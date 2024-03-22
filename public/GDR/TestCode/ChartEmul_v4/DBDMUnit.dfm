object DBDM: TDBDM
  OldCreateOrder = False
  OnDestroy = DataModuleDestroy
  Height = 302
  Width = 209
  object LiteConnection1: TLiteConnection
    Options.Direct = True
    LoginPrompt = False
    AfterConnect = LiteConnection1AfterConnect
    Left = 55
    Top = 22
  end
  object FindQuery: TLiteQuery
    Connection = LiteConnection1
    Left = 48
    Top = 104
  end
  object trans_table: TLiteQuery
    Connection = LiteConnection1
    Left = 48
    Top = 192
  end
  object LiteQuery1: TLiteQuery
    Connection = LiteConnection1
    Left = 120
    Top = 120
  end
end
