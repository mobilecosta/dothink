#include "totvs.ch"

/*/{Protheus.doc} Frete
Rotina de ajuste do endereço do frete quando temos redespacho
@type function
@version 1.0
@author erike.yuri@dothink.com.br
@since 15/07/2025
@obs Funcao ja existia, porem estava gravando o municio e estado incorreto da quando se tem redespacho. Nao coloquei o nome do autor pois a funcao nao tinha cabecalho
/*/
User Function Frete()
Local aArea:= GetArea()

If SuperGetMv("ES_FILGFE", .F., .T.)

	If !Empty(SC5->C5_XTPFRTR) .And. !Empty(SC5->C5_REDESP)
		
		DbSelectArea("SA4")
		SA4->( DbSetOrder(1) )
		SA4->( DbSeek(xFilial() + SC5->C5_REDESP) )
		
		RecLock("SC5", .F.)
		SC5->C5_TFRDP1	:= SC5->C5_XTPFRTR
		SC5->C5_ESTRDP1	:= SA4->A4_EST
		SC5->C5_CMURDP1	:= SA4->A4_COD_MUN
		SC5->( MsUnLock() )
	
	EndIf

EndIf

RestArea(aArea)
Return
