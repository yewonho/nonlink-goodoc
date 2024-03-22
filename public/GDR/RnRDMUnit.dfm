object RnRDM: TRnRDM
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 150
  Width = 215
  object RR_DB: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 32
    Top = 16
  end
  object Room_DB: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 32
    Top = 80
  end
  object CancelMsg_DB: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 120
    Top = 80
  end
end
