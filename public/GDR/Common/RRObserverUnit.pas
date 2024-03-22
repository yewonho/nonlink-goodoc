unit RRObserverUnit;

interface
uses
  System.SysUtils, System.Classes;

type
  TObserverData = class( TObject )
  private
    { Private declarations }
  public
    { Public declarations }
    function CopyData : TObserverData; dynamic; abstract;
  end;

  TBeforeNotify = procedure( AEventID : Cardinal; AData : TObserverData ) of object;
  TAfterNotify = procedure( AEventID : Cardinal; AData : TObserverData ) of object;

  TCustomRRObserver = class(TComponent)
  private
    { Private declarations }
    FBeforeAction: TBeforeNotify;
    FAfterAction: TAfterNotify;
  protected
    { protected declarations }
    procedure doBeforeAction( AEventID : Cardinal; AData : TObserverData );
    procedure doAfterAction( AEventID : Cardinal; AData : TObserverData );
  public
    { public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    { published declarations }
    property OnBeforeAction : TBeforeNotify read FBeforeAction write FBeforeAction;
    property OnAfterAction : TAfterNotify read FAfterAction write FAfterAction;
  end;

  TRRObserver = class(TCustomRRObserver)
  private
    { Private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure BeforeAction( AEventID : Cardinal; AData : TObserverData = nil );
    procedure AfterAction( AEventID : Cardinal; AData : TObserverData = nil );
    procedure AfterActionASync( AEventID : Cardinal; AData : TObserverData = nil );
  published
    { published declarations }
  end;

  TRRObserverSource = class(TComponent)
  private
    { Private declarations }
    FList: TList;
    function GetCount: integer;
  protected
    { protected declarations }
    function GetObserver(AIndex: integer): TCustomRRObserver;
  public
    { public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Add(ARRObserver: TCustomRRObserver);
    procedure Del(ARRObserver: TCustomRRObserver);

    procedure BeforeAction( AEventID : Cardinal; AData : TObserverData );
    procedure AfterAction( AEventID : Cardinal; AData : TObserverData );
    procedure AfterActionASync( AEventID : Cardinal; AData : TObserverData );

    property Count: integer read GetCount;
  published
    { published declarations }
  end;

//  TObserverThread = class( TGDThread )
  TObserverThread = class( System.Classes.TThread )
  private
    { private declarations }
  protected
    { protected declarations }
    procedure Execute; override;
  public
    { public declarations }
    EventID : Cardinal;
    ObserverSource : TRRObserverSource;
    Data : TObserverData;

    constructor Create; virtual;
    destructor Destroy; override;
  end;


function _GetObserverSource: TRRObserverSource;

implementation
var
  GObserverSource : TRRObserverSource;

function _GetObserverSource: TRRObserverSource;
begin
  if not Assigned( GObserverSource ) then
    GObserverSource := TRRObserverSource.Create( nil );
  Result := GObserverSource;
end;

function CreateObserverThread : TObserverThread;
begin
  Result := TObserverThread.Create;
  Result.FreeOnTerminate := True;
end;


{ TCustomRRObserver }

constructor TCustomRRObserver.Create(AOwner: TComponent);
begin
  inherited;

  FBeforeAction := nil;
  FAfterAction := nil;

  _GetObserverSource.Add( self );
end;

destructor TCustomRRObserver.Destroy;
begin

  _GetObserverSource.Del( self );

  inherited;
end;

procedure TCustomRRObserver.doAfterAction( AEventID : Cardinal; AData: TObserverData);
begin
  if Assigned( FAfterAction ) then
    FAfterAction( AEventID, AData );
end;

procedure TCustomRRObserver.doBeforeAction( AEventID : Cardinal; AData: TObserverData);
begin
  if Assigned( FBeforeAction ) then
    FBeforeAction( AEventID, AData );
end;

{ TRRObserver }

procedure TRRObserver.AfterAction(AEventID: Cardinal; AData: TObserverData);
begin
  _GetObserverSource.AfterAction( AEventID, AData );
end;

procedure TRRObserver.AfterActionASync(AEventID: Cardinal;
  AData: TObserverData);
begin
  _GetObserverSource.AfterActionASync( AEventID, AData );
end;

procedure TRRObserver.BeforeAction(AEventID: Cardinal; AData: TObserverData);
begin
  _GetObserverSource.BeforeAction( AEventID, AData );
end;

constructor TRRObserver.Create(AOwner: TComponent);
begin
  inherited;

end;

destructor TRRObserver.Destroy;
begin

  inherited;
end;

{ TRRObserverSource }

procedure TRRObserverSource.Add(ARRObserver: TCustomRRObserver);
begin
  Del( ARRObserver );
  FList.Add( ARRObserver );
end;

procedure TRRObserverSource.AfterAction(AEventID: Cardinal; AData: TObserverData);
var
  i: integer;
  observer: TCustomRRObserver;
begin
  for i := 0 to FList.Count - 1 do
  begin
    try
      observer := GetObserver(i);
      observer.doAfterAction(AEventID, AData);
    except
    end;
  end;
end;

procedure TRRObserverSource.AfterActionASync(AEventID: Cardinal;
  AData: TObserverData);
(*var
  thread : TObserverThread; *)
begin
(*  thread := CreateObserverThread;
  thread.ObserverSource := Self;
  thread.EventID := AEventID;
  thread.Data := nil;
  if Assigned( AData ) then
    thread.Data := AData.CopyData;

  thread.Resume; *)
  AfterAction(AEventID, AData);
end;

procedure TRRObserverSource.BeforeAction(AEventID: Cardinal; AData: TObserverData);
var
  i: integer;
  observer: TCustomRRObserver;
begin
  for i := 0 to FList.Count - 1 do
  begin
    try
      observer := GetObserver(i);
      observer.doBeforeAction(AEventID, AData);
    except
    end;
  end;
end;

constructor TRRObserverSource.Create(AOwner: TComponent);
begin
  inherited;
  FList := TList.Create;
end;

procedure TRRObserverSource.Del(ARRObserver: TCustomRRObserver);
var
  index: integer;
begin
  index := FList.IndexOf( ARRObserver );
  if index >= 0 then
  begin
    FList.Items[ index ] := nil;
    FList.Delete( index );
  end;
end;

destructor TRRObserverSource.Destroy;
begin
  FreeAndNil(FList);
  inherited;
end;

function TRRObserverSource.GetCount: integer;
begin
  Result := FList.Count;
end;

function TRRObserverSource.GetObserver(AIndex: integer): TCustomRRObserver;
begin
  Result := TCustomRRObserver(FList.Items[AIndex]);
end;

{ TObserverThread }

constructor TObserverThread.Create;
begin

  inherited Create( True );
end;

destructor TObserverThread.Destroy;
begin
  if Assigned( Data ) then
    FreeAndNil( Data );
  inherited;
end;

procedure TObserverThread.Execute;
var
  i: integer;
  observer: TCustomRRObserver;
begin
  Sleep( 50 );
  for i := 0 to ObserverSource.Count - 1 do
  begin
    try
      observer := ObserverSource.GetObserver(i);
      observer.doAfterAction(EventID, Data);
    except
    end;
  end;
end;

initialization
  GObserverSource := nil;

finalization
  if Assigned(GObserverSource) then
    FreeAndNil(GObserverSource);


end.
