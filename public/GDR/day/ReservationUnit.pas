unit ReservationUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Grids,
  RRObserverUnit, GDGrid, Vcl.StdCtrls, SakpungStyleButton, SakpungImageButton,
  RnRData, RRGridDrawUnit;

type
  TDispData = class( TRnRData )
  private
    { Private declarations }
  public
    { Public declarations }
    Button_진료완료 : TSakpungImageButton2;
    Button_내원확인 : TSakpungImageButton2;
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

  TReservationForm = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    all_check: TCheckBox;
    Decide_check: TCheckBox;
    VisiteDecide_check: TCheckBox;
    finish_check: TCheckBox;
    cancel_check: TCheckBox;
    Label1: TLabel;
    listgrid: TStringGrid;
    ec_btn: TSakpungImageButton2;
    BalloonHint1: TBalloonHint;
    filter_btn: TSakpungImageButton2;
    procedure all_checkClick(Sender: TObject);
    procedure listgridTopLeftChanged(Sender: TObject);
    procedure listgridFixedCellClick(Sender: TObject; ACol, ARow: Integer);
    procedure listgridDblClick(Sender: TObject);
    procedure listgridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure ec_btnClick(Sender: TObject);
    procedure listgridMouseLeave(Sender: TObject);
    procedure listgridMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure filter_btnClick(Sender: TObject);
    procedure listgridMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure listgridMouseActivate(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y, HitTest: Integer;
      var MouseActivate: TMouseActivate);
  private
    { Private declarations }
    FSortType : Integer;
    Foldrow4Hint : Integer;
    FRoomFilter : string;
    FDrawGrid : TGridListDrawCell;
    FLastMouseUPGridRow, FLastMouseUPGridCol : Integer;
    FLastMouseDownRow : Integer; // grid에서 mousedown한 row의 위치를 관리 한다.

    FButtonEnabled: Boolean;

    procedure SetGridUI;  // grid의 초기 UI를 설정 한다.
    function FindObject4Grid( AObj : TObject; var ARow, ATag : Integer ) : TDispData;  // aobj에 해당하는 row를 grid에서 찾아 관련 data를 반환 한다.
    function FindID4Grid(ARnRData : TRnRData; var ARow : Integer) : TDispData;  // 접수 data로 grid상의 data를 추적 한다.

    procedure RefreshData; // list에 data를 출력 한다.  주기적으로 출력 한다.
    function CheckFilterData : Boolean; // filter에 적절 한지 check한다. true이면 출력 대상이다.
    procedure ClearGrid;
    // grid에 출력되어 있는 모든 button들의 visible값을 지정된 값으로 설정 한다.
    procedure VisibleGridButton( AVisible : Boolean = False );

    procedure ButtonClickEvent( ASender : TObject ); // 확정 button click시 발생하는 event
    procedure ButtonClickEventThread( ASender : TObject ); // 확정 button click시 발생하는 event
    // 상세 조회상태에서 상태 변경 event 발생시 처리
    procedure StatusChangeNotify(AData: TRnRData; ANewStatus : TRnRDataStatus; var AClosed : Boolean);
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


procedure FreeReservationForm;
function GetReservationForm : TReservationForm;

implementation
uses
  Data.DB, UtilsUnit, GDLog, BridgeCommUnit, RREnvUnit,
  EventIDConst, RRConst, RRDialogs, RoomFilter,
  RnRDMUnit, ImageResourceDMUnit, DetailView, BridgeWrapperUnit, SelectCancelMSG;

var
  GReservationForm: TReservationForm;


{$R *.dfm}

function GetReservationForm : TReservationForm;
begin
  if not Assigned( GReservationForm ) then
    GReservationForm := TReservationForm.Create( nil );
  Result := GReservationForm;
end;

procedure FreeReservationForm;
begin
  if Assigned( GReservationForm ) then
  begin
    GReservationForm.ShowPanel( nil );
    FreeAndNil( GReservationForm );
  end;
end;


{ TDispData }

constructor TDispData.Create;
begin
  inherited;
  Button_진료완료 := nil;
  Button_내원확인 := nil;
end;

destructor TDispData.Destroy;
begin
  if Assigned(Button_진료완료) then
  begin
    Button_진료완료.Parent := nil;
    FreeAndNil( Button_진료완료 );
  end;

  if Assigned(Button_내원확인) then
  begin
    Button_내원확인.Parent := nil;
    FreeAndNil( Button_내원확인 );
  end;
  inherited;
end;

{ TReservationForm }

procedure TReservationForm.AfterEventNotify(AEventID: Cardinal; AData: TObserverData);
begin
  case AEventID of
    OB_Event_DataRefresh,
    OB_Event_DataRefresh_Reservation : RefreshData; // grid의 list를 갱신 한다
    OB_Event_RoomInfo_Change : filter_btn.Visible := RnRDM.RoomFilterButtonVisible;
  end;
end;

procedure TReservationForm.all_checkClick(Sender: TObject);
begin
  FObserver.BeforeAction(OB_Event_DataRefresh_Reservation);
  try
    all_check.ClicksDisabled := true;
    Decide_check.ClicksDisabled := true;  // data 수정시 click event를 발생시키지 않게 한다
    VisiteDecide_check.ClicksDisabled := true;
    cancel_check.ClicksDisabled := true;
    finish_check.ClicksDisabled := true;
    try
      if Sender = all_check then
      begin
        Decide_check.Checked := all_check.Checked;
        VisiteDecide_check.Checked := all_check.Checked;
        cancel_check.Checked := all_check.Checked;
        finish_check.Checked := all_check.Checked;
      end
      else
      begin // 예약/접수/취소 클릭
        all_check.Checked := Decide_check.Checked and VisiteDecide_check.Checked and cancel_check.Checked and finish_check.Checked;
      end;
    finally
      Decide_check.ClicksDisabled := False;
      VisiteDecide_check.ClicksDisabled := False;
      cancel_check.ClicksDisabled := False;
      finish_check.ClicksDisabled := False;
      all_check.ClicksDisabled := False;
    end;
  finally
    FObserver.AfterAction(OB_Event_DataRefresh_Reservation);
  end;
end;

procedure TReservationForm.BeforeEventNotify(AEventID: Cardinal;
  AData: TObserverData);
begin

end;

procedure TReservationForm.ButtonClickEvent(ASender: TObject);
var
  t, r : Integer;
  status : TRnRDataStatus;
  data : TDispData;
  copydata : TRnRData;
  event109 : TBridgeResponse_109;
begin // 내원요청/내원확인/진료완료  button click시 발생하는 event
  data := FindObject4Grid( ASender, r, t);

  if not Assigned( data ) then
    exit;

  listgrid.Row := r;

  with RnRDM do
  begin
    if not FindRR( data ) then
      exit; //  못 찾았다.

    copydata := data.Copy;
    try
      case t of
        Index_tag_내원확인 : status := rrs내원확정; // rrs진료대기;
      else // Index_tag_진료완료
        status := rrs진료완료;
      end;

      event109 := BridgeWrapperDM.ChangeStatus( copydata, status);
      try
        if event109.Code = Result_SuccessCode then
        begin
          data := FindID4Grid( copydata, r);
          if Assigned( data ) then
          begin
            UpdateStatusRR(data, status);
            data.Status := status;
            listgrid.Row := r;
          end;
        end
        else
          GDMessageDlg(event109.MessageStr, mtError, [mbOK], 0, Self.Handle );
      finally
        FreeAndNil( event109 );
      end;

    finally
      FreeAndNil( copydata );
      listgrid.Invalidate;
    end;
  end;
end;

procedure TReservationForm.ButtonClickEventThread(ASender: TObject);
begin
  if RnRDM.IsTaskRunning then
    exit;

  if not FButtonEnabled then
    exit;

  FButtonEnabled := False;

  TThread.CreateAnonymousThread( procedure begin ButtonClickEvent(ASender); FButtonEnabled := True end ).Start;
end;

function TReservationForm.CheckFilterData: Boolean;
var
  status : TRnRDataStatus;
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

  if (not Result) or (all_check.Checked or (Decide_check.Checked and
     VisiteDecide_check.Checked and finish_check.Checked and cancel_check.Checked)) then
  begin  // 전체 data
    exit;
  end;

  with RnRDM do
  begin
    statusfilter := [];
    status := TRRDataTypeConvert.DataStatus2RnRDataStatus( RR_DB.FieldByName('status').AsInteger );;

    if Decide_check.Checked then // 예약 확정
    begin
      Include(statusfilter, rrs예약완료);
    end;

    if VisiteDecide_check.Checked then // 내원
    begin
      Include(statusfilter, rrs진료대기);
      Include(statusfilter, rrs진료차례);
      Include(statusfilter, rrs내원요청);
      Include(statusfilter, rrs내원확정);
    end;

    if finish_check.Checked then  // 완료
    begin
      Include(statusfilter, rrs진료완료);
    end;

    if cancel_check.Checked then // 취소
    begin
      if RR_DB.FieldByName( 'hsptlreceptndttm' ).AsDateTime <> 0 then
      begin
        Include(statusfilter, rrs취소요청);
        Include(statusfilter, rrs본인취소);
        Include(statusfilter, rrs병원취소);
        Include(statusfilter, rrs자동취소);
      end;
    end;

    Result := status in statusfilter;
  end;
end;

procedure TReservationForm.ClearGrid;
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

constructor TReservationForm.Create(AOwner: TComponent);
begin
  inherited;
  FRoomFilter := '';
  FLastMouseUPGridRow := 0;
  FLastMouseUPGridCol := 0;
  FLastMouseDownRow := -1;

  Constraints.MinHeight := Panel2.Height;

  FObserver := TRRObserver.Create( nil );
  FObserver.OnBeforeAction := BeforeEventNotify;
  FObserver.OnAfterAction := AfterEventNotify;

  FSortType := Sort_time_Descending;

  FDrawGrid := TGridListDrawCell.Create;
  FDrawGrid.GridDataType := gdtReservation;
  FDrawGrid.ListGrid := listgrid;

  FButtonEnabled := True;

  GetRREnv.GridInfoList.GetGridInfo( Grid_Information_Reservation_ID ).SetGridInfo( FSortType, listgrid);
end;

destructor TReservationForm.Destroy;
begin
  ec_btn.PngImageList := nil;
  ClearGrid;  // grid에 등록되어 있는 object 제거

  FreeAndNil( FDrawGrid );

  FreeAndNil( FObserver );
  inherited;
end;

procedure TReservationForm.ec_btnClick(Sender: TObject);
begin
  FObserver.BeforeAction(OB_Event_ExpandCollapse_Reservation);
  try
    { TODO : 접었다/폈다 button의 상태를 변환 시켜야 한다 }
  finally
    FObserver.AfterAction(OB_Event_ExpandCollapse_Reservation);
  end;
end;

procedure TReservationForm.filter_btnClick(Sender: TObject);
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
      FObserver.BeforeAction(OB_Event_DataRefresh_Reservation);
      try
        FRoomFilter := roominfo.RoomCode;
        if FRoomFilter = '' then
          filter_btn.ActiveButtonType := aibtButton1
        else
          filter_btn.ActiveButtonType := aibtButton2;
      finally
        FObserver.AfterAction(OB_Event_DataRefresh_Reservation);
      end;
    end;
  end;
end;

function TReservationForm.FindID4Grid(ARnRData: TRnRData;
  var ARow: Integer): TDispData;
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
      if (ARnRData.ChartReceptnResultId.Id1 = rowdata.ChartReceptnResultId.Id1)
         and (ARnRData.ChartReceptnResultId.Id2 = rowdata.ChartReceptnResultId.Id2)
         and (ARnRData.ChartReceptnResultId.Id3 = rowdata.ChartReceptnResultId.Id3)
         and (ARnRData.ChartReceptnResultId.Id4 = rowdata.ChartReceptnResultId.Id4)
         and (ARnRData.ChartReceptnResultId.Id5 = rowdata.ChartReceptnResultId.Id5)
         and (ARnRData.ChartReceptnResultId.Id6 = rowdata.ChartReceptnResultId.Id6)
        then
      begin
        ARow := i;
        Result := rowdata;
        exit;
      end;
    end;
  end;
end;

function TReservationForm.FindObject4Grid(AObj: TObject; var ARow,
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
      if AObj = rowdata.Button_진료완료 then
      begin
        ARow := i;
        ATag := rowdata.Button_진료완료.Tag;
        Result := rowdata;
        exit;
      end
      else if AObj = rowdata.Button_내원확인 then
      begin
        ARow := i;
        ATag := rowdata.Button_내원확인.Tag;
        Result := rowdata;
        exit;
      end;
    end;
  end;
end;

procedure TReservationForm.listgridDblClick(Sender: TObject);
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

procedure TReservationForm.listgridDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
  procedure dispButton( ARect : TRect; AButton : TSakpungImageButton2 );
  var
    r : TRect;
  begin
    r.Left := ARect.Left + ( ((ARect.Right - ARect.Left) - AButton.Width) div 2);
    if ARect.Left > r.Left then
      r.Left := ARect.Left;

    if (ARect.Bottom - ARect.Top) > AButton.Height then // cell 영역에 button 표시가 가능한 영역인지 check한다.
      r.top := ARect.Top + ( ((ARect.Bottom - ARect.Top) - AButton.Height) div 2) // 가능하면
    else
      r.Top := ARect.Top; // 불가능하면
    r.Right := r.Left + AButton.Width;
    r.Bottom := r.Top + AButton.Height;

    AButton.BoundsRect := r;
    AButton.Visible := True;
  end;
var
  s : TStringGrid;
  rowdata : TDispData;
  workrect, r1 : TRect;
begin
  try
    if ARow < 1 then
      exit;
    if ACol < FDrawGrid.Col_Index_Button1 then
      exit;

    s := TStringGrid( Sender );

    rowdata := TDispData( s.Objects[Col_Index_Data, ARow] );
    if not Assigned( rowdata ) then
      exit; // 출력 data가 없다.

    workrect := s.CellRect(FDrawGrid.Col_Index_Button1, ARow);
    r1 := s.CellRect(FDrawGrid.Col_Index_Button2, ARow);
    workrect := TRect.Union(workrect, r1);
    workrect.Right := workrect.Right -1;

    case rowdata.Status4App of
      csa환자확인,
      csa환자확인Disable,
      csa환자내원         : // 내원 요청/내원 확인 버튼만 출력 한다.
        begin
          dispButton(workrect, rowdata.Button_내원확인);
        end;
      csa진료대기         : // 완료 버튼만 출력 한다.
        begin
          if rowdata.Status = rrs내원확정 then
          begin
            rowdata.Button_내원확인.Visible := False;
          end;

          dispButton(workrect, rowdata.Button_진료완료);
        end;
      csa진료완료         : // 완료된 data이다.
        begin
          rowdata.Button_진료완료.Visible := False;
          rowdata.Button_내원확인.Visible := False;
          FDrawGrid.DrawCenterText(s, workrect, '-' );
        end;
      csa취소             : // 취소 data
        begin
          rowdata.Button_진료완료.Visible := False;
          rowdata.Button_내원확인.Visible := False;

          FDrawGrid.DrawCenterText(s, workrect, '-' );
        end;
    end;
  except
    on e : exception do
    begin
      AddExceptionLog('TReservationForm.listgridDrawCell', e);
      raise e;
    end;
  end;
end;

procedure TReservationForm.listgridFixedCellClick(Sender: TObject; ACol,
  ARow: Integer);
begin
  if not (ACol in [FDrawGrid.Col_Index_PatientName, FDrawGrid.Col_Index_Room, FDrawGrid.Col_Index_Time]) then
    exit;

  FObserver.BeforeAction( OB_Event_DataRefresh_Reservation );
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
    FObserver.AfterActionASync( OB_Event_DataRefresh_Reservation );
  end;
end;

procedure TReservationForm.listgridMouseActivate(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y, HitTest: Integer;
  var MouseActivate: TMouseActivate);
var
  tmp : Integer;
begin
  if Button = mbLeft then
  begin
    listgrid.MouseToCell( x, y, tmp, FLastMouseDownRow );
  end;
end;

procedure TReservationForm.listgridMouseLeave(Sender: TObject);
begin
  BalloonHint1.HideHint;
  Foldrow4Hint := -1;
end;

procedure TReservationForm.listgridMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
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
      rt := s.CellRect(2,r);
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

procedure TReservationForm.listgridMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    listgrid.MouseToCell( x, y, FLastMouseUPGridCol, FLastMouseUPGridRow );
    if FLastMouseDownRow = 0 then // col이 resize되었거나 sort 상태가 변경된것으로 인지 한다.
    begin
      VisibleGridButton( False );
      listgrid.Invalidate;
      GetRREnv.GridInfoList.GetGridInfo( Grid_Information_Reservation_ID ).AssignGridInfo( FSortType, listgrid);
    end;
  end;
end;

procedure TReservationForm.listgridTopLeftChanged(Sender: TObject);
begin
  BalloonHint1.HideHint;
  Foldrow4Hint := -1;

  VisibleGridButton( False );
end;

procedure TReservationForm.RefreshData;
var
  step : Integer;
  rowindex : Integer;
  dtype : TRnRType;
  statuscode : TRnRDataStatus;
  status : TConvertState4App;
  rowdata : TDispData;
  selectrow : Integer;
  cnt : Integer;
begin
  selectrow := listgrid.Row;

  cnt := 0;
  SetGridUI;

  RnRDM.RRTableEnter;
  listgrid.Perform(WM_SETREDRAW, 0, 0);   // begineupdate
  try
    with RnRDM do
    begin
      // sort상황에 따라 index값을 변경해야 한다.
      case FSortType of
        Sort_Name_Ascending   : RR_DB.IndexName := 'nameIndex'; // 환자 이름 순
        Sort_Name_Descending  : RR_DB.IndexName := 'nameIndexdesc'; // 환자 이름 역순
        Sort_Time_Ascending   : RR_DB.IndexName := 'visitIndex'; // 방문 시간 순
        Sort_Room_Ascending   : RR_DB.IndexName := 'roomIndex'; // 진료실순
        Sort_Room_Descending  : RR_DB.IndexName := 'roomIndexdesc'; // 진료실 역순
      else // Sort_time_Descending  :
        RR_DB.IndexName := 'visitIndexdesc'; // 방문 시간 역순
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
          dtype := TRnRType( RR_DB.FieldByName( 'datatype' ).AsInteger );
          try
            if dtype <> rrReservation then
                Continue;

            // 당일 방문 예약 data만 표시 해야 한다.
            if not CheckToday( RR_DB.FieldByName( 'reservedttm' ).AsDateTime ) then
              Continue; // 방문일이 오늘이 아니다.

            statuscode := TRRDataTypeConvert.DataStatus2RnRDataStatus(RR_DB.FieldByName( 'status' ).AsInteger);
            status := TRRDataTypeConvert.Status4App( statuscode, RR_DB.FieldByName( 'hsptlreceptndttm' ).AsDateTime );
            if status in [csa요청, csa요청취소] then // 요청 관련 data만 인지 하게 한다.
              Continue; // 요청상태이면 아니면 처리 하지 않는다.

            if step = 0 then
            begin
              if TRRDataTypeConvert.CheckCancelStatus( statuscode ) then
                continue; // 취소 data는 step 0에서 처리 한다.

              if not TRRDataTypeConvert.checkFinishStatus(statuscode) then
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
            GetReceptionReservationData( rowdata  );

            rowdata.Button_진료완료 := TSakpungImageButton2.Create(listgrid);
            rowdata.Button_진료완료.Visible := False;
            rowdata.Button_진료완료.Parent := listgrid;
            rowdata.Button_진료완료.Tag := Index_tag_진료완료;
            rowdata.Button_진료완료.PngImageList := ImageResourceDM.ButtonImageList;
            ImageResourceDM.SetButtonImage(rowdata.Button_진료완료, aibtButton1, BTN_Img_진료완료);
            //rowdata.Button_진료완료.OnClick := ButtonClickEvent;
            rowdata.Button_진료완료.OnClick := ButtonClickEventThread;


            rowdata.Button_내원확인 := TSakpungImageButton2.Create(listgrid);
            rowdata.Button_내원확인.Visible := False;
            rowdata.Button_내원확인.Parent := listgrid;
            rowdata.Button_내원확인.Tag := Index_tag_내원확인;
            rowdata.Button_내원확인.PngImageList := ImageResourceDM.ButtonImageList;
            ImageResourceDM.SetButtonImage(rowdata.Button_내원확인, aibtButton1, BTN_Img_내원확인);
            //rowdata.Button_내원확인.OnClick := ButtonClickEvent;
            rowdata.Button_내원확인.OnClick := ButtonClickEventThread;

            Inc( rowindex, 1);
            listgrid.RowCount := rowindex + 1;
            listgrid.Rows[ rowindex ].CommaText := '" "," "," "," "," "," "'; // 모든 내용은 drawcell에서 draw로 그린다.
            listgrid.Objects[Col_Index_Data, rowindex] := rowdata;
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
    RnRDM.RRTableLeave;
    listgrid.Perform(WM_SETREDRAW, 1, 0);   // endupdate
    listgrid.Invalidate;
  end;

  Label1.Caption := Format('예약 확정 (%d명)',[cnt]);
end;

procedure TReservationForm.SetGridUI;
var
  i : Integer;
  str : string;
  dname, dtime, droom : string;
begin
  listgrid.Perform(WM_SETREDRAW, 0, 0);   // begineupdate
  try
    ClearGrid;
    with listgrid do
    begin
      RowCount := 2;

      dname := '이름' + Const_Char_Arrow_UPDown;
      droom := '진료실' + Const_Char_Arrow_UPDown;
      dtime := '시간' + Const_Char_Arrow_UPDown;
      case FSortType of
        Sort_Name_Ascending   : dname := '이름' + Const_Char_Arrow_Down;
        Sort_Name_Descending  : dname := '이름' + Const_Char_Arrow_UP;
        Sort_Time_Ascending   : dtime := '시간' + Const_Char_Arrow_Down;
        Sort_Room_Ascending   : droom := '진료실' + Const_Char_Arrow_Down;
        Sort_Room_Descending  : droom := '진료실' + Const_Char_Arrow_UP;
      else // Sort_time_Descending  :
        dtime := '시간' + Const_Char_Arrow_UP;
      end;
      str := Grid_Head_상태 + ',"' + dname + '","' + droom + '",' + Grid_Head_생일_주번 + ',"' + dtime + '",' + Grid_Head_관리;
      Rows[ 0 ].CommaText := str;

      str := '';
      for i := 0 to ColCount do
      begin
        if str <> '' then
          str := str + ',';
        str := str + '""';
      end;
      Rows[ 1 ].CommaText := str;
    end;
  finally
    listgrid.Perform(WM_SETREDRAW, 1, 0);   // endupdate
    listgrid.Invalidate;
  end;
end;

procedure TReservationForm.ShowPanel(AParentControl: TWinControl);
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

procedure TReservationForm.StatusChangeNotify(AData: TRnRData;
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
            end
            else
              GDMessageDlg(event_109.MessageStr, mtError, [mbOK], 0, Self.Handle );
          finally
            FreeAndNil( event_109 );
          end;
        except
          on e : exception do
          begin
            AddExceptionLog('TReservationForm.StatusChangeNotify : ', e);
            GDMessageDlg(format('작업 중 Error가 발생 하였습니다'+#13#10+ '(%s,%s)',[e.Message, e.ClassName]), mtError, [mbOK], 0);
          end;
        end;
      finally
        FObserver.AfterActionASync(OB_Event_DataRefresh);
      end;
    end; // with
  end;

  function CancelStatus : Boolean;
  var // 취소
    form : TSelectCancelMSGForm;
    event_103 : TBridgeResponse_103;
  begin
    Result := False;
    with RnRDM do
    begin
      if not FindRR( AData ) then
        exit; // 못 찾았다.

      form := TSelectCancelMSGForm.Create( self );
      try
        if form.ShowModal = mrYes then
        begin
         // event_103 := BridgeWrapperDM.CancelReceptionReservation(AData, form.GetSelectMsg);
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
        FreeAndNil( form );
      end;
    end;
  end;

begin
  case ANewStatus of
    rrs진료대기,
    rrs내원확정,
    rrs진료차례,
    rrs내원요청,
    rrs진료완료 : AClosed := StatusChange;

    rrs병원취소,
    rrs본인취소,
    rrs취소요청 : AClosed := CancelStatus;
  end;
end;

procedure TReservationForm.VisibleGridButton(AVisible: Boolean);
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
      begin
        dd.Button_진료완료.Visible := False;
        dd.Button_내원확인.Visible := False;
      end;
    end;
  finally
    listgrid.Perform(WM_SETREDRAW, 1, 0);   // endupdate
    listgrid.Invalidate;
  end;
end;

initialization
  GReservationForm := nil;

finalization

end.
