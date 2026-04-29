object IWUserSession: TIWUserSession
  OldCreateOrder = False
  Height = 246
  Width = 406
  object uniconn: TUniConnection
    ProviderName = 'SQL Server'
    Port = 7109
    Database = 'RBA'
    Username = 'sa'
    Server = '192.168.0.2'
    LoginPrompt = False
    Left = 144
    Top = 16
    EncryptedPassword = 'C8FFC6FFCFFFCEFFCEFFCDFF8BFF97FF'
  end
  object qryAux: TUniQuery
    Connection = uniconn
    Left = 40
    Top = 80
  end
  object qryRetornaSQL: TUniQuery
    Connection = uniconn
    Left = 40
    Top = 136
  end
  object qryExecuta: TUniQuery
    Connection = uniconn
    Left = 216
    Top = 16
  end
  object qryAux2: TUniQuery
    Connection = uniconn
    Left = 88
    Top = 80
  end
  object SQLServerUniProvider1: TSQLServerUniProvider
    Left = 40
    Top = 16
  end
  object qryLogos: TUniQuery
    Connection = uniconn
    SQL.Strings = (
      'select Empresa, LogoIAM_FundoEscuro, LogoIAM_FundoClaro'
      'from LogoEmpresas'
      'where Empresa = :Empresa')
    Left = 216
    Top = 80
    ParamData = <
      item
        DataType = ftInteger
        Name = 'Empresa'
        ParamType = ptInput
        Value = nil
      end>
    object qryLogosEmpresa: TIntegerField
      FieldName = 'Empresa'
      Required = True
    end
    object qryLogosLogoIAM_FundoEscuro: TBlobField
      FieldName = 'LogoIAM_FundoEscuro'
    end
    object qryLogosLogoIAM_FundoClaro: TBlobField
      FieldName = 'LogoIAM_FundoClaro'
    end
  end
end
