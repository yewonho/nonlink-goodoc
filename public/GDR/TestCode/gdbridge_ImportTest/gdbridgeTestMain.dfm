object gdbridgeTestMainForm: TgdbridgeTestMainForm
  Left = 0
  Top = 0
  Caption = 'gdbridge.dll Test '#54532#47196#44536#47016
  ClientHeight = 381
  ClientWidth = 545
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #47569#51008' '#44256#46357
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    545
    381)
  PixelsPerInch = 96
  TextHeight = 17
  object Button1: TButton
    Left = 8
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Load'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Edit1: TEdit
    Left = 170
    Top = 8
    Width = 121
    Height = 25
    TabOrder = 1
    Text = 'Edit1'
  end
  object Button2: TButton
    Left = 89
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Unload'
    TabOrder = 2
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 8
    Top = 70
    Width = 150
    Height = 25
    Caption = 'GetJobID'
    TabOrder = 3
    OnClick = Button3Click
  end
  object Edit2: TEdit
    Left = 164
    Top = 70
    Width = 370
    Height = 25
    TabOrder = 4
    Text = 'Edit2'
  end
  object Button4: TButton
    Left = 8
    Top = 142
    Width = 150
    Height = 25
    Caption = 'GetErrorString'
    TabOrder = 5
    OnClick = Button4Click
  end
  object Edit3: TEdit
    Left = 164
    Top = 142
    Width = 370
    Height = 25
    TabOrder = 6
    Text = 'Edit2'
  end
  object Button5: TButton
    Left = 8
    Top = 101
    Width = 150
    Height = 25
    Caption = 'GetJobIDW'
    TabOrder = 7
    OnClick = Button5Click
  end
  object Button6: TButton
    Left = 8
    Top = 173
    Width = 150
    Height = 25
    Caption = 'GetErrorStringW'
    TabOrder = 8
    OnClick = Button6Click
  end
  object Button7: TButton
    Left = 8
    Top = 39
    Width = 150
    Height = 25
    Caption = 'init'
    TabOrder = 9
    OnClick = Button7Click
  end
  object Button8: TButton
    Left = 164
    Top = 39
    Width = 150
    Height = 25
    Caption = 'Deinit'
    TabOrder = 10
    OnClick = Button8Click
  end
  object Memo1: TMemo
    Left = 8
    Top = 280
    Width = 529
    Height = 93
    Anchors = [akLeft, akRight, akBottom]
    Lines.Strings = (
      'Memo1')
    ScrollBars = ssVertical
    TabOrder = 11
  end
  object Edit4: TEdit
    Left = 320
    Top = 39
    Width = 161
    Height = 25
    TabOrder = 12
    Text = '90909090'
  end
end
