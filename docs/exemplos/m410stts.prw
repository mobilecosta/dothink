#Include 'Protheus.ch'

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥M410STTS  ∫Autor  ≥Doit (Darcio)       ∫ Data ≥  19/01/12   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Ponto de entrada desenvolvido para pegar as informacoes de  ∫±±
±±∫          ≥percentual de comissoes de cada vendedor da capa do pedido  ∫±±
±±∫          ≥vendas, de acordo com o cadastro na tabela de percentuais   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Doit x Shark                                               ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User Function M410STTS()
Local aArea		:= GetArea()
Local aAreaSCJ	:= SCJ->(GetArea())
Local aAreaSC5	:= SC5->(GetArea())
Local aAreaSC6	:= SC6->(GetArea())

Local cDtEmissa := M->C5_EMISSAO
Local cNumOrc   := Space(TamSX3("CJ_NUM")[1])
//Local cDtEmissa := If(!Empty(M->C5_XNUMORC) .and. cModulo $ "ESP/ESP1", Posicione("SCJ",1,xFilial("SCJ")+Subs(M->C5_XNUMORC,1,6),"CJ_EMISSAO"), M->C5_EMISSAO)
//Local cNumOrc	:= If(!Empty(M->C5_XNUMORC) .and. M->C5_XNUMORC == SCJ->CJ_NUM .and. cModulo $ "ESP/ESP1", SCJ->CJ_NUM, Subs(M->C5_XNUMORC,1,6))
Local lXPolCom	:= SM0->M0_CODIGO $ SuperGetMV("ES_XPOLCOM",,"") //Empresas que possuem politica de comissoes Agricola
Local lXPolCm2	:= cModulo == "ESP1" .AND. cEmpAnt $ (GetMV("ES_XPOLCM2",,"")) // Empresas que que n„o grava o vend1 quando for maquina
Local lXPolCm3	:= SuperGetMV("ES_XPOLCM3",,.F.) //Calcula a comiss„o do Gerente pela Margem
Local cVend1	:= M->C5_VEND1
Local cVend2	:= M->C5_VEND2
Local cVend3	:= M->C5_VEND3
Local cVend4	:= M->C5_VEND4
Local cVend5	:= M->C5_VEND5
Local cVend6	:= M->C5_VEND6
Local cVend7	:= M->C5_VEND7
Local cVend8	:= M->C5_VEND8
Local cVend9	:= M->C5_VEND9
Local cPecOLEO  := ""
Local nAVista 	:= SuperGetMV("ES_AVISTA",,14) // dias que considera pagamento a vista
Local lMaqUsada := .F.
Local alInfoCli	:= {}

If Upper(Alltrim(Funname())) == "MATA415"			// Efetivacao do Orcamento
	cNumOrc := SCJ->CJ_NUM
	DbSelectArea("SC5")
	RecLock("SC5",.F.)
	SC5->C5_XNUMORC := SCJ->CJ_NUM
	MsUnLock()
Elseif Upper(Alltrim(Funname())) == "MATA410"		// Inclusao ou Alteracao do Pedido de Venda
	If !Empty(M->C5_XNUMORC)
		cNumOrc := Posicione("SCJ",1,xFilial("SCJ")+Subs(M->C5_XNUMORC,1,6),"C5_XNUMORC")
	Endif
Endif
cDtEmissa := IIF(!Empty(cNumOrc) .and. cModulo $ "ESP/ESP1", SCJ->CJ_EMISSAO, M->C5_EMISSAO)

Private cCatPro	:= ""
Private cXCATEGO  := ""
Private cDCtPro	:= ""
Private nRegC6	:= SC6->(Recno())
Private nRegC5	:= SC5->(Recno())
Private nPosPro	:= aScan(aHeader,{|x| x[2] == "C6_PRODUTO"})
Private nPosTES	:= aScan(aHeader,{|x| x[2] == "C6_TES    "})
Private nPosIte	:= aScan(aHeader,{|x| x[2] == "C6_ITEM   "})
Private nPosCha	:= aScan(aHeader,{|x| x[2] == "C6_NUMSERI"})
Private nPosVlr	:= aScan(aHeader,{|x| x[2] == "C6_VALOR  "})
Private nPosQTV	:= aScan(aHeader,{|x| x[2] == "C6_QTDVEN "})
Private nPosPVD	:= aScan(aHeader,{|x| x[2] == "C6_PRCVEN "})

Private nI		:= 0
Private nJ		:= 0
Private cNumPed	:= M->C5_NUM
Private cCliente:= M->C5_CLIENTE
Private cLoja	:= M->C5_LOJACLI
Private cTipUso	:= M->C5_XTIPUSO
Private cNomCli	:= ""
Private aVends	:= {}
Private cManute := ""
Private lProd	:= .T.
Private lCli	:= .T.
Private nPercent:= 0
Private nPVenGe := 0
Private dtOrc   := ctod("  /  /  ")
Private cCondPag:= M->C5_CONDPAG
Private cProduto:= cDesCla := ""
Private lVendDir:= .f. // Venda Direta

If cModulo == "ESP1"
   cManute := "MAQ"
ElseIf cModulo == "ESP"
   cManute := "PEC"
ElseIf cModulo == "ESP2"
   cManute := "SER"
EndIf

If lXPolCom .and. cModulo == "ESP1" .Or. cModulo == "ESP2" .Or. cModulo == "ESP"
	If IsInCallStack( " A410Inclui " ) .or. IsInCallStack( " A410Copia " )

		nPercent := 0

		If !Empty(cVend1).and. u_VerVendFer(cVend1,cDtEmissa)
			aAdd(aVends, {cVend1,cVend1, "1"})
		EndIf

		If !Empty(cVend2) .and. u_VerVendFer(cVend2,cDtEmissa)
			aAdd(aVends, {cVend1,cVend2, "2"})
		EndIf

		If !Empty(cVend3) .and. u_VerVendFer(cVend3,cDtEmissa)
			aAdd(aVends, {cVend1,cVend3, "3"})
		EndIf

		If !Empty(cVend4) .and. u_VerVendFer(cVend4,cDtEmissa)
			aAdd(aVends, {cVend1,cVend4, "4"})
		EndIf

		If !Empty(cVend5) .and. u_VerVendFer(cVend5,cDtEmissa)
			aAdd(aVends, {cVend1,cVend5, "5"})
		EndIf

		If !Empty(cVend6) .and. u_VerVendFer(cVend6,cDtEmissa)
			aAdd(aVends, {cVend1,cVend6, "6"})
		EndIf

		If !Empty(cVend7) .and. u_VerVendFer(cVend7,cDtEmissa)
			aAdd(aVends, {cVend1,cVend7, "7"})
		EndIf

		If !Empty(cVend8) .and. u_VerVendFer(cVend8,cDtEmissa)
			aAdd(aVends, {cVend1,cVend8, "8"})
		EndIf

		If !Empty(cVend9) .and. u_VerVendFer(cVend9,cDtEmissa)
			aAdd(aVends, {cVend1,cVend9, "9"})
		EndIf

		DbSelectArea("SCJ")
		DbSetOrder(1)
		IF DbSeek(xFilial("SCJ") + cNumOrc,.F.)
			dtOrc := SCJ->CJ_EMISSAO
			If SCJ->CJ_XFATVDI == "S"
				cCliente:= SCJ->CJ_XCODFAB
				cLoja	:= SCJ->CJ_XLOJFAB
				cProduto:= SCK->CK_PRODUTO
				lVendDir:= .t.
			Else
				cCliente:= SCJ->CJ_CLIENTE
				cLoja	:= SCJ->CJ_LOJA
			Endif

			If SCJ->CJ_XFLAT == 0 .AND. M->C5_XFLAT > 0
				RecLock("SCJ", .F.)
				Replace SCJ->CJ_XFLAT With M->C5_XFLAT
				MsUnLock()
			EndIf

		Endif

		alInfoCli	:= GetAdvFVal("SA1", {"A1_XEMPGRU", "A1_NOME"}, xFilial("SA1") + cCliente + cLoja, 1, {"", ""})

		if !( alInfoCli[1] == '1' ) // Se for empresa do grupo, n„o gera comiss„o

			//cNomCli	:= Posicione("SA1", 1, xFilial("SA1") + cCliente + cLoja, "A1_NOME")
			cNomCli := alInfoCli[2]

		If lXPolCom  .and. cCliente+cLoja == M->C5_CLIENTE+M->C5_LOJACLI
			For nI := 1 To Len(aCols)

				cProduto := aCols[nI,nPosPro]

				dbSelectArea("SB1")
				DbSetOrder(1)
				dbSeek(xFilial("SB1") + Iif(lVendDir,cProduto,aCols[nI,nPosPro]) )
				cCatPro := StrZero(Val(SB1->B1_XGRCTB),6)
				cDCtPro	:= Posicione("SZM",1,xFilial("SZM")+SB1->B1_XGRCTB,"ZM_DESC") //SB1->B1_XDCATC
				cPecOLEO:= Posicione("SZM",1,xFilial("SZM")+SB1->B1_XGRCTB,"ZM_OLEO")

				dbSelectArea("RZ5")
				DbSetOrder(1)
				If dbSeek(xFilial("RZ5")+aCols[nI,nPosCha])
					If Right(RTrim(RZ5->RZ5_MODELO), 2) == "_U"
						lMaqUsada := .T.
					Endif
				Endif

				For nJ := 1 To Len(aVends)

					dbSelectArea("SA3")
					dbSetOrder(1)
					lAchou := dbSeek(xFilial("SA3")+aVends[nJ,2])
					If lAchou
						lPagaComissao := SA3->A3_XTIPCOM <> "N"
						lPagaNaBaixa  := SA3->A3_ALBAIXA == 100
					Endif

					If lAchou .and. lPagaComissao

						DbSelectArea("SC5")
						DbSetOrder(1)
						DbGoTo(nRegC5)

						RecLock("SC5", .F.)
						&("SC5->C5_COMIS" + aVends[nJ, 3]) := 0
						SC5->(MsUnLock())

						DbSelectArea("SC6")
						DbSetOrder(1)
						If SC6->(dbSeek(xFilial("SC6")+cNumPed+aCols[nI,1]))
							RecLock("SC6", .F.)
								&("SC6->C6_COMIS" + aVends[nJ, 3]) := 0
							SC6->(MsUnLock())
						Endif
/*
						DbGoTo(nRegC6)

						RecLock("SC6", .F.)
							&("SC6->C6_COMIS" + aVends[nJ, 3]) := 0
						SC6->(MsUnLock())
*/
	                    If cModulo == "ESP"
							nDiasPagto := Posicione("SE4",1,xFilial("SE4")+M->C5_CONDPAG,"E4_XPRZMED")
							nTpPagto   := POSICIONE("SZ9",1,XFILIAL("SZ9")+M->C5_CLIENTE,"Z9_TPPRECO")

							If Empty(nTpPagto)
								nTpPagto:= "1" // 1=Varejo;2=Atacado
							Endif

		                    If cPecOLEO <> "O"
		                    	If nDiasPagto <= nAVista .and. nTpPagto == "2"
		                    		cCatPro := "000013" // PECAS ATACADO A VISTA
		                    	ElseIf nDiasPagto > nAVista .and. nTpPagto == "2"
		                    		cCatPro := "000014" // PECAS ATACADO A PRAZO
		                    	ElseIf nDiasPagto <= nAVista .and. nTpPagto == "1"
		                    		cCatPro := "000015" // PECAS VAREJO A VISTA
		                    	ElseIf nDiasPagto > nAVista .and. nTpPagto == "1"
		                    		cCatPro := "000016" // PECAS VAREJO A PRAZO
								Endif
							Else
		                    	If nDiasPagto <= nAVista .and. nTpPagto == "2"
		                    		cCatPro := "000017" // OLEO ATACADO A VISTA
		                    	ElseIf nDiasPagto > nAVista .and. nTpPagto == "2"
		                    		cCatPro := "000017" // OLEO ATACADO A PRAZO
		                    	ElseIf nDiasPagto <= nAVista .and. nTpPagto == "1"
		                    		cCatPro := "000019" // OLEO VAREJO A VISTA
		                    	ElseIf nDiasPagto > nAVista .and. nTpPagto == "1"
		                    		cCatPro := "000020" // OLEO VAREJO A PRAZO
								Endif
							Endif
						Endif

						dbSelectArea("RZE")
						RZE->( dbSetOrder(3) ) // RZE_FILIAL+RZE_VENDED+RZE_CLASSE+RZE_MANUTE
						IF RZE->( dbSeek( xFilial("RZE")+aVends[nJ,2]+cCatPro+cManute ) )

							If cFilAnt $ AllTrim(RZE->RZE_FILGER) .Or. AllTrim(RZE->RZE_FILGER) == '@@'

								nPercent := Iif(cTipUso == "G", RZE->RZE_COMISS, RZE->RZE_PERCAN)
								cDesCla := RZE->RZE_DESCAT

								If nPercent > 0

									If cModulo == "ESP1" .Or. cModulo == "ESP"
										If !(nJ == 1 .AND. lXPolCm2 ) //Adicionado por Heimdall Castro (Doit) 16/08/2012
											RecLock("SC5", .F.)
												&("SC5->C5_COMIS" + aVends[nJ, 3]) := nPercent
											SC5->(MsUnLock())
										EndIf

//										cnItem:="00"
//										For xNN := 1 to Len(aCols)
//											cnItem := soma1(cnItem)
											If SC6->(dbSeek(xFilial("SC6")+cNumPed+aCols[nI,1]))
												RecLock("SC6", .F.)
												If nJ == 1 .AND. lXPolCm2
													&("SC6->C6_XCOMIS1") := nPercent
												Else
													&("SC6->C6_COMIS" + aVends[nJ, 3]) := nPercent
												EndIf
												SC6->(MsUnLock())
											Endif
//										Next xNN

									Endif

									cXCATEGO := AllTrim(Posicione("SA3",1,xFilial("SA3") + aVends[nJ, 2],"A3_XCATEGO"))
								    If cXCATEGO == "05" .and. ; 		 // Gerente Filial  (RZE_CATEGO)
										    	lXPolCom .and. ; 		 // Tem politica de comiss„o
										    	cManute == "MAQ" .and. ; // SÛ para maquinas
										    	!lMaqUsada  	 .and. ;// N„o calcula se for maquina usada
										    	lXPolCm3                // Calcula a comiss„o do Gerente pela Margem
											GteFilCom(.f.,.f.)
									Else
										DbSelectArea("RZF")
										DbSetOrder(1)

										RecLock("RZF", .T.)
											RZF->RZF_FILIAL	:= xFilial("RZF")
											RZF->RZF_PEDIDO	:= cNumPed
											RZF->RZF_TIPUSO	:= cTipUso
											RZF->RZF_CLIENT	:= cCliente
											RZF->RZF_LOJA	:= cLoja
											RZF->RZF_NOME	:= cNomCli
											RZF->RZF_ITEM	:= StrZero(nJ,2)
											RZF->RZF_ITEMPV	:= aCols[nI,nPosIte]
											RZF->RZF_PRODUT	:= Iif(lVendDir,cProduto,aCols[nI,nPosPro])
											RZF->RZF_VENPAI := aVends[nJ,1]
											RZF->RZF_VENDED	:= aVends[nJ,2]
											RZF->RZF_NOMVEN	:= Posicione("SA3",1,xFilial("SA3") + aVends[nJ, 2],"A3_NOME")
											RZF->RZF_VLRBAS	:= aCols[nI,nPosVlr]
											//se for vend1 e se a empresa n„o tem politica de comiss„o,
											//deixa o percentual de zerado pois ser· definido pelo comercial
											If lXPolCm2 .and. aVends[nJ,3] == "1"
												RZF->RZF_COMISS	:= 0
												RZF->RZF_RESULT	:= 0
											Else
												RZF->RZF_COMISS	:= nPercent
												RZF->RZF_RESULT	:= nPercent
											Endif
											RZF->RZF_REDUTO := 0
											RZF->RZF_CATEGO	:= Posicione("SA3",1,xFilial("SA3") + aVends[nJ, 2],"A3_XCATEGO")
											RZF->RZF_DESPRO	:= Posicione("SB1",1,xFilial("SB1") + Iif(lVendDir,cProduto,aCols[nI,nPosPro]) ,"B1_DESC")
											RZF->RZF_PRCVEN := 0
											RZF->RZF_PRCCOM	:= 0
											RZF->RZF_MRGLIQ	:= 0
											RZF->RZF_PERTAB	:= 0
											RZF->RZF_NVCALC := 0
											RZF->RZF_DESCAT	:= Posicione("SA3",1,xFilial("SA3") + aVends[nJ, 2],"A3_XDESCAT")
											RZF->RZF_NUMCOM	:= aVends[nJ,3]
											RZF->RZF_USERNA	:= cUserName
											RZF->RZF_DATLOG	:= dDataBase
											RZF->RZF_CLASSE	:= cCatPro
											RZF->RZF_DESCLA	:= cDesCla
											RZF->RZF_MODULO := cModulo
											RZF->RZF_XFIL   := cFilAnt
										RZF->(MsUnLock())
										If nJ == 1
											// Guarda o valor da comiss„o do vendedor 1
											nPVenGe := aCols[nI,nPosVlr] * (nPercent/100)
										Endif
									Endif
								Endif
							Endif
						Endif
					Endif
				Next nJ
			Next nI

//		Else
//			For nI := 1 To Len(aCols)
//				GteFilCom(.t.,.f.)
//			Next nI
		EndIf

		endif

	ElseIf IsInCallStack( " A410Visual " ) .and. __CUSERID $ "001014/000145"

//		If lXPolCom
//			U_CComiss()
//		Endif

	ElseIf IsInCallStack( " A410Altera " )  //.and. .f.

		If !Empty(cVend1).and. u_VerVendFer(cVend1,cDtEmissa)
			aAdd(aVends, {cVend1,cVend1, "1"})
		EndIf

		If !Empty(cVend2) .and. u_VerVendFer(cVend2,cDtEmissa)
			aAdd(aVends, {cVend1,cVend2, "2"})
		EndIf

		If !Empty(cVend3) .and. u_VerVendFer(cVend3,cDtEmissa)
			aAdd(aVends, {cVend1,cVend3, "3"})
		EndIf

		If !Empty(cVend4) .and. u_VerVendFer(cVend4,cDtEmissa)
			aAdd(aVends, {cVend1,cVend4, "4"})
		EndIf

		If !Empty(cVend5) .and. u_VerVendFer(cVend5,cDtEmissa)
			aAdd(aVends, {cVend1,cVend5, "5"})
		EndIf

		If !Empty(cVend6) .and. u_VerVendFer(cVend6,cDtEmissa)
			aAdd(aVends, {cVend1,cVend6, "6"})
		EndIf

		If !Empty(cVend7) .and. u_VerVendFer(cVend7,cDtEmissa)
			aAdd(aVends, {cVend1,cVend7, "7"})
		EndIf

		If !Empty(cVend8) .and. u_VerVendFer(cVend8,cDtEmissa)
			aAdd(aVends, {cVend1,cVend8, "8"})
		EndIf

		If !Empty(cVend9) .and. u_VerVendFer(cVend9,cDtEmissa)
			aAdd(aVends, {cVend1,cVend9, "9"})
		EndIf

		DbSelectArea("SCJ")
		DbSetOrder(1)
		IF DbSeek(xFilial("SCJ") + cNumOrc,.F.)
			dtOrc := SCJ->CJ_EMISSAO
			If SCJ->CJ_XFATVDI == "S"
				cCliente:= SCJ->CJ_XCODFAB
				cLoja	:= SCJ->CJ_XLOJFAB
				cProduto:= SCK->CK_PRODUTO
				lVendDir:= .t.
			Else
				cCliente:= SCJ->CJ_CLIENTE
				cLoja	:= SCJ->CJ_LOJA
			Endif

			If SCJ->CJ_XFLAT == 0 .AND. M->C5_XFLAT > 0
				RecLock("SCJ", .F.)
				Replace SCJ->CJ_XFLAT With M->C5_XFLAT
				MsUnLock()
			EndIf

		Endif

		alInfoCli	:= GetAdvFVal("SA1", {"A1_XEMPGRU", "A1_NOME"}, xFilial("SA1") + cCliente + cLoja, 1, {"", ""})

		if !( alInfoCli[1] == '1' ) // Se for empresa do grupo, n„o gera comiss„o

			//cNomCli	:= Posicione("SA1", 1, xFilial("SA1") + cCliente + cLoja, "A1_NOME")
			cNomCli	:= alInfoCli[2]

		If lXPolCom
			For nI := 1 To Len(aCols)
				cProduto := aCols[nI,nPosPro]
				For nJ := 1 To Len(aVends)

					dbSelectArea("SA3")
					dbSetOrder(1)
					lAchou := dbSeek(xFilial("SA3")+aVends[nJ,2])
					If lAchou
						lPagaComissao := SA3->A3_XTIPCOM <> "N"
						lPagaNaBaixa  := SA3->A3_ALBAIXA == 100
					Endif

					If lAchou .and. lPagaComissao

						DbSelectArea("SC5")
						DbSetOrder(1)
						DbGoTo(nRegC5)

						RecLock("SC5", .F.)
						If !(nJ == 1 .AND. lXPolCm2 ) //Adicionado por Heimdall Castro (Doit) 16/08/2012
							&("SC5->C5_COMIS" + aVends[nJ, 3]) := 0
						EndIf
						SC5->(MsUnLock())

						DbSelectArea("SC6")
						DbSetOrder(1)
						If SC6->(dbSeek(xFilial("SC6")+cNumPed+aCols[nI,1]))
							If !(nJ == 1 .AND. lXPolCm2 ) //Adicionado por Heimdall Castro (Doit) 16/08/2012
								RecLock("SC6", .F.)
									&("SC6->C6_COMIS" + aVends[nJ, 3]) := 0
								SC6->(MsUnLock())
							EndIf
						Endif
						/*
						DbGoTo(nRegC6)

						RecLock("SC6", .F.)
							&("SC6->C6_COMIS" + aVends[nJ, 3]) := 0
						SC6->(MsUnLock())
						*/
						dbSelectArea("SB1")
						DbSetOrder(1)
						dbSeek(xFilial("SB1")+Iif(lVendDir,cProduto,aCols[nI,nPosPro]) )
						cCatPro := StrZero(Val(SB1->B1_XGRCTB),6)


						dbSelectArea("RZ5")
						DbSetOrder(1)
						If dbSeek(xFilial("RZ5")+aCols[nI,nPosCha])
							If Right(RTrim(RZ5->RZ5_MODELO), 2) == "_U"
								lMaqUsada := .T.
							Endif
						Endif

	                    If cModulo == "ESP"
							nDiasPagto := Posicione("SE4",1,xFilial("SE4")+M->C5_CONDPAG,"E4_XPRZMED")
							nTpPagto   := POSICIONE("SZ9",1,XFILIAL("SZ9")+M->C5_CLIENTE,"Z9_TPPRECO")

							If Empty(nTpPagto)
								nTpPagto:= "1" // 1=Varejo;2=Atacado
							Endif

		                    If cPecOLEO <> "O"
		                    	If nDiasPagto <= nAVista .and. nTpPagto == "2"
		                    		cCatPro := "000013" // PECAS ATACADO A VISTA
		                    	ElseIf nDiasPagto > nAVista .and. nTpPagto == "2"
		                    		cCatPro := "000014" // PECAS ATACADO A PRAZO
		                    	ElseIf nDiasPagto <= nAVista .and. nTpPagto == "1"
		                    		cCatPro := "000015" // PECAS VAREJO A VISTA
		                    	ElseIf nDiasPagto > nAVista .and. nTpPagto == "1"
		                    		cCatPro := "000016" // PECAS VAREJO A PRAZO
								Endif
							Else
		                    	If nDiasPagto <= nAVista .and. nTpPagto == "2"
		                    		cCatPro := "000017" // OLEO ATACADO A VISTA
		                    	ElseIf nDiasPagto > nAVista .and. nTpPagto == "2"
		                    		cCatPro := "000017" // OLEO ATACADO A PRAZO
		                    	ElseIf nDiasPagto <= nAVista .and. nTpPagto == "1"
		                    		cCatPro := "000019" // OLEO VAREJO A VISTA
		                    	ElseIf nDiasPagto > nAVista .and. nTpPagto == "1"
		                    		cCatPro := "000020" // OLEO VAREJO A PRAZO
								Endif
							Endif
						Endif

						dbSelectArea("RZE")
						RZE->( dbSetOrder(3) ) // RZE_FILIAL+RZE_VENDED+RZE_CLASSE+RZE_MANUTE
						IF RZE->( dbSeek( xFilial("RZE")+aVends[nJ,2]+cCatPro+cManute ) )

							nPercent := Iif(cTipUso == "G", RZE->RZE_COMISS, RZE->RZE_PERCAN)
							cDesCla := RZE->RZE_DESCAT

							If nPercent > 0

									If cModulo == "ESP1" .Or. cModulo == "ESP"
										RecLock("SC5", .F.)
										If !(nJ == 1 .AND. lXPolCm2 ) //Adicionado por Heimdall Castro (Doit) 16/08/2012
											&("SC5->C5_COMIS" + aVends[nJ, 3]) := nPercent
										EndIf
										SC5->(MsUnLock())

										If !Empty(SC6->C6_NOTA)
											dbSelectArea("SE1")
											dbSetOrder(2)  //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
											// E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
											If dbSeek(xFilial("SE1")+SC5->(C5_CLIENTE+C5_LOJACLI)+xFilial("SC5")+AllTrim(SC6->C6_SERIE)+SC6->C6_NOTA)
												While xFilial("SE1")+SC5->(C5_CLIENTE+C5_LOJACLI)+xFilial("SC5")+AllTrim(SC6->C6_SERIE)+SC6->C6_NOTA == ;
													  SE1->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM) .and. SE1->(!Eof())
													If  !("FIN"$SE1->E1_ORIGEM)
														RecLock("SE1", .F.)
														If lPagaNaBaixa
															&("SE1->E1_VEND" + aVends[nJ, 3]) := aVends[nJ,2]
															If !(nJ == 1 .AND. lXPolCm2 ) //Adicionado por Heimdall Castro (Doit) 16/08/2012
																&("SE1->E1_COMIS" + aVends[nJ, 3]) := nPercent
															EndIf
															If (nJ == 1 .AND. lXPolCm2 )
																&("SE1->E1_COMIS" + aVends[nJ, 3]) := SC6->C6_COMIS1
															EndIf
														Else
															&("SE1->E1_VEND" + aVends[nJ, 3]) := ""
															&("SE1->E1_COMIS" + aVends[nJ, 3]) := 0
														Endif
														SE1->(MsUnLock())
													Endif
													SE1->(dbSkip())
												Enddo
											Endif
										Endif

//										cnItem:="00"
//										For xNN := 1 to Len(aCols)
//											cnItem := soma1(cnItem)
											If SC6->(dbSeek(xFilial("SC6")+cNumPed+aCols[nI,1]))
												RecLock("SC6", .F.)
													If nJ == 1 .AND. lXPolCm2
														&("SC6->C6_XCOMIS1") := nPercent
													Else
														&("SC6->C6_COMIS" + aVends[nJ, 3]) := nPercent
													EndIf
												SC6->(MsUnLock())
											Endif
//										Next xNN

									Endif

									cXCATEGO := AllTrim(Posicione("SA3",1,xFilial("SA3") + aVends[nJ, 2],"A3_XCATEGO"))
								    If cXCATEGO == "05" .and. ; 		 // Gerente Filial  (RZE_CATEGO)
										    	lXPolCom .and. ; 		 // Tem politica de comiss„o
										    	cManute == "MAQ" .and. ; // SÛ para maquinas
										    	!lMaqUsada  	 .and. ; // N„o calcula se for maquina usada
										    	lXPolCm3                 //Calcula a comiss„o do Gerente pela Margem
										GteFilCom(.f.,.t.)
									Else
										DbSelectArea("RZF")
										DbSetOrder(2)
										If DbSeek(xFilial("RZF") + cNumPed + cCliente + cLoja + aCols[nI,nPosIte] + aVends[nJ,2])

											RecLock("RZF", .F.)
											RZF->RZF_FILIAL	:= xFilial("RZF")
											RZF->RZF_PEDIDO	:= cNumPed
											RZF->RZF_TIPUSO	:= cTipUso
											RZF->RZF_CLIENT	:= cCliente
											RZF->RZF_LOJA	:= cLoja
											RZF->RZF_NOME	:= cNomCli
											RZF->RZF_ITEM	:= StrZero(nJ,2)
											RZF->RZF_ITEMPV	:= aCols[nI,nPosIte]
											RZF->RZF_PRODUT	:= Iif(lVendDir,cProduto,aCols[nI,nPosPro])
											RZF->RZF_VENPAI := aVends[nJ,1]
											RZF->RZF_VENDED	:= aVends[nJ,2]
											RZF->RZF_NOMVEN	:= Posicione("SA3",1,xFilial("SA3") + aVends[nJ, 2],"A3_NOME")
											RZF->RZF_VLRBAS	:= aCols[nI,nPosVlr]
											//se for vend1 e se a empresa n„o tem politica de comiss„o,
											//deixa o percentual de zerado pois ser· definido pelo comercial
											If lXPolCm2 .and. aVends[nJ,3] == "1"
												RZF->RZF_COMISS	:= 0
												RZF->RZF_RESULT	:= 0
											Else
												RZF->RZF_COMISS	:= nPercent
												If RZF->RZF_REDUTO <> 0
													nPercent := nPercent * ( ( 100-RZF->RZF_REDUTO ) / 100 )
 												Endif
												RZF->RZF_RESULT	:= nPercent
											Endif

											RZF->RZF_CATEGO	:= Posicione("SA3",1,xFilial("SA3") + aVends[nJ, 2],"A3_XCATEGO")
											RZF->RZF_DESPRO	:= Posicione("SB1",1,xFilial("SB1") + Iif(lVendDir,cProduto,aCols[nI,nPosPro]) ,"B1_DESC")
											RZF->RZF_PRCVEN := 0
											RZF->RZF_PRCCOM	:= 0
											RZF->RZF_MRGLIQ	:= 0
											RZF->RZF_PERTAB	:= 0
											RZF->RZF_NVCALC := 0
											RZF->RZF_DESCAT	:= Posicione("SA3",1,xFilial("SA3") + aVends[nJ, 2],"A3_XDESCAT")
											RZF->RZF_NUMCOM	:= aVends[nJ,3]
											RZF->RZF_USERNA	:= cUserName
											RZF->RZF_DATLOG	:= dDataBase
											RZF->RZF_CLASSE	:= cCatPro
											RZF->RZF_DESCLA	:= cDesCla
											RZF->RZF_MODULO := cModulo
											RZF->RZF_XFIL   := cFilAnt
											RZF->(MsUnLock())
											If nJ == 1
												// Guarda o valor da comiss„o do vendedor 1
												nPVenGe := aCols[nI,nPosVlr] * (nPercent/100)
											Endif
									Endif
	/*
								cXCATEGO := Posicione("SA3",1,xFilial("SA3") + aVends[nJ, 2],"A3_XCATEGO")
								If nJ == 1
									// Guarda o valor da comiss„o do vendedor 1
									nPVenGe := aCols[nI,nPosVlr] * (nPercent/100)
								Endif
							    If cXCATEGO == "05" // Gerente Filial
							    	GteFilCom(.f.,.t.)
	*/
								Endif
							Endif
						Endif
					Endif
				Next nJ
			Next nI

//		Else
//			For nI := 1 To Len(aCols)
//				GteFilCom(.t.,.t.)
//			Next nI

		EndIf

		endif
	ElseIf IsInCallStack( " A410Deleta " )

		cCliente:= SC5->C5_CLIENTE
		cLoja	:= SC5->C5_LOJACLI

		DbSelectArea("RZF")
		DbSetOrder(2)
		//RZF_FILIAL+RZF_PEDIDO+RZF_CLIENT+RZF_LOJA+RZF_ITEMPV+RZF_VENDED+RZF_VENPAI
//		If DbSeek(xFilial("RZF") + cNumPed + cCliente + cLoja + aCols[nI,nPosIte] + aVends[nJ,2])
		If DbSeek(xFilial("RZF") + cNumPed + cCliente + cLoja )
			While !eof() .and. RZF->(RZF_FILIAL+RZF_PEDIDO+RZF_CLIENT+RZF_LOJA) == ;
									xFilial("RZF") + cNumPed + cCliente + cLoja
				RecLock("RZF", .F.)
					DbDelete()
				RZF->(MsUnLock())
				dbSkip()
			Enddo
		EndIf
	EndIf
EndIf

//U_LogComis(cTitulo, cTexto)

RestArea(aAreaSC6)
RestArea(aAreaSC5)
RestArea(aAreaSCJ)
RestArea(aArea)
Return



User Function LogComis(cTitulo, cTexto)
Local aArea		:= GetArea()
Local oDlgLog
Local cFile		:= ""
Local cMask		:= "Arquivos Texto (*.TXT) |*.txt|"

Default cTexto	:= ""
Default cTitulo	:= ""

cTexto		:= "Log de Comiss„o" + CHR(13) + CHR(10) + cTexto  //"Log da atualizacao "
__cFileLog	:= MemoWrite(Criatrab(,.f.) + ".LOG", cTexto)

DEFINE FONT oFont NAME "Mono AS" SIZE 5,12
DEFINE MSDIALOG oDlgLog TITLE cTitulo From 3,0 to 340,417 PIXEL
	@ 5,5 GET oMemo  VAR cTexto MEMO SIZE 200,145 OF oDlgLog PIXEL
	oMemo:bRClicked := {||AllwaysTrue()}
	oMemo:oFont:=oFont
	DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlgLog:End() ENABLE OF oDlgLog PIXEL //Apaga
	DEFINE SBUTTON  FROM 153,145 TYPE 13 ACTION (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) ENABLE OF oDlgLog PIXEL //Salva e Apaga //"Salvar Como..."
ACTIVATE MSDIALOG oDlgLog CENTER

RestArea(aArea)
Return


Static Function GteFilCom(lTexto,lAtualiza, llJob)
/*/f/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
<Descricao> : Faz o Calculo da Comiss„o do Gerente da Filial
<Autor> : Marcelo Montenegro
<Data> : 27/03/2012
<Parametros> : Nenhum
<Retorno> : LÛgico
<Processo> : Maquinas e Implementos
<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ): G
<Obs> :
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/
Local cTitulo	:= "MemÛria de C·lculo Gerente"
Local cTexto	:= ""
Local cXReduVe	:= SuperGetMV("ES_REDUTVE",,"01")
Local nFlat		:= 0
Local nBonus	:= 0
Local nPerGer	:= 0
Local nPGerTo	:= 0
Local nTotPv	:= 0
Local nPrcUlC	:= 0  // PreÁo corrigido da Ultima Compra
Local nValFre	:= 0
Local nValIcm	:= 0

Local nValPis	:= 0
Local nValCof	:= 0

Local nTotPc	:= 0
Local nMgLiq	:= 0
Local nNvCal	:= 0
Local dUlComp	:= StoD("  /  /  ")
Local cQrySD1	:= ""
Local cQryRZ7	:= ""
Local cPedCom	:= ""
Local cItemPc	:= ""
Local cXReduGe	:= SuperGetMV("ES_REDUTGE",,"05")
Local nICCC     := 0
Local dEmissao  := M->C5_EMISSAO
Local nQtDatas  := 26 // Numero de datas de vencimento no pedido de venda
Local cNdata    := "0"
Local nVlMedioC := 0  // Valor medio da Compra (NF) com relaÁ„o a data de vencimento
Local nVlMedioV := 0  // Valor medio da parcela da Venda com relaÁ„o a data de vencimento
Local nVlMediot := 0  // Totalizador do nVlMadio
Local nVDiasMedio:= 0  // Numero de dias medio de todas as parcelas com relacÁ„o a data de Vencimento
Local nCDiasMedio:= 0  // Numero de dias medio de todas as parcelas com relacÁ„o a data de Compra
Local nVlrCompra:= 0
Local nVlVenda  := 0
Local _nTxMes   := (SUPERGETMV("ES_MQCOMCV",,1.00)) // (SUPERGETMV("MV_X_CFIN",,"0.07")) * 30  //taxa de correcao mensal
Local aRetImp   := {}
Local _nVICM    := 0
Local lXPolCm2	:= cModulo == "ESP1" .AND. cEmpAnt $ (GetMV("ES_XPOLCM2",,"")) // Empresas que que n„o grava o vend1 quando for maquina
Local clMsErro	:= ""

Default llJob := .F.

//For nJ := 1 To Len(aVends)
//	DbSelectArea("RZE")
//	DbSetOrder(3)

	If lTexto
		cTexto += "____________________________________________" + Chr(13) + Chr(10)
		cTexto += "Gerente: " + aVends[nJ, 2] + " Categoria: " + cCatPro + " - " + AllTrim(cDCtPro) + Chr(13) + Chr(10)
	Endif

	If !Empty(RZE->RZE_PRODUT)
		If RZE->RZE_PRODUTO <> Iif(lVendDir,cProduto,aCols[nI,nPosPro])
			lProd := .F.
		EndIf
	EndIf

	If !Empty(RZE->RZE_CLIENT)
		If RZE->RZE_CLIENT <> cCliente .Or. RZE->RZE_LOJACL <> cLoja
			lCli := .F.
		EndIf
	EndIf

	If RZE->RZE_MANUTE == "MAQ" .And. lProd .And. lCli
		nPercent := Iif(cTipUso == "G", RZE->RZE_COMISS, RZE->RZE_PERCAN)
		If lTexto
			cTexto += "Percentual Tabela: " + AllTrim(Str(nPercent)) + Chr(13) + Chr(10)
		Endif
	EndIf

	DbSelectArea("SC5")
	DbSetOrder(1)
	DbGoTo(nRegC5)

	DbSelectArea("SCJ")
	DbSetOrder(1)
	If dbSeek(xFilial("SCJ")+AllTrim(SC5->C5_XNUMORC)+cCliente+cLoja)
		dEmissao  := SCJ->CJ_EMISSAO
	Endif
/*
	//Categoria vendedor
	If cXCatego $ cXReduVe
	    nPerVen  :=0
		If RZE->RZE_MANUTE == "MAQ" .OR. RZE->RZE_MANUTE == "PEC"
			nPerVen := Iif(cTipUso == "G", RZE->RZE_COMISS, RZE->RZE_PERCAN)
		EndIf
		nPVenTo	:= (aCols[nI,nPosVlr] * nPerVen) / 100
		nPVenGe	:= nPVenGe + nPVenTo
	EndIf
*/

	//Categoria gerente
	If cXCatego $ cXReduGe  .and. !lVendDir
		//Preco de venda ************************************************************************************************
		DbSelectArea("SC6")
//		DbGoTo(nRegC6)
		dbSeek(xFilial("SC6")+cNumPed+aCols[nI,1])

        If !Empty(SC6->C6_NOTA)
//        	nNJ_Bak := nNJ
//			_nVICM    := Posicione("SF2",2,xFilial("SF2")+SC6->(C6_CLI+C6_LOJA+C6_NOTA+C6_SERIE),"F2_VALICM")
//        	nNJ     := nNJ_Bak

        	NJ_Bak := NJ
			dbSelectArea("SF2")
        	NJ     := NJ_Bak
			dbSetOrder(2) // F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE
			If dbSeek(xFilial("SF2")+SC6->(C6_CLI+C6_LOJA+C6_NOTA+C6_SERIE))
				_nVICM    := SF2->F2_VALICM
			Endif

		Else
			MaFisSave()
			MaFisEnd()
			MaFisIni( M->C5_CLIENTE,M->C5_LOJACLI, "C", "N", M->C5_TIPOCLI ,,,.T.,,"MATA415")

			MaFisAdd(   aCols[nI,nPosPro],;							// 1-Codigo do Produto ( Obrigatorio )
						aCols[nI,nPosTES],;							// 2-Codigo do TES ( Opcional )
						aCols[nI,nPosQTV],;		 					// SC6->C6_QTDVEN 3-Quantidade ( Obrigatorio )
						(aCols[nI,nPosQTV] * aCols[nI,nPosPVD]),;	// SC6->C6_VALOR 4-Preco Unitario ( Obrigatorio )
						0,;		  	 								// 5-Valor do Desconto ( Opcional )
						"",;           	   							// 6-Numero da NF Original ( Devolucao/Benef )
						"",;           								// 7-Serie da NF Original ( Devolucao/Benef )
						0,;			 	   							// 8-RecNo da NF Original no arq SD1/SD2
						0,;			 	   							// 9-Valor do Frete do Item ( Opcional )
						0,;			 								// 10-Valor da Despesa do item ( Opcional )
						0,;			 								// 11-Valor do Seguro do item ( Opcional )
						0,;			 								// 12-Valor do Frete Autonomo ( Opcional )
						(aCols[nI,nPosQTV] * aCols[nI,nPosPVD]),;	// SC6->C6_VALOR 13-Valor da Mercadoria ( Obrigatorio )
						0,;			 								// 14-Valor da Embalagem ( Opiconal )
						Nil,; 		 	   							// 15-RecNo do SB1
						Nil)			 							// 16-RecNo do SF4

			aRetImp := MaFisNFCab()
			MaFisEnd()
			MaFisRestore()

			_nVICM   := Ascan( aRetImp,{|x|Upper(AllTrim(x[1]))=="ICM"})
			If _nVICM > 0
				_nBASICM  := aRetImp[_nVICM][3] // SÛ informativo
				_nALQICM  := aRetImp[_nVICM][4] // SÛ informativo
				_nVICM    := aRetImp[_nVICM][5]
			Endif
		Endif

		nFlat	:= M->C5_XFLAT
		If RZE->RZE_MANUTE == "MAQ" //.OR.   RZE->RZE_MANUTE == "PEC"
			nPerGer	:= Iif(cTipUso == "G", RZE->RZE_COMISS, RZE->RZE_PERCAN)
		EndIf

		If lTexto
			cTexto += "Taxa Flat: " + AllTrim(Transform(nFlat, "@E 999,999,999.99")) + Chr(13) + Chr(10)
			cTexto += "Percentual Gerente: " + AllTrim(Str(nPerGer)) + Chr(13) + Chr(10)
		Endif

 		For xN := 1 to nQtDatas
 			cNdata    := Soma1(cNdata)
 			If &("M->C5_PARC"+cNdata) > 0
	 			nVlMedio  := ( &("M->C5_DATA"+cNdata) - dEmissao ) *  &("M->C5_PARC"+cNdata)
	 			nVlMedioT += nVlMedio
	 		Endif
 		Next xN

		nVDiasMedio  := nVlMedioT/aCols[nI,nPosVlr]

        If nVDiasMedio > 0
	        nVlCorr     := aCols[nI,nPosVlr] / ( ( (_nTxMes  / 100) + 1 ) ** ( nVDiasMedio / 30 ))   //U_SMQ010CORRE(nDiasMedPag ,aCols[nI,nPosVlr] ,cCondPag,dDataBase)
		Else
			nVlCorr     := aCols[nI,nPosVlr]
		Endif

 		nPGerTo	:= (nVlCorr - _nVICM)  * 0.4 / 100  // Percentual de comiss„o dos demais envolvidos (definÁ„o Diego-Supervisor/Adilson-Diretor[Equagril]) - 15/05/2012

//		nTotPv	    := aCols[nI,nPosVlr] - (nFlat + nPVenGe + nPGerTo)
		nTotPv	    := nVlCorr - (_nVICM - nFlat + nPVenGe + nPGerTo)
		//***************************************************************************************************************************


		If lTexto
			cTexto += "Comiss„o Gerente: " + AllTrim(Transform(nPGerTo, "@E 999,999,999.99")) + Chr(13) + Chr(10)
			cTexto += "Comiss„o Vendedor: " + AllTrim(Transform(nPVenTo, "@E 999,999,999.99")) + Chr(13) + Chr(10)
			cTexto += "PreÁo Venda: " + AllTrim(Transform(nTotPv, "@E 999,999,999.99")) + Chr(13) + Chr(10)
		Endif

		nICCC     := Posicione("RZ5",1,xFilial("RZ5")+SC6->C6_NUMSERI,"RZ5_ICCC")      // Indice de correÁ„o de compras de maquinas antigas

/*
		If nICCC == 0

			//Preco de compra
			cQryRZ7 := "SELECT * "
			cQryRZ7 += "FROM "
			cQryRZ7 += 		RetSqlName("RZ7") + " "
			cQryRZ7 += "WHERE "
			cQryRZ7 += "	RZ7_FILIAL = '" + xFilial("RZ7") + "' AND "
			cQryRZ7 += " 	RZ7_CHASSI = '" + aCols[nI,nPosCha] + "' AND "
			cQryRZ7 += "	RZ7_CODIGO = '" + Iif(lVendDir,cProduto,aCols[nI,nPosPro]) + "' AND "
	//		cQryRZ7 += "	RZ7_USERID = '" + __cUserId + "' AND "
			cQryRZ7 += "	D_E_L_E_T_ = ' ' "

			cQryRZ7 := ChangeQuery(cQryRZ7)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryRZ7),"QRYRZ7",.F.,.T.)
			DbSelectArea("QRYRZ7")

//			nPrcUlC := Iif(QRYRZ7->RZ7_CORRE > 0, QRYRZ7->RZ7_CORRE, QRYRZ7->RZ7_CUSTO)

			If QRYRZ7->RZ7_CORRE > 0
				nPrcUlC := QRYRZ7->RZ7_CORRE
			//						nPrcUlC	:= Posicione("SB1", 1, xFilial("SB1") + aCols[nI,nPosPro], "B1_UPRC")
			//						dUlComp	:= DtoS(Posicione("SB1", 1, xfilial("SB1") + aCols[nI,nPosPro], "B1_UCOM"))
			Else

				cQrySDB := " SELECT DISTINCT F1_EMISSAO, F1_VALBRUT "
				cQrySDB += " FROM "
				cQrySDB +=  	RetSqlName("SDB") + " SDB "
				cQrySDB += " JOIN "
				cQrySDB += 		RetSqlName("SF1") + " SF1 ON "
				cQrySDB += " 	SF1.F1_FILIAL = '" + xFilial("SF1") + "' AND "
				cQrySDB += " 	SF1.F1_TIPO   = 'N'           AND "
				cQrySDB += " 	SF1.F1_DOC    = SDB.DB_DOC    AND "
				cQrySDB += " 	SF1.F1_SERIE  = SDB.DB_SERIE  AND "
				cQrySDB += " 	SF1.F1_FORNECE= SDB.DB_CLIFOR AND "
				cQrySDB += " 	SF1.F1_LOJA   = SDB.DB_LOJA   AND "
				cQrySDB += " 	SF1.D_E_L_E_T_ = ' ' "
				cQrySDB += " WHERE "
				cQrySDB += " 	SDB.DB_FILIAL  = '" + xFilial("SDB") + "' AND "
				cQrySDB += "	SDB.DB_PRODUTO = '" + Iif(lVendDir,cProduto,aCols[nI,nPosPro])  + "' AND "
				cQrySDB += "	SDB.DB_NUMSERI = '" + aCols[nI,nPosCha] + "' AND "
				cQrySDB += "	SDB.D_E_L_E_T_ = ' ' "

				cQrySDB := ChangeQuery(cQrySDB)

				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySDB),"QRYSDB",.F.,.T.)
				DbSelectArea("QRYSDB")

			    If !QRYSDB->(Eof())
//					dtCompra:= 	Iif( !QRYSDB->(Eof()) , stod(QRYSDB->F1_EMISSAO), dtOrc)
					dtCompra  := stod(QRYSDB->F1_EMISSAO)
				  	nVlrCompra:=  QRYSDB->F1_VALBRUT
					nVlMedio  := ( dtOrc - dtCompra ) *  nVlrCompra

					nCDiasMedio  := nVlMedio/nVlrCompra

			        nPrcUlC :=   nVlrCompra * ((_nTxMes / 100 + 1 ) ** ( nCDiasMedio / 30 ))
		        Else
					Final("N„o foi loclizada a NF de compra para a maquina "+ Iif(lVendDir,cProduto,aCols[nI,nPosPro]) +" serie "+ aCols[nI,nPosCha]+". O sistema ser· finalizado.")
				Endif

				QRYSDB->(DbCloseArea())

			Endif

			QRYRZ7->(DbCloseArea())

		Else
*/
			//Preco de compra ***************************************************************************************************
			cQrySD1 := "SELECT "
			cQrySD1 += "	F1_VALMERC, "
			cQrySD1 += "	(D1_VALICM/D1_QUANT)        D1_VALICM, "
			cQrySD1 += "	D1_VUNIT                    D1_TOTAL, "
			cQrySD1 += "	(E2_VALOR/D1_QUANT)         E2_VALOR, "
			cQrySD1 += "	E2_VENCREA, "
			cQrySD1 += "	NVL((C7_XBONUS/D1_QUANT),0) C7_XBONUS, "
			cQrySD1 += "	(D1_VALFRE/D1_QUANT)        D1_VALFRE, "
			cQrySD1 += "	D1_PEDIDO, "
			cQrySD1 += "	D1_ITEMPC  "
			cQrySD1 += "FROM "
			cQrySD1 += 		RetSqlName("SDB") + " SDB "
			cQrySD1 += "		Left Join "
			cQrySD1 += 		RetSqlName("SD1") + " SD1 ON "
//			cQrySD1 += " 		D1_FILIAL  = DB_FILIAL  AND "
			cQrySD1 += " 		D1_COD     = DB_PRODUTO AND "
			cQrySD1 += " 		D1_DOC     = DB_DOC     AND "
			cQrySD1 += " 		D1_SERIE   = DB_SERIE   AND "
			cQrySD1 += " 		D1_NUMSEQ  = DB_NUMSEQ  AND "
			cQrySD1 += " 		D1_FORNECE = DB_CLIFOR  AND "
			cQrySD1 += " 		D1_LOJA    = DB_LOJA    AND "
			cQrySD1 += " 		SD1.D_E_L_E_T_ = ' ' "
			cQrySD1 += "		Left Join "
			cQrySD1 += 		RetSqlName("SF1") + " SF1 ON "
			cQrySD1 += "		F1_FILIAL = DB_FILIAL AND "
			cQrySD1 += "		F1_DOC    = D1_DOC    AND "
			cQrySD1 += "		F1_SERIE  = D1_SERIE  AND "
			cQrySD1 += "		F1_FORNECE= D1_FORNECE AND "
			cQrySD1 += "		F1_LOJA   = D1_LOJA   AND "
			cQrySD1 += "		SF1.D_E_L_E_T_ = ' ' "
			cQrySD1 += "		Left Join "
			cQrySD1 += 		RetSqlName("SE2") + " SE2 ON "
			cQrySD1 += "		E2_PREFIXO = F1_FILIAL  AND "
			cQrySD1 += "		E2_NUM     = F1_DUPL    AND "
			cQrySD1 += "		E2_FORNECE = F1_FORNECE AND "
			cQrySD1 += "		E2_LOJA    = F1_LOJA    AND "
			cQrySD1 += "		SE2.D_E_L_E_T_ = ' ' "
			cQrySD1 += "		Left Join "
			cQrySD1 += 		RetSqlName("SC7") + " SC7 ON"
			cQrySD1 += "		C7_FILIAL = '" + xFilial("SC7") + "' AND "
			cQrySD1 += "		C7_PRODUTO = DB_PRODUTO AND "
			cQrySD1 += "		C7_NUM     = D1_PEDIDO  AND "
			cQrySD1 += "		C7_ITEM    = D1_ITEMPC  AND "
			cQrySD1 += "		SC7.D_E_L_E_T_ = ' ' "
			cQrySD1 += "WHERE "
//			cQrySD1 += " 	DB_FILIAL  = '" + xFilial("SDB")    + "' AND "
			cQrySD1 += "	DB_PRODUTO = '" + Iif(lVendDir,cProduto,aCols[nI,nPosPro])  + "' AND "
			cQrySD1 += "	DB_NUMSERI = '" + aCols[nI,nPosCha] + "' AND "
			cQrySD1 += "	DB_ORIGEM  = 'SD1' AND "
			cQrySD1 += "	DB_ESTORNO = ' '   AND "
			cQrySD1 += "	SDB.D_E_L_E_T_ = ' ' "

			cQrySD1 := ChangeQuery(cQrySD1)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySD1),"QRYSD1",.F.,.T.)
			DbSelectArea("QRYSD1")

			If !QRYSD1->(Eof()) .and. QRYSD1->E2_VALOR > 0 .and. QRYSD1->D1_TOTAL > 0

				nVlMedio := nVlMedioT := nCDiasMedio := nVlrCompra := nVlNF := nBonus:= nValICM := 0
				While !Eof()
					nVlNF    := QRYSD1->D1_TOTAL
				    nVlMedio := QRYSD1->D1_TOTAL / QRYSD1->F1_VALMERC * QRYSD1->E2_VALOR  // Faz o calculo proporcional da parcela caso a nota tenha mais de um equipamento
					nVlrCompra += nVlMedio
//					nVlMedio := (STOD(QRYSD1->C7_EMISSAO) - STOD(QRYSD1->E2_VENCREA)) * nVlMedio
					nVlMedio := (dEmissao  - STOD(QRYSD1->E2_VENCREA)) * nVlMedio
					nVlMedioT += nVlMedio
					nBonus   := QRYSD1->C7_XBONUS
					nValFre  := QRYSD1->D1_VALFRE
					nValIcm  := QRYSD1->D1_VALICM
					cPedCom  := QRYSD1->D1_PEDIDO
					cItemPc  := QRYSD1->D1_ITEMPC
					dbSkip()
				Enddo
                nVlrCompra := Iif( nVlNF <> nVlrCompra, nVlNF ,nVlrCompra)
				nCDiasMedio  := nVlMedioT/nVlrCompra

		        nPrcUlC :=   (nVlrCompra-nBonus) * ( ( (Iif(nICCC == 0, _nTxMes, nICCC )  / 100 ) + 1 ) ** ( nCDiasMedio / 30 ) )
	        Else
	        	If QRYSD1->E2_VALOR == 0
//		        	Aviso("Titulo n„o localizado","N„o foi localizado o Titulo a Receber da NF de compra para a maquina "+ Iif(lVendDir,cProduto,aCols[nI,nPosPro]) +" serie "+ aCols[nI,nPosCha]+".!",{"Continuar"})

					clMsErro := "Pedido: " + cNumPed + " - N„o foi localizado o Titulo a Receber da NF de compra para a maquina "+ Iif(lVendDir,cProduto,aCols[nI,nPosPro]) +" serie "+ aCols[nI,nPosCha]+". O sistema ser· finalizado."
					U_SFATV002(cpNomeLog, "ERRO - "+clMsErro, .T., .T.)

					if !llJob
						Final( clMsErro )
					endif
				ElseIf QRYSD1->D1_TOTAL == 0
//		        	Aviso("NF n„o localizada","N„o foi localizada a NF de compra para a maquina "+ Iif(lVendDir,cProduto,aCols[nI,nPosPro]) +" serie "+ aCols[nI,nPosCha]+".!",{"Continuar"})

    				clMsErro := "Pedido: " + cNumPed + " - N„o foi localizada a NF de compra para a maquina "+ Iif(lVendDir,cProduto,aCols[nI,nPosPro]) +" serie "+ aCols[nI,nPosCha]+". O sistema ser· finalizado."
					U_SFATV002(cpNomeLog, "ERRO - "+clMsErro, .T., .T.)

					if !llJob
						Final( clMsErro )
					endif
				Endif
			Endif

			DbSelectArea("QRYSD1")
			QRYSD1->(DbCloseArea())

//		Endif                                                                                  '

		If lTexto
			cTexto += "PreÁo Ultima Compra: " + AllTrim(Transform(nPrcUlC, "@E 999,999,999.99")) + Chr(13) + Chr(10)
		Endif
/*
		cQrySD1 := " SELECT MAX(SD1.R_E_C_N_O_) RECSD1 "
		cQrySD1 += " FROM "
		cQrySD1 +=  	RetSqlName("SDB") + " SDB "
		cQrySD1 += " JOIN "
		cQrySD1 += 		RetSqlName("SD1") + " SD1 ON "
		cQrySD1 += " 	D1_FILIAL  = DB_FILIAL AND "
		cQrySD1 += " 	D1_DOC     = DB_DOC AND "
		cQrySD1 += " 	D1_SERIE   = DB_SERIE AND
		cQrySD1 += " 	D1_FORNECE = DB_CLIFOR AND "
		cQrySD1 += " 	D1_LOJA    = DB_LOJA   AND "
		cQrySD1 += " 	SD1.D_E_L_E_T_ = ' ' "
		cQrySD1 += " WHERE "
		cQrySD1 += " 	DB_FILIAL  = '" + xFilial("SDB")    + "' AND "
		cQrySD1 += "	DB_PRODUTO = '" + Iif(lVendDir,cProduto,aCols[nI,nPosPro])  + "' AND "
		cQrySD1 += "	DB_NUMSERI = '" + aCols[nI,nPosCha] + "' AND "
		cQrySD1 += "	SDB.D_E_L_E_T_ = ' ' "

		cQrySD1 := ChangeQuery(cQrySD1)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySD1),"QRYSD1",.F.,.T.)
		DbSelectArea("QRYSD1")

		If !QRYSD1->(Eof())
			DbSelectArea("SD1")
			DbSetOrder(1)
			DbGoTo(QRYSD1->RECSD1)

***			nValFre := SD1->D1_VALFRE
***			nValIcm := SD1->D1_VALICM

***			cPedCom := SD1->D1_PEDIDO
***			cItemPc := SD1->D1_ITEMPC

			If lTexto
				cTexto += "Valor Frete: " + AllTrim(Transform(nValFre, "@E 999,999,999.99")) + Chr(13) + Chr(10)
				cTexto += "Valor ICMS: " + AllTrim(Transform(nValIcm, "@E 999,999,999.99")) + Chr(13) + Chr(10)
			Endif

		EndIf

		DbSelectArea("QRYSD1")
		QRYSD1->(DbCloseArea())

		DbSelectArea("SC7")
		DbSetOrder(1)
		If DbSeek(xFilial("SC7") + cPedCom + cItemPc)
			nBonus := SC7->C7_XBONUS
			If lTexto
				cTexto += "Valor BÙnus: " + AllTrim(Transform(nBonus, "@E 999,999,999.99")) + Chr(13) + Chr(10)
			Endif
		EndIf
*/
		If lTexto
			cTexto += "Valor Frete: " + AllTrim(Transform(nValFre, "@E 999,999,999.99")) + Chr(13) + Chr(10)
			cTexto += "Valor ICMS: " + AllTrim(Transform(nValIcm, "@E 999,999,999.99")) + Chr(13) + Chr(10)
			cTexto += "Valor BÙnus: " + AllTrim(Transform(nBonus, "@E 999,999,999.99")) + Chr(13) + Chr(10)
		Endif

		nTotPc := (nPrcUlC + nValFre) - (nValIcm)

		If lTexto
			cTexto += "PreÁo de Compra: " + AllTrim(Transform(nTotPc, "@E 999,999,999.99")) + Chr(13) + Chr(10)
		Endif

		nMgLiq := nTotPv - nTotPc

		If lTexto
			cTexto += "Margem LÌquida: " + AllTrim(Transform(nMgLiq, "@E 999,999,999.99")) + Chr(13) + Chr(10)
		Endif
		// Novo percentual
		nNvCal := (nMgLiq * nPerGer) / aCols[nI,nPosVlr]

		If lTexto
			cTexto += "Novo Percentual Calculado: " + AllTrim(Str(nNvCal)) + Chr(13) + Chr(10)
		Endif

		nPercent := nNvCal

	Else

		If RZE->RZE_MANUTE == "MAQ" //.OR.   RZE->RZE_MANUTE == "PEC"
			nPerGer	:= Iif(cTipUso == "G", RZE->RZE_COMISS, RZE->RZE_PERCAN)
		EndIf

		nTotPv 		:= nVlCorr := SCK->CK_VALOR
	    nMgLiq 		:= aCols[nI,nPosVlr]
	    nTotPc 		:= nTotPv - nMgLiq
	    nVlrCompra	:= nTotPc
	    nNvCal 		:= nPerGer
		nPercent    := nNvCal

		If lTexto
			cTexto += "Taxa Flat: "					+ AllTrim(Transform(nFlat, "@E 999,999,999.99")) + Chr(13) + Chr(10)
			cTexto += "Percentual Gerente: " 		+ AllTrim(Str(nPerGer)) + Chr(13) + Chr(10)
			cTexto += "Comiss„o Gerente: " 			+ AllTrim(Transform(nPGerTo, "@E 999,999,999.99")) + Chr(13) + Chr(10)
			cTexto += "Comiss„o Vendedor: " 		+ AllTrim(Transform(nPVenTo, "@E 999,999,999.99")) + Chr(13) + Chr(10)
			cTexto += "PreÁo Venda: " 				+ AllTrim(Transform(nTotPv, "@E 999,999,999.99")) + Chr(13) + Chr(10)
			cTexto += "PreÁo Ultima Compra: " 		+ AllTrim(Transform(nPrcUlC, "@E 999,999,999.99")) + Chr(13) + Chr(10)
			cTexto += "Valor Frete: " 				+ AllTrim(Transform(nValFre, "@E 999,999,999.99")) + Chr(13) + Chr(10)
			cTexto += "Valor ICMS: " 				+ AllTrim(Transform(nValIcm, "@E 999,999,999.99")) + Chr(13) + Chr(10)
			cTexto += "Valor BÙnus: " 				+ AllTrim(Transform(nBonus, "@E 999,999,999.99")) + Chr(13) + Chr(10)
			cTexto += "PreÁo de Compra: " 			+ AllTrim(Transform(nTotPc, "@E 999,999,999.99")) + Chr(13) + Chr(10)
			cTexto += "Margem LÌquida: " 			+ AllTrim(Transform(nMgLiq, "@E 999,999,999.99")) + Chr(13) + Chr(10)
			cTexto += "Novo Percentual Calculado: " + AllTrim(Str(nNvCal)) + Chr(13) + Chr(10)
		Endif

	EndIf

	lAchou := .F.
	If lAtualiza
		DbSelectArea("RZF")
		DbSetOrder(2)
		lAchou := DbSeek(xFilial("RZF") + cNumPed + cCliente + cLoja + aCols[nI,nPosIte] + aVends[nJ,2])

		RecLock("RZF", !lAchou)
	Else
		DbSelectArea("RZF")
		DbSetOrder(1)

		RecLock("RZF", .T.)
	Endif
		RZF->RZF_FILIAL	:= xFilial("RZF")
		RZF->RZF_PEDIDO	:= cNumPed
		RZF->RZF_TIPUSO	:= cTipUso
		RZF->RZF_CLIENT	:= cCliente
		RZF->RZF_LOJA	:= cLoja
		RZF->RZF_NOME	:= cNomCli
		RZF->RZF_ITEM	:= StrZero(nJ,2)
		RZF->RZF_ITEMPV	:= aCols[nI,nPosIte]
		RZF->RZF_PRODUT	:= Iif(lVendDir,cProduto,aCols[nI,nPosPro])
		RZF->RZF_VENPAI := aVends[nJ,1]
		RZF->RZF_VENDED	:= aVends[nJ,2]
		RZF->RZF_NOMVEN	:= Posicione("SA3",1,xFilial("SA3") + aVends[nJ, 2],"A3_NOME")
		RZF->RZF_VLRBAS	:= aCols[nI,nPosVlr]
		RZF->RZF_COMISS	:= nPercent
		If lAchou .and. RZF->RZF_REDUTO <> 0
			nPercent := nPercent * ( ( 100-RZF->RZF_REDUTO ) / 100 )
		Else
			RZF->RZF_REDUTO := 0
		Endif
		RZF->RZF_RESULT	:= nPercent
		RZF->RZF_CATEGO	:= cXCatego
		RZF->RZF_DESPRO	:= Posicione("SB1",1,xFilial("SB1") + Iif(lVendDir,cProduto,aCols[nI,nPosPro]) ,"B1_DESC")

		RZF->RZF_PRCNF 	:= nVlrCompra   								// VALOR NOTA FISCAL DE COMPRA
		RZF->RZF_DIAMDC	:= nCDiasMedio  								// DIAS MEDIO
 		RZF->RZF_VLFRET	:= nValFre       								//
		RZF->RZF_VLICM 	:= nValIcm       								//
		RZF->RZF_VLBONU	:= nBonus        								//
		RZF->RZF_PRCCOM	:= nTotPc	   									// VALOR NOTA FISCAL DE COMPRA + FRETE - ICM - BONUS
		RZF->RZF_IDCORC	:= Iif(nICCC<>0, nICCC, _nTxMes)  				//  Indice de correÁ„o de compra

		RZF->RZF_VLVEND := Iif(lVendDir,aCols[nI,nPosVlr],nTotPv)      //nVlCorr - (nFlat + nPVenGe + nPGerTo)
		RZF->RZF_DIAMDV := Iif(nVDiasMedio > 0, nVDiasMedio ,0)        //
		RZF->RZF_PRVDCR := nVlCorr                                     //
		RZF->RZF_XFLAT  := nFlat                                       //
		RZF->RZF_COMVEN := nPVenGe                                     //
		RZF->RZF_COMGTE := nPGerTo                                     //
		RZF->RZF_VLICMV := _nVICM                                      //  criar campo
		RZF->RZF_IDCORV := _nTxMes // Indice de correÁ„o de venda

		RZF->RZF_MRGLIQ	:= nMgLiq                                     // nTotPv - nTotPc
		RZF->RZF_PERTAB	:= nPerGer                                    //
		RZF->RZF_NVCALC := nNvCal                                     //
		RZF->RZF_DESCAT	:= Posicione("SA3",1,xFilial("SA3") + aVends[nJ, 2],"A3_XDESCAT")
		RZF->RZF_NUMCOM	:= aVends[nJ,3]
		RZF->RZF_USERNA	:= cUserName
		RZF->RZF_DATLOG	:= dDataBase
		RZF->RZF_CLASSE	:= cCatPro
		RZF->RZF_DESCLA	:= cDesCla
		RZF->RZF_MODULO := cModulo
		RZF->RZF_XFIL   := cFilAnt

	RZF->(MsUnLock())

	If !(nJ == 1 .AND. lXPolCm2 ) //Adicionado por Heimdall Castro (Doit) 16/08/2012
		RecLock("SC5", .F.)
			&("SC5->C5_COMIS" + aVends[nJ, 3]) := Iif(nPercent > 0, nPercent, 0 )
		SC5->(MsUnLock())
	EndIf

	DbSelectArea("SC6")
	DbSetOrder(1)

	If SC6->(dbSeek(xFilial("SC6")+cNumPed+aCols[nI,1]))
		RecLock("SC6", .F.)
		If nJ == 1 .AND. lXPolCm2  //Adicionado por Heimdall Castro (Doit) 16/08/2012
			&("SC6->C6_XCOMIS" + aVends[nJ, 3]) := Iif(nPercent > 0, nPercent, 0 )
		Else
			&("SC6->C6_COMIS" + aVends[nJ, 3]) := Iif(nPercent > 0, nPercent, 0 )
		EndIf

		SC6->(MsUnLock())
		DbSelectArea("SD2")
		SD2->(DbSetOrder(3)) // 3-D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD    +D2_ITEM
		If SD2->(DbSeek(xFilial("SD2")+SC6->C6_NOTA+SC6->C6_SERIE+SC6->C6_CLI+SC6->C6_LOJA+SC6->C6_PRODUTO))
			RecLock( "SD2",.F.)
				&("SD2->D2_COMIS" + aVends[nJ, 3] ) := nPercent
			SD2->(MsUnLock())
		Endif
		njBak := nj
		DbSelectArea("SF2")
		SF2->(DbSetOrder(1)) // 1-F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
		nj:= njBak
		If SF2->(DbSeek(xFilial("SF2")+SC6->C6_NOTA+SC6->C6_SERIE+SC6->C6_CLI+SC6->C6_LOJA))
			dbSelectArea("SE1")
			dbSetOrder(1)  //1-E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO //2- E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
			If dbSeek(xFilial("SE1")+ SF2->F2_PREFIXO + SC6->C6_NOTA )
				While xFilial("SE1")+ SF2->F2_PREFIXO + SC6->C6_NOTA  == SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM) .and. SE1->(!Eof())
					If !("FIN"$SE1->E1_ORIGEM)
							dbSelectArea("SE1")
							RecLock("SE1", .F.)
								&("SE1->E1_COMIS" + aVends[nJ, 3]) := Iif(nPercent > 0, nPercent, 0 )
							SE1->(MsUnLock())
					Endif
					SE1->( dbSkip() )
				Enddo
			Endif
		Endif
	Endif
/*
	DbGoTo(nRegC6)

	RecLock("SC6", .F.)
		&("SC6->C6_COMIS" + aVends[nJ, 3]) := nPercent
	SC6->(MsUnLock())
*/

	If lTexto
		cTexto += "____________________________________________" + Chr(13) + Chr(10)
		cTexto += "Log de Usu·rio" + Chr(13) + Chr(10)
		cTexto += "Usu·rio: " + cUserName + Chr(13) + Chr(10)
		cTexto += "Data: " + DtoC(dDataBase) + Chr(13) + Chr(10)

		MSMM(,150,,cTexto,1,,,"RZF","RZF_MEMCAL")
	Endif
//Next nJ

Return

//*******************************************************************************************************
//* 21/12/2012                                                                                          *
//* Autor: Sergio Artero                                                                                *
//* Solicitante: Luiz Favareto (Pai)                                                                    *
//* Regra para vendedor 000091                                                                          *
//* Se a emissao for menor que 21/11/2012, nao gerar comissao. Essa regra foi necessaria para nao gerar *
//* comissao antes da admissao deste vendedor.                                                          *
//*******************************************************************************************************
Static Function FVEND91( clVend, cDupl, cCliente, cLoja )

	Local llOk := .T.
	Local alAreaSF2 := {}

	if clVend == "000091" .And. cEmpAnt == '11'

		dbSelectArea("SF2")
		alAreaSF2 := SF2->( GetArea() )
		SF2->( dbSetOrder(2) ) //F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE
		if SF2->( dbSeek( xFilial("SF2") + cCliente + cLoja + cDupl ) )

			if SF2->F2_EMISSAO < StoD('20121121')
				llOk := .F.
			endif

		endif

		RestArea( alAreaSF2 )

	endif

Return llOk

User Function CComiss(lLoja, llJob)
/*/f/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
<Descricao> : Esta rotina tem o objetivo de refazer a cadeia de comiss„o a partir do Vend1 digitado na capa do pedido de venda e seus percentuais
<Autor> : Marcelo Montenegro
<Data> : 04/05/2012
<Parametros> : 	Nenhum
<Retorno> : Nenhum
<Processo> : Especifico Grupo Shark - Manutencao do modulo de oficina
<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : G
<Obs> :
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/

Local aArea		:= GetArea()
Local aAreaSC5	:= SC5->(GetArea())
Local aAreaSC6	:= SC6->(GetArea())
Local cAlias    := ""
Local cDtEmissa //:= If(!Empty(M->C5_XNUMORC) .and. cModulo $ "ESP/ESP1", Posicione("SCJ",1,xFilial("SCJ")+AllTrim(M->C5_XNUMORC),"CJ_EMISSAO"), M->C5_EMISSAO)
Local cNumOrc	:= If(Empty(M->C5_XNUMORC) .and. cModulo $ "ESP/ESP1", Space(TamSx3("CJ_NUM")[1]) , SubStr(M->C5_XNUMORC,1,TamSx3("CJ_NUM")[1] ) )
//Local cNumOrc	:= If(Empty(M->C5_XNUMORC) .and. cModulo $ "ESP/ESP1", SCJ->CJ_NUM, M->C5_XNUMORC)
Local lXPolCom	:= SM0->M0_CODIGO $ SuperGetMV("ES_XPOLCOM",,"") //Empresas que possuem politica de comissoes Agricola
Local lXPolCm2	:= cModulo == "ESP1" .AND. cEmpAnt $ (GetMV("ES_XPOLCM2",,"")) // Empresas que que n„o grava o vend1 quando for maquina
Local lXPolCm3	:= SuperGetMV("ES_XPOLCM3",,.F.) //Calcula a comiss„o do Gerente pela Margem
Local cVend1	:= M->C5_VEND1
Local cVend2	:= ""
Local cVend3	:= ""
Local cVend4	:= ""
Local cVend5	:= ""
Local cVend6	:= ""
Local cVend7	:= ""
Local cVend8	:= ""
Local cVend9	:= ""
Local lOK       := .T.
Local alInfoCli	:= {}
Local cPecOLEO  := ""
Local nAVista 	:= SuperGetMV("ES_AVISTA",,14) // dias que considera pagamento a vista
Local lMaqUsada := .F.
Local lCalcGer  := .F.
Local lAchou    := .F.
Local nPosCom   := 0
Local cnItem    := "01"
Local lPagaComissao := .F.
Local lPagaNaBaixa  := .F.
Local cQuery    := ""
Local lParcelado:= .F.
Local cDupl 	:= Space(TamSx3("E1_NUM")[1])
Local cSerie	:= Space(TamSx3("C6_SERIE")[1])
Local cPrefixo	:= Space(TamSx3("E1_PREFIXO")[1])
Local cVendsPed	:= ""
Local c
Local clMsErro	:= ""

Private cCatPro	:= ""
Private cXCATEGO  := ""
Private cDCtPro	:= ""
Private nRegC6	:= 0
Private nRegC5	:= SC5->(Recno())
Private nPosPro	:= aScan(aHeader,{|x| x[2] == "C6_PRODUTO"}) // 2
Private nPosTES	:= aScan(aHeader,{|x| x[2] == "C6_TES    "})
Private nPosIte	:= aScan(aHeader,{|x| x[2] == "C6_ITEM   "}) // 1
Private nPosCha	:= aScan(aHeader,{|x| x[2] == "C6_NUMSERI"}) // 34
Private nPosVlr	:= aScan(aHeader,{|x| x[2] == "C6_VALOR  "}) // 8
Private nPosQTV	:= aScan(aHeader,{|x| x[2] == "C6_QTDVEN "})
Private nPosPVD	:= aScan(aHeader,{|x| x[2] == "C6_PRCVEN "})
Private nI		:= 0
Private nJ		:= 0
Private cNumPed	:= M->C5_NUM
Private cCliente:= M->C5_CLIENTE
Private cLoja	:= M->C5_LOJACLI
Private cTipUso	:= M->C5_XTIPUSO
Private cNomCli	:= Posicione("SA1", 1, xFilial("SA1") + cCliente + cLoja, "A1_NOME")
Private aVends	:= {}
Private cManute := cDesCla := ""
Private lProd	:= .T.
Private lCli	:= .T.
Private nPercent:= 0
Private nPVenGe := 0
Private dtOrc   := ctod("  /  /  ")
Private cCondPag:= M->C5_CONDPAG
Private cProduto:= Space(TamSx3("CK_PRODUTO")[1]) //Iif(M->CJ_XFATVDI == "S", M->CJ_PRODUTO ,Space(TamSx3("CK_PRODUTO")[1]))
Private lVendDir:= .T. //M->CJ_XFATVDI == "S" // venda direta
Private cDCtPro	:= ""

Default lLoja		:= .F.
Default llJob		:= .F.

If !Empty(M->C5_XNUMORC) .and. cModulo $ "ESP/ESP1"
	SCJ->( dbSetOrder(1) )
    If SCJ->( dbSeek( xFilial("SCJ") + cNumOrc ) )
		cDtEmissa := SCJ->CJ_EMISSAO
		lVendDir:= SCJ->CJ_XFATVDI == "S"
		If SCJ->CJ_XFATVDI == "S"
//			cProduto:= SCK->CK_PRODUTO
		Endif
	Endif
Else
	cDtEmissa := M->C5_EMISSAO
Endif

// Verifica se o pedido j· foi pago, se j· foi pago n„o calcula
/*
cAlias := GetNextAlias()
cQuery :=  "SELECT "
cQuery +=  "	 Count(E3.R_E_C_N_O_) nRec "
cQuery +=  "FROM "
cQuery +=  "	"+RetSqlName("SE3")+" E3 "
cQuery +=  "WHERE "
cQuery +=  "		E3_XFILIAL = '"+ cFilAnt   +"' "
cQuery +=  "	AND E3_PEDIDO  = '"+ cNumPed   +"' "
cQuery +=  "	AND E3_CODCLI  = '"+ cCliente  +"' "
cQuery +=  "	AND E3_LOJA    = '"+ cLoja     +"' "
cQuery +=  "	AND E3_DATA   <> ' ' "
cQuery +=  "	AND E3.D_E_L_E_T_ = ' '	"

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

lOk := (cAlias)->nRec == 0

(cAlias)->(DbCloseArea())
*/

lOk := !( Posicione("SA1", 1, xFilial("SA1") + cCliente + cLoja, "A1_XEMPGRU") == '1' ) // Se for empresa do grupo, n„o gera comiss„o

If lOk

	if !( Type("cpNomeLog") == "C" )
		cpNomeLog := ""
	endif

	If !lLoja
		lLoja := !Empty(Alltrim(SC5->C5_XPECSL1))
	Endif

	If !lLoja
		dbSelectArea("SC6")
		SC6->( dbSetOrder(1) )
		SC6->( dbSeek(xFilial("SC6")+cNumPed) )
		nRegC6	:= SC6->(Recno())
	Endif

	If cModulo == "ESP1"
		cManute := "MAQ"
		cCampo := "A3_XAPMAQ"
	ElseIf cModulo == "ESP" .or. cModulo == "LOJ"
		cManute := "PEC"
		cCampo := "A3_XAPPEC"
	ElseIf cModulo == "ESP2"
		cManute := "SER"
		cCampo := "A3_XAPSERV"
	EndIf

	If Empty(Posicione("SA3",1,xFilial("SA3")+M->C5_VEND1,cCampo))

		clMsErro := "Pedido: " + cNumPed + " - A estrutura de vendas/participantes do "+M->C5_VEND1+"-"+cManute+" n„o est· aprovada. Ser· necess·rio aprovar antes de gerar um pedido de vendas."
		U_SFATV002(cpNomeLog, "ERRO - "+clMsErro, .T., .T.)

		if !llJob
			MsgAlert( clMsErro )
		endif

		Return
	Endif

	cBkp := __ReadVar

	__ReadVar:= 'M->C5_VEND1'
	If ExistTrigger("C5_VEND1")
		RunTrigger(1,,,,Padr("C5_VEND1",10))
	Endif

	//***********************************************************************************************************
	//* Foi necessario declarar esta variavel quando o processamento for em Job para executar a funcao CheckSX3 *
	//***********************************************************************************************************
	if llJob
		aGets	:= {}
	endif
	CheckSX3("C5_VEND1")

	__ReadVar:= cBkp

	cVend1	:= M->C5_VEND1
	cVend2	:= M->C5_VEND2
	cVend3	:= M->C5_VEND3
	cVend4	:= M->C5_VEND4
	cVend5	:= M->C5_VEND5
	cVend6	:= M->C5_VEND6
	cVend7	:= M->C5_VEND7
	cVend8	:= M->C5_VEND8
	cVend9	:= M->C5_VEND9


	If !Empty(cVend1).and. u_VerVendFer(cVend1,cDtEmissa)
		aAdd(aVends, {cVend1,cVend1, "1"})
		cVendsPed += ",'"+cVend1+"'"
	EndIf

	If !Empty(cVend2) .and. u_VerVendFer(cVend2,cDtEmissa)
		aAdd(aVends, {cVend1,cVend2, "2"})
		cVendsPed += ",'"+cVend2+"'"
	EndIf

	If !Empty(cVend3) .and. u_VerVendFer(cVend3,cDtEmissa)
		aAdd(aVends, {cVend1,cVend3, "3"})
		cVendsPed += ",'"+cVend3+"'"
	EndIf

	If !Empty(cVend4) .and. u_VerVendFer(cVend4,cDtEmissa)
		aAdd(aVends, {cVend1,cVend4, "4"})
		cVendsPed += ",'"+cVend4+"'"
	EndIf

	If !Empty(cVend5) .and. u_VerVendFer(cVend5,cDtEmissa)
		aAdd(aVends, {cVend1,cVend5, "5"})
		cVendsPed += ",'"+cVend5+"'"
	EndIf

	If !Empty(cVend6) .and. u_VerVendFer(cVend6,cDtEmissa)
		aAdd(aVends, {cVend1,cVend6, "6"})
		cVendsPed += ",'"+cVend6+"'"
	EndIf

	If !Empty(cVend7) .and. u_VerVendFer(cVend7,cDtEmissa)
		aAdd(aVends, {cVend1,cVend7, "7"})
		cVendsPed += ",'"+cVend7+"'"
	EndIf

	If !Empty(cVend8) .and. u_VerVendFer(cVend8,cDtEmissa)
		aAdd(aVends, {cVend1,cVend8, "8"})
		cVendsPed += ",'"+cVend8+"'"
	EndIf

	If !Empty(cVend9) .and. u_VerVendFer(cVend9,cDtEmissa)
		aAdd(aVends, {cVend1,cVend9, "9"})
		cVendsPed += ",'"+cVend9+"'"
	EndIf

	cVendsPed := "("+SubStr(cVendsPed,2,Len(cVendsPed)-1)+")"

	// Garante que sÛ pagar· comiss„o para os vendedores que constam na cascata
	cQueryDel := "DELETE "
	cQueryDel += "	"+RetSqlName("SE3")+" E3 "
	cQueryDel += " WHERE
	cQueryDel += "		E3_VEND NOT IN  "+ cVendsPed +" "
	cQueryDel += "	AND E3_PEDIDO    = '"+ cNumPed   +"' "
	cQueryDel += "	AND E3_XFILIAL   = '"+ cFilAnt   +"' "
	cQueryDel +=  "	AND E3_CODCLI    = '"+ cCliente  +"' "
	cQueryDel +=  "	AND E3_LOJA      = '"+ cLoja     +"' "
	cQueryDel += "	AND E3_DATA      = ' ' "
	cQueryDel += "	AND E3.D_E_L_E_T_ = ' '	"
	TCSQLEXEC(cQueryDel)

	cQryUPD := "Update "
	cQryUPD += "	"+RetSqlName("SC5")+" C5 "
	cQryUPD += "Set "
//	cQryUPD += "	 C5_VEND1 = '"+Padr( cVend1,TamSx3("C5_VEND1")[1] )+"' "
	cQryUPD += "	 C5_VEND2 = '"+Padr( cVend2,TamSx3("C5_VEND2")[1] )+"' "
	cQryUPD += "	,C5_VEND3 = '"+Padr( cVend3,TamSx3("C5_VEND3")[1] )+"' "
	cQryUPD += "	,C5_VEND4 = '"+Padr( cVend4,TamSx3("C5_VEND4")[1] )+"' "
	cQryUPD += "	,C5_VEND5 = '"+Padr( cVend5,TamSx3("C5_VEND5")[1] )+"' "
	cQryUPD += "	,C5_VEND6 = '"+Padr( cVend6,TamSx3("C5_VEND6")[1] )+"' "
	cQryUPD += "	,C5_VEND7 = '"+Padr( cVend7,TamSx3("C5_VEND7")[1] )+"' "
	cQryUPD += "	,C5_VEND8 = '"+Padr( cVend8,TamSx3("C5_VEND8")[1] )+"' "
	cQryUPD += "	,C5_VEND9 = '"+Padr( cVend9,TamSx3("C5_VEND9")[1] )+"' "
	If !lXPolCm2
		cQryUPD += "	,C5_COMIS1 = 0 "
	Endif
	cQryUPD += "	,C5_COMIS2 = 0 "
	cQryUPD += "	,C5_COMIS3 = 0 "
	cQryUPD += "	,C5_COMIS4 = 0 "
	cQryUPD += "	,C5_COMIS5 = 0 "
	cQryUPD += "	,C5_COMIS6 = 0 "
	cQryUPD += "	,C5_COMIS7 = 0 "
	cQryUPD += "	,C5_COMIS8 = 0 "
	cQryUPD += "	,C5_COMIS9 = 0 "
	cQryUPD += "Where "
	cQryUPD +=  "		C5_FILIAL    = '"+ cFilAnt   +"' "
	cQryUPD +=  "	AND C5_NUM       = '"+ cNumPed   +"' "
	cQryUPD +=  "	AND C5_CLIENTE   = '"+ cCliente  +"' "
	cQryUPD +=  "	AND C5_LOJACLI   = '"+ cLoja     +"' "
	cQryUPD +=  "	AND C5.D_E_L_E_T_ = ' '	"

	TCSQLEXEC(cQryUPD)

	cQryUPD := "Update "
	cQryUPD += "	"+RetSqlName("SC6")+" C6 "
	cQryUPD += "Set "
	If !lXPolCm2
		cQryUPD += "	 C6_COMIS1 = 0 , "
	Endif
	cQryUPD += "	 C6_COMIS2 = 0 "
	cQryUPD += "	,C6_COMIS3 = 0 "
	cQryUPD += "	,C6_COMIS4 = 0 "
	cQryUPD += "	,C6_COMIS5 = 0 "
	cQryUPD += "	,C6_COMIS6 = 0 "
	cQryUPD += "	,C6_COMIS7 = 0 "
	cQryUPD += "	,C6_COMIS8 = 0 "
	cQryUPD += "	,C6_COMIS9 = 0 "
	cQryUPD += "Where "
	cQryUPD +=  "		C6_FILIAL    = '"+ cFilAnt   +"' "
	cQryUPD +=  "	AND C6_NUM       = '"+ cNumPed   +"' "
	cQryUPD +=  "	AND C6_CLI       = '"+ cCliente  +"' "
	cQryUPD +=  "	AND C6_LOJA      = '"+ cLoja     +"' "
	cQryUPD +=  "	AND C6.D_E_L_E_T_ = ' '	"

	TCSQLEXEC(cQryUPD)

	For nI := 1 To Len(aCols)

		cProduto := aCols[nI,nPosPro]

		For nJ := 1 To Len(aVends)

			lParcelado:= .F.

			dbSelectArea("SA3")
			SA3->( dbSetOrder(1) )
			lAchou := SA3->( dbSeek(xFilial("SA3")+aVends[nJ,2]) )
			If lAchou
				lPagaComissao := SA3->A3_XTIPCOM <> "N"
				lPagaNaBaixa  := SA3->A3_ALBAIXA == 100
			Endif

			If lAchou .and. lPagaComissao
				If !lLoja
					DbSelectArea("SC5")
					SC5->( DbSetOrder(1) )
					DbGoTo(nRegC5)
/*
					If !(nJ == 1 .AND. lXPolCm2 ) //Adicionado por Heimdall Castro (Doit) 16/08/2012
						RecLock("SC5", .F.)
							&("SC5->C5_COMIS" + aVends[nJ, 3]) := 0
						SC5->(MsUnLock())
					EndIf
*/
					DbSelectArea("SC6")
					SC6->( DbSetOrder(1) )
/*
					If !(nJ == 1 .AND. lXPolCm2 ) //Adicionado por Heimdall Castro (Doit) 16/08/2012
						If SC6->(dbSeek(xFilial("SC6")+cNumPed+aCols[nI,1]))
							RecLock("SC6", .F.)
							&("SC6->C6_COMIS" + aVends[nJ, 3]) := 0
							SC6->(MsUnLock())
						Endif
					Endif
*/
				Endif

				dbSelectArea("SB1")
				SB1->( DbSetOrder(1) )
				SB1->( dbSeek(xFilial("SB1")+Iif(lVendDir,cProduto,aCols[nI,nPosPro]) ) )
				cCatPro := StrZero(Val(SB1->B1_XGRCTB),6)
				cDCtPro	:= Posicione("SZM",1,xFilial("SZM")+SB1->B1_XGRCTB,"ZM_DESC") //SB1->B1_XDCATC
				cPecOLEO:= Posicione("SZM",1,xFilial("SZM")+SB1->B1_XGRCTB,"ZM_OLEO")


				dbSelectArea("RZ5")
				RZ5->( DbSetOrder(1) )
				If RZ5->( dbSeek(xFilial("RZ5")+aCols[nI,nPosCha]) )
					If Right(RTrim(RZ5->RZ5_MODELO), 2) == "_U"
						lMaqUsada := .T.
					Endif
				Endif

				If cModulo == "ESP" .or. cModulo == "LOJ"
					nDiasPagto := Posicione("SE4",1,xFilial("SE4")+M->C5_CONDPAG,"E4_XPRZMED")
					nTpPagto   := POSICIONE("SZ9",1,XFILIAL("SZ9")+M->C5_CLIENTE,"Z9_TPPRECO")

					If Empty(nTpPagto)
						nTpPagto:= "1" // 1=Varejo;2=Atacado
					Endif

                    If cPecOLEO <> "O"
                    	If nDiasPagto <= nAVista .and. nTpPagto == "2"
                    		cCatPro := "000013" // PECAS ATACADO A VISTA
                    	ElseIf nDiasPagto > nAVista .and. nTpPagto == "2"
                    		cCatPro := "000014" // PECAS ATACADO A PRAZO
                    	ElseIf nDiasPagto <= nAVista .and. nTpPagto == "1"
                    		cCatPro := "000015" // PECAS VAREJO A VISTA
                    	ElseIf nDiasPagto > nAVista .and. nTpPagto == "1"
                    		cCatPro := "000016" // PECAS VAREJO A PRAZO
				   		Endif
			   		Else
                    	If nDiasPagto <= nAVista .and. nTpPagto == "2"
                    		cCatPro := "000017" // OLEO ATACADO A VISTA
                    	ElseIf nDiasPagto > nAVista .and. nTpPagto == "2"
                    		cCatPro := "000017" // OLEO ATACADO A PRAZO
                    	ElseIf nDiasPagto <= nAVista .and. nTpPagto == "1"
                    		cCatPro := "000019" // OLEO VAREJO A VISTA
                    	ElseIf nDiasPagto > nAVista .and. nTpPagto == "1"
                    		cCatPro := "000020" // OLEO VAREJO A PRAZO
						Endif
					Endif
				Endif

				dbSelectArea("RZE")
				RZE->( dbSetOrder(3) ) // RZE_FILIAL+RZE_VENDED+RZE_CLASSE+RZE_MANUTE
				IF RZE->( dbSeek( xFilial("RZE")+aVends[nJ,2]+cCatPro+cManute ) )

					nPercent := Iif(cTipUso == "G", RZE->RZE_COMISS, RZE->RZE_PERCAN)
					cDesCla := RZE->RZE_DESCAT

					If nPercent > 0

						If (cModulo == "ESP1" .Or. cModulo == "ESP" )  //.or. cModulo == "LOJ"
							cDupl := ""
							cSerie:= ""
							If !lLoja
								RecLock("SC5", .F.)
									&("SC5->C5_VEND" + aVends[nJ, 3]) := aVends[nJ,2]
									If !(nJ == 1 .AND. lXPolCm2 )
										&("SC5->C5_COMIS" + aVends[nJ, 3]) := nPercent
									Endif
									lOK       := .t.
								SC5->(MsUnLock())

	//							cnItem:="00"
	//							For xNN := 1 to Len(aCols)
	//								cnItem := soma1(cnItem)
									If SC6->(dbSeek(xFilial("SC6")+cNumPed+aCols[nI,1]))
										cDupl  := SC6->C6_NOTA
										cSerie := AllTrim(SC6->C6_SERIE)
										If !(nJ == 1 .AND. lXPolCm2 )
											RecLock("SC6", .F.)
												If nJ == 1 .AND. lXPolCm2
													&("SC6->C6_XCOMIS1") := nPercent
												Else
													&("SC6->C6_COMIS" + aVends[nJ, 3]) := nPercent
												EndIf
											SC6->(MsUnLock())
										Endif
										If nJ == 1 .AND. lXPolCm2
											If Empty(SC6->C6_COMIS1)

												clMsErro := "Pedido: " + cNumPed + " - N„o foi informado o Percentual do Vendedor 1 !"
												U_SFATV002(cpNomeLog, "ERRO - Pedido "+cNumPed+" - "+ clMsErro, .T., .T.)

												if !llJob
													Aviso("Pedido "+cNumPed,clMsErro,{"Fechar"})
												endif

												Return()
											Else
												nPercent := SC6->C6_COMIS1 // Guarda o percentual de comiss„o que o usu·rio informou
											Endif
										Endif
										If !Empty(cDupl)

		                                    njBak := nj
											DbSelectArea("SF2")
											SF2->(DbSetOrder(1)) // 1-F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
											nj:= njBak
											If SF2->(DbSeek(xFilial("SF2")+cDupl+SC6->C6_SERIE+SC6->C6_CLI+SC6->C6_LOJA))
												cPrefixo := SF2->F2_PREFIXO
												RecLock( "SF2",.F.)
													&("SF2->F2_VEND" + aVends[nJ, 3] ) := aVends[nJ,2]
												SF2->(MsUnLock())
											Endif

											DbSelectArea("SD2")
											SD2->(DbSetOrder(3)) // 3-D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD    +D2_ITEM
											If SD2->(DbSeek(xFilial("SD2")+cDupl+SC6->C6_SERIE+SC6->C6_CLI+SC6->C6_LOJA+SC6->C6_PRODUTO))
												RecLock( "SD2",.F.)
													&("SD2->D2_COMIS" + aVends[nJ, 3] ) := nPercent
												SD2->(MsUnLock())
											Endif
										Endif
									Endif
	//							Next xNN
							Else
								RecLock("SC5", .F.)
									&("SC5->C5_VEND" + aVends[nJ, 3]) := aVends[nJ,2]
									If !(nJ == 1 .AND. lXPolCm2 )
										&("SC5->C5_COMIS" + aVends[nJ, 3]) := nPercent
									Endif
									lOK       := .t.
								SC5->(MsUnLock())
								If SC6->(dbSeek(xFilial("SC6")+cNumPed+aCols[nI,1]))
									RecLock("SC6", .F.)
										&("SC6->C6_COMIS" + aVends[nJ, 3]) := nPercent
									SC6->(MsUnLock())
								Endif
								DbSelectArea("SL1")
								SL1->( DbSetOrder(1) )
								If SL1->( dbSeek(xFilial("SL1")+SC5->C5_XPECSL1) )
									RecLock("SL1", .F.)
										&("SL1->L1_VEND" + If(aVends[nJ, 3]=="1","",aVends[nJ, 3]) ) :=  aVends[nJ,2]
									SL1->(MsUnLock())
                                    njBak := nj
									dbselectarea("SF2")
									SF2->(DbSetOrder(1))
									nj:= njBak
									If SF2->(DbSeek(xFilial("SF2")+SL1->L1_DOC+SL1->L1_SERIE))
										cPrefixo := SF2->F2_PREFIXO
										cDupl := SF2->F2_DUPL
										cSerie:= SF2->F2_SERIE
										RecLock( "SF2",.F.)
											&("SF2->F2_VEND" + aVends[nJ, 3] ) :=  aVends[nJ,2]
										SF2->(MsUnLock())
									Endif
									DbSelectArea("SL2")
									If nJ == 1
										cnItem := Iif(nI == 1 , "01" , Soma1(cnItem) )
									Endif
									SL2->(DbSetOrder(1))  //L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO
									If SL2->(DbSeek(xFilial("SL2")+SL1->L1_NUM+cnItem))
										RecLock( "SL2",.F.)
											&("SL2->L2_COMIS" + aVends[nJ, 3] ) := nPercent
										SL2->(MsUnLock())
									Endif

									DbSelectArea("SD2")
									SD2->(DbSetOrder(3)) // 3-D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD    +D2_ITEM
														 //             L1_DOC+L1_SERIE+L1_CLIENTE+L1_LOJA+L2_PRODUTO+L2_ITEM
//									While SL2->L2_FILIAL+SL2->L2_NUM == xFilial("SL2")+SL1->L1_NUM
										If SD2->(DbSeek(xFilial("SD2")+SL1->L1_DOC+SL1->L1_SERIE+SL1->L1_CLIENTE+SL1->L1_LOJA+SL2->L2_PRODUTO+SL2->L2_ITEM))
											RecLock( "SD2",.F.)
												&("SD2->D2_COMIS" + aVends[nJ, 3] ) := nPercent
											SD2->(MsUnLock())
										Endif
//										SL2->(dbSkip())
//									Enddo
									/*
									If !Empty(cDupl)
										dbSelectArea("SE1")
										dbSetOrder(2)  //E1_FILIAL+    E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
										If dbSeek( xFilial("SE1")+SF2->(F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DUPL) )
											RecLock( "SE1",.F.)
												&("SE1->E1_VEND" + aVends[nJ, 3] ) := aVends[nJ,2]
												&("SE1->E1_COMIS"+ aVends[nJ, 3] ) := nPercent
											SE1->(MsUnLock())
										Endif
									Endif
									*/
								Endif
								lOK       := .t.
							Endif
						Endif

						lOk := FVEND91( aVends[nJ,2], cDupl, cCliente, cLoja )

						if lOk

						cXCATEGO := AllTrim(Posicione("SA3",1,xFilial("SA3") + aVends[nJ, 2],"A3_XCATEGO"))
					    If cXCATEGO == "05" .and. ; 		 // Gerente Filial  (RZE_CATEGO)
							    	cManute == "MAQ" .and. ; // SÛ para maquinas
							    	!lMaqUsada  	 .and. ; // N„o calcula se for maquina usada
							    	lXPolCm3                 // Calcula a comiss„o do Gerente pela Margem
							lCalcGer  := .T.
							GteFilCom(.f.,.t.)
						Else

							DbSelectArea("RZF")
							RZF->( DbSetOrder(2) )
							lAchou := RZF->( DbSeek(xFilial("RZF") + cNumPed + cCliente + cLoja + aCols[nI,nPosIte] + aVends[nJ,2]) )

							RecLock("RZF", !lAchou)
								RZF->RZF_FILIAL	:= xFilial("RZF")
								RZF->RZF_PEDIDO	:= cNumPed
								RZF->RZF_TIPUSO	:= cTipUso
								RZF->RZF_CLIENT	:= cCliente
								RZF->RZF_LOJA	:= cLoja
								RZF->RZF_NOME	:= cNomCli
								RZF->RZF_ITEM	:= StrZero(nJ,2)
								RZF->RZF_ITEMPV	:= aCols[nI,nPosIte]
								RZF->RZF_PRODUT	:= Iif(lVendDir,cProduto,aCols[nI,nPosPro])
								RZF->RZF_VENPAI := aVends[nJ,1]
								RZF->RZF_VENDED	:= aVends[nJ,2]
								RZF->RZF_NOMVEN	:= Posicione("SA3",1,xFilial("SA3") + aVends[nJ, 2],"A3_NOME")
								RZF->RZF_VLRBAS	:= aCols[nI,nPosVlr]
								//se for vend1 e se a empresa n„o tem politica de comiss„o,
								//deixa o percentual de zerado pois ser· definido pelo comercial
								If !lXPolCom .and. aVends[nJ,3] == "1"
									RZF->RZF_COMISS	:= 0
									RZF->RZF_RESULT	:= 0
								Else
									RZF->RZF_COMISS	:= nPercent

									If lAchou .and. RZF->RZF_REDUTO <> 0
										nPercent := nPercent * ( ( 100-RZF->RZF_REDUTO ) / 100 )
									Else
										RZF->RZF_REDUTO := 0
									Endif

									RZF->RZF_RESULT	:= nPercent
								Endif

//								RZF->RZF_REDUTO := 0
								RZF->RZF_CATEGO	:= Posicione("SA3",1,xFilial("SA3") + aVends[nJ, 2],"A3_XCATEGO")
								RZF->RZF_DESPRO	:= Posicione("SB1",1,xFilial("SB1") + Iif(lVendDir,cProduto,aCols[nI,nPosPro]) ,"B1_DESC")
								RZF->RZF_PRCVEN := 0
								RZF->RZF_PRCCOM	:= 0
								RZF->RZF_MRGLIQ	:= 0
								RZF->RZF_PERTAB	:= 0
								RZF->RZF_NVCALC := 0
								RZF->RZF_DESCAT	:= Posicione("SA3",1,xFilial("SA3") + aVends[nJ, 2],"A3_XDESCAT")
								RZF->RZF_NUMCOM	:= aVends[nJ,3]
								RZF->RZF_USERNA	:= cUserName
								RZF->RZF_DATLOG	:= dDataBase
								RZF->RZF_CLASSE	:= cCatPro
								RZF->RZF_DESCLA	:= cDesCla
								RZF->RZF_MODULO := cModulo
								RZF->RZF_XFIL   := cFilAnt
							RZF->(MsUnLock())
							If nJ == 1
								// Guarda o valor da comiss„o do vendedor 1
								nPVenGe := aCols[nI,nPosVlr] * (nPercent/100)
							Endif
						Endif

						// refaz o calculo da comiss„o
					   	If !Empty(cDupl) .and. ( nPercent <> 0 .or. lCalcGer )
							dbSelectArea("SE1")
							SE1->( dbSetOrder(1) )  //1-E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO //2- E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
							If SE1->( dbSeek(xFilial("SE1")+ cPrefixo + cDupl ) )
								While xFilial("SE1")+ cPrefixo + cDupl  == SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM) .and. SE1->(!Eof())

									If !("FIN"$SE1->E1_ORIGEM)
											dbSelectArea("SE1")
											RecLock("SE1", .F.)
												If lPagaNaBaixa
													&("SE1->E1_VEND" + aVends[nJ, 3]) := aVends[nJ,2]
													&("SE1->E1_COMIS" + aVends[nJ, 3]) := Iif(nPercent > 0, nPercent, 0 )
												Else
													&("SE1->E1_VEND" + aVends[nJ, 3]) := ""
													&("SE1->E1_COMIS" + aVends[nJ, 3]) := 0
												Endif
												If lLoja
													SE1->E1_PEDIDO := cNumPed
												Endif
											SE1->(MsUnLock())
                                    Endif

                                    If ((SE1->E1_VALOR-SE1->E1_SALDO) <> 0  .OR. !lPagaNaBaixa ) .and. !("FIN"$SE1->E1_ORIGEM) // Se o titulo for baixado ou o pagtop da comiss„o È pela emiss„o

										// Verifica se existe titulos como parcela
										cAlias := GetNextAlias()
										cQuery :=  "SELECT "
										cQuery +=  "	 E3.R_E_C_N_O_ nRecno "
										cQuery +=  "	,E3.E3_DATA "
										cQuery +=  "FROM "
										cQuery +=  "	"+RetSqlName("SE3")+" E3 "
										cQuery +=  "WHERE "
	//									cQuery +=  "		E3_XFILIAL = '"+ cFilAnt         +"' "
										cQuery +=  "	    E3_VEND    = '"+ aVends[nJ,2]    +"' "
										cQuery +=  "	AND E3_PREFIXO = '"+ SE1->E1_PREFIXO +"' "
										cQuery +=  "	AND E3_NUM     = '"+ SE1->E1_NUM     +"' "
										cQuery +=  "	AND E3_TIPO    = '"+ SE1->E1_TIPO    +"' "
										cQuery +=  "	AND E3_PARCELA = '"+ SE1->E1_PARCELA +"' "
										cQuery +=  "	AND E3_XFILIAL = '"+ cFilAnt         +"' "
//										cQuery +=  "	AND E3_SERIE   = '"+ cSerie          +"' "
										cQuery +=  "	AND E3.D_E_L_E_T_ = ' '	"

										dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

										lAchou := (cAlias)->( !Eof() )
										If !lParcelado .and. lAchou
											lParcelado := .T.
										Endif

										If !lAchou  .and. !lParcelado
											//caso n„o tenha encontrado titulos com parcela, verfica se tem titulos sem parcela
											(cAlias)->(dbCloseArea())
											cQuery :=  "SELECT "
											cQuery +=  "	 E3.R_E_C_N_O_ nRecno "
											cQuery +=  "	,E3.E3_DATA "
											cQuery +=  "FROM "
											cQuery +=  "	"+RetSqlName("SE3")+" E3 "
											cQuery +=  "WHERE "
		//									cQuery +=  "		E3_XFILIAL = '"+ cFilAnt         +"' "
											cQuery +=  "	    E3_VEND    = '"+ aVends[nJ,2]    +"' "
											cQuery +=  "	AND E3_PREFIXO = '"+ SE1->E1_PREFIXO +"' "
											cQuery +=  "	AND E3_NUM     = '"+ SE1->E1_NUM     +"' "
											cQuery +=  "	AND E3_TIPO    = '"+ SE1->E1_TIPO    +"' "
											cQuery +=  "	AND E3_XFILIAL = '"+ cFilAnt         +"' "
											cQuery +=  "	AND E3_PARCELA = '  ' "
//											cQuery +=  "	AND E3_SERIE   = '"+ cSerie          +"' "
											cQuery +=  "	AND E3.D_E_L_E_T_ = ' '	"

											dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

											lAchou := (cAlias)->( !Eof() )
                                        Endif

										If ( lAchou .and. Empty((cAlias)->E3_DATA) ) .OR. !lAchou
											// Se o titulo estiver baixado, refaz o calculo da comiss„o ou Se paga na Emiss„o
											If ( Round(SE1->E1_SALDO,2) # Round(SE1->E1_VALOR,2) .or. !lPagaNaBaixa ) .and.( nPercent <> 0 .or. lCalcGer )

												dbSelectArea("SE3")

												If lAchou
													While (cAlias)->( !Eof() )
														SE3->( dbGoTo( (cAlias)->nRecno  ) )
														RecLock("SE3", !lAchou)
															SE3->E3_PORC   := nPercent
															SE3->E3_COMIS  := Iif(nPercent > 0, SE3->E3_BASE * nPercent / 100 , 0 )
															SE3->E3_XTIPO  := Substr(cManute,1,1) //"M"
															SE3->E3_XFILIAL:= cFilAnt
															If lLoja
																SE3->E3_PEDIDO := cNumPed
															Endif
														(cAlias)->(MsUnLock())
														(cAlias)->(dbSkip())
													Enddo
												Else

													dbSelectArea("SE5")
													SE5->( dbSetOrder(7) )  //E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ
													cSeq := "01"
													If SE5->( dbSeek(SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA) ) )
														While SE5->(!EOF()) .and. SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA) == ;
																					SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)
															cSeq := SE5->E5_SEQ
															SE5->(dbSkip())
														Enddo
									                Endif

													dbSelectArea("SE3")

														RecLock("SE3", !lAchou)
														SE3->E3_FILIAL := xFilial("SE3")
														SE3->E3_VEND   := aVends[nJ,2]
														SE3->E3_PREFIXO:= SE1->E1_PREFIXO
														SE3->E3_NUM    := SE1->E1_NUM
														SE3->E3_PARCELA:= SE1->E1_PARCELA
														SE3->E3_SEQ    := U_SE3SEQ(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,aVends[nJ,2] )
														SE3->E3_TIPO   := SE1->E1_TIPO
														SE3->E3_CODCLI := SE1->E1_CLIENTE
														SE3->E3_LOJA   := SE1->E1_LOJA
														SE3->E3_EMISSAO:= SE1->E1_EMISSAO
														SE3->E3_SERIE  := SE1->E1_SERIE
														SE3->E3_BASE   := Iif(lPagaNaBaixa,SE1->(E1_VALOR+E1_ACRESC-E1_DECRESC+E1_CALJURO-E1_SALDO), SE1->E1_VALOR)
														SE3->E3_PORC   := nPercent
														SE3->E3_COMIS  :=  Iif(nPercent > 0, Iif(lPagaNaBaixa,SE1->(E1_VALOR+E1_ACRESC-E1_DECRESC+E1_CALJURO-E1_SALDO), SE1->E1_VALOR) * nPercent / 100 , 0 )
														SE3->E3_BAIEMI := Iif(lPagaNaBaixa,"B","E")
														SE3->E3_PEDIDO := cNumPed
														SE3->E3_SEQ	   := cSeq
														SE3->E3_ORIGEM := Iif(lPagaNaBaixa,"B","E")
														SE3->E3_VENCTO := SE1->E1_BAIXA
														SE3->E3_XFILIAL:= cFilAnt
														SE3->E3_XTIPO  := Substr(cManute,1,1) //"M"
													SE3->(MsUnLock())
											    Endif
											Endif
										Endif
										(cAlias)->(DbCloseArea())
									Endif
									dbSelectArea("SE1")
									SE1->(dbSkip())
								Enddo
							Endif
						Endif
						endif
						//******************************************************************************
					Endif
				Endif
			Endif

		Next nJ
	Next nI

Endif
If lOK
//	Aviso("Pedido "+cNumPed+" Atualizado","A Cascata/Percentuais de comiss„o foram atualizados.!",{"Fechar"})
Endif

Return
