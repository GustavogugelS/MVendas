unit uFrmCnsBase;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, FMX.StdCtrls, FMX.Objects, FMX.Controls.Presentation, FMX.Edit,
  FMX.Layouts, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client;

type
  TfrmCnsBase = class(TForm)
    layEditBusca: TLayout;
    edtBusca: TEdit;
    rectTopo: TRectangle;
    Layout2: TLayout;
    Layout1: TLayout;
    btnVoltar: TSpeedButton;
    lblTitulo: TLabel;
    lvConsulta: TListView;
    layConsulta: TLayout;
    procedure btnVoltarClick(Sender: TObject);
    procedure lvConsultaItemClickEx(const Sender: TObject; ItemIndex: Integer;
      const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

    var
      retorno: String;
      qryConsulta: TFDquery;

  end;

var
  frmCnsBase: TfrmCnsBase;

implementation

uses
  uDmPrincipal;

{$R *.fmx}

procedure TfrmCnsBase.btnVoltarClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmCnsBase.FormCreate(Sender: TObject);
begin
  qryConsulta := TFDquery.Create(Owner);
  qryConsulta.Connection := dmPrincipal.conexao;
end;

procedure TfrmCnsBase.lvConsultaItemClickEx(const Sender: TObject;
  ItemIndex: Integer; const LocalClickPos: TPointF;
  const ItemObject: TListItemDrawable);
begin
  ModalResult := mrOk;
end;

end.
