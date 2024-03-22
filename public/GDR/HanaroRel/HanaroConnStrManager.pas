unit HanaroConnStrManager;
(*
  �ϳ���(������)�� �����ϱ� ���� DB Connection Info�� ����
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

    // ������ registry���� connection string�� �о �ǻ���� connection string�� �����.
    function ReadRegistry : Boolean; // HKEY_CURRENT_USER

    property ConnectionString : string read FConnectionString;
    property IsUsesConnStr : Boolean read FIsUsesConnStr;

  end;

implementation
uses
  Winapi.Windows, registry, inifiles, Winsock, GDLog, System.RegularExpressions;

const
  HospitalIDPath = 'SOFTWARE\goodoc_v40'; // registry���� �ǻ�� connection string�� ����� ��ġ


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
