unit ReceptionMngUnit;
//  C07(진료 대기), C08(진료중), F05(진료 완료)
//  C04(예약 진료 대기)??
// F06 접수 취소
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
    FCheckAutoAccountProcess : Boolean; // 자동  결제 요청 처리
    FDataFlag : Integer;
    FSendQueue_354 : TObjectList;
    function CheckReceptionPatient( AChartID : string; ARoomCode : string ) : integer;   // 같은 대기실에 등록되어 있으면 해당 rid값을 반환 한다. 없으면 -1을 반환
    function ChangePeriod( ARid : Integer; ADateTime, ARoomCode : string; AUpDownFlag : Integer ) : Boolean; // AUpDownFlag값이 1이면 위로, 그외에는 아래로 이동

    // 전자 처방전 처리
    function processEP( AChartID, AGDID : string; AChartReceptnResultId : TChartReceptnResultId ) : Boolean;
    function MakeEvent354( AChartReceptnResultId : TChartReceptnResultId ) : TBridgeRequest_354;
    function Send354( AEvent354 : TBridgeRequest_354 ) : Boolean;

    procedure openprocessquery;

    // 약 정보 등록
    procedure InputDrug_0( AEvent354 : TBridgeRequest_354 );
    procedure InputDrug_1( AEvent354 : TBridgeRequest_354 );

    function GetRoomInfo( ARoomCode : string ) : TRoomInfoRecord;
  public
    { Public declarations }
    constructor Create( AOwner : TComponent ); override;
    destructor Destroy; override;

    procedure ChangeUI( AParentCtrl : TWinControl );

    // 접수
    function AddReception( AReceptionData : TBridgeResponse_100 ) : TBridgeRequest_101; overload;
    procedure AddReception( AReceptionData : TBridgeRequest_100 ); overload;
    // ResultCode가 200이면 처리 완료, 그외에는 처리 불가
    procedure AddReception( AReceptionData : TData307; var APatientChartID : string; var ResultCode : integer ); overload;

    // 접수 취소
    function CancelReception( AReceptionCancelData : TBridgeResponse_102 ) : TBridgeRequest_103; overload;
    procedure CancelReception( AReceptionCancelData : TData307; var APatientChartID : string; var ResultCode : integer ); overload;

    // 내원 확인
    function VisitConfirm( AVisitConfirmData : TBridgeResponse_110; ARoomList : TStringList ) : TBridgeRequest_111;

    // 지정된 진료실의 순서를 정리 한다.
    procedure UpdatePeriod( AUpdateDate : TDateTime; ARoomCode : string );

    // 지정된 진료실들의 순서를 정리 한다.
    procedure UpdatePeriods( AUpdateDate : TDateTime; ARoomCodes : TStringList );

    procedure SendPeriod( ADate : TDateTime; ARoomInfo : TRoomInfoRecord );

    // 전자 처방정 발급 대상 설정
    function UpdateEP_Reception( AEvent352: TBridgeResponse_352): TBridgeResponse_353;

    // V3-185. 자동화툴에 의한 접수 상태변경
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
  Result := TBridgeRequest_101( GBridgeFactory.MakeRequestObj(EventID_접수요청결과, AReceptionData.JobID ) );

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
    //    환자 추가
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
      ChartEmulV4Form.AddMemo( format('%s 주민 번호는 신규 환자 입니다. 차트 id %s로 추가 되었습니다.', [AReceptionData.RegNum, pid]) );
    finally
      patient.Active := False;
    end;
  end
  else
  begin  // gdid update
    if AReceptionData.gdid <> '' then
      PatientMngForm.UpdateGDID( pid, AReceptionData.gdid );
  end;

  // 환자 정보에 주소 정보가 없으면 주소 정보를 update하게 한다.
  DBDM.UpdatePatientAddress(pid, AReceptionData.Addr,  AReceptionData.AddrDetail, AReceptionData.Zip);

  rid := CheckReceptionPatient(pid, AReceptionData.RoomInfo.RoomCode);
  if rid >= 0 then
  begin // 이미 등록 되어 있다.
    Result.Code := Result_접수중복;
    Result.MessageStr := GBridgeFactory.GetErrorString( Result.Code );
    ChartEmulV4Form.AddMemo( format('%s(%s)환자는 %s(%s)에 이미 등록 되어 있습니다.(RID:%d)', [AReceptionData.PatntName, pid, AReceptionData.RoomInfo.RoomName, AReceptionData.RoomInfo.RoomCode, rid]) );
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

      FieldByName( 'status' ).AsString := Status_진료대기;
      if AReceptionData.EndPoint = 'A' then
        FieldByName( 'statusmng' ).AsString := Status_내원요청
      else
        FieldByName( 'statusmng' ).AsString := Status_진료대기;

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

  //내원 목적은 별도로 추가 한다
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
  Result.ePrescriptionHospital := GElectronicPrescriptionsOption;  // 전자 처방전 병원 여부 (0:미사용,1:사용)

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
      FieldByName( 'status' ).AsString := Status_내원확정;
      FieldByName( 'statusmng' ).AsString := Status_내원확정;
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

    //    환자 추가
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
      ChartEmulV4Form.AddMemo( format('%s 주민 번호는 신규 환자 입니다. 차트 id %s로 추가 되었습니다.', [AReceptionData.RegNum, APatientChartID]) );
    finally
      patient.Active := False;
    end;
  end
  else
  begin  // gdid update
    ChartEmulV4Form.AddMemo( format('%s 주민 번호는 차트 id %s로 존재하는 환자 입니다.', [AReceptionData.RegNum, APatientChartID]) );
    if AReceptionData.gdid <> '' then
      PatientMngForm.UpdateGDID( APatientChartID, AReceptionData.gdid );
  end;

  rid := CheckReceptionPatient(APatientChartID, AReceptionData.RoomInfo.RoomCode);
  if rid >= 0 then
  begin // 이미 등록 되어 있다.
    ResultCode := Result_접수중복;
    ChartEmulV4Form.AddMemo( format('%s(%s)환자는 %s(%s)에 이미 등록 되어 있습니다.(RID:%d)', [AReceptionData.PatntName, APatientChartID, AReceptionData.RoomInfo.RoomName, AReceptionData.RoomInfo.RoomCode, rid]) );
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

      FieldByName( 'status' ).AsString := Status_진료대기;
      if AReceptionData.EndPoint = 'A' then
        FieldByName( 'statusmng' ).AsString := Status_내원요청
      else
        FieldByName( 'statusmng' ).AsString := Status_진료대기;

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

  //내원 목적은 별도로 추가 한다
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
  event_102 := TBridgeRequest_102( GBridgeFactory.MakeRequestObj(EventID_접수취소 ) );
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
      LiteQuery1.FieldByName( 'status' ).AsString := Status_병원취소; // 병원 취소
      LiteQuery1.FieldByName( 'statusmng' ).AsString := Status_병원취소; // 병원 취소
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
begin // 진료실 변경
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

  event_106 := TBridgeRequest_106( GBridgeFactory.MakeRequestObj(EventID_대기열변경 ) );
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

  // 우선 순위 변경
  UpdatePeriod(now, RoomInfo.RoomCode);
  SendPeriod( Now, RoomInfo); // old변경

  // 우선 순위 변경
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
begin // 아래로
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
      MessageDlg('수정 완료', mtInformation, [mbOK], 0);
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
  Result := TBridgeRequest_103( GBridgeFactory.MakeRequestObj(EventID_접수취소결과, AReceptionCancelData.JobID ) );
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
        Result.Code := Result_접수번호없음;
        Result.MessageStr := GBridgeFactory.GetErrorString( Result.Code );
        ChartEmulV4Form.AddMemo( format('%s 접수 번호를 찾을 수 없습니다.',[AReceptionCancelData.chartReceptnResultId.Id1]) );
        exit;
      end;

      GSendReceptionPeriodRoomInfo.RoomCode := FieldByName('roomcode').AsString;
      GSendReceptionPeriodRoomInfo.RoomName := FieldByName('roomname').AsString;
      GSendReceptionPeriodRoomInfo.DeptCode := FieldByName('deptcode').AsString;
      GSendReceptionPeriodRoomInfo.DeptName := FieldByName('deptname').AsString;
      GSendReceptionPeriodRoomInfo.DoctorCode := FieldByName('doctorcode').AsString;
      GSendReceptionPeriodRoomInfo.DoctorName := FieldByName('doctorname').AsString;

      Edit;
        FieldByName( 'status' ).AsString := Status_본인취소;
        FieldByName( 'statusmng' ).AsString := Status_본인취소;
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
        ResultCode := Result_접수번호없음;
        ChartEmulV4Form.AddMemo( format('%s 접수 번호를 찾을 수 없습니다.',[AReceptionCancelData.chartReceptnResultId.Id1]) );
        exit;
      end;

      Edit;
        FieldByName( 'status' ).AsString := Status_본인취소;
        FieldByName( 'statusmng' ).AsString := Status_본인취소;
        FieldByName( 'cancelmsg' ).AsString := 'event306, 취소됨';
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
    SQL.Text := 'select * from reception where status in (''C04'', ''C07'') and roomcode = :roomcode and receptiondate = :receptiondate order by period';  //  C04(진료대기), C08(진료중)
    if AUpDownFlag <> 1 then
      SQL.Text := SQL.Text + ' desc';

    ParamByName('roomcode').Value := ARoomCode;
    ParamByName('receptiondate').Value := ADateTime;
    Active := True;
    First;

    if not Locate('rid', IntToStr(ARid), []) then
      exit; //  못 찾았다.

    ownerperiod := FieldByName( 'period' ).AsInteger;
    ownerstatus := FieldByName( 'status' ).AsString;
    Next;
    if eof then
      exit; // 마지막 이라 처리 불가

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
      //SQL.Text := 'select * from reception where status in (''C04'', ''C07'') and roomcode = :roomcode and receptiondate = :receptiondate  and chartid = :chartid';  //  C04(진료대기), C07(진료차례)
(*
2020-07-17, tonny요청, 접수모바일 접수시 동일 진료실에 이미 접수 되어 있는 경우 접수가 안되어야 하는데 접수 되는 현상
기존에는 진료 대기 C04 , 진료차례 C07  상태에 있는 환자만 check하게 되어 있습니다.
지금 봐서는
접수 요청 C01
접수 완료 C03
내원 요청 C05
내원 확정 C06
등 진료 대기에 해당되는 상태도 접수요청처리가 않되게 수정을 하겠습니다.
해당 상태는 emul에서 관리하고 있는 상태 기준입니다.
*)
      SQL.Text := 'select * from reception where status in (''C01'', ''C03'', ''C04'', ''C05'', ''C06'', ''C07'') and roomcode = :roomcode and receptiondate = :receptiondate  and chartid = :chartid';  //  C04(진료대기), C07(진료차례)
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

  // 접수 번호 변경
  Button8.Enabled := DataSource1.DataSet.FieldByName('chartrrid1').AsString <> '';

  with DataSource1.DataSet do
  begin
    status := FieldByName( 'status' ).AsString;

    // 취소, 진료실 변경
    if (status = Status_예약요청)
       or (status = Status_예약완료)
       or (status = Status_접수요청)
       or (status = Status_접수완료)
       or (status = Status_진료대기)
       or (status = Status_내원요청)
       or (status = Status_내원확정)
       or (status = Status_진료차례)
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

    // 위아래
    if (status = Status_진료대기) or (status = Status_진료차례) then
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

    // 상태 변경
    if (status = Status_취소요청)
       or (status = Status_본인취소)
       or (status = Status_병원취소)
       or (status = Status_자동취소)
       or (status = Status_진료완료)
    then
      Button4.Enabled := False
    else
      Button4.Enabled := True;
  end;

  // 결제된 record이냐?  true이면 결제 됬다, false이면 결제되지 않았다.
  isAccountCheck := DataSource1.DataSet.FieldByName('payauthno').AsString <> '';
  // 결제 요청
  N14.Enabled := AccountDM.Active and (not isAccountCheck) and (DataSource1.DataSet.FieldByName('chartrrid1').AsString <> ''); // 결제 사용 병원이고, 결제가 않됬다, 접수는 되어 있어야 한다. true
  // 결제 취소,
  N15.Enabled := AccountDM.Active and isAccountCheck; // 결제 사용 병원이고 결제가 됬다. true
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
      drugKorName := '프레드포르테점안액(외용)';
      drugEngName := '프레드포르테점안액(외용)';
      drugReimbursementType := 1; // 1:급여, 2:비급여, 3:100/100, 4:100/80, 5:100/50, 6:100/30, 7: 100:90
      drugAdminRoute := 1; // 0:내복, 1:외용, 2:주사제
      drugDose := '0.8333'; // 1회 투여량
      totalAdminDose := '1';  // 총투여량
      drugAdminCount := '6';  // 1회 투여횟수
      drugTreatmentPeriod := '1';  // 총 투약일수
      drugAdminCode := 'D0';// 용법 코드
      drugAdminComment := '지시대로 복용하세요'; // 용법
      drugOutsideFlag := 1; // 1(원내), 2(원외)
      docClsType := 1; //  마약일 경우: 3 마약이 아닐 경우: 1
      docComment := '';
      prnCheck := 0; //  1: prn 처방인 경우, 0: prn 처방이 아닌 경우

      ingredientName := '';
      drugListEnrollType := 0; //  0:상품명, 1:성분명(영문), 2:성분명(한글), Default = '0'
      drugPackageFlag := 1;    // 1:병팩단위, 0:그외약품

        CItem := TadCommentItem.Create;
        CItem.resnm := '중복투여 치료군' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resncnts := '동일 치료군 내 하나의 약재료 질병이 조절되지 않 으며, 대체 가능한 다른 치료군이 없음.' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resnm := '진서방정10/5mg' + FormatDateTime('yyyymmddhhnnsszzz',now);
        AddadComment( CItem );
    end;
    AddrxDrug( rxDrug );

    // 4
    rxDrug := TrxDrugListItem.Create;
    with rxDrug do
    begin
      drugCode := '653501390';
      drugKorName := '트라젠타듀오정 2.5/500mg (한국베링거인겔하임)';
      drugEngName := '트라젠타듀오정 2.5/500mg (한국베링거인겔하임)';
      drugReimbursementType := 5; // 1:급여, 2:비급여, 3:100/100, 4:100/80, 5:100/50, 6:100/30, 7: 100:90
      drugAdminRoute := 0; // 0:내복, 1:외용, 2:주사제
      drugDose := '1'; // 1회 투여량
      totalAdminDose := '180';  // 총투여량
      drugAdminCount := '2';  // 1회 투여횟수
      drugTreatmentPeriod := '90';  // 총 투약일수
      drugAdminCode := 'D30';// 용법 코드
      drugAdminComment := '식후30분'; // 용법
      drugOutsideFlag := 2; // 1(원내), 2(원외)
      docClsType := 1; //  마약일 경우: 3 마약이 아닐 경우: 1
      docComment := '';
      prnCheck := 0; //  1: prn 처방인 경우, 0: prn 처방이 아닌 경우

      ingredientName := '';
      drugListEnrollType := 0; //  0:상품명, 1:성분명(영문), 2:성분명(한글), Default = '0'
      drugPackageFlag := 1;    // 1:병팩단위, 0:그외약품

        CItem := TadCommentItem.Create;
        CItem.resnm := '중복투여 치료군' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resncnts := '동일 치료군 내 하나의 약재료 질병이 조절되지 않 으며, 대체 가능한 다른 치료군이 없음.' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resnm := '진서방정10/5mg' + FormatDateTime('yyyymmddhhnnsszzz',now);
        AddadComment( CItem );
    end;
    AddrxDrug( rxDrug );

    // 8
    rxDrug := TrxDrugListItem.Create;
    with rxDrug do
    begin
      drugCode := '646202070';
      drugKorName := '파모시드정20mg';
      drugEngName := '파모시드정20mg';
      drugReimbursementType := 1; // 1:급여, 2:비급여, 3:100/100, 4:100/80, 5:100/50, 6:100/30, 7: 100:90
      drugAdminRoute := 0; // 0:내복, 1:외용, 2:주사제
      drugDose := '1'; // 1회 투여량
      totalAdminDose := '6';  // 총투여량
      drugAdminCount := '3';  // 1회 투여횟수
      drugTreatmentPeriod := '2';  // 총 투약일수
      drugAdminCode := 'D30';// 용법 코드
      drugAdminComment := '식후30분'; // 용법
      drugOutsideFlag := 2; // 1(원내), 2(원외)
      docClsType := 1; //  마약일 경우: 3 마약이 아닐 경우: 1
      docComment := '';
      prnCheck := 0; //  1: prn 처방인 경우, 0: prn 처방이 아닌 경우

      ingredientName := '';
      drugListEnrollType := 0; //  0:상품명, 1:성분명(영문), 2:성분명(한글), Default = '0'
      drugPackageFlag := 1;    // 1:병팩단위, 0:그외약품

        CItem := TadCommentItem.Create;
        CItem.resnm := '중복투여 치료군' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resncnts := '동일 치료군 내 하나의 약재료 질병이 조절되지 않 으며, 대체 가능한 다른 치료군이 없음.' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resnm := '진서방정10/5mg' + FormatDateTime('yyyymmddhhnnsszzz',now);
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
      drugKorName := '프레드포르테점안액(외용)';
      drugEngName := '프레드포르테점안액(외용)';
      drugReimbursementType := 1; // 1:급여, 2:비급여, 3:100/100, 4:100/80, 5:100/50, 6:100/30, 7: 100:90
      drugAdminRoute := 1; // 0:내복, 1:외용, 2:주사제
      drugDose := '0.8333'; // 1회 투여량
      totalAdminDose := '1';  // 총투여량
      drugAdminCount := '6';  // 1회 투여횟수
      drugTreatmentPeriod := '1';  // 총 투약일수
      drugAdminCode := 'D0';// 용법 코드
      drugAdminComment := '지시대로 복용하세요'; // 용법
      drugOutsideFlag := 1; // 1(원내), 2(원외)
      docClsType := 1; //  마약일 경우: 3 마약이 아닐 경우: 1
      docComment := '';
      prnCheck := 0; //  1: prn 처방인 경우, 0: prn 처방이 아닌 경우

      ingredientName := '';
      drugListEnrollType := 0; //  0:상품명, 1:성분명(영문), 2:성분명(한글), Default = '0'
      drugPackageFlag := 1;    // 1:병팩단위, 0:그외약품

        CItem := TadCommentItem.Create;
        CItem.resnm := '중복투여 치료군' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resncnts := '동일 치료군 내 하나의 약재료 질병이 조절되지 않 으며, 대체 가능한 다른 치료군이 없음.' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resnm := '진서방정10/5mg' + FormatDateTime('yyyymmddhhnnsszzz',now);
        AddadComment( CItem );
    end;
    AddrxDrug( rxDrug );

    // 2
    rxDrug := TrxDrugListItem.Create;
    with rxDrug do
    begin
      drugCode := '661904110';
      drugKorName := '리피스타틴정 10mg (영풍)';
      drugEngName := '리피스타틴정 10mg (영풍)';
      drugReimbursementType := 3; // 1:급여, 2:비급여, 3:100/100, 4:100/80, 5:100/50, 6:100/30, 7: 100:90
      drugAdminRoute := 0; // 0:내복, 1:외용, 2:주사제
      drugDose := '1'; // 1회 투여량
      totalAdminDose := '180';  // 총투여량
      drugAdminCount := '2';  // 1회 투여횟수
      drugTreatmentPeriod := '90';  // 총 투약일수
      drugAdminCode := 'D33';// 용법 코드
      drugAdminComment := '2시간마다'; // 용법
      drugOutsideFlag := 2; // 1(원내), 2(원외)
      docClsType := 1; //  마약일 경우: 3 마약이 아닐 경우: 1
      docComment := '';
      prnCheck := 0; //  1: prn 처방인 경우, 0: prn 처방이 아닌 경우

      ingredientName := '';
      drugListEnrollType := 0; //  0:상품명, 1:성분명(영문), 2:성분명(한글), Default = '0'
      drugPackageFlag := 1;    // 1:병팩단위, 0:그외약품
        CItem := TadCommentItem.Create;
        CItem.resnm := '중복투여 치료군' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resncnts := '동일 치료군 내 하나의 약재료 질병이 조절되지 않 으며, 대체 가능한 다른 치료군이 없음.' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resnm := '진서방정10/5mg' + FormatDateTime('yyyymmddhhnnsszzz',now);
        AddadComment( CItem );
    end;
    AddrxDrug( rxDrug );

    // 3
    rxDrug := TrxDrugListItem.Create;
    with rxDrug do
    begin
      drugCode := '644501990';
      drugKorName := '유유포지 정 5/160mg (유유제약)';
      drugEngName := '유유포지 정 5/160mg (유유제약)';
      drugReimbursementType := 4; // 1:급여, 2:비급여, 3:100/100, 4:100/80, 5:100/50, 6:100/30, 7: 100:90
      drugAdminRoute := 0; // 0:내복, 1:외용, 2:주사제
      drugDose := '1'; // 1회 투여량
      totalAdminDose := '180';  // 총투여량
      drugAdminCount := '2';  // 1회 투여횟수
      drugTreatmentPeriod := '90';  // 총 투약일수
      drugAdminCode := 'D30';// 용법 코드
      drugAdminComment := '식후30분'; // 용법
      drugOutsideFlag := 2; // 1(원내), 2(원외)
      docClsType := 1; //  마약일 경우: 3 마약이 아닐 경우: 1
      docComment := '';
      prnCheck := 0; //  1: prn 처방인 경우, 0: prn 처방이 아닌 경우

      ingredientName := '';
      drugListEnrollType := 0; //  0:상품명, 1:성분명(영문), 2:성분명(한글), Default = '0'
      drugPackageFlag := 1;    // 1:병팩단위, 0:그외약품
        CItem := TadCommentItem.Create;
        CItem.resnm := '중복투여 치료군' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resncnts := '동일 치료군 내 하나의 약재료 질병이 조절되지 않 으며, 대체 가능한 다른 치료군이 없음.' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resnm := '진서방정10/5mg' + FormatDateTime('yyyymmddhhnnsszzz',now);
        AddadComment( CItem );
    end;
    AddrxDrug( rxDrug );

    // 4
    rxDrug := TrxDrugListItem.Create;
    with rxDrug do
    begin
      drugCode := '653501390';
      drugKorName := '트라젠타듀오정 2.5/500mg (한국베링거인겔하임)';
      drugEngName := '트라젠타듀오정 2.5/500mg (한국베링거인겔하임)';
      drugReimbursementType := 5; // 1:급여, 2:비급여, 3:100/100, 4:100/80, 5:100/50, 6:100/30, 7: 100:90
      drugAdminRoute := 0; // 0:내복, 1:외용, 2:주사제
      drugDose := '1'; // 1회 투여량
      totalAdminDose := '180';  // 총투여량
      drugAdminCount := '2';  // 1회 투여횟수
      drugTreatmentPeriod := '90';  // 총 투약일수
      drugAdminCode := 'D30';// 용법 코드
      drugAdminComment := '식후30분'; // 용법
      drugOutsideFlag := 2; // 1(원내), 2(원외)
      docClsType := 1; //  마약일 경우: 3 마약이 아닐 경우: 1
      docComment := '';
      prnCheck := 0; //  1: prn 처방인 경우, 0: prn 처방이 아닌 경우

      ingredientName := '';
      drugListEnrollType := 0; //  0:상품명, 1:성분명(영문), 2:성분명(한글), Default = '0'
      drugPackageFlag := 1;    // 1:병팩단위, 0:그외약품
        CItem := TadCommentItem.Create;
        CItem.resnm := '중복투여 치료군' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resncnts := '동일 치료군 내 하나의 약재료 질병이 조절되지 않 으며, 대체 가능한 다른 치료군이 없음.' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resnm := '진서방정10/5mg' + FormatDateTime('yyyymmddhhnnsszzz',now);
        AddadComment( CItem );
    end;
    AddrxDrug( rxDrug );

    // 4
    rxDrug := TrxDrugListItem.Create;
    with rxDrug do
    begin
      drugCode := '661901650';
      drugKorName := '크라빅스정 75mg  (영풍제약)';
      drugEngName := '크라빅스정 75mg  (영풍제약)';
      drugReimbursementType := 6; // 1:급여, 2:비급여, 3:100/100, 4:100/80, 5:100/50, 6:100/30, 7: 100:90
      drugAdminRoute := 0; // 0:내복, 1:외용, 2:주사제
      drugDose := '1'; // 1회 투여량
      totalAdminDose := '180';  // 총투여량
      drugAdminCount := '2';  // 1회 투여횟수
      drugTreatmentPeriod := '90';  // 총 투약일수
      drugAdminCode := 'D30';// 용법 코드
      drugAdminComment := '식후30분'; // 용법
      drugOutsideFlag := 2; // 1(원내), 2(원외)
      docClsType := 1; //  마약일 경우: 3 마약이 아닐 경우: 1
      docComment := '';
      prnCheck := 0; //  1: prn 처방인 경우, 0: prn 처방이 아닌 경우

      ingredientName := '';
      drugListEnrollType := 0; //  0:상품명, 1:성분명(영문), 2:성분명(한글), Default = '0'
      drugPackageFlag := 1;    // 1:병팩단위, 0:그외약품
        CItem := TadCommentItem.Create;
        CItem.resnm := '중복투여 치료군' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resncnts := '동일 치료군 내 하나의 약재료 질병이 조절되지 않 으며, 대체 가능한 다른 치료군이 없음.' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resnm := '진서방정10/5mg' + FormatDateTime('yyyymmddhhnnsszzz',now);
        AddadComment( CItem );
    end;
    AddrxDrug( rxDrug );

    // 5
    rxDrug := TrxDrugListItem.Create;
    with rxDrug do
    begin
      drugCode := '643901070';
      drugKorName := '오큐시클로점안액';
      drugEngName := '오큐시클로점안액';
      drugReimbursementType := 7; // 1:급여, 2:비급여, 3:100/100, 4:100/80, 5:100/50, 6:100/30, 7: 100:90
      drugAdminRoute := 1; // 0:내복, 1:외용, 2:주사제
      drugDose := '1.25'; // 1회 투여량
      totalAdminDose := '1';  // 총투여량
      drugAdminCount := '4';  // 1회 투여횟수
      drugTreatmentPeriod := '1';  // 총 투약일수
      drugAdminCode := 'D40';// 용법 코드
      drugAdminComment := '식후 1번씩 취침전 1번'; // 용법
      drugOutsideFlag := 2; // 1(원내), 2(원외)
      docClsType := 1; //  마약일 경우: 3 마약이 아닐 경우: 1
      docComment := '';
      prnCheck := 0; //  1: prn 처방인 경우, 0: prn 처방이 아닌 경우

      ingredientName := '';
      drugListEnrollType := 0; //  0:상품명, 1:성분명(영문), 2:성분명(한글), Default = '0'
      drugPackageFlag := 1;    // 1:병팩단위, 0:그외약품
        CItem := TadCommentItem.Create;
        CItem.resnm := '중복투여 치료군' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resncnts := '동일 치료군 내 하나의 약재료 질병이 조절되지 않 으며, 대체 가능한 다른 치료군이 없음.' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resnm := '진서방정10/5mg' + FormatDateTime('yyyymmddhhnnsszzz',now);
        AddadComment( CItem );
    end;
    AddrxDrug( rxDrug );

    // 6
    rxDrug := TrxDrugListItem.Create;
    with rxDrug do
    begin
      drugCode := '646201050';
      drugKorName := '솔로젠정';
      drugEngName := '솔로젠정';
      drugReimbursementType := 1; // 1:급여, 2:비급여, 3:100/100, 4:100/80, 5:100/50, 6:100/30, 7: 100:90
      drugAdminRoute := 0; // 0:내복, 1:외용, 2:주사제
      drugDose := '2'; // 1회 투여량
      totalAdminDose := '12';  // 총투여량
      drugAdminCount := '3';  // 1회 투여횟수
      drugTreatmentPeriod := '2';  // 총 투약일수
      drugAdminCode := 'D30';// 용법 코드
      drugAdminComment := '식후30분'; // 용법
      drugOutsideFlag := 2; // 1(원내), 2(원외)
      docClsType := 1; //  마약일 경우: 3 마약이 아닐 경우: 1
      docComment := '';
      prnCheck := 0; //  1: prn 처방인 경우, 0: prn 처방이 아닌 경우

      ingredientName := '';
      drugListEnrollType := 0; //  0:상품명, 1:성분명(영문), 2:성분명(한글), Default = '0'
      drugPackageFlag := 1;    // 1:병팩단위, 0:그외약품
        CItem := TadCommentItem.Create;
        CItem.resnm := '중복투여 치료군' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resncnts := '동일 치료군 내 하나의 약재료 질병이 조절되지 않 으며, 대체 가능한 다른 치료군이 없음.' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resnm := '진서방정10/5mg' + FormatDateTime('yyyymmddhhnnsszzz',now);
        AddadComment( CItem );
    end;
    AddrxDrug( rxDrug );

    // 7
    rxDrug := TrxDrugListItem.Create;
    with rxDrug do
    begin
      drugCode := '646200690';
      drugKorName := '록소젠정';
      drugEngName := '록소젠정';
      drugReimbursementType := 2; // 1:급여, 2:비급여, 3:100/100, 4:100/80, 5:100/50, 6:100/30, 7: 100:90
      drugAdminRoute := 0; // 0:내복, 1:외용, 2:주사제
      drugDose := '1'; // 1회 투여량
      totalAdminDose := '6';  // 총투여량
      drugAdminCount := '3';  // 1회 투여횟수
      drugTreatmentPeriod := '2';  // 총 투약일수
      drugAdminCode := 'D30';// 용법 코드
      drugAdminComment := '식후30분'; // 용법
      drugOutsideFlag := 2; // 1(원내), 2(원외)
      docClsType := 3; //  마약일 경우: 3 마약이 아닐 경우: 1
      docComment := '비급여';
      prnCheck := 0; //  1: prn 처방인 경우, 0: prn 처방이 아닌 경우

      ingredientName := '';
      drugListEnrollType := 0; //  0:상품명, 1:성분명(영문), 2:성분명(한글), Default = '0'
      drugPackageFlag := 1;    // 1:병팩단위, 0:그외약품
        CItem := TadCommentItem.Create;
        CItem.resnm := '중복투여 치료군' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resncnts := '동일 치료군 내 하나의 약재료 질병이 조절되지 않 으며, 대체 가능한 다른 치료군이 없음.' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resnm := '진서방정10/5mg' + FormatDateTime('yyyymmddhhnnsszzz',now);
        AddadComment( CItem );
    end;
    AddrxDrug( rxDrug );

    // 8
    rxDrug := TrxDrugListItem.Create;
    with rxDrug do
    begin
      drugCode := '646202070';
      drugKorName := '파모시드정20mg';
      drugEngName := '파모시드정20mg';
      drugReimbursementType := 1; // 1:급여, 2:비급여, 3:100/100, 4:100/80, 5:100/50, 6:100/30, 7: 100:90
      drugAdminRoute := 0; // 0:내복, 1:외용, 2:주사제
      drugDose := '1'; // 1회 투여량
      totalAdminDose := '6';  // 총투여량
      drugAdminCount := '3';  // 1회 투여횟수
      drugTreatmentPeriod := '2';  // 총 투약일수
      drugAdminCode := 'D30';// 용법 코드
      drugAdminComment := '식후30분'; // 용법
      drugOutsideFlag := 2; // 1(원내), 2(원외)
      docClsType := 1; //  마약일 경우: 3 마약이 아닐 경우: 1
      docComment := '';
      prnCheck := 0; //  1: prn 처방인 경우, 0: prn 처방이 아닌 경우

      ingredientName := '';
      drugListEnrollType := 0; //  0:상품명, 1:성분명(영문), 2:성분명(한글), Default = '0'
      drugPackageFlag := 1;    // 1:병팩단위, 0:그외약품
        CItem := TadCommentItem.Create;
        CItem.resnm := '중복투여 치료군' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resncnts := '동일 치료군 내 하나의 약재료 질병이 조절되지 않 으며, 대체 가능한 다른 치료군이 없음.' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resnm := '진서방정10/5mg' + FormatDateTime('yyyymmddhhnnsszzz',now);
        AddadComment( CItem );
    end;
    AddrxDrug( rxDrug );

    // 9
    rxDrug := TrxDrugListItem.Create;
    with rxDrug do
    begin
      drugCode := '67080032';
      drugKorName := '푸로작확산정20밀리그람(염산플루옥';
      drugEngName := '푸로작확산정20밀리그람(염산플루옥';
      drugReimbursementType := 3; // 1:급여, 2:비급여, 3:100/100, 4:100/80, 5:100/50, 6:100/30, 7: 100:90
      drugAdminRoute := 0; // 0:내복, 1:외용, 2:주사제
      drugDose := '1'; // 1회 투여량
      totalAdminDose := '180';  // 총투여량
      drugAdminCount := '2';  // 1회 투여횟수
      drugTreatmentPeriod := '180';  // 총 투약일수
      drugAdminCode := 'D2120';// 용법 코드
      drugAdminComment := '아침점심'; // 용법
      drugOutsideFlag := 2; // 1(원내), 2(원외)
      docClsType := 1; //  마약일 경우: 3 마약이 아닐 경우: 1
      docComment := '';
      prnCheck := 0; //  1: prn 처방인 경우, 0: prn 처방이 아닌 경우

      ingredientName := '';
      drugListEnrollType := 0; //  0:상품명, 1:성분명(영문), 2:성분명(한글), Default = '0'
      drugPackageFlag := 1;    // 1:병팩단위, 0:그외약품
        CItem := TadCommentItem.Create;
        CItem.resnm := '중복투여 치료군' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resncnts := '동일 치료군 내 하나의 약재료 질병이 조절되지 않 으며, 대체 가능한 다른 치료군이 없음.' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resnm := '진서방정10/5mg' + FormatDateTime('yyyymmddhhnnsszzz',now);
        AddadComment( CItem );
    end;
    AddrxDrug( rxDrug );
exit;

    // 10
    rxDrug := TrxDrugListItem.Create;
    with rxDrug do
    begin
      drugCode := '65190128';
      drugKorName := '설피딘정200mg(설피리드)수출명';
      drugEngName := '설피딘정200mg(설피리드)수출명';
      drugReimbursementType := 6; // 1:급여, 2:비급여, 3:100/100, 4:100/80, 5:100/50, 6:100/30, 7: 100:90
      drugAdminRoute := 0; // 0:내복, 1:외용, 2:주사제
      drugDose := '0.5'; // 1회 투여량
      totalAdminDose := '90';  // 총투여량
      drugAdminCount := '1';  // 1회 투여횟수
      drugTreatmentPeriod := '180';  // 총 투약일수
      drugAdminCode := 'H1';// 용법 코드
      drugAdminComment := '심한 가슴통증시 혀 밑에 1알을 넣으세요'; // 용법
      drugOutsideFlag := 2; // 1(원내), 2(원외)
      docClsType := 1; //  마약일 경우: 3 마약이 아닐 경우: 1
      docComment := '';
      prnCheck := 0; //  1: prn 처방인 경우, 0: prn 처방이 아닌 경우

      ingredientName := '';
      drugListEnrollType := 0; //  0:상품명, 1:성분명(영문), 2:성분명(한글), Default = '0'
      drugPackageFlag := 1;    // 1:병팩단위, 0:그외약품
        CItem := TadCommentItem.Create;
        CItem.resnm := '중복투여 치료군' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resncnts := '동일 치료군 내 하나의 약재료 질병이 조절되지 않 으며, 대체 가능한 다른 치료군이 없음.' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resnm := '진서방정10/5mg' + FormatDateTime('yyyymmddhhnnsszzz',now);
        AddadComment( CItem );
    end;
    AddrxDrug( rxDrug );

    // 11
    rxDrug := TrxDrugListItem.Create;
    with rxDrug do
    begin
      drugCode := '26800751';
      drugKorName := '네리소나0.3%연고';
      drugEngName := '네리소나0.3%연고';
      drugReimbursementType := 2; // 1:급여, 2:비급여, 3:100/100, 4:100/80, 5:100/50, 6:100/30, 7: 100:90
      drugAdminRoute := 1; // 0:내복, 1:외용, 2:주사제
      drugDose := '1'; // 1회 투여량
      totalAdminDose := '1';  // 총투여량
      drugAdminCount := '1';  // 1회 투여횟수
      drugTreatmentPeriod := '1';  // 총 투약일수
      drugAdminCode := 'O1';// 용법 코드
      drugAdminComment := '환부에 바르세요'; // 용법
      drugOutsideFlag := 1; // 1(원내), 2(원외)
      docClsType := 1; //  마약일 경우: 3 마약이 아닐 경우: 1
      docComment := '';
      prnCheck := 0; //  1: prn 처방인 경우, 0: prn 처방이 아닌 경우

      ingredientName := '';
      drugListEnrollType := 0; //  0:상품명, 1:성분명(영문), 2:성분명(한글), Default = '0'
      drugPackageFlag := 1;    // 1:병팩단위, 0:그외약품
        CItem := TadCommentItem.Create;
        CItem.resnm := '중복투여 치료군' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resncnts := '동일 치료군 내 하나의 약재료 질병이 조절되지 않 으며, 대체 가능한 다른 치료군이 없음.' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resnm := '진서방정10/5mg' + FormatDateTime('yyyymmddhhnnsszzz',now);
        AddadComment( CItem );
    end;
    AddrxDrug( rxDrug );

    // 12
    rxDrug := TrxDrugListItem.Create;
    with rxDrug do
    begin
      drugCode := '642101410';
      drugKorName := '유한2%염산리도카인에피네프린주사(1:80,000)';
      drugEngName := '유한2%염산리도카인에피네프린주사(1:80,000)';
      drugReimbursementType := 7; // 1:급여, 2:비급여, 3:100/100, 4:100/80, 5:100/50, 6:100/30, 7: 100:90
      drugAdminRoute := 2; // 0:내복, 1:외용, 2:주사제
      drugDose := '1'; // 1회 투여량
      totalAdminDose := '1';  // 총투여량
      drugAdminCount := '1';  // 1회 투여횟수
      drugTreatmentPeriod := '1';  // 총 투약일수
      drugAdminCode := 'P1';// 용법 코드
      drugAdminComment := '필요시 허벅지에 주사하세요'; // 용법
      drugOutsideFlag := 1; // 1(원내), 2(원외)
      docClsType := 3; //  마약일 경우: 3 마약이 아닐 경우: 1
      docComment := '비급여';
      prnCheck := 1; //  1: prn 처방인 경우, 0: prn 처방이 아닌 경우

      ingredientName := '';
      drugListEnrollType := 0; //  0:상품명, 1:성분명(영문), 2:성분명(한글), Default = '0'
      drugPackageFlag := 1;    // 1:병팩단위, 0:그외약품
        CItem := TadCommentItem.Create;
        CItem.resnm := '중복투여 치료군' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resncnts := '동일 치료군 내 하나의 약재료 질병이 조절되지 않 으며, 대체 가능한 다른 치료군이 없음.' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resnm := '진서방정10/5mg' + FormatDateTime('yyyymmddhhnnsszzz',now);
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
  Result := TBridgeRequest_354( GBridgeFactory.MakeRequestObj( EventID_전자처방전발급 ) );
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
      docLicenseType := '1'; // 1:의사, 2:한의사, 3:수의사, 4:치과의사, 5:기타
      docLicenseTypeName := '의사';  // 의사, 한의사, 수의사, 치과의사, 기타
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


(*      // 처방전 부가 정보
      for i := 1 to 10 do
      begin
        CItem := TadCommentItem.Create;
        CItem.resnm := '중복투여 치료군' + format('_%d_',[i])+ FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resncnts := '동일 치료군 내 하나의 약재료 질병이 조절되지 않 으며, 대체 가능한 다른 치료군이 없음.' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resnm := '진서방정10/5mg' + format('_%d_',[i]) + FormatDateTime('yyyymmddhhnnsszzz',now);
        AddadComment( CItem );
      end; *)

//      InputDrug_1( Result );
      // 약 처방 및 용법
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
begin // 결제 요청
  crrid.Id1 := LiteQuery1.FieldByName('chartrrid1').AsString;
  crrid.Id2 := LiteQuery1.FieldByName('chartrrid2').AsString;
  crrid.Id3 := LiteQuery1.FieldByName('chartrrid3').AsString;
  crrid.Id4 := LiteQuery1.FieldByName('chartrrid4').AsString;
  crrid.Id5 := LiteQuery1.FieldByName('chartrrid5').AsString;
  crrid.Id6 := LiteQuery1.FieldByName('chartrrid6').AsString;
  if AccountDM.CheckAccountPatient( crrid ) then
  begin
    if FCheckAutoAccountProcess then // 자동 결제의 경우에만 아래 message를 출력 한다.
    begin
      if MessageDlg( '자동결제 가능 환자입니다.' + #13#10 + '자동결제 화면으로 이동 하시겠습니까?', mtConfirmation, mbYesNo, 0) = mrNo then
        exit;
    end;
  end
  else
  begin
    if not FCheckAutoAccountProcess then // 자동 결제 process의 경우 아래 message를 출력하지 않는다.
      MessageDlg( '결제 연결이 안되어 있는 환자입니다.', mtWarning, [mbOK], 0);
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
begin  // 결제 취소
  msg := format('접수 정보 : %s(%s) ',[LiteQuery1.FieldByName('chartid').AsString, LiteQuery1.FieldByName('chartrrid1').AsString]);
  msg := msg + #13#10 + format('결제승인번호 : %s ',[ LiteQuery1.FieldByName('payauthno').AsString ]);
  msg := msg + #13#10 + format('금액 : 환자 부담금(%s), 공단 부담금(%s), 총 금액(%s) ',[
                                          FormatFloat('#,0',LiteQuery1.FieldByName('userAmt').AsLongWord),
                                          FormatFloat('#,0',LiteQuery1.FieldByName('nhisAmt').AsLongWord),
                                          FormatFloat('#,0',LiteQuery1.FieldByName('totalAmt').AsLongWord) ]);
  msg := msg + #13#10 + format('할부 정보 : %s ',[ LiteQuery1.FieldByName('planMonth').AsString ]);
  msg := msg + #13#10#13#10 + '정말 결제를 취소하시겠습니까?';
  //rid := LiteQuery1.FieldByName('rid').AsLongWord;

  if MessageDlg( msg, mtConfirmation, mbYesNo, 0) = mrNo then
    exit;

  if AccountDM.Send144(LiteQuery1.FieldByName('chartrrid1').AsString, LiteQuery1.FieldByName('payauthno').AsString, '뭘물어~~ 그냥', transdttm, rcd, resultmsg) <> Result_SuccessCode then
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

    MessageDlg( '취소 되었습니다.', mtInformation, [mbOK], 0);
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
begin // 진료 완료
  if not ( Sender is TMenuItem ) then
    exit;

  //isOnlyEP := False;
  case TMenuItem( Sender ).tag of
    1 : statuscode := Status_내원요청; // 내원 요청
    2 : statuscode := Status_내원확정;// 내원 확정
    3 : statuscode := Status_진료대기;// 진료 대기
    4 : statuscode := Status_진료완료;// 진료 완료
    //5 : isOnlyEP := True;// 전자 처방전 발송 test
    11 : statuscode := Status_본인취소;// 본인 취소
    12 : statuscode := Status_병원취소;// 병원 취소
    13 : statuscode := Status_자동취소;// 자동 취소
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
      LiteQuery1.FieldByName( 'status' ).AsString := statuscode; // 상태 변경
      LiteQuery1.FieldByName( 'statusmng' ).AsString := statuscode; // 상태 변경
  LiteQuery1.Post;

  event_108 := TBridgeRequest_108( GBridgeFactory.MakeRequestObj( EventID_대기열상태값변경 ) );
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
  if (statuscode = Status_진료완료) and ( gdid <> '' ) then
  begin // 완료 이고, gdid가 있는 환자만 전자 처방전을 전송하게 한다.
    // 전자 처방전 처리
    processEP( event_108.ReceptionUpdateDto.PatientChartId,
               PatientMngForm.GetGDID(event_108.ReceptionUpdateDto.PatientChartId),
               event_108.ReceptionUpdateDto.chartReceptnResultId );
  end;
{$endif}

  UpdatePeriod(now, GSendReceptionPeriodRoomInfo.RoomCode);

  if isDummy then
  begin
    ChartEmulV4Form.AddMemo( format('접수번호(%s)는 더미 data로 상태 변경 data를 전송하지 않는다.',[event_108.ReceptionUpdateDto.chartReceptnResultId.Id1]) );
  end
  else
  begin //
    ChartEmulV4Form.AddMemo( event_108.EventID, event_108.JobID );
    ret := GetBridge.RequestResponse( event_108.ToJsonString );
    responsebase := GBridgeFactory.MakeResponseObj( ret );
    ChartEmulV4Form.AddMemo( responsebase.EventID, responsebase.JobID, responsebase.Code, responsebase.MessageStr, 0 );
    FreeAndNil( responsebase );
  end;

  // 자동 결제 처리
  if AccountDM.Active and (statuscode = Status_진료완료) then
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
    exit; // 전자 처방전 처리 병원이 아니다.

{
전자 처방전을 사용하는 병원이라면 모든 환자에 대한 처방전을 전송 할수 있게 한다.
단, gdid가 있는 환자만 전송하게 한다.
  // 환자 정보를 check하여 전자 처방전 사용하는 환자인지 확인 한다.
  //if PatientMngForm.GetPatientPrescription( AChartID ) = 0 then
  //  exit; // 전자 처방전을 사용하는 환자가 아니다. }

  if AGDID = '' then
    exit; // goodoc id가 없으면 전자 처방전을 전송하지 않는다

  Timer_354.Enabled := False;
  // 접수 정보 확인하여 prescription이 true이면 354를 전송 한다.
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
  ChartEmulV4Form.AddMemo( EventID_전자처방전발급, AEvent354.JobID );

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

  // 순서 정렬, 당일 roomcode, period순으로 순서 대로...
  with LiteQuery2 do
  begin
    //SQL.Text := 'select * from reception where status in (''C04'', ''C07'') and roomcode = :roomcode and receptiondate = :receptiondate order by period';  //  C04(진료대기), C08(진료중)
    SQL.Text := 'select * from reception where status in (''C04'', ''C05'', ''C06'', ''C07'') and roomcode = :roomcode and receptiondate = :receptiondate order by period';  //  C04(진료대기), C08(진료중)
    ParamByName('roomcode').Value := ARoomInfo.RoomCode;
    ParamByName('receptiondate').Value := FormatDateTime('yyyy-mm-dd', ADate);
    Active := True;
    try
      First;

      event_104 := TBridgeRequest_104( GBridgeFactory.MakeRequestObj( EventID_대기순번변경 ) );
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

        addlog( doRunLog, '전송 : ' + event_104.ToJsonString);
        ChartEmulV4Form.AddMemo( event_104.EventID, event_104.JobID );
        str := GetBridge.RequestResponse( event_104.ToJsonString );
        addlog( doRunLog, '결과 : ' + str);
        responsebase := GBridgeFactory.MakeResponseObj( str );
        try
          ChartEmulV4Form.AddMemo( responsebase.EventID, responsebase.JobID, responsebase.Code, responsebase.MessageStr, 0 );
          if event_104.JobID <> responsebase.JobID then
          begin
            ChartEmulV4Form.AddMemo( format('EventID:%d에 대한 JobID값이 없거나 틀리다.(JobID=%s)', [responsebase.EventID, responsebase.JobID]) );
            AddLog(doWarningLog, format('EventID:%d에 대한 JobID값이 없거나 틀리다.(JobID=%s)', [responsebase.EventID, responsebase.JobID]) );
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
  Result := TBridgeResponse_353( GBridgeFactory.MakeRequestObj(EventID_전자처방전발급설정결과, AEvent352.JobID ) );
  if AEvent352.AnalysisErrorCode <> Result_SuccessCode then
  begin
    Result.Code := AEvent352.AnalysisErrorCode;
    Result.MessageStr :=  GBridgeFactory.GetErrorString( Result.Code );
    exit;
  end;

  try
    //gdid를 이용해서 hipass, prescription값을 update한다.
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
이건이라면 여기서 data를 전송하면 않되는데...
순번 data를 올리지 않는다.
*)
    exit;

    event_108 := TBridgeRequest_108( GBridgeFactory.MakeRequestObj( EventID_대기열상태값변경 ) );
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
    // 순서 정렬, 당일 roomcode, period순으로 순서 대로...
    with Query104 do
    begin
      Active := False;
      //SQL.Text := 'select * from reception where status in (''C04'', ''C07'') and roomcode = :roomcode and receptiondate = :receptiondate order by period';  //  C04(진료대기), C08(진료중)
      // 상태 C04, C05, C06, C07는 진료 대기로 구분해서 처리 하자.
      SQL.Text := 'select * from reception where status in (''C04'', ''C05'', ''C06'', ''C07'') and roomcode = :roomcode and receptiondate = :receptiondate order by period';  //  C04(진료대기), C08(진료중)
      ParamByName('roomcode').Value := ARoomCode;
      ParamByName('receptiondate').Value := FormatDateTime('yyyy-mm-dd', AUpdateDate);
      Active := True;
      First;

      // 내원 요청 상태를 고려한 순번 data 만들기
      seq := 0; isadd := False;
      while not eof do
      begin
        Inc( seq );
        oldseq := FieldByName( 'period' ).AsInteger;

        if not isadd then
        begin // 처음 data부터 내원확인 data이면 별도 목록에 저장 한다.
          if FieldByName( 'statusmng' ).AsString = Status_내원요청 then
          begin
            c05list.Add( inttostr(FieldByName( 'rid' ).AsInteger) );
            if oldseq = Const_Period_Send then
            begin // 접수 상태를 서버로 전송 한다.
              send108( LiteQuery2 ); // 상태가 변경된 data를 전송하게 한다.
            end;
            Next;
            Continue;
          end
          else
            isadd := True;
        end;

        seqlist.Values[ inttostr(FieldByName( 'rid' ).AsInteger) ] := inttostr( seq ); // 기본 순번 등록

        if oldseq = Const_Period_Send then
        begin // 접수 상태를 서버로 전송 한다.
          send108( Query104 ); // 상태가 변경된 data를 전송하게 한다.
        end;

        if c05list.Count > 0 then
        begin
          // 별도 내원확인 목록에 저장된 data에 대한 순번 data를 생성해주고
          for i := 0 to c05list.Count -1 do
          begin
            Inc( seq );
            seqlist.Values[ c05list.Strings[i] ] := inttostr( seq );
          end;
          // 목록을 초기화 한다.
          c05list.Clear;
        end;

        next;
      end;
        // 대기실에 apps으로 접수한 data만 존재 했을 때 사용 한다.
        if c05list.Count > 0 then
        begin
          // 별도 내원확인 목록에 저장된 data에 대한 순번 data를 생성해주고
          for i := 0 to c05list.Count -1 do
          begin
            Inc( seq );
            seqlist.Values[ c05list.Strings[i] ] := inttostr( seq );
          end;
          // 목록을 초기화 한다.
          c05list.Clear;
        end;

      First;
      while not eof do
      begin
        seq := StrToIntDef( seqlist.Values[ IntToStr(FieldByName( 'rid' ).AsInteger) ], 0  );
        if seq = 0 then
        begin // 다음 data를 처리 하자. 처리 할 수 없는 data이다.
          Next;
          Continue;
        end;

        Edit;
        FieldByName( 'period' ).AsInteger := seq;
  (*      if seq = 1 then
          FieldByName( 'status' ).AsString := Status_진료차례; *)
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
    addlog( doRunLog, '내원확인요청으로 인한 진료 순번 변경 시작' );
    UpdatePeriod( AUpdateDate, rcode );
    rinfo := GetRoomInfo( rcode );
    SendPeriod(now, rinfo);
    addlog( doRunLog, '내원확인요청으로 인한 진료 순번 변경 완료' );
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
  Result := TBridgeRequest_111( GBridgeFactory.MakeRequestObj(EventID_내원확인요청결과, AVisitConfirmData.JobID ) );
  if AVisitConfirmData.AnalysisErrorCode <> Result_Success then
  begin
    Result.MessageStr := GBridgeFactory.GetErrorString( AVisitConfirmData.AnalysisErrorCode );
    exit;
  end;

  Result.MessageStr := '';
  Result.HospitalNo := AVisitConfirmData.HospitalNo;
  CheckBox1.Checked := AVisitConfirmData.reclnicOnly = 1; // 재진만 접수를 UI에 표시

  LiteQuery2.Active := False;

  // 모두 내원 확정 처리를 한다.
  for i := 0 to AVisitConfirmData.Count -1 do
  begin
    data := AVisitConfirmData.confirmList[ i ];

    ret := 0; // 실패
    try
      //    db에서 data 속성을 변경 한다.
      if data.receptnResveType = 0 then
      begin // 예약 data의 처리
       // 접수 table에 있는 접수 번호가 내려 오나???
       // 예약완료 상태에서 예약접수 기능을 실행 해야 한다.

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
          begin // 재진만 접수 시, AVisitConfirmData.reclnicOnly 1이면 재진만 접수
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
          begin // data가 있다.
            // 예약완료 상태의 data만 접수 처리를 한다.
            if FieldByName('status').AsString = Status_예약완료 then
            begin
              ReservationMngForm.AddReception( LiteQuery2 );
              ret := 1; // 성공
            end;
          end
          else
          begin // 초진 환자가 예약 했다.
            if AVisitConfirmData.reclnicOnly = 1 then
            begin // 재진만 접수 시
              ret := 0; // 실패
              Result.isFirst := 1; // 신규 환자다.
            end
            else
            begin
              if FieldByName('status').AsString = Status_예약완료 then
              begin
                ReservationMngForm.AddReception( LiteQuery2 );
                ret := 1; // 성공
              end;
            end;
          end;
        end;
      end
      else
      begin  // 진료 data의 처리
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
          begin // data가 있다.
            // 내원 요청 상태의 data만 확정 처리를 한다.
            //if FieldByName('statusmng').AsString = Status_내원요청 then
            begin
              if ARoomList.IndexOf( FieldByName('roomcode').AsString ) < 0 then
                ARoomList.Add( FieldByName('roomcode').AsString );

              edit;
                FieldByName('status').AsString := Status_내원확정;
                FieldByName('statusmng').AsString := Status_내원확정;
              Post;

              event_108 := TBridgeRequest_108( GBridgeFactory.MakeRequestObj( EventID_대기열상태값변경 ) );
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

              event_108.ReceptionUpdateDto.Status := Status_내원확정;
              event_108.receptStatusChangeDttm     := now;

              event_108.NewchartReceptnResult.Id1 := '';
              event_108.NewchartReceptnResult.Id2 := '';
              event_108.NewchartReceptnResult.Id3 := '';
              event_108.NewchartReceptnResult.Id4 := '';
              event_108.NewchartReceptnResult.Id5 := '';
              event_108.NewchartReceptnResult.Id6 := '';
              ret := 1; // 성공

              ChartEmulV4Form.AddMemo( event_108.EventID, event_108.JobID );
              retstr := GetBridge.RequestResponse( event_108.ToJsonString );
              responsebase := GBridgeFactory.MakeResponseObj( retstr );
              ChartEmulV4Form.AddMemo( responsebase.EventID, responsebase.JobID, responsebase.Code, responsebase.MessageStr, 0 );
              FreeAndNil( responsebase );
              FreeAndNil( event_108 );
            end; // if문
          end;
        end;
      end;
    finally
      LiteQuery2.Active := False;
    end;
    // 처리 결과 등록
    ConfirmResult( Result, data, ret );
  end;  // for문
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

  if (AStatusCode <> Status_진료대기)
    and (AStatusCode <> Status_내원확정)
    and (AStatusCode <> Status_본인취소)
    and (AStatusCode <> Status_병원취소)
    and (AStatusCode <> Status_자동취소)
    and (AStatusCode <> Status_진료완료)
    and (AStatusCode <> Status_예약완료) then
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
        FieldByName( 'status' ).AsString := AStatusCode; // 상태 변경
        FieldByName( 'statusmng' ).AsString := AStatusCode; // 상태 변경
        Post;
      end;
  finally
    LiteQuery2.Active := false;
  end;

  if string.IsNullOrEmpty(chartid) then
    exit;

  event_108 := TBridgeRequest_108( GBridgeFactory.MakeRequestObj( EventID_대기열상태값변경 ) );
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
  if (statuscode = Status_진료완료) and ( gdid <> '' ) then
  begin // 완료 이고, gdid가 있는 환자만 전자 처방전을 전송하게 한다.
    // 전자 처방전 처리
    processEP( event_108.ReceptionUpdateDto.PatientChartId,
               PatientMngForm.GetGDID(event_108.ReceptionUpdateDto.PatientChartId),
               event_108.ReceptionUpdateDto.chartReceptnResultId );
  end;
{$endif}

  UpdatePeriod(now, GSendReceptionPeriodRoomInfo.RoomCode);

  if isDummy then
  begin
    ChartEmulV4Form.AddMemo( format('접수번호(%s)는 더미 data로 상태 변경 data를 전송하지 않는다.',[event_108.ReceptionUpdateDto.chartReceptnResultId.Id1]) );
  end
  else
  begin //
    ChartEmulV4Form.AddMemo( event_108.EventID, event_108.JobID );
    ret := GetBridge.RequestResponse( event_108.ToJsonString );
    responsebase := GBridgeFactory.MakeResponseObj( ret );
    ChartEmulV4Form.AddMemo( responsebase.EventID, responsebase.JobID, responsebase.Code, responsebase.MessageStr, 0 );
    FreeAndNil( responsebase );
  end;

  // 자동 결제 처리
  if AccountDM.Active and (AStatusCode = Status_진료완료) then
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
