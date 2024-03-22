object ElectronicPrescriptionsDefaultForm: TElectronicPrescriptionsDefaultForm
  Left = 0
  Top = 0
  Caption = #51204#51088' '#52376#48169#51204' '#44592#48376#44050
  ClientHeight = 637
  ClientWidth = 572
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #47569#51008' '#44256#46357
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 17
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 572
    Height = 637
    Align = alClient
    TabOrder = 0
    object ValueListEditor1: TValueListEditor
      Left = 1
      Top = 1
      Width = 570
      Height = 635
      Align = alClient
      Strings.Strings = (
        '=')
      TabOrder = 0
      OnGetPickList = ValueListEditor1GetPickList
      ColWidths = (
        283
        281)
    end
  end
end
