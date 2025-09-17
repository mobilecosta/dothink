#include "totvs.ch"

#define nWidthCard 100
#define nHeigthCard 50

#define cAllbackground "#F2F2F2"
#define cClrMenu "#F2F2F2"
#define cClrText "#045B8F"

/*/{Protheus.doc} TRK0001
Cockpit Logistico
@type function
@version 1.0
@author erike.yuri@dothink.com.br
@since 30/06/2025
/*/
User Function TRK0001()
    MotaCockpit()
Return

//-- Cockpit Expedicao
User Function TRK0001A()
    MotaCockpit(1)
Return 

//-- Cockpit Recebimento
User Function TRK0001B()
    MotaCockpit(2)
Return 

//-- Cockpit Qualidade
User Function TRK0001C()
    MotaCockpit(3)
Return 

//-- Cockpit CS
User Function TRK0001D()
    MotaCockpit(4)
Return 

//-- Cockpit Faturamento
User Function TRK0001E()
    MotaCockpit(5)
Return 


//-- Atualiza Status
User Function TRK0001S()
    TrataStatus()
Return 


/*/{Protheus.doc} MotaCockpit
Monta tela do CockPit
@type function
@version 1.0
@author erike.yuri@dothink.com.br
@since 30/06/2025
/*/
Static Function MotaCockpit(nOpc as numeric)
    local lTelaG    as logical
    local lSlaExp   as logical
    local cAliasTrk as character
    local cTitulo   as character
    local cFunExec  as character
    local nI        as numeric
    local nJ        as numeric
    local nLinLista as numeric
    local nHDown    as numeric
    local nColCard  as numeric
    local aSize     as array
    local aDbCards  as array
    local aRelation as array
    local bInfG     as codeblock
    local bSair     as codeblock
    local oDlgTrk   as object
    local oSayTit   as character

    private aCards  as array
    private aButton as array

    private cFontNome   := 'Tahoma'
    private oFontPadrao := TFont():New(cFontNome, , -14, ,.T.)

    default nOpc := 0

    //-- Inicialização de variáveis
    aButton     := {}
    aDbCards    := GetDbCards(nOpc)
    aCards      := Array( Len(aDbCards), 6)
    aSize       := FWGetDialogSize( oMainWnd )
    lTelaG      := (ASIZE[4] > 1580)
    lSlaExp     := .T.
    nHDown      := 150
    cCadastro   := "Cockpit Logistico"
    cAliasTrk   := "Z09"
    cTitulo     := "Expedição"
    cFunExec    := "TRK0002"
    aRelation   := { { 'Z11_IDTRAC', 'Z09_IDTRAC' } }
    bInfG       := {|| oInfG:lVisible :=  !oInfG:lVisible, oBody:Refresh(), oBrowseUp:Refresh(), oBrowseDwn:Refresh() }
    bSair       := {|| If(MSGYESNO( "Deseja realmente fechar a aplicação?", "Encerrando Cockpit" ), oDlgTrk:End(), nil)}

    DO CASE
        CASE nOpc == 1
            cCadastro += " - " + cTitulo
        CASE nOpc == 2
            cTitulo   := "Recebimento"
            cCadastro += " - " + cTitulo
            aRelation := { { 'Z11_IDTRAC', 'Z10_IDTRAC' } }
            cAliasTrk := "Z10"
            cFunExec  := "TRK0003"
            lSlaExp   := .F.
        CASE nOpc == 3
            cTitulo   := "Recebimento"
            cCadastro += "- Qualidade"
            aRelation := { { 'Z11_IDTRAC', 'Z10_IDTRAC' } }
            cAliasTrk := "Z10"
            cFunExec  := "TRK0003"
            lSlaExp   := .F.
        CASE nOpc == 4
            cCadastro  += "- CS (Customer Service)"
        CASE nOpc == 5
            cCadastro  += "- Faturamento"
    END CASE

    //-- Atualiza STATUS SLA
    If lSlaExp
        u_TRK0017A()
    EndIf

    oDlgTrk := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cCadastro, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. ) 

    oMenu   := TPanel():New(0, 0, '', oDlgTrk, /*oFont*/, /*lCentered*/, /*uParam7*/, /*nClrText*/,, 080, 1000, .T. )
    oMenu:SetCSS("QWidget { background: "+cClrMenu+"; border: 1px solid white; }")
    oMenu:align      := CONTROL_ALIGN_LEFT

    //-- MENU ---------------------------------------------------------------------------------------------------
    oTMenu:= TPanel():New(0, 0, , oMenu, , /*lCentered*/, /*uParam7*/, /*nClrText*/,, 30, 15, .T. )
    oTMenu:SetCSS("QWidget { background: "+cClrMenu+"; }")
    oTMenu:align      := CONTROL_ALIGN_TOP
    TSay():New(01, 01, {|| '<div style="font-size: 12px;"><strong>::MENU::<strong></div>' }, oTMenu, /*cPicture*/, /*oFontPadrao*/, , , , .T., /*nClrText*/, /*nClrBack*/, 30, 15, , , , , , .T.)
    
    oMExit:= TPanel():New(0, 0, '', oMenu, /*oFont*/, /*lCentered*/, /*uParam7*/, /*nClrText*/,, 30, 25, .T. )
    oMExit:SetCSS("QWidget { background: "+cClrMenu+"; border: 1px solid white; }")
    oMExit:align:= CONTROL_ALIGN_BOTTOM

    aadd(aButton, {AddBotao("MENURUN"   , "Fechar menu" , {|| oMenu:nWidth := If(oMenu:nWidth == 160, 48, 160) }, oMExit, cClrMenu, cClrText)})

    aadd(aButton, {AddBotao("PARAMETROS", "Inf.Gerais"  , bInfG, oMenu, cClrMenu, cClrText)})
    aadd(aButton, {AddBotao("TK_REFRESH", "Atu.Cards"   , {|| FWMsgRun(NIL,{|| SetVldCards()  },"Aguarde...","Atualizando Cards") }, oMenu, cClrMenu, cClrText)})

    If nOpc == 0 .Or. nOpc == 5
        //aadd(aButton, {AddBotao("NCO", "Vld.Fiscal"  , {|| u_TRK0005()}, oMenu, cClrMenu, cClrText)})
        aadd(aButton, {AddBotao("NCO", "Cad.Motivos"   , {|| u_trk0008b()}, oMenu, cClrMenu, cClrText)})
    EndIf

    If nOpc == 0 .Or. nOpc == 1
        //-- Validacao Fisica
        aadd(aButton, {AddBotao("PENDENTE", "Vld.Física"  , {||EndFilBrw("Z09"), u_TRK0009A()}, oMenu, cClrMenu, cClrText)})
        //-- Ordem de Separação
        aadd(aButton, {AddBotao("EMPILHADEIRA", "Ord.Separação"  , {|| EndFilBrw("Z09"), u_TRK0009B()}, oMenu, cClrMenu, cClrText)})        

    EndIf



    aadd(aButton, {AddBotao("FINAL"     , "Sair"        , bSair, oMenu, cClrMenu, cClrText)})
    //-- FIM MENU -----------------------------------------------------------------------------------------------


    oMain := TPanel():New(0, 0, '', oDlgTrk, /*oFont*/, /*lCentered*/, /*uParam7*/, /*nClrText*/,, 1000, 1000 )
    oMain:align      := CONTROL_ALIGN_ALLCLIENT

    //--Sub-Titulo -----------------------------------------------------------------------------------------------
    oSubT:= TPanel():New(0, 0, , oMain, /*oFont*/, /*lCentered*/, /*uParam7*/, /*nClrText*/,, 1000, 15, .T. )
    oSubT:SetCSS("QWidget { background: "+cAllbackground+"; }")
    oSubT:align      := CONTROL_ALIGN_TOP
    oSayTit := TSay():New(01, 05, {|| '<div style="font-size: 20px;">'+cCadastro+'</div>' }, oSubT, /*cPicture*/, /*oFont*/, , , , .T., /*nClrText*/, /*nClrBack*/, 300, 15, , , , , , .T.)
    oSayTit:SetCSS("background-color: "+cAllbackground+"; color: "+cClrText+"}")

    //-- Informacoes Gerais --------------------------------------------------------------------------------------
    oInfG   := TPanel():New(0, 0, '', oMain, /*oFont*/, /*lCentered*/, /*uParam7*/, /*nClrText*/,, 300, nHeigthCard+5 )
    oInfG:SetCSS("QWidget { background: #f1f2f2ff; border: 1px solid white; }")
    oInfG:align         := CONTROL_ALIGN_TOP
    If !lTelaG 
        oInfG:lVisible  := .F.
        nHDown          := 100        
    EndIf


    nColCard := 2
    For nI:=1 To Len(aCards)
        aCards[nI,1] := TPanel():New(002 , nColCard  , , oInfG, /*oFont*/, /*lCentered*/, /*uParam7*/, /*nClrText*/, , nWidthCard , nHeigthCard, .T. )
        aCards[nI,1]:SetCSS("QWidget { background: #ffffffff;   border: 1px solid black; border-radius: 5px; }")

        aCards[nI,2] := TPanel():New(001 , 001  , , aCards[nI,1], /*oFont*/, /*lCentered*/, /*uParam7*/, /*nClrText*/, , 100 , 12, .T. )
        aCards[nI,2]:SetCSS("QWidget { background: #00659A; }")
        aCards[nI,2]:align := CONTROL_ALIGN_TOP

        aCards[nI,3] := TSay():New(01, 20, {|| '<div style="font-size: 14px;"></div>' }, aCards[nI,2], /*cPicture*/, /*oFontPadrao*/, , , , .T., /*nClrText*/, /*nClrBack*/, 100, 15, , , , , , .T.)
        aCards[nI,3]:SetText( '<div style="font-size: 14px; color: #FFFFFF;">'+aDbCards[nI, 1]+'</div>')
        
        //Imagem atual
        If !Empty(aDbCards[nI, 2])
            oBmpFoto := TBitmap():New(001, 002, 10, 10, aDbCards[nI, 2], /*cBmpFile*/, /*lNoBorder*/, aCards[nI,2], /*bLClicked*/, /*bRClicked*/, /*lScroll*/, .T. /*lStretch*/, /*oCursor*/, /*uParam14*/, /*uParam15*/, /*bWhen*/, .T., /*bValid*/)
            oBmpFoto:Refresh()
        EndIf

        //-- Trata lista
        nLinLista := 15
        aCards[nI,4] := Array( Len(aDbCards[nI, 3]) )
        aCards[nI,5] := Array( Len(aDbCards[nI, 3]) )
        aCards[nI,6] := Array( Len(aDbCards[nI, 3]) )
        For nJ:=1 To Len(aDbCards[nI, 3])
            aCards[nI,4,nJ] := TSay():New(nLinLista, 20, {|| "" }, aCards[nI,1], /*cPicture*/, /*oFontPadrao*/, , , , .T., /*nClrText*/, /*nClrBack*/, 60, 7, , , , , , .T.)
            aCards[nI,4,nJ]:SetText( '<div>'+aDbCards[nI, 3, nJ]+'</div>')

            aCards[nI,5,nJ] := TButton():New(nLinLista, 02, cValtoChar(aDbCards[nI, 4, nJ]), aCards[nI,1], {|| .T. }, 15, 7, , /*oFontPadrao*/, , .T.)
            aCards[nI,5,nJ]:SetCSS("TButton { font: bold;     background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #3DAFCC, stop: 1 #0D9CBF);    color: #FFFFFF;     border-width: 1px;     border-style: solid;     border-radius: 3px;     border-color: #369CB5; }TButton:focus {    padding:0px; outline-width:1px; outline-style:solid; outline-color: #51DAFC; outline-radius:3px; border-color:#369CB5;}TButton:hover {    color: #FFFFFF;     background-color : qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #3DAFCC, stop: 1 #1188A6);    border-width: 1px;     border-style: solid;     border-radius: 3px;     border-color: #369CB5; }TButton:pressed {    color: #FFF;     background-color : qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #1188A6, stop: 1 #3DAFCC);    border-width: 1px;     border-style: solid;     border-radius: 3px;     border-color: #369CB5; }TButton:disabled {    color: #FFFFFF;     background-color: #4CA0B5; }")
            aCards[nI,5,nJ]:cMsg := aDbCards[nI, 5, nJ] //-- Variavel de controle

            aCards[nI,6,nJ] := TSay():New(nLinLista, 80, {|| "" }, aCards[nI,1], /*cPicture*/, /*oFontPadrao*/, , , , .T., /*nClrText*/, /*nClrBack*/, 30, 7, , , , , , .T.)
            aCards[nI,6,nJ]:SetText( '<div>(0)</div>')
            aCards[nI,6,nJ]:cMsg := aDbCards[nI, 5, nJ]+"_ALL" //-- Variavel de controle

            nLinLista += 8
        Next nJ


        nColCard += nWidthCard + 5
    Next nI

    FWMsgRun(NIL,{|| SetVldCards()  },"Aguarde...","Atualizando Cards")
    
    //--Tracking
    oBody := TPanel():New(0, 0, '', oMain, /*oFont*/, /*lCentered*/, /*uParam7*/, /*nClrText*/,, 1000, 1000 )
    oBody:align      := CONTROL_ALIGN_ALLCLIENT

        DbSelectArea(cAliasTrk)
        (cAliasTrk)->( DbSetOrder(1) )

        DbSelectArea("Z11")
        Z11->( DbSetOrder(1) )
       
        oPanelDown := TPanel():New(0, 0, '', oBody, /*oFont*/, /*lCentered*/, /*uParam7*/, /*nClrText*/,, 50, nHDown )
        oPanelDown:align:= CONTROL_ALIGN_BOTTOM

        oPanelUp := TPanel():New(0, 0, '', oBody, /*oFont*/, /*lCentered*/, /*uParam7*/, /*nClrText*/,, 1000, 1000 )
        oPanelUp:align:= CONTROL_ALIGN_ALLCLIENT

        //Cria o browse superior trazendo dados da cAliasTrk
        oBrowseUp:= FWmBrowse():New()
        oBrowseUp:SetOwner(oPanelUp)
        oBrowseUp:SetDescription("Tracking " + cTitulo )
        oBrowseUp:SetAlias(cAliasTrk)
        oBrowseUp:DisableDetails()
        oBrowseUp:SetProfileID('1')
        oBrowseUp:ExecuteFilter(.T.)
        oBrowseUp:SetMainProc("TRK0004")
        oBrowseUp:ForceQuitButton()
        oBrowseUp:SetMenuDef(cFunExec)
        oBrowseUp:SetCacheView (.F.)
        //oBrowseUp:SetOnlyFields({'Z09_IDTRAC', 'Z09_BU'})
        If cAliasTrk == "Z09"
            oBrowseUp:AddLegend( "Z09->Z09_STATUS == '1' "                      , "BR_PRETO"            , "Em Liberação"            , "1")
            oBrowseUp:AddLegend( "Z09->Z09_STATUS == '2' "                      , "br_branco.bmp"       , "Em Validação Fiscal"     , "1")
            oBrowseUp:AddLegend( "Z09->Z09_STATUS == '3' "                      , "br_amarelo.bmp"      , "Em Validação Física"     , "1")
            oBrowseUp:AddLegend( "Z09->Z09_STATUS == '4' "                      , "br_laranja.bmp"      , "Em Agendamento"          , "1")
            oBrowseUp:AddLegend( "Z09->Z09_STATUS == '5' "                      , "br_marron.bmp"       , "Em Separação"            , "1")
            oBrowseUp:AddLegend( "Z09->Z09_STATUS == '6' "                      , "br_azul.bmp"         , "Em Faturamento"          , "1")
            oBrowseUp:AddLegend( "Z09->Z09_STATUS == '7' "                      , "br_verde.bmp"        , "Em Embarque"             , "1")
            oBrowseUp:AddLegend( "Z09->Z09_STATUS == '8' "                      , "BR_BRANCO"           , "Pedido Em Transito"      , "1") 
            oBrowseUp:AddLegend( "Z09->Z09_STATUS == '9' "                      , "GREEN"               , "Pedido Entregue"         , "1") 
            oBrowseUp:AddLegend( "Z09->Z09_SLA == ' ' .or. Z09->Z09_SLA == '1' ", "sps_updated"         , "Dentro do Prazo"         , "2")
            oBrowseUp:AddLegend( "Z09->Z09_SLA == '2' "                         , "sps_outdated"        , "Próximo Vencimento"      , "2")
            oBrowseUp:AddLegend( "Z09->Z09_SLA == '3' "                         , "sps_not_installed"   , "Fora do Prazo"           , "2")
            oBrowseUp:AddLegend( "Z09->Z09_SLA == '4' "                         , "sps_not_compatible"  , "SLA Pausado"             , "2")
            oBrowseUp:AddLegend( "Z09->Z09_ACAOCS == '2' "                      , "CLIENTE"             , "Pendencia CS"            , "3")
            oBrowseUp:AddLegend( "Z09->Z09_ACAOCS == '3' "                      , "checked"             , "Ajustado CS"             , "3")
            oBrowseUp:AddLegend( "Z09->Z09_ACAOCS == '4' "                      , "cancel"              , "Cancelado CS"            , "3")
        EndIf

        oBrowseUp:Activate()

        //Cria o browse inferior, que irá trazer todos os produtos
        aRotina := FWLoadMenuDef("TRK0004")
        oBrowseDwn:= FWMBrowse():New()
        oBrowseDwn:SetOwner(oPanelDown)
        oBrowseDwn:SetDescription("Log do Tracking")
        oBrowseDwn:SetMenuDef('TRK0004')
        oBrowseDwn:DisableDetails()
        oBrowseDwn:SetAlias('Z11')
        oBrowseDwn:SetProfileID('2')
        oBrowseDwn:SetMainProc(cFunExec)
        oBrowseDwn:SetCacheView (.F.)
        //oBrowseDwn:SetOnlyFields({'Z11_IDTRAC', 'Z11_ORIG'})

        //Faz o relacionamento entre os dois browses
        oRelaction:= FWBrwRelation():New()
        oRelaction:AddRelation( oBrowseUp  , oBrowseDwn , aRelation )
        oRelaction:Activate()
        oBrowseDwn:Activate()

        //Atualiza os browses e cria a janela na tela
        oBrowseUp:Refresh()
        oBrowseDwn:Refresh()

    oDlgTrk:Activate()


Return


/*/{Protheus.doc} AddBotao
Adiciona botao na barra de menu lateral
@type function
@version 1.0
@author erike.yuri@dothink.com.br
@since 8/7/2025
@param cResName, character, nome da imagem no rpo
@param cText, character, texto do botao 
@param bAction, codeblock, acao executada com o click
@param oContainer, object, objeto pai
@param cCorMenu, character, código da cor do menu
@param cCorTexto, character, código da cor do texto do botao
@return array, array com os objetos
/*/
Static Function AddBotao(cResName, cText, bAction, oContainer, cCorMenu, cCorTexto)
    local aRet      := Array(3)
    local cSay1     := '<div style="font-size: 14px;">'+cText+'</div>'
    local lDimPixels:= .T.

    aRet[1] := TPanel():New(0, 0, '', oContainer, /*oFont*/, /*lCentered*/, /*uParam7*/, /*nClrText*/,, 30, 15, .T. )
    aRet[1]:SetCSS("QWidget { background: "+cCorMenu+";}")
    aRet[1]:Align:= CONTROL_ALIGN_TOP
    //TBtnBmp2(): New ( [ nTop], [ nLeft], [ nWidth], [ nHeight], [ cResName1], [ uParam6], [ uParam7], [ uParam8], [ bAction], [ oWnd], [ cMsg], [ bWhen], [ uParam13], [ uParam14] ) --> oObjeto
    aRet[2] := TBtnBmp2():New( 01,08,26,26,cResName,,,,bAction,aRet[1], cText,,.T. )

    //aRet[3] := TSay():New(01, 30, &("{|| '"+ cText +"'}"), aRet[1],,,,,,.T., , 100,20)
    aRet[3] := TSay():New(01, 25, {|| cSay1}, aRet[1], /*cPicture*/, /*oFontPadrao*/, , , , lDimPixels, /*nClrText*/, /*nClrBack*/, 150, 15, , , , , , .T.)
    aRet[3]:SetCSS("background-color: "+cCorMenu+"; color: "+cCorTexto+"}")
    aRet[3]:bRClicked  := bAction

Return aRet


//-- somente para teste
Static Function GetDbCards(nOpc)
    local aRet := {} //-- [1] Titulo; [2] Resource; [3] Array com lista; [4] Array com valores

    If nOpc == 0 .or. nOpc == 2 .or. nOpc == 3
        //--- Recebimento
        //Aadd(aRet, {"RECEBIMENTO"   , "trk-receb-32x32" , {"Em pré-nota", "Em Check List", "Em Conferência"}, {0, 0, 0}, {"_nPRE", "_nCHK", "_nCONF"}})
        
        //--- Qualidade
        //Aadd(aRet, {"QUALIDADE"     , "trk-qa-32x32"    , {"Em Análise"}, {0}, {"_nCQ"}})        
    EndIf

    If nOpc == 0 .or. nOpc == 1 .or. nOpc == 4 .or. nOpc == 5
        //--- Expedicao
        Aadd(aRet, {"EXPEDIÇÃO"     , "trk-exped-32x32" , {"Em Validação Física", "Em Agendamento","Em Separação", "Em Embarque"}, {0, 0, 0, 0}, {"_nVLDFISICA", "_nAGENDA","_nSEP","_nEMBARQ"}})
    EndIf
    
    If nOpc == 0 .or. nOpc == 5
        //--- FATURAMENTO
        Aadd(aRet, {"FATURAMENTO"   , "trk-fatura-32x32", {"Em Validação Fiscal", "Em Faturamento"}, {0, 0}, {"_nVLDFISCAL", "_nFATUR"}})
    EndIf

    If nOpc == 0 .or. nOpc == 4
        //--- CS
        Aadd(aRet, {"CS"            , "trk-cs-32x32"    , {"Validação CS", "Ajustado CS", "Cancelado CS"}, {0, 0, 0}, {"_nCS2", "_nCS3", "_nCS4"}})
    EndIf

    If nOpc == 0 .or. nOpc == 1 .or. nOpc == 4 .or. nOpc == 5
        //--- SLA EXPEDICÃO
        Aadd(aRet, {"SLA EXPEDIÇÃO" , "trk-exped-32x32" , {"Dentro do Prazo", "Próximo Vencimento","Fora do Prazo", "SLA Pausado"}, {0, 0, 0, 0}, {"_nSLA_1", "_nSLA_2","_nSLA_3","_nSLA_4"}})
    EndIf


return aRet



Static Function SetVldCards()
    local nI, nJ
    local cVar       := ""
    local cVar1      := ""
    local cItem      := ""
    local nCount     := 0
    local aArea      := GetArea()
    local cQryZ09    := "SELECT COUNT(1) AS OK FROM " + RetSQLName("Z09") + " Z09 WHERE Z09.Z09_FILIAL = '" + xFilial("Z09") + "' AND Z09.D_E_L_E_T_= ' ' "
    local cQryZ09ALL := "SELECT COUNT(1) AS OK FROM " + RetSQLName("Z09") + " Z09 WHERE Z09.D_E_L_E_T_= ' ' "

    For nI:=1 To Len(aCards)
        For nJ:=1 To Len(aCards[nI, 4])
            cVar    := aCards[nI,5,nJ]:cMsg
            nCount  := 0

            DO CASE
                CASE cVar == "_nVLDFISCAL"
                    nCount := MpSysExecScalar(cQryZ09 + " AND Z09.Z09_STATUS = '2' ", "OK")
                CASE cVar == "_nVLDFISICA"
                    nCount := MpSysExecScalar(cQryZ09 + " AND Z09.Z09_STATUS = '3' ", "OK")
                CASE cVar == "_nAGENDA"
                    nCount := MpSysExecScalar(cQryZ09 + " AND Z09.Z09_STATUS = '4' ", "OK")
                CASE cVar == "_nSEP"
                    nCount := MpSysExecScalar(cQryZ09 + " AND Z09.Z09_STATUS = '5' ", "OK")
                CASE cVar == "_nFATUR"
                    nCount := MpSysExecScalar(cQryZ09 + " AND Z09.Z09_STATUS = '6' ", "OK")
                CASE cVar == "_nEMBARQ"
                    nCount := MpSysExecScalar(cQryZ09 + " AND Z09.Z09_STATUS = '7' ", "OK")
                CASE cVar == "_nCS2"
                    nCount := MpSysExecScalar(cQryZ09 + " AND Z09.Z09_ACAOCS = '2' ", "OK")
                CASE cVar == "_nCS3"
                    nCount := MpSysExecScalar(cQryZ09 + " AND Z09.Z09_ACAOCS = '3' ", "OK")
                CASE cVar == "_nCS4"
                    nCount := MpSysExecScalar(cQryZ09 + " AND Z09.Z09_ACAOCS = '4' ", "OK")
                CASE "_nSLA_" $ cVar
                    cItem := Right(cVar,1)
                    If cItem == "1"
                        nCount := MpSysExecScalar(cQryZ09 + " AND Z09.Z09_SLA IN(' ', '1') ", "OK")
                    Else
                        nCount := MpSysExecScalar(cQryZ09 + " AND Z09.Z09_SLA = '"+cItem+"' ", "OK")
                    EndIf
            END CASE

            aCards[nI,5,nJ]:cCaption := cValtoChar(nCount)

            cVar1   := aCards[nI,6,nJ]:cMsg
            nCount  := 0

            DO CASE
                CASE cVar1 == "_nVLDFISCAL_ALL"
                    nCount := MpSysExecScalar(cQryZ09ALL + " AND Z09.Z09_STATUS = '2' ", "OK")
                CASE cVar1 == "_nVLDFISICA_ALL"
                    nCount := MpSysExecScalar(cQryZ09ALL + " AND Z09.Z09_STATUS = '3' ", "OK")
                CASE cVar1 == "_nAGENDA_ALL"
                    nCount := MpSysExecScalar(cQryZ09ALL + " AND Z09.Z09_STATUS = '4' ", "OK")
                CASE cVar1 == "_nSEP_ALL"
                    nCount := MpSysExecScalar(cQryZ09ALL + " AND Z09.Z09_STATUS = '5' ", "OK")
                CASE cVar1 == "_nFATUR_ALL"
                    nCount := MpSysExecScalar(cQryZ09ALL + " AND Z09.Z09_STATUS = '6' ", "OK")
                CASE cVar1 == "_nEMBARQ_ALL"
                    nCount := MpSysExecScalar(cQryZ09ALL + " AND Z09.Z09_STATUS = '7' ", "OK")
                CASE cVar1 == "_nCS2_ALL"
                    nCount := MpSysExecScalar(cQryZ09ALL + " AND Z09.Z09_ACAOCS = '2' ", "OK")
                CASE cVar1 == "_nCS3_ALL"
                    nCount := MpSysExecScalar(cQryZ09ALL + " AND Z09.Z09_ACAOCS = '3' ", "OK")
                CASE cVar1 == "_nCS4_ALL"
                    nCount := MpSysExecScalar(cQryZ09ALL + " AND Z09.Z09_ACAOCS = '4' ", "OK")
                CASE "_nSLA_" $ cVar1
                    cVar1 := StrTran(cVar1, "_ALL", "") 
                    cItem := Right(cVar1,1)
                    If cItem == "1"
                        nCount := MpSysExecScalar(cQryZ09ALL + " AND Z09.Z09_SLA IN(' ', '1') ", "OK")
                    Else
                        nCount := MpSysExecScalar(cQryZ09ALL + " AND Z09.Z09_SLA = '"+cItem+"' ", "OK")
                    EndIf
            END CASE

            aCards[nI,6,nJ]:SetText( '<div>('+cValtoChar(nCount)+')</div>')


        Next nJ
    Next nI

    RestArea(aArea)
Return



Static Function TrataStatus()
    local cPedido   := ""       as character
    local cNota     := ""       as character
    local cStZ09    := ""       as character
    local cSt4Sales := ""       as character
    local aParamBox := Array(0) as array
    local aStaZ09   := Array(0) as array
    local aStaSC5   := Array(0) as array
    local aArea     := {}       as array
    local aAZ09     := {}       as array
    local lContinua := .T.      as logical

    If !MsgYesNo("Confirma a alteração do Status?") 
        Return
    EndIf

    aArea   := GetArea()
    aAZ09   := Z09->( GetArea() )

    If Z09->( Eof() )
        FWAlertInfo("Não existem registros selecionados!", "Registro Não Selecionado")
        Return
    EndIf

    cPedido := Z09->Z09_NUMPV
    cNota   := Z09->Z09_NF
    cStZ09  := Z09->Z09_STATUS
    aStaZ09 := X3CboxToArray("Z09_STATUS")[1]
    aStaSC5 := X3CboxToArray("C5_X4SSTAT")[1]

    If Empty( cPedido )
      lContinua := .F.  
    Else
        DbSelectArea("SC5") 
        SC5->( DbSetOrder(1) )

        If !SC5->( DbSeek( xFilial() + cPedido) )
            FWAlertInfo("O pedido [" + cPedido + "] não foi localizado. Favor verificar!", "Pedido NÃO Localizado")
            lContinua := .F.
        Else
            cSt4Sales := SC5->C5_X4SSTAT
        EndIf

    EndIf

    If lContinua

        SaveInter()
            
        aAdd(aParamBox,{2, "Status Tracking"        , cStZ09    , aStaZ09, 100, "", .T.})
        aAdd(aParamBox,{2, "Status Pedido Vendas"   , cSt4Sales , aStaSC5, 100, ".F.", .F.})
        If ParamBox(@aParamBox,"Manutenção Status",,NIL,NIL,.T.,NIL,NIL,NIL,NIL,.T.,.T.)
            If ValType(mv_par01) == "N"
                mv_par01 := Str(mv_par01, 1)
            Endif

            If ValType(mv_par02) == "N"
                mv_par02 := Str(mv_par02, 1)
            Endif
            
            mv_par01 := Substr(mv_par01, 1,1)
            mv_par02 := Substr(mv_par02, 1,1)

            GrvStatus(mv_par01, mv_par02, cPedido)
        Endif

        RestInter()

    EndIf

    RestArea(aAZ09)
    RestArea(aArea)

    FWFreeArray(@aParamBox)
    FWFreeArray(@aAZ09)
    FWFreeArray(@aArea)

Return

/*/{Protheus.doc} GrvStatus
Atualização do Status das tabelas SC5 e Z09, conforme execucao do 
@type function
@version 1.0
@author erike.yuri@dothink.com.br
@since 30/07/2025
@param cStaZ09, character, Status Tracking Expedicao
@param cStaSC5, character, Status pedido de vendas
@param cPedido, character, codigo do pedido de vendas
/*/
Static Function GrvStatus(cStaZ09, cStaSC5, cPedido)
    local cChave  := Z09->(Z09_FILIAL + Z09_NUMPV)
    local aTrackS := {}
    local aPVs    := {}
    local nZ09Rec := Z09->( Recno() )
    local nI      := 0

    DO CASE
        CASE cStaZ09 == "1" //1=Em Liberação;
            cStaSC5 := " "
        CASE cStaZ09 == "2" //2=Em Validação Fiscal;
            cStaSC5 := "9"  //9=Em Validação Fiscal;
        CASE cStaZ09 == "3" //3=Em Validação Física;
            cStaSC5 := "A"  //A=Validação Física;
        CASE cStaZ09 == "4" //4=Em Agendamento;
            cStaSC5 := "8"  //8=Em Agendamento;
        CASE cStaZ09 == "5" //5=Em Separação;
            cStaSC5 := "1"  //1=Em Separação;
        CASE cStaZ09 == "6" //6=Em Faturamento;
            cStaSC5 := "2"  //2=Em Faturamento;
        CASE cStaZ09 == "7" //7=Em Embarque;
            cStaSC5 := "B"  //B=Em Embarque;
        CASE cStaZ09 == "8" //8=Pedido Entregue;
            cStaSC5 := "5"  //5=Pedido Entregue;
    END CASE


    RecLock("SC5", .F.)
    SC5->C5_X4SSTAT := cStaSC5
    SC5->C5_MSEXP   :=   ""
    SC5->( MsUnLock() )

    aAdd(aPVs, cChave) 
    If !Empty(Z09->Z09_PVREME)
        If Z09->Z09_NUMPV == Z09->Z09_PVREME
            aAdd(aPVs, Z09->Z09_FILIAL + Z09->Z09_PVTRIA)
        Else
            aAdd(aPVs, Z09->Z09_FILIAL + Z09->Z09_PVREME)
        EndIf
    Endif

    //-- Verifica se é triangular
    For nI := 1 To Len(aPVs)
        cChave := aPVs[nI]

        DbSelectAre("Z09")
        Z09->( DbSetOrder(3) )
        Z09->( DbSeek(cChave) )
        While Z09->( !Eof() .And. Z09_FILIAL + Z09_NUMPV == cChave)
    
            aTrackS := Array( Len( Z09->( DbStruct() ) ) )

            aTrackS[FieldPos("Z09_FILIAL")]  :=    Z09->Z09_FILIAL
            aTrackS[FieldPos("Z09_NUMPV") ]  :=    Z09->Z09_NUMPV
            aTrackS[FieldPos("Z09_ITEMPV")]  :=    Z09->Z09_ITEMPV
            aTrackS[FieldPos("Z09_STATUS")]  :=    cStaZ09

            u_TRK006S(aTrackS,"Ajuste Manual de Status")

            Z09->( DbSkip() )
        End
    Next nI

    Z09->( DbGoto(nZ09Rec) )
Return
