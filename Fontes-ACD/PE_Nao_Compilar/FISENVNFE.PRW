#include "totvs.ch"
/*/{Protheus.doc} FISENVNFE
Tratamento para a transmissão da nota
@type function
@version 20250829
@author erike.yuri@dothink.com.br
@since 29/8/2025
/*/
User Function FISENVNFE()
    Local aArea         := GetArea()
    Local aParametros   := ParamIXB
    /*
    If Len(aParametros) > 0
        CursorWait()

        U_PRT0669()

        CursorArrow()
        
    EndIf
    */

    //--Inicio bloco de copia - Somente considerar este trecho para copiar no PE BARENTZ    
    If ExistBlock("TRK006SP")
        //Faz um backup das variáveis do Protheus em memória
        SaveInter()

        u_TRK006SP(ParamIXB)

        //Restaura o backup das variáveis do Protheus em memória
        RestInter()        
    EndIf
    //-- Fim bloco de copia


    RestArea(aArea)
Return
