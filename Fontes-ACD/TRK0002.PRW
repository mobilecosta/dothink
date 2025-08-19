#include "totvs.ch"
#include 'FwMVCDef.ch'

Static cTitulo := "Tracking de Expedição"
Static cOrigem := ""
Static aFields := {}
Static aPos    := {}
Static cModel  := ""

/*/{Protheus.doc} TRK0002
Tracking de Expedicao
@type function
@version 1.0
@author erike.yuri@dothink.com.br
@since 30/06/2025
/*/
User Function TRK0002()
    Local aArea   := GetArea()
    Local oBrowse

    aFields := {}
    aPos    := {}

    //Instânciando FWMBrowse - Somente com dicionário de dados
    oBrowse := FWMBrowse():New()

    oBrowse:SetMenuDef("TRK0002")
    oBrowse:SetMainProc("TRK0002")
     
    //Setando a tabela de cadastro de Autor/Interprete
    oBrowse:SetAlias("Z09")
 
    //Setando a descrição da rotina
    oBrowse:SetDescription(cTitulo)
     
    //Legendas
    /*
    Z09_STATUS
    1 = Em Liberação Crédito/Estoque
    2 = Em Validação Fiscal
    3 = Em Validação Física
    4 = Em Agendamento
    5 = Em Separação
    6 = Em Faturamento
    7 = Em Embarque
    8 = Pedido Entregue    
    */
    oBrowse:AddLegend( "Z09->Z09_STATUS == '1'", "BR_PRETO"         , "Em Liberação"            )
    oBrowse:AddLegend( "Z09->Z09_STATUS == '2'", "br_branco.bmp"    , "Em Validação Fiscal"     )
    oBrowse:AddLegend( "Z09->Z09_STATUS == '3'", "br_amarelo.bmp"   , "Em Validação Física"     )
    oBrowse:AddLegend( "Z09->Z09_STATUS == '4'", "br_laranja.bmp"   , "Em Agendamento"          )
    oBrowse:AddLegend( "Z09->Z09_STATUS == '5'", "br_marron.bmp"    , "Em Separação"            )
    oBrowse:AddLegend( "Z09->Z09_STATUS == '6'", "br_azul.bmp"      , "Em Faturamento"          )
    oBrowse:AddLegend( "Z09->Z09_STATUS == '7'", "br_verde.bmp"     , "Em Embarque"             )
    oBrowse:AddLegend( "Z09->Z09_STATUS == '8'", "GREEN"            , "Pedido Entregue"         ) 
     
    //Ativa a Browse
    oBrowse:Activate()
     
    RestArea(aArea)

Return
 
Static Function MenuDef()
    Local aRot := {}
     
    //Adicionando opções
    ADD OPTION aRot TITLE 'Visualizar'              ACTION 'VIEWDEF.TRK0002'    OPERATION MODEL_OPERATION_VIEW      ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Legenda'                 ACTION 'u_TRK0002L'         OPERATION 6                         ACCESS 0 //OPERATION X
    ADD OPTION aRot TITLE 'Alterar'                 ACTION 'VIEWDEF.TRK0002'    OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Registrar Atraso'        ACTION 'VIEWDEF.TRK0002A'   OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 //OPERATION 5
    ADD OPTION aRot TITLE '1o Coleta'               ACTION 'U_TRK00021()'       OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 //OPERATION 5
    ADD OPTION aRot TITLE '1o Conferencia'          ACTION 'U_TRK00021(.T.)'    OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 //OPERATION 5
    ADD OPTION aRot TITLE '2o Coleta'               ACTION 'U_TRK00022()'       OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 //OPERATION 5
    ADD OPTION aRot TITLE '2o Conferencia'          ACTION 'U_TRK00022(.T.)'    OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 //OPERATION 5
    ADD OPTION aRot TITLE '3o Coleta'               ACTION 'U_TRK00023()'       OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 //OPERATION 5
    ADD OPTION aRot TITLE '3o Conferencia'          ACTION 'U_TRK00023(.T.)'    OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 //OPERATION 5
    ADD OPTION aRot TITLE 'Troca Transportadora'    ACTION 'U_TRK00014()'       OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 //OPERATION 5
    ADD OPTION aRot TITLE 'Email Transportadora'    ACTION 'U_TRK02Mtr()'       OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 //OPERATION 5

Return aRot
 
Static Function ModelDef()
    //Criação do objeto do modelo de dados
    Local oModel := Nil
    Local nFields := 1

    //Criação da estrutura de dados utilizada na interface
    Local oStZ09 := FWFormStruct(1, "Z09")
     
    //Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
    oModel := MPFormModel():New("TRK0002M",/*bPre*/, /*bPos*/,{|| Commit(SELF)},/*bCancel*/) 
     
    //Atribuindo formulários para o modelo
    oModel:AddFields("FORMZ09",/*cOwner*/,oStZ09)

    For nFields := 1 To Len(aFields)
        If aPos[nFields] == 0 .Or. (nFields == Len(aFields) - 1) // Hora da Coleta
            oStZ09:SetProperty(aFields[nFields],MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN , '.F.'  ))
        EndIf
    Next

    //Setando a chave primária da rotina
    oModel:SetPrimaryKey({'Z09_FILIAL','Z09_IDTRAC'})
     
    //Adicionando descrição ao modelo
    oModel:SetDescription("Modelo de Dados do Cadastro "+cTitulo)
     
    //Setando a descrição do formulário
    oModel:GetModel("FORMZ09"):SetDescription("Formulário do Cadastro "+cTitulo)
Return oModel

Static Function Commit(oModel) 

local aTrackS := {}
Local nPos    := 1
Local oZ09    := oModel:GetModel("FORMZ09")
Local cEmail  := ""

// Chamada TRK0002A
/*
Z09_STATUS
1 = Em Liberação Crédito/Estoque
2 = Em Validação Fiscal
3 = Em Validação Física
4 = Em Agendamento
5 = Em Separação
6 = Em Faturamento
7 = Em Embarque
8 = Pedido Entregue

C5_X4SSTAT (Sistem de Pedido de Vendas Web - 4Sales)
1 = Em Separação
2 = Em Faturamento
3 = Em Coleta
4 = Em Transito
5 = Pedido Entregue
6 = Em Fracionamento
8 = Em Agendamento
;9 = Em Validação Fiscal
;A = Validação Física
;B = Em Embarque
*/

// Chamada TRK0002C
If cModel == 'TRK0002C'
    oZ09:LoadValue("Z09_STATUS", "4")  // Em agendamento
    oZ09:LoadValue(aFields[Len(aFields) - 1], Left(Time(), 5))
    oZ09:LoadValue(aFields[Len(aFields)], cUserName)

    aTrackS := Array( Len( Z09->( DbStruct() ) ) )

    aTrackS[Z09->(FieldPos("Z09_FILIAL"))] := Z09->Z09_FILIAL
    aTrackS[Z09->(FieldPos("Z09_NUMPV")) ] := oZ09:GetValue("Z09_NUMPV")
    aTrackS[Z09->(FieldPos("Z09_ITEMPV"))] := oZ09:GetValue("Z09_ITEMPV")
    aTrackS[Z09->(FieldPos("Z09_STATUS"))] := oZ09:GetValue("Z09_STATUS")
    SC5->(DbSetOrder(1))
    If  SC5->(DbSeek(Z09->Z09_FILIAL + oZ09:GetValue("Z09_NUMPV"))) .And.;
        SC5->(RecLock("SC5", .F.))
        SC5->C5_X4SSTAT := "8" // Em Agendamento
        SC5->C5_MSEXP := ""
        SC5->(MsUnLock())
    EndIf

    For nPos := 1 To Len(aPos)
        If aPos[nPos] > 0
            aTrackS[ Z09->(FieldPos(aFields[nPos]) ) ] := oZ09:GetValue(aFields[nPos])
        EndIf
    Next

    u_TRK006S(aTrackS,"Agendamento")

    aTrackS[Z09->(FieldPos("Z09_FILIAL"))] := Z09->Z09_FILIAL
    aTrackS[Z09->(FieldPos("Z09_NUMPV")) ] := oZ09:GetValue("Z09_NUMPV")
    aTrackS[Z09->(FieldPos("Z09_ITEMPV"))] := oZ09:GetValue("Z09_ITEMPV")

    // Realizar a gravaçaõ da Z09
    While   Z09->(Z09_FILIAL + Z09_NUMPV + Z09_ITEMPV) == Z09->Z09_FILIAL +;
            oZ09:GetValue("Z09_NUMPV") + oZ09:GetValue("Z09_ITEMPV")
        Z09->(DbSkip())
    EndDo

    // Envio do Email
    cEmail := "erike.yuri@dothink.com.br;mobile.costa@gmail.com" // Alltrim(SA4->A4_EMAIL)
    
    U_TRK0012(cEmail, cOrigem)
ElseIf cModel == 'TRK0014'
    SC5->(DbSetOrder(1))
    If  SC5->(DbSeek(Z09->Z09_FILIAL + oZ09:GetValue("Z09_NUMPV"))) .And.;
        SC5->(RecLock("SC5", .F.))
        SC5->C5_TRANSP := oZ09:GetValue("Z09_TRANSP")
        SC5->C5_X4SSTAT := "8" // Em Agendamento
        SC5->C5_MSEXP := ""
        SC5->(MsUnLock())
    EndIf
Else
    FWFormCommit(oModel)
EndIf

Return .T.

User Function TRK02Mtr

    SC5->(DbSetOrder(1))
    SC5->(DbSeek(Z09->Z09_FILIAL + Z09->Z09_NUMPV))

    // Envio do Email
    cEmail := "erike.yuri@dothink.com.br;mobile.costa@gmail.com" // Alltrim(SA4->A4_EMAIL)
    
    U_TRK0012(cEmail, "Envio de Email para Transportadora")

Return

Static Function ViewDef()
    Local oModel := FWLoadModel("TRK0002")
    Local oStZ09 := FWFormStruct(2, "Z09")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'SBM_NOME|SBM_DTAFAL|'}
    Local oView  := Nil
 
    //Criando a view que será o retorno da função e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)
     
    //Atribuindo formulários para interface
    oView:AddField("VIEW_Z09", oStZ09, "FORMZ09")
     
    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox("TELA",100)
     
    //Colocando título do formulário
    oView:EnableTitleView('VIEW_Z09', 'Dados da Tabela de Tracking de Expedição' )  
     
    //Força o fechamento da janela na confirmação
    oView:SetCloseOnOk({||.T.})
     
    //O formulário da interface será colocado dentro do container
    oView:SetOwnerView("VIEW_Z09","TELA")
Return oView
 
/*/{Protheus.doc} TRK0002L
Função para mostrar a legenda das rotinas MVC com grupo de produtos
@author erike.yuri@dothink.com.br
@since 30/06/2025
@version 1.0
    @example
    u_TRK0002L()
/*/
 
User Function TRK0002L()
    Local aLegenda := {}
     
    //Monta as cores
    AADD(aLegenda,{"BR_PRETO"           ,    "Em Liberação"         })
    AADD(aLegenda,{"br_branco.bmp"      ,    "Em Validação Fiscal"  })
    AADD(aLegenda,{"br_amarelo.bmp"     ,    "Em Validação Física"  })
    AADD(aLegenda,{"br_laranja.bmp"     ,    "Em Agendamento"       })
    AADD(aLegenda,{"br_marron.bmp"      ,    "Em Separação"         })
    AADD(aLegenda,{"br_azul.bmp"        ,    "Em Faturamento"       })
    AADD(aLegenda,{"br_verde.bmp"       ,    "Em Embarque"          })
    AADD(aLegenda,{"BR_VERDE"           ,    "Pedido Entregue"      })
       
    BrwLegenda("Tracking Expedição", "Status", aLegenda)

Return

User Function TRK02FL(__aFields, __aPos, __cModel, __cOrigem)

    aFields := AClone(__aFields)
    aPos    := AClone(__aPos)
    cModel  := __cModel
    cOrigem := __cOrigem

Return
