#include "totvs.ch"
#include "topconn.ch"


/*/{Protheus.doc} TRK0016
Rotina de exportacao de planilha de controle de expedicao de terceiros, atraves da ordem de separacao gerada na Barentz
@type function
@version 1.0
@author dener.lemos@dothink.com.br
@since 27/08/2025
/*/
User Function TRK0016()
	Local nOpcAviso := 0
	Local cMsg      := ""
 
	cMsg := "Esse programa tem como objetivo exportar ou importar arquivo de integração com Armazens de Terceiros."

	//Mensagem média com botões
	nOpcAviso := Aviso("Integração Armazém de Terceiro", cMsg, {"Exportar", "Importar", "Fechar"}, 2, "Exportação/Importação Excel")

	DO CASE
		CASE nOpcAviso == 1
			u_TRK0016E()
		CASE nOpcAviso == 2
			u_TRK0016I()		
	END CASE


Return


User Function TRK0016E()
	Local aArea  := GetArea()
	Local aPergs := {}
	Local xPar0  := Space(6)
	Local xPar1  := Replicate("Z", Len(CB7->CB7_PEDIDO))
	Local xPar2	 := "19"

	If FWCodFil() == "05"
		xPar2 := "02"
	EndIf
	
	aAdd(aPergs, {1, "Pedido De" , xPar0, "", ".T.", "CB7", ".T.", 80,  .F.})
	aAdd(aPergs, {1, "Pedido Ate", xPar1, "", ".T.", "CB7", ".T.", 80,  .T.})
	aAdd(aPergs, {1, "Armazém"   , xPar2, "", ".T.", "NNR", ".F.", 30,  .T.})
	
	If ParamBox(aPergs, "Gerar Planilha Armazém Terceiro", /*aRet*/, /*bOk*/, /*aButtons*/, /*lCentered*/, /*nPosx*/, /*nPosy*/, /*oDlgWizard*/, /*cLoad*/, .F., .F.)
		Processa({|| GeraExcel()})
	EndIf
	
	RestArea(aArea)

Return


/*/{Protheus.doc} GeraExcel
Rotina de criacao do arquivo Excel da funcao TRK0016
@type function
@version 1.0
@author dener.lemos@dothink.com.br
@since 27/08/2025
/*/
Static Function GeraExcel()
	Local oPrintXlsx
	Local oExcel	
	Local aArea       := GetArea()
	Local dData       := Date()
	Local cHora       := Time()
	Local cArquivo    := GetTempPath() + "TRK0016" + dToS(dData) + "_" + StrTran(cHora, ":", "-") + ".rel"
	Local cQuery      := ""
	Local nAtual      := 0
	Local nTotal      := 0
	Local cFonte      := FwPrinterFont():Arial()
	Local nTamFonte   := 12
	Local lItalico    := .F.
	Local lNegrito    := .T.
	Local lSublinhado := .F.
	Local nCpoAtual   := 0
	Local oCellHoriz  := FwXlsxCellAlignment():Horizontal()
	Local oCellVerti  := FwXlsxCellAlignment():Vertical()
	Local cHorAlinha  := ""
	Local cVerAlinha  := ""
	Local lQuebrLin   := .F.
	Local nRotation   := 0
	Local cCustForma  := ""
	Local cCampoAtu   := ""
	Local cTipo       := ""
	Local cCorFundo   := ""
	Local cCorPreto   := "000000"
	Local cCorBranco  := "FFFFFF"
	Local cCorTxtCab  := "000000"
	Local cCorFunPad  := "EDEDED"
	Local cHoje		  := dtos( date() )

	Private aColunas  := {}

    //-- Consulta
    cQuery := " SELECT CB8_FILIAL, CB8_PEDIDO, CB8_ITEM, CB8_PROD, CB8_QTDORI, C6_LOTECTL, CB8_LOTECT, '' LOTE_LIDO, " + CRLF
    cQuery += " Z09_DVIFIS, Z09_HVIFIS, Z12_QTESEP, Z09_UVIFIS, " + CRLF
    cQuery += " Z09_DTEXPE, Z09_HREXPE, CB9_QTESEP, " + CRLF
    cQuery += " Z09_DTPEMB, Z09_HRPEMB, CB9_QTEEBQ, " + CRLF
    cQuery += " Z09_NF, Z09_SERIE, Z09_CHVNFE, C6_ENTREG, CB8_LOCAL, CB8_OCOSEP, " + CRLF
	cQuery += " Z09_DTEMNF, (CASE WHEN Z09_DTSLA < '"+cHoje+"' THEN '"+cHoje+"' ELSE Z09_DTSLA END) AS Z09_DTSLA, Z09_DC1COL, Z09_NTRANS, " + CRLF
	cQuery += " Z09_DVFISI, Z09_HVFISI, Z09_MOTIVO, "
	cQuery += " Z12TRB.* "+ CRLF
    cQuery += " FROM " + RetSQLName("CB8") + " CB8 " + CRLF
    cQuery += " INNER JOIN " + RetSQLName("SC6") + " SC6 " + CRLF
    cQuery += " ON C6_FILIAL = CB8_FILIAL " + CRLF
    cQuery += " AND C6_NUM = CB8_PEDIDO " + CRLF
    cQuery += " AND C6_ITEM = CB8_ITEM " + CRLF
    cQuery += " AND SC6.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += " JOIN " + RetSQLName("Z09") + " Z09 " + CRLF
    cQuery += " ON Z09_FILIAL = CB8_FILIAL " + CRLF
    cQuery += " AND Z09_NUMPV = CB8_PEDIDO " + CRLF
    cQuery += " AND Z09_ITEMPV = CB8_ITEM " + CRLF
	cQuery += " AND Z09_STATUS < '8' " + CRLF
    cQuery += " AND Z09.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += " LEFT JOIN ( SELECT Z12_FILIAL, Z12_PEDIDO, Z12_ITESEP, Z12_LOTECT, SUM(Z12_QTESEP) Z12_QTESEP " + CRLF
    cQuery += "             FROM " + RetSQLName("Z12") + " Z12 " + CRLF
    cQuery += "             WHERE Z12.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "             GROUP BY Z12_FILIAL, Z12_PEDIDO, Z12_ITESEP, Z12_LOTECT) Z12TRB " + CRLF
    cQuery += " ON Z12TRB.Z12_FILIAL = CB8_FILIAL " + CRLF
    cQuery += " AND Z12TRB.Z12_PEDIDO = CB8_PEDIDO " + CRLF
    cQuery += " AND Z12TRB.Z12_ITESEP = CB8_ITEM " + CRLF
    cQuery += " AND Z12TRB.Z12_LOTECT = CB8_LOTECT " + CRLF
    cQuery += " LEFT JOIN ( SELECT CB9_FILIAL, CB9_PEDIDO, CB9_ITESEP, CB9_LOTECT, SUM(CB9_QTESEP) CB9_QTESEP, SUM(CB9_QTEEBQ) CB9_QTEEBQ " + CRLF
    cQuery += "             FROM " + RetSQLName("CB9") + " CB9 " + CRLF
    cQuery += "             WHERE CB9.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "             GROUP BY CB9_FILIAL, CB9_PEDIDO, CB9_ITESEP, CB9_LOTECT) CB9TRB " + CRLF
    cQuery += " ON CB9TRB.CB9_FILIAL = CB8_FILIAL " + CRLF
    cQuery += " AND CB9TRB.CB9_PEDIDO = CB8_PEDIDO " + CRLF
    cQuery += " AND CB9TRB.CB9_ITESEP = CB8_ITEM " + CRLF
    cQuery += " AND CB9TRB.CB9_LOTECT = CB8_LOTECT " + CRLF
    cQuery += " WHERE CB8_FILIAL = '" + xFilial("CB8") + "' " + CRLF
    cQuery += " AND CB8_PEDIDO >= '" + mv_par01 + "' " + CRLF
    cQuery += " AND CB8_PEDIDO <= '" + mv_par02 + "' " + CRLF
	cQuery += " AND CB8_LOCAL  = '" + mv_par03 + "' " + CRLF
    cQuery += " AND CB8.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += " ORDER BY " + SqlOrder(CB8->(IndexKey(2)))

    cQuery := ChangeQuery(cQuery)
    TCQUERY cQuery New Alias "_QRY"

	dbSelectArea("_QRY")
	
	If !_QRY->(EoF())
		//-- Tamanho da regua
		Count To nTotal
		ProcRegua(nTotal)
		_QRY->(DbGoTop())

		//-- Mapeamento de campos:
		//-- [1] Nome do Campo
		//-- [2] Tipo do Campo
		//-- [3] Título a ser exibido
		//-- [4] Largura em pixels, sendo que o ideal é o tamanho do campo * 1.5 (se o campo for muito pequeno, considere o tamanho minimo como 10 * 1.5)
		//-- [5] Alinhamento (0 = esquerda, 1 = direita, 2 = centralizado)
		//-- [6] Máscara aplicada em campos numéricos
		aColunas := RetColunas()

		oPrintXlsx := FwPrinterXlsx():New()
		If oPrintXlsx:Activate(cArquivo)
			oPrintXlsx:AddSheet("EXPEDICAO TERCEIROS")

			nTamFonte := 10
			lNegrito  := .F.
			oPrintXlsx:SetFont(cFonte, nTamFonte, lItalico, lNegrito, lSublinhado)
			
			cHorAlinha  := oCellHoriz:Center()
			cVerAlinha  := oCellVerti:Center()
			oPrintXlsx:SetCellsFormat(cHorAlinha, cVerAlinha, lQuebrLin, nRotation, cCorTxtCab, cCorBranco, cCustForma)

			nLinExcel := 1
			For nAtual := 1 To Len(aColunas)
				oPrintXlsx:SetColumnsWidth(nAtual, nAtual, aColunas[nAtual][4])
				oPrintXlsx:SetText(nLinExcel, nAtual, aColunas[nAtual][3])
			Next

			oPrintXlsx:ApplyAutoFilter(nLinExcel, 1, nLinExcel, Len(aColunas))
			
			nAtual := 0
			While !(_QRY->(EoF()))
				nAtual++
				IncProc('Adicionando registro ' + cValToChar(nAtual) + ' de ' + cValToChar(nTotal) + '...')

				If nAtual % 2 != 0
					cCorFundo := cCorFunPad
				Else
					cCorFundo := cCorBranco
				EndIf

				nLinExcel++

				For nCpoAtual := 1 To Len(aColunas)
					cCampoAtu := aColunas[nCpoAtual][1]
					cTipo     := aColunas[nCpoAtual][2]
					xConteud  := &("_QRY->" + cCampoAtu)

					If cTipo == "D"
						If Empty(xConteud)
							xConteud := Alltrim(xConteud)
						Else
							xConteud := DTOC(STOD(xConteud))
						EndIf
					ElseIf cTipo == "N"
						If ! Empty(aColunas[nCpoAtual][6])
							xConteud := Alltrim(Transform(xConteud, aColunas[nCpoAtual][6]))
						Else
							xConteud := cValToChar(xConteud)
						EndIf
					Else
						xConteud := Alltrim(xConteud)
					EndIf

					If aColunas[nCpoAtual][5] == 1
						cHorAlinha := oCellHoriz:Right()
					ElseIf aColunas[nCpoAtual][5] == 2
						cHorAlinha := oCellHoriz:Center()
					Else
						cHorAlinha := oCellHoriz:Left()
					EndIf

					oPrintXlsx:ResetCellsFormat()
					oPrintXlsx:SetCellsFormat(cHorAlinha, cVerAlinha, lQuebrLin, nRotation, cCorPreto, cCorFundo, cCustForma)
					oPrintXlsx:SetText(nLinExcel, nCpoAtual, xConteud)
				Next
				
				_QRY->(DbSkip())
			EndDo

			oPrintXlsx:ToXlsx()
			oPrintXlsx:DeActivate()

			cArquivo := ChgFileExt(cArquivo, '.xlsx')
			If File(cArquivo)
				oExcel := MsExcel():New()
				oExcel:WorkBooks:Open(cArquivo)
				oExcel:SetVisible(.T.)
				oExcel:Destroy()
			EndIf
		EndIf
	Else
		FWAlertError('Não foi encontrado registros com os filtros informados!', 'Falha')
	EndIf

	_QRY->(DbCloseArea())
	
	RestArea(aArea)

Return


//-- Função que realiza a leitura de um XLS convertendo ele para CSV para importar os dados (como se fosse um CSV)
User Function TRK0016I()
    Local aAreaAnt := GetArea()
    Local cArqSel  := ""
	Local aPergs   := {}
	Local cArquivo := Space(200)

    Private cArqCSV := ""
  
	aAdd(aPergs, {6,"Arquivo",cArquivo,"","","",80,.F.,"Todos os arquivos (*.xlsx) |*.*"})
	If ParamBox(aPergs, "Informe o arquivo", /*aRet*/, /*bOk*/, /*aButtons*/, /*lCentered*/, /*nPosx*/, /*nPosy*/, /*oDlgWizard*/, /*cLoad*/, .F., .F.)
		cArqSel := AllTrim(MV_PAR01)
		If !Empty(cArqSel) .And. File(cArqSel)
			FWMsgRun(NIL,{|| ProcCSV(cArqSel)  },"Aguarde...","Convertendo e importando")
		EndIf

	EndIf
    RestArea(aAreaAnt)

Return

Static Function ProcCSV(cArqSel, nTipo)
	local nI     := 0
	local nCount := 0
	Default nTipo := 1

	cArqCSV := XLStoCSV(cArqSel)

	For nI:=1 To 40
		nCount++
		Sleep(500)
		If File(cArqCSV)
			Exit
		EndIf
	Next nI

	If File(cArqCSV)
		Processa({|| Importa(cArqCSV, nTipo) }, "Importando...")
	EndIf
Return


//-- Funcao que processa o arquivo e realiza a importação para o sistema
Static Function Importa(cArqSel, nTipo)
    Local oArquivo
    Local cDirTmp    := GetTempPath()
    Local cArqLog    := "importacao_" + dToS(Date()) + "_" + StrTran(Time(), ":", "-") + ".log"
    Local nI         := 0
	Local nTotLinhas := 0
    Local cLinAtu    := ""
    Local nLinhaAtu  := 0
    Local aLinha     := {}
    Local cLog       := ""
	Local cSeparador := ","
	Private aColunas := RetColunas(nTipo)
	Private aErros   := {}

    //Definindo o arquivo a ser lido
    oArquivo := FWFileReader():New(cArqSel)
 
    //Se o arquivo pode ser aberto
    If (oArquivo:Open())
 
        //Se não for fim do arquivo
        If ! (oArquivo:EoF())      

		    //Definindo o tamanho da régua
            aLinhas    := oArquivo:GetAllLines()
            nTotLinhas := Len(aLinhas)
            ProcRegua(nTotLinhas)
 
            //Método GoTop não funciona (dependendo da versão da LIB), deve fechar e abrir novamente o arquivo
            oArquivo:Close()
            oArquivo := FWFileReader():New(cArqSel)
            oArquivo:Open()
 
            //Iniciando controle de transação
            Begin Transaction
 
                //Enquanto tiver linhas
                While (oArquivo:HasLine())
 
                    //Incrementa na tela a mensagem
                    nLinhaAtu++
                    IncProc("Importando linha " + cValToChar(nLinhaAtu) + " de " + cValToChar(nTotLinhas) + "...")
 
                    //Pegando a linha atual e transformando em array
                    cLinAtu := oArquivo:GetLine()
                    aLinha  := Separa(cLinAtu, cSeparador)

					If nLinhaAtu == 1
						Loop
					EndIf

                    //Se houver posições no array
                    If Len(aLinha) > 0
						If nTipo == 1
							SetTraking(aLinha, "Planilha Terceiros - ", nLinhaAtu)
						ElseIf nTipo == 2
							SetDtRealT(aLinha, "Planilha Entrega - Pedido Entregue", nLinhaAtu)
						EndIf
                    EndIf

                EndDo
            End Transaction

			cLog := ""
			For nI:=1 To Len(aErros)
				cLog += "Linha:" + StrZero(aErros[nI,1], 3) + ", " + aErros[nI,2] + CRLF
			Next nI

            //Se tiver log, mostra ele
            If !Empty(cLog)
                MemoWrite(cDirTmp + cArqLog, cLog)
                ShellExecute('OPEN', cArqLog, '', cDirTmp, 1)
            EndIf
 
        Else
            MsgStop('Arquivo não tem conteúdo!', 'Atenção')
        EndIf
 
        //Fecha o arquivo
        oArquivo:Close()
    Else
        MsgStop('Arquivo não pode ser aberto!', 'Atenção')
    EndIf
 
Return
 

//Essa função foi baseada como referência no seguinte link: https://stackoverflow.com/questions/1858195/convert-xls-to-csv-on-command-line
Static Function XLStoCSV(cArqXLS)
    Local cArqCSV    := ""
    Local cDirTemp   := GetTempPath()
    Local cArqScript := cDirTemp + "XlsToCsv.vbs"
    Local cScript    := ""
    Local cDrive     := ""
    Local cDiretorio := ""
    Local cNome      := ""
    Local cExtensao  := ""
 
    //Monta o Script para converter
    cScript := 'if WScript.Arguments.Count < 2 Then' + CRLF
    cScript += '    WScript.Echo "Error! Please specify the source path and the destination. Usage: XlsToCsv SourcePath.xls Destination.csv"' + CRLF
    cScript += '    Wscript.Quit' + CRLF
    cScript += 'End If' + CRLF
    cScript += 'Dim oExcel' + CRLF
    cScript += 'Set oExcel = CreateObject("Excel.Application")' + CRLF
    cScript += 'Dim oBook' + CRLF
    cScript += 'Set oBook = oExcel.Workbooks.Open(Wscript.Arguments.Item(0))' + CRLF
    cScript += 'oBook.SaveAs WScript.Arguments.Item(1), 6' + CRLF
    cScript += 'oBook.Close False' + CRLF
    cScript += 'oExcel.Quit' + CRLF
    MemoWrite(cArqScript, cScript)
 
    //Pega os detalhes do arquivo original em XLS
    SplitPath(cArqXLS, @cDrive, @cDiretorio, @cNome, @cExtensao)
 
    //Monta o nome do CSV, conforme os detalhes do XLS
    cArqCSV := cDrive + cDiretorio + cNome + ".csv"

	//-- Caso o arquivo ja exista apaga
	FErase(cArqCSV)
 
    //Executa a conversão, exemplo: 
    //   c:\totvs\Testes\XlsToCsv.vbs "C:\Users\danat\Downloads\tste2.xls" "C:\Users\danat\Downloads\tst2_csv.csv"
    ShellExecute("OPEN", cArqScript, ' "' + cArqXLS + '" "' + cArqCSV + '"', cDirTemp, 0 )
 
Return cArqCSV


/*/{Protheus.doc} SetTraking
Atualiza tabela de tracking
@type function
@version 1.0
@author dener.lemos@dothink.com.br
@since 27/08/2025
@param aLinha, array, array contendo a linha
@param cTitLog, character, Titulo para log do tracking
@param nLinhaAtu, numeric, numero da linha da planilha / csv
/*/
Static Function SetTraking(aLinha, cTitLog, nLinhaAtu)
    Local aAreaAnt  := GetArea()
    Local aTrackS   := {}
	Local cC5X4SSTAT:= ""
	Local cLogTrk	:= ""
	Local cLFilial  := GCpoN("FILIAL"		, aLinha) 
	Local cLPedido  := GCpoN("PEDIDO"		, aLinha) 
	Local cLItem    := GCpoN("ITEM"			, aLinha) 
	Local cLProduto := GCpoN("PRODUTO"		, aLinha) 
	Local cLQuant   := GCpoN("QUANTIDADE"	, aLinha) 
	Local cLLoteLid := GCpoN("LOTE_LIDO"	, aLinha) 
	Local cLDVlFisi := GCpoN("DT_VLDFISICA"	, aLinha)
	Local cLHVlFisi := GCpoN("HR_VLDFISICA"	, aLinha)
	Local cLQVlFisi := GCpoN("QT_VLDFISICA"	, aLinha)
	Local cLDSepar  := GCpoN("DT_SEPARACAO"	, aLinha)
	Local cLHSepar  := GCpoN("HR_SEPARACAO"	, aLinha)
	Local cLQSepar  := GCpoN("QT_SEPARACAO"	, aLinha)
	Local cLDEmbarq := GCpoN("DT_EMBARQUE"	, aLinha)
	Local cLHEmbarq := GCpoN("HR_EMBARQUE"	, aLinha)
	Local cLQEmbarq := GCpoN("HR_EMBARQUE"	, aLinha)
	Local cLMotivo	:= GCpoN("MOTIVO"		, aLinha)
	Local nRecZ09   := 0
	Local nLQuant   := 0
	Local nLQVlFisi := 0
	Local nLQSepar  := 0
	Local nLQEmbarq := 0
	Local dLDVlFisi := CTOD("")
	Local dLDSepar  := CTOD("")
	Local dLDEmbarq := CTOD("")
	Local cCodOpe	:= ""
	Local dDtAg		:= Date() + 1
	Local cEmail	:= ""
	Local cTransp	:= ""


	If !Empty(cLQuant)
		nLQuant := Val(cLQuant)
	EndIf

	If !Empty(cLDVlFisi)
		dLDVlFisi := CTOD(cLDVlFisi)
		If Empty(dLDVLFisi)
			dLDVlFisi := CTOD(ConvDate(cLDVlFisi))
		EndIf
	EndIf

	If !Empty(cLQVlFisi)
		nLQVlFisi := Val(cLQVlFisi)
	EndIf

	If !Empty(cLDSepar)
		dLDSepar  := CTOD(cLDSepar)
		If Empty(dLDSepar)
			dLDSepar  := CTOD(ConvDate(cLDSepar))
		EndIf
	EndIf

	If !Empty(cLQSepar)
		nLQSepar := Val(cLQSepar)
	EndIf

	If !Empty(cLDEmbarq)
		dLDEmbarq := CTOD(cLDEmbarq)
		If Empty(dLDEmbarq)
			dLDEmbarq := CTOD(ConvDate(cLDEmbarq))
		EndIf
	EndIf

	If !Empty(cLQEmbarq)
		nLQEmbarq := Val(cLQEmbarq)
	EndIf

	If Empty(cLPedido)
		Aadd(aErros, {nLinhaAtu, "A columa pedido PEDIDO deve ser informada."})
		Return
	EndIf

	If Empty(cLItem)
		Aadd(aErros, {nLinhaAtu, "A columa pedido ITEM deve ser informada."})
		Return
	EndIf	

	If Empty(cLFilial)
		Aadd(aErros, {nLinhaAtu, "A columa pedido FILIAL deve ser informada."})
		Return
	EndIf

	If cLFilial == "05" 
		cCodOpe := "TAC"
	Else
		cCodOpe := "UDLOG"
	EndIf

	dbSelectArea("Z09")
	Z09->( dbSetOrder(3) )

	If !Z09->(dbSeek(cLFilial + cLPedido + cLItem))
		Aadd(aErros, {nLinhaAtu, "Filial:"+cLFilial+ " Pedido:"+cLPedido + " Item:"+cLItem+ " , nao localizado na tabela de tracking."})
		Return
	EndIf
	
	nRecZ09 := Z09->(Recno())

	If !Empty(cLMotivo)
		DbSelectArea("CB4")
		CB4->( DbSetOrder(1) )
		If !CB4->( DbSeek(xFilial() + cLMotivo) )
			Aadd(aErros, {nLinhaAtu, "Motivo: "+cLMotivo+" , nao localizado no cadastro de motivos."})
			Return
		EndIf
	EndIf

	If AllTrim(cLProduto) <> AllTrim(Z09->Z09_PROD)
		Aadd(aErros, {nLinhaAtu, "Produto: "+cLProduto+" , diferente do informado na tabela tracking ["+AllTrim(Z09->Z09_PROD)+"]."})
		Return
	EndIf

	If !Empty(Z09->Z09_LOTECT) .And. AllTrim(cLLoteLid) <> AllTrim(Z09->Z09_LOTECT)
		Aadd(aErros, {nLinhaAtu, "Lote Lido: "+AllTrim(cLLoteLid)+" , diferente do lote fixo ["+AllTrim(Z09->Z09_LOTECT)+"]."})
		Return
	EndIf
	
	dbSelectArea("SC5")
	SC5->( dbSetOrder(1) )
    If SC5->( dbSeek( cLFilial + cLPedido ) )
		cC5X4SSTAT := SC5->C5_X4SSTAT

		//-- VALIDACAO FISICA
		If Z09->Z09_STATUS <= "3"
			
			If !Empty(cLMotivo) .Or. ( !Empty(dLDVlFisi) .And. !Empty(cLHVlFisi) .And. !Empty(nLQVlFisi) )

				If Empty(cLMotivo)
					//-- Atualiza tabela de validacao fiscal
					DbSelectArea("CB7")
					CB7->( DbSetOrder(2) )
					If CB7->( DbSeek(Z09->Z09_FILIAL + Z09->Z09_NUMPV) )

						// AJUSTE DO STATUS
						RecLock("CB7", .F.)
						CB7->CB7_XSTATU := "9"
						CB7->CB7_XSTATP := " "
						CB7->CB7_CODOPE := cCodOpe
						CB7->( MsUnLock() )

						GravaCB8(1, Z09->Z09_FILIAL, Z09->Z09_NUMPV, Z09->Z09_ITEMPV, Z09->Z09_PROD, cLLoteLid, nLQVlFisi)

					EndIf
				EndIf

				If Z09->Z09_DTSLA > Date()
					dDtAg := Z09->Z09_DTSLA
				EndIf

				cTransp := Z09->Z09_TRANSP

				aTrackS := Array( Len( Z09->( DbStruct() ) ) )

				aTrackS[Z09->(FieldPos("Z09_FILIAL"))]  := Z09->Z09_FILIAL
				aTrackS[Z09->(FieldPos("Z09_NUMPV")) ]  := Z09->Z09_NUMPV
				aTrackS[Z09->(FieldPos("Z09_ITEMPV"))]  := Z09->Z09_ITEMPV
				aTrackS[Z09->(FieldPos("Z09_DVIFIS"))]  := dLDVlFisi	
				aTrackS[Z09->(FieldPos("Z09_HVIFIS"))]  := cLHVlFisi
				aTrackS[Z09->(FieldPos("Z09_UVIFIS"))]  := "PLANILHA"
				If Empty(cLMotivo)
					aTrackS[Z09->(FieldPos("Z09_DVFISI"))]  := dLDVlFisi
					aTrackS[Z09->(FieldPos("Z09_HVFISI"))]  := cLHVlFisi
					aTrackS[Z09->(FieldPos("Z09_UVFISI"))]  := "PLANILHA"
					aTrackS[Z09->(FieldPos("Z09_STATUS"))]  := "4" // Status "Em Agendamento" (grava a fase posterior)
					aTrackS[Z09->(FieldPos("Z09_DT1COL"))]  := dDtAg
					aTrackS[Z09->(FieldPos("Z09_HR1COL"))]  := Time()
					aTrackS[Z09->(FieldPos("Z09_US1COL"))]  := "AUTOMATICO"				
					
					cLogTrk 	:= "Em Validação Fisica (Fim)"
					cC5X4SSTAT 	:= "8"	//-- Status "Em agendamento" Pedido de Vendas (grava a fase posterior)
				Else
					aTrackS[Z09->(FieldPos("Z09_MOTIVO"))]  := cLMotivo
					aTrackS[Z09->(FieldPos("Z09_STATUS"))]  := "3" // Status "Em Validacao Fisica"
					cLogTrk 	:= "Em Validação Fisica"
					cC5X4SSTAT 	:= "A"	//-- Status "Em Validacao Fisica" Pedido de Vendas
				Endif

				u_TRK006S(aTrackS, cTitLog + cLogTrk)


				If cC5X4SSTAT == "8"
					If !Empty(cTransp)
							cEmail := Posicione("SA4", 1, FWxFilial('SA4') + cTransp, "A4_EMAIL")

							cEmail := u_GetAgEmail(cEmail)
					
							u_TRK0012(cEmail, "Agendamento")
					EndIf
				EndIf

			Else
				cLogTrk := ""
				If Empty(dLDVlFisi)
					cLogTrk += ", DT_VLDFISICA"
				EndIf
				If Empty(cLHVlFisi)
					cLogTrk += ", HR_VLDFISICA"
				EndIf				
				If Empty(nLQVlFisi)
					cLogTrk += ", QT_VLDFISICA"
				EndIf	
				Aadd(aErros, {nLinhaAtu, "Existem conteudo vazios da validacao Fisica para as colunas" + cLogTrk})
			Endif
		EndIf

		Z09->(dbGoTo(nRecZ09))
		//-- EM SEPARACAO  (Só é executado se ja tiver ocorrido a confirmacao do agendamento)
		If Z09->Z09_STATUS == "5"
			If !Empty(cLMotivo) .Or. ( !Empty(dLDSepar) .And. !Empty(cLHSepar) .And. !Empty(nLQSepar) )

				If Empty(cLMotivo)
					//-- Atualiza tabela de validacao fiscal
					DbSelectArea("CB7")
					CB7->( DbSetOrder(2) )
					If CB7->( DbSeek(Z09->Z09_FILIAL + Z09->Z09_NUMPV) )

						// AJUSTE DO STATUS
						RecLock("CB7", .F.)
						CB7->CB7_STATUS := "9"
						CB7->CB7_STATPA := " "
						CB7->CB7_DTFIMS := dLDSepar
						CB7->CB7_HRFIMS := cLHSepar						
						CB7->( MsUnLock() )

						GravaCB8(2, Z09->Z09_FILIAL, Z09->Z09_NUMPV, Z09->Z09_ITEMPV, Z09->Z09_PROD, cLLoteLid, nLQSepar)

					EndIf
				EndIf

				aTrackS := Array( Len( Z09->( DbStruct() ) ) )

				aTrackS[Z09->(FieldPos("Z09_FILIAL"))]  := Z09->Z09_FILIAL
				aTrackS[Z09->(FieldPos("Z09_NUMPV")) ]  := Z09->Z09_NUMPV
				aTrackS[Z09->(FieldPos("Z09_ITEMPV"))]  := Z09->Z09_ITEMPV

				If Empty(cLMotivo)
					aTrackS[Z09->(FieldPos("Z09_STATUS"))]  := "6" // Status "Em Faturamento" (grava a fase posterior)
					aTrackS[Z09->(FieldPos("Z09_DTEXPE"))]  := dLDSepar
					aTrackS[Z09->(FieldPos("Z09_HREXPE"))]  := cLHSepar

					cLogTrk 	:= "Em Faturamento"
					cC5X4SSTAT 	:= "2"	//-- Status "Em Faturamento" Pedido de Vendas (grava a fase posterior)
				Else
					aTrackS[Z09->(FieldPos("Z09_MOTIVO"))]  := cLMotivo
					aTrackS[Z09->(FieldPos("Z09_STATUS"))]  := "5" // Status "Em Separacao"
					cLogTrk 	:= "Em Separacao"
					cC5X4SSTAT 	:= "1"	//-- Status "Em Separacao" Pedido de Vendas
				EndIf

				u_TRK006S(aTrackS, cTitLog + cLogTrk)			

			Else
				cLogTrk := ""
				If Empty(dLDSepar)
					cLogTrk += ", DT_SEPARACAO"
				EndIf
				If Empty(cLHSepar)
					cLogTrk += ", HR_SEPARACAO"
				EndIf				
				If Empty(nLQVlFisi)
					cLogTrk += ", QT_SEPARACAO"
				EndIf	
				Aadd(aErros, {nLinhaAtu, "Existem conteudo vazios na separacao para as colunas" + cLogTrk})
			EndIf
			
		EndIf

		Z09->(dbGoTo(nRecZ09))
		//-- EM EMBARQUE  (Só é executado se ja tiver ocorrido o faturamento)
		If Z09->Z09_STATUS == "7"
			If !Empty(cLMotivo) .Or. (!Empty(dLDEmbarq) .And. !Empty(cLHEmbarq) .And. !Empty(nLQEmbarq))
				aTrackS := Array( Len( Z09->( DbStruct() ) ) )

				aTrackS[Z09->(FieldPos("Z09_FILIAL"))]  := Z09->Z09_FILIAL
				aTrackS[Z09->(FieldPos("Z09_NUMPV")) ]  := Z09->Z09_NUMPV
				aTrackS[Z09->(FieldPos("Z09_ITEMPV"))]  := Z09->Z09_ITEMPV

				aTrackS[Z09->(FieldPos("Z09_STATUS"))]  := "8" // Status "Em Transito"
				aTrackS[Z09->(FieldPos("Z09_DTPEMB"))]  := dLDEmbarq
				aTrackS[Z09->(FieldPos("Z09_HRPEMB"))]  := cLHEmbarq

				cLogTrk 	:= "Em Transito"
				cC5X4SSTAT 	:= "4"	//-- Status "Em Transito" Pedido de Vendas (grava a fase posterior)

				u_TRK006S(aTrackS, cTitLog + cLogTrk)	
			Else
				cLogTrk := ""
				If Empty(dLDEmbarq)
					cLogTrk += ", DT_EMBARQUE"
				EndIf
				If Empty(cLHSepar)
					cLogTrk += ", HR_EMBARQUE"
				EndIf				
				If Empty(nLQVlFisi)
					cLogTrk += ", QT_EMBARQUE"
				EndIf	
				Aadd(aErros, {nLinhaAtu, "Existem conteudo vazios no embarque para as colunas" + cLogTrk})
			EndIf
		EndIf

		//-- Atualiza o Status da SC5
		RecLock("SC5", .F.)
			SC5->C5_X4SSTAT := cC5X4SSTAT
			SC5->C5_MSEXP	:= ""  			//-- Grava o campo C5_MSEXP para sinalizaro ao Scheduler
		SC5->( MsUnLock() )

	Else
		Aadd(aErros, {nLinhaAtu, "Filial:"+cLFilial+ " Pedido:"+cLPedido + " , nao localizado na tabela de pedido de vendas."})
	EndIf

    RestArea(aAreaAnt)

Return


/*/{Protheus.doc} ConvDate
Converte data string
@type function
@version 1.0
@author erike.yuri@dothink.com.br
@since 30/08/2025
@param cMMDDYYY, character, Data no formato string no formado MMDDYYY
@return character, data string no formato DDMMYYYY
/*/
Static Function ConvDate(cMMDDYYY)
	Local nMesHoje	:= Month( Date() )
	Local cDay      := SubStr(cMMDDYYY, At("/", cMMDDYYY)+1, 2)
	Local cMonth    := Left(cMMDDYYY, At("/", cMMDDYYY)-1)
	Local cYear     := Right(cMMDDYYY, 4)
	Local cDDMMYYYY := cDay + "/" + cMonth + "/" + cYear

	
	If cMonth > "12"
		cDDMMYYYY := cMonth + "/" + cDay + "/" + cYear
	Else
		If nMesHoje < Val(cMonth) .And. nMesHoje > 1
			cDDMMYYYY := cMonth + "/" + cDay + "/" + cYear
		EndIf
	EndIf

Return cDDMMYYYY

/*/{Protheus.doc} RetColunas
Retorna array com as colunas do excel
@type function
@version 1.0
@author erike.yuri@dothink.com.br
@since 30/08/2025
@return array, Array com colunas do Excel
/*/
Static Function RetColunas(nTipo)
	local aColsCtr := {}
	Default nTipo  := 1

	If nTipo == 1
		aadd(aColsCtr, {'CB8_FILIAL', 'C', 'FILIAL'          , GetSX3Cache( 'CB8_FILIAL'	, 'X3_TAMANHO' ) * 1.5, 0, ""})
		aadd(aColsCtr, {'CB8_LOCAL' , 'C', 'ARMAZEM'         , GetSX3Cache( 'CB8_LOCAL' 	, 'X3_TAMANHO' ) * 1.5, 0, ""})
		aadd(aColsCtr, {'CB8_PEDIDO', 'C', 'PEDIDO'          , GetSX3Cache( 'CB8_PEDIDO' 	, 'X3_TAMANHO' ) * 1.5, 0, ""})
		aadd(aColsCtr, {'CB8_ITEM'  , 'C', 'ITEM'            , GetSX3Cache( 'CB8_ITEM' 		, 'X3_TAMANHO' ) * 1.5, 0, ""})
		aadd(aColsCtr, {'CB8_PROD'  , 'C', 'PRODUTO'         , GetSX3Cache( 'CB8_PROD' 		, 'X3_TAMANHO' ) * 1.5, 0, ""})
		aadd(aColsCtr, {'CB8_QTDORI', 'N', 'QUANTIDADE'      , 18, 1, "@E 999,999,999,999"})
		aadd(aColsCtr, {'C6_LOTECTL', 'C', 'LOTE_FIXO'       , GetSX3Cache( 'C6_LOTECTL' 	, 'X3_TAMANHO' ) * 1.5, 0, ""})
		aadd(aColsCtr, {'CB8_LOTECT', 'C', 'LOTE_FEFO'       , GetSX3Cache( 'CB8_LOTECT' 	, 'X3_TAMANHO' ) * 1.5, 0, ""})
		aadd(aColsCtr, {'Z09_DTEMNF', 'D', 'DATA_NF'         , GetSX3Cache( 'Z09_DTEMNF' 	, 'X3_TAMANHO' ) * 1.5, 0, ""})
		aadd(aColsCtr, {'Z09_NF'    , 'C', 'NUM_NF'          , GetSX3Cache( 'Z09_NF' 		, 'X3_TAMANHO' ) * 1.5, 0, ""})
		aadd(aColsCtr, {'Z09_SERIE' , 'C', 'SERIE_NF'        , GetSX3Cache( 'Z09_SERIE' 	, 'X3_TAMANHO' ) * 1.5, 0, ""})
		aadd(aColsCtr, {'Z09_DTSLA' , 'D', 'DATA_PREV_COLETA', GetSX3Cache( 'Z09_DTSLA' 	, 'X3_TAMANHO' ) * 1.5, 0, ""})
		aadd(aColsCtr, {'Z09_DC1COL', 'D', 'DATA_AGENDAMENTO', GetSX3Cache( 'Z09_DC1COL' 	, 'X3_TAMANHO' ) * 1.5, 0, ""})
		aadd(aColsCtr, {'Z09_NTRANS', 'C', 'TRANSPORTADORA'  , GetSX3Cache( 'Z09_NTRANS' 	, 'X3_TAMANHO' ) * 1.5, 0, ""})
		aadd(aColsCtr, {'Z12_LOTECT', 'C', 'LOTE_LIDO'       , GetSX3Cache( 'Z12_LOTECT' 	, 'X3_TAMANHO' ) * 1.5, 0, ""})
		aadd(aColsCtr, {'Z09_DVFISI', 'D', 'DT_VLDFISICA'    , GetSX3Cache( 'Z09_DVFISI' 	, 'X3_TAMANHO' ) * 1.5, 0, ""})
		aadd(aColsCtr, {'Z09_HVFISI', 'C', 'HR_VLDFISICA'    , GetSX3Cache( 'Z09_HVFISI' 	, 'X3_TAMANHO' ) * 1.5, 0, ""})
		aadd(aColsCtr, {'Z12_QTESEP', 'N', 'QT_VLDFISICA'    , 18, 1, "@E 999,999,999,999"})
		aadd(aColsCtr, {'Z09_DTEXPE', 'D', 'DT_SEPARACAO'    , GetSX3Cache( 'Z09_DTEXPE' 	, 'X3_TAMANHO' ) * 1.5, 0, ""})
		aadd(aColsCtr, {'Z09_HREXPE', 'C', 'HR_SEPARACAO'    , GetSX3Cache( 'Z09_HREXPE' 	, 'X3_TAMANHO' ) * 1.5, 0, ""})
		aadd(aColsCtr, {'CB9_QTESEP', 'N', 'QT_SEPARACAO'    , 18, 1, "@E 999,999,999,999"})
		aadd(aColsCtr, {'Z09_DTPEMB', 'D', 'DT_EMBARQUE'     , GetSX3Cache( 'Z09_DTPEMB' 	, 'X3_TAMANHO' ) * 1.5, 0, ""})
		aadd(aColsCtr, {'Z09_HRPEMB', 'C', 'HR_EMBARQUE'     , GetSX3Cache( 'Z09_HRPEMB' 	, 'X3_TAMANHO' ) * 1.5, 0, ""})
		aadd(aColsCtr, {'CB9_QTEEBQ', 'N', 'QT_EMBARQUE'     , 18, 1, "@E 999,999,999,999"})
		aadd(aColsCtr, {'Z09_MOTIVO', 'C', 'MOTIVO'          , GetSX3Cache( 'Z09_MOTIVO' 	, 'X3_TAMANHO' ) * 1.5, 0, ""})
	Else
		aadd(aColsCtr, {'Z09_FILIAL', 'C', 'UNIDADE BARENTZ' 				, GetSX3Cache( 'Z09_FILIAL'	, 'X3_TAMANHO' ) * 1.5, 0, ""})
		aadd(aColsCtr, {'Z09_NTRANS', 'C', 'TRANSPORTADORA'         		, GetSX3Cache( 'Z09_NTRANS' , 'X3_TAMANHO' ) * 1.5, 0, ""})
		aadd(aColsCtr, {'Z09_NF'	, 'C', 'NF BARENTZ'          			, GetSX3Cache( 'Z09_NF' 	, 'X3_TAMANHO' ) * 1.5, 0, ""})
		aadd(aColsCtr, {'Z09_CTE'   , 'C', 'N. CT-E'           				, GetSX3Cache( 'Z09_CTE' 	, 'X3_TAMANHO' ) * 1.5, 0, ""})
		aadd(aColsCtr, {'XTIPOX'  	, 'C', 'D (DIRETO) OU R (REDESPACHO)'	, 18											  , 0, ""})
		aadd(aColsCtr, {'Z09_DC1COL', 'D', 'DATA COLETA NA BARENTZ'      	, GetSX3Cache( 'Z09_DC1COL' , 'X3_TAMANHO' ) * 1.5, 0, ""})
		aadd(aColsCtr, {'Z09_DTSLA'	, 'D', 'PREVISAO DE ENTREGA (SLA)'      , GetSX3Cache( 'Z09_DTSLA' 	, 'X3_TAMANHO' ) * 1.5, 0, ""})
		aadd(aColsCtr, {'Z09_DTENTR', 'D', 'DATA DE ENTREGA REAL'       	, GetSX3Cache( 'Z09_DTENTR' , 'X3_TAMANHO' ) * 1.5, 0, ""})
		aadd(aColsCtr, {'Z09_OBSLOG', 'C', 'OCORRENCIAS:'         			, GetSX3Cache( 'Z09_OBSLOG' , 'X3_TAMANHO' ) * 1.5, 0, ""})
	EndIf

return aColsCtr

/*/{Protheus.doc} GCpoN
Retorna o conteudo do array de linhas
@type function
@version 1.0
@author erike.yuri@dothink.com.br
@since 30/08/2025
@param cCpoName, character, nome da coluna
@param aLinha, array, array com colunas da linha
@return character, conteudo do campo
/*/
Static Function GCpoN(cCpoName, aLinha)
	local nPos := Ascan( aColunas, {|x| upper(x[3]) == upper(cCpoName) })
	local cRet := ""

	If nPos > 0 .And. nPos <= Len(aLinha) .And. !Empty(aLinha[nPos])
		cRet := aLinha[nPos]
	EndIf
	 
Return cRet


Static Function GravaCB8(nOpc, cxFilial, cPedido, cItem, cProduto, cLote, nQtde)
	Local aArea:= GetArea()

	DbSelectArea("CB8")
	CB8->( DbSetOrder(2) )
	CB8->( DbSeek(cxFilial + cPedido + cItem) )
	While CB8->( !Eof() .And. CB8_FILIAL+CB8_PEDIDO+CB8_ITEM == cxFilial + cPedido + cItem)

		If AllTrim(CB8->CB8_PROD) == AllTrim(cProduto) .And. AllTrim(CB8->CB8_LOTECT) == AllTrim(cLote)
			RecLock("CB8", .F.)
			If nOpc == 1
				If nQtde >= CB8->CB8_XSALDO
					GravaZ12(cxFilial, CB8->CB8_XSALDO, CB8->CB8_LCALIZ, CB8->CB8_LOTECT, CB8->CB8_NUMLOT, NIL, CB8->CB8_NUMSER, CB8->CB8_SEQUEN)
					nQtde 			-= CB8->CB8_XSALDO
					CB8->CB8_XSALDO := 0
				Else
					CB8->CB8_XSALDO -= nQtde
					GravaZ12(cxFilial, CB8->CB8_XSALDO, CB8->CB8_LCALIZ, CB8->CB8_LOTECT, CB8->CB8_NUMLOT, NIL, CB8->CB8_NUMSER, CB8->CB8_SEQUEN)
					nQtde:=0
				EndIf
			Else
				If nQtde >= CB8->CB8_SALDOS
					GravaCB9(cxFilial, CB8->CB8_SALDOS,CB8->CB8_LCALIZ, CB8->CB8_LOTECT, CB8->CB8_NUMLOT, NIL, CB8->CB8_NUMSER, CB8->CB8_SEQUEN)
					nQtde -= CB8->CB8_SALDOS
					CB8->CB8_SALDOS := 0
				Else
					CB8->CB8_SALDOS -= nQtde
					GravaCB9(cxFilial, nQtde,CB8->CB8_LCALIZ, CB8->CB8_LOTECT, CB8->CB8_NUMLOT, NIL, CB8->CB8_NUMSER, CB8->CB8_SEQUEN)
					nQtde:=0
				EndIf
			EndIf
			CB8->( MsUnLock() )
		EndIf

		CB8->( DbSkip() )
	End

	RestArea(aArea)
Return


Static Function GravaZ12(cxFilial, nQtde,cEndNew,cLoteNew,cSLoteNew,cCodCB0,cNumSerNew,cSequen)
	Default cCodCB0 := Space(10)

	Z12->(DbSetOrder(10))         
	If !Z12->(DbSeek(cxFilial+CB8->(CB8_ORDSEP+CB8_ITEM+CB8_PROD+CB8_LOCAL+CB8_LCALIZ+cLoteNew+cSLoteNew+CB8_LOTECT+CB8_NUMLOT+CB8_NUMSER)))
		RecLock("Z12",.T.)
		Z12->Z12_FILIAL := cxFilial
		Z12->Z12_ORDSEP := CB7->CB7_ORDSEP
		Z12->Z12_CODETI := cCodCB0
		Z12->Z12_PROD   := CB8->CB8_PROD
		Z12->Z12_CODSEP := CB7->CB7_CODOPE
		Z12->Z12_ITESEP := CB8->CB8_ITEM
		Z12->Z12_SEQUEN := cSequen
		Z12->Z12_LOCAL  := CB8->CB8_LOCAL
		Z12->Z12_LCALIZ := cEndNew
		Z12->Z12_LOTECT := cLoteNew
		Z12->Z12_NUMLOT := cSLoteNew
		Z12->Z12_NUMSER := cNumSerNew
		Z12->Z12_LOTSUG := CB8->CB8_LOTECT
		Z12->Z12_SLOTSU := CB8->CB8_NUMLOT
		Z12->Z12_NSERSU := CB8->CB8_NUMSER
		Z12->Z12_PEDIDO := CB8->CB8_PEDIDO

		If Z12->(ColumnPos("Z12_TRT")) > 0 .And. CB8->(ColumnPos("CB8_TRT")) > 0
			Z12->Z12_TRT	:= CB8->CB8_TRT
		EndIf

	Else
		RecLock("Z12",.F.)
	EndIf
	Z12->Z12_QTESEP += nQtde
	Z12->Z12_STATUS := "1"  // validado
	Z12->(MsUnlock())

Return


Static Function GravaCB9(cxFilial, nQtde,cEndNew,cLoteNew,cSLoteNew,cCodCB0,cNumSerNew,cSequen)
	Default cCodCB0 := Space(10)


	CB9->(DbSetOrder(10))
	If !CB9->(DbSeek(cxFilial+CB8->(CB8_ORDSEP+CB8_ITEM+CB8_PROD+CB8_LOCAL+CB8_LCALIZ+cLoteNew+cSLoteNew+CB8_LOTECT+CB8_NUMLOT+CB8_NUMSER)))
		RecLock("CB9",.T.)
		CB9->CB9_FILIAL := cxFilial
		CB9->CB9_ORDSEP := CB7->CB7_ORDSEP
		CB9->CB9_CODETI := cCodCB0
		CB9->CB9_PROD   := CB8->CB8_PROD
		CB9->CB9_CODSEP := CB7->CB7_CODOPE
		CB9->CB9_ITESEP := CB8->CB8_ITEM
		CB9->CB9_SEQUEN := cSequen
		CB9->CB9_LOCAL  := CB8->CB8_LOCAL
		CB9->CB9_LCALIZ := cEndNew
		CB9->CB9_LOTECT := cLoteNew
		CB9->CB9_NUMLOT := cSLoteNew
		CB9->CB9_NUMSER := cNumSerNew
		CB9->CB9_LOTSUG := CB8->CB8_LOTECT
		CB9->CB9_SLOTSU := CB8->CB8_NUMLOT
		CB9->CB9_NSERSU := CB8->CB8_NUMSER
		CB9->CB9_PEDIDO := CB8->CB8_PEDIDO

		If CB9->(ColumnPos("CB9_TRT")) > 0 .And. CB8->(ColumnPos("CB8_TRT")) > 0
			CB9->CB9_TRT	:= CB8->CB8_TRT
		EndIf

	Else
		RecLock("CB9",.F.)
	EndIf
	CB9->CB9_QTESEP += nQtde
	CB9->CB9_STATUS := "1"  // separado
	CB9->(MsUnlock())

Return


//---- ATUALIZACAO POR PLANILHA ENTREGA DO CLIENTE
//-- Função que realiza a leitura de um XLS convertendo ele para CSV para importar os dados (como se fosse um CSV)
User Function TRK0016R()
    Local aAreaAnt := GetArea()
    Local cArqSel  := ""
	Local cArquivo := Space(200)

    Private cArqCSV := ""
  

	aAdd(aPergs, {6,"Arquivo",cArquivo,"","","",80,.F.,"Todos os arquivos (*.xlsx) |*.*"})
	If ParamBox(aPergs, "Informe o arquivo", /*aRet*/, /*bOk*/, /*aButtons*/, /*lCentered*/, /*nPosx*/, /*nPosy*/, /*oDlgWizard*/, /*cLoad*/, .F., .F.)
		cArqSel := AllTrim(MV_PAR01)
		If !Empty(cArqSel) .And. File(cArqSel)
			FWMsgRun(NIL,{|| ProcCSV(cArqSel, 2)  },"Aguarde...","Convertendo e importando")
		EndIf

	EndIf

    RestArea(aAreaAnt)

Return



/*/{Protheus.doc} SetDtRealT
Atualiza tabela de tracking para data real
@type function
@version 1.0
@author dener.lemos@dothink.com.br
@since 01/10/2025
@param aLinha, array, array contendo a linha
@param cTitLog, character, Titulo para log do tracking
@param nLinhaAtu, numeric, numero da linha da planilha / csv
/*/
Static Function SetDtRealT(aLinha, cTitLog, nLinhaAtu)
    Local aAreaAnt  := GetArea()
    Local aTrackS   := {}
	Local cxFilial	:= ""
	Local cxNF		:= ""
	Local cLFilial  := GCpoN("UNIDADE BARENTZ"		, aLinha) 
	Local cLNF	    := GCpoN("NF BARENTZ"			, aLinha) 
	Local cLCte 	:= GCpoN("N. CT-E"				, aLinha) 
	Local cLDtReal  := GCpoN("DATA DE ENTREGA REAL"	, aLinha) 
	Local cLOcorr	:= GCpoN("OCORRENCIAS:"			, aLinha) 
	Local nRecZ09   := 0
	Local dLDtReal	:= CTOD("")
	Local cAuxObs	:= ""
	Local lVldDtReal:= .F.

	If !Empty(cLDtReal)
		dLDtReal  := CTOD(cLDtReal)
		If Empty(dLDtReal)
			dLDtReal  := CTOD(ConvDate(cLDtReal))
		EndIf
	EndIf

	If !Empty(dLDtReal)
		lVldDtReal := .T.
	EndIf

	If !lVldDtReal
		Aadd(aErros, {nLinhaAtu, "A columa DATA DE ENTREGA REAL sem conteudo."})
		Return
	EndIf

	If Empty(cLFilial)
		Aadd(aErros, {nLinhaAtu, "A columa UNIDADE BARENTZ (Filial) deve ser informada."})
		Return
	EndIf

	If Empty(cLNF)
		Aadd(aErros, {nLinhaAtu, "A columa NF BARENTZ deve ser informada."})
		Return
	EndIf	


	dbSelectArea("Z09")
	Z09->( dbSetOrder(2) )

	cxFilial := StrZero( val(cLFilial), 2)
	cxNF	 := StrZero( val(cLNF), Len(Z09->Z09_NF) )

	If !Z09->(dbSeek(cxFilial + cxNF))
		Aadd(aErros, {nLinhaAtu, "UNIDADE BARENTZ:"+cxFilial+ " NF BARENTZ:"+cxNF  +" , nao localizado na tabela de tracking."})
		Return
	EndIf

	//-- Verifica se ja esta atualizado
	If !Empty(Z09->Z09_DTENTR)
		Return
	EndIf
	
	nRecZ09 := Z09->(Recno())
	
	dbSelectArea("SC5")
	SC5->( dbSetOrder(1) )
    If SC5->( dbSeek( Z09->Z09_FILIAL + Z09->Z09_NUMPV ) )

		aTrackS := Array( Len( Z09->( DbStruct() ) ) )

		While Z09->( !Eof() .and. Z09_FILIAL + Z09_NF == cxFilial + cxNF )
			aTrackS[Z09->(FieldPos("Z09_FILIAL"))]  := Z09->Z09_FILIAL
			aTrackS[Z09->(FieldPos("Z09_NUMPV")) ]  := Z09->Z09_NUMPV
			aTrackS[Z09->(FieldPos("Z09_ITEMPV"))]  := Z09->Z09_ITEMPV
			aTrackS[Z09->(FieldPos("Z09_DTENTR"))]  := dLDtReal
			aTrackS[Z09->(FieldPos("Z09_STATUS"))]  := "9" // Status "Pedido Entregue"
		
			If !Empty(cLOcorr)
				cAuxObs += "--[" + DTOC(Date()) + " " + Time() + "]----------"+ chr(13)+chr(10)
				cAuxObs += "Quem: " + cUserName + chr(13)+chr(10)
				cAuxObs += "O que: " + chr(13)+chr(10) + AllTrim(cLOcorr) + chr(13)+chr(10)
				
				aTrackS[Z09->(FieldPos("Z09_OBSLOG")) ]	:= cAuxObs	+ Trim(Z09->Z09_OBSLOG)
			EndIf

			If !Empty(cLCte)
				aTrackS[Z09->(FieldPos("Z09_CTE")) ]	:= Trim(cLCte)
			EndIf
			
			u_TRK006S(aTrackS, cTitLog )
		
			Z09->( DbSkip() )
		End

		//-- Atualiza o Status da SC5
		RecLock("SC5", .F.)
			SC5->C5_X4SSTAT := "5"
			SC5->C5_MSEXP	:= ""  			//-- Grava o campo C5_MSEXP para sinalizaro ao Scheduler
		SC5->( MsUnLock() )

	Else
		Aadd(aErros, {nLinhaAtu, "Filial:"+cLFilial+ " e Pedido da NF:" +cxNF+ " , nao localizado na tabela de pedido de vendas."})
	EndIf

    RestArea(aAreaAnt)

Return


