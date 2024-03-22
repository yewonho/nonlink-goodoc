unit ReservationMonthUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Grids,
  RRObserverUnit, Vcl.StdCtrls, SakpungStyleButton,
  RnRData, RRGridDrawUnit, SakpungImageButton;

type
  TReservationMonthForm = class(TForm)
    Panel1: TPanel;
    MonthGrid: TStringGrid;
    Panel2: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    SakpungImageButton1: TSakpungImageButton;
    SakpungImageButton2: TSakpungImageButton;
    today_btn: TSakpungImageButton;
    SakpungImageButton3: TSakpungImageButton;
    procedure Panel1Resize(Sender: TObject);
    procedure MonthGridSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure SakpungImageButton1Click(Sender: TObject);
    procedure SakpungImageButton2Click(Sender: TObject);
    procedure today_btnClick(Sender: TObject);
    procedure SakpungImageButton3Click(Sender: TObject);
  private
    { Private declarations }
    FWorkMonth : TDate;
    FDrawGrid : TMonthGridDrawCell;
    procedure CalcWorkMonth( AIncMonth : Integer = 0 );

    procedure SetGridUI;  // grid의 초기 UI를 설정 한다.
    procedure RefreshData; // list에 data를 출력 한다.  주기적으로 출력 한다.
    function GetDayData( ADay : TDate; var ACol, ARow : Integer ) : TMonthData; // day에 해당하는 data를 반환 한다.
    procedure ClearGrid;
    // 지정된 날자에 해당하는 cell에 focus를 준다.
    procedure FocusDay( AFocusDay : TDateTime );
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
    procedure GetLastMonth;
  end;

function GetReservationMonthForm : TReservationMonthForm;
procedure FreeReservationMonthForm;

implementation
uses
  math,
  dateutils, UtilsUnit, GDLog,
  EventIDConst, RRDialogs,
  RestCallUnit, RnRDMUnit, BridgeWrapperUnit;

const
  GridFixedRowHeight = 30;

var
  GReservationMonthForm: TReservationMonthForm;

{$R *.dfm}

function GetReservationMonthForm : TReservationMonthForm;
begin
  if not Assigned( GReservationMonthForm ) then
    GReservationMonthForm := TReservationMonthForm.Create( nil );
  Result := GReservationMonthForm;
end;

procedure FreeReservationMonthForm;
begin
  if Assigned( GReservationMonthForm ) then
  begin
    GReservationMonthForm.ShowPanel( nil );
    FreeAndNil( GReservationMonthForm );
  end;
end;

{ TReservationMonthForm }

procedure TReservationMonthForm.AfterEventNotify(AEventID: Cardinal;
  AData: TObserverData);
begin
  case AEventID of
    OB_Event_DataRefresh_Month :
      begin
        RefreshData;
      end;
  end;
end;

procedure TReservationMonthForm.BeforeEventNotify(AEventID: Cardinal;
  AData: TObserverData);
begin

end;

procedure TReservationMonthForm.CalcWorkMonth(AIncMonth: Integer);
begin
  if AIncMonth = 0 then
    FWorkMonth := Today
  else
    FWorkMonth := IncMonth(FWorkMonth, AIncMonth); // 증가/감소

  Label1.Caption := FormatDateTime('yyyy년 m월', FWorkMonth);
end;

procedure TReservationMonthForm.ClearGrid;
var
  i, j : Integer;
  o : TObject;
begin
  with MonthGrid do
  begin
    for i := 1 to RowCount-1 do
    begin
      for j := 0 to ColCount do
      begin
        o := Objects[j, i];
        if Assigned( o ) then
        begin
          Objects[j, i] := nil;
          FreeAndNil( o );
        end;
      end;
    end;
  end;
end;

constructor TReservationMonthForm.Create(AOwner: TComponent);
begin
  inherited;
  FObserver := TRRObserver.Create( nil );
  FObserver.OnBeforeAction := BeforeEventNotify;
  FObserver.OnAfterAction := AfterEventNotify;

  FWorkMonth := Today;
  CalcWorkMonth;

  FDrawGrid := TMonthGridDrawCell.Create;
  FDrawGrid.ListGrid := MonthGrid;
end;

destructor TReservationMonthForm.Destroy;
begin
  ClearGrid;

  FreeAndNil( FDrawGrid );
  FreeAndNil( FObserver );
  inherited;
end;

procedure TReservationMonthForm.FocusDay(AFocusDay: TDateTime);
var
  CanSelect : Boolean;
  c, r : Integer;
begin
  FDrawGrid.CalcDate2ColRow(TDate( AFocusDay ), c, r );

  MonthGrid.Row := r;
  MonthGrid.Col := c;

  CanSelect := True;
  MonthGridSelectCell( MonthGrid, c, r, CanSelect);
end;

function TReservationMonthForm.GetDayData(ADay: TDate; var ACol,
  ARow: Integer): TMonthData;
var
  y, m, d : Word;
begin
  FDrawGrid.CalcDate2ColRow(ADay, ACol, ARow );

  Result := TMonthData( MonthGrid.Objects[ACol, ARow] );
  if not Assigned( Result ) then
  begin
    decodedate(ADay, y, m, d);
    Result := TMonthData.Create;
    Result.Day := ADay;
    Result.Caption := IntToStr( d );
    Result.WeekDay := ACol;
    Result.Holiday := ACol in [0, 6];
    MonthGrid.Objects[ACol, ARow] := Result;
  end;
end;

procedure TReservationMonthForm.GetLastMonth;
var
  flashcount : integer;
begin
  FObserver.BeforeAction( OB_Event_DataRefresh_Month );
  try
    if FWorkMonth = 0 then
      CalcWorkMonth; // 오늘날자 기준으로 변경 한다.

    flashcount := 0;
    // data를 새로 읽게 한다.
    RestCallDM.GetRRMonthData( FWorkMonth, 'S', flashcount )
  finally
    FObserver.AfterActionASync( OB_Event_DataRefresh_Month );
  end;
end;

procedure TReservationMonthForm.MonthGridSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
var
  sd, ed : TDateTime;
  data : TMonthData;
  selectdata : TSelectData;
begin
  if ARow = 0 then
  begin
    CanSelect := False;
    exit;
  end;

  data := TMonthData( TStringGrid(Sender).Objects[ ACol, ARow ] );
  selectdata := TSelectData.Create( data.Day );
  try
    FObserver.BeforeAction(OB_Event_DataRefresh_Month_List, selectdata );
    try
    finally
      FObserver.AfterAction(OB_Event_DataRefresh_Month_List, selectdata);

      // FWorkMonth에 대한 시작 일과 마자막 일자를 읽어 온다.
      CalcRangeMonth( FWorkMonth, sd, ed );
      if CheckRangeDateTime( selectdata.Date, sd, ed ) then
        FWorkMonth := selectdata.Date;
    end;
  finally
    FreeAndNil( selectdata );
  end;
end;

procedure TReservationMonthForm.Panel1Resize(Sender: TObject);
var
  i, h, w : Integer;
begin
  MonthGrid.RowHeights[ 0 ] := GridFixedRowHeight;
  h := (MonthGrid.Height - GridFixedRowHeight ) div (MonthGrid.RowCount -1) -1;
  for i := 1 to MonthGrid.RowCount -1 do
  begin
    MonthGrid.RowHeights[ i ] := h;
  end;

  w := MonthGrid.Width div 7;
  for i := 0 to 6 do
    MonthGrid.ColWidths[ i ] := w;
end;

procedure TReservationMonthForm.RefreshData;
var
  dtype : TRnRType;

  status : TConvertState4App;
  statuscode : TRnRDataStatus;

  visitdt : TDateTime;
  sd, ed : TDateTime;
  c, r  : Integer;
  data : TMonthData;
begin
  SetGridUI;

  // FWorkMonth에 대한 시작 일과 마자막 일자를 읽어 온다.
  CalcRangeMonth( FWorkMonth, sd, ed );

  MonthGrid.Perform(WM_SETREDRAW, 0, 0);   // begineupdate
  try
    with RnRDM do
    begin
      RR_DB.IndexName := 'visitIndex';

      RR_DB.First;
      while not RR_DB.Eof do // state가 rrsRequest인 data를 모두 출력 한다.
      begin
        try
          dtype := TRnRType( RR_DB.FieldByName( 'datatype' ).AsInteger );
          if dtype <> rrReservation then
              Continue; // 예약이 아니면 집계 하지 않는다.

          visitdt := RR_DB.FieldByName('reservedttm').AsDateTime;
          if not CheckRangeDateTime( visitdt, sd, ed ) then
            Continue; // 지정한 달에 발생된 data가 아니다.

          data := GetDayData(visitdt, c, r);
          if not Assigned( data ) then
            continue;

          statuscode := TRRDataTypeConvert.DataStatus2RnRDataStatus(RR_DB.FieldByName( 'status' ).AsInteger);
          status := TRRDataTypeConvert.Status4App( statuscode, RR_DB.FieldByName( 'hsptlreceptndttm' ).AsDateTime );

          if TRRDataTypeConvert.CheckCancelStatus( statuscode ) or TRRDataTypeConvert.checkFinishStatus( statuscode ) then
          begin
            data.incCancelFinishCount; // 취소 data 추가
            Continue; // 취소/완료된 data는 집계하지 않는다.
          end;

          if (status in [csa요청, csa요청취소]) then // 요청 관련 data만 인지 하게 한다.
            data.incRequestCount
          else
            data.incDecideCount;
        finally
          RR_DB.Next;
        end;
      end;
    end;
  finally
    MonthGrid.Perform(WM_SETREDRAW, 1, 0);   // endupdate
    MonthGrid.Invalidate;
  end;
end;

procedure TReservationMonthForm.SakpungImageButton1Click(Sender: TObject);
var
  flashcount : Integer;
  sd : TSelectData;
begin
  CalcWorkMonth( -1 ); // 전달
  sd := TSelectData.Create( FWorkMonth );
  try
    FObserver.BeforeAction( OB_Event_DataRefresh_Month_List, sd );
    try
      flashcount := 0;
      // data를 새로 읽게 한다.
      RestCallDM.GetRRMonthData( FWorkMonth, 'S', flashcount );
    finally
      FObserver.AfterActionASync( OB_Event_DataRefresh_Month, sd );
    end;
  finally
    FreeAndNil( sd );
  end;
  FocusDay(FWorkMonth);
end;

procedure TReservationMonthForm.SakpungImageButton2Click(Sender: TObject);
var
  flashcount : Integer;
  sd : TSelectData;
begin
  CalcWorkMonth( 1 ); // 다음달
  sd := TSelectData.Create( FWorkMonth );
  try
    FObserver.BeforeAction( OB_Event_DataRefresh_Month_List, sd );
    try
      flashcount := 0;
      // data를 새로 읽게 한다.
      RestCallDM.GetRRMonthData( FWorkMonth, 'S', flashcount );
    finally
      FObserver.AfterActionASync( OB_Event_DataRefresh_Month, sd );
    end;
  finally
    FreeAndNil( sd );
  end;
  FocusDay(FWorkMonth);
end;

procedure TReservationMonthForm.SakpungImageButton3Click(Sender: TObject);
var
  flashcount : Integer;
  sd : TSelectData;
begin
  sd := TSelectData.Create( FWorkMonth );
  try
    FObserver.BeforeAction( OB_Event_DataRefresh_Month_List, sd );
    try
      if BridgeWrapperDM.BridgeActivate then
      begin
        flashcount := 0;
        // data를 새로 읽게 한다.
        RestCallDM.GetRRMonthData( FWorkMonth, 'S', flashcount )
      end;
    finally
      FObserver.AfterActionASync( OB_Event_DataRefresh_Month, sd );
    end;
  finally
    FreeAndNil( sd );
  end;

  FocusDay(FWorkMonth);
end;

procedure TReservationMonthForm.SetGridUI;
var
  i, j : Integer;
  str : string;
  sd : TDateTime;
  c : Integer;
  md : TMonthData;
begin
  MonthGrid.Perform(WM_SETREDRAW, 0, 0);   // begineupdate
  try
    ClearGrid;
    with MonthGrid do
    begin
      str := '"일","월","화","수","목","금","토"';
      Rows[ 0 ].CommaText := str;

      FDrawGrid.Day := FWorkMonth;
      sd := StartOfTheMonth( FWorkMonth ); // 지정된 월의 시작 일자
      c := DayOfWeek( sd ) -1; // 시작 일자의 요일 계산
      sd := sd - c; // grid의 시작 날자를 계산 한다.
      // grid에 요일을 출력 한다.
      for i := 1 to MonthGrid.RowCount -1 do
      begin
        for j := 0 to MonthGrid.ColCount -1 do
        begin
          c := DayOfWeek( sd ) -1;
          Cells[c, i] := FormatDateTime('d', sd);
          md := TMonthData.Create;
          Objects[c, i] := md;
          md.Day := sd;
          md.Caption := Cells[c, i];
          md.Holiday := c in [0, 6];

          sd := IncDay(sd, 1); // 1일 증가
        end;
      end;
    end;
  finally
    MonthGrid.Perform(WM_SETREDRAW, 1, 0);   // endupdate
    MonthGrid.Invalidate;
  end;
end;

procedure TReservationMonthForm.ShowPanel(AParentControl: TWinControl);
begin
  if Assigned( AParentControl ) and (Panel1.Parent <> AParentControl) then
  begin
    Panel1.Parent := AParentControl;
    Panel1.Align := alClient;
    Panel1.Visible := True;
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

procedure TReservationMonthForm.today_btnClick(Sender: TObject);
var
  flashcount : Integer;
  sd : TSelectData;
begin
  CalcWorkMonth; // 오늘날자 기준으로 변경 한다.
  sd := TSelectData.Create( FWorkMonth );
  try
    FObserver.BeforeAction( OB_Event_DataRefresh_Month_List, sd );
    try
      if BridgeWrapperDM.BridgeActivate then
      begin
        flashcount := 0;
        // data를 새로 읽게 한다.
        RestCallDM.GetRRMonthData( FWorkMonth, 'S', flashcount )
      end;
    finally
      FObserver.AfterActionASync( OB_Event_DataRefresh_Month, sd );
    end;
  finally
    FreeAndNil( sd );
  end;

  FocusDay(FWorkMonth);
end;

initialization
  GReservationMonthForm := nil;

finalization

end.
