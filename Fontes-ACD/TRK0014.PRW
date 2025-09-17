#include "totvs.ch"
#include 'FwMVCDef.ch'

static cTitulo := "Troca de Transportadora"
Static aFields := { "Z09_TRANSP", "Z09_NTRANS","Z09_ICOTER", "Z09_REDESP", "Z09_NREDES", "Z09_REDICO","Z09_IDTRAC" }


/*/{Protheus.doc} TRK0014
Troca de transportadora
@type function
@version 1.0
@author DO THINK
@since 10/08/2025

/*/
User Function TRK00014()

    If Z09->Z09_ACAOCS == "2"
        FWAlertWarning("Aguardando Ação CS!", "Aguardando CS")  
        Return
    EndIf

    If Z09->Z09_ACAOCS == "4"
        FWAlertWarning("Solicitação de Cancelamento CS!", "Cancelamento CS")  
        Return
    EndIf

    If Z09->Z09_ICOTER == "C"
        FWAlertWarning("Não é possível ajustar o tipo de frete quando o Icoterm é CIF!", "Não Permitido Ajuste")  
        Return
    EndIf

    If !Empty(Z09->Z09_NF)
        FWAlertWarning("Já foi gerada a NF ["+Z09->Z09_NF+"] Série ["+Z09->Z09_SERIE+"], não sendo mais possível realizar o ajuste!", "Não Permitido Ajuste")  
        Return
    EndIf

    If !Empty(Z09->Z09_DT1COL) .or. !Empty(Z09->Z09_DT2COL) .or. !Empty(Z09->Z09_DT3COL)
        FWAlertWarning("Ja existe confirmação de coleta. Para prosseguir será necessário realizar o cancelamento da coleta antes!", "Não Permitido Ajuste")  
        Return
    EndIf

    FWExecView(cTitulo,'TRK0014', MODEL_OPERATION_UPDATE)

Return


Static Function ViewDef()
    Local oModel  := Nil
    Local oStZ09  := Nil
    Local oView   := Nil
    Local nFields := 1
    Local cFields := ""
    Local aPos    := {}

    cFields := ""
    For nFields := 1 To Len(aFields)
        cFields += aFields[nFields] + "|"
    Next
    
    aFields := { "Z09_TRANSP"                   , "Z09_NTRANS","Z09_ICOTER"  , "Z09_REDESP"                  , "Z09_NREDES", "Z09_REDICO"                    ,"Z09_IDTRAC" }
 
    aPos    := { Z09->(FieldPos("Z09_TRANSP"))  ,            0,          0   , Z09->(FieldPos("Z09_REDESP")) ,            0, Z09->(FieldPos("Z09_REDICO"))   ,         0   }

    U_TRK02FL(AClone(aFields), AClone(aPos), 'TRK0014', cTitulo)

    oModel := FWLoadModel("TRK0002")
    oStZ09 := FWFormStruct(2, "Z09", { |cCampo| AllTrim(cCampo) $ cFields})
 
    //Criando a view que será o retorno da função e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)

	oStZ09:SetProperty("Z09_IDTRAC",MODEL_FIELD_NOUPD,FwBuildFeature(STRUCT_FEATURE_WHEN,".F."))
	//oStZ09:SetProperty("Z09_DTATRS",MODEL_FIELD_NOUPD,FwBuildFeature(STRUCT_FEATURE_WHEN,".F."))
    //oStZ09:SetProperty("Z09_HRATRS",MODEL_FIELD_NOUPD,FwBuildFeature(STRUCT_FEATURE_WHEN,".F."))

    //Atribuindo formulários para interface
    oView:AddField("VIEW_Z09", oStZ09, "FORMZ09")
     
    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox("TELA", 100)
     
    //Colocando título do formulário
    //oView:EnableTitleView('VIEW_Z09', cTitulo )  
     
    //Força o fechamento da janela na confirmação
    oView:SetCloseOnOk({||.T.})
     
    //O formulário da interface será colocado dentro do container
    oView:SetOwnerView("VIEW_Z09","TELA")
Return oView
