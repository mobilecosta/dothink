// Bibliotecas necessárias
#Include "TOTVS.ch"

/*/{Protheus.doc} TRK0015
    Monitoramento automático de coletas para expedição não cumpridas no prazo.
    @type Function
    @version 12.1.2410
    @author DoThink
    @since 19/08/2025
    @return Variant, Retorno nulo fixado
/*/
User Function TRK0015()
	// Variáveis locais
	Local aArea  As Array     // Área anteriormente posicionada
	Local cAlias As Character // Apelido do arquivo temporário
	Local cTitle As Character // Título da rotina para mensagens
	Local lPop   As Logical   // Flag de exibição de GUI
	Local lEmpty As Logical   // Flag de verificação de registros encontrados
	Local nRecNo As Numeric   // Identificador único do registro
	Local nDays  As Numeric   // Dias desde a última coleta
	Local dDate  As Date      // Data da coleta mais recente
	Local cMessage As Character // Mensagem de status

	// Inicialização das variáveis
	aArea  := FwGetArea()
	cAlias := GetNextAlias()
	cTitle := "Monitoramento de Coletas Fora do Prazo"
	lPop   := FwIsInCallStack("U_TRKJ015") .Or. !IsBlind()
	lEmpty := .T.
	nRecNo := 0
	nDays  := 0
	dDate  := CToD("/")

	// Define a sequência de processamento
	BEGIN SEQUENCE
		// Pausa a execução se não for a vontade do usuário
		If (lPop .And. !FwAlertYesNo("Deseja realmente alterar o status das coletas para expedição não cumpridas no prazo?", cTitle))
			BREAK
		EndIf

		// Pesquisa por registros ainda não processados
		BEGINSQL ALIAS cAlias
            SELECT
                Z09.R_E_C_N_O_ Z09_RECNO,
            FROM
                %TABLE:Z09% Z09
            WHERE
                Z09.Z09_STATUS = '4'
                AND (
                    Z09.Z09_DT1COL <= %EXP:DToS(Date() - 7)%
                    OR Z09.Z09_DT2COL <= %EXP:DToS(Date() - 7)%
                    OR Z09.Z09_DT3COL <= %EXP:DToS(Date() - 7)%
                )
                AND Z09.%NOTDEL%
		ENDSQL

		// Percorre os registros encontrados
		While (!EOF())
			// Posiciona a tabela de monitoramento
			nRecNo := Z09_RECNO
			DBSelectArea("Z09")
			DBGoTo(nRecNo)

			// Define qual a coleta mais recente a ser utilizada
			dDate := IIf(!Empty(Z09_DT3COL), Z09_DT3COL, IIf(!Empty(Z09_DT2COL), Z09_DT2COL, Z09_DT1COL))
			nDays := Date() - dDate

			// Verifica se a coleta está fora do prazo de no mínimo 5 dias úteis
			If (nDays >= 5)
				// Ativa a flag de registros encontrados se houver coletas fora do prazo
				lEmpty := .F.

				// Altera o registro de monitoramento
				If (nDays < 7)
					cZ09_STATUS := "2" // ALERTA_CANC_NF - Bloqueio Fiscal Pendente
					cZ09_MOTIVO := "ATRASO"
					cZ09_DSMOTV := "Coleta com atraso maior que 5 dias."

					// Atualiza SC5 + grava histórico
					cMessage := "Detectado no monitoramento automático em " + ;
						DToC(Date()) + " às " + Time()
				Else
					cZ09_STATUS := "3" // NF_CANCELADA (rejeição)
					cZ09_MOTIVO := "NF CANCELADA"
					cZ09_DSMOTV := "Coleta não realizada após 7 dias do agendamento."

					// Atualiza SC5 + grava histórico
					cMessage := "Cancelada automaticamente pelo sistema em " + ;
						DToC(Date()) + " às " + Time()
				EndIf
				aTrackS := Array( Len( Z09->( DbStruct() ) ) )
				aTrackS[Z09->(FieldPos("Z09_FILIAL"))] := Z09->Z09_FILIAL
                aTrackS[Z09->(FieldPos("Z09_NUMPV")) ] := Z09->Z09_NUMPV
				aTrackS[Z09->(FieldPos("Z09_ITEMPV"))] := Z09->Z09_ITEMPV
				aTrackS[Z09->(FieldPos("Z09_STATUS"))] := Z09->Z09_STATUS
				aTrackS[Z09->(FieldPos("Z09_MOTIVO")) ] := Z09->Z09_MOTIVO
                aTrackS[Z09->(FieldPos("Z09_DSMOTV")) ] := Z09->Z09_DSMOTV
				u_TRK006S(aTrackS, cMessage)

			EndIf

			// Salta para o próximo registro
			DBSelectArea(cAlias)
			DBSkip()
		End

		// Fecha o arquivo temporário
		DBSelectArea(cAlias)
		DBCloseArea()

		// Mensagem de status final do processamento se estiver via interface gráfica
		If (lPop)
			If (lEmpty)
				FwAlertWarning("Não foram encontradas coletas para expedição fora do prazo.", cTitle)
			Else
				FwAlertSuccess("Monitoramento de coletas para expedição não cumpridas no prazo realizado com sucesso", cTitle)
			EndIf
		EndIf
	END SEQUENCE

	// Restaura a área de trabalho anterior
	FwRestArea(aArea)
Return (NIL)

/*/{Protheus.doc} SchedDef
    Definições de agendamento do Schedule Protheus.
    @type Function
    @version 12.1.2410
    @author Guilherme Bigois
    @since 19/08/2025
    @return Array, Array com definições do agendamento
/*/
Static Function SchedDef() As Array
	// Variáveis locais
	Local aParam As Array

	// Inicialização das variáveis
	aParam := {}

	// Montagem da estrutura do vetor de retorno
	AAdd(aParam, "P")        // Tipo do agendamento: "P" = Processo | "R" = Relatório
	AAdd(aParam, "PARAMDEF") // Pergunte (SX1) do relatório (Usar "PARAMDEF" caso não tenha conjunto de Perguntas)
	AAdd(aParam, "")         // Alias principal (exclusivo para relatórios)
	AAdd(aParam, {})         // Vetor de ordenação (exclusivo para relatórios)
	AAdd(aParam, "")         // Título (exclusivo para relatórios)
Return (aParam)

/*/{Protheus.doc} TRKJ015
    Encapsulamento da tarefa U_TRK0015 para execução via SmartClient.
    @version 12.1.2410
    @author Guilherme Bigois
    @since 19/08/2025
    @return Variant, Retorno nulo fixado
/*/
User Function TRKJ015() As Variant
	// Prepara o ambiente para execução sem interface gráfica quando fora do Schedule
	OpenSM0()
	RPCSetType(3)
	RPCSetEnv(M0_CODIGO, M0_CODFIL)

	// Realiza a chamada da função principal
	U_TRK0015()

	// Encerra a conexão com o banco de dados quando fora do Schedule
	RPCClearEnv()
Return (NIL)
