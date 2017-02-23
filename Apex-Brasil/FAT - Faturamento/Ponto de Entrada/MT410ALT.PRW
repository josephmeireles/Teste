#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MT410ALT  ºAutor  ³ TOTVS                                º Data ³  01/12/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função para Workflow de aviso quando o campo “PARTICIPANTE” no                º±±
±±º          ³ no pedido de vendas for alterado - FAT009     								 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ APEX                                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MT410ALT()

Local  aArea      := GetArea()
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
Local _cAssunto    :=  "Alteração no pedido de vendas - Participante"
Local _cRemete     :=  UsrRetMail(__CUSERID)
Local _cCorpoEmai  :=  ""
Local lExec        :=  .F.

If M->C5_PARTICI == "2"
	
	oFont := TFont():New('Courier new',,-20,.T.)
	
	oDlg 	 := MSDialog():New( 140,100,600,950,"Alteração no pedido de vendas - Participante",,,.F.,,,,,,.T.,,,.T. )
	
	oSay1:= TSay():New(020,090,{||"Notificação de alteração no pedido de vendas"},oDlg,,oFont,,,,.T.,CLR_BLACK,,300,20)
	
	
	oLabel1	 := TSay():New( 50,12,{|| "Mensagem:" },oPanel1,,,.F.,.F.,.F.,.T.,,,92,24)
	@ 60,12 GET oEdit1 VAR _cCorpoEmai MEMO SIZE 400,100 PIXEL OF ODLG
	
	oLabel1	 := TSay():New( 170,12,{|| "Destinatário:" },oPanel1,,,.F.,.F.,.F.,.T.,,,92,24)
	@ 170,50 GET oEdit2 VAR _cDestin SIZE 200,009 PIXEL OF ODLG
	
	oLabel1	 := TSay():New( 200,12,{|| "Atenciosamente," },oPanel1,,,.F.,.F.,.F.,.T.,,,92,24)
	oLabel1	 := TSay():New( 210,12,{|| "WorkFlow Apex-Brasil - Mensagem automática, por favor, não responda esse e-mail." },oPanel1,,,.F.,.F.,.F.,.T.,,,300,24)
	
	oButton1 := TButton():New( 170, 260, "Enviar",oPanel1,{|| lExec := U_WF01EMAI(_cRemete,_cDestin,_cCorpoEmai,_cAssunto), Iif( lExec, oDlg:End(), .F.) },042,012,,,,.T.)
	
	oDlg:Activate(,,,.T.)
	
EndIf

RestArea(aArea)

Return( Nil )

//-----------------------------------------------------------------------
/*/
Rotina para enviar e-mail

Exemplo:
U_EnvEmail("usuario@gmail.com", "usuario@empresa.com.br", "Teste de envio de email", "Corpo do email")

@param		cRemete		= Remetente do e-mail
cDestin		= Destinatário do e-mail
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


static Function WF02EMAI(_cRemete,_cDestin,_cCorpoEmai,_cAssunto)

LOCAL oMail, oMessage
LOCAL nErro
LOCAL cServer		:= ALLTRIM(GETMV("MV_RELSERV"))    // Nome do servidor de envio de e-mail (SMTP) utilizado no envio
LOCAL cAccount		:= ALLTRIM(GETMV("MV_RELACNT"))    // Conta a ser utilizada no envio
LOCAL cPassword 	:= ALLTRIM(GETMV("MV_RELPSW"))     // Senha da conta de e-mail utilizada no envio
LOCAL lAutentica	:= GETMV("MV_RELAUTH")             // Servidor de e-mail necessita de autenticação
LOCAL cUserAut 		:= ALLTRIM(GETMV("MV_WFAUTUS"))    // Caso o servidor SMTP necessite de autenticação, definir neste parâmetro o usuário desta autenticação
LOCAL cPassAut 		:= ALLTRIM(GETMV("MV_WFAUTSE"))    // Caso o servidor SMTP necessite de autenticação, definir neste parâmetro a senha do usuário desta autenticação
LOCAL lRelTLS 		:= GETMV("MV_RELTLS")              // Utilizar ou não conexão segura TLS
LOCAL lRelSSL 		:= GETMV("MV_RELSSL")              // Utilizar ou não conexão segura SSL
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
	cMensagem	:= "Não foi possível anexar o arquivo " + cFile + " - " + oMail:GetErrorString( nErro )
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
		MsgInfo(cMensagem, "Atenção")
	ELSE
		ConOut(cMensagem)
	ENDIF
ENDIF

oMail:SMTPDisconnect()

RETURN lRet


