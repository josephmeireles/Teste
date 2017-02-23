#INCLUDE "Topconn.ch"
#INCLUDE "Protheus.ch"

/*/{Protheus.doc} ABFATR06
//TODO Descrição auto-gerada.
@author TOTVS
@since 27/10/2016
@version undefined

@type function
/*/
User Function ABFATR06()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declaracao de variaveis                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private oReport  := Nil
Private oSection1:= Nil
Private oSection2:= Nil
Private cPerg 	 := PadR ("RFATR06", Len (SX1->X1_GRUPO))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao e apresentacao das perguntas      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

AjustaSX1(cPerg)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definicoes/preparacao para impressao      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport := ReportDef(cPerg)
oReport	:PrintDialog()

Return Nil

/*/{Protheus.doc} ReportDef
//TODO Descrição auto-gerada.
@author TOTVS
@since 27/10/2016
@version undefined

@type function
/*/
Static Function ReportDef()

Local oReport := Nil
Local oBreak1
Local oFunction

oReport := TReport():New("RFATR06","Missões e Feiras",cPerg,{|oReport| PrintReport(oReport)},"O Relatório de Missões e Feiras tem como objetivo relacionar os eventos,clientes e valores referente as notas emitidas para cada cliente.")
oReport:SetPortrait()
//oReport:SetLandscape(.T.)
//oReport:SetTotalInLine(.T.)

oSection1:= TRSection():New(oReport, "Eventos", {"QRY"}, ,.T., .T.)

TRCell():New(oSection1, "CLIENTE"    , "QRY", RetTitle("A1_COD"	), PesqPict("SA1","A1_COD"	),TamSx3("A1_COD"	)[1],/*lPixel*/,{||QRY->CLIENTE})
TRCell():New(oSection1, "NOMECLI"    , "QRY", RetTitle("A1_NOME"	), PesqPict("SA1","A1_NOME"	),TamSx3("A1_NOME"	)[1],/*lPixel*/,{||QRY->NOMECLI})
TRCell():New(oSection1, "NOTAFIS"    , "QRY", RetTitle("F2_DOC"	), PesqPict("SF2","F2_DOC"	),TamSx3("F2_DOC"	)[1],/*lPixel*/,{||QRY->NOTAFIS})
TRCell():New(oSection1, "VLRMOES"    , "QRY", RetTitle("C5_MOEDAES"	),PesqPict("SC5","C5_MOEDAES" ),TamSx3("C5_MOEDAES"	)[1],/*lPixel*/,{||QRY->VLRMOES}) 
TRCell():New(oSection1, "VALOR"      , "QRY", "Valor",PesqPict("SE1","E1_VALOR"	 ),TamSx3("E1_VALOR"	)[1],/*lPixel*/,{||QRY->VALOR})
TRCell():New(oSection1, "EMISSAO"    , "QRY", RetTitle("E1_EMISSAO"	),PesqPict("SE1","E1_EMISSAO"),TamSx3("E1_EMISSAO" )[1],/*lPixel*/,{||QRY->EMISSAO})
TRCell():New(oSection1, "VENCTO"     , "QRY", RetTitle("E1_VENCTO"	),PesqPict("SE1","E1_VENCTO" ),TamSx3("E1_VENCTO" )[1],/*lPixel*/,{||QRY->VENCTO})  
TRCell():New(oSection1, "VL RECEBIDO", "QRY", "Valor",PesqPict("SE1","E1_VALOR"	 ),TamSx3("E1_VALOR"	)[1],/*lPixel*/,{||QRY->VLRECBD})
TRCell():New(oSection1, "VL RECEBER" , "QRY", "Valor",PesqPict("SE1","E1_VALOR"	 ),TamSx3("E1_VALOR"	)[1],/*lPixel*/,{||QRY->VLRECBR})

//Quebra do relatório quando mudar o Data de vencimento
oBreak1 := TRBreak():New(oSection1,oSection1:Cell("VENCTO"),"Subtotal por Vencimento")

TRFunction():New(oSection1:Cell("VALOR") ,NIL,"SUM",oBreak1,"Total R$",PesqPict("SE1","E1_VALOR"),/*uFormula*/,.F.,.T.,.F.,oSection1)

oReport:SetTotalInLine(.F.)  // Define se os totalizadores serão impressos em linha ou coluna   .T. - Linha   .F. - Coluna

//Aqui, farei uma quebra  por seção
oSection1:SetPageBreak(.F.)          // Define se salta a página na quebra de seção
oSection1:SetTotalText("")           // Define o texto que será impresso antes da impressão dos totalizadores

//oSection2:SetHeaderSection(.T.)	//Imprime o cabeçalho da secao
//oSection2:SetNoFilter("")

Return(oReport)


/*/{Protheus.doc} PrintReport
//TODO Descrição auto-gerada.
@author TOTVS
@since 27/10/2016
@version undefined
@param oReport, object, descricao
@type function
/*/
Static Function PrintReport(oReport)

Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(2)
Local oSection3 := oReport:Section(3)
Local cQuery    := ""
Local _cEvento  := ""
Local _cCliente := ""

Pergunte(cPerg,.F.)

cQuery += " SELECT " + CRLF
cQuery += "     ZZ1.ZZ1_COD AS EVENTO, " + CRLF
cQuery += "     ZZ1.ZZ1_DESC AS NOMEVEN, " + CRLF
cQuery += "     SA1.A1_COD AS CLIENTE, " + CRLF
cQuery += "     SA1.A1_NOME AS NOMECLI, " + CRLF
cQuery += "     SA1.A1_CGC AS CNPJ, " + CRLF
cQuery += "     SE1.E1_EMISSAO AS EMISSAO, " + CRLF
cQuery += "     SE1.E1_VALOR AS VALOR, " + CRLF
cQuery += "     SE1.E1_VENCTO AS VENCTO " + CRLF
cQuery += " FROM " + RetSqlName("ZZ1") + " ZZ1, " + CRLF
cQuery +=            RetSqlName("SA1") + " SA1, " + CRLF
cQuery +=            RetSqlName("SC5") + " SC5, " + CRLF
cQuery +=            RetSqlName("SE1") + " SE1 " + CRLF
cQuery += " WHERE SE1.E1_VENCTO BETWEEN '" + Dtos(mv_par01) + "' AND '" + Dtos(mv_par02) + "' " + CRLF
cQuery += "   AND ZZ1.ZZ1_FILIAL = '" + xFilial ("ZZ1") + "' " + CRLF
cQuery += "   AND SA1.A1_FILIAL = '" + xFilial ("SA1") + "' " + CRLF
cQuery += "   AND SC5.C5_FILIAL = '" + xFilial ("SC5") + "' " + CRLF
cQuery += "   AND SE1.E1_FILIAL = '" + xFilial ("SE1") + "' " + CRLF
cQuery += "   AND ZZ1.ZZ1_COD = SC5.C5_EVENTO " + CRLF
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
cQuery += " ORDER BY SE1.E1_FILIAL,SE1.E1_VENCTO " + CRLF     ////  Data  de vencimento dos títulos
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

While !Eof()
	
	_dEmissao := SUBSTR(QRY->EMISSAO,7,2)+"/"+SUBSTR(QRY->EMISSAO,5,2)+"/"+SUBSTR(QRY->EMISSAO,1,4)
	_dVencto  := SUBSTR(QRY->VENCTO,7,2)+"/"+SUBSTR(QRY->VENCTO,5,2)+"/"+SUBSTR(QRY->VENCTO,1,4)
	
	If oReport:Cancel()
		Exit
	EndIf
	
	IncProc("Imprimindo Eventos "+alltrim(QRY->EVENTO))
	
	If QRY->VENCTO == _dVencimento
		oSection1:Init()
		oReport:IncMeter()
		
		//imprimo a primeira seção
		oSection1:Cell("EVENTO") :SetValue(QRY->EVENTO)
		oSection1:Cell("NOMEVEN"):SetValue(QRY->NOMEVEN)
		oSection1:Cell("CLIENTE"):SetValue(QRY->CLIENTE)
		oSection1:Cell("CNPJ")   :SetValue(QRY->CNPJ)
		oSection1:Cell("NOMECLI"):SetValue(QRY->NOMECLI)
		oSection1:Cell("EMISSAO"):SetValue(_dEmissao)  // QRY->EMISSAO
		oSection1:Cell("VALOR")  :SetValue(QRY->VALOR)
		oSection1:Cell("VENCTO") :SetValue(_dVencto) //QRY->VENCTO
		oSection1:Printline()
		
	EndIf
	
	QRY->(dbSkip())
	
	If QRY->VENCTO <> _dVencimento
		//finalizo a primeira seção
		oSection1:Finish()
		
		_dVencimento := QRY->VENCTO
		
	EndIf
	
Enddo

//finalizo a primeira seção
oSection1:Finish()

Return Nil


/*/{Protheus.doc} AjustaSX1
//TODO Descrição auto-gerada.
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

Aadd(aRegs,{"Evento de?                "   ,"Evento de?                "   ,"Evento de?                "   ,"mv_ch1","C",TamSx3 ("ZZ1_COD")[1],0,0,"G","","MV_PAR01","","","","","","","","","ZZ1","",""})
Aadd(aRegs,{"Evento até?               "   ,"Evento até?               "   ,"Evento até?               "   ,"mv_ch2","C",TamSx3 ("ZZ1_COD")[1],0,0,"G","","MV_PAR02","","","","","","","","","ZZ1","",""})
Aadd(aRegs,{"Faixa de Exportação de?   "   ,"Faixa de Exportação de?   "   ,"Faixa de Exportação de?   "   ,"mv_ch3","C",TamSx3 ("A1_COD") [1],0,0,"G","","MV_PAR03","","","","","","","","","SA1","",""})
Aadd(aRegs,{"Faixa de Exportação até?  "   ,"Faixa de Exportação até?  "   ,"Faixa de Exportação até?  "   ,"mv_ch4","C",TamSx3 ("A1_COD") [1],0,0,"G","","MV_PAR04","","","","","","","","","SA1","",""})
Aadd(aRegs,{"Cliente participante?     "   ,"Cliente participante?     "   ,"Cliente participante?     "   ,"mv_ch5","N",1                    ,0,1,"C","","MV_PAR05","1-Sim" ,"","","2-Não","","","3-Todos","","",""})

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
