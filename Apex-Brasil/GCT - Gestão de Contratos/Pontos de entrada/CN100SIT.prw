#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'
#include 'totvs.ch'
#include 'ap5mail.ch'
#include 'fileio.ch'

#define CRLF Chr(13) + Chr(10)

/*/{Protheus.doc} CN100SIT.prw

P.E. após a alteração da situação do contrato

@author  luciano.camargo - TOTVS
@since   10/02/2017
@version 1.0

@obs 	 Criado para enviar aviso a contabilidade quando o contrato iniciar vigencia [Situacao=05]
@obs 	 Tabelas: CN0-TipoRevisaoContrato, CN9-Contratos 
@type 	 function
/*/

user function CN100SIT()

	Local _cAvCdRev	  := GetNewPar("AB_AVSTCTO","05/06")						 	// Codigos das revisões que enviaram aviso a contabilidade
	Local cEMAILREM   := GetNewPar("AB_MAILREM","workflow@apexbrasil.com.br" )		// E-mail do remetente (APEX)
	Local cDESTIN     := GetNewPar("AB_MAILCTB","contabilidade@apexbrasil.com.br") 	// E-mail do departamento contabil   										
	Local cCc         := GetNewPar("AB_MAILMON","")									// E-mail do monitoramento (TI)
	Local cASSUNT     := "Aviso de alteração de situação de contrato"				// Assunto
	Local cCORPO	  := ""                               							// Informações a exibir: Codigo Convenio, Codigo Contrato, Situação [Codigo/Descrição]
	Local aENVANEXO   := ""
	Local cLogoAssin  := AllTrim(GetNewPar("AB_LOGCART","")) 						// '\dirdoc\ApexBrasil.png'
	Local _cSituac    := CN9->CN9_SITUAC 

	If _cSituac $ _cAvCdRev

		//--- Tratamentos
		_cNrConv := Iif( FieldPos("CN9_XCONV")==0,"NAO INFORMADO",CN9->CN9_XCONV) 
		
		//--- Início do corpo do e-mail 

		cCORPO += "<table>" + CRLF
		cCORPO += "<caption><b><u>Aviso de alteração de situação de contrato</u></b><br/><br/></caption>" + CRLF
		cCORPO += "<tr>" + CRLF
		cCORPO += "<th>Convênio</th><th>Contrato</th><th>Situação</th>" + CRLF
		cCORPO += "</tr>" + CRLF

		cCORPO += "<tr>" + CRLF
		cCORPO += "<td>" + _cNrConv + "</td>" + CRLF
		cCORPO += "<td><center>" +CN9->CN9_NUMERO+IIF(!Empty(CN9->CN9_REVISA)," R"+CN9->CN9_REVISA,"") + "</center></td>" + CRLF
		cCORPO += "<td> " + _cSITUAC+"-"+IIF(_cSituac=="05","Vigente","Paralisado") + "</td>" + CRLF
		cCORPO += "</tr>" + CRLF			

		//--- Fim do corpo do e-mail 

		cCORPO += "</table>" + CRLF
		cCORPO += "<br/>" + CRLF
		cCORPO += "<b>Atenciosamente,</b><br/>" + CRLF
		cCORPO += "<b>Apex Brasil</b><br/>" + CRLF
		cCORPO += "<b>Mensagem automática, favor não responda esse e-mail.<br/>" + CRLF

		U_EnvEmai2(cEMAILREM, cDESTIN, cASSUNT, cCORPO, aENVANEXO, cLogoAssin)
		MsgInfo("Aviso de mudança de situação enviado à contabilidade.")
	Endif

return(.T.)