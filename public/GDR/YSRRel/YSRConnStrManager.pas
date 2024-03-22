unit YSRConnStrManager;
(*
  �ǻ��DB�� �����ϱ� ���� DB Connection Info�� ����
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

    // ������ registry���� connection string�� �о �ǻ���� connection string�� �����.
    function ReadRegistry : Boolean; // HKEY_CURRENT_USER

    // ����� connection string�� �����Ѵ�. result�� true�� connection string���� ����� �� �ִ�.
    function SetConnStr( AConnStr : string ) : Boolean;

    // c:\ysr2000\dbserver.ini���� db server ip �� engine name�� �о��.
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
  HospitalIDPath = 'SOFTWARE\goodoc_v40'; // registry���� �ǻ�� connection string�� ����� ��ġ

(*
DBServer.ini ���� ����
#####################################################################
#DBMSConnPriority=0                                  : DB ���ӽõ� �켱����  0: ���ýõ� �� ���ݽõ�, 1: ���ݽõ� �� ���ýõ�
#EngineName=YSR2000                              : ���� DB���� ��Ī
#CommLinks=tcpip{host=127.0.0.1}          : ���� DB���� IP
#DBMSConnInfoDisplay=0                           : DB �������� ȭ�� ���÷��� (�����ڿ�)
#####################################################################

[Connection Config]
EngineName=YSR2000
CommLinks=tcpip{host=192.168.219.104}
DBMSConnPriorToLastConnected=1
DBMSConnPriorityLastConnectedIndex=0
DBMSLastConnectedLogInInfoIndex=0
DBMSConnAutoCommitOff=0
LocalDBServerName=YSR2000 - SQL Anywhere ��Ʈ��ũ ����
DBMSVersion=12.0.1.4344
DBMSConnPriority=0
DBMSConnInfoDisplay=0
*)

{ TYSRConnStrManager }

(*
�������� connection string
DRIVER=SQL Anywhere 12;UID=DBA;PWD=#ub2014$cjsqordjr;Delphi=Yes;EngineName=YSR2000;CommLinks=tcpip{host=10.1.20.169};AutoStop=Yes;Integrated=No;Debug=No;DisableMultiRowFetch=No;PrefetchBuffer=2M;PrefetchRows=200;

ó�� ������ connection string
"CommLinks=tcpip"�� ���ԵǾ� �־�� ó�� ������ connection string�� �ȴ�
DRIVER=SQL Anywhere 12;Delphi=Yes;EngineName=YSR2000;CommLinks=tcpip;AutoStop=Yes;Integrated=No;Debug=No;DisableMultiRowFetch=No;PrefetchBuffer=2M;PrefetchRows=200;;UID=DBA;PWD=L5$T1t4ul#or2bAJErMA

CommLinks���� ������ connection�� �� ���� ����
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
      begin // commlinks�� ���� �� tcpip�� ���� �ִ�.
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

  // ����� dbserver.ini������ ���� �Ѵ�.
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
  begin // engine name�� ����.
    GetDBServerInfo_HostEngineName( h, e ); // dbserver.ini���� �о� �´�.
    if e <> '' then
      dname := e  // ����
    else // dbserver.ini���� ����.
      dname := YSRDefaultDataBaseName;  // �⺻�� ����
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
�м� ó�� �ʵ�. �����������ǿ�
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
