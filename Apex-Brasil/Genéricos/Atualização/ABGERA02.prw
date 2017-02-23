#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'AP5MAIL.CH'

//-----------------------------------------------------------------------
/*/{Protheus.doc} EnvEmail()

Rotina para enviar e-mail

Exemplo:
U_EnvEmai2("murilototvs01@gmail.com", "murilom@totvs.com.br", "Teste de envio de email", "Corpo do email")   

----U_EnvEmai2("murilototvs01@gmail.com", "murilom@totvs.com.br", "Teste de envio de email", "Corpo do email", {"\data\ABGERA01.prw"})

@param		cRemete		= Remetente do e-mail
			cDestin		= Destinatário do e-mail
			cAssunto	= Assunto do e-mail
			cMensagem	= Mensagem do e-mail
			aAnexos		= Anexos do e-mail - a partir do rootpath (protheus_data)
@return		lRet 		= T. = Sucesso / .F. = Falha no envio do e-mail
@author 	Fabio Cazarini
@since 		19/08/2016
@version 	1.0
@project	SuperAcao Apex-Brasil
/*/
//-----------------------------------------------------------------------
USER FUNCTION EnvEmai2(_cRemete, _cDestin, _cAssunto, _cCorpoEmai, _aAnexos,_cCc)    

    LOCAL oMail, oMessage
	LOCAL nErro
	LOCAL cServer		:= ALLTRIM(GETMV("MV_RELSERV"))
	LOCAL cAccount		:= ALLTRIM(GETMV("MV_RELACNT"))
	LOCAL cPassword 	:= ALLTRIM(GETMV("MV_RELPSW"))
	LOCAL lAutentica	:= GETMV("MV_RELAUTH")
	LOCAL cUserAut 		:= ALLTRIM(GETMV("MV_WFAUTUS"))
	LOCAL cPassAut 		:= ALLTRIM(GETMV("MV_WFAUTSE"))
	LOCAL lRelTLS 		:= GETMV("MV_RELTLS")
	LOCAL lRelSSL 		:= GETMV("MV_RELSSL")
	LOCAL lRet			:= .T.
	LOCAL lJob 			:= !(Type("oMainWnd")=="O")
	LOCAL cMensagem		:= ""
	LOCAL cFile			:= ""
	LOCAL nX			:= 0
	
	DEFAULT aAnexos		:= {}
	DEFAULT _cCc		:= ""
	
	IF EMPTY(_cRemete) .OR. EMPTY(_cDestin) 
		lRet := .F.
	ENDIF

	oMail := TMailManager():New()
	
	IF lRelSSL
		oMail:SetUseSSL( .T. )
	ENDIF	
	IF lRelTLS
		oMail:SetUseTLS( .T. )
	ENDIF	

	//oMail:Init( '', cServer , cAccount, cPassword, 0, 465 )
	oMail:Init( '', cServer , cAccount, cPassword, 0, 587 )
	oMail:SetSmtpTimeOut( 120 )
	nErro := oMail:SmtpConnect()
	IF nErro <> 0
		cMensagem	:= oMail:GetErrorString( nErro )
		lRet		:= .F. 	
	ENDIF
	
	IF lRet
		IF lAutentica
			IF EMPTY(cUserAut)
				cUserAut := cAccount
			ENDIF
			IF EMPTY(cPassAut)
				cPassAut := cPassword
			ENDIF

			nErro := oMail:SmtpAuth( cUserAut , cPassAut )
			IF nErro <> 0
				cMensagem	:= oMail:GetErrorString( nErro )
				lRet		:= .F. 	
			ENDIF
		ENDIF
	ENDIF
	
	IF lRet
		oMessage := TMailMessage():New()
		oMessage:Clear()
		oMessage:cFrom                  := _cRemete
		oMessage:cTo                    := _cDestin
		oMessage:cCc                    := _cCc
		oMessage:cSubject               := _cAssunto
		oMessage:cBody                  := _cCorpoEmai
		
		FOR nX := 1 TO LEN(aAnexos)
			cFile	:= aAnexos[nX]
			IF !EMPTY(cFile) .AND. FILE(cFile)
				nErro 	:= oMessage:AttachFile( cFile )
	
				IF nErro < 0
			  		cMensagem	:= "Não foi possível anexar o arquivo " + cFile + " - " + oMail:GetErrorString( nErro )
			  		lRet		:= .F. 
			  		EXIT	
			  	ENDIF
		  	ENDIF
		NEXT nX
		
		IF lRet
			nErro := oMessage:Send( oMail )
			IF nErro <> 0
				cMensagem	:= oMail:GetErrorString( nErro )
				lRet		:= .F. 	
			ENDIF
		ENDIF
	ENDIF

	IF !lRet
		IF !lJob
			MsgInfo(cMensagem, "Atenção")
		ELSE
			ConOut(cMensagem)		
		ENDIF	
	ENDIF

    oMail:SMTPDisconnect()

RETURN lRet