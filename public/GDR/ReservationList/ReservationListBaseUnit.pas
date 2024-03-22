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
    procedure ExpandCollapse( AActionCode : Cardinal; AUIInit : Boolean = False ); // ������ ���, AUIInit�� true�̸� ������ ������ ȭ���� �����ϰ� �Ѵ�.

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

    // ������ ���� data�� ���� �� �ְ� �Ѵ�.
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
    OB_Event_ExpandCollapse_RR_RequestReservationList     : ExpandCollapse( AEventID ); // ���, ������
    OB_Event_DataRefresh_Month2_DataReload        : GetMonthData; // data�� �ٽ� �޾� ���� �Ѵ�.
  end;
end;

procedure TReservationListBaseForm.BeforeEventNotify(AEventID: Cardinal;
  AData: TObserverData);
begin
  case AEventID of
    OB_Event_Init_ExpandCollapse : ExpandCollapse(OB_Event_Init_ExpandCollapse, True); // ���� ��� ��ư �ʱ�ȭ
  end;
end;

procedure TReservationListBaseForm.CalcWorkMonth(AIncMonth: Integer);
begin
  if AIncMonth = 0 then
    FWorkMonth := Today
  else
    FWorkMonth := IncMonth(FWorkMonth, AIncMonth); // ����/����

  Label1.Caption := FormatDateTime('yyyy�� m��', FWorkMonth);
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
    expandpanel[1] := TopPanel.Height > HeaderHeight;  // ����â
    expandpanel[2] := BottomPanel.Height > HeaderHeight; // ���� ��û â
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
  begin // ����ڰ� button�� Ŭ�� ���� ��
    // ui ���� check, expandpanel[1]�� ���� true�̸� ���� �ִ� ������.
    checkExpand;
    case AActionCode of
      OB_Event_ExpandCollapse_RR_RequestReservationList    : // ���� â ������/���
        begin
          expandpanel[1] := not expandpanel[1];
          GetRREnv.MonthList_ExpandCollapse_ReservationDecide := expandpanel[1];
        end;
      OB_Event_ExpandCollapse_RR_List             : // ���� ��ûâ ������/���
        begin
          expandpanel[2] := not expandpanel[2];
          GetRREnv.MonthList_ExpandCollapse_ReservationRequest := expandpanel[2];
        end;
    end;
    GetRREnv.Save;
  end
  else
  begin // ȯ�� ������
    expandpanel[1] := GetRREnv.MonthList_ExpandCollapse_ReservationDecide;  // ���� â ������/���
    expandpanel[2] := GetRREnv.MonthList_ExpandCollapse_ReservationRequest; // ���� ��ûâ ������/���
  end;

  cnt := ExpandCount;
  if cnt <= 0 then
    exit; // ��� �����ִ� �����̹Ƿ� ó�� ���� �ʴ´�.

  ReservationListForm := GetReservationListForm;
  ReservationRequestListForm := GetReservationRequestListForm;

  if expandpanel[1] and expandpanel[2] then
  begin
    TopPanel.Align := alTop;
    TopPanel.Height := Panel2.Height div 2;
    BottomPanel.Align := alClient;
    Splitter1.Visible := True;
    Splitter1.Top := BottomPanel.Top + 2;

    ReservationRequestListForm.ec_btn.ActiveButtonType := aibtButton1; // ����
    ReservationListForm.ec_btn.ActiveButtonType := aibtButton1; // ����;
  end
  else if expandpanel[1] then
  begin
    BottomPanel.Align := alBottom;
    BottomPanel.Height := HeaderHeight;
    Splitter1.Visible := False;
    TopPanel.Align := alClient;

    ReservationRequestListForm.ec_btn.ActiveButtonType := aibtButton2; // ���
  end
  else
  begin
    TopPanel.Align := alTop;
    TopPanel.Height := HeaderHeight;
    Splitter1.Visible := False;
    BottomPanel.Align := alClient;

    ReservationListForm.ec_btn.ActiveButtonType := aibtButton2; // ���
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
          CalcWorkMonth; // ���ó��� �������� ���� �Ѵ�.

        flashcount := 0;
        // data�� ���� �а� �Ѵ�.
        RestCallDM.GetRRMonthData( FWorkMonth, 'S', flashcount )
      finally
        FObserver.AfterActionASync( OB_Event_DataRefresh_Month2 );
      end;
    end).Start;
end;

procedure TReservationListBaseForm.ResizeTimerTimer(Sender: TObject);
begin // �ʱ� ui ������ ���� �ѹ��� ����ǰ� �Ѵ�.
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
      // data�� ���� �а� �Ѵ�.
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
      // data�� ���� �а� �Ѵ�.
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
      // data�� ���� �а� �Ѵ�.
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
      // data�� ���� �а� �Ѵ�.
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
