object ReceptionDialogForm: TReceptionDialogForm
  Left = 0
  Top = 0
  Caption = #54872#51088' '#51217#49688
  ClientHeight = 582
  ClientWidth = 627
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #47569#51008' '#44256#46357
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 17
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 627
    Height = 185
    Align = alTop
    TabOrder = 0
    ExplicitWidth = 589
    DesignSize = (
      627
      185)
    object Label1: TLabel
      Left = 8
      Top = 8
      Width = 131
      Height = 17
      Caption = #51652#47308#49892#51012' '#49440#53469' '#54616#49464#50836'!'
    end
    object DBGrid1: TDBGrid
      Left = 8
      Top = 31
      Width = 611
      Height = 146
      Anchors = [akLeft, akTop, akRight, akBottom]
      DataSource = DataSource1
      Options = [dgEditing, dgAlwaysShowEditor, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
      TabOrder = 0
      TitleFont.Charset = ANSI_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -13
      TitleFont.Name = #47569#51008' '#44256#46357
      TitleFont.Style = []
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 185
    Width = 627
    Height = 356
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitLeft = -196
    ExplicitTop = 32
    ExplicitWidth = 785
    ExplicitHeight = 417
    object Panel4: TPanel
      Left = 0
      Top = 0
      Width = 627
      Height = 41
      Align = alTop
      TabOrder = 0
      ExplicitWidth = 785
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
        OnKeyPress = LabeledEdit2KeyPress
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
        OnKeyPress = LabeledEdit2KeyPress
      end
      object Button3: TButton
        Left = 527
        Top = 8
        Width = 75
        Height = 25
        Caption = #44160#49353
        TabOrder = 2
        OnClick = Button3Click
      end
    end
    object DBGrid2: TDBGrid
      Left = 0
      Top = 41
      Width = 627
      Height = 315
      Align = alClient
      DataSource = DataSource2
      Options = [dgEditing, dgAlwaysShowEditor, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
      TabOrder = 1
      TitleFont.Charset = ANSI_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -13
      TitleFont.Name = #47569#51008' '#44256#46357
      TitleFont.Style = []
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 541
    Width = 627
    Height = 41
    Align = alBottom
    TabOrder = 2
    ExplicitLeft = 208
    ExplicitTop = 288
    ExplicitWidth = 185
    object Button1: TButton
      Left = 6
      Top = 8
      Width = 75
      Height = 25
      Caption = #51217#49688
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 87
      Top = 8
      Width = 75
      Height = 25
      Caption = #52712#49548
      TabOrder = 1
      OnClick = Button2Click
    end
  end
  object roomlist: TLiteTable
    Connection = DBDM.LiteConnection1
    TableName = 'room'
    Left = 160
    Top = 72
  end
  object DataSource1: TDataSource
    Left = 248
    Top = 80
  end
  object DataSource2: TDataSource
    DataSet = LiteQuery1
    Left = 272
    Top = 304
  end
  object LiteQuery1: TLiteQuery
    Connection = DBDM.LiteConnection1
    Left = 152
    Top = 304
  end
end
