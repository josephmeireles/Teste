#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FILEIO.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ RdMake   ³ ABIMP01  ³ Autor ³ TOTVS              º Data ³  26/12/16   º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Importa arquivo CSV - SICONV.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ APEX                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function ABIMP01()

Local cDataAtu	:= DdataBase
Local cDataAnt	:= DaySub(cDataAtu,1)
Local cDataFim	:= Dtos(cDataAnt)
Local cHtml 	:= ""
Local cCaminho	:= ""
Local cPath		:= "C:\SICONV\"
////Local cPath		:= "\Banco Central\"
////Local cUrl 		:= "http://www4.bcb.gov.br/Download/fechamento/"+cDataFim+".csv"
Local cUrl 		:= "http://portal.convenios.gov.br/images/docs/CGSIS/csv/siconv_desembolso.csv"


cHtml := HttpGet(cUrl)

cCaminho := cPath + SubStr( cUrl, Rat("/",cUrl) + 01 )
MemoWrite(cCaminho,cHtml)

WaitRunSrv("C:\SICONV\download.bat",.T.,"C:\SICONV\")  

IMPSIC01()

Return cCaminho

//-----------------------------------------------------------------------------------------
//-------------------- Soulucao que sera executada para a integracao SICONV-------------------------------------
/*
Local cHtml := ""
Local cCaminho := ""
Local cPath    := "\SICONV\"


Prepare Environment empresa "99" filial "01"
WaitRunSrv("C:\SICONV\download.bat",.T.,"C:\SICONV\")
reset environment
Return
*/
//--------------------------------------------------------------------------------------------------------------              


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ RdMake   ³ IMPSIC01  ³ Autor ³ TOTVS              º Data ³  26/12/16  º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina de importacao do arquivo.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ APEX                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


Static Function IMPSIC01()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aArea		  := GetArea()
Local cType		  := "Arquivos CSV|*.CSV|Todos os Arquivos|*.*"  

Local nOpca		  := 0
Local aSays		  := {}
Local aButtons	  := {}
Local cCadastro	  := OemToAnsi("Importa os dados da planilha do SICONV")

Private _dXDATE   := dDatabase     //Subs(DTOS(ddatabase),7,2)+Subs(DTOS(ddatabase),5,2)+Subs(DTOS(ddatabase)
Private _cXUSER   := SUBSTR(CUSUARIO,7,15)
Private _Coduser  := __CUSERID
Private nHandle	  := 0
Private _cArquivo := ""

_cArquivo := "C:\SICONV\siconv_desembolso.csv"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida se o arquivo existe                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If Empty(_cArquivo)
////	Aviso("Atenção!","Selecione o caminho válido!",{"Ok"})
	Return
Else	
	IMPSIC02()
Endif

RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ RdMake   ³ IMPSIC02  ³ Autor ³ TOTVS              º Data ³  26/12/16  º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina de importacao do arquivo.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ APE                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function IMPSIC02()

Local cArq    := _cArquivo
Local cDir    := ""   //_cLocal
Local cLinha  := ""
Local lPrim   := .T.
Local aCampos := {}
Local aDados  := {}
Local nTamFile
Local nTamLin
Local cBuffer
Local nBtLidos
Local _cFileLog
Local _cPath := ""
Local _cDataN := Subs(DTOS(ddatabase),7,2)+Subs(DTOS(ddatabase),5,2)+Subs(DTOS(ddatabase),3,2)
Local _dBaixa := dDatabase
//Local _cTimeN := Sustr(Time(),1,2)+Sustr(Time(),4,2)+Sustr(Time(),6,2)
Local i, _nHdl
Local _nCt       := 0
Local _lAprov    := .T.
Local _cTXDEPR1  := 0
Local _cVLSALV1  := 0
Local _cVMXDEPR  := 0

Local  _cBanco	   := ""
Local  _cAgencia   := ""
Local  _cConta	   := ""

Local _cNRCONVENIO           := "" // Numero do Convênio
Local _dDTULTDESEMBOLSO      := "" // Data do ultimo desembolso.
Local _nQTDDIASSEMDESEMBOLSO := "" // Quantidade de dias sem desembolso.
Local _dDTDESEMBOLSO         := "" // Data do desembolso.
Local _dANODESEMBOLSO        := "" // Ano desembolso.
Local _dMESDESEMBOLSO        := "" // Mês desembolso.
Local _cNRSIAFI              := "" // Numero SIAFI.
Local _nVLDESEMBOLSADO       := "" // Valor do desembolso.
Private cNomArq              := "IMPSICONV_"+_cDataN+".LOG"
Private _cDirPro             := "C:\SICONV\" + cNomArq
Private aErro := {}

////If !File(cArq)
////	MsgStop("O arquivo " +cArq + " não foi encontrado. Por favor, verifique os parâmetros!","[IMPSICONV] - ATENCAO")
///	Return
///EndIf

AutoGrLog("----------------------------------------------------------")
AutoGrLog("LOG DE IMPORTAÇÃO DA PLANILHA DO SICONV")
AutoGrLog("----------------------------------------------------------")
AutoGrLog("ARQUIVO............: "+_cArquivo)
AutoGrLog("DATABASE...........: "+Dtoc(dDataBase))
AutoGrLog("DATA...............: "+Dtoc(MsDate()))
AutoGrLog("HORA...............: "+Time())
AutoGrLog("ENVIRONMENT........: "+GetEnvServer())
AutoGrLog("VERSÃO.............: "+GetVersao())
AutoGrLog("MÓDULO.............: "+"SIGA"+cModulo)
AutoGrLog("EMPRESA / FILIAL...: "+SM0->M0_CODIGO+"/"+SM0->M0_CODFIL)
AutoGrLog("NOME EMPRESA.......: "+Capital(Trim(SM0->M0_NOME)))
AutoGrLog("NOME FILIAL........: "+Capital(Trim(SM0->M0_FILIAL)))
AutoGrLog("USUÁRIO............: "+SubStr(cUsuario, 7, 15))
AutoGrLog("----------------------------------------------------------")
AutoGrLog(" ")

_nHdl := FT_FUSE(cArq) //FOpen(cArq, 0)

If _nHdl < 0
	ApMsgStop('Problemas na abertura do arquivo de importação', 'ATENÇÃO' )
	return NIL
EndIf

ProcRegua(FT_FLASTREC())
FT_FGOTOP()

While !FT_FEOF()
	
	IncProc("Lendo arquivo texto...")
	
	cLinha := FT_FREADLN()
	
	If lPrim
		aCampos := Separa(cLinha,";",.T.)
		lPrim := .F.
	Else
		AADD(aDados,Separa(cLinha,";",.T.))
	EndIf
	
	FT_FSKIP()
EndDo

ProcRegua(Len(aDados))
For i:=1 to Len(aDados)
	
	_lAprov    := .T.
	
	IncProc("Importando dados da planilha...")
	
	_nCt++
	
	_cPrefixo               := "AAA"       //  verificar  qual o prefixo será utilizado
	
	_cNRCONVENIO            := aDados[i,1]
	_dDTULTDESEMBOLSO       := aDados[i,2]
	_nQTDDIASSEMDESEMBOLSO  := aDados[i,3]
	_dDTDESEMBOLSO          := aDados[i,4]
	_dANODESEMBOLSO         := aDados[i,5]
	_dMESDESEMBOLSO         := aDados[i,6]
	_cNRSIAFI               := aDados[i,7]
	_nVLDESEMBOLSADO        := aDados[i,8]
	
	
	dbSelectArea("SE2")
	dbSetOrder(1)
	dbGoTop()
	
	If dbSeek(xFilial("SE2")+_cPrefixo+_cNRSIAFI)
		
		DbSelectArea("SA6")
		DbOrderNickName("XCHVATVD1")
		
		If !dbSeek(xFilial("SA6")+_cNRCONVENIO)
			AutoGrLog("Linha.: "+Str(_nCt, 5)+"   Filial - "+_cFILIAL+" Numero SIAFI - "+_cNRSIAFI+" Número de Convênio  - "+_cNRCONVENIO+ " - Banco não encontrado (SA6)!")
			AutoGrLog(REPLICATE("=", 70))
		Else
			_cBanco	   := SA6->A6_COD
			_cAgencia  := SA6->A6_AGENCIA
			_cConta	   := SA6->A6_NUMCON
		Endif
		
		If _nValor > 0
			aBaixa := {{"E2_PREFIXO"	  , _cPrefixo					, Nil},;
		   			   {"E2_NUM"		  , _cNRSIAFI					, Nil},;
			 		   {"E2_PARCELA"	  , SE2->E2_PARCELA				, Nil},;
			           {"E2_TIPO"	      , SE2->E2_TIPO				, Nil},;
			           {"E2_FORNECE"	  , SE2->E2_FORNECE				, Nil},;
			           {"E2_LOJA"	      , SE2->E2_LOJA				, Nil},;
			           {"AUTBANCO"	      , _cBanco						, Nil},;
			           {"AUTAGENCIA"	  , _cAgencia					, Nil},;
			           {"AUTCONTA"	      , _cConta						, Nil},;
			           {"AUTMOTBX"	      , "NOR"						, Nil},;
			           {"AUTDTBAIXA"	  , _dBaixa     				, Nil},;
			           {"AUTDTCREDITO"    , SE2->E2_EMISSAO				, Nil},;
			           {"AUTHIST"	      , "Valor pago s/ Titulo "		, Nil},;
			           {"AUTVALREC"	      , SE2->E2_VALOR				, Nil}}
			
			MSExecAuto({|x,y| FINA080(x,y)},aBaixa)
		Endif
		
		If lMsErroAuto
			If _nValor > 0
				AutoGrLog("Linha.: "+Str(_nCt, 5)+"   Filial - "+_cFILIAL+" Numero SIAFI - "+_cNRSIAFI+" Número de Convênio  - "+_cNRCONVENIO+ " - Erro na importação do Registro (SE2)!")
				AutoGrLog(REPLICATE("=", 70))
			Else
				AutoGrLog("Linha.: "+Str(_nCt, 5)+"   Filial - "+_cFILIAL+" Numero SIAFI - "+_cNRSIAFI+" Número de Convênio  - "+_cNRCONVENIO+ " - Registro importado (SE2)!")
				AutoGrLog(REPLICATE("=", 70))
			Endif
		Endif

	Endif
	
Next i

_cFileLog := "IMPSICONV_"+_cDataN+".LOG"
                
__COPYFILE(_cDirPro, _cDirPro) //Copia Arquivo.            ////////ver como copiar arquivo

////If _cFileLog <> ""
////	MostraErro(_cPath, _cFileLog)
////Endif

FClose(_nHdl)

MsgInfo("Processo Finalizado")

Return
