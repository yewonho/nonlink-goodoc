object ReservationMngForm: TReservationMngForm
  Left = 0
  Top = 0
  Caption = 'ReservationMngForm'
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
        Width = 207
        Height = 25
        DataSource = DataSource1
        VisibleButtons = [nbFirst, nbPrior, nbNext, nbLast, nbDelete, nbEdit, nbPost, nbCancel, nbRefresh]
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
    end
    object DBGrid1: TDBGrid
      Left = 0
      Top = 41
      Width = 785
      Height = 335
      Align = alClient
      DataSource = DataSource1
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
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
        Width = 150
        Height = 25
        Caption = #49440#53469#54620' '#50696#50557' '#52712#49548
        TabOrder = 0
        OnClick = Button2Click
      end
      object Button4: TButton
        Left = 164
        Top = 10
        Width = 150
        Height = 25
        Caption = #49345#53468' '#48320#44221
        TabOrder = 1
        OnMouseDown = Button4MouseDown
      end
    end
  end
  object DataSource1: TDataSource
    DataSet = LiteQuery1
    OnDataChange = DataSource1DataChange
    Left = 216
    Top = 88
  end
  object LiteQuery1: TLiteQuery
    Connection = DBDM.LiteConnection1
    AfterOpen = LiteQuery1AfterOpen
    BeforeClose = LiteQuery1BeforeClose
    BeforeInsert = LiteQuery1BeforeEdit
    BeforeEdit = LiteQuery1BeforeEdit
    BeforePost = LiteQuery1AfterOpen
    AfterPost = LiteQuery1AfterPost
    AfterCancel = LiteQuery1AfterPost
    Left = 96
    Top = 88
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
    Left = 296
    Top = 32
    object N2: TMenuItem
      Tag = 2
      Caption = #50696#50557#50756#47308
      OnClick = N7Click
    end
    object N1: TMenuItem
      Caption = #51652#47308#45824#44592
      OnClick = N1Click
    end
    object N4: TMenuItem
      Caption = '-'
      Visible = False
    end
    object N5: TMenuItem
      Tag = 11
      Caption = #48376#51064' '#52712#49548
      Visible = False
      OnClick = N7Click
    end
    object N6: TMenuItem
      Tag = 12
      Caption = #48337#50896' '#52712#49548
      Visible = False
      OnClick = N7Click
    end
    object N7: TMenuItem
      Tag = 13
      Caption = #51088#46041' '#52712#49548
      Visible = False
      OnClick = N7Click
    end
  end
  object reception: TLiteTable
    Connection = DBDM.LiteConnection1
    TableName = 'reception'
    Left = 256
    Top = 256
  end
  object processQuery: TLiteQuery
    Connection = DBDM.LiteConnection1
    Left = 336
    Top = 96
  end
end
