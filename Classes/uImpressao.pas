unit uImpressao;

interface
uses
  GEDIPrinter,
  G700Interface,
  System.SysUtils,
  FireDAC.Comp.Client,
  System.Classes;

  type
  TImpressao = class
    private

    public
      procedure impTeste;
      procedure ImprimirExtratoVenda;
      procedure ImprimirGerencial(qry: TFDQuery);
  end;

  var imprimir: TImpressao;

implementation

uses
  uFrmVendas, uDmPrincipal;

{ TImpressao }

procedure TImpressao.ImprimirGerencial(qry: TFDQuery);
var
  text: TStringList;
  totalVenda: Currency;
  totalCancelado: Currency;
  totalReforco: Currency;
  totalSangria: Currency;

  procedure CarregarTotais;
  begin
    qry.First;
    while not qry.Eof do
    begin
      totalVenda := totalVenda + qry.FieldByName('VL_TOTAL').AsCurrency;
      totalCancelado := totalCancelado + qry.FieldByName('VL_CANCELADO').AsCurrency;

      if qry.FieldByName('TIPO').AsString = 'R' then
        totalReforco := totalReforco + qry.FieldByName('VL_TOTAL').AsCurrency
      else if qry.FieldByName('TIPO').AsString = 'S' then
        totalSangria := totalSangria + qry.FieldByName('VL_TOTAL').AsCurrency;

      qry.Next;
    end;
  end;

begin
  totalVenda := 0;
  totalCancelado := 0;
  totalReforco := 0;
  totalSangria := 0;

  CarregarTotais;

  text := TStringList.Create;
  text.Add('</ce>REL. GERENCIAL');
  text.Add('');
  text.Add('</ae>Venda: ' + FormatCurr('R$ 0.00', totalVenda));
  text.Add('Cancelamento: ' + FormatCurr('R$ 0.00', totalCancelado));
  text.Add('');
  text.Add('Reforço: ' + FormatCurr('R$ 0.00', totalReforco));
  text.Add('Sangria: ' + FormatCurr('R$ 0.00', totalSangria));
  text.Add('');

  qry.First;
  while not qry.Eof do
  begin
    text.Add(qry.FieldByName('DESCRICAO').AsString + ': ' +
      FormatCurr('R$ 0.00', qry.FieldByName('VL_TOTAL').AsCurrency));
    qry.Next;
  end;

  text.Add('');
  text.Add('');
  text.Add('');
  text.Add('');
  text.Add('');
  text.Add('');

  dmPrincipal.AcbrPosPrinter.Imprimir(text.Text);
  dmPrincipal.AcbrPosPrinter.CortarPapel();
end;

procedure TImpressao.impTeste;
begin
  GertecPrinter.PrintString(CENTRALIZADO, 'teste');
end;

procedure TImpressao.ImprimirExtratoVenda;
var
  vlTotal: Currency;
  vlBruto: Currency;
  vlDescItem: Currency;
  tribTotais: Currency;
  pagamento: String;
  descricao: String;
  valores: String;
begin
  vlTotal := 0;
  vlBruto := 0;
  vlDescItem := 0;
  tribTotais := 0;
  tribTotais := 0;
  pagamento := '';
  descricao := '';
  valores := '';

  with dmPrincipal do
  begin
    qryNotaI.ParamByName('NR_DOCUMENTO').AsInteger := rCupom.nrDocumento;
    qryPagamento.ParamByName('NR_DOCUMENTO').AsInteger := rCupom.nrDocumento;;

    {EMPRESA}
    GertecPrinter.PrintString(CENTRALIZADO, UpperCase(empresa.RazaoSocial));
    GertecPrinter.PrintString(CENTRALIZADO, empresa.Cnpj + '  ' + empresa.Ie);
    GertecPrinter.PrintString(CENTRALIZADO, empresa.Endereco + ', ' + empresa.Numero.ToString);
    GertecPrinter.PrintString(CENTRALIZADO, empresa.Cidade + ' - ' + empresa.UF);
    GertecPrinter.PrintString('');
    GertecPrinter.PrintString(CENTRALIZADO, 'Extrato de itens da NFC-e');
    GertecPrinter.PrintString(CENTRALIZADO, '-------------------------------');

    {ITENS}
    qryNotaI.Open;
    qryNotaI.First;
    while not qryNotaI.Eof do
    begin
      tribTotais := tribTotais + qryNotaI.FieldByName('VL_ICMS').AsCurrency;

      descricao := qryNotaI.FieldByName('CD_BARRAS').AsString + ' ';
      descricao := descricao + qryNotaI.FieldByName('DESCRICAO').AsString;
      descricao := Copy(descricao, 0, 30);

      vlTotal := qryNotaI.FieldByName('VL_TOTAL').AsCurrency;
      vlBruto := qryNotaI.FieldByName('VL_BRUTO').AsCurrency;
      vlDescItem := qryNotaI.FieldByName('VL_DESCITEM').AsCurrency;

      valores := FormatFloat('0.000', qryNotaI.FieldByName('QTD').AsFloat) + ' x ';
      valores := valores + FormatCurr('0.00', qryNotaI.FieldByName('VL_BRUTO').AsCurrency) + '     ';

      if qryNotaI.FieldByName('VL_DESCITEM').AsCurrency > 0 then
      begin
        valores := valores + FormatCurr('-0.00', vlDescItem) + '    ';
        valores := valores + FormatCurr('0.00', vlBruto * qryNotaI.FieldByName('QTD').AsFloat - vlDescItem);
      end
      else
        valores := valores + FormatCurr('0.00', vlBruto * qryNotaI.FieldByName('QTD').AsFloat);

      GertecPrinter.PrintString(ESQUERDA, descricao);
      GertecPrinter.PrintString(DIREITA, valores);
      qryNotaI.Next;
    end;
    qryNotaI.Close;

    {TOTAIS}
    if rCupom.vlDesconto > 0 then
    begin
      GertecPrinter.PrintString(DIREITA, FormatCurr('0.00', rCupom.vlTotal));
      GertecPrinter.PrintString(DIREITA, FormatCurr('-0.00', rCupom.vlDesconto));
    end;
    GertecPrinter.PrintString(DIREITA, 'TOTAL  ' + FormatCurr('0.00', rCupom.vlSubTotal));
    GertecPrinter.PrintString(CENTRALIZADO, '-------------------------------');

    {PAGAMENTOS}
    qryPagamento.Open;
    qryPagamento.First;
    while not qryPagamento.Eof do
    begin
      pagamento := qryPagamento.FieldByName('DESCRICAO').AsString + '  ';
      pagamento := pagamento + FormatCurr('0.00', qryPagamento.FieldByName('VL_TOTAL').AsCurrency);
      GertecPrinter.PrintString(DIREITA, pagamento);
      qryPagamento.Next;
    end;
    if rCupom.pagVlTroco > 0 then
      GertecPrinter.PrintString(DIREITA, 'TROCO  ' + FormatFloat('0.00', rCupom.pagVlTroco));
    qryPagamento.Close;

    {CONSUMIDOR}
    GertecPrinter.PrintString(ESQUERDA, rCliCupom.nmCliente);
    if rCliCupom.cpfCliente <> '' then
      GertecPrinter.PrintString(ESQUERDA, 'CPF ' + rCliCupom.cpfCliente);

    {AUTORIZAÇÃO}
    GertecPrinter.PrintString(CENTRALIZADO, 'NFC-e pendente de emissão');
    GertecPrinter.PrintString(CENTRALIZADO, rCupom.autChaveDanfe);
    GertecPrinter.PrintString(CENTRALIZADO, 'NFC-e N°' + rCupom.nrNota.ToString +
                              ' Série ' + configuracao.Serie.ToString);

    GertecPrinter.printBlankLine(120);
  end;

  GertecPrinter.PrintOutput;
end;

end.
