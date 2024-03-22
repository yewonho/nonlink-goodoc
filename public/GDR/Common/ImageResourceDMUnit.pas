unit ImageResourceDMUnit;

interface

uses
  System.SysUtils, System.Classes,
  SakpungPngImageList, SakpungImageButton;

type
  TImageResourceDM = class(TDataModule)
  private
    { Private declarations }
    FRootFolder : string;
    FButtonImageList : TSakpungPngImageList;
    FECButtonImageList : TSakpungPngImageList;
    FWindowButtonImageList : TSakpungPngImageList;
    FButtonImageList24x24 : TSakpungPngImageList;
    FButtonImageList28x18 : TSakpungPngImageList;
    FButtonImageList80x26: TSakpungPngImageList;


    procedure AddImage( AImageList : TSakpungPngImageList; AImageID : string; AImageFileName : string );
  public
    { Public declarations }
    constructor Create( AOwner : TComponent ); override;
    destructor Destroy; override;

    procedure LoadImageResource; // button에 사용할 image 적제

    // imagebutton2에 image를 연결 한다.
    procedure SetButtonImage( AButton : TSakpungImageButton2; AButtonType : TActiveImageButtonType; AImageID : string );

    property ButtonImageList : TSakpungPngImageList read FButtonImageList; // 23x12    -> 18
    property ExpandCollapseButtonImageList : TSakpungPngImageList read FECButtonImageList; // 32x18
    property WindowButtonImageList : TSakpungPngImageList read FWindowButtonImageList; // 20x20

    property ButtonImageList24x24 : TSakpungPngImageList read FButtonImageList24x24; // 24x24
    property ButtonImageList28x18 : TSakpungPngImageList read FButtonImageList28x18; // 28x24
    property ButtonImageList80x26 : TSakpungPngImageList read FButtonImageList80x26; // 80x26
  end;

var
  ImageResourceDM: TImageResourceDM;

const
  BTN_Img_확정      = '확정';
  BTN_Img_진료완료  = '진료완료';
  BTN_Img_내원요청  = '내원요청';
  BTN_Img_내원확인  = '내원확인';

  BTN_Img_접기  = '접기';
  BTN_Img_펴기  = '펴기';

  BTN_Img_Win_Close   = '종료';
  BTN_Img_Win_Min     = '최소화';
  BTN_Img_Win_Max     = '최대화';
  BTN_Img_Win_normal  = '복구';

  BTN_Img_Filter_Off  = 'filter';
  BTN_Img_Filter_On   = 'filteron';

  BTN_Img_Home_Off      = 'Home';
  BTN_Img_Home_On       = 'Homeon';

  BTN_Img_일_Off      = '일';
  BTN_Img_일_On       = '일on';
  BTN_Img_월_Off      = '월';
  BTN_Img_월_On       = '월on';

  BTN_Img_Detail_접수확정   = '접수확정d';
  BTN_Img_Detail_예약확정   = '예약확정d';
  BTN_Img_Detail_내원요청   = '내원요청d';
  BTN_Img_Detail_내원확인   = '내원확인d';
  BTN_Img_Detail_진료완료   = '진료완료d';
  BTN_Img_Detail_접수거부   = '접수거부d';
  BTN_Img_Detail_접수취소   = '접수취소d';
  BTN_Img_Detail_예약거부   = '예약거부d';
  BTN_Img_Detail_예약취소   = '예약취소d';

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TImageResourceDM }

procedure TImageResourceDM.AddImage( AImageList : TSakpungPngImageList; AImageID, AImageFileName: string);
  procedure addImg( AID : string; AFN : string );
  begin
    if FileExists( AFN ) then
      AImageList.AddPngFile( AID, AFN );
  end;

begin
  addImg( AImageID + '_disable', FRootFolder + AImageFileName + '_disable.png' );
  addImg( AImageID + '_over', FRootFolder + AImageFileName + '_over.png' );
  addImg( AImageID + '_normal', FRootFolder + AImageFileName + '_normal.png' );
  addImg( AImageID + '_down', FRootFolder + AImageFileName + '_down.png' );
end;

constructor TImageResourceDM.Create(AOwner: TComponent);
begin
  inherited;
  FRootFolder := ExtractFilePath( ParamStr( 0 ) ) + 'img\';

  FButtonImageList := TSakpungPngImageList.Create( nil );
  FECButtonImageList := TSakpungPngImageList.Create( nil );
  FWindowButtonImageList := TSakpungPngImageList.Create( nil );
  FButtonImageList24x24 := TSakpungPngImageList.Create( nil );
  FButtonImageList28x18 := TSakpungPngImageList.Create( nil );
  FButtonImageList80x26 := TSakpungPngImageList.Create( nil );

  LoadImageResource;
end;

destructor TImageResourceDM.Destroy;
begin
  FreeAndNil( FButtonImageList );
  FreeAndNil( FECButtonImageList );
  FreeAndNil( FWindowButtonImageList );
  FreeAndNil( FButtonImageList24x24 );
  FreeAndNil( FButtonImageList28x18 );
  FreeAndNil( FButtonImageList80x26 );

  inherited;
end;

procedure TImageResourceDM.LoadImageResource;
begin
  AddImage(FButtonImageList, BTN_Img_확정, 'decide');  // 확정
  AddImage(FButtonImageList, BTN_Img_진료완료, 'treatment_finish');  // 진료 완료
  AddImage(FButtonImageList, BTN_Img_내원요청, 'visit_request');   // 내원요청
  AddImage(FButtonImageList, BTN_Img_내원확인, 'visit_comfirm'); // 내원확인

  AddImage(FECButtonImageList, BTN_Img_접기, 'collapse');  // 접기
  AddImage(FECButtonImageList, BTN_Img_펴기, 'expand');  // 펴기

  AddImage(FWindowButtonImageList, BTN_Img_Win_Close, 'close');
  AddImage(FWindowButtonImageList, BTN_Img_Win_Min, 'min');
  AddImage(FWindowButtonImageList, BTN_Img_Win_Max, 'max');
  AddImage(FWindowButtonImageList, BTN_Img_Win_normal, 'normal');

  AddImage(FButtonImageList24x24, BTN_Img_Filter_Off, 'filter');
  AddImage(FButtonImageList24x24, BTN_Img_Filter_On, 'filteron');


  AddImage(FButtonImageList28x18, BTN_Img_Home_Off, 'Home');
  AddImage(FButtonImageList28x18, BTN_Img_Home_On, 'Homeon');
  AddImage(FButtonImageList28x18, BTN_Img_일_Off, 'day');  // 일
  AddImage(FButtonImageList28x18, BTN_Img_일_On, 'day_on');  // 일 on
  AddImage(FButtonImageList28x18, BTN_Img_월_Off, 'month');  // 월
  AddImage(FButtonImageList28x18, BTN_Img_월_On, 'month_on'); // 월 on

  AddImage(FButtonImageList80x26, BTN_Img_Detail_접수거부, 'reception_cancel_detail'); // 접수거부d
  AddImage(FButtonImageList80x26, BTN_Img_Detail_접수확정, 'reception_decide_detail');  // 접수확정d
  AddImage(FButtonImageList80x26, BTN_Img_Detail_내원요청, 'visit_request_detail'); // 내원요청d
  AddImage(FButtonImageList80x26, BTN_Img_Detail_내원확인, 'visit_comfirm_detail');  //내원확인d
  AddImage(FButtonImageList80x26, BTN_Img_Detail_예약확정, 'reservation_decide_detail');  // 예약확정d
  AddImage(FButtonImageList80x26, BTN_Img_Detail_진료완료, 'treatment_finish_detail'); // 진료완료d
  AddImage(FButtonImageList80x26, BTN_Img_Detail_예약거부, 'reservation_reject_detail');  // 예약거부d
  AddImage(FButtonImageList80x26, BTN_Img_Detail_예약취소, 'reservation_cancel_detail');  // 예약취소d
  AddImage(FButtonImageList80x26, BTN_Img_Detail_접수취소, 'reception_cancel_detail');  // 접수취소d
end;

procedure TImageResourceDM.SetButtonImage(AButton: TSakpungImageButton2;
  AButtonType: TActiveImageButtonType; AImageID: string);
var
  btnimg : TSakpungButtonImage;
begin
  if AButtonType = aibtButton1 then
    btnimg := AButton.Button1
  else
    btnimg := AButton.Button2;

  btnimg.NomalImageID := AImageID + '_normal';
  btnimg.OverImageID := AImageID + '_over';
  btnimg.DownImageID := AImageID + '_down';
  btnimg.DisableImageID := AImageID + '_disable';
end;

end.
