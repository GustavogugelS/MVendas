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
    fdMemTable: TFDMemTable;
    rstAdapter: TRESTResponseDataSetAdapter;
    rstRequest: TRESTRequest;
    rstResponse: TRESTResponse;
  private
    { Private declarations }
    FImei: String;
    FImeiJson: String;

    procedure ConfigurarREST;

    function ReceberEmpresa: Boolean; {Receber}
    function ReceberCliente: Boolean; {Receber}
    function ReceberProduto: Boolean; {Receber}
    function ReceberUsuario: Boolean; {Receber}

    procedure SetImei(const Value: String);

  public
    { Public declarations }
    property Imei: String read FImei write SetImei;
    property ImeiJson: String read FImeiJson write FImeiJson;


    function ReceberDados: Boolean;
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

    with rstRequest.Params.AddItem do
    begin
      ContentType := ctAPPLICATION_JSON;
      name        := 'body';
      Value       := ImeiJson;
      Kind        := pkREQUESTBODY;
    end;

    rstRequest.Method := TRESTRequestMethod.rmPOST;
    rstRequest.Resource := 'post_NotaCController';
    //TODO: Pedir para o Rafa o EndPoint
    //TODO: Passar para o Rafa o modelo do JSON

    Log(TJson.ObjectToJsonString(Nota), '');

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

  with rstRequest.Params.AddItem do
  begin
    ContentType := ctAPPLICATION_JSON;
    name        := 'body';
    Value       := ImeiJson;
    Kind        := pkREQUESTBODY;
  end;

  rstRequest.Method := TRESTRequestMethod.rmPOST;
  rstRequest.Resource := 'post_TPessoaController';

  try
    rstRequest.Execute;
    Log(rstResponse.Content, '');

  except on E: Exception do
    begin
      Log('ReceberPessoa', 'Erro ao receber pessoa : ' + e.Message);
      result := False;
    end;
  end;

  fdMemTable.Open;
  result := dmPrincipal.GravarCliente(fdMemTable);
end;

function TdmSincronismo.ReceberDados: Boolean;
begin
  result := false;
  ConfigurarREST;

  if ReceberEmpresa then
    if ReceberUsuario then
      if ReceberProduto then
        if ReceberCliente then
          result := true;

end;

function TdmSincronismo.ReceberEmpresa: Boolean;
begin
  fdMemTable.Close;
  rstRequest.Body.ClearBody;
  rstRequest.Params.Clear;

  with rstRequest.Params.AddItem do
  begin
    ContentType := ctAPPLICATION_JSON;
    name        := 'body';
    Value       := ImeiJson;
    Kind        := pkREQUESTBODY;
  end;

  rstRequest.Method := TRESTRequestMethod.rmPOST;
  rstRequest.Resource := 'post_TEmpresaController';

  try
    rstRequest.Execute;

  except on E: Exception do
    begin
      Log('ReceberEmpresa', 'Erro ao receber empresa : ' + e.Message);
      result := False;
      Exit;
    end;
  end;

  fdMemTable.Open;
  result := dmPrincipal.GravarEmpresa(fdMemTable);
end;

function TdmSincronismo.ReceberProduto: Boolean;
begin
  fdMemTable.Close;
  rstRequest.Body.ClearBody;
  rstRequest.Params.Clear;

  with rstRequest.Params.AddItem do
  begin
    ContentType := ctAPPLICATION_JSON;
    name        := 'body';
    Value       := ImeiJson;
    Kind        := pkREQUESTBODY;
  end;

  rstRequest.Method := TRESTRequestMethod.rmPOST;
  rstRequest.Resource := 'post_TProdutoController';

  try

    rstRequest.Execute;

    Log(rstResponse.StatusCode.ToString, rstResponse.StatusText);

    if rstResponse.StatusCode <> 200 then
      raise Exception.Create('IMEI Não encontrado');

  except on E: Exception do
    begin
      Log('ReceberProduto', 'Erro ao receber produto : ' + e.Message);
      result := False;
      Exit;
    end;
  end;

  fdMemTable.Open;
  result := dmPrincipal.GravarProduto(fdMemTable);
end;

function TdmSincronismo.ReceberUsuario: Boolean;
begin
  fdMemTable.Close;
  rstRequest.Body.ClearBody;
  rstRequest.Params.Clear;

  with rstRequest.Params.AddItem do
  begin
    ContentType := ctAPPLICATION_JSON;
    name        := 'body';
    Value       := ImeiJson;
    Kind        := pkREQUESTBODY;
  end;

  rstRequest.Method := TRESTRequestMethod.rmPOST;
  rstRequest.Resource := 'post_TUsuarioController';

  try

    rstRequest.Execute;

  except on E: Exception do
    begin
      Log('ReceberUsuario', 'Erro ao receber usuario : ' + e.Message);
      result := False;
      Log(rstResponse.StatusCode.ToString, rstResponse.StatusText);
      Exit;
    end;
  end;

  fdMemTable.Open;
  result := dmPrincipal.GravarUsuario(fdMemTable);
end;

procedure TdmSincronismo.SetImei(const Value: String);
var
  json: TJSONObject;
begin
  json := TJSONObject.Create;
  json.AddPair('IMEI', Value);

  FImei := Value;
  ImeiJson := json.ToString;
end;

end.
