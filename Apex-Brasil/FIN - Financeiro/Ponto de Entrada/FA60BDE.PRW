#INCLUDE "PROTHEUS.ch"
#INCLUDE "Topconn.ch"

/*/{Protheus.doc} FA60BDE
//TODO Descrição: Ponto de entrada para o enviar para o cliente o WF com a relação de títulos a receber
que está sendo classificado como cobrança administrativa e uma notificação para o destinatário 
definido pela ApexRotina.
@project	SuperAcao Apex-Brasil    
@author TOTVS
@since 17/11/2016
@version 1.0

@type function
/*/
User function FA60BDE()

Local  aArea      := GetArea()
Local _cRemete    := AllTrim( GetNewPar ( "AB_REMFIN1"	, "workflow@apexbrasil.com.br" ))         // Parâmetro ou e-mail do remetente (APEX)
Local _cDestin    := "" 																	      // E-mail do destinatário que será cadastrado no campo SA1->A1_EMAIL
Local _cCC        := AllTrim( GetNewPar ( "AB_CCFIN1"	, "josephmeireles@live.com" ))   		  // Parâmetro para cadastrar o e-mail do destinatário especificado pelo departamento Financeiro que receberá a cópia do e-mail enviado ao Cliente
Local _cAssunto   := AllTrim( GetNewPar ( "AB_ASSFIN1"	, "Relação de títulos em aberto." ))	  // Parâmetro com assunto.
Local _cCorpoEmai := ""                               											  // Relação dos títulos que será enviado para o cliente
Local _aAnexos    := ""
Local _cFinal     := .F.
Local _cTotal     := 0
Local _cTotalCli  := ""   
Local _cLogoAssin := AllTrim( GetNewPar ("AB_LOGCART"	,"\dirdoc\ApexBrasil.png"))

_cQuery := "SELECT E1_FILIAL,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_CLIENTE,E1_LOJA,E1_NOMCLI,E1_EMISSAO,E1_VENCTO,E1_VALOR "
_cQuery += " FROM " + RetSqlName("SE1") + " SE1 "
_cQuery += " WHERE E1_FILIAL Between '" + cFilDe + "' AND '"+ cFilAte + "'"
_cQuery += "   AND E1_NUMBOR = '      '"
_cQuery += "   AND E1_EMISSAO Between '" + DTOS(dEmisDe) + "' AND '" + DTOS(dEmisAte) + "'"
_cQuery += "   AND E1_CLIENTE between '" + cCliDe        + "' AND '" + cCliAte        + "'"
_cQuery += "   AND E1_VENCREA between '" + DTOS(dVencIni)+ "' AND '" + DTOS(dVencFim) + "'"
_cQuery += "   AND E1_MOEDA = "+ str(nmoeda)
_cQuery += "   AND E1_PREFIXO Between '" + cPrefDe + "' AND '" + cPrefAte + "'"
_cQuery += "   AND E1_NUM between '"     + cNumDe  + "' AND '" + cNumAte  + "'"
_cQuery += "   AND ( E1_SALDO > 0  OR E1_OCORREN = '02' ) "

//Seleciona Tipos

If mv_par12 == 1
	_cQuery += "   AND E1_TIPO IN " + FormatIn(cTipos,"/")
Endif
If ( cPaisLoc == "CHI" )
	_cQuery += " AND E1_TIPO NOT IN ('RA ','NCC', 'NDC','NF ','FT ','LTC')"
Endif
If !Empty(MVPROVIS) .Or. !Empty(MVRECANT) .Or. !Empty(MV_CRNEG) .Or. !Empty(MVENVBCOR)
	_cQuery += "   AND E1_TIPO NOT IN " + FormatIn(MVPROVIS+"/"+MVRECANT+"/"+MV_CRNEG+"/"+MVENVBCOR,"/")
Endif
_cQuery += "   AND E1_SITUACA IN ('0','F','G') "
_cQuery += "   AND SE1.D_E_L_E_T_ <> '*' "
_cQuery += "   ORDER BY SE1.E1_CLIENTE,E1_EMISSAO "

_cQuery := ChangeQuery(_cQuery)

If Select("QRY") > 0
	Dbselectarea("QRY")
	QRY->(DbClosearea())
EndIf

TcQuery _cQuery New Alias "QRY"

dbSelectArea("QRY")
QRY->(dbGoTop())

DbSelectArea("SA1")
DbSetOrder(1)
SA1->(dbGoTop())
DbSeek(xFilial()+SE1->E1_CLIENTE+SE1->E1_LOJA,.T.)

_cCliente := QRY->E1_CLIENTE
_cNome    := QRY->E1_NOMCLI
_cDestin  := SA1->A1_EMAIL

//---  Inicio do corpo do e-mail

_cHTML:="<br/>"
_cHTML+="<b>Código: </b> "+_cCliente+"  <br/>"
_cHTML+="<b>Nome  :</b> "+_cNome+" <br/><br/>"
_cHTML+="<table>"
_cHTML+="<caption><b><u>Relação de títulos em aberto</u></b><br/><br/></caption>"
_cHTML+="<tr>"
_cHTML+="<th>Título</th><th>Parcela</th><th>Vencimento</th><th>Valor</th> "
_cHTML+="</tr>"

//----------------------

dbSelectArea("QRY")
QRY->(dbGoTop())

While !Eof()
	
	If  QRY->E1_CLIENTE == _cCliente
		
		_cDestin  := SA1->A1_EMAIL
		
		_cTitulo   := QRY->E1_NUM
		_cParcela  := QRY->E1_PARCELA
		_cVencto   := SUBSTR(QRY->E1_VENCTO,7,2)+"/"+SUBSTR(QRY->E1_VENCTO,5,2)+"/"+SUBSTR(QRY->E1_VENCTO,1,4)
		_cValor    := TRANSFORM(QRY->E1_VALOR, "@E 9,999,999,999.99")// QRY->E1_VALOR,17,2)
		
		_cTotal    := _cTotal + QRY->E1_VALOR
		_cTotalCli := TRANSFORM(QRY->E1_VALOR, "@E 9,999,999,999.99") //_cTotal,17,2)
		 
		//--- Relação de títulos 
		
		_cHTML+="<tr>"
		_cHTML+="<td>"+_cTitulo+"</td>"
		_cHTML+="<td><center>"+_cParcela+"</center></td>"
		_cHTML+="<td>"+_cVencto+"</td>"
		_cHTML+="<td>R$ "+_cValor+"</td>"
		_cHTML+="</tr>"
		
		//----------------------
	Else
		
		_cFinal := .T.
		
		//--- Fim do corpo do e-mail 
		
		_cHTML+="</table>"
		_cHTML+="<br/>"
		_cHTML+="<b>Total dos títulos: </b>R$ "+_cTotalCli+"<br/> <br/>"
		_cHTML+="<br/>"
		_cHTML+="<b>Atenciosamente,</b><br/> <br/>"
		_cHTML+="<b>Apex Brasil</b><br/><br/>"
		_cHTML+="<b>Mensagem automática, favor não responda esse e-mail.<br/>"
		
		//----------------------
		
		//u_emailcli(_cRemete, _cDestin, _cAssunto, _cCorpoEmai, _aAnexos)
		U_EnvEmai2(_cRemete, _cDestin, _cAssunto, _cCorpoEmai, _aAnexos, _cLogoAssin, _cCC)
		
		_cFinal := .F.
		
		_cTotal   := 0
		
		_cCliente := QRY->E1_CLIENTE
		_cNome    := QRY->E1_NOMCLI
		_cDestin  := SA1->A1_EMAIL 
		
		//---  Inicio do corpo do e-mail
		
		_cHTML:="<br/>"
		_cHTML+="<b>Código: </b> "+_cCliente+"  <br/>"
		_cHTML+="<b>Nome  :</b> "+_cNome+" <br/><br/> "
		_cHTML+="<table>"
		_cHTML+="<caption><b><u>Relação de títulos em aberto</u></b><br/><br/></caption>"
		_cHTML+="<tr>"
		_cHTML+="<th>Título</th><th>Parcela</th><th>Vencimento</th><th>Valor</th> "
		_cHTML+="</tr>"  

		//----------------------

		_cTitulo   := QRY->E1_NUM
		_cParcela  := QRY->E1_PARCELA
		_cVencto   := SUBSTR(QRY->E1_VENCTO,7,2)+"/"+SUBSTR(QRY->E1_VENCTO,5,2)+"/"+SUBSTR(QRY->E1_VENCTO,1,4)
		_cValor    := TRANSFORM(QRY->E1_VALOR, "@E 9,999,999,999.99") // QRY->E1_VALOR,17,2)STR(QRY->E1_VALOR,17,2)
		_cTotal    := _cTotal + QRY->E1_VALOR
		_cTotalCli := TRANSFORM(QRY->E1_VALOR,"@E 9,999,999,999.99") //_cTotal,17,2) STR(_cTotal,17,2)
		 
		//--- Relação de títulos 
		
		_cHTML+="<tr>"
		_cHTML+="<td>"+_cTitulo+"</td>"
		_cHTML+="<td><center>"+_cParcela+"</center></td>"
		_cHTML+="<td>"+_cVencto+"</td>"
		_cHTML+="<td>R$ "+_cValor+"</td>"
		_cHTML+="</tr>"   
		
		//----------------------
				
	EndIf
	
	_cCliente := QRY->E1_CLIENTE
	
	_cDestin  := ""
	_cTitulo  := ""
	_cParcela := ""
	_cVencto  := ""
	_cValor   := 0
	
	QRY->(dbSkip())
	
End

If _cFinal == .F. 

	//--- Fim do corpo do e-mail
	
	_cHTML+="</table>"
	_cHTML+="<br/>"
	_cHTML+="<b>Total dos títulos:</b> R$ "+_cTotalCli+"<br/> <br/>"
	_cHTML+="<br/>"
	_cHTML+="<b>Atenciosamente,</b><br/> <br/>"
	_cHTML+="<b>Apex Brasil</b><br/><br/>"
	_cHTML+="<b>Mensagem automática, favor não responda esse e-mail.<br/>"
	
	//----------------------
	
//	u_emailcli(_cRemete, _cDestin,_cCC, _cAssunto, _cCorpoEmai, _aAnexos)
	U_EnvEmai2(_cRemete, _cDestin, _cAssunto, _cCorpoEmai, _aAnexos, _cLogoAssin, _cCC)

EndIf

RestArea(aArea)

Return