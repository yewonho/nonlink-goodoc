object PatientMngForm: TPatientMngForm
  Left = 0
  Top = 0
  Caption = #54872#51088' '#44288#47532
  ClientHeight = 491
  ClientWidth = 836
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #47569#51008' '#44256#46357
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 17
  object Panel1: TPanel
    Left = 24
    Top = 32
    Width = 785
    Height = 417
    BevelOuter = bvNone
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
        Width = 240
        Height = 25
        DataSource = DataSource1
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
    object Panel3: TPanel
      Left = 0
      Top = 0
      Width = 785
      Height = 73
      Align = alTop
      TabOrder = 1
      object LabeledEdit1: TLabeledEdit
        Left = 64
        Top = 8
        Width = 177
        Height = 25
        EditLabel.Width = 52
        EditLabel.Height = 17
        EditLabel.Caption = #55092#45824#51204#54868
        LabelPosition = lpLeft
        TabOrder = 0
      end
      object LabeledEdit2: TLabeledEdit
        Left = 328
        Top = 8
        Width = 193
        Height = 25
        EditLabel.Width = 78
        EditLabel.Height = 17
        EditLabel.Caption = #51452#48124#46321#47197#48264#54840
        LabelPosition = lpLeft
        TabOrder = 1
      end
      object Button2: TButton
        Left = 8
        Top = 39
        Width = 150
        Height = 25
        Caption = #49440#53469' '#54872#51088' '#51217#49688
        Enabled = False
        TabOrder = 2
        OnClick = Button2Click
      end
      object Button3: TButton
        Left = 164
        Top = 39
        Width = 117
        Height = 25
        Caption = #49888#44508' '#54872#51088' '#54644#51648
        Enabled = False
        TabOrder = 3
        OnClick = Button3Click
      end
    end
    object DBGrid1: TDBGrid
      Left = 0
      Top = 73
      Width = 785
      Height = 303
      Align = alClient
      DataSource = DataSource1
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
      TabOrder = 2
      TitleFont.Charset = ANSI_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -13
      TitleFont.Name = #47569#51008' '#44256#46357
      TitleFont.Style = []
    end
  end
  object LiteQuery1: TLiteQuery
    Connection = DBDM.LiteConnection1
    AfterOpen = LiteQuery1AfterOpen
    BeforeClose = LiteQuery1BeforeClose
    BeforeInsert = LiteQuery1BeforeEdit
    BeforeEdit = LiteQuery1BeforeEdit
    AfterPost = LiteQuery1AfterPost
    AfterCancel = LiteQuery1AfterPost
    Left = 160
    Top = 192
  end
  object DataSource1: TDataSource
    DataSet = LiteQuery1
    OnDataChange = DataSource1DataChange
    Left = 272
    Top = 240
  end
  object LiteQuery2: TLiteQuery
    Connection = DBDM.LiteConnection1
    AfterOpen = LiteQuery1AfterOpen
    BeforeClose = LiteQuery1BeforeClose
    BeforeInsert = LiteQuery1BeforeEdit
    BeforeEdit = LiteQuery1BeforeEdit
    AfterPost = LiteQuery1AfterPost
    AfterCancel = LiteQuery1AfterPost
    Left = 136
    Top = 280
  end
  object update_352: TLiteQuery
    Connection = DBDM.LiteConnection1
    AfterOpen = LiteQuery1AfterOpen
    BeforeClose = LiteQuery1BeforeClose
    BeforeInsert = LiteQuery1BeforeEdit
    BeforeEdit = LiteQuery1BeforeEdit
    AfterPost = LiteQuery1AfterPost
    AfterCancel = LiteQuery1AfterPost
    Left = 256
    Top = 312
  end
  object updategdid_query: TLiteQuery
    Connection = DBDM.LiteConnection1
    Left = 376
    Top = 240
  end
  object gdid_query: TLiteQuery
    Connection = DBDM.LiteConnection1
    Left = 496
    Top = 248
  end
  object removepatnt_query: TLiteQuery
    Connection = DBDM.LiteConnection1
    AfterDelete = RemovePatientAfterDelete
    Left = 416
    Top = 320
  end
end
