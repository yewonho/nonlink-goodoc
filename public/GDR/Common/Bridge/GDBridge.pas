unit GDBridge;
(*
log 구분
PG ->  프로그램에서 브릿지로 api 호출
PGR <- 요청에 대한 응답
PG <- 브릿지에서 call back 발생
*)
interface
uses
  Windows, Messages, SysUtils, Classes, SyncObjs, System.Contnrs, Registry,
  GDThread,
  BridgeDLL;

type
  TBridgePollingData = procedure ( AJsonStr : string ) of object;
  TBridgeLogNodify = procedure ( ALogLevel : Integer; ALog : string ) of object;

  TGDBridge = class( TComponent )
  private
    { Private declarations }
    FBridgeDLL : T__BridgeDLL;
    FDLLName : string;
    FThread : TGDThread;
    FQueue : TStringList; // bridgedll에서 올라온 data를 저장 한다.
    FHospitalNo: string;
    FChartCode: integer;
    FBridgePollingData: TBridgePollingData;
    FBridgeLogNodify: TBridgeLogNodify;
    function ThreadExecute_QueueCheck(Sender: TObject) : boolean;
    function GetActivate: Boolean;
  protected
    { protected declarations }
    procedure doBridgePollingData( AJsonStr : string );
    procedure doBridgeLogNodify(ALogLevel : Integer; ALog : string);
  public
    { Public declarations }
    constructor Create( AOwner : TComponent ); override;
    destructor Destroy; override;

    function login( AHospitalID : cardinal; AID : string; APW : string ) : Integer;
    function init( AHospitalNo : string; AChartCode : Integer ) : integer; // 초기화 작업 및 동작 시작
    procedure DeInit; // bridge 동작 완료
    function GetBridgeID : string;

    // json string을 bridge로 전송 한다. 처리 결과를 result로 반환 한다. 0이면 문제없이 처리된 상태이다.
    function RequestResponse( AJsonStr : string; APolling : Boolean = False ) : string;
    // errorcode에 대한 error message를 반환 한다.
    function GetErrorMsg( AErrorCode : Integer ) : string; overload;
    function GetErrorMsg( AErrorCode : string ) : string; overload;

    procedure _AddJsonStr( AJsonStr : string );
    function PutResponse( AJsonStr : string ) : integer; // callback, 폴링 event 처리에 대한 응답할 때 사용 한다.

    function IsConnectionAlive : Boolean; // V3-27

    property DLLName : string read FDLLName;
    property HospitalNo : string read FHospitalNo;
    property ChartCode : integer read FChartCode;
    property Activate : Boolean read GetActivate;

    property OnBridgePollingData : TBridgePollingData read FBridgePollingData write FBridgePollingData;
    property OnBridgeLogNodify : TBridgeLogNodify read FBridgeLogNodify write FBridgeLogNodify;
  end;

function GetBridge : TGDBridge;

implementation
uses
  math,
  UtilsUnit, gdlog, GDDateTime,
  BridgeCommUnit;

var
  GBridge : TGDBridge;

function GetBridge : TGDBridge;
begin
  if not Assigned( GBridge ) then
    GBridge := TGDBridge.Create( nil );
  Result := GBridge;
end;

function BridgeCallBackFunc( Apjson : Pointer; nlen : cardinal ) : integer; stdcall;
var
  aa : AnsiString;
  s : string;
begin
  Result := 0;
  if nlen <= 0 then
    exit;

  //SetLength( aa, nlen);       // 우선은 잘됨
  //Move(Apjson^, aa[1], nlen); // 우선은 잘됨

  aa := pansichar( @Apjson^ ); // 잘됨

  //aa := StrPas( pansichar( @Apjson^ ) ); // 잘됨

{$WARNINGS OFF}
  s := aa;
{$WARNINGS ON}
  GetBridge._AddJsonStr( s ); // queue에 등록
end;

{ TGDBridge }

procedure TGDBridge._AddJsonStr(AJsonStr: string);
begin
  AddLog(doRestPacketNomal, 'PG(CallBack) <- ' +  AJsonStr);
  FQueue.Add( AJsonStr );
end;

constructor TGDBridge.Create(AOwner: TComponent);
{var
  reg : TRegistry;
  path : string;}
begin
  inherited;
  // https://goodoc.atlassian.net/browse/V3-49 : 다른 이슈가 있어서 롤백
  {
  reg := TRegistry.Create (KEY_READ or KEY_WOW64_64KEY);
  try
    reg.RootKey := HKEY_CURRENT_USER;
    if reg.OpenKey(_Bridge_DLL_RegistryPath, True) then
    begin
      if reg.ValueExists('bridgepath') then
      begin
        path := reg.ReadString('bridgepath');
        FDLLName := path + '\' + _Bridge_DLL_FileName.Substring(_Bridge_DLL_FileName.LastDelimiter('\'));
      end
      else
        FDLLName := RelToAbs(_Bridge_DLL_FileName, ExtractFilePath(ParamStr(0)) );
    end
    else
      FDLLName := RelToAbs(_Bridge_DLL_FileName, ExtractFilePath(ParamStr(0)) );

  finally
    FreeAndNil(reg);
  end;
  }
  if _Bridge_DLL_FileName.Contains('C:') then
    FDLLName := _Bridge_DLL_FileName
  else
    FDLLName := RelToAbs(_Bridge_DLL_FileName, ExtractFilePath(ParamStr(0)) );

  if not FileExists(FDLLName) then
    FDLLName := RelToAbs(_Bridge_DLL_FileNameFallback, ExtractFilePath(ParamStr(0)) );

  FBridgeDLL := T__BridgeDLL.Create( FDLLName );
  FBridgeDLL.Load;

  FQueue := TStringList.Create;

  FThread := CreateGDThread( self, 'TGDBridgeThread', 20,  ThreadExecute_QueueCheck, false);
  FThread.Start;
end;

procedure TGDBridge.DeInit;
var
  ret : Integer;
  s : Cardinal;
  err : string;
begin
  ret := Result_ExceptionError;
  s := StartTimer;
  try
    try
      ret := FBridgeDLL.Deinit;
      err := GetErrorMsg( ret );
    except
      on e : exception do
      begin
        doBridgeLogNodify(doErrorLog, Format('PG(deinit) -> Exception : %s(%s)', [e.Message, e.ClassName]));
      end;
    end;
  finally
    AddLog_WorkTime(FinishTimer( s ), 0, 'deinit' );
    doBridgeLogNodify(doValueLog, Format('PG(deinit) -> Result=%d, err=%s', [ret, err]));
  end;
end;

destructor TGDBridge.Destroy;
begin
  FThread.SafeTerminateThread;
  FreeAndNil( FThread );

  FreeAndNil( FBridgeDLL );
  FreeAndNil( FQueue );
  inherited;
end;

procedure TGDBridge.doBridgeLogNodify(ALogLevel: Integer; ALog: string);
begin
  if Assigned( FBridgeLogNodify ) then
    FBridgeLogNodify( ALogLevel, ALog );
end;

procedure TGDBridge.doBridgePollingData(AJsonStr: string);
begin
  doBridgeLogNodify( doRestPacketNomal, 'PG(doBridgePollingData) <- ' + AJsonStr );

  if Assigned( FBridgePollingData ) then
    FBridgePollingData( AJsonStr );
end;

function TGDBridge.GetActivate: Boolean;
begin
  Result := FBridgeDLL.Activate;
end;

function TGDBridge.GetBridgeID: string;
begin
  Result := FBridgeDLL.GetBridgeID;
  doBridgeLogNodify(doValueLog, Format('PG(GetBridgeID) -> ', [Result]));
end;

function TGDBridge.GetErrorMsg(AErrorCode: string): string;
var
  err : Integer;
begin
  Result := '';
  err := StrToIntDef(AErrorCode, -1);
  if err > 0 then
    Result := GetErrorMsg( err );
end;

function TGDBridge.GetErrorMsg(AErrorCode: Integer): string;
begin
  Result := FBridgeDLL.GetErrorString( AErrorCode );
end;

function TGDBridge.init(AHospitalNo: string; AChartCode: Integer): integer;
var
  err : string;
begin
  Result := Result_ExceptionError;
  FHospitalNo := AHospitalNo;
  FChartCode := AChartCode;

  try
    try
      Result := FBridgeDLL.init(FChartCode, AHospitalNo, _Bridge_InitType_CallBack, @BridgeCallBackFunc);
      err := GetErrorMsg( Result );
    except
      on e : exception do
      begin
        err := GetErrorMsg( Result );
        doBridgeLogNodify(doErrorLog, Format('PG(init) -> ChartCode:%d, HospitalID:%s, InitType:%d, Exception : %s(%s)', [FChartCode, FHospitalNo, _Bridge_InitType_CallBack, e.Message, e.ClassName]));
      end;
    end;
  finally
    doBridgeLogNodify(doValueLog, Format('PG(init) -> ChartCode:%d, HospitalID:%s, InitType:%d, Result=%d, err=%s', [FChartCode, FHospitalNo, _Bridge_InitType_CallBack, Result, err]));
  end;
end;

function TGDBridge.login(AHospitalID : cardinal; AID, APW: string): Integer;
var
  err : string;
begin
  Result := Result_ExceptionError;
  try
    try
      //Result := FBridgeDLL.login( AID, APW );
      Result := FBridgeDLL.loginW(AHospitalID, AID, APW);
      err := GetErrorMsg( Result );
    except
      on e : exception do
      begin
        if Result <> Result_ExceptionError then
          err := GetErrorMsg( Result )
        else
          err := 'exception 발생';
        doBridgeLogNodify(doErrorLog, Format('PG(login) -> ID(%s) : Exception : %s(%s), Err=%s', [AID, e.Message, e.ClassName, err]));
      end;
    end;
  finally
    doBridgeLogNodify(doValueLog, Format('PG(login) -> ID(%s) : Result=%d, err=%s', [AID, Result, err]));
  end;
end;

function TGDBridge.PutResponse(AJsonStr: string) : Integer;
var
  s : Cardinal;
  err : string;
begin
  s := StartTimer;
  try
    doBridgeLogNodify( doRestPacketNomal, 'PG(PutResponse) -> : ' + AJsonStr );
    Result := FBridgeDLL.PutResponse( AJsonStr );
  except
    on e : exception do
    begin
      Result := Result_ExceptionError;
      doBridgeLogNodify(doErrorLog, Format('PG(PutResponse) : Exception : %s(%s)' + #13#10 + '$s', [e.Message, e.ClassName, AJsonStr]));
    end;
  end;
  err := GetErrorMsg( Result );
  doBridgeLogNodify( doRestPacketNomal, 'PGR(PutResponse) <- : Result=' + IntToStr(Result) + ', ' + err );
  AddLog_WorkTime(FinishTimer( s ), 0, format( 'PG(PutResponse) : Result=%d, Msg=%s',[ Result, GetErrorMsg(Result)] ) );
end;

function TGDBridge.RequestResponse(AJsonStr: string; APolling : Boolean): string;
var
  s : Cardinal;
  logflag : integer;
begin
  Result := '';
  logflag := ifthen(APolling, doRestPacketALL, doRestPacketNomal);
  s := StartTimer;
  try
    doBridgeLogNodify( logflag, 'PG(RequestResponse) -> : ' + AJsonStr );

    Result := FBridgeDLL.SendRequestResponse( AJsonStr );

    doBridgeLogNodify( logflag, 'PGR(RequestResponse) <- : ' + Result );
  except
    on e : exception do
    begin
      doBridgeLogNodify(doErrorLog, Format('PG(RequestResponse) -> : Exception : %s(%s)' + #13#10 + '%s' , [e.Message, e.ClassName, AJsonStr]));
    end;
  end;
  AddLog_WorkTime(FinishTimer( s ), 0, 'SendRequestResponse 결과 : ' +  Result);
end;

function TGDBridge.ThreadExecute_QueueCheck(Sender: TObject): boolean;
var
  str : string;
begin
  Result := True;

  if FQueue.Count <= 0 then
    exit;

  str := FQueue.Strings[ 0 ];
  FQueue.Strings[ 0 ] := '';
  FQueue.Delete( 0 );
  doBridgePollingData( str );
end;

(*
V3-27
*)
function TGDBridge.IsConnectionAlive : boolean;
var
  ans : integer;
begin
  ans := FBridgeDLL.IsWebsocketAlive;
  Result := ans = 1;
end;

initialization
  GBridge := nil;

finalization
  if Assigned( GBridge ) then
    FreeAndNil( GBridge );

end.
