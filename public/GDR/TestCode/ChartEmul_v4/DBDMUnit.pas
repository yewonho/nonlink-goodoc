unit DBDMUnit;
(*
table 목록
reception : 접수 목록
patient : 환자 목록
reserve : 예약 목록
purpose : 내원목적
room : 진료실 목록
*)
interface

uses
  System.SysUtils, System.Classes, LiteCall, LiteConsts, Data.DB, DBAccess,
  LiteAccess,
  Vcl.DBGrids, MemDS;

type
  TDBDM = class(TDataModule)
    LiteConnection1: TLiteConnection;
    FindQuery: TLiteQuery;
    trans_table: TLiteQuery;
    LiteQuery1: TLiteQuery;
    procedure DataModuleDestroy(Sender: TObject);
    procedure LiteConnection1AfterConnect(Sender: TObject);
  private
    { Private declarations }
    function GetDBConnected: Boolean;
    procedure SetDBConnected(const Value: Boolean);
    procedure CheckDBUpdate; // table 구조 변경
  public
    { Public declarations }
    function FindPatient_RegNum( ARegNum : string ) : string; // 찾았으면 해당 환자의 차트 id를 반환 한다.
    procedure UpdatePatientAddress(APatientID, AAddr, AAddrDetail, AZip : string );
    property DBConnected : Boolean read GetDBConnected write SetDBConnected;
  end;

var
  DBDM: TDBDM;

procedure initDBGridWidth( ADBGrid: TDBGrid );

const
  Const_Period_NotSend    = 998;
  Const_Period_Send       = 999;

implementation
uses
  System.UITypes,
  Winapi.Messages, Vcl.Dialogs,
  LiteError;

{%CLASSGROUP 'Vcl.Controls.TControl'}

procedure initDBGridWidth( ADBGrid: TDBGrid );
var
  i, w : Integer;
  a : AnsiString;
  f : TField;
  widtharray : array of integer;
begin
  if not ADBGrid.DataSource.DataSet.Active then
    exit;

  ADBGrid.DataSource.DataSet.DisableControls;
  ADBGrid.Perform(WM_SETREDRAW, 0, 0);   // begineupdate
  try
    SetLength( widtharray, ADBGrid.FieldCount);

    for i := 0 to ADBGrid.FieldCount -1 do
    begin
      f := ADBGrid.Fields[ i ];
{$WARNINGS OFF}
      a := f.DisplayName;
{$WARNINGS ON}
      widtharray[ i ] := Length( a );
    end;

    with ADBGrid.DataSource.DataSet do
    begin
      First;
      while not Eof do
      begin
        for i := 0 to ADBGrid.FieldCount -1 do
        begin
          f := ADBGrid.Fields[ i ];
{$WARNINGS OFF}
          a := f.DisplayText;
{$WARNINGS ON}
          w := Length( a );
          if widtharray[ i ] < w then
            widtharray[ i ] := w;
        end;
        Next;
      end;
    end;

    for i := 0 to ADBGrid.FieldCount -1 do
    begin
      f := ADBGrid.Fields[ i ];
      f.DisplayWidth := widtharray[ i ] + 1;
    end;
  finally
    ADBGrid.DataSource.DataSet.EnableControls;
    ADBGrid.Perform(WM_SETREDRAW, 1, 0);   // endupdate
    ADBGrid.Invalidate;
  end;
end;

{$R *.dfm}

{ TDBDM }

procedure TDBDM.CheckDBUpdate;
var
  str : string;
  sl : TStringList;

  procedure Reception_AddDeviceType;
  begin
    sl.Clear;
    LiteConnection1.GetFieldNames('reception',sl);
    if sl.IndexOf( 'endpoint' ) < 0 then
    begin
      try
        trans_table.SQL.Clear;
        trans_table.SQL.Add( 'ALTER TABLE reception ' );
        trans_table.SQL.Add( '    ADD COLUMN endpoint varchar(1) DEFAULT '''' ' );
        trans_table.ExecSQL;

        // 기본값 설정
        trans_table.SQL.Clear;
        trans_table.SQL.Add( 'update reception set endpoint = '''' ' );
        trans_table.ExecSQL;
      except
        on e : ESQLiteError do
        begin
          str := Format('ESQLiteError : %s, %s, ErrorCode=%d',[e.Message, e.ClassName, e.ErrorCode]);
          MessageDlg(str, mtError, [mbOK], 0);
        end;
        on e : exception do
        begin
          str := Format('Error : %s, %s',[e.Message, e.ClassName ]);
          MessageDlg(str, mtError, [mbOK], 0);
        end;
      end;
    end;
  end;

  procedure Reception_AddStatusmng;
  begin
    sl.Clear;
    LiteConnection1.GetFieldNames('reception',sl);
    if sl.IndexOf( 'statusmng' ) < 0 then
    begin
      try
        trans_table.SQL.Clear;
        trans_table.SQL.Add( 'ALTER TABLE reception ' );
        trans_table.SQL.Add( '    ADD COLUMN statusmng varchar(3) DEFAULT '''' ' );
        trans_table.ExecSQL;

        // 기본값 설정
        trans_table.SQL.Clear;
        trans_table.SQL.Add( 'update reception set statusmng = status ' );
        trans_table.ExecSQL;
      except
        on e : ESQLiteError do
        begin
          str := Format('ESQLiteError : %s, %s, ErrorCode=%d',[e.Message, e.ClassName, e.ErrorCode]);
          MessageDlg(str, mtError, [mbOK], 0);
        end;
        on e : exception do
        begin
          str := Format('Error : %s, %s',[e.Message, e.ClassName ]);
          MessageDlg(str, mtError, [mbOK], 0);
        end;
      end;
    end;
  end;

  procedure reserve_AddReceptionChartReceptionID;
  begin
    sl.Clear;
    LiteConnection1.GetFieldNames('reserve',sl);
    if sl.IndexOf( 'receptionid' ) < 0 then
    begin
      try
        trans_table.SQL.Clear;
        trans_table.SQL.Add( 'ALTER TABLE reserve ' );
        trans_table.SQL.Add( '    ADD COLUMN receptionid varchar(20) DEFAULT '''' ' );
        trans_table.ExecSQL;

        // 기본값 설정
        trans_table.SQL.Clear;
        trans_table.SQL.Add( 'update reserve set receptionid = status ' );
        trans_table.ExecSQL;
      except
        on e : ESQLiteError do
        begin
          str := Format('ESQLiteError : %s, %s, ErrorCode=%d',[e.Message, e.ClassName, e.ErrorCode]);
          MessageDlg(str, mtError, [mbOK], 0);
        end;
        on e : exception do
        begin
          str := Format('Error : %s, %s',[e.Message, e.ClassName ]);
          MessageDlg(str, mtError, [mbOK], 0);
        end;
      end;
    end;
  end;

  procedure patient_Add_isfirst;
  begin
    sl.Clear;
    LiteConnection1.GetFieldNames('patient',sl);
    if sl.IndexOf( 'isfirst' ) < 0 then
    begin
      try
        trans_table.SQL.Clear;
        trans_table.SQL.Add( 'ALTER TABLE patient ' );
        trans_table.SQL.Add( '    ADD COLUMN isfirst integer DEFAULT 0 ' );
        trans_table.ExecSQL;

        // 기본값 설정
        trans_table.SQL.Clear;
        trans_table.SQL.Add( 'update patient set isfirst = 0 ' );
        trans_table.ExecSQL;
      except
        on e : ESQLiteError do
        begin
          str := Format('ESQLiteError : %s, %s, ErrorCode=%d',[e.Message, e.ClassName, e.ErrorCode]);
          MessageDlg(str, mtError, [mbOK], 0);
        end;
        on e : exception do
        begin
          str := Format('Error : %s, %s',[e.Message, e.ClassName ]);
          MessageDlg(str, mtError, [mbOK], 0);
        end;
      end;
    end;
  end;


  procedure reception_add_결제;
  begin
    sl.Clear;
    LiteConnection1.GetFieldNames('reception',sl);
    if sl.IndexOf( 'payauthno' ) < 0 then
    begin
      try
        trans_table.SQL.Clear;
        trans_table.SQL.Add( 'ALTER TABLE reception ' );
        trans_table.SQL.Add( '    ADD COLUMN payauthno varchar(128) DEFAULT '''' ' );
        trans_table.ExecSQL;

        // 기본값 설정
        trans_table.SQL.Clear;
        trans_table.SQL.Add( 'update reception set ' );
        trans_table.SQL.Add( '     payauthno = '''' ' );
        trans_table.ExecSQL;
      except
        on e : ESQLiteError do
        begin
          str := Format('ESQLiteError : %s, %s, ErrorCode=%d',[e.Message, e.ClassName, e.ErrorCode]);
          MessageDlg(str, mtError, [mbOK], 0);
        end;
        on e : exception do
        begin
          str := Format('Error : %s, %s',[e.Message, e.ClassName ]);
          MessageDlg(str, mtError, [mbOK], 0);
        end;
      end;
    end;

    if sl.IndexOf( 'useramt' ) < 0 then
    begin
      try
        trans_table.SQL.Clear;
        trans_table.SQL.Add( 'ALTER TABLE reception ' );
        trans_table.SQL.Add( '    ADD COLUMN useramt UNSIGNED BIG INT DEFAULT 0 ' );
        trans_table.ExecSQL;

        // 기본값 설정
        trans_table.SQL.Clear;
        trans_table.SQL.Add( 'update reception set ' );
        trans_table.SQL.Add( '     useramt = 0 ' );
        trans_table.ExecSQL;
      except
        on e : ESQLiteError do
        begin
          str := Format('ESQLiteError : %s, %s, ErrorCode=%d',[e.Message, e.ClassName, e.ErrorCode]);
          MessageDlg(str, mtError, [mbOK], 0);
        end;
        on e : exception do
        begin
          str := Format('Error : %s, %s',[e.Message, e.ClassName ]);
          MessageDlg(str, mtError, [mbOK], 0);
        end;
      end;
    end;

    if sl.IndexOf( 'totalamt' ) < 0 then
    begin
      try
        trans_table.SQL.Clear;
        trans_table.SQL.Add( 'ALTER TABLE reception ' );
        trans_table.SQL.Add( '    ADD COLUMN totalamt UNSIGNED BIG INT DEFAULT 0 ' );
        trans_table.ExecSQL;

        // 기본값 설정
        trans_table.SQL.Clear;
        trans_table.SQL.Add( 'update reception set ' );
        trans_table.SQL.Add( '     totalamt = 0 ' );
        trans_table.ExecSQL;
      except
        on e : ESQLiteError do
        begin
          str := Format('ESQLiteError : %s, %s, ErrorCode=%d',[e.Message, e.ClassName, e.ErrorCode]);
          MessageDlg(str, mtError, [mbOK], 0);
        end;
        on e : exception do
        begin
          str := Format('Error : %s, %s',[e.Message, e.ClassName ]);
          MessageDlg(str, mtError, [mbOK], 0);
        end;
      end;
    end;

    if sl.IndexOf( 'nhisamt' ) < 0 then
    begin
      try
        trans_table.SQL.Clear;
        trans_table.SQL.Add( 'ALTER TABLE reception ' );
        trans_table.SQL.Add( '    ADD COLUMN nhisamt UNSIGNED BIG INT DEFAULT 0 ' );
        trans_table.ExecSQL;

        // 기본값 설정
        trans_table.SQL.Clear;
        trans_table.SQL.Add( 'update reception set ' );
        trans_table.SQL.Add( '     nhisamt = 0 ' );
        trans_table.ExecSQL;
      except
        on e : ESQLiteError do
        begin
          str := Format('ESQLiteError : %s, %s, ErrorCode=%d',[e.Message, e.ClassName, e.ErrorCode]);
          MessageDlg(str, mtError, [mbOK], 0);
        end;
        on e : exception do
        begin
          str := Format('Error : %s, %s',[e.Message, e.ClassName ]);
          MessageDlg(str, mtError, [mbOK], 0);
        end;
      end;
    end;

    if sl.IndexOf( 'planmonth' ) < 0 then
    begin
      try
        trans_table.SQL.Clear;
        trans_table.SQL.Add( 'ALTER TABLE reception ' );
        trans_table.SQL.Add( '    ADD COLUMN planmonth varchar(3) DEFAULT '''' ' );
        trans_table.ExecSQL;

        // 기본값 설정
        trans_table.SQL.Clear;
        trans_table.SQL.Add( 'update reception set ' );
        trans_table.SQL.Add( '     planmonth = '''' ' );
        trans_table.ExecSQL;
      except
        on e : ESQLiteError do
        begin
          str := Format('ESQLiteError : %s, %s, ErrorCode=%d',[e.Message, e.ClassName, e.ErrorCode]);
          MessageDlg(str, mtError, [mbOK], 0);
        end;
        on e : exception do
        begin
          str := Format('Error : %s, %s',[e.Message, e.ClassName ]);
          MessageDlg(str, mtError, [mbOK], 0);
        end;
      end;
    end;

    if sl.IndexOf( 'transdttm' ) < 0 then
    begin
      try
        trans_table.SQL.Clear;
        trans_table.SQL.Add( 'ALTER TABLE reception ' );
        trans_table.SQL.Add( '    ADD COLUMN transdttm varchar(20) DEFAULT '''' ' );
        trans_table.ExecSQL;

        // 기본값 설정
        trans_table.SQL.Clear;
        trans_table.SQL.Add( 'update reception set ' );
        trans_table.SQL.Add( '     transdttm = '''' ' );
        trans_table.ExecSQL;
      except
        on e : ESQLiteError do
        begin
          str := Format('ESQLiteError : %s, %s, ErrorCode=%d',[e.Message, e.ClassName, e.ErrorCode]);
          MessageDlg(str, mtError, [mbOK], 0);
        end;
        on e : exception do
        begin
          str := Format('Error : %s, %s',[e.Message, e.ClassName ]);
          MessageDlg(str, mtError, [mbOK], 0);
        end;
      end;
    end;
  end;

  procedure Reception_AddPurpose;
  begin
    sl.Clear;
    LiteConnection1.GetFieldNames('reception',sl);
    if sl.IndexOf( 'compurpose' ) < 0 then
    begin
      try
        trans_table.SQL.Clear;
        trans_table.SQL.Add( 'ALTER TABLE reception ' );
        trans_table.SQL.Add( '    ADD COLUMN compurpose varchar(100) DEFAULT '''' ' );
        trans_table.ExecSQL;

        // 기본값 설정
        trans_table.SQL.Clear;
        trans_table.SQL.Add( 'update reception set compurpose = '''' ' );
        trans_table.ExecSQL;
      except
        on e : ESQLiteError do
        begin
          str := Format('ESQLiteError : %s, %s, ErrorCode=%d',[e.Message, e.ClassName, e.ErrorCode]);
          MessageDlg(str, mtError, [mbOK], 0);
        end;
        on e : exception do
        begin
          str := Format('Error : %s, %s',[e.Message, e.ClassName ]);
          MessageDlg(str, mtError, [mbOK], 0);
        end;
      end;
    end;
  end;

begin
  sl := TStringList.Create;
  try
    Reception_AddDeviceType; // reception table에 endpoint field 추가
    Reception_AddStatusmng; // 관리용 상태 field 추가
    reserve_AddReceptionChartReceptionID; // 예약 table에 예약접수시에 발생된 접수 id관리 field를 추가 한다.

    patient_Add_isfirst; // 신환 환자 check field 추가

    reception_add_결제; // 결제 field 추가

    Reception_AddPurpose; // 내원목적 표시 요청 (https://goodoc.atlassian.net/browse/V3-7)
  finally
    FreeAndNil( sl );
  end;
end;

procedure TDBDM.DataModuleDestroy(Sender: TObject);
begin
  DBDM.DBConnected := False;
end;

function TDBDM.FindPatient_RegNum(ARegNum: string): string;
begin
  Result := '';
  FindQuery.Active := False;
  try
    FindQuery.SQL.Text := 'select * from patient where regnum = :regnum';
    FindQuery.ParamByName( 'regnum' ).Value := ARegNum;
    FindQuery.Active := True;
    FindQuery.First;

    if not FindQuery.Eof then
    begin
      Result := FindQuery.FieldByName( 'chartid' ).AsString;
    end;
  finally
    FindQuery.Active := False;
  end;
end;

function TDBDM.GetDBConnected: Boolean;
begin
  Result := LiteConnection1.Connected;
end;

procedure TDBDM.LiteConnection1AfterConnect(Sender: TObject);
begin
  CheckDBUpdate;
end;

procedure TDBDM.SetDBConnected(const Value: Boolean);
begin
  if not Value then
  begin  // disconnect 처리
    LiteConnection1.Connected := False;
    exit;
  end;

  LiteConnection1.Database := 'ChartEmul_v4.db3';
  LiteConnection1.Options.ForceCreateDatabase := False;
  LiteConnection1.Options.Direct := True;
  LiteConnection1.Open;
end;

procedure TDBDM.UpdatePatientAddress(APatientID, AAddr, AAddrDetail,
  AZip: string);
begin
  if AAddr = '' then
    exit;

  FindQuery.Active := False;
  try
    FindQuery.SQL.Text := 'select * from patient where chartid = :chartid';
    FindQuery.ParamByName( 'chartid' ).Value := APatientID;
    FindQuery.Active := True;
    FindQuery.First;

    if FindQuery.Eof then
      exit; // 검색하고자 하는 환자가 없다.

    if FindQuery.FieldByName('addr').AsString <> '' then
      exit; // 주소가 이미 들어 있다. update하지 않는다.
  finally
    FindQuery.Active := False;
  end;

  LiteQuery1.SQL.Clear;
  LiteQuery1.SQL.Add( 'update patient set ' );
  LiteQuery1.SQL.Add( 'addr = :addr, ' );
  LiteQuery1.SQL.Add( 'addrdetail = :addrdetail, ' );
  LiteQuery1.SQL.Add( 'zip = :zip ' );
  LiteQuery1.SQL.Add( ' where chartid = :chartid' );
  LiteQuery1.ParamByName('addr').Value := AAddr;
  LiteQuery1.ParamByName('addrdetail').Value := AAddrDetail;
  LiteQuery1.ParamByName('zip').Value := AZip;
  LiteQuery1.ParamByName('chartid').Value := APatientID;
  LiteQuery1.ExecSQL;
end;

end.
