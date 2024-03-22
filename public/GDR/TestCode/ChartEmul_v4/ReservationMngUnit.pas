unit ReservationMngUnit;
//  C07(���� ���), C08(������), F05(���� �Ϸ�)
//  C04(���� ���� ���)??
// F06 ���� ���
interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.Grids, Vcl.DBGrids,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.DBCtrls, MemDS, DBAccess, LiteAccess,
  DBDMUnit, BridgeCommUnit,GlobalUnit, Vcl.Menus;

type
  TReservationMngForm = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    DBNavigator1: TDBNavigator;
    Button1: TButton;
    DBGrid1: TDBGrid;
    DataSource1: TDataSource;
    LiteQuery1: TLiteQuery;
    purposeTable: TLiteTable;
    patient: TLiteTable;
    Panel3: TPanel;
    Button2: TButton;
    PopupMenu1: TPopupMenu;
    Button4: TButton;
    N2: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    reception: TLiteTable;
    N1: TMenuItem;
    processQuery: TLiteQuery;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure N7Click(Sender: TObject);
    procedure Button4MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure LiteQuery1AfterOpen(DataSet: TDataSet);
    procedure LiteQuery1BeforeClose(DataSet: TDataSet);
    procedure DataSource1DataChange(Sender: TObject; Field: TField);
    procedure LiteQuery1AfterPost(DataSet: TDataSet);
    procedure LiteQuery1BeforeEdit(DataSet: TDataSet);
    procedure N1Click(Sender: TObject);
  private
    { Private declarations }
    procedure openprocessquery;
  public
    { Public declarations }
    procedure ChangeUI( AParentCtrl : TWinControl );

    // ����
    function AddReservation( AReceptionData : TBridgeResponse_200 ) : TBridgeRequest_201; overload;
    procedure AddReservation( AReservationCancelData : TData307; var APatientChartID : string; var ResultCode: integer ); overload;

    // ���� ���
    function CancelReservation( AReservationCancelData : TBridgeResponse_202 ) : TBridgeRequest_203; overload;
    procedure CancelReservation( AReservationCancelData : TData307; var APatientChartID : string; var ResultCode: integer ); overload;

    procedure AddReception( ADataQuery : TLiteQuery );

    procedure DBRefresh;
  end;

var
  ReservationMngForm: TReservationMngForm;

implementation
uses
  GDBridge,
  RoomListDialogUnit, ReceptionMngUnit,
  ChartEmul_v4Unit;

{$R *.dfm}

{ TReceptionMngForm }

procedure TReservationMngForm.AddReception(ADataQuery: TLiteQuery);
var // ���� ���
  d : TDateTime;
  chartrrid1 : string;
  pid : string;
  event_108 : TBridgeRequest_108;
  responsebase : TBridgeResponse;
  ret : string;
begin
  if not Assigned( ADataQuery ) then
    exit;

  GSendReceptionPeriodRoomInfo.RoomCode := ADataQuery.FieldByName('roomcode').AsString;
  GSendReceptionPeriodRoomInfo.RoomName := ADataQuery.FieldByName('roomname').AsString;
  GSendReceptionPeriodRoomInfo.DeptCode := ADataQuery.FieldByName('deptcode').AsString;
  GSendReceptionPeriodRoomInfo.DeptName := ADataQuery.FieldByName('deptname').AsString;
  GSendReceptionPeriodRoomInfo.DoctorCode := ADataQuery.FieldByName('doctorcode').AsString;
  GSendReceptionPeriodRoomInfo.DoctorName := ADataQuery.FieldByName('doctorname').AsString;

  pid := DBDM.FindPatient_RegNum( ADataQuery.FieldByName('regnum').AsString );
  if pid = '' then
  begin // �ű� ȯ�� �̴�.
    pid := ADataQuery.FieldByName( 'chartid' ).AsString;
    if pid = '' then
      pid := 'P' + FormatDateTime('yyyymmddhhnnsszzz', now);

    patient.Active := True;
    try
      with patient do
      begin
        Append;
        FieldByName( 'chartid' ).AsString := pid;
        FieldByName( 'name' ).AsString := ADataQuery.FieldByName('name').AsString;
        FieldByName( 'cellphone' ).AsString := ADataQuery.FieldByName('cellphone').AsString;
        FieldByName( 'regnum' ).AsString := ADataQuery.FieldByName('regnum').AsString;
        FieldByName( 'sex' ).AsInteger := StrToIntDef( ADataQuery.FieldByName('sex').AsString, 1);
        FieldByName( 'birthday' ).AsString := ADataQuery.FieldByName('birthday').AsString;
        FieldByName( 'addr' ).AsString := ADataQuery.FieldByName('addr').AsString;
        FieldByName( 'addrdetail' ).AsString := ADataQuery.FieldByName('addrdetail').AsString;
        FieldByName( 'zip' ).AsString := ADataQuery.FieldByName('zip').AsString;
        Post;
      end;
      ChartEmulV4Form.AddMemo( format('%s �ֹ� ��ȣ�� �ű� ȯ�� �Դϴ�. ��Ʈ id %s�� �߰� �Ǿ����ϴ�.', [ADataQuery.FieldByName('regnum').AsString, pid]) );
    finally
      patient.Active := False;
    end;
  end
  else
  begin
    ChartEmulV4Form.AddMemo( format('%s �ֹ� ��ȣ�� ��Ʈ id %s�� �����ϴ� ȯ�� �Դϴ�.', [pid, ADataQuery.FieldByName( 'chartid' ).AsString]) );
  end;

  chartrrid1 := FormatDateTime('yyyymmddhhnnsszzz', now);
  ADataQuery.Edit;
    ADataQuery.FieldByName( 'receptionid' ).AsString := chartrrid1;
  ADataQuery.Post;

  // ���� ���
  reception.Active := True;
  try
    reception.Append;
    with reception do
    begin
      FieldByName( 'chartrrid1' ).AsString := chartrrid1;
      FieldByName( 'chartrrid2' ).AsString := '';
      FieldByName( 'chartrrid3' ).AsString := '';
      FieldByName( 'chartrrid4' ).AsString := '';
      FieldByName( 'chartrrid5' ).AsString := '';
      FieldByName( 'chartrrid6' ).AsString := '';
      FieldByName( 'chartid' ).AsString := pid;

      FieldByName( 'roomcode' ).AsString := GSendReceptionPeriodRoomInfo.RoomCode;
      FieldByName( 'roomname' ).AsString := GSendReceptionPeriodRoomInfo.RoomName;
      FieldByName( 'deptcode' ).AsString := GSendReceptionPeriodRoomInfo.DeptCode;
      FieldByName( 'deptname' ).AsString := GSendReceptionPeriodRoomInfo.DeptName;
      FieldByName( 'doctorcode' ).AsString := GSendReceptionPeriodRoomInfo.DoctorCode;
      FieldByName( 'doctorname' ).AsString := GSendReceptionPeriodRoomInfo.DoctorName;
      FieldByName( 'etcpurpose' ).AsString := ADataQuery.FieldByName( 'etcpurpose' ).AsString;

      d := now;
      FieldByName( 'receptiondate' ).AsString := FormatDateTime('yyyy-mm-dd',d);
      FieldByName( 'receptiontime' ).AsString := FormatDateTime('hh:nn',d);
      FieldByName( 'status' ).AsString := Status_����Ȯ��;
      FieldByName( 'statusmng' ).AsString := Status_����Ȯ��;
      FieldByName( 'period' ).AsInteger := Const_Period_Send;
      FieldByName( 'endpoint' ).AsString := 'A';
      FieldByName( 'dummy' ).AsInteger := 0;
    end;
    reception.Post;
  finally
    reception.Active := False;
  end;

  event_108 := TBridgeRequest_108( GBridgeFactory.MakeRequestObj( EventID_��⿭���°����� ) );
  event_108.HospitalNo := GHospitalNo;
  event_108.ReceptionUpdateDto.chartReceptnResultId.Id1 := ADataQuery.FieldByName('chartrrid1').AsString;
  event_108.ReceptionUpdateDto.chartReceptnResultId.Id2 := ADataQuery.FieldByName('chartrrid2').AsString;
  event_108.ReceptionUpdateDto.chartReceptnResultId.Id3 := ADataQuery.FieldByName('chartrrid3').AsString;
  event_108.ReceptionUpdateDto.chartReceptnResultId.Id4 := ADataQuery.FieldByName('chartrrid4').AsString;
  event_108.ReceptionUpdateDto.chartReceptnResultId.Id5 := ADataQuery.FieldByName('chartrrid5').AsString;
  event_108.ReceptionUpdateDto.chartReceptnResultId.Id4 := ADataQuery.FieldByName('chartrrid6').AsString;

  event_108.ReceptionUpdateDto.RoomInfo.RoomCode := GSendReceptionPeriodRoomInfo.RoomCode;
  event_108.ReceptionUpdateDto.RoomInfo.RoomName := GSendReceptionPeriodRoomInfo.RoomName;
  event_108.ReceptionUpdateDto.RoomInfo.DeptCode := GSendReceptionPeriodRoomInfo.DeptCode;
  event_108.ReceptionUpdateDto.RoomInfo.DeptName := GSendReceptionPeriodRoomInfo.DeptName;
  event_108.ReceptionUpdateDto.RoomInfo.DoctorCode := GSendReceptionPeriodRoomInfo.DoctorCode;
  event_108.ReceptionUpdateDto.RoomInfo.DoctorName := GSendReceptionPeriodRoomInfo.DoctorName;
  event_108.ReceptionUpdateDto.Status   := Status_����Ȯ��; // Status_������;
  event_108.receptStatusChangeDttm     := now;

  event_108.NewchartReceptnResult.Id1 := chartrrid1;  // ������ ������ ���
  event_108.NewchartReceptnResult.Id2 := '';
  event_108.NewchartReceptnResult.Id3 := '';
  event_108.NewchartReceptnResult.Id4 := '';
  event_108.NewchartReceptnResult.Id5 := '';
  event_108.NewchartReceptnResult.Id6 := '';

  ChartEmulV4Form.AddMemo( event_108.EventID, event_108.JobID );
  ret := GetBridge.RequestResponse( event_108.ToJsonString );
  responsebase := GBridgeFactory.MakeResponseObj( ret );
  ChartEmulV4Form.AddMemo( responsebase.EventID, responsebase.JobID, responsebase.Code, responsebase.MessageStr, 0 );
  FreeAndNil( responsebase );

  // ���� ����
  ReceptionMngForm.UpdatePeriod(now, GSendReceptionPeriodRoomInfo.RoomCode);
  GSendReceptionPeriod := True;

  FreeAndNil( event_108 );
end;

function TReservationMngForm.AddReservation(
  AReceptionData: TBridgeResponse_200): TBridgeRequest_201;
var
  i : Integer;
  rid : Integer;
  d : tdatetime;
  pid, chartrrid1 : string;
  pitem : TPurposeListItem;
begin
  Result := TBridgeRequest_201( GBridgeFactory.MakeRequestObj(EventID_�����û���, AReceptionData.JobID ) );
  Result.Code := AReceptionData.AnalysisErrorCode;
  if AReceptionData.AnalysisErrorCode <> Result_Success then
  begin
    Result.MessageStr := GBridgeFactory.GetErrorString( AReceptionData.AnalysisErrorCode );
    exit;
  end;

  openprocessquery;
  try
    pid := DBDM.FindPatient_RegNum(AReceptionData.RegNum);
    if pid = '' then
    begin
      pid := AReceptionData.PatntChartID;
      if pid = '' then
        pid := 'P' + FormatDateTime('yyyymmddhhnnsszzz', now);

      //    ȯ�� �߰�
      patient.Active := True;
      try
        with patient do
        begin
          Append;
          FieldByName( 'chartid' ).AsString := pid;
          FieldByName( 'name' ).AsString := AReceptionData.PatntName;
          FieldByName( 'cellphone' ).AsString := AReceptionData.Cellphone;
          FieldByName( 'regnum' ).AsString := AReceptionData.RegNum;
          FieldByName( 'sex' ).AsInteger := StrToIntDef( AReceptionData.Sexdstn, 1);
          FieldByName( 'birthday' ).AsString := AReceptionData.Birthday;
          FieldByName( 'addr' ).AsString := AReceptionData.Addr;
          FieldByName( 'addrdetail' ).AsString := AReceptionData.AddrDetail;
          FieldByName( 'zip' ).AsString := AReceptionData.Zip;
          FieldByName( 'isfirst' ).AsInteger := 1;
          Post;
        end;
        ChartEmulV4Form.AddMemo( format('%s �ֹ� ��ȣ�� �ű� ȯ�� �Դϴ�. ��Ʈ id %s�� �߰� �Ǿ����ϴ�.', [AReceptionData.RegNum, pid]) );
      finally
        patient.Active := False;
      end;
    end
    else
    begin
      ChartEmulV4Form.AddMemo( format('%s �ֹ� ��ȣ�� ��Ʈ id %s�� �����ϴ� ȯ�� �Դϴ�.', [AReceptionData.RegNum, AReceptionData.PatntChartID]) );
    end;

    processQuery.Append;

    with processQuery do
    begin
      chartrrid1 := FormatDateTime('yyyymmddhhnnsszzz', now);
      FieldByName( 'chartrrid1' ).AsString := chartrrid1;
      FieldByName( 'chartrrid2' ).AsString := '';
      FieldByName( 'chartrrid3' ).AsString := '';
      FieldByName( 'chartrrid4' ).AsString := '';
      FieldByName( 'chartrrid5' ).AsString := '';
      FieldByName( 'chartrrid6' ).AsString := '';
      FieldByName( 'chartid' ).AsString := pid;

      FieldByName( 'name' ).AsString := AReceptionData.PatntName;
      FieldByName( 'cellphone' ).AsString := AReceptionData.Cellphone;
      FieldByName( 'regnum' ).AsString := AReceptionData.RegNum;
      FieldByName( 'sex' ).AsInteger := StrToIntDef( AReceptionData.Sexdstn, 1);
      FieldByName( 'birthday' ).AsString := AReceptionData.Birthday;
      FieldByName( 'addr' ).AsString := AReceptionData.Addr;
      FieldByName( 'addrdetail' ).AsString := AReceptionData.AddrDetail;
      FieldByName( 'zip' ).AsString := AReceptionData.Zip;

      FieldByName( 'roomcode' ).AsString := AReceptionData.RoomCode;
      FieldByName( 'roomname' ).AsString := AReceptionData.RoomName;
      FieldByName( 'deptcode' ).AsString := AReceptionData.DeptCode;
      FieldByName( 'deptname' ).AsString := AReceptionData.DeptName;
      FieldByName( 'doctorcode' ).AsString := AReceptionData.DoctorCode;
      FieldByName( 'doctorname' ).AsString := AReceptionData.DoctorName;
      FieldByName( 'etcpurpose' ).AsString := AReceptionData.EtcPurpose;

      d := AReceptionData.ReserveDttm;
      FieldByName( 'reservedate' ).AsString := FormatDateTime('yyyy-mm-dd',d);
      FieldByName( 'reservetime' ).AsString := FormatDateTime('hh:nn',d);
      FieldByName( 'status' ).AsString := Status_�����û;
      FieldByName( 'reservedttm' ).AsString := FormatDateTime('yyyy-mm-dd hh:nn:ss', AReceptionData.ReserveDttm );
      FieldByName( 'regdttm' ).AsString := FormatDateTime('yyyy-mm-dd hh:nn:ss', AReceptionData.RegistrationDttm );
    end;
    processQuery.Post;
    rid := processQuery.FieldByName( 'rid' ).AsInteger;

    //���� ������ ������ �߰� �Ѵ�
    purposeTable.Active := False;
    purposeTable.TableName := 'purpose';
    purposeTable.Active := True;
    try
      for i := 0 to AReceptionData.PurposeListCount -1 do
      begin
        pitem := AReceptionData.PurposeLists[ i ];
        purposeTable.Append;
        purposeTable.FieldByName('pid').AsInteger := i+1;
        purposeTable.FieldByName('rid').AsInteger := rid;
        purposeTable.FieldByName('rrtype').AsString := RRType_Reservation;
        purposeTable.FieldByName('purpose1').AsString := pitem.purpose1;
        purposeTable.FieldByName('purpose2').AsString := pitem.purpose2;
        purposeTable.FieldByName('purpose3').AsString := pitem.purpose3;
        purposeTable.Post;
      end;

    finally
      purposeTable.Active := False;
    end;

    Result.Code := Result_Success;
    Result.MessageStr := '';
    Result.HospitalNo := AReceptionData.HospitalNO;
    Result.PatntChartID := pid;
    Result.RegNum := AReceptionData.regNum;
    Result.chartReceptnResultId.Id1 := chartrrid1;
    Result.chartReceptnResultId.Id2 := '';
    Result.chartReceptnResultId.Id3 := '';
    Result.chartReceptnResultId.Id4 := '';
    Result.chartReceptnResultId.Id4 := '';
    Result.chartReceptnResultId.Id6 := '';

    Result.RoomInfo.RoomCode := AReceptionData.RoomCode;
    Result.RoomInfo.RoomName := AReceptionData.RoomName;
    Result.RoomInfo.DeptCode := AReceptionData.DeptCode;
    Result.RoomInfo.DeptName := AReceptionData.DeptName;
    Result.RoomInfo.DoctorCode := AReceptionData.DoctorCode;
    Result.RoomInfo.DoctorName := AReceptionData.DoctorName;
  finally
    processQuery.Active := False;
  end;
end;

procedure TReservationMngForm.AddReservation(AReservationCancelData: TData307;
  var APatientChartID: string; var ResultCode: integer);
var
  i : Integer;
  rid : Integer;
  d : tdatetime;
  chartrrid1 : string;
  pitem : TPurposeListItem;
  regnum : string;
begin
  ResultCode := Result_SuccessCode;
  APatientChartID := AReservationCancelData.PatntChartID;

  openprocessquery;
  try
    regnum := DBDM.FindPatient_RegNum(AReservationCancelData.RegNum);
    if regnum = '' then
    begin  // �ű� ȯ�� ó��
      if APatientChartID = '' then
        APatientChartID := 'P' + FormatDateTime('yyyymmddhhnnsszzz', now);

      // ȯ�� �߰�
      patient.Active := True;
      try
        with patient do
        begin
          Append;
          FieldByName( 'chartid' ).AsString := APatientChartID;
          FieldByName( 'name' ).AsString := AReservationCancelData.PatntName;
          FieldByName( 'cellphone' ).AsString := AReservationCancelData.Cellphone;
          FieldByName( 'regnum' ).AsString := AReservationCancelData.RegNum;
          FieldByName( 'sex' ).AsInteger := StrToIntDef( AReservationCancelData.Sexdstn, 1);
          FieldByName( 'birthday' ).AsString := AReservationCancelData.Birthday;
          FieldByName( 'addr' ).AsString := AReservationCancelData.Addr;
          FieldByName( 'addrdetail' ).AsString := AReservationCancelData.AddrDetail;
          FieldByName( 'zip' ).AsString := AReservationCancelData.Zip;
          FieldByName( 'isfirst' ).AsInteger := 1;
          Post;
        end;
        ChartEmulV4Form.AddMemo( format('%s �ֹ� ��ȣ�� �ű� ȯ�� �Դϴ�. ��Ʈ id %s�� �߰� �Ǿ����ϴ�.', [AReservationCancelData.RegNum, APatientChartID]) );
      finally
        patient.Active := False;
      end;
    end
    else
    begin
      ChartEmulV4Form.AddMemo( format('%s �ֹ� ��ȣ�� ��Ʈ id %s�� �����ϴ� ȯ�� �Դϴ�.', [AReservationCancelData.RegNum, APatientChartID]) );
    end;

    processQuery.Append;

    with processQuery do
    begin
      chartrrid1 := FormatDateTime('yyyymmddhhnnsszzz', now);
      FieldByName( 'chartrrid1' ).AsString := chartrrid1;
      AReservationCancelData.chartReceptnResultId.Id1 := chartrrid1;
      FieldByName( 'chartrrid2' ).AsString := '';
      FieldByName( 'chartrrid3' ).AsString := '';
      FieldByName( 'chartrrid4' ).AsString := '';
      FieldByName( 'chartrrid5' ).AsString := '';
      FieldByName( 'chartrrid6' ).AsString := '';
      FieldByName( 'chartid' ).AsString := APatientChartID;

      FieldByName( 'name' ).AsString := AReservationCancelData.PatntName;
      FieldByName( 'cellphone' ).AsString := AReservationCancelData.Cellphone;
      FieldByName( 'regnum' ).AsString := AReservationCancelData.RegNum;
      FieldByName( 'sex' ).AsInteger := StrToIntDef( AReservationCancelData.Sexdstn, 1);
      FieldByName( 'birthday' ).AsString := AReservationCancelData.Birthday;
      FieldByName( 'addr' ).AsString := AReservationCancelData.Addr;
      FieldByName( 'addrdetail' ).AsString := AReservationCancelData.AddrDetail;
      FieldByName( 'zip' ).AsString := AReservationCancelData.Zip;

      FieldByName( 'roomcode' ).AsString := AReservationCancelData.RoomInfo.RoomCode;
      FieldByName( 'roomname' ).AsString := AReservationCancelData.RoomInfo.RoomName;
      FieldByName( 'deptcode' ).AsString := AReservationCancelData.RoomInfo.DeptCode;
      FieldByName( 'deptname' ).AsString := AReservationCancelData.RoomInfo.DeptName;
      FieldByName( 'doctorcode' ).AsString := AReservationCancelData.RoomInfo.DoctorCode;
      FieldByName( 'doctorname' ).AsString := AReservationCancelData.RoomInfo.DoctorName;
      FieldByName( 'etcpurpose' ).AsString := AReservationCancelData.EtcPurpose;

      d := AReservationCancelData.ReserveDttm;
      FieldByName( 'reservedate' ).AsString := FormatDateTime('yyyy-mm-dd',d);
      FieldByName( 'reservetime' ).AsString := FormatDateTime('hh:nn',d);
      FieldByName( 'status' ).AsString := Status_�����û;
      FieldByName( 'reservedttm' ).AsString := FormatDateTime('yyyy-mm-dd hh:nn:ss', AReservationCancelData.ReserveDttm );
      FieldByName( 'regdttm' ).AsString := FormatDateTime('yyyy-mm-dd hh:nn:ss', AReservationCancelData.ReceptionDttm );
    end;
    processQuery.Post;
    rid := processQuery.FieldByName( 'rid' ).AsInteger;

    //���� ������ ������ �߰� �Ѵ�
    purposeTable.Active := False;
    purposeTable.TableName := 'purpose';
    purposeTable.Active := True;
    try
      for i := 0 to AReservationCancelData.PurposeListCount -1 do
      begin
        pitem := AReservationCancelData.PurposeLists[ i ];
        purposeTable.Append;
        purposeTable.FieldByName('pid').AsInteger := i+1;
        purposeTable.FieldByName('rid').AsInteger := rid;
        purposeTable.FieldByName('rrtype').AsString := RRType_Reservation;
        purposeTable.FieldByName('purpose1').AsString := pitem.purpose1;
        purposeTable.FieldByName('purpose2').AsString := pitem.purpose2;
        purposeTable.FieldByName('purpose3').AsString := pitem.purpose3;
        purposeTable.Post;
      end;

    finally
      purposeTable.Active := False;
    end;
  finally
    processQuery.Active := False;
  end;
end;

procedure TReservationMngForm.Button1Click(Sender: TObject);
begin
  if LiteQuery1.Active then
    LiteQuery1.Refresh
  else
  begin
    LiteQuery1.Active := False;
  //  LiteQuery1.SQL.Text := 'select * from reserve order by reservedttm desc, rid';
  //  LiteQuery1.SQL.Text := 'select * from reserve order by regdttm desc, rid';
    LiteQuery1.SQL.Text := 'select * from reserve order by rid desc, reservedttm';
    LiteQuery1.Active := True;
  end;
  initDBGridWidth( DBGrid1 );
  LiteQuery1.First;
end;

procedure TReservationMngForm.Button2Click(Sender: TObject);
var
  event_202 : TBridgeRequest_202;
  responsebase : TBridgeResponse;
  ret : string;
begin
  event_202 := TBridgeRequest_202( GBridgeFactory.MakeRequestObj(EventID_������� ) );
  event_202.HospitalNo := GHospitalNo;
  event_202.CancelMessage := '';
  event_202.chartReceptnResultId.Id1 := LiteQuery1.FieldByName('chartrrid1').AsString;
  event_202.chartReceptnResultId.Id2 := LiteQuery1.FieldByName('chartrrid2').AsString;
  event_202.chartReceptnResultId.Id3 := LiteQuery1.FieldByName('chartrrid3').AsString;
  event_202.chartReceptnResultId.Id4 := LiteQuery1.FieldByName('chartrrid4').AsString;
  event_202.chartReceptnResultId.Id5 := LiteQuery1.FieldByName('chartrrid5').AsString;
  event_202.chartReceptnResultId.Id6 := LiteQuery1.FieldByName('chartrrid6').AsString;

  event_202.RoomInfo.RoomCode := LiteQuery1.FieldByName('roomcode').AsString;
  event_202.RoomInfo.RoomName := LiteQuery1.FieldByName('roomname').AsString;
  event_202.RoomInfo.DeptCode := LiteQuery1.FieldByName('deptcode').AsString;
  event_202.RoomInfo.DeptName := LiteQuery1.FieldByName('deptname').AsString;
  event_202.RoomInfo.DoctorCode := LiteQuery1.FieldByName('doctorcode').AsString;
  event_202.RoomInfo.DoctorName := LiteQuery1.FieldByName('doctorname').AsString;
  event_202.receptStatusChangeDttm := now;

  GSendReceptionPeriodRoomInfo.RoomCode := LiteQuery1.FieldByName('roomcode').AsString;
  GSendReceptionPeriodRoomInfo.RoomName := LiteQuery1.FieldByName('roomname').AsString;
  GSendReceptionPeriodRoomInfo.DeptCode := LiteQuery1.FieldByName('deptcode').AsString;
  GSendReceptionPeriodRoomInfo.DeptName := LiteQuery1.FieldByName('deptname').AsString;
  GSendReceptionPeriodRoomInfo.DoctorCode := LiteQuery1.FieldByName('doctorcode').AsString;
  GSendReceptionPeriodRoomInfo.DoctorName := LiteQuery1.FieldByName('doctorname').AsString;

  LiteQuery1.Edit;
      LiteQuery1.FieldByName( 'status' ).AsString := Status_�������; // ���� ���
      //LiteQuery1.FieldByName( 'cancelmsg' ).AsString := event_202.CancelMessage;
  LiteQuery1.Post;

  ChartEmulV4Form.AddMemo( event_202.EventID, event_202.JobID );
  ret := GetBridge.RequestResponse( event_202.ToJsonString );
  responsebase := GBridgeFactory.MakeResponseObj( ret );
  ChartEmulV4Form.AddMemo( responsebase.EventID, responsebase.JobID, responsebase.Code, responsebase.MessageStr, 0 );
  FreeAndNil( responsebase );

  FreeAndNil( event_202 );
end;

procedure TReservationMngForm.Button4MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  PopupMenu1.Popup( Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

function TReservationMngForm.CancelReservation(
  AReservationCancelData: TBridgeResponse_202): TBridgeRequest_203;
begin
  Result := TBridgeRequest_203( GBridgeFactory.MakeRequestObj(EventID_������Ұ��, AReservationCancelData.JobID ) );
  Result.Code := AReservationCancelData.AnalysisErrorCode;
  if AReservationCancelData.AnalysisErrorCode <> Result_Success then
  begin
    Result.MessageStr := GBridgeFactory.GetErrorString( AReservationCancelData.AnalysisErrorCode );
    exit;
  end;
  Result.MessageStr := '';

  processQuery.Active := False;
  try
    with processQuery do
    begin
      SQL.Clear;
      SQL.Add( 'select * from reserve where ' );
      SQL.Add( 'chartrrid1 = :chartrrid1 and ' );
      SQL.Add( 'chartrrid2 = :chartrrid2 and ' );
      SQL.Add( 'chartrrid3 = :chartrrid3 and ' );
      SQL.Add( 'chartrrid4 = :chartrrid4 and ' );
      SQL.Add( 'chartrrid5 = :chartrrid5 and ' );
      SQL.Add( 'chartrrid6 = :chartrrid6 ' );
      ParamByName( 'chartrrid1' ).Value := AReservationCancelData.chartReceptnResultId.Id1;
      ParamByName( 'chartrrid2' ).Value := AReservationCancelData.chartReceptnResultId.Id2;
      ParamByName( 'chartrrid3' ).Value := AReservationCancelData.chartReceptnResultId.Id3;
      ParamByName( 'chartrrid4' ).Value := AReservationCancelData.chartReceptnResultId.Id4;
      ParamByName( 'chartrrid5' ).Value := AReservationCancelData.chartReceptnResultId.Id5;
      ParamByName( 'chartrrid6' ).Value := AReservationCancelData.chartReceptnResultId.Id6;
      Active := True;

      First;
      if Eof then
      begin
        Result.Code := Result_������ȣ����;
        Result.MessageStr := GBridgeFactory.GetErrorString( Result.Code );
        ChartEmulV4Form.AddMemo( format('%s ���� ��ȣ�� ã�� �� �����ϴ�.',[AReservationCancelData.chartReceptnResultId.Id1]) );
        exit;
      end;

      Edit;
        FieldByName( 'status' ).AsString := Status_�������;
        //FieldByName( 'cancelmsg' ).AsString := AReservationCancelData.CancelMessage;
      Post;
    end;
  finally
    processQuery.Active := False;
  end;
end;

procedure TReservationMngForm.CancelReservation(
  AReservationCancelData: TData307; var APatientChartID: string;
  var ResultCode: integer);
begin
  ResultCode := Result_SuccessCode;
  APatientChartID := AReservationCancelData.PatntChartID;

  processQuery.Active := False;
  try
    with processQuery do
    begin
      SQL.Clear;
      SQL.Add( 'select * from reserve where ' );
      SQL.Add( 'chartrrid1 = :chartrrid1 and ' );
      SQL.Add( 'chartrrid2 = :chartrrid2 and ' );
      SQL.Add( 'chartrrid3 = :chartrrid3 and ' );
      SQL.Add( 'chartrrid4 = :chartrrid4 and ' );
      SQL.Add( 'chartrrid5 = :chartrrid5 and ' );
      SQL.Add( 'chartrrid6 = :chartrrid6 ' );
      ParamByName( 'chartrrid1' ).Value := AReservationCancelData.chartReceptnResultId.Id1;
      ParamByName( 'chartrrid2' ).Value := AReservationCancelData.chartReceptnResultId.Id2;
      ParamByName( 'chartrrid3' ).Value := AReservationCancelData.chartReceptnResultId.Id3;
      ParamByName( 'chartrrid4' ).Value := AReservationCancelData.chartReceptnResultId.Id4;
      ParamByName( 'chartrrid5' ).Value := AReservationCancelData.chartReceptnResultId.Id5;
      ParamByName( 'chartrrid6' ).Value := AReservationCancelData.chartReceptnResultId.Id6;
      Active := True;

      First;
      if Eof then
      begin
        ResultCode := Result_������ȣ����;
        ChartEmulV4Form.AddMemo( format('%s ���� ��ȣ�� ã�� �� �����ϴ�.',[AReservationCancelData.chartReceptnResultId.Id1]) );
        exit;
      end;

      Edit;
        FieldByName( 'status' ).AsString := Status_�������;
        //FieldByName( 'cancelmsg' ).AsString := AReservationCancelData.CancelMessage;
      Post;
    end;
  finally
    processQuery.Active := False;
  end;
end;

procedure TReservationMngForm.ChangeUI(AParentCtrl: TWinControl);
begin
  if Assigned( AParentCtrl ) then
  begin
    Panel1.Parent := AParentCtrl;
    Panel1.Align := alClient;
  end
  else
    Panel1.Parent := Self;
end;

procedure TReservationMngForm.DataSource1DataChange(Sender: TObject;
  Field: TField);
var
  status : string;
begin
  if not Assigned( DataSource1.DataSet ) then
    exit;
  if not DataSource1.DataSet.Active then
    exit;

  if DataSource1.DataSet.State <> dsBrowse then
    exit;

  with DataSource1.DataSet do
  begin
    status := FieldByName( 'status' ).AsString;

(*    // ���, ���� ����
    if (status = Status_�����û) then
    begin
      Button2.Enabled := True;
      Button4.Enabled := True;
    end
    else
    begin
      Button2.Enabled := False;
      Button4.Enabled := status = Status_����Ϸ�;
    end;  *)

    Button4.Enabled := (status = Status_�����û) or (status = Status_����Ϸ�);
    //Button2.Enabled := status = Status_�����û;
    Button2.Enabled := (status = Status_�����û) or (status = Status_����Ϸ�);
    N2.Enabled := status = Status_�����û; // ���� �Ϸ� �޴�
    N1.Enabled := status = Status_����Ϸ�; // ���� ��� �޴�
  end;
end;

procedure TReservationMngForm.DBRefresh;
begin
  Button1.Click;
end;

procedure TReservationMngForm.LiteQuery1AfterOpen(DataSet: TDataSet);
begin
  Button2.Enabled := not DataSet.Eof;
  Button4.Enabled := Button2.Enabled;
end;

procedure TReservationMngForm.LiteQuery1AfterPost(DataSet: TDataSet);
begin
  DBGrid1.Options := [dgTitles,dgIndicator,dgColumnResize,dgColLines,dgRowLines,dgTabs,dgRowSelect,dgAlwaysShowSelection,dgConfirmDelete,dgCancelOnExit,dgTitleClick,dgTitleHotTrack];
end;

procedure TReservationMngForm.LiteQuery1BeforeClose(DataSet: TDataSet);
begin
  Button2.Enabled := False;
  Button4.Enabled := Button2.Enabled;
end;

procedure TReservationMngForm.LiteQuery1BeforeEdit(DataSet: TDataSet);
begin
  DBGrid1.Options := [dgEditing,dgTitles,dgIndicator,dgColumnResize,dgColLines,dgRowLines,dgTabs,dgConfirmDelete,dgCancelOnExit,dgTitleClick,dgTitleHotTrack];
end;

procedure TReservationMngForm.N1Click(Sender: TObject);
// ���� ���
begin
  if not ( Sender is TMenuItem ) then
    exit;

  AddReception( LiteQuery1 );
end;

procedure TReservationMngForm.N7Click(Sender: TObject);
var
//  d : TDateTime;
  statuscode : string;
//  chartrrid1 : string;
  event_108 : TBridgeRequest_108;
  responsebase : TBridgeResponse;
  ret : string;
begin
  if not ( Sender is TMenuItem ) then
    exit;

  case TMenuItem( Sender ).tag of
    2 : statuscode := Status_����Ϸ�;// ���� �Ϸ�
    11 : statuscode := Status_�������;// ���� ���
    12 : statuscode := Status_�������;// ���� ���
    13 : statuscode := Status_�ڵ����;// �ڵ� ���
  else
    exit;
  end;

  GSendReceptionPeriodRoomInfo.RoomCode := LiteQuery1.FieldByName('roomcode').AsString;
  GSendReceptionPeriodRoomInfo.RoomName := LiteQuery1.FieldByName('roomname').AsString;
  GSendReceptionPeriodRoomInfo.DeptCode := LiteQuery1.FieldByName('deptcode').AsString;
  GSendReceptionPeriodRoomInfo.DeptName := LiteQuery1.FieldByName('deptname').AsString;
  GSendReceptionPeriodRoomInfo.DoctorCode := LiteQuery1.FieldByName('doctorcode').AsString;
  GSendReceptionPeriodRoomInfo.DoctorName := LiteQuery1.FieldByName('doctorname').AsString;

  LiteQuery1.Edit;
      LiteQuery1.FieldByName( 'status' ).AsString := statuscode; // ���� ����
  LiteQuery1.Post;

  event_108 := TBridgeRequest_108( GBridgeFactory.MakeRequestObj( EventID_��⿭���°����� ) );
  event_108.HospitalNo := GHospitalNo;
  event_108.ReceptionUpdateDto.chartReceptnResultId.Id1 := LiteQuery1.FieldByName('chartrrid1').AsString;
  event_108.ReceptionUpdateDto.chartReceptnResultId.Id2 := LiteQuery1.FieldByName('chartrrid2').AsString;
  event_108.ReceptionUpdateDto.chartReceptnResultId.Id3 := LiteQuery1.FieldByName('chartrrid3').AsString;
  event_108.ReceptionUpdateDto.chartReceptnResultId.Id4 := LiteQuery1.FieldByName('chartrrid4').AsString;
  event_108.ReceptionUpdateDto.chartReceptnResultId.Id5 := LiteQuery1.FieldByName('chartrrid5').AsString;
  event_108.ReceptionUpdateDto.chartReceptnResultId.Id4 := LiteQuery1.FieldByName('chartrrid6').AsString;

  event_108.ReceptionUpdateDto.RoomInfo.RoomCode := GSendReceptionPeriodRoomInfo.RoomCode;
  event_108.ReceptionUpdateDto.RoomInfo.RoomName := GSendReceptionPeriodRoomInfo.RoomName;
  event_108.ReceptionUpdateDto.RoomInfo.DeptCode := GSendReceptionPeriodRoomInfo.DeptCode;
  event_108.ReceptionUpdateDto.RoomInfo.DeptName := GSendReceptionPeriodRoomInfo.DeptName;
  event_108.ReceptionUpdateDto.RoomInfo.DoctorCode := GSendReceptionPeriodRoomInfo.DoctorCode;
  event_108.ReceptionUpdateDto.RoomInfo.DoctorName := GSendReceptionPeriodRoomInfo.DoctorName;
  event_108.ReceptionUpdateDto.Status   := statuscode;
  event_108.receptStatusChangeDttm     := now;

  event_108.NewchartReceptnResult.Id1 := '';  // ������ ������ ���
  event_108.NewchartReceptnResult.Id2 := '';
  event_108.NewchartReceptnResult.Id3 := '';
  event_108.NewchartReceptnResult.Id4 := '';
  event_108.NewchartReceptnResult.Id5 := '';
  event_108.NewchartReceptnResult.Id6 := '';

  ChartEmulV4Form.AddMemo( event_108.EventID, event_108.JobID );
  ret := GetBridge.RequestResponse( event_108.ToJsonString );
  responsebase := GBridgeFactory.MakeResponseObj( ret );
  ChartEmulV4Form.AddMemo( responsebase.EventID, responsebase.JobID, responsebase.Code, responsebase.MessageStr, 0 );
  FreeAndNil( responsebase );

  FreeAndNil( event_108 );
end;

procedure TReservationMngForm.openprocessquery;
begin
  processQuery.Active := False;
  processQuery.SQL.Text := 'select * from reserve order by rid desc, reservedttm';
  processQuery.Active := True;
end;

end.
