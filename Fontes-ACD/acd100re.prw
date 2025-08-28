#include "totvs.ch"
#include "APWIZARD.CH"
#include "FILEIO.CH"
#include "RPTDEF.CH"                                      
#include "FWPrintSetup.ch"
#include "PARMTYPE.CH"


/*/{Protheus.doc} acd100re
Ponto de Entrada do relatorio customizado de Ordens de Separacao
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 03/09/2024
@return character, Nome do fonte
/*/
User Function acd100re()
Return "xacd100r"


/*/{Protheus.doc} xacd100r
Relatorio customizado de Ordens de Separacao
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 03/09/2024
/*/
User Function xacd100r(_lImpAut)
    Local cRelName  := ""
    Local cPathDest := GetTempPath()
    Local oPrinter  := Nil

    Private cNow     := FWTimeStamp(1)
    Private cPergSX1 := "XACD100R"
    Private nMaxLin	 := 600
    Private nMaxCol	 := 800
    Default _lImpAut := .F.
    SetMVValue(cPergSX1, "MV_PAR01", CB7->CB7_ORDSEP            , .T.)
    SetMVValue(cPergSX1, "MV_PAR02", CB7->CB7_ORDSEP            , .T.)
    SetMVValue(cPergSX1, "MV_PAR03", FirstDate(CB7->CB7_DTEMIS) , .T.)
    SetMVValue(cPergSX1, "MV_PAR04", LastDate(CB7->CB7_DTEMIS)  , .T.)

    Pergunte(cPergSX1, !_lImpAut) 
        cRelName := "os_" + cNow
        oPrinter := FWMSPrinter():new(cRelName, IMP_PDF, .F., cPathDest, .T.)

        oPrinter:nDevice  := IMP_PDF
        oPrinter:cPathPDF := cPathDest
        oPrinter:setLandscape()
        oPrinter:setPaperSize(9)
        
        RptStatus({|lEnd| ACD100Imp(@lEnd, @oPrinter)}, "Imprimindo Relatorio...")

    FreeObj(oPrinter)

Return


/*/{Protheus.doc} ACD100Imp
Imprime o corpo do relatorio
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 03/09/2024
@param lEnd, logical, Variavel de controle
@param oPrinter, object, Objeto de impressao
/*/
Static Function ACD100Imp(lEnd, oPrinter)
    Local nMaxLinha := 8
    Local nLinCount := 0
    Local aArea		:= GetArea()
    Local cQry      := ""
    Local cOrdSep   := ""
    Local nLinhaBar := 0
    Local nColBar   := 0

    Private cAliasOS := GetNextAlias()
    Private nMargDir := 15
    Private nMargEsq := 20
    Private nColAmz	 := nMargEsq+135
    Private nColEnd	 := nColAmz+45
    Private nColLot	 := nColEnd+145
    Private nColVdd	 := nColLot+85
    Private nQtOri	 := nColVdd+75
    Private nQtSep	 := nQtOri+100
    Private nColVol	 := nQtSep+125

    Private oFontA7	 := TFont():new('Arial',,7,.T.)
    Private oFontA12 := TFont():new('Arial',,12,.T.)
    Private oFontC12 := TFont():new('Courier new',,12,.T.)
    Private li       := 14
    Private nLiItm   := 0
    Private nPag     := 0

    Pergunte(cPergSX1, .F.)

    //-- Monta o arquivo temporario
    cQry := " SELECT CB7_ORDSEP,CB7_PEDIDO,CB7_CLIENT,CB7_LOJA,CB7_NOTA,"+SerieNfId('CB7',3,'CB7_SERIE')+",CB7_OP,CB7_STATUS,CB7_ORIGEM, "
    cQry += " CB8_PROD,CB8_ORDSEP,CB8_LOCAL,CB8_LCALIZ,CB8_LOTECT,CB8_NUMLOT,CB8_NUMSER,CB8_QTDORI,CB8_SALDOS,CB8_SALDOE"
    cQry += " FROM "+RetSqlName("CB7")+","+RetSqlName("CB8")
    cQry += " WHERE CB7_FILIAL = '"+xFilial("CB7")+"' AND"
    cQry += " CB7_ORDSEP >= '"+MV_PAR01+"' AND"
    cQry += " CB7_ORDSEP <= '"+MV_PAR02+"' AND"
    cQry += " CB7_DTEMIS >= '"+DTOS(MV_PAR03)+"' AND"
    cQry += " CB7_DTEMIS <= '"+DTOS(MV_PAR04)+"' AND"
    cQry += " CB8_FILIAL = CB7_FILIAL AND"
    cQry += " CB8_ORDSEP = CB7_ORDSEP AND"

    //-- Nao Considera as Ordens ja finalizadas
    If MV_PAR05 == 2
        cQry += " CB7_STATUS <> '9' AND"
    EndIf

    cQry += " "+RetSqlName("CB8")+".D_E_L_E_T_ = '' AND"
    cQry += " "+RetSqlName("CB7")+".D_E_L_E_T_ = ''"
    cQry += " ORDER BY CB7_ORDSEP,CB8_PROD"

    cQry := ChangeQuery(cQry)                  
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasOS,.T.,.T.)

    SetRegua((cAliasOS)->(LastRec()))

    //-- Inicia a impressao do relatorio
    While !(cAliasOS)->(Eof())
        IncRegua()
        nLiItm    := 114
        nLinCount := 0
        nLinhaBar := 12.3
        nColBar   := 17
        nPag++
        oPrinter:startPage()
        CabPagina(@oPrinter)
        CabItem(@oPrinter,(cAliasOS)->CB7_ORIGEM)

        //-- Imprime os titulos das colunas dos itens
        oPrinter:sayAlign(li+100,nMargDir,"Produto",oFontC12,200,200,,0)
        oPrinter:sayAlign(li+100,nColAmz,"Arm.",oFontC12,200,200,,0)
        oPrinter:sayAlign(li+100,nColEnd,"Endereco",oFontC12,200,200,,0)
        oPrinter:sayAlign(li+100,nColLot,"Lote",oFontC12,200,200,,0)
        oPrinter:sayAlign(li+100,nColVdd,"Validade",oFontC12,200,200,,0)
        oPrinter:sayAlign(li+100,nQtOri,"Qtde. Original",oFontC12,200,200,,0)
        oPrinter:sayAlign(li+100,nQtSep,"Qtd. a Separar",oFontC12,200,200,,0)
        oPrinter:sayAlign(li+100,nColVol,"Volume",oFontC12,200,200,,0)
        oPrinter:line(li+114,nMargDir, li+114, nMaxCol-nMargEsq,, "-2")
        
        cOrdSep := (cAliasOS)->CB7_ORDSEP

        While !(cAliasOS)->(Eof()) .and. (cAliasOS)->CB8_ORDSEP == cOrdSep
            //-- Inicia uma nova pagina caso nao estiver em EOF
            If nLinCount == nMaxLinha
                oPrinter:startPage()
                nPag++
                CabPagina(@oPrinter)
                nLiItm    := li+50
                nLinCount := 0
                nLinhaBar := 8.2
                nColBar   := 17

                //-- Imprime os titulos das colunas dos itens		
                oPrinter:sayAlign(nLiItm,nMargDir,"Produto",oFontC12,200,200,,0)
                oPrinter:sayAlign(nLiItm,nColAmz,"Arm.",oFontC12,200,200,,0)
                oPrinter:sayAlign(nLiItm,nColEnd,"Endereco",oFontC12,200,200,,0)
                oPrinter:sayAlign(nLiItm,nColLot,"Lote",oFontC12,200,200,,0)
                oPrinter:sayAlign(nLiItm,nColVdd,"Validade",oFontC12,200,200,,0)
                oPrinter:sayAlign(nLiItm,nQtOri,"Qtde. Original",oFontC12,200,200,,0)
                oPrinter:sayAlign(nLiItm,nQtSep,"Qtd. a Separar",oFontC12,200,200,,0)
                oPrinter:sayAlign(nLiItm,nColVol,"Volume",oFontC12,200,200,,0)
                oPrinter:line(li+nLiItm,nMargDir, li+nLiItm, nMaxCol-nMargEsq,, "-2")
            EndIf

            //-- Imprime os itens da ordem de separacao
            oPrinter:sayAlign(li+nLiItm,nMargDir,(cAliasOS)->CB8_PROD,oFontC12,200,200,,0)
            oPrinter:sayAlign(li+nLiItm,nColAmz,(cAliasOS)->CB8_LOCAL,oFontC12,200,200,,0)
            oPrinter:sayAlign(li+nLiItm,nColEnd,(cAliasOS)->CB8_LCALIZ,oFontC12,200,200,,0)
            //-- Codigo de barras do endereco
            oPrinter:FWMSBAR("CODE128", nLinhaBar, nColBar, AllTrim((cAliasOS)->CB8_LOCAL)+AllTrim((cAliasOS)->CB8_LCALIZ),oPrinter,,,, 0.0164, 0.6,, "Courier New",, .F.,,,)
            oPrinter:sayAlign(li+nLiItm,nColLot,(cAliasOS)->CB8_LOTECT,oFontC12,200,200,,0)
            oPrinter:sayAlign(li+nLiItm,nColVdd,DToC(Posicione("SB8",3,xFilial("SB8")+(cAliasOS)->(CB8_PROD+CB8_LOCAL+CB8_LOTECT),"B8_DTVALID")),oFontC12,200,200,,0)
            oPrinter:sayAlign(li+nLiItm,nQtOri+li,Transform((cAliasOS)->CB8_QTDORI,PesqPictQt("CB8_QTDORI",20)),oFontC12,200,200,1,0) 
            oPrinter:sayAlign(li+nLiItm,nQtSep+li,Transform((cAliasOS)->CB8_SALDOS,PesqPictQt("CB8_QTDORI",20)),oFontC12,200,200,1,0)
            oPrinter:sayAlign(li+nLiItm,nColVol+li,CValToChar((cAliasOS)->CB8_QTDORI/Posicione("SB1",1,xFilial("SB1")+(cAliasOS)->(CB8_PROD),"B1_CONV")),oFontC12,200,200,1,0)
            
            nLinCount++

            //-- Finaliza a pagina quando atingir a quantidade maxima de itens	
            If nLinCount == nMaxLinha
                oPrinter:line(550,nMargDir, 550, nMaxCol-nMargEsq,, "-2")
                oPrinter:endPage()
            Else
                nLiItm    += li+40
                nLinhaBar += 4.6
            EndIf

            (cAliasOS)->(dbSkip())
            Loop
        EndDo

        //-- Finaliza a pagina se a quantidade de itens for diferente da quantidade
        //-- maxima, para evitar que a pagina seja finalizada mais de uma vez.
        If nLinCount <> nMaxLinha
            oPrinter:line(550,nMargDir, 550, nMaxCol-nMargEsq,, "-2")
            oPrinter:endPage()
        EndIf
    EndDo

    oPrinter:Print()

    (cAliasOS)->(dbCloseArea())
    RestArea(aArea)

Return


/*/{Protheus.doc} CabPagina
Imprime o cabecalho do relatorio
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 03/09/2024
@param oPrinter, object, Objeto de impressao
/*/
Static Function CabPagina(oPrinter)
    Private nCol1Dir := 720-nMargDir   
    Private nCol2Dir := 760-nMargDir

    oPrinter:line(li+5, nMargDir, li+5, nMaxCol-nMargEsq,, "-8")

    oPrinter:sayAlign(li+10,nMargDir,"ACD100RE",oFontA7,200,200,,0)
    oPrinter:sayAlign(li+20,nMargDir,"Hora: "+Time(),oFontA7,200,200,,0)
    oPrinter:sayAlign(li+30,nMargDir,"Empresa: "+FWFilialName(,,2) ,oFontA7,300,200,,0)

    oPrinter:sayAlign(li+20,340,"Impressao das Ordens de Separacao",oFontA12,nMaxCol-nMargEsq,200,2,0)

    oPrinter:sayAlign(li+10,nCol1Dir,"Folha   : ",oFontA7,200,200,,0)
    oPrinter:sayAlign(li+20,nCol1Dir,"Dt. Ref.: ",oFontA7,200,200,,0)
    oPrinter:sayAlign(li+30,nCol1Dir,"Emissao : ",oFontA7,200,200,,0)

    oPrinter:sayAlign(li+10,nCol2Dir,AllTrim(STR(nPag)),oFontA7,200,200,,0)
    oPrinter:sayAlign(li+20,nCol2Dir,DTOC(ddatabase),oFontA7,200,200,,0)
    oPrinter:sayAlign(li+30,nCol2Dir,DTOC(ddatabase),oFontA7,200,200,,0)

    oPrinter:line(li+40,nMargDir, li+40, nMaxCol-nMargEsq,, "-8")

Return


/*/{Protheus.doc} CabItem
Imprime o cabecalho do relatorio
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 03/09/2024
@param oPrinter, object, Objeto de impressao
@param cOrigem, character, Origem, tipo da ordem de separacao
/*/
Static Function CabItem(oPrinter, cOrigem)
    Local cOrdSep  := AllTrim((cAliasOS)->CB7_ORDSEP)
    Local cPedVen  := AllTrim((cAliasOS)->CB7_PEDIDO)
    Local cClient  := AllTrim((cAliasOS)->CB7_CLIENT)+"-"+AllTrim((cAliasOS)->CB7_LOJA)
    Local cNFiscal := AllTrim((cAliasOS)->CB7_NOTA)+"-"+AllTrim((cAliasOS)->&(SerieNfId('CB7',3,'CB7_SERIE')))
    Local cOP	   := AllTrim((cAliasOS)->CB7_OP)
    Local cStatus  := RetStatus((cAliasOS)->CB7_STATUS)

    oPrinter:sayAlign(li+50,nMargDir,"Ordem Separacao:",oFontC12,200,200,,0)
    oPrinter:sayAlign(li+50,nMargDir+95,cOrdSep,oFontC12,200,200,,0)

    If Alltrim(cOrigem) == "1" // Pedido venda
        If Empty(cPedVen) .And. (cAliasOS)->CB7_STATUS <> "9"
            oPrinter:sayAlign(li+50,nMargDir+360,"PV's Aglutinados:",oFontC12,200,200,,0)
            oPrinter:sayAlign(li+50,nMargDir+460,A100AglPd(cOrdSep),oFontC12,550,200,,0)		
        Else
            oPrinter:sayAlign(li+50,nMargDir+360,"Pedido de Venda:",oFontC12,200,200,,0)
            oPrinter:sayAlign(li+50,nMargDir+455,cPedVen,oFontC12,200,200,,0)
        EndIf
        oPrinter:sayAlign(li+70,nMargDir,"Cliente:",oFontC12,200,200,,0)
        oPrinter:sayAlign(li+70,nMargDir+50,cClient,oFontC12,200,200,,0)
        oPrinter:sayAlign(li+70,nMargDir+160,"Nome Cliente:",oFontC12,200,200,,0)
        oPrinter:sayAlign(li+70,nMargDir+240,AllTrim(Posicione("SA1", 1, xFilial("SA1") + (cAliasOS)->CB7_CLIENT + (cAliasOS)->CB7_LOJA, "A1_NREDUZ")),oFontC12,200,200,,0)
    ElseIf Alltrim(cOrigem) == "2" // Nota Fiscal
        oPrinter:sayAlign(li+50,nMargDir+360,"Nota Fiscal:",oFontC12,200,200,,0)
        oPrinter:sayAlign(li+50,nMargDir+435,cNFiscal,oFontC12,200,200,,0)
        oPrinter:sayAlign(li+70,nMargDir,"Cliente:",oFontC12,200,200,,0)
        oPrinter:sayAlign(li+70,nMargDir+50,cClient,oFontC12,200,200,,0)
        oPrinter:sayAlign(li+70,nMargDir+160,"Nome Cliente:",oFontC12,200,200,,0)
        oPrinter:sayAlign(li+70,nMargDir+240,AllTrim(Posicione("SA1", 1, xFilial("SA1") + (cAliasOS)->CB7_CLIENT + (cAliasOS)->CB7_LOJA, "A1_NREDUZ")),oFontC12,200,200,,0)
    ElseIf Alltrim(cOrigem) == "3" // Ordem de Producao
        oPrinter:sayAlign(li+50,nMargDir+360,"Ordem de Producao:",oFontC12,200,200,,0)
        oPrinter:sayAlign(li+50,nMargDir+465,cOP,oFontC12,200,200,,0)
    EndIf

    oPrinter:sayAlign(li+50,nMargDir+160,"Status:",oFontC12,200,200,,0)
    oPrinter:sayAlign(li+50,nMargDir+205,cStatus,oFontC12,200,200,,0)
    oPrinter:line(li+90,nMargDir, li+90, nMaxCol-nMargEsq,, "-2")

    If MV_PAR06 == 1
        //-- Ordem Separacao
        oPrinter:FWMSBAR("CODE128",5/*nRow*/,60/*nCol*/,AllTrim(cOrdSep),oPrinter,,,, 0.049,1.0,,,,.F.,,,)
    ElseIf MV_PAR06 == 2 .And. !Empty(cPedVen)
        //-- Pedido Venda
        oPrinter:FWMSBAR("CODE128",5/*nRow*/,60/*nCol*/,AllTrim(cPedVen),oPrinter,,,, 0.049,1.0,,,,.F.,,,)
    ElseIf MV_PAR06 == 3 .And. !Empty((cAliasOS)->CB7_NOTA)
        //-- Nota Fiscal
        oPrinter:FWMSBAR("CODE128",5/*nRow*/,58/*nCol*/,AllTrim((cAliasOS)->CB7_NOTA)+AllTrim((cAliasOS)->&(SerieNfId('CB7',3,'CB7_SERIE'))),oPrinter,,,, 0.049,1.0,,,,.F.,,,)
    ElseIf MV_PAR06 == 4 .And. !Empty(cOP)
        //-- Ordem Producao
        oPrinter:FWMSBAR("CODE128",5/*nRow*/,56/*nCol*/,AllTrim(cOP),oPrinter,,,, 0.049,1.0,,,,.F.,,,)
    EndIf

Return


/*/{Protheus.doc} RetStatus
Retorna o Status da Ordem de Separacao
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 03/09/2024
@param cStatus, character, Codigo do status
@return character, Descricao do status
/*/
Static Function RetStatus(cStatus)
    Local cDescri := ""

    If Empty(cStatus) .or. cStatus == "0"
        cDescri:= "Nao iniciado"
    ElseIf cStatus == "1"
        cDescri:= "Em separacao"
    ElseIf cStatus == "2"
        cDescri:= "Separacao finalizada"
    ElseIf cStatus == "3"
        cDescri:= "Em processo de embalagem"
    ElseIf cStatus == "4"
        cDescri:= "Embalagem Finalizada"
    ElseIf cStatus == "5"
        cDescri:= "Nota gerada"
    ElseIf cStatus == "6"
        cDescri:= "Nota impressa"
    ElseIf cStatus == "7"
        cDescri:= "Volume impresso"
    ElseIf cStatus == "8"
        cDescri:= "Em processo de embarque"
    ElseIf cStatus == "9"
        cDescri:= "Finalizado"
    EndIf

Return cDescri


/*/{Protheus.doc} A100AglPd
Retorna String com os Pedidos de Venda aglutinados na OS
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 03/09/2024
@param cOrdSep, character, Numero da Ordem de Separacao
@return variant, PVs aglutinados
/*/
Static Function A100AglPd(cOrdSep)
    Local cAliasPV	:= GetNextAlias()
    Local cQuery	:= ""
    Local cPedidos	:= ""
    Local aArea		:= GetArea()

    cQuery := "SELECT C9_PEDIDO FROM "+RetSqlName("SC9")+" WHERE C9_ORDSEP = '"+cOrdSep+"' AND "
    cQuery += "C9_FILIAL = '"+xFilial("SC9")+"' AND D_E_L_E_T_ = '' ORDER BY C9_PEDIDO"

    cQuery := ChangeQuery(cQuery)                  
    DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasPV,.T.,.T.)

    While !(cAliasPV)->(EOF())
        cPedidos += (cAliasPV)->C9_PEDIDO+"/"
        (cAliasPV)->(dbSkip())
    EndDo

    (cAliasPV)->(dbCloseArea())
    RestArea(aArea)

    If Len(cPedidos) > 119
        cPedidos := SubStr(cPedidos,1,119)+"..."
    EndIf

Return cPedidos
