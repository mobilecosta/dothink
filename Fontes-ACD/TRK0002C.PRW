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

If Z09->Z09_ACAOCS == "2"
    FWAlertWarning("Aguardando Ação CS!", "Aguardando CS")  
    Return
EndIf

If Z09->Z09_ACAOCS == "4"
    FWAlertWarning("Solicitação de Cancelamento CS!", "Cancelamento CS")  
    Return
EndIf

If Z09->Z09_STATUS <> '4'
    FWAlertWarning("Só é possível realizar agendamento estando na etapa [<strong>4="+ X3Combo("Z09_STATUS", "4") +"</strong>], e o registro posicionado esta na etapa [<strong>" + Z09->Z09_STATUS+ "="+ X3Combo("Z09_STATUS", Z09->Z09_STATUS) +"</strong>].", "Fora da Etapa de Agendamento")  
    Return
EndIf

If lConf .And. Empty(Z09->Z09_DT1COL)
    FWAlertWarning("Só é possível confirmar a coleta, se seu agendamento foi realizado !", "Confirmação Coleta")                
    Return
EndIf

If !Empty(Z09->Z09_PVTRIA) .And. !Empty(Z09->Z09_PVREME)
    If Z09->Z09_NUMPV == Z09->Z09_PVTRIA
        FWAlertWarning("Só é possível realizar agendamento, a partir do pedido de remessa [<strong>"+Z09->Z09_PVREME+"</strong>]. Favor verificar!", "Pedido Triangular")                
        Return
    EndIf
EndIf

If ! lConf
    aFields := { "Z09_FILIAL", "Z09_IDTRAC", "Z09_RESTR", "Z09_OBSPV", "Z09_NUMPV", "Z09_ITEMPV", "Z09_STATUS",;
                 "Z09_TRANSP", "Z09_NTRANS", "Z09_ORDCOL","Z09_DT1COL", "Z09_HR1COL", "Z09_US1COL" }
    aPos    := { 0, 0, 0, 0, 0, 0, 0, 0, 0, Z09->(FieldPos("Z09_ORDCOL")), Z09->(FieldPos("Z09_DT1COL")), Z09->(FieldPos("Z09_HR1COL")), Z09->(FieldPos("Z09_US1COL")) }
    cTitulo := "Data Prévia da Coleta 1"
Else
    aFields := { "Z09_FILIAL", "Z09_IDTRAC", "Z09_RESTR", "Z09_OBSPV", "Z09_NUMPV", "Z09_ITEMPV", "Z09_STATUS",;
                 "Z09_TRANSP", "Z09_NTRANS", "Z09_ORDCOL", "Z09_DC1COL", "Z09_HC1COL", "Z09_UC1COL" }
    aPos    := { 0, 0, 0, 0, 0, 0, 0, 0, 0, Z09->(FieldPos("Z09_ORDCOL")), Z09->(FieldPos("Z09_DC1COL")), Z09->(FieldPos("Z09_HC1COL")), Z09->(FieldPos("Z09_UC1COL")) }
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

If Z09->Z09_ACAOCS == "2"
    FWAlertWarning("Aguardando Ação CS!", "Aguardando CS")  
    Return
EndIf

If Z09->Z09_ACAOCS == "4"
    FWAlertWarning("Solicitação de Cancelamento CS!", "Cancelamento CS")  
    Return
EndIf

If Z09->Z09_STATUS <> '4'
    FWAlertWarning("Só é possível realizar agendamento estando na etapa [<strong>4="+ X3Combo("Z09_STATUS", "4") +"</strong>], e o registro posicionado esta na etapa [<strong>" + Z09->Z09_STATUS+ "="+ X3Combo("Z09_STATUS", Z09->Z09_STATUS) +"</strong>].", "Fora da Etapa de Agendamento")  
    Return
EndIf

If lConf .And. Empty(Z09->Z09_DT2COL)
    FWAlertWarning("Só é possível confirmar a coleta, se seu agendamento foi realizado !", "Confirmação Coleta")   
    Return
EndIf

If !Empty(Z09->Z09_PVTRIA) .And. !Empty(Z09->Z09_PVREME)
    If Z09->Z09_NUMPV == Z09->Z09_PVTRIA
        FWAlertWarning("Só é possível realizar agendamento, a partir do pedido de remessa [<strong>"+Z09->Z09_PVREME+"</strong>]. Favor verificar!", "Pedido Triangular")                
        Return
    EndIf
EndIf

If Empty(Z09->Z09_DT1COL)
    FWAlertWarning("A segunda coleta só pode ser informada, após a primeira ser informada !", "Agendamento Coleta")  
    Return
EndIf

If !Empty(Z09->Z09_DC1COL)
    ApMsgInfo("A segunda coleta só pode ser informada, se não for confirmada a primeira coleta !")
    Return
EndIf

If ! lConf
    aFields := { "Z09_FILIAL", "Z09_IDTRAC", "Z09_RESTR", "Z09_OBSPV", "Z09_NUMPV", "Z09_ITEMPV", "Z09_STATUS",;
                 "Z09_TRANSP", "Z09_NTRANS", "Z09_DT2COL", "Z09_HR2COL", "Z09_US2COL" }
    aPos    := { 0, 0, 0, 0, 0, 0, 0, 0, 0, Z09->(FieldPos("Z09_DT2COL")), Z09->(FieldPos("Z09_HR2COL")), Z09->(FieldPos("Z09_US2COL")) }
    cTitulo := "Data Prévia da Coleta 2"
Else
    aFields := { "Z09_FILIAL", "Z09_IDTRAC", "Z09_RESTR", "Z09_OBSPV", "Z09_NUMPV", "Z09_ITEMPV", "Z09_STATUS",;
                 "Z09_TRANSP", "Z09_NTRANS", "Z09_DC2COL", "Z09_HC2COL", "Z09_UC2COL" }
    aPos    := { 0, 0, 0, 0, 0, 0, 0, 0, 0, Z09->(FieldPos("Z09_DC2COL")), Z09->(FieldPos("Z09_HC2COL")), Z09->(FieldPos("Z09_UC2COL")) }
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

If Z09->Z09_ACAOCS == "2"
    FWAlertWarning("Aguardando Ação CS!", "Aguardando CS")  
    Return
EndIf

If Z09->Z09_ACAOCS == "4"
    FWAlertWarning("Solicitação de Cancelamento CS!", "Cancelamento CS")  
    Return
EndIf

If Z09->Z09_STATUS <> '4'
    FWAlertWarning("Só é possível realizar agendamento estando na etapa [<strong>4="+ X3Combo("Z09_STATUS", "4") +"</strong>], e o registro posicionado esta na etapa [<strong>" + Z09->Z09_STATUS+ "="+ X3Combo("Z09_STATUS", Z09->Z09_STATUS) +"</strong>].", "Fora da Etapa de Agendamento")  
    Return
EndIf

If lConf .And. Empty(Z09->Z09_DT3COL)
    FWAlertWarning("Só é possível confirmar a coleta, se seu agendamento foi realizado !", "Confirmação Coleta")   
    Return
EndIf

If !Empty(Z09->Z09_PVTRIA) .And. !Empty(Z09->Z09_PVREME)
    If Z09->Z09_NUMPV == Z09->Z09_PVTRIA
        FWAlertWarning("Só é possível realizar agendamento, a partir do pedido de remessa [<strong>"+Z09->Z09_PVREME+"</strong>]. Favor verificar!", "Pedido Triangular")                
        Return
    EndIf
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
    aFields := { "Z09_FILIAL", "Z09_IDTRAC", "Z09_RESTR", "Z09_OBSPV", "Z09_NUMPV", "Z09_ITEMPV", "Z09_STATUS",;
                 "Z09_TRANSP", "Z09_NTRANS", "Z09_DT3COL", "Z09_HR3COL", "Z09_US3COL" }
    aPos    := { 0, 0, 0, 0, 0, 0, 0, 0, 0, Z09->(FieldPos("Z09_DT3COL")), Z09->(FieldPos("Z09_HR3COL")), Z09->(FieldPos("Z09_US3COL")) }
    cTitulo := "Data Prévia da Coleta 3"
Else
    aFields := { "Z09_FILIAL", "Z09_IDTRAC", "Z09_RESTR", "Z09_OBSPV", "Z09_NUMPV", "Z09_ITEMPV", "Z09_STATUS",;
                 "Z09_TRANSP", "Z09_NTRANS", "Z09_DC3COL", "Z09_HC3COL", "Z09_UC3COL" }
    aPos    := { 0, 0, 0, 0, 0, 0, 0, 0, 0, Z09->(FieldPos("Z09_DC3COL")), Z09->(FieldPos("Z09_HC3COL")), Z09->(FieldPos("Z09_UC3COL"))  }
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


User Function TRK00025()
local aArea   := GetArea()
local dDtAgen := nil
local dDtConf := nil
local nPosRec := 0
local nI      := 0
local cChave  := ""
local cTransp := ""
local aPVs    := {}
local aTrackS := {}

If Z09->Z09_ACAOCS == "2"
    FWAlertWarning("Aguardando Ação CS!", "Aguardando CS")  
    Return
EndIf

If Z09->Z09_STATUS <> '4'
    FWAlertWarning("Só é possível realizar cancelamento do agendamento estando na etapa [<strong>4="+ X3Combo("Z09_STATUS", "4") +"</strong>], e o registro posicionado esta na etapa [<strong>" + Z09->Z09_STATUS+ "="+ X3Combo("Z09_STATUS", Z09->Z09_STATUS) +"</strong>].", "Fora da Etapa de Agendamento")  
    Return
EndIf

If !Empty(Z09->Z09_DT3COL)
    dDtAgen := Z09->Z09_DT3COL
EndIf

If !Empty(Z09->Z09_DC3COL)
    dDtConf := Z09->Z09_DC3COL
EndIf

If Empty(dDtAgen) .And. !Empty(Z09->Z09_DT2COL)
    dDtAgen := Z09->Z09_DT2COL
EndIf

If Empty(dDtConf) .And. !Empty(Z09->Z09_DC2COL)
    dDtConf :=  Z09->Z09_DC2COL
EndIf

If Empty(dDtAgen) .And. !Empty(Z09->Z09_DT1COL)
    dDtAgen := Z09->Z09_DT1COL
EndIf

If Empty(dDtConf) .And. !Empty(Z09->Z09_DC1COL)
    dDtConf :=  Z09->Z09_DC1COL
EndIf

If Empty(dDtAgen) .And. Empty(dDtConf) 
    FWAlertWarning("Não é possível realizar cancelamento pois não existe agendamento", "Sem Agendamento")  
    Return
Endif

If !FwAlertYesNo("Deseja realizar o cancelamento do agendamento previsto para o dia ["+DtoC(dDtAgen)+"] confirmado para o dia ["+DtoC(dDtConf)+"] ?" , "Cancelamento do Agendamento")               
    Return .F.
EndIf

nPosRec:= Z09->( Recno() )
cTransp:= Z09->Z09_TRANSP
cChave := Z09->(Z09_FILIAL + Z09_NUMPV)


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

        aTrackS[Z09->(FieldPos("Z09_FILIAL"))] := Z09->Z09_FILIAL
        aTrackS[Z09->(FieldPos("Z09_NUMPV")) ] := Z09->Z09_NUMPV
        aTrackS[Z09->(FieldPos("Z09_ITEMPV"))] := Z09->Z09_ITEMPV  
        aTrackS[Z09->(FieldPos("Z09_DT1COL"))] := CTOD("") 
        aTrackS[Z09->(FieldPos("Z09_HR1COL"))] := ""
        aTrackS[Z09->(FieldPos("Z09_US1COL"))] := ""    
        aTrackS[Z09->(FieldPos("Z09_DC1COL"))] := CTOD("")
        aTrackS[Z09->(FieldPos("Z09_HC1COL"))] := ""
        aTrackS[Z09->(FieldPos("Z09_UC1COL"))] := ""
        aTrackS[Z09->(FieldPos("Z09_DT2COL"))] := CTOD("") 
        aTrackS[Z09->(FieldPos("Z09_HR2COL"))] := ""
        aTrackS[Z09->(FieldPos("Z09_US2COL"))] := ""    
        aTrackS[Z09->(FieldPos("Z09_DC2COL"))] := CTOD("")
        aTrackS[Z09->(FieldPos("Z09_HC2COL"))] := ""
        aTrackS[Z09->(FieldPos("Z09_UC2COL"))] := "" 
        aTrackS[Z09->(FieldPos("Z09_DT3COL"))] := CTOD("") 
        aTrackS[Z09->(FieldPos("Z09_HR3COL"))] := ""
        aTrackS[Z09->(FieldPos("Z09_US3COL"))] := ""    
        aTrackS[Z09->(FieldPos("Z09_DC3COL"))] := CTOD("")
        aTrackS[Z09->(FieldPos("Z09_HC3COL"))] := ""
        aTrackS[Z09->(FieldPos("Z09_UC3COL"))] := ""  
        aTrackS[Z09->(FieldPos("Z09_ORDCOL"))] := ""   

        //-- Atualiza Tabela de Tracking
        u_TRK006S(aTrackS, "Cancelamento do Agendamento")

        Z09->( DbSkip() )
    End
Next nI

// Envio do Email
DbSelectArea("SA4")
SA4->( DbSetOrder(1) )
If SA4->( DbSeek(xFilial()+ cTransp) )

    cEmail := "erike.yuri@dothink.com.br;janine.duarte@barentz.com" // Alltrim(SA4->A4_EMAIL)

    FWMsgRun(NIL,{|| U_TRK0012D(cEmail, "Cancelamento do Agendamento")}, "Aguarde...", "Enviando email para transportadora")
EndIf

RestArea(aArea)
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
