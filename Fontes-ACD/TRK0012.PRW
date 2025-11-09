#include "totvs.ch"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"


/*/{Protheus.doc} TRK0012
Função de envio de email para transportadora - PL_012_v01.pdf
@type function
@version 1.0
@author DO THINK
@since 10/08/2025
@return logical, Indica se conseguiu enviar e-mail
/*/
User Function TRK0012(cEMail, cAssunto, cMsgFim)
Local aArea		:= Z09->(GetArea())
Local lRet      := .F.
Local cPathHTML := "\workflow"
Local cFileHTM  := cPathHTML + "\agentransp.html"
Local oHtml     := Nil
Local cFileName := ""
Local cTitOrig	:= ""
Local cTexto    := "" 
Local cAnexos	:= Nil
Local cErro		:= ""
Local cMsgIni	:= ""
Local cDtAgenda := ""
Local cEndOrig	:= ""
Local cEndDest	:= ""
Local cDestino	:= ""
Local cB5_ONU   := ""
Local cB5_ITEM	:= ""
Local cB5_RISCO := ""
Local cB5_CLASS := ""
Local cControla := ""
Local cXML      := ""
Local cItens	:= ""
Local aDadosFil := {}
Local cFile     := ""
Local nTotal	:= 0
Local cNomCliFor:= ""
Local aEnd		:= {}

Local cZ09_FILIAL := Z09->Z09_FILIAL
Local cZ09_NUMPV  := Z09->Z09_NUMPV
Local cZ09_ITEMPV := Z09->Z09_ITEMPV

Default cMsgFim := ""

If ! File(cFileHTM)
    ApMsgInfo("Arquivo [" + cFileHTM + "] não localizado no servidor !")
    Return lRet
EndIf

If Empty(cEmail)
	cErro := "Endereço de e-mail da transportadora [" + cTransp + "] não cadastrado!"
    
	If Isblind()
		Conout(cErro)
	Else
	    MsgAlert(cErro)
    EndIf 

	Return lRet
EndIf

If !Empty(Z09->Z09_DT1COL)
	cDtAgenda := DTOC(Z09->Z09_DT1COL)
EndIf

If !Empty(Z09->Z09_DT2COL)
	cDtAgenda := DTOC(Z09->Z09_DT2COL)
EndIf

If !Empty(Z09->Z09_DT3COL)
	cDtAgenda := DTOC(Z09->Z09_DT3COL)
EndIf

//-- Se nao tiver agendamento, nao envia email
If Empty(cDtAgenda)
	ApMsgInfo("O agendamento não foi realizado! Favor realizar agendamento para o envio!")
	Return
EndIf

//Carrega os dados da empresa e filial logada
If !fInfo(@aDadosFil, Z09->Z09_FILIAL)
	ApMsgInfo("Erro ao carregar dados da filial do pedido!")
	Return
EndIf

//-- Ajusta assunto
cAssunto += " Pedido " + Z09->Z09_NUMPV + " (Filial: " + AllTrim(aDadosFil[1]) + " - " + AllTrim(aDadosFil[2]) + ")"

// Pedido de Vendas
SC5->( DbSetOrder(1) )
SC5->( DbSeek(Z09->Z09_FILIAL + Z09->Z09_NUMPV) )

nTotal := If(!Empty(Z09->Z09_TOTAL), Z09->Z09_TOTAL,If(!Empty(SC5->C5_XTOTAL),SC5->C5_XTOTAL, u_TRK0005A(Z09->Z09_NUMPV) ))

If SC5->C5_TIPO $ 'F|B'
	SA2->( DbSetOrder(1) )
	SA2->( DbSeek(xFilial() + SC5->(C5_CLIENT + C5_LOJAENT)) )
	aadd(aEnd, SA2->A2_END		)
	aadd(aEnd, SA2->A2_COMPLEM	)
	aadd(aEnd, SA2->A2_BAIRRO	)
	aadd(aEnd, SA2->A2_MUN		)
	aadd(aEnd, SA2->A2_EST		)
	cNomCliFor := " (Fornecedor: " + AllTrim(SA2->A2_NOME) + ")"
Else
	SA1->( DbSetOrder(1) )
	SA1->( DbSeek(xFilial() + SC5->(C5_CLIENT + C5_LOJAENT)) )

	aadd(aEnd, SA1->A1_END		)
	aadd(aEnd, SA1->A1_COMPLEM	)
	aadd(aEnd, SA1->A1_BAIRRO	)
	aadd(aEnd, SA1->A1_MUN		)
	aadd(aEnd, SA1->A1_EST		)
	cNomCliFor := " (Cliente: " + AllTrim(SA1->A1_NOME) + ")"
EndIf


//-- Endereco de Origem
cEndOrig := AllTrim(aDadosFil[4]) + ", " + AllTrim(aDadosFil[14]) + ", " + AllTrim(aDadosFil[13]) + ", " + AllTrim(aDadosFil[5]) + ", " + AllTrim(aDadosFil[6])

If Empty(SC5->C5_REDESP)
	//-- Endereco de Destino (Cliente de Entrega)
	cEndDest := aEnd[1]
	If !Empty(aEnd[2])
		cEndDest += ", " + AllTrim(aEnd[2])
	EndIf
	If !Empty(aEnd[3])
		cEndDest += ", " + AllTrim(aEnd[3])
	EndIf
	If !Empty(aEnd[4])
		cEndDest += ", " + AllTrim(aEnd[4])
	EndIf
	If !Empty(aEnd[5])
		cEndDest += ", " + AllTrim(aEnd[5])
	EndIf

	cEndDest := "<strong>" + cEndDest + "</strong>"
	cDestino := "cliente"
Else
	//-- Endereco de Destino (Transportadaora Redespacho)
	// Transportadora Redespacho
	SA4->( DbSetOrder(1) )
	SA4->( DbSeek(xFilial() + SC5->C5_REDESP) )	

	cEndDest := SA4->A4_END
	If !Empty(SA4->A4_COMPLEM)
		cEndDest += ", " + AllTrim(SA4->A4_COMPLEM)
	EndIf
	If !Empty(SA4->A4_BAIRRO)
		cEndDest += ", " + AllTrim(SA4->A4_BAIRRO)
	EndIf
	If !Empty(SA4->A4_MUN)
		cEndDest += ", " + AllTrim(SA4->A4_MUN)
	EndIf
	If !Empty(SA4->A4_EST)
		cEndDest += ", " + AllTrim(SA4->A4_EST)
	EndIf

	cEndDest := "<strong>" + cEndDest + "</strong>"

	cDestino := "Transp.Redespacho"
EndIf

// Transportadora
SA4->( DbSetOrder(1) )
SA4->( DbSeek(xFilial() + Z09->Z09_TRANSP) )

// Cabeçalho da Nota Fiscal
If !Empty(Z09->Z09_NF)

	If Empty(Z09->Z09_XMLNF)
		SF2->(DbSetOrder(1))
		SF2->(DbSeek(Z09->(Z09_FILIAL + Z09_NF)))

		cXML := SpedXML(Z09->Z09_NF, Z09->Z09_SERIE, "")
		IF ! Empty(cXML) 
			Z09->(DbSetOrder(3))	// Z09_FILIAL + Z09_NUMPV + Z09_ITEMPV

			While 	Z09->Z09_FILIAL == cZ09_FILIAL .And. Z09->Z09_NUMPV == cZ09_NUMPV .And.;
					Z09->Z09_ITEMPV == cZ09_ITEMPV .And. ! Z09->(Eof())

				Z09->(RecLock("Z09", .F.))
				Z09->Z09_XMLNF := cXML
				Z09->(MsUnLock())

				Z09->(DbSkip())
			EndDo

		EndIF

	Else
		cXML := Z09->Z09_XMLNF
	EndIf

	If !Empty(cXML)
		cAnexos := "\workflow\nf_" + AllTrim(Z09->Z09_NF) + AllTrim(Z09->Z09_SERIE) + ".xml"
		MemoWrite(cAnexos, cXML)
	
		cAnexos += ","

		cFile := TRK12DF()
		If File(cFile)
			cAnexos += cFile + "," 
		EndIf

	EndIf

	Z09->(RestArea(aArea))

EndIf

oHtml := TWFHtml():New( cFileHTM )


cTitOrig := If( Empty(Z09->Z09_NF), "o Pedido <strong>"+ Z09->Z09_NUMPV +"</strong>", "a NF <strong>"+ Z09->Z09_NF +"</strong>"  )

oHTML:ValByName("INFO_PEDIDO"	, Substr(cTitOrig, 3)							)
oHTML:ValByName("DT_AGENDADA"	, cDtAgenda										)
oHTML:ValByName("A4_NOME"		, SC5->C5_TRANSP + " - " + AllTrim(SA4->A4_NOME))
oHTML:ValByName("DESTINO"		, cDestino										)

cMsgIni := "Informamos que " + cTitOrig 
cMsgIni += cNomCliFor + ", esta disponível para coleta, no endereço: "
cMsgIni += "<strong>" + cEndOrig + "</strong>"
cMsgIni += ", no dia <strong>" + cDtAgenda + "</strong>."

oHTML:ValByName("MSG_INI"	, cMsgIni									)

If Empty(Z09->Z09_NF)
	oHTML:ValByName("VLR_TOTAL"	, Trans(nTotal, "@E 999,999,999.99"))
Else
	oHTML:ValByName("VLR_TOTAL"	, Trans(SF2->(F2_VALBRUT + F2_VALIPI), "@E 999,999,999.99"))
EndIf

oHTML:ValByName("C5_TPFRETE"	, U_DtCombo("Z09_ICOTER", SC5->C5_TPFRETE))
oHTML:ValByName("END_ENTREGA"	, cEndDest)

// Item de Pedido
SC6->( DbSetOrder(1) )
SC6->( DbSeek( Z09->(Z09_FILIAL + Z09_NUMPV) ) )
While ! SC6->( Eof() ) .And. SC6->(C6_FILIAL + C6_NUM) == Z09->(Z09_FILIAL + Z09_NUMPV)

	//-- Inicializa variaveis
	cB5_ONU		:= ""
	cB5_ITEM	:= ""
	cB5_RISCO	:= ""
	cB5_CLASS	:= ""
	cControla	:= ""

	//-- SB1 -> Cadastro de produto
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1") + SC6->C6_PRODUTO))

	If SB1->B1_XLICFED == "1"
		cControla += "Policia Federal"
	EndIf
	 
	If SB1->B1_XLICCIV == "1"
		If !Empty(cControla)
			cControla += ", "
		EndIf
		cControla += "Policia Civil"
	EndIf

	If SB1->B1_LICEXER == "1"
		If !Empty(cControla)
			cControla += ", "
		EndIf
		cControla += "Exercito"
	EndIf

	//-- SB5 -> Complemento de Produto
	SB5->(DbSetOrder(1))
	If SB5->(DbSeek(xFilial("SB5") + SC6->C6_PRODUTO))
	
		cB5_ONU		:= AllTrim(SB5->B5_ONU)
		cB5_ITEM	:= AllTrim(SB5->B5_ITEM)
		
		If SB5->(FieldPos("B5_XRISCO")) .And. !Empty(SB5->B5_XRISCO)
			cB5_RISCO := SB5->B5_XRISCO 
		EndIF

		If ! Empty(cB5_ONU)
			DbSelectArea("DY3")
			DY3->( DbSetOrder(1) )
			If DY3->( DbSeek(xFilial() + SB5->B5_ONU + cB5_ITEM) )
				cB5_ONU 	:= cB5_ONU + " - " + DY3->DY3_ITEM + " - "+ AllTrim(DY3->DY3_DESCRI)
				cB5_RISCO 	:= AllTrim(DY3->DY3_NRISCO)
				cB5_CLASS	:= AllTrim(DY3->DY3_CLASSE)
			EndIf
		EndIf


	EndIf
	

    cItens += '<div style="border:1px solid #ccc; border-radius:5px; padding:10px; margin-bottom:10px;">'
    cItens += '<p style="margin:5px 0;"><strong>Item:</strong> ' + SC6->C6_ITEM + '</p>'
    cItens += '<p style="margin:5px 0;"><strong>Produto:</strong> ' + SC6->C6_PRODUTO + '</p>'
    cItens += '<p style="margin:5px 0;"><strong>Quantidade:</strong> ' + Trans(SC6->C6_QTDVEN, "@E 999,999,999.99") + '</p>'
	cItens += '<p style="margin:5px 0;"><strong>Volume(s):</strong> ' + cValToChar( ConvUm(SC6->C6_PRODUTO, SC6->C6_QTDVEN, 0, 2) ) + '</p>'
    cItens += '<p style="margin:5px 0;"><strong>ONU:</strong> ' + cB5_ONU + '</p>'
	cItens += '<p style="margin:5px 0;"><strong>Risco:</strong> ' + cB5_RISCO + '</p>'
    cItens += '<p style="margin:5px 0;"><strong>Classe:</strong> ' + cB5_CLASS + '</p>'
    cItens += '<p style="margin:5px 0;"><strong>Controlado:</strong> '+cControla+'</p>'
    cItens += '</div>	

	SC6->( DbSkip() )
EndDo
oHTML:ValByName("ITENS"		, cItens									)
oHTML:ValByName("REQUISITO"	, AllTrim(Z09->Z09_RESTR)					)
oHTML:ValByName("C5_PESOL"	, Trans(SC5->C5_PESOL	, "@E 999,999.9999"))
oHTML:ValByName("C5_PBRUTO"	, Trans(SC5->C5_PBRUTO	, "@E 999,999.9999"))
oHTML:ValByName("MSG_FIM"	, cMsgFim									)

cFileName := CriaTrab(NIL,.F.) + ".htm"
cFileName := cPathHTML + "\" + cFileName 
oHtml:SaveFile(cFileName)

cTexto := StrTran(WFLoadFile(cFileName), Chr(13), "")
cTexto := StrTran(cTexto, chr(10), "")
cTexto := OemtoAnsi(cTexto)

IF Empty(cEmail)
    If ! Isblind()
	    MsgAlert("Endereço de e-mail da transportadora [" + cTransp + "] não cadastrado!")
    EndIf 
Else
	lRet := U_xSendMail(ALLTRIM(cEMail), cAssunto, cTexto, cAnexos , .T.,,,,,)
Endif

RestArea(aArea)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³SendMail  ³ Autor ³ TI1369-ALEX FONSECA   ³ Data ³14.11.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Envio de E-mail                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Servido de E-mail                                     ³±±
±±³          ³ExpC2: Conta de E-mail                                       ³±±
±±³          ³ExpC3: Senha Conta E-mail                                    ³±±
±±³          ³ExpC4: String Contas E-mail destino                          ³±±
±±³          ³ExpC5: Assunto                                               ³±±
±±³          ³ExpC6: Corpo de Texto                                        ³±±
±±³          ³ExpC7: Arquivos Anexos                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico - .T. - Operacao realizada                            ³±±
±±³          ³       - .F. - Operacao NAO realizada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ AVIS                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function xSendMail(cMailDestino,cAssunto,cTexto,cAnexos,lJob,cCopia,cEmailDe,lAutentica,lFormatoTexto, cCopOcult  )

	Local lEnvio 	:= .F.
	Local cEmailTst	:= GetSrvProfString( "MailTestList", "" )
	Local lNovoMtd  := GETMV("TI_NVMTDMA",,.T.)  

	Default	cMailDestino:= ""
	Default cAssunto	:= ""
	Default cTexto		:= ""
	Default lJob		:= .F.
	Default	cCopia		:= ""
	Default	cCopOcult	:= ""
	Default lAutentica	:= .F.

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Avalia conteudo³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

	lAutentica := GetMv( 'MV_RELAUTH',,.F. )    //-- Força autenticação pois o parametro MV_RELAUTH do padrão precisa estar como .F.

	If 	Empty( cMailDestino )
		cMensagem := "Conta(s) de Email Destino - NAO INFORMADA."
		If ! lJob 
			MsgStop( cMensagem ) 
		EndIf
		Return(.F.)
	EndIf
	If 	Empty( cAssunto )
		cMensagem := "Assunto do E-mail - NAO INFORMADO"
		If ! lJob 
			MsgStop( cMensagem ) 
		EndIf
		Return(.F.)
	EndIf
	If 	Empty( cTexto )
		cMensagem := "Texto do E-mail - NAO INFORMADO"
		If ! lJob 
			MsgStop( cMensagem ) 
		EndIf
		Return(.F.)
	EndIf

	//Funcao Responsavel por Alterar as Variaveis de Envio de Email no Ambiente Teste
	If !( Empty( cEmailTst ) )
		TGetEmlTst( cEmailTst, @cMailDestino, @cCopia, @cTexto )
	EndIf

	If lNovoMtd
		If  lJob
			lEnvio := SendNvMtd( cMailDestino,cAssunto,cTexto,cAnexos,lJob,cCopia,cEmailDe,lAutentica,lFormatoTexto, cCopOcult  )
		Else
			Processa( { || lEnvio := SendNvMtd( cMailDestino, cAssunto, cTexto, cAnexos, lJob, cCopia, cEmailDe, lAutentica, lFormatoTexto, cCopOcult  ) } )
		EndIf
	Else
		If  lJob
			lEnvio := SendMail2( cMailDestino,cAssunto,cTexto,cAnexos,lJob,cCopia,cEmailDe,lAutentica,lFormatoTexto, cCopOcult  )
		Else
			Processa( { || lEnvio := SendMail2( cMailDestino, cAssunto, cTexto, cAnexos, lJob, cCopia, cEmailDe, lAutentica, lFormatoTexto, cCopOcult  ) } )
		EndIf
	EndIf
Return(lEnvio)

/*
SendNvMtd
Função de email para adequar a comunicação com o smtp-pulse.com:587

@author Oswaldo Leite
@since 25/09/2022
@version 1.0
*/
Static function SendNvMtd(cMailDestino,cAssunto,cTexto,cAnexos,lJob,cCopia,cEmailDe,lAutentica,lFormatoTexto, cCopOcult)
Local cMailServer 	:= GETMV("MV_RELSERV")
Local nPort         := GETMV("TI_PORSMTP",,587)
Local cStrPort      := ":" + Alltrim( STR(nPort) )
Local cMailCtaAut  	:= GETMV("MV_RELACNT",,'erpcorporativo@totvs.com.br')
Local cMailSenha  	:= GETMV("MV_RELPSW")
Local oServer       := Nil 
Local oMessage      := Nil 
Local nArr          := 0 
Local cMAilError    := ""
Local nErro         := 0
Local cMensagem     := ""  
Local lEnvio        := .T. 
Local n1            := 0 
Local aFiles        := {}
Local cTstAnexos    := ''
DEFAULT cEmailDe 	:= GETMV("MV_RELFROM",,'erpcorporativo@totvs.com.br')
DEFAULT	cCopia		:= ""
DEFAULT	cCopOcult	:= ""
DEFAULT lAutentica 	:= .F.//sem uso
DEFAULT lFormatoTexto := .F.//sem uso

If cAnexos <> Nil 
	cTstAnexos := strtran(cAnexos, ",", "SEPARADOR" )
	If cTstAnexos != cAnexos
		aFiles        := StrTokArr2( cAnexos, "," )
	Else
		aFiles        := StrTokArr2( cAnexos, ";" )
	EndIf
EndIf

cMailServer := STRTRAN( cMailServer, cStrPort, "")

If 	!( lJob )
	ProcRegua(3)
	IncProc("Conectando ao servidor de Email !!!")
End
	
oServer := TMailManager():New()      
oServer:SetUseTLS(.T.)  
oServer:Init('', cMailServer, cMailCtaAut, cMailSenha, 0, nPort )

nArr       := oServer:SetSMTPTimeOut( 120 )       
cMAilError := oServer:GetErrorString(nArr)

If  oServer:SMTPConnect() <> 0      
	cMensagem := "Ocorreu um problema ao determinar o Time-Out do servidor SMTP ou nao foi possível estabelecer a conexao com o mesmo." 
	Iif( lJob , ConOut( cMensagem ) , MsgStop( cMensagem ) ) 
	lEnvio := .F.
Else
	nErro := oServer:SmtpAuth(cMailCtaAut, cMailSenha)

	If nErro <> 0
        cMAilError := oServer:GetErrorString(nErro)
        DEFAULT cMailError := '***UNKNOW***'
        cMensagem := "Erro de Autenticacao " + Str(nErro,4) + '(' + cMAilError + ')'
		Iif( lJob , ConOut( cMensagem ) , MsgStop( cMensagem ) ) 
        oServer := Nil
    	lEnvio := .F.
    EndIf	
EndIf

If lEnvio 
   	oMessage := TMailMessage():New()         
	oMessage:Clear()                            
	
	//--Popula com os dados de envio
	oMessage:cFrom 	  := cEmailDe 
	oMessage:cTo 	  := cMailDestino 
	oMessage:cCc	  := cCopia 
	oMessage:cBcc	  := cCopOcult
	oMessage:cSubject := cAssunto
	oMessage:cBody    := cTexto  
	For n1 := 1 to Len(aFiles)
		oMessage:AttachFile( aFiles[n1] )
	Next 
		
	If oMessage:Send(oServer) != 0
		cMensagem :=  "Erro ao enviar o e-mail" 
		Iif( lJob , ConOut( cMensagem ) , MsgStop( cMensagem ) ) 
		lEnvio := .F.
	Else     
		If Empty(oMessage:cTo)
			cMensagem :=  "Erro ao enviar o e-mail" 
			Iif( lJob , ConOut( cMensagem ) , MsgStop( cMensagem ) ) 
			lEnvio := .F.
		endif
	EndIf
	        
    oMessage := Nil
                                                       
	//--Desconecta do servidor
	If oServer:SMTPDisconnect() != 0
		cMensagem := "Erro ao disconectar do servidor SMTP" 
		Iif( lJob , ConOut( cMensagem ) , MsgStop( cMensagem ) ) 
		lEnvio := .F.
	EndIf
Endif

return lEnvio 


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³SendMail2 ³ Autor ³ TI1369-ALEX FONSECA   ³ Data ³14.11.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Envio de E-mail                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico Avis                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function SendMail2( cMailDestino,cAssunto,cTexto,cAnexos,lJob,cCopia,cEmailDe, lAutentica, lFormatoTexto, cCopOcult  )

	Local cMailServer 	:= GETMV("MV_RELSERV")

	Local cAutMailServer:= GETMV("MV_AUTRELS",,'smtp.totvs.com.br')

	//PARA CONECTAR E ENVIAR E_MAILS
	Local cMailConta  	:= GETMV("MV_RELACNT",,'erpcorporativo@totvs.com.br')
	Local cMailSenha  	:= GETMV("MV_RELPSW")

	//PARA ATENTICAR NO SERVIDOR DE EMAIL
	Local cUsrAutent  	:= GETMV("MV_RELAUSR",,"wf")
	Local cPswAutent  	:= GETMV("MV_RELAPSW")

	DEFAULT cEmailDe 	:= GETMV("MV_RELFROM",,'erpcorporativo@totvs.com.br')

	//-- DEVE ser informado .T. sempre que o destinatario for != @microsiga.com.br
	DEFAULT lAutentica 	:= .F.
	DEFAULT	cCopia		:= ""
	DEFAULT	cCopOcult	:= ""
	DEFAULT lFormatoTexto := .F.


	lConexao			:= .F.
	lEnvio   			:= .F.
	lDesconexao			:= .F.
	lRetAutenticacao	:= .T.
	cErro_Conexao 		:= ""
	cErro_Envio			:= ""
	cErro_Desconexao	:= ""

	If 	!( lJob )
		/// Inicializa regua processamento
		ProcRegua(3)

		IncProc("Conectando ao servidor de Email !!!")
	End
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³EXECUTA conexão ao servidor mencionado no parametro³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	If 	!(lAutentica)
		Connect Smtp Server cMailServer ACCOUNT cMailConta PASSWORD cMailSenha RESULT lConexao
	Else
		Connect Smtp Server cAutMailServer ACCOUNT cMailConta PASSWORD cMailSenha RESULT lConexao
		lRetAutenticacao := MailAuth(cUsrAutent,cPswAutent)
	Endif

	IF !lConexao
		GET MAIL ERROR cErro_Conexao
		cMensagem := "Nao foi possivel estabelecer a CONEXAO com o servidor - " + cErro_Conexao
		If ! lJob 
			MsgStop( cMensagem ) 
		EndIf
		Return( .F. )
	ENdIf

	IF !lRetAutenticacao
		cMensagem := "AUTENTICACAO falhou no servidor SMTP.TOTVS.COM.BR"
		If ! lJob 
			MsgStop( cMensagem ) 
		EndIf
		Return( .F. )
	ENdIf

	If  !( lJob )
		IncProc("Enviando Email")
	EndIf
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³EXECUTA envio da mensagem³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If  !( Empty( cAnexos ) )
		If  lFormatoTexto
			Send Mail From cEmailDe To cMAILDESTINO CC cCOPIA BCC cCopOcult SubJect cASSUNTO BODY cTEXTO FORMAT TEXT ATTACHMENT cANEXOS RESULT lENVIO
		Else
			Send Mail From cEmailDe To cMAILDESTINO CC cCOPIA BCC cCopOcult SubJect cASSUNTO BODY cTEXTO ATTACHMENT cANEXOS RESULT lENVIO
		EndIf
	Else
		If  lFormatoTexto
			Send Mail From cEmailDe To cMAILDESTINO CC cCOPIA BCC cCopOcult SubJect cASSUNTO BODY cTEXTO FORMAT TEXT RESULT lENVIO
		Else
			Send Mail From cEmailDe To cMAILDESTINO CC cCOPIA BCC cCopOcult SubJect cASSUNTO BODY cTEXTO RESULT lENVIO
		EndIf
	EndIf

	If !lEnvio
		Get Mail Error cErro_Envio
		cMensagem := "Nao foi possivel ENVIAR a mensagem - " + cErro_Envio
		If ! lJob 
			MsgStop( cMensagem ) 
		EndIf
		Return( .F. )
	EndIf

	If 	!( lJob )
		IncProc("Desconectando do servidor de Email !!!")
	EndIf
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³EXECUTA disconexao ao servidor SMTP³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	DisConnect Smtp Server Result lDesconexao
	IF !lDesconexao
		Get Mail Error cErro_Desconexao
		cMensagem := "Nao foi possivel DESCONECTAR do servidor - " + cErro_Desconexao
		If ! lJob 
			MsgStop( cMensagem ) 
		EndIf
		Return( .F. )
	EndIf

Return(lEnvio)

User Function DtCombo( cCampo,cConteudo )

	Local cCaption := ""
	Local aSx3Box   := RetSx3Box( Posicione("SX3", 2, cCampo, "X3CBox()" ),,, TamSX3(cCampo)[1] )
	Local nPos  := Ascan( aSx3Box, { |aBox| aBox[2] = cConteudo } )

	If nPos > 0
		cCaption := AllTrim( aSx3Box[nPos][3] )
	EndIf

Return(cCaption)


/*/{Protheus.doc} SpedXML
Função para recuperar o XML do TSS para uso no Protheus
@type function
@version 1.0
@author DO THINK
@since 22/08/2025
/*/
User Function SpedXML(cDocumento, cSerie, cError)

	SpedXML(cDocumento, cSerie, cError)

Return

Static Function SpedXML(cDocumento, cSerie, cError)
    Local aArea        := GetArea()
    Local cURLTss      := PadR(GetNewPar("MV_SPEDURL","http://"),250)  
    Local oWebServ
    Local cIdEnt       := RetIdEnti()
    Local cTextoXML    := ""
    Default cDocumento := ""
    Default cSerie     := ""
    Default cArqXML    := GetTempPath()+"arquivo_"+cSerie+cDocumento+".xml"
    Default cError     := ""
        
    //Se tiver documento
    If !Empty(cDocumento)
        cDocumento := PadR(cDocumento, TamSX3('F2_DOC')[1])
        cSerie     := PadR(cSerie,     TamSX3('F2_SERIE')[1])
            
        //Instancia a conexão com o WebService do TSS    
        oWebServ:= WSNFeSBRA():New()
        oWebServ:cUSERTOKEN        := "TOTVS"
        oWebServ:cID_ENT           := cIdEnt
        oWebServ:oWSNFEID          := NFESBRA_NFES2():New()
        oWebServ:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()
        aAdd(oWebServ:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
        aTail(oWebServ:oWSNFEID:oWSNotas:oWSNFESID2):cID := (cSerie+cDocumento)
        oWebServ:nDIASPARAEXCLUSAO := 0
        oWebServ:_URL              := AllTrim(cURLTss)+"/NFeSBRA.apw"
            
        //Se tiver notas
        If oWebServ:RetornaNotas()
            //Se tiver dados
            If Len(oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3) > 0
                
                //Se tiver sido cancelada
                If oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFECANCELADA != Nil
                    cTextoXML := oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFECANCELADA:cXML
                        
                //Senão, pega o xml normal (foi alterado abaixo conforme dica do Jorge Alberto)
                Else
                    cTextoXML := '<?xml version="1.0" encoding="UTF-8"?>'
                    cTextoXML += '<nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" versao="4.00">'
                    cTextoXML += oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFE:cXML
                    cTextoXML += oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFE:cXMLPROT
                    cTextoXML += '</nfeProc>'
                EndIf
            EndIf
        //Senão, houve erros na classe
        Else
            cError := IIf(Empty(GetWscError(3)), GetWscError(1), GetWscError(3))
        EndIf
    EndIf
    RestArea(aArea)
Return cTextoXML

Static _cIdEnt := Nil

Static Function TRK12DF()
Local oDanfe
Local cPathDest := GetTempPath()
Local cPergSX1  := "NFSIGW"
Local cChave    := Z09->(AllTrim(Z09_FILIAL)+"_"+AllTrim(Z09_NF)+"_"+AllTrim(Z09_SERIE))
Private cFilePrint := "danfe_"+cChave+"_"+DTOS(DATE())+"_"+ STRTRAN(TIME(),":","") + ".pdf"
Private lUsaColab:= .F.

Pergunte(cPergSX1,.F.)
MV_PAR01 := Z09->Z09_NF
MV_PAR02 := Z09->Z09_NF
MV_PAR03 := Z09->Z09_SERIE
MV_PAR04 := 2
SetMVValue(cPergSX1, "MV_PAR01", Z09->Z09_NF     , .T.)
SetMVValue(cPergSX1, "MV_PAR02", Z09->Z09_NF     , .T.)
SetMVValue(cPergSX1, "MV_PAR03", Z09->Z09_SERIE  , .T.)
SetMVValue(cPergSX1, "MV_PAR04", 2               , .T.)

If _cIdEnt  == Nil
	_cIdEnt := GetIdEnt(lUsaColab)
EndIf

nFlags := PD_ISTOTVSPRINTER + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN
oSetup := FWPrintSetup():New(nFlags, "DANFE")
oSetup:aOptions[PD_VALUETYPE]:=cPathDest
//oSetup:Activate()

oDanfe:= FWMSPrinter():New(cFilePrint, IMP_PDF, .F., cPathDest, .T.)
oDanfe:nDevice  := IMP_PDF
oDanfe:cPathPDF := cPathDest
u_PrtNfeSef(_cIdEnt,,,oDanfe, oSetup, cFilePrint,.t.)

__CopyFile(cPathDest+cFilePrint,"\workflow\"+cFilePrint)
oDanfe:=Nil
oSetup:=Nil
Return("\workflow\"+cFilePrint)

Static Function GetIdEnt(lUsaColab)

Local aArea  := GetArea()
Local cIdEnt := ""
Local cURL   := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local oWs
Local lUsaGesEmp	:= IIF(FindFunction("FWFilialName") .And. FindFunction("FWSizeFilial") .And. FWSizeFilial() > 2,.T.,.F.)
Local lEnvCodEmp := GetNewPar("MV_ENVCDGE",.F.)
Default lUsaColab := .F.

If	FunName() == "LOJA701"
	If !Empty(GetNewPar("MV_NFCEURL",""))
		cURL := PadR(GetNewPar("MV_NFCEURL","http://"),250)
	Endif
Endif

If !lUsaColab
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtem o codigo da entidade                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
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



User Function TRK0012D(cEMail, cAssunto, cMsgFim)
Local aArea		:= Z09->(GetArea())
Local lRet      := .F.
Local cPathHTML := "\workflow"
Local cFileHTM  := cPathHTML + "\cancelagentransp.html"
Local oHtml     := Nil
Local cFileName := ""
Local cTitOrig	:= ""
Local cTexto    := "" 
Local cAnexos	:= Nil
Local cErro		:= ""
Local cMsgIni	:= ""
Local cDtAgenda := ""
Local cEndOrig	:= ""
Local cEndDest	:= ""
Local cDestino	:= ""
Local aDadosFil := {}
Local nTotal	:= 0
Local cNomCliFor:= ""
Local aEnd		:= {}

Default cMsgFim := ""

If ! File(cFileHTM)
    ApMsgInfo("Arquivo [" + cFileHTM + "] não localizado no servidor !")
    Return lRet
EndIf

If Empty(cEmail)
	cErro := "Endereço de e-mail da transportadora [" + cTransp + "] não cadastrado!"
    
	If Isblind()
		Conout(cErro)
	Else
	    MsgAlert(cErro)
    EndIf 

	Return lRet
EndIf

//Carrega os dados da empresa e filial logada
If !fInfo(@aDadosFil, Z09->Z09_FILIAL)
	ApMsgInfo("Erro ao carregar dados da filial do pedido!")
	Return
EndIf

If !Empty(Z09->Z09_DT1COL)
	cDtAgenda := DTOC(Z09->Z09_DT1COL)
EndIf

If !Empty(Z09->Z09_DT2COL)
	cDtAgenda := DTOC(Z09->Z09_DT2COL)
EndIf

If !Empty(Z09->Z09_DT3COL)
	cDtAgenda := DTOC(Z09->Z09_DT3COL)
EndIf


//-- Ajusta assunto
cAssunto += " Pedido " + Z09->Z09_NUMPV + " (Filial: " + AllTrim(aDadosFil[1]) + " - " + AllTrim(aDadosFil[2]) + ")"

// Pedido de Vendas
SC5->( DbSetOrder(1) )
SC5->( DbSeek(Z09->Z09_FILIAL + Z09->Z09_NUMPV) )

nTotal := If(!Empty(Z09->Z09_TOTAL), Z09->Z09_TOTAL,If(!Empty(SC5->C5_XTOTAL),SC5->C5_XTOTAL, u_TRK0005A(Z09->Z09_NUMPV) ))

If SC5->C5_TIPO $ 'F|B'
	SA2->( DbSetOrder(1) )
	SA2->( DbSeek(xFilial() + SC5->(C5_CLIENT + C5_LOJAENT)) )
	aadd(aEnd, SA2->A2_END		)
	aadd(aEnd, SA2->A2_COMPLEM	)
	aadd(aEnd, SA2->A2_BAIRRO	)
	aadd(aEnd, SA2->A2_MUN		)
	aadd(aEnd, SA2->A2_EST		)
	cNomCliFor := " (Fornecedor: " + AllTrim(SA2->A2_NOME) + ")"
Else
	SA1->( DbSetOrder(1) )
	SA1->( DbSeek(xFilial() + SC5->(C5_CLIENT + C5_LOJAENT)) )

	aadd(aEnd, SA1->A1_END		)
	aadd(aEnd, SA1->A1_COMPLEM	)
	aadd(aEnd, SA1->A1_BAIRRO	)
	aadd(aEnd, SA1->A1_MUN		)
	aadd(aEnd, SA1->A1_EST		)
	cNomCliFor := " (Cliente: " + AllTrim(SA1->A1_NOME) + ")"
EndIf


//-- Endereco de Origem
cEndOrig := AllTrim(aDadosFil[4]) + ", " + AllTrim(aDadosFil[14]) + ", " + AllTrim(aDadosFil[13]) + ", " + AllTrim(aDadosFil[5]) + ", " + AllTrim(aDadosFil[6])

If Empty(SC5->C5_REDESP)
	//-- Endereco de Destino (Cliente de Entrega)
	cEndDest := aEnd[1]
	If !Empty(aEnd[2])
		cEndDest += ", " + AllTrim(aEnd[2])
	EndIf
	If !Empty(aEnd[3])
		cEndDest += ", " + AllTrim(aEnd[3])
	EndIf
	If !Empty(aEnd[4])
		cEndDest += ", " + AllTrim(aEnd[4])
	EndIf
	If !Empty(aEnd[5])
		cEndDest += ", " + AllTrim(aEnd[5])
	EndIf

	cEndDest := "<strong>" + cEndDest + "</strong>"
	cDestino := "cliente"
Else
	//-- Endereco de Destino (Transportadaora Redespacho)
	// Transportadora Redespacho
	SA4->( DbSetOrder(1) )
	SA4->( DbSeek(xFilial() + SC5->C5_REDESP) )	

	cEndDest := SA4->A4_END
	If !Empty(SA4->A4_COMPLEM)
		cEndDest += ", " + AllTrim(SA4->A4_COMPLEM)
	EndIf
	If !Empty(SA4->A4_BAIRRO)
		cEndDest += ", " + AllTrim(SA4->A4_BAIRRO)
	EndIf
	If !Empty(SA4->A4_MUN)
		cEndDest += ", " + AllTrim(SA4->A4_MUN)
	EndIf
	If !Empty(SA4->A4_EST)
		cEndDest += ", " + AllTrim(SA4->A4_EST)
	EndIf

	cEndDest := "<strong>" + cEndDest + "</strong>"

	cDestino := "Transp.Redespacho"
EndIf

// Transportadora
SA4->( DbSetOrder(1) )
SA4->( DbSeek(xFilial() + Z09->Z09_TRANSP) )

cTexto := "Informamos que foi cancelado o agendamento do pedido "+ Z09->Z09_NUMPV 
oHtml := TWFHtml():New( cFileHTM )


cTitOrig := If( Empty(Z09->Z09_NF), "o Pedido <strong>"+ Z09->Z09_NUMPV +"</strong>", "a NF <strong>"+ Z09->Z09_NF +"</strong>"  )

oHTML:ValByName("INFO_PEDIDO"	, Substr(cTitOrig, 3)							)
oHTML:ValByName("DT_AGENDADA"	, cDtAgenda										)
oHTML:ValByName("A4_NOME"		, SC5->C5_TRANSP + " - " + AllTrim(SA4->A4_NOME))
oHTML:ValByName("DESTINO"		, cDestino										)

cMsgIni := "Informamos que foi <strong>cancelado</strong> o agendamento d" + cTitOrig 
cMsgIni += cNomCliFor + ", que estava disponível para coleta, no endereço: "
cMsgIni += "<strong>" + cEndOrig + "</strong>"
cMsgIni += ", para o dia <strong>" + cDtAgenda + "</strong>."

oHTML:ValByName("MSG_INI"	, cMsgIni									)

If Empty(Z09->Z09_NF)
	oHTML:ValByName("VLR_TOTAL"	, Trans(nTotal, "@E 999,999,999.99"))
Else
	SF2->(DbSetOrder(1))
	SF2->(DbSeek(Z09->(Z09_FILIAL + Z09_NF)))
	//oHTML:ValByName("MSG_INI"	, "Informamos que o Nota Fiscal  " + Z09->Z09_NF + ", esta disponível para coleta, a partir do dia " + cDtAgenda)
	oHTML:ValByName("VLR_TOTAL"	, Trans(SF2->(F2_VALBRUT + F2_VALIPI), "@E 999,999,999.99"))
EndIf

oHTML:ValByName("C5_TPFRETE"	, U_DtCombo("Z09_ICOTER", SC5->C5_TPFRETE))
oHTML:ValByName("END_ENTREGA"	, cEndDest)
oHTML:ValByName("C5_PBRUTO"	, Trans(SC5->C5_PBRUTO	, "@E 999,999.9999"))
oHTML:ValByName("MSG_FIM"	, cMsgFim									)

cFileName := CriaTrab(NIL,.F.) + ".htm"
cFileName := cPathHTML + "\" + cFileName 
oHtml:SaveFile(cFileName)

cTexto := StrTran(WFLoadFile(cFileName), Chr(13), "")
cTexto := StrTran(cTexto, chr(10), "")
cTexto := OemtoAnsi(cTexto)

IF Empty(cEmail)
    If ! Isblind()
	    MsgAlert("Endereço de e-mail da transportadora [" + cTransp + "] não cadastrado!")
    EndIf 
Else
	lRet := U_xSendMail(ALLTRIM(cEMail), cAssunto, cTexto, cAnexos , .T.,,,,,)
Endif

RestArea(aArea)

Return lRet
