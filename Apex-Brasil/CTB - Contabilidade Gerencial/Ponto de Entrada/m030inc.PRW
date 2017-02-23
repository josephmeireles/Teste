#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'

//-----------------------------------------------------------------------
/*/{Protheus.doc} M020INC()

Ponto de Entrada apos a Inclusao do Registro no Cadastro de clientes
para gerar o item contábil (CTD)

@param		Nenhum
@return		Nenhum
@author 	Fabio Cazarini / Jose Maria
@since 		02/09/2016
@version 	1.0
@project	SuperAcao Apex-Brasil
/*/
//-----------------------------------------------------------------------
USER FUNCTION M030INC()
Local _aArea 	:= GetArea()

dBSelectArea("CTD")
dBSetOrder(1)
If !dBSeek( xFilial("CTD") + "C" + SA1->(A1_COD+A1_LOJA) )
	RecLock("CTD",.T.)
	CTD->CTD_FILIAL	:= xFilial("CTD")
	CTD->CTD_ITEM	:= "C" + SA1->(A1_COD+A1_LOJA)
	CTD->CTD_DESC01	:= SA1->A1_NOME
	CTD->CTD_CLASSE	:= "2"
	CTD->CTD_DTEXIS	:= CTOD("01/01/1980")
	CTD->CTD_BLOQ	:= "2"
	CTD->CTD_ACCLVL	:= "1"
	CTD->CTD_CLOBRG	:= "2"
	MsUnLock()
Endif

RestArea( _aArea )

RETURN