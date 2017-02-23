#INCLUDE "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ABATFA02 บ Autor ณ Leonardo Soncin    บ Data ณ  25/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Processo especifico de Inventario de ATF - CNI             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CNI                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function ABATFA02()
Local aRot1			:= {	{ "Lista Inventแrio",	"U_SIATFR02",0,2},;
							{ "Dif. Localiza็ใo",	"U_SIATFR05",0,2} }
Local aRot2			:= {	{ "Responsแvel",		"U_ABF02R01",0,4},;
							{ "Localiza็ใo",		"U_ABF02R02",0,4},;
							{ "Dados Contแbeis",	"U_ABF02R03",0,4}}  //atfa060
Private cCadastro	:= "Cadastro de Inventแrio"
Private cDelFunc	:= ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock
Private cString		:= "PA4"
Private aRotina		:= {	{"Pesquisar",		"AxPesqui"	,0,1} ,;
							{"Importar CSV",	"U_ABF02CSV",0,3} ,;
							{"Relat๓rios",		aRot1		,0,2} ,;
							{"Transfer๊ncia",	aRot2		,0,4} ,;
							{"Conciliar",		"U_ABF02CNC",0,4} ,;
							{"Estornar",		"U_ABF02DEL",0,5} }
//							{"Visualizar",		"AxVisual"	,0,2} ,;

	DbSelectArea(cString)
	(cString)->(DbSetOrder(1))
	mBrowse(06,01,22,75,cString)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ATF02CSV บ Autor ณ Leonardo Soncin    บ Data ณ  25/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Processo especifico de Inventario de ATF - CNI             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CNI                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function ABF02CSV
Local oProcess	:= NIL
Local cPathIni	:= "C:\" //GetSrvProfString("RootPath", "")+GetSrvProfString("Startpath", "")
Private cFile	:= cGetFile("Arquivo CSV | *.csv","Selecione o arquivo CSV",,cPathIni,.T.,GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE )

	If !Empty(cFile)
		oProcess := MsNewProcess():New( { | lEnd | xImpCSV( @lEnd,oProcess) }, 'Processando', 'Aguarde, processando...', .F. )
		oProcess:Activate()
	Else
		Help(" ",1,"NOFILE")
	Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ xImpCSV  บ Autor ณ Leonardo Soncin    บ Data ณ  25/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Processo especifico de Inventario de ATF - CNI             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CNI                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function xImpCSV(lEnd,oProcess)
Local nX,nY
Local cLin		:=	""
Local aCampo	:= {}
Local aEstrut	:= {}
Local aTXT		:= {}
Local aPosCampos:= {}
Local cAliasTrb 	:= GetNextAlias()
Local cArqTmp	:= ""
Local cChave	:= ""

aEstrut :={	{ "EMISSAO" 	, "D", 	 8, 0 },;
			{ "COD_BARRA"	, "C",  20, 0 },;
			{ "LOCALIZ"		, "C",   6, 0 },;
			{ "RESP" 		, "C", 	 6, 0 },;
			{ "CCUSTO"		, "C",  20, 0 },;
			{ "ITEM"		, "C",  20, 0 },;
			{ "CLVL"		, "C",  20, 0 },;
			{ "EMPORI"		, "C",   8, 0 }}

cArqTmp := CriaTrab(aEstrut, .T.)
dbUseArea( .T.,, cArqTmp, cAliasTrb, .F., .F. )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria Indice Temporario do Arquivo de Trabalho 1.             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cChave   := "DTOS(EMISSAO)+LOCALIZ+RESP"

IndRegua(cAliasTrb,cArqTmp,cChave,,,"Selecionando Registros...")
dbSelectArea(cAliasTrb)
dbSetIndex(cArqTmp+OrdBagExt())
dbSetOrder(1)

// ESTRUTURA DO ARQUIVO TEXTO
aAdd(aCampo,"EMISSAO")
aAdd(aCampo,"COD_BARRA")
aAdd(aCampo,"LOCALIZACAO")
aAdd(aCampo,"RESPONSAVEL")
aAdd(aCampo,"CCUSTO")
aAdd(aCampo,"ITEM")
aAdd(aCampo,"CLVL")
aAdd(aCampo,"EMPORI")

//Define o valor do array conforme estrutura
aPosCampos:= Array(Len(aCampo))

If (nHandle := FT_FUse(AllTrim(cFile)))== -1
	Help(" ",1,"NOFILEIMPOR")
	Return
EndIf

//Verifica Estrutura do Arquivo
FT_FGOTOP()
cLinha := FT_FREADLN()
nPos	:=	0
nAt	:=	1

While nAt > 0
	nPos++
	nAt	:=	AT(";",cLinha)
	If nAt == 0
		cCampo := cLinha
	Else
		cCampo	:=	Substr(cLinha,1,nAt-1)
	Endif
	nPosCpo	:=	Ascan(aCampo,{|x| x==cCampo})
	If nPosCPO > 0
		aPosCampos[nPosCpo]:= nPos
	Endif
	cLinha	:=	Substr(cLinha,nAt+1)
Enddo

If (nPosNil:= Ascan(aPosCampos,Nil)) > 0
	Aviso("Estrutura de arquivo invแlido.","O campo "+aCampo[nPosNil]+" nao foi encontrado na estrutura, verifique.",{"Sair"})
	Return .F.
Endif

// Inicia Importacao das Linhas
FT_FSKIP()
While !FT_FEOF()
	cLinha := FT_FREADLN()
	AADD(aTxt,{})
	nCampo := 1
	While At(";",cLinha)>0
		aAdd(aTxt[Len(aTxt)],Substr(cLinha,1,At(";",cLinha)-1))
		nCampo ++
		cLinha := StrTran(Substr(cLinha,At(";",cLinha)+1,Len(cLinha)-At(";",cLinha)),'"','')
	End
	If Len(AllTrim(cLinha)) > 0
		aAdd(aTxt[Len(aTxt)],StrTran(Substr(cLinha,1,Len(cLinha)),'"','') )
	Else
		aAdd(aTxt[Len(aTxt)],"")
	Endif
	FT_FSKIP()
End

// Gravacao dos Itens (TRB)
FT_FUSE()
For nX:=1 To Len(aTxt)
	For nY:=1 To Len(aCampo)
		dbSelectArea(cAliastrb)
		RecLock(cAliasTrb,.T.)
		For nY:=1 To Len(aCampo)
			If AllTrim(aCampo[nY]) == 'RESPONSAVEL'
				FieldPut(FieldPos("RESP"),aTxt[nX,aPosCampos[nY]])
			ElseIf AllTrim(aCampo[nY]) == 'LOCALIZACAO'
				FieldPut(FieldPos("LOCALIZ"),aTxt[nX,aPosCampos[nY]])
			ElseIf AllTrim(aCampo[nY]) == 'EMISSAO'
				If ValType(aTxt[nX,aPosCampos[nY]]) == "D"
					_data:= aTxt[nX,aPosCampos[nY]]
				Else
					_data:= Stod(aTxt[nX,aPosCampos[nY]])
				Endif
				FieldPut(FieldPos(aCampo[nY]),_dAta)
			Else
				FieldPut(FieldPos(aCampo[nY]),aTxt[nX,aPosCampos[nY]])
			Endif
		Next
		MsUnLock()
	Next
Next

dbSelectArea(cAliasTrb)
dbGotop()

// Inicia Gravacao no Sistema - Tabela PA4
xAtuPA4(cAliasTrb,oProcess)

If Select(cAliasTrb) != 0
	dbSelectArea(cAliasTrb)
	dbCloseArea()
	FErase(cArqTmp+GetDBExtension())
	FErase(cArqTmp+OrdBagExt())
Endif

Aviso("Importa็ใo de CSV","Processo finalizado.",{"OK"})

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ABATFA02 บ Autor ณ Leonardo Soncin    บ Data ณ  25/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Processo especifico de Inventario de ATF - CNI             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CNI                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function xAtuPA4(cAliastrb,oProcess)
Local aEstrut	:= {}
Local cAliasTmp := GetNextAlias()
Local cArqTmp	:= ""
Local cChave	:= ""
Local lErro		:= .F.
Local lGrava	:= .T.
Local cDescBem	:= ""
Local nTotRegs 	:= 0
Local nProcRegs := 0

aEstrut :={	{ "EMISSAO" 	, "D", 	 8, 0 },;
			{ "COD_BARRA"	, "C",  20, 0 },;
			{ "DESCR"		, "C",  30, 0 },;
			{ "CONTEUDO"	, "C",  20, 0 },;
			{ "MSG"			, "C",  60, 0 }}

cArqTmp := CriaTrab(aEstrut, .T.)
dbUseArea( .T.,, cArqTmp, cAliasTmp, .F., .F. )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria Indice Temporario do Arquivo de Trabalho.               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cChave   := "DTOS(EMISSAO)+COD_BARRA"

IndRegua(cAliasTmp,cArqTmp,cChave,,,"Criando Arquivo Temporแrio...")
dbSelectArea(cAliasTmp)
dbSetIndex(cArqTmp+OrdBagExt())
dbSetOrder(1)

//Validacoes
dbSelectArea("PA4")
dbSetOrder(1)
If dbSeek(xFilial("PA4")+Dtos((cAliasTrb)->EMISSAO)+(cAliastrb)->LOCALIZ+(cAliasTrb)->RESP)
	MsgStop("Jแ existe informa็ใo para a data de "+Dtoc((cAliasTrb)->EMISSAO)+", localiza็ใo "+(cAliastrb)->LOCALIZ+" e responsแvel "+(cAliasTrb)->RESP+". Verifique!")
	Return
Endif

dbSelectArea(cAliasTrb)

dbEval( {|x| nTotRegs++ },,{|| (cAliasTrb)->(!EOF())})
oProcess:SetRegua1(nTotRegs+2)
oProcess:IncRegua1("Iniciando processamento...")
oProcess:SetRegua2(nTotRegs+1)
oProcess:IncRegua2("")

// Prcessa o Arquivo e Grava
dbSelectArea(cAliasTrb)
dbGotop()
While !Eof(cAliasTrb)

	cDescBem := xDescBem((cAliasTrb)->COD_BARRA,(cAliasTrb)->EMPORI)

	// Valida CC
	dbSelectArea("CTT")
	dbSetOrder(1)
	If !Empty((cAliasTrb)->CCUSTO) .and. !dbSeek(xFilial("CTT")+(cAliasTrb)->CCUSTO)
		lErro 	:= .T.
		lGrava 	:= .F.
		dbSelectArea(cAliasTmp)
		RecLock(cAliasTmp,.T.)
		(cAliasTmp)->EMISSAO 	:= (cAliasTrb)->EMISSAO
		(cAliasTmp)->COD_BARRA 	:= (cAliasTrb)->COD_BARRA
		(cAliasTmp)->DESCR		:= cDescBem
		(cAliasTmp)->CONTEUDO 	:= (cAliasTrb)->CCUSTO
		(cAliasTmp)->MSG	 	:= "Centro de Custo "+Alltrim((cAliastrb)->CCUSTO)+" nใo localizado na base de dados."
		MsUnlock()
	Endif

	//Valida Item
	dbSelectArea("CTD")
	dbSetOrder(1)
	If !Empty((cAliasTrb)->ITEM) .and. !dbSeek(xFilial("CTD")+(cAliasTrb)->ITEM)
		lErro := .T.
		lGrava 	:= .F.
		dbSelectArea(cAliasTmp)
		RecLock(cAliasTmp,.T.)
		(cAliasTmp)->EMISSAO 	:= (cAliastrb)->EMISSAO
		(cAliasTmp)->COD_BARRA 	:= (cAliasTrb)->COD_BARRA
		(cAliasTmp)->DESCR		:= cDescBem
		(cAliasTmp)->CONTEUDO 	:= (cAliasTrb)->ITEM
		(cAliasTmp)->MSG	 	:= "Item Contแbil "+Alltrim((cAliasTrb)->ITEM)+" nใo localizado na base de dados."
		MsUnlock()
	Endif

	//Valida Classe de Valor
	dbSelectArea("CTH")
	dbSetOrder(1)
	If !Empty((cAliasTrb)->CLVL) .and. !dbSeek(xFilial("CTH")+(cAliasTrb)->CLVL)
		lErro := .T.
		lGrava 	:= .F.
		dbSelectArea(cAliasTmp)
		RecLock(cAliasTmp,.T.)
		(cAliasTmp)->EMISSAO 	:= (cAliasTrb)->EMISSAO
		(cAliasTmp)->COD_BARRA 	:= (cAliasTrb)->COD_BARRA
		(cAliasTmp)->DESCR		:= cDescBem
		(cAliasTmp)->CONTEUDO 	:= (cAliasTrb)->CLVL
		(cAliasTmp)->MSG	 	:= "Classe de Valor "+Alltrim((cAliasTrb)->CLVL)+" nใo localizada na base de dados."
		MsUnlock()
	Endif

	//Valida Responsavel
	dbSelectArea("RD0")
	dbSetOrder(1)
	If !Empty((cAliasTrb)->RESP) .and. !dbSeek(xFilial("RD0")+(cAliasTrb)->RESP)
		lErro := .T.
		lGrava 	:= .F.
		dbSelectArea(cAliasTmp)
		RecLock(cAliasTmp,.T.)
		(cAliasTmp)->EMISSAO 	:= (cAliasTrb)->EMISSAO
		(cAliasTmp)->COD_BARRA 	:= (cAliasTrb)->COD_BARRA
		(cAliasTmp)->DESCR		:= cDescBem
		(cAliasTmp)->CONTEUDO 	:= (cAliasTrb)->RESP
		(cAliasTmp)->MSG	 	:= "Responsแvel "+Alltrim((cAliasTrb)->RESP)+" nใo localizado na base de dados."
		MsUnlock()
	Endif

	//Valida Localizacao
	dbSelectArea("SNL")
	dbSetOrder(1)
	If !Empty((cAliasTrb)->LOCALIZ) .and. !dbSeek(xFilial("SNL")+(cAliasTrb)->LOCALIZ)
		lErro := .T.
		lGrava 	:= .F.
		dbSelectArea(cAliasTmp)
		RecLock(cAliasTmp,.T.)
		(cAliasTmp)->EMISSAO 	:= (cAliastrb)->EMISSAO
		(cAliasTmp)->COD_BARRA 	:= (cAliasTrb)->COD_BARRA
		(cAliasTmp)->DESCR		:= cDescBem
		(cAliasTmp)->CONTEUDO 	:= (cAliasTrb)->LOCALIZ
		(cAliasTmp)->MSG	 	:= "Localiza็ใo "+Alltrim((cAliasTrb)->LOCALIZ)+" nใo localizada na base de dados."
		MsUnlock()
	Endif

	//Valida Empresa
	aAreaSM0 := GetArea("SM0")
	dbSelectArea("SM0")
	If !Empty((cAliasTrb)->EMPORI) .and. !dbSeek(cEmpAnt+(cAliasTrb)->EMPORI)
		lErro := .T.
		lGrava 	:= .F.
		dbSelectArea(cAliasTmp)
		RecLock(cAliasTmp,.T.)
		(cAliasTmp)->EMISSAO 	:= (cAliastrb)->EMISSAO
		(cAliasTmp)->COD_BARRA 	:= (cAliasTrb)->COD_BARRA
		(cAliasTmp)->DESCR		:= cDescBem
		(cAliasTmp)->CONTEUDO 	:= (cAliasTrb)->EMPORI
		(cAliasTmp)->MSG	 	:= "Empresa "+Alltrim((cAliasTrb)->EMPORI)+" nใo localizada na base de dados. Gr. Empresa: "+cEmpAnt
		MsUnlock()
	Endif
	RestArea(aAreaSM0)

	If lGrava
		dbSelectArea("PA4")
		RecLock("PA4",.T.)
		PA4->PA4_FILIAL 	:= xFilial("PA4")
		PA4->PA4_EMISSAO 	:= (cAliasTrb)->EMISSAO
		PA4->PA4_CODBAR 	:= (cAliasTrb)->COD_BARRA
		PA4->PA4_LOCALIZ	:= (cAliasTrb)->LOCALIZ
		PA4->PA4_RESP		:= (cAliasTrb)->RESP
		PA4->PA4_CC			:= (cAliasTrb)->CCUSTO
		PA4->PA4_ITEM		:= (cAliasTrb)->ITEM
		PA4->PA4_CLVL		:= (cAliasTrb)->CLVL
		PA4->PA4_EMPORI		:= (cAliasTrb)->EMPORI
		PA4->PA4_STATUS		:= "3"
		MsUnlock()

		// Chama rotina de conciliacao
		xConcilia()

		nProcRegs++
		oProcess:IncRegua2("Codigo de Barra: "+(cAliasTrb)->COD_BARRA)

	Endif

	oProcess:IncRegua1("Processando item: "+CValToChar(nProcRegs)+" / "+CValToChar(nTotRegs))

	dbSelectArea(cAliasTrb)
	dbSkip()
	lGrava := .T.

Enddo


If lErro
	//Chama Impressao do Relatorio de Inconsistencias
	If ApMsgYesNo("Ocorreram inconsist๊ncias durante a importa็ใo dos dados, deseja imprimir o log?","Log de Inconsist๊ncias")
		xRelInc(cAliasTmp,"Inconsist๊ncias da Importa็ใo")
	Endif
Endif

If Select(cAliasTMP) > 0  //
	dbSelectArea(cAliasTMP)
	dbCloseArea()
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ATF02DEL บ Autor ณ Leonardo Soncin    บ Data ณ  25/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Processo especifico de Inventario de ATF - CNI             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CNI                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function ABF02DEL
Local cPerg := "AF2DEL"

ValidPerg(cPerg)

If Pergunte(cPerg,.T.)

	If MsgYesNo("Confirma dele็ใo dos registros?","Confirma estorno? Sim/Nใo")
		dbSelectArea("PA4")
		dbSetOrder(1)
		dbGotop()
		dbSeek(xFilial("PA4")+DTOS(MV_PAR01),.T.)

		While !Eof() .and. PA4->PA4_FILIAL == xFilial("PA4") .AND. PA4->PA4_EMISSAO <= MV_PAR02
			RecLock("PA4",.F.)
			dbDelete()
			MsUnlock()
			dbSkip()
		EndDo
	Endif

Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ xRelIn   บ Autor ณ Leonardo Soncin    บ Data ณ  29/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio de Inconsistencias (Importacao e Transferencia)  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CNI                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function xRelInc(_cAlias,_cTitulo)
Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2        := "de acordo com os parametros informados pelo usuario."
Local cDesc3        := _cTitulo
Local cPict       	:= ""
Local titulo       	:= _cTitulo
Local nLin         	:= 80
Local Cabec1       	:= "Emissใo    Cod. Barra         Descri็ใo                        Conte๚do              Mensagem"
//1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789123456789123456789123456789
//0        1         2         3         4         5         6         7         8         9         1
Local Cabec2       	:= ""
Local imprime      	:= .T.
Local aOrd 			:= {}
Private lEnd      	:= .F.
Private lAbortPrint	:= .F.
Private CbTxt     	:= ""
Private limite   	:= 132
Private tamanho  	:= "M"
Private nomeprog 	:= "ABATFA02"
Private nTipo     	:= 18
Private aReturn  	:= { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey	:= 0
Private cbtxt      	:= Space(10)
Private cbcont     	:= 00
Private CONTFL     	:= 01
Private m_pag      	:= 01
Private wnrel      	:= "ABATFA02"
Private cString		:= _cAlias

dbSelectArea(cString)
dbSetOrder(1)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta a interface padrao com o usuario...                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Processamento. RPTSTATUS monta janela com a regua de processamento. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ AP6 IDE            บ Data ณ  29/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
Local nOrdem
Local nTamLin := 50

dbSelectArea(cString)
dbSetOrder(1)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

SetRegua(RecCount())

dbGoTop()
While !EOF()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica o cancelamento pelo usuario...                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lAbortPrint
		@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Impressao do cabecalho do relatorio. . .                            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If nLin > 55 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8
	Endif

	@nLin,000 PSAY Dtoc((cString)->EMISSAO)
	@nLin,011 PSAY (cString)->COD_BARRA
	@nLin,030 PSAY (cString)->DESCR
	@nLin,063 PSAY (cString)->CONTEUDO

//	@nLin,085 PSAY (cString)->MSG

    cAux1:= Dtoc((cString)->EMISSAO)
    cAux2:= (cString)->COD_BARRA
    cAux3:= (cString)->DESCR
    cAux4:= (cString)->CONTEUDO

    While cAux1 == Dtoc((cString)->EMISSAO) .And.;
		cAux2 ==(cString)->COD_BARRA
		cAux3 ==(cString)->DESCR
		cAux4 == (cString)->CONTEUDO
		@nLin,085 PSAY (cString)->MSG
		nLin := nLin + 1 // Avanca a linha de impressao
		IncRegua()
		dbSkip() // Avanca o ponteiro do registro no arquivo
     End

EndDo

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Finaliza a execucao do relatorio...                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SET DEVICE TO SCREEN

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ xConciliaบ Autor ณ AP6 IDE            บ Data ณ  29/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function xConcilia()
Local _cQuery := ""
Local cAliasTMP1 := GetNextAlias()

_cQuery :=  "SELECT N1_DESCRIC, N1_LOCAL, N3_CUSTBEM, N3_SUBCCON, N3_CLVLCON, ND_CODRESP "
_cQuery +=  "FROM "+RetSqlName("SN1")+" SN1 "
_cQuery +=  "LEFT OUTER JOIN "+RetSqlName("SN3")+" SN3 ON N3_FILIAL = '"+Alltrim(PA4->PA4_EMPORI)+"' AND N3_CBASE = N1_CBASE	AND N3_ITEM = N1_ITEM AND SN3.D_E_L_E_T_ = '' "
_cQuery +=  "LEFT OUTER JOIN "+RetSqlName("SND")+" SND ON ND_FILIAL = '"+Alltrim(PA4->PA4_EMPORI)+"' AND ND_CBASE = N1_CBASE	AND ND_ITEM = N1_ITEM AND SND.D_E_L_E_T_ = '' AND SND.ND_STATUS = '1' "
_cQuery +=  "WHERE N1_FILIAL = '"+Alltrim(PA4->PA4_EMPORI)+"' AND "
_cQuery +=  "N1_CODBAR = '"+PA4->PA4_CODBAR+"' AND "
_cQuery +=  "SN1.D_E_L_E_T_ = '' "
_cQuery := ChangeQuery(_cQuery)

If Select(cAliasTMP1) > 0
	dbSelectArea(cAliasTMP1)
	dbCloseArea()
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),cAliasTMP1,.T.,.F.)

DbSelectArea(cAliasTMP1)
dbGotop()

If !Eof(cAliasTMP1)
	dbSelectArea("PA4")
	RecLock("PA4",.F.)
	PA4->PA4_DESCBEM	:= (cAliasTMP1)->N1_DESCRIC
	PA4->PA4_XLOCAL 	:= (cAliasTMP1)->N1_LOCAL
	PA4->PA4_XRESP		:= (cAliasTMP1)->ND_CODRESP
	PA4->PA4_XCC		:= (cAliasTMP1)->N3_CUSTBEM
	PA4->PA4_XITEM		:= (cAliasTMP1)->N3_SUBCCON
	PA4->PA4_XCLVL		:= (cAliasTMP1)->N3_CLVLCON

	If PA4_LOCALIZ+PA4_RESP+PA4_CC+PA4_ITEM+PA4_CLVL == PA4_XLOCAL+PA4_XRESP+PA4_XCC+PA4_XITEM+PA4_XCLVL
		PA4->PA4_STATUS := "1"
	Else
		PA4->PA4_STATUS := "2"
	Endif

	MsUnLock()
Endif

If Select(cAliasTMP1) > 0
	dbSelectArea(cAliasTMP1)
	dbCloseArea()
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณ ValidPergณ Autor ณ Wagner Gomes          ณ Data ณ 10/12/09 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Cria as Perguntas para Fatura para locacao de Bens Moveis  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Especifico Construtora OAS Ltda                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ValidPerg(cPerg)
Local _sAlias := Alias()
Local aRegs := {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

If cPerg = "AF2DEL"

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
	aAdd(aRegs,{cPerg,"01","Emissใo de:  "				,"mv_ch1","D",08,0,0,"G","naovazio()","mv_par01","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Emissใo at้: "				,"mv_ch2","D",08,0,0,"G","naovazio() .and. mv_par02>=mv_par01","mv_par02","","","","","","","","","","","","","","","",""})

Else

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
	aAdd(aRegs,{cPerg,"01","Codigo de Barras de:  "		,"mv_ch1","C",20,0,0,"G","","mv_par01","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Codigo de Barras at้: "		,"mv_ch2","C",20,0,0,"G","","mv_par02","","","","","","","","","","","","","","","",""})

Endif

For i := 1 to Len(aRegs)
	PutSX1(aRegs[i,1],aRegs[i,2],aRegs[i,3],aRegs[i,3],aRegs[i,3],aRegs[i,4],aRegs[i,5],aRegs[i,6],aRegs[i,7],;
	aRegs[i,8],aRegs[i,9],aRegs[i,10],iif(len(aRegs[i])>=26,aRegs[i,26],""),aRegs[i,27],"",aRegs[i,11],aRegs[i,12],;
	aRegs[i,12],aRegs[i,12],aRegs[i,13],aRegs[i,15],aRegs[i,15],aRegs[i,15],aRegs[i,18],aRegs[i,18],aRegs[i,18],;
	aRegs[i,21],aRegs[i,21],aRegs[i,21],aRegs[i,24],aRegs[i,24],aRegs[i,24])

Next i

dbSelectArea(_sAlias)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ABF02CNC บ Autor ณ Leonardo Soncin    บ Data ณ  25/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Conciliacao dos Registros                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CNI                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function ABF02CNC
Local aArea := GetArea()
Local oProcess  := NIL

If ApMsgYesNo("Confirma concilia็ใo dos itens?","Concilia็ใo")
	oProcess := MsNewProcess():New( { | lEnd | xConcl( @lEnd,oProcess) }, 'Processando', 'Aguarde, processando...', .F. )
	oProcess:Activate()
Endif

Aviso("Concilia็ใo","Processo finalizado.",{"OK"})

RestArea(aArea)

Return



// Concilia็ใo dos Itens

Static Function xConcl(lEnd,oProcess)

Local cFilter 	:= "PA4_STATUS == '3'"
Local nTotRegs 	:= 0
Local nProcRegs := 0

dbSelectArea("PA4")
Set Filter To &(cFilter)

dbEval( {|x| nTotRegs++ },,{|| PA4->(!EOF())})
oProcess:SetRegua1(nTotRegs+2)
oProcess:IncRegua1("Iniciando processamento...")

dbGotop()
While ! Eof("PA4")

	xConcilia()

	nProcRegs++
	oProcess:IncRegua1("Processando item: "+CValToChar(nProcRegs)+" / "+CValToChar(nTotRegs))

	dbSelectArea("PA4")
	dbSkip()
Enddo

dbClearFilter()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ABF02R02 บ Autor ณ Leonardo Soncin    บ Data ณ  25/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Processo especifico de Inventario de ATF - CNI             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CNI                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function ABF02R02
Local cPerg		:= "AF2TRF"
Local aArea		:= GetArea()
Local oProcess	:= NIL

ValidPerg(cPerg)
If Pergunte(cPerg,.T.)
	If ApMsgYesNo("Confirma a transfer๊ncia de locais?","Transfer๊ncia")
		oProcess := MsNewProcess():New( { | lEnd | xTrfLoc( @lEnd,oProcess) }, 'Processando', 'Aguarde, processando...', .F. )
		oProcess:Activate()
	Endif
Endif

Aviso("Transfer๊ncia","Processo finalizado.",{"OK"})

RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ABATFA02 บ Autor ณ Leonardo Soncin    บ Data ณ  25/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Processo especifico de Inventario de ATF - CNI             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CNI                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function xTrfLoc(lEnd,oProcess)

Local _cQuery := ""
Local cAliasTMP2 := GetNextAlias()
Local nProcRegs	  := 0
Local nTotRegs	  := 0

_cQuery :=  "SELECT PA4_CODBAR, PA4_EMPORI, PA4_LOCALIZ, PA4_EMPORI, N1_CBASE, N1_ITEM, PA4.R_E_C_N_O_ AS RECNOPA4 "
_cQuery +=  "FROM "+RetSqlName("PA4")+" PA4 "
_cQuery +=  "LEFT OUTER JOIN "+RetSqlName("SN1")+" SN1 ON N1_FILIAL = PA4_EMPORI AND N1_CODBAR = PA4_CODBAR AND SN1.D_E_L_E_T_ = '' "
_cQuery +=  " WHERE PA4_FILIAL = '"+xFilial("PA4")+"' AND "
_cQuery +=  "PA4_CODBAR BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
_cQuery +=  "PA4_STATUS = '2' AND "
_cQuery +=  "PA4.D_E_L_E_T_ = '' "
_cQuery := ChangeQuery(_cQuery)

If Select(cAliasTMP2) > 0
	dbSelectArea(cAliasTMP2)
	dbCloseArea()
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),cAliasTMP2,.T.,.F.)

DbSelectArea(cAliasTMP2)

dbEval( {|x| nTotRegs++ },,{|| (cAliasTMP2)->(!EOF())})
oProcess:SetRegua1(nTotRegs+2)
oProcess:IncRegua1("Iniciando processamento...")
oProcess:SetRegua2(nTotRegs+1)
oProcess:IncRegua2("")

dbGotop()

While !Eof()

	dbSelectArea("SN1")
	dbSetOrder(1)
	dbSeek(Alltrim((cAliasTMP2)->PA4_EMPORI)+(cAliasTMP2)->(N1_CBASE+N1_ITEM))
	RecLock("SN1",.F.)
	SN1->N1_LOCAL := (cAliasTMP2)->PA4_LOCALIZ
	MsUnlock()

	dbSelectArea("PA4")
	dbSetOrder(1)
	dbGoto((cAliasTMP2)->RECNOPA4)

	xConcilia()

	nProcRegs++
	oProcess:IncRegua1("Processando item: "+CValToChar(nProcRegs)+" / "+CValToChar(nTotRegs))
	oProcess:IncRegua2("Codigo de Barra: "+(cAliasTMP2)->PA4_CODBAR)

	DbSelectArea(cAliasTMP2)
	dbSkip()
EndDo

If Select(cAliasTMP2) > 0
	dbSelectArea(cAliasTMP2)
	dbCloseArea()
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ABATFA02 บ Autor ณ Leonardo Soncin    บ Data ณ  25/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Processo especifico de Inventario de ATF - CNI             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CNI                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function xDescBem(cCodBar,_cEmpOri)

Local cDescr := ""
Local _cQuery := ""
Local cAliasTMP3 := GetNextAlias()

_cQuery :=  "SELECT N1_DESCRIC "
_cQuery +=  "FROM "+RetSqlName("SN1")+" SN1 "
_cQuery +=  "WHERE N1_FILIAL = '"+_cEmpOri+"' AND "
_cQuery +=  "N1_CODBAR = '"+cCodBar+"' AND "
_cQuery +=  "SN1.D_E_L_E_T_ = '' "
_cQuery := ChangeQuery(_cQuery)

If Select(cAliasTMP3) > 0
	dbSelectArea(cAliasTMP3)
	dbCloseArea()
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),cAliasTMP3,.T.,.F.)

dbSelectArea(cAliasTMP3)

If !Eof(cAliasTMP3)
	cDescr := (cAliasTMP3)->N1_DESCRIC
Endif

If Select(cAliasTMP3) > 0
	dbSelectArea(cAliasTMP3)
	dbCloseArea()
Endif

Return cDescr


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ABATFA02 บ Autor ณ Leonardo Soncin    บ Data ณ  25/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Processo especifico de Inventario de ATF - CNI             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CNI                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function ABF02R01
Local cPerg := "AF2TRF"
Local aArea := GetArea()
Local oProcess  := NIL

ValidPerg(cPerg)
If Pergunte(cPerg,.T.)
	If ApMsgYesNo("Confirma a transfer๊ncia de responsแveis?","Transfer๊ncia")
		oProcess := MsNewProcess():New( { | lEnd | xTrfResp( @lEnd,oProcess) }, 'Processando', 'Aguarde, processando...', .F. )
		oProcess:Activate()
	Endif
Endif

Aviso("Transfer๊ncia","Processo finalizado.",{"OK"})

RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ABATFA02 บ Autor ณ Leonardo Soncin    บ Data ณ  25/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Processo especifico de Inventario de ATF - CNI             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CNI                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function xTrfResp(lEnd,oProcess)

Local _cQuery := ""
Local cAliasTMP2 := GetNextAlias()
Local nProcRegs	  := 0
Local nTotRegs	  := 0
Local __cFilOri	  := cFilAnt

_cQuery :=  "SELECT PA4_CODBAR, PA4_RESP, PA4_XRESP, PA4_EMPORI, N1_CBASE, N1_ITEM, PA4.R_E_C_N_O_ AS RECNOPA4 "
_cQuery +=  "FROM "+RetSqlName("PA4")+" PA4 "
_cQuery +=  "LEFT OUTER JOIN "+RetSqlName("SN1")+" SN1 ON N1_FILIAL = PA4_EMPORI AND N1_CODBAR = PA4_CODBAR AND SN1.D_E_L_E_T_ = '' "
_cQuery +=  " WHERE PA4_FILIAL = '"+xFilial("PA4")+"' AND "
_cQuery +=  "PA4_CODBAR BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
_cQuery +=  "PA4_STATUS = '2' AND "
_cQuery +=  "PA4_RESP <> PA4_XRESP AND "
_cQuery +=  "PA4.D_E_L_E_T_ = '' "
_cQuery := ChangeQuery(_cQuery)

If Select(cAliasTMP2) > 0
	dbSelectArea(cAliasTMP2)
	dbCloseArea()
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),cAliasTMP2,.T.,.F.)

DbSelectArea(cAliasTMP2)

dbEval( {|x| nTotRegs++ },,{|| (cAliasTMP2)->(!EOF())})
oProcess:SetRegua1(nTotRegs+2)
oProcess:IncRegua1("Iniciando processamento...")
oProcess:SetRegua2(nTotRegs+1)
oProcess:IncRegua2("")

dbGotop()

While !Eof()

	dbSelectArea("SN1")
	dbSetOrder(1)
	dbSeek(Alltrim((cAliasTMP2)->PA4_EMPORI)+(cAliasTMP2)->(N1_CBASE+N1_ITEM))

	cFilAnt := (cAliasTMP2)->(PA4_EMPORI)

	If Af190GrTrans(SN1->N1_CBASE,SN1->N1_ITEM,(cAliasTMP2)->PA4_XRESP,(cAliasTMP2)->PA4_RESP)

		dbSelectArea("PA4")
		dbSetOrder(1)
		dbGoto((cAliasTMP2)->RECNOPA4)

		cFilAnt := __cFilOri

		xConcilia()

		nProcRegs++
		oProcess:IncRegua1("Processando item: "+CValToChar(nProcRegs)+" / "+CValToChar(nTotRegs))
		oProcess:IncRegua2("Codigo de Barra: "+(cAliasTMP2)->PA4_CODBAR)

	Endif

	DbSelectArea(cAliasTMP2)
	dbSkip()
EndDo

cFilAnt := __cFilOri

If Select(cAliasTMP2) > 0
	dbSelectArea(cAliasTMP2)
	dbCloseArea()
Endif


Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ABATFA02 บ Autor ณ Leonardo Soncin    บ Data ณ  25/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Processo especifico de Inventario de ATF - CNI             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CNI                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function ABF02R03
Local cPerg := "AF2TRF"
Local aArea := GetArea()
Local oProcess  := NIL

ValidPerg(cPerg)
If Pergunte(cPerg,.T.)
	If ApMsgYesNo("Confirma a transfer๊ncia de dados contแbeis?","Transfer๊ncia")
		oProcess := MsNewProcess():New( { | lEnd | xTrfCtb( @lEnd,oProcess) }, 'Processando', 'Aguarde, processando...', .F. )
		oProcess:Activate()
	Endif
Endif

Aviso("Transfer๊ncia","Processo finalizado.",{"OK"})

RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ABATFA02 บ Autor ณ Leonardo Soncin    บ Data ณ  25/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Processo especifico de Inventario de ATF - CNI             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CNI                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function xTrfCtb(lEnd,oProcess)
Local _cQuery		:= ""
Local cAliasTMP		:= GetNextAlias()
Local cAliasTMP2	:= GetNextAlias()
Local nProcRegs		:= 0
Local nTotRegs		:= 0
Local aDadosAuto 	:= {}         // Array com os dados a serem enviados pela MsExecAuto() para gravacao automatica
Local aEstrut		:= {}
Local lErro			:= .F.
Local nTamLin		:= 50
Local _cErroAuto	:= ""
Local __cFilOri		:= cFilAnt
Private lMsHelpAuto	:= .f.        // Determina se as mensagens de help devem ser direcionadas para o arq. de log
Private lMsErroAuto	:= .f.        // Determina se houve alguma inconsistencia na execucao da rotina em relacao aos

aEstrut				:={	{ "EMISSAO" 	, "D", 	 8, 0 },;
						{ "COD_BARRA"	, "C",  20, 0 },;
						{ "DESCR"		, "C",  30, 0 },;
						{ "CONTEUDO"	, "C",  20, 0 },;
						{ "MSG"			, "C",  60, 0 }}

cArqTmp				:= CriaTrab(aEstrut, .T.)

dbUseArea( .T.,, cArqTmp, cAliasTmp, .F., .F. )
cChave := "DTOS(EMISSAO)+COD_BARRA"
IndRegua(cAliasTmp,cArqTmp,cChave,,,"Criando Arquivo Temporแrio...")

dbSelectArea(cAliasTmp)
dbSetIndex(cArqTmp+OrdBagExt())
dbSetOrder(1)

_cQuery :=  "SELECT PA4_EMISSAO, PA4_CODBAR, PA4_CC, PA4_CLVL, PA4_ITEM, PA4_EMPORI, N1_CBASE, N1_ITEM, N1_DESCRIC, PA4.R_E_C_N_O_ AS RECNOPA4 "
_cQuery +=  "FROM "+RetSqlName("PA4")+" PA4 "
_cQuery +=  "LEFT OUTER JOIN "+RetSqlName("SN1")+" SN1 ON N1_FILIAL = PA4_EMPORI AND N1_CODBAR = PA4_CODBAR AND SN1.D_E_L_E_T_ = '' "
_cQuery +=  " WHERE PA4_FILIAL = '"+xFilial("PA4")+"' AND "
_cQuery +=  "PA4_CODBAR BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
_cQuery +=  "PA4_STATUS = '2' AND "
_cQuery +=  "PA4.D_E_L_E_T_ = '' "
_cQuery := ChangeQuery(_cQuery)

If Select(cAliasTMP2) > 0
	dbSelectArea(cAliasTMP2)
	dbCloseArea()
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),cAliasTMP2,.T.,.F.)

DbSelectArea(cAliasTMP2)

dbEval( {|x| nTotRegs++ },,{|| (cAliasTMP2)->(!EOF())})
oProcess:SetRegua1(nTotRegs+2)
oProcess:IncRegua1("Iniciando processamento...")
oProcess:SetRegua2(nTotRegs+1)
oProcess:IncRegua2("")

dbGotop()

While !Eof()

	aDadosAuto:= {  {'N3_FILIAL'	,(cAliasTMP2)->PA4_EMPORI	, Nil},;	// Filial
					{'N3_CBASE'		,(cAliasTMP2)->N1_CBASE		, Nil},;	// Codigo base do ativo
					{'N3_ITEM'  	,(cAliasTMP2)->N1_ITEM		, Nil},;	// Item sequencial do codigo bas do ativo
					{'N4_DATA'  	,dDataBase					, Nil},;	// Data da Transferencia
					{'N3_CUSTBEM' 	,(cAliasTMP2)->PA4_CC   	, Nil},;	// Centro de Custo de Despesa
					{'N3_SUBCCON' 	,(cAliasTMP2)->PA4_ITEM 	, Nil},;	// Item Contabil da Despesa
					{'N3_CLVLCON' 	,(cAliasTMP2)->PA4_CLVL    	, Nil}}		// Classe de Valor da Despesa

	cFilAnt := (cAliasTMP2)->PA4_EMPORI
	MSExecAuto({|x, y, z| AtfA060(x, y, z)},aDadosAuto, 4)
	cFilAnt := __cFilOri

	If lMsErroAuto
		_cArqAuto 	:= NomeAutoLog()
		//MostraErro()
		_cErroAuto 	:= MemoRead(_cArqAuto)
		_cErroAuto 	:= Iif(Empty(_cErroAuto),"Erro na Execu็ใo do MsExecauto. Verificar log.",_cErroAuto)

		lErro := .T.
		dbSelectArea(cAliasTmp)

		nLinMsg := mlCount(_cErroAuto, nTamLin) //Total de linhas da Mensagem

   	    For nContador := 1 To nLinMsg
   	    	RecLock(cAliasTmp,.T.)
				(cAliasTmp)->EMISSAO 	:= Stod((cAliasTMP2)->PA4_EMISSAO)
				(cAliasTmp)->COD_BARRA 	:= (cAliasTMP2)->PA4_CODBAR
				(cAliasTmp)->DESCR		:= (cAliasTMP2)->N1_DESCRIC
				(cAliasTmp)->CONTEUDO 	:= Memoline(_cErroAuto,nTamLin,1)
				(cAliasTmp)->MSG		:=  IIf(!Empty(Alltrim(Memoline(_cErroAuto,nTamlin,nContador))),Alltrim(Memoline(_cErroAuto,nTamlin,nContador)),' ') //)+Space(1)+Alltrim(Memoline(_cErroAuto,132,3))
			MsUnlock()
		Next

	Else

		dbSelectArea("PA4")
		dbSetOrder(1)
		dbGoto((cAliasTMP2)->RECNOPA4)

		xConcilia()

		nProcRegs++

	EndIf

	oProcess:IncRegua1("Processando item: "+CValToChar(nProcRegs)+" / "+CValToChar(nTotRegs))
	oProcess:IncRegua2("Codigo de Barra: "+(cAliasTMP2)->PA4_CODBAR)

	DbSelectArea(cAliasTMP2)
	dbSkip()

	aDadosAuto  := {}
	lMsErroAuto := .f.

EndDo

If lErro
	//Chama Impressao do Relatorio de Inconsistencias
	If ApMsgYesNo("Ocorreram inconsist๊ncias durante a transfer๊ncia dos dados, deseja imprimir o log?","Log de Inconsist๊ncias")
		xRelInc(cAliasTmp,"Inconsist๊ncias da Transfer๊ncia")
	Endif
Endif

If Select(cAliasTMP) > 0
	dbSelectArea(cAliasTMP)
	dbCloseArea()
Endif

If Select(cAliasTMP2) > 0
	dbSelectArea(cAliasTMP2)
	dbCloseArea()
Endif

Return