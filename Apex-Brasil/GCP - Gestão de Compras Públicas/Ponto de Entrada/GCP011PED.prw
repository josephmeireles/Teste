#include "PROTHEUS.CH"
#include "RWMAKE.CH"
#include "FWMVCDEF.CH"
#include "FWMBROWSE.CH"
#include "TBICONN.CH"
#include "TOPCONN.CH"
#include "FILEIO.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} GCP011PED.PRW

P.E. após a inclusão da S.C. na Gestao de Compras Publicas [Modulo=87]

@sample	 Nenhum		
@param	 Nenhum
@return	 Nenhum
@author	 luciano.camargo - TOTVS
@since	 14/02/2017
@version 1.0
@obs     Criado para replicar dados do convenio ao Pedido de Compra
@obs     Existe P.E. semelhante para replicar dados do convênio ao Contrato
/*/

user function GCP011PED()

	Local _aCab 	:= PARAMIXB[1]
	Local _aItens 	:= PARAMIXB[2]
	Local _aRatCTB 	:= PARAMIXB[3]
	Local _aArea	:= GetArea()
	Local _cConv
	Local _cAcao
	Local _cCodAcao
	Local _cItem
	Local _cCCRed
	Local _cSiconv
	Local _cDossie
	Local _cAtaReg

	cXFilial := xFilial("SC1",cFilOrig)
	BeginSQL Alias "TmpSC1"
	SELECT * FROM %Table:SC1% SC1
	WHERE SC1.%NotDel% AND
		SC1.C1_FILIAL = %Exp:cXFilial% AND
		SC1.C1_CODED = %Exp:CO1->CO1_CODEDT% AND
		SC1.C1_NUMPR = %Exp:CO1->CO1_NUMPRO% AND
		SC1.C1_FILIAL <> SC1.C1_FILENT
	EndSQL

	// Posicionar na SC
	_cConv      := TmpSC1->C1_XCONV
	_cAcao		:= TmpSC1->C1_XDACAO
	_cCodAcao	:= TmpSC1->C1_XACAO
	_cItem		:= TmpSC1->C1_XITEM
	_cCCRed		:= TmpSC1->C1_XCCRED
	_cSiconv	:= TmpSC1->C1_XSICON
	_cDossie	:= TmpSC1->C1_XDOSSI
	_cAtaReg	:= TmpSC1->C1_XATARE

	TmpSC1->(dbCloseArea())

	aAdd(aTail(_aItens),{"C7_XCONV"		, _cConv		,NIL})  // Codigo do convênio
	aAdd(aTail(_aItens),{"C7_XDACAO"	, _cAcao		,NIL})  // Descrição da Ação Fenix
	aAdd(aTail(_aItens),{"C7_XACAO"		, _cCodAcao  	,NIL})  // Codigo da Ação Fenix
	aAdd(aTail(_aItens),{"C7_XITEM"  	, _cItem      	,NIL})  // Item Orçamentario
	aAdd(aTail(_aItens),{"C7_XCCRED"	, _cCCRed		,NIL})  // Centro de Custo Reduzido
	aAdd(aTail(_aItens),{"C7_XSICON"   	, _cSiconv   	,NIL})  // Numero SICONV
	aAdd(aTail(_aItens),{"C7_XDOSSI" 	, _cDossie     	,NIL})  // Numero do Dossiê
	aAdd(aTail(_aItens),{"C7_XATARE"	, _cAtaReg 		,NIL})  // Ata de registro de preço

	// Ordenar um vetor conforme o dicionário para uso em rotinas de MSExecAuto
	_aCab	:= FWVetByDic( _aCab, 'SC7' )

RestArea(_aArea)

Return( {_aCab, _aItens, _aRatCTB} )