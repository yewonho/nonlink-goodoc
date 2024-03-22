unit EventIDConst;

interface
const
  OB_Event_LoginOk                    = 1;
  OB_Event_LogoutOk                   = OB_Event_LoginOk + 1;

  OB_Event_Env_Change                 = OB_Event_LogoutOk + 1; // ȯ�� ���� �����

  OB_Event_1_1_Chat                   = OB_Event_Env_Change + 1; // 1:1 ä��
  OB_Event_UserMenualDownLoad         = OB_Event_1_1_Chat + 1; // ����� �޴��� download

  OB_Event_Show_��                    = OB_Event_UserMenualDownLoad + 1; // �� ȭ�� �̵�
  OB_Event_Show_��                    = OB_Event_Show_�� + 1;  // �� ȭ�� �̵�
  OB_Event_Show_��_List               = OB_Event_Show_�� + 1;  //�� list ȭ�� �̵�

  OB_Event_DataRefresh                = OB_Event_Show_��_List + 1; // data�� ���� �Ǿ����� ȭ���� refresh�ϰ� �Ѵ�.
  OB_Event_DataRefresh_RR             = OB_Event_DataRefresh + 1; // ����/���� ����� refresh�Ѵ�.
  OB_Event_DataRefresh_Reception      = OB_Event_DataRefresh_RR + 1; // ���� ����� refresh
  OB_Event_DataRefresh_Reservation    = OB_Event_DataRefresh_Reception + 1; // ���� ����� refresh
  OB_Event_DataRefresh_DataReload     = OB_Event_DataRefresh_Reservation + 1; //  �� ���� list data refresh
  OB_Event_DataRefresh_Notify         = OB_Event_DataRefresh_DataReload + 1; // ����/���� ��ó�� count notify

  OB_Event_ExpandCollapse_RnR         = OB_Event_DataRefresh_Notify + 1; // ����/���� â ������/���
  OB_Event_ExpandCollapse_Reception   = OB_Event_ExpandCollapse_RnR + 1; // ���� â ������/���
  OB_Event_ExpandCollapse_Reservation = OB_Event_ExpandCollapse_Reception + 1; // ���� â ������/���

  OB_Event_DataRefresh_Month          = OB_Event_ExpandCollapse_Reservation + 1; //  �� ���� data refresh
  OB_Event_DataRefresh_Month_List     = OB_Event_DataRefresh_Month + 1; //  �� ���� data ����� refresh
  OB_Event_DataRefresh_Month_ProcessList  = OB_Event_DataRefresh_Month_List + 1; //  �� ���� data ����� refresh
  OB_Event_DataRefresh_Month_RequestList  = OB_Event_DataRefresh_Month_ProcessList + 1; //  �� ���� ��û ��� data ����� refresh
  OB_Event_DataRefresh_Month_DataReload   = OB_Event_DataRefresh_Month_RequestList + 1; //  �� ���� list data refresh(�� �޴�)

  OB_Event_ExpandCollapse_RR_MonthList  = OB_Event_DataRefresh_Month_DataReload + 1; // �� ���� ��û â ������/���
  OB_Event_ExpandCollapse_R_Reception   = OB_Event_ExpandCollapse_RR_MonthList + 1; // �� ���� â ������/���


  OB_Event_DataRefresh_Month2          = OB_Event_ExpandCollapse_R_Reception + 1; //  �� ���� list data refresh
  OB_Event_DataRefresh_Month2_List     = OB_Event_DataRefresh_Month2 + 1; //  �� ���� list data ����� refresh
  OB_Event_DataRefresh_Month2_ProcessList   = OB_Event_DataRefresh_Month2_List + 1; //  �� ���� list data ����� refresh
  OB_Event_DataRefresh_Month2_RequestList   = OB_Event_DataRefresh_Month2_ProcessList + 1; //  �� ���� ��û ��� list data ����� refresh
  OB_Event_DataRefresh_Month2_DataReload    = OB_Event_DataRefresh_Month2_RequestList + 1; // �������� data�� �ٽ� �޾� �ͼ� ��� �ϰ� �Ѵ�.(�� �޴�)

  OB_Event_ExpandCollapse_RR_List  = OB_Event_DataRefresh_Month2_DataReload + 1; // �� ���� list ��û â ������/���
  OB_Event_ExpandCollapse_RR_RequestReservationList   = OB_Event_ExpandCollapse_RR_List + 1; // �� ���� list â ������/���

  OB_Event_RoomInfo_Change              = OB_Event_ExpandCollapse_RR_RequestReservationList + 1; // room info ������ ���� ���.

  OB_Event_400FireOff                   = OB_Event_RoomInfo_Change + 1; // event 400, polling ����
  OB_Event_400FireOn                    = OB_Event_400FireOff + 1;      // event 400, polling ����

  OB_Event_Reload_RoomInfo              = OB_Event_400FireOn + 1; // ����� ����� �������� �ٽ� �޾� �´�.
  OB_Event_Reload_CancelMessage         = OB_Event_Reload_RoomInfo + 1; // ��� �޽��� ����� �������� �ٽ� �޾� �´�.

  OB_Event_Init_ExpandCollapse          = OB_Event_Reload_CancelMessage + 1; // ����/��� ��ư �ʱⰪ ����

  OB_Event_Hook_Check                   = OB_Event_Init_ExpandCollapse +1; //��ŷ üũ(��ž ��Ʈ�� ����)
  OB_Event_Hook_Check_all               = OB_Event_Hook_Check +1; // ��ŷ ��ü üũ
implementation

end.
