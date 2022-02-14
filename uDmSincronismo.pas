unit uDmSincronismo;

interface

uses
  System.SysUtils, System.Classes, uVenda, REST.Types, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, REST.Response.Adapter, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, REST.Client, Data.Bind.Components,
  Data.Bind.ObjectScope, uUtilitarios, FMX.Forms, StrUtils, Androidapi.JNI.Toast;

type
  TdmSincronismo = class(TDataModule)
    rstClient: TRESTClient;
    rstRequest: TRESTRequest;
    rstResponse: TRESTResponse;
    fdMemTable: TFDMemTable;
    rstAdapter: TRESTResponseDataSetAdapter;
  private
    { Private declarations }
    FImei: String;

    function ReceberConfiguracao: Boolean;
    function ReceberEmpresa: Boolean;

  public
    { Public declarations }
    property Imei: String read FImei write FImei;

    procedure ReceberDados(formChamou: TForm; msg: String = '');

//    function EnviarVenda: Boolean;
//    function ReceberProduto: Boolean;
//    function ReceberCliente: Boolean;
//    function ReceberUsuario: Boolean;

  end;

var
  dmSincronismo: TdmSincronismo;

implementation

uses
  Loading, uDmPrincipal;

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

{ TdmSincronismo }

function TdmSincronismo.ReceberConfiguracao: Boolean;
begin
  rstRequest.Resource := 'get_TEmpresaController\' + imei;

  try
    rstRequest.Execute;
  except on E: Exception do
    begin
      Log('ReceberConfiguracao', 'Erro ao receber configuração : ' + e.Message);
      result := False;
    end;
  end;

  fdMemTable.Open;
  //GravarCofniguracao;

end;

procedure TdmSincronismo.ReceberDados(formChamou: TForm; msg: String);
begin
  //Aqui vai acontecer o recebimento da carga(Atualização)
  msg := Ifthen(msg = '', 'Aguarde', msg);

  Tloading.Show(formChamou, msg);
  TThread.CreateAnonymousThread(procedure
  begin
    ReceberEmpresa;

    TThread.Synchronize(nil, procedure
    begin
      Toast('Configuração concluída');
      TLoading.Hide;
    end);

  end).Start;
end;

function TdmSincronismo.ReceberEmpresa: Boolean;
begin
  rstRequest.Resource := 'get_TEmpresaController';
  rstRequest.AddParameter('IMEI', ''

  try
    rstRequest.Execute;
  except on E: Exception do
    begin
      Log('ReceberConfiguracao', 'Erro ao receber configuração : ' + e.Message);
      Log('Retorno', ':' + rstResponse.Content);
    end;
  end;

  fdMemTable.Open;
  result := dmPrincipal.GravarEmpresa(fdMemTable);
end;

end.
