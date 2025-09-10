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
	Local aArea  := GetArea()
	Local aPergs := {}
	Local xPar0  := Space(6)
	Local xPar1  := Replicate("Z", Len(CB7->CB7_PEDIDO))
	Local xPar2	 := "19"
	
	aAdd(aPergs, {1, "Pedido De" , xPar0, "", ".T.", "CB7", ".T.", 80,  .F.})
	aAdd(aPergs, {1, "Pedido Ate", xPar1, "", ".T.", "CB7", ".T.", 80,  .T.})
	aAdd(aPergs, {1, "Armazém"   , xPar2, "", ".T.", "NNR", ".T.", 30,  .T.})
	
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
	Local aColunas    := {}
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

    //-- Consulta
    cQuery := " SELECT CB8_FILIAL, CB8_PEDIDO, CB8_ITEM, CB8_PROD, CB8_QTDORI, C6_LOTECTL, CB8_LOTECT, '' LOTE_LIDO, " + CRLF
    cQuery += " Z09_DVIFIS, Z09_HVIFIS, Z12_QTESEP, Z09_UVIFIS, " + CRLF
    cQuery += " Z09_DTEXPE, Z09_HREXPE, CB9_QTESEP, '' US_SEPARACAO, " + CRLF
    cQuery += " Z09_DTPEMB, Z09_HRPEMB, CB9_QTEEBQ, '' US_EMBARQUE, " + CRLF
    cQuery += " Z09_NF, Z09_SERIE, Z09_CHVNFE, C6_ENTREG, CB8_LOCAL, CB8_OCOSEP " + CRLF
    cQuery += " FROM " + RetSQLName("CB8") + " CB8 " + CRLF
    cQuery += " INNER JOIN " + RetSQLName("SC6") + " SC6 " + CRLF
    cQuery += " ON C6_FILIAL = CB8_FILIAL " + CRLF
    cQuery += " AND C6_NUM = CB8_PEDIDO " + CRLF
    cQuery += " AND C6_ITEM = CB8_ITEM " + CRLF
    cQuery += " AND SC6.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += " LEFT JOIN " + RetSQLName("Z09") + " Z09 " + CRLF
    cQuery += " ON Z09_FILIAL = CB8_FILIAL " + CRLF
    cQuery += " AND Z09_NUMPV = CB8_PEDIDO " + CRLF
    cQuery += " AND Z09_ITEMPV = CB8_ITEM " + CRLF
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
		aAdd(aColunas, {"CB8_FILIAL"  , "C", "FILIAL"        , Len(_QRY->CB8_FILIAL) * 1.5  , 0  , ""                  })
		aAdd(aColunas, {"CB8_LOCAL"   , "C", "ARMAZEM"       , Len(_QRY->CB8_LOCAL) * 1.5   , 0  , ""                  })
		aAdd(aColunas, {"CB8_PEDIDO"  , "C", "PEDIDO"        , Len(_QRY->CB8_PEDIDO) * 1.5  , 0  , ""                  })
		aAdd(aColunas, {"CB8_ITEM"    , "C", "ITEM"          , Len(_QRY->CB8_ITEM) * 1.5    , 0  , ""                  })
        aAdd(aColunas, {"CB8_PROD"    , "C", "PRODUTO"       , Len(_QRY->CB8_PROD) * 1.5    , 0  , ""                  })
		aAdd(aColunas, {"CB8_QTDORI"  , "N", "QUANTIDADE"    , 18                           , 1  , "@E 999,999,999,999"})
		aAdd(aColunas, {"C6_LOTECTL"  , "C", "LOTE_FIXO"     , Len(_QRY->C6_LOTECTL) * 1.5  , 0  , ""                  })
        aAdd(aColunas, {"CB8_LOTECT"  , "C", "LOTE_FEFO"     , Len(_QRY->CB8_LOTECT) * 1.5  , 0  , ""                  })
        aAdd(aColunas, {"Z09_NF"      , "C", "NUM_NF"        , Len(_QRY->Z09_NF) * 1.5      , 0  , ""                  })
        aAdd(aColunas, {"Z09_SERIE"   , "C", "SERIE_NF"      , Len(_QRY->Z09_SERIE) * 1.5   , 0  , ""                  })
        aAdd(aColunas, {"LOTE_LIDO"   , "C", "LOTE_LIDO"     , Len(_QRY->LOTE_LIDO) * 1.5   , 0  , ""                  })
        aAdd(aColunas, {"Z09_DVIFIS"  , "D", "DT_VLDFISICA"  , Len(_QRY->Z09_DVIFIS) * 1.5  , 0  , ""                  })
        aAdd(aColunas, {"Z09_HVIFIS"  , "C", "HR_VLDFISICA"  , Len(_QRY->Z09_HVIFIS) * 1.5  , 0  , ""                  })
        aAdd(aColunas, {"Z12_QTESEP"  , "N", "QT_VLDFISICA"  , 18                           , 1  , "@E 999,999,999,999"})
        aAdd(aColunas, {"Z09_UVIFIS"  , "C", "US_VALIDACAO"  , Len(_QRY->Z09_UVIFIS) * 1.5  , 0  , ""                  })
        aAdd(aColunas, {"Z09_DTEXPE"  , "D", "DT_SEPARACAO"  , Len(_QRY->Z09_DTEXPE) * 1.5  , 0  , ""                  })
        aAdd(aColunas, {"Z09_HREXPE"  , "C", "HR_SEPARACAO"  , Len(_QRY->Z09_HREXPE) * 1.5  , 0  , ""                  })
        aAdd(aColunas, {"CB9_QTESEP"  , "N", "QT_SEPARACAO"  , 18                           , 1  , "@E 999,999,999,999"})
        aAdd(aColunas, {"US_SEPARACAO", "C", "US_SEPARACAO"  , Len(_QRY->US_SEPARACAO) * 1.5, 0  , ""                  })
        aAdd(aColunas, {"Z09_DTPEMB"  , "D", "DT_EMBARQUE"   , Len(_QRY->Z09_DTPEMB) * 1.5  , 0  , ""                  })
        aAdd(aColunas, {"Z09_HRPEMB"  , "C", "HR_EMBARQUE"   , Len(_QRY->Z09_HRPEMB) * 1.5  , 0  , ""                  })
        aAdd(aColunas, {"CB9_QTEEBQ"  , "N", "QT_EMBARQUE"   , 18                           , 1  , "@E 999,999,999,999"})
        aAdd(aColunas, {"US_EMBARQUE" , "C", "US_EMBARQUE"   , Len(_QRY->US_EMBARQUE) * 1.5 , 0  , ""                  })
        //aAdd(aColunas, {"Z09_CHVNFE"  , "C", "CHV_DANFE"     , Len(_QRY->Z09_CHVNFE) * 1.5  , 0  , ""                  })
        //aAdd(aColunas, {"C6_ENTREG"   , "D", "DT_REALENTREGA", Len(_QRY->C6_ENTREG) * 1.5   , 0  , ""                  })
        aAdd(aColunas, {"CB8_OCOSEP"  , "C", "MOTIVO"        , Len(_QRY->CB8_OCOSEP) * 1.5  , 0  , ""                  })
	
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
						xConteud := DTOC(STOD(xConteud))
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
    Local cDirIni  := "C:\" //GetTempPath()
    Local cTipArq  := "Arquivos Excel (*.xlsx) | Arquivos Excel 97-2003 (*.xls)"
    Local cTitulo  := "Importar Planilha Armazém Terceiro"
    Local lSalvar  := .F.
    Local cArqSel  := ""

    Private cArqCSV := ""
  
	cArqSel := tFileDialog(	cTipArq,; // Filtragem de tipos de arquivos que serão selecionados
							cTitulo,; // Título da Janela para seleção dos arquivos
							,;        // Compatibilidade
							cDirIni,; // Diretório inicial da busca de arquivos
							lSalvar,; // Se for .T., será uma Save Dialog, senão será Open Dialog
							)         // Se não passar parâmetro, irá pegar apenas 1 arquivo; Se for informado GETF_MULTISELECT será possível pegar mais de 1 arquivo; Se for informado GETF_RETDIRECTORY será possível selecionar o diretório

	If !Empty(cArqSel) .And. File(cArqSel)
		cArqCSV := XLStoCSV(cArqSel)

		If File(cArqCSV)
			Processa({|| Importa(cArqCSV) }, "Importando...")
		EndIf
	EndIf

    RestArea(aAreaAnt)

Return


//-- Funcao que processa o arquivo e realiza a importação para o sistema
Static Function Importa(cArqSel)
    Local cDirTmp    := GetTempPath()
    Local cArqLog    := "importacao_" + dToS(Date()) + "_" + StrTran(Time(), ":", "-") + ".log"
    Local nTotLinhas := 0
    Local cLinAtu    := ""
    Local nLinhaAtu  := 0
    Local aLinha     := {}
    Local oArquivo
    Local cLog       := ""
	Local cSeparador := ","

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
						SetTraking(aLinha, "Planilha de Expedição de Terceiros - Atualização")
                    EndIf
                EndDo
            End Transaction
 
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
 
    //Executa a conversão, exemplo: 
    //   c:\totvs\Testes\XlsToCsv.vbs "C:\Users\danat\Downloads\tste2.xls" "C:\Users\danat\Downloads\tst2_csv.csv"
    ShellExecute("OPEN", cArqScript, ' "' + cArqXLS + '" "' + cArqCSV + '"', cDirTemp, 0 )
 
Return cArqCSV


//--
Static Function SetTraking(aLinha, cTitLog)
    Local aAreaAnt  := GetArea()
    Local aTrackS   := {}
	Local cLFilial  := Iif((Len(aLinha) >= 01 .And. !Empty(aLinha[01])), aLinha[01], "")
	//Local cLArmaz   := Iif((Len(aLinha) >= 02 .And. !Empty(aLinha[02])), aLinha[02], "")
	Local cLPedido  := Iif((Len(aLinha) >= 03 .And. !Empty(aLinha[03])), aLinha[03], "")
	Local cLItem    := Iif((Len(aLinha) >= 04 .And. !Empty(aLinha[04])), aLinha[04], "")
	//Local cLProduto := Iif((Len(aLinha) >= 05 .And. !Empty(aLinha[05])), aLinha[05], "")
	Local cLQuant   := Iif((Len(aLinha) >= 06 .And. !Empty(aLinha[06])), aLinha[06], "")
	//Local cLLoteFix := Iif((Len(aLinha) >= 07 .And. !Empty(aLinha[07])), aLinha[07], "")
	//Local cLLoteFef := Iif((Len(aLinha) >= 08 .And. !Empty(aLinha[08])), aLinha[08], "")
	//Local cLNumNF   := Iif((Len(aLinha) >= 09 .And. !Empty(aLinha[09])), aLinha[09], "")
	//Local cLSerieNF := Iif((Len(aLinha) >= 10 .And. !Empty(aLinha[10])), aLinha[10], "")
	//Local cLLoteLid := Iif((Len(aLinha) >= 11 .And. !Empty(aLinha[11])), aLinha[11], "")
	Local cLDVlFisi := Iif((Len(aLinha) >= 12 .And. !Empty(aLinha[12])), aLinha[12], "")
	Local cLHVlFisi := Iif((Len(aLinha) >= 13 .And. !Empty(aLinha[13])), aLinha[13], "")
	Local cLQVlFisi := Iif((Len(aLinha) >= 14 .And. !Empty(aLinha[14])), aLinha[14], "")
	Local cLUVlFisi := Iif((Len(aLinha) >= 15 .And. !Empty(aLinha[15])), aLinha[15], "")
	Local cLDSepar  := Iif((Len(aLinha) >= 16 .And. !Empty(aLinha[16])), aLinha[16], "")
	Local cLHSepar  := Iif((Len(aLinha) >= 17 .And. !Empty(aLinha[17])), aLinha[17], "")
	Local cLQSepar  := Iif((Len(aLinha) >= 18 .And. !Empty(aLinha[18])), aLinha[18], "")
	Local cLUSepar  := Iif((Len(aLinha) >= 19 .And. !Empty(aLinha[19])), aLinha[19], "")
	Local cLDEmbarq := Iif((Len(aLinha) >= 20 .And. !Empty(aLinha[20])), aLinha[20], "")
	Local cLHEmbarq := Iif((Len(aLinha) >= 21 .And. !Empty(aLinha[21])), aLinha[21], "")
	Local cLQEmbarq := Iif((Len(aLinha) >= 22 .And. !Empty(aLinha[22])), aLinha[22], "")
	Local cLUEmbarq := Iif((Len(aLinha) >= 23 .And. !Empty(aLinha[23])), aLinha[23], "")
	//Local cLOcoSep  := Iif((Len(aLinha) >= 24 .And. !Empty(aLinha[24])), aLinha[24], "")
	Local nRecZ09   := 0
	Local nLQuant   := 0
	Local dLDVlFisi := CTOD(""), nLQVlFisi := 0
	Local dLDSepar  := CTOD(""), nLQSepar  := 0
	Local dLDEmbarq := CTOD(""), nLQEmbarq := 0

	If !Empty(cLQuant)
		nLQuant := Val(cLQuant)
	EndIf

	If !Empty(cLDVlFisi)
		dLDVlFisi := CTOD(ConvDate(cLDVlFisi))
	EndIf

	If !Empty(cLQVlFisi)
		nLQVlFisi := Val(cLQVlFisi)
	EndIf

	If !Empty(cLDSepar)
		dLDSepar  := CTOD(ConvDate(cLDSepar))
	EndIf

	If !Empty(cLQSepar)
		nLQSepar := Val(cLQSepar)
	EndIf

	If !Empty(cLDEmbarq)
		dLDEmbarq := CTOD(ConvDate(cLDEmbarq))
	EndIf

	If !Empty(cLQEmbarq)
		nLQEmbarq := Val(cLQEmbarq)
	EndIf

	dbSelectArea("Z09")
	Z09->( dbSetOrder(3) )

	If !Z09->(dbSeek(cLFilial + cLPedido + cLItem))
		Return
	EndIf

	dbSelectArea("SC5")
	SC5->( dbSetOrder(1) )
    If SC5->( dbSeek( cLFilial + cLPedido ) )
		nRecZ09 := Z09->(Recno())

		aTrackS := Array( Len( Z09->( DbStruct() ) ) )
		If !Empty(dLDVlFisi) .Or. !Empty(cLHVlFisi) .Or. !Empty(nLQVlFisi) .Or. !Empty(cLUVlFisi)

			RecLock("SC5", .F.)
				If cOpc == "1"
					SC5->C5_X4SSTAT := "A" // Em Validacao Fisica
				EndIf

				//Grava o campo C5_MSEXP para sinalizaro ao Scheduler
				SC5->C5_MSEXP:=   ""  //DToS(dDataBase)
			SC5->( MsUnLock() )

			aTrackS[Z09->(FieldPos("Z09_FILIAL"))]  := Z09->Z09_FILIAL
			aTrackS[Z09->(FieldPos("Z09_NUMPV")) ]  := Z09->Z09_NUMPV
			aTrackS[Z09->(FieldPos("Z09_ITEMPV"))]  := Z09->Z09_ITEMPV

			aTrackS[Z09->(FieldPos("Z09_STATUS"))]  := "3" // Status "Em Validacao Fisica"
			aTrackS[Z09->(FieldPos("Z09_DVIFIS"))]  := dLDVlFisi	
			aTrackS[Z09->(FieldPos("Z09_HVIFIS"))]  := cLHVlFisi
			aTrackS[Z09->(FieldPos("Z09_UVIFIS"))]  := cLUVlFisi

			aTrackS[Z09->(FieldPos("Z09_DVFISI"))]  := dLDVlFisi
			aTrackS[Z09->(FieldPos("Z09_HVFISI"))]  := cLHVlFisi
			aTrackS[Z09->(FieldPos("Z09_UVFISI"))]  := cLUVlFisi

			u_TRK006S(aTrackS, "Em Validação Fisica")
		EndIf

		Z09->(dbGoTo(nRecZ09))
		aTrackS := Array( Len( Z09->( DbStruct() ) ) )
		If !Empty(dLDSepar) .Or. !Empty(cLHSepar) .Or. !Empty(nLQSepar) .Or. !Empty(cLUSepar)

			RecLock("SC5", .F.)
				If cOpc == "1"
					SC5->C5_X4SSTAT := "1" // Em Separacao
				EndIf

				//Grava o campo C5_MSEXP para sinalizaro ao Scheduler
				SC5->C5_MSEXP:=   ""  //DToS(dDataBase)
			SC5->( MsUnLock() )

			aTrackS[Z09->(FieldPos("Z09_FILIAL"))]  := Z09->Z09_FILIAL
			aTrackS[Z09->(FieldPos("Z09_NUMPV")) ]  := Z09->Z09_NUMPV
			aTrackS[Z09->(FieldPos("Z09_ITEMPV"))]  := Z09->Z09_ITEMPV

			aTrackS[Z09->(FieldPos("Z09_STATUS"))]  := "5" // Status "Em Separacao"
			aTrackS[Z09->(FieldPos("Z09_DTEXPE"))]  := dLDSepar
			aTrackS[Z09->(FieldPos("Z09_HREXPE"))]  := cLHSepar

			u_TRK006S(aTrackS, "Em Separacao")
		EndIf

		Z09->(dbGoTo(nRecZ09))
		aTrackS := Array( Len( Z09->( DbStruct() ) ) )
		If !Empty(dLDEmbarq) .Or. !Empty(cLHEmbarq) .Or. !Empty(nLQEmbarq) .Or. !Empty(cLUEmbarq)

			RecLock("SC5", .F.)
				If cOpc == "1"
					SC5->C5_X4SSTAT := "2" // Em Faturamento
				EndIf

				//Grava o campo C5_MSEXP para sinalizaro ao Scheduler
				SC5->C5_MSEXP:=   ""  //DToS(dDataBase)
			SC5->( MsUnLock() )

			aTrackS[Z09->(FieldPos("Z09_FILIAL"))]  := Z09->Z09_FILIAL
			aTrackS[Z09->(FieldPos("Z09_NUMPV")) ]  := Z09->Z09_NUMPV
			aTrackS[Z09->(FieldPos("Z09_ITEMPV"))]  := Z09->Z09_ITEMPV

			aTrackS[Z09->(FieldPos("Z09_STATUS"))]  := "6" // Status "Em Faturamento"
			aTrackS[Z09->(FieldPos("Z09_DTPEMB"))]  := dLDEmbarq
			aTrackS[Z09->(FieldPos("Z09_HRPEMB"))]  := cLHEmbarq

			u_TRK006S(aTrackS, "Em Faturamento")
		EndIf
	EndIf

    RestArea(aAreaAnt)

Return


//--
Static Function ConvDate(cMMDDYYY)
	Local cDay      := SubStr(cMMDDYYY, At("/", cMMDDYYY)+1, 2)
	Local cMonth    := Left(cMMDDYYY, At("/", cMMDDYYY)-1)
	Local cYear     := Right(cMMDDYYY, 4)
	Local cDDMMYYYY := cDay + "/" + cMonth + "/" + cYear

Return cDDMMYYYY
