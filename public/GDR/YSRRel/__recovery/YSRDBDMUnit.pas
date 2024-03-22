unit YSRDBDMUnit;
(* YSR DB에 직접 연결하여 쿼리 등을 통해서 환자 조회 등의 기능을 수행함 *)

interface

uses
  System.SysUtils, System.Classes,
  Data.DB, Data.Win.ADODB,
  GDThread, RestCallUnit, BridgeCommUnit, YSRConnStrManager;

type
  TYSRDBDM = class(TDataModule)
  private
    { Private declarations }
    FADOConn : TADOConnection;
    FActive : Boolean;

  public
    { Public declarations }
    constructor Create( AOwner : TComponent ); override;
    destructor Destroy; override;

    function testConnectDB(DBConnStr : string) : Boolean;
    procedure DisconnectDB;

    procedure Start;
    procedure Stop;

    // 환자 정보 조회
    function FindPatient( AEvent0 : TBridgeResponse_0 ) : TBridgeRequest_1;

    property Active : Boolean read FActive;
  end;

const
  ERR_DB = -9999;
  ERR_RESTCALL = -9998;

var
  YSRDBDM: TYSRDBDM;

implementation
uses
  Winapi.Windows, GDLog, System.JSON, GDJson, System.JSON.Types, ActiveX, RREnvUnit;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{TYSRDBDM}

constructor TYSRDBDM.Create(AOwner: TComponent);
begin
  inherited;
  FActive := False;

  CoInitialize(nil);
  try
    FADOConn := TADOConnection.Create(Self);
    FADOConn.LoginPrompt := False;
  finally
    CoUnInitialize;
  end;
end;

destructor TYSRDBDM.Destroy;
begin
  Stop;

  if Assigned( FADOConn ) then
  begin
    CoInitialize(nil);

    DisconnectDB;
    FreeAndNil( FADOConn );

    CoUnInitialize;
  end;

  inherited;
end;

function TYSRDBDM.FindPatient(AEvent0: TBridgeResponse_0) : TBridgeRequest_1;

  // 쿼리문을 생성
  function makeFindPatientQuery(APhone, ARegNum : string) : string;
  var
    where : string;

    function makePhone : string;
    var
      l : Integer;
      t1, t2, t3 : string;
    begin
      Result := '';
      if APhone = '' then
        exit;

      l := 3;
      if Length( APhone ) >= 11 then
        l := 4;

      t1 := APhone.Substring(0, 3);
      t3 := APhone.Remove(0, 3);
      t2 := t3.Substring (0, l);
      t3 := t3.Remove(0, l);

      Result := '( P1.TEL2 REGEXP ''(.*)' + t1 + '(.*)' + t2 + '(.*)' + t3 + '(.*)''';
      Result := Result + ' OR P.TEL REGEXP ''(.*)' + t1 + '(.*)' + t2 + '(.*)' + t3 + '(.*)'' )';
    end;
    function makeRegNum : string;
    var
      r1, r2 : string;
    begin
      Result := '';
      if ARegNum = '' then
        exit;

      r1 := ARegNum.Substring(0, 6);
      r2 := ARegNum.Remove(0,6);

      Result := '( P.PREGI REGEXP ''(.*)' + r1 + '(.*)' + r2 + '(.*)'' )';
    end;
    procedure AddWhere( AStr : string );
    begin
      if AStr = '' then
        exit;

      if where <> '' then
        where := where + ' and ';
      where := where + AStr;
    end;

  var
    sl : TStringList;
  begin
    where := '';
    sl := TStringList.Create;
    try
      try
        with sl do
        begin
          Add( 'SELECT ' );
          Add( '   P.CNO, P.PREGI, P.PATIENT, P.POSTNUM,' );
          Add( '   P.GENDER, P.BIRTHDAY, P.ADDRESS, ' );
          Add( '   P.TEL, P1.TEL2 ' );
          Add( 'FROM ' );
          Add( '   PATIENT AS P ' );
          Add( '   INNER JOIN PATIENT1 AS P1 ON P.CNO=P1.CNO ' );

          AddWhere( makePhone );
          AddWhere( makeRegNum );

          if where <> '' then
          begin
            Add( 'WHERE ' );
            Add( where );
          end;

          // 출력 순서
          Add( 'order by p.patient, p1.startdate' );
        end;
        Result := sl.Text;
      except on e : exception do
        begin
          AddExceptionLog('Make Query Exception!');
        end;
      end;
    finally
      FreeAndNil( sl );
    end;
  end;
  // 의사랑DB에 쿼리 실행
  function doQuery(AQueryStr: string; ABridgeRequest : TBridgeRequest_1; var ACount: Integer) : string;

    function GetGenderData( AStr : string ) : string;
    begin
      Result := '0';
      if CompareText(AStr, 'F') = 0 then
        Result := '2'
      else if CompareText(AStr, 'M') = 0 then
        Result := '1';
    end;

    function ExtractInt( AStr : string ) : string;
    var
      i : Integer;
    begin
      Result := '';

      for i := 1 to Length( AStr ) do
      begin
        if CharInSet(AStr[i], ['0'..'9']) then
          Result := Result + AStr[i];
      end;
    end;

    function CheckCellPhone(ATel : string) : Boolean;
    const
      TT : array [1..6] of string = ('010', '011', '016', '017', '018', '019');
    var
      i : Integer;
      a : string;
    begin
      Result := False;
      if ATel = '' then
        exit;

      a := ATel.Substring(1, 3);

      for i := 1 to 6 do
      begin
        if CompareText(a, TT[i]) = 0 then
        begin
          Result := True;
          exit;
        end;
      end;
    end;

  var
    patientChartId, patientName, regNum, cellPhone, sexDstn, birthday, addr, addrDetail, zip : string;
    tel, tel1, tel2 : string;

    dbconn : TADOConnection;
    query : TADOQuery;
  begin
    CoInitialize(nil);
    try
      dbconn := FADOConn;
      dbconn.ConnectionTimeout := 5;
      query := TADOQuery.Create( nil );

      query.Connection := dbconn;
      ACount := 0;
      query.Active := False;

      try
        query.SQL.Text := AQueryStr;
        query.Active := True;

        query.First;
        while not query.Eof do
        begin
          patientChartId := query.FieldByName('CNO').AsString;
          patientName := query.FieldByName('patient').AsString;
          sexDstn := GetGenderData( trim( query.FieldByName('gender').AsString ) );
          birthday := ExtractInt( query.FieldByName('birthday').AsString );
          addr := query.FieldByName('address').AsString;
          addrDetail := '';
          zip := StringReplace(query.FieldByName('postnum').AsString,'-','',[rfReplaceAll]);
          // 사용할 전화 번호는 둘중 휴대 번호를 사용하며, 둘다 아니면 patient1의 전화 번호를 사용한다.
          // tel2의 값이 없으면 patient의 tel값을 사용하게 한다.
          tel1 := query.FieldByName('tel').AsString;
          tel2 := query.FieldByName('tel2').AsString;
          if CheckCellPhone( tel2 ) then
            tel := tel2 // 휴대번호
          else if CheckCellPhone( tel1 ) then
            tel := tel1  // 휴대 번호
          else
          begin  // 둘다 휴대 번호가 아닌 경우
            if tel2 <> '' then
              tel := tel2
            else
              tel := tel1
          end;
          cellPhone := ExtractInt(tel);
          regNum := ExtractInt(query.FieldByName('PREGI').AsString);

          // send result
          ABridgeRequest.Add(patientChartId, patientName, regNum, cellPhone, sexDstn, birthday, addr, addrDetail, zip);

          Inc( ACount );
          query.Next;
        end; // while
      finally
        query.Active := False;
      end;
    finally
      FreeAndNil( query );

      CoUnInitialize;
    end;
  end;

var
  starttime : Cardinal;
  phone, regnum : string;
  querystr : string;
  str : string;

  bridgeRequest : TBridgeRequest_1;
  patientCount : Integer;
begin
  bridgeRequest := TBridgeRequest_1( GetBridgeFactory.MakeRequestObj( EventID_환자조회결과, AEvent0.JobID ) );
  bridgeRequest.HospitalNo := GetRREnv.HospitalID;

  phone := AEvent0.CellPhone;
  regnum := AEvent0.RegNum;

  querystr := makeFindPatientQuery( phone, regnum );
  AddLog( 'Query : ' + querystr );

  starttime := GetTickCount;

  str := doQuery( querystr, bridgeRequest, patientCount );

  starttime := GetTickCount - starttime;
  if starttime >= 2000 then
  begin
    AddLog( doWarningLog, '환자 검색 Timeout : ' + IntToStr(starttime) );
    AddQueryLog( querystr );
  end;

  bridgeRequest.Code := Result_SuccessCode;
  bridgeRequest.MessageStr := GetBridgeFactory.GetErrorString( bridgeRequest.Code );

  Result := bridgeRequest;
end;


procedure TYSRDBDM.Start;

  function LoadDBConnectionString (var ADBConnectionString : string) : Boolean;
  var
    ysr : TYSRConnStrManager;
  begin
    try
      ysr := TYSRConnStrManager.Create( nil );
      try
        ysr.ReadRegistry;
        ADBConnectionString := ysr.ConnectionString;
        Result := True;
      finally
        FreeAndNil( ysr );
      end;
    except
      on e : exception do
      begin
        Result := False;
        AddExceptionLog('TYSRDBDM.Start.LoadDBConnectionString', e);
      end;
    end;
  end;

var
  DBConnStr : string;
begin
  if FActive then
    exit;

  if not LoadDBConnectionString(DBConnStr) then
    exit;

  FADOConn.ConnectionString := DBConnStr;

  AddLog( doRunLog, 'TYSRDBDM.testConnectDB');
  if testConnectDB(DBConnStr) then
  begin
    AddLog( doRunLog, 'TYSRDBDM.Start DB Test OK!' );
  end
  else
  begin
    AddLog( doRunLog, 'TYSRDBDM.Start DB Test Error' );
    exit;
  end;

  FActive := True;
end;

procedure TYSRDBDM.Stop;
begin
  if not FActive then
    exit;

  AddLog( doRunLog, 'TYSRDBDM.Stop');

  FActive := False;

end;

function TYSRDBDM.testConnectDB(DBConnStr : string) : Boolean;
var
  dbconn : TADOConnection;
begin
  Result := False;
  CoInitialize(nil);
  try
    dbconn := FADOConn;
    try
      if not Assigned( FADOConn ) then
        AddLog( doWarningLog, 'FADOConn가 nil이다');

      dbconn.ConnectionString := DBConnStr;
      dbconn.ConnectionTimeout := 5;
      try
        dbconn.Connected := True;
        Result := dbconn.Connected;
      except
        on e : exception do
        begin
          AddExceptionLog('TYSRDBDM.testConnectDB: dbconn.Connected := True; Failed.', e);
          if Assigned( FADOConn ) then
          begin
            FreeAndNil( FADOConn );
          end;
          FADOConn := TADOConnection.Create(Self);
          FADOConn.ConnectionString := DBConnStr;
          exit;
        end;
      end;
      AddLog( doValueLog, 'TYSRDBDM.ConnectDB, Result=' + BoolToStr(Result, true) + ', ' + DBConnStr );
    except
      on e : exception do
      begin
        AddExceptionLog('TYSRDBDM.ConnectDB', e);

        if Assigned( FADOConn ) then
        begin
          FreeAndNil(FADOConn);
        end;
        FADOConn := TADOConnection.Create(Self);
        FADOConn.ConnectionString := DBConnStr;
        exit;
      end;
    end;
  finally
    CoUnInitialize;
  end;

end;

procedure TYSRDBDM.DisconnectDB;
begin
  if Assigned(FADOConn) then
    FADOConn.Connected := False;
end;


end.
