unit uFrmCnsCliente;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  uFrmCnsBase, FMX.ListView.Types, FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base, FMX.Objects, FMX.ListView,
  FMX.Controls.Presentation, FMX.Edit, FMX.Layouts, FMX.TabControl,
  System.Actions, FMX.ActnList, System.StrUtils;

type
  TfrmCnsCliente = class(TfrmCnsBase)
    Layout3: TLayout;
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
    rectBtnEntrar: TRectangle;
    btnEntrar: TSpeedButton;
    layEntrar: TLayout;
    Layout8: TLayout;
    Layout9: TLayout;
    Edit1: TEdit;
    ListView1: TListView;
    Rectangle3: TRectangle;
    Layout10: TLayout;
    Layout11: TLayout;
    SpeedButton3: TSpeedButton;
    Label1: TLabel;
    Layout12: TLayout;
    Layout13: TLayout;
    Rectangle4: TRectangle;
    btnIdentificar: TSpeedButton;
    TabControl1: TTabControl;
    tabConsulta: TTabItem;
    TabIdentifica: TTabItem;
    ActionList1: TActionList;
    actConsulta: TChangeTabAction;
    actIdentifica: TChangeTabAction;
    procedure edtBuscaChangeTracking(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lvConsultaItemClickEx(const Sender: TObject; ItemIndex: Integer;
      const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
    procedure btnVoltarClick(Sender: TObject);
    procedure btnIdentificarClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure edtCPFTyping(Sender: TObject);
    procedure btnEntrarClick(Sender: TObject);
  private
    { Private declarations }
    procedure pCarregarCliente;
    procedure pAdicionarClienteLista(const codigo: integer; const nome, cpf: String);
    procedure CapturarDadosCliente(codigo: Integer = 1; nome: String = ''; cpf: String = '');

    procedure OrganizarTab;
    procedure MudarTab(tabIndexAtual: Integer);
    function ValidarCompos: Boolean;
  public
    { Public declarations }
  end;

var
  frmCnsCliente: TfrmCnsCliente;

implementation

uses
  uUtilitarios, uFrmVendas, uFormat, uDmPrincipal;

{$R *.fmx}

{ TfrmCnsCliente }

procedure TfrmCnsCliente.btnEntrarClick(Sender: TObject);
begin
  inherited;
  if ValidarCompos then
  begin
    CapturarDadosCliente(1, edtNome.Text, edtCPF.Text);
    if rCupom.nrDocumento > 0 then
      dmPrincipal.GravarClienteVenda(rCliCupom.cdCliente, rCliCupom.nmCliente, rCliCupom.cpfCliente);

    ModalResult := mrOk;
  end;
end;

procedure TfrmCnsCliente.btnIdentificarClick(Sender: TObject);
begin
  inherited;
  MudarTab(TabControl1.TabIndex);
end;

procedure TfrmCnsCliente.btnVoltarClick(Sender: TObject);
begin
  inherited;
  CapturarDadosCliente(1 , '', '');
  ModalResult := mrCancel;
end;

procedure TfrmCnsCliente.CapturarDadosCliente(codigo: Integer; nome,
  cpf: String);
begin
  rCliCupom.cdCliente := codigo;
  rCliCupom.nmCliente := nome;
  rCliCupom.cpfCliente := SomenteNumero(cpf);
end;

procedure TfrmCnsCliente.edtBuscaChangeTracking(Sender: TObject);
begin
  inherited;
  pCarregarCliente;
end;

procedure TfrmCnsCliente.edtCPFTyping(Sender: TObject);
begin
  inherited;
  if edtCPF.Text.Length <= 14 then
    Formatar(edtCPF, TFormato.CPF)
  else
    Formatar(edtCPF, TFormato.CNPJ);
end;

procedure TfrmCnsCliente.FormCreate(Sender: TObject);
begin
  inherited;
  OrganizarTab;
  pCarregarCliente;
end;

procedure TfrmCnsCliente.lvConsultaItemClickEx(const Sender: TObject;
  ItemIndex: Integer; const LocalClickPos: TPointF;
  const ItemObject: TListItemDrawable);
begin
  CapturarDadosCliente(
    TListItemText(ListView1.items[ItemIndex].Objects.FindDrawable('Text1')).TagString.ToInteger,
    TListItemText(ListView1.items[ItemIndex].Objects.FindDrawable('Text2')).TagString,
    TListItemText(ListView1.items[ItemIndex].Objects.FindDrawable('Text4')).TagString);

  ModalResult := mrOk;
end;

procedure TfrmCnsCliente.MudarTab(tabIndexAtual: Integer);
begin
  case tabIndexAtual of
    0: begin
      edtNome.Text := '';
      edtCPF.Text := '';
      actIdentifica.ExecuteTarget(nil);
    end;
    1: begin
      actConsulta.ExecuteTarget(nil);
    end;
  end;
end;

procedure TfrmCnsCliente.OrganizarTab;
begin
  TabControl1.TabPosition := TTabPosition.None;
  actConsulta.ExecuteTarget(nil);
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

procedure TfrmCnsCliente.SpeedButton1Click(Sender: TObject);
begin
  inherited;
  MudarTab(TabControl1.TabIndex);
end;

function TfrmCnsCliente.ValidarCompos: Boolean;
var
  cpf: String;
begin
  cpf := edtCPF.Text;
  result := false;

  if cpf = '' then
    result := True
  else if (cpf.Length <= 14) and (not TestarCPF(cpf)) then
    ShowMessage('CPF Inválido')
  else if (cpf.Length > 14) and (not TestarCNPJ(cpf)) then
    ShowMessage('CNPJ Inválido')
  else
    result := true;
end;

end.
