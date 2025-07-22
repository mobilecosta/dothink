#include "totvs.ch"
#include 'FwMVCDef.ch'

static cTitulo := "Validação Fiscal"

/*/{Protheus.doc} TRK0005
Tracking de Recebimento
@type function
@version 1.0
@author Conceitho
@since 22/07/2025
/*/
User Function TRK0003()
    Local aArea   := GetArea()
    Local oBrowse
     
    //Instânciando FWMBrowse - Alterar para query
    oBrowse := FWMBrowse():New()
     
    //Setando a tabela de cadastro de Autor/Interprete
    oBrowse:SetAlias("SC5")
 
    //Setando a descrição da rotina
    oBrowse:SetDescription(cTitulo)
     
    //Ativa a Browse
    oBrowse:Activate()
     
    RestArea(aArea)

Return