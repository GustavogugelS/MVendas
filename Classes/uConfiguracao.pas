unit uConfiguracao;

interface

type
  TConfiguracao = class
    private
      FHomologacao: Integer;
      FDispDescricao: String;
      FIdDispositivo: Integer;
      FIpServidor: String;
      FUltimoUsuario: String;
      FPortaServidor: Integer;
      FSerie: Integer;
      FModelo: Integer;
      FId: Integer;
      FCFOP: Integer;
      FCFOPST: Integer;
      FCaixaCodigo: Integer;
      FIdCSC: Integer;
      FCSC: String;
      FUrlPFX: String;
      FSenhaPFX: String;
      FTipoSSL: Integer;
      FAmbiente: Integer;

    public
      property Id: Integer read FId write FId;
      property IdDispositivo: Integer read FIdDispositivo write FIdDispositivo;
      property DispDescricao: String read FDispDescricao write FDispDescricao;
      property CaixaCodigo: Integer read FCaixaCodigo write FCaixaCodigo;
      property Ipservidor: String read FIpServidor write FIpServidor;
      property UltimoUsuario: String read FUltimoUsuario write FUltimoUsuario;
      property portaServidor: Integer read FPortaServidor write FPortaServidor;
      property Serie: Integer read FSerie write FSerie;
      property Modelo: Integer read FModelo write FModelo;
      property Homologacao: Integer read FHomologacao write FHomologacao;
      property CFOP: Integer read FCFOP write FCFOP;
      property CFOPST: Integer read FCFOPST write FCFOPST;
      property IdCsc: Integer read FIdCSC write FIdCSC;
      property Csc: String read FCSC write FCSC;
      property UrlPFX: String read FUrlPFX write FUrlPFX;
      property SenhaPFX: String read FSenhaPFX write FSenhaPFX;
      property TipoSSL: Integer read FTipoSSL write FTipoSSL;
      property Ambiente: Integer read FAmbiente write FAmbiente;
  end;

  TConfiguracaoLocal = class
    private
      FId: Integer;
      FVersaoBanco: Integer;
      FUltimaSenha: String;
      FUltimoLogin: String;
      FDtUltSinc: TDate;
      FFlSomsucesso: Integer;
      FFLSomErro: Integer;
      FFlEconomiaPapel: Integer;
      FcdPreco: Integer;
      FImei: String;

    public
      property Id: Integer read FId write FId;
      property UltimoLogin: String read FUltimoLogin write FUltimoLogin;
      property UltimaSenha: String read FUltimaSenha write FUltimaSenha;
      property FlEconomiaPapel: Integer read FFlEconomiaPapel write FFlEconomiaPapel;
      property FLSomErro: Integer read FFLSomErro write FFLSomErro;
      property FlSomsucesso: Integer read FFlSomsucesso write FFlSomsucesso;
      property CdPreco: Integer read FCdPreco write FCdPreco;
      property VersaoBanco: Integer read FVersaoBanco write FVersaoBanco;
      property DtUltSinc: TDate read FDtUltSinc write FDtUltSinc;
      property Imei: String read FImei write FImei;
  end;

  TEmpresa = class
    private
      FAliqPis: Double;
      FAliqCofins: Double;
      FFantasia: String;
      FCnpj: String;
      FId: Integer;
      FIe: String;
      FNumero: Integer;
      FEndereco: String;
      FRazaoSocial: String;
      FCidade: String;
      FUF: String;
      FComplemento: String;
      FBairro: String;
      FIbgeCod: Integer;
      FCep: Integer;
      FTelefone: String;
      FUfCodigo: Integer;
      FRegime: Integer;

    public
      property Id: Integer read FId write FId;
      property Cnpj: String read FCnpj write FCnpj;
      property RazaoSocial: String read FRazaoSocial write FRazaoSocial;
      property Numero: Integer read FNumero write FNumero;
      property Fantasia: String read FFantasia write FFantasia;
      property Ie: String read FIe write FIe;
      property AliqPis: Double read FAliqPis write FAliqPis;
      property AliqCofins: Double read FAliqCofins write FAliqCofins;
      property Cidade: String read FCidade write FCidade;
      property Endereco: String read FEndereco write FEndereco;
      property UF: String read FUF write FUF;
      property Complemento: String read FComplemento write FComplemento;
      property Bairro: String read FBairro write FBairro;
      property IbgeCod: Integer read FIbgeCod write FIbgeCod;
      property Cep: Integer read FCep write FCep;
      property Telefone: String read FTelefone write FTelefone;
      property UfCodigo: Integer read FUfCodigo write FUfCodigo;
      property Regime: Integer read FRegime write FRegime;
  end;

  TCaixa = class
    private
      FId: Integer;
      FCdUsuario: Integer;
      FData: String;

    public
      property Id :Integer read FId write FId;
      property CdUsuario: Integer read FCdUsuario write FCdUsuario;
      property Data: String read FData write FData;
  end;

  TUsuario = class
    private
      FId: Integer;
      FSenha: String;
      FLogin: String;
      FNome: String;

    public
      property Id: Integer read FId write FId;
      property Nome: String read FNome write FNome;
      property Login: String read FLogin write FLogin;
      property Senha: String read FSenha write FSenha;
  end;

  var
    Empresa: TEmpresa;
    Configuracao: TConfiguracao;
    ConfigLocal: TConfiguracaoLocal;
    Caixa: TCaixa;
    Usuario: TUsuario;

implementation

Initialization

  Empresa := TEmpresa.Create;
  Configuracao := TConfiguracao.Create;
  ConfigLocal := TConfiguracaoLocal.Create;
  Caixa := TCaixa.Create;
  Usuario := TUsuario.Create;

end.
