unit RoomFilter;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.ExtCtrls, Vcl.Grids, Vcl.AppEvnts,
  RnRData;

type
  TRoomFilterForm = class(TForm)
    Panel1: TPanel;
    RoomGrid: TStringGrid;
    ApplicationEvents1: TApplicationEvents;
    procedure RoomGridMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure RoomGridMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure RoomGridKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure RoomGridKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure RoomGridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure RoomGridClick(Sender: TObject);
    procedure ApplicationEvents1Deactivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormDeactivate(Sender: TObject);
    procedure FormClick(Sender: TObject);
  private
    { Private declarations }
    iskeydown : Boolean;
    FSelectRoomInfo : TRoomInfo;

    procedure SetUI( ADispRect : TRect; ASelectRoomCode : string = '' );
    procedure ClearUI;
  protected
    { protected declarations }
    procedure CreateParams( var AParams : TCreateParams ); override;
  public
    { Public declarations }
    function ShowCustomModal: Integer; virtual;
    function ShowRoomSelect( ADispRect : TRect; var ARoomInfo : TRoomInfo ) : Integer;

    constructor Create( AOwner : TComponent ); override;
    destructor Destroy; override;
  end;

const  // 진료실 목록 출력
  GDC_RoomSelect_Title      = $006DB10D;
  GDC_RoomSelect_TitleFont  = clWhite;
  //GDC_RoomSelect_SelectItem =  $00C8F6B8;
  GDC_RoomSelect_SelectItem = $00FFEFD5;


var
  RoomFilterForm: TRoomFilterForm;

function ShowRoomFilterForm( ADispRect : TRect; var ARoomInfo : TRoomInfo ) : integer;

implementation
uses
  System.Types,
  TranslucentFormUnit, RnRDMUnit;

function ShowRoomFilterForm( ADispRect : TRect; var ARoomInfo : TRoomInfo ) : integer;
var
  form : TRoomFilterForm;
begin
  Result := mrCancel;
  if RnRDM.Room_DB.RecordCount <= 1 then
    exit;

  form := TRoomFilterForm.Create( nil );
  try
    Result := form.ShowRoomSelect( ADispRect, ARoomInfo );
  finally
    FreeAndNil( form );
  end;
end;

{$R *.dfm}

procedure TRoomFilterForm.ApplicationEvents1Deactivate(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TRoomFilterForm.ClearUI;
var
  i : Integer;
  data : TObject;
begin
  for i := 0 to RoomGrid.RowCount -1 do
  begin
    data := RoomGrid.Objects[0, i];
    if Assigned(data) then
    begin
      RoomGrid.Objects[0, i] := nil;
      FreeAndNil( data );
    end;
  end;
end;

constructor TRoomFilterForm.Create(AOwner: TComponent);
begin
  inherited;
  iskeydown := False;
  FSelectRoomInfo.RoomCode := '';
  FSelectRoomInfo.RoomName := '';
  FSelectRoomInfo.DeptCode := '';
  FSelectRoomInfo.DeptName := '';
  FSelectRoomInfo.DoctorCode := '';
  FSelectRoomInfo.DoctorName := '';
end;

procedure TRoomFilterForm.CreateParams(var AParams: TCreateParams);
begin
  inherited;

  AParams.WndParent := GetTransForm.Handle;
end;

destructor TRoomFilterForm.Destroy;
begin
  ClearUI;

  inherited;
end;

procedure TRoomFilterForm.FormClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TRoomFilterForm.FormDeactivate(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TRoomFilterForm.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key = VK_ESCAPE then
    ModalResult := mrCancel;
end;

procedure TRoomFilterForm.FormShow(Sender: TObject);
begin
  FormStyle := Application.MainForm.FormStyle;
  RoomGrid.SetFocus;
end;

procedure TRoomFilterForm.SetUI(ADispRect: TRect; ASelectRoomCode : string);
var
  index, h : Integer;
  selectrow : Integer;
  rect, dr : TRect;
  data : TRoomInfoData;
begin
  RoomGrid.Perform(WM_SETREDRAW, 0, 0);   // begineupdate
  try
    ClearUI;

    index := 0;
    data := TRoomInfoData.Create;
    data.RoomCode := '';
    data.RoomName := '전체';
    selectrow := 0;

    RoomGrid.DefaultColWidth := RoomGrid.Width;

    RoomGrid.Cells[0, index] := data.RoomName;
    RoomGrid.Objects[0, index] := data;

    RnRDM.Room_DB.First;
    while not RnRDM.Room_DB.Eof do
    begin
      Inc( index );
      data := TRoomInfoData.Create;
      data.RoomCode := RnRDM.Room_DB.FieldByName( 'roomcode' ).AsString;
      data.RoomName := RnRDM.Room_DB.FieldByName( 'roomname' ).AsString;
      data.DeptCode := RnRDM.Room_DB.FieldByName( 'deptcode' ).AsString;
      data.DeptName := RnRDM.Room_DB.FieldByName( 'deptname' ).AsString;
      data.DoctorCode := RnRDM.Room_DB.FieldByName( 'doctorcode' ).AsString;
      data.DoctorName := RnRDM.Room_DB.FieldByName( 'doctorname' ).AsString;

      RoomGrid.Cells[0, index] := data.RoomName;
      RoomGrid.Objects[0, index] := data;

      if ASelectRoomCode <> '' then
      begin
        if CompareStr(ASelectRoomCode, data.RoomCode ) = 0 then
          selectrow := index;
      end;

      RnRDM.Room_DB.Next;
    end;
    RoomGrid.RowCount := index + 1;
    RoomGrid.Row := selectrow;

    h := RoomGrid.DefaultRowHeight * RoomGrid.RowCount + RoomGrid.RowCount;

    dr.Left := ADispRect.Left + ( ADispRect.Right - ADispRect.Left - Width ) div 2;
    dr.Top := ADispRect.Top + ( ADispRect.Bottom - ADispRect.Top - Height ) div 2;

    GetWindowRect(Application.MainFormHandle, rect);
    dr.Right := dr.Left + Width;

    if rect.Bottom < (rect.Top + h + 2)  then
      h := h - ( (rect.Top + h + 2) - rect.Bottom );

    Panel1.Height := h;
    dr.Bottom := dr.Top + h + 2;

    BoundsRect := dr;
  finally
    RoomGrid.Perform(WM_SETREDRAW, 1, 0);   // endupdate
    RoomGrid.Invalidate;
  end;
end;

function TRoomFilterForm.ShowCustomModal: Integer;
var
  //WindowList: TTaskWindowList;
  LSaveFocusState: TFocusState;
  SaveCursor: TCursor;
  SaveCount: Integer;
  ActiveWindow: HWnd;
begin
  CancelDrag;
//  if Visible or not Enabled or (fsModal in FFormState) or (FormStyle = fsMDIChild) then
//    raise EInvalidOperation.Create(SCannotShowModal);

//  if GetCapture <> 0 then
//    SendMessage(GetCapture, WM_CANCELMODE, 0, 0);

//  ReleaseCapture;
  Application.ModalStarted;
  try
    { RecreateWnd could change the active window }
    ActiveWindow := GetActiveWindow;
    Include(FFormState, fsModal);
    if (PopupMode = pmNone) and (Application.ModalPopupMode <> pmNone) then
    begin
      RecreateWnd;
      HandleNeeded;
      { The active window might have become invalid, refresh it }
      if (ActiveWindow = 0) or not IsWindow(ActiveWindow) then
        ActiveWindow := GetActiveWindow;
    end;
    LSaveFocusState := SaveFocusState;
    Screen.SaveFocusedList.Insert(0, Screen.FocusedForm);
    Screen.FocusedForm := Self;
    SaveCursor := Screen.Cursor;
    Screen.Cursor := crDefault;
    SaveCount := Screen.CursorCount;
//    WindowList := DisableTaskWindows(0);
    try
      Show;
      try
        SendMessage(Handle, CM_ACTIVATE, 0, 0);
        ModalResult := 0;
        repeat
          Application.HandleMessage;
          if Application.Terminated then ModalResult := mrCancel else
            if ModalResult <> 0 then CloseModal;
        until ModalResult <> 0;
        Result := ModalResult;
        SendMessage(Handle, CM_DEACTIVATE, 0, 0);
        if GetActiveWindow <> Handle then ActiveWindow := 0;
      finally
        Hide;
      end;
    finally
      if Screen.CursorCount = SaveCount then
        Screen.Cursor := SaveCursor
      else Screen.Cursor := crDefault;
//      EnableTaskWindows(WindowList);
      if Screen.SaveFocusedList.Count > 0 then
      begin
        Screen.FocusedForm := TCustomForm(Screen.SaveFocusedList.First);
        Screen.SaveFocusedList.Remove(Screen.FocusedForm);
      end else Screen.FocusedForm := nil;
      { ActiveWindow might have been destroyed and using it as active window will
        force Windows to activate another application }
//      if (ActiveWindow <> 0) and not IsWindow(ActiveWindow) then
//        ActiveWindow := FindTopMostWindow(0);
      if ActiveWindow <> 0 then
        SetActiveWindow(ActiveWindow);
      RestoreFocusState(LSaveFocusState);
      Exclude(FFormState, fsModal);
    end;
  finally
    Application.ModalFinished;
  end;
end;

function TRoomFilterForm.ShowRoomSelect(ADispRect: TRect; var ARoomInfo : TRoomInfo): Integer;
var
  sfiltercode : string;
begin
  sfiltercode := ARoomInfo.RoomCode;
  ARoomInfo.RoomCode := '';
  ARoomInfo.RoomName := '';
  ARoomInfo.DeptCode := '';
  ARoomInfo.DeptName := '';
  ARoomInfo.DoctorCode := '';
  ARoomInfo.DoctorName := '';

  SetUI( ADispRect, sfiltercode );

  Result := ShowCustomModal;
  if Result = mrOk then
  begin
    ARoomInfo.RoomCode := FSelectRoomInfo.RoomCode;
    ARoomInfo.RoomName := FSelectRoomInfo.RoomName;
    ARoomInfo.DeptCode := FSelectRoomInfo.DeptCode;
    ARoomInfo.DeptName := FSelectRoomInfo.DeptName;
    ARoomInfo.DoctorCode := FSelectRoomInfo.DoctorCode;
    ARoomInfo.DoctorName := FSelectRoomInfo.DoctorName;
  end;
end;

procedure TRoomFilterForm.RoomGridClick(Sender: TObject);
var
  data : TRoomInfoData;
begin
  if iskeydown then
    exit;

  data := TRoomInfoData( RoomGrid.Objects[ 0, RoomGrid.Row ] );
  if Assigned( data ) then
  begin
    FSelectRoomInfo.RoomCode := data.RoomCode;
    FSelectRoomInfo.RoomName := data.RoomName;
    FSelectRoomInfo.DeptCode := data.DeptCode;
    FSelectRoomInfo.DeptName := data.DeptName;
    FSelectRoomInfo.DoctorCode := data.DoctorCode;
    FSelectRoomInfo.DoctorName := data.DoctorName;

    if FSelectRoomInfo.RoomName <> '' then
    begin
      ModalResult := mrOk;
    end;
  end;
end;

procedure TRoomFilterForm.RoomGridDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  data : string;
  sg : TStringGrid;
begin
  sg := TStringGrid( Sender );

  if gdSelected in State then
    sg.Canvas.Brush.Color := GDC_RoomSelect_SelectItem
  else
    sg.Canvas.Brush.Color := clWhite;

  sg.Canvas.Brush.Style := bsSolid;
  sg.Canvas.Pen.Style := psClear;
  sg.Canvas.FillRect(Rect);
  sg.Canvas.FrameRect( Rect );

  data := sg.Cells[ACol, ARow];

  sg.Canvas.Font.Assign( sg.Font );
  sg.Canvas.TextRect(Rect, data, [tfCenter, tfVerticalCenter, tfSingleLine, tfEndEllipsis]);
end;

procedure TRoomFilterForm.RoomGridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  iskeydown := VK_RETURN <> key;
  if not iskeydown then
  begin
    RoomGrid.OnClick( RoomGrid );
  end;
end;

procedure TRoomFilterForm.RoomGridKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  iskeydown := False;
end;

procedure TRoomFilterForm.RoomGridMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  // mouse wheel로 인해 click event가 발생되지 않게 코드 추가함.
  Handled := True;
end;

procedure TRoomFilterForm.RoomGridMouseWheelUp(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  // mouse wheel로 인해 click event가 발생되지 않게 코드 추가함.
  Handled := True;
end;

end.
