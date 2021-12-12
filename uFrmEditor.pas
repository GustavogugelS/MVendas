unit uFrmEditor;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Layouts, FMX.Objects, FMX.Edit;

type
  TfrmEditor = class(TForm)
    rectTopo: TRectangle;
    Layout2: TLayout;
    Layout1: TLayout;
    btnVoltar: TSpeedButton;
    lblTitulo: TLabel;
    btnAplicar: TSpeedButton;
    Layout3: TLayout;
    rectEdit: TRectangle;
    edtTexto: TEdit;
    procedure btnVoltarClick(Sender: TObject);
    procedure btnAplicarClick(Sender: TObject);
    procedure edtTextoKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }

    var
      indCampoObrigatorio: Boolean;
      texto: String;
  end;

var
  frmEditor: TfrmEditor;

implementation

{$R *.fmx}

procedure TfrmEditor.btnAplicarClick(Sender: TObject);
begin
  texto := edtTexto.Text;
  ModalResult := mrOk;
end;

procedure TfrmEditor.btnVoltarClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmEditor.edtTextoKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if edtTexto.KeyboardType = TVirtualKeyboardType.DecimalNumberPad then
  begin
    edtTexto.Text := FormatFloat('0.00',
                      StrToFloatDef(StringReplace(edtTexto.Text, '.', '', [rfReplaceAll]), 0) / 100);
  end;
end;

end.
