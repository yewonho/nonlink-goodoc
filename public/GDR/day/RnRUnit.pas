unit RnRUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Grids,
  RRObserverUnit, GDGrid, Vcl.StdCtrls, RnRData, SakpungImageButton,
  RRGridDrawUnit, Data.DB;

type
  TDispData = class( TRnRData )
  private
    { Private declarations }
  public
    { Public declarations }
    Button_확정 : TSakpungImageButton2;
  public
    { Public declarations }
    constructor Create; override;
    destructor Destroy; override;
  end;

  TCheckBox = class( Vcl.StdCtrls.TCheckBox )
  public
  published
    { published declarations }
    property ClicksDisabled;
  end;

  TRnRForm = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    listgrid: TStringGrid;
    Panel3: TPanel;
    Panel4: TPanel;
    all_check: TCheckBox;
    reception_check: TCheckBox;
    reservation_check: TCheckBox;
    Label1: TLabel;
    cancel_check: TCheckBox;
    ec_btn: TSakpungImageButton2;
    BalloonHint1: TBalloonHint;
    filter_btn: TSakpungImageButton2;
    SakpungImageButton1: TSakpungImageButton;
    DataSource1: TDataSource;
    Label2: TLabel;
    procedure listgridTopLeftChanged(Sender: TObject);
    procedure listgridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure listgridFixedCellClick(Sender: TObject; ACol, ARow: Integer);
    procedure listgridDblClick(Sender: TObject);
    procedure all_checkClick(Sender: TObject);
    procedure ec_btnClick(Sender: TObject);
    procedure listgridMouseLeave(Sender: TObject);
    procedure listgridMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure filter_btnClick(Sender: TObject);
    procedure SakpungImageButton1Click(Sender: TObject);
    procedure listgridMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure listgridMouseActivate(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y, HitTest: Integer;
      var MouseActivate: TMouseActivate);
    function GetHorizontalScrollBarPosition(grid: TStringGrid): Integer;
    procedure RnRhookCheck;
    procedure RnRhookCheck_all;

  private
    { Private declarations }
    FSortType : Integer;
    Foldrow4Hint : Integer;
    FRoomFilter : string;
    oldList, newList : TStringList;
    FDrawGrid : TRRGridListDrawCell;

    FLastMouseUPGridRow, FLastMouseUPGridCol : Integer;
    FLastMouseDownRow : Integer; // grid에서 mousedown한 row의 위치를 관리 한다.

    FButtonEnabled : Boolean;

    LastScrollPos : Integer;

    procedure SetGridUI;  // grid의 초기 UI를 설정 한다.
    function FindObject4Grid( AObj : TObject; var ARow, ATag : Integer ) : TDispData;  // aobj에 해당하는 row를 grid에서 찾아 관련 data를 반환 한다.
    procedure RefreshData; // list에 data를 출력 한다.  주기적으로 출력 한다.
    procedure NotifyEvent; // 예약/접수 미확정 data notify
    function CheckFilterData : Boolean; // filter에 적절 한지 check한다. true이면 출력 대상이다.
    procedure ClearGrid;
    // grid에 출력되어 있는 모든 button들의 visible값을 지정된 값으로 설정 한다.
    procedure VisibleGridButton( AVisible : Boolean = False );

    procedure ButtonClickEvent( ASender : TObject ); // 확정 button click시 발생하는 event
    procedure ButtonClickEventThread( ASender : TObject ); // 확정 button click시 발생하는 event

    // 상세 조회상태에서 상태 변경 event 발생시 처리
    procedure StatusChangeNotify(AData: TRnRData; ANewStatus : TRnRDataStatus; var AClosed : Boolean);

    procedure InsertPatientToOCS(AData: TRnRData);



   // function GetHorizontalScrollBarPosition(grid: TStringGrid): Integer;




  private
    { Private declarations }
    FObserver : TRRObserver;
    procedure BeforeEventNotify( AEventID : Cardinal; AData : TObserverData );
    procedure AfterEventNotify( AEventID : Cardinal; AData : TObserverData );
  public
    { Public declarations }
    constructor Create( AOwner : TComponent ); override;
    destructor Destroy; override;

    procedure ShowPanel( AParentControl : TWinControl );
  end;

function GetRnRForm : TRnRForm;
procedure FreeRnRForm;

implementation
uses
  math, GDLog, RREnvUnit, BridgeCommUnit,
  UtilsUnit, RRDialogs, gd.GDMsgDlg_none,
  EventIDConst, RRConst,
  BridgeWrapperUnit,
  ImageResourceDMUnit, RnRDMUnit, RoomFilter,
  RoomSelect, DetailView, SelectCancelMSG,
  TranslucentFormUnit, RRNoticeUnit,
  OCSHookAPI, OCSHookLoader, GDRnRprogress;

var
  GRnRForm: TRnRForm;


{$R *.dfm}

function GetRnRForm : TRnRForm;
begin
  if not Assigned( GRnRForm ) then
    GRnRForm := TRnRForm.Create( nil );
  Result := GRnRForm;
end;

procedure FreeRnRForm;
begin
  if Assigned( GRnRForm ) then
  begin
    GRnRForm.ShowPanel( nil );
    FreeAndNil( GRnRForm );
  end;
end;

{ TReservationForm }

procedure TRnRForm.AfterEventNotify(AEventID: Cardinal; AData: TObserverData);
begin
  case AEventID of
    OB_Event_DataRefresh,
    OB_Event_DataRefresh_RR,
    OB_Event_DataRefresh_Reception :
      TThread.Synchronize(TThread.CurrentThread, procedure ()
      begin
        RefreshData; // grid의 list를 갱신 한다
      end);
    // 굿닥: 미확정 내용 알림 팝업 삭제 요청
    // OB_Event_DataRefresh_Notify : NotifyEvent;
    OB_Event_RoomInfo_Change : filter_btn.Visible := RnRDM.RoomFilterButtonVisible;
    OB_Event_Hook_Check : RnRhookCheck;
    OB_Event_Hook_Check_all : RnRhookCheck_all;
  end;
end;


procedure TRnRForm.RnRhookCheck;
  var
  ret : Integer;
  retStr : string;
  ocshook : TOCSHookDLLLoader;
  env : TRREnv;
begin
    env := GetRREnv;
    ocshook := GetOCSHookLoader;

      if not ocshook.isOCSHookDLLLoad then
      begin
        ocshook.OCSType := TOCSType( env.HookOCSType );

        ocshook.Load;
        ocshook.Init;
      end;

          if (ocshook.OCSType = TOCSType.None) or (ocshook.OCSType = TOCSType.IPro) or (ocshook.OCSType = TOCSType.Dentweb) then
            begin
              exit;
            end
          else
            begin
             ret := ocshook.Check;
             retStr := ocshook.GetOCSErrorMessage(ret);
            if retStr <> '' then
             begin
                //MessageDlg(retStr, mtInformation, [mbOK], 0, mbOK);
                ShowGDMsgDlg(retStr , GetTransFormHandle, mtInformation, [mbOK] )
             end;
          end;

          if ret = 1109 then     //후킹 연결 실패
            begin
              Label2.Font.Color := clRed;
              Label2.Caption := '후킹 연결 실패! 차트 및 굿닥을 확인 해주세요';
            end
          else if ret = 1111 then   // 타겟프로세스 없음
            begin
              Label2.Font.Color := clRed;
              Label2.Caption := '후킹 연결 실패! 차트 및 굿닥을 확인 해주세요';
            end
          else if ret = 0 then  // 성공
            begin
             Label2.Caption := '';
            end;

end;


procedure TRnRForm.RnRhookCheck_all;
  var
  ret : Integer;
  retStr : string;
  ocshook : TOCSHookDLLLoader;
  env : TRREnv;
begin
    env := GetRREnv;
    ocshook := GetOCSHookLoader;

      if not ocshook.isOCSHookDLLLoad then
      begin
        ocshook.OCSType := TOCSType( env.HookOCSType );

        ocshook.Load;
        ocshook.Init;
      end;

          if (ocshook.OCSType = TOCSType.None) then
            begin
              exit;
            end
          else
            begin
             ret := ocshook.Check;
             retStr := ocshook.GetOCSErrorMessage(ret);
            if retStr <> '' then
             begin
                //MessageDlg(retStr, mtInformation, [mbOK], 0, mbOK);
                ShowGDMsgDlg(retStr , GetTransFormHandle, mtInformation, [mbOK] )
             end;
          end;

          if ret = 1109 then     //후킹 연결 실패
            begin
              Label2.Font.Color := clRed;
              Label2.Caption := '후킹 연결 실패! 차트 및 굿닥을 확인 해주세요';
            end
          else if ret = 1111 then   // 타겟프로세스 없음
            begin
              Label2.Font.Color := clRed;
              Label2.Caption := '후킹 연결 실패! 차트 및 굿닥을 확인 해주세요';
            end
          else if ret = 0 then  // 성공
            begin
             Label2.Caption := '';
            end;

end;


procedure TRnRForm.all_checkClick(Sender: TObject);
begin
  FObserver.BeforeAction(OB_Event_DataRefresh_RR);
  try
    all_check.ClicksDisabled := true;
    reservation_check.ClicksDisabled := true;  // data 수정시 click event를 발생시키지 않게 한다
    reception_check.ClicksDisabled := true;
    cancel_check.ClicksDisabled := true;
    try
      if Sender = all_check then
      begin
        reservation_check.Checked := all_check.Checked;
        reception_check.Checked := all_check.Checked;
        cancel_check.Checked := all_check.Checked;
      end
      else
      begin // 예약/접수/취소 클릭
        all_check.Checked := reservation_check.Checked and reception_check.Checked and cancel_check.Checked;
      end;
    finally
      reservation_check.ClicksDisabled := False;
      reception_check.ClicksDisabled := False;
      cancel_check.ClicksDisabled := False;
      all_check.ClicksDisabled := False;
    end;
  finally
    FObserver.AfterAction(OB_Event_DataRefresh_RR);
  end;
end;

procedure TRnRForm.BeforeEventNotify(AEventID: Cardinal;
  AData: TObserverData);
begin
end;

procedure TRnRForm.ButtonClickEvent(ASender: TObject);
var
  t, r : Integer;
  status : TRnRDataStatus;
  RoomInfo : TRoomInfo;
  data : TDispData;
  copydata : TRnRData;

  event_109 : TBridgeResponse_109;
  event_411 : TBridgeREsponse_411;
begin // 확정 button click시 발생하는 event
  data := FindObject4Grid( ASender, r, t);

  if not Assigned( data ) then
    exit;

  listgrid.Row := r;

  with RnRDM do
  begin
    FObserver.BeforeAction(OB_Event_DataRefresh_RR);
    copydata := data.Copy;
    try
      if not FindRR( data ) then
        exit; // 못 찾았다.

      if data.RoomInfo.RoomCode = '' then
      begin // room이 선택되어 있지 않다. room을 선택 하게 한다.
        if RnRDM.RoomFilterButtonVisible then
        begin  // 2개 이상의 진료실 정보가 있다.
          if ShowRoomSelect( RoomInfo ) <> mrOk then
            exit; // room을 선택하지 않았다.
        end
        else
        begin  // 한개이면 room 정보를 읽어서 설정하게 한다.
          if not RnRDM.GetFirstRoomInfo( RoomInfo ) then
            exit; // room 정보가 없다., 처리 하지 않는다.
        end;
      end;

      // 주민번호가져오기
      event_411 := BridgeWrapperDM.GetFullRegistrationNumber(copydata);
      try
        if event_411.Code = Result_SuccessCode then
        begin
          copydata.Registration_number := event_411.regNum;
        end
        else
          exit;
      finally
        FreeAndNil(event_411);
      end;

      try
        if data.DataType = rrReception then
          status := rrs접수완료
        else
          status := rrs예약완료;

        if data.RoomInfo.RoomName = '' then
        begin // room이 지정되지 않는 data는 update를 할 수 있게 한다.
          UpdateRoomInfoRR(data, RoomInfo);

          data.RoomInfo.RoomCode := RoomInfo.RoomCode;
          data.RoomInfo.RoomName := RoomInfo.RoomName;
          data.RoomInfo.DeptCode := RoomInfo.DeptCode;
          data.RoomInfo.DeptName := RoomInfo.DeptName;
          data.RoomInfo.DoctorCode := RoomInfo.DoctorCode;
          data.RoomInfo.DoctorName := RoomInfo.DoctorName;
        end;

        event_109 := BridgeWrapperDM.ChangeStatus( data, status );
        try
          if event_109.Code = Result_SuccessCode then
          begin
            UpdateStatusRR(copydata, status);
            //data.Status := status;

            // chart hooking 사용 중일 경우 차트로 전송
{$IFNDEF DEBUG}
            if GetOCSHookLoader.OCSType <> TOCSType.None then
            begin
              if GetOCSHookLoader.isOCSHookDLLLoad then
                InsertPatientToOCS(copydata)
              else
                AddLog( doRunLog, format('외래차트 연결 실패. OCSType: %d', [Ord(GetOCSHookLoader.OCSType)]));
            end;
{$ELSE}
            if GetOCSHookLoader.isOCSHookDLLLoad then
              InsertPatientToOCS(copydata);
{$ENDIF}
          end
          else
            GDMessageDlg(event_109.MessageStr, mtError, [mbOK], 0, Self.Handle );
        finally
          FreeAndNil( event_109 );
        end;
      except
        on e : exception do
        begin
          AddExceptionLog('TRnRForm.ButtonClickEvent : ', e);
          GDMessageDlg(format('작업 중 Error가 발생 하였습니다'+#13#10+ '(%s,%s)',[e.Message, e.ClassName]), mtError, [mbOK], 0);
        end;
      end;
    finally
      FreeAndNil( copydata );
      FObserver.AfterAction(OB_Event_DataRefresh_RR);
    end;
  end;
end;

procedure TRnRForm.ButtonClickEventThread(ASender: TObject);
var OtherForm: TRnRDMUnitProgress; // 다른 폼의 인스턴스 선언
  t, r : Integer;
  CheckPhone : string;
  CheckPhonelength : Integer;
  data : TDispData;
begin
  if RnRDM.IsTaskRunning then
    exit;

  data := FindObject4Grid( ASender, r, t);
  CheckPhone := data.CellPhone;
  CheckPhonelength := Length(CheckPhone);

  if not FButtonEnabled then
    exit;

  if CheckPhone = '' then
    begin
      ShowGDMsgDlg( '연락처가 입력되지 않았습니다.', GetTransFormHandle, mtWarning, [mbOK] );
      exit;
    end;


  if CheckPhonelength <= 9 then
    begin
      ShowGDMsgDlg( '연락처가 9자 미만입니다.', GetTransFormHandle, mtWarning, [mbOK] );
      exit;
    end;


  if CheckPhonelength > 11 then
    begin
      ShowGDMsgDlg( '연락처가 12자 초과입니다.', GetTransFormHandle, mtWarning, [mbOK] );
      exit;
    end;

  FButtonEnabled := False;


 // TThread.CreateAnonymousThread( procedure begin ButtonClickEvent(ASender); FButtonEnabled := True end ).Start;

  //확정버튼에 프로그래스 bar 추가하는 코드
  TThread.CreateAnonymousThread(
   procedure

    begin

    TThread.Synchronize(nil,
      procedure

      begin
      if not FButtonEnabled then


        begin
        ButtonClickEvent(ASender);

          OtherForm := TRnRDMUnitProgress.Create(nil); // 프로그래스  인스턴스 생성
          try
            // 폼에 대한 설정 및 처리 작업 수행
            OtherForm.ShowModal; // 프로그래스  폼을 모달로 표시
          finally
            OtherForm.Free; // 프로그래스  인스턴스 해제
          end;
          end;

        Sleep(1200);

        FButtonEnabled := True;
      end
      );
    end
    ).Start;
end;

function TRnRForm.CheckFilterData: Boolean;
var
  statuscode : TRnRDataStatus;
  statusfilter : set of TRnRDataStatus;
  a : string;
begin
  Result := True;
  with RnRDM do
  begin
    if FRoomFilter <> ''  then
    begin
      a := RR_DB.FieldByName( 'roomcode' ).AsString;
      if a <> '' then
        Result := CompareText( FRoomFilter, a) = 0;
    end;
  end;

  if (not Result) or (all_check.Checked or (reception_check.Checked and reservation_check.Checked and cancel_check.Checked)) then
  begin  // 전체 data
    exit;
  end;

  with RnRDM do
  begin
    statusfilter := [];
    statuscode := TRRDataTypeConvert.DataStatus2RnRDataStatus( RR_DB.FieldByName('status').AsInteger );

    if reception_check.Checked then
    begin
      Include(statusfilter, rrsUnknown);
      Include(statusfilter, rrs접수요청);
    end;

    if reservation_check.Checked then
    begin
      Include(statusfilter, rrs예약요청);
    end;

    if cancel_check.Checked then
    begin
      Include(statusfilter, rrs접수실패);
      Include(statusfilter, rrs예약실패);

      if RR_DB.FieldByName( 'hsptlreceptndttm' ).AsDateTime = 0 then
      begin
        Include(statusfilter, rrs본인취소);
        Include(statusfilter, rrs병원취소);
      end;
    end;

    Result := statuscode in statusfilter;
  end;
end;

procedure TRnRForm.ClearGrid;
var
  i, j : Integer;
  o : TObject;
begin
  with listgrid do
  begin
    for i := 0 to RowCount-1 do
    begin
      for j := 0 to ColCount do
      begin
        o := Objects[j, i];
        if Assigned( o ) then
        begin
          Objects[j, i] := nil;
          FreeAndNil( o );
        end;
      end;
    end;
  end;
end;


constructor TRnRForm.Create(AOwner: TComponent);

begin
  inherited;
  Foldrow4Hint := -1;
  FRoomFilter := '';

  Constraints.MinHeight := Panel2.Height;

  FLastMouseUPGridRow := 0;
  FLastMouseUPGridCol := 0;
  FLastMouseDownRow := -1;

  FObserver := TRRObserver.Create( nil );
  FObserver.OnBeforeAction := BeforeEventNotify;
  FObserver.OnAfterAction := AfterEventNotify;

  FSortType := Sort_time_Descending;

  oldList := TStringList.Create;
  newList := TStringList.Create;

  FDrawGrid := TRRGridListDrawCell.Create;
  FDrawGrid.GridDataType := gdtRequest;
  FDrawGrid.ListGrid := listgrid;

  FButtonEnabled := True;

  GetRREnv.GridInfoList.GetGridInfo( Grid_Information_RnR_ID ).SetGridInfo( FSortType, listgrid);

end;


destructor TRnRForm.Destroy;
begin
  ec_btn.PngImageList := nil;
  ClearGrid;  // grid에 등록되어 있는 object 제거

  FreeAndNil( FDrawGrid );

  FreeAndNil( oldList );
  FreeAndNil( newList );
  FreeAndNil( FObserver );
  inherited;
end;

procedure TRnRForm.ec_btnClick(Sender: TObject);
begin
  FObserver.BeforeAction(OB_Event_ExpandCollapse_RnR);
  try
  finally
    FObserver.AfterAction(OB_Event_ExpandCollapse_RnR);
  end;
end;

function TRnRForm.FindObject4Grid(AObj: TObject; var ARow,
  ATag: Integer): TDispData;
var
  i : Integer;
  rowdata : TDispData;
begin
  Result := nil;

  for i := 1 to listgrid.RowCount -1 do
  begin
    rowdata := TDispData( listgrid.Objects[ Col_Index_Data, i ] );
    if Assigned( rowdata ) then
    begin
      if AObj = rowdata.Button_확정 then
      begin
        ARow := i;
        ATag := rowdata.Button_확정.Tag;
        Result := rowdata;
        exit;
      end;
    end;
  end;
end;

procedure TRnRForm.listgridDblClick(Sender: TObject);
var
  rowdata : TDispData;
  form : TCustomRRDetailViewForm;
begin
  if (listgrid.FixedRows <> 0) and (FLastMouseUPGridRow < listgrid.FixedRows) then
    exit;

  rowdata := TDispData( listgrid.Objects[Col_Index_Data, listgrid.Row] );
  if not Assigned(rowdata) then
    exit;

  form := MakeDetailClass( rowdata );
  FObserver.BeforeAction( OB_Event_400FireOff );
  try
    form.OnStatusChange := StatusChangeNotify;
    form.ShowDetailData( rowdata );
    if form.DataModified then
    begin
      FObserver.BeforeAction( OB_Event_DataRefresh_DataReload);
      FObserver.AfterAction( OB_Event_DataRefresh_DataReload);
    end;
  finally
    FreeAndNil( form );
    FObserver.AfterAction(OB_Event_400FireOn);
  end;
end;



function TRnRForm.GetHorizontalScrollBarPosition(grid: TStringGrid): Integer;
var
  si: TScrollInfo;
begin
  FillChar(si, SizeOf(TScrollInfo), 0);
  si.cbSize := SizeOf(TScrollInfo);
  si.fMask := SIF_POS;

  if GetScrollInfo(grid.Handle, SB_HORZ, si) then
    Result := si.nPos
  else
    Result := 0; // 오류 처리
end;



procedure TRnRForm.listgridDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  s : TStringGrid;
  rowdata : TDispData;
  workrect, r1 : TRect;
  CurrentScrollPos: Integer;
begin
  CurrentScrollPos := GetHorizontalScrollBarPosition(listgrid);

  if ARow < 1 then
    exit;
  if ACol < FDrawGrid.Col_Index_Button1 then
    exit;


  s := TStringGrid ( Sender );

  rowdata := TDispData( s.Objects[Col_Index_Data, ARow] );
  if not Assigned( rowdata ) then
    exit; // 출력 data가 없다.

  workrect := s.CellRect(FDrawGrid.Col_Index_Button1, ARow);
  r1 := s.CellRect(FDrawGrid.Col_Index_Button2, ARow);
  workrect := TRect.Union(workrect, r1);
  workrect.Right := workrect.Right -1;
  workrect.Left := workrect.Left -1;


  if rowdata.Canceled then
    begin // 취소 data
      rowdata.Button_확정.Visible := False;
      FDrawGrid.DrawCenterText(s, workrect, '-' );
    end
  else
  if CurrentScrollPos >= 30 then
    begin
    rowdata.Button_확정.Visible := False;
    //FDrawGrid.DrawCenterText(s, workrect, '-' );
    end
  else
  begin
    r1.Left := workrect.Left + ( ((workrect.Right - workrect.Left) - rowdata.Button_확정.Width) div 2);
    if workrect.Left > r1.Left then
      r1.Left := workrect.Left;
    r1.Right := r1.Left + rowdata.Button_확정.Width;

    if (workrect.Bottom - workrect.Top) > rowdata.Button_확정.Height then // cell 영역에 button 표시가 가능한 영역인지 check한다.
      r1.top := workrect.Top + ( ((workrect.Bottom - workrect.Top) - rowdata.Button_확정.Height) div 2) // 가능하면
    else
      r1.Top := workrect.Top; // 불가능하면

    r1.Bottom := r1.Top + rowdata.Button_확정.Height;

    rowdata.Button_확정.BoundsRect := r1;
    rowdata.Button_확정.Visible := True;
  end;

end;

procedure TRnRForm.listgridFixedCellClick(Sender: TObject; ACol, ARow: Integer);    //접수항목 오름차순 내림차순
begin
  if not (ACol in [FDrawGrid.Col_Index_PatientName, FDrawGrid.Col_Index_Room, FDrawGrid.Col_Index_Time]) then    //FDrawGrid.Col_Index_Time2 예약시간 제외
    exit;

  FObserver.BeforeAction( OB_Event_DataRefresh_RR );
  try

    if ACol = FDrawGrid.Col_Index_PatientName then // 이름 sort
    begin
      if FSortType = Sort_Name_Ascending then
        FSortType := Sort_Name_Descending
      else
        FSortType := Sort_Name_Ascending;
    end
    else if ACol = FDrawGrid.Col_Index_Room then // room sort
    begin
      if FSortType = Sort_Room_Ascending then
        FSortType := Sort_Room_Descending
      else
        FSortType := Sort_Room_Ascending;
    end
    else if ACol = FDrawGrid.Col_Index_Time then // 방문 시간 sort
    begin
      if FSortType = Sort_Time_Ascending then
        FSortType := Sort_time_Descending
      else
        FSortType := Sort_Time_Ascending;
    end;

  finally
    FObserver.AfterActionASync( OB_Event_DataRefresh_RR );
  end;
end;

procedure TRnRForm.listgridMouseActivate(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y, HitTest: Integer;
  var MouseActivate: TMouseActivate);
var
  tmp : Integer;
begin
  if Button = mbLeft then
  begin
    listgrid.MouseToCell( x, y, tmp, FLastMouseDownRow );
  end;
end;


procedure TRnRForm.listgridMouseLeave(Sender: TObject);
begin
  BalloonHint1.HideHint;
  Foldrow4Hint := -1;
end;


procedure TRnRForm.listgridMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  c, r : Integer;
  h : string;
  rt : TRect;
  p : TPoint;
  s : TStringGrid;
  rowdata : TDispData;
begin
  s := TStringGrid( Sender );

  listgrid.MouseToCell( x, y, c, r );

  if not (c in [FDrawGrid.Col_Index_PatientName]) then
  begin // 0,1 col cell이 아니면 출력 하지 않는다.
    BalloonHint1.HideHint;
    exit;
  end;

  if (r >= 0) and (r < s.RowCount) then
  begin
    if Foldrow4Hint = r then
      exit;

    Foldrow4Hint := r;
    rowdata := TDispData( s.Objects[Col_Index_Data, r] );

    h := FDrawGrid.makeHint( rowdata );
    if h = '' then
    begin
      Foldrow4Hint := -1;
      BalloonHint1.HideHint;
    end
    else
    begin
      rt := s.CellRect(4,r);
      p.X := rt.Left;
      p.Y := rt.Top + 10;
      p := s.ClientToScreen(p);
      BalloonHint1.Description := h;
      BalloonHint1.ShowHint( p );
      //BalloonHint1.ShowHint( S );
    end;
  end
  else
  begin
    BalloonHint1.HideHint;
    Foldrow4Hint := -1;
  end;

end;

procedure TRnRForm.listgridMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    listgrid.MouseToCell( x, y, FLastMouseUPGridCol, FLastMouseUPGridRow );
    if FLastMouseDownRow = 0 then // col이 resize되었거나 sort 상태가 변경된것으로 인지 한다.
    begin
      VisibleGridButton( False );
      listgrid.Invalidate;
      GetRREnv.GridInfoList.GetGridInfo( Grid_Information_RnR_ID ).AssignGridInfo( FSortType, listgrid);
    end;
  end;
end;

procedure TRnRForm.listgridTopLeftChanged(Sender: TObject);
begin
  BalloonHint1.HideHint;
  Foldrow4Hint := -1;

  VisibleGridButton( False );
end;

procedure TRnRForm.NotifyEvent;
// 예약/접수 미확정 data notify
var
  receptcount, reservecount : Integer;
  status : TConvertState4App;
  statuscode : TRnRDataStatus;
begin
  receptcount := 0; reservecount := 0;
  RnRDM.RRTableEnter;
  try
    with RnRDM do
    begin
      RR_DB.First;
      while not RR_DB.Eof do // state가 rrsRequest인 data를 모두 출력 한다.
      begin
        try
          // 당일 접수 접수/예약 data만 표시 해야 한다.
          if not CheckToday( RR_DB.FieldByName( 'receptiondttm' ).AsDateTime ) then
            Continue; // 당일 요청 data가 아니다.

            statuscode := TRRDataTypeConvert.DataStatus2RnRDataStatus(RR_DB.FieldByName( 'status' ).AsInteger);
            status := TRRDataTypeConvert.Status4App( statuscode, RR_DB.FieldByName( 'hsptlreceptndttm' ).AsDateTime );

            if status <> csa요청 then
              continue;
  (*
            if not (status in [csa요청, csa요청취소]) then // 요청 관련 data만 인지 하게 한다.
              Continue; // 요청상태가 아니면 처리 하지 않는다.

            if TRRDataTypeConvert.CheckCancelStatus( statuscode ) then
              continue; // 취소 data는 step 0에서 처리 한다. *)

            if TRnRType( RR_DB.FieldByName( 'datatype' ).AsInteger ) = rrReception  then
              Inc( receptcount ) // 접수 집계
            else
              Inc( reservecount );  // 예약 집계
        finally
          RR_DB.Next;
        end;
      end;
    end;
  finally
    RnRDM.RRTableLeave;
  end;

//  // 예약/접수 미처림 알림 (예약요청.접수요청 알림팝업인거같음)
//  if ( receptcount <> 0) or (reservecount <> 0) then
//    ShowRRNoticeForm( receptcount, reservecount ) // 처리 대상이 있다.
//  else
//    CloseRRNoticeForm; // 처리 대상이 없다. form을 종료 시킨다.
end;

procedure TRnRForm.RefreshData;
var
  step : Integer;
  rowindex : Integer;
  status : TConvertState4App;
  statuscode : TRnRDataStatus;
  rowdata : TDispData;
  isNewAdd : Boolean;
  selectrow : Integer;
  index : Integer;
  cnt : Integer;
begin
  selectrow := listgrid.Row;
  oldList.Assign( newList );
  newList.Clear;
  isNewAdd := False;

  cnt := 0;

  RnRDM.RRTableEnter;
  listgrid.Perform(WM_SETREDRAW, 0, 0);   // begineupdate
  try
    SetGridUI;

    with RnRDM do
    begin
      // sort상황에 따라 index값을 변경해야 한다.
      case FSortType of
        Sort_Name_Ascending   : RR_DB.IndexName := 'nameIndex'; // 환자 이름 순
        Sort_Name_Descending  : RR_DB.IndexName := 'nameIndexdesc'; // 환자 이름 역순
        Sort_Time_Ascending   : RR_DB.IndexName := 'visitIndex'; // 'receptionIndex'; // 접수 시간 순
        Sort_Room_Ascending   : RR_DB.IndexName := 'roomIndex'; // 진료실순
        Sort_Room_Descending  : RR_DB.IndexName := 'roomIndexdesc'; // 진료실 역순
      else // Sort_time_Descending  :
        RR_DB.IndexName := 'visitIndexdesc'; //'receptionIndexdesc'; // 방문 시간 역순
      end;

      rowindex := 0;
      for step := 0 to 1 do
      begin
        if step = 1 then
        begin // 취소 data를 출력해야 하는데
          if (not all_check.Checked) and ( not cancel_check.Checked) then
            break; // filter에서 취소 data를 출력하지 않게 설정 되어 있다.
        end;

        RR_DB.First;
        while not RR_DB.Eof do // state가 rrsRequest인 data를 모두 출력 한다.
        begin
          try
            // 당일 접수 접수/예약 data만 표시 해야 한다.
            if not CheckToday( RR_DB.FieldByName( 'receptiondttm' ).AsDateTime ) then
              Continue; // 당일 요청 data가 아니다.

            statuscode := TRRDataTypeConvert.DataStatus2RnRDataStatus(RR_DB.FieldByName( 'status' ).AsInteger);
            status := TRRDataTypeConvert.Status4App( statuscode, RR_DB.FieldByName( 'hsptlreceptndttm' ).AsDateTime );

            if not (status in [csa요청, csa요청취소]) then // 요청 관련 data만 인지 하게 한다.
              Continue; // 요청상태가 아니면 처리 하지 않는다.

            if step = 0 then
            begin
              if TRRDataTypeConvert.CheckCancelStatus( statuscode ) then
                continue; // 취소 data는 step 0에서 처리 한다.

              Inc( cnt ); // 완료 data는 집계에 포함 시키지 않는다.
            end
            else
            begin // step 1
              if not TRRDataTypeConvert.CheckCancelStatus( statuscode ) then
                continue // 취소 data를 출력하는데 취소항목이 아니다.
            end;

            if not CheckFilterData then // filter처리
              continue;

            rowdata := TDispData.Create;
            GetReceptionReservationData( rowdata );

            rowdata.Button_확정 := TSakpungImageButton2.Create(listgrid);
            rowdata.Button_확정.Visible := False;
            rowdata.Button_확정.Parent := listgrid;
            rowdata.Button_확정.Tag := Index_tag_확정;
            rowdata.Button_확정.PngImageList := ImageResourceDM.ButtonImageList;
            ImageResourceDM.SetButtonImage(rowdata.Button_확정, aibtButton1, BTN_Img_확정);
            //rowdata.Button_확정.OnClick := ButtonClickEvent;
            rowdata.Button_확정.OnClick := ButtonClickEventThread;

            newList.Add( rowdata.GetChartReceptnResultId );

            Inc( rowindex, 1);
            listgrid.RowCount := rowindex + 1;
            listgrid.Rows[ rowindex ].CommaText := '" "," "," "," "," "," "," "'; // 모든 내용은 drawcell에서 draw로 그린다.
            listgrid.Objects[Col_Index_Data, rowindex] := rowdata;

            if not isNewAdd then
              isNewAdd := not oldList.Find(rowdata.GetChartReceptnResultId, index);
          finally
            RR_DB.Next;
          end;
        end; // while 문
      end; // for문
    end;

    if selectrow >= listgrid.RowCount then
    begin
      selectrow := listgrid.RowCount -1;
    end;
    listgrid.Row := selectrow;
  finally
    listgrid.Perform(WM_SETREDRAW, 1, 0);   // endupdate
    RnRDM.RRTableLeave;
    listgrid.Invalidate;
  end;

  Label1.Caption := Format('접수 요청 (%d명)',[cnt]);

  if isNewAdd then
  begin  // 신규로 추가된 data가 있다.
    if not Application.Active then
      FormFlash( True );
  end;
end;

procedure TRnRForm.filter_btnClick(Sender: TObject);
var
  roominfo : TRoomInfo;
  rect : TRect;
begin
  GetWindowRect(Application.MainFormHandle, rect);
  roominfo.RoomCode := FRoomFilter;
  if ShowRoomFilterForm( rect, roominfo ) = mrOk then
  begin
    if FRoomFilter <> roominfo.RoomCode then
    begin
      FObserver.BeforeAction(OB_Event_DataRefresh_RR);
      try
        FRoomFilter := roominfo.RoomCode;
        if FRoomFilter = '' then
          filter_btn.ActiveButtonType := aibtButton1
        else
          filter_btn.ActiveButtonType := aibtButton2;
      finally
        FObserver.AfterAction(OB_Event_DataRefresh_RR);
      end;
    end;
  end;
end;

procedure TRnRForm.SakpungImageButton1Click(Sender: TObject);
  function countDecide : Integer;
  var
    i : Integer;
    data : TDispData;
  begin
    Result := 0;
    for i := 0 to listgrid.RowCount -1 do
    begin
      data := TDispData( listgrid.Objects[ Col_Index_Data, i ] );
      if not Assigned( data ) then
        continue;
      if data.RoomInfo.RoomCode = '' then
        continue; // room code가 없어서 일괄로 처리 할수 없다.
      if not RnRDM.FindRR( data ) then
        Continue; //  못찾았다.  처리 하지 않는다.

      if not (data.Status in [rrs예약요청, rrs접수요청]) then
        continue; //예약/접수 요청 data가 아니다.

      Inc( Result );
    end;
  end;
var
  i, cnt : Integer;
  status : TRnRDataStatus;
  data : TDispData;

  event_109 : TBridgeResponse_109;
begin
  cnt := countDecide; // 확정 대상 data의 갯수를 계산 한다.
  if cnt <= 0 then
    exit;

  if ShowGDMsgDlg( format('%d개의 접수/예약 요청을 확정하시겠습니까?',[cnt]), Application.MainForm, mtConfirmation, [mbYes, mbNo]) <> mrYes then
    exit;

  cnt := 0;
  FObserver.BeforeAction(OB_Event_DataRefresh);
  try
    for i := 0 to listgrid.RowCount -1 do
    begin
      data := TDispData( listgrid.Objects[ Col_Index_Data, i ] );
      if not Assigned( data ) then
        continue;
      if data.RoomInfo.RoomCode = '' then
        continue; // room code가 없어서 일괄로 처리 할수 없다.

      if not (data.Status in [rrs예약요청, rrs접수요청]) then
        continue; //예약/접수 요청 data가 아니다.

      listgrid.Row := i;

      with RnRDM do
      begin
        if not FindRR( data ) then
          Continue; // 못 찾았다.

        if data.DataType = rrReception then
          status := rrs접수완료
        else
          status := rrs예약완료;

        try
          event_109 := BridgeWrapperDM.ChangeStatus( data, status );
          try
            if event_109.Code = Result_SuccessCode then
            begin
              Inc( cnt );
              UpdateStatusRR(data, status);
            end
            else
              ShowGDMsgDlg( event_109.MessageStr, Application.MainForm, mtError, [mbOK]); //GDMessageDlg(event_109.MessageStr, mtError, [mbOK], 0, Self.Handle );
          finally
            FreeAndNil( event_109 );
          end;
        except
          on e : exception do
          begin
            AddExceptionLog('TRnRForm.ButtonClickEvent : ', e);
            ShowGDMsgDlg( format('작업 중 Error가 발생 하였습니다'+#13#10+ '(%s,%s)',[e.Message, e.ClassName]), Application.MainForm, mtError, [mbOK]);
            exit;
          end;
        end;
      end;
    end;
  finally
    FObserver.AfterActionASync(OB_Event_DataRefresh);
  end;

  ShowGDMsgDlg( format('%d개의 접수/예약 요청 데이터를 처리 하였습니다.',[cnt]), Application.MainForm, mtInformation, [mbOK]);
end;

procedure TRnRForm.SetGridUI;
var
  i : Integer;
  str : string;
  dname, dtime, droom : string;
//  dtime2 : string;
begin
  try
    ClearGrid;
    with listgrid do
    begin
      RowCount := 2;

      dname := '이름' + Const_Char_Arrow_UPDown;
      droom := '진료실' + Const_Char_Arrow_UPDown;
      dtime := '요청시각' + Const_Char_Arrow_UPDown;
      case FSortType of
        Sort_Name_Ascending   : dname := '이름' + Const_Char_Arrow_Down;
        Sort_Name_Descending  : dname := '이름' + Const_Char_Arrow_UP;
        Sort_Time_Ascending   : dtime := '요청시각' + Const_Char_Arrow_Down;
        Sort_Room_Ascending   : droom := '진료실' + Const_Char_Arrow_Down;
        Sort_Room_Descending  : droom := '진료실' + Const_Char_Arrow_UP;
      else // Sort_time_Descending  :
        dtime := '요청시각' + Const_Char_Arrow_UP;
      end;
      //dtime2 := '예약시각';
      str := Grid_Head_관리+ ',' + Grid_Head_상태 + ',' + Grid_Head_환자유형 +',' + dname + ',"' + droom + '",' + Grid_Head_생일_주번 + ','+ Grid_Head_내원목적+ ',"' + dtime ;
      Rows[ 0 ].CommaText := str;

      str := '';
      for i := 0 to ColCount do
      begin
        if str <> '' then
          str := str + ',';
        str := str + '""';
      end;
      Rows[ 1 ].CommaText := str;

      // hide column
      if GetRREnv.ShowOptionRoom then
      begin
        if ColWidths[FDrawGrid.Col_Index_Room] = -1 then
          ColWidths[FDrawGrid.Col_Index_Room] := Col_Width_Room_RR;
      end
      else
        ColWidths[FDrawGrid.Col_Index_Room] := -1;

      if GetRREnv.ShowOptionRegNum then
      begin
        if ColWidths[FDrawGrid.Col_Index_BirthDayRegNum] = -1 then
          ColWidths[FDrawGrid.Col_Index_BirthDayRegNum] := Col_Width_BirthDay_RR;
      end
      else
        ColWidths[FDrawGrid.Col_Index_BirthDayRegNum] := -1;

      if GetRREnv.ShowOptionCreationTime then
      begin
        if ColWidths[FDrawGrid.Col_Index_Time] = -1 then
          ColWidths[FDrawGrid.Col_Index_Time] := Col_Width_Time_RR;
      end
      else
        ColWidths[FDrawGrid.Col_Index_Time] := -1;

//      if GetRREnv.ShowOptionReservationTime then
//      begin
//        if ColWidths[FDrawGrid.Col_Index_Time2] = -1 then
//          ColWidths[FDrawGrid.Col_Index_Time2] := Col_Width_Time2_RR;
//      end
//      else
//        ColWidths[FDrawGrid.Col_Index_Time2] := -1;

//      if GetRREnv.ShowOptionSymptom then
//      begin
//        if ColWidths[FDrawGrid.Col_Index_Symptom] = -1 then
//          ColWidths[FDrawGrid.Col_Index_Symptom] := Col_Width_Symptom_RR;
//      end
//      else
//        ColWidths[FDrawGrid.Col_Index_Symptom] := -1;

      if GetRREnv.ShowOptionisFirst then
      begin
        if ColWidths[FDrawGrid.Col_Index_isFirst] = -1 then
          ColWidths[FDrawGrid.Col_Index_isFirst] := Col_Width_isFirst_RR;
      end
      else
        ColWidths[FDrawGrid.Col_Index_isFirst] := -1;

      if GetRREnv.ShowOptionState then
      begin
        if ColWidths[FDrawGrid.Col_Index_State] = -1 then
          ColWidths[FDrawGrid.Col_Index_State] := Col_Width_State_RR;
      end
      else
        ColWidths[FDrawGrid.Col_Index_State] := -1;

    end;
  finally
    listgrid.Invalidate;
  end;
end;

procedure TRnRForm.ShowPanel(AParentControl: TWinControl);
begin
  if Assigned( AParentControl ) then
  begin
    ec_btn.PngImageList := ImageResourceDM.ExpandCollapseButtonImageList;
    ImageResourceDM.SetButtonImage(ec_btn, aibtButton1, BTN_Img_접기);
    ImageResourceDM.SetButtonImage(ec_btn, aibtButton2, BTN_Img_펴기);

    filter_btn.PngImageList := ImageResourceDM.ButtonImageList24x24;
    ImageResourceDM.SetButtonImage(filter_btn, aibtButton1, BTN_Img_Filter_Off);
    ImageResourceDM.SetButtonImage(filter_btn, aibtButton2, BTN_Img_Filter_On);

    Panel1.Parent := AParentControl;
    Panel1.Align := alClient;

    filter_btn.Visible := RnRDM.RoomFilterButtonVisible;

    /// V4에서는 예약 기능 삭제
    reservation_check.Enabled := False;
    reservation_check.Visible := False;
  end
  else
  begin
    if Assigned( Panel1 ) then
    begin
      Panel1.Visible := False;
      Panel1.Parent := Self;
      Panel1.Align := alClient;
    end;
  end;
end;


procedure TRnRForm.StatusChangeNotify(AData: TRnRData;
  ANewStatus: TRnRDataStatus; var AClosed: Boolean);

  function StatusChange : Boolean;
  var // 상태 변경
    event_109 : TBridgeResponse_109;
  begin
    Result := False;
    with RnRDM do
    begin
      try
        if not FindRR( AData ) then
          exit; // 못 찾았다.

        if not ConfirmMessage( ANewStatus, Self.Handle ) then
          exit;

        FObserver.BeforeAction(OB_Event_DataRefresh);
        try
          event_109 := BridgeWrapperDM.ChangeStatus( AData, ANewStatus );
          try
            if event_109.Code = Result_SuccessCode then
            begin
              UpdateStatusRR(AData, ANewStatus);
              Result := True;

              // chart hooking 사용 중일 경우 차트로 전송
{$IFNDEF DEBUG}
              if GetOCSHookLoader.OCSType <> TOCSType.None then
              begin
                if GetOCSHookLoader.isOCSHookDLLLoad then
                  InsertPatientToOCS(AData)
                else
                  AddLog( doRunLog, format('외래차트 연결 실패. OCSType: %d', [Ord(GetOCSHookLoader.OCSType)]));
              end;
{$ELSE}
              if GetOCSHookLoader.isOCSHookDLLLoad then
                InsertPatientToOCS(AData);
{$ENDIF}
            end
            else
              GDMessageDlg(event_109.MessageStr, mtError, [mbOK], 0, Self.Handle );
          finally
            FreeAndNil( event_109 );
          end;
        except
          on e : exception do
          begin
            AddExceptionLog('TRnRForm.StatusChangeNotify : ', e);
            GDMessageDlg(format('작업 중 Error가 발생 하였습니다'+#13#10+ '(%s,%s)',[e.Message, e.ClassName]), mtError, [mbOK], 0);
          end;
        end;
      finally
        FObserver.AfterActionASync(OB_Event_DataRefresh);
      end;
    end; // with
  end;

//  function CancelStatus : Boolean;
//  var // 취소
//    form : TSelectCancelMSGForm;
//    event_103 : TBridgeResponse_103;
//  begin
//    Result := False;
//    with RnRDM do
//    begin
//      if not FindRR( AData ) then
//        exit; // 못 찾았다.
//
//      form := TSelectCancelMSGForm.Create( self );
//      try
//        if form.ShowModal = mrYes then
//        begin
//          event_103 := BridgeWrapperDM.CancelReceptionReservation(AData, form.GetSelectMsg);
//          try
//            if event_103.Code <> Result_SuccessCode then
//              GDMessageDlg(event_103.MessageStr, mtError, [mbOK], 0, Self.Handle )
//            else
//            begin
//              UpdateStatusRR(AData, ANewStatus);
//              Result := True;
//            end;
//          finally
//            FreeAndNil( event_103 );
//          end;
//        end;
//      finally
//        FreeAndNil( form );
//      end;
//    end;
//  end;


 function CancelStatus : Boolean;
  var // 취소
    event_103 : TBridgeResponse_103;
  begin
    Result := False;
    with RnRDM do
    begin
      if not FindRR( AData ) then
        exit; // 못 찾았다.

      if not ConfirmMessage( ANewStatus, Self.Handle ) then
        exit;

     FObserver.BeforeAction(OB_Event_DataRefresh_Reception);
      try
        begin
          event_103 := BridgeWrapperDM.CancelReceptionReservation(AData, ANewStatus);
          try
            if event_103.Code <> Result_SuccessCode then
              GDMessageDlg(event_103.MessageStr, mtError, [mbOK], 0, Self.Handle )
            else
            begin
              UpdateStatusRR(AData, ANewStatus);
              Result := True;
            end;
          finally
            FreeAndNil( event_103 );
          end;
        end;
      finally
      FObserver.AfterActionASync(OB_Event_DataRefresh_Reception);
      end;
    end;
  end;


begin
  case ANewStatus of
    rrs예약완료,
    rrs접수완료 : AClosed := StatusChange;
    rrs예약실패,
    rrs접수실패 : AClosed := CancelStatus;
    rrs접수완료_new : AClosed := StatusChange;
  end;
end;

procedure TRnRForm.VisibleGridButton(AVisible: Boolean);
// grid에 출력되어 있는 모든 button들의 visible값을 지정된 값으로 설정 한다.
var
  i : Integer;
  dd : TDispData;
begin
  listgrid.Perform(WM_SETREDRAW, 0, 0);   // begineupdate
  try
    // grid위에 출력되어 있는 control들을 안보이게 처리 한다.
    for i := 0 to listgrid.RowCount -1 do
    begin
      dd := TDispData( listgrid.Objects[Col_Index_Data, i] );
      if Assigned( dd ) then
        dd.Button_확정.Visible := False;
    end;
  finally
    listgrid.Perform(WM_SETREDRAW, 1, 0);   // endupdate
    listgrid.Invalidate;
  end;
end;

procedure TRnRForm.InsertPatientToOCS(AData: TRnRData);
var
  ret : integer;
  retStr : string;
  patientdata : TREQPATIENTINFO;
  pdata : PREQPATIENTINFO;
  atmp : AnsiString;
  ocshook : TOCSHookDLLLoader;

begin
  ocshook := GetOCSHookLoader;

  FillChar(patientdata, sizeof(TREQPATIENTINFO), 0);

  if GetRREnv.IsFindPatientEnabled then
  begin
    if AData.isFirst then
      patientdata.unFirstVisit := 1
    else
      patientdata.unFirstVisit := 0;
  end
  else
    patientdata.unFirstVisit := 2;

  //patientdata.unID := StrToInt(FShowData.ChartReceptnResultId.Id1);
  atmp := AnsiString( AData.GetChartReceptnResultId );
  Move(atmp[1], patientdata.szID, Length(atmp)); // patientdata.szID := AData.GetCharReceptnResultId;
  atmp := AnsiString( AData.PatientChartID );
  Move(atmp[1], patientdata.szCNo, Length(atmp)); // patientdata.szCNo := AData.PatientChartID;
  atmp := AnsiString( DisplaySymptom(AData.Symptom) + #13#10 + AData.Memo );
  Move(atmp[1], patientdata.szMemo, Length(atmp)); // patientdata.szMemo := AData.Memo;
  patientdata.unSex := Cardinal(AData.Gender);
  atmp := AnsiString( AData.PatientName );
  Move(atmp[1], patientdata.szName, Length(atmp)); // patientdata.szName := AData.PatientName;
  atmp := AnsiString( AData.Addr );
  Move(atmp[1], patientdata.szAddress, Length(atmp)); // patientdata.szAddress := AData.Addr;

  atmp := AnsiString( AData.AddrDetail );
  Move(atmp[1], patientdata.szAddressDetail, Length(atmp)); // patientdata.szAddress := AData.AddrDetail;

  atmp := AnsiString( AData.Zip );
  Move(atmp[1], patientdata.szZip, Length(atmp)); // patientdata.szzip := AData.zip;

  atmp := AnsiString( AData.Registration_number );
  Move(atmp[1], patientdata.szSocialNum, Length(atmp)); // patientdata.szSocialNum := AData.Registration_number;
  atmp := AnsiString( AData.CellPhone );
  Move(atmp[1], patientdata.szCellPhone, Length(atmp)); // patientdata.szCellPhone := AData.CellPhone;
  atmp := AnsiString( AData.BirthDay );
  Move(atmp[1], patientdata.szBirthday, Length(atmp)); // patientdata.szBirthday := AData.BirthDay;
  atmp := AnsiString( AData.RoomInfo.RoomName );
  Move(atmp[1], patientdata.szRoom, Length(atmp)); // patientdata.szRoom := AData.RoomInfo.RoomName;
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


{ TDispData }

constructor TDispData.Create;
begin
  inherited;
  Button_확정 := nil;
end;

destructor TDispData.Destroy;
begin
  if Assigned(Button_확정) then
  begin
    Button_확정.Parent := nil;
    FreeAndNil( Button_확정 );
  end;

  inherited;
end;

initialization
  GRnRForm := nil;

finalization

end.
