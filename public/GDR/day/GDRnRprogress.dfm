object RnRDMUnitProgress: TRnRDMUnitProgress
  Left = 0
  Top = 0
  Caption = 'Goodoc '#51217#49688' '#54869#51221
  ClientHeight = 182
  ClientWidth = 385
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 24
    Top = 40
    Width = 337
    Height = 33
    AutoSize = False
    Caption = 'Goodoc '#51217#49688' '#54869#51221' '#51652#54665#51473' '#51077#45768#45796'.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -24
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object ProgressBar1: TProgressBar
    Left = 24
    Top = 112
    Width = 337
    Height = 33
    Smooth = True
    TabOrder = 0
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
  end
end
