// Programa: TRKZ10S.prw
// Descrição: Comparação e gravação dos dados da tabela SZ10 com base nos defines do TRK006E

#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"

// Tabela SZ10
#DEFINE CZ10XFILIAL  1 // Filial        C [ 2 ][ 0 ] 01
#DEFINE CZ10XIDTRAC  2 // ID Tracking   C [13 ][ 0 ] 02
#DEFINE CZ10XFORNEC  3 // Fornecedor    C [ 6 ][ 0 ] 03
#DEFINE CZ10XLOJFOR  4 // Loja Fornec.  C [ 2 ][ 0 ] 04
#DEFINE CZ10XNFORN   5 // Nome Fornec.  C [60 ][ 0 ] 05
#DEFINE CZ10XPO      6 // PO            C [ 6 ][ 0 ] 06
#DEFINE CZ10XITEMPO  7 // Item PO       C [ 4 ][ 0 ] 07
#DEFINE CZ10XNF      8 // NF Mae        C [ 9 ][ 0 ] 08
#DEFINE CZ10XSERIE   9 // Serie NF Mae  C [ 3 ][ 0 ] 09
#DEFINE DZ10XDTENNF  10 // Data Entrada  D [ 8 ][ 0 ] 10
#DEFINE CZ10XHRENNF  11 // Hora Entrada  C [ 5 ][ 0 ] 11
#DEFINE CZ10XNFFILH  12 // NF Filha      C [ 9 ][ 0 ] 12
#DEFINE CZ10XSERFIL  13 // Serie Filha   C [ 3 ][ 0 ] 13
#DEFINE CZ10XITNFM   14 // Item NF Mae   C [ 4 ][ 0 ] 14
#DEFINE CZ10XPRODUT  15 // Produto       C [15 ][ 0 ] 15
#DEFINE NZ10XQUANT   16 // Quant. Kg     N [16 ][ 6 ] 16
#DEFINE DZ10XPRVCH   17 // Prev.Chegada  D [ 8 ][ 0 ] 17
#DEFINE CZ10XLBRAN   18 // Linha Branca  C [ 1 ][ 0 ] 18
#DEFINE DZ10XDTENFI  19 // D.Ent.Fiscal  D [ 8 ][ 0 ] 19
#DEFINE CZ10XHRENFI  20 // H.Ent.Fiscal  C [ 5 ][ 0 ] 20
#DEFINE CZ10XPRDREM  21 // Prod.Remessa  C [15 ][ 0 ] 21
#DEFINE CZ10XNFREM   22 // NF Remessa    C [ 9 ][ 0 ] 22
#DEFINE CZ10XSERREM  23 // Serie Remess  C [ 3 ][ 0 ] 23
#DEFINE DZ10XDTNFRE  24 // Dt.NF Remes.  D [ 8 ][ 0 ] 24
#DEFINE CZ10XHRNFRE  25 // Hr.NF Remes.  C [ 5 ][ 0 ] 25
#DEFINE DZ10XDTENTL  26 // D.Ent.Fisica  D [ 8 ][ 0 ] 26
#DEFINE CZ10XHRENTL  27 // H.Ent.Fisica  C [ 5 ][ 0 ] 27
#DEFINE DZ10XDTENTQ  28 // D.Entr.Quali  D [ 8 ][ 0 ] 28
#DEFINE CZ10XHRENTQ  29 // H.Entr.Quali  C [ 5 ][ 0 ] 29
#DEFINE DZ10XDTLBCQ  30 // D.Lib.Quali   D [ 8 ][ 0 ] 30
#DEFINE CZ10XHRLBCQ  31 // H.Lib.Quali   C [ 5 ][ 0 ] 31
#DEFINE CZ10XMOTIVO  32 // Motivo Quali  C [ 6 ][ 0 ] 32
#DEFINE DZ10XDTDISP  33 // D.Ent.Ender.  D [ 8 ][ 0 ] 33
#DEFINE CZ10XHRDISP  34 // H.Ent.Ender.  C [ 5 ][ 0 ] 34
#DEFINE MZ10XOCORRE  35// Ocorrencias   M [10 ][ 0 ] 35
#DEFINE CZ10XARMAZ   36 // Armazem       C [ 2 ][ 0 ] 36
#DEFINE CZ10XSTATUS  37 // Status        C [ 1 ][ 0 ] 37
#DEFINE CZ10XSLA     38 // Status SLA    C [ 1 ][ 0 ] 38

/*/{Protheus.doc} TRK006E
Funcao para gravacao dos logs de entrada
@type function
@version 1.0
@author fernando.muta@dothink.com.br
@since 30/07/2025
@param aTrackE, array, param_description
@param cEvento, character, param_description
@return variant, return_description
/*/
USER FUNCTION TRK006E(aTrackE,cEvento)
local _lNew
local cLog    := ""
local aTrackL := Array(12)
// Verificando existencia do registro
Z10->(DbSetOrder(2))
_lNew := !Z10->(DbSeek(aTrackE[CZ10XFILIAL]+aTrackE[CZ10XFORNEC]+aTrackE[CZ10XLOJFOR]+aTrackE[CZ10XNF]+aTrackE[CZ10XSERIE]+aTrackE[CZ10XITNFM]))
If _lNew
	While .T.
		aTrackE[CZ10XIDTRAC] := GetSx8Num("Z10","Z10_IDTRACK")
		ConfirmSx8()
		// Garante que nao existe o mesmo Idtrack gravado
		Z10->(DbSetOrder(1))
		If !Z10->(DbSeek(aTrackE[CZ10XFILIAL]+aTrackE[CZ10XIDTRAC]))
			Exit
		End
	End
else
	aTrackE[CZ10XIDTRAC] :=  Z10->Z10_IDTRAC
EndIf
RecLock("Z10",_lNew)
If !Empty(CZ10XFILIAL)
    If !_lNew .And. TrkIsEq(Z10->Z10_FILIAL, aTrackE[CZ10XFILIAL] )
        cLog += "Filial Antes: " + Z10->Z10_FILIAL + " Depois: " + aTrackE[CZ10XFILIAL] + Chr(13) + Chr(10)
    EndIf
    Z10->Z10_FILIAL := aTrackE[CZ10XFILIAL]  // Filial        C [ 2 ][ 0 ] 01
EndIf

If !Empty(CZ10XIDTRAC)
    If !_lNew .And. TrkIsEq(Z10->Z10_IDTRAC, aTrackE[CZ10XIDTRAC] )
        cLog += "ID Tracking Antes: " + Z10->Z10_IDTRAC + " Depois: " + aTrackE[CZ10XIDTRAC] + Chr(13) + Chr(10)
    EndIf
    Z10->Z10_IDTRAC :=  aTrackE[CZ10XIDTRAC]  // ID Tracking   C [13 ][ 0 ] 02
EndIf

If !Empty(CZ10XFORNEC)
    If !_lNew .And. TrkIsEq(Z10->Z10_FORNEC, aTrackE[CZ10XFORNEC] )
        cLog += "Fornecedor Antes: " + Z10->Z10_FORNEC + " Depois: " +aTrackE[CZ10XFORNEC] + Chr(13) + Chr(10)
    EndIf
    Z10->Z10_FORNEC :=  aTrackE[CZ10XFORNEC]  // Fornecedor    C [ 6 ][ 0 ] 03
EndIf

If !Empty(CZ10XLOJFOR)
    If !_lNew .And. TrkIsEq(Z10->Z10_LOJFOR, aTrackE[CZ10XLOJFOR] )
        cLog += "Loja Fornec. Antes: " + Z10->Z10_LOJFOR + " Depois: " + aTrackE[CZ10XLOJFOR] + Chr(13) + Chr(10)
    EndIf
    Z10->Z10_LOJFOR :=  aTrackE[CZ10XLOJFOR]  // Loja Fornec.  C [ 2 ][ 0 ] 04
EndIf

If !Empty(CZ10XNFORN)
    If !_lNew .And. TrkIsEq(Z10->Z10_NFORN, aTrackE[CZ10XNFORN] )
        cLog += "Nome Fornec. Antes: " + Z10->Z10_NFORN + " Depois: " + aTrackE[CZ10XNFORN] + Chr(13) + Chr(10)
    EndIf
    Z10->Z10_NFORN :=  aTrackE[CZ10XNFORN ] // Nome Fornec.  C [60 ][ 0 ] 05
EndIf

If !Empty(CZ10XPO)
    If !_lNew .And. TrkIsEq(Z10->Z10_PO, aTrackE[CZ10XPO] )
        cLog += "PO  Antes: " + Z10->Z10_PO + " Depois: " + CZ10XPO + Chr(13) + Chr(10)
    EndIf
    Z10->Z10_PO :=  aTrackE[CZ10XPO]  // PO            C [ 6 ][ 0 ] 06
EndIf

If !Empty(CZ10XITEMPO)
    If !_lNew .And. TrkIsEq(Z10->Z10_ITEMPO,aTrackE[CZ10XITEMPO] )
        cLog += "Item PO Antes: " + Z10->Z10_ITEMPO + " Depois: " + aTrackE[CZ10XITEMPO] + Chr(13) + Chr(10)
    EndIf
    Z10->Z10_ITEMPO :=  aTrackE[CZ10XITEMPO]  // Item PO       C [ 4 ][ 0 ] 07
EndIf

If !Empty(CZ10XNF)
    If !_lNew .And. TrkIsEq(Z10->Z10_NF, aTrackE[CZ10XNF] )
        cLog += "NF Mae Antes: " + Z10->Z10_NF + " Depois: " + aTrackE[CZ10XNF] + Chr(13) + Chr(10)
    EndIf
    Z10->Z10_NF :=  aTrackE[CZ10XNF]  // NF Mae        C [ 9 ][ 0 ] 08
EndIf

If !Empty(CZ10XSERIE)
    If !_lNew .And. TrkIsEq(Z10->Z10_SERIE, aTrackE[CZ10XSERIE] )
        cLog += "Serie NF Mae Antes: " + Z10->Z10_SERIE + " Depois: " + aTrackE[CZ10XSERIE] + Chr(13) + Chr(10)
    EndIf
    Z10->Z10_SERIE :=  aTrackE[CZ10XSERIE]  // Serie NF Mae  C [ 3 ][ 0 ] 09
EndIf

If !Empty(DZ10XDTENNF)
    If !_lNew .And. TrkIsEq(Z10->Z10_DTENNF, aTrackE[DZ10XDTENNF] )
        cLog += "Data Entrada : Antes: " + Z10->Z10_DTENNF + " Depois: " + aTrackE[DZ10XDTENNF] + Chr(13) + Chr(10)
    EndIf
    Z10->Z10_DTENNF :=  aTrackE[DZ10XDTENNF]  // Data Entrada  D [ 8 ][ 0 ] 10
EndIf

If !Empty(CZ10XHRENNF)
    If !_lNew .And. TrkIsEq(Z10->Z10_HRENNF, aTrackE[CZ10XHRENNF] )
        cLog += "Hora Entrada Antes: " + Z10->Z10_HRENNF + " Depois: " + aTrackE[CZ10XHRENNF] + Chr(13) + Chr(10)
    EndIf
    Z10->Z10_HRENNF :=  aTrackE[CZ10XHRENNF]  // Hora Entrada  C [ 5 ][ 0 ] 11
EndIf

If !Empty(CZ10XNFFILH)
    If !_lNew .And. TrkIsEq(Z10->Z10_NFFILH, aTrackE[CZ10XNFFILH] )
        cLog += "NF Filha  Antes: " + Z10->Z10_NFFILH + " Depois: " + aTrackE[CZ10XNFFILH] + Chr(13) + Chr(10)
    EndIf
    Z10->Z10_NFFILH :=  aTrackE[CZ10XNFFILH]  // NF Filha      C [ 9 ][ 0 ] 12
EndIf

If !Empty(CZ10XSERFIL)
    If !_lNew .And. TrkIsEq(Z10->Z10_SERFIL, aTrackE[CZ10XSERFIL] )
        cLog += "Serie Filha Antes: " + Z10->Z10_SERFIL + " Depois: " + aTrackE[CZ10XSERFIL] + Chr(13) + Chr(10)
    EndIf
    Z10->Z10_SERFIL :=  aTrackE[CZ10XSERFIL]  // Serie Filha   C [ 3 ][ 0 ] 13
EndIf

If !Empty(CZ10XITNFM)
    If !_lNew .And. TrkIsEq(Z10->Z10_ITNFM, aTrackE[CZ10XITNFM] )
        cLog += "Item NF Mae Antes: " + Z10->Z10_ITNFM + " Depois: " + aTrackE[CZ10XITNFM] + Chr(13) + Chr(10)
    EndIf
    Z10->Z10_ITNFM :=  aTrackE[CZ10XITNFM]  // Item NF Mae   C [ 4 ][ 0 ] 14
EndIf

If !Empty(CZ10XPRODUT)
    If !_lNew .And. TrkIsEq(Z10->Z10_PRODUT, aTrackE[CZ10XPRODUT] )
        cLog += "Produto Antes: " + Z10->Z10_PRODUT + " Depois: " + aTrackE[CZ10XPRODUT] + Chr(13) + Chr(10)
    EndIf
    Z10->Z10_PRODUT :=  aTrackE[CZ10XPRODUT]  // Produto       C [15 ][ 0 ] 15
EndIf

If !Empty(NZ10XQUANT)
    If !_lNew .And. TrkIsEq(Z10->Z10_QUANT, aTrackE[NZ10XQUANT] )
        cLog += "Quant. Kg Antes: " + Z10->Z10_QUANT + " Depois: " + aTrackE[NZ10XQUANT] + Chr(13) + Chr(10)
    EndIf
    Z10->Z10_QUANT :=  aTrackE[NZ10XQUANT]  // Quant. Kg     N [16 ][ 6 ] 16
EndIf

If !Empty(DZ10XPRVCH)
    If !_lNew .And. TrkIsEq(Z10->Z10_PRVCH, aTrackE[DZ10XPRVCH] )
        cLog += "Prev.Chegada Antes: " + Z10->Z10_PRVCH + " Depois: " + aTrackE[DZ10XPRVCH] + Chr(13) + Chr(10)
    EndIf
    Z10->Z10_PRVCH :=  aTrackE[DZ10XPRVCH]  // Prev.Chegada  D [ 8 ][ 0 ] 17
EndIf

If !Empty(CZ10XLBRAN)
    If !_lNew .And. TrkIsEq(Z10->Z10_LBRAN, aTrackE[CZ10XLBRAN] )
        cLog += "Linha Branca Antes: " + Z10->Z10_LBRAN + " Depois: " + aTrackE[CZ10XLBRAN] + Chr(13) + Chr(10)
    EndIf
    Z10->Z10_LBRAN :=  aTrackE[CZ10XLBRAN]  // Linha Branca  C [ 1 ][ 0 ] 18
EndIf

If !Empty(DZ10XDTENFI)
    If !_lNew .And. TrkIsEq(Z10->Z10_DTENFI, aTrackE[DZ10XDTENFI] )
        cLog += "D.Ent.Fiscal Antes: " + Z10->Z10_DTENFI + " Depois: " + aTrackE[DZ10XDTENFI] + Chr(13) + Chr(10)
    EndIf
    Z10->Z10_DTENFI :=  aTrackE[DZ10XDTENFI]  // D.Ent.Fiscal  D [ 8 ][ 0 ] 19
EndIf

If !Empty(CZ10XHRENFI)
    If !_lNew .And. TrkIsEq(Z10->Z10_HRENFI, aTrackE[CZ10XHRENFI] )
        cLog += "H.Ent.Fiscal  Antes: " + Z10->Z10_HRENFI + " Depois: " + aTrackE[CZ10XHRENFI] + Chr(13) + Chr(10)
    EndIf
    Z10->Z10_HRENFI :=  aTrackE[CZ10XHRENFI]  // H.Ent.Fiscal  C [ 5 ][ 0 ] 20
EndIf

If !Empty(CZ10XPRDREM)
    If !_lNew .And. TrkIsEq(Z10->Z10_PRDREM, aTrackE[CZ10XPRDREM] )
        cLog += "Prod.Remessa  Antes: " + Z10->Z10_PRDREM + " Depois: " + aTrackE[CZ10XPRDREM] + Chr(13) + Chr(10)
    EndIf
    Z10->Z10_PRDREM :=  aTrackE[CZ10XPRDREM]  // Prod.Remessa  C [15 ][ 0 ] 21
EndIf

If !Empty(CZ10XNFREM)
    If !_lNew .And. TrkIsEq(Z10->Z10_NFREM, aTrackE[CZ10XNFREM] )
        cLog += "NF Remessa  Antes: " + Z10->Z10_NFREM + " Depois: " + aTrackE[CZ10XNFREM] + Chr(13) + Chr(10)
    EndIf
    Z10->Z10_NFREM := aTrackE[CZ10XNFREM]  // NF Remessa    C [ 9 ][ 0 ] 22
EndIf

If !Empty(CZ10XSERREM)
    If !_lNew .And. TrkIsEq(Z10->Z10_SERREM, aTrackE[CZ10XSERREM] )
        cLog += "Serie Remess  Antes: " + Z10->Z10_SERREM + " Depois: " + aTrackE[CZ10XSERREM] + Chr(13) + Chr(10)
    EndIf
    Z10->Z10_SERREM :=  aTrackE[CZ10XSERREM]  // Serie Remess  C [ 3 ][ 0 ] 23
EndIf

If !Empty(DZ10XDTNFRE)
    If !_lNew .And. TrkIsEq(Z10->Z10_DTNFRE, aTrackE[DZ10XDTNFRE] )
        cLog += "Dt.NF Remes. Antes: " + Z10->Z10_DTNFRE + " Depois: " + aTrackE[DZ10XDTNFRE] + Chr(13) + Chr(10)
    EndIf
    Z10->Z10_DTNFRE :=  aTrackE[DZ10XDTNFRE]  // Dt.NF Remes.  D [ 8 ][ 0 ] 24
EndIf

If !Empty(CZ10XHRNFRE)
    If !_lNew .And. TrkIsEq(Z10->Z10_HRNFRE, aTrackE[CZ10XHRNFRE] )
        cLog += "Hr.NF Remes.  Antes: " + Z10->Z10_HRNFRE + " Depois: " + aTrackE[CZ10XHRNFRE] + Chr(13) + Chr(10)
    EndIf
    Z10->Z10_HRNFRE :=  aTrackE[CZ10XHRNFRE]  // Hr.NF Remes.  C [ 5 ][ 0 ] 25
EndIf

If !Empty(DZ10XDTENTL)
    If !_lNew .And. TrkIsEq(Z10->Z10_DTENTL, aTrackE[DZ10XDTENTL] )
        cLog += "D.Ent.Fisica Antes: " + Z10->Z10_DTENTL + " Depois: " + aTrackE[DZ10XDTENTL] + Chr(13) + Chr(10)
    EndIf
    Z10->Z10_DTENTL :=  aTrackE[DZ10XDTENTL]  // D.Ent.Fisica  D [ 8 ][ 0 ] 26
EndIf

If !Empty(CZ10XHRENTL)
    If !_lNew .And. TrkIsEq(Z10->Z10_HRENTL, aTrackE[CZ10XHRENTL] )
        cLog += "H.Ent.Fisica Antes: " + Z10->Z10_HRENTL + " Depois: " + aTrackE[CZ10XHRENTL] + Chr(13) + Chr(10)
    EndIf
    Z10->Z10_HRENTL :=  aTrackE[CZ10XHRENTL]  // H.Ent.Fisica  C [ 5 ][ 0 ] 27
EndIf

If !Empty(DZ10XDTENTQ)
    If !_lNew .And. TrkIsEq(Z10->Z10_DTENTQ, aTrackE[DZ10XDTENTQ] )
        cLog += "D.Entr.Quali  Antes: " + Z10->Z10_DTENTQ + " Depois: " + aTrackE[DZ10XDTENTQ] + Chr(13) + Chr(10)
    EndIf
    Z10->Z10_DTENTQ :=  aTrackE[DZ10XDTENTQ]  // D.Entr.Quali  D [ 8 ][ 0 ] 28
EndIf

If !Empty(CZ10XHRENTQ)
    If !_lNew .And. TrkIsEq(Z10->Z10_HRENTQ, aTrackE[CZ10XHRENTQ] )
        cLog += "H.Entr.Quali Antes: " + Z10->Z10_HRENTQ + " Depois: " + aTrackE[CZ10XHRENTQ] + Chr(13) + Chr(10)
    EndIf
    Z10->Z10_HRENTQ :=  aTrackE[CZ10XHRENTQ]  // H.Entr.Quali  C [ 5 ][ 0 ] 29
EndIf

If !Empty(DZ10XDTLBCQ)
    If !_lNew .And. TrkIsEq(Z10->Z10_DTLBCQ, aTrackE[DZ10XDTLBCQ] )
        cLog += "D.Lib.Quali Antes: " + Z10->Z10_DTLBCQ + " Depois: " + aTrackE[DZ10XDTLBCQ] + Chr(13) + Chr(10)
    EndIf
    Z10->Z10_DTLBCQ :=  aTrackE[DZ10XDTLBCQ]  // D.Lib.Quali   D [ 8 ][ 0 ] 30
EndIf

If !Empty(CZ10XHRLBCQ)
    If !_lNew .And. TrkIsEq(Z10->Z10_HRLBCQ, aTrackE[CZ10XHRLBCQ] )
        cLog += "H.Lib.Quali Antes: " + Z10->Z10_HRLBCQ + " Depois: " + aTrackE[CZ10XHRLBCQ] + Chr(13) + Chr(10)
    EndIf
    Z10->Z10_HRLBCQ :=  aTrackE[CZ10XHRLBCQ]  // H.Lib.Quali   C [ 5 ][ 0 ] 31
EndIf

If !Empty(CZ10XMOTIVO)
    If !_lNew .And. TrkIsEq(Z10->Z10_MOTIVO, aTrackE[CZ10XMOTIVO] )
        cLog += "Motivo Quali  Antes: " + Z10->Z10_MOTIVO + " Depois: " + aTrackE[CZ10XMOTIVO] + Chr(13) + Chr(10)
    EndIf
    Z10->Z10_MOTIVO :=  aTrackE[CZ10XMOTIVO]  // Motivo Quali  C [ 6 ][ 0 ] 32
EndIf

If !Empty(DZ10XDTDISP)
    If !_lNew .And. TrkIsEq(Z10->Z10_DTDISP, aTrackE[DZ10XDTDISP] )
        cLog += "D.Ent.Ender. Antes: " + Z10->Z10_DTDISP + " Depois: " + aTrackE[DZ10XDTDISP] + Chr(13) + Chr(10)
    EndIf
    Z10->Z10_DTDISP :=  aTrackE[DZ10XDTDISP]  // D.Ent.Ender.  D [ 8 ][ 0 ] 33
EndIf

If !Empty(CZ10XHRDISP)
    If !_lNew .And. TrkIsEq(Z10->Z10_HRDISP, aTrackE[CZ10XHRDISP] )
        cLog += "H.Ent.Ender. Antes: " + Z10->Z10_HRDISP + " Depois: " + aTrackE[CZ10XHRDISP] + Chr(13) + Chr(10)
    EndIf
    Z10->Z10_HRDISP :=  aTrackE[CZ10XHRDISP]  // H.Ent.Ender.  C [ 5 ][ 0 ] 34
EndIf

If !Empty(MZ10XOCORRE)
    If !_lNew .And. TrkIsEq(Z10->Z10_OCORRE, aTrackE[MZ10XOCORRE] )
        cLog += "Ocorrencias  Antes: " + Z10->Z10_OCORRE + " Depois: " + aTrackE[MZ10XOCORRE] + Chr(13) + Chr(10)
    EndIf
    Z10->Z10_OCORRE :=  aTrackE[MZ10XOCORRE]  // Ocorrencias   M [10 ][ 0 ] 35
EndIf

If !Empty(CZ10XARMAZ)
    If !_lNew .And. TrkIsEq(Z10->Z10_ARMAZ, aTrackE[CZ10XARMAZ] )
        cLog += "Armazem  Antes: " + Z10->Z10_ARMAZ + " Depois: " + aTrackE[CZ10XARMAZ] + Chr(13) + Chr(10)
    EndIf
    Z10->Z10_ARMAZ :=  aTrackE[CZ10XARMAZ]  // Armazem       C [ 2 ][ 0 ] 36
EndIf

If !Empty(CZ10XSTATUS)
    If !_lNew .And. TrkIsEq(Z10->Z10_STATUS,aTrackE[ CZ10XSTATUS] )
        cLog += "Status Antes: " + Z10->Z10_STATUS + " Depois: " + aTrackE[CZ10XSTATUS] + Chr(13) + Chr(10)
    EndIf
    Z10->Z10_STATUS :=  aTrackE[CZ10XSTATUS]  // Status        C [ 1 ][ 0 ] 37
EndIf

If !Empty(CZ10XSLA)
    If !_lNew .And. TrkIsEq(Z10->Z10_SLA, aTrackE[CZ10XSLA] )
        cLog += "Status SLA Antes: " + Z10->Z10_SLA + " Depois: " + aTrackE[CZ10XSLA] + Chr(13) + Chr(10)
    EndIf
    Z10->Z10_SLA :=  aTrackE[CZ10XSLA]  // Status SLA    C [ 1 ][ 0 ] 38
EndIf
Z10->(MsUnlock())

// Gravacao do Log
If !_lNew
	aTrackL[CZ11XFILIAL] := aTrackE[CZ10XFILIAL]
	aTrackL[CZ11XORIG  ] := "Z09"
	aTrackL[CZ11XIDTRAC] := aTrackE[CZ10XIDTRAC]
	aTrackL[CZ11XEVENTO] := cEvento
	aTrackL[CZ11XQUEM  ] := cUserName
	aTrackL[DZ11XQUANDO] := date()
	aTrackL[CZ11XHORA  ] := Time()
	aTrackL[NZ11XRECORI] := Z09->(Recno())
	aTrackL[CZ11XSTAMP ] := dtos(date()) + strtran(time(),":","")
	aTrackL[CZ11XEMPORI] := cEmpAnt
	aTrackL[CZ11XFILORI] := aTrackE[CZ10XFILIAL]
	aTrackL[CZ11XOQUE  ] := cLog
	U_TRK006L(aTrackL)
EndIf

Return _lNew


/*/{Protheus.doc} TrkIsEq
Validacao se grava no log de alteracoes
@type function
@version 1.0
@author fernando.muta@dothink.com.br
@since 30/07/2025
@param aTrackE, array, param_description
@param cEvento, character, param_description
@return variant, return_description
/*/

Static Function TrkIsEq(xGravado, xNovo)
Local lRet := .F.

If ValType(xGravado) == "C"
    lRet := Lower(Alltrim(xGravado)) != Lower(Alltrim(xNovo))
ElseIf ValType(xGravado) == "D"
    lRet := xGravado != xNovo
ElseIf ValType(xGravado) == "N"
    lRet := xGravado != xNovo
Else
    lRet := xGravado != xNovo
EndIf

Return lRet
