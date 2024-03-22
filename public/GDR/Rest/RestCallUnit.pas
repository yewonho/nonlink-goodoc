unit RestCallUnit;

interface

uses
  System.SysUtils, System.Classes,
  RRObserverUnit;

type
  TRestCallDM = class(TDataModule)
  private
    { Private declarations }
    FDay : TDate;
    FDayLastChangeDttm : TDateTime;
    FMonth : TDate;
    FMonthLastChangeDttm : TDateTime;

    FObserver : TRRObserver;
  public
    { 당일 data처리  Public declarations }
    // 당일 data를 처음부터 읽어내기 위해 last change dttm값을 0으로 만들어 준다.
    procedure initLastChangeDttm;
    // 지정된 날자의 data를 요청해서 받아 온다.
    function GetRRData( ADate : TDate; AReceptionReservationDataType : string; var AFlashCount : Integer ) : Integer;
  public
    { 월 data처리  Public declarations }
    // 월 data를 처음부터 읽어내기 위해 last change dttm값을 0으로 만들어 준다.
    procedure initMonthLastChangeDttm;
    // 지정된 월의 data를 요청해서 받아 온다. 검색 data는 예약 data를 받아 오게 한다.
    function GetRRMonthData( AMonthDate : TDate; AReceptionReservationDataType : string; var AFlashCount : Integer ) : Integer;
  public
    { Public declarations }
    constructor Create( AOwner : TComponent ); override;
    destructor Destroy; override;

    procedure ClearLastChangeDttm;
  end;

var
  RestCallDM: TRestCallDM;

const
  MaxRRListCount = 50; // 한번에 읽을 목록수

implementation
uses
  System.DateUtils, UtilsUnit,
  BridgeWrapperUnit, BridgeCommUnit, GDJson,
  GDLog, EventIDConst, RREnvUnit, RnRDMUnit;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TRestCallDM }

constructor TRestCallDM.Create(AOwner: TComponent);
begin
  inherited;
  ClearLastChangeDttm;

  FObserver := TRRObserver.Create( nil );
  FObserver.OnBeforeAction := nil;
  FObserver.OnAfterAction := nil;
end;

destructor TRestCallDM.Destroy;
begin
  FreeAndNil( FObserver );

  inherited;
end;

function TRestCallDM.GetRRData(ADate: TDate;
  AReceptionReservationDataType: string; var AFlashCount : Integer): Integer;
var
  sendlog, receivelog : string;

  function sendEvent400( AOffset : Integer ) : TBridgeResponse;
  var
    sdt, edt : TDateTime;
    event401 : string;
    event_400 : TBridgeRequest_400;
  begin
    event_400 := TBridgeRequest_400( GetBridgeFactory.MakeRequestObj( EventID_접수예약목록요청 ) );
    try
      event_400.HospitalNo := GetRREnv.HospitalID;
      // 당일 data만
      CalcRangeDay(ADate, sdt, edt);
      event_400.ReceptnResveType := AReceptionReservationDataType; // 접수+예약 목록 요청

      //event_400.ReceptnResveType := RRType_ALL; // 접수+예약 목록 요청
      //event_400.ReceptnResveType := RRType_Reservation; // 예약 목록 요청
      //event_400.ReceptnResveType := RRType_Reception; // 접수 목록 요청

      event_400.StartDttm := sdt;
      event_400.EndDttm := edt;

      if FDayLastChangeDttm = 0 then
        event_400.LastChangeDttm := 0 // 최종 update날자 등록
      else
        event_400.LastChangeDttm := FDayLastChangeDttm;
      event_400.Limit := MaxRRListCount;
      event_400.Offset := AOffset;

      sendlog := AddLogStr( 'PG(RequestResponse) -> ' + event_400.ToJsonString );
      // debug level이 dovaluelog이하이면 polling log를 찍지 않는다. true이면 polling log이다.
      event401 := BridgeWrapperDM.RequestResponse400(event_400.ToJsonString, True );
      receivelog := AddLogStr( 'PGR(RequestResponse) <- ' + event401 );
      Result := GetBridgeFactory.MakeResponseObj( event401 );
    finally
      FreeAndNil( event_400 );
    end;
  end;

var
  isEof : Boolean;
  offset : Integer;
  changedt, newchangedt : TDateTime;
  baseresponse : TBridgeResponse;
  event_401 : TBridgeResponse_401;
begin
  Result := 0;
  AFlashCount := 0;
  offset := 0;
  isEof := False;
  sendlog := ''; receivelog := '';

  if not BridgeWrapperDM.BridgeActivate then
    exit;

  if FDay <> ADate then
    initLastChangeDttm;

  FDay := ADate;
  changedt := FDayLastChangeDttm;

  while not isEof do
  begin
    baseresponse := sendEvent400( offset );
    try
      if baseresponse.EventID <> EventID_접수예약목록요청결과 then
      begin // error 처리
        exit;
      end;

      event_401 := TBridgeResponse_401( baseresponse );
      if event_401.ReceptionReservationCount > 0 then
      begin
        //offset := event_401.CurrentOffset + event_401.ReceptionReservationCount;
        offset := offset + 1;

        if GDebugLogLevel.Level = doRestPacketNomal then // data가 있을 경우에만 출력 한다.
          AddLog(doRestPacketNomal,'[GetRRData Polling] ' + #13#10 + sendlog + #13#10 + receivelog);

        // 수신된 접수/예약 정보를 table에 저장 한다.
        newchangedt := RnRDM.PackReceptionReservationList( event_401, Result, AFlashCount );
        if changedt < newchangedt then
          changedt := newchangedt;
        //if offset >= event_401.TotalDataCount then
        //  isEof := True; // data를 끝까지 읽었다.
(* 읽어온 블럭만큼 화면에 출력 되게 한다.
        else
          FObserver.BeforeAction(OB_Event_DataRefresh);
          FObserver.AfterAction(OB_Event_DataRefresh); *)
      end
      else
        isEof := True; // 처리할 data가 없다.
    finally
      FreeAndNil( baseresponse );
    end;
  end;
  FDayLastChangeDttm := changedt;
end;

function TRestCallDM.GetRRMonthData(AMonthDate: TDate;
  AReceptionReservationDataType: string; var AFlashCount : Integer): Integer;
var
  sendlog, receivelog : string;

  function sendEvent400( AOffset : Integer ) : TBridgeResponse;
  var
    sdt, edt : TDateTime;
    event401 : string;
    event_400 : TBridgeRequest_400;
  begin
    event_400 := TBridgeRequest_400( GetBridgeFactory.MakeRequestObj( EventID_접수예약목록요청 ) );
    try
      event_400.HospitalNo := GetRREnv.HospitalID;
      // 당월 data만
      CalcRangeMonth(AMonthDate, sdt, edt);
      event_400.ReceptnResveType := AReceptionReservationDataType;

      event_400.StartDttm := sdt;
      event_400.EndDttm := edt;

      if FDayLastChangeDttm = 0 then
        event_400.LastChangeDttm := 0 // 최종 update날자 등록
      else
        event_400.LastChangeDttm := FMonthLastChangeDttm;
      event_400.Limit := MaxRRListCount;
      event_400.Offset := AOffset;

      sendlog := AddLogStr( 'PG(RequestResponse) -> ' + event_400.ToJsonString );
      event401 := BridgeWrapperDM.RequestResponse( event_400.ToJsonString, True );
      receivelog := AddLogStr( 'PGR(RequestResponse) <- ' + event401 );

      Result := GetBridgeFactory.MakeResponseObj( event401 );
    finally
      FreeAndNil( event_400 );
    end;
  end;

var
  isEof : Boolean;
  offset : Integer;
  changedt, newchangedt : TDateTime;
  baseresponse : TBridgeResponse;
  event_401 : TBridgeResponse_401;
begin
  Result := 0;
  AFlashCount := 0;
  offset := 0;
  isEof := False;

  // 기존에 조회하는 data가 아니면 전체 data를 다시 읽을수 있게 한다.
  if FMonth <> AMonthDate then
    initMonthLastChangeDttm;

  FMonth := AMonthDate;

  changedt := FMonthLastChangeDttm;

  while not isEof do
  begin
    baseresponse := sendEvent400( offset );
    try
      if baseresponse.EventID <> EventID_접수예약목록요청결과 then
      begin // error 처리
        exit;
      end;

      event_401 := TBridgeResponse_401( baseresponse );
      if event_401.ReceptionReservationCount > 0 then
      begin
        if GDebugLogLevel.Level = doRestPacketNomal then // data가 있을 경우에만 출력 한다.
            AddLog(doRestPacketNomal,'[GetRRMonthData Polling] ' + #13#10 + sendlog + #13#10 + receivelog);

        //offset := event_401.CurrentOffset + event_401.ReceptionReservationCount;
        offset := offset + 1;

        // 수신된 접수/예약 정보를 table에 저장 한다.
        newchangedt := RnRDM.PackReceptionReservationList( event_401, Result, AFlashCount );
        if changedt < newchangedt then
          changedt := newchangedt;
        //if offset >= event_401.TotalDataCount then
        //  isEof := True; // data를 끝까지 읽었다.
      end
      else
        isEof := True; // 처리할 data가 없다.
    finally
      FreeAndNil( baseresponse );
    end;
  end;
  FMonthLastChangeDttm := changedt;
end;

procedure TRestCallDM.initLastChangeDttm;
begin
  FDayLastChangeDttm := 0;
end;

procedure TRestCallDM.initMonthLastChangeDttm;
begin
  FMonthLastChangeDttm := 0;
end;

procedure TRestCallDM.ClearLastChangeDttm;
begin
  FDay := 0;
  FMonth := 0;
  FDayLastChangeDttm := 0;
  FMonthLastChangeDttm := 0;
end;

end.
