// Bibliotecas necessárias
#Include "TOTVS.ch"

/*/{Protheus.doc} TRK0015
    Monitoramento automático de coletas para expedição não cumpridas no prazo.
    @type Function
    @version 12.1.2410
    @author Guilherme Bigois
    @since 19/08/2025
    @return Variant, Retorno nulo fixado
/*/
User Function TRK0015() As Variant
    // Variáveis locais
    Local aArea  As Array     // Área anteriormente posicionada
    Local cAlias As Character // Apelido do arquivo temporário
    Local cTitle As Character // Título da rotina para mensagens
    Local lPop   As Logical   // Flag de exibição de GUI
    Local lEmpty As Logical   // Flag de verificação de registros encontrados
    Local nRecNo As Numeric   // Identificador único do registro
    Local nDays  As Numeric   // Dias desde a última coleta
    LOcal dDate  As Date      // Data da coleta mais recente

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
                RecLock("Z09", .F.)
                    If (nDays < 7)
                        Z09_STATUS := "?" // ALERTA_CANC_NF
                    Else
                        Z09_STATUS := "?" // NF_CANCELADA
                        Z09_MOTIVO := "NF CANCELADA"
                        Z09_DSMOTV := "Coleta não realizada após 7 dias do agendamento."
                    EndIf
                MsUnlock()
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
