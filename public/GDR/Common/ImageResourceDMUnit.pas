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

    procedure LoadImageResource; // button�� ����� image ����

    // imagebutton2�� image�� ���� �Ѵ�.
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
  BTN_Img_Ȯ��      = 'Ȯ��';
  BTN_Img_����Ϸ�  = '����Ϸ�';
  BTN_Img_������û  = '������û';
  BTN_Img_����Ȯ��  = '����Ȯ��';

  BTN_Img_����  = '����';
  BTN_Img_���  = '���';

  BTN_Img_Win_Close   = '����';
  BTN_Img_Win_Min     = '�ּ�ȭ';
  BTN_Img_Win_Max     = '�ִ�ȭ';
  BTN_Img_Win_normal  = '����';

  BTN_Img_Filter_Off  = 'filter';
  BTN_Img_Filter_On   = 'filteron';

  BTN_Img_Home_Off      = 'Home';
  BTN_Img_Home_On       = 'Homeon';

  BTN_Img_��_Off      = '��';
  BTN_Img_��_On       = '��on';
  BTN_Img_��_Off      = '��';
  BTN_Img_��_On       = '��on';

  BTN_Img_Detail_����Ȯ��   = '����Ȯ��d';
  BTN_Img_Detail_����Ȯ��   = '����Ȯ��d';
  BTN_Img_Detail_������û   = '������ûd';
  BTN_Img_Detail_����Ȯ��   = '����Ȯ��d';
  BTN_Img_Detail_����Ϸ�   = '����Ϸ�d';
  BTN_Img_Detail_�����ź�   = '�����ź�d';
  BTN_Img_Detail_�������   = '�������d';
  BTN_Img_Detail_����ź�   = '����ź�d';
  BTN_Img_Detail_�������   = '�������d';

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
  AddImage(FButtonImageList, BTN_Img_Ȯ��, 'decide');  // Ȯ��
  AddImage(FButtonImageList, BTN_Img_����Ϸ�, 'treatment_finish');  // ���� �Ϸ�
  AddImage(FButtonImageList, BTN_Img_������û, 'visit_request');   // ������û
  AddImage(FButtonImageList, BTN_Img_����Ȯ��, 'visit_comfirm'); // ����Ȯ��

  AddImage(FECButtonImageList, BTN_Img_����, 'collapse');  // ����
  AddImage(FECButtonImageList, BTN_Img_���, 'expand');  // ���

  AddImage(FWindowButtonImageList, BTN_Img_Win_Close, 'close');
  AddImage(FWindowButtonImageList, BTN_Img_Win_Min, 'min');
  AddImage(FWindowButtonImageList, BTN_Img_Win_Max, 'max');
  AddImage(FWindowButtonImageList, BTN_Img_Win_normal, 'normal');

  AddImage(FButtonImageList24x24, BTN_Img_Filter_Off, 'filter');
  AddImage(FButtonImageList24x24, BTN_Img_Filter_On, 'filteron');


  AddImage(FButtonImageList28x18, BTN_Img_Home_Off, 'Home');
  AddImage(FButtonImageList28x18, BTN_Img_Home_On, 'Homeon');
  AddImage(FButtonImageList28x18, BTN_Img_��_Off, 'day');  // ��
  AddImage(FButtonImageList28x18, BTN_Img_��_On, 'day_on');  // �� on
  AddImage(FButtonImageList28x18, BTN_Img_��_Off, 'month');  // ��
  AddImage(FButtonImageList28x18, BTN_Img_��_On, 'month_on'); // �� on

  AddImage(FButtonImageList80x26, BTN_Img_Detail_�����ź�, 'reception_cancel_detail'); // �����ź�d
  AddImage(FButtonImageList80x26, BTN_Img_Detail_����Ȯ��, 'reception_decide_detail');  // ����Ȯ��d
  AddImage(FButtonImageList80x26, BTN_Img_Detail_������û, 'visit_request_detail'); // ������ûd
  AddImage(FButtonImageList80x26, BTN_Img_Detail_����Ȯ��, 'visit_comfirm_detail');  //����Ȯ��d
  AddImage(FButtonImageList80x26, BTN_Img_Detail_����Ȯ��, 'reservation_decide_detail');  // ����Ȯ��d
  AddImage(FButtonImageList80x26, BTN_Img_Detail_����Ϸ�, 'treatment_finish_detail'); // ����Ϸ�d
  AddImage(FButtonImageList80x26, BTN_Img_Detail_����ź�, 'reservation_reject_detail');  // ����ź�d
  AddImage(FButtonImageList80x26, BTN_Img_Detail_�������, 'reservation_cancel_detail');  // �������d
  AddImage(FButtonImageList80x26, BTN_Img_Detail_�������, 'reception_cancel_detail');  // �������d
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
