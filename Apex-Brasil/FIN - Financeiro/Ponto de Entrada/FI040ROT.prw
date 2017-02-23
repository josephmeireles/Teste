#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'

/*/{Protheus.doc} FI040ROT
//TODO Descri��o: Esse Ponto de Entrada inclui novos
Itens no Menu aRotina, o mesmo est� contido em Contas a Receber.
@project	SuperAcao Apex-Brasil.
@author Joseph Oliveira / Analista de Servi�os TOTVS.
@since 14/12/2016.
@version 1.0
@type function
/*/
User Function FI040ROT()
Local aRotina := PARAMIXB

Aadd(aRotina, {"Env.Carta de Cobran�a", "u_ParEnv"  , 0, 7})

Return(aRotina)

/*/{Protheus.doc} ParEnv
//TODO Descri��o: Tela de Par�metros para envio do email.
@project	SuperAcao Apex-Brasil
@author Joseph Oliveira / Analista de Servi�os TOTVS.
@since 14/12/2016
@version 1.0
@type function
/*/
USER FUNCTION ParEnv()

	LOCAL aPar			:= {}
	LOCAL aRet			:= {}
	LOCAL lEdita		:= .T.
	LOCAL aPswRet		:= {}	
	LOCAL lRet			:= .T.
	
	PRIVATE	cEMAILREM	:= SPACE(150)
	PRIVATE cNOMEREM	:= SPACE(100)
	PRIVATE cCARGOPOR	:= SPACE(100)
	PRIVATE cCARGOING	:= SPACE(100)
	PRIVATE cTELEFONE	:= SPACE(100)
	PRIVATE cCOPIAREM	:= "1-Sim"
	PRIVATE cDESTIN		:= SPACE(100)
	PRIVATE cASSUNT		:= SPACE(100)
	PRIVATE cANEXOS		:= ""
	PRIVATE aANEXOS		:= {}
	PRIVATE cCORPO		:= ""

	PswOrder(1) // ID do usu�rio/grupo
	IF PswSeek( __CUSERID, .T. ) 
		aPswRet		:= PswRet()
		cNOMEREM	:= aPswRet[1][04] // Nome completo do usu�rio
		cCARGOPOR	:= aPswRet[1][13] // Departamento
		cEMAILREM 	:= aPswRet[1][14] // E-mail
	ENDIF	 
	cNOMEREM		:= PADR(cNOMEREM,100)
	cCARGOPOR		:= PADR(cCARGOPOR,100)
	cEMAILREM 		:= PADR(cEMAILREM,150)

	//-----------------------------------------------------------------------
	// Defini��o dos Parametros da Rotina
	//-----------------------------------------------------------------------
	// 1 - MsGet
	//  [2] : Descri��o
	//  [3] : String contendo o inicializador do campo
	//  [4] : String contendo a Picture do campo
	//  [5] : String contendo a valida��o
	//  [6] : Consulta F3
	//  [7] : String contendo a valida��o When
	//  [8] : Tamanho do MsGet
	//  [9] : Flag .T./.F. Par�metro Obrigat�rio ?
	
	aAdd(aPar,{1	,"E-mail rementente"	, cEMAILREM 			, "", , 		, , 100, .T.})
	aAdd(aPar,{1	,"Nome do rementente"	, cNOMEREM 				, "", , 		, , 100, .F.})
	aAdd(aPar,{1	,"Cargo - Portugu�s"	, cCARGOPOR 			, "", , 		, , 100, .F.})
	aAdd(aPar,{1	,"Cargo - Ingl�s"		, cCARGOING 			, "", , 		, , 100, .F.})
	aAdd(aPar,{1	,"Telefone"				, cTELEFONE 			, "", , 		, , 100, .F.})
	aAdd(aPar,{2	,"Envia c�pia ao remet"	, cCOPIAREM	, { "1-Sim", "2-N�o" }, 100,'.T.',.T.})

//	Parambox ( aParametros	@cTitle	@aRet [ bOk ] [ aButtons ] [ lCentered ] [ nPosX ] [ nPosy ] [ oDlgWizard ] [ cLoad ] [ lCanSave ] [ lUserSave ] ) --> aRet

	lRet 	:= ParamBox(aPar,"Par�metros",@aRet,,,,,,,"AB_ENVCAR",.T.,.T.)
	IF lRet
		cEMAILREM	:= aRet[1]
		cNOMEREM	:= aRet[2]
		cCARGOPOR	:= aRet[3]
		cCARGOING	:= aRet[4]
		cTELEFONE	:= aRet[5]
		cCOPIAREM	:= aRet[6]	
		cDESTIN 	:= SPACE(100) 
		cANEXOS		:= ""
		cCORPO		:= "Prezados(a),"   + "</br>" + CRLF
		cCORPO		+= "Segue em anexo, carta de cobran�a administrativa." + "</br>" + CRLF + "</br>"
		cCORPO		+= CRLF + "</br>"
		cCORPO		+= "Atenciosamente,<br/><br/>" 		+ CRLF
		cCORPO		+= CRLF
		cCORPO		+= ALLTRIM(cNOMEREM)  + "</br>"			+ CRLF 
		cCORPO		+= ALLTRIM(cCARGOPOR) + "</br>"			+ CRLF
		cCORPO		+= ALLTRIM(cCARGOING) + "</br>"			+ CRLF
		cCORPO		+= ALLTRIM(cTELEFONE) + "</br> <br/>"	+ CRLF
		cCORPO 		+= "<b>Apex Brasil</b><br/> " 			+ CRLF
		cCORPO 		+= "<b>Mensagem autom�tica, favor n�o responda esse e-mail." + CRLF
								
		TelaCarta(lEdita)
		
	ENDIF

RETURN

/*/{Protheus.doc} TelaCarta
//TODO Descri��o: Tela para Envio da Carta de Cobran�a.
@project	SuperAcao Apex-Brasil
@author Joseph Oliveira / Analista de Servi�os TOTVS.
@since 14/12/2016
@version 1.0
@param lEdita, logical, descricao
@type function

/*/
STATIC FUNCTION TelaCarta(lEdita)

	Local oDlg1
	LOCAL oDestin
	LOCAL oAssunt
	LOCAL oAnexos
	LOCAL oCorpo	
	LOCAL aENVANEXO		:= {}
	LOCAL nX			:= 0
	LOCAL cLogoAssin	:= ALLTRIM(GETMV("AB_LOGCART", )) // '\dirdoc\ApexBrasil.png'
	
	PRIVATE bOpc1 		:= {|| zLocal(lEdita) }
	PRIVATE nOpca		:= 0

	//-----------------------------------------------------------------------
	// Dialog
	//-----------------------------------------------------------------------
	DEFINE MSDIALOG oDlg1 FROM  0, 0 TO 240,630 TITLE "Enviar Carta de Cobran�a" PIXEL			
/*540*/
	oDlg1:lMaximized := .F.

	@ 025,048 SAY OemToAnsi("Destinat�rio")  SIZE 32, 8 OF oDlg1 PIXEL
	@ 040,048 SAY OemToAnsi("Assunto") 		 SIZE 32, 8 OF oDlg1 PIXEL
	@ 055,048 SAY OemToAnsi("Anexos") 		 SIZE 32, 8 OF oDlg1 PIXEL

	@ 023,080 MSGET oDestin VAR cDESTIN	SIZE 231, 08 OF oDlg1 PIXEL WHEN lEdita
	@ 038,080 MSGET oAssunt VAR cASSUNT	SIZE 231, 08 OF oDlg1 PIXEL WHEN lEdita
	@ 052,080 GET   oAnexos VAR cANEXOS OF oDlg1 MULTILINE SIZE 231,20 HSCROLL PIXEL READONLY
	
/*
	IF lEdita
		@ 077,004 GET oCorpo VAR cCORPO OF oDlg1 MULTILINE SIZE 307,188 HSCROLL PIXEL
	ELSE
		@ 077,004 GET oCorpo VAR cCORPO OF oDlg1 MULTILINE SIZE 307,188 HSCROLL PIXEL READONLY
	ENDIF
*/

	@ 023,004 BUTTON "Enviar" 	SIZE 037, 024 PIXEL OF oDlg1 ACTION (nOpca := 1, oDlg1:End()) WHEN lEdita
	@ 052,004 BUTTON "Anexar" 	SIZE 037, 012 PIXEL OF oDlg1 ACTION Eval(bOpc1)

	ACTIVATE MSDIALOG oDlg1 CENTERED VALID  ( IIF(nOpca==1 , ValidaDlg(), .T.) )

	IF nOpca == 1
		FOR nX := 1 TO LEN(aANEXOS)
			AADD(aENVANEXO, cANEXOS)
		NEXT nX
			//-----------------------------------------------------------------------
			// Envia o e-mail
			//-----------------------------------------------------------------------
		IF LEFT(cCOPIAREM,1) == "1" // 1=Sim - Envia copia ao rementete
			IF !( ALLTRIM(cEMAILREM) $ ALLTRIM(cDESTIN) )
				cDESTIN += IIF(RIGHT(ALLTRIM(cDESTIN),1)==";","",";") + ALLTRIM(cEMAILREM) 
			ENDIF
		ENDIF
		
			U_EnvEmai2(cEMAILREM, cDESTIN, cASSUNT, cCORPO, aENVANEXO, cLogoAssin, /*cCc*/)
			
	ENDIF

RETURN

/*/{Protheus.doc} ValidaDlg
//TODO Descri��o: Valida dados do formul�rio.
@project	SuperAcao Apex-Brasil
@author Joseph Oliveira / Analista de Servi�os TOTVS.
@since 09/01/2017
@version 1.0
@type function
/*/
STATIC FUNCTION ValidaDlg()
	LOCAL lRet	:= .T.

	IF lRet
		IF EMPTY(cDESTIN)
			MsgAlert("� necess�rio indicar pelo menos um destinat�rio","Aten��o")
			lRet := .F.
		ELSE
			IF !("@" $ cDESTIN)
				MsgAlert("E-mail do destinat�rio inv�lido","Aten��o")
				lRet := .F.
			ELSE
				IF LEN(SEPARA(cDESTIN, "@")) <> 2
					MsgAlert("E-mail do destinat�rio inv�lido","Aten��o")
					lRet := .F.
				ENDIF
			ENDIF
		ENDIF
	ENDIF

	IF lRet
	
		IF EMPTY(cASSUNT) 
			MsgAlert("Campo Assunto Deve ser Preenchido!","Aten��o")
			lRet := .F.
		ENDIF
	ENDIF
		
	IF !lRet
		nOpca := 0
	ENDIF
	
RETURN lRet

/*/{Protheus.doc} zLocal
//TODO Descri��o Localiza o Anexo.
@project	SuperAcao Apex-Brasil
@author Joseph Oliveira
@since 14/12/2016
@version undefined
@param lEdita, logical, descricao
@type function

/*/
STATIC Function zLocal(lEdita)

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������

	Local aArea		:= GetArea()
	Local cType		:= "Arquivos DOT|*.DOT|Documento do Word 97-2003(Doc)|*.doc|Documento do Word(Docx)|*.docx|Todos os Arquivos|*.*"

	Private nHandle	:= 0
	Private cArquivo:= ""


//���������������������������������������������������������������������Ŀ
//� Exibe tela para selecionar arquivo                                  �
//�����������������������������������������������������������������������
cArquivo := cGetFile(cType, OemToAnsi("Informe o caminho do arquivo"),0,"SERVIDOR\",.F.,GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE)

	IF 	lEdita
		aANEXOS		:= {}
		cANEXOS 	:= ""
		cANEXOS 	:= cArquivo
		AADD( aANEXOS, cANEXOS )	
	ENDIF

//���������������������������������������������������������������������Ŀ
//� Valida se o arquivo existe                                          �
//�����������������������������������������������������������������������

	If Empty(cArquivo)
		Aviso("Aten��o!","Selecione o caminho v�lido!",{"Ok"})
		Return
	ENDIF
	
	RestArea(aArea)

Return
