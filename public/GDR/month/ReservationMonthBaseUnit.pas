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
    procedure ExpandCollapse( AActionCode : Cardinal; AUIInit : Boolean = False ); // ������ ���, AUIInit�� true�̸� ������ ������ ȭ���� �����ϰ� �Ѵ�.
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
    OB_Event_ExpandCollapse_R_Reception     : ExpandCollapse( AEventID ); // ���, ������
    OB_Event_DataRefresh_Month_DataReload   : GetMonthData; // data�� �ٽ� �޾� ���� �Ѵ�.
  end;
end;

procedure TReservationMonthBaseForm.BeforeEventNotify(AEventID: Cardinal;
  AData: TObserverData);
begin
  case AEventID of
    OB_Event_Init_ExpandCollapse : ExpandCollapse(OB_Event_Init_ExpandCollapse, True); // ���� ��� ��ư �ʱ�ȭ
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
  ReservationMonthListForm : TReservationMonthListForm;
  ReservationRequestMonthListForm : TReservationRequestMonthListForm;
begin
  if not AUIInit then
  begin // ����ڰ� button�� Ŭ�� ���� ��
    // ui ���� check, expandpanel[1]�� ���� true�̸� ���� �ִ� ������.
    checkExpand;
    case AActionCode of
      OB_Event_ExpandCollapse_R_Reception    :  // ���� â ������/���
        begin
          expandpanel[1] := not expandpanel[1];
          GetRREnv.Day_ExpandCollapse_ReservationDecide := expandpanel[1];
        end;
      OB_Event_ExpandCollapse_RR_MonthList   : // ���� ��ûâ ������/���
        begin
          expandpanel[2] := not expandpanel[2];
          GetRREnv.Day_ExpandCollapse_ReservationRequest := expandpanel[2];
        end;
    end;
    GetRREnv.Save;
  end
  else
  begin // ȯ�� ������
    expandpanel[1] := GetRREnv.Day_ExpandCollapse_ReservationDecide;  // ���� â ������/���
    expandpanel[2] := GetRREnv.Day_ExpandCollapse_ReservationRequest; // ���� ��ûâ ������/���
  end;

  cnt := ExpandCount;
  if cnt <= 0 then
    exit; // ��� �����ִ� �����̹Ƿ� ó�� ���� �ʴ´�.

  ReservationMonthListForm := GetReservationMonthListForm;
  ReservationRequestMonthListForm := GetReservationRequestMonthListForm;

  if expandpanel[1] and expandpanel[2] then
  begin
    TopPanel.Align := alTop;
    TopPanel.Height := Panel2.Height div 2;
    BottomPanel.Align := alClient;
    Splitter1.Visible := True;
    Splitter1.Top := BottomPanel.Top + 2;

    ReservationRequestMonthListForm.ec_btn.ActiveButtonType := aibtButton1; // SakpungStyleButton1.Caption := '����';
    ReservationMonthListForm.ec_btn.ActiveButtonType := aibtButton1; // SakpungStyleButton1.Caption := '����';
  end
  else if expandpanel[1] then
  begin
    BottomPanel.Align := alBottom;
    BottomPanel.Height := HeaderHeight;
    Splitter1.Visible := False;
    TopPanel.Align := alClient;

    ReservationRequestMonthListForm.ec_btn.ActiveButtonType := aibtButton2; // SakpungStyleButton1.Caption := '���';
  end
  else
  begin
    TopPanel.Align := alTop;
    TopPanel.Height := HeaderHeight;
    Splitter1.Visible := False;
    BottomPanel.Align := alClient;

    ReservationMonthListForm.ec_btn.ActiveButtonType := aibtButton2; // SakpungStyleButton1.Caption := '���';
  end;
end;

procedure TReservationMonthBaseForm.GetMonthData;
begin
  TThread.CreateAnonymousThread(
    procedure
    begin
      // �������� ��ȸ�� �� data�� ��û�ϰ� ��� �ϰ� �Ѵ�.
      GetReservationMonthForm.GetLastMonth;
    end).Start;
end;

procedure TReservationMonthBaseForm.ResizeTimerTimer(Sender: TObject);
begin // �ʱ� ui ������ ���� �ѹ��� ����ǰ� �Ѵ�.
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
