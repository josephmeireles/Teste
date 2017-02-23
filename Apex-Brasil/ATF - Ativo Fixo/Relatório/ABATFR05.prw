#INCLUDE "protheus.ch"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ABATFR05 � Autor � Leonardo Soncin    � Data �  31/08/11   ���
�������������������������������������������������������������������������͹��
���Descricao � Relatorio de Invent�rio                                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � CNI                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function ABATFR05
Local cDesc1		:= "Este programa tem como objetivo imprimir relatorio "
Local cDesc2		:= "de acordo com os parametros informados pelo usuario."
Local cDesc3		:= "Itens n�o importados existentes no ERP"
Local cPict			:= ""
Local titulo		:= "Itens n�o importados existentes no ERP"
Local nLin			:= 80
Local Cabec1		:= "C�d. Barra            Descri��o                       Respons�vel           C. Custo                        Item Cont�bil                   Classe de Valor"
Local Cabec2		:= ""
                     //01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
				     //0        1         2         3         4         5         6         7         8         9         0         1         2         3         4         5
Local imprime		:= .T.
Local aOrd			:= {}
Private lEnd		:= .F.
Private lAbortPrint	:= .F.
Private CbTxt		:= ""
Private limite		:= 132
Private tamanho		:= "G"
Private nomeprog	:= "ABATFR05"
Private nTipo		:= 18
Private aReturn		:= { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey	:= 0
Private cPerg		:= "SIAF05"
Private cbtxt		:= Space(10)
Private cbcont		:= 00
Private CONTFL		:= 01
Private m_pag		:= 01
Private wnrel		:= "ABATFR05" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cString		:= "PA4"

dbSelectArea("PA4")
dbSetOrder(1)

ValidPerg(cPerg)
pergunte(cPerg,.F.)

//���������������������������������������������������������������������Ŀ
//� Monta a interface padrao com o usuario...                           �
//�����������������������������������������������������������������������
wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//���������������������������������������������������������������������Ŀ
//� Processamento. RPTSTATUS monta janela com a regua de processamento. �
//�����������������������������������������������������������������������
RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    �RUNREPORT � Autor � AP6 IDE            � Data �  31/08/11   ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS ���
���          � monta a janela com a regua de processamento.               ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
Local nOrdem
Local _cQuery 	:= ""
Local cAliasTMP := GetNextAlias()
Local cLocAnt 	:= ""

_cQuery :=  "SELECT N1_DESCRIC, N1_CODBAR, N1_LOCAL, N3_CUSTBEM, N3_SUBCCON, N3_CLVLCON, ND_CODRESP "
_cQuery +=  "FROM "+RetSqlName("SN1")+" SN1 "
_cQuery +=  "LEFT OUTER JOIN "+RetSqlName("SN3")+" SN3 ON N3_FILIAL = '"+xFilial("SN3")+"' AND N3_CBASE = N1_CBASE	AND N3_ITEM = N1_ITEM AND SN3.D_E_L_E_T_ = '' "
_cQuery +=  "LEFT OUTER JOIN "+RetSqlName("SND")+" SND ON ND_FILIAL = '"+xFilial("SND")+"' AND ND_CBASE = N1_CBASE	AND ND_ITEM = N1_ITEM AND SND.D_E_L_E_T_ = '' AND ND_STATUS = '1' "
_cQuery +=  "WHERE N1_FILIAL = '"+xFilial("SN1")+"' AND "
_cQuery +=  "N1_LOCAL BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND "
_cQuery +=  "N1_CODBAR NOT IN (SELECT PA4_CODBAR FROM "+RetSqlName("PA4")+" PA4 WHERE "
_cQuery +=  "PA4_FILIAL = '"+xFilial("PA4")+"' AND "
_cQuery +=  "PA4_EMISSAO BETWEEN '"+Dtos(MV_PAR01)+"' AND '"+Dtos(MV_PAR02)+"' AND "
_cQuery +=  "PA4_LOCALIZ BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND PA4.D_E_L_E_T_ = '' ) AND "
_cQuery +=  "SN1.D_E_L_E_T_ = '' AND SN1.N1_BAIXA = ' ' "
_cQuery +=  "ORDER BY N1_LOCAL "
_cQuery := ChangeQuery(_cQuery)

If Select(cAliasTMP) > 0
	dbSelectArea(cAliasTMP)
	dbCloseArea()
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),cAliasTMP,.T.,.F.)

DbSelectArea(cAliasTMP)

//���������������������������������������������������������������������Ŀ
//� SETREGUA -> Indica quantos registros serao processados para a regua �
//�����������������������������������������������������������������������
SetRegua(RecCount())

dbGoTop()
While !EOF(cAliasTMP)

	//���������������������������������������������������������������������Ŀ
	//� Verifica o cancelamento pelo usuario...                             �
	//�����������������������������������������������������������������������
	If lAbortPrint
		@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif

	//���������������������������������������������������������������������Ŀ
	//� Impressao do cabecalho do relatorio. . .                            �
	//�����������������������������������������������������������������������
	If nLin > 60 // Salto de P�gina. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8
	Endif

	cLocAnt := (cAliasTMP)->N1_LOCAL
    @nLin,000 PSAY "Localiza��o: "+cLocAnt + " - "+Posicione("SNL",1,xFilial("SNL")+cLocAnt	,"NL_DESCRIC")
   	nLin := nLin + 2

	While !Eof(cAliasTMP) .and. (cAliasTMP)->N1_LOCAL == cLocAnt
		@nLin,000 PSAY (cAliasTMP)->N1_CODBAR
		@nLin,022 PSAY Substr((cAliasTMP)->N1_DESCRIC,1,30)
		@nLin,054 PSAY Substr(Posicione("RD0",1,xFilial("RD0")+(cAliasTMP)->ND_CODRESP	,"RD0_NOME"),1,20)
		@nLin,076 PSAY Substr(Posicione("CTT",1,xFilial("CTT")+(cAliasTMP)->N3_CUSTBEM 	,"CTT_DESC01"),1,30)
		@nLin,108 PSAY Substr(Posicione("CTD",1,xFilial("CTD")+(cAliasTMP)->N3_SUBCCON	,"CTD_DESC01"),1,30)
		@nLin,140 PSAY Substr(Posicione("CTH",1,xFilial("CTH")+(cAliasTMP)->N3_CLVLCON	,"CTH_DESC01"),1,30)

		nLin := nLin + 1 // Avanca a linha de impressao

		dbSelectarea(cAliasTMP)
		Incregua()
		dbSkip() // Avanca o ponteiro do registro no arquivo
	EndDo

	nLin := nLin + 2
EndDo

//���������������������������������������������������������������������Ŀ
//� Finaliza a execucao do relatorio...                                 �
//�����������������������������������������������������������������������
SET DEVICE TO SCREEN

//���������������������������������������������������������������������Ŀ
//� Se impressao em disco, chama o gerenciador de impressao...          �
//�����������������������������������������������������������������������
If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � ValidPerg� Autor � Wagner Gomes          � Data � 10/12/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cria as Perguntas para Fatura para locacao de Bens Moveis  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Especifico Construtora OAS Ltda                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ValidPerg(cPerg)
Local _sAlias := Alias()
Local aRegs := {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
aAdd(aRegs,{cPerg,"01","Emiss�o de:  "				,"mv_ch1","D",08,0,0,"G","naovazio()","mv_par01","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Emiss�o at�: "				,"mv_ch2","D",08,0,0,"G","naovazio() .and. mv_par02>=mv_par01","mv_par02","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Localiza��o de: "			,"mv_ch3","C",06,0,0,"G","","mv_par03","","","","","","","","","","","","","","","SNL",""})
aAdd(aRegs,{cPerg,"04","Localiza��o at�: "			,"mv_ch4","C",06,0,0,"G","","mv_par04","","","","","","","","","","","","","","","SNL",""})

For i := 1 to Len(aRegs)
	PutSX1(aRegs[i,1],aRegs[i,2],aRegs[i,3],aRegs[i,3],aRegs[i,3],aRegs[i,4],aRegs[i,5],aRegs[i,6],aRegs[i,7],;
	aRegs[i,8],aRegs[i,9],aRegs[i,10],iif(len(aRegs[i])>=26,aRegs[i,26],""),aRegs[i,27],"",aRegs[i,11],aRegs[i,12],;
	aRegs[i,12],aRegs[i,12],aRegs[i,13],aRegs[i,15],aRegs[i,15],aRegs[i,15],aRegs[i,18],aRegs[i,18],aRegs[i,18],;
	aRegs[i,21],aRegs[i,21],aRegs[i,21],aRegs[i,24],aRegs[i,24],aRegs[i,24])
Next i

dbSelectArea(_sAlias)

Return