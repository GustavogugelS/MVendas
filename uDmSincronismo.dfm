object dmSincronismo: TdmSincronismo
  OldCreateOrder = False
  Height = 477
  Width = 660
  object rstClient: TRESTClient
    Accept = 'application/json, text/plain; q=0.9, text/html;q=0.8,'
    AcceptCharset = 'utf-8, *;q=0.8'
    BaseURL = 'http://52.67.45.102:8090'
    ContentType = 'application/x-www-form-urlencoded'
    Params = <>
    Left = 32
    Top = 16
  end
  object rstRequest: TRESTRequest
    Client = rstClient
    Params = <>
    Resource = 'get_TEmpresaController'
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
  object fdMemTable: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 32
    Top = 272
  end
  object rstAdapter: TRESTResponseDataSetAdapter
    Dataset = fdMemTable
    FieldDefs = <>
    Response = rstResponse
    Left = 32
    Top = 208
  end
end
