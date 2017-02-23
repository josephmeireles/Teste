#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MT110TEL
//TODO Descrição:  Rotina Adiconar novos campos personalizados 
na solicitacao de compras.
@Project	SuperAcao Apex-Brasil.
@Author 	Joseph Oliveira / Analista de Serviços TOTVS.
@Since 16/01/2017.
@Version 1.0
@Type function
/*/
User function MT110TEL()

	Local oNewDialog := PARAMIXB[1]
	Local aPosGet    := PARAMIXB[2]
	Local nOpcx      := PARAMIXB[3]
	Local nReg       := PARAMIXB[4]
	Local cItens	 := space(15)
	Local oGet1
	Local oGet2 
	Local oGet3
	Local oGet4
	Local oGet5
	Local oGet6
	Local oGet7
	Local oGet8
	Local oGet9
	Local oCombo1
	Local oCombo2
	Local aItens1	 := {'1 - Aplicável','2 - Não Aplicável'}
	Local aItens2	 := {'1 - SIM	   ','2 - Não '}
	Local cAcao  	 := SPACE(30)//SPACE( LEN(SC1->C1_XDACAO) )
	Local cCodAcao 	 := SPACE(15)//SPACE( LEN(SC1->C1_XACAO) )
	Local cCombo1	 := SPACE(15)//SPACE( LEN(SC1->C1_XAPLIC) )
	Local cCombo2	 := SPACE(15)//SPACE( LEN(SC1->C1_XAPLIC) )
	Local cRespTec	 := SPACE( LEN( SC1->C1_SOLICIT ) )
	Local cAreaSolic := SPACE( LEN( CTT->CTT_DESC01 ) )
	Local cGestSolic := SPACE( LEN( CTT->CTT_MAT ) )
	Local cProjFenix := SPACE( LEN( SC1->C1_CLVL ) )
	Local cCodCenCus := SPACE( LEN( SC1->C1_CC ) )
	Local cEvento	 := SPACE( LEN( SC1->C1_XEVENTO ) )
	Local cVlrNego
	
	cAcao		:= SC1->C1_XDACAO
	cCodAcao	:= SC1->C1_XACAO
	cCombo1		:= SC1->C1_XAPLIC
	cRespTec	:= SC1->C1_SOLICIT
	cProjFenix	:= SC1->C1_CLVL
	cAreaSolic	:= CTT->CTT_DESC01
	cGestSolic	:= CTT->CTT_MAT
	cCodCenCus	:= SC1->C1_CC
	cEvento 	:= SC1->C1_XEVENTO
	cVlrNego	:= SC1->C1_XVNMES
	
	aadd(aPosGet[1],0)

	@ 64,022 SAY 'Proj. Fenix' Of oNewDialog PIXEL SIZE 30,9
	@ 64,077 MSGET oGet1 VAR cProjFenix OF oNewDialog PIXEL SIZE 79,10

	@ 63,222 SAY 'Cod. Ação Fenix' Of oNewDialog PIXEL SIZE 50,9
	@ 63,300 MSGET oGet2 VAR cCodAcao OF oNewDialog PIXEL SIZE 34,10

	@ 63,454 SAY 'Ação Fenix' Of oNewDialog PIXEL SIZE 50,9  
	@ 63,0563 MSGET oGet3 VAR cAcao OF oNewDialog PIXEL SIZE 72,10 

	@ 79,022 SAY 'Centro de Custo' Of oNewDialog PIXEL SIZE 40,9  
	@ 79,077 MSGET oGet4 VAR cCodCenCus OF oNewDialog PIXEL SIZE 34,10 

	@ 79,222 SAY 'Área. Solicitante' Of oNewDialog PIXEL SIZE 50,9  
	@ 79,300 MSGET oGet5 VAR cAreaSolic OF oNewDialog PIXEL SIZE 70,10 

	@ 79,454 SAY 'Descri. Técnica' Of oNewDialog PIXEL SIZE 50,9  
	@ 79,563 MSCOMBOBOX oCombo1 VAR cCombo1 ITEMS aItens1  OF oNewDialog PIXEL SIZE 70,10

	@ 95,022 SAY 'Gestor. Solicitante' Of oNewDialog PIXEL SIZE 30,9  
	@ 95,077 MSGET oGet6 VAR CGestSolic OF oNewDialog PIXEL SIZE 79,10 

	@ 95,222 SAY 'Resp. Técnico' Of oNewDialog PIXEL SIZE 50,9  
	@ 95,300 MSGET oGet7 VAR cRespTec OF oNewDialog PIXEL SIZE 70,10
	
	@ 95,454 SAY 'Ata. de Registro de Preço' Of oNewDialog PIXEL SIZE 70,9  
	@ 95,563 MSCOMBOBOX oCombo2 VAR cCombo2 ITEMS aItens2  OF oNewDialog PIXEL SIZE 70,10

	@ 111,022 SAY 'Evento' Of oNewDialog PIXEL SIZE 30,9  
	@ 111,077 MSGET oGet8 VAR cEvento OF oNewDialog PIXEL SIZE 79,10 

	@ 111,222 SAY 'Valor. Negócio' Of oNewDialog PIXEL SIZE 50,9  
	@ 111,300 MSGET oGet9 VAR cVlrNego PICTURE "@E 999,999,999.99" OF oNewDialog PIXEL SIZE 70,10

	oGet1:Refresh()
	oGet2:Refresh()
	oGet3:Refresh()
	oGet4:Refresh()
	oGet5:Refresh()
	oGet6:Refresh()
	oGet7:Refresh()
	oGet8:Refresh()
	oGet9:Refresh()
	oCombo1:Refresh()
	oCombo2:Refresh()

RETURN ()

/*/{Protheus.doc} MT110GET
//TODO Descrição: Manipula as dimensões do contorno dos campos do cabeçalho e 
o começo da GetDados.
@Author 	Joseph Oliveira / Analista de Serviços TOTVS.
@Since 16/01/2017.
@Version 1.0
@Type function
/*/
User Function MT110GET()

	Local aRet	:= PARAMIXB[1]

	aRet[2,1]	:= 128 // Abaixando o começo da linha da GetDados.
	aRet[1,3] 	:= 126 // Abaixando a linha de contorno dos campos do cabeçalho.

Return(aRet)