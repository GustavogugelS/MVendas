unit uDmNfe;

interface

uses
  System.SysUtils, System.Classes, ACBrBase, ACBrDFe, ACBrNFe, System.Zip,
  ACBrUtil, System.IoUtils, pcnConversao, blcksock,
  pcnConversaoNfe, ACBrDFeReport, ACBrDFeDANFeReport, ACBrNFeDANFEClass,
  ACBrNFeDANFeESCPOS, StrUtils, uVenda, uConfiguracao;

type
  tpEvento = (EMISSAO, CANCELAMENTO);

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

  TdmNfe = class(TDataModule)
    ACBrNFe: TACBrNFe;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
    procedure ConfigurarAcbrNFe;
    procedure DescompactarSchemas;
    procedure ObterDadosAutorizacao(Evento: tpEvento = EMISSAO);
    function PreencherAcbrNFe(var Nota: TVenda): Boolean;
    function PreencherAcbrNFeEvento(var Nota: TVenda): Boolean;
  public
    { Public declarations }
    procedure EmitirNota;
    procedure CancelarNota;
    procedure ReimprimirNota;
  end;

var
  dmNfe: TdmNfe;

implementation

uses
  uDmPrincipal, uFrmVendas, uUtilitarios, ACBrLibXml2, ssl_openssl_lib,
  ACBrDFeSSL, ACBrDFeUtil, ACBrValidador, uImpressao;

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

{ TdmNfe }

procedure TdmNfe.DataModuleCreate(Sender: TObject);
begin
  ConfigurarAcbrNFe;
end;

function TdmNfe.PreencherAcbrNFe(var Nota: TVenda): Boolean;
var
  ValorTotalBCICMS,
  ValorTotalVLICMS,
  ValorTotalVLPIS,
  ValorTotalVLCOFINS,
  ValorTotalBCPIS,
  ValorTotalBCCOFINS,
  ValorTotalDesconto,
  ValorTotalNF: Currency;
  ok :Boolean;
  i: Integer;
  NFCeITem: TItem;
  NFCEItemPagamento : TPagamento;

begin
  ValorTotalBCICMS   := 0;
  ValorTotalVLICMS   := 0;
  ValorTotalBCCOFINS := 0;
  ValorTotalVLCOFINS := 0;
  ValorTotalBCPIS    := 0;
  ValorTotalVLPIS    := 0;
  ValorTotalNF       := 0;
  ValorTotalDesconto := 0;

  try
    ACBrNFe.NotasFiscais.Clear;
    with ACBrNFe.NotasFiscais.Add.NFe do
    begin
      Ide.natOp     := 'VENDA';
      Ide.indPag    := ipVista;
      Ide.modelo    := 65;
      Ide.tpNF      := tnSaida;
      Ide.tpEmis    := teNormal;
      Ide.finNFe      := fnNormal;
      Ide.indFinal    := cfConsumidorFinal;
      Ide.idDest      := doInterna;
      Ide.nNF         := Nota.nrNota;
      Ide.indPres     := TpcnPresencaComprador.pcPresencial;
      Ide.indIntermed := iiOperacaoSemIntermediador;
      Ide.serie       := Nota.nrSerie;
      Ide.dEmi        := Now;
      Ide.dSaiEnt     := Now;
      Ide.cUF         := empresa.UfCodigo;
      Ide.cMunFG      := empresa.IbgeCod;
      Ide.cNF         := 0;

      Emit.xNome             := empresa.RazaoSocial;
      Emit.xFant             := empresa.Fantasia;
      Emit.CNPJCPF           := empresa.Cnpj;
      Emit.IE                := empresa.Ie;
      Emit.IEST              := '';
      Emit.CNAE              := '';
      Emit.EnderEmit.fone    := empresa.Telefone;
      Emit.EnderEmit.xLgr    := empresa.Endereco;
      Emit.EnderEmit.nro     := empresa.Numero.ToString;
      Emit.EnderEmit.xCpl    := empresa.Complemento;
      Emit.EnderEmit.xBairro := empresa.bairro;
      Emit.EnderEmit.xMun    := empresa.Cidade;
      Emit.EnderEmit.cMun    := empresa.IbgeCod;
      Emit.EnderEmit.UF      := empresa.UF;
      Emit.EnderEmit.CEP     := empresa.Cep;
      Emit.enderEmit.cPais   := 1058;
      Emit.enderEmit.xPais   := 'BRASIL';

      case Empresa.regime of
        0: Emit.CRT := crtRegimeNormal;
        1: Emit.CRT := crtRegimeNormal;
        2: Emit.CRT := crtSimplesNacional;
      end;

      Emit.CRT := crtRegimeNormal;

      Dest.CNPJCPF     := rCliCupom.cpfCliente;
      Dest.xNome       := rCliCupom.nmCliente;
      Dest.indIEDest   := inNaoContribuinte;

      I := 0;
      for NFCeItem in Nota.Itens do
      begin
        Inc(I);

        With Det.New do
        begin
          Prod.nItem    := I;
          Prod.cProd    := NFCeItem.Cdbarras;
          Prod.xProd    := NFCeItem.descricao;
          Prod.NCM      := NFCeItem.ncm;
          Prod.CFOP     := NFCeItem.Cfop.ToString;
          Prod.CEST     := NFCeItem.Cest;
          Prod.cBenef   := '';
          Prod.cEAN     := 'SEM GTIN';
          Prod.cEANTrib := 'SEM GTIN';

          Prod.uCom     := NFCeItem.un;
          Prod.qCom     := NFCeItem.quantidade;
          Prod.vUnCom   := NFCeItem.vlBruto;
          Prod.vProd    := NFCeItem.quantidade * NFCeItem.vlBruto;
          Prod.vDesc    := NFCeItem.vlDesconto + NFCeItem.vlDescItem;
          ValorTotalDesconto := ValorTotalDesconto + Prod.vDesc;

          Prod.uTrib    := NFCeItem.un;
          Prod.qTrib    := NFCeItem.quantidade;
          Prod.vUnTrib  := NFCeItem.vlBruto;
          Prod.vOutro := 0;
          Prod.vFrete := 0;
          ValorTotalNF := ValorTotalNF + Prod.vProd;

          Imposto.ICMS.orig := TpcnOrigemMercadoria.oeNacional;

          // ICMS ********************************************************
          if Emit.CRT = crtRegimeNormal then
          begin
            Imposto.ICMS.CST := StrToCSTICMS(ok, Copy(NFCeItem.cstIcms, 2, 2));

            if NFCeItem.aliqIcms > 0 then
            begin
              Imposto.ICMS.vBC   := NFCeItem.vlBcIcms;
              Imposto.ICMS.pICMS := NFCeItem.aliqIcms;
              Imposto.ICMS.vICMS := NFCeItem.vlIcms;
              ValorTotalVLICMS := ValorTotalVLICMS + NFCeItem.vlIcms;
              ValorTotalBCICMS := ValorTotalBCICMS + NFCeItem.vlBcIcms;
            end;
          end
          else
          begin //Simples nacional
            Imposto.ICMS.CSOSN := StrToCSOSNIcms(ok, Copy(NFCeItem.cstIcms, 2, 2));
            Imposto.ICMS.vBC   := 0;
            Imposto.ICMS.pICMS := 0;
            Imposto.ICMS.vICMS := 0;
            ValorTotalVLICMS             := ValorTotalVLICMS + 0;
            ValorTotalBCICMS             := ValorTotalBCICMS + 0;
          end;

          Imposto.ICMS.pCredSN     := 0.00;
          Imposto.ICMS.vCredICMSSN := 0.00;

          {ICMS EFETIVO}
          if (Copy(NFCeItem.cstIcms, 2, 2) = '60') then
          begin
            Imposto.ICMS.pRedBCEfet := 0;
            Imposto.ICMS.vBCEfet    := 0;
            Imposto.ICMS.pICMSEfet  := 0;
            Imposto.ICMS.vICMSEfet  := 0;
          end;

          // PIS *******************************************************
          Imposto.PIS.CST       := StrToCSTPIS(ok,  NFCeItem.cstPisCofins);
          Imposto.PIS.vBC       := NFCeItem.vlBcPis;
          Imposto.PIS.pPIS      := NFCeItem.aliqPis;
          Imposto.PIS.vPIS      := NFCeItem.vlPis;
          Imposto.PIS.qBCProd   := 0; //Não será utilizado (Calculo Aliq Específica)
          Imposto.PIS.vAliqProd := 0; //Não será utilizado (Calculo Aliq Específica)
          ValorTotalVLPIS :=  ValorTotalVLPIS +  Imposto.PIS.vPIS;
          ValorTotalBCPIS :=  ValorTotalBCPIS +  Imposto.PIS.vBC;

          // COFINS ******************************************************
          Imposto.COFINS.CST       := StrToCSTCOFINS(ok,  NFCeItem.cstPisCofins);
          Imposto.COFINS.vBC       := NFCeItem.vlBcCofins;
          Imposto.COFINS.pCOFINS   := NFCeItem.aliqCofins;
          Imposto.COFINS.vCOFINS   := NFCeItem.vlCofins;
          Imposto.COFINS.qBCProd   := 0; //Não será utilizado (Calculo Aliq Específica)
          Imposto.COFINS.vAliqProd := 0; //Não será utilizado (Calculo Aliq Específica)
          ValorTotalVLCOFINS :=  ValorTotalVLCOFINS + Imposto.COFINS.vCOFINS;
          ValorTotalBCCOFINS := ValorTotalBCCOFINS  +  Imposto.COFINS.vBC;
        end;

      end;

      {Pagamentos}
      for NFCEItemPagamento in Nota.Pagamentos do
      begin
        pag.vTroco := NFCEItemPagamento.VlTroco;
        with pag.New do
        begin
          case NFCEItemPagamento.Tipo of
            1:  tPag := TpcnFormaPagamento.fpDinheiro;
            2:  tPag := TpcnFormaPagamento.fpCheque;
            3:  tPag := TpcnFormaPagamento.fpCartaoCredito;
            4:  tPag := TpcnFormaPagamento.fpCartaoDebito;
            5:  tPag := TpcnFormaPagamento.fpCreditoLoja;
            10: tPag := TpcnFormaPagamento.fpValeAlimentacao;
            11: tPag := TpcnFormaPagamento.fpValeRefeicao;
            12: tPag := TpcnFormaPagamento.fpValePresente;
            13: tPag := TpcnFormaPagamento.fpValeCombustivel;
            15: tPag := TpcnFormaPagamento.fpBoletoBancario;
            90: tPag := TpcnFormaPagamento.fpSemPagamento;
            99: tPag := TpcnFormaPagamento.fpOutro;
          end;

          vPag := NFCEItemPagamento.VlTotal;
          tpIntegra := tiPagNaoIntegrado;


  //        if ANFCe.TransacoesTEF <> nil then
  //        begin
  //          for NFCEItemTEF in ANFCe.TransacoesTEF do
  //          begin
  //            if NFCEItemTEF.Nr_documento = NFCEItemPagamento.NrDocumento then
  //            begin
  //              if NFCEItemTEF.bandeira = '' then
  //              begin
  //                 Buffer.Text:= NFCEItemTEF.Obs;
  //                 NFCEItemTEF.bandeira := Trim(Buffer.Strings[2]);
  //              end;
  //
  //              if NFCEItemTEF.bandeira.Contains('VISA') then
  //                OPagto.tBand := TpcnBandeiraCartao.bcVisa
  //              else if NFCEItemTEF.bandeira.Contains('MASTER') THEN
  //                OPagto.tBand := TpcnBandeiraCartao.bcMasterCard
  //              else if NFCEItemTEF.bandeira.Contains('AMERIC') THEN
  //                OPagto.tBand := TpcnBandeiraCartao.bcAmericanExpress
  //              else if NFCEItemTEF.bandeira.Contains('SORO') THEN
  //                OPagto.tBand := TpcnBandeiraCartao.bcSorocred
  //              else if NFCEItemTEF.bandeira.Contains('DIN') THEN
  //                OPagto.tBand := TpcnBandeiraCartao.bcDinersClub
  //              else if NFCEItemTEF.bandeira.Contains('ELO') THEN
  //                OPagto.tBand := TpcnBandeiraCartao.bcElo
  //              else if NFCEItemTEF.bandeira.Contains('HIPE') THEN
  //                OPagto.tBand := TpcnBandeiraCartao.bcHipercard
  //              else if NFCEItemTEF.bandeira.Contains('AURA') THEN
  //                OPagto.tBand := TpcnBandeiraCartao.bcAura
  //              else if NFCEItemTEF.bandeira.Contains('CABAL') THEN
  //                OPagto.tBand := TpcnBandeiraCartao.bcCabal
  //              else
  //                OPagto.tBand := TpcnBandeiraCartao.bcOutros;
  //
  //              OPagto.CNPJ  := fBuscarCNPJAdministradora(Conexao,NFCEItemTEF.administrador);//'';//'02727867000179';
  //              OPagto.cAut  := NFCEItemTEF.Nr_transacao;
  //            end;
  //            OPagto.tpIntegra := tiPagIntegrado;
  //          end;
  //        end;

          if tPag in [TpcnFormaPagamento.fpDinheiro, TpcnFormaPagamento.fpCartaoDebito] then
            indPag := TpcnIndicadorPagamento.ipVista
          else
            indPag := TpcnIndicadorPagamento.ipPrazo;
        end;
      end;

      //Totais da nota fiscal
      Total.ICMSTot.vBC      := ValorTotalBCICMS;
      Total.ICMSTot.vICMS    := ValorTotalVLICMS;
      Total.ICMSTot.vBCST    := 0.00;
      Total.ICMSTot.vST      := 0.00;
      Total.ICMSTot.vProd    := ValorTotalNF;
      Total.ICMSTot.vDesc    := ValorTotalDesconto;
      Total.ICMSTot.vPIS     := ValorTotalVLPIS;
      Total.ICMSTot.vCOFINS  := ValorTotalVLCOFINS;
      Total.ICMSTot.vFCP     := 0.00;
      Total.ICMSTot.vNF      := ValorTotalNF - ValorTotalDesconto;
      Total.ICMSTot.vTotTrib := 0.00;
      Total.ICMSTot.vFrete  := 0;
      Total.ICMSTot.vOutro  := 0;

      Transp.modFrete := mfSemFrete;

      infRespTec.CNPJ := '87.636.817/0001-39';
      infRespTec.xContato := 'Gustavo Schwarz';
      infRespTec.email := 'guto.bajo@gmail.com';
      infRespTec.fone := '49991538905';
    end;
  except on E: Exception do
    Log('Erro ao preencher ACBrNFe : ', E.Message);
  end;
end;


function TdmNfe.PreencherAcbrNFeEvento(var Nota: TVenda): Boolean;
begin
  ACBrNFe.EventoNFe.Evento.Clear;
  with ACBrNFe.EventoNFe.Evento.New do
  begin
    infEvento.chNFe := Nota.autChave;
    infEvento.CNPJ := Empresa.Cnpj;
    infEvento.dhEvento := Now;
    infEvento.tpEvento := teCancelamento;
    infEvento.detEvento.xJust := 'Cancelamento de Nfc-e';
    infEvento.detEvento.nProt := Nota.autProtocolo;
  end;
end;

procedure TdmNfe.ReimprimirNota;
var
  Nota: TVenda;
begin
  Nota := TVenda.Create;
  dmPrincipal.DadosDaNota(rCupom.nrDocumento, Nota);

  try
    ACBrNFe.NotasFiscais.LoadFromString(Nota.xml);
    ACBrNFe.NotasFiscais.Imprimir;
    ACBrNFe.NotasFiscais.Clear;
  finally
    Nota.Free;
  end;
end;

procedure TdmNfe.EmitirNota;
var
  Nota: TVenda;

begin
  Nota := TVenda.Create;
  dmPrincipal.DadosDaNota(rCupom.nrDocumento, Nota);

  try
    PreencherAcbrNFE(Nota);
  finally
    Nota.Free;
  end;

  rCupom.autNrLote := FormatDateTime('yymmddhhmm', NOW);

  try
    AcbrNfe.NotasFiscais.GerarNFe;
    AcbrNfe.NotasFiscais.Assinar;
    AcbrNFe.NotasFiscais.GravarXML;
    ACbrNfe.Enviar(rCupom.autNrLote, False, True);
    ACbrNfe.NotasFiscais.Imprimir;

    ObterDadosAutorizacao(EMISSAO);
  except on E: Exception do
    begin
      Log('Erro EmitirNota : ', e.message);
      if ACbrNfe.NotasFiscais <> nil then
        ACbrNfe.NotasFiscais.Imprimir;
    end;
  end;

end;

procedure TdmNfe.ObterDadosAutorizacao(Evento: tpEvento);
begin
  if Evento = EMISSAO then
  begin
    rCupom.autSituacaoNfce := ACBrNFe.WebServices.Enviar.cStat.ToString;
    rCupom.autXmlVenda := ACBrNFe.NotasFiscais[0].XMLAssinado;
    rCupom.autNrProtocolo := ACBrNFe.NotasFiscais[0].NFe.procNFe.nProt;
  end
  else
  begin
    rCupom.autSituacaoNfce :=
      ACBrNFe.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0].RetInfEvento.cStat.ToString;
    rCupom.autXmlVenda :=
      ACBrNFe.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0].RetInfEvento.XML;
    rCupom.autNrProtocolo :=
      ACBrNFe.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0].RetInfEvento.nProt;
  end;

  rCupom.autChaveDanfe := ACBrNFe.NotasFiscais[0].NFe.procNFe.chNFe;
  rCupom.autDtProcessamento := FormatDateTime('dd/mm/yyyy', Date);
  rCupom.autHrprocessamento := FormatDateTime('hh:nn:ss', Now);
  rCupom.autRecibo := ACBrNFe.WebServices.Recibo.NFeRetorno.nRec;
end;

procedure TdmNfe.CancelarNota;
var
  Nota: TVenda;
begin
  Nota := TVenda.Create;
  dmPrincipal.DadosDaNota(rCupom.nrDocumento, Nota);
  PreencherAcbrNFeEvento(Nota);
  rCupom.autNrLote := Nota.autLote;

  try
    try
      ACBrNFe.EnviarEvento(StrToInt(rCupom.autNrLote));
      ObterDadosAutorizacao(CANCELAMENTO);
    except on E: Exception do
      begin
        Log('CancelarNota', e.message);
      end;
    end;

  finally
    Nota.Free;
  end;
end;

procedure TdmNfe.ConfigurarAcbrNFe;
var
  CertPFX: string;
begin
  {CERTIFICADO}
  CertPFX := '';
  if (ExtractFilePath(CertPFX) = 'cert.pfx') then
    CertPFX := ApplicationPath + CertPFX;

  ACBrNFe.Configuracoes.Certificados.URLPFX := configuracao.UrlPFX;
  ACBrNFe.Configuracoes.Certificados.ArquivoPFX := CertPFX;
  ACBrNFe.Configuracoes.Certificados.Senha := configuracao.SenhaPFX;
  ACBrNFe.SSL.URLPFX := ACBrNFe.Configuracoes.Certificados.URLPFX;
  ACBrNFe.SSL.ArquivoPFX := ACBrNFe.Configuracoes.Certificados.ArquivoPFX;
  ACBrNFe.SSL.Senha := ACBrNFe.Configuracoes.Certificados.Senha;

  {AMBIENTE}
  ACBrNFe.Configuracoes.WebServices.UF := empresa.UF;
  ACBrNFe.Configuracoes.WebServices.Ambiente := TpcnTipoAmbiente(configuracao.Ambiente);
  ACBrNFe.Configuracoes.WebServices.TimeOut := Trunc(10000);
  ACBrNFe.Configuracoes.Geral.SSLLib := TSSLLib.libOpenSSL;
  ACBrNFe.Configuracoes.WebServices.SSLType := TSSLType(configuracao.TipoSSL);
  ACBrNFe.Configuracoes.Geral.IdCSC := configuracao.IdCsc.ToString;
  ACBrNFe.Configuracoes.Geral.CSC := configuracao.Csc;

  // Sugestão de configuração para apresentação de mensagem mais amigável ao usuário final
  ACBrNFe.Configuracoes.Geral.ExibirErroSchema := True;
  ACBrNFe.Configuracoes.Geral.FormatoAlerta := 'Campo:%DESCRICAO% - %MSG%';

  {CASH LOCAL}
  ACBrNFe.Configuracoes.WebServices.Salvar := False;
  ACBrNFe.Configuracoes.Arquivos.PathNFe := TPath.Combine(ApplicationPath, 'xml');
  ACBrNFe.Configuracoes.Arquivos.PathEvento := ACBrNFe.Configuracoes.Arquivos.PathNFe;
  ACBrNFe.Configuracoes.Arquivos.PathInu := ACBrNFe.Configuracoes.Arquivos.PathNFe;
  ACBrNFe.Configuracoes.Arquivos.PathSalvar := TPath.Combine(TPath.Combine(ApplicationPath, 'xml'), 'soap');

  {SCHEMAS}
  DescompactarSchemas;
end;

procedure TdmNfe.DescompactarSchemas;
var
  BasePathSchemas, SchemasZip, ArquivoControle: string;
  ZipFile: TZipFile;
  Descompactar: Boolean;
  dtSchema, dtControle: TDateTime;
begin
  BasePathSchemas := ApplicationPath + 'Schemas';
  ArquivoControle := TPath.Combine(BasePathSchemas, 'leiame.txt');
  ACBrNFe.Configuracoes.Arquivos.PathSchemas := TPath.Combine(BasePathSchemas, 'NFe');
  {$IfDef MSWINDOWS}
   SchemasZip := '..\..\Schemas.zip';
  {$Else}
   SchemasZip := TPath.Combine( TPath.GetDocumentsPath, 'Schemas.zip' );
  {$EndIf}
  if not FileExists(SchemasZip) then
    Exit;

  Descompactar := not FileExists( ArquivoControle );
  if not (Descompactar) then
  begin
    FileAge(SchemasZIP, dtSchema);
    FileAge(ArquivoControle, dtControle);
    Descompactar := (dtSchema > dtControle);
  end;

  if Descompactar then
  begin
    ZipFile := TZipFile.Create;
    try
      ZipFile.Open(SchemasZip, zmReadWrite);
      ZipFile.ExtractAll(BasePathSchemas);
    finally
      ZipFile.Free;
    end;

    // Criando arquivo de controle
    System.SysUtils.DeleteFile(ArquivoControle);
    WriteToFile(ArquivoControle,'https://www.projetoacbr.com.br/');
  end;
end;

end.
