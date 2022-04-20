unit uFrmVendas;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.TabControl,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.Objects, FMX.Edit,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, FMX.Ani, FMX.Effects, FMX.MultiView, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.FMXUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.Comp.UI, system.Math, System.Actions,
  FMX.ActnList, FMX.ListBox, uImpressao, Androidapi.JNI.Toast, StrUtils;
type
  tpFinalizadora = (DINHEIRO, CREDITO, DEBITO, CHEQUE, PIX);
  opQuantidade = (ADD, REMOVE);

  TItemLista = record
    nrSequencia: Integer;
    descricao: String;
    quantidade: Double;
  end;

  TCupom = record
    nrDocumento: Integer;
    nrNota: Integer;
    vlTotal: Currency;
    vlSubTotal: Currency;
    vlDesconto: Currency; {Todos os descontos somados}
    vlDescontoSub: Currency; {Desconto aplicado ao subtotal}
    qtItens: Integer;
    pagVlTroco: Currency;
    pagVlTotal: Currency;
    DtEmissao: String;
    autChaveDanfe: String;
    autNrProtocolo: String;
    autXmlVenda: String;
    autSituacaoNfce: String;
    autMotivo: String;
    autQrCode: String;
    autNrLote: String;
    autRecibo: String;
    autHrprocessamento: String;
    autDtProcessamento: String;
    autNrDocumentoServidor: String;
  end;

  TCliCupom = record
    cdCliente: Integer;
    nmCliente: String;
    cpfCliente: String;
  end;

  TProdutoCupom = record
    cdProduto: Integer;
    cdBarras: String;
    nrSequencia: Integer;
    gtin: String;
    descricao: String;
    preco: Currency;
    cst: String;
    un: String;
    ncm: String;
    cest: String;
    cstPisCofins: String;
    ntReceita: String;
    pesoL: Double;
    aliqIcms: Double;
    pcReducao: Currency;
    aliqPis: Double;
    aliqCofins: Double;
    cfop: Integer;
    vlTotal: Currency;
    qtd: Double;
  end;

  TfrmVendas = class(TForm)
    TabControl: TTabControl;
    tabVendas: TTabItem;
    tabPagamento: TTabItem;
    rectTopo: TRectangle;
    Layout1: TLayout;
    btnLateral: TSpeedButton;
    rectTotais: TRectangle;
    laySubTotal: TLayout;
    rectCdProduto: TRectangle;
    edtCdProduto: TEdit;
    lblTitulo: TLabel;
    layCodigo: TLayout;
    imgBarCode: TImage;
    layDesconto: TLayout;
    lblDesconto: TLabel;
    btnLimpaCodigo: TLabel;
    StyleBook1: TStyleBook;
    lvItens: TListView;
    lblTotal: TLabel;
    imgLista: TImage;
    Label7: TLabel;
    lblSubtotal: TLabel;
    ShadowEffect1: TShadowEffect;
    layTotais: TLayout;
    RoundRect1: TRoundRect;
    layCorpo: TLayout;
    Layout2: TLayout;
    MultiView: TMultiView;
    rectFundoMenu: TRectangle;
    layBtnCliente: TLayout;
    Image1: TImage;
    Label9: TLabel;
    layBtnDesconto: TLayout;
    Image2: TImage;
    Label10: TLabel;
    layBtnGerencial: TLayout;
    Image3: TImage;
    Label11: TLabel;
    layBtnAcrescimo: TLayout;
    Image4: TImage;
    Label12: TLabel;
    layBtnSair: TLayout;
    Image5: TImage;
    Label13: TLabel;
    Label6: TLabel;
    Label2: TLabel;
    lvPagamentos: TListView;
    grdFinalizadoras: TGridPanelLayout;
    rectDinheiro: TRectangle;
    rectPagar: TRectangle;
    Label15: TLabel;
    Label17: TLabel;
    ActionList: TActionList;
    actTabVenda: TChangeTabAction;
    actTabPagamento: TChangeTabAction;
    rectTopoPagamento: TRectangle;
    Layout3: TLayout;
    btnVoltarPagamento: TSpeedButton;
    Label1: TLabel;
    lblQtItens: TLabel;
    layDescTotal: TLayout;
    rect_fundo: TRectangle;
    rect_msg: TRectangle;
    Label4: TLabel;
    lblDescTT: TLabel;
    layout_botao: TLayout;
    rectConfirma: TRectangle;
    btnConfirmarDesc: TSpeedButton;
    lbl_btn1: TLabel;
    rectCancela: TRectangle;
    btnCancelarDesc: TSpeedButton;
    lbl_btn2: TLabel;
    ShadowEffect2: TShadowEffect;
    edtDescTT: TEdit;
    cmbDescTipo: TComboBox;
    Layout4: TLayout;
    lblDescSubTT: TLabel;
    lblValorPagar: TLabel;
    layValorPagar: TLayout;
    Rectangle1: TRectangle;
    Rectangle2: TRectangle;
    Label16: TLabel;
    Layout6: TLayout;
    Rectangle3: TRectangle;
    btnConfirmarVlPagar: TSpeedButton;
    Label18: TLabel;
    Rectangle4: TRectangle;
    btnCancelarVlPagar: TSpeedButton;
    Label19: TLabel;
    ShadowEffect3: TShadowEffect;
    edtValorPagar: TEdit;
    Label3: TLabel;
    rectCredito: TRectangle;
    Image7: TImage;
    rectOutros: TRectangle;
    Image8: TImage;
    Label8: TLabel;
    rectDebito: TRectangle;
    Image9: TImage;
    Label14: TLabel;
    Credito: TLabel;
    layBtnCancelar: TLayout;
    Image10: TImage;
    Label5: TLabel;
    layBtnEmissao: TLayout;
    Image11: TImage;
    Label20: TLabel;
    Image6: TImage;
    layQuantidade: TLayout;
    Rectangle5: TRectangle;
    Rectangle6: TRectangle;
    Label21: TLabel;
    Layout7: TLayout;
    Rectangle7: TRectangle;
    btnAplicarQuantidade: TSpeedButton;
    Label22: TLabel;
    Rectangle8: TRectangle;
    btnCancelarQtd: TSpeedButton;
    Label23: TLabel;
    ShadowEffect4: TShadowEffect;
    edtQuantidade: TEdit;
    imgAdicionar: TImage;
    imgRemover: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormVirtualKeyboardHidden(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
    procedure FormVirtualKeyboardShown(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
    procedure btnLimpaCodigoClick(Sender: TObject);
    procedure imgListaClick(Sender: TObject);
    procedure lvItensItemClickEx(const Sender: TObject; ItemIndex: Integer;
      const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
    procedure RoundRect1Click(Sender: TObject);
    procedure btnVoltarPagamentoClick(Sender: TObject);
    procedure edtCdProdutoKeyUp(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure edtDescTTKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure layBtnDescontoClick(Sender: TObject);
    procedure btnCancelarDescClick(Sender: TObject);
    procedure btnConfirmarDescClick(Sender: TObject);
    procedure rectDinheiroClick(Sender: TObject);
    procedure lblTituloClick(Sender: TObject);
    procedure lblQtItensClick(Sender: TObject);
    procedure btnConfirmarVlPagarClick(Sender: TObject);
    procedure btnCancelarVlPagarClick(Sender: TObject);
    procedure edtValorPagarTyping(Sender: TObject);
    procedure rectPagarClick(Sender: TObject);
    procedure layBtnCancelarClick(Sender: TObject);
    procedure lvItensDeletingItem(Sender: TObject; AIndex: Integer;
      var ACanDelete: Boolean);
    procedure edtDescTTTyping(Sender: TObject);
    procedure layBtnEmissaoClick(Sender: TObject);
    procedure layBtnClienteClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure rectOutrosClick(Sender: TObject);
    procedure rectDebitoClick(Sender: TObject);
    procedure rectCreditoClick(Sender: TObject);
    procedure edtQuantidadeTyping(Sender: TObject);
    procedure btnAplicarQuantidadeClick(Sender: TObject);
    procedure btnCancelarQtdClick(Sender: TObject);
    procedure layBtnGerencialClick(Sender: TObject);
    procedure layBtnSairClick(Sender: TObject);
    procedure imgBarCodeClick(Sender: TObject);
    procedure rectQtdClick(Sender: TObject);
  private
    procedure PosicionarUltimoItemListView;
    procedure pAdicionarItemCupom(cdBarras: String);
    procedure pAdicionarItemLista(const sequencia, Codigo: Integer; const Barras, Nome: string; const vUnit, Total: Currency; const Qtd: Double);
    procedure pAtualizarTela;
    procedure pCarregarVendaAberta;
    function fCarregarItensVenda: Boolean;
    function fReceberValor(const tipo: tpFinalizadora; const valor: Currency): Boolean;
    function ValidarDesc: Boolean;

    procedure SairVenda;
    procedure pIniciarPagamento;
    procedure pVoltarVendas;
    procedure pAdicionarPagLista(descricao: String; valor: Currency);
    procedure pAbrirLayDesc;
    procedure pAbrirLayValorPagar;
    procedure pFinalizarVenda;
    procedure pLimparDados;
    procedure pConsultarCliente;
    procedure FecharLays;
    procedure pMsgCancelarDesc;
    procedure pMsgSomenteAviso(titulo, texto: String);
    procedure AplicarQuantidade;
    procedure AbrirLayQuantidade;
    procedure PrepararQuantidade(ItemObject: TListItemDrawable);
  public
    { Public declarations }
    function fTotaisCupom: boolean;

  end;

  const
    rCupomVazio: TCupom = ();
    rCliCupomVazio: TCliCupom = ();
    rProdutoVazio: TProdutoCupom = ();

  var
    rCupom: TCupom;
    rCliCupom: TCliCupom;
    rProdutoCupom: TProdutoCupom;
    rItemlista: TItemLista;

  procedure pEditarCampo(const tipoCampo, titulo, textPrompt, textPadrao: string; indObrigatorio: Boolean; tamMax: Integer);

var
  frmVendas: TfrmVendas;

implementation

uses
  uFrmLogin, uFrmEditor, uDmPrincipal, uFrmMensagem, uUtilitarios,
  uConsultaBanco, uFormat, uFrmCnsProduto, uFrmCnsNota, uFrmCnsCliente, uDmNfe, uFrmMenuPrincipal, uFrmLeitorBarcode, Loading;

{$R *.fmx}

procedure pEditarCampo(const tipoCampo, titulo, textPrompt, textPadrao: string; indObrigatorio: Boolean; tamMax: Integer);
begin
  if not Assigned(frmEditor) then
    Application.CreateForm(TfrmEditor, frmEditor);

  with frmEditor do
  begin
    lblTitulo.Text := titulo;
    indCampoObrigatorio := indObrigatorio;

    if UpperCase(tipoCampo) = 'EDIT' then
    begin
      edtTexto.TextPrompt := textPrompt;
      edtTexto.MaxLength := tamMax;
      edtTexto.Text := textPadrao;
    end
    else if UpperCase(tipoCampo) = 'DECIMAL' then
    begin
      edtTexto.TextPrompt := textPrompt;
      edtTexto.MaxLength := tamMax;
      edtTexto.Text := textPadrao;
      edtTexto.KeyboardType := TVirtualKeyboardType.DecimalNumberPad;
    end;
  end;
end;

procedure TfrmVendas.btnAplicarQuantidadeClick(Sender: TObject);
begin
  AplicarQuantidade;
end;

procedure TfrmVendas.AplicarQuantidade;
begin
  dmPrincipal.ModificarQuantidade(ADD, rItemlista.nrSequencia, edtQuantidade.Text);
  if fTotaisCupom then
    fCarregarItensVenda;
  AbrirLayQuantidade;
end;

procedure TfrmVendas.btnCancelarDescClick(Sender: TObject);
begin
  layDescTotal.Visible := False;
end;

procedure TfrmVendas.btnCancelarQtdClick(Sender: TObject);
begin
  FecharLays;
end;

procedure TfrmVendas.btnCancelarVlPagarClick(Sender: TObject);
begin
  pAbrirLayValorPagar
end;

procedure TfrmVendas.btnConfirmarDescClick(Sender: TObject);
begin
  if not ValidarDesc then
    Exit;

  dmPrincipal.pRatearDescontoItem(StrToFloat(edtDescTT.Text));
  fTotaisCupom;
  layDescTotal.Visible := False;
end;

procedure TfrmVendas.btnConfirmarVlPagarClick(Sender: TObject);
begin
  lblValorPagar.Text := edtValorPagar.Text;
  layValorPagar.Visible := False;
end;

procedure TfrmVendas.btnLimpaCodigoClick(Sender: TObject);
begin
  edtCdProduto.Text := '';
end;

procedure TfrmVendas.btnVoltarPagamentoClick(Sender: TObject);
begin
  dmPrincipal.pDeletarPagBanco;
  pVoltarVendas;
end;

procedure TfrmVendas.edtCdProdutoKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkReturn then
    pAdicionarItemCupom(edtCdProduto.Text);
end;

procedure TfrmVendas.edtDescTTKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkReturn then
    ValidarDesc;
end;

procedure TfrmVendas.edtDescTTTyping(Sender: TObject);
begin
  Formatar(edtDescTT, Valor);
end;

procedure TfrmVendas.edtQuantidadeTyping(Sender: TObject);
begin
  Formatar(edtQuantidade, Peso);
end;

procedure TfrmVendas.edtValorPagarTyping(Sender: TObject);
begin
  Formatar(edtValorPagar, Valor);
end;

function TfrmVendas.fTotaisCupom: boolean;
begin
  result := dmPrincipal.CalcularTotaisCupom;
  pAtualizarTela;
end;

function TfrmVendas.fCarregarItensVenda: Boolean;
begin
  try
    with dmPrincipal do
    begin
      try
        qryNotaI.ParamByName('NR_DOCUMENTO').AsInteger := rCupom.nrDocumento;
        qryNotaI.Open;

        lvItens.Items.Clear;
        qryNotaI.First;
        while not qryNotaI.Eof do
        begin
          pAdicionarItemLista(qryNotaI.FieldByName('NR_SEQUENCIA').AsInteger,
                              qryNotaI.FieldByName('CD_PRODUTO').AsInteger,
                              qryNotaI.FieldByName('CD_BARRAS').AsString,
                              qryNotaI.FieldByName('DESCRICAO').AsString,
                              qryNotaI.FieldByName('VL_BRUTO').AsCurrency,
                              qryNotaI.FieldByName('VL_TOTAL').AsCurrency,
                              qryNotaI.FieldByName('QTD').AsFloat);
          qryNotaI.Next;
        end;

      finally
        qryNotaI.Close;
        fTotaisCupom;
      end;
    end;
  except
    raise Exception.Create('Erro ao carregar os itens');
  end;
end;

procedure TfrmVendas.FormCreate(Sender: TObject);
begin
  TabControl.TabPosition := TTabPosition.None;
  FecharLays;
  layCodigo.Height := 44;
  pLimparDados;
  pCarregarVendaAberta;
  dmPrincipal.ConfigurarPosPrinter;
end;

procedure TfrmVendas.FormKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if key = vkHardwareBack then
  begin
    FecharLays;
    Key := 0;
  end;
end;

procedure TfrmVendas.FormVirtualKeyboardHidden(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
begin
  layCodigo.Margins.Bottom := 0;
end;

procedure TfrmVendas.FormVirtualKeyboardShown(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
begin
  layCodigo.Margins.Bottom := Bounds.Height;
end;

function TfrmVendas.fReceberValor(const tipo: tpFinalizadora;
  const valor: Currency): Boolean;
begin
  if tipo = DINHEIRO then
  begin
    pAdicionarPagLista('DINHEIRO', valor);

    if valor >= rCupom.vlSubTotal then
    begin
      rCupom.pagVlTroco := valor - rCupom.vlSubTotal;
      if dmPrincipal.GravarPagBanco(1, valor) then
        pFinalizarVenda;
      Exit;
    end
    else
    begin
      dmPrincipal.GravarPagBanco(1, valor);
      rCupom.vlSubTotal := rCupom.vlSubTotal - valor;
      pAdicionarPagLista('SUBTOTAL', rCupom.vlSubTotal)
    end;
  end;

  {SUBTOTAL}
  lblValorPagar.Text := FormatCurr('0.00', rCupom.vlSubTotal);
end;

procedure TfrmVendas.imgBarCodeClick(Sender: TObject);
begin
  Application.CreateForm(TfrmLeitorBarcode, frmLeitorBarcode);

  frmLeitorBarcode.ShowModal(
    procedure(ModalResult: TModalResult)
    begin
      if ModalResult = mrOk then
        pAdicionarItemCupom(frmLeitorBarcode.retorno);
      frmLeitorBarcode.Free;
    end);
end;

procedure TfrmVendas.imgListaClick(Sender: TObject);
begin
  Application.CreateForm(TfrmCnsProduto, frmCnsProduto);
  frmCnsProduto.ShowModal(
    procedure(ModalResult: TModalResult)
    begin
      if ModalResult = mrOk then
        pAdicionarItemCupom(frmCnsProduto.retorno);
      frmCnsProduto.Free;
    end);
end;

procedure TfrmVendas.layBtnDescontoClick(Sender: TObject);
begin
  MultiView.HideMaster;
  pAbrirLayDesc;
end;

procedure TfrmVendas.layBtnEmissaoClick(Sender: TObject);
begin
  Application.CreateForm(TfrmCnsNota, frmCnsNota);
  frmCnsNota.ShowModal(
    procedure(ModalResult: TModalResult)
    begin
      frmCnsNota.Free;
      pLimparDados;
    end);
  MultiView.HideMaster;
end;

procedure TfrmVendas.layBtnGerencialClick(Sender: TObject);
begin
  MultiView.HideMaster;
  dmPrincipal.RelGerencial;
end;

procedure TfrmVendas.layBtnSairClick(Sender: TObject);
begin
  SairVenda;
end;

procedure TfrmVendas.layBtnCancelarClick(Sender: TObject);
begin
  MultiView.HideMaster;
  dmPrincipal.pDeletarVendaBanco;
  pLimparDados;
end;

procedure TfrmVendas.layBtnClienteClick(Sender: TObject);
begin
  pConsultarCliente;
  MultiView.HideMaster;
end;

procedure TfrmVendas.lblQtItensClick(Sender: TObject);
begin
  Application.CreateForm(Tdados, dados);
  dados.ShowModal(
  procedure(ModalResult: TModalResult)
    begin
      dados.Free;
    end)
//  imprimir.impTeste;
end;

procedure TfrmVendas.lblTituloClick(Sender: TObject);
begin
//  try
//    imprimir.pImprimirVenda;
//  except on E: Exception do
//    raise Exception.Create('Erro ao imprimir: ' + e.Message);
//  end;

end;

procedure TfrmVendas.lvItensDeletingItem(Sender: TObject; AIndex: Integer;
  var ACanDelete: Boolean);
var
  item: TListViewItem;
  sequencia: String;
  descricao: String;

  procedure pMsgCancelarItem;
  begin
    if not Assigned(frmMensagem) then
      Application.CreateForm(TfrmMensagem, frmMensagem);

    with frmMensagem do
    begin
      pPadraoPergunta;
      lblTitulo.Text := 'CANCELAR ITEM';
      lblMsg.Text := 'Deseja cancelar o item?' + #13 +
                     '- ' + copy(descricao, 0, 25);
    end;

    frmMensagem.ShowModal(
      procedure(ModalResult: TModalResult)
      begin
        if frmMensagem.retorno = 1 then
        begin
          if rCupom.qtItens > 1 then
          begin
            dmPrincipal.pDeletarItemBanco(StrToInt(sequencia));
            fTotaisCupom;
            Exit;
          end
          else {Ultimo item do cupom}
          begin
            dmPrincipal.pDeletarVendaBanco;
            pLimparDados;
          end;
        end;
        fCarregarItensVenda;
        frmMensagem.Free;
      end);
  end;

begin
  item := lvItens.items[AIndex];
  sequencia := TListItemText(item.Objects.FindDrawable('Text1')).TagString;
  descricao := TListItemText(item.Objects.FindDrawable('Text2')).TagString;

  pMsgCancelarItem;
end;

procedure TfrmVendas.PrepararQuantidade(ItemObject: TListItemDrawable);
begin
  if ItemObject.Name = 'Image8' then
    dmPrincipal.ModificarQuantidade(ADD, rItemlista.nrSequencia, '1')
  else if (ItemObject.Name = 'Image9') and ((rItemlista.quantidade - 1) > 0) then
    dmPrincipal.ModificarQuantidade(REMOVE, rItemlista.nrSequencia, '1')
  else
    Exit;

  fCarregarItensVenda;
end;

procedure TfrmVendas.lvItensItemClickEx(const Sender: TObject;
  ItemIndex: Integer; const LocalClickPos: TPointF;
  const ItemObject: TListItemDrawable);
begin
  rItemlista.nrSequencia :=
    TListItemText(lvItens.items[ItemIndex].Objects.FindDrawable('Text1')).TagString.ToInteger;
  rItemLista.descricao :=
    TListItemText(lvItens.items[ItemIndex].Objects.FindDrawable('Text2')).TagString;
  rItemLista.quantidade :=
    StrToFloat(TListItemText(lvItens.items[ItemIndex].Objects.FindDrawable('Text11')).TagString);

  if ItemObject is TListItemImage then
    PrepararQuantidade(ItemObject)
  else if ItemObject is TListItemText then
  begin
    if ItemObject.Name = 'Text11' then
      AbrirLayQuantidade;
  end;

end;

procedure TfrmVendas.pAbrirLayDesc;
begin
  if rCupom.vlTotal <= 0 then
    Exit;

  cmbDescTipo.Index := 0;
  edtDescTT.Text := '0,00';
  lblDescTT.Text := '0,00';
  lblDescSubTT.Text := '0,00';

  if rCupom.vlDescontoSub = 0 then
  begin
    layDescTotal.Visible := True;
    edtDescTT.SetFocus;
    Exit;
  end;

  {Ja existe desconto}
  pMsgCancelarDesc;
end;

procedure TfrmVendas.pAbrirLayValorPagar;
begin
  if layValorPagar.Visible = False then
  begin
    edtValorPagar.Text := '0,00';
    layValorPagar.Visible := True;
    edtValorPagar.SetFocus;
  end
  else
    layValorPagar.Visible := False;
end;

procedure TfrmVendas.pAdicionarItemCupom(cdBarras: String);
begin
  rProdutoCupom := dmPrincipal.fBuscarProduto(cdBarras);

  if (cdBarras = '') or (rProdutoCupom.cdBarras = '') then
  begin
    ShowMessage('Produto não encontrado ou sem preço de venda.');
    Exit;
  end;

  if rCupom.nrDocumento = 0 then
    dmPrincipal.GravarVendaBanco;

  if dmPrincipal.GravarItemBanco then
    pAdicionarItemLista(rProdutoCupom.nrSequencia,
                        rProdutoCupom.cdProduto,
                        rProdutoCupom.cdBarras,
                        rProdutoCupom.descricao,
                        rprodutoCupom.preco,
                        rprodutoCupom.vlTotal,
                        rprodutoCupom.qtd);

  edtCdProduto.Text := '';
  rProdutoCupom := rProdutoVazio;

  fTotaisCupom;
end;

procedure TfrmVendas.pAdicionarItemLista(const sequencia, Codigo: Integer; const Barras, Nome: string; const vUnit, Total: Currency; const Qtd: Double);
var
  item: TListViewItem;
  txt: TListItemText;
  img: TListItemImage;
begin
  try
    item := lvItens.Items.Add;
    with item do
    begin
      //Sequencia
      txt := TlistItemText(Objects.FindDrawable('Text1'));
      txt.Text := sequencia.ToString;
      txt.TagString := txt.Text;

      //Barras
      txt := TlistItemText(Objects.FindDrawable('Text7'));
      txt.Text := Barras;
      txt.TagString := txt.Text;

      //Descricao
      txt := TlistItemText(Objects.FindDrawable('Text2'));
      txt.Text := AnsiUpperCase(Nome);
      txt.TagString := txt.Text;

      //Quantidade
      txt := TlistItemText(Objects.FindDrawable('Text11'));
      txt.Text := FormatFloat('0.000', Qtd);
      txt.TagString := txt.Text;

      //Valor unitario
      txt := TlistItemText(Objects.FindDrawable('Text5'));
      txt.Text := FormatCurr('R$ 0.00', vUnit);
      txt.TagString := txt.Text;

      //Valor total
      txt := TlistItemText(Objects.FindDrawable('Text6'));
      txt.Text := FormatCurr('R$ 0.00', Total);
      txt.TagString := txt.Text;

      //Imagens Quantidade
      img := TListItemImage(Objects.FindDrawable('Image8'));
      img.TagString := 'Add';
      img.Bitmap := imgAdicionar.Bitmap;

      img := TListItemImage(Objects.FindDrawable('Image9'));
      img.TagString := 'Remove';
      img.Bitmap := imgRemover.Bitmap;
    end;

    PosicionarUltimoItemListView;
  except on E: Exception do
    Log('pAdicionarItemLista', E.Message);
  end;
end;

procedure TfrmVendas.pAdicionarPagLista(descricao: String; valor: Currency);
  function fCriarTextPag: String;
  var
    ponto: String;
  begin
    ponto := '..........................................................';
    ponto := Copy(ponto, 1, 59 - length(FormatCurr('0.00', valor)));
    result := descricao + ponto + FormatCurr('0.00', valor);
  end;
var
  item: TListViewItem;
  txt: TListItemText;
begin
  item := lvPagamentos.Items.Add;
  with item do
  begin
    {DESCRICAO}
    txt := TlistItemText(Objects.FindDrawable('Text1'));
    txt.Text := descricao;
    txt.TagString := txt.Text;

    {VALOR}
    txt := TlistItemText(Objects.FindDrawable('Text2'));
    txt.Text := FormatCurr('R$ 0.00', valor);
    txt.TagString := txt.Text;
  end;
end;

procedure TfrmVendas.pAtualizarTela;
begin
  lblTotal.Text := FormatCurr('R$ 0.00', rCupom.vlTotal);
  lblDesconto.Text := FormatCurr('R$ 0.00', rCupom.vlDesconto);
  lblSubtotal.Text := FormatCurr('R$ 0.00', rCupom.vlSubTotal);
  lblQtItens.Text := rCupom.qtItens.ToString;
end;

procedure TfrmVendas.pCarregarVendaAberta;
begin
  rCupom.nrDocumento := dmPrincipal.fDocumentoAberto;
  if rCupom.nrDocumento = 0 then
    Exit;

  fCarregarItensVenda;
end;

procedure TfrmVendas.pConsultarCliente;
  procedure pMsgClienteInformado;
  begin
    if not Assigned(frmMensagem) then
    Application.CreateForm(TfrmMensagem, frmMensagem);

    with frmMensagem do
    begin
      pPadraoPergunta;
      lblTitulo.Text := 'Identificar Cliente';
      lblMsg.Text := 'Deseja alterar o cliente informado?' + #13 +
                     copy(rCliCupom.nmCliente, 0, 25);
    end;

    frmMensagem.ShowModal(
    procedure(ModalResult: TModalResult)
    begin
      if frmMensagem.retorno = 1 then
      begin
        Application.CreateForm(TfrmCnsCliente, frmCnsCliente);
        frmCnsCliente.ShowModal(
        procedure(ModalResult: TModalResult)
        begin
          frmCnsCliente.Free;
        end);
      end;
      frmMensagem.Free;
    end);
  end;

begin
  if rCliCupom.nmCliente <> '' then
  begin
    pMsgClienteInformado;
    Exit;
  end;

  Application.CreateForm(TfrmCnsCliente, frmCnsCliente);
  frmCnsCliente.ShowModal(
  procedure(ModalResult: TModalResult)
  begin
    frmCnsCliente.Free;
  end);
end;

procedure TfrmVendas.FecharLays;
begin
  MultiView.HideMaster;
  layDescTotal.Visible := False;
  layQuantidade.Visible := False;
end;

procedure TfrmVendas.pFinalizarVenda;
begin
  TLoading.Show(Self, 'Emitindo');
  TThread.CreateAnonymousThread(procedure
  begin
    dmPrincipal.CalcularImposto;
    dmNfe.EmitirNota;
    dmPrincipal.AtualizarStatusNota;

    TThread.Synchronize(nil, procedure
    begin
      TLoading.Hide;
      pLimparDados;
    end);
  end).Start;
end;

procedure TfrmVendas.pIniciarPagamento;
begin
  if (rCupom.nrDocumento = 0) or (rCupom.vlTotal = 0) then
    Exit;

  lvPagamentos.Items.Clear;
  pAdicionarPagLista('SUBTOTAL', rCupom.vlSubTotal);

  lblValorPagar.Text := FormatCurr('0.00', rCupom.vlSubTotal);
  actTabPagamento.ExecuteTarget(nil);
end;

procedure TfrmVendas.pLimparDados;
begin
  rCupom := rCupomVazio;
  rCliCupom := rCliCupomVazio;
  rCliCupom.cdCliente := 1;
  rCliCupom.nmCliente := 'CONSUMIDOR';

  pAtualizarTela;
  lvItens.Items.Clear;
  actTabVenda.ExecuteTarget(nil);
end;

procedure TfrmVendas.pMsgCancelarDesc;
begin
  if not Assigned(frmMensagem) then
    Application.CreateForm(TfrmMensagem, frmMensagem);

  with frmMensagem do
  begin
    pPadraoPergunta;
    lblTitulo.Text := 'CANCELAR DESCONTO';
    lblMsg.Text := 'Deseja cancelar o desconto anterior?' + #13 +
                   FormatCurr('Desconto: 0.00', rCupom.vlDescontoSub) ;
  end;

  frmMensagem.ShowModal(
  procedure(ModalResult: TModalResult)
  begin
    if frmMensagem.retorno = 1 then
    begin
      dmPrincipal.pLimparDesconto;
      fTotaisCupom;
      layDescTotal.Visible := True;
    end;
    frmMensagem.Free;
  end);
end;

procedure TfrmVendas.pMsgSomenteAviso(titulo, texto: String);
begin
  if not Assigned(frmMensagem) then
    Application.CreateForm(TfrmMensagem, frmMensagem);

  with frmMensagem do
  begin
    pPadraoMsg;
    lblTitulo.Text := titulo;
    lblMsg.Text := texto;
  end;

  frmMensagem.ShowModal(
  procedure(ModalResult: TModalResult)
  begin
    {Somente mensagem}
    frmMensagem.Free;
  end);
end;

procedure TfrmVendas.PosicionarUltimoItemListView;
var
  Tmp_top, scroll_total: Single;
begin
  Tmp_top := lvItens.GetItemRect(lvItens.ItemCount - 1).top + lvItens.ScrollViewPos -
    lvItens.SideSpace - lvItens.LocalRect.top;
  scroll_total := Tmp_top + lvItens.GetItemRect(lvItens.ItemCount - 1).Height - lvItens.Height;
  lvItens.ScrollViewPos := scroll_total;
end;

function TfrmVendas.ValidarDesc: Boolean;
var
  vlTotalDesc: Currency;
begin
  vlTotalDesc := 0;
  result := False;

  if StrToFloatDef(edtDescTT.Text, 0) <= 0 then
    Exit;

  {Calcula valor do desconto}
  if cmbDescTipo.ItemIndex = 0 then
    vlTotalDesc := StrToFloat(edtDescTT.Text)
  else
    vlTotalDesc := (StrToFloat(edtDescTT.Text) * rCupom.vlTotal / 100);

  {Valida desconto menor que o subTotal}
  if (rCupom.vlTotal - vlTotalDesc) <= rCupom.qtItens / 100 then
  begin
    Toast('Desconto inválido', longToast);
    Exit;
  end;

  result := True;
end;

procedure TfrmVendas.pVoltarVendas;
begin
  fTotaisCupom;
  lblTitulo.Text := 'Vendas';
  actTabVenda.ExecuteTarget(nil);
end;

procedure TfrmVendas.rectCreditoClick(Sender: TObject);
begin
  pMsgSomenteAviso('NÃO DISPONÍVEL',
                   'Funcionalidade não disponível');
end;

procedure TfrmVendas.rectDebitoClick(Sender: TObject);
begin
  pMsgSomenteAviso('NÃO DISPONÍVEL',
                   'Funcionalidade não disponível');
end;

procedure TfrmVendas.rectDinheiroClick(Sender: TObject);
begin
  fReceberValor(DINHEIRO, StrToCurr(lblValorPagar.Text));
end;

procedure TfrmVendas.rectOutrosClick(Sender: TObject);
begin
  pMsgSomenteAviso('NÃO DISPONÍVEL',
                   'Funcionalidade não disponível');
end;

procedure TfrmVendas.rectPagarClick(Sender: TObject);
begin
  pAbrirLayValorPagar;
end;

procedure TfrmVendas.rectQtdClick(Sender: TObject);
begin
  AbrirLayQuantidade;
end;

procedure TfrmVendas.AbrirLayQuantidade;
begin
  if layQuantidade.Visible then
  begin
    layQuantidade.Visible := False;
    Exit;
  end;

  Teclado(edtQuantidade);
  layQuantidade.Visible := True;
  edtQuantidade.SetFocus;
end;

procedure TfrmVendas.RoundRect1Click(Sender: TObject);
begin
  pIniciarPagamento;
end;

procedure TfrmVendas.SairVenda;
begin
  if not Assigned(frmMenuPrincipal) then
    Application.CreateForm(TfrmMenuPrincipal, frmMenuPrincipal);

  frmMenuPrincipal.Show;
end;

end.

