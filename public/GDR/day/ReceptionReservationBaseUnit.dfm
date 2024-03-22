object ReceptionReservationBaseForm: TReceptionReservationBaseForm
  Left = 0
  Top = 0
  Caption = 'ReceptionReservationBaseForm'
  ClientHeight = 761
  ClientWidth = 433
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #44404#47548
  Font.Style = []
  OldCreateOrder = False
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 32
    Top = 32
    Width = 321
    Height = 650
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 0
    OnResize = FormResize
    object Splitter: TSplitter
      Left = 0
      Top = 650
      Width = 321
      Height = 4
      Cursor = crVSplit
      Align = alTop
      Color = clGradientInactiveCaption
      ParentColor = False
    end
    object TopPanel: TPanel
      Left = 0
      Top = 0
      Width = 321
      Height = 650
      Align = alTop
      BevelOuter = bvNone
      ParentColor = True
      TabOrder = 0
      ExplicitHeight = 324
    end
    object BottomPanel: TPanel
      Left = 0
      Top = 654
      Width = 321
      Height = 0
      Align = alClient
      BevelOuter = bvNone
      ParentColor = True
      TabOrder = 1
      ExplicitTop = 328
      ExplicitHeight = 322
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
