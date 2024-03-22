object AccountRequestForm: TAccountRequestForm
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = #44415#45797' '#54168#51060'('#44208#51228' '#50836#52397')'
  ClientHeight = 301
  ClientWidth = 415
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #47569#51008' '#44256#46357
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 17
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 415
    Height = 243
    Align = alClient
    TabOrder = 0
    object Label1: TLabel
      Left = 16
      Top = 8
      Width = 117
      Height = 37
      Caption = #44415#45797' '#54168#51060
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -27
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      ParentFont = False
    end
    object Label2: TLabel
      Left = 56
      Top = 59
      Width = 44
      Height = 17
      Caption = #52509' '#44552#50529
    end
    object Label3: TLabel
      Left = 56
      Top = 102
      Width = 70
      Height = 17
      Caption = #44277#45800' '#48512#45812#44552
    end
    object Label4: TLabel
      Left = 56
      Top = 135
      Width = 80
      Height = 20
      Caption = #54872#51088' '#48512#45812#44552
      Font.Charset = ANSI_CHARSET
      Font.Color = clRed
      Font.Height = -15
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label5: TLabel
      Left = 56
      Top = 200
      Width = 57
      Height = 17
      Caption = #54624#48512' '#44060#50900
    end
    object Label6: TLabel
      Left = 294
      Top = 59
      Width = 13
      Height = 17
      Caption = #50896
    end
    object Label7: TLabel
      Left = 294
      Top = 102
      Width = 13
      Height = 17
      Caption = #50896
    end
    object Label8: TLabel
      Left = 294
      Top = 145
      Width = 13
      Height = 17
      Caption = #50896
    end
    object ComboBox1: TComboBox
      Left = 164
      Top = 197
      Width = 189
      Height = 25
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 0
      Text = #51068#49884#48520
      Items.Strings = (
        #51068#49884#48520
        '2'#44060#50900
        '3'#44060#50900
        '4'#44060#50900
        '5'#44060#50900
        '6'#44060#50900
        '7'#44060#50900
        '8'#44060#50900
        '9'#44060#50900
        '10'#44060#50900
        '11'#44060#50900
        '12'#44060#50900)
    end
    object totalAmt_edit: TEdit
      Left = 161
      Top = 56
      Width = 127
      Height = 25
      Alignment = taRightJustify
      NumbersOnly = True
      TabOrder = 1
      Text = '0'
      OnChange = totalAmt_editChange
      OnKeyPress = totalAmt_editKeyPress
    end
    object nhisAmt_edit: TEdit
      Left = 160
      Top = 99
      Width = 127
      Height = 25
      Alignment = taRightJustify
      NumbersOnly = True
      TabOrder = 2
      Text = '0'
      OnChange = totalAmt_editChange
      OnKeyPress = totalAmt_editKeyPress
    end
    object userAmt_edit: TEdit
      Left = 160
      Top = 142
      Width = 127
      Height = 25
      Alignment = taRightJustify
      NumbersOnly = True
      ReadOnly = True
      TabOrder = 3
      Text = '0'
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 243
    Width = 415
    Height = 58
    Align = alBottom
    TabOrder = 1
    object Button1: TButton
      Left = 90
      Top = 16
      Width = 100
      Height = 25
      Caption = #44208#51228
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 226
      Top = 16
      Width = 100
      Height = 25
      Caption = #52712#49548
      TabOrder = 1
      OnClick = Button2Click
    end
  end
end
