#INCLUDE "Topconn.ch"
#INCLUDE "Protheus.ch"

/*/{Protheus.doc} ABFATR04
//TODO Descri豫o auto-gerada.
@author TOTVS
@since 09/11/2016
@version undefined

@type function
/*/
User Function ABFATR04()

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿏eclaracao de variaveis                   �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Private oReport  := Nil
Private oSection1:= Nil
Private oSection2:= Nil
Private cPerg 	 := PadR ("RFATR04", Len (SX1->X1_GRUPO))

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿎riacao e apresentacao das perguntas      �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸

AjustaSX1(cPerg)

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿏efinicoes/preparacao para impressao      �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
oReport := ReportDef(cPerg)
oReport	:PrintDialog()

Return Nil


/*/{Protheus.doc} ReportDef
//TODO Descri豫o auto-gerada.
@author TOTVS
@since 13/02/2017
@version undefined

@type function
/*/

Static Function ReportDef()

Local oReport := Nil
Local oBreak1
Local oFunction

oReport := TReport():New("RFATR04","Faturamento do Evento por Vencimento - RFEV",cPerg,{|oReport| PrintReport(oReport)},"O Relat�rio de Faturamento do Evento por Vencimento - RFEV tem como objetivo relacionar os eventos,clientes e valores referente as notas emitidas para cada cliente.")
oReport:SetPortrait()
//oReport:SetLandscape(.T.)
//oReport:SetTotalInLine(.T.)

///TRCell():New(oSection1,"FILIAL","TRBIMP","FILIAL", "",03,,,/*ALINHAMENTO DA CELULA*/,,/*ALINHAMENTO DO CABECALHO*/)

oSection1:= TRSection():New(oReport, "Eventos", {"QRY"}, ,.T., .T.)
TRCell():New(oSection1, "EVENTO"     , "QRY", "Evento", PesqPict("ZZ1","ZZ1_COD" ),TamSx3("ZZ1_COD"	)[1],/*lPixel*/,{||QRY->EVENTO})
TRCell():New(oSection1, "NOMEVEN"    , "QRY", RetTitle("ZZ1_DESC"	), PesqPict("ZZ1","ZZ1_DESC"),TamSx3("ZZ1_DESC"	)[1],/*lPixel*/,{||QRY->NOMEVEN})

oSection2:= TRSection():New(oReport, "Lan�amentos", {"QRY"}, ,.T., .T.)

TRCell():New(oSection2, "CLIENTE"    , "QRY", RetTitle("A1_COD"	), PesqPict("SA1","A1_COD"	),TamSx3("A1_COD"	)[1],/*lPixel*/,{||QRY->CLIENTE})
TRCell():New(oSection2, "CNPJ"       , "QRY", RetTitle("A1_CGC"	), PesqPict("SA1","A1_CGC"	),TamSx3("A1_CGC"	)[1],/*lPixel*/,{||QRY->CNPJ})
TRCell():New(oSection2, "NOMECLI"    , "QRY", RetTitle("A1_NOME"	), PesqPict("SA1","A1_NOME"	),TamSx3("A1_NOME"	)[1],/*lPixel*/,{||QRY->NOMECLI})
TRCell():New(oSection2, "EMISSAO"    , "QRY", RetTitle("E1_EMISSAO"	),PesqPict("SE1","E1_EMISSAO"),TamSx3("E1_EMISSAO" )[1],/*lPixel*/,{||QRY->EMISSAO})
TRCell():New(oSection2, "VALOR"      , "QRY", "Valor",PesqPict("SE1","E1_VALOR"	 ),TamSx3("E1_VALOR"	)[1],/*lPixel*/,{||QRY->VALOR})
TRCell():New(oSection2, "VENCTO"     , "QRY", RetTitle("E1_VENCTO"	),PesqPict("SE1","E1_VENCTO" ),TamSx3("E1_VENCTO" )[1],/*lPixel*/,{||QRY->VENCTO})


//Quebra do relat�rio quando mudar o Data de vencimento
oBreak1 := TRBreak():New(oSection1,oSection1:Cell("EVENTO"),"Subtotal por Evento")

///TRFUNCTION():New(oCell,cName,cFunction,oBreak,cTitle,cPicture,uFormula,lEndSection,lEndReport,lEndPage,oParent,bCondition,lDisable,bCanPrint)

TRFunction():New(oSection2:Cell("VALOR") ,NIL,"SUM",oBreak1,"Total R$",PesqPict("SE1","E1_VALOR"),/*uFormula*/,.F.,.T.,.F.,oSection1)

oReport:SetTotalInLine(.F.)  // Define se os totalizadores ser�o impressos em linha ou coluna   .T. - Linha   .F. - Coluna

//Aqui, farei uma quebra  por se豫o
oSection1:SetPageBreak(.F.)          // Define se salta a p�gina na quebra de se豫o
oSection1:SetTotalText("")           // Define o texto que ser� impresso antes da impress�o dos totalizadores

//oSection2:SetHeaderSection(.T.)	//Imprime o cabe�alho da secao
//oSection2:SetNoFilter("")

Return(oReport)


/*/{Protheus.doc} PrintReport
//TODO Descri豫o auto-gerada.
@author TOTVS
@since 13/02/2017
@version undefined
@param oReport, object, descricao
@type function
/*/
Static Function PrintReport(oReport)

Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(2)
Local _cEvento  := ""
Local _cCliente := ""
Local cQuery    := ""
Pergunte(cPerg,.F.)

cQuery := " SELECT " + CRLF
cQuery += "     ZZ1.ZZ1_COD EVENTO, " + CRLF
cQuery += "     ZZ1.ZZ1_DESC NOMEVEN, " + CRLF
cQuery += "     SA1.A1_COD CLIENTE, " + CRLF
cQuery += "     SA1.A1_NOME NOMECLI, " + CRLF
cQuery += "     SA1.A1_CGC CNPJ, " + CRLF
cQuery += "     SE1.E1_EMISSAO EMISSAO, " + CRLF
cQuery += "     SE1.E1_VALOR VALOR, " + CRLF
cQuery += "     SE1.E1_VENCTO VENCTO " + CRLF
cQuery += " FROM " + RetSqlName("ZZ1") + " ZZ1, " + CRLF
cQuery +=            RetSqlName("SA1") + " SA1, " + CRLF
cQuery +=            RetSqlName("SC5") + " SC5, " + CRLF
cQuery +=            RetSqlName("SE1") + " SE1 " + CRLF
cQuery += " WHERE SE1.E1_VENCTO BETWEEN '" + Dtos(mv_par01) + "' AND '" + Dtos(mv_par02) + "' " + CRLF
cQuery += "   AND ZZ1.ZZ1_FILIAL = '" + xFilial ("ZZ1") + "' " + CRLF
cQuery += "   AND SA1.A1_FILIAL = '" + xFilial ("SA1") + "' " + CRLF
cQuery += "   AND SC5.C5_FILIAL = '" + xFilial ("SC5") + "' " + CRLF
cQuery += "   AND SE1.E1_FILIAL = '" + xFilial ("SE1") + "' " + CRLF
cQuery += "   AND ZZ1.ZZ1_COD = SC5.C5_XEVENTO " + CRLF
cQuery += "   AND SC5.C5_NOTA = SE1.E1_NUM " + CRLF
cQuery += "   AND SC5.C5_SERIE = SE1.E1_PREFIXO " + CRLF
cQuery += "   AND SC5.C5_CLIENTE = SE1.E1_CLIENTE " + CRLF
cQuery += "   AND SC5.C5_CLIENTE = SA1.A1_COD " + CRLF
cQuery += "   AND SC5.C5_LOJACLI = SE1.E1_LOJA " + CRLF
cQuery += "   AND SC5.C5_LOJACLI = SA1.A1_LOJA  " + CRLF
cQuery += "   AND ZZ1.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "   AND SA1.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "   AND SC5.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "   AND SE1.D_E_L_E_T_ = ' ' " + CRLF
cQuery += " ORDER BY SE1.E1_FILIAL,SE1.E1_VENCTO,ZZ1.ZZ1_COD " + CRLF     ////  Data  de vencimento dos t�tulos
cQuery := ChangeQuery(cQuery)

If Select("QRY") > 0
	Dbselectarea("QRY")
	QRY->(DbClosearea())
EndIf

TcQuery cQuery New Alias "QRY"

dbSelectArea("QRY")
QRY->(dbGoTop())

oReport:SetMeter(QRY->(LastRec()))

_dVencimento := QRY->VENCTO
_cEvento     := QRY->EVENTO

oSection1:Init()
oReport:IncMeter()

//imprimo a primeira se豫o
oSection1:Cell("EVENTO"):SetValue(QRY->EVENTO)
oSection1:Cell("NOMEVEN"):SetValue(QRY->NOMEVEN)
oSection1:Printline()

//inicializo a segunda se豫o
oSection2:init()
oReport:IncMeter()


While !Eof()
	
	_dEmissao := SUBSTR(QRY->EMISSAO,7,2)+"/"+SUBSTR(QRY->EMISSAO,5,2)+"/"+SUBSTR(QRY->EMISSAO,1,4)
	_dVencto  := SUBSTR(QRY->VENCTO,7,2)+"/"+SUBSTR(QRY->VENCTO,5,2)+"/"+SUBSTR(QRY->VENCTO,1,4)
	
	If oReport:Cancel()
		Exit
	EndIf
	
	IncProc("Imprimindo Eventos "+alltrim(QRY->EVENTO))
	
	If QRY->EVENTO == _cEvento
		
		
		//inicializo a segunda se豫o
		oSection2:init()
		oReport:IncMeter()
		
		_dEmissao := SUBSTR(QRY->EMISSAO,7,2)+"/"+SUBSTR(QRY->EMISSAO,5,2)+"/"+SUBSTR(QRY->EMISSAO,1,4)
		_dVencto  := SUBSTR(QRY->VENCTO,7,2)+"/"+SUBSTR(QRY->VENCTO,5,2)+"/"+SUBSTR(QRY->VENCTO,1,4)
		
		oSection2:Cell("CLIENTE"):SetValue(QRY->CLIENTE)
		oSection2:Cell("CNPJ")   :SetValue(QRY->CNPJ)
		oSection2:Cell("NOMECLI"):SetValue(QRY->NOMECLI)
		oSection2:Cell("EMISSAO"):SetValue(_dEmissao)  // QRY->EMISSAO
		oSection2:Cell("VALOR")  :SetValue(QRY->VALOR)
		oSection2:Cell("VENCTO") :SetValue(_dVencto) //QRY->VENCTO
		oSection2:Printline()
		
		
	Else
		oSection1:Finish()
		oSection2:Finish()
		
		oReport:skipLine()  // Salta uma linha
		oReport:ThinLine() 	// Imprimo uma linha para separar um EVENTO de outro
		oReport:skipLine()  // Salta uma linha
		
		//inicializo a primeira se豫o
		oSection1:Init()
		oReport:IncMeter()
		
		//imprimo a primeira se豫o
		oSection1:Cell("EVENTO"):SetValue(QRY->EVENTO)
		oSection1:Cell("NOMEVEN") :SetValue(QRY->NOMEVEN)
		oSection1:Printline()
		
		//inicializo a segunda se豫o
		oSection2:init()
		oReport:IncMeter()
		
		_dEmissao := SUBSTR(QRY->EMISSAO,7,2)+"/"+SUBSTR(QRY->EMISSAO,5,2)+"/"+SUBSTR(QRY->EMISSAO,1,4)
		_dVencto  := SUBSTR(QRY->VENCTO,7,2)+"/"+SUBSTR(QRY->VENCTO,5,2)+"/"+SUBSTR(QRY->VENCTO,1,4)
		
		///	IncProc("Imprimindo lan�amentos : "+alltrim(QRY->NOMECLI))
		
		oSection2:Cell("CLIENTE"):SetValue(QRY->CLIENTE)
		oSection2:Cell("CNPJ")   :SetValue(QRY->CNPJ)
		oSection2:Cell("NOMECLI"):SetValue(QRY->NOMECLI)
		oSection2:Cell("EMISSAO"):SetValue(_dEmissao)  // QRY->EMISSAO
		oSection2:Cell("VALOR")  :SetValue(QRY->VALOR)
		oSection2:Cell("VENCTO") :SetValue(_dVencto) //QRY->VENCTO
		oSection2:Printline()
		
		//finalizo a segunda se豫o
		oSection2:Finish()
		
	EndIf
	
	_cEvento 	:= QRY->EVENTO
	_cCliente   := QRY->CLIENTE
	
	QRY->(dbSkip())
	
	If QRY->EVENTO <> _cEvento
		//finalizo a primeira se豫o
		oSection1:Finish()
	EndIf
	
Enddo

//finalizo a primeira se豫o
oSection1:Finish()

Return Nil


/*/{Protheus.doc} AjustaSX1
//TODO Descri豫o auto-gerada.
@author TOTVS
@since 27/10/2016
@version undefined
@param cPerg, characters, descricao
@type function
/*/
Static Function AjustaSX1(cPerg)

Local aArea    := GetArea()
Local nX
Local aRegs	   := {}
Local cOrdem    

AAdd(aRegs,{"Vencimento de?" ,"Vencimento de?" ,"Vencimento de?" ,"mv_ch1","D",TAMSX3("E1_VENCTO")[1],0,2,"G","","mv_par01","","","","","","","","","",""})
AAdd(aRegs,{"Vencimento at�?","Vencimento at�?","Vencimento at�?","mv_ch2","D",TAMSX3("E1_VENCTO")[1],0,2,"G","","mv_par02","","","","","","","","","",""})

dbSelectArea("SX1")
dbSetOrder(1)
For nX:=1 to Len(aRegs)
	cOrdem := StrZero(nX+00,2)
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
