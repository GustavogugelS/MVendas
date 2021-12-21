unit uFrmLeitorBarcode;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Android.Permissions, FMX.CodeReader, FMX.Controls.Presentation,
  FMX.StdCtrls;

type
  TfrmLeitorBarcode = class(TForm)
    CodeReader: TCodeReader;
    AndroidPermissions: TAndroidPermissions;
    procedure CodeReaderCodeReady(aCode: string);
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

  var
    retorno: String;

  end;

var
  frmLeitorBarcode: TfrmLeitorBarcode;

implementation

{$R *.fmx}

procedure TfrmLeitorBarcode.CodeReaderCodeReady(aCode: string);
begin
  retorno := aCode;
  CodeReader.Stop;
  ModalResult := mrOk;
end;

procedure TfrmLeitorBarcode.FormCreate(Sender: TObject);
begin
  CodeReader.Opacity := 0.7;
end;

procedure TfrmLeitorBarcode.SpeedButton1Click(Sender: TObject);
begin
  CodeReader.Start;
end;

end.
