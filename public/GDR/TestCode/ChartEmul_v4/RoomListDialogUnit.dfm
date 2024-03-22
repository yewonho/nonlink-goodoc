object RoomListDialogForm: TRoomListDialogForm
  Left = 0
  Top = 0
  Caption = #54872#51088' '#51217#49688
  ClientHeight = 393
  ClientWidth = 506
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #47569#51008' '#44256#46357
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 17
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 506
    Height = 352
    Align = alClient
    TabOrder = 0
    DesignSize = (
      506
      352)
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
      Width = 490
      Height = 313
      Anchors = [akLeft, akTop, akRight, akBottom]
      DataSource = DataSource1
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
      TabOrder = 0
      TitleFont.Charset = ANSI_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -13
      TitleFont.Name = #47569#51008' '#44256#46357
      TitleFont.Style = []
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 352
    Width = 506
    Height = 41
    Align = alBottom
    TabOrder = 1
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
    DataSet = roomlist
    Left = 248
    Top = 80
  end
end
