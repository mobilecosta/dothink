#Include "protheus.ch"
#Include "totvs.ch"
#Include "APWIZARD.CH"
#Include "FILEIO.CH"
#Include "RPTDEF.CH"
#Include "FWPrintSetup.ch"
#Include "PARMTYPE.CH"

/*/{Protheus.doc} U_TRK0011
   OD-27 - Check List de Expedição (PDF)
   Ajustes de layout: alturas menores e assinatura garantindo espaço.
   Includes e FWMSPrinter mantidos conforme seu padrão.
*/
User Function TRK0011()

   // --- Locals
   Local _cRel  := "TRK0011"+ StrTran(Time(),":","")
   Local _cPath := ""
   Local oPrinter := FWMSPrinter():New(_cRel, IMP_PDF, .F., _cPath, .T.)

   Local _nEsq := 30
   Local _nDir := 580
   Local _nTop := 25
   Local _nLin := _nTop

   // alturas padronizadas (menores)
   Local _nHl  := 36   // box grande (DATA/PEDIDO)
   Local _nHm  := 28   // box médio (EMISSÃO/ENTREGA)
   Local _nHs  := 26   // box pequeno (Parte II linhas)
   Local _nRw  := 18   // altura das linhas da tabela

   Local _cTit := "OD-27 - Check List De Expedição"
   Local _cSet := "Setor De Logística"
   Local _cP1  := "Parte I - Informações Gerais"
   Local _cP2  := "Parte II - Dados de Coleta"
   Local _cP3  := "Parte III - Conferência"
   Local _cP4  := "Parte IV - Autorização De Expedição"
   Local _cP5  := "Parte V - Termo De Responsabilidade"
      // ---- Variáveis de dados para preencher os boxes ----
   Local _dData  := Date()              // DATA
   Local _cPed   := "-"            // Nº do PEDIDO
   Local _cClie  := "-"   // CLIENTE
   Local _cTransp:= "-"   // TRANSPORTADORA
   Local _cDanfe := "-"    // DANFE
   Local _dEmis  := CTOD("  /  /  ")              // DATA DE EMISSÃO


   // Fontes
   Private oFA06 := TFont():New("Arial",,  6, .T.)
   Private oFA08 := TFont():New("Arial",,  8, .T.)
   Private oFA09 := TFont():New("Arial",,  9, .T.)
   Private oFA10 := TFont():New("Arial",, 10, .T.)
   Private oFB10 := TFont():New("Arial",, 10, .T., .T.)
   Private oFB12 := TFont():New("Arial",, 12, .T., .T.)

   _cPed := Z13->Z13_PEDIDO
   SC5->(DbSetOrder(1))
   If SC5->(DbSeek(Z13->Z13_FILIAL+Z13->Z13_PEDIDO))
      SA4->(DbSetOrder(1))
      If SA4->(DbSeek(xFilial()+SC5->C5_TRANSP))   
         _cTransp := SA4->A4_NOME
      EndIf
      If SC5->C5_TIPO $ "DB"
            SA2->(DbSetOrder(1))
            If SA2->(DbSeek(xFilial()+SC5->C5_CLIENTE+SC5->C5_LOJACLI))
               _cClie  := SA2->A2_NOME       // Nome Cliente  C [60 ][ 0 ] 17
            EndIf
      else
            SA1->(DbSetOrder(1))
            If SA1->(DbSeek(xFilial()+SC5->C5_CLIENTE+SC5->C5_LOJACLI))
               _cClie  := SA1->A1_NOME       // Nome Cliente  C [60 ][ 0 ] 17
            EndIf
      EndIf
   EndIf
   SF2->(DbSetOrder(1))
   If SF2->(DbSeek(Z13->Z13_FILIAL+Z13->Z13_DOC+Z13->Z13_SERIE+Z13->Z13_CLIENT+Z13->Z13_LOJA))
      _dEmis := SF2->F2_EMISSAO
      _cDanfe   := SF2->F2_DOC+"-"+SF2->F2_SERIE
   EndIf
   // Página
   oPrinter:StartPage()

   // Título e subtítulo
   oPrinter:Line(20, _nEsq, 20, _nDir,, "-2")
   SayMid( oPrinter, _nLin, _nEsq, _nDir, _cTit, oFB12, RGB(200,0,0) )
   _nLin += 15
   oPrinter:Say( _nLin, _nEsq, _cSet, oFA09 )
   _nLin += 18

   // ===== Parte I =====
   _nLin += SecTit( oPrinter, _nLin, _nEsq, _nDir, _cP1 )

   _nLin += BoxRow( oPrinter, _nLin, _nEsq, _nDir, 26 )
   ClasLbl( oPrinter, _nLin-26, _nEsq, _nDir )

   // DATA / TRANSPORTADORA / DANFE
   _nLin += Box3P( oPrinter, _nLin, _nEsq, _nDir, _nHl, 22, 58, 20, ;
                   "DATA:", "TRANSPORTADORA:", "DANFE:" )

   
   
   
   oPrinter:Say( (_nLin - _nHl)+20, _nEsq+8, DtoC(_dData), oFA10 )
   oPrinter:Say( (_nLin - _nHl)+20, _nEsq + Int((_nDir - _nEsq)*22/100) + 8, _cTransp,    oFA10 )
   oPrinter:Say( (_nLin - _nHl)+20, _nEsq + Int((_nDir - _nEsq)*(22+58)/100) + 8, _cDanfe,     oFA10 )
// valores nos campos (DATA / TRANSPORTADORA / DANFE)

   oPrinter:Say( (_nLin - _nHl)+20, _nEsq+8, DtoC(_dData), oFA10 )
   oPrinter:Say( (_nLin - _nHl)+20, _nEsq + Int((_nDir - _nEsq)*22/100) + 8, _cTransp,    oFA10 )
   oPrinter:Say( (_nLin - _nHl)+20, _nEsq + Int((_nDir - _nEsq)*(22+58)/100) + 8, _cDanfe,     oFA10 )
// PEDIDO / CLIENTE
   _nLin += Box2P( oPrinter, _nLin, _nEsq, _nDir, _nHl, 22, 78, ;
                   "PEDIDO:", "CLIENTE:" )

  
   

   oPrinter:Say( (_nLin - _nHl)+20, _nEsq+8, _cPed,  oFA10 )
   oPrinter:Say( (_nLin - _nHl)+20, _nEsq + Int((_nDir - _nEsq)*22/100) + 8, _cClie, oFA10 )
oPrinter:Say( (_nLin - _nHl)+20, _nEsq+8, _cPed,  oFA10 )
   oPrinter:Say( (_nLin - _nHl)+20, _nEsq + Int((_nDir - _nEsq)*22/100) + 8, _cClie, oFA10 )
// DATA DE EMISSÃO
   _nLin += Box1( oPrinter, _nLin, _nEsq, _nDir, _nHm, "DATA DE EMISSÃO:" )

   
   // valor no campo DATA DE EMISSÃO
   oPrinter:Say( (_nLin - _nHm)+8, _nEsq+140, DtoC(_dEmis), oFA10 )
// ENTREGA
   /*_nLin += Box3P( oPrinter, _nLin, _nEsq, _nDir, _nHm, 22, 58, 20, ;
                   "A ENTREGA SERÁ REALIZADA:", ;
                   "TRANSPORTADORA (REDESPACHO)  ( )", ;
                   "CLIENTE  ( )" )*/
   _nLin += 26
   Entrega( oPrinter, _nLin-26, _nEsq, _nDir )
   _nLin -= 10 

   // ===== Parte II =====
   _nLin += SecTit( oPrinter, _nLin, _nEsq, _nDir, _cP2 )
   _nLin += Box4L( oPrinter, _nLin, _nEsq, _nDir, _nHs, ;
                   "HORA / PORTARIA:", "HORA/DOCA:", "MOTORISTA:", "" )
   _nLin += Box3P( oPrinter, _nLin, _nEsq, _nDir, _nHs, 25, 25, 50, ;
                "COLETADO EM:", "HORA:", ;
                "CARGA CONFERIDA PELO MOTORISTA: ( ) SIM   ( ) NÃO" )
   _nLin += 6

   // ===== Parte III =====
   _nLin += SecTit( oPrinter, _nLin, _nEsq, _nDir, _cP3 )
   _nLin += SecBand( oPrinter, _nLin, _nEsq, _nDir, 18, "QUESTÕES A SEREM AVALIADAS" ) + 4
   _nLin += TblHead( oPrinter, _nLin, _nEsq, _nDir, 18 )

   _nLin += TblRow( oPrinter, _nLin, _nEsq, _nDir, _nRw,  1, "O nome da transportadora constante na nota fiscal confere com a transportadora que está realizando a coleta dos produtos?" )
   _nLin += TblRow( oPrinter, _nLin, _nEsq, _nDir, _nRw,  2, "Há necessidade de transporte climatizado?" )
   _nLin += TblRow( oPrinter, _nLin, _nEsq, _nDir, _nRw,  3, "Qual a temperatura constante no transporte no momento da expedição (aplicável para insumos farmacêuticos e com temperatura controlada)?" )
   _nLin += TblRow( oPrinter, _nLin, _nEsq, _nDir, _nRw,  4, "O veículo está de acordo para o carregamento, limpo e em bom estado de conservação?" )
   _nLin += TblRow( oPrinter, _nLin, _nEsq, _nDir, _nRw,  5, "No veículo há matérias incompatíveis com a carga a ser expedida?" )
   _nLin += TblRow( oPrinter, _nLin, _nEsq, _nDir, _nRw,  6, "A equipe da transportadora é apta e em quantidade suficiente para o carregamento dos produtos?" )
   _nLin += TblRow( oPrinter, _nLin, _nEsq, _nDir, _nRw,  7, "Os produtos constantes na nota fiscal conferem com os produtos separados pelo Setor Operacional/Logística?" )
   _nLin += TblRow( oPrinter, _nLin, _nEsq, _nDir, _nRw,  8, "As documentações que irão acompanhar o produto estão de acordo?" )
   _nLin += TblRow( oPrinter, _nLin, _nEsq, _nDir, _nRw,  9, "O veículo é adequado para o transporte de insumos perigosos (Kit, curso e placa - se aplicável)?" )
   _nLin += TblRow( oPrinter, _nLin, _nEsq, _nDir, _nRw, 10, "Produtos doces e salgados transportados separadamente?" )
   _nLin += TblRow( oPrinter, _nLin, _nEsq, _nDir, _nRw, 11, "O item está na Lista Mestre de Rotulagem?  Se sim, será necessário realizar a rotulagem padrão." )
   _nLin += 6

   // ===== Parte IV =====
   _nLin += SecTit( oPrinter, _nLin, _nEsq, _nDir, _cP4 )
   _nLin += AuthBx( oPrinter, _nLin, _nEsq, _nDir, 60, ; // antes 110
                    "EXPEDIÇÃO AUTORIZADA      ( )", ;
                    "EXPEDIÇÃO NÃO AUTORIZADA  ( )" )
   _nLin += 6

   // Assinaturas (altura um pouco menor)
   _nLin += SignRow( oPrinter, _nLin, _nEsq, _nDir, ;
                     "Responsável pela separação", ;
                     "Responsável pela expedição", ;
                     "Inspetor de Qualidade" ) // retorna 36

   // ===== Parte V =====
   _nLin += SecTit( oPrinter, _nLin, _nEsq, _nDir, _cP5 )
   _nLin += 2
   _nLin += ParaTxt( oPrinter, _nLin, _nEsq, _nDir, 28, ; // antes 46
      "RETIRAMOS A(S) MERCADORIA(S) CONSTANTE(S) DA NOTA FISCAL ACIMA REFERENCIADA, EM PERFEITAS CONDIÇÕES DE HIGIENE E CONSERVAÇÃO, EMBALAGENS E RÓTULOS ÍNTEGROS E DOCUMENTAÇÕES EM CONFORMIDADE COM A LEGISLAÇÃO E SOLICITAÇÕES DO CLIENTE." )
   _nLin += 18
   _nLin += SigBx3( oPrinter, _nLin, _nEsq, _nDir, 40, ;
                  "Nome legível (Nome e Sobrenome)", "RG", "Placa do Veículo" )

   oPrinter:Say( 820, _nDir-160, "REVISÃO xx | dd/mm/yyyy", oFA09 )
   //oPrinter:Line( 785, _nEsq, 785, _nDir,, "-2" )

   oPrinter:EndPage()
   oPrinter:Preview()
Return .T.


// =================== Helpers ===================

Static Function SecTit( _prn, _nTop, _nEsq, _nDir, _cTxt )
   Local _nAlt := 18
   _prn:Line( _nTop,       _nEsq, _nTop,       _nDir,, "-2" )
   _prn:Line( _nTop+_nAlt, _nEsq, _nTop+_nAlt, _nDir,, "-2" )
   SayMid( _prn, _nTop+3, _nEsq, _nDir, _cTxt, oFB10 )
Return _nAlt + 6

Static Function SecBand( _prn, _nTop, _nEsq, _nDir, _nAlt, _cTxt )
   Local _nBot := _nTop + _nAlt
   _prn:Line( _nTop, _nEsq, _nTop, _nDir,, "-2" )
   _prn:Line( _nBot, _nEsq, _nBot, _nDir,, "-2" )
   SayMid( _prn, _nTop+3, _nEsq, _nDir, _cTxt, oFB10 )
Return _nAlt + 4

Static Function Box1( _prn, _nTop, _nEsq, _nDir, _nAlt, _cLbl )
   Local _nBot := _nTop + _nAlt
   _prn:Line( _nTop, _nEsq, _nTop, _nDir,, "-2" )
   _prn:Line( _nBot, _nEsq, _nBot, _nDir,, "-2" )
   _prn:Line( _nTop, _nEsq, _nBot, _nEsq,, "-2" )
   _prn:Line( _nTop, _nDir, _nBot, _nDir,, "-2" )
   _prn:Say ( _nTop+8, _nEsq+8, _cLbl, oFA10 )
Return _nAlt

Static Function Box2P( _prn, _nTop, _nEsq, _nDir, _nAlt, _p1, _p2, _c1, _c2 )
   Local _nBot := _nTop + _nAlt
   Local _nTot := _nDir - _nEsq
   Local _w1   := Int(_nTot * _p1 / 100)
   Local _x2   := _nEsq + _w1
   _prn:Line( _nTop, _nEsq, _nTop, _nDir,, "-2" )
   _prn:Line( _nBot, _nEsq, _nBot, _nDir,, "-2" )
   _prn:Line( _nTop, _nEsq, _nBot, _nEsq,, "-2" )
   _prn:Line( _nTop, _nDir, _nBot, _nDir,, "-2" )
   _prn:Line( _nTop, _x2 , _nBot, _x2 ,, "-2" )
   _prn:Say ( _nTop+8, _nEsq+8, _c1, oFA10 )
   _prn:Say ( _nTop+8, _x2  +8, _c2, oFA10 )
Return _nAlt

Static Function Box3( _prn, _nTop, _nEsq, _nDir, _nAlt, _c1, _c2, _c3 )
   Local _nBot := _nTop + _nAlt
   Local _w    := Int((_nDir-_nEsq)/3)
   Local _x2   := _nEsq + _w
   Local _x3   := _nEsq + _w*2
   _prn:Line( _nTop, _nEsq, _nTop, _nDir,, "-2" )
   _prn:Line( _nBot, _nEsq, _nBot, _nDir,, "-2" )
   _prn:Line( _nTop, _nEsq, _nBot, _nEsq,, "-2" )
   _prn:Line( _nTop, _nDir, _nBot, _nDir,, "-2" )
   _prn:Line( _nTop, _x2 , _nBot, _x2 ,, "-2" )
   _prn:Line( _nTop, _x3 , _nBot, _x3 ,, "-2" )
   _prn:Say ( _nTop+8, _nEsq+8, _c1, oFA10 )
   _prn:Say ( _nTop+8, _x2  +8, _c2, oFA10 )
   _prn:Say ( _nTop+8, _x3  +8, _c3, oFA10 )
Return _nAlt

Static Function Box3P( _prn, _nTop, _nEsq, _nDir, _nAlt, _p1, _p2, _p3, _c1, _c2, _c3 )
   Local _nBot := _nTop + _nAlt
   Local _nTot := (_nDir - _nEsq)
   Local _w1   := Int(_nTot * _p1 / 100)
   Local _w2   := Int(_nTot * _p2 / 100)
   Local _x2   := _nEsq + _w1
   Local _x3   := _x2  + _w2
   _prn:Line( _nTop, _nEsq, _nTop, _nDir,, "-2" )
   _prn:Line( _nBot, _nEsq, _nBot, _nDir,, "-2" )
   _prn:Line( _nTop, _nEsq, _nBot, _nEsq,, "-2" )
   _prn:Line( _nTop, _nDir, _nBot, _nDir,, "-2" )
   _prn:Line( _nTop, _x2 , _nBot, _x2 ,, "-2" )
   _prn:Line( _nTop, _x3 , _nBot, _x3 ,, "-2" )
   _prn:Say ( _nTop+8, _nEsq+8, _c1, oFA10 )
   _prn:Say ( _nTop+8, _x2  +8, _c2, oFA10 )
   _prn:Say ( _nTop+8, _x3  +8, _c3, oFA10 )
Return _nAlt

Static Function Box4L( _prn, _nTop, _nEsq, _nDir, _nAlt, _c1, _c2, _c3, _c4 )
   Local _nBot := _nTop + _nAlt
   Local _w    := Int((_nDir-_nEsq)/4)
   Local _x2   := _nEsq + _w
   Local _x3   := _nEsq + _w*2
   Local _x4   := _nEsq + _w*3
   _prn:Line( _nTop, _nEsq, _nTop, _nDir,, "-2" )
   _prn:Line( _nBot, _nEsq, _nBot, _nDir,, "-2" )
   _prn:Line( _nTop, _nEsq, _nBot, _nEsq,, "-2" )
   _prn:Line( _nTop, _nDir, _nBot, _nDir,, "-2" )
   _prn:Line( _nTop, _x2 , _nBot, _x2 ,, "-2" )
   _prn:Line( _nTop, _x3 , _nBot, _x3 ,, "-2" )
   _prn:Line( _nTop, _x4 , _nBot, _x4 ,, "-2" )
   _prn:Say ( _nTop+9, _nEsq+8, _c1, oFA10 )
   _prn:Say ( _nTop+9, _x2  +8, _c2, oFA10 )
   _prn:Say ( _nTop+9, _x3  +8, _c3, oFA10 )
   _prn:Say ( _nTop+9, _x4  +8, _c4, oFA10 )
Return _nAlt

Static Function BoxRow( _prn, _nTop, _nEsq, _nDir, _nAlt )
   Local _nBot := _nTop + _nAlt
   _prn:Line( _nTop, _nEsq, _nTop, _nDir,, "-2" )
   _prn:Line( _nBot, _nEsq, _nBot, _nDir,, "-2" )
   _prn:Line( _nTop, _nEsq, _nBot, _nEsq,, "-2" )
   _prn:Line( _nTop, _nDir, _nBot, _nDir,, "-2" )
Return _nAlt

Static Function TblHead( _prn, _nTop, _nEsq, _nDir, _nAlt )
   Local _nBot := _nTop + _nAlt
   Local _nWn  := 24
   Local _nXn  := _nEsq + _nWn
   Local _nWq  := Int((_nDir-_nEsq)*0.80)
   Local _nXq  := _nXn + _nWq
   Local _nWc  := 0
   Local _nX2  := 0
   Local _nX3  := 0

   If _nWq < 300 ; _nWq := 300 ; EndIf
   If _nXq > _nDir -  84 ; _nXq := _nDir -  84 ; EndIf
   _nWc := Int((_nDir - _nXq)/3)
   _nX2 := _nXq + _nWc
   _nX3 := _nX2 + _nWc

   _prn:Line( _nTop, _nEsq, _nTop, _nDir,, "-2" )
   _prn:Line( _nBot, _nEsq, _nBot, _nDir,, "-2" )
   _prn:Line( _nTop, _nEsq, _nBot, _nEsq,, "-2" )
   _prn:Line( _nTop, _nDir, _nBot, _nDir,, "-2" )
   _prn:Line( _nTop, _nXn , _nBot, _nXn ,, "-2" )
   _prn:Line( _nTop, _nXq , _nBot, _nXq ,, "-2" )
   _prn:Line( _nTop, _nX2 , _nBot, _nX2 ,, "-2" )
   _prn:Line( _nTop, _nX3 , _nBot, _nX3 ,, "-2" )

   _prn:Say( _nTop + Int((_nAlt-10)/2)+5, _nEsq+25, "QUESTÃO", oFB10 )
   _prn:Say( _nTop + Int((_nAlt-10)/2)+5, _nXq +10, "SIM",    oFB10 )
   _prn:Say( _nTop + Int((_nAlt-10)/2)+5, _nX2 +10, "NÃO",    oFB10 )
   _prn:Say( _nTop + Int((_nAlt-10)/2)+5, _nX3 +10, "N/A",    oFB10 )
Return _nAlt

Static Function TblRow( _prn, _nTop, _nEsq, _nDir, _nAlt, _nNum, _cTxt )
   Local _nBot := _nTop + _nAlt
   Local _nWn  := 24
   Local _nXn  := _nEsq + _nWn
   Local _nWq  := Int((_nDir-_nEsq)*0.80)
   Local _nXq  := _nXn + _nWq
   Local _nWc  := 0
   Local _nX2  := 0
   Local _nX3  := 0

   If _nWq < 300 ; _nWq := 300 ; EndIf
   If _nXq > _nDir -  84 ; _nXq := _nDir -  84 ; EndIf
   _nWc := Int((_nDir - _nXq)/3)
   _nX2 := _nXq + _nWc
   _nX3 := _nX2 + _nWc

   _prn:Line( _nTop, _nEsq, _nTop, _nDir,, "-2" )
   _prn:Line( _nBot, _nEsq, _nBot, _nDir,, "-2" )
   _prn:Line( _nTop, _nEsq, _nBot, _nEsq,, "-2" )
   _prn:Line( _nTop, _nDir, _nBot, _nDir,, "-2" )
   _prn:Line( _nTop, _nXn , _nBot, _nXn ,, "-2" )
   _prn:Line( _nTop, _nXq , _nBot, _nXq ,, "-2" )
   _prn:Line( _nTop, _nX2 , _nBot, _nX2 ,, "-2" )
   _prn:Line( _nTop, _nX3 , _nBot, _nX3 ,, "-2" )

   _prn:Say( _nTop + Int((_nAlt-10)/2)+5, _nEsq+8, cValToChar(_nNum), oFA09 )
   _prn:Say( _nTop + Int((_nAlt-10)/2)+5, _nXn +6, _cTxt, oFA09 )
Return _nAlt

Static Function SayMid( _prn, _nTop, _nEsq, _nDir, _cTxt, _oFon, _nClr )
   Local _nW := _nDir - _nEsq
   _prn:SayAlign( _nTop, _nEsq, _cTxt, _oFon, _nW, 18, _nClr, 2,2 )
Return Nil

Static Function ParaTxt( _prn, _nTop, _nEsq, _nDir, _nAlt, _cTxt )
   Local _nBot := _nTop + _nAlt
   _prn:Line( _nTop, _nEsq, _nTop, _nDir,, "-2" )
   _prn:Line( _nBot, _nEsq, _nBot, _nDir,, "-2" )
   _prn:Line( _nTop, _nEsq, _nBot, _nEsq,, "-2" )
   _prn:Line( _nTop, _nDir, _nBot, _nDir,, "-2" )
   // texto com quebra automática dentro da caixa
   _prn:SayAlign( _nTop+6, _nEsq+8, _cTxt, oFA06, (_nDir-_nEsq-16), (_nAlt-12), NIL, 0, 0 )
Return _nAlt

Static Function SignRow( _prn, _nTop, _nEsq, _nDir, _c1, _c2, _c3 )
   Local _nAlt := 36
   Local _w    := Int((_nDir-_nEsq)/3)
   Local _x2   := _nEsq + _w
   Local _x3   := _nEsq + _w*2
   _prn:Line( _nTop+24, _nEsq+10, _nTop+24, _x2 -10,, "-2" )
   _prn:Line( _nTop+24, _x2  +10, _nTop+24, _x3 -10,, "-2" )
   _prn:Line( _nTop+24, _x3  +10, _nTop+24, _nDir-10,, "-2" )
   _prn:Say ( _nTop+30, _nEsq+14, _c1, oFA09 )
   _prn:Say ( _nTop+30, _x2  +14, _c2, oFA09 )
   _prn:Say ( _nTop+30, _x3  +14, _c3, oFA09 )
Return _nAlt

Static Function AuthBx( _prn, _nTop, _nEsq, _nDir, _nAlt, _c1, _c2 )
   Local _nMid := Int((_nEsq + _nDir)/2)
   Local _nBot := _nTop + _nAlt
   _prn:Line( _nTop, _nEsq, _nBot, _nEsq,, "-2" )
   _prn:Line( _nTop, _nDir, _nBot, _nDir,, "-2" )
   _prn:Line( _nTop, _nEsq, _nTop, _nDir,, "-2" )
   _prn:Line( _nTop+24, _nEsq, _nTop+24, _nDir,, "-2" ) // separa Observações
   _prn:Line( _nBot, _nEsq, _nBot, _nDir,, "-2" )
   _prn:Line( _nTop, _nMid, _nTop+24, _nMid,, "-2" )
   ChkSq( _prn, _nEsq+10, _nTop+4 )
   _prn:Say ( _nTop+11,  _nEsq+24, _c1, oFB10 )
   ChkSq( _prn, _nMid+6, _nTop+4 )
   _prn:Say ( _nTop+11,  _nMid +24, _c2, oFB10 )
   _prn:Say ( _nTop+34, _nEsq+10, "OBSERVAÇÕES:", oFB10 )
Return _nAlt

Static Function ClasLbl( _prn, _nTop, _nEsq, _nDir )
   Local _nX0 := _nEsq+8
   Local _nX1 := _nEsq+100
   Local _nX2 := _nEsq+200
   Local _nX3 := _nEsq+310
   Local _nX4 := _nEsq+420
   _prn:Say( _nTop+10, _nX0, "CLASSIFICAÇÃO:", oFB10 )
   ChkSq( _prn, _nX1-12, _nTop+4 ) ; _prn:Say( _nTop+10, _nX1, "INSUMO COSMÉTICO",    oFA10 )
   ChkSq( _prn, _nX2-12, _nTop+4 ) ; _prn:Say( _nTop+10, _nX2, "INSUMO FARMACÊUTICO", oFA10 )
   ChkSq( _prn, _nX3-12, _nTop+4 ) ; _prn:Say( _nTop+10, _nX3, "INSUMO ALIMENTÍCIO",  oFA10 )
   ChkSq( _prn, _nX4-12, _nTop+4 ) ; _prn:Say( _nTop+10, _nX4, "AROMAS",              oFA10 )
Return Nil

Static Function Entrega( _prn, _nTop, _nEsq, _nDir )
   Local _nX0 := _nEsq+8
   Local _nX1 := _nEsq+160
   Local _nX2 := _nEsq+350
   _prn:Say( _nTop+10, _nX0, "A ENTREGA SERÁ REALIZADA:",    oFA10 )
   ChkSq( _prn, _nX1-12, _nTop+4 ) ; _prn:Say( _nTop+10, _nX1, "TRANSPORTADORA (REDESPACHO)", oFA10 )
   ChkSq( _prn, _nX2-12, _nTop+4 ) ; _prn:Say( _nTop+10, _nX2, "CLIENTE",  oFA10 )
Return Nil


Static Function SigBx3( _prn, _nTop, _nEsq, _nDir, _nAlt, _c1, _c2, _c3 )
   Local _nBot := _nTop + _nAlt
   Local _w    := Int((_nDir-_nEsq)/3)
   Local _x2   := _nEsq + _w
   Local _x3   := _nEsq + _w*2
   // moldura
   _prn:Line( _nTop, _nEsq, _nTop, _nDir,, "-2" )
   _prn:Line( _nBot, _nEsq, _nBot, _nDir,, "-2" )
   _prn:Line( _nTop, _nEsq, _nBot, _nEsq,, "-2" )
   _prn:Line( _nTop, _nDir, _nBot, _nDir,, "-2" )
   // divisões
   _prn:Line( _nTop, _x2 , _nBot, _x2 ,, "-2" )
   _prn:Line( _nTop, _x3 , _nBot, _x3 ,, "-2" )
   // linhas de assinatura na metade inferior
   _prn:Line( _nTop+_nAlt-12, _nEsq+14, _nTop+_nAlt-12, _x2 -14,, "-2" )
   _prn:Line( _nTop+_nAlt-12, _x2  +14, _nTop+_nAlt-12, _x3 -14,, "-2" )
   _prn:Line( _nTop+_nAlt-12, _x3  +14, _nTop+_nAlt-12, _nDir-14,, "-2" )
   // rótulos
   _prn:Say ( _nTop+_nAlt-4, _nEsq+18, _c1, oFA09 )
   _prn:Say ( _nTop+_nAlt-4, _x2  +18, _c2, oFA09 )
   _prn:Say ( _nTop+_nAlt-4, _x3  +18, _c3, oFA09 )
Return _nAlt

Static Function ChkSq( _prn, _nX, _nY )
   _prn:Line( _nY,   _nX,   _nY,   _nX+8,, "-2" )
   _prn:Line( _nY+8, _nX,   _nY+8, _nX+8,, "-2" )
   _prn:Line( _nY,   _nX,   _nY+8, _nX,,   "-2" )
   _prn:Line( _nY,   _nX+8, _nY+8, _nX+8,, "-2" )
Return Nil
