#include "totvs.ch"
#include "apvt100.ch"


                        
/*/{Protheus.doc} ACDVEX03
Embarque dos volumes 
@type function
@version 20250726  
@author dener.lemos@dothink.com.br
@since 26/07/2025
@return variant, return_description
/*/
User Function ACDVEX03()
Local aTela
Local nOpc 

IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf

If ACDGet170() 
	Return ACDVEX3X(0)
EndIf

aTela := VtSave()
VTCLear()
If lVT100B // GetMv("MV_RF4X20")
	@ 0,0 VTSAY "Embarque" + ' Selecione:'//"Embarque"
	nOpc:=VTaChoice(2,0,3,VTMaxCol(),{"Ordem de separação","Pedido de vendas","Nota Fiscal"})
ElseIf Vtmodelo()=="RF"
	@ 0,0 VTSAY "Embarque" //"Embarque" 
	@ 1,0 VTSay 'Selecione:' 
	nOpc:=VTaChoice(3,0,6,VTMaxCol(),{"Ordem de separação","Pedido de vendas","Nota Fiscal"})
ElseIf VtModelo()=="MT44"
	@ 0,0 VTSAY "Embarque" //"Embarque" 
	@ 1,0 VTSay 'Selecione:'
	nOpc:=VTaChoice(0,20,1,39,{"Ordem de separação","Pedido de vendas","Nota Fiscal"})
ElseIf VtModelo()=="MT16"
	@ 0,0 VTSAY "Embarque Selecione"
	nOpc:=VTaChoice(1,0,1,19,{"Ordem de separação","Pedido de vendas","Nota Fiscal"})
EndIf	

VtRestore(,,,,aTela)

If nOpc == 1 // por ordem de separacao
	ACDVEX3A()
ElseIf nOpc == 2 // por pedido de venda
	ACDVEX3B()
ElseIf nOpc == 3 // por Nota Fiscal 
	ACDVEX3C()
EndIf   

Return 1

Static Function ACDVEX3A()
ACDVEX3X(1)
Return
Static Function ACDVEX3B()
ACDVEX3X(2)
Return
Static Function ACDVEX3C()
ACDVEX3X(3)
Return


/*/{Protheus.doc} ACDVEX3X
Funcao principal do Embarque
@type function
@version 20250810
@author dener.lemos@dothink.com.br
@since 8/26/2025
@param nOpc, numeric, Opacao: 1=por ordem de separacao; 2=por pedido de venda; 3=por Nota Fiscal 
/*/
Static Function ACDVEX3X(nOpc)
Local ckey09       := VTDescKey(09)
Local ckey24       := VTDescKey(24)
Local bkey09       := VTSetKey(09)
Local bkey24       := VTSetKey(24)

Private cTranspConf
Private cDesTra
Private cCodOpe    := CBRetOpe()
Private lVldOrdSep := GetMV("MV_CBVLDOS") == "1" // --> Valida Ordem de Separacao
Private lVldTransp := SuperGetMV("MV_CBVLDTR",.F.,"1") == "1" // --> Valida Transportadora
Private lEmbarque  := .t.

If Type('cOrdSep')=='U'
	Private cOrdSep := Space(TamSX3("CB8_ORDSEP")[1])
EndIf    

IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf

//Verifica se foi chamado pelo programa ACDV170 e se ja foi embarcado 
//(ver se eh necessario fazer esta consistencia)
If ACDGet170() .AND. !("06" $ CB7->CB7_TIPEXP)
	Return 10
ElseIf ACDGet170()
	//Desativa a  tecla  avanca
	A170ATVKeys(.f.,.t.)		
EndIf

VTClear()
If VtModelo()=="RF" .or. lVT100B
	@ 0,0 VtSay  "Embarque"
EndIf
If ! CBSolCB7(nOpc,{|| VldCodSep()})
   Return 10
EndIf   

If CB7->CB7_STATUS == "9" .And. MpSysExecScalar("SELECT SUM(CB9_QTEEBQ) AS QTDEMB FROM " + RetSQLName("CB9") + " CB9 WHERE CB9.CB9_FILIAL = '" + CB7->CB7_FILIAL + "' AND CB9.D_E_L_E_T_= ' ' ", "QTDEMB") > 0
   VTAlert("Processo de embarque finalizado","Aviso",.t.,4000) 
   If VTYesNo("Deseja estornar os produtos embarcados ?","Atencao",.T.)
	   VTSetKey(09,{|| Informa()},"Informacoes")
	   Estorna()
	   VTSetKey(09,bkey09,cKey09)        
	   Return FimEmbarq()
	Endif			   			
EndIf   

IniProcesso()

VTSetKey(09,{|| Informa()},"Informacoes") //"Informacoes"
VTSetKey(24,{|| Estorna()},"Estorno") //"Estorno"

//Informa a Transportadora
If !Transport()
	Return FimEmbarq(10)
EndIf      

//Atualiza variavel com dados da transportadora
cDesTra := ""

DbSelectArea("SA4")
SA4->(DbSetOrder(1)) // A4_FILIAL + A4_COD
SA4->(DbSeek(xFilial("SA4") + CB7->CB7_TRANSP))
If !Empty(SA4->A4_COD)
	cTranspConf := SA4->A4_COD
	cDesTra     := SA4->A4_NOME	
ENDIF


//Leitura dos produtos para embarque
If !Embarque()
	Return FimEmbarq(10)
EndIf

Vtsetkey(09,bkey09,cKey09)
Vtsetkey(24,bkey24,cKey24)
Return  FimEmbarq()                   


/*/{Protheus.doc} VldCodSep
Validacao da Ordem de Separacao
@type function
@version 20250801  
@author erike.yuri@dothink.com.br
@since 8/26/2025
@return logical, retorno da validacao sucesso ou erro
/*/
Static Function VldCodSep()

If Empty(cOrdSep)
   VtKeyBoard(chr(23))
   Return .f.
EndIf

CB7->(DbSetOrder(1))
CB7->(DbSeek(xFilial("CB7")+cOrdSep))

// --> Atencao nao alterar a sequencia das validacoes.

If CB7->(Eof())
	VtAlert("Ordem de separacao  nao encontrada.","Aviso",.t.,4000,3)
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf
  
// analisar a pergunta '00-Separcao,01-Separacao/Embalagem,02-Embalagem,03-Gera Nota,04-Imp.Nota,05-Imp.Volume,06-embarque'
If !("06") $ CB7->CB7_TIPEXP
	VtAlert("Ordem de separacao nao configurada para Embarque","Aviso",.t.,4000,3)
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
Endif

If CB7->CB7_STATUS == "0" .OR. CB7->CB7_STATUS == "1"
	VtAlert("Ordem de separacao possui itens nao separados","Aviso",.t.,4000,3)
	VtKeyboard(Chr(20))  // zera o get
	Return .f.
Endif

If "02" $ CB7->CB7_TIPEXP .and. (CB7->CB7_STATUS == "2" .OR. CB7->CB7_STATUS == "3")
	VtAlert("Ordem de separacao possui itens nao embalados","Aviso",.t.,4000,3)
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
Endif

If "03" $ CB7->CB7_TIPEXP .and. Empty(CB7->(CB7_NOTA+CB7_SERIE))
	VtAlert("Nota não gerada para esta ordem de separação","Aviso",.t.,4000,3)
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
Endif

If !ACDGet170()
	If "04" $ CB7->CB7_TIPEXP .AND.  (CB7->CB7_STATUS  < "6")
		VtAlert("Nota nao impressa para esta Ordem de separacao","Aviso",.t.,4000,3)
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	If "05" $ CB7->CB7_TIPEXP .AND.  (CB7->CB7_STATUS  < "7")
		VtAlert("Etiquetas oficiais de volume nao foram impressas para esta Ordem de separacao","Aviso",.t.,4000,3)
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf		
EndIf

If CB7->CB7_STATUS # "0" .AND. CB7->CB7_STATPA == "1" .AND. CB7->CB7_CODOPE # cCodOpe  // SE ESTIVER EM SEPARACAO E PAUSADO SE DEVE VERIFICAR SE O OPERADOR E' O MESMO
   VtBeep(3)
   If !VTYesNo("Ordem Separacao iniciada pelo operador "+CB7->CB7_CODOPE+". Deseja continuar ?","Aviso",.T.)
      VtKeyboard(Chr(20))  // zera o get
      Return .F.
   EndIf
EndIf

//-- Ponto de entrada permite validação especifica para a ordem de separação.   
If ExistBlock("ACD175SOL")
	lRet:=ExecBlock("ACD175SOL",.f.,.f.)
	If ValType(lRet) == "L"
	   	Return lRet
   	EndIf
EndIf   	

RecLock("CB7",.f.)
If !Empty(CB7->CB7_STATPA)  // se estiver pausado tira o STATUS  de pausa
	CB7->CB7_STATPA := " "
EndIf
CB7->CB7_CODOPE := cCodOpe
CB7->(MsUnlock())
Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ IniProcesso³ Autor ³ ACD                 ³ Data ³ 08/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Embarque                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function IniProcesso()
	CBFlagSC5("3",cOrdSep)  //Embarcado
	RecLock("CB7")
		CB7->CB7_STATUS := "8"    //Em processo de embarque
		CB7->CB7_STATPA := " "    //tira pausa

		If Z09->(FieldPos("Z09_DVIFIS")) .And. Z09->(FieldPos("Z09_HVIFIS")) .And. Z09->(FieldPos("Z09_UVIFIS"))
			SetTraking("1", "Em Embarque")
		EndIf
	CB7->(MsUnlock())
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Transport³ Autor ³ ACD    	            ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Responsável por apresentar tela de digitação de dados  da³   ±±
±±³transportadora.³                                                                        ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Transport()          
Local cF3 
Local nLinha
Local uRetTrans
Local lV175CODT :=ExistBlock("V175CODT")
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf
VTClear()
If lVldTransp
	If lVT100B // GetMv("MV_RF4X20")
		If ! Empty(CB7->CB7_TRANSP)
			@ 0,0 VTSay "Va para doca " //"Va para doca "
			@ 1,0 VTSay "referente a  " //"referente a  "
			@ 2,0 VTSay "transportadora:" //"transportadora:"
			@ 3,0 VTSay CB7->CB7_TRANSP
			VTPause
			VTClear
			@ 1,0 VTSay "Confirme a " //"Confirme a "
			@ 2,0 VTSay "transportadora" //"transportadora"
			nLinha:= 7
		Else
			@ 0,0 VTSay "Leia o codigo da" //"Leia o codigo da"
			@ 1,0 VTSay "transportadora:" //"transportadora:"
			@ 2,0 VTSay "para embarcar" //"para embarcar"
			nLinha := 3
		EndIf
	ElseIf VtModelo()=="RF"
		If ! Empty(CB7->CB7_TRANSP)
			@ 0,0 VTSay "Va para doca " //"Va para doca " 
			@ 1,0 VTSay "referente a  " //"referente a  " 
			@ 2,0 VTSay "transportadora:" //"transportadora:" 
			@ 3,0 VTSay CB7->CB7_TRANSP
			@ 5,0 VTSay "Confirme a " //"Confirme a " 
			@ 6,0 VTSay "transportadora" //"transportadora" 
			nLinha:= 7
		Else
			@ 0,0 VTSay "Leia o codigo da" //"Leia o codigo da" 
			@ 1,0 VTSay "transportadora:" //"transportadora:" 
			@ 2,0 VTSay "para embarcar" //"para embarcar" 
			nLinha := 3
		EndIf  
	ElseIf VtModelo()=="MT44"
		If ! Empty(CB7->CB7_TRANSP)
			@ 0,0 VTSay "Confirme a "+"transportadora"+ CB7->CB7_TRANSP //"Confirme a transportadora "
		Else
			@ 0,0 VTSay "Informe a Transportadora"  //"Informe a Transportadora" 
		EndIf
		nLinha := 1	
	ElseIf VtModelo()=="MT16"
		If ! Empty(CB7->CB7_TRANSP)
		VtClear()	
		@ 0,0 VTSay "Confirme a " //"Confirme a "
		@ 1,0 VTSay "transportadora" //"Transportadora"	   
		VtInkey(0)
		VtClear()
			@ 0,0 VTSay "Transp.: "+CB7->CB7_TRANSP
		Else
		VtClear()	
		@ 0,0 VTSay  "Informe a " //"Informe a "
		@ 1,0 VTSay  "transportadora" //"Transportadora"	   
		VtInkey(0)
		VtClear()
			@ 0,0 VTSay "transportadora" //"Transportadora" 
		EndIf
		nLinha:= 1
	EndIf   

	while .t.
		VtClearBuffer()
		If UsaCB0('06')
			cTranspConf := Space(10)
		Else
			cTranspConf := Space(6)
			cF3 := 'SA4'
		EndIf
		If lV175CODT
			uRetTrans := ExecBlock("V175CODT",.F.,.F.)
			If(ValType(uRetTrans)=="C") 
				cTranspConf := uRetTrans
			EndIf
		EndIf
		@ nLinha,0 VTGet cTranspConf  pict "@!" Valid VldConfTransp(cTranspConf) F3 cF3
		VTRead
		If VtLastKey() == 27
			Return .f.
		EndIf
		Exit
	End
EndIf	
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³VldConfTransp³ Autor ³ ACD                ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Validacao da Transportadora                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldConfTransp(cTranspConf)
Local lACD175VE := ExistBlock("ACD175VE")
Local aRet      := {}
Local lRet      := .T.

If UsaCB0("06")  // se usar CB0 para dispositivo
	aRet := CBRetEti(cTranspConf,"06")
	If lACD175VE
		aRet:=ExecBlock('ACD175VE',,,{aRet,"06"})
	EndIf	
	If Empty(aRet)
		VtAlert("Etiqueta invalida","Aviso",.t.,4000,3) //### "Etiqueta invalida","Aviso"
		VtClearGet("cTranspConf")
		lRet := .F.
	EndIf
Else
	aRet := {PadR(cTranspConf,6)}
EndIf

If !Empty(CB7->CB7_TRANSP) .and. CB7->CB7_TRANSP <> aRet[1]
	VtBeep(3)
	VtAlert("Transportadora invalida","Aviso",.T.,4000) //"Transportadora invalida"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	lRet:= .F.
EndIf

If lRet
	SA4->(DbSetOrder(1))
	If !SA4->(DbSeek(xFilial()+aRet[1]))
		VtAlert("Transportadora nao encontrada","Aviso",.T.,4000,3)  //### "Transportadora nao encontrada","Aviso"
		VtClearGet("cTranspConf")
		lRet := .F.
	EndIf
EndIf

If lRet
	RecLock("CB7")
	CB7->CB7_TRANSP := aRet[1]
	CB7->(MsUnlock())
EndIf	

Return lRet

             
/*/{Protheus.doc} FimEmbarq
Finalisa o processo de Impressao de NFS  
@type function
@version 20250726  
@author dener.lemos@dothink.com.br
@since 26/07/2025
@param nSai, numeric, codigo para analise de finalizacao
@return numeric, retorno para expedicao ligada
/*/ 
Static Function FimEmbarq(nSai)
Local _cStatus := CB7->CB7_STATUS
Local _cPausa  := " "
Local lACD175FI := ExistBlock("ACD175FI") 
Default nSai := 1 

CB9->(DbSetOrder(5))
If !CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP+"1")) .AND. ;
	!CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP+"2")) 
   _cStatus := "9"	//Embarque finalizado
   _cPausa  := " "   //Sem pausa
   VTAlert("Processo de embarque finalizado","Aviso",.t.,4000) 
ElseIf CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP+"3")) .AND.;
		(CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP+"1")) .OR. ;
		 CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP+"2")))
   _cStatus := "8"  //Embarcando
   _cPausa  := "1"  //Pausada
Else              
	 // Retorna para processo anterior 
	_cStatus :=  CBAntProc(CB7->CB7_TIPEXP,"06*")
	_cPausa  := "1"  //Pausada

	If Z09->(FieldPos("Z09_DVIFIS")) .And. Z09->(FieldPos("Z09_HVIFIS")) .And. Z09->(FieldPos("Z09_UVIFIS"))
		SetTraking("2", "Em Faturamento")
	EndIf
EndIf

RecLock("CB7",.F.)
CB7->CB7_STATUS := _cStatus
CB7->CB7_STATPA := _cPausa
CB7->(MsUnLock())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para Customizacoes apos gravar dados Embarque     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lACD175FI
       ExecBlock("ACD175FI",.F.,.F.,{CB7->CB7_ORDSEP})
EndIf       

//Verifica se esta sendo chamado pelo ACDV170 e se existe um avanco 
//ou retrocesso forcado pelo operador
If ACDGet170() .AND. A170AvOrRet() 
 	nSai := A170ChkRet()         
EndIf
Return nSai


Static Function Embarque()
//Local cEtiqProd
Local nQtde
Local cProduto
Local cPictQtdExp := PesqPict("CB8","CB8_QTDORI")
Local lForcaQtd   := GetMV("MV_CBFCQTD",,"2") =="1"     
Private cVolume   := Space(10)
Private lEmbarque := .t.

IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf

While .T.
	VTClear           
	If lVT100B // GetMv("MV_RF4X20")
		@ 0,0 VTSay "Transp." +CB7->CB7_TRANSP+" "+SubStr(cDesTra,1,20)		
		If '01' $ CB7->CB7_TIPEXP .or. '02' $ CB7->CB7_TIPEXP // trabalha com sub-volume
			cVolume := Space(10)
			@ 02,00 VtSay "Leia o volume" //"Leia o volume"
			@ 03,00 VtGet cVolume Picture "@!" Valid VldEbqVol(cVolume)
		Else
			nQtde := 1
			cProduto   := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
			If ! Usacb0("01")
				@ 1,0 VTSay 'Qtde ' VtGet nQtde pict cPictQtdExp valid VldQtde(nQtde,.f.) when (lForcaQtd .or. VTLastkey() == 5) //
			EndIf
			@ 2,0 VTSay "Embarcar Produto" // "Embarcar Produto"->Embarcar Produto
			@ 3,0 VTGet cProduto pict '@!' VALID VTLastkey() == 5 .or. VldProdEbq(cProduto,nQtde,Nil)
		EndIf
	ElseIf VtModelo()=="RF"
		@ 0,0 VTSay "Transportadora"
		@ 1,0 VTSay CB7->CB7_TRANSP
		@ 2,0 VtSay SubStr(cDesTra,1,20)
		If '01' $ CB7->CB7_TIPEXP .or. '02' $ CB7->CB7_TIPEXP // trabalha com sub-volume
			cVolume := Space(10)
			@ 06,00 VtSay "Leia o volume" 
			@ 07,00 VtGet cVolume Picture "@!" Valid VldEbqVol(cVolume)
		Else
			nQtde := 1
			cProduto   := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
			If ! Usacb0("01")
				@ 4,0 VTSay 'Qtde ' VtGet nQtde pict cPictQtdExp valid VldQtde(nQtde,.f.) when (lForcaQtd .or. VTLastkey() == 5) //
			EndIf
			@ 5,0 VTSay "Leia o produto" 
			@ 6,0 VtSay "a embarcar" 
			@ 7,0 VTGet cProduto pict '@!' VALID VTLastkey() == 5 .or. VldProdEbq(cProduto,nQtde,Nil)
		EndIf
	ElseIf VtModelo()=="MT44" 
		If '01' $ CB7->CB7_TIPEXP .or. '02' $ CB7->CB7_TIPEXP // trabalha com sub-volume
		@ 0,0 VTSay "Transp." +CB7->CB7_TRANSP+" "+SubStr(cDesTra,1,20)
			cVolume := Space(10)
			@ 01,00 VtSay "Leia o volume" VtGet cVolume Picture "@!" Valid VldEbqVol(cVolume) //"Leia o volume" -> Leia o volume
		Else         
		@ 0,0 VTSay "Transp." +CB7->CB7_TRANSP
			nQtde := 1   
			cProduto   := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
			If ! Usacb0("01")
				@ 0,17 VTSay 'Qtde ' VtGet nQtde pict cPictQtdExp valid VldQtde(nQtde,.f.) when (lForcaQtd .or. VTLastkey() == 5) //
			EndIf
			@ 1,0 VTSay "Embarcar Produto" VTGet cProduto pict '@!' VALID VTLastkey() == 5 .or. VldProdEbq(cProduto,nQtde,Nil) // "Embarcar Produto"->Embarcar Produto
		EndIf           
	ElseIf VtModelo()=="MT16"	
		If '01' $ CB7->CB7_TIPEXP .or. '02' $ CB7->CB7_TIPEXP // trabalha com sub-volume
		@ 0,0 VTSay "Transp." +CB7->CB7_TRANSP
			cVolume := Space(10)
			@ 01,00 VtSay "Volume" VtGet cVolume Picture "@!" Valid VldEbqVol(cVolume) // Volume
		Else         
			nQtde := 1   
			cProduto   := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
			If Usacb0("01")
			@ 0,0 VTSay "Transp." +CB7->CB7_TRANSP
			Else
				@ 0,0 VTSay 'Qtde ' VtGet nQtde pict cPictQtdExp valid VldQtde(nQtde,.f.) when (lForcaQtd .or. VTLastkey() == 5) //
			EndIf
			@ 1,0 VTSay "Produto" VTGet cProduto pict '@!' VALID VTLastkey() == 5 .or. VldProdEbq(cProduto,nQtde,Nil) //"Produto"->Produto
		EndIf           
	EndIf
	VtRead
	If VtLastKey() == 27
		Return .f.
	EndIf
	CB9->(DbSetOrder(5))
	If ! CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP+"1")) .and. ! CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP+"2"))
		Exit
	EndIF
EndDo
RecLock("CB7")
CB7->CB7_STATUS := "9"    //embarcado/finalizado
CBLogExp(cOrdSep)
CB7->(MsUnlock())
//VTAlert('Processo de embarque finalizado','Aviso',.t.,4000) //'Processo de expedicao finalizado'###
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ VldEbqVol³ Autor ³ ACD                   ³ Data ³ 08/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validacao do Volume no embarque e no estorno do embarque   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldEbqVol(cVolume,lEstorna)
Local lACD175VE  := ExistBlock("ACD175VE")
Local lACD175VO  := ExistBlock("ACD175VO")
Local aRet       := {}
Local cVolOri
Default lEstorna := .F.

If Empty(cVolume)
	Return .f.
EndIf

If lACD175VO
	cVolOri := cVolume
	cVolume := ExecBlock("ACD175VO",.F.,.F.,{cVolume})
	If (ValType(cVolume)<>"C") .OR. (ValType(cVolume)=="C" .AND. Empty(cVolume))
		cVolume := cVolOri
	EndIf
EndIf

If UsaCB0("05")
   aRet:= CBRetEti(cVolume,"05")
	If lACD175VE
		aRet:=ExecBlock('ACD175VE',,,{aRet,"05"})
	Endif   
   If Empty(aRet)
	   VtAlert("Etiqueta de volume invalida","Aviso",.t.,4000,3) //###"Etiqueta de volume invalida","Aviso"
	   VtKeyboard(Chr(20))  // zera o get
	   Return .f.
   EndIf
   cCodVol:= aRet[1]   
Else
   cCodVol:= cVolume
EndIf

CB6->(DbSetOrder(1))
If ! CB6->(DbSeek(xFilial("CB6")+cCodVol))
	VtAlert("Codigo de volume nao cadastrado "+cCodVol,"Aviso",.t.,4000,3) //###"Codigo de volume nao cadastrado "+cCodVol,"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	return .f.
EndIf
If lEstorna
	If CB6->CB6_STATUS # "5"
		VtAlert("Volume nao embarcado","Aviso",.t.,4000) //### "Volume nao embarcado","Aviso"
		VtKeyboard(Chr(20))  // zera o get
		return .f.
	EndIf
EndIf
CB9->(DbSetOrder(4))
If !CB9->(DbSeek(xFilial("CB9")+cCodVol))
	VtAlert("Volume nao encontrado","Aviso",.t.,4000) //### "Volume nao encontrado","Aviso"
	VtKeyboard(Chr(20))  // zera o get
	return .f.
EndIf
If CB9->CB9_ORDSEP # CB7->CB7_ORDSEP
	VtAlert("Volume pertence a outra ordem de separacao "+CB9->CB9_ORDSEP,"Aviso",.t.,4000,3) //### "Volume pertence a outra ordem de separacao "+CB9->CB9_ORDSEP,"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	return .f.
EndIf
If lEstorna
	IF ! VtYesNo("Confirma o estorno?","Aviso",.t.) //### "Confirma o estorno?","Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
Else
	IF CB9->CB9_STATUS =="3"
		VtAlert("Volume ja lido","Aviso",.t.,4000,3) //### "Volume ja lido","Aviso"
		VtKeyboard(Chr(20))  // zera o get
		return .f.
	EndIf
EndIf

CB9->(DbSetOrder(2))
CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP+cCodVol))
While CB9->(! EOF() .and. CB9_FILIAL+CB9_ORDSEP+CB9_VOLUME == ;
	xFilial("CB9")+cOrdSep+cCodVol)
	RecLock("CB9")
	If lEstorna
		CB9->CB9_QTEEBQ := 0.00
		CB9->CB9_STATUS := "2"  // EMBALAGEM FINALIZADA
	Else
		CB9->CB9_QTEEBQ := CB9->CB9_QTESEP
		CB9->CB9_STATUS := "3"  // EMBARCADO
	EndIf
	CB9->(MsUnLock())
	CB9->(DBSkip())
End
RecLock("CB6")
If lEstorna
	If CBAntProc(CB7->CB7_TIPEXP,"06*") == "7"
		CB6->CB6_STATUS := "3"   // VOLUME ENCERRADO
	Else
		CB6->CB6_STATUS := "1"   // VOLUME EM ABERTO
	EndIf		
	CB6->CB6_CODEB1 := ""
	CB6->CB6_CODEB2 := ""
Else
	CB6->CB6_STATUS := "5"   // EMBARQUE
	CB6->CB6_CODEB1 := cCodOpe
	CB6->CB6_CODEB2 := cCodOpe
EndIf
CB6->(MsUnlock())
VtKeyboard(Chr(20))  // zera o get
Return ! lEstorna

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³  VldQtde ³ Autor ³ ACD                   ³ Data ³ 09/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validacao da quantidade informada                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAACD															        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldQtde(nQtde,lSerie)
Local   lRet := .T.
Default lSerie:=.F.

If nQtde <= 0
   Return .F.
Endif
If lSerie .and. nQtde > 1
   VTAlert("Quantidade invalida !","Aviso",.T.,2000,3) //###  "Quantidade invalida !""Aviso"
   VTAlert("Quando se utiliza numero de serie a quantidade deve ser == 1","Aviso",.T.,4000) //### "Quando se utiliza numero de serie a quantidade deve ser == 1","Aviso"
   Return .F.
Endif

If Existblock("ACD175QTD") 
	lRet:=ExecBlock("ACD175QTD",.F.,.F.,{nQtde})
	If ValType(lRet) == "L"
	   	Return lRet
   	EndIf
EndIf 
 	
Return .T.



/*/{Protheus.doc} VldProdEbq
Validacao do Produto no embarque e no estorno do embarque
@type function
@version 20250726  
@author dener.lemos@dothink.com.br
@since 26/07/2025
@param cEProduto, character, codigo do produto
@param nQtde, numeric, quantidade multiplicadora
@param lEstorna, logical, indica se eh estorno
@return logical, retorno da validacao
/*/
Static Function VldProdEbq(cEProduto,nQtde,lEstorna)
Local cTipo
Local aEtiqueta,aRet
Local aCB9Atu  := {}
Local aItensPallet := CBItPallet(cEProduto)
Local cLote    := Space(TamSX3("B8_LOTECTL")[1])
Local cSLote   := Space(TamSX3("B8_NUMLOTE")[1])
Local cNumSer  := Space(TamSX3("BF_NUMSERI")[1])
Local cProduto := ""
Local cFilCB9  := xFilial("CB9")
Local nTamVol  := TamSX3("CB9_VOLUME")[1]
Local nQE      := 0
Local nQEConf  := 0
Local nQtdBaixa:= 0
Local nX       := 1
Local nSaldoEmb:= 0
Local nSaldoEtq:= 0
Local lACD175VE:= ExistBlock("ACD175VE")
Local lIsPallet:= .F.
Local lFirst   := .T.
Local lChkqemb := SuperGetMV("MV_CHKQEMB",.F.,"1") == "1"

Default lEstorna := .F.

If !CBLoad128(@cEProduto)
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf

If Len(aItensPallet) > 0 .And. UsaCB0("01")
	lIsPallet := .T.
EndIf

cTipo := CBRetTipo(cEProduto)
If cTipo == "01"
	aEtiqueta:= CBRetEti(cEProduto,"01") 
	If lACD175VE
		aEtiqueta:=ExecBlock('ACD175VE',,,{aEtiqueta,"01"})
	EndIf		
	If Empty(aEtiqueta)
		VtAlert("Etiqueta invalida","Aviso",.t.,4000,3) //### "Etiqueta invalida","Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	If !Empty(aEtiqueta[21])
		VtAlert("Etiqueta invalida, produto pertence a um pallet","Aviso",.t.,4000,3) //### "Etiqueta invalida, produto pertence a um pallet" "AVISO"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	CB9->(DbSetorder(1))
	If ! CB9->(DbSeek( cFilCB9 + cOrdSep + CB0->CB0_CODETI ))
		VtAlert("Produto nao separado","Aviso",.t.,4000,3) //### "Produto nao separado" "AVISO"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	
	nSaldoEtq := aEtiqueta[2]
	While !CB9->(EOF()) .And. CB9->(CB9_FILIAL+CB9_ORDSEP+CB9_CODETI) == cFilCB9+cOrdSep+CB0->CB0_CODETI

		cProduto	:= aEtiqueta[1]		
		nQE     	:= IIF(nSaldoEtq > CB9->CB9_QTESEP,CB9->CB9_QTESEP,nSaldoEtq)
		nSaldoEtq 	-= nQE
		
		cLote   	:= aEtiqueta[16]
		cSLote  	:= aEtiqueta[17]
		nQEConf 	:= nQE
		If ! CBProdUnit(aEtiqueta[1]) .and. lChkqemb
			nQEConf := CBQtdEmb(aEtiqueta[1])
		EndIf
		If Empty(nQEConf) .or. nQE # nQEConf
			VtAlert("Quantidade invalida","Aviso",.t.,4000,3) //### "Quantidade invalida""Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .f.
		EndIf
		If lEstorna
			If CB9->CB9_STATUS == "1"  // STATUS=1 (EM ABERTO)
				VtAlert("Produto nao embarcado","Aviso",.t.,4000,3) //### "Produto nao embarcado","Aviso"
				VtKeyboard(Chr(20))  // zera o get
				Return .f.
			EndIf
			If ! VtYesNo("Confirma o estorno?","Aviso",.t.) //### "Confirma o estorno?","Aviso"
				VtKeyboard(Chr(20))  // zera o get
				Return .F.
			EndIf
		Else
			If CB9->CB9_STATUS # "1"  // STATUS=1 (EM ABERTO)
				VtAlert("Produto ja embarcado","Aviso",.t.,4000,3) //### "Produto ja embarcado","Aviso"
				VtKeyboard(Chr(20))  // zera o get
				Return .f.
			EndIf
		EndIf
		aAdd(aCB9Atu,{CB9->(Recno()),nQE})
		
		CB9->(dbSkip())
	End
	For nX := 1 To Len(aCB9Atu)
		CB9->(dbGoTo(aCB9Atu[nX,1]))
		RecLock("CB9",.F.)
		If lEstorna
			CB9->CB9_QTEEBQ := 0
			CB9->CB9_STATUS := "1"  // em aberto
		Else
			CB9->CB9_QTEEBQ += aCB9Atu[nX,2]
			CB9->CB9_STATUS := "3"  // embarcado
		EndIf
		CB9->(MsUnlock())
	Next nX

ElseIf cTipo $ "EAN8OU13-EAN14-EAN128"
	aRet     := CBRetEtiEan(cEProduto)
	If lACD175VE
		aRet:=ExecBlock('ACD175VE',,,{aRet,"01"})
	Endif	
	If Empty(aRet)
		VtAlert("Etiqueta invalida","Aviso",.t.,4000,3) //### "Etiqueta invalida","Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	cProduto := aRet[1]
	If ! CBProdUnit(cProduto)
		VtAlert("Etiqueta invalida","Aviso",.t.,4000,3)  //### "Etiqueta invalida","Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	
	If cTipo $ "EAN8OU13"
		nQE  := aRet[2] * nQtde
	Else
		nQE  := CBQtdEmb(cProduto)*nQtde
	EndIf	
	
	If Empty(nQE)
		VtAlert("Quantidade invalida","Aviso",.t.,4000,3) //### "Quantidade invalida" "Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	cLote := aRet[3]
	If ! CBRastro(aRet[1],@cLote,@cSLote)
		VTKeyBoard(chr(20))
		Return .f.
	EndIf   
	cNumSer:= aRet[5]
	If Empty(cNumSer) .and. CBSeekNumSer(cOrdSep,cProduto)
      If ! VldQtde(nQtde,.T.)
         VtKeyboard(Chr(20))  // zera o get
		   Return .F.
      Endif
      If ! CBNumSer(@cNumSer)
         VTKeyBoard(chr(20))
         Return .f.
      EndIf
   EndIf
	CB9->(DbSetorder(8))
	If ! CB9->(DBSeek(xFilial("CB9")+cOrdSep+cProduto+cLote+cSLote+cNumSer+ Space(nTamVol)))
		VtAlert("Produto invalido","Aviso",.t.,4000,3)
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	nSaldoEmb:=0
	While CB9->(! EOF() .AND. CB9_FILIAL+CB9_ORDSEP+CB9_PROD+CB9_LOTECT+CB9_NUMLOT+CB9_VOLUME ==;
		xFilial("CB9")+cOrdSep+cProduto+cLote+cSLote+space(nTamVol))
		If lEstorna
			nSaldoEmb += CB9->CB9_QTEEBQ
		Else
			nSaldoEmb += CB9->CB9_QTESEP-CB9->CB9_QTEEBQ
		EndIf
		CB9->(DbSkip())
	Enddo
	If nQE > nSaldoEmb
		VtBeep(3)
		If lEstorna
			VtAlert("Quantidade informada maior que a quantidade embarcada","Aviso",.t.,4000)
		Else
			VtAlert("Quantidade informada maior que disponivel para o embarque","Aviso",.t.,4000)
		EndIf
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	If lEstorna
		If ! VtYesNo("Confirma o estorno?","Aviso",.t.) 
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		EndIf
	EndIf
	
	nSaldoEmb := nQE
	nQtdBaixa := 0

	CB9->(DbSetorder(8))
	CB9->(DBSeek(xFilial("CB9")+cOrdSep+cProduto+cLote+cSLote+cNumSer+space(nTamVol)))
	While CB9->(! EOF() .AND. CB9_FILIAL+CB9_ORDSEP+CB9_PROD+CB9_LOTECT+CB9_NUMLOT+CB9_VOLUME ==;
		xFilial("CB9")+cOrdSep+cProduto+cLote+cSLote+space(nTamVol)) .and. ! Empty(nSaldoEmb)
		If lEstorna
			If Empty(CB9->CB9_QTEEBQ)
				CB9->(DBSkip())
				Loop
			EndIf
		Else
			If CB9->CB9_STATUS == '3'
				CB9->(DBSkip())
				Loop
			EndIf
		EndIf
		nQtdBaixa := nSaldoEmb
		If lEstorna
			If nSaldoEmb >= CB9->CB9_QTEEBQ
				nQtdBaixa := CB9->CB9_QTEEBQ
			EndIf
		Else
			If nSaldoEmb >= (CB9->CB9_QTESEP-CB9->CB9_QTEEBQ)
				nQtdBaixa := (CB9->CB9_QTESEP-CB9->CB9_QTEEBQ)
			EndIf
		EndIf
		RecLock("CB9")
		If lEstorna
			CB9->CB9_QTEEBQ -=nQtdBaixa
			CB9->CB9_STATUS := "1"  // em aberto
		Else
			CB9->CB9_QTEEBQ +=nQtdBaixa
			If CB9->CB9_QTEEBQ == CB9->CB9_QTESEP
				CB9->CB9_STATUS := "3"  // embarcado
			EndIf
		EndIf
		CB9->(MsUnlock())
		nSaldoEmb -=nQtdBaixa
		CB9->(DbSkip())
	Enddo
ElseIf lIsPallet
	Begin Transaction
	For nX:= 1 to Len(aItensPallet)
		cEProduto := aItensPallet[nX]
		aEtiqueta := CBRetEti(cEProduto,"01") 
		If lACD175VE
			aEtiqueta:=ExecBlock('ACD175VE',,,{aEtiqueta,"01"})
		EndIf		
		If Empty(aEtiqueta)
			VtAlert("Etiqueta invalida","Aviso",.t.,4000,3) //### "Etiqueta invalida","Aviso"
			VtKeyboard(Chr(20))  // zera o get
			DisarmTransaction()
			Break
		EndIf
		CB9->(DbSetorder(1))
		If ! CB9->(DbSeek(xFilial("CB9")+cOrdSep+Left(cEProduto,10)))
			VtAlert("Produto nao separado","Aviso",.t.,4000,3) //### "Produto nao separado" "AVISO"
			VtKeyboard(Chr(20))  // zera o get
			DisarmTransaction()
			Break
		EndIf
		cProduto:= aEtiqueta[1]
		nQE     := aEtiqueta[2]
		cLote   := aEtiqueta[16]
		cSLote  := aEtiqueta[17]
		nQEConf := nQE
		If ! CBProdUnit(aEtiqueta[1]) .and. lChkqemb
			nQEConf := CBQtdEmb(aEtiqueta[1])
		EndIf
		If Empty(nQEConf) .or. nQE # nQEConf
			VtAlert("Quantidade invalida","Aviso",.t.,4000,3) //### "Quantidade invalida""Aviso"
			VtKeyboard(Chr(20))  // zera o get
			DisarmTransaction()
			Break
		EndIf
		If lEstorna
			If CB9->CB9_STATUS == "1"  // STATUS=1 (EM ABERTO)
				VtAlert("Embarcar Produto","Aviso",.t.,4000,3) //### "Produto nao embarcado","Aviso"
				VtKeyboard(Chr(20))  // zera o get
				DisarmTransaction()
				Break
			EndIf
			If lFirst
				If ! VtYesNo("Confirma o estorno?","Aviso",.t.) //### "Confirma o estorno?","Aviso"
					VtKeyboard(Chr(20))  // zera o get				
					DisarmTransaction()
					Break
				EndIf
				lFirst := .F.
			EndIf
		Else
			If CB9->CB9_STATUS # "1"  // STATUS=1 (EM ABERTO)
				VtAlert("Embarcar Produto","Aviso",.t.,4000,3) //### "Produto ja embarcado","Aviso"
				VtKeyboard(Chr(20))  // zera o get				
				DisarmTransaction()
				Break
			EndIf
		EndIf
		If lEstorna
			RecLock("CB9")
			CB9->CB9_QTEEBQ := 0.00
			CB9->CB9_STATUS := "1"  // em aberto
			CB9->(MsUnlock())
		Else
			RecLock("CB9")
			CB9->CB9_QTEEBQ += nQE
			CB9->CB9_STATUS := "3"  // embarcado
			CB9->(MsUnlock())
		EndIf
	Next
	End Transaction
	If !(nX > Len(aItensPallet))
		Return .F.
	Endif
Else
	VtAlert("Etiqueta invalida","Aviso",.t.,4000,3) //### "Etiqueta invalida","Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf

nQtde:=1
VTGetRefresh('nQtde')
VtKeyboard(Chr(20))  // zera o get
Return ! lEstorna


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Informa  ³ Autor ³ ACD                   ³ Data ³ 17/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Mostra as etiquetas lidas o tipo e a quantidade das mesmas ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Informa()
Local cPallet                
Local nRecCB9 := CB9->(RecNo())
Local cTipo                       
Local nPos
Local aCab      := {}
Local aSize     := {}
Local aSave     := VTSAVE()              
Local aAreaCB9  := CB9->(GetArea())
Local aEtiqueta := {}
Local aDados    := {}
Local lACD175VE := ExistBlock("ACD175VE")

VTClear()
If UsaCB0("01")
	aCab  := {"Etiqueta","Tipo","Ordem de separação"}
	aSize := {10,10,15}

	CB9->(DbSetOrder(1))
	CB9->(DbSeek(xFilial("CB9")+cOrdSep))
	While CB9->(! Eof() .and. CB9_FILIAL+CB9_ORDSEP == xFilial("CB9")+cOrdSep)
		cTipo     := CBRetTipo(CB9->CB9_CODETI)
		cPallet   := RetPallet(CB9->CB9_CODETI)
		If cTipo == "05" // --> Etiqueta de Volume         
			aadd(aDados, {CB9->CB9_CODETI, "Volume" , CB9->CB9_ORDSEP}) // -> Volume
		Elseif cTipo == "01" .and. Empty(cPallet) // --> Etiqueta de Produto  com CB0	  
			aadd(aDados, {CB9->CB9_CODETI, "Produto", CB9->CB9_ORDSEP}) // "Produto" -> Produto
		Elseif ! Empty(cPallet) // --> Etiqueta de Pallet			 
			aEtiqueta := CBRetEti(CB9->CB9_CODETI)
			If lACD175VE
				aEtiqueta := ExecBlock( 'ACD175VE' ,,,{aEtiqueta      , "01"})
			EndIf
			If Alltrim(CB0->CB0_PALLET) # Alltrim(cPallet)
				CB9->(DbSkip())
				Loop
			Endif
			If ascan(aDados,{|x|x[1] == cPallet})== 0 // Adiciona o Pallet somente uma vez
				aadd(aDados, {cPallet        , "Pallet" , CB9->CB9_ORDSEP}) //
			Endif
		EndIf
		CB9->(DbSkip())
	EndDo
   aDados := aSort(aDados,,,{|x,y| x[2] < y[2]})   
Else
   aCab  := {"Produto","Volume","Qtd.Sep","Qtd.Embq"}  //"Produto","Volume","Qtd.Sep","Qtd.Embq"
   aSize := {15,10,9,9}              
   CB9->(DbSetOrder(12))
   CB9->(DbSeek(xFilial("CB9")+cOrdSep))
   While CB9->(! Eof() .and. CB9_FILIAL+CB9_ORDSEP == xFilial("CB9")+cOrdSep)
   	nPos := AsCan(aDados,{|x| x[1]+x[2]+x[5]==CB9->(CB9_PROD+CB9_VOLUME+CB9_LOCAL+CB9_LCALIZ+CB9_LOTECT+CB9_NUMLOT+CB9_NUMSER)})
   	If Empty(nPos)
			CB9->(aadd(aDados,{CB9_PROD,CB9_VOLUME,CB9_QTESEP,CB9_QTEEBQ,CB9_LOCAL+CB9_LCALIZ+CB9_LOTECT+CB9_NUMLOT+CB9_NUMSER}) )
		Else
			aDados[nPos,3] += CB9->CB9_QTESEP
			aDados[nPos,4] += CB9->CB9_QTEEBQ
		EndIf
   	CB9->(DbSkip())
   EndDo
Endif   
VTaBrowse(0,0,VTMaxRow(),VTMaxCol(),aCab,aDados,aSize)
VtRestore(,,,,aSave)
RestArea(aAreaCB9)
CB9->(DbGoto(nRecCB9))
Return                 



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Estorna  ³ Autor ³ Anderson Rodrigues    ³ Data ³ 15/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Realiza estorno dos volumes embarcados                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Estorna()
Local ckey24  := VTDescKey(24)
Local bkey24  := VTSetKey(24)
Local aTela   := VTSave()
//Local cEtiqueta  
Local cVolume
Local cProduto
Local nQtde
Local lForcaQtd   := GetMV("MV_CBFCQTD",,"2") =="1"     
Local cPictQtdExp := PesqPict("CB8","CB8_QTDORI")
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf
VTSetKey(24,Nil)        

While .t.
	VTClear()           
		If lVT100B // GetMv("MV_RF4X20")
			@ 0,0 VtSay Padc("Estorno do embarque",VTMaxCol())  //->"Estorno do embarque"
			If '01' $ CB7->CB7_TIPEXP .or.; 
			'02' $ CB7->CB7_TIPEXP // trabalha com sub-volume
				cVolume := Space(10)
				@ 02,00 VtSay  "Leia o volume" // "Leia o volume"
				@ 03,00 VtGet cVolume Picture "@!" Valid VldEbqVol(cVolume,.t.)
			Else
				nQtde := 1
				cProduto   := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
				If ! Usacb0("01")
					@ 1,0 VTSay 'Qtde ' VtGet nQtde pict cPictQtdExp valid VldQtde(nQtde,.f.) when (lForcaQtd .or. VTLastkey() == 5) //
				EndIf
				@ 2,0 VtSay  "Embarcar Produto" //"Embarcar Produto"->Embarcar Produto
				@ 3,0 VTGet cProduto pict '@!' VALID VTLastkey() == 5 .or. VldProdEbq(cProduto,nQtde,.t.)
			EndIf
		ElseIf VtModelo()=="RF"
		@ 0,0 VtSay Padc("Estorno do embarque",VTMaxCol())  // "Estorno do embarque"->"Estorno do embarque"
		If '01' $ CB7->CB7_TIPEXP .or. '02' $ CB7->CB7_TIPEXP // trabalha com sub-volume
			cVolume := Space(10)
			@ 06,00 VtSay  "Leia o volume" // "Leia o volume"
			@ 07,00 VtGet cVolume Picture "@!" Valid VldEbqVol(cVolume,.t.)
		Else
			nQtde := 1
			cProduto   := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
			If ! Usacb0("01")
				@ 4,0 VTSay 'Qtde ' VtGet nQtde pict cPictQtdExp valid VldQtde(nQtde,.f.) when (lForcaQtd .or. VTLastkey() == 5) //
			EndIf
			@ 5,0 VTSay  "Leia o produto" // 'Leia o produto' 
			@ 6,0 VtSay  "a embarcar" // 'a embarcar' 
			@ 7,0 VTGet cProduto pict '@!' VALID VTLastkey() == 5 .or. VldProdEbq(cProduto,nQtde,.t.)						
		EndIf
	ElseIf VtModelo()=="MT44" 
		If '01' $ CB7->CB7_TIPEXP .or. '02' $ CB7->CB7_TIPEXP // trabalha com sub-volume
			cVolume := Space(10)                                                            
			@ 0,0 VtSay Padc("Estorno do embarque",VTMaxCol()) // "Estorno do embarque"->"Estorno do embarque"
			@ 1,00 VtSay "Leia o volume" VtGet cVolume Picture "@!" Valid VldEbqVol(cVolume,.t.) // "Leia o volume"
		Else         
			nQtde := 1   
			cProduto   := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
			If Usacb0("01")       
			   @ 0,0 VtSay Padc("Estorno do embarque",VTMaxCol())// "Estorno do embarque"->"Estorno do embarque"
			Else
				@ 0,0 VTSay 'Estorno: Qtde ' VtGet nQtde pict cPictQtdExp valid VldQtde(nQtde,.f.) when (lForcaQtd .or. VTLastkey() == 5) //
			EndIf
			@ 1,0 VTSay "Produto" VTGet cProduto pict '@!' VALID VTLastkey() == 5 .or. VldProdEbq(cProduto,nQtde,.T.) // ""Produto" ->Produto"
		EndIf           
	ElseIf VtModelo()=="MT16"	
		If '01' $ CB7->CB7_TIPEXP .or. '02' $ CB7->CB7_TIPEXP // trabalha com sub-volume
			cVolume := Space(10)                                 
			@ 0,0 VtSay Padc("Estorno do embarque",VTMaxCol())	// "Estorno do embarque"->"Estorno do embarque"		
			@ 1,0 VtSay "Volume" VtGet cVolume Picture "@!" Valid VldEbqVol(cVolume,.t.) //"Volume" ->"Volume"
		Else         
			nQtde := 1   
			cProduto   := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
			If  Usacb0("01")
				@ 0,0 VtSay Padc("Estorno do embarque",VTMaxCol())	// "Estorno do embarque"->"Estorno do embarque"			
			Else
				@ 0,0 VTSay 'Est.Qtde ' VtGet nQtde pict cPictQtdExp valid VldQtde(nQtde,.f.) when (lForcaQtd .or. VTLastkey() == 5) //
			EndIf
			@ 1,0 VTSay "Produto" VTGet cProduto pict '@!' VALID VTLastkey() == 5 .or. VldProdEbq(cProduto,nQtde,.T.) //"Produto" -> Produto
		EndIf           
	EndIf
	VtRead
	If VtLastKey() == 27	
		Exit
	EndIf
	//Se nao existir mais nenhum produto embarcado para esta ordem
	//de separacao aborta estorno
	CB9->(DbSetOrder(5))
	If ! CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP+"3"))
		Exit
	EndIF
EndDo

VTRestore(,,,,aTela)
VTSetKey(24,bkey24,cKey24)        
Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³RetPalletCB9³ Autor ³ ACD                 ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Verifica se existe o Pallet para a etiqueta informada       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function RetPallet(cEtiqueta)
Local cPallet:= " "
Local aArea  := CB0->(GetArea())

If ! UsaCB0("01") .or. Empty(cEtiqueta)
   Return(cPallet)
EndIf

CB0->(DbSetOrder(1))
If CB0->(DbSeek(xFilial("CB0")+cEtiqueta)) 
   cPallet:= CB0->CB0_PALLET
EndIf
RestArea(aArea)
Return(cPallet)


//--
Static Function SetTraking(cOpc, cTitLog)
    local aArea   := GetArea()
	local aASC5   := SC5->( GetArea() )
    local aTrackS := {}
    local nRecPos := CB7->( Recno() )
    local cChave  := CB7->( CB7_FILIAL + CB7_PEDIDO )
	//local cTransp := ""
	//local cEmail  := ""

	DbSelectArea("SC5")
	SC5->( DbSetOrder(1) )
    If SC5->( DbSeek( cChave ) )
		RecLock("SC5", .f.)
		If cOpc == "1"
			SC5->C5_X4SSTAT := "4" // Em Transito
		ElseIf cOpc == "2"
			SC5->C5_X4SSTAT := "2" // Em Faturamento
		EndIf

		//Grava o campo C5_MSEXP para sinalizaro ao Scheduler
		SC5->C5_MSEXP:=   ""  //DToS(dDataBase)
		SC5->( MsUnLock() )

		DbSelectAre("Z09")
		Z09->( DbSetOrder(3) )

		If Z09->( DbSeek(cChave) )
			aTrackS := Array( Len( Z09->( DbStruct() ) ) )

			//Atualiza, também, no alias temporário para atualização do status
			While Z09->( !Eof() .And. Z09_FILIAL + Z09_NUMPV == cChave)

				aTrackS[Z09->(FieldPos("Z09_FILIAL"))]  := xFilial("SC5")
				aTrackS[Z09->(FieldPos("Z09_NUMPV")) ]  := Z09->Z09_NUMPV                   // Pedido Venda
				aTrackS[Z09->(FieldPos("Z09_ITEMPV"))]  := Z09->Z09_ITEMPV                  // Item PV
				If cOpc == "1"
					aTrackS[Z09->(FieldPos("Z09_STATUS"))]  := "8"							// Status "Em Transito"
					aTrackS[Z09->(FieldPos("Z09_DTPEMB"))]  := dDataBase	
					aTrackS[Z09->(FieldPos("Z09_HRPEMB"))]  := Time()
				ElseIf cOpc == "2"
					aTrackS[Z09->(FieldPos("Z09_STATUS"))]  := "6"							// Status "Em Faturamento"
					aTrackS[Z09->(FieldPos("Z09_DTPEMB"))]  := CTOD("")	
					aTrackS[Z09->(FieldPos("Z09_HRPEMB"))]  := Space(5)
				EndIf
				
				u_TRK006S(aTrackS, cTitLog)

				Z09->( DbSkip() )
			End
		EndIf
		
		CB7->( DbGoto(nRecPos) )
	EndIf

	/*If !Empty(cTransp)
		DbSelectAre("Z09")
		Z09->( DbSetOrder(3) )

		If Z09->( DbSeek(cChave) )
			cEmail := Posicione("SA4", 1, FWxFilial('SA4') + cTransp, "A4_EMAIL")
			cEmail := "erike.yuri@dothink.com.br;janine.duarte@barentz.com;"
			u_TRK0012(cEmail, "Agendamento")
		EndIf
	EndIf*/

	RestArea(aASC5)
    RestArea(aArea)

Return
