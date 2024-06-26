unit BridgeWrapperUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, SyncObjs,
  BridgeCommUnit, RnRData;

type
  TBridgeWrapperDM = class(TForm)
  private
    { Private declarations }
    FHospitalNO : string;
    FChartCode : integer;
    FLastResultCode: Integer;
    FLastResultCodeMessage: string;
    FRestLock: TCriticalSection;

    procedure SetLastResultCode( AResultCode : Integer );
    function GetBridgeActivate: Boolean;
  public
    { Public declarations }
    constructor Create( AOwner : TComponent ); override;
    destructor Destroy; override;

    function Init( AHospitalNo : string; AChartCode : Integer ) : Boolean; // bridge를 초기화 한다, false이면 실패이다.
    procedure InitInfo( AHospitalNo : string; AChartCode : Integer ); // hospitalno, chartcode를 설정 한다.

    // 사용자 인증
    function Login( AHospitalID : cardinal; AID, APW : string ) : Integer;
    // 상태 변경
    function ChangeStatus( AData : TRnRData; AChangeStatus : TRnRDataStatus ) : TBridgeResponse_109;
    // 진료실 변경
    function ChangeRoom(AData : TRnRData; ANewRoomInfo : TRoomInfo) : TBridgeResponse_107;
    // 메모정보 변경
    function ChangeMemo(AData : TRnRData; ANewMemo : string) : TBridgeResponse_109;
    // 접수 취소
   // function CancelReceptionReservation(AData : TRnRData; ACancelMessage : string) : TBridgeResponse_103;
    function CancelReceptionReservation(AData : TRnRData; AChangeStatus : TRnRDataStatus) : TBridgeResponse_103;

    // 환자 이름 변경
    function ChangePatientName( APatientId : string; AoldName, AnewName: string; AoldPhone, AnewPhone : string ) : TBridgeResponse_405;
    // 환자 전화번호 변경
    function ChangePatientPhone( APatientId : string; AoldName, AnewName: string; AoldPhone, AnewPhone : string ) : TBridgeResponse_405;
    // 예약요청시간 변경
    function ChangeReservationTime(AData : TRnRData; ATime: TDateTime) : TBridgeResponse_207;

    // 주민번호 전체 읽어오기
    function GetFullRegistrationNumber(AData : TRnRData) : TBridgeResponse_411;

    // 중계
    function RequestResponse( AJsonStr : string; APolling : Boolean = False ) : string;
    function RequestResponse400( AJsonStr : string; APolling : Boolean = False ) : string;
    function PutResponse( AJsonStr : string ) : integer;

    property BridgeActivate : Boolean read GetBridgeActivate;
    property LastResultCode : Integer read FLastResultCode;
    property LastResultCodeMessage : string read FLastResultCodeMessage;
  end;

var
  BridgeWrapperDM: TBridgeWrapperDM;

implementation
uses
  GDLog,
  GDBridge;

{$R *.dfm}

{ TBridgeWrapperDM }

function TBridgeWrapperDM.ChangeStatus(AData: TRnRData; AChangeStatus : TRnRDataStatus ): TBridgeResponse_109;
var
  ret : string;
  responsebase : TBridgeResponse;
  event_108 : TBridgeRequest_108;
begin
  event_108 := TBridgeRequest_108( GetBridgeFactory.MakeRequestObj( EventID_대기열상태값변경 ) );
  try
    event_108.HospitalNo := FHospitalNO;
    event_108.ReceptionUpdateDto.chartReceptnResultId.Id1 := AData.ChartReceptnResultId.Id1;
    event_108.ReceptionUpdateDto.chartReceptnResultId.Id2 := AData.ChartReceptnResultId.Id2;
    event_108.ReceptionUpdateDto.chartReceptnResultId.Id3 := AData.ChartReceptnResultId.Id3;
    event_108.ReceptionUpdateDto.chartReceptnResultId.Id4 := AData.ChartReceptnResultId.Id4;
    event_108.ReceptionUpdateDto.chartReceptnResultId.Id5 := AData.ChartReceptnResultId.Id5;
    event_108.ReceptionUpdateDto.chartReceptnResultId.Id6 := AData.ChartReceptnResultId.Id6;

    event_108.ReceptionUpdateDto.PatientChartId := AData.PatientChartID;
    event_108.ReceptionUpdateDto.RoomInfo.RoomCode := AData.RoomInfo.RoomCode;
    event_108.ReceptionUpdateDto.RoomInfo.RoomName := AData.RoomInfo.RoomName;
    event_108.ReceptionUpdateDto.RoomInfo.DeptCode := AData.RoomInfo.DeptCode;
    event_108.ReceptionUpdateDto.RoomInfo.DeptName := AData.RoomInfo.DeptName;
    event_108.ReceptionUpdateDto.RoomInfo.DoctorCode := AData.RoomInfo.DoctorCode;
    event_108.ReceptionUpdateDto.RoomInfo.DoctorName := AData.RoomInfo.DoctorName;
    event_108.ReceptionUpdateDto.Status :=  TRRDataTypeConvert.RnRDataStatus2DataStatus( AChangeStatus );
    event_108.ReceptionUpdateDto.memo := AData.Memo;
    event_108.receptStatusChangeDttm     := now;

    if AChangeStatus = rrs예약완료 then
    begin // 비연동에서는 예약 완료시 추가적인 접수id를 생성 하지 않는다.
      event_108.NewchartReceptnResult.Id1 := '';
      event_108.NewchartReceptnResult.Id2 := '';
      event_108.NewchartReceptnResult.Id3 := '';
      event_108.NewchartReceptnResult.Id4 := '';
      event_108.NewchartReceptnResult.Id5 := '';
      event_108.NewchartReceptnResult.Id6 := '';
    end
    else
    begin
      event_108.NewchartReceptnResult.Id1 := '';
      event_108.NewchartReceptnResult.Id2 := '';
      event_108.NewchartReceptnResult.Id3 := '';
      event_108.NewchartReceptnResult.Id4 := '';
      event_108.NewchartReceptnResult.Id5 := '';
      event_108.NewchartReceptnResult.Id6 := '';
    end;

    ret := RequestResponse( event_108.ToJsonString );
    responsebase := GetBridgeFactory.MakeResponseObj( ret );
    Result := TBridgeResponse_109( responsebase );
  finally
    freeandnil( event_108 );
  end;
end;

constructor TBridgeWrapperDM.Create(AOwner: TComponent);
begin
  inherited;
  FRestLock:= TCriticalSection.Create;
end;

destructor TBridgeWrapperDM.Destroy;
begin
  FreeAndNil( FRestLock );
  inherited;
end;

//function TBridgeWrapperDM.CancelReceptionReservation(AData: TRnRData;
//  ACancelMessage: string): TBridgeResponse_103;

function TBridgeWrapperDM.CancelReceptionReservation(AData: TRnRData;
  AChangeStatus : TRnRDataStatus): TBridgeResponse_103;
var
  ret : string;
  event_102 : TBridgeRequest_102;
  responsebase : TBridgeResponse;
begin
  event_102 := TBridgeRequest_102( GetBridgeFactory.MakeRequestObj( EventID_접수취소 ) );
  try
    event_102.HospitalNo := FHospitalNO;
    event_102.PatientChartID := AData.PatientChartID;
    event_102.chartReceptnResultId.Id1 := AData.ChartReceptnResultId.Id1;
    event_102.chartReceptnResultId.Id2 := AData.ChartReceptnResultId.Id2;
    event_102.chartReceptnResultId.Id3 := AData.ChartReceptnResultId.Id3;
    event_102.chartReceptnResultId.Id4 := AData.ChartReceptnResultId.Id4;
    event_102.chartReceptnResultId.Id5 := AData.ChartReceptnResultId.Id5;
    event_102.chartReceptnResultId.Id6 := AData.ChartReceptnResultId.Id6;
    event_102.RoomInfo.RoomCode     := AData.RoomInfo.RoomCode;
    event_102.RoomInfo.RoomName     := AData.RoomInfo.RoomName;
    event_102.RoomInfo.DeptCode     := AData.RoomInfo.DeptCode;
    event_102.RoomInfo.DeptName     := AData.RoomInfo.DeptName;
    event_102.RoomInfo.DoctorCode   := AData.RoomInfo.DoctorCode;
    event_102.RoomInfo.DoctorName   := AData.RoomInfo.DoctorName;
   // event_102.CancelMessage           := ACancelMessage;
    event_102.receptStatusChangeDttm  := now;

    ret := RequestResponse( event_102.ToJsonString );
    responsebase := GetBridgeFactory.MakeResponseObj( ret );
    Result := TBridgeResponse_103( responsebase );
  finally
    FreeAndNil( event_102 );
  end;
end;

function TBridgeWrapperDM.ChangeMemo(AData: TRnRData;
  ANewMemo: string): TBridgeResponse_109;
// 메모정보 변경
var
  ret : string;
  event_108 : TBridgeRequest_108;
  responsebase : TBridgeResponse;
begin
  event_108 := TBridgeRequest_108( GetBridgeFactory.MakeRequestObj( EventID_대기열상태값변경 ) );
  try
    event_108.HospitalNo := FHospitalNO;
    event_108.ReceptionUpdateDto.chartReceptnResultId.Id1 := AData.ChartReceptnResultId.Id1;
    event_108.ReceptionUpdateDto.chartReceptnResultId.Id2 := AData.ChartReceptnResultId.Id2;
    event_108.ReceptionUpdateDto.chartReceptnResultId.Id3 := AData.ChartReceptnResultId.Id3;
    event_108.ReceptionUpdateDto.chartReceptnResultId.Id4 := AData.ChartReceptnResultId.Id4;
    event_108.ReceptionUpdateDto.chartReceptnResultId.Id5 := AData.ChartReceptnResultId.Id5;
    event_108.ReceptionUpdateDto.chartReceptnResultId.Id6 := AData.ChartReceptnResultId.Id6;
    event_108.ReceptionUpdateDto.memo                     := ANewMemo;

    event_108.ReceptionUpdateDto.PatientChartId := AData.PatientChartID;
    event_108.ReceptionUpdateDto.RoomInfo.RoomCode := AData.RoomInfo.RoomCode;
    event_108.ReceptionUpdateDto.RoomInfo.RoomName := AData.RoomInfo.RoomName;
    event_108.ReceptionUpdateDto.RoomInfo.DeptCode := AData.RoomInfo.DeptCode;
    event_108.ReceptionUpdateDto.RoomInfo.DeptName := AData.RoomInfo.DeptName;
    event_108.ReceptionUpdateDto.RoomInfo.DoctorCode := AData.RoomInfo.DoctorCode;
    event_108.ReceptionUpdateDto.RoomInfo.DoctorName := AData.RoomInfo.DoctorName;
    event_108.ReceptionUpdateDto.Status :=  TRRDataTypeConvert.RnRDataStatus2DataStatus( AData.Status );
    event_108.receptStatusChangeDttm     := now;

    event_108.NewchartReceptnResult.Id1 := '';
    event_108.NewchartReceptnResult.Id2 := '';
    event_108.NewchartReceptnResult.Id3 := '';
    event_108.NewchartReceptnResult.Id4 := '';
    event_108.NewchartReceptnResult.Id5 := '';
    event_108.NewchartReceptnResult.Id6 := '';

    ret := RequestResponse( event_108.ToJsonString );
    responsebase := GetBridgeFactory.MakeResponseObj( ret );
    Result := TBridgeResponse_109( responsebase );
  finally
    FreeAndNil( event_108 );
  end;
end;

function TBridgeWrapperDM.ChangePatientName(APatientId : string; AoldName,
  AnewName: string; AoldPhone, AnewPhone : string): TBridgeResponse_405;
var
  ret : string;
  event_404 : TBridgeRequest_404;
  responsebase : TBridgeResponse;
begin
  event_404 := TBridgeRequest_404( GetBridgeFactory.MakeRequestObj( EventID_환자정보수정요청 ) );
  try
    event_404.HospitalNo := FHospitalNO;
    event_404.patntChartId := ''; // V4. deprecated.
    event_404.patntId := APatientId; // V4
    event_404.oldName := AoldName;
    event_404.newName := AnewName;
    event_404.oldPhone := AoldPhone;
    event_404.newPhone := AnewPhone;

    ret := RequestResponse( event_404.ToJsonString );
    responsebase := GetBridgeFactory.MakeResponseObj( ret );
    Result := TBridgeResponse_405( responsebase );
  finally
    FreeAndNil( event_404 );
  end;
end;

function TBridgeWrapperDM.ChangePatientPhone(APatientId, AoldName, AnewName, AoldPhone,
  AnewPhone: string): TBridgeResponse_405;
var
  ret : string;
  event_404 : TBridgeRequest_404;
  responsebase : TBridgeResponse;
begin
  event_404 := TBridgeRequest_404( GetBridgeFactory.MakeRequestObj( EventID_환자정보수정요청 ) );
  try
    event_404.HospitalNo := FHospitalNO;
    event_404.patntChartId := ''; // V4. deprecated.
    event_404.patntId := APatientId; // V4
    event_404.oldName := AoldName;
    event_404.newName := AnewName;
    event_404.oldPhone := AoldPhone;
    event_404.newPhone := AnewPhone;

    ret := RequestResponse( event_404.ToJsonString );
    responsebase := GetBridgeFactory.MakeResponseObj( ret );
    Result := TBridgeResponse_405( responsebase );
  finally
    FreeAndNil( event_404 );
  end;
end;

function TBridgeWrapperDM.ChangeRoom(AData: TRnRData;
  ANewRoomInfo: TRoomInfo): TBridgeResponse_107;
var
  ret : string;
  event_106 : TBridgeRequest_106;
  responsebase : TBridgeResponse;
begin
  event_106 := TBridgeRequest_106( GetBridgeFactory.MakeRequestObj( EventID_대기열변경 ) );
  try
    event_106.HospitalNo := FHospitalNO;
    event_106.ReceptionUpdateDto.chartReceptnResultId.Id1 := AData.ChartReceptnResultId.Id1;
    event_106.ReceptionUpdateDto.chartReceptnResultId.Id2 := AData.ChartReceptnResultId.Id2;
    event_106.ReceptionUpdateDto.chartReceptnResultId.Id3 := AData.ChartReceptnResultId.Id3;
    event_106.ReceptionUpdateDto.chartReceptnResultId.Id4 := AData.ChartReceptnResultId.Id4;
    event_106.ReceptionUpdateDto.chartReceptnResultId.Id5 := AData.ChartReceptnResultId.Id5;
    event_106.ReceptionUpdateDto.chartReceptnResultId.Id6 := AData.ChartReceptnResultId.Id6;

    event_106.ReceptionUpdateDto.PatientChartId := AData.PatientChartID;
    event_106.ReceptionUpdateDto.RoomInfo.RoomCode := ANewRoomInfo.RoomCode;
    event_106.ReceptionUpdateDto.RoomInfo.RoomName := ANewRoomInfo.RoomName;
    event_106.ReceptionUpdateDto.RoomInfo.DeptCode := ANewRoomInfo.DeptCode;
    event_106.ReceptionUpdateDto.RoomInfo.DeptName := ANewRoomInfo.DeptName;
    event_106.ReceptionUpdateDto.RoomInfo.DoctorCode := ANewRoomInfo.DoctorCode;
    event_106.ReceptionUpdateDto.RoomInfo.DoctorName := ANewRoomInfo.DoctorName;
    event_106.ReceptionUpdateDto.Status := TRRDataTypeConvert.RnRDataStatus2DataStatus( AData.Status );
    event_106.RoomChangeDttm := now;

    ret := RequestResponse( event_106.ToJsonString );
    responsebase := GetBridgeFactory.MakeResponseObj( ret );
    Result := TBridgeResponse_107( responsebase );
  finally
    FreeAndNil( event_106 );
  end;
end;

function TBridgeWrapperDM.GetBridgeActivate: Boolean;
begin
  Result := GetBridge.Activate;
end;

function TBridgeWrapperDM.Init( AHospitalNo : string; AChartCode : Integer ): Boolean;
var
  ret : Integer;
begin
  ret := GetBridge.init(AHospitalNo, AChartCode);
  Result := ret = Result_Success;
  if Result then
    InitInfo(AHospitalNo, AChartCode);

  SetLastResultCode( ret );
  AddLog(doRunStatusLog, Format('Bridge.init(%s,%d) : Result=%d(%s)',[FHospitalNO, FChartCode, FLastResultCode, FLastResultCodeMessage]) );
end;

procedure TBridgeWrapperDM.InitInfo(AHospitalNo: string;
  AChartCode: Integer);
begin
  FHospitalNO := AHospitalNo;
  FChartCode := AChartCode;
  AddLog(doRunStatusLog, Format('Bridge.initinfo(%s,%d)',[FHospitalNO, FChartCode]) );
end;

function TBridgeWrapperDM.Login( AHospitalID : cardinal; AID, APW: string): Integer;
begin
  Result := GetBridge.login(AHospitalID, AID, APW);
  SetLastResultCode(Result);
end;

function TBridgeWrapperDM.PutResponse(AJsonStr: string): integer;
begin
  FRestLock.Enter;
  try
    Result := GetBridge.PutResponse(AJsonStr);
  finally
    FRestLock.Leave;
  end;
end;

function TBridgeWrapperDM.RequestResponse(AJsonStr: string;
  APolling: Boolean): string;
begin
  while not FRestLock.TryEnter do
  begin
    AddLog(doWarningLog, 'RequestResponse Try Enter!');
    Sleep(100);
  end;

  try
    Result := GetBridge.RequestResponse(AJsonStr, APolling);
  finally
    FRestLock.Leave;
  end;
end;

function TBridgeWrapperDM.RequestResponse400(AJsonStr: string;
  APolling: Boolean): string;
begin
  Result := '';

  while not FRestLock.TryEnter do
  begin
    AddLog(doWarningLog, 'RequestResponse400 Try Enter!');
    Sleep(100);
  end;

  try
    Result := GetBridge.RequestResponse(AJsonStr, APolling);
  finally
    FRestLock.Leave;
  end;
end;

procedure TBridgeWrapperDM.SetLastResultCode(AResultCode: Integer);
begin
  FLastResultCode := AResultCode;
  if FLastResultCode <> Result_Success  then
    FLastResultCodeMessage := GetBridge.GetErrorMsg( FLastResultCode )
  else
    FLastResultCodeMessage := '';
end;

function TBridgeWrapperDM.ChangeReservationTime(AData: TRnRData; ATime: TDateTime) : TBridgeResponse_207;
var
  ret : string;
  event_206 : TBridgeRequest_206;
  responsebase : TBridgeResponse;
begin
  event_206 := TBridgeRequest_206( GetBridgeFactory.MakeRequestObj( EventID_예약요청시간변경 ) );
  try
    event_206.hospitalNo := FHospitalNO;
    event_206.chartReceptnResultId.Id1 := AData.ChartReceptnResultId.Id1;
    event_206.chartReceptnResultId.Id2 := AData.ChartReceptnResultId.Id2;
    event_206.chartReceptnResultId.Id3 := AData.ChartReceptnResultId.Id3;
    event_206.chartReceptnResultId.Id4 := AData.ChartReceptnResultId.Id4;
    event_206.chartReceptnResultId.Id5 := AData.ChartReceptnResultId.Id5;
    event_206.chartReceptnResultId.Id6 := AData.ChartReceptnResultId.Id6;
    event_206.reserveDttm := ATime;

    ret := RequestResponse( event_206.ToJsonString );
    responsebase := GetBridgeFactory.MakeResponseObj( ret );
    Result := TBridgeResponse_207( responsebase );
  finally
    FreeAndNil( event_206 );
  end;
end;

function TBridgeWrapperDM.GetFullRegistrationNumber(AData: TRnRData) : TBridgeResponse_411;
var
  ret : string;
  event_410 : TBridgeRequest_410;
  responsebase : TBridgeResponse;
begin
  event_410 := TBridgeRequest_410( GetBridgeFactory.MakeRequestObj( EventID_환자주민번호요청 ) );
  try
    event_410.patntId := AData.PatientID;

    ret := RequestResponse( event_410.ToJsonString );
    responsebase := GetBridgeFactory.MakeResponseObj( ret );
    Result := TBridgeResponse_411( responsebase );
  finally
    FreeAndNil( event_410 );
  end;

end;

end.
