object ReservationMonthListForm: TReservationMonthListForm
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'ReservationMonthListForm'
  ClientHeight = 375
  ClientWidth = 501
  Color = clWhite
  Ctl3D = False
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
    Left = 48
    Top = 24
    Width = 393
    Height = 281
    BevelOuter = bvNone
    Constraints.MinHeight = 30
    ParentColor = True
    TabOrder = 0
    object Panel3: TPanel
      Left = 0
      Top = 30
      Width = 393
      Height = 28
      Align = alTop
      BevelOuter = bvNone
      ParentColor = True
      TabOrder = 0
      object Panel4: TPanel
        Left = 106
        Top = 0
        Width = 287
        Height = 28
        Align = alRight
        BevelOuter = bvNone
        ParentColor = True
        TabOrder = 0
        object filter_btn: TSakpungImageButton2
          Left = 257
          Top = 2
          Width = 24
          Height = 24
          DPIStretch = True
          ActiveButtonType = aibtButton1
          OnClick = filter_btnClick
        end
        object all_check: TCheckBox
          Left = 2
          Top = 5
          Width = 47
          Height = 17
          Caption = #51204#52404
          Checked = True
          State = cbChecked
          TabOrder = 0
          OnClick = all_checkClick
        end
        object Decide_check: TCheckBox
          Left = 53
          Top = 5
          Width = 47
          Height = 17
          Caption = #50696#50557
          Checked = True
          State = cbChecked
          TabOrder = 1
          OnClick = all_checkClick
        end
        object VisiteDecide_check: TCheckBox
          Left = 105
          Top = 5
          Width = 47
          Height = 17
          Caption = #45236#50896
          Checked = True
          State = cbChecked
          TabOrder = 2
          OnClick = all_checkClick
        end
        object finish_check: TCheckBox
          Left = 157
          Top = 5
          Width = 47
          Height = 17
          Caption = #50756#47308
          Checked = True
          State = cbChecked
          TabOrder = 3
          OnClick = all_checkClick
        end
        object cancel_check: TCheckBox
          Left = 209
          Top = 5
          Width = 47
          Height = 17
          Caption = #52712#49548
          Checked = True
          State = cbChecked
          TabOrder = 4
          OnClick = all_checkClick
        end
      end
    end
    object listgrid: TStringGrid
      Left = 0
      Top = 58
      Width = 393
      Height = 223
      Align = alClient
      BorderStyle = bsNone
      ColCount = 7
      FixedCols = 0
      RowCount = 2
      Options = [goColSizing, goRowSelect, goFixedColClick, goFixedRowClick]
      TabOrder = 1
      OnDblClick = listgridDblClick
      OnDrawCell = listgridDrawCell
      OnFixedCellClick = listgridFixedCellClick
      OnMouseActivate = listgridMouseActivate
      OnMouseLeave = listgridMouseLeave
      OnMouseMove = listgridMouseMove
      OnMouseUp = listgridMouseUp
      OnTopLeftChanged = listgridTopLeftChanged
      ColWidths = (
        64
        64
        64
        64
        64
        64
        64)
    end
    object Panel2: TPanel
      Left = 0
      Top = 0
      Width = 393
      Height = 30
      Align = alTop
      BevelOuter = bvNone
      Color = 13661467
      ParentBackground = False
      TabOrder = 2
      StyleElements = []
      DesignSize = (
        393
        30)
      object Label1: TLabel
        Left = 9
        Top = 5
        Width = 96
        Height = 20
        Caption = #50696#50557' '#54869#51221' (xx)'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWhite
        Font.Height = -15
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = [fsBold]
        ParentFont = False
      end
      object ec_btn: TSakpungImageButton2
        Left = 344
        Top = 5
        Width = 40
        Height = 20
        DPIStretch = True
        ActiveButtonType = aibtButton1
        OnClick = ec_btnClick
        Anchors = [akTop, akRight]
      end
    end
  end
  object BalloonHint1: TBalloonHint
    Left = 56
    Top = 186
  end
end
