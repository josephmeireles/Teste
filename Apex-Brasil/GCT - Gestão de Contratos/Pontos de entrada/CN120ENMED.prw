#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'
#include 'totvs.ch'
#include 'ap5mail.ch'
#include 'fileio.ch'

#define CRLF Chr(13) + Chr(10)

/*/{Protheus.doc} CN120ENMED.prw

P.E. para encerramento da medição [pos TRANSACTION]

@author  luciano.camargo - TOTVS
@since   13/02/2017
@version 1.0

@obs 	 Criado para enviar aviso ao gestor do contrato quando determinados percentuais forem atingidos
@obs     Entenda-se por Gestor do Contrato, o e-mail vinculado ao Centro de Custo
@obs 	 Tabelas: CN9-Contratos , CTT-Centros de Custo
@type 	 function
/*/

user function CN120ENMED()

	Local _cAvPCSld	  := GetNewPar("AB_AVSLCTO","15/35/50/75/")							// Percentuais de avisos de saldos atingidos de contratos
	Local cEMAILREM   := GetNewPar("AB_MAILREM","workflow@apexbrasil.com.br" )			// E-mail do remetente (APEX)
	Local cDESTIN     := GetNewPar("AB_MAILCTO","gestaodecontratos@apexbrasil.com.br") 	// E-mail do departamento de contratos   										
	Local cCc         := GetNewPar("AB_MAILMON","")										// E-mail do monitoramento (TI)
	Local cASSUNT     := "Aviso de saldo de contrato atingido"							// Assunto
	Local cCORPO	  := ""                               								// Informações a exibir: Codigo Convenio, Codigo Contrato, Situação [Codigo/Descrição]
	Local aENVANEXO   := ""
	Local cLogoAssin  := AllTrim(GetNewPar("AB_LOGCART","")) 							// '\dirdoc\ApexBrasil.png'
	Local _cSituac    := CN9->CN9_SITUAC 
	Local _lAtingiu   := .F.
	Local _nIdx
	Local _nTotal     := CND->CND_VLTOT
	Local _nSaldo     := 0
	Local _cMailGst   := ""

	// Obter percentuais
	_cAvPCSld := Iif( FieldPos("CN9_XPCAVS")==0,_cAvPCSld,CN9->CN9_XPCAVS) 
	_aAvPCSld := Separa( _cAvPCSld, "/")

	// Obter Saldo e Percentual
	_nSaldo := CN9->CN9_SALDO

	// Calcular o percentual
	For _nIdx := 1 to Len(_aAvPCSld)
		Aadd( _aVal, { Val(_aAvPCSld), (_nTotal * (Val(_aAvPCSld)/100)) } )
	Next _nIdx
	
	For _nIdx := 1 to Len(_aVal)
		If (_nSaldo >= _aVal[_nIdx][2]) .and. (_nSaldo <= _aVal[_nIdx+1][2]) 
			_lAtingiu := .T.
			Break
		Endif
	Next _nIdx

	If _lAtingiu

		//--- Tratamentos
		_cNrConv := Iif( FieldPos("CN9_XCONV")==0,"NAO INFORMADO",CN9->CN9_XCONV) 

		// Obter o Centro de custo da CNB
		_cCC := CNB->CNB_CC // Definir onde será melhor CC / CLVL ou ItemC

		// Verificar se existe E-Mail, vinculado ao Centro de Custo
		_cMailGst := Posicione( "CTT", xFilial("CTT")+_cCC,"CTT_XEMAIL" )
		If !Empty(_cMailGst)
			cDESTIN += "; "+_cMailGst
		Endif 

		//--- Início do corpo do e-mail 

		cCORPO += "<table>" + CRLF
		cCORPO += "<caption><b><u>Aviso: Percentual de saldo de contrato atingido</u></b></caption>" + CRLF
		cCORPO += "<br/>Gestor contrato - e-Mail: " + _cMailGst + CRLF
		cCORPO += "<br/><br/><tr>" + CRLF
		cCORPO += "<th>Convênio</th><th>Contrato</th><th>Saldo % / R$</th>" + CRLF
		cCORPO += "</tr>" + CRLF

		cCORPO += "<tr>" + CRLF
		cCORPO += "<td>" + _cNrConv + "</td>" + CRLF
		cCORPO += "<td><center>" +CN9->CN9_NUMERO+IIF(!Empty(CN9->CN9_REVISA)," R"+CN9->CN9_REVISA,"") + "</center></td>" + CRLF
		cCORPO += "<td> " + AllTrim(Str(_aVal[_nIdx][1])) +"% - R$"+AllTrim(Str(_aVal[_nIdx][2])) + "</td>" + CRLF
		cCORPO += "</tr>" + CRLF			

		//--- Fim do corpo do e-mail 

		cCORPO += "</table>" + CRLF
		cCORPO += "<br/>" + CRLF
		cCORPO += "<b>Atenciosamente,</b><br/>" + CRLF
		cCORPO += "<b>Apex Brasil</b><br/>" + CRLF
		cCORPO += "<b>Mensagem automática, favor não responda esse e-mail.<br/>" + CRLF

		U_EnvEmai2(cEMAILREM, cDESTIN, cASSUNT, cCORPO, aENVANEXO, cLogoAssin)
		MsgInfo("Aviso enviado ao gestor do contrato: Percentual de saldo atingido.")
	Endif

return(.T.)