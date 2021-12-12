 unit DNFCe;

interface

uses
  System.SysUtils, system.math,
  System.Classes, ACBrNFeDANFEClass, ACBrDANFCeFortesFr,
  ACBrBase, ACBrDFe, ACBrNFe, UNFCeClass, ACBrDFeReport, ACBrDFeDANFeReport,
  ACBrPosPrinter, ACBrNFeDANFeESCPOS, ACBrSATExtratoClass,
  ACBrSATExtratoReportClass, ACBrSATExtratoFortesFr, ACBrSAT,pcnCFe,System.DateUtils, UBaseController,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, ACBrEAD, ACBrPAF, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdExplicitTLSClientServerBase, IdFTP, system.Zip, IdFTPCommon, ActiveX;


type
  TPisCofins = record
    cst_pis: Integer;
    cst_cofins: Integer;
    base_pis: Currency;
    vl_pis: Currency;
    base_cofins: Currency;
    vl_cofins: Currency;
    aliq_pis: Currency;
    aliq_cofins: Currency;
  end;

  TdtmNFCe = class(TDataModule)
    ACBrNFe1: TACBrNFe;
    ACBrNFeDANFCeFortes1: TACBrNFeDANFCeFortes;
    ACBrNFeDANFeESCPOS1: TACBrNFeDANFeESCPOS;
    ACBrPosPrinter1: TACBrPosPrinter;
    ACBrSAT1: TACBrSAT;
    sat: TACBrSATExtratoFortes;
    ACBrPAF: TACBrPAF;
    ACBrEAD: TACBrEAD;
    procedure ACBrNFe1TransmitError(const HttpError, InternalError: Integer;
      const URL, DadosEnviados, SoapAction: string; var Retentar,
      Tratado: Boolean);
    procedure DataModuleCreate(Sender: TObject);
  private
    function PathNotaFiscalExemplo: string;
  public
    procedure ConfigurarNFe(config :TNFCeEmpresa);
    procedure PreencherNFCe(Conexao : TFDConnection; ANFCe: TNFCe; config :TNFCeEmpresa);
    function Enviar: TNFCeRetACBR;
    function fCancelarNFCe(ADadosCancelamento: TNFCeCancNFCE;
      config: TNFCeEmpresa; var retorno: TNFCeRetACBR): Boolean;

    function GerarPDF(xml:string; config : TNFCeEmpresa): string;
    function GerarPDFCfe(xml, nrDocumento, idDispositivo :String):String;
    function GerarXML(numero, serie: integer): string;

  	function ArredondarFloatABNT(ValorNormal: Real; CasasDecimais: Integer): Real;
    function fDadosPisCofins(vCstPis, vCstCofins: Integer; vAliqPis, vAliqCofins: Double; vBasePis, vBaseCofins, vVlPis, vVlCofins: Currency): TPisCofins;
    function fBuscarCodigoPgtoNFCE(vConexao: TFDConnection;vCD_Finalizadora: integer): integer;
    function fBuscarCNPJAdministradora(vConexao: TFDConnection;vNM_ADMINISTRADORA: String): string;
    function fBuscarAliquotaInterna(vConexao: TFDConnection): Currency;
  end;

//var
//  dtmNFCe: TdtmNFCe;

implementation

uses
  pcnConversaoNFe, pcnConversao, ACBrDFeSSL, blcksock, pcnAuxiliar, pcnNFe,
  System.StrUtils, ACBrUtil,  ACBrValidador, ACBrPAFRegistros, ACBrPAF_J;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

function GetStringFormatada(_AString, _ASubStr: String; _ALength: Word; _AAlign: TAlignment): String;
var
  i: Integer;
  ATam: Integer;
begin
  ATam := Length(_AString);
  _ASubStr := Copy(_ASubStr, 1, 1);
  if ((_ALength = 6) and (ATam > 6)) then
    _AString := Copy(_AString, ATam - 5, 6);
  Result := Copy(_AString, 1, _ALength);
  for i := 1 to _ALength-Length(Result) do
  begin
    case _AAlign of
      taLeftJustify : Result := Result + _ASubStr;
      taRightJustify  : Result := _ASubStr + Result;
      taCenter    :
      begin
        if (i mod 2) = 0 then
          Result := _ASubStr + Result
        else
          Result := Result + _ASubStr;
      end;
    end;
  end;
end;


function MP_CalculaCodBarras(Valor: String; size: integer = 12): String;
var i, soma, achaMultiplo, digito: integer;
    vetNumeros,vetCampos:array[1..14] of integer;
begin
	soma := 0;
  try
    Valor := GetStringFormatada(Valor, '0', size, taRightJustify);
    for i:= 1 to size do
    begin
      vetCampos[i] := StrToInt(copy(Valor,i,1));
      if odd(i) = false then
        vetNumeros[i] := 3
      else
        vetNumeros[i] := 1;
      soma := soma + (vetCampos[i] * vetNumeros[i])
    end;

    achaMultiplo := soma + 10;
    if achaMultiplo < 100 then
      achaMultiplo := (StrToInt(copy(inttostr(achaMultiplo),1,1))) * 10
    else
      achaMultiplo := (StrToInt(copy(inttostr(achaMultiplo),1,2))) * 10;

    digito := achaMultiplo - soma;
    if digito > 9 then
      digito := 0;

    Valor := Valor + IntToStr(Digito);
    if (Valor[1]='0') and (size = 12) then
      Result := Copy(Valor, 2, 12)
    else
    if Valor[1]='0' then
      Result := Copy(Valor, 2, size)
    else
      Result := Valor;
    {if size = 8 then  //Fabiano 08/01/2013 - comentado
      Result := Copy(Result, 5, 8) }
    if size = 8 then  //Fabiano 08/01/2013 - modificado
      Result := Copy(Result, 1, 8)

  except
  end;
end;


function ValorInRange(const AValor: Variant; const ARange: array of Variant): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := Low(ARange) to High(ARange) do
  begin
    if ARange[I] = AValor then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

function TdtmNFCe.PathNotaFiscalExemplo: string;
begin
  // gerar uma nota sempre com mesmo nome para efeitos de exemplo
  Result := ExtractFilePath(paramStr(0)) + 'notafiscal.xml';
end;

function TdtmNFCe.fBuscarCodigoPgtoNFCE(vConexao :TFDConnection; vCD_Finalizadora: integer): integer;
var
  qry :TFDQuery;
begin
  {CODIGO PAGAMENTO NFCE}
  result := 1; //Dinheiro
end;



function TdtmNFCe.fBuscarAliquotaInterna(vConexao: TFDConnection): Currency;
var
  qry: TFDQuery;
begin
  result := 0;
  qry := TFDQuery.Create(nil);
  try
    qry.Connection := vConexao;
    qry.Sql.Text := 'SELECT FIRST 1 ' +
                    '    TRIBICMS_UF.ALIQ_ICM_CONT AS ALIQ_INTERNA ' +
                    'FROM ' +
                    '    TRIBICMS_UF ' +
                    '    JOIN FILIAL ON FILIAL.UF = TRIBICMS_UF.UF_ORIGEM AND ' +
                    '        FILIAL.UF = TRIBICMS_UF.UF_DESTINO ' +
                    'WHERE ' +
                    '    TRIBICMS_UF.CST = ''000'' ';
    qry.Open;
    if not qry.IsEmpty then
      result := qry.FieldByName('ALIQ_INTERNA').AsCurrency;
  finally
    qry.Free;
  end;
end;

function TdtmNFCe.fBuscarCNPJAdministradora(vConexao :TFDConnection; vNM_ADMINISTRADORA: String): string;
var
  qry :TFDQuery;
begin
  result := '';

  qry := TFDQuery.Create(nil);
  try
    qry.Connection := vConexao;
    qry.SQL.Text :=
            'SELECT CNPJ FROM ADMINISTRADORA WHERE NM_ADMINISTRADORA = :NM_ADMINISTRADORA';
    qry.ParamByName('NM_ADMINISTRADORA').AsString:= vNM_ADMINISTRADORA;
    qry.Open;
    if not qry.IsEmpty then
      result := qry.FieldByName('CNPJ').AsString;
  finally
    qry.Free;
  end;
end;


function TdtmNFCe.fCancelarNFCe(ADadosCancelamento: TNFCeCancNFCE;
  config: TNFCeEmpresa; var retorno: TNFCeRetACBR): Boolean;
var
  CNPJ: String;
begin
  try
    retorno.xml             :='';
    retorno.chaveDanfe      :='';
    retorno.lote            :='';
    retorno.protocolo       :='';
    retorno.autorizou       := false;

    self.ConfigurarNFe(config);
    CNPJ := copy(ADadosCancelamento.chaveDanfe,7,14);
    ADadosCancelamento.Justificativa := 'Justificativa do Cancelamento';
    ACBrNFe1.EventoNFe.Evento.Clear;

    with ACBrNFe1.EventoNFe.Evento.New do
    begin
      infEvento.chNFe := ADadosCancelamento.chaveDanfe;
      infEvento.CNPJ   := CNPJ;
      infEvento.dhEvento := now;
      infEvento.tpEvento := teCancelamento;
      infEvento.detEvento.xJust := ADadosCancelamento.Justificativa;
      infEvento.detEvento.nProt := ADadosCancelamento.Protocolo;
    end;

    ACBrNFe1.EnviarEvento(StrToInt(ADadosCancelamento.Lote));

    retorno.Texto := ACBrNFe1.WebServices.EnvEvento.RetWS;
//    retorno.xml := ACBrNFe1.WebServices.EnvEvento.RetornoWS;
  //  LoadXML(ACBrNFe1.WebServices.EnvEvento.RetornoWS, WBResposta);
    (*
    ACBrNFe1.WebServices.EnvEvento.EventoRetorno.TpAmb
    ACBrNFe1.WebServices.EnvEvento.EventoRetorno.verAplic
    ACBrNFe1.WebServices.EnvEvento.EventoRetorno.cStat
    ACBrNFe1.WebServices.EnvEvento.EventoRetorno.xMotivo
    ACBrNFe1.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0].RetInfEvento.chNFe
    ACBrNFe1.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0].RetInfEvento.dhRegEvento
    ACBrNFe1.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0].RetInfEvento.nProt
    *)

   retorno.DT_Autorizacao := FormatDateTime('DD/MM/YYYY', ACBrNFe1.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0].RetInfEvento.dhRegEvento);
   retorno.HR_autorizacao := FormatDateTime('hh:mm:ss', ACBrNFe1.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0].RetInfEvento.dhRegEvento);
   retorno.xml            := ACBrNFe1.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0].RetInfEvento.XML;
   retorno.protocolo      := ACBrNFe1.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0].RetInfEvento.nProt;
   if (ACBrNFe1.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0].RetInfEvento.cStat = 135) then
    retorno.autorizou := true;




  finally
    result := retorno ;

  end;

end;

function TdtmNFCe.fDadosPisCofins(vCstPis, vCstCofins: Integer; vAliqPis,
  vAliqCofins: Double; vBasePis, vBaseCofins, vVlPis, vVlCofins: Currency): TPisCofins;
{Verifica a CST de Pis/Cofins zera os valores de necessário}
begin
  {PIS}
  if vBasePis = 0 then
    vAliqPis := 0;

  case vCstPis of
    1://Saída Tributado
    begin
      Result.cst_pis := vCstPis;
      Result.base_pis := vBasePis;
      Result.aliq_pis := vAliqPis;
      Result.vl_pis := vVlPis;
    end;
    4://Saida - Monofasica
    begin
      Result.cst_pis := vCstPis;
      Result.base_pis := 0;
      Result.aliq_pis := 0;
      Result.vl_pis := 0;
    end;
    5://Saida - Substituição Tributária
    begin
      Result.cst_pis := vCstPis;
      Result.base_pis := 0;
      Result.aliq_pis := 0;
      Result.vl_pis := 0;
    end;
    6://Aliquota "Zero" Saida
    begin
      Result.cst_pis := vCstPis;
      Result.base_pis := vBasePis;
      Result.aliq_pis := 0;
      Result.vl_pis := 0;
    end;
    7://Saida - Isento
    begin
      Result.cst_pis := vCstPis;
      Result.base_pis := 0;
      Result.aliq_pis := 0;
      Result.vl_pis := 0;
    end;
    9://Suspensão
    begin
      Result.cst_pis := vCstPis;
      Result.base_pis := 0;
      Result.aliq_pis := 0;
      Result.vl_pis := 0;
    end;
    49://Outras Saidas
    begin
      Result.cst_pis := vCstPis;
      Result.base_pis := 0;
      Result.aliq_pis := 0;
      Result.vl_pis := 0;
    end;
    else//Se for Outra
    begin
      Result.cst_pis := vCstPis;
      Result.base_pis := vBasePis;
      Result.aliq_pis := vAliqPis;
      Result.vl_pis := vVlPis;
    end;
  end;

  {COFINS}
  if CurrToStr(vBaseCofins) = '' then
    vAliqCofins := 0;
  case vCstCofins of
    1://Saída Tributado
    begin
      Result.cst_cofins := vCstCofins;
      Result.base_cofins := vBaseCofins;
      Result.aliq_cofins := vAliqCofins;
      Result.vl_cofins := vVlCofins;
    end;
    4://Saida - Monofasica
    begin
      Result.cst_cofins := vCstCofins;
      Result.base_cofins := 0;
      Result.aliq_cofins := 0;
      Result.vl_cofins := 0;
    end;
    5://Saida - Substituição Tributária
    begin
      Result.cst_cofins := vCstCofins;
      Result.base_cofins := 0;
      Result.aliq_cofins := 0;
      Result.vl_cofins := 0;
    end;
    6://Aliquota "Zero" Saida
    begin
      Result.cst_cofins := vCstCofins;
      Result.base_cofins := vBaseCofins;
      Result.aliq_cofins := 0;
      Result.vl_cofins := 0;
    end;
    7://Saida - Isento
    begin
      Result.cst_cofins := vCstCofins;
      Result.base_cofins := 0;
      Result.aliq_cofins := 0;
      Result.vl_cofins := 0;
    end;
    9://Suspensão
    begin
      Result.cst_cofins := vCstCofins;
      Result.base_cofins := 0;
      Result.aliq_cofins := 0;
      Result.vl_cofins := 0;
    end;
    49://Outras Saidas
    begin
      Result.cst_cofins := vCstCofins;
      Result.base_cofins := 0;
      Result.aliq_cofins := 0;
      Result.vl_cofins := 0;
    end;
    else//Se for Outra
    begin
      Result.cst_cofins := vCstCofins;
      Result.base_cofins := vBaseCofins;
      Result.aliq_cofins := vAliqCofins;
      Result.vl_cofins := vVlCofins;
    end;
  end;
end;

procedure TdtmNFCe.ACBrNFe1TransmitError(const HttpError,
  InternalError: Integer; const URL, DadosEnviados, SoapAction: string;
  var Retentar, Tratado: Boolean);
var
  vHttpError : string;
  vDadosEnviados :string;
begin

 vHttpError :=  HttpError.ToString;
 vDadosEnviados := DadosEnviados;

end;

function TdtmNFCe.ArredondarFloatABNT(ValorNormal: Real; CasasDecimais: Integer): Real;
var
  fFator, fDecimal: Real;
begin
  fFator := IntPower(10, CasasDecimais);
  { A conversão para string e depois para float evita
    erros de arredondamentos indesejáveis. }
  ValorNormal := StrToFloat(FloatToStr(ValorNormal * fFator));
  Result := Int(ValorNormal);
  fDecimal := Frac(ValorNormal);
  if fDecimal >= 0.5 then
  begin
    if ((Frac(Int(ValorNormal) / 2) > 0) and  (fDecimal = 0.5)) or (fDecimal > 0.5) then
      Result := Result + 1
  end;
  Result := Result / fFator;
end;

procedure TdtmNFCe.ConfigurarNFe(config :TNFCeEmpresa);
var
  PathApp: string;
  PathArqDFe: string;
  PathPDF: string;
  PathArquivos: string;
  PathSchemas: string;
  PathTmp: string;



begin
  // caminhos de pastas gerais
  PathApp := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));

  // somente para NFC-e
  PathSchemas := IncludeTrailingPathDelimiter(PathApp + 'NOTA\SCHEMAS');

  // caminhos de pastas especificos por cnpj e comuns aos dois modos de funcionamento
  PathArqDFe      := IncludeTrailingPathDelimiter(PathApp + 'NOTA\DOCUMENTOS');
  PathPDF         := IncludeTrailingPathDelimiter(PathArqDFe + 'PDF');
  PathArquivos    := IncludeTrailingPathDelimiter(PathArqDFe + 'ARQUIVOS');
  PathTmp         := IncludeTrailingPathDelimiter(PathArqDFe + 'TMP');

  ForceDirectories(PathPDF);
  ForceDirectories(PathArquivos);
  ForceDirectories(PathTmp);

  // configuração do ACBRNFE
  ACBrNFe1.Configuracoes.Arquivos.AdicionarLiteral := False;
  ACBrNFe1.Configuracoes.Arquivos.EmissaoPathNFe   := True;
  ACBrNFe1.Configuracoes.Arquivos.SepararPorMes    := True;
  ACBrNFe1.Configuracoes.Arquivos.SepararPorModelo := True;
  ACBrNFe1.Configuracoes.Arquivos.SepararPorCNPJ   := True;
  ACBrNFe1.Configuracoes.Arquivos.Salvar           := True;
  ACBrNFe1.Configuracoes.Arquivos.SalvarEvento     := True;
  ACBrNFe1.Configuracoes.Arquivos.PathNFe          := PathArquivos;
  ACBrNFe1.Configuracoes.Arquivos.PathInu          := PathArquivos;
  ACBrNFe1.Configuracoes.Arquivos.PathEvento       := PathArquivos;
  ACBrNFe1.Configuracoes.Arquivos.PathSalvar       := PathTmp;
  ACBrNFe1.Configuracoes.Arquivos.PathSchemas      := PathSchemas;
  ACBrNFe1.Configuracoes.Arquivos.IniServicos      := PathApp + 'NOTA\ACBrNFeServicos.ini';

  // configurações gerais
  ACBrNFe1.Configuracoes.Geral.ModeloDF := moNFCe;

  // configurações do token
  ACBrNFe1.Configuracoes.Geral.IdCSC        := config.autIdToken;
  ACBrNFe1.Configuracoes.Geral.CSC          := config.autToken;
  ACBrNFe1.Configuracoes.Geral.Salvar       := True;
  ACBrNFe1.Configuracoes.Geral.VersaoDF     := TpcnVersaoDF.ve400;
  ACBrNFe1.Configuracoes.Geral.VersaoQRCode := TpcnVersaoQrCode.veqr200;
  ACBrNFe1.Configuracoes.Geral.FormaEmissao := teNormal;

  // autenticação e assinatura seguras
  ACBrNFe1.Configuracoes.Geral.SSLLib := TSSLLib.libWinCrypt;
  ACBrNFe1.Configuracoes.Geral.SSLCryptLib := TSSLCryptLib.cryWinCrypt;
  ACBrNFe1.Configuracoes.Geral.SSLHttpLib := TSSLHttpLib.httpWinHttp;
  ACBrNFe1.Configuracoes.Geral.SSLXmlSignLib := TSSLXmlSignLib.xsLibXml2;
  ACBrNFe1.SSL.SSLType := TSSLType.LT_TLSv1_2;

  // configurações de timezone
  ACBrNFe1.Configuracoes.WebServices.TimeZoneConf.ModoDeteccao := TTimeZoneModoDeteccao.tzSistema;

  // propriedades para melhorar a aparência dos retornos de validaçã dos schemas
  // %TAGNIVEL%  : Representa o Nivel da TAG; ex: <transp><vol><lacres>
  // %TAG%       : Representa a TAG; ex: <nLacre>
  // %ID%        : Representa a ID da TAG; ex X34
  // %MSG%       : Representa a mensagem de alerta
  // %DESCRICAO% : Representa a Descrição da TAG
  ACBrNFe1.Configuracoes.Geral.ExibirErroSchema := False;
  ACBrNFe1.Configuracoes.Geral.FormatoAlerta    := '[ %TAGNIVEL% %TAG% ] %DESCRICAO% - %MSG%';

  // certificado
  //  ACBrNFe1.Configuracoes.Certificados.Senha := '1234566';
  //  ACBrNFe1.Configuracoes.Certificados.ArquivoPFX  := PathApp + 'certificado.pfx';
  ACBrNFe1.Configuracoes.Certificados.NumeroSerie := config.autCertificado;
  //  ACBrNFe1.Configuracoes.Certificados.DadosPFX := '';

  // configurações do webservice
  ACBrNFe1.Configuracoes.WebServices.UF         := config.endUf;
  ACBrNFe1.Configuracoes.WebServices.Salvar     := True;
  ACBrNFe1.Configuracoes.WebServices.Visualizar := False;

  if config.autAmbiente = 'P' then
    ACBrNFe1.Configuracoes.WebServices.Ambiente  := taHomologacao
  else
    ACBrNFe1.Configuracoes.WebServices.Ambiente  := taHomologacao;

  // proxy de acesso
  ACBrNFe1.Configuracoes.WebServices.ProxyHost := '';
  ACBrNFe1.Configuracoes.WebServices.ProxyPort := '';
  ACBrNFe1.Configuracoes.WebServices.ProxyUser := '';
  ACBrNFe1.Configuracoes.WebServices.ProxyPass := '';

  ACBrNFe1.DANFE.PathPDF := PathPDF;
  ACBrNFe1.DANFE.Sistema := 'MVENDAS';
  ACBrNFe1.DANFE.Logo    := '';
  ACBrNFe1.DANFE.Site    := '';
  ACBrNFe1.DANFE.Email   := 'guto.bajo@gmail.com';
end;

procedure TdtmNFCe.DataModuleCreate(Sender: TObject);
begin
  CoInitialize(nil);
end;

function TdtmNFCe.Enviar: TNFCeRetACBR;
var
  PathTempImpressao: string;
  config : TNFCeEmpresa;
  StrErros :String;
  NumeroLote :string;
  StatusNFCe :Integer;
  retorno : TNFCeRetACBR;
  xml : string;
begin

  retorno := TNFCeRetACBR.Create;

  retorno.chaveDanfe     := '';
  retorno.protocolo      :='';
  retorno.HR_autorizacao := '';
  retorno.DT_Autorizacao := '';
  retorno.lote           := '';
  retorno.autorizou      := false;
  retorno.xml            := '';
  retorno.SituacaoNFCE   := 0;
  retorno.QrCode         := '';
  retorno.nrNota         := 0;
  xml:='';

  if ACBrNFe1.NotasFiscais.Count <= 0 then
  begin
    retorno.Texto := 'nenhuma nota fiscal informada';
    Result := retorno;
    exit;
  end;

  try
    ACBrNFe1.NotasFiscais.Assinar;
  except
    on E: Exception do
    begin
      retorno.Texto := 'Erro de Assinatura: ' + e.Message;
      Result := retorno;
      exit;
    end;
  end;

  try
    ACBrNFe1.NotasFiscais.Validar;
  except
    on E: Exception do
    begin
      retorno.Texto := 'ERRO VALIDAÇÃO: ' +IFThen(
          ACBrNFe1.NotasFiscais.Items[0].Alertas <> '',
          ACBrNFe1.NotasFiscais.Items[0].ErroValidacao,
          ACBrNFe1.NotasFiscais.Items[0].ErroValidacaoCompleto
        );
      retorno.SituacaoNFCE := 998;
      Result := retorno;
      exit;
    end;
  end;

  // validar regras de negocios
//  if not ACBrNFe1.NotasFiscais.ValidarRegrasdeNegocios(StrErros) then
//    raise EFilerError.Create('ERRO REGRAS DE NEGOCIO: ' + StrErros);
//

  try
    PathTempImpressao := ExtractFilePath(ParamStr(0)) + '\impressao\';
    ForceDirectories(PathTempImpressao);

    ACBrPosPrinter1.Porta := PathTempImpressao +'\impressao_' + FormatDateTime('hhmmsszzz', NOW) + '.txt';

    // salvar a nota em um arquivo conhecido somente para efeitos de exemplo
    // na vida real o XML deverá ser gravado no banco de dados ou em pasta de
    // arquivamento e mantido por 5 anos
    ACBrNFe1.NotasFiscais[0].GravarXML(PathNotaFiscalExemplo);

    // opcional imprimir diretamente do servidor, para isso é preciso ter
    // confiurado o impressor
    ACBrNFe1.NotasFiscais.Imprimir;
  Except

  end;

//  omitido para evitar o uso de certificado durante o curso
  NumeroLote := FormatDateTime('yymmddhhmm', NOW);
  try
    if ACBrNFe1.Enviar(NumeroLote, False, True) then
    begin
      StatusNFCe := ACBrNFe1.WebServices.Enviar.cStat;
      retorno.SituacaoNFCE := StatusNFCe;
      retorno.chaveDanfe := ACBrNFe1.NotasFiscais[0].NFe.procNFe.chNFe;
      retorno.protocolo := ACBrNFe1.NotasFiscais[0].NFe.procNFe.nProt;
      retorno.xml :=   ACBrNFe1.NotasFiscais[0].XMLAssinado;
      retorno.QrCode := ACBrNFe1.NotasFiscais[0].NFe.infNFeSupl.qrCode;
      retorno.lote := NumeroLote;
      retorno.nrNota := ACBrNFe1.NotasFiscais[0].NFE.IDE.NNF;

      if ValorInRange(StatusNFCe, [100, 110, 150, 205, 301, 302]) then
      begin
        retorno.autorizou := true;
        retorno.DT_Autorizacao := FormatDateTime('dd/mm/yyyy', Date);
        retorno.HR_autorizacao := FormatDateTime('hh:nn:ss', Now);
        retorno.recibo         := ACBrNFe1.WebServices.Recibo.NFeRetorno.nRec;
        retorno.Texto          := ACBrNFe1.WebServices.Enviar.cStat.ToString + ' - ' +
                                  ACBrNFe1.WebServices.Enviar.xMotivo;
      end
      else
      begin
       retorno.Texto := ACBrNFe1.WebServices.Enviar.cStat.ToString + ' - ' + ACBrNFe1.WebServices.Enviar.xMotivo;
       retorno.SituacaoNFCE := ACBrNFe1.WebServices.Enviar.cStat;
       Result := retorno;
       exit;
      end;
    end
    else
    begin
      retorno.Texto :='Erro ao enviar: %d - %s'+ACBrNFe1.WebServices.Enviar.cStat.ToString+
      ACBrNFe1.WebServices.Enviar.xMotivo;
      retorno.SituacaoNFCE := ACBrNFe1.WebServices.Enviar.cStat;
      Result := retorno;
      exit;
    end;
  Except on e:Exception do
    begin
      if retorno.SituacaoNFCE = 0 then
      begin
        xml:= ACBrNFe1.NotasFiscais[0].XMLAssinado;
        NumeroLote := FormatDateTime('yymmddhhmm', NOW);
        ACBrNFe1.NotasFiscais.Clear;
        ACBrNFe1.NotasFiscais.LoadFromString(xml);
        ACBrNFe1.NotasFiscais.Items[0].NFe.Ide.tpEmis := tpcntipoEmissao.teoffline;
        ACBrNFe1.NotasFiscais.Items[0].NFe.Ide.xJust := 'SEM CONEXAO COM O SERVIDOR';
        ACBrNFe1.NotasFiscais.Items[0].NFe.Ide.dhCont := now;
        ACBrNFe1.NotasFiscais.Items[0].NFe.Ide.tpImp := tiNFCe;
        ACBrNFe1.NotasFiscais.GerarNFe;
        ACBrNFe1.NotasFiscais.Assinar;
        ACBrNFe1.NotasFiscais.Validar;

        retorno.SituacaoNFCE :=  ACBrNFe1.WebServices.Enviar.cStat;
        retorno.chaveDanfe := StringReplace(upperCase( ACBrNFe1.NotasFiscais[0].NFe.infnfe.ID), 'NFE', '', [rfReplaceAll]);
        retorno.protocolo := '';
        retorno.xml :=   xml;
        retorno.QrCode := ACBrNFe1.NotasFiscais[0].NFe.infnfeSupl.qrcode;
        retorno.lote := '';
        retorno.nrNota :=0;
        retorno.autorizou := true;
        retorno.Texto := 'EMITIDO OFFLINE';
      end
      ELSE
      BEGIN
        retorno.Texto := ACBrNFe1.WebServices.Enviar.cStat.ToString + ' - ' + ACBrNFe1.WebServices.Enviar.xMotivo;
              Result := retorno;
              exit;
      END;
    end;
  end;
  result := retorno;
end;

procedure TdtmNFCe.PreencherNFCe(Conexao :TFDConnection; ANFCe: TNFCe;config :TNFCeEmpresa);
var
  ONFe: TNFe;
  OPagto: TpagCollectionItem;
  OItemNota: TDetCollectionItem;
  NFCeItem: TNFCeItem;
  NFCEItemPagamento : TNFCePagto;
  NFCEItemTEF: TNFCeTEF;
  PisCofins: TPisCofins;
  I: Integer;
  ValorTotalBCICMS,
  ValorTotalVLICMS,
  ValorTotalVLPIS,
  ValorTotalVLCOFINS,
  ValorTotalBCPIS,
  ValorTotalBCCOFINS,
  ValorTotalDesconto,



  ValorTotalNF: double;
  ok :Boolean;
  url:String;

  Buffer : TStringList;

begin
  //Zerar as variavéis
  ValorTotalBCICMS   :=0;
  ValorTotalVLICMS   :=0;
  ValorTotalBCCOFINS :=0;
  ValorTotalVLCOFINS :=0;
  ValorTotalBCPIS    :=0;
  ValorTotalVLPIS    :=0;
  ValorTotalNF       :=0;
  ValorTotalDesconto :=0;


  Buffer := TStringList.Create;
  self.ConfigurarNFe(config);
  ACBrNFe1.NotasFiscais.Clear;

  ONFe := ACBrNFe1.NotasFiscais.Add.NFe;

  ONFe.Ide.tpAmb     := ACBrNFe1.Configuracoes.WebServices.Ambiente;
  ONFe.Ide.verProc   := '1.0.0.0';
  ONFe.Ide.tpImp     := tiNFCe;

  // Identificação da nota fiscal eletrônica
  ONFe.Ide.modelo    := 65;
  ONFe.Ide.tpNF      := tnSaida;
//  if vContigencia then
//  begin
//    ONFe.Ide.tpEmis    := teContingencia;
//    ONFe.Ide.dhCont := NOW;
//    ONFe.Ide.xJust  := 'SEM COMUNICACAO SEFAZ';
//    ACBrNFe1.Configuracoes.Geral.FormaEmissao := teOffLine;
//  end
//  else
//  begin
  ONFe.Ide.tpEmis    := teNormal;
//  end;
  ONFe.Ide.finNFe      := fnNormal;
  ONFe.Ide.indFinal    := cfConsumidorFinal;
  ONFe.Ide.idDest      := doInterna;
  ONFe.Ide.nNF         := ANFCe.nrNota;
  oNfe.Ide.indPres     := TpcnPresencaComprador.pcPresencial;
  oNfe.Ide.indIntermed := iiOperacaoSemIntermediador;
  ONFe.Ide.serie       := ANFCe.nrSerie;
  ONFe.Ide.natOp       := 'VENDA A CONSUMIDOR FINAL';
  ONFe.Ide.dEmi        := NOW;
  ONFe.Ide.dSaiEnt     := ONFe.Ide.dEmi;
  ONFe.Ide.cUF         := UFtoCUF(config.endUf);
  ONFe.Ide.cMunFG      := config.endIbge.ToInteger;



  // deixar o acbr gerar um numero randomico conforme manual da nfe
  ONFe.Ide.cNF := 0;

  // entrar em contingência quando configurado
  //ONFe.Ide.tpEmis := teNormal;

  // identificação do EMITENTE
  ONFe.Emit.xNome             := config.nmEmpresa;
  ONFe.Emit.xFant             := config.nmEmpresa;
  ONFe.Emit.CNPJCPF           := config.cnpj;
  ONFe.Emit.IE                := config.ie;
  ONFe.Emit.IEST              := '';
  ONFe.Emit.CNAE              := '';
  ONFe.Emit.EnderEmit.fone    := config.fone;
  ONFe.Emit.EnderEmit.xLgr    := config.endEndereco;
  ONFe.Emit.EnderEmit.nro     := config.endNumero;
  ONFe.Emit.EnderEmit.xCpl    := config.endComplemento;
  ONFe.Emit.EnderEmit.xBairro := config.endBairro;
  ONFe.Emit.EnderEmit.xMun    := config.endCidade;
  ONFe.Emit.EnderEmit.cMun    := config.endIbge.ToInteger;
  ONFe.Emit.EnderEmit.UF      := config.endUf;
  ONFe.Emit.EnderEmit.CEP     := strToInt(config.endCep);
  ONFe.Emit.enderEmit.cPais   := 1058;
  ONFe.Emit.enderEmit.xPais   := 'BRASIL';
  case config.regime of
    0: ONFe.Emit.CRT := crtRegimeNormal;
    1: ONFe.Emit.CRT := crtRegimeNormal;
    2: ONFe.Emit.CRT := crtSimplesNacional;
  end;

  // informações do destinatário da nota fiscal
  ONFe.Dest.CNPJCPF     := ANFCe.cpf;
  ONFe.Dest.xNome       := ANFCe.nmCliente;
  ONFe.Dest.indIEDest   := inNaoContribuinte;

  I := 0;
  for NFCeItem in ANFCe.Itens do
  begin
    Inc(I);
    OItemNota := ONFe.Det.Add;

    OItemNota.Prod.nItem    := I;
    OItemNota.Prod.cProd    := NFCeItem.Cdbarras;
    OItemNota.Prod.xProd    := NFCeItem.descricao;
    OItemNota.Prod.NCM      := NFCeItem.ncm;
    OItemNota.Prod.CFOP     := NFCeItem.Cfop.ToString;
    OItemNota.Prod.CEST     := NFCeItem.Cest;
    OItemNota.Prod.cBenef   := '';
    OItemNota.Prod.cEAN     := 'SEM GTIN';
    OItemNota.Prod.cEANTrib := 'SEM GTIN';

    if Length(NFCeItem.gtin) >= 8 then
    begin
      if MP_CalculaCodBarras(NFCeItem.gtin,Length(NFCeItem.gtin) -1) = NFCeItem.gtin then
      begin
        OItemNota.Prod.cEAN     := NFCeItem.gtin;
        OItemNota.Prod.cEANTrib :=  NFCeItem.gtin;
      end
      else
      begin
        OItemNota.Prod.cEAN     := 'SEM GTIN';
        OItemNota.Prod.cEANTrib := 'SEM GTIN';
      end;
    end;

//    if (Length(NFCeItem.Codigo_gtin) > 3) and (Length(NFCeItem.Codigo_gtin) < 15) then
//    begin
//      OItemNota.Prod.cEAN     := NFCeItem.Codigo_gtin;
//      OItemNota.Prod.cEANTrib := NFCeItem.Codigo_gtin;
//    end
//    else
//    begin
//      OItemNota.Prod.cEAN     := 'SEM GTIN';
//      OItemNota.Prod.cEANTrib := 'SEM GTIN';
//    end;

    OItemNota.Prod.uCom     := NFCeItem.un;
    OItemNota.Prod.qCom     := NFCeItem.quantidade;
    OItemNota.Prod.vUnCom   := NFCeItem.vlBruto;
    OItemNota.Prod.vProd    := NFCeItem.quantidade * NFCeItem.vlBruto;
    OItemNota.Prod.vDesc    := NFCeItem.vlDesconto + NFCeItem.vlDescItem;
	  ValorTotalDesconto      := ValorTotalDesconto + OItemNota.Prod.vDesc;


    OItemNota.Prod.uTrib    := NFCeItem.un;
    OItemNota.Prod.qTrib    := NFCeItem.quantidade;
    OItemNota.Prod.vUnTrib  := NFCeItem.vlBruto;
    ValorTotalNF := ValorTotalNF + OItemNota.Prod.vProd;

    OItemNota.Imposto.ICMS.orig := TpcnOrigemMercadoria.oeNacional;

    // ICMS ********************************************************
    if ONFe.Emit.CRT = crtRegimeNormal then
    begin
      OItemNota.Imposto.ICMS.CST := StrToCSTICMS(ok, Copy(NFCeItem.cstIcms, 2, 2));

      if NFCeItem.aliqIcms > 0 then
      begin
        OItemNota.Imposto.ICMS.vBC   := ArredondarFloatABNT(NFCeItem.vlBcIcms, 2);
        OItemNota.Imposto.ICMS.pICMS := NFCeItem.aliqIcms;
        OItemNota.Imposto.ICMS.vICMS := ArredondarFloatABNT(NFCeItem.vlIcms, 2);
        ValorTotalVLICMS             := ValorTotalVLICMS + ArredondarFloatABNT(NFCeItem.vlIcms, 2);
        ValorTotalBCICMS             := ValorTotalBCICMS + ArredondarFloatABNT(NFCeItem.vlBcIcms, 2);
      end;
    end
    else
    begin //Simples nacional
      OItemNota.Imposto.ICMS.CSOSN := StrToCSOSNIcms(ok, Copy(NFCeItem.cstIcms, 2, 2));
      OItemNota.Imposto.ICMS.vBC   := 0;
      OItemNota.Imposto.ICMS.pICMS := 0;
      OItemNota.Imposto.ICMS.vICMS := 0;
      ValorTotalVLICMS             := ValorTotalVLICMS + 0;
      ValorTotalBCICMS             := ValorTotalBCICMS + 0;
    end;

    OItemNota.Imposto.ICMS.pCredSN     := 0.00;
    OItemNota.Imposto.ICMS.vCredICMSSN := 0.00;

    {ICMS EFETIVO}
    if (Copy(NFCeItem.cstIcms, 2, 2) = '60') then
    begin
      OItemNota.Imposto.ICMS.pRedBCEfet := 0;
      OItemNota.Imposto.ICMS.vBCEfet    := 0;
      OItemNota.Imposto.ICMS.pICMSEfet  := 0;
      OItemNota.Imposto.ICMS.vICMSEfet  := 0;
    end;

    {PIS / COFINS}
    PisCofins := fDadosPisCofins(NFCeItem.cstPisCofins.ToInteger, NFCeItem.cstPisCofins.ToInteger, NFCeItem.aliqPis,
    NFCeItem.aliqCofins, NFCeItem.vlBcPis, NFCeItem.vlBcCofins,
    NFCeItem.vlPis, NFCeItem.vlCofins);

    // PIS *******************************************************
    OItemNota.Imposto.PIS.CST       := StrToCSTPIS(ok,  IntToStr(PisCofins.cst_pis));
    OItemNota.Imposto.PIS.vBC       := PisCofins.base_pis;
    OItemNota.Imposto.PIS.pPIS      := PisCofins.aliq_pis;
    OItemNota.Imposto.PIS.vPIS      := PisCofins.vl_pis;
    OItemNota.Imposto.PIS.qBCProd   := 0; //Não será utilizado (Calculo Aliq Específica)
    OItemNota.Imposto.PIS.vAliqProd := 0; //Não será utilizado (Calculo Aliq Específica)
    ValorTotalVLPIS                 :=  ValorTotalVLPIS +  OItemNota.Imposto.PIS.vPIS;
    ValorTotalBCPIS                 :=  ValorTotalBCPIS +  OItemNota.Imposto.PIS.vBC;

    // COFINS ******************************************************
    OItemNota.Imposto.COFINS.CST       := StrToCSTCOFINS(ok,  IntToStr(PisCofins.cst_cofins));
    OItemNota.Imposto.COFINS.vBC       := PisCofins.base_cofins;
    OItemNota.Imposto.COFINS.pCOFINS   := PisCofins.aliq_cofins;
    OItemNota.Imposto.COFINS.vCOFINS   := PisCofins.vl_cofins;
    OItemNota.Imposto.COFINS.qBCProd   := 0; //Não será utilizado (Calculo Aliq Específica)
    OItemNota.Imposto.COFINS.vAliqProd := 0; //Não será utilizado (Calculo Aliq Específica)
    ValorTotalVLCOFINS                 :=  ValorTotalVLCOFINS +  OItemNota.Imposto.COFINS.vCOFINS;
    ValorTotalBCCOFINS                 := ValorTotalBCCOFINS +   OItemNota.Imposto.COFINS.vBC;
  end;

  // pagamento
  I := 0;
  for NFCEItemPagamento in ANFCe.Pagamentos do
  begin
    Inc(I);
    OPagto := ONFe.pag.Add;
    case NFCEItemPagamento.Tipo of
      1:  OPagto.tPag      := TpcnFormaPagamento.fpDinheiro;
      2:  OPagto.tPag      := TpcnFormaPagamento.fpCheque;
      3:  OPagto.tPag      := TpcnFormaPagamento.fpCartaoCredito;
      4:  OPagto.tPag      := TpcnFormaPagamento.fpCartaoDebito;
      5:  OPagto.tPag      := TpcnFormaPagamento.fpCreditoLoja;
      10: OPagto.tPag      := TpcnFormaPagamento.fpValeAlimentacao;
      11: OPagto.tPag      := TpcnFormaPagamento.fpValeRefeicao;
      12: OPagto.tPag      := TpcnFormaPagamento.fpValePresente;
      13: OPagto.tPag      := TpcnFormaPagamento.fpValeCombustivel;
      15: OPagto.tPag      := TpcnFormaPagamento.fpBoletoBancario;
      90: OPagto.tPag      := TpcnFormaPagamento.fpSemPagamento;
      99: OPagto.tPag      := TpcnFormaPagamento.fpOutro;
    end;

    OPagto.vPag      := NFCEItemPagamento.VlTotal;
    OPagto.tpIntegra := tiPagNaoIntegrado;

    if ANFCe.TransacoesTEF <> nil then
    begin
      for NFCEItemTEF in ANFCe.TransacoesTEF do
      begin
        if NFCEItemTEF.Nr_documento = NFCEItemPagamento.NrDocumento then
        begin
          if NFCEItemTEF.bandeira = '' then
          begin
             Buffer.Text:= NFCEItemTEF.Obs;
             NFCEItemTEF.bandeira := Trim(Buffer.Strings[2]);
          end;

          if NFCEItemTEF.bandeira.Contains('VISA') then
            OPagto.tBand := TpcnBandeiraCartao.bcVisa
          else if NFCEItemTEF.bandeira.Contains('MASTER') THEN
            OPagto.tBand := TpcnBandeiraCartao.bcMasterCard
          else if NFCEItemTEF.bandeira.Contains('AMERIC') THEN
            OPagto.tBand := TpcnBandeiraCartao.bcAmericanExpress
          else if NFCEItemTEF.bandeira.Contains('SORO') THEN
            OPagto.tBand := TpcnBandeiraCartao.bcSorocred
          else if NFCEItemTEF.bandeira.Contains('DIN') THEN
            OPagto.tBand := TpcnBandeiraCartao.bcDinersClub
          else if NFCEItemTEF.bandeira.Contains('ELO') THEN
            OPagto.tBand := TpcnBandeiraCartao.bcElo
          else if NFCEItemTEF.bandeira.Contains('HIPE') THEN
            OPagto.tBand := TpcnBandeiraCartao.bcHipercard
          else if NFCEItemTEF.bandeira.Contains('AURA') THEN
            OPagto.tBand := TpcnBandeiraCartao.bcAura
          else if NFCEItemTEF.bandeira.Contains('CABAL') THEN
            OPagto.tBand := TpcnBandeiraCartao.bcCabal
          else
            OPagto.tBand := TpcnBandeiraCartao.bcOutros;

          OPagto.CNPJ  := fBuscarCNPJAdministradora(Conexao,NFCEItemTEF.administrador);//'';//'02727867000179';
          OPagto.cAut  := NFCEItemTEF.Nr_transacao;
        end;
        OPagto.tpIntegra := tiPagIntegrado;
      end;
    end;

    if OPagto.tPag in [TpcnFormaPagamento.fpDinheiro, TpcnFormaPagamento.fpCartaoDebito] then
     OPagto.indPag := TpcnIndicadorPagamento.ipVista
    else
      OPagto.indPag := TpcnIndicadorPagamento.ipPrazo;
  end;

  // totais da nota fiscal
  ONFe.Total.ICMSTot.vBC      := ValorTotalBCICMS;
  ONFe.Total.ICMSTot.vICMS    := ValorTotalVLICMS;
  ONFe.Total.ICMSTot.vBCST    := 0.00;
  ONFe.Total.ICMSTot.vST      := 0.00;
  ONFe.Total.ICMSTot.vProd    := ValorTotalNF;
  ONFe.Total.ICMSTot.vFrete   := 0.00; //Não existe no Nfc-e
  ONFe.Total.ICMSTot.vSeg     := 0.00; //Não existe no Nfc-e
  ONFe.Total.ICMSTot.vDesc    := ValorTotalDesconto;
  ONFe.Total.ICMSTot.vII      := 0.00;
  ONFe.Total.ICMSTot.vIPI     := 0.00;
  ONFe.Total.ICMSTot.vPIS     := ValorTotalVLPIS;
  ONFe.Total.ICMSTot.vCOFINS  := ValorTotalVLCOFINS;
  ONFe.Total.ICMSTot.vOutro   := 0.00; //Não existe no Nfc-e
  ONFe.Total.ICMSTot.vFCP     := 0.00;
  ONFe.Total.ICMSTot.vNF      := ValorTotalNF-ValorTotalDesconto;
  ONFe.Total.ICMSTot.vTotTrib := 0.00;

  // serviços (não existe na NFC-e)
  ONFe.Total.ISSQNtot.vServ   := 0.00;
  ONFe.Total.ISSQNTot.vBC     := 0.00;
  ONFe.Total.ISSQNTot.vISS    := 0.00;
  ONFe.Total.ISSQNTot.vPIS    := 0.00;
  ONFe.Total.ISSQNTot.vCOFINS := 0.00;

  // transporte (frete), no caso de NFC-e não pode ter frete
  ONFe.Transp.modFrete := mfSemFrete;

  onfe.infRespTec.CNPJ:='87.636.817/0001-39';
  onfe.infRespTec.xContato:='Gustavo Schwarz';
  onfe.infRespTec.email:='guto.bajo@gmail.com';
  onfe.infRespTec.fone:='49991538905';

  url := ACBrNFe1.GetURLQRCode(ONFe.ide.cUF,
                               ONFe.ide.tpAmb,
                               copy(ONFe.infnfe.ID,4,44),
                               ONFe.dest.CNPJCPF,
                               ONFe.ide.dEmi,
                               ONFe.total.ICMSTot.vNF,
                               ONFe.Total.ICMSTot.vICMS,
                               ONFe.procNFe.digVal,
                               4);
  ONFe.infNFeSupl.qrCode := url;

end;

function TdtmNFCe.GerarPDF(xml :string; config : TNFCeEmpresa): string;
var
  OldCfgDANFE: TACBrDFeDANFeReport;
begin

  OldCfgDANFE := ACBrNFe1.DANFE;
  try
    ACBrNFe1.DANFE := ACBrNFeDANFCeFortes1;
    Self.ConfigurarNFe(config);

    ACBrNFe1.NotasFiscais.Clear;
    ACBrNFe1.NotasFiscais.LoadFromString(XML);
    ACBrNFe1.NotasFiscais.ImprimirPDF;

    Result :=
      ACBrNFe1.DANFE.PathPDF +
      ACBrUtil.OnlyNumber(ACBrNFe1.NotasFiscais[0].NFe.infNFe.ID) +
      '-nfe.pdf';

    if not FileExists(Result) then
      raise Exception.Create('Arquivo PDF não encontrado no servidor!');
  finally
    ACBrNFe1.DANFE := OldCfgDANFE;
  end;
end;

function TdtmNFCe.GerarPDFCfe(xml,nrDocumento, idDispositivo :String): String;
var
  cfe :Tcfe;
  caminho : String;
begin

  caminho := ExtractFilePath(ParamStr(0)) + '\Documentos\CFe\' + idDispositivo + '\' +
                 IntToStr(YearOf(Date)) + '\' +
                 FormatFloat('00',MonthOf(Date)) + '\' +
                 FormatFloat('00',DayOf(Date)) + '\' ;


  ForceDirectories(Caminho);

  try
    cfe := tcfe.Create;
    cfe.SetXMLString(xml);


    sat.Filtro  := fiPDF;
    sat.PathPDF := Caminho;
    sat.NomeDocumento := nrDocumento + '.PDF';
    sat.ImprimirExtrato(cfe);
  finally
    cfe.Free;
  end;

  result := caminho + nrDocumento + '.PDF';

end;

function TdtmNFCe.GerarXML(numero, serie: integer): string;
begin
  if not FilesExists(PathNotaFiscalExemplo) then
    raise Exception.Create('Arquivo XML de nota fiscal não encontrado');

  ACBrNFe1.NotasFiscais.Clear;
  ACBrNFe1.NotasFiscais.LoadFromFile(PathNotaFiscalExemplo);

  Result := ACBrNFe1.NotasFiscais[0].XML;
end;


end.

