#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'

//-----------------------------------------------------------------------
/*/{Protheus.doc} ABCADG03()

Função de usuario para validação do campo CP_QUANT nas solicitações ao armazem 

ValidUser do campo: IIF(FINDFUNCTION("U_ABCADG03"),U_ABCADG03(), .T.)                                                                               

@param		Nenhum
@return		_lRet := .T.
@author 	luciano.camargo - TOTVS
@since 		20/02/2017
@version 	1.0
@project	SuperAcao Apex-Brasil
/*/
//-----------------------------------------------------------------------
User Function ABCADG03()

	Local	_lRet  := .T.
	Local _cCdPro  := "" // Codigo de produto
	Local _nQtPro  := 0  // Quantidade do produto
	Local _aB2Area := SB2->(GetArea())
	Local _nSalPedi, _nQatu, _nQEmpSa, _nDisp
	Local nPProduto
	Local nPQuant  

	If INCLUI .OR. ALTERA
		nPProduto := aScan(aHeader,{|x| AllTrim(x[2])=="CP_PRODUTO"})
		nPQuant   := aScan(aHeader,{|x| AllTrim(x[2])=="CP_QUANT"})

		_cCdPro  := aCols[n][nPProduto] //SCP->CP_PRODUTO 	// Codigo de produto
		_nQtPro  := aCols[n][nPQuant]   //SCP->CP_QUANT 	// Quantidade do produto

		SB2->(dBSetOrder(1), DbSeek(xFilial("SB2")+_cCdPro))
		If !SB2->(Eof())
			_nSalPedi := SB2->B2_SALPEDI 			// Saldo em pedido
			_nQatu    := SB2->B2_QATU    			// Quantidade Atual
			_nQempsa  := SB2->B2_QEMPSA  			// Quantidade Empenhada
			_nDisp    := SB2->(B2_QATU - B2_QEMPSA) // Disponível
			_cMens    := ""
			If _nDisp < _nQtPro // Quantidade disponivel menor que quantidade solicitada 
				_cMens := "Saldo disponivel é menor que a quantidade solicitada!"
			Endif
			_cMens += +Chr(13)+Chr(10)+Chr(13)+Chr(10)+	"Quantidade Disponivel: "+AllTrim(Str(_nDisp))+Chr(13)+Chr(10)+;
			"Quantidade Atual em Estoque: "+AllTrim(Str(_nQatu))+Chr(13)+Chr(10)+;
			"Quantidade Empenhada em solicitações: "+AllTrim(Str(_nQempsa))+Chr(13)+Chr(10)+;
			"Quantidade em Pedido de Compra : "+AllTrim(Str(_nSalPedi))+Chr(13)+Chr(10) 

			If _nDisp > 0
				If MsgYesNo( _cMens+Chr(13)+Chr(10)+" Deseja ajustar a quantidade solicitada, conforme a quantidade disponivel?" )
					aCols[n][nPQuant] := _nDisp
				Endif
			Else
				MsgInfo( _cMens )
			Endif
		Else
			MsgAlert("Não localizada a movimentação deste produto em [SB2]")
		Endif

	Endif

	RestArea(_aB2Area)
RETURN _lRet


// Ver possibilidade de uso do P.E. MTA105LIN - Validação da Linha