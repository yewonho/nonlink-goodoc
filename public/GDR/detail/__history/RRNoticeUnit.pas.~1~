unit RRNoticeUnit;
(*
  당일 예약/접수 요청 미처리 건수 알림 form
*)
interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, SakpungImageButton, Vcl.ExtCtrls,
  CapPaintPanel, ImageResourceDMUnit, Vcl.StdCtrls;

type
  TRRNoticeForm = class(TForm)
    Panel1: TCapPaintPanel;
    Image1: TImage;
    close_btn: TSakpungImageButton2;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    Timer1: TTimer;
    procedure FormShow(Sender: TObject);
    procedure close_btnClick(Sender: TObject);
    procedure Panel1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    FLastShowTime : string; // 1200, 1230  형식으로 저장됨
    // 출력대상 시간이면 true 그렇지 않으면 false을 반환 한다.  출력 대상 시간은 00분 30분 이다.
    function CheckShowTime( var AShowTime : string ) : Boolean;
  protected
    { protected declarations }
    procedure CreateParams( var AParams : TCreateParams ); override;
  public
    { Public declarations }
    procedure ShowCount( AReceptionCount, AReservationCount : integer );
  end;

var
  RRNoticeForm: TRRNoticeForm;

function GetRRNoticeForm : TRRNoticeForm;
procedure ShowRRNoticeForm( AReceptionCount, AReservationCount : integer );
procedure CloseRRNoticeForm;
procedure FreeRRNoticeForm;

implementation
uses
  GDLog;

var
  GRRNoticeForm : TRRNoticeForm;

function GetRRNoticeForm : TRRNoticeForm;
begin
  if not Assigned( GRRNoticeForm ) then
    GRRNoticeForm := TRRNoticeForm.Create( nil );
  Result := GRRNoticeForm;
end;
procedure ShowRRNoticeForm( AReceptionCount, AReservationCount : integer );
begin
  GetRRNoticeForm.ShowCount( AReceptionCount, AReservationCount );
end;
procedure CloseRRNoticeForm;
begin
  if Assigned( GRRNoticeForm ) then
  begin
    if GRRNoticeForm.Showing then
      GRRNoticeForm.Close;
  end;
end;
procedure FreeRRNoticeForm;
begin
  if Assigned( GRRNoticeForm ) then
    FreeAndNil( GRRNoticeForm );
end;

{$R *.dfm}

function TRRNoticeForm.CheckShowTime(var AShowTime: string): Boolean;
// 출력대상 시간이면 true 그렇지 않으면 false을 반환 한다.  출력 대상 시간은 00분 30분 이다.
var
  nowtime : string;
  a : TDateTime;
begin
  a := now;
  AShowTime := FormatDateTime('hhnn', a);  // 시분
  nowtime := FormatDateTime('nn', a);  // 분

  Result := (nowtime = '00') or (nowtime = '30'); // 정각 or 30 분일 경우 true를 반환 한다.
end;

procedure TRRNoticeForm.close_btnClick(Sender: TObject);
begin
  Close;
end;

procedure TRRNoticeForm.CreateParams(var AParams: TCreateParams);
begin
  inherited;

  AParams.Style := AParams.Style or WS_BORDER or WS_THICKFRAME;  // bsnone

  AParams.WndParent := Application.MainFormHandle;
end;

procedure TRRNoticeForm.FormShow(Sender: TObject);
begin
  close_btn.PngImageList := ImageResourceDM.WindowButtonImageList;
  ImageResourceDM.SetButtonImage(close_btn, aibtButton1, BTN_Img_Win_Close);
end;

procedure TRRNoticeForm.Panel1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
const
  SC_DragMove = $F012;  { a magic number }
begin
  ReleaseCapture;
  self.perform(WM_SysCommand, SC_DragMove, 0);
end;

procedure TRRNoticeForm.ShowCount(AReceptionCount, AReservationCount: integer);
var
  nt : string;
begin
  if not Showing then
  begin // 출력 여부 확인
    if not CheckShowTime(nt) then
      exit; // 정각, 30분이 아니다.  출력하지 않는다.

    if FLastShowTime = nt then
      exit; // 이미 출력 했다.

    FLastShowTime := nt; // 출력 해야 한다.
  end;
  // 이미 출력되어 있는 상태라면 변경된 data를 출력 한다.

  // 예약 요청
  Edit1.Text := IntToStr( AReservationCount );
  if AReservationCount = 0 then
    Edit1.Font.Color := clBlack
  else
    Edit1.Font.Color := clRed;

  // 접수 요청
  Edit2.Text := IntToStr( AReceptionCount );
  if AReceptionCount = 0 then
    Edit2.Font.Color := clBlack
  else
    Edit2.Font.Color := clRed;

  if not Showing then
  begin
    Application.MainForm.BringToFront;
    Timer1.Enabled := True;
  end;
end;

procedure TRRNoticeForm.Timer1Timer(Sender: TObject);
var
  rect : TRect;
begin
  Timer1.Enabled := False;

  if not Assigned( Application.MainForm ) then
    exit;

  //FormStyle := Application.MainForm.FormStyle;
  FormStyle := fsStayOnTop;

  rect := Application.MainForm.BoundsRect;  // main form 전체에 표시

  rect.Left := rect.Right - Width;
  rect.Top := rect.Bottom - Height;

  BoundsRect := rect;

  Show;
  AddLog(doRunLog, format('Nofity form 출력 Count : Time:%s 접수:%s, 예약:%s',[FLastShowTime, Edit2.Text, Edit1.Text]) );
  BringToFront;
end;

initialization
  GRRNoticeForm := nil;
  GetRRNoticeForm;

finalization
  CloseRRNoticeForm;
  FreeRRNoticeForm;

end.
