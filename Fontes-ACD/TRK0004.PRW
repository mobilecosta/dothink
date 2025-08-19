#include "totvs.ch"
#include 'FwMVCDef.ch'

static cTitulo := "Log do Tracking"
/*/{Protheus.doc} TRK0004
Tracking do Tracking
@type function
@version 1.0
@author erike.yuri@dothink.com.br
@since 30/06/2025
/*/
User Function TRK0004()
    Local aArea   := GetArea()
    Local oBrowse
     
    //Instânciando FWMBrowse - Somente com dicionário de dados
    oBrowse := FWMBrowse():New()
     
    //Setando a tabela de cadastro de Autor/Interprete
    oBrowse:SetAlias("Z11")
 
    //Setando a descrição da rotina
    oBrowse:SetDescription(cTitulo)
     
    //Ativa a Browse
    oBrowse:Activate()
     
    RestArea(aArea)

Return
 
Static Function MenuDef()
    Local aRot := {}
     
    //Adicionando opções
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.TRK0004' OPERATION MODEL_OPERATION_VIEW      ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.TRK0004' OPERATION MODEL_OPERATION_INSERT    ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.TRK0004' OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.TRK0004' OPERATION MODEL_OPERATION_DELETE    ACCESS 0 //OPERATION 5
 
Return aRot
 
Static Function ModelDef()
    //Criação do objeto do modelo de dados
    Local oModel := Nil
     
    //Criação da estrutura de dados utilizada na interface
    Local oStZ11 := FWFormStruct(1, "Z11")
     
    //Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
    oModel := MPFormModel():New("TRK0011M",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 
     
    //Atribuindo formulários para o modelo
    oModel:AddFields("FORMZ11",/*cOwner*/,oStZ11)
     
    //Setando a chave primária da rotina
    oModel:SetPrimaryKey({'Z11_FILIAL', 'Z11_IDTRAC', 'Z11_ORIG'})
     
    //Adicionando descrição ao modelo
    oModel:SetDescription("Modelo de Dados do Cadastro "+cTitulo)
     
    //Setando a descrição do formulário
    oModel:GetModel("FORMZ11"):SetDescription("Formulário do Cadastro "+cTitulo)
Return oModel
 

Static Function ViewDef()
    //Criação do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
    Local oModel := FWLoadModel("TRK0004")
     
    //Criação da estrutura de dados utilizada na interface do cadastro de Autor
    Local oStZ11 := FWFormStruct(2, "Z11")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'SBM_NOME|SBM_DTAFAL|'}
     
    //Criando oView como nulo
    Local oView := Nil
 
    //Criando a view que será o retorno da função e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)
     
    //Atribuindo formulários para interface
    oView:AddField("VIEW_Z11", oStZ11, "FORMZ11")
     
    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox("TELA",100)
     
    //Colocando título do formulário
    oView:EnableTitleView('VIEW_Z11', 'Dados da Tabela de Log de Tracking' )  
     
    //Força o fechamento da janela na confirmação
    oView:SetCloseOnOk({||.T.})
     
    //O formulário da interface será colocado dentro do container
    oView:SetOwnerView("VIEW_Z11","TELA")
Return oView
 

