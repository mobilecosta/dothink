#include "totvs.ch"
#include 'FwMVCDef.ch'

static cTitulo := "Ação CS (Customer Services)"
Static aFields := { "Z09_ACAOCS", "Z09_OBSCS", "Z09_NUMPV", "Z09_ITEMPV", "Z09_IDTRAC", "Z09_RESTR", "Z09_OBSPV", "Z09_PENCS" }

/*/{Protheus.doc} ViewDef
View para ação do CS (Customer Services)
@type function
@version 1.0
@author wagner.mobile@dothink.com.br
@since 10/8/2025
@return object, Objeto da View
/*/
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
    aPos := { Z09->(FieldPos("Z09_ACAOCS")), Z09->(FieldPos("Z09_OBSCS")), 0, 0, 0, 0, 0, 0 }

    U_TRK02FL(AClone(aFields), AClone(aPos), 'TRK0002D', cTitulo)

    oModel := FWLoadModel("TRK0002")
    oStZ09 := FWFormStruct(2, "Z09", { |cCampo| AllTrim(cCampo) $ cFields})
 
    //Criando a view que será o retorno da função e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)

	oStZ09:SetProperty("Z09_IDTRAC",MODEL_FIELD_NOUPD,FwBuildFeature(STRUCT_FEATURE_WHEN,".F."))
	oStZ09:SetProperty("Z09_NUMPV",MODEL_FIELD_NOUPD,FwBuildFeature(STRUCT_FEATURE_WHEN,".F."))
    oStZ09:SetProperty("Z09_ITEMPV",MODEL_FIELD_NOUPD,FwBuildFeature(STRUCT_FEATURE_WHEN,".F."))

    //Atribuindo formulários para interface
    oView:AddField("VIEW_Z09", oStZ09, "FORMZ09")
     
    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox("TELA",100)
     
    //Força o fechamento da janela na confirmação
    oView:SetCloseOnOk({||.T.})
     
    //O formulário da interface será colocado dentro do container
    oView:SetOwnerView("VIEW_Z09","TELA")
Return oView
