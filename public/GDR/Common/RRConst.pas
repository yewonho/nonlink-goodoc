unit RRConst;

interface
const
  Const_Char_Arrow_UPDown   = '��';
  Const_Char_Arrow_UP       = '��';
  Const_Char_Arrow_Down     = '��';

const // listgrid����
  Col_Index_Data = 1;

const // sort
  Sort_Name_Ascending   = 1;
  Sort_Name_Descending  = 2;
  Sort_Time_Ascending   = 3;
  Sort_time_Descending  = 4;
  Sort_Room_Ascending   = 5;
  Sort_Room_Descending  = 6;

const  // button tag
  Index_tag_Ȯ��     = 1;
  Index_tag_����Ϸ� = 2;
  Index_tag_������û = 3;
  Index_tag_����Ȯ�� = 4;

const  // ��� cell�� width
  Col_Width_State       = 40; // ����(����)
  Col_Width_isFirst     = 70; // ȯ������
  Col_Width_PatientName = 90; // �̸�
  Col_Width_Room        = 100; // �����
  Col_Width_BirthDay    = 105; // ����(�ֹ�)
  Col_Width_Time        = 90; // ����/���� (��û) �ð�
  Col_Width_Button1     = 40; // 1�� ��ư(Ȯ����ư)
  Col_Width_Button2     = 36; // 2�� ��ư
  Col_Width_Symptom     = 80; // ��������


const  // ��� cell�� width(����/���� ���)
  Col_Width_State_RR        = 40; // ����(����)
  Col_Width_isFirst_RR      = 70; // ȯ������
  Col_Width_PatientName_RR  = 90; // �̸�
  Col_Width_Room_RR         = 100; // �����
  Col_Width_BirthDay_RR     = 105; // ���� (�ֹ�)
  Col_Width_Time_RR         = 90; // ����/���� (��û) �ð�
  Col_Width_Time2_RR        = 90; // ���� �ð�
  Col_Width_Button1_RR      = 40; // 1�� ��ư(Ȯ����ư)
  Col_Width_Button2_RR      = 36; // 2�� ��ư
  Col_Width_Symptom_RR      = 80; // ��������



const  // ��� cell�� width (������)
  Col_Width_State_R       = 40; // ����
  Col_Width_PatientName_R = 70; // �̸�
  Col_Width_Room_R        = 90; // �����
  Col_Width_BirthDay_R    = 100; // ����
  Col_Width_Time_R        = 90; // ����/���� (��û) �ð�
  Col_Width_Time2_R       = 90; // ���� �ð�
  Col_Width_Button1_R     = 36; // 1�� ��ư
  Col_Width_Button2_R     = 36; // 2�� ��ư

const // ��µǴ� grid�� ID
  Grid_Information_RnR_ID           = 'RnR'; // Ȩ/��û grid
  Grid_Information_Reception_ID     = 'Reception'; // Ȩ/���� grid
  Grid_Information_Reservation_ID   = 'Reservation'; // Ȩ/���� grid

  Grid_Information_ReservationMonthReq_ID     = 'ReservationMonthReq'; // ��/�����û grid
  Grid_Information_ReservationMonth_ID        = 'ReservationMonth'; // ��/����Ȯ�� grid

  Grid_Information_ReservationListReq_ID     = 'ReservationListReq'; // ��/�����û grid
  Grid_Information_ReservationList_ID        = 'ReservationList'; // ��/����Ȯ�� grid

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
    '����',
    '�ǻ��',
    '��������(��ž)',
    '��Ʈ��',
    '�ϳ���'
  );

implementation

end.
