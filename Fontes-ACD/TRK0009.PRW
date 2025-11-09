#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "DBTREE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ACDA100  ³ Autor ³ Eduardo Motta         ³ Data ³ 06/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina de geracao da ordem de separacao                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/* 
Parametros utilizados (pergunte):

AIA101
MV_PAR01 - Opcao: Pedidos de Venda / Notas Fiscais / Ordens de Producao

 
Pedidos de Venda:
-----------------

AIA106   - Parametros - Brasil
MV_PAR01 - Confere Lote        ? Sim/Nao
MV_PAR02 - Embal Simultanea    ? Sim/Nao
MV_PAR03 - Embalagem           ? Sim/Nao
MV_PAR04 - Gera Nota           ? Sim/Nao
MV_PAR05 - Imprime Nota        ? Sim/Nao
MV_PAR06 - Imprime Etiq.Volume ? Sim/Nao
MV_PAR07 - Embarque            ? Sim/Nao
MV_PAR08 - Aglutina Pedido     ? Sim/Nao
MV_PAR09 - Aglutina Armazem    ? Sim/Nao
MV_PAR10 - Prioriza Endereco   ? Sim/Nao

AIA106   - Parametros -  Outros Países
MV_PAR01 - Confere Lote        ? Sim/Nao
MV_PAR02 - Embal Simultanea    ? Sim/Nao
MV_PAR03 - Embalagem           ? Sim/Nao
MV_PAR04 - Imprime Etiq.Volume ? Sim/Nao
MV_PAR05 - Embarque            ? Sim/Nao
MV_PAR06 - Aglutina Pedido     ? Sim/Nao
MV_PAR07 - Aglutina Armazem    ? Sim/Nao
MV_PAR08 - Prioriza Endereco   ? Sim/Nao

AIA102   - Filtros
MV_PAR01 - Separador           ?
MV_PAR02 - Pedido de           ?
MV_PAR03 - Pedido ate          ?
MV_PAR04 - Cliente de          ?
MV_PAR05 - Loja Cliente de     ?
MV_PAR06 - Cliente ate         ?
MV_PAR07 - Loja Cliente ate    ?
MV_PAR08 - Data Liberacao de   ?
MV_PAR09 - Data Liberacao ate  ?
MV_PAR10 - Pre-Separacao       ? Sim/Nao


Notas Fiscais:
--------------

AIA107   - Parametros
MV_PAR01 - Embal Simultanea    ? Sim/Nao
MV_PAR02 - Embalagem           ? Sim/Nao
MV_PAR03 - Imprime Nota        ? Sim/Nao
MV_PAR04 - Imprime Etiq.Volume ? Sim/Nao
MV_PAR05 - Embarque            ? Sim/Nao

AIA103   - Filtros
MV_PAR01 - Separador           ?
MV_PAR02 - Nota de             ?
MV_PAR03 - Serie de            ?
MV_PAR04 - Nota ate            ?
MV_PAR05 - Serie ate           ?
MV_PAR06 - Cliente de          ?
MV_PAR07 - Loja Cliente de     ?
MV_PAR08 - Cliente ate         ?
MV_PAR09 - Loja Cliente ate    ?
MV_PAR10 - Data emissao de     ?
MV_PAR11 - Data emissao ate    ?

         
Ordens de Producao:
-------------------

AIA108   - Parametros
MV_PAR01 - Requisita material  ? Sim/Nao
MV_PAR02 - Aglutina Armazem    ? Sim/Nao

AIA104   - Filtros
MV_PAR01 - Separador           ?
MV_PAR02 - Op de               ?
MV_PAR03 - Op ate              ?
MV_PAR04 - Data emissao de     ?
MV_PAR05 - Data emissao ate    ?
MV_PAR06 - Pre-Separacao       ?


*/


//-- U_TRK0009A
User Function TRK0009A()
Private nOSOpc := 1
Return U_TRK0009X()


//-- U_TRK0009B
User Function TRK0009B()
Private nOSOpc := 2
Return U_TRK0009X()


User Function TRK0009X()
Local aCores    := {}
Local aCoresUsr := {}

PRIVATE aRotina := {}

PRIVATE cCadastro := ""
PRIVATE aRecno:={}
PRIVATE aHeader := {}

//Configuracoes da pergunte AIA106 (Pedidos de Venda), ativado pela tecla F12:
PRIVATE nConfLote
PRIVATE nEmbSimul
PRIVATE nEmbalagem
PRIVATE nGeraNota
PRIVATE nImpNota
PRIVATE nImpEtVol
PRIVATE nEmbarque
PRIVATE nAglutPed
PRIVATE nAglutArm
PRIVATE nPriorEnd
//Configuracoes da pergunte AIA107 (Notas Fiscais), ativado pela tecla F12:
PRIVATE nEmbSimuNF
PRIVATE nEmbalagNF
PRIVATE nImpNotaNF
PRIVATE nImpVolNF
PRIVATE nEmbarqNF
//Configuracoes da pergunte AIA108 (Ordens de Producao), ativado pela tecla F12:
PRIVATE nReqMatOP
PRIVATE nAglutArmOP
PRIVATE nPreSep

//configuração das perguntas
STATIC aPerg100	:= {}

aRotina   := MenuDef()
cCadastro := OemtoAnsi(IIF(nOSOpc==1, "Validação Física", "Ordens de Separação")) //"Ordens de separacao"

If nOSOpc == 1
    aAdd(aCores, {"CB7->CB7_XDIVER == '1'"      , "PMSTASK1"})
    aAdd(aCores, {"CB7->CB7_XSTATP == '1'"      , "PMSTASK3"})
    aAdd(aCores, {"CB7->CB7_XSTATU == '9'"      , "PMSTASK4"})
    aAdd(aCores, {"CB7->CB7_XSTATU $ '12345678'", "PMSTASK2"})
    aAdd(aCores, {"CB7->CB7_XSTATU == '0'"      , "PMSTASK6"})
Else
    aAdd(aCores, {"CB7->CB7_DIVERG == '1'"      , "DISABLE"   })
    aAdd(aCores, {"CB7->CB7_STATPA == '1'"      , "BR_CINZA"  })
    aAdd(aCores, {"CB7->CB7_STATUS == '9'"      , "ENABLE"    })
    aAdd(aCores, {"CB7->CB7_STATUS $ '12345678'", "BR_AMARELO"})
    aAdd(aCores, {"CB7->CB7_STATUS == '0'"      , "BR_AZUL"   })
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada para inclusão de nova COR da legenda       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
If ExistBlock("ACD100CR")
	aCoresUsr := ExecBlock("ACD100CR",.F.,.F.,{aCores})
	If ValType(aCoresUsr) == "A"
		aCores := aClone(aCoresUsr)
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa tecla F12 para acionar perguntas                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetKey(VK_F12,{||AtivaF12()})
mBrowse( 6, 1, 22, 75, "CB7", , , , , , aCores, , , ,{|x|TimerBrw(x)})
SetKey(VK_F12,Nil)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³VSACDA100 ³ Autor ³ Eduardo Motta         ³ Data ³ 06/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de visualizacao da Ordem de Separacao             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void VSACDA100(ExpC1,ExpN1,ExpN2)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function VSACDA100(cAlias,nReg,nOpcx)
Local oDlg
Local oGet

Local cSeekCB8  := CB8->(xFilial("CB8")) + CB7->CB7_ORDSEP
Local aSize     := {}
Local aInfo     := {}
Local aObjects  := {}
Local aButtons  := {}
Local lEmbal    := ("01" $ CB7->CB7_TIPEXP) .OR. ("02" $ CB7->CB7_TIPEXP)
Local aHeadAUX	:= {}
Local nI

Private oTimer
Private Altera  := .F.
Private Inclui  := .F.
Private aHeader := {}
Private aCols   := {}
Private aTela   := {},aGets := {}

Private cBmp1 := "PMSEDT3" //"PMSDOC"  //"FOLDER5" //"PMSMAIS"  //"SHORTCUTPLUS"
Private cBmp2 := "PMSDOC" //"PMSEDT3" //"FOLDER6" //"PMSMENOS" //"SHORTCUTMINUS"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe algum dado no arquivo de Itens            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CB8->(DbSetOrder(1))
If ! CB8->( dbSeek( cSeekCB8 ) )
	Return .T.
EndIf

If lEmbal
	aadd(aButtons, {'AVGBOX1',{||MsgRun("Carregando consulta, aguarde...","Ordem de Separação",{|| ConsEmb() })},"Embalagens","Embalagens"}) //"Carregando consulta, aguarde..."###"Ordem de Separação"###"Embalagens"###"Embalagens"
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona botoes do usuario na EnchoiceBar                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "ACD100BUT" )
	If ValType( aUsButtons := ExecBlock( "ACD100BUT", .F., .F., {nOpcx} ) ) == "A"
		AEval( aUsButtons, { |x| AAdd( aButtons, x ) } )
	EndIf
EndIf

RegToMemory("CB7")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o cabecalho                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aHeadAUX	:= aClone(APBuildHeader("CB8"))
For nI := 1 to Len(aHeadAUX)
	If X3USO(aHeadAUX[nI,7]) .and. alltrim(aHeadAUX[nI,2]) <> "CB8_ORDSEP" .and. cNivel >= GetSx3Cache(trim(aHeadAUX[nI,2]), "X3_NIVEL") 
		Aadd(aHeader,aHeadAUX[nI])
	EndIf
Next nI 

MontaCols(cSeekCB8)

aSize   := MsAdvSize()
aAdd(aObjects, {100, 130, .T., .F.})
aAdd(aObjects, {100, 200, .T., .T.})
aInfo   := {aSize[1], aSize[2], aSize[3], aSize[4], 2, 2}
aPosObj := MsObjSize(aInfo, aObjects)

DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCadastro) From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL //"Ordens de separacao - Visualizacao"
oEnc:=MsMget():New(cAlias,nReg,nOpcx,,,,,{aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]},,3,,,,,,.t.)
oGet:=MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4], nOpcx,"AllWaysTrue","AllWaysTrue", ,.F.)

DEFINE TIMER oTimer INTERVAL 1000 ACTION MontaCols(cSeekCB8,oGet) OF oDlg
oTimer:Activate()

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,oDlg:End()},{||oDlg:End()},,aButtons)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ALACDA100 ³ Autor ³ Eduardo Motta         ³ Data ³ 06/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de alteracao do Ordem de Separacao                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void ALACDA100(ExpC1,ExpN1,ExpN2)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada no menu                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ALACDA100(cAlias,nReg,nOpcx)
Local oDlg
Local cSeekCB8 := xFilial("CB8") + CB7->CB7_ORDSEP
Local nOpca := 0
Local nI,nJ
Local nPosDel:=0
Local lAltEmp:=(CB7->CB7_ORIGEM $ '1|3')
Local nDel
Local lContinua := .T.

Local aSize     := {}
Local aInfo     := {}
Local aObjects  := {}
Local aButtons  := {}
Local aHeadAUX	:= {}
Local aHeadCBC	:= {}
Local aItensTrc := {}
Local nPos		:= 0
Local nX		:= 0
Local nQtdSep   := 0
Local cItemAnt  := ''
Local aEmpPrtBkp:= {}	
Local aDadosSD4 := {}
Local aGRLog    := {}
Local cGRLog    := ""
Local cQuery    := ""

Private oGet
Private Altera  := .T.
Private Inclui  := .F.
Private aHeader := {}
Private aCols   := {}
Private aAcolsOri	  := {}
Private lAlterouEmp := .f.
Private lDiverg     := .f.
Private nItensCB8   := 0

CB8->(DbSetOrder(1))
If nOSOpc == 1
    If CB7->CB7_XSTATU == "9" .or. ! CB8->( dbSeek( cSeekCB8 ) )
        MsgAlert( "Validacao fisica concluida.", "Aviso" )
        Return
    EndIf
Else
    If CB7->CB7_STATUS == "9" .or. ! CB8->( dbSeek( cSeekCB8 ) )
        MsgAlert( "Ordem de separacao concluida.", "Aviso" ) 	 //"Ordem de separacao concluida."###"Aviso"
        Return
    EndIf
EndIf

If lAltEmp
	aadd(aButtons, {'RELOAD',{||AltEmp(aHeader,aCols)},"Alt.Empenhos","Alt.Empenhos"}) //"Alt.Empenhos"###"Alt.Empenhos"
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona botoes do usuario na EnchoiceBar                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "ACD100BUT" )
	If ValType( aUsButtons := ExecBlock( "ACD100BUT", .F., .F., {nOpcx} ) ) == "A"
		AEval( aUsButtons, { |x| AAdd( aButtons, x ) } )
	EndIf
EndIf

RegToMemory("CB7")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o cabecalho                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeadAUX	:= aClone(APBuildHeader("CB8"))
For nI := 1 to Len(aHeadAUX)
	If X3USO(aHeadAUX[nI,7]) .and. cNivel >= GetSx3Cache(trim(aHeadAUX[nI,2]), "X3_NIVEL") 
		Aadd (aHeadCBC,aHeadAUX[nI])
	EndIf
Next nI 

MontaCols(cSeekCB8)
aColsOri := aClone(aCols)

aSize   := MsAdvSize()
aAdd(aObjects, {100, 130, .T., .F.})
aAdd(aObjects, {100, 200, .T., .T.})
aInfo   := {aSize[1], aSize[2], aSize[3], aSize[4], 2, 2}
aPosObj := MsObjSize(aInfo, aObjects)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para validar a abertura do dialog de alteracao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("AC100VLA")
	lContinua := ExecBlock("AC100VLA")
EndIf

If lContinua
	DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCadastro) From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL //"Ordens de separacao - Alteracao"
	oEnc:=MsMget():New(cAlias,nReg,nOpcx,,,,,{aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]},,3,,,,,,.t.)
	oGet:= MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4], nOpcx,"U_ACD100LinOK","U_ACD100TudOK",,.T.,Nil,Nil,Nil,Len(aCols))
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,if(oGet:TudoOk(),oDlg:End(),nOpca := 0)},{||oDlg:End()},,aButtons)
	
	If nOpca == 1
	   
		// -----------------------------------------------------------------------
		//Valida se todas as linhas foram excluidas, nao permitindo via alteracao:
		nPosDel := Len(aHeader)+1
		nDel    := 0
		aEval(aCols,{|x| If(x[nPosDel],nDel++,nil)})
		
		If nDel == Len(aCols)
			MsgAlert( "Para excluir todos os itens acessar a rotina de Estorno da Ordem de Separacao!", "Aviso" ) //"Para excluir todos os itens acessar a rotina de Estorno da Ordem de Separacao!"###"Aviso"
			Return
		Endif 
	
		lDiverg   := .F.
		nItensCB8 := 0
		Begin Transaction
	
			If !lAlterouEmp
	
				//----------------------------------------------------------------------------------------------
				//Estorna as informacoes sobre a Ordem de Separacao nas tabelas do sistema caso itens deletados:
				LimpaInfoOS()
	
				//---------------------------------------------------------------------------
				// Caso houve apenas alteracoes em campos do CB8, sem alteracoes de empenhos:
				CB8->(DbSetOrder(1))
				For nI := 1 to Len(aCols)
					If aCols[nI,nPosDel]
						Loop
					Endif
					++nItensCB8
					CB8->(DbGoto(aRecno[nI]))
					CB8->(RecLock("CB8"))
					For nJ := 1 to len(aHeader)
						If aHeader[nJ,10] == "V"
							Loop
						EndIf
						CB8->&(AllTrim(aHeader[nJ,2])) := aCols[nI,nJ]
					Next
					If !Empty(CB8->CB8_OCOSEP) .and. (CB8->CB8_SALDOS-CB8->CB8_QTECAN) > 0
						lDiverg := .T.
					EndIf
					CB8->(MsUnlock())
				Next
			
			Else
				
				//----------------------------------------------------------------------------------------------
				//Estorna as informacoes sobre a Ordem de Separacao nas tabelas do sistema caso itens deletados:
				LimpaInfoOS()
	
				lAutoErrNoFile := .T.
				//--------------------------------------------
				//Estorna os empenhos de todos os itens da OS:
				AutoGrLog("    MANUTENÇÃO AUTOMÁTICA DOS EMPENHOS" ) // "    MANUTENÇÃO AUTOMÁTICA DOS EMPENHOS" 
				AutoGrLog("-------------------------------------------")
				AutoGrLog("Atualizações da Ordem de Separação: " + Alltrim (CB7->CB7_ORDSEP)) //"Atualizações da Ordem de Separação: "
				AutoGrLog("   *** EXCLUSÃO DOS EMPENHOS") //"   *** EXCLUSÃO DOS EMPENHOS"
				AutoGrLog(" ")
					
				If !ProcAtuEmp(aColsOri,.t.,@aDadosSD4)
					AutoGrLog("Ocorreu um erro no estorno dos empenhos da OS!") //"Ocorreu um erro no estorno dos empenhos da OS!"
					AutoGrLog("Processo abortado!") //"Processo abortado!"
					DisarmTransaction()
					Break
				EndIf
	
				//--------------------------------------------------------------------------------------
				//Deleta os itens da Ordem de Separacao e grava novos registros com base nas alteracoes:
				GravaCB8()		
				CB8->(DbSetOrder(1))
				CB8->(MsSeek(xFilial("CB8")+CB7->CB7_ORDSEP))
				While !CB8->(Eof()) .And. CB8->CB8_ORDSEP == CB7->CB7_ORDSEP
					nPos := aScan(aItensTrc,{|x| x[1]+x[2] == CB8->CB8_PEDIDO+CB8->CB8_ITEM})
				 	If nPos == 0
				 		aAdd(aItensTrc, {CB8->CB8_PEDIDO, CB8->CB8_ITEM, CB8->CB8_SEQUEN, CB8->CB8_QTDORI, CB8->CB8_LOTECT, CB8->CB8_NUMLOT,CB8->CB8_PROD, CB8->CB8_LOCAL, {}})
				 		nPos := len(aItensTrc)
						nQtdSep += CB8->CB8_QTDORI
				 	Else
				 		aItensTrc[nPos][4] += CB8->CB8_QTDORI
				 		nQtdSep += CB8->CB8_QTDORI
				 	EndIf
				 	aAdd(aItensTrc[nPos,9],	{	CB8->CB8_LOTECT,; // 1
												CB8->CB8_NUMLOT,; // 2
												CB8->CB8_LCALIZ,; // 3
												CB8->CB8_NUMSER,; // 4
												CB8->CB8_QTDORI,; // 5
												ConvUM(CB8->CB8_PROD,CB8->CB8_QTDORI,0,2),; // 6
												Posicione("SB8",3,xFilial("SB8")+CB8->CB8_PROD+CB8->CB8_LOCAL+CB8->CB8_LOTECT+CB8->CB8_NUMLOT,"B8_DTVALID"),; // 7
												,; // 8
												,; // 9
												,; // 10
												CB8->CB8_LOCAL,; // 11
												0})
 					CB8->(DbSkip())
				EndDo
	
				SC9->(DbSetOrder(1))

				For nx := 1 to Len(aItensTrc)
					If SC9->(MsSeek(xFilial("SC9")+aItensTrc[nX][1]+aItensTrc[nX][2]+aItensTrc[nX][3]))
						If !Empty(SC9->C9_ORDSEP) 
							Reclock("SC9",.F.)
							SC9->C9_ORDSEP := ''
							MsUnlock()
						EndIf
						SC9->(a460Estorna())
					EndIf
				Next nX				

				CB8->(MsSeek(xFilial("CB8")+CB7->CB7_ORDSEP))
				For nX := 1 to Len(aItensTrc)
					If SC6->(MsSeek(xFilial("SC6")+aItensTrc[nX][1]+aItensTrc[nX][2]))
						If cItemAnt != aItensTrc[nX][1]+aItensTrc[nX][2]
							aEmpPrtBkp := aItensTrc[nX,9]
							MaLibDoFat(SC6->(Recno()),nQtdSep,.T.,.T.,.F.,.F.,.F.,.F.,NIL,{||SC9->C9_ORDSEP := CB7->CB7_ORDSEP},aEmpPrtBkp,.T.)
						EndIf
					EndIf
					cItemAnt := aItensTrc[nX][1]+aItensTrc[nX][2]
				Next nX
				//---------------------------------------
				//Refaz empenhos de todos os itens da OS:
				AutoGrLog("   *** INCLUSÃO DOS EMPENHOS") //"   *** INCLUSÃO DOS EMPENHOS"
				AutoGrLog(" ")
	
				If !ProcAtuEmp(aCols,.f.,aDadosSD4)
					AutoGrLog("Ocorreu um erro no estorno dos empenhos da OS!") //"Ocorreu um erro no estorno dos empenhos da OS!"
					AutoGrLog("Processo abortado!") //"Processo abortado!"
					DisarmTransaction()
					Break
				EndIf

				If lAltEmp
					If Select("_QRYCHK") > 0
						_QRYCHK->(dbCloseArea())
					EndIf

					cQuery := " SELECT (TRB1.C9_QTDLIB - TRB2.CB8_QTDORI) DIFF "
					cQuery += " FROM ( "
					cQuery += " SELECT C9_FILIAL, C9_PEDIDO, C9_ITEM, C9_PRODUTO, C9_LOTECTL, SUM(C9_QTDLIB) C9_QTDLIB "
					cQuery += " FROM " + RetSQLName("SC9") + " SC9 "
					cQuery += " WHERE C9_FILIAL = '" + xFilial("SC9") + "' "
					cQuery += " AND C9_PEDIDO = '" + CB7->CB7_PEDIDO + "' "
					cQuery += " AND SC9.D_E_L_E_T_ = ' ' "
					cQuery += " GROUP BY C9_FILIAL, C9_PEDIDO, C9_ITEM, C9_PRODUTO, C9_LOTECTL "
					cQuery += " ) TRB1 "
					cQuery += " LEFT JOIN ( "
					cQuery += " SELECT CB8_FILIAL, CB8_PEDIDO, CB8_ITEM, CB8_PROD, CB8_LOTECT, SUM(CB8_QTDORI) CB8_QTDORI "
					cQuery += " FROM " + RetSQLName("CB8") + " CB8 "
					cQuery += " WHERE CB8_FILIAL = '" + xFilial("CB8") + "' "
					cQuery += " AND CB8_PEDIDO = '" + CB7->CB7_PEDIDO + "' "
					cQuery += " AND CB8.D_E_L_E_T_ = ' ' "
					cQuery += " GROUP BY CB8_FILIAL, CB8_PEDIDO, CB8_ITEM, CB8_PROD, CB8_LOTECT "
					cQuery += " ) TRB2 "
					cQuery += " ON TRB2.CB8_FILIAL = TRB1.C9_FILIAL "
					cQuery += " AND TRB2.CB8_PEDIDO = TRB1.C9_PEDIDO "
					cQuery += " AND TRB2.CB8_ITEM = TRB1.C9_ITEM "
					cQuery += " AND TRB2.CB8_PROD = TRB1.C9_PRODUTO "
					cQuery += " AND TRB2.CB8_LOTECT = TRB1.C9_LOTECTL "

					cQuery := ChangeQuery(cQuery)
					TCQUERY cQuery NEW ALIAS "_QRYCHK"

					dbSelectArea("_QRYCHK")
					_QRYCHK->(dbGoTop())
					While _QRYCHK->(!EoF())
						If !Empty(_QRYCHK->DIFF)
							If IsBlind()
								AutoGrLog("Ocorreu um erro no processo de alteracao de empenho onde as tabelas CB8 e SC9 ficaram desbalanceadas, o processo foi abortado!")
								AutoGrLog("Processo abortado!")
							Else
								Help(Nil, Nil, "NAOALTEMP", Nil, "Ocorreu um erro no processo de alteracao de empenho onde as tabelas CB8 e SC9 ficaram desbalanceadas, o processo foi abortado!", 1, 0)
							EndIf

							DisarmTransaction()
							Break
						EndIf
						
						_QRYCHK->(dbSkip())
					EndDo

					If Select("_QRYCHK") > 0
						_QRYCHK->(dbCloseArea())
					EndIf
				EndIf
	
				AutoGrLog(" ")
				AutoGrLog("Manutenção dos Lotes Finalizada.") //"Manutenção dos Lotes Finalizada."
				//MostraErro()
				aGRLog := GetAutoGRLog()

				//-- Percorre todas as linhas do log
				For nX := 1 To Len(aGRLog)
					cGRLog += aGRLog[nX] + CRLF
				Next nX

				cItemAnt := ""
				For nX := 1 to Len(aItensTrc)
					If SC6->(MsSeek(xFilial("SC6")+aItensTrc[nX][1]+aItensTrc[nX][2]))
						If cItemAnt != aItensTrc[nX][1]+aItensTrc[nX][2]
							SetTraking("2", SC6->C6_NUM, SC6->C6_ITEM, Nil, cGRLog, "Altualização de Empenho")
						EndIf
					EndIf
					cItemAnt := aItensTrc[nX][1]+aItensTrc[nX][2]
				Next nX
			Endif
			
			//----------------------------
			//Atualiza informacoes em CB7:
			AtuCB7()
					
		End Transaction
	
		//--- P.E. apos gravacao da alteracao O.S.
		If	ExistBlock("ACD100ALT")
			ExecBlock("ACD100ALT",.f.,.f.)
		EndIf
		
	EndIf
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ A100LinOK º Autor ³ Henrique Gomes Oikawa º Data ³  28/02/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Validacao da linha na alteracao da Ordem de Separacao          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAACD                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function ACD100LinOK()
Local lRet    := .F.
Local lPreSep :=("09*" $ CB7->CB7_TIPEXP)
Local nPosDel:= Len(aHeader)+1

If	aCols[n,nPosDel] //item deletado...
	lRet := .F.
    If nOSOpc == 1
        If	CB7->CB7_XSTATU == "0"
            lRet := .T.
        ElseIf	CB7->CB7_XSTATP == '1'
            If	aCols[n,GDFieldPos("CB8_QTDORI")] == aCols[n,GDFieldPos("CB8_SALDOS")] //O produto ainda nao foi separado...
                lRet := .T.
            Else
                If	lPreSep
                    MsgAlert( "A Ordem de Pre-Separacao "+CB7->CB7_ORDSEP+" possui produtos separados!", "Aviso" ) //"A Ordem de Pre-Separacao "###" possui produtos separados!"###"Aviso"
                Else
                    MsgAlert( "A Ordem de Separacao "+CB7->CB7_ORDSEP+" possui produtos validados!", "Aviso" ) //"A Ordem de Separacao "###" possui produtos separados!"###"Aviso"
                Endif
            Endif
        ElseIf	CB7->CB7_XSTATP != '1'
            If	lPreSep
                MsgAlert( "A Ordem de Pre-Separacao "+CB7->CB7_ORDSEP+" esta em andamento!", "Aviso" ) //"A Ordem de Pre-Separacao "###" esta em andamento!"###"Aviso"
            Else
                MsgAlert( "A validacao fisica "+CB7->CB7_ORDSEP+" esta em andamento!", "Aviso" ) //"A Ordem de Separacao "###" esta em andamento!"###"Aviso"
            Endif
        Endif
    Else
        If	CB7->CB7_STATUS == "0"
            lRet := .T.
        ElseIf	CB7->CB7_STATPA == '1'
            If	aCols[n,GDFieldPos("CB8_QTDORI")] == aCols[n,GDFieldPos("CB8_SALDOS")] //O produto ainda nao foi separado...
                lRet := .T.
            Else
                If	lPreSep
                    MsgAlert( "A Ordem de Pre-Separacao "+CB7->CB7_ORDSEP+" possui produtos separados!", "Aviso" ) //"A Ordem de Pre-Separacao "###" possui produtos separados!"###"Aviso"
                Else
                    MsgAlert( "A Ordem de Separacao "+CB7->CB7_ORDSEP+" possui produtos separados!", "Aviso" ) //"A Ordem de Separacao "###" possui produtos separados!"###"Aviso"
                Endif
            Endif
        ElseIf	CB7->CB7_STATPA != '1'
            If	lPreSep
                MsgAlert( "A Ordem de Pre-Separacao "+CB7->CB7_ORDSEP+" esta em andamento!", "Aviso" ) //"A Ordem de Pre-Separacao "###" esta em andamento!"###"Aviso"
            Else
                MsgAlert( "A Ordem de Separacao "+CB7->CB7_ORDSEP+" esta em andamento!", "Aviso" ) //"A Ordem de Separacao "###" esta em andamento!"###"Aviso"
            Endif
        Endif
    EndIf
Else
	lRet:= .T.
Endif
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ A100TudOK º Autor ³ Henrique Gomes Oikawa º Data ³  28/02/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Validacao Tudo OK na alteracao da Ordem de Separacao           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAACD                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function ACD100TudOK()
Local nX
Local nLinhas := 0
Local nPosDel := Len(aHeader)+1
Local lRet    := .T.

For nX:= 1 to Len(aCols)
	If ! aCols[nX,nPosDel]
		nLinhas++
	Endif
Next

If nLinhas < 1 // Tem que ter no minimo uma linha
	lRet := .f.
Endif

Return lRet


/*/{Protheus.doc} ETACDA100
Programa de estorno da Ordem de Separacao 
@type function
@version 1.0
@author dener.lemos@dothink.com.br
@since 22/07/2025
@param cAlias, character, Alias
@param nReg, numeric, registro posicionado
@param nOpcx, numeric, opcao de execucao
@param lAuto, logical, indica se é rotina automática
/*/
User Function ETACDA100(cAlias,nReg,nOpcx, lAuto)

Local oDlg
Local oGet
Local cSeekCB8 := xFilial("CB8") + CB7->CB7_ORDSEP
Local nI,nJ
Local nOpca := 0
Local lContinua := .T.

Local aSize      := {}
Local aInfo      := {}
Local aObjects   := {}
Local aHeadAUX	 := {}
Local nPosPed    := 0
Local nPosItPed  := 0
Local nPosSeqPed := 0
Local cMsgAlert  := "" 
Local cItemAnt   := ""
Local aPVs       := {}
Local cChave     := ""
Local cTitRotina := ""

Private Altera  := .F.
Private Inclui  := .F.
Private aHeader := {}
Private aCols   := {}
Private aTela   := {},aGets := {}

Default lAuto := .F.

Private l100Auto := lAuto

CB8->(DbSetOrder(1)) // Forca a utilizacao do indice de ordem 1, pois o programa estava se perdendo (by Erike)
If nOSOpc == 1
	cTitRotina := "Validação Física"
    Z12->(DbSetOrder(1))
    If CB7->CB7_XSTATU == "9"
		cMsgAlert := "Esta validacao fisica não pode ser estornada, pois a mesma já está Finalizada."
		If l100Auto
			aAdd(aFileLog, cMsgAlert)
		Else
			MsgAlert(cMsgAlert,"Aviso")
		EndIf
        Return
    ElseIf CB7->CB7_XSTATU # "0" .and. Empty(CB7->CB7_XSTATP)
		cMsgAlert := "Esta validacao fisica nao pode ser estornada pois a mesma esta sendo executada neste momento"
		If l100Auto
			aAdd(aFileLog, cMsgAlert)
		Else
			MsgAlert(cMsgAlert,"Aviso")
		EndIf
		Return
    ElseIf CB7->CB7_XSTATU # "0" .and. Z12->(DbSeek(xFilial("Z12")+CB7->CB7_ORDSEP))
		cMsgAlert := "A validacao fisica nao pode ter nenhuma movimentacao para ser estornada."
		If l100Auto
			aAdd(aFileLog, cMsgAlert)
		Else
			MsgAlert(cMsgAlert,"Aviso")
		EndIf
		Return
    EndIf
Else
	cTitRotina := "Ordem de Separação"
    CB9->(DbSetOrder(1))
    If CB7->CB7_STATUS == "9"
		cMsgAlert := "Esta Ordem de separação não pode ser estornada, pois a mesma já está Finalizada."
		If l100Auto
			aAdd(aFileLog, cMsgAlert)
		Else
			MsgAlert(cMsgAlert,"Aviso") //"Esta Ordem de separação não pode ser estornada, pois a mesma já está Finalizada."###"Aviso"
		EndIf
        Return
    ElseIf CB7->CB7_STATUS # "0" .and. Empty(CB7->CB7_STATPA)
		cMsgAlert := "Esta Ordem de separação não pode ser estornada pois a mesma esta sendo executada neste momento"
		If l100Auto
			aAdd(aFileLog, cMsgAlert)
		Else
			MsgAlert(cMsgAlert,"Aviso") //"Esta Ordem de separacao nao pode ser estornada pois a mesma esta sendo executada neste momento"###"Aviso"
		EndIf
		Return
    ElseIf CB7->CB7_STATUS # "0" .and. CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP))
		cMsgAlert := "A Ordem de separação não pode ter nenhuma movimentação para ser estornada."
		If l100Auto
			aAdd(aFileLog, cMsgAlert)
		Else
			MsgAlert(cMsgAlert, "Aviso" ) //"A Ordem de Separacao nao pode ter nenhuma movimentacao para ser estornada."###"Aviso"
		EndIf
        Return
	ElseIf CB7->CB7_XSTATU == "9"
		cMsgAlert := "Esta Ordem de separação não pode ser estornada, pois a validação fisica já está Finalizada."
		If l100Auto
			aAdd(aFileLog, cMsgAlert)
		Else
			MsgAlert(cMsgAlert,"Aviso")
		EndIf
        Return
    ElseIf CB7->CB7_XSTATU # "0" .and. Empty(CB7->CB7_XSTATP)
		cMsgAlert := "Esta Ordem de separação não pode ser estornada, pois a validação fisica esta sendo executada neste momento"
		If l100Auto
			aAdd(aFileLog, cMsgAlert)
		Else
			MsgAlert(cMsgAlert,"Aviso")
		EndIf
		Return
    ElseIf CB7->CB7_XSTATU # "0" .and. Z12->(DbSeek(xFilial("Z12")+CB7->CB7_ORDSEP))
		cMsgAlert := "A Ordem de separação não pode ter nenhuma movimentação de validação fisica para ser estornada."
		If l100Auto
			aAdd(aFileLog, cMsgAlert)
		Else
			MsgAlert(cMsgAlert,"Aviso")
		EndIf
		Return
    EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe algum dado no arquivo de Itens            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If ! CB8->( dbSeek( cSeekCB8 ) )
	Return .T.
EndIf

If ExistBlock('ACD100VE')
	lContinua := ExecBlock('ACD100VE',.F.,.F.)
	If Valtype(lContinua)#'L'
		lContinua := .T.
	EndIf
	If !lContinua
		Return
	EndIf
EndIf

RegToMemory("CB7")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o cabecalho                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeadAUX	:= aClone(APBuildHeader("CB8"))
For nI := 1 to Len(aHeadAUX)
	If X3USO(aHeadAUX[nI,7]) .and. cNivel >= GetSx3Cache(trim(aHeadAUX[nI,2]), "X3_NIVEL") .And. AllTrim( aHeadAUX[nI,2] ) <> "CB8_ORDSEP"
		Aadd (aHeader,aHeadAUX[nI])
	EndIf
Next nI 

nPosPed    := ASCAN(aHeader,{|x| UPPER(AllTrim(x[2]))=="CB8_PEDIDO"})
nPosItPed  := ASCAN(aHeader,{|x| UPPER(AllTrim(x[2]))=="CB8_ITEM"})
nPosSeqPed := ASCAN(aHeader,{|x| UPPER(AllTrim(x[2]))=="CB8_SEQUEN"})

MontaCols(cSeekCB8)

If !l100Auto
	aSize   := MsAdvSize()
	aAdd(aObjects, {100, 130, .T., .F.})
	aAdd(aObjects, {100, 200, .T., .T.})
	aInfo   := {aSize[1], aSize[2], aSize[3], aSize[4], 2, 2}
	aPosObj := MsObjSize(aInfo, aObjects)

	DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCadastro) From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL //"Ordens de separacao - Estorno"
	oEnc:=MsMget():New(cAlias,nReg,nOpcx,,,,,{aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]},,3,,,,,,.t.)
	oGet:=MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4], nOpcx,"AllWaysTrue","AllWaysTrue", ,.F.)

	DEFINE TIMER oTimer INTERVAL 1000 ACTION MontaCols(cSeekCB8,oGet) OF oDlg
	oTimer:Activate()

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,oDlg:End()},{||oDlg:End()})
EndIf

dbSelectArea( cAlias )

If nOpca == 1 .Or. l100Auto

	If !l100Auto .And. !FWAlertNoYes("Deseja realmente estornar a <strong>" +cTitRotina+ "</strong>? Esta ação fará com que volte para etapa de validação fiscal!", "Confirma Estorno?")
		Return
	EndIf

	If ExistBlock("ACD100ET")
    	ExecBlock("ACD100ET",.F.,.F.)
	EndIf

	Begin Transaction

		SC9->(DbSetOrder(1))
		CB8->(DbSetOrder(1))
		dbSelectArea("CB7")
		For nI := 1 to Len(aCols)
			CB8->(DbGoto(aRecno[nI]))

			If CB7->CB7_ORIGEM == "1"
				SC9->(DbSetOrder(1))
				SF2->(DbSetOrder(1))
				SD2->(DbSetOrder(3))
				If SC9->(MsSeek(xFilial("SC9")+aCols[nI,nPosPed]+aCols[nI,nPosItPed]+aCols[nI,nPosSeqPed])) //Limpa a informação do campo C9_ORDSEP, no estorno da Ordem de Separação
					While SC9-> (!Eof() .And. C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN == (xFilial("SC9")+aCols[nI,nPosPed]+aCols[nI,nPosItPed]+aCols[nI,nPosSeqPed]) )
						SC9->(RecLock("SC9",.F.))
						SC9->C9_ORDSEP := ""
						SC9->(MsUnlock())
						SC9->(DbSkip())
					EndDo
				EndIf
				If SF2->(DBSeek(xFilial("SF2")+CB7->(CB7_NOTA+CB7_SERIE)))
					If ! Empty(SF2->F2_ORDSEP)
						SF2->(RecLock("SF2",.F.))
						SF2->F2_ORDSEP := ""
						SF2->(MsUnlock())
					EndIf
				EndIf
				If SD2->( DBSeek( xFilial("SD2")+CB7->(CB7_NOTA+CB7_SERIE+CB7_CLIENTE+CB7_LOJA)+aCols[ni,GDFieldPos("CB8_PROD")]+aCols[ni,GDFieldPos("CB8_ITEM")] ) )
					If !Empty(SD2->D2_ORDSEP)	
						SD2->(RecLock("SD2",.F.))
						SD2->D2_ORDSEP := ""
						SD2->(MsUnlock())
					EndIf
				EndIf			
			ElseIf CB7->CB7_ORIGEM == "2"
				SF2->(DbSetOrder(1))
				SD2->(DbSetOrder(3))
				If SF2->(DBSeek(xFilial("SF2")+CB7->(CB7_NOTA+CB7_SERIE)))
					If ! Empty(SF2->F2_ORDSEP)
						SF2->(RecLock("SF2",.F.))
						SF2->F2_ORDSEP := ""
						SF2->(MsUnlock())
					EndIf
				EndIf
				If SD2->( DBSeek( xFilial("SD2")+CB7->(CB7_NOTA+CB7_SERIE+CB7_CLIENTE+CB7_LOJA)+aCols[ni,GDFieldPos("CB8_PROD")]+aCols[ni,GDFieldPos("CB8_ITEM")] ) )
					If !Empty(SD2->D2_ORDSEP)	
						SD2->(RecLock("SD2",.F.))
						SD2->D2_ORDSEP := ""
						SD2->(MsUnlock())
					EndIf
				EndIf
			ElseIf CB7->CB7_ORIGEM == "3"
				SC2->(DbSetOrder(1))
				If SC2->(DbSeek(xFilial("SC2")+CB8->CB8_OP))
					If ! Empty(SC2->C2_ORDSEP)
						SC2->(RecLock("SC2",.F.))
						SC2->C2_ORDSEP := ""
						SC2->(MsUnlock())
					Endif
				Endif
			EndIf
			CB8->(RecLock( "CB8",.F.))
			CB8->(dbDelete())
			CB8->(MsUnLock())

			If	!Empty(CB7->CB7_PRESEP)
				If	CB8->(DbSeek(xFilial("CB8")+CB7->CB7_PRESEP+CB8_ITEM+CB8_SEQUEN+CB8_PROD))
					If	CB8->CB8_SLDPRE == 0
						CB8->(RecLock( "CB8",.F.))
						CB8->CB8_SLDPRE := CB8->CB8_QTDORI
						CB8->(MsUnLock())
						CB8->(DbSkip())
					EndIf
				EndIf
			EndIf

		Next nI

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exclui linha da tabela CB7 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		aAdd(aPVs, CB7->( CB7_FILIAL + CB7_PEDIDO ))
		If !Empty(CB7->CB7_XPVTRI)
			aAdd(aPVs, CB7->( CB7_FILIAL + CB7_XPVTRI ))
		Endif

		CB7->(RecLock("CB7", .F.))
		CB7->(dbDelete())
		CB7->(MsUnlock())

		If nOSOpc == 1
			For nJ := 1 To Len(aPVs)
				cChave	:= aPVs[nJ]
				cItemAnt:= ""
				//-- Estorna também a validacao Fiscal
				For nI := 1 to Len(aCols)
					If cItemAnt != aCols[nI,nPosPed]+aCols[nI,nPosItPed]
						SetTraking("5", cChave, aCols[nI,nPosItPed], Nil, "Estorno total PV-Item: " + AllTrim(aCols[nI,nPosPed]) + "-" + AllTrim(aCols[nI,nPosItPed]), "Estorno " + If(nOSOpc == 1, "Vld.Fisica", "OS"))
					EndIf
					cItemAnt := aCols[nI,nPosPed]+aCols[nI,nPosItPed]
				Next nI
			Next nJ
		EndIf

	End Transaction

EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GRACDA100 ³ Autor ³ Eduardo Motta         ³ Data ³ 06/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina de geracao das ordens de separacao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function GRACDA100(cAlias, nReg, nOpc, lAuto, aParams)
Local aRotBack  := {}
Local cCondicao := ""
Local aNewFil   := {}
Local cFilSC9   := ".T."
Local cFilSD2   := ".T."
Local cFilSC2   := ".T."
Local cSerie	:= ""

Local lRet      := .T.
Local aArea     := GetArea()
Local aAreaCB7  := CB7->(GetArea())

Local cGetMark  := Nil
Local cBrwAlias	:= Nil
Local cBrwCpMark:= Nil
Local cBrwDesc	:= Nil
Local oBrwMrk   := Nil
Local nZ

Local aLegend 	:= {}
Local aBrwButt	:= {}
Local bMark2	:= { ||}
Local bBrwLeg	:= { || oFWLegend:View() }
Local bBrwMark	:= { || a100Mark( oBrwMrk, 1, cGetMark, bMark2, cBrwAlias, cBrwCpMark ) }
Local bBrwMakAll:= { || FWMsgRun(, {|| a100Mark( oBrwMrk, 2, cGetMark, bMark2, cBrwAlias, cBrwCpMark ) }, "Aguarde", "Atualizando Registros..." ) }
Local bBrwGrava	:= { || ( U_A100_Grava( cBrwAlias, Nil, Nil, cGetMark, Nil, Nil, oBrwMrk ), oBrwMrk:SetFilterDefault( cCondicao ) )  }

Private oFwLegend := NIl

Private nGroupLoc	:= 0
PRIVATE nOrigExp   	:= ""
PRIVATE cSeparador 	:= Space(6)	//variavel utilizada para armazenar o separador da pergunte AIA102, pois o mesmo estava sendo sobreposto por outra pergunte, ao precionar F12 na tela de geracao
Private aSav102     := Array(10)

Default lAuto   := .F.
Default aParams := {}

Private l100Auto := lAuto

If !l100Auto
	Aadd( aBrwButt, { "Gerar"	, bBrwGrava	, Nil, 1 } )
	Aadd( aBrwButt, { "Marcar/Desmarc Registros"	, bBrwMakAll, Nil, 1 } )
	Aadd( aBrwButt, { "Legenda"	, bBrwLeg	, Nil, 1 } )

	If !Pergunte("AIA101",.T.)
		Return
	EndIf
	nOrigExp := MV_PAR01
	AtivaF12(nOrigExp) // carrega os valores das perguntes relacionados a configuracoes
	If	ExistBlock("ACD100FI")
		aNewFil := ExecBlock("ACD100FI",.F.,.F.,{nOrigExp})
		If	ValType(aNewFil) == "A"
			If	aNewFil[1] == 1
				cFilSC9 := aNewFil[2]
			ElseIf	aNewFil[1] == 2
				cFilSD2 := aNewFil[2]
			ElseIf	aNewFil[1] == 3
				cFilSC2 := aNewFil[2]
			EndIf
		EndIf
	EndIf

	aRotBack := aClone( aRotina )
	aRotina  := {{"Gerar","U_A100_Grava",0,1} } //"Gerar"
	//--- P.E. utilizado para adicionar itens no Menu da MarkBrowse
	If	ExistBlock("ACD100MNU")
		ExecBlock("ACD100MNU",.f.,.f.,{nOrigExp})
	EndIf
Else
	//Configuracoes da pergunte AIA106 (Pedidos de Venda), ativado pela tecla F12:
	PRIVATE nConfLote
	PRIVATE nEmbSimul
	PRIVATE nEmbalagem
	PRIVATE nGeraNota
	PRIVATE nImpNota
	PRIVATE nImpEtVol
	PRIVATE nEmbarque
	PRIVATE nAglutPed
	PRIVATE nAglutArm
	PRIVATE nPriorEnd
	PRIVATE nPreSep

	Pergunte("AIA101", .F.)
	MV_PAR01 := 1 //Pedido
	SetMVValue("AIA101", "MV_PAR01", 1    , .T.)

	nOrigExp := MV_PAR01

	Pergunte("AIA106", .F.)
	MV_PAR01 := 1
	MV_PAR02 := 2
	MV_PAR03 := 2
	MV_PAR04 := 2
	MV_PAR05 := 2
	MV_PAR07 := 1
	MV_PAR08 := 2
	MV_PAR09 := 2
	MV_PAR10 := 1
	SetMVValue("AIA106", "MV_PAR01", MV_PAR01, .T.)
	SetMVValue("AIA106", "MV_PAR02", MV_PAR02, .T.)
	SetMVValue("AIA106", "MV_PAR03", MV_PAR03, .T.)
	SetMVValue("AIA106", "MV_PAR04", MV_PAR04, .T.)
	SetMVValue("AIA106", "MV_PAR05", MV_PAR05, .T.)
	SetMVValue("AIA106", "MV_PAR06", MV_PAR06, .T.)
	SetMVValue("AIA106", "MV_PAR07", MV_PAR07, .T.)
	SetMVValue("AIA106", "MV_PAR08", MV_PAR08, .T.)
	SetMVValue("AIA106", "MV_PAR09", MV_PAR09, .T.)
	SetMVValue("AIA106", "MV_PAR10", MV_PAR10, .T.)

	AtivaF12(nOrigExp) // carrega os valores das perguntes relacionados a configuracoes
EndIf

If nOrigExp == 1 .And. l100Auto
	//configuração das perguntas
	STATIC aPerg100	:= {}

	Pergunte("AIA102", .F.)

	For nZ := 1 to 10
		//Verifica se o parâmetro foi enviado no execauto.
		nPos := ASCAN(aParams, { |x|  Alltrim(Upper(x[1])) == "MV_PAR"+StrZero(nZ,2)})
		IF nPos == 0
			aSav102[nZ] := &("mv_par"+StrZero(nZ,2)) //Padrão
		ELSE
			IF VALTYPE(aParams[nPos,2]) <> VALTYPE(&("mv_par"+StrZero(nZ,2))) //Verifica se o tipo da variavel esta correto
				aSav102[nZ] := &("mv_par"+StrZero(nZ,2)) //Padrão
			ELSE
				aSav102[nZ] := aParams[nPos,2] //ExecAuto
			ENDIF
			SetMVValue("AIA102", "MV_PAR"+StrZero(nZ,2), aSav102[nZ], .T.)
		ENDIF
	Next nZ

	Aadd(aPerg100,ACD100Perg("AIA102"))
	cSeparador := aSav102[1]
	nPreSep    := aSav102[10]

	cCondicao := 'C9_PEDIDO  >="'+aSav102[2]+'".And.C9_PEDIDO <="'+aSav102[3]+'".And.'
	cCondicao += 'C9_CLIENTE >="'+aSav102[4]+'".And.C9_CLIENTE<="'+aSav102[6]+'".And.'
	cCondicao += 'C9_LOJA    >="'+aSav102[5]+'".And.C9_LOJA   <="'+aSav102[7]+'".And.'
	cCondicao += 'DTOS(C9_DATALIB)>="'+DTOS(aSav102[8])+'".And.DTOS(C9_DATALIB)<="'+DTOS(aSav102[9])+'".And.'
	cCondicao += 'Empty(C9_ORDSEP) .And.'
	cCondicao += 'C9_FILIAL = xFilial("SC9") .And.'
	cCondicao += 'Empty( C9_BLEST + C9_BLCRED ) .And.'
	cCondicao += '!Empty( C9_LOTECTL )'

	cBrwAlias	:= 'SC9'
	cBrwCpMark	:= 'C9_OK'
	cGetMark  	:= GetMark( .T., cBrwAlias, cBrwCpMark )
ElseIf nOrigExp == 1 .And. !l100Auto
	If  !( Pergunte("AIA102",.T.) )
		lRet := .F.
	Else
		Aadd(aPerg100,ACD100Perg("AIA102"))
		cSeparador := MV_PAR01
		nPreSep := MV_PAR10

		dbSelectArea("SC9")
		dbSetOrder(1)		

		cCondicao := 'C9_PEDIDO  >="'+mv_par02+'".And.C9_PEDIDO <="'+mv_par03+'".And.'
		cCondicao += 'C9_CLIENTE >="'+mv_par04+'".And.C9_CLIENTE<="'+mv_par06+'".And.'
		cCondicao += 'C9_LOJA    >="'+mv_par05+'".And.C9_LOJA   <="'+mv_par07+'".And.'
		cCondicao += 'DTOS(C9_DATALIB)>="'+DTOS(mv_par08)+'".And.DTOS(C9_DATALIB)<="'+DTOS(mv_par09)+'".And.'
		cCondicao += 'Empty(C9_ORDSEP) .And.'
		cCondicao += ' C9_FILIAL = xFilial("SC9") .And.'
		cCondicao += '!Empty( C9_LOTECTL ) .And.'
		cCondicao += cFilSC9
		
		cBrwAlias	:= 'SC9'
		cBrwCpMark	:= 'C9_OK'
		bMark2		:= { || Empty( C9_BLEST + C9_BLCRED ) }
		cGetMark  	:= GetMark( .T., cBrwAlias, cBrwCpMark )
		cBrwDesc	:= OemToAnsi( "Gerar Ordem de Separacao - Pedido de Venda" )

		Aadd( aLegend,{ "Empty( C9_BLEST + C9_BLCRED )"	, "ENABLE"		, "Liberado para Separacao" } )
		Aadd( aLegend,{ "!Empty( C9_BLEST + C9_BLCRED )", "BR_VERMELHO"	, "Nao Liberado para Separacao" } )
		oFwLegend := a1002Leg( aLegend )
	EndIf
ElseIf	nOrigExp == 2  .And. !l100Auto// nota fiscal saida
	If	!( Pergunte("AIA103",.T.) )
		lRet := .F.
	Else
		Aadd(aPerg100,ACD100Perg("AIA103"))
		cSeparador := MV_PAR01
		dbSelectArea("SD2")
		dbSetOrder(3)

		cSerie := 	SerieNfId("SD2",3,"D2_SERIE")
		cChaveInd := 'D2_FILIAL+D2_ORDSEP+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+DTOS(D2_EMISSAO)' //IndexKey()
		cCondicao := 'D2_DOC >="'          +mv_par02+'" .And. D2_DOC<="'    +mv_par04+'"'
		cCondicao += '.And. '+cSerie+' >="' +mv_par03+'" .And. '+cSerie+' <= "'  +mv_par05+'"'
		cCondicao += '.And. D2_CLIENTE>="' +mv_par06+'" .And. D2_CLIENTE<="'+mv_par08+'"'
		cCondicao += '.And. D2_LOJA>="'    +mv_par07+'" .And. D2_LOJA<="'   +mv_par09+'"'
		cCondicao += '.And. DTOS(D2_EMISSAO)>="'+DTOS(mv_par10)+'".And.DTOS(D2_EMISSAO)<="'+DTOS(mv_par11)+'"'
		cCondicao += '.And. Empty(D2_ORDSEP) .And. '
		cCondicao += ' D2_FILIAL = xFilial("SD2") .And. '
		cCondicao += cFilSD2

		If  !Pergunte("AIA107",.T.)
			lRet := .F.
		Else
			Aadd(aPerg100,ACD100Perg("AIA107"))

			cBrwAlias	:= 'SD2'
			cBrwCpMark	:= 'D2_OK'
			bMark2		:= { || Empty( D2_ORDSEP ) }
			cGetMark  	:= GetMark( .T., cBrwAlias, cBrwCpMark )
			cBrwDesc	:= OemToAnsi( "Gerar Ordem de Separacao - Documento de Saida" )

			Aadd( aLegend,{ "Empty( D2_ORDSEP  )"	, "ENABLE"		, "Liberado para Separacao" } )
			Aadd( aLegend,{ "!Empty( D2_ORDSEP )"	, "BR_VERMELHO"	, "Nao Liberado para Separacao" } )
			oFwLegend := a1002Leg( aLegend )

		EndIf
	EndIf

ElseIf	nOrigExp == 3  .And. !l100Auto// producao 	 
	If	!( Pergunte("AIA104",.T.) )
		lRet := .F.
	Else
		Aadd(aPerg100,ACD100Perg("AIA104"))
		cSeparador := MV_PAR01
		nPreSep := MV_PAR06

		dbSelectArea("SC2")
		dbSetOrder(1)

		cCondicao := 'C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD >="'    +mv_par02+'".And.C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD <="'+mv_par03+'"'
		cCondicao += '.And. DTOS(C2_EMISSAO)>="'+DTOS(mv_par04)+'".And.DTOS(C2_EMISSAO)<="'+DTOS(mv_par05)+'"'
		cCondicao += '.And. Empty(C2_ORDSEP)'
		cCondicao += '.And. Empty(C2_DATRF) .And. '
		cCondicao += ' C2_FILIAL = xFilial("SC2") .And. '
		cCondicao += cFilSC2

		If  !( Pergunte("AIA108",.T.) )
			lRet := .F.
		Else
			nGroupLoc := Mv_Par02
			Aadd(aPerg100,ACD100Perg("AIA108"))

			cBrwAlias	:= 'SC2'
			cBrwCpMark	:= 'C2_OK'
			bMark2		:= { || Empty( C2_ORDSEP ) }
			cGetMark  	:= GetMark( .T., cBrwAlias, cBrwCpMark )
			cBrwDesc	:= OemToAnsi( "Gerar Ordem de Separacao - Ordem de Producao" )

			Aadd( aLegend,{ "Empty( C2_ORDSEP  )"	, "ENABLE"		, "Liberado para Separacao" } )
			Aadd( aLegend,{ "!Empty( C2_ORDSEP )"	, "BR_VERMELHO"	, "Nao Liberado para Separacao" } )
			oFwLegend := a1002Leg( aLegend )


		EndIf
	EndIf
EndIf

If !l100Auto
	If lRet
		oBrwMrk := FwMarkBrowse():New()      
		oBrwMrk:SetAlias( cBrwAlias ) 		  
		oBrwMrk:SetFieldMark( cBrwCpMark ) 
		oBrwMrk:SetDescription( cBrwDesc ) 
		oBrwMrk:SetFilterDefault( cCondicao )
		oBrwMrk:SetAllMark(bBrwMakAll)
		oBrwMrk:SetCustomMarkRec(bBrwMark)
		oBrwMrk:SetMark( cGetMark, cBrwAlias, cBrwCpMark )

		AEval( aLegend ,{ | x | oBrwMrk:AddLegend( x[ 1 ], x[ 2 ], x[ 3 ] ) } )
		AEval( aBrwButt,{ | x | oBrwMrk:AddButton( x[ 1 ], x[ 2 ], x[ 3 ], x[ 4 ] ) } )

		oBrwMrk:Activate()

		FreeObj( oBrwMrk )
		oBrwMrk := Nil
		aAreaCB7 := CB7->(GetArea())
	EndIf
Else
	A100OSAut(cGetMark, cCondicao)
EndIf

aRotina := aClone( aRotBack )
RestArea( aArea )
RestArea( aAreaCB7 )
Return( lRet )


//--
Static Function A100OSAut(cMarca, cCondicao)
	Local aAreaAnt := GetArea()
	Local aAreaSC9 := SC9->(GetArea())

	dbSelectArea("SC9")
	SC9->(dbSetOrder(1))
	SC9->(dbSetFilter({|| &cCondicao}, cCondicao))
	SC9->(dbGoTop())
	While !EoF()
		RecLock("SC9", .F.)
			SC9->C9_OK := cMarca
		SC9->(MsUnLock())
		SC9->(dbSkip())
	Enddo

	GeraOSepPedido(cMarca, Nil, Nil, Nil)

	dbClearFilter()
	
	RestArea(aAreaSC9)
	RestArea(aAreaAnt)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A100_Grava ³ Autor ³ Eduardo Motta    ³ Data ³ 06/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gravacao das ordens de separacao                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAACD                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function A100_Grava(cAlias,cCampo,nOpcE,cMarca,lInverte,lNoDupl, oBrwMrk )
If nOrigExp==1
	Processa( { || GeraOSepPedido( cMarca, lInverte, Nil, oBrwMrk ) } ) 
ElseIf nOrigExp==2
	Processa( { || GeraOSepNota( cMarca, lInverte, Nil, oBrwMrk ) } )
ElseIf nOrigExp==3
	Processa( { || GeraOSepProducao( cMarca, lInverte, oBrwMrk ) } )
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GeraOSepPedido³ Autor ³ Eduardo Motta     ³ Data ³ 06/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Gera as ordens de separacao a partir dos itens da MarkBrowse³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³GeraOrdSep( ExpC1, ExpL1 )                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 -> Marca da MarkBrowse / ExpL1 -> lInverte MarkBrowse³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ PCHA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GeraOSepPedido( cMarca, lInverte, cPedidoPar, oBrwMrk )
Local nI
Local cCodOpe
Local aRecSC9	:= {}
Local aOrdSep	:= {}
Local nNumItens	:= 0
Local cArm		:= Space(Tamsx3("B1_LOCPAD")[1])
Local cPedido	:= Space(Tamsx3("C9_PEDIDO")[1])
Local cCliente	:= Space(Tamsx3("C6_CLI")[1])
Local cLoja		:= Space(Tamsx3("C6_LOJA")[1])
Local cCondPag	:= Space(Tamsx3("C5_CONDPAG")[1])
Local cLojaEnt	:= Space(Tamsx3("C5_LOJAENT")[1])
Local cAgreg	:= Space(Tamsx3("C9_AGREG")[1])
Local cOrdSep	:= Space(Tamsx3("CB7_ORDSEP")[1])
Local cForn		:= ""
Local cLojaForn	:= ""

Local cTipExp	:= ""
Local nPos      := 0
Local nMaxItens	:= GETMV("MV_NUMITEN")			//Numero maximo de itens por nota (neste caso por ordem de separacao)- by Erike
Local lConsNumIt:= SuperGetMV("MV_CBCNITE",.F.,.T.) //Parametro que indica se deve ou nao considerar o conteudo do MV_NUMITEN
Local lFilItens	:= ExistBlock("ACDA100I")  //Ponto de Entrada para filtrar o processamento dos itens selecionados
Local lLocOrdSep:= .F.
Local lA100CABE := ExistBlock("A100CABE")
Local lACD100GI := ExistBlock("ACD100GI")
Local lACDA100F := ExistBlock("ACDA100F")
Local lACD100G1 := ExistBlock("ACD100G1")
Local aSc9Aux	:= {}
Local aAux		:= {}
Local aItens	:= {}
Local aPvVet	:= {}
Local aAuxUsr	:= {}
Local nInd		:= 0
Local nXnd		:= 0
Local cTransp	:= Nil
Local cCondPg	:= Nil
Local lCB7Priore:= CB7->(FieldPos("CB7_PRIORE") > 0)
Local lCB8Priore:= CB8->(FieldPos("CB8_PRIOR") > 0 )

Local oSDCQry   := Nil
Local cSDCQry   := ""
Local cTblTmp   := ""
Local cRemessa  := ""
Local cCliRem   := ""
Local cLojaRem  := ""
Local cLoteFor	:= ""
Local cQLoteFor := ""
Private aLogOS	:= {}
Default oBrwMrk	:= Nil
Default cPedidoPar	:= Nil

nMaxItens := If(Empty(nMaxItens),99,nMaxItens)

// analisar a pergunta '00-Separacao,01-Separacao/Embalagem,02-Embalagem,03-Gera Nota,04-Imp.Nota,05-Imp.Volume,06-embarque,07-Aglutina Pedido,08-Aglutina Local,09-Pre-Separacao'
If nEmbSimul == 1 // Separacao com Embalagem Simultanea
	cTipExp := "01*"
Else
	cTipExp := "00*" // Separacao Simples
EndIF
If nEmbalagem == 1 // Embalagem
	cTipExp += "02*"
EndIF
If nGeraNota == 1 // Gera Nota
	cTipExp += "03*"
EndIF
If nImpNota == 1 // Imprime Nota
	cTipExp += "04*"
EndIF
If nImpEtVol == 1 // Imprime Etiquetas Oficiais de Volume
	cTipExp += "05*"
EndIF
cTipExp += "06*"
If nAglutPed == 1 // Aglutina pedido
	cTipExp +="11*"
EndIf
If nAglutArm == 1 // Aglutina armazem
	cTipExp +="08*"
EndIf
If nPreSep == 1 // pre-separacao - Trocar MV_PAR10 para nPreSep
	cTipExp +="09*"
EndIf
If nConfLote == 1 // confere lote
	cTipExp +="10*"
EndIf

/*Ponto de entrada, permite que o usuário realize o processamento conforme suas particularidades.*/
If	ExistBlock("ACD100VG")
	If ! ExecBlock("ACD100VG",.F.,.F.,)
		Return
	EndIf		
EndIf

ProcRegua( SC9->( LastRec() ), "oook" )
cCodOpe	 := cSeparador

SC5->(DbSetOrder(1))
SC6->(DbSetOrder(1))
SDC->(DbSetOrder(1))
CB7->(DbSetOrder(2))
CB8->(DbSetOrder(2))

SC9->(dbGoTop())
While !SC9->(Eof())
	If Type("oBrwMrk") == "O"
		If !( oBrwMrk:IsMark() )
			SC9->( dbSkip() ) ; Loop
			IncProc()
		EndIf
	Else
		If !(SC9->C9_OK == cMarca)
			SC9->( dbSkip() ) ; Loop
			IncProc()
		EndIf
	EndIf

	If !Empty(SC9->(C9_BLEST+C9_BLCRED+C9_BLOQUEI))
		SC9->(DbSkip())
		IncProc()
		Loop
	EndIf
	If lFilItens
		If !ExecBlock("ACDA100I",.F.,.F.)
			SC9->(DbSkip())
			IncProc()
			Loop
		Endif
	Endif
	//pesquisa se este item tem saldo a separar, caso tenha, nao gera ordem de separacao
	If CB8->(DbSeek(xFilial('CB8')+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN+SC9->C9_PRODUTO)) .and. CB8->CB8_SALDOS > 0
		//Grava o historico das geracoes:
		aadd(aLogOS,{"2","Pedido",SC9->C9_PEDIDO,SC9->C9_CLIENTE,SC9->C9_LOJA,SC9->C9_ITEM,SC9->C9_PRODUTO,SC9->C9_LOCAL,"Existe saldo a separar deste item","NAO_GEROU_OS"}) //"Pedido"###"Existe saldo a separar deste item"
		SC9->(DbSkip())
		IncProc()
		Loop
	EndIf

	If ! SC5->(DbSeek(xFilial('SC5')+SC9->C9_PEDIDO))
		// neste caso a base tem sc9 e nao tem sc5, problema de incosistencia de base
		//Grava o historico das geracoes:
		aadd(aLogOS,{"2","Pedido",SC9->C9_PEDIDO,SC9->C9_CLIENTE,SC9->C9_LOJA,SC9->C9_ITEM,SC9->C9_PRODUTO,SC9->C9_LOCAL,"Inconsistencia de base (SC5 x SC9)","NAO_GEROU_OS"}) //"Pedido"###"Inconsistencia de base (SC5 x SC9)"
		SC9->(DbSkip())
		IncProc()
		Loop
	EndIf

	//-- Verifica se tem remessa
	cRemessa := ChkRemessa(xFilial("SC5"), SC9->C9_PEDIDO)
	If !Empty(cRemessa)
		cCliRem  := SC5->C5_CLIENTE
		cLojaRem := SC5->C5_LOJACLI
	EndIf

	If ! SC6->(DbSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO))
		// neste caso a base tem sc9,sc5 e nao tem sc6,, problema de incosistencia de base
		//Grava o historico das geracoes:
		aadd(aLogOS,{"2","Pedido",SC9->C9_PEDIDO,SC9->C9_CLIENTE,SC9->C9_LOJA,SC9->C9_ITEM,SC9->C9_PRODUTO,SC9->C9_LOCAL,"Inconsistencia de base (SC6 x SC9)","NAO_GEROU_OS"}) //"Pedido"###"Inconsistencia de base (SC6 x SC9)"
		SC9->(DbSkip())
		IncProc()
		Loop
	EndIf

	If !("08*" $ cTipExp)  // gera ordem de separacao por armazem
		cArm :=SC6->C6_LOCAL
	Else  // gera ordem de separa com todos os armazens
		cArm :=Space(Tamsx3("B1_LOCPAD")[1])
	EndIf
	If "11*" $ cTipExp //AGLUTINA TODOS OS PEDIDOS DE UM MESMO CLIENTE
		cPedido := Space(Tamsx3("C9_PEDIDO")[1])
	Else   // Nao AGLUTINA POR PEDIDO
		cPedido := SC9->C9_PEDIDO
	EndIf
	If "09*" $ cTipExp // AGLUTINA PARA PRE-SEPARACAO
		cPedido  := Space(Tamsx3("C9_PEDIDO")[1]) // CASO SEJA PRE-SEPARACAO TEM QUE CONSIDERAR TODOS OS PEDIDOS
		cCliente := Space(Tamsx3("C6_CLI")[1])
		cLoja    := Space(Tamsx3("C6_LOJA")[1])
		cCondPag := Space(Tamsx3("C5_CONDPAG")[1])
		cLojaEnt := Space(Tamsx3("C5_LOJAENT")[1])
		cAgreg   := Space(Tamsx3("C9_AGREG")[1])
		cForn 		:= SC6->C6_CLI
		cLojaForn	:= SC6->C6_LOJA
		cArmazem	:= SC6->C6_LOCAL 
	Else   // NAO AGLUTINA PARA PRE-SEPARACAO
		cCliente 	:= SC6->C6_CLI
		cLoja    	:= SC6->C6_LOJA
		cCondPag 	:= SC5->C5_CONDPAG
		cLojaEnt 	:= SC5->C5_LOJAENT
		cAgreg   	:= SC9->C9_AGREG
		cForn 		:= Space(Tamsx3("C6_CLI")[1])
		cLojaForn	:= Space(Tamsx3("C6_LOJA")[1])
		cArmazem 	:= SC6->C6_LOCAL

	EndIf

	lLocOrdSep := .F.
	If CB7->(DbSeek(xFilial("CB7")+cPedido+cArm+" "+cCliente+cLoja+cCondPag+cLojaEnt+cAgreg))
		While CB7->(!Eof() .and. CB7_FILIAL+CB7_PEDIDO+CB7_LOCAL+CB7_STATUS+CB7_CLIENT+CB7_LOJA+CB7_COND+CB7_LOJENT+CB7_AGREG==;
								xFilial("CB7")+cPedido+cArm+" "+cCliente+cLoja+cCondPag+cLojaEnt+cAgreg)
			If Ascan(aOrdSep, CB7->CB7_ORDSEP) > 0			
				lLocOrdSep := .T.
				Exit
			EndIf
			CB7->(DbSkip())
		EndDo
	EndIf

	If Localiza(SC9->C9_PRODUTO)
		If ! SDC->( dbSeek(xFilial("SDC")+SC9->C9_PRODUTO+SC9->C9_LOCAL+"SC6"+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN))
			// neste caso nao existe composicao de empenho
			//Grava o historico das geracoes:
			aadd(aLogOS,{"2","Pedido",SC9->C9_PEDIDO,SC9->C9_CLIENTE,SC9->C9_LOJA,SC9->C9_ITEM,SC9->C9_PRODUTO,SC9->C9_LOCAL,"Nao existe composicao de empenho (SDC)","NAO_GEROU_OS"}) //"Pedido"###"Nao existe composicao de empenho (SDC)"
			SC9->(DbSkip())
			IncProc()
			Loop
		EndIf
	EndIf
	
	aPvVet := GetAdvFVal( 'SC5', { 'C5_TRANSP', 'C5_CONDPAG' }, FWxFilial( 'SC5' ) + SC9->C9_PEDIDO, 1 )
	Aadd( aAux,{ 	IIf( "09*" $ cTipExp, cForn, cCliente  ),; 	//01-Cliente/Fornecedor
					IIf( "09*" $ cTipExp, cLojaForn, cLoja ),; 	//02-Loja Cliente/Fornecedor
					cCondPag,; 									//03-Condp Pagto
					cLojaEnt,; 									//04-Loja Entrada
					cAgreg	,; 									//05-Agrega
					cArmazem,; 									//06-Armazem
					SC9->( Recno() ),; 							//07-Recno SC9
					SC9->C9_PEDIDO	,; 							//08-Codigo Ped Venda SC9
					cPedido	,; 									//09-Cod. Ped Venda
					aPvVet[ 01 ],; 								//10-Transportadora Ped venda SC5
					aPvVet[ 02 ]  } )							//11-Cond. Pagto Ped venda SC5

	If lACD100G1
		aAuxUsr := ExecBlock("ACD100G1", .F., .F., aTail(aAux) )
		If ValType(aAuxUsr) == "A"
			aTail(aAux) := aClone(aAuxUsr)
		EndIf
	EndIf
	
	IncProc()
	SC9->( dbSkip() )
EndDo

aItens := A100ItGrp( aAux, nAglutPed, nAglutArm, nPreSep )

Begin Transaction

For nInd := 1 To Len( aItens )
	nNumItens := 0
	cCliente  := aItens[ nInd ][ 01 ]
	cLoja	  := aItens[ nInd ][ 02 ]
	cArm	  := aItens[ nInd ][ 03 ]	
	cPedido	  := aItens[ nInd ][ 06 ]
	cLojaEnt  := aItens[ nInd ][ 07 ]
	cTransp	  := aItens[ nInd ][ 08 ]
	cCondPg   := aItens[ nInd ][ 09 ]
	cAgreg	  := aItens[ nInd ][ 10 ]	

	aSc9Aux	  := AClone( aItens[ nInd ][ 05 ] )

	For nXnd := 1 To Len( aSc9Aux )
		SC9->( dbGoto( aSc9Aux[ nXnd ] ) )
			If !lLocOrdSep .or. (("03*" $ cTipExp) .and. !("09*" $ cTipExp) .and. lConsNumIt )
				If ( nNumItens == 0 ) .Or. ( nNumItens >= nMaxItens )
					nNumItens	:= 0
					cOrdSep 	:= CB_SXESXF("CB7","CB7_ORDSEP",,1)
					ConfirmSX8()

					CB7->(RecLock( "CB7",.T.))
					CB7->CB7_FILIAL := xFilial( "CB7" )
					CB7->CB7_ORDSEP := cOrdSep
					CB7->CB7_PEDIDO := cPedido
					CB7->CB7_CLIENT := cCliente
					CB7->CB7_LOJA   := cLoja
					CB7->CB7_COND   := cCondPg
					CB7->CB7_LOJENT := cLojaEnt
					CB7->CB7_LOCAL  := cArm
					CB7->CB7_DTEMIS := dDataBase
					CB7->CB7_HREMIS := Time()
					CB7->CB7_STATUS := " "
					CB7->CB7_CODOPE := cCodOpe
					CB7->CB7_PRIORI := "1"
					CB7->CB7_ORIGEM := "1"
                    CB7->CB7_TIPEXP := cTipExp + "99*" //-- 99 indica que devera ser feita "Validacao Fisica"
					CB7->CB7_TRANSP := cTransp
					CB7->CB7_AGREG  := cAgreg 

					If !("06*" $ CB7->CB7_TIPEXP)
						CB7->CB7_TIPEXP += AllTrim(CB7->CB7_TIPEXP) + "06*"
					EndIf
					//-- Priorizacao de endereco na separacao
					If lCB7Priore .And. ValType(nPriorEnd) == "N" .And. nPriorEnd == 1
						CB7->CB7_PRIORE := CValToChar(nPriorEnd)
					EndIf

                    If CB7->(FieldPos("CB7_XSTATU") > 0)
                        CB7->CB7_XSTATU := CB7_STATUS
                    EndIf

                    If CB7->(FieldPos("CB7_XPVTRI") > 0) .And. !Empty(cRemessa)
                        CB7->CB7_XPVTRI := cRemessa
                    EndIf

                    If CB7->(FieldPos("CB7_XCLIRE") > 0) .And. !Empty(cCliRem)
                        CB7->CB7_XCLIRE := cCliRem
                    EndIf

                    If CB7->(FieldPos("CB7_XLJREM") > 0) .And. !Empty(cLojaRem)
                        CB7->CB7_XLJREM := cLojaRem
                    EndIf

					If	lA100CABE
						ExecBlock("A100CABE",.F.,.F.)
					EndIf
					CB7->(MsUnlock())

					aadd(aOrdSep, cOrdSep )
				EndIf
			EndIf
			//Grava o historico das geracoes:
			nPos := Ascan(aLogOS,{|x| x[01]+x[02]+x[03]+x[04]+x[05]+x[10] == ("1"+"Pedido"+SC9->(C9_PEDIDO+C9_CLIENTE+C9_LOJA)+CB7->CB7_ORDSEP)})
			If nPos == 0
				aadd(aLogOS,{"1","Pedido",SC9->C9_PEDIDO,SC9->C9_CLIENTE,SC9->C9_LOJA,"","",cArm,"",CB7->CB7_ORDSEP}) //"Pedido"
			Endif

			If Localiza(SC9->C9_PRODUTO)
				If oSDCQry == Nil
					//-- Query para localizar os enderecos condiderando sua prioridade
					cSDCQry :=	" SELECT SDC.DC_PRODUTO, SDC.DC_LOCAL, SDC.DC_ORIGEM,SDC.DC_PEDIDO, SDC.DC_ITEM, SDC.DC_SEQ, SDC.DC_QUANT, SDC.DC_LOCALIZ, SDC.DC_NUMSERI, SBE.BE_PRIOR, SB1.B1_XCODSIM " + ;
								" FROM " + RetSqlName('SDC') + " SDC " + ;
								" RIGHT JOIN " + RetSQLName("SB1") + " SB1 " + ;
								" ON SB1.B1_FILIAL = ? " + ;
								" AND SB1.B1_COD = SDC.DC_PRODUTO " + ;
								" AND SB1.D_E_L_E_T_ = ' ' " + ;
								" INNER JOIN " + RetSqlName('SBE') + " SBE " + ;
								" ON SBE.BE_FILIAL = ? " + ;
								" AND SBE.BE_LOCAL = SDC.DC_LOCAL " + ;
								" AND SBE.BE_LOCALIZ = SDC.DC_LOCALIZ " + ;
								" AND SBE.D_E_L_E_T_ = ' ' " + ;
								" WHERE SDC.DC_FILIAL = ? " + ;
								" AND SDC.DC_PRODUTO = ? " + ;
								" AND SDC.DC_LOCAL = ? " + ;
								" AND SDC.DC_ORIGEM = ? " + ;
								" AND SDC.DC_PEDIDO = ? " + ;
								" AND SDC.DC_ITEM = ? " + ;
								" AND SDC.DC_SEQ = ? " + ;
								" AND SDC.D_E_L_E_T_ = ' ' " + ;
								" ORDER BY " + SqlOrder(SDC->(IndexKey(1)))

					cSDCQry := ChangeQuery(cSDCQry)
					oSDCQry := FWPreparedStatement():New(cSDCQry)
				EndIf

				oSDCQry:setString(1, xFilial("SB1"))
				oSDCQry:setString(2, xFilial("SBE"))
				oSDCQry:setString(3, xFilial("SDC"))
				oSDCQry:setString(4, SC9->C9_PRODUTO)
				oSDCQry:setString(5, SC9->C9_LOCAL)
				oSDCQry:setString(6, "SC6")
				oSDCQry:setString(7, SC9->C9_PEDIDO)
				oSDCQry:setString(8, SC9->C9_ITEM)
				oSDCQry:setString(9, SC9->C9_SEQUEN)

				cSDCQry := oSDCQry:getFixQuery()
				cTblTmp := MPSysOpenQuery(cSDCQry)

				While (cTblTmp)->( !Eof() )
					If IsProdMOD((cTblTmp)->DC_PRODUTO)
						(cTblTmp)->(DbSkip())
						Loop
					Endif
					CB7->( dbSetOrder( 1 ) )
					CB7->( dbSeek( xFilial( "CB7" ) + cOrdSep ) )
					CB8->(RecLock("CB8",.T.))
					CB8->CB8_FILIAL := xFilial("CB8")
					CB8->CB8_ORDSEP := CB7->CB7_ORDSEP
					CB8->CB8_ITEM   := SC9->C9_ITEM
					CB8->CB8_PEDIDO := SC9->C9_PEDIDO
					CB8->CB8_PROD   := (cTblTmp)->DC_PRODUTO
					CB8->CB8_LOCAL  := (cTblTmp)->DC_LOCAL
					CB8->CB8_QTDORI := (cTblTmp)->DC_QUANT
					If "09*" $ cTipExp
						CB8->CB8_SLDPRE := (cTblTmp)->DC_QUANT
					EndIf
					CB8->CB8_SALDOS := (cTblTmp)->DC_QUANT
					If ! "09*" $ cTipExp .AND. nEmbalagem == 1
						CB8->CB8_SALDOE := (cTblTmp)->DC_QUANT
					EndIf
					CB8->CB8_LCALIZ := (cTblTmp)->DC_LOCALIZ
					CB8->CB8_NUMSER := (cTblTmp)->DC_NUMSERI
					CB8->CB8_SEQUEN := SC9->C9_SEQUEN
					CB8->CB8_LOTECT := SC9->C9_LOTECTL
					CB8->CB8_NUMLOT := SC9->C9_NUMLOTE
					CB8->CB8_CFLOTE := If("10*" $ cTipExp,"1","2")
					CB8->CB8_TIPSEP := If("09*" $ cTipExp,"1"," ")
					//-- Priorizacao de endereco na separacao
					If lCB8Priore .And. ValType(nPriorEnd) == "N" .And. nPriorEnd == 1
						CB8->CB8_PRIOR  := (cTblTmp)->BE_PRIOR
					EndIf

                    If CB8->(FieldPos("CB8_XQTDOR") > 0)
                        CB8->CB8_XQTDOR := (cTblTmp)->DC_QUANT
                    EndIf

                    If CB8->(FieldPos("CB8_XSALDO") > 0)
                        CB8->CB8_XSALDO := (cTblTmp)->DC_QUANT
                    EndIf

                    If CB8->(FieldPos("CB8_XCODSI") > 0)
                        CB8->CB8_XCODSI := (cTblTmp)->B1_XCODSIM
                    EndIf

                    If CB8->(FieldPos("CB8_XLOTFO") > 0)
						cQLoteFor := "SELECT IsNull(CB8_LOTECT, '') AS LOTEFOR FROM " + RetSQLName("SC2") + " SC2 "
						cQLoteFor += "INNER JOIN " + RetSQLName("CB8") + " CB8 ON CB8_FILIAL = C2_FILIAL AND CB8_OP = C2_NUM+C2_ITEM+C2_SEQUEN AND CB8.D_E_L_E_T_ = ' ' "
						cQLoteFor += "WHERE SC2.D_E_L_E_T_ = ' ' "
						cQLoteFor += "AND C2_FILIAL = '" + xFilial("SC2") + "' "
						cQLoteFor += "AND C2_PEDIDO = '" + SC9->C9_PEDIDO + "' "
						cQLoteFor += "AND C2_ITEM = '" + SC9->C9_ITEM + "' "

						cLoteFor := MpSysExecScalar(cQLoteFor, "LOTEFOR")

						If Empty(cLoteFor)
                        	CB8->CB8_XLOTFO := Posicione("SB8",3,xFilial("SB8")+(cTblTmp)->DC_PRODUTO+(cTblTmp)->DC_LOCAL+SC9->C9_LOTECTL+SC9->C9_LOTECTL, "B8_LOTEFOR")
						Else
							CB8->CB8_XLOTFO := cLoteFor
						EndIf

                    EndIf					

					If	lACD100GI
						ExecBlock("ACD100GI",.F.,.F.)
					EndIf
					CB8->(MsUnLock())
					//Atualizacao do controle do numero de itens a serem impressos
					nNumItens ++
					RecLock("CB7",.F.)
					CB7->CB7_NUMITE := nNumItens
					CB7->(MsUnLock())
					(cTblTmp)->( dbSkip() )
				End
				(cTblTmp)->( dbCloseArea()) 
			Else
				CB7->( dbSetOrder( 1 ) )
				CB7->( dbSeek( xFilial( "CB7" ) + cOrdSep ) )
				
				CB8->(RecLock("CB8",.T.))
				CB8->CB8_FILIAL := xFilial("CB8")
				CB8->CB8_ORDSEP := CB7->CB7_ORDSEP
				CB8->CB8_ITEM   := SC9->C9_ITEM
				CB8->CB8_PEDIDO := SC9->C9_PEDIDO
				CB8->CB8_PROD   := SC9->C9_PRODUTO
				CB8->CB8_LOCAL  := SC9->C9_LOCAL
				CB8->CB8_QTDORI := SC9->C9_QTDLIB
			
				If "09*" $ cTipExp
					CB8->CB8_SLDPRE := SC9->C9_QTDLIB
				EndIf
			
				CB8->CB8_SALDOS := SC9->C9_QTDLIB
				If ! "09*" $ cTipExp .AND. nEmbalagem == 1
					CB8->CB8_SALDOE := SC9->C9_QTDLIB
				EndIf
			
				CB8->CB8_LCALIZ := ""
				CB8->CB8_NUMSER := SC9->C9_NUMSERI
				CB8->CB8_SEQUEN := SC9->C9_SEQUEN
				CB8->CB8_LOTECT := SC9->C9_LOTECTL
				CB8->CB8_NUMLOT := SC9->C9_NUMLOTE
				CB8->CB8_CFLOTE := If("10*" $ cTipExp,"1","2")
				CB8->CB8_TIPSEP := If("09*" $ cTipExp,"1"," ")
				If	lACD100GI
					ExecBlock("ACD100GI",.F.,.F.)
				EndIf
				CB8->(MsUnLock())

				//Atualizacao do controle do numero de itens a serem impressos
				nNumItens ++
				RecLock("CB7",.F.)
				CB7->CB7_NUMITE := nNumItens
				CB7->(MsUnLock())
			EndIf
			Aadd(aRecSC9,{ SC9->(Recno() ), cOrdSep } )
	Next nXnd
Next nInd

CB7->(DbSetOrder(1))
For nI := 1 to len( aOrdSep )
	CB7->(DbSeek(xFilial("CB7")+aOrdSep[nI]))
	CB7->(RecLock("CB7"))
	CB7->CB7_STATUS := "0"  // nao iniciado
    CB7->CB7_XSTATU := CB7_STATUS
	CB7->(MsUnlock())

	If	lACDA100F
		ExecBlock("ACDA100F",.F.,.F.,{aOrdSep[nI]})
	EndIf
Next

For nI := 1 to len(aRecSC9)
	SC9->(DbGoto(aRecSC9[nI,1]))
    SC9->(RecLock("SC9"))
    SC9->C9_ORDSEP := aRecSC9[nI,2]
    SC9->C9_OK := space(len(SC9->C9_OK))
    SC9->(MsUnlock())
Next

If !Empty(aLogOS)
	LogACDA100()
Endif

End Transaction
Return

Static Function GeraOSepNota( cMarca, lInverte, cNotaSerie, oBrwMrk )
Local cChaveDB
Local cTipExp
Local nI
Local cCodOpe
Local aRecSD2 := {}
Local aOrdSep := {}
Local lFilItens  := ExistBlock("ACDA100I")  //Ponto de Entrada para filtrar o processamento dos itens selecionados
Local lA100CABE := ExistBlock("A100CABE")
Local lACD100GI := ExistBlock("ACD100GI")
Local lACDA100F := ExistBlock("ACDA100F")

Private aLogOS:= {}

Default cNotaSerie	:= Nil
Default oBrwMrk		:= Nil

// analisar a pergunta '00-Separcao,01-Separacao/Embalagem,02-Embalagem,03-Gera Nota,04-Imp.Nota,05-Imp.Volume,06-embarque'
If nEmbSimuNF == 1
	cTipExp := "01*"
Else
	cTipExp := "00*"
EndIF
If nEmbalagNF == 1
	cTipExp += "02*"
EndIF
If nImpNotaNF == 1
	cTipExp += "04*"
EndIF
If nImpVolNF == 1
	cTipExp += "05*"
EndIF
If nEmbarqNF == 1
	cTipExp += "06*"
EndIF
/*Ponto de entrada, permite que o usuário realize o processamento conforme suas particularidades.*/
If	ExistBlock("ACD100VG")
	If ! ExecBlock("ACD100VG",.F.,.F.,)
		Return
	EndIf		
EndIf

SF2->(DbSetOrder(1))
SD2->(DbSetOrder(3))
SD2->( dbGoTop() )

If cNotaSerie == Nil
	ProcRegua( SD2->( LastRec() ), "oook" )
	cCodOpe	 := cSeparador
Else
	SD2->(DbSetOrder(3))
	SD2->(DbSeek(xFilial("SD2")+cNotaSerie))
	cCodOpe := Space(06)
EndIf

ProcRegua( SD2->( LastRec() ), "oook" )
cCodOpe := cSeparador

While !SD2->( Eof() ) .and. ( cNotaSerie == Nil .Or. cNotaSerie == SD2->( D2_DOC + D2_SERIE ) )
	If ( cNotaSerie == NIL ) .And. !( oBrwMrk:IsMark() )
		SD2->( dbSkip() ) ; Loop
	EndIf

	If lFilItens
		If !ExecBlock("ACDA100I",.F.,.F.)
			SD2->( dbSkip() ) ; Loop
		Endif
	Endif

	cChaveDB :=xFilial("SDB")+SD2->(D2_COD+D2_LOCAL+D2_NUMSEQ+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA)
	If Localiza(SD2->D2_COD)
		SDB->(dbSetOrder(1))
		If ! SDB->(dbSeek( cChaveDB ))
			// neste caso nao existe composicao de empenho
			//Grava o historico das geracoes:
			aadd(aLogOS,{"2","Nota",SD2->D2_DOC,SD2->D2_SERIE,SD2->D2_CLIENTE,SD2->D2_LOJA,"Inconsistencia de base, nao existe registro de movimento (SDB)","NAO_GEROU_OS"})				 //"Nota"###"Inconsistencia de base, nao existe registro de movimento (SDB)"
			SD2->(DbSkip())
			If cNotaSerie == Nil
				IncProc()
			EndIf
			Loop
		EndIf
	EndIf

	CB7->(DbSetOrder(4))
	If ! CB7->(DbSeek(xFilial("CB7")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_LOCAL+" "))
		CB7->(RecLock( "CB7", .T. ))
		CB7->CB7_FILIAL := xFilial( "CB7" )
		CB7->CB7_ORDSEP := GetSX8Num( "CB7", "CB7_ORDSEP" )
		CB7->CB7_NOTA   := SD2->D2_DOC
		//CB7->CB7_SERIE  := SD2->D2_SERIE
		SerieNfId ("CB7",1,"CB7_SERIE",,,,SD2->D2_SERIE)
		CB7->CB7_CLIENT := SD2->D2_CLIENTE
		CB7->CB7_LOJA   := SD2->D2_LOJA
		CB7->CB7_LOCAL  := SD2->D2_LOCAL
		CB7->CB7_DTEMIS := dDataBase
		CB7->CB7_HREMIS := Time()
		CB7->CB7_STATUS := " "   // gravar STATUS de nao iniciada somente depois do processo
		CB7->CB7_CODOPE := cCodOpe
		CB7->CB7_PRIORI := "1"
		CB7->CB7_ORIGEM := "2"
		CB7->CB7_TIPEXP := cTipExp
		If SF2->(DbSeek(xFilial("SF2")+SD2->(D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA)))
			CB7->CB7_TRANSP := SF2->F2_TRANSP
		EndIf   
		If	lA100CABE
			ExecBlock("A100CABE",.F.,.F.)
		EndIf
		CB7->(MsUnLock())
		ConfirmSX8()
		//Grava o historico das geracoes:
		aadd(aLogOS,{"1","Nota",SD2->D2_DOC,SD2->D2_SERIE,SD2->D2_CLIENTE,SD2->D2_LOJA,"",CB7->CB7_ORDSEP})
		aadd(aOrdSep,CB7->CB7_ORDSEP)
	EndIf
	If Localiza(SD2->D2_COD)
		While SDB->(!Eof() .And. cChaveDB == DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_NUMSEQ+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA)
			If SDB->DB_ESTORNO == "S"
				SDB->(dbSkip())
				Loop
			EndIf
			CB8->(DbSetorder(4))
			If ! CB8->(DbSeek(xFilial("CB8")+CB7->CB7_ORDSEP+SD2->(D2_ITEM+D2_COD+D2_LOCAL+SDB->DB_LOCALIZ+D2_LOTECTL+D2_NUMLOTE+D2_NUMSERI)))
				CB8->(RecLock( "CB8", .T. ))
				CB8->CB8_FILIAL := xFilial( "CB8" )
				CB8->CB8_ORDSEP := CB7->CB7_ORDSEP
				CB8->CB8_ITEM   := SD2->D2_ITEM
				CB8->CB8_PEDIDO := SD2->D2_PEDIDO
				CB8->CB8_NOTA   := SD2->D2_DOC
				//CB8->CB8_SERIE  := SD2->D2_SERIE
				SerieNfId ("CB8",1,"CB8_SERIE",,,,SD2->D2_SERIE)
				CB8->CB8_PROD   := SD2->D2_COD
				CB8->CB8_LOCAL  := SD2->D2_LOCAL
				CB8->CB8_LCALIZ := SDB->DB_LOCALIZ
				CB8->CB8_SEQUEN := SDB->DB_ITEM
				CB8->CB8_LOTECT := SD2->D2_LOTECTL
				CB8->CB8_NUMLOT := SD2->D2_NUMLOTE
				CB8->CB8_NUMSER := SD2->D2_NUMSERI
				CB8->CB8_CFLOTE := "1"
				aadd(aRecSD2,{SD2->(Recno()),CB7->CB7_ORDSEP})
			Else
				CB8->(RecLock( "CB8", .f. ))
			EndIf
			CB8->CB8_QTDORI += SDB->DB_QUANT
			CB8->CB8_SALDOS += SDB->DB_QUANT
			If nEmbalagem == 1
				CB8->CB8_SALDOE += SDB->DB_QUANT
			EndIf
			If	lACD100GI
				ExecBlock("ACD100GI",.F.,.F.)
			EndIf
			CB8->(MsUnLock())
			SDB->(dbSkip())
		Enddo
	Else
		CB8->(DbSetorder(4))
		If ! CB8->(DbSeek(xFilial("CB8")+CB7->CB7_ORDSEP+SD2->(D2_ITEM+D2_COD+D2_LOCAL+Space(15)+D2_LOTECTL+D2_NUMLOTE+D2_NUMSERI)))
			CB8->(RecLock( "CB8", .T. ))
			CB8->CB8_FILIAL := xFilial( "CB8" )
			CB8->CB8_ORDSEP := CB7->CB7_ORDSEP
			CB8->CB8_ITEM   := SD2->D2_ITEM
			CB8->CB8_PEDIDO := SD2->D2_PEDIDO
			CB8->CB8_NOTA   := SD2->D2_DOC
			//CB8->CB8_SERIE  := SD2->D2_SERIE
			SerieNfId ("CB8",1,"CB8_SERIE",,,,SD2->D2_SERIE)				
			CB8->CB8_PROD   := SD2->D2_COD
			CB8->CB8_LOCAL  := SD2->D2_LOCAL
			CB8->CB8_LCALIZ := Space(15)
			CB8->CB8_SEQUEN := SD2->D2_ITEM
			CB8->CB8_LOTECT := SD2->D2_LOTECTL
			CB8->CB8_NUMLOT := SD2->D2_NUMLOTE
			CB8->CB8_NUMSER := SD2->D2_NUMSERI
			CB8->CB8_CFLOTE := "1"
			aadd(aRecSD2,{SD2->(Recno()),CB7->CB7_ORDSEP})
		Else
			CB8->(RecLock( "CB8", .f. ))
		EndIf
		CB8->CB8_QTDORI += SD2->D2_QUANT
		CB8->CB8_SALDOS += SD2->D2_QUANT
		If nEmbalagem == 1
			CB8->CB8_SALDOE += SD2->D2_QUANT
	    EndIf
		If	lACD100GI
			ExecBlock("ACD100GI",.F.,.F.)
		EndIf
		CB8->(MsUnLock())
	EndIf

	If cNotaSerie==Nil
		IncProc()
	EndIf
	SD2->( dbSkip() )
EndDo

CB7->(DbSetOrder(1))
For nI := 1 to len(aOrdSep)
	CB7->(DbSeek(xFilial("CB7")+aOrdSep[nI]))
	CB7->(RecLock("CB7"))
	CB7->CB7_STATUS := "0"  // nao iniciado
	CB7->(MsUnlock())
	If	lACDA100F
		ExecBlock("ACDA100F",.F.,.F.,{aOrdSep[nI]})
	EndIf
Next
For nI := 1 to len(aRecSD2)
	SD2->(DbGoto(aRecSD2[nI,1]))
	SD2->(RecLock("SD2",.F.))
	SD2->D2_ORDSEP := aRecSD2[nI,2]
	SD2->(MsUnlock())
Next
If !Empty(aLogOS)
	LogACDA100()
Endif
Return


Static Function GeraOSepProducao( cMarca, lInverte, oBrwMrk )
Local cOrdSep,aOrdSep := {},nI
Local cCodOpe
Local aRecSC2   := {}
Local aAreaAnt  := {}
Local cTipExp
Local aItemCB8  := {}
Local lSai      := .f.
Local cArm      := Space(Tamsx3("B1_LOCPAD")[1])
Local lFilItens := ExistBlock("ACDA100I")  //Ponto de Entrada para filtrar o processamento dos itens selecionados
Local cTM	    := GetMV("MV_CBREQD3")
Local lConsEst  := SuperGetMV("MV_CBRQEST",,.F.)  //Considera a Estrutura do Produto x Saldo na geracao da Ordem de Separacao
Local lParcial  := SuperGetMV("MV_CBOSPRC",,.F.)  //Permite ou nao gerar Ordens de Separacoes parciais
Local lGera		:= .T.
Local lA100CABE := ExistBlock("A100CABE")
Local lACD100GI := ExistBlock("ACD100GI")
Local lACDA100F := ExistBlock("ACDA100F")
Local lExtACDEMP := ExistBlock("ACD100EMP")
Local nSalTotIt := 0
Local nSaldoEmp := 0
Local aSaldoSBF := {}
Local aSaldoSDC := {}
Local nSldGrv   := 0
Local nRetSldEnd:= 0
Local nRetSldSDC:= 0
Local nSldAtu   := 0
Local nQtdEmpOS := 0
Local nQtdOpInt := 0
Local nPosEmp    
Local nX
Local lGroupLoc	:= IIf( Type( 'nGroupLoc' ) == 'N', ( nGroupLoc == 2 ), .F. )
Local lBlkPApInd:= SuperGetMv( "MV_PAPRIND", .F., .F. ) //Parametro que Indica se Pode Ser Gerada Ordem de Separacao para Produto de Aprop. Indireta.

Private aLogOS	:= {}
Private aEmp	:= {}
Private cProdPA	:= Nil
Private cArmPA	:= Nil

Default oBrwMrk	:= Nil


// analisar a pergunta '00-Separcao,01-Separacao/Embalagem,02-Embalagem,03-Gera Nota,04-Imp.Nota,05-Imp.Volume,06-embarque,07-Requisita'
cTipExp := "00*"

If nReqMatOP == 1
	cTipExp += "07*" //Requisicao
EndIf

If nAglutArmOP == 1 // Aglutina armazem
	cTipExp +="08*"
EndIf

If nPreSep == 1 // Pre-Separacao
	cTipExp +="09*"
EndIf
/*Ponto de entrada, permite que o usuário realize o processamento conforme suas particularidades.*/
If	ExistBlock("ACD100VG")
	If ! ExecBlock("ACD100VG",.F.,.F.,)
		Return
	EndIf		
EndIf

SC2->( dbGoTop() )
ProcRegua( SC2->( LastRec() ), "oook" )
cCodOpe	 := cSeparador

SB2->(DbSetOrder(1))
SD4->(DbSetOrder(2))
SDC->(dbSetOrder(2))
CB7->(DbSetOrder(1))
NNR->(dbSetOrder(1)) //NNR_FILIAL, NNR_CODIGO

While !SC2->( Eof() )
	If !( oBrwMrk:IsMark() )
		IncProc()
		SC2->( dbSkip() ) ; Loop
	EndIf

	If lFilItens
		If !ExecBlock("ACDA100I",.F.,.F.)
			SC2->(DbSkip())
			IncProc()
			Loop
		Endif
	Endif

	cProdPA	:= SC2->C2_PRODUTO
	cArmPA	:= SC2->C2_LOCAL

	CB8->(DbSetOrder(6))
	If CB8->(DbSeek(xFilial("CB8")+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN))
		If CB7->(DbSeek(xFilial("CB7")+CB8->CB8_ORDSEP)) .and. CB7->CB7_STATUS # "9" // Ordem em aberto
			//Grava o historico das geracoes:
			aadd(aLogOS,{"2","OP",SC2->(C2_NUM+C2_ITEM+C2_SEQUEN),"","","Existe uma Ordem de Separacao em aberto para esta Ordem de Producao","NAO_GEROU_OS"}) //"Existe uma Ordem de Separacao em aberto para esta Ordem de Producao"
			IncProc()
			SC2->(dbSkip())
			Loop
		Endif
	EndIf

	lSai := .f.
	aEmp := {}
	SD4->(DbSeek(xFilial('SD4')+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN))
	While SD4->(! Eof() .And. D4_FILIAL+Left(D4_OP,11) == xFilial('SD4')+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN)
		If SD4->D4_QUANT <= 0
			SD4->(DbSkip())
			Loop
		Endif
		
		If !NNR->( dbSeek( FWxFilial( 'NNR' ) + SD4->D4_LOCAL ) ) //NNR_FILIAL, NNR_CODIGO
			SD4->( dbSkip() ) ; Loop
		EndIf
		
		If lParcial .And. Localiza(SD4->D4_COD)// Se permitir parcial, controlar localização e nao existir composição de empenho, passa para o proximo.   
			If !CBArmProc(SD4->D4_COD,cTM)
				aSaldoSDC := RetSldSDC(SD4->D4_COD,SD4->D4_LOCAL,SD4->D4_OP,.F.,"","",SD4->D4_TRT)
				If Empty(aSaldoSDC)
				    SD4->(DbSkip())
				    Loop
	             EndIf
			Else
				aSaldoSBF := RetSldEnd( SD4->D4_COD, .f.,, IIf( lGroupLoc, SD4->D4_LOCAL, Nil ), lGroupLoc, cArmPA )
				If Empty(aSaldoSBF)
					SD4->(DbSkip())
					Loop
				EndIf
			EndIf  
	    EndIf
		SB1->(DBSetOrder(1))
		If SB1->(DbSeek(xFilial("SB1")+SD4->D4_COD)) .And. IsProdMOD(SD4->D4_COD)
			SD4->(DbSkip())
			Loop
		Endif

		If IsPrdApInd( SD4->D4_COD ) .And. lBlkPApInd
			SD4->( dbSkip() ) ; Loop
		EndIf

		If lExtACDEMP
			lACD100EMP := ExecBlock("ACD100EMP",.F.,.F.,{SD4->D4_OP,SD4->D4_COD,SD4->D4_QUANT})
			lACD100EMP := If(ValType(lACD100EMP)=="L",lACD100EMP,.T.)
			If !lACD100EMP
				SD4->(DbSkip())
				Loop
			Endif
		Endif

		//-- Nao permitir a geracao da OS por OP, caso o Lote esteja vazio
		If Rastro(SD4->D4_COD) .And. Empty(SD4->D4_LOTECTL)
			//Grava o historico das geracoes:
			aadd(aLogOS,{"2","OP",SD4->D4_OP,SD4->D4_COD,"","O produto "+Alltrim(SD4->D4_COD)+" tem controle de rastreabilidade e o Lote nao foi informado.","NAO_GEROU_OS"}) //"OP"###"O produto " //" tem controle de rastreabilidade e o Lote nao foi informado."
			lSai := .t.
		EndIf

		If !Localiza(SD4->D4_COD) // Nao controla endereco
			nQtdOpInt := 0
			// Verifica se tem OP intermediaria e considera o apontamento desta como saldo
			If !Empty(SD4->D4_OPORIG)
				aAreaAnt := GetArea()
				DbSelectArea("SD3")
				DbSetOrder(1)
				If DbSeek(xFilial("SD3")+SD4->(D4_OPORIG+D4_COD+D4_LOCAL))
					If D3_CF == "PR0" .And. D3_ESTORNO == " "
						nQtdOpInt := D3_QUANT
					EndIf
				EndIf
				RestArea(aAreaAnt)
			EndIf

			SB2->(DbSeek(xFilial("SB2")+SD4->(D4_COD+D4_LOCAL)))
			nSldAtu := If(CBArmProc(SD4->D4_COD,cTM),SB2->B2_QATU,SaldoSB2()+SD4->D4_QUANT)
			nSldAtu += nQtdOpInt
			nPosEmp := Ascan(aEmp,{|x| x[02] == SD4->D4_COD})
			If nPosEmp == 0
				aadd(aEmp,{SD4->D4_OP,SD4->D4_COD,SD4->D4_QUANT,nSldAtu,0,0,0})
			Else
				aEmp[nPosEmp,03] += SD4->D4_QUANT
			Endif
			SD4->(DbSkip())
			Loop
		Endif
		If !CBArmProc(SD4->D4_COD,cTM) .AND. If(!lParcial,(SD4->D4_QUANT > (nRetSldSDC := RetSldSDC(SD4->D4_COD,SD4->D4_LOCAL,SD4->D4_OP,.t.,"","",SD4->D4_TRT))),.F.) .AND. !lConsEst  
			//Grava o historico das geracoes:
			aadd(aLogOS,{"2","OP",SD4->D4_OP,SD4->D4_COD,"","O produto "+Alltrim(SD4->D4_COD)+" nao encontra-se empenhado (SD4 x SDC)","NAO_GEROU_OS"}) //"OP"###"O produto "###" nao encontra-se empenhado (SD4 x SDC)"
			lSai := .t.
		ElseIf CBArmProc(SD4->D4_COD,cTM) .AND. If(!lParcial,(SD4->D4_QUANT > (nRetSldEnd := RetSldEnd( SD4->D4_COD,.t.,, IIf( lGroupLoc, SD4->D4_LOCAL, Nil ), lGroupLoc, cArmPA ))),.F.) .AND. !lConsEst
			//Grava o historico das geracoes:
			aadd(aLogOS,{"2","OP",SD4->D4_OP,SD4->D4_COD,"","O produto "+Alltrim(SD4->D4_COD)+" nao possui saldo enderecado suficiente."+CHR(13)+CHR(10)+"        (ou existem Ordens de Separacao ainda nao requisitadas)","NAO_GEROU_OS"}) //"OP"###"O produto " //" nao possui saldo enderecado suficiente."###"        (ou existem Ordens de Separacao ainda nao requisitadas)"
			lSai := .t.
		EndIf
		nPosEmp := Ascan(aEmp,{|x| x[02] == SD4->D4_COD})
		If nPosEmp == 0
			aadd(aEmp,{SD4->D4_OP,SD4->D4_COD,SD4->D4_QUANT,If(CBArmProc(SD4->D4_COD,cTM),nRetSldEnd,nRetSldSDC),0,0,0})
		Else
			aEmp[nPosEmp,03] += SD4->D4_QUANT
		Endif
		SD4->(DbSkip())
		Loop
	EndDo
	If lConsEst  //Considera a Estrutura do Produto x Saldo na geracao da Ordem de Separacao
		If SemSldOS()
			//Grava o historico das geracoes:
			aadd(aLogOS,{"2","OP",SD4->D4_OP,SD4->D4_COD,"","Os itens empenhados nao possuem saldo em estoque suficiente para a producao de uma unidade do produto da OP","NAO_GEROU_OS"}) //"Os itens empenhados nao possuem saldo em estoque suficiente para a producao de uma unidade do produto da OP"
			lSai := .t.
		Endif
	Endif
	If lSai
		IncProc()
		SC2->(dbSkip())
		Loop
	EndIf

	SD4->(DbSeek(xFilial('SD4')+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN))
	While SD4->(!Eof() .And. D4_FILIAL+Left(D4_OP,11) == xFilial('SD4')+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN)
		If SD4->D4_QUANT <= 0
			SD4->(DbSkip())
			Loop
		EndIf  

		If !NNR->( dbSeek( FWxFilial( 'NNR' ) + SD4->D4_LOCAL ) ) //NNR_FILIAL, NNR_CODIGO
			SD4->( dbSkip() ) ; Loop
		EndIf

		If lParcial .And. Localiza(SD4->D4_COD)// Se permitir parcial, controlar localização e nao existir composição de empenho, passa para o proximo.   
			If !CBArmProc(SD4->D4_COD,cTM)
				aSaldoSDC := RetSldSDC(SD4->D4_COD,SD4->D4_LOCAL,SD4->D4_OP,.F.,SD4->D4_LOTECTL,SD4->D4_NUMLOTE,SD4->D4_TRT)
				If Empty(aSaldoSDC)
					aadd(aLogOS,{"2","OP",SD4->D4_OP,SD4->D4_COD,"","O produto "+Alltrim(SD4->D4_COD)+" nao encontra-se empenhado (SD4 x SDC)","NAO_GEROU_OS"}) //"OP"###"O produto "###" nao encontra-se empenhado (SD4 x SDC)"
				    SD4->(DbSkip())
				    Loop
	             EndIf
			Else
				aSaldoSBF := RetSldEnd(SD4->D4_COD, .f.,, IIf( lGroupLoc, SD4->D4_LOCAL, Nil ), lGroupLoc, cArmPA )
				If Empty(aSaldoSBF)
					aadd(aLogOS,{"2","OP",SD4->D4_OP,SD4->D4_COD,"","O produto "+Alltrim(SD4->D4_COD)+" nao possui saldo enderecado suficiente."+CHR(13)+CHR(10)+"        (ou existem Ordens de Separacao ainda nao requisitadas)","NAO_GEROU_OS"}) //"OP"###"O produto " //" nao possui saldo enderecado suficiente."###"        (ou existem Ordens de Separacao ainda nao requisitadas)"
					SD4->(DbSkip())
					Loop
				EndIf
			EndIf  
	    EndIf
		SB1->(DBSetOrder(1))
		If SB1->(DbSeek(xFilial("SB1")+SD4->D4_COD)) .And. IsProdMOD(SD4->D4_COD)
			SD4->(DbSkip())
			Loop
		Endif
		
		If IsPrdApInd( SD4->D4_COD ) .And. lBlkPApInd
			SD4->( dbSkip() ) ; Loop
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de Entrada na Geração das Ordens de Separação.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lExtACDEMP
			lACD100EMP := ExecBlock("ACD100EMP",.F.,.F.,{SD4->D4_OP,SD4->D4_COD,SD4->D4_QUANT})
			lACD100EMP := If(ValType(lACD100EMP)=="L",lACD100EMP,.T.)
			If !lACD100EMP
				SD4->(DbSkip())
				Loop
			Endif
		Endif
		
		If !("08*" $ cTipExp)  // gera ordem de separacao por armazem
			cArm := If(CBArmProc(SD4->D4_COD,cTM), Posicione( 'SB1', 1, FWxFilial( 'SB1' ) + SD4->D4_COD, 'B1_LOCPAD' ), SD4->D4_LOCAL )
		Else  // gera ordem de separa com todos os armazens
			cArm :=Space(Tamsx3("B1_LOCPAD")[1])
		EndIf

		If "09*" $ cTipExp // AGLUTINA PARA PRE-SEPARACAO
			cOP:= Space(Len(SD4->D4_OP))
		Else
			cOP:= SD4->D4_OP
		Endif

		CB7->(DbSetOrder(5))
		If ! CB7->(DbSeek(xFilial("CB7")+cOP+cArm+" "))
			cOrdSep   := GetSX8Num( "CB7", "CB7_ORDSEP" )
			CB7->(RecLock( "CB7", .T. ))
			CB7->CB7_FILIAL := xFilial( "CB7" )
			CB7->CB7_ORDSEP := cOrdSep
			CB7->CB7_OP     := cOP
			CB7->CB7_LOCAL  := cArm
			CB7->CB7_DTEMIS := dDataBase
			CB7->CB7_HREMIS := Time()
			CB7->CB7_STATUS := " "   // gravar STATUS de nao iniciada somente depois do processo
			CB7->CB7_CODOPE := cCodOpe
			CB7->CB7_PRIORI := "1"
			CB7->CB7_ORIGEM := "3"
			CB7->CB7_TIPEXP := cTipExp 
			If	lA100CABE
				ExecBlock("A100CABE",.F.,.F.)
			EndIf
			ConfirmSX8()
			//Grava o historico das geracoes:
			aadd(aLogOS,{"1","OP",SD4->D4_OP,"",cArm,"",CB7->CB7_ORDSEP})
			aadd(aOrdSep,cOrdSep)
		EndIf

		If Localiza(SD4->D4_COD) //controla endereco
			If !CBArmProc(SD4->D4_COD,cTM)
				aSaldoSDC := RetSldSDC(SD4->D4_COD,SD4->D4_LOCAL,SD4->D4_OP,.F.,SD4->D4_LOTECTL,SD4->D4_NUMLOTE,SD4->D4_TRT)
				nSalTotIt := 0
				For nX:=1 to Len(aSaldoSDC)
					nSalTotIt+=aSaldoSDC[nX,7]
				Next
 			    If lConsEst
	 			    nSaldoEmp := RetEmpOS(lConsEst,SD4->D4_COD,SD4->D4_QUANT)
 			    EndIf
 			    
				// Separacoes sao geradas conf. empenhos nos enderecos (SDC)
				For nX:=1 to Len(aSaldoSDC)
					lGera := .T.
	 			    If !lConsEst
	 				    nSaldoEmp := RetEmpOS(lConsEst,SD4->D4_COD,aSaldoSDC[nX,7])
                    EndIf
					If (!lConsEst .And. !lParcial) .And. SD4->D4_QTDEORI <> nSalTotIt
						Exit
					ElseIf lConsEst .And. nSaldoEmp == 0
						lGera := .F.
					Else
						nSldGrv   := aSaldoSDC[nX,7]
						nSaldoEmp -= aSaldoSDC[nX,7]
					EndIf
					If lGera
						cOrdSep := CB7->CB7_ORDSEP
						CB8->(RecLock( "CB8", .T. ))
						CB8->CB8_FILIAL := xFilial( "CB8" )
						CB8->CB8_ORDSEP := cOrdSep
						CB8->CB8_OP     := SD4->D4_OP
						CB8->CB8_ITEM   := RetItemCB8(cOrdSep,aItemCB8)
						CB8->CB8_PROD   := SD4->D4_COD
						CB8->CB8_LOCAL  := aSaldoSDC[nX,2]
						CB8->CB8_QTDORI := nSldGrv
						CB8->CB8_SALDOS := nSldGrv
						If nEmbalagem == 1
							CB8->CB8_SALDOE := nSldGrv
						EndIf
						CB8->CB8_LCALIZ := aSaldoSDC[nX,3]
						CB8->CB8_SEQUEN := ""
						CB8->CB8_LOTECT := aSaldoSDC[nX,4]
						CB8->CB8_NUMLOT := aSaldoSDC[nX,5]
						CB8->CB8_NUMSER := aSaldoSDC[nX,6]
						CB8->CB8_CFLOTE := "1"
						If "09*" $ cTipExp
							CB8->CB8_SLDPRE := nSldGrv
						EndIf
						If CB8->(ColumnPos("CB8_TRT")) > 0
							CB8->CB8_TRT	:= SD4->D4_TRT
						EndIf
						If	lACD100GI
							ExecBlock("ACD100GI",.F.,.F.)
						EndIf
						CB8->(MsUnLock())
					EndIf
				Next
				SD4->(DbSkip())	
				Loop
			Else
				aSaldoSBF := RetSldEnd(SD4->D4_COD, .f.,, IIf( lGroupLoc, SD4->D4_LOCAL, Nil ), lGroupLoc, cArmPA )
 			    If lConsEst
	 			    nSaldoEmp := RetEmpOS(lConsEst,SD4->D4_COD,SD4->D4_QUANT)
 			    EndIf	
				For nX:=1 to Len(aSaldoSBF)
	 			    If !lConsEst .and. nX==1
	 				    nSaldoEmp := RetEmpOS(lConsEst,SD4->D4_COD,SD4->D4_QUANT)
                    EndIf
                    If nSaldoEmp < 1
                    	Loop
                    EndIf
                    
					If lConsEst .And. nSaldoEmp == 0
						SD4->(DbSkip())
						Exit
						nSaldoEmp -= aSaldoSDC[nX,7]
					EndIf
					cOrdSep := CB7->CB7_ORDSEP
					CB8->(RecLock( "CB8", .T. ))
					CB8->CB8_FILIAL := xFilial( "CB8" )
					CB8->CB8_ORDSEP := cOrdSep
					CB8->CB8_OP     := SD4->D4_OP
					CB8->CB8_ITEM   := RetItemCB8(cOrdSep,aItemCB8)
					CB8->CB8_PROD   := aSaldoSBF[nX,1]
					CB8->CB8_LOCAL  := aSaldoSBF[nX,2]
					CB8->CB8_QTDORI := nSaldoEmp
					CB8->CB8_SALDOS := Iif (!aSaldoSBF[nX,7] > nSaldoEmp,aSaldoSBF[nX,7],nSaldoEmp)
					If nEmbalagem == 1
						CB8->CB8_SALDOE := nSaldoEmp
	                EndIf
					CB8->CB8_LCALIZ := aSaldoSBF[nX,3]
					CB8->CB8_SEQUEN := ""
					CB8->CB8_LOTECT := aSaldoSBF[nX,4]
					CB8->CB8_NUMLOT := aSaldoSBF[nX,5]
					CB8->CB8_NUMSER := aSaldoSBF[nX,6]
					CB8->CB8_CFLOTE := "1"
					If "09*" $ cTipExp
						CB8->CB8_SLDPRE := nSaldoEmp
					EndIf
					If CB8->(ColumnPos("CB8_TRT")) > 0
						CB8->CB8_TRT	:= SD4->D4_TRT
					EndIf
					If	lACD100GI
						ExecBlock("ACD100GI",.F.,.F.)
					EndIf
					CB8->(MsUnLock())
					nSaldoEmp -= aSaldoSBF[nX,7]				
				Next Nx
				SD4->(DbSkip())	
			Endif
		Else
			cOrdSep   := CB7->CB7_ORDSEP
			nQtdEmpOS := RetEmpOS(lConsEst,SD4->D4_COD,SD4->D4_QUANT)
			CB8->(RecLock( "CB8", .T. ))
			CB8->CB8_FILIAL := xFilial( "CB8" )
			CB8->CB8_ORDSEP := cOrdSep
			CB8->CB8_OP     := SD4->D4_OP
			CB8->CB8_ITEM   := RetItemCB8(cOrdSep,aItemCB8)
			CB8->CB8_PROD   := SD4->D4_COD
			CB8->CB8_LOCAL  := If(CBArmProc(SD4->D4_COD,cTM), Posicione( 'SB1', 1, FWxFilial( 'SB1' ) + SD4->D4_COD, 'B1_LOCPAD' ), SD4->D4_LOCAL )
			CB8->CB8_QTDORI := nQtdEmpOS
			CB8->CB8_SALDOS := nQtdEmpOS
			If nEmbalagem == 1
				CB8->CB8_SALDOE := nQtdEmpOS
			EndIf
			CB8->CB8_LCALIZ := Space(15)
			CB8->CB8_SEQUEN := ""
			CB8->CB8_LOTECT := SD4->D4_LOTECTL
			CB8->CB8_NUMLOT := SD4->D4_NUMLOTE
			CB8->CB8_CFLOTE := "1"
			If "09*" $ cTipExp
				CB8->CB8_SLDPRE := nQtdEmpOS
			EndIf
			If CB8->(ColumnPos("CB8_TRT")) > 0
				CB8->CB8_TRT	:= SD4->D4_TRT
			EndIf
			If	lACD100GI
				ExecBlock("ACD100GI",.F.,.F.)
			EndIf
			CB8->(MsUnLock())
			SD4->(DbSkip())
		Endif
	EndDo
	aadd(aRecSC2,SC2->(Recno()))
	IncProc()
	SC2->( dbSkip() )
EndDo

CB7->(DbSetOrder(1))
For nI := 1 to len(aOrdSep)
	CB7->(DbSeek(xFilial("CB7")+aOrdSep[nI]))
	CB7->(RecLock("CB7"))
	CB7->CB7_STATUS := "0"  // nao iniciado
	CB7->(MsUnlock())
	If	lACDA100F
		ExecBlock("ACDA100F",.F.,.F.,{aOrdSep[nI]})
	EndIf
Next
For nI := 1 to len(aRecSC2)
	SC2->(DbGoto(aRecSC2[nI]))
	SC2->(RecLock("SC2"))
	SC2->C2_ORDSEP := cOrdSep
	SC2->(MsUnlock())
Next

If lParcial .and. Empty(aOrdSep) .and. !Empty(aLogOS) // Quando permitir parcial somente gera log se nao existir nenhuma item na OS
	LogACDA100()
Elseif !lparcial .and.!Empty(aLogOS)
	LogACDA100()
EndIf

Return

Static Function RetItemCB8(cOrdSep,aItemCB8)

Local nPos := Ascan(aItemCB8,{|x| x[1] == cOrdSep})
Local cItem :=' '

If Empty(nPos )
	AAdd(aItemCB8,{cOrdSep,'00'})
	nPos := len(aItemCB8)
EndIF

cItem := Soma1(aItemcb8[nPos,2])
aItemcb8[nPos,2]:= cItem

Return cItem

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³REACDA100 ³ Autor ³ Anderson Rodrigues    ³ Data ³ 29/10/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Rotina de Impressao das ordens de separacao                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function REACDA100()
Local lContinua      := .T.
Local lCustRel		 := ExistBlock("ACD100RE")
Local cCustRel		 := ""
Local lACDR100		:= SuperGetMV("MV_ACDR100",.F.,.F.)
Private cString      := "CB7"
Private aOrd         := {}
Private cDesc1       := "Este programa tem como objetivo imprimir informacoes das" //"Este programa tem como objetivo imprimir informacoes das"
Private cDesc2       := "Ordens de separacao" //"Ordens de Separacao"
Private cPict        := ""
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 132
Private tamanho      := "M"
Private nomeprog     := "ACDA100R" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo        := 18
Private aReturn      := {"Zebrado",1,"Administracao",2,2,1,"",1}  //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private cPerg        := "ACD100"
Private titulo       := "Impressao das Ordens de Separacao" //"Impressao das Ordens de Separacao"
Private nLin         := 06
Private Cabec1       := ""
Private Cabec2       := ""
Private cbtxt        := "Regsitro(s) lido(s)" //"Regsitro(s) lido(s)"
Private cbcont       := 0
Private CONTFL       := 01
Private m_pag        := 01
Private lRet         := .T.
Private imprime      := .T.
Private wnrel        := "ACDA100R" // Coloque aqui o nome do arquivo usado para impressao em disco

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas como Parametros                                ³
//³ MV_PAR01 = Ordem de Separacao de       ?                            ³
//³ MV_PAR02 = Ordem de Separacao Ate      ?                            ³
//³ MV_PAR03 = Data de Emissao de          ?                            ³
//³ MV_PAR04 = Data de Emissao Ate         ?                            ³
//³ MV_PAR05 = Considera Ordens encerradas ?                            ³
//³ MV_PAR06 = Imprime Codigo de barras    ?                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lCustRel
	cCustRel := ExecBlock("ACD100RE",.F.,.F.)
	If ExistBlock(cCustRel)
		ExecBlock( cCustRel, .F., .F.)
	EndIf
ElseIf lACDR100
	ACDR100()
Else 
	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,Nil,.F.,aOrd,.F.,Tamanho,,.T.)

	Pergunte(cPerg,.F.)

	If	nLastKey == 27
		lContinua := .F.
	EndIf

	If	lContinua
		SetDefault(aReturn,cString)
	EndIf

	If	nLastKey == 27
		lContinua := .F.
	EndIf                        	

	If	lContinua
		RptStatus({|| Relatorio() },Titulo)
	EndIf

	CB7->(DbClearFilter())
EndIf
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ Relatorioº Autor ³ Anderson Rodrigues º Data ³  29/10/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAACD                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Relatorio()

CB7->(DbSetOrder(1))
CB7->(DbSeek(xFilial("CB7")+MV_PAR01,.T.)) // Posiciona no 1o.reg. satisfatorio 
SetRegua(RecCount()-Recno())

While ! CB7->(EOF()) .and. (CB7->CB7_ORDSEP >= MV_PAR01 .and. CB7->CB7_ORDSEP <= MV_PAR02)
	If CB7->CB7_DTEMIS < MV_PAR03 .or. CB7->CB7_DTEMIS > MV_PAR04 // Nao considera as ordens que nao tiver dentro do range de datas 
		CB7->(DbSkip())
		Loop
	Endif
	If MV_PAR05 == 2 .and. (CB7->CB7_STATUS == "9" .Or. CB7->CB7_XSTATU == "9") // Nao Considera as Ordens ja encerradas
		CB7->(DbSkip())
		Loop
	Endif
	CB8->(DbSetOrder(1))
	If ! CB8->(DbSeek(xFilial("CB8")+CB7->CB7_ORDSEP))
		CB7->(DbSkip())
		Loop
	EndIf
	IncRegua("Imprimindo")  //"Imprimindo"
	If lAbortPrint
		@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***" //"*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	Imprime()
	CB7->(DbSkip())
Enddo
Fim()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ Imprime  º Autor ³ Anderson Rodrigues º Data ³  12/09/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela funcao Relatorio              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAACD                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Imprime(lRet)
Local cOrdSep := Alltrim(CB7->CB7_ORDSEP)
Local cPedido := Alltrim(CB7->CB7_PEDIDO)
Local cCliente:= Alltrim(CB7->CB7_CLIENT)
Local cLoja   := Alltrim(CB7->CB7_LOJA	)
Local cNota   := Alltrim(CB7->CB7_NOTA)
Local cSerie  := Alltrim(CB7->&(SerieNfId("CB7",3,"CB7_SERIE")))
Local cOP     := Alltrim(CB7->CB7_OP)
Local cStatus := ""
Local nWidth  := 0.050
Local nHeigth := 0.75
Local oPr

If nOSOpc == 1
    cStatus := RetStatus(CB7->CB7_XSTATU)
Else
    cStatus := RetStatus(CB7->CB7_STATUS)
EndIf

Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)

@ 06, 000 Psay "Ordem de Separacao: "+cOrdSep //"Ordem de Separacao: "

If CB7->CB7_ORIGEM == "1" // Pedido de Venda
	@ 06, 035 Psay "Pedido de Venda: "+cPedido 	 //"Pedido de Venda: "
	@ 06, 065 Psay "Cliente: "+cCliente+" - "+"Loja: "+cLoja //"Cliente: "###"Loja: "
	@ 06, 095 Psay "Status: "+cStatus //"Status: "
Elseif CB7->CB7_ORIGEM == "2" // Nota Fiscal de Saida
	@ 06, 035 Psay "Nota Fiscal: "+cNota+" - Serie: "+cSerie //"Nota Fiscal: "###" - Serie: "
	@ 06, 075 Psay "Cliente: "+cCliente+" - "+"Loja: "+cLoja //"Cliente: "###"Loja: "
	@ 06, 105 Psay "Status: "+cStatus //"Status: "
Elseif CB7->CB7_ORIGEM == "3" // Ordem de Producao
	@ 06, 035 Psay "Ordem de Producao: "+cOP //"Ordem de Producao: "
	@ 06, 070 Psay "Status: "+cStatus //"Status: "
Endif

If MV_PAR06 == 1 .And. aReturn[5] # 1
	oPr:= ReturnPrtObj()
  	MSBAR3("CODE128",2.8,0.8,cOrdSep,oPr,Nil,Nil,Nil,nWidth,nHeigth,.t.,Nil,"B",Nil,Nil,Nil,.f.)
  	nLin := 11 
Else
	nLin := 07
EndIf

@ ++nLin, 000 Psay Replicate("=",147)
nLin++

@nLin, 000 Psay "Produto" //"Produto"
@nLin, 032 Psay "Armazem" //"Armazem"
@nLin, 042 Psay "Endereco" //"Endereco"
@nLin, 058 Psay "Lote" //"Lote"
@nLin, 070 Psay "SubLote" //"SubLote"
@nLin, 079 Psay "Numero de Serie" //"Numero de Serie"
@nLin, 101 Psay "Qtd Original" //"Qtd Original"
@nLin, 116 Psay "Qtd a Separar" //"Qtd a Separar"
@nLin, 132 Psay "Qtd a Embalar" //"Qtd a Embalar"

CB8->(DbSetOrder(1))
CB8->(DbSeek(xFilial("CB8")+cOrdSep))

While ! CB8->(EOF()) .and. (CB8->CB8_ORDSEP == cOrdSep)
	nLin++
	If nLin > 59 // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 06
		@nLin, 000 Psay "Produto" //"Produto"
		@nLin, 032 Psay "Armazem" //"Armazem"
		@nLin, 042 Psay "Endereco" //"Endereco"
		@nLin, 058 Psay "Lote" //"Lote"
		@nLin, 070 Psay "SubLote" //"SubLote"
		@nLin, 079 Psay "Numero de Serie" //"Numero de Serie"
		@nLin, 101 Psay "Qtd Original" //"Qtd Original"
		@nLin, 116 Psay "Qtd a Separar" //"Qtd a Separar"
		@nLin, 132 Psay "Qtd a Embalar" //"Qtd a Embalar"
	Endif
	@nLin, 000 Psay CB8->CB8_PROD
	@nLin, 032 Psay CB8->CB8_LOCAL
	@nLin, 042 Psay CB8->CB8_LCALIZ
	@nLin, 058 Psay CB8->CB8_LOTECT
	@nLin, 070 Psay CB8->CB8_NUMLOT
	@nLin, 079 Psay CB8->CB8_NUMSER
	@nLin, 099 Psay CB8->CB8_QTDORI Picture "@E 999,999,999.99"
	@nLin, 114 Psay CB8->CB8_SALDOS Picture "@E 999,999,999.99"
	@nLin, 130 Psay CB8->CB8_SALDOE Picture "@E 999,999,999.99"	
	CB8->(DbSkip())
Enddo

Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza impressao                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Static Function Fim()

SET DEVICE TO SCREEN
If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif
MS_FLUSH()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ RetStatusº Autor ³ Anderson Rodrigues º Data ³  04/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela funcao Imprime                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAACD                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RetStatus(cStatus)
Local cDescri:= " "

If Empty(cStatus) .or. cStatus == "0"
	cDescri:= "Nao iniciado" //"Nao iniciado"
ElseIf cStatus == "1"
	cDescri:= "Em separacao" //"Em separacao"
ElseIf cStatus == "2"
	cDescri:= "Separacao finalizada" //"Separacao finalizada"
ElseIf cStatus == "3"
	cDescri:= "Em processo de embalagem" //"Em processo de embalagem"
ElseIf cStatus == "4"
	cDescri:= "Embalagem Finalizada" //"Embalagem Finalizada"
ElseIf cStatus == "5"
	cDescri:= "Nota gerada" //"Nota gerada"
ElseIf cStatus == "6"
	cDescri:= "Nota impressa" //"Nota impressa"
ElseIf cStatus == "7"
	cDescri:= "Volume impresso" //"Volume impresso"
ElseIf cStatus == "8"
	cDescri:= "Em processo de embarque" //"Em processo de embarque"
ElseIf cStatus == "9"
	cDescri:=  "Finalizado" //"Finalizado"
EndIf

Return(cDescri)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LGACDA100 ³ Autor ³ Eduardo Motta         ³ Data ³ 06/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Legenda para as cores da mbrowse                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function LGACDA100()
Local aCorDesc := {}
Local aCorUsr  := {}

If nOSOpc == 1
    aAdd(aCorDesc, {"PMSTASK1", "- Divergencia Validacao"})
    aAdd(aCorDesc, {"PMSTASK3", "- Validacao Pausada"})
    aAdd(aCorDesc, {"PMSTASK4", "- Validacao Finalizada"})
    aAdd(aCorDesc, {"PMSTASK2", "- Em Validacao Fisica"})
    aAdd(aCorDesc, {"PMSTASK6", "- Validacao nao iniciada"})
Else
    aAdd(aCorDesc, {"DISABLE"   , "- Divergencia"})
    aAdd(aCorDesc, {"BR_CINZA"  , "- Pausa"})
    aAdd(aCorDesc, {"ENABLE"    , "- Finalizado"})
    aAdd(aCorDesc, {"BR_AMARELO", "- Em andamento"})
    aAdd(aCorDesc, {"BR_AZUL"   , "- Nao iniciado"})
EndIf
                    
If ExistBlock("ACD100LG")
	aCorUsr := ExecBlock("ACD100LG",.F.,.F.,{aCorDesc})
	If ValType(aCorUsr) == "A"
		aCorDesc := aClone(aCorUsr)
	EndIf
EndIf
				
BrwLegenda( cCadastro, "Status", aCorDesc ) 	//"Legenda - Separacao"###"Status"

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MontaCols ³ Autor ³ Eduardo Motta         ³ Data ³ 06/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao para montagem do aCols na GetDados                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cSeekCB8 -> Chave de pesquisa no CB8                       ³±±
±±³          ³ oGet     -> objeto getdados a dar refresh (opcional)       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MontaCols(cSeekCB8,oGet)
Local nCnt,nUsado, nI

If Type("oTimer") == "O"
	oTimer:Deactivate()
EndIf

aCols := {}
aRecno:={}

nCnt := 0
CB8->(DbSetOrder(1))
CB8->( dbSeek( cSeekCB8 ) )
While !CB8->( Eof() ) .And. cSeekCB8 == CB8->CB8_FILIAL + CB8->CB8_ORDSEP

	nCnt++
	nUsado := 0
	aHeader:={}
	aadd(aCols,Array(Len(aHeader)+1))
	aadd(aRecno,CB8->(Recno()))
	aHeadAUX	:= aClone(APBuildHeader("CB8"))
	aHeader := aClone(aHeadAUX)
	For nI := 1 to Len(aHeadAUX)
		If X3USO(aHeadAUX[nI,7]) .and. allTrim(aHeadAUX[nI,2]) <> 'CB8_ORDSEP' .and. cNivel >= GetSx3Cache(trim(aHeadAUX[nI,2]), "X3_NIVEL")
			nUsado++ 
			If aHeadAUX[nI,10] # "V"
				cField := allTrim(aHeadAUX[nI,2])
				dbSelectArea("CB8")
				aCols[ nCnt, nUsado ] := FieldGet( FieldPos( cField ) )
				Aadd(aCols[nCnt],+1)
			ElseIf aHeadAUX[nI,10] == "V"
				Aadd(aCols[nCnt],+1)
				aCols[ nCnt, nUsado ] := CriaVar( AllTrim(aHeadAUX[nI,2]) )
				// Processa Gatilhos
				EvalTrigger()
			Endif
		EndIf
	Next nI 
	aCols[ nCnt, nUsado + 1 ] := .f.

	dbSelectArea( "CB8" )
	dbSkip()

EndDo
If oGet # Nil
	oGet:oBrowse:Refresh()
EndIf
If Type("oTimer") == "O"
	oTimer:Activate()
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TimerBrw  ³ Autor ³ Eduardo Motta         ³ Data ³ 06/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao que cria timer no mbrowse                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cMBrowse -> form em que sera criado o timer                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TimerBrw(oMBrowse)
Local oTimer
DEFINE TIMER oTimer INTERVAL 1000 ACTION TmBrowse(GetObjBrow(),oTimer) OF oMBrowse
oTimer:Activate()
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TmBrowse ³ Autor ³ Eduardo Motta         ³ Data ³ 06/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de timer do mbrowse                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cMBrowse -> objeto mbrowse a dar refresh                   ³±±
±±³          ³ oTimer   -> objeto timer                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TmBrowse(oObjBrow,oTimer)
oTimer:Deactivate()
oObjBrow:Refresh()
oTimer:Activate()
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ACDA100OC ³ Autor ³ Eduardo Motta         ³ Data ³ 18/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao do campo ocorrencia                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Validacao do campo CB8_OCOSEP                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*Function ACDA100OC()
aCols[n,GdFieldPos("CB8_DESOCS",aHeader)] := Posicione("CB4",1,xFilial("CB4")+M->CB8_OCOSEP,"CB4_DESCRI")
Return .T.*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LogACDA100³ Autor ³ Henrique Gomes Oikawa ³ Data ³ 23/09/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibicao do log das geracoes das Ordens de Separacao       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Apos a geracao das OS sao exibidas todas as informacoes que³±±
±±³          ³ ocorreram durante o processo                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function LogACDA100()
Local i, j, k
Local cChaveAtu, cPedCli, cOPAtual

If Type("l100Auto") == "L" .And. l100Auto
	lAutoErrNoFile := .T.
Else
	lAutoErrNoFile := .F.
EndIf

//Cabecalho do Log de processamento:
AutoGRLog(Replicate("=",75))
AutoGRLog("                         I N F O R M A T I V O") //"                         I N F O R M A T I V O"
AutoGRLog("               H I S T O R I C O   D A S   G E R A C O E S") //"               H I S T O R I C O   D A S   G E R A C O E S"

//Detalhes do Log de processamento:
AutoGRLog(Replicate("=",75))
AutoGRLog("I T E N S   P R O C E S S A D O S :") //"I T E N S   P R O C E S S A D O S :"
AutoGRLog(Replicate("=",75))
If aLogOS[1,2] == "Pedido" //"Pedido"
	aLogOS := aSort(aLogOS,,,{|x,y| x[01]+x[10]+x[03]+x[04]+x[05]+x[06]+x[07]+x[08]<y[01]+y[10]+y[03]+y[04]+y[05]+y[06]+y[07]+y[08]})
	// Status Ord.Sep(1=Gerou;2=Nao Gerou) + Ordem Separacao + Pedido + Cliente + Loja + Item + Produto + Local
	cChaveAtu := ""
	cPedCli   := ""
	For i:=1 to len(aLogOs)
		If aLogOs[i,10] <> cChaveAtu .OR. (aLogOs[i,03]+aLogOs[i,04] <> cPedCli)
			If !Empty(cChaveAtu)
				AutoGRLog(Replicate("-",75))
			Endif
			j:=0
			k:=i  //Armazena o conteudo do contador do laco logico principal (i) pois o "For" j altera o valor de i;
			cChaveAtu := aLogOs[i,10]
			For j:=k to len(aLogOs)
				If aLogOs[j,10] <> cChaveAtu
					Exit
				Endif
				If Empty(aLogOs[j,08]) //Aglutina Armazem
					AutoGRLog("Pedido: "+aLogOs[j,03]+" - Cliente: "+aLogOs[j,04]+"-"+aLogOs[j,05]) //"Pedido: "###" - Cliente: "
				Else
					AutoGRLog("Pedido: "+aLogOs[j,03]+" - Cliente: "+aLogOs[j,04]+"-"+aLogOs[j,05]+" - Local: "+aLogOs[j,08]) //"Pedido: "###" - Cliente: "###" - Local: "
				Endif
				cPedCli := aLogOs[j,03]+aLogOs[j,04]
				If aLogOs[j,10] == "NAO_GEROU_OS"
					Exit
				Endif
				i:=j
			Next
			AutoGRLog("Ordem de Separacao: "+If(aLogOs[i,01]=="1",aLogOs[i,10],"N A O  G E R A D A")) //"Ordem de Separacao: "###"N A O  G E R A D A"
			If aLogOs[i,01] == "2"  //Ordem Sep. NAO gerada
				AutoGRLog("Motivo: ") //"Motivo: "
			Endif
		Endif
		If aLogOs[i,01] == "2"  //Ordem Sep. NAO gerada
			AutoGRLog("Item: "+aLogOs[i,06]+" - Produto: "+AllTrim(aLogOs[i,07])+" - Local: "+aLogOs[i,08]+" ---> "+aLogOs[i,09]) //"Item: "###" - Produto: "###" - Local: "
		Endif
	Next
Elseif aLogOS[1,2] == "Nota" //"Nota"
	aLogOS := aSort(aLogOS,,,{|x,y| x[01]+x[08]+x[03]+x[04]+x[05]+x[06]<y[01]+y[08]+y[03]+y[04]+y[05]+y[06]})
	// Status Ord.Sep(1=Gerou;2=Nao Gerou) + Ordem Separacao + Nota + Serie + Cliente + Loja
	cChaveAtu := ""
	For i:=1 to len(aLogOs)
		If aLogOs[i,08] <> cChaveAtu
			If !Empty(cChaveAtu)
				AutoGRLog(Replicate("-",75))
			Endif
			cChaveAtu := aLogOs[i,08]
			AutoGRLog("Nota: "+aLogOs[i,3]+"/"+aLogOs[i,04]+" - Cliente: "+aLogOs[i,05]+"-"+aLogOs[i,06]) //"Nota: "###" - Cliente: "
			AutoGRLog("Ordem de Separacao: "+If(aLogOs[i,01]=="1",aLogOs[i,08],"N A O  G E R A D A")) //"Ordem de Separacao: "###"N A O  G E R A D A"
			If aLogOs[i,01] == "2"  //Ordem Sep. NAO gerada
				AutoGRLog("Motivo: ") //"Motivo: "
			Endif
		Endif
	Next
Else  //Ordem de Producao
	aLogOS := aSort(aLogOS,,,{|x,y| x[01]+x[07]+x[03]+x[04]<y[01]+y[07]+y[03]+y[04]})
	// Status Ord.Sep(1=Gerou;2=Nao Gerou) + Ordem Separacao + Ordem Producao + Produto
	cChaveAtu := ""
	cOPAtual  := ""
	For i:=1 to len(aLogOs)
		If aLogOs[i,07] <> cChaveAtu .OR. aLogOs[i,03] <> cOPAtual
			If !Empty(cChaveAtu)
				AutoGRLog(Replicate("-",75) )
			Endif
			j:=0
			k:=i  //Armazena o conteudo do contador do laco logico principal (i) pois o "For" j altera o valor de i;
			cChaveAtu := aLogOs[i,07]
			For j:=k to len(aLogOs)
				If aLogOs[j,07] <> cChaveAtu
					Exit
				Endif
				If Empty(aLogOs[j,05]) //Aglutina Armazem
					AutoGRLog("Ordem de Producao: "+aLogOs[i,03]) //"Ordem de Producao: "
				Else
					AutoGRLog("Ordem de Producao: "+aLogOs[i,03]+" - Local: "+aLogOs[j,05]) //"Ordem de Producao: "###" - Local: "
				Endif
				cOPAtual := aLogOs[j,03]
				If aLogOs[j,07] == "NAO_GEROU_OS"
					Exit
				Endif
				i:=j
			Next
			AutoGRLog("Ordem de Separacao: "+If(aLogOs[i,01]=="1",aLogOs[i,07],"N A O  G E R A D A")) //"Ordem de Separacao: "###"N A O  G E R A D A"
			If aLogOs[i,01] == "2"  //Ordem Sep. NAO gerada
				AutoGRLog("Motivo: ") //"Motivo: "
			Endif
		Endif
		If aLogOs[i,01] == "2"  //Ordem Sep. NAO gerada
			AutoGRLog(" ---> "+aLogOs[i,06])
		Endif
	Next
Endif
MostraParam(aLogOS[1,2])
If l100Auto
	If Type("aFileLog") == "A"
		aFileLog := GetAutoGRLog()
	EndIf
Else
	MostraErro()
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MostraParam ³ Autor ³ Henrique Gomes Oikawa ³ Data ³ 28/09/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibicao dos parametros da geracao da Ordem de Separacao     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MostraParam(cTipGer)
Local cPergParam  := ""
Local cPergConfig := ""
Local cDescTipGer := ""
Local cResp		  := ""
Local nTamSX1     := 0
Local aPerg       := {}
Local aParam      := {}
Local ni          := 0
Local nX		  := 0
Local nPos		  := 0
Local ci          := 0
Local aLogs       := {}
Local oObj
		  		

// se existe a classe FWSX1Util e o metodo GetAllFields não se encontra disponivel
// na versao da lib 20180615
If ACDLibVersion() >= "20180820"
	oObj := FWSX1Util():New()	
	oObj:AddGroup("AIA102")
    oObj:SearchGroup()
    nTamSX1 := len(oObj:aGrupo[1][1])
    
// faz o tratamento buscando direto na tabela SX1
// Caso gere issue na ferramenta SONARQUBE deve ser
// classificado como falso positivo. 
else
	nTamSX1 := Len(SX1->X1_GRUPO)
	
Endif

If cTipGer == "Pedido" //"Pedido"
	cPergParam  := PADR('AIA102',nTamSX1) 
	cPergConfig := PADR('AIA106',nTamSX1)
	cDescTipGer := 'PEDIDO DE VENDA' //'PEDIDO DE VENDA'
	aAdd(aParam,nConfLote)
	aAdd(aParam,nEmbSimul)
	aAdd(aParam,nEmbalagem)
	If cPaisLoc == "BRA"
		aAdd(aParam,nGeraNota)
		aAdd(aParam,nImpNota)
	EndIf
	aAdd(aParam,nImpEtVol)
	aAdd(aParam,nEmbarque)
	aAdd(aParam,nAglutPed)
	aAdd(aParam,nAglutArm)
	If ValType(nPriorEnd) == "N"
		aAdd(aParam,nPriorEnd)
	EndIf
Elseif cTipGer == "Nota" //"Nota"
	cPergParam  := PADR('AIA103',nTamSX1)
	cPergConfig := PADR('AIA107',nTamSX1)
	cDescTipGer := 'NOTA FISCAL' //'NOTA FISCAL'
	aAdd(aParam,nEmbSimuNF)
	aAdd(aParam,nEmbalagNF)
	aAdd(aParam,nImpNotaNF)
	aAdd(aParam,nImpVolNF)
	aAdd(aParam,nEmbarqNF)
Else //OP
	cPergParam  := PADR('AIA104',nTamSX1)
	cPergConfig := PADR('AIA108',nTamSX1)
	cDescTipGer := 'ORDEM DE PRODUCAO' //'ORDEM DE PRODUCAO'
	aAdd(aParam,nReqMatOP)
	aAdd(aParam,nAglutArmOP)
Endif

aAdd(aPerg,{"P A R A M E T R O S : "+cDescTipGer,cPergParam}) //"P A R A M E T R O S : "
aAdd(aPerg,{"C O N F I G U R A C O E S : "+cDescTipGer,cPergConfig}) //"C O N F I G U R A C O E S : "
//-- Carrega parametros SX1
For ni := 1 To Len(aPerg)
	//Posiciona no pergunte dentro do array
	nPos := aScan(aPerg100,{|x| x[1] == AllTrim(aPerg[ni,2])})
	aAdd(aLogs,{aPerg100[nPos,1],{}})
	//Percorre o Array para retornar as perguntas
	For nX := 1 To Len(aPerg100[nPos,2])
		If ValType(aPerg100[nPos,2,nX,2]) == "C"
			cResp := aPerg100[nPos,2,nX,2]
		ElseIf ValType(aPerg100[nPos,2,nX,2]) == "N"
			If aPerg100[nPos,2,nX,2] == 1
				cResp := "Sim" //Sim
			Else
				cResp := "Não" //Não
			EndIf
		Else
			cResp := ""
		EndIf		
		cTexto := "Pergunta " + StrZero(nX,2) + ": " + aPerg100[nPos,2,nX,1] + cResp
		aAdd(aLogs[ni,2],cTexto) 
	Next nX
	
Next

//-- Gera Log
For ni := 1 To Len(aPerg)
	AutoGRLog(Replicate("=",75))
	AutoGRLog(aPerg[ni,1])
	AutoGRLog(Replicate("=",75))
	For ci := 1 To Len(aLogs[ni,2])
		AutoGRLog(aLogs[ni,2,ci])
	Next
Next
AutoGRLog(Replicate("=",75))
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ AtivaF12 ³ Autor ³ Henrique Gomes Oikawa ³ Data ³ 27/09/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Executa a Funcao da Pergunte                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AtivaF12(nOrigExp)
Local lPerg := .F.
Local lRet  := .T.
If	nOrigExp == NIL
	lPerg := .T.
	If	(lRet:=Pergunte("AIA101",.t.))
		nOrigExp := MV_PAR01
	EndIf
EndIf
If	lRet
	If	nOrigExp == 1  //Origem: Pedidos de Venda
		If	Pergunte("AIA106",lPerg) .Or. !lPerg
			Aadd(aPerg100,ACD100Perg("AIA106"))
			nConfLote	:= MV_PAR01
			nEmbSimul	:= MV_PAR02
			nEmbalagem	:= MV_PAR03
			If cPaisLoc == "BRA"
				nGeraNota	:= MV_PAR04
				nImpNota	:= MV_PAR05
				nImpEtVol	:= MV_PAR06
				nEmbarque	:= MV_PAR07
				nAglutPed	:= MV_PAR08
				nAglutArm	:= MV_PAR09
				If ValType(MV_PAR10) == "N" 
					nPriorEnd   := MV_PAR10
				EndIf
			Else
				nImpEtVol	:= MV_PAR04
				nEmbarque	:= MV_PAR05
				nAglutPed	:= MV_PAR06
				nAglutArm	:= MV_PAR07
				If ValType(MV_PAR08) == "N" 
					nPriorEnd   := MV_PAR08
				EndIf
			EndIf		
		EndIf
	ElseIf	nOrigExp == 2  //Origem: Notas Fiscais
		If	Pergunte("AIA107",lPerg) .Or. !lPerg
			nEmbSimuNF := MV_PAR01
			nEmbalagNF := MV_PAR02
			nEmbalagem := MV_PAR02
			nImpNotaNF := MV_PAR03
			nImpVolNF  := MV_PAR04
			nEmbarqNF  := MV_PAR05
		EndIf
	Else  //Origem: Ordens de Producao
		If	Pergunte("AIA108",lPerg) .Or. !lPerg
			nReqMatOP   := MV_PAR01
			nAglutArmOP := MV_PAR02
		EndIf
	EndIf
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ RetSldSDC ³ Autor ³ Microsiga             ³ Data ³ 25/05/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os saldos disponiveis nas Composicoes de Empenho    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RetSldSDC(cProd,cLocal,cOP,lRetSaldo,cLote,cSublote,cSequen)
Local aArea     := GetArea()
Local aAreaSDC  := SDC->(GetArea())
Local nSaldoSDC := 0
Local aSaldoSDC := {}
Local cQuerySDC
Local lQuery    :=.F.
Local cAliasSDC := "SDC"

DEFAULT cLote := ''
DEFAULT cSubLote := ''

lQuery    :=.T.
cQuerySDC := "SELECT SDC.* "
cQuerySDC += " FROM " + RetSqlName("SDC") +" SDC "
cQuerySDC += " 		INNER JOIN " + RetSqlName( "NNR" ) +" NNR ON ( DC_FILIAL = '"+ FWxFilial( 'SDC' ) +"' AND NNR_FILIAL = '"+ FWxFilial( 'NNR' ) +"' AND DC_LOCAL = NNR_CODIGO ) "
cQuerySDC += " WHERE DC_PRODUTO = '" + cProd + "' AND DC_LOCAL = '" + cLocal + "' AND DC_OP = '" + cOP + "' AND "

If !Empty(cLote)
	cQuerySDC += " DC_LOTECTL = '" + cLote + "' AND " 
EndIf

If !Empty(cSubLote)
	cQuerySDC += " DC_NUMLOTE = '" + cSubLote + "' AND " 
EndIf

If !Empty(cSequen)
	cQuerySDC += " DC_TRT = '" + cSequen + "' AND " 
EndIf

cQuerySDC += " NNR.D_E_L_E_T_ = ' ' AND SDC.D_E_L_E_T_ = ' ' "
cQuerySDC += " ORDER BY SDC.R_E_C_N_O_"

cQuerySDC := ChangeQuery( cQuerySDC )
TCQUERY cQuerySDC NEW ALIAS "SDCTMP"
dbSelectArea("SDCTMP")
cAliasSDC := "SDCTMP"

While (cAliasSDC)->(!Eof() .AND. DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_OP == xFilial("SDC")+cProd+cLocal+cOP)
	nSaldoSDC += (cAliasSDC)->DC_QUANT
	aadd(aSaldoSDC,{(cAliasSDC)->DC_PRODUTO,(cAliasSDC)->DC_LOCAL,(cAliasSDC)->DC_LOCALIZ,(cAliasSDC)->DC_LOTECTL,(cAliasSDC)->DC_NUMLOTE,(cAliasSDC)->DC_NUMSERI,(cAliasSDC)->DC_QUANT,(cAliasSDC)->(recno())})
	(cAliasSDC)->(DbSkip())
Enddo
If lQuery
	(cAliasSDC)->( DbCloseArea() )
Endif
aSort(aSaldoSDC,,,{|x,y| x[08]<y[08]})

RestArea(aAreaSDC)
RestArea(aArea)
Return If(lRetSaldo,nSaldoSDC,aSaldoSDC)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ RetSldEnd ³ Autor ³ Microsiga                                                        ³ Data ³ 09/05/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os saldos disponiveis nos enderecos:                                                           ³±±
±±³          ³ - Quando produto com apropriacao INDIRETA, disconsidera o saldo de Ordens de Separacao ainda nao sepa- ³±±
±±³          ³   radas;                                                                                               ³±±
±±³          ³ - Quando produto com apropriacao DIRETA, disconsidera apenas o saldo nao separado do item atual;       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RetSldEnd(cProd,lRetSaldo,aVarAlt, cLocPad, lGroupLoc, cArmPA )
Local aArea     := GetArea()
Local aAreaSBF  := SBF->(GetArea())
Local cArmProc  := GetMvNNR('MV_LOCPROC','99')
Local cLocCQ    := GetMvNNR('MV_CQ','98')
Local nSaldoAtu := 0
Local nSaldoCB8 := 0
Local nSaldoSBF := 0
Local aSaldoSBF := {}
Local cQuerySBF
Local lQuery    :=.F.
Local cAliasSBF := "SBF"
Local lACD100END                 

Local cTM       := GetMV("MV_CBREQD3")
Local lApropInd := CBArmProc(cProd,cTM)
Local lExAcdEnd := ExistBlock("ACD100END")

LocaL cArmOri    
Local cEndOri    
Local cLoteOri   
Local cSLoteOri  
Local cNumSerOri          
Local nSldSepOri

Default cLocPad 	:= Nil
Default lGroupLoc	:= .F.
Default cArmPA		:= Nil

If aVarAlt<>NIL
	cArmOri    := IIF(aVarAlt[1]<>Nil, aVarAlt[1], Space(Len(CB8->CB8_LOCAL)))
	cEndOri    := IIF(aVarAlt[2]<>Nil, aVarAlt[2], Space(Len(CB8->CB8_LCALIZ)))
	cLoteOri   := IIF(aVarAlt[3]<>Nil, aVarAlt[3], Space(Len(CB8->CB8_LOTECT)))
	cSLoteOri  := IIF(aVarAlt[4]<>Nil, aVarAlt[4], Space(Len(CB8->CB8_NUMLOT)))
	cNumSerOri := IIF(aVarAlt[5]<>Nil, aVarAlt[5], Space(Len(CB8->CB8_NUMSER)))
	nSldSepOri := IIF(aVarAlt[6]<>Nil, aVarAlt[6], 0)
EndIf

lQuery    :=.T.
cQuerySBF := "SELECT SBF.* "
cQuerySBF += " FROM " + RetSqlName("SBF") +" SBF "
cQuerySBF += " 		INNER JOIN " + RetSqlName( "NNR" ) +" NNR ON ( BF_FILIAL = '"+ FWxFilial( 'SBF' ) +"' AND NNR_FILIAL = '"+ FWxFilial( 'NNR' ) +"' AND BF_LOCAL = NNR_CODIGO ) "

cQuerySBF += " WHERE BF_PRODUTO = '" + cProd + "' AND "

If !( Empty( cLocPad ) ) .And. !( cLocPad == cArmProc ) .And. !( cLocPad == cLocCQ )
	cQuerySBF += " BF_LOCAL = '" + cLocPad + "' AND "
EndIf

cQuerySBF += " BF_FILIAL = '" + xFilial("SBF") + "' AND "
cQuerySBF += " SBF.D_E_L_E_T_ = ' ' AND NNR.D_E_L_E_T_ = ' ' "
cQuerySBF += " ORDER BY BF_PRODUTO,BF_LOCAL,BF_LOTECTL,BF_NUMLOTE"
cQuerySBF := ChangeQuery( cQuerySBF )
TCQUERY cQuerySBF NEW ALIAS "SBFTMP"
dbSelectArea("SBFTMP")
cAliasSBF := "SBFTMP"

While (cAliasSBF)->(!Eof() .AND. BF_FILIAL+BF_PRODUTO == xFilial("SBF")+cProd)
	If ((cAliasSBF)->BF_LOCAL == cArmProc) .or. (aVarAlt<>NIL .and. (cAliasSBF)->BF_LOCAL == cLocCQ)
		(cAliasSBF)->(DbSkip())
		Loop
	Endif

	If lGroupLoc
		If !( AllTrim( (cAliasSBF)->BF_LOCAL ) == cArmPA )
			(cAliasSBF)->( dbSkip() ) ; Loop
		EndIf
	EndIf
	
	If	lExAcdEnd
		lACD100END := ExecBlock("ACD100END",.F.,.F.,{(cAliasSBF)->BF_LOCAL,(cAliasSBF)->BF_LOCALIZ,(cAliasSBF)->BF_PRODUTO,(cAliasSBF)->BF_NUMSERI,(cAliasSBF)->BF_LOTECTL,(cAliasSBF)->BF_NUMLOTE})
		lACD100END := If(ValType(lACD100END)=="L",lACD100END,.T.)
		If !lACD100END
			(cAliasSBF)->(DbSkip())
			Loop
		Endif
	Endif
	If lApropInd
		nSaldoAtu := (cAliasSBF)->(SaldoSBF(BF_LOCAL,BF_LOCALIZ,BF_PRODUTO,BF_NUMSERI,BF_LOTECTL,BF_NUMLOTE))
		nSaldoCB8 := (cAliasSBF)->(RetSldCB8(BF_PRODUTO,BF_LOCAL,BF_LOCALIZ,BF_NUMSERI,BF_LOTECTL,BF_NUMLOTE))
		If (nSaldoAtu-nSaldoCB8) > 0
			nSaldoSBF += (nSaldoAtu-nSaldoCB8)
			aadd(aSaldoSBF,{(cAliasSBF)->BF_PRODUTO,(cAliasSBF)->BF_LOCAL,(cAliasSBF)->BF_LOCALIZ,(cAliasSBF)->BF_LOTECTL,(cAliasSBF)->BF_NUMLOTE,(cAliasSBF)->BF_NUMSERI,(nSaldoAtu-nSaldoCB8)})
		Endif
	Else                                                                                                        
		nSaldoAtu := (cAliasSBF)->(SaldoSBF(BF_LOCAL,BF_LOCALIZ,BF_PRODUTO,BF_NUMSERI,BF_LOTECTL,BF_NUMLOTE))
		If aVarAlt<> NIL .and. (cProd+cArmOri+cEndOri+cLoteOri+cSLoteOri+cNumSerOri) == (cAliasSBF)->(BF_PRODUTO+BF_LOCAL+BF_LOCALIZ+BF_LOTECTL+BF_NUMLOTE+BF_NUMSERI)
			//Se a chave SBF corresponder a chave do CB8, permitir que o usuario possa seleciona-la com o saldo a ser separado:
			nSaldoAtu := nSldSepOri
		Endif                                                                        
		
		If nSaldoAtu > 0
			nSaldoSBF += nSaldoAtu
			aadd(aSaldoSBF,{(cAliasSBF)->BF_PRODUTO,(cAliasSBF)->BF_LOCAL,(cAliasSBF)->BF_LOCALIZ,(cAliasSBF)->BF_LOTECTL,(cAliasSBF)->BF_NUMLOTE,(cAliasSBF)->BF_NUMSERI,nSaldoAtu})
		Endif
	Endif
	(cAliasSBF)->(DbSkip())
Enddo
If lQuery
	(cAliasSBF)->( DbCloseArea() )
Endif
aSort(aSaldoSBF,,,{|x,y| x[01]+x[02]+x[03]+x[04]+x[05]+x[06]<y[01]+y[02]+y[03]+y[04]+y[05]+y[06]})

RestArea(aAreaSBF)
RestArea(aArea)
Return If(lRetSaldo,nSaldoSBF,aSaldoSBF)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ RetSldCB8 ³ Autor ³ Microsiga             ³ Data ³ 13/05/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os saldos que ainda nao foram separados nas OS      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RetSldCB8(cProd,cLocal,cLocaliz,cNumSerie,cLote,cSubLote)
Local aArea     := GetArea()
Local aAreaCB7  := CB7->(GetArea())
Local nSaldoCB8 := 0

cQueryCB8 := "SELECT SUM(CB8_SALDOS) AS SALDOSEP FROM " + RetSqlName("CB7") + " CB7, " + RetSqlName("CB8") + " CB8"
cQueryCB8 += " WHERE CB7.CB7_ORDSEP = CB8.CB8_ORDSEP AND CB7.CB7_OP <> '' AND CB7.CB7_REQOP <> '1' AND"
cQueryCB8 += " CB8.CB8_LOCAL = '" + cLocal + "' AND CB8.CB8_LCALIZ = '" + cLocaliz + "' AND"
cQueryCB8 += " CB8.CB8_NUMSER = '" + cNumSerie + "' AND CB8.CB8_LOTECT = '" + cLote + "' AND CB8.CB8_NUMLOT = '" + cSubLote + "' AND"
cQueryCB8 += " CB8.CB8_PROD = '" + cProd + "' AND CB8.CB8_SALDOS > 0 AND"
cQueryCB8 += " CB7.CB7_FILIAL = '" + xFilial("CB7") + "' AND CB8.CB8_FILIAL = '" + xFilial("CB8") + "' AND "
cQueryCB8 += " CB7.D_E_L_E_T_ = ' ' AND CB8.D_E_L_E_T_ = ' '"
cQueryCB8 := ChangeQuery( cQueryCB8 )
TCQUERY cQueryCB8 NEW ALIAS "CB8TMP"
dbSelectArea("CB8TMP")
CB8TMP->(DbGoTop())
If CB8TMP->(!Eof())
	nSaldoCB8 := CB8TMP->SALDOSEP
Endif
CB8TMP->( DbCloseArea() )

RestArea(aAreaCB7)
RestArea(aArea)
Return nSaldoCB8


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ SemSldOS  ³ Autor ³ Microsiga             ³ Data ³ 20/05/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Analisa se os produtos empenhados possuem saldo suficiente  ³±±
±±³          ³ para a separacao (considera a estrutura)                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function SemSldOS()
Local nUnPA := 0
Local nX

//aEmp:
// [01] - OP
// [02] - Produto
// [03] - Quantidade
// [04] - Saldo em Estoque
// [05] - Quantidade na estrutura
// [06] - Quantidade disponivel para a producao de um PA
// [07] - Nova quantidade a ser definida para a meteria-prima (com base na estrutura)

SG1->(DbSetOrder(1))
//Calcula quantos produtos acabados podem ser gerados com as materias-primas empenhadas:
For nX:=1 to Len(aEmp)
	If SG1->(DbSeek(xFilial("SG1")+SC2->C2_PRODUTO+aEmp[nX,02]))
		aEmp[nX,05] := SG1->G1_QUANT
		If aEmp[nX,04] >= aEmp[nX,03]  //Se tem saldo suficiente para atender a quantidade da OP:
			aEmp[nX,06] := SC2->C2_QUANT-(SC2->C2_QUJE+SC2->C2_PERDA)
		Else  //Se saldo insuficiente, encontrar o coeficiente para producao de um PA
			aEmp[nX,06] := (aEmp[nX,04]/SG1->G1_QUANT)
			If aEmp[nX,06] == 0
				aEmp[nX,06] := 0.1 //Se zero, novo valor deve ter residuo para processar abaixo
			Endif
		Endif
	Endif
Next
aSort(aEmp,,,{|x,y| x[06]<y[06]})

//Verifico qual a menor unidade para producao de um produto acabado:
//(descartando as materias-primas que nao fazem parte da estrutura e foram incluidas manualmente):
For nX:=1 to Len(aEmp)
	If !Empty(aEmp[nX,06])
		nUnPA := Int(aEmp[nX,06])
		Exit
	Endif
Next

If nUnPA <= 0
	Return .t.
Endif

//Refaco a quantidade de materias-primas necessarias com base no coeficiente encontrado para producao do PA:
For nX:=1 to Len(aEmp)
	If !Empty(aEmp[nX,05])  //Se empenho nao incluido manualmente
		aEmp[nX,07] := aEmp[nX,05] * nUnPA
	Else
		aEmp[nX,07] := aEmp[nX,03]
	Endif
Next

Return .f.


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ RetEmpOS  ³ Autor ³ Microsiga             ³ Data ³ 20/05/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a quantidade do produto a ser separada na Ordem de  ³±±
±±³          ³ Separacao                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RetEmpOS(lConsEst,cProdEmp,nQtdEmp)
Local nPos

If !lConsEst
	Return nQtdEmp
Endif

nPos := Ascan(aEmp,{|x| x[02] == cProdEmp})

Return aEmp[nPos,07]


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AltEmp     ³ Autor ³ Totvs                 ³ Data ³ 20/05/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina de alteracao dos produtos da Ordem Separacao onde     ³±±
±±³          ³ refaz os empenhos                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AltEmp(aHeaderEmp,aColsEmp)
Local nOpcao   := 0
Local cPictCB8 := PesqPict('CB8','CB8_SALDOS')
Local oDlgEmp 
Local oNewGetDados
Local cProdAtu
Local oDescPrd
Local cDescPrd
Local oArmOri
LocaL cArmOri
Local oEndOri
Local cEndOri
Local oLoteOri
Local cLoteOri
Local oSLoteOri
Local cSLoteOri
Local oNumSerOri
Local cNumSerOri
Local oQtdOri
Local nQtdOri
Local oQtdSep
Local lJaSeparou

// variaveis Private, necessario dependencia dentro da GetDados.
Private aHeaderAtu := aClone(aHeaderEmp)
Private aColsAtu   := aClone(aColsEmp)
Private nAtaCols	 := n 
Private aHeadForm  := {}
Private aColsForm  := {}
Private aHeader    := {}
Private aCols      := {}
Private cLoteSug   := Space(TamSx3("CB8_LOTECT")[1])
Private cSLoteSug  := Space(TamSx3("CB8_NUMLOT")[1])
Private nQtdSug    := 0
Private cLocSug    := Space(TamSx3("CB8_LOCAL")[1])
Private cEndSug    := Space(TamSx3("CB8_LOCAL")[1])
Private cNumSerSug := Space(TamSx3("CB8_NUMSER")[1])
Private oQtdSldInf
Private nQtdSldInf := IIF(nOSOpc==1, GDFGet2("CB8_XSALDO"), GDFGet2("CB8_SALDOS"))
Private nQtdSep

dbSelectArea("SC6")
SC6->(dbSetOrder(1)) //-- C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
If SC6->(dbSeek(xFilial("SC6") + GDFGet2("CB8_PEDIDO") + GDFGet2("CB8_ITEM") + GDFGet2("CB8_PROD"))) .And. !Empty(SC6->C6_LOTECTL)
	FWAlertHelp("<font color='red'>Atenção não será permitido a alteração do lote para esse item do pedido.</font>" + Chr(10) + Chr(10) +;
				"<font color='red'>Lote <strong>" + AllTrim(SC6->C6_LOTECTL) + "</strong> preenchido no pedido de venda pelo vendedor</font>", "Entre em contato com o Vendedor/Cliente para alteração de Lote.")
	
	If FWAlertNoYes("Deseja informar o CS que este lote [" + AllTrim(SC6->C6_LOTECTL) + "] não foi localizado?", "Informar CS")
		SetTraking("1", SC6->(C6_FILIAL + C6_NUM), SC6->C6_ITEM, "Lote", "Lote não localizado: " + AllTrim(SC6->C6_LOTECTL), "Validação Fisica (Lote não localizado)")
	EndIf
	
	aHeader := aClone(aHeaderAtu)
	aCols   := aClone(aColsAtu)
	Return
Endif

cProdAtu   := GDFGet2("CB8_PROD")
cArmOri    := GDFGet2("CB8_LOCAL")
cEndOri    := GDFGet2("CB8_LCALIZ")
cLoteOri   := GDFGet2("CB8_LOTECT")
cSLoteOri  := GDFGet2("CB8_NUMLOT")
cNumSerOri := GDFGet2("CB8_NUMSER")
nQtdOri    := IIF(nOSOpc==1, GDFGet2("CB8_XQTDOR"), GDFGet2("CB8_QTDORI"))
nQtdSep    := IIF(nOSOpc==1, GDFGet2("CB8_XQTDOR")-GDFGet2("CB8_XSALDO"), GDFGet2("CB8_QTDORI")-GDFGet2("CB8_SALDOS"))
lJaSeparou := nQtdSep > 0

If GdDeleted(nAtaCols,aHeaderEmp,aColsEmp)
	Alert("Nao e permitida a alteracao de empenhos de itens deletados!") //"Nao e permitida a alteracao de empenhos de itens deletados!"
	aHeader := aClone(aHeaderAtu)
	aCols   := aClone(aColsAtu)
	Return
Endif

If !Localiza(cProdAtu)
	Alert("So e permitida a alteracao de empenhos da Ordem de Separacao quando o produto controlar enderecamento!") //"So e permitida a alteracao de empenhos da Ordem de Separacao quando o produto controlar enderecamento!"
	aHeader := aClone(aHeaderAtu)
	aCols   := aClone(aColsAtu)
	Return
Endif

If nQtdOri == nQtdSep
	Alert("O produto "+AllTrim(cProdAtu)+" ja foi totalmente separado!") //"O produto "###" ja foi totalmente separado!"
	aHeader := aClone(aHeaderAtu)
	aCols   := aClone(aColsAtu)
	Return
Endif

SB1->(DbSetOrder(1))
SB1->(DbSeek(xFilial("SB1")+cProdAtu))
cDescPrd  := AllTrim(cProdAtu)+" - "+AllTrim(SB1->B1_DESC)

aHeadForm := RetHeaderForm()
aColsForm := RetColsForm()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa tecla F4 para comunicacao com Saldos Empenhados        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetKey( VK_F4, {|| ShowF4()} )

DEFINE MSDIALOG oDlgEmp TITLE "Substituicao de Empenhos - <F4 - Consulta Empenhos>" From 50,50 to 450,855 PIXEL //"Substituicao de Empenhos - <F4 - Consulta Empenhos>"
	@ 15,05 TO 65,400 LABEL "" OF oDlgEmp PIXEL
	@ 47,05 TO 05,400 LABEL "" OF oDlgEmp PIXEL
	@ 22,010 SAY "Produto:" SIZE 200,8 OF oDlgEmp PIXEL //"Produto:"
	@ 34,010 SAY "Local:" SIZE 20,8 OF oDlgEmp PIXEL //"Local:"
	@ 34,055 SAY "Endereco:" SIZE 25,8 OF oDlgEmp PIXEL //"Endereco:"
	@ 34,155 SAY "Lote:" SIZE 200,8 OF oDlgEmp PIXEL //"Lote:"
	@ 34,225 SAY "Sublote:" SIZE 20,8 OF oDlgEmp PIXEL //"Sublote:"
	@ 34,292 SAY "Num.Serie:" SIZE 40,8 OF oDlgEmp PIXEL //"Num.Serie:"
	
	@ 52,010 SAY "Quantidade Original:" SIZE 150,8 OF oDlgEmp PIXEL //"Quantidade Original:"
	@ 52,160 SAY IIF(nOSOpc==1, "Saldo Validado:", "Saldo Separado:") SIZE 150,8 OF oDlgEmp PIXEL //"Saldo Separado:"
	@ 52,300 SAY "Saldo a Informar:" SIZE 150,8 OF oDlgEmp PIXEL //"Saldo a Informar:"
	
	@ 21,032 MSGET oDescPrd VAR cDescPrd PICTURE "@!" SIZE 222,06 WHEN .F. OF oDlgEmp PIXEL
	@ 33,032 MSGET oArmOri VAR cArmOri PICTURE "@!" SIZE 15,06 WHEN .F. OF oDlgEmp PIXEL
	@ 33,085 MSGET oEndOri VAR cEndOri PICTURE "@!" SIZE 60,06 WHEN .F. OF oDlgEmp PIXEL
	@ 33,175 MSGET oLoteOri VAR cLoteOri PICTURE "@!" SIZE 38,06 WHEN .F. OF oDlgEmp PIXEL
	@ 33,250 MSGET oSLoteOri VAR cSLoteOri PICTURE "@!" SIZE 30,06 WHEN .F. OF oDlgEmp PIXEL
	@ 33,325 MSGET oNumSerOri VAR cNumSerOri PICTURE "@!" SIZE 70,06 WHEN .F. OF oDlgEmp PIXEL
	@ 51,062 MSGET oQtdOri VAR nQtdOri PICTURE cPictCB8 SIZE 50,06 WHEN .F. OF oDlgEmp PIXEL
	@ 51,203 MSGET oQtdSep VAR nQtdSep PICTURE cPictCB8 SIZE 50,06 WHEN .F. OF oDlgEmp PIXEL
	@ 51,345 MSGET oQtdSldInf VAR nQtdSldInf PICTURE cPictCB8 SIZE 50,06 WHEN .F. OF oDlgEmp PIXEL
	AtuSldInf(.f.,nQtdOri)
	oNewGetDados := MsNewGetDados():New(025,005,160,280,GD_INSERT+GD_UPDATE+GD_DELETE,"U_A100LLOK()",,/*inicpos*/,,/*freeze*/,50,/*fieldok*/,/*superdel*/,/*delok*/,oDlgEmp,aHeadForm,aColsForm)
	oNewGetDados:oBrowse:bDelete := {|| VldLinDel(oNewGetDados:aCols,oNewGetDados:nAt,oNewGetDados,nQtdSep,nQtdOri) }
	oNewGetDados:oBrowse:Align := CONTROL_ALIGN_BOTTOM
ACTIVATE DIALOG oDlgEmp ON INIT EnchoiceBar(oDlgEmp,{||(nOpcao:=VldItens(),If(nOpcao==1,oDlgEmp:End(),0))},{||oDlgEmp:End()}) CENTERED

If nOpcao == 1
	Begin Transaction
		AtuNovosEmp(aHeaderEmp,aColsEmp,nAtaCols)
	End Transaction
Else
	aHeader := aClone(aHeaderAtu)
	aCols   := aClone(aColsAtu)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desativa tecla F4 para comunicacao com Saldos Empenhados     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SET KEY VK_F4 TO
Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RetHeaderForm ºAutor  ³       Totvs          º Data ³  28/04/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Carrega o Header dos formularios								   			º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RetHeaderForm()
Local aHeaderTMP := {}

AADD(aHeaderTMP,{ "Local"		,"cLocSug" 		,"@!"						,02,0,,,"C","","","",,".F."}) //"Local"
AADD(aHeaderTMP,{ "Endereco"		,"cEndSug" 		,"@!"						,15,0,,,"C","","","",,".F."}) //"Endereco"
AADD(aHeaderTMP,{ "Quantidade"		,"nQtdSug" 		,PesqPict('CB8','CB8_SALDOS'),12,2,"U_A100VQt(,.t.)",,"N","","","",0,".T."}) //"Quantidade"
AADD(aHeaderTMP,{ "Lote"		,"cLoteSug"		,"@!"    				,10,0,,,"C","","","",,".F."})// "Lote"	
AADD(aHeaderTMP,{ "SubLote"		,"cSLoteSug"		,"@!"    				,06,0,,,"C","","","","",".F."})//"SubLote"
AADD(aHeaderTMP,{ "Numero de Serie"		,"cNumSerSug"		,"@!"						,20,0,,,"C","","","",,".F."})//"   Numero de Serie "  

Return aClone( aHeaderTMP )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RetColsForm   ºAutor  ³       Totvs          º Data ³  28/04/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Carrega o aCols dos formularios								    		   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RetColsForm()

Local cArmOri   := GDFGet2("CB8_LOCAL")
Local cEndOri   := GDFGet2("CB8_LCALIZ")
Local cLoteOri  := GDFGet2("CB8_LOTECT")
Local cSLoteOri := GDFGet2("CB8_NUMLOT")
Local cNumSerOri:= GDFGet2("CB8_NUMSER")
Local nQtdSep   := IIF(nOSOpc==1, GDFGet2("CB8_XQTDOR")-GDFGet2("CB8_XSALDO"), GDFGet2("CB8_QTDORI")-GDFGet2("CB8_SALDOS"))

Local aColsTMP := {}
Local lJaSeparou := nQtdSep > 0

AADD(aColsTMP,Array(Len(aHeadForm)+1))
aColsTMP[1,1] := cArmOri
aColsTMP[1,2] := cEndOri
If lJaSeparou
	aColsTMP[1,3] := nQtdSep
Else
	aColsTMP[1,3] := nQtdSldInf
Endif
aColsTMP[1,4] := cLoteOri
aColsTMP[1,5] := cSLoteOri
aColsTMP[1,6] := cNumSerOri
aColsTMP[1,7] := .F.

Return aClone( aColsTMP )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ A100VQt       ºAutor  ³       Totvs          º Data ³  20/05/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao da quantidade informada                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function A100VQt(nQtde,lAtualiza)

Local cProduto  := GDFGet2("CB8_PROD")
Local cArmOri   := GDFGet2("CB8_LOCAL")
Local cEndOri   := GDFGet2("CB8_LCALIZ")
Local cLoteOri  := GDFGet2("CB8_LOTECT")
Local cSLoteOri := GDFGet2("CB8_NUMLOT")
Local cNumSerOri:= GDFGet2("CB8_NUMSER")
Local nQtdSep   := IIF(nOSOpc==1, GDFGet2("CB8_XQTDOR")-GDFGet2("CB8_XSALDO"), GDFGet2("CB8_QTDORI")-GDFGet2("CB8_SALDOS"))
Local nQtdOri   := IIF(nOSOpc==1, GDFGet2("CB8_XQTDOR"), GDFGet2("CB8_QTDORI"))

Local aRetSld   := {}
Local nSldTMP   := 0
Local cChaveAtu := ""
Local nPos
Local nX     
Local lJaSeparou 	:= nQtdSep > 0

If nQtde == NIL 
	If Empty(ReadVar())
		nQtde:= GDFieldGet('nQtdSug',n)
	Else
		nQtde:= M->nQtdSug
	EndIf
EndIf

If Empty(nQtde)
	MsgAlert("Quantidade invalida!!!") //"Quantidade invalida!!!"
	Return .f.
Endif

If lJaSeparou .AND. (n == 1)
	MsgAlert("A linha nao pode ser editada pois ja foi separada!!!") //"A linha nao pode ser editada pois ja foi separada!!!"
	Return .f.
Endif

aRetSld   := RetSldEnd(cProduto,.f.,{cArmOri,cEndOri,cLoteOri,cSLoteOri,cNumSerOri,nQtde})
cChaveAtu := GDFieldGet('cLocSug',n)+GDFieldGet('cEndSug',n)+GDFieldGet('cLoteSug',n)+GDFieldGet('cSLoteSug',n)+GDFieldGet('cNumSerSug',n)
nPos := Ascan(aRetSld,{|x| x[02]+x[03]+x[04]+x[05]+x[06] == cChaveAtu})
If nPos == 0
	MsgAlert("Saldo indisponivel!!!") //"Saldo indisponivel!!!"
	Return .f.
Endif

For nX:=1 to Len(aColsForm)
	If (nX <> n) .AND. (aColsForm[nX,01]+aColsForm[nX,02]+aColsForm[nX,04]+aColsForm[nX,05]+aColsForm[nX,06]==cChaveAtu) .AND. !aColsForm[nX,07]
		MsgAlert("A chave: Local+Endereco+Lote+Sublote+Num.Serie ja foi informada em outra linha!!!") //"A chave: Local+Endereco+Lote+Sublote+Num.Serie ja foi informada em outra linha!!!"
		Return .f.
	Endif
Next

If nQtde > aRetSld[nPos,07]
	MsgAlert("A quantidade digitada e superior ao saldo disponivel!!!") //"A quantidade digitada e superior ao saldo disponivel!!!"
	Return .f.
Endif

For nX:=1 to Len(aColsForm)
	If (nX <> n) .AND. !aColsForm[nX,07]
		nSldTMP += aColsForm[nX,03]
	Endif
Next

If nQtde > (nQtdOri-nSldTMP)
	MsgAlert("A quantidade digitada e superior ao saldo a ser informado!!!") //"A quantidade digitada e superior ao saldo a ser informado!!!"
	Return .f.
Endif

If lAtualiza
	//Atualiza a informacao da array:
	If n > Len(aColsForm)
		aadd(aColsForm,Array(Len(aHeadForm)+1))
		aColsForm[Len(aColsForm),01] := GDFieldGet('cLocSug',n)
		aColsForm[Len(aColsForm),02] := GDFieldGet('cEndSug',n)
		aColsForm[Len(aColsForm),03] := nQtde
		aColsForm[Len(aColsForm),04] := GDFieldGet('cLoteSug',n)
		aColsForm[Len(aColsForm),05] := GDFieldGet('cSLoteSug',n)
		aColsForm[Len(aColsForm),06] := GDFieldGet('cNumSerSug',n)
		aColsForm[Len(aColsForm),07] := .F.
	Else
		aColsForm[n,01] := GDFieldGet('cLocSug',n)
		aColsForm[n,02] := GDFieldGet('cEndSug',n)
		aColsForm[n,03] := nQtde
		aColsForm[n,04] := GDFieldGet('cLoteSug',n)
		aColsForm[n,05] := GDFieldGet('cSLoteSug',n)
		aColsForm[n,06] := GDFieldGet('cNumSerSug',n)
	Endif
Endif
AtuSldInf(.t.,nQtdOri)  //Atualiza o saldo a ser informado

Return .t.


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ A100LLOK   ºAutor  ³       Totvs          º Data ³  28/04/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao da linha                     	    			  	  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function A100LLOK()
Local lJaSeparou := nQtdSep > 0
If aColsForm[n,7]
	Return .t.
Endif

If lJaSeparou .AND. (n == 1)
	Return .t.
Endif


If !U_A100VQt(,.f.)
	Return .f.
Endif

Return .t.


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VldLinDel  ºAutor  ³       Totvs          º Data ³  20/05/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao do DELETE de linhas da tela de selecao de empenhos	º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function VldLinDel(aCols,nPosAtu,oGetDados,nQtdSep,nQtdOri)
Local lJaSeparou := nQtdSep > 0

If !aTail(aCols[nPosAtu])
	If lJaSeparou .AND. (nPosAtu == 1)
		MsgAlert("A linha nao pode ser excluida pois a quantidade ja foi <strong>"+IIF(nOSOpc==1, "validado", "separada")+"</strong>!!!" ) //"A linha nao pode ser excluida pois a quantidade ja foi separada!!!"
		Return .f.
	Endif
	//Nao estava deletado antes...
	aTail(aCols[nPosAtu]) := .t.
	If Len(aCols) == Len(aColsForm)
		aTail(aColsForm[nPosAtu]) := .t.
	EndIf
	AtuSldInf(.t.,nQtdOri)  //Atualiza o saldo a ser informado
Else
	//Estava deletado antes...
	//Verifica se ainda existe saldo a ser informado:
	If aCols[nPosAtu, 3] > nQtdSldInf
		MsgAlert("A quantidade definida para este lote e superior ao saldo a ser informado!!!") //"A quantidade definida para este lote e superior ao saldo a ser informado!!!"
		Return .f.
	Endif
	aTail(aCols[nPosAtu]) := .f.
	If Len(aCols) == Len(aColsForm)
		aTail(aColsForm[nPosAtu]) := .f.
	EndIf
	AtuSldInf(.t.,nQtdOri)  //Atualiza o saldo a ser informado
Endif
oGetDados:Refresh()

Return .F.


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VldItens   ºAutor  ³       Totvs          º Data ³  20/05/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao da confirmacao dos empenhos substituidos  	  			º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function VldItens()

Local cArmOri   := GDFGet2("CB8_LOCAL")
Local cEndOri   := GDFGet2("CB8_LCALIZ")
Local cLoteOri  := GDFGet2("CB8_LOTECT")
Local cSLoteOri := GDFGet2("CB8_NUMLOT")
Local cNumSerOri:= GDFGet2("CB8_NUMSER")

Local nQtdTMP := 0
Local nX 

For nX:=1 to Len(aColsForm)
	If aColsForm[nX,07]
		Loop
	Endif
	nQtdTMP += aColsForm[nX,03]
Next

If nQtdSldInf == 0
	If (Len(aColsForm) == 1) .AND. (aColsForm[1,1] == cArmOri) .AND. (aColsForm[1,2] == cEndOri) .AND. (aColsForm[1,4] == cLoteOri) .AND.;
	  	(aColsForm[1,5] == cSLoteOri) .AND. (aColsForm[1,6] == cNumSerOri)
		Return 1
	Endif
	If !MsgYesNo("Confirma a substituicao dos empenhos?") //"Confirma a substituicao dos empenhos?"
		Return 0
	Endif
	lAlterouEmp := .t.
	Return 1
Endif

If nQtdSldInf != 0 
	MsgAlert("Ainda existe saldo a ser informado. Verifique!!!") //"Ainda existe saldo a ser informado. Verifique!!!"
	Return 0
Endif

Return 1


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AtuSldInf     ºAutor  ³       Totvs          º Data ³  20/05/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza o saldo a ser separado 								   	 		º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AtuSldInf(lAtuTela,nQtdOri)
Local nQtdInfo := 0
Local nX

For nX:=1 to Len(aColsForm)
	If !aColsForm[nX,07]
		nQtdInfo += aColsForm[nX,03]
	Endif
Next
nQtdSldInf :=(nQtdOri-nQtdInfo)
If lAtuTela
	oQtdSldInf:Refresh()
Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ShowF4        ºAutor  ³       Totvs          º Data ³  20/05/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta tela com saldos disponiveis							   	 		º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ShowF4()
Local cProdAtu  := GDFGet2("CB8_PROD")
Local cArmOri   := GDFGet2("CB8_LOCAL")
Local cEndOri   := GDFGet2("CB8_LCALIZ")
Local cLoteOri  := GDFGet2("CB8_LOTECT")
Local cSLoteOri := GDFGet2("CB8_NUMLOT")
Local cNumSerOri:= GDFGet2("CB8_NUMSER")
Local nQtdSep   := IIF(nOSOpc==1, GDFGet2("CB8_XQTDOR")-GDFGet2("CB8_XSALDO"), GDFGet2("CB8_QTDORI")-GDFGet2("CB8_SALDOS"))

Local cCampo   := AllTrim(Upper(ReadVar()))
Local oDlgEnd
Local nOpcEnd  := 0
Local nAtEnd
Local aListAux := {}
Local lJaSeparou := nQtdSep > 0

Private oListEnd
Private aListEnd := {}
Private cVarEnd

If cCampo == "M->NQTDSUG"

	aListAux := RetSldEnd(cProdAtu,.f.,{cArmOri,cEndOri,cLoteOri,cSLoteOri,cNumSerOri,nQtdSldInf})   
	If Empty(aListAux)
		MsgAlert("Produto sem saldo disponivel!!!") //"Produto sem saldo disponivel!!!"
		Return .f.
	Endif
	aEval(aListAux,{|x| aadd(aListEnd,{x[2],x[3],x[7],x[4],x[5],x[6]})})

	DEFINE MSDIALOG oDlgEnd TITLE ":: Saldos disponiveis ::" From 50,50 to 300,390 PIXEL //":: Saldos disponiveis ::"
		@ 00,00 LISTBOX oListEnd VAR cVarEnd Fields HEADER "Local", "Endereco:", "Quantidade","Lote:", "Sublote:", "Num.Serie:" SIZE 50,110 PIXEL of oDlgEnd //'Local', 'Enderecos', 'Quantidades', 'Lotes', 'Sublotes', 'Num.Serie'
		oListEnd:Align := CONTROL_ALIGN_TOP
		oListEnd:SetArray( aListEnd )
		oListEnd:bLine := { || { aListEnd[oListEnd:nAT,1], aListEnd[oListEnd:nAT,2], aListEnd[oListEnd:nAT,3], aListEnd[oListEnd:nAT,4], aListEnd[oListEnd:nAT,5], aListEnd[oListEnd:nAT,6] } }
		oListEnd:Refresh()
		DEFINE SBUTTON FROM 113,115 TYPE 1 ACTION (nOpcEnd:=1,nAtEnd:=oListEnd:nAT,oDlgEnd:End()) ENABLE Of oDlgEnd
		DEFINE SBUTTON FROM 113,143 TYPE 2 ACTION oDlgEnd:End() ENABLE Of oDlgEnd
	ACTIVATE DIALOG oDlgEnd CENTERED
	
	If nOpcEnd == 1

		If lJaSeparou .AND. (n == 1)
			MsgAlert("A linha nao pode ser editada pois ja foi separada!!!") //"A linha nao pode ser editada pois ja foi separada!!!"
			Return .f.
		Endif

		//Atualiza informacoes da variavel de memoria:
		GDFieldPut("cLocSug"		,aListEnd[nAtEnd][01],n)
		GDFieldPut("cEndSug"		,aListEnd[nAtEnd][02],n)
		&(ReadVar()) := If(nQtdSldInf<=aListEnd[nAtEnd][03],nQtdSldInf,aListEnd[nAtEnd][03])
		GDFieldPut("cLoteSug"	,aListEnd[nAtEnd][04],n)
		GDFieldPut("cSLoteSug"	,aListEnd[nAtEnd][05],n)
		GDFieldPut("cNumSerSug"	,aListEnd[nAtEnd][06],n)

	Endif

Endif

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AtuNovosEmp   	 ºAutor  ³       Totvs          º Data ³  20/05/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Grava os novos empenhos                  						   		  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AtuNovosEmp(aHeaderEmp,aColsEmp,nAtaCols)
Local nPosPROD   := Ascan(aHeaderEmp,{|x| UPPER(AllTrim(x[2]))=="CB8_PROD" })
Local nPosLOCAL  := Ascan(aHeaderEmp,{|x| UPPER(AllTrim(x[2]))=="CB8_LOCAL" })
Local nPosLCALIZ := Ascan(aHeaderEmp,{|x| UPPER(AllTrim(x[2]))=="CB8_LCALIZ" })
Local nPosQTDORI := Ascan(aHeaderEmp,{|x| UPPER(AllTrim(x[2]))=="CB8_QTDORI" })
Local nPosSALDOS := Ascan(aHeaderEmp,{|x| UPPER(AllTrim(x[2]))=="CB8_SALDOS" })
Local nPosSALDOE := Ascan(aHeaderEmp,{|x| UPPER(AllTrim(x[2]))=="CB8_SALDOE" })
Local nPosLOTECT := Ascan(aHeaderEmp,{|x| UPPER(AllTrim(x[2]))=="CB8_LOTECT" })
Local nPosNUMLOT := Ascan(aHeaderEmp,{|x| UPPER(AllTrim(x[2]))=="CB8_NUMLOT" })
Local nPosNUMSER := Ascan(aHeaderEmp,{|x| UPPER(AllTrim(x[2]))=="CB8_NUMSER" })
Local nPosQTDORV := Ascan(aHeaderEmp,{|x| UPPER(AllTrim(x[2]))=="CB8_XQTDOR" })
Local nPosSALDOV := Ascan(aHeaderEmp,{|x| UPPER(AllTrim(x[2]))=="CB8_XSALDO" })

Local nQtdSep    := IIF(nOSOpc==1, aColsEmp[nAtaCols,nPosQTDORV]-aColsEmp[nAtaCols,nPosSALDOV], aColsEmp[nAtaCols,nPosQTDORI]-aColsEmp[nAtaCols,nPosSALDOS])
Local lJaSeparou := nQtdSep > 0

Local cTipExp    := CB7->CB7_TIPEXP
Local aColsLinha
Local nLen                  
Local nX

//Atualiza as arrays de controle do MSGetDados:
aHeader    := aClone(aHeaderEmp)
aCols      := {}
aColsLinha := aClone(aColsEmp[nAtaCols])

If lJaSeparou
	If nOSOpc == 1
		aColsEmp[nAtaCols,nPosQTDORV] := nQtdSep
		aColsEmp[nAtaCols,nPosSALDOV] := 0

		aColsEmp[nAtaCols,nPosQTDORI] := nQtdSep
		aColsEmp[nAtaCols,nPosSALDOS] := nQtdSep
		aColsEmp[nAtaCols,nPosSALDOE] := 0
	Else
		aColsEmp[nAtaCols,nPosQTDORI] := nQtdSep
		aColsEmp[nAtaCols,nPosSALDOS] := 0
		aColsEmp[nAtaCols,nPosSALDOE] := 0
	EndIf
Else
	aDel(aColsEmp,nAtaCols)
	aSize(aColsEmp,Len(aColsEmp)-1)	
Endif

//Inclui os itens sugeridos:
For nX:=1 to Len(aColsForm)
	If aColsForm[nX,07] .OR. (lJaSeparou .AND. nX == 1)
		Loop
	Endif
	aadd(aColsEmp,aClone(aColsLinha))
	nLen:= len(aColsEmp)
	aColsEmp[nLen,nPosLOCAL]  := aColsForm[nX,01]
	aColsEmp[nLen,nPosLCALIZ] := aColsForm[nX,02]
	If nOSOpc == 1
		aColsEmp[nLen,nPosQTDORV] := aColsForm[nX,03]
		aColsEmp[nLen,nPosSALDOV] := aColsForm[nX,03]
	EndIf
	aColsEmp[nLen,nPosQTDORI] := aColsForm[nX,03]
	aColsEmp[nLen,nPosSALDOS] := aColsForm[nX,03]
	If !("09*" $ cTipExp) .AND. ("02*" $ cTipExp)
		aColsEmp[nLen,nPosSALDOE] := aColsForm[nX,03]
	Else
		aColsEmp[nLen,nPosSALDOE] := 0
	Endif
	aColsEmp[nLen,nPosLOTECT] := aColsForm[nX,04]
	aColsEmp[nLen,nPosNUMLOT] := aColsForm[nX,05]
	aColsEmp[nLen,nPosNUMSER] := aColsForm[nX,06]
Next
aSort(aColsEmp,,,{|x,y| x[nPosPROD]+x[nPosLOCAL]+x[nPosLCALIZ]+x[nPosLOTECT]+x[nPosNUMLOT]+x[nPosNUMSER] < ;
                         y[nPosPROD]+y[nPosLOCAL]+y[nPosLCALIZ]+y[nPosLOTECT]+y[nPosNUMLOT]+y[nPosNUMSER] })

aCols :=aClone(aColsEmp)

//Atualiza o getdados:
n:=1
oGet:Refresh()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GravaCB8        ºAutor  ³       Totvs          º Data ³  20/05/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gravacao dos registros no CB8                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GravaCB8()
Local nX
Local nJ
                 
CB8->(DBSetOrder(1))      
While CB8->(DbSeek(xFilial('CB8')+CB7->CB7_ORDSEP))
	CB8->(RecLock("CB8",.F.))
	CB8->(dbDelete())
	CB8->(MsUnLock())
End
For nX:=1 to Len(aCols)
	If GdDeleted(nX,aHeader,aCols)
		Loop
	EndIf
	++nItensCB8
	CB8->(RecLock("CB8",.T.))
	CB8->CB8_FILIAL := xFilial("CB8")
	CB8->CB8_ORDSEP := CB7->CB7_ORDSEP
	For nJ := 1 to len(aHeader)
		If aHeader[nJ,10] == "V"
			Loop
		EndIf
		CB8->&(AllTrim(aHeader[nJ,2])) := aCols[nX,nJ]
	Next
	If !Empty(CB8->CB8_OCOSEP) .and. (CB8->CB8_SALDOS-CB8->CB8_QTECAN) > 0
		lDiverg := .t.
	Endif
	CB8->(MsUnlock())
Next

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcAtuEmp³ Autor ³         Totvs         ³ Data ³ 20/05/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina de empenho/estorno empenho sobre PV/OP              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void ProcAtuEmp(aItensEmp,lEstorno)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aItensEmp = Array contendo os empenhos                     ³±±
±±³          ³ lEstorno  = Indica se empenho/estorno empenho              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ProcAtuEmp(aItensEmp,lEstorno,aDadosSD4)

// Parametros para a chamada da Funcao GravaEmp
Local cOrigem     	:= If(CB7->CB7_ORIGEM=="1","SC6","SC2")	// Indica a Origem do Empenho (SC6,SD3...)
Local cOpOrig		:= ""									// OP Original
Local dEntrega		:= cTod("//")							// Data de Entrega do Empenho
Local aTravas		:= {}									// Array para Travamento dos Saldos, Se = {}, nao ha travamento
Local lProj			:= .F.									// Informa se e chamada da Projecao de Estoque
Local lEmpSB2		:= .T.									// Indica se Empenha Material no SB2
Local lGravaSD4   	:= (CB7->CB7_ORIGEM=="3")				// Indica se grava registro no SD4
Local lConsVenc		:= .T.									// Indica se considera lote vencido
Local lEmpSB8SBF	:= .T.									// Indica se Empenha Material em SB8/SBF
Local lCriaSDC		:= .T.									// Indica se cria Registro no SDC
Local lEncerrOp		:= .F.									// Indica se Encerra Empenho de OP
Local cIdDCF		:= ""									// Identificador do DFC

Local cProduto 		:= ""									// Produto
Local cLocal		:= ""									// Armazem
Local nQtd			:= 0									// Quantidade Empenhada
Local nQtd2UM		:= 0									// Quantidade Empenhada na Segunda Unidade de Medida
Local cLote			:= ""									// Lote
Local cNumLote		:= ""									// Sub-Lote
Local cOp			:= CB7->CB7_OP							// Codigo da OP
Local cTrt			:= ""									// Sequencia do Empenho / Liberacao do Pedido de Vendas
Local cPedido		:= ""									// Pedido de vendas
Local cItem			:= ""									// Item do Pedido de Vendas

Local msg1			:= If(lEstorno,"   [Exclusao]","   [Inclusao]")			//"   [Exclusao]"###"   [Inclusao]"
Local msg2			:= If(lEstorno,"   Exclusao do Empenho OK","   Inclusao do Empenho OK")			//"   Exclusao do Empenho OK"###"   Inclusao do Empenho OK"
Local nX			:= 0
Local nPosProd		:= 0
Local aEmp			:= {}
Local aAreaAnt		:= GetArea()

Default aDadosSD4	:= {}

For nX:= 1 to len(aItensEmp)

	cProduto 	:=GDFieldGet("CB8_PROD"		,nX,,,aItensEmp)
	cItem		:=GDFieldGet("CB8_ITEM"		,nX,,,aItensEmp)
	cLocal		:=GDFieldGet("CB8_LOCAL"	,nX,,,aItensEmp)
	cLote		:=GDFieldGet("CB8_LOTECT"	,nX,,,aItensEmp)
	cNumLote	:=GDFieldGet("CB8_NUMLOT"	,nX,,,aItensEmp) 
	cLocaliz 	:=GDFieldGet("CB8_LCALIZ"	,nX,,,aItensEmp) 
	cNumSer  	:=GDFieldGet("CB8_NUMSER"	,nX,,,aItensEmp) 
	nQtd		:=GDFieldGet("CB8_QTDORI"	,nX,,,aItensEmp)
	cTrt		:=GDFieldGet("CB8_SEQUEN"	,nX,,,aItensEmp) 
	cPedido		:=GDFieldGet("CB8_PEDIDO"	,nX,,,aItensEmp) 
	 
	nQtd2UM  	:=ConvUm(cProduto,nQtd,nQtd2UM,2)
				  	
   If ascan(aEmp,{|x| x[1]+x[2]+x[3]+x[4]+x[5] == cProduto+cItem+cLocal+cLote+cNumLote+cNumSer}) == 0
		aadd(aEmp,{cProduto,cItem,cLocal,cLote,cNumLote,cPedido,nQtd,nQtd2UM,cLocaliz,cNumSer,cTrt})
   Endif
    	   
Next nX	

For nX:=1 to Len(aEmp)

	AutoGrLog(msg1)
	AutoGrLog("   Produto...: "+aEmp[nX,1])  //"   Produto...: "
	AutoGrLog("   Item......: "+aEmp[nX,2]) //"   Item......: "
	AutoGrLog("   Quantidade: "+Alltrim(Str(aEmp[nX,7]))) //"   Quantidade: "
	AutoGrLog("   Armazem...: "+aEmp[nX,3]) //"   Armazem...: "
	AutoGrLog("   Lote......: "+aEmp[nX,4]) //"   Lote......: "
		AutoGrLog("Endereco:"+aEmp[nX,9]) //"   Endereco: "
	AutoGrLog("   Num.Serie.: "+aEmp[nX,10]) //"   Num.Serie.: "
	If !Empty(cPedido)
		AutoGrLog("   Pedido....: "+cPedido	) //"   Pedido....: "
	Else
		AutoGrLog("   Op........: "+cOp	) //"   Op........: "
	Endif
	
	// Refaz empenhos para a OP
	If !Empty(cOp) .And. Empty(cPedido)

		If lEstorno
			SD4->(DbSetOrder(2))
			If SD4->(DbSeek(xFilial("SD4") + cOp + aEmp[nX,1] + aEmp[nX,3]))

				// Armazena dados do empenho antigo para serem replicados no empenho novo
				aAdd(aDadosSD4, {cOp, aEmp[nX,1], aEmp[nX,3], SD4->D4_TRT, SD4->D4_DATA})

				RecLock("SD4",.F.)
				DbDelete()
				MsUnLock()
			EndIf
		EndIf

		If (nPosProd := aScan(aDadosSD4,{|x| x[1]==cOp .And. x[2]==aEmp[nX,1] .And. x[3] == aEmp[nX,3]})) > 0
			cTrt     := aDadosSD4[nPosProd][4]
			dEntrega := aDadosSD4[nPosProd][5]
		EndIf

		GravaEmp(aEmp[nX,1],aEmp[nX,3],aEmp[nX,7],nQtd2UM,aEmp[nX,4],aEmp[nX,5],aEmp[nX,9],aEmp[nX,10],cOp,cTrt,cPedido,aEmp[nX,2],cOrigem,cOpOrig,dEntrega,aTravas,lEstorno,lProj,lEmpSB2,lGravaSD4,lConsVenc,lEmpSB8SBF,lCriaSDC,lEncerrOp,cIdDCF)

	EndIf				
	AutoGrLog(msg2)
	AutoGrLog("   ")
			
Next nX

RestArea(aAreaAnt)

Return .t. 


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LimpaInfoOS     ºAutor  ³       Totvs          º Data ³  21/05/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Limpa as informacoes dos campos padroes relacionado a OS em questao º±±
±±º          ³ quando item deletado                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LimpaInfoOS()
Local	nPosPed    := Ascan(aHeader,{|x| UPPER(AllTrim(x[2]))=="CB8_PEDIDO" })
Local	nPosItPed  := Ascan(aHeader,{|x| UPPER(AllTrim(x[2]))=="CB8_ITEM"   })
Local	nPosSeqPed := Ascan(aHeader,{|x| UPPER(AllTrim(x[2]))=="CB8_SEQUEN" })
Local	nPosPrdPed := Ascan(aHeader,{|x| UPPER(AllTrim(x[2]))=="CB8_PROD"   })
Local nPosNSPed  := Ascan(aHeader,{|x| UPPER(AllTrim(x[2]))=="CB8_NUMSER" })
Local	nPosNota   := Ascan(aHeader,{|x| UPPER(AllTrim(x[2]))=="CB8_NOTA"   })
Local	nPosSerie  := Ascan(aHeader,{|x| UPPER(AllTrim(x[2]))=="CB8_SERIE"  })
Local	nPosOP     := Ascan(aHeader,{|x| UPPER(AllTrim(x[2]))=="CB8_OP"     })
Local	nPosDel    := Len(aHeader)+1
Local cPedAtu, cChavePV
Local i, nQ, nItens

For i:=1 to Len(aCols)
	If aCols[i,nPosDel]
		If CB7->CB7_ORIGEM == "1"  //Por pedido
			If Empty(aCols[i,nPosPed])
				Loop
			Endif
			cPedAtu := aCols[i,nPosPed]
			CB8->(DbGoto(aRecno[i]))
			CB8->(RecLock( "CB8",.F.))
			CB8->(dbDelete())
			CB8->(MsUnLock())
			//Verifica se o item possui N.Serie, neste caso, avaliar se existem itens com mesma chave que nao foram excluidos...
			If !Empty(aCols[i,nPosNSPed])
				cChavePV := aCols[i,nPosPed]+aCols[i,nPosItPed]+aCols[i,nPosSeqPed]+aCols[i,nPosPrdPed]
				nItens   := 0
				aEval(aCols,{|x| If(x[nPosPed]+x[nPosItPed]+x[nPosSeqPed]+x[nPosPrdPed]==cChavePV .AND. !x[nPosDel],nItens++,NIL)})
				If nItens > 0
					Loop
				Endif
			Endif
			SC9->(DbSetOrder(1))
			If SC9->( dbSeek( xFilial("SC9")+cPedAtu+aCols[i,nPosItPed]+aCols[i,nPosSeqPed]+aCols[i,nPosPrdPed]	) )
				If ! Empty(SC9->C9_ORDSEP)
					SC9->(RecLock("SC9",.F.))
					SC9->C9_ORDSEP := ""
					SC9->(MsUnlock())
				Endif
			EndIf
		ElseIf CB7->CB7_ORIGEM == "2"  //Por Nota
			If Empty(aCols[i,nPosNota]+aCols[i,nPosSerie])
				Loop
			Endif
			cNotaAtu := aCols[i,nPosNota]
			cSeriAtu := aCols[i,nPosSerie]
			nQ       := 0
			aEval(aCols,{|x| If(x[nPosNota]+x[nPosSerie]==cNotaAtu+cSeriAtu,nQ++,nil)})
			aCols[i,nPosNota]  := ""
			aCols[i,nPosSerie] := ""
			CB8->(DbGoto(aRecno[i]))
			CB8->(RecLock( "CB8",.F.))
			CB8->(dbDelete())
			CB8->(MsUnLock())
			If nQ == 1
				SF2->(DbSetOrder(1))
				If SF2->(DBSeek(xFilial("SF2")+cNotaAtu+cSeriAtu))
					If ! Empty(SF2->F2_ORDSEP)
						SF2->(RecLock("SF2",.F.))
						SF2->F2_ORDSEP := ""
						SF2->(MsUnlock())
					Endif
				Endif
			Endif
		ElseIf CB7->CB7_ORIGEM == "3"  //Por OP
			If Empty(aCols[i,nPosOP])
				Loop
			Endif
			cOPAtu := aCols[i,nPosOP]
			nQ     := 0
			aEval(aCols,{|x| If(x[nPosOP]==cOPAtu,nQ++,nil)})
			aCols[i,nPosOP] := ""
			CB8->(DbGoto(aRecno[i]))
			CB8->(RecLock( "CB8",.F.))
			CB8->(dbDelete())
			CB8->(MsUnLock())
			If nQ == 1
				SC2->(DbSetOrder(1))
				If SC2->(DbSeek(xFilial("SC2")+cOPAtu))
					If ! Empty(SC2->C2_ORDSEP)
						SC2->(RecLock("SC2",.F.))
						SC2->C2_ORDSEP := ""
						SC2->(MsUnlock())
					Endif
				Endif
			Endif
		Endif
	Endif
Next

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AtuCB7          ºAutor  ³       Totvs          º Data ³  21/05/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza as informacoes do Cabecalho da OS                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AtuCB7()
Local nPosSaldoS := Ascan(aHeader,{|x| UPPER(AllTrim(x[2]))=="CB8_SALDOS" })
Local nPosDel    := Len(aHeader)+1
Local lOK        := .t.
Local i

For i:=1 to Len(aCols)
	If !aCols[i,nPosDel] .and. ! Empty(aCols[i,nPosSaldoS]) // Linha nao esta Deletada e o produto tem saldo a separar ...
		lOK:= .f.
		Exit
	Endif
Next

CB7->(RecLock( "CB7", .F. ))
CB7->CB7_CODOPE := M->CB7_CODOPE
CB7->CB7_NUMITE := nItensCB8

If nOSOpc == 1
    CB7->CB7_XDIVER := If(lDiverg,"1"," ")
    If lOK // Nao tem nada pendente para validacao
        CB7->CB7_XSTATP := " "
        CB7->CB7_XSTATU := "9"	// Processo de validacao fisica finalizado
    Endif
Else
    CB7->CB7_DIVERG := If(lDiverg,"1"," ")
    If lOK // Nao tem nada pendente para separacao
        CB7->CB7_STATPA := " "
        CB7->CB7_STATUS := "9"	// Processo de Expedicao ou separacao finalizado
    Endif
EndIf
CB7->(MsUnLock())

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ConsEmb         º Autor ³       Totvs          º Data ³  06/06/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de consulta de embalagens                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ConsEmb()

Local oDlgVol
Local aButtons := {}
Local aSize	   := MsAdvSize()
Local lTemVol  := .f.
Local lImpEtiq := If(("05") $ CB7->CB7_TIPEXP,VldImpEtiq(),.T.)
Local lEncEtap := .T.
Local nI	   := 0
Local oPanEsq
Local oPanDir
Local oPanelCB3
Local oTreeVol
Local oEncCB3
Local oEncCB6
Local oEncCB9
Local lUpdate	:= ( Inclui .Or. Altera )

Private aVolumes := {}
Private aSubVols := {}

CB9->(DbSetOrder(1))
CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP))
While CB9->(!Eof() .AND. CB9_FILIAL+CB9_ORDSEP == xFilial("CB9")+CB7->CB7_ORDSEP)
	If !Empty(CB9->CB9_VOLUME)
		lTemVol  := .t.
		Exit
	Endif
	CB9->(DbSkip())
Enddo
If !lTemVol
	MsgStop("Volumes não encontrados!")//"Volumes não encontrados!"
	Return
Endif

If lImpEtiq
	//Adiciona botao de impressao de etiquetas:
	aAdd(aButtons, {'RPMNEW',{|| ImpEtiqVol(oTreeVol:GetCargo())},"Impr.Etiq.Vol.","Impr.Etiq.Vol."}) //"Impr.Etiq.Vol."###"Impr.Etiq.Vol."
EndIf

DEFINE MSDIALOG oDlgVol TITLE "Consulta de volumes - Ordem de Separação: "+CB7->CB7_ORDSEP FROM aSize[07],0 TO aSize[06],aSize[05] PIXEL //OF oMainWnd PIXEL //"Consulta de volumes - Ordem de Separação: "

	@ 000,000 SCROLLBOX oPanEsq  HORIZONTAL SIZE 200,270 OF oDlgVol BORDER
	oPanEsq:Align := CONTROL_ALIGN_LEFT

	oTreeVol := DbTree():New(0, 0, 0, 0, oPanEsq,,,.T.)
	oTreeVol:bChange    := {|| AtuEncDir(oTreeVol:GetCargo(),oPanelCB3,oEncCB3,oEncCB6,oEncCB9)}
	oTreeVol:blDblClick := {|| AtuEncDir(oTreeVol:GetCargo(),oPanelCB3,oEncCB3,oEncCB6,oEncCB9)}
	oTreeVol:Align      := CONTROL_ALIGN_ALLCLIENT

	@ 000,000 MsPanel oPanDir  Of oDlgVol
	oPanDir:Align := CONTROL_ALIGN_ALLCLIENT
   
	oPanelCB3 := TPanel():New( 028, 072,,oPanDir, , , , , , 200, 80, .F.,.T. )
	oPanelCB3 :Align:= CONTROL_ALIGN_TOP
	oPanelCB3:Hide()
   
	oEncCB3 := MsMGet():New("CB3",1,2,,,,,{015,002,100,100},,,,,,oPanelCB3,,,.F.,nil,,.T.)
	oEncCB3:oBox:Align := CONTROL_ALIGN_ALLCLIENT
	oEncCB3:Hide()

	oEncCB6 := MsMGet():New("CB6",1,2,,,,,{015,002,100,100},,,,,,oPanDir,,,.F.,nil,,.T.)
	oEncCB6:oBox:Align := CONTROL_ALIGN_ALLCLIENT
	oEncCB6:Hide()

	oEncCB9 := MsMGet():New("CB9",1,2,,,,,{015,002,100,100},,,,,,oPanDir,,,.F.,nil,,.T.)
	oEncCB9:oBox:Align := CONTROL_ALIGN_ALLCLIENT
	oEncCB9:Hide()

	AtuTreeVol(oPanelCB3,oTreeVol,oPanelCB3,oEncCB3,oEncCB6,oEncCB9)

ACTIVATE MSDIALOG oDlgVol ON INIT EnchoiceBar(oDlgVol,{||oDlgVol:End()},{||oDlgVol:End()},,aButtons) CENTERED

If lImpEtiq
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o status do expedicao			³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nI := 1 To Len(aVolumes)
		If CB6->(DbSeek(xFilial("CB6")+aVolumes[nI,1])) .And. CB6->CB6_STATUS == "1"
			lEncEtap := .F.	
			Exit
		EndIf
	Next nI
	
	If ( lUpdate )
		CB7->(RecLock('CB7',.F.))
		If lEncEtap
			CB7->CB7_VOLEMI :="1"
			If "05" $ CBUltExp(CB7->CB7_TIPEXP)
				CB7->CB7_STATUS := "9"  // finalizou
			Else
				CB7->CB7_STATUS := "7"  // imprimiu volume
				CB7->CB7_STATPA := "1"  // pausa
			EndIf
		Else  
			If !ISINCALLSTACK('U_VSACDA100')
				CB7->CB7_STATUS := 	CBAntProc(CB7->CB7_TIPEXP,"05*") // estorno 
			EndIf	
		EndIf
		CB7->(MsUnlock())
	EndIf

EndIf

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AtuTreeVol      º Autor ³       Totvs          º Data ³  06/06/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de atualizacao do Tree de consulta de volumes                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AtuTreeVol(oPanelCB3,oTreeVol,oPanelCB3,oEncCB3,oEncCB6,oEncCB9)
Local aAreaCB9 := CB9->(GetArea())
Local cDescItem
Local cSubVolAtu
Local nPosVol
Local lFechaTree
Local nX, nY

aVolumes := {}
CB9->(DbSetOrder(1))
CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP))
While CB9->(!Eof() .AND. CB9_FILIAL+CB9_ORDSEP == xFilial("CB9")+CB7->CB7_ORDSEP)
	If !Empty(CB9->CB9_VOLUME)
		nPosVol   := Ascan(aVolumes,{|x| x[01] == CB9->CB9_VOLUME})
		cDescItem := CB9->CB9_PROD+If(!Empty(CB9->CB9_LOTECT)," - Lote: "+CB9->CB9_LOTECT,"")+If(!Empty(CB9->CB9_NUMLOT)," - SubLote: "+CB9->CB9_NUMLOT,"")+If(!Empty(CB9->CB9_NUMSER)," - Num.Serie: "+CB9->CB9_NUMSER,"")
		If nPosVol == 0
			aadd(aVolumes,{CB9->CB9_VOLUME,{},CB9->CB9_ITESEP})
			nPosVol := Len(aVolumes)
		Endif
		aadd(aVolumes[nPosVol,02],{CB9->CB9_SUBVOL,CB9->CB9_PROD,cDescItem,CB9->CB9_LOTECT,CB9->CB9_NUMLOT,CB9->CB9_NUMSER,StrZero(CB9->(Recno()),10)})
	Endif
	CB9->(DbSkip())
Enddo

//Reorganiza a array de volumes e subvolumes:
aSort(aVolumes,,,{|x,y| x[01]<y[01]})
For nX:=1 to Len(aVolumes)
	aSort(aVolumes[nX,02],,,{|x,y| x[01]+x[04]+x[05]+x[06]<y[01]+y[04]+y[05]+y[06]})
Next

oTreeVol:BeginUpdate()
oTreeVol:Reset()

For nX:=1 to Len(aVolumes)
	oTreeVol:AddTree("Volume: "+aVolumes[nX,01]+Space(70),.F.,cBmp1,cBmp1,,,aVolumes[nX,01]+Space(TamSx3("B1_COD")[1]+20)) //"Volume: "
	cSubVolAtu := ""
	For nY:=1 to Len(aVolumes[nX,02])
		If !Empty(aVolumes[nX,02,nY,01]) .AND. Empty(cSubVolAtu)
			cSubVolAtu := aVolumes[nX,02,nY,01]
		ElseIf !Empty(aVolumes[nX,02,nY,01]) .AND. !Empty(cSubVolAtu) .AND. (cSubVolAtu<>aVolumes[nX,02,nY,01])
			oTreeVol:EndTree()
			cSubVolAtu := aVolumes[nX,02,nY,01]
			lFechaTree := .f.
		Endif
		If Empty(aVolumes[nX,02,nY,01])
			//Adiciona produto no volume:
			oTreeVol:AddTreeItem(aVolumes[nX,02,nY,03],cBmp2,,aVolumes[nX,01]+Space(10)+aVolumes[nX,02,nY,02]+aVolumes[nX,02,nY,07])
		ElseIf !oTreeVol:TreeSeek(AllTrim(aVolumes[nX,01]+aVolumes[nX,02,nY,01]))
			//Adiciona subvolume:
			oTreeVol:AddTree("SubVolume: "+aVolumes[nX,02,nY,01]+Space(60),.F.,cBmp1,cBmp1,,,aVolumes[nX,01]+aVolumes[nX,02,nY,01]+Space(25)) //"SubVolume: "
			lFechaTree := .t.
			//Adiciona produto no subvolume:
			oTreeVol:AddTreeItem(aVolumes[nX,02,nY,03],cBmp2,,aVolumes[nX,01]+aVolumes[nX,02,nY,01]+aVolumes[nX,02,nY,02]+aVolumes[nX,02,nY,07])
		Else
			//Adiciona produto no subvolume:
			oTreeVol:AddTreeItem(aVolumes[nX,02,nY,03],cBmp2,,aVolumes[nX,01]+aVolumes[nX,02,nY,01]+aVolumes[nX,02,nY,02]+aVolumes[nX,02,nY,07])
		Endif
	Next
	If lFechaTree
		oTreeVol:EndTree()
		lFechaTree := .f.
	Endif
	oTreeVol:EndTree()
Next

oTreeVol:EndUpdate()
oTreeVol:Refresh()

AtuEncDir(oTreeVol:GetCargo(),oPanelCB3,oEncCB3,oEncCB6,oEncCB9)  //Atualiza enchoice direita

RestArea(aAreaCB9)
Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AtuEncDir       º Autor ³       Totvs          º Data ³  06/06/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao de atualizacao da enchoice                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AtuEncDir(cCargoAtu,oPanelCB3,oEncCB3,oEncCB6,oEncCB9)
Local nTamVol    := TamSX3("CB9_VOLUME")[01]
Local nTamSubVol := TamSX3("CB9_SUBVOL")[01]
Local cVolume

If Len(AllTrim(cCargoAtu)) == nTamVol .OR. Len(AllTrim(cCargoAtu)) == (nTamVol+nTamSubVol)  //Volume ou Subvolume
	CB6->(DbSetOrder(1))
	cVolume := If(Len(AllTrim(cCargoAtu))==nTamVol,AllTrim(cCargoAtu),SubStr(cCargoAtu,nTamVol+1,nTamSubVol))
	CB6->(DbSeek(xFilial("CB6")+cVolume))
	CB3->(DbSetOrder(1))
	CB3->(DbSeek(xFilial("CB3")+CB6->CB6_TIPVOL))
	oEncCB9:Hide()
	oEncCB3:Refresh()
	oEncCB6:Refresh()
	oPanelCB3:Show()
	oEncCB3:Show()
	oEncCB6:Show()
Else
 	CB9->(Dbgoto(Val(Right(cCargoAtu,10))))
	oEncCB3:Hide()
	oEncCB6:Hide()
	oPanelCB3:Hide()
	oEncCB9:Refresh()
	oEncCB9:Show()
Endif

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ImpEtiqVol      º Autor ³       Totvs          º Data ³  08/06/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de impressao de etiquetas de identificacao de volumes        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ImpEtiqVol(cCargoAtu)
Local nTamVol    := TamSX3("CB9_VOLUME")[01]
Local nTamSubVol := TamSX3("CB9_SUBVOL")[01]
Local aRet       := {}
Local aParamBox  := {}
Local aAreaCB6	 := {}
Local cIDVol     := ""
Local cVolume    := ""
Local cSubVol    := ""
Local nVolAtu    := 1
Local nTotVol    := Len(aVolumes)
Local nPosParam  := 1
Local nTpEtqVol  := 1
Local nAtuStaCB7 := 1
Local lEtqOfi    := ("05" $ CB7->CB7_TIPEXP)
Local lImpVol    := .T.

If !Empty(SubStr(cCargoAtu,nTamVol+1,nTamSubVol))
	cVolume := Left(cCargoAtu,nTamVol)
	cSubVol := SubStr(cCargoAtu,nTamVol+1,nTamSubVol)
	cIDVol  := cSubVol
Else
	cVolume := Left(cCargoAtu,nTamVol)
	cIDVol  := cVolume
Endif
nVolAtu    := Ascan(aVolumes,{|x| x[01] == cVolume})

If ExistBlock("ACD100VO")
	lImpVol := ExecBlock("ACD100VO",.F.,.F.,{cIDVol})
	If Valtype(lImpVol) # 'L'
      lImpVol := .T.
   EndIf
   If !lImpVol
      Return
   EndIf
EndIf

If lEtqOfi
	aadd(aParamBox,{3,"Tipo de identificação de volumes:",1,{"Temporaria","Oficial"},50,"",.T.}) //"Tipo de identificação de volumes:"###"Temporaria"###"Oficial"
Endif
aadd(aParamBox,{1,"Local de Impressao",Space(06),"","","CB5","",0,.T.}) //"Local de Impressao"

If ParamBox(aParamBox,"Volume: "+cIDVol,@aRet,,,,,,,,.f.) //"Volume: "
	If lEtqOfi
		nTpEtqVol := aRet[nPosParam]
		++nPosParam
	Endif
	If ExistBlock(If(nTpEtqVol==1,"IMG05","IMG05OFI")) .AND. CB5SetImp(aRet[nPosParam],.t.)
		If nTpEtqVol==1  //Volume temporario
			ExecBlock("IMG05",,,{cIDVol,CB7->CB7_PEDIDO,CB7->CB7_NOTA,CB7->CB7_SERIE})
		Else  //Volume oficial
			ExecBlock("IMG05OFI",,,{nTotVol,VAL( aVolumes[ nVolAtu ][ 3 ] )})
            
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza o status do volume				³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aAreaCB6 := CB6->(GetArea())
			CB6->(DbSetOrder(1))

			If CB6->(DbSeek(xFilial("CB6")+cVolume)) .And. CB6->CB6_STATUS == "3" // Volume encerrado
				nAtuStaCB7 := Aviso("Aviso", "A etiqueta oficial do volume selecionado já foi impressa, gostaria de:" ,{"Imprimir","Estornar","Cancelar"}) // "Aviso" ## "A etiqueta oficial do volume selecionado já foi impressa, gostaria de:" ## "Imprimir" ## "Estornar" ## "Cancelar"
			EndIf

			If nAtuStaCB7 != 3
				RecLock("CB6",.F.)
				If nAtuStaCB7 == 1
					CB6->CB6_STATUS := "3" // Encerrado
				Else
					CB6->CB6_STATUS := "1" // Aberto
				EndIf
				CB6->(MsUnlock())
			EndIf
			
			CB6->(RestArea(aAreaCB6))
		Endif
		MSCBCLOSEPRINTER()
	EndIf
Endif

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GDFGet2         º Autor ³       Totvs                      º Data ³  19/06/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao de retorno do conteudo do campo de aColsAtu, semelhante ao GDFieldGet    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GDFGet2(cCampo)
Local nPosCmp := Ascan(aHeaderAtu,{|x| Upper(Alltrim(x[2]))==cCampo})
Local xRet

If nPosCmp > 0
	xRet := aColsAtu[nAtaCols,nPosCmp]
Endif

Return xRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VldImpEtiq º Autor ³ Paulo Fco. Cruz Neto º Data ³ 05.08.2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida a ordem de separacaoRotina de consulta de embalagens	 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function VldImpEtiq()

If	(CB7->CB7_STATUS == "0" .Or. CB7->CB7_STATUS == "1") .Or. ;
	("02" $ CB7->CB7_TIPEXP .And. (CB7->CB7_STATUS == "2" .Or. CB7->CB7_STATUS == "3")) .Or. ;
	("03" $ CB7->CB7_TIPEXP .And. Empty(CB7->(CB7_NOTA+CB7_SERIE))) .Or. ;
	(!ACDGet170() .And. "04" $ CB7->CB7_TIPEXP .And. (CB7->CB7_STATUS != "6")) .Or. ;
	(CB7->CB7_STATUS  == "8") .Or. ;
	(CB7->CB7_STATUS == "9" .And. !("05" $ CBUltExp(CB7->CB7_TIPEXP)))
		Return .F.
EndIf

Return .T.

/*/{Protheus.doc} ACD100Perg
//Guarda configuração do Pergunte utilizado
@author jose.eulalio
@since 14/08/2018
@version 1.0
@return aRet

@type function
/*/
Static Function ACD100Perg(cPerg)
Local aRet		:= {}
Local nX		:= 0
Local nY		:= 0
Local oObj
Local dLibVers  := ACDLibVersion()
Local aRetSX1	:= {}
Local aPergunt	:= {}

// se existe a classe FWSX1Util e o metodo GetAllFields não se encontra disponivel
// na versao da lib 20180615
If (dLibVers >= "20180820" ) 
	oObj := FWSX1Util():New()	
	
// faz o tratamento buscando direto na tabela SX1
// Caso gere issue na ferramenta SONARQUBE deve ser
// classificado como falso positivo.
else
	aRetSX1	:= SX1->(GetArea())
	
Endif

//Define quantidade de perguntas
If cPerg == "AIA106"
	If cPaisLoc == "BRA"
		MV_PAR10 := ""
        Pergunte(cPerg,.F.)
		If ValType(MV_PAR10) == "N"
			nY := 10 
		else
			nY := 9
		Endif
	Else
		MV_PAR08 := ""
        Pergunte(cPerg,.F.)
		If ValType(MV_PAR08) == "N"
		    nY := 8 
		else
			nY := 7
		Endif
	EndIf
ElseIf cPerg == "AIA102"
	nY := 10
ElseIf cPerg == "AIA107"
	nY := 5
ElseIf cPerg == "AIA103"
	nY := 11
ElseIf cPerg == "AIA108"
	nY := 2
ElseIf cPerg == "AIA104"
	nY := 6
EndIf

Aadd(aRet,cPerg)
Aadd(aRet,{})

// se existe a classe FWSX1Util e o metodo GetAllFields não se encontra disponivel
// na versao da lib 20180615
If (dLibVers >= "20180820" ) 

	oObj:AddGroup(cPerg)
	oObj:SearchGroup()

	aPergunt := oObj:GetGroup(cPerg)
	//Pega Perguntas e valores configurados
	For nX := 1 To nY
		Aadd(aRet[2],{aPergunt[2][nx]:CX1_PERGUNT,&("MV_PAR" + StrZero(nX,2))})
	Next nX
	
// faz o tratamento buscando direto na tabela SX1
// Caso gere issue na ferramenta SONARQUBE deve ser
// classificado como falso positivo.
Else	
	For nX := 1 To nY
		SX1->(DbSetOrder(1))
		SX1->(DbSeek(PADR(cPerg,Len(SX1->X1_GRUPO)) + StrZero(nX,2)))
		Aadd(aRet[2],{X1Pergunt(),&("MV_PAR" + StrZero(nX,2))})
	Next nX
	RestArea(aRetSX1)
	
Endif

Return aRet

/*/{Protheus.doc} IsUseApInd
//Verifica se o Produto e de Aprop. Indireta
@author Paulo V. Beraldo
@since Jan/2019
@version 1.0
@return lRet

@type function
/*/
Static Function IsPrdApInd( cProduto )
Local lRet		:= .T.
Local aArea		:= GetArea()
Local aAreaSB1	:= SB1->( GetArea() )

Default cProduto:= ''

dbSelectArea( 'SB1' )
SB1->( dbSetOrder( 1 ) )

If Empty( cProduto )
	lRet := .F.
Else
	If !SB1->( dbSeek( FWxFilial( 'SB1' ) + cProduto ) )
		lRet := .F.
	Else
		lRet := ( SB1->B1_APROPRI == 'I' )
	EndIf
EndIf

RestArea( aAreaSB1 )
RestArea( aArea )
Return lRet

/*/{Protheus.doc} ACDLibVersion
encapsulamento da funcao do frame que retorna a versão da lib do repositorio
@author reynaldo
@since 11/01/2019
@version 1.0
@return Character, Versão da lib do repositorio

@type function
/*/
Static Function ACDLibVersion()
	Local cVersao := ""
	/*
	 * A chamada da funcao __FWLibVersion esta sendo utilizada, conforme acordado com o framework.
	 * Pois se trata de uma funcao "interna" do framework.
	 * A função vai estar liberada com o nome de FWLibVersion() na proxima lib
	 * com versão superior a 20190111
	 */
	If FindFunction("__FWLibVersion")
		cVersao := __FWLibVersion()
	Else
		If FindFunction("FWLibVersion")
			cVersao := FWLibVersion()
		EndIf
	EndIf

Return cVersao


/*/{Protheus.doc} MenuDef
Funcao padrao de chamada de menus
@type function
@version 1.0
@author dener.lemos@dothink.com.br
@since 22/07/2025
@return array, rotinas do menu / botoes
/*/
Static Function MenuDef()
local cTxtEstorna := "Estornar " + If(nOSOpc == 1, "Vld.Fisica", "OS")
Private aRotina := { } 

aAdd(aRotina, {"Pesquisar" , "AxPesqui"   , 0, 1})
aAdd(aRotina, {"Visualizar", "U_VSACDA100", 0, 2})
aAdd(aRotina, {"Alterar"   , "U_ALACDA100", 0, 3})
If nOSOpc == 1 //-- Solicitado pelo Denis Lobo no dia 25/08/2025, pois segundo ele apenas pode haver estorno atraves da validacao fisica e nao na separacao
	aAdd(aRotina, {cTxtEstorna , "U_ETACDA100", 0, 5})
EndIf
aAdd(aRotina, {"Gerar"     , "U_GRACDA100", 0, 3})
aAdd(aRotina, {"Impressao" , "U_REACDA100", 0, 4})
aAdd(aRotina, {"Legenda"   , "U_LGACDA100", 0, 3})

If nOSOpc == 1
	AADD(aRotina,{"Desfaz Validação","U_DVACDA100",0,5})  //-- Desfaz Validacao Fisica
Else
	AADD(aRotina,{"Desfaz Separação","U_DSACDA100",0,5})  //-- Desfaz Separacao
	AADD(aRotina,{"Desfaz Embarque"	,"U_DEACDA100",0,5})  //-- Desfaz Embarque
EndIf

If ExistBlock("ACD100M")
	ExecBlock("ACD100M",.F.,.F.)
EndIf


Return aRotina

/*/{Protheus.doc} a1002Leg
	Funcao Responsavel Montar a Legenda do Browser
	@type  Static Function
	@author Paulo V. Beraldo
	@since Mar/2020
	@version 1.00
	@param aLegend	 , Array  , Vetor com as Informacoes para Montagem da Legenda
	@return oFWLegend, Object , Objeto FwLegend Criado
/*/
Static Function a1002Leg( aLegend )
Default aLegend := {}
oFWLegend := IIf( Type( "oFWLegend" ) == "U", Nil, oFWLegend )

If Len( aLegend ) > 0
	oFWLegend := FWLegend():New()
	AEval( aLegend,{ | x | oFWLegend:Add( x[1], x[2], x[3] ) } )
	oFWLegend:Activate()
EndIf

Return oFWLegend

/*/{Protheus.doc} a100Mark
	Funcao Responsavel por Marcar / Desmarcar Registros no Browser
	@type  Static Function
	@author Paulo V. Beraldo
	@since Mar/2020
	@version 1.00
	@param oBrwMrk	, Object  , Objeto do Browser
	@param nOpcx	, Numeric , Opcao para Processamento 1= Atualiza Registro / 2=Atualiza Todos
	@param cGetMark	, Caracter, Marca Utilizada no Browser
	@param bMark2	, Block	  , Bloco de Codigo Utilizado para Identificar se o Registro deve ser Marcado ou N?o
	@param uAlias	, Caracter, Alias da Tabela em Uso
	@param cCpoMark	, Caracter, Campo Utilizado para Marcar/Desmarcar
	@return lRet	, Boolean , Informa se foi possivel Atualizar o Registro
/*/
Static Function a100Mark( oBrwMrk, nOpcx, cGetMark, bMark2, uAlias, cCpoMark )
Local lRet		:= .T.
Local bMarkRec	:= { || IIf( Eval( bMark2 ) , IIf( AllTrim( &( ( uAlias )->( cCpoMark ) ) ) == AllTrim( cGetMark ), CriaVar( cCpoMark, .F.), AllTrim( cGetMark ) ) , CriaVar( cCpoMark, .F.) ) }

Default nOpcx := 1

If nOpcx == 1
	If !Empty(Eval( bMarkRec )) .OR. AllTrim( &( ( uAlias )->( cCpoMark ) ) ) == AllTrim( cGetMark )
	RecLock( uAlias, .F. )
	( uAlias )->( FieldPut( FieldPos( cCpoMark ) , Eval( bMarkRec ) ) )
	( uAlias )->( MsUnLock() )
	Endif
Else
	( uAlias )->( dbGoTop() )
	While !( uAlias )->( Eof() )
		If !Empty(Eval( bMarkRec )) .OR. AllTrim( &( ( uAlias )->( cCpoMark ) ) ) == AllTrim( cGetMark )
			RecLock( uAlias, .F. )
			( uAlias )->( FieldPut( FieldPos( cCpoMark ) , Eval( bMarkRec ) ) )
			( uAlias )->( MsUnLock() )
		Endif
		( uAlias )->( dbSkip() )
	EndDo

	oBrwMrk:GoTop()

EndIf

Return lRet

/*/{Protheus.doc} A100ItGrp
	Funcao Responsavel por Preencher o Vetor de Itens Respeitando a Configuracao 
	para Aglutinar as Ordens de Separacao
	@type  Static Function
	@author Paulo V. Beraldo
	@since Jul/2020
	@version 1.00
	@param aAux		, Array	  , Vetor com os Itens para Serem Aglutinados
	@param nAglutPed, Integer , Indica Se Devemos Aglutinar Pedido de Venda 1=Sim/2=Nao
	@param nAglutArm, Integer , Indica Se Devemos Aglutinar Armazem 1=Sim/2=Nao
	@return aItens	, Array	  , Vetor com os Itens Ordenados e Aglutinados
/*/
Static Function A100ItGrp( aAux, nAglutPed, nAglutArm, nPreSep )
Local nInd		:= 0
Local nPosSc9	:= 0
Local nAuxVet 	:= 0
Local aItens	:= {}
Local aAuxVet	:= {}
Local aItensUsr	:= {}
Local bAscVet	:= Nil
Local bAuxVet1	:= Nil
Local bAuxVet2	:= Nil
Local bAuxVet3	:= Nil
Local lAglut    := .F.
Local lAglutArm := .F.
Local lACD100G2 := ExistBlock("ACD100G2")
Local lACD100G3 := ExistBlock("ACD100G3")

// O bloco de codigo bAscVet determina a regra para efetuar a quebra das Ordens de Separacao (Por cliente e loja, por cliente, loja e armazem, etc.)
// As regras estao descritas no documento: https://tdn.totvs.com/pages/viewpage.action?pageId=619129430
// Os demais blocos contem os mesmos campos e sao utilizados para efetuar as comparacoes para efeito de aglutinacao de pedidos em uma mesma O.S.

Do Case

Case nAglutPed == 2 .And. nAglutArm == 2

	// Aglutina Pedido = Nao; Aglutina Armazem = Nao
	// Sera gerada uma Ordem de Separacao para cada pedido de vendas
	// Caso um pedido de venda possua itens com armazens diferentes, sera gerada uma Ordem de Separacao diferente para cada item/armazem

	bAscVet := { || Ascan( aItens ,{ | x |  AllTrim( x[ 04 ] ) == AllTrim( aAux[ nInd ][ 08 ] ) .And.; // Pedido
											AllTrim( x[ 01 ] ) == AllTrim( aAux[ nInd ][ 01 ] ) .And.; // Cliente
											AllTrim( x[ 02 ] ) == AllTrim( aAux[ nInd ][ 02 ] ) .And.; // Loja
											AllTrim( x[ 03 ] ) == AllTrim( aAux[ nInd ][ 06 ] ) } ) }  // Armazem
	
	bAuxVet1 := { || Aadd( aAuxVet, {		AllTrim( aAux[ nInd ][ 08 ] ),;
											AllTrim( aAux[ nInd ][ 01 ] ),;
											AllTrim( aAux[ nInd ][ 02 ] ),;
											AllTrim( aAux[ nInd ][ 06 ] ),;
											{ AllTrim( aAux[ nInd ][ 08 ] ) },;
											{ AllTrim( aAux[ nInd ][ 06 ] ) } } ) }

	bAuxVet2 := { || Ascan( aAuxVet,{ | x | AllTrim( x[ 01 ] ) == AllTrim( aAux[ nInd ][ 08 ] ) .And.;
											AllTrim( x[ 02 ] ) == AllTrim( aAux[ nInd ][ 01 ] ) .And.;
											AllTrim( x[ 03 ] ) == AllTrim( aAux[ nInd ][ 02 ] ) .And.;
											AllTrim( x[ 04 ] ) == AllTrim( aAux[ nInd ][ 06 ] ) } ) }

	bAuxVet3 := { || Ascan( aAuxVet,{ | x | AllTrim( x[ 01 ] ) == AllTrim( aItens[ nInd ][ 04 ] ) .And.;
											AllTrim( x[ 02 ] ) == AllTrim( aItens[ nInd ][ 01 ] ) .And.;
											AllTrim( x[ 03 ] ) == AllTrim( aItens[ nInd ][ 02 ] ) .And.;
											AllTrim( x[ 04 ] ) == AllTrim( aItens[ nInd ][ 03 ] ) } ) }

Case nAglutPed == 2 .And. nAglutArm == 1

	// Aglutina Pedido = Nao; Aglutina Armazem = Sim
	// Sera gerada uma Ordem de Separacao para cada pedido de vendas
	// Mesmo que o pedido de venda possua itens com armazens diferentes, todos os itens do pedido serao considerados na mesma Ordem de Separacao

	bAscVet := { || Ascan( aItens ,{ | x |  AllTrim( x[ 04 ] ) == AllTrim( aAux[ nInd ][ 08 ] ) .And.; // Pedido
											AllTrim( x[ 01 ] ) == AllTrim( aAux[ nInd ][ 01 ] ) .And.; // Cliente
											AllTrim( x[ 02 ] ) == AllTrim( aAux[ nInd ][ 02 ] ) } ) }  // Loja
	
	bAuxVet1 := { || Aadd( aAuxVet, {		AllTrim( aAux[ nInd ][ 08 ] ),;
											AllTrim( aAux[ nInd ][ 01 ] ),;
											AllTrim( aAux[ nInd ][ 02 ] ),;
											{ AllTrim( aAux[ nInd ][ 08 ] ) },;
											{ AllTrim( aAux[ nInd ][ 06 ] ) } } ) }

	bAuxVet2 := { || Ascan( aAuxVet,{ | x | AllTrim( x[ 01 ] ) == AllTrim( aAux[ nInd ][ 08 ] ) .And.;
											AllTrim( x[ 02 ] ) == AllTrim( aAux[ nInd ][ 01 ] ) .And.;
											AllTrim( x[ 03 ] ) == AllTrim( aAux[ nInd ][ 02 ] ) } ) }

	bAuxVet3 := { || Ascan( aAuxVet,{ | x | AllTrim( x[ 01 ] ) == AllTrim( aItens[ nInd ][ 04 ] ) .And.;
											AllTrim( x[ 02 ] ) == AllTrim( aItens[ nInd ][ 01 ] ) .And.;
											AllTrim( x[ 03 ] ) == AllTrim( aItens[ nInd ][ 02 ] ) } ) }

Case nAglutPed == 1 .And. nAglutArm == 2

	// Aglutina Pedido = Sim; Aglutina Armazem = Nao
	// Pedidos de venda serao aglutinados em uma mesma Ordem de Separacao desde que sejam do mesmo cliente/loja
	// Caso um pedido de venda possua itens com armazens diferentes, sera gerada uma Ordem de Separacao diferente para cada item/armazem

	bAscVet := { || Ascan( aItens ,{ | x |  AllTrim( x[ 01 ] ) == AllTrim( aAux[ nInd ][ 01 ] ) .And.; // Cliente
											AllTrim( x[ 02 ] ) == AllTrim( aAux[ nInd ][ 02 ] ) .And.; // Loja
											AllTrim( x[ 03 ] ) == AllTrim( aAux[ nInd ][ 06 ] ) } ) }  // Armazem

	bAuxVet1 := { || Aadd( aAuxVet, { 		AllTrim( aAux[ nInd ][ 01 ] ),;
											AllTrim( aAux[ nInd ][ 02 ] ),;
											AllTrim( aAux[ nInd ][ 06 ] ),;
											{ AllTrim( aAux[ nInd ][ 08 ] ) },;
											{ AllTrim( aAux[ nInd ][ 06 ] ) } } ) }

	bAuxVet2 := { || Ascan( aAuxVet,{ | x | AllTrim( x[ 01 ] ) == AllTrim( aAux[ nInd ][ 01 ] ) .And.;
											AllTrim( x[ 02 ] ) == AllTrim( aAux[ nInd ][ 02 ] ) .And.;
											AllTrim( x[ 03 ] ) == AllTrim( aAux[ nInd ][ 06 ] ) } ) }

	bAuxVet3 := { || Ascan( aAuxVet,{ | x | AllTrim( x[ 01 ] ) == AllTrim( aItens[ nInd ][ 01 ] ) .And.;
											AllTrim( x[ 02 ] ) == AllTrim( aItens[ nInd ][ 02 ] ) .And.;
											AllTrim( x[ 03 ] ) == AllTrim( aItens[ nInd ][ 03 ] ) } ) }

Case nAglutPed == 1 .And. nAglutArm == 1

	// Aglutina Pedido = Sim; Aglutina Armazem = Sim
	// Pedidos de venda serao aglutinados em uma mesma Ordem de Separacao desde que sejam do mesmo cliente/loja
	// Mesmo que o pedido de venda possua itens com armazens diferentes, todos os itens do pedido serao considerados na mesma Ordem de Separacao

	bAscVet := { || Ascan( aItens ,{ | x |  AllTrim( x[ 01 ] ) == AllTrim( aAux[ nInd ][ 01 ] ) .And.; // Cliente
											AllTrim( x[ 02 ] ) == AllTrim( aAux[ nInd ][ 02 ] ) } ) }  // Loja

	bAuxVet1 := { || Aadd( aAuxVet, { 		AllTrim( aAux[ nInd ][ 01 ] ),;
											AllTrim( aAux[ nInd ][ 02 ] ),;
											{ AllTrim( aAux[ nInd ][ 08 ] ) },;
											{ AllTrim( aAux[ nInd ][ 06 ] ) } } ) }

	bAuxVet2 := { || Ascan( aAuxVet,{ | x | AllTrim( x[ 01 ] ) == AllTrim( aAux[ nInd ][ 01 ] ) .And.;
											AllTrim( x[ 02 ] ) == AllTrim( aAux[ nInd ][ 02 ] ) } ) }

	bAuxVet3 := { || Ascan( aAuxVet,{ | x | AllTrim( x[ 01 ] ) == AllTrim( aItens[ nInd ][ 01 ] ) .And.;
											AllTrim( x[ 02 ] ) == AllTrim( aItens[ nInd ][ 02 ] ) } ) }

EndCase

If lACD100G2
	bAscVet := ExecBlock("ACD100G2", .F., .F., {bAscVet,nAglutPed,nAglutArm} )
EndIf

For nInd := 1 to Len( aAux )
	nPosSc9 := Eval( bAscVet )
	If nPosSc9 == 0
		Aadd( aItens, { AllTrim( aAux[ nInd ][ 01 ] ),; 	//01-Cliente/Fornecedor
						AllTrim( aAux[ nInd ][ 02 ] ),; 	//02-Loja Cliente/Fornecedor
						AllTrim( aAux[ nInd ][ 06 ] ),; 	//03-Armazem
						AllTrim( aAux[ nInd ][ 08 ] ),; 	//04-Codigo Ped Venda SC9
						{ aAux[ nInd ][ 07 ] }		 ,; 	//05-Vetor Recno SC9
						AllTrim( aAux[ nInd ][ 09 ] ),; 	//06-Cod. Ped Venda
						AllTrim( aAux[ nInd ][ 04 ] ),; 	//07-Loja Entrada
						AllTrim( aAux[ nInd ][ 10 ] ),; 	//08-Transportadora Ped venda SC5
						AllTrim( aAux[ nInd ][ 11 ] ),; 	//09-Cond. Pagto Ped venda SC5
						allTrim( aAux[ nInd ][ 05 ] ) } )	//10-Agreg

						Eval( bAuxVet1 )

		If lACD100G3
			aItensUsr := ExecBlock("ACD100G3", .F., .F., {aTail(aItens),aAux[nInd]} )
			If ValType(aItensUsr) == "A"
				aTail(aItens) := aClone(aItensUsr)
			EndIf
		EndIf

	Else
		Aadd( aItens[ nPosSc9 ][ 05 ], aAux[ nInd ][ 07 ] ) //05-Vetor Recno SC9
		nPosAglt := Eval( bAuxVet2 )
		If nPosAglt > 0
			If Ascan( aAuxVet[ nPosAglt ][ Len( aAuxVet[ nPosAglt ] )-1 ], AllTrim( aAux[ nInd ][ 08 ] ) ) == 0
				Aadd( aAuxVet[ nPosAglt ][ Len( aAuxVet[ nPosAglt ] )-1 ], AllTrim( aAux[ nInd ][ 08 ] ) )
			EndIf
			If Ascan( aAuxVet[ nPosAglt ][ Len( aAuxVet[ nPosAglt ] ) ], AllTrim( aAux[ nInd ][ 06 ] ) ) == 0
				Aadd( aAuxVet[ nPosAglt ][ Len( aAuxVet[ nPosAglt ] ) ], AllTrim( aAux[ nInd ][ 06 ] ) )
			EndIf
		EndIf

	EndIf
	
Next nInd

For nInd := 1 To Len( aItens )
	nAuxVet := Eval( bAuxVet3 )
	lAglut	:=   Len( aAuxVet[ nAuxVet ][ Len( aAuxVet[ nAuxVet ] )-1 ] ) > 1
	lAglutArm := Len( aAuxVet[ nAuxVet ][ Len( aAuxVet[ nAuxVet ] ) ] ) > 1

	Do Case
	Case nAglutPed == 2 .And. nAglutArm == 2 // Aglutina Pedido = Nao; Aglutina Armazem = Nao
		aItens[ nInd ][ 06 ] := IIf( lAglut .Or. nPreSep == 1, CriaVar( 'CB7_PEDIDO', .F. ), aItens[ nInd ][ 04 ] )
		aItens[ nInd ][ 07 ] := IIf( lAglut .Or. nPreSep == 1, CriaVar( 'CB7_LOJENT', .F. ), aItens[ nInd ][ 07 ] )
		aItens[ nInd ][ 08 ] := IIf( lAglut .Or. nPreSep == 1, CriaVar( 'CB7_TRANSP', .F. ), aItens[ nInd ][ 08 ] )
		aItens[ nInd ][ 09 ] := IIf( lAglut .Or. nPreSep == 1, CriaVar( 'CB7_COND'  , .F. ), aItens[ nInd ][ 09 ] )
		aItens[ nInd ][ 10 ] := IIf( nPreSep == 1, CriaVar( 'CB7_AGREG' , .F. ), aItens[ nInd ][ 10 ] )

	Case nAglutPed == 2 .And. nAglutArm == 1 // Aglutina Pedido = Nao; Aglutina Armazem = Sim
		aItens[ nInd ][ 03 ] := IIf( lAglutArm .Or. nPreSep == 1, CriaVar( 'CB7_LOCAL' , .F. ), aItens[ nInd ][ 03 ] )
		aItens[ nInd ][ 06 ] := IIf( lAglut .Or. nPreSep == 1, CriaVar( 'CB7_PEDIDO', .F. ), aItens[ nInd ][ 04 ] )
		aItens[ nInd ][ 07 ] := IIf( lAglut .Or. nPreSep == 1, CriaVar( 'CB7_LOJENT', .F. ), aItens[ nInd ][ 07 ] )
		aItens[ nInd ][ 08 ] := IIf( lAglut .Or. nPreSep == 1, CriaVar( 'CB7_TRANSP', .F. ), aItens[ nInd ][ 08 ] )
		aItens[ nInd ][ 09 ] := IIf( lAglut .Or. nPreSep == 1, CriaVar( 'CB7_COND'  , .F. ), aItens[ nInd ][ 09 ] )
		aItens[ nInd ][ 10 ] := IIf( nPreSep == 1, CriaVar( 'CB7_AGREG' , .F. ), aItens[ nInd ][ 10 ] )

	Case nAglutPed == 1 .And. nAglutArm == 2 // Aglutina Pedido = Sim; Aglutina Armazem = Nao
		aItens[ nInd ][ 06 ] := IIf( lAglut .Or. nPreSep == 1, CriaVar( 'CB7_PEDIDO', .F. ), aItens[ nInd ][ 04 ] )
		aItens[ nInd ][ 07 ] := IIf( lAglut .Or. nPreSep == 1, CriaVar( 'CB7_LOJENT', .F. ), aItens[ nInd ][ 07 ] )
		aItens[ nInd ][ 08 ] := IIf( lAglut .Or. nPreSep == 1, CriaVar( 'CB7_TRANSP', .F. ), aItens[ nInd ][ 08 ] )
		aItens[ nInd ][ 09 ] := IIf( lAglut .Or. nPreSep == 1, CriaVar( 'CB7_COND'  , .F. ), aItens[ nInd ][ 09 ] )
		aItens[ nInd ][ 10 ] := IIf( nPreSep == 1, CriaVar( 'CB7_AGREG' , .F. ), aItens[ nInd ][ 10 ] )

	Case nAglutPed == 1 .And. nAglutArm == 1 // Aglutina Pedido = Sim; Aglutina Armazem = Sim
		aItens[ nInd ][ 03 ] := IIf( lAglutArm .Or. nPreSep == 1, CriaVar( 'CB7_LOCAL' , .F. ), aItens[ nInd ][ 03 ] )
		aItens[ nInd ][ 06 ] := IIf( lAglut .Or. nPreSep == 1, CriaVar( 'CB7_PEDIDO', .F. ), aItens[ nInd ][ 04 ] )
		aItens[ nInd ][ 07 ] := IIf( lAglut .Or. nPreSep == 1, CriaVar( 'CB7_LOJENT', .F. ), aItens[ nInd ][ 07 ] )
		aItens[ nInd ][ 08 ] := IIf( lAglut .Or. nPreSep == 1, CriaVar( 'CB7_TRANSP', .F. ), aItens[ nInd ][ 08 ] )
		aItens[ nInd ][ 09 ] := IIf( lAglut .Or. nPreSep == 1, CriaVar( 'CB7_COND'  , .F. ), aItens[ nInd ][ 09 ] )
		aItens[ nInd ][ 10 ] := IIf( nPreSep == 1, CriaVar( 'CB7_AGREG' , .F. ), aItens[ nInd ][ 10 ] )

	EndCase

Next nInd


Return aItens


//-- Monta a tela de selecao de itens validados para desfazer
User Function DVACDA100()
	Local aArea      := GetArea()
	Local nOpca		 := 0
	Local bConfirma  := {|| nOpcA := 1, oModal:DeActivate() }
	Local bFechar 	 := {|| nOpcA := 0, oModal:DeActivate() }
	Local bGetData	 := {}
	Local aColunas	 := {}
	Local nX		 := 0
	Local oModal	 := Nil
	Local oBrowse	 := Nil
	Local oTabTemp   := Nil
	Local cAliasQry  := GetNextAlias()
	Local aCampoTmp  := {}
	Local aFiltro    := {}
	Local aIndex     := {}
	Local aSeek      := {}
	Local aCpoZ12    := FWSX3Util():GetAllFields( "Z12" , .F. )
	Local lAltMark	 := .T.
	Local lRetDesf	 := .F.

	CB9->(DbSetOrder(1))
	If CB7->CB7_STATUS == "9"
		MsgAlert("Esta validação fisica não pode ser defeita, pois a ordem de separação já está Finalizada.", "Aviso")
		Return
	ElseIf CB7->CB7_STATUS # "0" .and. Empty(CB7->CB7_STATPA)
		MsgAlert("Esta validação fisica não pode ser defeita pois a ordem de separação esta sendo executada neste momento", "Aviso")
		Return
	EndIf

	// retira o campo filial e numero do array
	aDel(aCpoZ12,ASCAN(aCpoZ12,"Z12_FILIAL"))
	aDel(aCpoZ12,ASCAN(aCpoZ12,"Z12_ORDSEP"))
	aSize(aCpoZ12, Len(aCpoZ12)-2)

	// busca campos do SX3 da tabela Z12
	For nX := 1 To Len(aCpoZ12)
		cCampoX3  := aCpoZ12[nX]
		cTitulo	:= GetSx3Cache( cCampoX3, "X3_TITULO")
		nTamCpo	:= GetSx3Cache( cCampoX3, "X3_TAMANHO")
		cTipoCpo:= GetSx3Cache( cCampoX3, "X3_TIPO")
		nDecCpo	:= GetSx3Cache( cCampoX3, "X3_DECIMAL")
		aAdd(aCampoTmp	,{cCampoX3,cTipoCpo,nTamCpo,nDecCpo})
		aAdd(aFiltro	,{cCampoX3,cTitulo,cTipoCpo,nTamCpo,nDecCpo, GetSx3Cache(cCampoX3,"X3_PICTURE")})//Adiciona o título dos campos na pesquisa por filtro
		If cTipoCpo == "C"
			aAdd(aIndex	, cCampoX3)			
			aAdd(aSeek	,{cTitulo, { {cTitulo, cTipoCpo, nTamCpo, 0, cTitulo, GetSx3Cache(cCampoX3,"X3_PICTURE"), cCampoX3} } , Len(aIndex), .T. })
		EndIf
		bGetData := &("{ ||(oBrowse:Alias())-> " + cCampoX3 + " }")
		aAdd( aColunas, FWBrwColumn():New())
		aColunas[nX]:SetData(bGetData)
    	aColunas[nX]:SetTitle(cTitulo)
    	aColunas[nX]:SetSize(nTamCpo)
    	aColunas[nX]:SetID(cCampoX3)
	Next

	// cria campo para selecionar os registros
	aAdd(aCampoTmp	,{"MARK" ,"N", 1,0})
	aAdd(aCampoTmp	,{"RECNO","N",99,0})

	oTabTemp:= FWTemporaryTable():New(cAliasQry) // seta tabela temporária
	oTabTemp:SetFields(aCampoTmp) // seta os campos da tabela temporária
	For nX := 1 to Len(aIndex)		
		oTabTemp:AddIndex( StrZero(nX,2), {aIndex[nX]} )//Adiciona os Indices da tabela temporária
	Next nX	
	oTabTemp:Create() //Cria a tabela temporaria	

	// monta tabela temporaria
	Z12SqlToTrb( aCampoTmp, cAliasQry, @lAltMark)//Adiciona os dados da query na tabela temporária

	// monta tela
	oModal	:= FWDialogModal():New()
	oModal:SetEscClose(.T.)
	oModal:SetTitle(OemToAnsi(Capital(FwSX2Util():GetX2Name("Z12"))))
	oModal:EnableAllClient()
	oModal:CreateDialog()
	oModal:addButtons({ { 1,"Confirmar", bConfirma, "",0,.T.,.F.} , { 1,"Cancelar", bFechar, "",0,.T.,.F.}})
	oBrowse := FWFormBrowse():New()
	oBrowse:AddMarkColumns( { || IIf( (cAliasQry)->MARK == 1, "LBOK", "LBNO" ) }, { || IIf( (cAliasQry)->MARK == 0 .Or. !lAltMark, (cAliasQry)->MARK := 1, (cAliasQry)->MARK := 0 ) } )
	oBrowse:DisableDetails()
	oBrowse:DisableReport()	
	oBrowse:SetDescription(OemToAnsi("Desfaz Validação Física: " + CB7->CB7_ORDSEP))
	oBrowse:SetDataTable()
	oBrowse:SetAlias(oTabTemp:GetAlias())
	oBrowse:SetColumns(aColunas)
	oBrowse:SetSeek(,aSeek)
	oBrowse:SetDoubleClick(bConfirma)
	oBrowse:SetOwner(oModal:getPanelMain())
	oBrowse:SetFieldFilter(aFiltro)
	oBrowse:SetUseFilter()
	If lAltMark
		oBrowse:aColumns[1]:bHeaderClick := {|| Z12MkAll( oBrowse ) }
		oBrowse:SetDoubleClick( {|| Z12MkOne( oBrowse ) } )
	EndIf
	oBrowse:Activate()
	oModal:Activate()
	
	// confirmação da tela
	If nOpcA == 1
		lRetDesf := .T.
		// processa tabela temporaria e desfaz separação dos registros marcados
		DbSelectArea(cAliasQry)
		DbGoTop()
		While !(cAliasQry)->(EOF())
			If (cAliasQry)->MARK == 1
				Z12->(DbGoTo((cAliasQry)->RECNO))

				//Tratamento caso o lote da CB8 não seja o lote que está sendo estornado na Z12
				If !lAltMark
					If CB8->(DbSeek(xFilial("CB8")+Z12->(Z12_ORDSEP+Z12_ITESEP+Z12_PROD+Z12_LOCAL+Z12_LCALIZ))) .And. Z12->Z12_LOTECT <> CB8->CB8_LOTECT
						RecLock("CB8")
						CB8->CB8_LOTECT := Z12->Z12_LOTECT
						CB8->(MsUnlock())
					EndIf
				EndIf

				GrvEstZ12((cAliasQry)->Z12_QTESEP,(cAliasQry)->Z12_QTESEP)
			Endif
			(cAliasQry)->(DbSkip())
		EndDo
	EndIf

	RestArea( aArea )

	oTabTemp:Delete() //Deletando a tabela temporária e liberando a memória utilizada
	FreeObj( oModal )
	FreeObj( oBrowse )
	FreeObj( oTabTemp )

	FwFreeArray( aIndex )
	FwFreeArray( aSeek )
	FwFreeArray( aCampoTmp )
	FwFreeArray( aFiltro )
	FwFreeArray( aCpoZ12 )
	FwFreeArray( aArea )

Return lRetDesf

//-- Desfaz embarque
User Function DEACDA100()
	local aArea		:= GetArea()
	local cQryEmb	:= ""
	local nQtEEBQ 	:= 0

	If !("06*" $ CB7->CB7_TIPEXP)
		FWAlertWarning("Não possui embarque configurado!", "Sem Embarque")  
		Return
	EndIf

	cQryEmb := "SELECT SUM(CB9_QTEEBQ) QTEEBQ FROM " + RetSQLName("CB9") + " CB9 "
	cQryEmb += " WHERE CB9.D_E_L_E_T_ = ' ' AND CB9.CB9_FILIAL = '" + xFilial("CB9") + "' "
	cQryEmb += " AND CB9.CB9_ORDSEP = '"+ CB7->CB7_ORDSEP +"' "
	nQtEEBQ := MpSysExecScalar(cQryEmb, "QTEEBQ")

	If Empty(nQtEEBQ)
		FWAlertWarning("A ordem de separação <strong>"+CB7->CB7_ORDSEP+"</strong>, não possui itens embarcados!", "Sem Embarque")  
		RestArea(aArea)
		Return
	EndIf

	DbSelectArea("Z09")
	Z09->( DbSetOrder(3) )
	If !Z09->( DbSeek(CB7->(CB7_FILIAL+CB7_PEDIDO)) )
		FWAlertWarning("A ordem de separação <strong>"+CB7->CB7_ORDSEP+"</strong>, não possui tracking (Filial: "+CB7->CB7_FILIAL+", Pedido: "+CB7->CB7_PEDIDO+")!", "Sem Embarque")  
		RestArea(aArea)
		Return
	EndIf

	If Z09->Z09_ACAOCS == '2'
    	FWAlertWarning("Aguardando Ação CS!", "Aguardando CS")  
		RestArea(aArea)
		Return
	EndIf

	If Z09->Z09_STATUS > '7' .And. !FWAlertNoYes("O pedido <strong>"+Z09->Z09_NUMPV+"</strong>, já foi enviado para o cliente. Mesmo assim deseja prosseguir com o estorno?" , "Pedido enviado para o cliente")
		RestArea(aArea)
		Return
	EndIf	

	If !FWAlertNoYes("Deseja estornar <strong>TODOS ITENS EMBARCADOS</strong> da ordem de separação <strong>"+CB7->CB7_ORDSEP+"</strong>?" , "Confirma Estorno?")
		RestArea(aArea)
		Return
	EndIf

	FWMsgRun(NIL,{|| ProcDsEmb()  },"Aguarde...","Estornando Embarque")
	
	FWAlertSucess("Estorno executado!", "Finalizada")

	RestArea(aArea)
Return

Static Function ProcDsEmb()
	local nI		:= 0
	local nJ		:= 0
	local aItens	:= {}
	local aPVs		:= {}
	local cItemAnt	:= ""
	local cChave	:= ""

	DbSelectArea("CB9")
	CB9->( DbSetOrder(1) )
	CB9->( DbSeek(CB7->(CB7_FILIAL+CB7_ORDSEP)) )
	While CB9->(!Eof() .And. CB9_FILIAL+CB9_ORDSEP == CB7->(CB7_FILIAL+CB7_ORDSEP))
		If Empty(CB9->CB9_QTEEBQ)
			CB9->(DBSkip())
			Loop
		EndIf

		RecLock("CB9", .F.)
			CB9->CB9_QTEEBQ := 0
			CB9->CB9_STATUS := "1"  // em aberto
		CB9->( MsUnLock() )

		If Ascan(aItens, {|x| x[2] == CB9->CB9_ITESEP}) == 0
			aadd(aItens, {CB9->CB9_PEDIDO, CB9->CB9_ITESEP})
		EndIf

		CB9->( DbSkip() )
	End

	aAdd(aPVs, CB7->( CB7_FILIAL + CB7_PEDIDO ))
	If !Empty(CB7->CB7_XPVTRI)
		aAdd(aPVs, CB7->( CB7_FILIAL + CB7_XPVTRI ))
	Endif

	For nJ := 1 To Len(aPVs)
		cChave	:= aPVs[nJ]
		cItemAnt:= ""
		For nI:=1 To Len(aItens)
			If cItemAnt != aItens[nI,1]+aItens[nI,2]
				SetTraking("6", cChave, aItens[nI,2], Nil, "Estorno embarque PV-Item: " + AllTrim(aItens[nI,1]) + "-" + AllTrim(aItens[nI,2]), "Estorno Embarque" )
			EndIf
			cItemAnt := aItens[nI,1]+aItens[nI,2]
		Next nI
	Next nJ

Return

//-- Monta a tela de selecao de itens separados para desfazer
User Function DSACDA100()
	Local aArea      := GetArea()
	Local nOpca		 := 0
	Local bConfirma  := {|| nOpcA := 1, oModal:DeActivate() }
	Local bFechar 	 := {|| nOpcA := 0, oModal:DeActivate() }
	Local bGetData	 := {}
	Local aColunas	 := {}
	Local nX		 := 0
	Local oModal	 := Nil
	Local oBrowse	 := Nil
	Local oTabTemp   := Nil
	Local cAliasQry  := GetNextAlias()
	Local aCampoTmp  := {}
	Local aFiltro    := {}
	Local aIndex     := {}
	Local aSeek      := {}
	Local aCpoCB9    := FWSX3Util():GetAllFields( "CB9" , .F. )
	Local lAltMark	 := .T.
	Local lRetDesf	 := .F.
 
	// retira o campo filial e numero do array
	aDel(aCpoCB9,ASCAN(aCpoCB9,"CB9_FILIAL"))
	aDel(aCpoCB9,ASCAN(aCpoCB9,"CB9_ORDSEP"))
	aSize(aCpoCB9, Len(aCpoCB9)-2)

	// busca campos do SX3 da tabela CB9
	For nX := 1 To Len(aCpoCB9)
		cCampoX3  := aCpoCB9[nX]
		cTitulo	:= GetSx3Cache( cCampoX3, "X3_TITULO")
		nTamCpo	:= GetSx3Cache( cCampoX3, "X3_TAMANHO")
		cTipoCpo:= GetSx3Cache( cCampoX3, "X3_TIPO")
		nDecCpo	:= GetSx3Cache( cCampoX3, "X3_DECIMAL")
		aAdd(aCampoTmp	,{cCampoX3,cTipoCpo,nTamCpo,nDecCpo})
		aAdd(aFiltro	,{cCampoX3,cTitulo,cTipoCpo,nTamCpo,nDecCpo, GetSx3Cache(cCampoX3,"X3_PICTURE")})//Adiciona o título dos campos na pesquisa por filtro
		If cTipoCpo == "C"
			aAdd(aIndex	, cCampoX3)			
			aAdd(aSeek	,{cTitulo, { {cTitulo, cTipoCpo, nTamCpo, 0, cTitulo, GetSx3Cache(cCampoX3,"X3_PICTURE"), cCampoX3} } , Len(aIndex), .T. })
		EndIf
		bGetData := &("{ ||(oBrowse:Alias())-> " + cCampoX3 + " }")
		aAdd( aColunas, FWBrwColumn():New())
		aColunas[nX]:SetData(bGetData)
    	aColunas[nX]:SetTitle(cTitulo)
    	aColunas[nX]:SetSize(nTamCpo)
    	aColunas[nX]:SetID(cCampoX3)
	Next

	// cria campo para selecionar os registros
	aAdd(aCampoTmp	,{"MARK" ,"N", 1,0})
	aAdd(aCampoTmp	,{"RECNO","N",99,0})

	oTabTemp:= FWTemporaryTable():New(cAliasQry) // seta tabela temporária
	oTabTemp:SetFields(aCampoTmp) // seta os campos da tabela temporária
	For nX := 1 to Len(aIndex)		
		oTabTemp:AddIndex( StrZero(nX,2), {aIndex[nX]} )//Adiciona os Indices da tabela temporária
	Next nX	
	oTabTemp:Create() //Cria a tabela temporaria	

	// monta tabela temporaria
	CB9SqlToTrb( aCampoTmp, cAliasQry, @lAltMark)//Adiciona os dados da query na tabela temporária

	// monta tela
	oModal	:= FWDialogModal():New()
	oModal:SetEscClose(.T.)
	oModal:SetTitle(OemToAnsi(Capital(FwSX2Util():GetX2Name("CB9"))))
	oModal:EnableAllClient()
	oModal:CreateDialog()
	oModal:addButtons({ { 1,"Confirmar", bConfirma, "",0,.T.,.F.} , { 1,"Cancelar", bFechar, "",0,.T.,.F.}})
	oBrowse := FWFormBrowse():New()
	oBrowse:AddMarkColumns( { || IIf( (cAliasQry)->MARK == 1, "LBOK", "LBNO" ) }, { || IIf( (cAliasQry)->MARK == 0 .Or. !lAltMark, (cAliasQry)->MARK := 1, (cAliasQry)->MARK := 0 ) } )
	oBrowse:DisableDetails()
	oBrowse:DisableReport()	
	oBrowse:SetDescription(OemToAnsi("Desfaz Separação: " + CB7->CB7_ORDSEP))
	oBrowse:SetDataTable()
	oBrowse:SetAlias(oTabTemp:GetAlias())
	oBrowse:SetColumns(aColunas)
	oBrowse:SetSeek(,aSeek)
	oBrowse:SetDoubleClick(bConfirma)
	oBrowse:SetOwner(oModal:getPanelMain())
	oBrowse:SetFieldFilter(aFiltro)
	oBrowse:SetUseFilter()
	If lAltMark
		oBrowse:aColumns[1]:bHeaderClick := {|| CB9MkAll( oBrowse ) }
		oBrowse:SetDoubleClick( {|| CB9MkOne( oBrowse ) } )
	EndIf
	oBrowse:Activate()
	oModal:Activate()
	
	// confirmação da tela
	If nOpcA == 1
		lRetDesf := .T.
		// processa tabela temporaria e desfaz separação dos registros marcados
		DbSelectArea(cAliasQry)
		DbGoTop()
		While !(cAliasQry)->(EOF())
			If (cAliasQry)->MARK == 1
				CB9->(DbGoTo((cAliasQry)->RECNO))

				//Tratamento caso o lote da CB8 não seja o lote que está sendo estornado na CB9
				If !lAltMark
					If CB8->(DbSeek(xFilial("CB8")+CB9->(CB9_ORDSEP+CB9_ITESEP+CB9_PROD+CB9_LOCAL+CB9_LCALIZ))) .And. CB9->CB9_LOTECT <> CB8->CB8_LOTECT
						RecLock("CB8")
						CB8->CB8_LOTECT := CB9->CB9_LOTECT
						CB8->(MsUnlock())
					EndIf
				EndIf

				GrvEstCB9((cAliasQry)->CB9_QTESEP,(cAliasQry)->CB9_QTESEP)
			Endif
			(cAliasQry)->(DbSkip())
		EndDo
	EndIf

	RestArea( aArea )

	oTabTemp:Delete() //Deletando a tabela temporária e liberando a memória utilizada
	FreeObj( oModal )
	FreeObj( oBrowse )
	FreeObj( oTabTemp )

	FwFreeArray( aIndex )
	FwFreeArray( aSeek )
	FwFreeArray( aCampoTmp )
	FwFreeArray( aFiltro )
	FwFreeArray( aCpoCB9 )
	FwFreeArray( aArea )

Return lRetDesf


//-- Insere os registros dos itens da ordem de separação na tabela temporaria
Static Function Z12SqlToTrb( aStruTmp, cAliasTmp, lAltMark )

	Local aArea := GetArea()
	Local nI	:= 0
	
	// busca dados da separação
	Z12->( DbSetOrder(1) ) // Z12_FILIAL+Z12_ORDSEP+Z12_CODETI
	Z12->( DbSeek( CB7->CB7_FILIAL+CB7->CB7_ORDSEP ) )
	While !Z12->( EOF() ) .And. Z12->Z12_FILIAL+Z12->Z12_ORDSEP == CB7->CB7_FILIAL+CB7->CB7_ORDSEP
		( cAliasTmp )->( DbAppend() )
		For nI := 1 To Len(aStruTmp)
			If aStruTmp[nI,1] <> "MARK" 
				If aStruTmp[nI,1] == "RECNO" 
					( cAliasTmp )->RECNO := Z12->( RECNO() )
				Else
					( cAliasTmp )->( FieldPut( nI, Z12->( FieldGet( FieldPos( aStruTmp[ nI, 1 ] ) ) ) ) )				
				Endif
			Endif
		Next 
		Z12->( DbSkip() )
	End

	If !lAltMark
		( cAliasTmp )->(dbGoTop())
		While !( cAliasTmp )->(Eof())
			//Atualiza item(s) separados
			RecLock(cAliasTmp, .F.)
			( cAliasTmp )->MARK := 1
			( cAliasTmp )->(MsUnlock())
			( cAliasTmp )->(dbSkip())
		EndDo
	EndIf

	RestArea( aArea )
	FWFreeArray( aArea )
	
Return Nil


//-- Insere os registros dos itens da ordem de separação na tabela temporaria
Static Function CB9SqlToTrb( aStruTmp, cAliasTmp, lAltMark )

	Local aArea := GetArea()
	Local nI	:= 0
	
	// busca dados da separação
	CB9->( DbSetOrder(1) ) // CB9_FILIAL+CB9_ORDSEP+CB9_CODETI
	CB9->( DbSeek( CB7->CB7_FILIAL+CB7->CB7_ORDSEP ) )
	While !CB9->( EOF() ) .And. CB9->CB9_FILIAL+CB9->CB9_ORDSEP == CB7->CB7_FILIAL+CB7->CB7_ORDSEP
		( cAliasTmp )->( DbAppend() )
		For nI := 1 To Len(aStruTmp)
			If aStruTmp[nI,1] <> "MARK" 
				If aStruTmp[nI,1] == "RECNO" 
					( cAliasTmp )->RECNO := CB9->( RECNO() )
				Else
					( cAliasTmp )->( FieldPut( nI, CB9->( FieldGet( FieldPos( aStruTmp[ nI, 1 ] ) ) ) ) )				
				Endif
			Endif
		Next 
		CB9->( DbSkip() )
	End

	If !lAltMark
		( cAliasTmp )->(dbGoTop())
		While !( cAliasTmp )->(Eof())
			//Atualiza item(s) separados
			RecLock(cAliasTmp, .F.)
			( cAliasTmp )->MARK := 1
			( cAliasTmp )->(MsUnlock())
			( cAliasTmp )->(dbSkip())
		EndDo
	EndIf

	RestArea( aArea )
	FWFreeArray( aArea )
	
Return Nil


//-- Funcao Responsavel para marcar/desmarcar o registros selecionado
Static Function Z12MkOne( oObjMark )

	Local nMark 
	Local cMarkZ12 := ''

	Default oObjMark := Nil
	If oObjMark <> Nil
		cMarkZ12 := oObjMark:cAlias
		nMark := IIF( ( cMarkZ12 )->MARK == 1, 0, 1 )
		( cMarkZ12 )->MARK := nMark
		oObjMark:Refresh( , .T. )
	EndIf

Return


//-- Funcao Responsavel para marcar/desmarcar o registros selecionado
Static Function CB9MkOne( oObjMark )

	Local nMark 
	Local cMarkCB9 := ''

	Default oObjMark := Nil
	If oObjMark <> Nil
		cMarkCB9 := oObjMark:cAlias
		nMark := IIF( ( cMarkCB9 )->MARK == 1, 0, 1 )
		( cMarkCB9 )->MARK := nMark
		oObjMark:Refresh( , .T. )
	EndIf

Return


//-- Funcao Responsavel para marcar/desmarcar todos os registros no markbrowse
Static Function Z12MkAll( oObjMark )

	Local nMark 
	Local cMarkZ12 := ''
	Default oObjMark := Nil

	If oObjMark <> Nil
		cMarkZ12 := oObjMark:cAlias
		( cMarkZ12 )->( DbGoTop() )
		nMark := IIF( ( cMarkZ12 )->MARK == 1, 0, 1 )
		While ( cMarkZ12 )->( !EOF() ) 
			( cMarkZ12 )->MARK := nMark
			( cMarkZ12 )->( DbSkip() )
		End
		( cMarkZ12 )->( DbGoTop() )
		oObjMark:Refresh( , .T. )
	EndIf

Return


//-- Funcao Responsavel para marcar/desmarcar todos os registros no markbrowse
Static Function CB9MkAll( oObjMark )

	Local nMark 
	Local cMarkCB9 := ''
	Default oObjMark := Nil

	If oObjMark <> Nil
		cMarkCB9 := oObjMark:cAlias
		( cMarkCB9 )->( DbGoTop() )
		nMark := IIF( ( cMarkCB9 )->MARK == 1, 0, 1 )
		While ( cMarkCB9 )->( !EOF() ) 
			( cMarkCB9 )->MARK := nMark
			( cMarkCB9 )->( DbSkip() )
		End
		( cMarkCB9 )->( DbGoTop() )
		oObjMark:Refresh( , .T. )
	EndIf

Return


//-- Estorna Z12
Static Function GrvEstZ12(nQtde, nSldQtdDev)
	Local nDevQtd := 0
	Local cOrdSep := Z12->Z12_ORDSEP
	Local cProd	  := Z12->Z12_PROD
	Local cArm 	  := Z12->Z12_LOCAL
	Local cEnd 	  := Z12->Z12_LCALIZ
	Local cLote   := Z12->Z12_LOTECT
	Local cSLote  := Z12->Z12_NUMLOT
	Local cNumSer := Z12->Z12_NUMSER
	Local cLoteOri:= Nil
	Local cStatus := "1"
	Local cItemAnt := ""

	If nQtde <= Z12->Z12_QTESEP
		//Devolve item(s) ja separados para o CB8
		DevItemCB8(nQtde,cLoteOri)
		
		//Atualiza item(s) separados
		RecLock("Z12",.F.)
		Z12->Z12_QTESEP -= nQtde
		If Empty(Z12->Z12_QTESEP)
			Z12->(DbDelete())
		EndIf
		Z12->(MsUnlock())
	Else
		Z12->(DbSetOrder(9))
		Z12->(DbSeek(xFilial("Z12")+cOrdSep+cProd+cArm+cEnd+cLote+cSLote+cNumSer))
		While !Z12->(Eof()) .and. ;
			Z12->(Z12_FILIAL+Z12_ORDSEP+Z12_PROD+Z12_LOCAL+Z12_LCALIZ+Z12_LOTECT+Z12_NUMLOT+Z12_NUMSER) ==;
			xFilial("Z12")+cOrdSep+cProd+cArm+cEnd+cLote+cSLote+cNumSer
			If Empty(nQtde)
				Exit
			EndIf
			
			If Empty(Z12->Z12_QTESEP) //-- ja devolvido
				Z12->(DbSkip())
				Loop
			EndIf
			
			If nQtde <= Z12->Z12_QTESEP
				nDevQtd := nQtde
				nQtde	  := 0
			Else
				nDevQtd := Z12->Z12_QTESEP
				nQtde   -= nDevQtd
			EndIf
			
			If !DevItemCB8(nDevQtd)
				VTAlert("Item de validacao nao localizado!","Aviso",.T.,4000,3)
				Z12->(DbSetOrder(12))
				Z12->(DbSeek(xFilial("Z12")+cOrdSep))
				Return
			EndIf
			
			RecLock("Z12",.F.)
			Z12->Z12_QTESEP -= nDevQtd
			If Empty(Z12->Z12_QTESEP)
				Z12->(DbDelete())
			EndIf
			Z12->(MsUnlock())
		EndDo
	EndIf

	If Empty( MpSysExecScalar("SELECT COUNT(1) AS OK FROM " + RetSQLName("Z12") + " Z12 WHERE Z12.Z12_FILIAL = '" + xFilial("Z12") + "' AND Z12.Z12_ORDSEP = '" + cOrdSep + "' AND Z12.D_E_L_E_T_= ' ' ", "OK") )
		cStatus := "0"
	EndIf

	RecLock("CB7",.F.)
	CB7->CB7_XSTATU := cStatus
	CB7->CB7_XSTATP := "1"
	If cStatus == "0"
		CB7->CB7_XDIVER := "0"
		CB7->CB7_XSTATP := "0"
	EndIf
	CB7->(MsUnlock())

	If cStatus == "0"
		dbSelectArea("CB8")
		CB8->(dbSetOrder(1))      
		If CB8->(dbSeek(xFilial("CB8") + CB7->CB7_ORDSEP))
			While CB8->(!EoF()) .AND. CB8->(CB8_FILIAL+CB8_ORDSEP) == CB7->(CB7_FILIAL+CB7_ORDSEP)
				If cItemAnt != CB8->(CB8_PEDIDO+CB8_ITEM)
					SetTraking("3", CB8->CB8_PEDIDO, CB8->CB8_ITEM, Nil, "Validação física totalmente desfeita PV-Item: " + AllTrim(CB8->CB8_PEDIDO) + "-" + AllTrim(CB8->CB8_ITEM), "Desfaz Validação Física")
				EndIf
				cItemAnt := CB8->(CB8_PEDIDO+CB8_ITEM)

				CB8->(dbSkip())
			EndDo
		EndIf
	EndIf

Return


//-- Estorna CB9
Static Function GrvEstCB9(nQtde, nSldQtdDev)
	Local nDevQtd := 0
	Local cOrdSep := CB9->CB9_ORDSEP
	Local cProd	  := CB9->CB9_PROD
	Local cArm 	  := CB9->CB9_LOCAL
	Local cEnd 	  := CB9->CB9_LCALIZ
	Local cLote   := CB9->CB9_LOTECT
	Local cSLote  := CB9->CB9_NUMLOT
	Local cNumSer := CB9->CB9_NUMSER
	Local cLoteOri:= Nil
	Local cStatus := "1"
	Local cItemAnt := ""

	If nQtde <= CB9->CB9_QTESEP
		//Devolve item(s) ja separados para o CB8
		DevItemCB8(nQtde,cLoteOri)
		
		//Atualiza item(s) separados
		RecLock("CB9",.F.)
		CB9->CB9_QTESEP -= nQtde
		If Empty(CB9->CB9_QTESEP)
			CB9->(DbDelete())
		EndIf
		CB9->(MsUnlock())
	Else
		CB9->(DbSetOrder(9))
		CB9->(DbSeek(xFilial("CB9")+cOrdSep+cProd+cArm+cEnd+cLote+cSLote+cNumSer))
		While !CB9->(Eof()) .and. ;
			CB9->(CB9_FILIAL+CB9_ORDSEP+CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTECT+CB9_NUMLOT+CB9_NUMSER) ==;
			xFilial("CB9")+cOrdSep+cProd+cArm+cEnd+cLote+cSLote+cNumSer
			If Empty(nQtde)
				Exit
			EndIf
			
			If Empty(CB9->CB9_QTESEP) //-- ja devolvido
				CB9->(DbSkip())
				Loop
			EndIf
			
			If nQtde <= CB9->CB9_QTESEP
				nDevQtd := nQtde
				nQtde	  := 0
			Else
				nDevQtd := CB9->CB9_QTESEP
				nQtde   -= nDevQtd
			EndIf
			
			If !DevItemCB8(nDevQtd)
				VTAlert("Item de validacao nao localizado!","Aviso",.T.,4000,3)
				CB9->(DbSetOrder(12))
				CB9->(DbSeek(xFilial("CB9")+cOrdSep))
				Return
			EndIf
			
			RecLock("CB9",.F.)
			CB9->CB9_QTESEP -= nDevQtd
			If Empty(CB9->CB9_QTESEP)
				CB9->(DbDelete())
			EndIf
			CB9->(MsUnlock())
		EndDo
	EndIf

	If Empty( MpSysExecScalar("SELECT COUNT(1) AS OK FROM " + RetSQLName("CB9") + " CB9 WHERE CB9.CB9_FILIAL = '" + xFilial("CB9") + "' AND CB9.CB9_ORDSEP = '" + cOrdSep + "' AND CB9.D_E_L_E_T_= ' ' ", "OK") )
		cStatus := "0"
	EndIf

	RecLock("CB7",.F.)
		CB7->CB7_STATUS := cStatus
		CB7->CB7_STATPA := "1"
		If cStatus == "0"
			CB7->CB7_DIVERG := "0"
			CB7->CB7_STATPA := "0"
		EndIf
	CB7->(MsUnlock())

	If cStatus == "0"
		dbSelectArea("CB8")
		CB8->(dbSetOrder(1))      
		If CB8->(dbSeek(xFilial("CB8") + CB7->CB7_ORDSEP))
			While CB8->(!EoF()) .AND. CB8->(CB8_FILIAL+CB8_ORDSEP) == CB7->(CB7_FILIAL+CB7_ORDSEP)
				If cItemAnt != CB8->(CB8_PEDIDO+CB8_ITEM)
					SetTraking("4", CB8->CB8_PEDIDO, CB8->CB8_ITEM, Nil, "Separação totalmente desfeita PV-Item: " + AllTrim(CB8->CB8_PEDIDO) + "-" + AllTrim(CB8->CB8_ITEM), "Desfaz Separação")
				EndIf
				cItemAnt := CB8->(CB8_PEDIDO+CB8_ITEM)

				CB8->(dbSkip())
			EndDo
		EndIf
	EndIf

Return


//-- Devolve Items separados para o itens a separar CB8
Static Function DevItemCB8(nQtde,cLoteOri)
	Local aCB8			:= CB8->(GetArea())
	Local aLoteOri		:= {}
	Local lAtuLotCB8	:= .F.

	Default cLoteOri	:= ""

	If nOSOpc == 1
		CB8->(DbSetOrder(4))
		If !CB8->(DbSeek(xFilial("CB8")+Z12->(Z12_ORDSEP+Z12_ITESEP+Z12_PROD+Z12_LOCAL+Z12_LCALIZ+Z12_LOTECT+Z12_NUMLOT+Z12_NUMSER)))
			Return .F.
		EndIf

		While CB8->(!Eof() .AND. ;
			CB8_FILIAL+CB8_ORDSEP+CB8_ITEM+CB8_PROD+CB8_LOCAL+CB8_LCALIZ+CB8_LOTECT+CB8_NUMLOT+CB8_NUMSER ==;
			xFilial("CB8")+Z12->(Z12_ORDSEP+Z12_ITESEP+Z12_PROD+Z12_LOCAL+Z12_LCALIZ+Z12_LOTECT+Z12_NUMLOT+Z12_NUMSER))

			If CB8->CB8_PEDIDO # Z12->Z12_PEDIDO
				CB8->(DbSkip())
				Loop
			EndIf

			If CB8->CB8_SEQUEN # Z12->Z12_SEQUEN
				CB8->(DbSkip())
				Loop
			EndIf

			RecLock("CB8")
			If nQtde < CB8->CB8_XQTDOR
				CB8->CB8_XSALDO := CB8->CB8_XSALDO + nQtde
			Else
				CB8->CB8_XSALDO := CB8->CB8_XSALDO + CB8->CB8_XQTDOR
			EndIf

			If "01" $ CB7->CB7_TIPEXP .And. !"01" $ CB7->CB7_TIPEXP
				CB8->CB8_SALDOE := CB8->CB8_SALDOE + nQtde
			EndIf

			If lAtuLotCB8
				CB8->CB8_LOTECT := aTail(aLoteOri)
			EndIf

			CB8->(MsUnlock())
			CB8->(DbSkip())
		EndDo
	Else
		CB8->(DbSetOrder(4))
		If !CB8->(DbSeek(xFilial("CB8")+CB9->(CB9_ORDSEP+CB9_ITESEP+CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTECT+CB9_NUMLOT+CB9_NUMSER)))
			Return .F.
		EndIf

		While CB8->(!Eof() .AND. ;
			CB8_FILIAL+CB8_ORDSEP+CB8_ITEM+CB8_PROD+CB8_LOCAL+CB8_LCALIZ+CB8_LOTECT+CB8_NUMLOT+CB8_NUMSER ==;
			xFilial("CB8")+CB9->(CB9_ORDSEP+CB9_ITESEP+CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTECT+CB9_NUMLOT+CB9_NUMSER))

			If CB8->CB8_PEDIDO # CB9->CB9_PEDIDO
				CB8->(DbSkip())
				Loop
			EndIf

			If CB8->CB8_SEQUEN # CB9->CB9_SEQUEN
				CB8->(DbSkip())
				Loop
			EndIf

			RecLock("CB8")
			If nQtde < CB8->CB8_QTDORI
				CB8->CB8_SALDOS := CB8->CB8_SALDOS + nQtde
			Else
				CB8->CB8_SALDOS := CB8->CB8_SALDOS + CB8->CB8_QTDORI
			EndIf

			If "01" $ CB7->CB7_TIPEXP .And. !"01" $ CB7->CB7_TIPEXP
				CB8->CB8_SALDOE := CB8->CB8_SALDOE + nQtde
			EndIf

			If lAtuLotCB8
				CB8->CB8_LOTECT := aTail(aLoteOri)
			EndIf

			CB8->(MsUnlock())
			CB8->(DbSkip())
		EndDo
	EndIf

	//Restaura Ambiente
	CB8->(RestArea(aCB8))

Return .T.


//--
Static Function SetTraking(cOpc, cChave, cItem, cMotivo, cObs, cTitLog)
    local aArea   := GetArea()
	local aASC5   := SC5->( GetArea() )
    local aTrackS := {}
	local nRecPos := CB7->( Recno() )
	local cAuxObs := ""

	dbSelectArea("SC5")
	SC5->( dbSetOrder(1) )
    If SC5->( dbSeek( cChave ) )
		RecLock("SC5", .f.)
			If cOpc == "3"
				SC5->C5_X4SSTAT := "A" // Em Validacao Fisica
			ElseIf cOpc == "4"
				SC5->C5_X4SSTAT := "8" // Em Agendamento
			ElseIf cOpc == "5"
				SC5->C5_X4SSTAT := "9" // Em Validacao Fiscal
				SC5->C5_XBLFIS	:= "1"
			ElseIf cOpc == "6"
				SC5->C5_X4SSTAT := "B" // Em Embarque				
			EndIf

			//Grava o campo C5_MSEXP para sinalizaro ao Scheduler
			SC5->C5_MSEXP:=   ""  //DToS(dDataBase)
		SC5->( MsUnLock() )

		dbSelectArea("Z09")
		Z09->( dbSetOrder(3) )

		If Z09->( dbSeek(cChave + cItem) )
			aTrackS := Array( Len( Z09->( DbStruct() ) ) )

			aTrackS[Z09->(FieldPos("Z09_FILIAL"))]  := Z09->Z09_FILIAL
			aTrackS[Z09->(FieldPos("Z09_NUMPV")) ]  := Z09->Z09_NUMPV                   // Pedido Venda
			aTrackS[Z09->(FieldPos("Z09_ITEMPV"))]  := Z09->Z09_ITEMPV                  // Item PV
			If cOpc == "1"
				cAuxObs += "--[" + DTOC(Date()) + " " + Time() + "]----------"+ chr(13)+chr(10)
				cAuxObs += "De: Logistica" + chr(13)+chr(10)
				cAuxObs += "Para: Operações" + chr(13)+chr(10)
				cAuxObs += "Quem: " + cUserName + chr(13)+chr(10)
				cAuxObs += "O que: "+ cObs + chr(13)+chr(10)

				aTrackS[Z09->(FieldPos("Z09_ACAOCS"))]	:= "2"								// Acao CS
				aTrackS[Z09->(FieldPos("Z09_DSMOTV"))]	:= cAuxObs + Trim(Z09->Z09_DSMOTV) 	// Detalhes do Motivo
            	aTrackS[Z09->(FieldPos("Z09_PENCS")) ]  := cAuxObs + Trim(Z09->Z09_PENCS)   // Pendencia CS
				If !Empty(cMotivo)
					aTrackS[Z09->(FieldPos("Z09_MOTIVO")) ]	:= cMotivo						// Observacao para CS
				EndIf
			ElseIf cOpc == "2"
				cAuxObs += "--[" + DTOC(Date()) + " " + Time() + "]----------"+ chr(13)+chr(10)
				cAuxObs += "Quem: " + cUserName + chr(13)+chr(10)
				cAuxObs += "O que: " + chr(13)+chr(10) + cObs + chr(13)+chr(10)

				aTrackS[Z09->(FieldPos("Z09_OBSLOG")) ]	:= cAuxObs	+ Trim(Z09->Z09_OBSLOG)						// Obs.Logistic para a alteracao do empenho
			ElseIf cOpc == "3"
				cAuxObs += "--[" + DTOC(Date()) + " " + Time() + "]----------"+ chr(13)+chr(10)
				cAuxObs += "Quem: " + cUserName + chr(13)+chr(10)
				cAuxObs += "O que: " + chr(13)+chr(10) + cObs + chr(13)+chr(10)

				aTrackS[Z09->(FieldPos("Z09_OBSLOG")) ]	:= cAuxObs + Trim(Z09->Z09_OBSLOG)						// Obs.Logistic para a Desfaz Validacao Fisica
				aTrackS[Z09->(FieldPos("Z09_DVIFIS"))]  := CTOD("")		
				aTrackS[Z09->(FieldPos("Z09_HVIFIS"))]  := Space(5)
				aTrackS[Z09->(FieldPos("Z09_UVIFIS"))]  := Space(15)

				aTrackS[Z09->(FieldPos("Z09_DVFISI"))]  := CTOD("")	
				aTrackS[Z09->(FieldPos("Z09_HVFISI"))]  := Space(5)
				aTrackS[Z09->(FieldPos("Z09_UVFISI"))]  := Space(15)
				aTrackS[Z09->(FieldPos("Z09_STATUS"))]  := "3"							    // Status "Em Validacao Fisica"
			ElseIf cOpc == "4"
				cAuxObs += "--[" + DTOC(Date()) + " " + Time() + "]----------"+ chr(13)+chr(10)
				cAuxObs += "Quem: " + cUserName + chr(13)+chr(10)
				cAuxObs += "O que: " + chr(13)+chr(10) + cObs + chr(13)+chr(10)

				aTrackS[Z09->(FieldPos("Z09_OBSLOG")) ]	:= cAuxObs + Trim(Z09->Z09_OBSLOG)							// Obs.Logistic para a Desfaz Separacao
				aTrackS[Z09->(FieldPos("Z09_DTEXPE"))]  := CTOD("")
				aTrackS[Z09->(FieldPos("Z09_HREXPE"))]  := Space(5)
				aTrackS[Z09->(FieldPos("Z09_STATUS"))]  := "4"							    // Status "Em Agendamento"
			ElseIf cOpc == "5"
				cAuxObs += "--[" + DTOC(Date()) + " " + Time() + "]----------"+ chr(13)+chr(10)
				cAuxObs += "Quem: " + cUserName + chr(13)+chr(10)
				cAuxObs += "O que: " + chr(13)+chr(10) + cObs + chr(13)+chr(10)

				aTrackS[Z09->(FieldPos("Z09_OBSLOG")) ]	:= cAuxObs + Trim(Z09->Z09_OBSLOG)							// Obs.Logistic para a Desfaz Separacao
				aTrackS[Z09->(FieldPos("Z09_STATUS"))]  := "2"							    // Status "Em Validacao Fiscal"
			ElseIf cOpc == "6"
				cAuxObs += "--[" + DTOC(Date()) + " " + Time() + "]----------"+ chr(13)+chr(10)
				cAuxObs += "Quem: " + cUserName + chr(13)+chr(10)
				cAuxObs += "O que: " + chr(13)+chr(10) + cObs + chr(13)+chr(10)

				aTrackS[Z09->(FieldPos("Z09_OBSLOG")) ]	:= cAuxObs + Trim(Z09->Z09_OBSLOG)						// Obs.Logistic para a Desfaz Embarque
				aTrackS[Z09->(FieldPos("Z09_DTPEMB"))]  := CTOD("")
				aTrackS[Z09->(FieldPos("Z09_HRPEMB"))]  := Space(5)
				aTrackS[Z09->(FieldPos("Z09_STATUS"))]  := "7"							    // Status "Em Embarque"				
			EndIf

			u_TRK006S(aTrackS, cTitLog)

			Z09->( DbSkip() )
		End

		CB7->( DbGoto(nRecPos) )
	EndIf

	RestArea(aASC5)
    RestArea(aArea)

Return


//--
Static Function ChkRemessa(cXFilial, cXPedido)
	Local aAreaAnt := GetArea()
	Local aAreaSC5 := SC5->(GetArea())
	Local cRemessa := ""

	SC5->(dbSetOrder(1))
	If SC5->(dbSeek(cXFilial + cXPedido))
		//-- Verificar se e operacao remessa
		If !Empty(SC5->C5_XPEDWEB)
			cRemessa := MpSysExecScalar("SELECT Coalesce(C5_NUM, '"+Space(TamSX3('C5_NUM')[1])+"') AS PEDIDO FROM " + RetSQLName("SC5") + " SC5 WHERE SC5.C5_FILIAL = '" + xFilial("SC5") + "' AND SC5.D_E_L_E_T_= ' ' AND C5_XPEDORI = '"+SC5->C5_XPEDWEB+"'", "PEDIDO")
		EndIf
	EndIf

	RestArea(aAreaSC5)
	RestArea(aAreaAnt)

Return cRemessa
