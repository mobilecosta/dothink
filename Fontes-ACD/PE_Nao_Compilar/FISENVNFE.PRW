#include "totvs.ch"
/*/{Protheus.doc} FISENVNFE
Tratamento para a transmissão da nota
@type function
@version 1.0 
@author erike.yuri@dothink.com.br
@since 22/8/2025
@return array, Array de Cores
/*/
User Function FISENVNFE()
    Local aArea    := GetArea()
    
    //... aqui o conteúdo do PE BARENTZ

    //--Inicio bloco de copia - Somente considerar este trecho para copiar no PE BARENTZ    
    If ExistBlock("TRK12XML")
        //Faz um backup das variáveis do Protheus em memória
        SaveInter()

        u_TRK12XML(ParamIXB)

        //Restaura o backup das variáveis do Protheus em memória
        RestInter()        
    EndIf
    //-- Fim bloco de copia

    RestArea(aArea)
Return
