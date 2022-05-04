unit uUtilitarios;

interface

  uses
    FMX.ListView, FMX.ListView.Appearances, FMX.ListView.Types, System.SysUtils,
    FMX.VirtualKeyboard, FMX.Platform, FMX.Edit, FMX.Platform.Android, FMX.Forms,
    System.Classes, StrUtils;

  type
    TUtilitarios = class
      private

      public

    end;

    var
      util: TUtilitarios;

    procedure Log(const funcao, erro: String);
    procedure pCriardir;
    procedure pAddLista(lista: TListView; texto: String; indice: Integer = 0);
    procedure Teclado(edt: TEdit);
    procedure IniciarSincronismo(quemChamou: TForm; msg: String = 'Aguarde...');

    function CapTurarImei: String;
    function TestarCPF(cpf: string): boolean;
    function TestarCNPJ(numCNPJ: string): boolean;

implementation

uses
  System.Permissions, Androidapi.Helpers, Androidapi.JNI.Telephony,
  Androidapi.JNI.OS, uDmSincronismo, Loading, uConfiguracao, uFormat;

{ TUtilitarios }


function TestarCNPJ(numCNPJ: string): boolean;
var
  CNPJ: string;
  dg1, dg2: Integer;
  x, Total: Integer;
  ret: boolean;
begin
{$ZEROBASEDSTRINGS OFF}
  ret := false;
  CNPJ := '';

  // Analisa os formatos
  if length(numCNPJ) = 18 then
    if (copy(numCNPJ, 3, 1) + copy(numCNPJ, 7, 1) + copy(numCNPJ, 11, 1) +
      copy(numCNPJ, 16, 1) = '../-') then
    begin
      CNPJ := copy(numCNPJ, 1, 2) + copy(numCNPJ, 4, 3) + copy(numCNPJ, 8, 3) +
        copy(numCNPJ, 12, 4) + copy(numCNPJ, 17, 2);
      ret := true;
    end;
  if length(numCNPJ) = 14 then
  begin
    CNPJ := numCNPJ;
    ret := true;
  end;
  // Verifica
  if ret then
  begin
    try
      // 1° digito
      Total := 0;
      for x := 1 to 12 do
      begin
        if x < 5 then
          Inc(Total, strtoInt(copy(CNPJ, x, 1)) * (6 - x))
        else
          Inc(Total, strtoInt(copy(CNPJ, x, 1)) * (14 - x));
      end;
      dg1 := 11 - (Total mod 11);
      if dg1 > 9 then
        dg1 := 0;
      // 2° digito
      Total := 0;
      for x := 1 to 13 do
      begin
        if x < 6 then
          Inc(Total, strtoInt(copy(CNPJ, x, 1)) * (7 - x))
        else
          Inc(Total, strtoInt(copy(CNPJ, x, 1)) * (15 - x));
      end;
      dg2 := 11 - (Total mod 11);
      if dg2 > 9 then
        dg2 := 0;
      // Validação final
      if (dg1 = strtoInt(copy(CNPJ, 13, 1))) and
        (dg2 = strtoInt(copy(CNPJ, 14, 1))) then
        ret := true
      else
        ret := false;
    except
      ret := false;
    end;
    // Inválidos
    case AnsiIndexStr(CNPJ, ['00000000000000', '11111111111111',
      '22222222222222', '33333333333333', '44444444444444',

      '55555555555555', '66666666666666', '77777777777777', '88888888888888',
      '99999999999999']) of

      0 .. 9:
        ret := false;

    end;
  end;

  result := ret;
{$ZEROBASEDSTRINGS ON}
end;

function TestarCPF(cpf: string): boolean;
var
  i: Integer;
  Want: Char;
  Wvalid: boolean;
  Wdigit1, Wdigit2: Integer;
begin
{$ZEROBASEDSTRINGS OFF}
  Wdigit1 := 0;
  Wdigit2 := 0;
  Want := cpf[1];

  cpf := SomenteNumero(cpf);

  // testar se o cpf é repetido como 111.111.111-11
  for i := 1 to length(cpf) do
  begin
    if cpf[i] <> Want then
    begin
      Wvalid := true;
      // se o cpf possui um digito diferente ele passou no primeiro teste
      break
    end;
  end;
  // se o cpf é composto por numeros repetido retorna falso
  if not Wvalid then
  begin
    result := false;
    exit;
  end;

  // executa o calculo para o primeiro verificador
  for i := 1 to 9 do
  begin
    Wdigit1 := Wdigit1 + (strtoInt(cpf[10 - i]) * (i + 1));
  end;
  Wdigit1 := ((11 - (Wdigit1 mod 11)) mod 11) mod 10;
  { formula do primeiro verificador
    soma=1°*2+2°*3+3°*4.. até 9°*10
    digito1 = 11 - soma mod 11
    se digito > 10 digito1 =0
  }

  // verifica se o 1° digito confere
  if intToStr(Wdigit1) <> cpf[10] then
  begin
    result := false;
    exit;
  end;

  for i := 1 to 10 do
  begin
    Wdigit2 := Wdigit2 + (strtoInt(cpf[11 - i]) * (i + 1));
  end;
  Wdigit2 := ((11 - (Wdigit2 mod 11)) mod 11) mod 10;
  { formula do segundo verificador
    soma=1°*2+2°*3+3°*4.. até 10°*11
    digito1 = 11 - soma mod 11
    se digito > 10 digito1 =0
  }

  // confere o 2° digito verificador
  if intToStr(Wdigit2) <> cpf[11] then
  begin
    result := false;
    exit;
  end;

  // se chegar até aqui o cpf é valido
  result := true;
{$ZEROBASEDSTRINGS ON}
end;

function CapturarImei: String;
var
  TM: JTelephonyManager;
begin
  TM := TJTelephonyManager.Create;
  result := JStringToString(TM.getImei);
end;

procedure IniciarSincronismo(quemChamou: TForm; msg: String);
begin
  Application.CreateForm(TDmSincronismo, dmSincronismo);
  dmSincronismo.Imei := ConfigLocal.Imei;

  TLoading.Show(quemChamou, msg);
  TThread.CreateAnonymousThread(procedure
  begin

    dmSincronismo.ReceberDados;
//    dmSincronismo.EnviarDados;

    TThread.Synchronize(nil, procedure
    begin
      TLoading.Hide;
      dmSincronismo.Free;
    end);

  end).Start;
end;

procedure Teclado(edt: TEdit);
var
  VKbSvc: IFMXVirtualKeyboardService;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXVirtualKeyboardService, VKbSvc) then
  begin
    VKbSvc.ShowVirtualKeyboard(edt);
  end;
end;

procedure pCriarDir;
begin
  ForceDirectories('/mnt/sdcard/android/data/com.embarcadero.MVendas/logs');
end;

procedure pAddLista(lista: TListView; texto: String;
  indice: Integer);
var
  item: TListViewItem;
  txt: TListItemText;
begin
  item := lista.Items.Add;
  with item do
  begin
   //Index
    txt := TlistItemText(Objects.FindDrawable('Text1'));
    txt.Text := indice.ToString;
    txt.TagString := txt.Text;

    //Texto
    txt := TlistItemText(Objects.FindDrawable('Text2'));
    txt.Text := AnsiUpperCase(texto);
    txt.TagString := txt.Text;
  end;
end;

procedure Log(const funcao, erro: String);
var
  dir: String;
  arq: TextFile;
begin
  dir := '/mnt/sdcard/android/data/com.embarcadero.MVendas/logs/' + FormatDateTime('DDMMAA', Now) + '.txt';

  AssignFile(arq, dir);

  if FileExists(dir) then
    Append(arq) { se existir, apenas adiciona linhas }
  else
    ReWrite(arq); { cria um novo se não existir }

  try
    WriteLn(arq, DateTimeToStr(Now) + ' > ' + funcao + ' : ' + erro);
    WriteLn(arq, '-------------');

  finally
    CloseFile(arq)
  end;
end;

end.
