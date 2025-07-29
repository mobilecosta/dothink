#include "totvs.ch"
#define nMaxCard 5
#define nWidthCard 150
#define nHeigthCard 75

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


/*/{Protheus.doc} MotaCockpit
Monta tela do CockPit
@type function
@version 1.0
@author erike.yuri@dothink.com.br
@since 30/06/2025
/*/
Static Function MotaCockpit(nOpc as numeric)
local nI    as numeric
local nTInfoG as numeric
local nColCard  as numeric
local aSize     as array
local aDbCards as array
local oDlgWA    as object
private oWorkArea as object

private aCards  as array

default nOpc := 0

//-- Inicialização de variáveis
aDbCards    := GetDbCards()
aCards      := Array(nMaxCard)
aSize       := FWGetDialogSize( oMainWnd )
nTInfoG     := If(ASIZE[4] > 1580, 180, 200)
cCadastro   := "Cockpit Logistico "

DO CASE
    CASE nOpc == 1
        cCadastro  += "- Expedição"
    CASE nOpc == 2
        cCadastro  += "- Recebimento"
    CASE nOpc == 3
        cCadastro  += "- Qualidade"
    CASE nOpc == 4
        cCadastro  += "- CS (Customer Service)"
    CASE nOpc == 5
        cCadastro  += "- Faturamento"
END CASE


oDlgWA      := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cCadastro, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. ) 
 
oWorkArea := FWUIWorkArea():new(oDlgWA)
oWorkArea:SetMenuWidth( 150 )

//-- Menu
oMenu := FWMenu():New()
oMenu:Init()

cMenuFld1   := oMenu:AddFolder( "Menu", "E" ) //
oMenuItem   := oMenu:GetItem(cMenuFld1) 
oMenuItem:AddSeparator()
oMenuItem:AddContent( "Logistica"       , "E", {||  TransMT261( oWorkArea)}) //
oMenuItem:AddContent( "Qualidade"       , "E", {||  Invent( oWorkArea)})//
oMenuItem:AddContent( "CS"              , "E", {||  Invent( oWorkArea)})//
oMenuItem:AddContent( "Faturamento"     , "E", {||  Invent( oWorkArea)})//


cMenuFld2  := oMenu:AddFolder( "Outras Ações", "E" ) //
oMenuItem   := oMenu:GetItem(cMenuFld2) 
oMenuItem:AddSeparator()
oMenuItem:AddContent( "Cards"               , "E", {|| oWorkArea:GetPanel("WIDGET1"):lVisible :=  !oWorkArea:GetPanel("WIDGET1"):lVisible } ) //
oMenuItem:AddContent( "Ajuda"               , "E", {|| ShellExecute("open",cLink  ,"","",SW_SHOW) } ) //
oMenuItem:AddContent( "Sair"                , "E", {|| If(CloseScreen(),oDlgWA:End(),.T.) } ) //

oWorkArea:SetMenu( oMenu )

oWorkArea:CreateHorizontalBox("INFGERAL", nTInfoG      , .T.)
oWorkArea:CreateHorizontalBox("MAIN"    , aSize[3]-150 , .T.)

oWorkArea:SetBoxCols("INFGERAL" , {"WIDGET1"} )
oWorkArea:SetBoxCols("MAIN"     , {"WIDGET2"} )

oWorkArea:Activate()

//aCards[1] := TPanel():New(002 , 002  , 'Card1' , oWorkArea:GetPanel("WIDGET1"), /*oFont*/, /*lCentered*/, /*uParam7*/, /*nClrText*/, , 150 , 80, .T. )

nColCard := 2
For nI:=1 To Len(aCards)
    aCards[nI] := TPanel():New(002 , nColCard  , 'Card'+ cValToChar(nI) , oWorkArea:GetPanel("WIDGET1"), /*oFont*/, /*lCentered*/, /*uParam7*/, /*nClrText*/, , nWidthCard , nHeigthCard, .T. )
    aCards[nI]:SetCSS("QWidget { background: #f1f7f8ff; border: 1px solid white; }")

    TSay():New(01, 01, {|| aDbCards[nI, 1]}, aCards[nI])
    
    //Imagem atual
    If !Empty(aDbCards[nI, 2])
        oBmpFoto := TBitmap():New(002, 002, 60, 60, /*cResName*/, /*cBmpFile*/, /*lNoBorder*/, aCards[nI], /*bLClicked*/, /*bRClicked*/, /*lScroll*/, /*lStretch*/, /*oCursor*/, /*uParam14*/, /*uParam15*/, /*bWhen*/, .T., /*bValid*/)
        //oBmpFoto:lStretch := .T.
        oBmpFoto:Load(, aDbCards[nI, 2])
        oBmpFoto:Refresh()
    EndIf

    nColCard += nWidthCard + 5
Next nI

If nTInfoG == 200
    oBtPrevPag:= TButton():New(nHeigthCard + 3, 002, "<<"	, oWorkArea:GetPanel("WIDGET1"), {|| OnPreviousPage()	}, 20, 10, , , .F., .T., .F., , .F., , , .F. )
    oBtPrevPag:lReadOnly := .T.

    oBtNextPag:= TButton():New(nHeigthCard + 3, 025, ">>"	, oWorkArea:GetPanel("WIDGET1"), {|| OnNextPage()		}, 20, 10, , , .F., .T., .F., , .F., , , .F. )
    oBtNextPag:lReadOnly := .F.
EndIf

oDlgWA:Activate()


Return



/*/{Protheus.doc} CloseScreen
Monta tela de saída
@type function
@version 1.0 
@author erike.yuri@dothink.com.br
@since 30/06/2025
@return logical, indica se permite encerrar a tela ou não
/*/
Static Function CloseScreen()
Local oModal
Local oContainer
Local oSay := Nil
Local lRet := .F.

oModal  := FWDialogModal():New()        
oModal:SetEscClose(.T.)
oModal:setTitle("SAIR")
oModal:setSize(100, 150)
oModal:createDialog()
oModal:addYesNoButton()

oContainer := TPanel():New( ,,, oModal:getPanelMain() ) 
oContainer:Align := CONTROL_ALIGN_ALLCLIENT
    
oSay := TSay():New(4,4,{|| "Deseja realmente sair do programa? "},oContainer,,,,,,.T.,,,98,98,,,,,,.T.)

oModal:Activate()

If oModal:getButtonSelected()
    lRet := .T.
EndIf

Return lRet


/*/{Protheus.doc} OnNextPage
Navega para a próxima página
@type function
@version 1.0
@author DOTHINK - ERIKE YURI
@since 21/06/2025
/*/
Static Function OnNextPage()
    Alert("OnNextPage()")
Return

/*/{Protheus.doc} OnPreviousPage
Navega para a página anterior
@type function
@version 1.0
@author DOTHINK - ERIKE YURI
@since 21/06/2025
/*/
Static Function OnPreviousPage()
    Alert("OnPreviousPage()")
return

//-- somente para teste
Static Function GetDbCards()
    local aRet := {}

    //--- Recebimento
    Aadd(aRet, {"RECEBIMENTO", "trk-recebimento.png", {"Em pré-nota", "Em Check List", "Em Conferência", "Em Endereçamento"}, {0, 0, 0, 0}})

    //--- Expedicao
    Aadd(aRet, {"EXPEDIÇÃO", "trk-expedicao.png", {"Em pré-nota", "Em Check List", "Em Conferência", "Em Endereçamento"}, {0, 0, 0, 0}})
    
    //--- cs
    Aadd(aRet, {"CS", "", {"Validação CS"}, {6}})

    //--- Qualidade
    Aadd(aRet, {"QUALIDADE", "", {"Em pré-nota", "Em Check List", "Em Conferência", "Em Endereçamento"}, {0, 0, 0, 0}})

    //--- FATURAMENTO
    Aadd(aRet, {"FATURAMENTO", "", {"Em pré-nota", "Em Check List", "Em Conferência", "Em Endereçamento"}, {0, 0, 0, 0}})

        //--- FATURAMENTO
    Aadd(aRet, {"XXXXXX", "", {"Em pré-nota", "Em Check List", "Em Conferência", "Em Endereçamento"}, {0, 0, 0, 0}})
return aRet
