#include "totvs.ch"
#include "rwmake.ch"
#include "topconn.ch"
#include "fwmvcdef.ch"
Static _nADanfeNy := 0 as numeric
Static nADanfeCHV := ++_nADanfeNy
Static nADanfeCLI := ++_nADanfeNy
Static nADanfeLOJ := ++_nADanfeNy
Static nADanfeTPV := ++_nADanfeNy
/*/{Protheus.doc} GFEEX001
Geracao de Romaneio de Carga SIGAGFE, a partir de chamada do SIGAACD
@type function
@version 20250814
@author luiz.favareto@dithink.com.br
@since 25/06/2025
@history 13/08/2025, luiz.favareto, adicionado terceiro parametro BA_TPOPPF para carga caminhao fechado
@history 14/08/2025, luiz.favareto, novo parametro GFEA050LIB default .T. se desarma transacao na falha do calculo/liberacao do romaneio, e correcao chamada liberacao sem interface (lAuto)
@param aDanfes, array, {{"35250669170462000668550070000044681387453992","000001","02"},...}
@return character, mensagem retorno sucesso ou falha
@obs Conforme Projeto Logico 001 do Projeto no. 20250528008v02 referente ao servico de Revitalizacao do Gestao de Frete Embarcador (SIGAGFE TOTVS Protheus) e Integracao com o SIGAACD (Automacao e Coleta de Dados)
/*/
User Function GFEEX001(;
        aDanfes      as array;
    )
    Local aArea      as array
    Local cChaveGW1  as character
    Local cGU3CDEMIT as character
    Local cF2TRANSP  as character
    Local cZ09CDTPVC as charecter
    Local cRet       as character
    Local lGFEEX001  as boolean
    Local lPerigoso  as boolean
    Local nX         as numeric
    Local oModelGWN  as object
    Iif(lGFEEX001:=SuperGetMv("BA_GFEX001",,.T.),ConOut(ProcName()+" => INICIO"),)
    Iif(.Not.ValType(aDanfes)=="A",cRet:="ERRO na chamada da rotina "+ProcName(),)
    If Empty(cRet)
        aArea := Lj7GetArea({"GW1","GW8","SB5","SF2","SA4","GWU"})
        lPerigoso := .F.
        SB5->(DbSetOrder(1)) // B5_FILIAL+B5_COD
        GW8->(DbSetOrder(2)) // GW8_FILIAL+GW8_CDTPDC+GW8_EMISDC+GW8_SERDC+GW8_NRDC+GW8_SEQ
        SF2->(DbSetOrder(1)) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
        SA4->(DbSetOrder(1)) // A4_FILIAL+A4_COD
        Iif(.Not.GW1->(DBOrderNickname("DANFE")),cRet:="ERRO no indice GW1 DANFE",) // GW1_DANFE+GW1_FILIAL
        Iif(Empty(aDanfes),cRet:="ERRO, informar ao menos uma Chave de NF",)
        For nX := 1 To Len(aDanfes)
            Iif(.Not.Len(aDanfes[nX])==4,cRet:="ERRO na chamada da rotina, documento nro. "+cValToChar(nX),)
            Iif(Empty(cRet).And.Empty(aDanfes[nX][nADanfeCHV]),cRet:="ERRO, documento nro. "+cValToChar(nX)+", Chave da NF nao informada",)
            Iif(Empty(cRet).And.Empty(aDanfes[nX][nADanfeCLI]),cRet:="ERRO, documento nro. "+cValToChar(nX)+", Cliente da NF nao informado",)
            Iif(Empty(cRet).And.Empty(aDanfes[nX][nADanfeLOJ]),cRet:="ERRO, documento nro. "+cValToChar(nX)+", Loja(cliente) da NF nao informada",)
            //Iif(Empty(cRet).And.Empty(aDanfes[nX][nADanfeTPV]),cRet:="ERRO, documento nro. "+cValToChar(nX)+", Tipo de Veículo nao informado no cockpit",)
            Iif(Empty(cRet).And.(.Not.ValType(aDanfes[nX][nADanfeCHV])=="C"),cRet:="ERRO, documento nro. "+cValToChar(nX)+", Chave da NF c/ tipo incorreto!",)
            Iif(Empty(cRet).And.(.Not.ValType(aDanfes[nX][nADanfeCLI])=="C"),cRet:="ERRO, documento nro. "+cValToChar(nX)+", Cliente da NF c/ tipo incorreto!",)
            Iif(Empty(cRet).And.(.Not.ValType(aDanfes[nX][nADanfeLOJ])=="C"),cRet:="ERRO, documento nro. "+cValToChar(nX)+", Loja(cliente) da NF c/ tipo incorreto!",)
            Iif(Empty(cRet).And.(.Not.ValType(aDanfes[nX][nADanfeTPV])=="C"),cRet:="ERRO, documento nro. "+cValToChar(nX)+", Tipo de Veículo c/ tipo incorreto!",)
            Iif(Empty(cRet).And.(.Not.Len(aDanfes[nX][nADanfeCHV])==GetSx3Cache("F2_CHVNFE","X3_TAMANHO")),cRet:="ERRO, documento nro. "+cValToChar(nX)+", Chave da NF c/ tamanho incorreto!",)
            Iif(Empty(cRet).And.(.Not.Len(aDanfes[nX][nADanfeCLI])==GetSx3Cache("F2_CLIENTE","X3_TAMANHO")),cRet:="ERRO, documento nro. "+cValToChar(nX)+", Cliente da NF c/ tamanho incorreto!",)
            Iif(Empty(cRet).And.(.Not.Len(aDanfes[nX][nADanfeLOJ])==GetSx3Cache("F2_LOJA","X3_TAMANHO")),cRet:="ERRO, documento nro. "+cValToChar(nX)+", Loja(cliente) da NF c/ tamanho incorreto!",)
            Iif(Empty(cRet).And.(.Not.GW1->(MsSeek(Padr(aDanfes[nX][nADanfeCHV],GetSx3Cache("GW1_DANFE","X3_TAMANHO"))+xFilial("GW1")))),cRet:="ERRO Chave ["+aDanfes[nX][nADanfeCHV]+"] nao encontrada!",)
            Iif(Empty(cRet).And.(.Not.Empty(GW1->GW1_NRROM)),cRet:="ERRO, NF ["+GW1->GW1_NRDC+"] Serie ["+GW1->GW1_SERDC+"] ja existe em outro romaneio!",)
            Iif(Empty(cRet).And.(.Not.SF2->(MsSeek(GW1->(GW1_FILIAL+Padr(GW1_NRDC,GetSx3Cache("F2_DOC","X3_TAMANHO"))+GW1_SERDC+aDanfes[nX][nADanfeCLI]+aDanfes[nX][nADanfeLOJ])))),cRet:="ERRO, NF ["+GW1->GW1_NRDC+"] Serie ["+GW1->GW1_SERDC+"] nao encontrada!",)
            Iif(Empty(cRet).And.Empty(SF2->F2_TRANSP),cRet:="ERRO, NF ["+GW1->GW1_NRDC+"] Serie ["+GW1->GW1_SERDC+"] sem transportadora definida!",)
            Iif(Empty(cRet),Iif(Empty(cF2TRANSP),cF2TRANSP:=SF2->F2_TRANSP,Iif(.Not.cF2TRANSP==SF2->F2_TRANSP,cRet:="ERRO, NF ["+GW1->GW1_NRDC+"] Serie ["+GW1->GW1_SERDC+"] transportadora ["+cF2TRANSP+"] diferente para romaneio!",)),)
            If Empty(cRet).And.(.Not.lPerigoso)
                Iif(Empty(cRet),GW8->(MsSeek((cChaveGW1:=GW1->(GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC))+"01")),)
                While cChaveGW1==GW8->(GW8_FILIAL+GW8_CDTPDC+GW8_EMISDC+GW8_SERDC+GW8_NRDC)
                    If (lPerigoso:=SB5->(MsSeek(xFilial("SB5")+GW8->GW8_ITEM)).And.(.Not.Empty(SB5->B5_ONU)))
                        Exit
                    Else
                        GW8->(DbSkip())
                    Endif
                Enddo
            Endif
        Next
    Endif
    If Empty(cRet)
        Iif(.Not.SA4->(MsSeek(xFilial("SA4")+cF2TRANSP)),cRet:="ERRO, transportadora ["+cF2TRANSP+"] nao encontrada!",)
        Iif(Empty(cRet).And.Empty(SA4->A4_CGC),cRet:="ERRO, transportadora ["+cF2TRANSP+"] sem CNPJ cadastrado!",)
    Endif
    If Empty(cRet)
        cGU3CDEMIT := MpSysExecScalar("select top 1 coalesce(GU3_CDEMIT,' ') GU3_CDEMIT from "+RetSqlName("GU3");
            +" where GU3_FILIAL="+ValToSql(xFilial("GU3"))+" and GU3_IDFED="+ValToSql(Alltrim(SA4->A4_CGC));
            +" and GU3_TRANSP='1' and GU3_CTE='1' and D_E_L_E_T_=' ' order by R_E_C_N_O_","GU3_CDEMIT")
        Iif(Empty(cGU3CDEMIT),cRet:="ERRO, emitente de Transporte nao cadastrado ["+SA4->A4_CGC+"]",)
    Endif
    If Empty(cRet)
        cZ09CDTPVC  := aDanfes[1][nADanfeTPV]
        oModelGWN   := FWLoadModel("GFEA050")
        oModelGWN:SetOperation(MODEL_OPERATION_INSERT)
        oModelGWN:Activate()
        Iif(.Not.oModelGWN:IsActive(),cRet:="ERRO na ativacao do modelo de dados GFEA050: "+oModelGWN:GetErrorMessage()[6],)
        If Empty(cRet)
            oModelGWN:SetValue("GFEA050_GWN","GWN_FILIAL",xFilial("GWN"))
            // oModelGWN:SetValue("GFEA050_GWN","GWN_NRROM ",GFE50NRROM())
            oModelGWN:SetValue("GFEA050_GWN","GWN_CDTRP" ,cGU3CDEMIT)
            oModelGWN:SetValue("GFEA050_GWN","GWN_DTIMPL",dDataBase)
            oModelGWN:SetValue("GFEA050_GWN","GWN_HRIMPL",Left(Time(),5))
            oModelGWN:SetValue("GFEA050_GWN","GWN_ORI"   ,"1")
            oModelGWN:SetValue("GFEA050_GWN","GWN_CDCLFR",SuperGetMv("BA_CDCLFR",,""))
            If Empty(cZ09CDTPVC)
                oModelGWN:SetValue("GFEA050_GWN","GWN_CDTPOP",Padr(SuperGetMv("BA_TPOPP"+Iif(lPerigoso,"P","N"),,""),GetSx3Cache("GWN_CDTPOP","X3_TAMANHO")))
            Else
                oModelGWN:SetValue("GFEA050_GWN","GWN_CDTPOP",Padr(SuperGetMv("BA_TPOPPF",,""),GetSx3Cache("GWN_CDTPOP","X3_TAMANHO")))
                oModelGWN:SetValue("GFEA050_GWN","GWN_CDTPVC",cZ09CDTPVC)
            EndIf
            // oModelGWN:SetValue("GFEA050_GWN","GWN_SIT"   ,"2")
            Iif(lGFEEX001,ConOut(ProcName()+" => Validando Emissao do Romaneio"),)
            Iif(.Not.oModelGWN:VldData(),cRet:="ERRO na criacao do romaneio: "+oModelGWN:GetErrorMessage()[6],)
            If Empty(cRet)
                Iif(lGFEEX001,ConOut(ProcName()+" => Gravando Romaneio"),)
                Begin Sequence;Begintran()
                    oModelGWN:CommitData()
                    GWU->(DbSetOrder(1)) // GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC+GWU_SEQ
                    For nX := 1 To Len(aDanfes)
                        Iif(lGFEEX001,ConOut(ProcName()+" => Associando Documento de Carga ao Romaneio "+GWN->GWN_NRROM),)
                        Iif(.Not.GW1->(MsSeek(Padr(aDanfes[nX][nADanfeCHV],GetSx3Cache("GW1_DANFE","X3_TAMANHO"))+xFilial("GW1"))),cRet:="ERRO ao localizar Documento de Carga!",)
                        If Empty(cRet)
                            RecLock("GW1",.F.)
                            GW1->GW1_NRROM := GWN->GWN_NRROM
                            GW1->GW1_SIT   := "4" // embarcado
                            GW1->(MsUnLock())
                            Iif(lGFEEX001,ConOut(ProcName()+" => Associando Trecho do Itinerario ao Transportador "+cGU3CDEMIT),)
                            Iif(.Not.GWU->(MsSeek(GW1->(GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC+"01"))),cRet:="ERRO ao localizar Trecho do Itinerario!",)
                            If Empty(cRet)
                                RecLock("GWU",.F.)
                                GWU->GWU_CDTRP := cGU3CDEMIT
                                GWU->(MsUnLock())
                            Endif
                        Endif
                    Next
                    cMsg := ""
                    Iif(Empty(cRet).And.(.Not.GFE050CALC(,,@cMsg,)),cRet:="ERRO no calculo do Romaneio!" +CRLF+cMsg,)
                    Iif(Empty(cRet).And.(.Not.GFEA050LIB(.T.,,,,.T.)),cRet:="ERRO na liberacao do Romaneio!",)
                    If Empty(cRet)
                        cRet:="Sucesso na geracao do Romaneio: "+GWN->GWN_NRROM
                    Else
                        If SuperGetMv("BA_GFEX1TT",,.T.)
                            DisarmTransaction()
                        Endif
                        cRet += CRLF
                        For nX:=1 To Len(aDanfes)
                            cRet += "---" + CRLF
                            cRet += "[" + cValToChar(nX) + "] Danfe: "          + aDanfes[nX, nADanfeCHV] + CRLF
                            cRet += "[" + cValToChar(nX) + "] Cliente: "        + aDanfes[nX, nADanfeCLI] + CRLF
                            cRet += "[" + cValToChar(nX) + "] Loja: "           + aDanfes[nX, nADanfeLOJ] + CRLF
                            cRet += "[" + cValToChar(nX) + "] Tipo Veiculo: "   + aDanfes[nX, nADanfeTPV] + CRLF
                        Next nX
                        EnviaEmail("ERRO rotina "+ProcName(1)+" => "+ProcName(),cRet,SuperGetMv("BA_GFEX1EM",,""))
                    Endif
                    Iif(lGFEEX001,ConOut(ProcName()+" => "+cRet),)
                Endtran();End Sequence
            Endif
            oModelGWN:Deactivate()
        Endif
    Endif
    Iif(Empty(aArea),,Lj7RestArea(aArea))
    Iif(lGFEEX001,ConOut(ProcName()+" => Retorno: "+cRet),)
    Iif(lGFEEX001,ConOut(ProcName()+" => FIM"),)
Return cRet
/*/{Protheus.doc} EnviaEmail
Envio de email
@type function
@version 20250705
@author luiz.favareto@dothink.com.br
@since 05/07/2025
@param cAssunto, character, assunto
@param cMsg, character, mensagem
@param cEmail, character, destinatario
@return logical, lRet
/*/
Static Function EnviaEmail(;
        cAssunto as character;
        ,cMsg    as character;
        ,cEmail  as character;
    )
    Local lGFEEX001  := SuperGetMv("BA_GFEX001",,.T.) as boolean
    Local oServer    := tMailManager():New() as object
    Local oMessage   := tMailMessage():New() as object
    Local nSMTPTime  := SuperGetMv("MV_RELTIME",,120) as numeric
    Local cSMTPAddr  := SuperGetMV("MV_RELSERV",,"") as character
    Local nSMTPPort  := Iif(":"$cSMTPAddr,SubStr(cSMTPAddr,At(":",cSMTPAddr)+1),587) as numeric
    Local cUser      := SuperGetMV("MV_RELACNT",,"") as character
    Local cPass      := SuperGetMV("MV_RELPSW" ,,"") as character
    Local cFrom      := SuperGetMV("MV_RELACNT",,"") as character
    Local lSSL       := SuperGetMV("MV_RELSSL" ,,"") as boolean
    Local lTLS       := SuperGetMV("MV_RELTLS" ,,"") as boolean
    Local lRet       := .T. as boolean
    Local nRet       := 0 as numeric
    Local cErro      := "" as character
    Iif(lGFEEX001:=SuperGetMv("BA_GFEX001",,.T.),ConOut(ProcName()+" => INICIO"),)
    If .Not.Empty(cAssunto).And.(.Not.Empty(cMsg)).And.(.Not.Empty(cEmail))
        Iif(":"$cSMTPAddr,cSMTPAddr:=Left(cSMTPAddr,At(":",cSMTPAddr)-1),)
        oMessage:Clear()
        oMessage:cFrom    := cFrom
        oMessage:cTo      := cEmail
        oMessage:cSubject := cAssunto
        oMessage:cBody    := cMsg
        oServer:SetUseTLS(lSSL)
        oServer:SetUseSSL(lTLS)
        nRet := oServer:Init(""/*cPopAddr*/,cSMTPAddr,cUser,cPass,0/*nPOPPort*/,nSMTPPort)
        lRet := nRet==0
        If .Not.lRet
            cErro := "ERRO ao conectar com SMTP server: "+oServer:GetErrorString(nRet)
        Else
            nRet := oServer:SetSMTPTimeout(nSMTPTime)
            lRet := nRet==0
            If .Not.lRet
                cErro := "ERRO ao denifir o timeout no SMTP server para: "+cValToChar(nTimeout)
            Else
                nRet := oServer:SMTPConnect()
                lRet := nRet==0
                If .Not.lRet
                    cErro := "ERRO na conclusao da conexao ao SMTP server: "+oServer:GetErrorString(nRet)
                Else
                    nRet := oServer:SmtpAuth(cUser,cPass)
                    lRet := nRet==0
                    If .Not.lRet
                        cErro := "ERRO na autenticacao do SMTP server: "+oServer:GetErrorString(nRet)
                        oServer:SMTPDisconnect()
                    Else
                        nRet := oMessage:Send(oServer)
                        lRet := nRet==0
                        If .Not.lRet
                            cErro := "ERRO no envio da mensagem no SMTP server: "+oServer:GetErrorString(nRet)+CRLF
                        Endif
                        If .Not.oServer:SMTPDisconnect()==0
                            cErro += "ERRO ao desconectar do SMTP server: "+oServer:GetErrorString(nRet)
                        Endif
                    Endif
                Endif
            Endif
        Endif
        If .Not.Empty(cErro)
            ConOut(ProcName(2)+" => "+ProcName(1)+" => "+ProcName()+" => "+cErro)
        Endif
    Endif
Return lRet
/*/{Protheus.doc} qg250630
testes unitario
@type function
@version 1
@author luiz.favareto
@since 30/06/2025
@return variant, void
/*/
user function qg250630
    wfprepenv("BA","04")
    //u_GFEEX001({{"35231269170462000404550040000306481638145032","000912","03"}})
    u_GFEEX001({{"35250569170462000404550040000510851765272909","000044","01", "TOCO      "}})
return

user function qg250717
    local aPergs   := {}
    local cTpVei   := Space(10)
    local cVldGV3  := "Vazio() .Or. ExistCpo('GV3')"
    local cRet     := ""
    Private cChave   := Space(44)
    Private cCliente := ""
    Private cLoja    := ""

    wfprepenv("BA","04")

    aAdd(aPergs, {1, "Chave Danfe"  , cChave   , "@!", ""   , ""    , ".T.", 100,  .T.})
    aAdd(aPergs, {1, "Tipo Veículo" , cTpVei   , "@!", cVldGV3  , "GV3" , ".T.", 60,  .F.})

	If !ParamBox(aPergs, "Informe os parâmetros para Teste rotina")
		FWAlertInfo("Cancelado pelo operador", "Encerrando")
		Return
	EndIf    

    //-- Validacao inicial de conteudo da chave da danfe
    If Empty(MV_PAR01) .or. Len( Alltrim(MV_PAR01) ) < 44
		FWAlertInfo("Chave da danfe invalida! Possui menos de 44 caracteres", "Erro")
		Return 
	EndIf    

    DbSelectArea("SF2")
    SF2->( DbOrderNickName("CHAVE") )

    //-- Verifica se chave existe
    If !SF2->( DbSeek( xFilial() + MV_PAR01 ) )
		FWAlertInfo("Chave da danfe nao localizada!", "Erro")
		Return 
    EndIf


    //-- Guarda dados do cliente
    cCliente := SF2->F2_CLIENTE
    cLoja    := SF2->F2_LOJA   


    cRet := u_GFEEX001({{MV_PAR01,cCliente,cLoja, MV_PAR02}})

    cRet := DecodeUTF8(cRet, "cp1252")
    FWAlertInfo(cRet, "Retorno função")
    
return


// ////////////////////////////////////////////////////////////////////////////////////////////////////////
// ////////////////////////////////////////////////////////////////////////////////////////////////////////
// ////////////////////////////////////////////////////////////////////////////////////////////////////////
// //
// // funcoes abaixo sao trechos do padrao totvs, para
// // facilitar debug durante testes unitarios apenas
// //
// // devem ser removidos antes de liberar para homologacao !!!
// //
// ////////////////////////////////////////////////////////////////////////////////////////////////////////
// ////////////////////////////////////////////////////////////////////////////////////////////////////////
// ////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// 
// //-------------------------------------------------------------------
// /*/{Protheus.doc} GFE050CALC
// Calcula o frete de um romaneio
// @type function
// @param lDatabase, logical, Verifica se usa a data base na data da criaÃ§Ã£o do cÃ¡lculo (GWN_DTCALC)
// @author Luiz Fernando Soares
// @since 30/11/09
// @version 1.0
// /*/
// //-------------------------------------------------------------------
// 
// Static Function GFE050CALC(lDatabase,lHelp,cMsg,aRetCalc,lTstAuto,cArqLog)
//     Local aAreaGWN   := {}
//     Local lCalcAuto  := .F.
//     Local lLog       := IIF(SuperGetMv("MV_LOGCALC",,'1') == '2',.F., .T.)//Indica se serÃ¡ gerado ou nÃ£o o log de cÃ¡lculo, de acordo com // os parametros do mÃ³dulo
//     Local nQtPern    := 0
//     Local cGU5_TPIMP := ""
//     Local cNrOcor    := ""
//     Local nX         := 0
//     Local nY         := 0
//     Local nF         := 0
//     Local aDocsCarg  := {}
//     Local aNoCalc    := {}
//     Local aTcomps    := {}
//     Local cAliasQry  := Nil
//     Local lCalcrom   := .F.
//     Local aRetGXT    := {}
// 
//     Private lEdi       := .f.
//     Private aTblFrFUNB := {}
//     Private aCompsAux  := {}
//     Private nTblFrFUNB := 1
//     Private nAux2      := 1
//     Private cCalAntigo := ''
// 
//     // ParÃ¢metro utilizado para realizar nova conferÃªnica Doc Frete
//     // Deve estar como Private pois Ã© utilizado dentro de outra funÃ§Ã£o chamada por esta
//     Private cMV_GFE005 := SuperGetMv("MV_GFE005",.F.,"1")
//     Private aDFReConf  := {}
// 
//     Private lFirstMsg  := .F.
// 
//     Default lDatabase  := .T.
//     Default lHelp      := .T.
//     Default cMsg       := ""
//     Default aRetCalc   := {}
//     Default lTstAuto   := .F.
// 
//     If Empty(cMV_GFE005)
//         cMV_GFE005 := "1"
//     EndIf
// 
//     If lHelp .And. !Empty(GWN->GWN_VIAGEM) .And. !IsInCallStack("GF58ExecPVIA") // Quando lhelp Ã© falso, o cÃ¡lculo deve ser em lote
//         If PosicionaGWP(lHelp,@cMsg)
//             Return GFEA58CVIA(GWN->GWN_NRROM) // Calcula todos romaneios da viagem
//         Else
//             Return .F.
//         EndIf
//     EndIf
//     //Verifica se estÃ¡ sendo calculado para um docmento automÃ¡tico para suprimir mensagens
//     If !lTstAuto
//         If  !(GWN->GWN_NRROM == GW1->GW1_NRROM)
//             GW1->( dbSetOrder(09) )
//             GW1->( dbSeek(xFilial("GW1")+GWN->GWN_NRROM) )
//         EndIf
//         If (GW1->GW1_CALCAT == "1" .OR. Empty(GW1->GW1_CALCAT)) ;
//                 .And. Posicione("GV5",1,xFilial("GV5")+GW1->GW1_CDTPDC,"GV5_CALC") == "2"
// 
//             lCalcAuto := .T.
//         EndIf
//     Else
//         lCalcAuto := .T.
//     EndIf
// 
//     aAgrFrt  := {}
//     aDocCarg := {}
//     aTrchDoc := {}
//     aItDoc   := {}
// 
//     aAreaGWN := GWN->( GetArea() )
//     // ValidaÃ§Ãµes em relaÃ§Ã£o ao documento de carga
//     GWN->( dbSetOrder(1) )
//     aDocsCarg := {.F.,{}}
//     If GWN->(dbSeek(xFilial("GWN") + GWN->GWN_NRROM))
//         aDocsCarg := GF50VLROM(GWN->GWN_NRROM,lCalcAuto,"ROMANEIO") // Valida e retorna os documentos recalculÃ¡veis
//     EndIf
// 
//     // [1]: 0=Todos podem calcular; 1=alguns podem calcular; 2=Nenhum pode calcular; 3=Romaneio calculado no ERP
//     // [2]: Dados de DCs localizados.
//     // [3]: Mensagem de problemas identificados
//     // [4]: Num Calculo prÃ© existente nos DCs localizados
//     If Len(aDocsCarg[2]) == 0
//         If GW1->GW1_SIT == "2"
//             cMsg := "O Documento de Carga relacionado ao Romaneio estÃ¡ bloqueado."
//         Else
//             cMsg := "NÃ£o hÃ¡ documentos relacionados ao Romaneio."
//         EndIf
// 
//         If lCalcAuto == .F. .AND. lHelp
//             Help( ,, 'HELP',, cMsg, 1, 0)
//         EndIf
//         Return .F.
//     ElseIf aDocsCarg[1] == 3
//         cMsg := aDocsCarg[2,Len(aDocsCarg[2]),2]
//         If lCalcAuto == .F. .AND. lHelp
//             Help( ,, 'HELP',, cMsg, 1, 0)
//         EndIf
//         Return .F.
//     ElseIf aDocsCarg[1] == 2
//         cMsg := "NÃ£o foi possÃ­vel recalcular nenhum frete para documentos relacionados ao romaneio." + CRLF  + CRLF + "Motivos: "
//         nF := Len(aDocsCarg[3])
//         For nX := 1 To nf
//             cMsg += aDocsCarg[3,nX] + CRLF
//         Next nX
//         If lCalcAuto == .F. .AND. lHelp
//             Help( ,, 'CÃ¡lculo de Frete',, cMsg, 1, 0)
//         EndIf
//         Return .F.
//     ElseIf aDocsCarg[1] == 1
//         cMsg := "As seguintes situaÃ§Ãµes impedem o recÃ¡lculo de alguns documentos relacionados:" + CRLF
//         nF := Len(aDocsCarg[3])
//         For nX := 1 To nF
//             cMsg += aDocsCarg[3,nX] + CRLF
//         Next nX
//         If lCalcAuto == .F. .AND. lHelp .And. !IsBlind() .And. !MsgYesNo(cMsg +  "Deseja prosseguir?")
//             cMsg := ""
//             Return .F.
//         EndIf
//     EndIf
//     // InÃ­cio Ponto de Entrada Britania
//     If ExistBlock("XGFECALI")
//         aRotAdic := ExecBlock("XGFECALI",.F.,.F.,{GWN->GWN_NRROM})
//     EndIf
//     // Fim Ponto de Entrada Britania
//     RestArea(aAreaGWN)
// 
//     GWN->(dbSetOrder(1))
//     If GWN->(dbSeek(xFilial("GWN") + GWN->GWN_NRROM))
// 
//         aAdd(aAgrFrt, { GWN->GWN_NRROM ,; //Numero do Agrupador
//         GWN->GWN_CDTRP ,; //Transportador
//         GWN->GWN_CDTPVC,; //Tipo de Veiculo
//         GWN->GWN_CDCLFR,; //ClassIficacao de Frete
//         GWN->GWN_CDTPOP,; //Tipo de Operacao
//         GWN->GWN_DISTAN,; //Distancia Percorrida
//         GWN->GWN_NRCIDD,; //Cidade Destino
//         GWN->GWN_CEPD,;   //CEP Destino
//         '0'})             //ERRO
// 
//         aDocCarg := {}
//         aItDoc   := {}
//         aTrchDoc := {}
//         aNoCalc  := {}
// 
//         GF50ARCLC(aDocsCarg,aDocCarg,aItDoc,aTrchDoc,aNoCalc)
//     EndIf
// 
//     If (Len(aTrchDoc) == 0 .Or. Len(aItDoc) == 0) .And. aDocsCarg[1] != 2
//         cMsg := "Documento de Carga nÃ£o possui item ou trecho."
//         If lCalcAuto == .F. .And. lHelp
//             Help( ,, 'HELP',, cMsg, 1, 0)
//         EndIf
//         Return .F.
//     EndIf
// 
//     // Executa o cÃ¡lculo e armazena o retorno em um vetor
//     // [1] Sucesso (True/NÃ£o)
//     // [2] Arquivo de log
//     // [3] Array de Erros
//     /*param  aAgrFrt        Agrupadores de Frete -> Romaneios
//     param  aDocCarg       Documentos de Carga -> NF, etc.
//     param  aTrchDoc       Trechos do Documento de Carga
//     param  aItDoc         Itens do Documento de Carga
//     param  [aTblFrt]      Tabela de Frete
//     param  [lReal]        Calculo Real? (ou simulacao) default = .T.
//     param  [iLogProc]     Apresenta log ao final do processo? 0: NÃ£o apresentar, 1: Somente erros, 2: Sempre
//     param  [lTabProv]     CÃ¡lculo de ProvisÃ£o? default = .F.
//     param  [lParCons]     Considerar Tabelas de frete com a situaÃ§Ã£o 'Em negociaÃ§Ã£o'? default = .F.
//     param  [iTpSimul]     Tipo de simulaÃ§Ã£o: 0=simulaÃ§Ã£o geral, 1=simulaÃ§Ã£o especÃ­fica
//     param  lCalcLote       Recebe ".T." se rotina que chamou a funÃ§Ã£o Ã© GFEA081.
//     param    lHideProgress    Esconde a barra de progresso
// 
//     @sample GFECLCFRT(aAgrFrt, aDocCarg, aTrchDoc, aItDoc, aTblFrt, lReal, iLogProc, nTabProv, lParCons, iTpSimul, lCalcLote, lHideProgress, // lLog, lServ, pServTpImp, pCalcDataBase) */
// 
//     aAgrFrt2  := aClone(aAgrFrt)
//     aDocCarg2 := aClone(aDocCarg)
//     aTrchDoc2 := aClone(aTrchDoc) 
//     aItDoc2   := aClone(aItDoc)
// 
//     If aDocsCarg[1] != 2
//         //Ponto de Entrada NegociaÃ§Ã£o de Frete
//         If ExistBlock("GFE05010")
//             aItDoc := ExecBlock("GFE05010",.f.,.f.,{GWN->GWN_PLACAD,aItDoc})
//         EndIf
//         //Fim Ponto de Entrada
// 
//         aRetGXT := GFEA50GXT()        
//         aRetCalc := GFECLCFRT(aAgrFrt, aDocCarg, aTrchDoc, aItDoc, IIF(aRetGXT[1]== .T.,aRetGXT[2],Nil), .T.,If( lCalcAuto .OR. !lHelp ,0,// 2),,,,,lCalcAuto .OR. !lHelp,lLog, /* lServ */, /* pServTpImp */, lDatabase,aNoCalc)
//         
//         lCalcrom := aRetCalc[1]
//         cArqLog := aRetCalc[2]
//         If aRetCalc[1]
//             GWN->(dbSetOrder(1))
//             If GWN->(dbSeek(xFilial("GWN") + aAgrFrt[1,1]))
//                 RecLock('GWN', .F. )
//                     GWN->GWN_CALC   := "1"
//                     GWN->GWN_MTCALC := "Calculado com sucesso"
//                     If lDatabase
//                         GWN->GWN_DTCALC := DDATABASE
//                     Else
//                         GWN->GWN_DTCALC := Date()
//                     EndIf
// 
//                     GWN->GWN_HRCALC := SubStr(TIME(), 1, 5)                
// 
//                     If  !Empty(GWN->GWN_DTSAI) .AND. !Empty(GWN->GWN_HRSAI)
//                         PrevEntreg(GWN->GWN_FILIAL, GWN->GWN_NRROM, GWN->GWN_DTSAI, GWN->GWN_HRSAI)
//                     EndIf
//                     
//                     If GFXCP12127("GXY_NRCT")
//                     
//                         GWF->(dbSetOrder(04) )
//                         GWF->(dbSeek(xFilial("GWF")+GWN->GWN_NRROM) ) 
//                         Do While GWF->(!Eof()) .And. GWF->GWF_FILIAL == xFilial("GWF") .And. GWF->GWF_NRROM == GWN->GWN_NRROM
//                             GXY->(dbSetOrder(2))
//                             GXY->(dbSeek(GWF->GWF_FILIAL+GWF->GWF_NRCALC))
//                             Do While GXY->(!Eof() ) .And. GXY->GXY_FILCA == GWF->GWF_FILIAL .And. GXY->GXY_NRCALC == GWF->GWF_NRCALC
//                                 GWN->GWN_NRCT := GXY->GXY_NRCT
//                                 GXY->(dbSkip())
//                             EndDo
//                         
//                             GWF->(dbSkip())
//                         EndDo
//                     EndIf
//                 
//                 GWN->(MsUnlock())
//             EndIf
//             
//             If cMV_GFE005 == "2"
//                 nF := Len(aDFReConf)
//                 For nX := 1 To nF
//                     GW3->(dbSetOrder(1))
//                     If GW3->(dbSeek(aDFReConf[nX][1] + aDFReConf[nX][2] + aDFReConf[nX][3] + aDFReConf[nX][4] + aDFReConf[nX][5] + aDFReConf// [nX][6]))
//                         GFE50DFCONF()
//                     EndIf
//                 Next nX
//             EndIF
//         Else
//             GWN->(dbSetOrder(1))
//             If GWN->(dbSeek(xFilial("GWN") + aAgrFrt[1,1]))
//                 RecLock('GWN', .F. )
//                     GWN->GWN_CALC   := "3"
//                     
//                     aErr:= GFECalcErr(aRetCalc[3][1][2])
//                     nF := Len(aRetCalc[3][1][4])
//                     For nY:= 1 To nF
//                         aErr[1] := StrTran(aErr[1],"[" + cValToChar(nY) + "]",aRetCalc[3][1][4][nY])
//                     Next nY
//                     
//                     GWN->GWN_MTCALC := " " + aErr[1] + CRLF + "----" + CRLF
//                 
//                     If Empty(GWN->GWN_MTCALC)
//                         GWN->GWN_MTCALC := "Falha no cÃ¡lculo"
//                     EndIf
//                     GWN->GWN_DTCALC := CToD("  /  /    ")
//                     GWN->GWN_HRCALC := ""
//                 GWN->( MsUnLock() )
//                 
//                 If  !Empty(GWN->GWN_DTSAI) .AND. !Empty(GWN->GWN_HRSAI)
//                     PrevEntreg(GWN->GWN_FILIAL, GWN->GWN_NRROM, GWN->GWN_DTSAI, GWN->GWN_HRSAI)
//                 EndIf
//             EndIf
//         EndIf
//     Else    
//         lCalcrom := .T. //Significa que jÃ¡ foi recebido os documentos de frete do cÃ¡lculo normal/redespacho
//     EndIf
//     
//     If lCalcrom .And. GFXCP12117("GV9_TPIMP") == .T. 
//         aTblFrFUNB := {}
//         cAliasQry := GetNextAlias()
//         BeginSql Alias cAliasQry
//             SELECT GWG.GWG_CDEMIT,
//                     GWG.GWG_NRTAB,
//                     GWG.GWG_NRNEG,
//                     GWG.GWG_NRROTA,
//                     GWG.GWG_CDFXTV,
//                     GWF.R_E_C_N_O_ AS RECNOGWF
//             FROM %Table:GWF% GWF
//             INNER JOIN %Table:GWG% GWG
//             ON GWG.GWG_FILIAL = GWF.GWF_FILIAL
//             AND GWG.GWG_NRCALC = GWF.GWF_NRCALC
//             AND GWG.%NotDel%
//             WHERE GWF.GWF_FILIAL = %xFilial:GWF%
//             AND GWF.GWF_NRROM = %Exp:GWN->GWN_NRROM%
//             AND GWF.%NotDel%
//             GROUP BY GWG.GWG_CDEMIT,
//                         GWG.GWG_NRTAB,
//                         GWG.GWG_NRNEG,
//                         GWG.GWG_NRROTA,
//                         GWG.GWG_CDFXTV,
//                         GWF.R_E_C_N_O_
//         EndSql
//         Do While (cAliasQry)->(!Eof())
//             GWF->(dbGoTo( (cAliasQry)->RECNOGWF ))
// 
//             If GWF->GWF_TPCALC == "7" .And. ChkCompServ() // Verifica se o calculo anterior usado teve componentes de serviÃ§o, se sim exclui // calculo
//                 GFEDelCalc( GWF->GWF_NRCALC )    // Apaga o calculo de frete e seus relacionamentos, incluindo movimentos contÃ¡beis
//             Else
//                 aADD(aTblFrFUNB,{GWN->GWN_NRROM,(cAliasQry)->GWG_NRTAB,(cAliasQry)->GWG_NRNEG,(cAliasQry)->GWG_NRROTA,(cAliasQry)->GWG_CDFXTV,// (cAliasQry)->GWG_CDEMIT})
//             EndIf
// 
//             (cAliasQry)->(dbSkip())
//         EndDo
//         (cAliasQry)->(dbCloseArea())
// 
//         aTcomps := GFEXCOMP(aTblFrFUNB)
//         
//         aDocsCarg := GF50VLROM(GWN->GWN_NRROM,lCalcAuto,"SERVICO")
//         
//         aDocCarg := {}
//         aItDoc   := {}
//         aTrchDoc := {}
//         aNoCalc  := {}
//         
//         If aDocsCarg[1] == 2
//             cMsg := "NÃ£o foi possÃ­vel recalcular nenhum serviÃ§o para documentos relacionados ao romaneio. Motivos:" + CRLF
//             nF := Len(aDocsCarg[3])
//             For nX := 1 To nF
//                 cMsg += aDocsCarg[3,nX] + CRLF
//             Next nX 
//             If lCalcAuto == .F. .AND. lHelp
//                 Help( ,, 'HELP',, cMsg, 1, 0)
//             EndIf
//             Return .F.
//         EndIf
//         
//         GF50ARCLC(aDocsCarg,aDocCarg,aItDoc,aTrchDoc,aNoCalc)//Alimenta os arrays do cÃ¡lculo
//     
//         aDocCarg2 := aClone(aDocCarg)
//         aTrchDoc2 := aClone(aTrchDoc) 
//         aItDoc2 := aClone(aItDoc)
//     
//         If !Empty(aTblFrFUNB)
//             GV9->(dbSetOrder(1))
//             If GV9->(dbSeek(xFilial("GV9")+aTblFrFUNB[1][6]+aTblFrFUNB[1][2]+aTblFrFUNB[1][3])) //GV9_FILIAL+GV9_CDEMIT+GV9_NRTAB+GV9_NRNEG
//                 If Empty(GV9->GV9_TPIMP)
//                     cGU5_TPIMP := '1'
//                 Else
//                     cGU5_TPIMP := GV9->GV9_TPIMP
//                 EndIf
//             EndIf
// 
//             If Len(aTcomps) > 0 .And. aTcomps[1][5] == .T.
//                 GFEServFrete({}, aAgrFrt2, aDocCarg2, aTrchDoc2, aItDoc2, nQtPern, cNrOcor, IsInCallStack('GFEA117'), cGU5_TPIMP, ,.f.,.f.,// lCalcAuto .OR. !lHelp,aNoCalc) //FunÃ§Ã£o que realiza o cÃ¡lculo de serviÃ§o
//             EndIf    
//         EndIf
//         
//     EndIf
// 
//     // InÃ­cio Ponto de Entrada Britania
//     If ExistBlock("XGFECALF")
//         aRotAdic := ExecBlock("XGFECALF",.F.,.F.,{GWN->GWN_NRROM})
//     EndIf
//     // Fim Ponto de Entrada Britania
// 
//     //Ponto de entrada validaÃ§Ã£o Vicunha
//     If ExistBlock("GFEA0508")
//         ExecBlock("GFEA0508",.F.,.F.)
//     EndIf
// Return lCalcRom
// 
// Static Function PosicionaGWP(lHelp,cMsg)
//     Local lRet    := .T.
//     Local aArea   := GetArea()
//     Local cAlBkp  := Alias()
// 
//     Default lHelp := .T.
//     Default cMsg  := ""
// 
//     GWP->(dbOrderNickName('VIAGEM'))
//     If !GWP->(dbSeek(xFilial('GWP') + GWN->GWN_VIAGEM))
//         cMsg := 'Viagem ' + GWN->GWN_VIAGEM + ' nÃ£o localizada'
//         If lHelp
//             GfeMsgErro(cMsg)
//         EndIf
//         lRet := .F.
//     EndIf
//     RestArea(aArea)
// 
//     If cAlBkp != Nil .And. !Empty(cAlBkp)
//         dbSelectArea(cAlBkp)
//     EndIf
// Return lRet
// 
// /*/{Protheus.doc} GF50VLROM
//     FunÃ§Ã£o que valida e lista os trechos que poderÃ£o ser recalculados.
// @type function
// @author siegklenes.beulke
// @since 20/09/2016
// @version 1.0
// @param cNrRom, character, NÃºmero do Romaneio
// @param lCalcAuto, logical, Uso dde quando utilizar o cÃ¡lculo automÃ¡tico
// /*/
// Static Function GF50VLROM(cNrRom,lCalcAuto,cCalculando)
//     Local cAlQuery     := ""
//     Local cAlQryGWO    := ""
//     Local cQyGWF       := ""
//     Local aRet         := {0,{},{},{}} // 0=Todos poderÃ£o ser recalculados; 1=alguns poderÃ£o ser recalculados; 2= Nenhum poderÃ¡ ser // recalculado; 3= Romaneio calculado no ERP
//     Local nCount       := 0
//     Local nCntErro     := 0
//     Local nF           := 0
//     Local nX           := 0
//     Local nY           := 0
//     Local nPos         := 0
//     Local cTrecho      := ""
//     Local cQuery       := ""
//     Local lOk          := .F.
//     Local cGWF_TPCALC  := ""
//     Local cGWF_NROCO   := ""
//     Local cGWF_NRPREF  := ""
//     Local cMV_DPSERV   := SuperGetMV("MV_DPSERV", .F., "1")
//     Local cGW3SIT      := ''
//     Local lCheck       := GFXCP12116("GWF","GWF_EMISDF") == .T. .And. cMV_DPSERV == "1"
//     Local cCampos       := ""
//     Local clftGW4       := ""
//     Local cWhere       := ""
//     Local lVerifTrecho := .T.
// 
//     If lCheck
//         cCampos := " GW4.GW4_NRDC,"
//         cCampos += " GWF.GWF_FILIAL GW3_FILIAL,"
//         cCampos += " GWF.GWF_NRDF GW3_NRDF," 
//         cCampos += " GWF.GWF_CDESP GW3_CDESP,"
//         cCampos += " GWF.GWF_EMISDF GW3_EMISDF,"
//         cCampos += " GWF.GWF_SERDF GW3_SERDF,"
//         cCampos += " GWF.GWF_DTEMDF GW3_DTEMIS"
// 
//         clftGW4 := " AND GW4.GW4_EMISDF = GWF.GWF_EMISDF"
//         clftGW4 += " AND GW4.GW4_CDESP = GWF.GWF_CDESP"
//         clftGW4 += " AND GW4.GW4_SERDF = GWF.GWF_SERDF"
//         clftGW4 += " AND GW4.GW4_NRDF = GWF.GWF_NRDF"
//         clftGW4 += " AND GW4.GW4_DTEMIS = GWF.GWF_DTEMDF"
//     Else
//         cCampos := "GW4.GW4_NRDC,"
//         cCampos += "GW3.GW3_FILIAL,"
//         cCampos += "GW3.GW3_NRDF," 
//         cCampos += "GW3.GW3_CDESP,"
//         cCampos += "GW3.GW3_EMISDF,"
//         cCampos += "GW3.GW3_SERDF,"
//         cCampos += "GW3.GW3_DTEMIS"        
// 
//         cQuery := " LEFT JOIN " + RetSqlName("GW3") + " GW3"
//         cQuery += " ON GW3_FILIAL = '" + xFilial("GW3") + "'"
//         cQuery += " AND GW4_EMISDF = GW3_EMISDF"
//         cQuery += " AND GW4_CDESP = GW3_CDESP"
//         cQuery += " AND GW4_SERDF = GW3_SERDF"
//         cQuery += " AND GW4_NRDF  = GW3_NRDF"
//         cQuery += " AND GW4_DTEMIS = GW3_DTEMIS"
//         cQuery += " AND GW3_TPDF = GWF_TPCALC"
//         cQuery += " AND GW3.D_E_L_E_T_ = ' '" 
//     EndIf
// 
//     If GFXCP1212210('GW1_FILROM')
//         cWhere += " GW1.GW1_FILROM = '" + xFilial("GW1") + "'"
//     Else
//         cWhere += " GW1.GW1_FILIAL = '" + xFilial("GW1") + "'"
//     EndIf
//     cWhere += " AND GW1.GW1_NRROM = '" + cNrRom + "'"
// 
//     cCampos := "%" + cCampos + "%"
//     cQuery  := "%" + cQuery + "%"
//     cWhere  := "%" + cWhere + "%"
//     clftGW4 := "%" + clftGW4 + "%"
// 
//     cAlQuery := GetNextAlias()
// 
//     BeginSQL Alias cAlQuery
//         SELECT DISTINCT GW1.R_E_C_N_O_ GW1_RECNO,
//                         GW1.GW1_EMISDC,
//                         GW1.GW1_SERDC,
//                         GW1.GW1_NRDC,
//                         GW1.GW1_CDTPDC,
//                         GW1.GW1_CDREM,
//                         GW1.GW1_CDDEST,
//                         GW1.GW1_ENTEND,
//                         GW1.GW1_ENTBAI,
//                         GW1.GW1_ENTNRC,
//                         GW1.GW1_ENTCEP,
//                         GW1.GW1_NRREG,
//                         GW1.GW1_TPFRET,
//                         GW1.GW1_ICMSDC,
//                         GW1.GW1_USO,
//                         GW1.GW1_CARREG,
//                         GW1.GW1_NRROM,
//                         GW1.GW1_QTVOL,
//                         GW1.GW1_FILIAL,
//                         GW4.GW4_EMISDF,
//                         GWF.GWF_FILIAL,
//                         GWF.GWF_NRCALC,
//                         GWU.GWU_SEQ,
//                         %Exp: cCampos%
//         FROM %Table:GW1% GW1
//         INNER JOIN %Table:GWU% GWU
//         ON GWU.GWU_FILIAL = GW1.GW1_FILIAL
//         AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC 
//         AND GWU.GWU_EMISDC = GW1.GW1_EMISDC
//         AND GWU.GWU_SERDC = GW1.GW1_SERDC
//         AND GWU.GWU_NRDC = GW1.GW1_NRDC
//         AND GWU.%NotDel%
//         LEFT JOIN %Table:GWH% GWH 
//         ON GWH.GWH_FILIAL = GW1.GW1_FILIAL
//         AND GWH.GWH_CDTPDC = GW1.GW1_CDTPDC 
//         AND GWH.GWH_EMISDC = GW1.GW1_EMISDC 
//         AND GWH.GWH_SERDC = GW1.GW1_SERDC 
//         AND GWH.GWH_NRDC = GW1.GW1_NRDC
//         AND GWH.GWH_TRECHO = GWU.GWU_SEQ
//         AND GWH.%NotDel%
//         LEFT JOIN %Table:GWF% GWF 
//         ON GWF.GWF_FILIAL = GWH.GWH_FILIAL 
//         AND GWF.GWF_NRCALC = GWH.GWH_NRCALC
//         AND GWF.%NotDel%
//         LEFT JOIN %Table:GW4% GW4 
//         ON GW4.GW4_FILIAL = GWF.GWF_FILIAL
//         %Exp:clftGW4%
//         AND GW4.GW4_EMISDC = GW1.GW1_EMISDC
//         AND GW4.GW4_SERDC = GW1.GW1_SERDC
//         AND GW4.GW4_NRDC = GW1.GW1_NRDC
//         AND GW4.GW4_TPDC = GW1.GW1_CDTPDC
//         AND GW4.%NotDel%
//         %Exp:cQuery%
//         WHERE %Exp:cWhere%
//         AND GW1.GW1_SIT IN ('4','5')
//         AND GW1.%NotDel%        
//         ORDER BY GW1.R_E_C_N_O_, GWU.GWU_SEQ
//     EndSQL
// 
//     Do While (cAlQuery)->(!Eof())
//         
//         nCount++
// 
//         cQyGWF := GetNextAlias()
//         
//         If cCalculando == "ROMANEIO"
//             cQuery := " AND GWF.GWF_TPCALC IN ('1','6')"
//         Else
//             cQuery := " AND GWF.GWF_TPCALC IN ('7')"
//             cQuery += " AND GWF.GWF_NROCO = ' '" 
//         EndIf
// 
//         cQuery := "%" + cQuery + "%"
// 
//         BeginSQL Alias cQyGWF
//             SELECT GWF.GWF_FILIAL, 
//                    GWF.GWF_NRCALC, 
//                    GW4.GW4_NRDF, 
//                    GWH.GWH_NRCALC, 
//                    GW4.GW4_NRDC
//             FROM %Table:GWF% GWF
//             INNER JOIN %Table:GWH% GWH 
//             ON GWH.GWH_FILIAL = GWF.GWF_FILIAL
//             AND GWH.GWH_NRCALC = GWF.GWF_NRCALC 
//             AND GWH.%NotDel%
//             INNER JOIN %Table:GW4% GW4 
//             ON GW4.GW4_FILIAL = GWH.GWH_FILIAL
//             AND GW4.GW4_TPDC = GWH.GWH_CDTPDC
//             AND GW4.GW4_EMISDC = GWH.GWH_EMISDC
//             AND GW4.GW4_SERDC = GWH.GWH_SERDC
//             AND GW4.GW4_NRDC = GWH.GWH_NRDC
//             AND GW4.%NotDel%
//             WHERE GWF.GWF_FILIAL = %Exp:(cAlQuery)->GWF_FILIAL%
//             AND GWF.GWF_NRCALC = %Exp:(cAlQuery)->GWF_NRCALC%
//             AND GWF.GWF_SEQTRE = %Exp:(cAlQuery)->GWU_SEQ%
//             AND GW4.GW4_EMISDC = %Exp:(cAlQuery)->GW1_EMISDC%
//             AND GW4.GW4_SERDC = %Exp:(cAlQuery)->GW1_SERDC%
//             AND GW4.GW4_NRDC = %Exp:(cAlQuery)->GW1_NRDC%
//             AND GW4.GW4_TPDC = %Exp:(cAlQuery)->GW1_CDTPDC%
//             AND GWF.%NotDel%
//             %Exp:cQuery%
//         EndSQL
//         
//         If (cQyGWF)->(!Eof()) .Or. Empty((cAlQuery)->GWF_NRCALC) 
//             cGW3SIT := ''
//             
//             If !Empty((cAlQuery)->GW3_NRDF)
//                 GW3->(dbSetOrder(1))
//                 GW3->(dbSeek((cAlQuery)->GW3_FILIAL + (cAlQuery)->GW3_CDESP + (cAlQuery)->GW3_EMISDF + (cAlQuery)->GW3_SERDF + (cAlQuery)// ->GW3_NRDF + (cAlQuery)->GW3_DTEMIS))
//                 cGW3SIT := GW3->GW3_SIT
//             EndIf
// 
//             If (!Empty((cAlQuery)->GW3_NRDF) .And. ;
//                 (cMV_GFE005 == "1" .Or. (cMV_GFE005 == "2" .And. cGW3SIT $ "34")))
//                 nCntErro++
//                 aRet[1] := 1
//                 aAdd(aRet[2],{.F.,"HÃ¡ documentos de carga vinculados a documento de frete. Os novos cÃ¡lculos gerados podem apresentar // valores diferentes do cÃ¡lculo original.",(cAlQuery)->GW1_RECNO,;
//                                 (cAlQuery)->GW1_EMISDC,;
//                                 (cAlQuery)->GW1_SERDC ,;
//                                 (cAlQuery)->GW1_NRDC  ,;
//                                 (cAlQuery)->GW1_CDTPDC,;
//                                 (cAlQuery)->GW1_CDREM ,;
//                                 (cAlQuery)->GW1_CDDEST,;
//                                 (cAlQuery)->GW1_ENTEND,;
//                                 (cAlQuery)->GW1_ENTBAI,;
//                                 (cAlQuery)->GW1_ENTNRC,;
//                                 (cAlQuery)->GW1_ENTCEP,;
//                                 (cAlQuery)->GW1_NRREG ,;
//                                 (cAlQuery)->GW1_TPFRET,;
//                                 (cAlQuery)->GW1_ICMSDC,;
//                                 (cAlQuery)->GW1_USO   ,;
//                                 (cAlQuery)->GW1_CARREG,;
//                                 (cAlQuery)->GW1_NRROM ,;
//                                 (cAlQuery)->GW1_QTVOL ,;
//                                 (cAlQuery)->GWF_NRCALC,;
//                                 (cAlQuery)->GWU_SEQ,;
//                                 (cAlQuery)->GW4_NRDC,;
//                                 (cAlQuery)->GW4_EMISDF,;
//                                 (cAlQuery)->GW3_NRDF,;
//                                 (cAlQuery)->GW1_FILIAL })
// 
//                 aAdd(aRet[3],"HÃ¡ documentos de carga vinculados a documento de frete. Os novos cÃ¡lculos gerados podem apresentar valores // diferentes do cÃ¡lculo original.")
//                 aAdd(aRet[4],(cAlQuery)->GWF_NRCALC)
//                 (cAlQuery)->( dbSkip() )
//                 (cQyGWF)->(dbCloseArea())
//                 Loop
//             EndIf
// 
//             If cGW3SIT $ '12'
//                 If !Empty((cAlQuery)->GW3_NRDF)
//                     If ASCAN(aDFReConf,{|X| X[1] == (cAlQuery)->GW3_FILIAL .And.;
//                                             X[2] == (cAlQuery)->GW3_CDESP  .And.;
//                                             X[3] == (cAlQuery)->GW3_EMISDF .And.;
//                                             X[4] == (cAlQuery)->GW3_SERDF  .And.;
//                                             X[5] == (cAlQuery)->GW3_NRDF   .And.;
//                                             X[6] == (cAlQuery)->GW3_DTEMIS}) == 0
//                     
//                         aAdd(aDFReConf, {(cAlQuery)->GW3_FILIAL,;
//                                             (cAlQuery)->GW3_CDESP,;
//                                             (cAlQuery)->GW3_EMISDF,;
//                                             (cAlQuery)->GW3_SERDF,;
//                                             (cAlQuery)->GW3_NRDF,;
//                                             (cAlQuery)->GW3_DTEMIS})
//                     EndIf
// 
//                 ElseIf lCheck .And. !Empty((cAlQuery)->GW4B_NRDF)
//                     nPos := ASCAN(aDFReConf,{|X| X[1] == (cAlQuery)->GW4B_FILIAL .And.;
//                                                  X[2] == (cAlQuery)->GW4B_CDESP  .And.;
//                                                  X[3] == (cAlQuery)->GW4B_EMISDF .And.;
//                                                  X[4] == (cAlQuery)->GW4B_SERDF  .And.;
//                                                  X[5] == (cAlQuery)->GW4B_NRDF   .And.;
//                                                  X[6] == (cAlQuery)->GW4B_DTEMIS})
//                     
//                     If nPos == 0
//                         aAdd(aDFReConf, {(cAlQuery)->GW4B_FILIAL,;
//                                          (cAlQuery)->GW4B_CDESP,;
//                                          (cAlQuery)->GW4B_EMISDF,;
//                                          (cAlQuery)->GW4B_SERDF,;
//                                          (cAlQuery)->GW4B_NRDF,;
//                                          (cAlQuery)->GW4B_DTEMIS})
//                     EndIf
//                 EndIf
//             EndIf
// 
//             (cAlQuery)->(aAdd(aRet[2],{.T.,"OK",GW1_RECNO,;
//                                         GW1_EMISDC,;
//                                         GW1_SERDC ,;
//                                         GW1_NRDC  ,;
//                                         GW1_CDTPDC,;
//                                         GW1_CDREM ,;
//                                         GW1_CDDEST,;
//                                         GW1_ENTEND,;
//                                         GW1_ENTBAI,;
//                                         GW1_ENTNRC,;
//                                         GW1_ENTCEP,;
//                                         GW1_NRREG ,;
//                                         GW1_TPFRET,;
//                                         GW1_ICMSDC,;
//                                         GW1_USO   ,;
//                                         GW1_CARREG,;
//                                         GW1_NRROM ,;
//                                         GW1_QTVOL ,;
//                                         GWF_NRCALC,;
//                                         GWU_SEQ,;
//                                         "",;
//                                         "",;
//                                         "",;
//                                         GW1_FILIAL}))
//         EndIf
//         (cQyGWF)->(dbCloseArea())
//         
//         (cAlQuery)->(dbSkip())
//     EndDo
//     (cAlQuery)->(DbCloseArea())
// 
//     If lCheck
//         cCampos := " GWF.GWF_FILIAL,"
//         cCampos += " GWF.GWF_CDESP,"
//         cCampos += " GWF.GWF_EMISDF,"
//         cCampos += " GWF.GWF_SERDF,"
//         cCampos += " GWF.GWF_NRDF,"
//         cCampos += " GWF.GWF_DTEMDF
// 
//         cQuery := " AND GW4.GW4_EMISDF = GWF.GWF_EMISDF"
//         cQuery += " AND GW4.GW4_CDESP = GWF.GWF_CDESP"
//         cQuery += " AND GW4.GW4_SERDF = GWF.GWF_SERDF"
//         cQuery += " AND GW4.GW4_NRDF = GWF.GWF_NRDF"
//         cQuery += " AND GW4.GW4_DTEMIS = GWF.GWF_DTEMDF"
//     Else
//         cCampos := " GW4.GW4_FILIAL GWF_FILIAL,"
//         cCampos += " GW4.GW4_CDESP AS GWF_CDESP,"
//         cCampos += " GW4.GW4_EMISDF AS GWF_EMISDF,"
//         cCampos += " GW4.GW4_SERDF AS GWF_SERDF,"
//         cCampos += " GW4.GW4_NRDF AS GWF_NRDF,"
//         cCampos += " GW4.GW4_DTEMIS AS GWF_DTEMDF"
// 
//         cQuery := ""
//     EndIf
// 
//     cCampos := "%" + cCampos + "%"
//     cQuery  := "%" + cQuery + "%"
// 
//     cAlQuery := GetNextAlias()
//     
//     BeginSQL Alias cAlQuery
//         SELECT DISTINCT GW1.R_E_C_N_O_ GW1_RECNO,
//                         GW1.GW1_EMISDC,
//                         GW1.GW1_SERDC,
//                         GW1.GW1_NRDC,
//                         GW1.GW1_CDTPDC,
//                         GW1.GW1_CDREM,
//                         GW1.GW1_CDDEST,
//                         GW1.GW1_ENTEND,
//                         GW1.GW1_ENTBAI,
//                         GW1.GW1_ENTNRC,
//                         GW1.GW1_ENTCEP,
//                         GW1.GW1_NRREG,
//                         GW1.GW1_TPFRET,
//                         GW1.GW1_ICMSDC,
//                         GW1.GW1_USO,
//                         GW1.GW1_CARREG,
//                         GW1.GW1_NRROM,
//                         GXD.GXD_CODLOT,
//                         GWU.GWU_PAGAR,
//                         GW1.GW1_QTVOL,
//                         GWF.GWF_ORIGEM,
//                         GWF.GWF_TPCALC,
//                         GWF.GWF_NRCALC,
//                         GWF.GWF_NRPREF,
//                         GWU.GWU_SEQ,
//                         GWF.GWF_TRANSP,
//                         GWF.GWF_NROCO,
//                         GW1.GW1_FILIAL,
//                         %Exp:cCampos%    
//         FROM %Table:GW1% GW1
//         INNER JOIN %Table:GWU% GWU
//         ON GWU.GWU_FILIAL = GW1.GW1_FILIAL
//         AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC
//         AND GWU.GWU_EMISDC = GW1.GW1_EMISDC
//         AND GWU.GWU_SERDC = GW1.GW1_SERDC
//         AND GWU.GWU_NRDC = GW1.GW1_NRDC
//         AND GWU.%NotDel%
//         LEFT JOIN %Table:GWH% GWH 
//         ON GWH.GWH_FILIAL = GW1.GW1_FILIAL
//         AND GWH.GWH_CDTPDC = GW1.GW1_CDTPDC
//         AND GWH.GWH_EMISDC = GW1.GW1_EMISDC
//         AND GWH.GWH_SERDC = GW1.GW1_SERDC
//         AND GWH.GWH_NRDC = GW1.GW1_NRDC
//         AND GWH.%NotDel%
//         LEFT JOIN %Table:GWF% GWF
//         ON GWF.GWF_FILIAL = GWH.GWH_FILIAL 
//         AND GWF.GWF_NRCALC = GWH.GWH_NRCALC
//         AND GWF.GWF_SEQTRE = GWU.GWU_SEQ
//         AND GWF.%NotDel%
//         LEFT JOIN %Table:GW4% GW4 
//         ON GW4.GW4_FILIAL = GWF.GWF_FILIAL
//         %Exp:cQuery%
//         AND GW4.GW4_EMISDC = GW1.GW1_EMISDC
//         AND GW4.GW4_SERDC = GW1.GW1_SERDC
//         AND GW4.GW4_NRDC = GW1.GW1_NRDC
//         AND GW4.GW4_TPDC = GW1.GW1_CDTPDC
//         AND GW4.%NotDel%
//         LEFT JOIN %Table:GXD% GXD 
//         ON GXD.GXD_FILCAL = GWH.GWH_FILIAL 
//         AND GXD.GXD_NRCALC = GWH.GWH_NRCALC
//         AND GXD.%NotDel%
//         WHERE %Exp:cWhere%
//         AND GW1.GW1_SIT IN ('4','5')
//         AND GW1.%NotDel%
//         ORDER BY GW1.R_E_C_N_O_, GWF.GWF_NRCALC DESC, GWU.GWU_SEQ
//     EndSQL
// 
//     Do While (cAlQuery)->(!Eof())
//         
//         cGWF_TPCALC    := (cAlQuery)->GWF_TPCALC // 1=Normal;2=Compl Valor;3=Compl Imposto;4=Reentrega;5=Devolucao;6=Redespacho;7=Servico;// 8=Estimativa
//         cGWF_NROCO    := (cAlQuery)->GWF_NROCO
//         cGWF_NRPREF    := (cAlQuery)->GWF_NRPREF
//         CGW1_TPFRET := (cAlQuery)->GW1_TPFRET
//         CGWU_PAGAR    := (cAlQuery)->GWU_PAGAR
//         
//         If CGWU_PAGAR != "2"
//             lVerifTrecho := .F.
//         EndIf
//         nCount++
//         
//         If cCalculando == "ROMANEIO"
//             lOk := ((cGWF_TPCALC=="1") .OR. (cGWF_TPCALC=="6")) .OR. (CGWU_PAGAR == '2' .AND. CGW1_TPFRET == '3')
//         Else
//             lOk := ((cGWF_TPCALC=="7") .AND. Empty(cGWF_NROCO))
//         EndIf
// 
//         If lOk
//             If !Empty(cGWF_NRPREF)
//                 nCntErro++
//                 aRet[1] := 1
//                 aAdd(aRet[2],{.F.,"HÃ¡ cÃ¡lculos vinculados a PrÃ©-Faturas. Os novos cÃ¡lculos gerados podem apresentar valores diferentes do // cÃ¡lculo original.",(cAlQuery)->GW1_RECNO,;
//                                 (cAlQuery)->GW1_EMISDC,;
//                                 (cAlQuery)->GW1_SERDC ,;
//                                 (cAlQuery)->GW1_NRDC  ,;
//                                 (cAlQuery)->GW1_CDTPDC,;
//                                 (cAlQuery)->GW1_CDREM ,;
//                                 (cAlQuery)->GW1_CDDEST,;
//                                 (cAlQuery)->GW1_ENTEND,;
//                                 (cAlQuery)->GW1_ENTBAI,;
//                                 (cAlQuery)->GW1_ENTNRC,;
//                                 (cAlQuery)->GW1_ENTCEP,;
//                                 (cAlQuery)->GW1_NRREG ,;
//                                 (cAlQuery)->GW1_TPFRET,;
//                                 (cAlQuery)->GW1_ICMSDC,;
//                                 (cAlQuery)->GW1_USO   ,;
//                                 (cAlQuery)->GW1_CARREG,;
//                                 (cAlQuery)->GW1_NRROM ,;
//                                 (cAlQuery)->GW1_QTVOL ,;
//                                 (cAlQuery)->GWF_NRCALC,;
//                                 (cAlQuery)->GWU_SEQ,;
//                                 (cAlQuery)->GWF_NRDF,;
//                                 (cAlQuery)->GWF_TRANSP,;
//                                 (cAlQuery)->GWF_NRDF,;
//                                 (cAlQuery)->GW1_FILIAL })
//                 
//                 aAdd(aRet[3],"HÃ¡ cÃ¡lculos vinculados a PrÃ©-Faturas. Os novos cÃ¡lculos gerados podem apresentar valores diferentes do // cÃ¡lculo original.")
//                 aAdd(aRet[4],(cAlQuery)->GWF_NRCALC)
//                 (cAlQuery)->(dbSkip())
//                 Loop
//             EndIf
//             cGW3SIT := ''
//             if !Empty((cAlQuery)->GWF_NRDF)
//                 GW3->(dbSetOrder(1))
//                 GW3->(dbSeek((cAlQuery)->GWF_FILIAL + (cAlQuery)->GWF_CDESP + (cAlQuery)->GWF_EMISDF + (cAlQuery)->GWF_SERDF + (cAlQuery)// ->GWF_NRDF + (cAlQuery)->GWF_DTEMDF)) 
//                 cGW3SIT := GW3->GW3_SIT
//             EndIf
// 
//             If (GFXCP12116("GWF","GWF_EMISDF") == .T. .And. !Empty((cAlQuery)->GWF_NRDF) .And. cMV_DPSERV == "1" .And. ;
//                 (cMV_GFE005 == "1" .Or. (cMV_GFE005 == "2" .And. cGW3SIT $ "34")))
//                 
//                 nCntErro++
//                 aRet[1] := 1
//                 aAdd(aRet[2],{.F.,"HÃ¡ documentos de carga vinculados a documento de frete. Os novos cÃ¡lculos gerados podem apresentar // valores diferentes do cÃ¡lculo original.",(cAlQuery)->GW1_RECNO,;
//                                 (cAlQuery)->GW1_EMISDC,;
//                                 (cAlQuery)->GW1_SERDC ,;
//                                 (cAlQuery)->GW1_NRDC  ,;
//                                 (cAlQuery)->GW1_CDTPDC,;
//                                 (cAlQuery)->GW1_CDREM ,;
//                                 (cAlQuery)->GW1_CDDEST,;
//                                 (cAlQuery)->GW1_ENTEND,;
//                                 (cAlQuery)->GW1_ENTBAI,;
//                                 (cAlQuery)->GW1_ENTNRC,;
//                                 (cAlQuery)->GW1_ENTCEP,;
//                                 (cAlQuery)->GW1_NRREG ,;
//                                 (cAlQuery)->GW1_TPFRET,;
//                                 (cAlQuery)->GW1_ICMSDC,;
//                                 (cAlQuery)->GW1_USO   ,;
//                                 (cAlQuery)->GW1_CARREG,;
//                                 (cAlQuery)->GW1_NRROM ,;
//                                 (cAlQuery)->GW1_QTVOL ,;
//                                 (cAlQuery)->GWF_NRCALC,;
//                                 (cAlQuery)->GWU_SEQ,;
//                                 (cAlQuery)->GWF_NRDF,;
//                                 (cAlQuery)->GWF_TRANSP,;
//                                 (cAlQuery)->GWF_NRDF,;
//                                 (cAlQuery)->GW1_FILIAL })
// 
//                 aAdd(aRet[3],"HÃ¡ documentos de carga vinculados a documento de frete. Os novos cÃ¡lculos gerados podem apresentar valores // diferentes do cÃ¡lculo original.")
//                 aAdd(aRet[4],(cAlQuery)->GWF_NRCALC)
//                 (cAlQuery)->(dbSkip())
//                 Loop
//             Else
//                 If !Empty((cAlQuery)->GWF_NRDF) .AND. cGW3SIT $ '12'
//                     if ASCAN(aDFReConf,{|X| X[1] == (cAlQuery)->GWF_FILIAL .And.;
//                                             X[2] == (cAlQuery)->GWF_CDESP  .And.;
//                                             X[3] == (cAlQuery)->GWF_EMISDF .And.;
//                                             X[4] == (cAlQuery)->GWF_SERDF  .And.;
//                                             X[5] == (cAlQuery)->GWF_NRDF   .And.;
//                                             X[6] == (cAlQuery)->GWF_DTEMDF}) == 0
// 
//                         aAdd(aDFReConf,{(cAlQuery)->GWF_FILIAL,;
//                                         (cAlQuery)->GWF_CDESP,;
//                                         (cAlQuery)->GWF_EMISDF,;
//                                         (cAlQuery)->GWF_SERDF,;
//                                         (cAlQuery)->GWF_NRDF,;
//                                         (cAlQuery)->GWF_DTEMDF})
//                     EndIf
//                 EndIf
//             EndIf
//             
//             If !Empty((cAlQuery)->GXD_CODLOT)
//                 nCntErro++
//                 aRet[1] := 1
//                 aAdd(aRet[2],{.F.,"HÃ¡ cÃ¡lculos vinculados a Lotes de ProvisÃ£o. Os novos cÃ¡lculos gerados podem apresentar valores // diferentes do cÃ¡lculo original.",(cAlQuery)->GW1_RECNO,;
//                                 (cAlQuery)->GW1_EMISDC,;
//                                 (cAlQuery)->GW1_SERDC ,;
//                                 (cAlQuery)->GW1_NRDC  ,;
//                                 (cAlQuery)->GW1_CDTPDC,;
//                                 (cAlQuery)->GW1_CDREM ,;
//                                 (cAlQuery)->GW1_CDDEST,;
//                                 (cAlQuery)->GW1_ENTEND,;
//                                 (cAlQuery)->GW1_ENTBAI,;
//                                 (cAlQuery)->GW1_ENTNRC,;
//                                 (cAlQuery)->GW1_ENTCEP,;
//                                 (cAlQuery)->GW1_NRREG ,;
//                                 (cAlQuery)->GW1_TPFRET,;
//                                 (cAlQuery)->GW1_ICMSDC,;
//                                 (cAlQuery)->GW1_USO   ,;
//                                 (cAlQuery)->GW1_CARREG,;
//                                 (cAlQuery)->GW1_NRROM ,;
//                                 (cAlQuery)->GW1_QTVOL ,;
//                                 (cAlQuery)->GWF_NRCALC,;
//                                 (cAlQuery)->GWU_SEQ,;
//                                 (cAlQuery)->GWF_NRDF,;
//                                 (cAlQuery)->GWF_TRANSP,;
//                                 (cAlQuery)->GWF_NRDF,;
//                                 (cAlQuery)->GW1_FILIAL })
//                 
//                 aAdd(aRet[3],"HÃ¡ cÃ¡lculos vinculados a Lotes de ProvisÃ£o. Os novos cÃ¡lculos gerados podem apresentar valores diferentes // do cÃ¡lculo original.")
//                 aAdd(aRet[4],(cAlQuery)->GWF_NRCALC)
//                 (cAlQuery)->(dbSkip())
//                 Loop
//             EndIf
//     
//             If (cAlQuery)->GWF_ORIGEM $ "2;4" .AND. cGWF_TPCALC $ "16"
//                 nCntErro++
//                 aRet[1] := 1
//                 If !lCalcAuto
//                     aAdd(aRet[2],{.F.,"HÃ¡ frete combinado ou simulado. Os novos cÃ¡lculos gerados podem apresentar valores diferentes do // cÃ¡lculo original.",(cAlQuery)->GW1_RECNO,; //"Romaneio jÃ¡ possui Frete Combinado"
//                                 (cAlQuery)->GW1_EMISDC,;
//                                 (cAlQuery)->GW1_SERDC ,;
//                                 (cAlQuery)->GW1_NRDC  ,;
//                                 (cAlQuery)->GW1_CDTPDC,;
//                                 (cAlQuery)->GW1_CDREM ,;
//                                 (cAlQuery)->GW1_CDDEST,;
//                                 (cAlQuery)->GW1_ENTEND,;
//                                 (cAlQuery)->GW1_ENTBAI,;
//                                 (cAlQuery)->GW1_ENTNRC,;
//                                 (cAlQuery)->GW1_ENTCEP,;
//                                 (cAlQuery)->GW1_NRREG ,;
//                                 (cAlQuery)->GW1_TPFRET,;
//                                 (cAlQuery)->GW1_ICMSDC,;
//                                 (cAlQuery)->GW1_USO   ,;
//                                 (cAlQuery)->GW1_CARREG,;
//                                 (cAlQuery)->GW1_NRROM ,;
//                                 (cAlQuery)->GW1_QTVOL ,;
//                                 (cAlQuery)->GWF_NRCALC,;
//                                 (cAlQuery)->GWU_SEQ,;
//                                 (cAlQuery)->GWF_NRDF,;
//                                 (cAlQuery)->GWF_TRANSP,;
//                                 (cAlQuery)->GWF_NRDF,;
//                                 (cAlQuery)->GW1_FILIAL })
//                     
//                     aAdd(aRet[3],"HÃ¡ frete combinado ou simulado. Os novos cÃ¡lculos gerados podem apresentar valores diferentes do cÃ¡lculo // original.")
//                     aAdd(aRet[4],(cAlQuery)->GWF_NRCALC)
//                 EndIF
//                 (cAlQuery)->( dbSkip() )
//                 Loop
//             EndIf
//             
// 
//                 // Ajustes nÃ£o cancelados relacionados Ã  ocorrÃªncia.
//                 cAlQryGWO := GetNextAlias()
// 
//                 BeginSQL Alias cAlQryGWO
//                     SELECT GWO.R_E_C_N_O_ GWO_RECNO 
//                     FROM %Table:GWO% GWO
//                     WHERE GWO_FILIAL = %xFilial:GWO%
//                     AND GWO_NRCALC = %Exp:(cAlQuery)->GWF_NRCALC%
//                     AND GWO_NROCO <> ' '
//                     AND GWO_SITAJU IN ('1','2')
//                     AND GWO.%NotDel%
//                 EndSQL
// 
//                 If (cAlQryGWO)->(!Eof())
//                     nCntErro++
//                     aRet[1] := 1
//                     aAdd(aRet[2],{.F.,"HÃ¡ cÃ¡lculos cancelados por ocorrÃªncia. Os novos cÃ¡lculos gerados podem apresentar valores // diferentes do cÃ¡lculo original.",(cAlQuery)->GW1_RECNO,;
//                                     (cAlQuery)->GW1_EMISDC,;
//                                     (cAlQuery)->GW1_SERDC,;
//                                     (cAlQuery)->GW1_NRDC,;
//                                     (cAlQuery)->GW1_CDTPDC,;
//                                     (cAlQuery)->GW1_CDREM,;
//                                     (cAlQuery)->GW1_CDDEST,;
//                                     (cAlQuery)->GW1_ENTEND,;
//                                     (cAlQuery)->GW1_ENTBAI,;
//                                     (cAlQuery)->GW1_ENTNRC,;
//                                     (cAlQuery)->GW1_ENTCEP,;
//                                     (cAlQuery)->GW1_NRREG,;
//                                     (cAlQuery)->GW1_TPFRET,;
//                                     (cAlQuery)->GW1_ICMSDC,;
//                                     (cAlQuery)->GW1_USO,;
//                                     (cAlQuery)->GW1_CARREG,;
//                                     (cAlQuery)->GW1_NRROM,;
//                                     (cAlQuery)->GW1_QTVOL,;
//                                     (cAlQuery)->GWF_NRCALC,;
//                                     (cAlQuery)->GWU_SEQ,;
//                                     (cAlQuery)->GWF_NRDF,;
//                                     (cAlQuery)->GWF_TRANSP,;
//                                     (cAlQuery)->GWF_NRDF,;
//                                     (cAlQuery)->GW1_FILIAL})
// 
//                     aAdd(aRet[3],"HÃ¡ cÃ¡lculos cancelados por ocorrÃªncia. Os novos cÃ¡lculos gerados podem apresentar valores diferentes do // cÃ¡lculo original.")
//                     aAdd(aRet[4],(cAlQuery)->GWF_NRCALC)
// 
//                     (cAlQryGWO)->(dbCloseArea())
//                     (cAlQuery)->(dbSkip())
//                     Loop
//                 EndIf
// 
//                 (cAlQryGWO)->(dbCloseArea())
// 
// 
//             If CGW1_TPFRET == '3' .And. CGWU_PAGAR == '2' 
//                 nCntErro++
//                 aRet[1] := 1
//                 aAdd(aRet[2],{.F.,"Documentos de carga com sentido saÃ­da e tipo de frete FOB nÃ£o efetuam cÃ¡lculo.",(cAlQuery)->GW1_RECNO,;
//                                 (cAlQuery)->GW1_EMISDC,;
//                                 (cAlQuery)->GW1_SERDC ,;
//                                 (cAlQuery)->GW1_NRDC  ,;
//                                 (cAlQuery)->GW1_CDTPDC,;
//                                 (cAlQuery)->GW1_CDREM ,;
//                                 (cAlQuery)->GW1_CDDEST,;
//                                 (cAlQuery)->GW1_ENTEND,;
//                                 (cAlQuery)->GW1_ENTBAI,;
//                                 (cAlQuery)->GW1_ENTNRC,;
//                                 (cAlQuery)->GW1_ENTCEP,;
//                                 (cAlQuery)->GW1_NRREG ,;
//                                 (cAlQuery)->GW1_TPFRET,;
//                                 (cAlQuery)->GW1_ICMSDC,;
//                                 (cAlQuery)->GW1_USO   ,;
//                                 (cAlQuery)->GW1_CARREG,;
//                                 (cAlQuery)->GW1_NRROM ,;
//                                 (cAlQuery)->GW1_QTVOL ,;
//                                 (cAlQuery)->GWF_NRCALC,;
//                                 (cAlQuery)->GWU_SEQ,;
//                                 (cAlQuery)->GWF_NRDF,;
//                                 (cAlQuery)->GWF_TRANSP,;
//                                 (cAlQuery)->GWF_NRDF,;
//                                 (cAlQuery)->GW1_FILIAL})
//                 
//                 aAdd(aRet[3],"Documentos de carga com sentido saÃ­da e tipo de frete FOB nÃ£o efetuam cÃ¡lculo.")
//                 aAdd(aRet[4],(cAlQuery)->GWF_NRCALC)
//                 (cAlQuery)->(dbSkip())
//                 Loop
//             EndIf
// 
//         EndIf
//         aAdd(aRet[2],{.T.,"OK" ,(cAlQuery)->GW1_RECNO,;
//                         (cAlQuery)->GW1_EMISDC,;
//                         (cAlQuery)->GW1_SERDC ,;
//                         (cAlQuery)->GW1_NRDC  ,;
//                         (cAlQuery)->GW1_CDTPDC,;
//                         (cAlQuery)->GW1_CDREM ,;
//                         (cAlQuery)->GW1_CDDEST,;
//                         (cAlQuery)->GW1_ENTEND,;
//                         (cAlQuery)->GW1_ENTBAI,;
//                         (cAlQuery)->GW1_ENTNRC,;
//                         (cAlQuery)->GW1_ENTCEP,;
//                         (cAlQuery)->GW1_NRREG ,;
//                         (cAlQuery)->GW1_TPFRET,;
//                         (cAlQuery)->GW1_ICMSDC,;
//                         (cAlQuery)->GW1_USO   ,;
//                         (cAlQuery)->GW1_CARREG,;
//                         (cAlQuery)->GW1_NRROM ,;
//                         (cAlQuery)->GW1_QTVOL ,;
//                         (cAlQuery)->GWF_NRCALC,;
//                         (cAlQuery)->GWU_SEQ,;
//                         "",;
//                         (cAlQuery)->GWF_TRANSP,;
//                         "",;
//                         (cAlQuery)->GW1_FILIAL })
//         (cAlQuery)->(dbSkip())
//     EndDo
// 
//     (cAlQuery)->(dbCloseArea())
// 
//     aSort(aRet[2],,,{|x,y| x[7]+x[4]+x[5]+x[6]+x[22]      < y[7]+y[4]+y[5]+y[6]+y[22]})
//     
//     nX := 1
//     nF := Len(aRet[2])
//     Do While nX <= nF
//         cTrecho := aRet[2,nX,7]+aRet[2,nX,4]+aRet[2,nX,5]+aRet[2,nX,6]+aRet[2,nX,22]
//         nY := nX + 1
//         Do While nY <= Len(aRet[2]) .And. cTrecho == aRet[2,nY,7]+aRet[2,nY,4]+aRet[2,nY,5]+aRet[2,nY,6]+aRet[2,nY,22]
//             If aRet[2,nY,1] == .F.
//                 aRet[2,nX,1] := .F.
//                 aRet[2,nX,2] := aRet[2,nY,2]
//             EndIf
//             aDel(aRet[2],nY)
//             aSize(aRet[2],nF-1)
//             nF--
//         EndDo
//         nX++
//     EndDo
//     
//     aSort(aRet[2],,,{|x,y| x[21]+x[7]+x[4]+x[5]+x[6]      < y[21]+y[7]+y[4]+y[5]+y[6]})
//     // Remover todos os trechos que nÃ£o puderem ser recalculados dentro de um cÃ¡lculo. 
//     // Caso o documento possua um trecho que se encaixe em outro cÃ¡lculo e nÃ£o houver impedimento, esse outro cÃ¡lculo serÃ¡ recalculado.
//     nF := Len(aRet[2])
//     For nX := 1 To nF
//         If aRet[2,nX,1] == .F.
//             If !Empty(aRet[2,nX,21])
//                 nPos := aScan(aRet[2],{|y|y[21] == aRet[2,nX,21]})
//             Else
//                 nPos := Len(aRet[2]) + 1
//             EndIf
//             Do While nPos <= Len(aRet[2]) .And. aRet[2,nPos,21] == aRet[2,nX,21]
//                 If aRet[2,nPos,1]
//                     nCntErro++
//                 EndIf
//                 aRet[2,nPos,1] := .F.
//                 nPos++
//             EndDo
//         EndIf
//     Next nX
// 
//     nCount := Len(aRet[2])
//     nCntErro := 0
//         For nX := 1 To nCount
//             If aRet[2,nX,1] == .F.
//                 nCntErro++
//             Else
//                 If Posicione("GWU", 1, xFilial("GW1") + aRet[2,nX,7] + aRet[2,nX,4] + aRet[2,nX,5] + aRet[2,nX,6] + aRet[2,nX,22],// "GWU_PAGAR") == "2"    // Posiciona no trecho e veja se o pagar Ã© nÃ£o
//                     nCntErro++
//                     aAdd(aRet[3],"Documento(s) de carga relacionado(s) ao romaneio possui trecho(s) nÃ£o pago(s).")
//                 EndIf
//             EndIf
//         Next nX
//     
//     aSort(aRet[3])
//     nX := 1
//     nF := Len(aRet[3])
//     Do While nX <= nF
//         cTrecho := aRet[3,nX]
//         nY := nX + 1
//         Do While nY <= Len(aRet[3]) .And. cTrecho == aRet[3,nY]
//             aDel(aRet[3],nY)
//             aSize(aRet[3],nF-1)
//             nF--
//         EndDo
//         nX++
//     EndDo
// 
//     If nCount == nCntErro
//         aRet[1] := 2
//     ElseIf nCount > nCntErro .And. nCntErro > 0 .and. lVerifTrecho == .T.
//         aRet[1] := 1
//     EndIf
//     aSort(aRet[2],,,{|x,y| StrZero(x[3],10) + x[22] < StrZero(y[3],10) + y[22]})
// Return aRet
// 
// 
// Static Function GF50ARCLC(aDocsCarg,aDocCarg,aItDoc,aTrchDoc,aNoCalc)
//     Local nQtdeUnit  := 0
//     Local aTrechos   := {}
//     Local nF         := 0
//     Local nX         := 0
//     Local nY         := 0
//     Local nZ         := 0
//     Local nChave     := 0
//     Local aUnitiliz  := {}
//     Local lGW8VALLIQ := GFXCP12118("GW8_VALLIQ") .Or. SuperGetMv("MV_ERPGFE",.F.,"2") == "4" // LOGIX - tratamento de contorno para falha de // teste de existÃªncia do campo durante o cÃ¡lculo automÃ¡tico executado pela integraÃ§Ã£o via adapter EAI
//     Local lGFE05014  := ExistBlock("GFE05014")
//     Local aCtcPE     := nil
// 
//     nF := Len(aDocsCarg[2])
//     For nX := 1 To nF
//         If aDocsCarg[2,nX,1]
//             If nChave != aDocsCarg[2,nX,3]// Ã? permitido recalcular e o documento nÃ£o repetiu
//                 aUnitiliz := {}
//                 nChave := aDocsCarg[2,nX,3]
//                 // Obtem a quantidade de unitizadores (embalagens) do documento de carga
//                 nQtdeUnit := 0
// 
//                 GWB->( dbSetOrder(2) )
//                 GWB->( dbSeek(aDocsCarg[2,nX,26] + aDocsCarg[2,nX,7] + aDocsCarg[2,nX,4] + aDocsCarg[2,nX,5] + aDocsCarg[2,nX,6]) )
//                 Do While GWB->( !Eof() ) ;
//                         .And. GWB->GWB_FILIAL == aDocsCarg[2,nX,26] ;
//                         .And. GWB->GWB_CDTPDC == aDocsCarg[2,nX,7] ;
//                         .And. GWB->GWB_EMISDC == aDocsCarg[2,nX,4] ;
//                         .And. GWB->GWB_SERDC  == aDocsCarg[2,nX,5] ;
//                         .And. GWB->GWB_NRDC   == aDocsCarg[2,nX,6]
// 
//                     nQtdeUnit += GWB->GWB_QTDE
// 
//                     nPos := aScan(aUnitiliz,{|x|x[1] == GWB->GWB_CDUNIT })
//                     If nPos == 0
//                         aAdd(aUnitiliz,{GWB->GWB_CDUNIT,GWB->GWB_QTDE})
//                     Else
//                         aUnitiliz[nPos][2] += GWB->GWB_QTDE
//                     EndIf
//                     GWB->( dbSkip() )
//                 EndDo
//                 aAdd(aDocCarg, {aDocsCarg[2,nX,4],; //Emitente do Documento
//                 aDocsCarg[2,nX,5],; //Serie do Documento
//                 aDocsCarg[2,nX,6],; //Numero do Documento
//                 aDocsCarg[2,nX,7],; //Tipo do Documento
//                 aDocsCarg[2,nX,8],; //Remetente do Documento
//                 aDocsCarg[2,nX,9],; //Destinatario do Documento
//                 aDocsCarg[2,nX,10],; //Endereco de Entrega
//                 aDocsCarg[2,nX,11],; //Bairro de entrega
//                 aDocsCarg[2,nX,12],; //Cidade de Entrega
//                 aDocsCarg[2,nX,13],; //CEP de Entrega
//                 aDocsCarg[2,nX,14],; //RegiÃ£o de destino
//                 aDocsCarg[2,nX,15],; //Tipo de Frete
//                 aDocsCarg[2,nX,16],; //ICMS?
//                 aDocsCarg[2,nX,17],; //Finalidade da mercadoria
//                 aDocsCarg[2,nX,18],; //NÃºmero do carregamento
//                 aDocsCarg[2,nX,19],; //Numero do Agrupador
//                 If(nQtdeUnit > 0, nQtdeUnit, aDocsCarg[2,nX,20]),; //Quantidade de Unitizadores ou qtde de volumes do documento de carga
//                     aUnitiliz,; //Codigo do Unitilizador + Quantidade do Unitilizador
//                     aDocsCarg[2,nX,26]}) //Codigo do Unitilizador + Quantidade do Unitilizador
// 
//                 GW8->( dbSetOrder(1) )
//                 GW8->( dbSeek(aDocsCarg[2,nX,26] + aDocsCarg[2,nX,7] + aDocsCarg[2,nX,4] + aDocsCarg[2,nX,5] + aDocsCarg[2,nX,6]) )
//                 Do While GW8->( !Eof() ) ;
//                         .And. GW8->GW8_FILIAL == aDocsCarg[2,nX,26] ;
//                         .And. GW8->GW8_CDTPDC == aDocsCarg[2,nX,7] ;
//                         .And. GW8->GW8_EMISDC == aDocsCarg[2,nX,4] ;
//                         .And. GW8->GW8_SERDC == aDocsCarg[2,nX,5] ;
//                         .And. GW8->GW8_NRDC == aDocsCarg[2,nX,6]
// 
//                     aAdd(aItDoc, {GW8->GW8_EMISDC,; // Emitente do Documento
//                     GW8->GW8_SERDC ,; // Serie do Documento
//                     GW8->GW8_NRDC  ,; // Numero do Documento
//                     GW8->GW8_CDTPDC,; // Tipo do Documento
//                     GW8->GW8_ITEM  ,; // Item
//                     GW8->GW8_CDCLFR,; // ClassIficacao de Frete
//                     GW8->GW8_TPITEM,; // ClassIficacao de Frete
//                     GW8->GW8_QTDE  ,; // Quantidade do Item
//                     GW8->GW8_PESOR ,; // Peso do Item
//                     GW8->GW8_PESOC ,; // Peso Cubado
//                     GW8->GW8_QTDALT,; // Quantidade/Peso Alternativo
//                     GW8->GW8_VALOR ,; // Valor do Item
//                     GW8->GW8_VOLUME,; // Volume ocupado (m3)
//                     GW8->GW8_TRIBP, ; // Frete tributado PIS
//                     IIf(lGW8VALLIQ,GW8->GW8_VALLIQ,0),; // Valor Liquido
//                     GW8->GW8_FILIAL }) // Valor Liquido
//                     GW8->( dbSkip() )
//                 EndDo
//             EndIf
// 
//             aTrechos := XFBGWUDC(,aDocsCarg[2,nX,26],aDocsCarg[2,nX,7],aDocsCarg[2,nX,4],aDocsCarg[2,nX,5],aDocsCarg[2,nX,6],aDocsCarg[2,nX,// 22])
//             nZ := Len(aTrechos)
//             For nY := 1 To nZ
//                 aAdd(aTrchDoc,aClone(aTrechos[nY]))
//             Next nY
//         Else
// 
//             aTrechos := XFBGWUDC(,aDocsCarg[2,nX,26],aDocsCarg[2,nX,7],aDocsCarg[2,nX,4],aDocsCarg[2,nX,5],aDocsCarg[2,nX,6],aDocsCarg[2,nX,// 22])
//             nZ := Len(aTrechos)
//             For nY := 1 To nZ
//                 aTrechos[nY,9] := "2" // Considera nÃ£o pago.
//                 aAdd(aTrchDoc,aClone(aTrechos[nY]))
//             Next nY
//         EndIf
//     Next nX
//     aNoCalc := aDocsCarg[4]
// 
//     // Ponto de entrada
//     If lGFE05014
//         aCtcPE := ExecBlock("GFE05014",.F.,.F.,{aTrchDoc})
//         If ValType(aCtcPE) == 'A' .And. !Empty(aCtcPE)
//             aTrchDoc := aCtcPE
//         EndIf
//     EndIf
// Return
// 
// Static Function GFEA50GXT(cFilRom, cNrRom)
//     Local aTblFrt := Array(21)
//     Local lRet    := .F.
// 
//     aTblFrt[21]:= ''
// 
//     If GFXCP12121('GWN_NRCT')
//         // Valida contrato de transporte para o transportador
//         if cFilRom != Nil
//             //Localiza o Romaneio
//             GWN->(dbSetOrder(01))
//             GWN->(DbSeek(cFilRom + cNrRom))
//         EndIf
//         If !Empty(GWN->GWN_NRCT)
//             GXT->( dbSetOrder(01) )
//             If GXT->( dbSeek(xFilial("GXT") + GWN->GWN_NRCT) )
//                 aTblFrt[1] := GXT->GXT_CDTRP
//                 aTblFrt[2] := GXT->GXT_NRTAB
//                 aTblFrt[20]:= GXT->GXT_NRNEG
//                 aTblFrt[21]:= GWN->GWN_NRCT
//                 lRet := .T.
//             EndIf
//         EndIf
//     EndIf
// Return {lRet, aTblFrt}
// 
// 
// Static Function GFE50DFCONF(lmsg)
//     Local cRet      := ""
//     Local oModelPai := FWLoadModel("GFEA065")
//     Local oModelGW3 := oModelPai:GetModel("GFEA065_GW3")
// 
//     Default lmsg := .T.
// 
//     oModelPai:SetOperation(MODEL_OPERATION_UPDATE)
//     If oModelPai:Activate()
//         If !oModelGW3:SetValue("GW3_SIT","1")
//             Help(,,"HELP",, oModelPai:GetErrorMessage()[6],1,0)
//         EndIf
// 
//         If oModelPai:VldData()
//             oModelPai:CommitData()
//         Else
//             Help(,,"HELP",, oModelPai:GetErrorMessage()[6],1,0)
//         EndIf
//     ElseIf FwIsInCallStack("GFEA065")
//         If lmsg
//             Help(,,"HELP",, "Tentativa de recÃ¡lculo de Frete. Motivo de nÃ£o ser executado o recÃ¡lculo: " + oModelPai:GetErrorMessage()[6],// 1,0)
//         Else
//             cRet := "Tentativa de recÃ¡lculo de Frete. Motivo de nÃ£o ser executado o recÃ¡lculo: " + oModelPai:GetErrorMessage()[6]
//         EndIf
//     EndIf
// 
//     oModelPai:Deactivate()
//     oModelPai:Destroy(oModelPai)
//     oModelPai := Nil
// Return cRet

