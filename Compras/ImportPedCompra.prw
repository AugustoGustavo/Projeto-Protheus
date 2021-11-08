#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RwMake.ch"
#INCLUDE "TbiConn.ch"

/*/{Protheus.doc} User Function ImportPedCompra
    (descricao)
    @type  Function
    @author user
    @since 15/10/2021
    @version 0.0.1
    /*/
User Function ImportPedCompra()
    //variaveis que serao utilizadas durante a execucao de todo programa
    //o _ e o private identifica que elas sao acessadas na user function e nas static function tambem de movo privado, somente esse programa pode usa-las
    private _aCabecalho     := {} //vai armazenar os campos do cabecalho do pedido de compra
    private _aItens         := {} //vai armazenar os itens que foram lidos do arquivo csv importado
    private _cTes           := SPACE(FWTamSX3("F4_CODIGO")[1]) //adiciona espaco em branco na variavel que ira armazena o tes que sera utilizado nos itens do pedido
    private _cFornecedor    := SPACE(FWTamSX3("A2_COD")[1]) //adiciona espaco em branco na variavel que ira armazenar o codigo do fornecedor
    private _cLoja          := SPACE(FWTamSX3("A2_LOJA")[1]) //adiciona espaco em branco na variavel que ira armazenar a loja do fornecedor 
    private _cCondicaoPgto  := SPACE(FWTamSX3("E4_CODIGO")[1]) //adiciona espaco em branco na variavel que ira armazenar a condicao de pagamento que sera atribuida ao pedido
    private _cNumeroPedido  := SPACE(FWTamSX3("C7_NUM")[1]) //adiciona espaco em branco na variavel que ira armazenar o numero do pedido se assim o usuario preencher
    private _cCaminhoCSV    := SPACE(30) //adiciona espaco em branco na variavel que ira armazenar o caminho do arquivo 

    TelaPrincipal() //chama a tela principal de interacao com o usuario

Return Nil

/*/{Protheus.doc} Static Function TelaPrincipal
    (descricao)
    @type  Function
    @author Gustavo , Tiago e Renan
    @since 16/10/2021
    @version 0.0.1
    /*/
Static Function TelaPrincipal()

    /*Inicializa Variaveis visuais*/
        //Parametros do MSDIALOG:NEW()
        local nTop          := 180 //Indica a coordenada vertical superior em pixels ou caracteres.
        local nLeft         := 180 //Indica a coordenada horizontal esquerda em pixels ou caracteres.
        local nBottom       := 550 //Indica a coordenada vertical inferior em pixels ou caracteres.
        local nRight        := 700 //Indica a coordenada horizontal direita em pixels ou caracteres.
        local cCaption      := "Importacao de Pedido" //Indica o t�tulo da janela.
        local nClrText      := CLR_BLACK //Indica a cor do texto.
        local nClrBack      := CLR_WHITE //Indica a cor de fundo.
        local oWnd          := NIL //Indica a janela m�e (principal) da janela que ser� criada. O padr�o � a janela principal do programa.
        local lPixel        := .T. //Indica se considera as coordenadas passadas em pixels (.T.) ou caracteres (.F.)
        local lTransparent  := .F. //Se .T. permitira que a Dialog receba um fundo transparente
        //Parametros do MSDIALOG:Activate()
        local lCentered     := .T. //Indica se a janela sera (.T.) ou nao (.F.) centralizada. O padrao e falso (.F.).
        local bValid        := {||} //Indica se o conteudo do dialogo e valido. Se o retorno for falso (.F.), o dialogo nao sera fechado quando a finalizacao for solicitada
        local bInit         := {||} //Indica o bloco de codigo que sera executado quando o dialogo iniciar a exibicao
        //Parametros compartilhados entre Componentes TButton()
        local nRow          := 002 //Indica a coordenada vertical em pixels ou caracteres
        local nCol          := 002 //Indica a coordenada horizontal em pixels ou caracteres
        local nWidth        := 40 //Indica a largura em pixels do botao.
        local nHeight       := 10 //Indica a altura em pixels do botao
    /*Finaliza Variaveis visuais*/

    //Cria dialogo (tela mae principal, a partir dela vamos colocando os componentes, por exemplo o tbutton)
    Local oDialogoPrincipal := MSDialog():New(nTop,nLeft,nBottom,nRight,cCaption,,,,,nClrText,nClrBack,,oWnd,lPixel,,,,lTransparent)

    //Cria botoes (componentes filhos da tela mae oDialogo)
    oBotaoParametros      := TButton():New( nRow      ,nCol, "Parametros"        ,oDialogoPrincipal, {||VerificaParametros(oDialogoPrincipal)} , nWidth,nHeight,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBotaoImportar        := TButton():New( nRow+20   ,nCol, "Importar Pedido"   ,oDialogoPrincipal, {||LerCsv()}             , nWidth,nHeight,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBotaoGeraTemplate    := TButton():New( nRow+40   ,nCol, "Gerar Template"    ,oDialogoPrincipal, {||GeraTemplateCsv()}    , nWidth,nHeight,,,.F.,.T.,.F.,,.F.,,,.F. )

    // Ativa dialogo centralizado
    oDialogoPrincipal:Activate( , , , lCentered, bValid, , bInit)

Return Nil

/*/{Protheus.doc} VerificaParametros
    (descricao)
    @type  Function
    @author GustavoJesus
    @since 15/10/2021
    @version 0.0.1
    @param oDialogoPrincipal, object, instancia da tela principal
    /*/
Static Function VerificaParametros(oDialogoPrincipal)

    /*Inicializa Variaveis visuais*/
        //Parametros do MSDIALOG:NEW()
        local nTop          := 50 //Indica a coordenada vertical superior em pixels ou caracteres.
        local nLeft         := 50 //Indica a coordenada horizontal esquerda em pixels ou caracteres.
        local nBottom       := 310 //Indica a coordenada vertical inferior em pixels ou caracteres.
        local nRight        := 310//Indica a coordenada horizontal direita em pixels ou caracteres.
        local cCaption      := "Parametros da importacao" //Indica o t�tulo da janela.
        local nClrText      := CLR_BLACK //Indica a cor do texto.
        local nClrBack      := CLR_WHITE //Indica a cor de fundo.
        local lPixel        := .T. //Indica se considera as coordenadas passadas em pixels (.T.) ou caracteres (.F.)
        local lTransparent  := .F. //Se .T. permitira que a Dialog receba um fundo transparente
        //Parametros do MSDIALOG:Activate()
        local lCentered     := .T. //Indica se a janela ser� (.T.) ou n�o (.F.) centralizada. O padr�o � falso (.F.).
        local bValid        := {||} //Indica se o conte�do do di�logo � v�lido. Se o retorno for falso (.F.), o di�logo n�o ser� fechado quando a finaliza��o for solicitada
        local bInit         := {||} //Indica o bloco de c�digo que ser� executado quando o di�logo iniciar a exibi��o
    /**/

    //Cria segundo dialogo sobre o principal, este sera menor e tera como componentes os TGet
    Local oDialogoParametros := MSDialog():New(nTop,nLeft,nBottom,nRight,cCaption,,,,,nClrText,nClrBack,,oDialogoPrincipal,lPixel,,,,lTransparent)

    /*INICIO TGET criacao dos TGet para editar as variaveis que vao armazenar o conteudo informado pelo usuario*/

        //INICIALIZA objetos para formar os parametros pro usuario
        oTGetFornecedor := TGet():New( 01,10,{| u | If( PCount() == 0, _cFornecedor, _cFornecedor := u )}       ,oDialogoParametros,096,009,X3PICTURE("A2_COD")      ,,0,,,/*12*/,,.T.,,.F.,,.F.,.F.,,.F.,.F.,/*23*/,_cFornecedor  ,,,/*27*/,,,/*30*/,"Codigo do fornecedor"        ,1,,,,, ) //campo Fornecedor
        oTGetLoja       := TGet():New( 20,10,{| u | If( PCount() == 0, _cLoja, _cLoja := u )}                   ,oDialogoParametros,096,009,X3PICTURE("A2_LOJA")     ,,0,,,/*12*/,,.T.,,.F.,,.F.,.F.,,.F.,.F.,/*23*/,_cLoja        ,,,/*27*/,,,/*30*/,"Loja do fornecedor"          ,1,,,,, ) //campo loja
        oTGetCondPagto  := TGet():New( 40,10,{| u | If( PCount() == 0, _cCondicaoPgto, _cCondicaoPgto := u )}   ,oDialogoParametros,096,009,X3PICTURE("E4_CODIGO")   ,,0,,,/*12*/,,.T.,,.F.,,.F.,.F.,,.F.,.F.,/*23*/,_cCondicaoPgto,,,/*27*/,,,/*30*/,"Condicao de Pagto"           ,1,,,,, ) //campo condicao de Pgto
        oTGetTES        := TGet():New( 60,10,{| u | If( PCount() == 0, _cTes, _cTes := u )}                     ,oDialogoParametros,096,009,X3PICTURE("F4_CODIGO")   ,,0,,,/*12*/,,.T.,,.F.,,.F.,.F.,,.F.,.F.,/*23*/,_cTes         ,,,/*27*/,,,/*30*/,"TES"                         ,1,,,,, ) //campo TES
        oTGetArquivoCSV := TGet():New( 80,10,{| u | If( PCount() == 0, _cCaminhoCSV, _cCaminhoCSV := u )}       ,oDialogoParametros,096,009,"@!"                     ,,0,,,/*12*/,,.T.,,.F.,,.F.,.F.,,.F.,.F.,/*23*/,_cCaminhoCSV  ,,,/*27*/,,,/*30*/,"Arquivo CSV"                 ,1,,,,, ) //campo Caminho do CSV
        oTGetNumPedido  := TGet():New(100,10,{| u | If( PCount() == 0, _cNumeroPedido, _cNumeroPedido := u )}   ,oDialogoParametros,096,009,"@!"                     ,,0,,,/*12*/,,.T.,,.F.,,.F.,.F.,,.F.,.F.,/*23*/,_cCaminhoCSV  ,,,/*27*/,,,/*30*/,"Numero Pedido Manual? (F1)"  ,1,,,,, ) //Caso o usuario informe manualmente o numero do pedido

        //define propriedades do get p codigo do fornecedor
        oTGetFornecedor:lNoButton   := .F. //indica se mostra a botao de ajuda ao lado do campo, F para mostrar
        oTGetFornecedor:cF3         := 'SA2' //indica a consulta padrao do campo
        oTGetFornecedor:bHelp       := {|| ShowHelpCpo( 'Help', {' Codigo do fornecedor cadastrado no SA2 '}, 0 ) } //mostra help caso o usuario tecle F1

        //define propriedades do get p loja do fornecedor
        oTGetLoja:bHelp       := {|| ShowHelpCpo( 'Help', {' Loja do fornecedor cadastrado no SA2 '}, 0 ) }     

        //define propriedades do get p condicao de pagamento        
        oTGetCondPagto:lNoButton   := .F. //indica se mostra a botao de ajuda ao lado do campo, F para mostrar
        oTGetCondPagto:cF3         := 'SE4' //indica a consulta padrao do campo
        oTGetCondPagto:bHelp       := {|| ShowHelpCpo( 'Help', {' Codigo da condicao de pagamento '}, 0 ) } 

        //define propriedades do get p TES        
        oTGetTES:lNoButton   := .F. 
        oTGetTES:cF3         := 'SF4TES' 
        oTGetTES:bHelp       := {|| ShowHelpCpo( 'Help', {' Codigo do TES '}, 0 ) } 

        //define propriedades do get p o caminho do arquivo csv        
        oTGetArquivoCSV:bHelp       := {|| ShowHelpCpo( 'Help', {' Caminho do arquivo csv '}, 0 ) } 

        //define o help do campo que contem o numero do pedido informado pelo usuario
        oTGetNumPedido:bHelp        := {|| ShowHelpCpo( 'Help', {' Se deseja gravar o numero do pedido manualmente, informe aqui, caso contrario, deixe em branco '}, 0 ) } 
    /*FIM TGET*/

    //cria tbutton que permite o usuario buscar arquivo csv e alimentar a _cCaminhoCSV e dar um refresh no oTGetArquivoCSV
    oBotaoBuscarArquivo := TButton():New( 88, 106, "Buscar"     ,oDialogoParametros, {|| _cCaminhoCSV := BuscaArquivo() , oTGetArquivoCSV:CtrlRefresh()}    , 022,009,,,.F.,.T.,.F.,,.F.,,,.F. )
    //cria botao Ok e valida operacao
    oBotaoOk            := TButton():New( 120, 50, "Ok"         ,oDialogoParametros, {||oDialogoParametros:end()}    , 020,009,,,.F.,.T.,.F.,,.F.,,,.F. )

    // Ativa dialogo de parametros centralizado
    oDialogoParametros:Activate( , , , lCentered, bValid, , bInit)
    
Return nil

/*/{Protheus.doc} LerCsv
    (descricao)
    @type Function
    @author Gustavo Jesus
    @since 15/10/2021
    @version 0.0.1
    /*/
Static Function LerCsv()

    Local nLinhas       := 0 //variavel auxiliar para gaurdar a quantidade de linhas do arquivo
    Local aNomeColunas  := {} //Array auxiliar para pegar o nome das colunas que estao na primeira linha do arquivo
    Local nQtdColunas   := 0 //variavel contadora auxiliar que deve contar a quantidade de colunas da primeira linha 
    Local nContador     := 0 //contador de loop para ser usado no For
    Local nManipulador  := FT_FUse( _cCaminhoCSV ) //aponta no arquivo e o abre para manipula-lo

    IF nManipulador <> -1 //se o manipulador conseguiu abrir o arquivo, entao executa comandos abaixo

        FT_FGoTop() //posiciona na primeira linha
        nLinhas := FT_FLastRec() //retorna a quantida de linhas do arquivo

        for nContador := 1 to nLinhas //inicia o for ate chegar no final da linha

            If nLinhas == 1 //caso seja primeira linha, entende-se que e o nome das colunas entao executa comandos abaixo
                aNomeColunas    := StrTokArr( FT_FREADLN( ) , ";" ) //monta array de elemntos sendo os nomes das colunas separadas por ;
                nQtdColunas     := Len( aNomeColunas ) //conta quantas colunas deram

                for nContador := 1 to nQtdColunas //inicia lop ate terminas a quantidade de colunas 
                    Aadd( _aItens , aNomeColunas[nContador] ) //a cada coluna, adiciona-a como elemento index do array de itens ou seja o titulo da coluna e dps vamos colocar o conteudo
                next

                nContador   := 1 //volta o contador a 1
                
                FT_FSKIP() //pula primeira linha pois entende-se que e o nome das colunas
            Else
                //implementar aqui o codigo para pegar os itens do arquivo
            EndIF

            FT_FSKIP()
            
        next

        FT_FUse() //fecha arquivo

    ELSE //se o manipulador nao conseguiu abrir o arquivo, executa comandos abaixo
        MsgAlert("Nao foi possivel abrir o arquivo CSV")
        ConOut( "Erro ao ler CSV - FERROR " + str(FError(),4) ) //envia o erro para o console log
    ENDIF

Return nil

/*/{Protheus.doc} GravaPedido
    (descricao)
    @type function
    @author Gustavo Jesus
    @since 15/10/2021
    @version 0.0.1
    /*/
Static Function GravaPedido()

    //Local nOpcao := "3" //Opcao de incluir para o msexecauto
    /*
        DbSelectArea("SC7")
        DbSetOrder(1)
        If DbSeek(xFilial("SC7")+_cPed)
            _aCab := {}
            _aItem := {}
            Aadd(_aCab,{"C7_NUM"        ,SC7->C7_NUM    ,NIL})
            Aadd(_aCab,{"C7_COND"       ,SC7->C7_COND   ,NIL})
            Aadd(_aCab,{"C7_FILENT"     ,SC7->C7_FILENT ,NIL})

            _aItens := {}
            aadd(_aItem,{"C7_ITEM"      ,SC7->C7_ITEM   ,NIL})
            aAdd(_aItem,{"C7_PRODUTO"   ,SC7->C7_PRODUTO,Nil})
            aadd(_aItem,{"C7_QUANT"     ,SC7->C7_QUANT ,NIL})
            aAdd(_aItem,{"C7_PRECO"     ,_nVlUnit               ,Nil}) // Novo valor
            aAdd(_aItem,{"C7_TES"       ,SC7->C7_TES    ,Nil})
            aadd(_aItem,{"C7_DATPRF"    ,SC7->C7_DATPRF ,NIL})
            aadd(_aItens,_aItem)

            nOpc        := 4
            lMsErroAuto := .F.
            MSExecAuto({|u,v,x,y| MATA120(u,v,x,y)},1,_aCab,_aItens,nOpc)
        EndIf
    */
Return nil

/*/{Protheus.doc} MostraErro
    (descricao)
    @type  Function
    @author Gustavo Jesus
    @since 15/10/2021
    @version 0.0.1
    /*/
Static Function MostraErro()
    //programa
Return nil

/*/{Protheus.doc} GeraTemplateCsv
    Gera o template do arquivo csv para ser usado como base pro usuario 
    @type  Function
    @author Gustavo Jesus
    @since 15/10/2021
    @version 0.0.1
    /*/
Static Function GeraTemplateCsv()
    
    Local cDiretorioTemp    := getTempPath() //obtem o diretorio temporario do sistema operacional
    Local cNomeArquivo      := "templateImpPedido.csv" //nome do arquivo que sera gravado no diretorio temp
    Local aCamposSc7        := {} //array que deve conter os campos para o cabecalho do arquivo template
    Local nContador         := 0 //variavel para controle de loop
    Local cCamposSc7        := "" //sera usado para converter o array de campos em string

    aadd(aCamposSc7,"C7_ITEM") //add campo ao array numero do item do pedido
    aAdd(aCamposSc7,"C7_PRODUTO") //add campo ao array codigo do produto
    aadd(aCamposSc7,"C7_QUANT") //add campo ao array quantidade do produto
    aAdd(aCamposSc7,"C7_PRECO") //add campo ao array preco unitario do produto
    aadd(aCamposSc7,"C7_DATPRF") //add campo ao array data para entrega

    If File( cDiretorioTemp + cNomeArquivo )
        if FErase( cDiretorioTemp + cNomeArquivo ) == -1
            ConOut("Nao foi possivel excluir o arquivo " + cDiretorioTemp + cNomeArquivo +" - GeraTemplateCsv()")
        EndIf
    EndIf

    for nContador := 1 to Len(aCamposSc7)
       
        if( nContador <= Len(aCamposSc7) .and. AllTrim(cCamposSc7)<>"" , cCamposSc7 += ";" , )
        cCamposSc7 += aCamposSc7[nContador]

    next

    If !MemoWrite( cDiretorioTemp + cNomeArquivo ,cCamposSc7)
        MsgAlert("Nao possivel gravar o arquiv no diretorio: " + CRLF + cDiretorioTemp + cNomeArquivo )
    else
        ShellExecute("open", cDiretorioTemp + cNomeArquivo, "", "", 1)
    EndIf

    cCamposSc7 := "" 
    nContador := 0

Return nil

/*/{Protheus.doc} BuscaArquivo
    (Descricao)
    @type Function
    @author Gustavo Jesus
    @since 20/10/2021
    @version 0.0.1
    @return character, caminho do arquivo csv
    /*/
Static Function BuscaArquivo()
    local cDiretorioTemp := getTempPath()
    local cDiretorioArquivo := tFileDialog( "All CSV files (*.csv) ",'Selecao de Arquivos',, cDiretorioTemp, .F.,  )

Return alltrim(cDiretorioArquivo)

/*/{Protheus.doc} GeraLog
    (desc)
    @type Function
    @author Gustavo Jesus
    @since 21/10/2021
    @version 0.0.1
    /*/
Static Function GeraLog()
    //programa
Return Nil
