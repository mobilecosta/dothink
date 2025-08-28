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

/*/{Protheus.doc} TRK006SP
Centralizacao dos pontos de de entrada na gravacao do item da nota de saida
@type function
@version 1.0
@author fernando.muta@dothink.com.br
@since 30/07/2025
@param aTrackE, array, param_description
@param cEvento, character, param_description
@return variant, return_description
/*/

User Function TRK006SP(uXParam)
Local aArea		:= GetArea()
Local cParam    := "()"
Local cFuncPE	:= ""
Local uReturn	:= Nil
Default uXParam := Nil
cFuncPE := Upper( ProcName(1) )			// Recebe o nome do ponto de entrada
cFuncPE := StrTran( cFuncPE, "U_", "" )	// Remove o "U_"

If ValType(uXParam) <> "U"
    cParam := "(uXParam)"
EndIf

cFuncPE := "s" + cFuncPE + cParam			// Ajusta para o nome da Static Function correspondente

If !(Empty( cFuncPE ))
    uReturn := &( cFuncPE )
EndIf
RestArea(aArea)
Return(uReturn)





/*/{Protheus.doc} Static Function sMTA440C9()
Ponto de entrada apos geracao da liberacao do pedido
@type function
@version 1.0
@author fernando.muta@dothink.com.br
@since 30/07/2025
@param aTrackE, array, param_description
@param cEvento, character, param_description
@return variant, return_description
/*/

Static Function sMTA440C9()
local xRet      := nil /*
local aTrackS   := Array(66)
local cNomClFo  := ""
local cRespon   := ""
local nValTot   := 0
local dDtPreFat := nil
local aX5T3     := {}
local aArea     := GetArea()
local aAreaSC6  := SC6->(GetArea())
local aAreaSC9  := SC9->(GetArea())
local aAreaSA1  := SA1->(GetArea())
local aAreaSA2  := SA2->(GetArea())

If Type("_cItS9Dp") == "U"
    Public _cItS9Dp  := ""
EndIf
If  !SC9->C9_FILIAL+SC9->C9_PEDIDO+SC9->C9_ITEM $ _cItS9Dp // Para gravar somente 1x
    If Empty(SC9->C9_BLEST) .AND. Empty(SC9->C9_BLCRED) 
        // Busca o Cliente ou Fornecedor
        SC5->(DbSetOrder(1))
        If SC5->(DbSeek(SC9->C9_FILIAL+SC9->C9_PEDIDO))
            If SC5->C5_TIPO $ "DB"
                SA2->(DbSetOrder(1))
                If SA2->(DbSeek(xFilial()+SC9->C9_CLIENTE+SC9->C9_LOJA))
                    cNomClFo  := SA2->A2_NOME       // Nome Cliente  C [60 ][ 0 ] 17
                EndIf
            else
                SA1->(DbSetOrder(1))
                If SA1->(DbSeek(xFilial()+SC9->C9_CLIENTE+SC9->C9_LOJA))
                    cNomClFo  := SA1->A1_NOME       // Nome Cliente  C [60 ][ 0 ] 17
                EndIf
            EndIf
        EndIf
        
	    //-- Define o BU
	    aX5T3 := FWGetSX5 ( "T3", SC5->C5_XATIVI1)
	
	    cRespon := Posicione("SA3", 1, xFilial("SA3") + SC5->C5_VEND1, "A3_NOME")        
        
        SC6->(DbSetOrder(1))
        If SC6->(DbSeek(xFilial()+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO ))
            nValTot := SC6->C6_VALOR
        EndIf
        
        

        // Alimentacao das variaveis para gravacao
        aTrackS[CZ09XFILIAL]  := SC9->C9_FILIAL	  // Filial        C [ 2 ][ 0 ] 01
		If !Empty(aX5T3)
		    aTrackS[CZ09XBU]      := aX5T3[1][4]
		EndIf
		aTrackS[CZ09XRESPON]  := cRespon 	      // Reponsavel    C [30 ][ 0 ] 04        
        aTrackS[CZ09XNUMPV ]  := SC9->C9_PEDIDO	  // Pedido Venda  C [ 6 ][ 0 ] 05
        aTrackS[CZ09XITEMPV]  := SC9->C9_ITEM     // Item PV       C [ 2 ][ 0 ] 06
        aTrackS[CZ09XCLIENT]  := SC9->C9_CLIENTE // Cliente       C [ 6 ][ 0 ] 15
        aTrackS[CZ09XLOJA  ]  := SC9->C9_LOJA    // Loja Cliente  C [ 2 ][ 0 ] 16
        aTrackS[CZ09XNOMECL]  := cNomClFo       // Nome Cliente ou fornecedor  C [60 ][ 0 ] 17
        aTrackS[NZ09XTOTAL ]  := nValTot             // Vlr. Total    N [16 ][ 2 ] 18
        aTrackS[DZ09XDTEMPV] := Date()	          // Emissao PV    D [ 8 ][ 0 ] 07
        aTrackS[CZ09XHREMPV] := Time()           // Hr.Emiss.PV   C [ 5 ][ 0 ] 08
        // Gravacao do Tracker
        u_TRK006S(aTrackS,"Liberação do pedido")
        _cItS9Dp += SC9->C9_FILIAL+SC9->C9_PEDIDO+SC9->C9_ITEM + "|"
    EndIf
EndIf    


// Restaurando ponteiros
SC6->(RestArea(aAreaSC6))
SC9->(RestArea(aAreaSC9))
SC6->(RestArea(aAreaSA1))
SA2->(RestArea(aAreaSA2))
RestArea(aArea)
*/
Return xRet


/*/{Protheus.doc} Static Function sMSD2460()
Ponto de entrada na gravacao da nota fiscal de saida
@type function
@version 1.0
@author fernando.muta@dothink.com.br
@since 30/07/2025
@param aTrackE, array, param_description
@param cEvento, character, param_description
@return variant, return_description
/*/

Static Function sMSD2460()
local xRet    := Nil
local aArea   := GetArea()
local aTrackS := {}

DbSelectArea("Z09")
aTrackS := Array( Len( Z09->( DbStruct() ) ) )

aTrackS[ Z09->(FieldPos("Z09_FILIAL"))] := SD2->D2_FILIAL	  // Filial        C [ 2 ][ 0 ] 01
aTrackS[ Z09->(FieldPos("Z09_NUMPV")) ] := SD2->D2_PEDIDO	  // Pedido Venda  C [ 6 ][ 0 ] 05
aTrackS[ Z09->(FieldPos("Z09_ITEMPV"))] := SD2->D2_ITEMPV     // Item PV       C [ 2 ][ 0 ] 06
aTrackS[ Z09->(FieldPos("Z09_NF"))    ] := SD2->D2_DOC	      // Nota Fiscal   C [ 9 ][ 0 ] 11
aTrackS[ Z09->(FieldPos("Z09_SERIE")) ] := SD2->D2_SERIE	  // Serie NF      C [ 3 ][ 0 ] 12
aTrackS[ Z09->(FieldPos("Z09_DTEMNF"))] := SD2->D2_EMISSAO    // Emissao NF    D [ 8 ][ 0 ] 13
aTrackS[ Z09->(FieldPos("Z09_HREMNF"))] := SF2->F2_HORA	      // Hr.Emiss.NF   C [ 5 ][ 0 ] 14
u_TRK006S(aTrackS,"Faturamento")
RestArea(aArea)
Return xRet



/*/{Protheus.doc} M410PVNF
Ponto de entrada para validacao, executado antes da rotina de geracao de NF's.
Verifico o tipo do pedido e se tem validacao fiscal
@type function
@version 1.0 
@author erike.yuri@dothink.com.br
@since 12/8/2025
@return logical, Indica se prossegue ou nao com o processamento para a geracao da NF
/*/
Static Function sM410PVNF(nRecSC5)
    Local lRet     := .T.
    Local cMsgTit  := ""
    Local cMensag  := ""
    Local cSolucao := ""
    Local aArea    := GetArea()

    DbSelectArea("SC5")
    SC5->( DbGoto(nRecSC5) )
    
    //-- Avalia somente se o pedido possui itens que atualiza estoque
    If u_Trk006ME(SC5->C5_NUM)
        //-- Verifica se existe bloqueio fiscal
        If SC5->C5_XBLFIS <> "2" 
            lRet     := .F.
            cMsgTit  := "Bloqueio Fiscal"
            cMensag  := "O pedido ["+ SC5->C5_NUM +"] nao foi liberado na validacao fiscal."
            cSolucao := "Verificar com o departamento fiscal o motivo."
        EndIf

        If SC5->C5_X4SSTAT == "A"
            lRet     := .F.
            cMsgTit  := "Em validacao fisica"
            cMensag  := "O pedido ["+ SC5->C5_NUM +"] esta em validacao fisica."
            cSolucao := "Aguarde a finalizacao do processo de validacao fisica."
        EndIf

        If !lRet
            Help(NIL, NIL, cMsgTit, NIL, cMensag, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})
        EndIf

    EndIf

    RestArea(aArea)
Return lRet


/*/{Protheus.doc} Trk006ME
Verifica se o produto movimenta estoque
@type function
@version 1.0  
@author erike.yuri@dothink.com.br
@since 12/8/2025
@param cPedido, character, codigo do pedido de vendas
@return logical, Retorna se o pedido possui produtos que atualizam estoque
/*/
User Function Trk006ME(cPedido)
    Local lRet  := .T.
    Local cQuery:= ""
    Local aArea := GetArea()

    cQuery := "SELECT COUNT(1) AS OK FROM " + RetSQLName("SC6") + " SC6 "
    cQuery += " INNER JOIN " + RetSQLName("SF4") + " SF4 ON SF4.F4_FILIAL = '" + xFilial("SF4") + "' AND SF4.F4_CODIGO= SC6.C6_TES AND SF4.F4_TIPO = 'S' AND SF4.F4_ESTOQUE = 'S' AND SF4.D_E_L_E_T_= ' ' "
    cQuery += " WHERE SC6.C6_FILIAL = '" + xFilial("SC6") + "' AND SC6.D_E_L_E_T_= ' ' AND C6_NUM = '" + cPedido + "' "

    lRet := MpSysExecScalar(cQuery, "OK") > 0
    RestArea(aArea)

Return lRet

/*/{Protheus.doc} Trk006CO
Funcao utilizada nas cores das legendas
@type function
@version 1.0
@author erike.yuri@dothink.com.br
@since 13/18/2025
@return logical, Retorno da analise da legenda chamada
/*/
User Function Trk006CO(nOpc, cLeg)
    local aArea:= GetArea()
    local aASC5:= {}
    local lRet := .F.

    //-- Funcao M461COR
    If nOpc == 1
        aASC5 := SC5->( GetArea() )
        aASC6 := SC6->( GetArea() )

        DbSelectArea("SC5")
        SC5->( DbSetOrder(1) )

        If SC5->( DbSeek(SC9->C9_FILIAL + SC9->C9_PEDIDO) )

            DO CASE
                CASE cLeg == "VLD_FISCAL"
                    lRet := SC5->( C5_XBLQINI <> 'S' .And. (C5_XBLRENT == '2' .Or. C5_XBLRENT = ' ') .and. C5_X4SSTAT == '9' .and. Empty(C5_BLQ) .and. Empty(C5_NOTA))
                CASE cLeg == "VLD_FISICA"
                    lRet := SC5->( C5_XBLQINI <> 'S' .And. (C5_XBLRENT == '2' .Or. C5_XBLRENT = ' ') .and. C5_X4SSTAT == 'A' .and. Empty(C5_BLQ) .and. Empty(C5_NOTA))
                CASE cLeg == "AGENDAMENTO"
                    lRet := SC5->( C5_XBLQINI <> 'S' .And. (C5_XBLRENT == '2' .Or. C5_XBLRENT = ' ') .and. C5_X4SSTAT == '8' .and. Empty(C5_BLQ) .and. Empty(C5_NOTA))    
                CASE cLeg == "SEPARACAO"
                    lRet := SC5->( C5_XBLQINI <> 'S' .And. (C5_XBLRENT == '2' .Or. C5_XBLRENT = ' ') .and. C5_X4SSTAT == '1' .and. Empty(C5_BLQ) .and. Empty(C5_NOTA))     
                CASE cLeg == "FATURAMENTO"
                    lRet := SC5->( C5_XBLQINI <> 'S' .And. (C5_XBLRENT == '2' .Or. C5_XBLRENT = ' ') .and. C5_X4SSTAT == '2' .and. Empty(C5_BLQ))  
                CASE cLeg == "EMBARQUE"
                    lRet := SC5->( C5_XBLQINI <> 'S' .And. (C5_XBLRENT == '2' .Or. C5_XBLRENT = ' ') .and. C5_X4SSTAT == 'B' .and. Empty(C5_BLQ)) 
            END CASE
        EndIf

        RestArea(aASC5)
    EndIf

    RestArea(aArea)
Return lRet


/*/{Protheus.doc} sMA410Leg
Ponto de entrada para Legenda no pedido de vendas
@type function
@version 1.0 
@author fernando.muta@dothink.com.br
@since 12/8/2025
@return array, Array com a regra da Legenda
/*/
Static Function sMA410LEG(aCores)

    AAdd(aCores,{"br_branco.bmp"    , "Em Validação Fiscal"})  
    AAdd(aCores,{"br_amarelo.bmp"   , "Em Validação Física"})   
    AAdd(aCores,{"br_laranja.bmp"   , "Em Agendamento"     })       
    AAdd(aCores,{"br_marron.bmp"    , "Em Separação"       })
    AAdd(aCores,{"br_azul.bmp"      , "Em Faturamento"     })
    AAdd(aCores,{"br_verde.bmp"     , "Em Embarque"        })
    
Return aCores

/*/{Protheus.doc} sMA410COR
Ponto de entrada para Legenda no 
@type function
@version 1.0 
@author fernando.muta@dothink.com.br
@since 12/8/2025
@return array, Array com a regra da Legenda
/*/
Static Function sMA410COR(aCores)
    Local aRetCor := {}
    Local nI

    /*
        C5_X4SSTAT
        1 = Em Separação
        2 = Em Faturamento
        3 = Em Coleta
        4 = Em Transito
        5 = Pedido Entregue
        6 = Em Fracionamento
        8 = Em Agendamento 
        9 = Em Validação Fiscal 
        A = Validação Física
        B = Em Embarque    
    */
    //-- Em Validação Fiscal
    Aadd(aRetCor,{"C5_XBLQINI <> 'S' .and. (C5_XBLRENT == '2' .Or. C5_XBLRENT = ' ')  .and. C5_X4SSTAT == '9' .and. Empty(C5_BLQ) ", "br_branco.bmp", "Em Validação Fiscal"})   

    //-- Em Validação Fisica
    Aadd(aRetCor,{"C5_XBLQINI <> 'S' .and. (C5_XBLRENT == '2' .Or. C5_XBLRENT = ' ')  .and. C5_X4SSTAT == 'A' .and. Empty(C5_BLQ)  ", "br_amarelo.bmp", "Em Validação Física"}) 

    //-- Em Agendamento
    Aadd(aRetCor,{"C5_XBLQINI <> 'S' .and. (C5_XBLRENT == '2' .Or. C5_XBLRENT = ' ')  .and. C5_X4SSTAT == '8' .and. Empty(C5_BLQ) ", "br_laranja.bmp"        , "Em Agendamento"}) 

    //-- Em Separacao
    Aadd(aRetCor,{"C5_XBLQINI <> 'S' .and. (C5_XBLRENT == '2' .Or. C5_XBLRENT = ' ')  .and. C5_X4SSTAT == '1'  .and. Empty(C5_BLQ) ", "br_marron.bmp"     , "Em Separação"}) 

    //-- Em Faturamento
    Aadd(aRetCor,{"C5_XBLQINI <> 'S' .and. (C5_XBLRENT == '2' .Or. C5_XBLRENT = ' ')  .and. C5_X4SSTAT == '2'  .and. Empty(C5_BLQ) ", "br_azul.bmp" , "Em Faturamento"})

    //-- Em Embarque
    Aadd(aRetCor,{"C5_XBLQINI <> 'S' .and. (C5_XBLRENT == '2' .Or. C5_XBLRENT = ' ')  .and. C5_X4SSTAT == 'B'  .and. Empty(C5_BLQ) ", "br_verde.bmp"  , "Em Embarque"})

    For nI:=1 To Len(aCores)
        aadd(aRetCor, aCores[nI] )
    Next nI

Return aRetCor

/*/{Protheus.doc} sMA440COR
Ponto de entrada para Legenda no 
@type function
@version 1.0 
@author fernando.muta@dothink.com.br
@since 12/8/2025
@return array, Array com a regra da Legenda
/*/
Static Function sMA440COR(aCores)
    aCores := sMA410COR(aCores)
Return aCores

/*/{Protheus.doc} sM461LEG
Ponto de entrada para Legenda no 
@type function
@version 1.0 
@author fernando.muta@dothink.com.br
@since 12/8/2025
@return array, Array com a regra da Legenda
/*/
Static Function sM461LEG(aCores)

    AAdd(aCores,{"br_branco.bmp"    , "Em Validação Fiscal"})  
    AAdd(aCores,{"br_amarelo.bmp"   , "Em Validação Física"})   
    AAdd(aCores,{"br_laranja.bmp"   , "Em Agendamento"     })       
    AAdd(aCores,{"br_marron.bmp"    , "Em Separação"       })
    AAdd(aCores,{"br_azul.bmp"      , "Em Faturamento"     })
    AAdd(aCores,{"br_verde.bmp"     , "Em Embarque"        })

Return aCores

/*/{Protheus.doc} sM461COR
Ponto de entrada para Legenda no 
@version 1.0 
@author fernando.muta@dothink.com.br
@since 12/8/2025
@return array, Array com a regra da Legenda
/*/
Static Function sM461COR(aCores)
    Local aRetCor := {}
    Local nI
//aCores := GetCorLeg(aCores)[1]

    /*
        C5_X4SSTAT
        1 = Em Separação
        2 = Em Faturamento
        3 = Em Coleta
        4 = Em Transito
        5 = Pedido Entregue
        6 = Em Fracionamento
        8 = Em Agendamento 
        9 = Em Validação Fiscal 
        A = Validação Física
        B = Em Embarque    
    */

    //-- Em Validação Fiscal
    Aadd(aRetCor,{"U_Trk006CO(1, 'VLD_FISCAL')"  , "br_branco.bmp"  , "Em Validação Fiscal"})   

    //-- Em Validação Fisica
    Aadd(aRetCor,{"U_Trk006CO(1, 'VLD_FISICA')"  , "br_amarelo.bmp" , "Em Validação Física"}) 

    //-- Em Agendamento
    Aadd(aRetCor,{"U_Trk006CO(1, 'AGENDAMENTO')" , "br_laranja.bmp" , "Em Agendamento"}) 

    //-- Em Separacao
    Aadd(aRetCor,{"U_Trk006CO(1, 'SEPARACAO')"   , "br_marron.bmp"  , "Em Separação"}) 

    //-- Em Faturamento
    Aadd(aRetCor,{"U_Trk006CO(1, 'FATURAMENTO')" , "br_azul.bmp"    , "Em Faturamento"})

    //-- Em Embarque
    Aadd(aRetCor,{"U_Trk006CO(1, 'EMBARQUE')"    , "br_verde.bmp"   , "Em Embarque"})

    For nI:=1 To Len(aCores)
        aadd(aRetCor, aCores[nI] )
    Next nI

Return aRetCor

/*/{Protheus.doc} GetCorLeg
Funcao centralizada que retorna cores de legenda
@type function
@version 1.0 
@author fernando.muta@dothink.com.br
@since 12/8/2025
@return array, [1]=Cores e regras [2]=Legenda
/*/
Static Function GetCorLeg(aCores)
local aRet := {aCores, aCores}

// aRet[1] = Cor
If "MATA460A" $ UPPER(FunName())
    _cSTAT := "GetAdvFVal( 'SC5', 'C5_X4SSTAT', SC9->C9_FILIAL + SC9->C9_PEDIDO, 1 )"
Else
    _cSTAT := "C5_X4SSTAT"
EndIf

aadd(aRet[2], {"br_marron.bmp" , "Em Separação"})
aadd(aRet[2], {"br_azul.bmp"   , "Em Faturamento"})
aadd(aRet[2], {"BR_PRETO_0"    , "Em Fracionamento"})
aadd(aRet[2], {"br_laranja.bmp", "Em Agendamento"})
aadd(aRet[2], {"br_branco.bmp" , "Em Validação Fiscal"})
aadd(aRet[2], {"br_amarelo.bmp", "Validação Física"})
aadd(aRet[2], {"BR_VERMELHO"   , "Em Embarque"})

AAdd(aRet[1],{_cSTAT+" == '1'",aRet[2][01][1]    , aRet[2][01][1]})
AAdd(aRet[1],{_cSTAT+" == '2'",aRet[2][02][1]    , aRet[2][02][1]})
AAdd(aRet[1],{_cSTAT+" == '3'",aRet[2][03][1]    , aRet[2][03][1]})
AAdd(aRet[1],{_cSTAT+" == '4'",aRet[2][04][1]    , aRet[2][04][1]})
AAdd(aRet[1],{_cSTAT+" == '5'",aRet[2][05][1]    , aRet[2][05][1]})
AAdd(aRet[1],{_cSTAT+" == '6'",aRet[2][06][1]    , aRet[2][06][1]})
AAdd(aRet[1],{_cSTAT+" == '8'",aRet[2][07][1]    , aRet[2][07][1]})
AAdd(aRet[1],{_cSTAT+" == '9'",aRet[2][08][1]    , aRet[2][08][1]})
AAdd(aRet[1],{_cSTAT+" == 'A'",aRet[2][09][1]    , aRet[2][09][1]})
AAdd(aRet[1],{_cSTAT+" == 'B'",aRet[2][10][1]    , aRet[2][10][1]})


Return aClone(aRet)


Static Function SM460MARK()
    local lRet := .T.
Return lRet


Static Function SM460FIM(aParam)
    Local aArea     := GetArea()
    Local aSF2      := SF2->( GetArea() )
    Local aSD2      := SD2->( GetArea() )
    Local aSC5      := SC5->( GetArea() )
    Local cNumNFS   := aParam[1] // Número da NF
    Local cSerieNFS := aParam[2] // Série da NF
    Local cClieFor  := aParam[3] // Cliente/fornecedor da NF
    Local cLoja     := aParam[4] // Loja da NF
    Local aTrackS   := {}
    Local nTamZ09   := 0
    Local lAtuZ09   := .F.
     

    DbSelectAre("Z09")
    nTamZ09 := Len( Z09->( DbStruct() ) )
    
    //-- Se a SF2 estiver desposicionada, posiciono novamente
    If !(cNumNFS == SF2->F2_DOC .And. cSerieNFS == SF2->F2_SERIE .And. cClieFor == SF2->F2_CLIENTE .And. cLoja == SF2->F2_LOJA)
        SF2->( DbSetOrder(1) )
        SF2->( DbSeek(xFilial() + cNumNFS + cSerieNFS + cClieFor + cLoja) )
    EndIf

    If !(SF2->F2_TIPO == "N")
        RestArea(aSF2)
        RestArea(aArea)
        Return
    EndIf

    SD2->( DbSetOrder(3) )
    If SD2->( DbSeek(xFilial() + SF2->F2_DOC + SF2->F2_SERIE) ) .And. u_Trk006ME(SD2->D2_PEDIDO)
        lAtuZ09 := .T.

        DbSelectArea("SC5")
        SC5->( DbSetOrder(1) )
        If SC5->( DbSeek(xFilial() + SD2->D2_PEDIDO ) )

            RecLock("SC5", .F.)
            SC5->C5_X4SSTAT := "B" //-- Em Embarque
            SC5->( MsUnLock() )

            dbSelectArea("CB7")
            CB7->(dbSetOrder(2) )
            If CB7->(dbSeek(xFilial() + SC5->C5_NUM ) )
                RecLock("SC5", .F.)
                SC5->C5_X4SSTAT := "2"
                SC5->( MsUnLock() )
            EndIf
        EndIf

    Endif


    While lAtuZ09 .And. SD2->( !Eof() ) .And. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == SF2->( F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA) 

        aTrackS := Array( nTamZ09 )

        //-- Atualiza Z09
        DbSelectAre("Z09")
        aTrackS[FieldPos("Z09_FILIAL")] := xFilial("SF2")       // Filial
        aTrackS[FieldPos("Z09_NUMPV") ] := SD2->D2_PEDIDO       // Pedido Venda  C [ 6 ][ 0 ] 05
        aTrackS[FieldPos("Z09_ITEMPV")] := SD2->D2_ITEMPV       // Item PV       C [ 2 ][ 0 ] 06
        aTrackS[FieldPos("Z09_STATUS")] := "7"                  // Em Embarque
        aTrackS[FieldPos("Z09_NF")    ] := SD2->D2_DOC          // Nota Fiscal
        aTrackS[FieldPos("Z09_SERIE") ] := SD2->D2_SERIE        // Serie Nota Fiscal
        aTrackS[FieldPos("Z09_DTEMNF")] := SD2->D2_EMISSAO      // Emissao Nota
        aTrackS[FieldPos("Z09_HREMNF")] := SF2->F2_HORA         // Hora Emissao
        aTrackS[FieldPos("Z09_TOTAL") ] := SF2->(F2_VALBRUT + F2_VALIPI)
        u_TRK006S(aTrackS,"Em Embarque")

        SD2->( DbSkip() )
    End


    RestArea(aSC5)
    RestArea(aSD2)
    RestArea(aSF2)
    RestArea(aArea)

Return

Static Function sM410AGRV(aParam)
    Local nOpcao    := aParam[1]

    If nOpcao == 1
        ChkCliRet()
    ElseIf nOpcao == 2
        u_Frete()
    EndIf   
Return 


Static Function ChkCliRet()
    Local nContI    := 0
    Local nTotItens := 0
    Local nLocal    := 0
    Local lUdLog    := .F.
    Local aArea     := GetArea() //Armazena o ambiente ativo para restaurar ao fim do processo

    If FWCodFil() == "04" //cliente=010127 Loja=01
        nLocal      := aScan(aHeader, {|x| Alltrim(x[2]) == "C6_LOCAL"})
        nTotItens   := Len(aCols)

        For nContI := 1 To nTotItens
            If aCols[nContI][nLocal] == "19"
                lUdLog := .T.
                Exit
            EndIf
        Next nContI


        If lUdLog
            //--015268
            //Conout("Entrou Tem armazém 19")
        EndIf

    EndIf
    
    //-- Restaura o ambiente ativo no início da chamada
    RestArea(aArea)         
Return

