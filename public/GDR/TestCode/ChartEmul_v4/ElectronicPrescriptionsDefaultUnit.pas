unit ElectronicPrescriptionsDefaultUnit;
(*

ALTER TABLE patient
ADD COLUMN	'gdid'	varchar ( 20 ) DEFAULT ''

ALTER TABLE patient
ADD COLUMN	'hipass'	integer DEFAULT 0

ALTER TABLE patient
ADD COLUMN	'prescription'	integer DEFAULT 0

ALTER TABLE reception
ADD COLUMN	'gdid'	varchar ( 20 ) DEFAULT ''

ALTER TABLE reception
ADD COLUMN	'parmno'	varchar ( 50 ) DEFAULT ''

ALTER TABLE reception
ADD COLUMN	'parmnm'	varchar ( 50 ) DEFAULT ''

ALTER TABLE reception
ADD COLUMN	'extrainfo'	varchar ( 50 ) DEFAULT ''
*)
interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Grids, Vcl.ValEdit,
  Vcl.StdCtrls;

type
  TElectronicPrescriptionsDefaultForm = class(TForm)
    Panel1: TPanel;
    ValueListEditor1: TValueListEditor;
    procedure ValueListEditor1GetPickList(Sender: TObject;
      const KeyName: string; Values: TStrings);
  private
    { Private declarations }
    procedure initValue;
    function GetSerialNo : Integer; // 당일 유니크한 번호
  public
    { Public declarations }
    constructor Create( AOwner : TComponent ); override;

    function Get_HospitalName : string; // 병원 이름
    function Get_HospitalAddr : string; // 병원 주소
    function Get_reimburseType : Integer; // 종별구분
    function Get_reimburseTypeName : string; // 종별명
    function Get_reimburseDetailType : string; // 보험 세부 코드
    function Get_reimburseDetailName : string; // 보험 세부 명칭
    function Get_reimburseExcpCalc : integer; // 보호 종별
    function Get_reimburseViewDetailName : string; // 처방전 표시 보험세부 이름
    function Get_excpCalcCode : string; // 본인 부담 구분 코드
    function Get_identifyingSid : string; // 보험증 번호
    function Get_relationPatnt : Integer; // 피보험자와의 관계
    function Get_organUnitNo : string; // 사업장기호
    function Get_organName : string; // 사업장 명칭
    function Get_patriotId : string; // 보훈번호
    function Get_accidentHospUnitNo : string; // 산재 요양기호
    function Get_accidentManagementNo : string; // 산재 관리번호
    function Get_accidentWorkplaceName : string; // 산재 사업자명
    function Get_accidentHappenDate : string; // 산재재해발생일
    function Get_specialCode : string; // 특정기호(산정특례)
    function Get_rxSerialNo : string; // 처방전교부번호  , 일일 연속 번호
    function Get_rxMedInfoNo : string; // 원내 교부 번호
    function Get_rxAllMedNo : string; // 원내/외 모든 교부번호
    function Get_rxMakeDate : string; // 처방전 교부 일자
    function Get_rxIssueTimestamp : string; // 처방전 발급 시간
    function Get_diagnosisCode1 : string; // 상병기호
    function Get_diagnosisCode2 : string; // 상병기호
    function Get_diagnosisCode3 : string; // 상병기호
    function Get_rxEffectivePeriod : Integer; // 처방전 유효기간
    function Get_nextVisitDate : string; // 다음 방문일
    function Get_forDispensingComment : string; // 조제시 참고 사항
    function Get_specialComment : string; // 기타 사항
    function Get_topComment1 : string; // 상단1 comment
    function Get_topComment2 : string; // 상단2 comment
    function Get_topComment3 : string; // 상단3 comment
    function Get_centerComment1 : string; // 센터1 comment
    function Get_centerComment2 : string; // 센터2 comment
    function Get_centerComment3 : string; // 센터3 comment
    function Get_bottomComment1 : string; // 하단1 comment
    function Get_bottomComment2 : string; // 하단2 comment
    function Get_bottomComment3 : string; // 하단3 comment
  end;

var
  ElectronicPrescriptionsDefaultForm: TElectronicPrescriptionsDefaultForm;

const
  EPKEY_HospitalName              = '병원이름';
  EPKEY_HospitalAddr              = '병원주소';
  EPKEY_reimburseType             = '종별구분';
  EPKEY_reimburseDetailType       = '보험 세부 코드';
  EPKEY_reimburseExcpCalc         = '보호 종별';
  EPKEY_reimburseViewDetailName   = '보험세부 이름';
  EPKEY_excpCalcCode              = '본인 부담 구분 코드';
  EPKEY_identifyingSid            = '보험증 번호';
  EPKEY_relationPatnt             = '피보험자와의 관계';
  EPKEY_organUnitNo               = '사업장기호';
  EPKEY_organName                 = '사업장 명칭';
  EPKEY_patriotId                 = '보훈 번호';
  EPKEY_accidentHospUnitNo        = '산재 요양 기호';
  EPKEY_accidentManagementNo      = '산재 관리 번호';
  EPKEY_accidentWorkplaceName     = '산재 사업자명';
  EPKEY_accidentHappenDate        = '산재 재해 발생일';
  EPKEY_specialCode               = '특정기호(산정특례)';
  EPKEY_rxSerialNo                = '처방전교부번호';
  EPKEY_rxMedInfoNo               = '원내 교부 번호';
  EPKEY_rxAllMedNo                = '원내/외 모든 교부번호';
  EPKEY_rxMakeDate                = '처방전 교부 일자';
  EPKEY_rxIssueTimestamp          = '처방전 발급 시간';
  EPKEY_diagnosisCode1            = '상병기호1';
  EPKEY_diagnosisCode2            = '상병기호2';
  EPKEY_diagnosisCode3            = '상병기호3';
  EPKEY_rxEffectivePeriod         = '처방전 유효기간';
  EPKEY_nextVisitDate             = '다음 방문일';
  EPKEY_forDispensingComment      = '조제시 참고 사항';
  EPKEY_specialComment            = '기타 사항';
  EPKEY_topComment1               = '상단1 comment';
  EPKEY_topComment2               = '상단2 comment';
  EPKEY_topComment3               = '상단3 comment';
  EPKEY_centerComment1            = '센터1 comment';
  EPKEY_centerComment2            = '센터2 comment';
  EPKEY_centerComment3            = '센터3 comment';
  EPKEY_bottomComment1            = '하단1 comment';
  EPKEY_bottomComment2            = '하단2 comment';
  EPKEY_bottomComment3            = '하단3 comment';


implementation
uses
  inifiles;
const
  SerialNoFileName = 'SerialNo.ini';

{$R *.dfm}

constructor TElectronicPrescriptionsDefaultForm.Create(AOwner: TComponent);
begin
  inherited;
  initValue;
end;

function TElectronicPrescriptionsDefaultForm.GetSerialNo: Integer;
var
  fn : string;
  d, FToday : string;
  ini : TIniFile;
begin
  fn := ExtractFilePath( Application.ExeName ) + SerialNoFileName;
  FToday := FormatDateTime( 'yyyymmdd', now); // 오늘 날자
  ini := TIniFile.Create( fn );
  try
    d := ini.ReadString('SerialNo', 'date', '');
    Result := ini.ReadInteger('SerialNo', 'no', 0);
    Inc( Result );

    if FToday <> d then
    begin // 오늘자 data가 아니다.
      Result := 0;
      ini.WriteString('SerialNo', 'date', FToday);
    end;

    ini.WriteInteger('SerialNo', 'no', Result);
  finally
    FreeAndNil( ini );
  end;
end;

function TElectronicPrescriptionsDefaultForm.Get_accidentHappenDate: string;
begin
  Result := ValueListEditor1.Values[EPKEY_accidentHappenDate];
end;

function TElectronicPrescriptionsDefaultForm.Get_accidentHospUnitNo: string;
begin
  Result := ValueListEditor1.Values[EPKEY_accidentHospUnitNo];
end;

function TElectronicPrescriptionsDefaultForm.Get_accidentManagementNo: string;
begin
  Result := ValueListEditor1.Values[EPKEY_accidentManagementNo];
end;

function TElectronicPrescriptionsDefaultForm.Get_accidentWorkplaceName: string;
begin
  Result := ValueListEditor1.Values[EPKEY_accidentWorkplaceName];
end;

function TElectronicPrescriptionsDefaultForm.Get_bottomComment1: string;
begin
  Result := ValueListEditor1.Values[EPKEY_bottomComment1];
end;

function TElectronicPrescriptionsDefaultForm.Get_bottomComment2: string;
begin
  Result := ValueListEditor1.Values[EPKEY_bottomComment2];
end;

function TElectronicPrescriptionsDefaultForm.Get_bottomComment3: string;
begin
  Result := ValueListEditor1.Values[EPKEY_bottomComment3];
end;

function TElectronicPrescriptionsDefaultForm.Get_centerComment1: string;
begin
  Result := ValueListEditor1.Values[EPKEY_centerComment1];
end;

function TElectronicPrescriptionsDefaultForm.Get_centerComment2: string;
begin
  Result := ValueListEditor1.Values[EPKEY_centerComment2];
end;

function TElectronicPrescriptionsDefaultForm.Get_centerComment3: string;
begin
  Result := ValueListEditor1.Values[EPKEY_centerComment3];
end;

function TElectronicPrescriptionsDefaultForm.Get_diagnosisCode1: string;
begin
  Result := ValueListEditor1.Values[EPKEY_diagnosisCode1];
end;

function TElectronicPrescriptionsDefaultForm.Get_diagnosisCode2: string;
begin
  Result := ValueListEditor1.Values[EPKEY_diagnosisCode2];
end;

function TElectronicPrescriptionsDefaultForm.Get_diagnosisCode3: string;
begin
  Result := ValueListEditor1.Values[EPKEY_diagnosisCode3];
end;

function TElectronicPrescriptionsDefaultForm.Get_excpCalcCode: string;
begin
  Result := ValueListEditor1.Values[EPKEY_excpCalcCode];
end;

function TElectronicPrescriptionsDefaultForm.Get_forDispensingComment: string;
begin
  Result := ValueListEditor1.Values[EPKEY_forDispensingComment];
end;

function TElectronicPrescriptionsDefaultForm.Get_HospitalAddr: string;
begin
  Result := ValueListEditor1.Values[EPKEY_HospitalAddr];
end;

function TElectronicPrescriptionsDefaultForm.Get_HospitalName: string;
begin
  Result := ValueListEditor1.Values[EPKEY_HospitalName];
end;

function TElectronicPrescriptionsDefaultForm.Get_identifyingSid: string;
begin
  Result := ValueListEditor1.Values[EPKEY_identifyingSid];
end;

function TElectronicPrescriptionsDefaultForm.Get_nextVisitDate: string;
begin
  Result := ValueListEditor1.Values[EPKEY_nextVisitDate];
end;

function TElectronicPrescriptionsDefaultForm.Get_organName: string;
begin
  Result := ValueListEditor1.Values[EPKEY_organName];
end;

function TElectronicPrescriptionsDefaultForm.Get_organUnitNo: string;
begin
  Result := ValueListEditor1.Values[EPKEY_organUnitNo];
end;

function TElectronicPrescriptionsDefaultForm.Get_patriotId: string;
begin

end;

function TElectronicPrescriptionsDefaultForm.Get_reimburseDetailName: string;
var
  p : Integer;
  str : string;
begin
  str := ValueListEditor1.Values[EPKEY_reimburseDetailType];

  p := Pos('(', str, 1);
  if p <= 0 then
    Result := str
  else
  begin
    Delete(str,1,p);
    Result := StringReplace(str,')','',[rfReplaceAll]);
  end;
end;

function TElectronicPrescriptionsDefaultForm.Get_reimburseDetailType: string;
var
  p : Integer;
  str : string;
begin
  str := ValueListEditor1.Values[EPKEY_reimburseDetailType];

  p := Pos('(', str, 1);
  if p <= 0 then
    Result := str
  else
  begin
    Result := Copy(str,1, p-1);
  end;
end;

function TElectronicPrescriptionsDefaultForm.Get_reimburseExcpCalc: integer;
var
  str : string;
begin
  if Get_reimburseType = 2 then
  begin
    str := ValueListEditor1.Values[EPKEY_reimburseType];
    Result := StrToIntDef( string( str[1] ), 1 );
  end
  else
    Result := 0;
end;

function TElectronicPrescriptionsDefaultForm.Get_reimburseType: Integer;
var
  str : string;
begin
  str := ValueListEditor1.Values[EPKEY_reimburseType];
  Result := StrToIntDef( string( str[1] ), 1 );
end;

function TElectronicPrescriptionsDefaultForm.Get_reimburseTypeName: string;
var
  str : string;
begin
  str := ValueListEditor1.Values[EPKEY_reimburseType];
  Delete(str,1,2);
  Result := str;
end;

function TElectronicPrescriptionsDefaultForm.Get_reimburseViewDetailName: string;
begin
  Result := ValueListEditor1.Values[EPKEY_reimburseViewDetailName];
end;

function TElectronicPrescriptionsDefaultForm.Get_relationPatnt: Integer;
var
  str : string;
begin
  str := ValueListEditor1.Values[EPKEY_relationPatnt];
  Result := StrToIntDef( string( str[1] ), 1 );
end;

function TElectronicPrescriptionsDefaultForm.Get_rxAllMedNo: string;
begin
  Result := ValueListEditor1.Values[EPKEY_rxAllMedNo];
end;

function TElectronicPrescriptionsDefaultForm.Get_rxEffectivePeriod: Integer;
begin
  try
    Result := strtoint( ValueListEditor1.Values[EPKEY_rxEffectivePeriod] );
  except
    Result := 14;
    ValueListEditor1.Values[EPKEY_rxEffectivePeriod] := '14';
  end;
end;

function TElectronicPrescriptionsDefaultForm.Get_rxIssueTimestamp: string;
begin
  ValueListEditor1.Values[EPKEY_rxIssueTimestamp] := FormatDateTime('yyyymmddhhnnss', now);;
  Result := ValueListEditor1.Values[EPKEY_rxIssueTimestamp];
end;

function TElectronicPrescriptionsDefaultForm.Get_rxMakeDate: string;
begin
  ValueListEditor1.Values[EPKEY_rxMakeDate] := FormatDateTime('yyyymmdd', now);
  Result := ValueListEditor1.Values[EPKEY_rxMakeDate];
end;

function TElectronicPrescriptionsDefaultForm.Get_rxMedInfoNo: string;
begin
  Result := ValueListEditor1.Values[EPKEY_rxMedInfoNo];
end;

function TElectronicPrescriptionsDefaultForm.Get_rxSerialNo: string;
var
  no : Integer;
begin
  no := GetSerialNo;
  //ValueListEditor1.Values[EPKEY_rxSerialNo] := IntToStr( no );
  //Result := ValueListEditor1.Values[EPKEY_rxSerialNo];
  Result := IntToStr( no );
end;

function TElectronicPrescriptionsDefaultForm.Get_specialCode: string;
begin
  Result := ValueListEditor1.Values[EPKEY_specialCode];
end;

function TElectronicPrescriptionsDefaultForm.Get_specialComment: string;
begin
  Result := ValueListEditor1.Values[EPKEY_specialComment];
end;

function TElectronicPrescriptionsDefaultForm.Get_topComment1: string;
begin
  Result := ValueListEditor1.Values[EPKEY_topComment1];
end;

function TElectronicPrescriptionsDefaultForm.Get_topComment2: string;
begin
  Result := ValueListEditor1.Values[EPKEY_topComment2];
end;

function TElectronicPrescriptionsDefaultForm.Get_topComment3: string;
begin
  Result := ValueListEditor1.Values[EPKEY_topComment3];
end;

procedure TElectronicPrescriptionsDefaultForm.initValue;
begin
  with ValueListEditor1 do
  begin
    Values[EPKEY_HospitalName]              :=  '빨간코이비인후과의원';
    Values[EPKEY_HospitalAddr]              :=  '서울 강남구 역삼로3길 12';

    Values[EPKEY_reimburseType]             := '1:건강보험';
    Values[EPKEY_reimburseDetailType]       := '1(공상)';
    Values[EPKEY_reimburseExcpCalc]         := '1(1종)';
    Values[EPKEY_reimburseViewDetailName]   := '중증';
    Values[EPKEY_excpCalcCode]              := 'M015';
    Values[EPKEY_identifyingSid]            := '12345678901234567890';
    Values[EPKEY_relationPatnt]             := '1:(본인)';
    Values[EPKEY_organUnitNo]               := '';
    Values[EPKEY_organName]                 := '';
    Values[EPKEY_patriotId]                 := '';
    Values[EPKEY_accidentHospUnitNo]        := '';
    Values[EPKEY_accidentManagementNo]      := '';
    Values[EPKEY_accidentWorkplaceName]     := '';
    Values[EPKEY_accidentHappenDate]        := '';
    Values[EPKEY_specialCode]               := 'V193';
    Values[EPKEY_rxSerialNo]                := '자동번호';
    Values[EPKEY_rxMedInfoNo]               := '10001';
    Values[EPKEY_rxAllMedNo]                := '[원내]10001[원외]10001';
    Values[EPKEY_rxMakeDate]                := FormatDateTime('yyyymmdd', now);
    Values[EPKEY_rxIssueTimestamp]          := FormatDateTime('yyyymmddhhnnss', now);
    Values[EPKEY_diagnosisCode1]            := 'G40.90 E23.2 E27.4';
    Values[EPKEY_diagnosisCode2]            := 'J96.19';
    Values[EPKEY_diagnosisCode3]            := '';
    Values[EPKEY_rxEffectivePeriod]         := '14';
    Values[EPKEY_nextVisitDate]             := FormatDateTime('yyyymmdd', now + 7);
    Values[EPKEY_forDispensingComment]      := '가루약으로 조제';
    Values[EPKEY_specialComment]            := '기타 사항이다';
    Values[EPKEY_topComment1]               := EPKEY_topComment1;
    Values[EPKEY_topComment2]               := EPKEY_topComment2;
    Values[EPKEY_topComment3]               := EPKEY_topComment3;
    Values[EPKEY_centerComment1]            := EPKEY_centerComment1;
    Values[EPKEY_centerComment2]            := EPKEY_centerComment2;
    Values[EPKEY_centerComment3]            := EPKEY_centerComment3;
    Values[EPKEY_bottomComment1]            := EPKEY_bottomComment1;
    Values[EPKEY_bottomComment2]            := EPKEY_bottomComment2;
    Values[EPKEY_bottomComment3]            := EPKEY_bottomComment3;
  end;
end;

procedure TElectronicPrescriptionsDefaultForm.ValueListEditor1GetPickList(
  Sender: TObject; const KeyName: string; Values: TStrings);
begin
  Values.Clear;
  if KeyName = EPKEY_reimburseType then
  begin
    Values.Add('1:건강보험');
    Values.Add('2:의료보호');
    Values.Add('3:산업재해');
    Values.Add('4:자동차보험');
    Values.Add('5:기 타');
  end
  else if KeyName = EPKEY_reimburseDetailType then
  begin
    case Get_reimburseType of
      1 : // 건강보험
        begin
          Values.Add('1(공상)');
          Values.Add('C(차상위본인부담경감)');
          Values.Add('E(차상위 만성, 18세미만)');
          Values.Add('F(E에 해당 장애인)');
          Values.Add('H(희귀난치성질환자의 국비지원대상)');
          Values.Add('R1(무자격자)');
          Values.Add('R2(보험료체납)');
          Values.Add('R3(출국자급여정지)');
        end;
      2 : ; // ValueListEditor1.Values[EPKEY_reimburseDetailType] := '보호종별 필드 사용'; // 의료보호 알아서 입력 해라
      3 : // 산업재해
        begin
          Values.Add('31(일반)');
          Values.Add('32(후유장애)');
        end;
      4 : ; //ValueListEditor1.Values[EPKEY_reimburseDetailType] := ''; // 자동차보험
      5 : // 기 타
        begin
          Values.Add('3(광주유공자보훈)');
          Values.Add('4(보훈30%감면)');
          Values.Add('5(보훈50%감면대상자)');
          Values.Add('6(보훈60%감면대상자)');
          Values.Add('8(군인가족,군요양기관)');
          Values.Add('9(군인,군무 원의 군 요양기관 이용시)');
          Values.Add('10(보훈100%감면)');
          Values.Add('11(보훈7급)');
          Values.Add('12(보훈90%감면대상자)');
          Values.Add('51(일반전액본인부담)');
        end;
    end;
  end
  else if KeyName = EPKEY_reimburseExcpCalc then
  begin
    Values.Add('1:(1종)');
    Values.Add('2:(2종)');
  end
  else if KeyName = EPKEY_relationPatnt then
  begin
    Values.Add('1:(본인)');
    Values.Add('2:(배우자)');
    Values.Add('3:(부모)');
    Values.Add('4:(자녀)');
    Values.Add('5:(기타)');
  end;

end;

end.
