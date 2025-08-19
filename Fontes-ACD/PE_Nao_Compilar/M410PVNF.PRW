#include "totvs.ch"

/*/{Protheus.doc} M410PVNF
 Ponto de entrada para validacao, executado antes da rotina de geracao de NF's.
 Devera usar somente o bloco do ExistBlock
@type function
@version 1.0 
@author erike.yuri@dothink.com.br
@since 12/8/2025
@return logical, Indica se prossegue ou nao com o processamento para a geracao da NF
/*/
User Function M410PVNF()
    Local aArea     := GetArea()
    Local lContinua := .T.
    Local nRecSC5
    
    //... aqui o conteúdo do PE BARENTZ

    //--Inicio bloco de copia - Somente considerar este trecho para copiar no PE BARENTZ    
    If lContinua .And. ExistBlock("TRK006SP")
        nRecSC5 := ParamIXB
        //Faz um backup das variáveis do Protheus em memória
        SaveInter()

        lContinua := u_TRK006SP(nRecSC5)

        //Restaura o backup das variáveis do Protheus em memória
        RestInter()        
    EndIf
    //-- Fim bloco de copia


    RestArea(aArea)

Return(lContinua)
