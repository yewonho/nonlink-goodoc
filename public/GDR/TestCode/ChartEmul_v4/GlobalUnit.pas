unit GlobalUnit;

interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  BridgeCommUnit;

var
  GSendReceptionPeriod : Boolean;  // ����� ��� ������ ���� �Ѵ�.
  GSendReceptionPeriodRoomInfo : TRoomInfoRecord; // ��� ������ ������ ����� ����

var
  GHospitalNo : string; // ����� ��ȣ
  GChartCode : Cardinal; // ��Ʈ �ڵ�
  GElectronicPrescriptionsOption : Integer;
  GBridgeFactory : TBridgeFactory; // ��� event class ������

procedure LoadEnv;
procedure SaveEnv;

implementation
uses
  inifiles;
const
  ENVFileName = 'Emul.ini';

procedure LoadEnv;
var
  fn : string;
  ini : TIniFile;
begin
  fn := ExtractFilePath( ParamStr(0) ) + ENVFileName;
  ini := TIniFile.Create( fn );
  try
    GHospitalNo := ini.ReadString('Hospital', 'No', '');
    GChartCode := ini.ReadInteger('Hospital', 'ChartCode', 0);
  finally
    FreeAndNil( ini );
  end;
end;

procedure SaveEnv;
var
  fn : string;
  ini : TIniFile;
begin
  fn := ExtractFilePath( ParamStr(0) ) + ENVFileName;
  ini := TIniFile.Create( fn );
  try
    ini.WriteString('Hospital', 'No', GHospitalNo);
    ini.WriteInteger('Hospital', 'ChartCode', GChartCode);
  finally
    FreeAndNil( ini );
  end;
end;

initialization
  GElectronicPrescriptionsOption := 0;

end.
