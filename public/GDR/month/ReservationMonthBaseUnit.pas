unit ReservationMonthBaseUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  RRObserverUnit;

type
  TReservationMonthBaseForm = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    BottomPanel: TPanel;
    Splitter1: TSplitter;
    TopPanel: TPanel;
    ResizeTimer: TTimer;
    procedure ResizeTimerTimer(Sender: TObject);
  private
    { Private declarations }
    isFirstResize : Boolean;
    procedure ExpandCollapse( AActionCode : Cardinal; AUIInit : Boolean = False ); // 접었다 폈다, AUIInit이 true이면 설정된 값으로 화면을 갱신하게 한다.
  private
    { Private declarations }
    FObserver : TRRObserver;
    procedure BeforeEventNotify( AEventID : Cardinal; AData : TObserverData );
    procedure AfterEventNotify( AEventID : Cardinal; AData : TObserverData );
  public
    { Public declarations }
    constructor Create( AOwner : TComponent ); override;
    destructor Destroy; override;

    procedure ShowPanel( AParentControl : TWinControl );

    // 지정된 월의 data를 읽을 수 있게 한다.
    procedure GetMonthData;
  end;

function GetReservationMonthBaseForm : TReservationMonthBaseForm;
procedure ShowReservationMonthBaseForm;
procedure UnvisibleReservationMonthBaseForm;
procedure FreeReservationMonthBaseForm;

implementation
uses
  GDLog, SakpungImageButton,
  EventIDConst, RREnvUnit,
  ReservationMonthUnit, ReservationMonthListUnit, ReservationRequestMonthListUnit;

const
  // HeaderHeight = 36;
  HeaderHeight = 30;

var
  GReservationMonthBaseForm: TReservationMonthBaseForm;


{$R *.dfm}

function GetReservationMonthBaseForm : TReservationMonthBaseForm;
begin
  if not Assigned( GReservationMonthBaseForm ) then
    GReservationMonthBaseForm := TReservationMonthBaseForm.Create( nil );
  Result := GReservationMonthBaseForm;
end;

procedure ShowReservationMonthBaseForm;
begin
  GetReservationMonthBaseForm.Panel1.Visible := True;
  GetReservationMonthBaseForm.Panel1.BringToFront;
  GetReservationMonthBaseForm.GetMonthData;
end;
procedure UnvisibleReservationMonthBaseForm;
begin
  GetReservationMonthBaseForm.Panel1.SendToBack;
  GetReservationMonthBaseForm.Panel1.Visible := False;
end;

procedure FreeReservationMonthBaseForm;
begin
  if Assigned( GReservationMonthBaseForm ) then
  begin
    GReservationMonthBaseForm.ShowPanel( nil );
    FreeAndNil( GReservationMonthBaseForm );
  end;
end;

{ TReservationMonthBaseForm }

procedure TReservationMonthBaseForm.AfterEventNotify(AEventID: Cardinal;
  AData: TObserverData);
begin
  case AEventID of
    OB_Event_ExpandCollapse_RR_MonthList,
    OB_Event_ExpandCollapse_R_Reception     : ExpandCollapse( AEventID ); // 폈다, 접었다
    OB_Event_DataRefresh_Month_DataReload   : GetMonthData; // data를 다시 받아 오게 한다.
  end;
end;

procedure TReservationMonthBaseForm.BeforeEventNotify(AEventID: Cardinal;
  AData: TObserverData);
begin
  case AEventID of
    OB_Event_Init_ExpandCollapse : ExpandCollapse(OB_Event_Init_ExpandCollapse, True); // 접기 펴기 버튼 초기화
  end;
end;

constructor TReservationMonthBaseForm.Create(AOwner: TComponent);
begin
  inherited;
  isFirstResize := False;

  FObserver := TRRObserver.Create( nil );
  FObserver.OnBeforeAction := BeforeEventNotify;
  FObserver.OnAfterAction := AfterEventNotify;

  GetReservationMonthForm.ShowPanel( Panel3 );
  GetReservationMonthListForm.ShowPanel( TopPanel );
  GetReservationRequestMonthListForm.ShowPanel( BottomPanel );

  GetReservationMonthForm.today_btn.Click;
end;

destructor TReservationMonthBaseForm.Destroy;
begin
  FreeReservationMonthForm;
  FreeReservationMonthListForm;
  FreeReservationRequestMonthListForm;

  FreeAndNil( FObserver );
  inherited;
end;

procedure TReservationMonthBaseForm.ExpandCollapse(AActionCode: Cardinal; AUIInit : Boolean);
var
  expandpanel : array [1..2] of boolean;

  procedure checkExpand;
  begin
    expandpanel[1] := TopPanel.Height > HeaderHeight;  // 예약창
    expandpanel[2] := BottomPanel.Height > HeaderHeight; // 예약 요청 창
  end;

  function ExpandCount : Integer;
  var
    i : Integer;
  begin
    Result := 0;
    for i := Low(expandpanel) to High(expandpanel) do
      if expandpanel[ i ] then
        Inc( Result );
  end;

var
  cnt : Integer;
  ReservationMonthListForm : TReservationMonthListForm;
  ReservationRequestMonthListForm : TReservationRequestMonthListForm;
begin
  if not AUIInit then
  begin // 사용자가 button을 클릭 했으 때
    // ui 상태 check, expandpanel[1]의 값이 true이면 펴져 있는 상태임.
    checkExpand;
    case AActionCode of
      OB_Event_ExpandCollapse_R_Reception    :  // 예약 창 접었다/폈다
        begin
          expandpanel[1] := not expandpanel[1];
          GetRREnv.Day_ExpandCollapse_ReservationDecide := expandpanel[1];
        end;
      OB_Event_ExpandCollapse_RR_MonthList   : // 예약 요청창 접었다/폈다
        begin
          expandpanel[2] := not expandpanel[2];
          GetRREnv.Day_ExpandCollapse_ReservationRequest := expandpanel[2];
        end;
    end;
    GetRREnv.Save;
  end
  else
  begin // 환경 설정값
    expandpanel[1] := GetRREnv.Day_ExpandCollapse_ReservationDecide;  // 예약 창 접었다/폈다
    expandpanel[2] := GetRREnv.Day_ExpandCollapse_ReservationRequest; // 예약 요청창 접었다/폈다
  end;

  cnt := ExpandCount;
  if cnt <= 0 then
    exit; // 모두 접혀있는 상태이므로 처리 하지 않는다.

  ReservationMonthListForm := GetReservationMonthListForm;
  ReservationRequestMonthListForm := GetReservationRequestMonthListForm;

  if expandpanel[1] and expandpanel[2] then
  begin
    TopPanel.Align := alTop;
    TopPanel.Height := Panel2.Height div 2;
    BottomPanel.Align := alClient;
    Splitter1.Visible := True;
    Splitter1.Top := BottomPanel.Top + 2;

    ReservationRequestMonthListForm.ec_btn.ActiveButtonType := aibtButton1; // SakpungStyleButton1.Caption := '접기';
    ReservationMonthListForm.ec_btn.ActiveButtonType := aibtButton1; // SakpungStyleButton1.Caption := '접기';
  end
  else if expandpanel[1] then
  begin
    BottomPanel.Align := alBottom;
    BottomPanel.Height := HeaderHeight;
    Splitter1.Visible := False;
    TopPanel.Align := alClient;

    ReservationRequestMonthListForm.ec_btn.ActiveButtonType := aibtButton2; // SakpungStyleButton1.Caption := '펴기';
  end
  else
  begin
    TopPanel.Align := alTop;
    TopPanel.Height := HeaderHeight;
    Splitter1.Visible := False;
    BottomPanel.Align := alClient;

    ReservationMonthListForm.ec_btn.ActiveButtonType := aibtButton2; // SakpungStyleButton1.Caption := '펴기';
  end;
end;

procedure TReservationMonthBaseForm.GetMonthData;
begin
  TThread.CreateAnonymousThread(
    procedure
    begin
      // 마지막에 조회한 월 data를 요청하고 출력 하게 한다.
      GetReservationMonthForm.GetLastMonth;
    end).Start;
end;

procedure TReservationMonthBaseForm.ResizeTimerTimer(Sender: TObject);
begin // 초기 ui 설정을 위해 한번만 실행되게 한다.
  ResizeTimer.Enabled := False;
  if not isFirstResize then
  begin
    isFirstResize := True;
    TopPanel.Height := Panel2.Height div 2;
  end;
end;

procedure TReservationMonthBaseForm.ShowPanel(AParentControl: TWinControl);
begin
  if Assigned( AParentControl ) then
  begin
    if (Panel1.Parent <> AParentControl) then
    begin
      Panel1.Parent := AParentControl;
      Panel1.Align := alClient;
      Panel1.Visible := True;
      ResizeTimer.Enabled := not isFirstResize;
    end;
  end
  else
  begin
    if Assigned( Panel1 ) then
    begin
      Panel1.Visible := False;
      Panel1.Parent := Self;
      Panel1.Align := alClient;
    end;
  end;

end;

initialization
  GReservationMonthBaseForm := nil;

finalization

end.
