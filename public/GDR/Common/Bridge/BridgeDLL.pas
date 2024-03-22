unit BridgeDLL;

(*
  본 unit은 gdbridge.dll를 적제하기 위해 만들어진 dll이다.
  참고 문서 : https://docs.google.com/document/d/1KczXf-Db1iyOP7pWgxExZwyYTMusjQSsPX_3NMluHKE/edit?ts=5ce634e6

  unsigned int : cardinal
  int : integer
  void * : pointer
*)
interface

uses
  Windows, Messages, SysUtils, SyncObjs;

type
  (*
    // 콜백 정의
    // pjson :json 형식의 string
    // nlen : pjson 문자열 길이
    typedef int(CALLBACK* GDL_FnCB)(IN void *pjson, IN unsigned int nlen);

  *)
  TGDL_FnCB = function( { in } pjson: Pointer; { in } nlen: cardinal) : integer; stdcall;
  PGDL_FnCB = ^TGDL_FnCB;

  (*
    GDBRIDGE_API int __stdcall gdl_login(IN LPCSTR pid, IN LPCSTR pw);
  *)
  Tgdl_login = function (nHospitalID: cardinal; pid : LPCSTR; pw : LPCSTR) : Integer; stdcall;
  Tgdl_loginw = function (nHospitalID: cardinal; pid : LPCWSTR; pw : LPWSTR) : Integer; stdcall;

  (*
    // nchartcode : 차트 프로그램의 종류(지정)
    // phospitalcode : 건강보험심사평가원에서 부여된 병원코드
    // nInitType : 초기화 형태(0:callback 사용, 1:폴링 사용)
    // cb : callback 함수의 포인터(nInitType이 1인 경우 NULL 입력)

    GDBRIDGE_API int __stdcall gdl_init(IN unsigned int nchartcode, IN LPCSTR phospitalcode, IN int nInitType, IN GDL_FnCB cb);

    GDBRIDGE_API int __stdcall gdl_initw(IN unsigned int nchartcode, IN LPCWSTR phospitalcode, IN int nInitType, IN GDL_FnCB cb);

    LPCSTR = PAnsiChar;
    LPCWSTR = PWideChar
  *)
  Tgdl_init = function( { in } nchartcode: cardinal; { in } phospitalcode: LPCSTR; { in } nInitType: integer; { in } cb: PGDL_FnCB): integer; stdcall;
  Tgdl_initw = function( { in } nchartcode: cardinal;     { in } phospitalcode: LPCWSTR; { in } nInitType: integer;
    { in } cb: PGDL_FnCB): integer; stdcall;

  (*
    LPCSTR __stdcall gdl_getbridgeid();
  *)
  Tgdl_getbridgeid = function : LPCSTR; stdcall;


  (*
    // 요청.응답 전송 함수
    // pjson : json 형식의 문자열
    // nlen : pjson의 문자열 길이

    {interface가 변경됨
    int __stdcall gdl_sendmessage(IN LPCSTR pjson, IN unsigned int nlen);
    int __stdcall gdl_sendmessagew(IN LPCWSTR pjson, IN unsigned int nlen);
    Tgdl_sendmessage = function ({in} pjson : LPCSTR; {in} nlen : cardinal ) : Integer; stdcall;
    Tgdl_sendmessagew = function ({in} pjson : LPCWSTR; {in} nlen : cardinal ) : Integer; stdcall;}

    LPCSTR  __stdcall gdl_sendrequest(IN LPCSTR pjson, IN unsigned int nlen);
    LPCWSTR  __stdcall gdl_sendrequestw(IN LPCWSTR pjson, IN unsigned int nlen);
  *)
  Tgdl_sendrequest = function( { in } pjson: LPCSTR; { in } nlen: cardinal) : LPCSTR; stdcall;
  Tgdl_sendrequestw = function( { in } pjson: LPCWSTR; { in } nlen: cardinal) : LPCWSTR; stdcall;

  (*
    // 응답 전송 함수
    // pjson : json 형식의 문자열
    // nlen : pjson의 문자열 길이

    int  __stdcall gdl_sendresponse(IN LPCSTR pjson, IN unsigned int nlen);
    int  __stdcall gdl_sendresponsew(IN LPCWSTR pjson, IN unsigned int nlen);
  *)
  Tgdl_sendresponse = function( { in } pjson: LPCSTR; { in } nlen: cardinal) : integer; stdcall;
  Tgdl_sendresponsew = function( { in } pjson: LPCWSTR; { in } nlen: cardinal) : integer; stdcall;

  (*
    // 작업 아이디 리턴 함수
    // pid : 작업 아이디를 받을 변수의 포인터
    // nlen : pid의 할당된 크기, 필요한 버퍼 크기 리턴(버퍼 크기 오류시)

    GDBRIDGE_API int __stdcall gdl_getjobid(IN OUT LPSTR pid, IN OUT unsigned int &nlen);
    GDBRIDGE_API int __stdcall gdl_getjobidw(IN OUT LPWSTR pid, IN OUT unsigned int &nlen);

  *)
  Tgdl_getjobid = function(pid: LPSTR; var nlen: cardinal) : integer; stdcall;
  Tgdl_getjobidw = function(pid: LPWSTR; var nlen: cardinal) : integer; stdcall;

  (*
    // 서버의 요청을 받아 오는 함수
    // pjson : 요청 데이터를 받을 변수의 포인터
    // nlen: pjson 의 할당된 크기, 필요한 버퍼 크기 리턴(버퍼 크기 오류시)
    // int : return 값, 0(요청 데이터가 있고 성공), 7(요청 데이터가 있으나 pjson의 버퍼 크기가 작음), 16(요청 데이터가 없음)

    GDBRIDGE_API int __stdcall gdl_getrequestmessage(IN OUT LPSTR pjson, IN OUTunsigned int &nlen);
    GDBRIDGE_API int __stdcall gdl_getrequestmessagew(IN OUT LPWSTR pjson, IN OUT unsigned int &nlen);
  *)
  Tgdl_getrequestmessage = function(var pjson: LPSTR; var nlen: cardinal) : integer; stdcall;
  Tgdl_getrequestmessagew = function(var pjson: LPWSTR; var nlen: cardinal) : integer; stdcall;

  (*
    // 에러코드를 받아오는 함수
    // uncode : API호출시 리턴된 에러 코드
    // pstring : 데이터를 받아올 버퍼을 넘기고 넘겨진 버퍼에 에러 설명을 리턴
    // nlen : 넘겨진 버퍼의 길이를 전달하고 리턴되는 에러 설명에 대한 길이를 리턴

    int __stdcall gdl_geterrorstring(IN int uncode, IN OUT LPSTR pstring, IN OUT unsigned int &nlen);
    int __stdcall gdl_geterrorstringw(IN int uncode, IN OUT LPWSTR pstring, IN OUT unsigned int &nlen);
  *)
  Tgdl_geterrorstring = function( { in } uncode: integer; pstring: LPSTR; var nlen: cardinal): integer; stdcall;
  Tgdl_geterrorstringw = function( { in } uncode: integer; pstring: LPWSTR; var nlen: cardinal): integer; stdcall;

  (*
    // 중지 함수

    int __stdcall gdl_deinit()
  *)
  Tgdl_deinit = function: integer; stdcall;

  (*V3-27
    // 브릿지에 웹소켓의 상태를 체크. Result: 1=alive, 0=dead

    int __stdcall gdl_iswcalive()
  *)
  Tgdl_iswcalive = function: integer; stdcall;

  T__BridgeDLL = class
  private
    { api declarations }
    _DLLHandle: THandle;
    FDLLFileName: string;
    FLock: TCriticalSection;
    FBridgeData: Pointer;
    FBridgeDataW: Pointer;

    _gdl_login : Tgdl_login;
    _gdl_loginw: Tgdl_loginw;
    _gdl_init: Tgdl_init;
    _gdl_initw: Tgdl_initw;
    _gdl_sendresponse: Tgdl_sendresponse; // callback 또는 Tgdl_getrequestmessage로 받은 event에 대한 응답용으로 사용함.
    _gdl_sendresponsew: Tgdl_sendresponsew; // callback 또는 Tgdl_getrequestmessage로 받은 event에 대한 응답용으로 사용함.

    _gdl_sendrequest: Tgdl_sendrequest;
    _gdl_sendrequestw: Tgdl_sendrequestw;

    _gdl_getjobid: Tgdl_getjobid;
    _gdl_getjobidw: Tgdl_getjobidw;
    _gdl_getrequestmessage: Tgdl_getrequestmessage; // 폴링시에 사용함.
    _gdl_getrequestmessagew: Tgdl_getrequestmessagew; // 폴링시에 사용함.
    _gdl_geterrorstring: Tgdl_geterrorstring;
    _gdl_geterrorstringw: Tgdl_geterrorstringw;
    _gdl_deinit: Tgdl_deinit;
    _gdl_getbridgeid : Tgdl_getbridgeid;

    _gdl_iswcalive : Tgdl_iswcalive; // V3-27
  public
    { api declarations }
    function login(AHospitalID: cardinal; AID : string; APW : string ) : Integer;
    function loginW(AHospitalID: cardinal; AID : string; APW : string ) : Integer;

    function init(AChartCode: cardinal; AHospitalCode: string; AInitType: integer; ACallBackFunc: PGDL_FnCB): integer;
    function initW(AChartCode: cardinal; AHospitalCode: string; AInitType: integer; ACallBackFunc: PGDL_FnCB): integer;
    function Deinit : Integer;

    function GetJobID: string;
    function GetJobIDW: string;
    function GetBridgeID : string;

    function SendRequestResponse(AJsonStr: string): string; // 요청 및 응답
    function SendRequestResponseW(AJsonStr: string): string; // 요청 및 응답

    function PutResponse(AJsonStr: string): integer; // 폴링, callback에 대한 응답
    function PutResponseW(AJsonStr: string): integer; // 폴링, callback에 대한 응답

    function GetRequest(AJsonStr: string): integer; // 폴링
    function GetRequestW(AJsonStr: string): integer; // 폴링

    function GetErrorString(AErrorCode: integer): string;
    function GetErrorStringW(AErrorCode: integer): string;

    function IsWebsocketAlive : Integer; // V3-27
  private
    { api declarations }
    FActivate: Boolean;

    function GetDLLLoaded: Boolean;

    function GetDataString(AData: Pointer; ALen: integer): String;
    function GetDataStringW(AData: Pointer; ALen: integer): String;
  public
    { public declarations }
    constructor Create(ADLLFilename: string); virtual;
    destructor Destroy; override;

    function Load: Boolean;
    procedure Unload;

    property DLLFileName: string read FDLLFileName;
    property DLLLoaded: Boolean read GetDLLLoaded;

    property Activate: Boolean read FActivate;
    // init이 호출되면 true, deinit이 호출되면 false을 반환 한다.
  end;

const
{$ifdef DEBUG}
  _Bridge_DLL_FileName = 'gdbridge.dll';
  //_Bridge_DLL_RegistryPath = 'Software\goodoc_v30';
{$else}
  // 2020.11.23 deprecated. Use registry value 'HKEY_CURRENT_USER\SOFTWARE\goodoc_v30\bridgepath' (https://goodoc.atlassian.net/browse/V3-49)
  _Bridge_DLL_FileName = '..\bin\gdbridge.dll';
  //_Bridge_DLL_RegistryPath = 'Software\goodoc_v30';
{$endif}
  _Bridge_DLL_FileNameFallback = 'gdbridge.dll';
  _Bridge_MaxDataSize = 10240; // 10k
  _Bridge_MaxDataSize4Message = 1024;  // 1k

const // bridge 동작 방식
  _Bridge_InitType_CallBack = 0;
  _Bridge_InitType_Polling = 1;

const // error
//  _Bridge_Return_Error_Success = 0;
  _Bridge_Return_Error_BufferSize = 7;
  _Bridge_Return_Error_NoData = 16;

var
  GBridgeDLL: T__BridgeDLL;

implementation

uses
  gdlog, BridgeCommUnit;

{ T__BridgeDLL }

constructor T__BridgeDLL.Create(ADLLFilename: string);
begin
  FActivate := False;

  _DLLHandle := INVALID_HANDLE_VALUE;


  FDLLFileName := ADLLFilename;

  _gdl_login := nil;
  _gdl_loginw := nil;
  _gdl_init := nil;
  _gdl_initw := nil;
  _gdl_sendrequest := nil;
  _gdl_sendrequestw := nil;
  _gdl_sendresponse := nil;
  _gdl_sendresponsew := nil;
  _gdl_getjobid := nil;
  _gdl_getjobidw := nil;
  _gdl_getrequestmessage := nil;
  _gdl_getrequestmessagew := nil;
  _gdl_geterrorstring := nil;
  _gdl_geterrorstringw := nil;
  _gdl_deinit := nil;
  _gdl_getbridgeid := nil;
  _gdl_iswcalive := nil; // V3-27

  FLock := TCriticalSection.Create;

  FBridgeData := GetMemory(_Bridge_MaxDataSize);
  FBridgeDataW := GetMemory(_Bridge_MaxDataSize * SizeOf(WideChar));
end;

function T__BridgeDLL.Deinit : Integer;
begin
  Result := Result_DLLNotLoaded;
  if not DLLLoaded then
    exit;

  FLock.Enter;
  try
    try
      Result := _gdl_deinit;
    except
      on e : exception do
      begin
        Result := Result_ExceptionError;
        AddExceptionLog('T__BridgeDLL.Deinit', e);
      end;
    end;
    AddLog(doValueLog, Format('T__BridgeDLL.Deinit : Result=%d', [Result]));
  finally
    FLock.Leave;
  end;
end;

destructor T__BridgeDLL.Destroy;
begin
  if FActivate then
    Deinit;

//  Unload;
  FreeAndNil(FLock);

  FreeMemory(FBridgeData);
  FreeMemory(FBridgeDataW);
  inherited;
end;

function T__BridgeDLL.GetDLLLoaded: Boolean;
begin
  Result := _DLLHandle <> INVALID_HANDLE_VALUE;
end;

function T__BridgeDLL.GetErrorString(AErrorCode: integer): string;
var
  ret: integer;
  len: cardinal;
  //  p : Pointer;
begin
  Result := '';
  if not DLLLoaded then
    exit;

  FLock.Enter;
  try
    len := _Bridge_MaxDataSize - 1;
    ret := _gdl_geterrorstring(AErrorCode, LPSTR( FBridgeData ), len);
    AddLog(doValueLog, Format('T__BridgeDLL.GetErrorString : ret=%d, len=%d', [ret, len]));
    if (ret <> Result_Success) or (len = 0) then
      exit;

    Result := GetDataString(FBridgeData, len);

(* 잘됨
    len := _Bridge_MaxDataSize4Message - 1;
    p := GetMemory(_Bridge_MaxDataSize4Message);
    ret := _gdl_geterrorstring(AErrorCode, LPSTR( p ), len);
    if (ret <> Result_Success) or (len = 0) then
      exit;

    Result := GetDataString(p, len);
    FreeMemory( p )*)
  finally
    FLock.Leave;
  end;
end;

function T__BridgeDLL.GetErrorStringW(AErrorCode: integer): string;
var
  ret: integer;
  len: cardinal;
begin
  Result := '';
  if not DLLLoaded then
    exit;

  FLock.Enter;
  try
    len := _Bridge_MaxDataSize - 1;

    ret := _gdl_geterrorstringw(AErrorCode, LPWSTR(FBridgeDataW), len);

    AddLog(doValueLog, Format('T__BridgeDLL.GetErrorStringW : ret=%d, len=%d', [ret, len]));
    if (ret <> Result_Success) or (len = 0) then
      exit;

    Result := GetDataStringW(FBridgeDataW, len);
  finally
    FLock.Leave;
  end;
end;

function T__BridgeDLL.GetJobID: string;
var
  ret: integer;
  len: cardinal;
begin
  Result := '';
  if not DLLLoaded then
    exit;

  FLock.Enter;
  try
    len := _Bridge_MaxDataSize -1;
    ret := _gdl_getjobid(LPSTR(FBridgeData), len);
    AddLog(doValueLog, Format('T__BridgeDLL.GetJobID : ret=%d, len=%d', [ret, len]));
    if (ret <> Result_Success) or (len = 0) then
      exit;

    Result := GetDataString(FBridgeData, len);
  finally
    FLock.Leave;
  end;
end;

function T__BridgeDLL.GetJobIDW: string;
var
  ret: integer;
  len: cardinal;
begin
  Result := '';
  if not DLLLoaded then
    exit;

  FLock.Enter;
  try
    len := _Bridge_MaxDataSize;

    ret := _gdl_getjobidw(LPWSTR(FBridgeDataW), len);

    AddLog(doValueLog, Format('T__BridgeDLL.GetJobIDW : ret=%d, len=%d', [ret, len]));
    if (ret <> Result_Success) or (len = 0) then
      exit;

    Result := GetDataStringW(FBridgeDataW, len);
  finally
    FLock.Leave;
  end;
end;

function T__BridgeDLL.init(AChartCode: cardinal; AHospitalCode: string;
  AInitType: integer; ACallBackFunc: PGDL_FnCB): integer;
var
  hospitalcode: AnsiString;
  data: LPCSTR;
begin
  Result := 0;
  if not DLLLoaded then
    exit;

  data := GetMemory(50);
  FLock.Enter;
  try
{$WARNINGS OFF}
    hospitalcode := AHospitalCode;
{$WARNINGS ON}
    FillChar(data^, 50, #0);
    Move(hospitalcode[1], data^, Length(hospitalcode));

    try
      Result := _gdl_init(AChartCode, data, AInitType, ACallBackFunc);
    except
      on e : exception do
      begin
        Result := Result_ExceptionError;
        AddExceptionLog('T__BridgeDLL.init', e);
      end;
    end;

    FActivate := Result = Result_Success;
  finally
    FLock.Leave;
    FreeMemory(data);
  end;
end;

function T__BridgeDLL.initW(AChartCode: cardinal; AHospitalCode: string;
  AInitType: integer; ACallBackFunc: PGDL_FnCB): integer;
var
  // aa : UnicodeString;
  hospitalcode: WideString;
begin
  Result := 0;
  if not DLLLoaded then
    exit;

  FLock.Enter;
  try
    // aa := AHospitalCode;
    // hospitalcode := StringToWideChar( AHospitalCode );
    hospitalcode := AHospitalCode;

    Result := _gdl_initw(AChartCode, LPCWSTR(hospitalcode[1]), AInitType, ACallBackFunc);
    FActivate := Result = 0;
    AddLog(doValueLog, Format('T__BridgeDLL.init(%d, %s, %d) : ret=%d', [AChartCode, hospitalcode, AInitType, Result]));
  finally
    FLock.Leave;
  end;
end;

function T__BridgeDLL.GetBridgeID: string;
var
  data : LPCSTR;
begin
  Result := '';
  if not DLLLoaded then
    exit;

  FLock.Enter;
  try
    try
      data := _gdl_getbridgeid;
      Result := string( pansichar( @data^ ) );
    except
      on e : exception do
      begin
        Result := '';
        AddExceptionLog('T__BridgeDLL.GetBridgeID', e);
      end;
    end;
  finally
    FLock.Leave;
  end;
end;

function T__BridgeDLL.GetDataString(AData: Pointer; ALen: integer): String;
var
  // l : Integer;
  data: AnsiString;
begin
  (* 1.
    len := strend(PAnsiChar(@FBridgeData)) - PAnsiChar(@FBridgeData);
    SetLength( data, len);
    Move(LPSTR(FBridgeData), data[1], len ); *)

  (* 2.
    data := StrPas( pansichar( FBridgeData ) );
    Result := pansichar( @FBridgeData ) ; *)

  (* 3.
    data := pansichar( @AData^ ); // 잘됨 *)
  data := pansichar( @AData^ );
  Result := string(data)
end;

function T__BridgeDLL.GetDataStringW(AData: Pointer; ALen: integer): String;
// var
// data : WideString;
begin
  // data := PWideChar( @AData^ );
  // Result := string( data );
  Result := WideCharToString(PWideChar(@AData^));
end;

function T__BridgeDLL.Load: Boolean;
var
  isUnload: Boolean;

  function GetProcFunc(lpProcName: string): FARPROC;
  var
    err: cardinal;
  begin
    Result := GetProcAddress(_DLLHandle, pchar(lpProcName));
    if Result = nil then
    begin
      err := GetLastError;
      AddLog(doErrorLog, Format('%s 적제 실패 : %s(%d)',
        [lpProcName, SysErrorMessage(err), err]));
      isUnload := True;
    end;
  end;

var
  err: cardinal;
begin
  Result := False;
  FLock.Enter;
  try
    try
      Unload;

      if not FileExists(FDLLFileName) then
      begin
        AddLog(doErrorLog, Format('%s 파일이 없습니다.', [FDLLFileName]));
        exit;
      end;

      _DLLHandle := LoadLibrary(pchar(FDLLFileName));
      if _DLLHandle = 0 then
      begin
        err := GetLastError;
        _DLLHandle := INVALID_HANDLE_VALUE;
        AddLog(doErrorLog, Format('%s LoadLibrary 적제 실패 : %s(%d)',
          [FDLLFileName, SysErrorMessage(err), err]));
        exit;
      end;

      isUnload := False;

      @_gdl_login := GetProcFunc('gdl_login');
      @_gdl_loginw := GetProcFunc('gdl_loginw');
      @_gdl_init := GetProcFunc('gdl_init');
      @_gdl_initw := GetProcFunc('gdl_initw');
      @_gdl_sendrequest := GetProcFunc('gdl_sendrequest');
      @_gdl_sendrequestw := GetProcFunc('gdl_sendrequestw');

      @_gdl_sendresponse := GetProcFunc('gdl_sendresponse');
      @_gdl_sendresponsew := GetProcFunc('gdl_sendresponsew');

      @_gdl_getjobid := GetProcFunc('gdl_getjobid');
      @_gdl_getjobidw := GetProcFunc('gdl_getjobidw');
      @_gdl_getrequestmessage := GetProcFunc('gdl_getrequestmessage');
      @_gdl_getrequestmessagew := GetProcFunc('gdl_getrequestmessagew');
      @_gdl_geterrorstring := GetProcFunc('gdl_geterrorstring');
      @_gdl_geterrorstringw := GetProcFunc('gdl_geterrorstringw');
      @_gdl_deinit := GetProcFunc('gdl_deinit');
      @_gdl_getbridgeid := GetProcFunc('gdl_getbridgeid');

      @_gdl_iswcalive := GetProcFunc('gdl_iswcalive');

      if isUnload then
      begin
        AddLog(doRunLog, 'Bridge DLL load fail!');
        Unload;
      end
      else
        AddLog(doRunLog, 'Bridge DLL load!');

      Result := DLLLoaded;
    except
      on e: exception do
      begin
        AddExceptionLog(Format('T__BridgeDLL.Load(%s)', [FDLLFileName]), e);
      end;
    end;
  finally
    FLock.Leave;
  end;
end;

function T__BridgeDLL.login(AHospitalID: cardinal; AID, APW: string): Integer;
var
  ansiid, ansipw : AnsiString;
  pid, ppw: LPCSTR;
begin
{$WARNINGS OFF}
  ansiid := AID;
  ansipw := APW;
{$WARNINGS ON}
  pid := pansichar(ansiid);
  ppw := pansichar(ansipw);

  try
    Result := _gdl_login(AHospitalID, pid, ppw);
  except
    on e : exception do
    begin
      Result := Result_ExceptionError;
      AddExceptionLog('T__BridgeDLL.login', e);
    end;
  end;
end;

function T__BridgeDLL.loginw(AHospitalID: cardinal; AID, APW: string): Integer;
var
  //ansiid, ansipw : AnsiString;
  pid, ppw: LPCWSTR;
begin
{$WARNINGS OFF}
  //ansiid := AID;
  //ansipw := APW;
{$WARNINGS ON}
  pid := PWideChar(AID);
  ppw := PWideChar(APW);

  try
    Result := _gdl_loginw(AHospitalID, pid, ppw);
  except
    on e : exception do
    begin
      Result := Result_ExceptionError;
      AddExceptionLog('T__BridgeDLL.login', e);
    end;
  end;
end;

function T__BridgeDLL.SendRequestResponse(AJsonStr: string): string;
var
  len: cardinal;
  ansidata: AnsiString;
  data: LPCSTR; // PAnsiChar
  retdata: LPCSTR;
begin
  Result := '';
  if not DLLLoaded then
    exit;

  FLock.Enter;
  try
    len := ByteLength(AJsonStr);

{$WARNINGS OFF}
    ansidata := AJsonStr;
{$WARNINGS ON}
    data := pansichar(ansidata);
    retdata := '';

    try
      // Result := _gdl_sendmessage( data, len );  interface가 변경됨
      retdata := _gdl_sendrequest(data, len);
      Result := GetDataString(retdata, 0);
    except
      on e : exception do
      begin
        AddExceptionLog('T__BridgeDLL.SendRequestResponse', e);
{$WARNINGS OFF}
        AddLog(doErrorLog, 'T__BridgeDLL.SendRequestResponse : ' + #13#10 + AJsonStr+ #13#10 + retdata );
{$WARNINGS ON}
      end;
    end;
  finally
    FLock.Leave;
  end;
end;

function T__BridgeDLL.SendRequestResponseW(AJsonStr: string): string;
var
  len: cardinal;
  widedata: WideString;
  data, retdata: LPCWSTR; // PWideChar
begin
  Result := '';
  if not DLLLoaded then
    exit;

  FLock.Enter;
  try
    widedata := AJsonStr;
    len := ByteLength(widedata);
    data := PWideChar(widedata);
    try
      // Result := _gdl_sendmessagew( data, len );
      retdata := _gdl_sendrequestw(data, len);
      Result := GetDataStringW(retdata, 0);
    except
      on e : exception do
      begin
        AddExceptionLog('T__BridgeDLL.SendRequestResponseW', e);
      end;
    end;
  finally
    FLock.Leave;
  end;
end;

function T__BridgeDLL.GetRequest(AJsonStr: string): integer;
var
  len: cardinal;
  ansidata: AnsiString;
  data: LPCSTR; // PAnsiChar
begin
  Result := 0;
  if not DLLLoaded then
    exit;

  FLock.Enter;
  try
    len := _Bridge_MaxDataSize;
    // len := ByteLength( AJsonStr );

    data := LPCSTR(GetMemory(_Bridge_MaxDataSize));
    try
      FillChar(data, _Bridge_MaxDataSize, #0);

{$WARNINGS OFF}
      ansidata := AJsonStr;
{$WARNINGS ON}

      Move(ansidata[1], data, ByteLength(AJsonStr));

      try
        Result := _gdl_getrequestmessage(data, len);
      except
        on e : exception do
        begin
          Result := Result_ExceptionError;
          AddExceptionLog('T__BridgeDLL.GetRequest', e);
        end;
      end;
    finally
      FreeMemory(data);
    end;
  finally
    FLock.Leave;
  end;
end;

function T__BridgeDLL.GetRequestW(AJsonStr: string): integer;
var
  len: cardinal;
  widedata: WideString;
  data: LPWSTR; // PwideChar
begin
  Result := 0;
  if not DLLLoaded then
    exit;

  FLock.Enter;
  try
    // len := ByteLength( AJsonStr );
    len := _Bridge_MaxDataSize * SizeOf(WideChar);

    data := LPWSTR(GetMemory(len));
    try
      FillChar(data, _Bridge_MaxDataSize, #0);

      widedata := AJsonStr;

      Move(widedata[1], data, ByteLength(widedata));
      try
        Result := _gdl_getrequestmessagew(data, len);
      except
        on e : exception do
        begin
          Result := Result_ExceptionError;
          AddExceptionLog('T__BridgeDLL.GetRequestW', e);
        end;
      end;
    finally
      FreeMemory(data);
    end;
  finally
    FLock.Leave;
  end;
end;

function T__BridgeDLL.PutResponse(AJsonStr: string): integer;
var
  len: cardinal;
  ansidata: AnsiString;
//  data: LPCSTR; // PAnsiChar
  data2: LPCSTR; // PAnsiChar
begin
  Result := 0;
  if not DLLLoaded then
    exit;

  FLock.Enter;
  try
//    len := _Bridge_MaxDataSize;
    // len := ByteLength( AJsonStr );

//    data := LPCSTR(GetMemory(_Bridge_MaxDataSize));
    try
//      FillChar(data^, _Bridge_MaxDataSize, #0);
{$WARNINGS OFF}
      ansidata := AJsonStr;
{$WARNINGS ON}
//      Move(ansidata[1], data^, ByteLength(AJsonStr));
      data2 := pansichar(ansidata);
      len := Length( ansidata );

      try
        Result := _gdl_sendresponse(data2, len);
//      Result := _gdl_sendresponse(data, len);
      except
        on e : exception do
        begin
          Result := Result_ExceptionError;
          AddExceptionLog('T__BridgeDLL.PutResponse', e);
        end;
      end;

    finally
//      FreeMemory(data);
    end;
  finally
    FLock.Leave;
  end;
end;

function T__BridgeDLL.PutResponseW(AJsonStr: string): integer;
var
  len: cardinal;
  widedata: WideString;
  data: LPWSTR; // PwideChar
begin
  Result := 0;
  if not DLLLoaded then
    exit;

  FLock.Enter;
  try
    // len := ByteLength( AJsonStr );
    len := _Bridge_MaxDataSize * SizeOf(WideChar);

    data := LPWSTR(GetMemory(len));
    try
      FillChar(data, _Bridge_MaxDataSize, #0);

      widedata := AJsonStr;

      Move(widedata[1], data, ByteLength(widedata));
      try
        Result := _gdl_sendresponsew(data, len);
      except
        on e : exception do
        begin
          Result := Result_ExceptionError;
          AddExceptionLog('T__BridgeDLL.PutResponseW', e);
        end;
      end;
    finally
      FreeMemory(data);
    end;
  finally
    FLock.Leave;
  end;
end;

procedure T__BridgeDLL.Unload;
begin
  FLock.Enter;
  try
    AddLog(doRunLog, 'T__BridgeDLL.Unload : Bridge DLL Unload 호출!(' + FDLLFileName + ')');
    if _DLLHandle <> INVALID_HANDLE_VALUE then
    begin
      try
        AddLog(doRunLog, 'FreeLibrary 전');
        FreeLibrary(_DLLHandle);
        AddLog(doRunLog, 'FreeLibrary 후');

        _DLLHandle := INVALID_HANDLE_VALUE;
        _gdl_login := nil;
        _gdl_loginw := nil;
        _gdl_init := nil;
        _gdl_initw := nil;
        _gdl_sendrequest := nil;
        _gdl_sendrequestw := nil;
        _gdl_sendresponse := nil;
        _gdl_sendresponsew := nil;
        _gdl_getjobid := nil;
        _gdl_getjobidw := nil;
        _gdl_getrequestmessage := nil;
        _gdl_getrequestmessagew := nil;
        _gdl_geterrorstring := nil;
        _gdl_geterrorstringw := nil;
        _gdl_deinit := nil;
        _gdl_getbridgeid := nil;
        _gdl_iswcalive := nil; // V3-27

        AddLog(doRunLog, 'T__BridgeDLL.Unload : Bridge DLL Unload ok');
      except
        on e: exception do
        begin
          AddExceptionLog(Format('T__BridgeDLL.Unload(%s)', [FDLLFileName]), e);
        end;
      end;
    end;
  finally
    FLock.Leave;
  end;
end;

(*
V3-27
*)
function T__BridgeDLL.IsWebsocketAlive : Integer;
begin
  Result := Result_DLLNotLoaded;
  if not DLLLoaded then
    exit;

  FLock.Enter;
  try
    try
      Result := _gdl_iswcalive;
    except
      on e : exception do
      begin
        Result := Result_ExceptionError;
        AddExceptionLog('T__BridgeDLL.IsWebsocketAlive', e);
      end;
    end;
    AddLog(doValueLog, Format('T__BridgeDLL.IsWebsocketAlive : Result=%d', [Result]));
  finally
    FLock.Leave;
  end;
end;

initialization

GBridgeDLL := nil;

end.
