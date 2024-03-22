object ReceptionIDChangeForm: TReceptionIDChangeForm
  Left = 0
  Top = 0
  Caption = #51217#49688' '#48264#54840' '#48320#44221
  ClientHeight = 179
  ClientWidth = 411
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #47569#51008' '#44256#46357
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 17
  object Panel1: TPanel
    Left = 0
    Top = 132
    Width = 411
    Height = 47
    Align = alBottom
    TabOrder = 0
    object Button1: TButton
      Left = 80
      Top = 11
      Width = 100
      Height = 25
      Caption = #48320#44221
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 232
      Top = 11
      Width = 100
      Height = 25
      Caption = #52712#49548
      TabOrder = 1
      OnClick = Button2Click
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 411
    Height = 132
    Align = alClient
    TabOrder = 1
    object Label1: TLabel
      Left = 33
      Top = 30
      Width = 81
      Height = 17
      Caption = 'old '#51217#49688' '#48264#54840
    end
    object Label2: TLabel
      Left = 33
      Top = 83
      Width = 87
      Height = 17
      Caption = 'new '#51217#49688' '#48264#54840
    end
    object Edit1: TEdit
      Left = 129
      Top = 27
      Width = 249
      Height = 25
      TabStop = False
      ReadOnly = True
      TabOrder = 1
      Text = 'Edit1'
    end
    object Edit2: TEdit
      Left = 129
      Top = 80
      Width = 249
      Height = 25
      TabOrder = 0
      Text = 'Edit2'
    end
  end
end
