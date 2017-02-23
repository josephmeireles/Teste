#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'

//-----------------------------------------------------------------------
/*/{Protheus.doc} ABCADG01()

Gatilho dos campos A1_CGC e A1_EST para gerar o código do cliente, sendo:

Estrangeiro = A1_COD sequencial, A1_LOJA = '0001'
PF = A1_COD = 8 primeiros dígitos do CPF, A1_LOJA = 3 últimos dígitos
PJ = A1_COD = 8 primeiros dígitos do CNPJ, A1_LOJA = 4 últimos dígitos 

Campo: A1_COD / A1_EST
Domínio: A1_CGC
Regra: U_ABCADG01()
Condição: INCLUI.AND.FINDFUNCTION("U_ABCADG01")

@param		Nenhum
@return		M->A1_COD
@author 	Fabio Cazarini
@since 		19/09/2016
@version 	1.0
@project	SuperAcao Apex-Brasil
/*/
//-----------------------------------------------------------------------
USER FUNCTION ABCADG01()
	LOCAL lAchou	:= .T.
		
	IF M->A1_EST == "EX"
		//-----------------------------------------------------------------------
		// Se for estrangeiro, gera sequencia
		//-----------------------------------------------------------------------
		M->A1_LOJA	:= STRZERO(1, LEN(M->A1_LOJA))

		IF !EMPTY(M->A1_COD) .AND. M->A1_COD <> LEFT(M->A1_CGC, LEN(M->A1_COD))
			DbSelectArea("SA1")
			SA1->( dbSetOrder(1) )
			lAchou := SA1->(dbSeek(xFilial('SA1') + M->A1_COD + M->A1_LOJA))	
		ELSE
			lAchou := .T.
		ENDIF

		M->A1_CGC	:= SPACE( LEN(M->A1_CGC) )

		IF lAchou
			DO WHILE .T.
				M->A1_COD := GetSXENum("SA1","A1_COD")
	
				DbSelectArea("SA1")
				SA1->( dbSetOrder(1) )
				If !SA1->(dbSeek(xFilial('SA1') + M->A1_COD + M->A1_LOJA))	
					EXIT
				ELSE
					ConfirmSX8()
				ENDIF
			ENDDO
		ENDIF
	ELSE
		IF !EMPTY(M->A1_CGC)
			M->A1_COD 	:= LEFT(M->A1_CGC, LEN(M->A1_COD))
			M->A1_LOJA	:= SUBSTR(M->A1_CGC, 9, LEN(M->A1_LOJA))   
		ENDIF
	ENDIF

RETURN M->A1_COD