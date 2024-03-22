unit BridgeCommUnit;
(*
  bridge와 통신을 위해 사용되는 protocol class를 정의 한다.
  class 이름 기준은 bridge와 차트간 통신을 기준으로 차트에서 바라본 송신/수신을 기준으로 한다.
*)

interface
uses
  System.SysUtils, System.Variants, System.Classes, System.Contnrs,
  System.JSON.Types, json, GDJson;

type
  TBridgeProtocol = class
  private
    { Private declarations }
    FEventID: integer;
    FJobID: string;
    FJsonRoot : TJSONObject;
  public
    { Public declarations }
    constructor Create( AEventID : integer; AJobID : String ); overload; virtual;
    constructor Create( AJsonRoot : TJSONObject ); overload; virtual;
    destructor Destroy; override;

    // eventid, jobid가 없으면 false을 반환 한다.
    function CheckNecessaryField : Boolean;

    property EventID : integer read FEventID;
    property JobID : string read FJobID;
  end;

  TBridgeRequest = class
  private
    { Private declarations }
    FBase : TBridgeProtocol;
    function GetEventID: Integer;
    function GetJobID: string;
  protected
    { protected declarations }
    // 이 부분에서 json으로 만들어질 json string을 등록 하게 한다. 자신 정보만 등록 해야 한다.
    procedure ConvertJson( AJsonWriter : TGDJsonTextWriter ); virtual;
  public
    { Public declarations }
    constructor Create( AEventID : integer; AJobID : String ); virtual;
    destructor Destroy; override;

    function ToJsonString : string;
    procedure Save( AFileName : string );

    property EventID : Integer read GetEventID;
    property JobID : string read GetJobID;
  end;

  TBridgeResponse = class
  private
    { Private declarations }
    FBase : TBridgeProtocol;
    FCode : Integer;
    FMessage : string;
    FAnalysisErrorCode: Integer;
    function GetEventID: Integer;
    function GetJobID: string;
  protected
    { protected declarations }
    // 이 부분에서 응답받은 data를 분석 해야 한다. 자신의 정보만 분석 하면 된다.
    {
      0 : 문제 없다
      3 : 필수 항목 누락
    }
    function AnalysisJson( AJsonRoot : TJSONObject ) : Integer; virtual;
  public
    { Public declarations }
    constructor Create( ABaseProtocol : TBridgeProtocol ); virtual;
    destructor Destroy; override;

    function Analysis : Integer;

    property EventID : Integer read GetEventID;
    property JobID : string read GetJobID;
    property Code : Integer read FCode;
    property MessageStr : string read FMessage;
    property AnalysisErrorCode : Integer read FAnalysisErrorCode;
  end;

  TChartReceptnResultId = record
    Id1 : string; // data에 대한 ID
    Id2 : string; // data에 대한 ID
    Id3 : string; // data에 대한 ID
    Id4 : string; // data에 대한 ID
    Id5 : string; // data에 대한 ID
    Id6 : string; // data에 대한 ID
  end;

  TRoomInfoRecord = record
    RoomCode : string;
    RoomName : string;
    DeptCode : string;
    DeptName : string;
    DoctorCode : string;
    DoctorName : string;
  end;

  TBridgeRequest_Nomal = class( TBridgeRequest )
  private
    { Private declarations }
  protected
    { protected declarations }
    procedure ConvertJson( AJsonWriter : TGDJsonTextWriter ); override;
    procedure AddResultJson( AResultJsonWriter : TGDJsonTextWriter ); virtual;
  public
    { Public declarations }
    Code : Integer;
    MessageStr : string;
  end;

  TBridgeError_9999 = class(TBridgeResponse) // error발생시 사용 한다.
  end;

  TBridgeRequestError_9999 = class(TBridgeRequest_Nomal) // error발생시 사용 한다.
  end;

// ================================================================================================
// 굿닥 → 차트, 환자 검색
  TBridgeResponse_0 = class( TBridgeResponse )
  private
    { Private declarations }
    FCellPhone: string;
    FRegNum: string;
  protected
    { protected declarations }
    function AnalysisJson( AJsonRoot : TJSONObject ) : Integer; override;
  public
    { Public declarations }
    property CellPhone : string read FCellPhone; // 휴대 전화 번호
    property RegNum : string read FRegNum; // 주민 번호
  end;

    TPatntListItem = class
    public
      { Public declarations }
      PatntChartId : string; // 필수
      PatntName, RegNum, CellPhone, Sexdstn, Birthday : string; // 필수
      Addr, AddrDetail, Zip : string; // option
    end;

  TBridgeRequest_1 = class( TBridgeRequest_Nomal )
  private
    { Private declarations }
    FpatntList : TObjectList;
  protected
    { protected declarations }
    procedure AddResultJson( AResultJsonWriter : TGDJsonTextWriter ); override;
  public
    { Public declarations }
    HospitalNo : string;

    function Add( APatntChartID, APatntName, ARegNum, ACellPhone, ASexdstn, ABirthDay, AAddr, AAddrdetail, AZip : string ) : Integer;
    constructor Create( AEventID : integer; AJobID : String ); override;
    destructor Destroy; override;
  end;



// ================================================================================================
// 차트 → 굿닥, 접수 요청, ok
    TPurposeListItem = class
    public
      { Public declarations }
      purpose1, purpose2, purpose3 : string;
    end;

  TBridgeRequest_100 = class( TBridgeRequest )
  private
    { Private declarations }
  protected
    { protected declarations }
    procedure ConvertJson( AJsonWriter : TGDJsonTextWriter ); override;
  public
    { Public declarations }
    hospitalNo : string;
    PatntChartId : string;
    {차트에서 굿닥으로 전송되는 접수는 모두 더미로 처리 합니다.
    PatntName, RegNum, CellPhone : string;}
    Sexdstn, Birthday : string;
    addr, addrDetail, zip : string;

    RoomInfo : TRoomInfoRecord;

    ReceptionDttm : TDateTime;

    chartReceptnResultId : TChartReceptnResultId;

    gdid : string;
    ePrescriptionHospital : Integer; // 전자처방전 환자 여부(0:미사용,1:사용)

    constructor Create( AEventID : integer; AJobID : String ); override;
    destructor Destroy; override;
  end;

  TBridgeResponse_101 = class( TBridgeResponse )
  private
    { Private declarations }
  protected
    { protected declarations }
  public
    { Public declarations }
  end;


// ================================================================================================
// 굿닥 → 차트, 접수 요청, ok
  TBridgeResponse_100 = class( TBridgeResponse )
  private
    { Private declarations }
    FPurposeList : TObjectList;

    FRoomInfo : TRoomInfoRecord;
    FPatntChartID: string;
    FAddrDetail: string;
    FReceptionDttm: TDateTime;
    FBirthday: string;
    FZip: string;
    FAddr: string;
    FSexdstn: string;
    FHospitalNO: string;
    FEtcPurpose: string;
    FregNum: string;
    FPatntName: string;
    Fcellphone: string;
    FEndPoint: string;
    FInboundPath: string;
    Fgdid: string;
    FisFirst: Boolean;
    function GetPurposeListCount: Integer;
    function GetPurposeLists(index: integer): TPurposeListItem;
  protected
    { protected declarations }
    function AnalysisJson( AJsonRoot : TJSONObject ) : Integer; override;
  public
    { Public declarations }
    constructor Create( ABaseProtocol : TBridgeProtocol ); override;
    destructor Destroy; override;

    property PurposeListCount : Integer read GetPurposeListCount;
    property PurposeLists[ index : integer ] : TPurposeListItem read GetPurposeLists;

    property HospitalNO : string read FHospitalNO;
    property PatntChartID : string read FPatntChartID;
    property PatntName : string read FPatntName;
    property Cellphone : string read Fcellphone;
    property RegNum : string read FregNum;
    property Sexdstn : string read FSexdstn;
    property Birthday : string read FBirthday;
    property InboundPath : string read FInboundPath;
    property Addr : string read FAddr;
    property AddrDetail : string read FAddrDetail;
    property Zip : string read FZip;

    Property RoomInfo : TRoomInfoRecord read FRoomInfo;

    property EtcPurpose : string read FEtcPurpose;
    property EndPoint : string read FEndPoint;  // 테블릿/앱 여부(T:테블릿, A:앱)
    property ReceptionDttm : TDateTime read FReceptionDttm;
    property gdid : string read Fgdid;
    property isFirst : Boolean read FisFirst;
  end;

  TBridgeRequest_101 = class( TBridgeRequest_Nomal )
  private
    { Private declarations }
  protected
    { protected declarations }
    procedure AddResultJson( AResultJsonWriter : TGDJsonTextWriter ); override;
  public
    { Public declarations }
    HospitalNo: string;
    PatntChartID: string;
    RegNum : string;

    chartReceptnResultId : TChartReceptnResultId;
    RoomInfo : TRoomInfoRecord;

    gdid: string;                   // 굿닥 아이디
    ePrescriptionHospital: integer; // 전자 처방전 병원 여부 (0:미사용,1:사용)
  public
    { Public declarations }
    constructor Create( AEventID : integer; AJobID : String ); override;
  end;

// ================================================================================================
// 차트 → 굿닥, 접수 취소(접수 취소는 양방향이므로 양쪽 class를 모두 확인 해야 한다), ok
  TBridgeRequest_102 = class( TBridgeRequest )
  private
    { Private declarations }
  protected
    { protected declarations }
    procedure ConvertJson( AJsonWriter : TGDJsonTextWriter ); override;
  public
    { Public declarations }
    HospitalNo : string;
    PatientChartID : string;  // 필수 항목임.
    CancelMessage : string;
    chartReceptnResultId : TChartReceptnResultId;
    RoomInfo : TRoomInfoRecord;
    receptStatusChangeDttm : TDateTime;
  end;

  TBridgeResponse_103 = class( TBridgeResponse )
  private
    { Private declarations }
  protected
    { protected declarations }
  public
    { Public declarations }
  end;

// ================================================================================================
// 굿닥 → 차트, 접수 취소(접수 취소는 양방향이므로 양쪽 class를 모두 확인 해야 한다), ok
  TBridgeResponse_102 = class( TBridgeResponse )
  private
    { Private declarations }
    FchartReceptnResultId : TChartReceptnResultId;
    FHospitalNo: string;
    FPatientChartID : string;
    FCancelMessage: string;
    FreceptStatusChangeDttm: TDateTime;
    FRoomInfo : TRoomInfoRecord;
  protected
    { protected declarations }
    function AnalysisJson( AJsonRoot : TJSONObject ) : Integer; override;
  public
    { Public declarations }
    property HospitalNo : string read FHospitalNo;
    property PatientChartID : string read FPatientChartID;
    property CancelMessage : string read FCancelMessage;

    property chartReceptnResultId : TChartReceptnResultId read FchartReceptnResultId;

    property RoomCode: string read FRoomInfo.RoomCode;
    property RoomName: string read FRoomInfo.RoomName;
    property DeptCode: string read FRoomInfo.DeptCode;
    property DeptName: string read FRoomInfo.DeptName;
    property DoctorCode: string read FRoomInfo.DoctorCode;
    property DoctorName: string read FRoomInfo.DoctorName;
    property receptStatusChangeDttm : TDateTime read FreceptStatusChangeDttm;
  end;

  TBridgeRequest_103 = class( TBridgeRequest_Nomal )
  private
    { Private declarations }
  protected
    { protected declarations }
  public
    { Public declarations }
  end;


// ================================================================================================
// 차트 → 굿닥, 대기 순서 변경 , ok
    TReceptnListItem = class
    public
      { Public declarations }
      chartReceptnResultId1: string;
      chartReceptnResultId2: string;
      chartReceptnResultId3: string;
      chartReceptnResultId6: string;
      chartReceptnResultId4: string;
      chartReceptnResultId5: string;
    end;

  TBridgeRequest_104 = class( TBridgeRequest )
  private
    { Private declarations }
    FReceptnList : TObjectList;
  protected
    { protected declarations }
    procedure ConvertJson( AJsonWriter : TGDJsonTextWriter ); override;
  public
    { Public declarations }
    HospitalNo: string;
    RoomInfo : TRoomInfoRecord;

    function Add( AchartReceptnResultId1 : string;
                  AchartReceptnResultId2 : string = '';
                  AchartReceptnResultId3 : string = '';
                  AchartReceptnResultId4 : string = '';
                  AchartReceptnResultId5 : string = '';
                  AchartReceptnResultId6 : string = '' ) : Integer;
    constructor Create( AEventID : integer; AJobID : String ); override;
    destructor Destroy; override;
  end;


  TBridgeResponse_105 = class( TBridgeResponse )
  private
    { Private declarations }
  protected
    { protected declarations }
  public
    { Public declarations }
  end;


// ================================================================================================
// 차트 → 굿닥, 대기열 변경, ok
    TReceptionUpdateDto = class
    public
      { Public declarations }
      chartReceptnResultId : TChartReceptnResultId;
      PatientChartId : string;
      RoomInfo : TRoomInfoRecord;
      memo : string;
      Status : string;
    end;

  TBridgeRequest_106 = class( TBridgeRequest )
  private
    { Private declarations }
  protected
    { protected declarations }
    procedure ConvertJson( AJsonWriter : TGDJsonTextWriter ); override;
  public
    { Public declarations }
    HospitalNo: string;
    RoomChangeDttm: TDateTime;
    ReceptionUpdateDto: TReceptionUpdateDto;

    constructor Create( AEventID : integer; AJobID : String ); override;
    destructor Destroy; override;
  end;

  TBridgeResponse_107 = class( TBridgeResponse )
  private
    { Private declarations }
  protected
    { protected declarations }
  public
    { Public declarations }
  end;

// ================================================================================================
// 차트 → 굿닥, 상태 정보 변경, ok
  TBridgeRequest_108 = class( TBridgeRequest )
  private
    { Private declarations }
  protected
    { protected declarations }
    procedure ConvertJson( AJsonWriter : TGDJsonTextWriter ); override;
  public
    { Public declarations }
    HospitalNo: string;
    ReceptionUpdateDto: TReceptionUpdateDto;
    NewchartReceptnResult : TChartReceptnResultId;
    receptStatusChangeDttm : TDateTime;

    constructor Create( AEventID : integer; AJobID : String ); override;
    destructor Destroy; override;
  end;

  TBridgeResponse_109 = class( TBridgeResponse )
  private
    { Private declarations }
  protected
    { protected declarations }
  public
    { Public declarations }
  end;

// ================================================================================================
// 굿닥 → 차트, 내원 확인(모바일 접수/예약인 경우), ok

  TconfirmListItem = class
  public
    chartReceptnResult : TChartReceptnResultId;
    receptnResveId : string; // 굿닥 접수 id
    receptnResveType : integer; // 0:예약, 1:접수
  end;

  TconfirmResultListItem = class( TconfirmListItem )
  public
    confirmResult : integer; // 0:실패, 1:성공
  end;

  TBridgeResponse_110 = class( TBridgeResponse )
  private
    { Private declarations }
    FHospitalNo: string;
    FreclnicOnly : Integer; // 0:모두 접수병원, 1:재진만 접수 병원
    FconfirmList : TObjectList;
    function GetconfirmList(AIndex: integer): TconfirmListItem;
    function GetCount: integer;
  protected
    { protected declarations }
    function AnalysisJson( AJsonRoot : TJSONObject ) : Integer; override;
  public
    { Public declarations }

    constructor Create( ABaseProtocol : TBridgeProtocol ); override;
    destructor Destroy; override;

    property HospitalNo : string read FHospitalNo;
    property reclnicOnly : integer read FreclnicOnly; // 재진만 접수 병원 option
    property Count : integer read GetCount;
    property confirmList[AIndex : integer] : TconfirmListItem read GetconfirmList;
  end;

  TBridgeRequest_111 = class( TBridgeRequest_Nomal )
  private
    { Private declarations }
    FconfirmResultList : TObjectList;
  protected
    { protected declarations }
    procedure AddResultJson( AResultJsonWriter : TGDJsonTextWriter ); override;
  public
    { Public declarations }
    HospitalNo : string;
    isFirst : Integer; // 0:신규환자 아님, 1:신규환자임.

    constructor Create( AEventID : integer; AJobID : String ); override;
    destructor Destroy; override;

    // add function 추가
    function Add( AchartReceptnResultId1 : string;
                  AchartReceptnResultId2 : string;
                  AchartReceptnResultId3 : string;
                  AchartReceptnResultId4 : string;
                  AchartReceptnResultId5 : string;
                  AchartReceptnResultId6 : string;
                  AreceptnResveId : string;
                  ADataRRType : Integer;   // 0:예약, 1:접수
                  AconfirmResult : Integer // 0:실패, 1:성공
                    ) : Integer;
  end;

// ================================================================================================
// 비연동(차트) → 굿닥, 환자 정보 수정
(*
  TBridgeRequest_400 = class( TBridgeRequest )
  private
    { Private declarations }
  protected
    { protected declarations }
    procedure ConvertJson( AJsonWriter : TGDJsonTextWriter ); override;
  public
    { Public declarations }
    HospitalNo : string;    // 요양기관 번호
    patntChartId : string;  // 환자 차트 ID
    oldName, newName : string; // 환자 기존 이름, 환자 신규 이름
    oldPhone, newPhone : string; // 환자 기존 전화번호, 환지 신규 전화 번호
    constructor Create( AEventID : integer; AJobID : String ); override;
  end;

  TBridgeResponse_401 = class( TBridgeResponse )
  private
    { Private declarations }
  protected
    { protected declarations }
    function AnalysisJson( AJsonRoot : TJSONObject ) : Integer; override;
  public
    { Public declarations }
    constructor Create( ABaseProtocol : TBridgeProtocol ); override;
    destructor Destroy; override;

    property patntChartId : string read FpatntChartId;  // 환자 차트 ID
    property newName : string read FnewName; // 환자 신규 이름
    property newPhone : string read FnewPhone; // 환자 신규 전화 번호
  end;
*)

// ================================================================================================
// 굿닥 → 차트, 예약 요청, ok
  TBridgeResponse_200 = class( TBridgeResponse )
  private
    { Private declarations }
    FPurposeList : TObjectList;
    FPatntChartId: string;
    FEtcPurpose: string;
    FAddrDetail: string;
    FBirthday: string;
    FZip: string;
    FHospitalNo: string;
    FRoomInfo : TRoomInfoRecord;
    FReserveDttm: TDateTime;
    FCellPhone: string;
    FRegistrationDttm: TDateTime;
    FRegNum: string;
    FAddr: string;
    FSexdstn: string;
    FInboundPath: string;
    FPatntName: string;
    function GetPurposeListCount: Integer;
    function GetPurposeLists(index: integer): TPurposeListItem;
  protected
    { protected declarations }
    function AnalysisJson( AJsonRoot : TJSONObject ) : Integer; override;
  public
    { Public declarations }
    constructor Create( ABaseProtocol : TBridgeProtocol ); override;
    destructor Destroy; override;

    property PurposeListCount : Integer read GetPurposeListCount;
    property PurposeLists[ index : integer ] : TPurposeListItem read GetPurposeLists;

    property HospitalNo : string read FHospitalNo;
    property PatntChartId : string read FPatntChartId;
    property PatntName : string read FPatntName;
    property RegNum : string read FRegNum;
    property CellPhone : string read FCellPhone;
    property Sexdstn : string read FSexdstn;
    property Birthday : string read FBirthday;
    property Addr : string read FAddr;
    property AddrDetail : string read FAddrDetail;
    property Zip : string read FZip;

    property InboundPath : string read FInboundPath;

    property RoomCode : string read FRoomInfo.RoomCode;
    property RoomName : string read FRoomInfo.RoomName;
    property DeptCode : string read FRoomInfo.DeptCode;
    property DeptName : string read FRoomInfo.DeptName;
    property DoctorCode : string read FRoomInfo.DoctorCode;
    property DoctorName : string read FRoomInfo.DoctorName;

    property ReserveDttm : TDateTime read FReserveDttm;
    property EtcPurpose : string read FEtcPurpose;
    property RegistrationDttm : TDateTime read FRegistrationDttm;
  end;

  TBridgeRequest_201 = class( TBridgeRequest_Nomal )
  private
    { Private declarations }
  protected
    { protected declarations }
    procedure ConvertJson( AJsonWriter : TGDJsonTextWriter ); override;
    procedure AddResultJson( AResultJsonWriter : TGDJsonTextWriter ); override;
  public
    { Public declarations }
    HospitalNo: string;
    PatntChartID: string;
    RegNum : string;
    RoomInfo : TRoomInfoRecord;
    chartReceptnResultId : TChartReceptnResultId;
  end;

// ================================================================================================
// 차트 → 굿닥 예약 취소 (접수 취소는 양방향이므로 양쪽 class를 모두 확인 해야 한다), ok
  TBridgeRequest_202 = class( TBridgeRequest )
  private
    { Private declarations }
  protected
    { protected declarations }
    procedure ConvertJson( AJsonWriter : TGDJsonTextWriter ); override;
  public
    { Public declarations }
    HospitalNo : string;
    CancelMessage : string;
    chartReceptnResultId : TChartReceptnResultId;
    RoomInfo : TRoomInfoRecord;
    receptStatusChangeDttm : TDateTime;
  end;

  TBridgeResponse_203 = class( TBridgeResponse )
  private
    { Private declarations }
  protected
    { protected declarations }
  public
    { Public declarations }
  end;

// ================================================================================================
// 굿닥 → 차트 예약 취소 (예약 취소는 양방향이므로 양쪽 class를 모두 확인 해야 한다), ok
  TBridgeResponse_202 = class( TBridgeResponse )
  private
    { Private declarations }
    FchartReceptnResultId : TChartReceptnResultId;
    FHospitalNo: string;
    FCancelMessage: string;
    FreceptStatusChangeDttm: TDateTime;
    FRoomInfo : TRoomInfoRecord;
  protected
    { protected declarations }
    function AnalysisJson( AJsonRoot : TJSONObject ) : Integer; override;
  public
    { Public declarations }
    property HospitalNo : string read FHospitalNo;
    property CancelMessage : string read FCancelMessage;

    property chartReceptnResultId : TChartReceptnResultId read FchartReceptnResultId;

    property RoomCode: string read FRoomInfo.RoomCode;
    property RoomName: string read FRoomInfo.RoomName;
    property DeptCode: string read FRoomInfo.DeptCode;
    property DeptName: string read FRoomInfo.DeptName;
    property DoctorCode: string read FRoomInfo.DoctorCode;
    property DoctorName: string read FRoomInfo.DoctorName;

    property receptStatusChangeDttm : TDateTime read FreceptStatusChangeDttm;
  end;

  TBridgeRequest_203 = class( TBridgeRequest_Nomal )
  private
    { Private declarations }
  protected
    { protected declarations }
  public
    { Public declarations }
  end;

// ================================================================================================
// 차트 → 굿닥 예약 시간 변경, ok
  TBridgeRequest_206 = class( TBridgeRequest )
  private
    { Private declarations }
  protected
    { protected declarations }
    procedure ConvertJson( AJsonWriter : TGDJsonTextWriter ); override;
  public
    { Public declarations }
    hospitalNo : string;
    chartReceptnResultId : TChartReceptnResultId;
    reserveDttm : TDateTime;
  end;

  TBridgeResponse_207 = class( TBridgeResponse )
  private
    { Private declarations }
  protected
    { protected declarations }
  public
    { Public declarations }
  end;

// ================================================================================================
// 차트 → 굿닥, 대기열 정보 전송, ok
    TRoomListItem = class
    public
      { Public declarations }
      RoomCode, RoomName : string;
      DeptCode, DeptName : string;
      DoctorCode, DoctorName : string;
    end;

  TBridgeRequest_300 = class( TBridgeRequest )
  private
    { Private declarations }
    FRoomList : TObjectList;
  protected
    { protected declarations }
    procedure ConvertJson( AJsonWriter : TGDJsonTextWriter ); override;
  public
    { Public declarations }
    HospitalNo : string;

    function AddRoomInfo( ARoomInfo : TRoomListItem ) : Integer;
    constructor Create( AEventID : integer; AJobID : String ); override;
    destructor Destroy; override;
  end;

  TBridgeResponse_301 = class( TBridgeResponse )
  private
    { Private declarations }
  protected
    { protected declarations }
  public
    { Public declarations }
  end;

// ================================================================================================
// 차트 → 굿닥, 취소 메시지 요청, ok
  TBridgeRequest_302 = class( TBridgeRequest )
  private
    { Private declarations }
  protected
    { protected declarations }
    procedure ConvertJson( AJsonWriter : TGDJsonTextWriter ); override;
  public
    { Public declarations }
    hospitalNo : string; // 요양기관 번호
  end;

    TCancelMsgListItem = class
    public
      { Public declarations }
      MessageStr : string;
      isDefault : Boolean;
    end;

  TBridgeResponse_303 = class( TBridgeResponse )
  private
    { Private declarations }
    FTotal: Integer;
    FCurrentLimit: Integer;
    FCurrentOffset: Integer;
    FList : TObjectList;
    function GetCancelMessageList(index: Integer): TCancelMsgListItem;
    function GetCancelMessageListCount: Integer;
  protected
    { protected declarations }
    function AnalysisJson( AJsonRoot : TJSONObject ) : Integer; override;
  public
    { Public declarations }
    constructor Create( ABaseProtocol : TBridgeProtocol ); override;
    destructor Destroy; override;

    property CancelMessageListCount : Integer read GetCancelMessageListCount;
    property CancelMessageList[ index : Integer ] : TCancelMsgListItem read GetCancelMessageList;

    property CurrentLimit : Integer read FCurrentLimit;
    property CurrentOffset : Integer read FCurrentOffset;
    property Total : Integer read FTotal;
  end;

// ================================================================================================
// 차트 → 굿닥, 미전송 접수/예약 리스트 요청
  TBridgeRequest_306 = class( TBridgeRequest )
  private
    { Private declarations }
  protected
    { protected declarations }
    procedure ConvertJson( AJsonWriter : TGDJsonTextWriter ); override;
  public
    { Public declarations }
    hospitalNo : string; // 요양기관 번호
    limit : Integer;     // 한번에 받아올 갯수
    offset : Integer;    // 시작 지점

    constructor Create( AEventID : integer; AJobID : String ); override;
  end;

  TData307 = class
  private
    { Private declarations }
    FPurposeList : TObjectList;

    function GetPurposeListCount: Integer;
    function GetPurposeLists(index: integer): TPurposeListItem;
  protected
    { protected declarations }
  public
    { Public declarations }
    chartReceptnResultId : TChartReceptnResultId;
    RoomInfo : TRoomInfoRecord;

    Addr: string;
    AddrDetail: string;
    Zip: string;

    Birthday: string;
    EndPoint: string; // 테블릿 T, 앱 A
    EventID : Integer; // 접수:100, 예약:200, 접수취소:102, 예약취소:202
    HospitalNO: string;

    PatntName: string;
    PatntChartID: string;
    cellphone: string;
    ReceptionDttm: TDateTime;

    receptnResveId : string; // 굿닥 접수 아이디

    ReserveDttm : TDateTime; // 예약 일시

    regNum: string;
    Sexdstn: string;

    InboundPath: string;
    EtcPurpose: string;
    Gdid : string;

    constructor Create; virtual;
    destructor Destroy; override;

    function AnalysisJson( AJsonRoot : TJSONObject ) : Integer;

    property PurposeListCount : Integer read GetPurposeListCount;
    property PurposeLists[ index : integer ] : TPurposeListItem read GetPurposeLists;
  end;

  TBridgeResponse_307 = class( TBridgeResponse )
  private
    { Private declarations }
    FTotal: Integer;
    FCurrentLimit: Integer;
    FCurrentOffset: Integer;
    FList : TObjectList;
    function GetDataList(index: Integer): TData307;
    function GetDataListCount: Integer;
  protected
    { protected declarations }
    function AnalysisJson( AJsonRoot : TJSONObject ) : Integer; override;
  public
    { Public declarations }
    constructor Create( ABaseProtocol : TBridgeProtocol ); override;
    destructor Destroy; override;

    property DataListCount : Integer read GetDataListCount;
    property DataList[ index : Integer ] : TData307 read GetDataList;

    property CurrentLimit : Integer read FCurrentLimit;
    property CurrentOffset : Integer read FCurrentOffset;
    property Total : Integer read FTotal;
  end;


// ================================================================================================
// 차트 → 굿닥, 미전송 접수/예약 리스트 요청
  TreceiveOkListItem = class( TconfirmListItem )
  public
    patntChartId : string;
  end;

  TBridgeRequest_308 = class( TBridgeRequest )
  private
    { Private declarations }
    FreceiveOkList : TObjectList;
  protected
    { protected declarations }
    procedure ConvertJson( AJsonWriter : TGDJsonTextWriter ); override;
  public
    { Public declarations }
    hospitalNo : string; // 요양기관 번호

    constructor Create( AEventID : integer; AJobID : String ); override;
    destructor Destroy; override;

    // add function 추가
    function Add( AchartReceptnResultId1 : string;
                  AchartReceptnResultId2 : string;
                  AchartReceptnResultId3 : string;
                  AchartReceptnResultId4 : string;
                  AchartReceptnResultId5 : string;
                  AchartReceptnResultId6 : string;
                  AreceptnResveId : string;
                  APatntChartID : string
                    ) : Integer;
  end;

  TBridgeResponse_309 = class( TBridgeResponse )
  private
    { Private declarations }
  protected
    { protected declarations }
  public
    { Public declarations }
  end;


// ================================================================================================
// 비연동(차트) → 굿닥, 대기열 정보 요청
  TBridgeRequest_400 = class( TBridgeRequest )
  private
    { Private declarations }
  protected
    { protected declarations }
    procedure ConvertJson( AJsonWriter : TGDJsonTextWriter ); override;
  public
    { Public declarations }
    HospitalNo : string;
    StartDttm : TDateTime;
    EndDttm : TDateTime;
    LastChangeDttm : TDateTime;
    ReceptnResveType : string;
    Limit : Integer; // 페이지 당 갯수
    Offset : Integer;  // 전체 중 몇번째 부터 인지 위치값
    constructor Create( AEventID : integer; AJobID : String ); override;
  end;

    TReceptionReservationListItem = class
    private
      { private declarations }
      function GetisMale: Boolean;
    public
      { Public declarations }
      PatntChartId, PatntName : string;
      PatntId : string; // V4에서는 PatntChartId 대신 PatntId를 사용
      chartReceptnResultId : TChartReceptnResultId;
      Cellphone, RegNum, Birthdy, Sexdstn, Addr, AddrDetail, Zip : string;
      InboundPath, Symptoms : string;
      RoomInfo : TRoomInfoRecord;
      Status : string;
      DeviceType, memo : string;
      CancelMessage : string;
      LastChangeDttm, ReceptionDttm, reserveDttm, CancelDttm : TDateTime;
      ReceptnResveType : string;
      (*
        병원 접수 일시(2019-05-15T13:30:00.000Z)
        취소 상태구분 할때 사용함
          병원접수일시 값이 있다면, 확정 후 취소
          병원접수일시 값이 없다면, 요청 후 취소
      *)
      hsptlReceptnDttm : TDateTime;
      isFirst : Boolean;

      property isMale : Boolean read GetisMale;
    end;

  TBridgeResponse_401 = class( TBridgeResponse )
  private
    { Private declarations }
    FRRList : TObjectList;
    FCurrentLimit: Integer;
    FCurrentOffset: Integer;
    FTotalDataCount: integer;
    function GetReceptionReservationLists(
      index: Integer): TReceptionReservationListItem;
    function GetReceptionReservationCount: Integer;
  protected
    { protected declarations }
    function AnalysisJson( AJsonRoot : TJSONObject ) : Integer; override;
  public
    { Public declarations }
    constructor Create( ABaseProtocol : TBridgeProtocol ); override;
    destructor Destroy; override;

    property CurrentLimit : Integer read FCurrentLimit;
    property CurrentOffset : Integer read FCurrentOffset;
    property TotalDataCount : integer read FTotalDataCount;

    property ReceptionReservationCount : Integer read GetReceptionReservationCount;
    property ReceptionReservationLists[ index : Integer ] : TReceptionReservationListItem read GetReceptionReservationLists;
  end;

// ================================================================================================
// 차트(비연동) → 굿닥, 대기열 정보 전송, ok
  TBridgeRequest_402 = class( TBridgeRequest )
  private
    { Private declarations }
  protected
    { protected declarations }
    procedure ConvertJson( AJsonWriter : TGDJsonTextWriter ); override;
  public
    { Public declarations }
    HospitalNo : string;
  end;

  TBridgeResponse_403 = class( TBridgeResponse )
  private
    { Private declarations }
    FTotal: Integer;
    FCurrentLimit: Integer;
    FCurrentOffset: Integer;
    FRoomList : TObjectList;
    function GetRoomListCount: Integer;
    function GetRoomLists(index: Integer): TRoomListItem;
  protected
    { protected declarations }
    function AnalysisJson( AJsonRoot : TJSONObject ) : Integer; override;
  public
    { Public declarations }
    constructor Create( ABaseProtocol : TBridgeProtocol ); override;
    destructor Destroy; override;

    property RoomListCount : Integer read GetRoomListCount;
    property RoomLists[ index : Integer ] : TRoomListItem read GetRoomLists;

    property CurrentLimit : Integer read FCurrentLimit;
    property CurrentOffset : Integer read FCurrentOffset;
    property Total : Integer read FTotal;
  end;

// ================================================================================================
// 차트(비연동) → 굿닥, 환자 정보 수정, ok
  TBridgeRequest_404 = class( TBridgeRequest )
  private
    { Private declarations }
  protected
    { protected declarations }
    procedure ConvertJson( AJsonWriter : TGDJsonTextWriter ); override;
  public
    { Public declarations }
    HospitalNo : string;
    patntChartId : string; // 환자 차트 ID
    patntId : string; // V4. 환자ID.
    oldName, newName : string;  // 이름
    oldPhone, newPhone : string; // 전화 번호
  end;

  TBridgeResponse_405 = class( TBridgeResponse )
  private
    { Private declarations }
    FnewName: string;
    FpatntChartId: string;
    FnewPhone: string;
  protected
    { protected declarations }
    function AnalysisJson( AJsonRoot : TJSONObject ) : Integer; override;
  public
    { Public declarations }
    constructor Create( ABaseProtocol : TBridgeProtocol ); override;
    destructor Destroy; override;

    property patntChartId : string read FpatntChartId;
    property newName : string read FnewName;
    property newPhone : string read FnewPhone;
  end;

// ================================================================================================
// 비연동(차트) → 굿닥, 개별접수예약목록 요청
  TBridgeRequest_406 = class( TBridgeRequest )
  private
    { Private declarations }
  protected
    { protected declarations }
    procedure ConvertJson( AJsonWriter : TGDJsonTextWriter ); override;
  public
    { Public declarations }
    chartReceptnResultId : TChartReceptnResultId;
    constructor Create( AEventID : integer; AJobID : String ); override;
  end;

  TBridgeResponse_407 = class( TBridgeResponse )
  private
    { Private declarations }
    FRRList : TObjectList;
    function GetReceptionReservationItem: TReceptionReservationListItem;
  protected
    { protected declarations }
    function AnalysisJson( AJsonRoot : TJSONObject ) : Integer; override;
  public
    { Public declarations }
    constructor Create( ABaseProtocol : TBridgeProtocol ); override;
    destructor Destroy; override;

    property ReceptionReservationItem : TReceptionReservationListItem read GetReceptionReservationItem;
  end;

// ================================================================================================
// 차트(비연동) → 굿닥, 환자 주민등록번호 가져오기
  TBridgeRequest_410 = class( TBridgeRequest )
  private
    { Private declarations }
  protected
    { protected declarations }
    procedure ConvertJson( AJsonWriter : TGDJsonTextWriter ); override;
  public
    { public declarations }
    patntId : string;
  end;

  TBridgeResponse_411 = class( TBridgeResponse )
  private
    { private declarations }
    FRegNum : string;
  protected
    { protected declarations }
    function AnalysisJson( AJsonRoot : TJSONObject ) : Integer; override;
  public
    { public declarations }
    constructor Create( ABaseProtocol : TBridgeProtocol ); override;
    destructor Destroy; override;

    property regNum : string read FRegNum;
  end;

// ================================================================================================
// 굿닥 → 차트(비연동), 접수목록업데이트 알림
  TBridgeResponse_420 = class( TBridgeResponse )
  private
    { private declarations }
    FchartReceptnResultId : TChartReceptnResultId;
  protected
    { protected declarations }
    function AnalysisJson( AJsonRoot : TJSONObject ) : Integer; override;
  public
    { public declarations }
    property chartReceptnResultId : TChartReceptnResultId read FchartReceptnResultId;

    constructor Create( ABaseProtocol : TBridgeProtocol ); override;
    destructor Destroy; override;
  end;

  TBridgeRequest_421 = class( TBridgeRequest_Nomal )
  private
    { Private declarations }
  protected
    { protected declarations }
    procedure ConvertJson( AJsonWriter : TGDJsonTextWriter ); override;
  public
    { public declarations }
  end;

// ================================================================================================
// 차트 → 굿닥, 예약 스케쥴 공유, ok
// #V3-171
  TReservationScheduleDto = class
  public
    { public declarations }
    kst_schedule : string;
    used: boolean;
  end;

  TBridgeRequest_2006 = class( TBridgeRequest )
  private
    { private declarations }
    FRoomCode : string;
    FDeptCode : string;
    FItems : TObjectList;
    function GetItem(index: integer): TReservationScheduleDto;
    function GetItemCount: integer;
  protected
    { protected declarations }
    procedure ConvertJson( AJsonWriter : TGDJsonTextWriter ); override;
  public
    { public declarations }
    property RoomCode : string read FRoomCode write FRoomCode;
    property DeptCode : string read FDeptCode write FDeptCode;
    property Item[index:integer] : TReservationScheduleDto read GetItem;
    property ItemCount : integer read GetItemCount;

    constructor Create( AEventID : integer; AJobID : string); override;
    destructor Destroy; override;

    procedure AddItem(datetime : string; reserved : boolean);
  end;

  TBridgeResponse_2007 = class( TBridgeResponse )
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
  end;

// ================================================================================================
// 통신 object 생성
  TBridgeFactory = class
  private
    { Private declarations }
  protected
    { protected declarations }
    function MakeResponseObj( ABaseObject : TBridgeProtocol ): TBridgeResponse; overload; virtual;
  public
    { Public declarations }
    function MakeRequestObj( AEventID : Integer; AJobID: string = '' ) : TBridgeRequest;  virtual;

    function MakeResponseObj( AJsonStr : string ) : TBridgeResponse; overload;
    function MakeResponseObj( AEventID : Integer; AJobID : string ) : TBridgeResponse; overload; virtual;

    function GetErrorString( AErrorNum : Integer ) : string; virtual;
  end;

const // event id
  EventID_환자조회                = 0;   // 굿닥->차트
  EventID_환자조회결과            = 1;   // 차트->굿닥
  EventID_접수요청                = 100; // 양방향
  EventID_접수요청결과            = 101; // 양방향
  EventID_접수취소                = 102; // 양방향
  EventID_접수취소결과            = 103; // 양방향
  EventID_대기순번변경            = 104;
  EventID_대기순번변경결과        = 105;
  EventID_대기열변경              = 106;
  EventID_대기열변경결과          = 107;
  EventID_대기열상태값변경        = 108;
  EventID_대기열상태값변경결과    = 109;
  EventID_내원확인요청            = 110; // 굿닥->차트
  EventID_내원확인요청결과        = 111;
  EventID_예약요청                = 200; // 굿닥->차트
  EventID_예약요청결과            = 201; // 차트->굿닥
  EventID_예약취소                = 202; // 양방향
  EventID_예약취소결과            = 203; // 양방향
  EventID_예약요청시간변경        = 206; // 차트->굿닥
  EventID_예약요청시간변경결과    = 207; // 굿닥->차트
  EventID_대기열목록전송          = 300; // 차트->굿닥
  EventID_대기열목록전송결과      = 301;
  EventID_취소메시지목록요청      = 302; // 차트->굿닥
  EventID_취소메시지목록요청결과  = 303;

  EventID_미전송목록요청          = 306; // 차트->굿닥
  EventID_미전송목록요청결과      = 307;
  EventID_미전송목록요청결과전송  = 308; // 차트->굿닥
  EventID_미전송목록요청결과전송결과  = 309;

  EventID_접수예약목록요청        = 400; // 차트(미연동)->굿닥
  EventID_접수예약목록요청결과    = 401;
  EventID_대기열목록요청          = 402; // 차트(미연동)->굿닥
  EventID_대기열목록요청결과      = 403;
  EventID_환자정보수정요청        = 404; // 차트(미연동)->굿닥
  EventID_환자정보수정요청결과    = 405;
  EventID_접수예약목록건별요청    = 406;
  EventID_접수예약목록건별요청결과= 407;
  EventID_환자주민번호요청        = 410;
  EventID_환자주민번호요청결과    = 411;
  EventID_접수목록변경알림        = 420;
  EventID_접수목록변경알림결과    = 421;

  EventID_예약스케쥴공유요청      = 2006; // 차트->굿닥 #V3-171
  EventID_예약스케쥴공유요청결과  = 2007;

  EventID_시스템Error             = 9999; // 시스템 error시 발생
  EventID_시스템Error2            = 1000; // 임시

const // 접수/예약 상태 코드
  Status_예약요청 = 'S01';
  Status_예약실패 = 'S02'; // 예약 요청 data를 예약 완료 전 취소를 하면 실패로 본다.
  Status_예약완료 = 'S03';
  Status_접수요청 = 'C01';
  Status_접수실패 = 'C02'; // 접수 요청 data를 접수 완료 전 취소를 하면 실패로 본다.
  Status_접수완료 = 'C03';
  Status_진료대기 = 'C04';
  Status_내원요청 = 'C05';
  Status_내원확정 = 'C06';
  Status_진료차례 = 'C07'; // 대기 순번 1번
  Status_진료중   = 'C08';
  Status_취소요청 = 'F01'; // 확정 이후
  Status_본인취소 = 'F02'; // 확정 이후
  Status_병원취소 = 'F03'; // 확정 이후
  Status_자동취소 = 'F04'; // 확정 이후
  Status_진료완료 = 'F05';

const // receptnResveType
  RRType_ALL    = ''; // 접수 + 예약
  RRType_Reception    = 'C'; // 접수
  RRType_Reservation  = 'S'; // 예약

const // 유입 기기 구분
  InDeviceType_Tablet    = 'T'; // tablet
  InDeviceType_Bridge    = 'B'; // Bridge
  InDeviceType_App       = 'A'; // app

(*  차트 에러 코드
200     정상
1       이미 등록된 환자
2       환자를 찾을수 없음
3       필수 정보가 누락
4       데이터 포멧 오류
5       접수 번호를 찾을 수 없음
6       이미 동일 대기실에 등록된 환자
100~199 사용자 정의 에러
*)
const
  Result_SuccessCode    = 200;
  Result_Success        = 200;
  Result_중복된환자     = 1;
  Result_중복된환자_Msg = '이미 등록된 환자 입니다.';
  Result_필수항목누락   = 3;
  Result_필수항목누락_Msg   = '필수 항목이 누락되어 있습니다.';
  Result_접수번호없음   = 5;
  Result_접수번호없음_Msg   = '접수 번호를 찾을 수 없습니다.';
  Result_접수중복       = 6;
  Result_접수중복_Msg   = '동일 진료실에 등록되어 있는 환자 입니다.';
  Result_NotDefineEvent = 11; // 정의되지 않은 형태의 이벤트 입니다
  Result_NotDefineEvent_Msg = '정의되지 않은 형태의 이벤트 입니다.';
  Result_NoRelation_NotDefineEvent_old = 30; // 비연동에서 지원하지 않는 이벤트 ID 입니다.
  Result_NoRelation_NotDefineEvent_Msg_old = '비연동 접수/예약 프로그램에서는 지원하지 않는 이벤트 ID 입니다.';

  Result_NoRelation_NotDefineEvent = 730; // 비연동에서 지원하지 않는 이벤트 ID 입니다.
  Result_NoRelation_NotDefineEvent_Msg = '환경 설정 변경이 필요합니다. 굿닥에 문의해주세요.';

  Result_NoRelation_NotDefineEvent_hook = 830; // 비연동에서 지원하지 않는 이벤트 ID 입니다.
  Result_NoRelation_NotDefineEvent_Msg_hook = '차트 DB 접근에 실패 했습니다. 굿닥에 문의해주세요.';

  Result_NoData         = 901;
  Result_NoData_Msg     = '지정된 Data가 없습니다.';

  Result_DLLNotLoaded     = 998;
  Result_DLLNotLoaded_Msg = '브릿지 DLL이 적제 되지 못했다.';
  Result_ExceptionError = 999;
  Result_ExceptionError_Msg = '알수 없는 시스템 Error가 발생하였습니다.';

const // json field name
  FN_EventID          = 'eventId';
  FN_JobID            = 'jobId';
  FN_Code             = 'code';
  FN_Message          = 'message';
  FN_Message2         = 'mssage';
  FN_isChoice         = 'isChoice';
  FN_Select           = 'select';
  FN_Default          = 'default';
  FN_Result           = 'result';
  FN_patntList        = 'patntList'; // 검색 list
  FN_PurposeList      = 'comPurposeList'; // 내원 목적 list
      FN_Purpose1     = 'purpose1';
      FN_Purpose2     = 'purpose2';
      FN_Purpose3     = 'purpose3';
  FN_Purpose          = 'symptoms'; // 내원 목적

  FN_ReceptnList      = 'patntReceptnList';
  FN_List             = 'list';
  FN_HospitalNo       = 'hospitalNo'; // 요양기관번호

  FN_PatntId          = 'patientId'; // V4. 환자ID
  FN_PatntChartId     = 'patntChartId'; // 차트 번호
  FN_PatntName        = 'name'; // 환자 이음
  FN_CellPhone        = 'cellphone'; // 휴대 전화 번호
  FN_RegNum           = 'regNum'; // 주민 번호
  FN_Sexdstn          = 'sexdstn'; // 성별, 13579남자, 24680여자
  FN_Birthday         = 'brthdy'; // 생년월일, yyyymmdd

  FN_Addr             = 'addr'; //주소
  FN_AddrDetail       = 'addrDetail'; // 주소 상세
  FN_Zip             = 'zip'; // 우편번호
  FN_EndPoint         = 'endpoint'; // 테블릿/앱 여부(T:테블릿, A:앱)
  FN_InboundPath      = 'path'; // 내원 경로
  FN_InboundPath2     = 'visitPath'; // 내원 경로
  FN_RoomCode         = 'roomCode'; // 진료실 코드
  FN_RoomName         = 'roomNm'; // 진료실 명
  FN_DeptCode         = 'deptCode'; // 과목코드
  FN_DeptName         = 'deptNm'; // 과목명
  FN_DoctorCode       = 'doctrCode'; // 담당의코드
  FN_DoctorName       = 'doctrNm'; // 담당의이름
  FN_EtcPurpose       = 'etcPurpose'; // 기타 내원 목적

  FN_ReceptionDttm    = 'receptnDttm'; // 접수 일시
  FN_RoomChangeDttm   = 'roomChangeDttm'; // 대기열 변경 일시
  FN_Status           = 'status'; // 상태정보
//  FN_ReserveDate      = 'reserveDate'; // 예약일(yyyymmdd)
//  FN_ReserveTime      = 'reserveTime'; // 예약시간(hh:mm)
  FN_ReserveDttm      = 'reserveDttm'; // 예약 일시

  FN_StartDttm        = 'startDttm';
  FN_EndDttm          = 'endDttm';
  FN_LastChangeDttm   = 'changeDttm';
  FN_ReceptnResveType = 'receptnResveType';
  FN_MaxPageCount     = 'take'; // V4. 기존 'limit';
  FN_DataOffset       = 'skip'; // V4. 기존 'offset';
  FN_Contents         = 'contents';
  FN_CurrentLimit     = 'currentLimit';
  FN_CurrentOffset    = 'currentOffset';
  FN_TotalCount       = 'total';
  FN_DeviceType       = 'deviceType';
  FN_Memo             = 'memo';
  FN_CancelMessage    = 'canclMssage';
  FN_hsptlReceptnDttm = 'hsptlReceptnDttm';

  FN_ConfirmList      = 'confirmList';
  FN_ConfirmResultList  = 'confirmResultList';
  FN_receiveOkList    = 'receiveOkList';
  FN_ConfirmResult    = 'confirmResult';
  FN_receptnResveId   = 'receptnResveId';
  FN_reclnicOnly      = 'reclnicOnly'; // 재진만 접수 option
  FN_isFirst          = 'isFirst'; // 신규환자 여부
  FN_oldName          = 'oldName';
  FN_newName          = 'newName';
  FN_oldPhone         = 'oldPhone';
  FN_newPhone         = 'newPhone';

  FN_receptStatusChangeDttm        = 'receptStatusChangeDttm';  // 변경 시간

  FN_ChartReceptnResultId1        = 'chartReceptnResultId1'; // 접수 아이디1
  FN_ChartReceptnResultId2        = 'chartReceptnResultId2'; // 접수 아이디2
  FN_ChartReceptnResultId3        = 'chartReceptnResultId3'; // 접수 아이디3
  FN_ChartReceptnResultId4        = 'chartReceptnResultId4'; // 접수 아이디4
  FN_ChartReceptnResultId5        = 'chartReceptnResultId5'; // 접수 아이디5
  FN_ChartReceptnResultId6        = 'chartReceptnResultId6'; // 접수 아이디6

(*   test
  FN_NewchartReceptnResultId1     = 'newchartReceptnResultId1'; // 신규 접수 아이디1
  FN_NewchartReceptnResultId2     = 'newchartReceptnResultId2'; // 신규 접수 아이디2
  FN_NewchartReceptnResultId3     = 'newchartReceptnResultId3'; // 신규 접수 아이디3
  FN_NewchartReceptnResultId4     = 'newchartReceptnResultId4'; // 신규 접수 아이디4
  FN_NewchartReceptnResultId5     = 'newchartReceptnResultId5'; // 신규 접수 아이디5
  FN_NewchartReceptnResultId6     = 'newchartReceptnResultId6'; // 신규 접수 아이디6 *)
  FN_NewchartReceptnResultId1     = 'newChartReceptnResultId1'; // 신규 접수 아이디1
  FN_NewchartReceptnResultId2     = 'newChartReceptnResultId2'; // 신규 접수 아이디2
  FN_NewchartReceptnResultId3     = 'newChartReceptnResultId3'; // 신규 접수 아이디3
  FN_NewchartReceptnResultId4     = 'newChartReceptnResultId4'; // 신규 접수 아이디4
  FN_NewchartReceptnResultId5     = 'newChartReceptnResultId5'; // 신규 접수 아이디5
  FN_NewchartReceptnResultId6     = 'newChartReceptnResultId6'; // 신규 접수 아이디6

  FN_ReceptionUpdateDto           = 'receptionUpdateDto';
// ======= 미정
  FN_Auth_ID  = 'id';
  FN_Auth_PW  = 'pw';
  FN_Auth_Action  = 'action';
  FN_Auth_Token = 'token';
// ======= 미정

// ======= 전자 차트 관련 추가 field
  FN_prescription           = 'prescription';
  FN_hipass                 = 'hipass';
  FN_ePrescriptionHospital  = 'ePrescriptionHospital';
  FN_gdid                   = 'gdid';
  FN_parmNo                 = 'parmNo';
  FN_parmNm                 = 'parmNm';
  FN_extraInfo              = 'extraInfo';
  FN_ePrescriptionPatient   = 'ePrescriptionPatient';
// =======

// ======= 예약스케쥴공유 추가 field
  FN_reservationScheduleItemList        = 'items';
  FN_reservationScheduleDateTimeFormat  = 'kst_schedule';
  FN_reservationScheduleReserved        = 'used';
// =======


// 통신에 사용되는 jobid를 생성 한다.
function MakeJobID : string;

// "yyyy-mm-ddThh:nn:ss.zzzZ"형식으로 만들어 준다.
function MakeDateTime2DttmStr( ADateTime : TDateTime ) : string;
// "yyyy-mm-ddThh:nn:ss.zzzZ"형식의 날자를 tdatetime형식으로 만들어 준다.
function MakeDttmStr2DateTime( ADttmStr : string ) : TDateTime;

// 상태코드가 진료 대기 상태인지 확인 한다. C04, C05, C06, C07은 진료 대기 상태이다.
function CheckTreatmentWait( AStatus : string ) : Boolean;

function GetBridgeFactory : TBridgeFactory;

implementation
uses
  math, System.StrUtils, UtilsUnit
{$ifdef _Emulation_}
  {$ifdef _EP_} , EPBridgeCommUnit {$endif}
{$endif};
var
  GBridgeFactory : TBridgeFactory;

function GetBridgeFactory : TBridgeFactory;
begin
  if not Assigned( GBridgeFactory ) then
{$ifdef _Emulation_}
  {$ifdef _EP_}
      GBridgeFactory := TepBridgeFactory.Create;
  {$else}
      GBridgeFactory := TBridgeFactory.Create;
  {$endif}
{$else}
    GBridgeFactory := TBridgeFactory.Create;
{$endif}

  Result := GBridgeFactory;
end;


function CheckTreatmentWait( AStatus : string ) : Boolean;
begin
(*
  Status_진료대기 = 'C04';
  Status_내원요청 = 'C05';
  Status_내원확정 = 'C06';
  Status_진료차례 = 'C07'; // 대기 순번 1번 *)

  Result := MatchText(AStatus, ['C04', 'C05', 'C06', 'C07']);
end;

function MakeJobID : string;
var
  g : TGUID;
begin
  CreateGUID( g );
  // Result := GUIDToString( g );
  Result := Format( '%.8x%.4x%.4x%.2x%.2x%.2x%.2x%.2x%.2x%.2x%.2x', [g.D1, g.D2, g.D3, g.D4[0], g.D4[1], g.D4[2], g.D4[3], g.D4[4], g.D4[5], g.D4[6], g.D4[7]]);
end;

// GMT-0로 만든 후 "yyyy-mm-ddThh:nn:ss.zzzZ"형식으로 만들어 준다.
function MakeDateTime2DttmStr( ADateTime : TDateTime ) : string;
begin
  Result := '';
  if ADateTime <> 0 then   //
    Result := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss.zzz"Z"', GetLocalTimetoGMT( ADateTime ));
end;

// "yyyy-mm-ddThh:nn:ss.zzzZ"형식의 날자를 tdatetime형식으로 만들어 준다.
function MakeDttmStr2DateTime( ADttmStr : string ) : TDateTime;
var
  d : TDateTime;
begin
  d := StrToDateTimeDef(  ADttmStr, 0 );
  if d <> 0 then
    Result := GetGMTtoLocalTime( d )
  else
    Result := 0;
end;

{ TBridgeProtocol }

constructor TBridgeProtocol.Create(AEventID: integer; AJobID: String);
begin
  FJsonRoot := nil;
  FEventID := AEventID;
  FJobID := AJobID;
end;

function TBridgeProtocol.CheckNecessaryField: Boolean;
begin
  Result := (FEventID >= 0) and (FJobID <> '');
end;

constructor TBridgeProtocol.Create(AJsonRoot: TJSONObject);
begin
  FJsonRoot := AJsonRoot;
  FEventID := GetValueIntegerGDJson(FJsonRoot, FN_EventID, -1);
  FJobID := GetValueStringGDJson(FJsonRoot, FN_JobID);
end;

destructor TBridgeProtocol.Destroy;
begin
  if Assigned( FJsonRoot ) then
    FreeAndNil( FJsonRoot );
  inherited;
end;

{ TBridgeRequest }

procedure TBridgeRequest.ConvertJson(AJsonWriter: TGDJsonTextWriter);
begin
  AJsonWriter.WriteValue(FN_EventID, FBase.EventID);
  AJsonWriter.WriteValue(FN_JobID, FBase.JobID);
end;

constructor TBridgeRequest.Create(AEventID: integer; AJobID: String);
begin
  FBase := TBridgeProtocol.Create( AEventID, AJobID );
end;

destructor TBridgeRequest.Destroy;
begin
  FreeAndNil( FBase );
  inherited;
end;

function TBridgeRequest.GetEventID: Integer;
begin
  Result := FBase.EventID;
end;

function TBridgeRequest.GetJobID: string;
begin
  Result := FBase.JobID;
end;

procedure TBridgeRequest.Save(AFileName: string);
var
  utf8str : UTF8String;
  mm : TMemoryStream;
begin
  mm := TMemoryStream.Create;
  try
    utf8str := UTF8String( ToJsonString );
    mm.WriteBuffer(utf8str[1], Length(utf8str) );
    mm.SaveToFile( AFileName );
  finally
    FreeAndNil( mm );
  end;
end;

function TBridgeRequest.ToJsonString: string;
var
  jsonwriter : TGDJsonTextWriter;
begin
  jsonwriter := TGDJsonTextWriter.Create;
  try
    jsonwriter.StartObject;
    try
      ConvertJson( jsonwriter );
    finally
      jsonwriter.EndObject;
    end;
    Result := jsonwriter.ToJsonString;
  finally
    FreeAndNil( jsonwriter );
  end;
end;

{ TBridgeResponse }

function TBridgeResponse.Analysis: Integer;
begin
  FAnalysisErrorCode := AnalysisJson( FBase.FJsonRoot );
  Result := FAnalysisErrorCode;
end;

function TBridgeResponse.AnalysisJson(AJsonRoot: TJSONObject) : Integer;
begin
  Result := Result_Success;

  if ExistObjectGDJson( AJsonRoot, FN_Code ) then
    FCode := GetValueIntegerGDJson(AJsonRoot, FN_Code)
  else
    Result := Result_필수항목누락;

  if ExistObjectGDJson( AJsonRoot, FN_Message ) then
    FMessage := GetValueStringGDJson(AJsonRoot, FN_Message)
  else
    Result := Result_필수항목누락;

  if Result = Result_Success then
  begin // 필수 data 확인
    if (FN_Code = '') or (FN_Message = '' ) then
        Result := Result_필수항목누락;
  end;
end;

constructor TBridgeResponse.Create(ABaseProtocol: TBridgeProtocol);
begin
  FBase := ABaseProtocol;
  FAnalysisErrorCode := Result_Success;
  FCode := Result_Success;
  FMessage := '';
end;

destructor TBridgeResponse.Destroy;
begin
  if Assigned( FBase ) then
    FreeAndNil( FBase );

  inherited;
end;

function TBridgeResponse.GetEventID: Integer;
begin
  Result := FBase.EventID;
end;

function TBridgeResponse.GetJobID: string;
begin
  Result := FBase.JobID;
end;


{ TBridgeRequest_100 }

procedure TBridgeRequest_100.ConvertJson(AJsonWriter: TGDJsonTextWriter);
begin
  inherited ConvertJson(AJsonWriter);

  with AJsonWriter do
  begin
    WriteValue(FN_HospitalNo, hospitalNo);
    WriteValue(FN_PatntChartId, PatntChartId);
    { 차트에서 굿닥으로 전송되는 접수는 모두 더미로 처리 합니다.
    WriteValue(FN_CellPhone, CellPhone);
    WriteValue(FN_RegNum, RegNum);
    WriteValue(FN_PatntName, PatntName);}
    WriteValue(FN_Sexdstn, Sexdstn);
    WriteValue(FN_Birthday, Birthday);
    WriteValue(FN_Addr, addr);
    WriteValue(FN_AddrDetail, addrDetail);
    WriteValue(FN_Zip, Zip);
    WriteValue(FN_RoomCode, RoomInfo.RoomCode);
    WriteValue(FN_RoomName, RoomInfo.RoomName);
    WriteValue(FN_DeptCode, RoomInfo.DeptCode);
    WriteValue(FN_DeptName, RoomInfo.DeptName);
    WriteValue(FN_doctorCode, RoomInfo.DoctorCode);
    WriteValue(FN_doctorName, RoomInfo.DoctorName);

    WriteValue(FN_chartReceptnResultId1, chartReceptnResultId.Id1);
    WriteValue(FN_chartReceptnResultId2, chartReceptnResultId.Id2);
    WriteValue(FN_chartReceptnResultId3, chartReceptnResultId.Id3);
    WriteValue(FN_chartReceptnResultId4, chartReceptnResultId.Id4);
    WriteValue(FN_chartReceptnResultId5, chartReceptnResultId.Id5);
    WriteValue(FN_chartReceptnResultId6, chartReceptnResultId.Id6);

    WriteValue(FN_ReceptionDttm, MakeDateTime2DttmStr( ReceptionDttm ) );

    WriteValue(FN_gdid, gdid);
    WriteValue(FN_isFirst, false);
    WriteValue(FN_ePrescriptionHospital, ePrescriptionHospital);
  end;
end;

constructor TBridgeRequest_100.Create(AEventID: integer; AJobID: String);
begin
  inherited;
  gdid := '';
  ePrescriptionHospital := 0; // 전자처방전 환자 여부(0:미사용,1:사용)
end;

destructor TBridgeRequest_100.Destroy;
begin
  inherited;
end;

{ TBridgeResponse_101 }


{ TBridgeResponse_100 }

function TBridgeResponse_100.AnalysisJson(AJsonRoot: TJSONObject): Integer;
var
  i : Integer;
  ResultJson, datajson : TJSONObject;
  purposelistjson : TJSONArray;
  item : TPurposeListItem;
begin
  inherited AnalysisJson( AJsonRoot );
  Result := Result_Success;
  ResultJson := AJsonRoot;

  if ExistObjectGDJson( ResultJson, FN_HospitalNo ) then
    FHospitalNO := GetValueStringGDJson(ResultJson, FN_HospitalNo) else Result := Result_필수항목누락;
  if ExistObjectGDJson( ResultJson, FN_PatntChartId ) then
    FPatntChartId := GetValueStringGDJson(ResultJson, FN_PatntChartId)
  else
    FPatntChartId := '';

  Fgdid := GetValueStringGDJson(AJsonRoot, FN_gdid);

  if ExistObjectGDJson( ResultJson, FN_PatntName ) then
    FPatntName := GetValueStringGDJson(ResultJson, FN_PatntName) else Result := Result_필수항목누락;
  if ExistObjectGDJson( ResultJson, FN_CellPhone ) then
    Fcellphone := GetValueStringGDJson(ResultJson, FN_CellPhone) else Result := Result_필수항목누락;
  if ExistObjectGDJson( ResultJson, FN_EndPoint ) then
    FEndPoint := GetValueStringGDJson(ResultJson, FN_EndPoint) else Result := Result_필수항목누락;

  if ExistObjectGDJson( ResultJson, FN_RegNum ) then
    FregNum := GetValueStringGDJson(ResultJson, FN_RegNum) else Result := Result_필수항목누락;
  FSexdstn := GetValueStringGDJson(ResultJson, FN_Sexdstn);
  FBirthday := GetValueStringGDJson(ResultJson, FN_Birthday);
  FAddr := GetValueStringGDJson(ResultJson, FN_Addr);
  FAddrDetail := GetValueStringGDJson(ResultJson, FN_AddrDetail);
  FZip := GetValueStringGDJson(ResultJson, FN_Zip);

  if ExistObjectGDJson( ResultJson, FN_RoomCode ) then
    FRoomInfo.RoomCode := GetValueStringGDJson(ResultJson, FN_RoomCode) else Result := Result_필수항목누락;
  if ExistObjectGDJson( ResultJson, FN_RoomName ) then
    FRoomInfo.RoomName := GetValueStringGDJson(ResultJson, FN_RoomName) else Result := Result_필수항목누락;
  if ExistObjectGDJson( ResultJson, FN_DeptCode ) then
    FRoomInfo.DeptCode := GetValueStringGDJson(ResultJson, FN_DeptCode) else Result := Result_필수항목누락;
  if ExistObjectGDJson( ResultJson, FN_DeptName ) then
    FRoomInfo.DeptName := GetValueStringGDJson(ResultJson, FN_DeptName) else Result := Result_필수항목누락;
  if ExistObjectGDJson( ResultJson, FN_doctorCode ) then
    FRoomInfo.DoctorCode := GetValueStringGDJson(ResultJson, FN_doctorCode) else Result := Result_필수항목누락;
  if ExistObjectGDJson( ResultJson, FN_doctorName ) then
    FRoomInfo.DoctorName := GetValueStringGDJson(ResultJson, FN_DoctorName) else Result := Result_필수항목누락;
  FEtcPurpose := GetValueStringGDJson(ResultJson, FN_EtcPurpose);

  FReceptionDttm := 0;
  if ExistObjectGDJson( ResultJson, FN_ReceptionDttm ) then
    FReceptionDttm := MakeDttmStr2DateTime( GetValueStringGDJson(ResultJson, FN_ReceptionDttm) )
  else Result := Result_필수항목누락;
  FInboundPath := GetValueStringGDJson(ResultJson, FN_InboundPath);

    purposelistjson := TJSONArray( FindObjectGDJson(ResultJson, FN_PurposeList) );
    if Assigned(purposelistjson) and ( purposelistjson.Count > 0 ) then
    begin
      for i := 0 to purposelistjson.Count-1 do
      begin
        datajson := TJSONObject( purposelistjson.Items[ i ] );
        item := TPurposeListItem.Create;
        item.purpose1 := GetValueStringGDJson(datajson, FN_Purpose1);
        item.purpose2 := GetValueStringGDJson(datajson, FN_Purpose2);
        item.purpose3 := GetValueStringGDJson(datajson, FN_Purpose3);
        FPurposeList.Add( item );
      end;
    end;

  FisFirst := GetValueBooleanGDJson(ResultJson, FN_isFirst);

  if Result = Result_Success then
  begin // 필수 data 확인
    if (FHospitalNO = '' ) or
       (FPatntName = '') or (FregNum = '') or
       (FRoomInfo.RoomCode = '') or (FRoomInfo.RoomName = '') or
       (FRoomInfo.DeptCode = '') or (FRoomInfo.DeptName = '') or
       (FRoomInfo.DoctorCode = '') or (FRoomInfo.DoctorName = '') or
       (FEndPoint = '') or
       (FReceptionDttm = 0)
    then
        Result := Result_필수항목누락;
  end;
end;


constructor TBridgeResponse_100.Create(ABaseProtocol: TBridgeProtocol);
begin
  inherited;
  FPurposeList := TObjectList.Create( true );
end;

destructor TBridgeResponse_100.Destroy;
begin
  FreeAndNil( FPurposeList );
  inherited;
end;

function TBridgeResponse_100.GetPurposeListCount: Integer;
begin
  Result := FPurposeList.Count;
end;

function TBridgeResponse_100.GetPurposeLists(index: integer): TPurposeListItem;
begin
  Result := TPurposeListItem( FPurposeList.Items[ index ] );
end;

{ TBridgeRequest_102 }

procedure TBridgeRequest_102.ConvertJson(AJsonWriter: TGDJsonTextWriter);
begin
  inherited ConvertJson(AJsonWriter);

  with AJsonWriter do
  begin
    WriteValue(FN_HospitalNo, hospitalNo);
    WriteValue(FN_PatntChartId, PatientChartID);
    WriteValue(FN_Message, CancelMessage);

    WriteValue(FN_chartReceptnResultId1, chartReceptnResultId.Id1);
    WriteValue(FN_chartReceptnResultId2, chartReceptnResultId.Id2);
    WriteValue(FN_chartReceptnResultId3, chartReceptnResultId.Id3);
    WriteValue(FN_chartReceptnResultId4, chartReceptnResultId.Id4);
    WriteValue(FN_chartReceptnResultId5, chartReceptnResultId.Id5);
    WriteValue(FN_chartReceptnResultId6, chartReceptnResultId.Id6);

    WriteValue(FN_RoomCode, RoomInfo.RoomCode);
    WriteValue(FN_RoomName, RoomInfo.RoomName);
    WriteValue(FN_DeptCode, RoomInfo.DeptCode);
    WriteValue(FN_DeptName, RoomInfo.DeptName);
    WriteValue(FN_DoctorCode, RoomInfo.DoctorCode);
    WriteValue(FN_DoctorName, RoomInfo.DoctorName);
    WriteValue(FN_receptStatusChangeDttm, MakeDateTime2DttmStr( receptStatusChangeDttm ));
  end;
end;

{ TBridgeResponse_102 }

function TBridgeResponse_102.AnalysisJson(AJsonRoot: TJSONObject): Integer;
var
  ResultJson : TJSONObject;
begin
  inherited AnalysisJson( AJsonRoot );
  Result := Result_Success;

  ResultJson := AJsonRoot;

  FHospitalNo := GetValueStringGDJson(ResultJson, FN_HospitalNo);
  FPatientChartID := GetValueStringGDJson(ResultJson, FN_PatntChartId);
  FCancelMessage := GetValueStringGDJson(ResultJson, FN_Message);

  if ExistObjectGDJson( ResultJson, FN_chartReceptnResultId1 ) then
    FchartReceptnResultId.Id1 := GetValueStringGDJson(ResultJson, FN_chartReceptnResultId1) else Result := Result_필수항목누락;
  FchartReceptnResultId.Id2 := GetValueStringGDJson(ResultJson, FN_chartReceptnResultId2);
  FchartReceptnResultId.Id3 := GetValueStringGDJson(ResultJson, FN_chartReceptnResultId3);
  FchartReceptnResultId.Id4 := GetValueStringGDJson(ResultJson, FN_chartReceptnResultId4);
  FchartReceptnResultId.Id5 := GetValueStringGDJson(ResultJson, FN_chartReceptnResultId5);
  FchartReceptnResultId.Id6 := GetValueStringGDJson(ResultJson, FN_chartReceptnResultId6);

  FRoomInfo.DeptCode := GetValueStringGDJson(ResultJson, FN_RoomCode);
  FRoomInfo.RoomName := GetValueStringGDJson(ResultJson, FN_RoomName);
  FRoomInfo.DeptCode := GetValueStringGDJson(ResultJson, FN_DeptCode);
  FRoomInfo.DeptName := GetValueStringGDJson(ResultJson, FN_DeptName);
  FRoomInfo.DoctorCode := GetValueStringGDJson(ResultJson, FN_DoctorCode);
  FRoomInfo.DoctorName := GetValueStringGDJson(ResultJson, FN_DoctorName);

  FreceptStatusChangeDttm := 0;
  if ExistObjectGDJson( ResultJson, FN_receptStatusChangeDttm ) then
    FreceptStatusChangeDttm := MakeDttmStr2DateTime( GetValueStringGDJson(ResultJson, FN_receptStatusChangeDttm) )
  else Result := Result_필수항목누락;

  if Result = Result_Success then
  begin // 필수 data 확인
    if (FchartReceptnResultId.Id1 = '') or (FreceptStatusChangeDttm = 0)
    then
        Result := Result_필수항목누락;
  end;
end;

{ TBridgeRequest_103 }


{ TBridgeRequest_Nomal }

procedure TBridgeRequest_Nomal.AddResultJson(
  AResultJsonWriter: TGDJsonTextWriter);
begin

end;

procedure TBridgeRequest_Nomal.ConvertJson(AJsonWriter: TGDJsonTextWriter);
begin
  inherited ConvertJson(AJsonWriter);

  with AJsonWriter do
  begin
    WriteValue(FN_Code, Code);
    WriteValue(FN_Message, MessageStr);

    StartObject(FN_Result);
      AddResultJson( AJsonWriter );
    EndObject;
  end;
end;

{ TBridgeRequest_202 }

procedure TBridgeRequest_202.ConvertJson(AJsonWriter: TGDJsonTextWriter);
begin
  inherited ConvertJson(AJsonWriter);

  with AJsonWriter do
  begin
    WriteValue(FN_HospitalNo, hospitalNo);
    WriteValue(FN_Message, CancelMessage);

    WriteValue(FN_chartReceptnResultId1, chartReceptnResultId.Id1);
    WriteValue(FN_chartReceptnResultId2, chartReceptnResultId.Id2);
    WriteValue(FN_chartReceptnResultId3, chartReceptnResultId.Id3);
    WriteValue(FN_chartReceptnResultId4, chartReceptnResultId.Id4);
    WriteValue(FN_chartReceptnResultId5, chartReceptnResultId.Id5);
    WriteValue(FN_chartReceptnResultId6, chartReceptnResultId.Id6);

    WriteValue(FN_RoomCode, RoomInfo.RoomCode);
    WriteValue(FN_RoomName, RoomInfo.RoomName);
    WriteValue(FN_DeptCode, RoomInfo.DeptCode);
    WriteValue(FN_DeptName, RoomInfo.DeptName);
    WriteValue(FN_DoctorCode, RoomInfo.DoctorCode);
    WriteValue(FN_DoctorName, RoomInfo.DoctorName);
    WriteValue(FN_receptStatusChangeDttm, MakeDateTime2DttmStr( receptStatusChangeDttm ) );
  end;
end;

{ TBridgeResponse_202 }

function TBridgeResponse_202.AnalysisJson(AJsonRoot: TJSONObject): Integer;
var
  ResultJson : TJSONObject;
begin
  inherited AnalysisJson( AJsonRoot );
  Result := Result_Success;

  ResultJson := AJsonRoot;

  if ExistObjectGDJson( ResultJson, FN_HospitalNo ) then
    FHospitalNo := GetValueStringGDJson(ResultJson, FN_HospitalNo) else Result := Result_필수항목누락;
  FCancelMessage := GetValueStringGDJson(ResultJson, FN_Message);

  if ExistObjectGDJson( ResultJson, FN_chartReceptnResultId1 ) then
    FchartReceptnResultId.Id1 := GetValueStringGDJson(ResultJson, FN_chartReceptnResultId1) else Result := Result_필수항목누락;
  FchartReceptnResultId.Id2 := GetValueStringGDJson(ResultJson, FN_chartReceptnResultId2);
  FchartReceptnResultId.Id3 := GetValueStringGDJson(ResultJson, FN_chartReceptnResultId3);
  FchartReceptnResultId.Id4 := GetValueStringGDJson(ResultJson, FN_chartReceptnResultId4);
  FchartReceptnResultId.Id5 := GetValueStringGDJson(ResultJson, FN_chartReceptnResultId5);
  FchartReceptnResultId.Id6 := GetValueStringGDJson(ResultJson, FN_chartReceptnResultId6);

  FRoomInfo.DeptCode := GetValueStringGDJson(ResultJson, FN_RoomCode);
  FRoomInfo.RoomName := GetValueStringGDJson(ResultJson, FN_RoomName);
  FRoomInfo.DeptCode := GetValueStringGDJson(ResultJson, FN_DeptCode);
  FRoomInfo.DeptName := GetValueStringGDJson(ResultJson, FN_DeptName);
  FRoomInfo.DoctorCode := GetValueStringGDJson(ResultJson, FN_DoctorCode);
  FRoomInfo.DoctorName := GetValueStringGDJson(ResultJson, FN_DoctorName);

  FreceptStatusChangeDttm := 0;
  if ExistObjectGDJson( ResultJson, FN_receptStatusChangeDttm ) then
    FreceptStatusChangeDttm := MakeDttmStr2DateTime( GetValueStringGDJson(ResultJson, FN_receptStatusChangeDttm) )
  else Result := Result_필수항목누락;

  if Result = Result_Success then
  begin // 필수 data 확인
    if (FHospitalNo = '') or
       (FchartReceptnResultId.Id1 = '') or (FreceptStatusChangeDttm = 0)
    then
        Result := Result_필수항목누락;
  end;
end;

{ TBridgeRequest_206 }

procedure TBridgeRequest_206.ConvertJson(AJsonWriter: TGDJsonTextWriter);
begin
  inherited ConvertJson(AJsonWriter);

  with AJsonWriter do
  begin
    WriteValue(FN_HospitalNo, hospitalNo);

    WriteValue(FN_chartReceptnResultId1, chartReceptnResultId.Id1);
    WriteValue(FN_chartReceptnResultId2, chartReceptnResultId.Id2);
    WriteValue(FN_chartReceptnResultId3, chartReceptnResultId.Id3);
    WriteValue(FN_chartReceptnResultId4, chartReceptnResultId.Id4);
    WriteValue(FN_chartReceptnResultId5, chartReceptnResultId.Id5);
    WriteValue(FN_chartReceptnResultId6, chartReceptnResultId.Id6);

    WriteValue(FN_ReserveDttm, MakeDateTime2DttmStr( reserveDttm ) );
  end;
end;

{ TBridgeRequest_302 }

procedure TBridgeRequest_302.ConvertJson(AJsonWriter: TGDJsonTextWriter);
begin
  inherited ConvertJson(AJsonWriter);

  with AJsonWriter do
  begin
    WriteValue(FN_HospitalNo, hospitalNo);
  end;
end;

{ TBridgeResponse_303 }

function TBridgeResponse_303.AnalysisJson(AJsonRoot: TJSONObject): Integer;
var
  i : Integer;
  ResultJson, datajson : TJSONObject;
  listJson : TJSONArray;
  item : TCancelMsgListItem;
begin
  Result := inherited AnalysisJson( AJsonRoot );

  ResultJson := TJSONObject( FindObjectGDJson(AJsonRoot, FN_Result ) );

  if ExistObjectGDJson( ResultJson, FN_CurrentLimit ) then
    FCurrentLimit := GetValueIntegerGDJson(ResultJson, FN_CurrentLimit) else Result := Result_필수항목누락;
  if ExistObjectGDJson( ResultJson, FN_CurrentOffset ) then
    FCurrentOffset := GetValueIntegerGDJson(ResultJson, FN_CurrentOffset) else Result := Result_필수항목누락;
  if ExistObjectGDJson( ResultJson, FN_TotalCount ) then
    FTotal := GetValueIntegerGDJson(ResultJson, FN_TotalCount) else Result := Result_필수항목누락;

  listJson := TJSONArray( FindObjectGDJson(ResultJson, FN_Contents) );
  if (not Assigned( listJson ) ) or (listJson.Count = 0) then
    exit;

  for i := 0 to listJson.Count -1 do
  begin
    datajson := TJSONObject( listJson.Items[ i ] );
    item := TCancelMsgListItem.Create;

    //item.MessageStr := GetValueStringGDJson(datajson, FN_Message);
    item.MessageStr := GetValueStringGDJson(datajson, FN_Message2);

    //item.isDefault := GetValueBooleanGDJson(datajson, FN_Default);
    //item.isDefault := GetValueIntegerGDJson(datajson, FN_Default) <> 0;
    item.isDefault := GetValueBooleanGDJson(datajson, FN_isChoice);
    //item.isDefault := GetValueBooleanGDJson(datajson, FN_Select);

    FList.Add( item );

    if Result = Result_Success then
    begin
      if item.MessageStr = '' then
        Result := Result_필수항목누락;
    end;
  end;
end;

constructor TBridgeResponse_303.Create(ABaseProtocol: TBridgeProtocol);
begin
  inherited;
  FList := TObjectList.Create( True );
end;

destructor TBridgeResponse_303.Destroy;
begin
  FreeAndNil( FList );
  inherited;
end;


function TBridgeResponse_303.GetCancelMessageList(
  index: Integer): TCancelMsgListItem;
begin
  Result := TCancelMsgListItem( FList.Items[ index ] );
end;

function TBridgeResponse_303.GetCancelMessageListCount: Integer;
begin
  Result := FList.Count;
end;

{ TBridgeRequest_300 }

function TBridgeRequest_300.AddRoomInfo(ARoomInfo: TRoomListItem): Integer;
begin
  Result := FRoomList.Add( ARoomInfo );
end;

procedure TBridgeRequest_300.ConvertJson(AJsonWriter: TGDJsonTextWriter);
var
  i : Integer;
  item : TRoomListItem;
begin
  inherited ConvertJson(AJsonWriter);

  with AJsonWriter do
  begin
    WriteValue(FN_HospitalNo, hospitalNo);
    StartArray( FN_List );
    try
      for i := 0 to FRoomList.Count -1 do
      begin
        item := TRoomListItem( FRoomList.Items[ i ] );
        if not Assigned( item ) then
          continue;
        StartObject;
        try
          WriteValue(FN_RoomCode, item.RoomCode);
          WriteValue(FN_RoomName, item.RoomName);
          WriteValue(FN_DeptCode, item.DeptCode);
          WriteValue(FN_DeptName, item.DeptName);
          WriteValue(FN_DoctorCode, item.DoctorCode);
          WriteValue(FN_DoctorName, item.DoctorName);
        finally
          EndObject;
        end;
      end;
    finally
      EndArray;
    end;
  end;
end;

constructor TBridgeRequest_300.Create(AEventID: integer; AJobID: String);
begin
  inherited;
  FRoomList := TObjectList.Create( true );
end;

destructor TBridgeRequest_300.Destroy;
begin
  FreeAndNil( FRoomList );
  inherited;
end;

{ TBridgeResponse_200 }

function TBridgeResponse_200.AnalysisJson(AJsonRoot: TJSONObject): Integer;
var
  i : Integer;
  PurposeListJson : TJSONArray;
  data : TJSONObject;
  item : TPurposeListItem;
begin
  inherited AnalysisJson( AJsonRoot );
  Result := Result_Success;

  if ExistObjectGDJson( AJsonRoot, FN_HospitalNo ) then
    FHospitalNo := GetValueStringGDJson(AJsonRoot, FN_HospitalNo) else Result := Result_필수항목누락;
  FPatntChartId := GetValueStringGDJson(AJsonRoot, FN_PatntChartId);
  if ExistObjectGDJson( AJsonRoot, FN_CellPhone ) then
    FCellPhone := GetValueStringGDJson(AJsonRoot, FN_CellPhone) else Result := Result_필수항목누락;
  if ExistObjectGDJson( AJsonRoot, FN_RegNum ) then
    FRegNum := GetValueStringGDJson(AJsonRoot, FN_RegNum) else Result := Result_필수항목누락;
  if ExistObjectGDJson( AJsonRoot, FN_PatntName ) then
    FPatntName := GetValueStringGDJson(AJsonRoot, FN_PatntName) else Result := Result_필수항목누락;
  FSexdstn := GetValueStringGDJson(AJsonRoot, FN_Sexdstn);
  FBirthday := GetValueStringGDJson(AJsonRoot, FN_Birthday);
  FAddr := GetValueStringGDJson(AJsonRoot, FN_Addr);
  FAddrDetail := GetValueStringGDJson(AJsonRoot, FN_AddrDetail);
  FZip := GetValueStringGDJson(AJsonRoot, FN_Zip);
  FInboundPath := GetValueStringGDJson(AJsonRoot, FN_InboundPath);
  if ExistObjectGDJson( AJsonRoot, FN_RoomCode ) then
    FRoomInfo.RoomCode := GetValueStringGDJson(AJsonRoot, FN_RoomCode) else Result := Result_필수항목누락;
  if ExistObjectGDJson( AJsonRoot, FN_RoomName ) then
    FRoomInfo.RoomName := GetValueStringGDJson(AJsonRoot, FN_RoomName) else Result := Result_필수항목누락;
  if ExistObjectGDJson( AJsonRoot, FN_DeptCode ) then
    FRoomInfo.DeptCode := GetValueStringGDJson(AJsonRoot, FN_DeptCode) else Result := Result_필수항목누락;
  if ExistObjectGDJson( AJsonRoot, FN_DeptName ) then
    FRoomInfo.DeptName := GetValueStringGDJson(AJsonRoot, FN_DeptName) else Result := Result_필수항목누락;
  if ExistObjectGDJson( AJsonRoot, FN_DoctorCode ) then
    FRoomInfo.DoctorCode := GetValueStringGDJson(AJsonRoot, FN_DoctorCode) else Result := Result_필수항목누락;
  if ExistObjectGDJson( AJsonRoot, FN_DoctorName ) then
    FRoomInfo.DoctorName := GetValueStringGDJson(AJsonRoot, FN_DoctorName) else Result := Result_필수항목누락;

  FReserveDttm := 0;
  if ExistObjectGDJson( AJsonRoot, FN_ReserveDttm ) then
    FReserveDttm := MakeDttmStr2DateTime( GetValueStringGDJson(AJsonRoot, FN_ReserveDttm) )
  else Result := Result_필수항목누락;

  PurposeListJson := TJSONArray( FindObjectGDJson(AJsonRoot, FN_PurposeList ) );
  if (Assigned( PurposeListJson )) and ( PurposeListJson.Count > 0 ) then
  begin
    for i := 0 to PurposeListJson.Count -1 do
    begin
      data := TJSONObject( PurposeListJson.Items[i] );
      item := TPurposeListItem.Create;
      item.purpose1 := GetValueStringGDJson(data, FN_Purpose1);
      item.purpose2 := GetValueStringGDJson(data, FN_Purpose2);
      item.purpose2 := GetValueStringGDJson(data, FN_Purpose3);
      FPurposeList.Add( item );
    end;
  end;

  FEtcPurpose := GetValueStringGDJson(AJsonRoot, FN_EtcPurpose);

  FRegistrationDttm := 0;
  if ExistObjectGDJson( AJsonRoot, FN_ReceptionDttm ) then
    FRegistrationDttm := MakeDttmStr2DateTime( GetValueStringGDJson(AJsonRoot, FN_ReceptionDttm) )
  else Result := Result_필수항목누락;

  if Result = Result_Success then
  begin // 필수 data 확인
    if (FHospitalNo = '') or
       (FPatntName = '' ) or (FCellPhone = '' ) or (FRegNum = '' ) or
       (FRoomInfo.RoomCode = '' ) or (FRoomInfo.RoomName = '' ) or (FRoomInfo.DeptCode = '' ) or
       (FRoomInfo.DeptName = '' ) or (FRoomInfo.DoctorCode = '' ) or (FRoomInfo.DoctorName = '' ) or
       (FReserveDttm = 0 ) or (FRegistrationDttm = 0 )
    then
        Result := Result_필수항목누락;
  end;
end;

constructor TBridgeResponse_200.Create(ABaseProtocol: TBridgeProtocol);
begin
  inherited;
  FPurposeList := TObjectList.Create( true );
end;

destructor TBridgeResponse_200.Destroy;
begin
  FreeAndNil( FPurposeList );
  inherited;
end;

function TBridgeResponse_200.GetPurposeListCount: Integer;
begin
  Result := FPurposeList.Count;
end;

function TBridgeResponse_200.GetPurposeLists(index: integer): TPurposeListItem;
begin
  Result := TPurposeListItem( FPurposeList.Items[ index ] );
end;

{ TBridgeRequest_201 }

procedure TBridgeRequest_201.AddResultJson(
  AResultJsonWriter: TGDJsonTextWriter);
begin
  inherited AddResultJson(AResultJsonWriter);

  with AResultJsonWriter do
  begin
      WriteValue(FN_HospitalNo, hospitalNo);

      WriteValue(FN_PatntChartId, PatntChartID);
      WriteValue(FN_RegNum, RegNum);
      WriteValue(FN_RoomCode, RoomInfo.RoomCode);
      WriteValue(FN_RoomName, RoomInfo.RoomName);
      WriteValue(FN_DeptCode, RoomInfo.DeptCode);
      WriteValue(FN_DeptName, RoomInfo.DeptName);
      WriteValue(FN_DoctorCode, RoomInfo.DoctorCode);
      WriteValue(FN_DoctorName, RoomInfo.DoctorName);
      WriteValue(FN_chartReceptnResultId1, chartReceptnResultId.Id1);
      WriteValue(FN_chartReceptnResultId2, chartReceptnResultId.Id2);
      WriteValue(FN_chartReceptnResultId3, chartReceptnResultId.Id3);
      WriteValue(FN_chartReceptnResultId4, chartReceptnResultId.Id4);
      WriteValue(FN_chartReceptnResultId5, chartReceptnResultId.Id5);
      WriteValue(FN_chartReceptnResultId6, chartReceptnResultId.Id6);
  end;
end;

procedure TBridgeRequest_201.ConvertJson(AJsonWriter: TGDJsonTextWriter);
begin
  inherited ConvertJson(AJsonWriter);
end;

{ TBridgeRequest_108 }

procedure TBridgeRequest_108.ConvertJson(AJsonWriter: TGDJsonTextWriter);
begin
  inherited ConvertJson(AJsonWriter);

  with AJsonWriter do
  begin
    WriteValue(FN_HospitalNo, HospitalNo);

    StartObject( FN_ReceptionUpdateDto );
    try
      WriteValue(FN_chartReceptnResultId1, ReceptionUpdateDto.chartReceptnResultId.Id1);
      WriteValue(FN_chartReceptnResultId2, ReceptionUpdateDto.chartReceptnResultId.Id2);
      WriteValue(FN_chartReceptnResultId3, ReceptionUpdateDto.chartReceptnResultId.Id3);
      WriteValue(FN_chartReceptnResultId4, ReceptionUpdateDto.chartReceptnResultId.Id4);
      WriteValue(FN_chartReceptnResultId5, ReceptionUpdateDto.chartReceptnResultId.Id5);
      WriteValue(FN_chartReceptnResultId6, ReceptionUpdateDto.chartReceptnResultId.Id6);

      WriteValue(FN_PatntChartId, ReceptionUpdateDto.PatientChartId);
      WriteValue(FN_RoomCode, ReceptionUpdateDto.RoomInfo.RoomCode);
      WriteValue(FN_RoomName, ReceptionUpdateDto.RoomInfo.RoomName);
      WriteValue(FN_DeptCode, ReceptionUpdateDto.RoomInfo.DeptCode);
      WriteValue(FN_DeptName, ReceptionUpdateDto.RoomInfo.DeptName);
      WriteValue(FN_DoctorCode, ReceptionUpdateDto.RoomInfo.DoctorCode);
      WriteValue(FN_DoctorName, ReceptionUpdateDto.RoomInfo.DoctorName);
      WriteValue(FN_Memo, ReceptionUpdateDto.memo);
      WriteValue(FN_Status, ReceptionUpdateDto.Status);
    finally
      EndObject
    end;

    WriteValue(FN_NewchartReceptnResultId1, NewchartReceptnResult.Id1);
    WriteValue(FN_NewchartReceptnResultId2, NewchartReceptnResult.Id2);
    WriteValue(FN_NewchartReceptnResultId3, NewchartReceptnResult.Id3);
    WriteValue(FN_NewchartReceptnResultId4, NewchartReceptnResult.Id4);
    WriteValue(FN_NewchartReceptnResultId5, NewchartReceptnResult.Id5);
    WriteValue(FN_NewchartReceptnResultId6, NewchartReceptnResult.Id6);
    WriteValue(FN_receptStatusChangeDttm, MakeDateTime2DttmStr( receptStatusChangeDttm ) )
  end;
end;

constructor TBridgeRequest_108.Create(AEventID: integer; AJobID: String);
begin
  inherited;
  ReceptionUpdateDto:= TReceptionUpdateDto.Create;

end;

destructor TBridgeRequest_108.Destroy;
begin
  FreeAndNil( ReceptionUpdateDto );

  inherited;
end;

{ TBridgeRequest_106 }

procedure TBridgeRequest_106.ConvertJson(AJsonWriter: TGDJsonTextWriter);
begin
  inherited ConvertJson(AJsonWriter);

  with AJsonWriter do
  begin
    WriteValue(FN_HospitalNo, HospitalNo);

    StartObject( FN_ReceptionUpdateDto );
    try
      WriteValue(FN_chartReceptnResultId1, ReceptionUpdateDto.chartReceptnResultId.Id1);
      WriteValue(FN_chartReceptnResultId2, ReceptionUpdateDto.chartReceptnResultId.Id2);
      WriteValue(FN_chartReceptnResultId3, ReceptionUpdateDto.chartReceptnResultId.Id3);
      WriteValue(FN_chartReceptnResultId4, ReceptionUpdateDto.chartReceptnResultId.Id4);
      WriteValue(FN_chartReceptnResultId5, ReceptionUpdateDto.chartReceptnResultId.Id5);
      WriteValue(FN_chartReceptnResultId6, ReceptionUpdateDto.chartReceptnResultId.Id6);

      WriteValue(FN_PatntChartId, ReceptionUpdateDto.PatientChartId);
      WriteValue(FN_RoomCode, ReceptionUpdateDto.RoomInfo.RoomCode);
      WriteValue(FN_RoomName, ReceptionUpdateDto.RoomInfo.RoomName);
      WriteValue(FN_DeptCode, ReceptionUpdateDto.RoomInfo.DeptCode);
      WriteValue(FN_DeptName, ReceptionUpdateDto.RoomInfo.DeptName);
      WriteValue(FN_DoctorCode, ReceptionUpdateDto.RoomInfo.DoctorCode);
      WriteValue(FN_DoctorName, ReceptionUpdateDto.RoomInfo.DoctorName);
      WriteValue(FN_Status, ReceptionUpdateDto.Status);
    finally
      EndObject
    end;
    WriteValue(FN_RoomChangeDttm, MakeDateTime2DttmStr( RoomChangeDttm) )
  end;
end;

constructor TBridgeRequest_106.Create(AEventID: integer; AJobID: String);
begin
  inherited;
  ReceptionUpdateDto:= TReceptionUpdateDto.Create;
end;

destructor TBridgeRequest_106.Destroy;
begin
  FreeAndNil( ReceptionUpdateDto );
  inherited;
end;

{ TBridgeRequest_104 }

function TBridgeRequest_104.Add(AchartReceptnResultId1,
  AchartReceptnResultId2, AchartReceptnResultId3, AchartReceptnResultId4,
  AchartReceptnResultId5, AchartReceptnResultId6: string): Integer;
var
  data : TReceptnListItem;
begin
  data := TReceptnListItem.Create;
  data.chartReceptnResultId1 := AchartReceptnResultId1;
  data.chartReceptnResultId2 := AchartReceptnResultId2;
  data.chartReceptnResultId3 := AchartReceptnResultId3;
  data.chartReceptnResultId4 := AchartReceptnResultId4;
  data.chartReceptnResultId5 := AchartReceptnResultId5;
  data.chartReceptnResultId6 := AchartReceptnResultId6;
  Result := FReceptnList.Add( data );
end;

procedure TBridgeRequest_104.ConvertJson(AJsonWriter: TGDJsonTextWriter);
var
  i : Integer;
  data : TReceptnListItem;
begin
  inherited ConvertJson(AJsonWriter);

  with AJsonWriter do
  begin
    WriteValue(FN_HospitalNo, HospitalNo);
    WriteValue(FN_RoomCode, RoomInfo.RoomCode);
    WriteValue(FN_RoomName, RoomInfo.RoomName);
    WriteValue(FN_DeptCode, RoomInfo.DeptCode);
    WriteValue(FN_DeptName, RoomInfo.DeptName);
    WriteValue(FN_DoctorCode, RoomInfo.DoctorCode);
    WriteValue(FN_DoctorName, RoomInfo.DoctorName);

    StartArray( FN_ReceptnList );
    try
      for i := 0 to FReceptnList.Count -1 do
      begin
        data := TReceptnListItem( FReceptnList.Items[ i ] );
        StartObject;
          WriteValue(FN_chartReceptnResultId1, data.chartReceptnResultId1);
          WriteValue(FN_chartReceptnResultId2, data.chartReceptnResultId2);
          WriteValue(FN_chartReceptnResultId3, data.chartReceptnResultId3);
          WriteValue(FN_chartReceptnResultId4, data.chartReceptnResultId4);
          WriteValue(FN_chartReceptnResultId5, data.chartReceptnResultId5);
          WriteValue(FN_chartReceptnResultId6, data.chartReceptnResultId6);
        EndObject;
      end;
    finally
      EndArray
    end;
  end;
end;

constructor TBridgeRequest_104.Create(AEventID: integer; AJobID: String);
begin
  inherited;
  FReceptnList := TObjectList.Create( True );
end;

destructor TBridgeRequest_104.Destroy;
begin
  FreeAndNil( FReceptnList );
  inherited;
end;

{ TBridgeResponse_0 }

function TBridgeResponse_0.AnalysisJson(AJsonRoot: TJSONObject): Integer;
begin
  //Result := inherited AnalysisJson( AJsonRoot );
  Result := Result_Success;

  FCellPhone := GetValueStringGDJson(AJsonRoot, FN_CellPhone);
  FRegNum := GetValueStringGDJson(AJsonRoot, FN_RegNum);
end;

{ TBridgeRequest_1 }

function TBridgeRequest_1.Add(APatntChartID, APatntName, ARegNum, ACellPhone,
  ASexdstn, ABirthDay, AAddr, AAddrdetail, AZip: string): Integer;
var
  data : TPatntListItem;
begin
  data := TPatntListItem.Create;
  data.PatntChartId := APatntChartID;
  data.PatntName := APatntName;
  data.RegNum := ARegNum;
  data.CellPhone := ACellPhone;
  data.Sexdstn := ASexdstn;
  data.Birthday := ABirthDay;
  data.addr := AAddr;
  data.addrDetail := AAddrdetail;
  data.zip := AZip;
  Result := FpatntList.Add( data );
end;

procedure TBridgeRequest_1.AddResultJson(AResultJsonWriter: TGDJsonTextWriter);
var
  i : Integer;
  data : TPatntListItem;
begin
  inherited AddResultJson( AResultJsonWriter );

  with AResultJsonWriter do
  begin
    WriteValue(FN_HospitalNo, HospitalNo);
    StartArray( FN_patntList );
    try
      for i := 0 to FpatntList.Count -1 do
      begin
        data := TPatntListItem( FpatntList.Items[i] );
        StartObject;
          WriteValue(FN_PatntChartId, data.PatntChartId);
          WriteValue(FN_CellPhone, data.CellPhone);
          WriteValue(FN_RegNum, data.RegNum);
          WriteValue(FN_PatntName, data.PatntName);
          WriteValue(FN_Sexdstn, data.Sexdstn);
          WriteValue(FN_Birthday, data.Birthday);
          WriteValue(FN_Addr, data.addr);
          WriteValue(FN_AddrDetail, data.addrDetail);
          WriteValue(FN_Zip, data.Zip);
        EndObject;
      end;
    finally
      EndArray;
    end;
  end;
end;


constructor TBridgeRequest_1.Create(AEventID: integer; AJobID: String);
begin
  inherited;
  FpatntList := TObjectList.Create( true );
end;

destructor TBridgeRequest_1.Destroy;
begin
  FreeAndNil( FpatntList );
  inherited;
end;

{ TBridgeFactory }

function TBridgeFactory.GetErrorString(AErrorNum: Integer): string;
begin
  case AErrorNum of
    Result_Success                    : Result := '';
    Result_필수항목누락               : Result := Result_필수항목누락_Msg;
    Result_접수번호없음               : Result := Result_접수번호없음_Msg;
    Result_접수중복                   : Result := Result_접수중복_Msg;
    Result_NotDefineEvent             : Result := Result_NotDefineEvent_Msg;
    Result_NoRelation_NotDefineEvent  : Result := Result_NoRelation_NotDefineEvent_Msg;
    Result_NoData                     : Result := Result_NoData_Msg; //  901;
    Result_DLLNotLoaded               : Result := Result_DLLNotLoaded_Msg;
    Result_ExceptionError             : Result := Result_ExceptionError_Msg;
  else
    result := format('알수 없는 Error 코드입니다(%d)', [AErrorNum]);
  end;
end;

function TBridgeFactory.MakeRequestObj(AEventID: Integer; AJobID: string): TBridgeRequest;
var
  jobid : string;
begin
  Result := nil;
  jobid := AJobID;
  if jobid = '' then
    jobid := MakeJobID;

  case AEventID of
    EventID_환자조회결과 {1}      : Result := TBridgeRequest_1.Create(EventID_환자조회결과, jobid);
    EventID_접수요청     {100}    : Result := TBridgeRequest_100.Create(EventID_접수요청, jobid);
    EventID_접수요청결과 {101}    : Result := TBridgeRequest_101.Create(EventID_접수요청결과, jobid);
    EventID_접수취소     {102}    : Result := TBridgeRequest_102.Create(EventID_접수취소, jobid);
    EventID_접수취소결과 {103}    : Result := TBridgeRequest_103.Create(EventID_접수취소결과, jobid);
    EventID_대기순번변경 {104}    : Result := TBridgeRequest_104.Create(EventID_대기순번변경, jobid);
    EventID_대기열변경   {106}    : Result := TBridgeRequest_106.Create(EventID_대기열변경, jobid);
    EventID_대기열상태값변경{108} : Result := TBridgeRequest_108.Create(EventID_대기열상태값변경, jobid);
    EventID_내원확인요청결과{111} : Result := TBridgeRequest_111.Create(EventID_내원확인요청결과, jobid);
    EventID_예약요청결과 {201}    : Result := TBridgeRequest_201.Create(EventID_예약요청결과, jobid);
    EventID_예약취소      {202}   : Result := TBridgeRequest_202.Create(EventID_예약취소, jobid);
    EventID_예약취소결과  {203}   : Result := TBridgeRequest_203.Create(EventID_예약취소결과, jobid);
    EventID_예약요청시간변경  {206}   : Result := TBridgeRequest_206.Create(EventID_예약요청시간변경, jobid);
    EventID_대기열목록전송{300}   : Result := TBridgeRequest_300.Create(EventID_대기열목록전송, jobid);
    EventID_대기열목록요청{302}   : Result := TBridgeRequest_402.Create(EventID_대기열목록요청, jobid);
    EventID_취소메시지목록요청 {304} : Result := TBridgeRequest_302.Create(EventID_취소메시지목록요청, jobid);
    EventID_미전송목록요청{306}   : Result := TBridgeRequest_306.Create(EventID_미전송목록요청, jobid);
    EventID_미전송목록요청결과전송 {308} : Result := TBridgeRequest_308.Create(EventID_미전송목록요청결과전송, jobid);
    EventID_접수예약목록요청 {400}: Result := TBridgeRequest_400.Create(EventID_접수예약목록요청, jobid);
    EventID_환자정보수정요청{404} : Result := TBridgeRequest_404.Create(EventID_환자정보수정요청, jobid);
(* login api로 대체됨
    EventID_사용자인증요청 {404}  : Result := TBridgeRequest_404.Create(EventID_사용자인증요청, jobid); *)
(* event 108로 대체됨
    EventID_메모수정요청    {406} : Result := TBridgeRequest_406.Create(EventID_메모수정요청, jobid); *)
//  EventID_메모수정요청결과        = 407;
    EventID_접수예약목록건별요청{406} : Result := TBridgeRequest_406.Create(EventID_접수예약목록건별요청, jobid);
    EventID_환자주민번호요청{410} : Result := TBridgeRequest_410.Create(EventID_환자주민번호요청, jobid);
    EventID_접수목록변경알림결과  : Result := TBridgeRequest_421.Create(EventID_접수목록변경알림결과, jobid);
    EventID_예약스케쥴공유요청    : Result := TBridgeRequest_2006.Create(EventID_예약스케쥴공유요청, jobid);

    EventID_시스템Error           : Result := TBridgeRequestError_9999.Create( EventID_시스템Error, jobid );
  end;
end;

function TBridgeFactory.MakeResponseObj(
  ABaseObject : TBridgeProtocol): TBridgeResponse;
begin
  Result := nil;
  case ABaseObject.EventID of
    EventID_환자조회                : Result := TBridgeResponse_0.Create( ABaseObject );
    EventID_접수요청                : Result := TBridgeResponse_100.Create( ABaseObject );
    EventID_접수요청결과            : Result := TBridgeResponse_101.Create( ABaseObject );
    EventID_접수취소                : Result := TBridgeResponse_102.Create( ABaseObject );
    EventID_접수취소결과            : Result := TBridgeResponse_103.Create( ABaseObject );
    EventID_대기순번변경결과        : Result := TBridgeResponse_105.Create( ABaseObject );
    EventID_대기열변경결과          : Result := TBridgeResponse_107.Create( ABaseObject );
    EventID_대기열상태값변경결과    : Result := TBridgeResponse_109.Create( ABaseObject );
    EventID_내원확인요청{110}       : Result := TBridgeResponse_110.Create(ABaseObject);
    EventID_예약요청                : Result := TBridgeResponse_200.Create( ABaseObject );
    EventID_예약취소                : Result := TBridgeResponse_202.Create( ABaseObject );
    EventID_예약취소결과            : Result := TBridgeResponse_203.Create( ABaseObject );
    EventID_예약요청시간변경결과    : Result := TBridgeResponse_207.Create( ABaseObject );
    EventID_대기열목록전송결과      : Result := TBridgeResponse_301.Create( ABaseObject );
    EventID_취소메시지목록요청결과  : Result := TBridgeResponse_303.Create( ABaseObject );
    EventID_미전송목록요청결과{307} : Result := TBridgeResponse_307.Create( ABaseObject );
    EventID_미전송목록요청결과전송결과{309} : Result := TBridgeResponse_309.Create( ABaseObject );
    EventID_접수예약목록요청결과    : Result := TBridgeResponse_401.Create( ABaseObject );
    EventID_대기열목록요청결과      : Result := TBridgeResponse_403.Create( ABaseObject );
    EventID_환자정보수정요청결과    : Result := TBridgeResponse_405.Create( ABaseObject );
    EventID_접수예약목록건별요청결과 : Result := TBridgeResponse_407.Create( ABaseObject );
(* login api로 대체됨
    EventID_사용자인증요청결과      : Result := TBridgeResponse_405.Create( ABaseObject ); *)
(* event 108로 대체됨
//  EventID_메모수정요청            = 406; // 차트(미연동)->굿닥
    EventID_메모수정요청결과        : Result := TBridgeResponse_407.Create( ABaseObject ); *)
    EventID_환자주민번호요청결과    : Result := TBridgeResponse_411.Create( ABaseObject );
    EventID_접수목록변경알림        : Result := TBridgeResponse_420.Create( ABaseObject );
    EventID_예약스케쥴공유요청결과  : Result := TBridgeResponse_2007.Create( ABaseObject );

    EventID_시스템Error2,
    EventID_시스템Error             : Result := TBridgeError_9999.Create( ABaseObject );
  end;
  if Assigned( Result ) then
    Result.Analysis;
end;

function TBridgeFactory.MakeResponseObj(AJsonStr: string): TBridgeResponse;
var
  jsonobj : TJSONObject;
  base : TBridgeProtocol;
begin
  Result := nil;
  jsonobj := ParseingGDJson( AJsonStr );
  if not Assigned(jsonobj) then
    exit;

  base := TBridgeProtocol.Create( jsonobj );
  Result := MakeResponseObj( base );
  if not Assigned( Result ) then // 생성할 protocol 객체가 없다
    FreeAndNil( base );
end;

function TBridgeFactory.MakeResponseObj(AEventID: Integer;
  AJobID: string): TBridgeResponse;
var
  base : TBridgeProtocol;
begin
  Result := nil;
  base := TBridgeProtocol.Create( AEventID, AJobID );
  case base.EventID of
    EventID_환자조회    : Result := TBridgeResponse_0.Create( base );
    EventID_접수요청    : Result := TBridgeResponse_100.Create( base );
    EventID_접수취소    : Result := TBridgeResponse_102.Create( base );
    EventID_예약요청    : Result := TBridgeResponse_200.Create( base );
    EventID_예약취소    : Result := TBridgeResponse_202.Create( base );
    EventID_시스템Error : Result := TBridgeError_9999.Create( base );
  end;
end;

{ TBridgeRequest_101 }

procedure TBridgeRequest_101.AddResultJson(
  AResultJsonWriter: TGDJsonTextWriter);
begin
  inherited AddResultJson( AResultJsonWriter );

  with AResultJsonWriter do
  begin
    WriteValue(FN_HospitalNo, HospitalNo);
    WriteValue(FN_PatntChartId, PatntChartID);
    WriteValue(FN_RegNum, RegNum);
    WriteValue(FN_chartReceptnResultId1, chartReceptnResultId.Id1);
    WriteValue(FN_chartReceptnResultId2, chartReceptnResultId.Id2);
    WriteValue(FN_chartReceptnResultId3, chartReceptnResultId.Id3);
    WriteValue(FN_chartReceptnResultId4, chartReceptnResultId.Id4);
    WriteValue(FN_chartReceptnResultId5, chartReceptnResultId.Id5);
    WriteValue(FN_chartReceptnResultId6, chartReceptnResultId.Id6);
    WriteValue(FN_RoomCode, RoomInfo.RoomCode);
    WriteValue(FN_RoomName, RoomInfo.RoomName);
    WriteValue(FN_DeptCode, RoomInfo.DeptCode);
    WriteValue(FN_DeptName, RoomInfo.DeptName);
    WriteValue(FN_DoctorCode, RoomInfo.DoctorCode);
    WriteValue(FN_DoctorName, RoomInfo.DoctorName);

    WriteValue(FN_gdid, gdid);
    WriteValue(FN_ePrescriptionHospital, ePrescriptionHospital);
  end;
end;

constructor TBridgeRequest_101.Create(AEventID: integer; AJobID: String);
begin
  inherited;
  gdid := '';                   // 굿닥 아이디
  ePrescriptionHospital := 0; // 전자 처방전 병원 여부 (0:미사용,1:사용)
end;

{ TBridgeRequest_402 }

procedure TBridgeRequest_402.ConvertJson(AJsonWriter: TGDJsonTextWriter);
begin
  inherited ConvertJson(AJsonWriter);

  with AJsonWriter do
  begin
    WriteValue(FN_HospitalNo, hospitalNo);
  end;
end;

{ TBridgeResponse_403 }

function TBridgeResponse_403.AnalysisJson(AJsonRoot: TJSONObject): Integer;
var
  i : Integer;
  ResultJson, datajson : TJSONObject;
  list : TJSONArray;
  item : TRoomListItem;
begin
  Result := inherited AnalysisJson( AJsonRoot );

  ResultJson := TJSONObject( FindObjectGDJson(AJsonRoot, FN_Result ) );

  { V4
  if ExistObjectGDJson( ResultJson, FN_CurrentLimit ) then
    FCurrentLimit := GetValueIntegerGDJson(ResultJson, FN_CurrentLimit) else Result := Result_필수항목누락;
  if ExistObjectGDJson( ResultJson, FN_CurrentOffset ) then
    FCurrentOffset := GetValueIntegerGDJson(ResultJson, FN_CurrentOffset) else Result := Result_필수항목누락;
  if ExistObjectGDJson( ResultJson, FN_TotalCount ) then
    FTotal := GetValueIntegerGDJson(ResultJson, FN_TotalCount) else Result := Result_필수항목누락;
  }
  FCurrentLimit := 100;
  FCurrentOffset := 0;
  FTotal := 0;

  list := TJSONArray( FindObjectGDJson(ResultJson, FN_Contents) );
  if not Assigned( list ) then
    exit;

  for i := 0 to list.Count -1 do
  begin
    datajson := TJSONObject( list.Items[ i ] );
    item := TRoomListItem.Create;

    if ExistObjectGDJson( datajson, FN_RoomCode ) then
      item.RoomCode := GetValueStringGDJson(datajson, FN_RoomCode) else Result := Result_필수항목누락;
    if ExistObjectGDJson( datajson, FN_RoomName ) then
      item.RoomName := GetValueStringGDJson(datajson, FN_RoomName) else Result := Result_필수항목누락;
    if ExistObjectGDJson( datajson, FN_DeptCode ) then
      item.DeptCode := GetValueStringGDJson(datajson, FN_DeptCode) else Result := Result_필수항목누락;
    if ExistObjectGDJson( datajson, FN_DeptName ) then
      item.DeptName := GetValueStringGDJson(datajson, FN_DeptName) else Result := Result_필수항목누락;
    if ExistObjectGDJson( datajson, FN_DoctorCode ) then
      item.DoctorCode := GetValueStringGDJson(datajson, FN_DoctorCode) else Result := Result_필수항목누락;
    if ExistObjectGDJson( datajson, FN_DoctorName ) then
      item.DoctorName := GetValueStringGDJson(datajson, FN_DoctorName) else Result := Result_필수항목누락;

    FRoomList.Add( item );

    if Result = Result_Success then
    begin // 필수 data 확인
      if (item.RoomCode = '') or (item.RoomName = '') or
         (item.DeptCode = '') or (item.DeptName = '') or
         (item.DoctorCode = '') or (item.DoctorName = '')
      then
          Result := Result_필수항목누락;
    end;
  end;
end;

constructor TBridgeResponse_403.Create(ABaseProtocol: TBridgeProtocol);
begin
  inherited;
  FRoomList := TObjectList.Create( true );
end;

destructor TBridgeResponse_403.Destroy;
begin
  FreeAndNil( FRoomList );
  inherited;
end;

function TBridgeResponse_403.GetRoomListCount: Integer;
begin
  Result := FRoomList.Count;
end;

function TBridgeResponse_403.GetRoomLists(index: Integer): TRoomListItem;
begin
  Result := TRoomListItem( FRoomList.Items[ index ] );
end;

{ TBridgeRequest_400 }

procedure TBridgeRequest_400.ConvertJson(AJsonWriter: TGDJsonTextWriter);
begin
  inherited ConvertJson(AJsonWriter);

  with AJsonWriter do
  begin
    WriteValue(FN_HospitalNo, hospitalNo);
    WriteValue(FN_StartDttm, MakeDateTime2DttmStr(StartDttm) );
    WriteValue(FN_EndDttm, MakeDateTime2DttmStr(EndDttm) );
    WriteValue(FN_LastChangeDttm, MakeDateTime2DttmStr(LastChangeDttm) );

    if ReceptnResveType <> '' then
      WriteValue(FN_ReceptnResveType, ReceptnResveType)
    else
      WriteValueNull(FN_ReceptnResveType);

    WriteValue(FN_MaxPageCount, Limit);
    WriteValue(FN_DataOffset, Offset);
  end;
end;

constructor TBridgeRequest_400.Create(AEventID: integer; AJobID: String);
begin
  inherited;
  ReceptnResveType :=  RRType_ALL;
  Limit := 50; // 페이지 당 갯수
  Offset := 0;  // 전체 중 몇번째 부터 인지 위치값
end;

{ TBridgeResponse_401 }

function TBridgeResponse_401.AnalysisJson(AJsonRoot: TJSONObject): Integer;
var
  i, i2 : Integer;
  resultjson, datajson, symptomsjson : TJSONObject;
  listJson : TJSONArray;
  item : TReceptionReservationListItem;
  listSymptoms : TJSONArray; // V4 진료항목 형식 수정
begin
  Result := inherited AnalysisJson( AJsonRoot );

  resultjson := FindObjectGDJson(AJsonRoot, FN_Result );
  if not Assigned( resultjson ) then
  begin
    Result := Result_필수항목누락;
    exit;
  end;

  {if ExistObjectGDJson( resultjson, FN_CurrentLimit ) then
    FCurrentLimit := GetValueIntegerGDJson(resultjson, FN_CurrentLimit) else Result := Result_필수항목누락;
  if ExistObjectGDJson( resultjson, FN_CurrentOffset ) then
    FCurrentOffset := GetValueIntegerGDJson(resultjson, FN_CurrentOffset) else Result := Result_필수항목누락;
  if ExistObjectGDJson( resultjson, FN_TotalCount ) then
    FTotalDataCount := GetValueIntegerGDJson(resultjson, FN_TotalCount) else Result := Result_필수항목누락;
    } // V4.
  FCurrentLimit := 100;
  FCurrentOffset := 0;
  FTotalDataCount := 0;

  listJson := TJSONArray( FindObjectGDJson(resultjson, FN_Contents) );
  if (not Assigned( listJson ) ) or (listJson.Count = 0) then
    exit;

  for i := 0 to listJson.Count -1 do
  begin
    datajson := TJSONObject( listJson.Items[ i ] );
    item := TReceptionReservationListItem.Create;

    with item do
    begin
      PatntChartId              := GetValueStringGDJson(datajson, FN_PatntChartId);
      PatntId                   := GetValueStringGDJson(datajson, FN_PatntId);
      PatntName                 := GetValueStringGDJson(datajson, FN_PatntName);
      chartReceptnResultId.Id1     := GetValueStringGDJson(datajson, FN_chartReceptnResultId1);
      chartReceptnResultId.Id2     := GetValueStringGDJson(datajson, FN_chartReceptnResultId2);
      chartReceptnResultId.Id3     := GetValueStringGDJson(datajson, FN_chartReceptnResultId3);
      chartReceptnResultId.Id4     := GetValueStringGDJson(datajson, FN_chartReceptnResultId4);
      chartReceptnResultId.Id5     := GetValueStringGDJson(datajson, FN_chartReceptnResultId5);
      chartReceptnResultId.Id6     := GetValueStringGDJson(datajson, FN_chartReceptnResultId6);
      Cellphone                 := GetValueStringGDJson(datajson, FN_CellPhone);
      RegNum                    := GetValueStringGDJson(datajson, FN_RegNum);

      Birthdy                   := GetValueStringGDJson(datajson, FN_Birthday);

      Sexdstn                   := GetValueStringGDJson(datajson, FN_Sexdstn);
      Addr                      := GetValueStringGDJson(datajson, FN_Addr);
      AddrDetail                := GetValueStringGDJson(datajson, FN_AddrDetail);
      Zip                       := GetValueStringGDJson(datajson, FN_Zip);
      InboundPath               := GetValueStringGDJson(datajson, FN_InboundPath);
      //Symptoms                  := GetValueStringGDJson(datajson, FN_Purpose);
      // V4 진료항목 데이터 형식 수정
      listSymptoms := TJSONArray( FindObjectGDJson(datajson, FN_Purpose) );
      if Assigned( listSymptoms ) and (listSymptoms.Count > 0) then
      begin
        for i2 := 0 to listSymptoms.Count - 1 do
        begin
          symptomsjson := TJSONObject( listSymptoms.Items[ i2 ] );
          if Symptoms.Length > 0 then
            Symptoms := Symptoms + '|';
          Symptoms := Symptoms + GetValueStringGDJson(symptomsjson, FN_Purpose1);
          if GetValueStringGDJson(symptomsjson, FN_Purpose2).Length > 0 then
            Symptoms := Symptoms + ',' + GetValueStringGDJson(symptomsjson, FN_Purpose2);
          if GetValueStringGDJson(symptomsjson, FN_Purpose3).Length > 0 then
            Symptoms := Symptoms + ',' + GetValueStringGDJson(symptomsjson, FN_Purpose3);
        end;
      end;

      RoomInfo.RoomCode         := GetValueStringGDJson(datajson, FN_RoomCode);
      RoomInfo.RoomName         := GetValueStringGDJson(datajson, FN_RoomName);
      RoomInfo.DeptCode         := GetValueStringGDJson(datajson, FN_DeptCode);
      RoomInfo.DeptName         := GetValueStringGDJson(datajson, FN_DeptName);
      RoomInfo.DoctorCode       := GetValueStringGDJson(datajson, FN_DoctorCode);
      RoomInfo.DoctorName       := GetValueStringGDJson(datajson, FN_DoctorName);
      Status                    := GetValueStringGDJson(datajson, FN_Status);
      DeviceType                := GetValueStringGDJson(datajson, FN_DeviceType);
      memo                      := GetValueStringGDJson(datajson, FN_Memo);
      CancelMessage             := GetValueStringGDJson(datajson, FN_CancelMessage);

      LastChangeDttm            := MakeDttmStr2DateTime( GetValueStringGDJson(datajson, FN_LastChangeDttm) );
      ReceptionDttm             := MakeDttmStr2DateTime( GetValueStringGDJson(datajson, FN_ReceptionDttm) );
      reserveDttm               := MakeDttmStr2DateTime( GetValueStringGDJson(datajson, FN_ReserveDttm) );
      hsptlReceptnDttm          := MakeDttmStr2DateTime( GetValueStringGDJson(datajson, FN_hsptlReceptnDttm) );
      {TODO 추후에 취소된 시간이 들어 올수 있게 시스템 개선이 필요하다. 서버와 브릿지도 수정 해야 한다.}
      CancelDttm                := LastChangeDttm;
      isFirst                   := GetValueBooleanGDJson(datajson, FN_isFirst); // 신규 여부

      ReceptnResveType          := GetValueStringGDJson(datajson, FN_ReceptnResveType);
    end;

    FRRList.Add( item );
  end;
end;

constructor TBridgeResponse_401.Create(ABaseProtocol: TBridgeProtocol);
begin
  inherited;
  FRRList := TObjectList.Create( true );
end;

destructor TBridgeResponse_401.Destroy;
begin
  FreeAndNil( FRRList );
  inherited;
end;

function TBridgeResponse_401.GetReceptionReservationCount: Integer;
begin
  Result := FRRList.Count;
end;

function TBridgeResponse_401.GetReceptionReservationLists(
  index: Integer): TReceptionReservationListItem;
begin
  Result := TReceptionReservationListItem( FRRList.Items[ index ] );
end;

{ TBridgeRequest_406 }

procedure TBridgeRequest_406.ConvertJson(AJsonWriter: TGDJsonTextWriter);
begin
  inherited ConvertJson(AJsonWriter);

  with AJsonWriter do
  begin
    WriteValue(FN_chartReceptnResultId1, chartReceptnResultId.Id1);
    WriteValue(FN_chartReceptnResultId2, chartReceptnResultId.Id2);
    WriteValue(FN_chartReceptnResultId3, chartReceptnResultId.Id3);
    WriteValue(FN_chartReceptnResultId4, chartReceptnResultId.Id4);
    WriteValue(FN_chartReceptnResultId5, chartReceptnResultId.Id5);
    WriteValue(FN_chartReceptnResultId6, chartReceptnResultId.Id6);
  end;
end;

constructor TBridgeRequest_406.Create(AEventID: integer; AJobID: String);
begin
  inherited;
end;

{ TBridgeResponse_407 }

function TBridgeResponse_407.AnalysisJson(AJsonRoot: TJSONObject): Integer;
var
  i, i2 : Integer;
  resultjson, datajson, symptomsjson : TJSONObject;
  listJson : TJSONArray;
  item : TReceptionReservationListItem;
  listSymptoms : TJSONArray; // V4 진료항목 형식 수정
begin
  Result := inherited AnalysisJson( AJsonRoot );

  resultjson := FindObjectGDJson(AJsonRoot, FN_Result );
  if not Assigned( resultjson ) then
  begin
    Result := Result_필수항목누락;
    exit;
  end;

  listJson := TJSONArray( FindObjectGDJson(resultjson, FN_Contents) );
  if (not Assigned( listJson ) ) or (listJson.Count = 0) then
    exit;

  for i := 0 to listJson.Count -1 do
  begin
    datajson := TJSONObject( listJson.Items[ i ] );
    item := TReceptionReservationListItem.Create;

    with item do
    begin
      PatntChartId              := GetValueStringGDJson(datajson, FN_PatntChartId);
      PatntId                   := GetValueStringGDJson(datajson, FN_PatntId);
      PatntName                 := GetValueStringGDJson(datajson, FN_PatntName);
      chartReceptnResultId.Id1     := GetValueStringGDJson(datajson, FN_chartReceptnResultId1);
      chartReceptnResultId.Id2     := GetValueStringGDJson(datajson, FN_chartReceptnResultId2);
      chartReceptnResultId.Id3     := GetValueStringGDJson(datajson, FN_chartReceptnResultId3);
      chartReceptnResultId.Id4     := GetValueStringGDJson(datajson, FN_chartReceptnResultId4);
      chartReceptnResultId.Id5     := GetValueStringGDJson(datajson, FN_chartReceptnResultId5);
      chartReceptnResultId.Id6     := GetValueStringGDJson(datajson, FN_chartReceptnResultId6);
      Cellphone                 := GetValueStringGDJson(datajson, FN_CellPhone);
      RegNum                    := GetValueStringGDJson(datajson, FN_RegNum);

      Birthdy                   := GetValueStringGDJson(datajson, FN_Birthday);

      Sexdstn                   := GetValueStringGDJson(datajson, FN_Sexdstn);
      Addr                      := GetValueStringGDJson(datajson, FN_Addr);
      AddrDetail                := GetValueStringGDJson(datajson, FN_AddrDetail);
      Zip                       := GetValueStringGDJson(datajson, FN_Zip);
      InboundPath               := GetValueStringGDJson(datajson, FN_InboundPath);
      //Symptoms                  := GetValueStringGDJson(datajson, FN_Purpose);
      // V4 진료항목 데이터 형식 수정
      listSymptoms := TJSONArray( FindObjectGDJson(datajson, FN_Purpose) );
      if Assigned( listSymptoms ) and (listSymptoms.Count > 0) then
      begin
        for i2 := 0 to listSymptoms.Count - 1 do
        begin
          symptomsjson := TJSONObject( listSymptoms.Items[ i2 ] );
          if Symptoms.Length > 0 then
            Symptoms := Symptoms + '|';
          Symptoms := Symptoms + GetValueStringGDJson(symptomsjson, FN_Purpose1);
          if GetValueStringGDJson(symptomsjson, FN_Purpose2).Length > 0 then
            Symptoms := Symptoms + ',' + GetValueStringGDJson(symptomsjson, FN_Purpose2);
          if GetValueStringGDJson(symptomsjson, FN_Purpose3).Length > 0 then
            Symptoms := Symptoms + ',' + GetValueStringGDJson(symptomsjson, FN_Purpose3);
        end;
      end;

      RoomInfo.RoomCode         := GetValueStringGDJson(datajson, FN_RoomCode);
      RoomInfo.RoomName         := GetValueStringGDJson(datajson, FN_RoomName);
      RoomInfo.DeptCode         := GetValueStringGDJson(datajson, FN_DeptCode);
      RoomInfo.DeptName         := GetValueStringGDJson(datajson, FN_DeptName);
      RoomInfo.DoctorCode       := GetValueStringGDJson(datajson, FN_DoctorCode);
      RoomInfo.DoctorName       := GetValueStringGDJson(datajson, FN_DoctorName);
      Status                    := GetValueStringGDJson(datajson, FN_Status);
      DeviceType                := GetValueStringGDJson(datajson, FN_DeviceType);
      memo                      := GetValueStringGDJson(datajson, FN_Memo);
      CancelMessage             := GetValueStringGDJson(datajson, FN_CancelMessage);

      LastChangeDttm            := MakeDttmStr2DateTime( GetValueStringGDJson(datajson, FN_LastChangeDttm) );
      ReceptionDttm             := MakeDttmStr2DateTime( GetValueStringGDJson(datajson, FN_ReceptionDttm) );
      reserveDttm               := MakeDttmStr2DateTime( GetValueStringGDJson(datajson, FN_ReserveDttm) );
      hsptlReceptnDttm          := MakeDttmStr2DateTime( GetValueStringGDJson(datajson, FN_hsptlReceptnDttm) );
      {TODO 추후에 취소된 시간이 들어 올수 있게 시스템 개선이 필요하다. 서버와 브릿지도 수정 해야 한다.}
      CancelDttm                := LastChangeDttm;
      isFirst                   := GetValueBooleanGDJson(datajson, FN_isFirst); // 신규 여부

      ReceptnResveType          := GetValueStringGDJson(datajson, FN_ReceptnResveType);
    end;

    FRRList.Add( item );
  end;
end;

constructor TBridgeResponse_407.Create(ABaseProtocol: TBridgeProtocol);
begin
  inherited;
  FRRList := TObjectList.Create( true );
end;

destructor TBridgeResponse_407.Destroy;
begin
  FreeAndNil( FRRList );
  inherited;
end;

function TBridgeResponse_407.GetReceptionReservationItem : TReceptionReservationListItem;
begin
  Result := nil;
  if FRRList.Count = 0 then
    exit;

  Result := TReceptionReservationListItem( FRRList.Items[0] );
end;

{ TBridgeResponse_110 }

function TBridgeResponse_110.AnalysisJson(AJsonRoot: TJSONObject): Integer;
var
  i : Integer;
  ResultJson, datajson : TJSONObject;
  List : TJSONArray;
  item : TconfirmListItem;
begin
//  inherited AnalysisJson( AJsonRoot );
  Result := Result_Success;
  ResultJson := AJsonRoot;

  if ExistObjectGDJson( ResultJson, FN_HospitalNo ) then
    FHospitalNo := GetValueStringGDJson(ResultJson, FN_HospitalNo) else Result := Result_필수항목누락;

  if ExistObjectGDJson( ResultJson, FN_reclnicOnly ) then
    FreclnicOnly := GetValueIntegerGDJson(ResultJson, FN_reclnicOnly) else Result := Result_필수항목누락;

  if not ExistObjectGDJson( ResultJson, FN_ConfirmList ) then
  begin
    Result := Result_필수항목누락;
    exit;
  end;

  List := TJSONArray( FindObjectGDJson(ResultJson, FN_ConfirmList) );
  if List.Count <= 0 then
  begin
    Result := Result_필수항목누락;
    exit;
  end;

  for i := 0 to List.Count -1 do
  begin
    datajson := TJSONObject( List.Items[ i ] );
    item := TconfirmListItem.Create;
    with item do
    begin
      if ExistObjectGDJson( datajson, FN_chartReceptnResultId1 ) then
        chartReceptnResult.Id1 := GetValueStringGDJson(datajson, FN_chartReceptnResultId1) else Result := Result_필수항목누락;
      chartReceptnResult.Id2 := GetValueStringGDJson(datajson, FN_chartReceptnResultId2);
      chartReceptnResult.Id3 := GetValueStringGDJson(datajson, FN_chartReceptnResultId3);
      chartReceptnResult.Id4 := GetValueStringGDJson(datajson, FN_chartReceptnResultId4);
      chartReceptnResult.Id5 := GetValueStringGDJson(datajson, FN_chartReceptnResultId5);
      chartReceptnResult.Id6 := GetValueStringGDJson(datajson, FN_chartReceptnResultId6);

      receptnResveId := GetValueStringGDJson(datajson, FN_receptnResveId);
      if receptnResveId = '' then
        Result := Result_필수항목누락;

      if not ExistObjectGDJson(datajson, 'type') then
        Result := Result_필수항목누락;

      receptnResveType := GetValueIntegerGDJson(datajson, 'type'); // 0:예약, 1:접수
    end;
    FconfirmList.Add( item );
  end;
end;

constructor TBridgeResponse_110.Create(ABaseProtocol: TBridgeProtocol);
begin
  inherited;
  FconfirmList := TObjectList.Create( True );
end;

destructor TBridgeResponse_110.Destroy;
begin
  Freeandnil( FconfirmList );
  inherited;
end;

function TBridgeResponse_110.GetconfirmList(AIndex: integer): TconfirmListItem;
begin
  Result := nil;
  if AIndex >= FconfirmList.Count then
    exit;
  Result := TconfirmListItem( FconfirmList.Items[AIndex] );
end;

function TBridgeResponse_110.GetCount: integer;
begin
  Result := FconfirmList.Count;
end;

{ TBridgeRequest_111 }


function TBridgeRequest_111.Add(AchartReceptnResultId1, AchartReceptnResultId2,
  AchartReceptnResultId3, AchartReceptnResultId4, AchartReceptnResultId5,
  AchartReceptnResultId6, AreceptnResveId: string; ADataRRType,
  AconfirmResult: Integer): Integer;
var
  data : TconfirmResultListItem;
begin
  data := TconfirmResultListItem.Create;
  with data do
  begin
    chartReceptnResult.ID1 := AchartReceptnResultId1;
    chartReceptnResult.ID2 := AchartReceptnResultId2;
    chartReceptnResult.ID3 := AchartReceptnResultId3;
    chartReceptnResult.ID4 := AchartReceptnResultId4;
    chartReceptnResult.ID5 := AchartReceptnResultId5;
    chartReceptnResult.ID6 := AchartReceptnResultId6;

    receptnResveId := AreceptnResveId;
    receptnResveType := ADataRRType;
    confirmResult := AconfirmResult;
  end;
  Result := FconfirmResultList.Add( data );
end;

procedure TBridgeRequest_111.AddResultJson(
  AResultJsonWriter: TGDJsonTextWriter);
var
  i : Integer;
  data : TconfirmResultListItem;
begin
  inherited AddResultJson( AResultJsonWriter );

  with AResultJsonWriter do
  begin
    WriteValue(FN_HospitalNo, HospitalNo);
    WriteValue(FN_isFirst, isFirst);

    StartArray( FN_ConfirmResultList );
    try
      for i := 0 to FconfirmResultList.Count -1 do
      begin
        data := TconfirmResultListItem( FconfirmResultList.Items[i] );
        StartObject;
          WriteValue(FN_chartReceptnResultId1, data.chartReceptnResult.ID1);
          WriteValue(FN_chartReceptnResultId2, data.chartReceptnResult.ID2);
          WriteValue(FN_chartReceptnResultId3, data.chartReceptnResult.ID3);
          WriteValue(FN_chartReceptnResultId4, data.chartReceptnResult.ID4);
          WriteValue(FN_chartReceptnResultId5, data.chartReceptnResult.ID5);
          WriteValue(FN_chartReceptnResultId6, data.chartReceptnResult.ID6);

          WriteValue(FN_receptnResveId, data.receptnResveId);
          WriteValue('type', data.receptnResveType);
          WriteValue(FN_ConfirmResult, data.confirmResult);
        EndObject;
      end;
    finally
      EndArray;
    end;
  end;
end;

constructor TBridgeRequest_111.Create(AEventID: integer; AJobID: String);
begin
  inherited;
  isFirst := 0; // 신규 환자
  FconfirmResultList := TObjectList.Create( true );
end;

destructor TBridgeRequest_111.Destroy;
begin
  Freeandnil( FconfirmResultList );
  inherited;
end;

{ TReceptionReservationListItem }

function TReceptionReservationListItem.GetisMale: Boolean;
var
  s : Integer;
begin
  s := StrToIntDef(Sexdstn, 1);
  Result := s in [1, 3, 5, 7, 9];
end;



{ TBridgeRequest_306 }

procedure TBridgeRequest_306.ConvertJson(AJsonWriter: TGDJsonTextWriter);
begin
  inherited ConvertJson(AJsonWriter);

  with AJsonWriter do
  begin
    WriteValue(FN_HospitalNo, hospitalNo);

    WriteValue(FN_MaxPageCount, limit);
    WriteValue(FN_DataOffset, offset);
  end;
end;

constructor TBridgeRequest_306.Create(AEventID: integer; AJobID: String);
begin
  inherited Create(AEventID, AJobID);
  limit := 20;
  offset := 0;
end;

{ TBridgeResponse_307 }

function TBridgeResponse_307.AnalysisJson(AJsonRoot: TJSONObject): Integer;
var
  i, ret : Integer;
  ResultJson, datajson : TJSONObject;
  listJson : TJSONArray;
  item : TData307;
begin
  Result := inherited AnalysisJson( AJsonRoot );

  ResultJson := TJSONObject( FindObjectGDJson(AJsonRoot, FN_Result ) );

  if ExistObjectGDJson( ResultJson, FN_CurrentLimit ) then
    FCurrentLimit := GetValueIntegerGDJson(ResultJson, FN_CurrentLimit) else Result := Result_필수항목누락;
  if ExistObjectGDJson( ResultJson, FN_CurrentOffset ) then
    FCurrentOffset := GetValueIntegerGDJson(ResultJson, FN_CurrentOffset) else Result := Result_필수항목누락;
  if ExistObjectGDJson( ResultJson, FN_TotalCount ) then
    FTotal := GetValueIntegerGDJson(ResultJson, FN_TotalCount) else Result := Result_필수항목누락;

  listJson := TJSONArray( TJSONObject( FindObjectGDJson(ResultJson, FN_Contents ) ) );
  if not Assigned( listJson ) then
  begin
    Result := Result_필수항목누락;
    exit;
  end;

  for i := 0 to listJson.Count -1 do
  begin
    datajson := TJSONObject( listJson.Items[ i ] );
    if not Assigned( datajson ) then
      continue;

    item := TData307.Create;
    ret := item.AnalysisJson( datajson );
    FList.Add( item );
    if ret <> Result_Success then
      Result := ret;
  end;
end;

constructor TBridgeResponse_307.Create(ABaseProtocol: TBridgeProtocol);
begin
  inherited Create(ABaseProtocol);

  FList := TObjectList.Create( true );
end;

destructor TBridgeResponse_307.Destroy;
begin
  Freeandnil( FList );
  inherited;
end;

function TBridgeResponse_307.GetDataList(index: Integer): TData307;
begin
  Result := TData307( FList.Items[index] );
end;

function TBridgeResponse_307.GetDataListCount: Integer;
begin
  Result := FList.Count;
end;

{ TData307 }

function TData307.AnalysisJson(AJsonRoot: TJSONObject): Integer;
var
  i : Integer;
  ResultJson, datajson : TJSONObject;
  purposelistjson : TJSONArray;
  item : TPurposeListItem;
begin
  Result := Result_Success;
  ResultJson := AJsonRoot;

  HospitalNO := GetValueStringGDJson(ResultJson, FN_HospitalNo);
  PatntChartId := GetValueStringGDJson(ResultJson, FN_PatntChartId);

  chartReceptnResultId.Id1 := GetValueStringGDJson(ResultJson, FN_chartReceptnResultId1);
  chartReceptnResultId.Id2 := GetValueStringGDJson(ResultJson, FN_chartReceptnResultId2);
  chartReceptnResultId.Id3 := GetValueStringGDJson(ResultJson, FN_chartReceptnResultId3);
  chartReceptnResultId.Id4 := GetValueStringGDJson(ResultJson, FN_chartReceptnResultId4);
  chartReceptnResultId.Id5 := GetValueStringGDJson(ResultJson, FN_chartReceptnResultId5);
  chartReceptnResultId.Id6 := GetValueStringGDJson(ResultJson, FN_chartReceptnResultId6);

  if ExistObjectGDJson( ResultJson, FN_EventID ) then
    EventID := GetValueIntegerGDJson(ResultJson, FN_EventID) else Result := Result_필수항목누락;

  PatntName := GetValueStringGDJson(ResultJson, FN_PatntName);
  cellphone := GetValueStringGDJson(ResultJson, FN_CellPhone);
  EndPoint := GetValueStringGDJson(ResultJson, FN_EndPoint);

  Gdid := GetValueStringGDJson(ResultJson, FN_gdid);

  regNum := GetValueStringGDJson(ResultJson, FN_RegNum);
  Sexdstn := GetValueStringGDJson(ResultJson, FN_Sexdstn);
  Birthday := GetValueStringGDJson(ResultJson, FN_Birthday);
  Addr := GetValueStringGDJson(ResultJson, FN_Addr);
  AddrDetail := GetValueStringGDJson(ResultJson, FN_AddrDetail);
  Zip := GetValueStringGDJson(ResultJson, FN_Zip);

  if ExistObjectGDJson( ResultJson, FN_RoomCode ) then
    RoomInfo.RoomCode := GetValueStringGDJson(ResultJson, FN_RoomCode) else Result := Result_필수항목누락;
  if ExistObjectGDJson( ResultJson, FN_RoomName ) then
    RoomInfo.RoomName := GetValueStringGDJson(ResultJson, FN_RoomName) else Result := Result_필수항목누락;
  if ExistObjectGDJson( ResultJson, FN_DeptCode ) then
    RoomInfo.DeptCode := GetValueStringGDJson(ResultJson, FN_DeptCode) else Result := Result_필수항목누락;
  if ExistObjectGDJson( ResultJson, FN_DeptName ) then
    RoomInfo.DeptName := GetValueStringGDJson(ResultJson, FN_DeptName) else Result := Result_필수항목누락;
  if ExistObjectGDJson( ResultJson, FN_doctorCode ) then
    RoomInfo.DoctorCode := GetValueStringGDJson(ResultJson, FN_doctorCode) else Result := Result_필수항목누락;
  if ExistObjectGDJson( ResultJson, FN_doctorName ) then
    RoomInfo.DoctorName := GetValueStringGDJson(ResultJson, FN_DoctorName) else Result := Result_필수항목누락;

  EtcPurpose := GetValueStringGDJson(ResultJson, FN_EtcPurpose);

  ReceptionDttm := 0;
  if ExistObjectGDJson( ResultJson, FN_ReceptionDttm ) then
    ReceptionDttm := MakeDttmStr2DateTime( GetValueStringGDJson(ResultJson, FN_ReceptionDttm) );
  InboundPath := GetValueStringGDJson(ResultJson, FN_InboundPath);

  if ExistObjectGDJson( ResultJson, FN_EventID ) then
    receptnResveId := GetValueStringGDJson(ResultJson, FN_receptnResveId) else Result := Result_필수항목누락;

  ReserveDttm := 0;
  if ExistObjectGDJson( ResultJson, FN_ReserveDttm ) then
    ReserveDttm := MakeDttmStr2DateTime( GetValueStringGDJson(ResultJson, FN_ReserveDttm) );

  purposelistjson := TJSONArray( FindObjectGDJson(ResultJson, FN_PurposeList) );
  if Assigned(purposelistjson) and ( purposelistjson.Count > 0 ) then
  begin
    for i := 0 to purposelistjson.Count-1 do
    begin
      datajson := TJSONObject( purposelistjson.Items[ i ] );
      item := TPurposeListItem.Create;
      item.purpose1 := GetValueStringGDJson(datajson, FN_Purpose1);
      item.purpose2 := GetValueStringGDJson(datajson, FN_Purpose2);
      item.purpose3 := GetValueStringGDJson(datajson, FN_Purpose3);
      FPurposeList.Add( item );
    end;
  end;
end;

constructor TData307.Create;
begin
  inherited;
  FPurposeList := TObjectList.Create( True );
end;

destructor TData307.Destroy;
begin
  Freeandnil( FPurposeList );
  inherited;
end;

function TData307.GetPurposeListCount: Integer;
begin
  Result := FPurposeList.Count;
end;

function TData307.GetPurposeLists(index: integer): TPurposeListItem;
begin
  Result := TPurposeListItem( FPurposeList.Items[ index ] );
end;

{ TBridgeRequest_308 }

function TBridgeRequest_308.Add(AchartReceptnResultId1, AchartReceptnResultId2,
  AchartReceptnResultId3, AchartReceptnResultId4, AchartReceptnResultId5,
  AchartReceptnResultId6, AreceptnResveId: string; APatntChartID : string ): Integer;
var
  data : TreceiveOkListItem;
begin
  data := TreceiveOkListItem.Create;
  with data do
  begin
    chartReceptnResult.ID1 := AchartReceptnResultId1;
    chartReceptnResult.ID2 := AchartReceptnResultId2;
    chartReceptnResult.ID3 := AchartReceptnResultId3;
    chartReceptnResult.ID4 := AchartReceptnResultId4;
    chartReceptnResult.ID5 := AchartReceptnResultId5;
    chartReceptnResult.ID6 := AchartReceptnResultId6;

    receptnResveId := AreceptnResveId;
    patntChartId := APatntChartID;
  end;
  Result := FreceiveOkList.Add( data );
end;

procedure TBridgeRequest_308.ConvertJson(AJsonWriter: TGDJsonTextWriter);
var
  i : Integer;
  data : TreceiveOkListItem;

begin
  inherited ConvertJson(AJsonWriter);

  with AJsonWriter do
  begin
     AJsonWriter.WriteValue(FN_HospitalNo, HospitalNo);
    StartArray( FN_receiveOkList );
    try
      for i := 0 to FreceiveOkList.Count -1 do
      begin
        data := TreceiveOkListItem( FreceiveOkList.Items[i] );
        StartObject;
          WriteValue(FN_chartReceptnResultId1, data.chartReceptnResult.ID1);
          WriteValue(FN_chartReceptnResultId2, data.chartReceptnResult.ID2);
          WriteValue(FN_chartReceptnResultId3, data.chartReceptnResult.ID3);
          WriteValue(FN_chartReceptnResultId4, data.chartReceptnResult.ID4);
          WriteValue(FN_chartReceptnResultId5, data.chartReceptnResult.ID5);
          WriteValue(FN_chartReceptnResultId6, data.chartReceptnResult.ID6);

          WriteValue(FN_receptnResveId, data.receptnResveId);
          WriteValue(FN_PatntChartId, data.patntChartId);
        EndObject;
      end;
    finally
      EndArray;
    end;
  end;
end;

constructor TBridgeRequest_308.Create(AEventID: integer; AJobID: String);
begin
  inherited;
  FreceiveOkList := TObjectList.Create( true );
end;

destructor TBridgeRequest_308.Destroy;
begin
  FreeAndNil( FreceiveOkList );
  inherited;
end;

{ TBridgeRequest_404 }

procedure TBridgeRequest_404.ConvertJson(AJsonWriter: TGDJsonTextWriter);
begin
  inherited ConvertJson(AJsonWriter);

  with AJsonWriter do
  begin
    WriteValue(FN_HospitalNo, hospitalNo);

    //WriteValue(FN_PatntChartId, patntChartId); // V4. patientChartId 대신 patientId 사용
    WriteValue(FN_PatntId, patntId);

    //if (oldName <> '') and (newName <> '') then
    //begin
      WriteValue(FN_oldName, oldName);
      WriteValue(FN_newName, newName);
    //end;

    //if (oldPhone <> '') and (newPhone <> '') then
    //begin
      WriteValue(FN_oldPhone, oldPhone);
      WriteValue(FN_newPhone, newPhone);
    //end;
  end;
end;

{ TBridgeResponse_405 }

function TBridgeResponse_405.AnalysisJson(AJsonRoot: TJSONObject): Integer;
var
  nullcheck : Boolean;
  ResultJson : TJSONObject;
begin
  Result := inherited AnalysisJson( AJsonRoot );

  // V4. result 값 없음.
  //ResultJson := TJSONObject( FindObjectGDJson(AJsonRoot, FN_Result ) );

  //nullcheck := TJSONValue(ResultJson).Null;
  //if nullcheck then
  //  exit;

  //FpatntChartId := GetValueStringGDJson(ResultJson, FN_PatntChartId);
  //FnewName := GetValueStringGDJson(ResultJson, FN_newName);
  //FnewPhone := GetValueStringGDJson(ResultJson, FN_newPhone);
  FpatntChartId := '';
  FnewName := '';
  FnewPhone := '';
end;

constructor TBridgeResponse_405.Create(ABaseProtocol: TBridgeProtocol);
begin
  inherited;

end;

destructor TBridgeResponse_405.Destroy;
begin

  inherited;
end;

{ TBridgeRequest_410 }

procedure TBridgeRequest_410.ConvertJson(AJsonWriter: TGDJsonTextWriter);
begin
  inherited ConvertJson(AJsonWriter);

  with AJsonWriter do
  begin
    WriteValue(FN_PatntId, patntId);
  end;
end;

{ TBridgeResponse_411 }

function TBridgeResponse_411.AnalysisJson(AJsonRoot: TJSONObject) : Integer;
begin
  Result := inherited AnalysisJson( AJsonRoot );

  FRegNum := GetValueStringGDJson(AJsonRoot, FN_RegNum);
end;

constructor TBridgeResponse_411.Create(ABaseProtocol: TBridgeProtocol);
begin
  inherited;
end;

destructor TBridgeResponse_411.Destroy;
begin
  inherited;
end;

{ TBridgeResponse_420 }
function TBridgeResponse_420.AnalysisJson(AJsonRoot: TJSONObject) : Integer;
var
  ResultJson : TJSONObject;
begin
  Result := inherited AnalysisJson( AJsonRoot );
  ResultJson := AJsonRoot;

  if ExistObjectGDJson( ResultJson, FN_chartReceptnResultId1 ) then
    FchartReceptnResultId.Id1 := GetValueStringGDJson(ResultJson, FN_chartReceptnResultId1)
  else
    Result := Result_필수항목누락;
  FchartReceptnResultId.Id2 := GetValueStringGDJson(ResultJson, FN_chartReceptnResultId2);
  FchartReceptnResultId.Id3 := GetValueStringGDJson(ResultJson, FN_chartReceptnResultId3);
  FchartReceptnResultId.Id4 := GetValueStringGDJson(ResultJson, FN_chartReceptnResultId4);
  FchartReceptnResultId.Id5 := GetValueStringGDJson(ResultJson, FN_chartReceptnResultId5);
  FchartReceptnResultId.Id6 := GetValueStringGDJson(ResultJson, FN_chartReceptnResultId6);
end;

constructor TBridgeResponse_420.Create(ABaseProtocol: TBridgeProtocol);
begin
  inherited;
end;

destructor TBridgeResponse_420.Destroy;
begin
  inherited;
end;

{ TBridgeRequest_421 }

procedure TBridgeRequest_421.ConvertJson(AJsonWriter: TGDJsonTextWriter);
begin
  inherited ConvertJson(AJsonWriter);
end;

{ TBridgeRequest_2006 }

procedure TBridgeRequest_2006.ConvertJson(AJsonWriter: TGDJsonTextWriter);
var
  i : integer;
  data : TReservationScheduleDto;
begin
  inherited ConvertJson(AJsonWriter);

  with AJsonWriter do
  begin
    WriteValue(FN_RoomCode, RoomCode);
    WriteValue(FN_DeptCode, DeptCode);

    StartArray( FN_reservationScheduleItemList );
    try
      for i := 0 to ItemCount -1 do
      begin
        data := TReservationScheduleDto( Item[i] );
        StartObject;
          WriteValue(FN_reservationScheduleDateTimeFormat, data.kst_schedule);
          WriteValue(FN_reservationScheduleReserved, data.used);
        EndObject;
      end;
    finally
      EndArray;
    end;
  end;
end;

constructor TBridgeRequest_2006.Create(AEventID: integer; AJobID: String);
begin
  inherited;
  FItems := TObjectList.Create( True );
end;

destructor TBridgeRequest_2006.Destroy;
begin
  FreeAndNil(FItems);
  inherited;
end;

procedure TBridgeRequest_2006.AddItem(datetime: string; reserved: Boolean);
var
  dto : TReservationScheduleDto;
begin
  dto := TReservationScheduleDto.Create;
  dto.kst_schedule := datetime;
  dto.used := reserved;

  FItems.Add(dto);
end;

function TBridgeRequest_2006.GetItem(index: Integer) : TReservationScheduleDto;
begin
  Result := TReservationScheduleDto( FItems.Items[index] );
end;

function TBridgeRequest_2006.GetItemCount : Integer;
begin
  Result := FItems.Count;
end;

{ TBridgeResponse_2007 (equal to base) }


initialization
  GBridgeFactory := nil;
finalization
  if Assigned( GBridgeFactory ) then
    FreeAndNil( GBridgeFactory );

end.
