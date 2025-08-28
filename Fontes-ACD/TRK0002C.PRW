#include "totvs.ch"
#include 'FwMVCDef.ch'

// https://github.com/erikeyuri/barentz-20250528007v02/issues/4

Static cTitulo := ""        // Data Prévia de Coleta 1 / Confirmação da Primeira Coleta
Static cFields := ''


/*/{Protheus.doc} TRK00021
Informações da primeira coleta
@type function
@version 1.0
@author DoThink
@since 10/08/2025
/*/
User Function TRK00021(lConf)

If Z09->Z09_STATUS <> '4'
    ApMsgInfo("Só é possível realizar agendamento estando na etapa [4="+ X3Combo("Z09_STATUS", "4") +"], e o registro posicionado esta na etapa [" + Z09->Z09_STATUS+ "="+ X3Combo("Z09_STATUS", Z09->Z09_STATUS) +"].")
    Return
EndIf

If lConf .And. Empty(Z09->Z09_DT1COL)
    ApMsgInfo("Só é possível confirmar a coleta, se seu agendamento foi realizado !")
    Return
EndIf

If ! lConf
    aFields := { "Z09_FILIAL", "Z09_IDTRAC", "Z09_RESTR", "Z09_NUMPV", "Z09_ITEMPV", "Z09_STATUS",;
                 "Z09_TRANSP", "Z09_NTRANS", "Z09_ORDCOL","Z09_DT1COL", "Z09_HR1COL", "Z09_US1COL" }
    aPos    := { 0, 0, 0, 0, 0, 0, 0, 0, Z09->(FieldPos("Z09_ORDCOL")), Z09->(FieldPos("Z09_DT1COL")), Z09->(FieldPos("Z09_HR1COL")), Z09->(FieldPos("Z09_US1COL")) }
    cTitulo := "Data Prévia da Coleta 1"
Else
    aFields := { "Z09_FILIAL", "Z09_IDTRAC", "Z09_RESTR", "Z09_NUMPV", "Z09_ITEMPV", "Z09_STATUS",;
                 "Z09_TRANSP", "Z09_NTRANS", "Z09_ORDCOL", "Z09_DC1COL", "Z09_HC1COL", "Z09_UC1COL" }
    aPos    := { 0, 0, 0, 0, 0, 0, 0, 0, Z09->(FieldPos("Z09_ORDCOL")), Z09->(FieldPos("Z09_DC1COL")), Z09->(FieldPos("Z09_HC1COL")), Z09->(FieldPos("Z09_UC1COL")) }
    cTitulo := "Confirmação da Primeira Coleta"
EndIf

GetColeta()

Return

/*/{Protheus.doc} TRK00022
Informações da segunda coleta
@type function
@version 1.0
@author DoThink
@since 10/08/2025
/*/
User Function TRK00022(lConf)

If Z09->Z09_STATUS <> '4'
    ApMsgInfo("Só é possível realizar agendamento estando na etapa [4="+ X3Combo("Z09_STATUS", "4") +"], e o registro posicionado esta na etapa [" + Z09->Z09_STATUS+ "="+ X3Combo("Z09_STATUS", Z09->Z09_STATUS) +"].")
    Return
EndIf

If lConf .And. Empty(Z09->Z09_DT2COL)
    ApMsgInfo("Só é possível confirmar a coleta, se seu agendamento foi realizado !")
    Return
EndIf

If Empty(Z09->Z09_DT1COL) //.Or. Empty(Z09->Z09_DC1COL)
    ApMsgInfo("A segunda coleta só pode ser informada, após a primeira ser informada !")

    Return
EndIf

If !Empty(Z09->Z09_DC1COL)
    ApMsgInfo("A segunda coleta só pode ser informada, se não for confirmada a primeira coleta !")
    Return
EndIf

If ! lConf
    aFields := { "Z09_FILIAL", "Z09_IDTRAC", "Z09_RESTR", "Z09_NUMPV", "Z09_ITEMPV", "Z09_STATUS",;
                 "Z09_TRANSP", "Z09_NTRANS", "Z09_DT2COL", "Z09_HR2COL", "Z09_US2COL" }
    aPos    := { 0, 0, 0, 0, 0, 0, 0, 0, Z09->(FieldPos("Z09_DT2COL")), Z09->(FieldPos("Z09_HR2COL")), Z09->(FieldPos("Z09_US2COL")) }
    cTitulo := "Data Prévia da Coleta 2"
Else
    aFields := { "Z09_FILIAL", "Z09_IDTRAC", "Z09_RESTR", "Z09_NUMPV", "Z09_ITEMPV", "Z09_STATUS",;
                 "Z09_TRANSP", "Z09_NTRANS", "Z09_DC2COL", "Z09_HC2COL", "Z09_UC2COL" }
    aPos    := { 0, 0, 0, 0, 0, 0, 0, 0, Z09->(FieldPos("Z09_DC2COL")), Z09->(FieldPos("Z09_HC2COL")), Z09->(FieldPos("Z09_UC2COL")) }
    cTitulo := "Confirmação da Segunda Coleta"
EndIf

GetColeta()

Return


/*/{Protheus.doc} TRK00023
Informações da terceira coleta
@type function
@version 1.0
@author DoThink
@since 10/08/2025
/*/
User Function TRK00023(lConf)

If Z09->Z09_STATUS <> '4'
    ApMsgInfo("Só é possível realizar agendamento estando na etapa [4="+ X3Combo("Z09_STATUS", "4") +"], e o registro posicionado esta na etapa [" + Z09->Z09_STATUS+ "="+ X3Combo("Z09_STATUS", Z09->Z09_STATUS) +"].")
    Return
EndIf

If lConf .And. Empty(Z09->Z09_DT3COL)
    ApMsgInfo("Só é possível confirmar a coleta, se seu agendamento foi realizado !")
    Return
EndIf

If Empty(Z09->Z09_DT2COL) //.Or. Empty(Z09->Z09_DC2COL)
    ApMsgInfo("A terceira coleta só pode ser informada, após a segunda ser informada !")
    Return
EndIf

If !Empty(Z09->Z09_DC2COL)
    ApMsgInfo("A terceira coleta só pode ser informada, se não for confirmada a segunda coleta !")
    Return
EndIf

If ! lConf
    aFields := { "Z09_FILIAL", "Z09_IDTRAC", "Z09_RESTR", "Z09_NUMPV", "Z09_ITEMPV", "Z09_STATUS",;
                 "Z09_TRANSP", "Z09_NTRANS", "Z09_DT3COL", "Z09_HR3COL", "Z09_US3COL" }
    aPos    := { 0, 0, 0, 0, 0, 0, 0, 0, Z09->(FieldPos("Z09_DT3COL")), Z09->(FieldPos("Z09_HR3COL")), Z09->(FieldPos("Z09_US3COL")) }
    cTitulo := "Data Prévia da Coleta 3"
Else
    aFields := { "Z09_FILIAL", "Z09_IDTRAC", "Z09_RESTR", "Z09_NUMPV", "Z09_ITEMPV", "Z09_STATUS",;
                 "Z09_TRANSP", "Z09_NTRANS", "Z09_DC3COL", "Z09_HC3COL", "Z09_UC3COL" }
    aPos    := { 0, 0, 0, 0, 0, 0, 0, 0, Z09->(FieldPos("Z09_DC3COL")), Z09->(FieldPos("Z09_HC3COL")), Z09->(FieldPos("Z09_UC3COL"))  }
    cTitulo := "Confirmação da terceira Coleta"
EndIf

GetColeta()

Return

Static Function GetColeta

Local nFields := 1

cFields := ""
For nFields := 1 To Len(aFields) - 1
    cFields += aFields[nFields] + "|"
Next

lAgenda := .T.

FWExecView(cTitulo,'TRK0002C', MODEL_OPERATION_UPDATE)

lAgenda := .F.

Return

Static Function ViewDef()
    Local oModel := Nil
    Local oStZ09 := Nil
    Local oView  := Nil
 
    U_TRK02FL(AClone(aFields), AClone(aPos), 'TRK0002C', cTitulo)

    oModel := FWLoadModel("TRK0002")
    oStZ09 := FWFormStruct(2, "Z09", { |cCampo| AllTrim(cCampo) $ cFields})

    //Criando a view que será o retorno da função e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)

    //Atribuindo formulários para interface
    oView:AddField("VIEW_Z09", oStZ09, "FORMZ09")
     
    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox("TELA",100)
     
    //Colocando título do formulário
    oView:EnableTitleView('VIEW_Z09', cTitulo )  
     
    //Força o fechamento da janela na confirmação
    oView:SetCloseOnOk({||.T.})
     
    //O formulário da interface será colocado dentro do container
    oView:SetOwnerView("VIEW_Z09","TELA")
Return oView
