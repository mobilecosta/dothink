#include "totvs.ch"

/*/{Protheus.doc} M410AGRV
Este ponto de entrada pertence à rotina de pedidos de venda, MATA410(). Está localizado na rotina de gravação do pedido, A410GRAVA(). É executado antes da gravação das alterações.
@type function
@version 1.0  
@author erike.yuri@dothink.com.br
@since 15/07/2025

/*/
User Function M410AGRV()
    Local aArea     := GetArea() //Armazena o ambiente ativo para restaurar ao fim do processo
  
    //... aqui o conteúdo do PE BARENTZ

    //--Inicio bloco de copia - Somente considerar este trecho para copiar no PE BARENTZ    
    If ExistBlock("TRK006SP")
        //Faz um backup das variáveis do Protheus em memória
        SaveInter()

        u_TRK006SP(ParamIXB)

        //Restaura o backup das variáveis do Protheus em memória
        RestInter()        
    EndIf
    //-- Fim bloco de copi
    
    //-- Restaura o ambiente ativo no início da chamada
    RestArea(aArea) 
Return
