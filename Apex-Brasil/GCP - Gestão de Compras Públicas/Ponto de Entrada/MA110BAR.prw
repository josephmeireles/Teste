#Include 'Protheus.ch'
#Include 'Parmtype.ch'
#Include 'Rwmake.CH'
#Include 'Topconn.ch'

/*/{Protheus.doc} MA110BAR
//TODO Descrição: Ponto de Entrada na Solicitação de Compras para incluir botões.
@Project	SuperAcao Apex-Brasil.
@Author 	Joseph Oliveira / Analista de Serviços TOTVS.
@since 		24/01/2017
@version 	1.0
@type 		Function
/*/
User Function MA110BAR()

Local aRet   := {}

Aadd(aRet,{ "Cam"    , {|| TelCamp() }, "Campos Complem.", "Campos Complem." } )
Aadd(aRet,{ "For"    , {|| GridForn()}, "Fornecedor", "Fornecedor" } )

Return(aRet)

/*/{Protheus.doc} TelCamp
//TODO Descrição Tela contendo os campos complementares da Solicitação de Compras.
@Project	SuperAcao Apex-Brasil.
@Author 	Joseph Oliveira / Analista de Serviços TOTVS.
@Since 		24/01/2017
@Version 	1.0
@Type 		Function
/*/
Static FUNCTION TelCamp()

Local aArea		:= GetArea()
Local aAreaPA5	:= PA5->( GetArea() )

Private	cJust	:= ""
Private cExig	:= ""
Private cNecs	:= ""
Private cObj	:= ""
Private cOrca	:= ""
Public  cNum	:= cA110num

		cJust	:= SPACE( LEN( PA5->PA5_JEXIGE ) )
		cExig	:= SPACE( LEN( PA5->PA5_EXIGEN ) )
		cNecs	:= SPACE( LEN( PA5->PA5_JUSTIC ) )
		cObj	:= SPACE( LEN( PA5->PA5_OBJETO ) )

		DbSelectArea("PA5")	   // Seleciona a área da tabela PA5.
		PA5->( DbSetOrder(1) ) // Ordena Tabela PA5 Filial + PA5_NUMSC.
		PA5->(DbGoTop())	  // Posiciona no topo da tabela PA5.

		If	PA5->( DbSeek ( FWxFilial ( "SC1" ) + cNum) ) 
		
			If !Empty(PA5->PA5_JEXIGE)
				cJust	:= PA5->PA5_JEXIGE				
			EndIf

			If !Empty(PA5->PA5_EXIGEN)	
				cExig	:= PA5->PA5_EXIGEN
			EndIf

			If !Empty(PA5->PA5_JUSTIC)
				cNecs	:= PA5->PA5_JUSTIC						
			EndIf

			If !Empty(PA5->PA5_OBJETO)
				cObj	:= PA5->PA5_OBJETO			
			EndIf
			
			If !Empty(PA5->PA5_ORCAME)
				cOrca	:= PA5->PA5_ORCAME			
			EndIf
								
		EndIf
	
// Declaração de Variaveis Private dos Objetos 
                            ±±
SetPrvt("_oDlg1","_oSay1","_oSay2","_oSay3","_oSay4","_oSay5","_oMGet1","_oMGet2","_oMGet3",;
"_oMGet4","_oGet1")

// Definicao do Dialog e todos os seus componentes.        

_oDlg1      := MSDialog():New( 022,321,620,1165,"Campos Complementares",,,.F.,,,,,,.T.,,,.T. )

_oSay1      := TSay():New( 012,036,{||"Orçamento:"},_oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
_oGet1      := TGet():New( 010,072,{|u| If(PCount()>0,cOrca:=u,cOrca)},_oDlg1,048,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cOrca",,)

_oSay2      := TSay():New( 023,036,{||"Justificativa a Necessidade da Compra :"},_oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,104,008)
_oMGet1     := TMultiGet():New( 034,035,{|u| If(PCount()>0,cJust:=u,cJust)},_oDlg1,361,049,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.F.,,,.F.,,  )

_oSay3      := TSay():New( 087,036,{||"Descreva as exigências técnicas, se aplicáveis:"},_oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,120,008)
_oMGet2     := TMultiGet():New( 095,036,{|u| If(PCount()>0,cExig:=u,cExig)},_oDlg1,360,049,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.F.,,,.F.,,  )

_oSay4      := TSay():New( 149,036,{||"Objeto:"},_oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,024,008)
_oMGet3     := TMultiGet():New( 157,036,{|u| If(PCount()>0,cObj:=u,cObj)},_oDlg1,360,052,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.F.,,,.F.,,  )

_oSay5      := TSay():New( 213,036,{||"Justifique a necessidade das exigências técnicas, se aplicáveis:"},_oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,156,008)
_oMGet4     := TMultiGet():New( 221,036,{|u| If(PCount()>0,cNecs:=u,cNecs)},_oDlg1,360,052,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.F.,,,.F.,,  )

_oBtn1      := SButton():New( 283,370,1,{||_oDlg1:end()},_oDlg1,,"", )
_oBtn2      := SButton():New( 283,333,2,{||_oDlg1:end()},_oDlg1,,"", )

_oDlg1:Activate(,,,.T.)

RestArea(aArea)
RestArea(aAreaPA5)

Return  

/*/{Protheus.doc} GridForn
//TODO Descrição auto-gerada.
@Project	SuperAcao Apex-Brasil.
@Author 	Joseph Oliveira / Analista de Serviços TOTVS.
@since 		24/01/2017
@version 	1.0
@type function
/*/
Static Function GridForn()                                      
Local oButton1
Local oButton2
Local oFont1 := TFont():New("MS Sans Serif",,022,,.F.,,,,,.F.,.F.)
Local oSay1
Static oDlg

  DEFINE MSDIALOG oDlg TITLE "Dados do Fornecedor" FROM 000, 000  TO 538, 802 COLORS 0, 16777215 PIXEL

    @ 008, 011 SAY oSay1 PROMPT "Dados do Fornecedor" SIZE 098, 013 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
    fWBrowse1()
    oButton1      := SButton():New( 006,318,1,{||oDlg:end()},oDlg,,"", )
    oButton2      := SButton():New( 006,355,2,{||oDlg:end()},oDlg,,"", )

  ACTIVATE MSDIALOG oDlg CENTERED

Return

/*/{Protheus.doc} fWBrowse1
//TODO Descrição auto-gerada.
@Project	SuperAcao Apex-Brasil.
@Author 	Joseph Oliveira / Analista de Serviços TOTVS.
@since 		24/01/2017
@version 	1.0
@type function
/*/
Static Function fWBrowse1()

Local 	oWBrowse1
Local 	aWBrowse1 	:= {}

Local 	x			:= 0
Local 	aArea    	:= GetArea()
//Local 	aAreaPA6 	:= PA6->(GetArea())
Local 	cQuery   	:= ""

Local   cNum		:= cA110num
		cSC			:= SPACE( LEN( PA6->PA6_NUMSC  ) )
		cCodForn	:= SPACE( LEN( PA6->PA6_CFORNE ) )
		cLoja		:= SPACE( LEN( PA6->PA6_LOJAFO ) )
		cNomeFor	:= SPACE( LEN( PA6->PA6_NFORNC ) )

//		DbSelectArea("PA6")	   // Seleciona a área da tabela PA6.
//		PA6->( DbSetOrder(1) ) // Ordena Tabela PA6 Filial + PA6_NUMSC.
//		PA6->( DbGoTop() )	  // Posiciona no topo da tabela PA6.

cQuery := " SELECT " + CRLF
cQuery += "     PA6.PA6_NUMSC, "  +  CRLF
cQuery += "     PA6.PA6_CFORNE, " +  CRLF
cQuery += "     PA6.PA6_LOJAFO, " +  CRLF
cQuery += "     PA6.PA6_NFORNC "  +  CRLF
cQuery += " FROM " + RetSqlName("PA6")  + " PA6 "     + CRLF
cQuery += " WHERE PA6.PA6_NUMSC  = '"   + cnum + "' " + CRLF
cQuery += "   AND PA6.PA6_FILIAL = '"   + xFilial ("PA6") + "' " + CRLF
cQuery += "   AND PA6.D_E_L_E_T_ = '' " + CRLF
cQuery += " ORDER BY PA6.PA6_FILIAL,PA6.PA6_NUMSC,PA6.PA6_CFORNE " + CRLF
cQuery := ChangeQuery(cQuery)

If Select("QRY") > 0
	Dbselectarea("QRY")
	QRY->(DbClosearea())
EndIf

TcQuery cQuery New Alias "QRY"

dbSelectArea("QRY")
QRY->(dbGoTop())

	While ! QRY->(EoF())
		// Inserindo os Itens.
		Aadd(aWBrowse1,{QRY->PA6_CFORNE, QRY->PA6_LOJAFO, QRY->PA6_NFORNC})
		QRY->(dbSkip())
	
	EndDo

    @ 027, -001 LISTBOX oWBrowse1 Fields HEADER "Cod","Loja","Nome" SIZE 405, 243 OF oDlg PIXEL ColSizes 50,50
    oWBrowse1:SetArray(aWBrowse1)
    oWBrowse1:bLine := {|| {;
      aWBrowse1[oWBrowse1:nAt,1],;
      aWBrowse1[oWBrowse1:nAt,2],;
      aWBrowse1[oWBrowse1:nAt,3],;
    }}

       // Evento Duplo Clique.

//    oWBrowse1:bLDblClick := {|| aWBrowse1[oWBrowse1:nAt,1] := !aWBrowse1[oWBrowse1:nAt,1],;
//    oWBrowse1:DrawSelect()}

//    RestArea( aAreaPA6 )
	QRY->(DbCloseArea())
    RestArea( aArea )

Return