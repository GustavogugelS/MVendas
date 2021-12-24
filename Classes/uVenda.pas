unit uVenda;

interface

uses
  System.Generics.Collections;

type
  TItem = class
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

  TPagamento = class
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

  TVenda = class
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

    FItens: TObjectList<TItem>;
    FPagamentos: TObjectList<TPagamento>;
    {TODO: Transações TEF}
    {TODO: Convenio}

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
    property Itens: TObjectList<TItem> read FItens write FItens;
    property Pagamentos: TObjectList<TPagamento> read FPagamentos write FPagamentos;
  end;

implementation

{ TVenda }

function TVenda.AsJsonString: String;
begin

end;

constructor TVenda.Create;
begin
  inherited create;
  FItens         := TObjectList<TItem>.Create;
  FPagamentos    := TObjectList<TPagamento>.Create;
  {TODO: Transações TEF}
  {TODO: Convenio}
end;

destructor TVenda.Destroy;
begin
  FItens.Free;
  FPagamentos.Free;
  inherited;
end;

end.
