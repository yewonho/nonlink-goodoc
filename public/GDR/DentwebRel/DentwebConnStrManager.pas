unit DentwebConnStrManager;

interface
uses
  System.SysUtils, System.Variants, System.Classes;

type
  TDentwebConnStrManager = class(TComponent)

  private
    FConnectionString: string;
    FIsUsesConnStr: Boolean;

    FBaseLocalConnectionString: string;
    FBaseRemoteConnectionString: string;

    { util function }
    //function StrXOR( AXORStr : AnsiString ) : AnsiString;

  protected

  public
    constructor Create( AOwner : TComponent ) ; override;
    destructor Destroy; override;

    //function ReadRegistry : Boolean; // HKEY_CURRENT_USER
    //function SetConnStr( AConnStr : string ) : Boolean;

    property ConnectionString : string read FConnectionString;
    property IsUsesConnStr : Boolean read FIsUsesConnStr;

    property BaseLocalConnectionString: string read FBaseLocalConnectionString;
    property BaseRemoteConnectionString: string read FBaseRemoteConnectionString;

  end;


implementation
uses
  Winapi.Windows, registry, Winsock, GDLog, RREnvUnit;

const
  DefaultDataBaseName = 'DentWeb';
  BaseLocalConnStrFormat =
    'Provider=SQLNCLI10;Integrated Security=SSPI;Persist Security Info=False;' +
    'Initial Catalog=DentWeb;Data Source=.\DentWeb;Use Procedure for Prepare=1;' +
    'Auto Translate=True;Packet Size=4096;Use Encryption for Data=False;';
  BaseRemoteConnStrFormat =
    'Provider=SQLNCLI10;Persist Security Info=False;User ID=gd;Password=goodoc;' +
    'Initial Catalog=DentWeb;Data Source=192.168.0.1\DentWeb;Use Procedure for Prepare=1;' +
    'Auto Translate=True;Packet Size=4096;Use Encryption for Data=False;';

  HospitalIDPath = 'SOFTWARE\goodoc_v40';

constructor TDentwebConnStrManager.Create(AOwner: TComponent);
var
  env : TRREnv;
  dataSource : string;
begin
  inherited;
  FIsUsesConnStr := False;

  env := GetRREnv;
  FConnectionString := env.ChartDBConnectionString;
  FBaseLocalConnectionString := BaseLocalConnStrFormat;
  FBaseRemoteConnectionString := BaseRemoteConnStrFormat;
end;

destructor TDentwebConnStrManager.Destroy;
begin
  FIsUsesConnStr := False;
  FConnectionString := '';

  inherited;
end;

end.
