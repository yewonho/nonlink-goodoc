unit RnRDMUnit;

interface

uses
  System.SysUtils, System.Classes, Data.DB, Datasnap.DBClient,
  RnRData, RRObserverUnit, BridgeCommUnit, SyncObjs;

type
  TRnRDM = class(TDataModule)
    RR_DB: TClientDataSet;
    Room_DB: TClientDataSet;
    CancelMsg_DB: TClientDataSet;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
    FObserver : TRRObserver;
    FRRTableLock: TCriticalSection;
    FIsTaskRunning: Boolean;

    function GetRoomFilterButtonVisible: Boolean;
  public
    { Public declarations }
    constructor Create( AOwner : TComponent ); override;
    destructor Destroy; override;

    procedure RRTableEnter;  // rr_db lock
    procedure RRTableLeave;  // rr_db unlock

    procedure MakeTable;
    procedure ClearRoomTable; // 진료실 목록 table을 초기화 한다.
    procedure PackRoomTable( AEvent403 : TBridgeResponse_403 ); // 진료실 목록 table에 진료실 정보를 추가 한다.

    // 취소 메시지 table을 초기화 한다.
    procedure ClearCancelMsgTable;
    // 취소 메시지 목록 table에 취소 메시지 정보를 추가 한다.
    procedure PackCancelMsgTable( AEvent303 : TBridgeResponse_303 );

    // 접수/예약 목록 update, 반환값은 마지막 수정된 일시이다.
    function PackReceptionReservationList( AEvent401 : TBridgeResponse_401; var ACount, AFlashCount : Integer ) : TDateTime;
    // 접수 정보 추가
    function AddReception( AEvent100 : TBridgeResponse_100 ) : TBridgeRequest_101;
    function AddReceptionFake( AEvent100 : TBridgeResponse_100 ) : TBridgeRequest_101;
    // 접수 정보 취소
    function CancelReception( AEvent102 : TBridgeResponse_102 ) : TBridgeRequest_103;
    // 내원 확인
    function VisitConfirm( AVisitConfirmData : TBridgeResponse_110 ) : TBridgeRequest_111;
    // 예약 정보 추가
    function AddReservation( AEvent200 : TBridgeResponse_200 ) : TBridgeRequest_201;
    // 예약 정보 취소
    function CancelReservation( AEvent202 : TBridgeResponse_202 ) : TBridgeRequest_203;

    // 지정된 접수/예약 record를 table에서 찾아서 그 결과를 반환 한다.
    function FindRR( AFindData : TRnRData ) : Boolean;
    function FindRR2( chartReceptnResultId1 : string; chartReceptnResultId2 : string; chartReceptnResultId3: string; chartReceptnResultId4: string; chartReceptnResultId5: string; chartReceptnResultId6: string) : Boolean;
    // RR_Db에서 status값을 수정 한다.
    procedure UpdateStatusRR(AFindData : TRnRData; AStatus : TRnRDataStatus);
    // RR_Db에서 room값을 수정 한다.
    procedure UpdateRoomInfoRR(AFindData : TRnRData; ARoomInfo : TRoomInfo);
    // RR_Db에서 reserveDttm값을 수정 한다.
    procedure UpdateReserveDttmRR(AFindData : TRnRData; AReserveDateTime : TDateTime);
    // RR_Db에서 접수내역을 최신값으로 수정한다.
    procedure UpdateReceptionReservation( AEvent407 : TBridgeResponse_407 );

    // 첫번째 room 정보를 읽어 낸다. 보통 room 정보가 1개일때만 사용해야 한다.
    function GetFirstRoomInfo( var ARoomInfo : TRoomInfo ) : Boolean;


    // rr_db에 있는 data 한개를 data에 저장 시킨다.
    procedure GetReceptionReservationData( AData : TRnRData );

    property RoomFilterButtonVisible : Boolean read GetRoomFilterButtonVisible;
    property IsTaskRunning : Boolean read FIsTaskRunning;
  end;

var
  RnRDM: TRnRDM;

implementation
uses
  System.Variants,
  EventIDConst, RestCallUnit;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TRnRDM }

function TRnRDM.AddReception(
  AEvent100: TBridgeResponse_100): TBridgeRequest_101;
var
  i : Integer;
  str : string;
begin
  Result := TBridgeRequest_101( GetBridgeFactory.MakeRequestObj( EventID_접수요청결과, AEvent100.JobID ) );

  RR_DB.IndexName := 'pkIndex';
  with AEvent100 do
  begin
    Result.HospitalNo := HospitalNo;
    Result.chartReceptnResultId.Id1 := FormatDateTime('yyyymmddhhnnsszzz', now);
    Result.chartReceptnResultId.Id2 := '';
    Result.chartReceptnResultId.Id3 := '';
    Result.chartReceptnResultId.Id4 := '';
    Result.chartReceptnResultId.Id5 := '';
    Result.chartReceptnResultId.Id6 := '';
    Result.PatntChartID := PatntChartID;  // 차트 id
    //if Result.PatntChartID = '' then
    //  Result.PatntChartID := 'P' + Result.chartReceptnResultId.Id1;
    Result.gdid := gdid;
    Result.RegNum := RegNum;
    Result.ePrescriptionHospital := 0;  // 전자 처방전 병원 여부 (0:미사용,1:사용)

    Result.RoomInfo := RoomInfo;

    RRTableEnter;
    try
      RR_DB.Append; // 추가 한다.

      RR_DB.FieldByName( 'ChartReceptnResultId1' ).AsString := Result.chartReceptnResultId.Id1; // 굿닥에서 관리하는 접수 id
      RR_DB.FieldByName( 'ChartReceptnResultId2' ).AsString := Result.chartReceptnResultId.Id2; // 굿닥에서 관리하는 접수 id
      RR_DB.FieldByName( 'ChartReceptnResultId3' ).AsString := Result.chartReceptnResultId.Id3; // 굿닥에서 관리하는 접수 id
      RR_DB.FieldByName( 'ChartReceptnResultId4' ).AsString := Result.chartReceptnResultId.Id4; // 굿닥에서 관리하는 접수 id
      RR_DB.FieldByName( 'ChartReceptnResultId5' ).AsString := Result.chartReceptnResultId.Id5; // 굿닥에서 관리하는 접수 id
      RR_DB.FieldByName( 'ChartReceptnResultId6' ).AsString := Result.chartReceptnResultId.Id6; // 굿닥에서 관리하는 접수 id

      RR_DB.FieldByName( 'chartid' ).AsString := PatntChartID; // 환자 차트 id
      RR_DB.FieldByName( 'patientname' ).AsString := PatntName; // 환자 이름
      RR_DB.FieldByName( 'patientid' ).AsString := PatntChartID; // V4.
      RR_DB.FieldByName( 'gdid' ).AsString := Result.gdid; // 환자 gdid

      RR_DB.FieldByName( 'datatype' ).AsInteger := integer( TRRDataTypeConvert.DataType2RnRType( RRType_Reception ) ); // 유형  접수 C/예약 S

      RR_DB.FieldByName( 'cellphone' ).AsString := Cellphone; // 전화 번호
      RR_DB.FieldByName( 'registration_number' ).AsString := Result.RegNum; // 주민등록 번호 xxxxxxxxxxxxx => 13자리
      RR_DB.FieldByName( 'birthday' ).AsString := Birthday; // 생년월일, yyyymmdd

      RR_DB.FieldByName( 'gender' ).AsInteger := Ord( TRRDataTypeConvert.GenderType2RnRGender( Sexdstn ) ); // 성별,  성별 (남:1/3/5/7/9, 여:2/4/6/8/0)

      RR_DB.FieldByName( 'addr' ).AsString := Addr; // 주소
      RR_DB.FieldByName( 'addrdetail' ).AsString := AddrDetail; // 상세 주소
      RR_DB.FieldByName( 'zip' ).AsString := Zip; // 우편 번호

      RR_DB.FieldByName( 'memo' ).AsString := ''; // 메모
      RR_DB.FieldByName( 'isfirst' ).AsBoolean := isFirst; // 초진/재진 구분, 우선은 재진으로 등록 한다.

      RR_DB.FieldByName( 'roomcode' ).AsString := Result.RoomInfo.RoomCode;
      RR_DB.FieldByName( 'roomname' ).AsString := Result.RoomInfo.RoomName;
      RR_DB.FieldByName( 'deptcode' ).AsString := Result.RoomInfo.DeptCode;
      RR_DB.FieldByName( 'deptname' ).AsString := Result.RoomInfo.DeptName;
      RR_DB.FieldByName( 'doctorcode' ).AsString := Result.RoomInfo.DoctorCode;
      RR_DB.FieldByName( 'doctorname' ).AsString := Result.RoomInfo.DoctorName;

      RR_DB.FieldByName('devicetype').AsInteger :=  Ord( TRRDataTypeConvert.InDevice2RnRInDevice( EndPoint ) ); // 유입 매체  tablet, web, mobile  Tablet/App여부

      RR_DB.FieldByName('inboundpath').AsString := InboundPath; // 내원 경로

      str := '';
      for i := 0 to PurposeListCount-1 do
      begin
        if str <> '' then
          str := str + '|';
        with PurposeLists[i] do
        begin
          str := str + purpose1 + '.'+purpose2+'.'+purpose3;
        end;
      end;
      if etcPurpose <> '' then
      begin
        if str <> '' then
          str := str + '|';
        str := str+etcPurpose;
      end;
      RR_DB.FieldByName('symptom').AsString := str; // 내원 목적

      RR_DB.FieldByName('status').AsInteger := integer( TRRDataTypeConvert.DataStatus2RnRDataStatus( integer( rrs접수요청) ) ); // data 상태
      RR_DB.FieldByName( 'canceledmessage' ).AsString := '';  // 취소 메시지

      RR_DB.FieldByName( 'receptiondttm' ).AsDateTime := ReceptionDttm;  // 접수/예약 일시
      RR_DB.FieldByName( 'reservedttm' ).AsDateTime := ReceptionDttm;  // 예약방문 일시
      RR_DB.FieldByName( 'lastchangedttm' ).AsDateTime := ReceptionDttm;  // 마지막 수정 일시

      RR_DB.FieldByName( 'hsptlreceptndttm' ).AsDateTime := 0; // 접수 확정이 되면 해당 field에 data가 설정됨

      RR_DB.Post;
    finally
      RRTableLeave;
    end;

    Result.Code := Result_SuccessCode;
    Result.MessageStr := GetBridgeFactory.GetErrorString( Result.Code );
  end;
end;

function TRnRDM.AddReceptionFake(
  AEvent100: TBridgeResponse_100): TBridgeRequest_101;
var
  i : Integer;
  str : string;
begin
  Result := TBridgeRequest_101( GetBridgeFactory.MakeRequestObj( EventID_접수요청결과, AEvent100.JobID ) );

  with AEvent100 do
  begin
    Result.HospitalNo := HospitalNo;
    Result.chartReceptnResultId.Id1 := FormatDateTime('yyyymmddhhnnsszzz', now);
    Result.chartReceptnResultId.Id2 := '';
    Result.chartReceptnResultId.Id3 := '';
    Result.chartReceptnResultId.Id4 := '';
    Result.chartReceptnResultId.Id5 := '';
    Result.chartReceptnResultId.Id6 := '';
    Result.PatntChartID := PatntChartID;  // 차트 id
    //if Result.PatntChartID = '' then
    //  Result.PatntChartID := 'P' + Result.chartReceptnResultId.Id1;
    Result.gdid := gdid;
    Result.RegNum := RegNum;
    Result.ePrescriptionHospital := 0;  // 전자 처방전 병원 여부 (0:미사용,1:사용)

    Result.RoomInfo := RoomInfo;

    Result.Code := Result_SuccessCode;
    Result.MessageStr := GetBridgeFactory.GetErrorString( Result.Code );
  end;
end;

function TRnRDM.AddReservation(
  AEvent200: TBridgeResponse_200): TBridgeRequest_201;
var
  i : Integer;
  str : string;
begin
  Result := TBridgeRequest_201( GetBridgeFactory.MakeRequestObj( EventID_예약요청결과, AEvent200.JobID ) );

  RR_DB.IndexName := 'pkIndex';
  with AEvent200 do
  begin
    Result.HospitalNo := HospitalNo;
    Result.chartReceptnResultId.Id1 := FormatDateTime('yyyymmddhhnnsszzz', now);
    Result.chartReceptnResultId.Id2 := '';
    Result.chartReceptnResultId.Id3 := '';
    Result.chartReceptnResultId.Id4 := '';
    Result.chartReceptnResultId.Id5 := '';
    Result.chartReceptnResultId.Id6 := '';
    Result.PatntChartID := PatntChartId;  // 차트 id
    if Result.PatntChartID = '' then
      Result.PatntChartID := 'P' + Result.chartReceptnResultId.Id1;
    Result.RegNum := RegNum;

    Result.RoomInfo.RoomCode := '';
    Result.RoomInfo.RoomName := '';
    Result.RoomInfo.DeptCode := '';
    Result.RoomInfo.DeptName := '';
    Result.RoomInfo.DoctorCode := '';
    Result.RoomInfo.DoctorName := '';

    RRTableEnter;
    try
      RR_DB.Append; // 추가 한다.

      RR_DB.FieldByName( 'ChartReceptnResultId1' ).AsString := Result.chartReceptnResultId.Id1; // 굿닥에서 관리하는 접수 id
      RR_DB.FieldByName( 'ChartReceptnResultId2' ).AsString := Result.chartReceptnResultId.Id2; // 굿닥에서 관리하는 접수 id
      RR_DB.FieldByName( 'ChartReceptnResultId3' ).AsString := Result.chartReceptnResultId.Id3; // 굿닥에서 관리하는 접수 id
      RR_DB.FieldByName( 'ChartReceptnResultId4' ).AsString := Result.chartReceptnResultId.Id4; // 굿닥에서 관리하는 접수 id
      RR_DB.FieldByName( 'ChartReceptnResultId5' ).AsString := Result.chartReceptnResultId.Id5; // 굿닥에서 관리하는 접수 id
      RR_DB.FieldByName( 'ChartReceptnResultId6' ).AsString := Result.chartReceptnResultId.Id6; // 굿닥에서 관리하는 접수 id

      RR_DB.FieldByName( 'chartid' ).AsString := Result.PatntChartID; // 환자 차트 id
      RR_DB.FieldByName( 'patientname' ).AsString := PatntName; // 환자 이름
      RR_DB.FieldByName( 'patientid' ).AsString := ''; // V4
      RR_DB.FieldByName( 'gdid' ).AsString := ''; // 환자 gdid

      RR_DB.FieldByName( 'datatype' ).AsInteger := integer( TRRDataTypeConvert.DataType2RnRType( RRType_Reservation ) ); // 유형  접수 C/예약 S

      RR_DB.FieldByName( 'cellphone' ).AsString := Cellphone; // 전화 번호
      RR_DB.FieldByName( 'registration_number' ).AsString := Result.RegNum; // 주민등록 번호 xxxxxxxxxxxxx => 13자리
      RR_DB.FieldByName( 'birthday' ).AsString := Birthday; // 생년월일, yyyymmdd

      RR_DB.FieldByName( 'gender' ).AsInteger := Ord( TRRDataTypeConvert.GenderType2RnRGender( Sexdstn ) ); // 성별,  성별 (남:1/3/5/7/9, 여:2/4/6/8/0)

      RR_DB.FieldByName( 'addr' ).AsString := Addr; // 주소
      RR_DB.FieldByName( 'addrdetail' ).AsString := AddrDetail; // 상세 주소
      RR_DB.FieldByName( 'zip' ).AsString := Zip; // 우편 번호

      RR_DB.FieldByName( 'memo' ).AsString := ''; // 메모
      RR_DB.FieldByName( 'isfirst' ).AsBoolean := false; // 초진/재진 구분, 우선은 재진으로 등록 한다.

      RR_DB.FieldByName( 'roomcode' ).AsString := Result.RoomInfo.RoomCode;
      RR_DB.FieldByName( 'roomname' ).AsString := Result.RoomInfo.RoomName;
      RR_DB.FieldByName( 'deptcode' ).AsString := Result.RoomInfo.DeptCode;
      RR_DB.FieldByName( 'deptname' ).AsString := Result.RoomInfo.DeptName;
      RR_DB.FieldByName( 'doctorcode' ).AsString := Result.RoomInfo.DoctorCode;
      RR_DB.FieldByName( 'doctorname' ).AsString := Result.RoomInfo.DoctorName;

      RR_DB.FieldByName('devicetype').AsInteger :=  Ord( TRRDataTypeConvert.InDevice2RnRInDevice( InDeviceType_App ) ); // 유입 매체  tablet, web, mobile  Tablet/App여부

      RR_DB.FieldByName('inboundpath').AsString := ''; // 내원 경로

      str := '';
      for i := 0 to PurposeListCount-1 do
      begin
        if str <> '' then
          str := str + '|';
        with PurposeLists[i] do
        begin
          str := str + purpose1 + '.'+purpose2+'.'+purpose3;
        end;
      end;
      if etcPurpose <> '' then
      begin
        if str <> '' then
          str := str + '|';
        str := str+etcPurpose;
      end;
      RR_DB.FieldByName('symptom').AsString := str; // 내원 목적

      RR_DB.FieldByName('status').AsInteger := integer( TRRDataTypeConvert.DataStatus2RnRDataStatus( integer( rrs접수요청) ) ); // data 상태
      RR_DB.FieldByName( 'canceledmessage' ).AsString := '';  // 취소 메시지

      RR_DB.FieldByName( 'receptiondttm' ).AsDateTime := RegistrationDttm;  // 접수/예약 일시
      RR_DB.FieldByName( 'reservedttm' ).AsDateTime := ReserveDttm;  // 예약방문 일시
      RR_DB.FieldByName( 'lastchangedttm' ).AsDateTime := ReserveDttm;  // 마지막 수정 일시
      RR_DB.Post;
    finally
      RRTableLeave;
    end;

    Result.Code := Result_SuccessCode;
    Result.MessageStr := GetBridgeFactory.GetErrorString( Result.Code );
  end;
end;

function TRnRDM.CancelReception(
  AEvent102: TBridgeResponse_102): TBridgeRequest_103;
begin
  Result := TBridgeRequest_103( GetBridgeFactory.MakeRequestObj( EventID_접수취소결과, AEvent102.JobID ) );
  RR_DB.IndexName := 'pkIndex';

  with AEvent102 do
  begin
    RRTableEnter;
    try
      if not RR_DB.Locate('ChartReceptnResultId1;ChartReceptnResultId2;ChartReceptnResultId3;ChartReceptnResultId4;ChartReceptnResultId5;ChartReceptnResultId6',
                          VarArrayOf ([ chartReceptnResultId.Id1,chartReceptnResultId.Id2,chartReceptnResultId.Id3,chartReceptnResultId.Id4,chartReceptnResultId.Id5,chartReceptnResultId.Id6]),
                          [loCaseInsensitive]) then
      begin // 처리 해야할 data가 없다
        Result.Code := Result_NoData;
      end
      else
      begin
        RR_DB.edit; // 찾았다. data를 수정 한다.
        RR_DB.FieldByName( 'status' ).AsInteger := ord( rrs본인취소 );
        RR_DB.FieldByName( 'lastchangedttm' ).AsDateTime := receptStatusChangeDttm;
        RR_DB.Post;

        Result.Code := Result_SuccessCode;
      end;
    finally
      RRTableLeave;
    end;
    Result.MessageStr := GetBridgeFactory.GetErrorString( Result.Code );
  end;
end;

function TRnRDM.CancelReservation(
  AEvent202: TBridgeResponse_202): TBridgeRequest_203;
begin
  Result := TBridgeRequest_203( GetBridgeFactory.MakeRequestObj( EventID_예약취소결과, AEvent202.JobID ) );
  RR_DB.IndexName := 'pkIndex';

  with AEvent202 do
  begin
    RRTableEnter;
    try
      if not RR_DB.Locate('ChartReceptnResultId1;ChartReceptnResultId2;ChartReceptnResultId3;ChartReceptnResultId4;ChartReceptnResultId5;ChartReceptnResultId6',
                          VarArrayOf ([ chartReceptnResultId.Id1,chartReceptnResultId.Id2,chartReceptnResultId.Id3,chartReceptnResultId.Id4,chartReceptnResultId.Id5,chartReceptnResultId.Id6]),
                          [loCaseInsensitive]) then
      begin // 처리 해야할 data가 없다
        Result.Code := Result_NoData;
      end
      else
      begin
        RR_DB.edit; // 찾았다. data를 수정 한다.
        RR_DB.FieldByName( 'status' ).AsInteger := ord( rrs본인취소 );
        RR_DB.FieldByName( 'lastchangedttm' ).AsDateTime := receptStatusChangeDttm;
        RR_DB.Post;

        Result.Code := Result_SuccessCode;
      end;
    finally
      RRTableLeave;
    end;
    Result.MessageStr := GetBridgeFactory.GetErrorString( Result.Code );
  end;
end;

procedure TRnRDM.ClearCancelMsgTable;
begin
  with CancelMsg_DB do
  begin
    Active := False;
    FieldDefs.Clear;

    FieldDefs.Add( 'cancelmsg', ftString, 256 );  // 메시지
    FieldDefs.Add( 'default', ftBoolean );  // 기본값?

    CreateDataSet;
    LogChanges := False;
    Active := True;
  end;
end;

procedure TRnRDM.ClearRoomTable;
begin
  with Room_DB do
  begin
    Active := False;
    FieldDefs.Clear;
    IndexDefs.Clear;

    FieldDefs.Add( 'roomcode', ftString, 64 );  // 진료실 id
    FieldDefs.Add( 'roomname', ftString, 64 );  // 진료실 이름
    FieldDefs.Add( 'deptcode', ftString, 16 );  // 진료과목 id
    FieldDefs.Add( 'deptname', ftString, 32 );  // 진료실 이름
    FieldDefs.Add( 'doctorcode', ftString, 64 );  // 의사 코드 id
    FieldDefs.Add( 'doctorname', ftString, 32 );  // 의사 이름

    IndexDefs.Add('pkIndex', 'roomcode',[]);

    CreateDataSet;
    LogChanges := False;
    Active := True;
  end;
end;

constructor TRnRDM.Create(AOwner: TComponent);
begin
  inherited;
  FObserver := TRRObserver.Create( nil );
  FRRTableLock := TCriticalSection.Create;
end;

procedure TRnRDM.DataModuleCreate(Sender: TObject);
begin
  MakeTable;
end;

destructor TRnRDM.Destroy;
begin
  RR_DB.Active := False;
  Room_DB.Active := False;

  FreeAndNil( FObserver );
  FreeAndNil( FRRTableLock );

  inherited;
end;

function TRnRDM.FindRR(AFindData: TRnRData): Boolean;
begin
  RRTableEnter;
  try
    RR_DB.First;

    Result := RR_DB.Locate('ChartReceptnResultId1;ChartReceptnResultId2;ChartReceptnResultId3;ChartReceptnResultId4;ChartReceptnResultId5;ChartReceptnResultId6',
                    VarArrayOf ([ AFindData.ChartReceptnResultId.Id1, AFindData.ChartReceptnResultId.Id2, AFindData.ChartReceptnResultId.Id3,
                                  AFindData.ChartReceptnResultId.Id4, AFindData.ChartReceptnResultId.Id5, AFindData.ChartReceptnResultId.Id6]),
                    [loCaseInsensitive]);
  finally
    RRTableLeave;
  end;
end;

function TRnRDM.FindRR2(chartReceptnResultId1: string; chartReceptnResultId2: string; chartReceptnResultId3: string; chartReceptnResultId4: string; chartReceptnResultId5: string; chartReceptnResultId6: string) : Boolean;
begin
  RRTableEnter;
  try
    RR_DB.First;

    Result := RR_DB.Locate('ChartReceptnResultId1;ChartReceptnResultId2;ChartReceptnResultId3;ChartReceptnResultId4;ChartReceptnResultId5;ChartReceptnResultId6',
                    VarArrayOf ([ chartReceptnResultId1, chartReceptnResultId2, chartReceptnResultId3,
                                  chartReceptnResultId4, chartReceptnResultId5, chartReceptnResultId6]),
                    [loCaseInsensitive]);
  finally
    RRTableLeave;
  end;
end;

function TRnRDM.GetFirstRoomInfo(var ARoomInfo: TRoomInfo): Boolean;
// 첫번째 room 정보를 읽어 낸다. 보통 room 정보가 1개일때만 사용해야 한다.
begin
  Result := False;
  Room_DB.First;
  if not Room_DB.Eof then
  begin
    ARoomInfo.RoomCode   := Room_DB.FieldByName( 'roomcode' ).AsString;
    ARoomInfo.RoomName   := Room_DB.FieldByName( 'roomname' ).AsString;
    ARoomInfo.DeptCode   := Room_DB.FieldByName( 'deptcode' ).AsString;
    ARoomInfo.DeptName   := Room_DB.FieldByName( 'deptname' ).AsString;
    ARoomInfo.DoctorCode := Room_DB.FieldByName( 'doctorcode' ).AsString;
    ARoomInfo.DoctorName := Room_DB.FieldByName( 'doctorname' ).AsString;
    Result := True;
  end;
end;

procedure TRnRDM.GetReceptionReservationData(AData: TRnRData);
begin
  AData.ChartReceptnResultId.Id1 := RR_DB.FieldByName('ChartReceptnResultId1').AsString;
  AData.ChartReceptnResultId.Id2 := RR_DB.FieldByName('ChartReceptnResultId2').AsString;
  AData.ChartReceptnResultId.Id3 := RR_DB.FieldByName('ChartReceptnResultId3').AsString;
  AData.ChartReceptnResultId.Id4 := RR_DB.FieldByName('ChartReceptnResultId4').AsString;
  AData.ChartReceptnResultId.Id5 := RR_DB.FieldByName('ChartReceptnResultId5').AsString;
  AData.ChartReceptnResultId.Id6 := RR_DB.FieldByName('ChartReceptnResultId6').AsString;

  AData.DataType := TRnRType( RR_DB.FieldByName( 'datatype' ).AsInteger );  // 유형  접수/예약
  AData.Inflow := TRnRInDevice( RR_DB.FieldByName( 'devicetype' ).AsInteger );  // 유입 매체  tablet, bridge, app
  AData.Status := TRnRDataStatus( RR_DB.FieldByName( 'status' ).AsInteger ); // data 상태,  요청/확정/완료

  AData.PatientChartID := RR_DB.FieldByName('chartid').AsString; // 환자 이름
  AData.PatientName := RR_DB.FieldByName('patientname').AsString; // 환자 이름
  AData.PatientID := RR_DB.FieldByName('patientid').AsString; // 환자ID

  AData.BirthDay := RR_DB.FieldByName('birthday').AsString;  // 생년월일, yyyy-mm-dd
  AData.DispBirthDay := DisplayBirthDay2( AData.BirthDay );

  AData.Registration_number := RR_DB.FieldByName('registration_number').AsString;  // 주민등록 번호 xxxxxxxxxxxxx => 13자리, 외국인/여권 번호???
  AData.DispRegistration_number := DisplayRegistrationNumber( AData.Registration_number );

  AData.Gender := TRnRGenderType( RR_DB.FieldByName( 'gender' ).AsInteger ); // 성별
  AData.CellPhone := RR_DB.FieldByName( 'cellphone' ).AsString;

  AData.RegisterDT := RR_DB.FieldByName( 'receptiondttm' ).AsDateTime; // 등록 시간, DB에 등록된 시간
  AData.VisitDT := RR_DB.FieldByName( 'reservedttm' ).AsDateTime; // 방문 시간(접수/예약)
  AData.hsptlreceptndttm := RR_DB.FieldByName( 'hsptlreceptndttm' ).AsDateTime;
  AData.CancelDT := RR_DB.FieldByName( 'canceldttm' ).AsDateTime;

  AData.InBoundPath := RR_DB.FieldByName('inboundpath').AsString; // 내원 목적
  AData.Addr := RR_DB.FieldByName('addr').AsString; // 주소
  AData.AddrDetail := RR_DB.FieldByName('addrdetail').AsString; // 상세 주소
  AData.zip := RR_DB.FieldByName('zip').AsString; // 우편 번호

  AData.Symptom := RR_DB.FieldByName('symptom').AsString;

  AData.RoomInfo.RoomCode := RR_DB.FieldByName('roomcode').AsString; // roomid
  AData.RoomInfo.RoomName := RR_DB.FieldByName('roomname').AsString; // roomname
  AData.RoomInfo.DeptCode := RR_DB.FieldByName('deptcode').AsString; //
  AData.RoomInfo.DeptName := RR_DB.FieldByName('deptname').AsString; //
  AData.RoomInfo.DoctorCode := RR_DB.FieldByName('doctorcode').AsString; //
  AData.RoomInfo.DoctorName := RR_DB.FieldByName('doctorname').AsString; //

  AData.Memo := RR_DB.FieldByName('memo').AsString; // memo
  AData.isFirst := RR_DB.FieldByName('isfirst').AsBoolean; // 초/재진 구분, true:초진 false:재진
  AData.CanceledMessage := RR_DB.FieldByName('canceledmessage').AsString; // 거부 메시지
end;

function TRnRDM.GetRoomFilterButtonVisible: Boolean;
begin
  Result := Room_DB.RecordCount > 1;
end;

procedure TRnRDM.MakeTable;
begin
  RestCallDM.ClearLastChangeDttm;

  with RR_DB do
  begin
    Active := False;
    FieldDefs.Clear;
    IndexDefs.Clear;

    FieldDefs.Add( 'ChartReceptnResultId1', ftString, 48 );
    FieldDefs.Add( 'ChartReceptnResultId2', ftString, 48 );
    FieldDefs.Add( 'ChartReceptnResultId3', ftString, 48 );
    FieldDefs.Add( 'ChartReceptnResultId4', ftString, 48 );
    FieldDefs.Add( 'ChartReceptnResultId5', ftString, 48 );
    FieldDefs.Add( 'ChartReceptnResultId6', ftString, 48 );

    FieldDefs.Add( 'chartid', ftString, 64 );
    FieldDefs.Add( 'patientname', ftString, 128 );
    FieldDefs.Add( 'patientid', ftString, 64 );
    FieldDefs.Add( 'gdid', ftString, 200 );

    FieldDefs.Add( 'datatype', ftInteger );  // 유형  접수 C/예약 S    , ReceptnResveType

    FieldDefs.Add( 'cellphone', ftString, 128 );
    FieldDefs.Add( 'registration_number', ftString, 30 );  // 주민등록 번호 xxxxxxxxxxxxx => 13자리, 외국인 번호가 있을 수 있을까?
    FieldDefs.Add( 'birthday', ftString, 10 );  // 생년월일, yyyy-mm-dd
    FieldDefs.Add( 'gender', ftInteger );  // 성별,  성별 (남:1/3/5/7/9, 여:2/4/6/8/0)
    FieldDefs.Add( 'addr', ftString, 128 );  // 주소
    FieldDefs.Add( 'addrdetail', ftString, 128);  // 상세 주소
    FieldDefs.Add( 'zip', ftString, 6 );  // 우편 번호
    FieldDefs.Add( 'memo', ftMemo, 256 );  // 메모

    FieldDefs.Add( 'roomcode', ftString, 64 );  // 진료실 id
    FieldDefs.Add( 'roomname', ftString, 64 );  // 진료실 이름
    FieldDefs.Add( 'deptcode', ftString, 16 );  // 진료과목 id
    FieldDefs.Add( 'deptname', ftString, 32 );  // 진료실 이름
    FieldDefs.Add( 'doctorcode', ftString, 64 );  // 의사 코드 id
    FieldDefs.Add( 'doctorname', ftString, 32 );  // 의사 이름

    FieldDefs.Add( 'devicetype', ftInteger );  // 유입 매체  tablet, web, mobile  Tablet/App여부 , T, B, A
    FieldDefs.Add( 'inboundpath', ftString, 32 );  // 내원 경로
    //FieldDefs.Add( 'symptom', ftString, 128 );  // 내원 목적
    FieldDefs.Add( 'symptom', ftMemo, 128 );  // 내원 목적
    FieldDefs.Add( 'status', ftInteger );  // data 상태,  ...
    FieldDefs.Add( 'isfirst', ftBoolean );  // 초진, 재진 구분  true이면 초진, false이면 재진

    FieldDefs.Add( 'canceledmessage', ftString, 256 );  // 취소 메시지

    FieldDefs.Add( 'lastchangedttm', ftDateTime );  // 마지막 수정 일시
    FieldDefs.Add( 'receptiondttm', ftDateTime );  // 접수/예약 일시
    FieldDefs.Add( 'reservedttm', ftDateTime );  // 예약방문 일시, 접수 data일 경우 reservedttm = receptiondttm
    FieldDefs.Add( 'hsptlreceptndttm', ftDateTime );  // 접수 확정 일시
    FieldDefs.Add( 'canceldttm', ftDateTime );  // 취소 일시

    IndexDefs.Add('pkIndex', 'ChartReceptnResultId1;ChartReceptnResultId2;ChartReceptnResultId3;ChartReceptnResultId4;ChartReceptnResultId5;ChartReceptnResultId6',[]);

    IndexDefs.Add('receptionIndex', 'receptiondttm',[]);
    IndexDefs.Add('receptionIndexdesc', 'receptiondttm',[ixDescending]);

    IndexDefs.Add('visitIndex', 'reservedttm',[]);
    IndexDefs.Add('visitIndexdesc', 'reservedttm',[ixDescending]);

    IndexDefs.Add('nameIndex', 'patientname',[]);
    IndexDefs.Add('nameIndexdesc', 'patientname',[ixDescending]);

    IndexDefs.Add('roomIndex', 'roomname',[]);
    IndexDefs.Add('roomIndexdesc', 'roomname',[ixDescending]);

    IndexName := 'visitIndex';

    CreateDataSet;
    LogChanges := False;
    Active := True;
  end;

  ClearRoomTable;

  ClearCancelMsgTable;
end;

procedure TRnRDM.PackCancelMsgTable(AEvent303 : TBridgeResponse_303);
var
  i : Integer;
  def : Boolean;
begin
  ClearCancelMsgTable;
  def := False;

  for i := 0 to AEvent303.CancelMessageListCount -1 do
  begin
    with AEvent303.CancelMessageList[ i ] do
    begin
      CancelMsg_DB.Append;
      CancelMsg_DB.FieldByName( 'cancelmsg' ).AsString := MessageStr;

      if not def then
        def := isDefault;
      CancelMsg_DB.FieldByName( 'default' ).AsBoolean := def;
      CancelMsg_DB.Post;
    end;
  end;
end;

function TRnRDM.PackReceptionReservationList(
  AEvent401: TBridgeResponse_401; var ACount, AFlashCount : Integer): TDateTime;
var
  i : Integer;
  ds : TRnRDataStatus;
  Event401Item : TReceptionReservationListItem;
begin
  Result := 0;

  RRTableEnter;
  try
    RR_DB.IndexName := 'pkIndex';
    for i := 0 to AEvent401.ReceptionReservationCount -1 do
    begin
      Event401Item := AEvent401.ReceptionReservationLists[ i ];
      with Event401Item do
      begin
        if Result < LastChangeDttm then
          Result := LastChangeDttm;
        Inc( ACount );

        if RR_DB.Locate('ChartReceptnResultId1;ChartReceptnResultId2;ChartReceptnResultId3;ChartReceptnResultId4;ChartReceptnResultId5;ChartReceptnResultId6',
                            VarArrayOf ([ chartReceptnResultId.Id1,chartReceptnResultId.Id2,chartReceptnResultId.Id3,chartReceptnResultId.Id4,chartReceptnResultId.Id5,chartReceptnResultId.Id6]),
                            [loCaseInsensitive]) then
          RR_DB.edit // 찾았다. data를 수정 한다.
        else
          RR_DB.Append; // 못찾았다. data를 추가 한다.

        RR_DB.FieldByName( 'ChartReceptnResultId1' ).AsString := chartReceptnResultId.Id1; // 굿닥에서 관리하는 접수 id
        RR_DB.FieldByName( 'ChartReceptnResultId2' ).AsString := chartReceptnResultId.Id2; // 굿닥에서 관리하는 접수 id
        RR_DB.FieldByName( 'ChartReceptnResultId3' ).AsString := chartReceptnResultId.Id3; // 굿닥에서 관리하는 접수 id
        RR_DB.FieldByName( 'ChartReceptnResultId4' ).AsString := chartReceptnResultId.Id4; // 굿닥에서 관리하는 접수 id
        RR_DB.FieldByName( 'ChartReceptnResultId5' ).AsString := chartReceptnResultId.Id5; // 굿닥에서 관리하는 접수 id
        RR_DB.FieldByName( 'ChartReceptnResultId6' ).AsString := chartReceptnResultId.Id6; // 굿닥에서 관리하는 접수 id

        RR_DB.FieldByName( 'chartid' ).AsString := PatntChartId; // 환자 차트 id
        RR_DB.FieldByName( 'patientname' ).AsString := PatntName; // 환자 이름
        RR_DB.FieldByName( 'patientid' ).AsString := PatntId; // V4. 환자ID

        RR_DB.FieldByName( 'datatype' ).AsInteger := integer( TRRDataTypeConvert.DataType2RnRType( receptnResveType ) ); // 유형  접수 C/예약 S

        RR_DB.FieldByName( 'cellphone' ).AsString := Cellphone; // 전화 번호
        RR_DB.FieldByName( 'registration_number' ).AsString := RegNum; // 주민등록 번호 xxxxxxxxxxxxx => 13자리
        RR_DB.FieldByName( 'birthday' ).AsString := Birthdy; // 생년월일, yyyymmdd

        RR_DB.FieldByName( 'gender' ).AsInteger := Ord( TRRDataTypeConvert.GenderType2RnRGender( Sexdstn ) ); // 성별,  성별 (남:1/3/5/7/9, 여:2/4/6/8/0)

        RR_DB.FieldByName( 'addr' ).AsString := Addr; // 주소
        RR_DB.FieldByName( 'addrdetail' ).AsString := AddrDetail; // 상세 주소
        RR_DB.FieldByName( 'zip' ).AsString := zip; // 우편 번호

        RR_DB.FieldByName( 'memo' ).AsString := memo; // 메모
        RR_DB.FieldByName( 'isfirst' ).AsBoolean := isFirst; // 초/재진 구분, true:초진 false:재진

        RR_DB.FieldByName( 'roomcode' ).AsString := RoomInfo.RoomCode;
        RR_DB.FieldByName( 'roomname' ).AsString := RoomInfo.RoomName;
        RR_DB.FieldByName( 'deptcode' ).AsString := RoomInfo.DeptCode;
        RR_DB.FieldByName( 'deptname' ).AsString := RoomInfo.DeptName;
        RR_DB.FieldByName( 'doctorcode' ).AsString := RoomInfo.DoctorCode;
        RR_DB.FieldByName( 'doctorname' ).AsString := RoomInfo.DoctorName;
        RR_DB.FieldByName('devicetype').AsInteger :=  Ord( TRRDataTypeConvert.InDevice2RnRInDevice( DeviceType ) ); // 유입 매체  tablet, web, mobile  Tablet/App여부
        RR_DB.FieldByName('inboundpath').AsString := InboundPath; // 내원 경로
        RR_DB.FieldByName('symptom').AsString := Symptoms; // 내원 목적

        ds := TRRDataTypeConvert.DataStatus2RnRDataStatus(Status);
        RR_DB.FieldByName('status').AsInteger := integer( ds ); // data 상태
        RR_DB.FieldByName( 'canceledmessage' ).AsString := CancelMessage;  // 취소 메시지

        if ds in [rrs예약요청, rrs접수요청, rrs본인취소, rrs자동취소] then
          inc( AFlashCount );
  (*  TRnRDataStatus = (
          rrsUnknown, // 알수 없는 상태
          rrs예약요청,      // Status_예약요청 = 'S01';
          rrs예약실패,      // Status_예약실패 = 'S02'; // 예약 요청 data를 예약 완료 전 취소를 하면 실패로 본다.
          rrs예약완료,      // Status_예약완료 = 'S03';
          rrs접수요청,      // Status_접수요청 = 'C01';
          rrs접수실패,      // Status_접수실패 = 'C02'; // 접수 요청 data를 접수 완료 전 취소를 하면 실패로 본다.
          rrs접수완료,      // Status_접수완료 = 'C03';
          rrs진료대기,      // Status_진료대기 = 'C04';
          rrs내원요청,      // Status_내원요청 = 'C05';
          rrs내원확정,      // Status_내원확정 = 'C06';
          rrs진료차례,      // Status_진료차례 = 'C07';
          rrs취소요청,      // Status_취소요청 = 'F01';
          rrs본인취소,      // Status_본인취소 = 'F02';
          rrs병원취소,      // Status_병원취소 = 'F03';
          rrs자동취소,      // Status_자동취소 = 'F04';
          rrs진료완료       // Status_진료완료 = 'F05';
      );  *)


        RR_DB.FieldByName( 'receptiondttm' ).AsDateTime := ReceptionDttm;  // 접수/예약 일시
        if TRRDataTypeConvert.DataType2RnRType( receptnResveType ) = rrReservation then
          RR_DB.FieldByName( 'reservedttm' ).AsDateTime := reserveDttm  // 예약방문 일시
        else
          RR_DB.FieldByName( 'reservedttm' ).AsDateTime := ReceptionDttm; // 접수

        RR_DB.FieldByName( 'lastchangedttm' ).AsDateTime := LastChangeDttm;  // 마지막 수정 일시

        RR_DB.FieldByName( 'hsptlreceptndttm' ).AsDateTime := hsptlReceptnDttm;  // 접수 확정이 되면 해당 field에 data가 설정됨
        RR_DB.FieldByName( 'canceldttm' ).AsDateTime := CancelDttm;  // 취소 시간을 설정 한다.

        RR_DB.Post;
      end;
    end;
  finally
    RRTableLeave;
  end;
end;

procedure TRnRDM.PackRoomTable(AEvent403: TBridgeResponse_403);
var
  i : Integer;
begin
  ClearRoomTable;
  for i := 0 to AEvent403.RoomListCount -1 do
  begin
    with AEvent403.RoomLists[ i ] do
    begin
      Room_DB.Append;
      Room_DB.FieldByName( 'roomcode' ).AsString := RoomCode;
      Room_DB.FieldByName( 'roomname' ).AsString := RoomName;
      Room_DB.FieldByName( 'deptcode' ).AsString := DeptCode;
      Room_DB.FieldByName( 'deptname' ).AsString := DeptName;
      Room_DB.FieldByName( 'doctorcode' ).AsString := DoctorCode;
      Room_DB.FieldByName( 'doctorname' ).AsString := DoctorName;
      Room_DB.Post;
    end;
  end;
end;

procedure TRnRDM.RRTableEnter;
begin
  FRRTableLock.Enter;
  FIsTaskRunning := True;
end;

procedure TRnRDM.RRTableLeave;
begin
  FRRTableLock.Leave;
  FIsTaskRunning := False;
end;

procedure TRnRDM.UpdateRoomInfoRR(AFindData: TRnRData; ARoomInfo: TRoomInfo);
begin
  RRTableEnter;
  try
    if FindRR( AFindData ) then
    begin
      RR_DB.Edit;
      RR_DB.FieldByName( 'roomcode' ).AsString := ARoomInfo.RoomCode;
      RR_DB.FieldByName( 'roomname' ).AsString := ARoomInfo.RoomName;
      RR_DB.FieldByName( 'deptcode' ).AsString := ARoomInfo.DeptCode;
      RR_DB.FieldByName( 'deptname' ).AsString := ARoomInfo.DeptName;
      RR_DB.FieldByName( 'doctorcode' ).AsString := ARoomInfo.DoctorCode;
      RR_DB.FieldByName( 'doctorname' ).AsString := ARoomInfo.DoctorName;
      RR_DB.Post;
    end;
  finally
    RRTableLeave;
  end;
end;

procedure TRnRDM.UpdateStatusRR(AFindData: TRnRData; AStatus: TRnRDataStatus);
begin
  RRTableEnter;
  try
    if FindRR( AFindData ) then
    begin
      RR_DB.Edit;
      RR_DB.FieldByName( 'status' ).AsInteger := ord( AStatus );
      RR_DB.Post;
    end;
  finally
    RRTableLeave;
  end;
end;

procedure TRnRDM.UpdateReserveDttmRR(AFindData: TRnRData; AReserveDateTime: TDateTime);
begin
  RRTableEnter;
  try
    if FindRR( AFindData ) then
    begin
      RR_DB.Edit;
      RR_DB.FieldByName( 'reservedttm' ).AsDateTime := AReserveDateTime;
      RR_DB.Post;
    end;
  finally
    RRTableLeave;
  end;
end;

function TRnRDM.VisitConfirm(
  AVisitConfirmData: TBridgeResponse_110): TBridgeRequest_111;
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
  i : Integer;
  data : TconfirmListItem;
begin
  Result := TBridgeRequest_111( GetBridgeFactory.MakeRequestObj(EventID_내원확인요청결과, AVisitConfirmData.JobID ) );
  if AVisitConfirmData.AnalysisErrorCode <> Result_Success then
  begin
    Result.MessageStr := GetBridgeFactory.GetErrorString( AVisitConfirmData.AnalysisErrorCode );
    exit;
  end;

  RR_DB.IndexName := 'pkIndex';
  Result.MessageStr := '';
  Result.HospitalNo := AVisitConfirmData.HospitalNo;

  // 모두 내원 확정 처리를 한다.
  for i := 0 to AVisitConfirmData.Count -1 do
  begin
    data := AVisitConfirmData.confirmList[ i ];

    ret := 0; // 실패

    RRTableEnter;
    try
      // data 검색
      with data do
      begin
        if not RR_DB.Locate('ChartReceptnResultId1;ChartReceptnResultId2;ChartReceptnResultId3;ChartReceptnResultId4;ChartReceptnResultId5;ChartReceptnResultId6',
                            VarArrayOf ([ chartReceptnResult.Id1, chartReceptnResult.Id2, chartReceptnResult.Id3, chartReceptnResult.Id4, chartReceptnResult.Id5, chartReceptnResult.Id6]),
                            [loCaseInsensitive]) then
        begin // data를 찾았다.
          if receptnResveType = 0 then
          begin // 예약 data 확인
            if RR_DB.FieldByName( 'datatype' ).AsInteger = ord( rrReservation ) then
            begin // 예약 data이다
              if RR_DB.FieldByName('status').AsInteger = integer( rrs예약완료 ) then
              begin
                RR_DB.Edit;
                  RR_DB.FieldByName('status').AsInteger := integer( rrs내원확정 );
                RR_DB.Post;
                ret := 1;
              end;
            end;
          end
          else
          begin // 접수 data 확인
            if receptnResveType = 1 then
            begin // 접수 data 확인
              if RR_DB.FieldByName( 'datatype' ).AsInteger = ord( rrReception ) then
              begin // 예약 data이다
                if RR_DB.FieldByName('status').AsInteger = integer( rrs내원요청 ) then
                begin
                  RR_DB.Edit;
                    RR_DB.FieldByName('status').AsInteger := integer( rrs내원확정 );
                  RR_DB.Post;
                  ret := 1;
                end;
              end;
            end;
          end;
        end;
      end; // with
    finally
      RRTableLeave;
    end;

    // 처리 결과 등록
    ConfirmResult( Result, data, ret );
  end;  // for문
end;

procedure TRnRDM.UpdateReceptionReservation( AEvent407: TBridgeResponse_407 );
var
  ds : TRnRDataStatus;
begin
  RRTableEnter;
  try
    with AEvent407.ReceptionReservationItem do
    begin
      if FindRR2( chartReceptnResultId.Id1, chartReceptnResultId.Id2, chartReceptnResultId.Id3, chartReceptnResultId.Id4, chartReceptnResultId.Id5, chartReceptnResultId.Id6 ) then
      begin
        RR_DB.Edit;
      end
      else
      begin
        RR_DB.Append;
      end;

      RR_DB.FieldByName( 'ChartReceptnResultId1' ).AsString := chartReceptnResultId.Id1; // 굿닥에서 관리하는 접수 id
      RR_DB.FieldByName( 'ChartReceptnResultId2' ).AsString := chartReceptnResultId.Id2; // 굿닥에서 관리하는 접수 id
      RR_DB.FieldByName( 'ChartReceptnResultId3' ).AsString := chartReceptnResultId.Id3; // 굿닥에서 관리하는 접수 id
      RR_DB.FieldByName( 'ChartReceptnResultId4' ).AsString := chartReceptnResultId.Id4; // 굿닥에서 관리하는 접수 id
      RR_DB.FieldByName( 'ChartReceptnResultId5' ).AsString := chartReceptnResultId.Id5; // 굿닥에서 관리하는 접수 id
      RR_DB.FieldByName( 'ChartReceptnResultId6' ).AsString := chartReceptnResultId.Id6; // 굿닥에서 관리하는 접수 id

      RR_DB.FieldByName( 'chartid' ).AsString := PatntChartId; // 환자 차트 id
      RR_DB.FieldByName( 'patientname' ).AsString := PatntName; // 환자 이름
      RR_DB.FieldByName( 'patientid' ).AsString := PatntId; // V4. 환자ID

      RR_DB.FieldByName( 'datatype' ).AsInteger := integer( TRRDataTypeConvert.DataType2RnRType( receptnResveType ) ); // 유형  접수 C/예약 S

      RR_DB.FieldByName( 'cellphone' ).AsString := Cellphone; // 전화 번호
      RR_DB.FieldByName( 'registration_number' ).AsString := RegNum; // 주민등록 번호 xxxxxxxxxxxxx => 13자리
      RR_DB.FieldByName( 'birthday' ).AsString := Birthdy; // 생년월일, yyyymmdd

      RR_DB.FieldByName( 'gender' ).AsInteger := Ord( TRRDataTypeConvert.GenderType2RnRGender( Sexdstn ) ); // 성별,  성별 (남:1/3/5/7/9, 여:2/4/6/8/0)

      RR_DB.FieldByName( 'addr' ).AsString := Addr; // 주소
      RR_DB.FieldByName( 'addrdetail' ).AsString := AddrDetail; // 상세 주소
      RR_DB.FieldByName( 'zip' ).AsString := zip; // 우편 번호

      RR_DB.FieldByName( 'memo' ).AsString := memo; // 메모
      RR_DB.FieldByName( 'isfirst' ).AsBoolean := isFirst; // 초/재진 구분, true:초진 false:재진

      RR_DB.FieldByName( 'roomcode' ).AsString := RoomInfo.RoomCode;
      RR_DB.FieldByName( 'roomname' ).AsString := RoomInfo.RoomName;
      RR_DB.FieldByName( 'deptcode' ).AsString := RoomInfo.DeptCode;
      RR_DB.FieldByName( 'deptname' ).AsString := RoomInfo.DeptName;
      RR_DB.FieldByName( 'doctorcode' ).AsString := RoomInfo.DoctorCode;
      RR_DB.FieldByName( 'doctorname' ).AsString := RoomInfo.DoctorName;

      //RR_DB.FieldByName('devicetype').AsInteger :=  Ord( TRRDataTypeConvert.InDevice2RnRInDevice( DeviceType ) ); // 유입 매체  tablet, web, mobile  Tablet/App여부
      RR_DB.FieldByName('devicetype').AsInteger :=  Ord( TRRDataTypeConvert.InDevice2RnRInDevice( DeviceType ) );
      RR_DB.FieldByName('inboundpath').AsString := InboundPath; // 내원 경로
      RR_DB.FieldByName('symptom').AsString := Symptoms; // 내원 목적

      ds := TRRDataTypeConvert.DataStatus2RnRDataStatus(Status);
      RR_DB.FieldByName('status').AsInteger := integer( ds ); // data 상태
      RR_DB.FieldByName( 'canceledmessage' ).AsString := CancelMessage;  // 취소 메시지

      RR_DB.FieldByName( 'receptiondttm' ).AsDateTime := ReceptionDttm;  // 접수/예약 일시
      if TRRDataTypeConvert.DataType2RnRType( receptnResveType ) = rrReservation then
        RR_DB.FieldByName( 'reservedttm' ).AsDateTime := reserveDttm  // 예약방문 일시
      else
        RR_DB.FieldByName( 'reservedttm' ).AsDateTime := ReceptionDttm; // 접수

      RR_DB.FieldByName( 'lastchangedttm' ).AsDateTime := LastChangeDttm;  // 마지막 수정 일시

      RR_DB.FieldByName( 'hsptlreceptndttm' ).AsDateTime := hsptlReceptnDttm;  // 접수 확정이 되면 해당 field에 data가 설정됨
      RR_DB.FieldByName( 'canceldttm' ).AsDateTime := CancelDttm;  // 취소 시간을 설정 한다.

      RR_DB.Post;
    end;
  finally
    RRTableLeave;
  end;
end;

end.
