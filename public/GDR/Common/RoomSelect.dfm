object RoomSelectForm: TRoomSelectForm
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'RoomSelectForm'
  ClientHeight = 367
  ClientWidth = 283
  Color = clWhite
  TransparentColor = True
  TransparentColorValue = clNavy
  DoubleBuffered = True
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #44404#47548
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClick = FormClick
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel2: TBevel
    Left = 0
    Top = 317
    Width = 283
    Height = 2
    Align = alBottom
    ExplicitTop = 8
    ExplicitWidth = 443
  end
  object Bevel1: TBevel
    Left = 0
    Top = 36
    Width = 283
    Height = 2
    Align = alTop
    ExplicitLeft = 8
    ExplicitTop = 8
    ExplicitWidth = 443
  end
  object Panel5: TPanel
    Left = 0
    Top = 38
    Width = 283
    Height = 279
    Align = alClient
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 2
    OnResize = Panel5Resize
    object Panel1: TPanel
      Left = 5
      Top = 8
      Width = 273
      Height = 257
      BevelOuter = bvNone
      Caption = 'Panel1'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #45208#45588#44256#46357
      Font.Style = []
      ParentBackground = False
      ParentFont = False
      TabOrder = 0
      object RoomGrid: TStringGrid
        Left = 0
        Top = 0
        Width = 273
        Height = 257
        Align = alClient
        BorderStyle = bsNone
        ColCount = 1
        DefaultColWidth = 270
        DefaultRowHeight = 36
        DefaultDrawing = False
        FixedCols = 0
        RowCount = 10
        FixedRows = 0
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = #45208#45588#44256#46357
        Font.Style = []
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goDrawFocusSelected]
        ParentFont = False
        ScrollBars = ssVertical
        TabOrder = 0
        OnClick = RoomGridClick
        OnDrawCell = RoomGridDrawCell
        OnMouseWheelDown = RoomGridMouseWheelDown
        OnMouseWheelUp = RoomGridMouseWheelUp
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 283
    Height = 36
    Align = alTop
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 0
    DesignSize = (
      283
      36)
    object Label1: TLabel
      Left = 6
      Top = 8
      Width = 86
      Height = 21
      Caption = #51652#47308#49892' '#49440#53469
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = [fsBold]
      ParentFont = False
    end
    object close_btn: TSakpungImageButton2
      Left = 260
      Top = 8
      Width = 20
      Height = 20
      DPIStretch = True
      ActiveButtonType = aibtButton1
      OnClick = close_btnClick
      Anchors = [akTop, akRight]
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 319
    Width = 283
    Height = 48
    Align = alBottom
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 1
    OnResize = Panel3Resize
    object Bevel3: TBevel
      Left = 0
      Top = 0
      Width = 283
      Height = 1
      Align = alTop
      ExplicitWidth = 532
    end
    object Panel4: TPanel
      Left = 118
      Top = 11
      Width = 83
      Height = 29
      BevelOuter = bvNone
      TabOrder = 0
      object SakpungImageButton1: TSakpungImageButton
        Left = 1
        Top = 1
        Width = 80
        Height = 26
        DPIStretch = True
        NomalImage.Data = {
          89504E470D0A1A0A0000000D49484452000000500000001A080600000020D2DB
          A7000000017352474200AECE1CE9000004AE4944415478DAED987B4C966518C6
          7F282846620822F3948916332A96254921D9D4DACA0E4E29E72ACCB9403182F2
          0F1733973A369543355371960466646A47B412126A7998A716289E2848F18072
          7001A1A8DDCFEEF0E3E3A4F53ABF8FEDBBFEE17B9FE77DDEF779AEFBBEAFEB7E
          712B1D1E7C0517FE37DC0C818302FA397A1F9D1265A7CA5D045A818B408B7011
          68112E022DE2E6103860003CFD14647F06E72ADBBE67E040387F1E6A6A3A7E96
          7F1F98190D996BE158896D7CF224387306F20BAE7F5FAF4441D101D8B9CBC104
          BE972207EBDB7ABCAA0A626261C4FDB0380966C4404949EBFB3C3C60CB37B061
          137CB0A2F57CB76EF042A4FEF6B94D8231017EC885F2721DDBF425A42D8503C5
          909CAA638F8F8388D16DEF7745BA9CFC4FD8B81EBE96F77E94E16002EF09064F
          4F183C18A267687698C85EBC08FB7FBD3681231F84A48532F7BBDC13DD7ABE7B
          77887AC976DDB52B5CBA64BB5E970DA94BEC09347B0ABA4B7F4F9D022784EC6D
          F97A9DF7A35682D310D884094FC2EBAF4146267C9C05A342212C0CFC7C95A4B6
          08EC2B99FB6E8A92373C08BEDF0ACB57C29516BDBDBB3B4C8F92608C80005973
          F61CECDD07AB56434303AC5E694F6073B273BE92B98310FF26787941F8233A17
          1BA359EF14049A324B5FAE07F5BA45746AB6E89A685F68A8EA56D8287B028DE6
          8D8980C8C9B04B3468A1646860202C91BFE52761ED3A25A8BE5EEF1F3F16DE88
          875912A0A3C74457FB4B292ED3C31B120C81BEBE4A6CFA2A79E66E5D374ED6CD
          4990CF0537A98E59F0572DCC7B4BE7860DD5EC753881438640E25CE8E1A9242D
          980F43858CF7976946B52CE1E0BB45B392A1B00872F3E0DBCD70F9B23ECB18CE
          33A271631E95B23B017109B6F10FD3952C230F81F2CE17A74A16C541F12125B0
          464C28670BFC5608A74FC3C3614ADEE71B75FD432321250D0A7ED6673A4509F7
          EE2DD992A1915F94A48731423F5BA21D1222877C59B428A8B506FAF9C99AB3ED
          3FB74B17E8D54B8DE86AA0EE5003315291B74D88D900870EEB5CCB127E55B438
          529CB94882143F4775D40436E43E7847F436FF272721D0C094E7EE3DD0F3562D
          11A3490686C8AA6A2D61A33B5BF3B44D993E4D4BFD7A605A8CEA6ACD26A3673E
          3EDA1299F1BF1BF41DBF6C8727C6DB1338F159BDDF646C53761B987DECD8A906
          F7A9985DCE66D56B871268D0D48A24A7E9A69AC3443D79B12D038DD118CD6C0E
          D37698EC2D2DB31F377D5D8564EA94E7A1510EDD28EE7BE1025456AA939A2C2E
          93358B16C0C1622DD196B87D108C0E17F3091099E9214194801C3E22A52C5958
          5B67E9D8379E4043404585FD9CB737DC39ACFD36C620F73B755FA357EDC11889
          29EBF6609C7CCF5EFB3153EE716268FBF66BE35D2D15D0BF9F06D5C35D9DF9E4
          292722D034B88585F673C671274DB44EA0D1557FFFB6E742EE953EAFA0751B93
          B9068E1F87B989F6E37D4456B2D668CF9AF589131198BD5E35A9394CBB103BD3
          3A811DA1BD3E70FE3C7840BA80A5A9FF6660B566E0D8C7E039D1C9C4B761FB0E
          272130FB1A914C9072F9A3F4E61268BE90A649271011AECE6FFAC1C646387254
          5CF80BFD2AB100E7F96F8C71D3BA7A9B83FF5778F75483A9EBC0148C2B1B426B
          6B6FD8B69D87C04E0A178116E122D0225C045A848B408BB84AA0A337D299F10F
          19E433B522D7D3B00000000049454E44AE426082}
        DisableImage.Data = {
          89504E470D0A1A0A0000000D49484452000000500000001A080600000020D2DB
          A7000000017352474200AECE1CE9000004F84944415478DAED98895222571486
          7F96660741115444C475CC38EA383A56F2B8A93C405E20196B328E712C77232A
          2238E0060A2AC82EE49C6B49815B26E9D48055FC555441DFEEDBB7BFFECF7251
          FCFCCBAF6534F59FA56080BDDEFE7AAFE3452A140C3401CA5113A04C3501CA54
          13A04C7D1780E9740691C8313C9E6E68B59A47CFB94EA7A1514B9034D2B37365
          B339F8FD41F4F6BA61361B2BC70FBE1E41A7D3C0E9B07FF3BA02FB07686931C3
          DED65A5F804B4BEBC8D083DD9746A3C1FBE971C4E3175859FD0B33EFDFC26432
          3C38AF542AE3C3EC67B8BB3B3134D4F7C87809A18343F13D5FC8E33072828E0E
          07F47A9D38E67677D21A3608860923AF06C5B1A3E32862D1B347D73B30E885D1
          A0C7C73F16E07275A0BFCF535F80898B4B946E4A485D67B0B7178497DCC16F56
          A954C2666BF9478067E709ACAD6DC16434626666E2C1F84DE906FB8170E577B9
          5C8242A1ACFCF6F4BAB0BCBC5903F0E2E20A57C9A4F81E0C4560D0E9E0ECB875
          A7D3D12E22A16100DE2972788C9D9D7D78BD3DE8F3BA71761647ECEC1CB95C01
          E704E93180EC5C76B0C964C4E555129DCE760C920B15F7E62E95CB043184F3F8
          25B299AC00D0DA6A45FF80072AA50A7F2EACD400AC86FD617601567AA19393A3
          28148B88C5CEC5987F771FDDEEAEC600C861B6F06595165C46B150C434852EE7
          3E76578E20C508663540CE79D1D33391BBDADA6C78FD7A08D7A96B2C93530D7A
          3DE538175AAD56A8D42A71FE3185A46F3B40F38EC14CB079EEC5C555F4D1C3BB
          090203CCE5F3D051DA1818E815738AEB4E62F0F9FC4C92AE9D805A526373635B
          8CA5E87E3D1E57FD01A652696C6E6E8B509B997E8BB50D1F92B4B8E1C13E7476
          3A1E843087D7D2F206AC560B9C4E3BBABA3AA054DC7AEEB6E09CE0F43406BD41
          87A9776395E30CC9DDDD8516AB593C7C3018C6D4D4385A2C26312649125C5D4E
          1AB740AFD30AF76FF9F6D04380D3E92CBDCC383974008EF63631674384702E97
          C7FCFC12341452A3E4228BC58C3C396167378844E2023FFDF80E5757A9073930
          9BCB41A7D53E392F876C819CACADAACA0C2D72788243FA70B565F758CC263176
          3F84FDFE10BE860F2BA17B43856A7D7D8BD6748537A3C370D0F50D0190158BC5
          2964ACE281D5924AE4241683E44ACCAD4794F20EE7376E530281035179BF456D
          761BCD21DDE62D829ACF1745AEB553887291E27BDADB6D383A8AD6000C53DBC4
          F9AF9B1C7BE76E56347A2EE654D1B59FE61685FB395FD71520EB8672E0ECEC3C
          468607D0E572D68C251297585ED9AC38707B27207266B538C7B19B8CF78A8CC3
          D1464ED521140A13300514F451D20B62A85C48B4E4626E49D6D67C02E02B0AD1
          FBBAA6EE204A2D4D369B45B17803492BC16232D3DCAD50ABD5B29EFB7F07C80F
          A3D5D58626BB24994C3DD9C6B07EFB7D0E8394FC7B7A5C4FDE8321178A8527C7
          8D06A388846ADD7506369B5534DE1215914C262342B94C51C0E17DD74F360440
          6E7039EF54EB9A0A40387C241BE00EB51DD9471A7616F7A24E72EBFD36E633E5
          6703BDD489F11F6A8E67B37931E6F5768BBEB561007A0880DD5EBB354AA652D8
          A5A22217E0737AAA0F5CA79625114F50680FC26436889CCC15F984AA7C845EEA
          D8D808DAED75DECAB1B8287C9AFBF2EC3993936F68B7F17D0116698714A43D2F
          170FAEFC2CDEC558082637D11D54D8E4A861FE8DE18ACD4DF35D05FFB7E23CCB
          0546AD7AFA7AAECA0C54925938AAD530005FAA9A0065AA0950A69A0065AA0950
          A62A00EBBD9097ACBF01C589E51BCB2C59F20000000049454E44AE426082}
        DownImage.Data = {
          89504E470D0A1A0A0000000D49484452000000500000001A080600000020D2DB
          A7000000017352474200AECE1CE90000058B4944415478DAED987B4C936714C6
          9FDE0B7229146861D08A42198A13D1CC4DDD149D4BBC2553747303119D51DC12
          E39C993A75FF38DD16A632D91CE265F3066832A76EA243DD1F8A38A7CBC40B77
          2F48E55268B9B550DA027BDF7759A5169C5B8DAD499F84A47DDFEF72BEDF77CE
          734EE1E42807F5C0ADFF2D0E05181910E0EC389E49553436BA013A22374007E5
          06E8A0DC001DD4530128522A10383B01F57BF7C34C6ED897C40395B034B790BF
          E6475E4B28972174C507A8DDB51B1DE515D6755952224C7575683A73F6B1E30A
          792F15866BD7D15270C1B900A376EF8430586EB76ED66A513A2F05DEA35F84EA
          9B0C14BF9D848E8A0ABBE3380201E22E16A03E2717EACD5BEDF74522C8E7CF63
          9F05FEFEEC6568F34EA253AD666B9ADCC388DAB90386EBD751F5E926B6269D3E
          0D7EAF4DEA335E75FA3618EFDEC5F033F968F8E1086ABECD742E40AF11B1E08A
          C5F0183C18A1CB97B1ECD0175D438FD98CB62B7FFC2B409FB16310F9D5567454
          56A2786EA2DD3E572C4248EA92070B3C1ED0D565FD5AF7FD5EA87664DA00F48A
          8DC5809821ECB37CE1027456ABD174FA34FBAE3B95CF2AC16500FEA380849950
          AE598D9AAC9DA8CDDA05DF57C64132FE55088282E03BE6E53E010A8383490667
          91F54A0C181603ED893CA8B7A4033DB6B33D87CF47C8FB4BE1F3D26888C839A6
          8606B4FD7E19F733BE46B7B113430EE5D8007C701E0F230ACE414F4AB57C712A
          785E5E904C8C677B612B57409373C83500D2321B927D80054C832C494E8158A9
          84EFB8B110CA640C646F80D4F3FC264F862C3909AD170A717BED7A7846462272
          7B0629CDFBA8DBF31D5A09A0EEF67676BC74FA5428D7AD45C9FC05E8282B8748
          1186E803FB509399054D760E0328080C8059D300F5B60CB4165E64E7F94F9B8A
          819FAC2301725092948CAE363D067DFE3764CF2815EA882F3B1DA00779F0F04D
          1BC0F3F024901231784B1A3C552A54A77D09EDCF797625EC153B1C2AEA594545
          D09E3C85C6A3C7AD25491B4ED09CD9F07B7D323AEF55A36CD162EBFAD0C3B924
          6372993D78A82211BCE85D94A62C44FBCD62069036A0C663C7A1FFF32A4CB5B5
          904C180F258147018B140AF632AB367E86E6B3BFB26BBA44090B02A48839F623
          CC0D8DB8B36E3D0C376E824F8C5EF1D14A788F1A851B6FCC84E7D0A1761E48CB
          DAACD1F47F61E2737C892F2C5ADD8317151181C03909084C9805DD2FF9A83F98
          8DF6E212B6F77009532FA69D99C22E5F924A2A448C88CD6924A691B8BDFA63D6
          AD5D0220952F29CFD6DF2E81EFED8D2E7D1BF3242A0AD2A2D3B1D143121F0F1D
          C9369A25D4CBB8A4F33E8E5A0A0A616ED2B16CE270791048A5A40BCF62A347B7
          D1C8EED172EE1CA43366D8000C9AFB16B3937AE271BD1B0EF53F7A6E8FC98461
          793F91EC3FC6FCDAA900A9384221E20ACFB307A041F5167DEBAACCEDD60C54AC
          59052EF1CCDEA263878194A2F1CE1D9B759A29A67A0DE429C9ACABF7582CE826
          0F4F47249AF5348BE9481291BE8565FFC34D844A1C1E0EBF4913217C2E84D88C
          077B8986925252CA67C90B3738F4DC4F1C60070160AEB72D4D9EAF0F064447F7
          3BC6508DBC7209D55BD3A13998D3EF3D6823E14B24FDEE7754DE6295D05B7432
          50AC5E85B6CB57D8E06D696E82283494D90B47C04719E9CCA6FB35AE03900EB8
          FAAB45367B62D2006489EF380C308CF8AA502EEF73CF7B641C99F3CED86560CC
          D12330DEBB87CA65CB6DD605B2200C23DE4D67D6DA5D7B5C0760DDBEFDC493CE
          DBEC793E1F4566AE0F1D06F828F537070E4AFB023E640AA8DAB091DDDBAC2319
          18160AE99429C427DF44E58A9576F13A0720690A2F9C3CF1C863CA483734DEBA
          FD54017289E7852C5DC23C90767E0E9907A98FB69796919F80B9EC5789237299
          FFC6D06EDADD6EB076F0FF2AEAB33D962E741BFA6F0AB42B73C51EA471E89F58
          DC2E03F059951BA083720374506E800ECA0DD04159013A3B9067597F0168E200
          BE42FF1F420000000049454E44AE426082}
        OverImage.Data = {
          89504E470D0A1A0A0000000D49484452000000500000001A080600000020D2DB
          A7000000017352474200AECE1CE90000049F4944415478DAED980B4C956518C7
          7FDC3343032F1079A5BC974A7829B54DB152D059492BCB4CE7DADA74352B6786
          2D6F1495A9E52A164BD1B5426BA5A8914AABD9C5505B89653651546E2624201A
          5EF0D2F3EC199D73B8657D4D0EDBF96F6CE77BDFF7FBCEFBFDDEE779FECFC1AF
          387EDC657CFACFF25380511D3A36F73E5AA44ACA4A7D009DC807D0A17C001DCA
          07D0A1AE0EC0C848881B05599F436565C36B6E9035A7FF8453A79A7E5678384C
          7E1832374241A16B3C7E0C9C28875DBBAF7C5F8913E1E041C8DDDBCC005F4882
          76EDEA8F9F3C090B1641BFBE3067B6AC9B0F8585F5D70506C2CA34D89A0D1F66
          D49F0F0A827109F6B94D288C8E83EF764069998D657F014973E1D02158B5DAC6
          460C8721831BDE6FC63A38760CDE5E015F7E059FAC6F6680BD7A42703074BA11
          263D64D19127277BE102ECFFED9F01F6BF159E7D5AE68A64CD8BF5E7F5D913EF
          735DFB07C0A58BAEEBCD59F0FC739E007BF680E868FB3C613C1C2F859DBBEC3A
          67A76582D700ACD5A89130ED31589F091BE46FE000B82D06C2C20C524300DB4B
          E4CE4BB2F19B6F826F25B232D6C2E53ABD7D80407B20116EE9071DDA434505EC
          DB0F1F7D0CE7CFC34B8B3D01BADF97962AA92A7329AFC2B5AD2036D6E61E7D04
          B6657B09404DB3E485B6E156B2C9058BADAE0DE86F754B41BA03D4B9A1432021
          DE6A50EABBD0A5B3456AA944CBC6CDF0AB003A7BD6D60F1F06D3A7C1C264A97D
          051011018BE4799F6E90D4DF6600C3AE37B0EB04EADE9F5DF73D3EDD3ECF97FD
          5557C3CC1976DDB50B7C96E505003BCB8BCF780242AEB1149CF594C178FF03AB
          557553B887A4D73CA9597979B02307B67F2D2979C99EA586335A0CE7F6A1F0FB
          710193E21A4F4936585A1EF4F9F74E108832967FD8009E1603DAFE0D1C38007F
          9CB04353785BE49EC808CB88F435B0FB077BA657A470DBB6F0FA6B5253E4E453
          C508F2F3A5D0B7812993A16F1F982DB529BA7BFD1AA869ADD1D298FCFD21F43A
          31A22AB783EA246E2E061237D2EAD896AD70F888CDD54DE1490F8A338F35D89A
          BA9A217AB07D7AC35BEF1844AF00A88A1908BFEC83D6AD2D45B426A914645595
          A5F020A93BDFE7589BA2B52C30E0CA9EADE95D25F7C4C618543D306D8974FCDC
          39FB8E9FF6C09D233C01DE7397998DD6B8DAE856E93E7273A1460C6EF9528B7E
          ADD7CD0A501524ADC87B69F602BA2977E9A9CF9DE38AC0A96234C1419E6BB4ED
          D0542C29F11CD7BEAE5C22757C82B9FA4571DF9A1A6B912A2A2D8A4BA4257966
          960094E84F5F5D7F6F5151307890994F48881DE291A3168567CE387AEDFF1FA0
          0228AF939A1A99DDBB35DEC6A8D6AC921E70ADD5B8C6A486101ADAF87C519165
          82BBB433983AC50C49BF5BA339A2A31DAAF69F2F4B7A9795791140350D350777
          A9018C1DE31CA0D6D5861A7655EF5E16AD75DB9825AF98192D5DEE391E2E3578
          89C0CBDC248EBFC98B00EACFB51FF778CE75EB6A3D9753804DA9B13EF0C999D6
          3BAE4CF78CC06177C0DD5227DF586135B4D9016A3ABCB9ACE9359A2EC5C55717
          A0D6BCC4FBAD06AAF3FBF9592D3D5A6006A36EEE40DEF3DF1875536D9A6B1DFC
          DF4AEBAC1A4C6DE3DD90B4C90F919F85D5CE8CC35DDE03B085CA07D0A17C001D
          CA07D0A17C001DEA6F80CDBD9196ACBF008DB13A69218012120000000049454E
          44AE426082}
        OnClick = SakpungImageButton1Click
      end
    end
  end
end
