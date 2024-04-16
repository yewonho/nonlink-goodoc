unit ReceptionUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Grids,
  RRObserverUnit, GDGrid, Vcl.StdCtrls, SakpungImageButton,
  RnRData, RRGridDrawUnit, Data.DB;

type
  TDispData = class( TRnRData )
  private
    { Private declarations }
  public
    { Public declarations }
    Button_����Ϸ� : TSakpungImageButton2;
    //Button_������û : TSakpungImageButton2;
    //Button_����Ȯ�� : TSakpungImageButton2;
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

  TReceptionForm = class(TForm)
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
    procedure listgridTopLeftChanged(Sender: TObject);
    procedure listgridFixedCellClick(Sender: TObject; ACol, ARow: Integer);
    procedure listgridDblClick(Sender: TObject);
    procedure listgridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure all_checkClick(Sender: TObject);
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
    function GetHorizontalScrollBarPosition(grid: TStringGrid): Integer;

  private
    { Private declarations }
    Foldrow4Hint : Integer;
    FSortType : Integer;
    FRoomFilter : string;
    FDrawGrid : TGridListDrawCell;
    FLastMouseUPGridRow, FLastMouseUPGridCol : Integer;
    FLastMouseDownRow : Integer; // grid���� mousedown�� row�� ��ġ�� ���� �Ѵ�.

    FButtonEnabled : Boolean;

    procedure SetGridUI;  // grid�� �ʱ� UI�� ���� �Ѵ�.
    function FindObject4Grid( AObj : TObject; var ARow, ATag : Integer ) : TDispData;  // aobj�� �ش��ϴ� row�� grid���� ã�� ���� data�� ��ȯ �Ѵ�.
    function FindID4Grid(ARnRData : TRnRData; var ARow : Integer) : TDispData;  // ���� data�� grid���� data�� ���� �Ѵ�.

    procedure RefreshData; // list�� data�� ��� �Ѵ�.  �ֱ������� ��� �Ѵ�.
    function CheckFilterData : Boolean; // filter�� ���� ���� check�Ѵ�. true�̸� ��� ����̴�.
    procedure ClearGrid;
    // grid�� ��µǾ� �ִ� ��� button���� visible���� ������ ������ ���� �Ѵ�.
    procedure VisibleGridButton( AVisible : Boolean = False );

    procedure ButtonClickEvent( ASender : TObject ); // Ȯ�� button click�� �߻��ϴ� event
    procedure ButtonClickEventThread( ASender : TObject ); // Ȯ�� button click�� �߻��ϴ� event

    // �� ��ȸ���¿��� ���� ���� event �߻��� ó��
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

procedure FreeReceptionForm;
function GetReceptionForm : TReceptionForm;

implementation
uses
  UtilsUnit,
  GDLog, BridgeCommUnit, RREnvUnit,
  EventIDConst, RRConst, RRDialogs, RoomFilter,
  RnRDMUnit, ImageResourceDMUnit, DetailView,
  SelectCancelMSG, BridgeWrapperUnit;

var
  GReceptionForm: TReceptionForm;

{$R *.dfm}

function GetReceptionForm : TReceptionForm;
begin
  if not Assigned( GReceptionForm ) then
    GReceptionForm := TReceptionForm.Create( nil );
  Result := GReceptionForm;
end;

procedure FreeReceptionForm;
begin
  if Assigned( GReceptionForm ) then
  begin
    GReceptionForm.ShowPanel( nil );
    FreeAndNil( GReceptionForm );
  end;
end;

{ TDispData }

constructor TDispData.Create;
begin
  inherited;
  Button_����Ϸ� := nil;
 // Button_������û := nil;
 // Button_����Ȯ�� := nil;
end;

destructor TDispData.Destroy;
begin
  if Assigned(Button_����Ϸ�) then
  begin
    Button_����Ϸ�.Parent := nil;
    FreeAndNil( Button_����Ϸ� );
  end;

//  if Assigned(Button_������û) then
//  begin
//    Button_������û.Parent := nil;
//    FreeAndNil( Button_������û );
//  end;
//
//  if Assigned(Button_����Ȯ��) then
//  begin
//    Button_����Ȯ��.Parent := nil;
//    FreeAndNil( Button_����Ȯ�� );
//  end;
  inherited;
end;

{ TReservationForm }

procedure TReceptionForm.AfterEventNotify(AEventID: Cardinal; AData: TObserverData);
begin
  case AEventID of
    OB_Event_DataRefresh, // ��ü
    OB_Event_DataRefresh_RR,
    OB_Event_DataRefresh_Reception :
      TThread.Synchronize(TThread.CurrentThread, procedure ()
      begin
        RefreshData; // grid�� list�� ���� �Ѵ�
      end);
    OB_Event_RoomInfo_Change : filter_btn.Visible := RnRDM.RoomFilterButtonVisible;
  end;
end;

procedure TReceptionForm.all_checkClick(Sender: TObject);
begin
  FObserver.BeforeAction(OB_Event_DataRefresh_Reception);
  try
    all_check.ClicksDisabled := true;
    Decide_check.ClicksDisabled := true;  // data ������ click event�� �߻���Ű�� �ʰ� �Ѵ�
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
      begin // ����/����/��� Ŭ��
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
    FObserver.AfterAction(OB_Event_DataRefresh_Reception);
  end;
end;

procedure TReceptionForm.BeforeEventNotify(AEventID: Cardinal;
  AData: TObserverData);
begin

end;

procedure TReceptionForm.ButtonClickEvent(ASender: TObject);
var
  t, r : Integer;
  status : TRnRDataStatus;
  data  : TDispData;
  copydata : TRnRData;
  event109 : TBridgeResponse_109;
begin // ������û/����Ȯ��/����Ϸ�  button click�� �߻��ϴ� event
  data := FindObject4Grid( ASender, r, t);

  if not Assigned( data ) then
    exit;

  listgrid.Row := r;

  with RnRDM do
  begin
    if not FindRR( data ) then
      exit; // �� ã�Ҵ�.

    copydata := data.Copy;
    try
      case t of
        Index_tag_������û : status := rrs������û;
        Index_tag_����Ȯ�� : status := rrs����Ȯ��; // status := rrs������;
      else // Index_tag_����Ϸ�
        status := rrs����Ϸ�;
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

procedure TReceptionForm.ButtonClickEventThread(ASender: TObject);
begin
  if RnRDM.IsTaskRunning then
    exit;

  if not FButtonEnabled then
    exit;

  FButtonEnabled := False;

  TThread.CreateAnonymousThread( procedure begin ButtonClickEvent(ASender); FButtonEnabled := True end ).Start;
end;

function TReceptionForm.CheckFilterData: Boolean;
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
  begin  // ��ü data
    exit;
  end;

  with RnRDM do
  begin
    statusfilter := [];
    status := TRRDataTypeConvert.DataStatus2RnRDataStatus( RR_DB.FieldByName('status').AsInteger );;

    if Decide_check.Checked then // ���� Ȯ��
    begin
      Include(statusfilter, rrs�����Ϸ�);
    end;

    if VisiteDecide_check.Checked then // ����
    begin
      Include(statusfilter, rrs������);
      Include(statusfilter, rrs��������);
      Include(statusfilter, rrs������û);
      Include(statusfilter, rrs����Ȯ��);
    end;

    if finish_check.Checked then  // �Ϸ�
    begin
      Include(statusfilter, rrs����Ϸ�);
    end;

    if cancel_check.Checked then // ���
    begin
      if RR_DB.FieldByName( 'hsptlreceptndttm' ).AsDateTime <> 0 then
      begin
        Include(statusfilter, rrs��ҿ�û);
        Include(statusfilter, rrs�������);
        Include(statusfilter, rrs�������);
        Include(statusfilter, rrs�ڵ����);
      end;
    end;

    Result := status in statusfilter;
  end;
end;

procedure TReceptionForm.ClearGrid;
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

constructor TReceptionForm.Create(AOwner: TComponent);
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
  FDrawGrid.GridDataType := gdtReception;
  FDrawGrid.ListGrid := listgrid;

  FButtonEnabled := True;

  GetRREnv.GridInfoList.GetGridInfo( Grid_Information_Reception_ID ).SetGridInfo( FSortType, listgrid);
end;

destructor TReceptionForm.Destroy;
begin
  ec_btn.PngImageList := nil;
  ClearGrid;  // grid�� ��ϵǾ� �ִ� object ����

  FreeAndNil( FDrawGrid );
  FreeAndNil( FObserver );

  inherited;
end;

procedure TReceptionForm.ec_btnClick(Sender: TObject);
begin
  FObserver.BeforeAction(OB_Event_ExpandCollapse_Reception);
  try
    { TODO : ������/��� button�� ���¸� ��ȯ ���Ѿ� �Ѵ� }
  finally
    FObserver.AfterAction(OB_Event_ExpandCollapse_Reception);
  end;
end;

procedure TReceptionForm.filter_btnClick(Sender: TObject);
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
      FObserver.BeforeAction(OB_Event_DataRefresh_Reception);
      try
        FRoomFilter := roominfo.RoomCode;

        if FRoomFilter = '' then
          filter_btn.ActiveButtonType := aibtButton1
        else
          filter_btn.ActiveButtonType := aibtButton2;
      finally
        FObserver.AfterAction(OB_Event_DataRefresh_Reception);
      end;
    end;
  end;
end;

function TReceptionForm.FindID4Grid(ARnRData: TRnRData; var ARow : Integer): TDispData;
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

function TReceptionForm.FindObject4Grid(AObj: TObject; var ARow,
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
      if AObj = rowdata.Button_����Ϸ� then
      begin
        ARow := i;
        ATag := rowdata.Button_����Ϸ�.Tag;
        Result := rowdata;
        exit;
//      end
//      else if AObj = rowdata.Button_������û then
//      begin
//        ARow := i;
//        ATag := rowdata.Button_������û.Tag;
//        Result := rowdata;
//        exit;
//      end
//      else if AObj = rowdata.Button_����Ȯ�� then
//      begin
//        ARow := i;
//        ATag := rowdata.Button_����Ȯ��.Tag;
//        Result := rowdata;
//        exit;
      end;
    end;
  end;
end;

procedure TReceptionForm.listgridDblClick(Sender: TObject);
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


function TReceptionForm.GetHorizontalScrollBarPosition(grid: TStringGrid): Integer;
var
  si: TScrollInfo;
begin
  FillChar(si, SizeOf(TScrollInfo), 0);
  si.cbSize := SizeOf(TScrollInfo);
  si.fMask := SIF_POS;

  if GetScrollInfo(grid.Handle, SB_HORZ, si) then
    Result := si.nPos
  else
    Result := 0; // ���� ó��
end;


procedure TReceptionForm.listgridDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
  procedure dispButton( ARect : TRect; AButton : TSakpungImageButton2 );
  var
    r : TRect;
  begin
    r.Left := ARect.Left + ( ((ARect.Right - ARect.Left) - AButton.Width) div 2);
    if ARect.Left > r.Left then
      r.Left := ARect.Left;

    if (ARect.Bottom - ARect.Top) > AButton.Height then // cell ������ button ǥ�ð� ������ �������� check�Ѵ�.
      r.top := ARect.Top + ( ((ARect.Bottom - ARect.Top) - AButton.Height) div 2) // �����ϸ�
    else
      r.Top := ARect.Top; // �Ұ����ϸ�
    r.Right := r.Left + AButton.Width;
    r.Bottom := r.Top + AButton.Height;

    AButton.BoundsRect := r;
    AButton.Visible := True
  end;
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

  s := TStringGrid( Sender );

  rowdata := TDispData( s.Objects[Col_Index_Data, ARow] );
  if not Assigned( rowdata ) then
    exit; // ��� data�� ����.

  workrect := s.CellRect(FDrawGrid.Col_Index_Button1, ARow);
  r1 := s.CellRect(FDrawGrid.Col_Index_Button2, ARow);
  workrect := TRect.Union(workrect, r1);
  workrect.Right := workrect.Right -1;

  case rowdata.Status4App of
    csaȯ��Ȯ��,
    csaȯ��Ȯ��Disable,
    csaȯ�ڳ���         : // ���� ��û/���� Ȯ�� ��ư�� ��� �Ѵ�.
      begin
        if rowdata.Inflow = rriftablet then
        begin
//          rowdata.Button_������û.Visible := False;
//          rowdata.Button_����Ȯ��.Visible := False;
          dispButton(workrect, rowdata.Button_����Ϸ�);
        end
        else
        dispButton(workrect, rowdata.Button_����Ϸ�);
//        begin
//          r1 := s.CellRect(FDrawGrid.Col_Index_Button1, ARow);
////          dispButton(r1, rowdata.Button_������û);
////          rowdata.Button_������û.Enabled := not (rowdata.Status in [rrs������û]);
//            dispButton(workrect, rowdata.Button_����Ϸ�);
//
//          r1 := s.CellRect(FDrawGrid.Col_Index_Button2, ARow);
////          dispButton(r1, rowdata.Button_����Ȯ��);
//
//        end;
      end;
    csa������         : // �Ϸ� ��ư�� ��� �Ѵ�.
      begin
//        if rowdata.Status = rrs����Ȯ�� then
//        begin
//          rowdata.Button_������û.Visible := False;
//          rowdata.Button_����Ȯ��.Visible := False;
//        end;
        dispButton(workrect, rowdata.Button_����Ϸ�);
      end;
    csa����Ϸ�         : // �Ϸ�� data�̴�.
      begin
        rowdata.Button_����Ϸ�.Visible := False;
//        rowdata.Button_������û.Visible := False;
//        rowdata.Button_����Ȯ��.Visible := False;
        FDrawGrid.DrawCenterText(s, workrect, '-' );
      end;
    csa��û���,
    csa���             : // ��� data
      begin
        rowdata.Button_����Ϸ�.Visible := False;
//        rowdata.Button_������û.Visible := False;
//        rowdata.Button_����Ȯ��.Visible := False;

        FDrawGrid.DrawCenterText(s, workrect, '-' );
      end;
  end;

    if CurrentScrollPos >= 30 then
    begin
    rowdata.Button_����Ϸ�.Visible := False;
    FDrawGrid.DrawCenterText(s, workrect, '-' );
    end

end;

procedure TReceptionForm.listgridFixedCellClick(Sender: TObject; ACol,
  ARow: Integer);
begin
  if not (ACol in [FDrawGrid.Col_Index_PatientName, FDrawGrid.Col_Index_Room, FDrawGrid.Col_Index_Time]) then
    exit;

  FObserver.BeforeAction( OB_Event_DataRefresh_Reception );
  try
    if ACol = FDrawGrid.Col_Index_PatientName then // �̸� sort
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
    else if ACol = FDrawGrid.Col_Index_Time then // �湮 �ð� sort
    begin
      if FSortType = Sort_Time_Ascending then
        FSortType := Sort_time_Descending
      else
        FSortType := Sort_Time_Ascending;
    end;

  finally
    FObserver.AfterActionASync( OB_Event_DataRefresh_Reception );
  end;
end;

procedure TReceptionForm.listgridMouseActivate(Sender: TObject;
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

procedure TReceptionForm.listgridMouseLeave(Sender: TObject);
begin
  BalloonHint1.HideHint;
  Foldrow4Hint := -1;
end;

procedure TReceptionForm.listgridMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
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
  begin // 0,1 col cell�� �ƴϸ� ��� ���� �ʴ´�.
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
    end;
  end
  else
  begin
    BalloonHint1.HideHint;
    Foldrow4Hint := -1;
  end;
end;

procedure TReceptionForm.listgridMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    listgrid.MouseToCell( x, y, FLastMouseUPGridCol, FLastMouseUPGridRow );
    if FLastMouseDownRow = 0 then // col�� resize�Ǿ��ų� sort ���°� ����Ȱ����� ���� �Ѵ�.
    begin
      VisibleGridButton( False );
      listgrid.Invalidate;
      GetRREnv.GridInfoList.GetGridInfo( Grid_Information_Reception_ID ).AssignGridInfo( FSortType, listgrid);
    end;
  end;
end;

procedure TReceptionForm.listgridTopLeftChanged(Sender: TObject);
begin
  BalloonHint1.HideHint;
  Foldrow4Hint := -1;

  VisibleGridButton( False );
end;

procedure TReceptionForm.RefreshData;
var
  step : Integer;
  rowindex : Integer;
  dtype : TRnRType;
  status : TConvertState4App;
  statuscode : TRnRDataStatus;
  rowdata : TDispData;
  selectrow : Integer;
  cnt : Integer;
begin
  selectrow := listgrid.Row;

  cnt := 0;

  RnRDM.RRTableEnter;
  listgrid.Perform(WM_SETREDRAW, 0, 0);   // begineupdate
  try
    SetGridUI;
    with RnRDM do
    begin
      // sort��Ȳ�� ���� index���� �����ؾ� �Ѵ�.
      case FSortType of
        Sort_Name_Ascending   : RR_DB.IndexName := 'nameIndex'; // ȯ�� �̸� ��
        Sort_Name_Descending  : RR_DB.IndexName := 'nameIndexdesc'; // ȯ�� �̸� ����
        Sort_Time_Ascending   : RR_DB.IndexName := 'visitIndex'; // �湮 �ð� ��
        Sort_Room_Ascending   : RR_DB.IndexName := 'roomIndex'; // ����Ǽ�
        Sort_Room_Descending  : RR_DB.IndexName := 'roomIndexdesc'; // ����� ����
      else // Sort_time_Descending  :
        RR_DB.IndexName := 'visitIndexdesc'; // �湮 �ð� ����
      end;

      rowindex := 0;
      for step := 0 to 1 do
      begin
        if step = 1 then
        begin // ��� data�� ����ؾ� �ϴµ�
          if (not all_check.Checked) and ( not cancel_check.Checked) then
            break; // filter���� ��� data�� ������� �ʰ� ���� �Ǿ� �ִ�.
        end;

        RR_DB.First;
        while not RR_DB.Eof do // state�� rrsRequest�� data�� ��� ��� �Ѵ�.
        begin
          dtype := TRnRType( RR_DB.FieldByName( 'datatype' ).AsInteger );
          try
            if dtype <> rrReception then
                Continue;

            // ���� ���� ���� data�� ǥ�� �ؾ� �Ѵ�.
            if not CheckToday( RR_DB.FieldByName( 'receptiondttm' ).AsDateTime ) then
              Continue; // ���� ��û data�� �ƴϴ�.

            statuscode := TRRDataTypeConvert.DataStatus2RnRDataStatus(RR_DB.FieldByName( 'status' ).AsInteger);
            status := TRRDataTypeConvert.Status4App( statuscode, RR_DB.FieldByName( 'hsptlreceptndttm' ).AsDateTime );

            if status in [csa��û, csa��û���] then // ��û ���� data�� ���� �ϰ� �Ѵ�.
              Continue; // ��û�����̸� �ƴϸ� ó�� ���� �ʴ´�.

            if step = 0 then
            begin
              if TRRDataTypeConvert.CheckCancelStatus( statuscode ) then
                continue; // ��� data�� step 0���� ó�� �Ѵ�.

              if not TRRDataTypeConvert.checkFinishStatus(statuscode) then
                Inc( cnt ); // �Ϸ� data�� ���迡 ���� ��Ű�� �ʴ´�.
            end
            else
            begin // step 1
              if not TRRDataTypeConvert.CheckCancelStatus( statuscode ) then
                continue // ��� data�� ����ϴµ� ����׸��� �ƴϴ�.
            end;

            if not CheckFilterData then // filteró��
              continue;

            rowdata := TDispData.Create;
            GetReceptionReservationData( rowdata  );

            rowdata.Button_����Ϸ� := TSakpungImageButton2.Create(listgrid);
            rowdata.Button_����Ϸ�.Visible := False;
            rowdata.Button_����Ϸ�.Parent := listgrid;
            rowdata.Button_����Ϸ�.Tag := Index_tag_����Ϸ�;
            rowdata.Button_����Ϸ�.PngImageList := ImageResourceDM.ButtonImageList;
            ImageResourceDM.SetButtonImage(rowdata.Button_����Ϸ�, aibtButton1, BTN_Img_����Ϸ�);
            //rowdata.Button_����Ϸ�.OnClick := ButtonClickEvent;
            rowdata.Button_����Ϸ�.OnClick := ButtonClickEventThread;

//            rowdata.Button_������û := TSakpungImageButton2.Create(listgrid);
//            rowdata.Button_������û.Visible := False;
//            rowdata.Button_������û.Parent := listgrid;
//            rowdata.Button_������û.Tag := Index_tag_������û;
//            rowdata.Button_������û.PngImageList := ImageResourceDM.ButtonImageList;
//            ImageResourceDM.SetButtonImage(rowdata.Button_������û, aibtButton1, BTN_Img_������û);
//            //rowdata.Button_������û.OnClick := ButtonClickEvent;
//            rowdata.Button_������û.OnClick := ButtonClickEventThread;

//            rowdata.Button_����Ȯ�� := TSakpungImageButton2.Create(listgrid);
//            rowdata.Button_����Ȯ��.Visible := False;
//            rowdata.Button_����Ȯ��.Parent := listgrid;
//            rowdata.Button_����Ȯ��.Tag := Index_tag_����Ȯ��;
//            rowdata.Button_����Ȯ��.PngImageList := ImageResourceDM.ButtonImageList;
//            ImageResourceDM.SetButtonImage(rowdata.Button_����Ȯ��, aibtButton1, BTN_Img_����Ȯ��);
//            //rowdata.Button_����Ȯ��.OnClick := ButtonClickEvent;
//            rowdata.Button_����Ȯ��.OnClick := ButtonClickEventThread;

            Inc( rowindex, 1);
            listgrid.RowCount := rowindex + 1;
            listgrid.Rows[ rowindex ].CommaText := '" "," "," "," "," "," "'; // ��� ������ drawcell���� draw�� �׸���.
            listgrid.Objects[Col_Index_Data, rowindex] := rowdata;
          finally
            RR_DB.Next;
          end;
        end; // while ��
      end; // for��
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

  Label1.Caption := Format('���� (%d��)',[cnt]);
end;

procedure TReceptionForm.SetGridUI;
var
  i : Integer;
  str : string;
  dname, dtime, droom : string;
begin
  //listgrid.Perform(WM_SETREDRAW, 0, 0);   // begineupdate
  try
    ClearGrid;
    with listgrid do
    begin
      RowCount := 2;

      dname := '�̸�' + Const_Char_Arrow_UPDown;
      droom := '�����' + Const_Char_Arrow_UPDown;
      dtime := 'Ȯ���ð�' + Const_Char_Arrow_UPDown;
      case FSortType of
        Sort_Name_Ascending   : dname := '�̸�' + Const_Char_Arrow_Down;
        Sort_Name_Descending  : dname := '�̸�' + Const_Char_Arrow_UP;
        Sort_Time_Ascending   : dtime := '�ð�' + Const_Char_Arrow_Down;
        Sort_Room_Ascending   : droom := '�����' + Const_Char_Arrow_Down;
        Sort_Room_Descending  : droom := '�����' + Const_Char_Arrow_UP;
      else // Sort_time_Descending  :
        dtime := 'Ȯ���ð�' + Const_Char_Arrow_UP;
      end;
//      str := Grid_Head_���� + ',"' + dname + '","' + droom + '",' + Grid_Head_����_�ֹ� + ','+ Grid_Head_��������+ ',"' + dtime + '",' + Grid_Head_����;
//      Rows[ 0 ].CommaText := str;
        str := Grid_Head_����+ ',' + Grid_Head_���� + ',' + Grid_Head_ȯ������ +',' + dname + ',"' + droom + '",' + Grid_Head_����_�ֹ� + ','+ Grid_Head_��������+ ',' + dtime ;
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

//      if GetRREnv.ShowOptionSymptom then
//      begin
//        if ColWidths[FDrawGrid.Col_Index_Symptom] = -1 then
//          ColWidths[FDrawGrid.Col_Index_Symptom] := Col_Width_Symptom_RR;
//      end
//      else
//        ColWidths[FDrawGrid.Col_Index_Symptom] := -1;

     (* if GetRREnv.ShowOptionReservationTime then
      begin
        if ColWidths[FDrawGrid.Col_Index_Time2] = -1 then
          ColWidths[FDrawGrid.Col_Index_Time2] := Col_Width_Time2_RR;
      end
      else
        ColWidths[FDrawGrid.Col_Index_Time2] := -1;
        ȯ�漳������ ����ð� üũ ������ ȯ�� ����Ʈ �������ʾ� ���ó��- �� ���� ���� Ȯ�� *)
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
    //listgrid.Perform(WM_SETREDRAW, 1, 0);   // endupdate
    listgrid.Invalidate;
  end;
end;

procedure TReceptionForm.ShowPanel(AParentControl: TWinControl);
begin
  if Assigned( AParentControl ) then
  begin
    ec_btn.PngImageList := ImageResourceDM.ExpandCollapseButtonImageList;
    ImageResourceDM.SetButtonImage(ec_btn, aibtButton1, BTN_Img_����);
    ImageResourceDM.SetButtonImage(ec_btn, aibtButton2, BTN_Img_���);

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

procedure TReceptionForm.StatusChangeNotify(AData: TRnRData;
  ANewStatus: TRnRDataStatus; var AClosed: Boolean);
  function StatusChange : Boolean;
  var // ���� ����
    event_109 : TBridgeResponse_109;
  begin
    Result := False;
    with RnRDM do
    begin
      try
        if not FindRR( AData ) then
          exit; // �� ã�Ҵ�.

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
            AddExceptionLog('TRnRForm.StatusChangeNotify : ', e);
            GDMessageDlg(format('�۾� �� Error�� �߻� �Ͽ����ϴ�'+#13#10+ '(%s,%s)',[e.Message, e.ClassName]), mtError, [mbOK], 0);
          end;
        end;
      finally
        FObserver.AfterActionASync(OB_Event_DataRefresh);
      end;
    end; // with
  end;

//  function CancelStatus : Boolean;
//  var // ���
//    form : TSelectCancelMSGForm;
//    event_103 : TBridgeResponse_103;
//  begin
//    Result := False;
//    with RnRDM do
//    begin
//      if not FindRR( AData ) then
//        exit; // �� ã�Ҵ�.
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
  var // ���
    event_103 : TBridgeResponse_103;
  begin
    Result := False;
    with RnRDM do
    begin
      if not FindRR( AData ) then
        exit; // �� ã�Ҵ�.

      if not ConfirmMessage( ANewStatus, Self.Handle ) then
        exit;

      FObserver.BeforeAction(OB_Event_DataRefresh);
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
        FObserver.AfterActionASync(OB_Event_DataRefresh);
      end;
    end;
  end;


begin
  case ANewStatus of
    rrs������,
    rrs����Ȯ��,
    rrs��������,
    rrs������û,
    rrs����Ϸ� : AClosed := StatusChange;
    rrs�������,
    rrs�������,
    rrs��ҿ�û : AClosed := CancelStatus;
  end;
end;

procedure TReceptionForm.VisibleGridButton(AVisible: Boolean);
// grid�� ��µǾ� �ִ� ��� button���� visible���� ������ ������ ���� �Ѵ�.
var
  i : Integer;
  dd : TDispData;
begin
  listgrid.Perform(WM_SETREDRAW, 0, 0);   // begineupdate
  try
    // grid���� ��µǾ� �ִ� control���� �Ⱥ��̰� ó�� �Ѵ�.
    for i := 0 to listgrid.RowCount -1 do
    begin
      dd := TDispData( listgrid.Objects[Col_Index_Data, i] );
      if Assigned( dd ) then
      begin
        dd.Button_����Ϸ�.Visible := False;
//        dd.Button_������û.Visible := False;
//        dd.Button_����Ȯ��.Visible := False;
      end;
    end;
  finally
    listgrid.Perform(WM_SETREDRAW, 1, 0);   // endupdate
    listgrid.Invalidate;
  end;
end;

initialization
  GReceptionForm := nil;

finalization

end.