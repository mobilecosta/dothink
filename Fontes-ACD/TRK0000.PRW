#include "totvs.ch"

//-- Funcoes genericas

/*/{Protheus.doc} C5X4SSTAT
Função para retornar uma lista de opções do campo combo C5_X4SSTAT, devido ter estourado o limite.
@type function
@version 1.0
@author erike.dothink.com.br
@since 8/14/2025
@return character, Lista
/*/
User Function C5X4SSTAT(nOpc)
Local aArea   := GetArea()
Local cOpcoes := ""
Default nOpc  := 1
 
//Montando as opções de retorno
DO CASE
    CASE nOpc == 1 // Portugues
        cOpcoes += "1=Em Separação;"
        cOpcoes += "2=Em Faturamento;"
        cOpcoes += "3=Em Coleta;"
        cOpcoes += "4=Em Transito;"
        cOpcoes += "5=Pedido Entregue;"
        cOpcoes += "6=Em Fracionamento;"
        cOpcoes += "8=Em Agendamento;" 
        cOpcoes += "9=Em Validação Fiscal;" 
        cOpcoes += "A=Validação Física;"
        cOpcoes += "B=Em Embarque;"
    CASE nOpc == 2 // Inglês
        cOpcoes += "1=Picking;"
        cOpcoes += "2=Billing;"
        cOpcoes += "3=Collection;"
        cOpcoes += "4=In Transit;"
        cOpcoes += "5=Order Delivered;"
        cOpcoes += "6=Fractioning;"
        cOpcoes += "8=Scheduling;"
        cOpcoes += "9=Tax Validation;"
        cOpcoes += "A=Physical Validation;"
        cOpcoes += "B=Shipping;"
    CASE nOpc == 3 // Espanhol
        cOpcoes += "1=En Separacion;"
        cOpcoes += "2=En Facturacion;"
        cOpcoes += "3=En Recoleccion;"
        cOpcoes += "4=En Transito;"
        cOpcoes += "5=Pedido Entregado;"
        cOpcoes += "6=En Fraccionamiento;"
        cOpcoes += "8=En Programacion;"
        cOpcoes += "9=Validacion Fiscal;"
        cOpcoes += "A=Validacion Física;"
        cOpcoes += "B=En Embarque;"
END CASE


 
RestArea(aArea)
Return cOpcoes

/*/{Protheus.doc} Z09STATUS
Função para retornar uma lista de opções do campo combo Z09_STATUS, devido ter estourado o limite.
@type function
@version 1.0
@author erike.dothink.com.br
@since 8/14/2025
@return character, Lista
/*/
User Function Z09STATUS(nOpc)
Local aArea   := GetArea()
Local cOpcoes := ""
Default nOpc  := 1
 
//Montando as opções de retorno
DO CASE
    CASE nOpc == 1 // Portugues
        cOpcoes += "1=Em Liberação;"
        cOpcoes += "2=Em Validação Fiscal;"
        cOpcoes += "3=Em Validação Física;"
        cOpcoes += "4=Em Agendamento;"
        cOpcoes += "5=Em Separação;"
        cOpcoes += "6=Em Faturamento;"
        cOpcoes += "7=Em Embarque;"
        cOpcoes += "8=Pedido Entregue;"
    CASE nOpc == 2 // Inglês
        cOpcoes += "1=In Release;"
        cOpcoes += "2=Tax Validation;"
        cOpcoes += "3=Physical Validation;"
        cOpcoes += "4=Scheduling;"
        cOpcoes += "5=Picking;"
        cOpcoes += "6=Billing;"
        cOpcoes += "7=Shipping;"
        cOpcoes += "8=Order Delivered;"
    CASE nOpc == 3 // Espanhol
        cOpcoes += "1=En Liberación;"
        cOpcoes += "2=Validación Fiscal;"
        cOpcoes += "3=Validación Física;"
        cOpcoes += "4=Programación;"
        cOpcoes += "5=Separación;"
        cOpcoes += "6=Facturación;"
        cOpcoes += "7=Embarque;"
        cOpcoes += "8=Pedido Entregado;"
END CASE

RestArea(aArea)
Return cOpcoes


