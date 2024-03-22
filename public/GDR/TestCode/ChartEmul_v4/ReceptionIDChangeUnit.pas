unit ReceptionIDChangeUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Grids,
  Vcl.ValEdit,
  BridgeCommUnit;

type
  TReceptionIDChangeForm = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    Panel2: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    procedure FormShow(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    function Send108 : integer;
  public
    { Public declarations }
    StatusCode : string;
    RoomInfoRecord : TRoomInfoRecord;
    oldchartReceptnResultId, newchartReceptnResultId : TChartReceptnResultId;
  end;

var
  ReceptionIDChangeForm: TReceptionIDChangeForm;

implementation
uses
  System.UITypes,
  GlobalUnit, GDBridge, ChartEmul_v4Unit;

{$R *.dfm}

procedure TReceptionIDChangeForm.Button1Click(Sender: TObject);
begin
  if oldchartReceptnResultId.Id1 = Edit2.Text then
  begin
    MessageDlg('변경할 접수 ID를 입력 하세요!', mtWarning, [mbOK], 0);
    Edit2.SetFocus;
    exit;
  end;

  newchartReceptnResultId.Id1 := Edit2.Text;

  if Send108 = Result_SuccessCode then
    ModalResult := mrOk;
end;

procedure TReceptionIDChangeForm.Button2Click(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TReceptionIDChangeForm.FormShow(Sender: TObject);
begin
  Edit1.Text := oldchartReceptnResultId.Id1;
  Edit2.Text := '';
  edit2.SetFocus;
  newchartReceptnResultId := oldchartReceptnResultId;
end;

function TReceptionIDChangeForm.Send108: integer;
var
  event_108 : TBridgeRequest_108;
  responsebase : TBridgeResponse;
  ret : string;
begin
  event_108 := TBridgeRequest_108( GBridgeFactory.MakeRequestObj( EventID_대기열상태값변경 ) );
  event_108.HospitalNo := GHospitalNo;
  event_108.ReceptionUpdateDto.chartReceptnResultId.Id1 := oldchartReceptnResultId.Id1;
  event_108.ReceptionUpdateDto.chartReceptnResultId.Id2 := oldchartReceptnResultId.Id2;
  event_108.ReceptionUpdateDto.chartReceptnResultId.Id3 := oldchartReceptnResultId.Id3;
  event_108.ReceptionUpdateDto.chartReceptnResultId.Id4 := oldchartReceptnResultId.Id4;
  event_108.ReceptionUpdateDto.chartReceptnResultId.Id5 := oldchartReceptnResultId.Id5;
  event_108.ReceptionUpdateDto.chartReceptnResultId.Id4 := oldchartReceptnResultId.Id6;

  event_108.ReceptionUpdateDto.RoomInfo.RoomCode := RoomInfoRecord.RoomCode;
  event_108.ReceptionUpdateDto.RoomInfo.RoomName := RoomInfoRecord.RoomName;
  event_108.ReceptionUpdateDto.RoomInfo.DeptCode := RoomInfoRecord.DeptCode;
  event_108.ReceptionUpdateDto.RoomInfo.DeptName := RoomInfoRecord.DeptName;
  event_108.ReceptionUpdateDto.RoomInfo.DoctorCode := RoomInfoRecord.DoctorCode;
  event_108.ReceptionUpdateDto.RoomInfo.DoctorName := RoomInfoRecord.DoctorName;
  event_108.ReceptionUpdateDto.Status   := StatusCode;
  event_108.receptStatusChangeDttm     := now;

  event_108.NewchartReceptnResult.Id1 := newchartReceptnResultId.Id1;  // 접수된 정보를 등록
  event_108.NewchartReceptnResult.Id2 := newchartReceptnResultId.Id2;
  event_108.NewchartReceptnResult.Id3 := newchartReceptnResultId.Id3;
  event_108.NewchartReceptnResult.Id4 := newchartReceptnResultId.Id4;
  event_108.NewchartReceptnResult.Id5 := newchartReceptnResultId.Id5;
  event_108.NewchartReceptnResult.Id6 := newchartReceptnResultId.Id6;

  ChartEmulV4Form.AddMemo( event_108.EventID, event_108.JobID );
  ret := GetBridge.RequestResponse( event_108.ToJsonString );
  responsebase := GBridgeFactory.MakeResponseObj( ret );
  ChartEmulV4Form.AddMemo( responsebase.EventID, responsebase.JobID, responsebase.Code, responsebase.MessageStr, 0 );
  Result := responsebase.Code;

  if Result <> Result_SuccessCode then
    MessageDlg(responsebase.MessageStr, mtError, [mbOK], 0);
  FreeAndNil( responsebase );

  FreeAndNil( event_108 );
end;

end.
