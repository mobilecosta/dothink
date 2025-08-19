#include 'totvs.ch'
// Tabela SZ10
#DEFINE CZ10XFILIAL  01	// Filial        C [ 2 ][ 0 ] 01
#DEFINE CZ10XIDTRAC  02	// ID Tracking   C [13 ][ 0 ] 02
#DEFINE CZ10XFORNEC  03	// Fornecedor    C [ 6 ][ 0 ] 03
#DEFINE CZ10XLOJFOR  04	// Loja Fornec.  C [ 2 ][ 0 ] 04
#DEFINE CZ10XNFORN   05	// Nome Fornec.  C [60 ][ 0 ] 05
#DEFINE CZ10XPO      06	// PO            C [ 6 ][ 0 ] 06
#DEFINE CZ10XITEMPO  07	// Item PO       C [ 4 ][ 0 ] 07
#DEFINE CZ10XNF      08	// NF Mae        C [ 9 ][ 0 ] 08
#DEFINE CZ10XSERIE   09	// Serie NF Mae  C [ 3 ][ 0 ] 09
#DEFINE DZ10XDTENNF  10	// Data Entrada  D [ 8 ][ 0 ] 10
#DEFINE CZ10XHRENNF  11	// Hora Entrada  C [ 5 ][ 0 ] 11
#DEFINE CZ10XNFFILH  12	// NF Filha      C [ 9 ][ 0 ] 12
#DEFINE CZ10XSERFIL  13	// Serie Filha   C [ 3 ][ 0 ] 13
#DEFINE CZ10XITNFM   14	// Item NF Mae   C [ 4 ][ 0 ] 14
#DEFINE CZ10XPRODUT  15	// Produto       C [15 ][ 0 ] 15
#DEFINE NZ10XQUANT   16	// Quant. Kg     N [16 ][ 6 ] 16
#DEFINE DZ10XPRVCH   17	// Prev.Chegada  D [ 8 ][ 0 ] 17
#DEFINE CZ10XLBRAN   18	// Linha Branca  C [ 1 ][ 0 ] 18
#DEFINE DZ10XDTENFI  19	// D.Ent.Fiscal  D [ 8 ][ 0 ] 19
#DEFINE CZ10XHRENFI  20	// H.Ent.Fiscal  C [ 5 ][ 0 ] 20
#DEFINE CZ10XPRDREM  21	// Prod.Remessa  C [15 ][ 0 ] 21
#DEFINE CZ10XNFREM   22	// NF Remessa    C [ 9 ][ 0 ] 22
#DEFINE CZ10XSERREM  23	// Serie Remess  C [ 3 ][ 0 ] 23
#DEFINE DZ10XDTNFRE  24	// Dt.NF Remes.  D [ 8 ][ 0 ] 24
#DEFINE CZ10XHRNFRE  25	// Hr.NF Remes.  C [ 5 ][ 0 ] 25
#DEFINE DZ10XDTENTL  26	// D.Ent.Fisica  D [ 8 ][ 0 ] 26
#DEFINE CZ10XHRENTL  27	// H.Ent.Fisica  C [ 5 ][ 0 ] 27
#DEFINE DZ10XDTENTQ  28	// D.Entr.Quali  D [ 8 ][ 0 ] 28
#DEFINE CZ10XHRENTQ  29	// H.Entr.Quali  C [ 5 ][ 0 ] 29
#DEFINE DZ10XDTLBCQ  30	// D.Lib.Quali   D [ 8 ][ 0 ] 30
#DEFINE CZ10XHRLBCQ  31	// H.Lib.Quali   C [ 5 ][ 0 ] 31
#DEFINE CZ10XMOTIVO  32	// Motivo Quali  C [ 6 ][ 0 ] 32
#DEFINE DZ10XDTDISP  33	// D.Ent.Ender.  D [ 8 ][ 0 ] 33
#DEFINE CZ10XHRDISP  34	// H.Ent.Ender.  C [ 5 ][ 0 ] 34
#DEFINE MZ10XOCORRE  35	// Ocorrencias   M [10 ][ 0 ] 35
#DEFINE CZ10XARMAZ   36	// Armazem       C [ 2 ][ 0 ] 36
#DEFINE CZ10XSTATUS  37	// Status        C [ 1 ][ 0 ] 37
#DEFINE CZ10XSLA     38	// Status SLA    C [ 1 ][ 0 ] 38

/*/{Protheus.doc} TRK006EP
Centralizacao da execucao dos pontos de entrada
@type function
@version 1.0
@author fernando.muta@dothink.com.br
@since 30/07/2025
@param aTrackE, array, param_description
@param cEvento, character, param_description
@return variant, return_description
/*/
User Function TRK006EP()
Local aArea		:= GetArea()
Local cFuncPE	:= ""
Local uReturn	:= Nil
cFuncPE := Upper( ProcName(1) )			// Recebe o nome do ponto de entrada
cFuncPE := StrTran( cFuncPE, "U_", "" )	// Remove o "U_"
cFuncPE := "e" + cFuncPE + "()"			// Ajusta para o nome da Static Function correspondente
If !(Empty( cFuncPE ))
    uReturn := &( cFuncPE )
EndIf
RestArea(aArea)
Return(uReturn)



/*/{Protheus.doc} eSD1100I
Ponto de entrada na gravacao do item da nota de entrada
@type function
@version 1.0
@author fernando.muta@dothink.com.br
@since 30/07/2025
@param aTrackE, array, param_description
@param cEvento, character, param_description
@return variant, return_description
/*/
Static Function eSD1100I()
local xRet     := Nil
local aArea    := GetArea()
local aTrackE  := Array(38)
local cNomClFo := ""
If SD1->D1_TIPO $ "DB"
    SA1->(DbSetOrder(1))
    If SA1->(DbSeek(xFilial()+SD1->D1_FORNECE+SF1->F1_LOJA))
        cNomClFo  := SA1->A1_NOME       // Nome Cliente  C [60 ][ 0 ] 17
    EndIf
else
    SA2->(DbSetOrder(1))
    If SA2->(DbSeek(xFilial()+SD1->D1_FORNECE+SD1->D1_LOJA))
        cNomClFo  := SA2->A2_NOME       // Nome Cliente  C [60 ][ 0 ] 17
    EndIf
EndIf


aTrackE[CZ10XFILIAL] := SD1->D1_FILIAL	    // Filial        C [ 2 ][ 0 ] 01
aTrackE[CZ10XFORNEC] := SD1->D1_FORNECE     // Fornecedor    C [ 6 ][ 0 ] 03
aTrackE[CZ10XLOJFOR] := SD1->D1_LOJA        // Loja Fornec.  C [ 2 ][ 0 ] 04
aTrackE[CZ10XNFORN]  := cNomClFo            // Nome Fornec.  C [60 ][ 0 ] 05
aTrackE[CZ10XNF    ] := SD1->D1_DOC         // NF Mae        C [ 9 ][ 0 ] 08
aTrackE[CZ10XSERIE ] := SD1->D1_SERIE       // Serie NF Mae  C [ 3 ][ 0 ] 09
aTrackE[DZ10XDTENNF] := SD1->D1_DTDIGIT     // Data Entrada  D [ 8 ][ 0 ] 10
aTrackE[CZ10XHRENNF] := SubStr(time(),1,5)  // Hora Entrada  C [ 5 ][ 0 ] 11
aTrackE[CZ10XITNFM ] := SD1->D1_ITEM        // Item NF Mae   C [ 4 ][ 0 ] 14
aTrackE[CZ10XPRODUT] := SD1->D1_COD         // Produto       C [15 ][ 0 ] 15
aTrackE[NZ10XQUANT ] := SD1->D1_QUANT       // Quant. Kg     N [16 ][ 6 ] 16
u_TRK006E(aTrackE,"Entrada de Nota")
RestArea(aArea)
Return xRet
