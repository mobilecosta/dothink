#include"totvs.ch"
#include "topconn.ch"
#include"dbstruct.ch"

static __cTitulo       := "Validação Fiscal"
static aTiposDePedidos := {"1=Bloqueados", "2=Liberados", "3=Rejeitados", "4=Todos"}

/*/{Protheus.doc} TRK0005
Parametros para Filtro do Browse
@type function
@version 1.0
@author wagner.mobile@dothink.com.br
@since 22/07/2025
/*/
user function TRK0005() as logical

    local aParamBox:=Array(0) as array

    if SC5->(FieldPos("C5_MSEXP")) == 0 .Or. SC5->(FieldPos("C5_XBLFIS")) == 0
        ApMsgInfo("Os campos C5_MSEXP e C5_XBLFIS são obrigatórios para funcionamento dessa rotina !")

        Return
    endif

    SaveInter()
        
        aAdd(aParamBox,{2,"Listar Pedidos",4,aTiposDePedidos,100,"",.T.})
        if ParamBox(@aParamBox,"Selecione os Parametros",,NIL,NIL,.T.,NIL,NIL,NIL,NIL,.T.,.T.)
            if ValType(mv_par01) == "N"
                mv_par01 := Str(mv_par01, 1)
            endif
            TRK0005Brw(mv_par01)
        endif

    RestInter()

    FWFreeArray(@aParamBox)

return()

/*/{Protheus.doc} TRK0005Brw
Carrega o Browse conforme Filtro inicial
@type function
@version 1.0
@author DoThink
@since 22/07/2025
/*/
static function TRK0005Brw(cTipoPedido as character)

    local aDbStruct          := Array(0)  as array
    local aCustomFields                   as array
    local aFWMBrwColumn      := Array(0)  as array
    local aFWMBrowseQryIndex := Array(0)  as array
    local aFWGetDialogSizeCoors           as array
    local aDadosFil          := {}        as array

    local cAlias                          as character
    local cTitulo            := __cTitulo as character
    
    local cQuerySelect                    as character
    local cQueryInsert                    as character
    local cQueryPutFields    := ""        as character

    local cTCSQLError                     as character
    local cRealTableName                  as character

    local lQueryInsert                    as logical

    local nField                          as numeric
    local nFields                         as numeric

    local oPanelMain                      as object
    local oBrowse                         as object
    local oFWDialogModal                  as object
    local oFWTemporaryTable               as object

    aCustomFields := GetFields()
    cQuerySelect  := GetQuery(cTipoPedido)

    aFilter := {}
    nFields:=Len(aCustomFields)
    for nField:=1 to nFields

        //Carrega a Estrutura da Tabela Temporaria
        aAdd(aDbStruct,Array(DBS_ALEN))
        aDbStruct[nField][DBS_NAME] := aCustomFields[nField][1]
        aDbStruct[nField][DBS_TYPE] := aCustomFields[nField][2][3]
        aDbStruct[nField][DBS_LEN]  := aCustomFields[nField][2][1]
        aDbStruct[nField][DBS_DEC]  := aCustomFields[nField][2][2]

        //Obtem os Campos para a Query
        cQueryPutFields += aCustomFields[nField][1]
        if (nField<nFields)
            cQueryPutFields += ","
        endif

        //Define o Campo como Filtravel
        // Não inclui os recnos no browse
        If "RECNO" $ aCustomFields[nField][1]
            Loop
        EndIF

        //Monta as Colunas do Browse
        aAdd(aFWMBrwColumn, FWBrwColumn():New())

        if (aCustomFields[nField][1]=="C5_XBLFIS")
            aFWMBrwColumn[nField]:SetData(&("{|oSelf|u_TRK005Fld('" + aCustomFields[nField][1] + "'," + aCustomFields[nField][1] + ")}"))
        else
            aFWMBrwColumn[nField]:SetData(&("{|oSelf|" + aCustomFields[nField][1] + "}"))
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
        

        //Filters
        aAdd(aFilter, {aCustomFields[nField][1], aCustomFields[nField][3], aCustomFields[nField][2][3], aCustomFields[nField][2][1], aCustomFields[nField][2][2], aCustomFields[nField][4]} )

    next nField

    //https://tdn.totvs.com/display/public/framework/FWTemporaryTable
    oFWTemporaryTable:=FWTemporaryTable():New()
    oFWTemporaryTable:SetFields(aDbStruct)
    oFWTemporaryTable:AddIndex("01",{"C5_NUM"       , "C6_ITEM" })
    oFWTemporaryTable:AddIndex("02",{"C5_CLIENTE"   , "C5_NUM"  })
    oFWTemporaryTable:AddIndex("03",{"C6_DATFAT"    , "C5_NUM"  , "C6_ITEM"})

	Aadd( aFWMBrowseSeek, { "Pedido + Item"                 , RetFldIdx("C5_NUM+C6_ITEM")           , 1 } )
	Aadd( aFWMBrowseSeek, { "Cliente + Pedido"              , RetFldIdx("C5_CLIENTE+C5_NUM")        , 1 } )
    Aadd( aFWMBrowseSeek, { "Faturamento + Pedido + Item"   , RetFldIdx("C6_DATFAT+C5_NUM+C6_ITEM") , 1 } )
    Aadd( aFWMBrowseSeek, { "Entrega + Dt.Fat + Dt.Ini.Blq.Fiscal"   , RetFldIdx("C6_ENTREG+C6_DATFAT+Z09_BLFDI") , 1 } )

    oFWTemporaryTable:Create()

    cAlias          := oFWTemporaryTable:GetAlias()
    cRealTableName  := oFWTemporaryTable:getRealName()

    //Elabora a Query para o Insert na Tabela Temporaria
    cQueryInsert := "INSERT INTO " + cRealTableName
    cQueryInsert += " (" + cQueryPutFields + ") "
    cQueryInsert += cQuerySelect

    //Executa o Insert..
    FWMsgRun(NIL, {|| lQueryInsert := (TCSQLExec(cQueryInsert)>=0) }, "Aguarde...", "Obtendo dados no SGBD")

    if (lQueryInsert)

        fInfo(@aDadosFil)

        //Update de campos Fiscais
        FWMsgRun(NIL, {|| TRK0005Fis(cAlias)            }, "Aguarde...", "Atualizando Informações Fiscais"  )

        FWMsgRun(NIL, {|| AtuTracking(cAlias, aDadosFil)}, "Aguarde...", "Atualizando Tracking de Expedição")

        FWMsgRun(NIL, {|| Sleep(100)                    }, "Aguarde...", "Elaborando a Interface de Dados"  )

        aFWGetDialogSizeCoors := FWGetDialogSize()

        (cAlias)->(dbSetOrder(1))

        //Define o Dialog
        //https://tdn.totvs.com/display/public/framework/FwDialogModal
        oFWDialogModal := FWDialogModal():New()
        oFWDialogModal:SetTitle("")
        oFWDialogModal:SetSize( ((aFWGetDialogSizeCoors[3]/(2+if(.F.,.15,0)))+25), ((aFWGetDialogSizeCoors[4]/2)-5) )
        oFWDialogModal:CreateDialog()
        oFWDialogModal:EnableFormBar(.T.)
        oFWDialogModal:CreateFormBar()

        oPanelMain  := oFWDialogModal:GetPanelMain()

        oBrowse     := FWMBrowse():New()
        oBrowse:SetOwner(oPanelMain)
        oBrowse:SetDescription(cTitulo)
        oBrowse:SetAlias(cAlias)

        oBrowse:AddLegend("C5_XBLFIS=='1'"  , "RED"     , "Bloqueado"  ,/*[<cID>]*/,.T./*[<lFilter>]*/)
        oBrowse:AddLegend("C5_XBLFIS=='2'"  , "GREEN"   , "Liberado"   ,/*[<cID>]*/,.T./*[<lFilter>]*/)
        oBrowse:AddLegend("C5_XBLFIS=='3'"  , "GRAY"    , "Rejeitado"  ,/*[<cID>]*/,.T./*[<lFilter>]*/)
        oBrowse:AddLegend("Empty(C5_XBLFIS)", "BLUE"    , "Sem Bloqueio",/*[<cID>]*/,.T./*[<lFilter>]*/)

        oBrowse:SetColumns(aFWMBrwColumn)
        oBrowse:SetSeek(.T.,aFWMBrowseSeek)
        oBrowse:SetMenuDef("")
        oBrowse:SetUseFilter(.T.)
        oBrowse:SetFieldFilter(aFilter) //Set Filters

        //oBrowse:AddButton(cTitle,xAction,uParam1,nOption,nVerify,lNeedFind)
        oBrowse:AddButton("&Liberar"        , {|| TRK0005Lib(cTitulo,cAlias,oBrowse)},NIL,2)
        oBrowse:AddButton("&Rejeitar"       , {|| TRK0005Rej(cTitulo,cAlias,oBrowse)},NIL,2)
        oBrowse:AddButton("&Bloquear"       , {|| TRK0005Blq(cTitulo,cAlias,oBrowse)},NIL,2)
        oBrowse:AddButton('Pedido Vendas'   , {|| TRK0005VPV(cAlias)})
        oBrowse:AddButton('Legenda'         , {|| TRK0005Leg()})
        oBrowse:AddButton("&Sair"           , {||oFWDialogModal:Deactivate()},NIL,2)

        FWMsgRun(;
            NIL,;
            {||;
                 oBrowse:Activate();
            },;
            cTitulo,;
            "Ativando o Browse...";
        )

        oFWDialogModal:Activate()

        FreeObj(@oPanelMain)
        FreeObj(@oBrowse)
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
    FWFreeArray(@aFWMBrowseQryIndex)
    FWFreeArray(@aFWGetDialogSizeCoors)

    DelClassIntF()

return


//--
Static Function GetFields()
    Local aFields := {}

    /* Define os Campos que irao aparecer no Browse
        aFields[n][1]=>Nome do Campo
        aFields[n][2]=>TamSX3=>{Size,Dec,Type}
        aFields[n][3]=>Titulo do Campo
        aFields[n][4]=>Picture do Campo
        aFields[n][5]=>Expressao SQL do Campo
    */
    aFields:={;
            {"C5_XBLFIS"   , TamSX3("C5_XBLFIS")   , GetSX3Cache("C5_XBLFIS"   ,"X3_TITULO"), GetSX3Cache("C5_XBLFIS"  ,"X3_PICTURE"),"C5_XBLFIS"      };
            ,{"C5_NUM"      , TamSX3("C5_NUM")      , GetSX3Cache("C5_NUM"      ,"X3_TITULO"), GetSX3Cache("C5_NUM"     ,"X3_PICTURE"),"SC5.C5_NUM"     };
            ,{"C6_ITEM"     , TamSX3("C6_ITEM")     , GetSX3Cache("C6_ITEM"     ,"X3_TITULO"), GetSX3Cache("C6_ITEM"    ,"X3_PICTURE"),"SC6.C6_ITEM"    };
            ,{"C5_CLIENTE"  , TamSX3("C5_CLIENTE")  , GetSX3Cache("C5_CLIENTE"  ,"X3_TITULO"), GetSX3Cache("C5_CLIENTE" ,"X3_PICTURE"),"SC5.C5_CLIENTE" };
            ,{"C5_LOJACLI"  , TamSX3("C5_LOJACLI")  , GetSX3Cache("C5_LOJACLI"  ,"X3_TITULO"), GetSX3Cache("C5_LOJACLI" ,"X3_PICTURE"),"SC5.C5_LOJACLI" };
            ,{"A1_NOME"     , TamSX3("A1_NOME")     , GetSX3Cache("A1_NOME"     ,"X3_TITULO"), GetSX3Cache("A1_NOME"    ,"X3_PICTURE"),"CASE WHEN C5_TIPO IN ('F', 'B') THEN SA2.A2_NOME ELSE SA1.A1_NOME END AS A1_NOME"    };
            ,{"C6_PRODUTO"  , TamSX3("C6_PRODUTO")  , GetSX3Cache("C6_PRODUTO"  ,"X3_TITULO"), GetSX3Cache("C6_PRODUTO" ,"X3_PICTURE"),"SC6.C6_PRODUTO" };       
            ,{"B1_DESC"     , TamSX3("B1_DESC")     , GetSX3Cache("B1_DESC"     ,"X3_TITULO"), GetSX3Cache("B1_DESC"    ,"X3_PICTURE"),"SB1.B1_DESC"    };
            ,{"C6_LOCAL"    , TamSX3("C6_LOCAL")    , GetSX3Cache("C6_LOCAL"    ,"X3_TITULO"), GetSX3Cache("C6_LOCAL"   ,"X3_PICTURE"),"SC6.C6_LOCAL"   }; 
            ,{"C6_CF"       , TamSX3("C6_CF")       , GetSX3Cache("C6_CF"       ,"X3_TITULO"), GetSX3Cache("C6_CF"      ,"X3_PICTURE"),"SC6.C6_CF"      };        
            ,{"B1_POSIPI"   , TamSX3("B1_POSIPI")   , GetSX3Cache("B1_POSIPI"   ,"X3_TITULO"), GetSX3Cache("B1_POSIPI"  ,"X3_PICTURE"),"SB1.B1_POSIPI"  };
            ,{"B1_ORIGEM"   , TamSX3("B1_ORIGEM")   , GetSX3Cache("B1_ORIGEM"   ,"X3_TITULO"), GetSX3Cache("B1_ORIGEM"  ,"X3_PICTURE"),"SB1.B1_ORIGEM"  };
            ,{"F4_SITTRIB"  , TamSX3("F4_SITTRIB")  , GetSX3Cache("F4_SITTRIB"  ,"X3_TITULO"), GetSX3Cache("F4_SITTRIB" ,"X3_PICTURE"),"SF4.F4_SITTRIB" };
            ,{"FT_BASEICM"  , TamSX3("FT_BASEICM")  , GetSX3Cache("FT_BASEICM"  ,"X3_TITULO"), GetSX3Cache("FT_BASEICM" ,"X3_PICTURE"),"0 AS FT_BASEICM"};
            ,{"FT_ALIQICM"  , TamSX3("FT_ALIQICM")  , GetSX3Cache("FT_ALIQICM"  ,"X3_TITULO"), GetSX3Cache("FT_ALIQICM" ,"X3_PICTURE"),"0 AS FT_ALIQICM"};
            ,{"FT_VALICM"   , TamSX3("FT_VALICM")   , GetSX3Cache("FT_VALICM"   ,"X3_TITULO"), GetSX3Cache("FT_VALICM"  ,"X3_PICTURE"),"0 AS FT_VALICM" };
            ,{"F4_CTIPI"    , TamSX3("F4_CTIPI")    , GetSX3Cache("F4_CTIPI"    ,"X3_TITULO"), GetSX3Cache("F4_CTIPI"   ,"X3_PICTURE"),"SF4.F4_CTIPI"   };
            ,{"FT_BASEIPI"  , TamSX3("FT_BASEIPI")  , GetSX3Cache("FT_BASEIPI"  ,"X3_TITULO"), GetSX3Cache("FT_BASEIPI" ,"X3_PICTURE"),"0 AS FT_BASEIPI"};
            ,{"FT_ALIQIPI"  , TamSX3("FT_ALIQIPI")  , GetSX3Cache("FT_ALIQIPI"  ,"X3_TITULO"), GetSX3Cache("FT_ALIQIPI" ,"X3_PICTURE"),"0 AS FT_ALIQIPI"};
            ,{"FT_VALIPI"   , TamSX3("FT_VALIPI")   , GetSX3Cache("FT_VALIPI"   ,"X3_TITULO"), GetSX3Cache("FT_VALIPI"  ,"X3_PICTURE"),"0 AS FT_VALIPI" };
            ,{"F4_CSTPIS"   , TamSX3("F4_CSTPIS")   , GetSX3Cache("F4_CSTPIS"   ,"X3_TITULO"), GetSX3Cache("F4_CSTPIS"  ,"X3_PICTURE"),"SF4.F4_CSTPIS"  };
            ,{"FT_BASEPIS"  , TamSX3("FT_BASEPIS")  , GetSX3Cache("FT_BASEPIS"  ,"X3_TITULO"), GetSX3Cache("FT_BASEPIS" ,"X3_PICTURE"),"0 AS FT_BASEPIS"};
            ,{"FT_ALIQPIS"  , TamSX3("FT_ALIQPIS")  , GetSX3Cache("FT_ALIQPIS"  ,"X3_TITULO"), GetSX3Cache("FT_ALIQPIS" ,"X3_PICTURE"),"0 AS FT_ALIQPIS"};
            ,{"FT_VALPIS"   , TamSX3("FT_VALPIS")   , GetSX3Cache("FT_VALPIS"   ,"X3_TITULO"), GetSX3Cache("FT_VALPIS"  ,"X3_PICTURE"),"0 AS FT_VALPIS" };
            ,{"F4_CSTCOF"   , TamSX3("F4_CSTCOF")   , GetSX3Cache("F4_CSTCOF"   ,"X3_TITULO"), GetSX3Cache("F4_CSTCOF"  ,"X3_PICTURE"),"SF4.F4_CSTCOF"  };
            ,{"FT_BASECOF"  , TamSX3("FT_BASECOF")  , GetSX3Cache("FT_BASECOF"  ,"X3_TITULO"), GetSX3Cache("FT_BASECOF" ,"X3_PICTURE"),"0 AS FT_BASECOF"};
            ,{"FT_ALIQCOF"  , TamSX3("FT_ALIQCOF")  , GetSX3Cache("FT_ALIQCOF"  ,"X3_TITULO"), GetSX3Cache("FT_ALIQCOF" ,"X3_PICTURE"),"0 AS FT_ALIQCOF"};
            ,{"FT_VALCOF"   , TamSX3("FT_VALCOF")   , GetSX3Cache("FT_VALCOF"   ,"X3_TITULO"), GetSX3Cache("FT_VALCOF"  ,"X3_PICTURE"),"0 AS FT_VALCOF" };
            ,{"C5_XOBSVEN"  , TamSX3("C5_XOBSVEN")  , GetSX3Cache("C5_XOBSVEN"  ,"X3_TITULO"), GetSX3Cache("C5_XOBSVEN" ,"X3_PICTURE"),"SC5.C5_XOBSVEN" };
            ,{"C5_XTOTAL"   , TamSX3("C5_XTOTAL")   , GetSX3Cache("C5_XTOTAL"   ,"X3_TITULO"), GetSX3Cache("C5_XTOTAL"  ,"X3_PICTURE"),"SC5.C5_XTOTAL"  }; 
            ,{"C6_TES"      , TamSX3("C6_TES")      , GetSX3Cache("C6_TES"      ,"X3_TITULO"), GetSX3Cache("C6_TES"     ,"X3_PICTURE"),"SC6.C6_TES"     };       
            ,{"C6_ENTREG"   , TamSX3("C6_ENTREG")   , GetSX3Cache("C6_ENTREG"   ,"X3_TITULO"), GetSX3Cache("C6_ENTREG"  ,"X3_PICTURE"),"SC6.C6_ENTREG"  };
            ,{"C6_DATFAT"   , TamSX3("C6_DATFAT")   , "Faturamento"                          , GetSX3Cache("C6_DATFAT"  ,"X3_PICTURE"),"SC6.C6_DATFAT"  };  
            ,{"Z09_BLFDI"   , TamSX3("Z09_BLFDI")   , GetSX3Cache("Z09_BLFDI"   ,"X3_TITULO"), GetSX3Cache("Z09_BLFDI"  ,"X3_PICTURE"),"Z09.Z09_BLFDI"  };
            ,{"Z09_BLFHI"   , TamSX3("Z09_BLFHI")   , GetSX3Cache("Z09_BLFHI"   ,"X3_TITULO"), GetSX3Cache("Z09_BLFHI"  ,"X3_PICTURE"),"Z09.Z09_BLFHI"  };
            ,{"Z09_BLFDF"   , TamSX3("Z09_BLFDF")   , GetSX3Cache("Z09_BLFDF"   ,"X3_TITULO"), GetSX3Cache("Z09_BLFDF"  ,"X3_PICTURE"),"Z09.Z09_BLFDF"  };
            ,{"Z09_BLFHF"   , TamSX3("Z09_BLFHF")   , GetSX3Cache("Z09_BLFHF"   ,"X3_TITULO"), GetSX3Cache("Z09_BLFHF"  ,"X3_PICTURE"),"Z09.Z09_BLFHF"  };         
            ,{"SC5RECNO"    , {18,0,"N"} , "RecNo SC5","@R 999999999999999999","SC5.R_E_C_N_O_ AS SC5RECNO"};
            ,{"SC6RECNO"    , {18,0,"N"} , "RecNo SC6","@R 999999999999999999","SC6.R_E_C_N_O_ AS SC6RECNO"};
            ,{"SB1RECNO"    , {18,0,"N"} , "RecNo SB1","@R 999999999999999999","SB1.R_E_C_N_O_ AS SB1RECNO"};
            ,{"SA1RECNO"    , {18,0,"N"} , "RecNo SA1","@R 999999999999999999","SA1.R_E_C_N_O_ AS SA1RECNO"};
            ,{"SF4RECNO"    , {18,0,"N"} , "RecNo SF4","@R 999999999999999999","SF4.R_E_C_N_O_ AS SF4RECNO"};
        }

Return aFields


//--
Static Function GetQuery(cTipoPedido)
    Local aFields         := GetFields()
    Local cINXBLFIS       := ""
    Local cQueryGetFields := ""
    Local cQueryApto      := ""
    Local cQuerySelect    := ""
    Local nField          := 0
    Local nFields         := 0

    Default cTipoPedido := "4"

    nFields := Len(aFields)
    For nField := 1 To nFields
        //Obtem os Campos para a Query
        cQueryGetFields += aFields[nField][5]
        If (nField<nFields)
            cQueryGetFields += ","
        EndIf
    Next nField

    //Elabora a query dos pedidos
    beginContent var cQuerySelect
        SELECT
            cQueryGetFields
        FROM
            SC5990 SC5
            LEFT JOIN SA1990 SA1 ON SA1.D_E_L_E_T_ = ' '
            AND SA1.A1_FILIAL = '__A1_FILIAL__'
            AND SA1.A1_COD = SC5.C5_CLIENTE
            AND SA1.A1_LOJA = SC5.C5_LOJACLI
            LEFT JOIN SA2990 SA2 ON SA2.D_E_L_E_T_ = ' '
            AND SA2.A2_FILIAL = '__A2_FILIAL__'
            AND SA2.A2_COD = SC5.C5_CLIENTE
            AND SA2.A2_LOJA = SC5.C5_LOJACLI
            JOIN SC6990 SC6 
            ON SC6.D_E_L_E_T_ = ' '
            AND SC6.C6_FILIAL = SC5.C5_FILIAL
            AND SC6.C6_NUM = SC5.C5_NUM
            AND SC6.C6_OPER <> '12'
            JOIN SB1990 SB1 ON SB1.D_E_L_E_T_ = ' '
            AND SB1.B1_FILIAL = '__B1_FILIAL__'
            AND SB1.B1_COD = SC6.C6_PRODUTO
            JOIN SF4990 SF4 
            ON SF4.D_E_L_E_T_ = ' '
            AND SF4.F4_FILIAL = '__F4_FILIAL__'
            AND SF4.F4_CODIGO = SC6.C6_TES
            LEFT JOIN Z09990 Z09 
            ON Z09.D_E_L_E_T_ = ' '
            AND Z09.Z09_FILIAL = SC5.C5_FILIAL
            AND Z09.Z09_NUMPV = SC5.C5_NUM
            AND Z09.Z09_ITEMPV = SC6.C6_ITEM
        WHERE
            SC5.D_E_L_E_T_ = ' '
            AND SC5.C5_FILIAL = '__C5_FILIAL__'
            AND SC5.C5_XBLQINI <> 'S'
            AND SC5.C5_XBLFIS <> 'Z'
            AND SC5.C5_XBLRENT IN ('2', ' ')  
            AND SC5.C5_BLQ = ' ' __XBLFIS
            AND (SELECT COUNT(QTDITSC9) QTDITSC9 FROM (SELECT C9_FILIAL, C9_PEDIDO, C9_ITEM, C9_PRODUTO, COUNT(1) QTDITSC9 FROM SC9990 SC9IT WHERE SC9IT.C9_FILIAL = SC6.C6_FILIAL AND SC9IT.C9_PEDIDO = SC6.C6_NUM  AND SC9IT.D_E_L_E_T_ = ' ' GROUP BY C9_FILIAL, C9_PEDIDO, C9_ITEM, C9_PRODUTO) TRBSC9) =
            (SELECT COUNT(1) QTDITSC6 FROM SC6990 SC6IT WHERE SC6IT.C6_FILIAL = SC6.C6_FILIAL AND SC6IT.C6_NUM = SC6.C6_NUM AND SC6IT.D_E_L_E_T_ = ' ')
    endContent

    //Efetua a Substituicao das constantes por Valores Dinamicos
    cQuerySelect := StrTran(cQuerySelect, "cQueryGetFields"   , cQueryGetFields   )
    cQuerySelect := StrTran(cQuerySelect, "SC5990"            , RetSQLName("SC5") )
    cQuerySelect := StrTran(cQuerySelect, "SC6990"            , RetSQLName("SC6") )
    cQuerySelect := StrTran(cQuerySelect, "SC9990"            , RetSQLName("SC9") )
    cQuerySelect := StrTran(cQuerySelect, "SA1990"            , RetSQLName("SA1") )
    cQuerySelect := StrTran(cQuerySelect, "SA2990"            , RetSQLName("SA2") )
    cQuerySelect := StrTran(cQuerySelect, "SB1990"            , RetSQLName("SB1") )
    cQuerySelect := StrTran(cQuerySelect, "SF4990"            , RetSQLName("SF4") )
    cQuerySelect := StrTran(cQuerySelect, "Z09990"            , RetSQLName("Z09") )
    cQuerySelect := StrTran(cQuerySelect, "__A1_FILIAL__"     , FWXFilial("SA1")  )
    cQuerySelect := StrTran(cQuerySelect, "__A2_FILIAL__"     , FWXFilial("SA2")  )
    cQuerySelect := StrTran(cQuerySelect, "__B1_FILIAL__"     , FWXFilial("SB1")  )
    cQuerySelect := StrTran(cQuerySelect, "__F4_FILIAL__"     , FWXFilial("SF4")  )
    cQuerySelect := StrTran(cQuerySelect, "__C5_FILIAL__"     , FWXFilial("SC5")  )
    cQuerySelect := StrTran(cQuerySelect, "__C6_FILIAL__"     , FWXFilial("SC6")  )
    cQuerySelect := StrTran(cQuerySelect, "__C9_FILIAL__"     , FWXFilial("SC9")  )

    // https://centraldeatendimento.totvs.com/hc/pt-br/articles/
    // 360017467652-Cross-Segmentos-BackOffice-Protheus-SIGAFAT-C%C3%B3digos-de-Bloqueio-gravados-na-tabela/
    //-SC9-dos-Pedidos-de-Venda-Liberados

    // Opção 1: Bloqueados  
    // Serão listados somente os pedidos de vendas que estiverem liberados aptos a faturar, mas que esteja com 
    // bloqueio de “Validação Fiscal”. 
    // Opção 2: Liberados 
    // Serão listados somente os pedidos que já foram liberados anteriormente, independente das regras de aptos a 
    // faturar. 
    // Opção 3: Rejeitados 
    // Serão listados somente os pedidos que já foram rejeitados anteriormente, independente das regras de aptos 
    // a faturar. 
    // Opção 4: Todos 
    // Serão listados todos os pedidos nas seguintes condições: o Pedidos Liberados e Rejeitados serão listados, 
    // independentemente das regras de aptos a faturar; o Pedidos Bloqueados serão listados apenas os pedidos que 
    // estejam de acordo com as regras de aptos a faturar;

    cQueryApto += "  AND EXISTS ("
    cQueryApto += "  SELECT 1"
    cQueryApto += "  FROM " + RetSQLName("SC9") + " SC9"
    cQueryApto += "  WHERE SC9.D_E_L_E_T_ = ' '"
    cQueryApto += "    AND SC9.C9_FILIAL = SC6.C6_FILIAL"
    cQueryApto += "    AND SC9.C9_PEDIDO = SC6.C6_NUM"
    cQueryApto += "    AND SC9.C9_ITEM = SC6.C6_ITEM"
	cQueryApto += "    )"

	cQueryApto += "  AND NOT EXISTS ("
	cQueryApto += "  SELECT 1"
	cQueryApto += "  FROM " + RetSQLName("SC9") + " SC9_BLOQ"
	cQueryApto += "  WHERE SC9_BLOQ.D_E_L_E_T_ = ' '"
	cQueryApto += "    AND SC9_BLOQ.C9_FILIAL = SC6.C6_FILIAL"
	cQueryApto += "    AND SC9_BLOQ.C9_PEDIDO = SC6.C6_NUM"
	cQueryApto += "    AND (SC9_BLOQ.C9_BLEST <> ' ' "
    cQueryApto += "    OR SC9_BLOQ.C9_BLCRED <> ' ')"
    cQueryApto += "    ) "

    DO CASE
        CASE cTipoPedido == '2' .Or. cTipoPedido == '3'
            cINXBLFIS := "AND SC5.C5_XBLFIS = '" + cTipoPedido + "' "
        CASE cTipoPedido == '1'
            cINXBLFIS := "AND SC5.C5_XBLFIS IN (' ','1') "
            cINXBLFIS += cQueryApto
        OTHERWISE
	        cINXBLFIS := "AND (SC5.C5_XBLFIS IN('2','3') OR "
            cINXBLFIS += "(CASE WHEN SC5.C5_XBLFIS IN (' ','1') "
            cINXBLFIS += cQueryApto
            cINXBLFIS += " THEN '0' ELSE '1' END) = '0'"
            cINXBLFIS += ")"
    END CASE

    cQuerySelect := StrTran(cQuerySelect, "__XBLFIS", cINXBLFIS)

Return cQuerySelect

/*/{Protheus.doc} TRK0005Leg
Funcao de Legenda
@type function
@version 1.0
@author wagner.mobile@dothink.com.br
@since 22/07/2025
/*/
Static Function TRK0005Leg

Local aCores := {	{"BR_VERMELHO"  , "Bloqueados"  },;
			        {"BR_VERDE"     , "Liberados"   },;
			        {"BR_CINZA"     , "Rejeitados"  },;
			        {"BR_AZUL"      , "Sem Bloqueio"}}

BrwLegenda("Validaçao Fiscal","Legenda",aCores)

Return

/*/{Protheus.doc} RetFldIdx
Funcao de Criacao de chave de indice
@type function
@version 1.0
@author wagner.mobile@dothink.com.br
@since 22/07/2025
@param cIndice, character, indice
@return array, indices
/*/
Static Function RetFldIdx(cIndice)

Local aIdx    := {}
Local aArea   := SX3->(GetArea())
Local aX3Stru := {}
Local cCpo    := ""

cIndice := AllTrim(cIndice)

If Right(cIndice, 1) <> "+"
	cIndice += "+"
EndIf

SX3->(DbSetOrder(2))

While At("+", cIndice) > 0
	SX3->(DbSeek( Left(AllTrim(Left(cIndice, At("+", cIndice) - 1)) + Space(Len(FieldGet(FieldPos("X3_CAMPO")))), Len(FieldGet(FieldPos("X3_CAMPO"))))  ))
	cCpo:= Left(AllTrim(Left(cIndice, At("+", cIndice) - 1)) + Space(Len(    SX3->(FieldGet(FieldPos("X3_CAMPO")))    )), Len(  SX3->(FieldGet(FieldPos("X3_CAMPO")))   ))

	aX3Stru:= FWSX3Util():GetFieldStruct(cCpo)
	If Len(aX3Stru) > 0 
		Aadd(aIdx, {"", aX3Stru[2], aX3Stru[3], aX3Stru[4], FWX3Titulo(aX3Stru[1]),,})
	Endif 
	cIndice := Subs(cIndice, At("+", cIndice) + 1, Len(cIndice))
EndDo

SX3->(RestArea(aArea))

Return aIdx


/*/{Protheus.doc} TRK0005Fis
Atualizar informações Fiscais
@type function
@version 1.0
@author DoThink
@since 22/07/2025
/*/
static function TRK0005Fis(cAlias)

    local aMaFisNFCabRet as array
    local aRecItens      as array
    local cPedido        as character
    local nAT            as numeric
    local nItem          as numeric
    local nItems         as numeric
    local nNextRecNo     as numeric

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
            //aAdd(aRecItens,(cAlias)->SC6RECNO)
            aAdd(aRecItens,(cAlias)->( Recno() ))
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
                        (cAlias)->FT_ALIQICM:=aMaFisNFCabRet[nAT][4]
                        (cAlias)->FT_VALICM:=aMaFisNFCabRet[nAT][5]
                    endif
                    nAT:=aScan(aMaFisNFCabRet,{|x|Upper(AllTrim(x[1]))=="IPI"})
                    if (nAT>0)
                        (cAlias)->FT_BASEIPI:=aMaFisNFCabRet[nAT][3]
                        (cAlias)->FT_ALIQIPI:=aMaFisNFCabRet[nAT][4]
                        (cAlias)->FT_VALIPI:=aMaFisNFCabRet[nAT][5]
                    endif
                    nAT:=aScan(aMaFisNFCabRet,{|x|Upper(AllTrim(x[1]))=="CF2"})
                    if (nAT>0)
                        (cAlias)->FT_BASEPIS:=aMaFisNFCabRet[nAT][3]
                        (cAlias)->FT_ALIQPIS:=aMaFisNFCabRet[nAT][4]
                        (cAlias)->FT_VALPIS:=aMaFisNFCabRet[nAT][5]
                    endif
                    nAT:=aScan(aMaFisNFCabRet,{|x|Upper(AllTrim(x[1]))=="PS2"})
                    if (nAT>0)
                        (cAlias)->FT_BASECOF:=aMaFisNFCabRet[nAT][3]
                        (cAlias)->FT_ALIQCOF:=aMaFisNFCabRet[nAT][4]
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
@author DoThink
@since 22/07/2025
/*/
static function TRK0005Lib(cTitulo,cAlias,oBrowse)

    local aArea      := FWGetArea()
    local aAreaAlias := (cAlias)->(FWGetArea())
    local cProcTitle := cTitulo+" :: Liberação"
    local cMsgOs     := ""
    local cPedido    := ""
    local cRemessa   := ""
    local cTriangular:= ""
    local lErro      := .F.
    local nRecRemess := 0

    //Verifica se o Item Está Bloqueado
    if ((cAlias)->C5_XBLFIS=="1")
        cPedido := (cAlias)->C5_NUM
        SC5->(MsGoTo((cAlias)->SC5RECNO))
        
        //-- Analise de remessa/triangulacao
        If !ChkRemessa(cAlias, "2", @cPedido, @nRecRemess, @cRemessa, @cTriangular)
            FWRestArea(aAreaAlias)
            FWFreeArray(@aAreaAlias)

            FWRestArea(aArea)
            FWFreeArray(@aArea)                    
            Return
        EndIf
        
        Begintran()            
            GeraOS(cPedido, @cMsgOs)
            
            If At("Ordem de Separacao: N A O  G E R A D A", cMsgOs) > 0
                lErro := .T.
                DisarmTransaction() 
            EndIf
        Endtran()

        If lErro   
            MostraTexto(cMsgOs)
        Else
            SetTraking(cAlias, "2", "", "", "", cTriangular, cRemessa)

            If nRecRemess > 0
                (cAlias)->( DbGoto(nRecRemess) )
                SetTraking(cAlias, "2", "", "", "", cTriangular, cRemessa)
            EndIf
            
            If !Empty(cRemessa)
                SC5->(MsGoTo((cAlias)->SC5RECNO))

                dbSelectArea("CB7")
                CB7->(dbSetOrder(2)) //-- CB7_FILIAL+CB7_PEDIDO+CB7_LOCAL+CB7_STATUS+CB7_CLIENT+CB7_LOJA+CB7_COND+CB7_LOJENT+CB7_AGREG
                If CB7->(dbSeek(xFilial("CB7") + cPedido))  
                    RecLock("CB7", .F.)
                    CB7->CB7_XPVTRI := cRemessa
                    CB7->CB7_XCLIRE := SC5->C5_CLIENTE
                    CB7->CB7_XLJREM := SC5->C5_LOJACLI
                    CB7->( MsUnLock() )
                    
                EndIf 
            EndIf
        EndIf

        oBrowse:Refresh()
    else
        ApMsgInfo("O Pedido não está Bloqueado. Só é possível Liberar Pedidos Bloqueados.",cProcTitle)
    endif

    FWRestArea(aAreaAlias)
    FWFreeArray(@aAreaAlias)

    FWRestArea(aArea)
    FWFreeArray(@aArea)

return

/*/{Protheus.doc} TRK0005Rej
Processa a Rejeição
@type function
@version 1.0
@author DoThink
@since 22/07/2025
/*/
static function TRK0005Rej(cTitulo,cAlias,oBrowse)

    local aArea      := FWGetArea()
    local aAreaAlias := (cAlias)->(FWGetArea())
    local cPedido    := ""  as character
    local cRemessa   := ""  as character
    local cTriangular:= ""  as character
    local cRejCod    := ""  as character
    local cRejObs    := ""  as character
    local cProcTitle := cTitulo+" :: Rejeição"
    local nRecRemess := 0   as numeric
    local nRejSiz    := 6   as numeric
    local nDesSiz    := 150 as numeric
    local lRet       := .F. as logical
    local oOk               as object
    local oDlg              as object
    local oPanel            as object
    local oCancel           as object
    local oCodRej           as object
    local oRejObs           as object

    private cDescMotivo     := Space(nDesSiz)
    private oDecMot         as object
    
    cRejCod := Space(Min(GetSX3Cache("X5_CHAVE","X3_TAMANHO"),nRejSiz))
    cRejObs := Space(50)

    //Verifica se o Item Está Bloqueado

    if ((cAlias)->C5_XBLFIS=="1")

        SC5->(MsGoTo((cAlias)->SC5RECNO))

        //-- Analise de remessa/triangulacao
        If !ChkRemessa(cAlias, "3", @cPedido, @nRecRemess, @cRemessa, @cTriangular)
            FWRestArea(aAreaAlias)
            FWFreeArray(@aAreaAlias)

            FWRestArea(aArea)
            FWFreeArray(@aArea)                    
            Return
        EndIf  


        DEFINE MSDIALOG oDlg FROM 0,0 TO 310,450 TITLE cProcTitle PIXEL OF GetWNDDefault()

            @ 000,000 MSPANEL oPanel OF oDlg
            oPanel:Align:=CONTROL_ALIGN_ALLCLIENT

            @ 007,005 SAY "Código Rejeição:" SIZE 45,08 OF oPanel PIXEL
            @ 005,048 MSGET oCodRej VAR cRejCod SIZE CalcFieldSize("C",nRejSiz,0,"@!",Replicate("W",nRejSiz)),08 OF oPanel PIXEL F3 "Z0" VALID CodRejVld(@cRejCod,nRejSiz,@oCodRej)
            @ 018,005 SAY "Descrição:" SIZE 45,08 OF oPanel PIXEL
            @ 016,048 MSGET oDecMot VAR cDescMotivo SIZE 150,08 OF oPanel PIXEL WHEN .F.

            @028,005 SAY "Observação" SIZE 60,07 OF oPanel PIXEL
            @036,005 GET oRejObs VAR cRejObs MEMO SIZE 220,097 CENTERED DESIGN OF oPanel PIXEL WHEN (.T.)

            DEFINE SBUTTON oOk     FROM 140,(220-48) TYPE 1 ENABLE OF oPanel PIXEL ACTION (If(VCloseDlgR(cRejCod, cRejObs, cProcTitle), (lRet:=.T.,oDlg:End()), nil))
            DEFINE SBUTTON oCancel FROM 140,(220-20) Type 2 ENABLE OF oPanel PIXEL ACTION oDlg:End()

            oRejObs:lReadOnly:=.F.
            oRejObs:EnableVScroll(.T.)
            oRejObs:EnableHScroll(.T.)

            oDlg:lEscClose:=.F.

        ACTIVATE MSDIALOG oDlg CENTER ON INIT (oDlg:SetFocus())

        if (lRet)
            SetTraking(cAlias, "3", cRejCod, FWGetSX5( "Z0", cRejCod)[1][4], cRejObs)

            If nRecRemess > 0
                (cAlias)->( DbGoto(nRecRemess) )
                SetTraking(cAlias, "3", cRejCod, FWGetSX5( "Z0", cRejCod)[1][4], cRejObs)
            EndIf

        endif
        oBrowse:Refresh()
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

return()

/*/{Protheus.doc} CodRejVld
Valida e Normaliza o Codigo de Rejeição.
@type function
@version 1.0
@author DoThink
@since 22/07/2025
/*/
static function CodRejVld(cRejCod as character,nRejSiz as numeric,oCodRej as object) as logical
    local lRet     := .F.
    local aContent := {}

    cRejCod := PadL(AllTrim(cRejCod),nRejSiz,"0")
    oCodRej:Refresh()
    
    cDescMotivo := Space(150)

    lRet := ExistCpo("SX5","Z0"+cRejCod,1)
    If lRet
        aContent := FWGetSX5( "Z0", cRejCod )
        If Len(aContent) > 0
            cDescMotivo:= aContent[1][4]
        EndIf     
    EndIf

    oDecMot:Refresh()   
return(lRet)

static function VCloseDlgR(cRejCod, cRejObs, cProcTitle)
    local lRet := .T.

    If Empty(cRejCod)
        lRet := .F.
    EndIf

    If Empty(cRejObs)
        lRet := .F.
    EndIf

    If !lRet
        ApMsgInfo("São obrigatórios o preechimento dos campos [código da rejeição] e [Observação].",cProcTitle)
    EndIf

return lRet

/*/{Protheus.doc} TRK0005Blq
Processa o Bloqueio
@type function
@version 1.0
@author DoThink
@since 22/07/2025
/*/
static function TRK0005Blq(cTitulo,cAlias,oBrowse)

    local aArea      := FWGetArea()
    local aAreaAlias := (cAlias)->(FWGetArea())
    local cProcTitle := cTitulo+" :: Bloqueio"
    local cPedido    := ""
    local cMsgOs     := ""
    local nRecRemess := 0
    local cRemessa   := ""
    local cTriangular:= ""
    local lContinua  := .T.

    //Verifica se o Item Está Bloqueado
    if (cAlias)->C5_XBLFIS!="1"
        cPedido := (cAlias)->C5_NUM
        SC5->(MsGoTo((cAlias)->SC5RECNO))

        //-- Analise de remessa/triangulacao
        If !ChkRemessa(cAlias, "1", @cPedido, @nRecRemess, @cRemessa, @cTriangular)
            FWRestArea(aAreaAlias)
            FWFreeArray(@aAreaAlias)

            FWRestArea(aArea)
            FWFreeArray(@aArea)                    
            Return
        EndIf        

        dbSelectArea("CB7")
        CB7->(dbSetOrder(2)) //-- CB7_FILIAL+CB7_PEDIDO+CB7_LOCAL+CB7_STATUS+CB7_CLIENT+CB7_LOJA+CB7_COND+CB7_LOJENT+CB7_AGREG
        If CB7->(dbSeek(xFilial("CB7") + cPedido))
            lContinua :=  CB7->CB7_XSTATU == '0'
        EndIf

        If lContinua
            Begintran()            
                SetTraking(cAlias, "1", "", "", "")
                EstornaOS(cPedido, @cMsgOs)

                If nRecRemess > 0
                    (cAlias)->( DbGoto(nRecRemess) )
                    SetTraking(cAlias, "1", "", "", "")
                EndIf
            Endtran()
        Else
            FWAlertHelp("A validação física para o pedido ["+cPedido+"] já foi iniciado ou já esta finalizada.", "Faça os estornos para poder realizar o bloqueio.")
        EndIf   
     
        oBrowse:Refresh()
    else
        ApMsgInfo("O Pedido já se encontra Bloqueado. Só é possível Bloquear Pedidos não Bloqueados.",cProcTitle)
    endif

    FWRestArea(aAreaAlias)
    FWFreeArray(@aAreaAlias)

    FWRestArea(aArea)
    FWFreeArray(@aArea)

return()

/*/{Protheus.doc} u_TRK005Fld
Retorna informação Customizada para o Campo
@type function
@version 1.0
@author DoThink
@since 22/07/2025
/*/
function u_TRK005Fld(cField as character,xValue)
    local xRet as variable
    local nAT as numeric
    if (cField=="C5_XBLFIS")
        nAT:=aScan(aTiposDePedidos,{|x|Left(x,1)==xValue})
        if (nAT>0)
            xRet:=aTiposDePedidos[nAT]
        endif
    endif
return(xRet)



Static Function TRK0005VPV(cAlias)
    local aArea     := FWGetArea()
    local aAreaAlias:=(cAlias)->(FWGetArea())
  
    //Tenta posicionar no pedido
    DbSelectArea("SC5")
    SC5->(DbSetOrder(1)) // C5_FILIAL + C5_NUM
    If SC5->( MsSeek(FWxFilial("SC5") + (cAlias)->C5_NUM) )
     
        //Se já tiver nota
        If ! Empty(SC5->C5_NOTA)
            FWAlertError("Pedido já faturado!", "Atenção")
 
        //Senão, aciona a alteração do pedido
        Else
            INCLUI := .F.
            ALTERA := .F.
            MATA410(Nil, Nil, Nil, Nil, "A410Visual")
        EndIf
    EndIf
    
    FWRestArea(aAreaAlias)
    FWFreeArray(@aAreaAlias)

    FWRestArea(aArea)
    FWFreeArray(@aArea)

Return


static function AtuTracking(cAliasVldFis, aDadosFil) 
    local cRespon   := ""
    local cNTransp  := ""
    local cNTRedesp := ""
    local cChave    := ""
    local aArea     := GetArea()    
    local aTrackS   := {}
    local aX5T3     := {}

    DbSelectAre("Z09")
    Z09->( DbSetOrder(3) )
    aTrackS := Array( Len( Z09->( DbStruct() ) ) )

    (cAliasVldFis)->(dbGoTop())
    (cAliasVldFis)->(dbSetOrder(1))
    while ((cAliasVldFis)->( !eof() ))
        cChave    := (cAliasVldFis)->( C5_NUM + C6_ITEM)

        If !Z09->( DbSeek(xFilial() + cChave ) ) //Empty( (cAliasVldFis)->C5_XBLFIS )
            //-- Atualiza temporario
            RecLock(cAliasVldFis, .F.)
                (cAliasVldFis)->C5_XBLFIS := "1"
            (cAliasVldFis)->( MsUnLock() )

            SC5->( MsGoto( (cAliasVldFis)->SC5RECNO ) )
            SC6->( MsGoto( (cAliasVldFis)->SC6RECNO ) )
            SA1->( MsGoto( (cAliasVldFis)->SA1RECNO ) )

            RecLock("SC5", .F.)
            SC5->C5_XBLFIS := "1" //-- Bloqueado
            SC5->C5_X4SSTAT:= "9" //-- Em Validacao Fiscal
            SC5->( MsUnLock() )            

            cRespon := Trim(Posicione("SA3", 1, xFilial("SA3") + SC5->C5_VEND1  , "A3_NOME"))
            cNTransp:= Trim(Posicione("SA4", 1, xFilial("SA4") + SC5->C5_TRANSP , "A4_NOME"))

            If !Empty(SC5->C5_REDESP)
                cNTRedesp := Trim(Posicione("SA4", 1, xFilial("SA4") + SC5->C5_REDESP , "A4_NOME"))
            EndIf

        	//-- Define o BU
	        aX5T3 := FWGetSX5 ( "T3", SC5->C5_XATIVI1)
            
            // Alimentacao das variaveis para gravacao
            DbSelectAre("Z09")
            aTrackS[FieldPos("Z09_FILIAL")]  := xFilial("SC5")	            // Filial
            If !Empty(aX5T3)
                aTrackS[FieldPos("Z09_BU")]  := aX5T3[1][4]                 //Unidade de Negocio
            EndIf
            aTrackS[FieldPos("Z09_RESPON")] := cRespon                      // Reponsavel    C [30 ][ 0 ] 04        
            aTrackS[FieldPos("Z09_NUMPV") ] := (cAliasVldFis)->C5_NUM       // Pedido Venda  C [ 6 ][ 0 ] 05
            aTrackS[FieldPos("Z09_ITEMPV")] := (cAliasVldFis)->C6_ITEM      // Item PV       C [ 2 ][ 0 ] 06
            aTrackS[FieldPos("Z09_CLIENT")] := (cAliasVldFis)->C5_CLIENTE   // Cliente       C [ 6 ][ 0 ] 15
            aTrackS[FieldPos("Z09_LOJA")  ] := (cAliasVldFis)->C5_LOJACLI   // Loja Cliente  C [ 2 ][ 0 ] 16
            aTrackS[FieldPos("Z09_NOMECL")] := (cAliasVldFis)->A1_NOME      // Nome Cliente ou fornecedor  C [60 ][ 0 ] 17
            aTrackS[FieldPos("Z09_TOTAL") ] := If(Empty((cAliasVldFis)->C5_XTOTAL),GetTotPV((cAliasVldFis)->C5_NUM),(cAliasVldFis)->C5_XTOTAL)    // Vlr. Total    N [16 ][ 2 ] 18
            aTrackS[FieldPos("Z09_DTEMPV")] := SC5->C5_EMISSAO              // Emissao PV    D [ 8 ][ 0 ] 07
            aTrackS[FieldPos("Z09_HREMPV")] := Time()                       // Hr.Emiss.PV   C [ 5 ][ 0 ] 08
            aTrackS[FieldPos("Z09_STATUS")] := "2"                          // Em Validação Fiscal
            aTrackS[FieldPos("Z09_BLFIS") ] := (cAliasVldFis)->C5_XBLFIS    // Nasce como Bloqueado    
            aTrackS[FieldPos("Z09_ARMAZ") ] := SC6->C6_LOCAL                // Armazem
            aTrackS[FieldPos("Z09_ICOTER")] := SC5->C5_TPFRETE              // Icoterm  
            aTrackS[FieldPos("Z09_TRANSP")] := SC5->C5_TRANSP               // Transportadora
            aTrackS[FieldPos("Z09_NTRANS")] := cNTransp                     // Nome da Transportadora
            aTrackS[FieldPos("Z09_REDICO")] := SC5->C5_TFRDP1               // Icoterm Redespacho 
            aTrackS[FieldPos("Z09_REDESP")] := SC5->C5_REDESP               // Transportadora Redespacho
            aTrackS[FieldPos("Z09_NREDES")] := cNTRedesp                    // Nome da Transportadora            
            aTrackS[FieldPos("Z09_DPEMPV")] := SC6->C6_ENTREG               // Previsao de Entrega PV
            aTrackS[FieldPos("Z09_DPFAPV")] := SC6->C6_DATFAT               // Previsao Faturamento PV 
            aTrackS[FieldPos("Z09_RESTR")]  := SC5->C5_XRESTR               // Restricao do Cliente 
            aTrackS[FieldPos("Z09_OBSPV")]  := SC5->C5_XOBSVEN              // Restricao do Cliente 
            aTrackS[FieldPos("Z09_BLFDI")]  := Date()                       // Dt.Inicio Bloq.Fiscal    
            aTrackS[FieldPos("Z09_BLFHI")]  := Time()                       // Hr.Inicio Bloq.Fiscal 
            aTrackS[FieldPos("Z09_DTSLA")]  := u_TRK0017S(aDadosFil[6], SA1->A1_EST, SA1->A1_COD_MUN, SC6->C6_ENTREG)

            If Z09->(FieldPos("Z09_PROD") > 0)
                aTrackS[FieldPos("Z09_PROD")] := SC6->C6_PRODUTO
            EndIf

            If Z09->(FieldPos("Z09_QTDPV") > 0)
                aTrackS[FieldPos("Z09_QTDPV")] := SC6->C6_QTDVEN
            EndIf

            If Z09->(FieldPos("Z09_LOTECT") > 0)
                aTrackS[FieldPos("Z09_LOTECT")] := SC6->C6_LOTECTL
            EndIf

            u_TRK006S(aTrackS,"Em Validacao Fiscal")

        EndIf

        (cAliasVldFis)->( DbSkip() )
    enddo
    
    RestArea(aArea)
return

Static Function SetTraking(cAlias, cOpc, cMotivo, cDescMotivo, cObsMotivo, cTriangular, cRemessa)
    local aArea         := GetArea()
    local aTrackS       := {}
    local nRecPos       := (cAlias)->( Recno() )
    local cChave        := (cAlias)->C5_NUM
    local cAcao         := If(cOpc=="2","Liberacao", If(cOpc=="3","Rejeicao", "Bloqueio"))
    default cMotivo     := ""
    default cDescMotivo := ""
    default cObsMotivo  := ""
    default cTriangular := ""
    default cRemessa    := ""

    SC5->(MsGoTo((cAlias)->SC5RECNO))

    if (SC5->C5_XBLFIS!= cOpc)
        if ( SC5->( RecLock("SC5",.F.) ) )
            SC5->C5_XBLFIS:= cOpc 
            
            If cOpc == "2"
                SC5->C5_X4SSTAT := "A" // Em Validacao Fisica
            Else
                SC5->C5_X4SSTAT := "9" // Em Validacao Fiscal
            EndIf

            //Grava o campo C5_MSEXP para sinalizaro ao Scheduler
            SC5->C5_MSEXP:=   ""  //DToS(dDataBase)
            SC5->(MsUnLock())
        endif
    endif

    DbSelectAre("Z09")
    aTrackS := Array( Len( Z09->( DbStruct() ) ) )

    //Atualiza, também, no alias temporário para atualização do status
    (cAlias)->( DbSetOrder(1) )
    (cAlias)->( DbSeek( cChave ) )
    While (cAlias)->( !Eof() .And. C5_NUM == cChave)
        if ((cAlias)->( RecLock(cAlias,.F.) ))
            (cAlias)->C5_XBLFIS := SC5->C5_XBLFIS
            (cAlias)->Z09_BLFDF := If(cOpc=="1", CtoD("")   , Date() )
            (cAlias)->Z09_BLFHF := If(cOpc=="1", ""         , Time() )
            (cAlias)->(MsUnLock())
        endif

        aTrackS[Z09->(FieldPos("Z09_FILIAL"))]  := xFilial("SC5")
        aTrackS[Z09->(FieldPos("Z09_NUMPV")) ]  := (cAlias)->C5_NUM                     // Pedido Venda
        aTrackS[Z09->(FieldPos("Z09_ITEMPV"))]  := (cAlias)->C6_ITEM                    // Item PV
        aTrackS[Z09->(FieldPos("Z09_STATUS"))]  := If((cAlias)->C5_XBLFIS=="2","3", "2")// Status
        aTrackS[Z09->(FieldPos("Z09_BLFIS")) ]  := (cAlias)->C5_XBLFIS                  // Resultado da Validacao Fiscal
        aTrackS[Z09->(FieldPos("Z09_CMTBLF"))]  := cMotivo                              // Motivo da Rejeicao
        aTrackS[Z09->(FieldPos("Z09_DMTBLF"))]  := cDescMotivo                          // Descricao da Rejeicao
        aTrackS[Z09->(FieldPos("Z09_OMTBLF"))]  := cObsMotivo                           // Observacao da Rejeicao
        aTrackS[Z09->(FieldPos("Z09_UBLFIS"))]  := cUserName                            // Usuario da Validacao
        aTrackS[Z09->(FieldPos("Z09_BLFDF")) ]  := (cAlias)->Z09_BLFDF                  // Dt.Finalizacao Bloq.Fiscal    
        aTrackS[Z09->(FieldPos("Z09_BLFHF")) ]  := (cAlias)->Z09_BLFHF                  // Hr.Finalizacao Bloq.Fiscal    
        If !Empty(cTriangular)     
            aTrackS[Z09->(FieldPos("Z09_PVTRIA"))]  := cTriangular                      // PV Triangular
        EndIf
        If !Empty(cRemessa)
            aTrackS[Z09->(FieldPos("Z09_PVREME")) ] := cRemessa                         // Hr.Finalizacao Bloq.Fiscal  
        EndIf           
        
        u_TRK006S(aTrackS, "Em Validacao Fiscal (" + cAcao + ")")

        (cAlias)->( DbSkip() )
    End
    
    (cAlias)->( DbGoto(nRecPos) )
       
    RestArea(aArea)
Return



Static Function GeraOS(cPV, cMsg)
    Local lAuto   := .T.
    Local aParams := {}
    Local nZ      := 0
    Default cMsg  := ""

    Private aFileLog := {}

    //-- Parametros do pergunte: "AIA102"
    aAdd(aParams, {"MV_PAR01",           "      "}) //-- Separador
    aAdd(aParams, {"MV_PAR02",                cPV}) //-- Pedido de
    aAdd(aParams, {"MV_PAR03",                cPV}) //-- Pedido ate
    aAdd(aParams, {"MV_PAR04",           "      "}) //-- Cliente de
    aAdd(aParams, {"MV_PAR05",               "  "}) //-- Loja Cliente de
    aAdd(aParams, {"MV_PAR06",           "ZZZZZZ"}) //-- Cliente ate
    aAdd(aParams, {"MV_PAR07",               "ZZ"}) //-- Loja Cliente ate
    aAdd(aParams, {"MV_PAR08", CTOD("01/01/2025")}) //-- Data Liberacao de
    aAdd(aParams, {"MV_PAR09", CTOD("31/12/2049")}) //-- Data Liberacao ate
    aAdd(aParams, {"MV_PAR10",                  2}) //-- Pre-Separacao / Sim/Nao
    
    U_GRACDA100(,,, lAuto, aParams)

    VarInfo("Gerar OS automaticamente", aFileLog)

    //-- Percorre todas as linhas do log
    For nZ := 1 To Len(aFileLog)
        cMsg += aFileLog[nZ] + CRLF
    Next

Return




/*/{Protheus.doc} EstornaOS
Estorna Ordem de Separacao
@type function
@version 1.0
@author erike.yuri@dothink.com.br
@since 8/14/2025
@return logical, Resultado do estorno
/*/
Static Function EstornaOS(cPedido, cMsg)
    Local lRet       := .T.
    Local lAuto      := .T.
    Local nZ         := 0
    Local aArea      := GetArea() 
    Default cMsg     := ""

    Private aRecno   := {}
    Private aFileLog := {}
    Private nOSOpc   := 1

    If Empty(cPedido)
        FWAlertError("Pedido não informado", "Erro Estorno OS")
        Return .F.
    EndIf

    dbSelectArea("CB7")
    CB7->(dbSetOrder(2)) //-- CB7_FILIAL+CB7_PEDIDO+CB7_LOCAL+CB7_STATUS+CB7_CLIENT+CB7_LOJA+CB7_COND+CB7_LOJENT+CB7_AGREG
    If CB7->(dbSeek(xFilial("CB7") + cPedido))

        //-- Dever estar posicionado no RECNO da CB7 que se deseja estornar
        U_ETACDA100(,,, lAuto)

        VarInfo("Estornar OS automaticamente", aFileLog)

        //-- Percorre todas as linhas do log
        For nZ := 1 To Len(aFileLog)
            cMsg += aFileLog[nZ] + CRLF
        Next
    EndIf

    RestArea(aArea)

Return lRet





/*/{Protheus.doc} MostraTexto
Visualizador de erro
@type function
@version 20250726 
@author erike
@since 8/26/2025
@param cTextoLog, character, Log que sera exibido
/*/
Static Function MostraTexto(cTextoLog)
    local oDlgMTexto
    Local cMemo    := ""
    Local oFont

    If !Empty(cTextoLog)
        cMemo := cTextoLog
    EndIf

	DEFINE FONT oFont NAME "Courier New" SIZE 5,0   //6,15

	DEFINE MSDIALOG oDlgMTexto TITLE "Erro na Criação da Validação Física" From 3,0 to 340,417 PIXEL

	@ 5,5 GET oMemo  VAR cMemo MEMO SIZE 200,145 OF oDlgMTexto PIXEL
	oMemo:bRClicked := {||AllwaysTrue()}
	oMemo:oFont:=oFont

	DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlgMTexto:End() ENABLE OF oDlgMTexto PIXEL //Apaga
	DEFINE SBUTTON  FROM 153,145 TYPE 13 ACTION (fSalvar(cMemo),oDlgMTexto:End()) ENABLE OF oDlgMTexto PIXEL 
	
	ACTIVATE MSDIALOG oDlgMTexto CENTER
Return 
 
Static Function fSalvar(cTexto)
    Local cTipArq := "Arquivos texto (*.txt) | Arquivos de log (*.log)"
    Local cTitulo := "Gravação de arquivo"
    Local cDirIni := GetTempPath()
    Local lSalvar := .T.
    Local cArqSel := ""
 
    //Aciona a tela para gravar o arquivo
    cArqSel := tFileDialog(;
        cTipArq,;  // Filtragem de tipos de arquivos que serão selecionados
        cTitulo,;  // Título da Janela para seleção dos arquivos
        ,;         // Compatibilidade
        cDirIni,;  // Diretório inicial da busca de arquivos
        lSalvar,;  // Se for .T., será uma Save Dialog, senão será Open Dialog
        ;          // Se não passar parâmetro, irá pegar apenas 1 arquivo; Se for informado GETF_MULTISELECT será possível pegar mais de 1 arquivo; Se for informado GETF_RETDIRECTORY será possível selecionar o diretório
    )
 
    //Efetua a gravação do arquivo
    If ! Empty(cArqSel)
        MemoWrite(cArqSel, cTexto)
    EndIf
Return
 
Static Function fCopiar(cTexto)
    //Copia o texto para a área de transferência em memória (similar a selecionar tudo e apertar Ctrl+C)
    CopyToClipBoard(cTexto)
    FWAlertSuccess("Texto copiado para área de transferência, agora basta você usar o atalho Ctrl+V para colar onde você deseja.", "Sucesso")
Return



Static Function ChkRemessa(cAlias, cOpc, cPedido, nRecRemess, cRemessa, cTriangular)
local cMsg        := ""
local nRecTriang  := 0
local lRet        := .T.

DO CASE
    CASE cOpc == "1"
        cMsg := "Você deseja bloquear os dois pedidos?" + CRLF + CRLF +"<strong>Se estiver tudo certo, deseja prosseguir com bloqueio?</strong>
    CASE cOpc == "2"
        cMsg := "Você já analisou os dois pedidos?" + CRLF + CRLF +"<strong>Se estiver tudo certo, deseja prosseguir com a liberação?</strong>
    CASE cOpc == "3"
        cMsg := "Você já analisou os dois pedidos?" + CRLF + CRLF +"<strong>Se estiver tudo certo, deseja prosseguir com a rejeição?</strong>
END CASE

//-- Verificar se é operacao remessa
If !Empty(SC5->C5_XPEDORI)
    nRecRemess  := (cAlias)->( RecNo() )
    cRemessa    := SC5->C5_NUM 
    cTriangular := MpSysExecScalar("SELECT C5_NUM AS PEDIDO FROM " + RetSQLName("SC5") + " SC5 WHERE SC5.C5_FILIAL = '" + xFilial("SC5") + "' AND SC5.D_E_L_E_T_= ' ' AND C5_XPEDWEB = '"+SC5->C5_XPEDORI+"'", "PEDIDO")
    If !Empty(cTriangular)
        If !FwAlertYesNo("O pedido ["+SC5->C5_NUM +"] é um pedido remessa do pedido triangular ["+cTriangular+"]. " + cMsg , "Pedido Remessa")               
            Return .F.
        EndIf

        (cAlias)->( DbSetOrder(1) )
        If !(cAlias)->( DbSeek(cTriangular) )
            FWAlertWarning("Pedido de triangular ["+cTriangular+"], não localizado. Verifique se o mesmo não esta com algum bloqueio.", "Pedido Triangular")                
            Return .F.
        EndIf

        cPedido := cTriangular
    EndIf
ElseIf !Empty(SC5->C5_XPEDWEB)
    cRemessa := MpSysExecScalar("SELECT Coalesce(C5_NUM, '"+Space(TamSX3('C5_NUM')[1])+"') AS PEDIDO FROM " + RetSQLName("SC5") + " SC5 WHERE SC5.C5_FILIAL = '" + xFilial("SC5") + "' AND SC5.D_E_L_E_T_= ' ' AND C5_XPEDORI = '"+SC5->C5_XPEDWEB+"'", "PEDIDO")
    If !Empty(cRemessa)
        cTriangular := SC5->C5_NUM 
        nRecTriang  := (cAlias)->( RecNo() )
        If !FwAlertYesNo("O pedido [" + SC5->C5_NUM +"] é um pedido triangular do pedido remessa ["+cRemessa+"]. " + cMsg , "Pedido Triangular")               
            Return .F.
        EndIf

        (cAlias)->( DbSetOrder(1) )
        If !(cAlias)->( DbSeek(cRemessa) )
            FWAlertWarning("Pedido de remessa ["+cRemessa+"], não localizado. Verifique se o mesmo não esta com algum bloqueio.", "Pedido Remessa")                
            Return .F.
        EndIf
        nRecRemess  := (cAlias)->( RecNo() )
        (cAlias)->( DbGoto(nRecTriang) )
        
    EndIf
EndIf

Return lRet

/*/{Protheus.doc} GetTotPV
Função que retorna o valor total do pedido com os impostos
@author Atilio
@since 25/08/2016
@version undefined
@param cNumPed, characters, Número do Pedido
@type function
/*/
    
Static Function GetTotPV(cNumPed)
    Local aArea     := GetArea()
    Local aAreaC5   := SC5->(GetArea())
    Local aAreaB1   := SC6->(GetArea())
    Local aAreaC6   := SB1->(GetArea())
    Local cQryIte   := ""
    Local nValPed   := 0
    Local nNritem   := 0
    Local nTotFrete := 0
    Local nTotNF    := 0
    Local nTotIPI   := 0
    Local nTotISS   := 0

    Default cNumPed := SC5->C5_NUM

    //Seleciona agora os itens do pedido
    cQryIte := " SELECT "
    cQryIte += "    C6_ITEM, "
    cQryIte += "    C6_PRODUTO "
    cQryIte += " FROM "
    cQryIte += "    "+RetSQLName('SC6')+" SC6 "
    cQryIte += "    LEFT JOIN "+RetSQLName('SB1')+" SB1 ON ( "
    cQryIte += "        B1_FILIAL = '"+FWxFilial('SB1')+"' "
    cQryIte += "        AND B1_COD = SC6.C6_PRODUTO "
    cQryIte += "        AND SB1.D_E_L_E_T_ = ' ' "
    cQryIte += "    ) "
    cQryIte += " WHERE "
    cQryIte += "    C6_FILIAL = '"+FWxFilial('SC6')+"' "
    cQryIte += "    AND C6_NUM = '"+cNumPed+"' "
    cQryIte += "    AND SC6.D_E_L_E_T_ = ' ' "
    cQryIte += " ORDER BY "
    cQryIte += "    C6_ITEM "
    cQryIte := ChangeQuery(cQryIte)
    TCQuery cQryIte New Alias "QRY_ITE"
    
    MaFisEnd() 
    DbSelectArea('SC5')
    SC5->(DbSetOrder(1))
    SC5->(DbSeek(FWxFilial('SC5') + cNumPed))
    MaFisIni(SC5->C5_CLIENTE,;                      // 1-Codigo Cliente/Fornecedor
        SC5->C5_LOJACLI,;                           // 2-Loja do Cliente/Fornecedor
        If(SC5->C5_TIPO$'DB',"F","C"),;             // 3-C:Cliente , F:Fornecedor
        SC5->C5_TIPO,;                              // 4-Tipo da NF
        SC5->C5_TIPOCLI,;                           // 5-Tipo do Cliente/Fornecedor
        MaFisRelImp("MT100",{"SF2","SD2"}),;        // 6-Relacao de Impostos que suportados no arquivo
        ,;                                          // 7-Tipo de complemento
        ,;                                          // 8-Permite Incluir Impostos no Rodape .T./.F.
        "SB1",;                                     // 9-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
        "MATA461")                                  // 10-Nome da rotina que esta utilizando a funcao
        
    //Pega o total de itens
    QRY_ITE->(DbGoTop())
    While ! QRY_ITE->(EoF())
        nNritem++
        QRY_ITE->(DbSkip())
    EndDo
        
    //Preenchendo o valor total
    QRY_ITE->(DbGoTop())
    nTotIPI := 0
    While ! QRY_ITE->(EoF())
        //Pega os tratamentos de impostos
        SB1->(DbSeek(FWxFilial("SB1")+QRY_ITE->C6_PRODUTO))
        SC6->(DbSeek(FWxFilial("SC6")+cNumPed+QRY_ITE->C6_ITEM))
            
        MaFisAdd(   SC6->C6_PRODUTO,;               // 1-Codigo do Produto                 ( Obrigatorio )
                    SC6->C6_TES,;                   // 2-Codigo do TES                     ( Opcional )
                    SC6->C6_QTDVEN,;                // 3-Quantidade                     ( Obrigatorio )
                    SC6->C6_PRCVEN,;                // 4-Preco Unitario                 ( Obrigatorio )
                    SC6->C6_VALDESC,;               // 5 desconto
                    SC6->C6_NFORI,;                 // 6-Numero da NF Original             ( Devolucao/Benef )
                    SC6->C6_SERIORI,;               // 7-Serie da NF Original             ( Devolucao/Benef )
                    0,;                             // 8-RecNo da NF Original no arq SD1/SD2
                    SC5->C5_FRETE/nNritem,;         // 9-Valor do Frete do Item         ( Opcional )
                    SC5->C5_DESPESA/nNritem,;       // 10-Valor da Despesa do item         ( Opcional )
                    SC5->C5_SEGURO/nNritem,;        // 11-Valor do Seguro do item         ( Opcional )
                    0,;                             // 12-Valor do Frete Autonomo         ( Opcional )
                    SC6->C6_VALOR,;                 // 13-Valor da Mercadoria             ( Obrigatorio )
                    0,;                             // 14-Valor da Embalagem             ( Opcional )
                    0,;                             // 15-RecNo do SB1
                    0)                              // 16-RecNo do SF4
            
        //nItem++
        QRY_ITE->(DbSkip())
    EndDo
        
    //Pegando totais
    nTotIPI   := MaFisRet(,'NF_VALIPI')
    nTotICM   := MaFisRet(,'NF_VALICM')
    nTotNF    := MaFisRet(,'NF_TOTAL')
    //nTotFrete := MaFisRet(,'NF_FRETE')
    nTotISS   := MaFisRet(,'NF_VALISS')
        
    QRY_ITE->(DbCloseArea())
    MaFisEnd()        
    
    //Atualiza o retorno
    nValPed := nTotNF + nTotIPI + nTotFrete + nTotISS
        
    RestArea(aAreaC6)
    RestArea(aAreaB1)
    RestArea(aAreaC5)
    RestArea(aArea)
Return nValPed


User Function TRK0005A(cNumPed)
Return GetTotPV(cNumPed)

User Function TRK0005Z()
local nCount := 0

FWMsgRun(NIL, {|| ProcTotal(@nCount) }, "Aguarde...", "Atualizando Total")

FWAlertSuccess("Processou "+cValToChar(nCount), "Fim Processamento")
Return

Static Function ProcTotal(nCount)
    default nCount := 0
    DbSelectArea("Z09")
    Z09->( DbSetOrder(1) )
    Z09->( DbSeek(FwFilial()) )
    While Z09->( !Eof() .And. Z09_FILIAL == FwFilial())
        If Empty(Z09->Z09_TOTAL)
            RecLock("Z09", .F.)
                Z09->Z09_TOTAL := GetTotPV(Z09->Z09_NUMPV)
            Z09->( MsUnLock() )
            nCount++
        EndIf

        Z09->( DbSkip() )
    End
Return


//-- Rotina de atualizacao dos status dos pedidos
User Function TRKVLFIS()

    Processa({|| AtuStatus()}, "Aguarde...", "Atualizando status...")

Return


//--
Static Function AtuStatus()
    Local aAreaAnt := GetArea()
    Local aAreaSC5 := SC5->(GetArea())
    Local aAreaSC6 := SC6->(GetArea())
    Local cQuery   := GetQuery("1")
    Local cUpDate  := ""
    Local nTotal   := 0
    Local nAtual   := 0

	dbSelectArea("SC5")
	SC5->(dbSetOrder(1))

	dbSelectArea("SC6")
	SC6->(dbSetOrder(1))

    dbSelectArea("Z09")
    Z09->( dbSetOrder(3) )

    If Select("_QRYFIS") > 0
        _QRYFIS->(dbCloseArea())
    EndIf

    cQuery := ChangeQuery(cQuery)
    TCQUERY cQuery New Alias "_QRYFIS"

    //-- Conta quantos registros existem, e seta no tamanho da regua
    Count To nTotal
    ProcRegua(nTotal)

    _QRYFIS->(dbGoTop())
    While !_QRYFIS->(EoF())
        //-- Incrementa a mensagem na regua
        nAtual++
        IncProc("Atualizando " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")

        SC5->( MsGoto( _QRYFIS->SC5RECNO ) )
        SC6->( MsGoto( _QRYFIS->SC6RECNO ) )

        If Empty(_QRYFIS->C5_XBLFIS)
            RecLock("SC5", .F.)
                SC5->C5_XBLFIS  := "1" //-- Bloqueado
                SC5->C5_X4SSTAT := "9" //-- Em Validacao Fiscal

                //Grava o campo C5_MSEXP para sinalizaro ao Scheduler
                SC5->C5_MSEXP := ""  //DToS(dDataBase)
            SC5->(MsUnLock())
        ElseIf _QRYFIS->C5_XBLFIS == "1"
            If Z09->(MsSeek(xFilial("Z09") + _QRYFIS->C5_NUM + _QRYFIS->C6_ITEM))
                If !(Z09->Z09_PROD == SC6->C6_PRODUTO) .Or. (QtdComp(Z09->Z09_QTDPV) <> QtdComp(SC6->C6_QTDVEN)) .Or. !(Z09->Z09_LOTECT == SC6->C6_LOTECTL) .Or. !(Z09->Z09_ICOTER == SC5->C5_TPFRETE) .Or. !(Z09->Z09_TRANSP == SC5->C5_TRANSP) .Or. !(Z09->Z09_REDICO == SC5->C5_TFRDP1) .Or. !(Z09->Z09_REDESP == SC5->C5_REDESP) .Or.;
                    (QtdComp(MpSysExecScalar("SELECT COUNT(1) AS QTDZ09 FROM " + RetSQLName("Z09") + " Z09 WHERE Z09.Z09_FILIAL = '" + xFilial("Z09") + "' AND Z09.Z09_NUMPV = '" + _QRYFIS->C5_NUM + "' AND Z09.D_E_L_E_T_= ' ' ", "QTDZ09")) <> QtdComp(MpSysExecScalar("SELECT COUNT(1) AS QTDSC6 FROM " + RetSQLName("SC6") + " SC6 WHERE SC6.C6_FILIAL = '" + xFilial("SC6") + "' AND SC6.C6_NUM = '" + _QRYFIS->C5_NUM + "' AND SC6.D_E_L_E_T_= ' ' ", "QTDSC6")))

                    //-- Deleta Z11
                    //cUpDate := " UPDATE " + RetSqlName("Z11") + " Z11 SET Z11.D_E_L_E_T_ = '*', Z11.R_E_C_D_E_L_ = Z11.R_E_C_N_O_ WHERE Z11_IDTRAC IN ('" + Z09->Z09_IDTRAC + "') AND Z11.D_E_L_E_T_ = ' ' "
                    cUpDate := " DELETE " + RetSqlName("Z11") + " Z11 WHERE Z11_IDTRAC IN ('" + Z09->Z09_IDTRAC + "') "	
                    If tcsqlexec(cUpdate)
                        ConOut(tcsqlerror())
                    EndIf

                    //-- Deleta Z09
                    //cUpDate := " UPDATE " + RetSqlName("Z09") + " Z09 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE Z09_FILIAL = '" + Z09->Z09_FILIAL + "' AND Z09_NUMPV = '" + _QRYFIS->C5_NUM  + "' AND D_E_L_E_T_ = ' ' "
                    cUpDate := " DELETE " + RetSqlName("Z09") + " Z09 WHERE Z09_FILIAL = '" + Z09->Z09_FILIAL + "' AND Z09_NUMPV = '" + _QRYFIS->C5_NUM  + "' "	
                    If tcsqlexec(cUpdate)
                        ConOut(tcsqlerror())
                    EndIf

                    RecLock("SC5", .F.)
                        SC5->C5_XBLFIS  := "1" //-- Bloqueado
                        SC5->C5_X4SSTAT := "9" //-- Em Validacao Fiscal

                        //Grava o campo C5_MSEXP para sinalizaro ao Scheduler
                        SC5->C5_MSEXP := ""  //DToS(dDataBase)
                    SC5->(MsUnLock())
                EndIf
            EndIf
        EndIf

        _QRYFIS->(dbSkip())
    EndDo

    If Select("_QRYFIS") > 0
        _QRYFIS->(dbCloseArea())
    EndIf

    RestArea(aAreaSC6)
    RestArea(aAreaSC5)
    RestArea(aAreaAnt)

Return
