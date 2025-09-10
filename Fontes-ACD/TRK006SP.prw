#include "totvs.ch"
#include "topconn.ch"


/*/{Protheus.doc} TRK006SP
Centralizacao dos pontos de de entrada na gravacao do item da nota de saida
@type function
@version 1.0
@author fernando.muta@dothink.com.br
@since 30/07/2025
@param uXParam, array, Parametro indefinido pois dependera da funcao chamadora
@return variant, retorno indefinido pois dependera da funcao chamadora
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

cFuncPE := "s" + cFuncPE + cParam		// Ajusta para o nome da Static Function correspondente

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
/*/
Static Function sMTA440C9(lRet)
local xRet      := lRet
/*
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
@return variant, Nenhum
/*/
Static Function sMSD2460()
local xRet    := Nil
local aArea   := GetArea()
local aTrackS := {}

DbSelectArea("Z09")
Z09->( DbSetOrder(3) )
If Z09->( DbSeek(xFilial() + SD2->D2_FILIAL + SD2->D2_PEDIDO) )
    aTrackS := Array( Len( Z09->( DbStruct() ) ) )

    aTrackS[ Z09->(FieldPos("Z09_FILIAL"))] := SD2->D2_FILIAL	  // Filial        C [ 2 ][ 0 ] 01
    aTrackS[ Z09->(FieldPos("Z09_NUMPV")) ] := SD2->D2_PEDIDO	  // Pedido Venda  C [ 6 ][ 0 ] 05
    aTrackS[ Z09->(FieldPos("Z09_ITEMPV"))] := SD2->D2_ITEMPV     // Item PV       C [ 2 ][ 0 ] 06
    aTrackS[ Z09->(FieldPos("Z09_NF"))    ] := SD2->D2_DOC	      // Nota Fiscal   C [ 9 ][ 0 ] 11
    aTrackS[ Z09->(FieldPos("Z09_SERIE")) ] := SD2->D2_SERIE	  // Serie NF      C [ 3 ][ 0 ] 12
    aTrackS[ Z09->(FieldPos("Z09_DTEMNF"))] := SD2->D2_EMISSAO    // Emissao NF    D [ 8 ][ 0 ] 13
    aTrackS[ Z09->(FieldPos("Z09_HREMNF"))] := SF2->F2_HORA	      // Hr.Emiss.NF   C [ 5 ][ 0 ] 14

    u_TRK006S(aTrackS,"Faturamento")
EndIf

RestArea(aArea)
Return xRet



/*/{Protheus.doc} M410PVNF
Ponto de entrada para validacao, executado antes da rotina de geracao de NF's.
Verifico o tipo do pedido e se tem validacao fiscal
@type function
@version 1.0 
@author erike.yuri@dothink.com.br
@since 12/8/2025
@param nRecSC5, numeric, Recno no SC5
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

        DbSelectArea("Z09")
        Z09->( DbSetOrder(3) )
        If Z09->( DbSeek(SC5->C5_FILIAL + SC5->C5_NUM) )
            If Z09->Z09_ACAOCS == "2"
                lRet     := .F.
                cMsgTit  := "Aguardando acao CS"
                cMensag  := "O pedido ["+ SC5->C5_NUM +"] esta em aguardando acao do CS."
                cSolucao := "Aguarde a analise do processo de acao do CS."
            ElseIf Z09->Z09_ACAOCS == "4"
                lRet     := .F.
                cMsgTit  := "Cancelamento CS"
                cMensag  := "O pedido ["+ SC5->C5_NUM +"] esta em cancelamento, conforme acao do CS."
                cSolucao := "Este pedido nao podera seguir, pois o CS solicitou cancelamento."
            EndIf
        EndIf

        //-- Verifica se existe bloqueio fiscal
        If lRet .And. SC5->C5_XBLFIS <> "2" 
            lRet     := .F.
            cMsgTit  := "Bloqueio Fiscal"
            cMensag  := "O pedido ["+ SC5->C5_NUM +"] nao foi liberado na validacao fiscal."
            cSolucao := "Verificar com o departamento fiscal o motivo."
        EndIf

        If lRet .And. SC5->C5_X4SSTAT == "A"
            lRet     := .F.
            cMsgTit  := "Em validacao fisica"
            cMensag  := "O pedido ["+ SC5->C5_NUM +"] esta em validacao fisica."
            cSolucao := "Aguarde a finalizacao do processo de validacao fisica."
        EndIf

        If lRet .And. SC5->C5_X4SSTAT == "8"
            lRet     := .F.
            cMsgTit  := "Em Agendamento"
            cMensag  := "O pedido ["+ SC5->C5_NUM +"] esta em agendamento."
            cSolucao := "Aguarde a finalizacao do processo de agendamento."
        EndIf        

        If !lRet
            Help(NIL, NIL, cMsgTit, NIL, cMensag, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})
        EndIf

        If lRet
            AcdPVxOsep()
        EndIf
    EndIf

    RestArea(aArea)
Return lRet


/*/{Protheus.doc} Trk006ME
Verifica se o pedido tem produto que movimenta estoque
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
    Aadd(aRetCor,{"C5_XBLQINI <> 'S' .and. (C5_XBLRENT == '2' .Or. C5_XBLRENT = ' ')  .and. C5_X4SSTAT == '9' .and. Empty(C5_BLQ) " , "br_branco.bmp"  , "Em Validação Fiscal"})   

    //-- Em Validação Fisica
    Aadd(aRetCor,{"C5_XBLQINI <> 'S' .and. (C5_XBLRENT == '2' .Or. C5_XBLRENT = ' ')  .and. C5_X4SSTAT == 'A' .and. Empty(C5_BLQ)  ", "br_amarelo.bmp" , "Em Validação Física"}) 

    //-- Em Agendamento
    Aadd(aRetCor,{"C5_XBLQINI <> 'S' .and. (C5_XBLRENT == '2' .Or. C5_XBLRENT = ' ')  .and. C5_X4SSTAT == '8' .and. Empty(C5_BLQ) " , "br_laranja.bmp" , "Em Agendamento"}) 

    //-- Em Separacao
    Aadd(aRetCor,{"C5_XBLQINI <> 'S' .and. (C5_XBLRENT == '2' .Or. C5_XBLRENT = ' ')  .and. C5_X4SSTAT == '1'  .and. Empty(C5_BLQ) ", "br_marron.bmp"  , "Em Separação"}) 

    //-- Em Faturamento
    Aadd(aRetCor,{"C5_XBLQINI <> 'S' .and. (C5_XBLRENT == '2' .Or. C5_XBLRENT = ' ')  .and. C5_X4SSTAT == '2'  .and. Empty(C5_BLQ) ", "br_azul.bmp"    , "Em Faturamento"})

    //-- Em Embarque
    Aadd(aRetCor,{"C5_XBLQINI <> 'S' .and. (C5_XBLRENT == '2' .Or. C5_XBLRENT = ' ')  .and. C5_X4SSTAT == 'B'  .and. Empty(C5_BLQ) ", "br_verde.bmp"   , "Em Embarque"})

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


Static Function SM460MARK(aParam)
    Local cMarca   := aParam[1]
    Local lInverte := aParam[2]
    Local lRet     := .T.
    Local cMsgTit  := ""
    Local cMensag  := ""
    Local cSolucao := ""
    Local aArea    := GetArea()

     If lRet
        DbSelectArea("Z09")
        Z09->( DbSetOrder(3) )
        If Z09->( DbSeek(SC9->C9_FILIAL + SC9->C9_PEDIDO) )
            If Z09->Z09_ACAOCS == "2"
                lRet     := .F.
                cMsgTit  := "Aguardando acao CS"
                cMensag  := "O pedido ["+ SC9->C9_PEDIDO +"] esta em aguardando acao do CS."
                cSolucao := "Aguarde a analise do processo de acao do CS."
            ElseIf Z09->Z09_ACAOCS == "4"
                lRet     := .F.
                cMsgTit  := "Cancelamento CS"
                cMensag  := "O pedido ["+ SC9->C9_PEDIDO +"] esta em cancelamento, conforme acao do CS."
                cSolucao := "Este pedido nao podera seguir, pois o CS solicitou cancelamento."
            EndIf
        EndIf

        If !lRet
            Help(NIL, NIL, cMsgTit, NIL, cMensag, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})
        EndIf

    EndIf

    If lRet
        //-- Essa chamda serve para fazer o preenchimento do campo C9_ORDSEP de todas as OS estao vazias e com OS existente
        AcdGrvOsep(1)

        //-- Essa chamda serva para fazer a lipeza do campo C9_ORDSEP para a NF que esta sendo faturada
        AcdNFxOsep(cMarca, lInverte)
    EndIf

    RestArea(aArea)
Return lRet


Static Function SM460FIM(aParam)
    Local aArea     := GetArea()
    Local aSF2      := SF2->( GetArea() )
    Local aSD2      := SD2->( GetArea() )
    Local aSC5      := SC5->( GetArea() )
    Local aCB7      := CB7->( GetArea() )
    Local cNumNFS   := aParam[1] // Número da NF
    Local cSerieNFS := aParam[2] // Série da NF
    Local cClieFor  := aParam[3] // Cliente/fornecedor da NF
    Local cLoja     := aParam[4] // Loja da NF
    Local cChave    := ""
    Local aTrackS   := {}
    Local nTamZ09   := 0
    Local lAtuZ09   := .F.
    Local aStatus   := Array(2)
     

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

        dbSelectArea("CB7")
        CB7->(dbsetorder(2))

        If CB7->(dbSeek(xFilial("CB7") + SD2->D2_PEDIDO)) .And. ("*99" $ CB7->CB7_TIPEXP)
            If CB7->CB7_STATUS >= "2"
                aStatus[1] := "B" //-- Em Embarque
                aStatus[2] := "7" //-- Em Embarque
            Else
                aStatus[1] := "1" //-- Em Separacao
                aStatus[2] := "5" //-- Em Separacao
            EndIf
        EndIf

        aStatus[1] := IIF(Empty(aStatus[1]), "B", aStatus[1]) 
        aStatus[2] := IIF(Empty(aStatus[2]), "7", aStatus[2])

        DbSelectArea("SC5")
        SC5->( DbSetOrder(1) )

        If SC5->( DbSeek(xFilial() + SD2->D2_PEDIDO ) )
            RecLock("SC5", .F.)
            SC5->C5_X4SSTAT := aStatus[1]
            SC5->( MsUnLock() )
        EndIf

    Endif


    While lAtuZ09 .And. SD2->( !Eof() ) .And. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == SF2->( F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA) 

        aTrackS := Array( nTamZ09 )
        cChave  := SD2->D2_FILIAL + SD2->D2_DOC + SD2->D2_SERIE 
        //-- Atualiza Z09
        DbSelectAre("Z09")
        aTrackS[FieldPos("Z09_FILIAL")] := xFilial("SF2")       // Filial
        aTrackS[FieldPos("Z09_NUMPV") ] := SD2->D2_PEDIDO       // Pedido Venda  C [ 6 ][ 0 ] 05
        aTrackS[FieldPos("Z09_ITEMPV")] := SD2->D2_ITEMPV       // Item PV       C [ 2 ][ 0 ] 06
        aTrackS[FieldPos("Z09_STATUS")] := aStatus[2]           // Em Embarque
        aTrackS[FieldPos("Z09_NF")    ] := SD2->D2_DOC          // Nota Fiscal
        aTrackS[FieldPos("Z09_SERIE") ] := SD2->D2_SERIE        // Serie Nota Fiscal
        aTrackS[FieldPos("Z09_DTEMNF")] := SD2->D2_EMISSAO      // Emissao Nota
        aTrackS[FieldPos("Z09_HREMNF")] := SF2->F2_HORA         // Hora Emissao
        aTrackS[FieldPos("Z09_TOTAL") ] := SF2->(F2_VALBRUT + F2_VALIPI)
        u_TRK006S(aTrackS,"Faturamento (Fim)")

        SD2->( DbSkip() )
    End

    AcdGrvOsep(2, {cNumNFS, cSerieNFS, cClieFor, cLoja})

    //-- Verifica se tem remessa
    If !Empty(cChave)
        DbSelectArea("Z09")
        Z09->( DbSetOrder(2) )
        If Z09->( DbSeek(cChave) ) .And. !Empty(Z09->Z09_PVREME) .And. Z09->Z09_NUMPV <> Z09->Z09_PVREME
            lAtuZ09 := .F.
            DbSelectArea("SC5")
            SC5->( DbSetOrder(1) )
            If SC5->( DbSeek(xFilial() + Z09->Z09_PVREME ) )
                RecLock("SC5", .F.)
                SC5->C5_X4SSTAT := aStatus[1]
                SC5->( MsUnLock() )

                SF2->( DbSetOrder(1) )
                SF2->( DbSeek(xFilial() + SC5->C5_NOTA + SC5->C5_SERIE) )


                //-- Atualiza Tracking
                DbSelectArea("SD2")
                SD2->( DbSetOrder(3) )
                SD2->( DbSeek(xFilial() + SC5->C5_NOTA + SC5->C5_SERIE) )
                While SD2->( !Eof() ) .And. SD2->(D2_FILIAL+D2_DOC+D2_SERIE) == SC5->(C5_FILIAL + C5_NOTA + C5_SERIE)
                    aTrackS := Array( nTamZ09 )
                    //-- Atualiza Z09
                    DbSelectAre("Z09")
                    aTrackS[FieldPos("Z09_FILIAL")] := xFilial("SF2")       // Filial
                    aTrackS[FieldPos("Z09_NUMPV") ] := SD2->D2_PEDIDO       // Pedido Venda  C [ 6 ][ 0 ] 05
                    aTrackS[FieldPos("Z09_ITEMPV")] := SD2->D2_ITEMPV       // Item PV       C [ 2 ][ 0 ] 06
                    aTrackS[FieldPos("Z09_STATUS")] := aStatus[2]           // Em Embarque
                    aTrackS[FieldPos("Z09_NF")    ] := SD2->D2_DOC          // Nota Fiscal
                    aTrackS[FieldPos("Z09_SERIE") ] := SD2->D2_SERIE        // Serie Nota Fiscal
                    aTrackS[FieldPos("Z09_DTEMNF")] := SD2->D2_EMISSAO      // Emissao Nota
                    aTrackS[FieldPos("Z09_HREMNF")] := SF2->F2_HORA         // Hora Emissao
                    aTrackS[FieldPos("Z09_TOTAL") ] := SF2->(F2_VALBRUT + F2_VALIPI)
                    u_TRK006S(aTrackS,"Faturamento (Fim)")
               
                    SD2->( DbSkip() )
                End

            EndIf
        EndIf
    EndIf

    RestArea(aCB7)
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


/*/{Protheus.doc} FISENVNFE
Executado logo após a transmissão da NF-e
@type function
@author erike.yuri@dothink.com.br
@since 20250829
/*/
Static Function sFISENVNFE(ParamIXB)
    local aArea := GetArea()
    local aSF2  := SF2->( GetArea() )
    local cNota := ""
    local cSerie:= ""

    If !Empty(ParamIXB)
        cNota := SubStr(ParamIXB[1][1], 4)
        cSerie:= SubStr(ParamIXB[1][1], 1, 3)
        
        DbSelectAre("SF2")
        SF2->( DbSetOrder(1) )
        If SF2->( DbSeek(xFilial()+ cNota + cSerie) )
            //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO                                                                                                  
            DbSelectAre("Z09")
            Z09->( DbSetOrder(2) )
            If Z09->( DbSeek( xFilial() + SF2->F2_DOC + SF2->F2_SERIE  ) )
                RecLock("Z09", .F.)
                Z09->Z09_CHVNFE := SF2->F2_CHVNFE
                Z09->( MsUnLock() )
            EndIf

        EndIf

    EndIf

    RestArea(aSF2)
    RestArea(aArea)
Return( Nil )

//-- 
Static Function AcdPVxOsep()
    Local aAreaAnt  := GetArea()
    Local aAreaCB7  := CB7->(GetArea())
    Local aAreaSC9  := SC9->(GetArea())

    dbSelectArea("CB7")
    CB7->(dbsetorder(1))

    dbSelectArea("SC9")
    SC9->(dbsetorder(1)) //-- C9_FILIAL, C9_PEDIDO, C9_ITEM, C9_SEQUEN, C9_PRODUTO, C9_BLEST, C9_BLCRED

    If SC9->(dbSeek(xFilial("SC9" ) + SC5->C5_NUM))
        While !SC9->(EoF()) .And. SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO == SC5->C5_NUM
            If !Empty(SC9->C9_ORDSEP) 
                If CB7->(dbSeek(xFilial("CB7") + SC9->C9_ORDSEP))
                    If ("*99" $ CB7->CB7_TIPEXP) .AND. CB7->CB7_XSTATU == "9"
                        RecLock("SC9", .F.)
                            SC9->C9_ORDSEP := ""
                        SC9->(MsUnlock())
                    EndIf 
                EndIf
            EndIf
            SC9->(dbSkip())
        EndDo
    EndIf

    RestArea(aAreaSC9)
    RestArea(aAreaCB7)
    RestArea(aAreaAnt)

Return


//--
Static Function AcdNFxOsep(cMarca, lInverte)
    Local aAreaAnt := GetArea()
    Local aAreaCB7 := CB7->(GetArea())
    Local aAreaSC9 := SC9->(GetArea())
    Local cQuery   := ""

    dbSelectArea("CB7")
    CB7->(dbsetorder(1))

    dbSelectArea("SC9")
    SC9->(dbsetorder(1)) //-- C9_FILIAL, C9_PEDIDO, C9_ITEM, C9_SEQUEN, C9_PRODUTO, C9_BLEST, C9_BLCRED

    If Select("_QRYSC9") > 0
        _QRYSC9->(dbCloseArea())
    EndIf

    Pergunte("MT461A", .F.)

    cQuery := " SELECT C9_FILIAL, C9_PEDIDO, C9_ITEM, C9_SEQUEN, C9_PRODUTO, C9_ORDSEP "
    cQuery += " FROM " + RetSQLName("SC9") + " SC9 "
    cQuery += " WHERE C9_FILIAL='" + xFilial("SC9") + "' "
    cQuery += " AND C9_OK"+Iif(lInverte, "<>", "=") + "'" + cMarca + "' "
    cQuery += " AND C9_CLIENTE >= '" + MV_PAR07 + "' AND C9_CLIENTE <= '" + MV_PAR08 + "' "
    cQuery += " AND C9_LOJA >= '" + MV_PAR09 + "' AND C9_LOJA <= '" + MV_PAR10 + "' "
    cQuery += " AND C9_DATALIB >= '" + dToS(MV_PAR11) + "' AND C9_DATALIB <= '" + dToS(MV_PAR12) + "' "
    cQuery += " AND C9_PEDIDO >= '" + MV_PAR05 + "' AND C9_PEDIDO <= '" + MV_PAR06 + "' "
    cQuery += " AND C9_BLEST = '' AND C9_BLCRED = '' "
    cQuery += " AND SC9.D_E_L_E_T_ = ' ' "

    cQuery := ChangeQuery(cQuery)
    TCQUERY cQuery New Alias "_QRYSC9"

    _QRYSC9->(dbGoTop())
    While !_QRYSC9->(EoF())
        If !Empty(_QRYSC9->C9_ORDSEP) 
            If CB7->(dbSeek(xFilial("CB7") + _QRYSC9->C9_ORDSEP))
                If ("*99" $ CB7->CB7_TIPEXP) .AND. CB7->CB7_XSTATU == "9"
                    If SC9->(dbSeek(_QRYSC9->(C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO)))
                        RecLock("SC9", .F.)
                            SC9->C9_ORDSEP := ""
                        SC9->(MsUnlock())
                    EndIf
                EndIf 
            EndIf
        EndIf
        _QRYSC9->(dbSkip())
    EndDo

    If Select("_QRYSC9") > 0
        _QRYSC9->(dbCloseArea())
    EndIf

    RestArea(aAreaSC9)
    RestArea(aAreaCB7)
    RestArea(aAreaAnt)

Return


//--
Static Function AcdGrvOsep(nOpc, aParam)
    Local aAreaAnt  := GetArea()
    Local aAreaCB7  := CB7->(GetArea())
    Local aAreaSC9  := SC9->(GetArea())
    Local cNumNFS   := ""
    Local cSerieNFS := ""
    Local cClieFor  := ""
    Local cLoja     := ""
    Local cQuery    := ""

    Default aParam := Array(4)

    cNumNFS   := aParam[1]
    cSerieNFS := aParam[2]
    cClieFor  := aParam[3]
    cLoja     := aParam[4]

    dbSelectArea("CB7")
    CB7->(dbsetorder(2))

    dbSelectArea("SC9")
    SC9->(dbsetorder(1)) //-- C9_FILIAL, C9_PEDIDO, C9_ITEM, C9_SEQUEN, C9_PRODUTO, C9_BLEST, C9_BLCRED

    cQuery := " SELECT C9_FILIAL, C9_PEDIDO, C9_ITEM, C9_SEQUEN, C9_PRODUTO, C9_ORDSEP, CB7_ORDSEP "
    cQuery += " FROM " + RetSQLName("SC9") + " SC9 "
    cQuery += " INNER JOIN " + RetSQLName("CB7") + " CB7 "
    cQuery += " ON CB7_FILIAL = C9_FILIAL "
    cQuery += " AND CB7_ORIGEM = '1' "
    cQuery += " AND CB7_PEDIDO = C9_PEDIDO "
    cQuery += " AND CB7.D_E_L_E_T_ = ' ' "
    cQuery += " WHERE C9_FILIAL = '" + xFilial("SC9") + "' "
    If nOpc == 2
        cQuery += " AND C9_NFISCAL = '" + cNumNFS + "' "
        cQuery += " AND C9_SERIENF = '" + cSerieNFS + "' "
        cQuery += " AND C9_CLIENTE = '" + cClieFor + "' "
        cQuery += " AND C9_LOJA = '" + cLoja + "' "
    EndIf
    cQuery += " AND C9_ORDSEP = ' ' "
    cQuery += " AND SC9.D_E_L_E_T_ = ' ' "

    cQuery := ChangeQuery(cQuery)
    TCQUERY cQuery New Alias "_QRYSC9"

    _QRYSC9->(dbGoTop())
    While !_QRYSC9->(EoF())
        If Empty(_QRYSC9->C9_ORDSEP) 
            If CB7->(dbSeek(xFilial("CB7") + _QRYSC9->C9_PEDIDO)) .And. CB7->CB7_ORIGEM == "1"
                If ("*99" $ CB7->CB7_TIPEXP) .AND. CB7->CB7_XSTATU == "9"
                    If SC9->(dbSeek(_QRYSC9->(C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO)))
                        RecLock("SC9", .F.)
                            SC9->C9_ORDSEP := CB7->CB7_ORDSEP
                        SC9->(MsUnlock())
                    EndIf
                EndIf 
            EndIf
        EndIf
        _QRYSC9->(dbSkip())
    EndDo

    If Select("_QRYSC9") > 0
        _QRYSC9->(dbCloseArea())
    EndIf

    RestArea(aAreaSC9)
    RestArea(aAreaCB7)
    RestArea(aAreaAnt)

Return


//--
Static Function sSF2520E(aParam)
    Local aArea   := GetArea()
    Local aSF2    := SF2->( GetArea() )
    Local aSD2    := SD2->( GetArea() )
    Local aSC5    := SC5->( GetArea() )
    Local aTrackS := {}
    Local nTamZ09 := 0
    Local lAtuZ09 := .F.
     
    dbSelectAre("Z09")
    nTamZ09 := Len( Z09->( dbStruct() ) )
    
    SD2->( DbSetOrder(3) )
    If SD2->( DbSeek(xFilial() + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA) ) .And. u_Trk006ME(SD2->D2_PEDIDO)
        lAtuZ09 := .T.

        DbSelectArea("SC5")
        SC5->( DbSetOrder(1) )
        If SC5->( DbSeek(xFilial() + SD2->D2_PEDIDO ) )
            RecLock("SC5", .F.)
            SC5->C5_X4SSTAT := "2" //-- Em Faturamento
            SC5->( MsUnLock() )
        EndIf

    Endif

    While lAtuZ09 .And. SD2->( !Eof() ) .And. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == SF2->( F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA) 

        aTrackS := Array( nTamZ09 )

        //-- Atualiza Z09
        DbSelectAre("Z09")
        aTrackS[FieldPos("Z09_FILIAL")] := xFilial("SF2") // Filial
        aTrackS[FieldPos("Z09_NUMPV") ] := SD2->D2_PEDIDO // Pedido Venda  C [ 6 ][ 0 ] 05
        aTrackS[FieldPos("Z09_ITEMPV")] := SD2->D2_ITEMPV // Item PV       C [ 2 ][ 0 ] 06
        aTrackS[FieldPos("Z09_STATUS")] := "6"            // Em Faturamento
        aTrackS[FieldPos("Z09_NF")    ] := ""             // Nota Fiscal
        aTrackS[FieldPos("Z09_SERIE") ] := ""             // Serie Nota Fiscal
        aTrackS[FieldPos("Z09_DTEMNF")] := CTOD("")      // Emissao Nota
        aTrackS[FieldPos("Z09_HREMNF")] := ""            // Hora Emissao
        aTrackS[FieldPos("Z09_CHVNFE")] := ""
        aTrackS[FieldPos("Z09_TOTAL") ] := 0

        u_TRK006S(aTrackS, "Exclusão NF " + Alltrim(SF2->F2_DOC) + "-" + Alltrim(SF2->F2_SERIE))

        SD2->( DbSkip() )
    EndDo

    RestArea(aSC5)
    RestArea(aSD2)
    RestArea(aSF2)
    RestArea(aArea)

Return
