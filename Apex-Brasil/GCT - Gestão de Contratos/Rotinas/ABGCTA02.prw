#INCLUDE 'TOTVS.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
//-----------------------------------------------------------------------
/*/{Protheus.doc} ABGCTA02()

Contrato Misto - Criar rotina de modificação das planilhas do contrato
após a integração com o módulo de Gestão de Compras Públicas.

Recursos:
- Modificar as Planilhas do Contrato após esta ser criada pela rotina de
  Gestão de Compras Públicas.

@param		Nenhum
@return		Nenhum
@author 	Klaus Schneider Peres
@since 		11/11/2016
@version 	1.0
@project	SuperAcao Apex-Brasil
/*/
//-----------------------------------------------------------------------
USER FUNCTION ABGCTA02()
Local cQry			:= ""
Local nX			:= 0
Local aHeaderEx		:= {}
Local aColsEx		:= {}
Local cAlias1		:= GetNextAlias()
Local cEol			:= Chr(13) + Chr(10)
Local aFields		:= {"CNB_NUMERO","CNB_ITEM","CNB_PRODUT","CNB_DESCRI","CNB_CONTA","CNB_CC","CNB_ITEMCT","CNB_CLVL","CNB_EC05DB","CNB_EC06DB","CNB_XNUMPL","CNB_XTIPOP","CNB_XTPDES"}
Local cCampos		:= "CNB_NUMERO|CNB_ITEM|CNB_PRODUT|CNB_CONTA|CNB_CC|CNB_CLVL|CNB_ITEMCT|CNB_EC05DB|CNB_EC06DB|CNB_DESCRI|CNB_XNUMPL|CNB_XTIPOP|CNB_XTPDES"
Local aAlterFields	:= {"CNB_XNUMPL","CNB_XTIPOP"}
Local aVirtual		:= {}
Local nPosVirtual	:= 0
Private oDlg
Private oMSNewGe1
Private aColsPos	:= {}

	// Verificar com o Flávio se existe a necessidade de validar se o contrato veio de uma integração com o Módulo de Gestão de Compras Públicas
	// ????????????????????????????????

	// Verifica se o Contrato está em Elaboração - Somente nesse Status que as Planilhas poderão sofrer alguma alteração
	if CN9->CN9_SITUAC <> "02" // Em Elaboração
		MsgStop("Essa rotina só poderá ser utilizada enquanto o contrato estiver em Elaboração. Operação não permitida!!!","A T E N Ç Ã O !!!")
		Return
	endif

	// Verifica se a rotina poderá ser executada
	cQry += "SELECT DISTINCT 1 FOUND"							// Verifica se existe Cronograma Financeiro
	cQry += "  FROM " + RetSqlName("CNF") + " CNF"
	cQry += " WHERE CNF.CNF_FILIAL = '" + CN9->CN9_FILIAL + "'"
	cQry += "   AND CNF.CNF_NUMERO = '" + CN9->CN9_NUMERO + "'"
	cQry += "   AND CNF.CNF_REVISA = '" + CN9->CN9_REVISA + "'"
	cQry += "   AND CNF.D_E_L_E_T_ = ' '"
	cQry += "  UNION "
	cQry += "SELECT DISTINCT 1 FOUND"							// Verifica se existe Cronograma Físico
	cQry += "  FROM " + RetSqlName("CNS") + " CNS"
	cQry += " WHERE CNS.CNS_FILIAL = '" + CN9->CN9_FILIAL + "'"
	cQry += "   AND CNS.CNS_CONTRA = '" + CN9->CN9_NUMERO + "'"
	cQry += "   AND CNS.CNS_REVISA = '" + CN9->CN9_REVISA + "'"
	cQry += "   AND CNS.D_E_L_E_T_ = ' '"
	cQry += " UNION "
	cQry += "SELECT DISTINCT 1 FOUND"							// Verifica se existe Cronograma Contabil
	cQry += "  FROM " + RetSqlName("CNV") + " CNV"
	cQry += " WHERE CNV.CNV_FILIAL = '" + CN9->CN9_FILIAL + "'"
	cQry += "   AND CNV.CNV_NUMERO = '" + CN9->CN9_NUMERO + "'"
	cQry += "   AND CNV.CNV_REVISA = '" + CN9->CN9_REVISA + "'"
	cQry += "   AND CNV.D_E_L_E_T_ = ' '"
	cQry += " UNION "
	cQry += "SELECT DISTINCT 1 FOUND"							// Verifica se existe Rateio Contábil por Item
	cQry += "  FROM " + RetSqlName("CNZ") + " CNZ"
	cQry += " WHERE CNZ.CNZ_FILIAL = '" + CN9->CN9_FILIAL + "'"
	cQry += "   AND CNZ.CNZ_CONTRA = '" + CN9->CN9_NUMERO + "'"
	cQry += "   AND CNZ.CNZ_REVISA = '" + CN9->CN9_REVISA + "'"
	cQry += "   AND CNZ.D_E_L_E_T_ = ' '"
	TCQUERY ChangeQuery(cQry) New Alias (cAlias1)
	if !(cAlias1)->(Eof())
		cTexto := "Essa rotina não poderá ser executada porque esse contrato já possui um ou mais dos itens a seguir cadastrados: " + cEol + cEol
		cTexto += "   - Rateio Contábil por Item" + cEol
		cTexto += "   - Cronograma Financeiro" + cEol
		cTexto += "   - Cronograma Físico" + cEol
		cTexto += "   - Cronograma Contábil" + cEol + cEol
		cTexto += "Para conseguir utilizar essa rotina, altere o contrato e exclua as informações de todas as tabelas acima citadas!!!"
		MsgStop(cTexto,'A T E N Ç Ã O !!!')
		(cAlias1)->(DbCloseArea())
		Return
	endif
	(cAlias1)->(DbCloseArea())

	// Cria a Tela de Interface com o usuário
	DbSelectArea("SX3")
	SX3->(DbSetOrder(1))

	// Inclui os campos do Dicionário de Dados da Tabela CNB no aHeader
	SX3->(DbSeek("CNB"))
	While !SX3->(Eof()) .And. SX3->X3_ARQUIVO == "CNB"
		If Alltrim(SX3->X3_CAMPO) $ cCampos .and. !AllTrim(SX3->X3_CAMPO) == "CNB_DESC"
			// Monta o Bloco de Código de Validação do Campo
			bBloco := "{ || " + SX3->X3_VALID + "}"

			Aadd(aHeaderEx,{	AllTrim(X3TITULO())			,;	// [01] - Titulo
								SX3->X3_CAMPO				,;	// [02] - Campo
								SX3->X3_PICTURE				,;	// [03] - Picture
								SX3->X3_TAMANHO				,;	// [04] - Tamanho
								SX3->X3_DECIMAL				,;	// [05] - Decimal
								SX3->X3_VALID				,;	// [06] - Valid
								""							,;	// [07] - nao alteravel
								SX3->X3_TIPO				,;	// [08] - Tipo
								""							,;	// [09] - nao alteravel
								""							})	// [10] - nao alteravel
			if SX3->X3_CONTEXT == 'V'
				aAdd(aVirtual,AllTrim(SX3->X3_CAMPO))
			endif
		EndIf
		SX3->(DbSkip())
	End

	// Alimenta o aCols com o Conteúdo das planilhas cadastradas
	DbSelectArea("CNB")
	CNB->(DbSetOrder(1)) // FILIAL + CONTRATO + REVISA + NUMERO + ITEM
	if CNB->(DbSeek(CN9->(CN9_FILIAL + CN9_NUMERO + CN9_REVISA)))
		While ! CNB->(Eof()) .AND. CNB->(CNB_FILIAL + CNB_CONTRA + CNB_REVISA) == CN9->(CN9_FILIAL + CN9_NUMERO + CN9_REVISA)
			aTmpCols := {}
			For nX := 1 to Len(aHeaderEx) // Inclui os campos na Ordem do Cabeçalho
				nPosVirtual := aScan(aVirtual, {|x| x == AllTrim(aHeaderEx[nX][02]) })
				if nPosVirtual == 0 // Se for campo Virtual, inicia-o com conteúdo vazio
					aAdd(aTmpCols, &(aHeaderEx[nX][02]) ) // Traz o conteúdo
				else
					aAdd(aTmpCols, CriaVar(aVirtual[nPosVirtual]) ) // Traz o conteúdo
				endif
			Next nX
			aAdd(aTmpCols, .F. )

			// Inclui a Linha no Array principal
			aAdd(aColsEx, aTmpCols)
			aAdd(aColsPos,CNB->(Recno())) // Será utilizado na efetivação da alteração

			// Pula para o próximo campo
			CNB->(DbSkip())
		end
	else
		MsgStop("Não foram encontradas Planilhas / Produtos para esse Contrato. Favor verificar!!!","A T E N Ç Ã O !!!")
		Return
	endif

	DEFINE MSDIALOG oDlg TITLE "Contrato Misto - Alteração de Planilha - CTR: " + CN9->CN9_NUMERO FROM 000, 000  TO 300, 905 COLORS 0, 16777215 PIXEL
		oMSNewGe1 := MsNewGetDados():New(001,001,136,454,GD_UPDATE,,,,aAlterFields,,999,,,,oDlg,aHeaderEx,aColsEx)
		DEFINE SBUTTON oSButton1 FROM 137,400 TYPE 01 OF oDlg ENABLE ACTION ( ABGCTA02B() )
		DEFINE SBUTTON oSButton2 FROM 137,427 TYPE 02 OF oDlg ENABLE ACTION ( oDlg:End() )
	ACTIVATE MSDIALOG oDlg CENTERED

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} ABGCTA02B()

Validação no botão OK da tela de Contrato Misto

@param		Nenhum
@return		Nenhum
@author 	Klaus Schneider Peres
@since 		16/11/2016
@version 	1.0
@project	SuperAcao Apex-Brasil
/*/
//-----------------------------------------------------------------------
STATIC FUNCTION ABGCTA02B()
Local nX			:= 0
Local nPosNewPla	:= aScan(oMSNewGe1:aHeader, { |x| Trim(x[2]) == "CNB_XNUMPL"} )
Local nPosNewTip	:= aScan(oMSNewGe1:aHeader, { |x| Trim(x[2]) == "CNB_XTIPOP"} )
Local lCheckPlan	:= .T.
Local lCheckCodP	:= .F.
Local lControl		:= .F.
Private aTamaCols	:= Array(Len(oMSNewGe1:aCols))
Private aTipaCols	:= Array(Len(oMSNewGe1:aCols))

	// Efetua validações da rotina
	For nX := 1 to Len(oMSNewGe1:aCols)
		// Verifica preenchimento dos campos para saber se todos os campos foram informados
		if Empty(oMSNewGe1:aCols[nX][nPosNewPla]) .or. Empty(oMSNewGe1:aCols[nX][nPosNewTip])
			MsgStop("Todos os campos são obrigatórios!!!","A T E N Ç Ã O !!!")
			Return
		endif

		// Verifica se para uma mesma planilha foi informado tipos diferentes (isso não poderá ocorrer)
		aEval(oMSNewGe1:aCols, { |x| if(x[nPosNewPla]==oMSNewGe1:aCols[nX][nPosNewPla] .and. x[nPosNewTip]<>oMSNewGe1:aCols[nX][nPosNewTip] , lCheckPlan := .F. ,) } )

		// Verifica se ficou faltando alguma planilha no meio. Ex: Foram digitados os seguintes códigos para novas planilhas: 000001, 000003 e 000004
		// Para o caso acima deveriam ser digitadas as seguintes planilhas: 000001, 000002 e 000003
		aTamaCols[Val(oMSNewGe1:aCols[nX][nPosNewPla])] := oMSNewGe1:aCols[nX][nPosNewPla]	// Planilha
		aTipaCols[Val(oMSNewGe1:aCols[nX][nPosNewPla])] := oMSNewGe1:aCols[nX][nPosNewTip]	// Tipo
	Next nX

	// Mostra a mensagem de Tipos diferentes para uma mesma planilha
	if !lCheckPlan
		MsgStop("Para uma mesma planilha, deverá ser informado o mesmo tipo. Favor revisar as informações digitadas!!!","A T E N Ç Ã O !!!")
		Return
	endif

	// Verifica se existe a planilha 000001, pois ela deverá existir
	aEval(oMSNewGe1:aCols, { |x| if(x[nPosNewPla] == StrZero(1,Len(oMSNewGe1:aCols[01][nPosNewPla])) , lCheckCodP := .T. , ) })
	if !lCheckCodP
		MsgStop("Deverá existir a planilha de número 000001. Favor revisar as informações digitadas!!!", "A T E N Ç Ã O !!!")
		Return
	endif

	// Mostra a mensagem do lacuna nos códigos das planilhas digitadas
	For nX := Len(aTamaCols) to 01 Step -1
		if !lControl
			if !aTamaCols[nX] == Nil
				lControl := .T.
			endif
		else
			if aTamaCols[nX] == Nil
				MsgStop("Não poderá existir lacunas entre os códigos das planilhas. Favor revisar as informações digitadas!!!","A T E N Ç Ã O !!!")
				Return
			endif
		endif
	Next nX

	// Se estiver tudo preenchido efetua o processamento e encerra a rotina
	if MsgNoYes("Confirma a alteração das planilhas do contrato ( Nao | Sim )?","A T E N Ç Ã O !!!")
		// Processa a Alteração das Planilhas
		ABGCTA02D()
		MsgInfo("Rotina concluída com sucesso!!!","A T E N Ç Ã O !!!")

		// Fecha a tela de interface com o usuário
		oDlg:End()
	else
		if !MsgYesNo("Rotina cancelada pelo usuário, nenhuma ação foi realizada. Deseja continuar editando ( Sim | Não )?","A T E N Ç Ã O !!!")
			// Fecha a tela de interface com o usuário
			oDlg:End()
		endif
	endif

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} ABGCTA02C()

Validação do campo personalizado CNB_XNUMPL(Usado no X3_RELACAO do campo)

@param		Nenhum
@return		T ou F
@author 	Klaus Schneider Peres
@since 		16/11/2016
@version 	1.0
@project	SuperAcao Apex-Brasil
/*/
//-----------------------------------------------------------------------
STATIC FUNCTION ABGCTA02C()
Local lRet			:= .T.

	// Se o usuário digitou menos caracteres do que comporta o campo, complementa com zeros à esquerda
	M->CNB_XNUMPL := StrZero(Val(M->CNB_XNUMPL),Len(M->CNB_XNUMPL))

	// Verifica se o valor digitado é maior que a quantidade de registros no Array
	// Só poderá ser digitado no campo de numero de contrato limitado à quantidade de Itens (Produtos)
	if Val(M->CNB_XNUMPL) > Len(oMSNewGe1:aCols)
		MsgStop("Não poderá ser informada uma planilha de número maior do que o total de itens (produtos). Favor revisar a informação digitada!!!","A T E N Ç Ã O !!!")
		lRet := .F.
	endif

Return(lRet)


//-----------------------------------------------------------------------
/*/{Protheus.doc} ABGCTA02D()

Processamento da Alteração das Planilhas conforme digitado pelo usuário

@param		Nenhum
@return		Nenhum
@author 	Klaus Schneider Peres
@since 		16/11/2016
@version 	1.0
@project	SuperAcao Apex-Brasil
/*/
//-----------------------------------------------------------------------
STATIC FUNCTION ABGCTA02D()
Local nX			:= 0
Local nY			:= 0
Local cQry			:= ""
Local cAlias1		:= GetNextAlias()
Local aEstrutura	:= {}
Local aDados		:= {}
Local cAnterior		:= ""
Local cCount		:= ""
Local nPosOldPla	:= aScan(oMSNewGe1:aHeader, { |x| Trim(x[2]) == "CNB_NUMERO"} )
Local nPosNewPla	:= aScan(oMSNewGe1:aHeader, { |x| Trim(x[2]) == "CNB_XNUMPL"} )
Local nPosOldIte	:= aScan(oMSNewGe1:aHeader, { |x| Trim(x[2]) == "CNB_ITEM"} )
Local nPosNewTip	:= aScan(oMSNewGe1:aHeader, { |x| Trim(x[2]) == "CNB_XTIPOP"} )

	Begin Transaction

	// Seleciona a Tabela de Planilhas
	DbSelectArea("CNA")
	CNA->(DbSetOrder(1)) // FILIAL + CONTRATO + REVISAO + NUMERO

	// Seleciona a Tabela de Itens das Planilhas
	DbSelectArea("CNB")
	CNB->(DbSetOrder(1)) // FILIAL + CONTRATO + REVISAO + NUMERO + ITEM

	// Efetua um Backup dos dados da planilha principal 000001
	cQry := "SELECT *"
	cQry += "  FROM " + RetSqlName("CNA")
	cQry += " WHERE CNA_FILIAL = '" + CN9->CN9_FILIAL + "'"
	cQry += "   AND CNA_CONTRA = '" + CN9->CN9_NUMERO + "'"
	cQry += "   AND CNA_REVISA = '" + CN9->CN9_REVISA + "'"
	cQry += "   AND D_E_L_E_T_ = ' '"
	cQry += " ORDER BY CNA_FILIAL, CNA_CONTRA, CNA_REVISA, CNA_NUMERO"
	TCQUERY ChangeQuery(cQry) New Alias (cAlias1)
	TCSetField(cAlias1, "CNA_DTINI", "D")
	TCSetField(cAlias1, "CNA_DTFIM", "D")
	TCSetField(cAlias1, "CNA_DTMXMD","D")

	if ! (cAlias1)->(Eof())
		// Captura a Estrutura da Tabela de Planilhas
		aEstrutura := DbStruct()

		// Retira campos indesejados da estrutura
		aDel( aEstrutura,aScan(aEstrutura, { |x| x[01] == "R_E_C_N_O_" } ) )
		aDel( aEstrutura,aScan(aEstrutura, { |x| x[01] == "R_E_C_D_E_L_" } ) )
		aSize(aEstrutura,Len(aEstrutura)-2)

		// Posiciona no primeiro registro da Tabela de Planilhas
		CNA->(DbGoTo((cAlias1)->R_E_C_N_O_))

		// Armazena os Dados da Planilha principal em um Array para uso posterior
		For nX := 1 to Len(aEstrutura)
			aAdd(aDados, &( "CNA->" + aEstrutura[nX][01] ) )
		Next nX

		// Exclui todas as Planilhas do Contrato
		While !(cAlias1)->(Eof())
			CNA->(DbGoTo((cAlias1)->R_E_C_N_O_))
			RecLock("CNA",.F.)
				CNA->(DbDelete())
			CNA->(MsUnLock())
			(cAlias1)->(DbSkip())
		end

		// Exclui todos os registros da tabela CPD
		DbSelectArea("CPD")
		CPD->(DbSetOrder(1))
		CPD->(DbSeek(CN9->CN9_FILIAL + CN9->CN9_NUMERO))
		While !CPD->(Eof()) .and. CPD->(CPD_FILIAL + CPD_CONTRA) == CN9->(CN9_FILIAL + CN9_NUMERO)
			RecLock("CPD",.F.)
				CPD->(DbDelete())
			CPD->(MsUnLock())
			CPD->(DbSkip())
		End

		// Retorna ao início da Tabela Temporária
		(cAlias1)->(DbGoTop())

		// Efetua a gravação das novas informações digitadas pelo usuário após todas as verificações já realizadas anteriormente
		For nX := 1 to Len(aTamaCols)

			// Grava a Tabela CNA (Planilhas)
			if aTamaCols[nX] <> Nil
				RecLock("CNA",.T.)
					For nY := 01 to Len(aEstrutura)
						if ! AllTrim(aEstrutura[nY][01]) $ "CNA_NUMERO|CNA_TIPPLA|CNA_VLTOT|CNA_SALDO"
							&( "CNA->" + AllTrim(aEstrutura[nY][01]) ) := aDados[nY]
						else
							if AllTrim(aEstrutura[nY][01]) == "CNA_NUMERO"
								&("CNA->" + AllTrim(aEstrutura[nY][01])) := aTamaCols[nX]
							elseif AllTrim(aEstrutura[nY][01]) == "CNA_TIPPLA"
								&("CNA->" + AllTrim(aEstrutura[nY][01])) := aTipaCols[nX]
							endif
						endif
					Next nY
				CNA->(MsUnLock())
			endif

			// Grava a Tabela CPD (Amarração Contrato x Filiais)
			RecLock("CPD",.T.)
				CPD->CPD_FILIAL	:= CN9->CN9_FILIAL
				CPD->CPD_CONTRA	:= CN9->CN9_NUMERO
				CPD->CPD_NUMPLA	:= aTamaCols[nX]
				CPD->CPD_FILAUT	:= CN9->CN9_FILIAL
			CPD->(MsUnLock())

		Next nX

	endif
	(cAlias1)->(DbCloseArea())

	// Altera o Código do Item para não dar problema de Registro Duplicado (Problema acontecia depois da primeira Alteração de Planilha)
	For nX := 1 to Len(aColsPos)
		CNB->(DbGoTo(aColsPos[nX]))
		RecLock("CNB",.F.)
			CNB->CNB_ITEM := StrZero(Len(aColsPos)+nX, Len(CriaVar("CNB_ITEM")))
		CNB->(MsUnLock())
	Next nX

	// Altera as informações de cada item conforme novas informações digitadas pelo usuário
	cCount := "001"
	For nX := 1 to Len(oMSNewGe1:aCols)
		// Adquire o próximo número sequencial para não dar problema de Registro duplicado
		cCount := Soma1(cCount,Len(CriaVar("CNB_ITEM")))

		// Posiciona no registro da tabela CNB (Itens da Planilha)
//		CNB->(DbSeek( CN9->(CN9_FILIAL + CN9_NUMERO + CN9_REVISA) + oMSNewGe1:aCols[nX][nPosOldPla] + oMSNewGe1:aCols[nX][nPosOldIte] ))
		CNB->(DbGoTo(aColsPos[nX]))
		RecLock("CNB",.F.)
			// O conteúdo do campo CNB_ITEM será um sequencial nesse momento mas será tratado posteriormente
			CNB->CNB_NUMERO	:= oMSNewGe1:aCols[nX][nPosNewPla]
			CNB->CNB_ITEM	:= cCount
		CNB->(MsUnLock())

		// Posiciona no registro da tabela CNA (Planilha) para atualizar os valores conforme os valores dos produtos já gravados
		CNA->(DbSeek( CN9->(CN9_FILIAL + CN9_NUMERO + CN9_REVISA) + oMSNewGe1:aCols[nX][nPosNewPla] ))
		RecLock("CNA",.F.)
			CNA->CNA_VLTOT += CNB->CNB_VLTOT
			CNA->CNA_SALDO += CNB->CNB_VLTOT
		CNA->(MsUnLock())
	Next nX

	// Corrige o campo CNB_ITEM para reiniciar a cada nova planilha
	cCount := ""
	CNB->(DbSeek( CN9->(CN9_FILIAL + CN9_NUMERO + CN9_REVISA) ))
	While ! CNB->(Eof()) .and. CNB->(CNB_FILIAL + CNB_CONTRA + CNB_REVISA) == CN9->(CN9_FILIAL + CN9_NUMERO + CN9_REVISA)
		// Controla o próximo número a ser utilizado
		if CNB->CNB_NUMERO <> cAnterior
			cAnterior	:= CNB->CNB_NUMERO
			cCount		:= StrZero(1,Len(CriaVar("CNB_ITEM"))) // Recomeça a Contagem
		else
			cCount		:= Soma1(cCount,Len(CriaVar("CNB_ITEM"))) // Adquire o próximo número
		endif

		// Altera o registro na CNB
		RecLock("CNB",.F.)
			CNB->CNB_ITEM := cCount
		CNB->(MsUnLock())

		CNB->(DbSkip())
	End

	End Transaction

Return