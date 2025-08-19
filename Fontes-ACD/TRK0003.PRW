#include "totvs.ch"
#include 'FwMVCDef.ch'

static cTitulo := "Tracking de Recebimento"

/*/{Protheus.doc} TRK0003
Tracking de Recebimento
@type function
@version 1.0
@author DO THINK - ERIKE YURI
@since 30/06/2025
/*/
User Function TRK0003()
    Local aArea   := GetArea()
    Local oBrowse
     
    //Instânciando FWMBrowse - Somente com dicionário de dados
    oBrowse := FWMBrowse():New()
     
    //Setando a tabela de cadastro de Autor/Interprete
    oBrowse:SetAlias("Z10")
 
    //Setando a descrição da rotina
    oBrowse:SetDescription(cTitulo)
     
    //Legendas
    oBrowse:AddLegend( "Z10->Z10_STATUS == '1'", "GREEN",    "Original" )
    oBrowse:AddLegend( "Z10->Z10_STATUS == '0'", "RED"  ,    "Não Original" )
     
    //Ativa a Browse
    oBrowse:Activate()
     
    RestArea(aArea)

Return
 
Static Function MenuDef()
    Local aRot := {}
     
    //Adicionando opções
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.TRK0003' OPERATION MODEL_OPERATION_VIEW      ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Legenda'    ACTION 'u_TRK0003L'      OPERATION 6                         ACCESS 0 //OPERATION X
    ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.TRK0003' OPERATION MODEL_OPERATION_INSERT    ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.TRK0003' OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.TRK0003' OPERATION MODEL_OPERATION_DELETE    ACCESS 0 //OPERATION 5
 
Return aRot
 
Static Function ModelDef()
    //Criação do objeto do modelo de dados
    Local oModel := Nil
     
    //Criação da estrutura de dados utilizada na interface
    Local oStZ10 := FWFormStruct(1, "Z10")
     
    //Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
    oModel := MPFormModel():New("TRK0003M",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 
     
    //Atribuindo formulários para o modelo
    oModel:AddFields("FORMZ10",/*cOwner*/,oStZ10)
     
    //Setando a chave primária da rotina
    oModel:SetPrimaryKey({'Z10_FILIAL','Z10_ID'})
     
    //Adicionando descrição ao modelo
    oModel:SetDescription("Modelo de Dados do Cadastro "+cTitulo)
     
    //Setando a descrição do formulário
    oModel:GetModel("FORMZ10"):SetDescription("Formulário do Cadastro "+cTitulo)
Return oModel
 

Static Function ViewDef()
    //Criação do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
    Local oModel := FWLoadModel("TRK0003")
     
    //Criação da estrutura de dados utilizada na interface do cadastro de Autor
    Local oStSBM := FWFormStruct(2, "Z10")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'SBM_NOME|SBM_DTAFAL|'}
     
    //Criando oView como nulo
    Local oView := Nil
 
    //Criando a view que será o retorno da função e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)
     
    //Atribuindo formulários para interface
    oView:AddField("VIEW_Z10", oStSBM, "FORMZ10")
     
    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox("TELA",100)
     
    //Colocando título do formulário
    oView:EnableTitleView('VIEW_Z10', 'Dados da Tabela de Tracking de Expedição' )  
     
    //Força o fechamento da janela na confirmação
    oView:SetCloseOnOk({||.T.})
     
    //O formulário da interface será colocado dentro do container
    oView:SetOwnerView("VIEW_Z10","TELA")
Return oView
 
/*/{Protheus.doc} TRK0003L
Função para mostrar a legenda das rotinas MVC com grupo de produtos
@author DO THINK - Erike Yuri
@since 30/06/2025
@version 1.0
    @example
    u_TRK0003L()
/*/
 
User Function TRK0003L()
    Local aLegenda := {}
     
    //Monta as cores
    AADD(aLegenda,{"BR_VERDE",        "Original"  })
    AADD(aLegenda,{"BR_VERMELHO",    "Não Original"})
     
    BrwLegenda("Tracking Reebimento", "Status", aLegenda)

Return

