unit UNFCeClass;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,

  MVCFramework.Serializer.Commons;

type
  [MVCNameCaseAttribute(ncLowerCase)]
  TNFCeEmpresa = class
  private
    Fid: integer;
    FnmEmpresa: string;
    FendEndereco: string;
    FendBairro: string;
    FendCidade: string;
    FendUf: string;
    FendCep: string;
    FendNumero: string;
    FendComplemento: string;
    FendIbge: string;
    Ffone: string;
    Fcnpj: string;
    Fie: string;
    Fim: string;
    Femail: string;
    FautCertificado: string;
    FautCsc: string;
    FautToken: string;
    FautIdToken: string;
    FautAmbiente: string;
    Fregime: integer; // 0-PRESUMIDO   1-REAL   2-SIMPLES

  public
    function AsJsonString: String;
    property id: integer read Fid write Fid;
    property nmEmpresa: string read FnmEmpresa write FnmEmpresa;
    property endEndereco: string read FendEndereco write FendEndereco;
    property endBairro: string read FendBairro write FendBairro;
    property endCidade: string read FendCidade write FendCidade;
    property endUf: string read FendUf write FendUf;
    property endCep: string read FendCep write FendCep;
    property endNumero: string read FendNumero write FendNumero;
    property endComplemento: string read FendComplemento write FendComplemento;
    property endIbge: string read FendIbge write FendIbge;
    property fone: string read Ffone write Ffone;
    property cnpj: string read Fcnpj write Fcnpj;
    property ie: string read Fie write Fie;
    property im: string read Fim write Fim;
    property email: string read Femail write Femail;
    property autCertificado: string read FautCertificado write FautCertificado;
    property autCsc: string read FautCsc write FautCsc;
    property autToken: string read FautToken write FautToken;
    property autIdToken: string read FautIdToken write FautIdToken;
    property autAmbiente: string read FautAmbiente write FautAmbiente;
    property regime: integer read Fregime write Fregime;
  end;

 type
  [MVCNameCaseAttribute(ncLowerCase)]
  TNFCeRetACBR= class
  private
    FChaveDoc              :string;
    fNrDocumentoServidor   :String;
    FNrNota                :integer;
    FchaveDanfe            :String;
    Fxml                   :STRING;
    Fprotocolo             :String;
    Flote                  :string;
    Frecibo                :string;
    FHR_autorizacao        :String;
    FDT_Autorizacao        :string;
    Fautorizou             :boolean;
    FTexto                 :string;
    FSituacaoNFCE          :Integer;
    FQrCode                :String;

  public
    function AsJsonString: String;

    property chaveDanfe  :string read FchaveDanfe write FchaveDanfe;
    property ChaveDoc  :string read FChaveDoc write FChaveDoc;
    property xml  :string read Fxml write Fxml;
    property QrCode  :String read fQrcode write fQrcode;
    property protocolo  :string read Fprotocolo write Fprotocolo;
    property lote  :string read Flote write Flote;
    property recibo  :string read Frecibo write Frecibo;
    property HR_autorizacao  :string read FHR_autorizacao write FHR_autorizacao;
    property Texto  :string read FTexto     write FTexto;
    property autorizou :boolean read  Fautorizou write Fautorizou;
    property SituacaoNFCE : integer read FSituacaoNFCE write FSituacaoNFCE;
    property DT_Autorizacao : String read FDT_Autorizacao write FDT_Autorizacao;
    property nrNota       :integer read FNrNota write FNrNota;
    property NrDocumentoServidor   :String read fNrDocumentoServidor write fNrDocumentoServidor;

  end;

type
  [MVCNameCaseAttribute(ncLowerCase)]
  TNFCeCancNFCE = class
  private
    FchaveDoc        :string;
    Fnr_documentoRet :INTEGER;
    Fnr_documento    :INTEGER;
    Fxml             :STRING;
    FchaveDanfe      :String;
    Flote            :String;
    Fprotocolo       :String;
    FprotocoloCanc   :String;
    FJustificativa   :String;
    FResposta        :String;
    FIdDispositivo   :String;
  public
    function AsJsonString: String;
    property chaveDoc :string read FchaveDoc write FchaveDoc;
    property Nr_documentoRet  :integer read Fnr_documentoRet write FNr_documentoRet;
    property Nr_documento  :integer read Fnr_documento write FNr_documento;
    property xml  :string read Fxml write Fxml;
    property chaveDanfe  :string read FchaveDanfe write FchaveDanfe;
    property lote  :string read Flote write FLote;
    property protocolo :string read Fprotocolo write Fprotocolo;
    property protocoloCanc :string read FprotocoloCanc write FprotocoloCanc;
    property Justificativa :string read FJustificativa write FJustificativa;
    property Resposta  :string read FResposta  write FResposta;
    property idDispositivo  :string read FIdDispositivo  write FIdDispositivo;
  end;

type
  [MVCNameCaseAttribute(ncLowerCase)]
  TNFCeItem = class
  private
    FnrDocumento: INTEGER;
    FnrSequencia: INTEGER;
    FcdProduto: string;
    Fdescricao: string;
    Fquantidade: Double;
    FvlBruto: currency;
    FpcDesconto: currency;
    FvlLiquido: currency;
    FvlTotal: currency;
    FpesoLiquido: Double;
    Fcancelado: INTEGER;
    FcstIcms: string;
    FaliqIcms: currency;
    FvlBcIcms: currency;
    FvlIcms: currency;
    Fun: string;
    FcdBarras: string;
    Fcfop: INTEGER;
    FaliqPis: currency;
    FvlVcPis: currency;
    FvlPis: currency;
    FaliqCofins: currency;
    FvlBcCofins: currency;
    FvlBcPis: currency;
    FvlCofins: currency;
    FcstPisCofins: string;
    FnatReceita: INTEGER;
    FvlDesconto: currency;
    FvlDescItem: currency;
    FvlImpostoAprox: currency;
    Fcest: string;
    FStatus: INTEGER;
    Fcbenef: INTEGER;
    FvlBaseFcp: currency;
    FaliqFcp: currency;
    FvlFcp: currency;
    Fncm: string;
    Fgtin: string;
  public
    property nrDocumento: integer read FnrDocumento write FnrDocumento;
    property nrSequencia: integer read FnrSequencia write FnrSequencia;
    property cdProduto: string read FcdProduto write FcdProduto;
    property descricao: string read Fdescricao write Fdescricao;
    property quantidade: Double read Fquantidade write Fquantidade;
    property vlBruto: currency read FvlBruto write FvlBruto;
    property pcDesconto: currency read FpcDesconto write FpcDesconto;
    property vlLiquido: currency read FvlLiquido write FvlLiquido;
    property vlTotal: currency read FvlTotal write FvlTotal;
    property pesoLiquido: Double read FpesoLiquido write FpesoLiquido;
    property cancelado: integer read Fcancelado write Fcancelado;
    property cstIcms: string read FcstIcms write FcstIcms;
    property aliqIcms: currency read FaliqIcms write FaliqIcms;
    property vlBcIcms: currency read FvlBcIcms write FvlBcIcms;
    property vlIcms: currency read FvlIcms write FvlIcms;
    property un: string read Fun write Fun;
    property cdBarras: string read FcdBarras write FcdBarras;
    property cfop: integer read Fcfop write Fcfop;
    property aliqPis: currency read FaliqPis write FaliqPis;
    property vlVcPis: currency read FvlVcPis write FvlVcPis;
    property vlPis: currency read FvlPis write FvlPis;
    property aliqCofins: currency read FaliqCofins write FaliqCofins;
    property vlBcCofins: currency read FvlBcCofins write FvlBcCofins;
    property vlBcPis: currency read FvlBcPis write FvlBcPis;
    property vlCofins: currency read FvlCofins write FvlCofins;
    property cstPisCofins: string read FcstPisCofins write FcstPisCofins;
    property natReceita: integer read FnatReceita write FnatReceita;
    property vlDesconto: currency read FvlDesconto write FvlDesconto;
    property vlDescItem: currency read FvlDescItem write FvlDescItem;
    property vlImpostoAprox: currency read FvlImpostoAprox write FvlImpostoAprox;
    property cest: string read Fcest write Fcest;
    property status: integer read FStatus write FStatus;
    property cbenef: integer read Fcbenef write Fcbenef;
    property vlBaseFcp: currency read FvlBaseFcp write FvlBaseFcp;
    property aliqFcp: currency read FaliqFcp write FaliqFcp;
    property vlFcp: currency read FvlFcp write FvlFcp;
    property ncm: string read Fncm write Fncm;
    property gtin: string read Fgtin write Fgtin;
  end;

type
  [MVCNameCaseAttribute(ncLowerCase)]
  TNFCeTitulo= class
  private
	FCd_filial                :INTEGER;
	FCd_tipo_conta            :INTEGER;
	FCd_clifor                :INTEGER;
	FNr_titulo                :STRING;
	FParcela                  :INTEGER;
	FDt_emissao               :STRING;
	FDt_inclusao              :STRING;
	FDt_vcto_ori              :STRING;
	FDt_vcto                  :STRING;
	FDt_ult_pgto              :STRING;
	FCd_banco_ori             :INTEGER;
	FCd_banco                 :INTEGER;
	FCd_tipocobr_ori          :INTEGER;
	FCd_tipocobr              :INTEGER;
	FCd_vendedor              :INTEGER;
	FFl_prev_realizado        :STRING;
	FVl_comissao              :CURRENCY;
	FVl_nominal               :CURRENCY;
	FVl_juros                 :CURRENCY;
	FVl_baixas_nominal        :CURRENCY;
	FVl_descontos             :CURRENCY;
	FVl_saldo                 :CURRENCY;
	FCd_caixa                 :INTEGER;
	FDt_atz                   :STRING;
	FNr_nf_ecf                :INTEGER;
	FPrazo_parcela            :INTEGER;
	FPc_parcela               :CURRENCY;
	FCd_conta                 :INTEGER;
	FVl_acrescimo             :CURRENCY;
	FFl_reparcelado           :STRING;
	FPc_parcela_total         :CURRENCY;
	FNr_documento             :INTEGER;
	FObs                      :STRING;
	FNr_sequencial            :INTEGER;
	FCupom_tipo               :STRING;
	FFl_excluido              :STRING;
	FMotivo_exclusao          :STRING;
	FCd_convenio              :INTEGER;
	FEmissao                  :STRING;
	FCd_funcionarioexclusao   :INTEGER;
	FDt_exclusao              :STRING;
	FId_sincronizado          :INTEGER;
	FId_codigo_matriz         :INTEGER;
	FNr_cupom                 :INTEGER;


  public
  property  Cd_filial               :INTEGER    READ    FCd_filial     WRITE    FCd_filial;
	property  Cd_tipo_conta           :INTEGER    READ    FCd_tipo_conta     WRITE    FCd_tipo_conta;
	property  Cd_clifor               :INTEGER    READ    FCd_clifor     WRITE    FCd_clifor;
	property  Nr_titulo               :STRING    READ    FNr_titulo     WRITE    FNr_titulo;
	property  Parcela                 :INTEGER    READ    FParcela     WRITE    FParcela;
	property  Dt_emissao              :STRING    READ    FDt_emissao     WRITE    FDt_emissao;
	property  Dt_inclusao             :STRING    READ    FDt_inclusao     WRITE    FDt_inclusao;
	property  Dt_vcto_ori             :STRING    READ    FDt_vcto_ori     WRITE    FDt_vcto_ori;
	property  Dt_vcto                 :STRING    READ    FDt_vcto     WRITE    FDt_vcto;
	property  Dt_ult_pgto             :STRING    READ    FDt_ult_pgto     WRITE    FDt_ult_pgto;
	property  Cd_banco_ori            :INTEGER    READ    FCd_banco_ori     WRITE    FCd_banco_ori;
	property  Cd_banco                :INTEGER    READ    FCd_banco     WRITE    FCd_banco;
	property  Cd_tipocobr_ori         :INTEGER    READ    FCd_tipocobr_ori     WRITE    FCd_tipocobr_ori;
	property  Cd_tipocobr             :INTEGER    READ    FCd_tipocobr     WRITE    FCd_tipocobr;
	property  Cd_vendedor             :INTEGER    READ    FCd_vendedor     WRITE    FCd_vendedor;
	property  Fl_prev_realizado       :STRING    READ    FFl_prev_realizado     WRITE    FFl_prev_realizado;
	property  Vl_comissao             :CURRENCY    READ    FVl_comissao     WRITE    FVl_comissao;
	property  Vl_nominal              :CURRENCY    READ    FVl_nominal     WRITE    FVl_nominal;
	property  Vl_juros                :CURRENCY    READ    FVl_juros     WRITE    FVl_juros;
	property  Vl_baixas_nominal       :CURRENCY    READ    FVl_baixas_nominal     WRITE    FVl_baixas_nominal;
	property  Vl_descontos            :CURRENCY    READ    FVl_descontos     WRITE    FVl_descontos;
	property  Vl_saldo                :CURRENCY    READ    FVl_saldo     WRITE    FVl_saldo;
	property  Cd_caixa                :INTEGER    READ    FCd_caixa     WRITE    FCd_caixa;
	property  Dt_atz                  :STRING    READ    FDt_atz     WRITE    FDt_atz;
	property  Nr_nf_ecf               :INTEGER    READ    FNr_nf_ecf     WRITE    FNr_nf_ecf;
	property  Prazo_parcela           :INTEGER    READ    FPrazo_parcela     WRITE    FPrazo_parcela;
	property  Pc_parcela              :CURRENCY    READ    FPc_parcela     WRITE    FPc_parcela;
	property  Cd_conta                :INTEGER    READ    FCd_conta     WRITE    FCd_conta;
	property  Vl_acrescimo            :CURRENCY    READ    FVl_acrescimo     WRITE    FVl_acrescimo;
	property  Fl_reparcelado          :STRING    READ    FFl_reparcelado     WRITE    FFl_reparcelado;
	property  Pc_parcela_total        :CURRENCY    READ    FPc_parcela_total     WRITE    FPc_parcela_total;
	property  Nr_documento            :INTEGER    READ    FNr_documento     WRITE    FNr_documento;
	property  Obs                     :STRING    READ    FObs     WRITE    FObs;
	property  Nr_sequencial           :INTEGER    READ    FNr_sequencial     WRITE    FNr_sequencial;
	property  Cupom_tipo              :STRING    READ    FCupom_tipo     WRITE    FCupom_tipo;
	property  Fl_excluido             :STRING    READ    FFl_excluido     WRITE    FFl_excluido;
	property  Motivo_exclusao         :STRING    READ    FMotivo_exclusao     WRITE    FMotivo_exclusao;
	property  Cd_convenio             :INTEGER    READ    FCd_convenio     WRITE    FCd_convenio;
	property  Emissao                 :STRING    READ    FEmissao     WRITE    FEmissao;
	property  Cd_funcionarioexclusao  :INTEGER    READ    FCd_funcionarioexclusao     WRITE    FCd_funcionarioexclusao;
	property  Dt_exclusao             :STRING    READ    FDt_exclusao     WRITE    FDt_exclusao;
	property  Id_sincronizado         :INTEGER    READ    FId_sincronizado     WRITE    FId_sincronizado;
	property  Id_codigo_matriz        :INTEGER    READ    FId_codigo_matriz     WRITE    FId_codigo_matriz;
	property  Nr_cupom                :INTEGER    READ    FNr_cupom     WRITE    FNr_cupom;
  end;

  type
  [MVCNameCaseAttribute(ncLowerCase)]
  TNFCePagto = class
  private
    FNrDocumento     :INTEGER;
    FNrSequencia     :INTEGER;
    FDtEmissao       :STRING;
    FCdFinalizadora  :INTEGER;
    FVlTotal         :CURRENCY;
    FCancelado       :INTEGER;
    FVlTroco         :CURRENCY;
    FTipo            :INTEGER;

  public
    property NrDocumento      :integer read FNrDocumento write FNrDocumento;
    property NrSequencia      :integer read FNrSequencia write FNrSequencia;
    property DtEmissao        :string read FDtEmissao write FDtEmissao;
    property CdFinalizadora   :integer read FCdFinalizadora write FCdFinalizadora;
    property VlTotal          :Currency read FVlTotal write FVlTotal;
    property Cancelado        :integer read FCancelado write FCancelado;
    property VlTroco          :Currency read FVlTroco write FVlTroco;
    property Tipo             :integer read FTipo write FTipo;
  end;


  type
  [MVCNameCaseAttribute(ncLowerCase)]
  TNFCeTEF= class
  private
    FId		             :INTEGER;
    Fbandeira		       :STRING;
    FVl_total		       :CURRENCY;
    FDt_lancamento	   :STRING;
    FNr_documento		   :INTEGER;
    FTp_operacao		   :STRING;
    FNr_transacao		   :STRING;
    FVl_troco		       :CURRENCY;
    FEad_unicode		   :STRING;
    Fadministrador	   :STRING;
    FEad		           :STRING;
    FObs		           :STRING;


  public
    property   Id                       :INTEGER      Read  FId               Write     FId;
    property   bandeira                 :String      Read  Fbandeira         Write     Fbandeira;
    property   Vl_total                 :CURRENCY     Read  FVl_total         Write     FVl_total;
    property   Dt_lancamento            :STRING       Read  FDt_lancamento    Write     FDt_lancamento;
    property   Nr_documento             :INTEGER      Read  FNr_documento     Write     FNr_documento;
    property   Tp_operacao              :STRING       Read  FTp_operacao      Write     FTp_operacao;
    property   Nr_transacao             :STRING       Read  FNr_transacao     Write     FNr_transacao;
    property   Vl_troco                 :CURRENCY     Read  FVl_troco         Write     FVl_troco;
    property   Ead_unicode              :STRING       Read  FEad_unicode      Write     FEad_unicode;
    property   administrador            :String      Read  Fadministrador    Write     Fadministrador;
    property   Ead                      :STRING       Read  FEad              Write     FEad;
    property   Obs                      :STRING       Read  FObs              Write     FObs;
  end;

  type
  [MVCNameCaseAttribute(ncLowerCase)]
  TNFCe = class
  private
    FnrDocumento: INTEGER;
    Fmodelo: INTEGER;
    FNrNota: INTEGER;
    FnrSerie: INTEGER;
    FStatus: INTEGER;
    Fcancelado: INTEGER;
    FdtEmissao: string;
    FdtVenda: string;
    FcdOperacao: INTEGER;
    FcdCliente: INTEGER;
    FnmCliente: string;
    Fcpf: string;
    FcdUsuario: INTEGER;
    FvlDescontos: currency;
    FvlTotal: currency;
    FObs: string;
    FufOrigem: string;
    FufDestino: string;
    FvlBcIcms: currency;
    FvlIcms: currency;
    FautHrEmissao: string;
    FautProtocolo: string;
    FautDtProcessamento: string;
    FautHrprocessamento: string;
    Fautlote: string;
    FautRecibo: string;
    FautProtocoloCancel: string;
    FautChave: string;
    FautSituacao: INTEGER;
    FautExtrato: INTEGER;
    FvlBcPis: currency;
    FvlBcCofins: currency;
    FvlPis: currency;
    FvcBcCofins: currency;
    FvlCofins: currency;
    FidXml: INTEGER;
    FqtItens: INTEGER;
    FsincEmissao: INTEGER;
    FsincCancel: INTEGER;
    FdocumentoServidor: INTEGER;
    FcdCaixa: INTEGER;
    Fxml: string;
    FnrSessao: INTEGER;
    FQrCode: string;
    FpcDesconto: currency;
    FIdDispositivo: string;

    FItens: TObjectList<TNFCeItem>;
    FPagamentos: TObjectList<TNFCePagto>;
    FTransacoesTEF: TObjectList<TNFCeTEF>;
    FTitulos: TObjectList<TNFCeTitulo>;

  public
    constructor Create;
    destructor Destroy; override;
    function AsJsonString: String;

    property nrDocumento: INTEGER read FnrDocumento write FnrDocumento;
    property modelo: INTEGER read Fmodelo write Fmodelo;
    property nrNota: INTEGER read FNrNota write FNrNota;
    property nrSerie: INTEGER read FnrSerie write FnrSerie;
    property Status: INTEGER read FStatus write FStatus;
    property cancelado: INTEGER read Fcancelado write Fcancelado;
    property dtEmissao: string read FdtEmissao write FdtEmissao;
    property dtVenda: string read FdtVenda write FdtVenda;
    property cdOperacao: INTEGER read FcdOperacao write FcdOperacao;
    property cdCliente: INTEGER read FcdCliente write FcdCliente;
    property nmCliente: string read FnmCliente write FnmCliente;
    property cpf: string read Fcpf write Fcpf;
    property cdUsuario: INTEGER read FcdUsuario write FcdUsuario;
    property vlDescontos: currency read FvlDescontos write FvlDescontos;
    property vlTotal: currency read FvlTotal write FvlTotal;
    property Obs: string read FObs write FObs;
    property ufOrigem: string read FufOrigem write FufOrigem;
    property ufDestino: string read FufDestino write FufDestino;
    property vlBcIcms: currency read FvlBcIcms write FvlBcIcms;
    property vlIcms: currency read FvlIcms write FvlIcms;
    property autHrEmissao: string read FautHrEmissao write FautHrEmissao;
    property autProtocolo: string read FautProtocolo write FautProtocolo;
    property autDtProcessamento: string read FautDtProcessamento write FautDtProcessamento;
    property autHrprocessamento: string read FautHrprocessamento write FautHrprocessamento;
    property autLote: string read Fautlote write Fautlote;
    property autRecibo: string read FautRecibo write FautRecibo;
    property autProtocoloCancel: string read FautProtocoloCancel write FautProtocoloCancel;
    property autChave: string read FautChave write FautChave;
    property autSituacao: INTEGER read FautSituacao write FautSituacao;
    property autExtrato: INTEGER read FautExtrato write FautExtrato;
    property vlBcPis: currency read FvlBcPis write FvlBcPis;
    property vlBcCofins: currency read FvlBcCofins write FvlBcCofins;
    property vlPis: currency read FvlPis write FvlPis;
    property vcBcCofins: currency read FvcBcCofins write FvcBcCofins;
    property vlCofins: currency read FvlCofins write FvlCofins;
    property idXml: INTEGER read FidXml write FidXml;
    property qtItens: INTEGER read FqtItens write FqtItens;
    property sincEmissao: INTEGER read FsincEmissao write FsincEmissao;
    property sincCancel: INTEGER read FsincCancel write FsincCancel;
    property documentoServidor: INTEGER read FdocumentoServidor write FdocumentoServidor;
    property cdCaixa: INTEGER read FcdCaixa write FcdCaixa;
    property xml: string read Fxml write Fxml;
    property nrSessao: INTEGER read FnrSessao write FnrSessao;
    property QrCode: string read FQrCode write FQrCode;
    property pcDesconto: currency read FpcDesconto write FpcDesconto;
    property idDispositivo: string read FIdDispositivo write FIdDispositivo;

    [MVCListOfAttribute(TNFCeItem)]
    property Itens: TObjectList<TNFCeItem> read FItens write FItens;
    [MVCListOfAttribute(TNFCePagto)]
    property Pagamentos: TObjectList<TNFCePagto> read FPagamentos write FPagamentos;
    [MVCListOfAttribute(TNFCeTEF)]
    property TransacoesTEF: TObjectList<TNFCeTEF> read FTransacoesTEF write FTransacoesTEF;
    [MVCListOfAttribute(TNFCeTitulo)]
    property Titulos: TObjectList<TNFCeTitulo> read FTitulos write FTitulos;
  end;

implementation

uses
  MVCFramework.DataSet.Utils,
  MVCFramework.Serializer.JsonDataObjects,
  JsonDataObjects;

{ TNFCe }
function TNFCe.AsJsonString: String;
var
  Serializar: TMVCJsonDataObjectsSerializer;
  JsonObj: TJSONObject;
begin
  Serializar := TMVCJsonDataObjectsSerializer.Create;
  JsonObj := TJSONObject.Create;
  try
    Serializar.ObjectToJSONObject(Self, JsonObj, stDefault, []);
    Result := JsonObj.ToJSON;
  finally
    Serializar.Free;
    JsonObj.Free;
  end;
end;

constructor TNFCe.Create;
begin
  inherited create;
  FItens         := TObjectList<TNFCeItem>.Create;
  FPagamentos    := TObjectList<TNFCePagto>.Create;
  FTransacoesTEF := TObjectList<TNFCeTEF>.Create;
  FTitulos       := TObjectList<TNFCeTitulo>.Create
end;

destructor TNFCe.Destroy;
begin
  FItens.Free;
  FPagamentos.Free;
  if Assigned(FTransacoesTEF) then
    FTransacoesTEF.Free;
  if Assigned(FTitulos) then
    FTitulos.Free;
  inherited;
end;

{ TNFCeRetACBR }

function TNFCeRetACBR.AsJsonString: String;
var
  Serializar: TMVCJsonDataObjectsSerializer;
  JsonObj: TJSONObject;
begin
    Serializar := TMVCJsonDataObjectsSerializer.Create;
    JsonObj := TJSONObject.Create;
  try
    Serializar.ObjectToJSONObject(Self, JsonObj, stDefault, []);
    Result := JsonObj.ToJSON;
  finally
    Serializar.Free;
    JsonObj.Free;
  end;
end;

{ TNFCeCancNFCE }
function TNFCeCancNFCE.AsJsonString: String;
var
  Serializar: TMVCJsonDataObjectsSerializer;
  JsonObj: TJSONObject;
begin
  Serializar := TMVCJsonDataObjectsSerializer.Create;
  JsonObj := TJSONObject.Create;
  try
    Serializar.ObjectToJSONObject(Self, JsonObj, stDefault, []);
    Result := JsonObj.ToJSON;
  finally
    Serializar.Free;
    JsonObj.Free;
  end;
end;

{ TNFCeConfig }
function TNFCeEmpresa.AsJsonString: String;
var
  Serializar: TMVCJsonDataObjectsSerializer;
  JsonObj: TJSONObject;
begin
  Serializar := TMVCJsonDataObjectsSerializer.Create;
  JsonObj := TJSONObject.Create;
  try
    Serializar.ObjectToJSONObject(Self, JsonObj, stDefault, []);
    Result := JsonObj.ToJSON;
  finally
    Serializar.Free;
    JsonObj.Free;
  end;
end;

end.
