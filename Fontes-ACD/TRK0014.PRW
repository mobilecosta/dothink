#include "totvs.ch"
#include 'FwMVCDef.ch'

static cTitulo := "Troca de Transportadora"


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

    If Z09->Z09_ICOTER == "F"

        FWAlertHelp("Atenção só será permitido a <font color='red'>alteração da transportadora</font> para o pedido de vendas <strong>"+Z09->Z09_NUMPV+"</strong>, " +;
                    "se o <font color='red'><strong>CS</strong></font> for informado, e autorizar esta alteração.", "Entre em contato com o CS, para verificar com o cliente (use a opção <font color='red'>Registrar Ocorrência</font>), porém caso isso já tenha sido feito por favor prossiga.")

        If !FWAlertNoYes("Se o CS já autorizou, deseja continuar?", "Confirme se o CS já autorizou")
            //SetTraking("1", SC6->(C6_FILIAL + C6_NUM), SC6->C6_ITEM, "Lote", "Lote não localizado: " + AllTrim(SC6->C6_LOTECTL), "Validação Fisica (Lote não localizado)")
            Return
        EndIf
        
    EndIf

    If !Empty(Z09->Z09_NF)
        FWAlertWarning("Já foi gerada a NF ["+Z09->Z09_NF+"] Série ["+Z09->Z09_SERIE+"], não sendo mais possível realizar o ajuste!", "Não Permitido Ajuste")  
        Return
    EndIf

    If !Empty(Z09->Z09_DC1COL) .or. !Empty(Z09->Z09_DC2COL) .or. !Empty(Z09->Z09_DC3COL)
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
    Local aFields := {} 
    Local aPos    := {}
    
    aFields := {    "Z09_TRANSP"    , ; //-- 01
                    "Z09_NTRANS"    , ; //-- 02
                    "Z09_ICOTER"    , ; //-- 03
                    "Z09_REDESP"    , ; //-- 04
                    "Z09_NREDES"    , ; //-- 05
                    "Z09_REDICO"    , ; //-- 06
                    "Z09_IDTRAC" }      //-- 07
 
    aPos    := {1 ,; //-- 01
                0 ,; //-- 02
                0 ,; //-- 03
                4 ,; //-- 04
                0 ,; //-- 05
                6 ,; //-- 06
                0 }  //-- 07 

    U_TRK02FL(AClone(aFields), AClone(aPos), 'TRK0014', cTitulo)

    cFields := ""
    For nFields := 1 To Len(aFields)
        cFields += aFields[nFields] + "|"
    Next   

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
