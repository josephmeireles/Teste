#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"
#INCLUDE "Rwmake.ch"
#INCLUDE "MSOLE.CH"

/*/{Protheus.doc} ABFINA01
//TODO Descrição: Programa para Gerar Carta de Cobrança.
@Project	SuperAcao Apex-Brasil
@Author 	Joseph Oliveira / Analista de Serviços TOTVS.
@Since 		08/12/2016
@Version 	1.0
@Type 		Function

/*/
User Function ABFINA01()

	Local oDlg    := NIL

	//Desenha a tela de impressão

	@ 096,042 TO 323,505 DIALOG oDlg TITLE "Geração da Carta de Cobrança"
	@ 008,010 TO 084,222
	@ 018,020 SAY "Geração de Carta de Cobrança."
	@ 030,020 SAY "Será Gerada de Acordo com a Selecao de Parâmetros."	
	@ 095,130 BUTTON "Gerar Carta"     SIZE 45,10 ACTION Processa( {|| Imprime() }, "Processando..." )
	@ 095,73  BUTTON "Parâmetros"  SIZE 45,10 ACTION Processa( {|| CartaCob() }, "Processando..." )
	@ 095,187 BMPBUTTON TYPE 2                      ACTION Close(oDlg)

	ACTIVATE DIALOG oDlg CENTERED

Return Nil

/*/{Protheus.doc} CartaCob
//TODO Descrição: Função que Recebe os Parametros da Função ajusta SX1 e seta os valores nas variáveis staticas.
@Project	SuperAcao Apex-Brasil
@Author 	Joseph Oliveira / Analista de Serviços TOTVS.
@Since 		08/12/2016
@Version 	1.0
@Type 		Function
/*/
Static Function CartaCob()

	Local aArea		 	:= GetArea()
	Local aAreaA1	 	:= SA1->(GetArea())
	Local aAreaE1		:= SE1->(GetArea())
	Local aAreaA6	 	:= SA6->(GetArea())
	
	Private cPerg		:= Padr ("AB_COBR", Len(SX1->X1_GRUPO))
		
	Static cPrefixo		:= ""	
	Static cTitulo		:= ""
	Static cNum			:= ""
	Static cParcela		:= ""
	Static nExtenso		:= ""
	Static dVencReal		
	Static cNatureza	:= ""
	Static dVencto
	Static cClien		:= ""
	Static cLoja		:= ""
	Static cEnd			:= ""
	Static Bairro		:= ""
	Static cEst			:= ""
	Static cCep			:= ""
	Static cBanco		:= ""
	Static cAgencia		:= ""
	Static cContaCo		:= ""
	Static dDataN			
	Static nPorcMul		:= 0
	Static nPorcCorr	:= 0
	Static cNome		:= ""	
	Static cCarg		:= ""
	Static nPorcen		:= 0
	Static nMul			:= 0
	Static nMulta		:= 0
	Static nValor	   	:= 0
	Static cDigAgen		:= ""
	Static cDigCont 	:= ""
	Static cTipo		:= ""
	Static nCorre		:= 0
	
	// Pergunta na Tela, para Seleção de Parâmetros.
	AjustaSX1( cPerg )
	Pergunte(  cPerg, .T. )
	
	//Posiciona as tabelas usadas na impressão do orçamento e aponta para o primeiro registro da tabela.
	
	DbSelectArea( "SA1" )
	DbSelectArea( "SE1" )

	SA1->( DbSetOrder(1) ) // Ordena Tabela SE1 por: A1_FILIAL + A1_COD + A1_LOJA 
	SE1->( DbSetOrder(1) ) // Ordena Tabela SA1 por: E1_FILIAL + E1_PREFIXO + E1_NUM+E1_PARCELA + E1_TIPO
	SA1->( DbGoTop()     ) // Posiona no topo da tabela SA1
	SE1->( DbGoTop()     ) // Posiona no topo da tabela SE1

	//Adicionando o valor dos parâmetros das perguntas SX1 nas Variáveis:

	cPrefixo 	:= MV_PAR01
	cNum     	:= MV_PAR02
	cParcela 	:= MV_PAR03
	cTipo	  	:= MV_PAR04
	cBanco   	:= MV_PAR05
	cAgencia 	:= MV_PAR06
	cContaCo 	:= MV_PAR07
	dDataN  	:= MV_PAR08
	nCorre   	:= MV_PAR09
	nMulta   	:= MV_PAR10	
	cNome	 	:= MV_PAR11
	cCarg   	:= MV_PAR12

	//Seleciona o Titulo e os dados do clietnte de acordo com a passagem de Parãmetros

	If SE1->( DbSeek(XFILIAL("SE1") +cPrefixo+cNum+cParcela+cTipo))
		cTitulo    := cNum
		nValor     := SE1->E1_VLCRUZ
		dVencReal  := SE1->E1_VENCREA
		cNatureza  := SE1->E1_NATUREZ
		nPorcMul   := (nValor * nMulta) / 100
		nPorcCorr  := (nValor * nCorre) / 100
		nMul  	   := nPorcMul + nPorcCorr + nValor

		If SA1->( DbSeek(XFILIAL("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA))
			cClien 		:= SA1->A1_NOME
			cEnd     	:= SA1->A1_END
			Bairro  	:= SA1->A1_BAIRRO
			cEst 	 	:= SA1->A1_EST
			cCep     	:= SA1->A1_CEP

		EndIf  
	EndIf    

	DbSelectArea("SA6")
	SA6->( DbSetOrder(1) ) // Ordena Tabela SE1 por E6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON 
	SA6 ->( DbGoTop()    ) // Posiona no topo da tabela SA6 

	//Seleciona os dados bancarios para pagamento de acordo com a passagem de Parãmetros

	If SA6->( DbSeek(XFILIAL("SA6") +cBanco+cAgencia+cContaCo)) 
		cBanco   	:= SA6->A6_NOME
		cAgencia  	:= SA6->A6_AGENCIA
		cDigAgen	:= SA6->A6_DVAGE
		cContaCo   	:= SA6->A6_NUMCON
		cDigCont	:= SA6->A6_DVCTA

	EndIf

	DTOC(dDataN) //Conversão da variável dDataN para Caractere, para correta impressão no arquivo .Dot

	RestArea(aAreaA1)
	RestArea(aAreaE1)
	RestArea(aAreaA6)
	RestArea(aArea)

Return nil

/*/{Protheus.doc} Imprime
//TODO Descrição: Função que Gera a carta de Cobrança de acordo com a função CartaCob().
@Project 	SuperAcao Apex-Brasil
@Author 	Joseph Oliveira / Analista de Serviços TOTVS.
@Since 		08/12/2016
@Version 	1.0
@Type 		Function
/*/
Static Function Imprime()

	Local aArea				:= GetArea()
	//Private cFileSave  	:= ''
	//Private cString  		:= ""
	Private dData	 		:= AllTrim(Str(Day(dDataBase),2))+;
	' de '+ AllTrim(MesExtenso(dDataBase))+' de '+AllTrim(Str(Year(dDataBase), 4))  
	Private hWord
	Private cPathDot 		:= "\\10.10.1.200\totvs$\Microsiga\Protheus_Data\Dot\cobranca.dot"  
	
	//Valida se o arquivo .dot está no local correto.³
/*
	If !File(cPathDot)
		MsgBox ("Arquivo cobranca.dot nao encontrado.","ERRO","STOP")

		Return(.F.)
	Endif  
*/
	
	//Montagem das variaveis dos itens. No documento word estas variaveis serao criadas ³
	//dinamicamente da seguinte forma:                                                  ³

	hWord    := OLE_CreateLink()
	OLE_NewFile(hWord, cPathDot ) // Abre o arquivo dot e comeca gravacao	

	OLE_SetDocumentVar(hWord, "wor_data"   	    , dData)
	OLE_SetDocumentVar(hWord, "wor_Cliente"   	, cClien)
	OLE_SetDocumentVar(hWord, "wor_end"    		, cEnd)
	OLE_SetDocumentVar(hWord, "wor_cid"     	, Bairro)
	OLE_SetDocumentVar(hWord, "wor_estado" 	    , cEst)
	OLE_SetDocumentVar(hWord, "wor_cep"     	, transform(cCep, "@R 99999-999"))
	OLE_SetDocumentVar(hWord, "wor_Etit"    	, cTitulo)
	OLE_SetDocumentVar(hWord, "wor_Evalor"  	, alltrim(transform(nValor, "@E 9,999,999,999,999.99"))) 
	OLE_SetDocumentVar(hWord, "wor_EExtenVal"   , extenso(nValor,0,1))
	OLE_SetDocumentVar(hWord, "wor_Evenrea"     , dVencReal)
	OLE_SetDocumentVar(hWord, "wor_Enat"        , cNatureza)
	OLE_SetDocumentVar(hWord, "wor_NovData"     , dDataN)
	OLE_SetDocumentVar(hWord, "wor_INPC" 	    , alltrim(transform(nMul, "@E 9,999,999,999,999.99")))
	OLE_SetDocumentVar(hWord, "wor_EInpcExten"  , extenso(nMul,0,1))
	OLE_SetDocumentVar(hWord, "wor_Banco"       , cBanco)
	OLE_SetDocumentVar(hWord, "wor_Agencia" 	, cAgencia)
	OLE_SetDocumentVar(hWord, "wor_DigitoA"  	, cDigAgen)
	OLE_SetDocumentVar(hWord, "wor_ContaC"  	, cContaCo)
	OLE_SetDocumentVar(hWord, "wor_DigitoC"  	, cDigCont)
	OLE_SetDocumentVar(hWord, "wor_Nome"  		, alltrim(cNome))
	OLE_SetDocumentVar(hWord, "wor_Cargo"  		, cCarg)

	OLE_UpdateFields(hWord) //Atualiza os campos dentro do word

	//Salva o documento.

	If MsgYesNo("Salvar o Documento ?")

		//	cFileSave := "C:\TOTVS\Ambiente\TOTVS1217\Protheus_Data\Temp\dot\"
		//	OLE_SaveAsFile( hWord, cFileSave+"Cobranca_" + alltrim(SE1->E1_NUM) + "_" + alltrim(SA1->A1_NOME) + ".doc" ) 
		//	Ole_PrintFile(hWord,"ALL",,,1)
		OLE_SaveFile( hWord )
		MsgInfo("Documento Salvo com Sucesso!", "Atenção")

	EndIf

	//Fecha o Word e Corta o Link.

	OLE_CloseFile( hWord ) 
	OLE_CloseLink( hWord )  

	RestArea(aArea)

Return nil

/*/{Protheus.doc} AjustaSX1
//TODO Descrição: Função AjustaSX1 - Definição das Perguntas.
@Project	SuperAcao Apex-Brasil
@Author 	Joseph Oliveira / Analista de Serviços TOTVS.
@Since 		08/12/2016
@Version 	1.0
@Param 		cPerg, characters, descricao
@Type 		Function
/*/

Static Function AjustaSX1(cPerg)

Local aArea 	:= GetArea()
Local nX
Local aRegs		:= {}
Local cOrdem    
Local aHelpPor 	:= {}
Local aHelpSpa 	:= {}
Local aHelpEng 	:= {}

//AAdd(aRegs,{"Gera Presença p/todas Grades?","","","mv_ch1","N",1,0,1,"C","","mv_par01","Sim","Si","Yes","","","Não","No","No","",""})
AAdd(aRegs,{"Prefixo ? ","Prefixo ?","Prefix ?"									,"mv_ch1","c",TAMSX3("E1_PREFIXO")[1],0,2,"C",""	,"mv_par01","","","","","","","","","SE1",""})
AAdd(aRegs,{"Número do Título ?","Número do Título ?","Title Number ?"			,"mv_ch2","C",TAMSX3("E1_NUM")[1],0,2,"S",""		,"mv_par02","","","","","","","","","SE1",""})
AAdd(aRegs,{"Parcela ?","Parcela ?","Plot ?"									,"mv_ch3","C",TAMSX3("E1_PARCELA")[1],0,2,"S",""	,"mv_par03","","","","","","","","","SE1",""})
AAdd(aRegs,{"Tipo ?","Tipo ?","Kind ?"											,"mv_ch4","C",TAMSX3("E1_TIPO")[1],0,2,"S",""		,"mv_par04","","","","","","","","","SE1",""})
AAdd(aRegs,{"Banco ?","Banco ?","Bank ?"										,"mv_ch5","C",TAMSX3("A6_COD")[1],0,2,"G",""		,"mv_par05","","","","","","","","","SA6",""})
AAdd(aRegs,{"Agencia ?","Agencia ?","Agency ?"									,"mv_ch6","S",TAMSX3("A6_AGENCIA")[1],0,2,"S",""	,"mv_par06","","","","","","","","","SA6",""})
AAdd(aRegs,{"Conta Corrente ?","Conta Corrente ?","Checking Account ?"			,"mv_ch7","S",TAMSX3("A6_NUMCON")[1],0,2,"S",""		,"mv_par07","","","","","","","","","SA6",""})
AAdd(aRegs,{"Data Novo Vencimento ?","Datos Novo Vencimento ?","New Date Due?"	,"mv_ch8","D", 08,0,2,"C",""						,"mv_par08","","","","","","","","","",""})
AAdd(aRegs,{"Taxa de Correção ?","Taxa de Corrección ?","Correction Rate ?"		,"mv_ch9","N", 05,2,2,"G",""						,"mv_par09","","","","","","","","","",""})
AAdd(aRegs,{"Taxa de Juros ?","Taxa de Juros ?","Interest Rate ?"				,"mv_chA","N", 05,2,2,"G",""						,"mv_par10","","","","","","","","","",""})
AAdd(aRegs,{"Assinatura ?","Assinatura ?","Signature ?"							,"mv_chB","C", 40,0,2,"G",""						,"mv_par11","","","","","","","","","",""})
AAdd(aRegs,{"Cargo ?","Cargo ?","Position ?"									,"mv_chC","C", 50,0,2,"G",""						,"mv_par12","","","","","","","","","",""})

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
