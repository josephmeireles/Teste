#INCLUDE "Topconn.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "Rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AFINR04 ºAutor  ³ TOTVS              º Data ³ 14/12/2016  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Impressão do Relatório de Ordem de Pagamentos              º±±
±±º          ³ MIT FIN004                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ APEX                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function AFINR04()

Local oDlg    := NIL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Desenha a tela de impressão³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

@ 096,042 TO 323,505 DIALOG oDlg TITLE "Relatório de Ordem de Pagamento"
@ 008,010 TO 084,222
@ 018,020 SAY "Relatório de Ordem de Pagamento"
@ 030,020 SAY "Será Gerada de Acordo com a Selecao de Parâmetros."
///@ 095,130 BUTTON "Gerar Ordem"     SIZE 45,10 ACTION Processa( {|| Imprime() }, "Processando..." )
///@ 095,73  BUTTON "Parâmetros"  SIZE 45,10 ACTION Processa( {|| ReportDef() }, "Processando..." )
@ 095,130  BUTTON "Gerar Ordem"  SIZE 45,10 ACTION Processa( {|| ReportDef() }, "Processando..." )
@ 095,187 BMPBUTTON TYPE 2                      ACTION Close(oDlg)

ACTIVATE DIALOG oDlg CENTERED

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ReportDef ºAutor  ³ TOTVS              º Data ³ 27/10/2016  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Definição da estrutura do relatório.                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ APEX                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef()

Local aArea		   := GetArea()
Local aAreaA2	   := SA2->(GetArea())
Local aAreaE2	   := SE2->(GetArea())
Local aAreaA6	   := SA6->(GetArea())
Local aAreaF1	   := SA6->(GetArea())
Local aAreaD1	   := SA6->(GetArea())
Local cQuery       := ""
Local _dData	   := AllTrim(Str(Day(dDataBase),2))+' de '+ AllTrim(MesExtenso(dDataBase))+' de '+AllTrim(Str(Year(dDataBase), 4))
Local _cNomeUser   := UsrFullName(__cUserID)
Local _cEvento     := ""
Local _cCliente    := ""
Local _dDTEmissao  := ""
Local _dEmissao    := ""
Local _dVencto     := ""
Local _cBanco	   := MV_PAR05
Local _cAgencia    := MV_PAR06
Local _cConta      := MV_PAR07 
Local _cNomeBco    := ""
Local _cPrefixox   := ""
Local _cTitulo	   := ""
Local _cNum	       := ""
Local _cParcela    := ""
Local _dVencReal   := ""
Local _cLoja	   := ""
Local _nValor	   := 0   
Local _nValIOF     := 0
Local _nValIR      := 0   
Local _nAlIOF      := MV_PAR06  
Local _nAlIR       := MV_PAR07 
Local _nAlipd      := MV_PAR08
Local _nTxFixa     := MV_PAR09 
Local _cRevisado   := MV_PAR10
Local _cGerente    := MV_PAR11

Private cPerg      := PadR ("AFINR04", Len (SX1->X1_GRUPO))

Private hWord
Private cPathDot 		:= "\\10.10.1.200\totvs$\Microsiga\Protheus_Data\Dot\Ordempg.dot" /* C:\APEX\cobranca.dot */

// Pergunta na Tela, para Seleção de Parâmetros.
AjustaSX1(cPerg)
Pergunte(cPerg, .T. )


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona as tabelas                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cQuery += " SELECT " + CRLF
cQuery += "     SA1.A1_COD AS CLIENTE, " + CRLF
cQuery += "     SA1.A1_NOME AS NOMECLI, " + CRLF
cQuery += "     SE2.E2_NUM AS NUMERO, " + CRLF
cQuery += "     SE2.E2_EMISSAO AS EMISSAO, " + CRLF
cQuery += "     SE2.E2_VALOR AS VALOR, " + CRLF
cQuery += "     SE2.E2_VENCTO AS VENCTO, " + CRLF
cQuery += "     SD1.D1_COD AS PRODUTO, " + CRLF
cQuery += "     SD1.D1_ITEM AS ITEM " + CRLF  
cQuery += "     SC5.C5_XEVENTO AS EVENTO " + CRLF
cQuery += "     SC5.C5_XVNMES AS VNMES " + CRLF

cQuery += " FROM " + RetSqlName("SA1") + " SA1, " + CRLF
cQuery +=            RetSqlName("SE2") + " SE2, " + CRLF
cQuery +=            RetSqlName("SC5") + " SC5, " + CRLF
cQuery +=            RetSqlName("SD1") + " SD1, " + CRLF 
cQuery +=            RetSqlName("SF1") + " SF1 " + CRLF

cQuery += " WHERE SE2.E2_FORNECE BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' " + CRLF
cQuery += "   AND SE2.E2_EMISSAO BETWEEN '" + Dtos(mv_par03) + "' AND '" + Dtos(mv_par04) + "' " + CRLF
cQuery += "   AND SA1.A1_FILIAL = '" + xFilial ("SA1") + "' " + CRLF
cQuery += "   AND SE2.E2_FILIAL = '" + xFilial ("SE2") + "' " + CRLF
cQuery += "   AND SC5.C5_FILIAL = '" + xFilial ("SC5") + "' " + CRLF
cQuery += "   AND SD1.D1_FILIAL = '" + xFilial ("SD1") + "' " + CRLF
cQuery += "   AND SF1.F1_FILIAL = '" + xFilial ("SF1") + "' " + CRLF

cQuery += "   AND SE2.E2_FORNECE = SF1.F1_FORNECE " + CRLF
cQuery += "   AND SF1.F1_DOC = SD1.D1_DOC " + CRLF
cQuery += "   AND SE2.E2_NUM = SF1.F1_DOC " + CRLF

cQuery += "   AND SA1.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "   AND SE2.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "   AND SD1.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "   AND SF1.D_E_L_E_T_ = ' ' " + CRLF

cQuery += " ORDER BY SE2.E2_FILIAL,SE2.E2_EMISSAO " + CRLF     ////  Data  da emissao dos títulos
cQuery := ChangeQuery(cQuery)

If Select("QRY") > 0
	Dbselectarea("QRY")
	QRY->(DbClosearea())
EndIf

TcQuery cQuery New Alias "QRY"

dbSelectArea("SA6")
dbSetOrder(1)

If dbSeek(xfilial("SA6")+_cBanco+_cAgencia+_cConta)
   _cNomeBco := A6_NOME
EndIf

dbSelectArea("QRY")
QRY->(dbGoTop())


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se o arquivo .dot está no local correto.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If !File(cPathDot)
	MsgBox ("Arquivo Ordempg.dot nao encontrado.","ERRO","STOP")
	Return(.F.)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem das variaveis dos itens. No documento word estas variaveis serao criadas ³
//³dinamicamente da seguinte forma:                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

hWord    := OLE_CreateLink()
                                
While !eof()  

    _nValIOF := (QRY->VALOR*_nAlIOF)/100   
    _nValIR  := (QRY->VALOR*_nAlIR)/100              

	OLE_NewFile(hWord, cPathDot ) // Abre o arquivo dot e comeca gravacao 
	
	OLE_SetDocumentVar(hWord, "wor_data"        , _dData) 
	OLE_SetDocumentVar(hWord, "wor_cNomeUser" 	, _cNomeUser) 
	OLE_SetDocumentVar(hWord, "wor_cRevisado" 	, _cRevisado)
	OLE_SetDocumentVar(hWord, "wor_cGerente"   	, _cGerente)
	OLE_SetDocumentVar(hWord, "wor_cCod"     	, QRY->CLIENTE)
	OLE_SetDocumentVar(hWord, "wor_cNome"   	, QRY->NOMECLI)
	OLE_SetDocumentVar(hWord, "wor_nVlror"  	, alltrim(transform(QRY->VNMES, "@E 9,999,999,999,999.99")))
	OLE_SetDocumentVar(hWord, "wor_nVlrea"      , alltrim(transform(QRY->VALOR, "@E 9,999,999,999,999.99"))) 
	OLE_SetDocumentVar(hWord, "wor_nAlIOF"      , alltrim(transform(_nAlIOF   , "@E 9,999.99"))) 
	OLE_SetDocumentVar(hWord, "wor_nAlIR"       , alltrim(transform(_nAlIR    , "@E 9,999.99")))
	OLE_SetDocumentVar(hWord, "wor_nAlipd"      , alltrim(transform(_nAlipd   , "@E 9,999.99")))  
	OLE_SetDocumentVar(hWord, "wor_nValIOF"     , alltrim(transform(_nValIOF  , "@E 9,999,999.99")))
    OLE_SetDocumentVar(hWord, "wor_nValIR"      , alltrim(transform(_nValIR   , "@E 9,999,999.99")))
	OLE_SetDocumentVar(hWord, "wor_nTxFixa"     , alltrim(transform(_nTxFixa  , "@E 9,999.99"))) 
	
///	OLE_SetDocumentVar(hWord, "wor_Banco"     , _cBanco)
/// OLE_SetDocumentVar(hWord, "wor_Agencia"   , _cAgencia)
	OLE_SetDocumentVar(hWord, "wor_Conta"     , _cConta)
    OLE_SetDocumentVar(hWord, "wor_Banco"     , _cNomeBco+_cAgencia)

	OLE_SetDocumentVar(hWord, "wor_cIdentif"  , QRY->NUMERO)
	OLE_SetDocumentVar(hWord, "wor_emissao"   , QRY->EMISSAO)
	
	OLE_UpdateFields(hWord) //Atualiza os campos dentro do word
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Salva o documento			         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If MsgYesNo("Salvar o Documento ?")
		
		OLE_SaveFile( hWord )
		MsgInfo("Documento Salvo com Sucesso!", "Atenção")
		
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Fecha o Word e Corta o Link			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	OLE_CloseFile( hWord )   
	
	OLE_CloseLink( hWord )
	
	DbSkip()
	
End

///OLE_CloseLink( hWord )


RestArea(aAreaA2)
RestArea(aAreaE2)
RestArea(aAreaA6)
RestArea(aAreaD1)
RestArea(aAreaF1)
RestArea(aArea)

Return nil

    
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

Aadd(aRegs,{"Cliente?        "   ,"Cliente?        ","Cliente?        ","mv_ch1","C",TamSx3 ("A1_COD")[1]    ,0,0,"G","","MV_PAR01","","","","","","","","","SA1",""})
Aadd(aRegs,{"Vencimento de?  "   ,"Vencimento de?  ","Vencimento de?  ","mv_ch2","D",TamSx3 ("E2_VENCTO")[1] ,0,0,"G","","MV_PAR02","","","","","","","","","","",""})
Aadd(aRegs,{"Vencimento até? "   ,"Vencimento até? ","Vencimento até? ","mv_ch3","D",TamSx3 ("E2_VENCTO")[1] ,0,0,"G","","MV_PAR03","","","","","","","","","","",""})
AADD(aRegs,{"Banco ?         "   ,"Banco ?         ","Banco ?         ","mv_ch4","C",TamSX3 ("A6_COD")[1]    ,0,0,"G","","MV_PAR04","","","","","","","","","","",""})
AADD(aRegs,{"Agência ?       "   ,"Agência ?       ","Agência ?       ","mv_ch5","C",TamSX3 ("A6_AGENCIA")[1],0,0,"G","","MV_PAR05","","","","","","","","","SA6",""})
AADD(aRegs,{"Aliquota de IOF:"   ,"Aliquota de IOF?","Aliquota de IOF?","mv_ch6","N",5                       ,2,0,"G","","mv_par06","","","","","","","","","","",""})
AADD(aRegs,{"Aliquota de IR: "   ,"Aliquota de IR? ","Aliquota de IR? ","mv_ch7","N",5                       ,2,0,"G","","mv_par07","","","","","","","","","","",""})
AADD(aRegs,{"Aliq.por dentro:"   ,"Aliq.por dentro:","Aliq.por dentro:","mv_ch8","N",5                       ,2,0,"G","","mv_par08","","","","","","","","","","",""})
AADD(aRegs,{"Taxa fixa?      "   ,"Taxa fixa?      ","Taxa fixa?      ","mv_ch9","N",5                       ,2,0,"G","","mv_par09","","","","","","","","","","",""})
AADD(aRegs,{"Revisado por:   "   ,"Revisado por:   ","Revisado por:   ","mv_cha","C",40                      ,0,0,"G","","MV_PAR10","","","","","","","","","","",""})
AADD(aRegs,{"Gerente:        "   ,"Gerente:        ","Gerente:        ","mv_chb","C",40                      ,0,0,"G","","MV_PAR11","","","","","","","","","","",""})

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

/*/
Aadd(aRegs,{cPerg,"01","Cliente?        "   ,"Cliente?        ","Cliente?        ","mv_ch1","C",TamSx3 ("A1_COD")[1]    ,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","SA1","",""})
Aadd(aRegs,{cPerg,"02","Vencimento de?  "   ,"Vencimento de?  ","Vencimento de?  ","mv_ch2","D",TamSx3 ("E2_VENCTO")[1] ,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"",""})
Aadd(aRegs,{cPerg,"03","Vencimento até? "   ,"Vencimento até? ","Vencimento até? ","mv_ch3","D",TamSx3 ("E2_VENCTO")[1] ,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"",""})
AADD(aRegs,{cPerg,"04","Banco ?         "   ,"Banco ?         ","Banco ?         ","mv_ch4","C",TamSX3 ("A6_COD")[1]    ,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","SA6","",""})
AADD(aRegs,{cPerg,"05","Agência ?       "   ,"Agência ?       ","Agência ?       ","mv_ch5","C",TamSX3 ("A6_AGENCIA")[1],0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","SA6","",""})
AADD(aRegs,{cPerg,"06","Aliquota de IOF:"   ,"Aliquota de IOF?","Aliquota de IOF?","mv_ch6","N",5                       ,2,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegs,{cPerg,"07","Aliquota de IR: "   ,"Aliquota de IR? ","Aliquota de IR? ","mv_ch7","N",5                       ,2,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegs,{cPerg,"08","Aliq.por dentro:"   ,"Aliq.por dentro:","Aliq.por dentro:","mv_ch8","N",5                       ,2,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegs,{cPerg,"09","Taxa fixa?      "   ,"Taxa fixa?      ","Taxa fixa?      ","mv_ch9","N",5                       ,2,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegs,{cPerg,"10","Revisado por:   "   ,"Revisado por:   ","Revisado por:   ","mv_cha","C",40                      ,0,0,"G","","MV_PAR10","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"11","Gerente:        "   ,"Gerente:        ","Gerente:        ","mv_chb","C",40                      ,0,0,"G","","MV_PAR11","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
/*/    