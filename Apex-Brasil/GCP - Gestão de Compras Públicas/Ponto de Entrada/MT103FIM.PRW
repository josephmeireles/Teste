#include 'PROTHEUS.CH'
#include "FILEIO.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} MT103FIM.prw

P.E. no final da inclusao do documento de entrada

@sample	 Nenhum		
@param	 Nenhum
@return	 Nenhum
@author	 luciano.camargo - TOTVS
@since	 08/02/2017
@version 1.0

@obs 	 Criado com base no fonte de Fabio Cazarini - TOTVS
@obs  	 Construido para gerar INSS Patronal 
/*/

user function MT103FIM()

	//------------------------------------------------------------------------------
	// Definicao das variaveis                             
	//------------------------------------------------------------------------------

	local nOpcaRot	:= ParamIxb[1]
	local nOpca		:= ParamIxb[2]
	local aArea		:= {SC7->(GetArea()),GetArea()}

	//------------------------------------------------------------------------------
	// Criticas / Validações                             
	//------------------------------------------------------------------------------

	if SF1->F1_ESPECIE == PADR("RPA", TAMSX3("F1_ESPECIE")[01]) // Entrar na rotina RPA apenas quando a especie for = RPA

		if(nOpcaRot == 3 .or. nOpcaRot == 4) .and. nOpca == 1 // inclusao ou classificacao
			GeraRPA()			// Inclusao de titulo INSS Patronal
		endif	

		if(nOpcaRot == 5 .and. nOpca == 1)// exclusao ou estorno da classificacao do doc. de entrada
			ExcluiRPA()			// Exclui titulo INSS Patronal
		endif	

	endif

	aEval(aArea,{|x| RestArea(x)})

return()

//------------------------------------------------------------------------------
/*/{Protheus.doc} GeraRPA

Inclusao de titulo INSS Patronal

@sample		GeraRPA()		
@param		Nenhum
@return		Nenhum
@author		Luciano Camargo - TOTVS
@since		08/02/2017
@version	1.0
/*/

STATIC FUNCTION GeraRPA()

	//------------------------------------------------------------------------------
	// Definicao das variaveis                             
	//------------------------------------------------------------------------------

	local _aArea    	:= GetArea()
	local _aAreaSE2 	:= SE2->(GetArea())
	local _aAreaSED 	:= SED->(GetArea())
	local _aAreaSA2     := SA2->(GetArea())
	local _cNaturez 	:= GetNewPar("AB_XNATRPA","RPA")	// Natureza
	local _cTipo		:= GetNewPar("AB_XTPRPA" ,"TXR")	// Tipo
	local _cFornece		:= GetNewPar("AB_XFORRPA","FORRPA")	// Fornecedor
	local _cLoja		:= GetNewPar("AB_XLOJRPA","00")		// Loja fornecedor
	local _cCodIns		:= GetNewPar("AB_XCODRPA","000001") // Codigo Inss
	local _nPerc		:= GetNewPar("AB_XINSRPA",20)		// Percentual INSS RPA
	local _nDias		:= GetNewPar("AB_XDIARPA",10)		// Numero de dias apos a emissao para vencimento
	local _dVencto		:= SE2->E2_EMISSAO + _nDias			// Vencimento.
	local _aGrvSE2  	:= {}
	local cPrefixo		:= IIf(Empty(SF1->F1_PREFIXO),&(SuperGetMV("MV_2DUPREF")),SF1->F1_PREFIXO)
	local lAchouSE2		:= .F.

	private lMsErroAuto 	:= .F.

	//------------------------------------------------------------------------------
	// Criticas / Validações                             
	//------------------------------------------------------------------------------

	if _nPerc <= 0
		ApMsgStop("Por favor informe o percentual INSS RPA - Parametro AB_XINSRPA, queira corrigir","Corrigir")
		return
	endif

	cPrefixo := PadR( cPrefixo, Len( SE2->E2_PREFIXO ) )

	SA2->(dbSetOrder(1))
	if !SA2->(DBSeek(XFilial("SA2")+_cFornece+_cLoja)) // Verificar existencia, do cadastro do fornecedor RPA
	   ApMsgStop("Não foi localizado o cadastro do fornecedor codigo: "+_cFornece+" loja:"+_cLoja+", favor cadastrar" ,"Cadastrar")
	   RestArea(_aAreaSA2)
	   return
	endif

	lAchouSE2 := .F.
	SE2->(dbSetOrder(6)) // E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
	if SE2->(DBSeek( SF1->F1_FILIAL+SF1->F1_FORNECE+SF1->F1_LOJA+cPrefixo+SF1->F1_DOC ))
		do while SE2->(E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM) == (SF1->F1_FILIAL+SF1->F1_FORNECE+SF1->F1_LOJA+cPrefixo+SF1->F1_DOC)
			if SE2->E2_TIPO = MVNOTAFIS
				lAchouSE2 := .T.	
				EXIT	
			endif
			SE2-(DbSkip())	
		enddo
	endif

	if !lAchouSE2
		RestArea(_aAreaSE2)
		return
	endif

	if SE2->E2_DESDOBR == "S"
		ApMsgStop("Titulo do tipo RPA, não pode utilizar desdobramento igual a Sim, queira corrigir","Corrigir")
		return
	endif

	_nInss := SE2->E2_INSS

	SED->(dbSetOrder(1)) // localizar a natureza financeira
	if SED->(dbSeek(XFilial("SED")+SE2->E2_NATUREZ)) .and. SED->(FieldPos("ED_DEDINSS")) > 0
		if SED->ED_DEDINSS == "2"  //Nao desconta o INSS do principal
			_nInss := 0
		endif
	endif

	SA2->(dbSetOrder(1)) // localizar o fornecedor do titulo
	SA2->(dbSeek(XFilial("SA2")+SE2->(E2_FORNECE+E2_LOJA)))

	//Controla o Pis Cofins e Csll na baixa
	lPCCBaixa := SuperGetMv("MV_BX10925",.T.,"2") == "1"  .and. (!Empty( SE5->( FieldPos( "E5_VRETPIS" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_VRETCOF" ) ) ) .And. ;
	!Empty( SE5->( FieldPos( "E5_VRETCSL" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_PRETPIS" ) ) ) .And. ;
	!Empty( SE5->( FieldPos( "E5_PRETCOF" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_PRETCSL" ) ) ) .And. ;
	!Empty( SE2->( FieldPos( "E2_SEQBX"   ) ) ) .And. !Empty( SFQ->( FieldPos( "FQ_SEQDES"  ) ) ) )

	// Controla IRPF na Baixa
	lIRPFBaixa := IIf( ! Empty( SA2->( FieldPos( "A2_CALCIRF" ) ) ), SA2->A2_CALCIRF == "2", .F.) .And. ;
	!Empty( SE2->( FieldPos( "E2_VRETIRF" ) ) ) .And. !Empty( SE2->( FieldPos( "E2_PRETIRF" ) ) ) .And. ;
	!Empty( SE5->( FieldPos( "E5_VRETIRF" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_PRETIRF" ) ) )

	lCalcIssBx := !Empty( SE5->( FieldPos( "E5_VRETISS" ) ) ) .and. !Empty( SE2->( FieldPos( "E2_SEQBX"   ) ) ) .and. ;
	!Empty( SE2->( FieldPos( "E2_TRETISS" ) ) ) .and. GetNewPar("MV_MRETISS","1") == "2"  //Retencao do ISS pela emissao (1) ou baixa (2)

	_nValor := SE2->E2_VALOR+If(lIRPFBaixa,0,SE2->E2_IRRF)+If(!lCalcIssBx,SE2->E2_ISS,0)+_nInss+SE2->(E2_RETENC+E2_SEST)+IIF(lPccBaixa,0,SE2->(E2_PIS+E2_COFINS+E2_CSLL))
	_nValor	:= _nValor * (_nPerc/100)

	Aadd(_aGrvSE2,	{ "E2_FILIAL" 	, xFilial("SE2")  					, Nil })
	Aadd(_aGrvSE2, 	{ "E2_PREFIXO"	, "RPA"	    		 				, Nil })
	Aadd(_aGrvSE2, 	{ "E2_PREFIXO"	, SE2->E2_PREFIXO	    		 	, Nil })
	Aadd(_aGrvSE2, 	{ "E2_NUM"		, SE2->E2_NUM	    			 	, Nil })
	Aadd(_aGrvSE2, 	{ "E2_PARCELA"	, SE2->E2_PARCELA				 	, Nil })
	Aadd(_aGrvSE2, 	{ "E2_TIPO"		, IIF("-"$_cTipo,"TX",_cTipo)		, Nil })
	Aadd(_aGrvSE2,	{ "E2_NATUREZ"	, _cNaturez 				 		, Nil })
	Aadd(_aGrvSE2, 	{ "E2_PORTADO"	, ""						 		, Nil })
	Aadd(_aGrvSE2, 	{ "E2_FORNECE"	, _cFornece					 		, Nil })
	Aadd(_aGrvSE2, 	{ "E2_LOJA"   	, _cLoja					 		, Nil })
	Aadd(_aGrvSE2, 	{ "E2_EMISSAO"	, dDataBase					 		, Nil })
	Aadd(_aGrvSE2, 	{ "E2_VENCTO"	, _dVencto 					 		, Nil })
	Aadd(_aGrvSE2, 	{ "E2_VENCREA"	, DataValida(_dVencto) 	     		, Nil })
	Aadd(_aGrvSE2, 	{ "E2_VALOR"  	, _nValor					 		, Nil })
	Aadd(_aGrvSE2, 	{ "E2_SALDO"  	, _nValor					 		, Nil })
	Aadd(_aGrvSE2, 	{ "E2_EMIS1"  	, dDataBase 				 		, Nil })
	Aadd(_aGrvSE2, 	{ "E2_MOEDA"	, SE2->E2_MOEDA  				 	, Nil })
	Aadd(_aGrvSE2, 	{ "E2_VLCRUZ" 	, _nValor   				 		, Nil })
	Aadd(_aGrvSE2, 	{ "E2_CODINS"	, _cCodIns  				 		, Nil })
	Aadd(_aGrvSE2, 	{ "E2_CCD"		, SE2->E2_CCD  				 		, Nil })
	Aadd(_aGrvSE2, 	{ "E2_ITEMD"	, SE2->E2_ITEMD  				 	, Nil })
	Aadd(_aGrvSE2, 	{ "E2_CLVLDB"	, SE2->E2_CLVLDB  			 		, Nil })
	Aadd(_aGrvSE2, 	{ "E2_CONTAD"	, SE2->E2_CONTAD  			 		, Nil })
	Aadd(_aGrvSE2, 	{ "E2_CCUSTO"	, SE2->E2_CCUSTO  			 		, Nil })

	if SE2->(FIELDPOS("E2_EC05DB")) > 0
		Aadd(_aGrvSE2, 	{ "E2_EC05DB"		, SE2->E2_EC05DB  			 		, Nil })
	endif
	if SE2->(FIELDPOS("E2_EC06DB")) > 0
		Aadd(_aGrvSE2, 	{ "E2_EC06DB"		, SE2->E2_EC06DB  			 		, Nil })
	endif
	if SE2->(FIELDPOS("E2_EC07DB")) > 0
		Aadd(_aGrvSE2, 	{ "E2_EC07DB"		, SE2->E2_EC07DB  			 		, Nil })
	endif
	if SE2->(FIELDPOS("E2_EC08DB")) > 0
		Aadd(_aGrvSE2, 	{ "E2_EC08DB"		, SE2->E2_EC08DB  			 		, Nil })
	endif
	if SE2->(FIELDPOS("E2_EC09DB")) > 0
		Aadd(_aGrvSE2, 	{ "E2_EC09DB"		, SE2->E2_EC09DB  			 		, Nil })
	endif
	if SE2->(FIELDPOS("E2_XIDRPA")) > 0
		Aadd(_aGrvSE2,	{ "E2_XIDRPA"	,&("SE2->("+SE2->(IndexKey(1))+")") , Nil})
	endif

	// Ordenar um vetor conforme o dicionário para uso em rotinas de MSExecAuto
	_aGrvSE2	:= FWVetByDic( _aGrvSE2, 'SE2' )

	Begin Transaction

		MsExecAuto({ | a,b,c | Fina050(a,b,c) },_aGrvSE2,,3)

		if lMsErroAuto
			if (__lSX8)
				RollBackSX8()
			endif
			MostraErro()
			DisarmTransaction()
			Break
		Else
			if (__lSX8)
				ConfirmSX8()
			endif
		endif

	End Transaction

	RestArea(_aAreaSE2)
	RestArea(_aAreaSED)
	RestArea(_aAreaSA2)
	RestArea(_aArea)

return

//------------------------------------------------------------------------------
/*/{Protheus.doc} ExcluiRPA

Exclusao de titulo INSS Patronal

@sample		ExcluiRPA()		
@param		Nenhum
@return		Nenhum
@author		Luciano Camargo - TOTVS
@since		08/02/2017
@version	1.0
/*/

STATIC FUNCTION ExcluiRPA()

	//------------------------------------------------------------------------------
	// Definicao das variaveis                             
	//------------------------------------------------------------------------------

	local aAreaSE2	:= SE2->( GetArea() )
	local _cFornece	:= GetNewPar("AB_XFORRPA","FORRPA")	// Fornecedor
	local _cLoja	:= GetNewPar("AB_XLOJRPA","00")		// Loja fornecedor
	local _cTipo	:= GetNewPar("AB_XTPRPA","TXR")		// Tipo
	local cPrefixo	:= IIf(Empty(SF1->F1_PREFIXO),&(SuperGetMV("MV_2DUPREF")),SF1->F1_PREFIXO)
	local cQuery	:= ""
	local lRetErr	:= .F. 

	cPrefixo := PadR( cPrefixo, Len( SE2->E2_PREFIXO ) )

	// localiza o titulo de inss patronal
	cQuery    := "SELECT SE2.E2_VALOR, SE2.R_E_C_N_O_ SE2RECNO "
	cQuery    += "FROM "+RetSqlName("SE2")+" SE2 "
	cQuery    += "WHERE SE2.E2_FILIAL  = '" + xFilial("SE2") + "'"
	cQuery    += "	AND SE2.E2_FORNECE = '" + _cFornece + "'"
	cQuery    += "	AND SE2.E2_LOJA    = '" + _cLoja + "'"
	cQuery    += "	AND SE2.E2_PREFIXO = '" + cPrefixo + "'"
	cQuery    += "	AND SE2.E2_NUM     = '" + SF1->F1_DUPL + "'"
	cQuery    += "	AND SE2.E2_TIPO    = '" + IIF("-"$_cTipo,"TX",_cTipo) + "'"
	cQuery    += "	AND SE2.D_E_L_E_T_ = ' ' "

	if Select("TRBSE2") > 0
		TRBSE2->( DbCloseArea() )
	endif	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBSE2",.T.,.T.)

	//BeginTran()
	DbSelectArea("TRBSE2")
	DbGoTop()
	do while !TRBSE2->( EOF() )
		DbSelectArea("SE2")
		SE2->( DbGoTo( TRBSE2->SE2RECNO ) )

		// Exclui título posicionado
		lRetErr := ExclSE2()
		if lRetErr
			EXIT
		endif

		DbSelectArea("TRBSE2")
		TRBSE2->( DbSkip() )
	enddo
	TRBSE2->( DbCloseArea() )

	RestArea(aAreaSE2)

return


//------------------------------------------------------------------------------
/*/{Protheus.doc} ExclSE2

FATURAMENTO DIRETO - Exclui título provisório ou de INSS Patronal (posicionado)

@sample		ExclSE2()		
@param		Nenhum
@return		lMsErroAuto 	= Se ocorreu erro no ExecAuto
@author		Luciano Camargo - TOTVS
@since		08/02/2017
@version	1.0
/*/

STATIC FUNCTION ExclSE2()

	//------------------------------------------------------------------------------
	// Definicao das variaveis                             
	//------------------------------------------------------------------------------

	local aDadosSE2	:= {}
	local lRetErr	:= .F.
	local nOPC		:= 5

	local cCRLF		:= CHR(13) + CHR(10)
	local aErros	:= {}   
	local nY 		:= 0
	local cErros	:= ""

	private lMsErroAuto 	:= .F.	// variável que define que o help deve ser gravado no arquivo de log e que as informações estão vindo à partir da rotina automática.
	private lMsHelpAuto		:= .T.	// força a gravação das informações de erro em array para manipulação da gravação ao invés de gravar direto no arquivo temporário
	private lAutoErrNoFile	:= .T.

	aAdd( aDadosSE2, { "E2_FILIAL"	, SE2->E2_FILIAL						, NIL } )
	aAdd( aDadosSE2, { "E2_PREFIXO"	, SE2->E2_PREFIXO						, NIL } )
	aAdd( aDadosSE2, { "E2_NUM"		, SE2->E2_NUM							, NIL } )
	aAdd( aDadosSE2, { "E2_PARCELA"	, SE2->E2_PARCELA						, NIL } )
	aAdd( aDadosSE2, { "E2_TIPO" 	, SE2->E2_TIPO							, NIL } )
	aAdd( aDadosSE2, { "E2_FORNECE"	, SE2->E2_FORNECE						, NIL } )
	aAdd( aDadosSE2, { "E2_LOJA"	, SE2->E2_LOJA							, NIL } )
	aAdd( aDadosSE2, { "E2_EMISSAO"	, SE2->E2_EMISSAO 						, NIL } )
	aAdd( aDadosSE2, { "E2_VENCTO"	, SE2->E2_VENCTO						, NIL } )
	aAdd( aDadosSE2, { "E2_VALOR"	, SE2->E2_VALOR							, NIL } )

	// Ordenar um vetor conforme o dicionário para uso em rotinas de MSExecAuto³
	aDadosSE2	:= FWVetByDic( aDadosSE2, 'SE2' )

	DbSelectArea("SE2")
	lMsErroAuto := .F.
	MSExecAuto(	{ |a,b,c| FINA050(a,b,c) } , aDadosSE2,, nOPC)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão

	if lMsErroAuto
		aErros := GetAutoGRLog()   
		for nY := 1 TO Len(aErros)
			cErros	+= aErros[nY] + cCRLF
		next   	

		// tratamento para não mostrar o erro abaixo pois nao é impeditivo para excluir o titulo
		if!("ser novamente amarrado a um projeto pois foi originado de uma nota fiscal" $ cErros)
			ApMsgStop( cErros, "MT103FIM" )
			lRetErr := .T.
		endif	
	endif

return lRetErr