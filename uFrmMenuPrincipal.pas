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
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure Layout5Click(Sender: TObject);
  private
    { Private declarations }
    procedure pAbrirPDV;
    procedure SairMenuPrincipal;
    procedure IniciarSincronismo;
  public
    { Public declarations }
  end;

var
  frmMenuPrincipal: TfrmMenuPrincipal;

implementation

uses
  uFrmVendas, uDmNfe, Loading, uFrmLogin, uDmSincronismo;

{$R *.fmx}

procedure TfrmMenuPrincipal.FormKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if key = vkHardwareBack then
  begin           
        
  end;
end;

procedure TfrmMenuPrincipal.IniciarSincronismo;
begin
  //TODO: Capturar IMEI do aparelho
  Application.CreateForm(TDmSincronismo, dmSincronismo);
  dmSincronismo.Imei := '869129022553165';

  TLoading.Show(self, 'Enviando/Recebendo');
  TThread.CreateAnonymousThread(procedure
  begin

    dmSincronismo.ReceberDados;
//    dmSincronismo.EnviarDados(frmMenuPrincipal);

    TThread.Synchronize(nil, procedure
    begin
      TLoading.Hide;
      dmSincronismo.Free;
    end);

  end).Start;
end;

procedure TfrmMenuPrincipal.Layout3Click(Sender: TObject);
begin
  pAbrirPDV;
end;

procedure TfrmMenuPrincipal.Layout4Click(Sender: TObject);
begin
//  ShowMessage('Válido até: '+ FormatDateBr(dmNfe.ACBrNFe.SSL.CertDataVenc));
  ShowMessage('Funcionalidade indisponível');
end;

procedure TfrmMenuPrincipal.Layout5Click(Sender: TObject);
begin
  IniciarSincronismo;
end;

procedure TfrmMenuPrincipal.pAbrirPDV;
var
  frmVendas: TfrmVendas;
begin
  if not Assigned(dmNfe) then
    Application.CreateForm(TdmNfe, dmNfe);

  if Assigned(frmVendas) then
    frmVendas.Free;

  Application.CreateForm(TfrmVendas, frmVendas);
  frmVendas.Show;
end;

procedure TfrmMenuPrincipal.SairMenuPrincipal;
begin
  if not Assigned(frmLogin) then
    Application.CreateForm(TFrmLogin, frmLogin);

  frmLogin.Show;
end;

end.
