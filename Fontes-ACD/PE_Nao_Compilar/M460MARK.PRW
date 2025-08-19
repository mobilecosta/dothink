#include "totvs.ch"

/*/{Protheus.doc} M460MARK
Validação de pedidos marcados.
Deverá usar somente o bloco do ExistBlock
@type function
@version 1.0 
@author erike.yuri@dothink.com.br
@since 12/8/2025
@return logical, Determina se deverá prosseguir com o processamento para geração da nota fiscal.
/*/
User Function M460MARK()
    Local aArea   := GetArea()
    Local aCpyParm:= {}
    Local lRet    := .T.
    
    //... aqui o conteúdo do PE BARENTZ

    //--Inicio bloco de copia - Somente considerar este trecho para copiar no PE BARENTZ    
    If ExistBlock("TRK006SP")
        aCpyParm := aClone(PARAMIXB) 
        //Faz um backup das variáveis do Protheus em memória
        SaveInter()
        
        lRet := u_TRK006SP(aCpyParm)

        //Restaura o backup das variáveis do Protheus em memória
        RestInter()        
    EndIf
    //-- Fim bloco de copia


    RestArea(aArea)

Return(lRet)
