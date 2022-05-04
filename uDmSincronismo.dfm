object dmSincronismo: TdmSincronismo
  OldCreateOrder = False
  Height = 477
  Width = 660
  object rstClient: TRESTClient
    Accept = 'application/json, text/plain; q=0.9, text/html;q=0.8,'
    AcceptCharset = 'utf-8, *;q=0.8'
    BaseURL = 'http://52.67.45.102:8090'
    ContentType = 'application/json'
    Params = <>
    Left = 32
    Top = 16
  end
  object fdMemTable: TFDMemTable
    Active = True
    FieldDefs = <
      item
        Name = 'pesCodigo'
        DataType = ftWideString
        Size = 255
      end
      item
        Name = 'pesCodigoExterno'
        DataType = ftWideString
        Size = 255
      end
      item
        Name = 'pesNome'
        DataType = ftWideString
        Size = 255
      end
      item
        Name = 'pesAtivo'
        DataType = ftWideString
        Size = 255
      end
      item
        Name = 'pesCep'
        DataType = ftWideString
        Size = 255
      end
      item
        Name = 'pesBairro'
        DataType = ftWideString
        Size = 255
      end
      item
        Name = 'pesRua'
        DataType = ftWideString
        Size = 255
      end
      item
        Name = 'pesNumero'
        DataType = ftWideString
        Size = 255
      end
      item
        Name = 'pesTelefone1'
        DataType = ftWideString
        Size = 255
      end
      item
        Name = 'pesTelefone2'
        DataType = ftWideString
        Size = 255
      end
      item
        Name = 'pesCpfcnpj'
        DataType = ftWideString
        Size = 255
      end
      item
        Name = 'pesInscmunicipal'
        DataType = ftWideString
        Size = 255
      end
      item
        Name = 'pesRginscest'
        DataType = ftWideString
        Size = 255
      end
      item
        Name = 'rtiCodigo'
        DataType = ftWideString
        Size = 255
      end
      item
        Name = 'rtiNome'
        DataType = ftWideString
        Size = 255
      end
      item
        Name = 'cidCodigo'
        DataType = ftWideString
        Size = 255
      end
      item
        Name = 'cidCodigoibge'
        DataType = ftWideString
        Size = 255
      end
      item
        Name = 'cidNome'
        DataType = ftWideString
        Size = 255
      end
      item
        Name = 'estSigla'
        DataType = ftWideString
        Size = 255
      end
      item
        Name = 'estCodigoibge'
        DataType = ftWideString
        Size = 255
      end
      item
        Name = 'pceAmbientenfce'
        DataType = ftWideString
        Size = 255
      end
      item
        Name = 'pceTipossl'
        DataType = ftWideString
        Size = 255
      end
      item
        Name = 'pceCsc'
        DataType = ftWideString
        Size = 255
      end
      item
        Name = 'pceSenhaPfx'
        DataType = ftWideString
        Size = 255
      end
      item
        Name = 'pceIdCsc'
        DataType = ftWideString
        Size = 255
      end
      item
        Name = 'pceUrlPfx'
        DataType = ftWideString
        Size = 255
      end
      item
        Name = 'pesAliquotapis'
        DataType = ftWideString
        Size = 255
      end
      item
        Name = 'pesAliquotacofins'
        DataType = ftWideString
        Size = 255
      end>
    IndexDefs = <>
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    StoreDefs = True
    Left = 32
    Top = 272
  end
  object rstAdapter: TRESTResponseDataSetAdapter
    Active = True
    Dataset = fdMemTable
    FieldDefs = <>
    Response = rstResponse
    Left = 32
    Top = 208
  end
  object rstRequest: TRESTRequest
    Client = rstClient
    Method = rmPOST
    Params = <
      item
        Kind = pkREQUESTBODY
        Name = 'body'
        Options = [poDoNotEncode]
        Value = '{"IMEI": "869129022553165"}'
        ContentType = ctAPPLICATION_JSON
      end>
    Resource = 'post_TEmpresaController'
    Response = rstResponse
    SynchronizedEvents = False
    Left = 32
    Top = 80
  end
  object rstResponse: TRESTResponse
    ContentType = 'application/json'
    Left = 32
    Top = 144
  end
end
