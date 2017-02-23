#INCLUDE "protheus.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ABATFR02 � Autor � Leonardo Soncin    � Data �  31/08/11   ���
�������������������������������������������������������������������������͹��
���Descricao � Relatorio de Invent�rio                                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � CNI                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function ABATFR02


//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������

Local cDesc1		:= "Este programa tem como objetivo imprimir relatorio "
Local cDesc2		:= "de acordo com os parametros informados pelo usuario."
Local cDesc3		:= "Lista geral de itens inventariados"
Local cPict			:= ""
Local titulo		:= "Lista geral de itens inventariados"
Local nLin			:= 80
Local Cabec1		:= "                                                                                  Informa��es do Invent�rio                                             Informa��es do ERP"
Local Cabec2		:= "Emiss�o     C�d. Barra            Descri��o             Status      Emp. Origem   Localiza��o   Respons�vel   C. Custo      It. Contab.   Cl. Valor     Localiza��o   Respons�vel   C. Custo      It. Contab.   Cl. Valor"
				      //1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
					  //0        1         2         3         4         5         6         7         8         9         0         1         2         3         4         5
Local imprime		:= .T.
Local aOrd			:= {}
Private lEnd		:= .F.
Private lAbortPrint	:= .F.
Private CbTxt		:= ""
Private limite		:= 220
Private tamanho		:= "G"
Private nomeprog	:= "ABATFR02"
Private nTipo		:= 18
Private aReturn		:= { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey	:= 0
Private cPerg		:= "SIAF02"
Private cbtxt		:= Space(10)
Private cbcont		:= 00
Private CONTFL		:= 01
Private m_pag		:= 01
Private wnrel		:= "ABATFR02" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cString		:= "PA1"

dbSelectArea("PA1")
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
Local _cQuery	:= ""
Local cAliasTMP	:= GetNextAlias()
Local aStatus	:= { "Conciliado", "Divergente" , "N�o Conci." }

_cQuery :=  "SELECT PA4_EMISSAO, PA4_CODBAR, PA4_DESCBEM, PA4_STATUS, PA4_EMPORI, PA4_LOCALIZ, PA4_RESP, PA4_CC, PA4_ITEM, PA4_CLVL, PA4_XLOCAL, PA4_XRESP, PA4_XCC, PA4_XITEM, PA4_XCLVL "
_cQuery +=  "FROM "+RetSqlName("PA1")
_cQuery +=  " WHERE PA4_FILIAL = '"+xFilial("PA1")+"' AND "
_cQuery +=  "PA4_EMISSAO BETWEEN '"+Dtos(MV_PAR01)+"' AND '"+Dtos(MV_PAR02)+"' AND "
_cQuery +=  "PA4_LOCALIZ BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND "
If MV_PAR05 <> 4
	_cQuery +=  "PA4_STATUS = '"+Alltrim(Str(MV_PAR05))+"' AND "
Endif
_cQuery +=  "D_E_L_E_T_ = ' ' "
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
      nLin := 9
   Endif

   @nLin,000 PSAY Dtoc(Stod((cAliasTMP)->PA4_EMISSAO))
   @nLin,012 PSAY (cAliasTMP)->PA4_CODBAR
   @nLin,034 PSAY Substr((cAliasTMP)->PA4_DESCBEM,1,20)
   @nLin,056 PSAY aStatus[Val((cAliasTMP)->PA4_STATUS)]
   @nLin,068 PSAY (cAliasTMP)->PA4_EMPORI
   //Dados do Inventario
   @nLin,082 PSAY Substr(Posicione("SNL",1,xFilial("SNL")+(cAliasTMP)->PA4_LOCALIZ	,"NL_DESCRIC"),1,12)
   @nLin,096 PSAY Substr(Posicione("RD0",1,xFilial("RD0")+(cAliasTMP)->PA4_RESP		,"RD0_NOME"),1,12)
   @nLin,110 PSAY Substr(Posicione("CTT",1,xFilial("CTT")+(cAliasTMP)->PA4_CC  		,"CTT_DESC01"),1,12)
   @nLin,124 PSAY Substr(Posicione("CTD",1,xFilial("CTD")+(cAliasTMP)->PA4_ITEM		,"CTD_DESC01"),1,12)
   @nLin,138 PSAY Substr(Posicione("CTH",1,xFilial("CTH")+(cAliasTMP)->PA4_CLVL		,"CTH_DESC01"),1,12)
   // Dados do ERP
   @nLin,152 PSAY Substr(Posicione("SNL",1,xFilial("SNL")+(cAliasTMP)->PA4_XLOCAL	,"NL_DESCRIC"),1,12)
   @nLin,166 PSAY Substr(Posicione("RD0",1,xFilial("RD0")+(cAliasTMP)->PA4_XRESP	,"RD0_NOME"),1,12)
   @nLin,180 PSAY Substr(Posicione("CTT",1,xFilial("CTT")+(cAliasTMP)->PA4_XCC		,"CTT_DESC01"),1,12)
   @nLin,194 PSAY Substr(Posicione("CTD",1,xFilial("CTD")+(cAliasTMP)->PA4_XITEM	,"CTD_DESC01"),1,12)
   @nLin,208 PSAY Substr(Posicione("CTH",1,xFilial("CTH")+(cAliasTMP)->PA4_XCLVL	,"CTH_DESC01"),1,12)

   nLin := nLin + 1 // Avanca a linha de impressao

	dbSelectarea(cAliasTMP)
	IncRegua()
   	dbSkip() // Avanca o ponteiro do registro no arquivo
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

		//  Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
aAdd(aRegs,{cPerg,"01","Emiss�o de:  "		,"mv_ch1","D",08,0,0,"G","naovazio()","mv_par01","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Emiss�o at�: "		,"mv_ch2","D",08,0,0,"G","naovazio() .and. mv_par02>=mv_par01","mv_par02","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Localiza��o de: "	,"mv_ch3","C",06,0,0,"G","","mv_par03","","","","","","","","","","","","","","","SNL",""})
aAdd(aRegs,{cPerg,"04","Localiza��o at�: "	,"mv_ch4","C",06,0,0,"G","","mv_par04","","","","","","","","","","","","","","","SNL",""})
aAdd(aRegs,{cPerg,"05","Listar: "			,"mv_ch5","N",01,0,0,"C","","mv_par05","Conciliados","","","Divergentes","","","N�o Conciliados","","","Todos","","","","","",""})

For i := 1 to Len(aRegs)
	PutSX1(aRegs[i,1],aRegs[i,2],aRegs[i,3],aRegs[i,3],aRegs[i,3],aRegs[i,4],aRegs[i,5],aRegs[i,6],aRegs[i,7],;
	aRegs[i,8],aRegs[i,9],aRegs[i,10],iif(len(aRegs[i])>=26,aRegs[i,26],""),aRegs[i,27],"",aRegs[i,11],aRegs[i,12],;
	aRegs[i,12],aRegs[i,12],aRegs[i,13],aRegs[i,15],aRegs[i,15],aRegs[i,15],aRegs[i,18],aRegs[i,18],aRegs[i,18],;
	aRegs[i,21],aRegs[i,21],aRegs[i,21],aRegs[i,24],aRegs[i,24],aRegs[i,24])
Next i

dbSelectArea(_sAlias)

Return