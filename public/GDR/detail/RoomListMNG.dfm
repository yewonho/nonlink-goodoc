object RoomListMNGForm: TRoomListMNGForm
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'SelectCancelMSGForm'
  ClientHeight = 368
  ClientWidth = 421
  Color = clWhite
  DoubleBuffered = True
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
  object Bevel1: TBevel
    Left = 0
    Top = 49
    Width = 421
    Height = 2
    Align = alTop
    ExplicitLeft = 8
    ExplicitTop = 8
    ExplicitWidth = 443
  end
  object Bevel2: TBevel
    Left = 0
    Top = 317
    Width = 421
    Height = 2
    Align = alBottom
    ExplicitTop = 293
    ExplicitWidth = 283
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 421
    Height = 49
    Align = alTop
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 0
    DesignSize = (
      421
      49)
    object Label1: TLabel
      Left = 6
      Top = 2
      Width = 86
      Height = 21
      Caption = #51652#47308#49892' '#47785#47197
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label2: TLabel
      Left = 6
      Top = 27
      Width = 148
      Height = 17
      Caption = #51652#47308#49892' '#47785#47197#51012' '#51312#54924' '#54620#45796'.'
    end
    object close_btn: TSakpungImageButton2
      Left = 398
      Top = 3
      Width = 20
      Height = 20
      DPIStretch = True
      ActiveButtonType = aibtButton1
      OnClick = close_btnClick
      Anchors = [akTop, akRight]
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 51
    Width = 421
    Height = 266
    Align = alClient
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 1
    DesignSize = (
      421
      266)
    object Label3: TLabel
      Left = 6
      Top = 11
      Width = 39
      Height = 17
      Caption = #51652#47308#49892
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = [fsBold]
      ParentFont = False
    end
    object listgrid: TStringGrid
      Left = 6
      Top = 36
      Width = 402
      Height = 226
      Anchors = [akLeft, akTop, akRight, akBottom]
      BorderStyle = bsNone
      ColCount = 3
      DefaultColWidth = 125
      DefaultDrawing = False
      FixedCols = 0
      RowCount = 2
      Options = [goRowSelect]
      TabOrder = 0
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 319
    Width = 421
    Height = 49
    Align = alBottom
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 2
    OnResize = Panel3Resize
    object Button1: TButton
      Left = 64
      Top = 6
      Width = 75
      Height = 25
      Caption = #45796#49884' '#51069#44592
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 288
      Top = 6
      Width = 75
      Height = 25
      Caption = #54869#51064
      TabOrder = 1
      OnClick = Button2Click
    end
  end
end
