#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ABFATW01  บAutor  ณ TOTVS                                 บ Data ณ  01/12/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para Envio de informa็๕es complementares - FAT003 e FAT004             บฑฑ
ฑฑบ          ณ 																				 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ APEX                                                                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function ABFATW01()
Local oDlg		   :=  Nil
Local oPanel1	   :=  Nil
Local oLabel1	   :=  Nil
Local oEdit1	   :=  Nil
Local oEdit2	   :=  Nil
Local oButton1	   :=  Nil
Local oButton2	   :=  Nil
Local nOpc         :=  ""
Local cEdit1	   :=  space(200)
Local _cDestin	   :=  space(200)
Local _cAssunto    :=  "Envio de informa็๕es complementares"
Local _cRemete     :=  UsrRetMail(__CUSERID)
Local _cCorpoEmai  :=  ""
Local lExec        :=  .F.

oFont := TFont():New('Courier new',,-20,.T.)

oDlg 	 := MSDialog():New( 140,100,600,950,"Informa็๕es Complementares",,,.F.,,,,,,.T.,,,.T. )

oSay1:= TSay():New(020,090,{||"Notifica็ใo de Informa็๕es Complementares"},oDlg,,oFont,,,,.T.,CLR_BLACK,,300,20)


oLabel1	 := TSay():New( 50,12,{|| "Mensagem:" },oPanel1,,,.F.,.F.,.F.,.T.,,,92,24)
@ 60,12 GET oEdit1 VAR _cCorpoEmai MEMO SIZE 400,100 PIXEL OF ODLG

oLabel1	 := TSay():New( 170,12,{|| "Destinatแrio:" },oPanel1,,,.F.,.F.,.F.,.T.,,,92,24)
@ 170,50 GET oEdit2 VAR _cDestin SIZE 200,009 PIXEL OF ODLG

oLabel1	 := TSay():New( 200,12,{|| "Atenciosamente," },oPanel1,,,.F.,.F.,.F.,.T.,,,92,24)
oLabel1	 := TSay():New( 210,12,{|| "WorkFlow Apex-Brasil - Mensagem automแtica, por favor, nใo responda esse e-mail." },oPanel1,,,.F.,.F.,.F.,.T.,,,300,24)

oButton1 := TButton():New( 170, 260, "Enviar",oPanel1,{|| lExec := U_WF01EMA(_cRemete,_cDestin,_cCorpoEmai,_cAssunto), Iif( lExec, oDlg:End(), .F.) },042,012,,,,.T.)

oDlg:Activate(,,,.T.)

Return( Nil )

//-----------------------------------------------------------------------
/*/
Rotina para enviar e-mail

Exemplo:
U_EnvEmail("usuario@gmail.com", "usuario@empresa.com.br", "Teste de envio de email", "Corpo do email")

@param		cRemete		= Remetente do e-mail
cDestin		= Destinatแrio do e-mail
cAssunto	= Assunto do e-mail
cMensagem	= Mensagem do e-mail
aAnexos		= Anexos do e-mail - a partir do rootpath (protheus_data)
@return		lRet 		= T. = Sucesso / .F. = Falha no envio do e-mail
@author 	TOTVS
@since 		17/11/2016
@version 	1.0
@project	SuperAcao Apex-Brasil
/*/
//-----------------------------------------------------------------------


User Function WF01EMA(_cRemete,_cDestin,_cCorpoEmai,_cAssunto)

LOCAL oMail, oMessage
LOCAL nErro
LOCAL cServer		:= ALLTRIM(GETMV("MV_RELSERV"))    // Nome do servidor de envio de e-mail (SMTP) utilizado no envio
LOCAL cAccount		:= ALLTRIM(GETMV("MV_RELACNT"))    // Conta a ser utilizada no envio
LOCAL cPassword 	:= ALLTRIM(GETMV("MV_RELPSW"))     // Senha da conta de e-mail utilizada no envio
LOCAL lAutentica	:= GETMV("MV_RELAUTH")             // Servidor de e-mail necessita de autentica็ใo
LOCAL cUserAut 		:= ALLTRIM(GETMV("MV_WFAUTUS"))    // Caso o servidor SMTP necessite de autentica็ใo, definir neste parโmetro o usuแrio desta autentica็ใo
LOCAL cPassAut 		:= ALLTRIM(GETMV("MV_WFAUTSE"))    // Caso o servidor SMTP necessite de autentica็ใo, definir neste parโmetro a senha do usuแrio desta autentica็ใo
LOCAL lRelTLS 		:= GETMV("MV_RELTLS")              // Utilizar ou nใo conexใo segura TLS
LOCAL lRelSSL 		:= GETMV("MV_RELSSL")              // Utilizar ou nใo conexใo segura SSL
LOCAL lRet			:= .T.
LOCAL lJob 			:= !(Type("oMainWnd")=="O")
LOCAL cMensagem		:= ""
LOCAL cFile			:= ""
LOCAL nX			:= 0

DEFAULT aAnexos		:= {}

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

oMail:Init( '', cServer , cAccount, cPassword, 0, 587 )
oMail:SetSmtpTimeOut( 120 )
nErro := oMail:SmtpConnect()
IF nErro <> 0
	cMensagem := oMail:GetErrorString( nErro )
	lRet := .F.
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
	oMessage:cSubject               := _cAssunto
	oMessage:cBody                  := _cCorpoEmai
	
/*	// Envio de anexos
	FOR nX := 1 TO LEN(aAnexos)
		cFile	:= aAnexos[nX]
		IF !EMPTY(cFile) .AND. FILE(cFile)
			nErro 	:= oMessage:AttachFile( cFile )
			
			IF nErro < 0
				cMensagem	:= "Nใo foi possํvel anexar o arquivo " + cFile + " - " + oMail:GetErrorString( nErro )
				lRet		:= .F.
				EXIT
			ENDIF
		ENDIF
	NEXT nX
*/	
	
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
		MsgInfo(cMensagem, "Aten็ใo")
	ELSE
		ConOut(cMensagem)
	ENDIF
ENDIF

oMail:SMTPDisconnect()

RETURN lRet


