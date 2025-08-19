#include "totvs.ch"
/*/{Protheus.doc} MA410COR
Alterar cores do cadastro do status do pedido. Deverá usar somente o bloco do ExistBlock
@type function
@version 1.0 
@author erike.yuri@dothink.com.br
@since 12/8/2025
@return array, Array de Cores
/*/
User Function MA410COR()
    Local aArea    := GetArea()
    Local aCoresPE := ParamIXB
    
    //... aqui o conteúdo do PE BARENTZ

    //--Inicio bloco de copia - Somente considerar este trecho para copiar no PE BARENTZ    
    If ExistBlock("TRK006SP")
        //Faz um backup das variáveis do Protheus em memória
        SaveInter()

        aCoresPE := u_TRK006SP(aCoresPE)

        //Restaura o backup das variáveis do Protheus em memória
        RestInter()        
    EndIf
    //-- Fim bloco de copia


    RestArea(aArea)
Return aCoresPE
