#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"
#INCLUDE "Rwmake.ch"
#INCLUDE "MSOLE.CH"

/*/{Protheus.doc} ABFINA02
//TODO  	Descrição: Programa para Gerar Memorando.
@author 	Joseph Oliveira / Analista de Serviços TOTVS.
@since		08/12/2016
@version 	1.0
@type 		Function
/*/
User Function ABFINA02()

	Local oDlg    := NIL

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-----------------------¿
	//³Desenha a tela de impressão                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-----------------------Ù

	@ 096,042 TO 323,505 DIALOG oDlg TITLE "Gerar Memorando."
	@ 008,010 TO 084,222
	@ 018,020 SAY "Gerar Memorando."
	@ 030,020 SAY "Será Gerado de Acordo com a Selecao de Parâmetros."
	@ 095,130 BUTTON "Gerar Memorando"     SIZE 45,10 ACTION Processa( {|| Imprime() }, "Processando..." )
	@ 095,73  BUTTON "Parâmetros"  SIZE 45,10 ACTION Processa( {|| Memoran() }, "Processando..." )
	@ 095,187 BMPBUTTON TYPE 2                      ACTION Close(oDlg)

	ACTIVATE DIALOG oDlg CENTERED

Return Nil

/*/{Protheus.doc} Memoran
//TODO 		Descrição: Função que Recebe os Parametros da Função ajusta SX1 e seta os valores nas variáveis staticas.
@author 	Joseph Oliveira / Analista de Serviços TOTVS.
@since 		08/12/2016
@version 	1.0
@type 		Function
/*/
Static Function Memoran()

	Local aArea		 	:= GetArea()
	Local aAreaA1	 	:= SA1->(GetArea())
	Local aAreaE1	 	:= SE1->(GetArea())
	
	Private cPerg		:= Padr ("AB_MEMO", Len(SX1->X1_GRUPO))

	Static cPrefixo		:= ""
	Static cNome		:= ""
	Static cParcela		:= ""
	Static cTipo 		:= ""
	Static cPara 		:= ""
	Static cCargoP 		:= ""
	Static cDe 			:= ""
	Static cCargoD 		:= ""
	Static cCgc			:= ""
	Static cMemo 		:= ""
	Static dDataCar		
	static dDtCar		
	Static cNumCar 		:= ""
	Static cAss			:= ""
	Static cCargo		:= ""

	AjustaSX1( cPerg )
	Pergunte( cPerg, .T. )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posiciona as tabelas usadas na impressão do orçamento e aponta para o primeiro registro da tabela.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DbSelectArea("SA1")
	DbSelectArea("SE1")

	SA1->( DbSetOrder(1) ) // Ordena Tabela SE1 por A1_FILIAL+A1_COD+A1_LOJA 
	SE1->( DbSetOrder(1) ) // Ordena Tabela SA1 por E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	SA1->( DbGoTop() ) // Posiona no topo da tabela
	SE1->( DbGoTop() ) // Posiona no topo da tabela

	cPrefixo 	:= MV_PAR01
	cNum     	:= MV_PAR02
	cParcela 	:= MV_PAR03
	cTipo 		:= MV_PAR04
	cPara 		:= MV_PAR05
	cCargoP 	:= MV_PAR06
	cDe 		:= MV_PAR07
	cCargoD 	:= MV_PAR08
	cMemo		:= MV_PAR09
	cNumCar		:= MV_PAR10
	dDataCar	:= MV_PAR11
	cCargo		:= MV_PAR12
	cAss		:= MV_PAR13

	dDtCar		:= AllTrim(Str(Day(dDataCar),2))+;
	' de '+ AllTrim(MesExtenso(dDataCar))+' de '+AllTrim(Str(Year(dDataCar), 4))

	If SE1->( DbSeek(XFILIAL("SE1") +cPrefixo+cNum+cParcela))

		If SA1->( DbSeek(XFILIAL("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA))

			cNome   := SA1->A1_NOME
			cCgc    := SA1->A1_CGC

		EndIf  
	EndIf    

	RestArea(aAreaA1)
	RestArea(aAreaE1)
	RestArea(aArea)

Return nil

/*/{Protheus.doc} Imprime
//TODO 		Descrição: Função que Gera o Memorando de acordo com a função Memoran().
@author 	Joseph Oliveira / Analista de Serviços TOTVS.
@since 		08/12/2016
@version 	1.0

@type function
/*/
Static Function Imprime()

	Local aArea		:= GetArea()
	Local dData		:= AllTrim(Str(Day(dDataBase),2))+;
	' de '+ AllTrim(MesExtenso(dDataBase))+' de '+AllTrim(Str(Year(dDataBase), 4))	 
	//Local cFileSave 	:= ''
	//Private cString  	:= ""
	Private hWord
	Private cPathDot 	:="\\10.10.1.200\totvs$\Microsiga\Protheus_Data\Dot\Memorando.dot"  

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida se o arquivo .dot está no local correto.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*
	If !File(cPathDot)
		MsgBox ("Arquivo Memorando.dot nao encontrado.","ERRO","STOP")

		Return(.F.)
	Endif  
*/
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Montagem das variaveis dos itens. No documento word estas variaveis serao criadas ³
	//³dinamicamente da seguinte forma:                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	hWord    := OLE_CreateLink()
	OLE_NewFile(hWord, cPathDot ) // Abre o arquivo dot e comeca gravacão.

	OLE_SetDocumentVar( hWord,"wor_Para", cPara)
	OLE_SetDocumentVar( hWord,"wor_CargoP", cCargoP)
	OLE_SetDocumentVar( hWord,"wor_De", cDe)
	OLE_SetDocumentVar( hWord,"wor_CargoDe", cCargoD)
	OLE_SetDocumentVar( hWord,"wor_data", dData)
	OLE_SetDocumentVar( hWord,"wor_A1Nome", cNome)
	OLE_SetDocumentVar( hWord,"wor_A1CGC", transform(cCgc,"@R 99.999.999/9999-99"))
	OLE_SetDocumentVar( hWord,"wor_Memo", cMemo)
	OLE_SetDocumentVar( hWord,"wor_Carta", cNumCar)
	OLE_SetDocumentVar( hWord,"wor_DCarta", dDtCar)
	OLE_SetDocumentVar( hWord,"wor_Ass", cAss)
	OLE_SetDocumentVar( hWord,"wor_CargoAss", cCargo)

	OLE_UpdateFields(hWord) //Atualiza os campos dentro do word

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Salva o documento			         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


	If MsgYesNo("Salvar o Documento ?")

		//cFileSave := "C:\TOTVS\Ambiente\TOTVS1217\Protheus_Data\Temp\dot\"
		//OLE_SaveAsFile ( hWord, cFileSave+"Memo_" + SA1->A1_NOME + ".doc" ) 
		OLE_SaveFile( hWord )
		MsgInfo("Documento Salvo com Sucesso!", "Atenção")	

	EndIf


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Fecha o Word e Corta o Link			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


	OLE_CloseFile( hWord )
	OLE_CloseLink( hWord )

	RestArea(aArea)


Return

/*/{Protheus.doc} AjustaSX1
//TODO Descrição: Função AjustaSX1 - Definição das Perguntas.
@author 	Joseph Oliveira / Analista de Serviços TOTVS.
@since 		08/12/2016
@version 	1.0
@param 		cPerg, characters, descricao
@type 		Function
/*/
Static Function AjustaSX1(cPerg)

Local aArea := GetArea()
Local nX
Local aRegs		:= {}
Local cOrdem    

AAdd(aRegs,{"Prefixo ? ","Prefixo ?","Prefix ?"										,"mv_ch1","c",TAMSX3("E1_PREFIXO")[1],0,2,"C","","mv_par01","","","","","","","","","SE1",""})
AAdd(aRegs,{"Número do Título ?","Número do Título ?","Title Number ?"				,"mv_ch2","C",TAMSX3("E1_NUM")[1],0,2,"S",""	,"mv_par02","","","","","","","","","SE1",""})
AAdd(aRegs,{"Parcela ?","Parcela ?","Plot ?"										,"mv_ch3","C",TAMSX3("E1_PARCELA")[1],0,2,"S","","mv_par03","","","","","","","","","SE1",""})
AAdd(aRegs,{"Tipo ?","Tipo ?","Kind ?"												,"mv_ch4","C",TAMSX3("E1_TIPO")[1],0,2,"S",""	,"mv_par04","","","","","","","","","SE1",""})
AAdd(aRegs,{"E-mail Para ?","Assinatura ?","Signature ?"							,"mv_ch5","C", 40,,,"G",""						,"mv_par05","","","","","","","","","",""})
AAdd(aRegs,{"Nome/Cargo ?","Nombre/Cargo","Name/Title"								,"mv_ch6","C", 40,,,"G",""						,"mv_par06","","","","","","","","","",""})
AAdd(aRegs,{"E-mail De ?","Cargo ?","Position ?"									,"mv_ch7","C", 40,,,"G",""						,"mv_par07","","","","","","","","","",""})
AAdd(aRegs,{"Nome/Cargo ?","Nombre/Cargo","Name/Title"								,"mv_ch8","C", 40,,,"G",""						,"mv_par08","","","","","","","","","",""})
AAdd(aRegs,{"Memorando ?","memorándum ?","Memo ?"									,"mv_ch9","C", 40,,,"G",""						,"mv_par09","","","","","","","","","",""})
AAdd(aRegs,{"nºCarta Apex ?","nºCarta Apex","Apex Letter Number ?"					,"mv_chA","C", 40,,,"G",""						,"mv_par10","","","","","","","","","",""})
AAdd(aRegs,{"Data do Envio da Carta  ?","Datos Novo Vencimento ?","New Date Due?"	,"mv_chB","D", 08,0,2,"C",""					,"mv_par11","","","","","","","","","",""})
AAdd(aRegs,{"Assinatura ?","Assinatura ?","Signature ?"							 	,"mv_chC","C", 40,0,2,"G",""					,"mv_par12","","","","","","","","","",""})
AAdd(aRegs,{"Cargo ?","Cargo ?","Position ?"									 	,"mv_chD","C", 50,0,2,"G",""					,"mv_par13","","","","","","","","","",""})

dbSelectArea("SX1")
dbSetOrder(1)
For nX:=1 to Len(aRegs)
	cOrdem := StrZero(nX+00,2)
//	If !MsSeek(cPerg+cOrdem)
	If !DbSeek(cPerg+cOrdem)
		RecLock("SX1",.T.)
		Replace X1_GRUPO		With cPerg
		Replace X1_ORDEM		With cOrdem
		Replace x1_pergunte		With aRegs[nx][01]
		Replace x1_perspa		With aRegs[nx][02]
		Replace x1_pereng		With aRegs[nx][03]
		Replace x1_variavl		With aRegs[nx][04]
		Replace x1_tipo			With aRegs[nx][05]
		Replace x1_tamanho		With aRegs[nx][06]
		Replace x1_decimal		With aRegs[nx][07]
		Replace x1_presel		With aRegs[nx][08]
		Replace x1_gsc			With aRegs[nx][09]
		Replace x1_valid		With aRegs[nx][10]
		Replace x1_var01		With aRegs[nx][11]
		Replace x1_def01		With aRegs[nx][12]
		Replace x1_defspa1		With aRegs[nx][13]
		Replace x1_defeng1		With aRegs[nx][14]
		Replace x1_cnt01		With aRegs[nx][15]
		Replace x1_var02		With aRegs[nx][16]
		Replace x1_def02		With aRegs[nx][17]
		Replace x1_defspa2		With aRegs[nx][18]
		Replace x1_defeng2		With aRegs[nx][19]
		Replace x1_f3			With aRegs[nx][20]
		Replace x1_grpsxg		With aRegs[nx][21]
		MsUnlock()
	Endif
Next

RestArea(aArea)

Return