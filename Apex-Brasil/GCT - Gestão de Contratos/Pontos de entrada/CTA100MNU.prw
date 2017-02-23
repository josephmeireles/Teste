#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'

//-----------------------------------------------------------------------
/*/{Protheus.doc} CTA100MNU()

Manuten��o de contratos

Descri��o:
LOCALIZA��O : Function CNTA100 - Rotina respons�vel pela Manuten��o de
Contratos.

EM QUE PONTO : Antes de montar a tela do browser.

UTILIZA��O : Para adicionar bot�es no menu principal da rotina.

Eventos
Acionar a rotina "Contratos" pelo menu do m�dulo SIGAGCT.

@param		Nenhum
@return		Nenhum
@author 	Fabio Cazarini
@since 		19/08/2016
@version 	1.0
@project	SuperAcao Apex-Brasil
/*/
//-----------------------------------------------------------------------
USER FUNCTION CTA100MNU()

	AADD(aRotina, {"Cartas ao fornecedor"	, "U_ABGCTA01()", 0, 2, 0, NIL})
	AADD(aRotina, {"Distrib. Itens"			, "U_ABGCTA02()", 0, 2, 0, NIL})

RETURN