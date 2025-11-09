#include "totvs.ch"
#include 'FwMVCDef.ch'

Static cTitulo := "Informar Protocolo da Carta de Correção"

/*/{Protheus.doc} TRK00026
Validacao Carta de Correcao
@type function
@version 1.0
@author DoThink
@since 10/08/2025
/*/
User Function TRK00026()

If Empty(Z09->Z09_NF)
    FWAlertWarning("Só é possível informar carta de correção se existir nota fiscal, e este pedido não possui nota fiscal!", "Não Permitido Ajuste")  
    Return
EndIf

FWExecView(cTitulo,'TRK0002E', MODEL_OPERATION_UPDATE)

Return

/*/{Protheus.doc} ViewDef
View do ajuste da carta de correcao
@type function
@version 1.0 
@author erike.yuri@dothink.com.br
@since 02/08/2025
@return object, Objeto da View
/*/
Static Function ViewDef()
    Local oModel := Nil
    Local oStZ09 := Nil
    Local oView  := Nil
    Local nFields := 1
    Local cFields := ""
    Local aFields := {} 
    Local aPos    := {}

    aFields := { "Z09_CLIENT", "Z09_LOJA", "Z09_NOMECL", "Z09_NUMPV", "Z09_STATUS","Z09_NF", "Z09_SERIE", "Z09_CCEPRO", "Z09_IDTRAC","Z09_FILIAL" }
    aPos    := { 0, 0, 0, 0, 0, 0, 0, Z09->(FieldPos("Z09_CCEPRO")), 0 ,0 }

    cFields := ""
    For nFields := 1 To Len(aFields) - 1
        cFields += aFields[nFields] + "|"
    Next    
 
    U_TRK02FL(AClone(aFields), AClone(aPos), 'TRK0002E', cTitulo)

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
