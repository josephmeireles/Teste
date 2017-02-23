#Include 'PROTHEUS.ch'
#Include 'Topconn.ch'
#Include 'TOTVS.CH'
#Include 'PROTHEUS.CH'
#Include 'PARMTYPE.CH'
#Include 'AP5MAIL.CH'
#Include 'FILEIO.CH'

//Constante que simula a tecla Enter.
#DEFINE CRLF	Chr(13) + Chr(10)

/*/{Protheus.doc} AF240CLA
//TODO Descrição : Ponto de entrada para envio de e-mail com os dados do ativo que acaba de ser classificado.
@Project SuperAcao Apex-Brasil
@author Joseph Oliveira / Analista de Serviços TOTVS.
@since 30/12/2016
@version 1.0
@param lEdita, logical, descricao
@type function
/*/
User Function AF240CLA()

	Local lRet     		:= 	.T.
	Local aArea    		:= 	GetArea()
	Local aAreaSN1 		:= 	SN1->(GetArea())
	Local aAreaSN3 		:= 	SN3->(GetArea())
	Local cFili			:= 	N1->N1_FILIAL
	Local cCBase		:=	N1->N1_CBASE
	Local cItem			:=	N1->N1_ITEM
	Local cAquisi		:=	N1->N1_AQUISIC
	Local cQuant		:= 	N1->N1_QUANTD
	Local cDesc			:=	N1->N1_DESCRIC
	Local cFiscal		:=	N1->N1_NFISCAL
	Local cTipo			:=	N3->N3_TIPO
	Local cHis			:=	N3->N3_HISTOR
	Local cCCont		:= 	N3->N3_CCONTAB
	Local cCusBem		:=	N3->N3_CUSTBEM
	Local cConDep		:=	N3->N3_CDEPREC
	Local cConDeA		:=	N3->N3_CCDEPRE
	Local cDtDepr		:=	DtoC(N3->N3_DINDEPR)
	Local cValOri		:=	N3->N3_VORIG1
	Local cTaxa			:=	N3->N3_TXDEPR1
	Local cCodBem		:=	N3->N3_CLVL
	Local cEMAILREM   	:= 	AllTrim( GetNewPar ( "AB_REMATF2"	, "workflow@apexbrasil.com.br" ))                 
	Local cDESTIN     	:= 	AllTrim( GetNewPar ( "AB_DESATF2"	, "joseph.oliveira@totvs.com.br" ))   			
	Local cCc         	:= 	AllTrim( GetNewPar ( "AB_CCATF2"	, "josephmeireles@live.com" ))  					 
	Local cASSUNT     	:= 	AllTrim( GetNewPar ( "AB_ASSATF2"	, "Novo Ativo Classificado." ))
	Local cCORPO  	 	:= 	""                               			
	Local aENVANEXO   	:= 	""

	//--- Início do corpo do e-mail 

	cCORPO += "<table>" + CRLF
	cCORPO += "<caption><b><u>Um Ativo acaba de ser Classificado</u></b><br/><br/></caption>" + CRLF
	cCORPO += "<tr>" + CRLF
	cCORPO += "<th>Campo</th><th>Descrição</th>" + CRLF
	cCORPO += "</tr>" + CRLF
	
	//----------------------
	
	//Tabela HTML Contendo os Campos das tabelas SN1 E SN3.

	cCORPO 	 += "<tr>" 	+ CRLF
    cCORPO 	 += "<td> Filial </td>" + CRLF
    cCORPO 	 += "<td>" 	+ cFili + "</td>" + CRLF
    cCORPO 	 += "</tr>" + CRLF
    cCORPO 	 += "<tr>" 	+ CRLF
    cCORPO 	 += "<td> CodBase </td>" + CRLF
    cCORPO 	 += "<td>" 	+ cCBase + "</td>" + CRLF
    cCORPO 	 += "</tr>" + CRLF
    cCORPO 	 += "<tr>" 	+ CRLF
    cCORPO 	 += "<td> Item </td>" + CRLF
    cCORPO 	 += "<td>" 	+ cItem + "</td>" + CRLF
    cCORPO 	 += "</tr>" + CRLF
    cCORPO 	 += "<tr>" 	+ CRLF
    cCORPO 	 += "<td> Aquisição </td>" + CRLF
    cCORPO 	 += "<td>" 	+ cAquisi + "</td>" + CRLF
    cCORPO 	 += "</tr>" + CRLF
    cCORPO 	 += "<tr>" 	+ CRLF
    cCORPO 	 += "<td> Quantidade </td>" + CRLF
    cCORPO 	 += "<td>" 	+ cQuant + "</td>" + CRLF
    cCORPO 	 += "</tr>" + CRLF
    cCORPO 	 += "<tr>" 	+ CRLF
    cCORPO 	 += "<td> Descrição </td>" + CRLF
    cCORPO 	 += "<td>" 	+ cDesc + "</td>" + CRLF
    cCORPO 	 += "</tr>" + CRLF
    cCORPO 	 += "<tr>" 	+ CRLF
    cCORPO 	 += "<td> NotaFiscal </td>" + CRLF
    cCORPO 	 += "<td>" 	+ cFiscal + "</td>" + CRLF
    cCORPO 	 += "</tr>" + CRLF
    cCORPO 	 += "<tr>" 	+ CRLF
    cCORPO 	 += "<td> Tipo de Classificação </td>" + CRLF
    cCORPO 	 += "<td>" 	+ cTipo + "</td>" + CRLF
    cCORPO 	 += "</tr>" + CRLF
    cCORPO 	 += "<tr>" 	+ CRLF
    cCORPO 	 += "<td>  Histórico Classificação </td> " + CRLF
    cCORPO 	 += "<td>" 	+ cHis + "</td>" + CRLF
    cCORPO 	 += "</tr>" + CRLF
    cCORPO 	 += "<tr>" 	+ CRLF
    cCORPO 	 += "<td> Conta Contábil </td>" + CRLF
    cCORPO 	 += "<td>" 	+ cCCont + "</td>" + CRLF
    cCORPO 	 += "</tr>" + CRLF
    cCORPO 	 += "<tr>" 	+ CRLF
    cCORPO 	 += "<td> Centro de Custo </td>" + CRLF
    cCORPO 	 += "<td>" 	+ cCusBem + "</td>" + CRLF
    cCORPO 	 += "</tr>" + CRLF
    cCORPO 	 += "<tr>" 	+ CRLF
    cCORPO 	 += "<td> Conta de Despesa de Depreciação </td>" + CRLF
    cCORPO 	 += "<td>" 	+ cConDep + "</td>" + CRLF
    cCORPO 	 += "</tr>" + CRLF
    cCORPO 	 += "<tr>" 	+ CRLF
    cCORPO 	 += "<td> Conta de Depreciação Acumulada </td>" + CRLF
    cCORPO 	 += "<td>" 	+ cConDeA + "</td>" + CRLF
    cCORPO 	 += "</tr>" + CRLF
    cCORPO 	 += "<tr>" 	+ CRLF
    cCORPO 	 += "<td> Data de Inicio de Depreciação </td>" + CRLF
    cCORPO 	 += "<td>" 	+ cDtDepr + "</td>" + CRLF
    cCORPO 	 += "</tr>" + CRLF
    cCORPO 	 += "<tr>" 	+ CRLF
    cCORPO 	 += "<td> Valor Original do Bem </td>" + CRLF
    cCORPO 	 += "<td>" 	+ cValOri + "</td>" + CRLF
    cCORPO 	 += "</tr>" + CRLF
    cCORPO 	 += "<tr>" 	+ CRLF
    cCORPO 	 += "<td> Taxa Anual de depreciação do Bem </td>" + CRLF
    cCORPO 	 += "<td>" 	+ cTaxa + "</td>" + CRLF
    cCORPO 	 += "</tr>" + CRLF
  	cCORPO 	 += "<tr>" 	+ CRLF
    cCORPO 	 += "<td> Código de Projeto do Bem </td>" + CRLF
    cCORPO 	 += "<td>" 	+ cCodBem + "</td>" + CRLF
    cCORPO 	 += "</tr>" + CRLF
	
    // Fim do corpo do e-mail 

	cCORPO += "</table>" + CRLF
	cCORPO += "<br/> <br/>" + CRLF
	cCORPO += "<b>Atenciosamente,</b><br/>" + CRLF
	cCORPO += "<b>Apex Brasil</b><br/> " + CRLF
	cCORPO += "<b>Mensagem automática, favor não responda esse e-mail." + CRLF

If lRet

	U_EnvEmai2(cEMAILREM, cDESTIN, cASSUNT, cCORPO, aENVANEXO, cLogoAssin, cCc)

EndIf

RestArea(aAreaSN3)
RestArea(aAreaSN1)
RestArea(aArea)
Return lRet
