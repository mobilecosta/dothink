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
Atualizacao de data do SLA
@type function
@version 1.0
@author fernando.muta@dothink.com.br
@since  31/08/2025
@param cEstOrig, character, estado origem (filial)
@param cEstDest, character, estado destino
@param cMumDest, character, codigo do municio de destino
@param dEntrega, date, data de entrega prometida para o cliente
@return date, data limite da operacao (Z09_DTSLA Z09_DPEMPV)
/*/
User Function TRK0017S(cEstOrig, cEstDest, cMumDest, dEntrega)
    local aArea     := GetArea()
    local dRet 
    local nSLAOutros := SuperGetMV("BA_SLAOPER",,1) 

    If ! AliasInDic("Z15")
        Return dDataBase
    EndIf

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
    RestArea(aArea)
Return dRet

/*/{Protheus.doc} TRK0017A
Processamento para atualização dos emogis dos SLA´s
@type function
@since  31/08/2025
@author erike.yuri@dothink.com.br
/*/
User Function TRK0017A()

    Processa({|| ProcUpdSLA()}, "Aguarde...", "Atualizando SLA...")

Return

/*/{Protheus.doc} ProcUpdSLA
Atualizacao dos emogis dos SLAs
@type function
@version 1.0
@author erike.yuri@dothink.com.br
@since  31/08/2025
/*/
Static Function ProcUpdSLA()
    Local cUpDate := ""
    Local cHoje   := DTOS( Date() )

    cUpDate := " UPDATE " + RetSqlName("Z09") 
    cUpDate += " SET Z09_SLA = (CASE "
    cUpDate += "    WHEN Z09_DTSLA > Z09_DPEMPV THEN '1' "
    cUpDate += "    WHEN Z09_DTSLA = Z09_DPEMPV THEN '2' "
    cUpDate += "    WHEN Z09_DTSLA < Z09_DPEMPV OR Z09_DTSLA < '" + cHoje + "' THEN '3' "
    cUpDate += "  END), "
    cUpDate += " Z09_DSLATM = '" + cHoje + "' "
    cUpDate += " WHERE D_E_L_E_T_ = ' ' "
    cUpDate += " AND Z09_STATUS < '8' "
    cUpDate += " AND Z09_DSLATM < '" + cHoje + "' "
    
    If tcsqlexec(cUpDate)
        ConOut(tcsqlerror())
    EndIf 

Return


User Function xTstSLAD()
     Processa({|| ProcIniSLA()}, "Aguarde...", "Atualizando SLA...")
Return

Static Function ProcIniSLA()
    local aData := {}
    local cFilInfo := ""

    DbSelectArea("SA1")
    SA1->( DbSetOrder(1) )

    DbSelectArea("Z09")
    Z09->( DbSetorder(1) )
    Z09->( DbSeek("04") )
    While Z09->( !Eof() )

        If cFilInfo <> Z09->Z09_FILIAL
            fInfo(@aData, Z09->Z09_FILIAL)
            cFilInfo := Z09->Z09_FILIAL
        EndIf

        If SA1->( DbSeek(xFilial() + Z09->(Z09_CLIENT + Z09_LOJA) ) )        
            
            RecLock("Z09", .F.)
            Z09->Z09_DTSLA := u_TRK0017S(aData[6], SA1->A1_EST, SA1->A1_COD_MUN, Z09->Z09_DPEMPV)
            Z09->( MsUnLock() )
        EndIf
        Z09->( DbSkip() )
    End

Return
