#include "totvs.ch"
#include "matxdef.ch"
#include "dbstruct.ch"
#include "fwmvcdef.ch"

static __cTitulo := "Validação Fiscal"

/*/{Protheus.doc} U_TRK00005
Parametros para Filtro do Browse
@type function
@version 1.0
@author Conceitho
@since 22/07/2025
/*/
function U_TRK0005() as logical

    local aParamBox:=Array(0) as array
    local aParamRet:=Array(0) as array
    local aTiposDePedidos as array

    local cTipoPedido as character

    local lExecute as logical

        SaveInter()
            aTiposDePedidos:={;
                 "1=Bloqueados";
                ,"2=Liberados";
                ,"3=Rejeitados";
                ,"7=Todos";
            }
            aAdd(aParamBox,{2,"Listar Pedidos",0,aTiposDePedidos,100,"",.F.})
            lExecute:=ParamBox(@aParamBox,"Selecione os Parametros",@aParamRet,NIL,NIL,.T.,NIL,NIL,NIL,NIL,.T.,.T.)
            if (lExecute)
                cTipoPedido:=Left(if(valtype(aParamRet[1])=="N",aTiposDePedidos[aParamRet[1]],allTrim(aParamRet[1])),1)
                TRK005Brw(cTipoPedido)
            endif
        RestInter()

    FWFreeArray(@aParamBox)
    FWFreeArray(@aParamRet)
    FWFreeArray(@aTiposDePedidos)

return()

/*/{Protheus.doc} TRK00030Brw
Carrega o Browse conforme Filtro inicial
@type function
@version 1.0
@author Conceitho
@since 22/07/2025
/*/
static function TRK005Brw(cTipoPedido as character)

    local aDbStruct:=Array(0) as array
    local aCustomFields as array
    local aFWMBrwColumn:=Array(0) as array
    local aFWMBrowseSeek:=Array(0) as array
    local aFWMBrowseFilter:=Array(0) as array
    local aFWMBrowseQryIndex:=Array(0) as array
    local aFWGetDialogSizeCoors as array

    local bFWTmpTblIdxOrder as codeblock

    local cAlias as character
    local cTitulo:=__cTitulo as character
    local cINXBLFIS as character

    local cQuerySelect as character
    local cQueryInsert as character
    local cQueryPutFields:="" as character
    local cQueryGetFields:="" as character

    local cTCSQLError as character
    local cRealTableName as character
    local cFWTmpTblIdxOrder as character

    local lQueryInsert as logical

    local nIndex:=0 as numeric
    local nField as numeric
    local nFields as numeric

    local oPanelMain as object
    local oFWMarkBrowse as object
    local oFWDialogModal as object
    local oFWTemporaryTable as object

    /* Define os Campos que irao aparecer no Browse
        aCustomFields[n][1]=>Nome do Campo
        aCustomFields[n][2]=>TamSX3=>{Size,Dec,Type}
        aCustomFields[n][3]=>Titulo do Campo
        aCustomFields[n][4]=>Picture do Campo
        aCustomFields[n][5]=>Expressao SQL do Campo
    */
    aCustomFields:={;
         {"C5_XBLFIS",TamSX3("C5_XBLFIS"),GetSX3Cache("C5_XBLFIS","X3_TITULO"),GetSX3Cache("C5_XBLFIS","X3_PICTURE"),"(CASE SC5.C5_XBLFIS WHEN ' ' THEN '1' ELSE SC5.C5_XBLFIS END) C5_XBLFIS"};
        ,{"C5_NUM",TamSX3("C5_NUM"),GetSX3Cache("C5_NUM","X3_TITULO"),GetSX3Cache("C5_NUM","X3_PICTURE"),"SC5.C5_NUM"};
        ,{"C6_ITEM",TamSX3("C6_ITEM"),GetSX3Cache("C6_ITEM","X3_TITULO"),GetSX3Cache("C6_ITEM","X3_PICTURE"),"SC6.C6_ITEM"};
        ,{"C5_CLIENTE",TamSX3("C5_CLIENTE"),GetSX3Cache("C5_CLIENTE","X3_TITULO"),GetSX3Cache("C5_CLIENTE","X3_PICTURE"),"SC5.C5_CLIENTE"};
        ,{"A1_RAZAO",TamSX3("A1_RAZAO"),GetSX3Cache("A1_RAZAO","X3_TITULO"),GetSX3Cache("A1_RAZAO","X3_PICTURE"),"SA1.A1_RAZAO"};
        ,{"C6_PRODUT",TamSX3("C6_PRODUT"),GetSX3Cache("C6_PRODUT","X3_TITULO"),GetSX3Cache("C6_PRODUT","X3_PICTURE"),"SC6.C6_PRODUT"};
        ,{"B1_DESC",TamSX3("B1_DESC"),GetSX3Cache("B1_DESC","X3_TITULO"),GetSX3Cache("B1_DESC","X3_PICTURE"),"SB1.B1_DESC"};
        ,{"C9_DATENT",TamSX3("C9_DATENT"),GetSX3Cache("C9_DATENT","X3_TITULO"),GetSX3Cache("C9_DATENT","X3_PICTURE"),"ISNULL(SC9.C9_DATENT,SC6.C6_ENTREG) AS C9_DATENT"};
        ,{"B1_ORIGEM",TamSX3("B1_ORIGEM"),GetSX3Cache("B1_ORIGEM","X3_TITULO"),GetSX3Cache("B1_ORIGEM","X3_PICTURE"),"SB1.B1_ORIGEM"};
        ,{"BC_VLRICMS",{18,4,"N"},"BC ICMS (Valor ICMS)","@R 9999999999999.9999","0 AS BC_VLRICMS"};
        ,{"BC_CSTICMS",{18,4,"N"},"BC ICMS (CST ICMS)","@R 9999999999999.9999","0 AS BC_CSTICMS"};
        ,{"BC_IPI",{18,4,"N"},"BC ICMS (BC IPI)","@R 9999999999999.9999","0 AS BC_IPI"};
        ,{"BC_VLRIPI",{18,4,"N"},"BC ICMS (Valor IPI)","@R 9999999999999.9999","0 AS BC_VLRIPI"};
        ,{"BC_CSTIPI",{18,4,"N"},"BC ICMS (CST IPI)","@R 9999999999999.9999","0 AS BC_CSTIPI"};
        ,{"BC_PISCONF",{18,4,"N"},"BC ICMS (PIS/Cofins)","@R 9999999999999.9999","0 AS BC_PISCONF"};
        ,{"BC_VPISCON",{18,4,"N"},"BC ICMS (Vlr PIS/Cofins)","@R 9999999999999.9999","0 AS BC_VPISCON"};
        ,{"CST_PICOFI",{18,4,"N"},"CST (PI/Cofins)","@R 9999999999999.9999","0 CST_PICOFI"};
        ,{"SC5RECNO",{18,0,"N"},"RecNo SC5","@R 999999999999999999","SC5.R_E_C_N_O_ AS SC5RECNO"};
        ,{"SC6RECNO",{18,0,"N"},"RecNo SC6","@R 999999999999999999","SC6.R_E_C_N_O_ AS SC6RECNO"};
        ,{"SC9RECNO",{18,0,"N"},"RecNo SC9","@R 999999999999999999","ISNULL(SC9.R_E_C_N_O_,0) AS SC9RECNO"};
        ,{"SB1RECNO",{18,0,"N"},"RecNo SB1","@R 999999999999999999","SB1.R_E_C_N_O_ AS SB1RECNO"};
        ,{"COLMARK",{1,0,"C"},"Mark","@!","' ' AS COLMARK"};
    }

    nFields:=Len(aCustomFields)
    for nField:=1 to nFields

        //Carrega a Estrutura da Tabela Temporaria
        aAdd(aDbStruct,Array(DBS_ALEN))
        aDbStruct[nField][DBS_NAME]:=aCustomFields[nField][1]
        aDbStruct[nField][DBS_TYPE]:=aCustomFields[nField][2][3]
        aDbStruct[nField][DBS_LEN]:=aCustomFields[nField][2][1]
        aDbStruct[nField][DBS_DEC]:=aCustomFields[nField][2][2]

        //Obtem os Campos para a Query
        cQueryPutFields+=aCustomFields[nField][1]
        cQueryGetFields+=aCustomFields[nField][5]
        if (nField<nFields)
            cQueryPutFields+=","
            cQueryGetFields+=","
        endif

        //Habilita o campo para Pesquisa
        aAdd(aFWMBrowseSeek,;
            {;
                aCustomFields[nField][3],;//[n,1] Titulo da pesquisa
                {;
                    {;
                        "",;//[n,2,n,1] LookUp (F3)
                        aDbStruct[nField][DBS_TYPE],;//[n,2,n,2] Tipo de dados
                        aDbStruct[nField][DBS_LEN],;//[n,2,n,3] Tamanho
                        aDbStruct[nField][DBS_DEC],;//[n,2,n,4] Decimal
                        aCustomFields[nField][3],;//[n,2,n,5] Titulo do campo
                        aCustomFields[nField][4],;//[n,2,n,6] Mascara
                        NIL;//[n,2,n,7] Nome Fisico do campo (Opcional) e ajustado no programa
                    };
                },;
                nIndex++,;//[n,3] Ordem da pesquisa
                .T.;//[n,4] Exibe na pesquisa
            };
        )

        //Define o Campo como Indice
        aAdd(aFWMBrowseQryIndex,{aDbStruct[nField][DBS_NAME]})

        //Define o Campo como Filtravel
        aAdd(aFWMBrowseFilter,;
            {;
                aCustomFields[nField][1],;//Campo
                aCustomFields[nField][3],;//Titulo
                aDbStruct[nField][DBS_TYPE],;//Tipo de dado
                aDbStruct[nField][DBS_LEN],;//Tamanho
                aDbStruct[nField][DBS_DEC],;//Decimal
                aCustomFields[nField][4];//Picture
            };
        )

        //Monta as Colunas do Browse
        aAdd(aFWMBrwColumn,FWBrwColumn():New())

        aFWMBrwColumn[nField]:SetData(&("{|oSelf|"+aCustomFields[nField][1]+"}"))
        aFWMBrwColumn[nField]:SetTitle(aCustomFields[nField][3])
        aFWMBrwColumn[nField]:SetPicture(aCustomFields[nField][4])
        aFWMBrwColumn[nField]:SetSize(aDbStruct[nField][DBS_LEN])
        aFWMBrwColumn[nField]:SetDecimal(aDbStruct[nField][DBS_DEC])

        //Define o Alinhamento dos Campos
        if (aCustomFields[nField][2][3]=="N")
            aFWMBrwColumn[nField]:SetAlign("RIGHT")
        else
            aFWMBrwColumn[nField]:SetAlign("LEFT")
        endif

    next nField

    oFWTemporaryTable:=FWTemporaryTable():New()
    oFWTemporaryTable:SetFields(aDbStruct)

    cFWTmpTblIdxOrder:="00"
    bFWTmpTblIdxOrder:={|cFWTmpTblIdxOrder|cFWTmpTblIdxOrder:=__Soma1(cFWTmpTblIdxOrder)}

    oFWTemporaryTable:AddIndex(Eval(bFWTmpTblIdxOrder,@cFWTmpTblIdxOrder),{"C5_NUM","C6_ITEM"})

    nIndexes:=Len(aFWMBrowseQryIndex)
    for nIndex:=1 to nIndexes
        oFWTemporaryTable:AddIndex(Eval(bFWTmpTblIdxOrder,@cFWTmpTblIdxOrder),aFWMBrowseQryIndex[nIndex])
    next nIndex

    oFWTemporaryTable:Create()

    //Elabora a query dos pedidos
    beginContent var cQuerySelect
    SELECT cQueryGetFields
      FROM SC5990 SC5
      JOIN SC6990 SC6 ON SC6.C6_FILIAL=SC5.C5_FILIAL AND SC6.C6_NUM=SC5.C5_NUM AND SC6.D_E_L_E_T_ = = ' '
      JOIN SB1990 SB1 ON SB1.B1_FILIAL= '__C5_FILIAL__' AND SB1.B1_COD=SC6.C6_PRODUTO AND SB1.D_E_L_E_T_=' '
      LEFT JOIN SC9990 SC9 ON SC9.C9_FILIAL= '__C5_FILIAL__' AND SC9.C9_PEDIDO=SC6.C6_NUM AND SC9.C9_ITEM=SC6.C6_ITEM
       AND SC9.D_E_L_E_T_ = ' '
     WHERE SC5.C5_FILIAL='__C5_FILIAL__' AND SC5.C5_XBLFIS IN(__XBLFIS) AND SC5.D_E_L_E_T_ = ' '
    endContent
    //Efetua a Substituicao das constantes por Valores Dinamicos
    cQuerySelect:=strTran(cQuerySelect,"cQueryGetFields",cQueryGetFields)
    cQuerySelect:=strTran(cQuerySelect,"SC5990",RetSQLName("SC5"))
    cQuerySelect:=strTran(cQuerySelect,"SB1990",RetSQLName("SB1"))
    cQuerySelect:=strTran(cQuerySelect,"SC9990",RetSQLName("SC9"))
    cQuerySelect:=strTran(cQuerySelect,"__C5_FILIAL__",FWXFilial("SC5"))
    cQuerySelect:=strTran(cQuerySelect,"__B1_FILIAL__",FWXFilial("SB1"))

    if (cTipoPedido=="7")
        cINXBLFIS:="' ','1','2','3'"
    else
        cINXBLFIS:="'"+cTipoPedido+"'"
    endif
    cQuerySelect:=strTran(cQuerySelect,"__XBLFIS",cINXBLFIS)

    cAlias:=oFWTemporaryTable:GetAlias()
    cRealTableName:=oFWTemporaryTable:getRealName()

    //Elabora a Query para o Insert na Tabela Temporaria
    cQueryInsert:="INSERT INTO "+cRealTableName
    cQueryInsert+=" ("+cQueryPutFields+") "
    cQueryInsert+=cQuerySelect

    //Executa o Insert..
    FWMsgRun(NIL,{||lQueryInsert:=(TCSQLExec(cQueryInsert)>=0)},"Aguarde...","Obtendo dados no SGBD")

    if (lQueryInsert)

        //Update de campos Fiscais
        FWMsgRun(NIL,{||U_TRK05Fis(cAlias)},"Aguarde...","Atualizando Informações Fiscais")

        FWMsgRun(NIL,{||Sleep(300)},"Aguarde...","Elaborando a Interface de Dados")

        aFWGetDialogSizeCoors:=FWGetDialogSize()

        (cAlias)->(dbSetOrder(1))

        //Define o Dialog
        oFWDialogModal:=FWDialogModal():New()
        oFWDialogModal:SetTitle("")
        oFWDialogModal:SetEscClose(.F.)
        oFWDialogModal:SetSize(((aFWGetDialogSizeCoors[3]/(2+if(.F.,.15,0)))+25),((aFWGetDialogSizeCoors[4]/2)-5))
        oFWDialogModal:CreateDialog()
        oFWDialogModal:EnableFormBar(.T.)
        oFWDialogModal:CreateFormBar()

        oPanelMain:=oFWDialogModal:GetPanelMain()

        oFWMarkBrowse:=FWMarkBrowse():New()

        oFWMarkBrowse:SetOwner(oPanelMain)
        oFWMarkBrowse:SetDescription(cTitulo)
        oFWMarkBrowse:SetDataTable()
        oFWMarkBrowse:SetTemporary(.T.)
        oFWMarkBrowse:SetAlias(cAlias)
        oFWMarkBrowse:SetFieldMark("COLMARK")
        oFWMarkBrowse:SetMark(NIL,cAlias,"COLMARK")

        oFWMarkBrowse:AddLegend("C5_XBLFIS=='1'"/*<xCondition>*/,"RED"/*<cColor>*/,"Bloqueados"/*[<cTitle>]*/,"ID_C5_XBLFIS"/*[<cID>]*/,.T./*[<lFilter>]*/)
        oFWMarkBrowse:AddLegend("C5_XBLFIS=='2'"/*<xCondition>*/,"GREEN"/*<cColor>*/,"Liberados"/*[<cTitle>]*/,"ID_C5_XBLFIS"/*[<cID>]*/,.T./*[<lFilter>]*/)
        oFWMarkBrowse:AddLegend("C5_XBLFIS=='3'"/*<xCondition>*/,"GRAY"/*<cColor>*/,"Rejeitados"/*[<cTitle>]*/,"ID_C5_XBLFIS"/*[<cID>]*/,.T./*[<lFilter>]*/)

        oFWMarkBrowse:SetColumns(aFWMBrwColumn)
        oFWMarkBrowse:SetSeek(.T.,aFWMBrowseSeek)
        oFWMarkBrowse:SetUseFilter(.T.)
        oFWMarkBrowse:SetFieldFilter(aFWMBrowseFilter)
        oFWMarkBrowse:SetMenuDef("")

        //oFWMarkBrowse:AddButton(cTitle,xAction,uParam1,nOption,nVerify,lNeedFind)
        oFWMarkBrowse:AddButton("&Liberar",{||MsgInfo("Liberar",cTitulo)},NIL,2)
        oFWMarkBrowse:AddButton("&Rejeitar",{||MsgInfo("Rejeitar",cTitulo)},NIL,2)
        oFWMarkBrowse:AddButton("&Sair",{||oFWDialogModal:Deactivate()},NIL,2)

        FWMsgRun(;
            NIL,;
            {||;
                 oFWMarkBrowse:Activate();
            },;
            cTitulo,;
            "Ativando o Browse...";
        )

        oFWDialogModal:Activate()

        FreeObj(@oPanelMain)
        FreeObj(@oFWMarkBrowse)
        FreeObj(@oFWDialogModal)

    else

        cTCSQLError:=TCSQLError()
        EECView(cTCSQLError,"TCSQLError")
        EECView(cQueryInsert,"Query View")

    endif

    oFWTemporaryTable:delete()
    FreeObj(@oFWTemporaryTable)

    FWFreeArray(@aDbStruct)
    FWFreeArray(@aCustomFields)
    aEval(@aFWMBrwColumn,{|o|FreeObj(@o)})
    FWFreeArray(@aFWMBrwColumn)
    FWFreeArray(@aFWMBrowseSeek)
    FWFreeArray(@aFWMBrowseFilter)
    FWFreeArray(@aFWMBrowseQryIndex)
    FWFreeArray(@aFWGetDialogSizeCoors)

    DelClassIntF()

return

/*/{Protheus.doc} TRK05Fis
Atualizar informações Fiscais
@type function
@version 1.0
@author Conceitho
@since 22/07/2025
/*/
static function TRK05Fis(cAlias)

    local aRetImp as array

    local cPedido as character
    local cCliente as character

    MaFisSave()

    (cAlias)->(dbGoTop())
    (cAlias)->(dbSetOrder(1))
    while ((cAlias)->(!eof()))
        MaFisSave()
        MaFisEnd()
        cCliente:=(cAlias)->C5_CLIENTE
        SC5->(MsGoTo((cAlias)->SC5RECNO))
        (cAlias)->(MaFisIni(C5_CLIENTE,SC5->C5_LOJACLI,"C","N",SC5->C5_TIPOCLI,NIL,NIL,.T.,NIL,"MATA415"))
        while ((cAlias)->(!eof().and.(cCliente==C5_CLIENTE)))
            cPedido:=(cAlias)->C5_NUM
            while ((cAlias)->(!eof().and.(cCliente==C5_CLIENTE).and.(cPedido==C5_NUM)))
                SC6->(MsGoTo((cAlias)->SC6RECNO))
                SC6->(;
                        MaFisAdd(;
                         SC6->C6_PRODUTO;    //  1-Codigo do Produto ( Obrigatorio )
                        ,SC6->C6_TES;        //  2-Codigo do TES ( Opcional )
                        ,SC6->C6_QTDVEN;     //  3-Quantidade ( Obrigatorio ) SC6->C6_QTDVEN
                        ,SC6->C6_VALOR;      //  4-Preco Unitario ( Obrigatorio ) SC6->C6_VALOR
                        ,0;             //  5-Valor do Desconto ( Opcional )
                        ,"";            //  6-Numero da NF Original ( Devolucao/Benef )
                        ,"";            //  7-Serie da NF Original ( Devolucao/Benef )
                        ,0;             //  8-RecNo da NF Original no arq SD1/SD2
                        ,0;             //  9-Valor do Frete do Item ( Opcional )
                        ,0;             // 10-Valor da Despesa do item ( Opcional )
                        ,0;             // 11-Valor do Seguro do item ( Opcional )
                        ,0;             // 12-Valor do Frete Autonomo ( Opcional )
                        ,C6_VALOR;      // 13-Valor da Mercadoria ( Obrigatorio ) SC6->C6_VALOR
                        ,0;             // 14-Valor da Embalagem ( Opiconal )
                        ,NIL;           // 15-RecNo do SB1
                        ,NIL;           // 16-RecNo do SF4
                    );
                )
                (cAlias)->(dbSkip())
            end while
            aRetImp:=MaFisNFCab()
            //TODO: Atualizar as informações fiscais.
            //Limpa os itens da NF e zera as variaveis do cabecalho.
            MaFisClear()
        end while
        FWFreeArray(@aRetImp)
        MaFisEnd()
        MaFisRestore()
    end while

    MaFisRestore()

return
