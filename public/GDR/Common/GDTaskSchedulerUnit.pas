unit GDTaskSchedulerUnit;
(*
  스케줄러에 task를 등록하는 class
  지정된 프로그램이 logon시 실행 할 수 있게 처리 한다.
  가장 높은 수준의 권한으로 실행할 수 있게 설정하므로 관리자 권한으로 프로그램이 실행되어 있어야 등록 처리가 가능한다.
*)
interface
uses
  Winapi.Windows, System.Classes, System.SysUtils,
  WinTask;

type
  TGDTaskScheduleManager = class(TComponent)
  private
    { private declarations }
    FWinTasks: TWinTaskScheduler;
    FActivate: Boolean;
    FErrorMessage: string;
    procedure SetActivate(const Value: Boolean);
  protected
    { protected declarations }
  public
    { public declarations }
    constructor Create( AOwner : TComponent ); override;
    destructor Destroy; override;

    // logon시 프로그램이 시작될 수 있게 등록 한다.   실패이면 false를 반환 한다.
    // 같은 이름의 task가 존재하면 update된다.
    function AddSchedule4LogonStart( AScheduleTaskName, AScheduleTaskDescription : string; AApplicationPath : string; AArguments : string = '' ) : Boolean;
    // task 삭제, 실패이면 false를 반환 한다.
    // 삭제할 task가 없으면 "지정된 파일을 찾을 수 없습니다." error 발생
    function DeleteSchedule( AScheduleTaskName : string ) : Boolean;

    // 지정된 schedule이 존제 하는지 확인 한다. 대소문자를 가리지 않는다.
    function ScheduleExists( AScheduleTaskName : string ) : boolean; overload;

    property ErrorMessage : string read FErrorMessage;
    // schduler를 사용할 수 있는지 상태값을 관리 한다.  false이면 사용할 수 없다.
    property Activate : Boolean read FActivate write SetActivate;
  published
    { published declarations }
  end;

const
  Goodoc_Schedule_Task_Name          = 'Goodoc 비연동 예약접수 시작';
  Goodoc_Schedule_Task_Description   = '굿닥 비연동 예약접수 프로그램 입니다.';

function GetTaskScheduleManager : TGDTaskScheduleManager;
procedure FreeTaskScheduleManager;

implementation
uses
  System.Win.ComObj, System.DateUtils, Vcl.FileCtrl, Winapi.ActiveX;

var
  GTaskScheduleManager : TGDTaskScheduleManager;

function GetTaskScheduleManager : TGDTaskScheduleManager;
begin
  if not Assigned( GTaskScheduleManager ) then
    GTaskScheduleManager := TGDTaskScheduleManager.Create( nil );

  Result := GTaskScheduleManager;
end;

procedure FreeTaskScheduleManager;
begin
  if Assigned( GTaskScheduleManager ) then
    FreeAndNil( GTaskScheduleManager );
end;

function UserName: string;
var
  p: pchar;
  size: dword;
begin
  size := 1024;
  p := StrAlloc(size);
  GetUserName(p, size);
  Result := p;
  Strdispose(p);
end;

{ TGDTaskScheduleManager }

function TGDTaskScheduleManager.AddSchedule4LogonStart(AScheduleTaskName,
  AScheduleTaskDescription, AApplicationPath, AArguments: string): Boolean;
var
  td: TWinTask;
  n: integer;
  user, pwd: string;
begin
  if not FActivate then
  begin
    Result := False;
    exit;
  end;

  FErrorMessage := '';

  user := '';
  pwd := '';

  try
    with FWinTasks do
    begin
      td := NewTask; // Tasks[SelectedTaskIndex];
      with td do
      begin
        UserId := UserName;
        Description := AScheduleTaskDescription;
        LogonType := ltToken; // as current user
        Author := UserId;

        HighestRunLevel := True; // 가장 높은 수준의 권한으로 실행

        Date := Now;
        with TWinTaskExecAction(NewAction(taExec)) do
        begin
          ApplicationPath := AApplicationPath;
          Arguments := AArguments;
          WorkingDirectory := ExtractFilePath( ApplicationPath );
        end;

        NewTrigger( ttLogon ); // ttLogon -> logon event 발생시
      end;

      n := TaskFolder.RegisterTask( AScheduleTaskName, td, user, pwd);

      if n < 0 then
      begin
        FErrorMessage := TaskFolder.ErrorMessage;
        Result := False;
      end
      else
        Result := True;
    end;
  except
    on e : exception do
    begin
      FErrorMessage := format('%s(%s)',[e.Message, e.ClassName]);
      Result := False;
    end;
  end;
end;

constructor TGDTaskScheduleManager.Create(AOwner: TComponent);
begin
  inherited;

  Activate := True;
end;

function TGDTaskScheduleManager.DeleteSchedule(
  AScheduleTaskName: string): Boolean;
begin
  if not FActivate then
  begin
    Result := False;
    exit;
  end;

  FErrorMessage := '';

  try
    with FWinTasks.TaskFolder do
    begin
      if failed( DeleteTask( AScheduleTaskName ) ) then
      begin
        FErrorMessage := FWinTasks.TaskFolder.ErrorMessage;
        Result := false;
        exit;
      end;
      Result := true;
    end;
  except
    on e : exception do
    begin
      FErrorMessage := format('%s(%s)',[e.Message, e.ClassName]);
      Result := False;
    end;
  end;
end;

destructor TGDTaskScheduleManager.Destroy;
begin
  Activate := False;
  inherited;
end;

function TGDTaskScheduleManager.ScheduleExists(
  AScheduleTaskName: string): boolean;
var
  i : Integer;
begin
  Result := False;
  if not FActivate then
    exit;

  FErrorMessage := '';

  try
    for i := 0 to FWinTasks.TaskFolder.TaskCount-1 do
    begin
      if CompareText( AScheduleTaskName, FWinTasks.TaskFolder.Tasks[ i ].TaskName ) = 0 then
      begin
        Result := True;
        exit;
      end;
    end;
  except
    on e : exception do
    begin
      FErrorMessage := format('%s(%s)',[e.Message, e.ClassName]);
      Result := False;
    end;
  end;
end;

procedure TGDTaskScheduleManager.SetActivate(const Value: Boolean);
var
  hr: HResult;
begin
  if FActivate = Value then
    exit;

  if Value then
  begin
    FErrorMessage := '';

    // CoInitializeEx(nil,COINIT_MULTITHREADED);
    hr := CreateWinTaskScheduler( FWinTasks );
    if failed(hr) then
    begin
      // 실패
      if hr = NotAvailOnXp then
        FErrorMessage := 'Windows Task Scheduler 2.0 requires at least Windows Vista'
      else
        FErrorMessage := 'Error initializing TWinTaskScheduler: ' + IntToHex(hr, 8);

      FActivate := False;
      FWinTasks.Free;
      FWinTasks := nil;
      // CoUninitialize;  // multi thread에서 동작 시킬 경우
      exit;
    end;
    FActivate := True;
  end
  else
  begin
    FActivate := False;
    FWinTasks.Free;
    FWinTasks := nil;
    // CoUninitialize;  // multi thread에서 동작 시킬 경우
  end;
end;

end.
