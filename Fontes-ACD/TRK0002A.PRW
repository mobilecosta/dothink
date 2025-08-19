#include "totvs.ch"
#include 'FwMVCDef.ch'

static cTitulo := "Registrar Atraso"
Static aFields := { "Z09_MOTIVO", "Z09_DSMOTV", "Z09_DTATRS", "Z09_HRATRS", "Z09_IDTRAC" }

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
        Aadd(aPos, -1)
    Next

    U_TRK02FL(AClone(aFields), AClone(aPos), 'TRK0002A', cTitulo)

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
    oView:CreateHorizontalBox("TELA",100)
     
    //Colocando título do formulário
    oView:EnableTitleView('VIEW_Z09', 'Registro do atraso' )  
     
    //Força o fechamento da janela na confirmação
    oView:SetCloseOnOk({||.T.})
     
    //O formulário da interface será colocado dentro do container
    oView:SetOwnerView("VIEW_Z09","TELA")
Return oView
