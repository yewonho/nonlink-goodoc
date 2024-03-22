object SetEnvForm: TSetEnvForm
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = #54872#44221
  ClientHeight = 254
  ClientWidth = 369
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #44404#47548
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 8
    Top = 8
    Width = 353
    Height = 193
    ActivePage = TabSheet6
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = #49892#54665' '#50948#52824
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Label7: TLabel
        Left = 10
        Top = 5
        Width = 288
        Height = 13
        Caption = #45796#47480' '#52285#51012' '#50676#50612#46020' '#54532#47196#44536#47016#51060' '#47592' '#50526#50640' '#50948#52824#54616#46020#47197' '
      end
      object Label8: TLabel
        Left = 10
        Top = 25
        Width = 116
        Height = 13
        Caption = #50976#51648#54624' '#49688' '#51080#49845#45768#45796'.'
      end
      object StayOnTop_CheckBox: TCheckBox
        Left = 24
        Top = 46
        Width = 146
        Height = 17
        Caption = #54637#49345' '#47592' '#50526#50640' '#50976#51648#54616#44592
        TabOrder = 0
      end
      object maxform_check: TCheckBox
        Left = 25
        Top = 81
        Width = 77
        Height = 17
        Caption = #52572#45824' '#54868#47732
        Enabled = False
        TabOrder = 1
        Visible = False
      end
      object Panel2: TPanel
        Left = 32
        Top = 104
        Width = 281
        Height = 57
        BevelOuter = bvNone
        BorderStyle = bsSingle
        Enabled = False
        TabOrder = 2
        Visible = False
        object leftposi_checkbox: TRadioButton
          Left = 44
          Top = 18
          Width = 70
          Height = 17
          Caption = #51340#52769' '#51221#47148
          Enabled = False
          TabOrder = 0
          Visible = False
        end
        object RadioButton2: TRadioButton
          Left = 163
          Top = 18
          Width = 70
          Height = 17
          Alignment = taLeftJustify
          Caption = #50864#52769' '#51221#47148
          Checked = True
          Enabled = False
          TabOrder = 1
          TabStop = True
          Visible = False
        end
      end
    end
    object TabSheet2: TTabSheet
      Caption = #48337#50896' '#51221#48372
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Panel3: TPanel
        Left = 0
        Top = 0
        Width = 345
        Height = 164
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object Label1: TLabel
          Left = 49
          Top = 54
          Width = 82
          Height = 13
          Caption = #50836#50577#44592#44288' '#48264#54840
        end
        object Label2: TLabel
          Left = 49
          Top = 99
          Width = 42
          Height = 13
          Caption = #52264#53944' ID'
        end
        object hospitalNo_Edit: TEdit
          Left = 146
          Top = 51
          Width = 150
          Height = 21
          NumbersOnly = True
          TabOrder = 0
        end
        object chartid_Edit: TEdit
          Left = 146
          Top = 91
          Width = 60
          Height = 21
          NumbersOnly = True
          TabOrder = 1
          Text = '9999'
        end
      end
    end
    object TabSheet3: TTabSheet
      Caption = #50629#45936#51060#53944
      Enabled = False
      ImageIndex = 2
      TabVisible = False
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Label3: TLabel
        Left = 3
        Top = 11
        Width = 336
        Height = 30
        AutoSize = False
        Caption = #48337#50896' '#44288#47532#51088' '#49324#51060#53944#50640#49436' '#52628#44032'/'#49325#51228#46108' '#51652#47308#49892' '#47785#47197#47484' '#50629#45936#51060#53944' '#54633#45768#45796'.'
      end
      object roominfo_update_btn: TButton
        Left = 83
        Top = 70
        Width = 180
        Height = 25
        Caption = #51652#47308#49892' '#47785#47197' '#50629#45936#51060#53944
        TabOrder = 0
        OnClick = roominfo_update_btnClick
      end
      object cancelmsg_update_btn: TButton
        Left = 83
        Top = 101
        Width = 180
        Height = 25
        Caption = #52712#49548#47700#49884#51648' '#47785#47197' '#50629#45936#51060#53944
        TabOrder = 1
        Visible = False
        OnClick = cancelmsg_update_btnClick
      end
    end
    object TabSheet4: TTabSheet
      Caption = #52264#53944' '#49444#51221
      ImageIndex = 3
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Label4: TLabel
        Left = 3
        Top = 3
        Width = 284
        Height = 13
        Caption = #54872#51088' '#51217#49688' '#51221#48372#47484' '#51204#49569#54624' '#54532#47196#44536#47016#51012' '#49444#51221#54633#45768#45796'.'
      end
      object Label5: TLabel
        Left = 3
        Top = 148
        Width = 313
        Height = 13
        Caption = #8251' '#47196#44536#51064' '#51060#54980' '#48320#44221#49884' '#54532#47196#44536#47016' '#51116#49884#51089#54616#50668#50556' '#54633#45768#45796'.'
        Color = clBtnFace
        Font.Charset = ANSI_CHARSET
        Font.Color = clRed
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = []
        ParentColor = False
        ParentFont = False
      end
      object chart_set_combobox: TComboBox
        Left = 3
        Top = 22
        Width = 240
        Height = 21
        TabOrder = 0
        Text = 'chart_set_combobox'
        OnChange = OnChangeChartSet
      end
      object chart_dbconn_info: TMemo
        Left = 3
        Top = 49
        Width = 339
        Height = 66
        Font.Charset = ANSI_CHARSET
        Font.Color = clDefault
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = []
        Lines.Strings = (
          'chart_dbconn_info')
        ParentFont = False
        ReadOnly = True
        TabOrder = 1
      end
      object Button3: TButton
        Left = 3
        Top = 121
        Width = 107
        Height = 25
        Caption = #44592#48376#44050'('#47196#52972')'
        TabOrder = 2
        OnClick = Button3Click
      end
      object Button4: TButton
        Left = 116
        Top = 121
        Width = 109
        Height = 25
        Caption = #44592#48376#44050'('#47532#47784#53944')'
        TabOrder = 3
        OnClick = Button4Click
      end
      object cb_findPatient: TCheckBox
        Left = 258
        Top = 22
        Width = 84
        Height = 21
        Caption = #54872#51088' '#51312#54924
        Color = clBtnFace
        ParentColor = False
        TabOrder = 4
        OnClick = cb_findPatientClick
      end
    end
    object TabSheet5: TTabSheet
      Caption = #54637#47785' '#49444#51221
      ImageIndex = 4
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Label6: TLabel
        Left = 3
        Top = 3
        Width = 306
        Height = 13
        Caption = #51217#49688#50752' '#51217#49688#50836#52397#50640#49436' '#48372#50668#51648#45716' '#54637#47785#51012' '#49440#53469#54644#51452#49464#50836'.'
      end
      object cb_showopt_room: TCheckBox
        Left = 16
        Top = 113
        Width = 97
        Height = 17
        Caption = #51652#47308#49892
        TabOrder = 0
      end
      object cb_showopt_regnum: TCheckBox
        Left = 176
        Top = 32
        Width = 97
        Height = 17
        Caption = #51452#48124#48264#54840
        TabOrder = 1
      end
      object cb_showopt_create_time: TCheckBox
        Left = 176
        Top = 72
        Width = 97
        Height = 17
        Caption = #50836#52397#49884#44033
        TabOrder = 2
      end
      object cb_showopt_reservation_time: TCheckBox
        Left = 248
        Top = 144
        Width = 97
        Height = 17
        Caption = #50696#50557#49884#44033
        Enabled = False
        TabOrder = 3
        Visible = False
      end
      object cb_showopt_Symptom: TCheckBox
        Left = 248
        Top = 121
        Width = 97
        Height = 17
        Caption = #45236#50896#47785#51201
        DoubleBuffered = True
        Enabled = False
        ParentDoubleBuffered = False
        TabOrder = 4
        Visible = False
      end
      object cb_showopt_State: TCheckBox
        Left = 16
        Top = 32
        Width = 97
        Height = 17
        Caption = #49688#45800
        TabOrder = 5
      end
      object cb_showopt_isFirst: TCheckBox
        Left = 16
        Top = 72
        Width = 97
        Height = 17
        Caption = #54872#51088#50976#54805
        TabOrder = 6
      end
    end
    object TabSheet6: TTabSheet
      Caption = #50672#44208' '#54869#51064
      ImageIndex = 5
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object HookResult: TLabel
        Left = 36
        Top = 122
        Width = 280
        Height = 13
        Caption = #48708#50672#46041' '#54532#47196#44536#47016#51012' '#52264#53944#48372#45796' '#45208#51473#50640' '#49892#54665#54616#49464#50836'.'
      end
      object NHButton: TButton
        Left = 36
        Top = 32
        Width = 113
        Height = 57
        Caption = #52264#53944' '#50672#44208' '#54869#51064
        TabOrder = 0
        OnClick = NewinsertCheck
      end
      object OHButton: TButton
        Left = 195
        Top = 32
        Width = 113
        Height = 57
        Caption = #51217#49688' '#53580#49828#53944
        TabOrder = 1
        OnClick = NewinsertTest
      end
    end
  end
  object Panel1: TPanel
    Left = 8
    Top = 206
    Width = 353
    Height = 41
    TabOrder = 1
    object Button1: TButton
      Left = 74
      Top = 8
      Width = 100
      Height = 25
      Caption = #51200#51109
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 180
      Top = 8
      Width = 100
      Height = 25
      Caption = #52712#49548
      ModalResult = 2
      TabOrder = 1
    end
  end
end
