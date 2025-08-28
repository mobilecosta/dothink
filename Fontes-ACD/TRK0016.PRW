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
	Local aArea := GetArea()
	Local aPergs   := {}
	Local xPar0 := Space(6)
	Local xPar1 := Space(6)
	
	aAdd(aPergs, {1, "Pedido De", xPar0,  "", ".T.", "CB7", ".T.", 80,  .F.})
	aAdd(aPergs, {1, "Pedido Ate", xPar1,  "", ".T.", "CB7", ".T.", 80,  .F.})
	
	If ParamBox(aPergs, 'Informe os parâmetros', /*aRet*/, /*bOk*/, /*aButtons*/, /*lCentered*/, /*nPosx*/, /*nPosy*/, /*oDlgWizard*/, /*cLoad*/, .F., .F.)
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
	Local aArea       := GetArea()
	Local oPrintXlsx
	Local dData       := Date()
	Local cHora       := Time()
	Local cArquivo    := GetTempPath() + "TRK0016" + dToS(dData) + "_" + StrTran(cHora, ":", "-") + ".rel"
	Local cQuery      := ""
	Local nAtual      := 0
	Local nTotal      := 0
	Local aColunas    := {}
	Local oExcel
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
		aAdd(aColunas, {"CB8_PEDIDO"  , "C", "PEDIDO"        , Len(_QRY->CB8_PEDIDO) * 1.5  , 0  , ""                  })
		aAdd(aColunas, {"CB8_ITEM"    , "C", "ITEM"          , Len(_QRY->CB8_ITEM) * 1.5    , 0  , ""                  })
        aAdd(aColunas, {"CB8_PROD"    , "C", "PRODUTO"       , Len(_QRY->CB8_PROD) * 1.5    , 0  , ""                  })
		aAdd(aColunas, {"CB8_QTDORI"  , "N", "QUANTIDADE"    , 18                           , 1  , "@E 999,999,999,999"})
		aAdd(aColunas, {"C6_LOTECTL"  , "C", "LOTE_FIXO"     , Len(_QRY->C6_LOTECTL) * 1.5  , 0  , ""                  })
        aAdd(aColunas, {"CB8_LOTECT"  , "C", "LOTE_FEFO"     , Len(_QRY->CB8_LOTECT) * 1.5  , 0  , ""                  })
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
        aAdd(aColunas, {"Z09_NF"      , "C", "NUM_NF"        , Len(_QRY->Z09_NF) * 1.5      , 0  , ""                  })
        aAdd(aColunas, {"Z09_SERIE"   , "C", "SERIE_NF"      , Len(_QRY->Z09_SERIE) * 1.5   , 0  , ""                  })
        aAdd(aColunas, {"Z09_CHVNFE"  , "C", "CHV_DANFE"     , Len(_QRY->Z09_CHVNFE) * 1.5  , 0  , ""                  })
        aAdd(aColunas, {"C6_ENTREG"   , "D", "DT_REALENTREGA", Len(_QRY->C6_ENTREG) * 1.5   , 0  , ""                  })
        aAdd(aColunas, {"CB8_LOCAL"   , "C", "ARMAZEM"       , Len(_QRY->CB8_LOCAL) * 1.5   , 0  , ""                  })
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
