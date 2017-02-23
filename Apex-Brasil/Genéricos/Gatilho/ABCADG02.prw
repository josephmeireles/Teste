#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'

//-----------------------------------------------------------------------
/*/{Protheus.doc} ABCADG02()

Gatilho dos campos A2_CGC e A2_EST para gerar o c�digo do fornecedor, 
sendo:

Estrangeiro = A2_COD sequencial, A2_LOJA = '0001'
PF = A2_COD = 8 primeiros d�gitos do CPF, A2_LOJA = 3 �ltimos d�gitos
PJ = A2_COD = 8 primeiros d�gitos do CNPJ, A2_LOJA = 4 �ltimos d�gitos 

Campo: A2_COD / A2_EST
Dom�nio: A2_CGC
Regra: U_ABCADG02()
Condi��o: INCLUI.AND.FINDFUNCTION("U_ABCADG02")

@param		Nenhum
@return		M->A2_COD
@author 	Fabio Cazarini
@since 		19/09/2016
@version 	1.0
@project	SuperAcao Apex-Brasil
/*/
//-----------------------------------------------------------------------
USER FUNCTION ABCADG02()
	LOCAL lAchou	:= .T.
	
	IF M->A2_EST == "EX"
		//-----------------------------------------------------------------------
		// Se for estrangeiro, gera sequencia
		//-----------------------------------------------------------------------
		M->A2_LOJA	:= STRZERO(1, LEN(M->A2_LOJA))

		IF !EMPTY(M->A2_COD) .AND. M->A2_COD <> LEFT(M->A2_CGC, LEN(M->A2_COD))
			DbSelectArea("SA2")
			SA2->( dbSetOrder(1) )
			lAchou := SA2->(dbSeek(xFilial('SA2') + M->A2_COD + M->A2_LOJA))	
		ELSE
			lAchou := .T.
		ENDIF

		M->A2_CGC	:= SPACE( LEN(M->A2_CGC) )
		M->A2_TIPO	:= "X"

		IF lAchou
			DO WHILE .T.
				M->A2_COD := GetSXENum("SA2","A2_COD")
	
				DbSelectArea("SA2")
				SA2->( dbSetOrder(1) )
				If !SA2->(dbSeek(xFilial('SA2') + M->A2_COD + M->A2_LOJA))	
					EXIT
				ELSE
					ConfirmSX8()
				ENDIF
			ENDDO
		ENDIF
	ELSE
		IF !EMPTY(M->A2_CGC)
			M->A2_COD 	:= LEFT(M->A2_CGC, LEN(M->A2_COD))
			M->A2_LOJA	:= SUBSTR(M->A2_CGC, 9, LEN(M->A2_LOJA))   
		ENDIF
	ENDIF

RETURN M->A2_COD