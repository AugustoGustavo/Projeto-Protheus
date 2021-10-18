#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} User Function ImportPedCompra
    (descricao)
    @type  Function
    @author user
    @since 15/10/2021
    @version 12.1.27
    /*/
User Function ImportPedCompra()
    //variaveis que serao utilizadas durante a execucao de todo programa
    //o _ e o private identifica que elas sao acessadas na user function e nas static function tambem de movo privado, somente esse programa pode usa-las
    private _aItens         := {} //vai armazenar os itens que foram lidos do arquivo csv importado
    private _cTes           := "" //armazena o tes que sera utilizado nos itens do pedido
    private _cFornecedor    := "" //vai armazenar o codigo do fornecedor
    private _cLoja          := "" //vai armazenar a loja do fornecedor 
    private _cCondicaoPgto  := "" //vai armazenar a condicao de pagamento que sera atribuida ao pedido
    private _cNumeroPedido  := "" //vai armazenar o numero do pedido se assim o usuario preencher
    private _cCaminhoCSV    := "" //vai armazenar o caminho do arquivo 

    TelaPrincipal() //chama a tela principal de interacao com o usuario

Return Nil

/*/{Protheus.doc} Static Function TelaPrincipal
    (descricao)
    @type  Function
    @author Gustavo Jesus
    @since 15/10/2021
    @version 12.1.27
    /*/
Static Function TelaPrincipal()

    /*Inicializa Variaveis visuais*/
        //Parametros do MSDIALOG:NEW()
        local nTop          := 180 //Indica a coordenada vertical superior em pixels ou caracteres.
        local nLeft         := 180 //Indica a coordenada horizontal esquerda em pixels ou caracteres.
        local nBottom       := 550 //Indica a coordenada vertical inferior em pixels ou caracteres.
        local nRight        := 700 //Indica a coordenada horizontal direita em pixels ou caracteres.
        local cCaption      := "Importação de Pedido" //Indica o título da janela.
        local nClrText      := CLR_BLACK //Indica a cor do texto.
        local nClrBack      := CLR_WHITE //Indica a cor de fundo.
        local oWnd          := NIL //Indica a janela mãe (principal) da janela que será criada. O padrão é a janela principal do programa.
        local lPixel        := .T. //Indica se considera as coordenadas passadas em pixels (.T.) ou caracteres (.F.)
        local lTransparent  := .F. //Se .T. permitira que a Dialog receba um fundo transparente
        //Parametros do MSDIALOG:Activate()
        local lCentered     := .T. //Indica se a janela será (.T.) ou não (.F.) centralizada. O padrão é falso (.F.).
        local bValid        := {||msgstop('validou D.Mae'),.T.} //Indica se o conteúdo do diálogo é válido. Se o retorno for falso (.F.), o diálogo não será fechado quando a finalização for solicitada
        local bInit         := {||msgstop('iniciando Dialogo mae...')} //Indica o bloco de código que será executado quando o diálogo iniciar a exibição
        //Parametros compartilhados entre Componentes TButton()
        local nRow          := 002 //Indica a coordenada vertical em pixels ou caracteres
        local nCol          := 002 //Indica a coordenada horizontal em pixels ou caracteres
        local nWidth        := 40 //Indica a largura em pixels do botão.
        local nHeight       := 10 //Indica a altura em pixels do botão
    /*Finaliza Variaveis visuais*/

    //Cria dialogo (tela mãe principal, a partir dela vamos colocando os componentes, por exemplo o tbutton)
    Local oDialogoPrincipal := MSDialog():New(nTop,nLeft,nBottom,nRight,cCaption,,,,,nClrText,nClrBack,,oWnd,lPixel,,,,lTransparent)

    //Cria botoes (componentes filhos da tela mae oDialogo)
    Local oBotaoParametros      := TButton():New( nRow      ,nCol, "Parametros"        ,oDialogoPrincipal, {||VerificaParametros(oDialogoPrincipal)} , nWidth,nHeight,,,.F.,.T.,.F.,,.F.,,,.F. )
    Local oBotaoImportar        := TButton():New( nRow+20   ,nCol, "Importar Pedido"   ,oDialogoPrincipal, {||LerCsv()}             , nWidth,nHeight,,,.F.,.T.,.F.,,.F.,,,.F. )
    Local oBotaoGeraTemplate    := TButton():New( nRow+40   ,nCol, "Gerar Template"    ,oDialogoPrincipal, {||GeraTemplateCsv()}    , nWidth,nHeight,,,.F.,.T.,.F.,,.F.,,,.F. )
    
    // Ativa dialogo centralizado
    oDialogoPrincipal:Activate( , , , lCentered, bValid, , bInit)

Return Nil

/*/{Protheus.doc} VerificaParametros
    (descricao)
    @type  Function
    @author GustavoJesus
    @since 15/10/2021
    @version 12.1.27

    /*/
Static Function VerificaParametros(oDialogoPrincipal)
    //alert("funcao verificaParametros executada")

    /*Inicializa Variaveis visuais*/
        //Parametros do MSDIALOG:NEW()
        local nTop          := 50 //Indica a coordenada vertical superior em pixels ou caracteres.
        local nLeft         := 50 //Indica a coordenada horizontal esquerda em pixels ou caracteres.
        local nBottom       := 200 //Indica a coordenada vertical inferior em pixels ou caracteres.
        local nRight        := 500 //Indica a coordenada horizontal direita em pixels ou caracteres.
        local cCaption      := "Parametros da importacao" //Indica o título da janela.
        local nClrText      := CLR_BLACK //Indica a cor do texto.
        local nClrBack      := CLR_WHITE //Indica a cor de fundo.
        local lPixel        := .T. //Indica se considera as coordenadas passadas em pixels (.T.) ou caracteres (.F.)
        local lTransparent  := .F. //Se .T. permitira que a Dialog receba um fundo transparente
        //Parametros do MSDIALOG:Activate()
        local lCentered     := .T. //Indica se a janela será (.T.) ou não (.F.) centralizada. O padrão é falso (.F.).
        local bValid        := {||msgstop('validou D. Filho'),.T.} //Indica se o conteúdo do diálogo é válido. Se o retorno for falso (.F.), o diálogo não será fechado quando a finalização for solicitada
        local bInit         := {||msgstop('iniciando Dialogo filho...')} //Indica o bloco de código que será executado quando o diálogo iniciar a exibição
    /**/

    //Cria segundo dialogo sobre o principal, este sera menor e tera como componentes os TGet
    Local oDialogoParametros := MSDialog():New(nTop,nLeft,nBottom,nRight,cCaption,,,,,nClrText,nClrBack,,oDialogoPrincipal,lPixel,,,,lTransparent)

    //abaixo cria os TGet para editar as variaveis que vao armazenar o conteudo informado pelo usuario
    oTGetFornecedor := TGet():New( 01,01,{||_cFornecedor},oDialogoParametros,096,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,_cFornecedor,,,, )
    oTGetFornecedor:lNoButton   := .F. //indica se mostra a botao de ajuda ao lado do campo, F para mostrar
    oTGetFornecedor:cF3         := 'SA2' //indica a consulta padrao do campo
    oTGetFornecedor:bHelp       := {|| ShowHelpCpo( 'Help', {' Codigo do fornecedor cadastrado no SA2 '}, 0 ) } //mostra help caso o usuario tecle F1

    // Ativa dialogo de parametros centralizado
    oDialogoParametros:Activate( , , , lCentered, bValid, , bInit)

Return nil

/*/{Protheus.doc} LerCsv
    (descricao)
    @type Function
    @author Gustavo Jesus
    @since 15/10/2021
    @version 12.1.27
    /*/
Static Function LerCsv()
    alert("funcao LerCsv executada")
Return nil

/*/{Protheus.doc} GravaPedido
    (descricao)
    @type function
    @author Gustavo Jesus
    @since 15/10/2021
    @version 12.1.27
    /*/
Static Function GravaPedido()
    //programa
Return nil

/*/{Protheus.doc} MostraErro
    (descricao)
    @type  Function
    @author Gustavo Jesus
    @since 15/10/2021
    @version 12.1.27
    /*/
Static Function MostraErro()
    //programa
Return nil

/*/{Protheus.doc} GeraTemplateCsv
    (descricao)
    @type  Function
    @author Gustavo Jesus
    @since 15/10/2021
    @version 12.1.27
    /*/
Static Function GeraTemplateCsv()
    alert("funcao GeraTemplateCsv executada")
Return nil
    