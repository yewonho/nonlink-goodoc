object ChartEmulV4Form: TChartEmulV4Form
  Left = 0
  Top = 0
  Caption = 'ChartEmul_V4'
  ClientHeight = 616
  ClientWidth = 798
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #47569#51008' '#44256#46357
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 17
  object Splitter1: TSplitter
    Left = 0
    Top = 485
    Width = 798
    Height = 3
    Cursor = crVSplit
    Align = alBottom
    ExplicitTop = 161
    ExplicitWidth = 366
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 798
    Height = 81
    Align = alTop
    TabOrder = 0
    DesignSize = (
      798
      81)
    object Label1: TLabel
      Left = 506
      Top = 58
      Width = 38
      Height = 17
      Caption = 'Label1'
      Enabled = False
    end
    object Label2: TLabel
      Left = 16
      Top = 56
      Width = 117
      Height = 17
      Caption = #44208#51228' '#48337#50896#51060' '#50500#45768#45796'.'
    end
    object Label3: TLabel
      Left = 693
      Top = 4
      Width = 52
      Height = 17
      Caption = #50672#44208#49345#53468
    end
    object HospitalNo_edit: TLabeledEdit
      Left = 8
      Top = 24
      Width = 161
      Height = 25
      EditLabel.Width = 66
      EditLabel.Height = 17
      EditLabel.Caption = 'HospitalNo'
      TabOrder = 0
    end
    object chartcode_edit: TLabeledEdit
      Left = 175
      Top = 24
      Width = 82
      Height = 25
      EditLabel.Width = 63
      EditLabel.Height = 17
      EditLabel.Caption = 'ChartCode'
      NumbersOnly = True
      TabOrder = 1
    end
    object saveenv_btn: TButton
      Left = 263
      Top = 26
      Width = 75
      Height = 25
      Caption = #51200#51109
      TabOrder = 2
      OnClick = saveenv_btnClick
    end
    object Button1: TButton
      Left = 692
      Top = 24
      Width = 99
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Query Test'
      TabOrder = 3
      OnClick = Button1Click
    end
    object Button8: TButton
      Left = 344
      Top = 25
      Width = 75
      Height = 25
      Caption = 'Init'
      TabOrder = 4
      OnClick = Button8Click
    end
    object LabeledEdit1: TLabeledEdit
      Left = 425
      Top = 26
      Width = 192
      Height = 25
      EditLabel.Width = 57
      EditLabel.Height = 17
      EditLabel.Caption = 'Bridge ID'
      ReadOnly = True
      TabOrder = 5
    end
    object Button9: TButton
      Left = 344
      Top = 56
      Width = 156
      Height = 25
      Caption = #51204#51088' '#52376#48169#51204' '#48337#50896' '#51312#54924
      Enabled = False
      TabOrder = 6
      OnClick = Button9Click
    end
    object ConnectionState: TPanel
      Left = 752
      Top = 3
      Width = 38
      Height = 18
      Color = clRed
      ParentBackground = False
      TabOrder = 7
    end
    object Button11: TButton
      Left = 692
      Top = 50
      Width = 99
      Height = 25
      Caption = #50672#44208#49436#48260#48320#44221
      TabOrder = 8
      OnClick = Button11Click
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 81
    Width = 798
    Height = 72
    Align = alTop
    TabOrder = 1
    object Button2: TButton
      Left = 8
      Top = 6
      Width = 150
      Height = 25
      Caption = 'Send Room List'
      TabOrder = 0
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 164
      Top = 6
      Width = 150
      Height = 25
      Caption = #52712#49548' '#47700#49884#51648' '#47785#47197' '#50836#52397
      TabOrder = 1
      OnClick = Button3Click
    end
    object Button4: TButton
      Left = 641
      Top = 6
      Width = 150
      Height = 25
      Caption = #54872#51088' '#44160#49353' Test'
      TabOrder = 2
      OnClick = Button4Click
    end
    object ComboBox1: TComboBox
      Left = 320
      Top = 6
      Width = 193
      Height = 25
      TabOrder = 3
    end
    object Button5: TButton
      Left = 8
      Top = 37
      Width = 150
      Height = 25
      Caption = 'Room List '#50836#52397
      TabOrder = 4
      OnClick = Button5Click
    end
    object Button6: TButton
      Left = 164
      Top = 37
      Width = 150
      Height = 25
      Caption = #51217#49688'/'#50696#50557' '#47785#47197' '#50836#52397
      TabOrder = 5
      OnClick = Button6Click
    end
    object Button7: TButton
      Left = 625
      Top = 41
      Width = 75
      Height = 25
      Caption = #51217#49688' test'
      TabOrder = 6
      OnClick = Button7Click
    end
    object Button10: TButton
      Left = 706
      Top = 41
      Width = 75
      Height = 25
      Caption = 'test'
      TabOrder = 7
      OnClick = Button10Click
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 153
    Width = 798
    Height = 332
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
    object PageControl1: TPageControl
      Left = 0
      Top = 0
      Width = 798
      Height = 332
      ActivePage = TabSheet1
      Align = alClient
      TabOrder = 0
      OnChange = PageControl1Change
      object TabSheet1: TTabSheet
        Caption = #49324#50857#51088' '#44160#49353
      end
      object TabSheet2: TTabSheet
        Caption = #51217#49688' '#44288#47532
        ImageIndex = 1
      end
      object TabSheet3: TTabSheet
        Caption = #50696#50557' '#44288#47532
        ImageIndex = 2
      end
      object TabSheet4: TTabSheet
        Caption = #51652#47308#49892' '#44288#47532
        ImageIndex = 3
      end
      object TabSheet5: TTabSheet
        Caption = #51204#51088' '#52376#48169#51204' '#49688#49888
        ImageIndex = 4
      end
      object TabSheet6: TTabSheet
        Caption = #50696#50557' '#49828#52992#51572' '#51204#49569
        ImageIndex = 5
      end
      object TabSheet7: TTabSheet
        Caption = #54872#51088#49345#53468#48320#44221
        ImageIndex = 6
      end
    end
  end
  object GridPanel1: TGridPanel
    Left = 0
    Top = 488
    Width = 798
    Height = 128
    Align = alBottom
    Caption = 'GridPanel1'
    ColumnCollection = <
      item
        Value = 60.000000000000000000
      end
      item
        Value = 40.000000000000000000
      end>
    ControlCollection = <
      item
        Column = 0
        Control = Memo1
        Row = 0
      end
      item
        Column = 1
        Control = Memo2
        Row = 0
      end>
    RowCollection = <
      item
        Value = 100.000000000000000000
      end>
    TabOrder = 3
    object Memo1: TMemo
      Left = 1
      Top = 1
      Width = 477
      Height = 126
      Align = alClient
      ScrollBars = ssBoth
      TabOrder = 0
      WordWrap = False
      OnClick = Memo1Click
    end
    object Memo2: TMemo
      Left = 478
      Top = 1
      Width = 319
      Height = 126
      Align = alClient
      ScrollBars = ssBoth
      TabOrder = 1
    end
  end
  object selectquery: TLiteQuery
    Connection = DBDM.LiteConnection1
    Left = 560
    Top = 64
  end
  object ApplicationEvents1: TApplicationEvents
    OnIdle = ApplicationEvents1Idle
    Left = 100
    Top = 261
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 100
    OnTimer = Timer1Timer
    Left = 56
    Top = 193
  end
  object Timer2: TTimer
    Enabled = False
    OnTimer = Timer2Timer
    Left = 52
    Top = 357
  end
  object HeartbeatTimer: TTimer
    Enabled = False
    Interval = 5000
    OnTimer = OnTimerHeartbeatTimer
    Left = 664
  end
end
