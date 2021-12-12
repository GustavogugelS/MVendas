object dmPrincipal: TdmPrincipal
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 457
  Width = 901
  object conexao: TFDConnection
    Params.Strings = (
      'Database=D:\Fontes\MVendas\Database\VENDAS.DB'
      'OpenMode=ReadWrite'
      'LockingMode=Normal'
      'DriverID=SQLite')
    LoginPrompt = False
    BeforeConnect = conexaoBeforeConnect
    Left = 48
    Top = 24
  end
  object qryProduto: TFDQuery
    Connection = conexao
    SQL.Strings = (
      'SELECT'
      '    PRODUTO.CD_PRODUTO,'
      '    PRODUTO.CD_BARRAS,'
      '    PRODUTO.DESCRICAO,'
      '    PRODUTO.PRECO,'
      '    COALESCE(PRODUTO.ALIQ, 0) ALIQ,'
      '    PRODUTO.CEST,'
      '    PRODUTO.NATUREZA_RECEITA,'
      '    PRODUTO.PESO_LIQUIDO,'
      '    PRODUTO.NCM,'
      '    PRODUTO.CST_ICMS,'
      '    PRODUTO.CST_PISCOFINS,'
      '    PRODUTO.GTIN,'
      '    PRODUTO.UN,'
      '    PRODUTO.PC_REDUCAO'
      'FROM'
      '    PRODUTO'
      'WHERE'
      '    PRODUTO.CD_BARRAS = :CD_BARRAS AND'
      '    PRODUTO.ATIVO = 1')
    Left = 224
    Top = 24
    ParamData = <
      item
        Name = 'CD_BARRAS'
        DataType = ftString
        ParamType = ptInput
        Value = '7898269396612'
      end>
  end
  object qryNotaC: TFDQuery
    Connection = conexao
    SQL.Strings = (
      'SELECT'
      '    *'
      'FROM'
      '    NOTAC'
      'WHERE'
      '    NR_DOCUMENTO = :NR_DOCUMENTO')
    Left = 288
    Top = 24
    ParamData = <
      item
        Name = 'NR_DOCUMENTO'
        DataType = ftInteger
        ParamType = ptInput
        Value = Null
      end>
  end
  object qryNotaI: TFDQuery
    Connection = conexao
    SQL.Strings = (
      'SELECT'
      '    *'
      'FROM'
      '    NOTAI'
      'WHERE'
      '    NOTAi.NR_DOCUMENTO = :NR_DOCUMENTO'
      'ORDER BY NR_SEQUENCIA ASC;')
    Left = 352
    Top = 24
    ParamData = <
      item
        Name = 'NR_DOCUMENTO'
        DataType = ftInteger
        ParamType = ptInput
        Value = Null
      end>
  end
  object qrySequencia: TFDQuery
    Connection = conexao
    SQL.Strings = (
      'SELECT'
      '    COALESCE(MAX(NR_SEQUENCIA), 0) + 1 AS PROX_SEQUENCIA'
      'FROM'
      '    NOTAI'
      'WHERE'
      '    NR_DOCUMENTO = :NR_DOCUMENTO;')
    Left = 48
    Top = 168
    ParamData = <
      item
        Name = 'NR_DOCUMENTO'
        DataType = ftInteger
        ParamType = ptInput
        Value = Null
      end>
  end
  object qryTotalCupom: TFDQuery
    Connection = conexao
    SQL.Strings = (
      'SELECT'
      '    COALESCE(COUNT(NR_SEQUENCIA), 0) AS QT_ITENS,'#9
      
        '    COALESCE(SUM(CASE WHEN COALESCE(NOTAI.CANCELADO, 0) = 0 THEN' +
        ' ROUND(VL_DESCONTO + VL_DESCITEM, 2) ELSE 0 END), 0) AS TOTAL_DE' +
        'SCONTO, '
      
        '    COALESCE(SUM(CASE WHEN COALESCE(NOTAI.CANCELADO, 0) = 0 THEN' +
        ' ROUND(VL_DESCONTO, 2) ELSE 0 END), 0) AS DESCONTO_SUBTOTAL, '
      
        '    COALESCE(SUM(CASE WHEN COALESCE(NOTAI.CANCELADO, 0) = 0 THEN' +
        ' ROUND(VL_TOTAL, 2) ELSE 0 END), 0) AS TOTAL, '
      
        '    COALESCE(SUM(CASE WHEN COALESCE(NOTAI.CANCELADO, 0) = 0 THEN' +
        ' ROUND(VL_LIQUIDO, 2) ELSE 0 END), 0) AS LIQUIDO'
      'FROM '
      '    NOTAI'
      'WHERE '
      '    NR_DOCUMENTO = :NR_DOCUMENTO')
    Left = 48
    Top = 104
    ParamData = <
      item
        Name = 'NR_DOCUMENTO'
        DataType = ftInteger
        ParamType = ptInput
        Value = Null
      end>
  end
  object qryPagamento: TFDQuery
    Connection = conexao
    SQL.Strings = (
      'SELECT'
      '    PAGAMENTO.*,'
      '    FINALIZADORA.DESCRICAO,'
      '    FINALIZADORA.TIPO'
      'FROM'
      '    PAGAMENTO'
      
        '    JOIN FINALIZADORA ON FINALIZADORA.ID = PAGAMENTO.FINALIZADOR' +
        'A'
      'WHERE'
      '    NR_DOCUMENTO = :NR_DOCUMENTO')
    Left = 424
    Top = 24
    ParamData = <
      item
        Name = 'NR_DOCUMENTO'
        DataType = ftInteger
        ParamType = ptInput
        Value = Null
      end>
  end
  object FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink
    Left = 48
    Top = 400
  end
  object qryNotas: TFDQuery
    Connection = conexao
    SQL.Strings = (
      'SELECT'
      '    NR_DOCUMENTO,'
      '    NR_NOTA,'
      '    DANFE,'
      '    VL_TOTAL,'
      '    STATUS'
      'FROM'
      '    NOTAC'
      'ORDER BY STATUS DESC, NR_NOTA DESC'
      'LIMIT 100')
    Left = 648
    Top = 24
  end
  object qryCaixa: TFDQuery
    Connection = conexao
    SQL.Strings = (
      'SELECT'
      '    *'
      'FROM'
      '    CAIXA'
      'WHERE'
      '    DATA = :DATACAIXA AND'
      '    FECHADO = :FECHADO')
    Left = 504
    Top = 24
    ParamData = <
      item
        Name = 'DATACAIXA'
        DataType = ftString
        ParamType = ptInput
        Value = Null
      end
      item
        Name = 'FECHADO'
        DataType = ftInteger
        ParamType = ptInput
        Value = Null
      end>
  end
  object qryCaixaMov: TFDQuery
    Connection = conexao
    SQL.Strings = (
      'SELECT'
      '    *'
      'FROM'
      '    CAIXA_MOVIMENTO'
      'WHERE'
      '    CD_CAIXA = :CD_CAIXA')
    Left = 576
    Top = 24
    ParamData = <
      item
        Name = 'CD_CAIXA'
        DataType = ftInteger
        ParamType = ptInput
        Value = Null
      end>
  end
  object AcbrEscPos: TACBrNFeDANFeESCPOS
    Sistema = 'Projeto ACBr - www.projetoacbr.com.br'
    MargemInferior = 8.000000000000000000
    MargemSuperior = 8.000000000000000000
    MargemEsquerda = 6.000000000000000000
    MargemDireita = 5.100000000000000000
    ExpandeLogoMarcaConfig.Altura = 0
    ExpandeLogoMarcaConfig.Esquerda = 0
    ExpandeLogoMarcaConfig.Topo = 0
    ExpandeLogoMarcaConfig.Largura = 0
    ExpandeLogoMarcaConfig.Dimensionar = False
    ExpandeLogoMarcaConfig.Esticar = True
    CasasDecimais.Formato = tdetInteger
    CasasDecimais.qCom = 2
    CasasDecimais.vUnCom = 2
    CasasDecimais.MaskqCom = ',0.00'
    CasasDecimais.MaskvUnCom = ',0.00'
    ACBrNFe = dmNfe.ACBrNFe
    TipoDANFE = tiNFCe
    ImprimeQRCodeLateral = True
    ImprimeEmUmaLinha = True
    PosPrinter = AcbrPosPrinter
    Left = 792
    Top = 32
  end
  object AcbrPosPrinter: TACBrPosPrinter
    ConfigBarras.MostrarCodigo = False
    ConfigBarras.LarguraLinha = 0
    ConfigBarras.Altura = 0
    ConfigBarras.Margem = 0
    ConfigQRCode.Tipo = 2
    ConfigQRCode.LarguraModulo = 4
    ConfigQRCode.ErrorLevel = 0
    LinhasEntreCupons = 0
    Left = 792
    Top = 96
  end
end
