unit PatientStateAutomationUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  DBDMUnit, BridgeCommUnit, GlobalUnit, Vcl.ExtCtrls, Vcl.StdCtrls, IdWebSocketSimpleClient,
  Vcl.Grids, Vcl.ValEdit, System.JSON.Types, json, System.json.Writers;

type
  TPatientStateAutomationForm = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    Edit1: TEdit;
    Label2: TLabel;
    Edit2: TEdit;
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
    FConnected : Boolean;
    FWSClient : TIdSimpleWebSocketClient;

    procedure OnDataEvent( ASender : TObject; const AText : string );
    procedure OnConnectionDataEvent( ASender :TObject; const AText : string );
    procedure OnError( ASender : TObject; AException : Exception; const AText : string; var AForceDisconnect);
    procedure OnHeartBeatTimer( ASender : TObject );

    procedure SetButtonCaption;

  published


  public
    { Public declarations }
    procedure ChangeUI( AParentCtrl : TWinControl );
    procedure Refresh;

    procedure Connect( URL, uniqueId : string );
    procedure Disconnect;

    property Connected : Boolean read FConnected write FConnected;
    property WSClient : TIdSimpleWebSocketClient read FWSClient write FWSClient;
  end;

  TAutomationRequest = (UNKNOWN, CHANGE_STATUS, DELETE);
  {$SCOPEDENUMS OFF}

const
  URL = 'ws://3.35.170.97:8080/websocket';

var
  PatientStateAutomationForm: TPatientStateAutomationForm;

implementation
uses
  System.UITypes, math, strutils,
  GDLog, GDBridge, GDJson, dateutils,
  RoomListDialogUnit, ChartEmul_v4Unit,
  PatientMngUnit, ElectronicPrescriptionsDefaultUnit, ReservationMngUnit, RoomMngUnit,
  AccountDMUnit, AccountRequestUnit, ReceptionIDChangeUnit, ReceptionMngUnit;

{$R *.dfm}

procedure TPatientStateAutomationForm.Button1Click(Sender: TObject);
var
  url : string;
  uniqueId : string;
begin
  //url := Edit1.Text + '?uniqueId=' + Edit2.Text;
  url := Edit1.Text;
  uniqueId := Edit2.Text;

  if Connected then
  begin
    Disconnect;
  end
  else
  begin
    Connect(url, uniqueId);
  end;
end;

procedure TPatientStateAutomationForm.SetButtonCaption;
begin
  if Connected then
    Button1.Caption := '연결끊기'
  else
    Button1.Caption := '연결';
end;

procedure TPatientStateAutomationForm.Button2Click(Sender: TObject);
var
  data : TJSONObject;
begin
  if Connected then
  begin
    data := TJSONObject.Create;
    data.AddPair('chartReceptnResultId1', '99999');
    data.AddPair('status', 'F05');
    data.AddPair('message', 'aa');

    try
      WSClient.writeText(data.ToJSON);
    except
      ChartEmulV4Form.AddMemo('Websocket Connection closed gracefully by Server.');
      Disconnect;
    end;

  end;
end;

procedure TPatientStateAutomationForm.ChangeUI(AParentCtrl: TWinControl);
begin
  if Assigned( AParentCtrl ) then
  begin
    Panel1.Parent := AParentCtrl;
    Panel1.Align := alClient;
  end
  else
    Panel1.Parent := Self;
end;

procedure TPatientStateAutomationForm.Refresh;
  procedure ResetUrl;
  begin
    Edit1.Text := URL;
  end;

  procedure ResetParameter;
  begin
    Edit2.Text := GetBridge.GetBridgeID;
  end;

begin
  ResetUrl;
  ResetParameter;
  SetButtonCaption;
end;

procedure TPatientStateAutomationForm.Connect(URL, uniqueId : string);
begin
  if Assigned(WSClient) then
  begin
    WSClient.Close;
    WSClient.CleanupInstance;
  end;

  WSClient := TIdSimpleWebSocketClient.Create(self);
  WSClient.onDataEvent       := self.OnDataEvent;  //TSWSCDataEvent
  WSClient.onConnectionDataEvent := self.OnConnectionDataEvent;
  WSClient.onError := self.OnError;
  WSClient.onHeartBeatTimer := self.OnHeartBeatTimer;
  WSClient.AutoCreateHandler := False; //you can set this as true in the majority of Websockets with ssl

  ChartEmulV4Form.AddMemo('Connecting to... ' + URL);

  WSClient.Connect(URL, uniqueId);
  //WSClient.writeText('ECHO TEST');

  Connected := WSClient.Connected;

  SetButtonCaption;

  if Connected then
    ChartEmulV4Form.AddMemo('WebSocket Connection is established.')
  else
    ChartEmulV4Form.AddMemo('WebSocket Connection is failed.');

end;

procedure TPatientStateAutomationForm.OnDataEvent(ASender: TObject; const AText: string);
  procedure ResponseChangeStatus(ASuccess : Boolean; AChartReceptionResultId1 : string);
  var
    res : TJSONObject;
  begin
    res := TJSONObject.Create;
    res.AddPair('chartReceptnResultId1', AChartReceptionResultId1);
    if ASuccess then
    begin
      res.AddPair('message', 'success');
    end
    else
    begin
      res.AddPair('error_code', '1');
      ChartEmulV4Form.AddMemo('상태변경에 실패하였습니다. 올바른 환자ID와 상태코드인지 확인해주세요.');
    end;

    if Connected then
    begin
      try
        WSClient.writeText(res.ToJSON);
        ChartEmulV4Form.AddMemo('환자상태변경 결과(Response to Server: ' + res.ToJSON + ')');
      except
        ChartEmulV4Form.AddMemo('Websocket Connection closed gracefully by Server.');
        Disconnect;
      end;
    end;

  end;

  procedure ResponseDelete(ASuccess : Boolean; AChartId : string);
  var
    res : TJSONObject;
  begin
    res := TJSONObject.Create;
    res.AddPair('patnt_id', AChartId);
    if ASuccess then
    begin
      res.AddPair('message', 'success');
    end
    else
    begin
      res.AddPair('error_code', '1');
      ChartEmulV4Form.AddMemo('환자삭제에 실패하였습니다. 일치하는 환자가 없거나 처리중인 접수/예약 내역이 있을 수 있습니다.');
    end;

    if Connected then
    begin
      try
        WSClient.writeText(res.ToJSON);
        ChartEmulV4Form.AddMemo('환자삭제 결과(Response to Server: ' + res.ToJSON + ')');
      except
        ChartEmulV4Form.AddMemo('Websocket Connection closed gracefully by Server.');
        Disconnect;
      end;
    end;

  end;

var
  data : TJSONObject;

  patntId : string;
  chartReceptnResultId1 : string;
  status : string;
  errorCode : integer;
  message : string;

  requestType : TAutomationRequest;

  updateResult : Boolean;
begin
  //ChartEmulV4Form.AddMemo(AText);
  // ignore '[WebSocket' , '"[WebSocket'
  if (CompareStr(AText.Substring(0, 10), '[WebSocket') = 0)
  or (CompareStr(AText.Substring(1, 10), '[WebSocket') = 0) then
  begin
    ChartEmulV4Form.AddMemo(AText);
    exit;
  end;

  // ignore 'pong'
  if (CompareStr(ReplaceStr(AText, '"', ''), 'pong') = 0) then
  begin
    //ChartEmulV4Form.AddMemo(AText);
    exit;
  end;

  data := ParseingGDJson(AText);
  //data := ParseingGDJson('{"chartReceptnResultId1":"20210623111019070","status":"F02","message":"진료차례요청"}');

  if not data.TryGetValue('patnt_id', patntId)
      or not data.TryGetValue('chartReceptnResultId1', chartReceptnResultId1)
      or not data.TryGetValue('status', status)
      or not data.TryGetValue('error_code', errorCode)
      or not data.TryGetValue('message', message)
      or string.Equals(message, 'error') then
  begin
    ChartEmulV4Form.AddMemo('잘못된 접수/예약 환자 상태변경 요청: ' + AText);
    exit;
  end;

  if not string.IsNullOrEmpty(chartReceptnResultId1) and not string.IsNullOrEmpty(status) then
    requestType := TAutomationRequest.CHANGE_STATUS
  else if not string.IsNullOrEmpty(patntId) then
    requestType := TAutomationRequest.DELETE
  else
    requestType := TAutomationRequest.UNKNOWN;

  case requestType of
    UNKNOWN:
      begin
        exit;
      end;
    CHANGE_STATUS:
      begin
        ChartEmulV4Form.AddMemo('환자상태변경 요청(Request from Server: ' + AText + ')');
        updateResult := ReceptionMngForm.UpdatePatientStateByAutomation(chartReceptnResultId1, status);
        ResponseChangeStatus(updateResult, chartReceptnResultId1);
      end;
    DELETE:
      begin
        ChartEmulV4Form.AddMemo('환자삭제 요청(Request from Server: ' + AText + ')');
        updateResult := PatientMngForm.DeletePatientByAutomation(patntId);
        ResponseDelete(updateResult, patntId);
      end;
  end;

end;

procedure TPatientStateAutomationForm.OnConnectionDataEvent(ASender: TObject; const AText: string);
begin
  // for debug
  //ChartEmulV4Form.AddMemo(AText);
end;

procedure TPatientStateAutomationForm.Disconnect;
begin
  if not Assigned(WSClient) then
    exit;

  WSClient.Close;

  Connected := WSClient.Connected;

  SetButtonCaption;

  ChartEmulV4Form.AddMemo('WebSocket Connection is closed.');
end;

procedure TPatientStateAutomationForm.OnError(ASender: TObject; AException : Exception; const AText: string; var AForceDisconnect);
begin
  ChartEmulV4Form.AddMemo('WebSocket Connection raise error([' + AException.ToString + ']:' + AText + ')');
  Disconnect;
end;

procedure TPatientStateAutomationForm.OnHeartBeatTimer(ASender: TObject);
begin
  if not Assigned(WSClient) then
    exit;

  if not WSClient.Connected then
    exit;

  WSClient.writeText('ping');

end;

end.
