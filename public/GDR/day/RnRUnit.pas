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
    Button_Ȯ�� : TSakpungImageButton2;
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
    FLastMouseDownRow : Integer; // grid���� mousedown�� row�� ��ġ�� ���� �Ѵ�.

    FButtonEnabled : Boolean;

    LastScrollPos : Integer;

    procedure SetGridUI;  // grid�� �ʱ� UI�� ���� �Ѵ�.
    function FindObject4Grid( AObj : TObject; var ARow, ATag : Integer ) : TDispData;  // aobj�� �ش��ϴ� row�� grid���� ã�� ���� data�� ��ȯ �Ѵ�.
    procedure RefreshData; // list�� data�� ��� �Ѵ�.  �ֱ������� ��� �Ѵ�.
    procedure NotifyEvent; // ����/���� ��Ȯ�� data notify
    function CheckFilterData : Boolean; // filter�� ���� ���� check�Ѵ�. true�̸� ��� ����̴�.
    procedure ClearGrid;
    // grid�� ��µǾ� �ִ� ��� button���� visible���� ������ ������ ���� �Ѵ�.
    procedure VisibleGridButton( AVisible : Boolean = False );

    procedure ButtonClickEvent( ASender : TObject ); // Ȯ�� button click�� �߻��ϴ� event
    procedure ButtonClickEventThread( ASender : TObject ); // Ȯ�� button click�� �߻��ϴ� event

    // �� ��ȸ���¿��� ���� ���� event �߻��� ó��
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
        RefreshData; // grid�� list�� ���� �Ѵ�
      end);
    // �´�: ��Ȯ�� ���� �˸� �˾� ���� ��û
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

          if ret = 1109 then     //��ŷ ���� ����
            begin
              Label2.Font.Color := clRed;
              Label2.Caption := '��ŷ ���� ����! ��Ʈ �� �´��� Ȯ�� ���ּ���';
            end
          else if ret = 1111 then   // Ÿ�����μ��� ����
            begin
              Label2.Font.Color := clRed;
              Label2.Caption := '��ŷ ���� ����! ��Ʈ �� �´��� Ȯ�� ���ּ���';
            end
          else if ret = 0 then  // ����
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

          if ret = 1109 then     //��ŷ ���� ����
            begin
              Label2.Font.Color := clRed;
              Label2.Caption := '��ŷ ���� ����! ��Ʈ �� �´��� Ȯ�� ���ּ���';
            end
          else if ret = 1111 then   // Ÿ�����μ��� ����
            begin
              Label2.Font.Color := clRed;
              Label2.Caption := '��ŷ ���� ����! ��Ʈ �� �´��� Ȯ�� ���ּ���';
            end
          else if ret = 0 then  // ����
            begin
             Label2.Caption := '';
            end;

end;


procedure TRnRForm.all_checkClick(Sender: TObject);
begin
  FObserver.BeforeAction(OB_Event_DataRefresh_RR);
  try
    all_check.ClicksDisabled := true;
    reservation_check.ClicksDisabled := true;  // data ������ click event�� �߻���Ű�� �ʰ� �Ѵ�
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
      begin // ����/����/��� Ŭ��
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
begin // Ȯ�� button click�� �߻��ϴ� event
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
        exit; // �� ã�Ҵ�.

      if data.RoomInfo.RoomCode = '' then
      begin // room�� ���õǾ� ���� �ʴ�. room�� ���� �ϰ� �Ѵ�.
        if RnRDM.RoomFilterButtonVisible then
        begin  // 2�� �̻��� ����� ������ �ִ�.
          if ShowRoomSelect( RoomInfo ) <> mrOk then
            exit; // room�� �������� �ʾҴ�.
        end
        else
        begin  // �Ѱ��̸� room ������ �о �����ϰ� �Ѵ�.
          if not RnRDM.GetFirstRoomInfo( RoomInfo ) then
            exit; // room ������ ����., ó�� ���� �ʴ´�.
        end;
      end;

      // �ֹι�ȣ��������
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
          status := rrs�����Ϸ�
        else
          status := rrs����Ϸ�;

        if data.RoomInfo.RoomName = '' then
        begin // room�� �������� �ʴ� data�� update�� �� �� �ְ� �Ѵ�.
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

            // chart hooking ��� ���� ��� ��Ʈ�� ����
{$IFNDEF DEBUG}
            if GetOCSHookLoader.OCSType <> TOCSType.None then
            begin
              if GetOCSHookLoader.isOCSHookDLLLoad then
                InsertPatientToOCS(copydata)
              else
                AddLog( doRunLog, format('�ܷ���Ʈ ���� ����. OCSType: %d', [Ord(GetOCSHookLoader.OCSType)]));
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
          GDMessageDlg(format('�۾� �� Error�� �߻� �Ͽ����ϴ�'+#13#10+ '(%s,%s)',[e.Message, e.ClassName]), mtError, [mbOK], 0);
        end;
      end;
    finally
      FreeAndNil( copydata );
      FObserver.AfterAction(OB_Event_DataRefresh_RR);
    end;
  end;
end;

procedure TRnRForm.ButtonClickEventThread(ASender: TObject);
var OtherForm: TRnRDMUnitProgress; // �ٸ� ���� �ν��Ͻ� ����
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
      ShowGDMsgDlg( '����ó�� �Էµ��� �ʾҽ��ϴ�.', GetTransFormHandle, mtWarning, [mbOK] );
      exit;
    end;


  if CheckPhonelength <= 9 then
    begin
      ShowGDMsgDlg( '����ó�� 9�� �̸��Դϴ�.', GetTransFormHandle, mtWarning, [mbOK] );
      exit;
    end;


  if CheckPhonelength > 11 then
    begin
      ShowGDMsgDlg( '����ó�� 12�� �ʰ��Դϴ�.', GetTransFormHandle, mtWarning, [mbOK] );
      exit;
    end;

  FButtonEnabled := False;


 // TThread.CreateAnonymousThread( procedure begin ButtonClickEvent(ASender); FButtonEnabled := True end ).Start;

  //Ȯ����ư�� ���α׷��� bar �߰��ϴ� �ڵ�
  TThread.CreateAnonymousThread(
   procedure

    begin

    TThread.Synchronize(nil,
      procedure

      begin
      if not FButtonEnabled then


        begin
        ButtonClickEvent(ASender);

          OtherForm := TRnRDMUnitProgress.Create(nil); // ���α׷���  �ν��Ͻ� ����
          try
            // ���� ���� ���� �� ó�� �۾� ����
            OtherForm.ShowModal; // ���α׷���  ���� ��޷� ǥ��
          finally
            OtherForm.Free; // ���α׷���  �ν��Ͻ� ����
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
  begin  // ��ü data
    exit;
  end;

  with RnRDM do
  begin
    statusfilter := [];
    statuscode := TRRDataTypeConvert.DataStatus2RnRDataStatus( RR_DB.FieldByName('status').AsInteger );

    if reception_check.Checked then
    begin
      Include(statusfilter, rrsUnknown);
      Include(statusfilter, rrs������û);
    end;

    if reservation_check.Checked then
    begin
      Include(statusfilter, rrs�����û);
    end;

    if cancel_check.Checked then
    begin
      Include(statusfilter, rrs��������);
      Include(statusfilter, rrs�������);

      if RR_DB.FieldByName( 'hsptlreceptndttm' ).AsDateTime = 0 then
      begin
        Include(statusfilter, rrs�������);
        Include(statusfilter, rrs�������);
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
  ClearGrid;  // grid�� ��ϵǾ� �ִ� object ����

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
      if AObj = rowdata.Button_Ȯ�� then
      begin
        ARow := i;
        ATag := rowdata.Button_Ȯ��.Tag;
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
    Result := 0; // ���� ó��
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
    exit; // ��� data�� ����.

  workrect := s.CellRect(FDrawGrid.Col_Index_Button1, ARow);
  r1 := s.CellRect(FDrawGrid.Col_Index_Button2, ARow);
  workrect := TRect.Union(workrect, r1);
  workrect.Right := workrect.Right -1;
  workrect.Left := workrect.Left -1;


  if rowdata.Canceled then
    begin // ��� data
      rowdata.Button_Ȯ��.Visible := False;
      FDrawGrid.DrawCenterText(s, workrect, '-' );
    end
  else
  if CurrentScrollPos >= 30 then
    begin
    rowdata.Button_Ȯ��.Visible := False;
    //FDrawGrid.DrawCenterText(s, workrect, '-' );
    end
  else
  begin
    r1.Left := workrect.Left + ( ((workrect.Right - workrect.Left) - rowdata.Button_Ȯ��.Width) div 2);
    if workrect.Left > r1.Left then
      r1.Left := workrect.Left;
    r1.Right := r1.Left + rowdata.Button_Ȯ��.Width;

    if (workrect.Bottom - workrect.Top) > rowdata.Button_Ȯ��.Height then // cell ������ button ǥ�ð� ������ �������� check�Ѵ�.
      r1.top := workrect.Top + ( ((workrect.Bottom - workrect.Top) - rowdata.Button_Ȯ��.Height) div 2) // �����ϸ�
    else
      r1.Top := workrect.Top; // �Ұ����ϸ�

    r1.Bottom := r1.Top + rowdata.Button_Ȯ��.Height;

    rowdata.Button_Ȯ��.BoundsRect := r1;
    rowdata.Button_Ȯ��.Visible := True;
  end;

end;

procedure TRnRForm.listgridFixedCellClick(Sender: TObject; ACol, ARow: Integer);    //�����׸� �������� ��������
begin
  if not (ACol in [FDrawGrid.Col_Index_PatientName, FDrawGrid.Col_Index_Room, FDrawGrid.Col_Index_Time]) then    //FDrawGrid.Col_Index_Time2 ����ð� ����
    exit;

  FObserver.BeforeAction( OB_Event_DataRefresh_RR );
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
    if FLastMouseDownRow = 0 then // col�� resize�Ǿ��ų� sort ���°� ����Ȱ����� ���� �Ѵ�.
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
// ����/���� ��Ȯ�� data notify
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
      while not RR_DB.Eof do // state�� rrsRequest�� data�� ��� ��� �Ѵ�.
      begin
        try
          // ���� ���� ����/���� data�� ǥ�� �ؾ� �Ѵ�.
          if not CheckToday( RR_DB.FieldByName( 'receptiondttm' ).AsDateTime ) then
            Continue; // ���� ��û data�� �ƴϴ�.

            statuscode := TRRDataTypeConvert.DataStatus2RnRDataStatus(RR_DB.FieldByName( 'status' ).AsInteger);
            status := TRRDataTypeConvert.Status4App( statuscode, RR_DB.FieldByName( 'hsptlreceptndttm' ).AsDateTime );

            if status <> csa��û then
              continue;
  (*
            if not (status in [csa��û, csa��û���]) then // ��û ���� data�� ���� �ϰ� �Ѵ�.
              Continue; // ��û���°� �ƴϸ� ó�� ���� �ʴ´�.

            if TRRDataTypeConvert.CheckCancelStatus( statuscode ) then
              continue; // ��� data�� step 0���� ó�� �Ѵ�. *)

            if TRnRType( RR_DB.FieldByName( 'datatype' ).AsInteger ) = rrReception  then
              Inc( receptcount ) // ���� ����
            else
              Inc( reservecount );  // ���� ����
        finally
          RR_DB.Next;
        end;
      end;
    end;
  finally
    RnRDM.RRTableLeave;
  end;

//  // ����/���� ��ó�� �˸� (�����û.������û �˸��˾��ΰŰ���)
//  if ( receptcount <> 0) or (reservecount <> 0) then
//    ShowRRNoticeForm( receptcount, reservecount ) // ó�� ����� �ִ�.
//  else
//    CloseRRNoticeForm; // ó�� ����� ����. form�� ���� ��Ų��.
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
      // sort��Ȳ�� ���� index���� �����ؾ� �Ѵ�.
      case FSortType of
        Sort_Name_Ascending   : RR_DB.IndexName := 'nameIndex'; // ȯ�� �̸� ��
        Sort_Name_Descending  : RR_DB.IndexName := 'nameIndexdesc'; // ȯ�� �̸� ����
        Sort_Time_Ascending   : RR_DB.IndexName := 'visitIndex'; // 'receptionIndex'; // ���� �ð� ��
        Sort_Room_Ascending   : RR_DB.IndexName := 'roomIndex'; // ����Ǽ�
        Sort_Room_Descending  : RR_DB.IndexName := 'roomIndexdesc'; // ����� ����
      else // Sort_time_Descending  :
        RR_DB.IndexName := 'visitIndexdesc'; //'receptionIndexdesc'; // �湮 �ð� ����
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
          try
            // ���� ���� ����/���� data�� ǥ�� �ؾ� �Ѵ�.
            if not CheckToday( RR_DB.FieldByName( 'receptiondttm' ).AsDateTime ) then
              Continue; // ���� ��û data�� �ƴϴ�.

            statuscode := TRRDataTypeConvert.DataStatus2RnRDataStatus(RR_DB.FieldByName( 'status' ).AsInteger);
            status := TRRDataTypeConvert.Status4App( statuscode, RR_DB.FieldByName( 'hsptlreceptndttm' ).AsDateTime );

            if not (status in [csa��û, csa��û���]) then // ��û ���� data�� ���� �ϰ� �Ѵ�.
              Continue; // ��û���°� �ƴϸ� ó�� ���� �ʴ´�.

            if step = 0 then
            begin
              if TRRDataTypeConvert.CheckCancelStatus( statuscode ) then
                continue; // ��� data�� step 0���� ó�� �Ѵ�.

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
            GetReceptionReservationData( rowdata );

            rowdata.Button_Ȯ�� := TSakpungImageButton2.Create(listgrid);
            rowdata.Button_Ȯ��.Visible := False;
            rowdata.Button_Ȯ��.Parent := listgrid;
            rowdata.Button_Ȯ��.Tag := Index_tag_Ȯ��;
            rowdata.Button_Ȯ��.PngImageList := ImageResourceDM.ButtonImageList;
            ImageResourceDM.SetButtonImage(rowdata.Button_Ȯ��, aibtButton1, BTN_Img_Ȯ��);
            //rowdata.Button_Ȯ��.OnClick := ButtonClickEvent;
            rowdata.Button_Ȯ��.OnClick := ButtonClickEventThread;

            newList.Add( rowdata.GetChartReceptnResultId );

            Inc( rowindex, 1);
            listgrid.RowCount := rowindex + 1;
            listgrid.Rows[ rowindex ].CommaText := '" "," "," "," "," "," "," "'; // ��� ������ drawcell���� draw�� �׸���.
            listgrid.Objects[Col_Index_Data, rowindex] := rowdata;

            if not isNewAdd then
              isNewAdd := not oldList.Find(rowdata.GetChartReceptnResultId, index);
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

  Label1.Caption := Format('���� ��û (%d��)',[cnt]);

  if isNewAdd then
  begin  // �űԷ� �߰��� data�� �ִ�.
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
        continue; // room code�� ��� �ϰ��� ó�� �Ҽ� ����.
      if not RnRDM.FindRR( data ) then
        Continue; //  ��ã�Ҵ�.  ó�� ���� �ʴ´�.

      if not (data.Status in [rrs�����û, rrs������û]) then
        continue; //����/���� ��û data�� �ƴϴ�.

      Inc( Result );
    end;
  end;
var
  i, cnt : Integer;
  status : TRnRDataStatus;
  data : TDispData;

  event_109 : TBridgeResponse_109;
begin
  cnt := countDecide; // Ȯ�� ��� data�� ������ ��� �Ѵ�.
  if cnt <= 0 then
    exit;

  if ShowGDMsgDlg( format('%d���� ����/���� ��û�� Ȯ���Ͻðڽ��ϱ�?',[cnt]), Application.MainForm, mtConfirmation, [mbYes, mbNo]) <> mrYes then
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
        continue; // room code�� ��� �ϰ��� ó�� �Ҽ� ����.

      if not (data.Status in [rrs�����û, rrs������û]) then
        continue; //����/���� ��û data�� �ƴϴ�.

      listgrid.Row := i;

      with RnRDM do
      begin
        if not FindRR( data ) then
          Continue; // �� ã�Ҵ�.

        if data.DataType = rrReception then
          status := rrs�����Ϸ�
        else
          status := rrs����Ϸ�;

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
            ShowGDMsgDlg( format('�۾� �� Error�� �߻� �Ͽ����ϴ�'+#13#10+ '(%s,%s)',[e.Message, e.ClassName]), Application.MainForm, mtError, [mbOK]);
            exit;
          end;
        end;
      end;
    end;
  finally
    FObserver.AfterActionASync(OB_Event_DataRefresh);
  end;

  ShowGDMsgDlg( format('%d���� ����/���� ��û �����͸� ó�� �Ͽ����ϴ�.',[cnt]), Application.MainForm, mtInformation, [mbOK]);
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

      dname := '�̸�' + Const_Char_Arrow_UPDown;
      droom := '�����' + Const_Char_Arrow_UPDown;
      dtime := '��û�ð�' + Const_Char_Arrow_UPDown;
      case FSortType of
        Sort_Name_Ascending   : dname := '�̸�' + Const_Char_Arrow_Down;
        Sort_Name_Descending  : dname := '�̸�' + Const_Char_Arrow_UP;
        Sort_Time_Ascending   : dtime := '��û�ð�' + Const_Char_Arrow_Down;
        Sort_Room_Ascending   : droom := '�����' + Const_Char_Arrow_Down;
        Sort_Room_Descending  : droom := '�����' + Const_Char_Arrow_UP;
      else // Sort_time_Descending  :
        dtime := '��û�ð�' + Const_Char_Arrow_UP;
      end;
      //dtime2 := '����ð�';
      str := Grid_Head_����+ ',' + Grid_Head_���� + ',' + Grid_Head_ȯ������ +',' + dname + ',"' + droom + '",' + Grid_Head_����_�ֹ� + ','+ Grid_Head_��������+ ',"' + dtime ;
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
    ImageResourceDM.SetButtonImage(ec_btn, aibtButton1, BTN_Img_����);
    ImageResourceDM.SetButtonImage(ec_btn, aibtButton2, BTN_Img_���);

    filter_btn.PngImageList := ImageResourceDM.ButtonImageList24x24;
    ImageResourceDM.SetButtonImage(filter_btn, aibtButton1, BTN_Img_Filter_Off);
    ImageResourceDM.SetButtonImage(filter_btn, aibtButton2, BTN_Img_Filter_On);

    Panel1.Parent := AParentControl;
    Panel1.Align := alClient;

    filter_btn.Visible := RnRDM.RoomFilterButtonVisible;

    /// V4������ ���� ��� ����
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

              // chart hooking ��� ���� ��� ��Ʈ�� ����
{$IFNDEF DEBUG}
              if GetOCSHookLoader.OCSType <> TOCSType.None then
              begin
                if GetOCSHookLoader.isOCSHookDLLLoad then
                  InsertPatientToOCS(AData)
                else
                  AddLog( doRunLog, format('�ܷ���Ʈ ���� ����. OCSType: %d', [Ord(GetOCSHookLoader.OCSType)]));
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
    rrs����Ϸ�,
    rrs�����Ϸ� : AClosed := StatusChange;
    rrs�������,
    rrs�������� : AClosed := CancelStatus;
    rrs�����Ϸ�_new : AClosed := StatusChange;
  end;
end;

procedure TRnRForm.VisibleGridButton(AVisible: Boolean);
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
        dd.Button_Ȯ��.Visible := False;
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

  AddLog( doRunLog, '���� ó�� : ' + IntToStr(patientdata.unID) );
  ret := ocshook.InsertPatient( pdata );
  AddLog( doRunLog, '���� ó�� ��� : ' + IntToStr(ret) );

  if ret = 0 then
  begin
    // ��û ����. data lock

  end
  else
  begin
    // ��û ����
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
  Button_Ȯ�� := nil;
end;

destructor TDispData.Destroy;
begin
  if Assigned(Button_Ȯ��) then
  begin
    Button_Ȯ��.Parent := nil;
    FreeAndNil( Button_Ȯ�� );
  end;

  inherited;
end;

initialization
  GRnRForm := nil;

finalization

end.