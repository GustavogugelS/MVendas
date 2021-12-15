unit uDmPrincipal;

interface

uses
  System.SysUtils, System.IoUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.FMXUI.Wait,
  Data.DB, FireDAC.Comp.Client, uConfiguracao,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.Comp.UI, uFrmVendas, UNFCeClass,
  MVCFramework.RESTClient, System.JSON, ACBrBase, ACBrDFeReport,
  ACBrDFeDANFeReport, ACBrNFeDANFEClass, ACBrNFeDANFeESCPOS, ACBrPosPrinter,
  ACBrPosPrinterGEDI;

type

  TdmPrincipal = class(TDataModule)
    conexao: TFDConnection;
    qryProduto: TFDQuery;
    qryNotaC: TFDQuery;
    qryNotaI: TFDQuery;
    qrySequencia: TFDQuery;
    qryTotalCupom: TFDQuery;
    qryPagamento: TFDQuery;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    qryNotas: TFDQuery;
    qryCaixa: TFDQuery;
    qryCaixaMov: TFDQuery;
    AcbrEscPos: TACBrNFeDANFeESCPOS;
    AcbrPosPrinter: TACBrPosPrinter;
    procedure DataModuleCreate(Sender: TObject);
    procedure conexaoBeforeConnect(Sender: TObject);

  private
    { Private declarations }
    fGEDIPrinter: TACBrPosPrinterGEDI;
  public
    { Public declarations }
    function fConectarBanco: Boolean;
    function fCarregarConfiguracao: Boolean;
    function fCarregarDadosEmpresa: Boolean;
    function fAchaNrNota: Integer;
    function fAchaNrSequencia(const nrDocumento: Integer; const tabela: String): Integer;
    function fAchaNrDocumento: Integer;
    function fBuscarProduto(const cdBarras: String): TProdutoCupom;
    function DadosDaNota(const nrDocumento: Integer; var Nota: TNFCe): Boolean;
    function fEmitirNota: Boolean;
    function fCancelarNota(const nrDocumento: Integer): Boolean;
    function fDocumentoAberto: Integer;
    function fCalcularTotaisCupom: Boolean;
    function fControleCaixa(const tipo: Integer): Boolean;
    function fGravarCaixaMov(const tipo: String; const cdFinalizadora: Integer; const valor: Currency): Boolean;
    function fMarcarFavorito(tabela, where, chave: String; favorito: Integer): Boolean;

    procedure GravarConfiguracao(disp, ipServidor, portaServidor, Cnpj: String);
    procedure pDeletarVendaBanco;
    procedure pDeletarItemBanco(const sequencia: Integer);
    procedure pDeletarPagBanco;
    procedure pRatearDescontoItem(const vlDesconto: Currency);
    procedure pLimparDesconto;
    procedure AtualizarStatusNota(const tipo: Integer = 0);
    procedure pCalcularImposto;
    procedure pCarregarDadosAut;
    procedure pCarregarDadosCliente;
    procedure ConfigurarPosPrinter;
    procedure RelGerencial;

    {Funções de dincronismo}
    function EnviarVenda: Boolean;
    function ReceberProduto: Boolean;
//    function ReceberCliente: Boolean;
//    function ReceberUsuario: Boolean;
  end;

var
  dmPrincipal: TdmPrincipal;
  configuracao: TConfiguracao;
  configLocal: TConfiguracaoLocal;
  empresa: TEmpresa;
  caixa: TCaixa;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

uses
  uUtilitarios, uDmNfe, uImpressao;

{$R *.dfm}

{ TdmPrincipal }

procedure TdmPrincipal.conexaoBeforeConnect(Sender: TObject);
begin
  fConectarBanco;
end;

procedure TdmPrincipal.ConfigurarPosPrinter;
begin
  fGEDIPrinter := TACBrPosPrinterGEDI.Create(AcbrPosPrinter);
  AcbrPosPrinter.ModeloExterno := fGEDIPrinter;

  ACBrPosPrinter.ColunasFonteNormal := 32;
  ACBrPosPrinter.EspacoEntreLinhas := 0;
  ACBrPosPrinter.LinhasEntreCupons := 6;
  ACBrPosPrinter.ControlePorta := True;

  ACBrPosPrinter.ConfigQRCode.LarguraModulo := 3;
  ACBrPosPrinter.ConfigQRCode.Tipo := 2;

  AcbrPosPrinter.Ativar;
end;

procedure TdmPrincipal.DataModuleCreate(Sender: TObject);
begin
  pCriarDir;
  empresa := TEmpresa.Create;
  configuracao := TConfiguracao.Create;
  configLocal := TConfiguracaoLocal.Create;
  caixa := TCaixa.Create;
  fCarregarDadosEmpresa;
  fCarregarConfiguracao;
  ConfigurarPosPrinter;
end;

function TdmPrincipal.fAchaNrDocumento: Integer;
var
  qryDocumento: TFDquery;
begin
  try
    qryDocumento := TFDquery.Create(nil);
    qryDocumento.Connection := conexao;
    qryDocumento.Open('SELECT MAX(NR_DOCUMENTO) NR_DOCUMENTO FROM NOTAC');
    result := qryDocumento.FieldByName('NR_DOCUMENTO').AsInteger;
  finally
    qryDocumento.Free;
  end;
end;

function TdmPrincipal.fAchaNrNota: Integer;
var
  qryNrNF: TFDquery;
begin
  try
    qryNrNF := TFDQuery.Create(nil);
    qryNrNF.Connection := conexao;
    qryNrNF.SQL.Text := 'SELECT ' +
                        '    COALESCE(MAX(NR_NOTA), 0) + 1  AS NR_NOTA ' +
                        'FROM ' +
                        '    NOTAC ' +
                        'WHERE ' +
                        '    NOTAC.NR_SERIE = :NR_SERIE';

    try
      qryNrNf.ParamByName('NR_SERIE').AsInteger := configuracao.Serie;
      qryNrNf.Open;
      result := qryNrNf.FieldByName('NR_NOTA').AsInteger;
    except on E: Exception do
      pLog('Erro ao buscar numero de nota : ', E.Message);
    end;
  finally
    qryNrNF.Free;
  end;
end;

function TdmPrincipal.fAchaNrSequencia(const nrDocumento: Integer;
  const tabela: String): Integer;
begin

  qrySequencia.Close;
  qrySequencia.SQL.Clear;
  qrySequencia.Open(' SELECT ' +
                    '     COALESCE(MAX(NR_SEQUENCIA), 0) + 1 AS PROX_SEQUENCIA ' +
                    ' FROM ' +
                          tabela +
                    ' WHERE ' +
                    '     NR_DOCUMENTO = ' + nrDocumento.ToString);

  result := qrySequencia.FieldByName('PROX_SEQUENCIA').AsInteger;
  qrySequencia.Close;
end;

function TdmPrincipal.fBuscarProduto(const cdBarras: String): TProdutoCupom;
begin
  try
    qryProduto.Close;
    qryProduto.ParamByName('CD_BARRAS').AsString := cdBarras;
    qryProduto.Open;

    if qryProduto.IsEmpty then
      Exit;

    result.cdProduto := qryProduto.FieldByName('CD_PRODUTO').AsString;
    result.cdBarras := cdBarras;
    result.descricao := qryProduto.FieldByName('DESCRICAO').AsString;
    result.preco := qryProduto.FieldByName('PRECO').AsCurrency;
    result.cst := qryProduto.FieldByName('CST_ICMS').AsString;
    result.un := qryProduto.FieldByName('UN').AsString;
    result.ncm := qryProduto.FieldByName('NCM').AsString;
    result.cest := qryProduto.FieldByName('CEST').AsString;
    result.cstPisCofins := qryProduto.FieldByName('CST_PISCOFINS').AsString;
    result.ntReceita := qryProduto.FieldByName('NATUREZA_RECEITA').AsString;
    result.pesoL := qryProduto.FieldByName('PESO_LIQUIDO').AsFloat;
    result.gtin := qryProduto.FieldByName('GTIN').AsString;
    result.AliqIcms := qryProduto.FieldByName('ALIQ').AsFloat;
    result.pcReducao := qryProduto.FieldByName('PC_REDUCAO').AsCurrency;

    if result.cst = '000' then
      result.cfop := configuracao.CFOP
    else
      result.cfop := configuracao.CFOPST;


  finally
    qryProduto.Close;
  end;
end;

function TdmPrincipal.fCalcularTotaisCupom: Boolean;
begin
  try
    result := False;

    {Carrega variaveis}
    qryTotalCupom.ParamByName('NR_DOCUMENTO').AsInteger := rCupom.nrDocumento;
    qryTotalCupom.Open;
    rCupom.vlDesconto := qryTotalCupom.FieldByName('TOTAL_DESCONTO').AsCurrency;
    rCupom.vlDescontoSub:= qryTotalCupom.FieldByName('DESCONTO_SUBTOTAL').AsCurrency;
    rCupom.vlTotal := qryTotalCupom.FieldByName('TOTAL').AsCurrency + rCupom.vlDesconto;
    rCupom.vlSubTotal := qryTotalCupom.FieldByName('TOTAL').AsCurrency;
    rCupom.qtItens := qryTotalCupom.FieldByName('QT_ITENS').AsInteger;

    {Atualiza NOTAC}
    qryNotaC.ParamByName('NR_DOCUMENTO').AsInteger := rCupom.nrDocumento;
    qryNotaC.Open;
    qryNotaC.Edit;
    qryNotaC.FieldByName('VL_TOTAL').AsCurrency := rCupom.vlSubTotal;
    qryNotaC.FieldByName('VL_DESCONTO').AsCurrency := rCupom.vlDesconto;
    qryNotaC.FieldByName('QT_ITENS').AsInteger := rCupom.qtItens;
    qryNotaC.Post;

    result := True;
  finally
    qryTotalCupom.Close;
    qryNotaC.Close;
  end;
end;

function TdmPrincipal.fCancelarNota(const nrDocumento: Integer): Boolean;
var
  NotaCancelamento: TNFCeCancNFCE;
  FCli: MVCFramework.RESTClient.TRESTClient;
  FResp: MVCFramework.RESTClient.IRESTResponse;
  JsonObject: TJSONObject;

  procedure pBuscarDadosAut(var oCanc: TNFCeCancNFCE);
  var
    qryDadosAut: TFDQuery;
  begin
    try
      qryDadosAut := TFDQuery.Create(nil);
      qryDadosAut.Connection := conexao;
      qryDadosAut.Open('SELECT  ' +
                       '    DANFE,  ' +
                       '    LOTE,  ' +
                       '    PROTOCOLO, ' +
                       '    XML ' +
                       'FROM  ' +
                       '    NOTAC  ' +
                       'WHERE  ' +
                       '    NR_DOCUMENTO =  ' + nrDocumento.ToString);
      if qryDadosAut.FieldByName('PROTOCOLO').AsString <> '' then
      begin
        oCanc.chaveDanfe := qryDadosAut.FieldByName('DANFE').AsString;
        oCanc.protocolo := qryDadosAut.FieldByName('PROTOCOLO').AsString;
        oCanc.lote := qryDadosAut.FieldByName('LOTE').AsString;
        oCanc.xml := qryDadosAut.FieldByName('XML').AsString;
      end;
    finally
      qryDadosAut.Free;
    end;
  end;

begin
  try
    try
      FCli := MVCFramework.RESTClient.TRESTClient.create(configuracao.ipServidor,
        configuracao.portaServidor);
      FCli.ConnectionTimeOut(5000);

      NotaCancelamento := TNFCeCancNFCE.Create;
      pBuscarDadosAut(NotaCancelamento);

      if NotaCancelamento.protocolo = '' then
        Exit;

      FResp := FCli.doPOST('/ServerApi/CancelaNFCe/' + empresa.Cnpj, [], NotaCancelamento.AsJsonString);
      JsonObject := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(FResp.BodyAsString), 0) as TJSONObject;

      rCupom.autNrProtocolo := JsonObject.Values['protocolo'].Value;
      rCupom.autDtProcessamento := JsonObject.Values['dt_autorizacao'].Value;
      rCupom.autHrprocessamento := JsonObject.Values['hr_autorizacao'].Value;
      rCupom.autXmlVenda := JsonObject.Values['xml'].Value;

      if JsonObject.Values['autorizou'].Value = 'true' then
      begin
        AtualizarStatusNota(2);
        result := True;
      end

    finally
      NotaCancelamento.Free;
    end;

  except on E: Exception do
    begin
      result := False;
      pLog('fCancelarNota', E.Message);
    end;
  end;
end;

function TdmPrincipal.fCarregarConfiguracao: Boolean;
var
  qryConfiguracao: TFDquery;
begin
  try
    qryConfiguracao := TFDquery.Create(nil);
    qryConfiguracao.Connection := conexao;
    qryConfiguracao.Open('SELECT * FROM CONFIGURACAO, CONFIGURACAO_LOCAL');

    {Configuração Sinc}
    configuracao.Id := qryConfiguracao.FieldByName('ID').AsInteger;
    configuracao.IdDispositivo := qryConfiguracao.FieldByName('DISP_ID').AsInteger;
    configuracao.DispDescricao := qryConfiguracao.FieldByName('DISP_DESCRICAO').AsString;
    configuracao.IpServidor := qryConfiguracao.FieldByName('IP_SERVIDOR').AsString;
    configuracao.PortaServidor := qryConfiguracao.FieldByName('PORTA_SERVIDOR').AsInteger;
    configuracao.CaixaCodigo := qryConfiguracao.FieldByName('CAIXA_CODIGO').AsInteger;
    configuracao.Serie := qryConfiguracao.FieldByName('SERIE').AsInteger;
    configuracao.Modelo := qryConfiguracao.FieldByName('MODELO').AsInteger;
    configuracao.Homologacao := qryConfiguracao.FieldByName('HOMOLOGACAO').AsInteger;
    configuracao.CFOP := qryConfiguracao.FieldByName('CFOP').AsInteger;
    configuracao.CFOPST := qryConfiguracao.FieldByName('CFOP_ST').AsInteger;
    configuracao.CdUsuario := qryConfiguracao.FieldByName('CD_USUARIO').AsInteger;
    configuracao.NomeUsuario := qryConfiguracao.FieldByName('NOME_USUARIO').AsString;
    configuracao.IdCsc := qryConfiguracao.FieldByName('ID_CSC').AsInteger;
    configuracao.Csc := qryConfiguracao.FieldByName('CSC').AsString;
    configuracao.UrlPFX := qryConfiguracao.FieldByName('URL_PFX').AsString;
    configuracao.SenhaPFX := qryConfiguracao.FieldByName('SENHA_PFX').AsString;
    configuracao.TipoSSL := qryConfiguracao.FieldByName('TIPO_SSL').AsInteger;
    configuracao.Ambiente := qryConfiguracao.FieldByName('AMBIENTE').AsInteger;

    {Configuração Local}
    configLocal.Id := qryConfiguracao.FieldByName('ID').AsInteger;
    configLocal.UltimoLogin := qryConfiguracao.FieldByName('ULT_LOGIN').AsString;
    configLocal.UltimaSenha := qryConfiguracao.FieldByName('ULT_SENHA').AsString;
    configLocal.FlEconomiaPapel := qryConfiguracao.FieldByName('FL_ECONOMIAPAPEL').AsInteger;
    configLocal.FLSomErro := qryConfiguracao.FieldByName('FL_SOMERRO').AsInteger;
    configLocal.FlSomsucesso := qryConfiguracao.FieldByName('FL_SOMSUCESSO').AsInteger;
    configLocal.VersaoBanco := qryConfiguracao.FieldByName('VERSAOBANCO').AsInteger;
  finally
    qryConfiguracao.Free;
  end;

  {Caixa}
  fControleCaixa(1);
end;

function TdmPrincipal.fCarregarDadosEmpresa: Boolean;
var
  qryEmpresa: TFDquery;
begin
  try
    qryEmpresa := TFDquery.Create(nil);
    qryEmpresa.Connection := conexao;
    qryEmpresa.Open('SELECT * FROM EMPRESA');

    empresa.Id := qryEmpresa.FieldByName('ID').AsInteger;
    empresa.Cnpj := qryEmpresa.FieldByName('CNPJ').AsString;
    empresa.RazaoSocial := qryEmpresa.FieldByName('RAZAOSOCIAL').AsString;
    empresa.Cidade := qryEmpresa.FieldByName('CIDADE').AsString;
    empresa.Numero := qryEmpresa.FieldByName('NUMERO').AsInteger;
    empresa.UF := qryEmpresa.FieldByName('UF').AsString;
    empresa.Endereco := qryEmpresa.FieldByName('RUA').AsString;
    empresa.Fantasia := qryEmpresa.FieldByName('FANTASIA').AsString;
    empresa.Ie := qryEmpresa.FieldByName('IE').AsString;
    empresa.AliqPis := qryEmpresa.FieldByName('PISALIQUOTA').AsCurrency;
    empresa.AliqCofins := qryEmpresa.FieldByName('COFINSALIQUOTA').AsCurrency;
    empresa.Complemento := qryEmpresa.FieldByName('COMPLEMENTO').AsString;
    empresa.Bairro := qryEmpresa.FieldByName('BAIRRO').AsString;
    empresa.IbgeCod := qryEmpresa.FieldByName('IBGECODIGO').AsInteger;
    empresa.Cep := qryEmpresa.FieldByName('CEP').AsInteger;
    empresa.Telefone := qryEmpresa.FieldByName('TELEFONE').AsString;
    empresa.UfCodigo := qryEmpresa.FieldByName('UF_CODIGO').AsInteger;
    empresa.Regime := qryEmpresa.FieldByName('REGIME').AsInteger;
  finally
    qryEmpresa.Free;
  end;
end;

function TdmPrincipal.fConectarBanco: Boolean;
begin
  with conexao do
  begin
    Params.Clear;
    Params.Values['DriverID'] := 'SQLite';
    {$IFDEF IOS}
    try
      Params.Values['DataBase'] := TPath.Combine(TPath.GetDocumentsPath, 'VENDAS.db');
    except on E: Exception do
      raise Exception.Create('Erro ao conectar no banco de dados: ' + E.message);
    end;
    {$ENDIF}

    {$IFDEF  ANDROID}
    try
      Params.Values['DataBase'] := TPath.Combine(TPath.GetDocumentsPath, 'VENDAS.db');
    except on E: Exception do
      raise Exception.Create('Erro ao conectar no banco de dados: ' + E.message);
    end;
    {$ENDIF}

    {$IFDEF  MSWINDOWS}
    try
      Params.Values['DataBase'] := 'D:\FONTES\MVENDAS\DATABASE\VENDAS.DB';
    except on E: Exception do
      raise Exception.Create('Erro ao conectar no banco de dados: ' + E.message);
    end;
    {$ENDIF}

  end;
end;

function TdmPrincipal.fControleCaixa(const tipo: Integer): Boolean;
begin
  try
    case tipo of
      1:
      begin {ABERTURA/CARREGAR}
        qryCaixa.Close;
        qryCaixa.ParamByName('DATACAIXA').AsString := FormatDateTime('dd/mm/yyyy', now);
        qryCaixa.ParamByName('FECHADO').AsInteger := 0;
        qryCaixa.Open;

        if qryCaixa.IsEmpty then
        begin
          qryCaixa.Append;
          qryCaixa.FieldByName('CD_USUARIO').AsInteger := configuracao.CdUsuario;
          qryCaixa.FieldByName('DATA').AsString := FormatDateTime('dd/mm/yyyy', now);
          qryCaixa.FieldByName('FECHADO').AsInteger := 0;
          qryCaixa.Post;
          qryCaixa.Refresh;
        end;

        caixa.Id := qryCaixa.FieldByName('ID').AsInteger;
        caixa.CdUsuario := qryCaixa.FieldByName('CD_USUARIO').AsInteger;
        caixa.Data := qryCaixa.FieldByName('DATA').AsString;
        qryCaixa.Close;
      end;
      2:
      begin {FECHAMENTO}
        //Programar o fechamento do caixa
      end;
    end;

    result := True;
  except on E: Exception do
    begin
      pLog('fControleCaixa', E.Message);
      result := False
    end;
  end;
end;

function TdmPrincipal.fEmitirNota: Boolean;
var
  Nota: TNFCe;
//  FCli: MVCFramework.RESTClient.TRESTClient;
//  FResp: MVCFramework.RESTClient.IRESTResponse;
//  JsonObject: TJSONObject;
begin
//  FCli := MVCFramework.RESTClient.TRESTClient.create(configuracao.ipServidor,
//          configuracao.portaServidor);
//  FCli.ConnectionTimeOut(5000);
  Nota := TNFCe.Create;

  try
    try
      DadosDaNota(rCupom.nrDocumento, Nota);
//      dmNfe.


//      FResp := FCli.doPOST('/ServerApi/GeraNFCE/' + empresa.cnpj, [], Nota.AsJsonString);
//      JsonObject := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(FResp.BodyAsString), 0) as TJSONObject;
//
//      rCupom.autChaveDanfe := JsonObject.Values['chavedanfe'].Value;
//      rCupom.autNrProtocolo := JsonObject.Values['protocolo'].Value;
//      rCupom.autXmlVenda := JsonObject.Values['xml'].Value;
//      rCupom.autSituacaoNfce := JsonObject.Values['situacaonfce'].Value;
//      rCupom.autQrCode := JsonObject.Values['qrcode'].Value;
//      rCupom.autNrLoteLote := JsonObject.Values['lote'].Value;
//      rCupom.autRecibo := JsonObject.Values['recibo'].Value;
//      rCupom.autHrprocessamento := JsonObject.Values['hr_autorizacao'].Value;
//      rCupom.autDtProcessamento := JsonObject.Values['dt_autorizacao'].Value;
//      rCupom.autNrDocumentoServidor := JsonObject.Values['NrDocumentoServidor'].Value;

      AtualizarStatusNota;

    except on E: Exception do
      begin
        pLog('fEmitirNota', E.Message);
        AtualizarStatusNota(2);
        result := False;
      end;
    end;

  finally
//    Nota.Free;
//    JsonObject.Free;
//    FCli.Free;
  end;
end;

function TdmPrincipal.fGravarCaixaMov(const tipo: String;
  const cdFinalizadora: Integer; const valor: Currency): Boolean;
begin
  qryCaixaMov.Close;
  qryCaixaMov.ParamByName('CD_CAIXA').AsInteger := 0;
  qryCaixaMov.Open;

  qryCaixaMov.Append;
  qryCaixaMov.FieldByName('CD_CAIXA').AsInteger := caixa.Id;
  qryCaixaMov.FieldByName('FINALIZADORA').AsInteger := cdFinalizadora;
  qryCaixaMov.FieldByName('VL_TOTAL').AsCurrency := valor;
  qryCaixaMov.FieldByName('TIPO').AsString := UpperCase(tipo);
  qryCaixaMov.FieldByName('NR_DOCUMENTO').AsInteger := rCupom.nrDocumento;
  qryCaixaMov.Post
end;

function TdmPrincipal.DadosDaNota(const nrDocumento: Integer; var Nota: TNFCe): Boolean;
var
  NotaItens: TNFCeItem;
  NotaPgto: TNFCePagto;

  function fPreencheCabecalho: Boolean;
  begin
    result := False;
    qryNotaC.ParamByName('NR_DOCUMENTO').AsInteger := nrDocumento;
    qryNotaC.Open;
    qryNotaC.First;

    if qryNotaC.IsEmpty then
      Exit;

    Nota.idDispositivo := configuracao.IdDispositivo.ToString;
    Nota.nrDocumento := qryNotaC.FieldByName('NR_DOCUMENTO').AsInteger;
    Nota.nrNota := qryNotaC.FieldByName('NR_NOTA').AsInteger;
    Nota.nrSerie := qryNotaC.FieldByName('NR_SERIE').AsInteger;
    Nota.cdCaixa := qryNotaC.FieldByName('CD_CAIXA').AsInteger;
    Nota.cancelado := qryNotaC.FieldByName('CANCELADO').AsInteger;
    Nota.dtVenda := qryNotaC.FieldByName('DTH_VENDA').AsString;
    Nota.dtEmissao := qryNotaC.FieldByName('DTH_EMISSAO').AsString;
    Nota.cdCliente := qryNotaC.FieldByName('CD_CLIENTE').AsInteger;
    Nota.vlTotal := qryNotaC.FieldByName('VL_TOTAL').AsCurrency;
    Nota.autProtocolo := qryNotaC.FieldByName('PROTOCOLO').AsString;
    Nota.autLote := qryNotaC.FieldByName('LOTE').AsString;
    Nota.autRecibo := qryNotaC.FieldByName('RECIBO').AsString;
    Nota.autChave := qryNotaC.FieldByName('DANFE').AsString;
    Nota.autProtocoloCancel := qryNotaC.FieldByName('PROT_CANCELAMENTO').AsString;
    Nota.autSituacao := qryNotaC.FieldByName('SITUACAO_NFCE').AsInteger;
    Nota.qtItens := qryNotaC.FieldByName('QT_ITENS').AsInteger;
    Nota.xml := qryNotaC.FieldByName('XML').AsString;
    Nota.qrCode := qryNotaC.FieldByName('QR_CODE').AsString;
    Nota.pcDesconto := qryNotaC.FieldByName('PC_DESCONTO').AsCurrency;
    Nota.status := qryNotaC.FieldByName('STATUS').AsInteger;
    Nota.modelo := qryNotaC.FieldByName('MODELO').AsInteger;
    Nota.documentoServidor := qryNotaC.FieldByName('DOCUMENTO_SERVIDOR').AsInteger;

    qryNotaC.Close;
    result := True;
  end;
  function fPreencherItens: Boolean;
  begin
    result := False;
    qryNotaI.Close;
    qryNotaI.ParamByName('NR_DOCUMENTO').AsInteger := nrDocumento;
    qryNotaI.Open;

    if qryNotaI.IsEmpty then
      Exit;

    qryNotaI.First;
    while not qryNotaI.Eof do
    begin
      NotaItens := TNFCeItem.Create;
      NotaItens.nrDocumento := qryNotaI.FieldByName('NR_DOCUMENTO').AsInteger;
      NotaItens.nrSequencia := qryNotaI.FieldByName('NR_SEQUENCIA').AsInteger;
      NotaItens.cdProduto := qryNotaI.FieldByName('CD_BARRAS').AsString;
      NotaItens.cdBarras := qryNotaI.FieldByName('CD_PRODUTO').AsString;
      NotaItens.descricao := qryNotaI.FieldByName('DESCRICAO').AsString;
      NotaItens.quantidade := qryNotaI.FieldByName('QTD').AsFloat;
      NotaItens.vlBruto := qryNotaI.FieldByName('VL_BRUTO').AsCurrency;
      NotaItens.vlLiquido := qryNotaI.FieldByName('VL_LIQUIDO').AsCurrency;
      NotaItens.vlTotal := qryNotaI.FieldByName('VL_TOTAL').AsCurrency;
      NotaItens.vlDesconto := qryNotaI.FieldByName('VL_DESCONTO').AsCurrency;
      NotaItens.vlDescItem := qryNotaI.FieldByName('VL_DESCITEM').AsCurrency;
      NotaItens.ncm := qryNotaI.FieldByName('NCM').AsString;
      NotaItens.vlIcms := qryNotaI.FieldByName('VL_ICMS').AsCurrency;
      NotaItens.vlBcIcms := qryNotaI.FieldByName('VL_BASE_ICMS').AsCurrency;
      NotaItens.vlBcPis := qryNotaI.FieldByName('VL_BASE_PIS').AsCurrency;
      NotaItens.vlPis := qryNotaI.FieldByName('VL_PIS').AsCurrency;
      NotaItens.vlBcCofins := qryNotaI.FieldByName('VL_BASE_COFINS').AsCurrency;
      NotaItens.vlCofins := qryNotaI.FieldByName('VL_COFINS').AsCurrency;
      NotaItens.vlFcp := qryNotaI.FieldByName('VL_FCP').AsCurrency;
      NotaItens.aliqIcms := qryNotaI.FieldByName('ALIQ_ICMS').AsCurrency;
      NotaItens.aliqFcp := qryNotaI.FieldByName('ALIQ_FCP').AsCurrency;
      NotaItens.status := qryNotaI.FieldByName('STATUS').AsInteger;
      NotaItens.cancelado := qryNotaI.FieldByName('CANCELADO').AsInteger;
      NotaItens.cstIcms := qryNotaI.FieldByName('CST_ICMS').AsString;
      NotaItens.aliqPis := qryNotaI.FieldByName('ALIQ_PIS').AsCurrency;
      NotaItens.aliqCofins := qryNotaI.FieldByName('ALIQ_COFINS').AsCurrency;
      NotaItens.cstPisCofins := qryNotaI.FieldByName('CST_PISCOFINS').AsString;
      NotaItens.pesoLiquido := qryNotaI.FieldByName('PESO_LIQUIDO').AsFloat;
      NotaItens.cest := qryNotaI.FieldByName('CEST').AsString;
      NotaItens.un := qryNotaI.FieldByName('UN').AsString;
      NotaItens.cfop := qryNotaI.FieldByName('CFOP').AsInteger;
      NotaItens.pcDesconto := qryNotaI.FieldByName('PC_DESCONTO').AsCurrency;
      Nota.Itens.Add(NotaItens);
      qryNotaI.Next;
    end;
    qryNotaI.Close;
    result := True;
  end;
  function fPreencherPagamento: Boolean;
  begin
    result := False;
    qryPagamento.Close;
    qryPagamento.ParamByName('NR_DOCUMENTO').AsInteger := nrDocumento;
    qryPagamento.Open;

    if qryPagamento.IsEmpty then
      Exit;

    qryPagamento.First;
    while not qryPagamento.Eof do
    begin
      NotaPgto := TNFCePagto.Create;
      NotaPgto.nrDocumento := qryPagamento.FieldByName('NR_DOCUMENTO').AsInteger;
      NotaPgto.nrSequencia := qryPagamento.FieldByName('NR_SEQUENCIA').AsInteger;
      NotaPgto.DtEmissao := qryPagamento.FieldByName('DTH_EMISSAO').AsString;
      NotaPgto.CdFinalizadora := qryPagamento.FieldByName('FINALIZADORA').AsInteger;
      NotaPgto.VlTotal := qryPagamento.FieldByName('VL_TOTAL').AsCurrency;
      NotaPgto.Cancelado := qryPagamento.FieldByName('CANCELADO').AsInteger;
      NotaPgto.VlTroco := qryPagamento.FieldByName('VL_TROCO').AsCurrency;
      NotaPgto.Tipo := qryPagamento.FieldByName('TIPO').AsInteger;
      Nota.Pagamentos.Add(NotaPgto);
      qryPagamento.Next;
    end;
    qryPagamento.Close;
    result := True;
  end;
begin
  try
    if fPreencheCabecalho then
      if fPreencherItens then
        if fPreencherPagamento then
          result := True;
  except on E: Exception do
    begin
      raise Exception.Create('Erro ao preencher a nota: ' + e.message);
      result := False;
    end
  end;
end;

function TdmPrincipal.ReceberProduto: Boolean;
begin

end;

function TdmPrincipal.EnviarVenda: Boolean;
var
  venda: TNFCe;
begin
  venda := TNFCe.Create;
  DadosDaNota(rCupom.nrDocumento, venda);
  
end;

procedure TdmPrincipal.GravarConfiguracao(disp, ipServidor, portaServidor,
  Cnpj: String);
var
  qryConfiguracao: TFDquery;
  qryEmpresa: TFDquery;
begin
  {SERVIDOR}
  qryConfiguracao := TFDquery.Create(nil);
  qryConfiguracao.Connection := conexao;
  qryConfiguracao.SQL.Text := 'UPDATE  ' +
                              '    CONFIGURACAO  ' +
                              'SET  ' +
                              '    DISP_ID = :DISP_IP,  ' +
                              '    IP_SERVIDOR = :IP_SERVIDOR,  ' +
                              '    PORTA_SERVIDOR = :PORTA_SERVIDOR ';
  qryConfiguracao.ParamByName('DISP_ID').AsInteger := disp.ToInteger;
  qryConfiguracao.ParamByName('IP_SERVIDOR').AsString := ipServidor;
  qryConfiguracao.ParamByName('PORTA_SERVIDOR').AsInteger := portaServidor.ToInteger;

  try
    qryConfiguracao.ExecSQL;
  finally
    qryConfiguracao.Free;
  end;

  {CNPJ}
  qryEmpresa := TFDquery.Create(nil);
  qryEmpresa.Connection := conexao;
  qryEmpresa.SQL.Text := 'UPDATE  ' +
                         '    EMPRESA ' +
                         'SET ' +
                         '    CNPJ = :CNPJ ';
  qryEmpresa.ParamByName('CNPJ').AsString := Cnpj;
  try
    qryEmpresa.ExecSQL;
  finally
    qryEmpresa.Free;
  end;
end;

procedure TdmPrincipal.AtualizarStatusNota(const tipo: Integer);
var
  qryUpdateNotaC: TFDquery;
  qryUpdateNotaI: TFDquery;

  procedure pAutSucesso;
  begin
    qryUpdateNotaC.SQL.Text := 'UPDATE ' +
                               '    NOTAC ' +
                               'SET ' +
                               '    DANFE = :DANFE,' +
                               '    PROTOCOLO = :PROTOCOLO, ' +
                               '    XML = :XML, ' +
                               '    SITUACAO_NFCE = :SITUACAO_NFCE, ' +
                               '    RECIBO = :RECIBO, ' +
                               '    STATUS = :STATUS, ' +
                               '    LOTE = :LOTE, ' +
                               '    DTH_EMISSAO = :DHT_EMISSAO ' +
                               'WHERE ' +
                               '    NR_DOCUMENTO = :NR_DOCUMENTO ';

    {Forma o DtEmissao}
    rCupom.dtEmissao := rCupom.autDtProcessamento + ' ' +
      rCupom.autHrprocessamento;

    qryUpdateNotaC.ParamByName('NR_DOCUMENTO').AsInteger := rCupom.nrDocumento;
    qryUpdateNotaC.ParamByName('DANFE').AsString := rCupom.autChaveDanfe;
    qryUpdateNotaC.ParamByName('PROTOCOLO').AsString := rCupom.autNrProtocolo;
    qryUpdateNotaC.ParamByName('XML').AsString := rCupom.autXmlVenda;
    qryUpdateNotaC.ParamByName('SITUACAO_NFCE').AsString := rCupom.autSituacaoNfce;
    qryUpdateNotaC.ParamByName('RECIBO').AsString := rCupom.autRecibo;
    qryUpdateNotaC.ParamByName('STATUS').AsInteger := 2;
    qryUpdateNotaC.ParamByName('LOTE').AsString := rCupom.autNrLote;
    qryUpdateNotaC.ParamByName('DHT_EMISSAO').AsString := rCupom.dtEmissao;
    qryUpdateNotaC.ExecSQL;
  end;
  procedure pAutErro;
  begin
    qryUpdateNotaC.SQL.Text := 'UPDATE ' +
                               '    NOTAC ' +
                               'SET ' +
                               '    STATUS = 4 ' +
                               'WHERE ' +
                               '    NR_DOCUMENTO = :NR_DOCUMENTO ';
    qryUpdateNotaC.ParamByName('NR_DOCUMENTO').AsInteger := rCupom.nrDocumento;
    qryUpdateNotaC.ExecSql;
  end;
  procedure pAutCancelamento;
  begin
    qryUpdateNotaC.SQL.Text := 'UPDATE ' +
                               '    NOTAC ' +
                               'SET ' +
                               '    PROT_CANCELAMENTO = :PROTOCOLO, ' +
                               '    XML = :XML, ' +
                               '    SITUACAO_NFCE = 101, ' +
                               '    STATUS = 3, ' +
                               '    CANCELADO = 1, ' +
                               '    DTH_EMISSAO = :DHT_EMISSAO ' +
                               'WHERE ' +
                               '    NR_DOCUMENTO = :NR_DOCUMENTO ';

    qryUpdateNotaC.ParamByName('NR_DOCUMENTO').AsInteger := rCupom.nrDocumento;
    qryUpdateNotaC.ParamByName('PROTOCOLO').AsString := rCupom.autNrProtocolo;
    qryUpdateNotaC.ParamByName('XML').AsString := rCupom.autXmlVenda;
    qryUpdateNotaC.ParamByName('DHT_EMISSAO').AsString :=
      rCupom.autDtProcessamento + ' ' + rCupom.autHrprocessamento;
    qryUpdateNotaC.ExecSQL;

    qryUpdateNotaI := TFDquery.Create(nil);
    qryUpdateNotaI.Connection := conexao;
    qryUpdateNotaI.SQL.Add(
      'UPDATE  ' +
      '    NOTAI ' +
      'SET  ' +
      '    CANCELADO = 1 ' +
      'WHERE        ' +
      '    NR_DOCUMENTO = :NR_DOCUMENTO ');

    qryUpdateNotaI.ParamByName('NR_DOCUMENTO').AsInteger := rCupom.nrDocumento;
    try
      qryUpdateNotaI.ExecSQL;
    finally
      qryUpdateNotaI.Free;
    end;
  end;
begin
  try
    qryUpdateNotaC := TFDquery.Create(nil);
    qryUpdateNotaC.Connection := conexao;

    case tipo of
      0: pAutSucesso;
      1: pAutErro;
      2: pAutCancelamento;
    end;

  finally
    qryUpdateNotaC.Free;
  end;
end;

procedure TdmPrincipal.pCalcularImposto;
var
	qryCalcImposto: TFDquery;
begin
  try
    try
      qryCalcImposto := TFDquery.Create(nil);
      qryCalcImposto.Connection := conexao;

      {PISCOFINS}
      qryCalcImposto.Sql.Text :=
        'UPDATE ' +
        '   NOTAI ' +
        'SET  ' +
        '   VL_BASE_PIS = VL_TOTAL, ' +
        '   VL_PIS = VL_TOTAL * ALIQ_PIS / 100, ' +
        ' 	VL_BASE_COFINS = VL_TOTAL, ' +
        ' 	VL_COFINS = VL_TOTAL * ALIQ_COFINS / 100 ' +
        'WHERE ' +
        '   NR_DOCUMENTO = ' + rCupom.nrDocumento.ToString + ' AND ' +
        '	  CST_PISCOFINS = ''1'' ';
      qryCalcImposto.ExecSql;

      {ICMS}
      qryCalcImposto.Sql.Text :=
        'UPDATE  ' +
        '	  NOTAI ' +
        'SET ' +
        '	  VL_BASE_ICMS = VL_TOTAL - (VL_TOTAL * PC_REDUCAO / 100), ' +
        '	  VL_ICMS = (VL_TOTAL - (VL_TOTAL * PC_REDUCAO / 100)) * ALIQ_ICMS / 100, ' +
        '	  VL_REDUCAO = (VL_TOTAL * PC_REDUCAO / 100) ' +
        'WHERE ' +
        '   NR_DOCUMENTO = ' + rCupom.nrDocumento.ToString + ' AND ' +
        '	  SUBSTR(CST_ICMS, 2, 3) IN (''00'', ''20'')';
      qryCalcImposto.ExecSql;

      {FCP}
      qryCalcImposto.Sql.Text :=
        'UPDATE  ' +
        '	  NOTAI ' +
        'SET ' +
        '	  VL_BASE_FCP = VL_TOTAL, ' +
        '	  VL_FCP = VL_TOTAL * ALIQ_FCP / 100 ' +
        'WHERE ' +
        '   NR_DOCUMENTO = ' + rCupom.nrDocumento.ToString + ' AND ' +
        '	  ALIQ_FCP > 0 AND ' +
        '	  SUBSTR(CST_ICMS, 2, 3) IN (''00'', ''20'')';
      qryCalcImposto.ExecSql;

    finally
      qryCalcImposto.Free;
    end;
  except on E: Exception do
    pLog('pCalcImposto', e.Message);
  end;
end;

procedure TdmPrincipal.pCarregarDadosAut;
begin
  try
    qryNotaC.ParamByName('NR_DOCUMENTO').AsInteger := rCupom.nrDocumento;
    qryNotaC.Open;

    rCupom.nrNota := qryNotaC.FieldByName('NR_NOTA').AsInteger;
    rCupom.autChaveDanfe := qryNotaC.FieldByName('DANFE').AsString;
    rCupom.autNrProtocolo := qryNotaC.FieldByName('PROTOCOLO').AsString;
    rCupom.autXmlVenda := qryNotaC.FieldByName('XML').AsString;
    rCupom.autSituacaoNfce := qryNotaC.FieldByName('SITUACAO_NFCE').AsInteger.ToString;
    rCupom.autQrCode := qryNotaC.FieldByName('QR_CODE').AsString;
    rCupom.autNrLote := qryNotaC.FieldByName('LOTE').AsString;
    rCupom.autRecibo := qryNotaC.FieldByName('RECIBO').AsString;
    rCupom.dtEmissao := qryNotaC.FieldByName('DTH_EMISSAO').AsString;

  finally
    qryNotaC.Close;
  end;
end;

procedure TdmPrincipal.pCarregarDadosCliente;
begin
  try
    qryNotaC.ParamByName('NR_DOCUMENTO').AsInteger := rCupom.nrDocumento;
    qryNotaC.Open;

    rCliCupom.cdCliente := qryNotaC.FieldByName('CD_CLIENTE').AsInteger;
    rCliCupom.nmCliente := qryNotaC.FieldByName('NOME_CLIENTE').AsString;
    rCliCupom.cpfCliente := qryNotaC.FieldByName('CPF_CLIENTE').AsString;
  finally
    qryNotaC.Close;
  end;
end;

procedure TdmPrincipal.pDeletarItemBanco(const sequencia: Integer);
var
  qryDelItem: TFDquery;
begin
  try
    qryDelItem := TFDquery.Create(nil);
    qryDelItem.Connection := conexao;
    qryDelItem.SQL.Text := 'DELETE FROM ' +
                           '    NOTAI ' +
                           'WHERE ' +
                           '    NR_DOCUMENTO = :NR_DOCUMENTO AND ' +
                           '    NR_SEQUENCIA = :NR_SEQUENCIA ';
    qryDelItem.ParamByName('NR_DOCUMENTO').AsInteger := rCupom.nrDocumento;
    qryDelItem.ParamByName('NR_SEQUENCIA').AsInteger := sequencia;
    qryDelItem.ExecSQL;
  finally
    qryDelItem.Free;
  end;
end;

procedure TdmPrincipal.pDeletarPagBanco;
var
  qryDelPag: TFDQuery;
begin
  try
    qryDelPag := TFDQuery.Create(nil);
    qryDelPag.Connection := conexao;

    {PAGAMENTO}
    qryDelPag.SQL.Text := 'DELETE FROM PAGAMENTO WHERE NR_DOCUMENTO = :NR_DOCUMENTO';
    qryDelPag.ParamByName('NR_DOCUMENTO').AsInteger := rCupom.nrDocumento;
    qryDelPag.ExecSQL;

    {CARTAO - Sem tabela ainda}
//    qryDelPag.SQL.Text := 'DELETE FROM CARTAO WHERE NR_DOCUMENTO = :NR_DOCUMENTO';
//    qryDelPag.ParamByName('NR_DOCUMENTO').AsInteger := rCupom.nrDocumento;
//    qryDelPag.ExecSQL;
  finally
    qryDelPag.Free;
  end;
end;

procedure TdmPrincipal.pDeletarVendaBanco;
var
  qryDelVenda: TFDQuery;
begin
  if rCupom.nrDocumento = 0 then
    Exit;

  try
    {DELETA O CABECALHO}
    qryDelVenda := TFDQuery.Create(nil);
    qryDelVenda.Connection := conexao;
    qryDelVenda.SQL.Text := 'DELETE FROM NOTAC WHERE NR_DOCUMENTO = ' + rCupom.nrDocumento.ToString;
    qryDelVenda.ExecSQL;

    {DELETA O ITEM}
    qryDelVenda := TFDQuery.Create(nil);
    qryDelVenda.Connection := conexao;
    qryDelVenda.SQL.Text := 'DELETE FROM NOTAI WHERE NR_DOCUMENTO = ' + rCupom.nrDocumento.ToString;
    qryDelVenda.ExecSQL;
  finally
    qryDelVenda.Free;
  end;

  pDeletarPagBanco;
end;

procedure TdmPrincipal.pLimparDesconto;
var
  qryLimpaDesc: TFDquery;
begin
  try
    qryLimpaDesc := TFDquery.Create(nil);
    qryLimpaDesc.Connection := conexao;
    qryLimpaDesc.SQL.Text :=
                'UPDATE  ' +
                '    NOTAI ' +
                'SET ' +
                '    VL_TOTAL = ROUND(VL_BRUTO * QTD, 2) - VL_DESCITEM, ' +
                '    VL_DESCONTO = 0 ' +
                'WHERE ' +
                '    NR_DOCUMENTO = :NR_DOCUMENTO ';
    qryLimpaDesc.ParamByName('NR_DOCUMENTO').AsInteger := rCupom.nrDocumento;
    qryLimpaDesc.ExecSql;
    rCupom.vlDescontoSub := 0;
  finally
    qryLimpaDesc.Free;
  end;
end;

function TdmPrincipal.fMarcarFavorito(tabela, where, chave: String; favorito: Integer): Boolean;
var
  qryMarcarFav: TFDquery;
begin
  try
    try
      qryMarcarFav := TFDquery.Create(nil);
      qryMarcarFav.Connection := conexao;
      qryMarcarFav.SQL.Text := ' UPDATE ' +
                                   tabela +
                               ' SET ' +
                               '   FAVORITO = ' + favorito.ToString +
                               ' WHERE ' +
                                   where + ' = ' + chave;
      qryMarcarFav.ExecSQL;
      result := True;
    finally
      qryMarcarFav.Free;
    end;
  except on E: Exception do
    pLog('fMarcarFavorito', E.Message);
  end;
end;

procedure TdmPrincipal.pRatearDescontoItem(const vlDesconto: Currency);
var
  qryRatDesc: TFDQuery;
  pcDesconto: Double;
begin
  pcDesconto := 0;
  pcDesconto := vlDesconto / rCupom.vlTotal * 100;
  try
    try
      qryRatDesc := TFDquery.Create(nil);
      qryRatDesc.Connection := conexao;
      qryRatDesc.SQL.Text := ' UPDATE ' +
                             '     NOTAI  ' +
                             ' SET   ' +
                             '     VL_DESCONTO = (:PERCENTUAL * VL_TOTAL / 100), ' +
                             '     VL_LIQUIDO = VL_LIQUIDO - (:PERCENTUAL * VL_BRUTO / 100), ' +
                             '     VL_TOTAL = VL_TOTAL - (:PERCENTUAL * VL_TOTAL /100) ' +
                             ' WHERE ' +
                             '    NR_DOCUMENTO = :NR_DOCUMENTO';

      qryRatDesc.ParamByName('PERCENTUAL').AsCurrency := pcDesconto;
      qryRatDesc.ParamByName('NR_DOCUMENTO').AsInteger := rCupom.nrDocumento;
      qryRatDesc.ExecSQL;

    except on E: Exception do
      raise Exception.Create('Erro ao ratear os descontos');
    end;
  finally
    qryRatDesc.Free;
  end;
end;

procedure TdmPrincipal.RelGerencial;
var
  qryGerencial: TFDquery;
begin
  qryGerencial := TFDquery.Create(nil);
  qryGerencial.Connection := dmPrincipal.conexao;
  qryGerencial.SQL.Add(
    'SELECT ' +
    '    CAIXA_MOVIMENTO.TIPO, ' +
    '    CAIXA_MOVIMENTO.FINALIZADORA, ' +
    '    CASE WHEN CAIXA_MOVIMENTO.TIPO = ''R'' THEN ''REFORCO''  ' +
    '         WHEN CAIXA_MOVIMENTO.TIPO = ''S'' THEN ''SUPRIMENTO'' ELSE FINALIZADORA.DESCRICAO ' +
    '         END DESCRICAO, ' +
    '    SUM(CASE WHEN NOTAC.CANCELADO = 0 THEN CAIXA_MOVIMENTO.VL_TOTAL ELSE 0 END) VL_TOTAL, ' +
    '    SUM(CASE WHEN NOTAC.CANCELADO = 1 THEN CAIXA_MOVIMENTO.VL_TOTAL ELSE 0 END) VL_CANCELADO ' +
    'FROM ' +
    '    CAIXA_MOVIMENTO ' +
    '    JOIN NOTAC ON NOTAC.NR_DOCUMENTO = CAIXA_MOVIMENTO.NR_DOCUMENTO ' +
    '    LEFT JOIN FINALIZADORA ON FINALIZADORA.ID = CAIXA_MOVIMENTO.FINALIZADORA ' +
    '    JOIN CAIXA ON CAIXA.ID = CAIXA_MOVIMENTO.ID ' +
    'WHERE ' +
    '    CAIXA.CD_USUARIO = :CD_USUARIO ' +
    'GROUP BY CAIXA_MOVIMENTO.FINALIZADORA ');

  qryGerencial.ParamByName('CD_USUARIO').AsInteger := configuracao.CdUsuario;

  try

    try
      qryGerencial.Open;
    except on E: Exception do
      pLog('RelGerencial', 'Erro ao pegar as informações do banco : ' + E.Message);
    end;

    imprimir.ImprimirGerencial(qryGerencial);
  finally
    qryGerencial.Free;
  end;

end;

function TdmPrincipal.fDocumentoAberto: Integer;
var
  qryDocAberto: TFDquery;
begin
  try
    result := 0;
    qryDocAberto := TFDquery.Create(nil);
    qryDocAberto.Connection := conexao;
    qryDocAberto.Open('SELECT COALESCE(NR_DOCUMENTO, 0) NR_DOCUMENTO FROM NOTAC WHERE STATUS = 1');

    if qryDocAberto.IsEmpty then
      Exit;

    result := qryDocAberto.FieldByName('NR_DOCUMENTO').AsInteger;
  finally
    qryDocAberto.Free;
  end;
end;

end.
