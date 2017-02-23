#Include 'PROTHEUS.ch'
#Include 'Topconn.ch'
#Include 'TOTVS.CH'
#Include 'PROTHEUS.CH'
#Include 'PARMTYPE.CH'
#Include 'AP5MAIL.CH'
#Include 'FILEIO.CH'

//Constante que simula a tecla Enter.
#Define CRLF 		Chr(13) + Chr(10)

/*/{Protheus.doc} ABATFW01
//TODO Descrição : Seleciona os Ativos que estão pendentes de Classificação e envia a relação dos mesmos por E-mail
De a acordo com os E-mail Cadastrados em AB_DESATF1 e AB_CCATF1.
@Project SuperAcao Apex-Brasil
@author Joseph Oliveira / Analista de Serviços TOTVS.
@since 30/12/2016
@version 1.0
@param lEdita, logical, descricao
@type function
/*/	
User Function ABATFW01()

	Local lRet     		:= .F.
	Local aArea    		:= GetArea()
	Local aAreaSN1 		:= SN1->(GetArea())
	Local aAreaSN3 		:= SN3->(GetArea())
	Local aCBase		:= {}
	Local aItem			:= {}
	Local aDescric		:= {}
	Local cEMAILREM   	:= AllTrim( GetNewPar ( "AB_REMATF1"	,"josephmeireles@gmail.com" ))                 
	Local cDESTIN     	:= AllTrim( GetNewPar ( "AB_DESATF1"	,"joseph.oliveira@totvs.com.br" ))   			
	Local cCc         	:= AllTrim( GetNewPar ( "AB_CCATF1"		,"josephmeireles@live.com" ))  					 
	Local cASSUNT     	:= AllTrim( GetNewPar ( "AB_ASSATF1"	,"Ativo Pendente de Classificação" ))
	Local cCORPO  	 	:= ""                               			
	Local aENVANEXO   	:= ""
	Local cLogoAssin  	:= AllTrim( GetNewPar ("AB_LOGCART"		,"\dirdoc\ApexBrasil.png"))
	Local x				:= 0
	Local y				:= 0
	
//Seleciona os ativos que estão pendentes de classificação

DbSelectArea("SN3")
SN3->(dbSetOrder(1)) //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ
SN3->(MsSeek(SN1->(N1_FILIAL+N1_CBASE+SN1->N1_ITEM)))

If Alltrim(SN1->N1_ORIGEM) == "ATFA310"
	If SN1->N1_STATUS != "0" // Pendente de Classificação
		
		Aadd(aCBase,	{SN1->N1_CBASE})
		Aadd(aItem,		{SN1->N1_ITEM})
		Aadd(Descric,	{SN1->N1_DESCRIC})
		lRet := .T.
	EndIf

Else

	While SN1->N1_FILIAL+SN1->N1_CBASE+SN1->N1_ITEM == SN3->(N3_FILIAL+N3_CBASE+N3_ITEM) .and. SN3->(!Eof())

		If Val( SN3->N3_BAIXA ) # 0 .or. ! Empty(SN3->N3_CCONTAB)
	
			Aadd(aCBase,	{SN1->N1_CBASE})	
			Aadd(aItem,		{SN1->N1_ITEM})
			Aadd(aDescric,	{SN1->N1_DESCRIC})
			lRet := .T.

			Exit

		EndIf

		SN3->(dbSkip())

	Enddo

EndIf

// Início do corpo do e-mail

	    cCORPO += "<table>" + CRLF
		cCORPO += "<caption><b><u>Ativos Pendentes de Classificação</u></b><br/><br/></caption>" + CRLF
		cCORPO += "<tr>" + CRLF
		cCORPO += "<th>Cod.Bem</th><th>Item</th><th>Descrição</th>" + CRLF
		cCORPO += "</tr>" + CRLF	

// Corpo do e-mail.
For y:=1 to Len( aCBase )	 	
	
	For x:=1 to Len( aCBase )
				
		cCORPO 	 += "<tr>" + CRLF
		cCORPO 	 += "<td>" +  AllTrim(cValToChar(aCBase[y][x])) + "</td>" + CRLF
		cCORPO 	 += "<td><center>" + AllTrim(cValToChar(aItem[y][x])) + "</center></td>" + CRLF
		cCORPO 	 += "<td> " + AllTrim(cValToChar(aDescric[y][x])) + "</td>" + CRLF
		cCORPO 	 += "</tr>" + CRLF	
				
	Next

Next

// Fim do corpo do e-mail 

	cCORPO += "</table>" + CRLF
	cCORPO += "<br/> <br/>" + CRLF
	cCORPO += "<b>Atenciosamente,</b><br/>" + CRLF
	cCORPO += "<b>Apex Brasil</b><br/> " + CRLF
	cCORPO += "<b>Mensagem automática, favor não responda esse e-mail." + CRLF
	
//Envia o E-mail.

If lRet

	U_EnvEmai2(cEMAILREM, cDESTIN, cASSUNT, cCORPO, aENVANEXO, cLogoAssin, cCc)

EndIf

RestArea(aAreaSN3)
RestArea(aAreaSN1)
RestArea(aArea)
Return lRet

/*
	_cQuery := "SELECT N3_FILIAL,N3_CBASE,N3_ITEM,N3_DESCRIC " + STR_PULA
	_cQuery += " FROM " + RetSqlName("SN3") + " SN3 " + STR_PULA
	_cQuery += " Where " + STR_PULA
	_cQuery += "   N3_BAIXA <> '0'" + STR_PULA
	_cQuery += "   AND SN3.D_E_L_E_T_ = '' " + STR_PULA
	_cQuery += "   OR N3_CCONTAB = '' " + STR_PULA
	_cQuery += "   ORDER BY SN3.N3_CBASE,E1_NUM " 	 + STR_PULA
	_cQuery := ChangeQuery(_cQuery)	

	TcQuery _cQuery New Alias "QRY_N3"			// Faz a pesquisa contida na váriavel _cQuery e adiciona o Alias QRY.

*/