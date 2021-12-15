unit Loading;

interface

uses System.SysUtils, System.UITypes, FMX.Types, FMX.Controls, FMX.StdCtrls,
     FMX.Objects, FMX.Effects, FMX.Layouts, FMX.Forms, FMX.Graphics, FMX.Ani,
     FMX.VirtualKeyboard, FMX.Platform;

type
  TLoading = class
  private
    class var Layout : TLayout;
    class var Fundo : TRectangle;
    class var Centro : TRectangle;
    class var Mensagem : TLabel;
    class var Indicator: TAniIndicator;
  public
    class procedure Show(const Frm : Tform; const msg : string);
    class procedure Hide;
  end;

implementation

{ TLoading }


class procedure TLoading.Hide;
begin
  if Assigned(Layout) then
  begin

    try
      if Assigned(Mensagem) then
        Mensagem.DisposeOf;

      if Assigned(Fundo) then
        Fundo.DisposeOf;

      if Assigned(Layout) then
        Layout.DisposeOf;

      if Assigned(Centro) then
        Centro.DisposeOf;

      if Assigned(Indicator) then
        Indicator.DisposeOf;
    except

    end;
  end;

  Mensagem := nil;
  Layout := nil;
  Centro := nil;
  Fundo := nil;
  Indicator := nil;
end;

class procedure TLoading.Show(const Frm : Tform; const msg: string);
var
  FService: IFMXVirtualKeyboardService;
begin
  // Panel de fundo opaco...
  Fundo := TRectangle.Create(Frm);
  Fundo.Opacity := 0;
  Fundo.Parent := Frm;
  Fundo.Visible := true;
  Fundo.Align := TAlignLayout.Contents;
  Fundo.Fill.Color := TAlphaColorRec.Black;
  Fundo.Fill.Kind := TBrushKind.Solid;
  Fundo.Stroke.Kind := TBrushKind.None;
  Fundo.Visible := true;

  // Layout contendo o texto e o arco...
  Layout := TLayout.Create(Frm);
  Layout.Opacity := 0;
  Layout.Parent := Frm;
  Layout.Visible := true;
  Layout.Align := TAlignLayout.Contents;
  Layout.Width := 250;
  Layout.Height := 78;
  Layout.Visible := true;

  // Caixa do meio
  Centro := TRectangle.Create(frm);
  Centro.Opacity := 1;
  Centro.Parent := Frm;
  Centro.Fill.Color := $FFFCFEFF;
  Centro.Visible := true;
  Centro.Align := TAlignLayout.Center;
  Centro.Position.X := (TForm(Application.MainForm).ClientWidth - Centro.Width) / 2;
  Centro.Position.Y := (TForm(Application.MainForm).ClientHeight - Centro.Height) / 2;
  Centro.Width := 209;
  Centro.Height := 81;
  Centro.Stroke.Kind := TBrushKind.None;
  Centro.XRadius := 5;
  Centro.YRadius := 5;
  Centro.Visible := true;

  //Indicator
  Indicator := TAniIndicator.Create(Frm);
  Indicator.Visible := False;
  Indicator.Enabled := False;
  Indicator.Parent := Centro;
  Indicator.Margins.Right := 10;
  Indicator.Align := TAlignLayout.MostRight;
  Indicator.Enabled := True;
  Indicator.Visible := True;
  Indicator.Parent := Centro;

  // Label do texto...
  Mensagem := TLabel.Create(Frm);
  Mensagem.TextSettings.Font.Family := 'SegoeUI';
  Mensagem.Parent := Centro;
  Mensagem.Align := TAlignLayout.MostLeft;
  Mensagem.Margins.Left := 10;
  Mensagem.Margins.Top := 30;
  Mensagem.Font.Size := 16;
  Mensagem.Height := 70;
  Mensagem.Width := Centro.Width - 100;
  Mensagem.FontColor := $FF2D61CC;
  Mensagem.TextSettings.VertAlign := TTextAlign.Leading;
  Mensagem.StyledSettings := [TStyledSetting.Family, TStyledSetting.Style];
  Mensagem.Text := msg;
  Mensagem.VertTextAlign := TTextAlign.Leading;
  Mensagem.Trimming := TTextTrimming.None;
  Mensagem.TabStop := false;
  Mensagem.SetFocus;

  // Exibe os controles...
  Fundo.AnimateFloat('Opacity', 0.7);
  Layout.AnimateFloat('Opacity', 1);
  Layout.BringToFront;

  // Esconde o teclado virtual...
  TPlatformServices.Current.SupportsPlatformService(IFMXVirtualKeyboardService,
                                                    IInterface(FService));
  if (FService <> nil) then
  begin
    FService.HideVirtualKeyboard;
  end;
  FService := nil;
end;


end.
