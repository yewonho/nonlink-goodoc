object ReservationMonthBaseForm: TReservationMonthBaseForm
  Left = 0
  Top = 0
  Caption = 'ReservationMonthBaseForm'
  ClientHeight = 886
  ClientWidth = 521
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #47569#51008' '#44256#46357
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 17
  object Panel1: TPanel
    Left = 12
    Top = 16
    Width = 473
    Height = 833
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 0
    object Panel2: TPanel
      Left = 0
      Top = 367
      Width = 473
      Height = 466
      Align = alClient
      BevelOuter = bvNone
      ParentColor = True
      TabOrder = 0
      object Splitter1: TSplitter
        Left = 0
        Top = 201
        Width = 473
        Height = 3
        Cursor = crVSplit
        Align = alTop
        Color = clGradientInactiveCaption
        ParentColor = False
      end
      object BottomPanel: TPanel
        Left = 0
        Top = 204
        Width = 473
        Height = 262
        Align = alClient
        BevelOuter = bvNone
        ParentColor = True
        TabOrder = 0
      end
      object TopPanel: TPanel
        Left = 0
        Top = 0
        Width = 473
        Height = 201
        Align = alTop
        BevelOuter = bvNone
        ParentColor = True
        TabOrder = 1
      end
    end
    object Panel3: TPanel
      Left = 0
      Top = 0
      Width = 473
      Height = 367
      Align = alTop
      BevelOuter = bvNone
      ParentColor = True
      TabOrder = 1
    end
  end
  object ResizeTimer: TTimer
    Enabled = False
    Interval = 10
    OnTimer = ResizeTimerTimer
    Left = 56
    Top = 112
  end
end
