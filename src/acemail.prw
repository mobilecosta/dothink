#include "fileio.ch"
#include "rwmake.ch"
#include "totvs.ch"
/*/{Protheus.doc} ACEMAIL
Funcao para envio de e-mail
@type function
@version  
@author fbmuta
@since 12/02/2023
@param _aDest, variant, param_description
@param _cAssunto, variant, param_description
@param _cHtm, variant, param_description
@param _aAnexos, variant, param_description
@return variant, Nil
/*/
User Function ACEMAIL( _aDest , _cAssunto , _cHtm , _aAnexos )
local i
local lOk := .F.
local lEnviou := .F.
local aDest2  := {}
for i:=1 to len(_aDest)
    If EXISTBLOCK("DOCEMAIL")
        U_DocEMail(_aDest[i], _cHtm, _cAssunto,_aAnexos) 
        lEnviou := .t.
    ElseIf EXISTBLOCK("DYENEML2")
        cEmlFrom   := Alltrim( GetNewPar("MV_WFMAIL","") )
        cPasFrom   := Alltrim( GetNewPar("MV_WFPASSW","") )
        U_DYENEML2(cEmpAnt, cFilAnt, cEmlFrom, cPasFrom, _aDest[i], _cAssunto, _cHtm, _aAnexos, , , , .T., .F.)
        lEnviou := .t.
    else
        //accmail(_aDest[i], _cHtm, _cAssunto,_aAnexos) 
    EndIf
Next

If !lEnviou 
    If len(_aDest) > 0
        aadd(aDest2,"naoresponda@acfontes.com")
        for i:=1 to len(_aDest)
            aadd(adest2,_aDest[i])
        next
        u_accmail(_aDest , _cAssunto , _cHtm , _aAnexos   )
    EndIf
EndIf    

Return




User Function accmail( aDestinat , cAssunto , cMensagem , aAnexos )

	Local lRet			:= .T.
	Local cTO			:= ""
	Local cCC			:= ""
	Local cSMTPServer	:= ""
	Local cFrom			:= ""
	Local aSMTPServer	:= {}
	Local cSMTPUser 	:= ""
	Local cSMTPPass 	:= ""
	Local lRelAuth 		:= .f.
	Local nSMTPPort		:= 0

    Local oInfo     := Nil

	Local cFrom			:= GETMV("MV_RELFROM",.F.,"")
	Local aSMTPServer	:= StrTokArr2(GETMV("MV_RELSERV",.F.,""),":")
	Local cSMTPUser 	:= GETMV("MV_RELACNT",.F.,"")
	Local cSMTPPass 	:= GETMV("MV_RELAPSW" ,.F.,"")
	Local lRelAuth 		:= GetMv("MV_RELAUTH",.F., .F.)
	Local nSMTPPort		:= 587

	Local oMail			:= Nil
	Local oMessage 		:= Nil
	Local nErro			:= 0
	Local nEmail		:= 0
	Local nX			:= 0
	Local cFileName		:= ""

	DEFAULT aDestinat	:= {}
	DEFAULT cAssunto	:= ""
	DEFAULT cMensagem	:= ""

	Private cError		:= ""
	Private lSendOk	:=	.T.
/*
    If !ValType(oInfo := oFn:ApiHubRecover(cEmpAnt,Upper(cPlatafo),,,,.T.)) == "O"
        Conout(cMsgErro)
        Return
    EndIf

	cFrom	   := oInfo[#"contaremet"]
	aSMTPServer:= StrTokArr2(oInfo[#"contaserver"],":")
    cSMTPUser  := oInfo[#"contaemail"]
	cSMTPPass  := oInfo[#"password"]
    lRelAuth   := oInfo[#"autentica"]
    nSMTPPort  := oInfo[#"smtpport"]
*/
	for nX := 1 to len(aSMTPServer)
		if nX == 1
			cSMTPServer := AllTrim(aSMTPServer[nX])
		endif
		if nX == 2
			nSMTPPort := Val(AllTrim(aSMTPServer[nX]))
		endif
	next

	/*
	 * Envio de e-mail só ocorre se existirem destinatários
	 */
	If Len(aDestinat) > 0
		cTo := aDestinat[1] // Primeiro e-mail de destinatários
		/*
		 * Próximos destinatários com cópia oculta.
		 */
		For nEmail := 2 To Len(aDestinat)
			If EMPTY(cCC)
				cCC += aDestinat[nEmail]
			Else
				cCC += ", " + aDestinat[nEmail]
			EndIf
		Next nEmail

		/*
		 * Iniciando conexão com o servidor de e-mails
		 */
		oMail := TMailManager():New()
		oMail:SetUseTLS( lRelAuth )
		//Inicializando SMTP
		oMail:Init( '', cSMTPServer , cSMTPUser, cSMTPPass, 0, nSMTPPort  )

		//Setando Time-Out
		oMail:SetSmtpTimeOut( 500 )

		//Conectando com servidor...
		nErro := oMail:SmtpConnect()

		/*
		 * Autenticando o usuário no servidor de e-mails
		 */
		If lRelAuth

			//Autenticando Usuario
			nErro := oMail:SmtpAuth(cSMTPUser ,cSMTPPass)

			If nErro <> 0

				// Recupera erro ...
				cMAilError := oMail:GetErrorString(nErro)
				DEFAULT cMailError := '***UNKNOW***'
				Conout("Erro de Autenticacao "+str(nErro,4)+' ('+cMAilError+')')

				lRet := .F.
			Endif
		EndIf

		If nErro <> 0
			// Recupera erro
			cMAilError := oMail:GetErrorString(nErro)
			DEFAULT cMailError := '***UNKNOW***'

			conOut(cMAilError)
			ConOut("Erro de Conexao SMTP "+str(nErro,4))
			conOut('Desconectando do SMTP')

			oMail:SMTPDisconnect()
			lRet := .F.
		Endif

		/*
		 * Criando o objeto da mensagem do e-mail
		 */

		oMessage := TMailMessage():New()
		oMessage:Clear()
	    oMessage:cFrom			:= cFrom
	    oMessage:cTo			:= cTo
	    oMessage:cBcc			:= cCC
	    oMessage:cSubject		:= cAssunto
	    oMessage:cBody			:= cMensagem
	    oMessage:MsgBodyType( "text/html" )

		For nX := 1 To Len(aAnexos)
			// Só anexa se o arquivo existir
			If File(aAnexos[nX])

				If oMessage:AttachFile( aAnexos[nX] ) < 0
					Conout("Erro ao anexar o arquivo")
				Else
					If (nPos:= Rat('\',aAnexos[nX]) ) > 0
						cFileName := Substr(aAnexos[nX],nPos+1)
					Else
						cFileName := aAnexos[nX]
					EndIf
					oMessage:AddAtthTag( 'Content-Disposition: attachment; filename='+cFileName)
				EndIf
			EndIf
		Next nX

		//conout(oMessage:cBody)
		//Alert(oMessage:cBody)
		//conout('Enviando Mensagem para ['+cTo+'] ')
		//Alert('Enviando Mensagem para ['+cTo+'] ')
		nErro := oMessage:Send( oMail )

		If nErro <> 0
			xError := oMail:GetErrorString(nErro)
			//Conout("Erro de Envio SMTP "+str(nErro,4)+" ("+xError+")")
			//Alert("Erro de Envio SMTP "+str(nErro,4)+" ("+xError+")")
			lRet := .F.
		Endif

		conout('Desconectando do SMTP')
		//Alert('Desconectando do SMTP')
		oMail:SMTPDisconnect()
	Else
		Alert("Sem destinatários para envio do e-mail .")
		//CONOUT("Sem destinatários para envio do e-mail .")
		lRet := .F.
	EndIf

Return lRet
