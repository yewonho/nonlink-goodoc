object PatientStateAutomationForm: TPatientStateAutomationForm
  Left = 0
  Top = 0
  Caption = #54872#51088#49345#53468#48320#44221
  ClientHeight = 450
  ClientWidth = 688
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    688
    450)
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 700
    Height = 201
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object Label1: TLabel
      Left = 10
      Top = 10
      Width = 44
      Height = 13
      Caption = #51452#49548#51077#47141
    end
    object Label2: TLabel
      Left = 343
      Top = 10
      Width = 42
      Height = 13
      Caption = 'uniqueId'
    end
    object Edit1: TEdit
      Left = 10
      Top = 29
      Width = 320
      Height = 21
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
    end
    object Edit2: TEdit
      Left = 343
      Top = 29
      Width = 320
      Height = 21
      Color = clInactiveCaption
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clInactiveCaptionText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 1
    end
    object Button1: TButton
      Left = 10
      Top = 56
      Width = 75
      Height = 25
      Align = alCustom
      Caption = #50672#44208
      TabOrder = 2
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 91
      Top = 56
      Width = 75
      Height = 25
      Caption = 'Test'
      TabOrder = 3
      Visible = False
      OnClick = Button2Click
    end
  end
end
