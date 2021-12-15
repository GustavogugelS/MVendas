unit uFrmInicial;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.FMXUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.Comp.UI;

type
  TfrmInicial = class(TForm)
    layWizard: TLayout;
    laySlide1: TLayout;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    layControles: TLayout;
    lblVoltar: TLabel;
    lblProximo: TLabel;
    Layout2: TLayout;
    Layout3: TLayout;
    Circle1: TCircle;
    Circle2: TCircle;
    Circle3: TCircle;
    laySlide2: TLayout;
    Image2: TImage;
    Label3: TLabel;
    Label4: TLabel;
    laySlide3: TLayout;
    Image3: TImage;
    Label5: TLabel;
    Label6: TLabel;
    procedure lblProximoClick(Sender: TObject);
    procedure lblVoltarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure pTratarSlide(const slide: Integer);
    procedure pAbrirLogin(const temConfig: Boolean = True);
    function fTemConfiguracao: Boolean;
    { Public declarations }
  end;

var
  frmInicial: TfrmInicial;

implementation

uses
  uFrmLogin, uDmPrincipal;

{$R *.fmx}
{ TfrmInicial }

procedure TfrmInicial.FormCreate(Sender: TObject);
begin
  if fTemConfiguracao then
    pAbrirLogin;


end;

function TfrmInicial.fTemConfiguracao: Boolean;
var
  qryConfig: TFDQuery;
begin
  qryConfig := TFDQuery.Create(nil);
  try
    qryConfig.Connection := dmPrincipal.conexao;
    qryConfig.Open('SELECT DISP_ID FROM CONFIGURACAO WHERE DISP_ID > 0');
    result := not qryConfig.IsEmpty;
  finally
    qryConfig.Free;
  end;
end;

procedure TfrmInicial.lblProximoClick(Sender: TObject);
begin
  if Circle1.Fill.Color = $FF425A9A then
    pTratarSlide(2)
  else if Circle2.Fill.Color = $FF425A9A then
    pTratarSlide(3)
  else if Circle3.Fill.Color = $FF425A9A then
    pAbrirLogin(False);
end;

procedure TfrmInicial.lblVoltarClick(Sender: TObject);
begin
  if Circle3.Fill.Color = $FF425A9A then
    pTratarSlide(2)
  else if Circle2.Fill.Color = $FF425A9A then
    pTratarSlide(1);
end;

procedure TfrmInicial.pAbrirLogin(const temConfig: Boolean = True);
begin
  if Assigned(frmLogin) then
    frmLogin.Free;

  Application.CreateForm(TFrmLogin, frmLogin);
  if temConfig then
    frmLogin.actTabLogin.ExecuteTarget(nil)
  else
    frmLogin.actTabConfig.ExecuteTarget(nil);

  Application.MainForm := frmLogin;
  frmLogin.Show;
end;

procedure TfrmInicial.pTratarSlide(const slide: Integer);
begin
  laySlide1.Visible := False;
  laySlide2.Visible := False;
  laySlide3.Visible := False;
  Circle1.Fill.Color := TAlphaColorRec.Silver;
  Circle2.Fill.Color := TAlphaColorRec.Silver;
  Circle3.Fill.Color := TAlphaColorRec.Silver;
  lblVoltar.Visible := True;

  case slide of
    1:begin
      laySlide1.Visible := True;
      lblVoltar.Visible := False;
      Circle1.Fill.Color := $FF425A9A;
    end;
    2:begin
      laySlide2.Visible := True;
      Circle2.Fill.Color := $FF425A9A;
    end;
    3:begin
      laySlide3.Visible := True;
      Circle3.Fill.Color := $FF425A9A;
    end
  end;

end;

end.
