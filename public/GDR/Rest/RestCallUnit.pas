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
    { ���� dataó��  Public declarations }
    // ���� data�� ó������ �о�� ���� last change dttm���� 0���� ����� �ش�.
    procedure initLastChangeDttm;
    // ������ ������ data�� ��û�ؼ� �޾� �´�.
    function GetRRData( ADate : TDate; AReceptionReservationDataType : string; var AFlashCount : Integer ) : Integer;
  public
    { �� dataó��  Public declarations }
    // �� data�� ó������ �о�� ���� last change dttm���� 0���� ����� �ش�.
    procedure initMonthLastChangeDttm;
    // ������ ���� data�� ��û�ؼ� �޾� �´�. �˻� data�� ���� data�� �޾� ���� �Ѵ�.
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
  MaxRRListCount = 50; // �ѹ��� ���� ��ϼ�

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
    event_400 := TBridgeRequest_400( GetBridgeFactory.MakeRequestObj( EventID_���������Ͽ�û ) );
    try
      event_400.HospitalNo := GetRREnv.HospitalID;
      // ���� data��
      CalcRangeDay(ADate, sdt, edt);
      event_400.ReceptnResveType := AReceptionReservationDataType; // ����+���� ��� ��û

      //event_400.ReceptnResveType := RRType_ALL; // ����+���� ��� ��û
      //event_400.ReceptnResveType := RRType_Reservation; // ���� ��� ��û
      //event_400.ReceptnResveType := RRType_Reception; // ���� ��� ��û

      event_400.StartDttm := sdt;
      event_400.EndDttm := edt;

      if FDayLastChangeDttm = 0 then
        event_400.LastChangeDttm := 0 // ���� update���� ���
      else
        event_400.LastChangeDttm := FDayLastChangeDttm;
      event_400.Limit := MaxRRListCount;
      event_400.Offset := AOffset;

      sendlog := AddLogStr( 'PG(RequestResponse) -> ' + event_400.ToJsonString );
      // debug level�� dovaluelog�����̸� polling log�� ���� �ʴ´�. true�̸� polling log�̴�.
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
      if baseresponse.EventID <> EventID_���������Ͽ�û��� then
      begin // error ó��
        exit;
      end;

      event_401 := TBridgeResponse_401( baseresponse );
      if event_401.ReceptionReservationCount > 0 then
      begin
        //offset := event_401.CurrentOffset + event_401.ReceptionReservationCount;
        offset := offset + 1;

        if GDebugLogLevel.Level = doRestPacketNomal then // data�� ���� ��쿡�� ��� �Ѵ�.
          AddLog(doRestPacketNomal,'[GetRRData Polling] ' + #13#10 + sendlog + #13#10 + receivelog);

        // ���ŵ� ����/���� ������ table�� ���� �Ѵ�.
        newchangedt := RnRDM.PackReceptionReservationList( event_401, Result, AFlashCount );
        if changedt < newchangedt then
          changedt := newchangedt;
        //if offset >= event_401.TotalDataCount then
        //  isEof := True; // data�� ������ �о���.
(* �о�� ����ŭ ȭ�鿡 ��� �ǰ� �Ѵ�.
        else
          FObserver.BeforeAction(OB_Event_DataRefresh);
          FObserver.AfterAction(OB_Event_DataRefresh); *)
      end
      else
        isEof := True; // ó���� data�� ����.
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
    event_400 := TBridgeRequest_400( GetBridgeFactory.MakeRequestObj( EventID_���������Ͽ�û ) );
    try
      event_400.HospitalNo := GetRREnv.HospitalID;
      // ��� data��
      CalcRangeMonth(AMonthDate, sdt, edt);
      event_400.ReceptnResveType := AReceptionReservationDataType;

      event_400.StartDttm := sdt;
      event_400.EndDttm := edt;

      if FDayLastChangeDttm = 0 then
        event_400.LastChangeDttm := 0 // ���� update���� ���
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

  // ������ ��ȸ�ϴ� data�� �ƴϸ� ��ü data�� �ٽ� ������ �ְ� �Ѵ�.
  if FMonth <> AMonthDate then
    initMonthLastChangeDttm;

  FMonth := AMonthDate;

  changedt := FMonthLastChangeDttm;

  while not isEof do
  begin
    baseresponse := sendEvent400( offset );
    try
      if baseresponse.EventID <> EventID_���������Ͽ�û��� then
      begin // error ó��
        exit;
      end;

      event_401 := TBridgeResponse_401( baseresponse );
      if event_401.ReceptionReservationCount > 0 then
      begin
        if GDebugLogLevel.Level = doRestPacketNomal then // data�� ���� ��쿡�� ��� �Ѵ�.
            AddLog(doRestPacketNomal,'[GetRRMonthData Polling] ' + #13#10 + sendlog + #13#10 + receivelog);

        //offset := event_401.CurrentOffset + event_401.ReceptionReservationCount;
        offset := offset + 1;

        // ���ŵ� ����/���� ������ table�� ���� �Ѵ�.
        newchangedt := RnRDM.PackReceptionReservationList( event_401, Result, AFlashCount );
        if changedt < newchangedt then
          changedt := newchangedt;
        //if offset >= event_401.TotalDataCount then
        //  isEof := True; // data�� ������ �о���.
      end
      else
        isEof := True; // ó���� data�� ����.
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
