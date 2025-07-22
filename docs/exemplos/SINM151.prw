#Include 'TOTVS.ch'
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FILEIO.CH"

Static aHeader := Nil
Static _aFunc  := {}	// Armazena em memoria endpoint de funcionario e empresa consultados
Static _aEmp   := {}
Static __cLog  := ""

User Function SINM151()
Local lSM0 := Select("SM0")	== 0

	If lSM0
		RpcSetType(3)
		RpcSetEnv( "09", "01")
	EndIF
    Processa( {|| fExamFunc()  }, "Aguarde...", "Carregando..." ,.F.)

	If lSM0
		RpcClearEnv()
	EndIf

Return Nil 

User Function SINJ151()
Local lSM0 := Select("SM0")	== 0

	If lSM0
		RpcSetType(3)
		RpcSetEnv( "09", "01")
	EndIF

    fImpEvento(.T., Str(Year(dDataBase), 4) + "-" + StrZero(Month(dDataBase),2) + "-01")

	If lSM0
		RpcClearEnv()
	EndIf

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} fImpEvento
Consulta endpoint de exames realizados

@author  Wagner Mobile Costa
@since 	 24/04/2025
@version 1.0
/*/ 
//-------------------------------------------------------------------
Static Function fImpEvento(lIsJob, cDate, oSay)
    Local cEmpVinc      := cEmpAnt
	Local cFuncCPF      := ""
    Local cMatric       := ""
    Local cOperac       := "1"
    Local aExames       := {}
    Local aExame        := {}
 	Local aParamBox 	:= {}
	Local axParams  	:= {}
	Local oJson			:= Nil
	Local oExame		:= Nil
	Local oFunc			:= Nil
	Local oSolic		:= Nil
	Local nX			:= 0
    Local nNovosRegs    := 0
    Local lContinua     := .F.
	Local cDateFim      := ""
	Local nPagina       := 0
	Local lProxima      := .F.
	Local cReturn       := ""
	Local cObsProc      := ""
	Local cObs          := ""

	Local cURLSol 		:= "https://app.sgg.net.br/api/v3/exames-realizados/"
	Local cBody 		:= ""
	Local cAccToken 	:= SuperGetMv("MV_XTOKSGG",, "a2ZycHZ2WlVXOHZNRXNvQlNJUjkyZzVxNnVwNFdSTDU6")
	Local aIdEmp        := {}
	Local nIdEmp        := 0
	Local cIdEmp        := ""
	Local nExames       := 0

    Default lIsJob  := .F.	

    __cLog := "SINM151" + Dtos(Date())+StrTran(Time(),":")

	// Configurar cabeçalhos da requisição
	aHeader := {}
	AAdd(aHeader, "Content-Type:application/json")
	AAdd(aHeader, "Accept:application/json")
	AAdd(aHeader, "Authorization: Basic " + cAccToken)

	// Buscar dados da Empresa pelo ID
	aIdEmp := CarEmp()
	If Len(aIdEmp) == 0
	    MsgAlert("Empresa/CNPJ [" + SM0->M0_CODIGO + "/" + Trans(SM0->M0_CGC, "@R 99.999.999/9999-99") + "] não localizado no Sgg.Net")
		Return
	EndIF

    If ! lIsJob
        If ! ApMsgNoYes("A rotina a seguir ira carregar os eventos da Sgg.Net para o Protheus.", "Deseja Continuar ?")
            Return
        EndIf

		cCadastro := "Importação Sgg.Net"

        aAdd(aParamBox,{1,"Data Inicial",CtoD(Space(8)),"","","","",50,.F.}) // Tipo data
                
        If ! ParamBox(aParamBox,"Informe a data para início da importação...",@axParams)
            Return
        Endif	

        cDate := Dtos(axParams[1])
    	cDate := Left(cDate,4) + "-" + SubStr(cDate,5,2) + "-" + Right(cDate,2)
    EndIf

	cDateFim := Dtos(LastDay(Stod(StrTran(cDate, "-", ""))))
    cDateFim := Left(cDateFim,4) + "-" + SubStr(cDateFim,5,2) + "-" + Right(cDateFim,2)

	For nIdEmp := 1 To Len(aIdEmp)
		cIdEmp := aIdEmp[nIdEmp]
		If oSay <> Nil
			oSay:SetText("Lendo dados da empresa [" + cIdEmp + "] do Sgg.Net")
			ProcessMessage()
		EndIF
		nPagina := 0
		While nPagina > -1
			cBody := "{"
			cBody +=   '"paginador": {'
			cBody +=   '"pagina": "' + AllTrim(Str(nPagina)) + '",'
			cBody +=   '"tamanho": "100"},'
			cBody +=   '"dataExame_aPartirDe": "' + cDate + '",'
			cBody +=   '"dataExame_ate": "' + cDateFim + '",'
			cBody +=   '"empresa": "' + cIdEmp + '"
			cBody += '}'

			cResponse := HTTPQUOTE(cURLSol, "GET", "", cBody, 120, aHeader, @cReturn)
			aExames   := {}
			lProxima  := .F.

			If !Empty(cResponse)
				oJson := JsonObject():New()
				oJson:FromJson(cResponse)
				If oJson:HasProperty("resultado")
					aExames := AClone(oJson["resultado"])
				EndIf

				If oJson:HasProperty("temProximaPagina")
					lProxima := oJson["temProximaPagina"]
				EndIf
				FreeObj(oJson)
			EndIf
			
			nExames += Len(aExames)
			For nX:=1 To Len(aExames)
				oExame := aExames[nX]

				// Buscar o ID do funcionário na solicitação
				cIdEmp  := oExame:GetJsonText("id_empresa")
				cIDFunc := oExame:GetJsonText("id_funcionario")
				If oSay <> Nil
					oSay:SetText("Lendo exames do funcionário [" + cIDFunc + "] da empresa [" + cIdEmp + "] do Sgg.Net")
					ProcessMessage()
				EndIF

				// Buscar dados do funcionário pelo ID
				oFunc := CarFunc(cIdEmp, cIDFunc)
				If oFunc == Nil
					fGravaLog(cIdEmp + "-" + cIDFunc, "N", "Funcionário não localizado no Sgg.Net." )
					FreeObj(oFunc)
					Loop
				EndIF

				cFuncCPF := StrTran(StrTran(oFunc:GetJsonText("CPF"), ".", ""), "-", "")
				If Empty(Posicione("SRA", 5, xFilial("SRA") + cFuncCPF,"RA_MAT"))
					fGravaLog(cFuncCPF, "N", "Funcionário não localizado nesta empresa." )
					Loop
				EndIf 

				// Buscar dados do funcionário pelo ID
				oSolic := CarExame(cIdEmp, cIDFunc, oExame:GetJsonText("data_exames_lancados"))
				If oSolic == Nil
					fGravaLog(cIdEmp + "-" + cIDFunc, "N", "Solicitação do exame não localizado no Sgg.Net." )
					FreeObj(oSolic)
					Loop
				EndIF

				cCRMResp := DecodeUtf8(oSolic:GetJsonText("medico_coord"), "cp1252" )		// "medico": "1212710-RJ",
				cUfResp := "SP"	
				If At("-", cCRMResp) > 0
					cUfResp := Subs(cCRMResp, At("-", cCRMResp) + 1, Len(cCRMResp))
					cCRMResp := Left(cCRMResp, At("-", cCRMResp) - 1)
				EndIf

				M->CM7_CODIGO := cCRMResp
				M->CM7_NRIUF  := cUfResp
				M->CM7_NOME   := "Responsável"
				M->CM7_NRIOC  := M->CM7_CODIGO
				M->CM7_CPF    := "99999999999"
				GravaMed()

				If CM7->CM7_CPF == M->CM7_CPF
					fGravaLog(cIdEmp + "-" + cIDFunc, "N", "Crm Responsável [" + cCRMResp + "] foi incluido no cadastro de médicos. Ajustar o nome e CPF" )
					Loop
				EndIF

				cFuncFun := oFunc:GetJsonText("categoria")
				cResASO  := If(oExame:GetJsonText("resultado_atestado") == "Apto", "1", "2")  // 1 Apto - 2 Inapto
				cDataASO := StrTran(oExame:GetJsonText("data_atestado"), "-", "") 

				cTpExOcup := oExame:GetJsonText("tipo_exame")
				If Upper(cTpExOcup) == Upper("Admissional")
					cTpExOcup := "0"	// 0 - Exame médico admissional
				ElseIf Upper(cTpExOcup) == Upper("Periódico")
					cTpExOcup := "1"	// 1 - Exame médico periódico, conforme Norma Regulamentadora 07 - NR-07 
										// e/ou planejamento do Programa de Controle Médico de Saúde Ocupacional - PCMSO
				ElseIf Upper(cTpExOcup) == Upper("Retorno ao Trabalho")
					cTpExOcup := "2"	// 2 - Exame médico de retorno ao trabalho
				ElseIf Upper(cTpExOcup) == Upper("Mudança de Função")
					cTpExOcup := "3"	// 3 - Exame médico de mudança de função ou de mudança de risco ocupacional
				// 4 - Exame médico de monitoração pontual, não enquadrado nos demais casos
				ElseIf Upper(cTpExOcup) == Upper("Demissional")
					cTpExOcup := "9"	// 9 - Exame médico demissional Validação: Se informado [0], não pode existir outro 
										// evento S-2220 para o mesmo contrato com dtAso anterior.
				Else
					cTpExOcup := "0"	// Assume como admissional
				EndIf

				If ( cFuncFun == "NF" ) .Or. ( cFuncFun == "null" ) 
					lContinua := .T.
				Else
					//Verificar se a função está correta
					If ( fVldFuncao(cFuncCPF, cFuncFun, @cEmpVinc, @cMatric) )
						lContinua := .T.
					Else
						lContinua := .F.
						fGravaLog(cFuncCPF, "N", "Erro ao validar função" )
					EndIf
				EndIf

				cDtExame   := StrTran(oExame:GetJsonText("data_exames_lancados"), "-", "")  
				cCodExame  := oExame:GetJsonText("procRealizado")  // Tabela 27
				cIndResult := oExame:GetJsonText("indResult")  	//Indicação dos resultados.
																	//Valores válidos:
																	//1 - Normal
																	//2 - Alterado
																	//3 - Estável
																	//4 - Agravamento
				cIndResult := If(Empty(cIndResult), "1", cIndResult)

				cTipoExam := IIF(Val(cCodExame)>= 287 .And. Val(cCodExame)<= 295, "CL", "CP" )     //Baseado na tabela 27 eSocial    

				// 1=Referencial e 2=Sequencial
				cOrdExame := If(Upper(oExame:GetJsonText("ordem")) == Upper("Sequencial"), "2", "1")
				cObsProc  := IIF(oExame:GetJsonText("exame")=="nill", '', DecodeUtf8(oExame:GetJsonText("exame"), "cp1252" ))
				cObs      := IIF(oExame:GetJsonText("observacoes")=="nill", '', DecodeUtf8(oExame:GetJsonText("observacoes"), "cp1252" ))
				IF ! Empty(cObs)
					IF ! Empty(cObsProc)
						cObsProc += "-"
					EndIF
					cObsProc  += cObs
				EndIf
				cCRMMed   := DecodeUtf8(oExame:GetJsonText("medico"), "cp1252" )		// "medico": "1212710-RJ",
				cUFCRMMed := "SP"	
				If At("-", cCRMMed) > 0
					cUFCRMMed := Subs(cCRMMed, At("-", cCRMMed) + 1, Len(cCrmMed))
					cCRMMed := Left(cCRMMed, At("-", cCRMMed) - 1)
				EndIf
				cNomeMed := DecodeUtf8(oExame:GetJsonText("nome_medico"), "cp1252" )
				
				aExame := {}
				aAdd(aExame, { 	cFuncCPF, cCodExame, cTipoExam, cDtExame, cIndResult,;
								cOrdExame, cObsProc, cCRMMed, cUFCRMMed, cNomeMed})

				If fGravaDados(	cOperac, aExame, cDataASO, cResASO, cFuncCPF, cMatric, cTpExOcup,,, oSolic)
					nNovosRegs++
					GerLog( __cLog, "[" + cFuncCPF + "] Exames incluidos com sucesso")
				EndIf
				FreeObj(oFunc)
				FreeObj(oExame)
				FreeObj(oSolic)
			Next nX
			If lProxima
				nPagina ++
			Else
				nPagina := -1
			EndIf
		EndDo
	Next
	
	FreeObj(oFunc)
	FreeObj(oExame)
	FreeObj(oSolic)

	If nExames == 0
		GerLog( __cLog, "Nenhuma solicitação encontrada.")
	EndIf

	If ! lIsJob
		If File( __cLog )
			ShowMemo( __cLog )
		EndIf	

		If nExames > 0
			MsgAlert("Importação concluída! " + Chr(13)+Chr(10) + cValToChar(nNovosRegs) +" novos registros.")
		EndIf
		SZM->(DbGoTop())
		aQuery[1][4]:Refresh()
		aQuery[2][4]:Refresh()
	EndIf
  
Return( )

//-------------------------------------------------------------------
/*/{Protheus.doc} CarFunc
Retorna os dados de funcionário do endpoint do Sgg.Net

@param	cId_Empresa, C, Código da empresa no SGG.NET
@param	cIdFunc, C, Código do funcionário no SGG.NET

@return  oFunc, O, Retorna objeto com endpoint com dados do funcionário

@author  Wagner Mobile Costa
@since 	 24/04/2025
@version 1.0
/*/ 
//-------------------------------------------------------------------

Static Function CarFunc(cID_Empresa, cIDFunc)
	Local cURLFunc  := "https://app.sgg.net.br/api/v3/funcionario/"
	Local cRespFunc := ""
	Local oJson     := Nil
	Local oFunc     := Nil
	Local cBody     := ""

	If (nPos := Ascan(_aFunc, {|X| x[1] == cID_Empresa + cIDFunc  })) > 0
		Return _aFunc[nPos][2]
	EndIf

	cBody := "{"
	cBody += '  "paginador": {'
	cBody += '  "pagina": "0",'
	cBody += '  "tamanho": "100"'
	cBody += '  },'
	cBody += '  "id_empresa": "' + cID_Empresa + '",'
	cBody += '  "codigo": "' + cIDFunc + '"'
	cBody += '  }'

	cRespFunc := HTTPQUOTE( cURLFunc, "GET", "", cBody, 120,  aHeader)

	If !Empty(cRespFunc)
		oJson := JsonObject():New()
		oJson:FromJson(cRespFunc)
		If oJson:HasProperty("resultado")
			oFunc := oJson:GetJsonObject("resultado")[1]
			Aadd(_aFunc, { cID_Empresa + cIDFunc, oFunc })
		EndIf
		FreeObj(oJson)
	EndIf

Return oFunc

//-------------------------------------------------------------------
/*/{Protheus.doc} CarExame
Retorna os dados da solicitação do exame do endpoint do Sgg.Net

@param	cId_Empresa, C, Código da empresa no SGG.NET
@param	cIdFunc, C, Código do funcionário no SGG.NET

@return  oFunc, O, Retorna objeto com endpoint com dados do funcionário

@author  Wagner Mobile Costa
@since 	 01/06/2025
@version 1.0
/*/ 
//-------------------------------------------------------------------

Static Function CarExame(cID_Empresa, cIDFunc, cSolicitacao)
	Local cURLFunc  := "https://app.sgg.net.br/api/v3/solicitacoes-exames/"
	Local cResp     := ""
	Local oJson     := Nil
	Local cBody     := ""
	Local oExame    := Nil

	cBody := "{"
	cBody += '  "paginador": {'
	cBody += '  "pagina": "0",'
	cBody += '  "tamanho": "100"'
	cBody += '  },'
	cBody += '  "empresa": "' + cID_Empresa + '",'
	cBody += '  "funcionario": "' + cIDFunc + '", '
	cBody += '  "dataSolicitacao_aPartirDe": "' + cSolicitacao + '", '
	cBody += '  "dataSolicitacao_ate": "' + cSolicitacao + '" '
	cBody += '  }'

	cResp := HTTPQUOTE( cURLFunc, "GET", "", cBody, 120,  aHeader)

	If !Empty(cResp)
		oJson := JsonObject():New()
		oJson:FromJson(cResp)
		If oJson:HasProperty("resultado")
			oExame := oJson:GetJsonObject("resultado")[1]
		EndIf
		FreeObj(oJson)
	EndIf

Return oExame

//-------------------------------------------------------------------
/*/{Protheus.doc} CarEmp
Retorna os dados da empresa  do endpoint do Sgg.Net

@param	cId_Empresa, C, Código da empresa no SGG.NET

@return  oFunc, O, Retorna objeto com endpoint com dados do funcionário

@author  Wagner Mobile Costa
@since 	 24/04/2025
@version 1.0
/*/ 
//-------------------------------------------------------------------

Static Function CarEmp()
	Local cURLFunc  := "https://app.sgg.net.br/api/v3/empresa/"
	Local cResp     := ""
	Local oJson     := Nil
	Local aEmp      := {}
	Local nEmp      := 1
	Local cBody     := ""

	If (nPos := Ascan(_aEmp, {|X| x[1] == SM0->M0_CGC })) > 0
		Return _aEmp[nPos][2]
	EndIf

	cBody := "{"
	cBody += '  "paginador": {'
	cBody += '  "pagina": "0",'
	cBody += '  "tamanho": "100"'
	cBody += '  },'
	cBody += '  "cnpj_cpf": "' + Trans(SM0->M0_CGC, "@R 99.999.999/9999-99") + '"'
	cBody += '  }'

	cResp := HTTPQUOTE( cURLFunc, "GET", "", cBody, 120, aHeader)

	If !Empty(cResp)
		oJson := JsonObject():New()
		oJson:FromJson(cResp)
		If oJson:HasProperty("resultado")
			For nEmp := 1 To Len(oJson:GetJsonObject("resultado"))
				Aadd(aEmp, oJson:GetJsonObject("resultado")[nEmp]:GetJsonObject("id_empresa"))
			Next
			
			Aadd(_aEmp, { SM0->M0_CGC, aEmp })
		EndIf
		FreeObj(oJson)
	EndIf

Return aEmp


//-------------------------------------------------------------------
/*/{Protheus.doc} fExamObrig
Verifica se todos os exames obrigatórios foram feitos

@param	cFuncCPF, C, CPF
@param	aExames, A, Exames realizados

@return  lRet, B, Resultado da validação

@author  Leonardo Santos ( IT )
@since 	 02/02/2022
@version 1.0
/*/ 
//-------------------------------------------------------------------
Static Function fExamObrig(cFuncCPF, aExames )
    Local cRet      := "S"
    Local cFuncao   := ""
	Local cQuery	:= ""
	Local cAliasTON	:= GetNextAlias()
	Local cTabTON	:= RetSQLName("TON")
	Local cQuebra	:= Chr(13) + Chr(10)

    cFuncao := Posicione("SRA", 5, xFilial("SRA") + cFuncCPF,"RA_CODFUNC")

    //cTabSRA := "SRA" + aListaSRA[nX] + "0"
    If !Empty(cFuncao)
        cQuery += "SELECT TON_CODEXA AS CODEXAM  "+ cQuebra
        cQuery += "FROM "+ cTabTON + cQuebra
        cQuery += "WHERE D_E_L_E_T_ = ' '"+ cQuebra
        cQuery += "AND  TON_CODFUN = '"+cFuncao+"'"+ cQuebra
        DbUseArea(.T., 'TOPCONN', TCGenQry(,, cQuery), cAliasTON, .F., .T.)

        If (cAliasTON)->(Eof())
            fGravaLog(cFuncCPF, "N", "Função não localizada na tabela de exames por função [TON]" )
        Else

            While !(cAliasTON)->(Eof())
                nPosCod := aScan(aExames,{|x| x[2] == (cAliasTON)->CODEXAM})
                If ( nPosCod == 0 )
                    cRet := "N"
                    Exit
                EndIf
            EndDo  
        EndIf
    EndIf

Return cRet 


//-------------------------------------------------------------------
/*/{Protheus.doc} fGravaDados
Gravação e manutenção dos dados do evento S-2220

@param	cCPF, C, CPF
@param	cMatric, C, Matrícula do funcionário
@param	cOperac, C, Tipo de operacao 1-Imp BrMed 2-Enviado TAF
@param	cApExClin, C, Apto no Exame clínico
@param	cApExCompl, C, Apto no Exame complementar 
@param	cExObrigat, C, Cumpriu todos os exames obrigatórios

@return  Nil

@author  Leonardo Santos ( IT )
@since 	 20/01/2022
@version 1.0
/*/ 
//-------------------------------------------------------------------
Static Function fGravaDados(cOperac, aExames, cDataASO, cResASO, cFuncCPF, cMatric, cTpExOcup, nRecnoSZM, cIdProc, oSolic )
    Local lRet          := .T.
    Local nX            := 0
    Local cExObrigat    := "1"
	Local cCPFMedi      := ""		
	Local cNmMedi       := ""
	Local cCRMMedi      := ""
	Local cUFCRMMedi    := ""
	Local cCRMResp      := ""
	Local cUfResp       := ""
	Local cSZNtem       := ""

	// @Todo cCPFMedi - Valor não disponivel verificar https://app.sgg.net.br/api/v3/doc/#/Fornecedores/get_fornecedores_
	// em relação a propriedade forncedor do endpoint https://app.sgg.net.br/api/v3/exames-realizados/
    //    "fornecedor": "UNIDADE DE CAMPO GRANDE - RJ"

	SZM->(dbSetOrder(1))

	If cOperac == "1"
		cExObrigat := fExamObrig(cFuncCPF, aExames )

		cNmMedi     := Upper(aExames[1][10])
		cCRMMedi    := aExames[1][8]
		cUFCRMMedi  := aExames[1][9]

		cCRMResp := DecodeUtf8(oSolic:GetJsonText("medico_coord"), "cp1252" )		// "medico": "1212710-RJ",
		cUfResp := "SP"	
		If At("-", cCRMResp) > 0
			cUfResp := Subs(cCRMResp, At("-", cCRMResp) + 1, Len(cCRMResp))
			cCRMResp := Left(cCRMResp, At("-", cCRMResp) - 1)
		EndIf

		lNovo := ! SZM->(dbSeek(xFilial("SZM")+cFuncCPF+ cTpExOcup + cDataASO))
		If lNovo 
			Reclock("SZM",lNovo)
			SZM->ZM_FILIAL 	:= xFilial("SZM")
			SZM->ZM_ID 	    := GetSxENum('SZM','ZM_ID')
			SZM->ZM_DTIMP	:= Date()
			SZM->ZM_HRIMP	:= Time()
			SZM->ZM_CPF 	:= cFuncCPF
			SZM->ZM_MAT 	:= Posicione("SRA", 5, xFilial("SRA") + cFuncCPF,"RA_MAT")
			SZM->ZM_EXMOBGT	:= cExObrigat
			SZM->ZM_ASO     := cResASO
			SZM->ZM_TPEXAM  := cTpExOcup
			SZM->ZM_DTASO   := StoD(cDataASO)
			SZM->ZM_CPFRESR	:= cCPFMedi	    // CPF medico Medi
			SZM->ZM_NMRESP 	:= cNmMedi 		// Nome medico resp
			SZM->ZM_CRMRESP	:= cCRMMedi     // CRM medico resp
			SZM->ZM_UFCRMRE	:= cUfResp  	// UF CRM medico resp     
			SZM->ZM_STATUS	:= cOperac
			If Len(SZM->ZM_EMPRESA) == 3
				SZM->ZM_EMPRESA := oSolic:GetJsonText("id_empresa")
			EndIf
			SZM->(MsUnlock())  
			ConfirmSx8()         
		EndIf 

		// Grava tabela de médicos - Executor do Exame
		M->CM7_CODIGO := cCRMMedi
		M->CM7_NOME   := cNmMedi
		M->CM7_NRIOC  := cCRMMedi
		M->CM7_NRIUF  := cUFCRMMedi
		M->CM7_CPF    := cCPFMedi
		GravaMed()

        // Grava os tipos de exame
        SZN->(dbSetOrder(2))
		SZN->(DbClearFilter())

		For nX := 1 To Len(aExames) 
			// Verifica se existe o código do exame no cabecalho 
			BeginSQL Alias "QRY"
				SELECT SZN.R_E_C_N_O_ AS RECNO
				  FROM %table:SZN% SZN
				 WHERE ZN_FILIAL = %exp:xFilial('SZN')% AND ZN_ID = %exp:SZM->ZM_ID% 
				   AND ZN_CODPROC = %exp:aExames[nX][02]% AND SZN.D_E_L_E_T_ = ' ' 
			EndSql
			lNovo := QRY->RECNO == 0
			If ! lNovo
				SZN->(DbGoto(QRY->RECNO))
			EndIf
			QRY->(DbCloseArea())

            If lNovo .Or. Empty(SZN->ZN_DTENTAF) //Ainda não foi enviado pro TAF
				If lNovo
					cSZNtem := StrZero(0, 6)
					BeginSQL Alias "QRY"
						SELECT MAX(ZN_SEQUEN) AS ZN_SEQUEN
					  	  FROM %table:SZN% SZN
						 WHERE ZN_FILIAL = %exp:xFilial('SZN')% AND ZN_ID = %exp:SZM->ZM_ID% 
						   AND SZN.D_E_L_E_T_ = ' ' 
					EndSql
					IF ! Empty(QRY->ZN_SEQUEN)
						cSZNtem := QRY->ZN_SEQUEN
					EndIf
					cSZNtem := Soma1(cSZNtem)
					QRY->(DbCloseArea())
				EndIf

                Reclock("SZN",lNovo)            

                cMatric := Posicione("SRA", 5, xFilial("SRA") + cFuncCPF,"RA_MAT")
                
                SZN->ZN_FILIAL 	:= xFilial("SZN")
                SZN->ZN_ID	    := SZM->ZM_ID
				IF ! Empty(cSZNtem)
                	SZN->ZN_SEQUEN	:= cSZNtem
				EndIf
                SZN->ZN_DTIMP	:= Date()
                SZN->ZN_HRIMP	:= Time()
                SZN->ZN_CPF 	:= cFuncCPF
                SZN->ZN_MAT 	:= cMatric
                SZN->ZN_CODPROC := aExames[nX][02]
                SZN->ZN_TPEXAME	:= aExames[nX][03]
                SZN->ZN_DTPROC	:= StoD(aExames[nX][04])
                SZN->ZN_INDRES	:= aExames[nX][05]
                SZN->ZN_ORDEXAM	:= aExames[nX][06] // Ordem exame
                SZN->ZN_OBSPROC	:= aExames[nX][07] // Obervacao
				
				CM7->(DbSetOrder(2))
				CM7->(DbSeek(xFilial() + cCRMResp))

                SZN->ZN_CRMMED 	:= cCRMResp 		// CRM medico
                SZN->ZN_UFCRMMD := cUfResp	 		// UF CRM id medico
                SZN->ZN_NMMEDIC := CM7->CM7_NOME 	// Nome medico

				CM7->(DbSetOrder(1))

                SZN->ZN_STATUS	:= cOperac
                SZN->(MsUnlock())
            Else
                lRet := .F.
            EndIf
        Next nX
	ElseIf cOperac == "2"

		SZM->(dbGoTo(nRecnoSZM))
		Reclock("SZM",.F.)
		SZM->ZM_DTENTAF	:= Date()
		SZM->ZM_HRENTAF	:= Time()
		SZM->ZM_STATUS	:= cOperac
		SZM->ZM_IDPROC	:= cIdProc
		SZM->(MsUnlock())

		SZN->(dbSetOrder(1))
		SZN->(dbSeek(xFilial("SZN")+SZM->ZM_ID))
		While SZN->(!Eof()) .And. SZN->ZN_ID == SZM->ZM_ID
			Reclock("SZN", .F. )
			SZN->ZN_DTENTAF	:= Date()
			SZN->ZN_HRENTAF	:= Time()
			SZN->ZN_STATUS	:= cOperac
			SZN->(MsUnlock())
			SZN->(DbSkip())
		EndDo
	EndIf
	
Return lRet 

Static Function GravaMed

Local cNumID := ""

	CM7->(dbSetOrder(2))
	lNovo := !CM7->(dbSeek(xFilial("CM7")+M->CM7_CODIGO)) 
	If lNovo 
		cNumID := GetSxENum('CM7','CM7_ID')

		Reclock("CM7",lNovo)
		CM7->CM7_FILIAL := xFilial("CM7")
		CM7->CM7_ID     := cNumID
		CM7->CM7_CODIGO := M->CM7_CODIGO
		CM7->CM7_NOME   := M->CM7_NOME
		CM7->CM7_NRIOC  := M->CM7_NRIOC
		CM7->CM7_NRIUF  := Posicione("C09",1, xFilial("C09")+M->CM7_NRIUF ,"C09_ID")
		CM7->CM7_CPF    := M->CM7_CPF
		CM7->(MsUnlock())
		ConfirmSx8()
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fGravaLog
Log de importação do evento S-2220

@param	cCPF, C, CPF
@param	cImport, C, Importou S/N ?
@param	cMotivo, C, Motivo do Log

@return  Nil

@author  Leonardo Santos ( IT )
@since 	 20/01/2022
@version 1.0
/*/ 
//-------------------------------------------------------------------
Static Function fGravaLog(cCPF, cImport, cMotivo )

	GerLog( __cLog, "[" + cCpf + "] " + cMotivo )

	IF ! AliasInDic("SZJ")
		Return Nil
	EndIf

    Reclock("SZJ",.T.)
    SZJ->ZJ_FILIAL 	:= xFilial("SZJ")
    SZJ->ZJ_DATA	:= Date()
    SZJ->ZJ_HORA	:= Time()
    SZJ->ZJ_EVENTO  := cEvento
    SZJ->ZJ_CPF 	:= cCPF
    SZJ->ZJ_IMPORTA := cImport
    SZJ->ZJ_MOTIVO	:= cMotivo
    SZJ->(MsUnlock())
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} fVldFuncao
Consulta S-2220: Validar a função do funcionário

@param	cFuncCPF, C, CPF
@param	cFuncFun, C, Função 

@return  lRet, B, Resultado da validação

@author  Leonardo Santos ( IT )
@since 	 20/01/2022
@version 1.0
/*/ 
//-------------------------------------------------------------------
Static Function fVldFuncao(cFuncCPF, cFuncFun, cEmpVinc, cMatric)
    Local lRet      := .F.
    Local nX        := 0
    Local aListaSRA := StrTokArr( SuperGetMV("MV_XSRATAB", .T., "01|06|07|09|10") , "|" ) //AllTrim( GetMV("MV_XSRATAB") )
	Local cQuery	:= ""
	Local cAliasRA	:= GetNextAlias()
	Local cTabSRA	:= ""

    For nX := 1 To Len(aListaSRA)
        cTabSRA := "SRA" + aListaSRA[nX] + "0"

        cQuery += "SELECT RA_MAT, RA_CIC, RA_NOME, RA_CODFUNC FROM "+ cTabSRA + " "
        cQuery +=  "WHERE D_E_L_E_T_ = ' ' AND RA_CIC = '" + cFuncCPF + "' AND  RA_SITFOLH = 'A'"
        DbUseArea(.T., 'TOPCONN', TCGenQry(,, cQuery), cAliasRA, .F., .T.)

        If !(cAliasRA)->(Eof())
            If (cAliasRA)->RA_CODFUNC == cFuncFun
                lRet        := .T.
                cEmpVinc    := cValToChar(nX)
                cMatric     := SRA->RA_MAT
                Exit
            EndIf
        EndIf  

        (cAliasRA)->(DbCloseArea())

    Next nX

Return lRet

Static Function fExamFunc()
Local oQuery := custom.query.TCForm():New()

	oQuery:AddForm("SZM")

	// 2. Exames
	oQuery:AddForm("SZN",, .F.)
	
	Aadd(oQuery:aFolder, "Exames")
	Aadd(oQuery:aJoin, "ZN_FILIAL=ZM_FILIAL;ZN_ID=ZM_ID")

	oQuery:MontaForm("SINM151", "Eventos S2220 e-Social",;
					{|cAlias,oBrowse| MenuDef(cAlias,oBrowse) },;
					{|cAlias,oBrowse| LegendDef(cAlias,oBrowse) })
	FreeObj(oQuery)

Return( Nil )

Static Function MenuDef(cAlias, oBrowse)

	If cAlias == "SZM"
		
    	oBrowse:AddButton( "Importar Evento", {|| FwMsgRun(,{|oSay|fImpEvento(,,oSay)}, "Carregando .. ","Aguarde") } ,,2 ) 
    	oBrowse:AddButton( "Enviar TAF", {|| Processa( {|| fGravaTAF()  }, "Aguarde...", "Processando..." ,.F.) } ,,2 ) 
		oBrowse:AddButton( "Cadastro Médicos", {|| TAFA262() } ,,2 ) 
		oBrowse:AddButton( "Exames por Função", {|| U_SINA131() } ,,2 ) 
		
	EndIf

Return

Static Function LegendDef(cAlias, oBrowse)

	If cAlias == "SZM"
		oBrowse:AddLegend( '(ZM_STATUS == "1")',"GREEN","Ativa" )
		oBrowse:AddLegend( '(ZM_STATUS == "2")',"BLUE","Enviado TAF" )	
	EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} fGravaTAF
Grava dados do evento S-2220 nas tabelas do TAF (C8B/C9W)

@param	cTransID, C, Identificador da transação
@param	cPagtoID, C, Identificador do pagamento 

@return  cRet, C, Numero do boleto

@author  Leonardo Santos
@since 	 17/03/2022
@version 1.0
/*/ 
//-------------------------------------------------------------------

Static Function fGravaTAF()
 	Local aParamBox := {}
	Local axParams  := {}	
	Local cQuery	:= ""
	Local cAlias01	:= GetNextAlias()
    Local cAlias02	:= ""
	Local cTabSZM	:= RetSQLName("SZM")
    Local cTabSZN	:= RetSQLName("SZN")
	Local cQuebra	:= Chr(13) + Chr(10)
    Local cFuncCPF  := ""
    Local cVersao   := ""
    Local cCodID    := ""
    Local cEvento   := ""
    Local nRecnoSZM := 0
    Local lGravou   := .F.

    aAdd(aParamBox,{9,"Informe abaixo a faixa de matriculas para processamento",200, 40,.T.})
    aAdd(aParamBox,{1,"Matricula De"  ,Space(TamSX3("RA_CIC")[1]),"","",/*"SRA"*/,"",50,.F.}) 
    aAdd(aParamBox,{1,"Matricula Até" ,Space(TamSX3("RA_CIC")[1]),"","",/*"SRA"*/,"",50,.F.}) 
			
	If ! ParamBox(aParamBox,"Parametros",@axParams)
   		Return Nil
	Endif	
    
    cMatricDe   := axParams[2]
    cMatricAte  := axParams[3]

    cQuery += " SELECT ZM_ID AS IDENTIF "+ cQuebra
    cQuery += " FROM "+cTabSZM+" A"+ cQuebra
    cQuery += " WHERE A.D_E_L_E_T_ = ' '"+ cQuebra
    cQuery += " AND ZM_FILIAL = '"+xFilial("SZM")+"'"+ cQuebra   
    cQuery += " AND ZM_DTENTAF = '"+Space(1)+"'"+ cQuebra   
    cQuery += " AND ZM_MAT BETWEEN '"+cMatricDe+"' AND '"+cMatricAte+"'" +cQuebra

    DbUseArea(.T., 'TOPCONN', TCGenQry(,, cQuery), cAlias01, .F., .T.)

    While !(cAlias01)->(Eof())     

        cAlias02	:= GetNextAlias()
        cQuery := " SELECT A.R_E_C_N_O_ as ZMRECNO, ZM_CPF, ZM_ASO AS ASORESULT, ZM_DTASO,ZM_TPEXAM,"+ cQuebra
        cQuery += " ZM_CPFRESR,ZM_NMRESP, ZM_CRMRESP, ZM_UFCRMRE, ZN_CRMMED, ZN_UFCRMMD, "+ cQuebra
        cQuery += " ZN_CODPROC, ZN_DTPROC, ZN_INDRES, ZN_ORDEXAM, "+ cQuebra
        cQuery += " CONVERT(VARCHAR(2047),CONVERT(VARBINARY(2047),ZN_OBSPROC ))  as ZN_OBSPROC"+ cQuebra
        cQuery += " FROM "+cTabSZM+" A"+ cQuebra
        cQuery += " LEFT JOIN "+cTabSZN+" B"+ cQuebra
        cQuery += " ON ZN_FILIAL =  A.ZM_FILIAL"+ cQuebra
        cQuery += " AND ZN_ID = A.ZM_ID"+ cQuebra 
        cQuery += " AND B.D_E_L_E_T_ = ' '"+ cQuebra
        cQuery += " WHERE A.D_E_L_E_T_ = ' '"+ cQuebra
        cQuery += " AND ZM_FILIAL = '"+xFilial("SZM")+"'"+ cQuebra   
        cQuery += " AND ZM_DTENTAF = '"+Space(1)+"'"+ cQuebra   
        cQuery += " AND ZM_ID = '"+(cAlias01)->IDENTIF+"'" +cQuebra

        DbUseArea(.T., 'TOPCONN', TCGenQry(,, cQuery), cAlias02, .F., .T.)
        lNovo   := .T.
        lGravou := .F.
        While !(cAlias02)->(Eof()) 

            nRecnoSZM := (cAlias02)->ZMRECNO
            cFuncCPF := (cAlias02)->ZM_CPF
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³Busco a versao que sera gravada³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

            If lNovo
                cCodID  := GETSX8NUM("C8B","C8B_ID")
                cVersao := xFunGetVer()
            EndIf

            //Campo de uso interno do sistema.
            //Deve representar neste campo a
            //identificação do evento. Deve ser preenchido com:
            //I = Inclusão
            //A = Alteração
            //E = Exclusão    
            cEvento := "I"

            //Log de operação que indica se o registro
            //foi incluido/alterado via Job
            //(integração) ou via browse (manual).
            //1- Incluído Integração
            //2- Incluído Manual
            //3- Incluído Integração + Alterado Integração
            //4- Incluído Integração + Alterado Manual
            //5- Incluído Manual + Alterado Integração
            //6- Incluído Manual + Alterado Manual
            cLogOpe := "1"

            cFuncionario := Posicione("C9V", 3, xFilial("C9V") + cFuncCPF ,"C9V_ID")

            If Empty(cFuncionario)
                Alert("Funcionário " + cFuncCPF + " não existe na C9V - Funcionários.")
                Return Nil
            EndIf

            C8B->(dbSetOrder(1))
            If lNovo
                RecLock("C8B", .T.)

                C8B->C8B_FILIAL := xFilial("CB8")
                C8B->C8B_ID     := cCodID
                C8B->C8B_VERSAO := cVersao	
                C8B->C8B_FUNC   := cFuncionario	
                C8B->C8B_DTASO  := Stod((cAlias02)->ZM_DTASO)
                C8B->C8B_TPASO	:= ""
                C8B->C8B_RESULT	:= (cAlias02)->ASORESULT
                C8B->C8B_CODMED := Posicione("CM7", 2, xFilial("CM7")+(cAlias02)->ZM_CRMRESP, "CM7_ID") 	
                C8B->C8B_NISRES	:= ""
                C8B->C8B_CRMRES := ""	
                C8B->C8B_CRMUF  := Posicione("C09",1, xFilial("C09")+(cAlias02)->ZM_UFCRMRE ,"C09_ID")
                C8B->C8B_VERANT := ""	
                C8B->C8B_STATUS := ""
                C8B->C8B_PROTUL := ""	
                C8B->C8B_PROTPN := ""	
                C8B->C8B_EVENTO := cEvento	
                C8B->C8B_ATIVO  := "1"	    
                C8B->C8B_CODCNE := ""	
                C8B->C8B_CONTAT := ""	
                C8B->C8B_EMAIL  := ""	
                C8B->C8B_STASEC := ""	
                C8B->C8B_DINSIS := dDataBase
                C8B->C8B_XMLID  := ""	
                C8B->C8B_PROCID := ""	
                C8B->C8B_LOGOPE := cLogOpe

				CM7->(DbSetOrder(2))
				If CM7->(DbSeek(xFilial() + (cAlias02)->ZN_CRMMED))	
	                C8B->C8B_CPFRES := CM7->CM7_CPF
                	C8B->C8B_NOMRES := CM7->CM7_NOME
                	C8B->C8B_NRCRM  := CM7->CM7_CODIGO
				Else
					Alert("CRM " + (cAlias02)->ZN_CRMMED + " não localizado no cadastro de médicos")
				EndIf
				CM7->(DbSetOrder(1))

                C8B->C8B_TPEXAM := (cAlias02)->ZM_TPEXAM
                C8B->C8B_NOMEVE := "S2200"
                C8B->(MsUnlock())
                lNovo := .F.
                lGravou := .T.
            EndIf

            If lGravou 

                C9W->(dbSetOrder(1))
                RecLock("C9W", .T.)  

                C9W->C9W_FILIAL := xFilial("C9W")
                C9W->C9W_ID     := cCodID  
                C9W->C9W_VERSAO := cVersao
                C9W->C9W_DTEXAM := StoD((cAlias02)->ZN_DTPROC)
                C9W->C9W_DESEXM := ""
                C9W->C9W_CODPRO := AllTrim(Posicione("V2K",2,xFilial("V2K")+ (cAlias02)->ZN_CODPROC, "V2K_ID"))
                C9W->C9W_INTERP := ""
                C9W->C9W_ORDEXA := (cAlias02)->ZN_ORDEXAM
                C9W->C9W_DTINMO := CtoD("")
                C9W->C9W_DTFIMO := CtoD("")
                C9W->C9W_INDRES := (cAlias02)->ZN_INDRES
                C9W->C9W_NISRES := ""
                C9W->C9W_CRMRES := ""
                C9W->C9W_CRMUF  := ""
                C9W->C9W_OBS    := IIF(AllTrim((cAlias02)->ZN_OBSPROC)=="null", '', AllTrim((cAlias02)->ZN_OBSPROC))
                C9W->(MsUnlock())

            EndIf
            (cAlias02)->(DbSkip())
        EndDo   
        (cAlias02)->(DbCloseArea())
        
        //Atualizar tabela intermediária informando que o registro já foi enviado ao TAF
        If lGravou
            fGravaDados("2", /*aExames*/, /*cDataASO*/, /*cResASO*/, cFuncCPF, /*cMatric*/, /*cTpExOcup*/, nRecnoSZM, cCodID, Nil )
        EndIf

        (cAlias01)->(DbSkip())
    EndDo   
    (cAlias01)->(DbCloseArea())
	SZM->(DbGoTop())
	aQuery[1][4]:Refresh()

Return Nil

//---------------------------------------------------------------------

/*/{Protheus.doc} GerLog

Rotina para criação de log (função ACALOG do P11.)

@since 16/08/2016
@version 12.1.7
/*/
//---------------------------------------------------------------------
Static Function GerLog( cArquivo, cTexto )

Local nHdl := 0

If !File(cArquivo)
	nHdl := FCreate(cArquivo)
Else
	nHdl := FOpen(cArquivo, FO_READWRITE)
EndIf

FSeek(nHdl,0,FS_END)
cTexto += Chr(13)+Chr(10)
FWrite(nHdl, cTexto, Len(cTexto))
FClose(nHdl)

Return()
