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
    function GetSerialNo : Integer; // ���� ����ũ�� ��ȣ
  public
    { Public declarations }
    constructor Create( AOwner : TComponent ); override;

    function Get_HospitalName : string; // ���� �̸�
    function Get_HospitalAddr : string; // ���� �ּ�
    function Get_reimburseType : Integer; // ��������
    function Get_reimburseTypeName : string; // ������
    function Get_reimburseDetailType : string; // ���� ���� �ڵ�
    function Get_reimburseDetailName : string; // ���� ���� ��Ī
    function Get_reimburseExcpCalc : integer; // ��ȣ ����
    function Get_reimburseViewDetailName : string; // ó���� ǥ�� ���輼�� �̸�
    function Get_excpCalcCode : string; // ���� �δ� ���� �ڵ�
    function Get_identifyingSid : string; // ������ ��ȣ
    function Get_relationPatnt : Integer; // �Ǻ����ڿ��� ����
    function Get_organUnitNo : string; // ������ȣ
    function Get_organName : string; // ����� ��Ī
    function Get_patriotId : string; // ���ƹ�ȣ
    function Get_accidentHospUnitNo : string; // ���� ����ȣ
    function Get_accidentManagementNo : string; // ���� ������ȣ
    function Get_accidentWorkplaceName : string; // ���� ����ڸ�
    function Get_accidentHappenDate : string; // �������ع߻���
    function Get_specialCode : string; // Ư����ȣ(����Ư��)
    function Get_rxSerialNo : string; // ó�������ι�ȣ  , ���� ���� ��ȣ
    function Get_rxMedInfoNo : string; // ���� ���� ��ȣ
    function Get_rxAllMedNo : string; // ����/�� ��� ���ι�ȣ
    function Get_rxMakeDate : string; // ó���� ���� ����
    function Get_rxIssueTimestamp : string; // ó���� �߱� �ð�
    function Get_diagnosisCode1 : string; // �󺴱�ȣ
    function Get_diagnosisCode2 : string; // �󺴱�ȣ
    function Get_diagnosisCode3 : string; // �󺴱�ȣ
    function Get_rxEffectivePeriod : Integer; // ó���� ��ȿ�Ⱓ
    function Get_nextVisitDate : string; // ���� �湮��
    function Get_forDispensingComment : string; // ������ ���� ����
    function Get_specialComment : string; // ��Ÿ ����
    function Get_topComment1 : string; // ���1 comment
    function Get_topComment2 : string; // ���2 comment
    function Get_topComment3 : string; // ���3 comment
    function Get_centerComment1 : string; // ����1 comment
    function Get_centerComment2 : string; // ����2 comment
    function Get_centerComment3 : string; // ����3 comment
    function Get_bottomComment1 : string; // �ϴ�1 comment
    function Get_bottomComment2 : string; // �ϴ�2 comment
    function Get_bottomComment3 : string; // �ϴ�3 comment
  end;

var
  ElectronicPrescriptionsDefaultForm: TElectronicPrescriptionsDefaultForm;

const
  EPKEY_HospitalName              = '�����̸�';
  EPKEY_HospitalAddr              = '�����ּ�';
  EPKEY_reimburseType             = '��������';
  EPKEY_reimburseDetailType       = '���� ���� �ڵ�';
  EPKEY_reimburseExcpCalc         = '��ȣ ����';
  EPKEY_reimburseViewDetailName   = '���輼�� �̸�';
  EPKEY_excpCalcCode              = '���� �δ� ���� �ڵ�';
  EPKEY_identifyingSid            = '������ ��ȣ';
  EPKEY_relationPatnt             = '�Ǻ����ڿ��� ����';
  EPKEY_organUnitNo               = '������ȣ';
  EPKEY_organName                 = '����� ��Ī';
  EPKEY_patriotId                 = '���� ��ȣ';
  EPKEY_accidentHospUnitNo        = '���� ��� ��ȣ';
  EPKEY_accidentManagementNo      = '���� ���� ��ȣ';
  EPKEY_accidentWorkplaceName     = '���� ����ڸ�';
  EPKEY_accidentHappenDate        = '���� ���� �߻���';
  EPKEY_specialCode               = 'Ư����ȣ(����Ư��)';
  EPKEY_rxSerialNo                = 'ó�������ι�ȣ';
  EPKEY_rxMedInfoNo               = '���� ���� ��ȣ';
  EPKEY_rxAllMedNo                = '����/�� ��� ���ι�ȣ';
  EPKEY_rxMakeDate                = 'ó���� ���� ����';
  EPKEY_rxIssueTimestamp          = 'ó���� �߱� �ð�';
  EPKEY_diagnosisCode1            = '�󺴱�ȣ1';
  EPKEY_diagnosisCode2            = '�󺴱�ȣ2';
  EPKEY_diagnosisCode3            = '�󺴱�ȣ3';
  EPKEY_rxEffectivePeriod         = 'ó���� ��ȿ�Ⱓ';
  EPKEY_nextVisitDate             = '���� �湮��';
  EPKEY_forDispensingComment      = '������ ���� ����';
  EPKEY_specialComment            = '��Ÿ ����';
  EPKEY_topComment1               = '���1 comment';
  EPKEY_topComment2               = '���2 comment';
  EPKEY_topComment3               = '���3 comment';
  EPKEY_centerComment1            = '����1 comment';
  EPKEY_centerComment2            = '����2 comment';
  EPKEY_centerComment3            = '����3 comment';
  EPKEY_bottomComment1            = '�ϴ�1 comment';
  EPKEY_bottomComment2            = '�ϴ�2 comment';
  EPKEY_bottomComment3            = '�ϴ�3 comment';


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
  FToday := FormatDateTime( 'yyyymmdd', now); // ���� ����
  ini := TIniFile.Create( fn );
  try
    d := ini.ReadString('SerialNo', 'date', '');
    Result := ini.ReadInteger('SerialNo', 'no', 0);
    Inc( Result );

    if FToday <> d then
    begin // ������ data�� �ƴϴ�.
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
    Values[EPKEY_HospitalName]              :=  '�������̺����İ��ǿ�';
    Values[EPKEY_HospitalAddr]              :=  '���� ������ �����3�� 12';

    Values[EPKEY_reimburseType]             := '1:�ǰ�����';
    Values[EPKEY_reimburseDetailType]       := '1(����)';
    Values[EPKEY_reimburseExcpCalc]         := '1(1��)';
    Values[EPKEY_reimburseViewDetailName]   := '����';
    Values[EPKEY_excpCalcCode]              := 'M015';
    Values[EPKEY_identifyingSid]            := '12345678901234567890';
    Values[EPKEY_relationPatnt]             := '1:(����)';
    Values[EPKEY_organUnitNo]               := '';
    Values[EPKEY_organName]                 := '';
    Values[EPKEY_patriotId]                 := '';
    Values[EPKEY_accidentHospUnitNo]        := '';
    Values[EPKEY_accidentManagementNo]      := '';
    Values[EPKEY_accidentWorkplaceName]     := '';
    Values[EPKEY_accidentHappenDate]        := '';
    Values[EPKEY_specialCode]               := 'V193';
    Values[EPKEY_rxSerialNo]                := '�ڵ���ȣ';
    Values[EPKEY_rxMedInfoNo]               := '10001';
    Values[EPKEY_rxAllMedNo]                := '[����]10001[����]10001';
    Values[EPKEY_rxMakeDate]                := FormatDateTime('yyyymmdd', now);
    Values[EPKEY_rxIssueTimestamp]          := FormatDateTime('yyyymmddhhnnss', now);
    Values[EPKEY_diagnosisCode1]            := 'G40.90 E23.2 E27.4';
    Values[EPKEY_diagnosisCode2]            := 'J96.19';
    Values[EPKEY_diagnosisCode3]            := '';
    Values[EPKEY_rxEffectivePeriod]         := '14';
    Values[EPKEY_nextVisitDate]             := FormatDateTime('yyyymmdd', now + 7);
    Values[EPKEY_forDispensingComment]      := '��������� ����';
    Values[EPKEY_specialComment]            := '��Ÿ �����̴�';
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
    Values.Add('1:�ǰ�����');
    Values.Add('2:�ǷẸȣ');
    Values.Add('3:�������');
    Values.Add('4:�ڵ�������');
    Values.Add('5:�� Ÿ');
  end
  else if KeyName = EPKEY_reimburseDetailType then
  begin
    case Get_reimburseType of
      1 : // �ǰ�����
        begin
          Values.Add('1(����)');
          Values.Add('C(���������κδ�氨)');
          Values.Add('E(������ ����, 18���̸�)');
          Values.Add('F(E�� �ش� �����)');
          Values.Add('H(��ͳ�ġ����ȯ���� �����������)');
          Values.Add('R1(���ڰ���)');
          Values.Add('R2(�����ü��)');
          Values.Add('R3(�ⱹ�ڱ޿�����)');
        end;
      2 : ; // ValueListEditor1.Values[EPKEY_reimburseDetailType] := '��ȣ���� �ʵ� ���'; // �ǷẸȣ �˾Ƽ� �Է� �ض�
      3 : // �������
        begin
          Values.Add('31(�Ϲ�)');
          Values.Add('32(�������)');
        end;
      4 : ; //ValueListEditor1.Values[EPKEY_reimburseDetailType] := ''; // �ڵ�������
      5 : // �� Ÿ
        begin
          Values.Add('3(���������ں���)');
          Values.Add('4(����30%����)');
          Values.Add('5(����50%��������)');
          Values.Add('6(����60%��������)');
          Values.Add('8(���ΰ���,�������)');
          Values.Add('9(����,���� ���� �� ����� �̿��)');
          Values.Add('10(����100%����)');
          Values.Add('11(����7��)');
          Values.Add('12(����90%��������)');
          Values.Add('51(�Ϲ����׺��κδ�)');
        end;
    end;
  end
  else if KeyName = EPKEY_reimburseExcpCalc then
  begin
    Values.Add('1:(1��)');
    Values.Add('2:(2��)');
  end
  else if KeyName = EPKEY_relationPatnt then
  begin
    Values.Add('1:(����)');
    Values.Add('2:(�����)');
    Values.Add('3:(�θ�)');
    Values.Add('4:(�ڳ�)');
    Values.Add('5:(��Ÿ)');
  end;

end;

end.
