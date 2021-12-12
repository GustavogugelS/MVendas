unit uAuthentication;


interface

uses
  system.sysUtils,
  Mvcframework.commons,
  system.generics.collections,
  mvcFramework,
  mvcframework.logger;
type
  TAPIAuthentication = class(TInterfacedObject, IMVCAuthenticationHandler)
    protected
     procedure OnRequest(const AContext: TWebContext; const AControllerQualifiedClassName, AActionName: string;
          var AAuthenticationRequired: Boolean);
     procedure OnAuthentication(const AContext: TWebContext; const AUserName, APassword: string;
          AUserRoles: TList<string>; var AIsValid: Boolean; const ASessionData: TDictionary<string, string>);
     procedure OnAuthorization(const AContext: TWebContext; AUserRoles: TList<string>;
          const AControllerQualifiedClassName: string; const AActionName: string; var AIsAuthorized: Boolean);
  end;

implementation

{ TAPIAuthentication }

procedure TAPIAuthentication.OnAuthentication(const AContext: TWebContext;
  const AUserName, APassword: string; AUserRoles: TList<string>;
  var AIsValid: Boolean; const ASessionData: TDictionary<string, string>);
begin
  AIsValid := AUserName.Contains('user') and APassword.Contains('123');

  if AIsValid then
  begin
    if AUserName.Contains('admin') then
      AUserRoles.Add('regra1')
    else
      AUserRoles.Clear;




  end;

end;

procedure TAPIAuthentication.OnAuthorization(const AContext: TWebContext;
  AUserRoles: TList<string>; const AControllerQualifiedClassName,
  AActionName: string; var AIsAuthorized: Boolean);
begin

  AIsAuthorized := true;

end;

procedure TAPIAuthentication.OnRequest(const AContext: TWebContext;
  const AControllerQualifiedClassName, AActionName: string;
  var AAuthenticationRequired: Boolean);
begin

  AAuthenticationRequired := not AControllerQualifiedClassName.Contains('API');

end;

end.
