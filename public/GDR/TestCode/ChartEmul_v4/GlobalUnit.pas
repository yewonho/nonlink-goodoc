unit GlobalUnit;

interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  BridgeCommUnit;

var
  GSendReceptionPeriod : Boolean;  // 변경된 대기 순서를 전송 한다.
  GSendReceptionPeriodRoomInfo : TRoomInfoRecord; // 대기 순서를 전송할 진료실 정보

var
  GHospitalNo : string; // 요양기관 번호
  GChartCode : Cardinal; // 차트 코드
  GElectronicPrescriptionsOption : Integer;
  GBridgeFactory : TBridgeFactory; // 통신 event class 생성기

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
