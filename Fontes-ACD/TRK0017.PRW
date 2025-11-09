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
    ADD OPTION aRot TITLE "Visualizar"      ACTION "VIEWDEF.TRK0017" OPERATION MODEL_OPERATION_VIEW    ACCESS 0
    ADD OPTION aRot TITLE "Incluir"         ACTION "VIEWDEF.TRK0017" OPERATION MODEL_OPERATION_INSERT  ACCESS 0
    ADD OPTION aRot TITLE "Alterar"         ACTION "VIEWDEF.TRK0017" OPERATION MODEL_OPERATION_UPDATE  ACCESS 0
    ADD OPTION aRot TITLE "Excluir"         ACTION "VIEWDEF.TRK0017" OPERATION MODEL_OPERATION_DELETE  ACCESS 0
    ADD OPTION aRot TITLE "SLA Adicional"   ACTION "U_TRK0017P"      OPERATION MODEL_OPERATION_UPDATE  ACCESS 0

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

/*/{Protheus.doc} TRK0017P
Ajuste do parâmetro BA_SLAOPER, que é o parametro de controle em dias do SLA da Operacao
@type function
@version 20240918
@author erike.yuri@dothink.com.br
@since 18/09/2025
@obs esta funcionalidade foi solicitada pela sra. Janine em reunião com a Fernanda, isso para não aguardar abertura de chamado com o TI.
/*/
User Function TRK0017P()
    local aArea := FWGetArea()
    local oDlg     as object
    local oPanel   as object
    local oSlaOper as object
    local nSlaOper as numeric
    local lSalva := .F. as logical

    nSlaOper := GetMV("BA_SLAOPER",.F.,2) 


    DEFINE MSDIALOG oDlg FROM 0,0 TO 100,250 TITLE "Informe parâmetro do tempo do SLA" PIXEL OF GetWNDDefault()

        @ 000,000 MSPANEL oPanel OF oDlg
        oPanel:Align:=CONTROL_ALIGN_ALLCLIENT

        @ 007,005 SAY "Informe o tempo adicional em dias de SLA" SIZE 120,20 OF oPanel PIXEL
        @ 017,005 MSGET oSlaOper VAR nSlaOper PICTURE "99" SIZE 30,08 OF oPanel PIXEL VALID Positivo(nSlaOper)

        DEFINE SBUTTON oOk     FROM 035,005 TYPE 1 ENABLE OF oPanel PIXEL ACTION (lSalva:=.T.,oDlg:End())
        DEFINE SBUTTON oCancel FROM 035,035 Type 2 ENABLE OF oPanel PIXEL ACTION oDlg:End()

        oDlg:lEscClose:=.F.

    ACTIVATE MSDIALOG oDlg CENTER ON INIT (oDlg:SetFocus())


    If lSalva
        If nSlaOper >= 0 .And. nSlaOper < 10
            PutMV("BA_SLAOPER", nSlaOper)
        Else
            FWAlertWarning("Valor informado deve ser maior que 0 e menor 10", "Valor")  
        EndIf
    EndIf

    FWRestArea(aArea)
Return


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
    local nSLAOutros := GetMV("BA_SLAOPER",.F.,2) 

    DbSelectArea("Z15")
    Z15->( DbSetOrder(1) )
    //Z15_FILIAL+Z15_UFORIG+Z15_UFDEST+Z15_MUDEST
    If Z15->( DbSeek(xFilial() + cEstOrig + cEstDest + cMumDest) )
        dRet := dEntrega - (Z15->Z15_TRANSP + nSLAOutros)
    Elseif Z15->( DbSeek(xFilial() + cEstOrig + cEstDest) )
        dRet := dEntrega - (Z15->Z15_TRANSP + nSLAOutros)
    Else
        dRet := dEntrega - nSLAOutros
    EndIf

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


/*/{Protheus.doc} TRK0017B
Processamento para atualização do status de agendamento
@type function
@since  31/08/2025
@author erike.yuri@dothink.com.br
/*/
User Function TRK0017B()

    Processa({|| ProcUpdAGT()}, "Aguarde...", "Atualizando Status Agendamento...")

Return

/*/{Protheus.doc} ProcUpdAGT
Atualizacao dos status de agendamento
@type function
@version 1.0
@author erike.yuri@dothink.com.br
@since  01/10/2025
/*/
Static Function ProcUpdAGT()
    Local cUpDate := ""
    Local cHoje   := DTOS( Date() )

    cUpDate := " UPDATE " + RetSqlName("Z09") +" SET Z09_STAAGE = (CASE WHEN "
    cUpDate += "  ( CASE "
    cUpDate += "       WHEN Z09_DC1COL >= Z09_DC2COL AND Z09_DC1COL >= Z09_DC3COL THEN Z09_DC1COL "
    cUpDate += "       WHEN Z09_DC2COL >= Z09_DC1COL AND Z09_DC2COL >= Z09_DC3COL THEN Z09_DC2COL "
    cUpDate += "       ELSE Z09_DC3COL "
    cUpDate += "   END)  > '" + cHoje + "' THEN '2' ELSE '3' END) WHERE D_E_L_E_T_ = ' ' AND Z09_STATUS = '7' "
    
    If tcsqlexec(cUpDate)
        ConOut(tcsqlerror())
    EndIf 

Return
