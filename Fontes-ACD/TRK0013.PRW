#include "totvs.ch"


/*/{Protheus.doc} TRK0013
Troca de transportadora - PL_010_v01.pdf
@type function
@version 1.0
@author DO THINK
@since 10/08/2025
/*/
User Function TRK0013()
    TRK0013InfCS("Cockpit Expedição","Z09")
Return



static function TRK0013InfCS(cTitulo,cAlias)

    local aArea      := FWGetArea()
    local aAreaAlias := (cAlias)->(FWGetArea())
    local aTrackS    := {}  as array
    local cChave     := ""  as character
    //local cPedido    := ""  as character
    //local cRemessa   := ""  as character
    //local cTriangular:= ""  as character
    local cMotivo    := ""  as character
    local cMotivoObs    := ""  as character
    local cAuxObs    := ""  as character
    local cProcTitle := cTitulo+" :: Informar Time de Operações"
    //local nRecRemess := 0   as numeric
    local nCodSiz    := 6   as numeric
    local nDesSiz    := 150 as numeric
    local lRet       := .F. as logical
    local oOk               as object
    local oDlg              as object
    local oPanel            as object
    local oCancel           as object
    local oCodMot           as object
    local oMotObs           as object

    private cDescMotivo     := Space(nDesSiz)
    private oDecMot         as object

    nCodSiz    := GetSX3Cache("CB4_CODDIV","X3_TAMANHO")
    cMotivo    := Space(nCodSiz)
    cMotivoObs := Space(50)
    cChave     := Z09->(Z09_FILIAL + Z09_NUMPV)

    DEFINE MSDIALOG oDlg FROM 0,0 TO 375,600 TITLE cProcTitle PIXEL OF GetWNDDefault()

        @ 000,000 MSPANEL oPanel OF oDlg
        oPanel:Align:=CONTROL_ALIGN_ALLCLIENT

        @ 005,005 SAY "Pedido:"  SIZE 45,08 OF oPanel PIXEL
        @ 005,048 SAY AllTrim(Z09->Z09_NUMPV)  SIZE 45,08 OF oPanel PIXEL

        @ 005,090 SAY "BU:"  SIZE 45,08 OF oPanel PIXEL
        @ 005,105 SAY AllTrim(Z09->Z09_BU) +Space(5)+ "Responsável: " + AllTrim(Z09->Z09_RESPON)  SIZE 200,08 OF oPanel PIXEL

        //@ 005,300 SAY "Responsável:"  SIZE 45,08 OF oPanel PIXEL
        //@ 005,348 SAY AllTrim(Z09->Z09_BU)  SIZE 80,08 OF oPanel PIXEL     
        @ 015,005 SAY "Cliente:"  SIZE 45,08 OF oPanel PIXEL
        @ 015,048 SAY AllTrim(Z09->Z09_CLIENT)+ "-" + AllTrim(Z09->Z09_LOJA)+ " - " + AllTrim(Z09->Z09_NOMECL)  SIZE 250,08 OF oPanel PIXEL  

        @ 025,005 SAY "Transportadora:"  SIZE 45,08 OF oPanel PIXEL
        @ 025,048 SAY AllTrim(Z09->Z09_TRANSP) + " - " + AllTrim(Z09->Z09_NTRANS)  SIZE 200,08 OF oPanel PIXEL      
        
        @ 035,005 SAY "Tipo de Frete:"  SIZE 45,08 OF oPanel PIXEL
        @ 035,048 SAY U_DtCombo("Z09_ICOTER", Z09->Z09_ICOTER)  SIZE 80,08 OF oPanel PIXEL      

        @ 047,005 SAY "Código Motivo:" SIZE 45,08 OF oPanel PIXEL
        @ 045,048 MSGET oCodMot VAR cMotivo SIZE CalcFieldSize("C",nCodSiz,0,"@!",Replicate("W",nCodSiz)),08 OF oPanel PIXEL F3 "CB4" VALID CodMtVld(@cMotivo,nCodSiz,@oCodMot)

        @ 060,005 SAY "Motivo:" SIZE 45,08 OF oPanel PIXEL
        @ 058,048 MSGET oDecMot VAR cDescMotivo SIZE 210,08 OF oPanel PIXEL WHEN .F.

        @070,005 SAY "Observação" SIZE 60,07 OF oPanel PIXEL
        @078,005 GET oMotObs VAR cMotivoObs MEMO SIZE 280,080 CENTERED DESIGN OF oPanel PIXEL WHEN (.T.)

        DEFINE SBUTTON oOk     FROM 170,(280-48) TYPE 1 ENABLE OF oPanel PIXEL ACTION (If(VCloseDlgR(cMotivo, cMotivoObs, cProcTitle), (lRet:=.T.,oDlg:End()), nil))
        DEFINE SBUTTON oCancel FROM 170,(280-20) Type 2 ENABLE OF oPanel PIXEL ACTION oDlg:End()

        oMotObs:lReadOnly:=.F.
        oMotObs:EnableVScroll(.T.)
        oMotObs:EnableHScroll(.T.)

        oDlg:lEscClose:=.F.

    ACTIVATE MSDIALOG oDlg CENTER ON INIT (oDlg:SetFocus())

    if (lRet)
        cAuxObs := ""
        dbSelectArea("Z09")
		Z09->( dbSetOrder(3) )
        Z09->( dbSeek( cChave ) )
        
        While Z09->( !Eof() .And. Z09_FILIAL + Z09_NUMPV == cChave)
            cAuxObs := ""
        	aTrackS := Array( Len( Z09->( DbStruct() ) ) )

			aTrackS[Z09->(FieldPos("Z09_FILIAL"))]  := Z09->Z09_FILIAL
			aTrackS[Z09->(FieldPos("Z09_NUMPV")) ]  := Z09->Z09_NUMPV                   // Pedido Venda
			aTrackS[Z09->(FieldPos("Z09_ITEMPV"))]  := Z09->Z09_ITEMPV                  // Item PV
            cAuxObs += "--[" + DTOC(Date()) + " " + Time() + "]----------"+ chr(13)+chr(10)
            cAuxObs += "Para: Operações" + chr(13)+chr(10)
            cAuxObs += "Quem: " + cUserName + chr(13)+chr(10)
            cAuxObs += "O que: "+ AllTrim(cDescMotivo) + chr(13)+chr(10)
            cAuxObs += "Observação:" + chr(13)+chr(10)
            cAuxObs += AllTrim(cMotivoObs)+ chr(13)+chr(10)+ chr(13)+chr(10)
            aTrackS[Z09->(FieldPos("Z09_ACAOCS"))]	:= "2"								// Acao CS
            aTrackS[Z09->(FieldPos("Z09_DSMOTV"))]	:= cAuxObs + Trim(Z09->Z09_DSMOTV) 	// Detalhes do Motivo
            aTrackS[Z09->(FieldPos("Z09_PENCS")) ]  := cAuxObs + Trim(Z09->Z09_PENCS)   // Pendencia CS
            If !Empty(cMotivo)
                aTrackS[Z09->(FieldPos("Z09_MOTIVO")) ]	:= cMotivo						// Observacao para CS
            EndIf
 
            u_TRK006S(aTrackS, "Informar Time Operacoes")

            Z09->( DbSkip() )
        End
        
        /*
        SetTraking(cAlias, "3", cMotivo, FWGetSX5( "Z0", cMotivo)[1][4], cMotivoObs)

        If nRecRemess > 0
            (cAlias)->( DbGoto(nRecRemess) )
            SetTraking(cAlias, "3", cMotivo, FWGetSX5( "Z0", cMotivo)[1][4], cMotivoObs)
        EndIf
        */
    endif

    FreeObj(@oOk)
    FreeObj(@oDlg)
    FreeObj(@oPanel)
    FreeObj(@oCancel)
    FreeObj(@oCodMot)
    FreeObj(@oMotObs)

    FWRestArea(aAreaAlias)
    FWFreeArray(@aAreaAlias)

    FWRestArea(aArea)
    FWFreeArray(@aArea)

return()

/*/{Protheus.doc} CodMtVld
Valida e Normaliza o Codigo de Rejeição.
@type function
@version 1.0
@author DoThink
@since 22/07/2025
/*/
static function CodMtVld(cMotivo as character,nCodSiz as numeric,oCodMot as object) as logical
local aArea := GetArea()
local lRet  := .F.

DbSelectArea("CB4")
CB4->( DbSetOrder(1) )

lRet := CB4->( DbSeek(xFilial() + cMotivo) )

If lRet
    cDescMotivo:= CB4->CB4_DESCRI
EndIf

oDecMot:Refresh()

RestArea(aArea)
return lRet

static function VCloseDlgR(cMotivo, cMotivoObs, cProcTitle)
    local lRet := .T.

    If Empty(cMotivo)
        lRet := .F.
    EndIf

    If Empty(cMotivoObs)
        lRet := .F.
    EndIf

    If !lRet
        ApMsgInfo("São obrigatórios o preechimento dos campos [código do motivo] e [Observação].",cProcTitle)
    EndIf

return lRet

