unit uDmSincronismo;

interface

uses
  System.SysUtils, System.Classes, uVenda;

type
  TdmSincronismo = class(TDataModule)
  private
    { Private declarations }
  public
    { Public declarations }
    function EnviarVenda: Boolean;
    function ReceberProduto: Boolean;
//    function ReceberCliente: Boolean;
//    function ReceberUsuario: Boolean;

  end;

var
  dmSincronismo: TdmSincronismo;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

function TdmSincronismo.EnviarVenda: Boolean;
var
  venda: TVenda;
begin
  venda := TVenda.Create;
  {TODO: Terminar assim que o rafa passar o server}
end;

end.
