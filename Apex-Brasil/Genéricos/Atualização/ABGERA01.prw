#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'AP5MAIL.CH'
#INCLUDE 'FILEIO.CH'

//-----------------------------------------------------------------------
/*/{Protheus.doc} EnvEmail()

Rotina para enviar e-mail

Exemplo:
U_EnvEmail("cazarini@gmail.com", "fabio.cazarini@totvs.com.br", "Teste de envio de email", "Corpo do email", {"\data\ABGERA01.prw"})

@param		cRemete		= Remetente do e-mail
			cDestin		= Destinatário do e-mail
			cAssunto	= Assunto do e-mail
			cMensagem	= Mensagem do e-mail
			aAnexos		= Anexos do e-mail - a partir do rootpath (protheus_data)
			cLogoAssin	= Local e nome do arquivo com a assinatura do email (rootpath)
@return		lRet 		= T. = Sucesso / .F. = Falha no envio do e-mail
@author 	Fabio Cazarini
@since 		19/08/2016
@version 	1.0
@project	SuperAcao Apex-Brasil
/*/
//-----------------------------------------------------------------------
USER FUNCTION EnvEmail(cRemete, cDestin, cAssunto, cCorpoEmai, aAnexos, cLogoAssin, cCc)
	LOCAL lRet			:= .T.
	DEFAULT aAnexos		:= {}
	DEFAULT cLogoAssin	:= ""
	DEFAULT cCc			:= ""

	MsgRun("Aguarde, enviando e-mail...","E-mail",{|| ProcEnvEma(cRemete, cDestin, cAssunto, cCorpoEmai, aAnexos, cLogoAssin) })

RETURN lRet


//-----------------------------------------------------------------------
/*/{Protheus.doc} ProcEnvEma()

Rotina para processar o envio do e-mail

@param		cRemete		= Remetente do e-mail
			cDestin		= Destinatário do e-mail
			cAssunto	= Assunto do e-mail
			cMensagem	= Mensagem do e-mail
			aAnexos		= Anexos do e-mail - a partir do rootpath (protheus_data)
			cLogoAssin	= Local e nome do arquivo com a assinatura do email
@return		lRet 		= T. = Sucesso / .F. = Falha no envio do e-mail
@author 	Fabio Cazarini
@since 		19/08/2016
@version 	1.0
@project	SuperAcao Apex-Brasil
/*/
//-----------------------------------------------------------------------
STATIC FUNCTION ProcEnvEma(cRemete, cDestin, cAssunto, cCorpoEmai, aAnexos, cLogoAssin, cCc)
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
	LOCAL nPorta 		:= 25
	LOCAL lEstaNoSrv	:= .F.
	LOCAL aDelFile		:= {}
	LOCAL cEnvCorpo		:= ""
		
	IF EMPTY(cRemete) .OR. EMPTY(cDestin) 
		lRet := .F.
	ENDIF

	oMail := TMailManager():New()
	
	nPorta := 25
	IF lRelSSL
		oMail:SetUseSSL( .T. )
		nPorta := 465
	ENDIF	
	IF lRelTLS
		oMail:SetUseTLS( .T. )
		nPorta := 587
	ENDIF	

	oMail:Init( '', cServer , cAccount, cPassword, 0, nPorta )
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
		cEnvCorpo	:= '<!DOCTYPE html>'
		cEnvCorpo	+= '<html lang="en">'
		cEnvCorpo	+= '<head>'
		cEnvCorpo	+= '<meta http-equiv="Content-Language" content="en-us" />'
		cEnvCorpo	+= '<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />'
		cEnvCorpo	+= '<title>Delivery Schedule</title>'
		cEnvCorpo	+= '<style type="text/css">'
		cEnvCorpo	+= '.style1 {'
		cEnvCorpo	+= 'font-family: Calibri, Arial, Helvetica, sans-serif;'
		cEnvCorpo	+= 'font-size:10.0pt;'
		cEnvCorpo	+= '}'
		cEnvCorpo	+= '.style2 {'
		cEnvCorpo	+= 'font-family: Calibri, Arial, Helvetica, sans-serif;'
		cEnvCorpo	+= 'font-size:10.0pt;'
		cEnvCorpo	+= 'border-style: solid;'
		cEnvCorpo	+= 'border-width: 1px;'
		cEnvCorpo	+= '}'
		cEnvCorpo	+= '</style>'
		cEnvCorpo	+= '</head>'	
		cEnvCorpo	+= '<body>'
		cEnvCorpo	+= '<table width="100%" border="0" class="style1">'
		
		cEnvCorpo	+= '<tr><td><span style="color:#002060">'
		cEnvCorpo	+= cCorpoEmai
		cEnvCorpo	+= '</span></td></tr>'
				
		IF !EMPTY(cLogoAssin) .AND. FILE(cLogoAssin)
			cEnvCorpo	+= '<tr><td><img src="' + ALLTRIM(SUBSTR(cLogoAssin,RAT("\",cLogoAssin)+1,LEN(cLogoAssin))) + '"/></td></tr>'
		ENDIF
		
		cEnvCorpo	+= '</table>'
		cEnvCorpo	+= '</body>'
		cEnvCorpo	+= '</html>'
		
		cEnvCorpo	:= STRTRAN( cEnvCorpo, CRLF, '<BR>' )
		
		oMessage := TMailMessage():New()
		oMessage:Clear()
		oMessage:cFrom                  := cRemete
		oMessage:cTo                    := cDestin
		oMessage:cCc                    := cCc
		oMessage:cSubject               := cAssunto
		oMessage:cBody                  := cEnvCorpo

		IF !EMPTY(cLogoAssin) .AND. FILE(cLogoAssin)
			oMessage:AttachFile( cLogoAssin ) // anexa o arquivo a partir do servidor Protheus
		ENDIF
		
		FOR nX := 1 TO LEN(aAnexos)
			cFile	:= aAnexos[nX]
			IF !EMPTY(cFile) .AND. FILE(cFile)
				lEstaNoSrv := .T.
				IF LEFT(cFile,1) <> "\" // se o arquivo não estiver no servidor
					//-----------------------------------------------------------------------
					// Copia arquivos do local p/o servidor, s/compactar antes de transmitir
					//-----------------------------------------------------------------------
					IF !CpyT2S( cFile, "\dirdoc", .F. )
				  		cMensagem	:= "Não foi possível anexar o arquivo " + cFile
				  		lRet		:= .F. 
				  		EXIT	
				  	ELSE
				  		lEstaNoSrv 	:= .F.
				  		cFile 		:= "\dirdoc\" + ALLTRIM(SUBSTR(cFile,RAT("\",cFile)+1,LEN(cFile)))
					ENDIF
				ENDIF
				
				nErro 	:= oMessage:AttachFile( cFile ) // anexa o arquivo a partir do servidor Protheus
	
				IF nErro < 0
			  		cMensagem	:= "Não foi possível anexar o arquivo " + cFile + " - " + oMail:GetErrorString( nErro )
			  		lRet		:= .F. 
			  		EXIT
			  	ELSE
					//-----------------------------------------------------------------------
					// Para apagar o arquivo copiado temporariamente para o servidor
					//-----------------------------------------------------------------------
			  		IF !lEstaNoSrv
			  			AADD( aDelFile, cFile )
			  		ENDIF
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

	//-----------------------------------------------------------------------
	// Apaga o arquivo copiado temporariamente para o servidor
	//-----------------------------------------------------------------------
    FOR nX := 1 TO LEN(aDelFile)
		FErase(aDelFile[nX])
    NEXT nX
    
RETURN lRet