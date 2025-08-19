#include "totvs.ch"

/*/{Protheus.doc} M461LEG
 Altera os textos da legenda sobre o status da Nota Fiscal.
 Deverá usar somente o bloco do ExistBlock
@type function
@version 1.0 
@author erike.yuri@dothink.com.br
@since 12/8/2025
@return array, Array com Legendas
/*/
User Function M461LEG()
    Local aArea  := GetArea()
    Local aCores := ParamIXB
    
    //... aqui o conteúdo do PE BARENTZ

    //--Inicio bloco de copia - Somente considerar este trecho para copiar no PE BARENTZ    
    If ExistBlock("TRK006SP")
        //Faz um backup das variáveis do Protheus em memória
        SaveInter()

        aCores := u_TRK006SP(aCores)

        //Restaura o backup das variáveis do Protheus em memória
        RestInter()        
    EndIf
    //-- Fim bloco de copia


    RestArea(aArea)

Return(aCores)
