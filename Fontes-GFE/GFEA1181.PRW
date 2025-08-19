#include "totvs.ch"
/*/{Protheus.doc} GFEA1181
PE validacoes de CT-e para atribuir a situacao 'Erro Impeditivo'
@type function
@version 20250813
@author luiz.favareto@dothink.com.br
@since 11/08/2025
@history 13/08/2025, luiz.favareto, correcao variavel lRet
@return logical, sempre .T.
@obs Conforme Projeto Logico 001 do Projeto no. 20250528008v02 referente ao servico de Revitalizacao do Gestao de Frete Embarcador (SIGAGFE TOTVS Protheus) e Integracao com o SIGAACD (Automacao e Coleta de Dados)
/*/
User Function GFEA1181
    Local lRet := .T.
    If Type("aGXG")=="A".And.Len(aGXG)>=37.And.ValType(aGXG[37])=="C".And.aGXG[37]=="5".And.GXG->GXG_EDISIT=="5"
        TcSqlExec("update "+RetSqlName("GXH");
            +" set D_E_L_E_T_=' ',R_E_C_D_E_L_=R_E_C_N_O_";
            +" where D_E_L_E_T_=' '";
            +" and GXH_FILIAL="+ValToSql(GXG->GXG_FILIAL);
            +" and GXH_NRIMP="+ValToSql(GXG->GXG_NRIMP);
        )
        TcSqlExec("update "+RetSqlName("GXG");
            +" set D_E_L_E_T_=' ',R_E_C_D_E_L_=R_E_C_N_O_";
            +" where D_E_L_E_T_=' '";
            +" and GXG_FILIAL="+ValToSql(GXG->GXG_FILIAL);
            +" and GXG_NRIMP="+ValToSql(GXG->GXG_NRIMP);
        )
    Endif
Return lRet
