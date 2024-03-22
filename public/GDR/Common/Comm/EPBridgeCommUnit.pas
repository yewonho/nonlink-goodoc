unit EPBridgeCommUnit;
(*
  전자 처방전 protocol 정의 unit
  electronic prescriptions
*)
interface
uses
  System.SysUtils, System.Variants, System.Classes, System.Contnrs,
  System.JSON.Types, json, GDJson,
  BridgeCommUnit;

type
// ================================================================================================
// 차트 → 굿닥, 자동 결제 여부
  TBridgeRequest_140 = class( TBridgeRequest )
  private
    { Private declarations }
  protected
    { protected declarations }
    procedure ConvertJson( AJsonWriter : TGDJsonTextWriter ); override;
  public
    { Public declarations }
    HospitalNo : string;    // 요양기관 번호
    chartReceptnResultId : TChartReceptnResultId;  // 접수 id

    constructor Create( AEventID : integer; AJobID : String ); override;
  end;

  TBridgeResponse_141 = class( TBridgeResponse )
  private
    { Private declarations }
    FActive: Integer;
  protected
    { protected declarations }
    function AnalysisJson( AJsonRoot : TJSONObject ) : Integer; override;
  public
    { Public declarations }
    constructor Create( ABaseProtocol : TBridgeProtocol ); override;
    destructor Destroy; override;

    property Active : Integer read FActive;  // 0:사용안함, 1:사용
  end;

// ================================================================================================
// 차트 → 굿닥, 자동 결제 요청
  TBridgeRequest_142 = class( TBridgeRequest )
  private
    { Private declarations }
  protected
    { protected declarations }
    procedure ConvertJson( AJsonWriter : TGDJsonTextWriter ); override;
  public
    { Public declarations }
    HospitalNo : string;    // 요양기관 번호
    chartReceptnResultId : TChartReceptnResultId;  // 접수 id
    userAmt : LongWord;    // 환자 부담금(실재 결제될 금액)
    totalAmt : LongWord;  // 총 결재 금액
    nhisAmt : LongWord;   // 공단부담금
    planMonth : string;  // 할부개월 코드, 없으면 일시불 처리 M0, M2, M3, M4, M5, M6, M7, M8, M9, M10, M11, M12

    constructor Create( AEventID : integer; AJobID : String ); override;
  end;

  TBridgeResponse_143 = class( TBridgeResponse )
  private
    { Private declarations }
    FpayAuthNo: string;
    FtransDttm: string;
    FresultMsg: string;
    FchartReceptnResultId: TChartReceptnResultId;
    FresultCd: string;
    FplanMonth: string;
  protected
    { protected declarations }
    function AnalysisJson( AJsonRoot : TJSONObject ) : Integer; override;
  public
    { Public declarations }
    constructor Create( ABaseProtocol : TBridgeProtocol ); override;
    destructor Destroy; override;

    property chartReceptnResultId : TChartReceptnResultId read FchartReceptnResultId;
    property resultCd : string read FresultCd;
    property resultMsg : string read FresultMsg;
    property transDttm : string read FtransDttm;

    property payAuthNo : string read FpayAuthNo;
    property planMonth : string read FplanMonth;
  end;

// ================================================================================================
// 차트 → 굿닥, 자동 결제 취소
  TBridgeRequest_144 = class( TBridgeRequest )
  private
    { Private declarations }
  protected
    { protected declarations }
    procedure ConvertJson( AJsonWriter : TGDJsonTextWriter ); override;
  public
    { Public declarations }
    HospitalNo : string;    // 요양기관 번호
    chartReceptnResultId : TChartReceptnResultId;  // 접수 id
    payAuthNo : string; // 승인 번호
    reason : string; // 취소 사유

    constructor Create( AEventID : integer; AJobID : String ); override;
  end;

  TBridgeResponse_145 = class( TBridgeResponse )
  private
    { Private declarations }
    FtransDttm: string;
    FresultMsg: string;
    FchartReceptnResultId: TChartReceptnResultId;
    FresultCd: string;
  protected
    { protected declarations }
    function AnalysisJson( AJsonRoot : TJSONObject ) : Integer; override;
  public
    { Public declarations }
    constructor Create( ABaseProtocol : TBridgeProtocol ); override;
    destructor Destroy; override;

    property chartReceptnResultId : TChartReceptnResultId read FchartReceptnResultId;
    property resultCd : string read FresultCd;
    property resultMsg : string read FresultMsg;
    property transDttm : string read FtransDttm;
  end;

// ================================================================================================
// 차트 → 굿닥, 자동 결제 병원 확인
  TBridgeRequest_310 = class( TBridgeRequest )
  private
    { Private declarations }
  protected
    { protected declarations }
    procedure ConvertJson( AJsonWriter : TGDJsonTextWriter ); override;
  public
    { Public declarations }
    HospitalNo : string;    // 요양기관 번호

    constructor Create( AEventID : integer; AJobID : String ); override;
  end;

  TBridgeResponse_311 = class( TBridgeResponse )
  private
    { Private declarations }
    FusePlan: Boolean;
    FpriceAmt: LongWord;
    FActive: boolean;
  protected
    { protected declarations }
    function AnalysisJson( AJsonRoot : TJSONObject ) : Integer; override;
  public
    { Public declarations }
    constructor Create( ABaseProtocol : TBridgeProtocol ); override;
    destructor Destroy; override;

    property Active : boolean read FActive;      // 자동 결제 사용
    property usePlan : Boolean read FusePlan;    // 할부 결제 사용
    property priceAmt : LongWord read FpriceAmt; // 1회 승인 가능 금액
  end;

// ================================================================================================
// 차트 → 굿닥, 자동 결제 병원 확인
  TBridgeRequest_312 = class( TBridgeRequest )
  private
    { Private declarations }
  protected
    { protected declarations }
    procedure ConvertJson( AJsonWriter : TGDJsonTextWriter ); override;
  public
    { Public declarations }
    HospitalNo : string;    // 요양기관 번호

    constructor Create( AEventID : integer; AJobID : String ); override;
  end;

  TCardmonthListItem = class
  public
    cd : string; // 할부 코드
    nm : string; // BC 카드
  end;

  TBridgeResponse_313 = class( TBridgeResponse )
  private
    { Private declarations }
    flist : TObjectList;
    FminPrice: LongWord;
    function GetCount: Integer;
    function GetmonthList(AIndex: Integer): TCardmonthListItem;
  protected
    { protected declarations }
    function AnalysisJson( AJsonRoot : TJSONObject ) : Integer; override;
  public
    { Public declarations }
    constructor Create( ABaseProtocol : TBridgeProtocol ); override;
    destructor Destroy; override;

    property minPrice : LongWord read FminPrice;
    property Count : Integer read GetCount;
    property monthList[ AIndex : Integer ] : TCardmonthListItem read GetmonthList;
  end;

// ================================================================================================
// 차트 → 굿닥, 전자 처방전 병원조회
  TBridgeRequest_350 = class( TBridgeRequest )
  private
    { Private declarations }
  protected
    { protected declarations }
    procedure ConvertJson( AJsonWriter : TGDJsonTextWriter ); override;
  public
    { Public declarations }
    HospitalNo : string;
    constructor Create( AEventID : integer; AJobID : String ); override;
    destructor Destroy; override;
  end;

  TBridgeResponse_351 = class( TBridgeResponse )
  private
    { Private declarations }
    Fprescription: Integer;
  protected
    { protected declarations }
    function AnalysisJson( AJsonRoot : TJSONObject ) : Integer; override;
  public
    { Public declarations }
    constructor Create( ABaseProtocol : TBridgeProtocol ); override;

    property Prescription : Integer read Fprescription;
  end;

// ================================================================================================
// 굿닥 → 차트, 전자 처방전 발급 요청
  TBridgeResponse_352 = class( TBridgeResponse )
  private
    { Private declarations }
    FHospitalNo: string;
    Fgdid : string;
    FPrescription: Integer;
    Fhipass : Integer;
    FchartReceptnResultId : TChartReceptnResultId;
    FparmNo: string;
    FparmNm: string;
    FextraInfo: string;
  protected
    { protected declarations }
    function AnalysisJson( AJsonRoot : TJSONObject ) : Integer; override;
  public
    { Public declarations }
    property HospitalNo : string read FHospitalNo;
    property Gdid : string read Fgdid;

    property chartReceptnResultId : TChartReceptnResultId read FchartReceptnResultId;

    property Hipass : Integer read Fhipass;     // 1 :사용, 0: 미사용, 9:기존값 유지
    property Prescription : Integer read FPrescription; // 1 :사용, 0: 미사용, 9:기존값 유지
    property ParmNo : string read FparmNo;
    property ParmNm : string read FparmNm;
    property ExtraInfo : string read FextraInfo;
  end;

  TBridgeResponse_353 = class( TBridgeRequest_Nomal )
  private
    { Private declarations }
  protected
    { protected declarations }
  public
    { Public declarations }
  end;

// ================================================================================================
// 차트 → 굿닥, 전자 처방전 발급 전송
    TadCommentItem = class
    public
      { Public declarations }
      resnm : string; // 약품 추가 용법
      resncnts : string; // 약품 추가 용법 설명
      hngnm : string; // 약품명
    end;

    TrxDrugListItem = class
    public
      { Public declarations }
      drugCode : string; // 보험코드
      drugKorName : string; // 약품명
      drugEngName : string; // 약품명(영어)
      ingredientName : string; // 성분명
      drugReimbursementType : integer; // 보험구분  1:급여, 2:비급여, 3:100/100, 4:100/80, 5:100/50, 6:100/30, 7: 100:90
      drugAdminRoute : integer; // 유형     0:내복, 1:외용, 2:주사제
      drugListEnrollType : Integer; // 구분   0:상품명, 1:성분명(영문), 2:성분명(한글) Default = '0'
      drugDose : string; // 1회 투약량
      drugAdminCount : string; // 1일 투여횟수
      drugTreatmentPeriod : string; // 투여일수
      totalAdminDose : string; // 총투여량
      drugPackageFlag : Integer; // 포장구분        1:병팩단위, 0:그외약품
      drugOutsideFlag : Integer; // 원내/원외 구분   1(원내), 2(원외)
      docClsType : Integer; // 마약 구분코드  마약일 경우: 3 마약이 아닐 경우: 1
      drugAdminCode : string; // 용법코드
      drugAdminComment : string; // 용법 설명
      docComment : string; // 참고 사항
      prnCheck : Integer; // prn처방 유무  1: prn 처방인 경우, 0: prn 처방이 아닌 경우
    end;

  TBridgeRequest_354 = class( TBridgeRequest )
  private
    { Private declarations }
    FadCommentList : TObjectList;
    FrxDrugList : TObjectList;
    function GetadCommentList(index: Integer): TadCommentItem;
    function GetadCommentListCount: Integer;
    function GetrxDrugList(index: Integer): TrxDrugListItem;
    function GetrxDrugListCount: Integer;
  protected
    { protected declarations }
    procedure ConvertJson( AJsonWriter : TGDJsonTextWriter ); override;
  public
    { Public declarations }
    HospitalNo : string;
    gdid : string;
    ePrescriptionPatient : Integer;  // 접수 환자의 전자 처방전 사용 여부(0:미사용, 1:사용)
    chartReceptnResultId : TChartReceptnResultId; // 접수 번호
    version : string; // 버전
    patientName : string;
    insureName : string; // 보험가입자명
    patientSid : string; // 주민번호
    patientUnitNo : string; // 환자 번호
    patientAge : integer; // 환자 나이
    patientSex : string; // 환자 성별 M:남자, F:여자
    patientAddr : string; // 환자 주소
    reimburseType : Integer; // 종별구분,  1:건강보험,2:의료보호,3:산업재해,4:자동차보험,5:기 타
    reimburseTypeName : string; // 종별,   건강보험, 의료보호, 산업재해, 자동차보험, 기타
    reimburseDetailType : string; // 보험 세부 코드 문서 참고
    reimburseDetailName : string; // 보험 세부 명칭
    reimburseExcpCalc : Integer; // 보호 종별   1: (1종), 2: (2종), 의료보호 이외에는 공백처리
    reimburseViewDetailName : string; // 처방전 표시 보험세부 이름  ex> 중증, 경증, 차상위
    excpCalcCode : string; // 본인 부담금, ex>M015
    identifyingSid : string; // 보험증 번호
    relationPatnt : Integer; // 피보험자와의 관계,  1: (본인), 2: (배우자), 3: (부모), 4: (자녀), 5: (기타) :relationPatient
    organUnitNo : string; // 사업장 기호
    organName : string; // 사업장 명칭
    patriotId : string; // 보훈번호
    accidentHospUnitNo : string; // 산재요양기호
    accidentManagementNo : string; // 산재관리번호
    accidentWorkplaceName : string; // 산재사업자명
    accidentHappenDate : string; // 산재재해발생일
    specialCode : string; // 특정기호
    rxSerialNo : string; // 처방전교부번호
    rxMedInfoNo : string; // 원내 교부번호
    rxAllMedNo : string; // 원내, 원외 모든 교부 번호
    rxMakeDate : string; // 처방전교부일자  YYYYMMDD
    rxIssueTimestamp : string; // 처방전발급시간   YYYYMMDDHHmmss
    hospUnitNo : string; // 처방전발급기관기호  ex> 서울대병원 기관번호 – 11100079
    medicalCenterName : string; // 센터명
    hospName : string; // 병원명
    hospTelNo : string; // 병원전화번호
    hospFaxNo : string; // 병원 fax
    hospRepName : string; // 병원 약칭
    hospEmail : string; // 병원 이메일
    hospAddr : string; // 병원주소
    hospUrl : string; // 병원 홈페이지
    deptMediCode : string; // 진료과코그
    docLicenseNo : string; // 의사면허번호
    docName : string; // 의사 이름
    docLicenseType : string; // 의사면허종별    의료인의 면허종별 1:의사, 2:한의사, 3:수의사, 4:치과의사, 5:기타
    docLicenseTypeName : string; //의사면허 종별명          의사, 한의사, 수의사, 치과의사, 기타
    docSpecialty : string; // 의사진료 과목
    docTelNo : string; // 의사 전화 번호      010-1234-5678
    docEmail : string; // 의사 이메일
    diagnosisCode1, diagnosisCode2, diagnosisCode3 : string; // 상병기호
    rxEffectivePeriod : Integer; // 전자 처방전 유효기간
    nextVisitDate : string; // 다음 방문일     20180523 (YYYYMMDD)
    forDispensingComment : string; // 조제 시 참고 사항
    specialComment : string; // 기타 사항
    topComment1, topComment2, topComment3 : string; // additional comment 상단
    centerComment1, centerComment2, centerComment3 : string; // additional comment 센터
    bottomComment1, bottomComment2, bottomComment3 : string; // additional comment 하단

    constructor Create( AEventID : integer; AJobID : String ); override;
    destructor Destroy; override;

    function AddadComment( ACommentItem : TadCommentItem ) : Integer;
    function AddrxDrug( ArxDrug : TrxDrugListItem ) : Integer;

    property adCommentListCount : Integer read GetadCommentListCount;
    property adCommentList[ index : Integer ] : TadCommentItem read GetadCommentList;

    property rxDrugListCount : Integer read GetrxDrugListCount;
    property rxDrugList[ index : Integer ] : TrxDrugListItem read GetrxDrugList;
  end;

  TBridgeResponse_355 = class( TBridgeResponse )
  private
    { Private declarations }
  protected
    { protected declarations }
  public
    { Public declarations }
  end;


// ================================================================================================
// 통신 object 생성
  TepBridgeFactory = class( TBridgeFactory )
  private
    { Private declarations }
  protected
    { protected declarations }
    function MakeResponseObj( ABaseObject : TBridgeProtocol  ): TBridgeResponse; overload; override;
  public
    { Public declarations }
    function MakeRequestObj( AEventID : Integer; AJobID: string = '' ) : TBridgeRequest;  override;

    function MakeResponseObj( AEventID : Integer; AJobID : string ) : TBridgeResponse; overload; override;

    function GetErrorString( AErrorNum : Integer ) : string; override;
  end;


const // event id
  EventID_자동결제여부확인요청        = 140;    // 차트->굿닥
  EventID_자동결제여부확인요청결과    = 141;    // 차트->굿닥
  EventID_자동결제요청                = 142;    // 차트->굿닥
  EventID_자동결제요청결과            = 143;    // 차트->굿닥
  EventID_자동결제취소요청            = 144;    // 차트->굿닥
  EventID_자동결제취소요청결과        = 145;    // 차트->굿닥
  EventID_자동결제병원확인요청        = 310;    // 차트->굿닥
  EventID_자동결제병원확인요청결과    = 311;    // 차트->굿닥
  EventID_상세할부옵션요청            = 312;    // 차트->굿닥
  EventID_상세할부옵션요청결과        = 313;    // 차트->굿닥

  EventID_전자처방전병원조회          = 350;   // 차트->굿닥
  EventID_전자처방전병원조회결과      = 351;   //
  EventID_전자처방전발급설정          = 352;   // 굿닥->차트
  EventID_전자처방전발급설정결과      = 353;   //
  EventID_전자처방전발급              = 354;   // 차트->굿닥
  EventID_전자처방전발급결과          = 355;   //


const
  FN_pres                   = 'pres';
  FN_version                = 'version';
  FN_patientName            = 'patientName';
  FN_insureName             = 'insureName';
  FN_patientSid             = 'patientSid';
  FN_patientUnitNo          = 'patientUnitNo';
  FN_patientAge             = 'patientAge';
  FN_patientSex             = 'patientSex';
  FN_patientAddr            = 'patientAddr';
  FN_reimburseType          = 'reimburseType';
  FN_reimburseTypeName      = 'reimburseTypeName';
  FN_reimburseDetailType    = 'reimburseDetailType';
  FN_reimburseDetailName    = 'reimburseDetailName';
  FN_reimburseExcpCalc      = 'reimburseExcpCalc';
  FN_reimburseViewDetailName = 'reimburseViewDetailName';
  FN_excpCalcCode           = 'excpCalcCode';
  FN_identifyingSid         = 'identifyingSid';
  FN_relationPatnt          = 'relationPatnt';
  FN_organUnitNo            = 'organUnitNo';
  FN_organName              = 'organName';
  FN_patriotId              = 'patriotId';
  FN_accidentHospUnitNo     = 'accidentHospUnitNo';
  FN_accidentManagementNo   = 'accidentManagementNo';
  FN_accidentWorkplaceName  = 'accidentWorkplaceName';
  FN_accidentHappenDate     = 'accidentHappenDate';
  FN_specialCode            = 'specialCode';
  FN_rxSerialNo             = 'rxSerialNo';
  FN_rxMedInfoNo            = 'rxMedInfoNo';
  FN_rxAllMedNo             = 'rxAllMedNo';
  FN_rxMakeDate             = 'rxMakeDate';
  FN_rxIssueTimestamp       = 'rxIssueTimestamp';
  FN_hospUnitNo             = 'hospUnitNo';
  FN_medicalCenterName      = 'medicalCenterName';
  FN_hospName               = 'hospName';
  FN_hospTelNo              = 'hospTelNo';
  FN_hospFaxNo              = 'hospFaxNo';
  FN_hospRepName            = 'hospRepName';
  FN_hospEmail              = 'hospEmail';
  FN_hospAddr               = 'hospAddr';
  FN_hospUrl                = 'hospUrl';
  FN_deptMediCode           = 'deptMediCode';
  FN_docLicenseNo           = 'docLicenseNo';
  FN_docName                = 'docName';
  FN_docLicenseType         = 'docLicenseType';
  FN_docLicenseTypeName     = 'docLicenseTypeName';
  FN_docSpecialty           = 'docSpecialty';
  FN_docTelNo               = 'docTelNo';
  FN_docEmail               = 'docEmail';
  FN_diagnosisCode1         = 'diagnosisCode1';
  FN_diagnosisCode2         = 'diagnosisCode2';
  FN_diagnosisCode3         = 'diagnosisCode3';
  FN_rxEffectivePeriod      = 'rxEffectivePeriod';
  FN_nextVisitDate          = 'nextVisitDate';
  FN_forDispensingComment   = 'forDispensingComment';
  FN_specialComment         = 'specialComment';
  FN_topComment1            = 'topComment1';
  FN_topComment2            = 'topComment2';
  FN_topComment3            = 'topComment3';
  FN_centerComment1         = 'centerComment1';
  FN_centerComment2         = 'centerComment2';
  FN_centerComment3         = 'centerComment3';
  FN_bottomComment1         = 'bottomComment1';
  FN_bottomComment2         = 'bottomComment2';
  FN_bottomComment3         = 'bottomComment3';

  FN_additionalCommentList  = 'additionalCommentList';
    FN_resnm                  = 'resnm';
    FN_resncnts               = 'resncnts';
    FN_hngnm                  = 'hngnm';

  FN_rxDrugList             = 'rxDrugList';
    FN_drugCode               = 'drugCode';
    FN_drugKorName            = 'drugKorName';
    FN_drugEngName            = 'drugEngName';
    FN_ingredientName         = 'ingredientName';
    FN_drugReimbursementType  = 'drugReimbursementType';
    FN_drugAdminRoute         = 'drugAdminRoute';
    FN_drugListEnrollType     = 'drugListEnrollType';
    FN_drugDose               = 'drugDose';
    FN_drugAdminCount         = 'drugAdminCount';
    FN_drugTreatmentPeriod    = 'drugTreatmentPeriod';
    FN_totalAdminDose         = 'totalAdminDose';
    FN_drugPackageFlag        = 'drugPackageFlag';
    FN_drugOutsideFlag        = 'drugOutsideFlag';
    FN_docClsType             = 'docClsType';
    FN_drugAdminCode          = 'drugAdminCode';
    FN_drugAdminComment       = 'drugAdminComment';
    FN_docComment             = 'docComment';
    FN_prnCheck               = 'prnCheck';

  // 결제 관련
  FN_userAmt                = 'userAmt';
  FN_totalAmt               = 'totalAmt';
  FN_nhisAmt                = 'nhisAmt';
  FN_planMonth              = 'planMonth';
  FN_resultCd               = 'resultCd'; //PG사 결제 응답코드( 00 외 오류 코드
  FN_resultMsg              = 'resultMsg'; //PG사 결제 응답메시지, 승인 결과로 이 메시지를 사용자에게 보여주는 것이 가장 확심함.
  FN_transDttm              = 'transDttm'; //거래 일시
  FN_payAuthNo              = 'payAuthNo'; // 승인 번호
  FN_reason                 = 'reason'; // 취소 사유
  FN_active                 = 'active'; // 자동결제 사용
  FN_usePlan                = 'usePlan'; // 할부결제 사용
  FN_priceAmt               = 'priceAmt'; // 1회 승인가능 금액
  FN_minPrice               = 'minPrice'; // 할부 최소 금액
  FN_monthList              = 'monthList';
    FN_CD                     = 'cd';  // 할부 코드
    FN_NM                     = 'nm';  // BC 카드

implementation
uses
  math, UtilsUnit;

{ TBridgeRequest_350 }

procedure TBridgeRequest_350.ConvertJson(AJsonWriter: TGDJsonTextWriter);
begin
  inherited ConvertJson(AJsonWriter);

  with AJsonWriter do
  begin
    WriteValue(FN_HospitalNo, hospitalNo);
  end;
end;

constructor TBridgeRequest_350.Create(AEventID: integer; AJobID: String);
begin
  inherited;

end;

destructor TBridgeRequest_350.Destroy;
begin

  inherited;
end;

{ TBridgeResponse_351 }

function TBridgeResponse_351.AnalysisJson(AJsonRoot: TJSONObject): Integer;
var
  resultjson : TJSONObject;
begin
  Result := inherited AnalysisJson( AJsonRoot );

  resultjson := FindObjectGDJson(AJsonRoot, FN_Result );
  if not Assigned( resultjson ) then
  begin
    Result := Result_필수항목누락;
    exit;
  end;

  if ExistObjectGDJson( resultjson, FN_Prescription ) then
    Fprescription := GetValueIntegerGDJson(resultjson, FN_Prescription) else Result := Result_필수항목누락;
end;

constructor TBridgeResponse_351.Create(ABaseProtocol: TBridgeProtocol);
begin
  inherited;
  FPrescription := 0;
end;

{ TBridgeResponse_352 }

function TBridgeResponse_352.AnalysisJson(AJsonRoot: TJSONObject): Integer;
var
  ResultJson : TJSONObject;
begin
  inherited AnalysisJson( AJsonRoot );
  Result := Result_Success;
  ResultJson := AJsonRoot;

  if ExistObjectGDJson( ResultJson, FN_HospitalNo ) then
    FHospitalNO := GetValueStringGDJson(ResultJson, FN_HospitalNo) else Result := Result_필수항목누락;

  if ExistObjectGDJson( ResultJson, FN_gdid ) then
    Fgdid := GetValueStringGDJson(ResultJson, FN_gdid) else Result := Result_필수항목누락;

  if ExistObjectGDJson( ResultJson, FN_chartReceptnResultId1 ) then
    FchartReceptnResultId.Id1 := GetValueStringGDJson(ResultJson, FN_chartReceptnResultId1) else Result := Result_필수항목누락;
  FchartReceptnResultId.Id2 := GetValueStringGDJson(ResultJson, FN_chartReceptnResultId2);
  FchartReceptnResultId.Id3 := GetValueStringGDJson(ResultJson, FN_chartReceptnResultId3);
  FchartReceptnResultId.Id4 := GetValueStringGDJson(ResultJson, FN_chartReceptnResultId4);
  FchartReceptnResultId.Id5 := GetValueStringGDJson(ResultJson, FN_chartReceptnResultId5);
  FchartReceptnResultId.Id6 := GetValueStringGDJson(ResultJson, FN_chartReceptnResultId6);

  if ExistObjectGDJson( ResultJson, FN_hipass ) then
    Fhipass := GetValueIntegerGDJson(ResultJson, FN_hipass) else Result := Result_필수항목누락;
  if ExistObjectGDJson( ResultJson, FN_Prescription ) then
    FPrescription := GetValueIntegerGDJson(ResultJson, FN_Prescription) else Result := Result_필수항목누락;

  FparmNo := GetValueStringGDJson(ResultJson, FN_parmNo);
  if ExistObjectGDJson( ResultJson, FN_parmNo ) then
    FparmNo := GetValueStringGDJson(ResultJson, FN_parmNo) else Result := Result_필수항목누락;

  FparmNm := GetValueStringGDJson(ResultJson, FN_parmNm);
  FextraInfo  := GetValueStringGDJson(ResultJson, FN_extraInfo);
end;

{ TBridgeRequest_354 }

function TBridgeRequest_354.AddadComment(ACommentItem: TadCommentItem): Integer;
begin
  Result := FadCommentList.Add( ACommentItem );
end;

function TBridgeRequest_354.AddrxDrug(ArxDrug: TrxDrugListItem): Integer;
begin
  Result := FrxDrugList.Add( ArxDrug );
end;

procedure TBridgeRequest_354.ConvertJson(AJsonWriter: TGDJsonTextWriter);
var
  i : Integer;
  adCommentitem : TadCommentItem;
  rxDrugListItem : TrxDrugListItem;
begin
  inherited ConvertJson(AJsonWriter);

  with AJsonWriter do
  begin
    WriteValue(FN_HospitalNo, hospitalNo);
    WriteValue(FN_gdid, gdid);
    WriteValue(FN_ePrescriptionPatient, ePrescriptionPatient);
    WriteValue(FN_ChartReceptnResultId1, chartReceptnResultId.Id1);
    WriteValue(FN_ChartReceptnResultId2, chartReceptnResultId.Id2);
    WriteValue(FN_ChartReceptnResultId3, chartReceptnResultId.Id3);
    WriteValue(FN_ChartReceptnResultId4, chartReceptnResultId.Id4);
    WriteValue(FN_ChartReceptnResultId5, chartReceptnResultId.Id5);
    WriteValue(FN_ChartReceptnResultId6, chartReceptnResultId.Id6);

    StartObject(FN_pres);
      WriteValue(FN_version, version);
      WriteValue(FN_patientName, patientName);
      WriteValue(FN_insureName, insureName);
      WriteValue(FN_patientSid, patientSid);
      WriteValue(FN_patientUnitNo, patientUnitNo);
      WriteValue(FN_patientAge, patientAge);
      WriteValue(FN_patientSex, patientSex);
      WriteValue(FN_patientAddr, patientAddr);
      WriteValue(FN_reimburseType, reimburseType);
      WriteValue(FN_reimburseTypeName, reimburseTypeName);
      WriteValue(FN_reimburseDetailType, reimburseDetailType);
      WriteValue(FN_reimburseDetailName, reimburseDetailName);
      if reimburseExcpCalc <> 0 then // 의료 보험 이외에는 추가 하지 않는다.
        WriteValue(FN_reimburseExcpCalc, reimburseExcpCalc);
      WriteValue(FN_reimburseViewDetailName, reimburseViewDetailName);
      WriteValue(FN_excpCalcCode, excpCalcCode);
      WriteValue(FN_identifyingSid, identifyingSid);
      WriteValue(FN_relationPatnt, relationPatnt);
      WriteValue(FN_organUnitNo, organUnitNo);
      WriteValue(FN_organName, organName);
      WriteValue(FN_patriotId, patriotId);
      WriteValue(FN_accidentHospUnitNo, accidentHospUnitNo);
      WriteValue(FN_accidentManagementNo, accidentManagementNo);
      WriteValue(FN_accidentWorkplaceName, accidentWorkplaceName);
      WriteValue(FN_accidentHappenDate, accidentHappenDate);
      WriteValue(FN_specialCode, specialCode);
      WriteValue(FN_rxSerialNo, rxSerialNo);
      WriteValue(FN_rxMedInfoNo, rxMedInfoNo);
      WriteValue(FN_rxAllMedNo, rxAllMedNo);
      WriteValue(FN_rxMakeDate, rxMakeDate);
      WriteValue(FN_rxIssueTimestamp, rxIssueTimestamp);
      WriteValue(FN_hospUnitNo, hospUnitNo);
      WriteValue(FN_medicalCenterName, medicalCenterName);
      WriteValue(FN_hospName, hospName);
      WriteValue(FN_hospTelNo, hospTelNo);
      WriteValue(FN_hospFaxNo, hospFaxNo);
      WriteValue(FN_hospRepName, hospRepName);
      WriteValue(FN_hospEmail, hospEmail);
      WriteValue(FN_hospAddr, hospAddr);
      WriteValue(FN_hospUrl, hospUrl);
      WriteValue(FN_deptMediCode, deptMediCode);
      WriteValue(FN_docLicenseNo, docLicenseNo);
      WriteValue(FN_docName, docName);
      WriteValue(FN_docLicenseType, docLicenseType);
      WriteValue(FN_docLicenseTypeName, docLicenseTypeName);
      WriteValue(FN_docSpecialty, docSpecialty);
      WriteValue(FN_docTelNo, docTelNo);
      WriteValue(FN_docEmail, docEmail);
      WriteValue(FN_diagnosisCode1, diagnosisCode1);
      WriteValue(FN_diagnosisCode2, diagnosisCode3);
      WriteValue(FN_diagnosisCode3, diagnosisCode3);
      WriteValue(FN_rxEffectivePeriod, rxEffectivePeriod);
      WriteValue(FN_nextVisitDate, nextVisitDate);
      WriteValue(FN_forDispensingComment, forDispensingComment);
      WriteValue(FN_specialComment, specialComment);
      WriteValue(FN_topComment1, topComment1);
      WriteValue(FN_topComment2, topComment2);
      WriteValue(FN_topComment3, topComment3);
      WriteValue(FN_centerComment1, centerComment1);
      WriteValue(FN_centerComment2, centerComment2);
      WriteValue(FN_centerComment3, centerComment3);
      WriteValue(FN_bottomComment1, bottomComment1);
      WriteValue(FN_bottomComment2, bottomComment2);
      WriteValue(FN_bottomComment3, bottomComment3);

      StartArray(FN_additionalCommentList);
      for i := 0 to adCommentListCount -1 do
      begin
        adCommentitem := adCommentList[ i ];
        if not Assigned(adCommentitem) then
          Continue;
        StartObject;
          WriteValue(FN_resnm, adCommentitem.resnm);
          WriteValue(FN_resncnts, adCommentitem.resncnts);
          WriteValue(FN_hngnm, adCommentitem.hngnm);
        EndObject;
      end;
      EndArray;

      StartArray(FN_rxDrugList);
      for i := 0 to rxDrugListCount-1 do
      begin
        rxDrugListItem := rxDrugList[ i ];
        if not Assigned(rxDrugListItem) then
          Continue;
        StartObject;
          WriteValue(FN_drugCode, rxDrugListItem.drugCode);
          WriteValue(FN_drugKorName, rxDrugListItem.drugKorName);
          WriteValue(FN_drugEngName, rxDrugListItem.drugEngName);
          WriteValue(FN_ingredientName, rxDrugListItem.ingredientName);
          WriteValue(FN_drugReimbursementType, rxDrugListItem.drugReimbursementType);
          WriteValue(FN_drugAdminRoute, rxDrugListItem.drugAdminRoute);
          WriteValue(FN_drugListEnrollType, rxDrugListItem.drugListEnrollType);
          WriteValue(FN_drugDose, rxDrugListItem.drugDose);
          WriteValue(FN_drugAdminCount, rxDrugListItem.drugAdminCount);
          WriteValue(FN_drugTreatmentPeriod, rxDrugListItem.drugTreatmentPeriod);
          WriteValue(FN_totalAdminDose, rxDrugListItem.totalAdminDose);
          WriteValue(FN_drugPackageFlag, rxDrugListItem.drugPackageFlag);
          WriteValue(FN_drugOutsideFlag, rxDrugListItem.drugOutsideFlag);
          WriteValue(FN_docClsType, rxDrugListItem.docClsType);
          WriteValue(FN_drugAdminCode, rxDrugListItem.drugAdminCode);
          WriteValue(FN_drugAdminComment, rxDrugListItem.drugAdminComment);
          WriteValue(FN_docComment, rxDrugListItem.docComment);
          WriteValue(FN_prnCheck, rxDrugListItem.prnCheck);
        EndObject;
      end;
      EndArray;

    EndObject;
  end;
end;

constructor TBridgeRequest_354.Create(AEventID: integer; AJobID: String);
begin
  inherited;
  FadCommentList := TObjectList.Create( True );
  FrxDrugList := TObjectList.Create( True );
end;

destructor TBridgeRequest_354.Destroy;
begin
  FreeAndNil( FadCommentList );
  FreeAndNil( FrxDrugList );
  inherited;
end;

function TBridgeRequest_354.GetadCommentList(index: Integer): TadCommentItem;
begin
  Result := TadCommentItem( FadCommentList.Items[ index ] );
end;

function TBridgeRequest_354.GetadCommentListCount: Integer;
begin
  Result := FadCommentList.Count;
end;

function TBridgeRequest_354.GetrxDrugList(index: Integer): TrxDrugListItem;
begin
  Result := TrxDrugListItem( FrxDrugList.Items[ index ] );
end;

function TBridgeRequest_354.GetrxDrugListCount: Integer;
begin
  Result := FrxDrugList.Count;
end;

{ TepBridgeFactory }

function TepBridgeFactory.GetErrorString(AErrorNum: Integer): string;
begin
  Result := inherited GetErrorString( AErrorNum );
end;

function TepBridgeFactory.MakeRequestObj(AEventID: Integer;
  AJobID: string): TBridgeRequest;
var
  jobid : string;
begin
  jobid := AJobID;
  if jobid = '' then
    jobid := MakeJobID;

  case AEventID of
    EventID_자동결제여부확인요청    : Result := TBridgeRequest_140.Create(EventID_자동결제여부확인요청, jobid);    // 차트->굿닥
    EventID_자동결제요청            : Result := TBridgeRequest_142.Create(EventID_자동결제요청, jobid);    // 차트->굿닥
    EventID_자동결제취소요청        : Result := TBridgeRequest_144.Create(EventID_자동결제취소요청, jobid);    // 차트->굿닥
    EventID_자동결제병원확인요청    : Result := TBridgeRequest_310.Create(EventID_자동결제병원확인요청, jobid);    // 차트->굿닥
    EventID_상세할부옵션요청        : Result := TBridgeRequest_312.Create(EventID_상세할부옵션요청, jobid);    // 차트->굿닥
    EventID_전자처방전병원조회{350} : Result := TBridgeRequest_350.Create(EventID_전자처방전병원조회, jobid);    // 차트->굿닥
    EventID_전자처방전발급설정결과  : Result := TBridgeResponse_353.Create( EventID_전자처방전발급설정결과, jobid );
    EventID_전자처방전발급   {354}  : Result := TBridgeRequest_354.Create(EventID_전자처방전발급, jobid);   // 차트->굿닥
//          = 355;   //
  else
    Result := inherited MakeRequestObj( AEventID, jobid );
  end;
end;

function TepBridgeFactory.MakeResponseObj(
   ABaseObject : TBridgeProtocol ): TBridgeResponse;
begin
  case ABaseObject.EventID of
    EventID_자동결제여부확인요청결과: Result := TBridgeResponse_141.Create( ABaseObject );    // 차트->굿닥
    EventID_자동결제요청결과        : Result := TBridgeResponse_143.Create( ABaseObject );    // 차트->굿닥
    EventID_자동결제취소요청결과    : Result := TBridgeResponse_145.Create( ABaseObject );    // 차트->굿닥
    EventID_자동결제병원확인요청결과: Result := TBridgeResponse_311.Create( ABaseObject );    // 차트->굿닥
    EventID_상세할부옵션요청결과    : Result := TBridgeResponse_313.Create( ABaseObject );    // 차트->굿닥
    EventID_전자처방전병원조회결과  : Result := TBridgeResponse_351.Create( ABaseObject );
    EventID_전자처방전발급설정      : Result := TBridgeResponse_352.Create( ABaseObject );
    EventID_전자처방전발급결과      : Result := TBridgeResponse_355.Create( ABaseObject );
  else
    Result := inherited MakeResponseObj(ABaseObject);
    exit;
  end;

  if Assigned( Result ) then
    Result.Analysis;
end;

function TepBridgeFactory.MakeResponseObj(AEventID: Integer;
  AJobID: string): TBridgeResponse;
(*var
  base : TBridgeProtocol;*)
begin
(*  base := TBridgeProtocol.Create( AEventID, AJobID );
  case base.EventID of
    EventID_전자처방전발급설정결과  : ; Result := TBridgeRequest_353.Create( base );
  else
    Result := inherited MakeResponseObj(AEventID, AJobID);
  end;*)
  Result := inherited MakeResponseObj(AEventID, AJobID);
end;


{ TBridgeRequest_312 }

procedure TBridgeRequest_312.ConvertJson(AJsonWriter: TGDJsonTextWriter);
begin
  inherited ConvertJson(AJsonWriter);

  with AJsonWriter do
  begin
    WriteValue(FN_HospitalNo, hospitalNo);
  end;
end;

constructor TBridgeRequest_312.Create(AEventID: integer; AJobID: String);
begin
  inherited;

end;

{ TBridgeResponse_313 }

function TBridgeResponse_313.AnalysisJson(AJsonRoot: TJSONObject): Integer;
var
  i : Integer;
  resultjson, datajson : TJSONObject;
  listJson : TJSONArray;
  item : TCardmonthListItem;
begin
  Result := inherited AnalysisJson( AJsonRoot );

  resultjson := FindObjectGDJson(AJsonRoot, FN_Result );
  if not Assigned( resultjson ) or TJSONValue(resultjson).Null then
  begin
    Result := Result_필수항목누락;
    exit;
  end;

  if ExistObjectGDJson( resultjson, FN_minPrice ) then
    FminPrice := GetValueIntegerGDJson(resultjson, FN_minPrice) else Result := Result_필수항목누락;

  if not ExistObjectGDJson( resultjson, FN_monthList ) then
  begin
    Result := Result_필수항목누락;
    exit;
  end;

  listJson := TJSONArray( FindObjectGDJson(resultjson, FN_monthList) );
  if (not Assigned( listJson ) ) or (listJson.Count = 0) then
    exit;

  for i := 0 to listJson.Count -1 do
  begin
    datajson := TJSONObject( listJson.Items[ i ] );

    if not ( ExistObjectGDJson( datajson, FN_CD ) and ExistObjectGDJson( datajson, FN_NM ) ) then
    begin
      Result := Result_필수항목누락;
      exit;
    end;

    item := TCardmonthListItem.Create;

    item.cd := GetValueStringGDJson(datajson, FN_CD );
    item.nm := GetValueStringGDJson(datajson, FN_NM );

    flist.Add( item );
  end;
end;

constructor TBridgeResponse_313.Create(ABaseProtocol: TBridgeProtocol);
begin
  inherited;
  flist := TObjectList.Create( True );
end;

destructor TBridgeResponse_313.Destroy;
begin
  flist.Clear;
  FreeAndNil( flist );
  inherited;
end;

function TBridgeResponse_313.GetCount: Integer;
begin
  Result := flist.Count;
end;

function TBridgeResponse_313.GetmonthList(AIndex: Integer): TCardmonthListItem;
begin
  result := TCardmonthListItem( flist.Items[ AIndex ] );
end;

{ TBridgeRequest_310 }

procedure TBridgeRequest_310.ConvertJson(AJsonWriter: TGDJsonTextWriter);
begin
  inherited ConvertJson(AJsonWriter);

  with AJsonWriter do
  begin
    WriteValue(FN_HospitalNo, hospitalNo);
  end;
end;

constructor TBridgeRequest_310.Create(AEventID: integer; AJobID: String);
begin
  inherited;

end;

{ TBridgeResponse_311 }

function TBridgeResponse_311.AnalysisJson(AJsonRoot: TJSONObject): Integer;
var
  resultjson : TJSONObject;
begin
  Result := inherited AnalysisJson( AJsonRoot );

  resultjson := FindObjectGDJson(AJsonRoot, FN_Result );
  if not Assigned( resultjson ) or TJSONValue(resultjson).Null then
  begin
    Result := Result_필수항목누락;
    exit;
  end;

  if ExistObjectGDJson( resultjson, FN_active ) then
    FActive := GetValueBooleanGDJson(resultjson, FN_active) else Result := Result_필수항목누락;

  if ExistObjectGDJson( resultjson, FN_usePlan ) then
    FusePlan := GetValueBooleanGDJson(resultjson, FN_usePlan) else Result := Result_필수항목누락;

  if ExistObjectGDJson( resultjson, FN_priceAmt ) then
    FpriceAmt := GetValueCardinalGDJson(resultjson, FN_priceAmt) else Result := Result_필수항목누락;
end;

constructor TBridgeResponse_311.Create(ABaseProtocol: TBridgeProtocol);
begin
  inherited;

end;

destructor TBridgeResponse_311.Destroy;
begin

  inherited;
end;

{ TBridgeRequest_144 }

procedure TBridgeRequest_144.ConvertJson(AJsonWriter: TGDJsonTextWriter);
begin
  inherited;

  with AJsonWriter do
  begin
    WriteValue(FN_HospitalNo, hospitalNo);
    WriteValue(FN_ChartReceptnResultId1, chartReceptnResultId.Id1);
    WriteValue(FN_ChartReceptnResultId2, chartReceptnResultId.Id2);
    WriteValue(FN_ChartReceptnResultId3, chartReceptnResultId.Id3);
    WriteValue(FN_ChartReceptnResultId4, chartReceptnResultId.Id4);
    WriteValue(FN_ChartReceptnResultId5, chartReceptnResultId.Id5);
    WriteValue(FN_ChartReceptnResultId6, chartReceptnResultId.Id6);

    WriteValue(FN_payAuthNo, payAuthNo);
    WriteValue(FN_reason, reason);
  end;
end;

constructor TBridgeRequest_144.Create(AEventID: integer; AJobID: String);
begin
  inherited;

end;

{ TBridgeResponse_145 }

function TBridgeResponse_145.AnalysisJson(AJsonRoot: TJSONObject): Integer;
var
  ResultJson : TJSONObject;
begin
  inherited AnalysisJson( AJsonRoot );
  Result := Result_Success;
  resultjson := FindObjectGDJson(AJsonRoot, FN_Result );

  if not Assigned( resultjson ) or TJSONValue(resultjson).Null then
  begin
    Result := Result_필수항목누락;
    exit;
  end;

  if ExistObjectGDJson( ResultJson, FN_chartReceptnResultId1 ) then
    FchartReceptnResultId.Id1 := GetValueStringGDJson(ResultJson, FN_chartReceptnResultId1) else Result := Result_필수항목누락;
  FchartReceptnResultId.Id2 := GetValueStringGDJson(ResultJson, FN_chartReceptnResultId2);
  FchartReceptnResultId.Id3 := GetValueStringGDJson(ResultJson, FN_chartReceptnResultId3);
  FchartReceptnResultId.Id4 := GetValueStringGDJson(ResultJson, FN_chartReceptnResultId4);
  FchartReceptnResultId.Id5 := GetValueStringGDJson(ResultJson, FN_chartReceptnResultId5);
  FchartReceptnResultId.Id6 := GetValueStringGDJson(ResultJson, FN_chartReceptnResultId6);

  if ExistObjectGDJson( ResultJson, FN_resultCd ) then
    FresultCd := GetValueStringGDJson(ResultJson, FN_resultCd) else Result := Result_필수항목누락;

  if ExistObjectGDJson( ResultJson, FN_resultMsg ) then
    FresultMsg := GetValueStringGDJson(ResultJson, FN_resultMsg) else Result := Result_필수항목누락;

  FtransDttm := '';
  if ExistObjectGDJson( ResultJson, FN_transDttm ) then
    //FtransDttm := MakeDttmStr2DateTime( GetValueStringGDJson(ResultJson, FN_transDttm) )
    FtransDttm := GetValueStringGDJson(ResultJson, FN_transDttm)
  else
    Result := Result_필수항목누락;
end;

constructor TBridgeResponse_145.Create(ABaseProtocol: TBridgeProtocol);
begin
  inherited;

end;

destructor TBridgeResponse_145.Destroy;
begin

  inherited;
end;

{ TBridgeRequest_142 }

procedure TBridgeRequest_142.ConvertJson(AJsonWriter: TGDJsonTextWriter);
begin
  inherited;

  with AJsonWriter do
  begin
    WriteValue(FN_HospitalNo, hospitalNo);
    WriteValue(FN_ChartReceptnResultId1, chartReceptnResultId.Id1);
    WriteValue(FN_ChartReceptnResultId2, chartReceptnResultId.Id2);
    WriteValue(FN_ChartReceptnResultId3, chartReceptnResultId.Id3);
    WriteValue(FN_ChartReceptnResultId4, chartReceptnResultId.Id4);
    WriteValue(FN_ChartReceptnResultId5, chartReceptnResultId.Id5);
    WriteValue(FN_ChartReceptnResultId6, chartReceptnResultId.Id6);

    WriteValue(FN_userAmt, userAmt);
    WriteValue(FN_totalAmt, totalAmt);
    WriteValue(FN_nhisAmt, nhisAmt);
    WriteValue(FN_planMonth, planMonth);
  end;
end;

constructor TBridgeRequest_142.Create(AEventID: integer; AJobID: String);
begin
  inherited;

end;

{ TBridgeResponse_143 }

function TBridgeResponse_143.AnalysisJson(AJsonRoot: TJSONObject): Integer;
var
  ResultJson : TJSONObject;
begin
  inherited AnalysisJson( AJsonRoot );

  Result := Result_Success;
  resultjson := FindObjectGDJson(AJsonRoot, FN_Result );

  if not Assigned( resultjson ) or TJSONValue(resultjson).Null then
  begin
    Result := Result_필수항목누락;
    exit;
  end;

  if ExistObjectGDJson( ResultJson, FN_chartReceptnResultId1 ) then
    FchartReceptnResultId.Id1 := GetValueStringGDJson(ResultJson, FN_chartReceptnResultId1) else Result := Result_필수항목누락;
  FchartReceptnResultId.Id2 := GetValueStringGDJson(ResultJson, FN_chartReceptnResultId2);
  FchartReceptnResultId.Id3 := GetValueStringGDJson(ResultJson, FN_chartReceptnResultId3);
  FchartReceptnResultId.Id4 := GetValueStringGDJson(ResultJson, FN_chartReceptnResultId4);
  FchartReceptnResultId.Id5 := GetValueStringGDJson(ResultJson, FN_chartReceptnResultId5);
  FchartReceptnResultId.Id6 := GetValueStringGDJson(ResultJson, FN_chartReceptnResultId6);

  FpayAuthNo := GetValueStringGDJson(ResultJson, FN_payAuthNo);
  FplanMonth := GetValueStringGDJson(ResultJson, FN_planMonth);

  if ExistObjectGDJson( ResultJson, FN_resultCd ) then
    FresultCd := GetValueStringGDJson(ResultJson, FN_resultCd) else Result := Result_필수항목누락;

  if ExistObjectGDJson( ResultJson, FN_resultMsg ) then
    FresultMsg := GetValueStringGDJson(ResultJson, FN_resultMsg) else Result := Result_필수항목누락;

  FtransDttm := '';
  if ExistObjectGDJson( ResultJson, FN_transDttm ) then
    //FtransDttm := MakeDttmStr2DateTime( GetValueStringGDJson(ResultJson, FN_transDttm) )
    FtransDttm := GetValueStringGDJson(ResultJson, FN_transDttm)
  else
    Result := Result_필수항목누락;
end;

constructor TBridgeResponse_143.Create(ABaseProtocol: TBridgeProtocol);
begin
  inherited;

end;

destructor TBridgeResponse_143.Destroy;
begin

  inherited;
end;

{ TBridgeRequest_140 }

procedure TBridgeRequest_140.ConvertJson(AJsonWriter: TGDJsonTextWriter);
begin
  inherited;

  with AJsonWriter do
  begin
    WriteValue(FN_HospitalNo, hospitalNo);
    WriteValue(FN_ChartReceptnResultId1, chartReceptnResultId.Id1);
    WriteValue(FN_ChartReceptnResultId2, chartReceptnResultId.Id2);
    WriteValue(FN_ChartReceptnResultId3, chartReceptnResultId.Id3);
    WriteValue(FN_ChartReceptnResultId4, chartReceptnResultId.Id4);
    WriteValue(FN_ChartReceptnResultId5, chartReceptnResultId.Id5);
    WriteValue(FN_ChartReceptnResultId6, chartReceptnResultId.Id6);
  end;
end;

constructor TBridgeRequest_140.Create(AEventID: integer; AJobID: String);
begin
  inherited;

end;

{ TBridgeResponse_141 }

function TBridgeResponse_141.AnalysisJson(AJsonRoot: TJSONObject): Integer;
var
  resultjson : TJSONObject;
begin
  Result := inherited AnalysisJson( AJsonRoot );

  resultjson := FindObjectGDJson(AJsonRoot, FN_Result );
  if not Assigned( resultjson ) then
  begin
    Result := Result_필수항목누락;
    exit;
  end;

  if ExistObjectGDJson( resultjson, FN_active ) then
    FActive := GetValueIntegerGDJson(resultjson, FN_active) else Result := Result_필수항목누락;
end;

constructor TBridgeResponse_141.Create(ABaseProtocol: TBridgeProtocol);
begin
  inherited;

end;

destructor TBridgeResponse_141.Destroy;
begin

  inherited;
end;

end.
