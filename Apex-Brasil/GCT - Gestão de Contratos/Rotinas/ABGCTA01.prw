#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'

//-----------------------------------------------------------------------
/*/{Protheus.doc} ABGCTA01()

Ao clicar no botão Cartas ao Fornecedor serão apresentadas, caso existam, 
as cartas enviadas ao fornecedor por e-mail. 

Recursos:
- Visualizar uma carta já enviada
- Enviar uma nova carta
- Imprimir uma carta enviada ou a nova carta

@param		Nenhum
@return		Nenhum
@author 	Fabio Cazarini
@since 		01/09/2016
@version 	1.0
@project	SuperAcao Apex-Brasil
/*/
//-----------------------------------------------------------------------
USER FUNCTION ABGCTA01()

	PRIVATE cString 	:= "PA2"
	PRIVATE aRotina		:= {} 
	PRIVATE cCadastro	:= "Cartas ao fornecedor"
	PRIVATE bOpc1 		:= {|| VisCarta()}
	PRIVATE bOpc2 		:= {|| IncCarta()}

	aAdd( aRotina,		{ "Pesquisar"			, "AxPesqui" 				, 0 , 1 }) // Funcao de Pesquisa 
	aAdd( aRotina,		{ "Visualizar Carta" 	, "Eval(bOpc1)"				, 0 , 2 }) // Funcao de Visualizar
	aAdd( aRotina,		{ "Incluir Nova Carta"	, "Eval(bOpc2)"				, 0 , 3 }) // Funcao de Incluir

	//-----------------------------------------------------------------------
	// Interface com usuario
	//-----------------------------------------------------------------------
	DbSelectArea(cString)
	DbSetOrder(1) // PA2_FILIAL+PA2_FILCNT+PA2_CONTRA+PA2_REVISA+PA2_NUM
	SET FILTER TO PA2->(PA2_FILCNT+PA2_CONTRA+PA2_REVISA) == PADR(CN9->CN9_FILIAL,LEN(PA2->PA2_FILCNT)) + PADR(CN9->CN9_NUMERO,LEN(PA2->PA2_CONTRA)) + PADR(CN9->CN9_REVISA,LEN(PA2->PA2_REVISA))

	dbGoTop()

	mBrowse(,,,,cString)

	DbSelectArea(cString)
	SET FILTER TO

RETURN


//-----------------------------------------------------------------------
/*/{Protheus.doc} VisCarta()

Visualizar uma carta já enviada ao fornecedor

@param		Nenhum
@return		Nenhum
@author 	Fabio Cazarini
@since 		01/09/2016
@version 	1.0
@project	SuperAcao Apex-Brasil
/*/
//-----------------------------------------------------------------------
STATIC FUNCTION VisCarta()
	LOCAL lEdita		:= .F.
	LOCAL cArquivo		:= ""

	PRIVATE cDESTIN		:= PA2->PA2_DESTIN
	PRIVATE cASSUNT		:= PA2->PA2_ASSUNT
	PRIVATE cANEXOS		:= ""
	PRIVATE aANEXOS		:= {}
	PRIVATE cCORPO		:= PA2->PA2_CORPO

	//-----------------------------------------------------------------------
	// Buscar os anexos na tabela PA3
	//-----------------------------------------------------------------------
	DbSelectArea("PA3")
	DbSetOrder(1) // PA3_FILIAL+PA3_NUM+PA3_ITEM
	IF DBSEEK( PA2->(PA2_FILIAL+PA2_NUM) )
		DO WHILE ! PA3->( EOF() ) .AND. PA3->(PA3_FILIAL+PA3_NUM) == PA2->(PA2_FILIAL+PA2_NUM)
			cArquivo := ALLTRIM(PA3->PA3_LOCAL)
			IF RIGHT(cArquivo,1) <> "\"
				cArquivo += "\"
			ENDIF
			cArquivo 	+= ALLTRIM(PA3->PA3_NOME)
			IF !EMPTY(cANEXOS)
				cANEXOS 	+= "; "
			ENDIF
			cANEXOS 	+= cArquivo
			
			AADD( aANEXOS, {PA3->PA3_NOME, PA3->PA3_LOCAL} )
			
			DbSelectArea("PA3")
			DbSkip()
		ENDDO  
	ENDIF
	
	TelaCarta(lEdita)

RETURN


//-----------------------------------------------------------------------
/*/{Protheus.doc} IncCarta()

Enviar uma nova carta ao fornecedor

@param		Nenhum
@return		Nenhum
@author 	Fabio Cazarini
@since 		01/09/2016
@version 	1.0
@project	SuperAcao Apex-Brasil
/*/
//-----------------------------------------------------------------------
STATIC FUNCTION IncCarta()

	LOCAL aPar		:= {}
	LOCAL aRet		:= {}
	LOCAL lEdita	:= .T.
	LOCAL aPswRet	:= {}
	
	PRIVATE	cEMAILREM	:= SPACE(150)
	PRIVATE cNOMEREM	:= SPACE(100)
	PRIVATE cCARGOPOR	:= SPACE(100)
	PRIVATE cCARGOING	:= SPACE(100)
	PRIVATE cTELEFONE	:= SPACE(100)
	PRIVATE cTIPOCARTA	:= "1-Carta de boas-vindas"
	PRIVATE cCOPIAREM	:= "1-Sim"

	PRIVATE cDESTIN		:= SPACE( LEN(PA2->PA2_DESTIN) )
	PRIVATE cASSUNT		:= ""
	PRIVATE cANEXOS		:= ""
	PRIVATE aANEXOS		:= {}
	PRIVATE cCORPO		:= ""

	IF Alltrim(CN9->CN9_SITUAC) == '02' // EM ELABORAÇÃO
		MsgAlert("Contrato EM ELABORAÇÃO. Não é possível incluir uma carta ao fornecedor deste contrato","Atenção")
		RETURN
	ENDIF
	
	IF Alltrim(CN9->CN9_SITUAC) == '10' // REVISADO
		MsgAlert("Contrato REVISADO. Não é possível incluir uma carta ao fornecedor deste contrato. Selecione a última revisão deste contrato.","Atenção")
		RETURN	
	ENDIF

	PswOrder(1) // ID do usuário/grupo
	IF PswSeek( __CUSERID, .T. ) 
		aPswRet	:= PswRet()
		cNOMEREM	:= aPswRet[1][04] // Nome completo do usuário
		cCARGOPOR	:= aPswRet[1][13] // Departamento
		cEMAILREM 	:= aPswRet[1][14] // E-mail
	ENDIF	 
	cNOMEREM	:= PADR(cNOMEREM, 100)
	cCARGOPOR	:= PADR(cCARGOPOR,100)
	cEMAILREM 	:= PADR(cEMAILREM, 150)

	//-----------------------------------------------------------------------
	// Definição dos Parametros da Rotina
	//-----------------------------------------------------------------------
	// 1 - MsGet
	//  [2] : Descrição
	//  [3] : String contendo o inicializador do campo
	//  [4] : String contendo a Picture do campo
	//  [5] : String contendo a validação
	//  [6] : Consulta F3
	//  [7] : String contendo a validação When
	//  [8] : Tamanho do MsGet
	//  [9] : Flag .T./.F. Parâmetro Obrigatório ?
	//
	aAdd(aPar,{1	,"E-mail rementente"	, cEMAILREM 			, "", , 		, , 100, .T.})
	aAdd(aPar,{1	,"Nome do rementente"	, cNOMEREM 				, "", , 		, , 100, .F.})
	aAdd(aPar,{1	,"Cargo - Português"	, cCARGOPOR 			, "", , 		, , 100, .F.})
	aAdd(aPar,{1	,"Cargo - Inglês"		, cCARGOING 			, "", , 		, , 100, .F.})
	aAdd(aPar,{1	,"Telefone"				, cTELEFONE 			, "", , 		, , 100, .F.})
	aAdd(aPar,{2	,"Tipo de carta"		,cTIPOCARTA	, { "1-Carta de boas-vindas", "2-Carta de aditivo", "3-Carta de cancelamento" }, 100,'.T.',.T.})
	aAdd(aPar,{2	,"Envia cópia ao remet"	,cCOPIAREM	, { "1-Sim", "2-Não" }, 100,'.T.',.T.})

	//Parambox ( aParametros	@cTitle	@aRet [ bOk ] [ aButtons ] [ lCentered ] [ nPosX ] [ nPosy ] [ oDlgWizard ] [ cLoad ] [ lCanSave ] [ lUserSave ] ) --> aRet

	lRet 	:= ParamBox(aPar,"Parâmetros",@aRet,,,,,,,"ABGCTAA",.T.,.T.)
	IF lRet
		cEMAILREM	:= aRet[1]
		cNOMEREM	:= aRet[2]
		cCARGOPOR	:= aRet[3]
		cCARGOING	:= aRet[4]
		cTELEFONE	:= aRet[5]
		cTIPOCARTA	:= aRet[6]
		cCOPIAREM	:= aRet[7]
		
		cASSUNT := ""
		IF LEFT(cTIPOCARTA,1) == "1"
			cASSUNT += "CARTA DE BOAS-VINDAS"
		ELSEIF LEFT(cTIPOCARTA,1) == "2" 
			cASSUNT += "CARTA DE ADITIVO"
		ELSEIF LEFT(cTIPOCARTA,1) == "3"
			cASSUNT += "CARTA DE CANCELAMENTO"				
		ENDIF
		cASSUNT		:= PADR(cASSUNT + IIF(!EMPTY(cASSUNT)," - ","") +"CONTRATO " + ALLTRIM(CN9->CN9_NUMERO), LEN(PA2->PA2_ASSUNT) )
		
		DbSelectArea("CNC")
		DbSetOrder(1) // CNC_FILIAL+CNC_NUMERO+CNC_REVISA+CNC_CODIGO+CNC_LOJA
		IF DbSEEK(CN9->CN9_FILIAL+CN9->CN9_NUMERO+CN9->CN9_REVISA)
			cDESTIN := POSICIONE("SA2",1,xFilial("SA2")+CNC->CNC_CODIGO+CNC->CNC_LOJA,"A2_EMAIL")
			cDESTIN	:= PADR(cDESTIN, LEN(PA2->PA2_DESTIN))
		ELSE
			cDESTIN := SPACE( LEN(PA2->PA2_DESTIN) ) 
		ENDIF
	
		cANEXOS		:= ""
		cCORPO		:= ""

		cCORPO		+= ALLTRIM(SM0->M0_CIDCOB) + "-" + ALLTRIM(SM0->M0_ESTCOB) + ", " + STRZERO(DAY(dDATABASE),2) + " de " + UPPER(MesExtenso(MONTH(dDATABASE))) + " de " + STRZERO(YEAR(dDATABASE),4) + "." + CRLF  
		cCORPO		+= CRLF 
		cCORPO		+= "A/C " + ALLTRIM(SA2->A2_CONTATO) + CRLF
		cCORPO		+= ALLTRIM(SA2->A2_NOME) + CRLF
		cCORPO		+= ALLTRIM(SA2->A2_END) + IIF(!EMPTY(SA2->A2_END) .AND. !EMPTY(SA2->A2_BAIRRO)," - ","") + ALLTRIM(SA2->A2_BAIRRO) + CRLF
		IF !EMPTY(SA2->A2_CEP)
			cCORPO		+= "CEP " + TRANSFORM(ALLTRIM(SA2->A2_CEP),"@r 99999-999") + CRLF
		ENDIF
		cCORPO		+= ALLTRIM(SA2->A2_MUN) + IIF(!EMPTY(SA2->A2_MUN) .AND. !EMPTY(SA2->A2_EST)," - ","") + SA2->A2_EST + CRLF
		cCORPO		+= CRLF 
		cCORPO		+= "ASSUNTO: " + cASSUNT + CRLF 
		cCORPO		+= CRLF 
		cCORPO		+= CRLF // texto - copiar e colar  
		cCORPO		+= CRLF 
		cCORPO		+= "Atenciosamente," + CRLF 
		cCORPO		+= CRLF
		cCORPO		+= ALLTRIM(cNOMEREM) + CRLF
		cCORPO		+= ALLTRIM(cCARGOPOR) + CRLF
		cCORPO		+= ALLTRIM(cCARGOING) + CRLF
		cCORPO		+= CRLF
		cCORPO		+= ALLTRIM(cTELEFONE) + CRLF
								
		/*		
		CARTA APEX-BRASIL No: 727/2016
		Brasília-DF, 03 de agosto de 2016. 
		
		A/C NILTON JOSÉ MIGLIOZZI
		PREMIER EVENTOS LTDA
		ALAMEDA AUGUSTO STELLFELD Nº 456 - CENTRO
		CEP 80410-140
		CURITIBA - PR
		
		Assunto: Contrato 3306/2015
		
		...
		<< Texto livre  - Copiar e colar o conteúdo>>
		...
		
		Atenciosamente,
		
		HÉBERTO S MENDANHA
		Coordenador de Contratos 
		Contracts Coordinator
		
		+55 (61) 3426.0268
		*/	
		

		TelaCarta(lEdita)
	ENDIF

RETURN


//-----------------------------------------------------------------------
/*/{Protheus.doc} TelaCarta()

Enviar uma nova carta ao fornecedor

@param		lEdita	= Permite editar os dados
@return		Nenhum
@author 	Fabio Cazarini
@since 		01/09/2016
@version 	1.0
@project	SuperAcao Apex-Brasil
/*/
//-----------------------------------------------------------------------
STATIC FUNCTION TelaCarta(lEdita)
	LOCAL oDlgCar
	LOCAL oDestin
	LOCAL oAssunt
	LOCAL oAnexos
	LOCAL oCorpo	
	LOCAL aENVANEXO		:= {}
	LOCAL nX			:= 0
	LOCAL cLogoAssin	:= ALLTRIM(GETMV("AB_LOGCART")) // '\dirdoc\ApexBrasil.png'
	
	PRIVATE bOpc1 		:= {|| AnexoCarta(lEdita) }
	PRIVATE bOpc2 		:= {|| ImprimeCar() }
	PRIVATE nOpca		:= 0

	//-----------------------------------------------------------------------
	// Dialog
	//-----------------------------------------------------------------------
	DEFINE MSDIALOG oDlgCar FROM  0, 0 TO 540,630 TITLE "Carta ao Fornecedor" PIXEL			

	oDlgCar:lMaximized := .F.

	@ 025,048 SAY OemToAnsi("Destinatário")  SIZE 32, 8 OF oDlgCar PIXEL
	@ 040,048 SAY OemToAnsi("Assunto") 		 SIZE 32, 8 OF oDlgCar PIXEL
	@ 055,048 SAY OemToAnsi("Anexos") 		 SIZE 32, 8 OF oDlgCar PIXEL

	@ 023,080 MSGET oDestin VAR cDESTIN	SIZE 231, 08 OF oDlgCar PIXEL WHEN lEdita
	@ 038,080 MSGET oAssunt VAR cASSUNT	SIZE 231, 08 OF oDlgCar PIXEL WHEN lEdita
	@ 052,080 GET oAnexos VAR cANEXOS OF oDlgCar MULTILINE SIZE 231,20 HSCROLL PIXEL READONLY

	IF lEdita
		@ 077,004 GET oCorpo VAR cCORPO OF oDlgCar MULTILINE SIZE 307,188 HSCROLL PIXEL
	ELSE
		@ 077,004 GET oCorpo VAR cCORPO OF oDlgCar MULTILINE SIZE 307,188 HSCROLL PIXEL READONLY
	ENDIF
	
	@ 023,004 BUTTON "Enviar" 	SIZE 037, 024 PIXEL OF oDlgCar ACTION (nOpca := 1, oDlgCar:End()) WHEN lEdita
	@ 052,004 BUTTON "Anexar" 	SIZE 037, 012 PIXEL OF oDlgCar ACTION Eval(bOpc1)

	@ 006,274 BUTTON "Imprimir"	SIZE 037, 012 PIXEL OF oDlgCar ACTION Eval(bOpc2)

	ACTIVATE MSDIALOG oDlgCar CENTERED VALID  ( IIF(nOpca==1 , ValidaDlg(), .T.) )

	IF nOpca == 1
		FOR nX := 1 TO LEN(aANEXOS)
			AADD(aENVANEXO, ALLTRIM(aAnexos[nX][2]) + ALLTRIM(aAnexos[nX][1]))
		NEXT nX

		//-----------------------------------------------------------------------
		// Grava o histórico nas tabelas PA2 e PA3
		//-----------------------------------------------------------------------
		IF GravaCarta()
			//-----------------------------------------------------------------------
			// Envia o e-mail
			//-----------------------------------------------------------------------
			IF LEFT(cCOPIAREM,1) == "1" // 1=Sim - Envia copia ao rementete
				IF !( ALLTRIM(cEMAILREM) $ ALLTRIM(cDESTIN) )
					cDESTIN += IIF(RIGHT(ALLTRIM(cDESTIN),1)==";","",";") + ALLTRIM(cEMAILREM) 
				ENDIF
			ENDIF
			U_EnvEmail(cEMAILREM, cDESTIN, cASSUNT, cCORPO, aENVANEXO, cLogoAssin)
		ENDIF
	ENDIF

RETURN


//-----------------------------------------------------------------------
/*/{Protheus.doc} ValidaDlg()

Valida dados do formulário

@param		lEdita	= Permite editar os dados
@return		Nenhum
@author 	Fabio Cazarini
@since 		08/09/2016
@version 	1.0
@project	SuperAcao Apex-Brasil
/*/
//-----------------------------------------------------------------------
STATIC FUNCTION ValidaDlg()
	LOCAL lRet	:= .T.

	IF lRet
		IF EMPTY(cDESTIN)
			MsgAlert("É necessário indicar pelo menos um destinatário","Atenção")
			lRet := .F.
		ELSE
			IF !("@" $ cDESTIN)
				MsgAlert("E-mail do destinatário inválido","Atenção")
				lRet := .F.
			ELSE
				IF LEN(SEPARA(cDESTIN, "@")) <> 2
					MsgAlert("E-mail do destinatário inválido","Atenção")
					lRet := .F.
				ENDIF
			ENDIF
		ENDIF
	ENDIF

	IF lRet
		IF EMPTY(cASSUNT) .AND. EMPTY(cCORPO)
			MsgAlert("É necessário indicar o assunto ou a mensagem","Atenção")
			lRet := .F.
		ENDIF
	ENDIF
	
	IF !lRet
		nOpca := 0
	ENDIF
	
RETURN lRet


//-----------------------------------------------------------------------
/*/{Protheus.doc} AnexoCarta()

Anexa um arquivo à carta ao fornecedor

@param		lEdita	= Permite editar os dados
@return		Nenhum
@author 	Fabio Cazarini
@since 		08/09/2016
@version 	1.0
@project	SuperAcao Apex-Brasil
/*/
//-----------------------------------------------------------------------
STATIC FUNCTION AnexoCarta(lEdita)

	LOCAL aButtons	:= {}
	LOCAL cTitulo	:= "Anexos"
	LOCAL nX		:= 0
	LOCAL nOpc		:= 0
	LOCAL cArquivo	:= ""

	PRIVATE oDlgPA3
	PRIVATE aCols	:= {}
	PRIVATE aHeader	:= {}
	PRIVATE oGD
	PRIVATE aCoord	:= FwGetDialogSize(oMainWnd)
	
	PRIVATE cUltLoc	:= ""

	IF lEdita
		aAdd( aButtons, { "EDIT", {|| AnexarArq() }, "Anexar arquivo" } )
	ENDIF	

	Aadd(aHeader,{"Nome do Arq"		,"PA3_NOME"		,""	,TAMSX3("PA3_NOME")[1]		,0,"","","C","","V","",""})
	Aadd(aHeader,{"Local do Arq"	,"PA3_LOCAL"	,""	,TAMSX3("PA3_LOCAL")[1]		,0,"","","C","","V","",""})

	//-----------------------------------------------------------------------
	// Popula 
	//-----------------------------------------------------------------------
	FOR nX := 1 TO LEN(aAnexos)
		Aadd(aCols,Array(Len(aHeader)+1))
		
		aCols[Len(aCols)][1]	:= aAnexos[nX][1]
		aCols[Len(aCols)][2]	:= aAnexos[nX][2]
		
		aCols[Len(aCols),Len(aHeader)+1] := .F.
	NEXT nX
	
	//-----------------------------------------------------------------------
	// Monta tela
	//-----------------------------------------------------------------------
	oDlgPA3 := MSDIALOG():New(aCoord[1],aCoord[2],aCoord[3]/2,(aCoord[4]/2)+100,cTitulo,,,,,,,,,.T.)    
			
	oGD := MsNewGetDados():New(0,0,80,100,IIF(lEdita,GD_DELETE,NIL),,,,,0,Len(aCols),,,,oDlgPA3,aHeader,aCols,.T.)
	oGD:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	//EnchoiceBar - Criação de barras de botões padrão ( oDlg bOkb Cancel [ lMsgDel ] [ aButtons ] [ nRecno ] [ cAlias ] [lMashups] [lImpCad] [lPadrao] [lHasOk] [lWalkThru] [cProfileID] ) --> Nil

	oDlgPA3:bInit := {|| EnchoiceBar(oDlgPA3, {||nOpc := 1, oDlgPA3:End()},{||oDlgPA3:End()},,aButtons,,,.F.,.F.,.T.,.T.,.F.)}
	
	oDlgPA3:lCentered := .T.
	oDlgPA3:Activate()
	
	IF nOpc == 1
		//-----------------------------------------------------------------------
		// Atualiza os anexos na array e string
		//-----------------------------------------------------------------------
		aANEXOS	:= {}
		cANEXOS := ""
		FOR nX := 1 TO LEN(aCols)
			IF !aCols[nX][Len(aHeader)+1] // se não estiver deletado
				cArquivo := ALLTRIM(aCols[nX][2]) + ALLTRIM(aCols[nX][1])
	
				IF !EMPTY(cANEXOS)
					cANEXOS 	+= "; "
				ENDIF
				cANEXOS 	+= cArquivo
	
				AADD( aANEXOS, {aCols[nX][1], aCols[nX][2]} )
			ENDIF
		NEXT nX
	ENDIF
	
RETURN


//-----------------------------------------------------------------------
/*/{Protheus.doc} AnexarArq()

Anexa um arquivo à carta ao fornecedor

@param		Nenhum
@return		Nenhum
@author 	Fabio Cazarini
@since 		08/09/2016
@version 	1.0
@project	SuperAcao Apex-Brasil
/*/
//-----------------------------------------------------------------------
STATIC FUNCTION AnexarArq()
	LOCAL cDrive	:= ""
	LOCAL cDir		:= ""
	LOCAL cNome		:= ""
	LOCAL cExt		:= ""
	LOCAL cArquivo	:= ""

	//cGetFile ( [ cMascara], [ cTitulo], [ nMascpadrao], [ cDirinicial], [ lSalvar], [ nOpcoes], [ lArvore], [ lKeepCase] ) --> cRet
	//cArquivo := cGetFile( '*.*', 'Arquivo (*.*)', 1, cUltLoc, .F., GETF_MULTISELECT, .T., .T. )
	cArquivo := cGetFile( '*.*' , 'Arquivo (*.*)', 1, cUltLoc, .F., GETF_NETWORKDRIVE+GETF_LOCALHARD,.T., .T. )

	IF !EMPTY(cArquivo)
		IF ASCAN(aANEXOS, {|x| ALLTRIM(x[2])+ALLTRIM(x[1]) == ALLTRIM(cArquivo)}) == 0 // se o arquivo não estiver na lista
			//-----------------------------------------------------------------------
			// Divide um caminho de disco completo em todas as suas subpartes
			//-----------------------------------------------------------------------
			SplitPath( cArquivo, @cDrive, @cDir, @cNome, @cExt )
	
			//-----------------------------------------------------------------------
			// Inclui no aCols  
			//-----------------------------------------------------------------------
			AADD( aANEXOS, {cNome + cExt, cDrive + cDir} )

			IF !EMPTY(cANEXOS)
				cANEXOS 	+= "; "
			ENDIF
			cANEXOS 	+= cArquivo
			
			Aadd(aCols,Array(Len(aHeader)+1))
			
			aCols[Len(aCols)][1]	:= cNome + cExt
			aCols[Len(aCols)][2]	:= cDrive + cDir
			
			aCols[Len(aCols),Len(aHeader)+1] := .F.
			
			oGD:oBrowse:SetArray( aCols )
			oGD:aCols := aCols
			oGD:oBrowse:Refresh(.T.)
		
			cUltLoc := cDrive + cDir
		ENDIF
	ENDIF	

RETURN


//-----------------------------------------------------------------------
/*/{Protheus.doc} GravaCarta()

Grava o histórico nas tabelas PA2 e PA3

@param		Nenhum
@return		Nenhum
@author 	Fabio Cazarini
@since 		09/09/2016
@version 	1.0
@project	SuperAcao Apex-Brasil
/*/
//-----------------------------------------------------------------------
STATIC FUNCTION GravaCarta()
	LOCAL aArea	:= GetArea()
	LOCAL cNUM	:= ""
	LOCAL nX	:= 0
	LOCAL lRet	:= .T.

	//-----------------------------------------------------------------------
	// Busca o último número de carta
	//-----------------------------------------------------------------------
	DO WHILE .T.
		cNUM := GetSXENum("PA2","PA2_NUM")
		ConfirmSX8()

		DbSelectArea("PA2")
		PA2->( dbSetOrder(2) ) // PA2_FILIAL+PA2_NUM
		If !PA2->(dbSeek(xFilial('PA2') + cNUM))	
			EXIT
		EndIF
	ENDDO

	//-----------------------------------------------------------------------
	// Complementa o corpo do e-mail com o número da carta
	//-----------------------------------------------------------------------
	cCORPO := "CARTA " + ALLTRIM(FWCompanyName()) + " No: " + ALLTRIM(cNUM) + CRLF + cCORPO 

	//-----------------------------------------------------------------------
	// Grava os dados da carta
	//-----------------------------------------------------------------------
	DbSelectArea("PA2")
	RecLock("PA2", .T.)
	PA2->PA2_FILIAL	:= xFILIAL("PA2")
	PA2->PA2_NUM	:= cNUM
	PA2->PA2_DATA	:= dDATABASE
	PA2->PA2_HORA	:= TIME()
	PA2->PA2_FILCNT	:= CN9->CN9_FILIAL
	PA2->PA2_CONTRA	:= CN9->CN9_NUMERO
	PA2->PA2_REVISA	:= CN9->CN9_REVISA
	PA2->PA2_TIPO	:= LEFT(cTIPOCARTA,1)
	PA2->PA2_DESTIN	:= cDESTIN 
	PA2->PA2_ASSUNT	:= cASSUNT
	PA2->PA2_CORPO	:= cCORPO
	PA2->PA2_USRINC	:= cUSERNAME
	PA2->( MsUnLock() )

	//-----------------------------------------------------------------------
	// Grava os anexos da carta
	//-----------------------------------------------------------------------
	FOR nX := 1 TO LEN(aAnexos)
		DbSelectArea("PA3")
		RecLock("PA3", .T.)
		PA3->PA3_FILIAL	:= xFILIAL("PA3")
		PA3->PA3_NUM	:= cNUM
		PA3->PA3_ITEM	:= STRZERO(nX, LEN(PA3->PA3_ITEM))
		PA3->PA3_LOCAL	:= aAnexos[nX][02]
		PA3->PA3_NOME	:= aAnexos[nX][01]
		PA3->( MsUnLock() )
	NEXT nX
	
	RestArea( aArea )
	
RETURN lRet


//-----------------------------------------------------------------------
/*/{Protheus.doc} ImprimeCar()

Imprime a carta ao fornecedor

@param		Nenhum
@return		Nenhum
@author 	Fabio Cazarini
@since 		14/09/2016
@version 	1.0
@project	SuperAcao Apex-Brasil
/*/
//-----------------------------------------------------------------------
STATIC FUNCTION ImprimeCar()
	LOCAL aCorpo		:= {}
	LOCAL nX			:= 0
	LOCAL cLogoAssin	:= ALLTRIM(GETMV("AB_LOGCART")) // '\dirdoc\ApexBrasil.png'

	PRIVATE cTitulo 	:= "Impressão - Carta ao fornecedor"
	PRIVATE oPrn    	:= NIL

	PRIVATE oFont1		:= TFont():New( "Calibri",,10,,.F.,,,,,.F. ) // normal
	PRIVATE oFont2		:= TFont():New( "Calibri",,14,,.F.,,,,,.F. ) // normal
	PRIVATE oFont3		:= TFont():New( "Calibri",,18,,.F.,,,,,.F. ) // normal
	PRIVATE nColIni		:= 050  
	PRIVATE nTamHPAG	:= 2200
	PRIVATE nTamVPAG	:= 2800
	PRIVATE nTamLin		:= 137
	PRIVATE nPag		:= 0
	PRIVATE cLinha		:= ""
	PRIVATE nLinha		:= 0

	//-----------------------------------------------------------------------
	// Prepara as linhas para impressao
	//-----------------------------------------------------------------------
	//aCorpo := SEPARA( cCorpo, CRLF )
	FOR nX := 1 TO MlCount(ALLTRIM(cCorpo),nTamLin)
		aAdd(aCorpo, MemoLine(ALLTRIM(cCorpo),nTamLin,nX))
	NEXT nX

	oPrn := FWMSPrinter():New(cTitulo)

	//-----------------------------------------------------------------------
	// Parametros da impressao
	//-----------------------------------------------------------------------
	oPrn:SetResolution(72)
	oPrn:SetPortrait()
	oPrn:SetPaperSize(DMPAPER_A4) 
	oPrn:SetMargin(10,10,10,10)  

	//-----------------------------------------------------------------------
	// Impressao
	//-----------------------------------------------------------------------
	CabecCar() // Cabecalho da Impressao
	
	FOR nX := 1 TO LEN( aCorpo )
		IF nLinha > nTamVPAG
			CabecCar()// Cabecalho da Impressao
		ENDIF
		
		cLinha	:= aCorpo[nX]
		oPrn:Say(nLinha,nColIni,cLinha, oFont1)
		nLinha	+= 50
	NEXT nX	

	oPrn:SayBitmap(nLinha,nColIni,cLogoAssin,227*2,151*2)

	//-----------------------------------------------------------------------
	// Finaliza impressao
	//-----------------------------------------------------------------------
	oPrn:EndPage()         
	oPrn:Print()

RETURN


//-----------------------------------------------------------------------
/*/{Protheus.doc} CabecCar()

Imprime a carta ao fornecedor - Cabecalho

@param		Nenhum
@return		Nenhum
@author 	Fabio Cazarini
@since 		14/09/2016
@version 	1.0
@project	SuperAcao Apex-Brasil
/*/
//-----------------------------------------------------------------------
STATIC FUNCTION CabecCar()
	LOCAL nY			:= 0

	IF nPag > 0
		oPrn:EndPage()  
	ENDIF
	nPag++

	oPrn:StartPage()

	oPrn:Say(0100,nColIni,"Destinatário", oFont1)
	oPrn:Say(0100,nColIni+250,cDESTIN, oFont1)

	oPrn:Say(0150,nColIni,"Assunto", oFont1)
	oPrn:Say(0150,nColIni+250,cASSUNT, oFont1)
	
	IF nPag == 1 .AND. LEN(aAnexos) > 0
		oPrn:Say(0200,nColIni,"Anexos", oFont1)
		nLinha := 0200

		FOR nY := 1 TO LEN( aAnexos )
			cLinha	:= ALLTRIM(aAnexos[nY][2]) + ALLTRIM(aAnexos[nY][1]) 
			oPrn:Say(nLinha,nColIni+250,cLinha, oFont1)
			nLinha	+= 50
		NEXT nY
	ELSE
		nLinha := 0200	
	ENDIF
	
	oPrn:Box(nLinha+25,nColIni,nLinha+25,nTamHPAG)
	nLinha	+= 50

RETURN