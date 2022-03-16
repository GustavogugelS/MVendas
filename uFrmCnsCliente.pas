unit uFrmCnsCliente;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  uFrmCnsBase, FMX.ListView.Types, FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base, FMX.Objects, FMX.ListView,
  FMX.Controls.Presentation, FMX.Edit, FMX.Layouts;

type
  TfrmCnsCliente = class(TfrmCnsBase)
    Layout3: TLayout;
    rectNomeCpf: TRectangle;
    Label1: TLabel;
    rectInfNomeCPF: TRectangle;
    Rectangle2: TRectangle;
    Layout4: TLayout;
    Layout5: TLayout;
    SpeedButton1: TSpeedButton;
    Label2: TLabel;
    Layout6: TLayout;
    rectNome: TRectangle;
    edtNome: TEdit;
    btnLimpaNome: TLabel;
    rectCPF: TRectangle;
    edtCPF: TEdit;
    btnLimpaCPF: TLabel;
    rectConfirma: TRoundRect;
    SpeedButton2: TSpeedButton;
    procedure edtBuscaChangeTracking(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lvConsultaItemClickEx(const Sender: TObject; ItemIndex: Integer;
      const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
    procedure btnVoltarClick(Sender: TObject);
  private
    { Private declarations }
    procedure pCarregarCliente;
    procedure pAdicionarClienteLista(const codigo: integer; const nome, cpf: String);
    procedure CapturarDadosCliente(codigo: Integer = 1; nome: String = 'CONSUMIDOR'; cpf: String = '');
  public
    { Public declarations }
  end;

var
  frmCnsCliente: TfrmCnsCliente;

implementation

uses
  uUtilitarios, uFrmVendas;

{$R *.fmx}

{ TfrmCnsCliente }

procedure TfrmCnsCliente.btnVoltarClick(Sender: TObject);
begin
  inherited;
  CapturarDadosCliente(1 , '', '')
end;

procedure TfrmCnsCliente.CapturarDadosCliente(codigo: Integer; nome,
  cpf: String);
begin
  rCliCupom.cdCliente := codigo;
  rCliCupom.nmCliente := nome;
  rCliCupom.cpfCliente := cpf;
end;

procedure TfrmCnsCliente.edtBuscaChangeTracking(Sender: TObject);
begin
  inherited;
  pCarregarCliente;
end;

procedure TfrmCnsCliente.FormCreate(Sender: TObject);
begin
  inherited;
  pCarregarCliente;
end;

procedure TfrmCnsCliente.lvConsultaItemClickEx(const Sender: TObject;
  ItemIndex: Integer; const LocalClickPos: TPointF;
  const ItemObject: TListItemDrawable);
begin
  CapturarDadosCliente(
    TListItemText(lvConsulta.items[ItemIndex].Objects.FindDrawable('Text1')).TagString.ToInteger,
    TListItemText(lvConsulta.items[ItemIndex].Objects.FindDrawable('Text2')).TagString,
    TListItemText(lvConsulta.items[ItemIndex].Objects.FindDrawable('Text4')).TagString);

  inherited;
end;

procedure TfrmCnsCliente.pAdicionarClienteLista(const codigo: integer;
  const nome, cpf: String);
var
  item: TListViewItem;
  txt: TListItemText;
begin
  try
    item := lvConsulta.Items.Add;
    with item do
    begin
      {ID}
      txt := TlistItemText(Objects.FindDrawable('Text1'));
      txt.Text := codigo.ToString;
      txt.TagString := txt.Text;

      {Nome}
      txt := TlistItemText(Objects.FindDrawable('Text2'));
      txt.Text := nome;
      txt.TagString := txt.Text;

      {CPF}
      txt := TlistItemText(Objects.FindDrawable('Text3'));
      txt.Text := 'CPF: ';

      {CPF}
      txt := TlistItemText(Objects.FindDrawable('Text4'));
      txt.Text := cpf;
      txt.TagString := txt.Text;
    end;
  Except on E: Exception do
    Log('pAdicionarClienteLista', E.Message);
  end;
end;

procedure TfrmCnsCliente.pCarregarCliente;
var
  SQL: String;
begin
  try
    try
      SQL := 'SELECT ' +
             '    ID, ' +
             '    NOME, ' +
             '    CPF ' +
             'FROM ' +
             '    CLIENTE ' +
             'WHERE ' +
             '    ATIVO = 1 ';

      if not edtBusca.Text.IsEmpty then {FILTRO NOME}
         SQL := SQL + ' AND UPPER(NOME) LIKE ('+QuotedStr('%'+ edtBusca.Text +'%')+') ';
      SQL := SQL + ' LIMIT 100 ';

      qryConsulta.Open(SQL);
      qryConsulta.First;
      lvConsulta.Items.Clear;
      while not qryConsulta.Eof do
      begin
        pAdicionarClienteLista(qryConsulta.FieldByName('ID').AsInteger,
                               qryConsulta.FieldByName('NOME').AsString,
                               qryConsulta.FieldByName('CPF').AsString);
        qryConsulta.Next;
      end;
    finally
      qryConsulta.Close;
    end;
  except on E: Exception do
    Log('pCarregarCliente', E.Message);
  end;
end;

end.
