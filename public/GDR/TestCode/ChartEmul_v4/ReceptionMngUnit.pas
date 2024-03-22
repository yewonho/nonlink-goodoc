unit ReceptionMngUnit;
//  C07(���� ���), C08(������), F05(���� �Ϸ�)
//  C04(���� ���� ���)??
// F06 ���� ���
interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  System.Contnrs,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.Grids, Vcl.DBGrids,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.DBCtrls, MemDS, DBAccess, LiteAccess,
  DBDMUnit, BridgeCommUnit, EPBridgeCommUnit, GlobalUnit, Vcl.Menus;

type
  TReceptionMngForm = class(TForm)
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
    Button3: TButton;
    PopupMenu1: TPopupMenu;
    Button4: TButton;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    LiteQuery2: TLiteQuery;
    Button5: TButton;
    Button6: TButton;
    processQuery: TLiteQuery;
    update_356: TLiteTable;
    Button7: TButton;
    make_354: TLiteQuery;
    Timer_354: TTimer;
    N9: TMenuItem;
    N10: TMenuItem;
    Query104: TLiteQuery;
    CheckBox1: TCheckBox;
    Button8: TButton;
    Button9: TButton;
    PopupMenu2: TPopupMenu;
    N14: TMenuItem;
    N15: TMenuItem;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure N7Click(Sender: TObject);
    procedure Button4MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button6Click(Sender: TObject);
    procedure LiteQuery1BeforeClose(DataSet: TDataSet);
    procedure LiteQuery1AfterOpen(DataSet: TDataSet);
    procedure DataSource1DataChange(Sender: TObject; Field: TField);
    procedure LiteQuery1AfterPost(DataSet: TDataSet);
    procedure LiteQuery1BeforeInsert(DataSet: TDataSet);
    procedure Button7Click(Sender: TObject);
    procedure Timer_354Timer(Sender: TObject);
    procedure N13Click(Sender: TObject);
    procedure N12Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
    FCheckAutoAccountProcess : Boolean; // �ڵ�  ���� ��û ó��
    FDataFlag : Integer;
    FSendQueue_354 : TObjectList;
    function CheckReceptionPatient( AChartID : string; ARoomCode : string ) : integer;   // ���� ���ǿ� ��ϵǾ� ������ �ش� rid���� ��ȯ �Ѵ�. ������ -1�� ��ȯ
    function ChangePeriod( ARid : Integer; ADateTime, ARoomCode : string; AUpDownFlag : Integer ) : Boolean; // AUpDownFlag���� 1�̸� ����, �׿ܿ��� �Ʒ��� �̵�

    // ���� ó���� ó��
    function processEP( AChartID, AGDID : string; AChartReceptnResultId : TChartReceptnResultId ) : Boolean;
    function MakeEvent354( AChartReceptnResultId : TChartReceptnResultId ) : TBridgeRequest_354;
    function Send354( AEvent354 : TBridgeRequest_354 ) : Boolean;

    procedure openprocessquery;

    // �� ���� ���
    procedure InputDrug_0( AEvent354 : TBridgeRequest_354 );
    procedure InputDrug_1( AEvent354 : TBridgeRequest_354 );

    function GetRoomInfo( ARoomCode : string ) : TRoomInfoRecord;
  public
    { Public declarations }
    constructor Create( AOwner : TComponent ); override;
    destructor Destroy; override;

    procedure ChangeUI( AParentCtrl : TWinControl );

    // ����
    function AddReception( AReceptionData : TBridgeResponse_100 ) : TBridgeRequest_101; overload;
    procedure AddReception( AReceptionData : TBridgeRequest_100 ); overload;
    // ResultCode�� 200�̸� ó�� �Ϸ�, �׿ܿ��� ó�� �Ұ�
    procedure AddReception( AReceptionData : TData307; var APatientChartID : string; var ResultCode : integer ); overload;

    // ���� ���
    function CancelReception( AReceptionCancelData : TBridgeResponse_102 ) : TBridgeRequest_103; overload;
    procedure CancelReception( AReceptionCancelData : TData307; var APatientChartID : string; var ResultCode : integer ); overload;

    // ���� Ȯ��
    function VisitConfirm( AVisitConfirmData : TBridgeResponse_110; ARoomList : TStringList ) : TBridgeRequest_111;

    // ������ ������� ������ ���� �Ѵ�.
    procedure UpdatePeriod( AUpdateDate : TDateTime; ARoomCode : string );

    // ������ ����ǵ��� ������ ���� �Ѵ�.
    procedure UpdatePeriods( AUpdateDate : TDateTime; ARoomCodes : TStringList );

    procedure SendPeriod( ADate : TDateTime; ARoomInfo : TRoomInfoRecord );

    // ���� ó���� �߱� ��� ����
    function UpdateEP_Reception( AEvent352: TBridgeResponse_352): TBridgeResponse_353;

    // V3-185. �ڵ�ȭ���� ���� ���� ���º���
    function UpdatePatientStateByAutomation( const AChartReceptionResultId1, AStatusCode : string ) : Boolean;

    procedure DBRefresh;
  end;

var
  ReceptionMngForm: TReceptionMngForm;

implementation
uses
  System.UITypes, math, strutils,
  GDLog, GDBridge, dateutils,
  RoomListDialogUnit, ChartEmul_v4Unit,
  PatientMngUnit, ElectronicPrescriptionsDefaultUnit, ReservationMngUnit, RoomMngUnit,
  AccountDMUnit, AccountRequestUnit, ReceptionIDChangeUnit;

{$R *.dfm}

function Gender( ASex : string ) : string;
var
  s : Integer;
begin
  s := StrToIntDef(ASex, 1);
  if s in [1,3,5,7,9] then
    Result := 'M'
  else
    Result := 'F';
end;

{ TReceptionMngForm }

function TReceptionMngForm.AddReception(
  AReceptionData: TBridgeResponse_100): TBridgeRequest_101;
var
  i : Integer;
  rid : Integer;
  d : tdatetime;
  pid, chartrrid1 : string;
  pitem : TPurposeListItem;
  pstr : string;
begin
  Result := TBridgeRequest_101( GBridgeFactory.MakeRequestObj(EventID_������û���, AReceptionData.JobID ) );

  Result.Code := AReceptionData.AnalysisErrorCode;
  if AReceptionData.AnalysisErrorCode <> Result_Success then
  begin
    Result.MessageStr := GBridgeFactory.GetErrorString( AReceptionData.AnalysisErrorCode );
    exit;
  end;

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
        FieldByName( 'sex' ).AsString := AReceptionData.Sexdstn;
        FieldByName( 'birthday' ).AsString := AReceptionData.Birthday;
        FieldByName( 'addr' ).AsString := AReceptionData.Addr;
        FieldByName( 'addrdetail' ).AsString := AReceptionData.AddrDetail;
        FieldByName( 'zip' ).AsString := AReceptionData.Zip;
        FieldByName( 'gdid' ).AsString := AReceptionData.gdid;
        Post;
      end;
      ChartEmulV4Form.AddMemo( format('%s �ֹ� ��ȣ�� �ű� ȯ�� �Դϴ�. ��Ʈ id %s�� �߰� �Ǿ����ϴ�.', [AReceptionData.RegNum, pid]) );
    finally
      patient.Active := False;
    end;
  end
  else
  begin  // gdid update
    if AReceptionData.gdid <> '' then
      PatientMngForm.UpdateGDID( pid, AReceptionData.gdid );
  end;

  // ȯ�� ������ �ּ� ������ ������ �ּ� ������ update�ϰ� �Ѵ�.
  DBDM.UpdatePatientAddress(pid, AReceptionData.Addr,  AReceptionData.AddrDetail, AReceptionData.Zip);

  rid := CheckReceptionPatient(pid, AReceptionData.RoomInfo.RoomCode);
  if rid >= 0 then
  begin // �̹� ��� �Ǿ� �ִ�.
    Result.Code := Result_�����ߺ�;
    Result.MessageStr := GBridgeFactory.GetErrorString( Result.Code );
    ChartEmulV4Form.AddMemo( format('%s(%s)ȯ�ڴ� %s(%s)�� �̹� ��� �Ǿ� �ֽ��ϴ�.(RID:%d)', [AReceptionData.PatntName, pid, AReceptionData.RoomInfo.RoomName, AReceptionData.RoomInfo.RoomCode, rid]) );
    exit;
  end;

  LiteQuery2.Active := False;
  try
    LiteQuery2.SQL.Text := 'select * from reception';
    LiteQuery2.Active := True;

    LiteQuery2.Append;
    with LiteQuery2 do
    begin
      chartrrid1 := FormatDateTime('yyyymmddhhnnsszzz', now);
      FieldByName( 'chartrrid1' ).AsString := chartrrid1;
      FieldByName( 'chartrrid2' ).AsString := '';
      FieldByName( 'chartrrid3' ).AsString := '';
      FieldByName( 'chartrrid4' ).AsString := '';
      FieldByName( 'chartrrid5' ).AsString := '';
      FieldByName( 'chartrrid6' ).AsString := '';
      FieldByName( 'chartid' ).AsString := pid;

      FieldByName( 'roomcode' ).AsString := AReceptionData.RoomInfo.RoomCode;
      FieldByName( 'roomname' ).AsString := AReceptionData.RoomInfo.RoomName;
      FieldByName( 'deptcode' ).AsString := AReceptionData.RoomInfo.DeptCode;
      FieldByName( 'deptname' ).AsString := AReceptionData.RoomInfo.DeptName;
      FieldByName( 'doctorcode' ).AsString := AReceptionData.RoomInfo.DoctorCode;
      FieldByName( 'doctorname' ).AsString := AReceptionData.RoomInfo.DoctorName;
      pstr := '';
      for i := 0 to AReceptionData.PurposeListCount - 1 do
      begin
        pitem := AReceptionData.PurposeLists[ i ];
        if pstr.Length > 0 then
          pstr := pstr + ',';
        //pstr := pstr + RRType_Reception;
        if not string.IsNullOrEmpty(pitem.purpose1) then
          pstr := pstr + pitem.purpose1;
        if not string.IsNullOrEmpty(pitem.purpose2) then
          pstr := pstr + '|' + pitem.purpose2;
        if not string.IsNullOrEmpty(pitem.purpose3) then
          pstr := pstr + '|' + pitem.purpose3;
      end;
      FieldByName( 'compurpose' ).AsString := pstr;
      FieldByName( 'etcpurpose' ).AsString := AReceptionData.EtcPurpose;

      d := AReceptionData.ReceptionDttm;
      FieldByName( 'receptiondate' ).AsString := FormatDateTime('yyyy-mm-dd',d);
      FieldByName( 'receptiontime' ).AsString := FormatDateTime('hh:nn',d);

      FieldByName( 'status' ).AsString := Status_������;
      if AReceptionData.EndPoint = 'A' then
        FieldByName( 'statusmng' ).AsString := Status_������û
      else
        FieldByName( 'statusmng' ).AsString := Status_������;

      FieldByName( 'period' ).AsInteger := Const_Period_NotSend;

      FieldByName( 'gdid' ).AsString := AReceptionData.gdid;
      FieldByName( 'hipass' ).AsInteger := 0;
      FieldByName( 'prescription' ).AsInteger := 0;
      FieldByName( 'parmno' ).AsString := '';
      FieldByName( 'parmnm' ).AsString := '';
      FieldByName( 'extrainfo' ).AsString := '';

      FieldByName( 'dummy' ).AsInteger := 0;
      FieldByName( 'endpoint' ).AsString := AReceptionData.EndPoint;
    end;
    LiteQuery2.Post;
    rid := LiteQuery2.FieldByName( 'rid' ).AsInteger;
  finally
    LiteQuery2.Active := false;
  end;

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
  Result.chartReceptnResultId.Id5 := '';
  Result.chartReceptnResultId.Id6 := '';

  Result.RoomInfo.RoomCode := AReceptionData.RoomInfo.RoomCode;
  Result.RoomInfo.RoomName := AReceptionData.RoomInfo.RoomName;
  Result.RoomInfo.DeptCode := AReceptionData.RoomInfo.DeptCode;
  Result.RoomInfo.DeptName := AReceptionData.RoomInfo.DeptName;
  Result.RoomInfo.DoctorCode := AReceptionData.RoomInfo.DoctorCode;
  Result.RoomInfo.DoctorName := AReceptionData.RoomInfo.DoctorName;

  Result.gdid := AReceptionData.gdid;
  Result.ePrescriptionHospital := GElectronicPrescriptionsOption;  // ���� ó���� ���� ���� (0:�̻��,1:���)

  GSendReceptionPeriodRoomInfo := Result.RoomInfo;
end;

procedure TReceptionMngForm.AddReception(AReceptionData: TBridgeRequest_100);
var
  d : TDateTime;
begin
  openprocessquery;

    processQuery.Append;

    with processQuery do
    begin
      FieldByName( 'chartid' ).AsString := AReceptionData.PatntChartId;
      FieldByName( 'chartrrid1' ).AsString := AReceptionData.chartReceptnResultId.Id1;
      FieldByName( 'chartrrid2' ).AsString := AReceptionData.chartReceptnResultId.Id2;
      FieldByName( 'chartrrid3' ).AsString := AReceptionData.chartReceptnResultId.Id3;
      FieldByName( 'chartrrid4' ).AsString := AReceptionData.chartReceptnResultId.Id4;
      FieldByName( 'chartrrid5' ).AsString := AReceptionData.chartReceptnResultId.Id5;
      FieldByName( 'chartrrid6' ).AsString := AReceptionData.chartReceptnResultId.Id6;

      FieldByName( 'roomcode' ).AsString := AReceptionData.RoomInfo.RoomCode;
      FieldByName( 'roomname' ).AsString := AReceptionData.RoomInfo.RoomName;
      FieldByName( 'deptcode' ).AsString := AReceptionData.RoomInfo.DeptCode;
      FieldByName( 'deptname' ).AsString := AReceptionData.RoomInfo.DeptName;
      FieldByName( 'doctorcode' ).AsString := AReceptionData.RoomInfo.DoctorCode;
      FieldByName( 'doctorname' ).AsString := AReceptionData.RoomInfo.DoctorName;
      FieldByName( 'compurpose' ).AsString := '';
      FieldByName( 'etcpurpose' ).AsString := '';

      d := AReceptionData.ReceptionDttm;
      FieldByName( 'receptiondate' ).AsString := FormatDateTime('yyyy-mm-dd',d);
      FieldByName( 'receptiontime' ).AsString := FormatDateTime('hh:nn',d);
      FieldByName( 'status' ).AsString := Status_����Ȯ��;
      FieldByName( 'statusmng' ).AsString := Status_����Ȯ��;
      FieldByName( 'period' ).AsInteger := Const_Period_Send;

      //FieldByName( 'gdid' ).AsString := AReceptionData.gdid;
      FieldByName( 'gdid' ).AsString := '';

      FieldByName( 'parmno' ).AsString := '';
      FieldByName( 'parmnm' ).AsString := '';
      FieldByName( 'extrainfo' ).AsString := '';
      FieldByName( 'dummy' ).AsInteger := 1;
      FieldByName( 'endpoint' ).AsString := '';
    end;
    processQuery.Post;

  processQuery.Active := False;

  //UpdatePeriod( d, AReceptionData.RoomInfo.RoomCode );
end;

procedure TReceptionMngForm.AddReception(AReceptionData: TData307; var APatientChartID : string; var ResultCode : integer);
var
  i : Integer;
  rid : Integer;
  d : tdatetime;
  chartrrid1 : string;
  pitem : TPurposeListItem;
  pstr : string;
begin
  ResultCode := Result_SuccessCode;
  APatientChartID := DBDM.FindPatient_RegNum(AReceptionData.RegNum);
  if APatientChartID = '' then
  begin
    APatientChartID := AReceptionData.PatntChartID;
    if APatientChartID = '' then
      APatientChartID := 'P' + FormatDateTime('yyyymmddhhnnsszzz', now);

    //    ȯ�� �߰�
    patient.Active := True;
    try
      with patient do
      begin
        Append;
        FieldByName( 'chartid' ).AsString := APatientChartID;
        FieldByName( 'name' ).AsString := AReceptionData.PatntName;
        FieldByName( 'cellphone' ).AsString := AReceptionData.Cellphone;
        FieldByName( 'regnum' ).AsString := AReceptionData.RegNum;
        FieldByName( 'sex' ).AsString := AReceptionData.Sexdstn;
        FieldByName( 'birthday' ).AsString := AReceptionData.Birthday;
        FieldByName( 'addr' ).AsString := AReceptionData.Addr;
        FieldByName( 'addrdetail' ).AsString := AReceptionData.AddrDetail;
        FieldByName( 'zip' ).AsString := AReceptionData.Zip;
        FieldByName( 'gdid' ).AsString := AReceptionData.gdid;
        Post;
      end;
      ChartEmulV4Form.AddMemo( format('%s �ֹ� ��ȣ�� �ű� ȯ�� �Դϴ�. ��Ʈ id %s�� �߰� �Ǿ����ϴ�.', [AReceptionData.RegNum, APatientChartID]) );
    finally
      patient.Active := False;
    end;
  end
  else
  begin  // gdid update
    ChartEmulV4Form.AddMemo( format('%s �ֹ� ��ȣ�� ��Ʈ id %s�� �����ϴ� ȯ�� �Դϴ�.', [AReceptionData.RegNum, APatientChartID]) );
    if AReceptionData.gdid <> '' then
      PatientMngForm.UpdateGDID( APatientChartID, AReceptionData.gdid );
  end;

  rid := CheckReceptionPatient(APatientChartID, AReceptionData.RoomInfo.RoomCode);
  if rid >= 0 then
  begin // �̹� ��� �Ǿ� �ִ�.
    ResultCode := Result_�����ߺ�;
    ChartEmulV4Form.AddMemo( format('%s(%s)ȯ�ڴ� %s(%s)�� �̹� ��� �Ǿ� �ֽ��ϴ�.(RID:%d)', [AReceptionData.PatntName, APatientChartID, AReceptionData.RoomInfo.RoomName, AReceptionData.RoomInfo.RoomCode, rid]) );
    exit;
  end;

  LiteQuery2.Active := False;
  try
    LiteQuery2.SQL.Text := 'select * from reception';
    LiteQuery2.Active := True;

    LiteQuery2.Append;
    with LiteQuery2 do
    begin
      chartrrid1 := FormatDateTime('yyyymmddhhnnsszzz', now);
      FieldByName( 'chartrrid1' ).AsString := chartrrid1;
      AReceptionData.chartReceptnResultId.Id1 := chartrrid1;
      FieldByName( 'chartrrid2' ).AsString := '';
      FieldByName( 'chartrrid3' ).AsString := '';
      FieldByName( 'chartrrid4' ).AsString := '';
      FieldByName( 'chartrrid5' ).AsString := '';
      FieldByName( 'chartrrid6' ).AsString := '';
      FieldByName( 'chartid' ).AsString := APatientChartID;

      FieldByName( 'roomcode' ).AsString := AReceptionData.RoomInfo.RoomCode;
      FieldByName( 'roomname' ).AsString := AReceptionData.RoomInfo.RoomName;
      FieldByName( 'deptcode' ).AsString := AReceptionData.RoomInfo.DeptCode;
      FieldByName( 'deptname' ).AsString := AReceptionData.RoomInfo.DeptName;
      FieldByName( 'doctorcode' ).AsString := AReceptionData.RoomInfo.DoctorCode;
      FieldByName( 'doctorname' ).AsString := AReceptionData.RoomInfo.DoctorName;
      pstr := '';
      for i := 0 to AReceptionData.PurposeListCount - 1 do
      begin
        pitem := AReceptionData.PurposeLists[ i ];
        if pstr.Length > 0 then
          pstr := pstr + ',';
        //pstr := pstr + RRType_Reservation;
        if not string.IsNullOrEmpty(pitem.purpose1) then
          pstr := pstr + pitem.purpose1;
        if not string.IsNullOrEmpty(pitem.purpose2) then
          pstr := pstr + '|' + pitem.purpose2;
        if not string.IsNullOrEmpty(pitem.purpose3) then
          pstr := pstr + '|' + pitem.purpose3;
      end;
      FieldByName( 'compurpose' ).AsString := pstr;
      FieldByName( 'etcpurpose' ).AsString := AReceptionData.EtcPurpose;

      d := AReceptionData.ReceptionDttm;
      FieldByName( 'receptiondate' ).AsString := FormatDateTime('yyyy-mm-dd',d);
      FieldByName( 'receptiontime' ).AsString := FormatDateTime('hh:nn',d);

      FieldByName( 'status' ).AsString := Status_������;
      if AReceptionData.EndPoint = 'A' then
        FieldByName( 'statusmng' ).AsString := Status_������û
      else
        FieldByName( 'statusmng' ).AsString := Status_������;

      FieldByName( 'period' ).AsInteger := Const_Period_NotSend;

      FieldByName( 'gdid' ).AsString := AReceptionData.gdid;
      FieldByName( 'hipass' ).AsInteger := 0;
      FieldByName( 'prescription' ).AsInteger := 0;
      FieldByName( 'parmno' ).AsString := '';
      FieldByName( 'parmnm' ).AsString := '';
      FieldByName( 'extrainfo' ).AsString := '';

      FieldByName( 'dummy' ).AsInteger := 0;
      FieldByName( 'endpoint' ).AsString := AReceptionData.EndPoint;
    end;
    LiteQuery2.Post;
    rid := LiteQuery2.FieldByName( 'rid' ).AsInteger;
  finally
    LiteQuery2.Active := false;
  end;

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
end;

procedure TReceptionMngForm.Button1Click(Sender: TObject);
begin
(*  if LiteQuery1.Active then
    LiteQuery1.Refresh
  else *)
  begin
    LiteQuery1.Active := False;
    LiteQuery1.SQL.Text := 'select * from reception where receptiondate = :receptiondate order by receptiondate desc, period';
    LiteQuery1.ParamByName( 'receptiondate' ).Value := FormatDateTime('yyyy-mm-dd', now);
    LiteQuery1.Active := True;
  end;
  initDBGridWidth( DBGrid1 );
  LiteQuery1.First;
end;

procedure TReceptionMngForm.Button2Click(Sender: TObject);
var
  event_102 : TBridgeRequest_102;
  responsebase : TBridgeResponse;
  ret : string;
begin
  event_102 := TBridgeRequest_102( GBridgeFactory.MakeRequestObj(EventID_������� ) );
  event_102.HospitalNo := GHospitalNo;
  event_102.CancelMessage := '';
  event_102.chartReceptnResultId.Id1 := LiteQuery1.FieldByName('chartrrid1').AsString;
  event_102.chartReceptnResultId.Id2 := LiteQuery1.FieldByName('chartrrid2').AsString;
  event_102.chartReceptnResultId.Id3 := LiteQuery1.FieldByName('chartrrid3').AsString;
  event_102.chartReceptnResultId.Id4 := LiteQuery1.FieldByName('chartrrid4').AsString;
  event_102.chartReceptnResultId.Id5 := LiteQuery1.FieldByName('chartrrid5').AsString;
  event_102.chartReceptnResultId.Id6 := LiteQuery1.FieldByName('chartrrid6').AsString;
  event_102.RoomInfo.RoomCode := LiteQuery1.FieldByName('roomcode').AsString;
  event_102.RoomInfo.RoomName := LiteQuery1.FieldByName('roomname').AsString;
  event_102.RoomInfo.DeptCode := LiteQuery1.FieldByName('deptcode').AsString;
  event_102.RoomInfo.DeptName := LiteQuery1.FieldByName('deptname').AsString;
  event_102.RoomInfo.DoctorCode := LiteQuery1.FieldByName('doctorcode').AsString;
  event_102.RoomInfo.DoctorName := LiteQuery1.FieldByName('doctorname').AsString;
  event_102.receptStatusChangeDttm := now;

  GSendReceptionPeriodRoomInfo.RoomCode := LiteQuery1.FieldByName('roomcode').AsString;
  GSendReceptionPeriodRoomInfo.RoomName := LiteQuery1.FieldByName('roomname').AsString;
  GSendReceptionPeriodRoomInfo.DeptCode := LiteQuery1.FieldByName('deptcode').AsString;
  GSendReceptionPeriodRoomInfo.DeptName := LiteQuery1.FieldByName('deptname').AsString;
  GSendReceptionPeriodRoomInfo.DoctorCode := LiteQuery1.FieldByName('doctorcode').AsString;
  GSendReceptionPeriodRoomInfo.DoctorName := LiteQuery1.FieldByName('doctorname').AsString;

  LiteQuery1.Edit;
      LiteQuery1.FieldByName( 'status' ).AsString := Status_�������; // ���� ���
      LiteQuery1.FieldByName( 'statusmng' ).AsString := Status_�������; // ���� ���
      LiteQuery1.FieldByName( 'cancelmsg' ).AsString := event_102.CancelMessage;
  LiteQuery1.Post;

  UpdatePeriod(now, GSendReceptionPeriodRoomInfo.RoomCode);

  ChartEmulV4Form.AddMemo( event_102.EventID, event_102.JobID );
  ret := GetBridge.RequestResponse( event_102.ToJsonString );
  responsebase := GBridgeFactory.MakeResponseObj( ret );
  ChartEmulV4Form.AddMemo( responsebase.EventID, responsebase.JobID, responsebase.Code, responsebase.MessageStr, 0 );
  FreeAndNil( responsebase );

  GSendReceptionPeriod := True;

  FreeAndNil( event_102 );

  LiteQuery1.Refresh;
end;

procedure TReceptionMngForm.Button3Click(Sender: TObject);
var
  RoomInfo: TRoomInfoRecord;
  event_106 : TBridgeRequest_106;
  responsebase : TBridgeResponse;
  status, ret : string;
begin // ����� ����
  if RoomListDialogForm.ShowModal <> mrOk then
    exit;

  RoomInfo.RoomCode := LiteQuery1.FieldByName('roomcode').AsString;
  RoomInfo.RoomName := LiteQuery1.FieldByName('roomname').AsString;
  RoomInfo.DeptCode := LiteQuery1.FieldByName('deptcode').AsString;
  RoomInfo.DeptName := LiteQuery1.FieldByName('deptname').AsString;
  RoomInfo.DoctorCode := LiteQuery1.FieldByName('doctorcode').AsString;
  RoomInfo.DoctorName := LiteQuery1.FieldByName('doctorname').AsString;
  status := LiteQuery1.FieldByName('status').AsString;

  GSendReceptionPeriodRoomInfo.RoomCode := RoomListDialogForm.LastSelectRoomInfo.RoomCode;
  GSendReceptionPeriodRoomInfo.RoomName := RoomListDialogForm.LastSelectRoomInfo.RoomName;
  GSendReceptionPeriodRoomInfo.DeptCode := RoomListDialogForm.LastSelectRoomInfo.DeptCode;
  GSendReceptionPeriodRoomInfo.DeptName := RoomListDialogForm.LastSelectRoomInfo.DeptName;
  GSendReceptionPeriodRoomInfo.DoctorCode := RoomListDialogForm.LastSelectRoomInfo.DoctorCode;
  GSendReceptionPeriodRoomInfo.DoctorName := RoomListDialogForm.LastSelectRoomInfo.DoctorName;

  event_106 := TBridgeRequest_106( GBridgeFactory.MakeRequestObj(EventID_��⿭���� ) );
  event_106.HospitalNo := GHospitalNo;
  event_106.ReceptionUpdateDto.chartReceptnResultId.Id1 := LiteQuery1.FieldByName('chartrrid1').AsString;
  event_106.ReceptionUpdateDto.chartReceptnResultId.Id2 := LiteQuery1.FieldByName('chartrrid2').AsString;
  event_106.ReceptionUpdateDto.chartReceptnResultId.Id3 := LiteQuery1.FieldByName('chartrrid3').AsString;
  event_106.ReceptionUpdateDto.chartReceptnResultId.Id4 := LiteQuery1.FieldByName('chartrrid4').AsString;
  event_106.ReceptionUpdateDto.chartReceptnResultId.Id5 := LiteQuery1.FieldByName('chartrrid5').AsString;
  event_106.ReceptionUpdateDto.chartReceptnResultId.Id6 := LiteQuery1.FieldByName('chartrrid6').AsString;

  event_106.ReceptionUpdateDto.PatientChartId := LiteQuery1.FieldByName('chartid').AsString;
  event_106.ReceptionUpdateDto.RoomInfo.RoomCode := GSendReceptionPeriodRoomInfo.RoomCode;
  event_106.ReceptionUpdateDto.RoomInfo.RoomName := GSendReceptionPeriodRoomInfo.RoomName;
  event_106.ReceptionUpdateDto.RoomInfo.DeptCode := GSendReceptionPeriodRoomInfo.DeptCode;
  event_106.ReceptionUpdateDto.RoomInfo.DeptName := GSendReceptionPeriodRoomInfo.DeptName;
  event_106.ReceptionUpdateDto.RoomInfo.DoctorCode := GSendReceptionPeriodRoomInfo.DoctorCode;
  event_106.ReceptionUpdateDto.RoomInfo.DoctorName := GSendReceptionPeriodRoomInfo.DoctorName;
  event_106.ReceptionUpdateDto.Status := status;

  event_106.RoomChangeDttm := now;

  LiteQuery1.Edit;
  with LiteQuery1 do
  begin
    FieldByName( 'roomcode' ).AsString := GSendReceptionPeriodRoomInfo.RoomCode;
    FieldByName( 'roomname' ).AsString := GSendReceptionPeriodRoomInfo.RoomName;
    FieldByName( 'deptcode' ).AsString := GSendReceptionPeriodRoomInfo.DeptCode;
    FieldByName( 'deptname' ).AsString := GSendReceptionPeriodRoomInfo.DeptName;
    FieldByName( 'doctorcode' ).AsString := GSendReceptionPeriodRoomInfo.DoctorCode;
    FieldByName( 'doctorname' ).AsString := GSendReceptionPeriodRoomInfo.DoctorName;
    FieldByName( 'period' ).AsInteger := Const_Period_Send;
  end;
  LiteQuery1.Post;

  // �켱 ���� ����
  UpdatePeriod(now, RoomInfo.RoomCode);
  SendPeriod( Now, RoomInfo); // old����

  // �켱 ���� ����
  UpdatePeriod(now, GSendReceptionPeriodRoomInfo.RoomCode);

  ChartEmulV4Form.AddMemo( event_106.EventID, event_106.JobID );
  ret := GetBridge.RequestResponse( event_106.ToJsonString );
  responsebase := GBridgeFactory.MakeResponseObj( ret );
  ChartEmulV4Form.AddMemo( responsebase.EventID, responsebase.JobID, responsebase.Code, responsebase.MessageStr, 0 );
  FreeAndNil( responsebase );

  GSendReceptionPeriod := True;

  FreeAndNil( event_106 );
end;

procedure TReceptionMngForm.Button4MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  PopupMenu1.Popup( Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

procedure TReceptionMngForm.Button6Click(Sender: TObject);
var
  ret : Boolean;
  rid : Integer;
  dt : string;
begin // �Ʒ���
  if not LiteQuery1.Active then
    exit;

  rid := LiteQuery1.FieldByName( 'rid' ).AsInteger;

  GSendReceptionPeriodRoomInfo.RoomCode := LiteQuery1.FieldByName( 'roomcode' ).AsString;
  GSendReceptionPeriodRoomInfo.RoomName := LiteQuery1.FieldByName( 'roomname' ).AsString;
  GSendReceptionPeriodRoomInfo.DeptCode := LiteQuery1.FieldByName( 'deptcode' ).AsString;
  GSendReceptionPeriodRoomInfo.DeptName := LiteQuery1.FieldByName( 'deptname' ).AsString;
  GSendReceptionPeriodRoomInfo.DoctorCode := LiteQuery1.FieldByName( 'doctorcode' ).AsString;
  GSendReceptionPeriodRoomInfo.DoctorName := LiteQuery1.FieldByName( 'doctorname' ).AsString;

  dt := LiteQuery1.FieldByName( 'receptiondate' ).AsString;
  ret := ChangePeriod(rid, dt, GSendReceptionPeriodRoomInfo.RoomCode, TButton(Sender).Tag );
  LiteQuery1.Refresh;
  GSendReceptionPeriod := ret;
end;

procedure TReceptionMngForm.Button7Click(Sender: TObject);
begin
  ElectronicPrescriptionsDefaultForm.Show;
//Button7.Caption := ElectronicPrescriptionsDefaultForm.Get_rxSerialNo;
end;

procedure TReceptionMngForm.Button8Click(Sender: TObject);
var
  form : TReceptionIDChangeForm;
begin
  form := TReceptionIDChangeForm.Create( nil );
  try
    form.oldchartReceptnResultId.Id1 := LiteQuery1.FieldByName('chartrrid1').AsString;
    form.oldchartReceptnResultId.Id2 := LiteQuery1.FieldByName('chartrrid2').AsString;
    form.oldchartReceptnResultId.Id3 := LiteQuery1.FieldByName('chartrrid3').AsString;
    form.oldchartReceptnResultId.Id4 := LiteQuery1.FieldByName('chartrrid4').AsString;
    form.oldchartReceptnResultId.Id5 := LiteQuery1.FieldByName('chartrrid5').AsString;
    form.oldchartReceptnResultId.Id6 := LiteQuery1.FieldByName('chartrrid6').AsString;
    form.StatusCode := LiteQuery1.FieldByName('status').AsString;

    form.RoomInfoRecord.RoomCode    := LiteQuery1.FieldByName('roomcode').AsString;
    form.RoomInfoRecord.RoomName    := LiteQuery1.FieldByName('roomname').AsString;
    form.RoomInfoRecord.DeptCode    := LiteQuery1.FieldByName('deptcode').AsString;
    form.RoomInfoRecord.DeptName    := LiteQuery1.FieldByName('deptname').AsString;
    form.RoomInfoRecord.DoctorCode  := LiteQuery1.FieldByName('doctorcode').AsString;
    form.RoomInfoRecord.DoctorName  := LiteQuery1.FieldByName('doctorname').AsString;

    if form.ShowModal = mrOk then
    begin
      LiteQuery1.Edit;
          LiteQuery1.FieldByName( 'chartrrid1' ).AsString := form.newchartReceptnResultId.Id1;
      LiteQuery1.Post;
      MessageDlg('���� �Ϸ�', mtInformation, [mbOK], 0);
    end;
  finally
    FreeAndNil( form );
  end;
end;

procedure TReceptionMngForm.Button9MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  PopupMenu2.Popup( Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

function TReceptionMngForm.CancelReception(
  AReceptionCancelData: TBridgeResponse_102): TBridgeRequest_103;
begin
  Result := TBridgeRequest_103( GBridgeFactory.MakeRequestObj(EventID_������Ұ��, AReceptionCancelData.JobID ) );
  Result.Code := AReceptionCancelData.AnalysisErrorCode;
  if AReceptionCancelData.AnalysisErrorCode <> Result_Success then
  begin
    Result.MessageStr := GBridgeFactory.GetErrorString( AReceptionCancelData.AnalysisErrorCode );
    exit;
  end;

  Result.MessageStr := '';

  LiteQuery2.Active := False;
  with LiteQuery2 do
  begin
    SQL.Clear;
    SQL.Add( 'select * from reception where ' );
    SQL.Add( 'chartrrid1 = :chartrrid1 and ' );
    SQL.Add( 'chartrrid2 = :chartrrid2 and ' );
    SQL.Add( 'chartrrid3 = :chartrrid3 and ' );
    SQL.Add( 'chartrrid4 = :chartrrid4 and ' );
    SQL.Add( 'chartrrid5 = :chartrrid5 and ' );
    SQL.Add( 'chartrrid6 = :chartrrid6 ' );
    ParamByName( 'chartrrid1' ).Value := AReceptionCancelData.chartReceptnResultId.Id1;
    ParamByName( 'chartrrid2' ).Value := AReceptionCancelData.chartReceptnResultId.Id2;
    ParamByName( 'chartrrid3' ).Value := AReceptionCancelData.chartReceptnResultId.Id3;
    ParamByName( 'chartrrid4' ).Value := AReceptionCancelData.chartReceptnResultId.Id4;
    ParamByName( 'chartrrid5' ).Value := AReceptionCancelData.chartReceptnResultId.Id5;
    ParamByName( 'chartrrid6' ).Value := AReceptionCancelData.chartReceptnResultId.Id6;
    Active := True;
    try
      if Eof then
      begin
        Result.Code := Result_������ȣ����;
        Result.MessageStr := GBridgeFactory.GetErrorString( Result.Code );
        ChartEmulV4Form.AddMemo( format('%s ���� ��ȣ�� ã�� �� �����ϴ�.',[AReceptionCancelData.chartReceptnResultId.Id1]) );
        exit;
      end;

      GSendReceptionPeriodRoomInfo.RoomCode := FieldByName('roomcode').AsString;
      GSendReceptionPeriodRoomInfo.RoomName := FieldByName('roomname').AsString;
      GSendReceptionPeriodRoomInfo.DeptCode := FieldByName('deptcode').AsString;
      GSendReceptionPeriodRoomInfo.DeptName := FieldByName('deptname').AsString;
      GSendReceptionPeriodRoomInfo.DoctorCode := FieldByName('doctorcode').AsString;
      GSendReceptionPeriodRoomInfo.DoctorName := FieldByName('doctorname').AsString;

      Edit;
        FieldByName( 'status' ).AsString := Status_�������;
        FieldByName( 'statusmng' ).AsString := Status_�������;
        FieldByName( 'cancelmsg' ).AsString := AReceptionCancelData.CancelMessage;
      Post;
      GSendReceptionPeriod := True;
    finally
      LiteQuery2.Active := False;
    end;
  end;
end;

procedure TReceptionMngForm.CancelReception(AReceptionCancelData: TData307;
   var APatientChartID : string; var ResultCode: integer);
begin
  ResultCode := Result_SuccessCode;
  APatientChartID := AReceptionCancelData.PatntChartID;

  LiteQuery2.Active := False;
  with LiteQuery2 do
  begin
    SQL.Clear;
    SQL.Add( 'select * from reception where ' );
    SQL.Add( 'chartrrid1 = :chartrrid1 and ' );
    SQL.Add( 'chartrrid2 = :chartrrid2 and ' );
    SQL.Add( 'chartrrid3 = :chartrrid3 and ' );
    SQL.Add( 'chartrrid4 = :chartrrid4 and ' );
    SQL.Add( 'chartrrid5 = :chartrrid5 and ' );
    SQL.Add( 'chartrrid6 = :chartrrid6 ' );
    ParamByName( 'chartrrid1' ).Value := AReceptionCancelData.chartReceptnResultId.Id1;
    ParamByName( 'chartrrid2' ).Value := AReceptionCancelData.chartReceptnResultId.Id2;
    ParamByName( 'chartrrid3' ).Value := AReceptionCancelData.chartReceptnResultId.Id3;
    ParamByName( 'chartrrid4' ).Value := AReceptionCancelData.chartReceptnResultId.Id4;
    ParamByName( 'chartrrid5' ).Value := AReceptionCancelData.chartReceptnResultId.Id5;
    ParamByName( 'chartrrid6' ).Value := AReceptionCancelData.chartReceptnResultId.Id6;
    Active := True;
    try
      if Eof then
      begin
        ResultCode := Result_������ȣ����;
        ChartEmulV4Form.AddMemo( format('%s ���� ��ȣ�� ã�� �� �����ϴ�.',[AReceptionCancelData.chartReceptnResultId.Id1]) );
        exit;
      end;

      Edit;
        FieldByName( 'status' ).AsString := Status_�������;
        FieldByName( 'statusmng' ).AsString := Status_�������;
        FieldByName( 'cancelmsg' ).AsString := 'event306, ��ҵ�';
      Post;
    finally
      LiteQuery2.Active := False;
    end;
  end;
end;

function TReceptionMngForm.ChangePeriod(ARid: Integer; ADateTime, ARoomCode: string;
  AUpDownFlag: Integer) : Boolean;
var
  ownerperiod, changeperiod : Integer;
  ownerstatus, changestatus : string;
  //changerid : Integer;
begin
  Result := False;
  with LiteQuery2 do
  begin
    Active := False;
    SQL.Text := 'select * from reception where status in (''C04'', ''C07'') and roomcode = :roomcode and receptiondate = :receptiondate order by period';  //  C04(������), C08(������)
    if AUpDownFlag <> 1 then
      SQL.Text := SQL.Text + ' desc';

    ParamByName('roomcode').Value := ARoomCode;
    ParamByName('receptiondate').Value := ADateTime;
    Active := True;
    First;

    if not Locate('rid', IntToStr(ARid), []) then
      exit; //  �� ã�Ҵ�.

    ownerperiod := FieldByName( 'period' ).AsInteger;
    ownerstatus := FieldByName( 'status' ).AsString;
    Next;
    if eof then
      exit; // ������ �̶� ó�� �Ұ�

    changeperiod := FieldByName( 'period' ).AsInteger;
    changestatus := FieldByName( 'status' ).AsString;

    Edit;
    FieldByName( 'period' ).AsInteger := ownerperiod;
    FieldByName( 'status' ).AsString := ownerstatus;
    Post;

    First;
    Locate('rid', IntToStr(ARid), []);
    if Locate('rid', IntToStr(ARid), []) then
    begin
      Edit;
      FieldByName( 'period' ).AsInteger := changeperiod;
      FieldByName( 'status' ).AsString := changestatus;
      Post;
    end;
    Result := True;
  end;
end;

procedure TReceptionMngForm.ChangeUI(AParentCtrl: TWinControl);
begin
  if Assigned( AParentCtrl ) then
  begin
    Panel1.Parent := AParentCtrl;
    Panel1.Align := alClient;
  end
  else
    Panel1.Parent := Self;
end;

function TReceptionMngForm.CheckReceptionPatient(AChartID,
  ARoomCode: string): integer;
begin
  Result := -1;
  with LiteQuery2 do
  begin
    Active := False;
    try
      //SQL.Text := 'select * from reception where status in (''C04'', ''C07'') and roomcode = :roomcode and receptiondate = :receptiondate  and chartid = :chartid';  //  C04(������), C07(��������)
(*
2020-07-17, tonny��û, ��������� ������ ���� ����ǿ� �̹� ���� �Ǿ� �ִ� ��� ������ �ȵǾ�� �ϴµ� ���� �Ǵ� ����
�������� ���� ��� C04 , �������� C07  ���¿� �ִ� ȯ�ڸ� check�ϰ� �Ǿ� �ֽ��ϴ�.
���� ������
���� ��û C01
���� �Ϸ� C03
���� ��û C05
���� Ȯ�� C06
�� ���� ��⿡ �ش�Ǵ� ���µ� ������ûó���� �ʵǰ� ������ �ϰڽ��ϴ�.
�ش� ���´� emul���� �����ϰ� �ִ� ���� �����Դϴ�.
*)
      SQL.Text := 'select * from reception where status in (''C01'', ''C03'', ''C04'', ''C05'', ''C06'', ''C07'') and roomcode = :roomcode and receptiondate = :receptiondate  and chartid = :chartid';  //  C04(������), C07(��������)
      ParamByName('chartid').Value := AChartID;
      ParamByName('roomcode').Value := ARoomCode;
      ParamByName('receptiondate').Value := FormatDateTime('yyyy-mm-dd', Today);
      Active := True;
      First;
      if not eof then
      begin
        Result := FieldByName( 'rid' ).AsInteger;
      end;
    finally
      Active := False;
    end;
  end;
end;

constructor TReceptionMngForm.Create(AOwner: TComponent);
begin
  inherited;
  FDataFlag := 0;
  FCheckAutoAccountProcess := False;
  FSendQueue_354 := TObjectList.Create(False);
end;

procedure TReceptionMngForm.DataSource1DataChange(Sender: TObject;
  Field: TField);
var
  status : string;
  isAccountCheck : Boolean;
begin
  if not Assigned( DataSource1.DataSet ) then
    exit;
  if not DataSource1.DataSet.Active then
    exit;

  if DataSource1.DataSet.State <> dsBrowse then
    exit;

  // ���� ��ȣ ����
  Button8.Enabled := DataSource1.DataSet.FieldByName('chartrrid1').AsString <> '';

  with DataSource1.DataSet do
  begin
    status := FieldByName( 'status' ).AsString;

    // ���, ����� ����
    if (status = Status_�����û)
       or (status = Status_����Ϸ�)
       or (status = Status_������û)
       or (status = Status_�����Ϸ�)
       or (status = Status_������)
       or (status = Status_������û)
       or (status = Status_����Ȯ��)
       or (status = Status_��������)
    then
    begin
      Button2.Enabled := True;
      Button3.Enabled := True;
    end
    else
    begin
      Button2.Enabled := False;
      Button3.Enabled := False;
    end;

    // ���Ʒ�
    if (status = Status_������) or (status = Status_��������) then
    begin
      Button5.Enabled := True;
      Button6.Enabled := True;
      Button3.Enabled := True;
    end
    else
    begin
      Button5.Enabled := False;
      Button6.Enabled := False;
      Button3.Enabled := False;
    end;

    // ���� ����
    if (status = Status_��ҿ�û)
       or (status = Status_�������)
       or (status = Status_�������)
       or (status = Status_�ڵ����)
       or (status = Status_����Ϸ�)
    then
      Button4.Enabled := False
    else
      Button4.Enabled := True;
  end;

  // ������ record�̳�?  true�̸� ���� ���, false�̸� �������� �ʾҴ�.
  isAccountCheck := DataSource1.DataSet.FieldByName('payauthno').AsString <> '';
  // ���� ��û
  N14.Enabled := AccountDM.Active and (not isAccountCheck) and (DataSource1.DataSet.FieldByName('chartrrid1').AsString <> ''); // ���� ��� �����̰�, ������ �ʉ��, ������ �Ǿ� �־�� �Ѵ�. true
  // ���� ���,
  N15.Enabled := AccountDM.Active and isAccountCheck; // ���� ��� �����̰� ������ ���. true
end;

procedure TReceptionMngForm.DBRefresh;
begin
  Button1.Click;
end;

destructor TReceptionMngForm.Destroy;
begin
  FreeAndNil( FSendQueue_354 );
  inherited;
end;

function TReceptionMngForm.GetRoomInfo(ARoomCode: string): TRoomInfoRecord;
begin
  Result := RoomMngForm.GetRoomInfo( ARoomCode );
end;

procedure TReceptionMngForm.InputDrug_0(AEvent354: TBridgeRequest_354);
var
  rxDrug: TrxDrugListItem;
  CItem: TadCommentItem;
begin
  with AEvent354 do
  begin
    // 1
    rxDrug := TrxDrugListItem.Create;
    with rxDrug do
    begin
      drugCode := '692000120';
      drugKorName := '���������������Ⱦ�(�ܿ�)';
      drugEngName := '���������������Ⱦ�(�ܿ�)';
      drugReimbursementType := 1; // 1:�޿�, 2:��޿�, 3:100/100, 4:100/80, 5:100/50, 6:100/30, 7: 100:90
      drugAdminRoute := 1; // 0:����, 1:�ܿ�, 2:�ֻ���
      drugDose := '0.8333'; // 1ȸ ������
      totalAdminDose := '1';  // ��������
      drugAdminCount := '6';  // 1ȸ ����Ƚ��
      drugTreatmentPeriod := '1';  // �� �����ϼ�
      drugAdminCode := 'D0';// ��� �ڵ�
      drugAdminComment := '���ô�� �����ϼ���'; // ���
      drugOutsideFlag := 1; // 1(����), 2(����)
      docClsType := 1; //  ������ ���: 3 ������ �ƴ� ���: 1
      docComment := '';
      prnCheck := 0; //  1: prn ó���� ���, 0: prn ó���� �ƴ� ���

      ingredientName := '';
      drugListEnrollType := 0; //  0:��ǰ��, 1:���и�(����), 2:���и�(�ѱ�), Default = '0'
      drugPackageFlag := 1;    // 1:���Ѵ���, 0:�׿ܾ�ǰ

        CItem := TadCommentItem.Create;
        CItem.resnm := '�ߺ����� ġ�ᱺ' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resncnts := '���� ġ�ᱺ �� �ϳ��� ����� ������ �������� �� ����, ��ü ������ �ٸ� ġ�ᱺ�� ����.' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resnm := '��������10/5mg' + FormatDateTime('yyyymmddhhnnsszzz',now);
        AddadComment( CItem );
    end;
    AddrxDrug( rxDrug );

    // 4
    rxDrug := TrxDrugListItem.Create;
    with rxDrug do
    begin
      drugCode := '653501390';
      drugKorName := 'Ʈ����Ÿ����� 2.5/500mg (�ѱ��������ΰ�����)';
      drugEngName := 'Ʈ����Ÿ����� 2.5/500mg (�ѱ��������ΰ�����)';
      drugReimbursementType := 5; // 1:�޿�, 2:��޿�, 3:100/100, 4:100/80, 5:100/50, 6:100/30, 7: 100:90
      drugAdminRoute := 0; // 0:����, 1:�ܿ�, 2:�ֻ���
      drugDose := '1'; // 1ȸ ������
      totalAdminDose := '180';  // ��������
      drugAdminCount := '2';  // 1ȸ ����Ƚ��
      drugTreatmentPeriod := '90';  // �� �����ϼ�
      drugAdminCode := 'D30';// ��� �ڵ�
      drugAdminComment := '����30��'; // ���
      drugOutsideFlag := 2; // 1(����), 2(����)
      docClsType := 1; //  ������ ���: 3 ������ �ƴ� ���: 1
      docComment := '';
      prnCheck := 0; //  1: prn ó���� ���, 0: prn ó���� �ƴ� ���

      ingredientName := '';
      drugListEnrollType := 0; //  0:��ǰ��, 1:���и�(����), 2:���и�(�ѱ�), Default = '0'
      drugPackageFlag := 1;    // 1:���Ѵ���, 0:�׿ܾ�ǰ

        CItem := TadCommentItem.Create;
        CItem.resnm := '�ߺ����� ġ�ᱺ' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resncnts := '���� ġ�ᱺ �� �ϳ��� ����� ������ �������� �� ����, ��ü ������ �ٸ� ġ�ᱺ�� ����.' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resnm := '��������10/5mg' + FormatDateTime('yyyymmddhhnnsszzz',now);
        AddadComment( CItem );
    end;
    AddrxDrug( rxDrug );

    // 8
    rxDrug := TrxDrugListItem.Create;
    with rxDrug do
    begin
      drugCode := '646202070';
      drugKorName := '�ĸ�õ���20mg';
      drugEngName := '�ĸ�õ���20mg';
      drugReimbursementType := 1; // 1:�޿�, 2:��޿�, 3:100/100, 4:100/80, 5:100/50, 6:100/30, 7: 100:90
      drugAdminRoute := 0; // 0:����, 1:�ܿ�, 2:�ֻ���
      drugDose := '1'; // 1ȸ ������
      totalAdminDose := '6';  // ��������
      drugAdminCount := '3';  // 1ȸ ����Ƚ��
      drugTreatmentPeriod := '2';  // �� �����ϼ�
      drugAdminCode := 'D30';// ��� �ڵ�
      drugAdminComment := '����30��'; // ���
      drugOutsideFlag := 2; // 1(����), 2(����)
      docClsType := 1; //  ������ ���: 3 ������ �ƴ� ���: 1
      docComment := '';
      prnCheck := 0; //  1: prn ó���� ���, 0: prn ó���� �ƴ� ���

      ingredientName := '';
      drugListEnrollType := 0; //  0:��ǰ��, 1:���и�(����), 2:���и�(�ѱ�), Default = '0'
      drugPackageFlag := 1;    // 1:���Ѵ���, 0:�׿ܾ�ǰ

        CItem := TadCommentItem.Create;
        CItem.resnm := '�ߺ����� ġ�ᱺ' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resncnts := '���� ġ�ᱺ �� �ϳ��� ����� ������ �������� �� ����, ��ü ������ �ٸ� ġ�ᱺ�� ����.' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resnm := '��������10/5mg' + FormatDateTime('yyyymmddhhnnsszzz',now);
        AddadComment( CItem );
    end;
    AddrxDrug( rxDrug );
  end;
end;

procedure TReceptionMngForm.InputDrug_1(AEvent354: TBridgeRequest_354);
var
  rxDrug: TrxDrugListItem;
  CItem: TadCommentItem;
begin
  with AEvent354 do
  begin
    // 1
    rxDrug := TrxDrugListItem.Create;
    with rxDrug do
    begin
      drugCode := '692000120';
      drugKorName := '���������������Ⱦ�(�ܿ�)';
      drugEngName := '���������������Ⱦ�(�ܿ�)';
      drugReimbursementType := 1; // 1:�޿�, 2:��޿�, 3:100/100, 4:100/80, 5:100/50, 6:100/30, 7: 100:90
      drugAdminRoute := 1; // 0:����, 1:�ܿ�, 2:�ֻ���
      drugDose := '0.8333'; // 1ȸ ������
      totalAdminDose := '1';  // ��������
      drugAdminCount := '6';  // 1ȸ ����Ƚ��
      drugTreatmentPeriod := '1';  // �� �����ϼ�
      drugAdminCode := 'D0';// ��� �ڵ�
      drugAdminComment := '���ô�� �����ϼ���'; // ���
      drugOutsideFlag := 1; // 1(����), 2(����)
      docClsType := 1; //  ������ ���: 3 ������ �ƴ� ���: 1
      docComment := '';
      prnCheck := 0; //  1: prn ó���� ���, 0: prn ó���� �ƴ� ���

      ingredientName := '';
      drugListEnrollType := 0; //  0:��ǰ��, 1:���и�(����), 2:���и�(�ѱ�), Default = '0'
      drugPackageFlag := 1;    // 1:���Ѵ���, 0:�׿ܾ�ǰ

        CItem := TadCommentItem.Create;
        CItem.resnm := '�ߺ����� ġ�ᱺ' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resncnts := '���� ġ�ᱺ �� �ϳ��� ����� ������ �������� �� ����, ��ü ������ �ٸ� ġ�ᱺ�� ����.' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resnm := '��������10/5mg' + FormatDateTime('yyyymmddhhnnsszzz',now);
        AddadComment( CItem );
    end;
    AddrxDrug( rxDrug );

    // 2
    rxDrug := TrxDrugListItem.Create;
    with rxDrug do
    begin
      drugCode := '661904110';
      drugKorName := '���ǽ�Ÿƾ�� 10mg (��ǳ)';
      drugEngName := '���ǽ�Ÿƾ�� 10mg (��ǳ)';
      drugReimbursementType := 3; // 1:�޿�, 2:��޿�, 3:100/100, 4:100/80, 5:100/50, 6:100/30, 7: 100:90
      drugAdminRoute := 0; // 0:����, 1:�ܿ�, 2:�ֻ���
      drugDose := '1'; // 1ȸ ������
      totalAdminDose := '180';  // ��������
      drugAdminCount := '2';  // 1ȸ ����Ƚ��
      drugTreatmentPeriod := '90';  // �� �����ϼ�
      drugAdminCode := 'D33';// ��� �ڵ�
      drugAdminComment := '2�ð�����'; // ���
      drugOutsideFlag := 2; // 1(����), 2(����)
      docClsType := 1; //  ������ ���: 3 ������ �ƴ� ���: 1
      docComment := '';
      prnCheck := 0; //  1: prn ó���� ���, 0: prn ó���� �ƴ� ���

      ingredientName := '';
      drugListEnrollType := 0; //  0:��ǰ��, 1:���и�(����), 2:���и�(�ѱ�), Default = '0'
      drugPackageFlag := 1;    // 1:���Ѵ���, 0:�׿ܾ�ǰ
        CItem := TadCommentItem.Create;
        CItem.resnm := '�ߺ����� ġ�ᱺ' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resncnts := '���� ġ�ᱺ �� �ϳ��� ����� ������ �������� �� ����, ��ü ������ �ٸ� ġ�ᱺ�� ����.' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resnm := '��������10/5mg' + FormatDateTime('yyyymmddhhnnsszzz',now);
        AddadComment( CItem );
    end;
    AddrxDrug( rxDrug );

    // 3
    rxDrug := TrxDrugListItem.Create;
    with rxDrug do
    begin
      drugCode := '644501990';
      drugKorName := '�������� �� 5/160mg (��������)';
      drugEngName := '�������� �� 5/160mg (��������)';
      drugReimbursementType := 4; // 1:�޿�, 2:��޿�, 3:100/100, 4:100/80, 5:100/50, 6:100/30, 7: 100:90
      drugAdminRoute := 0; // 0:����, 1:�ܿ�, 2:�ֻ���
      drugDose := '1'; // 1ȸ ������
      totalAdminDose := '180';  // ��������
      drugAdminCount := '2';  // 1ȸ ����Ƚ��
      drugTreatmentPeriod := '90';  // �� �����ϼ�
      drugAdminCode := 'D30';// ��� �ڵ�
      drugAdminComment := '����30��'; // ���
      drugOutsideFlag := 2; // 1(����), 2(����)
      docClsType := 1; //  ������ ���: 3 ������ �ƴ� ���: 1
      docComment := '';
      prnCheck := 0; //  1: prn ó���� ���, 0: prn ó���� �ƴ� ���

      ingredientName := '';
      drugListEnrollType := 0; //  0:��ǰ��, 1:���и�(����), 2:���и�(�ѱ�), Default = '0'
      drugPackageFlag := 1;    // 1:���Ѵ���, 0:�׿ܾ�ǰ
        CItem := TadCommentItem.Create;
        CItem.resnm := '�ߺ����� ġ�ᱺ' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resncnts := '���� ġ�ᱺ �� �ϳ��� ����� ������ �������� �� ����, ��ü ������ �ٸ� ġ�ᱺ�� ����.' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resnm := '��������10/5mg' + FormatDateTime('yyyymmddhhnnsszzz',now);
        AddadComment( CItem );
    end;
    AddrxDrug( rxDrug );

    // 4
    rxDrug := TrxDrugListItem.Create;
    with rxDrug do
    begin
      drugCode := '653501390';
      drugKorName := 'Ʈ����Ÿ����� 2.5/500mg (�ѱ��������ΰ�����)';
      drugEngName := 'Ʈ����Ÿ����� 2.5/500mg (�ѱ��������ΰ�����)';
      drugReimbursementType := 5; // 1:�޿�, 2:��޿�, 3:100/100, 4:100/80, 5:100/50, 6:100/30, 7: 100:90
      drugAdminRoute := 0; // 0:����, 1:�ܿ�, 2:�ֻ���
      drugDose := '1'; // 1ȸ ������
      totalAdminDose := '180';  // ��������
      drugAdminCount := '2';  // 1ȸ ����Ƚ��
      drugTreatmentPeriod := '90';  // �� �����ϼ�
      drugAdminCode := 'D30';// ��� �ڵ�
      drugAdminComment := '����30��'; // ���
      drugOutsideFlag := 2; // 1(����), 2(����)
      docClsType := 1; //  ������ ���: 3 ������ �ƴ� ���: 1
      docComment := '';
      prnCheck := 0; //  1: prn ó���� ���, 0: prn ó���� �ƴ� ���

      ingredientName := '';
      drugListEnrollType := 0; //  0:��ǰ��, 1:���и�(����), 2:���и�(�ѱ�), Default = '0'
      drugPackageFlag := 1;    // 1:���Ѵ���, 0:�׿ܾ�ǰ
        CItem := TadCommentItem.Create;
        CItem.resnm := '�ߺ����� ġ�ᱺ' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resncnts := '���� ġ�ᱺ �� �ϳ��� ����� ������ �������� �� ����, ��ü ������ �ٸ� ġ�ᱺ�� ����.' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resnm := '��������10/5mg' + FormatDateTime('yyyymmddhhnnsszzz',now);
        AddadComment( CItem );
    end;
    AddrxDrug( rxDrug );

    // 4
    rxDrug := TrxDrugListItem.Create;
    with rxDrug do
    begin
      drugCode := '661901650';
      drugKorName := 'ũ����� 75mg  (��ǳ����)';
      drugEngName := 'ũ����� 75mg  (��ǳ����)';
      drugReimbursementType := 6; // 1:�޿�, 2:��޿�, 3:100/100, 4:100/80, 5:100/50, 6:100/30, 7: 100:90
      drugAdminRoute := 0; // 0:����, 1:�ܿ�, 2:�ֻ���
      drugDose := '1'; // 1ȸ ������
      totalAdminDose := '180';  // ��������
      drugAdminCount := '2';  // 1ȸ ����Ƚ��
      drugTreatmentPeriod := '90';  // �� �����ϼ�
      drugAdminCode := 'D30';// ��� �ڵ�
      drugAdminComment := '����30��'; // ���
      drugOutsideFlag := 2; // 1(����), 2(����)
      docClsType := 1; //  ������ ���: 3 ������ �ƴ� ���: 1
      docComment := '';
      prnCheck := 0; //  1: prn ó���� ���, 0: prn ó���� �ƴ� ���

      ingredientName := '';
      drugListEnrollType := 0; //  0:��ǰ��, 1:���и�(����), 2:���и�(�ѱ�), Default = '0'
      drugPackageFlag := 1;    // 1:���Ѵ���, 0:�׿ܾ�ǰ
        CItem := TadCommentItem.Create;
        CItem.resnm := '�ߺ����� ġ�ᱺ' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resncnts := '���� ġ�ᱺ �� �ϳ��� ����� ������ �������� �� ����, ��ü ������ �ٸ� ġ�ᱺ�� ����.' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resnm := '��������10/5mg' + FormatDateTime('yyyymmddhhnnsszzz',now);
        AddadComment( CItem );
    end;
    AddrxDrug( rxDrug );

    // 5
    rxDrug := TrxDrugListItem.Create;
    with rxDrug do
    begin
      drugCode := '643901070';
      drugKorName := '��ť��Ŭ�����Ⱦ�';
      drugEngName := '��ť��Ŭ�����Ⱦ�';
      drugReimbursementType := 7; // 1:�޿�, 2:��޿�, 3:100/100, 4:100/80, 5:100/50, 6:100/30, 7: 100:90
      drugAdminRoute := 1; // 0:����, 1:�ܿ�, 2:�ֻ���
      drugDose := '1.25'; // 1ȸ ������
      totalAdminDose := '1';  // ��������
      drugAdminCount := '4';  // 1ȸ ����Ƚ��
      drugTreatmentPeriod := '1';  // �� �����ϼ�
      drugAdminCode := 'D40';// ��� �ڵ�
      drugAdminComment := '���� 1���� ��ħ�� 1��'; // ���
      drugOutsideFlag := 2; // 1(����), 2(����)
      docClsType := 1; //  ������ ���: 3 ������ �ƴ� ���: 1
      docComment := '';
      prnCheck := 0; //  1: prn ó���� ���, 0: prn ó���� �ƴ� ���

      ingredientName := '';
      drugListEnrollType := 0; //  0:��ǰ��, 1:���и�(����), 2:���и�(�ѱ�), Default = '0'
      drugPackageFlag := 1;    // 1:���Ѵ���, 0:�׿ܾ�ǰ
        CItem := TadCommentItem.Create;
        CItem.resnm := '�ߺ����� ġ�ᱺ' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resncnts := '���� ġ�ᱺ �� �ϳ��� ����� ������ �������� �� ����, ��ü ������ �ٸ� ġ�ᱺ�� ����.' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resnm := '��������10/5mg' + FormatDateTime('yyyymmddhhnnsszzz',now);
        AddadComment( CItem );
    end;
    AddrxDrug( rxDrug );

    // 6
    rxDrug := TrxDrugListItem.Create;
    with rxDrug do
    begin
      drugCode := '646201050';
      drugKorName := '�ַ�����';
      drugEngName := '�ַ�����';
      drugReimbursementType := 1; // 1:�޿�, 2:��޿�, 3:100/100, 4:100/80, 5:100/50, 6:100/30, 7: 100:90
      drugAdminRoute := 0; // 0:����, 1:�ܿ�, 2:�ֻ���
      drugDose := '2'; // 1ȸ ������
      totalAdminDose := '12';  // ��������
      drugAdminCount := '3';  // 1ȸ ����Ƚ��
      drugTreatmentPeriod := '2';  // �� �����ϼ�
      drugAdminCode := 'D30';// ��� �ڵ�
      drugAdminComment := '����30��'; // ���
      drugOutsideFlag := 2; // 1(����), 2(����)
      docClsType := 1; //  ������ ���: 3 ������ �ƴ� ���: 1
      docComment := '';
      prnCheck := 0; //  1: prn ó���� ���, 0: prn ó���� �ƴ� ���

      ingredientName := '';
      drugListEnrollType := 0; //  0:��ǰ��, 1:���и�(����), 2:���и�(�ѱ�), Default = '0'
      drugPackageFlag := 1;    // 1:���Ѵ���, 0:�׿ܾ�ǰ
        CItem := TadCommentItem.Create;
        CItem.resnm := '�ߺ����� ġ�ᱺ' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resncnts := '���� ġ�ᱺ �� �ϳ��� ����� ������ �������� �� ����, ��ü ������ �ٸ� ġ�ᱺ�� ����.' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resnm := '��������10/5mg' + FormatDateTime('yyyymmddhhnnsszzz',now);
        AddadComment( CItem );
    end;
    AddrxDrug( rxDrug );

    // 7
    rxDrug := TrxDrugListItem.Create;
    with rxDrug do
    begin
      drugCode := '646200690';
      drugKorName := '�ϼ�����';
      drugEngName := '�ϼ�����';
      drugReimbursementType := 2; // 1:�޿�, 2:��޿�, 3:100/100, 4:100/80, 5:100/50, 6:100/30, 7: 100:90
      drugAdminRoute := 0; // 0:����, 1:�ܿ�, 2:�ֻ���
      drugDose := '1'; // 1ȸ ������
      totalAdminDose := '6';  // ��������
      drugAdminCount := '3';  // 1ȸ ����Ƚ��
      drugTreatmentPeriod := '2';  // �� �����ϼ�
      drugAdminCode := 'D30';// ��� �ڵ�
      drugAdminComment := '����30��'; // ���
      drugOutsideFlag := 2; // 1(����), 2(����)
      docClsType := 3; //  ������ ���: 3 ������ �ƴ� ���: 1
      docComment := '��޿�';
      prnCheck := 0; //  1: prn ó���� ���, 0: prn ó���� �ƴ� ���

      ingredientName := '';
      drugListEnrollType := 0; //  0:��ǰ��, 1:���и�(����), 2:���и�(�ѱ�), Default = '0'
      drugPackageFlag := 1;    // 1:���Ѵ���, 0:�׿ܾ�ǰ
        CItem := TadCommentItem.Create;
        CItem.resnm := '�ߺ����� ġ�ᱺ' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resncnts := '���� ġ�ᱺ �� �ϳ��� ����� ������ �������� �� ����, ��ü ������ �ٸ� ġ�ᱺ�� ����.' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resnm := '��������10/5mg' + FormatDateTime('yyyymmddhhnnsszzz',now);
        AddadComment( CItem );
    end;
    AddrxDrug( rxDrug );

    // 8
    rxDrug := TrxDrugListItem.Create;
    with rxDrug do
    begin
      drugCode := '646202070';
      drugKorName := '�ĸ�õ���20mg';
      drugEngName := '�ĸ�õ���20mg';
      drugReimbursementType := 1; // 1:�޿�, 2:��޿�, 3:100/100, 4:100/80, 5:100/50, 6:100/30, 7: 100:90
      drugAdminRoute := 0; // 0:����, 1:�ܿ�, 2:�ֻ���
      drugDose := '1'; // 1ȸ ������
      totalAdminDose := '6';  // ��������
      drugAdminCount := '3';  // 1ȸ ����Ƚ��
      drugTreatmentPeriod := '2';  // �� �����ϼ�
      drugAdminCode := 'D30';// ��� �ڵ�
      drugAdminComment := '����30��'; // ���
      drugOutsideFlag := 2; // 1(����), 2(����)
      docClsType := 1; //  ������ ���: 3 ������ �ƴ� ���: 1
      docComment := '';
      prnCheck := 0; //  1: prn ó���� ���, 0: prn ó���� �ƴ� ���

      ingredientName := '';
      drugListEnrollType := 0; //  0:��ǰ��, 1:���и�(����), 2:���и�(�ѱ�), Default = '0'
      drugPackageFlag := 1;    // 1:���Ѵ���, 0:�׿ܾ�ǰ
        CItem := TadCommentItem.Create;
        CItem.resnm := '�ߺ����� ġ�ᱺ' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resncnts := '���� ġ�ᱺ �� �ϳ��� ����� ������ �������� �� ����, ��ü ������ �ٸ� ġ�ᱺ�� ����.' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resnm := '��������10/5mg' + FormatDateTime('yyyymmddhhnnsszzz',now);
        AddadComment( CItem );
    end;
    AddrxDrug( rxDrug );

    // 9
    rxDrug := TrxDrugListItem.Create;
    with rxDrug do
    begin
      drugCode := '67080032';
      drugKorName := 'Ǫ����Ȯ����20�и��׶�(�����÷��';
      drugEngName := 'Ǫ����Ȯ����20�и��׶�(�����÷��';
      drugReimbursementType := 3; // 1:�޿�, 2:��޿�, 3:100/100, 4:100/80, 5:100/50, 6:100/30, 7: 100:90
      drugAdminRoute := 0; // 0:����, 1:�ܿ�, 2:�ֻ���
      drugDose := '1'; // 1ȸ ������
      totalAdminDose := '180';  // ��������
      drugAdminCount := '2';  // 1ȸ ����Ƚ��
      drugTreatmentPeriod := '180';  // �� �����ϼ�
      drugAdminCode := 'D2120';// ��� �ڵ�
      drugAdminComment := '��ħ����'; // ���
      drugOutsideFlag := 2; // 1(����), 2(����)
      docClsType := 1; //  ������ ���: 3 ������ �ƴ� ���: 1
      docComment := '';
      prnCheck := 0; //  1: prn ó���� ���, 0: prn ó���� �ƴ� ���

      ingredientName := '';
      drugListEnrollType := 0; //  0:��ǰ��, 1:���и�(����), 2:���и�(�ѱ�), Default = '0'
      drugPackageFlag := 1;    // 1:���Ѵ���, 0:�׿ܾ�ǰ
        CItem := TadCommentItem.Create;
        CItem.resnm := '�ߺ����� ġ�ᱺ' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resncnts := '���� ġ�ᱺ �� �ϳ��� ����� ������ �������� �� ����, ��ü ������ �ٸ� ġ�ᱺ�� ����.' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resnm := '��������10/5mg' + FormatDateTime('yyyymmddhhnnsszzz',now);
        AddadComment( CItem );
    end;
    AddrxDrug( rxDrug );
exit;

    // 10
    rxDrug := TrxDrugListItem.Create;
    with rxDrug do
    begin
      drugCode := '65190128';
      drugKorName := '���ǵ���200mg(���Ǹ���)�����';
      drugEngName := '���ǵ���200mg(���Ǹ���)�����';
      drugReimbursementType := 6; // 1:�޿�, 2:��޿�, 3:100/100, 4:100/80, 5:100/50, 6:100/30, 7: 100:90
      drugAdminRoute := 0; // 0:����, 1:�ܿ�, 2:�ֻ���
      drugDose := '0.5'; // 1ȸ ������
      totalAdminDose := '90';  // ��������
      drugAdminCount := '1';  // 1ȸ ����Ƚ��
      drugTreatmentPeriod := '180';  // �� �����ϼ�
      drugAdminCode := 'H1';// ��� �ڵ�
      drugAdminComment := '���� ���������� �� �ؿ� 1���� ��������'; // ���
      drugOutsideFlag := 2; // 1(����), 2(����)
      docClsType := 1; //  ������ ���: 3 ������ �ƴ� ���: 1
      docComment := '';
      prnCheck := 0; //  1: prn ó���� ���, 0: prn ó���� �ƴ� ���

      ingredientName := '';
      drugListEnrollType := 0; //  0:��ǰ��, 1:���и�(����), 2:���и�(�ѱ�), Default = '0'
      drugPackageFlag := 1;    // 1:���Ѵ���, 0:�׿ܾ�ǰ
        CItem := TadCommentItem.Create;
        CItem.resnm := '�ߺ����� ġ�ᱺ' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resncnts := '���� ġ�ᱺ �� �ϳ��� ����� ������ �������� �� ����, ��ü ������ �ٸ� ġ�ᱺ�� ����.' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resnm := '��������10/5mg' + FormatDateTime('yyyymmddhhnnsszzz',now);
        AddadComment( CItem );
    end;
    AddrxDrug( rxDrug );

    // 11
    rxDrug := TrxDrugListItem.Create;
    with rxDrug do
    begin
      drugCode := '26800751';
      drugKorName := '�׸��ҳ�0.3%����';
      drugEngName := '�׸��ҳ�0.3%����';
      drugReimbursementType := 2; // 1:�޿�, 2:��޿�, 3:100/100, 4:100/80, 5:100/50, 6:100/30, 7: 100:90
      drugAdminRoute := 1; // 0:����, 1:�ܿ�, 2:�ֻ���
      drugDose := '1'; // 1ȸ ������
      totalAdminDose := '1';  // ��������
      drugAdminCount := '1';  // 1ȸ ����Ƚ��
      drugTreatmentPeriod := '1';  // �� �����ϼ�
      drugAdminCode := 'O1';// ��� �ڵ�
      drugAdminComment := 'ȯ�ο� �ٸ�����'; // ���
      drugOutsideFlag := 1; // 1(����), 2(����)
      docClsType := 1; //  ������ ���: 3 ������ �ƴ� ���: 1
      docComment := '';
      prnCheck := 0; //  1: prn ó���� ���, 0: prn ó���� �ƴ� ���

      ingredientName := '';
      drugListEnrollType := 0; //  0:��ǰ��, 1:���и�(����), 2:���и�(�ѱ�), Default = '0'
      drugPackageFlag := 1;    // 1:���Ѵ���, 0:�׿ܾ�ǰ
        CItem := TadCommentItem.Create;
        CItem.resnm := '�ߺ����� ġ�ᱺ' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resncnts := '���� ġ�ᱺ �� �ϳ��� ����� ������ �������� �� ����, ��ü ������ �ٸ� ġ�ᱺ�� ����.' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resnm := '��������10/5mg' + FormatDateTime('yyyymmddhhnnsszzz',now);
        AddadComment( CItem );
    end;
    AddrxDrug( rxDrug );

    // 12
    rxDrug := TrxDrugListItem.Create;
    with rxDrug do
    begin
      drugCode := '642101410';
      drugKorName := '����2%���긮��ī�ο��ǳ������ֻ�(1:80,000)';
      drugEngName := '����2%���긮��ī�ο��ǳ������ֻ�(1:80,000)';
      drugReimbursementType := 7; // 1:�޿�, 2:��޿�, 3:100/100, 4:100/80, 5:100/50, 6:100/30, 7: 100:90
      drugAdminRoute := 2; // 0:����, 1:�ܿ�, 2:�ֻ���
      drugDose := '1'; // 1ȸ ������
      totalAdminDose := '1';  // ��������
      drugAdminCount := '1';  // 1ȸ ����Ƚ��
      drugTreatmentPeriod := '1';  // �� �����ϼ�
      drugAdminCode := 'P1';// ��� �ڵ�
      drugAdminComment := '�ʿ�� ������� �ֻ��ϼ���'; // ���
      drugOutsideFlag := 1; // 1(����), 2(����)
      docClsType := 3; //  ������ ���: 3 ������ �ƴ� ���: 1
      docComment := '��޿�';
      prnCheck := 1; //  1: prn ó���� ���, 0: prn ó���� �ƴ� ���

      ingredientName := '';
      drugListEnrollType := 0; //  0:��ǰ��, 1:���и�(����), 2:���и�(�ѱ�), Default = '0'
      drugPackageFlag := 1;    // 1:���Ѵ���, 0:�׿ܾ�ǰ
        CItem := TadCommentItem.Create;
        CItem.resnm := '�ߺ����� ġ�ᱺ' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resncnts := '���� ġ�ᱺ �� �ϳ��� ����� ������ �������� �� ����, ��ü ������ �ٸ� ġ�ᱺ�� ����.' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resnm := '��������10/5mg' + FormatDateTime('yyyymmddhhnnsszzz',now);
        AddadComment( CItem );
    end;
    AddrxDrug( rxDrug );
  end;
end;

procedure TReceptionMngForm.LiteQuery1AfterOpen(DataSet: TDataSet);
begin
  Button2.Enabled := not DataSet.Eof;
  Button3.Enabled := Button2.Enabled;
  Button4.Enabled := Button2.Enabled;
  Button5.Enabled := Button2.Enabled;
  Button6.Enabled := Button2.Enabled;
end;

procedure TReceptionMngForm.LiteQuery1AfterPost(DataSet: TDataSet);
begin
  DBGrid1.Options := [dgTitles,dgIndicator,dgColumnResize,dgColLines,dgRowLines,dgTabs,dgRowSelect,dgAlwaysShowSelection,dgConfirmDelete,dgCancelOnExit,dgTitleClick,dgTitleHotTrack];
end;

procedure TReceptionMngForm.LiteQuery1BeforeClose(DataSet: TDataSet);
begin
  Button5.Enabled := False;
  Button6.Enabled := False;
end;

procedure TReceptionMngForm.LiteQuery1BeforeInsert(DataSet: TDataSet);
begin
  DBGrid1.Options := [dgEditing,dgTitles,dgIndicator,dgColumnResize,dgColLines,dgRowLines,dgTabs,dgConfirmDelete,dgCancelOnExit,dgTitleClick,dgTitleHotTrack];
end;

function TReceptionMngForm.MakeEvent354(
  AChartReceptnResultId : TChartReceptnResultId): TBridgeRequest_354;
(*var
  i : Integer;
  CItem: TadCommentItem; *)
begin
  Result := TBridgeRequest_354( GBridgeFactory.MakeRequestObj( EventID_����ó�����߱� ) );
  with make_354 do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add('select * from ');
    SQL.Add('   reception m ');
    SQL.Add('   inner join patient as s on (m.chartid = s.chartid) ');
    SQL.Add('where ');
    SQL.Add('   chartrrid1 = :chartrrid1 ');
    SQL.Add('   and chartrrid2 = :chartrrid2 ');
    SQL.Add('   and chartrrid3 = :chartrrid3 ');
    SQL.Add('   and chartrrid4 = :chartrrid4 ');
    SQL.Add('   and chartrrid5 = :chartrrid5 ');
    SQL.Add('   and chartrrid6 = :chartrrid6 ');

    ParamByName( 'chartrrid1' ).Value := AChartReceptnResultId.Id1;
    ParamByName( 'chartrrid2' ).Value := AChartReceptnResultId.Id2;
    ParamByName( 'chartrrid3' ).Value := AChartReceptnResultId.Id3;
    ParamByName( 'chartrrid4' ).Value := AChartReceptnResultId.Id4;
    ParamByName( 'chartrrid5' ).Value := AChartReceptnResultId.Id5;
    ParamByName( 'chartrrid6' ).Value := AChartReceptnResultId.Id6;
    Active := True;
    with Result do
    begin
      HospitalNo := GHospitalNo;
      gdid := FieldByName( 'gdid' ).AsString;
      patientUnitNo := FieldByName('chartid').AsString;
      ePrescriptionPatient := FieldByName( 'prescription' ).AsInteger;
      chartReceptnResultId := AChartReceptnResultId;
      version := '0.1';
      patientName := FieldByName('name').AsString;
      insureName := patientName;
      patientSid := FieldByName('regnum').AsString;
      patientAge := 50;
      patientSex := Gender( FieldByName('sex').AsString );
      patientAddr := FieldByName('addr').AsString + ifthen(FieldByName('addrdetail').AsString = '', '', ' ' + FieldByName('addrdetail').AsString);
      reimburseType := ElectronicPrescriptionsDefaultForm.Get_reimburseType;
      reimburseTypeName := ElectronicPrescriptionsDefaultForm.Get_reimburseTypeName;
      reimburseDetailType := ElectronicPrescriptionsDefaultForm.Get_reimburseDetailType;
      reimburseDetailName := ElectronicPrescriptionsDefaultForm.Get_reimburseDetailName;
      reimburseExcpCalc := ElectronicPrescriptionsDefaultForm.Get_reimburseExcpCalc;
      reimburseViewDetailName := ElectronicPrescriptionsDefaultForm.Get_reimburseViewDetailName;
      excpCalcCode := ElectronicPrescriptionsDefaultForm.Get_excpCalcCode;
      identifyingSid := ElectronicPrescriptionsDefaultForm.Get_identifyingSid;
      relationPatnt := ElectronicPrescriptionsDefaultForm.Get_relationPatnt;
      organUnitNo := ElectronicPrescriptionsDefaultForm.Get_organUnitNo;
      organName := ElectronicPrescriptionsDefaultForm.Get_organName;
      patriotId := ElectronicPrescriptionsDefaultForm.Get_patriotId;
      accidentHospUnitNo := ElectronicPrescriptionsDefaultForm.Get_accidentHospUnitNo;
      accidentManagementNo := ElectronicPrescriptionsDefaultForm.Get_accidentManagementNo;
      accidentWorkplaceName := ElectronicPrescriptionsDefaultForm.Get_accidentWorkplaceName;
      accidentHappenDate := ElectronicPrescriptionsDefaultForm.Get_accidentHappenDate;
      specialCode := ElectronicPrescriptionsDefaultForm.Get_specialCode;

      rxSerialNo := ElectronicPrescriptionsDefaultForm.Get_rxSerialNo;

      rxMedInfoNo := ElectronicPrescriptionsDefaultForm.Get_rxMedInfoNo;
      rxAllMedNo := ElectronicPrescriptionsDefaultForm.Get_rxAllMedNo;
      rxMakeDate := ElectronicPrescriptionsDefaultForm.Get_rxMakeDate;
      rxIssueTimestamp := ElectronicPrescriptionsDefaultForm.Get_rxIssueTimestamp;
      hospUnitNo := GHospitalNo;
      medicalCenterName := ElectronicPrescriptionsDefaultForm.Get_HospitalName;
      hospName := ElectronicPrescriptionsDefaultForm.Get_HospitalName;
      hospTelNo := '070'+ GHospitalNo;
      hospFaxNo := '02'+ GHospitalNo;
      hospRepName := hospName;
      hospEmail := GHospitalNo+'@emul.co.kr';
      hospAddr := ElectronicPrescriptionsDefaultForm.Get_HospitalAddr;
      hospUrl := 'http://'+GHospitalNo+'.co.kr';
      deptMediCode := FieldByName('deptcode').AsString;
      docLicenseNo := FieldByName('doctorcode').AsString;
      docName := FieldByName('doctorname').AsString;
      docLicenseType := '1'; // 1:�ǻ�, 2:���ǻ�, 3:���ǻ�, 4:ġ���ǻ�, 5:��Ÿ
      docLicenseTypeName := '�ǻ�';  // �ǻ�, ���ǻ�, ���ǻ�, ġ���ǻ�, ��Ÿ
      docSpecialty := FieldByName('deptname').AsString;
      docTelNo := '010'+ GHospitalNo;
      docEmail := FieldByName('doctorcode').AsString+'@doctor.co.kr';
      diagnosisCode1 := ElectronicPrescriptionsDefaultForm.Get_diagnosisCode1;
      diagnosisCode2 := ElectronicPrescriptionsDefaultForm.Get_diagnosisCode2;
      diagnosisCode3 := ElectronicPrescriptionsDefaultForm.Get_diagnosisCode3;
      rxEffectivePeriod := ElectronicPrescriptionsDefaultForm.Get_rxEffectivePeriod;
      nextVisitDate := ElectronicPrescriptionsDefaultForm.Get_nextVisitDate;

      case FDataFlag of
        1 : forDispensingComment := ElectronicPrescriptionsDefaultForm.Get_forDispensingComment;
      else
        forDispensingComment := '';
      end;

      specialComment := ElectronicPrescriptionsDefaultForm.Get_specialComment;
      topComment1 := ElectronicPrescriptionsDefaultForm.Get_topComment1;
      topComment2 := ElectronicPrescriptionsDefaultForm.Get_topComment2;
      topComment3 := ElectronicPrescriptionsDefaultForm.Get_topComment3;
      centerComment1 := ElectronicPrescriptionsDefaultForm.Get_centerComment1;
      centerComment2 := ElectronicPrescriptionsDefaultForm.Get_centerComment2;
      centerComment3 := ElectronicPrescriptionsDefaultForm.Get_centerComment3;
      bottomComment1 := ElectronicPrescriptionsDefaultForm.Get_bottomComment1;
      bottomComment2 := ElectronicPrescriptionsDefaultForm.Get_bottomComment2;
      bottomComment3 := ElectronicPrescriptionsDefaultForm.Get_bottomComment3;


(*      // ó���� �ΰ� ����
      for i := 1 to 10 do
      begin
        CItem := TadCommentItem.Create;
        CItem.resnm := '�ߺ����� ġ�ᱺ' + format('_%d_',[i])+ FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resncnts := '���� ġ�ᱺ �� �ϳ��� ����� ������ �������� �� ����, ��ü ������ �ٸ� ġ�ᱺ�� ����.' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resnm := '��������10/5mg' + format('_%d_',[i]) + FormatDateTime('yyyymmddhhnnsszzz',now);
        AddadComment( CItem );
      end; *)

//      InputDrug_1( Result );
      // �� ó�� �� ���
      case FDataFlag of
        1 : InputDrug_1( Result );
      else // 0
        InputDrug_0( Result );
      end;
      inc( FDataFlag );
      if FDataFlag > 2 then
        FDataFlag := 0;
    end;
    Active := False;
  end;
end;

procedure TReceptionMngForm.N12Click(Sender: TObject);
var
  crrid : TChartReceptnResultId;
  form : TAccountRequestForm;
begin // ���� ��û
  crrid.Id1 := LiteQuery1.FieldByName('chartrrid1').AsString;
  crrid.Id2 := LiteQuery1.FieldByName('chartrrid2').AsString;
  crrid.Id3 := LiteQuery1.FieldByName('chartrrid3').AsString;
  crrid.Id4 := LiteQuery1.FieldByName('chartrrid4').AsString;
  crrid.Id5 := LiteQuery1.FieldByName('chartrrid5').AsString;
  crrid.Id6 := LiteQuery1.FieldByName('chartrrid6').AsString;
  if AccountDM.CheckAccountPatient( crrid ) then
  begin
    if FCheckAutoAccountProcess then // �ڵ� ������ ��쿡�� �Ʒ� message�� ��� �Ѵ�.
    begin
      if MessageDlg( '�ڵ����� ���� ȯ���Դϴ�.' + #13#10 + '�ڵ����� ȭ������ �̵� �Ͻðڽ��ϱ�?', mtConfirmation, mbYesNo, 0) = mrNo then
        exit;
    end;
  end
  else
  begin
    if not FCheckAutoAccountProcess then // �ڵ� ���� process�� ��� �Ʒ� message�� ������� �ʴ´�.
      MessageDlg( '���� ������ �ȵǾ� �ִ� ȯ���Դϴ�.', mtWarning, [mbOK], 0);
    exit;
  end;

  form := TAccountRequestForm.Create( nil );
  try
    form.chartReceptnResultId.Id1 := LiteQuery1.FieldByName('chartrrid1').AsString;
    form.chartReceptnResultId.Id2 := LiteQuery1.FieldByName('chartrrid2').AsString;
    form.chartReceptnResultId.Id3 := LiteQuery1.FieldByName('chartrrid3').AsString;
    form.chartReceptnResultId.Id4 := LiteQuery1.FieldByName('chartrrid4').AsString;
    form.chartReceptnResultId.Id5 := LiteQuery1.FieldByName('chartrrid5').AsString;
    form.chartReceptnResultId.Id6 := LiteQuery1.FieldByName('chartrrid6').AsString;

    if form.ShowModal = mrOk then
    begin
      LiteQuery1.Edit;
        LiteQuery1.FieldByName( 'userAmt' ).AsLongWord := form.userAmt;
        LiteQuery1.FieldByName( 'nhisAmt' ).AsLongWord := form.nhisAmt;
        LiteQuery1.FieldByName( 'totalAmt' ).AsLongWord := form.totalAmt;
        LiteQuery1.FieldByName( 'payauthno' ).AsString := form.payAuthNo;
        LiteQuery1.FieldByName( 'planMonth' ).AsString := form.planMonth;
        LiteQuery1.FieldByName( 'transdttm' ).AsString := form.transDttm;
      LiteQuery1.Post;
    end;
  finally
    FreeAndNil( form );
  end;
end;

procedure TReceptionMngForm.N13Click(Sender: TObject);
var
  //rid : LongWord;
  msg, transdttm, rcd, resultmsg : string;
begin  // ���� ���
  msg := format('���� ���� : %s(%s) ',[LiteQuery1.FieldByName('chartid').AsString, LiteQuery1.FieldByName('chartrrid1').AsString]);
  msg := msg + #13#10 + format('�������ι�ȣ : %s ',[ LiteQuery1.FieldByName('payauthno').AsString ]);
  msg := msg + #13#10 + format('�ݾ� : ȯ�� �δ��(%s), ���� �δ��(%s), �� �ݾ�(%s) ',[
                                          FormatFloat('#,0',LiteQuery1.FieldByName('userAmt').AsLongWord),
                                          FormatFloat('#,0',LiteQuery1.FieldByName('nhisAmt').AsLongWord),
                                          FormatFloat('#,0',LiteQuery1.FieldByName('totalAmt').AsLongWord) ]);
  msg := msg + #13#10 + format('�Һ� ���� : %s ',[ LiteQuery1.FieldByName('planMonth').AsString ]);
  msg := msg + #13#10#13#10 + '���� ������ ����Ͻðڽ��ϱ�?';
  //rid := LiteQuery1.FieldByName('rid').AsLongWord;

  if MessageDlg( msg, mtConfirmation, mbYesNo, 0) = mrNo then
    exit;

  if AccountDM.Send144(LiteQuery1.FieldByName('chartrrid1').AsString, LiteQuery1.FieldByName('payauthno').AsString, '������~~ �׳�', transdttm, rcd, resultmsg) <> Result_SuccessCode then
  begin
    MessageDlg( resultmsg, mtInformation, [mbOK], 0);
    exit;
  end;

  if rcd = '00' then
  begin
    LiteQuery1.Edit;
      LiteQuery1.FieldByName( 'userAmt' ).AsLongWord := 0;
      LiteQuery1.FieldByName( 'nhisAmt' ).AsLongWord := 0;
      LiteQuery1.FieldByName( 'totalAmt' ).AsLongWord := 0;
      LiteQuery1.FieldByName( 'payauthno' ).AsString := '';
      LiteQuery1.FieldByName( 'planMonth' ).AsString := '';

      LiteQuery1.FieldByName( 'transdttm' ).AsString := transdttm;
    LiteQuery1.Post;

    MessageDlg( '��� �Ǿ����ϴ�.', mtInformation, [mbOK], 0);
  end
  else
  begin
    MessageDlg( resultmsg, mtError, [mbOK], 0);
  end;
end;

procedure TReceptionMngForm.N7Click(Sender: TObject);
var
  isDummy : Boolean;
  //isOnlyEP : Boolean;
  statuscode : string;
  gdid : string;
  event_108 : TBridgeRequest_108;
  responsebase : TBridgeResponse;
  ret : string;
begin // ���� �Ϸ�
  if not ( Sender is TMenuItem ) then
    exit;

  //isOnlyEP := False;
  case TMenuItem( Sender ).tag of
    1 : statuscode := Status_������û; // ���� ��û
    2 : statuscode := Status_����Ȯ��;// ���� Ȯ��
    3 : statuscode := Status_������;// ���� ���
    4 : statuscode := Status_����Ϸ�;// ���� �Ϸ�
    //5 : isOnlyEP := True;// ���� ó���� �߼� test
    11 : statuscode := Status_�������;// ���� ���
    12 : statuscode := Status_�������;// ���� ���
    13 : statuscode := Status_�ڵ����;// �ڵ� ���
  else
    exit;
  end;

  isDummy := LiteQuery1.FieldByName( 'dummy' ).AsInteger = 1;
  gdid := LiteQuery1.FieldByName( 'gdid' ).AsString;

  GSendReceptionPeriodRoomInfo.RoomCode := LiteQuery1.FieldByName('roomcode').AsString;
  GSendReceptionPeriodRoomInfo.RoomName := LiteQuery1.FieldByName('roomname').AsString;
  GSendReceptionPeriodRoomInfo.DeptCode := LiteQuery1.FieldByName('deptcode').AsString;
  GSendReceptionPeriodRoomInfo.DeptName := LiteQuery1.FieldByName('deptname').AsString;
  GSendReceptionPeriodRoomInfo.DoctorCode := LiteQuery1.FieldByName('doctorcode').AsString;
  GSendReceptionPeriodRoomInfo.DoctorName := LiteQuery1.FieldByName('doctorname').AsString;

  LiteQuery1.Edit;
      LiteQuery1.FieldByName( 'status' ).AsString := statuscode; // ���� ����
      LiteQuery1.FieldByName( 'statusmng' ).AsString := statuscode; // ���� ����
  LiteQuery1.Post;

  event_108 := TBridgeRequest_108( GBridgeFactory.MakeRequestObj( EventID_��⿭���°����� ) );
  event_108.HospitalNo := GHospitalNo;
  event_108.ReceptionUpdateDto.chartReceptnResultId.Id1 := LiteQuery1.FieldByName('chartrrid1').AsString;
  event_108.ReceptionUpdateDto.chartReceptnResultId.Id2 := LiteQuery1.FieldByName('chartrrid2').AsString;
  event_108.ReceptionUpdateDto.chartReceptnResultId.Id3 := LiteQuery1.FieldByName('chartrrid3').AsString;
  event_108.ReceptionUpdateDto.chartReceptnResultId.Id4 := LiteQuery1.FieldByName('chartrrid4').AsString;
  event_108.ReceptionUpdateDto.chartReceptnResultId.Id5 := LiteQuery1.FieldByName('chartrrid5').AsString;
  event_108.ReceptionUpdateDto.chartReceptnResultId.Id6 := LiteQuery1.FieldByName('chartrrid6').AsString;

  event_108.ReceptionUpdateDto.PatientChartId := LiteQuery1.FieldByName('chartid').AsString;
  event_108.ReceptionUpdateDto.RoomInfo.RoomCode := GSendReceptionPeriodRoomInfo.RoomCode;
  event_108.ReceptionUpdateDto.RoomInfo.RoomName := GSendReceptionPeriodRoomInfo.RoomName;
  event_108.ReceptionUpdateDto.RoomInfo.DeptCode := GSendReceptionPeriodRoomInfo.DeptCode;
  event_108.ReceptionUpdateDto.RoomInfo.DeptName := GSendReceptionPeriodRoomInfo.DeptName;
  event_108.ReceptionUpdateDto.RoomInfo.DoctorCode := GSendReceptionPeriodRoomInfo.DoctorCode;
  event_108.ReceptionUpdateDto.RoomInfo.DoctorName := GSendReceptionPeriodRoomInfo.DoctorName;
  event_108.ReceptionUpdateDto.Status := statuscode;
  event_108.receptStatusChangeDttm     := now;

  event_108.NewchartReceptnResult.Id1 := '';
  event_108.NewchartReceptnResult.Id2 := '';
  event_108.NewchartReceptnResult.Id3 := '';
  event_108.NewchartReceptnResult.Id4 := '';
  event_108.NewchartReceptnResult.Id5 := '';
  event_108.NewchartReceptnResult.Id6 := '';

{$ifdef _EP_}
  if (statuscode = Status_����Ϸ�) and ( gdid <> '' ) then
  begin // �Ϸ� �̰�, gdid�� �ִ� ȯ�ڸ� ���� ó������ �����ϰ� �Ѵ�.
    // ���� ó���� ó��
    processEP( event_108.ReceptionUpdateDto.PatientChartId,
               PatientMngForm.GetGDID(event_108.ReceptionUpdateDto.PatientChartId),
               event_108.ReceptionUpdateDto.chartReceptnResultId );
  end;
{$endif}

  UpdatePeriod(now, GSendReceptionPeriodRoomInfo.RoomCode);

  if isDummy then
  begin
    ChartEmulV4Form.AddMemo( format('������ȣ(%s)�� ���� data�� ���� ���� data�� �������� �ʴ´�.',[event_108.ReceptionUpdateDto.chartReceptnResultId.Id1]) );
  end
  else
  begin //
    ChartEmulV4Form.AddMemo( event_108.EventID, event_108.JobID );
    ret := GetBridge.RequestResponse( event_108.ToJsonString );
    responsebase := GBridgeFactory.MakeResponseObj( ret );
    ChartEmulV4Form.AddMemo( responsebase.EventID, responsebase.JobID, responsebase.Code, responsebase.MessageStr, 0 );
    FreeAndNil( responsebase );
  end;

  // �ڵ� ���� ó��
  if AccountDM.Active and (statuscode = Status_����Ϸ�) then
  begin
    FCheckAutoAccountProcess := True;
    try
      N12Click(nil);
    except
    end;
    FCheckAutoAccountProcess := False;
  end;

  GSendReceptionPeriod := True;

  FreeAndNil( event_108 );
end;

procedure TReceptionMngForm.openprocessquery;
begin
  processQuery.Active := False;
  processQuery.SQL.Text := 'select * from reception where receptiondate = :receptiondate order by receptiondate desc, period';
  processQuery.ParamByName( 'receptiondate' ).Value := FormatDateTime('yyyy-mm-dd', now);
  processQuery.Active := True;
end;

function TReceptionMngForm.processEP(
  AChartID, AGDID : string; AChartReceptnResultId: TChartReceptnResultId): Boolean;
{$ifdef _EP_}
var
  event_354 : TBridgeRequest_354;
{$endif}
begin
{$ifdef _EP_}
  Result := False;
  if GElectronicPrescriptionsOption = 0 then
    exit; // ���� ó���� ó�� ������ �ƴϴ�.

{
���� ó������ ����ϴ� �����̶�� ��� ȯ�ڿ� ���� ó������ ���� �Ҽ� �ְ� �Ѵ�.
��, gdid�� �ִ� ȯ�ڸ� �����ϰ� �Ѵ�.
  // ȯ�� ������ check�Ͽ� ���� ó���� ����ϴ� ȯ������ Ȯ�� �Ѵ�.
  //if PatientMngForm.GetPatientPrescription( AChartID ) = 0 then
  //  exit; // ���� ó������ ����ϴ� ȯ�ڰ� �ƴϴ�. }

  if AGDID = '' then
    exit; // goodoc id�� ������ ���� ó������ �������� �ʴ´�

  Timer_354.Enabled := False;
  // ���� ���� Ȯ���Ͽ� prescription�� true�̸� 354�� ���� �Ѵ�.
  event_354 := MakeEvent354( AChartReceptnResultId );
  FSendQueue_354.Add( event_354 );

  Timer_354.Enabled := FSendQueue_354.Count <> 0;
{$else}
  Result := False;
{$endif}
end;

function TReceptionMngForm.Send354(AEvent354: TBridgeRequest_354): Boolean;
{$ifdef _EP_}
var
  str : string;
  responsebase : TBridgeResponse;
{$endif}
begin
{$ifdef _EP_}
  ChartEmulV4Form.AddMemo( EventID_����ó�����߱�, AEvent354.JobID );

  str := GetBridge.RequestResponse( AEvent354.ToJsonString );
  responsebase := GBridgeFactory.MakeResponseObj( str );
  Result := responsebase.Code = Result_SuccessCode;
  ChartEmulV4Form.AddMemo( responsebase.EventID, responsebase.JobID, responsebase.Code, responsebase.MessageStr, 0 );
  FreeAndNil( responsebase );
  FreeAndNil( AEvent354 );
{$else}
  Result := True;
{$endif}
end;

procedure TReceptionMngForm.SendPeriod(ADate : TDateTime;
  ARoomInfo: TRoomInfoRecord);
var
  str : string;
  event_104 : TBridgeRequest_104;
  responsebase : TBridgeResponse;
begin
  LiteQuery2.Active := False;

  // ���� ����, ���� roomcode, period������ ���� ���...
  with LiteQuery2 do
  begin
    //SQL.Text := 'select * from reception where status in (''C04'', ''C07'') and roomcode = :roomcode and receptiondate = :receptiondate order by period';  //  C04(������), C08(������)
    SQL.Text := 'select * from reception where status in (''C04'', ''C05'', ''C06'', ''C07'') and roomcode = :roomcode and receptiondate = :receptiondate order by period';  //  C04(������), C08(������)
    ParamByName('roomcode').Value := ARoomInfo.RoomCode;
    ParamByName('receptiondate').Value := FormatDateTime('yyyy-mm-dd', ADate);
    Active := True;
    try
      First;

      event_104 := TBridgeRequest_104( GBridgeFactory.MakeRequestObj( EventID_���������� ) );
      try
        event_104.HospitalNo := GHospitalNo;
        event_104.RoomInfo := ARoomInfo;
        while not eof do
        begin
          event_104.Add( FieldByName('chartrrid1').AsString,
                         FieldByName('chartrrid2').AsString,
                         FieldByName('chartrrid3').AsString,
                         FieldByName('chartrrid4').AsString,
                         FieldByName('chartrrid5').AsString,
                         FieldByName('chartrrid6').AsString );
          Next;
        end;

        addlog( doRunLog, '���� : ' + event_104.ToJsonString);
        ChartEmulV4Form.AddMemo( event_104.EventID, event_104.JobID );
        str := GetBridge.RequestResponse( event_104.ToJsonString );
        addlog( doRunLog, '��� : ' + str);
        responsebase := GBridgeFactory.MakeResponseObj( str );
        try
          ChartEmulV4Form.AddMemo( responsebase.EventID, responsebase.JobID, responsebase.Code, responsebase.MessageStr, 0 );
          if event_104.JobID <> responsebase.JobID then
          begin
            ChartEmulV4Form.AddMemo( format('EventID:%d�� ���� JobID���� ���ų� Ʋ����.(JobID=%s)', [responsebase.EventID, responsebase.JobID]) );
            AddLog(doWarningLog, format('EventID:%d�� ���� JobID���� ���ų� Ʋ����.(JobID=%s)', [responsebase.EventID, responsebase.JobID]) );
          end;
        finally
          freeandnil( responsebase );
        end;
      finally
        freeandnil( event_104 );
      end;
    finally
      Active := False;
    end;
  end;
end;

procedure TReceptionMngForm.Timer_354Timer(Sender: TObject);
{$ifdef _EP_}
var
  event_354 : TBridgeRequest_354;
{$endif}
begin
{$ifdef _EP_}
  if FSendQueue_354.Count <= 0 then
  begin
    Timer_354.Enabled := False;
    exit;
  end;

  event_354 := TBridgeRequest_354( FSendQueue_354.Items[ 0 ] );
  FSendQueue_354.Delete( 0 );

  Send354(event_354);

  Timer_354.Enabled := FSendQueue_354.Count <> 0;
{$endif}
end;

function TReceptionMngForm.UpdateEP_Reception(
  AEvent352: TBridgeResponse_352): TBridgeResponse_353;
var
  itmp : Integer;
begin
  Result := TBridgeResponse_353( GBridgeFactory.MakeRequestObj(EventID_����ó�����߱޼������, AEvent352.JobID ) );
  if AEvent352.AnalysisErrorCode <> Result_SuccessCode then
  begin
    Result.Code := AEvent352.AnalysisErrorCode;
    Result.MessageStr :=  GBridgeFactory.GetErrorString( Result.Code );
    exit;
  end;

  try
    //gdid�� �̿��ؼ� hipass, prescription���� update�Ѵ�.
    with update_356 do
    begin
      SQL.Clear;
      SQL.Add( 'update reception ' );
      SQL.Add( 'set ' );

      SQL.Add( '  hipass = :hipass, ' );
      SQL.Add( '  prescription = :prescription, ' );
      SQL.Add( '  parmno = :parmno, ' );
      SQL.Add( '  parmnm = :parmnm, ' );
      SQL.Add( '  extrainfo = :extrainfo, ' );
      SQL.Add( '  gdid = :gdid ' );
      SQL.Add( 'where ' );
      SQL.Add( '  chartrrid1 = :chartrrid1 and ' );
      SQL.Add( '  chartrrid2 = :chartrrid2 and ' );
      SQL.Add( '  chartrrid3 = :chartrrid3 and ' );
      SQL.Add( '  chartrrid4 = :chartrrid4 and ' );
      SQL.Add( '  chartrrid5 = :chartrrid5 and ' );
      SQL.Add( '  chartrrid6 = :chartrrid6 ' );

      itmp :=  AEvent352.Hipass;
      if AEvent352.Hipass = 9 then
        itmp := 0;
      ParamByName( 'hipass' ).Value := itmp;
      itmp :=  AEvent352.Prescription;
      if AEvent352.Prescription = 9 then
        itmp := 0;

      ParamByName( 'prescription' ).Value := itmp;
      ParamByName( 'gdid' ).Value := AEvent352.Gdid;
      ParamByName( 'parmno' ).Value := AEvent352.ParmNo;
      ParamByName( 'parmnm' ).Value := AEvent352.ParmNm;
      ParamByName( 'extrainfo' ).Value := AEvent352.ExtraInfo;
      ParamByName( 'chartrrid1' ).Value := AEvent352.chartReceptnResultId.Id1;
      ParamByName( 'chartrrid2' ).Value := AEvent352.chartReceptnResultId.Id2;
      ParamByName( 'chartrrid3' ).Value := AEvent352.chartReceptnResultId.Id3;
      ParamByName( 'chartrrid4' ).Value := AEvent352.chartReceptnResultId.Id4;
      ParamByName( 'chartrrid5' ).Value := AEvent352.chartReceptnResultId.Id5;
      ParamByName( 'chartrrid6' ).Value := AEvent352.chartReceptnResultId.Id6;
      ExecSQL;
    end;
    Result.Code := Result_SuccessCode;
    Result.MessageStr := GBridgeFactory.GetErrorString( Result.Code );
  except
    on e : exception do
    begin
      Result.Code := Result_ExceptionError;
      Result.MessageStr := Format('%s(%s)',[e.Message, e.ClassName]);
    end;
  end;

end;

procedure TReceptionMngForm.UpdatePeriod( AUpdateDate : TDateTime; ARoomCode : string );
  procedure send108( AQuery : TLiteQuery );
  var
    ret : string;
    event_108 : TBridgeRequest_108;
    responsebase : TBridgeResponse;
  begin
(*https://goodoc.slack.com/archives/GTK8AMQP4/p1581993927103400
�̰��̶�� ���⼭ data�� �����ϸ� �ʵǴµ�...
���� data�� �ø��� �ʴ´�.
*)
    exit;

    event_108 := TBridgeRequest_108( GBridgeFactory.MakeRequestObj( EventID_��⿭���°����� ) );
    try
      event_108.HospitalNo := GHospitalNo;
      event_108.ReceptionUpdateDto.chartReceptnResultId.Id1 := AQuery.FieldByName('chartrrid1').AsString;
      event_108.ReceptionUpdateDto.chartReceptnResultId.Id2 := AQuery.FieldByName('chartrrid2').AsString;
      event_108.ReceptionUpdateDto.chartReceptnResultId.Id3 := AQuery.FieldByName('chartrrid3').AsString;
      event_108.ReceptionUpdateDto.chartReceptnResultId.Id4 := AQuery.FieldByName('chartrrid4').AsString;
      event_108.ReceptionUpdateDto.chartReceptnResultId.Id5 := AQuery.FieldByName('chartrrid5').AsString;
      event_108.ReceptionUpdateDto.chartReceptnResultId.Id6 := AQuery.FieldByName('chartrrid6').AsString;

      event_108.ReceptionUpdateDto.PatientChartId := AQuery.FieldByName('chartid').AsString;
      event_108.ReceptionUpdateDto.RoomInfo.RoomCode := AQuery.FieldByName('roomcode').AsString;
      event_108.ReceptionUpdateDto.RoomInfo.RoomName := AQuery.FieldByName('roomname').AsString;
      event_108.ReceptionUpdateDto.RoomInfo.DeptCode := AQuery.FieldByName('deptcode').AsString;
      event_108.ReceptionUpdateDto.RoomInfo.DeptName := AQuery.FieldByName('deptname').AsString;
      event_108.ReceptionUpdateDto.RoomInfo.DoctorCode := AQuery.FieldByName('doctorcode').AsString;
      event_108.ReceptionUpdateDto.RoomInfo.DoctorName := AQuery.FieldByName('doctorname').AsString;
      event_108.ReceptionUpdateDto.Status := AQuery.FieldByName( 'status' ).AsString;
      event_108.receptStatusChangeDttm     := now;

      event_108.NewchartReceptnResult.Id1 := '';
      event_108.NewchartReceptnResult.Id2 := '';
      event_108.NewchartReceptnResult.Id3 := '';
      event_108.NewchartReceptnResult.Id4 := '';
      event_108.NewchartReceptnResult.Id5 := '';
      event_108.NewchartReceptnResult.Id6 := '';

      ChartEmulV4Form.AddMemo( event_108.EventID, event_108.JobID );
      ret := GetBridge.RequestResponse( event_108.ToJsonString );
      responsebase := GBridgeFactory.MakeResponseObj( ret );
      try
        ChartEmulV4Form.AddMemo( responsebase.EventID, responsebase.JobID, responsebase.Code, responsebase.MessageStr, 0 );
      finally
        FreeAndNil( responsebase );
      end;
    finally
      FreeAndNil( event_108 );
    end;
  end;

var
  isadd : Boolean;
  i, seq, oldseq : Integer;
  seqlist, c05list : TStringList;
begin
  seqlist := TStringList.Create;
  c05list := TStringList.Create;
  try
    // ���� ����, ���� roomcode, period������ ���� ���...
    with Query104 do
    begin
      Active := False;
      //SQL.Text := 'select * from reception where status in (''C04'', ''C07'') and roomcode = :roomcode and receptiondate = :receptiondate order by period';  //  C04(������), C08(������)
      // ���� C04, C05, C06, C07�� ���� ���� �����ؼ� ó�� ����.
      SQL.Text := 'select * from reception where status in (''C04'', ''C05'', ''C06'', ''C07'') and roomcode = :roomcode and receptiondate = :receptiondate order by period';  //  C04(������), C08(������)
      ParamByName('roomcode').Value := ARoomCode;
      ParamByName('receptiondate').Value := FormatDateTime('yyyy-mm-dd', AUpdateDate);
      Active := True;
      First;

      // ���� ��û ���¸� ����� ���� data �����
      seq := 0; isadd := False;
      while not eof do
      begin
        Inc( seq );
        oldseq := FieldByName( 'period' ).AsInteger;

        if not isadd then
        begin // ó�� data���� ����Ȯ�� data�̸� ���� ��Ͽ� ���� �Ѵ�.
          if FieldByName( 'statusmng' ).AsString = Status_������û then
          begin
            c05list.Add( inttostr(FieldByName( 'rid' ).AsInteger) );
            if oldseq = Const_Period_Send then
            begin // ���� ���¸� ������ ���� �Ѵ�.
              send108( LiteQuery2 ); // ���°� ����� data�� �����ϰ� �Ѵ�.
            end;
            Next;
            Continue;
          end
          else
            isadd := True;
        end;

        seqlist.Values[ inttostr(FieldByName( 'rid' ).AsInteger) ] := inttostr( seq ); // �⺻ ���� ���

        if oldseq = Const_Period_Send then
        begin // ���� ���¸� ������ ���� �Ѵ�.
          send108( Query104 ); // ���°� ����� data�� �����ϰ� �Ѵ�.
        end;

        if c05list.Count > 0 then
        begin
          // ���� ����Ȯ�� ��Ͽ� ����� data�� ���� ���� data�� �������ְ�
          for i := 0 to c05list.Count -1 do
          begin
            Inc( seq );
            seqlist.Values[ c05list.Strings[i] ] := inttostr( seq );
          end;
          // ����� �ʱ�ȭ �Ѵ�.
          c05list.Clear;
        end;

        next;
      end;
        // ���ǿ� apps���� ������ data�� ���� ���� �� ��� �Ѵ�.
        if c05list.Count > 0 then
        begin
          // ���� ����Ȯ�� ��Ͽ� ����� data�� ���� ���� data�� �������ְ�
          for i := 0 to c05list.Count -1 do
          begin
            Inc( seq );
            seqlist.Values[ c05list.Strings[i] ] := inttostr( seq );
          end;
          // ����� �ʱ�ȭ �Ѵ�.
          c05list.Clear;
        end;

      First;
      while not eof do
      begin
        seq := StrToIntDef( seqlist.Values[ IntToStr(FieldByName( 'rid' ).AsInteger) ], 0  );
        if seq = 0 then
        begin // ���� data�� ó�� ����. ó�� �� �� ���� data�̴�.
          Next;
          Continue;
        end;

        Edit;
        FieldByName( 'period' ).AsInteger := seq;
  (*      if seq = 1 then
          FieldByName( 'status' ).AsString := Status_��������; *)
        Post;

        Next;
      end;
      Active := False;
    end;
  finally
    FreeAndNil( seqlist );
    FreeAndNil( c05list );
  end;
end;

procedure TReceptionMngForm.UpdatePeriods(AUpdateDate: TDateTime;
  ARoomCodes: TStringList);
var
  i : Integer;
  rcode : string;
  rinfo : TRoomInfoRecord;
begin
  for i := 0 to ARoomCodes.Count -1 do
  begin
    rcode := ARoomCodes.Strings[ i ];
    addlog( doRunLog, '����Ȯ�ο�û���� ���� ���� ���� ���� ����' );
    UpdatePeriod( AUpdateDate, rcode );
    rinfo := GetRoomInfo( rcode );
    SendPeriod(now, rinfo);
    addlog( doRunLog, '����Ȯ�ο�û���� ���� ���� ���� ���� �Ϸ�' );
  end;
end;

function TReceptionMngForm.VisitConfirm(
  AVisitConfirmData: TBridgeResponse_110; ARoomList : TStringList): TBridgeRequest_111;
  procedure ConfirmResult( AConfirmList : TBridgeRequest_111 ; AData : TconfirmListItem; AConfirmResult : Integer );
  begin
    AConfirmList.Add(
            AData.chartReceptnResult.Id1,
            AData.chartReceptnResult.Id2,
            AData.chartReceptnResult.Id3,
            AData.chartReceptnResult.Id4,
            AData.chartReceptnResult.Id5,
            AData.chartReceptnResult.Id6,
            AData.receptnResveId,
            AData.receptnResveType,
            AConfirmResult
            );
  end;

var
  ret : Integer;
  retstr : string;
  i : Integer;
  data : TconfirmListItem;
  event_108 : TBridgeRequest_108;
  responsebase : TBridgeResponse;
begin
  ARoomList.Clear;
  Result := TBridgeRequest_111( GBridgeFactory.MakeRequestObj(EventID_����Ȯ�ο�û���, AVisitConfirmData.JobID ) );
  if AVisitConfirmData.AnalysisErrorCode <> Result_Success then
  begin
    Result.MessageStr := GBridgeFactory.GetErrorString( AVisitConfirmData.AnalysisErrorCode );
    exit;
  end;

  Result.MessageStr := '';
  Result.HospitalNo := AVisitConfirmData.HospitalNo;
  CheckBox1.Checked := AVisitConfirmData.reclnicOnly = 1; // ������ ������ UI�� ǥ��

  LiteQuery2.Active := False;

  // ��� ���� Ȯ�� ó���� �Ѵ�.
  for i := 0 to AVisitConfirmData.Count -1 do
  begin
    data := AVisitConfirmData.confirmList[ i ];

    ret := 0; // ����
    try
      //    db���� data �Ӽ��� ���� �Ѵ�.
      if data.receptnResveType = 0 then
      begin // ���� data�� ó��
       // ���� table�� �ִ� ���� ��ȣ�� ���� ����???
       // ����Ϸ� ���¿��� �������� ����� ���� �ؾ� �Ѵ�.

        with LiteQuery2 do
        begin
          SQL.Clear;
          SQL.Add( 'select * from reserve m ' );
          SQL.Add('   inner join patient as s on (m.chartid = s.chartid) ');
          SQL.Add( 'where ');
          SQL.Add( 'm.chartrrid1 = :chartrrid1 ');
          SQL.Add( 'and m.chartrrid2 = :chartrrid2 ' );
          SQL.Add( 'and m.chartrrid3 = :chartrrid3 ' );
          SQL.Add( 'and m.chartrrid4 = :chartrrid4 ' );
          SQL.Add( 'and m.chartrrid5 = :chartrrid5 ' );
          SQL.Add( 'and m.chartrrid6 = :chartrrid6 ' );

          if AVisitConfirmData.reclnicOnly = 1 then
          begin // ������ ���� ��, AVisitConfirmData.reclnicOnly 1�̸� ������ ����
            SQL.Add( 'and s.isfirst = 0 ');
          end;

          ParamByName( 'chartrrid1' ).Value := data.chartReceptnResult.Id1;
          ParamByName( 'chartrrid2' ).Value := data.chartReceptnResult.Id2;
          ParamByName( 'chartrrid3' ).Value := data.chartReceptnResult.Id3;
          ParamByName( 'chartrrid4' ).Value := data.chartReceptnResult.Id4;
          ParamByName( 'chartrrid5' ).Value := data.chartReceptnResult.Id5;
          ParamByName( 'chartrrid6' ).Value := data.chartReceptnResult.Id6;
          LiteQuery2.Active := True;
          LiteQuery2.First;
          if not LiteQuery2.Eof then
          begin // data�� �ִ�.
            // ����Ϸ� ������ data�� ���� ó���� �Ѵ�.
            if FieldByName('status').AsString = Status_����Ϸ� then
            begin
              ReservationMngForm.AddReception( LiteQuery2 );
              ret := 1; // ����
            end;
          end
          else
          begin // ���� ȯ�ڰ� ���� �ߴ�.
            if AVisitConfirmData.reclnicOnly = 1 then
            begin // ������ ���� ��
              ret := 0; // ����
              Result.isFirst := 1; // �ű� ȯ�ڴ�.
            end
            else
            begin
              if FieldByName('status').AsString = Status_����Ϸ� then
              begin
                ReservationMngForm.AddReception( LiteQuery2 );
                ret := 1; // ����
              end;
            end;
          end;
        end;
      end
      else
      begin  // ���� data�� ó��
        with LiteQuery2 do
        begin
          SQL.Clear;
          SQL.Add( 'select * from reception ' );
          SQL.Add( 'where ');
          SQL.Add( 'chartrrid1 = :chartrrid1 ');
          SQL.Add( 'and chartrrid2 = :chartrrid2 ' );
          SQL.Add( 'and chartrrid3 = :chartrrid3 ' );
          SQL.Add( 'and chartrrid4 = :chartrrid4 ' );
          SQL.Add( 'and chartrrid5 = :chartrrid5 ' );
          SQL.Add( 'and chartrrid6 = :chartrrid6 ' );
          SQL.Add( 'and status in (''C03'', ''C04'', ''C05'', ''C07'' ) ' );
          ParamByName( 'chartrrid1' ).Value := data.chartReceptnResult.Id1;
          ParamByName( 'chartrrid2' ).Value := data.chartReceptnResult.Id2;
          ParamByName( 'chartrrid3' ).Value := data.chartReceptnResult.Id3;
          ParamByName( 'chartrrid4' ).Value := data.chartReceptnResult.Id4;
          ParamByName( 'chartrrid5' ).Value := data.chartReceptnResult.Id5;
          ParamByName( 'chartrrid6' ).Value := data.chartReceptnResult.Id6;
          LiteQuery2.Active := True;
          LiteQuery2.First;
          if not LiteQuery2.Eof then
          begin // data�� �ִ�.
            // ���� ��û ������ data�� Ȯ�� ó���� �Ѵ�.
            //if FieldByName('statusmng').AsString = Status_������û then
            begin
              if ARoomList.IndexOf( FieldByName('roomcode').AsString ) < 0 then
                ARoomList.Add( FieldByName('roomcode').AsString );

              edit;
                FieldByName('status').AsString := Status_����Ȯ��;
                FieldByName('statusmng').AsString := Status_����Ȯ��;
              Post;

              event_108 := TBridgeRequest_108( GBridgeFactory.MakeRequestObj( EventID_��⿭���°����� ) );
              event_108.HospitalNo := GHospitalNo;
              event_108.ReceptionUpdateDto.chartReceptnResultId.Id1 := LiteQuery2.FieldByName('chartrrid1').AsString;
              event_108.ReceptionUpdateDto.chartReceptnResultId.Id2 := LiteQuery2.FieldByName('chartrrid2').AsString;
              event_108.ReceptionUpdateDto.chartReceptnResultId.Id3 := LiteQuery2.FieldByName('chartrrid3').AsString;
              event_108.ReceptionUpdateDto.chartReceptnResultId.Id4 := LiteQuery2.FieldByName('chartrrid4').AsString;
              event_108.ReceptionUpdateDto.chartReceptnResultId.Id5 := LiteQuery2.FieldByName('chartrrid5').AsString;
              event_108.ReceptionUpdateDto.chartReceptnResultId.Id6 := LiteQuery2.FieldByName('chartrrid6').AsString;

              event_108.ReceptionUpdateDto.PatientChartId := LiteQuery2.FieldByName('chartid').AsString;
              event_108.ReceptionUpdateDto.RoomInfo.RoomCode := LiteQuery2.FieldByName('roomcode').AsString;
              event_108.ReceptionUpdateDto.RoomInfo.RoomName := LiteQuery2.FieldByName('roomname').AsString;
              event_108.ReceptionUpdateDto.RoomInfo.DeptCode := LiteQuery2.FieldByName('deptcode').AsString;
              event_108.ReceptionUpdateDto.RoomInfo.DeptName := LiteQuery2.FieldByName('deptname').AsString;
              event_108.ReceptionUpdateDto.RoomInfo.DoctorCode := LiteQuery2.FieldByName('doctorcode').AsString;
              event_108.ReceptionUpdateDto.RoomInfo.DoctorName := LiteQuery2.FieldByName('doctorname').AsString;

              event_108.ReceptionUpdateDto.Status := Status_����Ȯ��;
              event_108.receptStatusChangeDttm     := now;

              event_108.NewchartReceptnResult.Id1 := '';
              event_108.NewchartReceptnResult.Id2 := '';
              event_108.NewchartReceptnResult.Id3 := '';
              event_108.NewchartReceptnResult.Id4 := '';
              event_108.NewchartReceptnResult.Id5 := '';
              event_108.NewchartReceptnResult.Id6 := '';
              ret := 1; // ����

              ChartEmulV4Form.AddMemo( event_108.EventID, event_108.JobID );
              retstr := GetBridge.RequestResponse( event_108.ToJsonString );
              responsebase := GBridgeFactory.MakeResponseObj( retstr );
              ChartEmulV4Form.AddMemo( responsebase.EventID, responsebase.JobID, responsebase.Code, responsebase.MessageStr, 0 );
              FreeAndNil( responsebase );
              FreeAndNil( event_108 );
            end; // if��
          end;
        end;
      end;
    finally
      LiteQuery2.Active := False;
    end;
    // ó�� ��� ���
    ConfirmResult( Result, data, ret );
  end;  // for��
  Result.Code := Result_Success;
  Result.MessageStr := '';
end;

function TReceptionMngForm.UpdatePatientStateByAutomation(const AChartReceptionResultId1, AStatusCode: string) : Boolean;
var
  isDummy : Boolean;
  //isOnlyEP : Boolean;
  gdid : string;
  event_108 : TBridgeRequest_108;
  responsebase : TBridgeResponse;
  ret : string;
  chartid, chartrrid1, chartrrid2, chartrrid3, chartrrid4, chartrrid5, chartrrid6 : string;
begin
  //isOnlyEP := False;
  Result := False;

  if (AStatusCode <> Status_������)
    and (AStatusCode <> Status_����Ȯ��)
    and (AStatusCode <> Status_�������)
    and (AStatusCode <> Status_�������)
    and (AStatusCode <> Status_�ڵ����)
    and (AStatusCode <> Status_����Ϸ�)
    and (AStatusCode <> Status_����Ϸ�) then
    exit;

  if not Assigned( DataSource1.DataSet ) then
    exit;

  // Active = False in other window
  //if not DataSource1.DataSet.Active then
  //  exit;

  // perhaps, state is 'dsInactive' in other window
  //if DataSource1.DataSet.State <> dsBrowse then
  //  exit;

  LiteQuery2.Active := False;
  try
    LiteQuery2.SQL.Text := 'select * from reception where chartrrid1 = :chartrrid1';
    LiteQuery2.ParamByName('chartrrid1').Value := AChartReceptionResultId1;

    LiteQuery2.Active := True;

    if LiteQuery2.RecordCount > 0 then
      with LiteQuery2 do
      begin
        isDummy := FieldByName( 'dummy' ).AsInteger = 1;
        gdid := FieldByName( 'gdid' ).AsString;

        GSendReceptionPeriodRoomInfo.RoomCode := FieldByName('roomcode').AsString;
        GSendReceptionPeriodRoomInfo.RoomName := FieldByName('roomname').AsString;
        GSendReceptionPeriodRoomInfo.DeptCode := FieldByName('deptcode').AsString;
        GSendReceptionPeriodRoomInfo.DeptName := FieldByName('deptname').AsString;
        GSendReceptionPeriodRoomInfo.DoctorCode := FieldByName('doctorcode').AsString;
        GSendReceptionPeriodRoomInfo.DoctorName := FieldByName('doctorname').AsString;
      
        chartid := FieldByName( 'chartid' ).AsString;
        chartrrid1 := FieldByName( 'chartrrid1' ).AsString;
        chartrrid2 := FieldByName( 'chartrrid2' ).AsString;
        chartrrid3 := FieldByName( 'chartrrid3' ).AsString;
        chartrrid4 := FieldByName( 'chartrrid4' ).AsString;
        chartrrid5 := FieldByName( 'chartrrid5' ).AsString;
        chartrrid6 := FieldByName( 'chartrrid6' ).AsString;

        Edit;
        FieldByName( 'status' ).AsString := AStatusCode; // ���� ����
        FieldByName( 'statusmng' ).AsString := AStatusCode; // ���� ����
        Post;
      end;
  finally
    LiteQuery2.Active := false;
  end;

  if string.IsNullOrEmpty(chartid) then
    exit;

  event_108 := TBridgeRequest_108( GBridgeFactory.MakeRequestObj( EventID_��⿭���°����� ) );
  event_108.HospitalNo := GHospitalNo;
  event_108.ReceptionUpdateDto.chartReceptnResultId.Id1 := chartrrid1;
  event_108.ReceptionUpdateDto.chartReceptnResultId.Id2 := chartrrid2;
  event_108.ReceptionUpdateDto.chartReceptnResultId.Id3 := chartrrid3;
  event_108.ReceptionUpdateDto.chartReceptnResultId.Id4 := chartrrid4;
  event_108.ReceptionUpdateDto.chartReceptnResultId.Id5 := chartrrid5;
  event_108.ReceptionUpdateDto.chartReceptnResultId.Id6 := chartrrid6;

  event_108.ReceptionUpdateDto.PatientChartId := chartid;
  event_108.ReceptionUpdateDto.RoomInfo.RoomCode := GSendReceptionPeriodRoomInfo.RoomCode;
  event_108.ReceptionUpdateDto.RoomInfo.RoomName := GSendReceptionPeriodRoomInfo.RoomName;
  event_108.ReceptionUpdateDto.RoomInfo.DeptCode := GSendReceptionPeriodRoomInfo.DeptCode;
  event_108.ReceptionUpdateDto.RoomInfo.DeptName := GSendReceptionPeriodRoomInfo.DeptName;
  event_108.ReceptionUpdateDto.RoomInfo.DoctorCode := GSendReceptionPeriodRoomInfo.DoctorCode;
  event_108.ReceptionUpdateDto.RoomInfo.DoctorName := GSendReceptionPeriodRoomInfo.DoctorName;
  event_108.ReceptionUpdateDto.Status := AStatusCode;
  event_108.receptStatusChangeDttm     := now;

  event_108.NewchartReceptnResult.Id1 := '';
  event_108.NewchartReceptnResult.Id2 := '';
  event_108.NewchartReceptnResult.Id3 := '';
  event_108.NewchartReceptnResult.Id4 := '';
  event_108.NewchartReceptnResult.Id5 := '';
  event_108.NewchartReceptnResult.Id6 := '';

{$ifdef _EP_}
  if (statuscode = Status_����Ϸ�) and ( gdid <> '' ) then
  begin // �Ϸ� �̰�, gdid�� �ִ� ȯ�ڸ� ���� ó������ �����ϰ� �Ѵ�.
    // ���� ó���� ó��
    processEP( event_108.ReceptionUpdateDto.PatientChartId,
               PatientMngForm.GetGDID(event_108.ReceptionUpdateDto.PatientChartId),
               event_108.ReceptionUpdateDto.chartReceptnResultId );
  end;
{$endif}

  UpdatePeriod(now, GSendReceptionPeriodRoomInfo.RoomCode);

  if isDummy then
  begin
    ChartEmulV4Form.AddMemo( format('������ȣ(%s)�� ���� data�� ���� ���� data�� �������� �ʴ´�.',[event_108.ReceptionUpdateDto.chartReceptnResultId.Id1]) );
  end
  else
  begin //
    ChartEmulV4Form.AddMemo( event_108.EventID, event_108.JobID );
    ret := GetBridge.RequestResponse( event_108.ToJsonString );
    responsebase := GBridgeFactory.MakeResponseObj( ret );
    ChartEmulV4Form.AddMemo( responsebase.EventID, responsebase.JobID, responsebase.Code, responsebase.MessageStr, 0 );
    FreeAndNil( responsebase );
  end;

  // �ڵ� ���� ó��
  if AccountDM.Active and (AStatusCode = Status_����Ϸ�) then
  begin
    FCheckAutoAccountProcess := True;
    try
      N12Click(nil);
    except
    end;
    FCheckAutoAccountProcess := False;
  end;

  GSendReceptionPeriod := True;

  if ChartEmulV4Form.EqualsCurrentTab(Panel1.Parent) then
  begin
    TThread.Synchronize(nil,
      procedure
      begin
        DBRefresh;
      end);
  end;

  Result := True;
  
  FreeAndNil( event_108 );
end;

end.
