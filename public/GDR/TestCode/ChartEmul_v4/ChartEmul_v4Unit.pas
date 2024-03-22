unit ChartEmul_v4Unit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Data.DB,
  MemDS, DBAccess, LiteAccess, Vcl.ComCtrls, Vcl.AppEvnts,
  GlobalUnit;

type
  TChartEmulV4Form = class(TForm)
    Panel1: TPanel;
    HospitalNo_edit: TLabeledEdit;
    chartcode_edit: TLabeledEdit;
    saveenv_btn: TButton;
    Button1: TButton;
    Panel2: TPanel;
    Button2: TButton;
    selectquery: TLiteQuery;
    Button3: TButton;
    Panel3: TPanel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    ApplicationEvents1: TApplicationEvents;
    TabSheet3: TTabSheet;
    Button4: TButton;
    ComboBox1: TComboBox;
    TabSheet4: TTabSheet;
    Memo1: TMemo;
    Splitter1: TSplitter;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Timer1: TTimer;
    LabeledEdit1: TLabeledEdit;
    Timer2: TTimer;
    Button9: TButton;
    Label1: TLabel;
    TabSheet5: TTabSheet;
    Button10: TButton;
    Label2: TLabel;
    ConnectionState: TPanel;
    Label3: TLabel;
    HeartbeatTimer: TTimer;
    GridPanel1: TGridPanel;
    Memo2: TMemo;
    TabSheet6: TTabSheet;
    TabSheet7: TTabSheet;
    Button11: TButton;
    procedure FormShow(Sender: TObject);
    procedure saveenv_btnClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure ApplicationEvents1Idle(Sender: TObject; var Done: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure OnTimerHeartbeatTimer(Sender: TObject);
    procedure Memo1Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
  private
    { Private declarations }
    FRoomListTmp : TStringList;
    procedure BridgePollingData( AJsonStr : string );
    procedure BridgeLogNodify(ALogLevel : Integer; ALog : string);
    procedure initUI;
    procedure ShowUseServerType; // 사용하고 있는 서버 type을 caption에 출력 한다.
    procedure ShowChangeServerButton;
  private
    { Private declarations }
    procedure Send308; // 미전송 목록 요청
  public
    { Public declarations }
    constructor Create( AOwner : TComponent ); override;
    destructor Destroy; override;

    procedure AddMemo( AMsg : string ); overload;
    procedure AddMemo( AEventID : Integer; AJobID : string ); overload;
    procedure AddMemo( AEventID : Integer; AJobID : string; ACode : integer; AMsg : string; AResult : Integer ); overload;

    function EqualsCurrentTab(ATabsheet : TWinControl) : Boolean;
  end;

var
  ChartEmulV4Form: TChartEmulV4Form;

implementation
uses
  System.Contnrs, registry,
  strutils,
  System.UITypes, dateutils, GDJson, gdlog,
  QueryTestUnit,
  DBDMUnit, BridgeCommUnit, GDBridge, EPBridgeCommUnit,
  PatientMngUnit, ReceptionMngUnit, ReservationMngUnit,
  RoomMngUnit, AccountDMUnit, AccountRequestUnit, ReservationScheduleSendUnit, PatientStateAutomationUnit;

{$R *.dfm}

procedure TChartEmulV4Form.AddMemo(AMsg: string);
var
  t : string;
begin
  t := FormatDateTime('"["dd일 hh:nn:ss.zzz"]" ', now);
  Memo1.Lines.Add( t + AMsg );
  AddLog(doRunLog, AMsg );
end;

procedure TChartEmulV4Form.AddMemo(AEventID: Integer; AJobID: string);
var
  str : string;
begin
  str := Format('처리 : EventID:%d, JobID:%s',[AEventID, AJobID]);
  AddMemo( str );
end;

procedure TChartEmulV4Form.AddMemo(AEventID: Integer; AJobID : string; ACode : Integer;
  AMsg: string; AResult: Integer);
var
  str : string;
begin
  str := Format('결과 : EventID:%d, JobID:%s, Code:%d, Msg:%s, Result:%d',[AEventID, AJobID, ACode, AMsg, AResult]);
  AddMemo( str );
end;

function TChartEmulV4Form.EqualsCurrentTab(ATabsheet: TWinControl) : Boolean;
begin
  if PageControl1.ActivePage = ATabsheet then
    Result := True
  else
    Result := False;
end;

procedure TChartEmulV4Form.ApplicationEvents1Idle(Sender: TObject;
  var Done: Boolean);
begin
  if GSendReceptionPeriod then
  begin // 순서 정보 전송...
    GSendReceptionPeriod := False;
    Timer2.Enabled := False;
    Timer2.Enabled := True;
  end;
end;

procedure TChartEmulV4Form.BridgeLogNodify(ALogLevel: Integer; ALog: string);
begin
  AddMemo( ALog );
  AddLog(ALogLevel,'[TGDBridge] ' + ALog);
end;

procedure TChartEmulV4Form.BridgePollingData(AJsonStr: string);
var
  ret : Integer;
  str : string;
  eventrequest : TBridgeResponse;
  eventresponse : TBridgeRequest_Nomal;
begin
  eventrequest := nil;
  FRoomListTmp.Clear;
  eventrequest := GBridgeFactory.MakeResponseObj( AJsonStr );
  if not Assigned( eventrequest ) then
  begin
    eventresponse := TBridgeRequest_Nomal( GBridgeFactory.MakeRequestObj( EventID_시스템Error ) );
    eventresponse.Code := Result_NotDefineEvent;
    eventresponse.MessageStr := GBridgeFactory.GetErrorString( eventresponse.Code );
    GetBridge.PutResponse( eventresponse.ToJsonString );
    AddMemo( 'TChartEmulV4Form.BridgePollingData, 인지 할 수 없는 event id : ' +  AJsonStr );
    AddLog(doRunLog, 'TChartEmulV4Form.BridgePollingData, 인지 할 수 없는 event id : ' +  AJsonStr);
    FreeAndNil( eventresponse );
    exit;// 인지 할수 없는 json data이다
  end;
  AddMemo( eventrequest.EventID, eventrequest.JobID );

  try
    try
      case eventrequest.EventID of
        EventID_환자조회 :
          eventresponse := PatientMngForm.searchPatientList( TBridgeResponse_0( eventrequest ) );
        EventID_접수요청 :
          eventresponse := ReceptionMngForm.AddReception( TBridgeResponse_100( eventrequest ) );
        EventID_접수취소 :
          eventresponse := ReceptionMngForm.CancelReception( TBridgeResponse_102( eventrequest ) );
        EventID_내원확인요청 :
          eventresponse := ReceptionMngForm.VisitConfirm( TBridgeResponse_110( eventrequest ), FRoomListTmp );
        EventID_예약요청  :
          eventresponse := ReservationMngForm.AddReservation( TBridgeResponse_200( eventrequest ) );
        EventID_예약취소  :
          eventresponse := ReservationMngForm.CancelReservation( TBridgeResponse_202 ( eventrequest ) );

        EventID_미전송목록요청결과 : ;
        EventID_미전송목록요청결과전송결과 : ;

{$ifdef _EP_}
        EventID_전자처방전발급설정 :
          eventresponse := ReceptionMngForm.UpdateEP_Reception( TBridgeResponse_352( eventrequest ) );
{$endif}
      end;
    except
      on e : exception do
      begin
        AddExceptionLog('TChartEmulV4Form.BridgePollingData 1', e);
      end;
    end;

    if Assigned( eventresponse ) then
    begin
      try
        str := eventresponse.ToJsonString;
        AddLog(doRunLog, '처리 결과 전송 : ' + str);
        ret := GetBridge.PutResponse( str );
        AddMemo( eventresponse.EventID, eventresponse.JobID, eventresponse.Code, eventresponse.MessageStr, ret );

        if ret <> Result_Success then
        begin
          AddLog(doRunLog, format('결과 전송 실패(EventID:%d, JobID:%s) : Result=%d', [eventresponse.EventID, eventresponse.JobID, ret]) );
        end;

        if eventrequest.EventID = EventID_접수요청 then
        begin // 접수요청부분만 별도로 처리 한다.
          if eventresponse.Code = Result_Success then
          begin
            ReceptionMngForm.UpdatePeriod( TBridgeResponse_100( eventrequest ).ReceptionDttm, TBridgeRequest_101(eventresponse).RoomInfo.RoomCode );
            ReceptionMngForm.SendPeriod(now, TBridgeResponse_100( eventrequest ).RoomInfo);
          end;
        end
        else if eventrequest.EventID = EventID_내원확인요청 then
        begin
          if FRoomListTmp.Count <> 0 then
            ReceptionMngForm.UpdatePeriods( now, FRoomListTmp );
        end;
      except
        on e : exception do
        begin
          AddExceptionLog('TChartEmulV4Form.BridgePollingData 2', e);
          AddLog(doRunLog, eventresponse.ToJsonString);
        end;
      end;
      FreeAndNil( eventresponse );
    end;
  finally
    FreeAndNil( eventrequest );
  end;
end;

procedure TChartEmulV4Form.Button10Click(Sender: TObject);
var
  form : TAccountRequestForm;
begin
  form := TAccountRequestForm.Create( nil );
  try
    form.ShowModal;
  finally
    FreeAndNil( form );
  end;
end;

procedure TChartEmulV4Form.Button11Click(Sender: TObject);
  function readServerUrl() : string;
  var
    reg : TRegistry;
    url : string;
  begin
    try
      reg := TRegistry.Create( KEY_READ or KEY_WOW64_64KEY );
      try
        reg.RootKey := HKEY_CURRENT_USER;

        reg.OpenKey( 'SOFTWARE\goodoc_v40', true );
        url := 'https://';

        if reg.ValueExists( 'serverurl' ) then
          url := reg.ReadString( 'serverurl' );

        url := TrimLeft( url );
        url := TrimRight( url );

        Result := url
      finally
        FreeAndNil( reg );
      end;
    except
      on e : exception do
      begin
        AddExceptionLog('TChartEmulV4Form.Button1Click.readServerUrl, 환경 읽기', e);
      end;
    end;
  end;

var
  inputString: string;
  reg: TRegistry;
begin
  inputString := InputBox('연결서버URL을 입력하세요', '', readServerUrl);
  // save registry
  try
    reg := TRegistry.Create( KEY_ALL_ACCESS or KEY_WOW64_64KEY );
    try
      reg.RootKey := HKEY_CURRENT_USER;
      reg.OpenKey( 'SOFTWARE\goodoc_v40', True );
      reg.WriteString( 'serverurl', inputString );
    finally
      FreeAndNil( reg );
    end;
  except
    on e : exception do
    begin
      AddExceptionLog( 'TChartEmulV4Form.Button1Click, serverurl 기록 에러', e);
    end;
  end;
end;

procedure TChartEmulV4Form.Button1Click(Sender: TObject);
begin
  TQueryTestForm.Create( nil ).Show;
end;

procedure TChartEmulV4Form.Button2Click(Sender: TObject);
var
  ret : string;
  err : string;
  RoomInfo: TRoomListItem;
  event_300 : TBridgeRequest_300;
  event_301 : TBridgeResponse;
begin
  event_300 := TBridgeRequest_300( GBridgeFactory.MakeRequestObj( EventID_대기열목록전송 ) );
  event_300.HospitalNo := GHospitalNo;

  selectquery.Active := False;
  selectquery.SQL.Text := 'select * from room';
  selectquery.Active := True;

  selectquery.First;
  while not selectquery.Eof do
  begin
    try
      RoomInfo := TRoomListItem.Create;

      RoomInfo.RoomCode := selectquery.FieldByName( 'roomcode' ).AsString;
      RoomInfo.RoomName := selectquery.FieldByName( 'roomname' ).AsString;
      RoomInfo.DeptCode := selectquery.FieldByName( 'deptcode' ).AsString;
      RoomInfo.DeptName := selectquery.FieldByName( 'deptname' ).AsString;
      RoomInfo.DoctorCode := selectquery.FieldByName( 'doctorcode' ).AsString;
      RoomInfo.DoctorName := selectquery.FieldByName( 'doctorname' ).AsString;

      event_300.AddRoomInfo( RoomInfo );
    finally
      selectquery.Next;
    end;
  end;
  AddMemo(event_300.EventID, event_300.JobID);
  ret := GetBridge.RequestResponse( event_300.ToJsonString );
  if ret <> '' then
  begin
    event_301 := GBridgeFactory.MakeResponseObj( ret );
    AddMemo(event_301.EventID, event_301.JobID, event_301.Code, event_301.MessageStr, 0);
    if event_301.Code = Result_Success then
      AddMemo('EventID 300 전송 성공 ')
    else
    begin
      err := event_301.MessageStr;
      FreeAndNil( event_301 );
      AddMemo('EventID 300 전송 실패 : ' + err );
      MessageDlg(err,mtError, [mbOK], 0);
    end;
    FreeAndNil( event_301 );
  end
  else
    AddMemo('EventID 300 전송 Error ');
  FreeAndNil( event_300 );
end;

procedure TChartEmulV4Form.Button3Click(Sender: TObject);
  procedure AnalysisCancelMsg( AEvent303 :  TBridgeResponse_303);
  var
    i : Integer;
    item : TCancelMsgListItem;
  begin
    ComboBox1.Items.Clear;
    for i := 0 to AEvent303.CancelMessageListCount -1 do
    begin
      item := AEvent303.CancelMessageList[ i ];
      if item.isDefault then
        ComboBox1.Text := item.MessageStr;
      ComboBox1.Items.Add( item.MessageStr );
    end;
  end;
var
  ret : string;
  err : string;
  event_302 : TBridgeRequest_302;
  event_303 : TBridgeResponse;
begin  // 취소 메시지 요청
  event_302 := TBridgeRequest_302( GBridgeFactory.MakeRequestObj( EventID_취소메시지목록요청 ) );
  try
    event_302.HospitalNo := GHospitalNo;

    AddMemo(event_302.EventID, event_302.JobID);
    ret := GetBridge.RequestResponse( event_302.ToJsonString );
    if ret <> '' then
    begin
      event_303 := GBridgeFactory.MakeResponseObj( ret );
      try
        AddMemo(event_303.EventID, event_303.JobID, event_303.Code, event_303.MessageStr, 0);
        if event_303.Code = Result_Success then
        begin
          AddMemo('EventID 302 전송 성공 ');
          AnalysisCancelMsg( TBridgeResponse_303(event_303) );
        end
        else
        begin
          err := Format('%s : %d', [event_303.MessageStr, event_303.EventID]);
          AddMemo('EventID 302 전송 실패 : ' + err );
          MessageDlg(err,mtError, [mbOK], 0);
        end;
      finally
        if Assigned(event_303) then
          FreeAndNil( event_303 );
      end;
    end;
  finally
    FreeAndNil( event_302 );
  end;
end;

procedure TChartEmulV4Form.Button4Click(Sender: TObject);
var
  jsonstr : string;
(*  jt : TGDJsonTextWriter; *)
begin
(*  jt := TGDJsonTextWriter.Create;
  jt.StartObject;
    jt.WriteValue(FN_EventID, EventID_환자조회);
    jt.WriteValue(FN_JobID, MakeJobID);
//    jt.WriteValue(FN_CellPhone, '01012345678');
    jt.WriteValue(FN_RegNum, '');
  jt.EndObject;
  jsonstr := jt.ToJsonString;
  GetBridge._AddJsonStr( jsonstr );
  FreeAndNil( jt );
*)


//  GetBridge._AddJsonStr( '{"cellphone":"01012121212","eventId":0,"jobId":"E9392BF2AC9268733C5F626965F5C3CA692C100A67E96EC3E7F354E6557AE1CD"}' );
//  GetBridge._AddJsonStr( '{"cellphone":"01011112222","eventId":0,"jobId":"B023D19CF84DC23A850069FF65FC72AFFAFD300BBFB75307B4DC4A9918E93BB8"}' );

(*jsonstr := '{"chartReceptnResultId1":"20190730105806039","chartReceptnResultId2":"","chartReceptnResultId3":"","chartReceptnResultId4":"","chartReceptnResultId5":"",';
jsonstr := jsonstr + '"chartReceptnResultId6":"",';
jsonstr := jsonstr + '"eventId":102,"hospitalNo":"23071000","jobId":"9D2C6AA3E19881D9509766CA0A419C599A63E6CFF00F017BFCECC47386288BAD",';
jsonstr := jsonstr + '"receptStatusChangeDttm":"2019-07-30T01:58:47.3059875Z"}'; *)

jsonstr := '{"chartReceptnResultId1":"20190801141352925","chartReceptnResultId2":"","chartReceptnResultId3":"","chartReceptnResultId4":"","chartReceptnResultId5":"",';
jsonstr := jsonstr + '"chartReceptnResultId6":"","eventId":202,"hospitalNo":"22714400","jobId":"1D119A924BDFC86477F9E9791F55E9BCC2F44E1BBC37C13D1E18315B8540C068",';
jsonstr := jsonstr + '"receptStatusChangeDttm":"2019-08-01T05:15:21.000Z"}';
GetBridge._AddJsonStr(jsonstr);

//  GetBridge._AddJsonStr( '{"eventId":0,"jobId":"E729EFA82A7532E8F4DFE36556059E4216C05D2E6F65DB338D4C468879178FE6","cellphone":"01001001001","salt":"10000003TPO18052118a"}' );
end;

procedure TChartEmulV4Form.Button5Click(Sender: TObject);
var
  ret : string;
  err : string;
  event_402 : TBridgeRequest_402;
  event_403 : TBridgeResponse;
begin
  event_402 := TBridgeRequest_402( GBridgeFactory.MakeRequestObj( EventID_대기열목록요청 ) );
  event_402.HospitalNo := GHospitalNo;

  AddMemo(event_402.EventID, event_402.JobID);
  ret := GetBridge.RequestResponse( event_402.ToJsonString );

  if ret <> '' then
  begin
    event_403 := GBridgeFactory.MakeResponseObj( ret );
    AddMemo(event_403.EventID, event_403.JobID, event_403.Code, event_403.MessageStr, 0);
    if event_403.Code = Result_Success then
    begin
      AddMemo('EventID 304 전송 성공 ');
      RoomMngForm.UpdateRoomInfo( TBridgeResponse_403( event_403 ) );
    end
    else
    begin
      err := event_403.MessageStr;
      AddMemo('EventID 402 전송 실패 : ' + err );
      MessageDlg(err,mtError, [mbOK], 0);
    end;
    FreeAndNil( event_403 );
  end
  else
    AddMemo('EventID 402 전송 Error ');

  FreeAndNil( event_402 );
end;

procedure TChartEmulV4Form.Button6Click(Sender: TObject);
var
  ret : string;
  err : string;
  event_400 : TBridgeRequest_400;
  event_401 : TBridgeResponse;
begin
  event_400 := TBridgeRequest_400( GBridgeFactory.MakeRequestObj( EventID_접수예약목록요청 ) );
  event_400.HospitalNo := GHospitalNo;
  event_400.StartDttm := Today;
  event_400.EndDttm := IncMilliSecond(Tomorrow, -1);
  event_400.LastChangeDttm := 0;
  event_400.ReceptnResveType := RRType_ALL;
  event_400.Offset := 1;

  AddMemo(event_400.EventID, event_400.JobID);
  ret := GetBridge.RequestResponse( event_400.ToJsonString );

  if ret <> '' then
  begin
    event_401 := GBridgeFactory.MakeResponseObj( ret );
    AddMemo(event_401.EventID, event_401.JobID, event_401.Code, event_401.MessageStr, 0);
    if event_401.Code = Result_Success then
      AddMemo('EventID 400 전송 성공 ' + ret)
    else
    begin
      err := event_401.MessageStr;
      AddMemo('EventID 400 전송 실패 : ' + err );
      MessageDlg(err,mtError, [mbOK], 0);
    end;
    FreeAndNil( event_401 );
  end
  else
    AddMemo('EventID 400 전송 Error ');

  FreeAndNil( event_400 );
end;

procedure TChartEmulV4Form.Button7Click(Sender: TObject);
var
//  i : Integer;
  jsonstr : string;
//  regnum : string;
begin
(*
  jsonstr := '{"addr":"서울특별시 강남구 도곡동","addrDetail":"11-1","brthdy":"","cellphone":"01011112222","comPurposeList":[{"purpose1":"멍"}],';
  jsonstr := jsonstr + '"deptCode":"","deptNm":"","doctrCode":"","doctrNm":"","endpoint":"T","etcPurpose":"","eventId":100,"hospitalNo":"10000003",';
  jsonstr := jsonstr + '"jobId":"1321E8E796C17624DCAC7BC1A8BBEC823D4016B2CD03A988B515821BE229589D","name":"문재인","path":"","patntChartId":"1","receptnDttm":"2019-06-17T02:27:52.280Z","regNum":"","roomCode":"101","roomNm":"진료실1","sexdstn":"","zip":""}'; *)

(*  for i := 1 to 10 do
  begin
    regnum := Format('11111111111%0.2d',[i]);
    jsonstr := '{"addr":"인천광역시 강남구 세곡동","addrDetail":"ㄹㅌㅊㅌ","brthdy":"19110101","cellphone":"01011112222","comPurposeList":[{"purpose1":"통증"}],';
    jsonstr := jsonstr + '"deptCode":"02","deptNm":"내과","doctrCode":"12312412","doctrNm":"의사2","endpoint":"T","etcPurpose":"","eventId":100,"hospitalNo":"10000003",';
    jsonstr := jsonstr + '"jobId":"37C42C53C5324B4E9620EB65C680AFB867CAD507276C20FDDA3C9326F043B8EB","name":"ㅎㄹㅌㄹㅎ","path":"집/직장 근처","patntChartId":"",';
    jsonstr := jsonstr + format('"receptnDttm":"2019-06-17T07:12:49.778Z","regNum":"%s","roomCode":"102","roomNm":"진료실2","sexdstn":"1","zip":"12346"}', [regnum]);

    GetBridge._AddJsonStr( jsonstr );
  end;
 *)

(*    jsonstr := '{"addr":null,"addrDetail":null,"brthdy":"19831026","cellphone":"01050005488",';
    jsonstr := jsonstr + '"comPurposeList":[{"purpose1":"검진/내시경","purpose2":"일반건강검진"},{"purpose1":"검진/내시경","purpose2":"위내시경"}],';
    jsonstr := jsonstr + '"deptCode":"1","deptNm":"내과","doctrCode":"123123123","doctrNm":"의사1","endpoint":"A","etcPurpose":null,"eventId":200,';
    jsonstr := jsonstr + '"hospitalNo":"23069000","jobId":"3B2378947F854D78AC47B1186FAF7AAB0496F8683C654B6BC5B937D0505DFED1","name":"김성일","path":null,';
    jsonstr := jsonstr + '"patntChartId":"P20190705103125035","receptnDttm":"2019-07-15T02:13:43.464Z","regNum":"8310261047129",';
    jsonstr := jsonstr + '"reserveDttm":"2019-07-27T01:00:00.000Z","roomCode":"101","roomNm":"진료실01","sexdstn":"1","zip":null}'; *)

(*jsonstr := '{"eventId":100,"jobId":"B1E6F15063473622B6933A7555E080E55BF89A8845F4F49846F92F1B34FE7946",';
jsonstr := jsonstr + '"hospitalNo":"23067000","patntChartId":"P20190806162808514","endpoint":"T",';
jsonstr := jsonstr + '"cellphone":"01020125023","regNum":"5001011000000","name":"aple",';
jsonstr := jsonstr + '"sexdstn":"1","brthdy":"19500101","addr":"울산광역시 중구 복산동","addrDetail":"test",';
jsonstr := jsonstr + '"zip":"","path":null,"roomCode":"101","roomNm":"진료실1","deptCode":"02","deptNm":"내과",';
jsonstr := jsonstr + '"doctrCode":"12314512","doctrNm":"의사1","salt":"23067000TTC1809A123B0564","comPurposeList":[],';
jsonstr := jsonstr + '"etcPurpose":"어지러워요","receptnDttm":"2019-08-21T01:41:51.506Z"}';*)


(*jsonstr := '{"chartReceptnResultId1":"20191105155311247","chartReceptnResultId2":"","chartReceptnResultId3":"","chartReceptnResultId4":"","chartReceptnResultId5":"","chartReceptnResultId6":"",';
jsonstr := jsonstr + '"eventId":352,';
jsonstr := jsonstr + '"extraInfo":"\"https://staging.goodoc.co.kr/hospitals\"/228001",';
jsonstr := jsonstr + '"gdid":"6SQJPAzzoPT12X70Z/dJJ5cPIwqCNyBiG//JA0Ewpv/XOGJKoAXpyMdrXE/Rqp2IzffhJYpOKTieb2GHG5J/dQ==",';
jsonstr := jsonstr + '"hipass":9,';
jsonstr := jsonstr + '"hospitalNo":"22802700",';
jsonstr := jsonstr + '"jobId":"F093282D13915310C5404650BF613BB85DD0560C89DC5A897319242B05D6D307","parmNm":"굿닥Aple2약국","parmNo":"22800100","prescription":1}'; *)

(*jsonstr := '{"addr":"","addrDetail":"","brthdy":"19831026","cellphone":"01050005488","comPurposeList":[{"purpose1":"검진/내시경","purpose2":"암검진"},';
jsonstr := jsonstr + '{"purpose1":"검진/내시경","purpose2":"대장내시경"}],"deptCode":"14","deptNm":"가정의학과","doctrCode":"Doc001","doctrNm":"의사1","endpoint":"A","etcPurpose":null,"eventId":200,';
jsonstr := jsonstr + '"gdid":null,"hospitalNo":"80000012","jobId":"D3CE3A909BBB915D8873A82EFDF8E9A0E5A89193E36705AA2CB36BA5217AA2AE","name":"김성일","path":null,';
jsonstr := jsonstr + '"patntChartId":"P20191211181123069","receptnDttm":"2019-12-13T08:35:48.738Z","regNum":"8310261047129","reserveDttm":"2019-12-16T13:20:00.000Z",';
jsonstr := jsonstr + '"roomCode":"R001","roomNm":"진료실1","sexdstn":"1","zip":null}';
*)

jsonstr := '{"confirmList":[';
jsonstr := jsonstr + '{"chartReceptnResultId1":"20200325115601504","chartReceptnResultId2":"","chartReceptnResultId3":"","chartReceptnResultId4":"","chartReceptnResultId5":"","chartReceptnResultId6":"",';
jsonstr := jsonstr + '"receptnResveId":"20BE5C1D18ED22043F7F07FA26292713655863A7D420E3E521209A6EAD03F595","type":0}],"eventId":110,';
jsonstr := jsonstr + '"hospitalNo":"22806300","jobId":"ad658f09-6558-4405-b0c5-defcb17aba82","reclnicOnly":1}';


    GetBridge._AddJsonStr( jsonstr );


  AddMemo( '내원확인' );
end;

procedure TChartEmulV4Form.Button8Click(Sender: TObject);
var
  ret : Integer;
  dtype : TMsgDlgType;
  str : string;
begin
  ret := GetBridge.init(GHospitalNo, GChartCode);

  LabeledEdit1.Text := GetBridge.GetBridgeID;

  Button8.Enabled := ret <> Result_Success;
  dtype := mtError;
  if ret = Result_Success then
    dtype := mtInformation;

  str := GetBridge.GetErrorMsg( ret );
  //MessageDlg(format('Init : %s(%d)',[str, ret]), dtype, [mbOK], 0);
  AddMemo( format('Init %s: %s(%d)',[ ifthen(dtype = mtInformation, '', 'Error ' ), str, ret]) );

{$ifdef _EP_}
  if Button9.Enabled then
  begin
    if not Button8.Enabled then
      Button9.Click;
  end;
{$endif}

  if ret = Result_Success then
  begin // 미전송 목록 요청
    Send308;

    AccountDM.init결제;
    if AccountDM.Active then
      Label2.Caption := '결제 사용 병원이다.'
    else
      Label2.Caption := '결제 사용 병원이 아니다.';

    // event 300, 진료실 목록 전송
    Button2.Click;
  end;
end;

procedure TChartEmulV4Form.Button9Click(Sender: TObject);
var
  jsonstr, ret : string;
  err : string;

  event_350 : TBridgeRequest_350;
  event_351 : TBridgeResponse;
begin
  if Button8.Enabled then
  begin
    MessageDlg('Bridge를 초기화 후 사용하세요!', mtWarning, [mbOK], 0);
    exit;
  end;

  event_350 := TBridgeRequest_350( GBridgeFactory.MakeRequestObj( EventID_전자처방전병원조회 ) );
  event_350.HospitalNo := GHospitalNo;

  jsonstr := event_350.ToJsonString;
  AddMemo(event_350.EventID, event_350.JobID);
  ret := GetBridge.RequestResponse( jsonstr );
  GElectronicPrescriptionsOption := 0;
  if ret <> '' then
  begin
    event_351 := GBridgeFactory.MakeResponseObj( ret );
    if event_351.Code = Result_Success then
    begin // 성공
      with TBridgeResponse_351( event_351 ) do
        GElectronicPrescriptionsOption := Prescription;
    end
    else
    begin
      err := event_351.MessageStr;
      AddMemo('EventID 350 전송 실패 : ' + err );
      MessageDlg(err,mtError, [mbOK], 0);
    end;
    FreeAndNil( event_351 );
  end;
  FreeAndNil( event_350 );

  Label1.Caption := ifthen(GElectronicPrescriptionsOption=1, '전자처방전 사용 병원', '전자처방전 미사용 병원');
end;

constructor TChartEmulV4Form.Create(AOwner: TComponent);
begin
  inherited;
  FRoomListTmp := TStringList.Create;

{$ifdef _EP_}
  Button9.Enabled := True;
  Label1.Enabled := True;
{$else}
  Button9.Enabled := False;
  Label1.Enabled := False;
{$endif}
  GSendReceptionPeriod := False;
  GBridgeFactory := TepBridgeFactory.Create;
  with GetBridge do
  begin
    OnBridgePollingData := BridgePollingData;
    OnBridgeLogNodify := BridgeLogNodify;
  end;
end;

destructor TChartEmulV4Form.Destroy;
begin
  FreeAndNil( GBridgeFactory );
  FreeAndNil( FRoomListTmp );
  inherited;
end;

procedure TChartEmulV4Form.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  GetBridge.DeInit;
end;

procedure TChartEmulV4Form.FormShow(Sender: TObject);
begin
  LoadEnv;
  HospitalNo_edit.Text := GHospitalNo;
  HospitalNo_edit.Modified := False;
  chartcode_edit.Text := IntToStr( GChartCode );
  chartcode_edit.Modified := False;

  DBDM.DBConnected := True;

  initUI;

  PageControl1.TabIndex := 0;
  PageControl1.OnChange( PageControl1 );

  Timer1.Enabled := True;
  HeartbeatTimer.Enabled := True; // V3-27

  ShowUseServerType;
  ShowChangeServerButton;
end;

(*
V3-27
*)
procedure TChartEmulV4Form.OnTimerHeartbeatTimer(Sender: TObject);
var
  isConnected: boolean;
begin
  isConnected := GetBridge.IsConnectionAlive;
  if isConnected then
  begin
    ConnectionState.Color := clGreen;
    ConnectionState.Caption := 'ON';
  end
  else
  begin
    ConnectionState.Color := clRed;
    ConnectionState.Caption := 'OFF';
  end;
  //AddMemo('Websocket: ' + isConnected.ToString);
end;

procedure TChartEmulV4Form.initUI;
begin
  PatientMngForm.ChangeUI( TabSheet1 );
  ReceptionMngForm.ChangeUI( TabSheet2 );
  ReservationMngForm.ChangeUI( TabSheet3 );
  RoomMngForm.ChangeUI( TabSheet4 );
  ReservationScheduleSendForm.ChangeUI(TabSheet6);
  PatientStateAutomationForm.ChangeUI(TabSheet7);
end;

procedure TChartEmulV4Form.Memo1Click(Sender: TObject);
  function GetPrettyJson(Memo : TMemo) : string;
  const
    sLineBreak = chr(13)+chr(10);
    sTab = chr(9);
  var
    I, I2, Line, BlockLength, Indent, SIdx : integer;
    C : Char;
  begin
    with Memo do
    begin
      Lines.BeginUpdate;
      Line := Perform(EM_LINEFROMCHAR, SelStart, 0);
      SelStart := Perform(EM_LINEINDEX, Line, 0);
      SelLength := 0;
      // TMemo가 1024자까지만 한 줄로 표현가능하므로 복수라인까지 선택하도록 함
      for I := Line to Lines.Count do
      begin
        BlockLength := Length(Lines[I]);
        SelLength := SelLength + BlockLength;
        if BlockLength < 1024 then
          break;
      end;
      Lines.EndUpdate;

      SIdx := SelText.IndexOf('{');
      if SIdx = -1 then
        exit('JSON 형식을 찾지 못했습니다.');

      Result := '';
      Indent := 0;
      for I := SIdx to SelText.Length - 1 do
      begin
        C := SelText.Chars[I];
        if C = '{' then
        begin
          Result := Result + C + sLineBreak;
          Indent := Indent + 1;

          for I2 := 1 to Indent do
            Result := Result + sTab;
        end
        else if C = ',' then
        begin
          Result := Result + C + sLineBreak;

          for I2 := 1 to Indent do
            Result := Result + sTab;
        end
        else if C = '}' then
        begin
          Result := Result + sLineBreak;
          Indent := Indent - 1;

          for I2 := 1 to Indent do
            Result := Result + sTab;
          Result := Result + C;
        end
        else
        begin
          Result := Result + C;
        end;
      end;

    end;
  end;

begin
  Memo2.Lines.Clear;
  Memo2.Lines.BeginUpdate;
  Memo2.Lines.Add(GetPrettyJson(Memo1));
  Memo2.Lines.EndUpdate;
end;

procedure TChartEmulV4Form.PageControl1Change(Sender: TObject);
begin
  case PageControl1.TabIndex of
    0 : PatientMngForm.DBRefresh;
    1 : ReceptionMngForm.DBRefresh;
    2 : ReservationMngForm.DBRefresh;
    3 : RoomMngForm.DBRefresh;
    5 : ReservationScheduleSendForm.Refresh;
    6 : PatientStateAutomationForm.Refresh;
  end;
end;

procedure TChartEmulV4Form.saveenv_btnClick(Sender: TObject);
begin
  if HospitalNo_edit.Modified then
    GHospitalNo := HospitalNo_edit.Text;
  if chartcode_edit.Modified then
    GChartCode := StrToIntDef(chartcode_edit.Text, GChartCode);

  SaveEnv;
  HospitalNo_edit.Modified := False;
  chartcode_edit.Modified := False;
end;

procedure TChartEmulV4Form.Send308;
// 미전송 목록 요청
var
  isEOF : Boolean;
  nosend308 : Boolean;
  i, offset : Integer;
  resultcode : Integer;
  ret, err, pid : string;
  send306 : TBridgeRequest_306;
  event_307 : TBridgeResponse_307;
  send308 : TBridgeRequest_308;
  data307 : TData307;
  event_309 : TBridgeResponse_309;
begin
  nosend308 := False;
  send308 := TBridgeRequest_308( GBridgeFactory.MakeRequestObj( EventID_미전송목록요청결과전송 ) );
  try
    isEOF := False;
    offset := 0;
    while not isEOF do
    begin
      send306 := TBridgeRequest_306( GBridgeFactory.MakeRequestObj( EventID_미전송목록요청 ) );
      try
        send306.hospitalNo := GHospitalNo;
        send306.offset := offset;
        AddMemo(send306.EventID, send306.JobID);
        ret := GetBridge.RequestResponse( send306.ToJsonString );

        if ret <> '' then
        begin
          event_307 := TBridgeResponse_307( GBridgeFactory.MakeResponseObj( ret ) );
          AddMemo(event_307.EventID, event_307.JobID, event_307.Code, event_307.MessageStr, 0);
          if event_307.Code = Result_Success then
          begin
            // 처리할 data 누적
            for i := 0 to event_307.DataListCount-1 do
            begin
              nosend308 := True;
              data307 := event_307.DataList[i];
              case data307.EventID of
                EventID_접수요청 :
                  ReceptionMngForm.AddReception( data307, pid, resultcode);
                EventID_접수취소 :
                  ReceptionMngForm.CancelReception( data307, pid, resultcode );
                EventID_예약요청 :
                  ReservationMngForm.AddReservation( data307, pid, resultcode);
                EventID_예약취소 :
                  ReservationMngForm.CancelReservation( data307, pid, resultcode );
              end;
              if resultcode = Result_SuccessCode then
              begin  // 성공한 data만 등록 처리 한다.
                send308.Add(
                        data307.chartReceptnResultId.Id1,
                        data307.chartReceptnResultId.Id2,
                        data307.chartReceptnResultId.Id3,
                        data307.chartReceptnResultId.Id4,
                        data307.chartReceptnResultId.Id5,
                        data307.chartReceptnResultId.Id6,
                        data307.receptnResveId,
                        pid
                      );
              end;
            end; // for문

            offset := event_307.CurrentOffset + event_307.DataListCount;
            isEOF := offset >= event_307.Total; // eof가 true이면 모든 data를 다 받았다.
          end
          else
          begin
            isEOF := True;
            err := event_307.MessageStr;
            FreeAndNil( event_307 );
            AddMemo('EventID 306 전송 실패 : ' + err );
          end;
          FreeAndNil( event_307 );
        end
        else
        begin
          isEOF := True;
          AddMemo('EventID 306 전송 Error ');
        end;
      finally
        FreeAndNil( send306 );
      end;
    end;

    if nosend308 then
    begin
      send308.hospitalNo := GHospitalNo;

      AddMemo(send308.EventID, send308.JobID);
      ret := GetBridge.RequestResponse( send308.ToJsonString );
      event_309 := TBridgeResponse_309( GBridgeFactory.MakeResponseObj( ret ) );
      try
        AddMemo(event_309.EventID, event_309.JobID, event_309.Code, event_309.MessageStr, 0);
      finally
        FreeAndNil( event_309 );
      end;
    end;
  finally
    FreeAndNil( send308 );
  end;
end;

procedure TChartEmulV4Form.ShowUseServerType;
var
  stype : Integer;
  str : string;
  reg : TRegistry;
begin
  reg := TRegistry.Create( KEY_READ or KEY_WOW64_64KEY );
  try
    reg.RootKey := HKEY_CURRENT_USER;
    reg.OpenKey( 'Software\goodoc_v40', True );

    stype := 2;

    if reg.ValueExists('servertype') then
    begin // 해당 key가 없다.
      stype := reg.ReadInteger('servertype');
    end;

    case stype of
      0 : str := 'DEV';
      1 : str := 'RC';
      2 : str := 'STG';
    else // 0, 1 이외에는 모두 product로 인지 하게 한다.
      str := 'PROD';
    end;
    //0: 개발 , 1: 스테이징, 2: 프러덕트, 없으면 프러덕트

    Caption := Caption + ' - ' + str;
  finally
    FreeAndNil( reg );
  end;
end;

procedure TChartEmulV4Form.ShowChangeServerButton;
var
  stype : Integer;
  reg : TRegistry;
begin
  reg := TRegistry.Create( KEY_READ or KEY_WOW64_64KEY );
  try
    reg.RootKey := HKEY_CURRENT_USER;
    reg.OpenKey( 'Software\goodoc_v40', True );

    stype := 3;

    if reg.ValueExists('servertype') then
    begin // 해당 key가 없다.
      stype := reg.ReadInteger('servertype');
    end;

    Button11.Visible := (stype = 0)
  finally
    FreeAndNil( reg );
  end;
end;

procedure TChartEmulV4Form.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  Button8.Click;
end;

procedure TChartEmulV4Form.Timer2Timer(Sender: TObject);
begin
  Timer2.Enabled := False;
  ReceptionMngForm.SendPeriod(now, GSendReceptionPeriodRoomInfo);
end;

end.
