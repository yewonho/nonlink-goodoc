unit ReceptionReservationBaseUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  RRObserverUnit, SakpungEdit;

type
  TReceptionReservationBaseForm = class(TForm)
    Panel1: TPanel;
    BottomPanel: TPanel;
    Splitter: TSplitter;
    TopPanel: TPanel;
    ResizeTimer: TTimer;
    procedure ResizeTimerTimer(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
    FObserver : TRRObserver;
    procedure BeforeEventNotify( AEventID : Cardinal; AData : TObserverData );
    procedure AfterEventNotify( AEventID : Cardinal; AData : TObserverData );
  private
    { Private declarations }
    isFirstResize : Boolean;

    procedure ExpandCollapse( AActionCode : Cardinal; AUIInit : Boolean = False ); // 접었다 폈다, AUIInit이 true이면 설정된 값으로 화면을 갱신하게 한다.
  public
    { Public declarations }
    constructor Create( AOwner : TComponent ); override;
    destructor Destroy; override;

    procedure ShowPanel( AParentControl : TWinControl );
  end;

function GetReceptionReservationBaseForm : TReceptionReservationBaseForm;
procedure ShowReceptionReservationBaseForm;
procedure UnvisibleReceptionReservationBaseForm;
procedure FreeReceptionReservationBaseForm;

const
//  HeaderHeight = 36;
  HeaderHeight = 30;
  MinPanelHeight = 150;

implementation
uses
  GDLog, SakpungImageButton,
  EventIDConst, RREnvUnit, ReservationUnit, ReceptionUnit, RnRUnit;

var
  GReceptionReservationBaseForm: TReceptionReservationBaseForm;


{$R *.dfm}

function GetReceptionReservationBaseForm : TReceptionReservationBaseForm;
begin
  if not Assigned( GReceptionReservationBaseForm ) then
  begin
    GReceptionReservationBaseForm := TReceptionReservationBaseForm.Create( nil );
  end;
  Result := GReceptionReservationBaseForm;
end;

procedure ShowReceptionReservationBaseForm;
begin
  GetReceptionReservationBaseForm.Panel1.Visible := True;
  GetReceptionReservationBaseForm.Panel1.BringToFront;
end;
procedure UnvisibleReceptionReservationBaseForm;
begin
  GetReceptionReservationBaseForm.Panel1.SendToBack;
  GetReceptionReservationBaseForm.Panel1.Visible := False;
end;

procedure FreeReceptionReservationBaseForm;
begin
  if Assigned( GReceptionReservationBaseForm ) then
  begin
    GReceptionReservationBaseForm.ShowPanel( nil );
    FreeAndNil( GReceptionReservationBaseForm );
  end;
end;

{ TReceptionReservationBaseForm }

procedure TReceptionReservationBaseForm.AfterEventNotify(AEventID: Cardinal;
  AData: TObserverData);
begin
  case AEventID of
    OB_Event_ExpandCollapse_RnR,       // 접수/예약 창 접었다/폈다
    OB_Event_ExpandCollapse_Reception,    // 접수 창 접었다/폈다
    OB_Event_ExpandCollapse_Reservation : ExpandCollapse( AEventID ); // 폈다, 접었다
  end;
end;

procedure TReceptionReservationBaseForm.BeforeEventNotify(AEventID: Cardinal;
  AData: TObserverData);
begin
  case AEventID of
    OB_Event_Init_ExpandCollapse : ExpandCollapse(OB_Event_Init_ExpandCollapse, True); // 접기 펴기 버튼 초기화
  end;

end;

constructor TReceptionReservationBaseForm.Create(AOwner: TComponent);

begin
  inherited;

  isFirstResize := False;

  FObserver := TRRObserver.Create( nil );
  FObserver.OnBeforeAction := BeforeEventNotify;
  FObserver.OnAfterAction := AfterEventNotify;

  GetReceptionForm.ShowPanel( TopPanel );
  GetRnRForm.ShowPanel( BottomPanel );
end;

destructor TReceptionReservationBaseForm.Destroy;
begin
  FreeReceptionForm;
  FreeRnRForm;

  FreeAndNil( FObserver );
  inherited;
end;

procedure TReceptionReservationBaseForm.ExpandCollapse(AActionCode: Cardinal; AUIInit : Boolean);
var
  expandpanel : array [1..2] of boolean;

  procedure checkExpand;
  begin
    expandpanel[1] := TopPanel.Height > HeaderHeight;  // 접수창
    expandpanel[2] := BottomPanel.Height > HeaderHeight; // 접수요청창
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
  cnt, h : Integer;
  ReceptionForm : TReceptionForm;
  RnRForm : TRnRForm;
begin
  if not AUIInit then
  begin // 사용자가 button을 클릭 했으 때
    // ui 상태 check, expandpanel[1]의 값이 true이면 펴져 있는 상태임.
    checkExpand;

    case AActionCode of
      OB_Event_ExpandCollapse_RnR         : // 접수/예약 창 접었다/폈다
        begin
          expandpanel[2] := not expandpanel[2];
          GetRREnv.ToDay_ExpandCollapse_ReceptionReservation := expandpanel[2]; // 접었다/폈다 버튼 상태를 저장 한다.
        end;
      OB_Event_ExpandCollapse_Reception   : // 접수 창 접었다/폈다
        begin
          expandpanel[1] := not expandpanel[1];
          GetRREnv.ToDay_ExpandCollapse_Reception := expandpanel[1]; // 접었다/폈다 버튼 상태를 저장 한다.
        end;
    end;
    GetRREnv.Save;
  end
  else
  begin // 환경 설정값
    expandpanel[1] := GetRREnv.ToDay_ExpandCollapse_Reception;  // 접수창
    expandpanel[2] := GetRREnv.ToDay_ExpandCollapse_ReceptionReservation; // 접수요청창
  end;

  cnt := ExpandCount;
  if cnt <= 0 then
    exit; // 모두 접혀있는 상태이므로 처리 하지 않는다.

  ReceptionForm := GetReceptionForm;
  RnRForm := GetRnRForm;

  if expandpanel[1] and expandpanel[2] then
  begin  // 둘다 펴져 있는 상태
    TopPanel.Height := Panel1.Height div 2;
    BottomPanel.Height := Panel1.Height div 2;
    Splitter.Visible := True;
    Splitter.Top := BottomPanel.Top - Splitter.Height;
    ReceptionForm.ec_btn.ActiveButtonType := aibtButton1; // SakpungStyleButton1.Caption := '접기';
    RnRForm.ec_btn.ActiveButtonType := aibtButton1; // SakpungStyleButton1.Caption := '접기';
  end
  else if expandpanel[1] or expandpanel[2] then
  begin // 둘중 한개만 펴져 있는 상태
    Splitter.Visible := false;
    if expandpanel[1] then
    begin
      TopPanel.Height := Panel1.Height - HeaderHeight;
      BottomPanel.Height := HeaderHeight;
      RnRForm.ec_btn.ActiveButtonType := aibtButton2; // SakpungStyleButton1.Caption := '펴기';
    end
    else
    begin
      TopPanel.Height := HeaderHeight;
      BottomPanel.Height := Panel1.Height - HeaderHeight;
      ReceptionForm.ec_btn.ActiveButtonType := aibtButton2; // SakpungStyleButton1.Caption := '펴기';
    end;
  end
  else
  begin  // 둘다 졉혀 있는 상태
    Splitter.Visible := False;
    TopPanel.Height := HeaderHeight;
    BottomPanel.Height := HeaderHeight;
    ReceptionForm.ec_btn.ActiveButtonType := aibtButton2; // SakpungStyleButton1.Caption := '펴기';
    RnRForm.ec_btn.ActiveButtonType := aibtButton2; // SakpungStyleButton1.Caption := '펴기';
  end;
end;


procedure TReceptionReservationBaseForm.FormResize(Sender: TObject);
var
  expandpanel : array [1..2] of boolean;
begin
  expandpanel[1] := TopPanel.Height > HeaderHeight;  // 접수창
  expandpanel[2] := BottomPanel.Height > HeaderHeight; // 접수요청창

  if expandpanel[1] and not Splitter.Visible then
  begin
    TopPanel.Height := Panel1.Height - HeaderHeight;
  end;

  Splitter.Top := BottomPanel.Top - Splitter.Height;
end;


procedure TReceptionReservationBaseForm.ResizeTimerTimer(Sender: TObject);
begin // 초기 ui 설정을 위해 한번만 실행되게 한다.
  ResizeTimer.Enabled := False;
  if not isFirstResize then
  begin
    isFirstResize := True;

    TopPanel.Height := Panel1.Height div 2;
    BottomPanel.Height := Panel1.Height div 2;
  end;
end;

procedure TReceptionReservationBaseForm.ShowPanel(
  AParentControl: TWinControl);
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
  GReceptionReservationBaseForm := nil;

finalization

end.
