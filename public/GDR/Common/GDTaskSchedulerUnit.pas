unit GDTaskSchedulerUnit;
(*
  �����ٷ��� task�� ����ϴ� class
  ������ ���α׷��� logon�� ���� �� �� �ְ� ó�� �Ѵ�.
  ���� ���� ������ �������� ������ �� �ְ� �����ϹǷ� ������ �������� ���α׷��� ����Ǿ� �־�� ��� ó���� �����Ѵ�.
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

    // logon�� ���α׷��� ���۵� �� �ְ� ��� �Ѵ�.   �����̸� false�� ��ȯ �Ѵ�.
    // ���� �̸��� task�� �����ϸ� update�ȴ�.
    function AddSchedule4LogonStart( AScheduleTaskName, AScheduleTaskDescription : string; AApplicationPath : string; AArguments : string = '' ) : Boolean;
    // task ����, �����̸� false�� ��ȯ �Ѵ�.
    // ������ task�� ������ "������ ������ ã�� �� �����ϴ�." error �߻�
    function DeleteSchedule( AScheduleTaskName : string ) : Boolean;

    // ������ schedule�� ���� �ϴ��� Ȯ�� �Ѵ�. ��ҹ��ڸ� ������ �ʴ´�.
    function ScheduleExists( AScheduleTaskName : string ) : boolean; overload;

    property ErrorMessage : string read FErrorMessage;
    // schduler�� ����� �� �ִ��� ���°��� ���� �Ѵ�.  false�̸� ����� �� ����.
    property Activate : Boolean read FActivate write SetActivate;
  published
    { published declarations }
  end;

const
  Goodoc_Schedule_Task_Name          = 'Goodoc �񿬵� �������� ����';
  Goodoc_Schedule_Task_Description   = '�´� �񿬵� �������� ���α׷� �Դϴ�.';

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

        HighestRunLevel := True; // ���� ���� ������ �������� ����

        Date := Now;
        with TWinTaskExecAction(NewAction(taExec)) do
        begin
          ApplicationPath := AApplicationPath;
          Arguments := AArguments;
          WorkingDirectory := ExtractFilePath( ApplicationPath );
        end;

        NewTrigger( ttLogon ); // ttLogon -> logon event �߻���
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
      // ����
      if hr = NotAvailOnXp then
        FErrorMessage := 'Windows Task Scheduler 2.0 requires at least Windows Vista'
      else
        FErrorMessage := 'Error initializing TWinTaskScheduler: ' + IntToHex(hr, 8);

      FActivate := False;
      FWinTasks.Free;
      FWinTasks := nil;
      // CoUninitialize;  // multi thread���� ���� ��ų ���
      exit;
    end;
    FActivate := True;
  end
  else
  begin
    FActivate := False;
    FWinTasks.Free;
    FWinTasks := nil;
    // CoUninitialize;  // multi thread���� ���� ��ų ���
  end;
end;

end.
