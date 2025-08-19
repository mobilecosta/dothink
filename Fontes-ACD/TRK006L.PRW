#include 'totvs.ch'
#define CZ11XFILIAL 1 // Filial        C [ 2][0] 01
#define CZ11XORIG   2 // Origem        C [ 3][0] 02
#define CZ11XIDTRAC 3 // Id Tracking   C [13][0] 03
#define CZ11XEVENTO 4 // Desc.Evento   C [50][0] 04
#define CZ11XQUEM   5 // Quem Exec.    C [30][0] 05
#define DZ11XQUANDO 6 // Quando Exec.  D [ 8][0] 06
#define CZ11XHORA   7 // Hora Exec.    C [ 5][0] 07
#define CZ11XOQUE   8 // Oque Exec.    M [10][0] 08
#define NZ11XRECORI 9 // Recno.Origem  N [10][0] 09
#define CZ11XSTAMP  10 // TimeStamp     C [14][0] 10
#define CZ11XEMPORI 11 // Emp.Origem    C [ 2][0] 11
#define CZ11XFILORI 12 // Fil.Origem    C [ 2][0] 12

/*/{Protheus.doc} TRK006L
Gravacao do log de alteracoes do track
@type function
@version 1.0
@author fernando.muta@dothink.com.br
@since 30/7/2025
@param aTrackL, array, param_description
@return variant, return_description
/*/
User Function TRK006L(aTrackL)
local aArea := GetArea()
RecLock("Z11",.T.)
 Z11->Z11_FILIAL := aTrackL[CZ11XFILIAL] // Filial        C [ 2][0] 01
 Z11->Z11_ORIG   := aTrackL[CZ11XORIG  ] // Origem        C [ 3][0] 02
 Z11->Z11_IDTRAC := aTrackL[CZ11XIDTRAC] // Id Tracking   C [13][0] 03
 Z11->Z11_EVENTO := aTrackL[CZ11XEVENTO] // Desc.Evento   C [50][0] 04
 Z11->Z11_QUEM   := aTrackL[CZ11XQUEM  ] // Quem Exec.    C [30][0] 05
 Z11->Z11_QUANDO := aTrackL[DZ11XQUANDO] // Quando Exec.  D [ 8][0] 06
 Z11->Z11_HORA   := aTrackL[CZ11XHORA  ] // Hora Exec.    C [ 5][0] 07
 Z11->Z11_OQUE   := aTrackL[CZ11XOQUE  ] // Oque Exec.    M [10][0] 08
 Z11->Z11_RECORI := aTrackL[NZ11XRECORI] // Recno.Origem  N [10][0] 09
 Z11->Z11_STAMP  := aTrackL[CZ11XSTAMP ] // TimeStamp     C [14][0] 10
 Z11->Z11_EMPORI := aTrackL[CZ11XEMPORI] // Emp.Origem    C [ 2][0] 11
 Z11->Z11_FILORI := aTrackL[CZ11XFILORI] // Fil.Origem    C [ 2][0] 12
Z11->(MsUnlock())
RestArea(aArea)
Return
