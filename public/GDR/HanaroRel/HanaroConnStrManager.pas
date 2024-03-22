unit HanaroConnStrManager;
(*
  하나로(오스템)에 접속하기 위한 DB Connection Info를 관리
*)

interface
uses
  System.SysUtils, System.Variants, System.Classes;

type
  THanaroConnStrManager = class(TComponent)

  private
    FConnectionString: string;
    FIsUsesConnStr: Boolean;

  protected


  public
    constructor Create( AOwner : TComponent ) ; override;
    destructor Destroy; override;

    // 지정된 registry에서 connection string을 읽어서 의사랑의 connection string을 만든다.
    function ReadRegistry : Boolean; // HKEY_CURRENT_USER

    property ConnectionString : string read FConnectionString;
    property IsUsesConnStr : Boolean read FIsUsesConnStr;

  end;

implementation
uses
  Winapi.Windows, registry, inifiles, Winsock, GDLog, System.RegularExpressions;

const
  HospitalIDPath = 'SOFTWARE\goodoc_v40'; // registry에서 의사랑 connection string이 저장된 위치


constructor THanaroConnStrManager.Create(AOwner: TComponent);
begin
  inherited;
  FIsUsesConnStr := False;
  FConnectionString := '';
end;

destructor THanaroConnStrManager.Destroy;
begin
  FIsUsesConnStr := False;
  FConnectionString := '';

  inherited;
end;

function THanaroConnStrManager.ReadRegistry : Boolean;
var
  str : string;
  reg : TRegistry;
begin
  reg := TRegistry.Create( KEY_READ or KEY_WOW64_64KEY );
  try
    try
      reg.RootKey := HKEY_CURRENT_USER;
      reg.OpenKey( HospitalIDPath, True );
      str := TrimLeft( reg.ReadString( 'hd' ) );
      str := TrimRight( str );

      str := Format(str, ['osstem']);

      FConnectionString := str;

      Result := True;

      AddLog( doValueLog, 'DBConnection Read : ' + FConnectionString );
    except
      on e : exception do
      begin
        Result := False;
        FConnectionString := '';
        AddExceptionLog('THanaroConnStrManager.RestRegistry', e);
      end;
    end;
  finally
    FreeAndNil( reg );
  end;
end;

end.
