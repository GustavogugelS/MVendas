unit uFrmCnsNota;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  uFrmCnsBase, FMX.ListView.Types, FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base, FMX.ListView, FMX.Objects, Androidapi.JNI.Toast,
  FMX.Controls.Presentation, FMX.Edit, FMX.Layouts, FMX.Effects;

type
  TfrmCnsNota = class(TfrmCnsBase)
    imgEmitido: TImage;
    imgCancelado: TImage;
    imgPendente: TImage;
    layOpcoes: TLayout;
    Rectangle1: TRectangle;
    Rectangle2: TRectangle;
    lblNrNota: TLabel;
    Layout6: TLayout;
    Rectangle3: TRectangle;
    btnConfirmarVlPagar: TSpeedButton;
    Label18: TLabel;
    Rectangle4: TRectangle;
    btnCancelarVlPagar: TSpeedButton;
    Label19: TLabel;
    ShadowEffect3: TShadowEffect;
    lvOpcoes: TListView;
    procedure edtBuscaChangeTracking(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lvOpcoesItemClickEx(const Sender: TObject; ItemIndex: Integer;
      const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
    procedure lvConsultaItemClickEx(const Sender: TObject; ItemIndex: Integer;
      const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
  private
    { Private declarations }
    procedure pCarregarNota;
    procedure pCarregarOpcoes;
    procedure pMsgCancelarNota;
    procedure pCarregarNotaImpressao;
    procedure pAutorizarNota;
    procedure pAdicionarNotaLista(const nrDocumento, nrNota, status,
      sitNfce: Integer; const vlTotal: Currency; danfe, cliente: String);
  public
    { Public declarations }
  end;

var
  frmCnsNota: TfrmCnsNota;

implementation

uses
  uUtilitarios, uDmPrincipal, uFrmVendas, uFrmMensagem, uImpressao, uDmNfe;

{$R *.fmx}

{ TfrmCnsNota }

procedure TfrmCnsNota.edtBuscaChangeTracking(Sender: TObject);
begin
  inherited;
  pCarregarNota;
end;

procedure TfrmCnsNota.FormCreate(Sender: TObject);
begin
  inherited;
  pCarregarNota;
end;

procedure TfrmCnsNota.lvConsultaItemClickEx(const Sender: TObject;
  ItemIndex: Integer; const LocalClickPos: TPointF;
  const ItemObject: TListItemDrawable);
begin
  rCupom.nrNota :=
    TListItemText(lvConsulta.items[ItemIndex].Objects.FindDrawable('Text1')).TagString.ToInteger;
  rCupom.nrDocumento :=
    TListItemText(lvConsulta.items[ItemIndex].Objects.FindDrawable('Text6')).TagString.ToInteger;
  rCupom.autSituacaoNfce :=
    TListItemImage(lvConsulta.items[ItemIndex].Objects.FindDrawable('Image5')).TagString;

  pCarregarOpcoes;
end;

procedure TfrmCnsNota.lvOpcoesItemClickEx(const Sender: TObject;
  ItemIndex: Integer; const LocalClickPos: TPointF;
  const ItemObject: TListItemDrawable);
var
  index: Integer;
begin
  pCarregarOpcoes;

  index :=
    TListItemText(lvOpcoes.items[ItemIndex].Objects.FindDrawable('Text1')).TagString.ToInteger;

  case index of
    1: dmNfe.ReimprimirNota;
    {TODO: Autorizar nota feita}
    3: pMsgCancelarNota;
  end;
end;

procedure TfrmCnsNota.pAdicionarNotaLista(const nrDocumento, nrNota,
  status, sitNfce: Integer; const vlTotal: Currency; danfe, cliente: String);
var
  item: TListViewItem;
  txt: TListItemText;
  img: TListItemImage;
begin
  try
    item := lvConsulta.Items.Add;
    with item do
    begin
      {NrNota}
      txt := TlistItemText(Objects.FindDrawable('Text1'));
      txt.Text := nrNota.ToString;
      txt.TagString := txt.Text;

      {Chave Danfe}
      txt := TlistItemText(Objects.FindDrawable('Text2'));
      if danfe = '' then danfe := 'Não emitido - situação: ' + sitNfce.ToString;
      txt.Text := danfe;
      txt.TagString := txt.Text;

      {Valor Total}
      txt := TlistItemText(Objects.FindDrawable('Text3'));
      txt.Text := FormatCurr('R$ 0.00', vlTotal);
      txt.TagString := txt.Text;

      {Nome Cliente}
      txt := TlistItemText(Objects.FindDrawable('Text4'));
      txt.Text := cliente;
      txt.TagString := txt.Text;

      {NrDocumento}
      txt := TlistItemText(Objects.FindDrawable('Text6'));
      txt.Text := nrDocumento.ToString;
      txt.TagString := txt.Text;

      {Status}
      img := TListItemImage(Objects.FindDrawable('Image5'));
      img.TagString := sitNfce.ToString;
      case sitNfce of
        0: img.Bitmap := nil;
        100: img.Bitmap := imgEmitido.Bitmap;
        101: img.Bitmap := imgCancelado.Bitmap;
        else img.Bitmap := imgPendente.Bitmap;
      end;
    end;
  Except on E: Exception do
    Log('pAdicionarNotaLista', E.Message);
  end;
end;

procedure TfrmCnsNota.pAutorizarNota;
begin
  dmNfe.EmitirNota;
end;

procedure TfrmCnsNota.pCarregarNota;
var
  SQL: String;
begin
  try
    try
      SQL := 'SELECT ' +
             '    NR_DOCUMENTO, ' +
             '    NR_NOTA, ' +
             '    DANFE, ' +
             '    VL_TOTAL, ' +
             '    NOME_CLIENTE, ' +
             '    STATUS, ' +
             '    SITUACAO_NFCE ' +
             'FROM ' +
             '    NOTAC ' +
             'ORDER BY SITUACAO_NFCE DESC';

      if not edtBusca.Text.IsEmpty then {FILTRO NOTA}
         SQL := SQL + ' AND UPPER(NR_NOTA) = ' + edtBusca.Text;
      SQL := SQL + ' LIMIT 100 ';

      qryConsulta.Open(SQL);
      qryConsulta.First;
      lvConsulta.Items.Clear;
      while not qryConsulta.Eof do
      begin
        pAdicionarNotaLista(qryConsulta.FieldByName('NR_DOCUMENTO').AsInteger,
                            qryConsulta.FieldByName('NR_NOTA').AsInteger,
                            qryConsulta.FieldByName('STATUS').AsInteger,
                            qryConsulta.FieldByName('SITUACAO_NFCE').AsInteger,
                            qryConsulta.FieldByName('VL_TOTAL').AsCurrency,
                            qryConsulta.FieldByName('DANFE').AsString,
                            qryConsulta.FieldByName('NOME_CLIENTE').AsString);
        qryConsulta.Next;
      end;
    finally
      qryConsulta.Close;
    end;
  except on E: Exception do
    Log('pCarregarNota', E.Message);
  end;
end;

procedure TfrmCnsNota.pCarregarNotaImpressao;
begin
  dmPrincipal.fCalcularTotaisCupom;
  dmPrincipal.pCarregarDadosCliente;
  imprimir.ImprimirExtratoVenda;
end;

procedure TfrmCnsNota.pCarregarOpcoes;
begin
  if layOpcoes.Visible then
  begin
    layOpcoes.Visible := False;
    Exit;
  end;

  lvOpcoes.Items.Clear;

  pAddLista(lvOpcoes, 'Imprimir', 1);
  if rCupom.autSituacaoNfce.ToInteger = 100 then
    pAddLista(lvOpcoes, 'Cancelar', 3);
  if rCupom.autSituacaoNfce.ToInteger = 0 then
    pAddLista(lvOpcoes, 'Autorizar', 2);

  layOpcoes.Visible := True;
end;

procedure TfrmCnsNota.pMsgCancelarNota;
begin
  if not Assigned(frmMensagem) then
    Application.CreateForm(TfrmMensagem, frmMensagem);

  with frmMensagem do
  begin
    pPadraoPergunta;
    lblTitulo.Text := 'CANCELAR NOTA';
    lblMsg.Text := 'Deseja cancelar a nota?' + #13 +
                   'N° ' + rCupom.nrNota.ToString;
  end;

  frmMensagem.ShowModal(
    procedure(ModalResult: TModalResult)
    begin
      if frmMensagem.retorno = 1 then
      begin
        dmNfe.CancelarNota;
        if rCupom.autSituacaoNfce = '135' then
        begin
          dmPrincipal.AtualizarStatusNota(2);
          pCarregarNota;
          Toast('Nota cancelada');
        end;
      end;
      layOpCoes.Visible := False;
      frmMensagem.Free;
    end);
end;

end.
