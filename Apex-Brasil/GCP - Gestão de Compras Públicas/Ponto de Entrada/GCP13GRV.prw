#include "PROTHEUS.CH"
#include "RWMAKE.CH"
#include "FWMVCDEF.CH"
#include "FWMBROWSE.CH"
#include "TBICONN.CH"
#include "TOPCONN.CH"
#include "FILEIO.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} GCP13GRV.prw

P.E. ap�s a inclus�o da S.C. na Gestao de Compras Publicas [modulo=87]

@sample	 Nenhum		
@param	 Nenhum
@return	 Nenhum
@author	 luciano.camargo - TOTVS
@since	 15/02/2017
@version 1.0
@obs     Criado para replicar dados do convenio ao Contrato
/*/

user function GCP13GRV()

	Local _aArea	:= GetArea()

	RecLock("CN9",.F.)
	CN9->CN9_XCONV 	:= SC1->C1_XCONV    // Codigo do conv�nio
	CN9->CN9_XDACAO := SC1->C1_XDACAO   // Descri��o da A��o Fenix
	CN9->CN9_XACAO	:= SC1->C1_XACAO	// Codigo da A��o Fenix
	CN9->CN9_XITEM	:= SC1->C1_XITEM	// Item Or�amentario
	CN9->CN9_XCCRED	:= SC1->C1_XCCRED 	// Centro de Custo Reduzido
	CN9->CN9_XSICON	:= SC1->C1_XSICON	// Numero SICONV
	CN9->CN9_XDOSSI	:= SC1->C1_XDOSSI	// Numero do Dossi�
	CN9->CN9_XATARE	:= SC1->C1_XATARE	// Ata de registro de pre�o
	CN9->(MsUnLock())
	
RestArea(_aArea)

Return(.T.)