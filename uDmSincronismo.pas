unit uDmSincronismo;

interface

uses
  System.SysUtils, System.Classes, uVenda, REST.Types, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, REST.Response.Adapter, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, REST.Client, Data.Bind.Components,
  Data.Bind.ObjectScope, uUtilitarios, FMX.Forms, StrUtils, Androidapi.JNI.Toast,
  JSON, REST.JSON;

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

    procedure ConfigurarREST;

      //Recebimento
    function ReceberEmpresa: Boolean;
    function ReceberCliente: Boolean;
    function ReceberProduto: Boolean;

    {TODO:
      function ReceberCliente: Boolean;
      function ReceberUsuario: Boolean;
    }

      //Envio


  public
    { Public declarations }
    property Imei: String read FImei write FImei;

    procedure ReceberDados;
    procedure EnviarDados(documento: Integer = 0);

  end;

var
  dmSincronismo: TdmSincronismo;

implementation

uses
  Loading, uDmPrincipal, uConfiguracao;

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

{ TdmSincronismo }

procedure TdmSincronismo.ConfigurarREST;
begin
  rstClient.BaseURL := 'http://' + Configuracao.Ipservidor + ':' +
                          Configuracao.portaServidor.ToString;
end;

procedure TdmSincronismo.EnviarDados(documento: Integer);
var
  Nota: TVenda;
  StringJson: String;
  qryDocumentos: TFDquery;
  json: TJsonObject;

  procedure Post;
  begin
    rstRequest.Body.ClearBody;
    rstRequest.Params.Clear;

    json := TJSONObject.Create;
    json.AddPair('IMEI', '869129022553165');

    rstRequest.Method := TRESTRequestMethod.rmPOST;
    rstRequest.Resource := 'post_NotaCController';
    //TODO: Pedir para o Rafa o EndPoint
    //TODO: Passar para o Rafa o modelo do JSON

    Log(TJson.ObjectToJsonString(Nota), '');

    rstRequest.Body.Add(json.ToString, ContentTypeFromString('application/json'));
    rstRequest.Body.Add(TJson.ObjectToJsonString(Nota), ContentTypeFromString('application/json'));
  end;

begin
  ConfigurarREST;

  try
    Nota := TVenda.Create;

    if documento = 0 then
    begin
      qryDocumentos := dmPrincipal.AcharNotaSincronizar;

      qryDocumentos.First;
      while not qryDocumentos.Eof do
      begin

        dmPrincipal.DadosDaNota(qryDocumentos.FieldByName('NR_DOCUMENTO').AsInteger, Nota);
        Post;
        Nota := nil;

        qryDocumentos.Next;
      end;
    end;
  except on E: Exception do
    Log('EnviarDados', e.Message);
  end;
end;

function TdmSincronismo.ReceberCliente: Boolean;
var
  json: TJsonObject;
begin

  rstRequest.Body.ClearBody;
  rstRequest.Params.Clear;

  json := TJSONObject.Create;
  json.AddPair('IMEI', Imei);

  rstRequest.Method := TRESTRequestMethod.rmPOST;
  rstRequest.Resource := 'post_ClienteController';
  rstRequest.Body.Add(json.ToString, ContentTypeFromString('application/json'));

  try
    rstRequest.Execute;
  except on E: Exception do
    begin
      Log('ReceberConfiguracao', 'Erro ao receber configuração : ' + e.Message);
      result := False;
    end;
  end;

  fdMemTable.Open;
  result := dmPrincipal.GravarEmpresa(fdMemTable);
end;

procedure TdmSincronismo.ReceberDados;
begin
  ConfigurarREST;

  if ReceberEmpresa then
//    ReceberProduto;
end;

function TdmSincronismo.ReceberEmpresa: Boolean;
var
  json: TJsonObject;
begin

  rstRequest.Body.ClearBody;
  rstRequest.Params.Clear;

  json := TJSONObject.Create;
  json.AddPair('IMEI', Imei);

  rstRequest.Method := TRESTRequestMethod.rmPOST;
  rstRequest.Resource := 'post_TEmpresaController';
  rstRequest.Body.Add(json.ToString, ContentTypeFromString('application/json'));

  try
    rstRequest.Execute;
  except on E: Exception do
    begin
      Log('ReceberEmpresa', 'Erro ao receber empresa : ' + e.Message);
      result := False;
    end;
  end;

  fdMemTable.Open;
  result := dmPrincipal.GravarEmpresa(fdMemTable);
end;

function TdmSincronismo.ReceberProduto: Boolean;
var
  json: TJsonObject;
begin

  rstRequest.Body.ClearBody;
  rstRequest.Params.Clear;

  json := TJSONObject.Create;
  json.AddPair('IMEI', Imei);

  rstRequest.Method := TRESTRequestMethod.rmPOST;
  rstRequest.Resource := 'post_TProdutoController';
  rstRequest.Body.Add(json.ToString, ContentTypeFromString('application/json'));

  try
    rstRequest.Execute;
  except on E: Exception do
    begin
      Log('ReceberEmpresa', 'Erro ao receber empresa : ' + e.Message);
      result := False;
    end;
  end;

  fdMemTable.Open;
  result := dmPrincipal.GravarProduto(fdMemTable); //Falta terminar implementação
end;

end.
