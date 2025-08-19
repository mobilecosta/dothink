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
User Function C5X4SSTAT()
Local aArea   := GetArea()
Local cOpcoes := ""
 
//Montando as opções de retorno
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
 
RestArea(aArea)
Return cOpcoes
