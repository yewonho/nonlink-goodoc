unit ElectronicPrescriptionsUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, BridgeCommUnit, EPBridgeCommUnit, GlobalUnit,
  Vcl.DBCtrls, MemDS, DBAccess, LiteAccess, DBDMUnit, Data.DB, Vcl.StdCtrls;

type
  TElectronicPrescriptionsForm = class(TForm)
    Panel1: TPanel;
    ReceptionExistsQuery: TLiteQuery;
    LiteQuery1: TLiteQuery;
    cid1: TLabeledEdit;
    cid2: TLabeledEdit;
    cid3: TLabeledEdit;
    cid4: TLabeledEdit;
    cid5: TLabeledEdit;
    cid6: TLabeledEdit;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    // �����ϴ� ���� ���� ���� Ȯ�� �Ѵ�.
    function ReceptionExists( AChartReceptnResultId : TChartReceptnResultId ) : Boolean;
    function MakeEvent354( AEvent352 : TBridgeResponse_352 ) : TBridgeRequest_354;
  public
    { Public declarations }
    procedure ChangeUI( AParentCtrl : TWinControl );


    // �Ʒ� function�� �۾� �Ϸ� �� ���� �ؾ���.
    function RequestEP( AEvent352 : TBridgeResponse_352 ) : TBridgeResponse_353; overload;  // ���� ó���� �߱� ó��

    procedure DBRefresh;
  end;

var
  ElectronicPrescriptionsForm: TElectronicPrescriptionsForm;

function Gender( ASex : string ) : string; // �ֹε�ϻ� ������ M or F�� ���� ���ش�.     1,3,5,7,9�� M

implementation
uses
  strutils,
  ElectronicPrescriptionsDefaultUnit;

{$R *.dfm}

function Gender( ASex : string ) : string;
var
  s : Integer;
begin
  s := StrToIntDef(ASex, 1);
  if s in [1,3,5,7,9] then
    Result := 'M'
  else
    Result := 'F';
end;

{ TElectronicPrescriptionsForm }

procedure TElectronicPrescriptionsForm.Button1Click(Sender: TObject);
begin
  ElectronicPrescriptionsDefaultForm.Show;
end;

procedure TElectronicPrescriptionsForm.ChangeUI(AParentCtrl: TWinControl);
begin
  if Assigned( AParentCtrl ) then
  begin
    Panel1.Parent := AParentCtrl;
    Panel1.Align := alClient;
  end
  else
    Panel1.Parent := Self;
end;

procedure TElectronicPrescriptionsForm.DBRefresh;
begin

end;

function TElectronicPrescriptionsForm.MakeEvent354(
  AEvent352: TBridgeResponse_352): TBridgeRequest_354;
var
  i : Integer;
  CItem: TadCommentItem;
  rxDrug: TrxDrugListItem;
begin
  Result := TBridgeRequest_354( GBridgeFactory.MakeRequestObj( EventID_����ó�����߱� ) );
  with LiteQuery1 do
  begin
    Active := False;
{ TODO :
protocol ���� �̽��� ���� �ڵ带 ���� �ؾ���.
���� ����
    ParamByName( 'chartrrid1' ).Value := AEvent352.chartReceptnResultId.Id1;
    ParamByName( 'chartrrid2' ).Value := AEvent352.chartReceptnResultId.Id2;
    ParamByName( 'chartrrid3' ).Value := AEvent352.chartReceptnResultId.Id3;
    ParamByName( 'chartrrid4' ).Value := AEvent352.chartReceptnResultId.Id4;
    ParamByName( 'chartrrid5' ).Value := AEvent352.chartReceptnResultId.Id5;
    ParamByName( 'chartrrid6' ).Value := AEvent352.chartReceptnResultId.Id6;
    Active := True;
    with Result do
    begin
      HospitalNo := GHospitalNo;
      gdid := AEvent352.Gdid;
      ePrescriptionPatient := ifthen(GElectronicPrescriptionsOption, '0', '1');
      chartReceptnResultId := AEvent352.chartReceptnResultId;
      version := '0.1';
      patientName := FieldByName('name').AsString;
      insureName := patientName;
      patientSid := FieldByName('regnum').AsString;
      patientUnitNo := FieldByName('chartid').AsString;
      patientAge := '50';
      patientSex := Gender( FieldByName('sex').AsString );
      patientAddr := FieldByName('addr').AsString + ifthen(FieldByName('addrdetail').AsString = '', '', ' ' + FieldByName('addrdetail').AsString);
      reimburseType := ElectronicPrescriptionsDefaultForm.Get_reimburseType;
      reimburseTypeName := ElectronicPrescriptionsDefaultForm.Get_reimburseTypeName;
      reimburseDetailType := ElectronicPrescriptionsDefaultForm.Get_reimburseDetailType;
      reimburseDetailName := ElectronicPrescriptionsDefaultForm.Get_reimburseDetailName;
      reimburseExcpCalc := ElectronicPrescriptionsDefaultForm.Get_reimburseExcpCalc;
      reimburseViewDetailName := ElectronicPrescriptionsDefaultForm.Get_reimburseViewDetailName;
      excpCalcCode := ElectronicPrescriptionsDefaultForm.Get_excpCalcCode;
      identifyingSid := ElectronicPrescriptionsDefaultForm.Get_identifyingSid;
      relationPatnt := ElectronicPrescriptionsDefaultForm.Get_relationPatnt;
      organUnitNo := ElectronicPrescriptionsDefaultForm.Get_organUnitNo;
      organName := ElectronicPrescriptionsDefaultForm.Get_organName;
      patriotId := ElectronicPrescriptionsDefaultForm.Get_patriotId;
      accidentHospUnitNo := ElectronicPrescriptionsDefaultForm.Get_accidentHospUnitNo;
      accidentManagementNo := ElectronicPrescriptionsDefaultForm.Get_accidentManagementNo;
      accidentWorkplaceName := ElectronicPrescriptionsDefaultForm.Get_accidentWorkplaceName;
      accidentHappenDate := ElectronicPrescriptionsDefaultForm.Get_accidentHappenDate;
      specialCode := ElectronicPrescriptionsDefaultForm.Get_specialCode;
      rxSerialNo := ElectronicPrescriptionsDefaultForm.Get_rxSerialNo;
      rxMedInfoNo := ElectronicPrescriptionsDefaultForm.Get_rxMedInfoNo;
      rxAllMedNo := ElectronicPrescriptionsDefaultForm.Get_rxAllMedNo;
      rxMakeDate := ElectronicPrescriptionsDefaultForm.Get_rxMakeDate;
      rxIssueTimestamp := ElectronicPrescriptionsDefaultForm.Get_rxIssueTimestamp;
      hospUnitNo := GHospitalNo;
      medicalCenterName := GHospitalNo + '����';
      hospName := GHospitalNo + '����';
      hospTelNo := '02'+ GHospitalNo;
      hospFaxNo := '02'+ GHospitalNo;
      hospRepName := hospName;
      hospEmail := GHospitalNo+'@emul.co.kr';
      hospAddr := GHospitalNo+'���� �ּ��̴�.';
      hospUrl := 'http://'+GHospitalNo+'.co.kr';
      deptMediCode := FieldByName('deptcode').AsString;
      docLicenseNo := FieldByName('doctorcode').AsString + FieldByName('doctorname').AsString;
      docName := FieldByName('doctorname').AsString;
      docLicenseType := '1'; // 1:�ǻ�, 2:���ǻ�, 3:���ǻ�, 4:ġ���ǻ�, 5:��Ÿ
      docLicenseTypeName := '�ǻ�';  // �ǻ�, ���ǻ�, ���ǻ�, ġ���ǻ�, ��Ÿ
      docSpecialty := FieldByName('deptname').AsString;
      docTelNo := '010'+ GHospitalNo;
      docEmail := FieldByName('doctorcode').AsString+'@doctor.co.kr';
      diagnosisCode1 := ElectronicPrescriptionsDefaultForm.Get_diagnosisCode1;
      diagnosisCode2 := ElectronicPrescriptionsDefaultForm.Get_diagnosisCode2;
      diagnosisCode3 := ElectronicPrescriptionsDefaultForm.Get_diagnosisCode3;
      rxEffectivePeriod := ElectronicPrescriptionsDefaultForm.Get_rxEffectivePeriod;
      nextVisitDate := ElectronicPrescriptionsDefaultForm.Get_nextVisitDate;
      forDispensingComment := ElectronicPrescriptionsDefaultForm.Get_forDispensingComment;
      specialComment := ElectronicPrescriptionsDefaultForm.Get_specialComment;
      topComment1 := ElectronicPrescriptionsDefaultForm.Get_topComment1;
      topComment2 := ElectronicPrescriptionsDefaultForm.Get_topComment2;
      topComment3 := ElectronicPrescriptionsDefaultForm.Get_topComment3;
      centerComment1 := ElectronicPrescriptionsDefaultForm.Get_centerComment1;
      centerComment2 := ElectronicPrescriptionsDefaultForm.Get_centerComment2;
      centerComment3 := ElectronicPrescriptionsDefaultForm.Get_centerComment3;
      bottomComment1 := ElectronicPrescriptionsDefaultForm.Get_bottomComment1;
      bottomComment2 := ElectronicPrescriptionsDefaultForm.Get_bottomComment2;
      bottomComment3 := ElectronicPrescriptionsDefaultForm.Get_bottomComment3;

      for i := 1 to 2 do
      begin
        CItem := TadCommentItem.Create;
        CItem.resnm := '�ߺ����� ġ�ᱺ' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resncnts := '���� ġ�ᱺ �� �ϳ��� ����� ������ �������� �� ����, ��ü ������ �ٸ� ġ�ᱺ�� ����.' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resnm := '��������10/5mg' + FormatDateTime('yyyymmddhhnnsszzz',now);
        AddadComment( CItem );
      end;

      for i := 1 to 2 do
      begin
        rxDrug := TrxDrugListItem.Create;
        with rxDrug do
        begin
          drugCode := 'KD �ڵ�';
          drugKorName := '�ϳ����ٸ���Ż�� 30mg';
          drugEngName := 'engname 30mg';
          ingredientName := '���� : �Ծ��';
          drugReimbursementType := 1; // 1:�޿�, 2:��޿�, 3:100/100, 4:100/80, 5:100/50, 6:100/30, 7: 100:90
          drugAdminRoute := 0; // 0:����, 1:�ܿ�, 2:�ֻ���
          drugListEnrollType := 0; //  0:��ǰ��, 1:���и�(����), 2:���и�(�ѱ�), Default = '0'
          drugDose := '0.5 tab';
          drugAdminCount := '2 ȸ';
          drugTreatmentPeriod := '42 ��';
          totalAdminDose := '42 tab';
          drugPackageFlag := 1;    // 1:���Ѵ���, 0:�׿ܾ�ǰ
          drugOutsideFlag := 3; // 1(����), 2(����)
          docClsType := 1; //  ������ ���: 3 ������ �ƴ� ���: 1
          drugAdminCode := 'p205';// p105, p205
          drugAdminComment := ' Pulv (����� ó��) + 1�� 2ȸ 12�ð����� ����';
          docComment := '��޿�';
          prnCheck := 1; //  1: prn ó���� ���, 0: prn ó���� �ƴ� ���
        end;

        AddrxDrug( rxDrug );
      end;
            }
(*


select * from
reception m
inner join patient as s on (m.chartid = s.chartid)
where
chartrrid1 = '20190625104303832'
and chartrrid2 = ''
and chartrrid3 = ''
and chartrrid4 = ''
and chartrrid5 = ''
and chartrrid6 = ''



    end;   *)
    Active := False;
  end;
end;

function TElectronicPrescriptionsForm.ReceptionExists(
  AChartReceptnResultId: TChartReceptnResultId): Boolean;
begin
  with ReceptionExistsQuery do
  begin
    Active := False;
    ParamByName( 'chartrrid1' ).Value := AChartReceptnResultId.Id1;
    ParamByName( 'chartrrid2' ).Value := AChartReceptnResultId.Id2;
    ParamByName( 'chartrrid3' ).Value := AChartReceptnResultId.Id3;
    ParamByName( 'chartrrid4' ).Value := AChartReceptnResultId.Id4;
    ParamByName( 'chartrrid5' ).Value := AChartReceptnResultId.Id5;
    ParamByName( 'chartrrid6' ).Value := AChartReceptnResultId.Id6;
    Active := True;
    First;
    Result := not Eof;
    Active := False;
  end;
end;

function TElectronicPrescriptionsForm.RequestEP(
  AEvent352: TBridgeResponse_352): TBridgeResponse_353;
var
  event_354 : TBridgeRequest_354;
begin
  Result := TBridgeResponse_353( GBridgeFactory.MakeRequestObj(EventID_����ó�����߱޼������, AEvent352.JobID ) );

  if not GElectronicPrescriptionsOption then
  begin
    Result.Code := 90; // �����ǵ� error �ڵ�
    Result.MessageStr := '����ó���� �߱� ������ �ƴմϴ�.';
    exit;
  end;

(*
  cid1.Text := AEvent352.chartReceptnResultId.Id1;
  cid2.Text := AEvent352.chartReceptnResultId.Id2;
  cid3.Text := AEvent352.chartReceptnResultId.Id3;
  cid4.Text := AEvent352.chartReceptnResultId.Id4;
  cid5.Text := AEvent352.chartReceptnResultId.Id5;
  cid6.Text := AEvent352.chartReceptnResultId.Id6;

  // ���� data�� �ִ� data�ΰ�?
  if not ReceptionExists( AEvent352.chartReceptnResultId ) then
  begin  // ���� ������ ����.
    Result.Code := Result_������ȣ����;
    Result.MessageStr := GBridgeFactory.GetErrorString( Result.Code );
    exit;
  end;
*)
  // ���� ������ �ִ� data�̴�.
  event_354 := MakeEvent354( AEvent352 );

{ TODO :
352�� ó���� ��� �Ұž�?
354�� �����ϱ� ���� �۾��� ��� �Ұų�

���� data�� �ش� data�� �ִ��� Ȯ�� ��
������ 354�� ������ �غ� �ϰ�
������ error ó���� �Ѵ�.
352�� ���� data�� 353���� json string�� ���� �� queue�� ��� �� 1�� �Ŀ� �߼� �ϰ� �Ѵ�.

}

  Result.Code := Result_SuccessCode;
  Result.MessageStr := GBridgeFactory.GetErrorString( Result.Code );
end;


end.
