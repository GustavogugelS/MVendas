unit uConsultaBanco;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.Rtti,
  FMX.Grid.Style, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.Bind.EngExt, Fmx.Bind.DBEngExt,
  Fmx.Bind.Grid, System.Bindings.Outputs, Fmx.Bind.Editors,
  Data.Bind.Components, Data.Bind.Grid, Data.Bind.DBScope, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FMX.ScrollBox, FMX.Grid, FMX.Edit,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.Memo,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, Data.Bind.Controls, Fmx.Bind.Navigator, fmx.DialogService;

type
  Tdados = class(TForm)
    Layout1: TLayout;
    Button1: TButton;
    edtTabela: TEdit;
    edtWhere: TEdit;
    Grid1: TGrid;
    FDQuery1: TFDQuery;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkGridToDataSourceBindSourceDB1: TLinkGridToDataSource;
    chkDDl: TCheckBox;
    Layout2: TLayout;
    edtComandoSql: TMemo;
    Layout3: TLayout;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    lvTabelas: TListView;
    BindNavigator1: TBindNavigator;
    Button5: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Grid1CellClick(const Column: TColumn; const Row: Integer);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure edtComandoSqlClick(Sender: TObject);
    procedure edtTabelaClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lvTabelasItemClickEx(const Sender: TObject; ItemIndex: Integer;
      const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure pAddLista(tabela : string);
  end;

var
  dados: Tdados;

implementation

{$R *.fmx}

uses UdmPrincipal;

procedure Tdados.Button1Click(Sender: TObject);
var
  sql :String;
begin
  sql := 'Select * from ' + edtTabela.Text + ' ';
  if edtWhere.Text <> '' then
    sql := sql + ' Where' + edtTabela.Text + '  ';
  FDQuery1.SQL.Text := sql;
  FDQuery1.Active := true;
end;

procedure Tdados.Button2Click(Sender: TObject);
begin
    edtTabela.Text := 'CUPOM_PGTO';
    Button1Click(nil);
end;

procedure Tdados.Button3Click(Sender: TObject);
begin
    edtTabela.Text := 'TEF_MOVIMENTACAO';
    Button1Click(nil);
end;

procedure Tdados.Button4Click(Sender: TObject);
begin
 edtComandoSql.Text :=
 '  SELECT   '+
                                    '      CASE WHEN   '+
                                    '          CUPOM_PGTO.CD_FINALIZADORA = 1 THEN ''Dinheiro'' ELSE ''Cartão''   '+
                                    '      END FINALIZADORA,  '+
                                    '      SUM(CUPOM_PGTO.VL_FINALIZADORA) AS VALOR  '+
                                    '  FROM  '+
                                    '      CUPOM_PGTO  '+
                                    '  WHERE  '+
                                    '      CUPOM_PGTO.NR_DOCUMENTO =   1 '+
                                    '  AND '+
                                    '      CUPOM_PGTO.CD_CANCELAMENTO = 0 '+
                                    '  GROUP BY   1 ';

end;

procedure Tdados.edtComandoSqlClick(Sender: TObject);
begin
 VKAutoShowMode := TVKAutoShowMode.Always
end;

procedure Tdados.edtTabelaClick(Sender: TObject);
begin
 VKAutoShowMode := TVKAutoShowMode.Always;
end;

procedure Tdados.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ModalResult := mrOk;
end;

procedure Tdados.FormCreate(Sender: TObject);
var
  qry : tfdQuery;
begin

 try
    qry := TFDQuery.create(nil);
    qry.connection := dmPrincipal.conexao;

    qry.Active := false;
    qry.sql.clear;
    qry.sql.Text := ' SELECT tbl_name FROM sqlite_master WHERE type=''table'' order by tbl_name ' ;
    qry.active := true;
    qry.first;
    while not qry.eof  do
    begin
        pAddLista(qry.FieldByName('tbl_name').asString) ;

       qry.Next;
    end;


  except on E:Exception do
                        begin
                          raise Exception.Create('Erro ao verificar os totais de pagamento com a NFSC:' +
                          E.Message);

                        end;

  end;



end;

procedure Tdados.FormShow(Sender: TObject);
begin
  VKAutoShowMode := TVKAutoShowMode.Always;
end;

procedure Tdados.Grid1CellClick(const Column: TColumn; const Row: Integer);
begin
   Column.Width := 200;
end;

procedure Tdados.lvTabelasItemClickEx(const Sender: TObject; ItemIndex: Integer;
  const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
begin
  if TListView(Sender).Selected <> nil then
  begin
     edtTabela.Text :=TListItemText(lvTabelas.items[ItemIndex].Objects.FindDrawable('Text1')).TagString;
     Button1Click(nil);
  end;
end;

procedure Tdados.pAddLista(tabela: string);
var
  item : TListViewItem;
  txt : TListItemText;
begin
  lvTabelas.BeginUpdate;
  item := lvTabelas.items.add;

  txt := TListItemText(item.Objects.FindDrawable('Text1'));
  txt.Text := tabela;
  txt.TagString := tabela;

  lvTabelas.EndUpdate;
end;


end.
