object ElectronicPrescriptionsForm: TElectronicPrescriptionsForm
  Left = 0
  Top = 0
  Caption = 'ElectronicPrescriptionsForm'
  ClientHeight = 529
  ClientWidth = 911
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
    Left = 56
    Top = 24
    Width = 777
    Height = 441
    BevelOuter = bvNone
    Caption = 'Panel1'
    TabOrder = 0
    object cid1: TLabeledEdit
      Left = 8
      Top = 24
      Width = 121
      Height = 25
      EditLabel.Width = 133
      EditLabel.Height = 17
      EditLabel.Caption = 'chartReceptnResultId1'
      TabOrder = 0
    end
    object cid2: TLabeledEdit
      Left = 153
      Top = 24
      Width = 121
      Height = 25
      EditLabel.Width = 133
      EditLabel.Height = 17
      EditLabel.Caption = 'chartReceptnResultId2'
      TabOrder = 1
    end
    object cid3: TLabeledEdit
      Left = 296
      Top = 24
      Width = 121
      Height = 25
      EditLabel.Width = 133
      EditLabel.Height = 17
      EditLabel.Caption = 'chartReceptnResultId3'
      TabOrder = 2
    end
    object cid4: TLabeledEdit
      Left = 8
      Top = 72
      Width = 121
      Height = 25
      EditLabel.Width = 133
      EditLabel.Height = 17
      EditLabel.Caption = 'chartReceptnResultId4'
      TabOrder = 3
    end
    object cid5: TLabeledEdit
      Left = 153
      Top = 72
      Width = 121
      Height = 25
      EditLabel.Width = 133
      EditLabel.Height = 17
      EditLabel.Caption = 'chartReceptnResultId5'
      TabOrder = 4
    end
    object cid6: TLabeledEdit
      Left = 296
      Top = 72
      Width = 121
      Height = 25
      EditLabel.Width = 133
      EditLabel.Height = 17
      EditLabel.Caption = 'chartReceptnResultId6'
      TabOrder = 5
    end
    object Button1: TButton
      Left = 440
      Top = 8
      Width = 121
      Height = 89
      Caption = #52376#48169#51204' '#44592#48376#44050
      TabOrder = 6
      OnClick = Button1Click
    end
  end
  object ReceptionExistsQuery: TLiteQuery
    Connection = DBDM.LiteConnection1
    SQL.Strings = (
      'select * from reception'
      'where'
      '   chartrrid1 = :chartrrid1'
      '   and chartrrid2 = :chartrrid2'
      '   and chartrrid3 = :chartrrid3'
      '   and chartrrid4 = :chartrrid4'
      '   and chartrrid5 = :chartrrid5'
      '   and chartrrid6 = :chartrrid6')
    Left = 80
    Top = 144
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'chartrrid1'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'chartrrid2'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'chartrrid3'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'chartrrid4'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'chartrrid5'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'chartrrid6'
        Value = nil
      end>
  end
  object LiteQuery1: TLiteQuery
    Connection = DBDM.LiteConnection1
    SQL.Strings = (
      'select * from '
      'reception m'
      'inner join patient as s on (m.chartid = s.chartid)'
      'where'
      'chartrrid1 = :chartrrid1'
      'and chartrrid2 = :chartrrid2'
      'and chartrrid3 = :chartrrid3'
      'and chartrrid4 = :chartrrid4'
      'and chartrrid5 = :chartrrid5'
      'and chartrrid6 = :chartrrid6')
    Left = 40
    Top = 232
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'chartrrid1'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'chartrrid2'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'chartrrid3'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'chartrrid4'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'chartrrid5'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'chartrrid6'
        Value = nil
      end>
  end
end
