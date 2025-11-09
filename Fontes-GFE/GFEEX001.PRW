#include "totvs.ch"
#include "rwmake.ch"
#include "topconn.ch"
#include "fwmvcdef.ch"
Static _nADanfeNy := 0 as numeric
Static nADanfeCHV := ++_nADanfeNy
Static nADanfeCLI := ++_nADanfeNy
Static nADanfeLOJ := ++_nADanfeNy
Static nADanfeTPV := ++_nADanfeNy
Static nADanfeFIL := ++_nADanfeNy
/*/{Protheus.doc} GFEEX001
Geracao de Romaneio de Carga SIGAGFE, a partir de chamada do SIGAACD
@type function
@version 20250912
@author luiz.favareto@dithink.com.br
@since 25/06/2025
@history 13/08/2025, luiz.favareto, adicionado terceiro parametro BA_TPOPPF para carga caminhao fechado
@history 14/08/2025, luiz.favareto, novo parametro BA_GFEX1TT default .T. se desarma transacao na falha do calculo/liberacao do romaneio, e correcao chamada liberacao sem interface (lAuto)
@history 21/08/2025, luiz.favareto, adicionar a filial da NF e numero do romaneio nas mensagens retorno, e busca transportadora na tabela Z09
@history 12/09/2025, luiz.favareto, adicionado parametros GFE050CALC, lHelp=.F. lAuto=.T. e atualizadas funcoes testadas/comentadas gfea050.prw e gfea050a.prw
@param aDanfes, array, {{"35250669170462000668550070000044681387453992","000001","02"},...}
@param aRpcEmpFil, array, {cEmpresa,cFilial} p/ Rpc se necessario
@return character, mensagem retorno sucesso ou falha
@obs Conforme Projeto Logico 001 do Projeto no. 20250528008v02 referente ao servico de Revitalizacao do Gestao de Frete Embarcador (SIGAGFE TOTVS Protheus) e Integracao com o SIGAACD (Automacao e Coleta de Dados)
resumo dos parametros:
    BA_GFEX001 - ativar ou desativar log da rotina GFEEX001
    BA_CDCLFR - classificacao de frete do romaneio
    BA_TPOPPP - tipo de operacao do romaneio de carga sem tipo de veiculo informado / carga fracionada
    BA_TPOPPN - tipo de operacao do romaneio de carga sem tipo de veiculo informado / carga fracionada
    BA_TPOPPF - tipo de operacao do romaneio de carga sem tipo de veiculo informado / carga fechada
    BA_GFEX1TT - parametro rollback inclusao do romaneio em caso de falhas no calculo ou liberacao
    BA_GFEX1EM - email notificacao falhas na geracao, calculo ou liberacao dos romaneios
/*/
User Function GFEEX001(;
        aDanfes      as array;
		,aRpcEmpFil  as array;
    )
    Local aArea      as array
    Local cChaveGW1  as character
    Local cGU3CDEMIT as character
    Local cZ09TRANSP as character
    Local cZ09CDTPVC as charecter
    Local cMsg       as character
    Local cRet       as character
    Local lGFEEX001  as boolean
    Local lPerigoso  as boolean
    Local nX         as numeric
    Local oModelGWN  as object
	Iif(Select("SX2")>0,,WfPrepEnv(aRpcEmpFil[1],aRpcEmpFil[2]))
    Iif(lGFEEX001:=SuperGetMv("BA_GFEX001",,.T.),ConOut(ProcName()+" => INICIO"),) // ativar ou desativar log da rotina GFEEX001
    Iif(.Not.ValType(aDanfes)=="A",cRet:="ERRO na chamada da rotina "+ProcName(),)
    If Empty(cRet)
        aArea := Lj7GetArea({"GW1","GW8","SB5","SF2","SD2","Z09","SA4","GWU"})
        lPerigoso := .F.
        SB5->(DbSetOrder(1)) // B5_FILIAL+B5_COD
        GW8->(DbSetOrder(2)) // GW8_FILIAL+GW8_CDTPDC+GW8_EMISDC+GW8_SERDC+GW8_NRDC+GW8_SEQ
        SF2->(DbSetOrder(1)) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
        SD2->(DbSetOrder(3)) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
        Z09->(DbSetOrder(3)) // Z09_FILIAL+Z09_NUMPV+Z09_ITEMPV
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
            Iif(Empty(cRet),Aadd(aDanfes[nX],GW1->GW1_FILIAL),)
            Iif(Empty(cRet).And.(.Not.Empty(GW1->GW1_NRROM)),cRet:="ERRO, NF ["+GW1->GW1_NRDC+"] Serie ["+GW1->GW1_SERDC+"] ja existe em outro romaneio!",)
            Iif(Empty(cRet).And.(.Not.SF2->(MsSeek(GW1->(GW1_FILIAL+Padr(GW1_NRDC,GetSx3Cache("F2_DOC","X3_TAMANHO"))+GW1_SERDC+aDanfes[nX][nADanfeCLI]+aDanfes[nX][nADanfeLOJ])))),cRet:="ERRO, NF ["+GW1->GW1_NRDC+"] Serie ["+GW1->GW1_SERDC+"] nao encontrada (SF2) !",)
            Iif(Empty(cRet).And.(.Not.SD2->(MsSeek(SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)))),cRet:="ERRO, NF ["+GW1->GW1_NRDC+"] Serie ["+GW1->GW1_SERDC+"] nao encontrada (SD2) !",)
            Iif(Empty(cRet).And.(.Not.Z09->(MsSeek(SD2->(D2_FILIAL+D2_PEDIDO+D2_ITEMPV)))),cRet:="ERRO, NF ["+GW1->GW1_NRDC+"] Serie ["+GW1->GW1_SERDC+"] nao encontrada (Z09) !",)
            Iif(Empty(cRet).And.Empty(Z09->Z09_TRANSP),cRet:="ERRO, NF ["+GW1->GW1_NRDC+"] Serie ["+GW1->GW1_SERDC+"] sem transportadora definida!",)
            Iif(Empty(cRet),Iif(Empty(cZ09TRANSP),cZ09TRANSP:=Z09->Z09_TRANSP,Iif(.Not.cZ09TRANSP==Z09->Z09_TRANSP,cRet:="ERRO, NF ["+GW1->GW1_NRDC+"] Serie ["+GW1->GW1_SERDC+"] transportadora ["+cZ09TRANSP+"] diferente para romaneio!",)),)
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
        Iif(.Not.SA4->(MsSeek(xFilial("SA4")+cZ09TRANSP)),cRet:="ERRO, transportadora ["+cZ09TRANSP+"] nao encontrada!",)
        Iif(Empty(cRet).And.Empty(SA4->A4_CGC),cRet:="ERRO, transportadora ["+cZ09TRANSP+"] sem CNPJ cadastrado!",)
    Endif
    If Empty(cRet)
        cGU3CDEMIT := MpSysExecScalar("select top 1 coalesce(GU3_CDEMIT,' ') GU3_CDEMIT from "+RetSqlName("GU3");
            +" where GU3_FILIAL="+ValToSql(xFilial("GU3"))+" and GU3_IDFED="+ValToSql(Alltrim(SA4->A4_CGC));
            +" and GU3_TRANSP='1' and D_E_L_E_T_=' ' order by R_E_C_N_O_","GU3_CDEMIT")
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
            oModelGWN:SetValue("GFEA050_GWN","GWN_CDCLFR",SuperGetMv("BA_CDCLFR",,"")) // classificacao de frete do romaneio
            If Empty(cZ09CDTPVC)
                oModelGWN:SetValue("GFEA050_GWN","GWN_CDTPOP",Padr(SuperGetMv("BA_TPOPP"+Iif(lPerigoso,"P","N"),,""),GetSx3Cache("GWN_CDTPOP","X3_TAMANHO"))) // tipo de operacao do romaneio de carga sem tipo de veiculo informado / carga fracionada
            Else
                oModelGWN:SetValue("GFEA050_GWN","GWN_CDTPOP",Padr(SuperGetMv("BA_TPOPPF",,""),GetSx3Cache("GWN_CDTPOP","X3_TAMANHO"))) // tipo de operacao do romaneio de carga com tipo de veiculo informado / carga fechada
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
                    Iif(Empty(cRet).And.(.Not.GFE050CALC(/*lDatabase*/,/*lHelp*/.F.,@cMsg,/*aRetCalc*/,/*lTstAuto*/.T.,/*cArqLog*/)),cRet:="ERRO no calculo do Romaneio nr ["+GWN->GWN_NRROM+"] !" +CRLF+cMsg,)
                    Iif(Empty(cRet).And.(.Not.GFEA050LIB(.T.,@cMsg,,,.T.)),cRet:="ERRO na liberacao do Romaneio nr ["+GWN->GWN_NRROM+"] !"+CRLF+cMsg,)
                    If Empty(cRet)
                        cRet:="Sucesso na geracao do Romaneio nr ["+GWN->GWN_NRROM+"]"
                    Else
                        If SuperGetMv("BA_GFEX1TT",,.T.) // parametro rollback inclusao do romaneio em caso de falhas no calculo ou liberacao
                            DisarmTransaction()
                        Endif
                        cRet += CRLF
                        For nX:=1 To Len(aDanfes)
                            cRet += "---" + CRLF
                            If Len(aDanfes[nX])>=nADanfeFIL
                                cRet += "[" + cValToChar(nX) + "] Filial: "   + aDanfes[nX, nADanfeFIL] + CRLF
                            Endif
                            cRet += "[" + cValToChar(nX) + "] Danfe: "        + aDanfes[nX, nADanfeCHV] + CRLF
                            cRet += "[" + cValToChar(nX) + "] Cliente: "      + aDanfes[nX, nADanfeCLI] + CRLF
                            cRet += "[" + cValToChar(nX) + "] Loja: "         + aDanfes[nX, nADanfeLOJ] + CRLF
                            cRet += "[" + cValToChar(nX) + "] Tipo Veiculo: " + aDanfes[nX, nADanfeTPV] + CRLF
                        Next nX
                        EnviaEmail("ERRO rotina "+ProcName(1)+" => "+ProcName(),cRet,SuperGetMv("BA_GFEX1EM",,"")) // email notificacao falhas na geracao, calculo ou liberacao dos romaneios
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
    Local lGFEEX001  := SuperGetMv("BA_GFEX001",,.T.) as boolean // ativar ou desativar log da rotina GFEEX001
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
    Iif(lGFEEX001,ConOut(ProcName()+" => INICIO"),)
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
    // wfprepenv("BA","07")
    // u_GFEEX001({{"35231269170462000404550040000306481638145032","000912","03"}})
    StartJob("u_GFEEX001",GetEnvServer(),.T.,{{"35250869170462000668550070000035901216697284","001466","01",""}},{"BA","07"})
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


// //gfea050.prw:
// #DEFINE CPESO 1
// #DEFINE CVAL  2
// #DEFINE CVOL  3
// #DEFINE CQTDE 4

// // Códigos de mensagens padronizadas
// #DEFINE GFEA050001 'GFEA050001'
// #DEFINE GFEA050002 'GFEA050002'
// #DEFINE GFEA050003 'GFEA050003'
// #DEFINE GFEA050004 'GFEA050004'
// #DEFINE GFEA050005 'GFEA050005'
// #DEFINE GFEA050006 'GFEA050006'
// #DEFINE GFEA050007 'GFEA050007'
// #DEFINE GFEA050008 'GFEA050008'
// #DEFINE GFEA050009 'GFEA050009'
// #DEFINE GFEA050010 'GFEA050010'
// #DEFINE GFEA050011 'GFEA050011'
// #DEFINE GFEA050012 'GFEA050012'
// #DEFINE GFEA050013 'GFEA050013'
// #DEFINE GFEA050014 'GFEA050014'
// #DEFINE GFEA050015 'GFEA050015'
// #DEFINE GFEA050016 'GFEA050016'
// #DEFINE GFEA050017 'GFEA050017'
// #DEFINE GFEA050018 'GFEA050018'
// #DEFINE GFEA050019 'GFEA050019'
// #DEFINE GFEA050020 'GFEA050020'
// #DEFINE GFEA050021 'GFEA050021'
// #DEFINE GFEA050022 'GFEA050022'
// #DEFINE GFEA050023 'GFEA050023'
// #DEFINE GFEA050024 'GFEA050024'
// #DEFINE GFEA050025 'GFEA050025'

// // SONARQUBE - CA1003: Uso não permitido de chamada de API em LOOP
// Static s_GFEI20_1
// Static s_GFEI20_2
// Static s_INTFRE
// Static s_RENTNP
// Static s_MULFIL

// // Static Function GFEA050()
// // 	Local l050Leg  := ExistBlock("GFE50LEG")
// // 	Private dData
// // 	Private cHora
// // 	Private oBrowse
// // 	Private cParamF12 := 2 // Inicializado para não mostrar filtro antes de abrir a tela de doc. de carga
// // 	Private lCopy     := .F.
// // 	Private lExcluir  := .F.
// // 	Private aRotina   := MenuDef()

// // 	// Função para preenchimento de campo FILROM em caso de sem conteudo em registros antigos a melhoria - Remover posteriormente
// // 	chkFilromaneio()

// // 	oBrowse := FWMBrowse():New()
// // 	oBrowse:SetAlias("GWN")                              // Alias da tabela utilizada
// // 	oBrowse:SetMenuDef("GFEA050")                        // Nome do fonte onde esta a função MenuDef
// // 	oBrowse:SetDescription("Documentos de Carga")                      // Descrição do browse //"Romaneios de Carga"
// // 	oBrowse:AddLegend("GWN_SIT=='1'", "WHITE" , "Peso Cub:") //"Digitado"
// // 	oBrowse:AddLegend("GWN_SIT=='2'", "BLUE", "Emitido") //"Emitido"
// // 	oBrowse:AddLegend("GWN_SIT=='3'", "GREEN" , "Valor Merc:") //"Liberado"
// // 	oBrowse:AddLegend("GWN_SIT=='4'", "RED"   , "Nr Volumes:") //"Encerrado"

// // 	If l050Leg
// // 		ExecBlock("GFE50LEG",.F.,.F.)
// // 	EndIf

// // 	Pergunte("GFEA050F12",.F.)
// // 	If !Empty(MV_PAR01)
// // 		cParamF12 := MV_PAR01
// // 		SetKey(VK_F12, {||ParamF12()})
// // 	EndIf

// // 	oBrowse:Activate()
// // Return Nil

// // //-------------------------------------------------------------------//
// // //-------------------------Funcao MenuDEF----------------------------//
// // //-------------------------------------------------------------------//
// // Static Function MenuDef()
// // 	Local aRotina   := {}
// // 	Local aRotina2  := {} //Submenu

// // 	Aadd(aRotina2, {"Incluir", "GFEA50REDP(1)", 0, 4 } )
// // 	Aadd(aRotina2, {"Alterar", "GFEA50REDP(2)", 0, 4 } )

// // 	//-------------------------------------------------------
// // 	// Adiciona botões do browse
// // 	//-------------------------------------------------------
// // 	ADD OPTION aRotina TITLE "Serie" ACTION "AxPesqui"                 						OPERATION  1 ACCESS 0 //"Pesquisar"
// // 	ADD OPTION aRotina TITLE "NRDC" ACTION "VIEWDEF.GFEC050"          						OPERATION  2 ACCESS 0 //"Visualizar"
// // 	ADD OPTION aRotina TITLE "TPDC" ACTION "VIEWDEF.GFEA050"          						OPERATION  3 ACCESS 0 //"Incluir"
// // 	ADD OPTION aRotina TITLE "CDEMIS" ACTION "GFEA050ALT()"             						OPERATION  4 ACCESS 0 //"Alterar"
// // 	ADD OPTION aRotina TITLE "NMEMIS" ACTION "GFEA050EXC()"             						OPERATION  5 ACCESS 0 //"Excluir"
// // 	ADD OPTION aRotina TITLE "Doc. Carga" ACTION "GFEDOCCAR()"              						OPERATION 14 ACCESS 0 //"Doc. Carga"
// // 	ADD OPTION aRotina TITLE "Adicionar" ACTION "GFE050CALC()"             						OPERATION 12 ACCESS 0 //"Calcular"
// // 	ADD OPTION aRotina TITLE "CDREM" ACTION "GFEA050BLO()"             						OPERATION  9 ACCESS 0 //"Bloq./Desbloq."
// // 	ADD OPTION aRotina TITLE "Liberar" ACTION "GFEA050LIB(,,,,.T.)"      						OPERATION 10 ACCESS 0 //"Liberar"
// // 	ADD OPTION aRotina TITLE STR0126 ACTION "GFEA050INF()"             						OPERATION 10 ACCESS 0 //"Inf. Rastr."
// // 	ADD OPTION aRotina TITLE STR0009 ACTION "GFEA050REA()"             						OPERATION 11 ACCESS 0 //"Reabrir"
// // 	ADD OPTION aRotina TITLE "Entrega" ACTION "GFEA050ENT()"             						OPERATION 13 ACCESS 0 //"Entrega"
// // 	ADD OPTION aRotina TITLE STR0127 ACTION "GFEA050RET()"             						OPERATION 14 ACCESS 0 //"Retorno"
// // 	ADD OPTION aRotina TITLE "Marca todos os documentos de carga em tela" ACTION "GFE050AJUS()"             						OPERATION 15 ACCESS 0 //"Ajuste"
// // 	ADD OPTION aRotina TITLE STR0128 ACTION "GFE050PMAI()"             						OPERATION 15 ACCESS 0 //"Enviar xml nfe"
// // 	ADD OPTION aRotina TITLE STR0129 ACTION aRotina2                   						OPERATION  4 ACCESS 0 //"Redespachantes"
// // 	ADD OPTION aRotina TITLE STR0130 ACTION "GFE050PVIA()"             						OPERATION 16 ACCESS 0 //"Partida Viagem"
// // 	ADD OPTION aRotina TITLE "Selecione Documentos de Carga " ACTION "GFEA50COPY()"             						OPERATION 6  ACCESS 0 //"Copiar"
// // 	ADD OPTION aRotina TITLE "Excluir" ACTION "VIEWDEF.GFEA050"          						OPERATION 8  ACCESS 0 //"Imprimir"
// // 	ADD OPTION aRotina TITLE STR0131 ACTION "GFE050COMB()"             						OPERATION 17 ACCESS 0 //"Combinar"
// // 	ADD OPTION aRotina TITLE STR0132 ACTION "GFEA050E(GWN->GWN_NRROM)" 						OPERATION 16 ACCESS 0 //"Roteiro"
// // 	ADD OPTION aRotina TITLE STR0133 ACTION "GFE050DESC()"             						OPERATION 18 ACCESS 0 //"Desfazer Combinado"
// // 	ADD OPTION aRotina TITLE STR0134 ACTION "MsDocument('GWN',GWN->(RecNo()), 3)"         	OPERATION  4 ACCESS 0 //"Anexos"
// // 	ADD OPTION aRotina TITLE STR0135 ACTION "GFEA50VCAL(GWN->GWN_FILIAL, GWN->GWN_NRROM)" 	OPERATION 20 ACCESS 0 //"Visualizar Cálculos"
// // 	ADD OPTION aRotina TITLE STR0136 ACTION "GFEX201(GWN->GWN_FILIAL, GWN->GWN_NRROM)"    	OPERATION 21 ACCESS 0 //"Integração FreteBras"

// // 	If ExistBlock("XGFEA050")
// // 		aRotAdic := ExecBlock("XGFEA050 ",.F.,.F.)
// // 		If ValType(aRotAdic) == "A"
// // 			AEval(aRotAdic, {|x| AAdd(aRotina ,x)})
// // 		EndIf
// // 	EndIf
// // Return aRotina

// // //-------------------------------------------------------------------//
// // //-------------------------Funcao ModelDEF---------------------------//
// // //-------------------------------------------------------------------//

// // Static Function ModelDef()
// // 	Local oModel
// // 	Local oStructGWN := FWFormStruct(1,"GWN")
// // 	Local aAux

// // 	aAux := FwStruTrigger('GWN_VIAGEM'     ,; // Campo de Dominio (tem que existir no Model)
// // 	'GWN_VIAGEM'   ,; // Campo de ContraDominio (tem que existir no Model)
// // 	'GFEA050PVG()' ,; // Regra de Preenchimento
// // 	,;                // Se posicionara ou não antes da execução do gatilhos (Opcional)
// // 	,;                // Alias da tabela a ser posicionada (Obrigatorio se lSeek = .T.)
// // 	,;                // Ordem da tabela a ser posicionada (Obrigatorio se lSeek = .T.)
// // 	,;                // Chave de busca da tabela a ser posicionada (Obrigatorio se lSeek = .T)
// // 	)                 // Condição para execução do gatilho (Opcional)

// // 	//  aAux tem o conteudo
// // 	// [01] Id do campo de origem
// // 	// [02] Id do campo de destino
// // 	// [03] Bloco de codigo de validação da execução do gatilho
// // 	// [04] Bloco de codigo de execução do gatilho
// // 	oStructGWN:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4] )

// // 	// cID     IdentIficador do modelo
// // 	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
// // 	// bPost   Code-Block de validação do formulário de edição
// // 	// bCommit Code-Block de persistência do formulário de edição
// // 	// bCancel Code-Block de cancelamento do formulário de edição
// // 	oModel := MPFormModel():New("GFEA050", /*bPre*/, { |oX| GFEA050POS( oX ) } /*bPost*/, {|oX| GFEA50CMT(oX)}/*bCommit*/, /*bCancel*/)
// // 	// cId          IdentIficador do modelo
// // 	// cOwner       IdentIficador superior do modelo
// // 	// oModelStruct Objeto com  a estrutura de dados
// // 	// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
// // 	// bPost        Code-Block de validação do formulário de edição
// // 	// bLoad        Code-Block de carga dos dados do formulário de edição
// // 	oModel:AddFields("GFEA050_GWN", Nil, oStructGWN,/*bPre*/,/*bPost*/,/*bLoad*/)
// // 	oModel:SetPrimaryKey({"GWN_FILIAL", "GWN_NRROM"})
// // 	oModel:SetActivate({|oMod| GFEA50ACT(oMod)})
// // 	oModel:SetVldActivate({|oModel| GFEA50VLD(oModel)})
// // Return oModel

// Static Function GFEA050PVG()
// 	Local nVal    := 0
// 	Local oMdlAct := FwModelActive()
// 	Local oVwAct  := FwViewActive()
// 	Local aQtdes  := {}
// 	Local cViagem := oMdlAct:GetModel("GFEA050_GWN"):GetValue("GWN_VIAGEM")

// 	oMdlAct:lModify := .T.
// 	If !Empty(cViagem)

// 		If oMdlAct:GetOperation() == MODEL_OPERATION_INSERT
// 			aQtdes := GFE58OUTCARGA('','',cViagem)
// 		Else
// 			aQtdes := GFE58OUTCARGA(GWN->GWN_FILIAL,GWN->GWN_NRROM,cViagem)
// 		EndIf

// 		If oMdlAct:GetModel("GFEA050_GWN"):HasField("GWN_CPESO")
// 			oMdlAct:GetModel("GFEA050_GWN"):LoadValue("GWN_CPESO", aQtdes[CPESO])
// 		EndIf

// 		If oMdlAct:GetModel("GFEA050_GWN"):HasField("GWN_CVAL" )
// 			oMdlAct:GetModel("GFEA050_GWN"):LoadValue("GWN_CVAL" , aQtdes[CVAL ])
// 		EndIf

// 		If oMdlAct:GetModel("GFEA050_GWN"):HasField("GWN_CVOL" )
// 			oMdlAct:GetModel("GFEA050_GWN"):LoadValue("GWN_CVOL" , aQtdes[CVOL ])
// 		EndIf

// 		If oMdlAct:GetModel("GFEA050_GWN"):HasField("GWN_CQTDE")
// 			oMdlAct:GetModel("GFEA050_GWN"):LoadValue("GWN_CQTDE", aQtdes[CQTDE])
// 		EndIf

// 		nVal := aQtdes[CPESO]
// 	Else
// 		If oMdlAct:GetModel("GFEA050_GWN"):HasField("GWN_CPESO")
// 			oMdlAct:GetModel("GFEA050_GWN"):LoadValue("GWN_CPESO", 0)
// 		EndIf
// 		If oMdlAct:GetModel("GFEA050_GWN"):HasField("GWN_CVAL" )
// 			oMdlAct:GetModel("GFEA050_GWN"):LoadValue("GWN_CVAL" , 0)
// 		EndIf
// 		If oMdlAct:GetModel("GFEA050_GWN"):HasField("GWN_CVOL" )
// 			oMdlAct:GetModel("GFEA050_GWN"):LoadValue("GWN_CVOL" , 0)
// 		EndIf
// 		If oMdlAct:GetModel("GFEA050_GWN"):HasField("GWN_CQTDE")
// 			oMdlAct:GetModel("GFEA050_GWN"):LoadValue("GWN_CQTDE", 0)
// 		EndIf
// 	EndIf

// 	If oVwAct != Nil .AND. oVwAct:LACTIVATE
// 		oVwAct:lModify := .T.
// 		oVwAct:Refresh()
// 	EndIf
// Return cViagem

// //-------------------------------------------
// //Função para validar a manipulação do model
// //-------------------------------------------

// Static Function GFEA50VLD(oModel)
// 	Local lRet := .T.
// 	Local nOp  := oModel:GetOperation()

// 	If (nOp == MODEL_OPERATION_UPDATE .OR. nOp == MODEL_OPERATION_DELETE)
// 		If GWN->GWN_SIT == "3"
// 			lRet := .F.
// 			GFEMessage(5, GFEA050011, "O Romaneio está liberado, portanto, não poderá ser alterado nem excluído.", "Reabra o Romaneio para permitir alterações ou exclusões.")	// "O Romaneio está liberado, portanto, não poderá ser alterado nem excluído.", "Reabra o Romaneio para permitir alterações ou exclusões."
// 		ElseIf GWN->GWN_SIT == "4"
// 			lRet := .F.
// 			GFEMessage(5, GFEA050012, "O Romaneio está encerrado, portando não poderá ser alterado nem excluído.", "Reabra o Romaneio para permitir alterações ou exclusões.") // "O Romaneio está encerrado, portando não poderá ser alterado nem excluído.", "Reabra o Romaneio para permitir alterações ou exclusões."
// 		EndIf
// 	EndIf
// Return lRet

// // //-------------------------------------------------------------------//
// // //-------------------------Funcao ViewDef----------------------------//
// // //-------------------------------------------------------------------//

// // Static Function ViewDef()
// // 	Local oModel     := FWLoadModel("GFEA050")
// // 	Local oView      := Nil
// // 	Local oStructGWN := FWFormStruct(2,"GWN")
// // 	Local nI         := 0
// // 	Local nF         := 0
// // 	Local aRetPE     := {}
// // 	Default lExcluir := .F.

// // 	oStructGWN:AddGroup("GrpId" , "Identificação"        , "", 2) // "Identificação"
// // 	oStructGWN:AddGroup("GrpClc", "Cálculo de Frete"     , "", 2) // "Cálculo de Frete"
// // 	oStructGWN:AddGroup("GrpMot", "Motoristas e Veículos", "", 2) // "Motoristas e Veículos"
// // 	oStructGWN:AddGroup("GrpVig", "Viagem"               , "", 2) // "Viagem"
// // 	oStructGWN:AddGroup("GrpViag","Consolidação de carga", "", 2) // "Consolidação de carga"
// // 	oStructGWN:AddGroup("GrpObs", "Observações"          , "", 2) // "Observações"
// // 	oStructGWN:AddGroup("GrpRea", "Reabertura"           , "", 2) // "Reabertura"
// // 	oStructGWN:AddGroup("GrpCtr", "Controle"             , "", 2) // "Controle"

// // 	oStructGWN:SetProperty("GWN_NRROM", MVC_VIEW_GROUP_NUMBER, "GrpId")
// // 	oStructGWN:SetProperty("GWN_CDTRP", MVC_VIEW_GROUP_NUMBER, "GrpId")
// // 	oStructGWN:SetProperty("GWN_DSTRP", MVC_VIEW_GROUP_NUMBER, "GrpId")

// // 	If oStructGWN:HasField("GWN_TOTALT")
// // 		// Mostra os campos totalizadores somente se for configurado como browse
// // 		If GetSx3Cache("GWN_TOTVOL","X3_BROWSE") == "N"
// // 			oStructGWN:RemoveField("GWN_TOTVOL")
// // 		EndIf
// // 		If GetSx3Cache("GWN_TOTPER","X3_BROWSE") == "N"
// // 			oStructGWN:RemoveField("GWN_TOTPER")
// // 		EndIf
// // 		If GetSx3Cache("GWN_TOTPEC","X3_BROWSE") == "N"
// // 			oStructGWN:RemoveField("GWN_TOTPEC")
// // 		EndIf
// // 		If GetSx3Cache("GWN_TQTVOL","X3_BROWSE") == "N"
// // 			oStructGWN:RemoveField("GWN_TQTVOL")
// // 		EndIf
// // 		If GetSx3Cache("GWN_TOTALT","X3_BROWSE") == "N"
// // 			oStructGWN:RemoveField("GWN_TOTALT")
// // 		EndIf
// // 	EndIf

// // 	If oStructGWN:HasField("GWN_VIAGEM")
// // 		oStructGWN:SetProperty("GWN_VIAGEM", MVC_VIEW_GROUP_NUMBER, "GrpViag")
// // 	EndIf

// // 	If oStructGWN:HasField("GWN_CPESO")
// // 		oStructGWN:SetProperty("GWN_CPESO", MVC_VIEW_GROUP_NUMBER, "GrpViag")
// // 	EndIf

// // 	If oStructGWN:HasField("GWN_CVOL")
// // 		oStructGWN:SetProperty("GWN_CVOL", MVC_VIEW_GROUP_NUMBER, "GrpViag")
// // 	EndIf

// // 	If oStructGWN:HasField("GWN_CVAL")
// // 		oStructGWN:SetProperty("GWN_CVAL", MVC_VIEW_GROUP_NUMBER, "GrpViag")
// // 	EndIf

// // 	If oStructGWN:HasField("GWN_CQTDE")
// // 		oStructGWN:SetProperty("GWN_CQTDE", MVC_VIEW_GROUP_NUMBER, "GrpViag")
// // 	EndIf

// // 	oStructGWN:SetProperty("GWN_CDTPOP", MVC_VIEW_GROUP_NUMBER, "GrpClc")
// // 	oStructGWN:SetProperty("GWN_CDCLFR", MVC_VIEW_GROUP_NUMBER, "GrpClc")
// // 	oStructGWN:SetProperty("GWN_DSCLFR", MVC_VIEW_GROUP_NUMBER, "GrpClc")
// // 	oStructGWN:SetProperty("GWN_CDTPVC", MVC_VIEW_GROUP_NUMBER, "GrpClc")

// // 	oStructGWN:SetProperty("GWN_CDMTR" , MVC_VIEW_GROUP_NUMBER, "GrpMot")
// // 	oStructGWN:SetProperty("GWN_NMMTR" , MVC_VIEW_GROUP_NUMBER, "GrpMot")
// // 	oStructGWN:SetProperty("GWN_CDMTR2", MVC_VIEW_GROUP_NUMBER, "GrpMot")
// // 	oStructGWN:SetProperty("GWN_NMMTR2", MVC_VIEW_GROUP_NUMBER, "GrpMot")
// // 	oStructGWN:SetProperty("GWN_PLACAD", MVC_VIEW_GROUP_NUMBER, "GrpMot")
// // 	oStructGWN:SetProperty("GWN_PLACAM", MVC_VIEW_GROUP_NUMBER, "GrpMot")
// // 	oStructGWN:SetProperty("GWN_PLACAT", MVC_VIEW_GROUP_NUMBER, "GrpMot")
// // 	oStructGWN:SetProperty("GWN_LACRE",  MVC_VIEW_GROUP_NUMBER, "GrpMot")
// // 	oStructGWN:SetProperty("GWN_NRCIDD", MVC_VIEW_GROUP_NUMBER, "GrpVig")
// // 	oStructGWN:SetProperty("GWN_NMCIDD", MVC_VIEW_GROUP_NUMBER, "GrpVig")
// // 	oStructGWN:SetProperty("GWN_CEPD"  , MVC_VIEW_GROUP_NUMBER, "GrpVig")
// // 	If AScan(oStructGWN:aFields,{|x| x[1] == "GWN_NRCIDO"}) != 0
// // 		oStructGWN:SetProperty("GWN_CEPO", MVC_VIEW_GROUP_NUMBER, "GrpVig")
// // 		oStructGWN:SetProperty("GWN_NRCIDO", MVC_VIEW_GROUP_NUMBER, "GrpVig")
// // 		oStructGWN:SetProperty("GWN_NMCIDO", MVC_VIEW_GROUP_NUMBER, "GrpVig")
// // 	EndIf
// // 	oStructGWN:SetProperty("GWN_RASTR" , MVC_VIEW_GROUP_NUMBER, "GrpVig")
// // 	oStructGWN:SetProperty("GWN_PRIOR" , MVC_VIEW_GROUP_NUMBER, "GrpVig")
// // 	oStructGWN:SetProperty("GWN_DISTAN", MVC_VIEW_GROUP_NUMBER, "GrpVig")

// // 	oStructGWN:SetProperty("GWN_DTIMPL", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
// // 	oStructGWN:SetProperty("GWN_HRIMPL", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
// // 	oStructGWN:SetProperty("GWN_SIT"   , MVC_VIEW_GROUP_NUMBER, "GrpCtr")
// // 	oStructGWN:SetProperty("GWN_DTSAI" , MVC_VIEW_GROUP_NUMBER, "GrpCtr")
// // 	oStructGWN:SetProperty("GWN_HRSAI" , MVC_VIEW_GROUP_NUMBER, "GrpCtr")
// // 	oStructGWN:SetProperty("GWN_CALC"  , MVC_VIEW_GROUP_NUMBER, "GrpCtr")
// // 	oStructGWN:SetProperty("GWN_MTCALC", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
// // 	oStructGWN:SetProperty("GWN_DTCALC", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
// // 	oStructGWN:SetProperty("GWN_HRCALC", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
// // 	If GFXCP12117("GWN_ENVNFE") == .T.
// // 		oStructGWN:SetProperty("GWN_ENVNFE", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
// // 	EndIf
// // 	If GFXCP12117("GWN_MOTNFE") == .T.
// // 		oStructGWN:SetProperty("GWN_MOTNFE", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
// // 	EndIf

// // 	If AScan(oStructGWN:aFields,{|x| x[1] == "GWN_VPVAL"}) != 0
// // 		oStructGWN:SetProperty("GWN_VPVAL", MVC_VIEW_GROUP_NUMBER, "GrpVig")
// // 		oStructGWN:SetProperty("GWN_VPNUM", MVC_VIEW_GROUP_NUMBER, "GrpVig")
// // 		oStructGWN:SetProperty("GWN_VPCDOP", MVC_VIEW_GROUP_NUMBER, "GrpVig")
// // 		oStructGWN:SetProperty("GWN_VPNMOP", MVC_VIEW_GROUP_NUMBER, "GrpVig")
// // 		oStructGWN:SetProperty("GWN_VALEP", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
// // 	EndIf

// // 	If AScan(oStructGWN:aFields,{|x| x[1] == "GWN_AGRUP"}) != 0
// // 		oStructGWN:SetProperty("GWN_AGRUP", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
// // 	EndIf

// // 	If AScan(oStructGWN:aFields,{|x| x[1] == "GWN_DSREAL"}) != 0
// // 		oStructGWN:SetProperty("GWN_HODRET", MVC_VIEW_GROUP_NUMBER, "GrpVig")
// // 		oStructGWN:SetProperty("GWN_HODSAI", MVC_VIEW_GROUP_NUMBER, "GrpVig")
// // 		oStructGWN:SetProperty("GWN_DSREAL", MVC_VIEW_GROUP_NUMBER, "GrpVig")
// // 		oStructGWN:SetProperty("GWN_DTRET", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
// // 		oStructGWN:SetProperty("GWN_HRRET", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
// // 		oStructGWN:SetProperty("GWN_FECHAM", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
// // 		oStructGWN:SetProperty("GWN_DTFECH", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
// // 	EndIf

// // 	oStructGWN:SetProperty("GWN_BLOQPF", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
// // 	oStructGWN:SetProperty("GWN_ORI"   , MVC_VIEW_GROUP_NUMBER, "GrpCtr")
// // 	oStructGWN:SetProperty("GWN_USUIMP", MVC_VIEW_GROUP_NUMBER, "GrpCtr")

// // 	oStructGWN:SetProperty("GWN_OBS", MVC_VIEW_GROUP_NUMBER, "GrpObs")

// // 	If AScan(oStructGWN:aFields,{|x| x[1] == "GWN_MOTREA"}) != 0
// // 		oStructGWN:SetProperty("GWN_MOTREA", MVC_VIEW_GROUP_NUMBER, "GrpRea")
// // 		oStructGWN:SetProperty("GWN_DTREAB", MVC_VIEW_GROUP_NUMBER, "GrpRea")
// // 		oStructGWN:SetProperty("GWN_HRREAB", MVC_VIEW_GROUP_NUMBER, "GrpRea")
// // 		oStructGWN:SetProperty("GWN_USUREA", MVC_VIEW_GROUP_NUMBER, "GrpRea")
// // 	EndIf

// // 	//PE para possibilitar posicionar campos customizados no agrupador "Viagem"
// // 	//retorno deve ser um array no formato:
// // 	//aRetPE[1] (Caracter) ID do Campo
// // 	//aRetPE[2] (Numérico) Agrupamento do Campo
// // 	If ExistBlock("GFE05012")
// // 		aRetPE := ExecBlock('GFE05012',.F.,.F.)
// // 		If ValType(aRetPE) == 'A' .AND. !Empty(aRetPE)
// // 			nF := Len(aRetPE)
// // 			For nI := 1 To nF
// // 				If GFXCP12127(aRetPE[nI][1])
// // 					oStructGWN:SetProperty(aRetPE[nI][1], aRetPE[nI][2], "GrpVig")
// // 				EndIf
// // 			Next nI
// // 		EndIf
// // 	EndIf

// // 	oView := FWFormView():New()
// // 	// Objeto do model a se associar a view.
// // 	oView:SetModel(oModel)
// // 	// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
// // 	// oStruct - Objeto do model a se associar a view.
// // 	// cLinkID - Representa o ID criado no Model ,Só é necessári o caso estamos mundando o ID no View.
// // 	oView:AddField( "GFEA050_GWN" , oStructGWN, /*cLinkID*/ )	//
// // 	// cID		  	Id do Box a ser utilizado
// // 	// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. é a qtd de pixel exato)
// // 	// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas criações uma dentro da outra.
// // 	// lFixPixel	Determina que o valor passado no nPercHeight é na verdade a qtd de pixel a ser usada.
// // 	// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, é necessário informar o cIDSheet
// // 	// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.

// // 	oView:CreateHorizontalBox( "MASTER" , 100 )
// // 	oView:SetOwnerView( "GFEA050_GWN" , "MASTER" )

// // 	oView:AddUserButton('Pesquisar Negociações', 'MAGIC_BMP', {|oModel| GFE50VERNG(oModel)})
// // 	oView:AddUserButton('Viagem/Consolidação', 'MAGIC_BMP', {|oModel| GFE50NVG()})

// // 	If GFXCP12118("GWT_NRROM")
// // 		If lExcluir = .T.
// // 			oView:AddUserButton( STR0132, 'MAGIC_BMP', {|oModel| GFEA050E(GWN_NRROM,,2)} ) //"Roteiro"
// // 		EndIf
// // 	EndIf
// // 	lExcluir := .F.
// // Return oView

// /*
// Integração Com OMS - Desabilita campos
// X3_WHEN do campo GWN_CDTRP.
// */
// Static Function GFEA050WCT()
// Return Inclui .OR. SuperGetMV('MV_GFEI12',,'1') $ "2N" .OR. GWN->GWN_ORI $ "14"

// Static Function GFEDOCCAR()
// 	Local lPedHD 	:= .F.
// 	Local lIncGX0 	:= .F.
// 	Local lAtuGX0 	:= .F.
// 	Local lDelGX0 	:= .F.
// 	Local cAliasGW1 := Nil
// 	Local oMovDocto := Nil
// 	Private aAuxDc 	:= {}

// 	//Ponto de entrada validação Vicunha
// 	If ExistBlock("GFEA0506")
// 		If ExecBlock("GFEA0506",.F.,.F.,{"1"})
// 			Return
// 		EndIf
// 	EndIf

// 	// Integração com OMS e registro de origem ERP
// 	If GFEERPOMS()
// 		GFEMessage(5, GFEA050013, "A integração com o SIGAOMS está ativada, esta operação deverá ser realizada naquele módulo", "Acesse o modulo SIGAOMS para realizar a operação.")	// "A integração com o SIGAOMS está ativada, esta operação deverá ser realizada naquele módulo", "Acesse o modulo SIGAOMS para realizar a operação."
// 		Return
// 	EndIf

// 	//Integração com o SIGATMS e registro de origem TMS
// 	If GFEINTTMS()
// 		GFEMessage(5, GFEA050014, "Não é permitido alterar a relação de Documentos de um Romaneio gerado pela integração com o SIGATMS.", "Acesse o modulo SIGATMS para efetuar alterações na relação de documentos com o Romaneio.")	//"Não é permitido alterar a relação de Documentos de um Romaneio gerado pela integração com o SIGATMS.", "Acesse o modulo SIGATMS para efetuar alterações na relação de documentos com o Romaneio."
// 		Return
// 	EndIf

// 	If GWN->GWN_SIT == "3"
// 		GFEMessage(5,GFEA050015, "Romaneio já foi liberado", "Reabra o Romaneio para permitir alterações ou exclusões.") // "Romaneio já foi liberado" / "Reabra o Romaneio para permitir alterações ou exclusões."
// 	ElseIf GWN->GWN_SIT == "4"
// 		GFEMessage(5, GFEA050016, "Romaneio já foi encerrado.", "Realize o estorno de todo o processo para permitir manutenções no Romaneio.") // "Romaneio já foi encerrado." / "Realize o estorno de todo o processo para permitir manutenções no Romaneio."
// 	Else

// 		// Como não tem como mapear o tipo de operação para incluir ou excluir, Bloco armazena em array os DCs associados ao romaneio para comparar apos associação na tela
// 		/*If GFXTB1212210("GX0")
// 			oMovDocto := GFEMovtoCarga():New()
// 			oMovDocto:setBranch(GWN->GWN_FILIAL)
// 			oMovDocto:setNumRomaneio(GWN->GWN_NRROM)

// 			cAliasGW1 := oMovDocto:SearchDCByRomaneio()
// 			While (cAliasGW1)->(!Eof())
// 				GW1->(dbGoTo( (cAliasGW1)->RECNUM ))
// 				aadd(aAuxDc, {GW1->GW1_FILIAL, GW1->GW1_CDTPDC, GW1->GW1_EMISDC, GW1->GW1_SERDC, GW1->GW1_NRDC, GW1->GW1_DTEMIS})

// 				(cAliasGW1)->(dbSkip())
// 			EndDo
// 			(cAliasGW1)->(dbCloseArea())

// 			oMovDocto:Destroy( oMovDocto )
// 		EndIf*/

// 		If ExistBlock("XAliMKB2")
// 			lPedHD := ExecBlock("XAliMKB2",.F.,.F.,nil)
// 		EndIf

// 		If IIf(lPedHD,GFEA050B(cParamF12),GFEA050A(cParamF12))  // 1-Romaneio Calculado

// 			If GWN->GWN_CALC != "2"
// 				RecLock("GWN", .F.)
// 				GWN->GWN_CALC := "4" // Romaneio necessita recálculo
// 				GWN->GWN_MTCALC := "Foram adicionados ou retirados Documentos de Carga relacionados ao Romaneio."
// 				GWN->GWN_DTCALC := CToD("  /  /    ")
// 				GWN->GWN_HRCALC := ""
// 				GWN->(MsUnLock())
// 			EndIf

// 			If !Empty(GWN->GWN_VIAGEM)
// 				GFE58ATVG(GWN->GWN_VIAGEM,'4',"Foram adicionados ou retirados Documentos de Carga relacionados ao Romaneio " + GWN->GWN_NRROM + ".",CToD("  /  /    "),'',GWN->GWN_FILIAL,GWN->GWN_NRROM,.T.)
// 			EndIf
// 			If GWN->GWN_CALC != "2"
// 				// Verifica se há algum documento de carga vinculado ao romaneio
// 				If GFXCP1212210('GW1_FILROM')
// 					cAliasClc := GetNextAlias()
// 					BeginSql Alias cAliasClc
// 						SELECT R_E_C_N_O_ AS RECNUM
// 						FROM %Table:GW1% GW1
// 						WHERE GW1.GW1_FILROM = %Exp:GWN->GWN_FILIAL%
// 						AND GW1.GW1_NRROM = %Exp:GWN->GWN_NRROM%
// 						AND GW1.%NotDel%
// 						ORDER BY GW1_FILIAL
// 					EndSql
// 					If (cAliasClc)->( !Eof() )
// 						If MsgYesNo("Deseja recalcular este romaneio?","Doc. Carga")	// "Deseja recalcular este romaneio?" // "Doc. Carga"
// 							GW1->(dbGoto( (cAliasClc)->RECNUM) )
// 							GFE050CALC() // Recalcula o romaneio
// 						EndIf
// 					EndIf
// 					(cAliasClc)->( dbCloseArea() )
// 				Else
// 					GW1->( dbSetOrder(09) )
// 					If GW1->( dbSeek(xFilial("GW1")+GWN->GWN_NRROM) )
// 						If MsgYesNo("Deseja recalcular este romaneio?","Doc. Carga")	// "Deseja recalcular este romaneio?" // "Doc. Carga"
// 							GFE050CALC() // Recalcula o romaneio
// 						EndIf
// 					EndIf
// 				EndIf
// 			EndIf

// 			// Gravação de dados para relatorio de Movimentação de Carga
// 			/*If GFXTB1212210("GX0")
// 				If Len(aAuxDc) > 0
// 					oMovDocto := GFEMovtoCarga():New()
// 					oMovDocto:setBranch(GWN->GWN_FILIAL)
// 					oMovDocto:setNumRomaneio(GWN->GWN_NRROM)

// 					cAliasGW1 := oMovDocto:SearchDCByRomaneio()
// 					If (cAliasGW1)->(Eof())
// 						lDelGX0 := .T.
// 					Else
// 						lAtuGX0 := .T.
// 					EndIf
// 					(cAliasGW1)->(dbCloseArea())

// 					oMovDocto:Destroy( oMovDocto )
// 				Else
// 					oMovDocto := GFEMovtoCarga():New()
// 					oMovDocto:setBranch(GWN->GWN_FILIAL)
// 					oMovDocto:setNumRomaneio(GWN->GWN_NRROM)

// 					cAliasGW1 := oMovDocto:SearchDCByRomaneio()
// 					If (cAliasGW1)->(!Eof())
// 						GW1->(dbGoTo( (cAliasGW1)->RECNUM ))
// 						oMovDocto:setBranch(GW1->GW1_FILIAL)
// 						oMovDocto:setTipoNF(GW1->GW1_CDTPDC)
// 						oMovDocto:setEmissorNF(GW1->GW1_EMISDC)
// 						oMovDocto:setSerieNF(GW1->GW1_SERDC)
// 						oMovDocto:setNumeroNF(GW1->GW1_NRDC)
// 						cAliasGX0 := oMovDocto:SearchByDC()
// 						If (cAliasGX0)->(!Eof())
// 							lAtuGX0 := .T.
// 						Else
// 							lIncGX0 := .T.
// 						EndIf
// 					EndIf
// 					(cAliasGW1)->(dbCloseArea())

// 					oMovDocto:Destroy( oMovDocto )
// 				EndIf

// 				If lIncGX0
// 					LoadMovtoDoc(3)
// 				ElseIf lAtuGX0
// 					LoadMovtoDoc(4)
// 				ElseIf lDelGX0
// 					LoadMovtoDoc(5)
// 				EndIf
// 			EndIf*/
// 		EndIf

// 		GFE50LbRom() // verifica e libera o romaneio posicionado
// 	EndIf
// Return

// Static Function GFEERPOMS()
// Return SuperGetMV('MV_GFEI12',,'1') $ "1S" .AND. GWN->GWN_ORI == "2"
// //-------------------------------------------------------------------
// /*GFEINTTMS
// Verifica se há integração com TMS e se o registro tem origem SIGATMS
// Se ambos forem verdadeiro, retorna .T.
// Esta função desabilita funcionalidades que deverão ser tratadas no módulo de SIGATMS:
// Vínculo de Documento de Carga, Eliminar o Romaneio ou Alterar a Transportadora

// @author Felipe mendes
// @since 13/09/2013
// @version 1.0
// /*/
// //-------------------------------------------------------------------
// Static Function GFEINTTMS()
// Return SuperGetMv("MV_TMSGFE",.F.,.F.) .AND. GWN->GWN_ORI == "3"
// //-------------------------------------------------------------------

// Static Function GFEINT3TMS()
// Return SuperGetMv("MV_TMS3GFE",.F.,.F.) $ "F;S;C" .AND. GWN->GWN_ORI == "3"

// Static Function GFEA050ALT()
// 	Local lRet := .T.

// 	//Ponto de entrada validação Vicunha
// 	If ExistBlock("GFEA0506")
// 		If ExecBlock("GFEA0506",.F.,.F.,{"4"})
// 			lRet := .F.
// 		EndIf
// 	EndIf
// 	If lRet
// 		FWExecView("",'GFEA050',4,,{||.T.})
// 	EndIf
// Return lRet

// Static Function GFEA050EXC()
// 	Local lRet := .T.

// 	// Integração com OMS e registro de origem ERP
// 	If GFEERPOMS()
// 		GFEMessage(5,GFEA050009,GFEMsgFmt("Operação não permitida, a integração com o módulo [VAR01] está ativada.",{{"[VAR01]", "SIGAOMS"}}),GFEMsgFmt("Operação deverá ser realizada no módulo [VAR01]!",{{"[VAR01]", "SIGAOMS"}})) //"Operação não permitida, a integração com o módulo [VAR01] está ativada." , "Operação deverá ser realizada no módulo [VAR01]!"
// 		lRet := .F.
// 	EndIf

// 	//Integração com o SIGATMS e registro de origem TMS
// 	If GFEINTTMS()
// 		GFEMessage(5,GFEA050010,GFEMsgFmt("Operação não permitida, a integração com o módulo [VAR01] está ativada.",{{"[VAR01]", "SIGATMS"}}),GFEMsgFmt("Operação deverá ser realizada no módulo [VAR01]!",{{"[VAR01]", "SIGATMS"}})) //"Operação não permitida, a integração com o módulo [VAR01] está ativada." , "Operação deverá ser realizada no módulo [VAR01]!"
// 		lRet := .F.
// 	EndIf
	
// 	If lRet
// 		//Ponto de entrada validação Vicunha
// 		If ExistBlock("GFEA0506")
// 			If ExecBlock("GFEA0506",.F.,.F.,{"3"})
// 				lRet := .F.
// 			EndIf
// 		EndIf
// 	EndIf

// 	If lRet
// 		lExcluir := .T. // Variável para criar grid de roteiro se for exclusão
// 		FWExecView("", 'GFEA050', MODEL_OPERATION_DELETE,, {|| .T.})
// 	EndIf
// Return lRet

// Static Function GFEA050REA(lAuto)
// 	Local oDlg      := Nil
// 	Local aAreaGWF  := GWF->( GetArea() )
// 	Local aAreaGW1  := GW1->( GetArea() )
// 	Local aAreaGWH  := GWH->( GetArea() )
// 	Local aAreaGWJ  := GWJ->( GetArea() )
// 	Local lRet      := .T.
// 	Local aRetPE    := {}
// 	Local cAliasGWF := Nil
// 	Local cAliasGW1 := Nil
// 	Local cWhere    := Nil

// 	Default lAuto  := .F.

// 	Private cTexto1

// 	If GWN->GWN_SIT != "3"	// Liberado
// 		If !lAuto
// 			GFEMessage(5,GFEA050001,"Romaneio não está liberado","Verifique o romaneio selecionado ou a ação escolhida para esse romaneio.") //"Romaneio não está liberado" , "Verifique o romaneio selecionado ou a ação escolhida para esse romaneio."
// 		EndIf

// 		lRet := .F.
// 	EndIf

// 	If lRet .And.GWN->GWN_AGRUP == "1"
// 		If !lAuto
// 			GFEMessage(5,GFEA050002,"Romaneio possui um agrupamento de cálculos!","Para realizar a reabertura é necessário a exclusão deste cálculo no programa de Frete Combinado.") //"Romaneio possui um agrupamento de cálculos!" , "Para realizar a reabertura é necessário a exclusão deste cálculo no programa de Frete Combinado."
// 		EndIf

// 		lRet := .F.
// 	EndIf

// 	If lRet .And. GFEVerCmpo({"GWN_FECHAM"}) .AND. GWN->GWN_FECHAM == "3"
// 		If !lAuto
// 			GFEMessage(5,GFEA050003,"Apuração do período de fechamento foi efetuada, portanto não é possível reabrir o Romaneio.","Verifique o romaneio selecionado ou a ação escolhida para esse romaneio.") //"Apuração do período de fechamento foi efetuada, portanto não é possível reabrir o Romaneio." , "Verifique o romaneio selecionado ou a ação escolhida para esse romaneio."
// 		EndIf
		
// 		lRet := .F.
// 	EndIf

// 	If lRet .And. !Empty(GWN->GWN_VIAGEM)
// 		If PosicionaGWP()
// 			If GWP->GWP_SIT == '2'
// 				If !lAuto
// 					GFEMessage(5,GFEA050004,GFEMsgFmt("Já ocorreu a partida da viagem [VAR01] que está relacionada, portanto não é possível reabrir o Romaneio.",{{"[VAR01]", GWP->GWP_VIAGEM}}),"Verifique o romaneio selecionado ou a ação escolhida para esse romaneio.") //"Já ocorreu a partida da viagem [VAR01] que está relacionada, portanto não é possível reabrir o Romaneio." , "Verifique o romaneio selecionado ou a ação escolhida para esse romaneio."
// 				EndIf
				
// 				lRet := .F.
// 			EndIf
// 		Else
// 			lRet := .F.
// 		EndIf
// 	EndIf

// 	//Ponto de entrada validação Vicunha
// 	If lRet .And. ExistBlock("GFEA0506")
// 		If ExecBlock("GFEA0506",.F.,.F.,{"2"})
// 			lRet := .F.
// 		EndIf
// 	EndIf

// 	// Validar se o romaneio possui cálculos vinculados a contrato com autônomo
// 	If lRet
// 		If GFXCP1212210('GW1_FILROM')
// 			cWhere := "GWF.GWF_FILROM = '" + GWN->GWN_FILIAL + "'"
// 		Else
// 			cWhere := "GWF.GWF_FILIAL = '" + GWN->GWN_FILIAL + "'"
// 		EndIf
// 		cWhere := "%" + cWhere + "%"

// 		cAliasGWF := GetNextAlias()
// 		BeginSql Alias cAliasGWF
// 			SELECT GWF_FILPRE, GWF_NRPREF, GWF_NRCONT, GWF.R_E_C_N_O_ AS GWFRECNO
// 			FROM %table:GWF% GWF
// 			WHERE %Exp:cWhere%
// 			AND GWF.GWF_NRROM = %Exp:GWN->GWN_NRROM%
// 			AND GWF.%NotDel%
// 			ORDER BY GWF.GWF_FILIAL,GWF.GWF_NRCALC
// 		EndSql
// 		While !(cAliasGWF)->(Eof()) .And. lRet
// 			If !Empty((cAliasGWF)->GWF_NRCONT)
// 				If !lAuto
// 					GFEMessage(5,GFEA050005,"Romaneio possui cálculos vinculados a contrato com autônomo e não pode ser reaberto.","Verifique o romaneio selecionado ou a ação escolhida para esse romaneio.") //"Romaneio possui cálculos vinculados a contrato com autônomo e não pode ser reaberto." , "Verifique o romaneio selecionado ou a ação escolhida para esse romaneio."
// 				EndIf

// 				lRet := .F.
// 			EndIf
			
// 			If lRet
// 				GWJ->( dbSetOrder(1) )
// 				If GWJ->( dbSeek((cAliasGWF)->GWF_FILPRE + (cAliasGWF)->GWF_NRPREF) ).AND. GWJ->GWJ_SIT <> "4"
// 					If !lAuto
// 						GFEMessage(5,GFEA050006,"Romaneio possui pré-fatura " + ". " + "Verifique o romaneio selecionado ou a ação escolhida para esse romaneio." + ".","Verifique o romaneio selecionado ou a ação escolhida para esse romaneio.") //"Romaneio possui pré-fatura "  , "Verifique o romaneio selecionado ou a ação escolhida para esse romaneio."
// 					EndIf

// 					lRet := .F.
// 				EndIf
// 			EndIf

// 			(cAliasGWF)->(dbSkip())
// 		EndDo	
// 		(cAliasGWF)->(dbCloseArea())
// 	EndIf
	
// 	If lRet
// 		If GFXCP1212210('GW1_FILROM')
// 			cWhere := "GW1.GW1_FILROM = '" + GWN->GWN_FILIAL + "'"
// 		Else
// 			cWhere := "GW1.GW1_FILIAL = '" + GWN->GWN_FILIAL + "'"
// 		EndIf
// 		cWhere := "%" + cWhere + "%"

// 		cAliasGW1 := GetNextAlias()
// 		BeginSql Alias cAliasGW1
// 			SELECT GW1_FILIAL, GW1_CDTPDC, GW1_EMISDC, GW1_SERDC, GW1_NRDC, GW1.R_E_C_N_O_ AS GW1RECNO
// 			FROM %table:GW1% GW1
// 			WHERE %Exp:cWhere%
// 			AND GW1.GW1_NRROM  = %Exp:GWN->GWN_NRROM%
// 			AND GW1.%NotDel%
// 			ORDER BY GW1.GW1_FILIAL,GW1.GW1_NRDC
// 		EndSql
// 		While !(cAliasGW1)->(Eof()) .And. lRet
// 			GWU->( dbSetOrder(1) )
// 			GWU->( dbSeek((cAliasGW1)->GW1_FILIAL + (cAliasGW1)->GW1_CDTPDC + (cAliasGW1)->GW1_EMISDC + (cAliasGW1)->GW1_SERDC + (cAliasGW1)->GW1_NRDC) )
// 			Do While lRet .And. GWU->( !Eof() ) .And. (cAliasGW1)->GW1_FILIAL == GWU->GWU_FILIAL ;
// 												.And. (cAliasGW1)->GW1_CDTPDC == GWU->GWU_CDTPDC ;
// 												.And. (cAliasGW1)->GW1_EMISDC == GWU->GWU_EMISDC ;
// 												.And. (cAliasGW1)->GW1_SERDC == GWU->GWU_SERDC ;
// 												.And. (cAliasGW1)->GW1_NRDC == GWU->GWU_NRDC
// 				If !Empty(GWU->GWU_DTENT)
// 					If !lAuto
// 						GFEMessage(5,GFEA050007, "Não é possível reabrir Romaneios vinculados a Documentos de Carga entregues.","Verifique o romaneio selecionado ou a ação escolhida para esse romaneio.") //"Não é possível reabrir Romaneios vinculados a Documentos de Carga entregues." , "Verifique o romaneio selecionado ou a ação escolhida para esse romaneio."
// 					EndIf

//  					lRet := .F.
// 				EndIf
// 				GWU->( dbSkip() )
// 			EndDo

// 			If lRet
// 				GW4->( dbSetOrder(2) )
// 				If GW4->( dbSeek(xFilial("GW4") + (cAliasGW1)->GW1_EMISDC + (cAliasGW1)->GW1_SERDC + (cAliasGW1)->GW1_NRDC + (cAliasGW1)->GW1_CDTPDC) )
// 					If !lAuto
// 						GFEMessage(5,GFEA050008, "O Romaneio possui documentos de frete relacionados aos seus documentos de carga, portanto, não poderá ser reaberto.","Verifique o romaneio selecionado ou a ação escolhida para esse romaneio.") //"O Romaneio possui documentos de frete relacionados aos seus documentos de carga, portanto, não poderá ser reaberto." , "Verifique o romaneio selecionado ou a ação escolhida para esse romaneio."
// 					EndIf
					
// 					lRet := .F.
// 				EndIf
// 			EndIf

// 			(cAliasGW1)->(dbSkip())
// 		EndDo	
// 		(cAliasGW1)->(dbCloseArea())
// 	EndIf
	
// 	//Ponto de entrada para validação adicional da reabertura do romaneio,
// 	//sendo que o retorno deve ser um array no seguinte formato:
// 	//aRetPE[1] (Lógico)    Verdadeiro ou falso (.T. ou .F.), resultado da validação do romaneio
// 	//aRetPE[2] (Caracter)  Mensagem de erro, caso o retorno do primeiro elemento do array seja falso
// 	If ExistBlock('GFEA0502')
// 		aRetPE := ExecBlock('GFEA0502',.F.,.F.)
		
// 		//Verifica se o retorno do ponto de entrada é válido
// 		If ValType(aRetPE) == 'A' .And. !Empty(aRetPE)
// 			If !aRetPE[1]
// 				GFEMsgErro(aRetPE[2])
// 				lRet := .F.
// 			EndIf
// 		EndIf
// 	EndIf

// 	RestArea(aAreaGW1)
// 	RestArea(aAreaGWH)
// 	RestArea(aAreaGWF)
// 	RestArea(aAreaGWJ)

// 	If lRet
// 		If !lAuto .And. !GFEINT3TMS()
// 			DEFINE MSDIALOG oDlg TITLE "Reabrir Romaneio" From 4,0 To 16,60 OF oMainWnd //"Reabrir Romaneio"
// 			@ 4, 006  SAY "Motivo da Reabertura:" SIZE 70,7 PIXEL OF oDlg //"Motivo da Reabertura:"
// 			// Usando o New
// 			oTMultiget1 := TMultiget():New(13,06,{|u|If(Pcount()>0,cTexto1:=u,cTexto1)},;
// 			oDlg,225,60,,,,,,.T.)

// 			oButtonOK   := tButton():New(75,5,'OK',oDlg,{|| If(GFEABTREA(),oDlg:End(),NIL)},25,10,,,,.T.)
// 			oButtonCanc := tButton():New(75,35,"Cancelar",oDlg,{||(oDlg:End())},25,10,,,,.T.) //"Cancelar"

// 			ACTIVATE MSDIALOG oDlg
// 		Else
// 			If IsInCallStack("GFEX101VAL")
// 				cTexto1:= "Reabertura automatica realizada pelo Processo de Liberação do Doc Carga Datasul." //"Reabertura automatica realizada pelo Processo de Liberação do Doc Carga Datasul."
// 				Processa({|| lRet:= GFEABTREA()})
// 			Else
// 				cTexto1:= "Reabertura automatica realizado pelo Modulo SIGATMS." //"Reabertura automatica realizado pelo Modulo SIGATMS."
// 				Processa({|| lRet:= GFEABTREA()})
// 			EndIf
// 		EndIf
// 	EndIf

// 	//Ponto de entrada Vicunha
// 	If lRet .And. ExistBlock("GFEA0507")
// 		ExecBlock("GFEA0507",.F.,.F.)
// 	EndIf

// 	// Gravação de dados para relatorio de Movimentação de Carga
// 	/*If lRet .And. GFXTB1212210("GX0")
// 		If GFXCP1212210('GW1_FILROM')
// 			cWhere := "GW1.GW1_FILROM = '" + GWN->GWN_FILIAL + "'"
// 		Else
// 			cWhere := "GW1.GW1_FILIAL = '" + GWN->GWN_FILIAL + "'"
// 		EndIf
// 		cWhere := "%" + cWhere + "%"

// 		cAliasGW1 := GetNextAlias()
// 		BeginSql Alias cAliasGW1
// 			SELECT GW1_FILIAL, GW1_CDTPDC, GW1_EMISDC, GW1_SERDC, GW1_NRDC, GW1.R_E_C_N_O_ AS GW1RECNO
// 			FROM %table:GW1% GW1
// 			WHERE %Exp:cWhere%
// 			AND GW1.GW1_NRROM  = %Exp:GWN->GWN_NRROM%
// 			AND GW1.%NotDel%
// 			ORDER BY GW1.GW1_FILIAL,GW1.GW1_NRDC
// 		EndSql
// 		While !(cAliasGW1)->(Eof())
// 			oMovDocto := GFEMovtoCarga():New()

// 			// Atribuição de dados GW1
// 			oMovDocto:setBranch((cAliasGW1)->GW1_FILIAL)
// 			oMovDocto:setTipoNF((cAliasGW1)->GW1_CDTPDC)
// 			oMovDocto:setEmissorNF((cAliasGW1)->GW1_EMISDC)
// 			oMovDocto:setSerieNF((cAliasGW1)->GW1_SERDC)
// 			oMovDocto:setNumeroNF((cAliasGW1)->GW1_NRDC)

// 			oMovDocto:setFilRomaneio(GWN->GWN_FILIAL)
// 			oMovDocto:setNumRomaneio(GWN->GWN_NRROM)
// 			oMovDocto:setClassFrete(GWN->GWN_CDCLFR)
// 			oMovDocto:setDescClassFrete(Posicione("GUB", 1, xFilial("GUB") + GWN->GWN_CDCLFR, "GUB_DSCLFR"))
// 			oMovDocto:setTipoOper(GWN->GWN_CDTPOP)
// 			oMovDocto:setDescTipoOperacao(Posicione("GV4", 1, xFilial("GV4") + GWN->GWN_CDTPOP, "GV4_DSTPOP"))
// 			oMovDocto:setDataSaida(ctod(" "))

// 			cAliasGX0 := oMovDocto:SearchByDC()
// 			While (cAliasGX0)->(!EoF()) .And. (cAliasGX0)->GX0_FILIAL == (cAliasGW1)->GW1_FILIAL ;
// 										.And. (cAliasGX0)->GX0_CDTPDC == (cAliasGW1)->GW1_CDTPDC ;
// 										.And. (cAliasGX0)->GX0_EMISDC == (cAliasGW1)->GW1_EMISDC ;
// 										.And. (cAliasGX0)->GX0_SERDC == (cAliasGW1)->GW1_SERDC ;
// 										.And. (cAliasGX0)->GX0_NRDC == (cAliasGW1)->GW1_NRDC
// 				GX0->(dbGoTo( (cAliasGX0)->RECNUM ))
// 				oMovDocto:UpdateRomaneio()		// Alteração de Registros na tabela GX0

// 				(cAliasGX0)->(dbSkip())
// 			EndDo
// 			(cAliasGX0)->(dbCloseArea())

// 			oMovDocto:Destroy( oMovDocto )

// 			(cAliasGW1)->(dbSkip())
// 		EndDo	
// 		(cAliasGW1)->(dbCloseArea())
// 	EndIf*/
	
// Return lRet

// Static Function GFEABTREA()
// 	Local nOpc      := 0
// 	Local lRet      := .T.
// 	Local cAliasGW1 := Nil
// 	Local cWhere    := Nil
// 	Local aAreaGW1  := GW1->( GetArea() )

// 	If !Empty(cTexto1)
// 		RecLock('GWN', nOpc == 4 )
// 		GWN->GWN_SIT := "1"
// 		GWN->GWN_DTSAI := STOD("  /  /  ")
// 		GWN->GWN_HRSAI := ""
// 		If GFEVerCmpo({"GWN_FECHAM"})
// 			GWN->GWN_DTRET := STOD("  /  /  ")
// 			GWN->GWN_HRRET := ""
// 			GWN->GWN_HODSAI := 0
// 			GWN->GWN_HODRET := 0
// 		EndIf
// 		If GFEVerCmpo({"GWN_MOTREA"})
// 			GWN->GWN_MOTREA := cTexto1
// 			GWN->GWN_DTREAB := dDatabase
// 			GWN->GWN_HRREAB := Time()
// 			GWN->GWN_USUREA := cUserName
// 		EndIf
// 		GWN->( MsUnLock() )

// 		If GFXCP1212210('GW1_FILROM')
// 			cWhere := "GW1.GW1_FILROM = '" + GWN->GWN_FILIAL + "'"
// 		Else
// 			cWhere := "GW1.GW1_FILIAL = '" + GWN->GWN_FILIAL + "'"
// 		EndIf
// 		cWhere := "%" + cWhere + "%"

// 		cAliasGW1 := GetNextAlias()
// 		BeginSql Alias cAliasGW1
// 			SELECT GW1_FILIAL, GW1_CDTPDC, GW1_EMISDC, GW1_SERDC, GW1_NRDC, GW1.R_E_C_N_O_ AS GW1RECNO
// 			FROM %table:GW1% GW1
// 			WHERE %Exp:cWhere%
// 			AND GW1.GW1_NRROM  = %Exp:GWN->GWN_NRROM%
// 			AND GW1.%NotDel%
// 			ORDER BY GW1.GW1_FILIAL,GW1.GW1_NRDC
// 		EndSql
// 		While !(cAliasGW1)->(Eof())
// 			GW1->(dbGoTo( (cAliasGW1)->GW1RECNO ))

// 			RecLock('GW1', .F.)
// 			GW1->GW1_DTSAI := STOD("  /  /  ")
// 			GW1->GW1_HRSAI := ""
// 			s_GFEI20_1 := SuperGetMV("MV_GFEI20",, '1')
// 			If s_GFEI20_1 == '1'
// 				If GFEVerCmpo({"GW1_SITFT"})
// 					GW1->GW1_SITFT := "5"
// 				EndIf
// 			EndIf
// 			GW1->( MsUnLock() )

// 			//Limpa a data de previsão de entrega dos trechos
// 			GWU->( dbSetOrder(1) )
// 			GWU->(dbSeek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC))
// 			Do While GWU->(!Eof()) .And. GW1->GW1_FILIAL == GWU->GWU_FILIAL;
// 								   .And. GW1->GW1_CDTPDC == GWU->GWU_CDTPDC;
// 								   .And. GW1->GW1_EMISDC == GWU->GWU_EMISDC;
// 								   .And. GW1->GW1_SERDC == GWU->GWU_SERDC;
// 								   .And. GW1->GW1_NRDC == GWU->GWU_NRDC

// 				RecLock('GWU', .F.)
// 					GWU->GWU_DTPENT	:= STOD("  /  /  ")
// 					GWU->GWU_HRPENT	:= ""
// 				If GFXCP12137("GWU_DTPENO")	
// 					GWU->GWU_DTPENO := STOD("  /  /  ")
// 					GWU->GWU_HRPENO := ""
// 					GWU->GWU_QTPRAZ := 0
// 					GWU->GWU_TPPRAZ := ""
// 				EndIf
// 				GWU->( MsUnLock() )
// 				GWU->(dbSkip())
// 			EndDo

// 			(cAliasGW1)->(dbSkip())
// 		EndDo	
// 		(cAliasGW1)->(dbCloseArea())

// 	Else
// 		GFEMsgErro("Informe motivo da reabertura") //"Informe motivo da reabertura"
// 		lRet := .F.
// 	EndIf
// 	RestArea( aAreaGW1 )
// Return lRet

// Static Function GFEA050BLO()
// 	Local lRet := .T.
// 	Local nOpc := 0

// 	If GWN->GWN_SIT == "4"
// 		GFEMessage(5, GFEA050017, "Romaneio já está encerrado, portanto não poderá ser bloqueado.", "Somente Romaneios não encerrados podem ser bloqueados.")	//"Romaneio já está encerrado, portanto não poderá ser bloqueado." / "Somente Romaneios não encerrados podem ser bloqueados."
// 		Return
// 	EndIf

// 	//Ponto de entrada validação Vicunha
// 	If ExistBlock("GFEA0506")
// 		If ExecBlock("GFEA0506",.F.,.F.,{"5"})
// 			Return
// 		EndIf
// 	EndIf

// 	GW1->( dbSetOrder(9) )
// 	GW1->( dbSeek(xFilial("GW1") + GWN->GWN_NRROM) )

// 	Do While GW1->( !Eof() ) .And. GW1->GW1_FILIAL == xFilial("GW1") .And. GW1->GW1_NRROM == GWN->GWN_NRROM
// 		GWH->( dbSetOrder(2) )
// 		GWH->( dbSeek(xFilial("GWH") + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC) )

// 		Do While GWH->( !Eof() ) ;
// 			.And. GWH->GWH_FILIAL == xFilial("GWH") ;
// 			.And. GWH->GWH_CDTPDC == GW1->GW1_CDTPDC ;
// 			.And. GWH->GWH_EMISDC == GW1->GW1_EMISDC ;
// 			.And. GWH->GWH_SERDC == GW1->GW1_SERDC ;
// 			.And. GWH->GWH_NRDC == GW1->GW1_NRDC

// 			GWF->( dbSetOrder(1) )
// 			If GWF->( dbSeek(xFilial("GWF") + GWH->GWH_NRCALC) )
// 				GWJ->( dbSetOrder(1) )
// 				If GWJ->( dbSeek(xFilial("GWJ") + GWF->GWF_NRPREF) )
// 					If GWJ->GWJ_SIT <> "4"
// 						/*PutHelp("PFRM050C",{"Não é possível bloquear romaneio"},{"Não é possível bloquear romaneio"},{"Não é possível bloquear romaneio"}) //"Não é possível bloquear romaneio"
// 						PutHelp("SFRM050C",{"Verifique o romaneio selecionado ou a ação escolhida para esse romaneio."},{"Verifique o romaneio selecionado ou a ação escolhida para esse romaneio."},{"Verifique o romaneio selecionado ou a ação escolhida para esse romaneio."}) //"Romaneio possui pré-fatura"
// 						HELP(" ",1,"FRM050C","FRM050C" )*/
// 						GFEMsgErro("Não é possível bloquear romaneio"+". "+"Verifique o romaneio selecionado ou a ação escolhida para esse romaneio."+".") //"Não é possível bloquear romaneio" , "Romaneio possui pré-fatura "
// 						lRet := .F.
// 						Exit
// 					EndIf
// 				EndIf
// 			EndIf
// 			GWH->( dbSkip() )
// 		EndDo

// 		If !lRet
// 			Exit
// 		EndIf
// 		GW1->( dbSkip() )
// 	EndDo

// 	If lRet == .T.
// 		If GWN->GWN_BLOQPF == "2"
// 			If msgyesno("Deseja bloquear romaneio para emissão de pre-fatura?") //"Deseja bloquear romaneio?" //"Deseja bloquear romaneio para emissão de pre-fatura?"
// 				RecLock('GWN', nOpc == 4 )
// 					GWN->GWN_BLOQPF := "1"
// 				GWN->( MsUnLock() )
// 			EndIf
// 		else
// 			If msgyesno("Deseja desbloquear romaneio para emissão de pre-fatura?") //"Deseja desbloquear romaneio?" //"Deseja desbloquear romaneio para emissão de pre-fatura?"
// 				RecLock('GWN', nOpc == 4 )
// 					GWN->GWN_BLOQPF := "2"
// 				GWN->( MsUnLock() )
// 			EndIf
// 		EndIf
// 	EndIf
// Return

// Static Function GFEA050LIB(lAuto,cMsg,dData,cHora,lValida)//sempre passar o parametro cMsg por referencia
// 	Local oDlg       := Nil
// 	Local cFilRom    := GWN->GWN_FILIAL
// 	Local cNrRom     := GWN->GWN_NRROM
// 	Local cRastr     := GWN->GWN_RASTR
// 	Local nHod       := 0
// 	Local lRet       := .T.
// 	Local lWhenHod   := .T.
// 	Local aRetPE     := {}
// 	Local cPicHodSai := Alltrim(GetSx3Cache("GWN_HODSAI", "X3_PICTURE"))
// 	Local cAliasGW1  := Nil
// 	Local cWhere     := Nil
// 	Local lWhenDtS   := .t.
// 	Local lWhenHrS   := .t.
// 	Local lPE18		 := ExistBlock("GFE05018")

// 	Default dData   := DDATABASE
// 	Default cHora   := SubStr(Time(), 1, 5)
// 	Default lAuto   := .F.
// 	Default cMsg    := ""
// 	Default lValida := .F.

// 	If GfeVerCmpo({"GWN_HODSAI"})
// 		nHod := GWN->GWN_HODSAI
// 	Else
// 		nHod := 0
// 		lWhenHod := .F.
// 	EndIf

// 	If GWN->GWN_SIT == "3" .And. lValida
// 		If Type("_lSemHelp") == "U"  // Definir varivel " Private _lSemHelp := .F.", varivel foi declarada nas funções GFEA050LIBL() e  GFEA081.CalculaRomaneios()
// 			GFEMessage(5, GFEA050018, "Romaneio já foi liberado", "Selecione um Romaneio que não esteja liberado.") 	//"Selecione um Romaneio que não esteja liberado." / "Romaneio já foi liberado"
// 		EndIf
// 		cMsg := "Romaneio já foi liberado"
// 		lRet := .F.
// 	ElseIf GWN->GWN_SIT == "4"
// 		If Type("_lSemHelp") == "U" // Definir varivel " Private _lSemHelp := .F."varivel foi declarada nas funções GFEA050LIBL() e  GFEA081.CalculaRomaneios()
// 			GFEMessage(5, GFEA050019, "Romaneio já está encerrado.", "Selecione um Romaneio que não esteja encerrado para continuar.")	 	//"Romaneio já está encerrado." / "Selecione um Romaneio que não esteja encerrado para continuar."
// 		EndIf
// 		cMsg := "Romaneio já está encerrado."	//"Romaneio já está encerrado."
// 		lRet := .F.
// 	EndIf

// 	If lRet
// 		lRet := GFE50VALVP(GWN->GWN_CDTPOP,GWN->GWN_VPVAL, GWN->GWN_CDTRP, @cMsg)
// 	EndIf

// 	//PE para possibilitar impedimento da liberação do romaneio, retorno deve ser um array no formato:
// 	//aRetPE[1] (Lógico)    Verdadeiro ou falso, conforme resultado da validação 
// 	//aRetPE[2] (Caracter)  Mensagem de erro, caso o retorno do primeiro elemento do array seja falso
// 	If ExistBlock("GFE05013")
// 		aRetPE := ExecBlock('GFE05013',.F.,.F.)
// 		If ValType(aRetPE) == 'A' .AND. !Empty(aRetPE)
// 			If !aRetPE[1]
// 				GFEMsgErro(aRetPE[2])
// 				lRet := .F.
// 			EndIf
// 		EndIf
// 	EndIf

// 	If lPE18
// 		aRetPE := ExecBlock("GFE05018",.F.,.F., {GWN->GWN_FILIAL, GWN->GWN_NRROM, dData, cHora})
// 		lWhenDtS := aRetPE[1]
// 		lWhenHrS := aRetPE[2]
// 		dData    := aRetPE[3]
// 		cHora    := aRetPE[4]
// 	EndIf

// 	If lRet
// 		If GFXCP1212210('GW1_FILROM')
// 			cWhere := "GW1.GW1_FILROM = '" + Alltrim(cFilRom) + "'"
// 		Else
// 			cWhere := "GW1.GW1_FILIAL = '" + Alltrim(cFilRom) + "'"
// 		EndIf
// 		cWhere := "%" + cWhere + "%"

// 		cAliasGW1 := GetNextAlias()
// 		BeginSql Alias cAliasGW1
// 			SELECT GW1_FILIAL, GW1_SIT, GW1_NRDC, GW1.R_E_C_N_O_ AS GW1RECNO
// 			FROM %table:GW1% GW1
// 			WHERE %Exp:cWhere%
// 			AND GW1.GW1_NRROM  = %Exp:cNrRom%
// 			AND GW1.%NotDel%
// 			ORDER BY GW1.GW1_FILIAL,GW1.GW1_NRDC
// 		EndSql
// 		While !(cAliasGW1)->(Eof())
// 			If (cAliasGW1)->GW1_SIT = '2'
// 				If !IsBlind() .And. !IsInCallStack("GFEA054")
// 					GFEMessage(2, GFEA050020, "Há um ou mais Documentos de Carga com situação bloqueado vinculado ao Romaneio de Carga. Não é possível liberar. Visualize o Romaneio e na aba de Documentos, verifique o campo Situação.", " ")
// 					lRet := .F.
// 					Exit
// 				Else
// 					cMsg := "Há um ou mais Documentos de Carga com situação bloqueado vinculado ao Romaneio de Carga. Não é possível liberar. Visualize o Romaneio e na aba de Documentos, verifique o campo Situação." //"Há um ou mais Documentos de Carga com situação bloqueado vinculado ao Romaneio de Carga. Não é possível liberar. Visualize o Romaneio e na aba de Documentos, verifique o campo Situação."
// 					lRet := .F.
// 				EndIf
// 			EndIf

// 			(cAliasGW1)->(dbSkip())
// 		EndDo	
// 		(cAliasGW1)->(dbCloseArea())
// 	EndIf

// 	If lRet
// 		If !lAuto
// 			DEFINE MSDIALOG oDlg TITLE "Liberar" From 4,0 To 16,40 OF oMainWnd //"Liberar"

// 			@  4, 006  SAY "Romaneio:" SIZE 70,7 PIXEL OF oDlg //"Romaneio:"
// 			@ 19, 006  SAY "Data de Saída:" SIZE 70,7 PIXEL OF oDlg //"Data de Saída:"
// 			@ 34, 006  SAY "Hora de Saída:" SIZE 70,7 PIXEL OF oDlg //"Hora de Saída:"
// 			@ 49, 006  SAY "Hora de Saída:" SIZE 70,7 PIXEL OF oDlg //"Hora de Saída:"
// 			@ 64, 006  SAY "Código de Rastream" SIZE 70,7 PIXEL OF oDlg //"Código de Rastream"

// 			@  3, 060  MSGET cNrRom When .F. SIZE 40,7 PIXEL OF oDlg hasbutton
// 			@ 18, 060  MSGET dData  When lWhenDtS PICTURE "99/99/9999" SIZE 45,7 PIXEL OF oDlg hasbutton Valid GFEVLDATE(dData)
// 			@ 33, 060  MSGET cHora  When lWhenHrS picture "99:99" 	SIZE 15,7 PIXEL OF oDlg Valid GFEVLDHR(cHora)
// 			@ 48, 060  MSGET nHod   When lWhenHod PICTURE cPicHodSai SIZE 15,7 PIXEL OF oDlg
// 			@ 63, 060  MSGET cRastR When .T. SIZE 45,7 PIXEL OF oDlg

// 			oButtonOK   := tButton():New(80,5,'OK',oDlg,{||If(GFEABTOK(lAuto,dData,cHora,cRastr,nHod),oDlg:End(),lRet:=.F.)},25,10,,,,.T.)
// 			oButtonCanc := tButton():New(80,35,"Cancelar",oDlg,{||lRet:=.F.,oDlg:End()},25,10,,,,.T.) //"Cancelar"

// 			ACTIVATE MSDIALOG oDlg
// 		Else
// 			If !IsBlind()
// 				Processa({|| lRet:= GFEABTOK(lAuto,dData,cHora,GWN->GWN_RASTR,,@cMsg) })
// 			Else
// 				lRet:= GFEABTOK(lAuto,dData, cHora,GWN->GWN_RASTR,,@cMsg)
// 			EndIf
// 		EndIf
// 	EndIf

// 	//Ponto de entrada validação Vicunha
// 	If lRet .AND. ExistBlock("GFEA0505")
// 		ExecBlock("GFEA0505",.F.,.F.)
// 	EndIf
	
// 	If lRet
// 		If !IsBlind()
// 			Processa({|| GFE050MAIL(.F.)},'Enviando e-mail aos destinatários do romaneio ' + GWN->GWN_NRROM)
// 		Else
// 			GFE050MAIL(.F.)
// 		EndIf
// 	EndIf
// Return lRet

// Static Function GFEVLDATE(dData)
// 	Local lRet := .T.

// 	If Empty(dData)
// 		lRet := .F.
// 		GFEMessage(5, GFEA050021, "Data inválida.", "Informe uma data valida para continuar.")	//"Data inválida." / "Informe uma data valida para continuar."
// 	EndIf
// Return lRet

// Static Function GFEA50LIBL()
// 	Local   lNotBlind  := !IsBlind()
	
// 	Private lPergunte  := Pergunte("GFEA050A",.T.)
// 	Private cFilialDe  := ""
// 	Private cFilialAte := ""
// 	Private cRomanDe   := ""
// 	Private cRomanAte  := ""
// 	Private dDtCriaDe  := Nil
// 	Private dDtCriaAte := Nil
// 	Private dDtSai     := Nil
// 	Private cHrSai     := ""
// 	Private _lSemHelp  := .F.// Variável para não exibir os Help's da função GFEA50LIB()

// 	If lPergunte .And. lNotBlind
// 		Processa({|| GFEA50LIExec(), "Liberando romaneios por lote... Aguarde"}) // "Liberando romaneios por lote... Aguarde"
// 	Else
// 		GFEA50LIExec()
// 	EndIf
// Return

// Static Function GFEA50LIExec() // Faz a liberação por lote
// 	Local cMsg       := ""
// 	Local dDtSai     := Nil
// 	Local nTotRomanP := 0
// 	Local nErroRoman := 0
// 	Local nCalcRoman := 0
// 	Local GFELog     := GFEViewProc():New()
// 	Local cFiltro    := "@"
// 	Local cFilAtu    := cFilAnt

// 	cFilialDe  := MV_PAR01
// 	cFilialAte := MV_PAR02
// 	cRomanDe   := MV_PAR03
// 	cRomanAte  := MV_PAR04
// 	dDtCriaDe  := MV_PAR05
// 	dDtCriaAte := MV_PAR06
// 	dDtSai     := MV_PAR07
// 	cHrSai     := MV_PAR08

// 	GWN->( dbSetOrder(1) )
// 	GWN->(dbClearFilter())
// 	cFiltro += "GWN_FILIAL >='" + cFilialDe + "'"
// 	cFiltro += " AND GWN_FILIAL <='" + cFilialAte + "'"
// 	cFiltro += " AND GWN_NRROM >='" + cRomanDe + "'"
// 	cFiltro += " AND GWN_NRROM <='" + cRomanAte + "'"

// 	GWN->(dbSetFilter({||},cFiltro))
// 	GWN->(dbGoTop())

// 	ProcRegua(0)

// 	Do While GWN->( !Eof() )
// 		If (Empty(dDtCriaDe ) .Or. DToS(GWN->GWN_DTIMPL) >= DToS(dDtCriaDe ));
// 			.And. (Empty(dDtCriaAte) .Or. DToS(GWN->GWN_DTIMPL) <= DToS(dDtCriaAte))
			
// 			nTotRomanP++
// 			cFilAnt := GWN->GWN_FILIAL
// 			IncProc("Liberando Romaneio... Filial: " + cFilAnt + " Nr.: " + GWN->GWN_NRROM)
// 			If GFEA050LIB(.T., @cMsg,dDtSai,cHrSai)
// 				GFELog:Add(Replicate('-',50))
// 				GFELog:Add(Space(4) + "Filial: " + GWN->GWN_FILIAL + ", Romaneio " + GWN->GWN_NRROM + ": ")
// 				GFELog:Add(Space(7) + "Foi Liberado com sucesso")
// 				GFELog:Add("")
// 				nCalcRoman++
// 			Else
// 				GFELog:AddErro(Replicate('-',50))
// 				GFELog:AddErro(Space(4) +"Filial: " + GWN->GWN_FILIAL + ",Romaneio " + GWN->GWN_NRROM + ": ")
// 				GFELog:AddErro(Space(7)+"Motivo: " + cMsg)
// 				GFELog:AddErro("")
// 				nErroRoman++
// 			EndIf
// 		EndIf
// 		GWN->( dbSkip() )
// 	EndDo

// 	cFilAnt := cFilAtu
// 	GWN->(dbClearFilter())

// 	GFELog:Add(Replicate('-',50))
// 	GFELog:Add("")
// 	GFELog:Add("Total de romaneios processados :" + cValToChar(nTotRomanP))
// 	GFELog:Add("Total de romaneios Liberados : "  + cValToChar(nCalcRoman))
// 	GFELog:Add("Total de romaneios com erros : "  + cValToChar(nErroRoman))
// 	If !IsBlind()
// 		GFELog:Show("Liberação de Romaneio", "Romaneios Liberados", "Erros", "Um ou mais Romaneios não foram liberados, clique no botão 'Erros' para mais detalhes.")
// 	EndIf
// Return

// Static Function GFEABTOK(lAuto,dData, cHora, cRastr,nHodo,cMsg) // Sempre passar o parametro cMsg por referencia
// 	Local lRet      	:= .T.
// 	Local lCalcAuto		:= .F.
// 	Local lSitFT    	:= .F.
// 	Local aRetVld   	:= {}
// 	Local aAreaGW1  	:= GW1->(GetArea())
// 	Local cMV_PLROADE := SuperGetMv("MV_PLROADE",.F.,"2")
// 	Local oMovDocto 	:= Nil
// 	Local cAliasGX0 	:= Nil
// 	Local cAliasGW1 	:= Nil
// 	Local cWhere    	:= Nil
		
// 	Default lAuto   := .F.
// 	Default cMsg    := ""

// 	If !(GWN->GWN_NRROM == GW1->GW1_NRROM)
// 		GW1->(dbSetOrder(09))
// 		GW1->(dbSeek(xFilial("GW1")+GWN->GWN_NRROM))
// 	EndIf

// 	If GFEVerCmpo( {"GV5_CALC","GW1_CALCAT"}) .AND. GW1->GW1_NRROM == GWN->GWN_NRROM  .AND.;
// 		 (GW1->GW1_CALCAT == "1" .OR. Empty(GW1->GW1_CALCAT)) .AND. Posicione("GV5",1,xFilial("GV5")+GW1->GW1_CDTPDC,"GV5_CALC") == "2"

// 		lCalcAuto := .T.
// 	EndIf
	
// 	If DTOS(dData) == DTOS(GWN->GWN_DTIMPL)
// 		If cHora < GWN->GWN_HRIMPL
// 			cHora := GWN->GWN_HRIMPL
// 		EndIf
// 	Else
// 		If DTOS(GW1->GW1_DTEMIS) > DTOS(dData) .And. cMV_PLROADE == "2"
// 			If !lAuto
// 				If !lCalcAuto .And. Type("_lSemHelp") == "U"// Definir varivel " Private _lSemHelp := .F.", varivel foi declarada nas funções GFEA050LIBL() e  GFEA081.CalculaRomaneios()
// 					GFEMessage(5, GFEA050022, "Romaneio não pode ser liberado", "Informe uma data e/ou hora maior ou igual a data de implantação.")	// "Romaneio não pode ser liberado" / "Informe uma data e/ou hora maior ou igual a data de implantação."
// 				EndIf
// 				cMsg := "Romaneio não pode ser liberado" + "Informe uma data e/ou hora maior ou igual a data de implantação." // "Romaneio não pode ser liberado. Informe uma data e/ou hora maior ou igual a data de implantação."
// 				lRet := .F.	
// 			EndIf
// 		EndIf
// 	EndIf

// 	If lRet .And. !lAuto .And. dData > dDataBase
// 		lRet := .F.
// 		GFEMessage(5, GFEA050023, "Romaneio não pode ser liberado", "Informe uma data menor ou igual a data corrente.")	//// "Romaneio não pode ser liberado" / "Informe uma data menor ou igual a data corrente."
// 	EndIf

// 	If lRet
// 		aRetVld := GFE50AVLIB(GWN->GWN_FILIAL, GWN->GWN_NRROM, dData, cHora, nHodo, cRastr)

// 		If aRetVld[1] = .F. .And. cMV_PLROADE == "2"
// 			lRet := .F.
// 			GFEMessage(5, GFEA050024, GFEMsgFmt("Romaneio não pode ser liberado: [VAR01]", {{"[VAR01]", aRetVld[2]}}), "Informe uma data superior a data de emissão do Documento de Carga.")	//"Romaneio não pode ser liberado: [VAR01]" / "Informe uma data superior a data de emissão do Documento de Carga."
// 		EndIf
// 	EndIf

// 	If lRet
// 		lSitFT := GfeVerCmpo({"GW1_SITFT"})

// 		If GFXCP1212210('GW1_FILROM')
// 			cWhere := "GW1.GW1_FILROM = '" + GWN->GWN_FILIAL + "'"
// 		Else
// 			cWhere := "GW1.GW1_FILIAL = '" + GWN->GWN_FILIAL + "'"
// 		EndIf
// 		cWhere := "%" + cWhere + "%"

// 		cAliasGW1 := GetNextAlias()
// 		BeginSql Alias cAliasGW1
// 			SELECT GW1_FILIAL, GW1_CDTPDC, GW1_EMISDC, GW1_SERDC, GW1_NRDC, GW1.R_E_C_N_O_ AS GW1RECNO
// 			FROM %table:GW1% GW1
// 			WHERE %Exp:cWhere%
// 			AND GW1.GW1_NRROM  = %Exp:GWN->GWN_NRROM%
// 			AND GW1.%NotDel%
// 			ORDER BY GW1.GW1_FILIAL,GW1.GW1_NRDC
// 		EndSql
// 		If !(cAliasGW1)->(Eof())
// 			While !(cAliasGW1)->(Eof())
// 				GW1->(dbGoTo( (cAliasGW1)->GW1RECNO ))
// 				RecLock('GW1', .F.)
// 					GW1->GW1_DTSAI := dData
// 					GW1->GW1_HRSAI := cHora
// 				GW1->( MsUnLock() )

// 				If lSitFT
// 					GV5->( dbSetorder(1) )
// 					s_GFEI20_2 := SuperGetMV('MV_GFEI20',,'2')
// 					If (GV5->( dbSeek(xFilial("GV5")+GW1->GW1_CDTPDC) ) .AND. GV5->GV5_SENTID == '1') .OR. s_GFEI20_2 != '1'
// 						RecLock('GW1', .F.)
// 							GW1->GW1_SITFT := "6"
// 						GW1->( MsUnLock() )
// 					Else
// 						RecLock('GW1', .F.)
// 							GW1->GW1_SITFT := "2"
// 						GW1->( MsUnLock() )
// 					EndIf
// 				EndIf

// 				(cAliasGW1)->(dbSkip())
// 			EndDo	

// 			RecLock('GWN', .F.)
// 				GWN->GWN_DTSAI := dData
// 				GWN->GWN_HRSAI := cHora
// 				GWN->GWN_SIT   := "3"
// 				GWN->GWN_RASTR := cRastR
// 				If GfeVerCmpo({"GWN_HODSAI"}) .AND. nHodo != Nil
// 					GWN->GWN_HODSAI := nHodo
// 				EndIf
// 			GWN->( MsUnlock() )

// 			aAreaGW1:= GW1->(GetArea())
// 			GFEA050ALI(GWN->GWN_FILIAL+GWN->GWN_NRROM) // Verifica se o cálculo do documento pode ser liberado
// 			RestArea(aAreaGW1)
			
// 			// Início Ponto de Entrada
// 			If ExistBlock("GFEA0501")
// 				aPontEnt := ExecBlock("GFEA0501",.F.,.F.,{GWN->GWN_FILIAL, GWN->GWN_NRROM})
// 			EndIf
// 			// Fim Ponto de Entrada
// 		Else
// 			If !lCalcAuto  .And. Type("_lSemHelp") == "U" // Definir varivel " Private _lSemHelp := .F.", varivel foi declarada nas funções GFEA050LIBL() e  GFEA081.CalculaRomaneios()
// 				GFEMessage(5, GFEA050025, "Romaneio não possui documento de carga relacionado.", "Selecione um Romaneio que possua ao menos um Documento de Carga relacionado para continuar.")	// "Romaneio não possui documento de carga relacionado." / "Selecione um Romaneio que possua ao menos um Documento de Carga relacionado para continuar."
// 			EndIf
// 			cMsg := "Romaneio não possui documento de carga relacionado." // "Romaneio não possui documento de carga relacionado."
// 			lRet := .F.
// 		EndIf
// 		(cAliasGW1)->(dbCloseArea())
// 	EndIf

// 	If lRet
// 		PrevEntreg(GWN->GWN_FILIAL, GWN->GWN_NRROM, dData, cHora)

// 		// Gravação de dados para relatorio de Movimentação de Carga
// 		/*If GFXTB1212210("GX0")
// 			If GFXCP1212210('GW1_FILROM')
// 				cWhere := "GW1.GW1_FILROM = '" + GWN->GWN_FILIAL + "'"
// 			Else
// 				cWhere := "GW1.GW1_FILIAL = '" + GWN->GWN_FILIAL + "'"
// 			EndIf
// 			cWhere := "%" + cWhere + "%"

// 			cAliasGW1 := GetNextAlias()
// 			BeginSql Alias cAliasGW1
// 				SELECT GW1_FILIAL, GW1_CDTPDC, GW1_EMISDC, GW1_SERDC, GW1_NRDC, GW1.R_E_C_N_O_ AS GW1RECNO
// 				FROM %table:GW1% GW1
// 				WHERE %Exp:cWhere%
// 				AND GW1.GW1_NRROM  = %Exp:GWN->GWN_NRROM%
// 				AND GW1.%NotDel%
// 				ORDER BY GW1.GW1_FILIAL,GW1.GW1_NRDC
// 			EndSql
// 			While !(cAliasGW1)->(Eof())
// 				oMovDocto := GFEMovtoCarga():New()

// 				// Atribuição de dados GW1
// 				oMovDocto:setBranch((cAliasGW1)->GW1_FILIAL)
// 				oMovDocto:setTipoNF((cAliasGW1)->GW1_CDTPDC)
// 				oMovDocto:setEmissorNF((cAliasGW1)->GW1_EMISDC)
// 				oMovDocto:setSerieNF((cAliasGW1)->GW1_SERDC)
// 				oMovDocto:setNumeroNF((cAliasGW1)->GW1_NRDC)

// 				oMovDocto:setFilRomaneio(GWN->GWN_FILIAL)
// 				oMovDocto:setNumRomaneio(GWN->GWN_NRROM)
// 				oMovDocto:setClassFrete(GWN->GWN_CDCLFR)
// 				oMovDocto:setDescClassFrete(Posicione("GUB", 1, xFilial("GUB")+GWN->GWN_CDCLFR, "GUB_DSCLFR"))
// 				oMovDocto:setTipoOper(GWN->GWN_CDTPOP)
// 				oMovDocto:setDescTipoOperacao(Posicione("GV4", 1, xFilial("GV4")+GWN->GWN_CDTPOP, "GV4_DSTPOP"))
// 				oMovDocto:setDataSaida(dData)

// 				cAliasGX0 := oMovDocto:SearchByDC()
// 				While (cAliasGX0)->(!EoF()) .And. (cAliasGX0)->GX0_FILIAL == (cAliasGW1)->GW1_FILIAL ;
// 											.And. (cAliasGX0)->GX0_CDTPDC == (cAliasGW1)->GW1_CDTPDC ;
// 											.And. (cAliasGX0)->GX0_EMISDC == (cAliasGW1)->GW1_EMISDC ;
// 											.And. (cAliasGX0)->GX0_SERDC == (cAliasGW1)->GW1_SERDC ;
// 											.And. (cAliasGX0)->GX0_NRDC == (cAliasGW1)->GW1_NRDC

// 					GX0->(dbGoTo( (cAliasGX0)->RECNUM ))
// 					oMovDocto:UpdateRomaneio()		// Alteração de Registros na tabela GX0

// 					(cAliasGX0)->(dbSkip())
// 				EndDo
// 				(cAliasGX0)->(dbCloseArea())

// 				oMovDocto:Destroy( oMovDocto )

// 				(cAliasGW1)->(dbSkip())
// 			EndDo	
// 			(cAliasGW1)->(dbCloseArea())
// 		EndIf*/
// 	EndIf
// Return lRet

// Static Function GFEA050POS(oModel)
// 	Local cAliasGW1 := Nil
// 	Local cWhere    := Nil
// 	Local aVinc     := {}
// 	Local lDif      := .F.
// 	Local cCdTrp    := FwFldGet('GWN_CDTRP')
// 	Local nOpc      := oModel:GetOperation()
// 	Local oModelGWN := oModel:GetModel('GFEA050_GWN')

// 	If nOpc == MODEL_OPERATION_INSERT .OR. nOpc == MODEL_OPERATION_UPDATE
// 		If !GFEA50RLMT(FwFldGet('GWN_CDMTR'), FwFldGet('GWN_CDMTR2'), "1", .F.)
// 			Return .F.
// 		EndIf

// 		If !GFEA50RLMT(FwFldGet('GWN_CDMTR'), FwFldGet('GWN_CDMTR2'), "2", .F.)
// 			Return .F.
// 		EndIf

// 		If nOpc == MODEL_OPERATION_INSERT
// 			If !GFEA050UNQ()
// 				Return .F.
// 			EndIf
// 		EndIf

// 		//Vale pedágio
// 		If !GFE50VALVP(FwFldGet("GWN_CDTPOP"),FwFldGet("GWN_VPVAL"), FwFldGet("GWN_CDTRP"))
// 			Return .F.
// 		EndIF

// 		If !Empty(FwFldGet("GWN_VIAGEM"))
// 			dbSelectarea('GWP')
// 			If Posicione('GWP',1,xFilial('GWP') + FwFldGet("GWN_VIAGEM"), "GWP_CDTRP") != FwFldGet("GWN_CDTRP")
// 				GFEMsgErro("Não é possível alterar o transportador quando o romaneio está relacionado a uma viagem.")
// 				dbSelectArea('GWN')
// 				Return .F.
// 			EndIf
// 			dbSelectArea('GWN')
// 		EndIf
		
// 		If GFXCP12117('GU8_CDTPOP')
// 			GU8->(dbSetOrder(2))
// 			If GU8->(dbSeek(xFilial('GU8')+FwFldGet('GWN_PLACAD')))
// 				If !Empty(GU8->GU8_CDTPOP) .And. Alltrim(GU8->GU8_CDTPOP) != Alltrim(FwFldGet('GWN_CDTPOP'))
// 					Help(,,'HELP',,'O tipo de operação do romaneio deve ser igual ao tipo de operação do veículo informado.',1,0,) 
// 					Return .F.
// 				EndIf
// 			EndIf
// 		EndIf

// 		If GFXCP12121('GWN_NRCT')
// 			// Valida contrato de transporte para o transportador
// 			If !Empty(FwFldGet("GWN_NRCT"))
// 				GXT->( dbSetOrder(01) )
// 				If !GXT->( dbSeek(xFilial("GXT")+FwFldGet("GWN_NRCT")) )
// 					GFEHelp("Contrato de transporte (" + FwFldGet("GWN_NRCT") + ") não existe ","Informe um contrato de transporte (GFEA079) válido. ","Contrato de Transporte")
// 					Return .F.
// 				Else
// 					If GXT->GXT_CDTRP !=FwFldGet("GWN_CDTRP")
// 						GFEHelp("Contrato de transporte (" + FwFldGet("GWN_NRCT") + ") pertence ao transportador (" + GXT->GXT_CDTRP + ").","Informe um contrato de transporte (GFEA079) válido para o transportador (" + FwFldGet("GWN_CDTRP") +").","Contrato de Transporte")
// 						Return .F.
// 					EndIf 
// 				EndIf
// 			EndIf
// 		EndIf
// 	EndIf

// 	If nopc == MODEL_OPERATION_UPDATE
// 		If GWN->GWN_CDTRP <> cCdTrp .And. SuperGetMv("MV_GFETRP",.F.,"1") == "2"
// 			If GFXCP1212210('GW1_FILROM')
// 				cWhere := "GW1.GW1_FILROM = '" + GWN->GWN_FILIAL + "'"
// 			Else
// 				cWhere := "GW1.GW1_FILIAL = '" + GWN->GWN_FILIAL + "'"
// 			EndIf
// 			cWhere := "%" + cWhere + "%"

// 			cAliasGW1 := GetNextAlias()
// 			BeginSql Alias cAliasGW1
// 				SELECT GW1_FILIAL, GW1_CDTPDC, GW1_EMISDC, GW1_SERDC, GW1_NRDC, GW1.R_E_C_N_O_ AS GW1RECNO
// 				FROM %table:GW1% GW1
// 				WHERE %Exp:cWhere%
// 				AND GW1.GW1_NRROM  = %Exp:GWN->GWN_NRROM%
// 				AND GW1.%NotDel%
// 				ORDER BY GW1.GW1_FILIAL,GW1.GW1_NRDC
// 			EndSql
// 			While !(cAliasGW1)->(Eof())
// 				GWU->(dbSetOrder(1))
// 				GWU->(dbSeek(GW1->((cAliasGW1)->GW1_FILIAL + (cAliasGW1)->GW1_CDTPDC + (cAliasGW1)->GW1_EMISDC + (cAliasGW1)->GW1_SERDC + (cAliasGW1)->GW1_NRDC + "01")))
// 				If GWU->GWU_CDTRP <> cCdTrp
// 					lDif := .T.
// 					Exit
// 				EndIf

// 				(cAliasGW1)->(dbSkip())
// 			EndDo	
// 			(cAliasGW1)->(dbCloseArea())

// 			If lDif
// 				GFEMsgErro("Conforme definido pelos Parâmetros do Módulo, não é permitido redefinir o Transportador das Cargas pelo Romaneio. O Transportador do Romaneio deve ser o mesmo Transportador do primeiro trecho dos Documentos de Carga")
// 				Return .F.
// 			EndIf
// 		EndIf

// 		If FwFldGet( 'GWN_SIT' ) == "3"
// 			PutHelp("PFRM050A",{"Região Demais Cidades ou Inativa"},{"Região Demais Cidades ou Inativa"},{"Região Demais Cidades ou Inativa"}) //"Região Demais Cidades ou Inativa"###"Região Demais Cidades ou Inativa"###"Região Demais Cidades ou Inativa" //"Romaneio Liberado"###"Romaneio Liberado"###"Romaneio Liberado"
// 			PutHelp("SFRM050A",{"Não é possivel incluir Cidade ou CEP"},{"Não é possivel incluir Cidade ou CEP"},{"Não é possivel incluir Cidade ou CEP"}) //"Não é possivel incluir Cidade ou CEP"###"Não é possivel incluir Cidade ou CEP"###"Não é possivel incluir Cidade ou Faixa de CEP" //"Não é possível alterar"###"Não é possível alterar"###"Não é possível alterar"
// 			HELP(" ",1,"FRM050A","FRM050A" )
// 			Return .F.
// 		EndIf

// 		GWN->(dbSetOrder(1))

// 		If  (GWN->GWN_CDCLFR <> FwFldGet( 'GWN_CDCLFR' ) .Or. GWN->GWN_CDTRP  <> FwFldGet( 'GWN_CDTRP'  );
// 			.Or. GWN->GWN_CDTPVC <> FwFldGet( 'GWN_CDTPVC' ) .Or. GWN->GWN_CDTPOP <> FwFldGet( 'GWN_CDTPOP' );
// 			.Or. GWN->GWN_NRCIDD <> FwFldGet( 'GWN_NRCIDD' ) .Or. GWN->GWN_CEPD   <> FwFldGet( 'GWN_CEPD'   );
// 			.Or. GWN->GWN_DISTAN <> FwFldGet( 'GWN_DISTAN' ) .Or. TrocouCrgComp(oModelGWN) ;
// 			) .And. FwFldGet( 'GWN_CALC' ) != "2" .And. GWN->GWN_SIT <> "3"
			
// 			If IsInCallStack("GFEP001")
// 				MsgInfo("Este romaneio precisa ser recalculado") //"Este romaneio precisa ser recalculado"
// 			EndIf

// 			RecLock('GWN', .F.)
// 				GWN->GWN_CALC := "4"
// 				GWN->GWN_MTCALC := "Foram alteradas informações do Romaneio utilizadas no Cálculo."
// 				GWN->GWN_DTCALC := CToD("  /  /    ")
// 				GWN->GWN_HRCALC := ""
// 			GWN->( MsUnlock() )

// 		EndIf

// 		If GWN->GWN_CDTPOP <> FwFldGet('GWN_CDTPOP')
// 			If GFXCP1212210('GW1_FILROM')
// 				cWhere := "GW1.GW1_FILROM = '" + GWN->GWN_FILIAL + "'"
// 			Else
// 				cWhere := "GW1.GW1_FILIAL = '" + GWN->GWN_FILIAL + "'"
// 			EndIf
// 			cWhere := "%" + cWhere + "%"

// 			cAliasGW1 := GetNextAlias()
// 			BeginSql Alias cAliasGW1
// 				SELECT GW1.R_E_C_N_O_ AS GW1RECNO
// 				FROM %table:GW1% GW1
// 				WHERE %Exp:cWhere%
// 				AND GW1.GW1_NRROM  = %Exp:GWN->GWN_NRROM%
// 				AND GW1.%NotDel%
// 				ORDER BY GW1.GW1_FILIAL,GW1.GW1_NRDC
// 			EndSql
// 			Do While !(cAliasGW1)->(Eof())
// 				GW1->(dbGoTo((cAliasGW1)->GW1RECNO))

// 				GV4->( dbSetOrder(1) )
// 				If GV4->( dbSeek(xFilial("GV4") + FwFldGet('GWN_CDTPOP')) )
// 					If GV4->GV4_SENTID <> "0"
// 						GV5->( dbSetOrder(1) )
// 						If GV5->( dbSeek(xFilial("GV5") + GW1->GW1_CDTPDC) )
// 							If GV5->GV5_SENTID <> GV4->GV4_SENTID
// 								Help( ,, 'HELP',, "Não é possível alterar tipo de operação. Tipo do Documento de Carga, Nr. :  " + GW1->GW1_NRDC + " dIfere do sentido do tipo de operação.", 1, 0,) //"Não é possível alterar tipo de operação. Tipo do Documento de Carga, Nr. :  "###" dIfere do sentido do tipo de operação."
// 								Return .F.
// 							EndIf
// 						EndIf
// 					EndIf
// 				EndIf

// 				(cAliasGW1)->(dbSkip())
// 			EndDo	
// 			(cAliasGW1)->(dbCloseArea())
// 		EndIf

// 		//Altera o transportador dos trechos do Doc carga vinculados ao romaneio
// 		If GFXCP1212210('GW1_FILROM')
// 			cWhere := "GW1.GW1_FILROM = '" + GWN->GWN_FILIAL + "'"
// 		Else
// 			cWhere := "GW1.GW1_FILIAL = '" + GWN->GWN_FILIAL + "'"
// 		EndIf
// 		cWhere := "%" + cWhere + "%"

// 		cAliasGW1 := GetNextAlias()
// 		BeginSql Alias cAliasGW1
// 			SELECT GW1.R_E_C_N_O_ AS GW1RECNO
// 			FROM %table:GW1% GW1
// 			WHERE %Exp:cWhere%
// 			AND GW1.GW1_NRROM  = %Exp:GWN->GWN_NRROM%
// 			AND GW1.%NotDel%
// 			ORDER BY GW1.GW1_FILIAL,GW1.GW1_NRDC
// 		EndSql
// 		While !(cAliasGW1)->(Eof())
// 			GW1->(dbGoTo((cAliasGW1)->GW1RECNO))

// 			GWU->( dbSetOrder(1) )
// 			If GWU->( dbSeek(xFilial('GWU') + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC) )
// 				RecLock('GWU', .F.)
// 					GWU->GWU_CDTRP  := FwFldGet('GWN_CDTRP')
// 					GWU->GWU_CDTPVC := FwFldGet('GWN_CDTPVC')
// 				GWU->( MsUnLock() )
// 			EndIf

// 			(cAliasGW1)->(dbSkip())
// 		EndDo	
// 		(cAliasGW1)->(dbCloseArea())
// 	EndIf

// 	If nOpc == MODEL_OPERATION_DELETE // Eliminar
// 		If GWN->GWN_SIT == "3"
// 			Help( ,, 'HELP',, "Romaneio já foi liberado", 1, 0,) // "Romaneio já foi liberado"
// 			Return .F.
// 		EndIf
		
// 		If !ValCalcLot()
// 			GFEMsgErro("Romaneio possui cálculos vinculados a Lote de Provisão") 
// 			Return .F.
// 		EndIf
// 		GFEA050DES(GWN->GWN_NRROM)
// 	EndIf

// 	If nOpc != MODEL_OPERATION_DELETE

// 		AAdd(aVinc, {FwFldGet("GWN_CDMTR") , "1"})
// 		AAdd(aVinc, {FwFldGet("GWN_CDMTR2"), "1"})
// 		AAdd(aVinc, {FwFldGet("GWN_PLACAD"), "2"})
// 		AAdd(aVinc, {FwFldGet("GWN_PLACAM"), "2"})
// 		AAdd(aVinc, {FwFldGet("GWN_PLACAT"), "2"})

// 		GFEA050VIN(aVinc, FwFldGet("GWN_CDTRP"))

// 		//Vale pedágio
// 		If GFEVerCmpo({"GWN_VPVAL"}) .AND. oModel:IsFieldUpdated("GFEA050_GWN","GWN_VPVAL")
// 			If !Empty(oModel:GetValue("GFEA050_GWN","GWN_VPVAL")) .AND. oModel:GetValue("GFEA050_GWN","GWN_VPVAL") >0
// 				oModel:LoadValue("GFEA050_GWN", "GWN_VALEP", "2") // Não conferido
// 			Else
// 				oModel:LoadValue("GFEA050_GWN", "GWN_VALEP", "1") // Não se aplica
// 			EndIf
// 		EndIf

// 		If GFEVerCmpo({"GWN_VPVAL"}) .AND. Posicione("GV4",1,xFilial("GV4") + oModel:GetValue("GFEA050_GWN","GWN_CDTPOP"),"GV4_PEDAG") == "1"
// 			oModel:LoadValue("GFEA050_GWN", "GWN_VALEP", "1") // Não se aplica
// 		EndIf
// 	EndIf
// Return .T.

// Static Function GFEA050VIN(aVinc, cTransp)
// 	Local nCount  := 0
// 	Local nFCount := 0
// 	Local cTpProp := ""

// 	nFCount := Len(aVinc)
// 	For nCount := 1 To nFCount
// 		If aVinc[nCount][2] == "1"
// 			GUU->( dbSetOrder(1) )
// 			If GUU->( dbSeek(xFilial("GUU") + aVinc[nCount][1]) ) .AND. Empty(GUU->GUU_CDTRP)
// 				RecLock("GUU", .F.)
// 				GUU->GUU_CDTRP := cTransp
// 				GUU->( MsUnlock() )
// 			EndIf
// 		ElseIf aVinc[nCount][2] == "2" //não utilizado else, para ter ceteza que virá apenas 1 ou 2.
// 			GU3->( dbSetOrder(1) )
// 			If GU3->( dbSeek(xFilial("GU3") + cTransp) )
// 				cTpProp := IIf(GU3->GU3_EMFIL == "1", "2", "1")
// 			EndIf

// 			GU8->( dbSetOrder(2) )
// 			If GU8->( dbSeek(xFilial("GU8") + aVinc[nCount][1]) ) // Removido para cadastrar o mesmo veículo para proprietarios diferentes.AND. Empty(GU8->GU8_CDPROP)
// 				RecLock("GU8", .F.)
// 				GU8->GU8_CDPROP := cTransp
// 				GU8->GU8_TPPROP := cTpProp
// 				GU8->( MsUnlock() )
// 			EndIf
// 		EndIf
// 	Next nCount
// Return

// Static Function GFEA050DES(nNRROM)
// 	Local aAreaGWN  := GWN->( GetArea() )
// 	Local aAreaGW1  := GW1->( GetArea() )
// 	Local aAreaGWH  := GWH->( GetArea() )
// 	Local aAreaGWF  := GWF->( GetArea() )
// 	Local aAreaGWM  := GWM->( GetArea() )
// 	Local aAreaGWA  := GWA->( GetArea() )
// 	Local aAreaGWT	:= {}
// 	Local aAreaGWR	:= {}
// 	Local aAreaGWS	:= {}
// 	Local aDocCarg  := {}
// 	Local nDC       := 0
// 	Local nFDC      := 0

// 	If GFXCP12117('GWT_NRROM')
// 		aAreaGWT  := GWT->( GetArea() )
// 		aAreaGWR  := GWS->( GetArea() )
// 		aAreaGWS  := GWS->( GetArea() )
// 	EndIf

// 	// Documentos de Carga vinculado ao romaneio
// 	GW1->( dbSetOrder(9) )
// 	GW1->( dbSeek(xFilial("GW1") + nNRROM) )
// 	Do While GW1->( !Eof() ) .And. GW1->GW1_FILIAL == xFilial("GW1") .And. GW1->GW1_NRROM == nNRROM
// 		AAdd(aDocCarg, GW1->( RecNo() ))
// 		GW1->( dbSkip() )
// 	EndDo

// 	nFDC := Len(aDocCarg)
// 	For nDC := 1 To NFDC
// 		GW1->( dbGoTo(aDocCarg[nDC]) )

// 		// Desvincula o Documento de Carga do romaneio
// 		RecLock("GW1", .F.)
// 		GW1->GW1_NRROM  := ""
// 		If GW1->GW1_SIT == "4"
// 			GW1->GW1_SIT    := "3"
// 		EndIf
// 		GW1->( MsUnLock() )
// 		s_INTFRE   := SuperGetMV('MV_INTFRE',.F.,'1')
// 		If GFXCP12117("GW1_SITFRE") .And. s_INTFRE == '2'
// 			If GW1->GW1_ORIGEM == "2" .And. GW1->GW1_SITFRE != '6'
// 				RecLock("GW1", .F.)
// 				GW1->GW1_SITFRE := "2"
// 				GW1->GW1_MOTFRE := "GFEA050 - Exclusão do Romaneio"
// 				GW1->GW1_DTFRE  := Date()
// 				GW1->( MsUnLock() )
// 			EndIf
// 		EndIf

// 		// Busca os cálculos do Documento de Carga para a eliminação
// 		GWH->( dbSetOrder(02) )
// 		GWH->( dbSeek(xFilial("GWH") + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC) )
// 		Do While GWH->( !Eof() ) ;
// 				.And. GWH->GWH_FILIAL == xFilial("GWH") ;
// 				.And. GWH->GWH_EMISDC == GW1->GW1_EMISDC;
// 				.And. GWH->GWH_SERDC == GW1->GW1_SERDC ;
// 				.And. GWH->GWH_NRDC == GW1->GW1_NRDC

// 			// Elimina o calculo e seus relacionamentos, na função já verifica se o cálculo existe na base,
// 			// fazendo com que se houver o mesmo cálculo para DC's diferentes não haja problema
// 			GFEDelCalc(GWH->GWH_NRCALC)
// 			GWH->( dbSkip() )
// 		EndDo
// 	Next nDC

// 	If GFXCP12117('GWT_NRROM')
// 		GWT->( dbSetOrder(01) )
// 		GWT->( dbSeek(xFilial("GWT") + nNRROM) )
// 		Do While GWT->( !Eof() ) .and. GWT->GWT_NRROM == nNRROM
// 			RecLock("GWT",.F.)
// 			GWT->(dbDelete())
// 			GWT->( MsUnlock() )
// 			GWT->( dbSkip() )
// 		EndDo

// 		GWR->( dbSetOrder(01) )
// 		GWR->( dbSeek(xFilial("GWR") + nNRROM) )
// 		Do While GWR->( !Eof() ) .and. GWR->GWR_NRROM == nNRROM
// 			RecLock("GWR",.F.)
// 			GWR->(dbDelete())
// 			GWR->( MsUnlock() )
// 			GWR->( dbSkip() )
// 		EndDo

// 		GWS->( dbSetOrder(01) )
// 		GWS->( dbSeek(xFilial("GWS") + nNRROM) )
// 		Do While GWS->( !Eof() ) .and. GWS->GWS_NRROM == nNRROM
// 			RecLock("GWS",.F.)
// 			GWS->(dbDelete())
// 			GWS->( MsUnlock() )
// 			GWS->( dbSkip() )
// 		EndDo
// 	EndIf

// 	RestArea(aAreaGW1)
// 	RestArea(aAreaGWH)
// 	RestArea(aAreaGWF)
// 	RestArea(aAreaGWM)
// 	RestArea(aAreaGWA)
// 	RestArea(aAreaGWN)

// 	If GFXCP12117('GWT_NRROM')
// 		RestArea(aAreaGWT)
// 		RestArea(aAreaGWR)
// 		RestArea(aAreaGWS)
// 	EndIf
// Return Nil

// Static Function GFEA050ENT()
// 	Local lRet      := .T.
// 	Local oDlg      := Nil
// 	Local cDSTRAN   := ""
// 	Local cCadastro := "Entrega" //"Entrega"
// 	Local dDataEnt  := Ctod(Space(8))
// 	Local cHrEnt    := "     "
// 	Local oSize     := Nil'
// 	Local cX3Rel    := ""

// 	cX3Rel := &(GetSx3Cache("GWU_HRENT", "X3_RELACAO"))
// 	If !Empty(cX3Rel)
// 		cHrEnt := cX3Rel
// 	EndIf

// 	If ExistBlock("GFEA0504")
// 		If ExecBlock("GFEA0504",.F.,.F.,{GWN->GWN_FILIAL, GWN->GWN_NRROM})
// 			lRet := .F.
// 		EndIf
// 	EndIf

// 	If lRet
// 		aNewButton := {}

// 		oSize := FWDefSize():New(.T.,,,oDlg)
// 		oSize:AddObject( "ENCHOICE", 100, 100, .T., .T. ) // Adiciona enchoice
// 		oSize:SetWindowSize({500, 200, 730, 820})
// 		oSize:lLateral     := .F.  // Calculo vertical
// 		oSize:Process() //executa os calculos

// 		//--------------------------
// 		// Montagem da tela
// 		//--------------------------
// 		Define MsDialog oDlg Title cCadastro ;
// 			From oSize:aWindSize[1],oSize:aWindSize[2];
// 			To oSize:aWindSize[3],oSize:aWindSize[4];
// 			Of oMainWnd Color CLR_WHITE /*,RGB(225,225,225)*/ Pixel

// 		oDlg:lEscClose := .F.

// 		oPanel1:= tPanel():New(oSize:GetDimension("ENCHOICE","LININI"),;
// 			oSize:GetDimension("ENCHOICE","COLINI"),;
// 			"",oDlg,,,,,,;
// 			oSize:GetDimension("ENCHOICE","XSIZE"),;
// 			oSize:GetDimension("ENCHOICE","YSIZE"))

// 		//----- Painel superior da tela principal, com as informacoes do romaneio -----//
// 		//oPnlA := tPanel():New(00,00,,oDlg,,,,,,10,80,.F.,.F.)
// 		//oPnlA:Align := CONTROL_ALIGN_TOP

// 		// ----- Criacao dos fields referente ao romaneio no painel superior da tela principal -----//
// 		cDSTRAN := posicione("GU3",1,xFilial("GU3")+GWN->GWN_CDTRP,"GU3_NMEMIT")

// 		@ 07,10  Say "Romaneio:" Of oPanel1 COLOR CLR_BLACK Pixel //"Romaneio: "
// 		@ 05,55  MSGET GWN->GWN_NRROM Picture "@!" Of oPanel1 When .F.   Pixel

// 		@ 22,10 Say "Transportadora: "            Of oPanel1 COLOR CLR_BLACK Pixel //"Transportadora: "
// 		@ 20,55 MSGET GWN->GWN_CDTRP  Picture "@!" Of oPanel1 When .F.   Pixel
// 		@ 20,145 MSGET cDSTRAN Picture "@!" SIZE 160,10 Of oPanel1 When .F.   Pixel

// 		@ 37,10  Say "Data Liberação: " Of oPanel1 COLOR CLR_BLACK Pixel //"Data Liberação: "
// 		@ 35,55  MSGET GWN->GWN_DTSAI Picture "  /  /  " Of oPanel1 When .F.   Pixel hasbutton

// 		@ 37,145  Say "Hr Liberação: " Of oPanel1 COLOR CLR_BLACK Pixel //"Hr Liberação: "
// 		@ 35,185  MSGET GWN->GWN_HRSAI PICTURE "99:99" When .F. SIZE 30,10 PIXEL OF oPanel1 hasbutton

// 		@ 52,10  Say "Data Entrega: " Of oPanel1 COLOR CLR_BLACK Pixel //"Data Entrega: "
// 		@ 50,55  MSGET dDataEnt When .T. SIZE 40,7 Valid (!Empty(dDataEnt)) PIXEL OF oPanel1 hasbutton

// 		@ 67,10  Say "Hora Entrega: " Of oPanel1 COLOR CLR_BLACK Pixel //"Hora Entrega: "
// 		@ 65,55  MSGET cHrEnt Picture "99:99" When .T. SIZE 30,7 Valid GFEVLDHR(cHrEnt) PIXEL OF oPanel1
// 		//---------Fim da criacao dos fields ----------//

// 		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(ODlg,{||If(GFEA050OK(dDataEnt, cHrEnt),ODlg:End(),NIL)},;
// 			{||If(APMSGYESNO("Deseja cancelar esse processo?"),ODlg:End(),)},,aNewButton) CENTERED //"Deseja cancelar esse processo?"
// 	EndIf
// Return lRet

// Static Function GFEA050OK(dDataEnt, cHrEnt)
// 	Local cListDC   := ""
// 	Local nTrcPag   := 0
// 	Local cTrecho   := ""
// 	Local lEntregue := .T.
// 	Local aDocGW1 	:= {}
// 	Local nI 		:= 0

// 	If GWN->GWN_SIT == "5"
// 		Help( ,, 'HELP',, "O Romaneio já está encerrado.", 1, 0,) //"O Romaneio já está encerrado."
// 		Return .F.
// 	ElseIf GWN->GWN_SIT == "3"

// 		If dDataEnt > Date()
// 			Help(,, 'HELP',, "A data informada não pode ser maior que hoje.", 1, 0)
// 			Return .F.
// 		ElseIf dDataEnt == Date() .AND. SubStr(cHrEnt, 1, 2) > SubStr(Time(), 1, 2)
// 			Help(,, 'HELP',, "A hora informada não pode ser maior que a hora atual.", 1, 0)
// 			Return .F.
// 		ElseIf dDataEnt == Date() .AND. SubStr(cHrEnt, 1, 2) == SubStr(Time(), 1, 2) .AND. SubStr(cHrEnt, 4, 2) > SubStr(Time(), 4, 2)
// 			Help(,, 'HELP',, "A hora informada não pode ser maior que a hora atual.", 1, 0)
// 			Return .F.
// 		ElseIf dDataEnt < GWN->GWN_DTSAI
// 			Help(,, 'HELP',, "A data informada não pode ser menor que a Data de Liberação.", 1, 0)
// 			Return .F.
// 		ElseIf dDataEnt == GWN->GWN_DTSAI .AND. SubStr(cHrEnt, 1, 2) < SubStr(GWN->GWN_HRSAI, 1, 2)
// 			Help(,, 'HELP',, "A hora informada não pode ser menor que a Hora de Liberação.", 1, 0)
// 			Return .F.
// 		ElseIf dDataEnt == GWN->GWN_DTSAI .AND. SubStr(cHrEnt, 1, 2) == SubStr(GWN->GWN_HRSAI, 1, 2) .AND. SubStr(cHrEnt, 4, 2) < SubStr(GWN->GWN_HRSAI, 4, 2)
// 			Help(,, 'HELP',, "A hora informada não pode ser menor que a Hora de Liberação.", 1, 0)
// 			Return .F.
// 		EndIf

// 		If dDataEnt < GWN->GWN_DTSAI .AND. StrTran(cHrEnt,":","") < StrTran(GWN->GWN_HRSAI,":","")
// 			Help( ,, 'HELP',, "Data entrega menor que data de liberação", 1, 0,) //"Data entrega menor que data de liberação"
// 			Return .F.
// 		EndIf

// 		If Empty(cHrEnt)
// 			Help(,, 'HELP',, "A hora de entrega é obrigatória.", 1, 0)
// 			Return .F.
// 		EndIf

// 		cAliasGW1 := GetNextAlias()
// 		BeginSql Alias cAliasGW1
// 			SELECT GW1.GW1_FILIAL,
// 				GW1_CDTPDC,
// 				GW1_EMISDC,
// 				GW1_SERDC,
// 				GW1.GW1_NRDC,
// 				GW1.GW1_NRROM,
// 				GW1.R_E_C_N_O_
// 			FROM %table:GW1% GW1
// 			WHERE GW1.%notDel%
// 			AND GW1.GW1_FILIAL = %xFilial:GW1%
// 			AND GW1.GW1_NRROM  = %Exp:GWN->GWN_NRROM%
// 			AND GW1.%NotDel%
// 			ORDER BY GW1.GW1_NRDC
// 		EndSql

// 		While !(cAliasGW1)->(Eof())
// 			AaDD(aDocGW1,{(cAliasGW1)->GW1_FILIAL,;
// 				(cAliasGW1)->GW1_CDTPDC,;
// 				(cAliasGW1)->GW1_EMISDC,;
// 				(cAliasGW1)->GW1_SERDC,;
// 				(cAliasGW1)->GW1_NRDC,;
// 				(cAliasGW1)->GW1_NRROM,;
// 				(cAliasGW1)->R_E_C_N_O_})
// 			(cAliasGW1)->(dbSkip())
// 		EndDo
// 		(cAliasGW1)->(dbCloseArea())

// 		For nI:= Len(aDocGW1) To 1 Step -1

// 			GW1->(dbGoTo(aDocGW1[nI,07]))
// 			If GW1->GW1_SIT == "5"
// 				cListDC += AllTrim(GW1->GW1_NRDC) + " -> [delivered]" + CRLF
// 				GW1->( dbSkip() )
// 				Loop
// 			EndIf

// 			GWU->( dbSetOrder(1) )
// 			GWU->(dbSeek(aDocGW1[nI,01] + aDocGW1[nI,02] + aDocGW1[nI,03] + aDocGW1[nI,04] + aDocGW1[nI,05]))
// 			Do While GWU->( !Eof() );
// 					.And. GWU->GWU_FILIAL == aDocGW1[nI,01] ;
// 					.And. GWU->GWU_CDTPDC == aDocGW1[nI,02] ;
// 					.And. GWU->GWU_EMISDC == aDocGW1[nI,03] ;
// 					.And. GWU->GWU_SERDC  == aDocGW1[nI,04] ;
// 					.And. GWU->GWU_NRDC   == aDocGW1[nI,05]
// 				s_RENTNP   := SuperGetMV("MV_RENTNP",.F.,"1")
// 				If (GWU->GWU_PAGAR == "1" .OR. s_RENTNP == "2") .And. Empty(GWU->GWU_DTENT)
// 					nTrcPag++
// 					cTrecho := GWU->GWU_SEQ
// 					Exit
// 				EndIf
// 				GWU->( dbSkip() )
// 			EndDo

// 			If nTrcPag != 1
// 				cListDC += AllTrim(aDocGW1[nI,05]) + If(nTrcPag == 0, " -> [emptystretch]", " -> [morethanonestretch]") + CRLF
// 				nTrcPag := 0
// 				lEntregue := .F.
// 				Loop
// 			EndIf

// 			GWU->(dbSetOrder(1))
// 			If GWU->(dbSeek(aDocGW1[nI,01] + aDocGW1[nI,02] + aDocGW1[nI,03] + aDocGW1[nI,04] + aDocGW1[nI,05] + cTrecho))
// 				If Empty(GWU->GWU_DTENT) .And. Empty(GWU->GWU_HRENT)
// 					RecLock("GWU", .F.)
// 					GWU->GWU_DTENT := dDataEnt
// 					GWU->GWU_HRENT := cHrEnt
// 					GWU->(MsUnlock())
// 				EndIf
// 			EndIf

// 			If GW1->GW1_SIT != "6"
// 				RecLock ("GW1", .F.)
// 				GW1->GW1_SIT := "5"
// 				GW1->(MsUnlock())
// 			EndIf
// 			// Comentario SAMSUNG
// 			GFE51IENT() // Integra a data de entrega do último trecho pago com a nota de saída do protheus.

// 			// Verifica e executa auditoria de Doc Frete se existir Doc Frete Bloqueado
// 			GFE050AUDIT(aDocGW1[nI,01], aDocGW1[nI,02],aDocGW1[nI,03],aDocGW1[nI,04],aDocGW1[nI,05])

// 			GW1->( dbSetOrder(9) )
// 			GW1->( dbSeek(aDocGW1[nI,01] + (aDocGW1[nI,06]) + (aDocGW1[nI,02]) + (aDocGW1[nI,03]) + (aDocGW1[nI,04]) + (aDocGW1[nI,05])) )
// 			If GW1->GW1_SIT == "5"
// 				cListDC += AllTrim(aDocGW1[nI,05]) + " -> [delivered]" + CRLF
// 			ElseIf GW1->GW1_SIT == "6"
// 				cListDC += AllTrim(aDocGW1[nI,05]) + " -> [returned]" + CRLF
// 			EndIf

// 			nTrcPag := 0
// 		Next nI

// 		If lEntregue
// 			RecLock ("GWN", .F.)
// 			GWN->GWN_SIT := "4"
// 			GWN->(MsUnlock())
// 		EndIf

// 		cListDC := StrTran(cListDC, "[delivered]"         , "Entregue.") //"Entregue."
// 		cListDC := StrTran(cListDC, "[emptystretch]"      , "Não Entregue. Documento de Carga não possui trechos pagos.") //"Não Entregue. Documento de Carga não possui trechos pagos."
// 		cListDC := StrTran(cListDC, "[morethanonestretch]", "Não Entregue. Documento de Carga possui mais de 1 trecho pago.") //"Não Entregue. Documento de Carga possui mais de 1 trecho pago."
// 		cListDC := StrTran(cListDC, "[notExt_Outflow]"    , "Não Entregue. Documento de Carga não é de 'Saída' ou 'Externo'.") //"Não Entregue. Documento de Carga não é de 'Saída' ou 'Externo'."
// 		cListDC := StrTran(cListDC, "[returned]"    	  , "Retornado.")

// 		MsgInfo("Documentos de carga do romaneio " + GWN->GWN_NRROM + ": " + CRLF + cListDC, "") //"Documentos de carga do romaneio "
// 	Else
// 		Help( ,, 'HELP',, "Romaneio não está liberado", 1, 0,) //"Romaneio não está liberado"
// 		Return .F.
// 	EndIf

// 	If ExistBlock("GFEA0500")
// 		If ExecBlock("GFEA0500",.F.,.F.)
// 			Return .T.
// 		EndIf
// 	EndIf

// Return .T.

// Static Function GFE050CALC(lDatabase,lHelp,cMsg,aRetCalc,lTstAuto,cArqLog)
// 	Local aAreaGWN   := {}
// 	Local lCalcAuto  := .F.
// 	Local lLog       := IIF(SuperGetMv("MV_LOGCALC",,'1') == '2',.F., .T.)//Indica se será gerado ou não o log de cálculo, de acordo com os parametros do módulo
// 	Local nQtPern    := 0
// 	Local cGU5_TPIMP := ""
// 	Local cNrOcor    := ""
// 	Local nX         := 0
// 	Local nY         := 0
// 	Local nF         := 0
// 	Local aDocsCarg  := {}
// 	Local aNoCalc    := {}
// 	Local aTcomps    := {}
// 	Local cAliasQry  := Nil
// 	Local lCalcrom   := .F.
// 	Local aRetGXT    := {}

// 	Private lEdi       := .f.
// 	Private aTblFrFUNB := {}
// 	Private aCompsAux  := {}
// 	Private nTblFrFUNB := 1
// 	Private nAux2      := 1
// 	Private cCalAntigo := ''

// 	// Parâmetro utilizado para realizar nova conferênica Doc Frete
// 	// Deve estar como Private pois é utilizado dentro de outra função chamada por esta
// 	Private cMV_GFE005 := SuperGetMv("MV_GFE005",.F.,"1")
// 	Private aDFReConf  := {}

// 	Private lFirstMsg  := .F.

// 	Default lDatabase  := .T.
// 	Default lHelp      := .T.
// 	Default cMsg       := ""
// 	Default aRetCalc   := {}
// 	Default lTstAuto   := .F.

// 	If Empty(cMV_GFE005)
// 		cMV_GFE005 := "1"
// 	EndIf

// 	If lHelp .And. !Empty(GWN->GWN_VIAGEM) .And. !IsInCallStack("GF58ExecPVIA") // Quando lhelp é falso, o cálculo deve ser em lote
// 		If PosicionaGWP(lHelp,@cMsg)
// 			Return GFEA58CVIA(GWN->GWN_NRROM) // Calcula todos romaneios da viagem
// 		Else
// 			Return .F.
// 		EndIf
// 	EndIf
// 	//Verifica se está sendo calculado para um docmento automático para suprimir mensagens
// 	If !lTstAuto
// 		If  !(GWN->GWN_NRROM == GW1->GW1_NRROM)
// 			GW1->( dbSetOrder(09) )
// 			GW1->( dbSeek(xFilial("GW1")+GWN->GWN_NRROM) )
// 		EndIf
// 		If (GW1->GW1_CALCAT == "1" .OR. Empty(GW1->GW1_CALCAT)) ;
// 				.And. Posicione("GV5",1,xFilial("GV5")+GW1->GW1_CDTPDC,"GV5_CALC") == "2"

// 			lCalcAuto := .T.
// 		EndIf
// 	Else
// 		lCalcAuto := .T.
// 	EndIf

// 	aAgrFrt  := {}
// 	aDocCarg := {}
// 	aTrchDoc := {}
// 	aItDoc   := {}

// 	aAreaGWN := GWN->( GetArea() )
// 	// Validações em relação ao documento de carga
// 	GWN->( dbSetOrder(1) )
// 	aDocsCarg := {.F.,{}}
// 	If GWN->(dbSeek(xFilial("GWN") + GWN->GWN_NRROM))
// 		aDocsCarg := GF50VLROM(GWN->GWN_NRROM,lCalcAuto,"ROMANEIO") // Valida e retorna os documentos recalculáveis
// 	EndIf

// 	// [1]: 0=Todos podem calcular; 1=alguns podem calcular; 2=Nenhum pode calcular; 3=Romaneio calculado no ERP
// 	// [2]: Dados de DCs localizados.
// 	// [3]: Mensagem de problemas identificados
// 	// [4]: Num Calculo pré existente nos DCs localizados
// 	If Len(aDocsCarg[2]) == 0
// 		If GW1->GW1_SIT == "2"
// 			cMsg := "O Documento de Carga relacionado ao Romaneio está bloqueado."
// 		Else
// 			cMsg := "Não há documentos relacionados ao Romaneio."
// 		EndIf

// 		If lCalcAuto == .F. .AND. lHelp
// 			Help( ,, 'HELP',, cMsg, 1, 0)
// 		EndIf
// 		Return .F.
// 	ElseIf aDocsCarg[1] == 3
// 		cMsg := aDocsCarg[2,Len(aDocsCarg[2]),2]
// 		If lCalcAuto == .F. .AND. lHelp
// 			Help( ,, 'HELP',, cMsg, 1, 0)
// 		EndIf
// 		Return .F.
// 	ElseIf aDocsCarg[1] == 2
// 		cMsg := "Não foi possível recalcular nenhum frete para documentos relacionados ao romaneio." + CRLF  + CRLF + "Motivos: "
// 		nF := Len(aDocsCarg[3])
// 		For nX := 1 To nf
// 			cMsg += aDocsCarg[3,nX] + CRLF
// 		Next nX
// 		If lCalcAuto == .F. .AND. lHelp
// 			Help( ,, 'Cálculo de Frete',, cMsg, 1, 0)
// 		EndIf
// 		Return .F.
// 	ElseIf aDocsCarg[1] == 1
// 		cMsg := "As seguintes situações impedem o recálculo de alguns documentos relacionados:" + CRLF
// 		nF := Len(aDocsCarg[3])
// 		For nX := 1 To nF
// 			cMsg += aDocsCarg[3,nX] + CRLF
// 		Next nX
// 		If lCalcAuto == .F. .AND. lHelp .And. !IsBlind() .And. !MsgYesNo(cMsg +  "Deseja prosseguir?")
// 			cMsg := ""
// 			Return .F.
// 		EndIf
// 	EndIf
// 	// Início Ponto de Entrada Britania
// 	If ExistBlock("XGFECALI")
// 		aRotAdic := ExecBlock("XGFECALI",.F.,.F.,{GWN->GWN_NRROM})
// 	EndIf
// 	// Fim Ponto de Entrada Britania
// 	RestArea(aAreaGWN)

// 	GWN->(dbSetOrder(1))
// 	If GWN->(dbSeek(xFilial("GWN") + GWN->GWN_NRROM))

// 		aAdd(aAgrFrt, { GWN->GWN_NRROM ,; //Numero do Agrupador
// 		GWN->GWN_CDTRP ,; //Transportador
// 		GWN->GWN_CDTPVC,; //Tipo de Veiculo
// 		GWN->GWN_CDCLFR,; //ClassIficacao de Frete
// 		GWN->GWN_CDTPOP,; //Tipo de Operacao
// 		GWN->GWN_DISTAN,; //Distancia Percorrida
// 		GWN->GWN_NRCIDD,; //Cidade Destino
// 		GWN->GWN_CEPD,;   //CEP Destino
// 		'0'})             //ERRO

// 		aDocCarg := {}
// 		aItDoc   := {}
// 		aTrchDoc := {}
// 		aNoCalc  := {}

// 		GF50ARCLC(aDocsCarg,aDocCarg,aItDoc,aTrchDoc,aNoCalc)
// 	EndIf

// 	If (Len(aTrchDoc) == 0 .Or. Len(aItDoc) == 0) .And. aDocsCarg[1] != 2
// 		cMsg := "Documento de Carga não possui item ou trecho."
// 		If lCalcAuto == .F. .And. lHelp
// 			Help( ,, 'HELP',, cMsg, 1, 0)
// 		EndIf
// 		Return .F.
// 	EndIf

// 	// Executa o cálculo e armazena o retorno em um vetor
// 	// [1] Sucesso (True/Não)
// 	// [2] Arquivo de log
// 	// [3] Array de Erros

// 	@sample GFECLCFRT(aAgrFrt, aDocCarg, aTrchDoc, aItDoc, aTblFrt, lReal, iLogProc, nTabProv, lParCons, iTpSimul, lCalcLote, lHideProgress, lLog, lServ, pServTpImp, pCalcDataBase) */

// 	aAgrFrt2  := aClone(aAgrFrt)
// 	aDocCarg2 := aClone(aDocCarg)
// 	aTrchDoc2 := aClone(aTrchDoc) 
// 	aItDoc2   := aClone(aItDoc)

// 	If aDocsCarg[1] != 2
// 		//Ponto de Entrada Negociação de Frete
// 		If ExistBlock("GFE05010")
// 			aItDoc := ExecBlock("GFE05010",.f.,.f.,{GWN->GWN_PLACAD,aItDoc})
// 		EndIf
// 		//Fim Ponto de Entrada

// 		aRetGXT := GFEA50GXT()		
// 		aRetCalc := GFECLCFRT(aAgrFrt, aDocCarg, aTrchDoc, aItDoc, IIF(aRetGXT[1]== .T.,aRetGXT[2],Nil), .T.,If( lCalcAuto .OR. !lHelp ,0,2),,,,,lCalcAuto .OR. !lHelp,lLog, /* lServ */, /* pServTpImp */, lDatabase,aNoCalc)
		
// 		lCalcrom := aRetCalc[1]
// 		cArqLog := aRetCalc[2]
// 		If aRetCalc[1]
// 			GWN->(dbSetOrder(1))
// 			If GWN->(dbSeek(xFilial("GWN") + aAgrFrt[1,1]))
// 				RecLock('GWN', .F. )
// 					GWN->GWN_CALC   := "1"
// 					GWN->GWN_MTCALC := "Calculado com sucesso"
// 					If lDatabase
// 						GWN->GWN_DTCALC := DDATABASE
// 					Else
// 						GWN->GWN_DTCALC := Date()
// 					EndIf

// 					GWN->GWN_HRCALC := SubStr(TIME(), 1, 5)				

// 					If  !Empty(GWN->GWN_DTSAI) .AND. !Empty(GWN->GWN_HRSAI)
// 						PrevEntreg(GWN->GWN_FILIAL, GWN->GWN_NRROM, GWN->GWN_DTSAI, GWN->GWN_HRSAI)
// 					EndIf
					
// 					If GFXCP12127("GXY_NRCT")
					
// 						GWF->(dbSetOrder(04) )
// 						GWF->(dbSeek(xFilial("GWF")+GWN->GWN_NRROM) ) 
// 						Do While GWF->(!Eof()) .And. GWF->GWF_FILIAL == xFilial("GWF") .And. GWF->GWF_NRROM == GWN->GWN_NRROM
// 							GXY->(dbSetOrder(2))
// 							GXY->(dbSeek(GWF->GWF_FILIAL+GWF->GWF_NRCALC))
// 							Do While GXY->(!Eof() ) .And. GXY->GXY_FILCA == GWF->GWF_FILIAL .And. GXY->GXY_NRCALC == GWF->GWF_NRCALC
// 								GWN->GWN_NRCT := GXY->GXY_NRCT
// 								GXY->(dbSkip())
// 							EndDo
						
// 							GWF->(dbSkip())
// 						EndDo
// 					EndIf
				
// 				GWN->(MsUnlock())
// 			EndIf
			
// 			If cMV_GFE005 == "2"
// 				nF := Len(aDFReConf)
// 				For nX := 1 To nF
// 					GW3->(dbSetOrder(1))
// 					If GW3->(dbSeek(aDFReConf[nX][1] + aDFReConf[nX][2] + aDFReConf[nX][3] + aDFReConf[nX][4] + aDFReConf[nX][5] + aDFReConf[nX][6]))
// 						GFE50DFCONF()
// 					EndIf
// 				Next nX
// 			EndIF
// 		Else
// 			GWN->(dbSetOrder(1))
// 			If GWN->(dbSeek(xFilial("GWN") + aAgrFrt[1,1]))
// 				RecLock('GWN', .F. )
// 					GWN->GWN_CALC   := "3"
					
// 					aErr:= GFECalcErr(aRetCalc[3][1][2])
// 					nF := Len(aRetCalc[3][1][4])
// 					For nY:= 1 To nF
// 						aErr[1] := StrTran(aErr[1],"[" + cValToChar(nY) + "]",aRetCalc[3][1][4][nY])
// 					Next nY
					
// 					GWN->GWN_MTCALC := " " + aErr[1] + CRLF + "----" + CRLF
				
// 					If Empty(GWN->GWN_MTCALC)
// 						GWN->GWN_MTCALC := "Falha no cálculo"
// 					EndIf
// 					GWN->GWN_DTCALC := CToD("  /  /    ")
// 					GWN->GWN_HRCALC := ""
// 				GWN->( MsUnLock() )
				
// 				If  !Empty(GWN->GWN_DTSAI) .AND. !Empty(GWN->GWN_HRSAI)
// 					PrevEntreg(GWN->GWN_FILIAL, GWN->GWN_NRROM, GWN->GWN_DTSAI, GWN->GWN_HRSAI)
// 				EndIf
// 			EndIf
// 		EndIf
// 	Else	
// 		lCalcrom := .T. //Significa que já foi recebido os documentos de frete do cálculo normal/redespacho
// 	EndIf
	
// 	If lCalcrom .And. GFXCP12117("GV9_TPIMP") == .T. 
// 		aTblFrFUNB := {}
// 		cAliasQry := GetNextAlias()
// 		BeginSql Alias cAliasQry
// 			SELECT GWG.GWG_CDEMIT,
// 					GWG.GWG_NRTAB,
// 					GWG.GWG_NRNEG,
// 					GWG.GWG_NRROTA,
// 					GWG.GWG_CDFXTV,
// 					GWF.R_E_C_N_O_ AS RECNOGWF
// 			FROM %Table:GWF% GWF
// 			INNER JOIN %Table:GWG% GWG
// 			ON GWG.GWG_FILIAL = GWF.GWF_FILIAL
// 			AND GWG.GWG_NRCALC = GWF.GWF_NRCALC
// 			AND GWG.%NotDel%
// 			WHERE GWF.GWF_FILIAL = %xFilial:GWF%
// 			AND GWF.GWF_NRROM = %Exp:GWN->GWN_NRROM%
// 			AND GWF.%NotDel%
// 			GROUP BY GWG.GWG_CDEMIT,
// 						GWG.GWG_NRTAB,
// 						GWG.GWG_NRNEG,
// 						GWG.GWG_NRROTA,
// 						GWG.GWG_CDFXTV,
// 						GWF.R_E_C_N_O_
// 		EndSql
// 		Do While (cAliasQry)->(!Eof())
// 			GWF->(dbGoTo( (cAliasQry)->RECNOGWF ))

// 			If GWF->GWF_TPCALC == "7" .And. ChkCompServ() // Verifica se o calculo anterior usado teve componentes de serviço, se sim exclui calculo
// 				GFEDelCalc( GWF->GWF_NRCALC )	// Apaga o calculo de frete e seus relacionamentos, incluindo movimentos contábeis
// 			Else
// 				aADD(aTblFrFUNB,{GWN->GWN_NRROM,(cAliasQry)->GWG_NRTAB,(cAliasQry)->GWG_NRNEG,(cAliasQry)->GWG_NRROTA,(cAliasQry)->GWG_CDFXTV,(cAliasQry)->GWG_CDEMIT})
// 			EndIf

// 			(cAliasQry)->(dbSkip())
// 		EndDo
// 		(cAliasQry)->(dbCloseArea())

// 		aTcomps := GFEXCOMP(aTblFrFUNB)
	    
// 		aDocsCarg := GF50VLROM(GWN->GWN_NRROM,lCalcAuto,"SERVICO")
		
// 		aDocCarg := {}
// 		aItDoc   := {}
// 		aTrchDoc := {}
// 		aNoCalc  := {}
		
// 		If aDocsCarg[1] == 2
// 			cMsg := "Não foi possível recalcular nenhum serviço para documentos relacionados ao romaneio. Motivos:" + CRLF
// 			nF := Len(aDocsCarg[3])
// 			For nX := 1 To nF
// 				cMsg += aDocsCarg[3,nX] + CRLF
// 			Next nX 
// 			If lCalcAuto == .F. .AND. lHelp
// 				Help( ,, 'HELP',, cMsg, 1, 0)
// 			EndIf
// 			Return .F.
// 		EndIf
		
// 		GF50ARCLC(aDocsCarg,aDocCarg,aItDoc,aTrchDoc,aNoCalc)//Alimenta os arrays do cálculo
	
// 		aDocCarg2 := aClone(aDocCarg)
// 		aTrchDoc2 := aClone(aTrchDoc) 
// 		aItDoc2 := aClone(aItDoc)
	
// 		If !Empty(aTblFrFUNB)
// 			GV9->(dbSetOrder(1))
// 			If GV9->(dbSeek(xFilial("GV9")+aTblFrFUNB[1][6]+aTblFrFUNB[1][2]+aTblFrFUNB[1][3])) //GV9_FILIAL+GV9_CDEMIT+GV9_NRTAB+GV9_NRNEG
// 				If Empty(GV9->GV9_TPIMP)
// 					cGU5_TPIMP := '1'
// 				Else
// 					cGU5_TPIMP := GV9->GV9_TPIMP
// 				EndIf
// 			EndIf

// 			If Len(aTcomps) > 0 .And. aTcomps[1][5] == .T.
// 				GFEServFrete({}, aAgrFrt2, aDocCarg2, aTrchDoc2, aItDoc2, nQtPern, cNrOcor, IsInCallStack('GFEA117'), cGU5_TPIMP, ,.f.,.f.,lCalcAuto .OR. !lHelp,aNoCalc) //Função que realiza o cálculo de serviço
// 			EndIf	
// 		EndIf
		
// 	EndIf

// 	// Início Ponto de Entrada Britania
// 	If ExistBlock("XGFECALF")
// 		aRotAdic := ExecBlock("XGFECALF",.F.,.F.,{GWN->GWN_NRROM})
// 	EndIf
// 	// Fim Ponto de Entrada Britania

// 	//Ponto de entrada validação Vicunha
// 	If ExistBlock("GFEA0508")
// 		ExecBlock("GFEA0508",.F.,.F.)
// 	EndIf
// Return lCalcRom

// Static Function GFE050AJUS()
// 	Local oDlg      := Nil
// 	Local nAlt      := 550
// 	Local nLrg      := 850
// 	Local cDsTransp := ""
// 	Local oCombo    := Nil
// 	Local cCombo    := ""
// 	Local oGet      := Nil
// 	Local cAliasQry := Nil
// 	Local aTpCalc   := RetSx3Box(Posicione('SX3',2,'GWF_TPCALC','X3CBox()'),,,1)
// 	Local nTpCalc   := 0
// 	Local aItems    := {}
// 	Local lRet      := .T.
// 	Local lPE17		:= ExistBlock("GFE05017")

// 	Private nVlFrete     := 0
// 	Private nVlTotAj     := 0
// 	Private nVlFinal     := 0
// 	Private nVlAjust     := 0
// 	Private lImpEmbutido := .F.
// 	Private nImpAliquota := 0
// 	Private nImpValor    := 0
// 	Private cJustIfi     := ""

// 	Private cCadastro := "Ajuste do Romaneio de Carga" //"Ajuste do Romaneio de Carga"
// 	Private cMarca    := GetMark()

// 	//Ponto de entrada validação Vicunha
// 	If ExistBlock("GFEA0506")
// 		If ExecBlock("GFEA0506",.F.,.F.,{"6"})
// 			lRet := .F.
// 		EndIf
// 	EndIf

// 	If lRet .And. GWN->GWN_CALC != "1"
// 		Help( ,, 'HELP',, "Romaneio de Carga não pode ser Ajustado pois ainda não foi Cálculado.", 1, 0)	 //"Romaneio de Carga não pode ser Ajustado pois ainda não foi Cálculado."
// 		lRet := .T.
// 	EndIf
// 	//----------------------------------------------
// 	// Criacao da tabela temporaria p/ Markbrowse
// 	//----------------------------------------------
// 	If lRet
// 		aMKB :=    {{"DTAJUS" ,"D",08 ,0},;
// 					{"HRAJUS" ,"C",05 ,0},;
// 					{"VLAJUS" ,"N",12 ,2},;
// 					{"SIT"    ,"C",20 ,0},;
// 					{"DTAPRO" ,"D",08 ,0},;
// 					{"HRAPRO" ,"C",05 ,0}}

// 		aCpMKB  := {{"DTAJUS"  ,NIL,"Data Ajuste",""  },; //"Data Ajuste"
// 					{"HRAJUS"  ,NIL,"Hora Ajuste","@!"},; //"Hora Ajuste"
// 					{"SIT"     ,NIL,"Situação","@!"},; //"Situação"
// 					{"VLAJUS"  ,NIL,"Valor Ajuste","@E 999,999,999.99"},; //"Valor Ajuste"
// 					{"DTAPRO"  ,NIL,"Data Aprovação/Reprovação",""  },; //"Data Aprovação/Reprovação"
// 					{"HRAPRO"  ,NIL,"Hora Aprovação/Reprovação","@!"}} //"Hora Aprovação/Reprovação"

// 		cAliMKB := GFECriaTab({aMKB,{"DTAJUS"}})

// 		CursorWait()

// 		//--------------------------
// 		// Montagem da tela
// 		//--------------------------
// 		Define MsDialog oDlg Title cCadastro From 00,00 To nAlt,nLrg Of oMainWnd Color CLR_BLACK,RGB(225,225,225) Pixel
// 		oDlg:lEscClose := .F.

// 		oPnlA := tPanel():New(00,00,,oDlg,,,,,,30,135,.F.,.F.)
// 		oPnlA:Align := CONTROL_ALIGN_TOP
// 		oPnlB := tPanel():New(00,00,,oDlg,,,,,,30,40,.F.,.F.)
// 		oPnlB:Align := CONTROL_ALIGN_ALLCLIENT

// 		cAliasQry := GetNextAlias()
// 		BeginSql Alias cAliasQry
// 			SELECT GWF.GWF_NRCALC,
// 					GWF.GWF_TPCALC,
// 					GWF.GWF_DTCRIA,
// 					GU3.GU3_NMEMIT
// 			FROM %Table:GWF% GWF
// 			INNER JOIN %Table:GU3% GU3
// 			ON GU3.GU3_FILIAL = %xFilial:GU3%
// 			AND GU3.GU3_CDEMIT = GWF.GWF_TRANSP
// 			AND GU3.%NotDel%
// 			WHERE GWF.GWF_FILIAL = %xFilial:GWF%
// 			AND GWF.GWF_NRROM  = %Exp:GWN->GWN_NRROM%
// 			AND GWF.GWF_TPCALC <> '8' // 8 - Estimativa
// 			AND GWF.%NotDel%
// 		EndSql
// 		TCSetField(cAliasQry,"GWF_DTCRIA","D",8,0)
// 		If (cAliasQry)->(!Eof())
// 			Do While (cAliasQry)->(!Eof())
// 				nTpCalc := Val(AllTrim((cAliasQry)->GWF_TPCALC))
// 				// Adiciona o cálculo no array
// 				Aadd(aItems,"Cálculo: " + (cAliasQry)->GWF_NRCALC + " | " + PadR((cAliasQry)->GU3_NMEMIT,50) + " | " + PadR(aTpCalc[nTpCalc,3],20) + " | " + DtoC((cAliasQry)->GWF_DTCRIA)) //"Cálculo: "
// 				(cAliasQry)->(dbSkip())
// 			EndDo
			
// 			//Indica que o Combo sera carregado no primeiro item do array
// 			cCombo:= aItems[1]
			
// 			cDsTransp := posicione("GU3",1,xFilial("GU3")+GWN->GWN_CDTRP,"GU3_NMEMIT")

// 			@ 07,15  Say "Número Romaneio: " Of oPnlA COLOR CLR_BLACK Pixel //"Número Romaneio: "
// 			@ 05,63  MSGET GWN->GWN_NRROM   Picture "@!" Of oPnlA When .F.   Pixel

// 			@ 22,25 Say "Transportador: "              Of oPnlA COLOR CLR_BLACK Pixel //"Transportador: "
// 			@ 20,63 MSGET GWN->GWN_CDTRP  Picture "@!" Of oPnlA When .F.   Pixel

// 			@ 20,118 MSGET cDsTransp Picture "@!" Of oPnlA When .F.   Pixel

// 			@ 37,18 Say "Cálculo a Ajustar: "              Of oPnlA COLOR CLR_BLACK Pixel //"Cálculo a Ajustar: "
// 			oCombo:= tComboBox():New(36,63,{|u|If(PCount()>0,cCombo:=u,cCombo)},aItems,300,10,oPnlA,,{||GFEA050COB(cCombo)},,,,.T.,,,,,,,,,'cCombo')

// 			//Chamada da Função para carregar os valores do cálculo
// 			GFEA050COB(cCombo)

// 			@ 53,32 Say "Valor Frete: "              Of oPnlA COLOR CLR_BLACK Pixel //"Valor Frete: "
// 			@ 51,63 MSGET nVlFrete Picture "@! 999,999,999.99" Of oPnlA When .F.   Pixel

// 			@ 68,132 Say "Valor Total Ajustes: "              Of oPnlA COLOR CLR_BLACK Pixel            //"Valor Total Ajustes: "
// 			@ 66,180 MSGET nVlTotAj Picture "@! 999,999,999.99" Of oPnlA When .F.   Pixel

// 			@ 53,151 Say "Valor Final: "              Of oPnlA COLOR CLR_BLACK Pixel            //"Valor Final: "
// 			@ 51,180 MSGET nVlFinal Picture "@! 999,999,999.99" Of oPnlA When .F.   Pixel

// 			@ 68,29 Say "Valor Ajuste: "              Of oPnlA COLOR CLR_BLACK Pixel   //"Valor Ajuste: "
// 			@ 66,63 Get oGet Var nVlAjust Picture '@E 999,999,999.99' Pixel OF oPnlA
// 			oGet:bChange := {||/* GFE050AJ()*/ }

// 			@ 83,26 Say "Motivo Ajuste: "              Of oPnlA COLOR CLR_BLACK Pixel     	 //"Motivo Ajuste: "
// 			oTMultiget1 := TMultiget():New(83,63,{|u|If(Pcount()>0,cJustIfi:=u,cJustIfi)},oPnlA,300,45,,,,,,.T.,,,,,,.F.,{|u| If(len(cJustIfi) > 254, GFEMsgErro("O tamanho máximo de caracteres para a descrição do motivo é de 254."+CRLF+CRLF+"- A descrição informada possui "+Alltrim(Str(Len(cJustIfi)))+ " caracteres."),.T. )})
// 			oTMultiget1:EnableVScroll( .T. )
// 			oTMultiget1:GoEnd()
// 			oTMultiget1:Refresh()

// 			oTButton3 := TButton():Create( oPnlA,65,250,"Efetivar Ajuste",{||GFEA050EAJ(cJustIfi, cCombo)},50,11,,,,.T.,,,,,,)         //"Efetivar Ajuste"

// 			Processa({|lEnd| GFE50ACGAJU(cCombo)},"Processando informações","Aguarde") //"Processando informações"###"Aguarde"

// 			CursorArrow()

// 			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(ODlg,{||,ODlg:End()},{||,ODlg:End(),},,/*oMark:oBrowse:Gotop()*/) CENTERED

// 			GFEDelTab(cAliMKB)
// 		Else
// 			Help( ,, 'HELP',, "Romaneio não possui cálculo a ser ajustado", 1, 0)
// 			lRet := .F.
// 		EndIf
// 		(cAliasQry)->(dbCloseArea())
// 	EndIf

// 	// Ponto de Entrada IMERYS PERLITA PAULINIA MINERAIS LTDA
// 	If lRet .And. lPE17
// 		ExecBlock("GFE05017",.F.,.F., {GWN->GWN_FILIAL, GWN->GWN_NRROM})	
// 	EndIf
// Return lRet

// Static Function GFEA050COB(cCombo,lAtuLista)
// 	Local cNrCalc     := Substring(cCombo,10,8) //Pega dentro da Variavel cCombo o Valor que representa o número daquele Cálculo
	
// 	Default lAtuLista := .T.
	
// 	nVlFrete     := 0
// 	nVlTotAj     := 0
// 	lImpEmbutido := .F.
// 	nImpValor    := 0
// 	cJustIfi     := ""

// 	If lAtuLista
// 		//Limpa Tabela Temporaria
// 		dbSelectArea(cAliMKB)
// 		ZAP
// 	EndIf
// 	//Recebe o retorno da função VLTOTFRET que retorna o valor do cálculo do frete
// 	GWF->(dbSetOrder(1))
// 	If GWF->(dbSeek(xFilial("GWF") + cNrCalc))
// 		IF GWF->GWF_ADICIS == "1"
// 			lImpEmbutido := .T.
// 			If GWF->GWF_IMPOST == "1" // ICMS
// 				nImpValor    := GWF->GWF_VLICMS
// 				nImpAliquota := GWF->GWF_PCICMS
// 			Else // ISS
// 				nImpValor    := GWF->GWF_VLISS
// 				nImpAliquota := GWF->GWF_PCISS
// 			EndIf
// 		EndIf

// 		GWI->(dbSetOrder(1))
// 		GWI->(dbSeek(xFilial("GWI") + GWF->GWF_NRCALC))
// 		Do While GWI->(!Eof()) .And. xFilial("GWI") == GWI->GWI_FILIAL .And. GWI->GWI_NRCALC == GWF->GWF_NRCALC
// 			If GWI->GWI_TOTFRE == "1"
// 				nVlFrete += GWI->GWI_VLFRET
// 			EndIf
// 			GWI->(dbSkip())
// 		EndDo
// 	EndIf

// 	GWO->(dbSetOrder(1))
// 	GWO->(dbSeek(xFilial("GWO")+cNrCalc))
// 	Do While GWO->(!Eof()) .And. xFilial("GWO") == GWO->GWO_FILIAL .And. GWO->GWO_NRCALC == cNrCalc
// 		//Soma o valor dos ajustes ja realizados
// 		If GWO->GWO_SITAJU <> "3"
// 			nVlTotAj += GWO->GWO_VLAJUS
// 		EndIf
// 		GWO->(dbSkip())
// 	EndDo

// 	// Atualiza o Valor Final do Frete
// 	GFE050AJ()
	
// 	If lAtuLista
// 		Processa({|lEnd| GFE50ACGAJU(cCombo)},"Processando informações","Aguarde") //"Processando informações"###"Aguarde"
// 	EndIf

// Return .T.

// Static Function GFE050AJ()
// 	//nVlFinal - Valor Final  - Private
// 	//nVlFrete - Valor Frete  - Private
// 	//nVlAjust - Valor Ajuste - Private
// 	If lImpEmbutido
// 		nVlFinal := (nVlFrete - nImpValor) + nVlTotAj
// 		nVlFinal := NoRound(nVlFinal / ((100 - nImpAliquota) / 100), 2)
// 	Else
// 		nVlFinal := nVlFrete + nVlTotAj
// 	EndIf
// Return .T.

// Static Function GFE50ACGAJU(cCombo)
// 	Local cNrCalc := Substring(cCombo,10,8)
// 	Local cDesSit := ""

// 	//Limpa Tabela Temporaria
// 	dbSelectArea(cAliMKB)
// 	ZAP

// 	GWO->( dbSetOrder(1) )
// 	GWO->( dbSeek(xFilial("GWO") + cNrCalc) )
// 	Do While GWO->(!Eof()) .And. xFilial("GWO") == GWO->GWO_FILIAL .And. GWO->GWO_NRCALC == cNrCalc
// 		//Carrega a Variavel cDesSit com a descrição da situação
// 		If GWO->GWO_SITAJU == "1"
// 			cDesSit	:= "Solicitado" //"Solicitado"
// 		ElseIf GWO->GWO_SITAJU == "2"
// 			cDesSit := "Aprovado" //"Aprovado"
// 		ElseIf GWO->GWO_SITAJU == "3"
// 			cDesSit := "Reprovado" //"Reprovado"
// 		EndIf

// 		//Grava o registro encontrado na Tabela Temporaria
// 		RecLock(cAliMKB,.T.)
// 			(cAliMKB)->DTAJUS := GWO->GWO_DTAJUS
// 			(cAliMKB)->HRAJUS := Transform(StrTran(GWO->GWO_HRAJUS,":",""),"@R 99:99")
// 			(cAliMKB)->VLAJUS := GWO->GWO_VLAJUS
// 			(cAliMKB)->SIT    := cDesSit
// 			(cAliMKB)->DTAPRO := GWO->GWO_DTAPRP
// 			(cAliMKB)->HRAPRO := GWo->GWO_HRAPRP
// 		(cAliMKB)->(MsUnLock())
// 		GWO->( dbSkip() )
// 	EndDo

// 	(cAliMKB)->(dbSetOrder(01))
// 	(cAliMKB)->(dbGoTop())

// 	oMark := MsSelect():New(cAliMKB,,,aCpMKB,,,{0,0,0,0},,,oPnlB)
// 	oMark:oBrowse:cToolTip := "Visualização" //"Visualização"
// 	oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
// 	oMark:OBrowse:Refresh()
// Return .T.

// Static Function GF50VLDAJ(cJustIfi, cCombo, lAjusteMenor, cMsg)
// 	Local nFreteFinal    := 0
// 	Local nFrtSemAj      := 0
// 	Default lAjusteMenor := .F.
// 	// Validações private
// 	If lImpEmbutido 
// 		nFreteFinal := (nVlFrete - nImpValor) + nVlTotAj + nVlAjust
// 		nFreteFinal := NoRound(nFreteFinal / ((100 - nImpAliquota) / 100), 2)
// 		nFrtSemAj := (nVlFrete - nImpValor) + nVlTotAj
// 	Else
// 		nFreteFinal := (nVlFrete + nVlTotAj + nVlAjust)
// 		nFrtSemAj := (nVlFrete - nImpValor) + nVlTotAj
// 	EndIf
	
// 	//Se o valor do ajuste estiver como Zero apresenta mensagem de Erro
// 	If nVlAjust == 0
// 		If cMsg == Nil
// 			Help( ,, 'HELP',, "Não foi informado o valor do ajuste", 1, 0)   //"Não foi informado o valor do ajuste"
// 		EndIf
// 		cMsg := "Não foi informado o valor do ajuste" //"Não foi informado o valor do ajuste"
// 		Return .F.
// 	EndIf

// 	If nFreteFinal <= 0 .And. !lAjusteMenor
// 		If lImpEmbutido
// 			If cMsg == Nil
// 				Help( ,, 'HELP',, "O valor final do frete deve ser maior que zero." + CHR(13) + CHR(10) + CHR(13) + CHR(10) + "Observação: Este cálculo de frete possui o valor do imposto embutido. O valor do ajuste será calculado juntamente com o imposto.", 1, 0)
// 			EndIf
// 			cMsg := "O valor final do frete deve ser maior que zero." + CHR(13) + CHR(10) + CHR(13) + CHR(10) + "Observação: Este cálculo de frete possui o valor do imposto embutido. O valor do ajuste será calculado juntamente com o imposto."
// 		Else
// 			If cMsg == Nil
// 				Help( ,, 'HELP',, "O valor final do frete deve ser maior que zero.", 1, 0)
// 			EndIf
// 			cMsg := "O valor final do frete deve ser maior que zero."
// 		EndIf
// 		Return .F.
// 	EndIf

// 	//Se o motivo da JustIficativa estiver em branco Apresenta mensagem de erro
// 	If Empty(cJustIfi)
// 		If cMsg == Nil
// 			Help( ,, 'HELP',, "Motivo do Ajuste deve ser informada.", 1, 0)   //"Motivo do Ajuste deve ser informada."
// 		EndIf
// 		cMsg := "Motivo do Ajuste deve ser informada." //"Motivo do Ajuste deve ser informada."
// 		Return .F.
// 	EndIf
	
// Return GF50VLDCLC(cCombo,@cMsg)

// //Validaçõs para geração de um ajuste de cálculo
// Static Function GF50VLDCLC(cCombo,cMsg)
// 	Local lCalCDoc := GFEA050CAL(SubStr(cCombo,10,8),,@cMsg)
	
// 	If lCalCDoc
// 		Return .F.
// 	EndIf

// 	GWF->(dbSetOrder(1))
// 	If GWF->(dbSeek(xFilial("GWF") + SubStr(cCombo,10,8)))
// 		GWJ->(dbSetOrder(1))
// 		If GWJ->(dbSeek(GWF->GWF_FILPRE + GWF->GWF_NRPREF))
// 			If GWJ->GWJ_SIT == "3" //Confirmada
// 				If cMsg == Nil
// 					Help( ,, 'HELP',, 'Cálculo de frete vinculado a pré-fatura já confirmada.', 1, 0)
// 				EndIf
// 				cMsg := 'Cálculo de frete vinculado a pré-fatura já confirmada.'
// 				Return .F.
// 			EndIf
// 			If GWJ->GWJ_SITFIN == "4" //ATUALIZADO
// 				If cMsg == Nil
// 					Help( ,, 'HELP',, 'Cálculo de frete vinculado a pré-fatura atualizada no financeiro, não pode ser reajustado.', 1, 0)
// 				EndIf
// 				cMsg := 'Cálculo de frete vinculado a pré-fatura atualizada no financeiro, não pode ser reajustado.'
// 				Return .F.
// 			EndIf
// 		EndIf
// 	EndIf
// Return .T.

// Static Function GFEA050EAJ(cJustIfi, cCombo, cMsg, lAjusteMenor,cData,cTime)
// 	Local xAux    := Nil

// 	Default cData        := DDATABASE
// 	Default cTime        := TIME()
// 	Default lAjusteMenor := .F.
	
// 	If !GF50VLDAJ(cJustIfi, cCombo,lAjusteMenor,@cMsg) //Validações
// 		Return .F.
// 	EndIf

// 	cTime := SubStr(cTime,1,5)

// 	GWO->(dbSetOrder(1))
// 	GWO->(dbSeek(xFilial("GWO") + SubStr(cCombo,10,8) + DToS(cData) + PadR(cTime,Len(GWO->GWO_HRAJUS))))
// 	Do While GWO->(!Eof()) .And. GWO->GWO_NRCALC == SubStr(cCombo,10,8) .And. GWO->GWO_DTAJUS == cData .And. GWO->GWO_HRAJUS == PadR(cTime,Len(GWO->GWO_HRAJUS))
// 		xAux := SubStr(cTime,1,2)
// 		cTime := Val(SubStr(cTime,4,2)) + 1
// 		If cTime == 60
// 			xAux := Val(xAux) + 1
// 			If xAux == 24
// 				cData++
// 				cTime := "00:00"
// 			Else
// 				cTime := AllTrim(PADL(xAux, 2, "0")) + ":00"
// 			EndIf
// 		Else
// 			cTime := AllTrim(PADL(xAux, 2, "0")) + ":00"
// 		EndIf
// 		GWO->(dbSkip())
// 	EndDo

// 	//Grava o Ajuste na GWO
// 	RecLock("GWO",.T.)
// 		GWO->GWO_FILIAL := GWN->GWN_FILIAL
// 		GWO->GWO_NRROM  := GWN->GWN_NRROM
// 		GWO->GWO_DTAJUS := cData
// 		GWO->GWO_HRAJUS := cTime
// 		GWO->GWO_USRAJU := cUserName
// 		GWO->GWO_VLFRET := nVlFrete + nVlTotAj
// 		GWO->GWO_VLAJUS := nVlAjust
// 		GWO->GWO_MOTAJU := SubStr(STRTRAN(cJustIfi,CRLF,""),1,254)// Utilizada para não gravar as quebras de linha
// 		GWO->GWO_SITAJU := "1"
// 		GWO->GWO_NRCALC := Substring(cCombo,10,8)
// 	GWO->(MsUnLock())

// 	nVlAjust := 0   //Zera a Variavel do Valor do Ajuste
// 	If !lAjusteMenor
// 		//Chamada da Função para carregar os valores do cálculo
// 		GFEA050COB(cCombo)
// 	EndIf
// Return .T.

// Static Function GFEA50RLMT(cCdMtr, cCdMtr2, cNumMt, lPerg)
// 	Local cValMtr := IIf(cNumMt == "1", cCdMtr, cCdMtr2)

// 	If !Empty(cValMtr)
// 		If !(GFEExistC("GUU",, cValMtr,"GUU->GUU_SIT=='1'"))
// 			Help( ,, 'HELP',, StrTran("O motorista [n] precisa existir e estar ativo.","[n]",cNumMt), 1, 0) //"O motorista [n] precisa existir e estar ativo."
// 			Return .F.
// 		EndIf

// 		If cCdMtr == cCdMtr2
// 			Help( ,, 'HELP',, "Os motoristas não podem ser iguais.", 1, 0) //"Os motoristas não podem ser iguais."
// 			Return .F.
// 		EndIf
// 	EndIf
// Return .T.

// Static Function GFEA50PLC(cPlacaD, cPlacaT, cPlacaM, cTpPlc, lPerg, cRomaneio)
// 	Local lValPlc
// 	Local cCdTpVc

// 	If cTpPlc == "D"
// 		lValPlc := cPlacaD
// 	ElseIf cTpPlc == "T"
// 		lValPlc := cPlacaT
// 	ElseIf cTpPlc == "M"
// 		lValPlc := cPlacaM
// 	EndIf

// 	IIf(lPerg, cCdTpVc := Posicione("GWN", 1, xFilial("GWN") + cRomaneio, "GWN_CDTPVC"), cCdTpVc := FwFldGet('GWN_CDTPVC'))

// 	If !Empty(lValPlc)
// 		If !GFEExistC("GU8", 2, lValPlc, "GU8->GU8_SIT=='1'")
// 			Help(,, 'HELP',, "A placa do veículo deve existir e estar ativa.", 1, 0) //A placa do veículo deve existir e estar ativa.
// 			Return .F.
// 		EndIf

// 		If cTpPlc == "D"
// 			If cPlacaD == cPlacaT
// 				Help(,, 'HELP',, "A placa dianteira não pode ser igual a placa traseira.", 1, 0,) //A placa dianteira não pode ser igual a placa traseira.
// 				Return .F.
// 			EndIf

// 			If cPlacaD == cPlacaM
// 				Help(,, 'HELP',, "A placa dianteira não pode ser igual a placa do meio.", 1, 0,) //A placa dianteira não pode ser igual a placa do meio.
// 				Return .F.
// 			EndIf
// 		ElseIf cTpPlc == "T"
// 			If cPlacaT == cPlacaM
// 				Help(,, 'HELP',, "A placa traseira não pode ser igual a placa do meio.", 1, 0,) //A placa traseira não pode ser igual a placa do meio.
// 				Return .F.
// 			EndIf

// 			If cPlacaT == cPlacaD
// 				Help(,, 'HELP',, "A placa traseira não pode ser igual a placa dianteira.", 1, 0,) //A placa traseira não pode ser igual a placa dianteira.
// 				Return .F.
// 			EndIf

// 		ElseIf cTpPlc == "M"
// 			If cPlacaM == cPlacaT
// 				Help(,, 'HELP',, "A placa do meio não pode ser igual a placa traseira.", 1, 0,) //A placa do meio não pode ser igual a placa traseira.
// 				Return .F.
// 			EndIf

// 			If cPlacaM == cPlacaD
// 				Help(,, 'HELP',, "A placa do meio não pode ser igual a placa dianteira.", 1, 0,) //A placa do meio não pode ser igual a placa dianteira.
// 				Return .F.
// 			EndIf

// 		EndIf

// 		GU8->(dbSetOrder(2))
// 		If cTpPlc == "D"
// 			If GU8->(dbSeek(xFilial('GU8') + cPlacaD))
// 				GV3->(dbSetOrder(1))
// 				If GV3->(dbSeek(xFilial('GV3') + GU8->GU8_CDTPVC))
// 					If GV3->GV3_POSCOM <> "1"
// 						Help( ,, 'HELP',, "Placa dianteira deve ser de veículo principal", 1, 0,) //"Placa dianteira deve ser de veículo principal"
// 						Return .F.
// 					EndIf

// 					If !Empty(cCdTpVc) .AND. cCdTpVc <> GV3->GV3_CDTPVC
// 						Help( ,, 'HELP',, "Tipo de veículo do romaneio dIferente do veículo principal", 1, 0,) //"Tipo de veículo do romaneio dIferente do veículo principal"
// 						Return .F.
// 					EndIf
// 				EndIf
// 			EndIf
// 		Else
// 			If GU8->(dbSeek(xFilial('GU8') + lValPlc))
// 				GV3->( dbSetOrder(1) )
// 				If GV3->(dbSeek(xFilial('GV3')+GU8->GU8_CDTPVC))
// 					If GV3->GV3_POSCOM <> "2"
// 						Help( ,, 'HELP',, If(cTpPlc=="T","Placa traseira deve ser do tipo reboque","Placa traseira deve ser do tipo reboque"), 1, 0,) //"Placa traseira deve ser do tipo reboque"
// 						Return .F.
// 					EndIf
// 				EndIf
// 			EndIf
// 		EndIf
// 	EndIf
// Return .T.

// Static Function GFEA50TPVC(cTpVc)

// 	If AllTrim(cTpVc) != ""
// 		If !GFEExistC("GV3",, M->GWN_CDTPVC, "GV3->GV3_SIT=='1'")
// 			Help(,, 'HELP',, "O tipo de veículo deve existir e estar ativo.", 1, 0,) //O tipo de veículo deve existir e estar ativo.
// 			Return .F.
// 		EndIf

// 		If !IsInCallStack("GFEX010") .And. AllTrim(FwFldGet('GWN_PLACAD')) != ""
// 			GU8->(dbSetOrder(2))
// 			If GU8->(dbSeek(xFilial('GU8') + FwFldGet('GWN_PLACAD')))
// 				GV3->(dbSetOrder(1))
// 				If GV3->(dbSeek(xFilial('GV3') + GU8->GU8_CDTPVC))
// 					If cTpVc <> GV3->GV3_CDTPVC
// 						Help(,, 'HELP',, "Tipo de veículo do romaneio dIferente do veículo principal", 1, 0,) //"Tipo de veículo do romaneio dIferente do veículo principal"
// 						Return .F.
// 					EndIf
// 				EndIf
// 			EndIf
// 		EndIf
// 	EndIf
// Return .T.

// Static Function GFEA50TRPL()
// Return .T. //(GU8->GU8_SIT == "1" .AND. (Empty(GU8->GU8_CDPROP) .OR. Empty(M->GWN_CDTRP) .OR. M->GWN_CDTRP == GU8->GU8_CDPROP))

// Static Function GFEA50TRMT()
// Return (GUU->GUU_SIT=="1" .AND. (Empty(GUU->GUU_CDTRP) .OR. Empty(M->GWN_CDTRP) .OR. M->GWN_CDTRP==GUU->GUU_CDTRP))

// //---------------------------------------------------------

// Static Function GFEA50TPLP()
// Return (GU8->GU8_SIT=="1" .AND. (Empty(GU8->GU8_CDPROP) .OR. Empty(Posicione("GWN", 1, xFilial("GWN")+MV_PAR02, "GWN_CDTRP")) .OR. Posicione("GWN", 1, xFilial("GWN")+MV_PAR02, "GWN_CDTRP")==GU8->GU8_CDPROP))

// Static Function GFEA050EAI(oModel, cXML)
// 	Local cError   := ''
// 	Local cWarning := ''
// 	Local oXML     := XmlParser(cXML, '_', @cError, @cWarning)
// 	Local aAreaGWN := GWN->( GetArea() )

// 	If !Empty( cError )
// 		Return NIL
// 	EndIf

// 	cNrRom := PadR( oXML:_GFEA050:_GFEA050_GWN:_GWN_NRROM:_VALUE:TEXT, TamSX3("GWN_NRROM")[1] )
// 	GWN->(dbSetOrder(1))

// 	If oModel:GetOperation() == MODEL_OPERATION_DELETE .AND. GWN->(dbSeek(xFilial("GWN")+cNrRom))
// 		Return .T.
// 	EndIf

// 	If oModel:GetOperation() == MODEL_OPERATION_INSERT .AND. GWN->(dbSeek(xFilial("GWN")+cNrRom))
// 		oModel:SetErrorMessage(,,,,,"Já existe um Embarque cadastrado com a chave informada")
// 		Return .F.
// 	EndIf

// 	If Empty(GetNewPar('MV_TPOPEMB'))
// 		oModel:SetErrorMessage(,,,,,"Parâmetro MV_TPOPEMB não possui valor")
// 		Return .F.
// 	EndIf

// 	oModel:GetModel("GFEA050_GWN"):LoadValue("GWN_CDTPOP",GetNewPar('MV_TPOPEMB'))

// 	RestArea(aAreaGWN)
// Return .T.

// Static Function GFEA050INF()
// 	Local aFields := {"GWN_NRROM", "GWN_CDTRP", "GWN_DSTRP", "GWN_RASTR", "NOUSER"}
// 	Local oSize   := Nil

// 	If GWN->GWN_SIT != "3"
// 		Help( ,, 'HELP',, "Romaneio não está liberado", 1, 0,) //"Romaneio não está liberado"
// 		Return .F.
// 	EndIf

// 	oSize := FWDefSize():New(.T.)
// 	oSize:AddObject( "ENCHOICE", 100, 20, .T., .T. ) // Adiciona enchoice
// 	oSize:SetWindowSize({000, 000, 300, 600})
// 	oSize:lLateral     := .F.  // Calculo vertical
// 	oSize:Process() //executa os calculos

// 	DEFINE MSDIALOG oDlg TITLE "Informação de rastreamento";
// 		FROM oSize:aWindSize[1],oSize:aWindSize[2] ;
// 		TO oSize:aWindSize[3],oSize:aWindSize[4] ;
// 		PIXEL OF oMainWnd

// 	RegToMemory("GWN", .F.)

// 	oComp := MsmGet():New("GWN",, MODEL_OPERATION_UPDATE,,,, aFields,{100, 20,,},{"GWN_RASTR"},;
// 		,,,, oDlg,,.T.,.T.,,.T.,,,,,,)

// 	oComp:oBox:Align := CONTROL_ALIGN_ALLCLIENT

// 	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| IIf(GFEA050RAS(), oDlg:End(), Nil)}, ;
// 		{|| oDlg:End()},, {}) CENTERED

// Return .T.

// Static Function GFEA050RAS()
// 	RecLock("GWN", .F.)
// 	GWN->GWN_RASTR := M->GWN_RASTR
// 	GWN->(MsUnlock())
// Return .T.

// Static Function GFEA050CID()
// 	Local cRet := ""

// 	If !Empty(M->GWN_CEPD)
// 		GU7->(dbSetFilter({|| VAL(GU7->GU7_CEPINI) <= VAL(M->GWN_CEPD) .AND. VAL(GU7->GU7_CEPFIM) >= VAL(M->GWN_CEPD) .AND. !Empty(GU7->GU7_CEPINI) .AND. !Empty(GU7->GU7_CEPFIM) }, ""))
// 		GU7->(dbSetOrder(1))
// 		GU7->(dbGoTop())
// 		If GU7->(dbSeek(xFilial("GU7")))
// 			cRet := GU7->GU7_NRCID
// 		EndIf
// 		GU7->(dbClearFilter())
// 	EndIf
// Return cRet

// Static Function GFEA050UNQ()
// 	Local lRet     := .T.
// 	Local aAreaGWN := GWN->( GetArea() )

// 	If FwFldGet("GWN_ORI") == "2" //Origem ERP
// 		GWN->( dbSetOrder(1))
// 		GWN->( dbSeek( xFilial("GWN")+FwFldGet("GWN_NRROM")))
// 		If GWN->(!Eof()) .And. GWN->GWN_FILIAL == xFilial("GWN") .And. GWN->GWN_NRROM == FwFldGet("GWN_NRROM")
// 			Help( ,, 'HELP',, "Já existe um Romaneio com a chave informada.", 1, 0,)
// 			lRet := .F.
// 		EndIf
// 	EndIf
// 	RestArea( aAreaGWN )
// Return lRet

// Static Function GFE50LbRom()
// 	Local lRet 	     := .F.
// 	Local aAreaGWN   := GWN->(GetArea())
// 	Local aAreaGW1   := GW1->(GetArea())
// 	Local cNrRom     := GWN->GWN_FILIAL + GWN->GWN_NRROM
// 	Local dDataMaior := Nil
// 	Local cHoraMaior := ""

// 	_lSemHelp := .T.

// 	//Ao vincular romaneio, preencher dt e hr de saida do romaneio com maior data de seus documentos
// 	//chamando a rotina padrão de liberação

// 	GW1->(dbSetOrder(9))
// 	GW1->(dbSeek(cNrRom))
// 	If GFEVerCmpo({"GV4_LBRMAT"}) .And. Posicione("GV4",1,xFilial("GV4") + GWN->GWN_CDTPOP,"GV4_LBRMAT") $ "1;2"
// 		dDataMaior := GW1->GW1_DTEMIS
// 		cHoraMaior := Time()

// 		Do While GW1->(!Eof()) .And. GW1->GW1_FILIAL + GW1->GW1_NRROM == cNrRom
// 			If dDataMaior < GW1->GW1_DTEMIS
// 				dDataMaior := GW1->GW1_DTEMIS
// 				cHoraMaior := Time()
// 			EndIF
// 			GW1->(dbSkip())
// 		EndDo
// 		If GV4->GV4_LBRMAT == '2' .And. GWN->GWN_DTIMPL > dDataMaior
// 			dDataMaior := GWN->GWN_DTIMPL
// 			cHoraMaior := Time()
// 		EndIf
// 		RestArea(aAreaGW1)
// 		lRet := GFEA050LIB(.T.,,dDataMaior,cHoraMaior)
// 	EndIf
// 	RestArea(aAreaGWN)
// 	RestArea(aAreaGW1)
// Return lRet

// Static Function GFE50CDOP()
// 	Local cRet := ""
// 	Local cGv4 := ""

// 	If !Empty(M->GWN_CDTPOP)
// 		cGv4:= Posicione("GV4",1,xFilial("GV4") + M->GWN_CDTPOP,"GV4_PEDAG")
// 		If !Empty(cGv4) .And. cGv4 != "1" .And. !Empty(M->GWN_CDTRP) .And. Posicione("GU3",1,xFilial("GU3") + M->GWN_CDTRP,"GU3_VALEP") == "1"
// 			GU3->(dbSetOrder(1))
// 			If GU3->(dbSeek(xFilial("GU3") + SuperGetMV("MV_GFEOVP",.F.,""))) .And. GU3->GU3_SIT == "1" .And. GU3->GU3_FORN == "1"
// 				cRet := GU3->GU3_CDEMIT
// 			EndIf
// 		EndIf
// 	EndIf
// Return cRet

// Static Function GFE50VERVP()
// 	Local lRet   := .T.
// 	Local oModel := FWModelActive()
// 	If IsInCallStack("GFEX300")
// 		If !Empty(oModel:GetValue("GWN_CDTRP")) ;
// 				.And. (Posicione("GU3",1,xFilial("GU3") + oModel:GetValue("GWN_CDTRP"),"GU3_VALEP" ) $ " 2";
// 				.Or. Posicione("GV4",1,xFilial("GV4") + oModel:GetValue("GWN_CDTPOP"),"GV4_PEDAG") $ " 1")

// 			lRet := .F.
// 		EndIf
// 	Else
// 		If !Empty(oModel:GetValue("GFEA050_GWN","GWN_CDTRP")) ;
// 				.And. (Posicione("GU3",1,xFilial("GU3") + oModel:GetValue("GFEA050_GWN","GWN_CDTRP"),"GU3_VALEP" ) $ " 2";
// 				.Or. Posicione("GV4",1,xFilial("GV4") + oModel:GetValue("GFEA050_GWN","GWN_CDTPOP"),"GV4_PEDAG") $ " 1")

// 			lRet := .F.
// 		EndIf
// 	EndIf
// Return lRet

// Static Function GFE50VALVP(cTipoOp, nVpValor,cTransp,cMsg)
// 	Default cTipoOp  := Space(TamSx3("GWN_CDTPOP")[1])
// 	Default nVpValor := 0
// 	Default cTransp  := Space(TamSx3("GWN_CDTRP")[1])

// 	If GfeVerCmpo({'GU3_VALEP'})
// 		If Posicione("GU3",1,xFilial("GU3") + cTransp,"GU3_VALEP") == "1" ;
// 				.And. Posicione("GV4",1,xFilial("GV4") + cTipoOp,"GV4_PEDAG") == "3";
// 				.And. (Empty(nVpValor) .OR. nVpValor <= 0)

// 			If Type("_lSemHelp") == "U" // Definir varivel " Private _lSemHelp := .F.", varivel foi declarada nas funções GFEA050LIBL() e  GFEA081.CalculaRomaneios()
// 				Help(,,'HELP',,"O Tipo de Operação determina que o Valor do pedágio é obrigatório",1,0,)
// 			EndIf
// 			cMsg := "O Tipo de Operação determina que o Valor do pedágio é obrigatório"
// 			Return .F.
// 		EndIf
// 	EndIf
// Return .T.

// //Valida o carregamento da tela de negociação

// Static Function GFE50VERNG(oModel)

// 	If cValToChar(oModel:GetOperation()) $ '25'
// 		Help(,,'HELP',,"Esta ação não está disponível durante a visualização ou exclusão de um registro",1,0)
// 		Return
// 	EndIf
// 	GFEA50NEG(oModel:GetValue("GFEA050_GWN","GWN_CDTRP"),"GFE50GRNEG",oModel)
// Return

// Static Function GFEA50NEG(cCDTRP, uRetorno, oModel)
// 	Local oDlg   := Nil
// 	Local nAlt   := (GetScreenRes()[2])
// 	Local nLrg   := (GetScreenRes()[1]-100)
// 	Local aMKB   := {}
// 	Local aCpMKB := {}
// 	Local oMark  := Nil

// 	Private cAliMKB
// 	Private cCadastro := "Negociações Vigentes"
// 	Private cMarca    := GetMark()
// 	Private _uRetorno := uRetorno
// 	Private aRetorno  := {}
// 	Private oMod      := oModel
// 	Private cTransp   := cCDTRP

// 	//Trata a altura da janela de acordo com a resolução
// 	If nAlt > 1000
// 		nAlt -= (nAlt - 900) * 80/100
// 	ElseIf nAlt < 900
// 		nAlt += (900 - nAlt) * 90/100
// 	EndIf

// 	//----------------------------------------------
// 	// Criacao da tabela temporaria p/ Markbrowse
// 	//----------------------------------------------

// 	aMKB :=    {{"OK"       	,"C",02,0},;
// 		{"GV9_CDTPOP" ,"C",TamSx3("GV9_CDTPOP")[1],0},;
// 		{"GV4_DSTPOP"	,"C",TamSx3("GV4_DSTPOP")[1],0},;
// 		{"GV9_CDCLFR" ,"C",TamSx3("GV9_CDCLFR")[1],0},;
// 		{"GUB_DSCLFR" 	,"C",TamSx3("GUB_DSCLFR")[1],0},;
// 		{"GV7_CDTPVC" ,"C",TamSx3("GV7_CDTPVC")[1],0},;
// 		{"GV3_DSTPVC" ,"C",TamSx3("GV3_DSTPVC")[1],0},;
// 		{"GV9_NRTAB"  ,"C",TamSx3("GV9_NRTAB")[1],0},;
// 		{"GV9_NRNEG" 	,"C",TamSx3("GV9_NRNEG")[1],0}}

// 	aCpMKB  := {{"OK"        	,NIL,"",""},;
// 		{"GV9_CDTPOP" ,NIL,"Código do Tipo de Operação","@!"},;
// 		{"GV4_DSTPOP" ,NIL,"Descrição do Tipo de Operação","@!"},;
// 		{"GV9_CDCLFR" ,NIL,"Código da Classificação de Frete","@!"},;
// 		{"GUB_DSCLFR" ,NIL,"Descrição da Classificação de Frete","@!"},;
// 		{"GV7_CDTPVC" ,NIL,"Código do Tipo de Veículo","@!"},;
// 		{"GV3_DSTPVC" ,NIL,"Descrição do Tipo de Veículo","@!"},;
// 		{"GV9_NRTAB"  ,NIL,"Número da Tabela de Frete","@!"},;
// 		{"GV9_NRNEG"	,NIL,"Número da Negociação","@!"}}

// 	// o segundo indice facilita a busca por registro marcados
// 	cAliMKB := GFECriaTab({aMKB,{"GV9_NRTAB+GV9_NRNEG+GV7_CDTPVC","OK"}})

// 	CursorWait()

// 	//--------------------------
// 	// Montagem da tela
// 	//--------------------------
// 	Define MsDialog oDlg Title cCadastro From 500,120 To nAlt,nLrg Of oMainWnd Color CLR_BLACK,RGB(225,225,225) Pixel
// 	oDlg:lEscClose := .F.

// 	oPnlB := tPanel():New(00,00,,oDlg,,,,,,30,40,.F.,.F.)
// 	oPnlB:Align := CONTROL_ALIGN_ALLCLIENT

// 	(cAliMKB)->(dbSetOrder(1))
// 	(cAliMKB)->(dbGoTop())

// 	oMark := MsSelect():New(cAliMKB,"OK",,aCpMKB,,@cMarca,{0,0,0,0},,,oPnlB)
// 	oMark:oBrowse:bLDblClick := { || GFE50CHK() }
// 	oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

// 	Processa({|lEnd| GFE50NGCRG(cTransp)},"Processando informações","Aguarde")

// 	CursorArrow()

// 	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(ODlg,{||If(Len(aRetorno:=GFE50NEGOK())>0,GFE50NGEND(oDlg),NIL)},;
// 		{||ODlg:End()},,) CENTERED

// 	GFEDelTab(cAliMKB)
// Return

// Static Function GFE50NGCRG(cCdTrp)
// 	Local aAreaGV9 := GV9->(GetArea())
// 	Local aAreaGV7 := GV7->(GetArea())

// 	GV4->(dbSetOrder(1))
// 	GUB->(dbSetOrder(1))
// 	GV7->(dbSetOrder(2))
// 	GV9->(dbSetOrder(1))

// 	If !Empty(cCdTrp)
// 		GV9->(dbSeek(xFilial("GV9")  + cCdTrp))
// 	EndIf

// 	Do While GV9->(!Eof()) .And. GV9->GV9_FILIAL == xFilial("GV9") .And. GV9->GV9_CDEMIT ==  cCdTrp
// 		If  GV9->GV9_SIT == "2" .And. DTOS(GV9->GV9_DTVALI) <= DTOS(Date()) .And. (DTOS(GV9->GV9_DTVALF) >= DTOS(Date()) .OR. Empty(GV9->GV9_DTVALF))
// 			RecLock(cAliMKB,.T.)
// 			(cAliMKB)->GV9_CDTPOP := GV9->GV9_CDTPOP
// 			If !Empty(GV9->GV9_CDTPOP)
// 				(cAliMKB)->GV4_DSTPOP := Posicione("GV4",1,xFilial("GV4") + GV9->GV9_CDTPOP, "GV4_DSTPOP")
// 			EndIf
// 			(cAliMKB)->GV9_CDCLFR := GV9->GV9_CDCLFR
// 			If !Empty(GV9->GV9_CDCLFR)
// 				(cAliMKB)->GUB_DSCLFR := Posicione("GUB",1,xFilial("GUB") + GV9->GV9_CDCLFR, "GUB_DSCLFR")
// 			EndIf
// 			(cAliMKB)->GV9_NRTAB  := GV9->GV9_NRTAB
// 			(cAliMKB)->GV9_NRNEG  := GV9->GV9_NRNEG
// 			If GV7->( dbSeek( xFilial("GV7") + GV9->GV9_CDEMIT + GV9->GV9_NRTAB + GV9->GV9_NRNEG ) )
// 				(cAliMKB)->GV7_CDTPVC := GV7->GV7_CDTPVC
// 				If !Empty(GV7->GV7_CDTPVC)
// 					(cAliMKB)->GV3_DSTPVC := Posicione("GV3",1,xFilial("GV7") + GV7->GV7_CDTPVC, "GV3_DSTPVC")
// 				EndIf
// 			EndIF
// 			(cAliMKB)->(MsUnlock())

// 			GV7->(dbSkip())
// 			Do While GV7->(!Eof()) .And. xFilial("GV7") + GV9->GV9_CDEMIT + GV9->GV9_NRTAB + GV9->GV9_NRNEG == xFilial("GV7") + GV7->GV7_CDEMIT + GV7->GV7_NRTAB + GV7->GV7_NRNEG
// 				RecLock(cAliMKB,.T.)
// 				(cAliMKB)->GV9_CDTPOP := GV9->GV9_CDTPOP
// 				If !Empty(GV9->GV9_CDTPOP)
// 					(cAliMKB)->GV4_DSTPOP := Posicione("GV4",1,xFilial("GV4") + GV9->GV9_CDTPOP, "GV4_DSTPOP")
// 				EndIf
// 				(cAliMKB)->GV9_CDCLFR := GV9->GV9_CDCLFR
// 				If !Empty(GV9->GV9_CDCLFR)
// 					(cAliMKB)->GUB_DSCLFR := Posicione("GUB",1,xFilial("GUB") + GV9->GV9_CDCLFR, "GUB_DSCLFR")
// 				EndIf
// 				(cAliMKB)->GV9_NRTAB  := GV9->GV9_NRTAB
// 				(cAliMKB)->GV9_NRNEG  := GV9->GV9_NRNEG
// 				(cAliMKB)->GV7_CDTPVC := GV7->GV7_CDTPVC
// 				If !Empty(GV7->GV7_CDTPVC)
// 					(cAliMKB)->GV3_DSTPVC := Posicione("GV3",1,xFilial("GV7") + GV7->GV7_CDTPVC, "GV3_DSTPVC")
// 				EndIf
// 				(cAliMKB)->(MsUnlock())
// 				GV7->(dbSkip())
// 			Enddo
// 		EndIF
// 		GV9->(dbSkip())
// 	EndDo
// 	(cAliMKB)->(dbGoTop())
// 	RestArea(aAreaGV7)
// 	RestArea(aAreaGV9)
// Return

// Static Function GFE50CHK()
// 	Local nMark := 0
// 	Local aArea := (cAliMKB)->(GetArea())

// 	(cAliMKB)->(dbSetOrder(2))
// 	(cAliMKB)->(dbSeek(cMarca))
// 	Do While (cAliMKB)->(!Eof()) .And. nMark <= 1
// 		If IsMark('OK',cMarca)
// 			nMark++
// 		EndIf
// 		(cAliMKB)->(dbSkip())
// 	EndDo
// 	RestArea(aArea)
// 	If nMark == 1 .And. !IsMark('OK',cMarca)
// 		Help(,,'HELP',, "Somente um registro pode estar selecionado", 1, 0)
// 		lRet := .F.
// 	Else
// 		RecLock(cAliMKB,.F.)
// 		(cAliMKB)->OK := If(IsMark('OK',cMarca),"  ",cMarca)
// 		(cAliMKB)->(MsUnLock())
// 	EndIf
// Return

// Static Function GFE50NEGOK()
// 	Local lRet     := .T.
// 	Local nMark    := 0
// 	Local aAreaMKB := (cAliMKB)->(GetArea())

// 	(cAliMKB)->(dbSetOrder(2))
// 	(cAliMKB)->(dbSeek(cMarca))
// 	Do While (cAliMKB)->(!Eof()) .And. nMark <= 1
// 		If IsMark('OK',cMarca)
// 			nMark++
// 			Exit
// 		EndIf
// 		(cAliMKB)->(dbSkip())
// 	EndDo

// 	If nMark == 0
// 		Help(,,'HELP',, "É necessário selecionar ao menos um registro", 1, 0)
// 		lRet := .F.
// 	EndIF

// 	If lRet
// 		(cAliMKB)->(dbSeek(cMarca))
// 		If (cAliMKB)->(!Eof())
// 			aAdd(aRetorno,(cAliMKB)->GV9_CDTPOP)
// 			aAdd(aRetorno,(cAliMKB)->GV9_CDCLFR)
// 			aAdd(aRetorno,(cAliMKB)->GV7_CDTPVC)
// 		EndIf
// 	EndIf
// 	RestArea(aAreaMKB)
// Return aRetorno

// // Função que avalia um bloco de código ou uma string com nome de função e executa

// Static Function GFE50NGEND(oDlg)
// 	If Type("_uRetorno") == "C"
// 		&(_uRetorno+"(aRetorno)")
// 	ElseIf Type("_uRetorno") == "B"
// 		Eval(_uRetorno,aRetorno)
// 	EndIf
// 	GfeDelTab(cAliMKB)
// 	oDlg:End()
// Return

// // Função que grava no model ativo as alterações

// Static Function GFE50GRNEG(aRet)
// 	Local oModel := FWModelActive()
// 	Local oView  := FWViewActive()

// 	oModel:LoadValue("GFEA050_GWN","GWN_CDTPOP",aRet[1])
// 	oModel:LoadValue("GFEA050_GWN","GWN_CDCLFR",aRet[2])
// 	oModel:LoadValue("GFEA050_GWN","GWN_CDTPVC",aRet[3])

// 	oMod:LMODIFY :=.T.
// 	oView:Refresh()
// Return

// // Efetua o retorno de um romaneio de frota dedica
// Static Function GFEA050RET()
// 	Local dDataRet
// 	Local cHoraRet
// 	Local cPicHodRet := Alltrim(GetSx3Cache("GWN_HODRET", "X3_PICTURE"))

// 	If Empty(GWN->GWN_DTSAI) .OR. Empty(GWN->GWN_HRSAI)
// 		HELP(,,'HELP',, "Necessário preencher a data e hora de saída do Romaneio.",1,0)
// 		Return .F.
// 	EndIf

// 	dDataRet := GWN->GWN_DTRET
// 	cHoraRet := GWN->GWN_HRRET
// 	nHod     := GWN->GWN_HODRET

// 	If Empty(dDataRet)
// 		dDataRet:= Date()
// 	EndIf

// 	If Empty(cHoraRet)
// 		cHoraRet:= SubStr(Time(),1,5)
// 	EndIf

// 	DEFINE MSDIALOG oDlgRet TITLE "Informar o Retorno" From 4,0 To 13,34 OF oMainWnd //"Liberar"

// 	@  4, 006  SAY "Data do Retorno" SIZE 70,7 PIXEL OF oDlgRet //"Romaneio:"
// 	@ 19, 006  SAY "Hora do Retorno" SIZE 70,7 PIXEL OF oDlgRet //"Data de Saída:"
// 	@ 34, 006  SAY "Hodômetro Retorno" SIZE 70,7 PIXEL OF oDlgRet //"Hora de Saída:"

// 	@  3, 060  MSGET dDataRet  When .T. PICTURE "99/99/9999" SIZE 45,7 PIXEL OF oDlgRet hasbutton Valid GFEVLDATE(dDataRet)
// 	@ 18, 060  MSGET cHoraRet  When .T. PICTURE "@R 99:99" SIZE 15,7 PIXEL OF oDlgRet Valid GFEVLDHR(cHoraRet)
// 	@ 33, 060  MSGET nHod	   When .T. PICTURE cPicHodRet SIZE 15,7 PIXEL OF oDlgRet

// 	TButton():New( 50, 5, "OK", oDlgRet,{||If (GFE50GRAVR(dDataRet,cHoraRet,nHod),oDlgRet:End(),Nil)},;
// 		25, 10,,,.F.,.T.,.F.,,.F.,,,.F. )

// 	TButton():New( 50, 35, "Cancelar", oDlgRet,{||oDlgRet:End()},25, 10,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Cancelar"

// 	ACTIVATE MSDIALOG oDlgRet CENTERED
// Return

// Static Function GFE50GRAVR(cDataRet,cHoraRet,nHod)
// 	Local lRet    := .T.
// 	Local nDistan := 0
// 	Local lPE15		:= ExistBlock("GFE05015")
// 	Local lPE16		:= ExistBlock("GFE05016")

// 	If !Empty(GWN->GWN_DTSAI) .AND. !Empty(cDataRet) .AND. DTOS(GWN->GWN_DTSAI)>= DTOS(cDataRet)
// 		If !Empty(GWN->GWN_HRSAI) .AND. !Empty(cHoraRet) .AND. StrTran(GWN->GWN_HRSAI,":") > cHoraRet
// 			HELP(,,"HELP",,"Data/Hora de Retorno não pode ser menor que a Data de Saída (" + DTOC(GWN->GWN_DTSAI) + " " + GWN->GWN_HRSAI +  ")",1,0)
// 			lRet:= .F.
// 		ElseIf DTOS(GWN->GWN_DTSAI)> DTOS(cDataRet)
// 			HELP(,,"HELP",,"Data de Retorno não pode ser menor que a Data de Saída (" + DTOC(GWN->GWN_DTSAI) + ")",1,0)
// 			lRet := .F.
// 		EndIf
// 	ElseIf !Empty(cDataRet) .AND. Empty(cHoraRet)
// 		HELP(,,"HELP",,"Hora de Retorno deve estar preenchido caso a Data de Retorno esteja.",1,0)
// 		lRet:= .F.
// 	EndIf

// 	If GWN->GWN_HODSAI > nHod
// 		HELP(,,"HELP",,"Valor do hodômetro de retorno deve ser maior do que hodômetro de saída.",1,0)
// 		lRet:= .F.
// 	EndIf

// 	If lPE15
// 		aRet := ExecBlock("GFE05015",.F.,.F., {GWN->GWN_FILIAL, GWN->GWN_NRROM, cDataRet, cHoraRet, nHod})
// 		If ValType(aRet) == "A" .and. !Empty(aRet)
// 			If !aRet[1]
// 				lRet :=  aRet[1]
// 				HELP(,,"HELP",,aRet[2],1,0)
// 			EndIf
// 		EndIf
// 	Endif

// 	If lRet
// 		nDistan := GFEDISTAN(nHod,GWN_HODSAI)

// 		Reclock("GWN",.F.)
// 		GWN->GWN_DTRET 	:= cDataRet
// 		GWN->GWN_HRRET 	:= cHoraRet
// 		GWN->GWN_HODRET	:= nHod
// 		GWN->GWN_DSREAL := nDistan
// 		GWN->(MsUnlock())

// 		MSGINFO("Informações gravadas com sucesso!")
// 	EndIf

// 	If lPE16
// 		ExecBlock("GFE05016",.F.,.F., )
// 	EndIf

// Return lRet

// Static Function GFEA050ExPer(cGrupo,cOrdem,cPergunta) // Função verifica a existencia do pergunte
// 	Local   AreaSX1   := SX1->(GetArea())
// 	Local   lRet      := .F.
// 	Default cPergunta := ""
// 	Default cOrdem    := ""

// 	dbSelectArea("SX1")
// 	SX1->( dbSetOrder(1) )

// 	If SX1->( dbSeek( PadR(cGrupo,10) + cOrdem ) )
// 		If Empty(cPergunta)
// 			lRet := .T.
// 		Else
// 			If AllTrim( X1Pergunt() ) == AllTrim( cPergunta )
// 				lRet := .T.
// 			EndIf
// 		EndIf
// 	EndIf
// 	RestArea(AreaSX1)
// Return lRet

// Static Function ParamF12()
// 	If Pergunte("GFEA050F12", .T.)
// 		cParamF12 := MV_PAR01
// 	EndIf
// Return

// Static Function GFEA50ACT(oModel)
// 	Local oModelGWN := oModel:GetModel("GFEA050_GWN")
// 	Local aFieldGWN := oModelGWN:GetStruct():aFields
// 	Local nI        := 0
// 	Local nF        := 0
// 	//Neste array contem os campos que será copiado do romaneio pai - caso necessite que um campo seja limpado é so retira-lo deste array
// 	Local aCmpGWN   := {"GWN_FILIAL",;
// 						"GWN_NRROM",;
// 						"GWN_CDTPOP",;
// 						"GWN_CDCLFR",;
// 						"GWN_CDTRP",;
// 						"GWN_CDMTR",;
// 						"GWN_CDMTR2",;
// 						"GWN_CDTPVC",;
// 						"GWN_PLACAD",;
// 						"GWN_PLACAT",;
// 						"GWN_PLACAM",;
// 						"GWN_SIT",;
// 						"GWN_DTIMPL",;
// 						"GWN_HRIMPL",;
// 						"GWN_CALC",;
// 						"GWN_USUIMP",;
// 						"GWN_ORI",;
// 						"GWN_PRIOR",;
// 						"GWN_DISTAN",;
// 						"GWN_NRCIDD",;
// 						"GWN_NMCIDD",;
// 						"GWN_CEPD", ;
// 						"GWN_BLOQPF",;
// 						"GWN_OBS",  ;
// 						"GWN_MTCALC",;
// 						"GWN_RASTR",  ;
// 						"GWN_DTRET", ;
// 						"GWN_HRRET", ;
// 						"GWN_HODSAI", ;
// 						"GWN_HODRET", ;
// 						"GWN_FECHAM", ;
// 						"GWN_DTFECH", ;
// 						"GWN_NRCIDO", ;
// 						"GWN_NMCIDO", ;
// 						"GWN_CEPO", ;
// 						"GWN_MOTREA",;
// 						"GWN_DTREAB", ;
// 						"GWN_HRREAB", ;
// 						"GWN_DSREAL",;
// 						"GWN_VPNMOP",;
// 						"GWN_DSCLFR",;
// 						"GWN_USUREA"}

// 	If IsInCallStack("GFEA050") .AND. lCopy
// 		nF := Len(aFieldGWN)
// 		For nI := 1 To nF
// 			If aFieldGWN[nI][3] == "GWN_SIT"
// 				oModelGWN:SetValue(aFieldGWN[nI][3], "1")
// 			ElseIf aFieldGWN[nI][3] == "GWN_FILIAL"
// 				oModelGWN:SetValue(aFieldGWN[nI][3], xFilial())
// 			ElseIf aFieldGWN[nI][3] == "GWN_NRROM"
// 				// necesario deixar assim somente para startar o getxnum do dicionario
// 			ElseIf aFieldGWN[nI][3] == "GWN_CALC"
// 				oModelGWN:SetValue(aFieldGWN[nI][3], "2")
// 			ElseIf aFieldGWN[nI][3] == "GWN_USUIMP"
// 				oModelGWN:SetValue(aFieldGWN[nI][3], cUserName)
// 			ElseIf aFieldGWN[nI][3] == "GWN_AGRUP"
// 				oModelGWN:SetValue(aFieldGWN[nI][3], "2")
// 			ElseIf aFieldGWN[nI][3] == "GWN_DTIMPL"
// 				oModelGWN:SetValue(aFieldGWN[nI][3], Date())
// 			ElseIf aFieldGWN[nI][3] == "GWN_ORI"
// 				oModelGWN:SetValue(aFieldGWN[nI][3], "1")
// 			ElseIf aFieldGWN[nI][3] == "GWN_HRIMPL"
// 				oModelGWN:SetValue(aFieldGWN[nI][3], SUBSTR(TIME(), 1, 2)+":"+SUBSTR(TIME(), 4, 2))
// 			ElseIf aFieldGWN[nI][14]
// 				Loop
// 			ElseIf aScan( aCmpGWN, {|x| x == aFieldGWN[nI][3] } ) > 0
// 				oModelGWN:SetValue(aFieldGWN[nI][3], &("GWN->"+aFieldGWN[nI][3]))
// 			Else
// 				oModel:ClearField("GFEA050_GWN", aFieldGWN[nI][3])
// 			EndIf
// 		Next nI
// 		lCopy := .F.
// 	EndIf
// Return Nil

// Static Function GFEA50COPY()

// 	lCopy := .T.
// 	FWExecView("Cópia","GFEA050",3,,{|| .T.}) //"Cópia"
// Return

// Static Function GFEA050CPT(cNrRom)
// 	Local aAreaAnt  := GetArea()
// 	Local cAliasQry := ""
// 	Local cFilBkp   := cFilAnt

// 	Static _aGWN_TOTVOL := {}
// 	Static _aGWN_TOTPER := {}
// 	Static _aGWN_TOTPEC := {}
// 	Static _aGWN_TOTALT := {}
// 	Static _nFieldCont := 0
// 	Static _aTotais := {0,0,0,0}

// 	// Apenas realiza o select uma vez por registro GWN
// 	// Caso os 4 campos totalizadores estejam ativados (BROWSE == 'S') esta função realizará o
// 	// select apenas a primeira vez, e para os demais campos é apenas retornado o valor do
// 	// parâmetro
// 	If !Empty(cNrRom) .AND. _nFieldCont == 0

// 		cFilAnt := GWN->GWN_FILIAL
// 		If Empty(_aGWN_TOTVOL)
// 			// Precisa carregar apenas uma vez
// 			_aGWN_TOTVOL := TamSx3("GWN_TOTVOL")
// 			_aGWN_TOTPER := TamSx3("GWN_TOTPER")
// 			_aGWN_TOTPEC := TamSx3("GWN_TOTPEC")
// 			_aGWN_TOTALT := TamSx3("GWN_TOTALT")
// 		EndIf

// 		// Conta quantos campos estão ativos para mostra no browse
// 		If GetSx3Cache("GWN_TOTVOL","X3_BROWSE") == "S"
// 			_nFieldCont++
// 		EndIf
// 		If GetSx3Cache("GWN_TOTPER","X3_BROWSE") == "S"
// 			_nFieldCont++
// 		EndIf
// 		If GetSx3Cache("GWN_TOTPEC","X3_BROWSE") == "S"
// 			_nFieldCont++
// 		EndIf
// 		If GetSx3Cache("GWN_TOTALT","X3_BROWSE") == "S"
// 			_nFieldCont++
// 		EndIf

// 		cAliasQry := GetNextAlias()
// 		BeginSql Alias cAliasQry
// 			SELECT SUM(GW8.GW8_VOLUME) GWN_TOTVOL,
// 					SUM(GW8.GW8_PESOR) GWN_TOTPER,
// 					SUM(GW8.GW8_PESOC) GWN_TOTPEC,
// 					SUM(GW8.GW8_QTDALT) GWN_TOTALT
// 			FROM %Table:GWN% GWN
// 			INNER JOIN %Table:GW1% GW1
// 			ON GW1.GW1_FILIAL = %xFilial:GW1%
// 			AND GW1.GW1_NRROM = GWN.GWN_NRROM
// 			AND GW1.%NotDel%
// 			INNER JOIN %Table:GW8% GW8
// 			ON GW8.GW8_FILIAL = %xFilial:GW8%
// 			AND GW8.GW8_CDTPDC = GW1.GW1_CDTPDC
// 			AND GW8.GW8_EMISDC = GW1.GW1_EMISDC
// 			AND GW8.GW8_SERDC = GW1.GW1_SERDC
// 			AND GW8.GW8_NRDC = GW1.GW1_NRDC
// 			AND GW8.%NotDel%
// 			WHERE GWN.GWN_FILIAL = %xFilial:GWN%
// 			AND GWN.GWN_NRROM = %Exp:cNrRom%
// 			AND GWN.%NotDel%
// 		EndSql
// 		TCSetField(cAliasQry,'GWN_TOTVOL','N',_aGWN_TOTVOL[1],_aGWN_TOTVOL[2])
// 		TCSetField(cAliasQry,'GWN_TOTPER','N',_aGWN_TOTPER[1],_aGWN_TOTPER[2])
// 		TCSetField(cAliasQry,'GWN_TOTPEC','N',_aGWN_TOTPEC[1],_aGWN_TOTPEC[2])
// 		TCSetField(cAliasQry,'GWN_TOTALT','N',_aGWN_TOTALT[1],_aGWN_TOTALT[2])
// 		If (cAliasQry)->(!Eof())
// 			_aTotais := (cAliasQry)->({GWN_TOTVOL,GWN_TOTPER,GWN_TOTPEC,GWN_TOTALT})
// 		EndIf
// 		(cAliasQry)->(dbCloseArea())
// 	EndIf

// 	_nFieldCont--

// 	RestArea(aAreaAnt)
// 	cFilAnt := cFilBkp
// Return _aTotais

// Static Function GFEA050CVT(cNrRom)
// 	Local aAreaAnt    := GetArea()
// 	Local nTotQtVol   := 0
// 	Local cAliasQry   := Nil
// 	Local aGWN_TQTVOL := TamSx3("GWN_TQTVOL")
// 	Local cFilBkp     := cFilAnt

// 	If !Empty(cNrRom)
// 		cFilAnt := GWN->GWN_FILIAL
// 		cAliasQry := GetNextAlias()
// 		BeginSql Alias cAliasQry
// 			SELECT SUM(GW1.GW1_QTVOL) GWN_TQTVOL
// 			FROM %Table:GWN% GWN
// 			INNER JOIN %Table:GW1% GW1
// 			ON GW1.GW1_FILIAL = %xFilial:GW1%
// 			AND GW1.GW1_NRROM = GWN.GWN_NRROM
// 			AND GW1.%NotDel%
// 			WHERE GWN.GWN_FILIAL = %xFilial:GW1%
// 			AND GWN.GWN_NRROM = %Exp:cNrRom%
// 			AND GWN.%NotDel%
// 		EndSql
// 		TCSetField(cAliasQry,'GWN_TQTVOL','N',aGWN_TQTVOL[1],aGWN_TQTVOL[2])
// 		If (cAliasQry)->(!Eof())
// 			nTotQtVol := (cAliasQry)->GWN_TQTVOL
// 		EndIf
// 		(cAliasQry)->(dbCloseArea())
// 	EndIf
// 	RestArea(aAreaAnt)
// 	cFilAnt := cFilBkp
// Return nTotQtVol
// /* alterado para commit */

// Static Function GFEA50REDP(nOpc)
// 	Local aAreaGW1 := GW1->(GetArea())
// 	Local aAreaGWU := GWU->(GetArea())

// 	If !Empty(SuperGetMv("MV_INTTMS",.F.,.F.)) .And. SuperGetMv("MV_INTTMS",.F.,.F.) .And. SuperGetMv("MV_TMSGFE",.F.,.F.)
// 		MsgAlert("Opção não disponível quando integração de Redespachos com SIGATMS está ativa")
// 		Return
// 	EndIf
// 	//Ponto de entrada validação Vicunha
// 	If ExistBlock("GFEA0506")
// 		If ExecBlock("GFEA0506",.F.,.F.,{"7"})
// 			Return
// 		EndIf
// 	EndIf

// 	//Realiza validações do romaneio e chama a view para executar inclusão ou alteração
// 	If nOpc == 1
// 		If GFE050VLRED(nOpc)
// 			FWExecView("Incluir","GFEA050C", MODEL_OPERATION_INSERT ,, { || .T. } ,, )
// 		EndIf
// 	ElseIf  nOpc == 2
// 		If GFE050VLRED(nOpc)
// 			FWExecView("Alterar","GFEA050D", MODEL_OPERATION_UPDATE ,, { || .T. } ,, )
// 		EndIf
// 	EndIf

// 	RestArea(aAreaGW1)
// 	RestArea(aAreaGWU)
// Return

// Static Function GFE050VLRED(nOpc)
// 	Local cAliasQry := ""
// 	Local cWhere    := Nil
// 	Local lRet      := .F.
// 	Local lEsp      := .T.

// 	GW1->(dbSetOrder(9)) //GW1_FILIAL+GW1_NRROM
// 	GWU->(dbSetOrder(1)) //GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC+GWU_SEQ
// 	GWH->(dbSetOrder(2)) //GWH_FILIAL+GWH_CDTPDC+GWH_EMISDC+GWH_SERDC+GWH_NRDC+GWH_NRCALC
// 	GXD->(dbSetOrder(2)) //GXD_FILCAL+GXD_NRCALC
// 	GXE->(dbSetOrder(1)) //GXE_FILIAL+GXE_CODLOT

// 	//Não permitir alterar romaneios encerrados
// 	If GWN->GWN_SIT == "4"
// 		Help( ,, 'HELP',, "O Romaneio está encerrado, portando não poderá ser alterado o Redespachante. ", 1, 0,)
// 		Return .F.
// 	EndIf

// 	If !Empty(GWN->GWN_VIAGEM)
// 		If PosicionaGWP()
// 			If GWP->GWP_SIT == '2'
// 				GFEMsgErro("Já ocorreu a partida da viagem " + GWP->GWP_VIAGEM + " que está relacionada, portanto não é possível alterar o Redespachante do Romaneio.")
// 				Return .F.
// 			EndIf
// 		Else
// 			Return .F.
// 		EndIf
// 	EndIf

// 	//Verica se há Trechos do Itinerário(GWU) do romaneio selecionado.
// 	If GW1->(dbSeek(xFilial('GW1')+GWN->GWN_NRROM))
// 		If GWU->(!dbSeek(xFilial('GWU')+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC))
// 			Help( ,, 'HELP',, "Não há trechos para manutenção. ", 1, 0,)
// 			Return .F.
// 		EndIf
// 	Else
// 		Help( ,, 'HELP',, "Não há documentos relacionados ao romaneio. ", 1, 0,)
// 		Return .F.
// 	EndIf

// 	If GFXCP1212210('GW1_FILROM')
// 		cWhere := "GW1.GW1_FILROM = '" + GWN->GWN_FILIAL + "'"
// 	Else
// 		cWhere := "GW1.GW1_FILIAL = '" + GWN->GWN_FILIAL + "'"
// 	EndIf
// 	cWhere := "%" + cWhere + "%"

// 	//Caso a opção escolhida foi "alterar", verifica se no romaneio possui documentos de carga com tipo de frete de redespacho
// 	If nOpc == 2
// 		cAliasQry := GetNextAlias()
// 		BeginSql Alias cAliasQry
// 			SELECT GW1.GW1_NRDC
// 			FROM %Table:GW1% GW1
// 			WHERE %Exp:cWhere%
// 			AND GW1.GW1_NRROM = %Exp:GWN->GWN_NRROM%
// 			AND GW1.GW1_TPFRET IN ('2','4','6')
// 			AND GW1.%NotDel%
// 		EndSql
// 		If (cAliasQry)->(Eof())
// 			Help( ,, 'HELP',, "No romaneio selecionado não existem documentos de carga que são do tipo CIF com Redespacho, FOB com Redespacho ou Consignado com Redespacho. ", 1, 0,)
// 			(cAliasQry)->(dbCloseArea())
// 			Return .F.
// 		EndIf
// 		(cAliasQry)->(dbCloseArea())
// 	EndIf

// 	cAliasQry := GetNextAlias()
// 	BeginSql Alias cAliasQry
// 		SELECT GW1.GW1_NRDC, GW1.GW1_TPFRET, GW1.GW1_CDTPDC, GW1.GW1_EMISDC, GW1.GW1_SERDC, GXE.GXE_SIT, GWF.GWF_ORIGEM
// 		FROM %Table:GW1% GW1
// 		LEFT JOIN %Table:GWH% GWH
// 		ON GWH.GWH_FILIAL = GW1.GW1_FILIAL
// 		AND GWH.GWH_CDTPDC = GW1.GW1_CDTPDC
// 		AND GWH.GWH_EMISDC = GW1.GW1_EMISDC
// 		AND GWH.GWH_SERDC = GW1.GW1_SERDC
// 		AND GWH.GWH_NRDC = GW1.GW1_NRDC
// 		AND GWH.%NotDel%
// 		LEFT JOIN %Table:GWF% GWF 
// 		ON GWF.GWF_FILIAL = GWH.GWH_FILIAL
// 		AND GWF.GWF_NRCALC = GWH_NRCALC
// 		AND GWF.%NotDel%
// 		LEFT JOIN %Table:GXD% GXD
// 		ON GXD.GXD_FILCAL = GWH.GWH_FILIAL
// 		AND GXD.GXD_NRCALC = GWH.GWH_NRCALC
// 		AND GXD.%NotDel%
// 		LEFT JOIN %Table:GXE% GXE
// 		ON GXE.GXE_FILIAL = GXD.GXD_FILIAL
// 		AND GXE.GXE_CODLOT = GXD.GXD_CODLOT
// 		AND GXE.%NotDel%
// 		WHERE %Exp:cWhere%
// 		AND GW1.GW1_NRROM = %Exp:GWN->GWN_NRROM%
// 		AND GW1.%NotDel%
// 	EndSql
// 	//Verifica se a origem de cálculos é válida
// 	Do While !lRet .And. (cAliasQry)->(!Eof())
// 		If Empty((cAliasQry)->GWF_ORIGEM) .Or. (cAliasQry)->GWF_ORIGEM $ "124"
// 			lRet := .T.
// 		EndIf
// 		(cAliasQry)->(dbSkip())
// 	EndDo

// 	If !lRet
// 		Help( ,, 'HELP',," O Romaneio possuí cálculos de origem 3=Apuracao Periodo,a alteração de Redespachantes não é permitida para cálculos com essa origem", 1, 0,)
// 		(cAliasQry)->(dbCloseArea())
// 		Return .F.
// 	EndIf

// 	//Ponto de entrada validação Camil
// 	If ExistBlock("GFEA0509")
// 		lEsp := ExecBlock("GFEA0509",.F.,.F.,{nOpc})
// 	EndIf
	
// 	//Caso o romaneio encontra-se liberado é necessário reabrir o romaneio por meio da decisão do usuário
// 	If GWN->GWN_SIT == "3"  .and. lEsp == .T.
// 		If MsgYesNo("Deseja reabrir o romaneio para incluir o trecho de redespacho?","Resdespachante")
// 			//Grava a data para reliberar o romaneio
// 			dData := GWN->GWN_DTSAI
// 			cHora := GWN->GWN_HRSAI
// 			If !GFEA050REA(.T.)
// 				(cAliasQry)->(dbCloseArea())
// 				Return .F.
// 			EndIf
// 		Else
// 			(cAliasQry)->(dbCloseArea())
// 			Return .F.
// 		EndIf
// 	EndIf
	
// 	If lEsp == .T.
// 		lRet := .F.
// 		(cAliasQry)->(dbGoTop())
// 		//Verifica se há cálculo de provisão vinculado
// 		Do While !lRet .And. (cAliasQry)->(!Eof())
// 			If Empty((cAliasQry)->GXE_SIT) .OR. !((cAliasQry)->GXE_SIT $ '2|3|4|5')
// 				lRet := .T.
// 			EndIf
// 			(cAliasQry)->(dbSkip())
// 		EndDo
// 		(cAliasQry)->(dbCloseArea())
	
// 		If !lRet
// 			Help( ,, 'HELP',, "Existem documentos do romaneio selecionado que possuem cálculo de provisão relacionado em um lote de provisão contábil já integrado. ", 1, 0,)
// 			Return .F.
// 		EndIf
// 	EndIf
// Return lRet

// Static Function GFE050PVIA()
// 	Local aArea      := GetArea()
// 	Local aAreaGWP   := GWP->(GetArea())
// 	Local lProssegue := .T.
	
// 	If GFXCP12116('GWP','GWP_VIAGEM')
// 		If Empty(GWN->GWN_VIAGEM)
// 			GfeMsgErro('Romaneio não está relacionado a uma viagem')
// 			lProssegue := .F.
// 		EndIf
	
// 		If lProssegue
// 			lProssegue := PosicionaGWP()
// 			If lProssegue
// 				GFEA58PVIA(,,,GWN->GWN_NRROM)
// 			EndIf
// 		EndIf
// 		RestArea(aAreaGWP)
// 		RestArea(aArea)
// 	Else
// 		Help(,,'HELP',,'Funcionalidade disponível a partir da versão 12.1.16.',1,0,)
// 	EndIf
// Return

// Static Function PosicionaGWP(lHelp,cMsg)
// 	Local lRet    := .T.
// 	Local aArea   := GetArea()
// 	Local cAlBkp  := Alias()

// 	Default lHelp := .T.
// 	Default cMsg  := ""

// 	GWP->(dbOrderNickName('VIAGEM'))
// 	If !GWP->(dbSeek(xFilial('GWP') + GWN->GWN_VIAGEM))
// 		cMsg := 'Viagem ' + GWN->GWN_VIAGEM + ' não localizada'
// 		If lHelp
// 			GfeMsgErro(cMsg)
// 		EndIf
// 		lRet := .F.
// 	EndIf
// 	RestArea(aArea)

// 	If cAlBkp != Nil .And. !Empty(cAlBkp)
// 		dbSelectArea(cAlBkp)
// 	EndIf
// Return lRet

// Static Function GFE50NVG()
// 	Local oMdlAct := FwModelActive()
// 	Local oVwAct  := FwViewActive()
// 	Local cRet    := ""
// 	Local cNrDc   := ""

// 	If Empty(FwFldGet("GWN_CDTRP"))
// 		GfeMsgErro("É necessário preencher o transportador antes de utilizar a ação")
// 		Return
// 	EndIf

// 	If oMdlAct:GetOperation() == MODEL_OPERATION_DELETE
// 		Return
// 	EndIf
// 	If oMdlAct:GetOperation() == MODEL_OPERATION_UPDATE
// 		If !GFEA058RVG(,@cNrDc)
// 			GfeMsgErro("Não é possível vincular romaneio que possui o documento " + AllTrim(cNrDc) + " com frete combinado/simulação com origem erp.")
// 			Return .F.
// 		EndIf
// 	EndIf

// 	cRet := GFEA058A(FwFldGet("GWN_NRROM"),FwFldGet("GWN_CDTRP"),FwFldGet("GWN_VIAGEM"))
// 	FwModelActive(oMdlAct)
// 	FwViewActive(oVwAct)

// 	If !Empty(cRet)
// 		oMdlAct:GetModel("GFEA050_GWN"):SetValue("GWN_VIAGEM",cRet)
// 		oMdlAct:lModify := .T.
// 	EndIf
// Return

// Static Function GFEA50CMT(oModel)
// 	Local lRet      := .T.
// 	Local cViagem   := ""
// 	Local cViagAnt  := ""
// 	Local nop       := oModel:GetOperation()
// 	Local oModelGWN := oModel:GetModel("GFEA050_GWN")
// 	Local aDados    := {}
// 	Local nX        := 0
// 	Local nF        := 0

// 	If oModelGWN:HasField("GWN_VIAGEM") 
// 		If nOp <> MODEL_OPERATION_INSERT
// 			cViagAnt := GWN->GWN_VIAGEM
// 		EndIf

// 		If nOp <> MODEL_OPERATION_DELETE
// 			cViagem := oModelGWN:GetValue('GWN_VIAGEM')
// 		EndIf

// 		lRet := FwFormCommit(oModel)

// 		If oModelGWN:HasField("GWN_CPESO")
// 			aAdd(aDados,{"GWN_CPESO",oModelGWN:GetValue("GWN_CPESO")})
// 		EndIf

// 		If oModelGWN:HasField("GWN_CVAL" )
// 			aAdd(aDados,{"GWN_CVAL",oModelGWN:GetValue("GWN_CVAL")})
// 		EndIf

// 		If oModelGWN:HasField("GWN_CVOL" )
// 			aAdd(aDados,{"GWN_CVOL",oModelGWN:GetValue("GWN_CVOL")})
// 		EndIf

// 		If oModelGWN:HasField("GWN_CQTDE")
// 			aAdd(aDados,{"GWN_CQTDE",oModelGWN:GetValue("GWN_CQTDE")})
// 		EndIf

// 		If !Empty(cViagem) .OR. !Empty(cViagAnt)
// 			GFE58ATVG(cViagem,GWN->GWN_CALC,GWN->GWN_MTCALC,GWN->GWN_DTCALC,GWN->GWN_HRCALC,GWN->GWN_FILIAL,GWN->GWN_NRROM,.T.,cViagAnt)
// 		EndIf

// 		If Len(aDados) > 0 .AND. nOp <> MODEL_OPERATION_DELETE
// 			RecLock('GWN',.F.)
// 			nF := Len(aDados)
// 			For nX := 1 To nF
// 				&("GWN->" + aDados[nX][1]) := aDados[nX][2]
// 			Next nX
// 			GWN->(MsUnlock())
// 		EndIf
// 	Else
// 		lRet := FwFormCommit(oModel)
// 	EndIf

// 	// Gravação de dados para relatorio de Movimentação de Carga
// 	/*If lRet .And. GFXTB1212210("GX0")
// 		LoadMovtoDoc(nOp)
// 	EndIf*/
// Return lRet

// Static Function GFE050COMB()
// 	Local oFWMVCWindow := Nil
// 	Local aCoors       := Nil
// 	Local lRet         := .T.
// 	Local oView        := FWLoadView('GFEA084')
// 	Local oModel       := FWLoadModel('GFEA084')

// 	GW1->( dbSetOrder(9) )
// 	If !GW1->(MsSeek(xFilial("GW1") + GWN->GWN_NRROM))
// 		MsgStop("Relacione documentos de carga antes de combinar um frete.","Atenção")
// 		Return .F.
// 	EndIf
	
// 	If !ValCalcLot()
// 		Help( ,, 'HELP',, 'Não é possível combinar frete. Romaneio possui cálculos vinculados a lote de provisão.', 1, 0)
// 		Return .F.
// 	EndIf

// 	aTrecho := GetTrecho()
// 	lRet 	:= !Empty(aTrecho)

// 	If lRet
// 		aCoors := FWGetDialogSize(oMainWnd)
// 		oModel:SetOperation(MODEL_OPERATION_INSERT)
// 		oModel:Activate()
// 		If AbreCadastro(oModel,aTrecho)
// 			oView:SetModel(oModel)
// 			oView:EnableControlBar(.T.)
// 			oView:SetOperation(MODEL_OPERATION_INSERT)
// 			oView:SetUseCursor(.F.)
// 			oView:SetCloseOnOk({|| .T.})

// 			oFWMVCWindow := FWMVCWindow():New()
// 			oFWMVCWindow:SetUseControlBar(.T.)
// 			oFWMVCWindow:SetView(oView)
// 			oFWMVCWindow:SetCentered(.T.)
// 			oFWMVCWindow:SetPos(aCoors[1],aCoors[2])
// 			oFWMVCWindow:SetSize(aCoors[3],aCoors[4])
// 			oFWMVCWindow:SetTitle("Frete Combinado")
// 			oFWMVCWindow:Activate(,,Nil,.F.)
// 		EndIf
// 		oModel:Deactivate()
// 		FreeObJ(oModel)
// 	Else
// 		Help( ,, 'HELP',, 'Verifique se existem trechos pagos e se o transportador permite frete combinado.', 1, 0)
// 	EndIf
// Return lRet

// Static Function AbreCadastro(oModel, aTrecho)
// 	Local oModelGWH := oModel:GetModel('GFEA084_GWH')
// 	Local aEntregas := GWNEntregas(,,aTrecho[2], aTrecho[1])
// 	Local nI        := 0
// 	Local nJ        := 0
// 	Local nF        := 0

// 	oModel:SetValue("GFEA084_GWF", "GWF_IDFRVI", "1")
// 	nF := Len(aEntregas)
// 	For nI := 1 To nF
// 		For nJ := 1 To Len(aEntregas[nI])
// 			If !Empty(oModelGWH:GetValue('GWH_NRDC'))
// 				oModelGWH:AddLine(.T.)
// 			EndIf

// 			oModelGWH:SetValue('GWH_FILIAL',	aEntregas[nI][nJ][NPOSFILIAL])
// 			oModelGWH:SetValue('GWH_NRDC', 		aEntregas[nI][nJ][NPOSNRDC])
// 			oModelGWH:SetValue('GWH_CDTPDC', 	aEntregas[nI][nJ][NPOSTPDC])
// 			oModelGWH:SetValue('GWH_EMISDC', 	aEntregas[nI][nJ][NPOSEMIS])
// 			oModelGWH:SetValue('GWH_SERDC',		aEntregas[nI][nJ][NPOSSERDC])
// 			oModelGWH:SetValue('GWH_TRECHO',	aEntregas[nI][nJ][NPOSSEQ])
// 			If oModelGWH:VldLinedata() != .T.
// 				oModelGWH:DeleteLine()
// 			EndIf
// 		Next nJ
// 	Next nI
// Return .T.

// // Ref Ao retorno da função GWNEntregas
// Static NPOSFILIAL := 1
// Static NPOSTPDC   := 2
// Static NPOSEMIS   := 3
// Static NPOSSERDC  := 4
// Static NPOSNRDC   := 5
// Static NPOSCDTRP  := 6
// Static NPOSSEQ    := 7
// Static NPOSCDREM  := 8
// Static NPOSCDDEST := 9
// Static NPOSENTNRC := 10
// Static NPOSENTBAI := 11
// Static NPOSENTEND := 12
// Static NPOSORIGEM := 13
// Static NPOSDESTIN := 14

// Static Function GF50AGRENT(aDocCarga, cCdTrp, cTrecho)
// 	Local aEntregas := {}
// 	Local nF        := 0
// 	Local nI        := 0
// 	Local nJ        := 0
// 	Local nCount    := 0
// 	Local nEntAgrup := 0
// 	Local aInfoEnt  := {}
// 	Local nMaxDoc   := 0
// 	Local cOrigem   := ""
// 	Local cDestin   := ""
// 	Local areaGWN := GWN->(GetArea())
	
// 	GWN->(dbSetOrder(1))
// 	nF := Len(aDocCarga)
// 	For nCount := 1 To nF
// 		GW1->(dbSetOrder(1))
// 		If GW1->(dbSeek( aDocCarga[nCount][NPOSFILIAL] + aDocCarga[nCount][NPOSTPDC] + aDocCarga[nCount][NPOSEMIS] + aDocCarga[nCount][NPOSSERDC] + aDocCarga[nCount][NPOSNRDC] ))
// 			GWU->(dbSetOrder(1))
// 			If GWU->(dbSeek( GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC ))
// 				Do While GWU->(!Eof()) ;
// 					.And. GWU->GWU_FILIAL == GW1->GW1_FILIAL ;
// 					.And. GWU->GWU_CDTPDC == GW1->GW1_CDTPDC ;
// 					.And. GWU->GWU_EMISDC == GW1->GW1_EMISDC ;
// 					.And. GWU->GWU_SERDC == GW1->GW1_SERDC ;
// 					.And. GWU->GWU_NRDC == GW1->GW1_NRDC

// 					If GWU->GWU_SEQ == '01'
// 						If GFXCP12117("GWU_NRCIDO") .And. !Empty(GWU->GWU_NRCIDO)
// 							cOrigem := GWU->GWU_NRCIDO
// 						Else
// 							GWN->(msSeek(xFilial("GWN") + GW1->GW1_NRROM))
// 							If !Empty(GWN->GWN_NRCIDO)
// 								cOrigem := GWN->GWN_NRCIDO
// 							Else
// 								cOrigem := Posicione("GU3",1,xFilial("GU3")+GW1->GW1_CDREM,"GU3_NRCID")
// 							EndIf
// 						EndIf
// 					Else
// 						If GFXCP12117("GWU_NRCIDO") .And. !Empty(GWU->GWU_NRCIDO)
// 							cOrigem := GWU->GWU_NRCIDO
// 						Else
// 							cOrigem := If(Empty(cDestin) , Posicione("GU3",1,xFilial("GU3")+GWU->GWU_CDTRP,"GU3_NRCID") , cDestin)
// 						EndIf
// 					EndIf
					
// 					cDestin := GWU->GWU_NRCIDD
					
// 					GWU->(dbSkip())
					
// 					If GWU->(!Eof()) ;
// 						.And. GWU->GWU_FILIAL == GW1->GW1_FILIAL ;
// 						.And. GWU->GWU_CDTPDC == GW1->GW1_CDTPDC ;
// 						.And. GWU->GWU_EMISDC == GW1->GW1_EMISDC ;
// 						.And. GWU->GWU_SERDC  == GW1->GW1_SERDC ;
// 						.And. GWU->GWU_NRDC   == GW1->GW1_NRDC
						
// 						//Se houver destino informado no trecho assume a cidade destino informado, caso contrario assume a cidade do
// 						//transportador do trecho seguinte, exceto o ultimo trecho, que tem outro tratamento
// 						if Empty(cDestin)
// 							cDestin := Posicione("GU3",1,xFilial("GU3")+GWU->GWU_CDTRP,"GU3_NRCID")
// 						EndIf
// 						GWU->(dbSkip(-1))
// 					Else
// 						GWU->(dbSkip(-1))
// 						GWN->(msSeek(xFilial("GWN") + GW1->GW1_NRROM))
// 						If !Empty(GWN->GWN_NRCIDD)
// 							cDestin := GWN->GWN_NRCIDD
// 						Else
// 							If !Empty(GW1->GW1_ENTNRC) .AND. GW1->GW1_ENTNRC != PADR("0",50)
// 								cDestin := GW1->GW1_ENTNRC
// 							Else
// 								cDestin := GWU->GWU_NRCIDD
// 							EndIf
// 						EndIf
// 					EndIf
					
// 					If GWU->GWU_PAGAR == "1" .And. (Empty(cCdTrp) .Or. GWU->GWU_CDTRP == cCdTrp) .And. (Empty(cTrecho) .Or. GWU->GWU_SEQ == cTrecho)						
// 						aInfoEnt   := { GWU->GWU_FILIAL,;
// 										GWU->GWU_CDTPDC,;
// 										GWU->GWU_EMISDC,;
// 										GWU->GWU_SERDC,;
// 										GWU->GWU_NRDC,;
// 										GWU->GWU_CDTRP,;
// 										GWU->GWU_SEQ,;
// 										GW1->GW1_CDREM,;
// 										GW1->GW1_CDDEST,;
// 										GW1->GW1_ENTNRC,;
// 										GW1->GW1_ENTBAI,;
// 										GW1->GW1_ENTEND,;
// 										cOrigem,;
// 										cDestin}

// 						nMaxDoc := Posicione("GU3", 1, xFilial("GU3")+GWU->GWU_CDTRP, "GU3_MAXDOC")

// 						If Len(aEntregas) == 0
// 							aAdd(aEntregas, {aInfoEnt})
// 						Else
// 							nEntAgrup := 0

// 							For nI := 1 To Len(aEntregas)
// 								For nJ := 1 To Len(aEntregas[nI])
// 									// Agrupar na mesma entrega
// 									If aEntregas[nI][nJ][NPOSCDTRP]  == GWU->GWU_CDTRP .AND. ;
// 									aEntregas[nI][nJ][NPOSCDREM]  == GW1->GW1_CDREM .AND. ;
// 									aEntregas[nI][nJ][NPOSCDDEST] == GW1->GW1_CDDEST .AND. ;
// 									aEntregas[nI][nJ][NPOSENTNRC] == GW1->GW1_ENTNRC .And. ;
// 									aEntregas[nI][nJ][NPOSENTBAI] == GW1->GW1_ENTBAI .And. ;
// 									aEntregas[nI][nJ][NPOSENTEND] == GW1->GW1_ENTEND .AND. ;
// 									aEntregas[nI][nJ][NPOSORIGEM] == cOrigem .And. ;
// 									aEntregas[nI][nJ][NPOSDESTIN] == cDestin .AND. ;
// 									nMaxDoc > 1 .AND. Len(aEntregas[nI]) < nMaxDoc

// 										nEntAgrup := nI

// 									EndIf
// 								Next nJ
// 							Next nI

// 							If nEntAgrup > 0
// 								aAdd(aEntregas[nEntAgrup], aInfoEnt)
// 							Else
// 								aAdd(aEntregas, {aInfoEnt})
// 							EndIf
// 						EndIf
// 					EndIf

// 					GWU->(dbSkip())
// 				EndDo
// 			EndIf
// 		EndIf
// 	Next nCount
// 	RestArea(areaGWN)
// Return aEntregas

// Static Function GWNEntregas(cFilRom, cNrRom, cCdTrp, cTrecho)
// 	Local aEntregas  := {}
// 	Local aDocCarga  := {}
// 	Local aArea      := {}
// 	Local cAliasGW1  := Nil
// 	Local cWhere     := Nil

// 	Default cFilRom  := GWN->GWN_FILIAL
// 	Default cNrRom   := GWN->GWN_NRROM
// 	Default cCdTrp   := ""
// 	Default cTrecho  := ""

// 	aArea := GWN->(GetArea())
// 	GWN->(dbSetOrder(1))
// 	If GWN->(dbSeek(cFilRom + cNrRom))
// 		If GFXCP1212210('GW1_FILROM')
// 			cWhere := "GW1.GW1_FILROM = '" + GWN->GWN_FILIAL + "'"
// 		Else
// 			cWhere := "GW1.GW1_FILIAL = '" + GWN->GWN_FILIAL + "'"
// 		EndIf
// 		cWhere := "%" + cWhere + "%"

// 		cAliasGW1 := GetNextAlias()
// 		BeginSql Alias cAliasGW1
// 			SELECT GW1_FILIAL, GW1_CDTPDC, GW1_EMISDC, GW1_SERDC, GW1_NRDC, GW1.R_E_C_N_O_ AS GW1RECNO
// 			FROM %table:GW1% GW1
// 			WHERE %Exp:cWhere%
// 			AND GW1.GW1_NRROM  = %Exp:GWN->GWN_NRROM%
// 			AND GW1.%NotDel%
// 			ORDER BY GW1.GW1_FILIAL,GW1.GW1_NRDC
// 		EndSql
// 		While !(cAliasGW1)->(Eof())
// 			aAdd(aDocCarga, {(cAliasGW1)->GW1_FILIAL, (cAliasGW1)->GW1_CDTPDC, (cAliasGW1)->GW1_EMISDC, (cAliasGW1)->GW1_SERDC, (cAliasGW1)->GW1_NRDC})

// 			(cAliasGW1)->(dbSkip())
// 		EndDo	
// 		(cAliasGW1)->(dbCloseArea())
// 	EndIf
// 	RestArea(aArea)
// 	aEntregas := GF50AGRENT(aDocCarga, cCdTrp, cTrecho)
// Return aEntregas

// Static Function GFE050DESC()
// 	Local aCalc     := {}
// 	Local cAliasGW1 := Nil
// 	Local cWhere    := Nil
// 	Local oRetValid := GFEXFBB():New()
	
// 	If msgyesno("Deseja excluir todos os cálculos do tipo combinado vinculado a este romaneio?")
// 		GWF->(dbSetOrder(4))
// 		If !GWF->(dbSeek(xFilial("GWF") + GWN->GWN_NRROM) )
// 			MsgInfo('Não há calculo relacionado ao romaneio', 'Frete Combinado')
// 			Return
// 		EndIf
		
// 		Do While GWF->(!Eof()) .And. GWF->GWF_FILIAL == xFilial("GWF") .And. GWF->GWF_NRROM == GWN->GWN_NRROM
// 			//Valida se o cálculo pode ser deletado.
// 			oRetValid:SetNrCalc(GWF->GWF_NRCALC)
// 			oRetValid:SetOrigem(GWF->GWF_ORIGEM)
// 			oRetValid:Validar()
// 			If(!oRetValid:getStatus())
// 				MsgInfo(oRetValid:getMensagem())
// 				oRetValid:Destroy()
// 				Return
// 			EndIf
		
// 			aAdd(aCalc,GWF->GWF_NRCALC)
// 			GWF->(dbSkip())
// 		EndDo
	
// 		GFEDelCalc(,,.T.,aCalc)		
		
// 		GWN->(dbSetOrder(1))
// 		If GWN->(dbSeek(xFilial("GWN") + GWN->GWN_NRROM))
// 			RecLock("GWN", .F.)
// 				GWN->GWN_CALC   := "4"
// 				GWN->GWN_MTCALC := ""
// 				GWN->GWN_DTCALC := CToD("  /  /    ")
// 				GWN->GWN_HRCALC := ""
// 				If GWN->GWN_AGRUP == "1"
// 					GWN->GWN_AGRUP := "2"
// 				EndIf
// 			GWN->(MsUnLock())
// 		EndIf


// 		If GFXCP1212210('GW1_FILROM')
// 			cWhere := "GW1.GW1_FILROM = '" + GWN->GWN_FILIAL + "'"
// 		Else
// 			cWhere := "GW1.GW1_FILIAL = '" + GWN->GWN_FILIAL + "'"
// 		EndIf
// 		cWhere := "%" + cWhere + "%"

// 		cAliasGW1 := GetNextAlias()
// 		BeginSql Alias cAliasGW1
// 			SELECT GW1_FILIAL, GW1_CDTPDC, GW1_EMISDC, GW1_SERDC, GW1_NRDC, GW1.R_E_C_N_O_ AS GW1RECNO
// 			FROM %table:GW1% GW1
// 			WHERE %Exp:cWhere%
// 			AND GW1.GW1_NRROM  = %Exp:GWN->GWN_NRROM%
// 			AND GW1.%NotDel%
// 			ORDER BY GW1.GW1_FILIAL,GW1.GW1_NRDC
// 		EndSql
// 		While !(cAliasGW1)->(Eof())
// 			GWU->(dbSetOrder(4))
// 			If GWU->(dbSeek((cAliasGW1)->GW1_FILIAL + (cAliasGW1)->GW1_NRDC))
// 				Do While GWU->(!Eof()) .And. (GWU->GWU_FILIAL + GWU->GWU_CDTPDC + GWU->GWU_EMISDC + GWU->GWU_SERDC + GWU->GWU_NRDC == (cAliasGW1)->GW1_FILIAL + (cAliasGW1)->GW1_CDTPDC + (cAliasGW1)->GW1_EMISDC + (cAliasGW1)->GW1_SERDC + (cAliasGW1)->GW1_NRDC)
// 					RecLock("GWU",.F.)
// 						GWU->GWU_DTPENT := CToD("  /  /    ")
// 						GWU->GWU_HRPENT	:= ""
// 					GWU->(MsUnLock())
// 					GWU->(dbSkip())
// 				EndDo
// 			EndIf

// 			(cAliasGW1)->(dbSkip())
// 		EndDo	
// 		(cAliasGW1)->(dbCloseArea())
// 	EndIf
// 	oRetValid:Destroy()
// Return

// Static Function GetTrecho()
// 	Local aRet      := {}
// 	Local aRet2     := {}
// 	Local cAliasTmp := Nil
// 	Local cWhere    := Nil

// 	If GFXCP1212210('GW1_FILROM')
// 		cWhere := "GW1.GW1_FILROM = '" + GWN->GWN_FILIAL + "'"
// 	Else
// 		cWhere := "GW1.GW1_FILIAL = '" + GWN->GWN_FILIAL + "'"
// 	EndIf
// 	cWhere := "%" + cWhere + "%"

// 	// GW1	Documentos de Carga
// 	// GWU	Trechos do Itinerario
// 	// GU3	Emitentes
// 	cAliasTmp := GetNextAlias()
// 	BeginSql Alias cAliasTmp
// 		SELECT DISTINCT GWU.GWU_SEQ, GWU.GWU_CDTRP, GU3.GU3_NMEMIT
// 		FROM %Table:GW1% GW1
// 		INNER JOIN %Table:GWU% GWU
// 		ON GWU.GWU_FILIAL = GW1.GW1_FILIAL
// 		AND GWU.GWU_EMISDC = GW1.GW1_EMISDC
// 		AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC
// 		AND GWU.GWU_SERDC = GW1.GW1_SERDC
// 		AND GWU.GWU_NRDC = GW1.GW1_NRDC
// 		AND GWU.GWU_PAGAR  = '1'
// 		AND GWU.%NotDel%
// 		INNER JOIN %Table:GU3% GU3
// 		ON GU3.GU3_CDEMIT = GWU.GWU_CDTRP
// 		AND GU3.GU3_FRCOMB = '1'
// 		AND GU3.%NotDel%
// 		WHERE %Exp:cWhere%
// 		AND GW1.GW1_NRROM = %Exp:GWN->GWN_NRROM%
// 		AND GW1.%NotDel%
// 		ORDER BY GWU.GWU_SEQ, GWU.GWU_CDTRP
// 	EndSql
// 	Do While (cAliasTmp)->(!Eof())
// 		aAdd(aRet, {((cAliasTmp)->GWU_SEQ == "01"), (cAliasTmp)->GWU_SEQ, (cAliasTmp)->GWU_CDTRP, (cAliasTmp)->GU3_NMEMIT})
// 		(cAliasTmp)->(dbSkip())
// 	EndDo
// 	(cAliasTmp)->(dbCloseArea())

// 	If Len(aRet) > 1
// 		aRet2 := TelaTrecho(aRet)
// 	Else 
// 		if Len(aRet) > 0
// 			aDel(aRet[1],1)
// 			aSize(aRet[1], Len(aRet[1])-1)
// 			aRet2 := aRet[1]
// 		EndIf
// 	EndIf
// Return aRet2

// Static Function TelaTrecho(aTrechos)
// 	Local oDlgTrc   := Nil
// 	Local oBrowse   := Nil
// 	Local nAlt      := 300
// 	Local nLrg      := 490
// 	Local aTrecho   := {}
// 	Local oOK       := LoadBitmap(GetResources(),"LBOK")
// 	Local oNO       := LoadBitmap(GetResources(),"LBNO")
// 	Local aColsName := {"","Trecho","Transp","Nome Transportador"}
// 	Local aColsSize := {20,25,60,70}
// 	Local bConfirm  := Nil
// 	Local bCancel   := Nil

// 	Private aRetTrecho := aTrechos

// 	//--------------------------
// 	// Montagem da tela
// 	//--------------------------
// 	Define MsDialog oDlgTrc Title "Selecionar Trecho" From 00,00 To nAlt,nLrg Of oMainWnd Color CLR_BLACK,RGB(225,225,225) Pixel
// 	oDlgTrc:lEscClose := .F.

// 	oBrowse := TWBrowse():New(0,0,248,120,,aColsName,aColsSize,oDlgTrc,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
// 	oBrowse:SetArray( aTrechos )
// 	oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
// 	oBrowse:bLine := {|| { If(aRetTrecho[oBrowse:nAt,01],oOK,oNO),aRetTrecho[oBrowse:nAt,02], aRetTrecho[oBrowse:nAt,03],aRetTrecho[oBrowse:nAt,04] } }
// 	// Troca a imagem no duplo click do mouse
// 	oBrowse:bLDblClick := {|| DlgTrcDblClick(aRetTrecho, oBrowse) }

// 	bConfirm	:= {|| IIf( VerTlTre(aRetTrecho) , (aTrecho := aRetTrecho[oBrowse:nAt], aDel(aTrecho,1), aSize(aTrecho, Len(aTrecho)-1), oDlgTrc:End() ), .F. ) }
// 	bCancel	:= {|| oDlgTrc:End() }
// 	ACTIVATE MSDIALOG oDlgTrc ON INIT EnchoiceBar(oDlgTrc, bConfirm, bCancel,, ) CENTERED
// Return aTrecho

// Static Function DlgTrcDblClick(aRetTrecho, oBrowse)
// 	Local nX         := 0
// 	Local nF         := 0
// 	Local nPosMarcar := oBrowse:nAt
// 	nF := Len(aRetTrecho)
// 	For nX := 1 To nF
// 		aRetTrecho[nX][1] := nX == nPosMarcar
// 	Next nX
// 	oBrowse:Refresh()
// Return

// Static Function VerTlTre(aRetTrecho)
// 	Local lRet := .T.
// 	Local nInd := 0
// 	Local nX   := 0
// 	Local nF   := 0

// 	nF := Len(aRetTrecho)
// 	For nX := 1 To nF
// 		If aRetTrecho[nX][1] == .T.
// 			nInd += 1
// 		EndIf
// 	Next nX
	
// 	If nInd == 0
// 		MsgInfo('É necessário selecionar um Trecho!', 'Frete Combinado')
// 		lRet := .F.
// 	EndIf

// 	If nInd > 1
// 		MsgInfo('Selecione somente um Trecho!', 'Frete Combinado')
// 		lRet := .F.
// 	EndIf
// Return lRet

// Static Function TrocouCrgComp(oModelGwn)
// 	Local lRet1 := .F.
// 	Local lRet2 := .F.
// 	Local lRet3 := .F.
// 	Local lRet4 := .F.
// 	Local lRet5 := .F.

// 	If oModelGwn:HasField('GWN_VIAGEM')
// 		lRet1 := GWN->GWN_VIAGEM <> FwFldGet( 'GWN_VIAGEM')
// 	EndIf

// 	If oModelGwn:HasField('GWN_CPESO')
// 		lRet2 := GWN->GWN_CPESO <> FwFldGet( 'GWN_CPESO')
// 	EndIf

// 	If oModelGwn:HasField('GWN_CVAL')
// 		lRet3 := GWN->GWN_CVAL <> FwFldGet( 'GWN_CVAL')
// 	EndIf

// 	If oModelGwn:HasField('GWN_CVOL')
// 		lRet4 := GWN->GWN_CVOL <> FwFldGet( 'GWN_CVOL')
// 	EndIf

// 	If oModelGwn:HasField('GWN_CQTDE')
// 		lRet5 := GWN->GWN_CQTDE <> FwFldGet( 'GWN_CQTDE')
// 	EndIf
// Return lRet1 .Or. lRet2 .Or. lRet3 .Or. lRet4 .Or. lRet5

// Static Function GFE050PMAI()
	
// 	If GFXCP12117("GU2_RECNFE") == .T.
// 		Processa({|| GFE050MAIL(.T.)},'Enviando e-mail aos destinatários do romaneio ' + GWN->GWN_NRROM)
// 	Else
// 		Help(,,'HELP',,'Funcionalidade disponível a partir da versão 12.1.17.',1,0,)
// 	EndIf
// Return 

// Static Function GFE050MAIL(lMenu)
// 	Local aOldArea 	 := GetArea()
// 	Local cTit 		 := "Envio de arquivo XML NFe"
// 	Local aFileEmail := {}
// 	Local aFiles     := {}
// 	Local nF         := 0
// 	Local nI         := 0
// 	Local nJ         := 0
// 	Local nScan      := 0
// 	Local nScan2     := 0
// 	Local cMV_NFEDIR := GetNewPar("MV_NFEDIR","")
// 	Local cEnvXMLNFE := GetNewPar("MV_NFEENV","1")
// 	Local cMailTxtOr := "Anexo os arquivos XML das notas fiscais referente ao Embarque [" + AllTrim(GWN->GWN_FILIAL) + " / " + GWN->GWN_NRROM + "]."
// 	Local cMailTxtAu := ''
// 	Local cMailNtFis := ''
// 	Local cDocGW1 	 := ''
// 	Local cBARRAS 	 := "", cNovoArq := "", cMsgErro := ""
// 	Local lTemContat := .F.
// 	Local lRet 		 := .T.
// 	Local lExisDoc 	 := .F.
// 	Local aContatos  := {}
// 	Local nDocRom 	 := 0
// 	Local lEnvEdi    := .T.
// 	Local lIsBlind := IsBlind()

// 	If lIsBlind
// 		lMenu := .F.
// 	EndIf
	
// 	If lMenu
// 		If cEnvXMLNFE == '1'
// 			cMsgErro := "Para enviar os arquivos XML para os transportadores, verifique o parâmetro 'Envio XML NFe'."
// 			If !lIsBlind .And. lMenu
// 				GFEMsgErro(cMsgErro)
// 			EndIf
// 			lRet := .F.
// 		EndIf
// 	Else
// 		If cEnvXMLNFE <> '2' //Automática
// 	       Return .F.
// 		EndIf
// 	EndIf
	
// 	If lRet
// 		If Empty(cMV_NFEDIR)
// 			cMsgErro := "Não foi possível realizar o envio dos arquivos de NFe. 'Diretório XML NFe' deve ser informado nos Parâmetros do Módulo."
// 			If !lIsBlind .And. lMenu
// 				GFEMsgErro(cMsgErro)
// 			EndIf
// 			lRet := .F.
// 		Else
// 			If !ExistDir(cMV_NFEDIR)
// 				cMsgErro := "Não foi possível realizar o envio dos arquivos de NFe. Diretório XML NFe não encontrado."
// 				If !lIsBlind .And. lMenu
// 					GFEMsgErro(cMsgErro)
// 				EndIf
// 				lRet := .F.
// 			EndIf
// 		EndIf

// 		If lRet
// 			If Right(AllTrim(cMV_NFEDIR),1) != "\"
// 			cMV_NFEDIR := AllTrim(cMV_NFEDIR) + "\"
// 			EndIf
			
// 			// Varre o diretório e procura pelas páginas gravadas.
// 			aFiles := Directory( cMV_NFEDIR + "*.xml" )

// 			GW1->(dbSetOrder(9))
// 			If GW1->(dbSeek(xFilial("GW1")+GWN->GWN_NRROM)) //GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC
// 				Do While GW1->(!Eof()) .And. GW1->GW1_FILIAL == xFilial("GW1") .And. GW1->GW1_NRROM == GWN->GWN_NRROM
// 					nDocRom := nDocRom +1
// 					GV5->(dbSetOrder(1))
// 					If GV5->(dbSeek(xFilial("GV5")+GW1->GW1_CDTPDC)) .And. GV5->GV5_EDI == '1'
// 						// Monta um Vetor com o path e nome do arquivo em cada linha para passar via email
// 						nF := Len(aFiles)
// 						For nI:= 1 To nF
// 							lExisDoc := .F.
// 							cMailNtFis := ''
// 							If AllTrim(GW1->GW1_DANFE) $ aFiles[nI][1]
// 								lExisDoc := .T.
// 							Else
// 								GXP->(dbSetOrder(1))
// 								If GXP->(dbSeek(xFilial("GXP")+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC))
// 									Do While GXP->(!Eof()) ;
// 										.And. GXP->GXP_FILIAL == xFilial("GXP") ;
// 										.And. GXP->GXP_CDTPDC == GW1->GW1_CDTPDC ;
// 										.And. GXP->GXP_EMISDC == GW1->GW1_EMISDC ;
// 										.And. GXP->GXP_SERDC == GW1->GW1_SERDC ;
// 										.And. GXP->GXP_NRDC == GW1->GW1_NRDC

// 										If AllTrim(GXP->GXP_DANFE) $ aFiles[nI][1]
// 											lExisDoc := .T.
// 											nDocRom := nDocRom +1
// 											cMailNtFis := " [" + AllTrim(GXP->GXP_SERORI) +" / " + AllTrim(GXP->GXP_DOCORI) +"]"
// 											Exit
// 										EndIf
// 										GXP->(dbSkip())	
// 									EndDo
// 								EndIf
// 							EndIf
// 							aContatos := {} 

// 							//Buscando os contatos - Inicio
// 							aAdd(aContatos,{GW1->GW1_EMISDC})
// 							GWU->(dbSetOrder(4))
// 							If GWU->(dbSeek(xFilial("GWU")+GW1->GW1_NRDC))
// 								Do While GWU->(!Eof()) .And. GWU->GWU_FILIAL+GWU->GWU_NRDC == xFilial("GWU")+GW1->GW1_NRDC
// 									nScan := aScan(aContatos,{|x| x[1] == GWU->GWU_CDTRP})
// 									If nScan == 0
// 										If GWU->GWU_PAGAR == '1'
// 											aAdd(aContatos,{GWU->GWU_CDTRP})
// 										EndIf
// 									EndIf
// 									GWU->(dbSkip())
// 								EndDo
// 							EndIf
// 							//Buscando os contatos - Fim
// 							nF := Len(aContatos)
// 							For nJ := 1 To nF
// 								GU2->(dbSetOrder(1))
// 								If GU2->(dbSeek(xFilial("GU2")+aContatos[nJ][1]))
// 									Do While GU2->(!Eof()) .And. GU2->GU2_FILIAL == xFilial("GU2") .And. GU2->GU2_CDEMIT == aContatos[nJ][1]
// 										If GU2->GU2_RECNFE == '1' .And. GU2->GU2_SIT == '1'
// 											nScan := aScan(aFileEmail,{|x| x[1] == GU2->GU2_EMAIL})
// 											If nScan == 0
// 												If Empty(GW1->GW1_DANFE)
// 													cDocGW1 := ""
// 												Else
// 													cDocGW1	:= "[ " + AllTrim(GW1->GW1_SERDC) +" / " + AllTrim(GW1->GW1_NRDC) + "]"
// 												EndIf
// 												cMailTxtAu := cMailTxtOr + Char(13) + Chr(10) +;
// 												"Notas Fiscais: " + cDocGW1
// 												cMailTxtAu := cMailTxtAu + cMailNtFis 
// 												If lExisDoc
// 													AADD(aFileEmail,{GU2->GU2_EMAIL, {aFiles[nI][1]}, cMailTxtAu,{}})
// 												Else
// 													AADD(aFileEmail,{GU2->GU2_EMAIL, {}, cMailTxtAu,{}})
// 												EndIf
// 											Else
// 												If lExisDoc
// 													nScan2 := aScan(aFileEmail[nScan][2], {|x| x == aFiles[nI][1] } )
// 													If nScan2 == 0
// 														AADD(aFileEmail[nScan][2],aFiles[nI][1])
// 														lTemContat := .T.
// 													EndIf
// 												EndIf

// 												If At(AllTrim(GW1->GW1_SERDC) +" / " + AllTrim(GW1->GW1_NRDC),aFileEmail[nScan][3]) == 0 .And.;
// 													!Empty(GW1->GW1_DANFE)
// 													cMailTxtAu := aFileEmail[nScan][3] + " ; [" + AllTrim(GW1->GW1_SERDC) +" / " + AllTrim(GW1->GW1_NRDC) +"]"
// 													aFileEmail[nScan][3] := cMailTxtAu
// 												EndIf
												
// 												If !Empty(cMailNtFis) .And.;
// 													At(AllTrim(GXP->GXP_SERORI) +" / " + AllTrim(GXP->GXP_DOCORI),aFileEmail[nScan][3]) == 0 .And.;
// 													!Empty(GXP->GXP_DANFE) 
// 													cMailTxtAu := cMailTxtAu + cMailNtFis 
// 													aFileEmail[nScan][3] := cMailTxtAu
// 												EndIf
// 											EndIf
// 										EndIf
// 										GU2->(dbSkip())
// 									EndDo
// 								EndIf
// 							Next nJ
// 						Next nI
// 					EndIf
// 					If GV5->GV5_EDI == '2'
// 						lEnvEdi := .F.
// 						Exit
// 					EndIf
// 					GW1->(dbSkip())
// 				EndDo
// 			EndIf

// 			If Len(aFileEmail) > 0
// 				cBARRAS := If(isSRVunix(),"/","\")
// 				cRootPath := Alltrim(GetSrvProfString("RootPath",cBARRAS))
// 				If Right(AllTrim(cRootPath),1) != cBARRAS
// 					cRootPath := AllTrim(cRootPath) + cBARRAS
// 				EndIf
// 				If !ExistDir(cRootPath+"XMLGFE")
// 					MakeDir(cRootPath+"XMLGFE")
// 				EndIf
			
// 				If !lIsBlind
// 					ProcRegua(Len(aFileEmail))
// 				Endif
// 				nF := Len(aFileEmail)
// 				For nI := 1 To nF //Copia os arquvios a serem enviados por email para o Rootpath, pois a função GFEEnvMail está preparada para tal.
// 					If !lIsBlind
// 						IncProc("Enviando...")
// 					EndIf
// 					If !Empty(aFileEmail[nI][1])
// 						For nJ := 1 to Len(aFileEmail[nI][2])
// 							cNovoArq := cBARRAS+'XMLGFE'+cBARRAS+aFileEmail[nI][2][nJ]
// 							__copyfile(cMV_NFEDIR+aFileEmail[nI][2][nJ],cNovoArq)
// 							aFileEmail[nI][2][nJ] := cNovoArq
// 						Next nJ
						
// 						If Len(aFileEmail[nI][2]) <= nDocRom .AND. Len(aFileEmail[nI][2]) != 0
// 							//Zipando os XMLs
// 							tarCompress( aFileEmail[nI][2], "\xmlgfe\xml.tar" )
// 							GzCompress( "\xmlgfe\xml.tar", "\xmlgfe\xml.tar.gz" )
// 							AADD(aFileEmail[nI][4],"\xmlgfe\xml.tar.gz")
// 							If SubStr(aFileEmail[nI][3],Len(aFileEmail[nI][3]),1) == ";"
// 								aFileEmail[nI][3] := SubStr(aFileEmail[nI][3],1,Len(aFileEmail[nI][3])-1)
// 							Endif
// 							aRet := GFEMail(aFileEmail[nI][1], cTit, aFileEmail[nI][3], .F., aFileEmail[nI][4])
// 							If !aRet[1]
// 								cMsgErro := aRet[2]
// 								GFEMsgErro(cMsgErro)
// 								lRet := .F.
// 							EndIf
		
// 							//Deleta os arquivos do diretório temporário - Inicio
// 							For nJ := 1 to Len(aFileEmail[nI][2])
// 								FErase(aFileEmail[nI][2][nJ])
// 							Next nJ
// 							FErase("\xmlgfe\xml.tar")
// 							FErase("\xmlgfe\xml.tar.gz")
// 							//Deleta os arquivos do diretório temporário - Fim
// 						Else
// 							cMsgErro := "Não foi possível realizar o envio dos arquivos de NFe. Um ou mais arquivos não foram localizados no diretório informado."
// 							If !lIsBlind .And. lMenu
// 								GFEMsgErro(cMsgErro)
// 							EndIf
// 							lRet := .F.
// 						EndIf
// 					EndIf
// 				Next nI
// 			Else
// 				If !lEnvEdi 
// 				cMsgErro := "Não foi possível realizar o envio dos arquivos de NFe.Verifique se o tipo de documento de carga está marcado para Envia EDI/NFe."
// 					If !lIsBlind .And. lMenu
// 						GFEMsgErro(cMsgErro)
// 					EndIf
// 					lRet := .F.	
// 				Else   		
// 					If Len(aFiles) == 0 .OR. !lExisDoc
// 					cMsgErro := "Não foi possível realizar o envio dos arquivos de NFe. Um ou mais arquivos não foram localizados no diretório informado."
// 						If !lIsBlind .And. lMenu
// 							GFEMsgErro(cMsgErro)
// 						EndIf
// 						lRet := .F.
// 					Else
// 						If !lTemContat
// 							cMsgErro := "Não foi possível realizar o envio dos arquivos de NFe. Não há contato cadastrado para recebimento dos arquivos XML NFe."
// 							If !lIsBlind .And. lMenu
// 								GFEMsgErro(cMsgErro)
// 							EndIf
// 							lRet := .F.	
// 						EndIf
// 					EndIf
// 				EndIf
// 			EndIf
// 		EndIf
// 	EndIf

// 	If cEnvXMLNFE == "1"
// 		cGWNENVNFE := "3" //Enviado ? Não se aplica
// 	Else
// 		If lRet
// 			cGWNENVNFE := "1" //Enviado ? Sim
// 		Else
// 			cGWNENVNFE := "2" //Enviado ? Não
// 		EndIf
// 	EndIf

// 	//Atualiza o status para "Enviado"
// 	Reclock("GWN",.F.)
// 	If GFXCP12117("GWN_ENVNFE") == .T.
// 		GWN->GWN_ENVNFE := cGWNENVNFE
// 	EndIf
// 	If GFXCP12117("GWN_MOTNFE") == .T.
// 		GWN->GWN_MOTNFE := cMsgErro
// 	EndIf
// 	GWN->(MsUnlock())
// 	RestArea(aOldArea)
// Return lRet

// Static Function GFEA050CAL(cNrCalc,lEncontrou,cMsg,lBloqueio)
// 	Local lCalCDoc     := .F.  // Calculo com documento de frete
// 	Local oModel65     := Nil
// 	Local cAliasQry    := Nil
// 	Default lEncontrou := .F.
// 	Default lBloqueio  := .F.

// 	cAliasQry := GetNextAlias()
// 	BeginSql Alias cAliasQry
// 		SELECT GW3.GW3_NRDF
// 		FROM %Table:GWF% GWF
// 		INNER JOIN %Table:GWH% GWH
// 		ON GWH.GWH_FILIAL = GWF.GWF_FILIAL
// 		AND GWH.GWH_NRCALC = GWF.GWF_NRCALC
// 		AND GWH.%NotDel%
// 		INNER JOIN %Table:GW4% GW4
// 		ON GW4.GW4_FILIAL = GWH.GWH_FILIAL
// 		AND GW4.GW4_TPDC = GWH.GWH_CDTPDC
// 		AND GW4.GW4_SERDC = GWH.GWH_SERDC
// 		AND GW4.GW4_EMISDC = GWH.GWH_EMISDC
// 		AND GW4.GW4_NRDC = GWH.GWH_NRDC
// 		AND GW4.%NotDel%
// 		INNER JOIN %Table:GW3% GW3
// 		ON GW3.GW3_FILIAL = GW4.GW4_FILIAL
// 		AND GW3.GW3_CDESP = GW4.GW4_CDESP
// 		AND GW3.GW3_EMISDF = GW4.GW4_EMISDF
// 		AND GW3.GW3_SERDF = GW4.GW4_SERDF
// 		AND GW3.GW3_NRDF = GW4.GW4_NRDF
// 		AND GW3.GW3_DTEMIS = GW4.GW4_DTEMIS
// 		AND GW3.GW3_SITFIS = '4'
// 		AND GW3.%NotDel%
// 		WHERE GWF.GWF_FILIAL = %xFilial:GWF%
// 		AND GWF.GWF_NRCALC = %Exp:cNrCalc%
// 		AND GWF.GWF_NRDF <> ' '
// 		AND GWF.%NotDel%
// 	EndSql
// 	If (cAliasQry)->(!Eof())
// 		lCalCDoc := .T.
// 	EndIf
// 	(cAliasQry)->(dbCloseArea())

// 	If lCalCDoc
// 		If SuperGetMv("MV_GFEAJDF",,'1') == '1'
// 			If cMsg == Nil
// 				Help( ,, 'HELP',, 'Cálculo de frete que já possui um Documento de Frete com o mesmo tipo, não podem ser reajustados.', 1, 0)
// 			EndIf
// 			cMsg := 'Cálculo de frete que já possui um Documento de Frete com o mesmo tipo, não podem ser reajustados.'
// 			lBloqueio := .T.
// 		Else
// 			oModel65 := FwLoadModel("GFEA065")
// 			oModel65:SetOperation(MODEL_OPERATION_UPDATE)
// 			If oModel65:Activate()
// 				lCalCDoc := .F. //Utilizado no GFEA050 apenas
// 				lBloqueio := .F.
// 			Else
// 				lCalCDoc := .T. //Utilizado no GFEA050 apenas
// 				If cMsg == Nil
// 					Help( ,, 'HELP',, "Não foi possível efetivar/aprovar o ajuste: " +  oModel65:GetErrorMessage()[6], 1, 0)
// 				EndIf
// 				cMsg := oModel65:GetErrorMessage()[6]
// 				lBloqueio := .T.
// 			EndIf
// 			oModel65:DeActivate()
// 			oModel65:Destroy()
// 			FreeObj(oModel65)
// 			lEncontrou := .T. //Utilizado no GFEA085 apenas
// 		EndIf
// 	Else
// 		lBloqueio := .F.
// 	EndIf
// Return lCalCDoc

// Static Function GF50VLROM(cNrRom,lCalcAuto,cCalculando)
// 	Local cAlQuery     := ""
// 	Local cAlQryGWO    := ""
// 	Local cQyGWF       := ""
// 	Local aRet         := {0,{},{},{}} // 0=Todos poderão ser recalculados; 1=alguns poderão ser recalculados; 2= Nenhum poderá ser recalculado; 3= Romaneio calculado no ERP
// 	Local nCount       := 0
// 	Local nCntErro     := 0
// 	Local nF           := 0
// 	Local nX           := 0
// 	Local nY           := 0
// 	Local nPos         := 0
// 	Local cTrecho      := ""
// 	Local cQuery       := ""
// 	Local lOk          := .F.
// 	Local cGWF_TPCALC  := ""
// 	Local cGWF_NROCO   := ""
// 	Local cGWF_NRPREF  := ""
// 	Local cMV_DPSERV   := SuperGetMV("MV_DPSERV", .F., "1")
// 	Local cGW3SIT      := ''
// 	Local lCheck       := GFXCP12116("GWF","GWF_EMISDF") == .T. .And. cMV_DPSERV == "1"
// 	Local cCampos	   := ""
// 	Local clftGW4	   := ""
// 	Local cWhere       := ""
// 	Local lVerifTrecho := .T.

// 	If lCheck
// 		cCampos := " GW4.GW4_NRDC,"
// 		cCampos += " GWF.GWF_FILIAL GW3_FILIAL,"
// 		cCampos += " GWF.GWF_NRDF GW3_NRDF," 
// 		cCampos += " GWF.GWF_CDESP GW3_CDESP,"
// 		cCampos += " GWF.GWF_EMISDF GW3_EMISDF,"
// 		cCampos += " GWF.GWF_SERDF GW3_SERDF,"
// 		cCampos += " GWF.GWF_DTEMDF GW3_DTEMIS"

// 		clftGW4 := " AND GW4.GW4_EMISDF = GWF.GWF_EMISDF"
// 		clftGW4 += " AND GW4.GW4_CDESP = GWF.GWF_CDESP"
// 		clftGW4 += " AND GW4.GW4_SERDF = GWF.GWF_SERDF"
// 		clftGW4 += " AND GW4.GW4_NRDF = GWF.GWF_NRDF"
// 		clftGW4 += " AND GW4.GW4_DTEMIS = GWF.GWF_DTEMDF"
// 	Else
// 		cCampos := "GW4.GW4_NRDC,"
// 		cCampos += "GW3.GW3_FILIAL,"
// 		cCampos += "GW3.GW3_NRDF," 
// 		cCampos += "GW3.GW3_CDESP,"
// 		cCampos += "GW3.GW3_EMISDF,"
// 		cCampos += "GW3.GW3_SERDF,"
// 		cCampos += "GW3.GW3_DTEMIS"		

// 		cQuery := " LEFT JOIN " + RetSqlName("GW3") + " GW3"
// 		cQuery += " ON GW3_FILIAL = '" + xFilial("GW3") + "'"
// 		cQuery += " AND GW4_EMISDF = GW3_EMISDF"
// 		cQuery += " AND GW4_CDESP = GW3_CDESP"
// 		cQuery += " AND GW4_SERDF = GW3_SERDF"
// 		cQuery += " AND GW4_NRDF  = GW3_NRDF"
// 		cQuery += " AND GW4_DTEMIS = GW3_DTEMIS"
// 		cQuery += " AND GW3_TPDF = GWF_TPCALC"
// 		cQuery += " AND GW3.D_E_L_E_T_ = ' '" 
// 	EndIf

// 	If GFXCP1212210('GW1_FILROM')
// 		cWhere += " GW1.GW1_FILROM = '" + xFilial("GW1") + "'"
// 	Else
// 		cWhere += " GW1.GW1_FILIAL = '" + xFilial("GW1") + "'"
// 	EndIf
// 	cWhere += " AND GW1.GW1_NRROM = '" + cNrRom + "'"

// 	cCampos := "%" + cCampos + "%"
// 	cQuery  := "%" + cQuery + "%"
// 	cWhere  := "%" + cWhere + "%"
// 	clftGW4 := "%" + clftGW4 + "%"

// 	cAlQuery := GetNextAlias()

// 	BeginSQL Alias cAlQuery
// 		SELECT DISTINCT GW1.R_E_C_N_O_ GW1_RECNO,
// 			            GW1.GW1_EMISDC,
// 						GW1.GW1_SERDC,
// 						GW1.GW1_NRDC,
// 						GW1.GW1_CDTPDC,
// 						GW1.GW1_CDREM,
// 						GW1.GW1_CDDEST,
// 						GW1.GW1_ENTEND,
// 						GW1.GW1_ENTBAI,
// 						GW1.GW1_ENTNRC,
// 						GW1.GW1_ENTCEP,
// 						GW1.GW1_NRREG,
// 						GW1.GW1_TPFRET,
// 						GW1.GW1_ICMSDC,
// 						GW1.GW1_USO,
// 						GW1.GW1_CARREG,
// 						GW1.GW1_NRROM,
// 						GW1.GW1_QTVOL,
// 						GW1.GW1_FILIAL,
// 						GW4.GW4_EMISDF,
// 						GWF.GWF_FILIAL,
// 						GWF.GWF_NRCALC,
// 						GWU.GWU_SEQ,
// 						%Exp: cCampos%
// 		FROM %Table:GW1% GW1
// 		INNER JOIN %Table:GWU% GWU
// 		ON GWU.GWU_FILIAL = GW1.GW1_FILIAL
// 		AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC 
// 		AND GWU.GWU_EMISDC = GW1.GW1_EMISDC
// 		AND GWU.GWU_SERDC = GW1.GW1_SERDC
// 		AND GWU.GWU_NRDC = GW1.GW1_NRDC
// 		AND GWU.%NotDel%
// 		LEFT JOIN %Table:GWH% GWH 
// 		ON GWH.GWH_FILIAL = GW1.GW1_FILIAL
// 		AND GWH.GWH_CDTPDC = GW1.GW1_CDTPDC 
// 		AND GWH.GWH_EMISDC = GW1.GW1_EMISDC 
// 		AND GWH.GWH_SERDC = GW1.GW1_SERDC 
// 		AND GWH.GWH_NRDC = GW1.GW1_NRDC
// 		AND GWH.GWH_TRECHO = GWU.GWU_SEQ
// 		AND GWH.%NotDel%
// 		LEFT JOIN %Table:GWF% GWF 
// 		ON GWF.GWF_FILIAL = GWH.GWH_FILIAL 
// 		AND GWF.GWF_NRCALC = GWH.GWH_NRCALC
// 		AND GWF.%NotDel%
// 		LEFT JOIN %Table:GW4% GW4 
// 		ON GW4.GW4_FILIAL = GWF.GWF_FILIAL
// 		%Exp:clftGW4%
// 		AND GW4.GW4_EMISDC = GW1.GW1_EMISDC
// 		AND GW4.GW4_SERDC = GW1.GW1_SERDC
// 		AND GW4.GW4_NRDC = GW1.GW1_NRDC
// 		AND GW4.GW4_TPDC = GW1.GW1_CDTPDC
// 		AND GW4.%NotDel%
// 		%Exp:cQuery%
// 		WHERE %Exp:cWhere%
// 		AND GW1.GW1_SIT IN ('4','5')
// 		AND GW1.%NotDel%		
// 		ORDER BY GW1.R_E_C_N_O_, GWU.GWU_SEQ
// 	EndSQL

// 	Do While (cAlQuery)->(!Eof())
		
// 		nCount++

// 		cQyGWF := GetNextAlias()
		
// 		If cCalculando == "ROMANEIO"
// 			cQuery := " AND GWF.GWF_TPCALC IN ('1','6')"
// 		Else
// 			cQuery := " AND GWF.GWF_TPCALC IN ('7')"
// 			cQuery += " AND GWF.GWF_NROCO = ' '" 
// 		EndIf

// 		cQuery := "%" + cQuery + "%"

// 		BeginSQL Alias cQyGWF
// 			SELECT GWF.GWF_FILIAL, 
// 				   GWF.GWF_NRCALC, 
// 				   GW4.GW4_NRDF, 
// 				   GWH.GWH_NRCALC, 
// 				   GW4.GW4_NRDC
// 			FROM %Table:GWF% GWF
// 			INNER JOIN %Table:GWH% GWH 
// 			ON GWH.GWH_FILIAL = GWF.GWF_FILIAL
// 			AND GWH.GWH_NRCALC = GWF.GWF_NRCALC 
// 			AND GWH.%NotDel%
// 			INNER JOIN %Table:GW4% GW4 
// 			ON GW4.GW4_FILIAL = GWH.GWH_FILIAL
// 			AND GW4.GW4_TPDC = GWH.GWH_CDTPDC
// 			AND GW4.GW4_EMISDC = GWH.GWH_EMISDC
// 			AND GW4.GW4_SERDC = GWH.GWH_SERDC
// 			AND GW4.GW4_NRDC = GWH.GWH_NRDC
// 			AND GW4.%NotDel%
// 			WHERE GWF.GWF_FILIAL = %Exp:(cAlQuery)->GWF_FILIAL%
// 			AND GWF.GWF_NRCALC = %Exp:(cAlQuery)->GWF_NRCALC%
// 			AND GWF.GWF_SEQTRE = %Exp:(cAlQuery)->GWU_SEQ%
// 			AND GW4.GW4_EMISDC = %Exp:(cAlQuery)->GW1_EMISDC%
// 			AND GW4.GW4_SERDC = %Exp:(cAlQuery)->GW1_SERDC%
// 			AND GW4.GW4_NRDC = %Exp:(cAlQuery)->GW1_NRDC%
// 			AND GW4.GW4_TPDC = %Exp:(cAlQuery)->GW1_CDTPDC%
// 			AND GWF.%NotDel%
// 			%Exp:cQuery%
// 		EndSQL
		
// 		If (cQyGWF)->(!Eof()) .Or. Empty((cAlQuery)->GWF_NRCALC) 
// 			cGW3SIT := ''
			
// 			If !Empty((cAlQuery)->GW3_NRDF)
// 				GW3->(dbSetOrder(1))
// 				GW3->(dbSeek((cAlQuery)->GW3_FILIAL + (cAlQuery)->GW3_CDESP + (cAlQuery)->GW3_EMISDF + (cAlQuery)->GW3_SERDF + (cAlQuery)->GW3_NRDF + (cAlQuery)->GW3_DTEMIS))
// 				cGW3SIT := GW3->GW3_SIT
// 			EndIf

// 			If (!Empty((cAlQuery)->GW3_NRDF) .And. ;
// 				(cMV_GFE005 == "1" .Or. (cMV_GFE005 == "2" .And. cGW3SIT $ "34")))
// 				nCntErro++
// 				aRet[1] := 1
// 				aAdd(aRet[2],{.F.,"Há documentos de carga vinculados a documento de frete. Os novos cálculos gerados podem apresentar valores diferentes do cálculo original.",(cAlQuery)->GW1_RECNO,;
// 								(cAlQuery)->GW1_EMISDC,;
// 								(cAlQuery)->GW1_SERDC ,;
// 								(cAlQuery)->GW1_NRDC  ,;
// 								(cAlQuery)->GW1_CDTPDC,;
// 								(cAlQuery)->GW1_CDREM ,;
// 								(cAlQuery)->GW1_CDDEST,;
// 								(cAlQuery)->GW1_ENTEND,;
// 								(cAlQuery)->GW1_ENTBAI,;
// 								(cAlQuery)->GW1_ENTNRC,;
// 								(cAlQuery)->GW1_ENTCEP,;
// 								(cAlQuery)->GW1_NRREG ,;
// 								(cAlQuery)->GW1_TPFRET,;
// 								(cAlQuery)->GW1_ICMSDC,;
// 								(cAlQuery)->GW1_USO   ,;
// 								(cAlQuery)->GW1_CARREG,;
// 								(cAlQuery)->GW1_NRROM ,;
// 								(cAlQuery)->GW1_QTVOL ,;
// 								(cAlQuery)->GWF_NRCALC,;
// 								(cAlQuery)->GWU_SEQ,;
// 								(cAlQuery)->GW4_NRDC,;
// 								(cAlQuery)->GW4_EMISDF,;
// 								(cAlQuery)->GW3_NRDF,;
// 								(cAlQuery)->GW1_FILIAL })

// 				aAdd(aRet[3],"Há documentos de carga vinculados a documento de frete. Os novos cálculos gerados podem apresentar valores diferentes do cálculo original.")
// 				aAdd(aRet[4],(cAlQuery)->GWF_NRCALC)
// 				(cAlQuery)->( dbSkip() )
// 				(cQyGWF)->(dbCloseArea())
// 				Loop
// 			EndIf

// 			If cGW3SIT $ '12'
// 				If !Empty((cAlQuery)->GW3_NRDF)
// 					If ASCAN(aDFReConf,{|X| X[1] == (cAlQuery)->GW3_FILIAL .And.;
// 											X[2] == (cAlQuery)->GW3_CDESP  .And.;
// 											X[3] == (cAlQuery)->GW3_EMISDF .And.;
// 											X[4] == (cAlQuery)->GW3_SERDF  .And.;
// 											X[5] == (cAlQuery)->GW3_NRDF   .And.;
// 											X[6] == (cAlQuery)->GW3_DTEMIS}) == 0
					
// 						aAdd(aDFReConf, {(cAlQuery)->GW3_FILIAL,;
// 											(cAlQuery)->GW3_CDESP,;
// 											(cAlQuery)->GW3_EMISDF,;
// 											(cAlQuery)->GW3_SERDF,;
// 											(cAlQuery)->GW3_NRDF,;
// 											(cAlQuery)->GW3_DTEMIS})
// 					EndIf

// 				ElseIf lCheck .And. !Empty((cAlQuery)->GW4B_NRDF)
// 					nPos := ASCAN(aDFReConf,{|X| X[1] == (cAlQuery)->GW4B_FILIAL .And.;
// 												 X[2] == (cAlQuery)->GW4B_CDESP  .And.;
// 												 X[3] == (cAlQuery)->GW4B_EMISDF .And.;
// 												 X[4] == (cAlQuery)->GW4B_SERDF  .And.;
// 												 X[5] == (cAlQuery)->GW4B_NRDF   .And.;
// 												 X[6] == (cAlQuery)->GW4B_DTEMIS})
					
// 					If nPos == 0
// 						aAdd(aDFReConf, {(cAlQuery)->GW4B_FILIAL,;
// 										 (cAlQuery)->GW4B_CDESP,;
// 										 (cAlQuery)->GW4B_EMISDF,;
// 										 (cAlQuery)->GW4B_SERDF,;
// 										 (cAlQuery)->GW4B_NRDF,;
// 										 (cAlQuery)->GW4B_DTEMIS})
// 					EndIf
// 				EndIf
// 			EndIf

// 			(cAlQuery)->(aAdd(aRet[2],{.T.,"OK",GW1_RECNO,;
// 										GW1_EMISDC,;
// 										GW1_SERDC ,;
// 										GW1_NRDC  ,;
// 										GW1_CDTPDC,;
// 										GW1_CDREM ,;
// 										GW1_CDDEST,;
// 										GW1_ENTEND,;
// 										GW1_ENTBAI,;
// 										GW1_ENTNRC,;
// 										GW1_ENTCEP,;
// 										GW1_NRREG ,;
// 										GW1_TPFRET,;
// 										GW1_ICMSDC,;
// 										GW1_USO   ,;
// 										GW1_CARREG,;
// 										GW1_NRROM ,;
// 										GW1_QTVOL ,;
// 										GWF_NRCALC,;
// 										GWU_SEQ,;
// 										"",;
// 										"",;
// 										"",;
// 										GW1_FILIAL}))
// 		EndIf
// 		(cQyGWF)->(dbCloseArea())
		
// 		(cAlQuery)->(dbSkip())
// 	EndDo
// 	(cAlQuery)->(DbCloseArea())

// 	If lCheck
// 		cCampos := " GWF.GWF_FILIAL,"
// 		cCampos += " GWF.GWF_CDESP,"
// 		cCampos += " GWF.GWF_EMISDF,"
// 		cCampos += " GWF.GWF_SERDF,"
// 		cCampos += " GWF.GWF_NRDF,"
// 		cCampos += " GWF.GWF_DTEMDF

// 		cQuery := " AND GW4.GW4_EMISDF = GWF.GWF_EMISDF"
// 		cQuery += " AND GW4.GW4_CDESP = GWF.GWF_CDESP"
// 		cQuery += " AND GW4.GW4_SERDF = GWF.GWF_SERDF"
// 		cQuery += " AND GW4.GW4_NRDF = GWF.GWF_NRDF"
// 		cQuery += " AND GW4.GW4_DTEMIS = GWF.GWF_DTEMDF"
// 	Else
// 		cCampos := " GW4.GW4_FILIAL GWF_FILIAL,"
// 		cCampos += " GW4.GW4_CDESP AS GWF_CDESP,"
// 		cCampos += " GW4.GW4_EMISDF AS GWF_EMISDF,"
// 		cCampos += " GW4.GW4_SERDF AS GWF_SERDF,"
// 		cCampos += " GW4.GW4_NRDF AS GWF_NRDF,"
// 		cCampos += " GW4.GW4_DTEMIS AS GWF_DTEMDF"

// 		cQuery := ""
// 	EndIf

// 	cCampos := "%" + cCampos + "%"
// 	cQuery  := "%" + cQuery + "%"

// 	cAlQuery := GetNextAlias()
	
// 	BeginSQL Alias cAlQuery
// 		SELECT DISTINCT GW1.R_E_C_N_O_ GW1_RECNO,
// 					    GW1.GW1_EMISDC,
// 						GW1.GW1_SERDC,
// 						GW1.GW1_NRDC,
// 						GW1.GW1_CDTPDC,
// 						GW1.GW1_CDREM,
// 						GW1.GW1_CDDEST,
// 						GW1.GW1_ENTEND,
// 						GW1.GW1_ENTBAI,
// 						GW1.GW1_ENTNRC,
// 						GW1.GW1_ENTCEP,
// 						GW1.GW1_NRREG,
// 						GW1.GW1_TPFRET,
// 						GW1.GW1_ICMSDC,
// 						GW1.GW1_USO,
// 						GW1.GW1_CARREG,
// 						GW1.GW1_NRROM,
// 						GXD.GXD_CODLOT,
// 						GWU.GWU_PAGAR,
// 						GW1.GW1_QTVOL,
// 						GWF.GWF_ORIGEM,
// 						GWF.GWF_TPCALC,
// 						GWF.GWF_NRCALC,
// 						GWF.GWF_NRPREF,
// 						GWU.GWU_SEQ,
// 						GWF.GWF_TRANSP,
// 						GWF.GWF_NROCO,
// 						GW1.GW1_FILIAL,
// 						%Exp:cCampos%	
// 		FROM %Table:GW1% GW1
// 		INNER JOIN %Table:GWU% GWU
// 		ON GWU.GWU_FILIAL = GW1.GW1_FILIAL
// 		AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC
// 		AND GWU.GWU_EMISDC = GW1.GW1_EMISDC
// 		AND GWU.GWU_SERDC = GW1.GW1_SERDC
// 		AND GWU.GWU_NRDC = GW1.GW1_NRDC
// 		AND GWU.%NotDel%
// 		LEFT JOIN %Table:GWH% GWH 
// 		ON GWH.GWH_FILIAL = GW1.GW1_FILIAL
// 		AND GWH.GWH_CDTPDC = GW1.GW1_CDTPDC
// 		AND GWH.GWH_EMISDC = GW1.GW1_EMISDC
// 		AND GWH.GWH_SERDC = GW1.GW1_SERDC
// 		AND GWH.GWH_NRDC = GW1.GW1_NRDC
// 		AND GWH.%NotDel%
// 		LEFT JOIN %Table:GWF% GWF
// 		ON GWF.GWF_FILIAL = GWH.GWH_FILIAL 
// 		AND GWF.GWF_NRCALC = GWH.GWH_NRCALC
// 		AND GWF.GWF_SEQTRE = GWU.GWU_SEQ
// 		AND GWF.%NotDel%
// 		LEFT JOIN %Table:GW4% GW4 
// 		ON GW4.GW4_FILIAL = GWF.GWF_FILIAL
// 		%Exp:cQuery%
// 		AND GW4.GW4_EMISDC = GW1.GW1_EMISDC
// 		AND GW4.GW4_SERDC = GW1.GW1_SERDC
// 		AND GW4.GW4_NRDC = GW1.GW1_NRDC
// 		AND GW4.GW4_TPDC = GW1.GW1_CDTPDC
// 		AND GW4.%NotDel%
// 		LEFT JOIN %Table:GXD% GXD 
// 		ON GXD.GXD_FILCAL = GWH.GWH_FILIAL 
// 		AND GXD.GXD_NRCALC = GWH.GWH_NRCALC
// 		AND GXD.%NotDel%
// 		WHERE %Exp:cWhere%
// 		AND GW1.GW1_SIT IN ('4','5')
// 		AND GW1.%NotDel%
// 		ORDER BY GW1.R_E_C_N_O_, GWF.GWF_NRCALC DESC, GWU.GWU_SEQ
// 	EndSQL

// 	Do While (cAlQuery)->(!Eof())
		
// 		cGWF_TPCALC	:= (cAlQuery)->GWF_TPCALC // 1=Normal;2=Compl Valor;3=Compl Imposto;4=Reentrega;5=Devolucao;6=Redespacho;7=Servico;8=Estimativa
// 		cGWF_NROCO	:= (cAlQuery)->GWF_NROCO
// 		cGWF_NRPREF	:= (cAlQuery)->GWF_NRPREF
// 		CGW1_TPFRET := (cAlQuery)->GW1_TPFRET
// 		CGWU_PAGAR	:= (cAlQuery)->GWU_PAGAR
		
// 		If CGWU_PAGAR != "2"
// 			lVerifTrecho := .F.
// 		EndIf
// 		nCount++
		
// 		If cCalculando == "ROMANEIO"
// 			lOk := ((cGWF_TPCALC=="1") .OR. (cGWF_TPCALC=="6")) .OR. (CGWU_PAGAR == '2' .AND. CGW1_TPFRET == '3')
// 		Else
// 			lOk := ((cGWF_TPCALC=="7") .AND. Empty(cGWF_NROCO))
// 		EndIf

// 		If lOk
// 			If !Empty(cGWF_NRPREF)
// 				nCntErro++
// 				aRet[1] := 1
// 				aAdd(aRet[2],{.F.,"Há cálculos vinculados a Pré-Faturas. Os novos cálculos gerados podem apresentar valores diferentes do cálculo original.",(cAlQuery)->GW1_RECNO,;
// 								(cAlQuery)->GW1_EMISDC,;
// 								(cAlQuery)->GW1_SERDC ,;
// 								(cAlQuery)->GW1_NRDC  ,;
// 								(cAlQuery)->GW1_CDTPDC,;
// 								(cAlQuery)->GW1_CDREM ,;
// 								(cAlQuery)->GW1_CDDEST,;
// 								(cAlQuery)->GW1_ENTEND,;
// 								(cAlQuery)->GW1_ENTBAI,;
// 								(cAlQuery)->GW1_ENTNRC,;
// 								(cAlQuery)->GW1_ENTCEP,;
// 								(cAlQuery)->GW1_NRREG ,;
// 								(cAlQuery)->GW1_TPFRET,;
// 								(cAlQuery)->GW1_ICMSDC,;
// 								(cAlQuery)->GW1_USO   ,;
// 								(cAlQuery)->GW1_CARREG,;
// 								(cAlQuery)->GW1_NRROM ,;
// 								(cAlQuery)->GW1_QTVOL ,;
// 								(cAlQuery)->GWF_NRCALC,;
// 								(cAlQuery)->GWU_SEQ,;
// 								(cAlQuery)->GWF_NRDF,;
// 								(cAlQuery)->GWF_TRANSP,;
// 								(cAlQuery)->GWF_NRDF,;
// 								(cAlQuery)->GW1_FILIAL })
				
// 				aAdd(aRet[3],"Há cálculos vinculados a Pré-Faturas. Os novos cálculos gerados podem apresentar valores diferentes do cálculo original.")
// 				aAdd(aRet[4],(cAlQuery)->GWF_NRCALC)
// 				(cAlQuery)->(dbSkip())
// 				Loop
// 			EndIf
// 			cGW3SIT := ''
// 			if !Empty((cAlQuery)->GWF_NRDF)
// 				GW3->(dbSetOrder(1))
// 				GW3->(dbSeek((cAlQuery)->GWF_FILIAL + (cAlQuery)->GWF_CDESP + (cAlQuery)->GWF_EMISDF + (cAlQuery)->GWF_SERDF + (cAlQuery)->GWF_NRDF + (cAlQuery)->GWF_DTEMDF)) 
// 				cGW3SIT := GW3->GW3_SIT
// 			EndIf

// 			If (GFXCP12116("GWF","GWF_EMISDF") == .T. .And. !Empty((cAlQuery)->GWF_NRDF) .And. cMV_DPSERV == "1" .And. ;
// 				(cMV_GFE005 == "1" .Or. (cMV_GFE005 == "2" .And. cGW3SIT $ "34")))
				
// 				nCntErro++
// 				aRet[1] := 1
// 				aAdd(aRet[2],{.F.,"Há documentos de carga vinculados a documento de frete. Os novos cálculos gerados podem apresentar valores diferentes do cálculo original.",(cAlQuery)->GW1_RECNO,;
// 								(cAlQuery)->GW1_EMISDC,;
// 								(cAlQuery)->GW1_SERDC ,;
// 								(cAlQuery)->GW1_NRDC  ,;
// 								(cAlQuery)->GW1_CDTPDC,;
// 								(cAlQuery)->GW1_CDREM ,;
// 								(cAlQuery)->GW1_CDDEST,;
// 								(cAlQuery)->GW1_ENTEND,;
// 								(cAlQuery)->GW1_ENTBAI,;
// 								(cAlQuery)->GW1_ENTNRC,;
// 								(cAlQuery)->GW1_ENTCEP,;
// 								(cAlQuery)->GW1_NRREG ,;
// 								(cAlQuery)->GW1_TPFRET,;
// 								(cAlQuery)->GW1_ICMSDC,;
// 								(cAlQuery)->GW1_USO   ,;
// 								(cAlQuery)->GW1_CARREG,;
// 								(cAlQuery)->GW1_NRROM ,;
// 								(cAlQuery)->GW1_QTVOL ,;
// 								(cAlQuery)->GWF_NRCALC,;
// 								(cAlQuery)->GWU_SEQ,;
// 								(cAlQuery)->GWF_NRDF,;
// 								(cAlQuery)->GWF_TRANSP,;
// 								(cAlQuery)->GWF_NRDF,;
// 								(cAlQuery)->GW1_FILIAL })

// 				aAdd(aRet[3],"Há documentos de carga vinculados a documento de frete. Os novos cálculos gerados podem apresentar valores diferentes do cálculo original.")
// 				aAdd(aRet[4],(cAlQuery)->GWF_NRCALC)
// 				(cAlQuery)->(dbSkip())
// 				Loop
// 			Else
// 				If !Empty((cAlQuery)->GWF_NRDF) .AND. cGW3SIT $ '12'
// 					if ASCAN(aDFReConf,{|X| X[1] == (cAlQuery)->GWF_FILIAL .And.;
// 											X[2] == (cAlQuery)->GWF_CDESP  .And.;
// 											X[3] == (cAlQuery)->GWF_EMISDF .And.;
// 											X[4] == (cAlQuery)->GWF_SERDF  .And.;
// 											X[5] == (cAlQuery)->GWF_NRDF   .And.;
// 											X[6] == (cAlQuery)->GWF_DTEMDF}) == 0

// 						aAdd(aDFReConf,{(cAlQuery)->GWF_FILIAL,;
// 										(cAlQuery)->GWF_CDESP,;
// 										(cAlQuery)->GWF_EMISDF,;
// 										(cAlQuery)->GWF_SERDF,;
// 										(cAlQuery)->GWF_NRDF,;
// 										(cAlQuery)->GWF_DTEMDF})
// 					EndIf
// 				EndIf
// 			EndIf
			
// 			If !Empty((cAlQuery)->GXD_CODLOT)
// 				nCntErro++
// 				aRet[1] := 1
// 				aAdd(aRet[2],{.F.,"Há cálculos vinculados a Lotes de Provisão. Os novos cálculos gerados podem apresentar valores diferentes do cálculo original.",(cAlQuery)->GW1_RECNO,;
// 								(cAlQuery)->GW1_EMISDC,;
// 								(cAlQuery)->GW1_SERDC ,;
// 								(cAlQuery)->GW1_NRDC  ,;
// 								(cAlQuery)->GW1_CDTPDC,;
// 								(cAlQuery)->GW1_CDREM ,;
// 								(cAlQuery)->GW1_CDDEST,;
// 								(cAlQuery)->GW1_ENTEND,;
// 								(cAlQuery)->GW1_ENTBAI,;
// 								(cAlQuery)->GW1_ENTNRC,;
// 								(cAlQuery)->GW1_ENTCEP,;
// 								(cAlQuery)->GW1_NRREG ,;
// 								(cAlQuery)->GW1_TPFRET,;
// 								(cAlQuery)->GW1_ICMSDC,;
// 								(cAlQuery)->GW1_USO   ,;
// 								(cAlQuery)->GW1_CARREG,;
// 								(cAlQuery)->GW1_NRROM ,;
// 								(cAlQuery)->GW1_QTVOL ,;
// 								(cAlQuery)->GWF_NRCALC,;
// 								(cAlQuery)->GWU_SEQ,;
// 								(cAlQuery)->GWF_NRDF,;
// 								(cAlQuery)->GWF_TRANSP,;
// 								(cAlQuery)->GWF_NRDF,;
// 								(cAlQuery)->GW1_FILIAL })
				
// 				aAdd(aRet[3],"Há cálculos vinculados a Lotes de Provisão. Os novos cálculos gerados podem apresentar valores diferentes do cálculo original.")
// 				aAdd(aRet[4],(cAlQuery)->GWF_NRCALC)
// 				(cAlQuery)->(dbSkip())
// 				Loop
// 			EndIf
	
// 			If (cAlQuery)->GWF_ORIGEM $ "2;4" .AND. cGWF_TPCALC $ "16"
// 				nCntErro++
// 				aRet[1] := 1
// 				If !lCalcAuto
// 					aAdd(aRet[2],{.F.,"Há frete combinado ou simulado. Os novos cálculos gerados podem apresentar valores diferentes do cálculo original.",(cAlQuery)->GW1_RECNO,; //"Romaneio já possui Frete Combinado"
// 								(cAlQuery)->GW1_EMISDC,;
// 								(cAlQuery)->GW1_SERDC ,;
// 								(cAlQuery)->GW1_NRDC  ,;
// 								(cAlQuery)->GW1_CDTPDC,;
// 								(cAlQuery)->GW1_CDREM ,;
// 								(cAlQuery)->GW1_CDDEST,;
// 								(cAlQuery)->GW1_ENTEND,;
// 								(cAlQuery)->GW1_ENTBAI,;
// 								(cAlQuery)->GW1_ENTNRC,;
// 								(cAlQuery)->GW1_ENTCEP,;
// 								(cAlQuery)->GW1_NRREG ,;
// 								(cAlQuery)->GW1_TPFRET,;
// 								(cAlQuery)->GW1_ICMSDC,;
// 								(cAlQuery)->GW1_USO   ,;
// 								(cAlQuery)->GW1_CARREG,;
// 								(cAlQuery)->GW1_NRROM ,;
// 								(cAlQuery)->GW1_QTVOL ,;
// 								(cAlQuery)->GWF_NRCALC,;
// 								(cAlQuery)->GWU_SEQ,;
// 								(cAlQuery)->GWF_NRDF,;
// 								(cAlQuery)->GWF_TRANSP,;
// 								(cAlQuery)->GWF_NRDF,;
// 								(cAlQuery)->GW1_FILIAL })
					
// 					aAdd(aRet[3],"Há frete combinado ou simulado. Os novos cálculos gerados podem apresentar valores diferentes do cálculo original.")
// 					aAdd(aRet[4],(cAlQuery)->GWF_NRCALC)
// 				EndIF
// 				(cAlQuery)->( dbSkip() )
// 				Loop
// 			EndIf
			

// 				// Ajustes não cancelados relacionados à ocorrência.
// 				cAlQryGWO := GetNextAlias()

// 				BeginSQL Alias cAlQryGWO
// 					SELECT GWO.R_E_C_N_O_ GWO_RECNO 
// 					FROM %Table:GWO% GWO
// 					WHERE GWO_FILIAL = %xFilial:GWO%
// 					AND GWO_NRCALC = %Exp:(cAlQuery)->GWF_NRCALC%
// 					AND GWO_NROCO <> ' '
// 					AND GWO_SITAJU IN ('1','2')
// 					AND GWO.%NotDel%
// 				EndSQL

// 				If (cAlQryGWO)->(!Eof())
// 					nCntErro++
// 					aRet[1] := 1
// 					aAdd(aRet[2],{.F.,"Há cálculos cancelados por ocorrência. Os novos cálculos gerados podem apresentar valores diferentes do cálculo original.",(cAlQuery)->GW1_RECNO,;
// 									(cAlQuery)->GW1_EMISDC,;
// 									(cAlQuery)->GW1_SERDC,;
// 									(cAlQuery)->GW1_NRDC,;
// 									(cAlQuery)->GW1_CDTPDC,;
// 									(cAlQuery)->GW1_CDREM,;
// 									(cAlQuery)->GW1_CDDEST,;
// 									(cAlQuery)->GW1_ENTEND,;
// 									(cAlQuery)->GW1_ENTBAI,;
// 									(cAlQuery)->GW1_ENTNRC,;
// 									(cAlQuery)->GW1_ENTCEP,;
// 									(cAlQuery)->GW1_NRREG,;
// 									(cAlQuery)->GW1_TPFRET,;
// 									(cAlQuery)->GW1_ICMSDC,;
// 									(cAlQuery)->GW1_USO,;
// 									(cAlQuery)->GW1_CARREG,;
// 									(cAlQuery)->GW1_NRROM,;
// 									(cAlQuery)->GW1_QTVOL,;
// 									(cAlQuery)->GWF_NRCALC,;
// 									(cAlQuery)->GWU_SEQ,;
// 									(cAlQuery)->GWF_NRDF,;
// 									(cAlQuery)->GWF_TRANSP,;
// 									(cAlQuery)->GWF_NRDF,;
// 									(cAlQuery)->GW1_FILIAL})

// 					aAdd(aRet[3],"Há cálculos cancelados por ocorrência. Os novos cálculos gerados podem apresentar valores diferentes do cálculo original.")
// 					aAdd(aRet[4],(cAlQuery)->GWF_NRCALC)

// 					(cAlQryGWO)->(dbCloseArea())
// 					(cAlQuery)->(dbSkip())
// 					Loop
// 				EndIf

// 				(cAlQryGWO)->(dbCloseArea())


// 			If CGW1_TPFRET == '3' .And. CGWU_PAGAR == '2' 
// 				nCntErro++
// 				aRet[1] := 1
// 				aAdd(aRet[2],{.F.,"Documentos de carga com sentido saída e tipo de frete FOB não efetuam cálculo.",(cAlQuery)->GW1_RECNO,;
// 								(cAlQuery)->GW1_EMISDC,;
// 								(cAlQuery)->GW1_SERDC ,;
// 								(cAlQuery)->GW1_NRDC  ,;
// 								(cAlQuery)->GW1_CDTPDC,;
// 								(cAlQuery)->GW1_CDREM ,;
// 								(cAlQuery)->GW1_CDDEST,;
// 								(cAlQuery)->GW1_ENTEND,;
// 								(cAlQuery)->GW1_ENTBAI,;
// 								(cAlQuery)->GW1_ENTNRC,;
// 								(cAlQuery)->GW1_ENTCEP,;
// 								(cAlQuery)->GW1_NRREG ,;
// 								(cAlQuery)->GW1_TPFRET,;
// 								(cAlQuery)->GW1_ICMSDC,;
// 								(cAlQuery)->GW1_USO   ,;
// 								(cAlQuery)->GW1_CARREG,;
// 								(cAlQuery)->GW1_NRROM ,;
// 								(cAlQuery)->GW1_QTVOL ,;
// 								(cAlQuery)->GWF_NRCALC,;
// 								(cAlQuery)->GWU_SEQ,;
// 								(cAlQuery)->GWF_NRDF,;
// 								(cAlQuery)->GWF_TRANSP,;
// 								(cAlQuery)->GWF_NRDF,;
// 								(cAlQuery)->GW1_FILIAL})
				
// 				aAdd(aRet[3],"Documentos de carga com sentido saída e tipo de frete FOB não efetuam cálculo.")
// 				aAdd(aRet[4],(cAlQuery)->GWF_NRCALC)
// 				(cAlQuery)->(dbSkip())
// 				Loop
// 			EndIf

// 		EndIf
// 		aAdd(aRet[2],{.T.,"OK" ,(cAlQuery)->GW1_RECNO,;
// 						(cAlQuery)->GW1_EMISDC,;
// 						(cAlQuery)->GW1_SERDC ,;
// 						(cAlQuery)->GW1_NRDC  ,;
// 						(cAlQuery)->GW1_CDTPDC,;
// 						(cAlQuery)->GW1_CDREM ,;
// 						(cAlQuery)->GW1_CDDEST,;
// 						(cAlQuery)->GW1_ENTEND,;
// 						(cAlQuery)->GW1_ENTBAI,;
// 						(cAlQuery)->GW1_ENTNRC,;
// 						(cAlQuery)->GW1_ENTCEP,;
// 						(cAlQuery)->GW1_NRREG ,;
// 						(cAlQuery)->GW1_TPFRET,;
// 						(cAlQuery)->GW1_ICMSDC,;
// 						(cAlQuery)->GW1_USO   ,;
// 						(cAlQuery)->GW1_CARREG,;
// 						(cAlQuery)->GW1_NRROM ,;
// 						(cAlQuery)->GW1_QTVOL ,;
// 						(cAlQuery)->GWF_NRCALC,;
// 						(cAlQuery)->GWU_SEQ,;
// 						"",;
// 						(cAlQuery)->GWF_TRANSP,;
// 						"",;
// 						(cAlQuery)->GW1_FILIAL })
// 		(cAlQuery)->(dbSkip())
// 	EndDo

// 	(cAlQuery)->(dbCloseArea())

// 	aSort(aRet[2],,,{|x,y| x[7]+x[4]+x[5]+x[6]+x[22]      < y[7]+y[4]+y[5]+y[6]+y[22]})
	
// 	nX := 1
// 	nF := Len(aRet[2])
// 	Do While nX <= nF
// 		cTrecho := aRet[2,nX,7]+aRet[2,nX,4]+aRet[2,nX,5]+aRet[2,nX,6]+aRet[2,nX,22]
// 		nY := nX + 1
// 		Do While nY <= Len(aRet[2]) .And. cTrecho == aRet[2,nY,7]+aRet[2,nY,4]+aRet[2,nY,5]+aRet[2,nY,6]+aRet[2,nY,22]
// 			If aRet[2,nY,1] == .F.
// 				aRet[2,nX,1] := .F.
// 				aRet[2,nX,2] := aRet[2,nY,2]
// 			EndIf
// 			aDel(aRet[2],nY)
// 			aSize(aRet[2],nF-1)
// 			nF--
// 		EndDo
// 		nX++
// 	EndDo
	
// 	aSort(aRet[2],,,{|x,y| x[21]+x[7]+x[4]+x[5]+x[6]      < y[21]+y[7]+y[4]+y[5]+y[6]})
// 	// Remover todos os trechos que não puderem ser recalculados dentro de um cálculo. 
// 	// Caso o documento possua um trecho que se encaixe em outro cálculo e não houver impedimento, esse outro cálculo será recalculado.
// 	nF := Len(aRet[2])
// 	For nX := 1 To nF
// 		If aRet[2,nX,1] == .F.
// 			If !Empty(aRet[2,nX,21])
// 				nPos := aScan(aRet[2],{|y|y[21] == aRet[2,nX,21]})
// 			Else
// 				nPos := Len(aRet[2]) + 1
// 			EndIf
// 			Do While nPos <= Len(aRet[2]) .And. aRet[2,nPos,21] == aRet[2,nX,21]
// 				If aRet[2,nPos,1]
// 					nCntErro++
// 				EndIf
// 				aRet[2,nPos,1] := .F.
// 				nPos++
// 			EndDo
// 		EndIf
// 	Next nX

// 	nCount := Len(aRet[2])
// 	nCntErro := 0
// 		For nX := 1 To nCount
// 			If aRet[2,nX,1] == .F.
// 				nCntErro++
// 			Else
// 				If Posicione("GWU", 1, xFilial("GW1") + aRet[2,nX,7] + aRet[2,nX,4] + aRet[2,nX,5] + aRet[2,nX,6] + aRet[2,nX,22],"GWU_PAGAR") == "2"	// Posiciona no trecho e veja se o pagar é não
// 					nCntErro++
// 					aAdd(aRet[3],"Documento(s) de carga relacionado(s) ao romaneio possui trecho(s) não pago(s).")
// 				EndIf
// 			EndIf
// 		Next nX
	
// 	aSort(aRet[3])
// 	nX := 1
// 	nF := Len(aRet[3])
// 	Do While nX <= nF
// 		cTrecho := aRet[3,nX]
// 		nY := nX + 1
// 		Do While nY <= Len(aRet[3]) .And. cTrecho == aRet[3,nY]
// 			aDel(aRet[3],nY)
// 			aSize(aRet[3],nF-1)
// 			nF--
// 		EndDo
// 		nX++
// 	EndDo

// 	If nCount == nCntErro
// 		aRet[1] := 2
// 	ElseIf nCount > nCntErro .And. nCntErro > 0 .and. lVerifTrecho == .T.
// 		aRet[1] := 1
// 	EndIf
// 	aSort(aRet[2],,,{|x,y| StrZero(x[3],10) + x[22] < StrZero(y[3],10) + y[22]})
// Return aRet

// Static Function GF50ARCLC(aDocsCarg,aDocCarg,aItDoc,aTrchDoc,aNoCalc)
// 	Local nQtdeUnit  := 0
// 	Local aTrechos   := {}
// 	Local nF         := 0
// 	Local nX         := 0
// 	Local nY         := 0
// 	Local nZ         := 0
// 	Local nChave     := 0
// 	Local aUnitiliz  := {}
// 	Local lGW8VALLIQ := GFXCP12118("GW8_VALLIQ") .Or. SuperGetMv("MV_ERPGFE",.F.,"2") == "4" // LOGIX - tratamento de contorno para falha de teste de existência do campo durante o cálculo automático executado pela integração via adapter EAI
// 	Local lGFE05014  := ExistBlock("GFE05014")
// 	Local aCtcPE     := nil

// 	nF := Len(aDocsCarg[2])
// 	For nX := 1 To nF
// 		If aDocsCarg[2,nX,1]
// 			If nChave != aDocsCarg[2,nX,3]// É permitido recalcular e o documento não repetiu
// 				aUnitiliz := {}
// 				nChave := aDocsCarg[2,nX,3]
// 				// Obtem a quantidade de unitizadores (embalagens) do documento de carga
// 				nQtdeUnit := 0

// 				GWB->( dbSetOrder(2) )
// 				GWB->( dbSeek(aDocsCarg[2,nX,26] + aDocsCarg[2,nX,7] + aDocsCarg[2,nX,4] + aDocsCarg[2,nX,5] + aDocsCarg[2,nX,6]) )
// 				Do While GWB->( !Eof() ) ;
// 						.And. GWB->GWB_FILIAL == aDocsCarg[2,nX,26] ;
// 						.And. GWB->GWB_CDTPDC == aDocsCarg[2,nX,7] ;
// 						.And. GWB->GWB_EMISDC == aDocsCarg[2,nX,4] ;
// 						.And. GWB->GWB_SERDC  == aDocsCarg[2,nX,5] ;
// 						.And. GWB->GWB_NRDC   == aDocsCarg[2,nX,6]

// 					nQtdeUnit += GWB->GWB_QTDE

// 					nPos := aScan(aUnitiliz,{|x|x[1] == GWB->GWB_CDUNIT })
// 					If nPos == 0
// 						aAdd(aUnitiliz,{GWB->GWB_CDUNIT,GWB->GWB_QTDE})
// 					Else
// 						aUnitiliz[nPos][2] += GWB->GWB_QTDE
// 					EndIf
// 					GWB->( dbSkip() )
// 				EndDo
// 				aAdd(aDocCarg, {aDocsCarg[2,nX,4],; //Emitente do Documento
// 				aDocsCarg[2,nX,5],; //Serie do Documento
// 				aDocsCarg[2,nX,6],; //Numero do Documento
// 				aDocsCarg[2,nX,7],; //Tipo do Documento
// 				aDocsCarg[2,nX,8],; //Remetente do Documento
// 				aDocsCarg[2,nX,9],; //Destinatario do Documento
// 				aDocsCarg[2,nX,10],; //Endereco de Entrega
// 				aDocsCarg[2,nX,11],; //Bairro de entrega
// 				aDocsCarg[2,nX,12],; //Cidade de Entrega
// 				aDocsCarg[2,nX,13],; //CEP de Entrega
// 				aDocsCarg[2,nX,14],; //Região de destino
// 				aDocsCarg[2,nX,15],; //Tipo de Frete
// 				aDocsCarg[2,nX,16],; //ICMS?
// 				aDocsCarg[2,nX,17],; //Finalidade da mercadoria
// 				aDocsCarg[2,nX,18],; //Número do carregamento
// 				aDocsCarg[2,nX,19],; //Numero do Agrupador
// 				If(nQtdeUnit > 0, nQtdeUnit, aDocsCarg[2,nX,20]),; //Quantidade de Unitizadores ou qtde de volumes do documento de carga
// 					aUnitiliz,; //Codigo do Unitilizador + Quantidade do Unitilizador
// 					aDocsCarg[2,nX,26]}) //Codigo do Unitilizador + Quantidade do Unitilizador

// 					GW8->( dbSetOrder(1) )
// 					GW8->( dbSeek(aDocsCarg[2,nX,26] + aDocsCarg[2,nX,7] + aDocsCarg[2,nX,4] + aDocsCarg[2,nX,5] + aDocsCarg[2,nX,6]) )
// 					Do While GW8->( !Eof() ) ;
// 							.And. GW8->GW8_FILIAL == aDocsCarg[2,nX,26] ;
// 							.And. GW8->GW8_CDTPDC == aDocsCarg[2,nX,7] ;
// 							.And. GW8->GW8_EMISDC == aDocsCarg[2,nX,4] ;
// 							.And. GW8->GW8_SERDC == aDocsCarg[2,nX,5] ;
// 							.And. GW8->GW8_NRDC == aDocsCarg[2,nX,6]

// 						aAdd(aItDoc, {GW8->GW8_EMISDC,; // Emitente do Documento
// 						GW8->GW8_SERDC ,; // Serie do Documento
// 						GW8->GW8_NRDC  ,; // Numero do Documento
// 						GW8->GW8_CDTPDC,; // Tipo do Documento
// 						GW8->GW8_ITEM  ,; // Item
// 						GW8->GW8_CDCLFR,; // ClassIficacao de Frete
// 						GW8->GW8_TPITEM,; // ClassIficacao de Frete
// 						GW8->GW8_QTDE  ,; // Quantidade do Item
// 						GW8->GW8_PESOR ,; // Peso do Item
// 						GW8->GW8_PESOC ,; // Peso Cubado
// 						GW8->GW8_QTDALT,; // Quantidade/Peso Alternativo
// 						GW8->GW8_VALOR ,; // Valor do Item
// 						GW8->GW8_VOLUME,; // Volume ocupado (m3)
// 						GW8->GW8_TRIBP, ; // Frete tributado PIS
// 						IIf(lGW8VALLIQ,GW8->GW8_VALLIQ,0),; // Valor Liquido
// 						GW8->GW8_FILIAL }) // Valor Liquido
// 						GW8->( dbSkip() )
// 					EndDo
// 				EndIf

// 				aTrechos := XFBGWUDC(,aDocsCarg[2,nX,26],aDocsCarg[2,nX,7],aDocsCarg[2,nX,4],aDocsCarg[2,nX,5],aDocsCarg[2,nX,6],aDocsCarg[2,nX,22])
// 				nZ := Len(aTrechos)
// 				For nY := 1 To nZ
// 					aAdd(aTrchDoc,aClone(aTrechos[nY]))
// 				Next nY
// 			Else

// 				aTrechos := XFBGWUDC(,aDocsCarg[2,nX,26],aDocsCarg[2,nX,7],aDocsCarg[2,nX,4],aDocsCarg[2,nX,5],aDocsCarg[2,nX,6],aDocsCarg[2,nX,22])
// 				nZ := Len(aTrechos)
// 				For nY := 1 To nZ
// 					aTrechos[nY,9] := "2" // Considera não pago.
// 					aAdd(aTrchDoc,aClone(aTrechos[nY]))
// 				Next nY
// 			EndIf
// 		Next nX
// 		aNoCalc := aDocsCarg[4]

// 		// Ponto de entrada
// 		If lGFE05014
// 			aCtcPE := ExecBlock("GFE05014",.F.,.F.,{aTrchDoc})
// 			If ValType(aCtcPE) == 'A' .And. !Empty(aCtcPE)
// 				aTrchDoc := aCtcPE
// 			EndIf
// 		EndIf
// 		Return

// Static Function GFE50NRROM()
// 	Local lAtrNewCod := !(IsInCallStack('OMSA200') .Or. IsInCallStack('OMSXCPL7') .Or. IsInCallStack('OMSATPR2') .Or. IsInCallStack('OMSM011DAK') .Or. IsInCallStack('GFEM011DAK'))
// 	Local cNewCod    := ""
// 	Local cSeqCar    := '01'

// 	If lAtrNewCod	//Caso o cliente queira fazer uma numeração própria
// 		If ExistBlock("GFE05011")
// 			cNewCod := ExecBlock("GFE05011",.F.,.F.)
// 		Else
// 			If SuperGetMv("MV_ERPGFE",.F.,"1") == "2" .And. SuperGetMv("MV_GFEI12",.F.,"2") == "1"
// 				cNewCod := GetSXENum("DAK","DAK_COD") + cSeqCar
// 				Do While (GFEA50GWN(xFilial("GWN"),cNewCod))
// 					ConfirmSX8()
// 					cNewCod := GetSXENum("DAK","DAK_COD") + cSeqCar
// 				EndDo
// 			Else
// 				cNewCod := GetSXENum("GWN","GWN_NRROM")
// 				Do While (GFEA50GWN(xFilial("GWN"),cNewCod))
// 					ConfirmSX8()
// 					cNewCod := GetSXENum("GWN","GWN_NRROM")
// 				EndDo
// 			EndIf
// 		EndIf
// 	EndIf

// Return cNewCod

// Static Function GFEA50GWN(cFilGWN, cNrGWN)
// 	Local lRet      := .T.
// 	Local cAliasGWN := GetNextAlias()

// 	BeginSql Alias cAliasGWN
// 		SELECT GWN.GWN_FILIAL
// 		FROM %Table:GWN% GWN
// 		WHERE GWN.GWN_FILIAL = %Exp:cFilGWN%
// 		AND GWN.GWN_NRROM = %Exp:cNrGWN%
// 		AND GWN.%NotDel%
// 	EndSql
// 	lRet := (cAliasGWN)->(!Eof())
// 	(cAliasGWN)->(dbCloseArea())
// Return lRet

// Static Function GFEA50GXT(cFilRom, cNrRom)
// 	Local aTblFrt := Array(21)
// 	Local lRet    := .F.

// 	aTblFrt[21]:= ''

// 	If GFXCP12121('GWN_NRCT')
// 		// Valida contrato de transporte para o transportador
// 		if cFilRom != Nil
// 			//Localiza o Romaneio
// 			GWN->(dbSetOrder(01))
// 			GWN->(DbSeek(cFilRom + cNrRom))
// 		EndIf
// 		If !Empty(GWN->GWN_NRCT)
// 			GXT->( dbSetOrder(01) )
// 			If GXT->( dbSeek(xFilial("GXT") + GWN->GWN_NRCT) )
// 				aTblFrt[1] := GXT->GXT_CDTRP
// 				aTblFrt[2] := GXT->GXT_NRTAB
// 				aTblFrt[20]:= GXT->GXT_NRNEG
// 				aTblFrt[21]:= GWN->GWN_NRCT
// 				lRet := .T.
// 			EndIf
// 		EndIf
// 	EndIf
// Return {lRet, aTblFrt}

// Static Function GFE50DFCONF(lmsg)
// 	Local cRet      := ""
// 	Local oModelPai := FWLoadModel("GFEA065")
// 	Local oModelGW3 := oModelPai:GetModel("GFEA065_GW3")

// 	Default lmsg := .T.

// 	oModelPai:SetOperation(MODEL_OPERATION_UPDATE)
// 	If oModelPai:Activate()
// 		If !oModelGW3:SetValue("GW3_SIT","1")
// 			Help(,,"HELP",, oModelPai:GetErrorMessage()[6],1,0)
// 		EndIf

// 		If oModelPai:VldData()
// 			oModelPai:CommitData()
// 		Else
// 			Help(,,"HELP",, oModelPai:GetErrorMessage()[6],1,0)
// 		EndIf
// 	ElseIf FwIsInCallStack("GFEA065")
// 		If lmsg
// 			Help(,,"HELP",, "Tentativa de recálculo de Frete. Motivo de não ser executado o recálculo: " + oModelPai:GetErrorMessage()[6],1,0)
// 		Else
// 			cRet := "Tentativa de recálculo de Frete. Motivo de não ser executado o recálculo: " + oModelPai:GetErrorMessage()[6]
// 		EndIf
// 	EndIf

// 	oModelPai:Deactivate()
// 	oModelPai:Destroy(oModelPai)
// 	oModelPai := Nil
// Return cRet

// Static Function GFEDISTAN(nHODRET,nHODSAI)
// 	Local nDistan := 0

// 	If nHODRET > nHODSAI
// 		nDistan := nHODRET - nHODSAI
// 	EndIf

// 	If nHODRET < nHODSAI
// 		nDistan:= (nHODRET+1000000)-nHODSAI
// 	EndIf
// Return nDistan

// Static Function GFEA50VCAL(cFilRom, nNrRom)
// 	Local oSize      := Nil
// 	Local oFWLayer   := Nil
// 	Local oLayerTot  := Nil
// 	Local oLayerCalc := Nil
// 	Local aNewButton := {}
// 	Local aColDef    := {}
// 	Local cAliasTmp  := ""
// 	Local cAliasAux  := ""
// 	Local aOrigem    := RetSx3Box(Posicione('SX3',2,'GWF_ORIGEM','X3CBox()'),,,1)
// 	Local aTpCalc    := RetSx3Box(Posicione('SX3',2,'GWF_TPCALC','X3CBox()'),,,1)
// 	Local aTpFret    := RetSx3Box(Posicione('SX3',2,'GWF_TPFRET','X3CBox()'),,,1)
// 	Local aFinCal    := RetSx3Box(Posicione('SX3',2,'GWF_FINCAL','X3CBox()'),,,1)
// 	Local aIdFrVi    := RetSx3Box(Posicione('SX3',2,'GWF_IDFRVI','X3CBox()'),,,1)
// 	Local aAgrup     := RetSx3Box(Posicione('SX3',2,'GWF_AGRUP' ,'X3CBox()'),,,1)
// 	Local nRomVlFrt  := 0
// 	Local nCalcVlFrt := 0
// 	Local nFrtNormal := 0
// 	Local nFrtRedesp := 0
// 	Local nRomAjus	 := 0
// 	Local nQtdCalc	 := 0

// 	Default cFilRom  := ""
// 	Default nNrRom   := ""

// 	Private aData    := {}
// 	Private oGrid    := Nil

// 	oSize := FWDefSize():New(.T.)
// 	oSize:AddObject( "ENCHOICE", 100, 100, .T., .T. ) // Adiciona enchoice
// 	oSize:SetWindowSize({000, 000, 400, 800})
// 	oSize:lLateral := .T.  // Calculo vertical
// 	oSize:Process() //executa os calculos

// 	DEFINE MSDIALOG oDlgCalc TITLE "Cálculos do Romaneio" ;
// 		FROM oSize:aWindSize[1],oSize:aWindSize[2] ;
// 		TO oSize:aWindSize[3],oSize:aWindSize[4] ;
// 		COLORS 0, 16777215 PIXEL

// 	oFWLayer := FWLayer():New()
// 	oFWLayer:Init(oDlgCalc, .F., .T.)

// 	oFWLayer:AddLine('TOTAL', 20, .T.)
// 	oFWLayer:AddCollumn('COL1', 100, .T., 'TOTAL')
// 	oFWLayer:AddLine('CALC', 80, .T.)
// 	oFWLayer:AddCollumn('COL2', 100, .T., 'CALC')

// 	oLayerTot  := oFWLayer:GetColPanel('COL1', 'TOTAL')
// 	oLayerCalc := oFWLayer:GetColPanel('COL2', 'CALC')

// 	Aadd(aColDef, { 1, "Valor de Frete" , 85, CONTROL_ALIGN_LEFT})
// 	Aadd(aColDef, { 2, "Nr Cálculo"			, 70, CONTROL_ALIGN_LEFT})
// 	Aadd(aColDef, { 3, "Transportador"		, 100, CONTROL_ALIGN_LEFT})
// 	Aadd(aColDef, { 4, "Nome Transportador" , 150, CONTROL_ALIGN_LEFT})
// 	Aadd(aColDef, { 5, "Origem Valor"		, 85, CONTROL_ALIGN_LEFT})
// 	Aadd(aColDef, { 6, "Tipo de Cálculo"	, 85, CONTROL_ALIGN_LEFT})
// 	Aadd(aColDef, { 7, "Tipo Frete"			, 70, CONTROL_ALIGN_LEFT})
// 	Aadd(aColDef, { 8, "Finalidade"			, 70, CONTROL_ALIGN_LEFT})
// 	Aadd(aColDef, { 9, "Valor Ajuste"		, 70, CONTROL_ALIGN_LEFT})
// 	Aadd(aColDef, {10, "Frete Viagem"		, 70, CONTROL_ALIGN_LEFT})
// 	Aadd(aColDef, {11, "Agrupado"			, 70, CONTROL_ALIGN_LEFT})
// 	Aadd(aColDef, {12, "Sequência"			, 70, CONTROL_ALIGN_LEFT})

// 	cAliasTmp := GetNextAlias()
// 	BeginSql Alias cAliasTmp
// 		SELECT GWF.GWF_FILIAL,
// 				GWF.GWF_NRCALC,
// 				GWF.GWF_VLAJUS,
// 				GWF.GWF_TPCALC,
// 				GWF.GWF_TRANSP,
// 				GWF.GWF_ORIGEM,
// 				GWF.GWF_TPFRET,
// 				GWF.GWF_FINCAL,
// 				GWF.GWF_IDFRVI,
// 				GWF.GWF_AGRUP,
// 				GWF.GWF_SEQTRE
// 		FROM %Table:GWF% GWF
// 		WHERE GWF.GWF_FILIAL = %Exp:cFilRom%
// 		AND GWF.GWF_NRROM = %Exp:nNrRom%
// 		AND GWF.%NotDel%
// 	EndSql

// 	nRomVlFrt  := 0
// 	nFrtNormal := 0
// 	nFrtRedesp := 0
// 	nRomAjus   := 0
// 	nQtdCalc   := 0

// 	Do While (cAliasTmp)->(!Eof())
// 		nCalcVlFrt := 0
// 		nQtdCalc++

// 		cAliasAux := GetNextAlias()
// 		BeginSql Alias cAliasAux
// 			SELECT SUM(GWI.GWI_VLFRET) AS GWI_VLFRET
// 			FROM %Table:GWI% GWI
// 			WHERE GWI.GWI_FILIAL = %Exp:(cAliasTmp)->GWF_FILIAL%
// 			AND GWI.GWI_NRCALC = %Exp:(cAliasTmp)->GWF_NRCALC%
// 			AND GWI.%NotDel%
// 		EndSql

// 		nCalcVlFrt := (cAliasAux)->GWI_VLFRET + (cAliasTmp)->GWF_VLAJUS
// 		nRomVlFrt  += nCalcVlFrt

// 		If (cAliasTmp)->GWF_TPCALC == "1"
// 			nFrtNormal += (cAliasAux)->GWI_VLFRET
// 		ElseIf (cAliasTmp)->GWF_TPCALC == "6"
// 			nFrtRedesp += (cAliasAux)->GWI_VLFRET
// 		EndIf
// 		(cAliasAux)->(dbCloseArea())

// 		nRomAjus += (cAliasTmp)->GWF_VLAJUS

// 		Aadd(aData, {Transform(nCalcVlFrt,"@E 999,999.99"),;
// 			(cAliasTmp)->GWF_NRCALC,;
// 			(cAliasTmp)->GWF_TRANSP,;
// 			Posicione("GU3",1,xFilial("GU3")+(cAliasTmp)->GWF_TRANSP,"GU3_NMEMIT"),;
// 			aOrigem[Val((cAliasTmp)->GWF_ORIGEM)][3],;
// 			aTpCalc[Val((cAliasTmp)->GWF_TPCALC)][3],;
// 			aTpFret[Val((cAliasTmp)->GWF_TPFRET)][3],;
// 			aFinCal[Val((cAliasTmp)->GWF_FINCAL)][3],;
// 			Transform((cAliasTmp)->GWF_VLAJUS,"@E 999,999.99"),;
// 			aIdFrVi[Val((cAliasTmp)->GWF_IDFRVI)][3],;
// 			aAgrup[Val((cAliasTmp)->GWF_AGRUP)][3],;
// 			(cAliasTmp)->GWF_SEQTRE,;
// 			(cAliasTmp)->GWF_FILIAL})

// 		(cAliasTmp)->(dbSkip())
// 	EndDo

// 	@ 10, 015  SAY "Filial:" SIZE 25,7 PIXEL OF oLayerTot
// 	@ 10, 045 MSGET cFilRom When .F. SIZE 40,7 PIXEL OF oLayerTot

// 	@ 10, 100  SAY "Romaneio:" SIZE 25,7 PIXEL OF oLayerTot
// 	@ 10, 130 MSGET nNrRom When .F. SIZE 40,7 PIXEL OF oLayerTot

// 	@ 10, 185  SAY "Qtd Calc:" SIZE 25,7 PIXEL OF oLayerTot
// 	@ 10, 215 MSGET nQtdCalc When .F. SIZE 40,7 PIXEL OF oLayerTot

// 	@ 25, 015  SAY "Frt Total:" SIZE 25,7 PIXEL OF oLayerTot
// 	@ 25, 045 MSGET Transform(nRomVlFrt,"@E 999,999.99") When .F. SIZE 40,7 PIXEL OF oLayerTot

// 	@ 25, 100  SAY "Frt Norm:" SIZE 25,7 PIXEL OF oLayerTot
// 	@ 25, 130 MSGET Transform(nFrtNormal,"@E 999,999.99") When .F. SIZE 40,7 PIXEL OF oLayerTot

// 	@ 25, 185  SAY "Frt Redes:" SIZE 25,7 PIXEL OF oLayerTot
// 	@ 25, 215 MSGET Transform(nFrtRedesp,"@E 999,999.99") When .F. SIZE 40,7 PIXEL OF oLayerTot

// 	@ 25, 270  SAY "Frt Ajuste:" SIZE 25,7 PIXEL OF oLayerTot
// 	@ 25, 300 MSGET Transform(nRomAjus,"@E 999,999.99") When .F. SIZE 40,7 PIXEL OF oLayerTot

// 	oGrid:= GFEGrid():New(oLayerCalc,aData,8,120,390,aColDef,"{ ||GFEA50DET()}")
// 	oGrid:SetFreeze(1)
// 	(cAliasTmp)->(dbCloseArea())
// 	ACTIVATE MSDIALOG oDlgCalc ON INIT EnchoiceBar(oDlgCalc,{||oDlgCalc:End()},{||oDlgCalc:End()},,aNewButton) CENTERED
// Return

// Static Function GFEA50DET()
// 	Local aCurPos := {}
// 	Local nLinha  := 0

// 	aCurPos := oGrid:GetCursorPos()
// 	nLinha := aCurPos[1] + 1
// 	If nLinha > 0
// 		GWF->(dbSetOrder(1))
// 		If GWF->(dbSeek(aData[nLinha][13] + aData[nLinha][2]))
// 			FWExecView("Visualiza", "GFEC080", 1,,{|| .T.})
// 		EndIf
// 	EndIf
// Return

// Static Function ValCalcLot()
// 	Local lRet := .T.
// 	// Validar se o romaneio possui cálculos vinculados a lotes de provisão
// 	GWF->( dbSetOrder(4) )
// 	GWF->( dbSeek(xFilial("GWF") + GWN->GWN_NRROM) )
// 	Do While lRet .And. GWF->( !Eof() ) .And. GWF->GWF_FILIAL == xFilial("GWF") .And. GWF->GWF_NRROM == GWN->GWN_NRROM

// 		GXD->(DbSetOrder(2))
// 		If GXD->(DbSeek(GWF->GWF_FILIAL+GWF->GWF_NRCALC))
// 			lRet := .F.
// 		EndIf
// 		GWF->( dbSkip() )
// 	EndDo
// Return lRet

// // Função para verificar se o(s) Documento(s) de Carga relacionados possuem Documento de Frete.
// // Se o documento frete estiver na situação bloqueado, executar a rotina de auditoria de frete. 
// Static Function GFE050AUDIT(cFilDc, cCDTPDC,cEMISDC,cSERDC,cNRDC)
// 	Local aAreaGW3  := GW3->(GetArea())
// 	Local cAliasQry := GetNextAlias()

// 	BeginSql Alias cAliasQry
// 		SELECT GW3.R_E_C_N_O_ AS GW3Recno
// 		  FROM %Table:GW1% GW1
// 		 INNER JOIN %Table:GW4% GW4
// 		ON GW4.GW4_FILIAL = GW1.GW1_FILIAL
// 		AND GW4.GW4_EMISDC = GW1.GW1_EMISDC
// 		AND GW4.GW4_SERDC = GW1.GW1_SERDC
// 		AND GW4.GW4_NRDC = GW1.GW1_NRDC
// 		AND GW4.GW4_TPDC = GW1.GW1_CDTPDC
// 		AND GW4.%NotDel%
// 		INNER JOIN %Table:GW3% GW3
// 		ON GW3.GW3_FILIAL = GW4.GW4_FILIAL
// 		AND GW3.GW3_CDESP = GW4.GW4_CDESP
// 		AND GW3.GW3_EMISDF = GW4.GW4_EMISDF
// 		AND GW3.GW3_SERDF = GW4.GW4_SERDF
// 		AND GW3.GW3_NRDF = GW4.GW4_NRDF
// 		AND GW3.GW3_DTEMIS = GW4.GW4_DTEMIS
// 		AND GW3.GW3_SIT IN ('2','5')
// 		AND GW3.GW3_TPDF IN ('1','4','5','6','7')
// 		AND GW3.%NotDel%
// 		WHERE GW1.GW1_FILIAL = %Exp:cFilDc%
// 		AND GW1.GW1_CDTPDC = %Exp:cCDTPDC%
// 		AND GW1.GW1_EMISDC = %Exp:cEMISDC%
// 		AND GW1.GW1_SERDC = %Exp:cSERDC%
// 		AND GW1.GW1_NRDC = %Exp:cNRDC%
// 		AND GW1.%NotDel%
// 		ORDER BY %Order:GW1%
// 	EndSql
// 	Do While (cAliasQry)->(!Eof())
// 		GW3->( DbGoTo( (cAliasQry)->GW3Recno ) )
// 		GFE50DFCONF()
// 		(cAliasQry)->(dbSkip())
// 	EndDo
// 	(cAliasQry)->(dbCloseArea())
// 	RestArea(aAreaGW3)
// Return

// // Função para verificar se calculo usado possui algum componente ativo do tipo serviço que calcula por romaneio.
// Static Function ChkCompServ()
// 	Local lRet      := .F.
// 	Local cAliasQry := GetNextAlias()
// 	Local cCodFil   := GWF->GWF_FILIAL
// 	Local cCodTrp   := GWF->GWF_TRANSP
// 	Local cNrCalc   := GWF->GWF_NRCALC

// 	BeginSql Alias cAliasQry
// 		SELECT GWG.R_E_C_N_O_ AS RECNOGWG
// 		FROM %Table:GWG% GWG					// Tabela do Calculo de Frete
// 		INNER JOIN %Table:GWI% GWI				// Componentes do calculo de Frete
// 		ON GWI.GWI_FILIAL = GWG.GWG_FILIAL
// 		AND GWI.GWI_NRCALC = GWG.GWG_NRCALC
// 		AND GWI.GWI_CDCLFR = GWG.GWG_CDCLFR
// 		AND GWI.GWI_CDTPOP = GWG.GWG_CDTPOP
// 		AND GWI.%NotDel%
// 		INNER JOIN %Table:GV2% GV2				// Cadastro de Componentes
// 		ON GV2.GV2_FILIAL = %xFilial:GV2%
// 		AND GV2.GV2_CDCOMP = GWI.GWI_CDCOMP
// 		AND GV2.GV2_SERVI = '1'
// 		AND GV2.GV2_CALSER = '2'				// 1-Ocorrencia, 2-Romaneio
// 		AND GV2.%NotDel%
// 		WHERE GWG.GWG_FILIAL = %Exp:cCodFil%
// 		AND GWG.GWG_NRCALC = %Exp:cNrCalc%
// 		AND GWG.GWG_CDEMIT = %Exp:cCodTrp%
// 		AND GWG.%NotDel%
// 	EndSql
// 	If (cAliasQry)->( !Eof() )
// 		lRet := .T.

// 		(cAliasQry)->(dbSkip())
// 	EndIf
// 	(cAliasQry)->(dbCloseArea())

// Return lRet

// // Manipula dados do romaneio para atualização de tabela agrupador para Relatorio de Movimentação de Documento de Carga
// Static Function LoadMovtoDoc(nOpc)
// 	Local i 		:= 0
// 	Local aAuxGX0   := {}
// 	Local cAliasGX0 := Nil
// 	Local cAliasGW1 := Nil
// 	Local cAliasGW8 := Nil
// 	Local cAliasGWU := Nil
// 	Local oMovDocto := GFEMovtoCarga():New()

// 	Default aAuxDc := {}

// 	If !Empty(nOpc)

// 		If nOpc == MODEL_OPERATION_INSERT
// 			oMovDocto:setBranch(GWN->GWN_FILIAL)
// 			oMovDocto:setFilRomaneio(GWN->GWN_FILIAL)
// 			oMovDocto:setNumRomaneio(GWN->GWN_NRROM)
// 			oMovDocto:setClassFrete(GWN->GWN_CDCLFR)
// 			oMovDocto:setDescClassFrete(Posicione("GUB", 1, xFilial("GUB")+GWN->GWN_CDCLFR, "GUB_DSCLFR"))
// 			oMovDocto:setTipoOper(GWN->GWN_CDTPOP)
// 			oMovDocto:setDescTipoOperacao(Posicione("GV4", 1, xFilial("GV4")+GWN->GWN_CDTPOP, "GV4_DSTPOP"))

// 			cAliasGW1 := oMovDocto:SearchDCByRomaneio()
// 			While (cAliasGW1)->(!Eof())
// 				GW1->(dbGoTo( (cAliasGW1)->RECNUM ))

// 				cCidDest := Posicione("GU3", 1, xFilial("GU3")+GW1->GW1_CDDEST, "GU3_NRCID")
// 				cCidRem  := Posicione("GU3", 1, xFilial("GU3")+GW1->GW1_CDREM, "GU3_NRCID")

// 				oMovDocto:setBranch(GW1->GW1_FILIAL)
// 				oMovDocto:setTipoNF(GW1->GW1_CDTPDC)
// 				oMovDocto:setEmissorNF(GW1->GW1_EMISDC)
// 				oMovDocto:setSerieNF(GW1->GW1_SERDC)
// 				oMovDocto:setNumeroNF(GW1->GW1_NRDC)
// 				oMovDocto:setDataNF(GW1->GW1_DTEMIS)
// 				oMovDocto:setNomeEmitente(Posicione("GU3", 1, xFilial("GU3")+GW1->GW1_EMISDC, "GU3_NMEMIT"))
// 				oMovDocto:setDestinatarioNF(GW1->GW1_CDDEST)
// 				oMovDocto:setNomeDestinat(Alltrim(Posicione("GU3", 1, xFilial("GU3")+GW1->GW1_CDDEST, "GU3_NMEMIT")))
// 				oMovDocto:setCidDestinat(cCidDest)
// 				oMovDocto:setUFDestinat(Posicione("GU7", 1, xFilial("GU7")+cCidDest, "GU7_CDUF"))
// 				oMovDocto:setDataSaida(GW1->GW1_DTSAI)
// 				oMovDocto:setRepresentante(GW1->GW1_REPRES)
// 				oMovDocto:setRemetente(GW1->GW1_CDREM)
// 				oMovDocto:setNomeRemetente(Alltrim(Posicione("GU3", 1, xFilial("GU3")+GW1->GW1_CDREM, "GU3_NMEMIT")))
// 				oMovDocto:setCidRemetente(cCidRem)
// 				oMovDocto:setUFRemetente(Posicione("GU7", 1, xFilial("GU7")+cCidRem, "GU7_CDUF"))
// 				oMovDocto:setRegComercial(GW1->GW1_REGCOM)

// 				// Atribuição de dados GW8
// 				cAliasGW8 := GetNextAlias()
// 				BeginSQL Alias cAliasGW8
// 					SELECT GW8.GW8_FILIAL, CASE WHEN COUNT(DISTINCT GW8.GW8_UNINEG) > 1 THEN ' ' ELSE MAX(GW8.GW8_UNINEG) END GW8_UNINEG
// 						 , SUM(ROUND(GW8.GW8_VALOR, 2)) GW8_VALOR, SUM(ROUND(GW8.GW8_PESOR, 2)) GW8_PESOR, SUM(ROUND(GW8.GW8_VOLUME, 2)) GW8_VOLUME, SUM(ROUND(GW8.GW8_PESOC, 2)) GW8_PESOC
// 					FROM %Table:GW8% GW8
// 					WHERE GW8.GW8_FILIAL = %Exp:GW1->GW1_FILIAL%
// 					AND GW8.GW8_CDTPDC = %Exp:GW1->GW1_CDTPDC%
// 					AND GW8.GW8_EMISDC = %Exp:GW1->GW1_EMISDC%
// 					AND GW8.GW8_SERDC = %Exp:GW1->GW1_SERDC%
// 					AND GW8.GW8_NRDC = %Exp:GW1->GW1_NRDC%
// 					AND GW8.%NotDel%
// 					GROUP BY GW8.GW8_FILIAL
// 				EndSQL
// 				If (cAliasGW8)->(!EoF())
// 					oMovDocto:setValorNF((cAliasGW8)->GW8_VALOR)
// 					oMovDocto:setPesoNF((cAliasGW8)->GW8_PESOR)
// 					oMovDocto:setVolumeNF((cAliasGW8)->GW8_VOLUME)
// 					oMovDocto:setPesoCubado((cAliasGW8)->GW8_PESOC)
// 					oMovDocto:setUnidNegocio((cAliasGW8)->GW8_UNINEG)
// 				EndIf
// 				(cAliasGW8)->(dbCloseArea())

// 				// Atribuição de dados GWU
// 				cAliasGWU := GetNextAlias()
// 				BeginSQL Alias cAliasGWU
// 					SELECT GWU_SEQ, GWU_CDTRP, GWU_DTENT
// 					FROM %Table:GWU% GWU
// 					WHERE GWU.GWU_FILIAL = %Exp:GW1->GW1_FILIAL%
// 					AND GWU.GWU_CDTPDC = %Exp:GW1->GW1_CDTPDC%
// 					AND GWU.GWU_EMISDC = %Exp:GW1->GW1_EMISDC%
// 					AND GWU.GWU_SERDC = %Exp:GW1->GW1_SERDC%
// 					AND GWU.GWU_NRDC = %Exp:GW1->GW1_NRDC%
// 					AND GWU.%NotDel%
// 					ORDER BY GWU_SEQ
// 				EndSQL
// 				While (cAliasGWU)->(!EoF())
// 					oMovDocto:setSeqTrecho((cAliasGWU)->GWU_SEQ)
// 					oMovDocto:setTransportador((cAliasGWU)->GWU_CDTRP)
// 					oMovDocto:setNomeTransport(Posicione("GU3", 1, xFilial("GU3")+(cAliasGWU)->GWU_CDTRP, "GU3_NMEMIT"))
// 					oMovDocto:setDataEntrega(StoD((cAliasGWU)->GWU_DTENT))

// 					oMovDocto:IncludeRomaneio()		// Inclusão de Registros na tabela GX0

// 					(cAliasGWU)->(dbSkip())
// 				EndDo
// 				(cAliasGWU)->(dbCloseArea())

// 				(cAliasGW1)->(DbSkip())
// 			EndDo
// 			(cAliasGW1)->(dbCloseArea())

// 		ElseIf nOpc == MODEL_OPERATION_UPDATE
// 			oMovDocto:setBranch(GWN->GWN_FILIAL)
// 			oMovDocto:setFilRomaneio(GWN->GWN_FILIAL)
// 			oMovDocto:setNumRomaneio(GWN->GWN_NRROM)
// 			oMovDocto:setClassFrete(GWN->GWN_CDCLFR)
// 			oMovDocto:setDescClassFrete(Posicione("GUB", 1, xFilial("GUB")+GWN->GWN_CDCLFR, "GUB_DSCLFR"))
// 			oMovDocto:setTipoOper(GWN->GWN_CDTPOP)
// 			oMovDocto:setDescTipoOperacao(Posicione("GV4", 1, xFilial("GV4")+GWN->GWN_CDTPOP, "GV4_DSTPOP"))

// 			// Verifica se todos DCs associados ao romaneio estão na GX0
// 			cAliasGW1 := oMovDocto:SearchDCByRomaneio()
// 			If (cAliasGW1)->(!Eof())
// 				While (cAliasGW1)->(!Eof())
// 					GW1->(dbGoTo( (cAliasGW1)->RECNUM ))

// 					aadd(aAuxGX0, {GW1->GW1_FILIAL, GW1->GW1_CDTPDC, GW1->GW1_EMISDC, GW1->GW1_SERDC, GW1->GW1_NRDC, GW1->GW1_DTEMIS})

// 					oMovDocto:setBranch(GW1->GW1_FILIAL)
// 					oMovDocto:setTipoNF(GW1->GW1_CDTPDC)
// 					oMovDocto:setEmissorNF(GW1->GW1_EMISDC)
// 					oMovDocto:setSerieNF(GW1->GW1_SERDC)
// 					oMovDocto:setNumeroNF(GW1->GW1_NRDC)

// 					cAliasGX0 := oMovDocto:SearchByDC()	// Caso ja exista registro desse DC, atualiza campos referentes ao romaneio.
// 					If (cAliasGX0)->(!EoF())
// 						While (cAliasGX0)->(!EoF()) .And. (cAliasGX0)->GX0_FILIAL == GW1->GW1_FILIAL ;
// 								.And. (cAliasGX0)->GX0_CDTPDC == GW1->GW1_CDTPDC ;
// 								.And. (cAliasGX0)->GX0_EMISDC == GW1->GW1_EMISDC ;
// 								.And. (cAliasGX0)->GX0_SERDC == GW1->GW1_SERDC ;
// 								.And. (cAliasGX0)->GX0_NRDC == GW1->GW1_NRDC
// 							GX0->(dbGoTo( (cAliasGX0)->RECNUM ))
// 							oMovDocto:UpdateRomaneio()		// Alteração de Registros na tabela GX0

// 							(cAliasGX0)->(dbSkip())
// 						EndDo
// 					EndIf
// 					(cAliasGX0)->(dbCloseArea())

// 					(cAliasGW1)->(DbSkip())
// 				EndDo
// 			EndIf
// 			(cAliasGW1)->(dbCloseArea())

// 			// Remove associações que não existem mais
// 			For i := 1 To Len(aAuxDc)
// 				If AScan(aAuxGX0, {|x| x[1] == aAuxDc[i][1] .And. x[2] == aAuxDc[i][2] .And. x[3] == aAuxDc[i][3] .And. x[4] == aAuxDc[i][4] .And. x[5] == aAuxDc[i][5]}) == 0
// 					oMovDocto:setBranch(aAuxDc[i][1])
// 					oMovDocto:setTipoNF(aAuxDc[i][2])
// 					oMovDocto:setEmissorNF(aAuxDc[i][3])
// 					oMovDocto:setSerieNF(aAuxDc[i][4])
// 					oMovDocto:setNumeroNF(aAuxDc[i][5])

// 					cAliasGX0 := oMovDocto:SearchByDC()	// Caso ja exista registro desse DC, atualiza campos referentes ao romaneio.
// 					If (cAliasGX0)->(!EoF())
// 						While (cAliasGX0)->(!EoF()) .And. (cAliasGX0)->GX0_FILIAL == aAuxDc[i][1] ;
// 								.And. (cAliasGX0)->GX0_CDTPDC == aAuxDc[i][2] ;
// 								.And. (cAliasGX0)->GX0_EMISDC == aAuxDc[i][3] ;
// 								.And. (cAliasGX0)->GX0_SERDC == aAuxDc[i][4] ;
// 								.And. (cAliasGX0)->GX0_NRDC == aAuxDc[i][5]

// 							GX0->(dbGoTo( (cAliasGX0)->RECNUM ))
// 							oMovDocto:setBranch(GX0->GX0_FILIAL)
// 							oMovDocto:setTipoNF(GX0->GX0_CDTPDC)
// 							oMovDocto:setEmissorNF(GX0->GX0_EMISDC)
// 							oMovDocto:setSerieNF(GX0->GX0_SERDC)
// 							oMovDocto:setNumeroNF(GX0->GX0_NRDC)
// 							oMovDocto:setFilRomaneio(" ")
// 							oMovDocto:setNumRomaneio(" ")
// 							oMovDocto:setClassFrete(" ")
// 							oMovDocto:setDescClassFrete(" ")
// 							oMovDocto:setTipoOper(" ")
// 							oMovDocto:setDescTipoOperacao(" ")

// 							oMovDocto:UpdateRomaneio()		// Remoção de associação de DC de Registros na tabela GX0

// 							(cAliasGX0)->(dbSkip())
// 						EndDo
// 					EndIf
// 					(cAliasGX0)->(dbCloseArea())
// 				EndIf
// 			Next

// 		ElseIf nOpc == MODEL_OPERATION_DELETE

// 			oMovDocto:setBranch(GWN->GWN_FILIAL)
// 			oMovDocto:setNumRomaneio(GWN->GWN_NRROM)
// 			s_MULFIL   := SuperGetMV("MV_MULFIL",.F.,"2")
// 			If s_MULFIL == "1"
// 				cAliasGX0 := GetNextAlias()
// 				BeginSQL Alias cAliasGX0
// 					SELECT GX0.R_E_C_N_O_ as RECNUM
// 					FROM %Table:GX0% GX0
// 					WHERE GX0.GX0_FILROM = %Exp:GWN->GWN_FILIAL%
// 					AND GX0.GX0_NRROM = %Exp:GWN->GWN_NRROM%
// 					AND GX0.%NotDel%
// 				EndSQL
// 			Else
// 				cAliasGX0 := oMovDocto:SearchByRomaneio()
// 			EndIf

// 			While (cAliasGX0)->(!EoF())
// 				GX0->(dbGoTo( (cAliasGX0)->RECNUM ))
// 				oMovDocto:setBranch(GX0->GX0_FILIAL)
// 				oMovDocto:setTipoNF(GX0->GX0_CDTPDC)
// 				oMovDocto:setEmissorNF(GX0->GX0_EMISDC)
// 				oMovDocto:setSerieNF(GX0->GX0_SERDC)
// 				oMovDocto:setNumeroNF(GX0->GX0_NRDC)
// 				oMovDocto:setFilRomaneio(" ")
// 				oMovDocto:setNumRomaneio(" ")
// 				oMovDocto:setClassFrete(" ")
// 				oMovDocto:setDescClassFrete(" ")
// 				oMovDocto:setTipoOper(" ")
// 				oMovDocto:setDescTipoOperacao(" ")

// 				oMovDocto:UpdateRomaneio()		// Não deleta GX0, apenas remove dados do romaneio nos registros da tabela GX0

// 				(cAliasGX0)->(DbSkip())
// 			EndDo
// 			(cAliasGX0)->(dbCloseArea())
// 		EndIf
// 	EndIf

// 	oMovDocto:Destroy( oMovDocto )
// Return

// Static Function chkFilromaneio()
// 	Local cQuery    := Nil
// 	Local cAliasGW1 := Nil
// 	Local cAliasGWF := Nil

// 	If GFXCP1212210('GW1_FILROM')	// Verifica se existe DC sem o campos GW1_FILROM preenchido caso o campo exista no dicionario de dados
// 		cAliasGW1 := GetNextAlias()
// 		BeginSql Alias cAliasGW1
// 			SELECT GW1.R_E_C_N_O_ AS GW1RECNO
// 			FROM %table:GW1% GW1
// 			WHERE GW1.GW1_FILROM = ' '
// 			AND GW1_NRROM != ' '
// 			AND GW1.%NotDel%
// 		EndSql
// 		If (cAliasGW1)->(!Eof())
// 			cQuery := "UPDATE " + RetSQLName("GW1") + " "
// 			cQuery += " SET GW1_FILROM = GW1_FILIAL"
// 			cQuery += " WHERE GW1_FILROM = ' '"
// 			cQuery += " AND GW1_NRROM != ' '"
// 			cQuery += " AND D_E_L_E_T_ = ' '"
// 			TCSQLExec(cQuery)
// 		EndIf
// 		(cAliasGW1)->(dbCloseArea())
// 	EndIf

// 	If GFXCP1212210('GWF_FILROM')	// Verifica se existe DC sem o campos GWF_FILROM preenchido caso o campo exista no dicionario de dados
// 		cAliasGWF := GetNextAlias()
// 		BeginSql Alias cAliasGWF
// 			SELECT GWF.R_E_C_N_O_ AS GWFRECNO
// 			FROM %table:GWF% GWF
// 			WHERE GWF.GWF_FILROM = ' '
// 			AND GWF_NRROM != ' '
// 			AND GWF.%NotDel%
// 		EndSql
// 		If (cAliasGWF)->(!Eof())
// 			cQuery := "UPDATE " + RetSQLName("GWF") + " "
// 			cQuery += " SET GWF_FILROM = GWF_FILIAL"
// 			cQuery += " WHERE GWF_FILROM = ' '"
// 			cQuery += " AND GWF_NRROM != ' '"
// 			cQuery += " AND D_E_L_E_T_ = ' '"
// 			TCSQLExec(cQuery)
// 		EndIf
// 		(cAliasGWF)->(dbCloseArea())
// 	EndIf
// Return

// Static Function GFECalcCarga(aCargas)
// 	Local nCont       := 0
// 	Local cCodFil     := Nil
// 	Local cNrRom      := Nil
// 	Local cAliasGWN   := Nil
// 	Local lClcAutoOMS := SuperGetMv("MV_CLCCRG",,.F.)	// Parametro para habilitar ou não o calculo do romaneio gerado pelas cargas

// 	If lClcAutoOMS .And. Len(aCargas) > 0
// 		For nCont := 1 To Len(aCargas)
// 			cCodFil := Alltrim(aCargas[nCont][1])
// 			cNrRom  := Alltrim(aCargas[nCont][2]) + Alltrim(aCargas[nCont][3])

// 			cAliasGWN := GetNextAlias()
// 			BeginSql Alias cAliasGWN
// 				SELECT GWN.R_E_C_N_O_ AS GWNRECNO
// 				FROM %table:GWN% GWN
// 				WHERE GWN.GWN_FILIAL = %Exp:cCodFil%
// 				AND GWN.GWN_NRROM = %Exp:cNrRom%
// 				AND GWN.%NotDel%
// 			EndSql
// 			While (cAliasGWN)->(!Eof())
// 				GWN->(DbGoTo( (cAliasGWN)->GWNRECNO ))	// Posiciona no romaneio

// 				GFE050CALC() // Executa o calculo para o romaneio posicionado

// 				(cAliasGWN)->(DbSkip())
// 			EndDo
// 			(cAliasGWN)->(dbCloseArea())
// 		Next
// 	EndIf
// Return

// Static Function GFE50AVLIB(cFilRom, cRom, dDtLib, dHrLib, nHodo, cRastr)
// 	Local lRet			:= .T.
// 	Local cMsg			:= ""
// 	Local cQuery		:= ""
// 	Local cAliasGW1		:= ""
// 	Local lPE04			:= ExistBlock("GFEA05A4")
// 	Local cMV_PLROADE	:= SuperGetMv("MV_PLROADE",.F.,"2")
// 	Local nTipo			:= 0
// 	Local cTitle		:= "SIGAGFE"
// 	Local cSolu			:= ""

// 	If lPE04
// 		aRet := ExecBlock("GFEA05A4",.F.,.F., {cFilRom, cRom, dDtLib, dHrLib, nHodo, cRastr})

// 		If aRet[1] = .F.
// 			lRet 	:= .F.
// 			nTipo 	:= 5
// 			cTitle	:= "GFEA05A4"
// 			cMsg	:= aRet[2] // Mensagem retornada pelo ponto de entrada
// 		EndIf
// 	ElseIf cMV_PLROADE == "2"
// 		cQuery := "SELECT GW1.GW1_NRDC NRDC, GW1.GW1_DTEMIS DTEMIS "
// 		cQuery += " FROM " + RetSQLName("GW1") + " GW1 "
// 		If GFXCP1212210('GW1_FILROM')
// 			cQuery += " WHERE GW1.GW1_FILROM = '" + cFilRom + "'"
// 		Else
// 			cQuery += " WHERE GW1.GW1_FILIAL = '" + cFilRom + "'"
// 		EndIf
// 		cQuery += "   AND GW1.GW1_NRROM = '" + cRom + "'"
// 		cQuery += "   AND GW1.GW1_DTEMIS > '" + DtoS(dDtLib) + "'"
// 		cQuery += "   AND GW1.D_E_L_E_T_ = ' ' "

// 		cAliasGW1 := GetNextAlias()
// 		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasGW1, .F., .T.)

// 		If !(cAliasGW1)->(Eof())
// 			lRet 	:= .F.
// 			nTipo 	:= 5
// 			cTitle	:= GFEA050024
// 			cMsg 	:= "Documento de Carga " + (cAliasGW1)->NRDC + " tem a data de Emissão Maior que a data de saída informada: " + CRLF +;
// 				"Data de Emissão do Documento de Carga: " + Dtoc(Stod((cAliasGW1)->DtEmis)) + CRLF +;
// 				"Data de Saída: " + DtoC(dDtLib)
// 			cMsg	:= GFEMsgFmt("Romaneio não pode ser liberado: [VAR01]", {{"[VAR01]", cMsg}})
// 			cSolu	:= "Informe uma data superior a data de emissão do Documento de Carga."
// 		EndIf

// 		(cAliasGW1)->(dbCloseArea())
// 	EndIf
// Return {lRet, nTipo, cTitle, cMsg, cSolu}

// //gfea050a.prw:
// // SONARQUBE - CA1003: Uso não permitido de chamada de API em LOOP
// Static lPE503		:= ExistBlock("GFEA0503")
// Static lPE505		:= ExistBlock("GFEA05A5")
// Static lPE506		:= ExistBlock("GFEA05A6")
// Static lPE507		:= ExistBlock("GFEA05A7")
// Static lPE508       := ExistBlock("GFEA05A8")
// Static lPE509       := ExistBlock("GFEA05A9")
// Static s_GFETRP
// Static lExiSITFRE

// Static Function GFEA050A(cParamF12)
// 	Local oDlg
// 	Local cDSTRAN
// 	Local aPos
// 	Local aRotAdic := {}
// 	Local oSize
// 	Local oOK := LoadBitmap( GetResources(), "LBOK" )
// 	Local oNO := LoadBitmap( GetResources(), "LBNO" )

// 	aNewButton := {}

// 	Private cCadastro := "Documentos de Carga" //"Documentos de Carga"
// 	Private cMarca    := GetMark()
// 	//Arrays para os rodapés - [1]->Nr Docs,[2]->Peso,[3]->Peso Cub,[4]->Volume,[5]->Valor Merc,[6]->Nr Volumes,[7]->Peso Liq
// 	Private aRdpDC    := {0,0,0,0,0,0,0}
// 	Private aRdpSel   := {0,0,0,0,0,0,0}
// 	Private _lFiltro  := .F.
// 	Private _lChgDocs := .F.	// Indica se houve alteração nos documentos de carga do romaneio
// 	Private oPanelB
// 	Private aDocFil := {} // Documentos de carga Filtrados
// 	Private aDocSel := {} // Documentos de Carga Selecionados
// 	Private nLinSel := 0
// 	Private oBrFil
// 	Private oBrSel
// 	Default cParamF12 := 2 // 1 - Sim 2 - Não

// 	//----------------------------------------------
// 	// Criacao da tabela temporaria p/ Markbrowse  
// 	//---------------------------------------------- 
// 	aMKB := {{"OK"    , "",                   02},;
// 			 {"FILIAL", "Filial",		     04},;
// 			 {"SERIE" , "Serie",              05},;
// 			 {"NRDC"  , "NRDC",              16},;
// 			 {"TPDC"  , "TPDC",              05},;
// 			 {"TPFRET", "Tipo de Frete",      25},;
// 			 {"CDEMIS", "CDEMIS",              TamSx3("GU3_CDEMIT")[1]},;
// 			 {"NMEMIS", "NMEMIS",              30},;
// 			 {"CDREM" , "CDREM",              TamSx3("GU3_CDEMIT")[1]},;
// 			 {"NMREM" , "Nome do Remetente",  30},;
// 			 {"CDDEST", "Liberar",              TamSx3("GU3_CDEMIT")[1]},;
// 			 {"NMDEST", "Nome do Destino",    30},;
// 			 {"NRREG" , "Região",             06},;
// 			 {"NRCID" , "Cidade",             TamSx3("GU3_NRCID")[1]},;
// 			 {"DTEMIS", "Emissão",            30},;
// 			 {"DTSAI" , "Data Saida",         30},;
// 			 {"CIDDES", "Cidade Destino",     TamSx3("GU7_NMCID")[1]},;
// 			 {"UFDEST", "UF Destino",         08}}
// 	s_MULFIL   := SuperGetMV("MV_MULFIL",.F.,"2")
// 	If s_MULFIL == "1"
// 		SetMVValue("GFEA050FIL", "MV_PAR01", '')       				// Filial de ?              
// 		SetMVValue("GFEA050FIL", "MV_PAR02", 'ZZZZZZZZ')    		// Filial até ?             
// 		SetMVValue("GFEA050FIL", "MV_PAR03", '')       				// Serie de ?               
// 		SetMVValue("GFEA050FIL", "MV_PAR04", 'ZZZZZ')       		// Serie até ?              
// 		SetMVValue("GFEA050FIL", "MV_PAR05", '')       				// Numero Docto de ?        
// 		SetMVValue("GFEA050FIL", "MV_PAR06", 'ZZZZZZZZZZZZZZZZ')    // Numero Docto até ?       
// 		SetMVValue("GFEA050FIL", "MV_PAR07", '')       				// Cidade Destino de ?      
// 		SetMVValue("GFEA050FIL", "MV_PAR08", 'ZZZZZZZ')       		// Cidade Destino até ?     
// 		SetMVValue("GFEA050FIL", "MV_PAR09", '')       				// UF de ?                  
// 		SetMVValue("GFEA050FIL", "MV_PAR10", 'ZZ')       			// UF até ?                 
// 		SetMVValue("GFEA050FIL", "MV_PAR11", '')       				// Destinatário de ?        
// 		SetMVValue("GFEA050FIL", "MV_PAR12", 'ZZZZZZZZZZZZZZ')      // Destinatário até ?       
// 		SetMVValue("GFEA050FIL", "MV_PAR13", GWN->GWN_CDTRP)       	// Transportador de ?       
// 		SetMVValue("GFEA050FIL", "MV_PAR14", GWN->GWN_CDTRP)       	// Transportador até ?      
// 		SetMVValue("GFEA050FIL", "MV_PAR15", '')       				// Tipo Docto de ?          
// 		SetMVValue("GFEA050FIL", "MV_PAR16", 'ZZZZZ')       		// Tipo Docto até ?         
// 		SetMVValue("GFEA050FIL", "MV_PAR17", 1)       				// Tipo Frete ?             
// 		SetMVValue("GFEA050FIL", "MV_PAR18", STOD("20000101"))      // Data Prev. Saída de ?    
// 		SetMVValue("GFEA050FIL", "MV_PAR19", Date())      			// Data Prev. Saída até ?   
// 		SetMVValue("GFEA050FIL", "MV_PAR20", STOD("20000101"))      // Data Emissao de ?        
// 		SetMVValue("GFEA050FIL", "MV_PAR21", Date())      			// Data Emissao até ?       
// 		SetMVValue("GFEA050FIL", "MV_PAR22", '')      				// Reg. Comercial de ?      
// 		SetMVValue("GFEA050FIL", "MV_PAR23", 'ZZZZZZZZZZZZ')       	// Reg. Comercial até ? 

// 		Pergunte("GFEA050FIL", .F.)
// 	Else
// 		SetMVValue("GFEA050","MV_PAR01", '')
// 		SetMVValue("GFEA050","MV_PAR02", 'zzzzz')
// 		SetMVValue("GFEA050","MV_PAR03", '')
// 		SetMVValue("GFEA050","MV_PAR04", 'zzzzzzzzzzzzzzzz')
// 		SetMVValue("GFEA050","MV_PAR05", '')
// 		SetMVValue("GFEA050","MV_PAR06", '9999999')
// 		SetMVValue("GFEA050","MV_PAR07", '')
// 		SetMVValue("GFEA050","MV_PAR08", 'zz')
// 		SetMVValue("GFEA050","MV_PAR09", '')
// 		SetMVValue("GFEA050","MV_PAR10", 'zzzzzzzzzzzzzz')
// 		SetMVValue("GFEA050","MV_PAR11", GWN->GWN_CDTRP)
// 		SetMVValue("GFEA050","MV_PAR12", GWN->GWN_CDTRP)
// 		SetMVValue("GFEA050","MV_PAR13", '')
// 		SetMVValue("GFEA050","MV_PAR14", 'zzzzz')
// 		SetMVValue("GFEA050","MV_PAR15", 1)
// 		SetMVValue("GFEA050","MV_PAR16", STOD(""))
// 		SetMVValue("GFEA050","MV_PAR17", STOD('20491231'))
// 		SetMVValue("GFEA050","MV_PAR18", STOD('20000101'))
// 		SetMVValue("GFEA050","MV_PAR19", Date())
// 		SetMVValue("GFEA050","MV_PAR20", '')
// 		SetMVValue("GFEA050","MV_PAR21", 'zzzzzzzzzzzz')

// 		Pergunte("GFEA050", .F.)
// 	EndIf

// 	CursorWait()

// 	//Criação da tela
// 	oSize := FWDefSize():New(.T.)
// 	oSize:AddObject( "ENCHOICE", 100, 60, .T., .T. ) // Adiciona enchoice
// 	oSize:lLateral     := .F.  // Calculo vertical	
// 	oSize:Process() //executa os calculos

// 	aPos := {oSize:GetDimension("ENCHOICE","LININI"),; 
// 	oSize:GetDimension("ENCHOICE","COLINI"),;
// 	oSize:GetDimension("ENCHOICE","XSIZE"),;
// 	oSize:GetDimension("ENCHOICE","YSIZE")}

// 	//----- Processa os registros e carrega os browses -----//
// 	If cParamF12 == 1 //Exibe tela de filtro antes da abertura do programa
// 		GFE050AFIL(.F.)
// 	EndIf
// 	Processa({|lEnd| GFE050AMB()},"Região Demais Cidades ou Inativa","Não é possivel incluir Cidade ou CEP") //"Processando informações"###"Aguarde"
// 	CursorArrow()

// 	DEFINE MSDIALOG oDlg TITLE cCadastro ;
// 	FROM oSize:aWindSize[1],oSize:aWindSize[2] ;
// 	TO oSize:aWindSize[3],oSize:aWindSize[4] ; 
// 	Of oMainWnd COLORS 0, 16777215 PIXEL	

// 	oDlg:lEscClose := .F.

// 	oPnlCnt := tPanel():New(aPos[1],aPos[2],,oDlg,,,,,,aPos[3],aPos[4],.F.,.F.)
// 	//----- Painel superior da tela principal, com as informacoes do romaneio -----//
// 	oPnlA := tPanel():New(00,00,,oPnlCnt,,,,,,10,20,.F.,.F.)
// 	oPnlA:Align := CONTROL_ALIGN_TOP

// 	//----- Splitter para permitir ao usuario movimentar os paineis dos browses -----//	
// 	oSplitter := tSplitter():New( 0,0,oPnlCnt,80,80,1 ) 
// 	oSplitter:Align := CONTROL_ALIGN_ALLCLIENT

// 	//----- Painel superior da tela, para o browse de documentos de cargas -----//
// 	oPanelB := TPanel():New(01,01,,oSplitter,,,,,,0,0,.F.,.T.)
// 	oPanelB:Align := CONTROL_ALIGN_TOP

// 	//----- Painel lateral do browse de documentos relacionados, para adicionar botoes -----//
// 	oPnlBtn1:=TPanel():New(00,00,,oPanelB,,,,,RGB(67,70,87),15,15,.F.,.F.)
// 	oPnlBtn1:Align := CONTROL_ALIGN_LEFT

// 	//------ Botao para adicionar relacionamento do Documento de carga com o romaneio -----//
// 	oBtnAdd  := TBtnBmp():NewBar("PMSSETADOWN","PMSSETADOWN",,,,{||GFEA50AOK()},,oPnlBtn1,,,"",,,,,"")
// 	oBtnAdd:cToolTip := "Adicionar" //"Adicionar"
// 	oBtnAdd:Align    := CONTROL_ALIGN_TOP

// 	//------ Botao para Filtro do Documento de carga com o romaneio -----//			
// 	oBtnFiltro			:= TBtnBmp():NewBar("brw_filtro","brw_filtro",,,,{|| GFE050AFIL(.T.,oBrFil)},,oPnlBtn1,,,"",,,,,"")
// 	oBtnFiltro:cToolTip := "Entrega" //"Filtrar"
// 	oBtnFiltro:Align    := CONTROL_ALIGN_TOP

// 	//Botão para selecionar todos os documentos de carga
// 	oBtnChk := TBtnBmp():NewBar("CHECKED","CHECKED",,,,{||GFEA50ACHK(1, @aDocFil)},,oPnlBtn1,,,"",,,,,"")
// 	oBtnChk:cToolTip := "Marca todos os documentos de carga em tela" //"Marca todos os documentos de carga em tela"
// 	oBtnChk:Align    := CONTROL_ALIGN_TOP

// 	//Botão para desselecionar todos os documentos de carga
// 	oBtnDChk := TBtnBmp():NewBar("UNCHECKED","UNCHECKED",,,,{||GFEA50ACHK(2, @aDocFil)},,oPnlBtn1,,,"",,,,,"")
// 	oBtnDChk:cToolTip := "Deseja recalcular este romaneio?" //"Desmarca todos os documentos de carga em tela"
// 	oBtnDChk:Align    := CONTROL_ALIGN_TOP

// 	//-----Painel inferior com o rodapé---//

// 	oPanelE := TPanel():New(00,00,,oPanelB,,,,,RGB(67,70,87),12,18,.F.,.F.)
// 	oPanelE:Align := CONTROL_ALIGN_BOTTOM 

// 	oSayRdp := tSay():New(05,18 ,{||"Deseja cancelar esse processo?"},oPanelE,,TFont():New('Arial',,-12,,.T.),,,,.T.,CLR_WHITE,CLR_WHITE,100,20) //"Nr Docs:"
// 	oSayRdp := tSay():New(05,103,{||"Data entrega menor que data de liberação"},oPanelE,,TFont():New('Arial',,-12,,.T.),,,,.T.,CLR_WHITE,CLR_WHITE,100,20) //"Peso:"
// 	oSayRdp := tSay():New(05,179,{||"Peso Liq:"},oPanelE,,TFont():New('Arial',,-12,,.T.),,,,.T.,CLR_WHITE,CLR_WHITE,100,20) //
// 	oSayRdp := tSay():New(05,263,{||"Peso Cub:"},oPanelE,,TFont():New('Arial',,-12,,.T.),,,,.T.,CLR_WHITE,CLR_WHITE,100,20) //"Peso Cub:"
// 	oSayRdp := tSay():New(05,350,{||"Volume:"},oPanelE,,TFont():New('Arial',,-12,,.T.),,,,.T.,CLR_WHITE,CLR_WHITE,100,20) //"Volume:"
// 	oSayRdp := tSay():New(05,432,{||"Valor Merc:"},oPanelE,,TFont():New('Arial',,-12,,.T.),,,,.T.,CLR_WHITE,CLR_WHITE,100,20) //"Valor Merc:"
// 	oSayRdp := tSay():New(05,524,{||"Nr Volumes:"},oPanelE,,TFont():New('Arial',,-12,,.T.),,,,.T.,CLR_WHITE,CLR_WHITE,100,20) //"Nr Volumes:"

// 	oGetRdp1 := TGet():New(04,46 ,{|u| If(PCount()>0,aRdpDC[1]:=u,aRdpDC[1])},oPanelE,50,8,'999999999'        ,,,,,,,.T.,,,{|| .F.},,,,,,,"aRdpDC[1]",,,,,.T.,.T.)
// 	oGetRdp2 := TGet():New(04,122,{|u| If(PCount()>0,aRdpDC[2]:=u,aRdpDC[2])},oPanelE,50,8,'999,999,999.99999',,,,,,,.T.,,,{|| .F.},,,,,,,"aRdpDC[2]",,,,,.T.,.T.)
// 	oGetRdp7 := TGet():New(04,208,{|u| If(PCount()>0,aRdpDC[7]:=u,aRdpDC[7])},oPanelE,50,8,'999,999,999.99999',,,,,,,.T.,,,{|| .F.},,,,,,,"aRdpDC[7]",,,,,.T.,.T.)
// 	oGetRdp3 := TGet():New(04,294,{|u| If(PCount()>0,aRdpDC[3]:=u,aRdpDC[3])},oPanelE,50,8,'999,999,999.99999',,,,,,,.T.,,,{|| .F.},,,,,,,"aRdpDC[3]",,,,,.T.,.T.)
// 	oGetRdp4 := TGet():New(04,375,{|u| If(PCount()>0,aRdpDC[4]:=u,aRdpDC[4])},oPanelE,50,8,'999,999,999.99999',,,,,,,.T.,,,{|| .F.},,,,,,,"aRdpDC[4]",,,,,.T.,.T.)
// 	oGetRdp5 := TGet():New(04,468,{|u| If(PCount()>0,aRdpDC[5]:=u,aRdpDC[5])},oPanelE,50,8,'999,999,999.99'   ,,,,,,,.T.,,,{|| .F.},,,,,,,"aRdpDC[5]",,,,,.T.,.T.)
// 	oGetRdp6 := TGet():New(04,561,{|u| If(PCount()>0,aRdpDC[6]:=u,aRdpDC[6])},oPanelE,50,8,'999999999'        ,,,,,,,.T.,,,{|| .F.},,,,,,,"aRdpDC[6]",,,,,.T.,.T.)

// 	//----- Painel superior do browse de documentos de carga, para colocar o titulo -----//
// 	oPnlBtn:=TPanel():New(00,00,,oPanelB,,,,,RGB(67,70,87),12,12,.F.,.F.)
// 	oPnlBtn:Align := CONTROL_ALIGN_TOP
// 	oFont12B := TFont():New('Arial',,-12,,.T.)
// 	@ 03,14  Say "Selecione Documentos de Carga " Of oPnlBtn COLOR CLR_WHITE Pixel font oFont12B  //"Selecione Documentos de Carga " 

// 	//---------------- Fim do painel superior da tela ------------------//

// 	//----- Painel inferior da tela, para o browse de documentos relacionados -----//
// 	oPanelC := TPanel():New(01,01,,oSplitter,,,,,,0,0,.F.,.T.)
// 	oPanelC:Align := CONTROL_ALIGN_BOTTOM

// 	//----- Painel lateral do browse de documentos relacionados, para adicionar botoes -----//
// 	oPnlBtn2:=TPanel():New(00,00,,oPanelC,,,,,RGB(67,70,87),15,16,.F.,.F.)
// 	oPnlBtn2:Align := CONTROL_ALIGN_LEFT

// 	SetKey(VK_F8,{||GFE50DELDC()})
// 	//------ Botao para excluir relacionamento do Documento de carga com o romaneio -----//			
// 	oBtnDel  := TBtnBmp():NewBar("PMSSETAUP","PMSSETAUP",,,,{||GFE50DELDC()},,oPnlBtn2,,,"",,,,,"")
// 	oBtnDel:cToolTip := "Excluir" //"Excluir"
// 	oBtnDel:Align    := CONTROL_ALIGN_TOP

// 	SetKey(VK_F9,{||GFEA050ADC()})
// 	//Adiciona documento de carga
// 	oBtnAddDC		  := TBtnBmp():NewBar("BMPINCLUIR","BMPINCLUIR",,,,{||GFEA050ADC()},,oPnlBtn2,,,"",,,,,"")
// 	oBtnAddDC:cToolTip := "Localiza e adiciona documentos de carga.(Abrir - F9|Adicionar - F10)"
// 	oBtnAddDC:Align    := CONTROL_ALIGN_TOP

// 	//------ Botao para visualizar Documento de carga  -----// 
// 	oBtnVis  := TBtnBmp():NewBar("bmpvisual","bmpvisual",,,,{||GFE050AVIS()},,oPnlBtn2,,,"",,,,,"")
// 	oBtnVis:cToolTip := "Doc. Carga" //"Visualzar"
// 	oBtnVis:Align    := CONTROL_ALIGN_TOP

// 	//------ Botao para simular Trechos  -----// 
// 	oBtnCalc		  := TBtnBmp():NewBar("SIMULACAO","SIMULACAO",,,,{||GFEA50ACL()},,oPnlBtn2,,,"",,,,,"")
// 	oBtnCalc:cToolTip := "Simular Calculo" //"Simular Calculo"
// 	oBtnCalc:Align    := CONTROL_ALIGN_TOP

// 	If lPE508
// 		ExecBlock("GFEA05A8",.f.,.f.,{oPnlBtn2, oBtnCalc})
// 	Endif

// 	//----- Painel superior do browse de documentos relacionados, para colocar o titulo -----//	
// 	oPnlBtn3:=TPanel():New(00,00,,oPanelC,,,,,RGB(67,70,87),12,12,.F.,.F.)
// 	oPnlBtn3:Align := CONTROL_ALIGN_TOP
// 	oFont12B := TFont():New('Arial',,-12,,.T.)
// 	@ 03,14  Say "Documentos de Carga Relacionados " Of oPnlBtn3 COLOR CLR_WHITE Pixel font oFont12B 	 //"Documentos de Carga Relacionados "
// 	//--------------- Fim do painel inferior da tela principal-----------------------//

// 	//--------StatusBar onde serão apresentados os valores totais referente aos documentos de carga relacionados--------------------//
// 	oPanelD := TPanel():New(00,00,,oPanelC,,,,,RGB(67,70,87),12,18,.F.,.F.)
// 	oPanelD:Align := CONTROL_ALIGN_BOTTOM 

// 	oSayRdp := tSay():New(05,18 ,{||"Deseja cancelar esse processo?"},oPanelD,,TFont():New('Arial',,-12,,.T.),,,,.T.,CLR_WHITE,CLR_WHITE,100,20) //"Nr Docs:"
// 	oSayRdp := tSay():New(05,103,{||"Data entrega menor que data de liberação"},oPanelD,,TFont():New('Arial',,-12,,.T.),,,,.T.,CLR_WHITE,CLR_WHITE,100,20) //"Peso:"
// 	oSayRdp := tSay():New(05,179,{||"Peso Liq:"},oPanelD,,TFont():New('Arial',,-12,,.T.),,,,.T.,CLR_WHITE,CLR_WHITE,100,20) //
// 	oSayRdp := tSay():New(05,263,{||"Peso Cub:"},oPanelD,,TFont():New('Arial',,-12,,.T.),,,,.T.,CLR_WHITE,CLR_WHITE,100,20) //"Peso Cub:"
// 	oSayRdp := tSay():New(05,350,{||"Volume:"},oPanelD,,TFont():New('Arial',,-12,,.T.),,,,.T.,CLR_WHITE,CLR_WHITE,100,20) //"Volume:"
// 	oSayRdp := tSay():New(05,432,{||"Valor Merc:"},oPanelD,,TFont():New('Arial',,-12,,.T.),,,,.T.,CLR_WHITE,CLR_WHITE,100,20) //"Valor Merc:"
// 	oSayRdp := tSay():New(05,524,{||"Nr Volumes:"},oPanelD,,TFont():New('Arial',,-12,,.T.),,,,.T.,CLR_WHITE,CLR_WHITE,100,20) //"Nr Volumes:"

// 	oGetRdp := TGet():New(04,46 ,{|u| If(PCount()>0,aRdpSel[1]:=u,aRdpSel[1])},oPanelD,50,8,'999999999'           ,,,,,,,.T.,,,{|| .F.},,,,,,,"aRdpSel[1]",,,,,.T.,.T.)
// 	oGetRdp := TGet():New(04,122,{|u| If(PCount()>0,aRdpSel[2]:=u,aRdpSel[2])},oPanelD,50,8,'@E 999,999,999.99999',,,,,,,.T.,,,{|| .F.},,,,,,,"aRdpSel[2]",,,,,.T.,.T.)
// 	oGetRdp := TGet():New(04,208,{|u| If(PCount()>0,aRdpSel[7]:=u,aRdpSel[7])},oPanelD,50,8,'@E 999,999,999.99999',,,,,,,.T.,,,{|| .F.},,,,,,,"aRdpSel[7]",,,,,.T.,.T.)
// 	oGetRdp := TGet():New(04,294,{|u| If(PCount()>0,aRdpSel[3]:=u,aRdpSel[3])},oPanelD,50,8,'@E 999,999,999.99999',,,,,,,.T.,,,{|| .F.},,,,,,,"aRdpSel[3]",,,,,.T.,.T.)
// 	oGetRdp := TGet():New(04,375,{|u| If(PCount()>0,aRdpSel[4]:=u,aRdpSel[4])},oPanelD,50,8,'@E 999,999,999.99999',,,,,,,.T.,,,{|| .F.},,,,,,,"aRdpSel[4]",,,,,.T.,.T.)
// 	oGetRdp := TGet():New(04,468,{|u| If(PCount()>0,aRdpSel[5]:=u,aRdpSel[5])},oPanelD,50,8,'@E 999,999,999.99'   ,,,,,,,.T.,,,{|| .F.},,,,,,,"aRdpSel[4]",,,,,.T.,.T.)
// 	oGetRdp := TGet():New(04,561,{|u| If(PCount()>0,aRdpSel[6]:=u,aRdpSel[6])},oPanelD,50,8,'999999999'           ,,,,,,,.T.,,,{|| .F.},,,,,,,"aRdpSel[6]",,,,,.T.,.T.)	

// 	//--------Fim do Statusbar

// 	// ----- Criacao dos fields referente ao romaneio no painel superior da tela principal -----//
// 	cDSTRAN := posicione("GU3",1,xFilial("GU3")+GWN->GWN_CDTRP,"GU3_NMEMIT")	
// 	@ 07,10  Say "Romaneio não está liberado" Of oPnlA COLOR CLR_BLACK Pixel //"Filial: "
// 	@ 05,25  MSGET GWN->GWN_FILIAL Picture "@!" Of oPnlA When .F. SIZE 40,10  Pixel

// 	@ 07,72  Say "Informe motivo da reabertura" Of oPnlA COLOR CLR_BLACK Pixel //"Romaneio: "
// 	@ 05,102  MSGET GWN->GWN_NRROM Picture "@!" Of oPnlA When .F. SIZE 55,10   Pixel  			

// 	@ 07,167 Say "Não é possível bloquear romaneio"            Of oPnlA COLOR CLR_BLACK Pixel //"Transportadora: "
// 	@ 05,212 MSGET GWN->GWN_CDTRP  Picture "@!" Of oPnlA When .F.  SIZE 80,10  Pixel 			
// 	@ 05,300 MSGET cDSTRAN Picture "@!" Of oPnlA When .F. SIZE 180,10  Pixel 			                                                                                                                                                                      
// 	//---------Fim da criacao dos fields ----------//

// 	//--1----- Seleciona a temp-table de Documentos de cargas que nao foram relacionados ao romaneio e cria o browse -----// 	
// 	oBrFil := TWBrowse():New( 01 , 01, 260,184,,;
// 	{aMKB[01,02], aMKB[02,02], aMKB[03,02], aMKB[04,02], aMKB[05,02], aMKB[06,02], aMKB[07,02], aMKB[08,02], aMKB[09,02],;
// 	 aMKB[10,02], aMKB[11,02], aMKB[12,02], aMKB[13,02], aMKB[14,02], aMKB[15,02], aMKB[16,02], aMKB[17,02], aMKB[18,02]},;  //Descrição das colunas
// 	{aMKB[01,03], aMKB[02,03], aMKB[03,03], aMKB[04,03], aMKB[05,03], aMKB[06,03], aMKB[07,03], aMKB[08,03], aMKB[09,03],;
// 	 aMKB[10,03], aMKB[11,03], aMKB[12,03], aMKB[13,03], aMKB[14,03], aMKB[15,03], aMKB[16,03], aMKB[17,03], aMKB[18,03]},;  //Colunas da tabela
// 	oPanelB,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )    
// 	oBrFil:Align := CONTROL_ALIGN_ALLCLIENT 
// 	oBrFil:SetArray(aDocFil)
// 	oBrFil:bLine := {||{	IIF(len(aDocFil)>0,IIF(aDocFil[oBrFil:nAt,01],oOK,oNO),), ;
// 	IIF(len(aDocFil)>0,aDocFil[oBrFil:nAt,02],''), IIF(len(aDocFil)>0,aDocFil[oBrFil:nAt,03],''), ;
// 	IIF(len(aDocFil)>0,aDocFil[oBrFil:nAt,04],''), IIF(len(aDocFil)>0,aDocFil[oBrFil:nAt,05],''), ;
// 	IIF(len(aDocFil)>0,aDocFil[oBrFil:nAt,06],''), IIF(len(aDocFil)>0,aDocFil[oBrFil:nAt,07],''), ;
// 	IIF(len(aDocFil)>0,aDocFil[oBrFil:nAt,08],''), IIF(len(aDocFil)>0,aDocFil[oBrFil:nAt,09],''), ;
// 	IIF(len(aDocFil)>0,aDocFil[oBrFil:nAt,10],''), IIF(len(aDocFil)>0,aDocFil[oBrFil:nAt,11],''), ;
// 	IIF(len(aDocFil)>0,aDocFil[oBrFil:nAt,12],''), IIF(len(aDocFil)>0,aDocFil[oBrFil:nAt,13],''), ;    
// 	IIF(len(aDocFil)>0,aDocFil[oBrFil:nAt,14],''), IIF(len(aDocFil)>0,aDocFil[oBrFil:nAt,15],''), ;
// 	IIF(len(aDocFil)>0,aDocFil[oBrFil:nAt,16],''), IIF(len(aDocFil)>0,aDocFil[oBrFil:nAt,17],''),;
// 	IIF(len(aDocFil)>0,aDocFil[oBrFil:nAt,18],'')}}      
// 	// Troca a imagem no duplo click do mouse 
// 	oBrFil:bLDblClick := {|| ArmazPos1 := oBrFil:nAt, GFEA50AD(ArmazPos1), oBrFil:Refresh()}
// 	oBrFil:bChange := {|| oBrFil:Refresh()}
// 	oBrFil:bHeaderClick :=  {|| GFEA50ACHK(3, @aDocFil), oBrFil:Refresh()}
// 	//--------------Fim 1 -- criado o browse---------------//

// 	//--2----- Seleciona a temp-table de Documentos de cargas que ja foram relacionados ao romaneio e cria o browse -----// 
// 	oBrSel := TWBrowse():New( 01 , 01, 260,184,,;
// 	{aMKB[01,02], aMKB[02,02], aMKB[03,02], aMKB[04,02], aMKB[05,02], aMKB[06,02], aMKB[07,02], aMKB[08,02], aMKB[09,02],;
// 	 aMKB[10,02], aMKB[11,02], aMKB[12,02], aMKB[13,02], aMKB[14,02], aMKB[15,02], aMKB[16,02], aMKB[17,02], aMKB[18,02]},;  //Descrição das colunas
// 	{aMKB[01,03], aMKB[02,03], aMKB[03,03], aMKB[04,03], aMKB[05,03], aMKB[06,03], aMKB[07,03], aMKB[08,03], aMKB[09,03],;
// 	 aMKB[10,03], aMKB[11,03], aMKB[12,03], aMKB[13,03], aMKB[14,03], aMKB[15,03], aMKB[16,03], aMKB[17,03], aMKB[18,03]},;  //Colunas da tabela
// 	oPanelC,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )    
// 	oBrSel:Align := CONTROL_ALIGN_ALLCLIENT 
// 	oBrSel:SetArray(aDocSel)
// 	oBrSel:bLine := {||{	IIF(len(aDocSel)>0,IIF(aDocSel[oBrSel:nAt,01],oOK,oNO),), ;
// 	IIF(len(aDocSel)>0,aDocSel[oBrSel:nAt,02],''), IIF(len(aDocSel)>0,aDocSel[oBrSel:nAt,03],''), ;
// 	IIF(len(aDocSel)>0,aDocSel[oBrSel:nAt,04],''), IIF(len(aDocSel)>0,aDocSel[oBrSel:nAt,05],''), ;
// 	IIF(len(aDocSel)>0,aDocSel[oBrSel:nAt,06],''), IIF(len(aDocSel)>0,aDocSel[oBrSel:nAt,07],''), ;
// 	IIF(len(aDocSel)>0,aDocSel[oBrSel:nAt,08],''), IIF(len(aDocSel)>0,aDocSel[oBrSel:nAt,09],''), ;
// 	IIF(len(aDocSel)>0,aDocSel[oBrSel:nAt,10],''), IIF(len(aDocSel)>0,aDocSel[oBrSel:nAt,11],''), ;
// 	IIF(len(aDocSel)>0,aDocSel[oBrSel:nAt,12],''), IIF(len(aDocSel)>0,aDocSel[oBrSel:nAt,13],''), ;    
// 	IIF(len(aDocSel)>0,aDocSel[oBrSel:nAt,14],''), IIF(len(aDocSel)>0,aDocSel[oBrSel:nAt,15],''), ;
// 	IIF(len(aDocSel)>0,aDocSel[oBrSel:nAt,16],''), IIF(len(aDocSel)>0,aDocSel[oBrSel:nAt,17],''),;
// 	IIF(len(aDocSel)>0,aDocSel[oBrSel:nAt,18],'')}}  
// 	// Troca a imagem no duplo click do mouse 
// 	oBrSel:bLDblClick := {|| ArmazPos2 := oBrSel:nAt, GFEA50AE(ArmazPos2), oBrSel:Refresh()}
// 	oBrSel:bChange := {|| nLinSel := oBrSel:nAt}
// 	oBrSel:bHeaderClick :=  {|| GFEA50ACHK(4, @aDocSel), oBrSel:Refresh()}

// 	//--------------Fim 2--------------------//
// 	// Ponto de entrada que permite incluir opções adicionais
// 	// no menu padrão da rotina de vinculo de Doc Carga x Romaneio

// 	If ExistBlock("GFEA05A3")
// 		aRotAdic := ExecBlock("GFEA05A3",.f.,.f.)
// 		If ValType(aRotAdic) == "A"
// 			AEval(aRotAdic, {|x| AAdd(aNewButton ,x)})
// 		EndIf
// 	EndIf 

// 	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(ODlg,{||If(GFEA50AOK(.T.),ODlg:End(),NIL)},;
// 	{||ODlg:End()},,aNewButton,/*nRecno*/,/*cAlias*/,/*lMashups*/,/*lImpCad*/, /*lPadrao*/, .F. /*lHasOK*/) CENTERED

// 	//------ Limpa as tabelas temporarias -----//
// 	IIF(aDocFil==NIL,,aSize(aDocFil,0))
// 	aDocFil := Nil
// 	IIF(aDocSel==NIL,,aSize(aDocSel,0))
// 	aDocSel := Nil
// 	IIF(aRdpSel==NIL,,aSize(aRdpSel,0))
// 	aRdpSel := Nil
// 	IIF(oBrFil==NIL,,aSize(oBrFil,0))
// 	oBrFil := Nil
// 	IIF(oBrSel==NIL,,aSize(oBrSel,0))
// 	oBrSel := Nil
// 	//-----------------------------------------//

// 	SetKey(VK_F9,{||})
// 	SetKey(VK_F8,{||})

// Return _lChgDocs

// Static Function GFE050AMB()
// 	Local cTrpIni := ""
// 	Local cTrpFim := ""

// 	cQuery := "SELECT GW1.GW1_FILIAL FILIAL, GW1.GW1_SERDC SERIE, GW1.GW1_NRDC NRDC, GW1.GW1_CDTPDC TPDC, "
// 	cQuery += GFEA66CASE("GW1", "GW1_TPFRET", "TPFRET", "''") + ", "
// 	cQuery += "      	GW1.GW1_EMISDC CDEMIS, GU3EMI.GU3_NMEMIT NMEMIS, GW1.GW1_CDREM CDREM, "
// 	cQuery += "		GU3REM.GU3_NMEMIT NMREM, GW1.GW1_CDDEST CDDEST, GU3DES.GU3_NMEMIT NMDEST, GW1.GW1_NRREG NRREG, "
// 	cQuery += "		GW1.GW1_DTEMIS DTEMIS, GW1.GW1_DTPSAI DTSAI, "
// 	cQuery += "		(CASE GW1.GW1_ENTNRC "
// 	cQuery += "			WHEN '' THEN GU3DES.GU3_NRCID"
// 	cQuery += "	   		ELSE GW1.GW1_ENTNRC "
// 	cQuery += " 		END) NRCID, "
// 	cQuery += "		(CASE GW1.GW1_ENTNRC "
// 	cQuery += "			WHEN '' THEN GU7DEST.GU7_NMCID"
// 	cQuery += "	   		ELSE GU7DOC.GU7_NMCID "
// 	cQuery += " 		END) CIDDES, "
// 	cQuery += "		(CASE GW1.GW1_ENTNRC "
// 	cQuery += "			WHEN '' THEN GU7DEST.GU7_CDUF"
// 	cQuery += "	   		ELSE GU7DOC.GU7_CDUF "
// 	cQuery += " 		END) UFDEST, "	
// 	cQuery += " 		GW1.GW1_QTVOL "	
// 	cQuery += "FROM " + RetSQLName("GW1") + " GW1 "
// 	cQuery += "INNER JOIN " + RetSQLName("GU3") + " GU3EMI ON GU3EMI.GU3_FILIAL = '" + xFilial("GU3") + "' AND GU3EMI.GU3_CDEMIT = GW1.GW1_EMISDC AND GU3EMI.D_E_L_E_T_ = ' ' "
// 	cQuery += "INNER JOIN " + RetSQLName("GU3") + " GU3REM ON GU3REM.GU3_FILIAL = '" + xFilial("GU3") + "' AND GU3REM.GU3_CDEMIT = GW1.GW1_CDREM  AND GU3REM.D_E_L_E_T_ = ' ' "
// 	cQuery += "INNER JOIN " + RetSQLName("GU3") + " GU3DES ON GU3DES.GU3_FILIAL = '" + xFilial("GU3") + "' AND GU3DES.GU3_CDEMIT = GW1.GW1_CDDEST AND GU3DES.D_E_L_E_T_ = ' ' "
// 	If _lFiltro
// 		cQuery += "INNER JOIN " + RetSQLName("GU7") + " GU7 ON GU7.GU7_FILIAL = '" + xFilial("GU7") + "' AND GU7.GU7_NRCID = GU3DES.GU3_NRCID AND GU7.D_E_L_E_T_ = ' ' "
// 	EndIf
// 	cQuery += "INNER JOIN " + RetSQLName("GV5") + " GV5 ON GV5.GV5_FILIAL = '" + xFilial("GV5") + "' AND GV5.GV5_CDTPDC = GW1.GW1_CDTPDC AND GV5.D_E_L_E_T_ = ' ' "
// 	cQuery += "INNER JOIN " + RetSQLName("GWU") + " GWU ON GWU.GWU_FILIAL = GW1.GW1_FILIAL AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC AND "
// 	cQuery += "		GWU.GWU_EMISDC = GW1.GW1_EMISDC AND GWU.GWU_SERDC = GW1.GW1_SERDC AND GWU.GWU_NRDC = GW1.GW1_NRDC AND GWU.GWU_SEQ = '01' "
// 	cQuery += "INNER JOIN " + RetSQLName("GV4") + " GV4 ON GV4.GV4_FILIAL = '" + xFilial("GV4") + "' AND GV4.GV4_CDTPOP = '" + GWN->GWN_CDTPOP + "'"
// 	cQuery += "LEFT JOIN " + RetSQLName("GU7") + " GU7DEST ON GU7DEST.GU7_FILIAL = '" + xFilial("GU7") + "' AND GU7DEST.GU7_NRCID = GU3DES.GU3_NRCID AND GU7DEST.D_E_L_E_T_ = ' ' "
// 	cQuery += "LEFT JOIN " + RetSQLName("GU7") + " GU7DOC ON GU7DOC.GU7_FILIAL = '" + xFilial("GU7") + "' AND GU7DOC.GU7_NRCID = GW1.GW1_ENTNRC AND GU7DOC.D_E_L_E_T_ = ' ' "
// 	cQuery += "WHERE GW1.D_E_L_E_T_ = ' ' "
// 	cQuery += "  AND GW1.GW1_SIT = '3'  "
// 	cQuery += "  AND (GW1.GW1_NRROM = '' OR GW1.GW1_NRROM = '0') " 
// 	cQuery += "  AND (GV5.GV5_SENTID = GV4.GV4_SENTID OR GV4.GV4_SENTID = '0') "
// 	cQuery += "  AND GV4.D_E_L_E_T_ = ' ' "
// 	cQuery += "  AND GWU.D_E_L_E_T_ = ' ' "
// 	s_MULFIL   := SuperGetMV("MV_MULFIL",.F.,"2")
// 	If s_MULFIL == "2"
// 		cQuery += "AND GW1.GW1_FILIAL = '" + GWN->GWN_FILIAL + "' "
// 	EndIf
	
// 	If s_MULFIL == "1"
// 		If _lFiltro
// 			cQuery += "AND GW1.GW1_FILIAL >= '" + MV_PAR01 + "' AND GW1.GW1_FILIAL <= '" + MV_PAR02 + "' "
// 			cQuery += "AND GW1.GW1_SERDC >= '" + MV_PAR03 + "' AND GW1.GW1_SERDC <= '" + MV_PAR04 + "' " //Série
// 			cQuery += "AND GW1.GW1_NRDC >= '" + MV_PAR05 + "' AND GW1.GW1_NRDC <= '" + MV_PAR06 + "' " //Número
// 			If MV_PAR17 == 2
// 				cQuery += " AND (GW1.GW1_TPFRET = '1' OR GW1.GW1_TPFRET = '2') " //Doc. Carga CIF ou CIF Redesp.
// 			ElseIf MV_PAR17 == 3
// 				cQuery += " AND (GW1.GW1_TPFRET = '3' OR GW1.GW1_TPFRET = '4') " //Doc. Carga FOB ou FOB Redesp.
// 			EndIf
// 			cQuery += "AND ((GU3DES.GU3_NRCID >= '" + MV_PAR07 + "' AND GU3DES.GU3_NRCID <= '" + MV_PAR08 + "' AND GW1.GW1_ENTNRC = '') OR "
// 			cQuery += "(GW1.GW1_ENTNRC >= '" + MV_PAR07 + "' AND GW1.GW1_ENTNRC <= '" + MV_PAR08 + "' AND GW1.GW1_ENTNRC <> ''))" //Cidade

// 			cQuery += "AND GU7.GU7_CDUF >= '" + MV_PAR09 + "' AND GU7.GU7_CDUF <= '" + MV_PAR10 + "' " //UF
// 			cQuery += "AND GW1.GW1_CDDEST >= '" + MV_PAR11 + "' AND GW1.GW1_CDDEST <= '" + MV_PAR12 + "' " //Destinatário
// 		EndIf

// 		/*
// 		Verifica se o parâmetro MV_GFETRP -> Transportador de Início e fim = Ao Transportador do Romaneio
// 		Ou se o Filtro não está sendo aplicado. 
// 		*Se verdadeiro atribui o valor do transportador do romaneio para busca.
// 		*Se falso atribui o valor dos transportadores informados no pergunte.
// 		*/
// 		s_GFETRP		:= SuperGetMv("MV_GFETRP",.F.,"1")
// 		If s_GFETRP == "2" .OR. !_lFiltro
// 			cTrpIni := GWN->GWN_CDTRP
// 			cTrpFim := GWN->GWN_CDTRP
// 		Else
// 			cTrpIni := MV_PAR13
// 			cTrpFim := MV_PAR14
// 		EndIf

// 		cQuery += "AND GWU.GWU_CDTRP >= '" + cTrpIni + "' AND GWU.GWU_CDTRP <= '" + cTrpFim + "' " //Transportador do Trecho

// 		If _lFiltro
// 			cQuery += "AND GW1.GW1_CDTPDC >= '" + MV_PAR15 + "' AND GW1.GW1_CDTPDC <= '" + MV_PAR16 + "' " //Tipo de Documento de Carga
// 			cQuery += "AND GW1.GW1_DTPSAI >= '" + DToS(MV_PAR18) + "' AND GW1.GW1_DTPSAI <= '" + DToS(MV_PAR19) + "' " //Data de Saída
// 			cQuery += "AND GW1.GW1_DTEMIS >= '" + DToS(MV_PAR20) + "' AND GW1.GW1_DTEMIS <= '" + DToS(MV_PAR21) + "' " //Data de Emissão
// 			cQuery += "AND GW1.GW1_REGCOM >= '" + MV_PAR22 + "' AND GW1.GW1_REGCOM <= '" + MV_PAR23 + "' " //Região comercial
// 		EndIf
// 	Else
// 		If _lFiltro
// 			cQuery += "AND GW1.GW1_SERDC >= '" + MV_PAR01 + "' AND GW1.GW1_SERDC <= '" + MV_PAR02 + "' " //Série
// 			cQuery += "AND GW1.GW1_NRDC >= '" + MV_PAR03 + "' AND GW1.GW1_NRDC <= '" + MV_PAR04 + "' " //Número
// 			If MV_PAR15 == 2
// 				cQuery += " AND (GW1.GW1_TPFRET = '1' OR GW1.GW1_TPFRET = '2') " //Doc. Carga CIF ou CIF Redesp.
// 			ElseIf MV_PAR15 == 3
// 				cQuery += " AND (GW1.GW1_TPFRET = '3' OR GW1.GW1_TPFRET = '4') " //Doc. Carga FOB ou FOB Redesp.
// 			EndIf
// 			cQuery += "AND ((GU3DES.GU3_NRCID >= '" + MV_PAR05 + "' AND GU3DES.GU3_NRCID <= '" + MV_PAR06 + "' AND GW1.GW1_ENTNRC = '') OR "
// 			cQuery += "(GW1.GW1_ENTNRC >= '" + MV_PAR05 + "' AND GW1.GW1_ENTNRC <= '" + MV_PAR06 + "' AND GW1.GW1_ENTNRC <> ''))" //Cidade

// 			cQuery += "AND GU7.GU7_CDUF >= '" + MV_PAR07 + "' AND GU7.GU7_CDUF <= '" + MV_PAR08 + "' " //UF
// 			cQuery += "AND GW1.GW1_CDDEST >= '" + MV_PAR09 + "' AND GW1.GW1_CDDEST <= '" + MV_PAR10 + "' " //Destinatário
// 		EndIf

// 		/*
// 		Verifica se o parâmetro MV_GFETRP -> Transportador de Início e fim = Ao Transportador do Romaneio
// 		Ou se o Filtro não está sendo aplicado. 
// 		*Se verdadeiro atribui o valor do transportador do romaneio para busca.
// 		*Se falso atribui o valor dos transportadores informados no pergunte.
// 		*/
// 		s_GFETRP		:= SuperGetMv("MV_GFETRP",.F.,"1")
// 		If s_GFETRP == "2" .OR. !_lFiltro
// 			cTrpIni := GWN->GWN_CDTRP
// 			cTrpFim := GWN->GWN_CDTRP
// 		Else
// 			cTrpIni := MV_PAR11
// 			cTrpFim := MV_PAR12
// 		EndIf

// 		cQuery += "AND GWU.GWU_CDTRP >= '" + cTrpIni + "' AND GWU.GWU_CDTRP <= '" + cTrpFim + "' " //Transportador do Trecho

// 		If _lFiltro
// 			cQuery += "AND GW1.GW1_CDTPDC >= '" + MV_PAR13 + "' AND GW1.GW1_CDTPDC <= '" + MV_PAR14 + "' " //Tipo de Documento de Carga
// 			cQuery += "AND GW1.GW1_DTPSAI >= '" + DToS(MV_PAR16) + "' AND GW1.GW1_DTPSAI <= '" + DToS(MV_PAR17) + "' " //Data de Saída
// 			cQuery += "AND GW1.GW1_DTEMIS >= '" + DToS(MV_PAR18) + "' AND GW1.GW1_DTEMIS <= '" + DToS(MV_PAR19) + "' " //Data de Emissão
// 			cQuery += "AND GW1.GW1_REGCOM >= '" + MV_PAR20 + "' AND GW1.GW1_REGCOM <= '" + MV_PAR21 + "' " //Região comercial
// 		EndIf
// 	EndIf

// 	//Ponto de entrada Pirelli
// 	If ExistBlock("GFEA05A1")
// 		cQuery += ExecBlock("GFEA05A1",.f.,.f.)
// 	EndIf
// 	//Fim ponto de entrada Pirelli 

// 	cQuery += " ORDER BY GW1.GW1_FILIAL, GW1.GW1_CDTPDC, GW1.GW1_EMISDC, GW1.GW1_SERDC, GW1.GW1_NRDC "
	
// 	cQuery := ChangeQuery(cQuery)
// 	cGW1 := GetNextAlias()
// 	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cGW1, .F., .T.)

// 	ASize(aDocFil,0)

// 	(cGW1)->( dbGoTop() )
// 	while !(cGW1)->(Eof())
// 		AaDD(aDocFil,{.F.   ,;
// 			(cGW1)->FILIAL  ,; 
// 			(cGW1)->SERIE   ,;
// 			(cGW1)->NRDC    ,;
// 			(cGW1)->TPDC    ,;
// 			(cGW1)->TPFRET  ,;
// 			(cGW1)->CDEMIS  ,;
// 			(cGW1)->NMEMIS  ,;
// 			(cGW1)->CDREM   ,;
// 			(cGW1)->NMREM   ,;
// 			(cGW1)->CDDEST  ,; 
// 			(cGW1)->NMDEST  ,;
// 			(cGW1)->NRREG  ,;
// 			(cGW1)->NRCID  ,;
// 			StoD((cGW1)->DTEMIS)  ,;
// 			StoD((cGW1)->DTSAI)  ,;
// 			(cGW1)->CIDDES  ,;
// 			(cGW1)->UFDEST  ,;
// 			(cGW1)->GW1_QTVOL })
// 			(cGW1)->(dbSkip())
// 	EndDo

// 	If Len(aDocFil) = 0
// 		AaDD(aDocFil,{.F.,; 
// 					  '' ,;
// 				      '' ,;
// 					  '' ,;
// 					  '' ,;
// 					  '' ,;
// 					  '' ,;
// 					  '' ,;
// 					  '' ,;
// 					  '' ,;
// 					  '' ,; 
// 					  '' ,;
// 					  '' ,;
// 					  '' ,;
// 					  '' ,;
// 					  '' ,;
// 					  '' ,;
// 					  '' ,;
// 					  0 })
// 	EndIf

// 	(cGW1)->( dbCloseArea() )

// 	cQuery := "SELECT GW1.GW1_FILIAL FILIAL, GW1.GW1_SERDC SERIE, GW1.GW1_NRDC NRDC, GW1.GW1_CDTPDC TPDC, "
// 	cQuery += GFEA66CASE("GW1", "GW1_TPFRET", "TPFRET", "''") + ", "
// 	cQuery += "      	GW1.GW1_EMISDC CDEMIS, GU3EMI.GU3_NMEMIT NMEMIS, GW1.GW1_CDREM CDREM, "
// 	cQuery += "		GU3REM.GU3_NMEMIT NMREM, GW1.GW1_CDDEST CDDEST, GU3DES.GU3_NMEMIT NMDEST, GW1.GW1_NRREG NRREG, "
// 	cQuery += "		GW1.GW1_DTEMIS DTEMIS, GW1.GW1_DTPSAI DTSAI, "
// 	cQuery += "		(CASE GW1.GW1_ENTNRC "
// 	cQuery += "			WHEN '' THEN GU3DES.GU3_NRCID"
// 	cQuery += "	   		ELSE GW1.GW1_ENTNRC "
// 	cQuery += " 		END) NRCID, "
// 	cQuery += "		(CASE GW1.GW1_ENTNRC "
// 	cQuery += "			WHEN '' THEN GU7DEST.GU7_NMCID"
// 	cQuery += "	   		ELSE GU7DOC.GU7_NMCID "
// 	cQuery += " 		END) CIDDES, "
// 	cQuery += "		(CASE GW1.GW1_ENTNRC "
// 	cQuery += "			WHEN '' THEN GU7DEST.GU7_CDUF"
// 	cQuery += "	   		ELSE GU7DOC.GU7_CDUF "
// 	cQuery += " 		END) UFDEST, "	
// 	cQuery += " 		GW1.GW1_QTVOL "	
// 	cQuery += "FROM " + RetSQLName("GW1") + " GW1 "
// 	cQuery += "INNER JOIN " + RetSQLName("GU3") + " GU3EMI ON GU3EMI.GU3_FILIAL = '" + xFilial("GU3") + "' AND GU3EMI.GU3_CDEMIT = GW1.GW1_EMISDC AND GU3EMI.D_E_L_E_T_ = ' ' "
// 	cQuery += "INNER JOIN " + RetSQLName("GU3") + " GU3REM ON GU3REM.GU3_FILIAL = '" + xFilial("GU3") + "' AND GU3REM.GU3_CDEMIT = GW1.GW1_CDREM  AND GU3REM.D_E_L_E_T_ = ' ' "
// 	cQuery += "INNER JOIN " + RetSQLName("GU3") + " GU3DES ON GU3DES.GU3_FILIAL = '" + xFilial("GU3") + "' AND GU3DES.GU3_CDEMIT = GW1.GW1_CDDEST AND GU3DES.D_E_L_E_T_ = ' ' "
// 	cQuery += "LEFT JOIN " + RetSQLName("GU7") + " GU7DEST ON GU7DEST.GU7_FILIAL = '" + xFilial("GU7") + "' AND GU7DEST.GU7_NRCID = GU3DES.GU3_NRCID AND GU7DEST.D_E_L_E_T_ = ' ' "
// 	cQuery += "LEFT JOIN " + RetSQLName("GU7") + " GU7DOC ON GU7DOC.GU7_FILIAL = '" + xFilial("GU7") + "' AND GU7DOC.GU7_NRCID = GW1.GW1_ENTNRC AND GU7DOC.D_E_L_E_T_ = ' ' "
// 	s_MULFIL   := SuperGetMV("MV_MULFIL",.F.,"2")
// 	If s_MULFIL == "1" .And. GFXCP1212210('GW1_FILROM')
// 		cQuery += "WHERE GW1.GW1_NRROM = '" + GWN->GWN_NRROM + "' AND GW1.GW1_FILROM = '" + GWN->GWN_FILIAL + "' AND GW1.D_E_L_E_T_ = ' ' "
// 		cQuery += " ORDER BY GW1.GW1_FILROM, GW1.GW1_CDTPDC, GW1.GW1_EMISDC, GW1.GW1_SERDC, GW1.GW1_NRDC "
// 	Else 
// 		cQuery += "WHERE GW1.GW1_NRROM = '" + GWN->GWN_NRROM + "' AND GW1.GW1_FILIAL = '" + GWN->GWN_FILIAL + "' AND GW1.D_E_L_E_T_ = ' ' "
// 		cQuery += " ORDER BY GW1.GW1_FILIAL, GW1.GW1_CDTPDC, GW1.GW1_EMISDC, GW1.GW1_SERDC, GW1.GW1_NRDC "
// 	EndIf

// 	cQuery := ChangeQuery(cQuery)
// 	cGW1 := GetNextAlias()
// 	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cGW1, .F., .T.)

// 	ASize(aDocSel,0)

// 	(cGW1)->( dbGoTop() )
// 	While !(cGW1)->(Eof())
// 		AaDD(aDocSel,{.F.,; 
// 					  (cGW1)->FILIAL,;
// 					  (cGW1)->SERIE,;
// 					  (cGW1)->NRDC,;
// 					  (cGW1)->TPDC,;
// 					  (cGW1)->TPFRET,;
// 					  (cGW1)->CDEMIS,;
// 					  (cGW1)->NMEMIS,;
// 					  (cGW1)->CDREM,;
// 					  (cGW1)->NMREM,;
// 					  (cGW1)->CDDEST,; 
// 					  (cGW1)->NMDEST,;
// 					  (cGW1)->NRREG,;
// 					  (cGW1)->NRCID,;
// 					  StoD((cGW1)->DTEMIS),;
// 					  StoD((cGW1)->DTSAI),;
// 					  (cGW1)->CIDDES,;
// 					  (cGW1)->UFDEST,;
// 					  (cGW1)->GW1_QTVOL })
// 			(cGW1)->(dbSkip())
// 	EndDo

// 	if Len(aDocSel) = 0
// 		AaDD(aDocSel,{.F.,; 
// 					  '' ,;
// 					  '' ,;
// 					  '' ,;
// 					  '' ,;
// 					  '' ,;
// 					  '' ,;
// 					  '' ,;
// 					  '' ,;
// 					  '' ,;
// 					  '' ,; 
// 					  '' ,;
// 					  '' ,;
// 					  '' ,;
// 					  '' ,;
// 					  '' ,;
// 					  '' ,;
// 					  '' ,;
// 					  0 })
// 	EndIf

// 	(cGW1)->( dbCloseArea() )

// 	aRdpDC:={0,0,0,0,0,0,0}
// 	GFEA50TSEL()
// 	GFE50ASORT(.T.,.T.)
// Return .T.

// Static Function GFEA50AOK(lConfirma) 

// 	Local lVincRoman := .F.
// 	Local nI         := 0
// 	Local nCont      := 0
// 	Local lRetPE     := .T.

// 	Default lConfirma := .F.

// 	If !GFE50ALINV(aDocFil)
// 		Return .T.
// 	EndIf

// 	For nI:= Len(aDocFil) to 1 Step -1 
// 		If aDocFil[nI,1] == .T.

// 			GW1->( dbSetOrder(1) )
// 			If GW1->( dbSeek(aDocFil[nI,02] + aDocFil[nI,05] + aDocFil[nI,07] + aDocFil[nI,03] + aDocFil[nI,04]) )
// 				If GWN->GWN_BLOQPF == "2"
// 					GV5->(dbSetOrder(1))
// 					GV5->(dbSeek(xFilial("GV5") + GW1->GW1_CDTPDC))
// 					If((GV5->GV5_EMITPF == "2" .Or. Empty(GV5->GV5_EMITPF)))
// 						If !IsBlind()
// 							MsgInfo("Você está vinculando um Documento de Carga cujo seu tipo bloqueia a emissão de pré-fatura a um Romaneio que não bloqueia a emissão de pré-fatura. Desta forma, o Romaneio será bloqueado para emissão de pré-fatura.")
// 						EndIf
// 						RecLock("GWN",.F.)
// 						GWN->GWN_BLOQPF := "1"
// 						GWN->(MsUnlock())	
// 					EndIf
// 				EndIf

// 				GW4->( dbSetOrder(02) )
// 				If GW4->( dbSeek(GW1->GW1_FILIAL+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC+GW1->GW1_CDTPDC) )
// 					If !IsBlind()
// 						MsgInfo("O Documento de Carga " + Alltrim(GW1->GW1_NRDC) + " já está vinculado a um Documento de Frete.")
// 					EndIf
// 					Return .F.
// 				EndIf

// 				If !Empty(GWN->GWN_VIAGEM)
// 					If !GFEA058RVG(GW1->(RecNo()))
// 						If !IsBlind()
// 							MsgInfo("Não é possível vincular o documento " + Alltrim(GW1->GW1_NRDC) + " que possui frete combinado/simulação com origem erp em romaneio com viagem")
// 						EndIf
// 						Return .F.
// 					EndIf
// 				EndIf

// 				// Ponto de entrada que permite realizar consistência adicional
// 				// na seleção dos documentos de carga que pertencerão ao romaneio
// 				If lPE503
// 					lRetPE := ExecBlock("GFEA0503",.F.,.F.,{GWN->GWN_NRROM,GW1->GW1_CDTPDC,GW1->GW1_EMISDC,GW1->GW1_SERDC,GW1->GW1_NRDC})
// 					If ValType(lRetPE) == "L" .And. !lRetPE
// 						Return .F.
// 					EndIf
// 				EndIf

// 				// Atualiza o documento de carga com o numero do romaneio
// 				RecLock("GW1", .F.)
// 					GW1->GW1_NRROM := GWN->GWN_NRROM
// 					If GFXCP1212210('GW1_FILROM')
// 						GW1->GW1_FILROM := GWN->GWN_FILIAL
// 					EndIf
// 					If GW1->GW1_SIT != "2"
// 						GW1->GW1_SIT   := "4" // Embarcado
// 					EndIf
// 					lVincRoman := .T.
// 				GW1->(MsUnLock())
// 				s_INTFRE		:= SuperGetMV('MV_INTFRE',.F.,'1')
// 				lExiSITFRE	:= GFXCP12117("GW1_SITFRE")
// 				If lExiSITFRE .And. s_INTFRE == '2'
// 					If GW1->GW1_ORIGEM == "2" .And. GW1->GW1_SITFRE != '6'
// 						RecLock("GW1", .F.)
// 						GW1->GW1_SITFRE := "2"
// 						GW1->GW1_MOTFRE := "GFEA050 - Vinculo do Documento de Carga no Romaneio"
// 						GW1->GW1_DTFRE  := Date()
// 						GW1->( MsUnLock() )
// 					EndIf
// 				EndIf

// 				GV4->( dbSetOrder(1) )
// 				If GV4->( dbSeek(xFilial("GV4") + GWN->GWN_CDTPOP) )

// 					GWU->( dbSetOrder(1) )
// 					If GWU->( dbSeek(xFilial("GWU") + aDocFil[nI,05] + aDocFil[nI,07] + aDocFil[nI,03] + aDocFil[nI,04]) )
// 						RecLock('GWU', .F. )
// 							GWU->GWU_CDTRP  := GWN->GWN_CDTRP
// 							GWU->GWU_CDTPVC := GWN->GWN_CDTPVC
// 						GWU->( MsUnLock() )
// 					EndIf
// 				EndIf   

// 				_lChgDocs := .T. // Romaneio teve alteração nos seus documentos de carga

// 			EndIf

// 			If nCont == 0
// 				GFE50ADELARRAY(aDocSel)
// 			EndIf

// 			AaDD(aDocSel,{.F.,aDocFil[nI,02],aDocFil[nI,03],aDocFil[nI,04],aDocFil[nI,05],aDocFil[nI,06],;
// 						  aDocFil[nI,07],aDocFil[nI,08],aDocFil[nI,09],aDocFil[nI,10],aDocFil[nI,11],aDocFil[nI,12],;
// 						  aDocFil[nI,13],aDocFil[nI,14],aDocFil[nI,15],aDocFil[nI,16],aDocFil[nI,17],aDocFil[nI,18],aDocFil[nI,19]})
// 			aDel(aDocFil,nI)
// 			nCont++
// 		EndIf
// 	Next

// 	If lVincRoman
// 		// Houve vinculo de romaneio com documento
// 		// Verifica se o cálculo do documento pode ser liberado, se possuir cálculo simulado
// 		aAreaGW1:= GW1->(GetArea())
// 		GFEA050ALI(GWN->GWN_FILIAL + GWN->GWN_NRROM)
// 		RestArea(aAreaGW1)

// 		If lConfirma
// 			//verifica se deve liberá-lo e libera-os
// 			GFE50LbRom()
// 		EndIf
// 	ElseIf lConfirma
// 		//verifica se deve liberá-lo e libera-os
// 		GFE50LbRom()
// 	EndIf

// 	ASize(aDocFil,Len(aDocFil)-nCont)

// 	GFE50ASORT(.T.,.T.)

// 	aRdpDC:={0,0,0,0,0,0,0}

// 	If !IsBlind()
// 		GFEA50RD()
// 		GFEA50TSEL()
// 	EndIf

// Return .T.  

// Static Function GFE50DELDC()

// 	Local aCalcs     := {}	
// 	Local nX         := 0
// 	Local lRetiraDoc := .T. 
// 	Local lApagaCalc := .T.
// 	Local cTpCalc
// 	Local nI         := 0
// 	Local nCont      := 0
// 	Local cTxtDoc	 := ''
// 	Local cOriCalc   := ""
// 	Local cMV_CALRET := SuperGetMv("MV_CALRET",.F.,"2")

// 	If !GFE50ALINV(aDocSel)
// 		Return .T.
// 	EndIf
	
// 	If cMV_CALRET == "1"
// 		cOriCalc := "1"
// 	EndIf

// 	For nI:= Len(aDocSel) To 1 Step -1 
// 		If aDocSel[nI,1] == .T.
// 			dbSelectArea("GW1")
// 			dbSetOrder(1)
// 			If dbSeek(aDocSel[nI,02] + aDocSel[nI,05] + aDocSel[nI,07] + aDocSel[nI,03] + aDocSel[nI,04])
// 				aCalcs := {}	
// 				//Verifica se o Documento de carga está entregue, em caso positivo não será possível desvinculá-lo
// 				If GW1->GW1_SIT == "5"
// 					Help( ,,'HELP',,"Documento de Carga já foi entregue. Retirada não permitida.", 1, 0,) 
// 					lRetiraDoc := .F.	
// 				EndIf

// 				// Verificar se o documento de carga está relacionado a cálculo de frete
// 				dbSelectArea("GWH")
// 				dbSetOrder(02)
// 				dbSeek(GW1->GW1_FILIAL+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC)
// 				While !GWH->(Eof()) .AND. GWH->GWH_FILIAL == GW1->GW1_FILIAL;
// 								    .AND. GWH->GWH_EMISDC == GW1->GW1_EMISDC;
// 									.AND. GWH->GWH_SERDC  == GW1->GW1_SERDC;
// 									.AND. GWH->GWH_NRDC   == GW1->GW1_NRDC
// 					dbSelectArea("GWF")
// 					dbSetOrder(01)
// 					If dbSeek(GWH->GWH_FILIAL + GWH->GWH_NRCALC)
// 						// Revisar quando a rotina estiver apta para gerar outros tipos de calculo (reentrega, devolucao)
// 						If aScan(aCalcs,{|x| x[1] == GWH->GWH_FILIAL .And. x[2] == GWH->GWH_NRCALC}) == 0 .AND. (GWF->GWF_TPCALC $ "168" .Or. GWF->GWF_TPCALC == "5" .And. cOriCalc == "1") // 1-Normal, 5-Devolução, 6-Redespacho, 8-Provisao
// 							aAdd(aCalcs, {GWH->GWH_FILIAL, GWH->GWH_NRCALC})
// 						EndIf
// 					EndIf

// 					dbSelectArea("GWH")
// 					dbSkip()
// 				EndDo

// 				// Verifica se os cálculos encontrados podem ser eliminados
// 				cTxtDoc := ''
// 				If !Empty(aCalcs)
// 					For nX := 1 to len(aCalcs)
// 						lApagaCalc := .T.

// 						If !GFEVldLotProvisao(aCalcs[nX][2], aCalcs[nX][1])
// 							cTxtDoc += ' (Lotes de Provisão) '
// 							lApagaCalc := .F.
// 						EndIf

// 						// Valida o cálculo de frete existente em relacao aos documentos de frete
// 						If !GFEVldDocFrete(aCalcs[nX][2], ,aCalcs[nX][1])
// 							cTxtDoc += ' (Documento de Frete) '
// 							lApagaCalc := .F.
// 						EndIf

// 						// Valida o cálculo de frete existente em relacao a pre-fatura
// 						If !GFEVldPreFat(aCalcs[nX][2], aCalcs[nX][1])
// 							cTxtDoc += ' (Pré-Fatura) '
// 							lApagaCalc := .F.
// 						EndIf

// 						// Valida o cálculo de frete em relacao a contrato com terceiros
// 						If !GFEVldContr(aCalcs[nX][2], aCalcs[nX][1])
// 							cTxtDoc += ' (Contrato com Autônomo) '
// 							lApagaCalc := .F.
// 						EndIf

// 						// Se não for possível eliminar o cálculo, não permitir a retirada do mesmo
// 						If !lApagaCalc
// 							Help( ,,'HELP',,"Cálculo do documento de carga possui vínculo com:" + cTxtDoc + "." + CRLF + CRLF + "Transportadora: ", 1, 0,) //"Retirada não permitida."
// 							lRetiraDoc := .F.
// 							Exit
// 						Else
// 							If !GFEVldMovCtb(aCalcs[nX][2], aCalcs[nX][1]) // Cálculo possui movimentos contábeis atualizados no ERP
// 								cTpCalc := Posicione("GWF",1,xFilial("GWF")+aCalcs[nX],"GWF_TPCALC")
// 								dbSelectArea("GWF")
// 								dbSetOrder(01)
// 								If dbSeek(xFilial("GWF")+aCalcs[nX])
// 									RecLock("GWF",.F.)
// 									If cTpCalc $ "16"	// 1-Normal, 6-Redespacho
// 										GWF->GWF_TPCALC := "8"	// Transforma o cálculo em Provisão              
// 									EndIf
// 									GWF->GWF_NRROM := ""   // Desvincula o cálculo do romaneio
// 									GWF->(MsUnLock())
// 								EndIf	
// 							Else
// 								// Reativa as provisões relacionadas aos documentos de carga do cálculo corrente
// 								GFEDelEstorno(aCalcs[nX][1], aCalcs[nX][2])
// 								// Apaga o calculo de frete e seus relacionamentos, incluindo movimentos contábeis
// 								GFEDelCalc(aCalcs[nX][2], aCalcs[nX][1],,,cOriCalc)
// 							EndIf
// 						EndIf
// 					Next nX
// 				EndIf

// 				If lRetiraDoc		
// 					// Desvincula o documento de carga do romaneio

// 					RecLock("GW1",.F.)
// 					GW1->GW1_NRROM := "" 
// 					If GFXCP1212210('GW1_FILROM')
// 						GW1->GW1_FILROM := ""
// 					EndIf
// 					If GW1->GW1_SIT == "4"
// 						GW1->GW1_SIT := "3" // Liberado
// 					EndIf
// 					GW1->(MsUnLock())
// 					s_INTFRE		:= SuperGetMV('MV_INTFRE',.F.,'1')
// 					lExiSITFRE	:= GFXCP12117("GW1_SITFRE")
// 					If lExiSITFRE .And. s_INTFRE == '2'
// 						If GW1->GW1_ORIGEM == "2" .And. GW1->GW1_SITFRE != '6'
// 							RecLock("GW1", .F.)
// 							GW1->GW1_SITFRE := "2"
// 							GW1->GW1_MOTFRE := "GFEA050 - Remoção do Documento de Carga do Romaneio"
// 							GW1->GW1_DTFRE  := Date()
// 							GW1->( MsUnLock() )
// 						EndIf
// 					EndIf

// 					If lPE509
// 						ExecBlock("GFEA05A9",.f.,.f.)
// 					EndIf

// 					If nCont == 0
// 						GFE50ADELARRAY(aDocFil)
// 					EndIf
// 					AaDD(aDocFil,{.F.,aDocSel[nI,02],aDocSel[nI,03],aDocSel[nI,04],aDocSel[nI,05],aDocSel[nI,06],;
// 								  aDocSel[nI,07],aDocSel[nI,08],aDocSel[nI,09],aDocSel[nI,10],aDocSel[nI,11],aDocSel[nI,12],;
// 							      aDocSel[nI,13],aDocSel[nI,14],aDocSel[nI,15],aDocSel[nI,16],aDocSel[nI,17],aDocSel[nI,18],aDocSel[nI,19]})
// 					aDel(aDocSel,nI)
// 					nCont++

// 					_lChgDocs := .T. // Romaneio teve alteração em seus documentos de carga

// 				EndIf
// 			EndIf
// 		EndIf
// 	next

// 	if nCont > 0
// 		ASize(aDocSel,Len(aDocSel)-nCont)

// 		GFE50ASORT(.T.,.T.)
// 		GFEA50RD()
// 		GFEA50TSEL()

// 		If oBrSel:nAt > Len(aDocSel) .And. Len(aDocSel) > 0
// 			oBrSel:nAt := Len(aDocSel)
// 		EndIf
// 	EndIf

// Return

// /*-------------------------------------------------------------------
// Elimina o estorno dos cálculos de provisão dos documentos de carga
// relacionados ao calculo normal recebido
// -------------------------------------------------------------------*/
// Static Function GFEDelEstorno(cCodFilial, cNrCalcNormal)
// 	Local aAreaGWF := GWF->(getArea())
// 	Local aAreaGWH := GWH->(getArea())
// 	Local aAreaGW1 := GW1->(getArea())    

// 	ChkFile("GWH",,"GWHBF")	// Cria um "buffer" da tabela GWH, evitando desposicionamento do registro na área original

// 	dbSelectArea("GWH")
// 	dbSetOrder(1)
// 	If dbSeek(cCodFilial + cNrCalcNormal)

// 		// Para cada documento de carga do calculo de frete normal (ou redespacho)...
// 		While !GWH->(Eof()) .AND. GWH->GWH_FILIAL == cCodFilial .AND. GWH->GWH_NRCALC == cNrCalcNormal
// 			dbSelectArea("GW1")
// 			dbSetOrder(1)
// 			If dbSeek(GWH->GWH_FILIAL+GWH->GWH_CDTPDC+GWH->GWH_EMISDC+GWH->GWH_SERDC+GWH->GWH_NRDC)
// 				dbSelectArea("GWHBF")
// 				dbSetOrder(2)
// 				If dbSeek(GW1->GW1_FILIAL+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC)			
// 					// Localiza os demais cálculos, diferentes do cálculo normal
// 					While !GWHBF->(Eof()) .AND. GWHBF->GWH_FILIAL == GW1->GW1_FILIAL;
// 										  .AND. GWHBF->GWH_EMISDC == GW1->GW1_EMISDC;
// 										  .AND. GWHBF->GWH_SERDC  == GW1->GW1_SERDC;
// 										  .AND. GWHBF->GWH_NRDC   == GW1->GW1_NRDC;
// 										  .AND. GWHBF->GWH_NRCALC != cNrCalcNormal				             
// 						dbSelectArea("GWF")
// 						dbSetOrder(1)
// 						// Se o cálculo de frete for do tipo provisão
// 						If dbSeek(GWHBF->GWH_FILIAL+GWHBF->GWH_NRCALC) .AND. GWF->GWF_TPCALC == "8"	// Provisao					
// 							// Eliminar os movimentos contábeis de estorno, se possível, fazendo a provisão voltar à ativa
// 							GWA->(dbSetOrder(1))
// 							If GWA->(dbSeek(GWF->GWF_FILIAL+"1"+PadR("",5)+PadR("",TamSx3("GWA_CDEMIT")[1])+PadR("",5)+GWF->GWF_NRCALC))
// 								While !GWA->(Eof()) .AND. GWA->GWA_FILIAL == GWF->GWF_FILIAL;
// 													.AND. GWA->GWA_TPDOC  == "1";
// 													.AND. GWA->GWA_CDESP  == PadR("",5);
// 													.AND. GWA->GWA_CDEMIT == PadR("", TamSx3("GWA_CDEMIT")[1]);
// 													.AND. GWA->GWA_SERIE  == PadR("",5);
// 													.AND. AllTrim(GWA->GWA_NRDOC) == AllTrim(GWF->GWF_NRCALC)     										 
// 									If AllTrim(GWA->GWA_CDTRAN) >= "305" .AND. AllTrim(GWA->GWA_CDTRAN) <= "309"; // Estornos de provisao
// 																		 .AND. GWA->GWA_SITCTB $ "13"	// Movimento contábil não atualizado no ERP
// 										RecLock("GWA",.F.)
// 										dbDelete()
// 										GWA->(MsUnLock())									
// 									EndIf   								
// 									GWA->(dbSkip())
// 								EndDo
// 							EndIf
// 						EndIf
// 						GWHBF->(dbSkip())
// 					EndDo
// 				EndIF
// 			EndIf		
// 			GWH->(dbSkip())
// 		EndDo
// 	EndIf		

// 	GWHBF->(dbCloseArea())

// 	RestArea(aAreaGWF)
// 	RestArea(aAreaGWH)
// 	RestArea(aAreaGW1)
// Return


// Static Function GFE050AVIS()
// 	if !GFE50ALINV(aDocSel)
// 		Return .T.
// 	EndIf
// 	if Len(aDocSel) > 0 .AND. nLinSel > 0 .AND. (nLinSel <= Len(aDocSel)) 
// 		dbSelectArea("GW1")
// 		dbSetOrder(1)
// 		if dbSeek(aDocSel[nLinSel,2] + aDocSel[nLinSel,5] + aDocSel[nLinSel,7] + aDocSel[nLinSel,3] + aDocSel[nLinSel,4])
// 			FWExecView("",'GFEA044',1,,{||.T.})
// 		endif
// 	EndIf
// Return(.T.)

// Static Function GFE050AFIL(lFiltrar, oBrwse)
// 	s_MULFIL   := SuperGetMV("MV_MULFIL",.F.,"2")
// 	If s_MULFIL == "1"
// 		If Pergunte("GFEA050FIL", .T.)
// 			_lFiltro := .T.
// 			If lFiltrar
// 				GFE050AMB()
// 			EndIf
// 		Else
// 			_lFiltro := .F.
// 		EndIf
// 	Else
// 		If Pergunte("GFEA050", .T.)
// 			_lFiltro := .T.
// 			If lFiltrar
// 				GFE050AMB()
// 			EndIf
// 		Else
// 			_lFiltro := .F.
// 		EndIf
// 	EndIf

// Return

// Static Function GFEA50ACL(lReal) 
// 	Local nQtdeIt := 0, nVlDC := 0, nVol := 0, nPeso := 0, nVlFrete := 0, nPercDC := 0
// 	Local aAgrFrt := {}
// 	Local aDocCarg := {}
// 	Local aTrchDoc := {}
// 	Local aItDoc := {}
// 	Local nI := 0
// 	Local nX
// 	Local aTrechos
// 	Local lGW8VALLIQ := GFXCP12118("GW8_VALLIQ")
// 	Local lXFBGWUDC := FindFunction("XFBGWUDC")
// 	Local aRetGXT

// 	Private cTRBCCF, cTRBITE, cTRBTRE, cTRBTCF, cTRBUNC, cTRBDOC, cTRBAGRU, cTRBSIM, cTRBENT    //variaveis utilizadas na rotina de calculo de frete
// 	Private aTRBCCF3 := {} // Indice 3
// 	Private lTabTemp := .F.

// 	Private idpCCF := 1 // posição do array cTRBCCF
// 	Private idxCCF := 1 // Indice  da array cTRBCCF
// 	Private _aCmpCCF := {	"NRCALC",; // 1
// 	"CDCLFR",; // 2
// 	"CDTPOP",; // 3
// 	"SEQ"   ,; // 4
// 	"CDCOMP",; // 5
// 	"CATVAL",; // 6
// 	"QTDE"  ,; // 7
// 	"VALOR" ,; // 8
// 	"TOTFRE",; // 9
// 	"BASIMP",; // 10
// 	"BAPICO",; // 11
// 	"FREMIN",; // 12
// 	"IDMIN" ,; // 13
// 	"VLFRMI",; // 14
// 	"DELETE"}  // 15

// 	if !GFE50ALINV(aDocSel)
// 		Return .T.
// 	EndIf

// 	if Len(aDocSel) > 0
// 		//ARRAY de Agrupadores de Frete (Romaneio)
// 		aAdd(aAgrFrt,{GWN->GWN_NRROM,; //Numero do Agrupador
// 		GWN->GWN_CDTRP,;  //Transportador
// 		GWN->GWN_CDTPVC,; //Tipo de Veiculo
// 		GWN->GWN_CDCLFR,; //Classificacao de Frete
// 		GWN->GWN_CDTPOP,; //Tipo de Operacao
// 		GWN->GWN_DISTAN,; //Distancia Percorrida
// 		GWN->GWN_NRCIDD,; //Cidade Destino
// 		GWN->GWN_CEPD,;   //CEP Destino
// 		"0"})   			//ERRO

// 		for nI:= 1 to Len(aDocSel)
// 			GW1->(dbSetOrder(01))
// 			If GW1->(!dbSeek(aDocSel[nI,2] + aDocSel[nI,5] + aDocSel[nI,7] + aDocSel[nI,3] + aDocSel[nI,4]))
// 				Loop
// 			EndIf

// 			//Totaliza unitizadores do documento selecionado
// 			nQtde := 0
// 			GWB->(dbSetOrder(02))
// 			GWB->(dbSeek(xFilial("GWB")+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC,.T.))
// 			While GWB->(!Eof()) .And. GWB->GWB_FILIAL == xFilial("GWB") .And. GWB->GWB_CDTPDC == GW1->GW1_CDTPDC .And.;
// 			GWB->GWB_EMISDC == GW1->GW1_EMISDC .And. GW1->GW1_SERDC == GW1->GW1_SERDC .And. GWB->GWB_NRDC == GW1->GW1_NRDC
// 				nQtde += GWB->GWB_QTDE
// 				GWB->(dbSkip())
// 			EndDo

// 			//ARRAY de Documentos de Carga
// 			aAdd(aDocCarg,{	GW1->GW1_EMISDC,; //Emitente do Documento
// 			GW1->GW1_SERDC,;  //Serie do Documento
// 			GW1->GW1_NRDC,;   //Numero do Documento
// 			GW1->GW1_CDTPDC,; //Tipo do Documento
// 			GW1->GW1_CDREM,;  //Remetente do Documento
// 			GW1->GW1_CDDEST,; //Destinatario do Documento
// 			GW1->GW1_ENTEND,; //Endereco de Entrega
// 			GW1->GW1_ENTBAI,; //Bairro de entrega
// 			GW1->GW1_ENTNRC,; //Cidade de Entrega
// 			GW1->GW1_ENTCEP,; //CEP de Entrega
// 			GW1->GW1_NRREG,;  //Região de destino
// 			GW1->GW1_TPFRET,; //Tipo de Frete  
// 			GW1->GW1_ICMSDC,; //ICMS?
// 			GW1->GW1_USO,;    //Finalidade da mercadoria
// 			GW1->GW1_CARREG,; //Número do carregamento
// 			GW1->GW1_NRROM,;    //Numero do Agrupador
// 			nQtde}) //Quantidade de Unitizadores
// 			If lXFBGWUDC			
// 				aTrechos := XFBGWUDC(,GW1->GW1_FILIAL,GW1->GW1_CDTPDC,GW1->GW1_EMISDC,GW1->GW1_SERDC,GW1->GW1_NRDC)
// 				For nX := 1 To Len(aTrechos)
// 					aAdd(aTrchDoc,aClone(aTrechos[nX]))
// 				Next nX
// 			Else
// 				GWU->(dbSetOrder(01))
// 				GWU->(dbSeek(xFilial("GWU")+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC,.T.))
// 				While GWU->(!Eof()) .And. GWU->GWU_FILIAL == xFilial("GWU") .And. GWU->GWU_CDTPDC == GW1->GW1_CDTPDC .And.;
// 				GWU->GWU_EMISDC == GW1->GW1_EMISDC .And. GWU->GWU_SERDC == GW1->GW1_SERDC .And. GWU->GWU_NRDC == GW1->GW1_NRDC

// 					//ARRAY de Trechos do Documento
// 					aAdd(aTrchDoc,{	GWU->GWU_EMISDC,; //Emitente do Documento
// 					GWU->GWU_SERDC,;  //Serie do Documento
// 					GWU->GWU_NRDC,;   //Numero do Documento
// 					GWU->GWU_CDTPDC,; //Tipo do Documento
// 					GWU->GWU_SEQ,;    //Sequencia do Trecho
// 					GWU->GWU_CDTRP,;  //Transportador do Trecho 
// 					GWU->GWU_NRCIDD,;  //Cidade Destino 
// 					GWU->GWU_CDTPVC,; //Tipo de Veiculo do Trecho
// 					GWU->GWU_PAGAR}) 
// 					GWU->(dbSkip())   

// 				EndDo
// 			EndIf		

// 			GW8->(dbSetOrder(01))
// 			GW8->(dbSeek(xFilial("GW8")+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC,.T.))
// 			While GW8->(!Eof()) .And. GW1->GW1_FILIAL == xFilial("GW8") .And. GW8->GW8_EMISDC == GW1->GW1_EMISDC .And.;
// 			GW8->GW8_CDTPDC == GW1->GW1_CDTPDC .And. GW8->GW8_SERDC == GW1->GW1_SERDC .And. GW8->GW8_NRDC == GW1->GW1_NRDC

// 				//ARRAY de Itens do Documento
// 				aAdd(aItDoc,{GW8->GW8_EMISDC,; //Emitente do Documento
// 				GW8->GW8_SERDC,;  //Serie do Documento
// 				GW8->GW8_NRDC,;   //Numero do Documento
// 				GW8->GW8_CDTPDC,; //Tipo do Documento
// 				GW8->GW8_ITEM,;   //Item
// 				GW8->GW8_CDCLFR,; //Classificacao de Frete
// 				GW8->GW8_TPITEM,; //Tipo de Item
// 				GW8->GW8_QTDE,;   //Quantidade do Item
// 				GW8->GW8_PESOR,;  //Peso do Item
// 				GW8->GW8_PESOC,;  //Peso Cubado
// 				GW8->GW8_QTDALT,; //Quantidade/Peso Alternativo
// 				GW8->GW8_VALOR,;  //Valor do Item
// 				GW8->GW8_VOLUME,; //Volume ocupado (m3)
// 				GW8->GW8_TRIBP,;  // Frete tributado PIS
// 				IIF(lGW8VALLIQ,GW8->GW8_VALLIQ,0),;// Valor Liquido
// 				GW8->GW8_FILIAL}) // Filial 

// 				nQtdeIt := GW8->GW8_QTDE + nQtdeIt
// 				nVlDC := GW8->GW8_VALOR + nVlDC   
// 				nVol  := GW8->GW8_VOLUME + nVol 
// 				nPeso := IF( GW8->GW8_PESOR > GW8->GW8_PESOC ,GW8->GW8_PESOR,GW8->GW8_PESOC) + nPeso 

// 				GW8->(dbSkip())    
// 			EndDo
// 		next

// 		aRetGXT := GFEA50GXT()

// 		aRet := GFECLCFRT(aAgrFrt,aDocCarg,aTrchDoc,aItDoc,IIF(aRetGXT[1]== .T.,aRetGXT[2],Nil),.F.,2,.F.,.F.,1)    

// 		If !Empty(aRet)  

// 			If aRet[1]

// 				lTabTemp	:= aRet[07]
// 				aTRBCCF3	:= aRet[10]

// 				/*
// 				Quantidade: Soma da quantidade dos itens dos documentos de cargas; 
// 				Valor Doctos Carga: Soma dos valores das mercadorias dos itens dos documentos de cargas; 
// 				Volumes: Soma dos volumes dos itens dos documentos de cargas; 
// 				Peso: Soma dos pesos real/cubado dos itens dos documentos de cargas;
// 				Valor do Frete: Total do frete calculado, resultado da simulação do frete. 
// 				% Doctos Carga: Percentual do frete com relação ao valor total do documento de carga  (Valor do Frete/Valor Doctos Carga)
// 				*/
// 				If Len(aRet) >= 12
// 					cTRBCCF := aRet[12]
// 				EndIf

// 				//Calculando to total do frete simulado
// 				GFEXFB_BORDER(lTabTemp,cTRBCCF,01,9) //dbSetOrder(1)
// 				GFEXFB_2TOP(lTabTemp, cTRBCCF, @aTRBCCF3, 9) //dbGoTop()
// 				While !GFEXFB_3EOF(lTabTemp, cTRBCCF, @aTRBCCF3, 9) 
// 					nVlFrete := nVlFrete + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF3, 9,"VALOR")
// 					GFEXFB_8SKIP(lTabTemp, cTRBCCF, 9) //dbSkip()
// 				EndDo	 
// 				nPercDC := (nVlFrete/nVlDC) * 100

// 				oSize := FWDefSize():New(.T.)
// 				oSize:AddObject( "ENCHOICE", 100, 60, .T., .T. ) // Adiciona enchoice
// 				oSize:SetWindowSize({80,50,320,500})
// 				oSize:lLateral     := .F.  // Calculo vertical	
// 				oSize:Process() //executa os calculos

// 				aPos := {oSize:GetDimension("ENCHOICE","LININI"),; 
// 				oSize:GetDimension("ENCHOICE","COLINI"),;
// 				oSize:GetDimension("ENCHOICE","XSIZE"),;
// 				oSize:GetDimension("ENCHOICE","YSIZE")}


// 				DEFINE MSDIALOG oDlg TITLE "Deseja bloquear romaneio para emissão de pre-fatura?" ;
// 				FROM oSize:aWindSize[1],oSize:aWindSize[2] ;
// 				TO oSize:aWindSize[3],oSize:aWindSize[4] ;
// 				OF oMainWnd COLORS 0, 16777215 PIXEL	
// 				oDlg:lEscClose := .F.

// 				@ aPos[1]+27,aPos[2]+10  Say "Deseja desbloquear romaneio para emissão de pre-fatura?" Of oDlg COLOR CLR_BLACK Pixel //"Quantidade: "
// 				@ aPos[1]+25,aPos[2]+45  MSGET nQtdeIt Picture "@E 999,999,999.99" Of oDlg When .F. Pixel

// 				@ aPos[1]+47,aPos[2]+10  Say "Volume:" Of oDlg COLOR CLR_BLACK Pixel //"Volume: "
// 				@ aPos[1]+45,aPos[2]+45  MSGET nVol Picture "@E 999,999,999.99" Of oDlg When .F. Pixel

// 				@ aPos[1]+67,aPos[2]+10  Say "Data entrega menor que data de liberação" Of oDlg COLOR CLR_BLACK Pixel //"Peso: "
// 				@ aPos[1]+65,aPos[2]+45  MSGET nPeso Picture "@E 999,999,999.99" Of oDlg When .F. Pixel

// 				@ aPos[1]+27,aPos[2]+120  Say "Romaneio não possui documento de carga relacionado." Of oDlg COLOR CLR_BLACK Pixel //"Valor DC: "
// 				@ aPos[1]+25,aPos[2]+155  MSGET nVlDC Picture "@E 999,999,999.99" Of oDlg When .F. Pixel

// 				@ aPos[1]+47,aPos[2]+120  Say "Valor Frete: " Of oDlg COLOR CLR_BLACK Pixel //"Valor Frete: "
// 				@ aPos[1]+45,aPos[2]+155  MSGET nVlFrete Picture "@E 999,999,999.99" Of oDlg When .F. Pixel

// 				@ aPos[1]+67,aPos[2]+120  Say "% Doc Carga: " Of oDlg COLOR CLR_BLACK Pixel //"% Doc Carga: "
// 				@ aPos[1]+65,aPos[2]+155  MSGET nPercDC Picture "@E 999,999,999.99" Of oDlg When .F. Pixel


// 				ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(ODlg,{||ODlg:End()},{||ODlg:End()},,aNewButton) CENTERED 

// 			EndIf   

// 			//Deletar as tabelas usadas na rotina do calculo de frete
// 			if lTabTemp
// 				GFEDelTab(cTRBCCF)
// 				GFEDelTab(cTRBITE) 
// 				GFEDelTab(cTRBTRE) 
// 				GFEDelTab(cTRBTCF) 
// 				GFEDelTab(cTRBUNC) 
// 				GFEDelTab(cTRBDOC) 
// 				GFEDelTab(cTRBAGRU)
// 				GFEDelTab(cTRBENT) 
// 			Else
// 				IIF(aTRBCCF3==NIL,,aSize(aTRBCCF3,0))
// 				aTRBCCF3:= Nil
// 			EndIf 
// 			If !Empty(cTRBSIM) 
// 				GFEDelTab(cTRBSIM) 
// 			EndIf  
// 		EndIf
// 	EndIf
// Return

// Static Function GFEA50TSEL()
// 	Local nI := 0

// 	aRdpSel := {0,0,0,0,0,0,0}

// 	For nI:= 1 To Len(aDocSel)
// 		aRdpSel[1]++
// 		aRdpSel[6] += aDocSel[nI,19]
		
// 		GW8->( dbSetOrder(1) )
// 		GW8->( dbSeek(aDocSel[nI,02] + aDocSel[nI,05] + aDocSel[nI,07] + aDocSel[nI,03] + aDocSel[nI,04]) )
// 		While !GW8->( Eof() ) .And. ;
// 		GW8->GW8_CDTPDC == aDocSel[nI,05] .And. ;
// 		GW8->GW8_EMISDC == aDocSel[nI,07] .And. ;
// 		GW8->GW8_SERDC == aDocSel[nI,03]   .And. ;
// 		GW8->GW8_NRDC == aDocSel[nI,04]

// 			aRdpSel[2] += GW8->GW8_PESOR
// 			aRdpSel[3] += GW8->GW8_PESOC
// 			aRdpSel[4] += GW8->GW8_VOLUME
// 			aRdpSel[5] += GW8->GW8_VALOR
// 			aRdpSel[7] += GW8->GW8_QTDALT

// 			GW8->( dbSkip() )
// 		EndDo
// 	Next
// Return

// Static Function GFEA50ACHK(nOp, aDoc)
// 	Local nI := 0

// 	if !GFE50ALINV(aDoc)
// 		Return .T.
// 	EndIf

// 	for nI:= 1 to Len(aDoc)
// 		if nOp==1 .AND. aDoc[nI,01] == .F.
// 			aDoc[nI,01] := IIF(nOp==1, .T., .F.)
// 			GFEA50ARDP(nI)
// 		ElseIf nOp==2 .AND. aDoc[nI,01] == .T.
// 			aDoc[nI,01] := IIF(nOp==1, .T., .F.)
// 			GFEA50ARDP(nI)
// 		ElseIf nOp==3
// 			aDoc[nI,01] := !aDoc[nI,01]
// 			GFEA50ARDP(nI)
// 		ElseIf nOp==4
// 			aDoc[nI,01] := !aDoc[nI,01]
// 		EndIf
// 	next
// 	GFEA50RD()
// Return

// Static Function GFEA50RD()
// 	Local nCont := 1
// 	While nCont <= 7
// 		&("oGetRdp"+AllTrim(Str(nCont))+":Refresh()")
// 		nCont++
// 	EndDo
// Return

// Static Function GFEA50ARDP(nPosicao)

// 	If aDocFil[nPosicao,01] == .T.

// 		aRdpDC[1]++

// 		aRdpDC[6] += aDocFil[nPosicao,19]

// 		GW8->( dbSetOrder(1) )
// 		GW8->( dbSeek(aDocFil[nPosicao,02] + aDocFil[nPosicao,05] + aDocFil[nPosicao,07] + aDocFil[nPosicao,03] + aDocFil[nPosicao,04]) )
// 		While !GW8->( Eof() ) .And. ;
// 		GW8->GW8_CDTPDC == aDocFil[nPosicao,05] .And. ;
// 		GW8->GW8_EMISDC == aDocFil[nPosicao,07] .And. ;
// 		GW8->GW8_SERDC  == aDocFil[nPosicao,03]  .And. ;
// 		GW8->GW8_NRDC   == aDocFil[nPosicao,04]

// 			aRdpDC[2] += GW8->GW8_PESOR
// 			aRdpDC[3] += GW8->GW8_PESOC
// 			aRdpDC[4] += GW8->GW8_VOLUME
// 			aRdpDC[5] += GW8->GW8_VALOR
// 			aRdpDC[7] += GW8->GW8_QTDALT

// 			GW8->( dbSkip() )
// 		EndDo
// 	Else

// 		aRdpDC[1]--

// 		aRdpDC[6] -= aDocFil[nPosicao,19]

// 		GW8->( dbSetOrder(1) )
// 		GW8->( dbSeek(aDocFil[nPosicao,02] + aDocFil[nPosicao,05] + aDocFil[nPosicao,07] + aDocFil[nPosicao,03] + aDocFil[nPosicao,04]) )
// 		While !GW8->( Eof() ) .And. GW8->GW8_CDTPDC == aDocFil[nPosicao,05] .And. GW8->GW8_EMISDC == aDocFil[nPosicao,07] .And. GW8->GW8_SERDC == aDocFil[nPosicao,03] ;
// 		.And. GW8->GW8_NRDC == aDocFil[nPosicao,04]

// 			aRdpDC[2] -= GW8->GW8_PESOR
// 			aRdpDC[3] -= GW8->GW8_PESOC
// 			aRdpDC[4] -= GW8->GW8_VOLUME
// 			aRdpDC[5] -= GW8->GW8_VALOR
// 			aRdpDC[7] -= GW8->GW8_QTDALT

// 			GW8->( dbSkip() )
// 		EndDo
// 	EndIf
// Return

// //Atualiza a situação do cálculo/romaneio para um cálculo ORIGEM 4
// Static Function GFEA050ALI(cNrRoman)
// 	Local lDCBloq	:= .F.
// 	Local lCalcSimu	:= .F.
// 	Local lDifSimu	:= .F.
// 	Local aAreaGWN	:= GWN->(GetArea())
// 	Local aAreaGWH	:= GWH->(GetArea())
// 	Local aAreaGW1	:= GW1->(GetArea())
// 	Local aRet		:= {.T., ""}
// 	Local aRetPE 	:= {}
// 	Local cNumBloq	:= ""
// 	Local cNumSimu	:= ""

// 	Default cNrRoman	:= ""

// 	// Setando a opção de busca para as tabelas que serão utilizadas
// 	GWF->(dbSetOrder(1))
// 	GWH->(dbSetOrder(2))
// 	GWN->(dbSetOrder(1))

// 	// Caso o parâmetro seja recebido em branco, é utilizada as informações da GW1 que está posicionada
// 	If Empty(cNrRoman) .And. !Empty(GW1->GW1_NRROM)
// 		cNrRoman := GW1->GW1_FILIAL + GW1->GW1_NRROM
// 	EndIf

// 	If !Empty(cNrRoman)
// 		// Realiza a busca de todas as GW1 vincualdas ao romaneio
// 		GW1->(dbSetOrder(9))
// 		GW1->(dbSeek(cNrRoman))

// 		While !GW1->(Eof()) .And. cNrRoman == GW1->GW1_FILIAL + GW1->GW1_NRROM
// 			// Verifica se algum dos documentos de carga está como bloqueado
// 			If GW1->GW1_SIT == '2'
// 				lDCBloq := .T.
// 				cNumBloq += cValToChar(AllTrim(GW1->GW1_NRDC)) + ";"
// 			EndIf
// 			// Verificar se existe cálculo vincualado ao documento de carga
// 			If GWH->(dbSeek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC))
// 				// Caso exista cálculo é verificado se é de simulação, se for lCalcSimu igual a .T., senão lDifSimu igual a .T.
// 				If GWF->(dbSeek(GWH->GWH_FILIAL + GWH->GWH_NRCALC)) .And. GWF->GWF_ORIGEM = '4'
// 					lCalcSimu 	:= .T.
// 					cNumSimu   += cValToChar(AllTrim(GW1->GW1_NRDC)) + ";"
// 				Else
// 					lDifSimu 	:= .T.
// 				EndIf
// 				If lPE505
// 					aRetPE := ExecBlock("GFEA05A5",.f.,.f.,{GWH->GWH_FILIAL, GWH->GWH_NRCALC, lCalcSimu, lDifSimu})

// 					If ValType(aRetPE) == "A" .And. !Empty(aRetPE)
// 						lCalcSimu 	:= aRetPE[1]
// 						lDifSimu 	:= aRetPE[2]
// 					EndIf
// 				EndIf
// 			Else
// 				// Senão existe cálculo para o documento de carga, lDifSimu fica igual a .T.
// 				lDifSimu 	:= .T.
// 			EndIf

// 			GW1->(dbSkip())
// 		EndDo

// 		// Verificação das variáveis de controle para efetuar o retorno com o erro ou a alteração do romaneio para calculado com sucesso
// 		If lDCBloq
// 			// Existe documento de carga bloqueado, é retornado o erro e modificado a situação do romaneio para necessita recálculo
// 			aRet := {.F., "Não foi possível alterar a situação do cálculo para 'Calculado com sucesso'. Verifique se existem documentos de carga com a situação 'bloqueado'. Documentos Bloqueados: " + cNumBloq}

// 			GWN->(dbSeek(cNrRoman)) 
// 			RecLock('GWN', .F. )
// 			GWN->GWN_CALC   := "4"
// 			GWN->GWN_MTCALC := ""
// 			GWN->GWN_DTCALC := DATE()
// 			GWN->GWN_HRCALC := TIME()
// 			GWN->(MsUnlock())

// 			If !Empty(GWN->GWN_VIAGEM) 
// 				GFE58ATVG(GWN->GWN_VIAGEM,GWN->GWN_CALC,GWN->GWN_MTCALC,GWN->GWN_DTCALC,GWN->GWN_HRCALC,GWN->GWN_FILIAL,GWN->GWN_NRROM)
// 			EndIf
// 		Else
// 			// Verifica se existe documentos de carga com simulação junto aos sem cálculo, caso exista retorna erro e o romaneio fica 
// 			// como necessita recálculo
// 			If lCalcSimu .And. lDifSimu
// 				aRet := {.F., "Não foi possível alterar a situação do cálculo para 'Calculado com sucesso'. Existem documentos de carga vinculados a uma simulação e outros que não possuem cálculo. Para esta situação devem ser criados dois romaneios ou deletado o cálculo de simulação através da rotina do cálculo combinado. Documentos com simulação: " + cNumSimu }

// 				GWN->(dbSeek(cNrRoman))
// 				RecLock('GWN', .F. )
// 				GWN->GWN_CALC   := "4"
// 				GWN->GWN_MTCALC := ""
// 				GWN->GWN_DTCALC := DATE()
// 				GWN->GWN_HRCALC := TIME()
// 				GWN->(msUnlock())

// 				If !Empty(GWN->GWN_VIAGEM) 
// 					GFE58ATVG(GWN->GWN_VIAGEM,GWN->GWN_CALC,GWN->GWN_MTCALC,GWN->GWN_DTCALC,GWN->GWN_HRCALC,GWN->GWN_FILIAL,GWN->GWN_NRROM)
// 				EndIf				
// 			Else
// 				// Se não ocorrer nenhum erro e existir cálculo de simulação, o romaneio passa a calculado com sucesso
// 				If lCalcSimu
// 					GWN->(dbSeek(cNrRoman)) 

// 					RecLock('GWN', .F. )
// 					GWN->GWN_CALC   := "1"
// 					GWN->GWN_MTCALC := ""
// 					GWN->GWN_DTCALC := DDATABASE
// 					GWN->GWN_HRCALC := SubStr(TIME(), 1, 5)
// 					GWN->(MsUnlock())

// 					GW1->(dbSetOrder(9))
// 					GW1->(dbSeek(cNrRoman))

// 					While !GW1->(Eof()) .And. cNrRoman == GW1->GW1_FILIAL + GW1->GW1_NRROM

// 						GWH->(dbSeek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC))
// 						// busca pelos cálculos do documento
// 						While !GWH->(Eof()) .And. GW1->GW1_FILIAL == GWH->GWH_FILIAL;
// 						.And. GW1->GW1_CDTPDC == GWH->GWH_CDTPDC;
// 						.And. GW1->GW1_EMISDC == GWH->GWH_EMISDC;
// 						.And. GW1->GW1_SERDC  == GWH->GWH_SERDC; 
// 						.And. GW1->GW1_NRDC   == GWH->GWH_NRDC 

// 							If GWF->(dbSeek(GWH->GWH_FILIAL + GWH->GWH_NRCALC))	.And. GWF->GWF_ORIGEM == '4'
// 								If Empty(GWF->GWF_NRROM) .And. !Empty(cNrRoman)
// 									Reclock("GWF",.F.)
// 									GWF->GWF_NRROM := SubStr(cNrRoman,FWSizeFilial()+1)
// 									msUnlock("GWF")
// 								EndIf
// 							EndIf

// 							If lPE506
// 								aRet := ExecBlock("GFEA05A6",.f.,.f.,{GWH->GWH_FILIAL, GWH->GWH_NRCALC, cNrRoman})
// 							EndIf

// 							GWH->(dbSkip())
// 						EndDo
// 						GW1->(dbSkip())
// 					EndDo
// 				EndIf
// 			EndIf
// 		EndIf
// 	EndIf

// 	RestArea(aAreaGWN)
// 	RestArea(aAreaGWH)
// 	RestArea(aAreaGW1)
// Return aRet

// //Uso do Pergunte GFEA050
// Static Function GFE50VLDP(cTrp)
// 	Local lRet	:=	.T.

// 	If cTrp <> GWN->GWN_CDTRP .And. SuperGetMv("MV_GFETRP",.F.,"1") == "2"
// 		Help(,,'HELP',,'Conforme definido pelos Parâmetros do Módulo, não é permitido redefinir o Transportador das Cargas pelo Romaneio. O Transportador do Romaneio deve ser o mesmo Transportador do primeiro trecho dos Documentos de Carga',1,0)
// 		lRet := .F.
// 	EndIf
// Return lRet

// //Abre uma tela de pesquisa que permite a marcação de documentos de carga na lista superior
// Static Function GFEA050ADC()
// 	Local aAreaGW1 := GW1->( GetArea() )
// 	Local aPosEnch := {}
// 	Local cFilBkp  := cFilAnt
	
// 	Private cGW1NRDC   := Space(TamSX3("GW1_NRDC"  )[1])
// 	Private cGW1CDTPDC := Space(TamSX3("GW1_CDTPDC")[1])
// 	Private cGW1SERDC  := Space(TamSX3("GW1_SERDC" )[1])
// 	Private cGW1EMISDC := Space(TamSX3("GW1_EMISDC")[1])
// 	Private oGetNrDc   := Nil
// 	Private lReload    := .F.
// 	Private oWind      := Nil
// 	Private cGW1FIL    := GWN->GWN_FILIAL
// 	Private oGetFil    := Nil

// 	SetKey(VK_F10,{||GFEA050ADD()})

// 	GW1->(dbSetOrder(8))

// 	oSize := FWDefSize():New(.T.)
// 	oSize:AddObject( "ENCHOICE", 200, 110, .T., .T. ) // Adiciona enchoice
// 	oSize:SetWindowSize({000, 000, 150, 600})
// 	oSize:lLateral     := .F.  // Calculo vertical	
// 	oSize:Process() //executa os calculos

// 	aPosEnch := {oSize:GetDimension("ENCHOICE","LININI"),;
// 	oSize:GetDimension("ENCHOICE","COLINI"),;
// 	oSize:GetDimension("ENCHOICE","LINEND"),;
// 	oSize:GetDimension("ENCHOICE","COLEND")}

// 	DEFINE MSDIALOG oWind TITLE "Busca de documento de carga" ;
// 	FROM oSize:aWindSize[1],oSize:aWindSize[2] ;
// 	TO oSize:aWindSize[3],oSize:aWindSize[4] ; 
// 	PIXEL	
// 	s_MULFIL   := SuperGetMV("MV_MULFIL",.F.,"2")
// 	TSay():New(aPosEnch[1]+010,aPosEnch[2]+0014,{|| "Filial"},oWind,,,,,,.T.,,,50,10,)
// 	oGetFil := TGet():New(aPosEnch[1]+017,aPosEnch[2]+0014,bSETGET(cGW1FIL),oWind,50,10,"@!",/*bValid*/,,,,,,.T.,,,{||s_MULFIL == "1"}/*bWhen*/,,,{|x| GFEA050FVL(cGW1FIL)}/*bChange*/,.F.,.F.,,"cGW1FIL",,,,.T.)
// 	oGetFil:cF3 := "SM0"
	
// 	TSay():New(aPosEnch[1]+010,aPosEnch[2]+065,{|| "Nr Documento"},oWind,,,,,,.T.,,,60,10,)
// 	oGetNrDc := TGet():New(aPosEnch[1]+017,aPosEnch[2]+065,bSETGET(cGW1NRDC),oWind,60,10,"@!",/*bValid*/,,,,,,.T.,,,/*bWhen*/,,,{|x|GFEA050ASQ()},.F.,.F.,,"cGW1NRDC",,,,.T.)
// 	oGetNrDc:cF3 := "GFEGW4"

// 	TSay():New(aPosEnch[1]+010,aPosEnch[2]+125,{|| "Tipo"},oWind,,,,,,.T.,,,50,10,)
// 	oGet := TGet():New(aPosEnch[1]+017,aPosEnch[2]+125,bSETGET(cGW1CDTPDC),oWind,50,10,"@!",/*bValid*/,,,,,,.T.,,,/*bWhen*/,,,/*bChange*/,.F.,.F.,,"cGW1CDTPDC")

// 	TSay():New(aPosEnch[1]+010,aPosEnch[2]+180,{|| "Série"},oWind,,,,,,.T.,,,50,10,)
// 	oGet := TGet():New(aPosEnch[1]+017,aPosEnch[2]+180,bSETGET(cGW1SERDC),oWind,50,10,"@!",/*bValid*/,,,,,,.T.,,,/*bWhen*/,,,/*bChange*/,.F.,.F.,,"cGW1SERDC")

// 	TSay():New(aPosEnch[1]+010,aPosEnch[2]+235,{|| "Emissor"},oWind,,,,,,.T.,,,50,10,)
// 	oGet := TGet():New(aPosEnch[1]+017,aPosEnch[2]+235,bSETGET(cGW1EMISDC),oWind,50,10,"@!",/*bValid*/,,,,,,.T.,,,/*bWhen*/,,,/*bChange*/,.F.,.F.,,"cGW1EMISDC")
// 	oGetNrDc:SetFocus()
// 	oGetFil:SetFocus()
// 	oWind:Activate(,,,.T.,,,{|| EnchoiceBar(oWind, {|| GFEA050ADD() }, {|| lReload := .F., oWind:End() },,)})
// 	SetKey(VK_F10,{||})
// 	RestArea(aAreaGW1)
// 	If lReload
// 		lReload := .F.
// 		oPanelB:Refresh()
// 		GFEA050ADC()
// 	EndIf
// 	cFilAnt := cFilBkp
// Return

// //Busca e marca um documento na lista acima. se não achar, pergunta se o usuário deseja adicionar mesmo assim.
// Static Function GFEA050ADD()
// 	Local nPos := 0
// 	Local cQuery 
// 	Local cGW1 
// 	local lRetPE := .F.

// 	if aScan(aDocSel,{|x| 	x[05] == cGW1CDTPDC .AND. ;
// 	x[07] == cGW1EMISDC .AND. ;
// 	x[03] == cGW1SERDC  .AND. ;
// 	x[04] == cGW1NRDC},1,1) > 0
// 		Help(,,'HELP',,'Documento de carga já está relacionado ao Romaneio.',1,0)
// 		Return
// 	EndIf

// 	nPos := aScan(aDocFil,{|x| 	x[05] == cGW1CDTPDC .AND. ;
// 	x[07] == cGW1EMISDC .AND. ;
// 	x[03] == cGW1SERDC  .AND. ;
// 	x[04] == cGW1NRDC})

// 	If nPos > 0
// 		aDocFil[nPos,01] := .T.
// 		GFEA50AOK()
// 	Else
// 		GWU->(dbSetOrder(1))
// 		If GWU->(dbSeek(cGW1FIL+cGW1CDTPDC+cGW1EMISDC+cGW1SERDC+cGW1NRDC+'01'))
// 			If GWN->GWN_CDTRP <> GWU->GWU_CDTRP
// 				If SuperGetMv("MV_GFETRP",.F.,"1") == "2"
// 					Help(,,'HELP',,'Conforme definido pelo Parâmetro do Módulo, não é permitido redefinir o Transportador da Carga pelo Romaneio. O Transportador do Romaneio deve ser o mesmo Transportador do primeiro trecho do Documento de Carga',1,0)
// 					Return
// 				Else
// 					If lPE507
// 						lRetPE := ExecBlock("GFEA05A7",.F.,.F.)
// 					Endif
// 					If !lRetPE
// 						If !MsgYesNo("O Transportador do Romaneio difere do primeiro trecho do Documento de Carga. Confirma redefinição do transportador do primeiro trecho?")
// 							Return
// 						EndIf
// 					Endif
// 				EndIf
// 			EndIf

// 			cQuery := "SELECT GW1.GW1_FILIAL FILIAL, GW1.GW1_SERDC SERIE, GW1.GW1_NRDC NRDC, GW1.GW1_CDTPDC TPDC, "
// 			cQuery += GFEA66CASE("GW1", "GW1_TPFRET", "TPFRET", "''") + ", "
// 			cQuery += "      	GW1.GW1_EMISDC CDEMIS, GU3EMI.GU3_NMEMIT NMEMIS, GW1.GW1_CDREM CDREM, "
// 			cQuery += "		GU3REM.GU3_NMEMIT NMREM, GW1.GW1_CDDEST CDDEST, GU3DES.GU3_NMEMIT NMDEST, GW1.GW1_NRREG NRREG, "
// 			cQuery += "		GW1.GW1_DTEMIS DTEMIS, GW1.GW1_DTPSAI DTSAI, "
// 			cQuery += "		(CASE GW1.GW1_ENTNRC "
// 			cQuery += "			WHEN '' THEN GU3DES.GU3_NRCID"
// 			cQuery += "	   		ELSE GW1.GW1_ENTNRC "
// 			cQuery += " 		END) NRCID, "
// 			cQuery += "		(CASE GW1.GW1_ENTNRC "
// 			cQuery += "			WHEN '' THEN GU7DEST.GU7_NMCID"
// 			cQuery += "	   		ELSE GU7DOC.GU7_NMCID "
// 			cQuery += " 		END) CIDDES, "
// 			cQuery += "		(CASE GW1.GW1_ENTNRC "
// 			cQuery += "			WHEN '' THEN GU7DEST.GU7_CDUF"
// 			cQuery += "	   		ELSE GU7DOC.GU7_CDUF "
// 			cQuery += " 		END) UFDEST, "	
// 			cQuery += " 		GW1.GW1_QTVOL, GW1.GW1_NRROM, GW1.GW1_SIT, GV5DOC.GV5_SENTID, GV4DOC.GV4_SENTID "	
// 			cQuery += "FROM " + RetSQLName("GW1") + " GW1 "
// 			cQuery += "INNER JOIN " + RetSQLName("GU3") + " GU3EMI  ON GU3EMI.GU3_FILIAL  = '" + xFilial("GU3") + "' AND GU3EMI.GU3_CDEMIT = GW1.GW1_EMISDC   AND GU3EMI.D_E_L_E_T_ = ' ' "
// 			cQuery += "INNER JOIN " + RetSQLName("GU3") + " GU3REM  ON GU3REM.GU3_FILIAL  = '" + xFilial("GU3") + "' AND GU3REM.GU3_CDEMIT = GW1.GW1_CDREM    AND GU3REM.D_E_L_E_T_ = ' ' "
// 			cQuery += "INNER JOIN " + RetSQLName("GU3") + " GU3DES  ON GU3DES.GU3_FILIAL  = '" + xFilial("GU3") + "' AND GU3DES.GU3_CDEMIT = GW1.GW1_CDDEST   AND GU3DES.D_E_L_E_T_ = ' ' "
// 			cQuery += "LEFT  JOIN " + RetSQLName("GU7") + " GU7DEST ON GU7DEST.GU7_FILIAL = '" + xFilial("GU7") + "' AND GU7DEST.GU7_NRCID = GU3DES.GU3_NRCID AND GU7DEST.D_E_L_E_T_ = ' ' "
// 			cQuery += "LEFT  JOIN " + RetSQLName("GU7") + " GU7DOC  ON GU7DOC.GU7_FILIAL  = '" + xFilial("GU7") + "' AND GU7DOC.GU7_NRCID  = GW1.GW1_ENTNRC   AND GU7DOC.D_E_L_E_T_ = ' ' "
// 			cQuery += "LEFT  JOIN " + RetSQLName("GV5") + " GV5DOC  ON GV5DOC.GV5_FILIAL  = '" + xFilial("GV5") + "' AND GV5DOC.GV5_CDTPDC = GW1.GW1_CDTPDC   AND GV5DOC.D_E_L_E_T_ = ' ' "
// 			cQuery += "LEFT  JOIN " + RetSQLName("GV4") + " GV4DOC  ON GV4DOC.GV4_FILIAL  = '" + xFilial("GV4") + "' AND GV4DOC.GV4_CDTPOP = '" +GWN->GWN_CDTPOP+ "' AND GV4DOC.D_E_L_E_T_ = ' ' " 
			
// 			cQuery += " WHERE GW1.GW1_FILIAL = '" + cGW1FIL + "'"
// 			cQuery += " AND GW1.GW1_CDTPDC = '" + cGW1CDTPDC + "'"
// 			cQuery += " AND GW1.GW1_EMISDC = '" + cGW1EMISDC + "'"
// 			cQuery += " AND GW1.GW1_SERDC = '" + cGW1SERDC + "'"
// 			cQuery += " AND GW1.GW1_NRDC = '" + cGW1NRDC + "'"
// 			cQuery += " AND GW1.D_E_L_E_T_ = ' '"

// 			cQuery := ChangeQuery(cQuery)
// 			cGW1 := GetNextAlias()

// 			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cGW1, .F., .T.)
// 			dbSelectArea(cGW1)

// 			If !Empty((cGW1)->GW1_NRROM) .And. (cGW1)->GW1_NRROM != GWN->GWN_NRROM
// 				Help(,,'HELP',,'Documento de carga já está relacionado a outro Romaneio.',1,0)
// 				(cGW1)->( dbCloseArea() )
// 				Return
// 			EndIf
// 			If (cGW1)->GW1_SIT != "3"
// 				Help(,,'HELP',,'Documento de carga deve estar liberado.',1,0)
// 				(cGW1)->( dbCloseArea() )
// 				Return
// 			EndIf
// 			If !((cGW1)->GV5_SENTID == (cGW1)->GV4_SENTID .Or. (cGW1)->GV4_SENTID == '0')
// 				Help(,,'HELP',,'Sentido da carga deve ser o mesmo do documento de carga.',1,0)
// 				(cGW1)->( dbCloseArea() )
// 				Return
// 			EndIf

// 			AaDD(aDocFil,{.T.,;
// 						  (cGW1)->FILIAL  ,; 
// 						  (cGW1)->SERIE   ,;
// 						  (cGW1)->NRDC    ,;
// 						  (cGW1)->TPDC    ,;
// 						  (cGW1)->TPFRET  ,;
// 						  (cGW1)->CDEMIS  ,;
// 						  (cGW1)->NMEMIS  ,;
// 						  (cGW1)->CDREM   ,;
// 						  (cGW1)->NMREM   ,;
// 						  (cGW1)->CDDEST  ,; 
// 						  (cGW1)->NMDEST  ,;
// 						  (cGW1)->NRREG   ,;
// 						  (cGW1)->NRCID   ,;
// 						  (cGW1)->DTEMIS  ,;
// 						  (cGW1)->DTSAI   ,;
// 						  (cGW1)->CIDDES  ,;
// 						  (cGW1)->UFDEST  ,;
// 						  (cGW1)->GW1_QTVOL })
// 			(cGW1)->( dbCloseArea() )
// 			GFEA50AOK()
// 		Else
// 			Help(,,'HELP',,'Documento de carga não localizado',1,0)
// 			Return
// 		EndIf
// 	EndIf

// 	cGW1NRDC   := Space(TamSX3("GW1_NRDC"  )[1])
// 	cGW1CDTPDC := Space(TamSX3("GW1_CDTPDC")[1])
// 	cGW1SERDC  := Space(TamSX3("GW1_SERDC" )[1])
// 	cGW1EMISDC := Space(TamSX3("GW1_EMISDC")[1])

// 	oGetNrDc:SetFocus()
// 	oGetFil:SetFocus()
// 	lReload := .T.
// 	oWind:End()
// Return

// //Pesquisa e preenche os outros campos se achar um documento de carga válido pelo número
// Static Function GFEA050ASQ()
// 	Local cAliasQ
// 	Local cQuery 	:= ""
// 	Local aDCMark 	:= {}
// 	Local nI 		:= 0
	
// 	For nI:= 1 To Len(aDocSel)
// 		aAdd(aDCMark,aDocSel[nI,5] + aDocSel[nI,7] + aDocSel[nI,3] + aDocSel[nI,4])
// 	Next

// 	cQuery := "SELECT GW1.GW1_FILIAL, GW1.GW1_SERDC SERIE, GW1.GW1_NRDC NRDC, GW1.GW1_CDTPDC TPDC, GW1.GW1_EMISDC CDEMIS"
// 	cQuery += "  FROM " + RetSQLName("GW1") + " GW1 "
// 	cQuery += " INNER JOIN " + RetSQLName("GV5") + " GV5 ON GV5.GV5_FILIAL = '" + xFilial("GV5") + "' AND GV5.GV5_CDTPDC = GW1.GW1_CDTPDC AND GV5.D_E_L_E_T_ = ' '"
// 	cQuery += " INNER JOIN " + RetSQLName("GWU") + " GWU ON GWU.GWU_FILIAL = '" + xFilial("GWU") + "' AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC AND GWU.GWU_EMISDC = GW1.GW1_EMISDC AND GWU.GWU_SERDC = GW1.GW1_SERDC AND GWU.GWU_NRDC = GW1.GW1_NRDC AND GWU.GWU_SEQ = '01' AND GWU.D_E_L_E_T_ = ' '"
// 	cQuery += " INNER JOIN " + RetSQLName("GV4") + " GV4 ON GV4.GV4_FILIAL = '" + xFilial("GV4") + "' AND GV4.GV4_CDTPOP = '" + GWN->GWN_CDTPOP + "' AND GV4.D_E_L_E_T_ = ' ' "
// 	cQuery += "  LEFT JOIN " + RetSQLName("GW4") + " GW4 ON GW4.GW4_FILIAL = '" + xFilial("GW4") + "' AND GW4.GW4_TPDC = GW1.GW1_CDTPDC AND GW4.GW4_EMISDC = GW1.GW1_EMISDC AND GW4.GW4_SERDC = GW1.GW1_SERDC AND GW4.GW4_NRDC = GW1.GW1_NRDC  AND GW4.D_E_L_E_T_ = ' '"
// 	cQuery += " WHERE GW1.GW1_SIT = '3'" 
// 	cQuery += "   AND GW1.GW1_NRDC = '" + cGW1NRDC + "'"
// 	cQuery += "	  AND (GW1.GW1_NRROM = '' OR GW1.GW1_NRROM = '0') AND (GV5.GV5_SENTID = GV4.GV4_SENTID OR GV4.GV4_SENTID = '0')"
// 	cQuery += "	  AND (GV5.GV5_SENTID = GV4.GV4_SENTID OR GV4.GV4_SENTID = '0')"
// 	cQuery += "	AND GW1.GW1_FILIAL = '" +cGW1FIL+ "'"
// 	cQuery += "	AND GW4.GW4_NRDF IS NULL AND GW1.D_E_L_E_T_ = ' ' "
// 	cQuery += "	ORDER BY GW1.GW1_NRDC"
// 	cAliasQ := GetNextAlias()
// 	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQ, .F., .T.)
// 	While !(cAliasQ)->(Eof())
// 		If aScan(aDCMark,{|x| x == (cAliasQ)->(TPDC+CDEMIS+SERIE+NRDC)}) == 0
// 			cGW1NRDC	:= (cAliasQ)->NRDC
// 			cGW1CDTPDC	:= (cAliasQ)->TPDC
// 			cGW1SERDC	:= (cAliasQ)->SERIE
// 			cGW1EMISDC	:= (cAliasQ)->CDEMIS
// 			(cAliasQ)->(dbCloseArea())
// 			Return
// 		EndIf
// 		(cAliasQ)->(dbSkip())
// 	EndDo
// 	(cAliasQ)->(dbCloseArea())
// Return

// Static Function GFEA50AD(nAt)
// 	If !GFE50ALINV(aDocFil)
// 		Return .T.
// 	EndIf

// 	If Len(aDocFil) > 0
// 		aDocFil[nAt,1] := !aDocFil[nAt,1]
// 		GFEA50ARDP(nAt)
// 		GFEA50RD()
// 	EndIf
// Return

// Static Function GFEA50AE(nAt)
// 	If !GFE50ALINV(aDocSel)
// 		Return .T.
// 	EndIf
	
// 	If Len(aDocSel) > 0
// 		aDocSel[nAt,1] := !aDocSel[nAt,1]
// 	EndIf
// Return

// Static function GFE50ASORT(lDocFil,lDocSel)
// 	Local cOrdemPE1 := ""
// 	Local cOrdemPE2 := ""

// 	If ExistBlock("GFEA05A2")
// 		cOrdemPE1 := ExecBlock("GFEA05A2",.f.,.f., {"1"}) 
// 	EndIf

// 	If ExistBlock("GFEA05A2")
// 		cOrdemPE2 := ExecBlock("GFEA05A2",.f.,.f., {"2"}) 
// 	EndIf

// 	cOrdDocCa := GFEArrOrd(cOrdemPE1)
// 	cOrdDocC2 := GFEArrOrd(cOrdemPE2)

// 	If lDocFil
// 		If Len(aDocFil) > 0
// 			aSort(aDocFil,,,{|x,y| &(cOrdDocCa)})
// 		EndIf
// 	EndIf
// 	If lDocSel
// 		If Len(aDocSel) > 0
// 			aSort(aDocSel,,,{|x,y| &(cOrdDocC2)})
// 		EndIf
// 	EndIf
// Return .T.

// Static Function GFEArrOrd(cOrdemPE)

// 	Local aOrdemPE := {}
// 	Local cOrdDocx := ""
// 	Local cOrdDocy := ""
// 	Local cOrdDC := ""
// 	Local nI

// 	If !Empty(cOrdemPE)
// 		aOrdemPE := StrToKArr(cOrdemPE, ';')

// 		cOrdDocx := "x[" + aOrdemPE[1] + "]" 
// 		cOrdDocy := "y[" + aOrdemPE[1] + "]"

// 		For nI:= 2 to Len(aOrdemPE)
// 			cOrdDocx += "+x[" + aOrdemPE[nI] + "]" 
// 			cOrdDocy += "+y[" + aOrdemPE[nI] + "]" 
// 		Next

// 		cOrdDC := cOrdDocx + " < " + cOrdDocy
// 	Else
// 		cOrdDC := "x[4]+x[6]+x[2]+x[3] < y[4]+y[6]+y[2]+y[3]"
// 	EndIf
// Return cOrdDC

// Static Function GFE50ADELARRAY(aDoc)
// 	if !GFE50ALINV(aDoc)
// 		aDel(aDoc,1)
// 		ASize(aDoc,0)
// 	EndIf
// Return .T.

// Static Function GFE50ALINV(aDoc)
// 	If Len(aDoc) = 1
// 		chkSerieEmpty(@aDoc)	// Adiciona caracter na serie
// 		If Empty(aDoc[1,3])
// 			Return .F.
// 		EndIf
// 		chkSerieEmpty(@aDoc)	// remove caracter na serie
// 	EndIf
// Return .T.

// Static Function GFEA050FVL(cGW1FIL)
// 	IF cGW1FIL == cFilAnt
// 		Return .F.
// 	Else 
// 		cFilAnt := cGW1FIL
// 	EndIf
// Return .T.

// Static Function chkSerieEmpty(aDoc)
// 	Local nI        := 0
// 	Local cTamSerie := Space(TamSx3("GW1_SERDC")[1])

// 	For nI := 1 To Len(aDoc)
// 		If Empty(aDoc[nI][3]) .And. (!Empty(aDoc[nI][2]) .And. !Empty(aDoc[nI][5]) .And. !Empty(aDoc[nI][7]) .And. !Empty(aDoc[nI][4]))
// 			aDoc[nI][3] := "-"
// 		ElseIf Alltrim(aDoc[nI][3]) = "-" .And. (!Empty(aDoc[nI][2]) .And. !Empty(aDoc[nI][5]) .And. !Empty(aDoc[nI][7]) .And. !Empty(aDoc[nI][4]))
// 			aDoc[nI][3] := cTamSerie
// 		EndIf
// 	Next
// Return
