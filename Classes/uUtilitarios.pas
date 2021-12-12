unit uUtilitarios;

interface
  uses
    FMX.ListView, FMX.ListView.Appearances, FMX.ListView.Types, System.SysUtils,
    FMX.VirtualKeyboard, FMX.Platform, FMX.Edit;

  type
    TUtilitarios = class
      private

      public

    end;

    var
      util: TUtilitarios;

    procedure pLog(const funcao, erro: String);
    procedure pCriardir;
    procedure pAddLista(lista: TListView; texto: String; indice: Integer = 0);
    procedure Teclado(edt: TEdit);

implementation

{ TUtilitarios }

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

procedure pLog(const funcao, erro: String);
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
