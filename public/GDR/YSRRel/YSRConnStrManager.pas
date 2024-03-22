unit YSRConnStrManager;
(*
  의사랑DB에 접속하기 위한 DB Connection Info를 관리
*)

interface
uses
  System.SysUtils, System.Variants, System.Classes;

type
  TYSRConnStrManager = class(TComponent)

  private
    FConnectionString: string;
    FIsUsesConnStr: Boolean;

    function analysisDBInfo( ADBConnectionString : string; var AID, APW, AIP, ADataBaseName : string ) : Boolean;
    function makeDBConnectionString(AID, APW, AIP, ADataBaseName : string) : string;

    { util function }
    function GetIPAddress : string;
    function StrXOR( AXORStr : AnsiString ) : AnsiString;
    function matchIPPattern( AIPAddr : string ) : Boolean;

  protected


  public
    constructor Create( AOwner : TComponent ) ; override;
    destructor Destroy; override;

    // 지정된 registry에서 connection string을 읽어서 의사랑의 connection string을 만든다.
    function ReadRegistry : Boolean; // HKEY_CURRENT_USER

    // 사용할 connection string을 설정한다. result가 true면 connection string값을 사용할 수 있다.
    function SetConnStr( AConnStr : string ) : Boolean;

    // c:\ysr2000\dbserver.ini에서 db server ip 및 engine name을 읽어낸다.
    function GetDBServerInfo_HostEngineName( var AHost, AEngineName : string ) : Boolean;

    property ConnectionString : string read FConnectionString;
    property IsUsesConnStr : Boolean read FIsUsesConnStr;

  end;

implementation
uses
  Winapi.Windows, registry, inifiles, Winsock, GDLog, System.RegularExpressions;

const
  YSRDefaultDataBaseName = 'YSR2000';
  YSRConnStr = 'DRIVER=SQL Anywhere 12;UID=%s;PWD=%s;Delphi=Yes;EngineName=%s;CommLinks=tcpip{host=%s};AutoStop=Yes;Integrated=No;Debug=No;DisableMultiRowFetch=No;PrefetchBuffer=2M;PrefetchRows=200;';
  HospitalIDPath = 'SOFTWARE\goodoc_v40'; // registry에서 의사랑 connection string이 저장된 위치

(*
DBServer.ini 파일 내용
#####################################################################
#DBMSConnPriority=0                                  : DB 접속시도 우선순위  0: 로컬시도 후 원격시도, 1: 원격시도 후 로컬시도
#EngineName=YSR2000                              : 원격 DB서버 명칭
#CommLinks=tcpip{host=127.0.0.1}          : 원격 DB서버 IP
#DBMSConnInfoDisplay=0                           : DB 연결정보 화면 디스플레이 (개발자용)
#####################################################################

[Connection Config]
EngineName=YSR2000
CommLinks=tcpip{host=192.168.219.104}
DBMSConnPriorToLastConnected=1
DBMSConnPriorityLastConnectedIndex=0
DBMSLastConnectedLogInInfoIndex=0
DBMSConnAutoCommitOff=0
LocalDBServerName=YSR2000 - SQL Anywhere 네트워크 서버
DBMSVersion=12.0.1.4344
DBMSConnPriority=0
DBMSConnInfoDisplay=0
*)

{ TYSRConnStrManager }

(*
정상적인 connection string
DRIVER=SQL Anywhere 12;UID=DBA;PWD=#ub2014$cjsqordjr;Delphi=Yes;EngineName=YSR2000;CommLinks=tcpip{host=10.1.20.169};AutoStop=Yes;Integrated=No;Debug=No;DisableMultiRowFetch=No;PrefetchBuffer=2M;PrefetchRows=200;

처리 가능한 connection string
"CommLinks=tcpip"가 포함되어 있어야 처리 가능한 connection string이 된다
DRIVER=SQL Anywhere 12;Delphi=Yes;EngineName=YSR2000;CommLinks=tcpip;AutoStop=Yes;Integrated=No;Debug=No;DisableMultiRowFetch=No;PrefetchBuffer=2M;PrefetchRows=200;;UID=DBA;PWD=L5$T1t4ul#or2bAJErMA

CommLinks값이 없으면 connection을 할 수가 없다
*)
function TYSRConnStrManager.analysisDBInfo(ADBConnectionString: string; var AID: string; var APW: string; var AIP: string; var ADataBaseName: string)
 : Boolean;
var
  str : string;
  sl : TStringList;
begin
  Result := False;
  sl := TStringList.Create;
  try
    sl.Delimiter := ';';
    sl.DelimitedText := ADBConnectionString;
    AID := sl.Values['UID']; // DBA
    APW := sl.Values['PWD']; // #ub2014$cjsqordjr
    AIP := '';

    ADataBaseName := Trim( sl.Values['EngineName'] ); // YSR2000
    if ADataBaseName = '' then
      ADataBaseName := YSRDefaultDataBaseName;

    str := Trim( sl.Values['CommLinks'] ); // tcpip{host=10.1.20.169}
    if str <> '' then
    begin
      if CompareText('tcpip', str) = 0 then
      begin // commlinks의 정보 중 tcpip의 값만 있다.
        Result := (AID <> '') and (APW <> '');
        exit;
      end;

      str := StringReplace(str,'{',',',[rfReplaceAll]);
      str := StringReplace(str,'}',',',[rfReplaceAll]);
      sl.CommaText := str;
      AIP := sl.Values['host']; // 10.1.20.169
    end;
    if AIP = '' then
    begin
      AIP := GetIPAddress;
    end;

    Result := (AID <> '') and (APW <> '') and (AIP <> '');

  finally
    FreeAndNil(sl);
  end;

end;

constructor TYSRConnStrManager.Create(AOwner: TComponent);
begin
  inherited;
  FIsUsesConnStr := False;
  FConnectionString := '';
end;

destructor TYSRConnStrManager.Destroy;
begin
  FIsUsesConnStr := False;
  FConnectionString := '';

  inherited;
end;

function TYSRConnStrManager.GetDBServerInfo_HostEngineName(var AHost: string; var AEngineName: string) : Boolean;
const
  DBServerName1 = 'C:\YSR2000\DBServer.ini';
  DBServerName2 = 'D:\YSR2000\DBServer.ini';

  // 사용할 dbserver.ini파일을 선택 한다.
  function GetFileName : string;
  begin
    Result := '';
    if FileExists( DBServerName1 ) then
    begin
      Result := DBServerName1;
      exit;
    end;
    if FileExists( DBServerName2 ) then
    begin
      Result := DBServerName2;
      exit;
    end;
  end;

  function GetHostIP( ACommLinks : string ) : string;
  var
    str : string;
    sl : TStringList;
  begin
    Result := '';
    if ACommLinks = '' then
      exit;

    sl := TStringList.Create;
    try
      str := StringReplace(ACommLinks, '{', ',', [rfReplaceAll]);
      str := StringReplace(str, '}', ',', [rfReplaceAll]);
      sl.CommaText := str;
      Result := sl.Values['host'];
    finally
      FreeAndNil( sl );
    end;
  end;

  function GetEngineName( AEngineName : string ) : string;
  begin
    Result := '';
    if AEngineName = '' then
      exit;
    Result := AEngineName;
  end;

var
  fname : string;
  ini : TIniFile;
  cl, en : string;

begin
  Result := false;
  fname := GetFileName;
  if not FileExists( fname ) then
    exit;

  ini := TIniFile.Create( fname );
  try
    cl := ini.ReadString('Connection Config', 'CommLinks', '' );
    AHost := GetHostIP( cl );

    en := ini.ReadString('Connection Config', 'EngineName', '' );
    AEngineName := GetEngineName( en )
  finally
    FreeAndNil( ini );
  end;

end;

function TYSRConnStrManager.makeDBConnectionString(AID: string; APW: string; AIP: string; ADataBaseName: string) : string;
var
  dname : string;
  h, e : string;
begin
  dname := ADataBaseName;
  if ADataBaseName = '' then
  begin // engine name이 없다.
    GetDBServerInfo_HostEngineName( h, e ); // dbserver.ini에서 읽어 온다.
    if e <> '' then
      dname := e  // 설정
    else // dbserver.ini에도 없다.
      dname := YSRDefaultDataBaseName;  // 기본값 설정
  end;

//  'DRIVER=SQL Anywhere 12;UID=%s;PWD=%s;Delphi=Yes;EngineName=%s;CommLinks=tcpip{host=%s};AutoStop=Yes;Integrated=No;Debug=No;DisableMultiRowFetch=No;PrefetchBuffer=2M;PrefetchRows=200;';
  Result := Format( YSRConnStr, [AID, APW, dname, AIP] );
end;

function TYSRConnStrManager.ReadRegistry : Boolean;
var
  astr : AnsiString;
  str : string;
  reg : TRegistry;
begin
  reg := TRegistry.Create( KEY_READ or KEY_WOW64_64KEY );
  try
    try
      reg.RootKey := HKEY_CURRENT_USER;
      reg.OpenKey( HospitalIDPath, True );
      str := TrimLeft( reg.ReadString( 'msg' ) );
      str := TrimRight( str );

      astr := ansistring( str );
      str := string( StrXOR( astr ) );

      AddLog( doValueLog, 'DBConnection Read(ORG) : ' + str );

      Result := SetConnStr( str );

      AddLog( doValueLog, 'DBConnection Read : ' + FConnectionString );
    except
      on e : exception do
      begin
        Result := False;
        AddExceptionLog('TYSRConnStrManager.RestRegistry', e);
      end;
    end;
  finally
    FreeAndNil( reg );
  end;
end;

function TYSRConnStrManager.SetConnStr(AConnStr: string) : Boolean;
var
  id, pw, ip, dbname : string;
begin
(*
분석 처리 않됨. 연세더블유의원
DRIVER=SQL Anywhere 12;Delhi=Yes;;UID=DBA;PWD=nx#tjdrhd
*)
  if analysisDBInfo(AConnStr, id, pw, ip, dbname) then
  begin
    FConnectionString := AConnStr;
    FisUsesConnStr := True;
  end
  else
  begin
    if not matchIPPattern( ip ) then
      ip := GetIPAddress;

    FConnectionString := makeDBConnectionString( id, pw, ip, dbname );
    FisUsesConnStr := False;
  end;
  Result := FisUsesConnStr;
end;

function TYSRConnStrManager.GetIPAddress : string;
type
  pu_long = ^u_long;
var
  wsaData : TWSAData;
  hostEnt : PHostEnt;
  inAddr : TInAddr;
  namebuf : Array[0..255] of AnsiChar;
begin
  if WSAStartup($101,wsaData) <> 0 then
    Result := ''
  else
  begin
    gethostname(namebuf, sizeof(namebuf));
    hostEnt := gethostbyname(namebuf);
    inAddr.S_addr := u_long(pu_long(hostEnt^.h_addr_list^)^);
    Result := string(inet_ntoa(inAddr));
  end;
  WSACleanup;
end;

function TYSRConnStrManager.StrXOR( AXORStr : AnsiString ) : AnsiString;
const
  XORKEY = $0f;
var
  b : Byte;
  i, cnt : Integer;
  str : AnsiString;
begin
  cnt := Length( AXORStr );
  SetLength( str, cnt );
  FillChar(str[1], cnt, 0);

  for i := 1 to cnt do
  begin
    b := byte( AXORStr[i] );
    str[i] := ansichar( b xor XORKEY );
  end;
  Result := str;
end;

function TYSRConnStrManager.matchIPPattern( AIPAddr : string ) : boolean;
const
  IP_REGEX = '\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b';
begin
  Result := False;
  if AIPAddr = '' then
    exit;

  Result := TRegEx.IsMatch(AIPAddr, IP_REGEX);
end;

end.
