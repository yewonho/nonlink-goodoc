object ReceptionMngForm: TReceptionMngForm
  Left = 0
  Top = 0
  Caption = 'ReceptionMngForm'
  ClientHeight = 494
  ClientWidth = 877
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 24
    Top = 8
    Width = 785
    Height = 417
    BevelOuter = bvNone
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #47569#51008' '#44256#46357
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    object Panel2: TPanel
      Left = 0
      Top = 376
      Width = 785
      Height = 41
      Align = alBottom
      TabOrder = 0
      object DBNavigator1: TDBNavigator
        Left = 114
        Top = 8
        Width = 198
        Height = 25
        DataSource = DataSource1
        VisibleButtons = [nbFirst, nbPrior, nbNext, nbLast, nbDelete, nbEdit, nbPost, nbCancel, nbRefresh]
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
      end
      object Button1: TButton
        Left = 8
        Top = 6
        Width = 100
        Height = 25
        Caption = 'All Refresh'
        TabOrder = 1
        OnClick = Button1Click
      end
      object Button7: TButton
        Left = 336
        Top = 6
        Width = 121
        Height = 25
        Caption = #52376#48169#51204' Data'
        TabOrder = 2
        OnClick = Button7Click
      end
      object CheckBox1: TCheckBox
        Left = 463
        Top = 13
        Width = 97
        Height = 17
        Caption = #51116#51652#47564' '#51217#49688
        TabOrder = 3
      end
    end
    object DBGrid1: TDBGrid
      Left = 0
      Top = 41
      Width = 785
      Height = 335
      Align = alClient
      DataSource = DataSource1
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
      TabOrder = 1
      TitleFont.Charset = ANSI_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -13
      TitleFont.Name = #47569#51008' '#44256#46357
      TitleFont.Style = []
    end
    object Panel3: TPanel
      Left = 0
      Top = 0
      Width = 785
      Height = 41
      Align = alTop
      TabOrder = 2
      object Button2: TButton
        Left = 8
        Top = 10
        Width = 113
        Height = 25
        Caption = #49440#53469#54620' '#51217#49688' '#52712#49548
        TabOrder = 0
        OnClick = Button2Click
      end
      object Button3: TButton
        Left = 121
        Top = 10
        Width = 113
        Height = 25
        Caption = #51652#47308#49892' '#48320#44221
        TabOrder = 1
        OnClick = Button3Click
      end
      object Button4: TButton
        Left = 233
        Top = 10
        Width = 113
        Height = 25
        Caption = #49345#53468' '#48320#44221
        TabOrder = 2
        OnMouseDown = Button4MouseDown
      end
      object Button5: TButton
        Tag = 1
        Left = 488
        Top = 10
        Width = 75
        Height = 25
        Caption = #50500#47000#47196
        Enabled = False
        TabOrder = 3
        OnClick = Button6Click
      end
      object Button6: TButton
        Left = 569
        Top = 10
        Width = 75
        Height = 25
        Caption = #50948#47196
        Enabled = False
        TabOrder = 4
        OnClick = Button6Click
      end
      object Button8: TButton
        Left = 650
        Top = 10
        Width = 95
        Height = 25
        Caption = #51217#49688#48264#54840#48320#44221
        TabOrder = 5
        OnClick = Button8Click
      end
      object Button9: TButton
        Left = 352
        Top = 10
        Width = 75
        Height = 25
        Caption = #44208#51228
        TabOrder = 6
        OnMouseDown = Button9MouseDown
      end
    end
  end
  object DataSource1: TDataSource
    DataSet = LiteQuery1
    OnDataChange = DataSource1DataChange
    Left = 304
    Top = 96
  end
  object LiteQuery1: TLiteQuery
    Connection = DBDM.LiteConnection1
    AfterOpen = LiteQuery1AfterOpen
    BeforeClose = LiteQuery1BeforeClose
    BeforeInsert = LiteQuery1BeforeInsert
    BeforeEdit = LiteQuery1BeforeInsert
    AfterPost = LiteQuery1AfterPost
    AfterCancel = LiteQuery1AfterPost
    Left = 192
    Top = 96
  end
  object purposeTable: TLiteTable
    Connection = DBDM.LiteConnection1
    Left = 144
    Top = 280
  end
  object patient: TLiteTable
    Connection = DBDM.LiteConnection1
    TableName = 'patient'
    Left = 272
    Top = 304
  end
  object PopupMenu1: TPopupMenu
    Left = 272
    Top = 40
    object N1: TMenuItem
      Tag = 1
      Caption = #45236#50896#50836#52397
      Hint = #52264#53944' '#50672#46041#50640#49436#45716' '#49324#50857#54616#51648' '#50506#51020'.'
      Visible = False
      OnClick = N7Click
    end
    object N2: TMenuItem
      Tag = 2
      Caption = #45236#50896#54869#51221
      OnClick = N7Click
    end
    object N3: TMenuItem
      Tag = 3
      Caption = #51652#47308#45824#44592
      OnClick = N7Click
    end
    object N8: TMenuItem
      Tag = 4
      Caption = #51652#47308' '#50756#47308
      OnClick = N7Click
    end
    object N9: TMenuItem
      Caption = '-'
    end
    object N10: TMenuItem
      Tag = 5
      Caption = #51204#51088' '#52376#48169#51204' '#48156#49569' Test'
      Visible = False
      OnClick = N7Click
    end
    object N4: TMenuItem
      Caption = '-'
      Visible = False
    end
    object N5: TMenuItem
      Tag = 11
      Caption = #48376#51064' '#52712#49548
      OnClick = N7Click
    end
    object N6: TMenuItem
      Tag = 12
      Caption = #48337#50896' '#52712#49548
      OnClick = N7Click
    end
    object N7: TMenuItem
      Tag = 13
      Caption = #51088#46041' '#52712#49548
      OnClick = N7Click
    end
  end
  object LiteQuery2: TLiteQuery
    Connection = DBDM.LiteConnection1
    Left = 64
    Top = 120
  end
  object processQuery: TLiteQuery
    Connection = DBDM.LiteConnection1
    Left = 368
    Top = 176
  end
  object update_356: TLiteTable
    Connection = DBDM.LiteConnection1
    TableName = 'patient'
    Left = 376
    Top = 312
  end
  object make_354: TLiteQuery
    Connection = DBDM.LiteConnection1
    Left = 512
    Top = 304
  end
  object Timer_354: TTimer
    Enabled = False
    Interval = 2000
    OnTimer = Timer_354Timer
    Left = 608
    Top = 288
  end
  object Query104: TLiteQuery
    Connection = DBDM.LiteConnection1
    Left = 64
    Top = 200
  end
  object PopupMenu2: TPopupMenu
    Left = 400
    Top = 40
    object N14: TMenuItem
      Caption = #44208#51228' '#50836#52397
      OnClick = N12Click
    end
    object N15: TMenuItem
      Caption = #44208#51228' '#52712#49548
      OnClick = N13Click
    end
  end
end
