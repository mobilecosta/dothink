#include "totvs.ch"
#include 'FwMVCDef.ch'

// https://github.com/erikeyuri/barentz-20250528007v02/issues/4

Static cTitulo := ""        // Data Prévia de Coleta 1 / Confirmação da Primeira Coleta
Static cFields := ''

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

/*/{Protheus.doc} TRK00021
Informações da primeira coleta
@type function
@version 1.0
@author DoThink
@since 10/08/2025
/*/
User Function TRK00021(lConf)

If lConf .And. Empty(Z09->Z09_DT1COL)
    ApMsgInfo("Só é possível confirmar a coleta, se seu agendamento foi realizado !")
    Return
EndIf

If ! lConf
    aFields := { "Z09_FILIAL", "Z09_IDTRAC", "Z09_NUMPV", "Z09_ITEMPV", "Z09_STATUS",;
                 "Z09_TRANSP", "Z09_NTRANS", "Z09_DT1COL", "Z09_HR1COL", "Z09_US1COL" }
    aPos    := { 0, 0, 0, 0, 0, 0, 0, DZ09XDT1COL, CZ09XHR1COL, CZ09XUS1COL }
    cTitulo := "Data Prévia da Coleta 1"
Else
    aFields := { "Z09_FILIAL", "Z09_IDTRAC", "Z09_NUMPV", "Z09_ITEMPV", "Z09_STATUS",;
                 "Z09_TRANSP", "Z09_NTRANS", "Z09_DC1COL", "Z09_HC1COL", "Z09_UC1COL" }
    aPos    := { 0, 0, 0, 0, 0, 0, 0, DZ09XDC1COL, CZ09XHC1COL, CZ09XUC1COL }
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
    aFields := { "Z09_FILIAL", "Z09_IDTRAC", "Z09_NUMPV", "Z09_ITEMPV", "Z09_STATUS",;
                 "Z09_TRANSP", "Z09_NTRANS", "Z09_DT2COL", "Z09_HR2COL", "Z09_US2COL" }
    aPos    := { 0, 0, 0, 0, 0, 0, 0, DZ09XDT2COL, CZ09XHR2COL, CZ09XUS2COL }
    cTitulo := "Data Prévia da Coleta 2"
Else
    aFields := { "Z09_FILIAL", "Z09_IDTRAC", "Z09_NUMPV", "Z09_ITEMPV", "Z09_STATUS",;
                 "Z09_TRANSP", "Z09_NTRANS", "Z09_DC2COL", "Z09_HC2COL", "Z09_UC2COL" }
    aPos    := { 0, 0, 0, 0, 0, 0, 0, DZ09XDC2COL, CZ09XHC2COL, CZ09XUC2COL }
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
    aFields := { "Z09_FILIAL", "Z09_IDTRAC", "Z09_NUMPV", "Z09_ITEMPV", "Z09_STATUS",;
                 "Z09_TRANSP", "Z09_NTRANS", "Z09_DT3COL", "Z09_HR3COL", "Z09_US3COL" }
    aPos    := { 0, 0, 0, 0, 0, 0, 0, DZ09XDT3COL, CZ09XHR3COL, CZ09XUS3COL }
    cTitulo := "Data Prévia da Coleta 3"
Else
    aFields := { "Z09_FILIAL", "Z09_IDTRAC", "Z09_NUMPV", "Z09_ITEMPV", "Z09_STATUS",;
                 "Z09_TRANSP", "Z09_NTRANS", "Z09_DC3COL", "Z09_HC3COL", "Z09_UC3COL" }
    aPos    := { 0, 0, 0, 0, 0, 0, 0, DZ09XDC3COL, CZ09XHC3COL, CZ09XUC3COL }
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
