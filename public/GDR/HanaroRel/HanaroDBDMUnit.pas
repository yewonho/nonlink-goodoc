unit HanaroDBDMUnit;
(* Hanaro DB에 직접 연결하여 쿼리 등을 통해서 환자 조회 등의 기능을 수행함 *)

interface

uses
  System.SysUtils, System.Classes,
  Data.DB, Data.Win.ADODB,
  GDThread, RestCallUnit, BridgeCommUnit, HanaroConnStrManager;

type
  THanaroDBDM = class(TDataModule)
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
  HanaroDBDM: THanaroDBDM;

implementation
uses
  Winapi.Windows, GDLog, System.JSON, GDJson, System.JSON.Types, ActiveX, RREnvUnit;

{$R *.dfm}

{TDentwebDBDM}

constructor THanaroDBDM.Create(AOwner : TComponent);
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

destructor THanaroDBDM.Destroy;
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

function THanaroDBDM.FindPatient(AEvent0: TBridgeResponse_0) : TBridgeRequest_1;

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

      //Result := '( P1.TEL2 REGEXP ''(.*)' + t1 + '(.*)' + t2 + '(.*)' + t3 + '(.*)''';
      //Result := Result + ' OR P.TEL REGEXP ''(.*)' + t1 + '(.*)' + t2 + '(.*)' + t3 + '(.*)'' )';
      Result := '( hp_no = ''' + t1 + '-' + t2 + '-' + t3 + ''' )';
    end;
    function makeRegNum : string;
    var
      r1, r2 : string;
    begin
      Result := '';
      if ARegNum = '' then
        exit;

      r1 := ARegNum.Substring(0, 6);
      //r2 := ARegNum.Remove(0,6);
      r2 := ARegNum[6] + '******';

      //Result := '( P.PREGI REGEXP ''(.*)' + r1 + '(.*)' + r2 + '(.*)'' )';
      Result := '( Ssn = ''' + r1 + ''' )';
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
      with sl do
      begin
        Add( 'SELECT * ' );
        Add( 'FROM dbo.tb_patient_info' );

        AddWhere( makePhone );
        // 덴트웹의 경우 주민번호가 sdb_patientsafe 에 암호화되어 들어가 있어서 사용할 수 없다.
        //AddWhere( makeRegNum );

        if where <> '' then
        begin
          Add( 'WHERE ' );
          Add( where );
        end;

        // 출력 순서
        //Add( 'order by ChartID' );
      end;
      Result := sl.Text;
    finally
      FreeAndNil( sl );
    end;
  end;
  // 아이프로DB에 쿼리 실행
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
          patientChartId := query.FieldByName('PNT_INT').AsString;
          patientName := query.FieldByName('PNT_NAME').AsString;
          sexDstn := '0'; //GetGenderData( trim( query.FieldByName('').AsString ) );
          birthday := ExtractInt( query.FieldByName('BIRTH_DAT').AsString );
          addr := query.FieldByName('HOME_ADDR').AsString;
          addrDetail := ''; // query.FieldByName('Addr2').AsString;
          zip := query.FieldByName('HOME_ZIPCD').AsString; //StringReplace(query.FieldByName('ZipCode').AsString,'-','',[rfReplaceAll]);
          tel1 := query.FieldByName('HP_NO').AsString;
          tel2 := '';
          tel := tel1;
          cellPhone := ExtractInt(tel);
          regNum := ExtractInt(query.FieldByName('RESI_NO').AsString);

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

  // 주민등록번호 조회가 불가능하므로 생략한다.
  if regnum = string.Empty then
  begin
    str := doQuery( querystr, bridgeRequest, patientCount );
  end;

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

procedure THanaroDBDM.Start;
  function LoadDBConnectionString (var ADBConnectionString : string) : Boolean;
  var
    hanaro : THanaroConnStrManager;
  begin
    try
      hanaro := THanaroConnStrManager.Create( nil );
      try
        hanaro.ReadRegistry;
        ADBConnectionString := hanaro.ConnectionString;
        Result := True;
      finally
        FreeAndNil( hanaro );
      end;
    except
      on e : exception do
      begin
        Result := False;
        AddExceptionLog('THanaroDBDM.Start.LoadDBConnectionString', e);
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

  AddLog( doRunLog, 'THanaroDBDM.testConnectDB');
  if testConnectDB(DBConnStr) then
  begin
    AddLog( doRunLog, 'THanaroDBDM.Start DB Test OK!' );
  end
  else
  begin
    AddLog( doRunLog, 'THanaroDBDM.Start DB Test Error' );
    exit;
  end;

  FActive := True;
end;

procedure THanaroDBDM.Stop;
begin
  if not FActive then
    exit;

  AddLog( doRunLog, 'THanaroDBDM.Stop');

  FActive := False;

end;

function THanaroDBDM.testConnectDB(DBConnStr: string) : Boolean;
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
          AddExceptionLog('THanaroDBDM.testConnectDB: dbconn.Connected := True; Failed.', e);
          if Assigned( FADOConn ) then
          begin
            FreeAndNil( FADOConn );
          end;
          FADOConn := TADOConnection.Create(Self);
          FADOConn.ConnectionString := DBConnStr;
          FADOConn.LoginPrompt := False;
          exit;
        end;
      end;
      AddLog( doValueLog, 'THanaroDBDM.ConnectDB, Result=' + BoolToStr(Result, true) + ', ' + DBConnStr );
    except
      on e : exception do
      begin
        AddExceptionLog('THanaroDBDM.ConnectDB', e);

        if Assigned( FADOConn ) then
        begin
          FreeAndNil(FADOConn);
        end;
        FADOConn := TADOConnection.Create(Self);
        FADOConn.ConnectionString := DBConnStr;
        FADOConn.LoginPrompt := False;
        exit;
      end;
    end;
  finally
    CoUnInitialize;
  end;

end;

procedure THanaroDBDM.DisconnectDB;
begin
  if Assigned(FADOConn) then
    FADOConn.Connected := False;
end;

end.

