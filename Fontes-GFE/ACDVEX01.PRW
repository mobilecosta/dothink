#include "totvs.ch"
#include "apvt100.ch"

/*/{Protheus.doc} ACDVEX01
Embarque com geracao de romaneio do SIGAGFE, a partir do SIGAACD
@type function
@version 1.0  
@author Alex - DOTHINK
@since 25/06/2025
@obs Conforme Projeto Logico 001 do Projeto no. 20250528008v02 referente ao serviço de Revitalização do Gestão de Frete Embarcador (SIGAGFE TOTVS Protheus) e Integração com o SIGAACD (Automação e Coleta de Dados)
/*/
User Function ACDVEX01()
    Local cRet      := ""
    Local bkey04    := VTSetKey(4)
    Local bKey24    := VTSetKey(24)
    Private nTChvNF := FwGetSx3Cache("F2_CHVNFE", "X3_TAMANHO")   
    Private cDanfe  := Space(nTChvNF)     
    Private aDanfes := {}
    

    VTSetKey(4  , {|| ShowDanfes()  }, "Lista de Danfes")
    VTSetKey(24 , {|| Estorna()     }, "Estorna Leitura")

    While .T.
        VTClear()
        VTClearBuffer()

        cDanfe := Space(nTChvNF)  

        If !GetDanfe()

            If Empty(aDanfes)
                exit
            Else
                
                If VTYesNo("Deseja Gerar o Romaneio?", "ATENCAO")
                    cRet := u_GFEEX001(aDanfes)

                    If !Empty(cRet)
                        VTAlert(cRet, "ERRO")
                        Loop
                    EndIf

                Else
                
                    If VTYesNo("Deseja sair pendendo os dados lidos?", "ATENCAO")
                        Exit
                    EndIf
                
                EndIf

            EndIf
        EndIf

    Enddo
    
    VTSetKey(4  , bkey04)
    VTSetKey(24 , bkey24)

return


/*/{Protheus.doc} GetDanfe
Leitura da Danfe
@type function
@author DO THINK - ERIKE
@since 10/11/2023
@return logical, sempre retorna verdadeiro
/*/
Static Function GetDanfe()
    Local lRet      := .T.
      
    cDanfe  := Space(nTChvNF) 
    
    @ 00,00 VTSay "GERACAO DE ROMANEIO"
    @ 01,00 VTSay Replicate("-", VTMaxCol())
    @ 02,00 VTSay "Leia a Danfe:"
    @ 03,00 VTGet cDanfe PICT "@!" VALID VldDanfe()
    VTRead

    If VTLastKey() == 27
        Return .F.
    EndIf

    VTInkey(0)
    VTClear()

Return lRet

/*/{Protheus.doc} VldDanfe
Valida o código inserido
@type function
@author DO THINK - ERIKE
@since 10/11/2023
@return logical, conforme validacao
/*/
Static Function VldDanfe()
    Local cCliente := ""
    Local cLoja    := ""
    Local cTpVeic  := ""
    Local nPos     := 0
    
    //-- Validacao inicial de conteudo da chave da danfe
    If Empty(cDanfe) .or. Len( Alltrim(cDanfe) ) < nTChvNF
		VTAlert("Chave da danfe invalida!", "Aviso", .T., 4000, 3)
        VTKeyBoard(chr(20))
		Return .F.
	EndIf

    DbSelectArea("SF2")
    SF2->( DbOrderNickName("CHAVE") )

    //-- Verifica se chave existe
    If !SF2->( DbSeek( xFilial() + cDanfe ) )
		VTAlert("Chave da danfe nao localizada!", "Aviso", .T., 4000, 3)
        VTKeyBoard(chr(20))
		Return .F.
    EndIf

    //-- Guarda dados do cliente
    cCliente := SF2->F2_CLIENTE
    cLoja    := SF2->F2_LOJA   
         
    If !Empty(aDanfes)
        //-- Valida se é mesmo agrupador (cliente + loja)
        If aDanfes[1, 2] <> cCliente .or. aDanfes[1, 3] <> cLoja
            VTAlert("O cliente/loja desta danfe é diferente da 1a danfe lida!", "Danfe Invalida", .T., 4000, 3)
            VTKeyBoard(chr(20))
            Return .F.
        EndIf

        //-- Verifica se danfe já foi lida
        nPos := Ascan(aDanfes, {|x| x[1]==cDanfe})

        If nPos > 0
            VTAlert("Esta danfe ja foi lida!", "Danfe Invalida", .T., 4000, 3)
            VTKeyBoard(chr(20))
            Return .F.
        EndIf

    EndIf

    DbSelectArea("Z09")
    Z09->( DbSetOrder(6) )

    If !Z09->( DbSeek(cDanfe) )
        VTAlert("Danfe nao localizada no Cockpit!", "Danfe Invalida", .T., 4000, 3)
        VTKeyBoard(chr(20))
        Return .F.
    EndIf

    
    /*
    If Empty(Z09->Z09_CDTPVC)
        VTAlert("Tipo de veiculo nao informado no CockPit!", "Danfe Invalida", .T., 4000, 3)
        VTKeyBoard(chr(20))
        Return .F.
    EndIf
    */

    cTpVeic := Z09->Z09_CDTPVC

    //-- Inclui no Array de Gravacao
    aadd(aDanfes, {cDanfe, cCliente, cLoja, cTpVeic})

    cDanfe  := Space(nTChvNF) 
Return .T.


/*/{Protheus.doc} ShowDanfes
Lista danfes lidas
@type function
@author DO THINK - ERIKE
@since 25/06/2025
/*/
Static Function ShowDanfes()
	Local aSave := VTSave()
	Local aCab  := {"Chave Danfe", "Cliente", "Lj", "Tipo Veiculo"}
	Local aSize := {nTChvNF, 7, 2, 10}

	VTCLear()
	If Empty(aDanfes)
		VTAlert("Não existem danfes lidas!", "Aviso", .T., 4000)
	Else
		VTaBrowse(0, 0, 7, 19, aCab, aDanfes, aSize)
	EndIF
	
	VTRestore(,,,,aSave)

return


/*/{Protheus.doc} Estorna
Estorna uma danfe já lida. Este estorno é somente da inclusão do array
@type function
@author DO THINK - ERIKE
@since 25/06/2025
/*/
Static Function Estorna()
    Local aTela

    If Empty(aDanfes)
        VTAlert("Nao existem danfes lidas!", "Aviso", .T., 4000, 3)
        Return
    EndIf

    cDanfe  := Space(nTChvNF)  
    aTela   := VTSave()

    VTClear()

    @ 00,00 VtSay "ESTORNO DA LEITURA"
    @ 01,00 VTSay Replicate("-", VTMaxCol())
    @ 02,00 VtSay "Leia a Danfe:"
    @ 03,00 VtGet cDanfe PICT "@!" VALID VldEstorno()
    VtRead

    vtRestore(,,,,aTela)
Return

/*/{Protheus.doc} VldEstorno
Valida leitura da danfe para estorno
@type function
@author DO THINK - ERIKE
@since 25/06/2025
@return logical, conforme validacao
/*/
Static Function VldEstorno()
    Local lRet := .T.
    Local nPos := 0

    //-- Validacao inicial de conteudo da chave da danfe
    If Empty(cDanfe) .or. Len( Alltrim(cDanfe) ) < nTChvNF
		VTAlert("Chave da danfe invalida!", "Aviso", .T., 4000, 3)
        VTKeyBoard(chr(20))
		Return .F.
	EndIf

    nPos := Ascan(aDanfes, {|x| x[1]==cDanfe})

    If Empty(nPos)
        VTAlert("Chave da danfe nao localizada!", "Danfe Invalida", .T., 4000, 3)
        VTKeyBoard(chr(20))
        Return .F.
    EndIf    

	If ! VTYesNo("Confirma o estorno?", "ATENCAO", .t.)
        VTKeyBoard(chr(20))
		Return .F.
	EndIf 

    aDel(aDanfes, nPos)    
    aSize(aDanfes, Len(aDanfes) - 1 )

    cDanfe  := Space(nTChvNF)  

Return lRet
