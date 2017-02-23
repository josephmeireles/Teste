#include "PROTHEUS.CH"
#include "RWMAKE.CH"
#include "FWMVCDEF.CH"
#include "FWMBROWSE.CH"
#include "TBICONN.CH"
#include "TOPCONN.CH"
#include "FILEIO.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} ABCTBI02.PRW

Importação de moedas do banco central, a partir de arquivo .CSV

@sample	 Nenhum		
@param	 _lAut = .T. ->Chamado por Schedule
@param	 _lAut = .F. ->Chamado por Menu
@return	 Nenhum
@author	 luciano.camargo - TOTVS
@since	 09/02/2017
@version 1.5
@obs     17-02-2017 / luciano.camargo - TOTVS / limpeza no codigo, correção gravação CTP e SM2, e testes com PA1 populada
@obs     20-02-2017 / luciano.camargo - TOTVS / Corrigido para não fazer download de arquivo .CSV com data de final de semana
@todo    colocar rodando no ambiente Schedule
/*/

user function ABCTBI02(_lAut)

	Local _dDataAtu	
	Local _dDataIni	
	Local _dDataProc
	Local _dbSiglas
	Local _cLine
	Local _nX
	Local _nX1
	Local _cCpo
	Local _aRelac   := {}
	Local _cHtml 	:= ""
	Local _cArq     := ""
	Local _cDirPath	:= ""
	Local _cUrl 	:= "" 
	Local _aSiglas  := {}
	Local _aLinha   := {}
	Local _aLin     := {}
	Default _lAut   := .F.

	If _lAut
		PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" MODULO "COM" TABLES "PA1","CTP","SM2"
	Endif

	_dDataAtu	:= dDataBase-1
	_dDataIni	:= DaySub(_dDataAtu,2)
	_dDataProc  := _dDataIni
	_cDirPath	:= GetNewPar("AB_CTBMOED","\Banco Central\")
	_cUrl 		:= GetNewPar("AB_CTBMOEL","http://www4.bcb.gov.br/Download/fechamento/") 

	CONOUT("ABIMP01 - Iniciando obtenção dos arquivos no Banco Central")
	// Efetuar baixa dos arquivos
	while _dDataProc <= _dDataAtu

		_cArq  := DtoS(_dDataProc)+".CSV"
		If Dow(_dDataProc) >= 2 .and. Dow(_dDataProc) <= 6 // Só existe cotações durante a semana
			_cHtml := HttpGet(_cUrl+_cArq)
			MemoWrite(_cDirPath+_cArq,_cHtml)
			CONOUT("ABIMP01 - Arquivo Obtido: "+_cArq)
		Else
			CONOUT("ABIMP01 - Não existe cotação a obter para esta data: "+_cArq)
		Endif
		_dDataProc ++ 

	enddo

	// Obter relação das moedas utilizadas pelos escritorios [PA1] CODIGO MOEDA PROTHEUS=PA1_MOEDA, SIGLA BANCO CENTRAL=P1_SIGLA
	CONOUT("ABIMP01 - Obter relação das moedas utilizadas pelos escritorios [PA1]")

	BeginSql alias "dbSiglas"

	SELECT DISTINCT PA1_SIGLA, PA1_MOEDA
	FROM %table:PA1% PA1
	WHERE PA1.%notDel%

	EndSql

	while !dbSiglas->(Eof())
		Aadd( _aSiglas, {dbSiglas->PA1_SIGLA, dbSiglas->PA1_MOEDA} ) // Sigla Moeda BCB=USD, Codigo Moeda Protheus [01,02,...]
		dbSiglas->(DbSkip())
	enddo
	dbSiglas->(dbCloseArea())

	// Efetuar processamento dos arquivos e salvar na CTP e SM2
	CONOUT("ABIMP01 - Efetuar processamento dos arquivos e salvar na CTP e SM2")

	_dDataProc:= _dDataIni
	while _dDataProc <= _dDataAtu .and. Len(_aSiglas)<>0

		_cArq := DtoS(_dDataProc)+".CSV"
		CONOUT("ABIMP01 - Lendo: "+_cArq)

		// Ler arquivo CSV
		_cLine := MemoRead( _cDirPath+_cArq )
		_aLinha := {}

		// Varre todas as linhas do texto jogando para array
		for _nX := 1 To MLCount( _cLine )

			_aLin := Separa( MemoLine( _cLine, , _nX ),";" )

			// Importar apenas moedas que existam escritorios vinculados
			If ( aScan( _aSiglas,{|x| AllTrim(x[1])==AllTrim(_aLin[4]) } ) <> 0 )
				Aadd( _aLinha, _aLin )
			Endif

		next _nX		

		for _nX := 1 To Len(_aLinha)

			// Sequencia dos campos do arquivo .CSV
			// DT_IMPORTACAO,CD_MOEDA,TP_MOEDA,SG_MOEDA,TX_COMPRA,TX_VENDA,VL_PARIDADE_COMPRA,VL_PARIDADE_VENDA
			// 18/08/2016;005;A;AFN;0,04769000;0,04784000;67,34000000;67,54000000

			// Atualizar Cambio
			CONOUT("ABIMP01 - Salvando CTP: "+DtoS(_dDataProc))
			CTP->( DbSetOrder(2), DbSeek(xFilial("CTP")+_aSiglas[_nX][2]+DtoS(_dDataProc)) ) //2=CTP_FILIAL+CTP_MOEDA+DTOS(CTP_DATA)                                                                                                                                                                                                                                                          
			RecLock("CTP", CTP->(Eof()) )
			CTP->CTP_FILIAL	:= xFilial("CTP")
			CTP->CTP_DATA	:= _dDataProc 	// Data
			CTP->CTP_MOEDA 	:= _aSiglas[_nX][2] 	// Codigo da moeda
			CTP->CTP_TAXA	:= Val(StrTran(_aLinha[_nX][5],",",".")) // Taxa de compra
			CTP->CTP_BLOQ	:= "2"
			CTP->(MsUnlock())

			// Atualizar moedas do sistema - IMPORTANTE: Existe um registro pra varias moedas, ou seja, nao existe o campo filial
			CONOUT("ABIMP01 - Salvando SM2: "+DtoS(_dDataProc))
			SM2->( DbSetOrder(1), DbSeek(+DtoS(_dDataProc)) ) //1=M2_DATA
			_cCpo := "M2_MOEDA"+AllTrim(Str(Val(_aSiglas[_nX][2])))
			if SM2->(FIELDPOS(_cCpo)) > 0
				RecLock("SM2", SM2->(Eof()))
				SM2->M2_DATA	:= _dDataProc
				SM2->(&_cCpo) 	:= Val(StrTran(_aLinha[_nX][5],",",".")) // Taxa de compra
				SM2->(MsUnlock())
			endif

		next _nX

		_dDataProc ++ 

	enddo

return