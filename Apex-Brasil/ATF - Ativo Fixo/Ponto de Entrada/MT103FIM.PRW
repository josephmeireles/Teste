#include "Protheus.ch"
#include "rwmake.ch"       

#Define cENTER Chr(13) + Chr(10)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MT103FIM  บAutor  ณ TOTVS            บ Data ณ  12/12/2016  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gravar informa็๕es em campos especํficos no Documento de   บฑฑ
ฑฑบ          ณ Entrada, Possui VAT? (SF1->F1_XVAT) e Valor do VAT         บฑฑ
ฑฑบ          ณ (SF1->F1_XVLVAT) e nos Tํtulos a Pagar no m๓dulo           บฑฑ
ฑฑบ          ณ Financeiro, Possui VAT? (SE2->E2_XVAT) e Valor do VAT      บฑฑ
ฑฑบ          ณ (SE2->E2_XVLVAT)                                           บฑฑ
ฑฑบ          ณ MIT - FIN003                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Apex                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function MT103FIM()

Local _cArea	 := GetArea()
Local nOpcao     := PARAMIXB[1] 		// Op็ใo Escolhida pelo usuario no aRotina
Local nConfirma  := PARAMIXB[2] 		//
Local _cQry      := ''
Local aVencto    := {}
Local lTrue      := .T.
Local nI         := 1
Local nCnt       := 0
Local cEdit1     := Space(25)
Local oEdit1
Local oEdit2
Local _cPXVAT    := "N"
Local _nVXVAT    := 0   
Local nOpca      := 0
Private _oDlg                    // Dialog Principal

If (nOpcao == 3 .or. nOpcao == 4)  

  If Empty(cNFiscal) <> .T.
	
	DEFINE MSDIALOG _oDlg TITLE " VAT " FROM C(178),C(181) TO C(310),C(460) PIXEL
	
	@ C(005),C(003) SAY "Possui VAT? (S/N)" SIZE 55,07 COLOR CLR_BLACK PIXEL OF _oDlg
	@ C(005),C(060) MSGET oEdit1 Var _cPXVAT SIZE 10,07 COLOR CLR_BLACK PIXEL PICTURE "@!" VALID _cPXVAT $ "SN"
	
	@ C(020),C(003) SAY "Valor VAT : " SIZE 55,07 COLOR CLR_BLACK PIXEL OF _oDlg
	@ C(020),C(060) MSGET oEdit2 Var _nVXVAT SIZE 55,07 COLOR CLR_BLACK PIXEL PICTURE "@E 99,999,999.99"
	
 	@ C(051),C(028)  BMPBUTTON TYPE 1 ACTION (nOpca := 1,_oDlg:End())
	@ C(051),C(080)  BMPBUTTON TYPE 2 ACTION (nOpca := 0,_oDlg:End())    
	
	ACTIVATE MSDIALOG _oDlg CENTERED
	
	If nOpca == 1
       u_GravaVAT(_cPXVAT,_nVXVAT)
	EndIf
	
  EndIf
	
EndIf

RestArea(_cArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GravaVAT  บAutor  ณ TOTVS            บ Data ณ  12/12/2016  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para gravar os campos no SF1 e SE2                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Apex                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function GravaVAT(_cPXVAT,_nVXVAT)

Local _cF1XVAT   := _cPXVAT
Local _cF1XVLVAT := _nVXVAT

Reclock("SF1",.F.)
SF1->F1_XVAT    := _cF1XVAT
SF1->F1_XVLVAT  := _cF1XVLVAT
MsUnlock()

// Verifica os Titulos Gerados no SE2

_cQry := "SELECT R_E_C_N_O_ E2_RECNO FROM "+RETSQLNAME('SE2')+" SE2 "+cENTER
_cQry += "WHERE SE2.D_E_L_E_T_ = ' '         "+cENTER
_cQry += " AND SE2.E2_NUM='"+SF1->F1_DOC+"'	 "+cENTER
_cQry += " AND SE2.E2_PREFIXO = '"+SF1->F1_PREFIXO+"' "+cENTER
_cQry += " AND SE2.E2_FORNECE = '"+SF1->F1_FORNECE+"' "+cENTER
_cQry += " AND SE2.E2_LOJA = '"+SF1->F1_LOJA+"'       "+cENTER

dbUseArea(.T., "TOPCONN", TCGenQry(,,_cQry), "TMPSE2", .F., .T.)

dbSelectArea("TMPSE2")
TMPSE2->( dbGotop() )

WHILE !TMPSE2->( EOF() )
	
	DbSelectArea("SE2")
	DBGOTO(TMPSE2->E2_RECNO)
	Reclock("SE2",.F.)
	SE2->E2_XVAT    := _cF1XVAT
	SE2->E2_XVLVAT  := _cF1XVLVAT
	MsUnlock()
	
	DBSELECTAREA("TMPSE2")
	
	dbSkip()
END

DbCloseArea("TMPSE2")

Return
