object SelectCancelMSGForm: TSelectCancelMSGForm
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'SelectCancelMSGForm'
  ClientHeight = 336
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
    Top = 285
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
      Width = 146
      Height = 21
      Caption = #44144#48512' '#48143' '#52712#49548' '#47700#49884#51648
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
      Width = 399
      Height = 17
      Caption = #54872#51088#51032' '#51217#49688'/'#50696#50557' '#45236#50669' '#52712#49548' '#49884' '#45208#44032#45716' '#47700#49464#51648#47484' '#49440#53469#54644#51452#49464#50836'('#54596#49688')'
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
    Height = 234
    Align = alClient
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 1
    object Label3: TLabel
      Left = 6
      Top = 11
      Width = 70
      Height = 17
      Caption = #48156#49569' '#47700#49464#51648
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = [fsBold]
      ParentFont = False
    end
    object listgrid: TStringGrid
      Left = 6
      Top = 34
      Width = 402
      Height = 165
      BorderStyle = bsNone
      ColCount = 2
      DefaultColWidth = 55
      DefaultDrawing = False
      FixedCols = 0
      RowCount = 1
      FixedRows = 0
      Options = [goRowSelect]
      TabOrder = 0
      OnDrawCell = listgridDrawCell
      OnSelectCell = listgridSelectCell
      OnTopLeftChanged = listgridTopLeftChanged
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 287
    Width = 421
    Height = 49
    Align = alBottom
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 2
    OnResize = Panel3Resize
    object SakpungImageButton1: TSakpungImageButton
      Left = 160
      Top = 11
      Width = 100
      Height = 26
      DPIStretch = True
      NomalImage.Data = {
        89504E470D0A1A0A0000000D49484452000000640000001A080600000041CAF9
        E5000000017352474200AECE1CE9000006454944415478DAED58F94F545714FE
        18F67D405665136110461611A4281651AB718B7B6BB4D5366D62139BB4497FE8
        FFD01FDBA4A6D51A1B5BDBBA54AB55D12AB8E386880888208AC2480515106118
        61E839D7BE7178EF0D834561DACC974C32EFBE79F7DD7BBE73BEF3DD71F9FC8B
        2FFBE184C3C08509898A8A1EED753841686CBCE724C491E024C4C1E024C4C1E0
        24C4C1F0CA0909D2FA236D52022E9755E3E953A31873737385AB46831ED333C5
        EF3534EEEEEE869E1E93E21E8FFBF878A1BDBDD332C6D7991949B85E558FB6B6
        2796715D420C02037D71A9B47AD87B48491E8FE6E68778F4B8C3329698102DF6
        76F172D590E749D2C5C2CFD71BA5653786FCCC4B131232462B022547F35F0FD1
        DFDF8F98E8702C5F52801F7F2E44EBC33671AFE0CD29888D8DC0B6ED0755173D
        7F6E2EBEDDB217DDC69E01F7B23293111AA2C5E1A325080E0A809BBB2BB481FE
        58306F1A8A4F95E27E732BFACDFD68696DC3EC826C8C8D0CC1F61D8755D71D17
        1B89DCA9A9F8A3F00C9E3CE9B2B93F1717177CBAF11D317FF9B55ACBF8AC9959
        626FD67B080F0B1609652B1673E7E48878EDF8F5C8EB2364C5D20284D1422470
        E66B342EF8EA9B9DE2DA162149BA18CA941AC57CA1A15A91DD6A84F0BBAAAA6F
        A3BAE68EF8CEE470C03C3D3D60A26A339BCD3052657190EC113265F244CC989E
        815DBF1D4793A14541C21C7AFEF905A04F8E27B2A9421EB58BA1CAEA7A4C4C8A
        5310B2FEDD85A262E5B1F87AD3AE9123448EDC9C5451E2DF6FDB3F2821FC9B86
        7BCD8AE7FD7D7D101E1EAC2084ABF0E38F968979BBBA5F8C67A4256226CD5776
        B50627CF9459C6ED11B272D92C448D0B2349ABC2D9926B0A42982C5BA8B9D900
        7D4ABC8210B558E8699F5BFE89C5A810B274713E5C5D35D8B3AF7850425E56B2
        26C48F434E961E3B761EB58C6949C3572C9929BE7B7B7BA190A4ACAEBED12E21
        19E93AE4E5A6E37AE52DA4527FDBBDB748C89D1A62632210113E06DD940437EB
        EEC2687CDEDBD4244B8EE5B43626578AC58813C20DEBFD758B50547C5964392F
        C6DFCF07E3E3C6AA564863D303C51CBE344758689082100E7057971125172AC4
        BCF368734C9EE17E2BF6EE3F81696FA4613205FA3135F69F7E39425593A920C4
        D3C31DD3A7A523553F01070BCFA2EE5623F2E83A234D4755528EF28A3A217B12
        F81D2C4D86FB2D08A29EA5A1F7EEDC735C34772644478DFD0A55269B1596316B
        0404F862FDDA85F8B3E8226E90C48E0A21ACBB898931D8BC759F28795B844447
        8553AF081A74AE6B15B5E8EDEDB35C7FB87E310E1D29B16472F694140A7E076E
        D537097D96821019112224455E214C50AA3E011D1D9D387FF13A6A6AEF5AE6CE
        C9D60B5258EF4F91EC55529F8AA0845ABD6AAE20AEB6EE9EB8B76ECD02611878
        8C094999184749D582769AB3F864E980F5B3D1E07D6ED9F63BFAFACC234F08CB
        407EDE640ADA39B1010972C96277C4440D055DDD462115C1C101787BC51C5135
        1C7C269803CF416257C312E9EDE549B2F5FCD370B7191E540DD68470BFE0DFF1
        3D06073C3D3591DCD3156108B801EBC868180CAD22C092746EDABC872CF8334B
        C271E573050E2659B939933095E4F5C0A1D3A8BF6DB08C8F0821BC91A9D92962
        01ECC95952AC212764E38695E21C620D2648CA726B70265FB854894C72441CC0
        4385E7C4389F01F863268BEBEEE626FA0BCB4223B9A54EB2B02C29D959298336
        751D553267F17754CD2C857270E2BCB766BED80F9F65B8D257AF7A0BF5779A70
        ACE8922A216C3C58029968AE3496336BBC76427891CBA871B1EE9F3E7B553449
        39D49ABA1C9F7DB25A750312D8E2B2D565CBAB16B8756B17883E22653FC39ECB
        B2470883ADF1F4DC3451416CAD59AEF83D5CB572422223C660D1FC3C51B1274F
        5FC10D924D3946A44266504694D181A9B353FD70355C4238EB3690DDDDFAC301
        9B996C8F103EAFE4644F1AF09C9F9FB7704FB71B0CE8EB350FB877820E819D4F
        BBC5774E3AEE774C8274C063C809F1F2F210C6A2E47C85E2FC34A284D8C37009
        891F3F56F879D66D350C85106DA01F92A9010F1557CB6B6D0655C2506CAF1CFF
        0B4266E567A1C764521CDE24F85106CF2EC81299F9A0E5B165DC9E640D17FF59
        425853BD3CDD29E34CAA8D9BE143CEC8F4AC7780CD95F0019D6B8E1EBBA0F87B
        C31E3C48EA34E4AAA483DCABC6BF999FE597CF326A7FAADA82F3EF7707839310
        07839310078393100783931007838590D15E88132FF037227EA5F6FFA8BEB900
        00000049454E44AE426082}
      DisableImage.Data = {
        89504E470D0A1A0A0000000D49484452000000640000001A080600000041CAF9
        E5000000017352474200AECE1CE90000061B4944415478DAED5889525A59103D
        AC2A0AB881E08E6B3426318B66D1CC647E756A3E607E60324B2AC654624C26C6
        88CAA2A0022ACAA66CE274DF84177C0F04CB8932539C2A4BB8F0EE7BDDA7FBF4
        B9A87EFEE5D753D45035503121FD8EC1EB7E8E1A085E8FAB464835A1464895A1
        464895A1464895E15F27E4E8E8187EFF0EFAFABA5157A7176B272727C89D9E42
        A7D52ABECFEBFC79B1CF4EB2274865323034D44B6BA974063EDF163AED1D3018
        1AA4F560700FC7C924FAE9BE97C5CE4E102693098D8DDFF60F85F690A0D81CFD
        3D15EF1308ECD2F3A6D1D7DB55F1351726241E3F120994C3646A824AA542387C
        88C5F79FF070FA2E9A9A0CE233E7AA1BFBE1033C7974BFE8437F5A5EC50FB3D3
        D0E975673EDBD8F423164D6062621489C431DD374B494F6169C989D161074C66
        23DD530DA3B1119F9DEB881C44F1E8D1BDA2CFBDB71F86C7E3C72DDAABBEBEAE
        647CA75420CF7F9F13FB77F7744AEB2B4E17C2078767628844E37C81620F23E5
        424DB958A6B8E289234C4F4D7E3F42DE2D7E14492A0C80FF9EFDF4042A7A5F8A
        902025BEB748A5C4E209517DC508E17BD9ED36D86D16F13A1E3B02879FCD66A1
        D5A805195ABD5624A91C211B1B5B58777971EFDE045A9ACD0A123EAFB8C46B15
        DD617B27440566A40EF9F2FC9D762B02C15D0521AF5E2D204D1D5BB80F77FCB3
        678FAF8E1039DCEE4D6AF11066661E88F7A508E1EFB4B6342BAEE7968E46630A
        4258AEFE7AF15AECABD7EBA5759F7F1BABAB1EF474DB31323220AD972364E1DD
        120E0F2342D20607FB1484ACAD7B4BC6D8D16111322627440E977B43C4393B33
        25DE5F0B21EF3F2CE33497C3DDBB13E7127251C9DADDDD87D7EBC7D4D41D698D
        E7D3E2FB25F13A93CE62FCE6082C9636D199E711E2A399E6A284DBBB6CD8F207
        709FBAC44C72570CFBFB07542071E8753A583ADAC47F4631C99283E36609CBE7
        E2CA0949A652A26D474787108DC5C07A924AA6855E2B3A643B849616B3628F54
        3A85582CA1208413CCC9181CE81315BCFC794DC89EB9D984C9C971B85C9B34DC
        B7D16830607AFA0E9C6B6E0521199236976B03DB5B019A433760B5B609D9F2FB
        7630405DD24D5DC6D292071706174833DD830738E90FEE3FB84DF768108484C8
        38B0EC72C776765ACFC4717C9CC4ABF9458C8F0DC146127B2D84ACACAC0B7733
        3B3B85350AB4142107545951D2FFF3D0DDDD018D5A23BD7F39F70613376F4895
        CCDDC2AEAADDD22A2591931021B9B391A4C83B64958AC0BF154443431D061CBD
        243BEDD2DE1ECF2639C180D0FBE1E17EE1D85836DFBCFD5B18880E6B3B15410E
        F394E026320CB7884C2684E5A885C86A20D7373A7A365F6C34B8836648AE346A
        F5D513C232C041B36BB15ABF052B972C7647A7A8ECB74B3D7508774582825858
        F888A74FA78573DB2319891C46A5A199A3646549B2D264893334545BDB5A9025
        07564848F82022BEDFD6FA656E71C2F9994769EE68C962E7A8FA8334A89BCD94
        6043BD249D3F3E7D08AD4E2B151C13CEB19C27593C47BD5E1F6EDD1E83A5BD55
        5ABF12423810BEB987FED8930F0CF49EF95C4EC81F7FCE2327B3C9797A54B2BD
        1D54C90E470FD9DD6D9140269BC12E2C18DA073746EE2487DDBDB090059696FA
        BA3A18C80D79377CE70EF520EDC155CC03377F3E2A044BD4EBF977144F1F9DA1
        BA488ED378FBE60375640BC66E0C1725848DC79ADB2BE6D2F050BFC2457E7742
        927406E064A7E96187A8D5BB3A6D8AEF141BEA72FCF6FC65D100F2585C5C1209
        B79394144BDC3C256E72F2A654FD8C722EAB1C210CB6C66E724A1A8D46CC1F3E
        DFF07DB86BE5844422517CA4FD72646846E8CC62B35915FB7D7742B8B25DEB1E
        D2FB2E3A5C150FEAB28464A9035EBC98C793C70F4A56723942F86CE3F1F8CE5C
        97A2628AC6E2682379537FD5F83C46461CA2D3185C746C32D86098BF1E761972
        423299ACB0B983D4D5F2F3D3951152092E4B08CB1157295F5F0C95107244C33E
        4003B852F099A65452F3A8C4F6CAF1BF20C4E974D3D0D5280E6F7924C9C5AD50
        F2076976198D4DD27A39C9BA2CFEB384B00BCA92FBD192EE167AFC42A4E974AE
        A1A417DADC3CE6E6DE626C7C58F1F3463964C9389C92E1D0E9B417BAEE22FBF3
        BCC81F142BBB2627EC73B11F4E4BA1F6F37B95A1464895A1464895A1464895A1
        4648954122E4BA1FA4866FF8075EFD69397E2F8DF20000000049454E44AE4260
        82}
      DownImage.Data = {
        89504E470D0A1A0A0000000D49484452000000640000001A080600000041CAF9
        E5000000017352474200AECE1CE90000069A4944415478DAED580D54CD6718FF
        DDBEF5A9D52D294BA150A152EA485214A5C262B10DFB3C8E096363543E77C8E7
        306C67271F736CA4301FC550299390426318CAC22945F46D4A7B9F77E7FEE77E
        54D789BADBB9BF73EE39F7FFFCFFF7BDEFF3FC9EE7F73CEF5F3436724A23D450
        19888810B158DCDEFB5083A1B4B4544D882A414D888A414D888A414D888AE195
        13626161065F1F4F1C3FF12B9E5454729B8E8E36343535515B5B27F73CD97575
        755053532B778FECC64686282D7B24D8E8DA7F8837B2CEE4E241E943C1EEE6EA
        0C7373531C3B7EAAD53E780D7045E19DBB282E2E156CAEFD9C6069618EA3C732
        945EC7A37F1F98181BE144DA69A57FF3D2845877B66481D295B3171416A1B1B1
        113D1DBB21EAD3495816B709F7EE97F07BE32242D0BB570F2C5ABA4EE1A6274F
        8CC0DCF971A8AAAA91BA376CA80F6CACADB0ED874474EA24868EB636C4E237F0
        C1E471D893948C8282223C7FFE1C77EF15637C6418BADBDB62E9B26F14EEDBA9
        B703428287207ECB6E3C2A7FD2A47F2291081BD72FE6EB67649E15EC916F87A2
        A74337291F6CDFB4E609250B2293F635F1DD31E8CCE215B7F2DBD747C88CA8F7
        D1C5C64AB8D6D2D28486860666CC5AD22C21FDDD5D909A9625B79E8D4D279EDD
        8A08A1FF3A939D8B73E72FF1EF940CF45F1D3AE8A1EEE95334D437B0CAAAE341
        6A8990A1013E181D1E88AFD76FC1CD5B77E44878677CB8E402DEAC4228C12415
        427BF0F0E82B47C8C29819303232908A051144B1683342643132C41F5E9EAE88
        59B8865F374508C9C0B5EBB7E47EDFB1A331CF34594248AE562EFF92AF5B5959
        2DD8FD7CBD30362218E927CF2069DF11C1DE12213319A13D7AD8E197E3993878
        E8841C21A3470535E9E3850BF9F0F67693234416A12101DCCFE805ABF975BB10
        3275CA7B3C33366CDCDE2C212F2B597DFBF4C2F0A0C158B1EA3BC1662136C3F4
        6993F97743437D266549B89C7F8D57667384F80DF6C2A8B061389D7501837C3C
        B06EC336DC2EF853A13FBD7B7587ADAD0DDB4B3572F3AEA0BAFA9F3D29922C59
        90DF44AE24166D4E0865F7A2D899D89D70903B21D210C194D99C9D1CE508F1F6
        72C58D3F0AE4D6303131E612284B0805B88A55C6A1E454EE243947B2779BF58D
        8D9B7720746400FCFDBC51F2A08C3B1CF156B01C21246DE18C8881DEEED8B26D
        0F2E5EBACA8921820EB02AC93C750E0D0D0DC2F3F41F9E4C9A6EDDBEC31AB898
        C9A3086BD6C5A3A4A48C13E2C61A7B6A7A162A2AAAB88CBD083333532661D3B1
        F3A79FB9C4B60B211322C399FE3B617EEC2AA6CF414D12E2E860CF7A8555B36B
        51709E3D7B265C7FB57836B66E4F14323968982F0F3E5504E9B32408765D6D90
        C32445B64248D6060DF440D9C372A4A4A42327375F583B78B81F06FB0EE07ABF
        77FF1116DC3C746509F5C5EC4F187109BC32A857C54647E11E1B18E2B7267042
        0678F463FDA710656CEA4B484C96DA3F0D1A8E8EF6888E5D8DFAFAFAB62784B2
        2C62CC089E797917AF087659C9A2E988325C1950AF20A9B062BF9935F323CC99
        17C7E5C8D9C901F6766F42435383074A5B4B0B0606FA3062B265686880DFAFDD
        84AE9EAE14210EAC5F50C0E91E8102EE3BC8934F4F75754FB9CCBABBB9F06A28
        2B2B17A4F3F3B9CB84F19C12CED6D61ACB576C6E56B24282FD313CD017DFC7EF
        42FE6FD7057B9B10428E04050EC608A6EF34931F4E4E93BA2F4BC8DA5531D0D6
        D6927A86824A81A6CF8B48397A1247D827C07F200BA035279B406700AAC40656
        19BA3A3AE8E3D293CB024D4BE56C842D2E29657BF26DB6A9BBBB39F32C9E17B3
        924B8E2C2C2DCD11336F1A0EA7A4F1B38CA9A909E6B08AA100FFB8EB80424268
        F0181516C889DEBBFF28D2D2A5A7C8D74E086D326AEA24181B1B62FF8163AC49
        E6C83DA3A8A9CB62D386250A1D90801A37053CFB6C9EC2C02D889ECEFB8824FB
        092D4D592D1142A0D1388CF526AA207DFD0EFC7C43FF43552B4B885DD72EF8F8
        C34868B2044DDA9B82F33997E5D67BED8490F450534CCFC8C6E3C7150A9F692D
        2154012BD8B8BB60F1DA2633B92542E86C3322C84FEA77D4DB68F0B872F506EB
        55F552F712594025FE50D2D19051C948282CBC2B54B12C21068CB0D0D0A14C21
        52E5CE4F6D468832682D212ECE8EEC6C13C0755B119421844EF39EAC012B8B8C
        CCEC26832A813263AF2CFE1784448E1B891AD654650F6F12D0A83D8105FF10EB
        5D4545F7057B4B92D55AFC6709A1C9465F5F8F1DA86A85F15416F4BAA1AEEE2F
        A9315782250B3FC38E9DFBE45E6FB4043D366569B261A15AC14BCA5701BE3EF3
        4D7250540624BF34192A7AA9DA14D4AFDF550C6A42540C6A42540C6A42540C6A
        42540C0221EDBD1135FEC5DFA96BA5501AD9FC060000000049454E44AE426082}
      OverImage.Data = {
        89504E470D0A1A0A0000000D49484452000000640000001A080600000041CAF9
        E5000000017352474200AECE1CE90000061E4944415478DAED58F9535357143E
        09618704085B0464094B407610905AB7AAD4B1B52EE34C3B76A6FD6FFA43FF84
        FED6CE682BD56A69A582B80015B114541611022220BBACB25AA0E7BB9A10DE7B
        217150483BF97ECABBEFBD9B7BCF77CE77BEFB54DF7CFBDD2AB9E132508190C8
        48C376AFC30DC6D0D0A09B1057829B1017839B1017839B1017C33B2744ABF527
        53522C35B775D1FCFCA218D37878905AADA2A557FFC89EC7B846A3A1A5A557B2
        7B1A8D07F9FA78D3CCCB39EB18AED352E3A9D3DC47D333B3D6F1B858030506F8
        51736BD7A6F79098104DA32F26696AEAE5DAFC3B0D626F8F5ACC4ECF9310B783
        FCFC7CA8A5ADDBE977DE9A90E0A040F2F4D4C8C647C7266895CDB32132944A0E
        17D2D5DFAA69627246DC2BDCBD8BA27684D1E5ABB71517BD6F6F0E5D28ADA4C5
        C5A575F7D2D38C1412A2A5EADA26D2E90204B1DA403FDAFF612ED5FFD54A23A3
        F8CF551A9F98A63D851914111E4C57CAAA15D71D1D154ED9994974ABBA916667
        E7EDEE4FA522FAEADC7131FFE3273DD6F13D05E9643084AEDB43A85EC709A556
        88C5A458D7DEE22C11AFB26BB5EF8F9092C345A4E72059A0F650939A77F1FDF9
        72716D8F1004BEE5B13C53F4C13A91DD4A84E0BFCC5D7DD4F5F4B9F81D121CC8
        015391979727BDE26A5B5959A145AE2C04C91121E96909949F9B4AE51575343C
        322E23A1B828D37A9D648C110936F9A642508DC6F8281921A74F1C201F1F2F49
        2CD4F4C385F2AD23448A9CAC6451E2A5BFDCDC90904463340D0C8EC9DEF7E792
        0ED507C908815C7D71F628CF5B450B0B6BE3A9297162BEB6C74FE9FEDF6DD671
        47847C7CA4882223F442721A1F3C911102B2ECE169CF8020494A88622CF8B9D2
        CB55E27A5B08397C68377970D95EBF51BF21216F2B593B6322282B3D89CACAD7
        36A30DF4177303DE9C99D5B50FA8B76FC82121A9A638CACB315147672F999263
        E98FCA7B42EE94106508A3D0D0204E8245EAE91DE435BDEE6D4A9225C5D18F0A
        05B996586C39216858673E3B4075F52D6213AA376331D111324290618343638A
        73E843743242106004A5E96187D8E4DEE26C411E025951554FB9D92994668AA7
        A9E959DE700D15E4EF9211E2C5BD0E442427EDA4DBDC3B9E3179B806418D4DED
        D4DEF18C656FEDAB110208691A1999E09EE52FE4F1DAF53AFE8F978210486B2B
        5726CC4A274BA92D02D8509C3EB19FFEAC7B2424765B0829E6A06191172F5551
        7E5EAA5D420C917AD67FDD8673B577F4D0F2F28AF5FAECA94374879BB9259333
        D28D343D354BBDFDC3429F2D4108E34480A4482B044990C244C0A13D78D4299E
        B1202B2349481F1C1E64CFDCD52F64F393631FD0ED9A46EA793628C838C50186
        61009920C4C8D28CFE33C3EEEE1E377D5BECE72A470595722C965756B69E1064
        59415E1ADDA96912A56D8154B2E08E544ECE895EB1C05512C4EF1C2B29A61F4B
        2B847383430A0F0B164142103DD86D7973634743F5611B3C30304A1AAE065B42
        D02FF0ACA56F21E0A69458E19E6008E08EE2E30CA21A409A453ACF5FACB05A70
        241C2AFFD7DF6B3694ACECCC642639916EDE69A0BEFE11EBF89610828D64A627
        8A05A04142526C2125E4DCE725C2AEDA0281B564B92D90C90F9B3B69576A82C8
        7C642B8033002A11AE0A6716F417C8C2F0F038CDCECD8BF34206AF69A3A61ECF
        EFC32EFF74E986F57C640B9D36804E7EBA4FECA7B9D5CC66C3978E73C5F47145
        DEBDD7AC48088C07CC00FA122A0D46C316EF9D103822342E5F5F6F6A686CA70E
        73AFEC19A5A62EC5D75F1E57DC800578BFABFB3999BBFB15030729411FB1756D
        8E5C962342005863F4265410AC35E4AAB2EABEA85A2921489883FBF284D5BDDF
        D046DD6FFAC6961202E4E79AA8ADBD87E6E61614EF6F9690D776F708FD7CE596
        DD4C76444848B056F4095B087BCD41EC7F3EB2AE5701F50DADD6FDE0B9103619
        90CFB117AF0FBB627E0921904C90D7C815253D3F6D29218EB0594262A2C3D9CF
        A708DD5682338404F269DE181FEDF49A7122B71754EBFC4ED85E29FE178414F1
        C6D154A587370BE0E2D06CA1F52FC6A7D602E640B2368BFF2C217036D05F1CA8
        941A370077049D964A0770E6E441AABDFB50F679C311F07D0D9F7016153E52BE
        0B88F9796F9683A23380FC624D4A1F55EDC1FDF9DDC5E026C4C5E026C4C5E026
        C4C5E026C4C5602564BB17E2C61AFE0540BBA8C0835FFD4B0000000049454E44
        AE426082}
      OnClick = SakpungImageButton1Click
    end
  end
end