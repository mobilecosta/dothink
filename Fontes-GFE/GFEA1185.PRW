#include "totvs.ch"
/*/{Protheus.doc} GFEA1185
PE validacoes de CT-e para atribuir a situacao 'Erro Impeditivo'
@type function
@version 20250818
@author luiz.favareto@dothink.com.br
@since 29/06/2025
@history 22/07/2025, luiz.favareto, posicionamento romaneio GWN antes da chamada da GFE050CALC
@history 24/07/2025, luiz.favareto, tratamento para CTE com array de chaves danfe INFDOC
@history 11/08/2025, luiz.favareto, tratamento para CTE remente Barentz ou xCaracad devolucao
@history 13/08/2025, luiz.favareto, ajuste calculo romaneio somente uma vez apos todas danfes terem sido lidas, e rateio peso cubado todos itens de todas danfes
@history 14/08/2025, luiz.favareto, controle filial do CTE emitente ou na devolucao destinatario
@history 18/08/2025, luiz.favareto, Correcao posicionamento empresa/filial
@return logical, sempre .T.
@obs Conforme Projeto Logico 001 do Projeto no. 20250528008v02 referente ao servico de Revitalizacao do Gestao de Frete Embarcador (SIGAGFE TOTVS Protheus) e Integracao com o SIGAACD (Automacao e Coleta de Dados)
/*/
User Function GFEA1185
    Local aArea      as array
    Local oLocCte    as object
    Local cChaveCte  as character
    Local cXCaracAd  as character
    Local cFilBkp    as character
    Local lGFEA1185  as boolean
    Local lContinua  as boolean
    Local aGetInfQ   as array
    Local aVolumes   as array
    Local nGW8PESOR  as numeric
    Local nGW8PESOX1 as numeric
    Local nGW8PESOX2 as numeric
    Local nSM0RECNO  as numeric
    Local nY         as numeric
    LocaL lOnlyCubad as boolean
    Local aChaves    as array
    Local xInfDoc    as variant
    Local lRet       as boolean
    Iif(lGFEA1185:=SuperGetMv("BA_GFA185L",,.T.),ConOut(ProcName()+" => INICIO"),)
    If cTpCte=="0".And.(lContinua:=SuperGetMv("BA_GFA185A",,.T.))
        oLocCte := PARAMIXB[1]
        If (.Not.XmlChildEx(oLocCte,"_INFCTE")==Nil).And. ;
           (.Not.XmlChildEx(oLocCte:_INFCTE,"_INFCTENORM")==Nil).And. ;
           (.Not.(XmlChildEx(oLocCte:_INFCTE:_INFCTENORM,"_INFDOC"))==Nil).And. ;
           (.Not.(xInfDoc:=XmlChildEx(oLocCte:_INFCTE:_INFCTENORM:_INFDOC,"_INFNFE"))==Nil)
            lContinua := lContinua.And.(.Not.XmlChildEx(oLocCte:_INFCTE,"_REM")==Nil)
            lContinua := lContinua.And.(.Not.XmlChildEx(oLocCte:_INFCTE:_REM,"_CNPJ")==Nil)
            If lContinua
                If ((.Not.XmlChildEx(oLocCte:_INFCTE,"_COMPL")==Nil).And.(.Not.XmlChildEx(oLocCte:_INFCTE:_COMPL,"_XCARACAD")==Nil).And."DEVOLU"$XmlValid(oLocCte,{"_INFCTE","_COMPL"},"_XCARACAD"))
                    lContinua := lContinua.And.(.Not.XmlChildEx(oLocCte:_INFCTE,"_DEST")==Nil)
                    lContinua := lContinua.And.(.Not.XmlChildEx(oLocCte:_INFCTE:_DEST,"_CNPJ")==Nil)
                    lContinua := lContinua.And.(nSM0RECNO:=MpSysExecScalar("select R_E_C_N_O_ REC from SYS_COMPANY where D_E_L_E_T_=' ' and M0_CGC="+ValToSql(oLocCte:_INFCTE:_DEST:_CNPJ:TEXT),"REC"))>0
                Else
                    lContinua := lContinua.And.(nSM0RECNO:=MpSysExecScalar("select R_E_C_N_O_ REC from SYS_COMPANY where D_E_L_E_T_=' ' and M0_CGC="+ValToSql(oLocCte:_INFCTE:_REM:_CNPJ:TEXT),"REC"))>0
                Endif
                If lContinua
                    SM0->(DbGoTo(nSM0RECNO))
                    cFilBkp := cFilAnt
                    cFilAnt := SM0->M0_CODFIL
                Endif
            Endif
            If (lRet := lContinua)
                aChaves := {}
                If ValType(xInfDoc)=="A"
                    For nY := 1 To Len(xInfDoc)
                        If .Not.XmlChildEx(xInfDoc[nY],"_CHAVE")==Nil.And. ;
                        .Not.(cChaveCte:=XmlChildEx(xInfDoc[nY]:_CHAVE,"TEXT"))==Nil.And. ;
                        ValType(cChaveCte)=="C".And.Len(Alltrim(cChaveCte))==44
                            Aadd(aChaves,cChaveCte)
                        Endif
                    Next
                Elseif ValType(xInfDoc)=="O".And. ;
                .Not.XmlChildEx(xInfDoc,"_CHAVE")==Nil.And. ;
                .Not.(cChaveCte:=XmlChildEx(xInfDoc:_CHAVE,"TEXT"))==Nil.And. ;
                ValType(cChaveCte)=="C".And.Len(Alltrim(cChaveCte))==44
                    Aadd(aChaves,xInfDoc:_CHAVE:TEXT)
                Endif
                aArea := Lj7GetArea({"GW1","GW8","GWN"})
                lContinua := lContinua.And.GW1->(DBOrderNickname("DANFE")) // GW1_DANFE+GW1_FILIAL
                If lContinua.And.(.Not.XmlChildEx(oLocCte:_INFCTE,"_COMPL")==Nil).And.(.Not.XmlChildEx(oLocCte:_INFCTE:_COMPL,"_XCARACAD")==Nil)
                    cXCaracAd := XmlValid(oLocCte,{"_INFCTE","_COMPL"},"_XCARACAD")
                    lContinua := .Not.("REENTREGA"$cXCaracAd.Or."REFATURAMENTO"$cXCaracAd.Or."SERVI"$cXCaracAd) // .Or."DEVOLU"$cXCaracAd
                Endif
                lContinua := lContinua.And.(.Not.XmlChildEx(oLocCte:_INFCTE,"_INFCTENORM")==Nil)
                lContinua := lContinua.And.(.Not.XmlChildEx(oLocCte:_INFCTE:_INFCTENORM,"_INFCARGA")==Nil)
                lContinua := lContinua.And.(.Not.XmlChildEx(oLocCte:_INFCTE:_INFCTENORM:_INFCARGA,"_INFQ")==Nil)
                lOnlyCubad := SuperGetMv("BA_GFA185C",,.T.) // peso cubado somente ?
                lContinua := lContinua.And.(aGetInfQ:=GetInfQ(oLocCte))[3]>0.Or.(.Not.lOnlyCubad.And.aGetInfQ[2]>0) // peso cubado ou peso real
                Begintran()
                    If lContinua
                        nGW8PESOR := 0
                        aVolumes  := {}
                        For nY := 1 To Len(aChaves)
                            cChaveCte := aChaves[nY]
                            If GW1->(MsSeek(Padr(cChaveCte,GetSx3Cache("GW1_DANFE","X3_TAMANHO"))+xFilial("GW1")))
                                GW8->(DbSetOrder(2)) // GW8_FILIAL+GW8_CDTPDC+GW8_EMISDC+GW8_SERDC+GW8_NRDC+GW8_SEQ
                                GW8->(MsSeek((cChaveGW1:=GW1->(GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC))+"0"))
                                While cChaveGW1==GW8->(GW8_FILIAL+GW8_CDTPDC+GW8_EMISDC+GW8_SERDC+GW8_NRDC)
                                    nGW8PESOR += Iif(GW8->GW8_PESOR>0,GW8->GW8_PESOR,1)
                                    Aadd(aVolumes,GW8->(Recno()))
                                    GW8->(DbSkip())
                                Enddo
                            Endif
                        Next
                    Endif
                    If lContinua.And.(.Not.Empty(GW1->(GW1_FILROM+GW1_NRROM)))
                        nGW8PESOX1 := nGW8PESOR
                        For nY := 1 To Len(aVolumes)
                            GW8->(DbGoTo(aVolumes[nY]))
                            RecLock("GW8",.F.)
                            If nY=Len(aVolumes)
                                nGW8PESOX2 := nGW8PESOX1
                            Else
                                nGW8PESOX2 := Round(Iif(aGetInfQ[3]>0,aGetInfQ[3],aGetInfQ[2])*GW8->GW8_PESOR/nGW8PESOR,GetSx3Cache("GW8_VOLUME","X3_DECIMAL"))
                                nGW8PESOX1 -= nGW8PESOX2
                            Endif
                            GW8->GW8_VOLUME := Round(Iif(aGetInfQ[3]>0,aGetInfQ[3],aGetInfQ[2])*GW8->GW8_PESOR/nGW8PESOR,GetSx3Cache("GW8_VOLUME","X3_DECIMAL"))
                            GW8->(MsUnLock())
                        Next
                        GWN->(DbSetOrder(1)) // GWN_FILIAL+GWN_NRROM
                        If GWN->(MsSeek(GW1->(GW1_FILROM+GW1_NRROM)))
                            GFE050CALC()
                        Endif
                    Endif
                Endtran()
                Lj7RestArea(aArea)
            Endif
        Endif
    Endif
    Iif(.Not.Empty(cFilBkp),cFilAnt:=cFilBkp,)
    Iif(lGFEA1185,ConOut(ProcName()+" => FIM lRet = "+cValToChar(lRet)),)
Return lRet
/*/{Protheus.doc} GetInfQ
Totaliza tag InfQ
@type function
@version 20250629
@author luiz.favareto@dothink.com.br
@since 29/06/2025
@param oLocCte, object, oCte
@return array, {nVolumesM3,nPesoReal,nPesoCubado,nQtdVolumes}
/*/
Static Function GetInfQ(;
        oLocCte as object;
    )
    Local nVolum := 0 as numeric
    Local nPesoR := 0 as numeric
    Local nPesoC := 0 as numeric
    Local nQtVol := 0 as numeric
    Local nX     := 0 as numeric
    Local oXml        as object
    oXml := oLocCte:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ
    If ValType(oXml)=="A"
        For nX := 1 To Len(oXml)
            If oXml[nX]:_CUNID:TEXT=='00' // Volume em Metro Cubico
                nVolum := Val(oXml[nX]:_QCARGA:TEXT)
            ElseIf oXml[nX]:_CUNID:TEXT=='01' // KG
                Iif('CUB'$Upper(oXml[nX]:_TPMED:TEXT),nPesoC:=Val(oXml[nX]:_QCARGA:TEXT),)
                nPesoR := Val(oXml[nX]:_QCARGA:TEXT)
            ElseIf oXml[nX]:_CUNID:TEXT=='02' // TON
                Iif('CUB'$Upper(oXml[nX]:_TPMED:TEXT),nPesoC:=Val(oXml[nX]:_QCARGA:TEXT)*1000,)
                nPesoR := Val(oXml[nX]:_QCARGA:TEXT)*1000
            ElseIf oXml[nX]:_CUNID:TEXT=='03' // Unidades
                nQtVol := NoRound(Val(oXml[nX]:_QCARGA:TEXT))
            Endif
        Next
    ElseIf ValType(oXml)=="O"
        If oXml:_CUNID:TEXT=='00' // Volume em Metro Cubico
            nVolum := Val(oXml:_QCARGA:TEXT)
        ElseIf oXml:_CUNID:TEXT=='01' //KG
            Iif('CUB'$Upper(oXml:_TPMED:TEXT),nPesoC := Val(oXml:_QCARGA:TEXT),)
            nPesoR := Val(oXml:_QCARGA:TEXT)
        ElseIf oXml:_CUNID:TEXT=='02' // TON
            Iif('CUB'$Upper(oXml:_TPMED:TEXT),nPesoC := Val(oXml:_QCARGA:TEXT)*1000,)
            nPesoR := Val(oXml:_QCARGA:TEXT)*1000
        ElseIf oXml:_CUNID:TEXT=='03' // Unidades
            nQtVol := NoRound(Val(oXml:_QCARGA:TEXT))
        Endif
    Endif
Return {nVolum,nPesoR,nPesoC,nQtVol}
