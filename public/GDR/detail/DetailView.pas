unit DetailView;
(*
상태 정리

상태 -> 출력 내용
------------------------------
예약 실패 -> 환차 취소
접수 실패 -> 접수 취소

접수 요청 -> 접수 요청
예약 요청 -> 에약 요청
취소 요청 -> 취소 요청
예약 완료 -> 예약 확정
접수 완료 -> 접수 확정
내원 요청 -> 내원 확인

진료 완료 -> 진료 완료

환자 취소
  확정 전 -> 환자 취소
  확정 후 -> 환자 철회

병원 취소
  확정 전
    예약 -> 예약 거부
    접수 -> 접수 거부
  확정 후 -> 병원 취소

예약/접수 후 방문을 하지 않아서 접수 서버에서 자동으로 취소 된 경우 -> 자동 취소
*)
interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  SakpungImageButton, Vcl.Grids, SakpungStyleButton, RnRData, Vcl.AppEvnts,
  TranslucentFormUnit, SakpungMemo, Vcl.ComCtrls, RRObserverUnit,
  Vcl.Imaging.pngimage;

type
  TComboBox = class(Vcl.StdCtrls.TComboBox)
  protected
    { protected declarations }
    procedure WndProc(var Message: TMessage); override;
    procedure DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState); override;
  end;

  TClipboardMemo = class(TMemo)
    public
      procedure DefaultHandler(var Message); override;
  end;


  TStatusChangeNotify = procedure (AData: TRnRData; ANewStatus : TRnRDataStatus; var AClosed : Boolean) of object;

  TRRDetailViewClass = class of TCustomRRDetailViewForm;
{
  접수 정보 출력 기본 class
}
  TCustomRRDetailViewForm = class(TTranslucentSubForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Bottom_Panel: TPanel;
    button_panel: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    RegisterDT_Label: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    roominfo: TComboBox;
    Label20: TLabel;
    Memo_Data: TSakpungMemo;
    Bevel1: TBevel;
    close_btn: TSakpungImageButton2;
    SakpungImageButton3: TSakpungImageButton;
    SakpungImageButton4: TSakpungImageButton;
    Bevel2: TBevel;
    VisitDT_Label: TLabel;
    reg_id: TEdit;
    memocount_label: TLabel;
    Registration_number_edit: TEdit;
    Path_edit: TEdit;
    Phone_edit: TEdit;
    addr_edit: TMemo;
    Label1: TLabel;
    name_edit: TEdit;
    Label10: TLabel;
    SakpungImageButton1: TSakpungImageButton;
    SakpungImageButton2: TSakpungImageButton;
    Label11: TLabel;
    SakpungImageButton6: TSakpungImageButton;
    SakpungImageButton8: TSakpungImageButton;
    SakpungImageButton9: TSakpungImageButton;
    Button1: TButton;
    SakpungImageButton7: TSakpungImageButton;
    Label4: TLabel;
    Department_memo: TEdit;
    CopyCom: TImage;
    CopyTimer: TTimer;
    CopyCom2: TImage;
    CopyCom3: TImage;
    CopyCom4: TImage;
    procedure Bottom_PanelResize(Sender: TObject);
    procedure close_btnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SakpungImageButton3Click(Sender: TObject);
    procedure SakpungImageButton4Click(Sender: TObject);
    procedure Memo_DataChange(Sender: TObject);
    procedure SakpungImageButton1Click(Sender: TObject);
    procedure SakpungImageButton2Click(Sender: TObject);
    procedure SakpungImageButton6Click(Sender: TObject);
    procedure SakpungImageButton8Click(Sender: TObject);
    procedure SakpungImageButton9Click(Sender: TObject);
   // procedure SakpungImageButton5Click(Sender: TObject);
   // procedure OnEditReservationDateTime(Sender: TObject);
   // procedure SakpungImageButton10Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure SakpungImageButton7Click(Sender: TObject);
    procedure Panel1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CopyTimerTimer(Sender: TObject);

  private
    { Private declarations }
    FStatusChange: TStatusChangeNotify;
    FObserver : TRRObserver;

    isMemoModified : Boolean; // 메모가 변경되어 있는 check한다. true이면 memo가 변경 되었다.
    isRoomChanged : Boolean; // 진료실 정보가 변경 되었습니다.
    isStatusChanged : Boolean; // 상태가 변경되었다.
    isNameChanged : Boolean; // 이름이 변경됨
    isPhoneChanged : Boolean; // 전화 번호가 변경됨
    isReservationTimeChanged : Boolean; // 예약시간이 변경됨

    procedure ImportRoomInfo;
    procedure initButton;

    function GetDataModified: Boolean; // window button의 image를 초기화 한다.
  protected
    { protected declarations }
    FShowData : TRnRData;

    procedure CreateParams(var Params: TCreateParams); override;
    procedure DoShow; override;

    procedure doRoomInfoChange( ARoomInfo : TRoomInfo ); virtual; // 변경 버튼 클릭시 발생 한다.
    procedure doMemoSave( AMemo : string ); virtual; // 저장 버튼 클릭시 발생 한다.
    function doStatusChange( ANewStatus : TRnRDataStatus ) : Boolean; virtual;
    procedure ShowData( AData : TRnRData ); virtual; // data를 출력 한다.
    procedure updateMemoCount;
    procedure doReservationTimeChange( ATime : TDateTime ); virtual;
    procedure updateRegistrationNumber;
  public
    { Public declarations }
  public
    { Public declarations }
    constructor Create( AOwner : TComponent ); override;
    destructor Destroy; override;

    property DataModified : Boolean read GetDataModified;

    function ShowDetailData( AData : TRnRData ) : Integer; virtual;

    property OnStatusChange : TStatusChangeNotify read FStatusChange write FStatusChange;
  end;

{
  접수 요청 상태에서 처리 하는 class
}
  TDetailView_RequestForm = class(TCustomRRDetailViewForm)
  private
    { Private declarations }
    btn_접수확정 : TSakpungImageButton2;
    btn_접수거부 : TSakpungImageButton2;
    procedure click_접수확정( ASender : TObject );
    procedure click_접수거부( ASender : TObject );

    procedure initButton( AType : TRnRType );
  protected
    { protected declarations }
    procedure doRoomInfoChange( ARoomInfo : TRoomInfo ); override; // 변경 버튼 클릭시 발생 한다.
    procedure doMemoSave( AMemo : string ); override; // 저장 버튼 클릭시 발생 한다.
    procedure ShowData( AData : TRnRData ); override; // data를 출력 한다.
  public
    { Public declarations }
    constructor Create( AOwner : TComponent ); override;
    destructor Destroy; override;
  end;

{
  접수 확정 상태에서 내원요청/내원확인 처리 하는 class
}
  TDetailView_WorkForm = class(TCustomRRDetailViewForm)
  private
    { Private declarations }
    btn_내원요청 : TSakpungImageButton2;
    btn_내원확인 : TSakpungImageButton2;
    btn_접수취소 : TSakpungImageButton2;
    btn_진료완료 : TSakpungImageButton2;
    procedure click_내원요청( ASender : TObject );
    procedure click_내원확인( ASender : TObject );
    procedure click_접수취소( ASender : TObject );
    procedure click_진료완료( ASender : TObject );

    procedure initButton( AType : TRnRType );
  protected
    { protected declarations }
    procedure doRoomInfoChange( ARoomInfo : TRoomInfo ); override; // 변경 버튼 클릭시 발생 한다.
    procedure doMemoSave( AMemo : string ); override; // 저장 버튼 클릭시 발생 한다.
    procedure ShowData( AData : TRnRData ); override; // data를 출력 한다.
  public
    { Public declarations }
    constructor Create( AOwner : TComponent ); override;
    destructor Destroy; override;
  end;

{
  취소 상태에서 내용 조회하는 class
}
  TDetailView_CancelForm = class(TCustomRRDetailViewForm)
  private
    { Private declarations }
    Label_Time : TLabel;
    Label_Memo : TLabel;
    procedure initUI;
  protected
    { protected declarations }
    procedure doRoomInfoChange( ARoomInfo : TRoomInfo ); override; // 변경 버튼 클릭시 발생 한다.
    procedure doMemoSave( AMemo : string ); override; // 저장 버튼 클릭시 발생 한다.
    procedure ShowData( AData : TRnRData ); override; // data를 출력 한다.
  public
    { Public declarations }
    constructor Create( AOwner : TComponent ); override;
    destructor Destroy; override;
  end;

{
  완료 상태에서 내용 조회하는 class
}
  TDetailView_FinishForm = class(TCustomRRDetailViewForm)
  private
    { Private declarations }
  protected
    { protected declarations }
    procedure doRoomInfoChange( ARoomInfo : TRoomInfo ); override; // 변경 버튼 클릭시 발생 한다.
    procedure doMemoSave( AMemo : string ); override; // 저장 버튼 클릭시 발생 한다.
    procedure ShowData( AData : TRnRData ); override; // data를 출력 한다.
  public
    { Public declarations }
    constructor Create( AOwner : TComponent ); override;
    destructor Destroy; override;
  end;


{
  예약 확정 상태에서 내원요청/내원확인 처리 하는 class
}
  TDetailView_Reservation_WorkForm = class(TCustomRRDetailViewForm)
  private
    { Private declarations }
    btn_내원확인 : TSakpungImageButton2;
    btn_예약취소 : TSakpungImageButton2;
    procedure click_내원확인( ASender : TObject );
    procedure click_예약취소( ASender : TObject );

    procedure initButton;
  protected
    { protected declarations }
    procedure doRoomInfoChange( ARoomInfo : TRoomInfo ); override; // 변경 버튼 클릭시 발생 한다.
    procedure doMemoSave( AMemo : string ); override; // 저장 버튼 클릭시 발생 한다.
    procedure ShowData( AData : TRnRData ); override; // data를 출력 한다.
  public
    { Public declarations }
    constructor Create( AOwner : TComponent ); override;
    destructor Destroy; override;
  end;

{
  진료 대기 상태(rrsVisiteDecide) 상태에서 완료 처리 하는 class
}
  TDetailView_VisiteDecide_WorkForm = class(TCustomRRDetailViewForm)
  private
    { Private declarations }
    btn_진료완료 : TSakpungImageButton2;
    btn_취소 : TSakpungImageButton2;
    procedure click_진료완료( ASender : TObject );
    procedure click_취소( ASender : TObject );

    procedure initButton( AType : TRnRType );
  protected
    { protected declarations }
    procedure doRoomInfoChange( ARoomInfo : TRoomInfo ); override; // 변경 버튼 클릭시 발생 한다.
    procedure doMemoSave( AMemo : string ); override; // 저장 버튼 클릭시 발생 한다.
    procedure ShowData( AData : TRnRData ); override; // data를 출력 한다.
  public
    { Public declarations }
    constructor Create( AOwner : TComponent ); override;
    destructor Destroy; override;
  end;


function MakeDetailClass( AData : TRnRData ) : TCustomRRDetailViewForm;

// 상세 page에서 상태 변경 전 확인 메시지 처리, true이면 yes 버튼을 선택 했다.
function ConfirmMessage( ANewStatus: TRnRDataStatus; AOwnerHandle : THandle = 0 ) : Boolean;


implementation
uses
  ClipBrd,
  dateutils, GDLog, {RRDialogs}gd.GDMsgDlg_none,
  RnRDMUnit, ImageResourceDMUnit, SelectCancelMSG,
  BridgeCommUnit, BridgeWrapperUnit, RegularExpressions, UtilsUnit, EventIDConst, RREnvUnit,
  OCSHookLoader, OCSHookAPI; //, DetailCancelForm;

{$R *.dfm}
procedure MemoToClipboardMemo( AMemo: TMemo);
type
  PClass = ^TClass;
begin
  if Assigned(AMemo) then
    PClass(AMemo)^ := TClipboardMemo;
end;


function MakeDetailClass( AData : TRnRData ) : TCustomRRDetailViewForm;
var
  makeclass : TRRDetailViewClass;
begin
    case AData.Status of
      rrsUnknown, // 알수 없는 상태
      rrs취소요청, // Status_취소요청 = 'F01';
      rrs예약요청, // Status_예약요청 = 'S01';
      rrs접수요청: // Status_접수요청 = 'C01';
          makeclass := TDetailView_RequestForm; // 접수 요청 상태
      rrs예약완료, // Status_예약완료 = 'S03';
      rrs접수완료, // Status_접수완료 = 'C03';
      rrs접수완료_new, // 디테일용
      rrs내원요청 : // Status_내원요청 = 'C05';
        begin
          makeclass := TDetailView_WorkForm; // 내원 확인이 완료된 상태, 진료 대기 상태

          if (AData.Inflow = rriftablet) and (AData.Status = rrs접수완료) then
            makeclass := TDetailView_VisiteDecide_WorkForm;
        end;
      rrs내원확정, // Status_내원확정 = 'C06';
      rrs진료대기, // Status_진료대기 = 'C04';
      rrs진료차례: // Status_진료차례 = 'C07';
          makeclass := TDetailView_VisiteDecide_WorkForm; // 내원 확인이 완료된 상태, 진료 대기 상태
      rrs진료완료:
          makeclass := TDetailView_FinishForm; // 진료 완료 상태
    else // 취소 data
      //rrs예약실패, // Status_예약실패 = 'S02';
      //rrs접수실패, // Status_접수실패 = 'C02';
      makeclass := TDetailView_CancelForm;
    end;

  Result := makeclass.Create( nil );
end;

function ConfirmMessage( ANewStatus: TRnRDataStatus; AOwnerHandle : THandle = 0 ) : Boolean;
var
  msg : string;
begin
  Result := False;
  case ANewStatus of
    // rrsUnknown, // 알수 없는 상태
    rrs본인취소,      // Status_본인취소 = 'F02';
    rrs병원취소,      // Status_병원취소 = 'F03';
    rrs예약실패,
    rrs접수실패 : msg := '해당 환자의 접수를 취소하시겠습니까?'; // 취소
    rrs예약완료,      // Status_예약완료 = 'S03';
    rrs접수완료 : msg := '해당 환자를 접수를 확정하시겠습니까?'; // 확정
    rrs접수완료_new,
    //rrs진료대기,      // Status_진료대기 = 'C04';
    rrs내원요청 : msg := '해당 환자에게 내원요청 알림톡을 발송하시겠습니까?'; // 내원 요청
    rrs내원확정 : msg := '해당환자의 내원을 확인하시겠습니까?'; // 내원 확정
    //rrs진료차례,      // Status_진료차례 = 'C07';
    //rrs취소요청,      // Status_취소요청 = 'F01';
    // rrs자동취소,      // Status_자동취소 = 'F04';
    rrs진료완료 : msg := '해당 환자를 진료완료 처리 하시겠습니까?'; // 진료 완료
  else
    exit;
  end;

  //Result := GDMessageDlg(msg, mtConfirmation, [mbYes, mbNo], 0, AOwnerHandle ) = mrYes;

  if ANewStatus = rrs접수완료_new then
  begin
      Result := true;
  end
  else

   Result := ShowGDMsgDlg( msg, GetTransFormHandle, mtConfirmation, [mbYes, mbNo] ) = mrYes;

end;


{ TCustomRRDetailViewForm }

procedure TCustomRRDetailViewForm.Button1Click(Sender: TObject);
var
  ret : integer;
  retStr : string;
  patientdata : TREQPATIENTINFO;
  pdata : PREQPATIENTINFO;
  atmp : AnsiString;
  ocshook : TOCSHookDLLLoader;

begin
{$ifndef DEBUG}
  exit;
{$endif}

  ocshook := GetOCSHookLoader;

  FillChar(patientdata, sizeof(TREQPATIENTINFO), 0);

  if GetRREnv.IsFindPatientEnabled then
  begin
    if FShowData.isFirst then
      patientdata.unFirstVisit := 1
    else
      patientdata.unFirstVisit := 0;
  end
  else
    patientdata.unFirstVisit := 2;

  //patientdata.unID := StrToInt(FShowData.ChartReceptnResultId.Id1);
  atmp := AnsiString( FShowData.GetChartReceptnResultId );
  Move(atmp[1], patientdata.szID, Length(atmp)); // patientdata.szID := FShwoData.GetCharReceptnResultId;
  atmp := AnsiString( FShowData.PatientChartID );
  Move(atmp[1], patientdata.szCNo, Length(atmp)); // patientdata.szCNo := FShowData.PatientChartID;
  //atmp := ANsiString( FShowData.Memo );
  atmp := AnsiString( Memo_Data.Lines.Text );
  Move(atmp[1], patientdata.szMemo, Length(atmp)); // patientdata.szMemo := FShowData.Memo;
  patientdata.unSex := Cardinal(FShowData.Gender);
  atmp := AnsiString( FShowData.PatientName );
  Move(atmp[1], patientdata.szName, Length(atmp)); // patientdata.szName := FShowData.PatientName;
  atmp := AnsiString( FShowData.Addr );
  Move(atmp[1], patientdata.szAddress, Length(atmp)); // patientdata.szAddress := FShowData.Addr;

  atmp := AnsiString( FShowData.AddrDetail );
  Move(atmp[1], patientdata.szAddressDetail, Length(atmp)); // patientdata.szAddress := FShowData.AddrDetail;

  atmp := AnsiString( FShowData.Zip );
  Move(atmp[1], patientdata.szZip, Length(atmp)); // patientdata.szzip := AData.zip;

  atmp := AnsiString( FShowData.Registration_number );
  Move(atmp[1], patientdata.szSocialNum, Length(atmp)); // patientdata.szSocialNum := FShowData.Registration_number;
  atmp := AnsiString( FShowData.CellPhone );
  Move(atmp[1], patientdata.szCellPhone, Length(atmp)); // patientdata.szCellPhone := FShowData.CellPhone;
  atmp := AnsiString( FShowData.BirthDay );
  Move(atmp[1], patientdata.szBirthday, Length(atmp)); // patientdata.szBirthday := FShowData.BirthDay;
  atmp := AnsiString( FShowData.RoomInfo.RoomName );
  Move(atmp[1], patientdata.szRoom, Length(atmp)); // patientdata.szRoom := FShowData.RoomInfo.RoomName;
  pdata := @patientdata;

  AddLog( doRunLog, '승인 처리 : ' + IntToStr(patientdata.unID) );
  ret := ocshook.InsertPatient( pdata );
  AddLog( doRunLog, '승인 처리 결과 : ' + IntToStr(ret) );

  if ret = 0 then
  begin
    // 요청 성공. data lock

  end
  else
  begin
    // 요청 실패
    retStr := ocshook.GetOCSErrorMessage(ret);
    if retStr <> '' then
    begin
      ShowGDMsgDlg(retStr, GetTransFormHandle, mtInformation, [mbOK]);
    end;
  end;


end;

procedure TCustomRRDetailViewForm.close_btnClick(Sender: TObject);

var
  ret: TModalResult;
  status : TRnRDataStatus;
  AData: TRnRData;
begin
  if Label9.Caption = '진료 완료' then
  begin
    Close;
  end

  else if Label9.Caption = '접수 취소' then
  begin
    Close;
  end

  else if Label9.Caption = '접수 완료' then
  begin
    Close;
  end

  else if Label9.Caption = '(초진) 진료 완료' then
  begin
    Close;
  end

  else if Label9.Caption = '(초진) 접수 취소' then
  begin
    Close;
  end

  else if Label9.Caption = '(초진) 접수 완료' then
  begin
    Close;
  end

  else
    ret := ShowGDMsgDlg('접수를 확정한 후 닫으시겠습니까?', GetTransFormHandle, mtConfirmation, [mbYes, mbNO]);

    if ret = mrYes then
    begin
    if FShowData.DataType = rrReception then
      status := rrs접수완료_new;

    if doStatusChange( status ) then
      Close;
    end
    else if ret = mrNo then
    begin
      Close;
    end


end;





constructor TCustomRRDetailViewForm.Create(AOwner: TComponent);
begin
  inherited;

  //MemoToClipboardMemo( Department_memo );
  MemoToClipboardMemo( addr_edit );

  isMemoModified := False;
  isRoomChanged := False;
  isStatusChanged := False;
  isNameChanged := False; // 이름이 변경됨
  isPhoneChanged := False; // 전화 번호가 변경됨
  isReservationTimeChanged := False;

  FStatusChange := nil;
  FShowData := nil;

  FObserver := TRRObserver.Create( nil );

  button_panel.BorderStyle := bsNone;

  Memo_Data.TextHint := '메모를 입력해주세요';
  addr_edit.Lines.Text := '서울시 강남구 역삼로3길 13,' +  #13#10 + '4층(역삼동 케어랩스타워)';
end;

procedure TCustomRRDetailViewForm.CreateParams(var Params: TCreateParams);
begin
  inherited;
  // borderstyle := bsNone; 으로 설정 후 사용해야 한다.

  //Params.Style := Params.Style or WS_THICKFRAME;   // captiond없고, resize 되고
  Params.Style := Params.Style or WS_BORDER; // caption없고, border 있고, resize않되고
  // Params.Style := Params.Style or WS_BORDER or WS_DLGFRAME; // caption있고, system button없고, resize 않되고 , WS_CAPTION사용 한것과 같다
  //Params.Style := Params.Style or WS_BORDER or WS_THICKFRAME; // captiond없고, resize 되고
end;

destructor TCustomRRDetailViewForm.Destroy;
var
  i : Integer;
  o : TObject;
begin
  if Assigned( FShowData ) then
    FreeAndNil( FShowData );

  for i := 0 to roominfo.Items.Count -1 do
  begin
    o := roominfo.Items.Objects[ i ];
    if Assigned( o ) then
    begin
      roominfo.Items.Objects[ i ] := nil;
      FreeAndNil( o );
    end;
  end;
  inherited;
end;

procedure TCustomRRDetailViewForm.doMemoSave(AMemo: string);
var
  event_109 : TBridgeResponse_109;
begin
  event_109 := BridgeWrapperDM.ChangeMemo(FShowData, AMemo);
  try
    if event_109.Code <> Result_SuccessCode then
      ShowGDMsgDlg( event_109.MessageStr, GetTransFormHandle, mtError, [mbOK] )
    else
    begin
      FShowData.Memo := AMemo;
      isMemoModified := True;

      ShowGDMsgDlg( '메모가 저장되었습니다', GetTransFormHandle, mtInformation, [mbOK] );
    end;

    ShowData( FShowData );
  finally
    FreeAndNil( event_109 );
  end;
end;

procedure TCustomRRDetailViewForm.doRoomInfoChange(ARoomInfo : TRoomInfo);
var
  event_107 : TBridgeResponse_107;
begin
  event_107 := BridgeWrapperDM.ChangeRoom(FShowData, ARoomInfo);
  try
    if event_107.Code <> Result_SuccessCode then
      ShowGDMsgDlg( event_107.MessageStr, GetTransFormHandle, mtError, [mbOK] )
    else
    begin
      FShowData.RoomInfo.Assign(ARoomInfo);
      isRoomChanged := True;
      ShowGDMsgDlg( '진료실이 변경되었습니다', GetTransFormHandle, mtInformation, [mbOK] );
    end;

    ShowData( FShowData );
  finally
    FreeAndNil( event_107 );
  end;
end;

procedure TCustomRRDetailViewForm.DoShow;
begin
  inherited;
end;

function TCustomRRDetailViewForm.doStatusChange(ANewStatus: TRnRDataStatus) : Boolean;
begin
  Result := False;

  if Assigned( FStatusChange ) then
    FStatusChange( FShowData, ANewStatus, Result );

  if Result then //  성공이면 상태가 변경된것으로 본다.
  begin
    FShowData.Status := ANewStatus;
    if not isStatusChanged then
      isStatusChanged := True;
  end;
end;

procedure TCustomRRDetailViewForm.FormShow(Sender: TObject);
begin
  initButton;

  FormStyle := Application.MainForm.FormStyle;
end;

function TCustomRRDetailViewForm.GetDataModified: Boolean;
begin
  Result := isMemoModified or isRoomChanged or isStatusChanged or isNameChanged or isPhoneChanged or isReservationTimeChanged;
end;

procedure TCustomRRDetailViewForm.ImportRoomInfo;
var
  ri : TRoomInfoData;
begin
  roominfo.Items.Clear;
  with RnRDM do
  begin
    Room_DB.First;
    // roominfo.Items.AddObject( '-', nil ); // 2020-01-22 셀린과 내용확인, 접수/예약시 반드시 진료실 정보는 내려 온다(필수값)
    while not Room_DB.Eof do
    begin
      ri := TRoomInfoData.Create;
      ri.RoomCode := Room_DB.FieldByName( 'roomcode' ).AsString;
      ri.RoomName := Room_DB.FieldByName( 'roomname' ).AsString;
      ri.DeptCode := Room_DB.FieldByName( 'deptcode' ).AsString;
      ri.DeptName := Room_DB.FieldByName( 'deptname' ).AsString;
      ri.DoctorCode := Room_DB.FieldByName( 'doctorcode' ).AsString;
      ri.DoctorName := Room_DB.FieldByName( 'doctorname' ).AsString;

      roominfo.Items.AddObject(ri.RoomName, ri);
      Room_DB.Next;
    end;
  end;
  roominfo.ItemIndex := 0;
end;

procedure TCustomRRDetailViewForm.initButton;
begin
  close_btn.PngImageList := ImageResourceDM.WindowButtonImageList;
  ImageResourceDM.SetButtonImage(close_btn, aibtButton1, BTN_Img_Win_Close);
{$ifdef DEBUG}
  Button1.Visible := True;
  Button1.Enabled := True;
{$else}
  Button1.Visible := False;
  Button1.Enabled := False;
{$endif}

end;


procedure TCustomRRDetailViewForm.Memo_DataChange(Sender: TObject);
begin
  updateMemoCount;
end;


//예약시간 제외
//procedure TCustomRRDetailViewForm.OnEditReservationDateTime(Sender: TObject);
//begin
//  if ((reservationDate.DateTime <> FShowData.VisitDT) or
//      not string.Equals(reservationTime.Text, FormatDateTime('hh:nn', FShowData.VisitDT))) and
//      (FShowData.Status in [rrs예약요청, rrs예약완료]) then
//    SakpungImageButton5.Enabled := True
//  else
//    SakpungImageButton5.Enabled := False;
//
//end;

procedure TCustomRRDetailViewForm.Bottom_PanelResize(Sender: TObject);
begin
  button_panel.Left := ( Bottom_Panel.Width - button_panel.Width ) div 2;
end;




//예약시간 제외
//procedure TCustomRRDetailViewForm.SakpungImageButton10Click(Sender: TObject);
//var
//  msg : string;
//
//  dtype : TRnRType;
//  visitdt : TDateTime;
//  pname : string;
//  roomcode : string;
//
//  status : TConvertState4App;
//  statuscode : TRnRDataStatus;
//
//begin
//  msg := '[' + FormatDateTime('yyyy-mm-dd', reservationDate.DateTime) + '] 예약목록' + #13#10;
//
//  RnRDM.RRTableEnter;
//  try
//    with RnRDM do
//    begin
//      RR_DB.IndexName := 'visitIndex';
//
//      RR_DB.First;
//      while not RR_DB.Eof do // state가 rrsRequest인 data를 모두 출력 한다.
//      begin
//        try
//          dtype := TRnRType( RR_DB.FieldByName( 'datatype' ).AsInteger );
//          if dtype <> rrReservation then
//              Continue; // 예약이 아니면 집계 하지 않는다.
//
//          visitdt := RR_DB.FieldByName('reservedttm').AsDateTime;
//          if not CheckToday(visitdt, reservationDate.DateTime) then
//            Continue; // 지정한 날에 발생된 data가 아니다.
//
//          roomcode := RR_DB.FieldByName('roomcode').AsString;
//          if not string.Equals(roomcode, FShowData.RoomInfo.RoomCode) then
//            Continue; // 진료실이 다르면 표시하지 않음.
//
//          statuscode := TRRDataTypeConvert.DataStatus2RnRDataStatus(RR_DB.FieldByName( 'status' ).AsInteger);
//          //status := TRRDataTypeConvert.Status4App( statuscode, RR_DB.FieldByName( 'hsptlreceptndttm' ).AsDateTime );
//
//          if TRRDataTypeConvert.CheckCancelStatus( statuscode ) or TRRDataTypeConvert.checkFinishStatus( statuscode ) then
//          begin
//            Continue; // 취소/완료된 data는 집계하지 않는다.
//          end;
//
//          pname := RR_DB.FieldByName('patientname').AsString;
//
//          msg := msg + pname + ': ' + FormatDateTime('hh:nn', visitdt);
//          if statuscode = rrs예약요청 then
//            msg := msg + ' [예약요청]' + #13#10
//          else if statuscode = rrs예약완료 then
//            msg := msg + ' [예약완료]' + #13#10
//          else
//            msg := msg + ' [내원/진료]' + #13#10;
//
//
//          {if (status in [csa요청, csa요청취소]) then // 확정 관련 data만 인지 하게 한다.
//            data.incRequestCount
//          else
//            data.incDecideCount;
//            }
//
//        finally
//          RR_DB.Next;
//        end;
//      end;
//    end;
//  finally
//    RnRDM.RRTableLeave;
//  end;
//
//  ShowGDMsgDlg(msg, GetTransFormHandle, mtInformation, [mbOK] );
//end;

procedure TCustomRRDetailViewForm.SakpungImageButton1Click(Sender: TObject);
var
  event_405 : TBridgeResponse_405;
begin // 이름 변경
  if FShowData.PatientName = name_edit.Text then
    exit;

  event_405 := BridgeWrapperDM.ChangePatientName( FShowData.PatientID, FShowData.PatientName, name_edit.Text, FShowData.CellPhone, FShowData.CellPhone);
  try
    if event_405.Code = Result_SuccessCode then
    begin
      //FShowData.PatientName := event_405.newName; // V4. 405응답을 무시하고 404요청값으로 대입
      FShowData.PatientName := name_edit.Text;
      isNameChanged := True;
      ShowData( FShowData );
      ShowGDMsgDlg( '이름이 변경되었습니다', GetTransFormHandle, mtInformation, [mbOK] );
    end
    else
      ShowGDMsgDlg( event_405.MessageStr, GetTransFormHandle, mtError, [mbOK] );
  finally
    if Assigned( event_405 ) then
      FreeAndNil( event_405 );
  end;
end;

procedure TCustomRRDetailViewForm.SakpungImageButton2Click(Sender: TObject);
var
  phone : string;
  event_405 : TBridgeResponse_405;
begin // 전화 번호 변경
  phone := ConvertInputCellPhone( Phone_edit.Text );
  if FShowData.CellPhone = phone then
    begin
      exit;
    end
  else
  if (phone.Length > 11) or (phone.Length <= 9) or (phone = '') then
    begin
      ShowGDMsgDlg( '연락처가 올바르지 않습니다.', GetTransFormHandle, mtWarning, [mbOK] );
      exit;
    end;

  event_405 := BridgeWrapperDM.ChangePatientPhone( FShowData.PatientID, FShowData.PatientName, FShowData.PatientName, FShowData.CellPhone, phone);
  try
    if event_405.Code = Result_SuccessCode then
    begin
      //FShowData.CellPhone := event_405.newPhone; // V4. 405응답을 무시하고 404요청값으로 대입
      FShowData.CellPhone := phone;
      isPhoneChanged := True;
      ShowData( FShowData );
      ShowGDMsgDlg( '연락처가 변경되었습니다', GetTransFormHandle, mtInformation, [mbOK] );
    end
    else
      ShowGDMsgDlg( event_405.MessageStr, GetTransFormHandle, mtError, [mbOK] );
  finally
    if Assigned( event_405 ) then
      FreeAndNil( event_405 );
  end;
end;

procedure TCustomRRDetailViewForm.SakpungImageButton3Click(Sender: TObject);
  function CheckDuplicateReservation(ARoomCode : string) : Boolean;
  var
    dtype : TRnRType;
    visitdt : TDateTime;
    roomcode : string;

    status : TConvertState4App;
    statuscode : TRnRDataStatus;

    changedt : TDateTime;
  begin
    Result := False;

    RnRDM.RRTableEnter;
    try
      with RnRDM do
      begin
        RR_DB.IndexName := 'visitIndex';

        RR_DB.First;
        while not RR_DB.Eof do
        begin
          try
            dtype := TRnRType( RR_DB.FieldByName( 'datatype' ).AsInteger );
            if dtype <> rrReservation then
                Continue;

            visitdt := RR_DB.FieldByName('reservedttm').AsDateTime;
            roomcode := RR_DB.FieldByName( 'roomcode' ).AsString;

//            if not CheckToday(visitdt, reservationDate.DateTime) then
//              Continue; // 지정한 날에 발생된 data가 아니다.

            statuscode := TRRDataTypeConvert.DataStatus2RnRDataStatus(RR_DB.FieldByName( 'status' ).AsInteger);
            //status := TRRDataTypeConvert.Status4App( statuscode, RR_DB.FieldByName( 'hsptlreceptndttm' ).AsDateTime );

            if TRRDataTypeConvert.CheckCancelStatus( statuscode ) or TRRDataTypeConvert.checkFinishStatus( statuscode ) then
            begin
              Continue; // 취소/완료된 data는 집계하지 않는다.
            end;

//            changedt := reservationDate.DateTime;
//            reservationTime.SelectAll;
//            ReplaceTime(changedt, StrToDateTime(reservationTime.SelText));

            if SameDateTime(visitdt, changedt) and string.Equals(roomcode, ARoomCode) then
            begin
              Result := True;
              break;
            end;
          finally
            RR_DB.Next;
          end;
        end;
      end;
    finally
      RnRDM.RRTableLeave;
    end;
  end;

var
  ri : TRoomInfo;
  rd : TRoomInfoData;
begin
  if roominfo.ItemIndex < 0 then
  begin // 선택되어 있는 진료실 정보가 없다.
    ShowGDMsgDlg( '진료실이 선택되어 있지 않습니다.' + #13#10 + '진료실을 선택해 주세요!', GetTransFormHandle, mtWarning, [mbOK] );
    exit;
  end;

  rd := TRoomInfoData( roominfo.Items.Objects[ roominfo.ItemIndex ] );
  if not Assigned( rd ) then
    exit;

  ri.RoomCode := rd.RoomCode;
  ri.RoomName := rd.RoomName;
  ri.DeptCode := rd.DeptCode;
  ri.DeptName := rd.DeptName;
  ri.DoctorCode := rd.DoctorCode;
  ri.DoctorName := rd.DoctorName;

  if CheckDuplicateReservation(ri.RoomCode) then
  begin
    ShowGDMsgDlg('해당시간에는 예약건이 존재합니다.', GetTransFormHandle, mtInformation, [mbOK] );
    roominfo.ItemIndex := roominfo.Items.IndexOf(FShowData.RoomInfo.RoomName);
    exit;
  end;

  doRoomInfoChange( ri );
end;

procedure TCustomRRDetailViewForm.SakpungImageButton4Click(Sender: TObject);
begin
  doMemoSave( Memo_Data.Lines.Text );
end;


//예약시간제외
//procedure TCustomRRDetailViewForm.SakpungImageButton5Click(Sender: TObject);
//  function CheckReservationTime : Boolean;
//  var
//    inputText : string;
//  begin
//    reservationTime.SelectAll;
//    inputText := reservationTime.SelText;
//    Result := TRegEx.IsMatch(inputText, '[0-9][0-9]:[0-9][0-9]');
//  end;
//
//  function CheckReservationDate : Boolean;
//  begin
//    if reservationDate.DateTime < Today then
//      Result := False
//    else
//      Result := True;
//  end;


//예약시간 제외
//  function CheckDuplicateReservation : Boolean;
//  var
//    dtype : TRnRType;
//    visitdt : TDateTime;
//    roomcode : string;
//
//    status : TConvertState4App;
//    statuscode : TRnRDataStatus;
//
//    changedt : TDateTime;
//  begin
//    Result := False;
//
//    RnRDM.RRTableEnter;
//    try
//      with RnRDM do
//      begin
//        RR_DB.IndexName := 'visitIndex';
//
//        RR_DB.First;
//        while not RR_DB.Eof do
//        begin
//          try
//            dtype := TRnRType( RR_DB.FieldByName( 'datatype' ).AsInteger );
//            if dtype <> rrReservation then
//                Continue;
//
//            visitdt := RR_DB.FieldByName('reservedttm').AsDateTime;
//            roomcode := RR_DB.FieldByName( 'roomcode' ).AsString;
//
////            if not CheckToday(visitdt, reservationDate.DateTime) then
////              Continue; // 지정한 날에 발생된 data가 아니다.    예약시간 제외
//
//            statuscode := TRRDataTypeConvert.DataStatus2RnRDataStatus(RR_DB.FieldByName( 'status' ).AsInteger);
//            //status := TRRDataTypeConvert.Status4App( statuscode, RR_DB.FieldByName( 'hsptlreceptndttm' ).AsDateTime );
//
//            if TRRDataTypeConvert.CheckCancelStatus( statuscode ) or TRRDataTypeConvert.checkFinishStatus( statuscode ) then
//            begin
//              Continue; // 취소/완료된 data는 집계하지 않는다.
//            end;
//
//            //예약시간 제외
////            changedt := reservationDate.DateTime;
////            reservationTime.SelectAll;
////            ReplaceTime(changedt, StrToDateTime(reservationTime.SelText));
//
//            if SameDateTime(visitdt, changedt) and string.Equals(roomcode, FShowData.RoomInfo.RoomCode) then
//            begin
//              Result := True;
//              break;
//            end;
//          finally
//            RR_DB.Next;
//          end;
//        end;
//      end;
//    finally
//      RnRDM.RRTableLeave;
//    end;
//  end;

var
  time : TDateTime;

//begin
//  if not CheckReservationDate() then
//  begin
//    ShowGDMsgDlg( '잘못된 예약 날짜입니다. 오늘 이후로 입력해주세요.', GetTransFormHandle, mtInformation, [mbOK] );
//    exit;
//  end;
//
//  if not CheckReservationTime() then
//  begin
//    ShowGDMsgDlg( '잘못된 예약 시간 형식입니다. 00:00 ~ 24:00 으로 입력해주세요.', GetTransFormHandle, mtInformation, [mbOK] );
//    reservationTime.SelectAll;
//    reservationTime.SetSelText(FormatDateTime('hh:nn', FShowData.VisitDT));
//    exit;
//  end;
//
//  if CheckDuplicateReservation() then
//  begin
//    ShowGDMsgDlg('해당시간에는 예약건이 존재합니다.', GetTransFormHandle, mtInformation, [mbOK] );
//    exit;
//  end;
//
//  time := reservationDate.DateTime;
//  reservationTime.SelectAll;
//  ReplaceTime(time, StrToDateTime(reservationTime.SelText));
//
//  doReservationTimeChange(time);
//
//end;

procedure TCustomRRDetailViewForm.SakpungImageButton6Click(Sender: TObject);
var
  inputText : string;
  trimText : string;
begin
  name_edit.SelectAll;
  inputText := name_edit.SelText;
  trimText := inputText.Replace('-', '');
  name_edit.SetSelText(trimText);
  name_edit.SelectAll;
  name_edit.CopyToClipboard;
  name_edit.SetSelText(inputText);


  CopyCom.Visible := true;        //복사버튼
  CopyTimer.Enabled := True;
end;

procedure TCustomRRDetailViewForm.SakpungImageButton7Click(Sender: TObject);
var
  inputText : string;
  trimText : string;
begin
  Department_memo.SelectAll;
  inputText := Department_memo.SelText;
  trimText := inputText.Trim;
  Department_memo.SetSelText(trimText);
  Department_memo.SelectAll;
  Department_memo.CopyToClipboard;
  Department_memo.SetSelText(inputText);


  CopyCom4.Visible := true;        //복사버튼
  CopyTimer.Enabled := True;

end;

procedure TCustomRRDetailViewForm.SakpungImageButton8Click(Sender: TObject);
var
  inputText : string;
  trimText : string;
begin
  Registration_number_edit.SelectAll;
  inputText := Registration_number_edit.SelText;
  trimText := inputText.Replace('-', '');

  Registration_number_edit.SetSelText(trimText);
  Registration_number_edit.SelectAll;
  Registration_number_edit.CopyToClipboard;
  Registration_number_edit.SetSelText(inputText);

  CopyCom3.Visible := true;        //복사버튼
  CopyTimer.Enabled := True;
end;

procedure TCustomRRDetailViewForm.SakpungImageButton9Click(Sender: TObject);
var
  inputText : string;
  trimText : string;
begin
  Phone_edit.SelectAll;
  inputText := Phone_edit.SelText;
  trimText := inputText.Replace('-', '');

  Phone_edit.SetSelText(trimText);
  Phone_edit.SelectAll;
  Phone_edit.CopyToClipboard;
  Phone_edit.SetSelText(inputText);

  CopyCom2.Visible := true;        //복사버튼
  CopyTimer.Enabled := True;
end;

procedure TCustomRRDetailViewForm.ShowData(AData: TRnRData);
  function GetAge( ABirthDay : string ) : string;
  var
    age : Integer;
    b : TDate;
    strd : string;
  begin
    Result := '';
    if ABirthDay = '' then exit;
    strd := DisplayBirthDay( ABirthDay );
    b := StrToDateDef(strd, 0);
    if b = 0 then exit; // 날자로 환산되지 않는다.

    age := Trunc(today) - Trunc( b );
    age := age div 365;
    Result := Format('만 %d세', [age]);
  end;
begin
  // 방문 일자 출력 여부, 예약 data만 출력을 한다.
  //VisitDT_Label.Visible := AData.DataType = rrReservation;
//  reservationDate.Enabled := AData.DataType = rrReservation;
//  reservationTime.Enabled := AData.DataType = rrReservation;
//  SakpungImageButton5.Enabled := False;
//  SakpungImageButton10.Enabled := AData.DataType = rrReservation;

  name_edit.Text := AData.PatientName;
  if not AData.isRegNumDefined then
    updateRegistrationNumber;
  Registration_number_edit.Text := DisplayRegistrationNumber( AData.Registration_number ); // 주민등록 번호 xxxxxxxxxxxxx => 13자리, 외국인/여권 번호???
  RegisterDT_Label.Caption := FormatDateTime('yyyy-mm-dd hh:nn',AData.RegisterDT);

  //VisitDT_Label.Caption := '예약시간 : ' + FormatDateTime('yyyy-mm-dd hh:nn',AData.VisitDT);
//  reservationDate.DateTime := AData.VisitDT;
//  reservationTime.Text := FormatDateTime('hh:nn', AData.VisitDT);

  roominfo.ItemIndex := roominfo.Items.IndexOf( AData.RoomInfo.RoomName );

  // 내원 목적
  Department_memo.Text := DisplaySymptom( AData.Symptom );
  // 내원 경로
  Path_edit.Text := AData.InBoundPath;
  //  ZipNo : string; // 우편 번호
  Phone_edit.Text := DisplayCellPhone( AData.CellPhone );
  // 주소
  if AData.Zip = '' then
  begin
    addr_edit.Lines.Text := AData.Addr + #13#10 + AData.AddrDetail;
  end
  else
  begin
    addr_edit.Lines.Text := '우편번호:' + AData.Zip + #13#10 + AData.Addr + #13#10 + AData.AddrDetail;
  end;

  Memo_Data.Lines.Text :=  AData.Memo; // 메모  DisplaySymptom( AData.Symptom) + #13#10 +

  updateMemoCount;

  // app에서 입력된 환자는 이름 변경을 못하게 한다.
  SakpungImageButton1.Enabled := (AData.Inflow <> rrifApp); // and (AData.PatientChartID <> ''); // V4 deprecated.
  //SakpungImageButton2.Enabled := (AData.PatientChartID <> '');
  SakpungImageButton2.Enabled := SakpungImageButton1.Enabled;
  name_edit.ReadOnly := not SakpungImageButton1.Enabled;
  Phone_edit.ReadOnly := not SakpungImageButton2.Enabled;

  reg_id.Visible := GDebugLogLevel.ShowUI;
  reg_id.Text := AData.ChartReceptnResultId.Id1;
end;

function TCustomRRDetailViewForm.ShowDetailData(AData: TRnRData): Integer;
begin
  FShowData := AData.Copy;
  ImportRoomInfo; // room 목록 출력

  ShowData( FShowData );

  Result := ShowModal;
  //Result := ShowCustomModal;
end;

procedure TCustomRRDetailViewForm.updateMemoCount;
var
  cnt : Integer;
  s : string;
begin
  s := Memo_Data.Lines.Text;
  cnt := Length( s );
  memocount_label.Caption := Format('%d자',[cnt]);
end;

procedure TCustomRRDetailViewForm.doReservationTimeChange( ATime : TDateTime );
var
  event_207 : TBridgeResponse_207;
begin
  FObserver.BeforeAction(OB_Event_DataRefresh_RR);
  FObserver.BeforeAction(OB_Event_DataRefresh_Reservation);
  FObserver.BeforeAction(OB_Event_DataRefresh_Month);
  FObserver.BeforeAction(OB_Event_DataRefresh_Month2);
  try
    event_207 := BridgeWrapperDM.ChangeReservationTime(FShowData, ATime);
    try
      if event_207.Code <> Result_SuccessCode then
        ShowGDMsgDlg( event_207.MessageStr, GetTransFormHandle, mtError, [mbOK] )
      else
      begin
        FShowData.VisitDT := ATime;
        // RR_DB 저장 필요?
        RnRDM.UpdateReserveDttmRR(FShowData, ATime);

        isReservationTimeChanged := True;
        ShowGDMsgDlg( '예약요청시간이 변경되었습니다.', GetTransFormHandle, mtInformation, [mbOK] );
      end;

      ShowData( FShowData );
    finally
      FreeAndNil( event_207 );
    end;
  finally
    FObserver.AfterAction(OB_Event_DataRefresh_RR);
    FObserver.AfterAction(OB_Event_DataRefresh_Reservation);
    FObserver.AfterAction(OB_Event_DataRefresh_Month);
    FObserver.AfterAction(OB_Event_DataRefresh_Month2);
  end;

end;

procedure TCustomRRDetailViewForm.updateRegistrationNumber;
var
  event_411 : TBridgeResponse_411;
begin
  event_411 := BridgeWrapperDM.GetFullRegistrationNumber(FShowData);
  try
    if event_411.Code <> Result_SuccessCode then
      ShowGDMsgDlg( event_411.MessageStr, GetTransFormHandle, mtError, [mbOK] )
    else
    begin
      FShowData.Registration_number := event_411.regNum;
      FShowData.isRegNumDefined := True;
      // RR_DB 저장하지 않는다. 환자목록 행에서는 ******로 노출

    end;
  finally
    FreeAndNil( event_411 );
  end;
end;

{ TComboBox }

procedure TComboBox.DrawItem(Index: Integer; Rect: TRect;
  State: TOwnerDrawState);
begin
  if odComboBoxEdit in State then begin // If we are drawing item in the edit part of the Combo
    if not Enabled then
      Canvas.Font.Color:= clBlack; // Disabled font colors
    Canvas.Brush.Color:= clWhite; // Get the right background color: normal, mandatory or disabled
  end;
  inherited DrawItem(Index, Rect, State);
end;

procedure TComboBox.WndProc(var Message: TMessage);
begin
  inherited;

  case Message.Msg of
    CN_CTLCOLORMSGBOX .. CN_CTLCOLORSTATIC, //48434..48440
    WM_CTLCOLORMSGBOX .. WM_CTLCOLORSTATIC:
    begin
      Color:= clWhite; // get's the current background state
      Brush.Color:= Color;
    end;
  end;
end;

{ TDetailView_RequestForm }

procedure TDetailView_RequestForm.click_접수거부(ASender: TObject);
var
  status : TRnRDataStatus;
begin
  if FShowData.DataType = rrReception then
    status := rrs접수실패
  else
    status := rrs예약실패;

  if doStatusChange( status ) then
    Close;


end;



procedure TDetailView_RequestForm.click_접수확정(ASender: TObject);
var
  status : TRnRDataStatus;
begin
  if FShowData.DataType = rrReception then
    status := rrs접수완료
  else
    status := rrs예약완료;

  if doStatusChange( status ) then
    Close;
end;

constructor TDetailView_RequestForm.Create(AOwner: TComponent);
begin
  inherited;

  btn_접수확정 := TSakpungImageButton2.Create( nil );
  btn_접수거부 := TSakpungImageButton2.Create( nil );

end;

destructor TDetailView_RequestForm.Destroy;
begin
  FreeAndNil( btn_접수확정 );
  FreeAndNil( btn_접수거부 );

  inherited;
end;


procedure TDetailView_RequestForm.doMemoSave(AMemo: string);
begin
  inherited;
end;

procedure TDetailView_RequestForm.doRoomInfoChange(ARoomInfo : TRoomInfo);
begin
  inherited;
end;

procedure TDetailView_RequestForm.initButton( AType : TRnRType );
var
  leftposition : Integer;
  btype : string;
begin
  button_panel.Width := ImageResourceDM.ButtonImageList80x26.Width * 2 + 5;
  leftposition := 0;

  btn_접수확정.Parent := button_panel;
  btn_접수확정.Top := 0;
  btn_접수확정.Left := leftposition;
  btn_접수확정.PngImageList := ImageResourceDM.ButtonImageList80x26;
  btn_접수확정.OnClick := click_접수확정;

  if AType = rrReception then
    btype := BTN_Img_Detail_접수확정
  else
    btype := BTN_Img_Detail_예약확정;

  ImageResourceDM.SetButtonImage(btn_접수확정, aibtButton1, btype);
  btn_접수확정.Visible := True;

  Inc(leftposition, btn_접수확정.Width + 5);

  btn_접수거부.Parent := button_panel;
  btn_접수거부.Top := 0;
  btn_접수거부.Left := leftposition;
  btn_접수거부.PngImageList := ImageResourceDM.ButtonImageList80x26;
//  btn_접수거부.OnClick := click_접수거부;
//  ImageResourceDM.SetButtonImage(btn_접수거부, aibtButton1, btype);


  if AType = rrReception then
    btype := BTN_Img_Detail_접수거부
  else
    btype := BTN_Img_Detail_예약거부;

  btn_접수거부.OnClick := click_접수거부;
  ImageResourceDM.SetButtonImage(btn_접수거부, aibtButton1, btype);


end;

procedure TDetailView_RequestForm.ShowData(AData: TRnRData);
var
  str : string;
begin
  inherited;
  initButton(AData.DataType);
  str := '';
  if AData.isFirst then
    str := '(초진) ';
  case AData.Status of
    rrs취소요청 : Label9.Caption := str + '취소 요청';
    rrs예약요청 : Label9.Caption := str + '예약 요청';
    rrs예약완료 : Label9.Caption := str + '예약 완료';
    rrs접수요청 : Label9.Caption := str + '접수 요청';
    rrs접수완료 : Label9.Caption := str + '접수 완료';
  end;

  if AData.Inflow = rriftablet then
   Label17.Caption := '태블릿';

  if AData.Inflow = rrifApp then
   Label17.Caption := '모바일';

end;

{ TDetailView_WorkForm }

procedure TDetailView_WorkForm.click_내원요청(ASender: TObject);
var
  status : TRnRDataStatus;
begin
  status := rrs내원요청;

  if doStatusChange( status ) then
    Close;
end;

procedure TDetailView_WorkForm.click_내원확인(ASender: TObject);
var
  status : TRnRDataStatus;
begin
  //status := rrs진료대기;
  status := rrs내원확정;

  if doStatusChange( status ) then
    Close;
end;

procedure TDetailView_WorkForm.click_접수취소(ASender: TObject);
var
  status : TRnRDataStatus;
begin
  status := rrs병원취소;

  if doStatusChange( status ) then
    Close;
end;

procedure TDetailView_WorkForm.click_진료완료(ASender: TObject);
var
  status : TRnRDataStatus;
begin
  status := rrs진료완료;

  if doStatusChange( status ) then
    Close;
end;

constructor TDetailView_WorkForm.Create(AOwner: TComponent);
begin
  inherited;

  btn_내원요청 := TSakpungImageButton2.Create( nil );
  btn_내원확인 := TSakpungImageButton2.Create( nil );
  btn_접수취소 := TSakpungImageButton2.Create( nil );
  btn_진료완료 := TSakpungImageButton2.Create( nil );
end;

destructor TDetailView_WorkForm.Destroy;
begin
  FreeAndNil( btn_내원요청 );
  FreeAndNil( btn_내원확인 );
  FreeAndNil( btn_접수취소 );
  FreeAndNil( btn_진료완료 );

  inherited;
end;

procedure TDetailView_WorkForm.doMemoSave(AMemo: string);
begin
  inherited;
end;

procedure TDetailView_WorkForm.doRoomInfoChange(ARoomInfo : TRoomInfo);
begin
  inherited;
end;

procedure TDetailView_WorkForm.initButton( AType : TRnRType );
var
  buttoncount : Integer;
  leftposition : Integer;
  btype : string;
begin
  if AType = rrReservation then
    buttoncount := 2
  else
    buttoncount := 3;

  button_panel.Width := ImageResourceDM.ButtonImageList80x26.Width * 2 + 5;
 // button_panel.Width := ImageResourceDM.ButtonImageList80x26.Width * buttoncount + 5*(buttoncount-1);
  leftposition := 0;

  if AType = rrReception then
  begin
//    btn_내원요청.Parent := button_panel;
//    btn_내원요청.Top := 0;
//    btn_내원요청.Left := leftposition;
//    btn_내원요청.PngImageList := ImageResourceDM.ButtonImageList80x26;
//    btn_내원요청.OnClick := click_내원요청;
//    ImageResourceDM.SetButtonImage(btn_내원요청, aibtButton1, BTN_Img_Detail_내원요청);
//    btn_내원요청.Visible := True;
//    Inc(leftposition, btn_내원요청.Width + 5);
      btn_진료완료.Parent := button_panel;
      btn_진료완료.Top := 0;
      btn_진료완료.Left := leftposition;
      btn_진료완료.PngImageList := ImageResourceDM.ButtonImageList80x26;
      btn_진료완료.OnClick := click_진료완료;
      ImageResourceDM.SetButtonImage(btn_진료완료, aibtButton1, BTN_Img_Detail_진료완료);
      btn_진료완료.Visible := True;
      Inc(leftposition, btn_진료완료.Width + 5);
  end;

//  btn_내원확인.Parent := button_panel;
//  btn_내원확인.Top := 0;
//  btn_내원확인.Left := leftposition;
//  btn_내원확인.PngImageList := ImageResourceDM.ButtonImageList80x26;
//  btn_내원확인.OnClick := click_내원확인;
//  ImageResourceDM.SetButtonImage(btn_내원확인, aibtButton1, BTN_Img_Detail_내원확인);
//  btn_내원확인.Visible := True;
//  Inc(leftposition, btn_내원확인.Width + 5);

  if AType = rrReservation then
    btype := BTN_Img_Detail_예약취소
  else
    btype := BTN_Img_Detail_접수취소;

  btn_접수취소.Parent := button_panel;
  btn_접수취소.Top := 0;
  btn_접수취소.Left := leftposition;
  btn_접수취소.PngImageList := ImageResourceDM.ButtonImageList80x26;
  btn_접수취소.OnClick := click_접수취소;
  ImageResourceDM.SetButtonImage(btn_접수취소, aibtButton1, btype);
  btn_접수취소.Visible := True;
end;

procedure TDetailView_WorkForm.ShowData(AData: TRnRData);
var
  str : string;
begin
  initButton( AData.DataType );

  inherited;

  str := '';
  if AData.isFirst then
    str := '(초진) ';

  case AData.Status of
  rrs예약완료 : Label9.Caption := str + '예약 확정';
  rrs접수완료 : Label9.Caption := str + '접수 완료';
  rrs내원요청 :
    begin
      Label9.Caption := str + '접수 완료';
      btn_내원요청.Enabled := False;
    end;
  end;

   if AData.Inflow = rriftablet then
   Label17.Caption := '태블릿';

  if AData.Inflow = rrifApp then
   Label17.Caption := '모바일';

end;

{ TDetailView_CancelForm }

constructor TDetailView_CancelForm.Create(AOwner: TComponent);
begin
  inherited;
  Label_Time := TLabel.Create( nil );
  Label_Memo := TLabel.Create( nil );


  initUI;
end;

destructor TDetailView_CancelForm.Destroy;
begin
  FreeAndNil( Label_Time );
  FreeAndNil( Label_Memo );

  inherited;
end;

procedure TDetailView_CancelForm.doMemoSave(AMemo: string);
begin
  inherited;
end;

procedure TDetailView_CancelForm.doRoomInfoChange(ARoomInfo : TRoomInfo);
begin
  inherited;
end;

procedure TDetailView_CancelForm.initUI;
var
  topposition : Integer;
begin
  button_panel.Visible := False;
  topposition := 15;

  Label_Time.Parent := Bottom_Panel;
  Label_Time.Top := topposition;
  Label_Time.Left := 10;
  Inc(topposition, Label_Time.Height + 5);

// 취소메시지 제거 0918
//  Label_Memo.Parent := Bottom_Panel;
//  Label_Memo.Top := topposition;
//  Label_Memo.Left := 10;
//  Label_Memo.AutoSize := False;
//  Label_Memo.Width := Bottom_Panel.Width - Label_Memo.Left - 2;
//  Label_Memo.ShowHint := False;
end;

procedure TDetailView_CancelForm.ShowData(AData: TRnRData);
var
  BeforeConfirmation : Boolean;
  R: TRect;
  str, str2, s : string;
begin
  inherited;
  str2 := '';
  if AData.isFirst then
    str2 := '(초진) ';

  BeforeConfirmation := AData.hsptlreceptndttm <> 0; // 접수/예약 확정 일시

    str := '취소';
  case AData.Status of
    rrs예약실패 : Label9.Caption := str2 + '환자 취소'; // '예약 취소';
    rrs접수실패 : Label9.Caption := str2 + '접수 취소';
    rrs병원취소 :
      begin
        if BeforeConfirmation then
        begin // 확정 후
          Label9.Caption := str2 + '병원 취소';
        end
        else
        begin // 확정 전
          if AData.DataType = rrReception then
            Label9.Caption := str2 + '접수 취소'
          else
            Label9.Caption := str2 + '예약 거부';
        end;
      end;
    rrs본인취소 :
      begin
        if BeforeConfirmation then
        begin // 확정 후
          Label9.Caption := str2 + '환자 철회';
        end
        else
        begin // 확정 전
          Label9.Caption := str2 + '환자 취소';
        end;
      end;
  else
    // Label9.Caption := '자동 취소';
    Label9.Caption := str2 + '만료';
    str := '만료'
  end;


  //수단 추가 0918
  if AData.Inflow = rriftablet then
   Label17.Caption := '태블릿';

  if AData.Inflow = rrifApp then
   Label17.Caption := '모바일';

//취소메시지 삭제0918
//  s := AData.CanceledMessage;
//  UniqueString(S);
//  R := Label_Memo.ClientRect;
//  Label_Memo.Canvas.Font := Label_Memo.Font;
//  DrawText(Label_Memo.Canvas.Handle,  PChar(S), Length(S), R, DT_END_ELLIPSIS or DT_MODIFYSTRING or DT_NOPREFIX);
//
//  Label_Memo.Caption := s;
//  if AData.CanceledMessage <> s then
//  begin
//    Label_Memo.ShowHint := True;
//    Label_Memo.Hint := AData.CanceledMessage;
//  end;

  Label_Time.Caption := str + '시각: ' + FormatDateTime('yyyy-mm-dd hh:nn:ss', AData.CancelDT);

  roominfo.Enabled := False;
  SakpungImageButton1.Enabled := False;
  SakpungImageButton2.Enabled := False;
  SakpungImageButton3.Enabled := False;
  SakpungImageButton4.Enabled := False;
  SakpungImageButton3.Visible := False;
  SakpungImageButton4.Visible := False;
  Memo_Data.ReadOnly := True;
  Memo_Data.Color := cl3DLight;


//  reservationDate.Enabled := False;
//  reservationTime.Enabled := False;
//  SakpungImageButton5.Enabled := False;
//  SakpungImageButton10.Enabled := False;
end;

{ TDetailView_FinishForm }

constructor TDetailView_FinishForm.Create(AOwner: TComponent);
begin
  inherited;

end;

destructor TDetailView_FinishForm.Destroy;
begin

  inherited;
end;

procedure TDetailView_FinishForm.doMemoSave(AMemo: string);
begin
  inherited;

end;

procedure TDetailView_FinishForm.doRoomInfoChange(ARoomInfo : TRoomInfo);
begin
  inherited;

end;

procedure TDetailView_FinishForm.ShowData(AData: TRnRData);
var
  str : string;
begin
  inherited;

  str := '';
//  if AData.isFirst then
//    str := '(초진) ';

  Label9.Caption := str + '진료 완료';

  roominfo.Enabled := False;
  SakpungImageButton1.Enabled := False;
  SakpungImageButton2.Enabled := False;
  SakpungImageButton3.Enabled := False;
  SakpungImageButton4.Enabled := False;
  SakpungImageButton3.Visible := False;
  SakpungImageButton4.Visible := False;
  Memo_Data.ReadOnly := True;
  Memo_Data.Color := cl3DLight;


  //수단추가 0918
  if AData.Inflow = rriftablet then
   Label17.Caption := '태블릿';

  if AData.Inflow = rrifApp then
   Label17.Caption := '모바일';

//  reservationDate.Enabled := False;
//  reservationTime.Enabled := False;
//  SakpungImageButton5.Enabled := False;
//  SakpungImageButton10.Enabled := False;
end;


{ TDetailView_Reservation_WorkForm }

procedure TDetailView_Reservation_WorkForm.click_내원확인(ASender: TObject);
begin
  ShowGDMsgDlg( '내원 확인 처리를 진행 해야 한다.', GetTransFormHandle, mtInformation, [mbOK] )
end;


procedure TDetailView_Reservation_WorkForm.click_예약취소(ASender: TObject);
var
  form : TSelectCancelMSGForm;
begin
  form := TSelectCancelMSGForm.Create( self );
  try
    if form.ShowModal = mrYes then
    begin
      Memo_Data.Lines.Text := form.GetSelectMsg; // test 코드
{ TODO : 선택한 접수 정보의 취소 작업 진행 }
    end;
  finally
    FreeAndNil( form );
  end;
end;

constructor TDetailView_Reservation_WorkForm.Create(AOwner: TComponent);
begin
  inherited;

  btn_내원확인 := TSakpungImageButton2.Create( nil );
  btn_예약취소 := TSakpungImageButton2.Create( nil );
  initButton;
end;

destructor TDetailView_Reservation_WorkForm.Destroy;
begin
  FreeAndNil( btn_내원확인 );
  FreeAndNil( btn_예약취소 );

  inherited;
end;

procedure TDetailView_Reservation_WorkForm.doMemoSave(AMemo: string);
begin
  inherited;
end;

procedure TDetailView_Reservation_WorkForm.doRoomInfoChange(ARoomInfo : TRoomInfo);
begin
  inherited;
end;

procedure TDetailView_Reservation_WorkForm.initButton;
var
  leftposition : Integer;
begin
  button_panel.Width := ImageResourceDM.ButtonImageList80x26.Width * 2 + 5;
  leftposition := 0;

  btn_내원확인.Parent := button_panel;
  btn_내원확인.Top := 0;
  btn_내원확인.Left := leftposition;
  btn_내원확인.PngImageList := ImageResourceDM.ButtonImageList80x26;
  btn_내원확인.OnClick := click_내원확인;
  ImageResourceDM.SetButtonImage(btn_내원확인, aibtButton1, BTN_Img_Detail_내원확인);
  btn_내원확인.Visible := True;
  Inc(leftposition, btn_내원확인.Width + 5);

  btn_예약취소.Parent := button_panel;
  btn_예약취소.Top := 0;
  btn_예약취소.Left := leftposition;
  btn_예약취소.PngImageList := ImageResourceDM.ButtonImageList80x26;
  btn_예약취소.OnClick := click_예약취소;
  ImageResourceDM.SetButtonImage(btn_예약취소, aibtButton1, BTN_Img_Detail_예약취소);
  btn_예약취소.Visible := True;
end;

procedure TDetailView_Reservation_WorkForm.ShowData(AData: TRnRData);
var
  str : string;
begin
  inherited;

  str := '';
  if AData.isFirst then
    str := '(초진) ';

  if AData.Status = rrs내원확정 then
    Label9.Caption := str + '예약 확정'
  else
  begin
    Label9.Caption := str + '내원 확인';
  end;

  //수단추가 0918
  if AData.Inflow = rriftablet then
   Label17.Caption := '태블릿';

  if AData.Inflow = rrifApp then
   Label17.Caption := '모바일';
end;

{ TDetailView_VisiteDecide_WorkForm }

procedure TDetailView_VisiteDecide_WorkForm.click_진료완료(
  ASender: TObject);
var
  status : TRnRDataStatus;
begin
  status := rrs진료완료;

  if doStatusChange( status ) then
    Close;
end;

procedure TDetailView_VisiteDecide_WorkForm.click_취소(ASender: TObject);
var
  status : TRnRDataStatus;
begin
  status := rrs병원취소;

  if doStatusChange( status ) then
    Close;
end;

constructor TDetailView_VisiteDecide_WorkForm.Create(AOwner: TComponent);
begin
  inherited;
  btn_진료완료 := TSakpungImageButton2.Create( nil );
  btn_취소 := TSakpungImageButton2.Create( nil );
end;

destructor TDetailView_VisiteDecide_WorkForm.Destroy;
begin
  FreeAndNil( btn_진료완료 );
  FreeAndNil( btn_취소 );
  inherited;
end;

procedure TDetailView_VisiteDecide_WorkForm.doMemoSave(AMemo: string);
begin
  inherited;
end;

procedure TDetailView_VisiteDecide_WorkForm.doRoomInfoChange(ARoomInfo : TRoomInfo);
begin
  inherited;
end;

procedure TDetailView_VisiteDecide_WorkForm.initButton( AType : TRnRType );
var
  leftposition : Integer;
  btype : string;
begin
  button_panel.Width := ImageResourceDM.ButtonImageList80x26.Width * 2 + 5;
  leftposition := 0;

  btn_진료완료.Parent := button_panel;
  btn_진료완료.Top := 0;
  btn_진료완료.Left := leftposition;
  btn_진료완료.PngImageList := ImageResourceDM.ButtonImageList80x26;
  btn_진료완료.OnClick := click_진료완료;
  ImageResourceDM.SetButtonImage(btn_진료완료, aibtButton1, BTN_Img_Detail_진료완료);
  btn_진료완료.Visible := True;
  Inc(leftposition, btn_진료완료.Width + 5);

  btn_취소.Parent := button_panel;
  btn_취소.Top := 0;
  btn_취소.Left := leftposition;
  btn_취소.PngImageList := ImageResourceDM.ButtonImageList80x26;
  btn_취소.OnClick := click_취소;

  if AType = rrReservation then
    btype := BTN_Img_Detail_예약취소
  else
    btype := BTN_Img_Detail_접수취소;

  ImageResourceDM.SetButtonImage(btn_취소, aibtButton1, btype);
  btn_취소.Visible := True;
end;

//접수완료 form
procedure TDetailView_VisiteDecide_WorkForm.ShowData(AData: TRnRData);
var
  str : string;
begin
  inherited;
  initButton( AData.DataType );

  str := '';
  if AData.isFirst then
    str := '(초진) ';

  Label9.Caption := str + '접수 완료';

  //수단추가 0918
  if AData.Inflow = rriftablet then
   Label17.Caption := '태블릿';

  if AData.Inflow = rrifApp then
   Label17.Caption := '모바일';
end;

{ TClipboardMemo }

procedure TClipboardMemo.DefaultHandler(var Message);
var
  str : string;
begin
(*
  case TMessage(Message).Msg of
    WM_COPY, WM_CUT:
    begin
      //메모에서 선택된 영역만큼만 복사 되야 한다. todo
      str := '';
      for i := 0 to Lines.Count -1 do
      begin
        if str <> '' then
          str := str + ' ';
        str := str + Lines.Strings[ i ];
      end;
      Clipboard.AsText := str;
    end;
    else inherited DefaultHandler(Message);
  end;  *)

  (*
    readonly가 true인 경우 ctrl+x(wm_cut는 발생 되지 않는다.
  *)
  inherited DefaultHandler(Message);
  case TMessage(Message).Msg of
    WM_COPY, WM_CUT:
    begin
      str := Clipboard.AsText;
      str := StringReplace(str, #13#10, ' ', [rfReplaceAll]);
      Clipboard.AsText := str;
    end;
  end;
end;


procedure TCustomRRDetailViewForm.Panel1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
const
  SC_DragMove = $F012;  { a magic number }
begin
  ReleaseCapture;
  self.perform(WM_SysCommand, SC_DragMove, 0);
end;


procedure TCustomRRDetailViewForm.CopyTimerTimer(Sender: TObject);
begin
 CopyTimer.Interval := 1000;
 CopyCom.Visible := false;
 CopyCom2.Visible := false;
 CopyCom3.Visible := false;
 CopyCom4.Visible := false;
end;


end.


//TDetailView_RequestForm 접수요청
//TDetailView_WorkForm 접수완료
//TDetailView_CancelForm 접수취소
//TDetailView_FinishForm 진료완료
