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
    // 존제하는 접수 정보 있지 확인 한다.
    function ReceptionExists( AChartReceptnResultId : TChartReceptnResultId ) : Boolean;
    function MakeEvent354( AEvent352 : TBridgeResponse_352 ) : TBridgeRequest_354;
  public
    { Public declarations }
    procedure ChangeUI( AParentCtrl : TWinControl );


    // 아래 function은 작업 완료 후 제거 해야함.
    function RequestEP( AEvent352 : TBridgeResponse_352 ) : TBridgeResponse_353; overload;  // 전자 처방정 발급 처리

    procedure DBRefresh;
  end;

var
  ElectronicPrescriptionsForm: TElectronicPrescriptionsForm;

function Gender( ASex : string ) : string; // 주민등록상 성별을 M or F로 변경 해준다.     1,3,5,7,9를 M

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
  Result := TBridgeRequest_354( GBridgeFactory.MakeRequestObj( EventID_전자처방전발급 ) );
  with LiteQuery1 do
  begin
    Active := False;
{ TODO :
protocol 변경 이슈로 인해 코드를 정리 해야함.
문서 참고
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
      medicalCenterName := GHospitalNo + '센터';
      hospName := GHospitalNo + '병원';
      hospTelNo := '02'+ GHospitalNo;
      hospFaxNo := '02'+ GHospitalNo;
      hospRepName := hospName;
      hospEmail := GHospitalNo+'@emul.co.kr';
      hospAddr := GHospitalNo+'병원 주소이다.';
      hospUrl := 'http://'+GHospitalNo+'.co.kr';
      deptMediCode := FieldByName('deptcode').AsString;
      docLicenseNo := FieldByName('doctorcode').AsString + FieldByName('doctorname').AsString;
      docName := FieldByName('doctorname').AsString;
      docLicenseType := '1'; // 1:의사, 2:한의사, 3:수의사, 4:치과의사, 5:기타
      docLicenseTypeName := '의사';  // 의사, 한의사, 수의사, 치과의사, 기타
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
        CItem.resnm := '중복투여 치료군' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resncnts := '동일 치료군 내 하나의 약재료 질병이 조절되지 않 으며, 대체 가능한 다른 치료군이 없음.' + FormatDateTime('yyyymmddhhnnsszzz',now);
        CItem.resnm := '진서방정10/5mg' + FormatDateTime('yyyymmddhhnnsszzz',now);
        AddadComment( CItem );
      end;

      for i := 1 to 2 do
      begin
        rxDrug := TrxDrugListItem.Create;
        with rxDrug do
        begin
          drugCode := 'KD 코드';
          drugKorName := '하나페노바르비탈정 30mg';
          drugEngName := 'engname 30mg';
          ingredientName := '성분 : 먹어도됨';
          drugReimbursementType := 1; // 1:급여, 2:비급여, 3:100/100, 4:100/80, 5:100/50, 6:100/30, 7: 100:90
          drugAdminRoute := 0; // 0:내복, 1:외용, 2:주사제
          drugListEnrollType := 0; //  0:상품명, 1:성분명(영문), 2:성분명(한글), Default = '0'
          drugDose := '0.5 tab';
          drugAdminCount := '2 회';
          drugTreatmentPeriod := '42 일';
          totalAdminDose := '42 tab';
          drugPackageFlag := 1;    // 1:병팩단위, 0:그외약품
          drugOutsideFlag := 3; // 1(원내), 2(원외)
          docClsType := 1; //  마약일 경우: 3 마약이 아닐 경우: 1
          drugAdminCode := 'p205';// p105, p205
          drugAdminComment := ' Pulv (가루약 처방) + 1일 2회 12시간마다 복용';
          docComment := '비급여';
          prnCheck := 1; //  1: prn 처방인 경우, 0: prn 처방이 아닌 경우
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
  Result := TBridgeResponse_353( GBridgeFactory.MakeRequestObj(EventID_전자처방전발급설정결과, AEvent352.JobID ) );

  if not GElectronicPrescriptionsOption then
  begin
    Result.Code := 90; // 미정의된 error 코드
    Result.MessageStr := '전차처방전 발급 병원이 아닙니다.';
    exit;
  end;

(*
  cid1.Text := AEvent352.chartReceptnResultId.Id1;
  cid2.Text := AEvent352.chartReceptnResultId.Id2;
  cid3.Text := AEvent352.chartReceptnResultId.Id3;
  cid4.Text := AEvent352.chartReceptnResultId.Id4;
  cid5.Text := AEvent352.chartReceptnResultId.Id5;
  cid6.Text := AEvent352.chartReceptnResultId.Id6;

  // 접수 data에 있는 data인가?
  if not ReceptionExists( AEvent352.chartReceptnResultId ) then
  begin  // 접수 정보가 없다.
    Result.Code := Result_접수번호없음;
    Result.MessageStr := GBridgeFactory.GetErrorString( Result.Code );
    exit;
  end;
*)
  // 접수 정보가 있는 data이다.
  event_354 := MakeEvent354( AEvent352 );

{ TODO :
352의 처리를 어떻게 할거야?
354를 전송하기 위한 작업은 어떻게 할거냐

접수 data에 해당 data가 있는지 확인 후
있으면 354를 전송할 준비를 하고
없으면 error 처리를 한다.
352에 대한 data로 353대한 json string을 만든 후 queue에 등록 후 1초 후에 발송 하게 한다.

}

  Result.Code := Result_SuccessCode;
  Result.MessageStr := GBridgeFactory.GetErrorString( Result.Code );
end;


end.
