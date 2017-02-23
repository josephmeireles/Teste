#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'

//-----------------------------------------------------------------------
/*/{Protheus.doc} M020INC()

Ponto de Entrada apos a Inclusao do Registro no Cadastro de Fornecedores
para gerar o item contábil (CTD)

@param		Nenhum
@return		Nenhum
@author 	Fabio Cazarini / Jose Maria
@since 		02/09/2016
@version 	1.0
@project	SuperAcao Apex-Brasil
/*/
//-----------------------------------------------------------------------
USER FUNCTION M020INC()
Local _aArea := GetArea()
Local _cNoItem	:= Supergetmv("JH_NOITEMF",.T.,"")

IF cFilAnt $ ALLTRIM(_cNoItem) .AND. !EMPTY(_cNoItem) .AND. !EMPTY(cFilAnt)
	RETURN
ENDIF

dBSelectArea("CTD")
dBSetOrder(1)
If !dBSeek( xFilial("CTD") + "F" + SA2->(A2_COD+A2_LOJA) )
	RecLock("CTD",.T.)
	CTD->CTD_FILIAL	:= xFilial("CTD")
	CTD->CTD_ITEM	:= "F" + SA2->(A2_COD+A2_LOJA)
	CTD->CTD_DESC01	:= SA2->A2_NOME
	CTD->CTD_CLASSE	:= "2"
	CTD->CTD_DTEXIS	:= CTOD("01/01/1980")
	CTD->CTD_BLOQ	:= "2"
	CTD->CTD_ACCLVL	:= "1"
	CTD->CTD_CLOBRG	:= "2"
	MsUnLock()
Endif

RestArea( _aArea )

RETURN