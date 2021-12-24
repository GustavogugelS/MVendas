unit uFrmLogin;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.TabControl, FMX.Layouts, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit,
  System.Actions, FMX.ActnList, FMX.Android.Permissions;

type
  TfrmLogin = class(TForm)
    TabControl: TTabControl;
    tabLogin: TTabItem;
    layCentroLogin: TLayout;
    imgLogin: TImage;
    Layout1: TLayout;
    Layout2: TLayout;
    rectUsuario: TRectangle;
    edtUsuario: TEdit;
    StyleBook1: TStyleBook;
    rectSenha: TRectangle;
    edtSenha: TEdit;
    Layout3: TLayout;
    rectBtnEntrar: TRectangle;
    btnEntrar: TSpeedButton;
    Label1: TLabel;
    tabConfig: TTabItem;
    Layout4: TLayout;
    Layout5: TLayout;
    edtDispositivo: TEdit;
    Label2: TLabel;
    Layout6: TLayout;
    EdtIpServidor: TEdit;
    Label3: TLabel;
    Layout7: TLayout;
    edtCNPJ: TEdit;
    Label4: TLabel;
    Layout8: TLayout;
    edtPortaServidor: TEdit;
    Label5: TLabel;
    Layout9: TLayout;
    Rectangle1: TRectangle;
    btnConfirmar: TSpeedButton;
    ActionList1: TActionList;
    actTabLogin: TChangeTabAction;
    actTabConfig: TChangeTabAction;
    AndroidPermissions: TAndroidPermissions;
    procedure FormCreate(Sender: TObject);
    procedure btnEntrarClick(Sender: TObject);
    procedure btnConfirmarClick(Sender: TObject);
    procedure imgLoginClick(Sender: TObject);
  private
    { Private declarations }
    procedure pEsconderTab;
    procedure AbrirMenuPrincipal;
    procedure pSalvarConfig;
    procedure pCarregarConfig;
  public
    { Public declarations }
  end;

var
  frmLogin: TfrmLogin;

implementation

uses
  uFrmMenuPrincipal, uDmPrincipal;

{$R *.fmx}

{ TfrmLogin }

procedure TfrmLogin.btnConfirmarClick(Sender: TObject);
begin
  pSalvarConfig;
  actTabLogin.ExecuteTarget(Sender);
end;

procedure TfrmLogin.btnEntrarClick(Sender: TObject);
begin
  AbrirMenuPrincipal;
end;

procedure TfrmLogin.FormCreate(Sender: TObject);
begin
  pEsconderTab;
end;

procedure TfrmLogin.imgLoginClick(Sender: TObject);
begin
  dmPrincipal.ConfigurarPosPrinter;
end;

procedure TfrmLogin.AbrirMenuPrincipal;
begin
  if not Assigned(FrmMenuPrincipal) then
    Application.CreateForm(TfrmMenuPrincipal, frmMenuPrincipal);

  frmMenuPrincipal.Show;
end;

procedure TfrmLogin.pSalvarConfig;
begin
  if not edtDispositivo.Text.IsEmpty then
    if not edtIpServidor.Text.IsEmpty then
      if not edtCNPJ.Text.IsEmpty then
        if not edtPortaServidor.Text.IsEmpty then
        begin
          dmPrincipal.GravarConfiguracao(
            edtDispositivo.Text,
            edtIpServidor.Text,
            edtPortaServidor.Text,
            edtCNPJ.Text);
        end;
end;

procedure TfrmLogin.pCarregarConfig;
begin
  edtDispositivo.Text := configuracao.IdDispositivo.ToString;
  edtIpServidor.Text := configuracao.Ipservidor;
  edtPortaServidor.Text := configuracao.portaServidor.ToString;
  edtCNPJ.Text := empresa.Cnpj;
end;

procedure TfrmLogin.pEsconderTab;
begin
  TabControl.TabPosition := TTabPosition.none;
end;

end.
