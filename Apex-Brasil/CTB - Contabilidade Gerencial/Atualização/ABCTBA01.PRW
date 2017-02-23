#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'

//-----------------------------------------------------------------------
/*/{Protheus.doc} ABCTBA01()

Leitura dos cadastros de cliente e fornecedores e polula a tabela item 
contabil (CTD)

@param		Nenhum
@return		Nenhum
@author 	Fabio Cazarini / Jose Maria
@since 		02/09/2016
@version 	1.0
@project	SuperAcao Apex-Brasil
/*/
//-----------------------------------------------------------------------
USER FUNCTION ABCTBA01()

	Local aArea		:= GetArea()
	Local nOpc     	:= 0
	Local aSay   	:= {}
	Local aButton 	:= {}    
	Local cDesc1	:= OemToAnsi('O objetivo desta rotina é gerar o item contábil a partir dos')
	Local cDesc2	:= OemToAnsi('clientes e fornecedores cadastrados.                        ')
	Local cDesc3	:= OemToAnsi('')
	Local cDesc4	:= OemToAnsi('')
	Local cDesc5	:= OemToAnsi('')
	Local cDesc6	:= OemToAnsi('')
	Local cDesc7  	:= OemToAnsi('')

	Private cCadastro 	:= OEMTOANSI("Gerar item contábil")
	Private nProcess	:= 0

	// Mensagens de Tela Inicial
	aAdd( aSay, cDesc1 )
	aAdd( aSay, cDesc2 )
	aAdd( aSay, cDesc3 )
	aAdd( aSay, cDesc4 )
	aAdd( aSay, cDesc5 )
	aAdd( aSay, cDesc6 )
	aAdd( aSay, cDesc7 )

	aAdd( aButton, { 1,.T.,{|| nOpc := 1,FechaBatch()}})
	aAdd( aButton, { 2,.T.,{|| FechaBatch() }} )

	FormBatch( cCadastro, aSay, aButton )

	If nOpc == 1	
		Processa({|| GRAVACTD() },"Processando")

		MsgInfo("Processo concluído. Foram atualizados " + ALLTRIM(STR(nProcess)) + " registros")
	ENDIF

	RestArea( aArea )

RETURN


//-----------------------------------------------------------------------
/*/{Protheus.doc} GRAVACTD()

Grava a CTD

@param		Nenhum
@return		Nenhum
@author 	Fabio Cazarini / Jose Maria
@since 		02/09/2016
@version 	1.0
@project	SuperAcao Apex-Brasil
/*/
//-----------------------------------------------------------------------
STATIC FUNCTION GRAVACTD()

	//-----------------------------------------------------------------------
	// Clientes
	//-----------------------------------------------------------------------
	dBSelectArea("SA1")
	dBSetOrder(1)

	ProcRegua(RecCount())

	dBGoTop()

	While !Eof()
		INCPROC("Processando tabela de clientes 1/2...")

		dBSelectArea("CTD")
		dBSetOrder(1)
		IF !dBSeek( xFilial("CTD") + "C" + SA1->(A1_COD+A1_LOJA) )
			nProcess++

			RecLock("CTD",.T.)
			CTD->CTD_FILIAL      := xFilial("CTD")
			CTD->CTD_ITEM        := "C" + SA1->(A1_COD+A1_LOJA)
			CTD->CTD_DESC01      := SA1->A1_NOME
			CTD->CTD_CLASSE      := "2"
			CTD->CTD_DTEXIS      := CTOD("01/01/1980")
			CTD->CTD_BLOQ        := "2"
			CTD->CTD_ACCLVL      := "1"
			CTD->CTD_CLOBRG      := "2"
			MsUnLock()
		Endif

		dBSelectArea("SA1")

		dBSkip()

	EndDo

	//-----------------------------------------------------------------------
	// Fornecedores
	//-----------------------------------------------------------------------
	dBSelectArea("SA2")
	dBSetOrder(1)

	ProcRegua(RecCount())

	dBGoTop()

	While !Eof()
		INCPROC("Processando tabela de fornecedores 2/2...")

		dBSelectArea("CTD")
		dBSetOrder(1)
		IF !dBSeek( xFilial("CTD") + "F" + SA2->(A2_COD+A2_LOJA) )
			nProcess++

			RecLock("CTD",.T.)
			CTD->CTD_FILIAL      := xFilial("CTD")
			CTD->CTD_ITEM        := "F" + SA2->(A2_COD+A2_LOJA)
			CTD->CTD_DESC01      := SA2->A2_NOME
			CTD->CTD_CLASSE      := "2"
			CTD->CTD_DTEXIS      := CTOD("01/01/1980")
			CTD->CTD_BLOQ        := "2"
			CTD->CTD_ACCLVL      := "1"
			CTD->CTD_CLOBRG      := "2"
			MsUnLock()
		Endif

		dBSelectArea("SA2")

		dBSkip()

	EndDo
        
RETURN
