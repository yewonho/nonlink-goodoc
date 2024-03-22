unit PatientMngUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Data.DB, Vcl.Grids,
  Vcl.DBGrids, DBDMUnit, MemDS, DBAccess, LiteAccess, Vcl.StdCtrls, Vcl.DBCtrls,
  BridgeCommUnit, {$ifdef _EP_} EPBridgeCommUnit, {$endif} GlobalUnit;

type
  TPatientMngForm = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    DBGrid1: TDBGrid;
    LiteQuery1: TLiteQuery;
    DataSource1: TDataSource;
    DBNavigator1: TDBNavigator;
    Button1: TButton;
    LabeledEdit1: TLabeledEdit;
    LabeledEdit2: TLabeledEdit;
    Button2: TButton;
    LiteQuery2: TLiteQuery;
    update_352: TLiteQuery;
    updategdid_query: TLiteQuery;
    gdid_query: TLiteQuery;
    Button3: TButton;
    removepatnt_query: TLiteQuery;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure LiteQuery1AfterOpen(DataSet: TDataSet);
    procedure LiteQuery1BeforeClose(DataSet: TDataSet);
    procedure LiteQuery1BeforeEdit(DataSet: TDataSet);
    procedure LiteQuery1AfterPost(DataSet: TDataSet);
    procedure DataSource1DataChange(Sender: TObject; Field: TField);
    procedure Button3Click(Sender: TObject);
    procedure RemovePatientAfterDelete(DataSet: TDataSet);
  private
    { Private declarations }
    procedure search( ACellPhone, ARegNum : string );
  public
    { Public declarations }
    procedure ChangeUI( AParentCtrl : TWinControl );
    function searchPatientList( ASearchData : TBridgeResponse_0 ) : TBridgeRequest_1;
    procedure DBRefresh;

    // chartid에 대한 gdid를 update한다.
    procedure UpdateGDID( AChartID : string; AGDID : string );
    // chartid에 대한 gdid를 반환 한다.
    function GetGDID( AChartID : string ) : string;

    // https://goodoc.atlassian.net/browse/V3-191
    function DeletePatientByAutomation( AChartId : string ) : Boolean;
  end;

var
  PatientMngForm: TPatientMngForm;

implementation
uses
  math, GDBridge,
  RoomListDialogUnit, ReceptionMngUnit,
  ChartEmul_v4Unit;

{$R *.dfm}

{ TPatientMngForm }

procedure TPatientMngForm.Button1Click(Sender: TObject);
begin
  LiteQuery1.Active := False;
  LiteQuery1.SQL.Text := 'select * from patient';
  LiteQuery1.Active := True;
  initDBGridWidth( DBGrid1 );
end;

procedure TPatientMngForm.Button2Click(Sender: TObject);
var
  br_100 : TBridgeRequest_100;
  responsebase : TBridgeResponse;
  ret : string;
begin
  if RoomListDialogForm.ShowModal <> mrOk then
    exit;

  br_100 := TBridgeRequest_100( GBridgeFactory.MakeRequestObj( EventID_접수요청 ) );
  br_100.PatntChartId := LiteQuery1.FieldByName( 'chartid' ).AsString;
  br_100.hospitalNo := GHospitalNo;
  { 차트에서 굿닥으로 전송되는 접수는 모두 더미로 처리 합니다.
  br_100.PatntName := LiteQuery1.FieldByName( 'name' ).AsString;
  br_100.RegNum := LiteQuery1.FieldByName( 'regnum' ).AsString;
  br_100.CellPhone := LiteQuery1.FieldByName( 'cellphone' ).AsString; }
  br_100.Sexdstn := LiteQuery1.FieldByName( 'sex' ).AsString;
  br_100.Birthday := LiteQuery1.FieldByName( 'birthday' ).AsString;
  br_100.addr := LiteQuery1.FieldByName( 'addr' ).AsString;
  br_100.addrDetail := LiteQuery1.FieldByName( 'addrdetail' ).AsString;
  br_100.zip := LiteQuery1.FieldByName( 'zip' ).AsString;

  br_100.RoomInfo.RoomCode := RoomListDialogForm.LastSelectRoomInfo.RoomCode;
  br_100.RoomInfo.RoomName := RoomListDialogForm.LastSelectRoomInfo.RoomName;
  br_100.RoomInfo.DeptCode := RoomListDialogForm.LastSelectRoomInfo.DeptCode;
  br_100.RoomInfo.DeptName := RoomListDialogForm.LastSelectRoomInfo.DeptName;
  br_100.RoomInfo.DoctorCode := RoomListDialogForm.LastSelectRoomInfo.DoctorCode;
  br_100.RoomInfo.DoctorName := RoomListDialogForm.LastSelectRoomInfo.DoctorName;

  br_100.ReceptionDttm := now;

  br_100.chartReceptnResultId.Id1 := FormatDateTime('yyyymmddhhnnsszzz', now);
  br_100.chartReceptnResultId.Id2 := '';
  br_100.chartReceptnResultId.Id3 := '';
  br_100.chartReceptnResultId.Id4 := '';
  br_100.chartReceptnResultId.Id5 := '';
  br_100.chartReceptnResultId.Id6 := '';

  br_100.gdid := LiteQuery1.FieldByName( 'gdid' ).AsString;
  br_100.ePrescriptionHospital := GElectronicPrescriptionsOption;  // 전자 처방전 병원 여부 (0:미사용,1:사용)

  // 접수 처리 한다.
    //local에 등록
    ReceptionMngForm.AddReception( br_100 );

    // 브릿지에 전송
    ChartEmulV4Form.AddMemo( br_100.EventID, br_100.JobID );
    ret := GetBridge.RequestResponse( br_100.ToJsonString );
    responsebase := GBridgeFactory.MakeResponseObj( ret );
    ChartEmulV4Form.AddMemo( responsebase.EventID, responsebase.JobID, responsebase.Code, responsebase.MessageStr, 0 );
    FreeAndNil( responsebase );

    ReceptionMngForm.UpdatePeriod(br_100.ReceptionDttm, br_100.RoomInfo.RoomCode);
    // 순서 값 전송
    ReceptionMngForm.SendPeriod( now, RoomListDialogForm.LastSelectRoomInfo );

  FreeAndNil( br_100 );
end;

procedure TPatientMngForm.Button3Click(Sender: TObject);
var
  cid : string;
begin
  cid := LiteQuery1.FieldByName('chartid').AsString;
  // 환자 해지
  LiteQuery1.Edit;
  LiteQuery1.FieldByName('isfirst').AsInteger := 0;
  LiteQuery1.Post;
end;

procedure TPatientMngForm.ChangeUI(AParentCtrl: TWinControl);
begin
  if Assigned( AParentCtrl ) then
  begin
    Panel1.Parent := AParentCtrl;
    Panel1.Align := alClient;
  end
  else
    Panel1.Parent := Self;
end;

procedure TPatientMngForm.DataSource1DataChange(Sender: TObject; Field: TField);
begin
  if not Assigned( DataSource1.DataSet ) then
    exit;
  if not DataSource1.DataSet.Active then
    exit;
  if DataSource1.DataSet.State <> dsBrowse then
    exit;

  with DataSource1.DataSet do
  begin
    Button3.Enabled := FieldByName( 'isfirst' ).AsInteger = 1;
  end;
end;

procedure TPatientMngForm.DBRefresh;
begin
  Button1.Click;
end;

function TPatientMngForm.GetGDID(AChartID: string): string;
begin
  Result := '';
  with gdid_query do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add( 'select * from patient' );
    SQL.Add( 'where' );
    SQL.Add( '   chartid = :chartid' );
    ParamByName( 'chartid' ).Value := AChartID;
    Active := True;

    First;
    if not Eof then
      Result := FieldByName( 'gdid' ).AsString;
    Active := False;
  end;
end;

procedure TPatientMngForm.LiteQuery1AfterOpen(DataSet: TDataSet);
begin
  Button2.Enabled := not DataSet.Eof;
end;

procedure TPatientMngForm.LiteQuery1AfterPost(DataSet: TDataSet);
begin
  DBGrid1.Options := [dgTitles,dgIndicator,dgColumnResize,dgColLines,dgRowLines,dgTabs,dgRowSelect,dgAlwaysShowSelection,dgConfirmDelete,dgCancelOnExit,dgTitleClick,dgTitleHotTrack];
end;

procedure TPatientMngForm.LiteQuery1BeforeClose(DataSet: TDataSet);
begin
  Button2.Enabled := False;
end;

procedure TPatientMngForm.LiteQuery1BeforeEdit(DataSet: TDataSet);
begin
  DBGrid1.Options := [dgEditing,dgTitles,dgIndicator,dgColumnResize,dgColLines,dgRowLines,dgTabs,dgConfirmDelete,dgCancelOnExit,dgTitleClick,dgTitleHotTrack];
end;

procedure TPatientMngForm.RemovePatientAfterDelete(DataSet: TDataSet);
begin
  if not ChartEmulV4Form.EqualsCurrentTab(Panel1.Parent) then
    exit;

  if not Assigned( DataSource1.DataSet ) then
    exit;

  // Active = False in other window
  if not DataSource1.DataSet.Active then
    exit;

  // perhaps, state is 'dsInactive' in other window
  if DataSource1.DataSet.State <> dsBrowse then
    exit;

  TThread.Synchronize(nil,
    procedure
    begin
      DBRefresh;
    end);
end;

procedure TPatientMngForm.search(ACellPhone, ARegNum: string);
  function makewhere : string;
  var
    cp, rn : string;
  begin
    Result := '';
    if (ACellPhone = '') and (ARegNum = '') then
      exit;
    if ACellPhone <> '' then
      cp := Format('( cellphone = ''%s'' )',[ACellPhone]);
    if ARegNum <> '' then
      rn := Format('( regnum = ''%s'' )',[ARegNum]);

    Result := cp;
    if rn <> '' then
      if Result = '' then
        Result := rn else Result := Result + ' and ' + rn;

    if Result <> '' then
      Result := ' where ' + Result;
  end;

begin
  LiteQuery2.Active := False;
  LiteQuery2.SQL.Clear;
  LiteQuery2.SQL.Add( 'select * from patient' );
  LiteQuery2.SQL.Add( makewhere );
  LiteQuery2.Active := True;
end;

function TPatientMngForm.searchPatientList(
  ASearchData: TBridgeResponse_0): TBridgeRequest_1;
begin
  LabeledEdit1.Text := ASearchData.CellPhone;
  LabeledEdit2.Text := ASearchData.RegNum;
  search(LabeledEdit1.Text, LabeledEdit2.Text);

  Result := TBridgeRequest_1( GBridgeFactory.MakeRequestObj(EventID_환자조회결과, ASearchData.JobID ) );
  Result.HospitalNo := GHospitalNo;

  if ASearchData.AnalysisErrorCode <> Result_SuccessCode then
  begin
    Result.Code := ASearchData.AnalysisErrorCode;
    Result.MessageStr :=  GBridgeFactory.GetErrorString( Result.Code );
    exit;
  end;

  Result.Code := Result_Success;
  Result.MessageStr := '';

  if (LabeledEdit1.Text = '') and (LabeledEdit2.Text = '') then
    exit;

  with LiteQuery2 do
  begin
    First;
    while not Eof do
    begin
      try
        Result.Add( FieldByName( 'chartid' ).AsString,
                    FieldByName( 'name' ).AsString,
                    FieldByName( 'regnum' ).AsString,
                    FieldByName( 'cellphone' ).AsString,
                    FieldByName( 'sex' ).AsString,
                    FieldByName( 'birthday' ).AsString,
                    FieldByName( 'addr' ).AsString,
                    FieldByName( 'addrdetail' ).AsString,
                    FieldByName( 'zip' ).AsString
                  );
      finally
        Next
      end;
    end;
    Active := False;
  end;
end;

procedure TPatientMngForm.UpdateGDID(AChartID, AGDID: string);
begin
  with updategdid_query do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add( 'update patient' );
    SQL.Add( 'set' );
    SQL.Add( '   gdid = :gdid' );
    SQL.Add( 'where' );
    SQL.Add( '   chartid = :chartid' );

    ParamByName( 'gdid' ).Value := AGDID;
    ParamByName( 'chartid' ).Value := AChartID;
    ExecSQL;
  end;
end;

function TPatientMngForm.DeletePatientByAutomation(AChartId: string) : Boolean;
var
  rowCount : Integer;
begin
  Result := False;
  rowCount := 0;

  with removepatnt_query do
  begin
    Active := False;

    SQL.Clear;
    SQL.Add( 'select * from patient where chartid = :chartid;' );
    ParamByName( 'chartid' ).AsString := AChartId;

    Active := True;
  end;
  if removepatnt_query.RecordCount = 0 then
  begin
    exit;
  end;

  with removepatnt_query do
  begin
    Active := False;

    SQL.Clear;
    SQL.Add( 'select * from reserve where chartid = :chartid and status not in (:s1, :s2, :s3, :s4);' );
    ParamByName( 'chartid' ).AsString := AChartId;
    ParamByName( 's1' ).AsString := Status_진료완료;
    ParamByName( 's2' ).AsString := Status_본인취소;
    ParamByName( 's3' ).AsString := Status_병원취소;
    ParamByName( 's4' ).AsString := Status_자동취소;

    Active := True;
  end;
  rowCount := rowCount + removepatnt_query.RecordCount;

  with removepatnt_query do
  begin
    Active := False;

    SQL.Clear;
    SQL.Add( 'select * from reception where chartid = :chartid and status not in (:s1, :s2, :s3, :s4);' );
    ParamByName( 'chartid' ).AsString := AChartId;
    ParamByName( 's1' ).AsString := Status_진료완료;
    ParamByName( 's2' ).AsString := Status_본인취소;
    ParamByName( 's3' ).AsString := Status_병원취소;
    ParamByName( 's4' ).AsString := Status_자동취소;

    Active := True;
  end;
  rowCount := rowCount + removePatnt_query.RecordCount;

  // 처리 중인(완료되지 않은) 예약/접수 내역이 있을 경우에는 환자를 삭제할 수 없다.
  if rowCount > 0 then
    exit;

  {try
    removepatnt_query.SQL.Clear;
    removepatnt_query.SQL.Add( 'delete from patient where chartid = :chartid;' );

    removepatnt_query.ParamByName( 'chartid' ).AsString := AChartId;

    removepatnt_query.ExecSQL;
  finally

  end;}

  with removepatnt_query do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add( 'select * from patient where chartid = :chartid;' );

    ParamByName( 'chartid' ).AsString := AChartId;
    Active := True;

    Delete;
  end;

  Result := True;

end;

end.
