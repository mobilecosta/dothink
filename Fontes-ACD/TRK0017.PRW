//Bibliotecas
#Include "Protheus.ch"
#Include "FWMVCDef.ch"

//------------------------------------------------------------------------------
// Variaveis estaticas
//------------------------------------------------------------------------------
Static cTitulo := "Transporte por origem e destino"

/*/{Protheus.doc} TRK0017
Rotina MVC (Modelo 1) para manter a tabela Z15 (transit time por UF origem/destino).
@author  Fernando B. Muta
@since   31/08/2025
@version 1.1
/*/
User Function TRK0017()
    Local aArea   := GetArea()
    Local oBrowse := FWMBrowse():New()

    // Alias/Tabela principal do cadastro
    oBrowse:SetAlias("Z15")

    // Titulo do browse
    oBrowse:SetDescription(cTitulo)

    // Ativa o browse padrao (barra com Incluir/Alterar/Outras Acoes)
    oBrowse:Activate()

    RestArea(aArea)
Return Nil

//------------------------------------------------------------------------------
// MenuDef - mapeia as operacoes da barra (Visualizar/Incluir/Alterar) para a View
//------------------------------------------------------------------------------
Static Function MenuDef()
    Local aRot := {}

    // As tres opcoes abaixo habilitam as acoes da barra
    ADD OPTION aRot TITLE "Visualizar" ACTION "VIEWDEF.TRK0017" OPERATION MODEL_OPERATION_VIEW    ACCESS 0
    ADD OPTION aRot TITLE "Incluir"    ACTION "VIEWDEF.TRK0017" OPERATION MODEL_OPERATION_INSERT  ACCESS 0
    ADD OPTION aRot TITLE "Alterar"    ACTION "VIEWDEF.TRK0017" OPERATION MODEL_OPERATION_UPDATE  ACCESS 0
    ADD OPTION aRot TITLE "Excluir"    ACTION "VIEWDEF.TRK0017" OPERATION MODEL_OPERATION_DELETE  ACCESS 0

Return aRot

//------------------------------------------------------------------------------
// ModelDef - regras de negocio / persistencia
//------------------------------------------------------------------------------
Static Function ModelDef()
    Local oModel  := Nil
    Local oStZ15  := FWFormStruct(1, "Z15") // estrutura para o Model (nivel 1)

    // ID do Model
    oModel := MPFormModel():New("TRK0017M", /*bPre*/, /*bPos*/, /*bCommit*/, /*bCancel*/)

    // Componente principal do Model
    oModel:AddFields("FORMZ15", /*cOwner*/, oStZ15)

    // Chave primaria 
    oModel:SetPrimaryKey({"Z15_FILIAL","Z15_UFORIG","Z15_UFDEST","Z15_MUDEST"})

    // Descricoes
    oModel:SetDescription("Modelo de dados do cadastro " + cTitulo)
    oModel:GetModel("FORMZ15"):SetDescription("Dados " + cTitulo)

Return oModel

//------------------------------------------------------------------------------
// ViewDef - interface (formulario) vinculada ao Model
//------------------------------------------------------------------------------
Static Function ViewDef()
    Local oModel := FWLoadModel("TRK0017")  
    Local oView  := FWFormView():New()
    Local oStZ15 := FWFormStruct(2, "Z15")  

    // VINCULA A VIEW AO MODEL 
    oView:SetModel(oModel)

    // Formulario principal
    oView:AddField("VIEW_Z15", oStZ15, "FORMZ15")

    // Layout basico
    oView:CreateHorizontalBox("TELA", 100)
    oView:EnableTitleView("VIEW_Z15", cTitulo)
    oView:SetCloseOnOk({|| .T.})
    oView:SetOwnerView("VIEW_Z15", "TELA")

Return oView

/*/{Protheus.doc} TRK0017S
Atualizacao do SLA
@type function
@version 1.0
@author fernando.muta@dothink.com.br
@since  31/08/2025
@return variant, Z09_DTSLA Z09_DPEMPV
/*/
User Function TRK0017S(cEstOrig, cEstDest, cMumDest, dEntrega)
    local dRet 
    local nSLAOutros := SuperGetMV("BA_SLAOPER",,1) 

    DbSelectArea("Z15")
    Z15->( DbSetOrder(1) )
    //Z15_FILIAL+Z15_UFORIG+Z15_UFDEST+Z15_MUDEST
    If Z15->( DbSeek(xFilial() + cEstOrig + cEstDest + cMumDest) )
        dRet := dEntrega - (Z15->Z15_TRANSP + nSLAOutros)
    Elseif Z15->( DbSeek(xFilial() + cEstOrig + cEstDest) )
        dRet := dEntrega - (Z15->Z15_TRANSP + nSLAOutros)
    Else
        dRet := dEntrega
    EndIf

    dRet -= nSLAOutros

Return dRet
