object RoomMngForm: TRoomMngForm
  Left = 0
  Top = 0
  Caption = #51652#47308#49892' '#44288#47532
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
        Top = 8
        Width = 100
        Height = 25
        Caption = 'All Refresh'
        TabOrder = 1
        OnClick = Button1Click
      end
      object Edit1: TEdit
        Left = 464
        Top = 6
        Width = 225
        Height = 25
        TabOrder = 2
        Text = 'Edit1'
      end
    end
    object DBGrid1: TDBGrid
      Left = 0
      Top = 0
      Width = 785
      Height = 376
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
  end
  object LiteQuery1: TLiteQuery
    Connection = DBDM.LiteConnection1
    BeforeInsert = LiteQuery1BeforeInsert
    BeforeEdit = LiteQuery1BeforeInsert
    AfterPost = LiteQuery1AfterPost
    AfterCancel = LiteQuery1AfterPost
    Left = 160
    Top = 192
  end
  object DataSource1: TDataSource
    DataSet = LiteQuery1
    Left = 272
    Top = 240
  end
  object LiteQuery2: TLiteQuery
    Connection = DBDM.LiteConnection1
    Left = 160
    Top = 264
  end
end
