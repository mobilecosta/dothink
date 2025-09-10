#include "totvs.ch"


/*/{Protheus.doc} SF2520E
Ponto de entrada executado na exlusao do documento de saida
@type function
@version 1.0 
@author dener.lemos@dothink.com.br
@since 30/08/2025
/*/
User Function SF2520E()
    Local aAreaAnt := GetArea()
    Local aCpyParm := {}
    
    //... aqui o conteúdo do PE BARENTZ

    //-- Inicio bloco de copia - Somente considerar este trecho para copiar no PE BARENTZ    
    If ExistBlock("TRK006SP")
        aCpyParm := aClone(PARAMIXB) 
        //-- Faz um backup das variáveis do Protheus em memória
        SaveInter()
        
        u_TRK006SP(aCpyParm)

        //-- Restaura o backup das variáveis do Protheus em memória
        RestInter()        
    EndIf
    //-- Fim bloco de copia

    RestArea(aAreaAnt)

Return
