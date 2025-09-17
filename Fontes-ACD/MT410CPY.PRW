//Bibliotecas
#include 'totvs.ch'
 
/*/{Protheus.doc} MT410CPY
Ponto de Entrada Na cópia do Pedido de Venda, zera os campos especificos
@type function
@version 1.0
@author erike.yuri@dothink.com.br
@since 8/18/2025
@return logical, return_description
@obs http://tdn.totvs.com/pages/releaseview.actionçpageId=6784349  
/*/ 
User Function MT410CPY()
    Local aArea := GetArea()
    Local lRet  := .T.
 
    //Zerando dados customizados no cabeçalho
    M->C5_X4SSTAT := ' '
    M->C5_XBLFIS  := ' '
    M->C5_XPEDORI := ' '
    M->C5_XPEDWEB := ' '
    
    RestArea(aArea)
Return lRet
