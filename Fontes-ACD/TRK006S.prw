#include 'totvs.ch'
// Tabela SZ09
#DEFINE CZ09XFILIAL  01	// Filial        C [ 2 ][ 0 ] 01
#DEFINE CZ09XIDTRAC  02	// Id Tracking   C [13 ][ 0 ] 02
#DEFINE CZ09XBU      03	// BU            C [30 ][ 0 ] 03
#DEFINE CZ09XRESPON  04	// Reponsavel    C [30 ][ 0 ] 04
#DEFINE CZ09XNUMPV   05	// Pedido Venda  C [ 6 ][ 0 ] 05
#DEFINE CZ09XITEMPV  06	// Item PV       C [ 2 ][ 0 ] 06
#DEFINE DZ09XDTEMPV  07	// Emissao PV    D [ 8 ][ 0 ] 07
#DEFINE CZ09XHREMPV  08	// Hr.Emiss.PV   C [ 5 ][ 0 ] 08
#DEFINE DZ09XDPFAPV  09	// Prev.Fat.PV   D [ 8 ][ 0 ] 09
#DEFINE DZ09XDPEMPV  10	// Prev.Entr.PV  D [ 8 ][ 0 ] 10
#DEFINE CZ09XNF      11	// Nota Fiscal   C [ 9 ][ 0 ] 11
#DEFINE CZ09XSERIE   12	// Serie NF      C [ 3 ][ 0 ] 12
#DEFINE DZ09XDTEMNF  13	// Emissao NF    D [ 8 ][ 0 ] 13
#DEFINE CZ09XHREMNF  14	// Hr.Emiss.NF   C [ 5 ][ 0 ] 14
#DEFINE CZ09XCLIENT  15	// Cliente       C [ 6 ][ 0 ] 15
#DEFINE CZ09XLOJA    16	// Loja Cliente  C [ 2 ][ 0 ] 16
#DEFINE CZ09XNOMECL  17	// Nome Cliente  C [60 ][ 0 ] 17
#DEFINE NZ09XTOTAL   18	// Vlr. Total    N [16 ][ 2 ] 18
#DEFINE CZ09XICOTER  19	// Incoterm      C [ 1 ][ 0 ] 19
#DEFINE CZ09XTRANSP  20	// Transport.    C [ 6 ][ 0 ] 20
#DEFINE CZ09XNTRANS  21	// N.Transport.  C [40 ][ 0 ] 21
#DEFINE CZ09XREMNF   22	// NF Remessa    C [ 9 ][ 0 ] 22
#DEFINE CZ09XREMSER  23	// Serie Remess  C [ 3 ][ 0 ] 23
#DEFINE CZ09XREMICO  24	// Incoterm Rem  C [ 1 ][ 0 ] 24
#DEFINE CZ09XRENTRA  25	// Transp.Rem.   C [ 6 ][ 0 ] 25
#DEFINE CZ09XRENTRN  26	// N.Transp.Rem  C [40 ][ 0 ] 26
#DEFINE CZ09XCCE     27	// Car.Correcao  C [ 9 ][ 0 ] 27
#DEFINE CZ09XCCESER  28	// Serie CC      C [ 3 ][ 0 ] 28
#DEFINE DZ09XDT1COL  29	// Dt.1a Coleta  D [ 8 ][ 0 ] 29
#DEFINE CZ09XHR1COL  30	// Hr.1a Coleta  C [ 5 ][ 0 ] 30
#DEFINE CZ09XUS1COL  31	// Us.1a Coleta  C [10 ][ 0 ] 31
#DEFINE DZ09XDC1COL  32	// Dt.Conf.1a C  D [ 8 ][ 0 ] 32
#DEFINE CZ09XHC1COL  33	// Hr.Conf.1a C  C [ 5 ][ 0 ] 33
#DEFINE CZ09XUC1COL  34	// Us.Conf.1a C  C [10 ][ 0 ] 34
#DEFINE DZ09XDT2COL  35	// Dt.2a Coleta  D [ 8 ][ 0 ] 35
#DEFINE CZ09XHR2COL  36	// Hr.2a Coleta  C [ 5 ][ 0 ] 36
#DEFINE CZ09XUS2COL  37	// Us.2a Coleta  C [10 ][ 0 ] 37
#DEFINE DZ09XDC2COL  38	// Dt.Conf.2a C  D [ 8 ][ 0 ] 38
#DEFINE CZ09XHC2COL  39	// Hr.Conf.2a C  C [ 5 ][ 0 ] 39
#DEFINE CZ09XUC2COL  40	// Us.Conf.2a C  C [10 ][ 0 ] 40
#DEFINE DZ09XDT3COL  41	// Dt.3a Coleta  D [ 8 ][ 0 ] 41
#DEFINE CZ09XHR3COL  42	// Hr.3a Coleta  C [ 5 ][ 0 ] 42
#DEFINE CZ09XUS3COL  43	// Us.3a Coleta  C [10 ][ 0 ] 43
#DEFINE DZ09XDC3COL  44	// Dt.Conf.3a C  D [ 8 ][ 0 ] 44
#DEFINE CZ09XHC3COL  45	// Hr.Conf.3a C  C [ 5 ][ 0 ] 45
#DEFINE CZ09XUC3COL  46	// Us.Conf.3a C  C [10 ][ 0 ] 46
#DEFINE DZ09XDTPEMB  47	// Dt.Embarque   D [ 8 ][ 0 ] 47
#DEFINE CZ09XHRPEMB  48	// Hr.Embarque   C [ 5 ][ 0 ] 48
#DEFINE DZ09XDTEXPE  49	// Dt.Expedicao  D [ 8 ][ 0 ] 49
#DEFINE CZ09XHREXPE  50	// Hr.Expedicao  C [ 5 ][ 0 ] 50
#DEFINE CZ09XCTE     51	// CTE           C [16 ][ 0 ] 51
#DEFINE DZ09XDTENTR  52	// Dt.Real Entr  D [ 8 ][ 0 ] 52
#DEFINE CZ09XSTATUS  53	// Status        C [ 1 ][ 0 ] 53
#DEFINE CZ09XRESPPD  54	// Resp.Pendenc  C [30 ][ 0 ] 54
#DEFINE MZ09XOBSLOG  55	// Obs.Logistic  M [ 0 ][ 0 ] 55
#DEFINE NZ09XDIAS    56	// Dias          N [ 3 ][ 0 ] 56
#DEFINE MZ09XOBSCS   57	// Obs. CS       M [ 0 ][ 0 ] 57
#DEFINE CZ09XDEVNF   58	// NF Devolucao  C [ 9 ][ 0 ] 58
#DEFINE CZ09XDEVSER  59	// Serie NF Dev  C [ 3 ][ 0 ] 59
#DEFINE CZ09XSLA     60	// Status SLA    C [ 1 ][ 0 ] 60
#DEFINE CZ09XARMAZ   61	// Armazem       C [ 2 ][ 0 ] 61
#DEFINE CZ09XMOTIVO  62	// Motivos       C [ 6 ][ 0 ] 62
#DEFINE CZ09XDCMOTV  63	// Desc.Motivo   C [55 ][ 0 ] 63
#DEFINE MZ09XDSMOTV  64	// Det.Motivo    M [10 ][ 0 ] 64
#DEFINE CZ09XCDTPVC  65	// Tipo Veiculo  C [10 ][ 0 ] 65
#DEFINE CZ09XCHVNFE  66	// Chave NFe     C [44 ][ 0 ] 66
//Z11
#define CZ11XFILIAL 1 // Filial        C [ 2][0] 01
#define CZ11XORIG   2 // Origem        C [ 3][0] 02
#define CZ11XIDTRAC 3 // Id Tracking   C [13][0] 03
#define CZ11XEVENTO 4 // Desc.Evento   C [50][0] 04
#define CZ11XQUEM   5 // Quem Exec.    C [30][0] 05
#define DZ11XQUANDO 6 // Quando Exec.  D [ 8][0] 06
#define CZ11XHORA   7 // Hora Exec.    C [ 5][0] 07
#define CZ11XOQUE   8 // Oque Exec.    M [10][0] 08
#define NZ11XRECORI 9 // Recno.Origem  N [10][0] 09
#define CZ11XSTAMP  10 // TimeStamp     C [14][0] 10
#define CZ11XEMPORI 11 // Emp.Origem    C [ 2][0] 11
#define CZ11XFILORI 12 // Fil.Origem    C [ 2][0] 12

/*/{Protheus.doc} BTrackS
Gravacao do track documentos de saida
@type function
@version 1.0
@author fernando.muta@dothink.com.br
@since 30/07/2025
@param aTrackS, array, Informacoes para documento de saida
@return Nil, Sem Retorno
/*/
User Function TRK006S(aTrackS,cEvento)
local _lNew
local cPict		:= ""
local cLog    	:= ""
local aTrackL 	:= Array(12)
local aDbStrZ09 := {}
local nTCpos	:= 0
local nI		:= 0


DbSelectArea("Z09")
Z09->(DbSetOrder(3))

aDbStrZ09 := Z09->( DbStruct() )
nTCpos := Len(aDbStrZ09)

// Verificando existencia do registro
_lNew := !Z09->( DbSeek(aTrackS[FieldPos("Z09_FILIAL")] + aTrackS[FieldPos("Z09_NUMPV")] + aTrackS[FieldPos("Z09_ITEMPV")]) )

If _lNew
	While .T.
		aTrackS[Z09->(FieldPos("Z09_IDTRAC"))] := GetSx8Num("Z09","Z09_IDTRAC")
		ConfirmSx8()
		// Garante que nao existe o mesmo Idtrack gravado
		DbSelectArea("Z09")
		Z09->(DbSetOrder(1))
		If !Z09->( DbSeek(aTrackS[FieldPos("Z09_FILIAL")] + aTrackS[FieldPos("Z09_IDTRAC")]) )
			Exit
		End
	End
Else
	aTrackS[FieldPos("Z09_IDTRAC")] :=  Z09->Z09_IDTRAC
EndIf

RecLock("Z09",_lNew)
For nI:=1 To nTCpos
	If nI > Len(aTracks)
		Exit
	EndIF

	If !Empty( aTrackS[nI] )
		DbSelectArea("Z09")
		If !_lNew .And. TrkIsEq( Z09->(FieldGet(nI)), aTrackS[nI])
				cLog += GetSX3Cache(Z09->(FieldName(nI)),"X3_TITULO") + ": Antes: "
				DbSelectArea("Z09")
				DO CASE
					CASE aDbStrZ09[nI, 2] == "C"
						cLog += FieldGet(nI) + " Depois: " + aTrackS[nI] + Chr(13) + Chr(10)
					CASE aDbStrZ09[nI, 2] == "D"
						cLog += DTOC( FieldGet(nI) ) + " Depois: " + DTOC( aTrackS[nI] ) + Chr(13) + Chr(10)
					CASE aDbStrZ09[nI, 2] == "N"
						cPict:= GetSX3Cache(FieldName(nI), "X3_PICTURE")
						DbSelectArea("Z09")
						cLog += Transform( FieldGet(nI), cPict) + " Depois: " + Transform( aTrackS[nI], cPict) + Chr(13) + Chr(10)
					CASE aDbStrZ09[nI, 2] == "M"
						cLog += AllTrim( FieldGet(nI) ) + " Depois: " + AllTrim(aTrackS[nI]) + Chr(13) + Chr(10)	

				END CASE					
		EndIf
		Z09->( FieldPut(nI, aTrackS[nI]) )
	EndIf

Next nI

Z09->(MsUnlock())

// Gravacao do Log
If !_lNew
	aTrackL[CZ11XFILIAL] := aTrackS[Z09->(FieldPos("Z09_FILIAL"))]
	aTrackL[CZ11XORIG  ] := "Z09"
	aTrackL[CZ11XIDTRAC] := aTrackS[Z09->(FieldPos("Z09_IDTRAC"))]
	aTrackL[CZ11XEVENTO] := cEvento
	aTrackL[CZ11XQUEM  ] := cUserName
	aTrackL[DZ11XQUANDO] := date()
	aTrackL[CZ11XHORA  ] := Time()
	aTrackL[NZ11XRECORI] := Z09->(Recno())
	aTrackL[CZ11XSTAMP ] := dtos(date()) + strtran(time(),":","")
	aTrackL[CZ11XEMPORI] := cEmpAnt
	aTrackL[CZ11XFILORI] := aTrackS[Z09->(FieldPos("Z09_FILIAL"))]
	aTrackL[CZ11XOQUE  ] := cLog
	U_TRK006L(aTrackL)
EndIf

Return()

/*/{Protheus.doc} Static Function TrkIsEq()
Validacao para gravacao do log de alteracao do track
@type function
@version 1.0
@author fernando.muta@dothink.com.br
@since 30/07/2025
@param aTrackE, array, param_description
@param cEvento, character, param_description
@return variant, return_description
/*/

Static Function TrkIsEq(xGravado, xNovo)
Local lRet := .F.

If ValType(xGravado) == "C"
    lRet := Lower(Alltrim(xGravado)) != Lower(Alltrim(xNovo))
ElseIf ValType(xGravado) == "D"
    lRet := xGravado != xNovo
ElseIf ValType(xGravado) == "N"
    lRet := xGravado != xNovo
Else
    lRet := xGravado != xNovo
EndIf

Return lRet
