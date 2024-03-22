unit ReservationListBaseUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  RRObserverUnit, SakpungImageButton, Vcl.StdCtrls;

type
  TReservationListBaseForm = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    BottomPanel: TPanel;
    Splitter1: TSplitter;
    TopPanel: TPanel;
    ResizeTimer: TTimer;
    Panel3: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    SakpungImageButton1: TSakpungImageButton;
    SakpungImageButton2: TSakpungImageButton;
    today_btn: TSakpungImageButton;
    SakpungImageButton3: TSakpungImageButton;
    procedure ResizeTimerTimer(Sender: TObject);
    procedure SakpungImageButton1Click(Sender: TObject);
    procedure SakpungImageButton2Click(Sender: TObject);
    procedure today_btnClick(Sender: TObject);
    procedure SakpungImageButton3Click(Sender: TObject);
  private
    { Private declarations }
    isFirstResize : Boolean;
    FWorkMonth : TDate;
    procedure ExpandCollapse( AActionCode : Cardinal; AUIInit : Boolean = False ); // 접었다 폈다, AUIInit이 true이면 설정된 값으로 화면을 갱신하게 한다.

    procedure CalcWorkMonth( AIncMonth : Integer = 0 );
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

function GetReservationListBaseForm : TReservationListBaseForm;
procedure ShowReservationListBaseForm;
procedure UnvisibleReservationListBaseForm;
procedure FreeReservationListBaseForm;

implementation
uses
  dateutils, GDLog,
  EventIDConst, RREnvUnit, RestCallUnit, RnRData,
  ReservationListUnit, ReservationRequestListUnit;

const
  // HeaderHeight = 36;
  HeaderHeight = 30;

var
  GReservationListBaseForm: TReservationListBaseForm;


{$R *.dfm}

function GetReservationListBaseForm : TReservationListBaseForm;
begin
  if not Assigned( GReservationListBaseForm ) then
    GReservationListBaseForm := TReservationListBaseForm.Create( nil );
  Result := GReservationListBaseForm;
end;

procedure ShowReservationListBaseForm;
begin
  GReservationListBaseForm.Panel1.Visible := True;
  GReservationListBaseForm.Panel1.BringToFront;
  GReservationListBaseForm.GetMonthData;
end;
procedure UnvisibleReservationListBaseForm;
begin
  GReservationListBaseForm.Panel1.SendToBack;
  GReservationListBaseForm.Panel1.Visible := False;
end;

procedure FreeReservationListBaseForm;
begin
  if Assigned( GReservationListBaseForm ) then
  begin
    GReservationListBaseForm.ShowPanel( nil );
    FreeAndNil( GReservationListBaseForm );
  end;
end;

{ TReservationMonthBaseForm }

procedure TReservationListBaseForm.AfterEventNotify(AEventID: Cardinal;
  AData: TObserverData);
begin
  case AEventID of
    OB_Event_ExpandCollapse_RR_List,
    OB_Event_ExpandCollapse_RR_RequestReservationList     : ExpandCollapse( AEventID ); // 폈다, 접었다
    OB_Event_DataRefresh_Month2_DataReload        : GetMonthData; // data를 다시 받아 오게 한다.
  end;
end;

procedure TReservationListBaseForm.BeforeEventNotify(AEventID: Cardinal;
  AData: TObserverData);
begin
  case AEventID of
    OB_Event_Init_ExpandCollapse : ExpandCollapse(OB_Event_Init_ExpandCollapse, True); // 접기 펴기 버튼 초기화
  end;
end;

procedure TReservationListBaseForm.CalcWorkMonth(AIncMonth: Integer);
begin
  if AIncMonth = 0 then
    FWorkMonth := Today
  else
    FWorkMonth := IncMonth(FWorkMonth, AIncMonth); // 증가/감소

  Label1.Caption := FormatDateTime('yyyy년 m월', FWorkMonth);
end;

constructor TReservationListBaseForm.Create(AOwner: TComponent);
begin
  inherited;
  isFirstResize := False;

  FObserver := TRRObserver.Create( nil );
  FObserver.OnBeforeAction := BeforeEventNotify;
  FObserver.OnAfterAction := AfterEventNotify;

  GetReservationListForm.ShowPanel( TopPanel );
  GetReservationRequestListForm.ShowPanel( BottomPanel );

  FWorkMonth := Today;
  CalcWorkMonth;
  today_btn.Click;
end;

destructor TReservationListBaseForm.Destroy;
begin
  FreeReservationListForm;
  FreeReservationRequestListForm;

  FreeAndNil( FObserver );
  inherited;
end;

procedure TReservationListBaseForm.ExpandCollapse(AActionCode: Cardinal; AUIInit : Boolean);
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
  ReservationListForm : TReservationListForm;
  ReservationRequestListForm : TReservationRequestListForm;
begin
  if not AUIInit then
  begin // 사용자가 button을 클릭 했으 때
    // ui 상태 check, expandpanel[1]의 값이 true이면 펴져 있는 상태임.
    checkExpand;
    case AActionCode of
      OB_Event_ExpandCollapse_RR_RequestReservationList    : // 예약 창 접었다/폈다
        begin
          expandpanel[1] := not expandpanel[1];
          GetRREnv.MonthList_ExpandCollapse_ReservationDecide := expandpanel[1];
        end;
      OB_Event_ExpandCollapse_RR_List             : // 예약 요청창 접었다/폈다
        begin
          expandpanel[2] := not expandpanel[2];
          GetRREnv.MonthList_ExpandCollapse_ReservationRequest := expandpanel[2];
        end;
    end;
    GetRREnv.Save;
  end
  else
  begin // 환경 설정값
    expandpanel[1] := GetRREnv.MonthList_ExpandCollapse_ReservationDecide;  // 예약 창 접었다/폈다
    expandpanel[2] := GetRREnv.MonthList_ExpandCollapse_ReservationRequest; // 예약 요청창 접었다/폈다
  end;

  cnt := ExpandCount;
  if cnt <= 0 then
    exit; // 모두 접혀있는 상태이므로 처리 하지 않는다.

  ReservationListForm := GetReservationListForm;
  ReservationRequestListForm := GetReservationRequestListForm;

  if expandpanel[1] and expandpanel[2] then
  begin
    TopPanel.Align := alTop;
    TopPanel.Height := Panel2.Height div 2;
    BottomPanel.Align := alClient;
    Splitter1.Visible := True;
    Splitter1.Top := BottomPanel.Top + 2;

    ReservationRequestListForm.ec_btn.ActiveButtonType := aibtButton1; // 접기
    ReservationListForm.ec_btn.ActiveButtonType := aibtButton1; // 접기;
  end
  else if expandpanel[1] then
  begin
    BottomPanel.Align := alBottom;
    BottomPanel.Height := HeaderHeight;
    Splitter1.Visible := False;
    TopPanel.Align := alClient;

    ReservationRequestListForm.ec_btn.ActiveButtonType := aibtButton2; // 펴기
  end
  else
  begin
    TopPanel.Align := alTop;
    TopPanel.Height := HeaderHeight;
    Splitter1.Visible := False;
    BottomPanel.Align := alClient;

    ReservationListForm.ec_btn.ActiveButtonType := aibtButton2; // 펴기
  end;
end;

procedure TReservationListBaseForm.GetMonthData;
var
  flashcount : Integer;
begin
  TThread.CreateAnonymousThread(
    procedure
    begin
      FObserver.BeforeAction( OB_Event_DataRefresh_Month2 );
      try
        if FWorkMonth = 0 then
          CalcWorkMonth; // 오늘날자 기준으로 변경 한다.

        flashcount := 0;
        // data를 새로 읽게 한다.
        RestCallDM.GetRRMonthData( FWorkMonth, 'S', flashcount )
      finally
        FObserver.AfterActionASync( OB_Event_DataRefresh_Month2 );
      end;
    end).Start;
end;

procedure TReservationListBaseForm.ResizeTimerTimer(Sender: TObject);
begin // 초기 ui 설정을 위해 한번만 실행되게 한다.
  ResizeTimer.Enabled := False;
  if not isFirstResize then
  begin
    isFirstResize := True;
    TopPanel.Height := Panel2.Height div 2;
  end;
end;

procedure TReservationListBaseForm.SakpungImageButton1Click(Sender: TObject);
var
  flashcount : Integer;
  sd : TSelectData;
begin
  CalcWorkMonth( -1 );
  sd := TSelectData.Create( FWorkMonth );
  try
    FObserver.BeforeAction( OB_Event_DataRefresh_Month2_List, sd );
    try
      flashcount := 0;
      // data를 새로 읽게 한다.
      RestCallDM.GetRRData( FWorkMonth, 'S', flashcount )
    finally
      FObserver.AfterActionASync( OB_Event_DataRefresh_Month2_List, sd );
    end;
  finally
    FreeAndNil( sd );
  end;
end;

procedure TReservationListBaseForm.SakpungImageButton2Click(Sender: TObject);
var
  flashcount : Integer;
  sd : TSelectData;
begin
  CalcWorkMonth( 1 );
  sd := TSelectData.Create( FWorkMonth );
  try
    FObserver.BeforeAction( OB_Event_DataRefresh_Month2_List, sd );
    try
      flashcount := 0;
      // data를 새로 읽게 한다.
      RestCallDM.GetRRData( FWorkMonth, 'S', flashcount )
    finally
      FObserver.AfterActionASync( OB_Event_DataRefresh_Month2_List, sd );
    end;
  finally
    FreeAndNil( sd );
  end;
end;

procedure TReservationListBaseForm.SakpungImageButton3Click(Sender: TObject);
var
  flashcount : Integer;
  sd : TSelectData;
begin
  sd := TSelectData.Create( FWorkMonth );
  try
    FObserver.BeforeAction( OB_Event_DataRefresh_Month2_List, sd );
    try
      flashcount := 0;
      // data를 새로 읽게 한다.
      RestCallDM.GetRRData( FWorkMonth, 'S', flashcount )
    finally
      FObserver.AfterActionASync( OB_Event_DataRefresh_Month2_List, sd );
    end;

  finally
    FreeAndNil( sd );
  end;
end;

procedure TReservationListBaseForm.ShowPanel(AParentControl: TWinControl);
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

procedure TReservationListBaseForm.today_btnClick(Sender: TObject);
var
  flashcount : Integer;
  sd : TSelectData;
begin
  CalcWorkMonth;
  sd := TSelectData.Create( FWorkMonth );
  try
    FObserver.BeforeAction( OB_Event_DataRefresh_Month2_List, sd );
    try
      flashcount := 0;
      // data를 새로 읽게 한다.
      RestCallDM.GetRRData( FWorkMonth, 'S', flashcount )
    finally
      FObserver.AfterActionASync( OB_Event_DataRefresh_Month2_List, sd );
    end;

  finally
    FreeAndNil( sd );
  end;
end;

initialization
  GReservationListBaseForm := nil;

finalization

end.
