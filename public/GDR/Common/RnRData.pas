unit RnRData;

interface
uses
  Data.DB,
  RRObserverUnit,
  BridgeCommUnit;

type
  TRnRType = (rrReception, rrReservation);              // ���� type, ����/����

//  TRnRDataState = (rrsRequest, rrsDecide, rrsRequestVisite, rrsVisiteDecide, rrsFinish );  // ���� ���� type,  ��û/Ȯ��/�����ͤ���û/����Ȯ��/�Ϸ�
  TRnRDataStatus = (
        rrsUnknown, // �˼� ���� ����
        rrs�����û,      // Status_�����û = 'S01';
        rrs�������,      // Status_������� = 'S02'; // ���� ��û data�� ���� �Ϸ� �� ��Ҹ� �ϸ� ���з� ����.
        rrs����Ϸ�,      // Status_����Ϸ� = 'S03';
        rrs������û,      // Status_������û = 'C01';
        rrs��������,      // Status_�������� = 'C02'; // ���� ��û data�� ���� �Ϸ� �� ��Ҹ� �ϸ� ���з� ����.
        rrs�����Ϸ�,      // Status_�����Ϸ� = 'C03';
        rrs������,      // Status_������ = 'C04';
        rrs������û,      // Status_������û = 'C05';
        rrs����Ȯ��,      // Status_����Ȯ�� = 'C06';
        rrs��������,      // Status_�������� = 'C07';
        rrs��ҿ�û,      // Status_��ҿ�û = 'F01';
        rrs�������,      // Status_������� = 'F02';
        rrs�������,      // Status_������� = 'F03';
        rrs�ڵ����,      // Status_�ڵ���� = 'F04';
        rrs����Ϸ�,       // Status_����Ϸ� = 'F05';
        rrs�����Ϸ�_new   // ������ Ȯ���� �����Ϸ�
    );
  TConvertState4App = (
      csa��û, // ��û(Ȯ�� ��ư ���), rrs�����û, rrs������û, rrsUnknown(���� ��û���� ����)
      csa��û���, // ��û ��� ����, rrs���ο�û���, rrs������û���
      csaȯ��Ȯ��, // ȯ�� Ȯ��(��û, ���� ��ư ���), rrs����Ϸ�,
      csaȯ��Ȯ��Disable, //  rrs������û(��û ��ư disable)
      csaȯ�ڳ���, // ����(��û ��ư disable, ���� ��ư ���), rrs�����Ϸ�, rrs����Ȯ��
      csa������, // ���� ó��(�Ϸ� ��ư ���), rrs��������, rrs������
      csa����Ϸ�, // �Ϸ�, rrs����Ϸ�
      csa���     // ���, rrs�������, rrs�������, rrs�ڵ����, rrs�������, rrs��������, rrs��ҿ�û(��� ���·� ����)
    );

  TRnRInDevice = ( rrifUnknown, rriftablet, rrifBridge, rrifApp );     // ���� type, tablet/web/mobile

  TRnRGenderType = (rrgtUnknown, rrgtMale, rrgtFemale );  // ����

  TRRDataTypeConvert = class
  public
    { Public declarations }
    // ����/���� ����
    class function DataType2RnRType( ADateType : String ) : TRnRType;
    class function RnRType2DataType( ARnRType : TRnRType ) : string;

    // ���� ����
    class function RnRDataStatus2DataStatus( ARnRDataStatus : TRnRDataStatus ) : string;
    class function RnRDataStatus2DispStr2( ARnRType : TRnRType; A����Ȯ��: Boolean; ARnRDataStatus : TRnRDataStatus; ADeviceType: TRnRInDevice ) : string;  overload;
    class function RnRDataStatus2DispStr( ARnRType : TRnRType; A����Ȯ��: Boolean; ARnRDataStatus : TRnRDataStatus; ADeviceType : TRnRInDevice ) : string;  overload;

    class function DataStatus2RnRDataStatus( AStatus : string ) : TRnRDataStatus; overload;
    class function DataStatus2RnRDataStatus( AStatus : Integer ) : TRnRDataStatus; overload;
    class function Status4App(AStatus : TRnRDataStatus; AReceptionConfirmationDttm : TDateTime = 0) : TConvertState4App;  // ���α׷����� ����� ��� ���·� ��ȯ �Ѵ�.
    class function DataStatus2State4App( AStatus : string ) : TConvertState4App;

    // ���� ��� type
    class function InDevice2RnRInDevice( ADeviceType : string ) : TRnRInDevice;
    class function RnRInDevice2InDevice( ARnRInDevice : TRnRInDevice ) : string;

    // ����
    class function GenderType2RnRGender( AGender : string ) : TRnRGenderType;
    class function RnRGender2GenderType( AGenderType : TRnRGenderType ) : string;

    // ��� ����
    class function CheckCancelStatus( AStatus : TRnRDataStatus; AReceptionConfirmationDttm : TDateTime = 0 ) : Boolean;
    class function checkFinishStatus( AStatus : TRnRDataStatus ) : Boolean;
  end;

  TRoomInfoData = class
  public
    { Public declarations }
    RoomCode : string;  // ����� ID
    RoomName : string; // ����� �̸�
    DeptCode : string; // �����ڵ�
    DeptName : string; // �����
    DoctorCode : string; // �ǻ� �ڵ�
    DoctorName : string; // DoctorName
  end;

  TRnRDataClass = class of TRnRData;

  TRoomInfo = record
    RoomCode : string;  // ����� ID
    RoomName : string; // ����� �̸�
    DeptCode : string; // �����ڵ�
    DeptName : string; // �����
    DoctorCode : string; // �ǻ� �ڵ�
    DoctorName : string; // DoctorName
    procedure Assign( ASource : TRoomInfo );
  end;

  TRnRData = class( TObject )
  private
    { Private declarations }
  public
    { Public declarations }
    ChartReceptnResultId : TChartReceptnResultId;

    DataType : TRnRType;  // ����  ����/����

    Inflow : TRnRInDevice;  // devicetype ���� ��ü  tablet, bridge, app
    Status : TRnRDataStatus; // data ����,  ��û/Ȯ��/�Ϸ�
    PatientChartID : string;
    PatientName : string; // ȯ�� �̸�
    PatientID : string; // V4
    CellPhone : string; // ��ȭ ��ȣ
    BirthDay : string; // �������, yyyymmdd
    DispBirthDay : string; // �������, yy-mm-dd, ��¿�
    Registration_number : string;  // �ֹε�� ��ȣ xxxxxxxxxxxxx => 13�ڸ�, �ܱ���/���� ��ȣ???
    DispRegistration_number : string; // �ֹι�ȣ ��¿�
    Gender : TRnRGenderType; // ����
    Symptom : string; // ���� ����
    InBoundPath : string; // ���� ���
    Addr : string; // �ּ�
    AddrDetail : string; // �� �ּ�
    Zip : string; // ���� ��ȣ

    RoomInfo : TRoomInfo;

    VisitDT : TDateTime;  // �湮 �ð�
    RegisterDT : TDateTime; // ��� �ð�, DB�� ��ϵ� �ð� receptiondttm
    hsptlreceptndttm : TDateTime; // ���� Ȯ�� �Ͻ�
    CancelDT : TDateTime;  // ��� �ð�
    isFirst : Boolean; // ��/���� ����, true:����, false:����

    CanceledMessage : string; // �ź� �޽���
    Memo : string; // �޸�
    isRegNumDefined : Boolean; // �ֹε�Ϲ�ȣ ��ü���� ������ �ִ��� ����
  public
    { Public declarations }
    constructor Create; virtual;

    function GetChartReceptnResultId : string;

    function DispGender : string; // ��¿� function ���� ���
    function Canceled : Boolean; // ��� ���� true�̸� ��� ���� �̴�.

    function Status4App : TConvertState4App;  // ���α׷����� ����� ��� ���·� ��ȯ �Ѵ�.

    function Copy : TRnRData;

    function ����Ȯ�� : Boolean; // ���� ��û ���� �����̸� false, �׿ܿ��� true(�����Ϸ�, ����, �Ϸ� ���� ����),
  end;

  TMonthData = class( TObject )
  private
    { Private declarations }
  public
    { Public declarations }
    Caption : string;
    Day : TDate;
    WeekDay : Integer; // ����, 0:�Ͽ���, 6:�����
    Holiday : Boolean;   // true�̸� ����

    RequestCount : Integer; // ���� ��û(Ȯ�� �� data) ����
    DecideCount : Integer; // ���� Ȯ��(�Ϸ�, ���...) ����
    CancelFinishCount : Integer; // ��� data ����
  public
    { Public declarations }
    constructor Create; virtual;

    function incRequestCount : Integer;
    function incDecideCount : Integer;
    function incCancelFinishCount : Integer;
  end;

  TSelectData = class( TObserverData )
  private
    { Private declarations }
    FDate: TDate;
  public
    { Public declarations }
    constructor Create( ADay : TDate ); virtual;

    function CopyData : TObserverData; override;

    property Date : TDate read FDate;
  end;

  TCancelMsgData = class
  private
    { Private declarations }
  public
    { Public declarations }
    Caption : string;
  public
    { Public declarations }
    constructor Create; virtual;
  end;

procedure InitData;

// ����ڰ� �Է��� ��ȭ��ȣ���� ���ڸ� ������ ��� ���ڸ� ���� �� ��ȯ
function ConvertInputCellPhone( ACellPhone : string ) : string;
// ��¿� ��ȭ��ȣ�� ����� �ش�.
function DisplayCellPhone( ACellPhone : string ) : string;
// ��¿� ���Ϸ� ����� �ش�.
function DisplayBirthDay( ABirthDay : string ) : string; // yyyy-mm-dd����
// ��¿� ���Ϸ� ����� �ش�.
function DisplayBirthDay2( ABirthDay : string ) : string; //yy-mm-dd����
// ��¿� �ֹε�� ��ȣ�� ����� �ش�.
function DisplayRegistrationNumber( ARegistrationNumber : string ) : string;
// ��¿� ���� �������� ��ȯ �Ѵ�.
function DisplaySymptom( ASymptom : string ) : string;

implementation
uses
  System.Classes, System.SysUtils, dateutils;

var
  GRnRDataStatusValue : array [TRnRDataStatus] of string;
  GRnRInDevice : array [TRnRInDevice] of string;

procedure InitData;
var
  data : string;
  i : TRnRDataStatus;
  j : TRnRInDevice;
begin
  for i := Low(TRnRDataStatus) to High(TRnRDataStatus) do
  begin
    case i of
      rrs�����û     : data := Status_�����û; // 'S01';
      rrs�������     : data := Status_�������; // 'S02';
      rrs����Ϸ�     : data := Status_����Ϸ�; // 'S03';
      rrs������û     : data := Status_������û; // 'C01';
      rrs��������     : data := Status_��������; // 'C02';
      rrs�����Ϸ�     : data := Status_�����Ϸ�; // 'C03';
      rrs������     : data := Status_������; // 'C04';
      rrs������û     : data := Status_������û; // 'C05';
      rrs����Ȯ��     : data := Status_����Ȯ��; // 'C06';
      rrs��������     : data := Status_��������; // 'C07';
      rrs��ҿ�û     : data := Status_��ҿ�û; // 'F01';
      rrs�������     : data := Status_�������; // 'F02';
      rrs�������     : data := Status_�������; // 'F03';
      rrs�ڵ����     : data := Status_�ڵ����; // 'F04';
      rrs����Ϸ�     : data := Status_����Ϸ�; // 'F05';
      rrs�����Ϸ�_new     : data := Status_�����Ϸ�; // 'C03'; �����Ͽ�
    else // rrsUnknown
      data := '';
    end;
    GRnRDataStatusValue[ i ] := data;
  end;

  for j := Low(TRnRInDevice) to High(TRnRInDevice) do
  begin
    case j of
      rriftablet  : data := InDeviceType_Tablet;
      rrifBridge  : data := InDeviceType_Bridge;
      rrifApp     : data := InDeviceType_App;
    else // rrifUnknown
      data := '';
    end;
    GRnRInDevice[ j ] := data
  end;
end;

// ����ڰ� �Է��� ��ȭ��ȣ���� ���ڸ� ������ ��� ���ڸ� ���� �� ��ȯ
function ConvertInputCellPhone( ACellPhone : string ) : string;
var
  i, l : Integer;
begin
  Result := '';
  l := Length( ACellPhone );
  if l <= 0  then
    exit;
  for i := 1 to l do
  begin
    //if StrToIntDef(ACellPhone[ i ], -1) >= 0 then
    if CharInSet(ACellPhone[i], ['0'..'9']) then
      Result := Result + ACellPhone[ i ];
  end;
end;

// ��¿� ��ȭ��ȣ�� ����� �ش�.
function DisplayCellPhone( ACellPhone : string ) : string;
var
  len : Integer;
begin
  Result := ACellPhone;

  if Result.IndexOf( '-' ) > 0 then
    exit; // ��ȭ��ȣ ���̿� �����ڰ� �̹� ��� �ִ�. �׳� ��� �ϰ� �Ѵ�.

  len := Length( ACellPhone );
  if len <= 3 then
    exit
  else if len <= 10 then
  begin
    Result.Insert(3, '-');
    if len >= 7 then
      Result.Insert(7, '-');
  end
  else
  begin
    Result.Insert(3, '-');
    if len >= 8 then
      Result.Insert(8, '-');
  end;
end;

// ��¿� ���Ϸ� ����� �ش�.
function DisplayBirthDay( ABirthDay : string ) : string;
var
  len : Integer;
begin
  Result := ABirthDay;

  if Result.IndexOf( '-' ) > 0 then
    exit; // ���� ���̿� �����ڰ� �̹� ��� �ִ�. �׳� ��� �ϰ� �Ѵ�.

  len := Length( ABirthDay );

  if len < 8 then
    exit;

  Result.Insert(4, '-');
  Result.Insert(7, '-');
end;

// ��¿� ���Ϸ� ����� �ش�.
function DisplayBirthDay2( ABirthDay : string ) : string; //yy-mm-dd����
var
  d : TDate;
  strd : string;
begin
  Result := '';
  strd := DisplayBirthDay( ABirthDay );
  d := StrToDateDef(strd, 0);
  if d = 0 then exit;
  Result := FormatDateTime('yy-mm-dd', d);
end;

function DisplayRegistrationNumber( ARegistrationNumber : string ) : string;
var
  index : Integer;
  len : Integer;
  s1, s2, s3 : AnsiString;
begin
  Result := ARegistrationNumber;

  index := Result.IndexOf( '-' );

  if index < 0 then
    index := 6 // '-'�� ����
  else
    Result := Result.Remove(index, 1);

  len := Length( Result );

  if len < 7 then
    exit;

{$WARNINGS OFF}
  s1 := Result.Substring(0, index); // ���ڸ� 6
  s2 := Result.Substring(index, 1); // ����

  if len = 7 then
  begin  // �ֹ� ��ȣ�� 7�ڸ��̴�.
    s3 := '******';
  end
  else // if len = 13 then
  begin
    s3 := Result.Substring(index+1, len-index-1);
  end;
  Result := s1 + '-' + s2 + s3;
{$WARNINGS ON}
end;

// ��¿� ���� �������� ��ȯ �Ѵ�.
function DisplaySymptom( ASymptom : string ) : string;
(*var
  sl : TStringList; *)
begin
(*  sl := TStringList.Create;
  try
    sl.CommaText := ASymptom;
    Result := sl.Text;
  finally
    FreeAndNil( sl );
  end; *)
  Result := ASymptom;
end;


{ TRnRData }

function TRnRData.Canceled: Boolean;
begin
  Result := Status in [rrs�������, rrs�������, rrs�ڵ����, rrs�������, rrs��������, rrs��ҿ�û];
end;

function TRnRData.Copy: TRnRData;
begin
  Result := TRnRData.Create;

  Result.ChartReceptnResultId.Id1 := ChartReceptnResultId.Id1; // data�� ���� ID
  Result.ChartReceptnResultId.Id2 := ChartReceptnResultId.Id2; // data�� ���� ID
  Result.ChartReceptnResultId.Id3 := ChartReceptnResultId.Id3; // data�� ���� ID
  Result.ChartReceptnResultId.Id4 := ChartReceptnResultId.Id4; // data�� ���� ID
  Result.ChartReceptnResultId.Id5 := ChartReceptnResultId.Id5; // data�� ���� ID
  Result.ChartReceptnResultId.Id6 := ChartReceptnResultId.Id6; // data�� ���� ID
  Result.DataType := DataType;  // ����  ����/����
  Result.Inflow := Inflow;  // ���� ��ü  tablet, web, mobile
  Result.Status := Status; // data ����,  �˼� ����.
  Result.PatientChartID := PatientChartID;
  Result.PatientName := PatientName;
  Result.PatientID := PatientID;
  Result.BirthDay := BirthDay;
  Result.Registration_number := Registration_number;
  Result.CellPhone := CellPhone;
  Result.Gender := Gender;
  Result.RoomInfo.RoomCode := RoomInfo.RoomCode;
  Result.RoomInfo.RoomName := RoomInfo.RoomName;
  Result.RoomInfo.DeptCode := RoomInfo.DeptCode;
  Result.RoomInfo.DeptName := RoomInfo.DeptName;
  Result.RoomInfo.DoctorCode := RoomInfo.DoctorCode;
  Result.RoomInfo.DoctorName := RoomInfo.DoctorName;
  Result.Memo := Memo;
  Result.isFirst := isFirst;
  Result.RegisterDT := RegisterDT;
  Result.Symptom := Symptom;
  Result.InBoundPath := InBoundPath;
  Result.Addr := Addr;
  Result.AddrDetail := AddrDetail;
  Result.Zip := Zip;
  Result.VisitDT := VisitDT;
  Result.CancelDT := CancelDT;
  Result.CanceledMessage := CanceledMessage;
  Result.hsptlreceptndttm := hsptlreceptndttm;
  Result.isRegNumDefined := isRegNumDefined;
end;

constructor TRnRData.Create;
begin
  ChartReceptnResultId.Id1 := ''; // data�� ���� ID
  ChartReceptnResultId.Id2 := ''; // data�� ���� ID
  ChartReceptnResultId.Id3 := ''; // data�� ���� ID
  ChartReceptnResultId.Id4 := ''; // data�� ���� ID
  ChartReceptnResultId.Id5 := ''; // data�� ���� ID
  ChartReceptnResultId.Id6 := ''; // data�� ���� ID

  DataType := rrReception;  // ����  ����/����

  Inflow := rriftablet;  // ���� ��ü  tablet, web, mobile
  Status := rrsUnknown; // data ����,  �˼� ����.
  //����Ȯ�� := False;
  PatientName := '';
  PatientChartID := '';
  PatientID := '';
  BirthDay := '';
  Registration_number := '';
  Gender := rrgtUnknown;
  RoomInfo.RoomCode := '';
  RoomInfo.RoomName := '';
  RoomInfo.DeptCode := '';
  RoomInfo.DeptName := '';
  RoomInfo.DoctorCode := '';
  RoomInfo.DoctorName := '';
  RegisterDT := 0;
  Symptom := '';
  InBoundPath := '';
  Addr := '';
  AddrDetail := '';
  Zip := '';
  VisitDT := 0;
  hsptlreceptndttm := 0;
  CanceledMessage := '';
  isRegNumDefined := False;
end;

function TRnRData.DispGender: string;
begin
  Result := '';
  if Gender = rrgtMale then
    Result := '(��)'
  else if Gender = rrgtFemale then
    Result := '(��)';
end;

function TRnRData.GetChartReceptnResultId: string;
begin
  Result := Format('%s!%s@%s#%s$%s^%s',[
                        ChartReceptnResultId.Id1,
                        ChartReceptnResultId.Id2,
                        ChartReceptnResultId.Id3,
                        ChartReceptnResultId.Id4,
                        ChartReceptnResultId.Id5,
                        ChartReceptnResultId.Id6
                        ]);
end;

function TRnRData.Status4App: TConvertState4App;
begin
  Result := TRRDataTypeConvert.Status4App( Status );
end;

function TRnRData.����Ȯ��: Boolean;
begin
  Result := hsptlreceptndttm <> 0;
end;

{ TMonthData }

constructor TMonthData.Create;
begin
  CancelFinishCount := 0; // ��� �Ϸ� data ����
  RequestCount := 0; // ���� ��û(Ȯ�� �� data) ����
  DecideCount := 0; // ���� Ȯ��(�Ϸ�, ���...) ����
  Day := Today;
  Caption := FormatDateTime('d', Day);
  Holiday := False;
end;

function TMonthData.incCancelFinishCount: Integer;
begin
  Inc( CancelFinishCount );
  Result := CancelFinishCount;
end;

function TMonthData.incDecideCount: Integer;
begin
  Inc( DecideCount );
  Result := DecideCount;
end;

function TMonthData.incRequestCount: Integer;
begin
  Inc( RequestCount );
  Result := RequestCount;
end;


{ TSelectData }

function TSelectData.CopyData: TObserverData;
begin
  Result := TSelectData.Create( FDate );
end;

constructor TSelectData.Create(ADay: TDate);
begin
  FDate := ADay;
end;

{ TCancelMsgData }

constructor TCancelMsgData.Create;
begin
  Caption := '';
end;

{ TRRDataTypeConvert }

class function TRRDataTypeConvert.CheckCancelStatus(
  AStatus: TRnRDataStatus; AReceptionConfirmationDttm : TDateTime ): Boolean;
begin
  Result := AStatus in [ rrs��ҿ�û, rrs�������, rrs�������, rrs�ڵ����, rrs�������, rrs��������];
end;

class function TRRDataTypeConvert.checkFinishStatus(
  AStatus: TRnRDataStatus): Boolean;
begin
  Result := AStatus = rrs����Ϸ�;
end;

class function TRRDataTypeConvert.DataStatus2RnRDataStatus(
  AStatus: string): TRnRDataStatus;
var
  i : TRnRDataStatus;
begin
  Result := rrsUnknown;
  for i := Low(TRnRDataStatus) to High(TRnRDataStatus) do
  begin
    if CompareText(AStatus, GRnRDataStatusValue[ i ] ) = 0 then
    begin
      Result := i;
      break;
    end;
  end;
end;

class function TRRDataTypeConvert.DataStatus2RnRDataStatus(
  AStatus: Integer): TRnRDataStatus;
begin
  Result := TRnRDataStatus( AStatus );
end;

class function TRRDataTypeConvert.DataStatus2State4App(
  AStatus: string): TConvertState4App;
var
  s : TRnRDataStatus;
begin
  s := DataStatus2RnRDataStatus( AStatus );
  Result := Status4App( s );
end;

class function TRRDataTypeConvert.DataType2RnRType(ADateType: String): TRnRType;
begin
  Result := rrReception;
  if ADateType = RRType_Reservation then
    Result := rrReservation;
end;

class function TRRDataTypeConvert.GenderType2RnRGender(
  AGender: string): TRnRGenderType;
const
  Male : array of string = ['1', '3', '5', '7', '9'];
  Female : array of string = ['2', '4', '6', '8', '10'];

  function Check( AData : array of string ) : Boolean;
  var
    i : Integer;
  begin
    Result := False;
    for i := Low(AData) to High(AData) do
    begin
      if CompareText( AGender, AData[i] ) = 0 then
      begin
        Result := True;
        exit;
      end;
    end;
  end;

begin
  Result := rrgtUnknown;
  if Check(Male) then
    Result := rrgtMale
  else if Check(Female)  then
    Result := rrgtFemale;
end;

class function TRRDataTypeConvert.InDevice2RnRInDevice(
  ADeviceType: string): TRnRInDevice;
var
  i : TRnRInDevice;
begin
  Result := rrifUnknown;
  for i := Low(TRnRInDevice) to High(TRnRInDevice) do
  begin
    if CompareText(ADeviceType, GRnRInDevice[ i ] ) = 0 then
    begin
      Result := i;
      break;
    end;
  end;
end;

class function TRRDataTypeConvert.RnRDataStatus2DataStatus(
  ARnRDataStatus: TRnRDataStatus): string;
begin
  Result := GRnRDataStatusValue[ ARnRDataStatus ];
end;

class function TRRDataTypeConvert.RnRDataStatus2DispStr(ARnRType: TRnRType;
  A����Ȯ��: Boolean; ARnRDataStatus: TRnRDataStatus;
  ADeviceType: TRnRInDevice): string;

begin
  case ARnRDataStatus of
    rrs�������, // Status_������� = 'S02';
    rrs�������� : Result := '���'; // Status_�������� = 'C02';
    rrs�����û, // Status_�����û = 'S01';
    rrs����Ϸ�, // Status_����Ϸ� = 'S03';
    rrs������û, // Status_������û = 'C01';
    rrs�����Ϸ�:  // Status_�����Ϸ� = 'C03';

        if ARnRType = rrReception then
        begin
            if ADeviceType = rriftablet then
               Result := '�º���';

            if ADeviceType = rrifApp then
               Result := '�����';

//            Result := '����';
//          if ADeviceType = rriftablet then
//            Result := '�ű�';
        end;
    rrs������ :  // Status_������ = 'C04';
      begin
        if ARnRType = rrReception then
        begin
            if ADeviceType = rriftablet then
               Result := '�º���';

            if ADeviceType = rrifApp then
               Result := '�����';

//            Result := '����';
//          if ADeviceType = rriftablet then
//            Result := '�ű�';
        end
        else
          Result := '����';
      end;
    rrs������û :  // Status_������û = 'C05';
      begin
            if ADeviceType = rriftablet then
               Result := '�º���';

            if ADeviceType = rrifApp then
               Result := '�����';
      end;
    rrs����Ȯ��     : Result := '����'; // Status_����Ȯ�� = 'C06';
    rrs��������     : Result := '����'; // Status_�������� = 'C07';
    rrs��ҿ�û     : Result := '��ҿ�û'; // Status_��ҿ�û = 'F01';

    rrs�������     : // Status_������� = 'F02';
      begin // Ȯ�� ���̳�, �ĳĿ� �ٶ� ��� ���� ���� �ؾ���.
//        if A����Ȯ�� then
//          Result := 'öȸ'
//        else
//          Result := '���';
            if ADeviceType = rriftablet then
               Result := '�º���';

            if ADeviceType = rrifApp then
               Result := '�����';

      end;
    rrs�������     : // Status_������� = 'F03';
      begin // Ȯ�� ���̳�, �ĳĿ� �ٶ� ��� ���� ���� �ؾ���.
//        if A����Ȯ�� then
//          Result := '���'
//        else
//          Result := '���';
            if ADeviceType = rriftablet then
               Result := '�º���';

            if ADeviceType = rrifApp then
               Result := '�����';
      end;
    rrs�ڵ����     : Result := '����'; // Result := '����'; // Status_�ڵ���� = 'F04';
    //rrs����Ϸ�     : Result := '�Ϸ�';  // Status_����Ϸ� = 'F05';
    rrs����Ϸ�     :
    begin
            if ADeviceType = rriftablet then
               Result := '�º���';

            if ADeviceType = rrifApp then
               Result := '�����';
    end;
  else  // rrsUnknown, // �˼� ���� ����
    Result := '';
  end;
end;

class function TRRDataTypeConvert.RnRDataStatus2DispStr2(
  ARnRType : TRnRType; A����Ȯ��: Boolean; ARnRDataStatus: TRnRDataStatus; ADeviceType: TRnRInDevice): string;
begin
  case ARnRDataStatus of
    rrs�������, // Status_������� = 'S02';
    rrs�������� : Result := '���'; // Status_�������� = 'C02';

    rrs�����û, // Status_�����û = 'S01';
    rrs����Ϸ�, // Status_����Ϸ� = 'S03';
    rrs������û, // Status_������û = 'C01';
    rrs�����Ϸ�,  // Status_�����Ϸ� = 'C03';
    rrs������ :  // Status_������ = 'C04';
      begin
        if ARnRType = rrReception then
        begin
            if ADeviceType = rriftablet then
               Result := '�º���';

            if ADeviceType = rrifApp then
               Result := '�����';
       end;
      end;
    rrs������û :  // Status_������û = 'C05';
      begin
        if ARnRType = rrReception then
        Result := '�º���'
      else
        Result := '�����';
      end;
    rrs����Ȯ��     : Result := '����'; // Status_����Ȯ�� = 'C06';
    rrs��������     : Result := '������'; // Status_�������� = 'C07';
    rrs��ҿ�û     : Result := '��ҿ�û'; // Status_��ҿ�û = 'F01';

    rrs�������     : // Status_������� = 'F02';
      begin // Ȯ�� ���̳�, �ĳĿ� �ٶ� ��� ���� ���� �ؾ���.
        if A����Ȯ�� then
          Result := 'öȸ'
        else
          Result := '���';
        //Result := 'ȯ��';
      end;
    rrs�������     : // Status_������� = 'F03';
      begin // Ȯ�� ���̳�, �ĳĿ� �ٶ� ��� ���� ���� �ؾ���.
        if A����Ȯ�� then
          Result := '���'
        else
          Result := '���';
      end;
    rrs�ڵ����     : Result := '����'; // Result := '����'; // Status_�ڵ���� = 'F04';
    //rrs����Ϸ�     : Result := '�Ϸ�';  // Status_����Ϸ� = 'F05';
    rrs����Ϸ�     :
    begin
      if ARnRType = rrReception then
      begin
            if ADeviceType = rriftablet then
               Result := '�º���';

            if ADeviceType = rrifApp then
               Result := '�����';
      end;
    end;
  else  // rrsUnknown, // �˼� ���� ����
    Result := '';
  end;
end;

class function TRRDataTypeConvert.RnRGender2GenderType(
  AGenderType: TRnRGenderType): string;
begin
  case AGenderType of
    rrgtMale    :  Result := '1';
    rrgtFemale  :  Result := '2';
  else // rrgtUnknown
    Result := '';
  end;
end;

class function TRRDataTypeConvert.RnRInDevice2InDevice(
  ARnRInDevice: TRnRInDevice): string;
begin
  Result := GRnRInDevice[ ARnRInDevice ];
end;

class function TRRDataTypeConvert.RnRType2DataType(ARnRType: TRnRType): string;
begin
  Result := RRType_Reception;
  if ARnRType = rrReservation then
    Result := RRType_Reservation;
end;

class function TRRDataTypeConvert.Status4App(
  AStatus: TRnRDataStatus; AReceptionConfirmationDttm : TDateTime): TConvertState4App;
begin
  Result := csa��û;  // rrsUnknown
  case AStatus of
    rrs�����û,
    rrs������û       : exit;

    rrs�������,
    rrs��������       : Result := csa��û���;

    rrs�����Ϸ�,
    rrs����Ϸ�       : Result := csaȯ��Ȯ��;

    rrs������û       : Result := csaȯ��Ȯ��Disable;

    rrs����Ȯ��,
    rrs������,
    rrs��������       : Result := csa������;

    rrs����Ϸ�       : Result := csa����Ϸ�;

    rrs��ҿ�û,
    rrs�������,
    rrs�������,
    rrs�ڵ����       :
      begin
        if AReceptionConfirmationDttm <> 0 then
          Result := csa���
        else
          Result := csa��û���;
      end;
  end;
end;

{ TRoomInfo }

procedure TRoomInfo.Assign(ASource: TRoomInfo);
begin
  RoomCode := ASource.RoomCode;  // ����� ID
  RoomName := ASource.RoomName; // ����� �̸�
  DeptCode := ASource.DeptCode; // �����ڵ�
  DeptName := ASource.DeptName; // �����
  DoctorCode := ASource.DoctorCode; // �ǻ� �ڵ�
  DoctorName := ASource.DoctorName; // DoctorName
end;

initialization
  initData;

end.