unit EventIDConst;

interface
const
  OB_Event_LoginOk                    = 1;
  OB_Event_LogoutOk                   = OB_Event_LoginOk + 1;

  OB_Event_Env_Change                 = OB_Event_LogoutOk + 1; // 환경 변수 변경됨

  OB_Event_1_1_Chat                   = OB_Event_Env_Change + 1; // 1:1 채팅
  OB_Event_UserMenualDownLoad         = OB_Event_1_1_Chat + 1; // 사용자 메뉴얼 download

  OB_Event_Show_일                    = OB_Event_UserMenualDownLoad + 1; // 일 화면 이동
  OB_Event_Show_월                    = OB_Event_Show_일 + 1;  // 월 화면 이동
  OB_Event_Show_월_List               = OB_Event_Show_월 + 1;  //월 list 화면 이동

  OB_Event_DataRefresh                = OB_Event_Show_월_List + 1; // data가 갱신 되었으니 화면을 refresh하게 한다.
  OB_Event_DataRefresh_RR             = OB_Event_DataRefresh + 1; // 접수/예약 목록을 refresh한다.
  OB_Event_DataRefresh_Reception      = OB_Event_DataRefresh_RR + 1; // 접수 목록을 refresh
  OB_Event_DataRefresh_Reservation    = OB_Event_DataRefresh_Reception + 1; // 예약 목록을 refresh
  OB_Event_DataRefresh_DataReload     = OB_Event_DataRefresh_Reservation + 1; //  일 단위 list data refresh
  OB_Event_DataRefresh_Notify         = OB_Event_DataRefresh_DataReload + 1; // 예약/접수 미처리 count notify

  OB_Event_ExpandCollapse_RnR         = OB_Event_DataRefresh_Notify + 1; // 접수/예약 창 접었다/폈다
  OB_Event_ExpandCollapse_Reception   = OB_Event_ExpandCollapse_RnR + 1; // 접수 창 접었다/폈다
  OB_Event_ExpandCollapse_Reservation = OB_Event_ExpandCollapse_Reception + 1; // 예약 창 접었다/폈다

  OB_Event_DataRefresh_Month          = OB_Event_ExpandCollapse_Reservation + 1; //  월 단위 data refresh
  OB_Event_DataRefresh_Month_List     = OB_Event_DataRefresh_Month + 1; //  월 단위 data 목록을 refresh
  OB_Event_DataRefresh_Month_ProcessList  = OB_Event_DataRefresh_Month_List + 1; //  월 단위 data 목록을 refresh
  OB_Event_DataRefresh_Month_RequestList  = OB_Event_DataRefresh_Month_ProcessList + 1; //  월 단위 요청 목록 data 목록을 refresh
  OB_Event_DataRefresh_Month_DataReload   = OB_Event_DataRefresh_Month_RequestList + 1; //  월 단위 list data refresh(일 메뉴)

  OB_Event_ExpandCollapse_RR_MonthList  = OB_Event_DataRefresh_Month_DataReload + 1; // 일 예약 요청 창 접었다/폈다
  OB_Event_ExpandCollapse_R_Reception   = OB_Event_ExpandCollapse_RR_MonthList + 1; // 일 예약 창 접었다/폈다


  OB_Event_DataRefresh_Month2          = OB_Event_ExpandCollapse_R_Reception + 1; //  월 단위 list data refresh
  OB_Event_DataRefresh_Month2_List     = OB_Event_DataRefresh_Month2 + 1; //  월 단위 list data 목록을 refresh
  OB_Event_DataRefresh_Month2_ProcessList   = OB_Event_DataRefresh_Month2_List + 1; //  월 단위 list data 목록을 refresh
  OB_Event_DataRefresh_Month2_RequestList   = OB_Event_DataRefresh_Month2_ProcessList + 1; //  월 단위 요청 목록 list data 목록을 refresh
  OB_Event_DataRefresh_Month2_DataReload    = OB_Event_DataRefresh_Month2_RequestList + 1; // 서버에서 data를 다시 받아 와서 출력 하게 한다.(월 메뉴)

  OB_Event_ExpandCollapse_RR_List  = OB_Event_DataRefresh_Month2_DataReload + 1; // 월 예약 list 요청 창 접었다/폈다
  OB_Event_ExpandCollapse_RR_RequestReservationList   = OB_Event_ExpandCollapse_RR_List + 1; // 월 예약 list 창 접었다/폈다

  OB_Event_RoomInfo_Change              = OB_Event_ExpandCollapse_RR_RequestReservationList + 1; // room info 정보가 변경 됬다.

  OB_Event_400FireOff                   = OB_Event_RoomInfo_Change + 1; // event 400, polling 중지
  OB_Event_400FireOn                    = OB_Event_400FireOff + 1;      // event 400, polling 시작

  OB_Event_Reload_RoomInfo              = OB_Event_400FireOn + 1; // 진료실 목록을 서버에서 다시 받아 온다.
  OB_Event_Reload_CancelMessage         = OB_Event_Reload_RoomInfo + 1; // 취소 메시지 목록을 서버에서 다시 받아 온다.

  OB_Event_Init_ExpandCollapse          = OB_Event_Reload_CancelMessage + 1; // 접기/펴기 버튼 초기값 설정

  OB_Event_Hook_Check                   = OB_Event_Init_ExpandCollapse +1; //후킹 체크(덴탑 덴트웹 제외)
  OB_Event_Hook_Check_all               = OB_Event_Hook_Check +1; // 후킹 전체 체크
implementation

end.
