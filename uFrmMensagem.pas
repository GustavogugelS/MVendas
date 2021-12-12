unit uFrmMensagem;

interface
uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Layouts, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit,  FMX.Platform, FMX.VirtualKeyboard,
  FMX.Effects;

type
  TfrmMensagem = class(TForm)
    rect_fundo: TRectangle;
    img_erro: TImage;
    img_alerta: TImage;
    img_sucesso: TImage;
    img_pergunta: TImage;
    rect_msg: TRectangle;
    lblTitulo: TLabel;
    lblMsg: TLabel;
    img_icone: TImage;
    layout_botao: TLayout;
    rectConfirma: TRectangle;
    lbl_btn1: TLabel;
    rectCancela: TRectangle;
    lbl_btn2: TLabel;
    edtTexto: TEdit;
    btnConfirma: TSpeedButton;
    btnCancela: TSpeedButton;
    ShadowEffect1: TShadowEffect;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure edtTextoKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure edtTextoExit(Sender: TObject);
    procedure btnCancelaClick(Sender: TObject);
    procedure btnConfirmaClick(Sender: TObject);
    procedure edtTextoEnter(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure pPadraoPergunta;
    procedure pPadraoMsg;
    var
      retorno: Integer;
  end;

var
  frmMensagem: TfrmMensagem;

implementation

{$R *.fmx}

procedure TfrmMensagem.edtTextoEnter(Sender: TObject);
var
  KeyboardService: IFMXVirtualKeyboardService;
begin
 if TPlatformServices.Current.SupportsPlatformService(IFMXVirtualKeyboardService, IInterface(KeyboardService)) then
  KeyboardService.ShowVirtualKeyboard(edtTexto);

end;

procedure TfrmMensagem.edtTextoExit(Sender: TObject);
var
  KeyboardService: IFMXVirtualKeyboardService;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXVirtualKeyboardService, IInterface(KeyboardService)) then
    KeyboardService.HideVirtualKeyboard;
end;


procedure TfrmMensagem.edtTextoKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if key = vkReturn  then
    btnConfirmaClick(nil);
end;

procedure TfrmMensagem.FormCreate(Sender: TObject);
begin
  img_erro.Visible := false;
  img_alerta.Visible := false;
  img_sucesso.Visible := false;
  img_pergunta.Visible := false;
  edtTexto.Visible := false;
end;

procedure TfrmMensagem.FormShow(Sender: TObject);
begin
  retorno := 2;
end;

procedure TfrmMensagem.pPadraoMsg;
begin
  img_icone.Bitmap := img_alerta.Bitmap;
  rect_msg.Height := 289;
  rectConfirma.Width := 102;
  rectCancela.Width := 102;
  rectConfirma.Align := TAlignLayout.Center;
  rectCancela.Align := TAlignLayout.Right;
  rectCancela.Visible := False;

  lbl_btn1.Text := 'OK';
  lbl_btn2.Text := 'Cancelar';
  edtTexto.Visible := False;

  rectConfirma.Fill.Color := $FF31B824;
  rectCancela.Fill.Color := $FFDF5447;
end;

procedure TfrmMensagem.pPadraoPergunta;
begin
  img_icone.Bitmap := img_pergunta.Bitmap;
  rect_msg.Height := 289;
  rectConfirma.Width := 102;
  rectCancela.Width := 102;
  rectConfirma.Align := TAlignLayout.Left;
  rectCancela.Align := TAlignLayout.Right;
  rectCancela.Visible := true;

  lbl_btn1.Text := 'OK';
  lbl_btn2.Text := 'Cancelar';
  edtTexto.Visible := False;

  rectConfirma.Fill.Color := $FF31B824;
  rectCancela.Fill.Color := $FFDF5447;
end;

procedure TfrmMensagem.btnConfirmaClick(Sender: TObject);
begin
  retorno := 1;
  close;
end;

procedure TfrmMensagem.btnCancelaClick(Sender: TObject);
begin
  retorno := 2;
  close;
end;

end.
