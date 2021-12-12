object NFCEWebModule: TNFCEWebModule
  OldCreateOrder = False
  OnCreate = WebModuleCreate
  OnDestroy = WebModuleDestroy
  Actions = <>
  OnException = WebModuleException
  Height = 325
  Width = 624
  object ConnSQLite: TFDConnection
    Params.Strings = (
      'OpenMode=ReadWrite'
      'LockingMode=Normal'
      'Database=C:\Servidor\DB\ServerMobile.db'
      'DriverID=SQLite')
    Left = 96
    Top = 56
  end
  object FDPhysPgDriverLink1: TFDPhysPgDriverLink
    Left = 504
    Top = 56
  end
end
