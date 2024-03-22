object QueryTestForm: TQueryTestForm
  Left = 0
  Top = 0
  Caption = 'Query Test'
  ClientHeight = 548
  ClientWidth = 692
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #47569#51008' '#44256#46357
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 17
  object Splitter1: TSplitter
    Left = 0
    Top = 216
    Width = 692
    Height = 3
    Cursor = crVSplit
    Align = alTop
    ExplicitLeft = 8
    ExplicitTop = 289
    ExplicitWidth = 664
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 692
    Height = 216
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitTop = 41
    ExplicitWidth = 664
    object Panel3: TPanel
      Left = 588
      Top = 0
      Width = 104
      Height = 216
      Align = alRight
      TabOrder = 0
      ExplicitLeft = 560
      object Button2: TButton
        Left = 7
        Top = 6
        Width = 90
        Height = 25
        Caption = 'Open'
        TabOrder = 0
        OnClick = Button2Click
      end
      object Button3: TButton
        Left = 7
        Top = 37
        Width = 90
        Height = 25
        Caption = 'ExecSQL'
        TabOrder = 1
        OnClick = Button3Click
      end
    end
    object Memo1: TMemo
      Left = 0
      Top = 0
      Width = 588
      Height = 216
      Align = alClient
      ScrollBars = ssBoth
      TabOrder = 1
      ExplicitWidth = 560
    end
  end
  object DBGrid1: TDBGrid
    Left = 0
    Top = 219
    Width = 692
    Height = 329
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
  object LiteQuery1: TLiteQuery
    Connection = DBDM.LiteConnection1
    Left = 152
    Top = 280
  end
  object LiteQuery2: TLiteQuery
    Connection = DBDM.LiteConnection1
    Left = 152
    Top = 336
  end
  object DataSource1: TDataSource
    DataSet = LiteQuery1
    Left = 264
    Top = 328
  end
end
