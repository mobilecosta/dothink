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
    oBrowse:AddLegend( "Z09->Z09_STATUS == '1' ", "BR_PRETO"         , "Em Liberação"            , "1")
    oBrowse:AddLegend( "Z09->Z09_STATUS == '2' ", "br_branco.bmp"    , "Em Validação Fiscal"     , "1")
    oBrowse:AddLegend( "Z09->Z09_STATUS == '3' ", "br_amarelo.bmp"   , "Em Validação Física"     , "1")
    oBrowse:AddLegend( "Z09->Z09_STATUS == '4' ", "br_laranja.bmp"   , "Em Agendamento"          , "1")
    oBrowse:AddLegend( "Z09->Z09_STATUS == '5' ", "br_marron.bmp"    , "Em Separação"            , "1")
    oBrowse:AddLegend( "Z09->Z09_STATUS == '6' ", "br_azul.bmp"      , "Em Faturamento"          , "1")
    oBrowse:AddLegend( "Z09->Z09_STATUS == '7' ", "br_verde.bmp"     , "Em Embarque"             , "1")
    oBrowse:AddLegend( "Z09->Z09_STATUS == '8' ", "BR_BRANCO"            , "Pedido Em Transito"      , "1") 
    oBrowse:AddLegend( "Z09->Z09_STATUS == '9' ", "GREEN"            , "Pedido Entregue"         , "1") 
    oBrowse:AddLegend( "Z09->Z09_SLA == ' ' .or. Z09->09_SLA == '1' "      , "sps_updated"      , "Dentro do Prazo"         , "2")
    oBrowse:AddLegend( "Z09->Z09_SLA == '2' "                               , "sps_outdated"     , "Próximo Vencimento"      , "2")
    oBrowse:AddLegend( "Z09->Z09_SLA == '3' "                               , "sps_not_installed", "Fora do Prazo"           , "2")
    oBrowse:AddLegend( "Z09->Z09_SLA == '4' "                               , "sps_not_compatible", "SLA Pausado"            , "2")
    oBrowse:AddLegend( "Z09->Z09_ACAOCS == '2' "                            , "CLIENTE"          , "Pendencia CS"            , "3")
    oBrowse:AddLegend( "Z09->Z09_ACAOCS == '3' "                            , "checked"             , "Ajustado CS"             , "3")
    oBrowse:AddLegend( "Z09->Z09_ACAOCS == '4' "                            , "cancel"              , "Cancelado CS"            , "3")
    //Ativa a Browse
    oBrowse:Activate()
     
    RestArea(aArea)

Return
 
Static Function MenuDef()
    Local aRot := {}
    Local aAge := {}
     
    //Adicionando opções
    ADD OPTION aRot TITLE 'Visualizar'              ACTION 'VIEWDEF.TRK0002'    OPERATION MODEL_OPERATION_VIEW      ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Legenda'                 ACTION 'u_TRK0002L'         OPERATION 6                         ACCESS 0 //OPERATION X
    ADD OPTION aRot TITLE 'Alterar'                 ACTION 'VIEWDEF.TRK0002'    OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Agendamento'             ACTION aAge                 OPERATION 9                         ACCESS 0 //OPERATION 9   
    ADD OPTION aRot TITLE 'Registrar Ocorrência'    ACTION 'VIEWDEF.TRK0002A'   OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 //OPERATION 5
    ADD OPTION aRot TITLE 'Troca Transportadora'    ACTION 'U_TRK00014()'       OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 //OPERATION 5
    ADD OPTION aRot TITLE 'Email Transportadora'    ACTION 'U_TRK02Mtr()'       OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 //OPERATION 5
    ADD OPTION aRot TITLE 'Acao Operação (CS)'      ACTION 'VIEWDEF.TRK0002D'   OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 //OPERATION 5
    ADD OPTION aRot TITLE 'Informar Operações (CS)' ACTION 'U_TRK0013()'        OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 //OPERATION 5
    ADD OPTION aRot TITLE 'Ajuste Status'           ACTION 'U_TRK0001S()'       OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 //OPERATION 5
    ADD OPTION aRot TITLE 'Import. Plan. Terceiro'  ACTION 'U_TRK0016I()'       OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 //OPERATION 5

    ADD OPTION aAge TITLE '1o Coleta'               ACTION 'U_TRK00021()'       OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 //OPERATION 5
    ADD OPTION aAge TITLE '1o Confirmacao'          ACTION 'U_TRK00021(.T.)'    OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 //OPERATION 5
    ADD OPTION aAge TITLE '2o Coleta'               ACTION 'U_TRK00022()'       OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 //OPERATION 5
    ADD OPTION aAge TITLE '2o Confirmacao'          ACTION 'U_TRK00022(.T.)'    OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 //OPERATION 5
    ADD OPTION aAge TITLE '3o Coleta'               ACTION 'U_TRK00023()'       OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 //OPERATION 5
    ADD OPTION aAge TITLE '3o Confirmacao'          ACTION 'U_TRK00023(.T.)'    OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 //OPERATION 5 
    ADD OPTION aAge TITLE 'Cancelar'                ACTION 'U_TRK00025()'       OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 //OPERATION 5   

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
Local nPos    := 1
Local nPosRec := 0
Local cChave  := ""
Local cTitLog := ""
Local lPrivez := .T.
Local aTrackS := {}
Local aArea   := GetArea()
Local oZ09    := oModel:GetModel("FORMZ09")
Local aPVs    := {}
Local nI

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

nPosRec:= Z09->( Recno() )

aAdd(aPVs, oZ09:GetValue("Z09_FILIAL") + oZ09:GetValue("Z09_NUMPV")) 
If !Empty(oZ09:GetValue("Z09_PVREME"))
    If oZ09:GetValue("Z09_NUMPV") == oZ09:GetValue("Z09_PVREME")
        aAdd(aPVs, oZ09:GetValue("Z09_FILIAL") + oZ09:GetValue("Z09_PVTRIA"))
    Else
        aAdd(aPVs, oZ09:GetValue("Z09_FILIAL") + oZ09:GetValue("Z09_PVREME"))
    EndIf
Endif

For nI := 1 To Len(aPVs)
    cChave := aPVs[nI]

    Z09->( DbSetOrder(3) )
    Z09->( DbSeek(cChave) )
    While Z09->( !Eof() .And. Z09_FILIAL + Z09_NUMPV == cChave)
        aTrackS := Array( Len( Z09->( DbStruct() ) ) )

        aTrackS[Z09->(FieldPos("Z09_FILIAL"))] := Z09->Z09_FILIAL
        aTrackS[Z09->(FieldPos("Z09_NUMPV")) ] := Z09->Z09_NUMPV
        aTrackS[Z09->(FieldPos("Z09_ITEMPV"))] := Z09->Z09_ITEMPV   

        If cModel == 'TRK0002A'
            cTitLog := "Registro de Ocorrencia"
            oZ09:LoadValue(aFields[GetPCpo("Z09_DTATRS")], Date())
            oZ09:LoadValue(aFields[GetPCpo("Z09_HRATRS")], Left(Time(), 5))

            aTrackS[Z09->(FieldPos("Z09_DTATRS"))] := oZ09:GetValue("Z09_DTATRS")      
            aTrackS[Z09->(FieldPos("Z09_HRATRS"))] := oZ09:GetValue("Z09_HRATRS") 
            aTrackS[Z09->(FieldPos("Z09_MOTIVO"))] := oZ09:GetValue("Z09_MOTIVO")
            aTrackS[Z09->(FieldPos("Z09_DCMOTV"))] := oZ09:GetValue("Z09_DCMOTV")  
            aTrackS[Z09->(FieldPos("Z09_DSMOTV"))] := oZ09:GetValue("Z09_DSMOTV") 

        ElseIf cModel == 'TRK0002C' // Chamada TRK0002C
            cTitLog := "Agendamento"

            oZ09:LoadValue("Z09_STATUS"             , "4"               )  // Em agendamento
            oZ09:LoadValue(aFields[Len(aFields) - 1], Left(Time(), 5)   )
            oZ09:LoadValue(aFields[Len(aFields)]    , cUserName         )
            
            //If lPrivez
                SC5->(DbSetOrder(1))
                If  SC5->(DbSeek( cChave )) .And.;
                    SC5->(RecLock("SC5", .F.))
                    If !Empty( oZ09:GetValue("Z09_DC1COL") ) .Or. !Empty( oZ09:GetValue("Z09_DC2COL") ) .Or. !Empty( oZ09:GetValue("Z09_DC3COL") )
                        SC5->C5_X4SSTAT := "1" // Em Separacao
                        cTitLog += " (Confirmação Coleta)"
                    Else
                        SC5->C5_X4SSTAT := "8" // Em Agendamento
                    EndIf
                    SC5->C5_MSEXP := ""
                    SC5->(MsUnLock())
                EndIf
                lPrivez := .F.
            //EndIf

            aTrackS[Z09->(FieldPos("Z09_STATUS"))] := oZ09:GetValue("Z09_STATUS")
            For nPos := 1 To Len(aPos)
                If aPos[nPos] > 0
                    aTrackS[ Z09->(FieldPos(aFields[nPos]) ) ] := oZ09:GetValue(aFields[nPos])
                EndIf
            Next

            If !Empty( oZ09:GetValue("Z09_DC1COL") ) .Or. !Empty( oZ09:GetValue("Z09_DC2COL") ) .Or. !Empty( oZ09:GetValue("Z09_DC3COL") )
                aTrackS[ Z09->(FieldPos("Z09_STATUS") ) ] := "5"
            EndIf

            // Envio do Email
            //cEmail := "erike.yuri@dothink.com.br;mobile.costa@gmail.com" // Alltrim(SA4->A4_EMAIL)

            //FWMsgRun(NIL,{|| U_TRK0012(cEmail, "Agendamento")}, "Aguarde...", "Enviando email para transportadora")

        ElseIf cModel == 'TRK0002D'
            cTitLog := "Acao do CS (Customer Services)"
            aTrackS[Z09->(FieldPos("Z09_ACAOCS"))] := oZ09:GetValue("Z09_ACAOCS")      
            aTrackS[Z09->(FieldPos("Z09_OBSCS")) ] := oZ09:GetValue("Z09_OBSCS") 
        
        ElseIf cModel == 'TRK0014'
            cTitLog := "Troca de Transportadora / Incoterm"

            SC5->( DbSetOrder(1) )
            If  SC5->(DbSeek( cChave )) .And.;
                SC5->(RecLock("SC5", .F.))
                SC5->C5_TRANSP := oZ09:GetValue("Z09_TRANSP")
                SC5->C5_REDESP := oZ09:GetValue("Z09_REDESP")
                SC5->C5_TFRDP1 := oZ09:GetValue("Z09_REDICO")
                SC5->C5_MSEXP := ""
                SC5->(MsUnLock())
            EndIf

            aTrackS[Z09->(FieldPos("Z09_TRANSP"))] := oZ09:GetValue("Z09_TRANSP")
            aTrackS[Z09->(FieldPos("Z09_NTRANS"))] := oZ09:GetValue("Z09_NTRANS")
            aTrackS[Z09->(FieldPos("Z09_REDESP"))] := oZ09:GetValue("Z09_REDESP")
            aTrackS[Z09->(FieldPos("Z09_NREDES"))] := oZ09:GetValue("Z09_NREDES")
            aTrackS[Z09->(FieldPos("Z09_REDICO"))] := oZ09:GetValue("Z09_REDICO")

        Else
            Conout("Entrou aqui")
            FWFormCommit(oModel)
            Exit
        EndIf

        //-- Atualiza Tabela de Tracking
        u_TRK006S(aTrackS, cTitLog)

        Z09->( DbSkip() )
    End
Next nI

Z09->( DbGoto(nPosRec) )

RestArea(aArea)

Return .T.



/*/{Protheus.doc} TRK02Mtr
Envio de email para transportadora
@type function
@version 1.0
@author erike.yuri@dothink.com.br
@since 17/08/2025
/*/

User Function TRK02Mtr

    SC5->(DbSetOrder(1))
    SC5->(DbSeek(Z09->Z09_FILIAL + Z09->Z09_NUMPV))

    // Envio do Email
    cEmail := "erike.yuri@dothink.com.br;mobile.costa@gmail.com;janine.duarte@barentz.com;" // Alltrim(SA4->A4_EMAIL)
    If IsBlind()
        U_TRK0012(cEmail, "Agendamento")
    Else
        FWMsgRun(NIL,{||U_TRK0012(cEmail, "Agendamento")},"Aguarde...","Enviando email para transportadora")
    EndIf

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
    AADD(aLegenda,{"BR_BRANCO"          ,    "Pedido Em Transito"   })
    AADD(aLegenda,{"BR_VERDE"           ,    "Pedido Entregue"      })
    AADD(aLegenda,{"sps_updated"        ,    "Dentro do Prazo"      })
    AADD(aLegenda,{"sps_outdated"       ,    "Próximo Vencimento"   })
    AADD(aLegenda,{"sps_not_installed"  ,    "Fora do Prazo"        })
    AADD(aLegenda,{"sps_not_compatible" ,    "SLA Pausado"          })
    AADD(aLegenda,{"CLIENTE"            ,    "Pendencia CS"         })
    AADD(aLegenda,{"checked"            ,    "Ajustado CS"          })
    AADD(aLegenda,{"cancel"             ,    "Cancelado CS"         })
 
    BrwLegenda("Tracking Expedição", "Status", aLegenda)

Return

User Function TRK02FL(__aFields, __aPos, __cModel, __cOrigem)

    aFields := AClone(__aFields)
    aPos    := AClone(__aPos)
    cModel  := __cModel
    cOrigem := __cOrigem

Return

/*/{Protheus.doc} GetPCpo
Retorna a Posicao do campo da variavel static aFields.
@type function
@version 20250821
@author erike
@since 8/21/2025
@param cCpoName, character, Nome do Campo
@return numeric, Posicao do campo
@obs Tem que existir a variavel aFields
/*/
Static Function GetPCpo(cCpoName)
    local nRet := AsCan(aFields, {|x| x == cCpoName })
return nRet
