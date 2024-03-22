program GDReceptionReservation;

uses
  {$IFDEF EurekaLog}
  EMemLeaks,
  EResLeaks,
  EDialogWinAPIMSClassic,
  EDialogWinAPIEurekaLogDetailed,
  EDialogWinAPIStepsToReproduce,
  EDebugExports,
  EDebugJCL,
  EFixSafeCallException,
  EMapWin32,
  EAppVCL,
  ExceptionLog7,
  {$ENDIF EurekaLog}
  windows,
  System.SysUtils,
  Vcl.Forms,
  GDReceptionReservationUnit in 'GDReceptionReservationUnit.pas' {GDReceptionReservationForm},
  LoginUnit in 'LoginUnit.pas' {LoginForm},
  RRObserverUnit in 'Common\RRObserverUnit.pas',
  GDDateTime in '..\Common\GDDateTime.pas',
  GDJson in '..\Common\GDJson.pas',
  BridgeDLL in 'Common\Bridge\BridgeDLL.pas',
  BridgeCommUnit in 'Common\Comm\BridgeCommUnit.pas',
  GDBridge in 'Common\Bridge\GDBridge.pas',
  RRDialogs in 'Common\RRDialogs.pas',
  EventIDConst in 'Common\EventIDConst.pas',
  ReceptionReservationUnit in 'ReceptionReservationUnit.pas' {ReceptionReservationForm},
  ReceptionReservationBaseUnit in 'day\ReceptionReservationBaseUnit.pas' {ReceptionReservationBaseForm},
  GDGrid in '..\common\GDGrid.pas',
  RnRUnit in 'day\RnRUnit.pas' {RnRForm},
  ReservationUnit in 'day\ReservationUnit.pas' {ReservationForm},
  ReceptionUnit in 'day\ReceptionUnit.pas' {ReceptionForm},
  RnRData in 'Common\RnRData.pas',
  RnRDMUnit in 'RnRDMUnit.pas' {RnRDM: TDataModule},
  TranslucentFormUnit in 'Common\TranslucentFormUnit.pas' {TranslucentForm},
  ReservationMonthBaseUnit in 'month\ReservationMonthBaseUnit.pas' {ReservationMonthBaseForm},
  ReservationMonthUnit in 'month\ReservationMonthUnit.pas' {ReservationMonthForm},
  RREnvUnit in 'env\RREnvUnit.pas',
  SetEnv in 'env\SetEnv.pas' {SetEnvForm},
  GDLog in '..\Common\Log\GDLog.pas',
  GDThread in '..\Common\GDThread.pas',
  ReservationMonthListUnit in 'month\ReservationMonthListUnit.pas' {ReservationMonthListForm},
  ReservationRequestMonthListUnit in 'month\ReservationRequestMonthListUnit.pas' {ReservationRequestMonthListForm},
  ImageResourceDMUnit in 'Common\ImageResourceDMUnit.pas' {ImageResourceDM: TDataModule},
  RRConst in 'Common\RRConst.pas',
  RRGridDrawUnit in 'Common\grid\RRGridDrawUnit.pas',
  RoomFilter in 'Common\RoomFilter.pas' {RoomFilterForm},
  SelectCancelMSG in 'detail\SelectCancelMSG.pas' {SelectCancelMSGForm},
  RoomSelect in 'Common\RoomSelect.pas' {RoomSelectForm},
  DetailView in 'detail\DetailView.pas' {CustomRRDetailViewForm},
  SplashUnit in 'Common\SplashUnit.pas' {SplashForm},
  BridgeWrapperUnit in 'Common\Bridge\BridgeWrapperUnit.pas' {BridgeWrapperDM},
  ChatViewerCtrl in '..\GoodocHospitalManager\Control\ChatViewerCtrl.pas',
  ProcessCtrlUnit in '..\Common\ProcessCtrlUnit.pas',
  UtilsUnit in '..\Common\UtilsUnit.pas',
  RoomListMNG in 'detail\RoomListMNG.pas' {RoomListMNGForm},
  CancelMsgListMNG in 'detail\CancelMsgListMNG.pas' {CancelMsgListMNGForm},
  ReservationListBaseUnit in 'ReservationList\ReservationListBaseUnit.pas' {ReservationListBaseForm},
  ReservationListUnit in 'ReservationList\ReservationListUnit.pas' {ReservationListForm},
  ReservationRequestListUnit in 'ReservationList\ReservationRequestListUnit.pas' {ReservationRequestListForm},
  RestCallUnit in 'Rest\RestCallUnit.pas' {RestCallDM: TDataModule},
  CipherAES in '..\common\Crypt\CipherAES.pas',
  gd.GDMsgDlg_none in '..\Common\gd.GDMsgDlg_none.pas' {GDMsgDlgNone},
  AboutUnit in 'Common\AboutUnit.pas' {AboutForm},
  GDTaskSchedulerUnit in 'Common\GDTaskSchedulerUnit.pas',
  RRNoticeUnit in 'detail\RRNoticeUnit.pas' {RRNoticeForm},
  SakpungFormPositionMng in '..\comp\SakpungComp\FormCtrl\SakpungFormPositionMng.pas',
  SakpungAppVersionInfo in '..\comp\SakpungComp\util\SakpungAppVersionInfo.pas',
  TaskSchedApi in '..\comp\WinTask\units\TaskSchedApi.pas',
  WinTask in '..\comp\WinTask\units\WinTask.pas',
  WinTaskConsts in '..\comp\WinTask\units\WinTaskConsts.pas',
  OCSHookAPI in '..\Common\OCSHook\OCSHookAPI.pas',
  OCSHookLoader in '..\Common\OCSHook\OCSHookLoader.pas',
  YSRConnStrManager in 'YSRRel\YSRConnStrManager.pas',
  YSRDBDMUnit in 'YSRRel\YSRDBDMUnit.pas' {YSRDBDM: TDataModule},
  CapPaintPanel in '..\comp\SakpungComp\StdCtrls\CapPaintPanel.pas',
  SakpungEdit in '..\comp\SakpungComp\StdCtrls\SakpungEdit.pas',
  SakpungImageButton in '..\comp\SakpungComp\StdCtrls\SakpungImageButton.pas',
  SakpungPngImageList in '..\comp\SakpungComp\StdCtrls\SakpungPngImageList.pas',
  SakpungStyleButton in '..\comp\SakpungComp\StdCtrls\SakpungStyleButton.pas',
  SakpungStyleButtonColor in '..\comp\SakpungComp\StdCtrls\SakpungStyleButtonColor.pas',
  SakpungMemo in '..\comp\SakpungComp\StdCtrls\SakpungMemo.pas',
  IPROConnStrManager in 'IPRORel\IPROConnStrManager.pas',
  IPRODBDMUnit in 'IPRORel\IPRODBDMUnit.pas' {IPRODBDM: TDataModule},
  DentwebConnStrManager in 'DentwebRel\DentwebConnStrManager.pas',
  DentwebDBDMUnit in 'DentwebRel\DentwebDBDMUnit.pas' {DentwebDBDM: TDataModule},
  HanaroDBDMUnit in 'HanaroRel\HanaroDBDMUnit.pas' {HanaroDBDM: TDataModule},
  HanaroConnStrManager in 'HanaroRel\HanaroConnStrManager.pas',
  GDRnRprogress in 'day\GDRnRprogress.pas' {RnRDMUnitProgress};

{$R *.res}

procedure ForegroundWindow;
var
  findwinhandle : THandle;
  r : TRect;
begin  // 뒤에 숨어 있는 form을 앞으로 나오게 하자
  findwinhandle := FindWindow ('TGDReceptionReservationForm', nil );
  if (findwinhandle = 0) or (findwinhandle = INVALID_HANDLE_VALUE) then
    exit;

  GetWindowRect(findwinhandle, r);
  if (r.top<0) or (r.left<0) or (r.Bottom<0) or (r.Right<0) then
  begin
    ShowWindow(findwinhandle, SW_RESTORE); // ok
    //SendMessage( findwinhandle, WM_SYSCOMMAND, SC_RESTORE, 0); // ok
  end;
  SetForegroundWindow( findwinhandle );
end;


var
{$ifdef _SplashForm_}
  form : TSplashForm;
{$endif}
  Mutex : THandle;
begin
{$ifdef DEBUG}
  SetLogRootFolder( RelToAbs('', ExtractFilePath(ParamStr(0)) ) );
{$else}
  SetLogRootFolder( RelToAbs('..\Log\GDReceptionReservation', ExtractFilePath(ParamStr(0)) ) );
{$endif}
  InitGDLog;
  GetRREnv.Load;

  // debug 모드가 아닐때만 check하게 한다.
  Mutex := CreateMutex(nil, true, '굿닥 병원 예약/접수');
  if (Mutex = 0) or ( GetLastError <> 0 ) then
  begin  // 이미 mutex가 이미 존재하면 getlasterror에서 183을 반환 한다.
    //Application.MessageBox('굿닥 병원 예약/접수 이미 실행 중입니다.','경고', MB_OK);
    ForegroundWindow;

    exit;
  end;

{$ifdef _SplashForm_}
  form := TSplashForm.Create( nil );
  form.FormStyle := fsStayOnTop;
{$endif}
  try
    Application.Initialize;
    Application.MainFormOnTaskbar := True;
    Application.Title := '굿닥 병원 예약/접수';

{$ifdef _SplashForm_}
    form.Show;
    form.dispDesc( 'Resource 적제' );
{$endif}
    ImageResourceDM := TImageResourceDM.Create( Application );
{$ifdef _SplashForm_}
    form.Visible := True;
    form.dispDesc( 'Rest API 적제' );
{$endif}
    RestCallDM := TRestCallDM.Create( Application );

{$ifdef _SplashForm_}
    form.dispDesc( '자료 구조 생성' );
{$endif}
    RnRDM := TRnRDM.Create( Application );
{$ifdef _SplashForm_}
    form.dispDesc( '화면 생성' );
{$endif}
    Application.CreateForm(TGDReceptionReservationForm, GDReceptionReservationForm);
  Application.CreateForm(TBridgeWrapperDM, BridgeWrapperDM);
  Application.CreateForm(TAboutForm, AboutForm);
  Application.CreateForm(TYSRDBDM, YSRDBDM);
  Application.CreateForm(TIPRODBDM, IPRODBDM);
  Application.CreateForm(TDentwebDBDM, DentwebDBDM);
  Application.CreateForm(THanaroDBDM, HanaroDBDM);
  Application.CreateForm(TRnRDMUnitProgress, RnRDMUnitProgress);
  {$ifdef _SplashForm_}
    form.dispDesc( '프로그램 시작' );
{$endif}
  finally
{$ifdef _SplashForm_}
    form.CloseSplash;
{$endif}
  end;
  Application.Run;
end.

