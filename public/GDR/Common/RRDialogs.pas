unit RRDialogs;


interface
uses
  windows, Vcl.Dialogs, forms;

type
  T_MessageForm = class
  public
    procedure doFormShow( ASender : TObject );
    procedure doFormActivate(ASender: TObject);
    procedure doFormDeactivate(ASender: TObject);
  end;

function GDMessageDlg(const Msg: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons; HelpCtx: Longint): Integer; overload;
function GDMessageDlg(const Msg: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons; HelpCtx: Longint; AParentHandle : THandle): Integer; overload;

procedure SetGDMessageDlgParentFormHandle( AParentFormHandle : THandle );

implementation
uses
  Winapi.Messages, System.SysUtils, Vcl.Controls, Vcl.StdCtrls;

var
  G_MessageForm : T_MessageForm;
  GParentFormHandle : THandle;

function GetParentFormHandle : THandle;
begin
  Result := GParentFormHandle;
  if Result = INVALID_HANDLE_VALUE then
    Result := Application.MainFormHandle;
end;

procedure SetGDMessageDlgParentFormHandle( AParentFormHandle : THandle );
begin
  GParentFormHandle := AParentFormHandle;
end;

function GDMessageDlg(const Msg: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons; HelpCtx: Longint; AParentHandle : THandle): Integer; overload;
var
  i, cnt, p, ButtonSpacing : Integer;
  bt : array[1..12] of TButton; //  최대 button의 수
  form : TForm;
begin
  // 소리 않남
  form := CreateMessageDialog(Msg, DlgType, Buttons);
  try
    SetWindowLong(form.Handle, GWL_HWNDPARENT, AParentHandle);

    if form.Width < (Application.MainForm.Width + 40) then
    form.Width := Application.MainForm.Width + 40;

    form.Position := poMainFormCenter;
    form.OnShow := G_MessageForm.doFormShow;
    form.OnDeactivate := G_MessageForm.doFormDeactivate;
    form.OnActivate := G_MessageForm.doFormActivate;
    form.PopupMode := pmExplicit;  // pmNone, pmAuto, pmExplicit

// form의 버튼 위치 계산
    cnt := 0;
    for i := 0 to form.ComponentCount -1 do
    begin
      if form.Components[ i ] is TButton then
      begin
        Inc( cnt );
        bt[ cnt ] := TButton( form.Components[ i ] );
      end;
    end;
    if cnt > 0 then
    begin
      ButtonSpacing := 0;
      if cnt >= 2 then
        ButtonSpacing := bt[2].Left - bt[1].Left;
      p := ( form.Width - ( (bt[1].Width * cnt) + (ButtonSpacing*cnt) ) ) div 2;
      for i := 1 to cnt do
      begin
        bt[i].Left := p;
        inc(p, bt[i].Width + ButtonSpacing);
      end;
    end;

    form.FormStyle := Application.MainForm.FormStyle;

    (* Application.NormalizeTopMosts;
    try
      Result := form.ShowModal;
    finally
      Application.RestoreTopMosts;
    end; *)
    Result := form.ShowModal;
  finally
    FreeAndNil( form );
  end;
end;

function GDMessageDlg(const Msg: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons; HelpCtx: Longint): Integer; overload;
begin
  Result := GDMessageDlg( Msg, DlgType, Buttons, HelpCtx, GetParentFormHandle);
end;


{ _MessageForm }

procedure T_MessageForm.doFormDeactivate(ASender: TObject);
begin
  if Assigned( ASender ) then
  begin
    if TForm( ASender ).ModalResult = 0 then
    begin
      TForm( ASender ).BringToFront;
      TForm( ASender ).SetFocus;
    end;
  end;
end;

procedure T_MessageForm.doFormShow(ASender: TObject);
begin
(*  if Assigned( ASender ) then
  begin
//    PostMessage( TForm( Self ).Handle, WM_USER_SET_FOCUS_AT_START, 0, 0); // WM_USER_SET_FOCUS_AT_START???
  end; *)
end;

procedure T_MessageForm.doFormActivate(ASender: TObject);
begin
(*  if Assigned( ASender ) then
  begin
    if TForm( ASender ).ModalResult = 0 then
    begin
      TForm( ASender ).BringToFront;
      TForm( ASender ).SetFocus;
    end;
  end;   *)
end;

initialization
  GParentFormHandle := INVALID_HANDLE_VALUE;
  G_MessageForm := T_MessageForm.Create

finalization
  FreeAndNil( G_MessageForm );

end.
