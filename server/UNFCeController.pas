unit UNFCeController;

interface

uses
  System.Classes,
  MVCFramework,
  MVCFramework.Commons,
  System.JSON,
  UBaseController;

type

  [MVCPath('/ServerApi')]
  TNFCeController = class(TBaseController)
  private
    procedure GetNFCePDF(ANumero: integer; ASerie: integer); overload;
    procedure GetNFCeXML(ANumero: integer; ASerie: integer); overload;
    procedure GetNFCeEscPOS(ANumero: integer; ASerie: integer); overload;
  protected
    procedure OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean); override;
    procedure OnAfterAction(Context: TWebContext; const AActionName: string); override;
  public
    [MVCPath('/')]
    [MVCHTTPMethod([httpGET])]
    procedure Index;

    [MVCPath('/testeBanco/($ACNPJ)/($AprecoVenda)')]
    [MVCHTTPMethod([httpGET])]
    procedure testeBanco(ACNPJ: String; AprecoVenda: string);

    [MVCPath('/filial/($ACNPJ)')]
    [MVCHTTPMethod([httpGET])]
    procedure GetFilial(ACNPJ: string);

    [MVCPath('/confignfe/($ACNPJ)/($Adispositivo)')]
    [MVCHTTPMethod([httpGET])]
    procedure GetConfigNFE(ACNPJ: String; Adispositivo: String);

    [MVCPath('/depositos/($ACNPJ)')]
    [MVCHTTPMethod([httpGET])]
    procedure GetDespositos(ACNPJ: String);

    [MVCPath('/setVersao/($ACNPJ)/($Adispositivo)/($Aversao)/($AIdentificador)')]
    [MVCHTTPMethod([httpGET])]
    procedure SetVersaoDispositivo(ACNPJ: String; Adispositivo, Aversao, AIdentificador: String);

    [MVCPath('/configmobile/($ACNPJ)/($Adispositivo)')]
    [MVCHTTPMethod([httpGET])]
    procedure GetConfigMobile(ACNPJ: string; Adispositivo: String);

    [MVCPath('/SaldoEstoque/($ACNPJ)/($AidDeposito)')]
    [MVCHTTPMethod([httpGET])]
    procedure GetSaldoEstoque(ACNPJ: String; AidDeposito: String);

    [MVCPath('/usuarios/($ACNPJ)')]
    [MVCHTTPMethod([httpGET])]
    procedure GetUsuarios(ACNPJ: String);

    [MVCPath('/perfilAbastecimentoC/($ACNPJ)')]
    [MVCHTTPMethod([httpGET])]
    procedure perfilAbastecimentoC(ACNPJ: String);

    [MVCPath('/perfilAbastecimentoI/($ACNPJ)')]
    [MVCHTTPMethod([httpGET])]
    procedure perfilAbastecimentoI(ACNPJ: String);

    [MVCPath('/PerfilImpressao/($ACNPJ)')]
    [MVCHTTPMethod([httpGET])]
    procedure PerfilImpressao(ACNPJ: String);

    [MVCPath('/permissao/($ACNPJ)')]
    [MVCHTTPMethod([httpGET])]
    procedure GetPermissao(ACNPJ: String);

    [MVCPath('/finalizadora/($ACNPJ)')]
    [MVCHTTPMethod([httpGET])]
    procedure GetFinalizadora(ACNPJ: String);

    [MVCPath('/produtos/($ACNPJ)/($ARegistroSKIP)/($ADtAtz)')]
    [MVCHTTPMethod([httpGET])]
    procedure GetProdutos(ACNPJ: String; ARegistroSKIP: integer; ADtAtz: String);

    [MVCPath('/prodCompostos/($ACNPJ)')]
    [MVCHTTPMethod([httpGET])]
    procedure GetCompostos(ACNPJ: String);

    [MVCPath('/QtProdutos/($ACNPJ)')]
    [MVCHTTPMethod([httpGET])]
    procedure GetQtProduto(ACNPJ: String);

    [MVCPath('/ListaInativoProduto/($ACNPJ)')]
    [MVCHTTPMethod([httpGET])]
    procedure GetListaInativoProduto(ACNPJ: String);

    // Lista todos os clientes
    [MVCPath('/clientes/($ACNPJ)')]
    [MVCHTTPMethod([httpGET])]
    procedure GetClientes(ACNPJ: String);

    // Busca cliente código interno
    [MVCPath('/clientes/($ACNPJ)/($Aid)')]
    [MVCHTTPMethod([httpGET])]
    procedure GetCliente(ACNPJ: String; Aid: integer);

    // Busca cliente por CPF
    [MVCPath('/clientesCPF/($ACNPJ)/($Aid)')]
    [MVCHTTPMethod([httpGET])]
    procedure GetClienteCPF(ACNPJ: String; Aid: String);

    // Busca cliente código externo
    [MVCPath('/clientesEx/($ACNPJ)/($Aid)')]
    [MVCHTTPMethod([httpGET])]
    procedure GetClienteEx(ACNPJ: String; Aid: String);

    [MVCPath('/contagemInicio/($ACNPJ)/($Aecf)/($Ausuario)/($Anm_deposito)')]
    [MVCHTTPMethod([httpGET])]
    procedure GetcontagemC(ACNPJ: String; Aecf, Ausuario: integer; Anm_deposito: string);

    [MVCPath('/contagemFim/($ACNPJ)/($Aecf)')]
    [MVCHTTPMethod([httpGET])]
    procedure FinalizaContagem(ACNPJ: String; Aecf: integer);

    [MVCPath('/Nota/($ACNPJ)/($Achavecanfe)')]
    [MVCHTTPMethod([httpGET])]
    procedure GetNota(ACNPJ: String; Achavecanfe: String);

    [MVCPath('/nfce/($ACNPJ)/($ANumero)/($ASerie)/($ATipo)')]
    [MVCHTTPMethod([httpGET])]
    procedure GetNFCe(ACNPJ: String; ANumero: integer; ASerie: integer; ATipo: string);

    [MVCPath('/teste1')]
    [MVCHTTPMethod([httpGET])]
    procedure CreateTeste;

    [MVCPath('/RelatorioEstoque/($ACNPJ)/($AEcf)')]
    [MVCHTTPMethod([httpGET])]
    procedure getUltimaContagem(ACNPJ: String; Aecf: integer);

    [MVCPath('/GrupoDescontos/($ACNPJ)')]
    [MVCHTTPMethod([httpGET])]
    procedure GetGrupoDescontos(ACNPJ: String);

    [MVCPath('/comandoSQL/($ACNPJ)/($Adispositivo)')]
    [MVCHTTPMethod([httpGET])]
    procedure GetComandoSql(ACNPJ: String; Adispositivo: string);

    [MVCPath('/finalizacomandoSQL/($ACNPJ)/($AidComando)')]
    [MVCHTTPMethod([httpGET])]
    procedure SetFinalizaComandoSql(ACNPJ: String; AidComando: string);

    [MVCPath('/GeraPDFNFCe/($ACNPJ)/($ANumero)/($ASerie)')]
    [MVCHTTPMethod([httpGET])]
    procedure GeraPDFNFCe(ACNPJ: String; ANumero, ASerie: integer);

    { Consulta na base de dados se o dispositivo possui permissão para receber carga
      Campo RECEBE_CARGA = 'S'
    }
    [MVCPath('/carga/($ACNPJ)/($Adispositivo)')]
    [MVCHTTPMethod([httpGET])]
    procedure GetStatusCarga(ACNPJ: String; Adispositivo: String);

    { Confirmação que o dispositivo recebeu carga com sucesso. Realiza update
      na base de dados do servidor setando RECEBE_CARGA = 'N'
    }
    [MVCPath('/setcarga/($ACNPJ)/($Adispositivo)')]
    [MVCHTTPMethod([httpGET])]
    procedure SetStatusCarga(ACNPJ: String; Adispositivo: String);

    [MVCPath('/ConsultaNFCE/($ACNPJ)/($ADocumento)')]
    [MVCHTTPMethod([httpGET])]
    procedure ConsultaNFCE(ACNPJ: String; ADocumento: string);

    [MVCPath('/CancelaNFCe/($ACNPJ)')]
    [MVCHTTPMethod([httpPOST])]
    procedure CancelaNFCe(ACNPJ: String);

    [MVCPath('/nfce/($ACNPJ)')]
    [MVCHTTPMethod([httpPOST])]
    procedure CreateNFCe(ACNPJ: String);

    [MVCPath('/GeraNFCE/($ACNPJ)')]
    [MVCHTTPMethod([httpPOST])]
    procedure GeraNfce(ACNPJ: String);

  var
    SatEmUso: Boolean;
  end;

implementation

uses
  Data.DB,
  System.NetEncoding,
  ACBrValidador,
  System.SysUtils,
  System.StrUtils,
  MVCFramework.Logger,
  UConfigClass,
  UNFCeClass,
  DNFCe;

{ TNFCeController }

procedure TNFCeController.Index;
begin
  // use Context property to access to the HTTP request and response
  Render('API NFC-e');
end;

procedure TNFCeController.GeraPDFNFCe(ACNPJ: String; ANumero, ASerie: integer);
begin
  self.GetNFCePDF(ANumero, ASerie);
end;

procedure TNFCeController.OnAfterAction(Context: TWebContext; const AActionName: string);
begin
  inherited;
end;

procedure TNFCeController.OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean);
var
  i: integer;
  aux: String;
begin
  inherited;
  aux := '';
  for i := 0 to pred(Context.Request.SegmentParamsCount) do
    aux := aux + '[' + Context.Request.paramNames[i] + '-' + Context.Request.params[Context.Request.paramNames[i]] + ']';

  writeln('[' + FormatDateTime('DD-MM-hh:mm:ss', now) + '] [' + Context.Request.clientIP + ' processo: ' + AActionName + '] ' + aux);
end;

procedure TNFCeController.PerfilImpressao(ACNPJ: String);
var
  TmpDataset: TDataSet;
begin
  try
    FDConexao.ExecSQL('SELECT                          ' + '    CD_PRODUTO,                  ' + '    SEQUENCIA, ' + '    FL_ATIVO ' +
       ' FROM                            ' + '    PERFILIMPRESSAOESTOQUE ', TmpDataset);

    if TmpDataset.IsEmpty then
      Render(500, 'Não existe produtos no perfil')
    else
      Render(TmpDataset, true);
  except
    on e: Exception do
    begin
      Render(500, 'Não existe produtos no perfil');
      MVCFramework.Logger.LogE('Erro na SetFinalizaComandoSql:' + e.Message);
    end;
  end;
end;

procedure TNFCeController.SetFinalizaComandoSql(ACNPJ: String; AidComando: string);
begin
  try
    if fFinalizaComandoSql(AidComando) then
      Render(200, 'Gravado com sucesso')
    else
      Render(500, 'Erro ao gravar retornoSql');
  except
    on e: Exception do
    begin
      Render(500, 'Erro ao gravar retornoSql');
      MVCFramework.Logger.LogE('Erro na SetFinalizaComandoSql:' + e.Message);
    end;
  end;
end;

procedure TNFCeController.SetStatusCarga(ACNPJ: String; Adispositivo: String);
begin
  try
    if fRecebeuCarga(Adispositivo) then
      Render(200, 'Sucesso')
    else
      Render(500, 'Erro');
  except
    on e: Exception do
    begin
      Render(500, 'Erro');
      MVCFramework.Logger.LogE('Erro na SetStatusCarga:' + e.Message);
    end;
  end;
end;

procedure TNFCeController.SetVersaoDispositivo(ACNPJ: String; Adispositivo, Aversao, AIdentificador: String);
begin

  if fGravarVersao(Adispositivo, Aversao, AIdentificador) then
    Render(201, 'Gravado com sucesso')
  else
    Render(500, 'Erro ao gravar Versão');
end;

procedure TNFCeController.testeBanco(ACNPJ: String; AprecoVenda: string);
var
  oNFCe: TNFCe;
  DmNFCe: TdtmNFCe;
  StrRetorno: string;
begin
  //
  try
    try
      FDConexao.StartTransaction;
      StrRetorno := fTestarBanco(AprecoVenda);

      if NOT StrRetorno.IsEmpty then
      begin
        FDConexao.Commit;
        Render(200, StrRetorno);
      end
      else
      begin
        FDConexao.Rollback;
        Render(404, StrRetorno);

      end;

    finally

    end;
  except
    on e: Exception do
    begin
      Render(500, e.Message);
    end;
  end;
end;

procedure TNFCeController.GetClientes(ACNPJ: String);
var
  TmpDataset: TDataSet;
begin
  try
    FDConexao.ExecSQL('SELECT                          ' + '    CD_CLIENTE,                  ' + '   CLIENTE.NM_CLIFOR NM_CLIENTE, ' +
       '    CGC_CPF                      ' + ' FROM                            ' + '    CLIENTE                      ', TmpDataset);

    if TmpDataset.IsEmpty then
      Render(500, 'Não existe nenhum cliente cadastrado na base de dados')
    else
      Render(TmpDataset, true);
  except
    on e: Exception do
    begin
      Render(500, 'Erro ao consultar clientes no banco de dados');
      MVCFramework.Logger.LogE('Erro na GetClientes:' + e.Message);
    end;
  end;
end;

procedure TNFCeController.CancelaNFCe(ACNPJ: String);
var
  DmNFCe: TdtmNFCe;
  oCancNf: TNFCeCancNFCE;
  retorno: TNFCeRetACBR;
  config: TNFCeEmpresa;
  xml: string;
begin
  xml := '';
  try
    try
      oCancNf := Context.Request.BodyAs<TNFCeCancNFCE>;
      DmNFCe := TdtmNFCe.Create(nil);
      retorno := TNFCeRetACBR.Create;

      xml := fExisteNota(oCancNf.chaveDoc.ToInteger, oCancNf.idDispositivo.ToInteger, 1);
      if trim(xml) <> '' then
      begin
        retorno.autorizou := true;
        retorno.NrDocumentoServidor := oCancNf.Nr_documentoRet.ToString;
        retorno.xml := xml;
      end
      else
      begin
        config := fBuscarDadosEmpresa;
        DmNFCe.fCancelarNFCe(oCancNf, config, retorno);
        if retorno.autorizou then
        begin
          {Terminar a atualização do cancelamento no servidor}
  //        if fCancelarNFSC(oCancNf.Nr_documentoRet, retorno.xml) and fCancelarNFSI(oCancNf.Nr_documentoRet) and fCancelarPGTO(oCancNf.Nr_documentoRet) then
  //          retorno.NrDocumentoServidor := oCancNf.Nr_documentoRet.ToString;
        end;
      end;

    finally
      DmNFCe.Free;
    end;

    Render(200, retorno);
  finally
    oCancNf.Free;
  end;
end;

procedure TNFCeController.GetCliente(ACNPJ: String; Aid: integer);
var
  TmpDataset: TDataSet;
begin

  try

    FDConexao.ExecSQL('   SELECT    ' + '       CLIENTE.CD_CLIENTE,    ' + '       CLIENTE.NM_CLIFOR AS NM_CLIENTE ,    ' +
       '       CLIENTE.CGC_CPF,    ' + '       COALESCE(grupo_cliente.pc_desconto,0) AS PC_DESCONTO_ESPECIAL,  ' +
       '       COALESCE(CLIENTE.LIMITE_CREDITO,0) LIMITE_CREDITO,  ' + '       SUM(COALESCE(CRPTITULO.VL_SALDO,0)) AS VL_CONVENIO  ' + '   FROM    ' +
       '       CLIENTE  ' + '   LEFT JOIN CRPTITULO ON ( (CLIENTE.CD_CLIENTE = CRPTITULO.CD_CLIFOR) AND(CRPTITULO.CD_TIPO_CONTA = 2) )  ' +
       '   LEFT JOIN grupo_cliente ON grupo_cliente.cd_grupo = cliente.cd_grupo  ' + '   WHERE    ' + '       CD_CLIENTE =    ' + Aid.ToString +
       '   AND    ' + '       CLIENTE.FL_ATIVO = ''S''  ' + '  GROUP BY  ' + '       CLIENTE.CD_CLIENTE,  ' + '       CLIENTE.NM_CLIFOR,  ' +
       '       CLIENTE.CGC_CPF,    ' + '       COALESCE(grupo_cliente.pc_desconto,0),  ' + '       CLIENTE.LIMITE_CREDITO  ', TmpDataset);

    if TmpDataset.IsEmpty then
      Render(500, Format('Não existe cliente cadastrado com o código "%d" na base de dados', [Aid]))
    else
      Render(TmpDataset, true);
  except
    on e: Exception do
    begin
      Render(500, Format('Não existe cliente cadastrado com o código "%d" na base de dados', [Aid]));
      MVCFramework.Logger.LogE('Erro na GetCliente:' + e.Message);
    end;
  end;
end;

procedure TNFCeController.GetClienteCPF(ACNPJ: String; Aid: String);
var
  TmpDataset: TDataSet;
begin

  try
    FDConexao.ExecSQL('   SELECT    ' + '       CLIENTE.CD_CLIENTE,    ' + '       CLIENTE.NM_CLIFOR AS NM_CLIENTE ,    ' +
       '       CLIENTE.CGC_CPF,    ' + '       COALESCE(grupo_cliente.pc_desconto,0) AS PC_DESCONTO_ESPECIAL,  ' +
       '       COALESCE(CLIENTE.LIMITE_CREDITO,0) LIMITE_CREDITO,  ' + '       COALESCE(CLIENTE.LIMITE_PESO,0) LIMITE_PESO, ' +
       '       SUM(COALESCE(CRPTITULO.VL_SALDO,0)) AS VL_CONVENIO  ' + '   FROM    ' + '       CLIENTE  ' +
       '   LEFT JOIN CRPTITULO ON ( (CLIENTE.CD_CLIENTE = CRPTITULO.CD_CLIFOR) AND(CRPTITULO.CD_TIPO_CONTA = 2) )  ' +
       '   LEFT JOIN grupo_cliente ON grupo_cliente.cd_grupo = cliente.cd_grupo  ' + '   WHERE    ' + '       CLIENTE.CGC_CPF = ' + QuotedStr(Aid) +
       '   AND    ' + '       CLIENTE.FL_ATIVO = ''S''  ' + '  GROUP BY  ' + '       CLIENTE.CD_CLIENTE,  ' + '       CLIENTE.NM_CLIFOR,  ' +
       '       CLIENTE.CGC_CPF,    ' + '       COALESCE(grupo_cliente.pc_desconto,0),  ' + '       CLIENTE.LIMITE_PESO, ' +
       '       CLIENTE.LIMITE_CREDITO  ', TmpDataset);

    if TmpDataset.IsEmpty then
      Render(500, Format('Não existe cliente cadastrado com o código "%d" na base de dados', [Aid]))
    else
      Render(TmpDataset, true);

  except
    on e: Exception do
    begin
      Render(500, Format('Não existe cliente cadastrado com o código "%d" na base de dados', [Aid]));
      MVCFramework.Logger.LogE('Erro na GetCliente:' + e.Message);
    end;
  end;
end;

procedure TNFCeController.GetClienteEx(ACNPJ: String; Aid: String);
var
  TmpDataset: TDataSet;
begin
  try
    FDConexao.ExecSQL('   SELECT    ' + '       CLIENTE.CD_CLIENTE    ' + '   FROM    ' + '       CLIENTE  ' + '   WHERE    ' +
       '       CD_EXTERNO =    ' + QuotedStr(Aid), TmpDataset);

    if TmpDataset.IsEmpty then
      Render(500, Format('Não existe cliente cadastrado com o código "%d" na base de dados', [Aid]))
    else
      Render(TmpDataset, true);
  except
    on e: Exception do
    begin
      Render(500, Format('Não existe cliente cadastrado com o código "%d" na base de dados', [Aid]));
      MVCFramework.Logger.LogE('Erro na GetCliente:' + e.Message);
    end;
  end;
end;

procedure TNFCeController.GetComandoSql(ACNPJ: String; Adispositivo: string);
var
  TmpDataset: TDataSet;
  SQL: sTRING;
begin
  try
    FDConexao.ExecSQL('  SELECT  ' + '      ID,  ' + '     cast(COMANDO_SQL as varchar (10000)) as sql,  ' + '      ID_DISPOSITIVO  ' + '  FROM  ' +
       '      COMANDOS_MOBILE   ' + '  WHERE  ' + '      FL_EXECUTADO = ''N''  ' + '  AND  ' + '      UPPER(ID_DISPOSITIVO) = UPPER(' +
       QuotedStr(Adispositivo) + ')', TmpDataset);

    if TmpDataset.IsEmpty then
      Render(500, 'sem comandos')
    else
      Render(TmpDataset, true);
  except
    on e: Exception do
    begin
      Render(500, 'sem comandos');
      MVCFramework.Logger.LogE('Erro na GetComandoSql:' + e.Message);
    end;
  end;

end;

procedure TNFCeController.GetCompostos(ACNPJ: String);
var
  TmpDataset: TDataSet;
begin
  try
    FDConexao.ExecSQL(' SELECT  ' + ' 	PROD_COMPOSTO.CD_PRODUTO, ' + ' 	PROD_COMPOSTO.CD_COMPOSTO, ' +
       '   COALESCE(PROD_COMPOSTO.QT_COMPOSTO,0) AS QT_COMPOSTO, ' + ' 	PROD_COMPOSTO.NM_PRODCOMPOSTO, ' + ' 	PROD_COMPOSTO.DT_ATZ, ' +
       ' 	PROD_COMPOSTO.FL_DECOMPOSTO, ' + ' 	COALESCE(PROD_COMPOSTO.PC_DESCONTO,0) AS PC_DESCONTO, ' +
       ' 	COALESCE(PROD_COMPOSTO.VL_VENDA,0) AS VL_VENDA, ' + ' 	PROD_COMPOSTO.FL_USA_PRECO_PRODUTO ' + ' FROM ' + ' 	PROD_COMPOSTO ' +
       '   JOIN PRODUTO ON PRODUTO.CD_PRODUTO = PROD_COMPOSTO.CD_PRODUTO ' + ' WHERE ' + '   PRODUTO.FL_ATIVO = ''S'' ', TmpDataset);

    if TmpDataset.IsEmpty then
      Render(500, 'Não existe nenhum produto composto cadastrado na base de dados')
    else
      Render(TmpDataset, true);
  except
    on e: Exception do
    begin
      Render(500, 'Não existe nenhum produto composto cadastrado na base de dados');
      MVCFramework.Logger.LogE('Erro na GetComposto:' + e.Message);
    end;
  end;

end;

procedure TNFCeController.GetConfigMobile(ACNPJ: String; Adispositivo: String);
var
  TmpDataset: TDataSet;
  SQL: STRING;
begin
  try
    // FDConexao.Temporary := true;
    FDConexao.ExecSQL(' SELECT ' +
                      '    1 CD_CONFIG, ' +
                      '    FL_SUPRIMENTOINICIAL, ' +
                      '    NR_ECF, ' +
                      '    NR_SERIE, ' +
                      '    CD_MODELO, ' +
                      '    FILIAL.FL_PERDIGAO FL_BRF, ' +
                      '    EQUIPAMENTO, ' +
                      '    COALESCE(QT_DIGBALANCA, 2) QT_DIGBALANCA, ' +
                      '    OTP, ' +
                      '    ID_DEPOSITO, ' +
                      '    (SELECT CASE WHEN VALOR = 1 THEN ''S'' ELSE ''N'' END FL_SITEF ' +
                      '    FROM CONFIG_PDV ' +
                      '    WHERE UPPER(CAMPO) = ''CRTSITEF'') AS FL_SITEF, ' +
                      '    (SELECT VALOR ' +
                      '    FROM CONFIG_PDV ' +
                      '    WHERE UPPER(CAMPO) = ''CRTSITEFSERVIDOR'') AS IP_SITEF, ' +
                      '    CASE WHEN COALESCE((SELECT VALOR FROM CONFIG_PDV WHERE UPPER(CAMPO) = ''CODIGOCONSUMIDOR''), ''1'') = '''' THEN ''1'' ' +
                      '         ELSE COALESCE((SELECT VALOR FROM CONFIG_PDV WHERE UPPER(CAMPO) = ''CODIGOCONSUMIDOR''), ''1'') ' +
                      '    END AS CD_CLIENTEPADRAO, ' +
                      '    (SELECT VALOR ' +
                      '    FROM CONFIG_PDV ' +
                      '    WHERE UPPER(CAMPO) = ''CRTSITEFLOJA'') AS EMPRESA_SITEF, ' +
                      '    ''RETAGUARDA'' API, ' +
                      '    ID_DISPOSITIVO, ' +
                      '    CONFIG_GLOBAL.TEF_TRANSACOESHABILITADAS, ' +
                      '    CONFIG_GLOBAL.FTP_ENDERECO, ' +
                      '    CONFIG_GLOBAL.FTP_USUARIO, ' +
                      '    CONFIG_GLOBAL.FTP_SENHA, ' +
                      '    COALESCE(CONFIG_GLOBAL.TIMER_SINCLOCALIZACAO, 0) TIMER_SINCLOCALIZACAO, ' +
                      '    COALESCE(CONFIG_GLOBAL.FL_DESCONTOAPI, ''N'') FL_DESCONTOAPI, ' +
                      '    COALESCE(FL_HABILITADINHEIRO, ''S'') AS FL_HABILITADINHEIRO, ' +
                      '    COALESCE(FL_CLISITEF, ''N'') AS FL_CLISITEF, ' +
                      '    COALESCE(FL_VALIDACHIP, ''N'') AS FL_VALIDACHIP, ' +
                      '    COALESCE(OPERACAO_ES.CFOP_INT_CONT, ''5102'') CFOPTRIB, ' +
                      '    COALESCE(OPERACAO_ES.CFOP_SUBS_INT_CONT, ''5405'') CFOPSUBS, ' +
                      '    CONFIG_GLOBAL.FL_BLQQTD ' +
                      ' FROM ' +
                      '    CONFIG_MOBILE ' +
                      '    JOIN FILIAL ON FILIAL.CD_FILIAL = 1 ' +
                      '    JOIN CONFIG_GLOBAL ON CONFIG_GLOBAL.ID = 1 ' +
                      '    LEFT JOIN OPERACAO_ES ON OPERACAO_ES.CD_OPERACAO = CONFIG_MOBILE.CD_OPERACAO ' +
                      ' WHERE ' +
                      '    CONFIG_MOBILE.FL_ATIVO = ''S'' AND ' +
                      '    UPPER(ID_DISPOSITIVO) = UPPER(' + QuotedStr(Adispositivo) + ')', TmpDataset);

    if TmpDataset.IsEmpty then
      Render(500, 'Configuracao Nao localizada')
    else
      Render(TmpDataset, true);
  except
    on e: Exception do
    begin
      Render(500, 'Configuracao Nao localizada' + e.Message);
      MVCFramework.Logger.LogE('Erro na GetCofigMobile:' + e.Message);
    end;
  end;

end;

procedure TNFCeController.GetConfigNFE(ACNPJ: String; Adispositivo: String);
var
  TmpDataset: TDataSet;
begin
  try
    FDConexao.ExecSQL(' SELECT ' +
                      '     1 AS ID, ' +
                      '     CONFIG_MOBILE.CD_ATIVACAO, ' +
                      '     COALESCE(CONFIG_NFE.VERSAO_SAT, ''0.08'') VERSAO_SAT, ' +
                      '     CASE WHEN CONFIG_NFE.AMBIENTE = 0 ' +
                      '         THEN ''S'' ' +
                      '         ELSE ''N'' ' +
                      '     END  FL_PRODUCAO, ' +
                      '     CASE when CONFIG_NFE.AMBIENTE = 0 ' +
                      '         then CONFIG_MOBILE.ASSINATURA ' +
                      '         ELSE  ''SGR-SAT SISTEMA DE GESTAO E RETAGUARDA DO SAT'' ' +
                      '     END ASSINATURA, ' +
                      '    ''01272811000104'' AS CNPJ_DESEN ' +
                      ' FROM ' +
                      '     CONFIG_MOBILE ' +
                      '         JOIN CONFIG_NFE ON CONFIG_NFE.ID = 1 ' +
                      ' WHERE ' +
                      '     CONFIG_MOBILE.FL_ATIVO =''S'' ' +
                      ' AND ' +
                      '     UPPER(ID_DISPOSITIVO) = UPPER(' + QuotedStr(Adispositivo) + ')', TmpDataset);

    if TmpDataset.IsEmpty then
      Render(500, 'Configuracao Nao encontrada')
    else
      Render(TmpDataset, true);
  except
    on e: Exception do
    begin
      Render(500, 'Filial Nao encontrada');
      MVCFramework.Logger.LogE('Erro na GetConfigNFE:' + e.Message);
    end;
  end;

end;

procedure TNFCeController.GetcontagemC(ACNPJ: String; Aecf, Ausuario: integer; Anm_deposito: string);
begin
  try
    if fInserirContagemCabecalho(Aecf, Ausuario, Anm_deposito) then
      Render(200, 'SUCESSO')
    else
      Render(500, 'ERRO');
  except
    on e: Exception do
    begin
      Render(500, 'ERRO');
      MVCFramework.Logger.LogE('Erro na GetContagemC:' + e.Message);
    end;
  end;

end;

procedure TNFCeController.GetDespositos(ACNPJ: String);
var
  TmpDataset: TDataSet;
begin
  try
    FDConexao.ExecSQL(' SELECT              ' + '    ID,              ' + '    DESCRICAO,       ' + '    FL_ATIVO         ' + ' FROM                '
       + '    DEPOSITO_MOBILE  ' + ' WHERE               ' + '    FL_ATIVO = 1 ', TmpDataset);

    if TmpDataset.IsEmpty then
      Render(500, 'Não foram encontrados depositos ativos')
    else
      Render(TmpDataset, true);

  except
    on e: Exception do
    begin
      Render(500, 'Não foram encontrados depositos ativos');
      MVCFramework.Logger.LogE('Erro na GetDepositos:' + e.Message);
    end;
  end;

end;

procedure TNFCeController.GetFilial(ACNPJ: string);
var
  TmpDataset: TDataSet;
begin
  try
    FDConexao.ExecSQL('           					SELECT                        ' + '                        FILIAL.NM_FILIAL NM_RAZAO,   ' +
       '                        NM_FANTASIA,   ' + '                        CASE WHEN CONFIG_NFE.AMBIENTE = 0  ' +
       '                             THEN  REPLACE(REPLACE(REPLACE(FILIAL.CGC, ''.'', ''''), ''/'', ''''),''-'', '''')  ' +
       '                             ELSE ''61099008000141''  ' + '                        END CNPJ,  ' +
       '                        CASE WHEN CONFIG_NFE.AMBIENTE = 0    ' +
       '                             THEN  REPLACE(REPLACE(REPLACE(FILIAL.IE, ''.'', ''''), ''/'', ''''),''-'', '''')  ' +
       '                             ELSE ''111111111111''  ' + '                        END IE,  ' + '                        CIDADE.UF,   ' +
       '                        CIDADE.NM_CIDADE NM_MUNICIPIO,   ' + '                        CIDADE.CD_IBGE CD_IBGE,   ' +
       '                        FILIAL.BAIRRO END_BAIRRO,   ' + '                        FILIAL.NUMERO END_NUMERO,   ' +
       '                        FILIAL.COMPLEMENTO  END_COMPLEMENTO ,   ' + '                        FONE,   ' +
       '                        FILIAL.ENDERECO END_RUA,   ' + '                        FILIAL.CEP END_CEP,   ' +
       '                        FILIAL.AL_PIS PIS_ALIQ,   ' + '                        FILIAL.AL_COFINS COFINS_ALIQ,   ' +
       '                        1 ID   ' + '                     FROM   ' + '                         FILIAL   ' +
       '                             JOIN CIDADE ON CIDADE.CD_CIDADE = FILIAL.CD_CIDADE  ' +
       '                             JOIN CONFIG_NFE ON CONFIG_NFE.ID = 1  ', TmpDataset);

    if TmpDataset.IsEmpty then
      Render(500, 'Filial Nao encontrada')
    else
      Render(TmpDataset, true);
  except
    on e: Exception do
    begin
      Render(500, 'Filial Nao encontrada');
      // MVCFramework.Logger.LogE('TESTE LOGE');
      MVCFramework.Logger.LogE('Erro na GetFilial:' + e.Message);
      // writeln(e.Message);
    end;
  end;

end;

procedure TNFCeController.GetFinalizadora(ACNPJ: String);
var
  TmpDataset: TDataSet;
begin
  try
    FDConexao.ExecSQL('  SELECT                                                                ' +
       '      FINALIZADORAS.CD_FINALIZADORA,                                    ' +
       '      FINALIZADORAS.TP_FINALIZADORA,                                    ' +
       '      UPPER(FINALIZADORAS.NM_FINALIZADORA) AS NM_FINALIZADORAS,         ' +
       '      CASE WHEN (FINALIZADORAS.TP_FINALIZADORA = ''D'' AND UPPER(FINALIZADORAS.NM_FINALIZADORA) = ''DINHEIRO'') THEN 1       ' +
       '           WHEN (FINALIZADORAS.TP_FINALIZADORA = ''R'' AND UPPER(FINALIZADORAS.NM_FINALIZADORA) = ''CARTAO'')  THEN  2       ' +
       '           WHEN (FINALIZADORAS.TP_FINALIZADORA = ''I'' ) THEN 3       ' +
       '           WHEN (FINALIZADORAS.TP_FINALIZADORA = ''T'' AND UPPER(FINALIZADORAS.NM_FINALIZADORA) = ''TICKET'') THEN 4       ' +
       '      ELSE 5                                         ' + '          END CD_MOBILE                  ' +
       '  FROM                                               ' + '      FINALIZADORAS                                  ' +
       '  WHERE                                              ' + '      FINALIZADORAS.TP_FINALIZADORA IN (''D'', ''R'', ''I'', ''T'') ', TmpDataset);

    if TmpDataset.IsEmpty then
      Render(500, 'Sem finalizadoras')
    else
      Render(TmpDataset, true);

  except
    on e: Exception do
    begin
      Render(500, 'Sem finalizadoras');
      MVCFramework.Logger.LogE('Erro na GetFinalizadora:' + e.Message);
    end;
  end;

end;

procedure TNFCeController.GetGrupoDescontos(ACNPJ: String);
var
  TmpDataset: TDataSet;
begin
  try
    FDConexao.ExecSQL(' select  ' + '    CD_GRUPO,  ' + '    NM_GRUPO,  ' + '    PC_DESCONTO,  ' + '    FL_ATIVO  ' + ' from  ' +
       '    grupo_cliente ', TmpDataset);

    if TmpDataset.IsEmpty then
      Render(500, 'Sem grupos')
    else
      Render(TmpDataset, true);
  except
    on e: Exception do
    begin
      Render(500, 'Sem grupos');
      MVCFramework.Logger.LogE('Erro na GetGrupoDesconto:' + e.Message);
    end;
  end;

end;

procedure TNFCeController.GetListaInativoProduto(ACNPJ: String);
var
  TmpDataset: TDataSet;
begin
  try
    FDConexao.ExecSQL(' SELECT CD_PRODUTO FROM PRODUTO WHERE FL_ATIVO = ''N'' and dt_atz >=  current_date - 80', TmpDataset);

    if TmpDataset.IsEmpty then
      Render(500, 'Não existe nenhum produto inativo na base de dados')
    else
      Render(TmpDataset, true);

  except
    on e: Exception do
    begin
      Render(500, 'Não existe nenhum produto inativo na base de dados');
      MVCFramework.Logger.LogE('Erro na GetListaInativo:' + e.Message);
    end;
  end;

end;

procedure TNFCeController.GetProdutos(ACNPJ: String; ARegistroSKIP: integer; ADtAtz: String);
var
  TmpDataset: TDataSet;
begin
  try
//    FDConexao.ExecSQL('SELECT FIRST 5000 SKIP ' + AREGISTROSKIP.TOSTRING +
//                      '    PRODUTO.CD_PRODUTO, COALESCE(PRODUTO.PESO_BRUTO, 0) PESO_BRUTO, ' +
//                      '    COALESCE(PRODUTO.FL_COMPOSTO, ''N'') AS FL_COMPOSTO, ' +
//                      '    PRODUTO.CST_PIS_SAIDA AS PISCOFINS_CST, ' +
//                      '    CASE ' +
//                      '        WHEN FILIAL.UF = ''SP'' THEN ' +
//                      '            CASE  ' +
//                      '                WHEN CST_INT = ''020'' THEN ''000''  ' +
//                      '                WHEN CST_INT = ''010'' THEN ''000''  ' +
//                      '                WHEN CST_INT = ''041'' THEN ''040''  ' +
//                      '                WHEN CST_INT = ''050'' THEN ''040''  ' +
//                      '                WHEN CST_INT = ''051'' THEN ''040''  ' +
//                      '                ELSE PRODUTO.CST_INT ' +
//                      '            END ' +
//                      '        ELSE PRODUTO.CST_INT ' +
//                      '    END ICMS_CST, ' +
//                      '    COALESCE(PRODUTO.NATUREZA_RECEITA_PIS, 0) PISCOFINS_NATUREZARECEITA, ' +
//                      '    COALESCE(TRIBICMS.PC_REDU_CONT, 0) AS PC_REDU_CONT, PRODUTO.DIR_FISCAL, ' +
//                      '    COALESCE(PRODUTO.CD_BARRAS, PRODUTO.CD_PRODUTO) AS CD_BARRAS, PRODUTO.NM_REDUZIDO, ' +
//                      '    PRODUTO.NM_REDUZIDO AS NM_PRODUTO, PRODUTO.UN_MEDIDA, ' +
//                      '    COALESCE(PRODUTO.PESO_LIQUIDO, 0) PESO_LIQUIDO, ' +
//                      '    COALESCE(PRODUTO.PC_DESCONTO, 0) AS PC_DESCONTO, PRODUTO.FL_ATIVO, ' +
//                      '    PRODUTO.CEST_CODIGO AS CD_CEST, COALESCE(PRODUTO.QT_ESTOQUE, 0) AS QT_ESTOQUE, ' +
//                      '    PRODUTO.PRECO_DELIVERY, ' +
//                      '    CASE ' +
//                      '        WHEN (NOT PROD_ATV_PROMOCAO.PC_VENDA IS NULL) THEN PROD_ATV_PROMOCAO.PC_VENDA ' +
//                      '        WHEN PRODUTO.PRECO_DELIVERY > 0 THEN PRODUTO.PRECO_DELIVERY ' +
//                      '        ELSE PRODUTO.PRECO_VENDA ' +
//                      '    END AS PRECO_VENDA, ' +
//                      '    COALESCE(CASE ' +
//                      '                WHEN COALESCE(PRODUTO.ALIQ_ECF, 0) > 0 THEN PRODUTO.ALIQ_ECF ' +
//                      '                ELSE CASE ' +
//                      '                        WHEN (PRODUTO.CST_INT IN (''060'', ''030'')) THEN 0 ' +
//                      '                        WHEN (PRODUTO.CST_INT = ''040'') THEN 0 ' +
//                      '                        WHEN (PRODUTO.CST_INT = ''041'') THEN 0 ' +
//                      '                        WHEN ((TRIBICMS.ALIQ_ICM_NCONT IS NULL) OR (TRIBICMS.ALIQ_ICM_NCONT = 0)) THEN TRIBICMS_UF.ALIQ_ICM_NCONT ' +
//                      '                        ELSE TRIBICMS.ALIQ_ICM_NCONT ' +
//                      '                      END ' +
//                      '             END, 0) AS ICMS_ALIQUOTA, ' +
//                      '    PRODUTO.CD_FISCAL, ' +
//                      '    COALESCE(PROD_NCM_IBPT.PNCM_ALIQNAC, 0) AS ALIQ_NACIONAL, PRODUTO.PC_FCP, ' +
//                      '    PRODUTO.CODIGO_GTIN, CBENEF.CD_CBENEF ' +
//                      'FROM ' +
//                      '    PRODUTO ' +
//                      '    JOIN FILIAL ON FILIAL.CD_FILIAL = 1 ' +
//                      '    LEFT OUTER JOIN PROD_ATV_PROMOCAO ON PROD_ATV_PROMOCAO.CD_PRODUTO = PRODUTO.CD_PRODUTO ' +
//                      '    LEFT OUTER JOIN TRIBICMS_UF ON TRIBICMS_UF.CST = PRODUTO.CST_INT AND ' +
//                      '        TRIBICMS_UF.UF_DESTINO = FILIAL.UF AND ' +
//                      '        TRIBICMS_UF.UF_ORIGEM = FILIAL.UF ' +
//                      '    LEFT OUTER JOIN CBENEF ON PRODUTO.ID_CBENEF = CBENEF.ID ' +
//                      '    LEFT OUTER JOIN TRIBICMS ON PRODUTO.CD_PRODUTO = TRIBICMS.CD_PRODUTO AND ' +
//                      '        PRODUTO.CST_INT = TRIBICMS.CST ' +
//                      '    LEFT JOIN PROD_NCM_IBPT ON (((PRODUTO.CD_FISCAL = PROD_NCM_IBPT.PNCM_NCM) OR (PROD_NCM_IBPT.PNCM_NCM = SUBSTRING(PRODUTO.CD_FISCAL FROM 2 FOR 7))) AND ' +
//                      '        (PROD_NCM_IBPT.PNCM_TABELA = 0) AND ' +
//                      '        (PROD_NCM_IBPT.PNCM_EX_TARIFARIOS IS NULL)) ' +
//                      'WHERE ' +
//                      '    PRODUTO.FL_ATIVO = ''S'' AND ' +
//                      '    COALESCE(CAST(PRODUTO.DT_ATZ AS DATE), CAST(' + QUOTEDSTR(ADTATZ) + ' AS DATE)) >= ' + QUOTEDSTR(ADTATZ) + ' AND ' +
//                      '    PRODUTO.FL_SERVICO = ''P'' AND ' +
//                      '    PRODUTO.CD_TIPO IN (' + CONFIGSERVER.TIPOPRODUTOCARGA + ') ' +
//                      'ORDER BY PRODUTO.CD_PRODUTO', TMPDATASET);

    if TmpDataset.IsEmpty then
      Render(500, 'Não existe nenhum produto cadastrado na base de dados')
    else
      Render(TmpDataset, true);
  except
    on e: Exception do
    begin
      Render(500, 'Não existe nenhum produto cadastrado na base de dados');
      MVCFramework.Logger.LogE('Erro na GetProdutos:' + e.Message);
    end;
  end;

end;

procedure TNFCeController.GetQtProduto(ACNPJ: String);
var
  TmpDataset: TDataSet;
begin
//  try
//    FDConexao.ExecSQL(' SELECT count(CD_PRODUTO) as Qtd ' + ' from  ' + '    produto ' + '  WHERE   ' + '      PRODUTO.fl_ativo =''S''   ' +
//       '    AND   ' + '      PRODUTO.FL_SERVICO = ''P''   ' + '    AND   ' + '      PRODUTO.cd_tipo IN (' + ConfigServer.tipoProdutoCarga + ')   '
//
//       , TmpDataset);
//
//    if TmpDataset.IsEmpty then
//      Render(500, 'Erro Busca total Prrodutos')
//    else
//      Render(TmpDataset, true);
//  except
//    on e: Exception do
//    begin
//      Render(500, 'Erro Busca total Prrodutos');
//      MVCFramework.Logger.LogE('Erro na GetQTProduto:' + e.Message);
//    end;
//  end;

end;

procedure TNFCeController.GetSaldoEstoque(ACNPJ: String; AidDeposito: String);
var
  TmpDataset: TDataSet;
begin
//  try
//    FDConexao.ExecSQL(
//
//       '  SELECT  ' + '      SALDO_ESTOQUE.CD_PRODUTO,  ' + '      SUM( CAST(COALESCE(SALDO_ESTOQUE.QT_ESTOQUE,0) AS NUMERIC (9,3))) AS QT_ESTOQUE  '
//       + '  FROM  ' + '    (  ' + '  SELECT  ' + '  		  MOBILEMOVIMENTOESTOQUE.CD_PRODUTO,   ' +
//       '  		  SUM( CAST(COALESCE(MOBILEMOVIMENTOESTOQUE.QT_PRODUTO,0) AS NUMERIC (9,3))) AS QT_ESTOQUE  ' + '  	   FROM   ' +
//       '  		  MOBILEMOVIMENTOESTOQUE   ' + '  		  JOIN PRODUTO ON PRODUTO.CD_PRODUTO = MOBILEMOVIMENTOESTOQUE.CD_PRODUTO    ' + '  	   WHERE   '
//       + '  		  MOBILEMOVIMENTOESTOQUE.ID_DEPOSITO =   ' + AidDeposito + '  	   AND     ' + '  		  PRODUTO.CD_TIPO IN ( ' +
//       ConfigServer.tipoProdutoCarga + ')  ' + '  	   GROUP BY   ' + '  		  MOBILEMOVIMENTOESTOQUE.CD_PRODUTO  ' + '    ' + '  	  UNION  ' + '    '
//       + '  	  SELECT  ' + '  		VIEW_MOBILESAIDA.CD_PRODUTO,  ' + '  		VIEW_MOBILESAIDA.QT_ESTOQUE  ' + '  	  FROM  ' + '  		VIEW_MOBILESAIDA  '
//       + '  	  WHERE  ' + '  		VIEW_MOBILESAIDA.ID_DEPOSITO = ' + AidDeposito + '      ) AS SALDO_ESTOQUE  ' + '    ' + '  GROUP BY  ' +
//       '  	SALDO_ESTOQUE.CD_PRODUTO  ' + '  HAVING  ' + '  	SUM( CAST(COALESCE(SALDO_ESTOQUE.QT_ESTOQUE,0) AS NUMERIC (9,3))) <> 0  ', TmpDataset);

//    if TmpDataset.IsEmpty then
//      Render(500, 'saldoestoque Nao localizada')
//    else
//      Render(TmpDataset, true);

//  except
//    on e: Exception do
//    begin
//      Render(500, 'saldoestoque Nao localizada');
//      MVCFramework.Logger.LogE('Erro na GetSaldoEstoque:' + e.Message);
//    end;
//  end;

end;

procedure TNFCeController.GetStatusCarga(ACNPJ: String; Adispositivo: String);
var
  TmpDataset: TDataSet;
begin
  try
    FDConexao.ExecSQL(' SELECT ' + '   COALESCE(RECEBE_CARGA, ''N'') AS RECEBE_CARGA ' + ' FROM ' + '   CONFIG_MOBILE ' + ' WHERE ' +
       '  UPPER(ID_DISPOSITIVO) = UPPER(' + QuotedStr(Adispositivo) + ')', TmpDataset);

    if TmpDataset.IsEmpty then
      Render(500, 'Sem informacoes')
    else
      Render(TmpDataset, true);
  except
    on e: Exception do
    begin
      Render(500, 'Sem informacoes');
      MVCFramework.Logger.LogE('Erro na GetStatusCarga:' + e.Message);
    end;
  end;

end;

procedure TNFCeController.getUltimaContagem(ACNPJ: String; Aecf: integer);
var
  TmpDataset: TDataSet;
begin
  try
    FDConexao.ExecSQL('  SELECT   ' + '      CONTAGEM_MOBILE_C.ID, ' + '      CONTAGEM_MOBILE_C.NR_ECF,   ' +
       '      CONTAGEM_MOBILE_C.NM_DEPOSITO,   ' + '      cast(CONTAGEM_MOBILE_C.DATA as date) as DATA,   ' + '      CONTAGEM_MOBILE_C.CD_USUARIO,   '
       + '      NFSI.CD_PRODSERV AS CD_PRODUTO,   ' + '      PRODUTO.CD_BARRAS,   ' + '      PRODUTO.NM_PRODUTO,   ' +
       '      COALESCE(CONTAGEM_MOBILE_I.QT_PRODUTO,0) AS QTCONTAGEM,   ' +
       '      COALESCE(CONTAGEM_MOBILE_I.QT_PRODUTO * PRODUTO.PESO_LIQUIDO,0)  AS PESOCONTAGEM,   ' +
       '      COALESCE(SUM(NFSI.QT_PRODUTO),0) AS QTNFSI,   ' + '      COALESCE(SUM(NFSI.PESO_LIQUIDO),0) AS PESONFSI,   ' +
       '      COALESCE(CONTAGEM_MOBILE_I.QT_PRODUTO,0) - COALESCE(SUM(NFSI.QT_PRODUTO),0) AS SALDO,   ' +
       '      COALESCE(CONTAGEM_MOBILE_I.QT_PRODUTO * PRODUTO.PESO_LIQUIDO,0) - COALESCE(SUM(NFSI.PESO_LIQUIDO),0) AS SALDOPESO   ' + '  FROM   ' +
       '      NFSI   ' + '      JOIN NFSC ON NFSC.NR_DOCUMENTO = NFSI.NR_DOCUMENTO   ' +
       '      JOIN CONTAGEM_MOBILE_C ON (NFSC.ID_CONTAGEMMOBILE = CONTAGEM_MOBILE_C.ID AND CONTAGEM_MOBILE_C.STATUS = 1)   ' +
       '      LEFT JOIN CONTAGEM_MOBILE_I ON (CONTAGEM_MOBILE_I.CD_PRODUTO = NFSI.CD_PRODSERV) AND NFSI.NR_DOCUMENTO = NFSC.NR_DOCUMENTO   ' +
       '      JOIN PRODUTO ON PRODUTO.CD_PRODUTO = NFSI.CD_PRODUTO   ' + '  WHERE   ' + '      CONTAGEM_MOBILE_C.NR_ECF =    ' + Aecf.ToString +
       '  AND   ' + '      CONTAGEM_MOBILE_I.CD_PRODUTO IS NULL   ' + '   AND                  ' + '      NFSI.CD_CANCELAMENTO <>99 ' +
       '  GROUP BY   ' + '      CONTAGEM_MOBILE_C.ID, ' + '      CONTAGEM_MOBILE_C.NR_ECF,   ' + '      CONTAGEM_MOBILE_C.NM_DEPOSITO,   ' +
       '      CONTAGEM_MOBILE_C.DATA,   ' + '      CONTAGEM_MOBILE_C.CD_USUARIO,   ' + '      CD_PRODUTO,   ' + '      PRODUTO.CD_BARRAS,   ' +
       '      PRODUTO.NM_PRODUTO,   ' + '      QTCONTAGEM,   ' + '      PESOCONTAGEM  ORDER BY CONTAGEM_MOBILE_I.SEQUENCIA ' + '  UNION   ' +
       '  SELECT   ' + '      CONTAGEM_MOBILE_C.ID, ' + '      CONTAGEM_MOBILE_C.NR_ECF,   ' + '      CONTAGEM_MOBILE_C.NM_DEPOSITO,   ' +
       '      cast(CONTAGEM_MOBILE_C.DATA as date) as DATA,   ' + '      CONTAGEM_MOBILE_C.CD_USUARIO,   ' +
       '      CONTAGEM_MOBILE_I.CD_PRODUTO AS CD_PRODUTO,   ' + '      PRODUTO.CD_BARRAS,   ' + '      PRODUTO.NM_PRODUTO,   ' +
       '      COALESCE(CONTAGEM_MOBILE_I.QT_PRODUTO,0) AS QTCONTAGEM,   ' +
       '      COALESCE(CONTAGEM_MOBILE_I.QT_PRODUTO * PRODUTO.PESO_LIQUIDO,0)  AS PESOCONTAGEM,   ' +
       '      COALESCE(SUM(NFSI.QT_PRODUTO),0) AS QTNFSI,   ' + '      COALESCE(SUM(NFSI.PESO_LIQUIDO),0) AS PESONFSI,   ' +
       '      COALESCE(CONTAGEM_MOBILE_I.QT_PRODUTO,0) - COALESCE(SUM(NFSI.QT_PRODUTO),0) AS SALDO,   ' +
       '      COALESCE(CONTAGEM_MOBILE_I.QT_PRODUTO * PRODUTO.PESO_LIQUIDO,0) - COALESCE(SUM(NFSI.PESO_LIQUIDO),0) AS SALDOPESO   ' + '  FROM   ' +
       '      CONTAGEM_MOBILE_I   ' + '      JOIN PRODUTO ON PRODUTO.CD_PRODUTO = CONTAGEM_MOBILE_I.CD_PRODUTO   ' +
       '      JOIN CONTAGEM_MOBILE_C ON (CONTAGEM_MOBILE_C.ID = CONTAGEM_MOBILE_I.ID_CONTAGEM_C AND CONTAGEM_MOBILE_C.STATUS = 1)   ' +
       '      LEFT JOIN NFSC ON NFSC.ID_CONTAGEMMOBILE = CONTAGEM_MOBILE_C.ID   ' +
       '      LEFT JOIN NFSI ON CONTAGEM_MOBILE_I.CD_PRODUTO = NFSI.CD_PRODSERV AND NFSI.NR_DOCUMENTO = NFSC.NR_DOCUMENTO AND COALESCE(NFSI.CD_CANCELAMENTO,0) = 0   '
       + '  WHERE   ' + '      CONTAGEM_MOBILE_C.NR_ECF =   ' + Aecf.ToString + '  GROUP BY   ' + '      CONTAGEM_MOBILE_C.ID, ' +
       '      CONTAGEM_MOBILE_C.NR_ECF,   ' + '      CONTAGEM_MOBILE_C.NM_DEPOSITO,   ' + '      CONTAGEM_MOBILE_C.DATA,   ' +
       '      CONTAGEM_MOBILE_C.CD_USUARIO,   ' + '      CD_PRODUTO,   ' + '      PRODUTO.CD_BARRAS,   ' + '      PRODUTO.NM_PRODUTO,   ' +
       '      QTCONTAGEM,   ' + '      PESOCONTAGEM  ORDER BY CONTAGEM_MOBILE_I.SEQUENCIA ', TmpDataset);

    if TmpDataset.IsEmpty then
      Render(500, 'Sem informacoes')
    else
      Render(TmpDataset, true);
  except
    on e: Exception do
    begin
      Render(500, 'Sem informacoes');
      MVCFramework.Logger.LogE('Erro na GetUltimaContagem:' + e.Message);
    end;
  end;
end;

procedure TNFCeController.GetUsuarios(ACNPJ: String);
var
  TmpDataset: TDataSet;
begin
  try
    FDConexao.ExecSQL('   SELECT   ' + '     FUNCIONARIO.CD_FUNCIONARIO CD_USUARIO,   ' + '     UPPER(FUNCIONARIO.LOGIN) NOME,   ' +
       '     UPPER(FUNCIONARIO.LOGIN)EMAIL,   ' + '     COALESCE(SENHA_MOBILE,FUNCIONARIO.CD_FUNCIONARIO) as SENHA,   ' +
       '     COALESCE(ID_TIPOUSUARIOMOBILE,3)  AS CD_PERFIL      ,  ' + '     COALESCE(FL_VENDEDOR,''N'') AS FL_VENDEDOR,  ' +
       '     ''N'' AS FL_CONFERENTE,  ' + '     ''S'' FL_ATIVO  ' + '   FROM  ' + '     FUNCIONARIO    ' +
       '   		JOIN CARGO ON CARGO.CD_CARGO = FUNCIONARIO.CD_CARGO   ' + '   WHERE     ' + '     COALESCE(ID_TIPOUSUARIOMOBILE,0) > 0   ', TmpDataset);

    if TmpDataset.IsEmpty then
      Render(500, 'Erro Busca usuarios')
    else
      Render(TmpDataset, true);
  except
    on e: Exception do
    begin
      Render(500, 'Erro Busca usuarios');
      MVCFramework.Logger.LogE('Erro na GetUsuarios:' + e.Message);
    end;
  end;
end;

procedure TNFCeController.GetPermissao(ACNPJ: String);
var
  TmpDataset: TDataSet;
begin
  try
    FDConexao.ExecSQL(' SELECT  ' + '  ID,  ' + '  SANGRIA        ,  ' + '  SUPRIMENTO     ,  ' + '  ABERTURA_CXA   ,  ' + '  FECHAMENTO_CXA ,  ' +
       '  CANCELAMENTO_I ,  ' + '  CANCELAMENTO_C ,  ' + '  REIMPRESSAO    ,  ' + '  GERENCIAL      ,  ' + '  CONFIGURACAO   ,  ' +
       '  ESTOQUE        ,  ' + '  GAVETA         ,  ' + '  SITEF          ,  ' + '  EST_ZERA       ,  ' + '  EST_LANCAMENTO ,  ' +
       '  EST_CONFERENCIA,  ' + ' 0 as CD_USUARIO,  ' + '  EST_RELATORIO    ' + ' from  ' + '    PERMISSAOMOBILE  ', TmpDataset);

    if TmpDataset.IsEmpty then
      Render(500, 'Erro ao buscar a permissao')
    else
      Render(TmpDataset, true);
  except
    on e: Exception do
    begin
      Render(500, 'Erro ao buscar a permissao');
      MVCFramework.Logger.LogE('Erro na GetPermissao:' + e.Message);
    end;
  end;
end;

procedure TNFCeController.GetNFCeXML(ANumero, ASerie: integer);
var
  DmNFCe: TdtmNFCe;
begin
  DmNFCe := TdtmNFCe.Create(nil);
  try
    Render(DmNFCe.GerarXML(ANumero, ASerie));
    ContentType := 'application/xml';
  finally
    DmNFCe.Free;
  end;
end;

procedure TNFCeController.GetNota(ACNPJ: String; Achavecanfe: String);
var
  TmpDataset: TDataSet;
begin
  try
    FDConexao.ExecSQL('select first 1 nr_documento  from NFSC where chave_danfe =' + QuotedStr(Achavecanfe), TmpDataset);

    if TmpDataset.IsEmpty then
      Render(800, 'INEXISTENTE')
    else
      Render(TmpDataset, true);
  except
    on e: Exception do
    begin
      Render(800, 'INEXISTENTE');
      MVCFramework.Logger.LogE('Erro na GetNota:' + e.Message);
    end;
  end;
end;

procedure TNFCeController.GetNFCePDF(ANumero, ASerie: integer);
var
  DmNFCe: TdtmNFCe;
  PathPDF: string;
  StreamPDF: TMemoryStream;
  arquivoXml: string;
  config: TNFCeEmpresa;
begin

  config := fBuscarDadosEmpresa;
  arquivoXml := fBuscarXML(ANumero, ASerie, '65');
  if trim(arquivoXml) <> '' then
  begin
    DmNFCe := TdtmNFCe.Create(nil);
    try
      PathPDF := DmNFCe.GerarPDF(arquivoXml, config);

      StreamPDF := TMemoryStream.Create;
      try
        StreamPDF.LoadFromFile(PathPDF);

        Render(StreamPDF, true);
        ContentType := 'application/pdf';
      except
        on e: Exception do
        begin
          if Assigned(StreamPDF) then
            StreamPDF.Free;
        end;
      end;
    finally
      DmNFCe.Free;
    end;
  end;
end;

procedure TNFCeController.GetNFCe(ACNPJ: String; ANumero: integer; ASerie: integer; ATipo: string);
begin
  if ATipo.ToUpper = 'XML' then
    self.GetNFCeXML(ANumero, ASerie)
  else if ATipo.ToUpper = 'PDF' then
    self.GetNFCePDF(ANumero, ASerie)
  else if ATipo.ToUpper = 'ESCPOS' then
    self.GetNFCeEscPOS(ANumero, ASerie)
  else
    MVCFramework.Logger.LogE('tipo de saida desconhecida');
end;

procedure TNFCeController.GetNFCeEscPOS(ANumero, ASerie: integer);
begin
  { todo: implementar retorno string escpos }
end;

procedure TNFCeController.GeraNfce(ACNPJ: String);
var
  DmNFCe: TdtmNFCe;
  config: TNFCeEmpresa;
  Nota: TNFCe;
  vNumeracaoNota: integer;
  retorno: TNFCeRetACBR;
begin
  try
    FDConexao.StartTransaction;
    Nota := Context.Request.BodyAs<TNFCe>;
    retorno := TNFCeRetACBR.Create;

    //Consulta no banco do server se a nota ja está autorizada
    retorno.xml := fExisteNota(Nota.idDispositivo.ToInteger, 0, Nota.nrSerie,
                               Nota.nrNota, ACNPJ);

    if retorno.xml = '' then
    begin
      try
        DmNFCe := TdtmNFCe.Create(nil);
        config := fBuscarDadosEmpresa;
        DmNFCe.PreencherNFCe(FDConexao, Nota, config);
        retorno := DmNFCe.Enviar;
        if retorno.autorizou then
        begin
          fGravarAutServer(ACNPJ, Nota.idDispositivo, retorno.ChaveDanfe, retorno.xml, retorno.xml, 0, Nota.nrSerie, Nota.nrNota);
          Nota.autProtocolo := retorno.protocolo;
          Nota.autChave := retorno.ChaveDanfe;
          Nota.xml := retorno.xml;
          Nota.autLote := retorno.lote;
          Nota.autRecibo := retorno.recibo;
          Nota.autSituacao := retorno.SituacaoNFCE;
          Nota.autDtProcessamento := retorno.DT_Autorizacao;
          Nota.autHrprocessamento := retorno.HR_autorizacao;
          Nota.Status := 2;
        end
        else
        begin
          Nota.autSituacao := retorno.SituacaoNFCE;
          Nota.Obs := retorno.Texto;
        end;

        try
          retorno.NrDocumentoServidor := '1'; //fGravarNfsc(Nota, ACNPJ);

          if retorno.NrDocumentoServidor.IsEmpty then
            FDConexao.Rollback
          else
            FDConexao.Commit;

        except
          on e: Exception do
            raise Exception.Create(e.Message);

        end;
      finally
        DmNFCe.Free;
      end;
    end;
    Render(200, retorno);
  finally
    Nota.Free;
  end;
end;

procedure TNFCeController.ConsultaNFCE(ACNPJ: String; ADocumento: string);
var
  TmpDataset: TDataSet;
  SQL: string;
begin
  try

    SQL := '  SELECT  ' + '      DT_PROCESSAMENTO_NFE,  ' + '      HR_PROCESSAMENTO_NFE,  ' + '      NR_PROTOCOLO_NFE,  ' + '      NR_LOTE_NFE,  ' +
       '      SITUACAO_NFCE,  ' + '      CHAVE_DANFE,  ' + '    case when cd_modelo = ''65'' then ' +
       '   CAST(  substring( xml.xml from (position (''<qrCode>'' in  xml.xml) + 17)  for  (position (''</qrCode>'' in  xml.xml)) - (position (''<qrCode>'' in  xml.xml) + 20) ) AS VARCHAR(10000)) else '''' end QR_CODE'
       + '  FROM  ' + '      NFSC  ' + '         JOIN XML ON XML.ID = NFSC.ID_XML ' + '  WHERE  ' + '      NFSC.NR_DOCUMENTO =   ' + ADocumento +
       ' AND ' + '      SITUACAO_NFCE IN (100,101) ';
    FDConexao.ExecSQL(

       SQL, TmpDataset);

    if TmpDataset.IsEmpty then
      Render(500, 'Não encontrado dados de autorizção ou cancelamento')
    else
      Render(200, TmpDataset);
  except
    on e: Exception do
    begin
      Render(500, 'Não encontrada');
      MVCFramework.Logger.LogE('Erro na GetConsultaNFCE:' + e.Message);
    end;
  end;
end;

procedure TNFCeController.CreateNFCe(ACNPJ: String);
var
  oNFCe: TNFCe;
  DmNFCe: TdtmNFCe;
  StrRetorno: string;
begin
  //
  try
    oNFCe := Context.Request.BodyAs<TNFCe>;
    try
      FDConexao.StartTransaction;
      StrRetorno := fGravarNfsc(oNFCe, ACNPJ);

      if (NOT StrRetorno.IsEmpty) then
      begin
        FDConexao.Commit;
        if fDadosConsistentes(StrRetorno.ToInteger) then
        begin
          Render(201, StrRetorno);
        end
        else
        begin
          pApagarRegistrosCupom(StrRetorno.ToInteger);
          Render(404, StrRetorno);
        end;
      end
      else
      begin
        FDConexao.Rollback;
        Render(404, StrRetorno);
      end;

      if oNFCe.Itens.Count <= 0 then
        exit;
      // MVCFramework.Logger.LogE('Nenhum item foi informado!');

      // DmNFCe := TdtmNFCe.Create(nil);
      // try
      // DmNFCe.PreencherNFCe(oNFCe);
      // StrRetorno := DmNFCe.Enviar;
      //
      // Render(201, StrRetorno);
      // finally
      // DmNFCe.Free;
      // end;
    finally
      if Assigned(oNFCe) then
        oNFCe.Free;
    end;
  except
    on e: Exception do
    begin
      Render(500, e.Message);
    end;
  end;
end;

procedure TNFCeController.CreateTeste;
var
  tmpDataSet: TDataSet;
begin
  FDConexao.ExecSQL('SELECT * FROM EMPRESA', tmpDataset);
  render(tmpDataset, True);
end;

procedure TNFCeController.FinalizaContagem(ACNPJ: String; Aecf: integer);
begin
  try
    if fFinalizaContagem(Aecf) then
      Render(200, 'SUCESSO')
    else
      Render(500, 'ERRO');

  except
    on e: Exception do
    begin
      Render(500, 'ERRO');
      MVCFramework.Logger.LogE('Erro na GetFinalizaContagem:' + e.Message);
    end;
  end;
end;

procedure TNFCeController.perfilAbastecimentoC(ACNPJ: String);
var
  TmpDataset: TDataSet;
begin
  try
    FDConexao.ExecSQL(' SELECT      ' + '   ID,        ' + '   DESCRICAO, ' + '   FL_ATIVO   ' + ' FROM           ' + '   PERFILABASTECIMENTO_C ',
       TmpDataset);

    if TmpDataset.IsEmpty then
      Render(500, 'Não existe CABECALHO abastecer')
    else
      Render(TmpDataset, true);
  except
    on e: Exception do
    begin
      Render(500, 'Não existe CABECALHO abastecer');
      MVCFramework.Logger.LogE('Erro na perfilAbastecimentoC:' + e.Message);
    end;
  end;
end;

procedure TNFCeController.perfilAbastecimentoI(ACNPJ: String);
var
  TmpDataset: TDataSet;
begin
  try
    FDConexao.ExecSQL('  SELECT ' + '    ID,  ' + '    CD_PRODUTO, ' + '    QT_PRODUTO, ' + '    FL_ATIVO, ' + '    ID_PERFILABASTECIMENTO_C ' +
       '  FROM ' + '    PERFILABASTECIMENTO_I', TmpDataset);

    if TmpDataset.IsEmpty then
      Render(500, 'Não existe produtos abastecer')
    else
      Render(TmpDataset, true);
  except
    on e: Exception do
    begin
      Render(500, 'Não existe produtos abastecer');
      MVCFramework.Logger.LogE('Erro na perfilAbastecimentoI:' + e.Message);
    end;
  end;
end;

end.
