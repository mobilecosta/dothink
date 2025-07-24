#include"totvs.ch"
#include"matxdef.ch"
#include"dbstruct.ch"
#include"fwmvcdef.ch"

static __cTitulo :="Validação Fiscal"

/*/{Protheus.doc} U_TRK0005
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
            ,"4=Todos";
        }
        aAdd(aParamBox,{2,"Listar Pedidos",0,aTiposDePedidos,100,"",.F.})
        lExecute:=ParamBox(@aParamBox,"Selecione os Parametros",@aParamRet,NIL,NIL,.T.,NIL,NIL,NIL,NIL,.T.,.T.)
        if (lExecute)
            cTipoPedido:=Left(if(valtype(aParamRet[1])=="N",aTiposDePedidos[aParamRet[1]],allTrim(aParamRet[1])),1)
            TRK0005Brw(cTipoPedido,aTiposDePedidos)
        endif
    RestInter()

    FWFreeArray(@aParamBox)
    FWFreeArray(@aParamRet)
    FWFreeArray(@aTiposDePedidos)

return()

/*/{Protheus.doc} TRK0005Brw
Carrega o Browse conforme Filtro inicial
@type function
@version 1.0
@author Conceitho
@since 22/07/2025
/*/
static function TRK0005Brw(cTipoPedido as character,aTiposDePedidos as array)

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

    local nTipoPed as numeric

    local oPanelMain as object
    local oFWMarkBrowse as object
    local oFWDialogModal as object
    local oFWTemporaryTable as object

    private __aTiposDePedidos:=aTiposDePedidos

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
        ,{"A1_NOME",TamSX3("A1_NOME"),GetSX3Cache("A1_NOME","X3_TITULO"),GetSX3Cache("A1_NOME","X3_PICTURE"),"SA1.A1_NOME"};
        ,{"C6_PRODUTO",TamSX3("C6_PRODUTO"),GetSX3Cache("C6_PRODUTO","X3_TITULO"),GetSX3Cache("C6_PRODUTO","X3_PICTURE"),"SC6.C6_PRODUTO"};
        ,{"B1_DESC",TamSX3("B1_DESC"),GetSX3Cache("B1_DESC","X3_TITULO"),GetSX3Cache("B1_DESC","X3_PICTURE"),"SB1.B1_DESC"};
        ,{"C9_DATENT",TamSX3("C9_DATENT"),GetSX3Cache("C9_DATENT","X3_TITULO"),GetSX3Cache("C9_DATENT","X3_PICTURE"),"ISNULL(SC9.C9_DATENT,SC6.C6_ENTREG) AS C9_DATENT"};
        ,{"B1_ORIGEM",TamSX3("B1_ORIGEM"),GetSX3Cache("B1_ORIGEM","X3_TITULO"),GetSX3Cache("B1_ORIGEM","X3_PICTURE"),"SB1.B1_ORIGEM"};
        ,{"FT_BASEICM",TamSX3("FT_BASEICM"),GetSX3Cache("FT_BASEICM","X3_TITULO"),GetSX3Cache("FT_BASEICM","X3_PICTURE"),"0 AS FT_BASEICM"};
        ,{"FT_VALICM",TamSX3("FT_VALICM"),GetSX3Cache("FT_VALICM","X3_TITULO"),GetSX3Cache("FT_VALICM","X3_PICTURE"),"0 AS FT_VALICM"};
        ,{"F4_SITTRIB",TamSX3("F4_SITTRIB"),GetSX3Cache("F4_SITTRIB","X3_TITULO"),GetSX3Cache("F4_SITTRIB","X3_PICTURE"),"SF4.F4_SITTRIB"};
        ,{"FT_BASEIPI",TamSX3("FT_BASEIPI"),GetSX3Cache("FT_BASEIPI","X3_TITULO"),GetSX3Cache("FT_BASEIPI","X3_PICTURE"),"0 AS FT_BASEIPI"};
        ,{"FT_VALIPI",TamSX3("FT_VALIPI"),GetSX3Cache("FT_VALIPI","X3_TITULO"),GetSX3Cache("FT_VALIPI","X3_PICTURE"),"0 AS FT_VALIPI"};
        ,{"F4_CTIPI",TamSX3("F4_CTIPI"),GetSX3Cache("F4_CTIPI","X3_TITULO"),GetSX3Cache("F4_CTIPI","X3_PICTURE"),"SF4.F4_CTIPI"};
        ,{"FT_BASEPIS",TamSX3("FT_BASEPIS"),GetSX3Cache("FT_BASEPIS","X3_TITULO"),GetSX3Cache("FT_BASEPIS","X3_PICTURE"),"0 AS FT_BASEPIS"};
        ,{"FT_VALPIS",TamSX3("FT_VALPIS"),GetSX3Cache("FT_VALPIS","X3_TITULO"),GetSX3Cache("FT_VALPIS","X3_PICTURE"),"0 AS FT_VALPIS"};
        ,{"F4_CSTPIS",TamSX3("F4_CSTPIS"),GetSX3Cache("F4_CSTPIS","X3_TITULO"),GetSX3Cache("F4_CSTPIS","X3_PICTURE"),"SF4.F4_CSTPIS"};
        ,{"FT_BASECOF",TamSX3("FT_BASECOF"),GetSX3Cache("FT_BASECOF","X3_TITULO"),GetSX3Cache("FT_BASECOF","X3_PICTURE"),"0 AS FT_BASECOF"};
        ,{"FT_VALCOF",TamSX3("FT_VALCOF"),GetSX3Cache("FT_VALCOF","X3_TITULO"),GetSX3Cache("FT_VALCOF","X3_PICTURE"),"0 AS FT_VALCOF"};
        ,{"F4_CSTCOF",TamSX3("F4_CSTCOF"),GetSX3Cache("F4_CSTCOF","X3_TITULO"),GetSX3Cache("F4_CSTCOF","X3_PICTURE"),"SF4.F4_CSTCOF"};
        ,{"SC5RECNO",{18,0,"N"},"RecNo SC5","@R 999999999999999999","SC5.R_E_C_N_O_ AS SC5RECNO"};
        ,{"SC6RECNO",{18,0,"N"},"RecNo SC6","@R 999999999999999999","SC6.R_E_C_N_O_ AS SC6RECNO"};
        ,{"SC9RECNO",{18,0,"N"},"RecNo SC9","@R 999999999999999999","ISNULL(SC9.R_E_C_N_O_,0) AS SC9RECNO"};
        ,{"SB1RECNO",{18,0,"N"},"RecNo SB1","@R 999999999999999999","SB1.R_E_C_N_O_ AS SB1RECNO"};
        ,{"SA1RECNO",{18,0,"N"},"RecNo SA1","@R 999999999999999999","SA1.R_E_C_N_O_ AS SA1RECNO"};
        ,{"SF4RECNO",{18,0,"N"},"RecNo SF4","@R 999999999999999999","SF4.R_E_C_N_O_ AS SF4RECNO"};
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

        if (aCustomFields[nField][1]=="C5_XBLFIS")
            aFWMBrwColumn[nField]:SetData(&("{|oSelf|u_TRK005Fld('"+aCustomFields[nField][1]+"',"+aCustomFields[nField][1]+",__aTiposDePedidos)}"))
        else
            aFWMBrwColumn[nField]:SetData(&("{|oSelf|"+aCustomFields[nField][1]+"}"))
        endif

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

    //https://tdn.totvs.com/display/public/framework/FWTemporaryTable
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
      JOIN SA1990 SA1 ON SA1.D_E_L_E_T_=' ' AND SA1.A1_FILIAL='__A1_FILIAL__' AND SA1.A1_COD=SC5.C5_CLIENTE AND SA1.A1_LOJA=SC5.C5_LOJACLI
      JOIN SC6990 SC6 ON SC6.D_E_L_E_T_=' ' AND SC6.C6_FILIAL=SC5.C5_FILIAL AND SC6.C6_NUM=SC5.C5_NUM
      JOIN SB1990 SB1 ON SB1.D_E_L_E_T_=' ' AND SB1.B1_FILIAL='__B1_FILIAL__' AND SB1.B1_COD=SC6.C6_PRODUTO
      JOIN SF4990 SF4 ON SF4.D_E_L_E_T_=' ' AND SF4.F4_FILIAL='__F4_FILIAL__' AND SF4.F4_CODIGO=SC6.C6_TES
 LEFT JOIN SC9990 SC9 ON SC9.D_E_L_E_T_=' ' AND SC9.C9_FILIAL= '__C9_FILIAL__' AND SC9.C9_PEDIDO=SC6.C6_NUM AND SC9.C9_ITEM=SC6.C6_ITEM
     WHERE SC5.D_E_L_E_T_=' ' AND SC5.C5_FILIAL='__C5_FILIAL__' AND SC5.C5_XBLFIS IN(__XBLFIS)
    endContent
    //Efetua a Substituicao das constantes por Valores Dinamicos
    cQuerySelect:=StrTran(cQuerySelect,"cQueryGetFields",cQueryGetFields)
    cQuerySelect:=StrTran(cQuerySelect,"SC5990",RetSQLName("SC5"))
    cQuerySelect:=StrTran(cQuerySelect,"SA1990",RetSQLName("SA1"))
    cQuerySelect:=StrTran(cQuerySelect,"SB1990",RetSQLName("SB1"))
    cQuerySelect:=StrTran(cQuerySelect,"SC9990",RetSQLName("SC9"))
    cQuerySelect:=StrTran(cQuerySelect,"__A1_FILIAL__",FWXFilial("SA1"))
    cQuerySelect:=StrTran(cQuerySelect,"__B1_FILIAL__",FWXFilial("SB1"))
    cQuerySelect:=StrTran(cQuerySelect,"__F4_FILIAL__",FWXFilial("SF4"))
    cQuerySelect:=StrTran(cQuerySelect,"__C9_FILIAL__",FWXFilial("SC9"))
    cQuerySelect:=StrTran(cQuerySelect,"__C5_FILIAL__",FWXFilial("SC5"))

    if (cTipoPedido=="4") //TODOS
        cINXBLFIS:=""
        for nTipoPed:=1 to Len(aTiposDePedidos)
            cINXBLFIS+="'"+Left(aTiposDePedidos[nTipoPed],1)+"'"
            if (nTipoPed<Len(aTiposDePedidos))
                cINXBLFIS+=","
            endif
        next nTipoPed
        cINXBLFIS:=StrTran(cINXBLFIS,"4"," ")
    else //Apenas o Selecionado
        cINXBLFIS:="'"+cTipoPedido+"'"
    endif
    cQuerySelect:=StrTran(cQuerySelect,"__XBLFIS",cINXBLFIS)

    cAlias:=oFWTemporaryTable:GetAlias()
    cRealTableName:=oFWTemporaryTable:getRealName()

    //Elabora a Query para o Insert na Tabela Temporaria
    cQueryInsert:="INSERT INTO"+cRealTableName
    cQueryInsert+=" ("+cQueryPutFields+")"
    cQueryInsert+=cQuerySelect

    //Executa o Insert..
    FWMsgRun(NIL,{||lQueryInsert:=(TCSQLExec(cQueryInsert)>=0)},"Aguarde...","Obtendo dados no SGBD")

    if (lQueryInsert)

        //Update de campos Fiscais
        FWMsgRun(NIL,{||TRK0005Fis(cAlias)},"Aguarde...","Atualizando Informações Fiscais")

        FWMsgRun(NIL,{||Sleep(300)},"Aguarde...","Elaborando a Interface de Dados")

        aFWGetDialogSizeCoors:=FWGetDialogSize()

        (cAlias)->(dbSetOrder(1))

        //Define o Dialog
        //https://tdn.totvs.com/display/public/framework/FwDialogModal
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

        oFWMarkBrowse:AddLegend("C5_XBLFIS=='1'"/*<xCondition>*/,"RED"/*<cColor>*/,"Bloqueados"/*[<cTitle>]*/,"ID_C5_XBLFIS"/*[<cID>]*/,.T./*[<lFilter>]*/)
        oFWMarkBrowse:AddLegend("C5_XBLFIS=='2'"/*<xCondition>*/,"GREEN"/*<cColor>*/,"Liberados"/*[<cTitle>]*/,"ID_C5_XBLFIS"/*[<cID>]*/,.T./*[<lFilter>]*/)
        oFWMarkBrowse:AddLegend("C5_XBLFIS=='3'"/*<xCondition>*/,"GRAY"/*<cColor>*/,"Rejeitados"/*[<cTitle>]*/,"ID_C5_XBLFIS"/*[<cID>]*/,.T./*[<lFilter>]*/)

        oFWMarkBrowse:SetColumns(aFWMBrwColumn)
        oFWMarkBrowse:SetSeek(.T.,aFWMBrowseSeek)
        oFWMarkBrowse:SetUseFilter(.T.)
        oFWMarkBrowse:SetFieldFilter(aFWMBrowseFilter)
        oFWMarkBrowse:SetMenuDef("")

        //oFWMarkBrowse:AddButton(cTitle,xAction,uParam1,nOption,nVerify,lNeedFind)
        oFWMarkBrowse:AddButton("&Liberar",{||TRK0005Lib(cTitulo,cAlias,oFWMarkBrowse)},NIL,2)
        oFWMarkBrowse:AddButton("&Rejeitar",{||TRK0005Rej(cTitulo,cAlias,oFWMarkBrowse)},NIL,2)
        oFWMarkBrowse:AddButton("&Bloquear",{||TRK0005Blq(cTitulo,cAlias,oFWMarkBrowse)},NIL,2)
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

/*/{Protheus.doc} TRK0005Fis
Atualizar informações Fiscais
@type function
@version 1.0
@author Conceitho
@since 22/07/2025
/*/
static function TRK0005Fis(cAlias)

    local aMaFisNFCabRet as array
    local aRecItens as array

    local cPedido as character
    local cCliente as character

    local nAT as numeric
    local nItem as numeric
    local nItems as numeric
    local nNextRecNo as numeric

    (cAlias)->(dbGoTop())
    (cAlias)->(dbSetOrder(1))
    while ((cAlias)->(!eof()))
        MaFisSave()
        MaFisEnd()
        SA1->(MsGoTo((cAlias)->SA1RECNO))
        SC5->(MsGoTo((cAlias)->SC5RECNO))
        (cAlias)->(MaFisIni(SC5->C5_CLIENTE,SC5->C5_LOJACLI,"C","N",SC5->C5_TIPOCLI,NIL,NIL,.T.,NIL,"MATA415"))
        cPedido:=(cAlias)->C5_NUM
        aRecItens:=Array(0)
        while ((cAlias)->(!eof().and.(cPedido==C5_NUM)))
            SC6->(MsGoTo((cAlias)->SC6RECNO))
            aAdd(aRecItens,(cAlias)->SC6RECNO)
            SC6->(;
                MaFisAdd(;
                        SC6->C6_PRODUTO;   //  1-Codigo do Produto ( Obrigatorio )
                    ,SC6->C6_TES;       //  2-Codigo do TES ( Opcional )
                    ,SC6->C6_QTDVEN;    //  3-Quantidade ( Obrigatorio ) SC6->C6_QTDVEN
                    ,SC6->C6_PRCVEN;    //  4-Preco Unitario ( Obrigatorio ) SC6->C6_PRCVEN
                    ,0;                 //  5-Valor do Desconto ( Opcional )
                    ,"";                //  6-Numero da NF Original ( Devolucao/Benef )
                    ,"";                //  7-Serie da NF Original ( Devolucao/Benef )
                    ,0;                 //  8-RecNo da NF Original no arq SD1/SD2
                    ,0;                 //  9-Valor do Frete do Item ( Opcional )
                    ,0;                 // 10-Valor da Despesa do item ( Opcional )
                    ,0;                 // 11-Valor do Seguro do item ( Opcional )
                    ,0;                 // 12-Valor do Frete Autonomo ( Opcional )
                    ,SC6->C6_VALOR;     // 13-Valor da Mercadoria ( Obrigatorio ) SC6->C6_VALOR
                    ,0;                 // 14-Valor da Embalagem ( Opiconal )
                    ,NIL;               // 15-RecNo do SB1
                    ,NIL;               // 16-RecNo do SF4
                );
            )
            (cAlias)->(dbSkip())
            nNextRecNo:=(cAlias)->(RecNo())
        end while
        //Obter as informações Fiscais
        aMaFisNFCabRet:=MaFisNFCab()
        //Atualizar as informações fiscais.
        if ((!Empty(aMaFisNFCabRet)).and.(!Empty(aRecItens)))
            nItems:=Len(aRecItens)
            //TODO: Rever a forma de Obter as informações de Impostos em: aRecItens
            for nItem:=1 to nItems
                (cAlias)->(MsGoTo(aRecItens[nItem]))
                if ((cAlias)->(RecLock(cAlias,.F.)))
                    nAT:=aScan(aMaFisNFCabRet,{|x|Upper(AllTrim(x[1]))=="ICM"})
                    if (nAT>0)
                        (cAlias)->FT_BASEICM:=aMaFisNFCabRet[nAT][3]
                        (cAlias)->FT_VALICM:=aMaFisNFCabRet[nAT][5]
                    endif
                    nAT:=aScan(aMaFisNFCabRet,{|x|Upper(AllTrim(x[1]))=="IPI"})
                    if (nAT>0)
                        (cAlias)->FT_BASEIPI:=aMaFisNFCabRet[nAT][3]
                        (cAlias)->FT_VALIPI:=aMaFisNFCabRet[nAT][5]
                    endif
                    nAT:=aScan(aMaFisNFCabRet,{|x|Upper(AllTrim(x[1]))=="PIS"})
                    if (nAT>0)
                        (cAlias)->FT_BASEPIS:=aMaFisNFCabRet[nAT][3]
                        (cAlias)->FT_VALPIS:=aMaFisNFCabRet[nAT][5]
                    endif
                    nAT:=aScan(aMaFisNFCabRet,{|x|Upper(AllTrim(x[1]))=="COF"})
                    if (nAT>0)
                        (cAlias)->FT_BASECOF:=aMaFisNFCabRet[nAT][3]
                        (cAlias)->FT_VALCOF:=aMaFisNFCabRet[nAT][5]
                    endif
                    (cAlias)->(MsUnLock())
                endif
            next nItem
            (cAlias)->(MsGoTo(nNextRecNo))
        endif
        //Limpa os itens da NF e zera as variaveis do cabecalho.
        MaFisClear()
        FWFreeArray(@aMaFisNFCabRet)
        FWFreeArray(@aRecItens)
        MaFisEnd()
        MaFisRestore()
    end while

return

/*/{Protheus.doc} TRK0005Lib
Processa a Liberação
@type function
@version 1.0
@author Conceitho
@since 22/07/2025
/*/
static function TRK0005Lib(cTitulo,cAlias,oFWMarkBrowse)

    local aArea:=FWGetArea()
    local aAreaAlias:=(cAlias)->(FWGetArea())
    local aFilBRWQry:=Array(0) as array

    local cC5Num:=(cAlias)->C5_NUM as character
    local cC5Cliente:=(cAlias)->C5_CLIENTE as character

    local cFilBRWExp as character

    local cProcTitle:=cTitulo+" :: Liberação"

    local lRet:=.F. as logical

    //Verifica se o Item Está Bloqueado
    lRet:=((cAlias)->C5_XBLFIS=="1")

    if (lRet)

        //Processa a Liberação
        (cAlias)->(dbGoTop())
        while ((cAlias)->(!eof()))
            SC5->(MsGoTo((cAlias)->SC5RECNO))
            if (SC5->C5_XBLFIS!="2")
                if (SC5->(RecLock("SC5",.F.)))
                    SC5->C5_XBLFIS:="2" //Liberado
                    //Grava o campo C5_MSEXP para sinalizaro ao Scheduler
                    if (SC5->(FieldPos("C5_MSEXP"))>0)
                        SC5->C5_MSEXP:=DToS(dDataBase)
                    endif
                    SC5->(MsUnLock())
                endif
            endif
            //Atualiza, também, no alias temporário para atualização do status
            if ((cAlias)->(RecLock(cAlias,.F.)))
                (cAlias)->C5_XBLFIS:=SC5->C5_XBLFIS
                (cAlias)->(MsUnLock())
            endif
            (cAlias)->(dbSkip())
        end while

    else

        ApMsgInfo("O Pedido não está Bloqueado. Só é possível Liberar Pedidos Bloqueados.",cProcTitle)

    endif

    FWRestArea(aAreaAlias)
    FWFreeArray(@aAreaAlias)

    FWRestArea(aArea)
    FWFreeArray(@aArea)

    if (lRet)
        oFWMarkBrowse:Refresh()
    endif

return(lRet)

/*/{Protheus.doc} TRK0005Rej
Processa a Rejeição
@type function
@version 1.0
@author Conceitho
@since 22/07/2025
/*/
static function TRK0005Rej(cTitulo,cAlias,oFWMarkBrowse)

    local aArea:=FWGetArea()
    local aAreaAlias:=(cAlias)->(FWGetArea())
    local aFilBRWQry:=Array(0) as array

    local cRejCod as character
    local cRejObs as character

    local cC5Num:=(cAlias)->C5_NUM as character
    local cC5Cliente:=(cAlias)->C5_CLIENTE as character

    local cFilBRWExp as character

    local cProcTitle:=cTitulo+" :: Rejeição"

    local lRet:=.F. as logical

    local nRejSiz:=6 as numeric

    local oOk as object
    local oDlg as object
    local oPanel as object
    local oCancel as object
    local oCodRej as object
    local oRejObs as object

    cRejCod:=Space(Min(GetSX3Cache("X5_CHAVE","X3_TAMANHO"),nRejSiz))
    cRejObs:=Space(50)

    //Verifica se o Item Está Bloqueado
    lContinue:=((cAlias)->C5_XBLFIS=="1")

    if (lContinue)

        DEFINE MSDIALOG oDlg FROM 0,0 TO 275,450 TITLE cProcTitle PIXEL OF GetWNDDefault()

            @ 000,000 MSPANEL oPanel OF oDlg
            oPanel:Align:=CONTROL_ALIGN_ALLCLIENT

            @ 007,005 SAY "Código Rejeição:" SIZE 45,08 OF oPanel PIXEL
            @ 005,048 MSGET oCodRej VAR cRejCod SIZE CalcFieldSize("C",nRejSiz,0,"@!",Replicate("W",nRejSiz)),08 OF oPanel PIXEL F3 "Z0" VALID CodRejVld(@cRejCod,nRejSiz,@oCodRej)

            @018,005 SAY "Observação" SIZE 60,07 OF oPanel PIXEL
            @026,005 GET oRejObs VAR cRejObs MEMO SIZE 220,087 CENTERED DESIGN OF oPanel PIXEL WHEN (.T.)

            DEFINE SBUTTON oOk     FROM 120,(220-48) TYPE 1 ENABLE OF oPanel PIXEL ACTION Eval({|lRet,oDlg|(lRet:=.T.,oDlg:End())},@lRet,oDlg)
            DEFINE SBUTTON oCancel FROM 120,(220-20) Type 2 ENABLE OF oPanel PIXEL ACTION oDlg:End()

            oRejObs:lReadOnly:=.F.
            oRejObs:EnableVScroll(.T.)
            oRejObs:EnableHScroll(.T.)

            oDlg:lEscClose:=.F.

        ACTIVATE MSDIALOG oDlg CENTER ON INIT (oDlg:SetFocus())

        if (lRet)
            SC5->(MsGoTo((cAlias)->SC5RECNO))
            if (SC5->C5_XBLFIS!="3")
                if (SC5->(RecLock("SC5",.F.)))
                    SC5->C5_XBLFIS:="3" //Rejeitado
                    SC5->C5_XCMTBLF:=cRejCod
                    SC5->C5_XOMTBLF:=cRejObs
                    //Grava o campo C5_MSEXP para sinalizaro ao Scheduler
                    if (SC5->(FieldPos("C5_MSEXP"))>0)
                        SC5->C5_MSEXP:=DToS(dDataBase)
                    endif
                    SC5->(MsUnLock())
                endif
            endif
            //Atualiza, também, no alias temporário para atualização do status
            if ((cAlias)->(RecLock(cAlias,.F.)))
                (cAlias)->C5_XBLFIS:=SC5->C5_XBLFIS
                (cAlias)->(MsUnLock())
            endif
        endif

    else

        ApMsgInfo("O Pedido não está Bloqueado. Só é possível Rejeitar Pedidos Bloqueados.",cProcTitle)

    endif

    FreeObj(@oOk)
    FreeObj(@oDlg)
    FreeObj(@oPanel)
    FreeObj(@oCancel)
    FreeObj(@oCodRej)
    FreeObj(@oRejObs)

    FWRestArea(aAreaAlias)
    FWFreeArray(@aAreaAlias)

    FWRestArea(aArea)
    FWFreeArray(@aArea)

    if (lRet)
        oFWMarkBrowse:Refresh()
    endif

return(lRet)

/*/{Protheus.doc} CodRejVld
Valida e Normaliza o Codigo de Rejeição.
@type function
@version 1.0
@author Conceitho
@since 22/07/2025
/*/
static function CodRejVld(cRejCod as character,nRejSiz as numeric,oCodRej as object) as logical
    cRejCod:=PadL(AllTrim(cRejCod),nRejSiz,"0")
    oCodRej:Refresh()
return(ExistCpo("SX5","Z0"+cRejCod,1))

/*/{Protheus.doc} TRK0005Blq
Processa o Bloqueio
@type function
@version 1.0
@author Conceitho
@since 22/07/2025
/*/
static function TRK0005Blq(cTitulo,cAlias,oFWMarkBrowse)

    local aArea:=FWGetArea()
    local aAreaAlias:=(cAlias)->(FWGetArea())
    local aFilBRWQry:=Array(0) as array

    local cC5Num:=(cAlias)->C5_NUM as character
    local cC5Cliente:=(cAlias)->C5_CLIENTE as character

    local cFilBRWExp as character

    local cProcTitle:=cTitulo+" :: Bloqueio"

    local lRet:=.F. as logical
    local lContinue as logical

    //Verifica se o Item Está Bloqueado
    lRet:=((cAlias)->C5_XBLFIS!="1")

    if (lRet)

        //Processa a Liberação
        SC5->(MsGoTo((cAlias)->SC5RECNO))
        if (SC5->C5_XBLFIS!="1")
            if (SC5->(RecLock("SC5",.F.)))
                SC5->C5_XBLFIS:="1" //Bloqueado
                //Limpa os Campos de Rejeição
                SC5->C5_XCMTBLF:=""
                SC5->C5_XOMTBLF:=""
                //Grava o campo C5_MSEXP para sinalizaro ao Scheduler
                if (SC5->(FieldPos("C5_MSEXP"))>0)
                    SC5->C5_MSEXP:=DToS(dDataBase)
                endif
                SC5->(MsUnLock())
            endif
        endif
        //Atualiza, também, no alias temporário para atualização do status
        if ((cAlias)->(RecLock(cAlias,.F.)))
            (cAlias)->C5_XBLFIS:=SC5->C5_XBLFIS
            (cAlias)->(MsUnLock())
        endif
    else

        ApMsgInfo("O Pedido já se encontra Bloqueado. Só é possível Bloquear Pedidos não Bloqueados.",cProcTitle)

    endif

    FWRestArea(aAreaAlias)
    FWFreeArray(@aAreaAlias)

    FWRestArea(aArea)
    FWFreeArray(@aArea)

    if (lRet)
        oFWMarkBrowse:Refresh()
    endif

return(lRet)

/*/{Protheus.doc} u_TRK005Fld
Retorna informação Customizada para o Campo
@type function
@version 1.0
@author Conceitho
@since 22/07/2025
/*/
function u_TRK005Fld(cField as character,xValue,xAscan as variant)
    local xRet as variable
    local nAT as numeric
    if (cField=="C5_XBLFIS")
        nAT:=aScan(xAscan,{|x|Left(x,1)==xValue})
        if (nAT>0)
            xRet:=xAscan[nAT]
        endif
    endif
return(xRet)
