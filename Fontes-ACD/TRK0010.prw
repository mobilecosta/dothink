#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "PARMTYPE.CH"
#include 'topconn.ch'
/*
1 Z13_FILIAL+Z13_DOC+Z13_SERIE+Z13_CLIENT+Z13_LOJA+Z13_ORDEM                                                                                                      
2 Z13_FILIAL+Z13_DOC+Z13_SERIE+Z13_CLIENT+Z13_LOJA+Z13_IMPRES                                                                                                  
DF=Danfe;LD=Laudo;OS=Ordem de Separacao;CL=Check-List de Embarque                                                               
*/

/*/{Protheus.doc} TRK0010
Geracao de Missao de Separacao (documentos para impressao)
@type function
@version  20250725
@author fernando.muta@dothink.com.br
@since 7/25/2025
@return variant, Sem Retorno
/*/
User Function TRK0010()

	Local aArea			:= GetArea()
	Private aCores		:= {}
    Private aRotina		:= MenuDef()
	Private aGetDados	:= {}
	Private aColNaoOrd	:= {}
	Private cAlias		:= "SZW"
	Private cCadastro	:= "Missao da Separacao"
	Private c518Cli		:= ""
	Private c518Loja	:= ""
	Private lCrescente	:= .F.
	Private nOrdena		:= 0
	Private oTimer
	Private oBrowse
	Private _aImpres := {{"DF","0",.T.},{"LD","1",.T.},{"OS","2",.T.},{"CL","3",.T.}} // [1]=DF=Danfe;LD=Laudo;OS=Ordem de Separacao;CL=Check-List de Embarque [2]=Ordem de Impressao, [3]=Indica se Imprime
	
	SX2->(DbSetOrder(1))
	If !SX2->(DbSeek("Z13"))
		MsgInfo("Tabela Z13 nao encontrada, tente em outra empresa ou 	verifique o dicionario")
		Return
	EndIf

	// Determina a legenda das faturas
	Aadd(aCores, {"Z13_STATUS=='0'", "BR_VERMELHO"	})	 // Nao Impresso
	Aadd(aCores, {"Z13_STATUS=='1'", "BR_VERDE"})        // Impresso
	ProcTm()
	DbSelectArea("Z13")
	DbGotop()

	// Inicializa a MBrowse com os dados do cabeçalho do arquivo
	oMBrowse := MBrowse(,,,, "Z13",,,,,, aCores,,,,{|| fRefresh()})

	RestArea(aArea)

Return

/*/{Protheus.doc} mendef
Carrega itens do menu
@type function
@version  1.00
@author Fernando B.Muta
@since 16/07/2025
@return variant, Nil
/*/
Static Function MenuDef()

Local aRot	:= {}

Aadd(aRot, { "Pesquisar"	, "AxPesqui"	, 0,  1, 0, .F. })
Aadd(aRot, { "Visualizar"	, "AXVISUAL"	, 0,  2, 0, Nil })
Aadd(aRot, { "Imprimir"     , "U_TRK10IMP"	, 0,  3, 0, Nil }) 
Aadd(aRot, { "Legenda"	    , "U_TRK10LEG"	, 0,  9, 0, Nil })

Return aClone(aRot)


/*/{Protheus.doc} TRK10LEG
Funcao de legenda
@type function
@version  20250807
@author fernando.muta@dothink.com.br
@since 07/08/2025
/*/
User Function TRK10LEG()
// Instancia browse para Legenda
Local oLegenda	:= FWLegend():New()

oLegenda:Add("", "BR_VERDE"	  , "Impresso"		)
oLegenda:Add("", "BR_VERMELHO", "Nao Impresso"	)
oLegenda:Activate()
oLegenda:View()
oLegenda:DeActivate()

Return

/*/{Protheus.doc} TRK10IMP
Funcao de impressao do documento posicionado
@type function
@version  20250807
@author fernando.muta@dothink.com.br
@since 07/08/2025
/*/
User Function TRK10IMP()
local _lOkImp := .T.
local _aVarBkp
local cLog := ""

oTimer:Deactivate()

DbSelectArea("CB7")
CB7->( DbSetOrder(2) )

_cQry := " SELECT * FROM "+RetSqlName("Z13") + " Z13 "
_cQry += " INNER JOIN "+RetSqlName("SF2") + " SF2 ON F2_FILIAL=Z13_FILIAL AND F2_DOC=Z13_DOC AND Z13_SERIE=F2_SERIE AND Z13_CLIENT=F2_CLIENTE AND Z13_LOJA=F2_LOJA AND SF2.D_E_L_E_T_ = ' ' "
_cQry += " WHERE Z13_FILIAL = '"+Z13->Z13_FILIAL+"' "
_cQry += " AND   Z13_DOC    = '"+Z13->Z13_DOC   +"' "
_cQry += " AND   Z13_SERIE  = '"+Z13->Z13_SERIE +"' "
_cQry += " AND   Z13_CLIENT = '"+Z13->Z13_CLIENT+"' "
_cQry += " AND   Z13_LOJA   = '"+Z13->Z13_LOJA  +"' "
_cQry += " AND   Z13.D_E_L_E_T_   = ' ' "
_cQry += " ORDER BY Z13_ORDEM "
If Select("TRBZ13IMP")>0
	TRBZ13IMP->(DbCloseArea())
EndIf	
TCQUERY _cQry New Alias "TRBZ13IMP"

TRBZ13IMP->(DbGotop())
While !TRBZ13IMP->(Eof())
	_lOkImp := .T.
	// Imprime os que nao foram impressos ou o registro posisionado, mesmo ja impresso
	If TRBZ13IMP->Z13_STATUS=="0" .OR. (TRBZ13IMP->Z13_STATUS=="1" .AND. TRBZ13IMP->Z13_IMPRES == Z13->Z13_IMPRES)
		_aVarBkp := SaveInter()
		If TRBZ13IMP->Z13_IMPRES == 'DF'                  // Danfe
			TRK10DF()
		ElseIf  TRBZ13IMP->Z13_IMPRES == 'LD'             // LD=Laudo
			TRK10LD()
		ElseIf  TRBZ13IMP->Z13_IMPRES == 'OS'             // OS=Ordem de Separacao
			If CB7->( DbSeek( TRBZ13IMP->Z13_FILIAL + TRBZ13IMP->Z13_PEDIDO ) )
				TRK10OS()
			Else
				cLog += "Ordem de Separação do Pedido ["+TRBZ13IMP->Z13_PEDIDO+"] da Filial ["+TRBZ13IMP->Z13_FILIAL+"], não foi localizado." + Chr(13) + Chr(10)
			EndIf
		ElseIf  TRBZ13IMP->Z13_IMPRES == 'CL'             //CL=Check-List de Embarque  
			U_TRK0011()
		EndIf

		RestInter(_aVarBkp)	
		
		If _lOkImp
			Z13->(DbGoto(TRBZ13IMP->R_E_C_N_O_))
			RecLock("Z13",.F.)
			Z13->Z13_STATUS := '1'
			If Empty(Z13->Z13_DTIMP)
				Z13->Z13_DTIMP   := Date()
				Z13->Z13_HRIMP   := Time()
				Z13->Z13_USIMP   := cUserName				
			EndIf
			Z13->(MsUnlock())
		EndIf
	EndIf
	TRBZ13IMP->(DbSkip())
	Sleep(500)
	
	If !Empty(cLog)
		FWAlertError(cLog, "Falha")
	EndIf
End

oTimer:Activate()

TRBZ13IMP->(DbCloseArea())

Return

/*/{Protheus.doc} TRK10DF
description
@type function
@version  20250807
@author fernando.muta@dothink.com.br
@since 07/08/2025
/*/
Static Function TRK10DF()
Local _cIdEnt 
Local oDanfe
Local cPathDest := GetTempPath()
Local cPergSX1  := "NFSIGW"
Private cFilePrint := cFilePrint := "danfe_"+TRBZ13IMP->Z13_FILIAL+"_"+TRBZ13IMP->Z13_DOC+"_"+TRBZ13IMP->Z13_SERIE +"_"+DTOS(DATE())+"_"+ STRTRAN(TIME(),":","")
Private lUsaColab:= .F.
DbSelectArea("SF2")
DbSetOrder(1)
If !SF2->(DbSeek(TRBZ13IMP->Z13_FILIAL+TRBZ13IMP->Z13_DOC+TRBZ13IMP->Z13_SERIE+TRBZ13IMP->Z13_CLIENT+TRBZ13IMP->Z13_LOJA))
	Alert("Erro fatal speddanfe SF2! ")
	Return
EndIf	
Pergunte(cPergSX1,.F.)
MV_PAR01 := TRBZ13IMP->Z13_DOC
MV_PAR02 := TRBZ13IMP->Z13_DOC
MV_PAR03 := TRBZ13IMP->Z13_SERIE
MV_PAR04 := 2
SetMVValue(cPergSX1, "MV_PAR01", TRBZ13IMP->Z13_DOC    , .T.)
SetMVValue(cPergSX1, "MV_PAR02", TRBZ13IMP->Z13_DOC    , .T.)
SetMVValue(cPergSX1, "MV_PAR03", TRBZ13IMP->Z13_SERIE  , .T.)
SetMVValue(cPergSX1, "MV_PAR04", 2                     , .T.)

_cIdEnt := GetIdEnt(lUsaColab)
nFlags := PD_ISTOTVSPRINTER + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN
oSetup := FWPrintSetup():New(nFlags, "DANFE")
oSetup:aOptions[PD_VALUETYPE]:=cPathDest
//oSetup:Activate()

oDanfe:= FWMSPrinter():New(cFilePrint, IMP_PDF, .F., cPathDest, .T.)
oDanfe:nDevice  := IMP_PDF
oDanfe:cPathPDF := cPathDest
u_PrtNfeSef(_cIdEnt,,,oDanfe, oSetup, cFilePrint,.t.)
oDanfe:=Nil
oSetup:=Nil
Return()

/*/{Protheus.doc} GetIdEnt
Retorna o id da entidade
@type function
@version 20250807
@author fernando.muta@dothink.com.br
@since 07/08/2025
@param lUsaColab, logical, indica se usa o totvs colaboracao
@return character, id da entidade
/*/
Static Function GetIdEnt(lUsaColab)
Local oWs
Local aArea       := GetArea()
Local cIdEnt      := ""
Local cURL        := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local lUsaGesEmp  := IIF(FindFunction("FWFilialName") .And. FindFunction("FWSizeFilial") .And. FWSizeFilial() > 2,.T.,.F.)
Local lEnvCodEmp  := GetNewPar("MV_ENVCDGE",.F.)
Default lUsaColab := .F.

If	FunName() == "LOJA701"
	If !Empty(GetNewPar("MV_NFCEURL",""))
		cURL := PadR(GetNewPar("MV_NFCEURL","http://"),250)
	Endif
Endif

If !lUsaColab
	//--Obtem o codigo da entidade                              
	
	oWS := WsSPEDAdm():New()
	oWS:cUSERTOKEN := "TOTVS"
	
	oWS:oWSEMPRESA:cCNPJ       := IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),SM0->M0_CGC,"")
	oWS:oWSEMPRESA:cCPF        := IIF(SM0->M0_TPINSC==3,SM0->M0_CGC,"")
	oWS:oWSEMPRESA:cIE         := SM0->M0_INSC
	oWS:oWSEMPRESA:cIM         := SM0->M0_INSCM
	oWS:oWSEMPRESA:cNOME       := SM0->M0_NOMECOM
	oWS:oWSEMPRESA:cFANTASIA   := IIF(lUsaGesEmp,FWFilialName(),Alltrim(SM0->M0_NOME))
	oWS:oWSEMPRESA:cENDERECO   := FisGetEnd(SM0->M0_ENDENT)[1]
	oWS:oWSEMPRESA:cNUM        := FisGetEnd(SM0->M0_ENDENT)[3]
	oWS:oWSEMPRESA:cCOMPL      := FisGetEnd(SM0->M0_ENDENT)[4]
	oWS:oWSEMPRESA:cUF         := SM0->M0_ESTENT
	oWS:oWSEMPRESA:cCEP        := SM0->M0_CEPENT
	oWS:oWSEMPRESA:cCOD_MUN    := SM0->M0_CODMUN
	oWS:oWSEMPRESA:cCOD_PAIS   := "1058"
	oWS:oWSEMPRESA:cBAIRRO     := SM0->M0_BAIRENT
	oWS:oWSEMPRESA:cMUN        := SM0->M0_CIDENT
	oWS:oWSEMPRESA:cCEP_CP     := Nil
	oWS:oWSEMPRESA:cCP         := Nil
	oWS:oWSEMPRESA:cDDD        := Str(FisGetTel(SM0->M0_TEL)[2],3)
	oWS:oWSEMPRESA:cFONE       := AllTrim(Str(FisGetTel(SM0->M0_TEL)[3],15))
	oWS:oWSEMPRESA:cFAX        := AllTrim(Str(FisGetTel(SM0->M0_FAX)[3],15))
	oWS:oWSEMPRESA:cEMAIL      := "microsiga@mc-bauchemie.com.br"
	oWS:oWSEMPRESA:cNIRE       := SM0->M0_NIRE
	oWS:oWSEMPRESA:dDTRE       := SM0->M0_DTRE
	oWS:oWSEMPRESA:cNIT        := IIF(SM0->M0_TPINSC==1,SM0->M0_CGC,"")
	oWS:oWSEMPRESA:cINDSITESP  := ""
	oWS:oWSEMPRESA:cID_MATRIZ  := ""
	
	If lUsaGesEmp .And. lEnvCodEmp
		oWS:oWSEMPRESA:CIDEMPRESA:= FwGrpCompany()+FwCodFil()
	EndIf
	
	oWS:oWSOUTRASINSCRICOES:oWSInscricao := SPEDADM_ARRAYOFSPED_GENERICSTRUCT():New()
	oWS:_URL := AllTrim(cURL)+"/SPEDADM.apw"
	If oWs:ADMEMPRESAS()
		cIdEnt  := oWs:cADMEMPRESASRESULT
	Else
		Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"SPED-ERRO"},3)
	EndIf
	
	FreeObj(oWs)
	oWs := nil
	
else
	if !( ColCheckUpd() )
		//Aviso("SPED","UPDATE do TOTVS Colaboração 3.0 não aplicado. Desativado o uso do TOTVS Colaboração 3.0","totvscolab",3)
		msginfo("UPDATE NAO APLICADO...")
	else
		cIdEnt := "000000"
	endif
endIf

RestArea(aArea)
aArea := aSize(aArea,0)
aArea := nil

Return(cIdEnt)


/*/{Protheus.doc} IsReady
description
@type function
@version  20250807
@author fernando.muta@dothink.com.br
@since 07/08/2025
@param cURL, character, url da danfe
@param nTipo, numeric, Tipo
@param lHelp, logical, indica se tera help
@param lUsaColab, logical, indica se usa totvs colavoracao
@return logical, return_description
/*/
Static Function IsReady(cURL,nTipo,lHelp,lUsaColab)
Local oWS
Local cHelp       := ""
Local lRetorno    := .F.
DEFAULT nTipo     := 1
DEFAULT lHelp     := .F.
DEFAULT lUsaColab := .F.

if !lUsaColab
	If FunName() <> "LOJA701"
		If !Empty(cURL) .And. !PutMV("MV_SPEDURL",cURL)
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial( "SX6" )
			SX6->X6_VAR     := "MV_SPEDURL"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "URL SPED NFe"
			MsUnLock()
			PutMV("MV_SPEDURL",cURL)
		EndIf
		SuperGetMv() //Limpa o cache de parametros - nao retirar
		DEFAULT cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)
	Else
		If !Empty(cURL) .And. !PutMV("MV_NFCEURL",cURL)
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial( "SX6" )
			SX6->X6_VAR     := "MV_NFCEURL"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "URL de comunicação com TSS"
			MsUnLock()
			PutMV("MV_NFCEURL",cURL)
		EndIf
		SuperGetMv() //Limpa o cache de parametros - nao retirar
		DEFAULT cURL      := PadR(GetNewPar("MV_NFCEURL","http://"),250)
	EndIf
	
	//--Verifica se o servidor da Totvs esta no ar                            
	oWs := WsSpedCfgNFe():New()
	oWs:cUserToken := "TOTVS"
	oWS:_URL := AllTrim(cURL)+"/SPEDCFGNFe.apw"
	If oWs:CFGCONNECT()
		lRetorno := .T.
	Else
		If lHelp
			Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"Erro - SPED"},3)
		EndIf
		lRetorno := .F.
	EndIf

	//-- Verifica se o certificado digital ja foi transferido
	If nTipo <> 1 .And. lRetorno
		oWs:cUserToken := "TOTVS"
		oWs:cID_ENT    := GetIdEnt()
		oWS:_URL := AllTrim(cURL)+"/SPEDCFGNFe.apw"
		If oWs:CFGReady()
			lRetorno := .T.
		Else
			If nTipo == 3
				cHelp := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
				If lHelp .And. !"003" $ cHelp
					Aviso("SPED",cHelp,{"Certificado ira vencer"},3)
					lRetorno := .F.
				EndIf
			Else
				lRetorno := .F.
			EndIf
		EndIf
	EndIf
	
else
	lRetorno := ColCheckUpd()
	if lHelp .And. !lRetorno .And. !lAuto
		MsgInfo("UPDATE do TOTVS Colaboração 2.0 não aplicado. Desativado o uso do TOTVS Colaboração 2.0")
	endif
endif

Return(lRetorno)



/*/{Protheus.doc} fRefresh
Impressao Automatica de Documentos
@type function
@version  20250807
@author fernando.muta@dothink.com.br
@since 07/08/2025
@return variant, Sem Retorno
/*/
Static Function fRefresh(oMBrowse)

If oTimer == NIL
	DEFINE TIMER oTimer INTERVAL 10000 ACTION TRK010TM(.F.) OF GetWndDefault()
	oTimer:Activate()
Endif

Return

/*/{Protheus.doc} ProcTm
Executa regua de processamento da geracao de registros para impressao
@type function
@version 20250808
@author fernando.muta@dothink.com.br
@since 8/8/2025
/*/
Static Function ProcTm()
Processa( {||TRK010TM(.T.) },"Gerando registros para impressao...")
Return

/*/{Protheus.doc} TRK010TM
Geracao de registros para impressao
@type function
@version 20250808
@author fernando.muta@dothink.com.br
@since 8/8/2025
@param _lReguaTm, variant, Controle do IndRegua
/*/
Static Function TRK010TM(_lReguaTm)
local _iK
local _cQry    := ""
local _aRecZ13 := Z13->(GetArea())

If !oTimer == NIL
	oTimer:Deactivate()
EndIf	

_cQry := " SELECT F2_FILIAL,F2_SERIE, F2_DOC,F2_CLIENTE,F2_LOJA,F2_EMISSAO,SF2.F2_CARGA, SF2.R_E_C_N_O_ NRECNO,D2_PEDIDO,MAX(B1_DESC) B1_DESC "
_cQry += " FROM " + RetSqlName("SF2") + " SF2 "                   
_cQry += " INNER JOIN " + RetSqlName("SD2") + " SD2 ON D2_FILIAL=F2_FILIAL AND D2_DOC=F2_DOC AND D2_SERIE=F2_SERIE AND D2_CLIENTE=F2_CLIENTE AND D2_LOJA=F2_LOJA AND SD2.D_E_L_E_T_ = ' ' "
_cQry += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_FILIAL='" + xFilial("SB1") + "' AND D2_COD=B1_COD AND SB1.D_E_L_E_T_ = ' ' "
_cQry += " INNER JOIN " + RetSqlName("SF4") + " SF4 ON F4_FILIAL='" + xFilial("SF4") + "' AND D2_TES=F4_CODIGO AND SF4.D_E_L_E_T_ = ' ' AND F4_ESTOQUE='S'  "
_cQry += " WHERE F2_FILIAL = '" + xFilial("SF2") + "' "
_cQry += " AND   F2_FIMP in('T','S') " // Somente se a nota foi autorizada
_cQry += " AND   F2_ESPECIE = 'SPED' "
_cQry += " AND   F2_TIPO = 'N' "
_cQry += " AND   F2_EMISSAO = '" +dtos(ddatabase) + "' "
_cQry += " AND   SF2.D_E_L_E_T_ = ' ' "  
_cQry += " AND   NOT EXISTS (SELECT * FROM " + RetSqlName("Z13") +  " Z13 " "
_cQry += "                  WHERE F2_FILIAL = Z13_FILIAL "  
_cQry += "                   AND   F2_DOC    = Z13_DOC    "  
_cQry += "                   AND   F2_SERIE  = Z13_SERIE  "  
_cQry += "                   AND   F2_CLIENTE= Z13_CLIENT  " 
_cQry += "                   AND   F2_LOJA   = Z13_LOJA    " 
_cQry += "                   AND Z13.D_E_L_E_T_ = ' ' ) " 
_cQry += " AND   EXISTS (  SELECT * FROM  " + RetSqlName("CB8") +  " CB8 " "
_cQry += "                 WHERE D2_FILIAL = CB8_FILIAL "  
_cQry += "                 AND   D2_PEDIDO = CB8_PEDIDO "  
_cQry += "                 AND   CB8.D_E_L_E_T_ = ' ' )"  
_cQry += " GROUP BY F2_FILIAL,F2_SERIE, F2_DOC,F2_CLIENTE,F2_LOJA,F2_EMISSAO,SF2.F2_CARGA, SF2.R_E_C_N_O_ ,D2_PEDIDO "

If Select("TRBF2IMP")> 0
	TRBF2IMP->(DbCloseArea())
End

TCQUERY _cQry New Alias "TRBF2IMP"

TRBF2IMP->(DbGotop())
While !TRBF2IMP->(Eof())
	If _lReguaTm
		IncProc("Gerando registros para impressao")
	EndIf	
	For _iK:=1 To len(_aImpres)
		Z13->(DbSetOrder(2))
		_lNewZ13 := !Z13->(DbSeek( TRBF2IMP->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)+_aImpres[_iK][1] ))
		If _lNewZ13 .AND. _aImpres[_iK][3]
			RecLock("Z13",_lNewZ13)
			Z13->Z13_FILIAL  := TRBF2IMP->F2_FILIAL
			Z13->Z13_STATUS  := "0"
			Z13->Z13_IMPRES  := _aImpres[_iK][1]
			Z13->Z13_ORDEM   := _aImpres[_iK][2]
			Z13->Z13_DOC     := TRBF2IMP->F2_DOC
			Z13->Z13_SERIE   := TRBF2IMP->F2_SERIE
			Z13->Z13_CLIENT  := TRBF2IMP->F2_CLIENTE
			Z13->Z13_LOJA    := TRBF2IMP->F2_LOJA
			Z13->Z13_PEDIDO  := TRBF2IMP->D2_PEDIDO
			Z13->Z13_EMISS   := STOD(TRBF2IMP->F2_EMISSAO)
			Z13->Z13_F2REC   := STRZERO(TRBF2IMP->NRECNO,14)
			Z13->(MsUnlock())
		EndIf
	Next     
	TRBF2IMP->(DbSkip())
End
TRBF2IMP->(DbCloseArea()) 

Z13->(RestArea(_aRecZ13))

If !oTimer == NIL
	oMBrowse := GetObjBrow()
	oMBrowse:Refresh()
	oTimer:Activate()
EndIf

Return

/*/{Protheus.doc} TRK10LD
Impressao de Laudo
@type function
@version 20250808 
@author fernando.muta@dothink.com.br
@since 8/8/2025
/*/
Static Function TRK10LD()
local cPergSX1 := "PRT0688"
local nTam     := TamSX3("D3_OP")[1]

pergunte(cPergSX1, .F.)

//MV_PAR01 := Space(nTam)				// OP de?
//MV_PAR02 := Replic("Z", nTam)       // OP até?
//nTam     := TamSX3("D3_LOTECTL")[1]
//MV_PAR03 := Space(nTam)             // Do Lote ?
//MV_PAR04 := Replic("Z",nTam)  		// Até Lote ?
//nTam     := TamSX3("D3_COD")[1]
//MV_PAR05 := Space(nTam)	            // Do Produto ?
//MV_PAR06 := Replic("Z",nTam)      	// Até Produto ?
//MV_PAR07 := ctod("  /  /  ")        // De Data?
//MV_PAR08 := date()+360              // Até Data?
//MV_PAR09 := TRBZ13IMP->Z13_PEDIDO   // De Pedido de Venda?
//MV_PAR10 := TRBZ13IMP->Z13_PEDIDO   // Até Pedido de Venda

SetMVValue(cPergSX1, "MV_PAR01", Space(nTam), .F.)
SetMVValue(cPergSX1, "MV_PAR02", Replic("Z", nTam), .F.)
nTam     := TamSX3("D3_LOTECTL")[1]
SetMVValue(cPergSX1, "MV_PAR03", Space(nTam), .F.)
SetMVValue(cPergSX1, "MV_PAR04", Replic("Z",nTam), .F.)
nTam     := TamSX3("B1_COD")[1]
SetMVValue(cPergSX1, "MV_PAR05", Space(nTam), .F.)
SetMVValue(cPergSX1, "MV_PAR06", Replic("Z",nTam), .F.)
SetMVValue(cPergSX1, "MV_PAR07", ctod("  /  /  "), .F.)
SetMVValue(cPergSX1, "MV_PAR08", date()+360, .F.)
SetMVValue(cPergSX1, "MV_PAR09", TRBZ13IMP->Z13_PEDIDO, .F.)
SetMVValue(cPergSX1, "MV_PAR10", TRBZ13IMP->Z13_PEDIDO, .F.)

U_PRT0688(.F.,.T.,.F.,.F.)

Return

/*/{Protheus.doc} TRK10OS
Impressao de OS
@type function
@version 20250808 
@author fernando.muta@dothink.com.br
@since 8/8/2025
/*/
Static Function TRK10OS()
	local aArea := GetArea()
	
	u_xacd100r(.T.)

	RestArea(aArea)
Return 
