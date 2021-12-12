unit UNFCeWebModulle;

interface

uses
  System.SysUtils,
  System.Classes,
  Web.HTTPApp,
  FireDAC.DApt,
  MVCFramework.Server,
  MVCFramework.Server.Impl,
  AuthHandlerU,
  MVCFramework,
  System.dateUtils,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait, Data.DB,
  FireDAC.Comp.Client, FireDAC.Phys.FBDef, FireDAC.Phys.IBBase, FireDAC.Phys.FB,
  FireDAC.Phys.PG, FireDAC.Phys.PGDef, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  Generics.Collections;

type
  TNFCEWebModule = class(TWebModule)
    ConnSQLite: TFDConnection;
    FDPhysPgDriverLink1: TFDPhysPgDriverLink;
    procedure WebModuleCreate(Sender: TObject);
    procedure WebModuleDestroy(Sender: TObject);
    procedure WebModuleException(Sender: TObject; E: Exception;
      var Handled: Boolean);
  private
    FMVC: TMVCEngine;
    procedure pConfigurarBanco;
  public
    { Public declarations }
  end;

var
  WebModuleClass: TComponentClass = TNFCEWebModule;

const
  CONEXAO_PG = 'CONEXAO_SERVIDOR_DMC';

implementation

{$R *.dfm}

uses
  UNFCeController,
  UConfigClass,
  System.IOUtils,

  MVCFramework.Commons,
  MVCFramework.Middleware.JWT,
  MVCFramework.JWT,
  MVCFramework.Middleware.Compression,
  MVCFramework.Middleware.CORS,
  MVCFramework.Middleware.Authentication;

procedure TNFCEWebModule.pConfigurarBanco;
var
  oParametros: TStringList;
begin
  FDManager.Close;
  oParametros := TStringList.Create;
  try
    oParametros.Clear;
    oParametros.Add('DriverID=PG');
    oParametros.Add('User_Name=postgres');
    oParametros.Add('Password=postgres');
    oParametros.Add('Protocol=TCPIP');
    oParametros.Add('CharacterSet=WIN1252');
    oParametros.Add('Server='   + ConfigServer.IP);
    oParametros.Add('Port='     + ConfigServer.Porta.ToString);
    oParametros.Add('Database=' + ConfigServer.Path);

    {parametros para o controle do pool se necessário e quiser alterar}
//    oParametros.Add('POOL_MaximumItems=50');
//    oParametros.Add('POOL_ExpireTimeout=9000');
//    oParametros.Add('POOL_CleanupTimeout=900000');

    FDManager.AddConnectionDef(CONEXAO_PG, 'PG', oParametros);
    FDManager.Open;
  finally
    oParametros.Free;
  end;
end;

procedure TNFCEWebModule.WebModuleCreate(Sender: TObject);
var
  lClaimsSetup: TJWTClaimsSetup;
begin
  pConfigurarBanco;

  lClaimsSetup :=
    procedure (const JWT:TJWT)
    begin
      JWT.Claims.Issuer := 'API';
      JWT.Claims.ExpirationTime := NOW+ OneHour;
      JWT.Claims.NotBefore := NOW -OneMinute *5;
      JWT.Claims.IssuedAt := NOW;
      JWT.CustomClaims['mycustomvalue']  := 'TESTE API';
    end;


  FMVC := TMVCEngine.Create(Self,
    procedure(Config: TMVCConfig)
    begin
      // session timeout (0 means session cookie)
      Config[TMVCConfigKey.SessionTimeout] := '0';
      //default content-type
      Config[TMVCConfigKey.DefaultContentType] := TMVCConstants.DEFAULT_CONTENT_TYPE;
      //default content charset
      Config[TMVCConfigKey.DefaultContentCharset] := TMVCConstants.DEFAULT_CONTENT_CHARSET;
      //unhandled actions are permitted?
      Config[TMVCConfigKey.AllowUnhandledAction] := 'false';
      //default view file extension
      Config[TMVCConfigKey.DefaultViewFileExtension] := 'html';
      //view path
      Config[TMVCConfigKey.ViewPath] := 'templates';
      //Max Record Count for automatic Entities CRUD
      Config[TMVCConfigKey.MaxEntitiesRecordCount] := '20';
      //Enable Server Signature in response
      Config[TMVCConfigKey.ExposeServerSignature] := 'false';
      // Max request size in bytes
      Config[TMVCConfigKey.MaxRequestSize] := IntToStr(TMVCConstants.DEFAULT_MAX_REQUEST_SIZE);
    end);

  FMVC.AddController(TNFCeController);

  // To enable compression (deflate, gzip) just add this middleware as the last one
  FMVC.AddMiddleware(TMVCCompressionMiddleware.Create);

  FMVC.AddMiddleware(
    TMVCCustomAuthenticationMiddleware.Create( TCustomAuth.Create, '/system/users/logged'));
end;

procedure TNFCEWebModule.WebModuleDestroy(Sender: TObject);
begin
  FMVC.Free;
end;

procedure TNFCEWebModule.WebModuleException(Sender: TObject; E: Exception;
  var Handled: Boolean);
begin
  writeln('erro'+e.Message);
end;

end.

