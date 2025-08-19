#include "totvs.ch"
#include "fwmvcdef.ch"

//-- Variveis Estaticas
Static cTitulo   := "Tabelas Genéricas"
Static cAliasMVC := "SX5"


/*/{Protheus.doc} TRK0008
Rotina de Cadastro de Tabela Generica SX5
@type function
@version 1.0
@author DO THINK - DENER LEMOS  
@since 22/07/2025
@param nOrigem, numeric, Origem da chamada (1=Chamada pelo Codigo e Modelo MM, 2=Chamada pelo Menu)
@param cTabela, character, Tabela Generica
/*/
User Function TRK0008(nOrigem, cTabela)
    Local aAreaAnt  := GetArea()
    Local aInfoCab  := {}
    Local aColunas  := {}
	Local oDlg      := Nil
	Local oPanel    := Nil
	Local oBrowse   := Nil

    Private aRotina := {}
    Private cTabGen := ""

    Default nOrigem := 2
    Default cTabela := ""

    //-- Somente se tiver tabela
    If !Empty(cTabela)
        If nOrigem == 1
            oDlg := FWDialogModal():new()
            oDlg:setBackground(.T.)
            oDlg:setEscClose(.F.)
            oDlg:setSize(270, 580)
            oDlg:enableFormBar(.T.)

            oDlg:createDialog()
            oPanel := oDlg:getPanelMain()
            oDlg:addCloseButton()
            oDlg:setEscClose(.T.)
        EndIf

        //-- Atualiza a tabela em uso e o titulo
        cTabGen := cTabela
 
        //-- Se o titulo tiver vazio, busca do cadastro do cabecalho da tabela
        aInfoCab := FWGetSX5("00", cTabGen)
        cTitulo  := Alltrim(Capital(aInfoCab[1][4]))
  
        //-- Adiciona as colunas que vao ser apresentadas no browse
        aAdd(aColunas, {"Código",    "X5_CHAVE",  "C", TamSX3("X5_CHAVE")[1],  0, ""})
        aAdd(aColunas, {"Descrição", "X5_DESCRI", "C", TamSX3("X5_DESCRI")[1], 0, ""})
 
        //-- Instanciando o browse
        oBrowse := FWMBrowse():new()
        oBrowse:setAlias(cAliasMVC)
        oBrowse:setDescription(cTitulo)
        oBrowse:setOnlyFields({"X5_FILIAL"})
        oBrowse:setFields(aColunas)
        oBrowse:setFilterDefault("SX5->X5_TABELA == '" + cTabGen + "'")
        If nOrigem == 1
            oBrowse:setOwner(oPanel)
        EndIf
        oBrowse:setMainProc("trk0008")
        oBrowse:setMenuDef("trk0008")
        oBrowse:disableReport()
        oBrowse:disableDetails()
 
        //-- Ativa a Browse
        oBrowse:Activate()

        If nOrigem == 1
            oDlg:activate()
        EndIf
    EndIf
 
    RestArea(aAreaAnt)

Return


/*/{Protheus.doc} MenuDef
MenuDef
@type function
@version 1.0
@author DO THINK - DENER LEMOS  
@since 22/07/2025
/*/
Static Function MenuDef()
    Local aRotina := {}
 
    ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.trk0008" OPERATION 1 ACCESS 0
    ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.trk0008" OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.trk0008" OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.trk0008" OPERATION 5 ACCESS 0
 
Return aRotina


/*/{Protheus.doc} ModelDef
ModelDef
@type function
@version 1.0
@author DO THINK - DENER LEMOS  
@since 22/05/2024
/*/
Static Function ModelDef()
    Local oStruct := FWFormStruct(1, cAliasMVC)
    Local oModel
    Local bPre := Nil
    Local bPos := {|| u_trk0008a()}
    Local bCancel := Nil
 
    //-- Editando características do dicionário
    oStruct:SetProperty("X5_TABELA", MODEL_FIELD_WHEN   , FwBuildFeature(STRUCT_FEATURE_WHEN  , ".F.")) 
    oStruct:SetProperty("X5_TABELA", MODEL_FIELD_INIT   , FwBuildFeature(STRUCT_FEATURE_INIPAD, "cTabGen"))
    oStruct:SetProperty("X5_CHAVE" , MODEL_FIELD_WHEN   , FwBuildFeature(STRUCT_FEATURE_WHEN  , "Iif(INCLUI, .T., .F.)"))
    oStruct:SetProperty("X5_CHAVE" , MODEL_FIELD_VALID  , FwBuildFeature(STRUCT_FEATURE_VALID , "u_trk0008a()"))
    oStruct:SetProperty("X5_CHAVE" , MODEL_FIELD_OBRIGAT, .T.)
    oStruct:SetProperty("X5_DESCRI", MODEL_FIELD_OBRIGAT, .T.)
 
    //-- Cria o modelo de dados para cadastro
    oModel := MPFormModel():New("xtrk0008", bPre, bPos, /*bCommit*/, bCancel)
    oModel:AddFields("SX5MASTER", /*cOwner*/, oStruct)
    oModel:SetPrimaryKey({"X5_FILIAL", "X5_TABELA", "X5_CHAVE"})
    oModel:SetDescription("Modelo de dados - " + cTitulo)
    oModel:GetModel("SX5MASTER"):SetDescription( "Dados de - " + cTitulo)
    oModel:SetPrimaryKey({})

Return oModel


/*/{Protheus.doc} ViewDef
ViewDef
@type function
@version 1.0
@author DO THINK - DENER LEMOS  
@since 22/05/2024
/*/
Static Function ViewDef()
    Local cCampos := "X5_CHAVE|X5_DESCRI|"
    Local oModel      := FWLoadModel("trk0008")
    Local oStructPrin := FWFormStruct(2, cAliasMVC, {|cCpo| AllTrim(cCpo) $ cCampos})
    Local oStructOutr := FWFormStruct(2, cAliasMVC, {|cCpo| ! AllTrim(cCpo) $ cCampos})
    Local oView
 
    //-- Retira as abas padroes
    oStructPrin:setNoFolder()
    oStructOutr:setNoFolder()
 
    //-- Altera o titulo dos campos principais
    oStructPrin:setProperty("X5_CHAVE",   MVC_VIEW_TITULO, "Código")
    oStructPrin:setProperty("X5_DESCRI",  MVC_VIEW_TITULO, "Descrição")
 
    //-- Altera o titulo dos outros campos
    oStructOutr:setProperty("X5_TABELA",  MVC_VIEW_TITULO, "Código Interno Tabela")
    oStructOutr:setProperty("X5_DESCSPA", MVC_VIEW_TITULO, "Descrição Espanhol")
    oStructOutr:setProperty("X5_DESCENG", MVC_VIEW_TITULO, "Descrição Inglês")
  
    //-- Cria a visualizacao do cadastro
    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("VIEW_PRIN", oStructPrin, "SX5MASTER")
    oView:AddField("VIEW_OUTR", oStructOutr, "SX5MASTER")
  
    //-- Cria o controle de Abas
    oView:CreateFolder("ABAS")
    oView:AddSheet("ABAS", "ABA_PRIN", "Cadastro")
    oView:AddSheet("ABAS", "ABA_OUTR", "Outros Campos")
  
    //-- Cria os Box que serao vinculados as abas
    oView:CreateHorizontalBox("BOX_PRIN", 100, /*owner*/, /*lUsePixel*/, "ABAS", "ABA_PRIN")
    oView:CreateHorizontalBox("BOX_OUTR", 100, /*owner*/, /*lUsePixel*/, "ABAS", "ABA_OUTR")
  
    //-- Amarra as Abas aos Views de Struct criados
    oView:SetOwnerView("VIEW_PRIN", "BOX_PRIN")
    oView:SetOwnerView("VIEW_OUTR", "BOX_OUTR")
 
Return oView


/*/{Protheus.doc} trk0008a
Rotina que valida a digitacao do campo Chave, para verificar se ja existe
@type function
@version 1.0
@author DO THINK - DENER LEMOS  
@since 22/05/2024
/*/
User Function trk0008a()
    Local aArea    := GetArea()
    Local lRet     := .T.
    Local cX5Chave := FWFldGet("X5_CHAVE")
    Local oModel   := FWModelActive()
    Local nOper    := oModel:GetOperation()
 
    //-- Se for operacao de inclusao
    If nOper == 3
        dbSelectArea('SX5')
        SX5->(dbSetOrder(1)) //-- X5_FILIAL+X5_TABELA+X5_CHAVE
        SX5->(dbGoTop())

        //-- Se conseguir posicionar, já existe
        If SX5->(DbSeek(FWxFilial("SX5") + cTabGen + cX5Chave))
            ExibeHelp("Help", "Código já existe!", "Informe um código diferente.")
            lRet := .F.
        EndIf
    EndIf

    RestArea(aArea)

Return lRet


User Function trk0008b()
Return u_TRK0008(1, "Z0")
