unit TranslucentFormUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.AppEvnts;

type
  TTranslucentForm = class(TForm)
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  protected
    { protected declarations }
    procedure CreateParams( var AParams : TCreateParams ); override;
  public
    { Public declarations }
  end;

  // translucentform 위에 출력될 form들은 이 class를 상속받아 사용하게 하면 된다.
  TTranslucentSubForm = class(TForm)
  private
    { Private declarations }
    ApplicationEvents1: TApplicationEvents;
    procedure ApplicationEvents1Deactivate(Sender: TObject);
  protected
    { protected declarations }
    procedure CreateParams( var AParams : TCreateParams ); override;

    procedure Deactivate; override; // form deactive
    procedure KeyUp(var Key: Word; Shift: TShiftState); override; // key up
  public
    { Public declarations }
    constructor Create( AOwner : TComponent ); override;
    destructor Destroy; override;

    // form을 translucent위에 출력 하게 한다.
    function ShowCustomModal: Integer; virtual;
  end;


procedure InitTransForm;
procedure ShowTransForm;
function GetTransForm : TTranslucentForm;
procedure CloseTransForm;
procedure FreeTransForm;
procedure SetControlObjTransForm( ACtrl : TWinControl );


function GetTransFormHandle : THandle;

implementation
uses
  System.Types,
  RRDialogs;

var
  GTranslucentForm: TTranslucentForm;
  GControlObj : TWinControl;


{$R *.dfm}

function GetTransFormHandle : THandle;
begin
  InitTransForm;
  Result := GTranslucentForm.Handle;
end;

procedure InitTransForm;
begin
  SetGDMessageDlgParentFormHandle( GetTransForm.Handle );
end;

function GetTransForm : TTranslucentForm;
begin
  if not Assigned( GTranslucentForm ) then
    GTranslucentForm := TTranslucentForm.Create( nil );
  Result := GTranslucentForm;
end;

procedure FreeTransForm;
begin
  if Assigned( GTranslucentForm ) then
    FreeAndNil( GTranslucentForm );
end;

procedure ShowTransForm;
begin
  GetTransForm.Show;
end;

procedure CloseTransForm;
begin
  GetTransForm.Close;
end;

procedure SetControlObjTransForm( ACtrl : TWinControl );
begin
  GControlObj := ACtrl;
end;

procedure TTranslucentForm.CreateParams(var AParams: TCreateParams);
begin
  inherited;

  AParams.Style := AParams.Style or WS_BORDER or WS_THICKFRAME;  // bsnone

  if Assigned( Application.MainForm ) then
  begin
    AParams.WndParent := Application.MainForm.Handle;
  end;
end;

procedure TTranslucentForm.FormShow(Sender: TObject);
var
  rect : TRect;
//  env : TClientEnv;
//  p : TPoint;
begin
(*
  env := GetClientEnv;

  if env.fsStayOnTop then
    FormStyle := fsStayOnTop; *)

  if Assigned( Application.MainForm ) then
    FormStyle := Application.MainForm.FormStyle;

//  BringToFront;

  if Assigned( GControlObj ) then
  begin  // 제어 object위에 출력 될 수 있게 한다.
    // GetWindowRect(GControlObj.Handle, rect);

{  caption영역 만큼 더 아래로 내려온다
    rect := GControlObj.BoundsRect;
    p := GControlObj.ClientToScreen( Point(0,0) );
    rect.Offset(p.X, p.Y); }

{ 지정된 control의 안쪽 영역에 위치 한다.
    rect := GControlObj.ClientRect;
    p := GControlObj.ClientToScreen( Point(0,0) );
    rect.Offset(p.X, p.Y); }

{ 지정된 control의 안쪽 영역에 위치 한다.
    p := GControlObj.ClientToScreen( Point(0,0) );
    rect.Top := p.Y;
    rect.Left := p.X;

    rect.Bottom := rect.Top + GControlObj.Height;
    rect.Right := rect.Left + GControlObj.Width;}

{ 지정된 control의 안쪽 영역에 위치 한다.
    Constraints.MaxHeight := GControlObj.Height;
    Constraints.MinHeight := GControlObj.Height;

    Constraints.MaxWidth := GControlObj.Width;
    Constraints.MinWidth := GControlObj.Width;
    p := GControlObj.ClientToScreen( Point(0,0) );
    Left := p.x;
    Top := p.Y; }
    rect := Application.MainForm.BoundsRect;  // main form 전체에 표시
    rect.Top := rect.Top + ( Application.MainForm.ClientHeight - GControlObj.ClientHeight ) + ( (Application.MainForm.Height - Application.MainForm.ClientHeight) div 2);
  end
  else
  begin  // 제어 대상 object가 없다. main form 전체를 활용 한다.
    // GetWindowRect(Application.MainForm.Handle, rect);
    Constraints := Application.MainForm.Constraints;
    rect := Application.MainForm.BoundsRect;  // main form 전체에 표시
    //rect := Application.MainForm.ClientRect;
    //rect.Offset(Application.MainForm.Left, Application.MainForm.Top);
  end;

  BoundsRect := rect;
end;

{ TTranslucentSubForm }

procedure TTranslucentSubForm.ApplicationEvents1Deactivate(Sender: TObject);
begin
end;

constructor TTranslucentSubForm.Create(AOwner: TComponent);
begin
  inherited;
  ApplicationEvents1 := TApplicationEvents.Create( self );
  ApplicationEvents1.OnDeactivate := ApplicationEvents1Deactivate;
end;

procedure TTranslucentSubForm.CreateParams(var AParams: TCreateParams);
begin
  inherited;
  // trans
  AParams.WndParent := GetTransFormHandle;
//  AParams.WndParent := Application.MainFormHandle;
end;

procedure TTranslucentSubForm.Deactivate;
begin
  inherited;
  ModalResult := mrCancel;
end;

destructor TTranslucentSubForm.Destroy;
begin
  ApplicationEvents1.OnDeactivate := nil;
  FreeAndNil( ApplicationEvents1 );
  inherited;
end;

procedure TTranslucentSubForm.KeyUp(var Key: Word; Shift: TShiftState);
begin
  inherited;

  if key = VK_ESCAPE then
  begin
    ModalResult := mrCancel;
  end;
end;

function TTranslucentSubForm.ShowCustomModal: Integer;
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

initialization
  GTranslucentForm := nil;
  GControlObj := nil;
  InitTransForm;

finalization
  CloseTransForm;
  FreeTransForm;

end.
