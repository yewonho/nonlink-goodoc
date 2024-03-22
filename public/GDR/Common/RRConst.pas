unit RRConst;

interface
const
  Const_Char_Arrow_UPDown   = '↕';
  Const_Char_Arrow_UP       = '↑';
  Const_Char_Arrow_Down     = '↓';

const // listgrid관련
  Col_Index_Data = 1;

const // sort
  Sort_Name_Ascending   = 1;
  Sort_Name_Descending  = 2;
  Sort_Time_Ascending   = 3;
  Sort_time_Descending  = 4;
  Sort_Room_Ascending   = 5;
  Sort_Room_Descending  = 6;

const  // button tag
  Index_tag_확정     = 1;
  Index_tag_진료완료 = 2;
  Index_tag_내원요청 = 3;
  Index_tag_내원확인 = 4;

const  // 출력 cell의 width
  Col_Width_State       = 40; // 상태(수단)
  Col_Width_isFirst     = 70; // 환자유형
  Col_Width_PatientName = 90; // 이름
  Col_Width_Room        = 100; // 진료실
  Col_Width_BirthDay    = 105; // 생일(주민)
  Col_Width_Time        = 90; // 예약/접수 (요청) 시간
  Col_Width_Button1     = 40; // 1번 버튼(확정버튼)
  Col_Width_Button2     = 36; // 2번 버튼
  Col_Width_Symptom     = 80; // 내원목적


const  // 출력 cell의 width(예약/접수 목록)
  Col_Width_State_RR        = 40; // 상태(수단)
  Col_Width_isFirst_RR      = 70; // 환자유형
  Col_Width_PatientName_RR  = 90; // 이름
  Col_Width_Room_RR         = 100; // 진료실
  Col_Width_BirthDay_RR     = 105; // 생일 (주민)
  Col_Width_Time_RR         = 90; // 예약/접수 (요청) 시간
  Col_Width_Time2_RR        = 90; // 예약 시간
  Col_Width_Button1_RR      = 40; // 1번 버튼(확정버튼)
  Col_Width_Button2_RR      = 36; // 2번 버튼
  Col_Width_Symptom_RR      = 80; // 내원목적



const  // 출력 cell의 width (예약목록)
  Col_Width_State_R       = 40; // 상태
  Col_Width_PatientName_R = 70; // 이름
  Col_Width_Room_R        = 90; // 진료실
  Col_Width_BirthDay_R    = 100; // 생일
  Col_Width_Time_R        = 90; // 예약/접수 (요청) 시간
  Col_Width_Time2_R       = 90; // 예약 시간
  Col_Width_Button1_R     = 36; // 1번 버튼
  Col_Width_Button2_R     = 36; // 2번 버튼

const // 출력되는 grid별 ID
  Grid_Information_RnR_ID           = 'RnR'; // 홈/요청 grid
  Grid_Information_Reception_ID     = 'Reception'; // 홈/접수 grid
  Grid_Information_Reservation_ID   = 'Reservation'; // 홈/예약 grid

  Grid_Information_ReservationMonthReq_ID     = 'ReservationMonthReq'; // 일/예약요청 grid
  Grid_Information_ReservationMonth_ID        = 'ReservationMonth'; // 일/예약확정 grid

  Grid_Information_ReservationListReq_ID     = 'ReservationListReq'; // 월/예약요청 grid
  Grid_Information_ReservationList_ID        = 'ReservationList'; // 월/예약확정 grid

type
  THookOCSType = (
    None,
    YSR,
    IPro,
    Dentweb,
    Hanaro
    );

const
  HookOCSNames : array [THookOCSType] of string = (
    '없음',
    '의사랑',
    '아이프로(덴탑)',
    '덴트웹',
    '하나로'
  );

implementation

end.
