unit AccountDMUnit;

interface

uses
  System.SysUtils, System.Classes,
  System.Contnrs,
  BridgeCommUnit, EPBridgeCommUnit;

type
  TMonthListItem = class
  public
    cd : string; // 할부 코드
    nm : string; // BC 카드
  end;

  TAccountDM = class(TDataModule)
  private
    { Private declarations }
    FUsePlan: Boolean;
    FminPrice: LongWord;
    FPriceAmt: LongWord;
    FActive: Boolean;
    flist : TObjectList;

    procedure ClearMonthList;
    function GetMonthList(AIndex: Integer): TMonthListItem;
    function GetMonthListCount: Integer;
  public
    { Public declarations }
    constructor Create( AOwner : TComponent ); override;
    destructor Destroy; override;

    property Active : Boolean read FActive; // 병원 자동결제 사용 여부
    property UsePlan : Boolean read FUsePlan; // 할부 결제 사용 여부
    property PriceAmt : LongWord read FPriceAmt; // 1회 승인 가능 금액
    property minPrice : LongWord read FminPrice; // 할부 최소 금액

    property MonthList[ AIndex : Integer ] : TMonthListItem read GetMonthList;
    property MonthListCount : Integer read GetMonthListCount;
  public
    { Public declarations }
    function init결제 : integer;
    function Send310 : integer;
    function Send312 : integer;

    // 환자 결제 가능 여부 확인
    function CheckAccountPatient( AchartReceptnResultId : TChartReceptnResultId ) : Boolean;

    // 결제 요청
    function Send142(AchartReceptnResultId : TChartReceptnResultId; AtotalAmt, AnhisAmt, AuserAmt: LongWord; AplanMonth : string) : TBridgeResponse_143;

    // 결제 취소
    function Send144( AchartReceptnResultId1 : string; ApayAuthNo : string; AReason : string; var Atransdttm, AResultCd, AResultMsg : string ) : integer;
  end;

var
  AccountDM: TAccountDM;

implementation
uses
  GlobalUnit, GDBridge,
  ChartEmul_v4Unit;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TAccountDM }

function TAccountDM.CheckAccountPatient(
  AchartReceptnResultId: TChartReceptnResultId): Boolean;
var
  ret : string;
  p140 : TBridgeRequest_140;
  r141 : TBridgeResponse_141;
begin
  Result := False;

  p140 := TBridgeRequest_140( GBridgeFactory.MakeRequestObj( EventID_자동결제여부확인요청 ) );
  try
    p140.hospitalNo := GHospitalNo;
    p140.chartReceptnResultId.Id1 := AchartReceptnResultId.Id1;
    p140.chartReceptnResultId.Id2 := AchartReceptnResultId.Id2;
    p140.chartReceptnResultId.Id3 := AchartReceptnResultId.Id3;
    p140.chartReceptnResultId.Id4 := AchartReceptnResultId.Id4;
    p140.chartReceptnResultId.Id5 := AchartReceptnResultId.Id5;
    p140.chartReceptnResultId.Id6 := AchartReceptnResultId.Id6;

    ChartEmulV4Form.AddMemo(p140.EventID, p140.JobID);
    ret := GetBridge.RequestResponse( p140.ToJsonString );

    if ret <> '' then
    begin
      r141 := TBridgeResponse_141( GBridgeFactory.MakeResponseObj( ret ) );
      try
        ChartEmulV4Form.AddMemo(r141.EventID, r141.JobID, r141.Code, r141.MessageStr, 0);
        Result := r141.Active = 1;
      finally
        FreeAndNil( r141 );
      end;
    end;
  finally
    FreeAndNil( p140 );
  end;
end;

procedure TAccountDM.ClearMonthList;
begin
  flist.Clear;
end;

constructor TAccountDM.Create(AOwner: TComponent);
begin
  inherited;
  FUsePlan := False;
  FminPrice := 0;
  FPriceAmt := 0;
  FActive := False;
  flist := TObjectList.Create( True );
end;

destructor TAccountDM.Destroy;
begin
  ClearMonthList;
  FreeAndNil( flist );
  inherited;
end;

function TAccountDM.GetMonthList(AIndex: Integer): TMonthListItem;
begin
  Result := TMonthListItem( flist.Items[ AIndex] );
end;

function TAccountDM.GetMonthListCount: Integer;
begin
  Result := flist.Count;
end;


function TAccountDM.init결제: integer;
begin
  Result := Send310;
  if Result <> Result_Success then
    exit;
  if Active then
    Result := Send312;
end;

function TAccountDM.Send142(AchartReceptnResultId : TChartReceptnResultId; AtotalAmt, AnhisAmt, AuserAmt: LongWord;
  AplanMonth: string): TBridgeResponse_143;
var
  ret : string;
  p142 : TBridgeRequest_142;
begin
  Result := nil;

  p142 := TBridgeRequest_142( GBridgeFactory.MakeRequestObj( EventID_자동결제요청 ) );
  try
    p142.hospitalNo := GHospitalNo;
    p142.chartReceptnResultId.Id1 := AchartReceptnResultId.Id1;
    p142.chartReceptnResultId.Id2 := AchartReceptnResultId.Id2;
    p142.chartReceptnResultId.Id3 := AchartReceptnResultId.Id3;
    p142.chartReceptnResultId.Id4 := AchartReceptnResultId.Id4;
    p142.chartReceptnResultId.Id5 := AchartReceptnResultId.Id5;
    p142.chartReceptnResultId.Id6 := AchartReceptnResultId.Id6;
    p142.userAmt := AuserAmt;
    p142.totalAmt := AtotalAmt;
    p142.nhisAmt := AnhisAmt;
    p142.planMonth := AplanMonth;

    ChartEmulV4Form.AddMemo(p142.EventID, p142.JobID);
    ret := GetBridge.RequestResponse( p142.ToJsonString );
    if ret <> '' then
    begin
      Result := TBridgeResponse_143( GBridgeFactory.MakeResponseObj( ret ) );
      ChartEmulV4Form.AddMemo(Result.EventID, Result.JobID, Result.Code, Result.MessageStr, 0);
    end;
  finally
    FreeAndNil( p142 );
  end;
end;

function TAccountDM.Send144(AchartReceptnResultId1, ApayAuthNo,
  AReason: string; var Atransdttm, AResultCd, AResultMsg : string): integer;
var
  ret : string;
  p144 : TBridgeRequest_144;
  r145 : TBridgeResponse_145;
begin
  Result := Result_NoData;

  p144 := TBridgeRequest_144( GBridgeFactory.MakeRequestObj( EventID_자동결제취소요청 ) );
  try
    p144.hospitalNo := GHospitalNo;
    p144.payAuthNo := ApayAuthNo;
    p144.reason := AReason;
    p144.chartReceptnResultId.Id1 := AchartReceptnResultId1;

    ChartEmulV4Form.AddMemo(p144.EventID, p144.JobID);
    ret := GetBridge.RequestResponse( p144.ToJsonString );

    if ret <> '' then
    begin
      r145 := TBridgeResponse_145( GBridgeFactory.MakeResponseObj( ret ) );
      try
        Result := r145.Code;
        AResultCd := r145.resultCd;
        ChartEmulV4Form.AddMemo(r145.EventID, r145.JobID, r145.Code, r145.MessageStr, 0);
        if Result <> Result_Success then
        begin
          AResultMsg := r145.MessageStr;
          exit;
        end;

        Atransdttm := r145.transDttm;
        AResultMsg := r145.resultMsg;
        AResultMsg := r145.resultCd;
      finally
        FreeAndNil( r145 );
      end;
    end;
  finally
    FreeAndNil( p144 );
  end;
end;

function TAccountDM.Send310: integer;
var
  ret : string;
  p310 : TBridgeRequest_310;
  r311 : TBridgeResponse_311;
begin
  Result := Result_NoData;
  FActive := False;
  FUsePlan := False;
  FPriceAmt := 0;

  p310 := TBridgeRequest_310( GBridgeFactory.MakeRequestObj( EventID_자동결제병원확인요청 ) );
  try
    p310.hospitalNo := GHospitalNo;

    ChartEmulV4Form.AddMemo(p310.EventID, p310.JobID);
    ret := GetBridge.RequestResponse( p310.ToJsonString );

    if ret <> '' then
    begin
      r311 := TBridgeResponse_311( GBridgeFactory.MakeResponseObj( ret ) );
      try
        Result := r311.Code;
        ChartEmulV4Form.AddMemo(r311.EventID, r311.JobID, r311.Code, r311.MessageStr, 0);
        if Result <> Result_Success then
          exit;

        FActive := r311.Active;
        FUsePlan := r311.usePlan;
        FPriceAmt := r311.priceAmt;
      finally
        FreeAndNil( r311 );
      end;
    end;
  finally
    FreeAndNil( p310 );
  end;
end;

function TAccountDM.Send312: integer;
var
  i : Integer;
  mlitem : TMonthListItem;
  item : TCardmonthListItem;
  ret : string;
  p312 : TBridgeRequest_312;
  r313 : TBridgeResponse_313;
begin
  Result := Result_NoData;
  FminPrice := 0;
  ClearMonthList;

  p312 := TBridgeRequest_312( GBridgeFactory.MakeRequestObj( EventID_상세할부옵션요청 ) );
  try
    p312.hospitalNo := GHospitalNo;

    ChartEmulV4Form.AddMemo(p312.EventID, p312.JobID);
    ret := GetBridge.RequestResponse( p312.ToJsonString );

    if ret <> '' then
    begin
      r313 := TBridgeResponse_313( GBridgeFactory.MakeResponseObj( ret ) );
      try
        Result := r313.Code;
        ChartEmulV4Form.AddMemo(r313.EventID, r313.JobID, r313.Code, r313.MessageStr, 0);
        if Result <> Result_Success then
          exit;

        FminPrice := r313.minPrice;
        for i := 0 to r313.Count -1 do
        begin
          item := r313.monthList[ i ];
          mlitem := TMonthListItem.Create;
          mlitem.cd := item.cd;
          if mlitem.cd <> 'M0' then
            mlitem.nm := item.nm
          else
            mlitem.nm := '일시불';
          flist.Add( mlitem );
        end;
      finally
        FreeAndNil( r313 );
      end;
    end;
  finally
    FreeAndNil( p312 );
  end;
end;

end.
