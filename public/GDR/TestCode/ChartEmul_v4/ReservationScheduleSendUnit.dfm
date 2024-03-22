object ReservationScheduleSendForm: TReservationScheduleSendForm
  Left = 0
  Top = 62
  Caption = #50696#50557' '#49828#52992#51572' '#51204#49569
  ClientHeight = 432
  ClientWidth = 867
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 8
    Top = 8
    Width = 793
    Height = 273
    TabOrder = 0
    object Label1: TLabel
      Left = 16
      Top = 16
      Width = 70
      Height = 16
      Caption = #51652#47308#44284#47785' '#53076#46300
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Label2: TLabel
      Left = 16
      Top = 138
      Width = 59
      Height = 16
      Caption = #51652#47308#49892' '#53076#46300
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Label3: TLabel
      Left = 288
      Top = 18
      Width = 59
      Height = 16
      Caption = #50696#50557' '#49828#52992#51572
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object ListBox1: TListBox
      Left = 16
      Top = 35
      Width = 249
      Height = 97
      ItemHeight = 13
      TabOrder = 0
    end
    object ListBox2: TListBox
      Left = 16
      Top = 163
      Width = 251
      Height = 97
      ItemHeight = 13
      TabOrder = 1
    end
    object Button1: TButton
      Left = 647
      Top = 227
      Width = 121
      Height = 33
      Caption = #51204#49569
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      OnClick = Button1Click
    end
    object StringGrid1: TStringGrid
      Left = 288
      Top = 35
      Width = 480
      Height = 186
      ColCount = 2
      DefaultColWidth = 235
      FixedColor = clGray
      FixedCols = 0
      RowCount = 2
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goDrawFocusSelected, goRowSizing, goColSizing, goEditing]
      TabOrder = 3
    end
    object Button2: TButton
      Left = 288
      Top = 227
      Width = 121
      Height = 33
      Caption = #54665' '#52628#44032
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 4
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 415
      Top = 227
      Width = 122
      Height = 33
      Caption = #47560#51648#47561' '#54665' '#49325#51228
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 5
      OnClick = Button3Click
    end
  end
  object LiteQuery1: TLiteQuery
    Connection = DBDM.LiteConnection1
    Left = 48
    Top = 56
  end
end
