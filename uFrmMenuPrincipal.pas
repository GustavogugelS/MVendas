unit uFrmMenuPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.MultiView, FMX.Layouts, FMX.Objects,
  FMX.StdCtrls, AcbrUtil;

type
  TfrmMenuPrincipal = class(TForm)
    mvMenuPrincipal: TMultiView;
    rectTopo: TRectangle;
    Layout1: TLayout;
    btnLateral: TSpeedButton;
    StyleBook1: TStyleBook;
    Layout2: TLayout;
    Layout3: TLayout;
    Layout4: TLayout;
    Image1: TImage;
    Label2: TLabel;
    Image2: TImage;
    Label1: TLabel;
    GridPanelLayout1: TGridPanelLayout;
    Layout5: TLayout;
    Image3: TImage;
    Label3: TLabel;
    procedure Layout3Click(Sender: TObject);
    procedure Layout4Click(Sender: TObject);
  private
    { Private declarations }
    procedure pAbrirPDV;
  public
    { Public declarations }
  end;

var
  frmMenuPrincipal: TfrmMenuPrincipal;

implementation

uses
  uFrmVendas, uDmNfe, Loading;

{$R *.fmx}

procedure TfrmMenuPrincipal.Layout3Click(Sender: TObject);
begin
//  dmNfe.ACBrNFe.WebServices.StatusServico.Executar;
//  ShowMessage(IntToStr(dmNfe.ACBrNFe.WebServices.StatusServico.cStat));
//  pAbrirPDV;
  TLoading.Show(Self, 'Carregando');
end;

procedure TfrmMenuPrincipal.Layout4Click(Sender: TObject);
begin
  ShowMessage('Válido até: '+ FormatDateBr(dmNfe.ACBrNFe.SSL.CertDataVenc));
end;

procedure TfrmMenuPrincipal.pAbrirPDV;
var
  frmVendas: TfrmVendas;
begin
  frmVendas := TFrmVendas.Create(self);
  frmVendas.Show;
end;

end.
