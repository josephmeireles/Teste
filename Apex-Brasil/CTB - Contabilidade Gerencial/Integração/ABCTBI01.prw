#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"         
#INCLUDE "TOTVS.CH"     
#INCLUDE "FWCOMMAND.CH"

//-----------------------------------------------------------------------
/*/{Protheus.doc} ABCTBI01()

WSFenixProjeto
Web service para integração entre o Protheus e o Fênix para manutenção na 
tabela de Classe de Valor (Projeto)

Informações recebidas do Fênix:
ID do Projeto, Descrição do Projeto, Data de Início do Projeto, Data Fim 
do Projeto, ID Centro de Custo ICO (Cód. Reduz. CC).

Plano de ação:
Definir a data para elaborar WSDL e enviar para TAREA

Detalhes:
Na inclusão ou alteração do Projeto no Fênix a informação será enviada 
ao Protheus via Web Service; quando um Projeto for concluído no Fênix a 
"Data Fim de Projeto" será enviada para o Protheus (WS), e o Protheus 
fará o bloqueio desse cadastro.

@param		Nenhum
@return		Nenhum
@author 	Fabio Cazarini
@since 		02/09/2016
@version 	1.0
@project	SuperAcao Apex-Brasil
/*/
//-----------------------------------------------------------------------
WSSERVICE WSFenixProjeto Description "Web service para integracao entre o Protheus e o Fenix  - Manutencao no tabela de projetos (Classe de valor)"
	//-----------------------------------------------------------------------
	// Dados
	//-----------------------------------------------------------------------
	WSDATA IDProjeto 				AS STRING OPTIONAL	// CTH_CLVL
	WSDATA DsProjeto 				AS STRING OPTIONAL	// CTH_DESC01
	WSDATA DtIniProjeto 			AS DATE OPTIONAL	// CTH_DTEXIS
	WSDATA DtFimProjeto 			AS DATE OPTIONAL	// CTH_DTEXSF
	WSDATA CodReduzido 				AS STRING OPTIONAL	// CTH_RES
	WSDATA Retorno					AS STRING OPTIONAL
	WSDATA ListaRetornoConsulta		AS ARRAY OF STRUCListaRetornoConsulta

	//-----------------------------------------------------------------------
	// Métodos
	//-----------------------------------------------------------------------
	WSMETHOD ConsultaProjetoFenix	DESCRIPTION "Método para consultar o projeto (classe de valor) no Protheus"
	WSMETHOD IncluiProjetoFenix		DESCRIPTION "Método para incluir o projeto (classe de valor) no Protheus"
	WSMETHOD AlteraProjetoFenix		DESCRIPTION "Método para alterar o projeto (classe de valor) no Protheus"
	WSMETHOD ExcluiProjetoFenix		DESCRIPTION "Método para excluir o projeto (classe de valor) no Protheus"
				
ENDWSSERVICE

WSSTRUCT STRUCListaRetornoConsulta
	WSDATA IDProjeto 				AS STRING OPTIONAL
	WSDATA DsProjeto 				AS STRING OPTIONAL
	WSDATA DtIniProjeto 			AS DATE OPTIONAL
	WSDATA DtFimProjeto 			AS DATE OPTIONAL
	WSDATA CodReduzido 				AS STRING OPTIONAL
ENDWSSTRUCT


//-----------------------------------------------------------------------
/*/{Protheus.doc} ConsultaProjeto

Método para consultar o projeto (classe de valor) no Protheus

@param		IDProjeto	= se informado, busca 
			DsProjeto	= descrição ou parte dela
			CodReduzido	= se informado, busca
@return		ListaRetornoConsulta
@author 	Fabio Cazarini
@since 		03/09/2016
@version 	1.0
@project	SuperAcao Apex-Brasil
/*/
//-----------------------------------------------------------------------
WSMETHOD ConsultaProjetoFenix WSRECEIVE IDProjeto, DsProjeto, CodReduzido WSSEND ListaRetornoConsulta WSSERVICE WSFenixProjeto
	LOCAL lRet			:= .T.
	LOCAL cIDProjeto	:= ALLTRIM(::IDProjeto)
	LOCAL cDsProjeto	:= ALLTRIM(::DsProjeto)
	LOCAL cCodReduzi 	:= ALLTRIM(::CodReduzido)
	LOCAL cQuery		:= ""
	LOCAL nCnt			:= 0

	//-----------------------------------------------------------------------
	// Busca a classe de valor de acordo com os parametros informados
	//-----------------------------------------------------------------------
	cQuery := " SELECT CTH.R_E_C_N_O_ AS REGNUM "
	cQuery += " FROM " + RetSqlName("CTH") + " CTH "
	cQuery += " WHERE	CTH.CTH_FILIAL = '" + xFILIAL("CTH") + "' " 
	IF !EMPTY(cIDProjeto)
		cQuery += " 	AND CTH.CTH_CLVL = '" + cIDProjeto + "'	"		
	ENDIF
	IF !EMPTY(cDsProjeto)
		cQuery += " 	AND CTH.CTH_DESC01 LIKE '%" + cDsProjeto + "%'	"		
	ENDIF
	IF !EMPTY(cCodReduzi)
		cQuery += " 	AND CTH.CTH_RES = '" + cCodReduzi + "'	"		
	ENDIF
	cQuery += " 	AND CTH.D_E_L_E_T_ = ' '	"
		
	IF SELECT("TRBCTH") > 0
		TRBCTH->( dbCloseArea() )
	ENDIF    
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), "TRBCTH" ,.F.,.T.)

	//-----------------------------------------------------------------------
	// Retorna a lista
	//-----------------------------------------------------------------------
	DbSelectArea("TRBCTH")
	DbGoTop()
	DO WHILE !TRBCTH->( EOF() )
		DbSelectArea("CTH")
		DbGoTo( TRBCTH->REGNUM )
		
		nCnt++
		AADD(::ListaRetornoConsulta,WSClassNew("STRUCListaRetornoConsulta"))
		
		::ListaRetornoConsulta[nCnt]:IDProjeto 		:= CTH->CTH_CLVL
		::ListaRetornoConsulta[nCnt]:DsProjeto 		:= CTH->CTH_DESC01 
		IF !EMPTY(CTH->CTH_DTEXIS)
			::ListaRetornoConsulta[nCnt]:DtIniProjeto 	:= CTH->CTH_DTEXIS
		ELSE
			::ListaRetornoConsulta[nCnt]:DtIniProjeto 	:= NIL		
		ENDIF	 
		IF !EMPTY(CTH->CTH_DTEXSF)
			::ListaRetornoConsulta[nCnt]:DtFimProjeto 	:= CTH->CTH_DTEXSF
		ELSE
			::ListaRetornoConsulta[nCnt]:DtFimProjeto 	:= NIL			
		ENDIF	 
		::ListaRetornoConsulta[nCnt]:CodReduzido 	:= CTH->CTH_RES
		
		DbSelectArea("TRBCTH")
		TRBCTH->( DbSkip() )
	ENDDO
	TRBCTH->( dbCloseArea() )
	
RETURN lRet


//-----------------------------------------------------------------------
/*/{Protheus.doc} IncluiProjetoFenix

Método para incluir o projeto (classe de valor) no Protheus

@param		IDProjeto		= CTH_CLVL 
			DsProjeto		= CTH_DESC01
			DtIniProjeto	= CTH_DTEXIS
			DtFimProjeto	= CTH_DTEXSF
			CodReduzido		= CTH_RES
@return		Retorno			= Carddata com o retorno da transacao e mensagem
@author 	Fabio Cazarini
@since 		03/09/2016
@version 	1.0
@project	SuperAcao Apex-Brasil
/*/
//-----------------------------------------------------------------------
WSMETHOD IncluiProjetoFenix WSRECEIVE IDProjeto, DsProjeto, DtIniProjeto, DtFimProjeto, CodReduzido WSSEND Retorno WSSERVICE WSFenixProjeto
	LOCAL lRet			:= .T.
	LOCAL cIDProjeto	:= ALLTRIM(::IDProjeto)
	LOCAL cDsProjeto	:= ALLTRIM(::DsProjeto)
	LOCAL dDtIniProj	:= ::DtIniProjeto
	LOCAL dDtFimProj	:= ::DtFimProjeto
	LOCAL cCodReduzi 	:= ALLTRIM(::CodReduzido)
	LOCAL cTransacao	:= ""
	LOCAL cMensagem		:= ""
	LOCAL cRetExec		:= ""
	LOCAL nOpc			:= 3 // 3=Inclui,4=Altera,5=Exclui
	LOCAL aAutoCab		:= {}
	LOCAL cCLVL			:= cIDProjeto
	LOCAL cCLASSE		:= "2"	// 1=SINTETICO,2=ANALÍTICO
	LOCAL cBLOQ			:= "2"	// 1=BLOQUEADO,2=NÃO BLOQUEADO

	IF EMPTY(dDtIniProj)
		dDtIniProj := CTOD("01/01/1980")
	ENDIF
	
	//-----------------------------------------------------------------------
	// Se enviou a data final do projeto, bloqueia
	//-----------------------------------------------------------------------
	IF !EMPTY(dDtFimProj)
		cBLOQ := "1"	// 1=BLOQUEADO,2=NÃO BLOQUEADO
	ENDIF
	
	//-----------------------------------------------------------------------
	// Prepara a array do ExecAuto
	//-----------------------------------------------------------------------
	AADD(aAutoCab,{"CTH_CLVL"	, cIDProjeto	, NIL})
	AADD(aAutoCab,{"CTH_DESC01"	, cDsProjeto	, NIL})
	AADD(aAutoCab,{"CTH_DTEXIS"	, dDtIniProj	, NIL})
	AADD(aAutoCab,{"CTH_DTEXSF"	, dDtFimProj	, NIL})
	AADD(aAutoCab,{"CTH_RES"	, cCodReduzi	, NIL})
	AADD(aAutoCab,{"CTH_CLASSE"	, cCLASSE		, NIL})
	AADD(aAutoCab,{"CTH_BLOQ"	, cBLOQ			, NIL})
						
	//-----------------------------------------------------------------------
	// Inclui a classe de valores via ExecAuto
	//-----------------------------------------------------------------------
	cRetExec	:= CTHExecA(aAutoCab, cCLVL, nOpc)

	//-----------------------------------------------------------------------
	// Retorno da operacao:
	// cTransacao = "OK" ou cTransacao = "ERRO" 
	//-----------------------------------------------------------------------		
	IF EMPTY(cRetExec)
		cTransacao 	:= "OK"
		cMensagem	:= "Projeto incluido com sucesso"
	ELSE
		cTransacao 	:= "ERRO"
		cMensagem	:= cRetExec
	ENDIF	 

	::Retorno := U_ABXMLRET("IncluiProjetoFenix", nOpc, cTransacao, cMensagem)
	
RETURN lRet


//-----------------------------------------------------------------------
/*/{Protheus.doc} AlteraProjetoFenix

Método para alterar o projeto (classe de valor) no Protheus

@param		IDProjeto		= CTH_CLVL 
			DsProjeto		= CTH_DESC01
			DtIniProjeto	= CTH_DTEXIS
			DtFimProjeto	= CTH_DTEXSF
			CodReduzido		= CTH_RES
@return		Retorno			= Carddata com o retorno da transacao e mensagem
@author 	Fabio Cazarini
@since 		03/09/2016
@version 	1.0
@project	SuperAcao Apex-Brasil
/*/
//-----------------------------------------------------------------------
WSMETHOD AlteraProjetoFenix WSRECEIVE IDProjeto, DsProjeto, DtIniProjeto, DtFimProjeto, CodReduzido WSSEND Retorno WSSERVICE WSFenixProjeto
	LOCAL lRet			:= .T.
	LOCAL cIDProjeto	:= ALLTRIM(::IDProjeto)
	LOCAL cDsProjeto	:= ALLTRIM(::DsProjeto)
	LOCAL dDtIniProj	:= ::DtIniProjeto
	LOCAL dDtFimProj	:= ::DtFimProjeto
	LOCAL cCodReduzi 	:= ALLTRIM(::CodReduzido)
	LOCAL cTransacao	:= ""
	LOCAL cMensagem		:= ""
	LOCAL cRetExec		:= ""
	LOCAL nOpc			:= 4 // 3=Inclui,4=Altera,5=Exclui
	LOCAL aAutoCab		:= {}
	LOCAL cCLVL			:= cIDProjeto
	LOCAL cCLASSE		:= "2"	// 1=SINTETICO,2=ANALÍTICO
	LOCAL cBLOQ			:= "2"	// 1=BLOQUEADO,2=NÃO BLOQUEADO

	IF EMPTY(dDtIniProj)
		dDtIniProj := CTOD("01/01/1980")
	ENDIF

	//-----------------------------------------------------------------------
	// Se enviou a data final do projeto, bloqueia
	//-----------------------------------------------------------------------
	IF !EMPTY(dDtFimProj)
		cBLOQ := "1"	// 1=BLOQUEADO,2=NÃO BLOQUEADO
	ENDIF
	
	//-----------------------------------------------------------------------
	// Prepara a array do ExecAuto
	//-----------------------------------------------------------------------
	AADD(aAutoCab,{"CTH_CLVL"	, cIDProjeto	, NIL})
	AADD(aAutoCab,{"CTH_DESC01"	, cDsProjeto	, NIL})
	AADD(aAutoCab,{"CTH_DTEXIS"	, dDtIniProj	, NIL})
	AADD(aAutoCab,{"CTH_DTEXSF"	, dDtFimProj	, NIL})
	AADD(aAutoCab,{"CTH_RES"	, cCodReduzi	, NIL})
	AADD(aAutoCab,{"CTH_CLASSE"	, cCLASSE		, NIL})
	AADD(aAutoCab,{"CTH_BLOQ"	, cBLOQ			, NIL})
						
	//-----------------------------------------------------------------------
	// Altera a classe de valores via ExecAuto
	//-----------------------------------------------------------------------
	cRetExec	:= CTHExecA(aAutoCab, cCLVL, nOpc)

	//-----------------------------------------------------------------------
	// Retorno da operacao:
	// cTransacao = "OK" ou cTransacao = "ERRO" 
	//-----------------------------------------------------------------------		
	IF EMPTY(cRetExec)
		cTransacao 	:= "OK"
		cMensagem	:= "Projeto alterado com sucesso"
	ELSE
		cTransacao 	:= "ERRO"
		cMensagem	:= cRetExec
	ENDIF	
	
	::Retorno := U_ABXMLRET("AlteraProjetoFenix", nOpc, cTransacao, cMensagem)
	 
RETURN lRet


//-----------------------------------------------------------------------
/*/{Protheus.doc} ExcluiProjetoFenix

Método para excluir o projeto (classe de valor) no Protheus

@param		IDProjeto		= CTH_CLVL 
			DsProjeto		= CTH_DESC01
			DtIniProjeto	= CTH_DTEXIS
			DtFimProjeto	= CTH_DTEXSF
			CodReduzido		= CTH_RES
@return		Retorno			= Carddata com o retorno da transacao e mensagem
@author 	Fabio Cazarini
@since 		03/09/2016
@version 	1.0
@project	SuperAcao Apex-Brasil
/*/
//-----------------------------------------------------------------------
WSMETHOD ExcluiProjetoFenix WSRECEIVE IDProjeto, CodReduzido WSSEND Retorno WSSERVICE WSFenixProjeto
	LOCAL lRet			:= .T.
	LOCAL cIDProjeto	:= ALLTRIM(::IDProjeto)
	LOCAL cCodReduzi 	:= ALLTRIM(::CodReduzido)
	LOCAL nCnt			:= 0
	LOCAL cTransacao	:= ""
	LOCAL cMensagem		:= ""
	LOCAL cRetExec		:= ""
	LOCAL nOpc			:= 5 // 3=Inclui,4=Altera,5=Exclui
	LOCAL aAutoCab		:= {}
	LOCAL cCLVL			:= cIDProjeto
	LOCAL cQuery		:= ""
	LOCAL cCRLF			:= CHR(13) + CHR(10)

	//-----------------------------------------------------------------------
	// Busca a classe de valor de acordo com os parametros informados
	//-----------------------------------------------------------------------
	cQuery := " SELECT CTH.R_E_C_N_O_ AS REGNUM "
	cQuery += " FROM " + RetSqlName("CTH") + " CTH "
	cQuery += " WHERE	CTH.CTH_FILIAL = '" + xFILIAL("CTH") + "' " 
	IF !EMPTY(cIDProjeto)
		cQuery += " 	AND CTH.CTH_CLVL = '" + cIDProjeto + "'	"	
	ELSE
		IF !EMPTY(cCodReduzi)
			cQuery += " 	AND CTH.CTH_RES = '" + cCodReduzi + "'	"		
		ELSE
			cRetExec	:= "Ocorreu um erro na exclusao do projeto: " + cCRLF
			cRetExec	+= "Informe o parametro IDProjeto ou CodReduzido do projeto" + cCRLF
		ENDIF
	ENDIF
	cQuery += " 	AND CTH.D_E_L_E_T_ = ' '	"

	IF EMPTY(cRetExec)
		IF SELECT("TRBCTH") > 0
			TRBCTH->( dbCloseArea() )
		ENDIF    
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), "TRBCTH" ,.F.,.T.)

		//-----------------------------------------------------------------------
		// Busca a classe de valor a excluir
		//-----------------------------------------------------------------------
		DbSelectArea("TRBCTH")
		DbGoTop()
		IF !TRBCTH->( EOF() )
			DbSelectArea("CTH")
			DbGoTo( TRBCTH->REGNUM )

			cIDProjeto 	:= CTH->CTH_CLVL
			cDsProjeto 	:= CTH->CTH_DESC01
			dDtIniProj 	:= CTH->CTH_DTEXIS
			dDtFimProj 	:= CTH->CTH_DTEXSF
			cCodReduzi 	:= CTH->CTH_RES
			cCLASSE		:= CTH->CTH_CLASSE
			cBLOQ		:= CTH->CTH_BLOQ
		ELSE
			cRetExec	:= "Ocorreu um erro na exclusao do projeto: " + cCRLF
			cRetExec	+= "Nao foi localizado projeto para os parametros informados" + cCRLF
		ENDIF
		TRBCTH->( dbCloseArea() )
	ENDIF
	
	IF EMPTY(cRetExec)
		//-----------------------------------------------------------------------
		// Prepara a array do ExecAuto
		//-----------------------------------------------------------------------
		AADD(aAutoCab,{"CTH_CLVL"	, cIDProjeto	, NIL})
		AADD(aAutoCab,{"CTH_DESC01"	, cDsProjeto	, NIL})
		AADD(aAutoCab,{"CTH_DTEXIS"	, dDtIniProj	, NIL})
		AADD(aAutoCab,{"CTH_DTEXSF"	, dDtFimProj	, NIL})
		AADD(aAutoCab,{"CTH_RES"	, cCodReduzi	, NIL})
		AADD(aAutoCab,{"CTH_CLASSE"	, cCLASSE		, NIL})
		AADD(aAutoCab,{"CTH_BLOQ"	, cBLOQ			, NIL})
							
		//-----------------------------------------------------------------------
		// Altera a classe de valores via ExecAuto
		//-----------------------------------------------------------------------
		cRetExec	:= CTHExecA(aAutoCab, cCLVL, nOpc)
	ENDIF
	
	//-----------------------------------------------------------------------
	// Retorno da operacao:
	// cTransacao = "OK" ou cTransacao = "ERRO" 
	//-----------------------------------------------------------------------		
	IF EMPTY(cRetExec)
		cTransacao 	:= "OK"
		cMensagem	:= "Projeto excluido com sucesso"
	ELSE
		cTransacao 	:= "ERRO"
		cMensagem	:= cRetExec
	ENDIF	 
	
	::Retorno := U_ABXMLRET("ExcluiProjetoFenix", nOpc, cTransacao, cMensagem)
	
RETURN lRet


//-----------------------------------------------------------------------
/*/{Protheus.doc} CTHExecA()

Execauto CTBA060 - Classe de valores

@param		aAutoCab 		= Array do execauto CTBA060
			cCLVL 			= Código da classe de valores
			nOPC = 3/4/5	= Inclusão/Alteração/Exclusão
@return		cRet = Se não vazio, retorna o erro do execauto
@author 	Fabio Cazarini
@since 		03/09/2016
@version 	1.0
@project	SuperAcao Apex-Brasil
/*/
//-----------------------------------------------------------------------
STATIC FUNCTION CTHExecA(aAutoCab, cCLVL, nOpc)
	LOCAL cRet			:= ""
	LOCAL aErros		:= {}   
	LOCAL cLinErr		:= {}
	LOCAL nY 			:= 0
	LOCAL cCRLF			:= CHR(13) + CHR(10)

	PRIVATE lMsErroAuto 	:= .F.	// variável que define que o help deve ser gravado no arquivo de log e que as informações estão vindo à partir da rotina automática.
	PRIVATE lAutoErrNoFile	:= .T.

	DbSelectArea("CTH")
	CTH->( dbSetOrder(1) ) // CTH_FILIAL+CTH_CLVL
	lExiste := CTH->(dbSeek(xFilial('CTH') + cCLVL ))
	
	IF nOpc == 3 // inclusao
		IF lExiste 	
			cRet 	:= "Ocorreu um erro na " + IIF(nOpc==3,"inclusao",IIF(nOpc==4,"alteracao","exclusao")) + " do projeto: " + cCRLF
			cRet	+= "Projeto " + cCLVL + " ja existe" + cCRLF
		ENDIF
	ELSE		// alteracao / exclusao
		IF !lExiste 
			cRet 	:= "Ocorreu um erro na " + IIF(nOpc==3,"inclusao",IIF(nOpc==4,"alteracao","exclusao")) + " do projeto: " + cCRLF
			cRet	+= "Projeto " + cCLVL + " nao existe" + cCRLF
		ENDIF
	ENDIF

	IF EMPTY(cRet)
		//-----------------------------------------------------------------------
		// Ordenar um vetor conforme o dicionário do MSExecAuto
		//-----------------------------------------------------------------------
		aAutoCab	:= FWVetByDic( aAutoCab, 'CTH' )
	
		DbSelectArea("CTH")
		lMsErroAuto := .F.
		BeginTran()
		MsExecAuto({|x,y| CTBA060(x,y)}, aAutoCab, nOpc)
	
		IF lMsErroAuto
			DisarmTransaction()
	
			//-----------------------------------------------------------------------
			// Atribui a cRet o MOSTRAERRO()
			//-----------------------------------------------------------------------
			cRet 	:= "Ocorreu um erro na " + IIF(nOpc==3,"inclusao",IIF(nOpc==4,"alteracao","exclusao")) + " do projeto: " + cCRLF
	
			aErros	:= GetAutoGRLog()   
			FOR nY := 1 TO LEN(aErros)
				cLinErr	:= aErros[nY]
				cRet 	+= cLinErr + cCRLF
			NEXT                                
		ELSE
			IF nOPC == 3 // inclusao
				DbSelectArea("CTH")
				DbSetOrder(1) // CTH_FILIAL+CTH_CLVL
				IF !DbSEEK( xFILIAL("CTH") + cCLVL )
					cRet 	:= "Ocorreu um erro na " + IIF(nOpc==3,"inclusao",IIF(nOpc==4,"alteracao","exclusao")) + " do projeto: " + cCRLF
					cRet	+= "Verifique o log de transacoes no EAI " + cCRLF
	
					DisarmTransaction()
				ELSE
					EndTran()
					cRet := ""
				ENDIF	
			ELSEIF nOPC == 5 // exclusao
				DbSelectArea("CTH")
				DbSetOrder(1) // CTH_FILIAL+CTH_CLVL
				IF DbSEEK( xFILIAL("CTH") + cCLVL )
					cRet 	:= "Ocorreu um erro na " + IIF(nOpc==3,"inclusao",IIF(nOpc==4,"alteracao","exclusao")) + " do projeto: " + cCRLF
					cRet	+= "Verifique o log de transacoes no EAI " + cCRLF
	
					DisarmTransaction()
				ELSE
					EndTran()
					cRet := ""
				ENDIF	
			ELSE
				EndTran()
				cRet := ""
			ENDIF
		ENDIF
	ENDIF
	
RETURN cRet


//-----------------------------------------------------------------------
/*/{Protheus.doc} ABXMLRET()

Retorna um XML para resposta dos webservices

@param		cServico		= WS executado
			nOPC = 3/4/5	= Inclusão/Alteração/Exclusão
			cTransacao		= Transacao OK / ERRO
			cMensagem		= Mensagem de retorno
@return		cXmlRet = Se não vazio, retorna o erro do execauto
@author 	Fabio Cazarini
@since 		03/09/2016
@version 	1.0
@project	SuperAcao Apex-Brasil
/*/
//-----------------------------------------------------------------------
USER FUNCTION ABXMLRET(cServico, nOpc, cTransacao, cMensagem)
LOCAL cXmlRet 	:= ''
LOCAL cCRLF		:= CHR(13) + CHR(10)

cXmlRet += '<' + cServico + ' Operation="' + ALLTRIM(STR(nOpc)) + '" version="1.01">' + cCRLF
cXmlRet += '<Transacao>' + cTransacao + '</Transacao>' 
cXmlRet += '<Mensagem>' + cMensagem + '</Mensagem>'
cXmlRet += '</' + cServico + '>' + cCRLF

RETURN cXmlRet