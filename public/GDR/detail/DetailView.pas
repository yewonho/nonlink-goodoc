unit DetailView;
(*
���� ����

���� -> ��� ����
------------------------------
���� ���� -> ȯ�� ���
���� ���� -> ���� ���

���� ��û -> ���� ��û
���� ��û -> ���� ��û
��� ��û -> ��� ��û
���� �Ϸ� -> ���� Ȯ��
���� �Ϸ� -> ���� Ȯ��
���� ��û -> ���� Ȯ��

���� �Ϸ� -> ���� �Ϸ�

ȯ�� ���
  Ȯ�� �� -> ȯ�� ���
  Ȯ�� �� -> ȯ�� öȸ

���� ���
  Ȯ�� ��
    ���� -> ���� �ź�
    ���� -> ���� �ź�
  Ȯ�� �� -> ���� ���

����/���� �� �湮�� ���� �ʾƼ� ���� �������� �ڵ����� ��� �� ��� -> �ڵ� ���
*)
interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  SakpungImageButton, Vcl.Grids, SakpungStyleButton, RnRData, Vcl.AppEvnts,
  TranslucentFormUnit, SakpungMemo, Vcl.ComCtrls, RRObserverUnit,
  Vcl.Imaging.pngimage;

type
  TComboBox = class(Vcl.StdCtrls.TComboBox)
  protected
    { protected declarations }
    procedure WndProc(var Message: TMessage); override;
    procedure DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState); override;
  end;

  TClipboardMemo = class(TMemo)
    public
      procedure DefaultHandler(var Message); override;
  end;


  TStatusChangeNotify = procedure (AData: TRnRData; ANewStatus : TRnRDataStatus; var AClosed : Boolean) of object;

  TRRDetailViewClass = class of TCustomRRDetailViewForm;
{
  ���� ���� ��� �⺻ class
}
  TCustomRRDetailViewForm = class(TTranslucentSubForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Bottom_Panel: TPanel;
    button_panel: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    RegisterDT_Label: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    roominfo: TComboBox;
    Label20: TLabel;
    Memo_Data: TSakpungMemo;
    Bevel1: TBevel;
    close_btn: TSakpungImageButton2;
    SakpungImageButton3: TSakpungImageButton;
    SakpungImageButton4: TSakpungImageButton;
    Bevel2: TBevel;
    VisitDT_Label: TLabel;
    reg_id: TEdit;
    memocount_label: TLabel;
    Registration_number_edit: TEdit;
    Path_edit: TEdit;
    Phone_edit: TEdit;
    addr_edit: TMemo;
    Label1: TLabel;
    name_edit: TEdit;
    Label10: TLabel;
    SakpungImageButton1: TSakpungImageButton;
    SakpungImageButton2: TSakpungImageButton;
    Label11: TLabel;
    SakpungImageButton6: TSakpungImageButton;
    SakpungImageButton8: TSakpungImageButton;
    SakpungImageButton9: TSakpungImageButton;
    Button1: TButton;
    SakpungImageButton7: TSakpungImageButton;
    Label4: TLabel;
    Department_memo: TEdit;
    CopyCom: TImage;
    CopyTimer: TTimer;
    CopyCom2: TImage;
    CopyCom3: TImage;
    CopyCom4: TImage;
    procedure Bottom_PanelResize(Sender: TObject);
    procedure close_btnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SakpungImageButton3Click(Sender: TObject);
    procedure SakpungImageButton4Click(Sender: TObject);
    procedure Memo_DataChange(Sender: TObject);
    procedure SakpungImageButton1Click(Sender: TObject);
    procedure SakpungImageButton2Click(Sender: TObject);
    procedure SakpungImageButton6Click(Sender: TObject);
    procedure SakpungImageButton8Click(Sender: TObject);
    procedure SakpungImageButton9Click(Sender: TObject);
   // procedure SakpungImageButton5Click(Sender: TObject);
   // procedure OnEditReservationDateTime(Sender: TObject);
   // procedure SakpungImageButton10Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure SakpungImageButton7Click(Sender: TObject);
    procedure Panel1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CopyTimerTimer(Sender: TObject);

  private
    { Private declarations }
    FStatusChange: TStatusChangeNotify;
    FObserver : TRRObserver;

    isMemoModified : Boolean; // �޸� ����Ǿ� �ִ� check�Ѵ�. true�̸� memo�� ���� �Ǿ���.
    isRoomChanged : Boolean; // ����� ������ ���� �Ǿ����ϴ�.
    isStatusChanged : Boolean; // ���°� ����Ǿ���.
    isNameChanged : Boolean; // �̸��� �����
    isPhoneChanged : Boolean; // ��ȭ ��ȣ�� �����
    isReservationTimeChanged : Boolean; // ����ð��� �����

    procedure ImportRoomInfo;
    procedure initButton;

    function GetDataModified: Boolean; // window button�� image�� �ʱ�ȭ �Ѵ�.
  protected
    { protected declarations }
    FShowData : TRnRData;

    procedure CreateParams(var Params: TCreateParams); override;
    procedure DoShow; override;

    procedure doRoomInfoChange( ARoomInfo : TRoomInfo ); virtual; // ���� ��ư Ŭ���� �߻� �Ѵ�.
    procedure doMemoSave( AMemo : string ); virtual; // ���� ��ư Ŭ���� �߻� �Ѵ�.
    function doStatusChange( ANewStatus : TRnRDataStatus ) : Boolean; virtual;
    procedure ShowData( AData : TRnRData ); virtual; // data�� ��� �Ѵ�.
    procedure updateMemoCount;
    procedure doReservationTimeChange( ATime : TDateTime ); virtual;
    procedure updateRegistrationNumber;
  public
    { Public declarations }
  public
    { Public declarations }
    constructor Create( AOwner : TComponent ); override;
    destructor Destroy; override;

    property DataModified : Boolean read GetDataModified;

    function ShowDetailData( AData : TRnRData ) : Integer; virtual;

    property OnStatusChange : TStatusChangeNotify read FStatusChange write FStatusChange;
  end;

{
  ���� ��û ���¿��� ó�� �ϴ� class
}
  TDetailView_RequestForm = class(TCustomRRDetailViewForm)
  private
    { Private declarations }
    btn_����Ȯ�� : TSakpungImageButton2;
    btn_�����ź� : TSakpungImageButton2;
    procedure click_����Ȯ��( ASender : TObject );
    procedure click_�����ź�( ASender : TObject );

    procedure initButton( AType : TRnRType );
  protected
    { protected declarations }
    procedure doRoomInfoChange( ARoomInfo : TRoomInfo ); override; // ���� ��ư Ŭ���� �߻� �Ѵ�.
    procedure doMemoSave( AMemo : string ); override; // ���� ��ư Ŭ���� �߻� �Ѵ�.
    procedure ShowData( AData : TRnRData ); override; // data�� ��� �Ѵ�.
  public
    { Public declarations }
    constructor Create( AOwner : TComponent ); override;
    destructor Destroy; override;
  end;

{
  ���� Ȯ�� ���¿��� ������û/����Ȯ�� ó�� �ϴ� class
}
  TDetailView_WorkForm = class(TCustomRRDetailViewForm)
  private
    { Private declarations }
    btn_������û : TSakpungImageButton2;
    btn_����Ȯ�� : TSakpungImageButton2;
    btn_������� : TSakpungImageButton2;
    btn_����Ϸ� : TSakpungImageButton2;
    procedure click_������û( ASender : TObject );
    procedure click_����Ȯ��( ASender : TObject );
    procedure click_�������( ASender : TObject );
    procedure click_����Ϸ�( ASender : TObject );

    procedure initButton( AType : TRnRType );
  protected
    { protected declarations }
    procedure doRoomInfoChange( ARoomInfo : TRoomInfo ); override; // ���� ��ư Ŭ���� �߻� �Ѵ�.
    procedure doMemoSave( AMemo : string ); override; // ���� ��ư Ŭ���� �߻� �Ѵ�.
    procedure ShowData( AData : TRnRData ); override; // data�� ��� �Ѵ�.
  public
    { Public declarations }
    constructor Create( AOwner : TComponent ); override;
    destructor Destroy; override;
  end;

{
  ��� ���¿��� ���� ��ȸ�ϴ� class
}
  TDetailView_CancelForm = class(TCustomRRDetailViewForm)
  private
    { Private declarations }
    Label_Time : TLabel;
    Label_Memo : TLabel;
    procedure initUI;
  protected
    { protected declarations }
    procedure doRoomInfoChange( ARoomInfo : TRoomInfo ); override; // ���� ��ư Ŭ���� �߻� �Ѵ�.
    procedure doMemoSave( AMemo : string ); override; // ���� ��ư Ŭ���� �߻� �Ѵ�.
    procedure ShowData( AData : TRnRData ); override; // data�� ��� �Ѵ�.
  public
    { Public declarations }
    constructor Create( AOwner : TComponent ); override;
    destructor Destroy; override;
  end;

{
  �Ϸ� ���¿��� ���� ��ȸ�ϴ� class
}
  TDetailView_FinishForm = class(TCustomRRDetailViewForm)
  private
    { Private declarations }
  protected
    { protected declarations }
    procedure doRoomInfoChange( ARoomInfo : TRoomInfo ); override; // ���� ��ư Ŭ���� �߻� �Ѵ�.
    procedure doMemoSave( AMemo : string ); override; // ���� ��ư Ŭ���� �߻� �Ѵ�.
    procedure ShowData( AData : TRnRData ); override; // data�� ��� �Ѵ�.
  public
    { Public declarations }
    constructor Create( AOwner : TComponent ); override;
    destructor Destroy; override;
  end;


{
  ���� Ȯ�� ���¿��� ������û/����Ȯ�� ó�� �ϴ� class
}
  TDetailView_Reservation_WorkForm = class(TCustomRRDetailViewForm)
  private
    { Private declarations }
    btn_����Ȯ�� : TSakpungImageButton2;
    btn_������� : TSakpungImageButton2;
    procedure click_����Ȯ��( ASender : TObject );
    procedure click_�������( ASender : TObject );

    procedure initButton;
  protected
    { protected declarations }
    procedure doRoomInfoChange( ARoomInfo : TRoomInfo ); override; // ���� ��ư Ŭ���� �߻� �Ѵ�.
    procedure doMemoSave( AMemo : string ); override; // ���� ��ư Ŭ���� �߻� �Ѵ�.
    procedure ShowData( AData : TRnRData ); override; // data�� ��� �Ѵ�.
  public
    { Public declarations }
    constructor Create( AOwner : TComponent ); override;
    destructor Destroy; override;
  end;

{
  ���� ��� ����(rrsVisiteDecide) ���¿��� �Ϸ� ó�� �ϴ� class
}
  TDetailView_VisiteDecide_WorkForm = class(TCustomRRDetailViewForm)
  private
    { Private declarations }
    btn_����Ϸ� : TSakpungImageButton2;
    btn_��� : TSakpungImageButton2;
    procedure click_����Ϸ�( ASender : TObject );
    procedure click_���( ASender : TObject );

    procedure initButton( AType : TRnRType );
  protected
    { protected declarations }
    procedure doRoomInfoChange( ARoomInfo : TRoomInfo ); override; // ���� ��ư Ŭ���� �߻� �Ѵ�.
    procedure doMemoSave( AMemo : string ); override; // ���� ��ư Ŭ���� �߻� �Ѵ�.
    procedure ShowData( AData : TRnRData ); override; // data�� ��� �Ѵ�.
  public
    { Public declarations }
    constructor Create( AOwner : TComponent ); override;
    destructor Destroy; override;
  end;


function MakeDetailClass( AData : TRnRData ) : TCustomRRDetailViewForm;

// �� page���� ���� ���� �� Ȯ�� �޽��� ó��, true�̸� yes ��ư�� ���� �ߴ�.
function ConfirmMessage( ANewStatus: TRnRDataStatus; AOwnerHandle : THandle = 0 ) : Boolean;


implementation
uses
  ClipBrd,
  dateutils, GDLog, {RRDialogs}gd.GDMsgDlg_none,
  RnRDMUnit, ImageResourceDMUnit, SelectCancelMSG,
  BridgeCommUnit, BridgeWrapperUnit, RegularExpressions, UtilsUnit, EventIDConst, RREnvUnit,
  OCSHookLoader, OCSHookAPI; //, DetailCancelForm;

{$R *.dfm}
procedure MemoToClipboardMemo( AMemo: TMemo);
type
  PClass = ^TClass;
begin
  if Assigned(AMemo) then
    PClass(AMemo)^ := TClipboardMemo;
end;


function MakeDetailClass( AData : TRnRData ) : TCustomRRDetailViewForm;
var
  makeclass : TRRDetailViewClass;
begin
    case AData.Status of
      rrsUnknown, // �˼� ���� ����
      rrs��ҿ�û, // Status_��ҿ�û = 'F01';
      rrs�����û, // Status_�����û = 'S01';
      rrs������û: // Status_������û = 'C01';
          makeclass := TDetailView_RequestForm; // ���� ��û ����
      rrs����Ϸ�, // Status_����Ϸ� = 'S03';
      rrs�����Ϸ�, // Status_�����Ϸ� = 'C03';
      rrs�����Ϸ�_new, // �����Ͽ�
      rrs������û : // Status_������û = 'C05';
        begin
          makeclass := TDetailView_WorkForm; // ���� Ȯ���� �Ϸ�� ����, ���� ��� ����

          if (AData.Inflow = rriftablet) and (AData.Status = rrs�����Ϸ�) then
            makeclass := TDetailView_VisiteDecide_WorkForm;
        end;
      rrs����Ȯ��, // Status_����Ȯ�� = 'C06';
      rrs������, // Status_������ = 'C04';
      rrs��������: // Status_�������� = 'C07';
          makeclass := TDetailView_VisiteDecide_WorkForm; // ���� Ȯ���� �Ϸ�� ����, ���� ��� ����
      rrs����Ϸ�:
          makeclass := TDetailView_FinishForm; // ���� �Ϸ� ����
    else // ��� data
      //rrs�������, // Status_������� = 'S02';
      //rrs��������, // Status_�������� = 'C02';
      makeclass := TDetailView_CancelForm;
    end;

  Result := makeclass.Create( nil );
end;

function ConfirmMessage( ANewStatus: TRnRDataStatus; AOwnerHandle : THandle = 0 ) : Boolean;
var
  msg : string;
begin
  Result := False;
  case ANewStatus of
    // rrsUnknown, // �˼� ���� ����
    rrs�������,      // Status_������� = 'F02';
    rrs�������,      // Status_������� = 'F03';
    rrs�������,
    rrs�������� : msg := '�ش� ȯ���� ������ ����Ͻðڽ��ϱ�?'; // ���
    rrs����Ϸ�,      // Status_����Ϸ� = 'S03';
    rrs�����Ϸ� : msg := '�ش� ȯ�ڸ� ������ Ȯ���Ͻðڽ��ϱ�?'; // Ȯ��
    rrs�����Ϸ�_new,
    //rrs������,      // Status_������ = 'C04';
    rrs������û : msg := '�ش� ȯ�ڿ��� ������û �˸����� �߼��Ͻðڽ��ϱ�?'; // ���� ��û
    rrs����Ȯ�� : msg := '�ش�ȯ���� ������ Ȯ���Ͻðڽ��ϱ�?'; // ���� Ȯ��
    //rrs��������,      // Status_�������� = 'C07';
    //rrs��ҿ�û,      // Status_��ҿ�û = 'F01';
    // rrs�ڵ����,      // Status_�ڵ���� = 'F04';
    rrs����Ϸ� : msg := '�ش� ȯ�ڸ� ����Ϸ� ó�� �Ͻðڽ��ϱ�?'; // ���� �Ϸ�
  else
    exit;
  end;

  //Result := GDMessageDlg(msg, mtConfirmation, [mbYes, mbNo], 0, AOwnerHandle ) = mrYes;

  if ANewStatus = rrs�����Ϸ�_new then
  begin
      Result := true;
  end
  else

   Result := ShowGDMsgDlg( msg, GetTransFormHandle, mtConfirmation, [mbYes, mbNo] ) = mrYes;

end;


{ TCustomRRDetailViewForm }

procedure TCustomRRDetailViewForm.Button1Click(Sender: TObject);
var
  ret : integer;
  retStr : string;
  patientdata : TREQPATIENTINFO;
  pdata : PREQPATIENTINFO;
  atmp : AnsiString;
  ocshook : TOCSHookDLLLoader;

begin
{$ifndef DEBUG}
  exit;
{$endif}

  ocshook := GetOCSHookLoader;

  FillChar(patientdata, sizeof(TREQPATIENTINFO), 0);

  if GetRREnv.IsFindPatientEnabled then
  begin
    if FShowData.isFirst then
      patientdata.unFirstVisit := 1
    else
      patientdata.unFirstVisit := 0;
  end
  else
    patientdata.unFirstVisit := 2;

  //patientdata.unID := StrToInt(FShowData.ChartReceptnResultId.Id1);
  atmp := AnsiString( FShowData.GetChartReceptnResultId );
  Move(atmp[1], patientdata.szID, Length(atmp)); // patientdata.szID := FShwoData.GetCharReceptnResultId;
  atmp := AnsiString( FShowData.PatientChartID );
  Move(atmp[1], patientdata.szCNo, Length(atmp)); // patientdata.szCNo := FShowData.PatientChartID;
  //atmp := ANsiString( FShowData.Memo );
  atmp := AnsiString( Memo_Data.Lines.Text );
  Move(atmp[1], patientdata.szMemo, Length(atmp)); // patientdata.szMemo := FShowData.Memo;
  patientdata.unSex := Cardinal(FShowData.Gender);
  atmp := AnsiString( FShowData.PatientName );
  Move(atmp[1], patientdata.szName, Length(atmp)); // patientdata.szName := FShowData.PatientName;
  atmp := AnsiString( FShowData.Addr );
  Move(atmp[1], patientdata.szAddress, Length(atmp)); // patientdata.szAddress := FShowData.Addr;

  atmp := AnsiString( FShowData.AddrDetail );
  Move(atmp[1], patientdata.szAddressDetail, Length(atmp)); // patientdata.szAddress := FShowData.AddrDetail;

  atmp := AnsiString( FShowData.Zip );
  Move(atmp[1], patientdata.szZip, Length(atmp)); // patientdata.szzip := AData.zip;

  atmp := AnsiString( FShowData.Registration_number );
  Move(atmp[1], patientdata.szSocialNum, Length(atmp)); // patientdata.szSocialNum := FShowData.Registration_number;
  atmp := AnsiString( FShowData.CellPhone );
  Move(atmp[1], patientdata.szCellPhone, Length(atmp)); // patientdata.szCellPhone := FShowData.CellPhone;
  atmp := AnsiString( FShowData.BirthDay );
  Move(atmp[1], patientdata.szBirthday, Length(atmp)); // patientdata.szBirthday := FShowData.BirthDay;
  atmp := AnsiString( FShowData.RoomInfo.RoomName );
  Move(atmp[1], patientdata.szRoom, Length(atmp)); // patientdata.szRoom := FShowData.RoomInfo.RoomName;
  pdata := @patientdata;

  AddLog( doRunLog, '���� ó�� : ' + IntToStr(patientdata.unID) );
  ret := ocshook.InsertPatient( pdata );
  AddLog( doRunLog, '���� ó�� ��� : ' + IntToStr(ret) );

  if ret = 0 then
  begin
    // ��û ����. data lock

  end
  else
  begin
    // ��û ����
    retStr := ocshook.GetOCSErrorMessage(ret);
    if retStr <> '' then
    begin
      ShowGDMsgDlg(retStr, GetTransFormHandle, mtInformation, [mbOK]);
    end;
  end;


end;

procedure TCustomRRDetailViewForm.close_btnClick(Sender: TObject);

var
  ret: TModalResult;
  status : TRnRDataStatus;
  AData: TRnRData;
begin
  if Label9.Caption = '���� �Ϸ�' then
  begin
    Close;
  end

  else if Label9.Caption = '���� ���' then
  begin
    Close;
  end

  else if Label9.Caption = '���� �Ϸ�' then
  begin
    Close;
  end

  else if Label9.Caption = '(����) ���� �Ϸ�' then
  begin
    Close;
  end

  else if Label9.Caption = '(����) ���� ���' then
  begin
    Close;
  end

  else if Label9.Caption = '(����) ���� �Ϸ�' then
  begin
    Close;
  end

  else
    ret := ShowGDMsgDlg('������ Ȯ���� �� �����ðڽ��ϱ�?', GetTransFormHandle, mtConfirmation, [mbYes, mbNO]);

    if ret = mrYes then
    begin
    if FShowData.DataType = rrReception then
      status := rrs�����Ϸ�_new;

    if doStatusChange( status ) then
      Close;
    end
    else if ret = mrNo then
    begin
      Close;
    end


end;





constructor TCustomRRDetailViewForm.Create(AOwner: TComponent);
begin
  inherited;

  //MemoToClipboardMemo( Department_memo );
  MemoToClipboardMemo( addr_edit );

  isMemoModified := False;
  isRoomChanged := False;
  isStatusChanged := False;
  isNameChanged := False; // �̸��� �����
  isPhoneChanged := False; // ��ȭ ��ȣ�� �����
  isReservationTimeChanged := False;

  FStatusChange := nil;
  FShowData := nil;

  FObserver := TRRObserver.Create( nil );

  button_panel.BorderStyle := bsNone;

  Memo_Data.TextHint := '�޸� �Է����ּ���';
  addr_edit.Lines.Text := '����� ������ �����3�� 13,' +  #13#10 + '4��(���ﵿ �ɾ��Ÿ��)';
end;

procedure TCustomRRDetailViewForm.CreateParams(var Params: TCreateParams);
begin
  inherited;
  // borderstyle := bsNone; ���� ���� �� ����ؾ� �Ѵ�.

  //Params.Style := Params.Style or WS_THICKFRAME;   // captiond����, resize �ǰ�
  Params.Style := Params.Style or WS_BORDER; // caption����, border �ְ�, resize�ʵǰ�
  // Params.Style := Params.Style or WS_BORDER or WS_DLGFRAME; // caption�ְ�, system button����, resize �ʵǰ� , WS_CAPTION��� �ѰͰ� ����
  //Params.Style := Params.Style or WS_BORDER or WS_THICKFRAME; // captiond����, resize �ǰ�
end;

destructor TCustomRRDetailViewForm.Destroy;
var
  i : Integer;
  o : TObject;
begin
  if Assigned( FShowData ) then
    FreeAndNil( FShowData );

  for i := 0 to roominfo.Items.Count -1 do
  begin
    o := roominfo.Items.Objects[ i ];
    if Assigned( o ) then
    begin
      roominfo.Items.Objects[ i ] := nil;
      FreeAndNil( o );
    end;
  end;
  inherited;
end;

procedure TCustomRRDetailViewForm.doMemoSave(AMemo: string);
var
  event_109 : TBridgeResponse_109;
begin
  event_109 := BridgeWrapperDM.ChangeMemo(FShowData, AMemo);
  try
    if event_109.Code <> Result_SuccessCode then
      ShowGDMsgDlg( event_109.MessageStr, GetTransFormHandle, mtError, [mbOK] )
    else
    begin
      FShowData.Memo := AMemo;
      isMemoModified := True;

      ShowGDMsgDlg( '�޸� ����Ǿ����ϴ�', GetTransFormHandle, mtInformation, [mbOK] );
    end;

    ShowData( FShowData );
  finally
    FreeAndNil( event_109 );
  end;
end;

procedure TCustomRRDetailViewForm.doRoomInfoChange(ARoomInfo : TRoomInfo);
var
  event_107 : TBridgeResponse_107;
begin
  event_107 := BridgeWrapperDM.ChangeRoom(FShowData, ARoomInfo);
  try
    if event_107.Code <> Result_SuccessCode then
      ShowGDMsgDlg( event_107.MessageStr, GetTransFormHandle, mtError, [mbOK] )
    else
    begin
      FShowData.RoomInfo.Assign(ARoomInfo);
      isRoomChanged := True;
      ShowGDMsgDlg( '������� ����Ǿ����ϴ�', GetTransFormHandle, mtInformation, [mbOK] );
    end;

    ShowData( FShowData );
  finally
    FreeAndNil( event_107 );
  end;
end;

procedure TCustomRRDetailViewForm.DoShow;
begin
  inherited;
end;

function TCustomRRDetailViewForm.doStatusChange(ANewStatus: TRnRDataStatus) : Boolean;
begin
  Result := False;

  if Assigned( FStatusChange ) then
    FStatusChange( FShowData, ANewStatus, Result );

  if Result then //  �����̸� ���°� ����Ȱ����� ����.
  begin
    FShowData.Status := ANewStatus;
    if not isStatusChanged then
      isStatusChanged := True;
  end;
end;

procedure TCustomRRDetailViewForm.FormShow(Sender: TObject);
begin
  initButton;

  FormStyle := Application.MainForm.FormStyle;
end;

function TCustomRRDetailViewForm.GetDataModified: Boolean;
begin
  Result := isMemoModified or isRoomChanged or isStatusChanged or isNameChanged or isPhoneChanged or isReservationTimeChanged;
end;

procedure TCustomRRDetailViewForm.ImportRoomInfo;
var
  ri : TRoomInfoData;
begin
  roominfo.Items.Clear;
  with RnRDM do
  begin
    Room_DB.First;
    // roominfo.Items.AddObject( '-', nil ); // 2020-01-22 ������ ����Ȯ��, ����/����� �ݵ�� ����� ������ ���� �´�(�ʼ���)
    while not Room_DB.Eof do
    begin
      ri := TRoomInfoData.Create;
      ri.RoomCode := Room_DB.FieldByName( 'roomcode' ).AsString;
      ri.RoomName := Room_DB.FieldByName( 'roomname' ).AsString;
      ri.DeptCode := Room_DB.FieldByName( 'deptcode' ).AsString;
      ri.DeptName := Room_DB.FieldByName( 'deptname' ).AsString;
      ri.DoctorCode := Room_DB.FieldByName( 'doctorcode' ).AsString;
      ri.DoctorName := Room_DB.FieldByName( 'doctorname' ).AsString;

      roominfo.Items.AddObject(ri.RoomName, ri);
      Room_DB.Next;
    end;
  end;
  roominfo.ItemIndex := 0;
end;

procedure TCustomRRDetailViewForm.initButton;
begin
  close_btn.PngImageList := ImageResourceDM.WindowButtonImageList;
  ImageResourceDM.SetButtonImage(close_btn, aibtButton1, BTN_Img_Win_Close);
{$ifdef DEBUG}
  Button1.Visible := True;
  Button1.Enabled := True;
{$else}
  Button1.Visible := False;
  Button1.Enabled := False;
{$endif}

end;


procedure TCustomRRDetailViewForm.Memo_DataChange(Sender: TObject);
begin
  updateMemoCount;
end;


//����ð� ����
//procedure TCustomRRDetailViewForm.OnEditReservationDateTime(Sender: TObject);
//begin
//  if ((reservationDate.DateTime <> FShowData.VisitDT) or
//      not string.Equals(reservationTime.Text, FormatDateTime('hh:nn', FShowData.VisitDT))) and
//      (FShowData.Status in [rrs�����û, rrs����Ϸ�]) then
//    SakpungImageButton5.Enabled := True
//  else
//    SakpungImageButton5.Enabled := False;
//
//end;

procedure TCustomRRDetailViewForm.Bottom_PanelResize(Sender: TObject);
begin
  button_panel.Left := ( Bottom_Panel.Width - button_panel.Width ) div 2;
end;




//����ð� ����
//procedure TCustomRRDetailViewForm.SakpungImageButton10Click(Sender: TObject);
//var
//  msg : string;
//
//  dtype : TRnRType;
//  visitdt : TDateTime;
//  pname : string;
//  roomcode : string;
//
//  status : TConvertState4App;
//  statuscode : TRnRDataStatus;
//
//begin
//  msg := '[' + FormatDateTime('yyyy-mm-dd', reservationDate.DateTime) + '] ������' + #13#10;
//
//  RnRDM.RRTableEnter;
//  try
//    with RnRDM do
//    begin
//      RR_DB.IndexName := 'visitIndex';
//
//      RR_DB.First;
//      while not RR_DB.Eof do // state�� rrsRequest�� data�� ��� ��� �Ѵ�.
//      begin
//        try
//          dtype := TRnRType( RR_DB.FieldByName( 'datatype' ).AsInteger );
//          if dtype <> rrReservation then
//              Continue; // ������ �ƴϸ� ���� ���� �ʴ´�.
//
//          visitdt := RR_DB.FieldByName('reservedttm').AsDateTime;
//          if not CheckToday(visitdt, reservationDate.DateTime) then
//            Continue; // ������ ���� �߻��� data�� �ƴϴ�.
//
//          roomcode := RR_DB.FieldByName('roomcode').AsString;
//          if not string.Equals(roomcode, FShowData.RoomInfo.RoomCode) then
//            Continue; // ������� �ٸ��� ǥ������ ����.
//
//          statuscode := TRRDataTypeConvert.DataStatus2RnRDataStatus(RR_DB.FieldByName( 'status' ).AsInteger);
//          //status := TRRDataTypeConvert.Status4App( statuscode, RR_DB.FieldByName( 'hsptlreceptndttm' ).AsDateTime );
//
//          if TRRDataTypeConvert.CheckCancelStatus( statuscode ) or TRRDataTypeConvert.checkFinishStatus( statuscode ) then
//          begin
//            Continue; // ���/�Ϸ�� data�� �������� �ʴ´�.
//          end;
//
//          pname := RR_DB.FieldByName('patientname').AsString;
//
//          msg := msg + pname + ': ' + FormatDateTime('hh:nn', visitdt);
//          if statuscode = rrs�����û then
//            msg := msg + ' [�����û]' + #13#10
//          else if statuscode = rrs����Ϸ� then
//            msg := msg + ' [����Ϸ�]' + #13#10
//          else
//            msg := msg + ' [����/����]' + #13#10;
//
//
//          {if (status in [csa��û, csa��û���]) then // Ȯ�� ���� data�� ���� �ϰ� �Ѵ�.
//            data.incRequestCount
//          else
//            data.incDecideCount;
//            }
//
//        finally
//          RR_DB.Next;
//        end;
//      end;
//    end;
//  finally
//    RnRDM.RRTableLeave;
//  end;
//
//  ShowGDMsgDlg(msg, GetTransFormHandle, mtInformation, [mbOK] );
//end;

procedure TCustomRRDetailViewForm.SakpungImageButton1Click(Sender: TObject);
var
  event_405 : TBridgeResponse_405;
begin // �̸� ����
  if FShowData.PatientName = name_edit.Text then
    exit;

  event_405 := BridgeWrapperDM.ChangePatientName( FShowData.PatientID, FShowData.PatientName, name_edit.Text, FShowData.CellPhone, FShowData.CellPhone);
  try
    if event_405.Code = Result_SuccessCode then
    begin
      //FShowData.PatientName := event_405.newName; // V4. 405������ �����ϰ� 404��û������ ����
      FShowData.PatientName := name_edit.Text;
      isNameChanged := True;
      ShowData( FShowData );
      ShowGDMsgDlg( '�̸��� ����Ǿ����ϴ�', GetTransFormHandle, mtInformation, [mbOK] );
    end
    else
      ShowGDMsgDlg( event_405.MessageStr, GetTransFormHandle, mtError, [mbOK] );
  finally
    if Assigned( event_405 ) then
      FreeAndNil( event_405 );
  end;
end;

procedure TCustomRRDetailViewForm.SakpungImageButton2Click(Sender: TObject);
var
  phone : string;
  event_405 : TBridgeResponse_405;
begin // ��ȭ ��ȣ ����
  phone := ConvertInputCellPhone( Phone_edit.Text );
  if FShowData.CellPhone = phone then
    begin
      exit;
    end
  else
  if (phone.Length > 11) or (phone.Length <= 9) or (phone = '') then
    begin
      ShowGDMsgDlg( '����ó�� �ùٸ��� �ʽ��ϴ�.', GetTransFormHandle, mtWarning, [mbOK] );
      exit;
    end;

  event_405 := BridgeWrapperDM.ChangePatientPhone( FShowData.PatientID, FShowData.PatientName, FShowData.PatientName, FShowData.CellPhone, phone);
  try
    if event_405.Code = Result_SuccessCode then
    begin
      //FShowData.CellPhone := event_405.newPhone; // V4. 405������ �����ϰ� 404��û������ ����
      FShowData.CellPhone := phone;
      isPhoneChanged := True;
      ShowData( FShowData );
      ShowGDMsgDlg( '����ó�� ����Ǿ����ϴ�', GetTransFormHandle, mtInformation, [mbOK] );
    end
    else
      ShowGDMsgDlg( event_405.MessageStr, GetTransFormHandle, mtError, [mbOK] );
  finally
    if Assigned( event_405 ) then
      FreeAndNil( event_405 );
  end;
end;

procedure TCustomRRDetailViewForm.SakpungImageButton3Click(Sender: TObject);
  function CheckDuplicateReservation(ARoomCode : string) : Boolean;
  var
    dtype : TRnRType;
    visitdt : TDateTime;
    roomcode : string;

    status : TConvertState4App;
    statuscode : TRnRDataStatus;

    changedt : TDateTime;
  begin
    Result := False;

    RnRDM.RRTableEnter;
    try
      with RnRDM do
      begin
        RR_DB.IndexName := 'visitIndex';

        RR_DB.First;
        while not RR_DB.Eof do
        begin
          try
            dtype := TRnRType( RR_DB.FieldByName( 'datatype' ).AsInteger );
            if dtype <> rrReservation then
                Continue;

            visitdt := RR_DB.FieldByName('reservedttm').AsDateTime;
            roomcode := RR_DB.FieldByName( 'roomcode' ).AsString;

//            if not CheckToday(visitdt, reservationDate.DateTime) then
//              Continue; // ������ ���� �߻��� data�� �ƴϴ�.

            statuscode := TRRDataTypeConvert.DataStatus2RnRDataStatus(RR_DB.FieldByName( 'status' ).AsInteger);
            //status := TRRDataTypeConvert.Status4App( statuscode, RR_DB.FieldByName( 'hsptlreceptndttm' ).AsDateTime );

            if TRRDataTypeConvert.CheckCancelStatus( statuscode ) or TRRDataTypeConvert.checkFinishStatus( statuscode ) then
            begin
              Continue; // ���/�Ϸ�� data�� �������� �ʴ´�.
            end;

//            changedt := reservationDate.DateTime;
//            reservationTime.SelectAll;
//            ReplaceTime(changedt, StrToDateTime(reservationTime.SelText));

            if SameDateTime(visitdt, changedt) and string.Equals(roomcode, ARoomCode) then
            begin
              Result := True;
              break;
            end;
          finally
            RR_DB.Next;
          end;
        end;
      end;
    finally
      RnRDM.RRTableLeave;
    end;
  end;

var
  ri : TRoomInfo;
  rd : TRoomInfoData;
begin
  if roominfo.ItemIndex < 0 then
  begin // ���õǾ� �ִ� ����� ������ ����.
    ShowGDMsgDlg( '������� ���õǾ� ���� �ʽ��ϴ�.' + #13#10 + '������� ������ �ּ���!', GetTransFormHandle, mtWarning, [mbOK] );
    exit;
  end;

  rd := TRoomInfoData( roominfo.Items.Objects[ roominfo.ItemIndex ] );
  if not Assigned( rd ) then
    exit;

  ri.RoomCode := rd.RoomCode;
  ri.RoomName := rd.RoomName;
  ri.DeptCode := rd.DeptCode;
  ri.DeptName := rd.DeptName;
  ri.DoctorCode := rd.DoctorCode;
  ri.DoctorName := rd.DoctorName;

  if CheckDuplicateReservation(ri.RoomCode) then
  begin
    ShowGDMsgDlg('�ش�ð����� ������� �����մϴ�.', GetTransFormHandle, mtInformation, [mbOK] );
    roominfo.ItemIndex := roominfo.Items.IndexOf(FShowData.RoomInfo.RoomName);
    exit;
  end;

  doRoomInfoChange( ri );
end;

procedure TCustomRRDetailViewForm.SakpungImageButton4Click(Sender: TObject);
begin
  doMemoSave( Memo_Data.Lines.Text );
end;


//����ð�����
//procedure TCustomRRDetailViewForm.SakpungImageButton5Click(Sender: TObject);
//  function CheckReservationTime : Boolean;
//  var
//    inputText : string;
//  begin
//    reservationTime.SelectAll;
//    inputText := reservationTime.SelText;
//    Result := TRegEx.IsMatch(inputText, '[0-9][0-9]:[0-9][0-9]');
//  end;
//
//  function CheckReservationDate : Boolean;
//  begin
//    if reservationDate.DateTime < Today then
//      Result := False
//    else
//      Result := True;
//  end;


//����ð� ����
//  function CheckDuplicateReservation : Boolean;
//  var
//    dtype : TRnRType;
//    visitdt : TDateTime;
//    roomcode : string;
//
//    status : TConvertState4App;
//    statuscode : TRnRDataStatus;
//
//    changedt : TDateTime;
//  begin
//    Result := False;
//
//    RnRDM.RRTableEnter;
//    try
//      with RnRDM do
//      begin
//        RR_DB.IndexName := 'visitIndex';
//
//        RR_DB.First;
//        while not RR_DB.Eof do
//        begin
//          try
//            dtype := TRnRType( RR_DB.FieldByName( 'datatype' ).AsInteger );
//            if dtype <> rrReservation then
//                Continue;
//
//            visitdt := RR_DB.FieldByName('reservedttm').AsDateTime;
//            roomcode := RR_DB.FieldByName( 'roomcode' ).AsString;
//
////            if not CheckToday(visitdt, reservationDate.DateTime) then
////              Continue; // ������ ���� �߻��� data�� �ƴϴ�.    ����ð� ����
//
//            statuscode := TRRDataTypeConvert.DataStatus2RnRDataStatus(RR_DB.FieldByName( 'status' ).AsInteger);
//            //status := TRRDataTypeConvert.Status4App( statuscode, RR_DB.FieldByName( 'hsptlreceptndttm' ).AsDateTime );
//
//            if TRRDataTypeConvert.CheckCancelStatus( statuscode ) or TRRDataTypeConvert.checkFinishStatus( statuscode ) then
//            begin
//              Continue; // ���/�Ϸ�� data�� �������� �ʴ´�.
//            end;
//
//            //����ð� ����
////            changedt := reservationDate.DateTime;
////            reservationTime.SelectAll;
////            ReplaceTime(changedt, StrToDateTime(reservationTime.SelText));
//
//            if SameDateTime(visitdt, changedt) and string.Equals(roomcode, FShowData.RoomInfo.RoomCode) then
//            begin
//              Result := True;
//              break;
//            end;
//          finally
//            RR_DB.Next;
//          end;
//        end;
//      end;
//    finally
//      RnRDM.RRTableLeave;
//    end;
//  end;

var
  time : TDateTime;

//begin
//  if not CheckReservationDate() then
//  begin
//    ShowGDMsgDlg( '�߸��� ���� ��¥�Դϴ�. ���� ���ķ� �Է����ּ���.', GetTransFormHandle, mtInformation, [mbOK] );
//    exit;
//  end;
//
//  if not CheckReservationTime() then
//  begin
//    ShowGDMsgDlg( '�߸��� ���� �ð� �����Դϴ�. 00:00 ~ 24:00 ���� �Է����ּ���.', GetTransFormHandle, mtInformation, [mbOK] );
//    reservationTime.SelectAll;
//    reservationTime.SetSelText(FormatDateTime('hh:nn', FShowData.VisitDT));
//    exit;
//  end;
//
//  if CheckDuplicateReservation() then
//  begin
//    ShowGDMsgDlg('�ش�ð����� ������� �����մϴ�.', GetTransFormHandle, mtInformation, [mbOK] );
//    exit;
//  end;
//
//  time := reservationDate.DateTime;
//  reservationTime.SelectAll;
//  ReplaceTime(time, StrToDateTime(reservationTime.SelText));
//
//  doReservationTimeChange(time);
//
//end;

procedure TCustomRRDetailViewForm.SakpungImageButton6Click(Sender: TObject);
var
  inputText : string;
  trimText : string;
begin
  name_edit.SelectAll;
  inputText := name_edit.SelText;
  trimText := inputText.Replace('-', '');
  name_edit.SetSelText(trimText);
  name_edit.SelectAll;
  name_edit.CopyToClipboard;
  name_edit.SetSelText(inputText);


  CopyCom.Visible := true;        //�����ư
  CopyTimer.Enabled := True;
end;

procedure TCustomRRDetailViewForm.SakpungImageButton7Click(Sender: TObject);
var
  inputText : string;
  trimText : string;
begin
  Department_memo.SelectAll;
  inputText := Department_memo.SelText;
  trimText := inputText.Trim;
  Department_memo.SetSelText(trimText);
  Department_memo.SelectAll;
  Department_memo.CopyToClipboard;
  Department_memo.SetSelText(inputText);


  CopyCom4.Visible := true;        //�����ư
  CopyTimer.Enabled := True;

end;

procedure TCustomRRDetailViewForm.SakpungImageButton8Click(Sender: TObject);
var
  inputText : string;
  trimText : string;
begin
  Registration_number_edit.SelectAll;
  inputText := Registration_number_edit.SelText;
  trimText := inputText.Replace('-', '');

  Registration_number_edit.SetSelText(trimText);
  Registration_number_edit.SelectAll;
  Registration_number_edit.CopyToClipboard;
  Registration_number_edit.SetSelText(inputText);

  CopyCom3.Visible := true;        //�����ư
  CopyTimer.Enabled := True;
end;

procedure TCustomRRDetailViewForm.SakpungImageButton9Click(Sender: TObject);
var
  inputText : string;
  trimText : string;
begin
  Phone_edit.SelectAll;
  inputText := Phone_edit.SelText;
  trimText := inputText.Replace('-', '');

  Phone_edit.SetSelText(trimText);
  Phone_edit.SelectAll;
  Phone_edit.CopyToClipboard;
  Phone_edit.SetSelText(inputText);

  CopyCom2.Visible := true;        //�����ư
  CopyTimer.Enabled := True;
end;

procedure TCustomRRDetailViewForm.ShowData(AData: TRnRData);
  function GetAge( ABirthDay : string ) : string;
  var
    age : Integer;
    b : TDate;
    strd : string;
  begin
    Result := '';
    if ABirthDay = '' then exit;
    strd := DisplayBirthDay( ABirthDay );
    b := StrToDateDef(strd, 0);
    if b = 0 then exit; // ���ڷ� ȯ����� �ʴ´�.

    age := Trunc(today) - Trunc( b );
    age := age div 365;
    Result := Format('�� %d��', [age]);
  end;
begin
  // �湮 ���� ��� ����, ���� data�� ����� �Ѵ�.
  //VisitDT_Label.Visible := AData.DataType = rrReservation;
//  reservationDate.Enabled := AData.DataType = rrReservation;
//  reservationTime.Enabled := AData.DataType = rrReservation;
//  SakpungImageButton5.Enabled := False;
//  SakpungImageButton10.Enabled := AData.DataType = rrReservation;

  name_edit.Text := AData.PatientName;
  if not AData.isRegNumDefined then
    updateRegistrationNumber;
  Registration_number_edit.Text := DisplayRegistrationNumber( AData.Registration_number ); // �ֹε�� ��ȣ xxxxxxxxxxxxx => 13�ڸ�, �ܱ���/���� ��ȣ???
  RegisterDT_Label.Caption := FormatDateTime('yyyy-mm-dd hh:nn',AData.RegisterDT);

  //VisitDT_Label.Caption := '����ð� : ' + FormatDateTime('yyyy-mm-dd hh:nn',AData.VisitDT);
//  reservationDate.DateTime := AData.VisitDT;
//  reservationTime.Text := FormatDateTime('hh:nn', AData.VisitDT);

  roominfo.ItemIndex := roominfo.Items.IndexOf( AData.RoomInfo.RoomName );

  // ���� ����
  Department_memo.Text := DisplaySymptom( AData.Symptom );
  // ���� ���
  Path_edit.Text := AData.InBoundPath;
  //  ZipNo : string; // ���� ��ȣ
  Phone_edit.Text := DisplayCellPhone( AData.CellPhone );
  // �ּ�
  if AData.Zip = '' then
  begin
    addr_edit.Lines.Text := AData.Addr + #13#10 + AData.AddrDetail;
  end
  else
  begin
    addr_edit.Lines.Text := '������ȣ:' + AData.Zip + #13#10 + AData.Addr + #13#10 + AData.AddrDetail;
  end;

  Memo_Data.Lines.Text :=  AData.Memo; // �޸�  DisplaySymptom( AData.Symptom) + #13#10 +

  updateMemoCount;

  // app���� �Էµ� ȯ�ڴ� �̸� ������ ���ϰ� �Ѵ�.
  SakpungImageButton1.Enabled := (AData.Inflow <> rrifApp); // and (AData.PatientChartID <> ''); // V4 deprecated.
  //SakpungImageButton2.Enabled := (AData.PatientChartID <> '');
  SakpungImageButton2.Enabled := SakpungImageButton1.Enabled;
  name_edit.ReadOnly := not SakpungImageButton1.Enabled;
  Phone_edit.ReadOnly := not SakpungImageButton2.Enabled;

  reg_id.Visible := GDebugLogLevel.ShowUI;
  reg_id.Text := AData.ChartReceptnResultId.Id1;
end;

function TCustomRRDetailViewForm.ShowDetailData(AData: TRnRData): Integer;
begin
  FShowData := AData.Copy;
  ImportRoomInfo; // room ��� ���

  ShowData( FShowData );

  Result := ShowModal;
  //Result := ShowCustomModal;
end;

procedure TCustomRRDetailViewForm.updateMemoCount;
var
  cnt : Integer;
  s : string;
begin
  s := Memo_Data.Lines.Text;
  cnt := Length( s );
  memocount_label.Caption := Format('%d��',[cnt]);
end;

procedure TCustomRRDetailViewForm.doReservationTimeChange( ATime : TDateTime );
var
  event_207 : TBridgeResponse_207;
begin
  FObserver.BeforeAction(OB_Event_DataRefresh_RR);
  FObserver.BeforeAction(OB_Event_DataRefresh_Reservation);
  FObserver.BeforeAction(OB_Event_DataRefresh_Month);
  FObserver.BeforeAction(OB_Event_DataRefresh_Month2);
  try
    event_207 := BridgeWrapperDM.ChangeReservationTime(FShowData, ATime);
    try
      if event_207.Code <> Result_SuccessCode then
        ShowGDMsgDlg( event_207.MessageStr, GetTransFormHandle, mtError, [mbOK] )
      else
      begin
        FShowData.VisitDT := ATime;
        // RR_DB ���� �ʿ�?
        RnRDM.UpdateReserveDttmRR(FShowData, ATime);

        isReservationTimeChanged := True;
        ShowGDMsgDlg( '�����û�ð��� ����Ǿ����ϴ�.', GetTransFormHandle, mtInformation, [mbOK] );
      end;

      ShowData( FShowData );
    finally
      FreeAndNil( event_207 );
    end;
  finally
    FObserver.AfterAction(OB_Event_DataRefresh_RR);
    FObserver.AfterAction(OB_Event_DataRefresh_Reservation);
    FObserver.AfterAction(OB_Event_DataRefresh_Month);
    FObserver.AfterAction(OB_Event_DataRefresh_Month2);
  end;

end;

procedure TCustomRRDetailViewForm.updateRegistrationNumber;
var
  event_411 : TBridgeResponse_411;
begin
  event_411 := BridgeWrapperDM.GetFullRegistrationNumber(FShowData);
  try
    if event_411.Code <> Result_SuccessCode then
      ShowGDMsgDlg( event_411.MessageStr, GetTransFormHandle, mtError, [mbOK] )
    else
    begin
      FShowData.Registration_number := event_411.regNum;
      FShowData.isRegNumDefined := True;
      // RR_DB �������� �ʴ´�. ȯ�ڸ�� �࿡���� ******�� ����

    end;
  finally
    FreeAndNil( event_411 );
  end;
end;

{ TComboBox }

procedure TComboBox.DrawItem(Index: Integer; Rect: TRect;
  State: TOwnerDrawState);
begin
  if odComboBoxEdit in State then begin // If we are drawing item in the edit part of the Combo
    if not Enabled then
      Canvas.Font.Color:= clBlack; // Disabled font colors
    Canvas.Brush.Color:= clWhite; // Get the right background color: normal, mandatory or disabled
  end;
  inherited DrawItem(Index, Rect, State);
end;

procedure TComboBox.WndProc(var Message: TMessage);
begin
  inherited;

  case Message.Msg of
    CN_CTLCOLORMSGBOX .. CN_CTLCOLORSTATIC, //48434..48440
    WM_CTLCOLORMSGBOX .. WM_CTLCOLORSTATIC:
    begin
      Color:= clWhite; // get's the current background state
      Brush.Color:= Color;
    end;
  end;
end;

{ TDetailView_RequestForm }

procedure TDetailView_RequestForm.click_�����ź�(ASender: TObject);
var
  status : TRnRDataStatus;
begin
  if FShowData.DataType = rrReception then
    status := rrs��������
  else
    status := rrs�������;

  if doStatusChange( status ) then
    Close;


end;



procedure TDetailView_RequestForm.click_����Ȯ��(ASender: TObject);
var
  status : TRnRDataStatus;
begin
  if FShowData.DataType = rrReception then
    status := rrs�����Ϸ�
  else
    status := rrs����Ϸ�;

  if doStatusChange( status ) then
    Close;
end;

constructor TDetailView_RequestForm.Create(AOwner: TComponent);
begin
  inherited;

  btn_����Ȯ�� := TSakpungImageButton2.Create( nil );
  btn_�����ź� := TSakpungImageButton2.Create( nil );

end;

destructor TDetailView_RequestForm.Destroy;
begin
  FreeAndNil( btn_����Ȯ�� );
  FreeAndNil( btn_�����ź� );

  inherited;
end;


procedure TDetailView_RequestForm.doMemoSave(AMemo: string);
begin
  inherited;
end;

procedure TDetailView_RequestForm.doRoomInfoChange(ARoomInfo : TRoomInfo);
begin
  inherited;
end;

procedure TDetailView_RequestForm.initButton( AType : TRnRType );
var
  leftposition : Integer;
  btype : string;
begin
  button_panel.Width := ImageResourceDM.ButtonImageList80x26.Width * 2 + 5;
  leftposition := 0;

  btn_����Ȯ��.Parent := button_panel;
  btn_����Ȯ��.Top := 0;
  btn_����Ȯ��.Left := leftposition;
  btn_����Ȯ��.PngImageList := ImageResourceDM.ButtonImageList80x26;
  btn_����Ȯ��.OnClick := click_����Ȯ��;

  if AType = rrReception then
    btype := BTN_Img_Detail_����Ȯ��
  else
    btype := BTN_Img_Detail_����Ȯ��;

  ImageResourceDM.SetButtonImage(btn_����Ȯ��, aibtButton1, btype);
  btn_����Ȯ��.Visible := True;

  Inc(leftposition, btn_����Ȯ��.Width + 5);

  btn_�����ź�.Parent := button_panel;
  btn_�����ź�.Top := 0;
  btn_�����ź�.Left := leftposition;
  btn_�����ź�.PngImageList := ImageResourceDM.ButtonImageList80x26;
//  btn_�����ź�.OnClick := click_�����ź�;
//  ImageResourceDM.SetButtonImage(btn_�����ź�, aibtButton1, btype);


  if AType = rrReception then
    btype := BTN_Img_Detail_�����ź�
  else
    btype := BTN_Img_Detail_����ź�;

  btn_�����ź�.OnClick := click_�����ź�;
  ImageResourceDM.SetButtonImage(btn_�����ź�, aibtButton1, btype);


end;

procedure TDetailView_RequestForm.ShowData(AData: TRnRData);
var
  str : string;
begin
  inherited;
  initButton(AData.DataType);
  str := '';
  if AData.isFirst then
    str := '(����) ';
  case AData.Status of
    rrs��ҿ�û : Label9.Caption := str + '��� ��û';
    rrs�����û : Label9.Caption := str + '���� ��û';
    rrs����Ϸ� : Label9.Caption := str + '���� �Ϸ�';
    rrs������û : Label9.Caption := str + '���� ��û';
    rrs�����Ϸ� : Label9.Caption := str + '���� �Ϸ�';
  end;

  if AData.Inflow = rriftablet then
   Label17.Caption := '�º���';

  if AData.Inflow = rrifApp then
   Label17.Caption := '�����';

end;

{ TDetailView_WorkForm }

procedure TDetailView_WorkForm.click_������û(ASender: TObject);
var
  status : TRnRDataStatus;
begin
  status := rrs������û;

  if doStatusChange( status ) then
    Close;
end;

procedure TDetailView_WorkForm.click_����Ȯ��(ASender: TObject);
var
  status : TRnRDataStatus;
begin
  //status := rrs������;
  status := rrs����Ȯ��;

  if doStatusChange( status ) then
    Close;
end;

procedure TDetailView_WorkForm.click_�������(ASender: TObject);
var
  status : TRnRDataStatus;
begin
  status := rrs�������;

  if doStatusChange( status ) then
    Close;
end;

procedure TDetailView_WorkForm.click_����Ϸ�(ASender: TObject);
var
  status : TRnRDataStatus;
begin
  status := rrs����Ϸ�;

  if doStatusChange( status ) then
    Close;
end;

constructor TDetailView_WorkForm.Create(AOwner: TComponent);
begin
  inherited;

  btn_������û := TSakpungImageButton2.Create( nil );
  btn_����Ȯ�� := TSakpungImageButton2.Create( nil );
  btn_������� := TSakpungImageButton2.Create( nil );
  btn_����Ϸ� := TSakpungImageButton2.Create( nil );
end;

destructor TDetailView_WorkForm.Destroy;
begin
  FreeAndNil( btn_������û );
  FreeAndNil( btn_����Ȯ�� );
  FreeAndNil( btn_������� );
  FreeAndNil( btn_����Ϸ� );

  inherited;
end;

procedure TDetailView_WorkForm.doMemoSave(AMemo: string);
begin
  inherited;
end;

procedure TDetailView_WorkForm.doRoomInfoChange(ARoomInfo : TRoomInfo);
begin
  inherited;
end;

procedure TDetailView_WorkForm.initButton( AType : TRnRType );
var
  buttoncount : Integer;
  leftposition : Integer;
  btype : string;
begin
  if AType = rrReservation then
    buttoncount := 2
  else
    buttoncount := 3;

  button_panel.Width := ImageResourceDM.ButtonImageList80x26.Width * 2 + 5;
 // button_panel.Width := ImageResourceDM.ButtonImageList80x26.Width * buttoncount + 5*(buttoncount-1);
  leftposition := 0;

  if AType = rrReception then
  begin
//    btn_������û.Parent := button_panel;
//    btn_������û.Top := 0;
//    btn_������û.Left := leftposition;
//    btn_������û.PngImageList := ImageResourceDM.ButtonImageList80x26;
//    btn_������û.OnClick := click_������û;
//    ImageResourceDM.SetButtonImage(btn_������û, aibtButton1, BTN_Img_Detail_������û);
//    btn_������û.Visible := True;
//    Inc(leftposition, btn_������û.Width + 5);
      btn_����Ϸ�.Parent := button_panel;
      btn_����Ϸ�.Top := 0;
      btn_����Ϸ�.Left := leftposition;
      btn_����Ϸ�.PngImageList := ImageResourceDM.ButtonImageList80x26;
      btn_����Ϸ�.OnClick := click_����Ϸ�;
      ImageResourceDM.SetButtonImage(btn_����Ϸ�, aibtButton1, BTN_Img_Detail_����Ϸ�);
      btn_����Ϸ�.Visible := True;
      Inc(leftposition, btn_����Ϸ�.Width + 5);
  end;

//  btn_����Ȯ��.Parent := button_panel;
//  btn_����Ȯ��.Top := 0;
//  btn_����Ȯ��.Left := leftposition;
//  btn_����Ȯ��.PngImageList := ImageResourceDM.ButtonImageList80x26;
//  btn_����Ȯ��.OnClick := click_����Ȯ��;
//  ImageResourceDM.SetButtonImage(btn_����Ȯ��, aibtButton1, BTN_Img_Detail_����Ȯ��);
//  btn_����Ȯ��.Visible := True;
//  Inc(leftposition, btn_����Ȯ��.Width + 5);

  if AType = rrReservation then
    btype := BTN_Img_Detail_�������
  else
    btype := BTN_Img_Detail_�������;

  btn_�������.Parent := button_panel;
  btn_�������.Top := 0;
  btn_�������.Left := leftposition;
  btn_�������.PngImageList := ImageResourceDM.ButtonImageList80x26;
  btn_�������.OnClick := click_�������;
  ImageResourceDM.SetButtonImage(btn_�������, aibtButton1, btype);
  btn_�������.Visible := True;
end;

procedure TDetailView_WorkForm.ShowData(AData: TRnRData);
var
  str : string;
begin
  initButton( AData.DataType );

  inherited;

  str := '';
  if AData.isFirst then
    str := '(����) ';

  case AData.Status of
  rrs����Ϸ� : Label9.Caption := str + '���� Ȯ��';
  rrs�����Ϸ� : Label9.Caption := str + '���� �Ϸ�';
  rrs������û :
    begin
      Label9.Caption := str + '���� �Ϸ�';
      btn_������û.Enabled := False;
    end;
  end;

   if AData.Inflow = rriftablet then
   Label17.Caption := '�º���';

  if AData.Inflow = rrifApp then
   Label17.Caption := '�����';

end;

{ TDetailView_CancelForm }

constructor TDetailView_CancelForm.Create(AOwner: TComponent);
begin
  inherited;
  Label_Time := TLabel.Create( nil );
  Label_Memo := TLabel.Create( nil );


  initUI;
end;

destructor TDetailView_CancelForm.Destroy;
begin
  FreeAndNil( Label_Time );
  FreeAndNil( Label_Memo );

  inherited;
end;

procedure TDetailView_CancelForm.doMemoSave(AMemo: string);
begin
  inherited;
end;

procedure TDetailView_CancelForm.doRoomInfoChange(ARoomInfo : TRoomInfo);
begin
  inherited;
end;

procedure TDetailView_CancelForm.initUI;
var
  topposition : Integer;
begin
  button_panel.Visible := False;
  topposition := 15;

  Label_Time.Parent := Bottom_Panel;
  Label_Time.Top := topposition;
  Label_Time.Left := 10;
  Inc(topposition, Label_Time.Height + 5);

// ��Ҹ޽��� ���� 0918
//  Label_Memo.Parent := Bottom_Panel;
//  Label_Memo.Top := topposition;
//  Label_Memo.Left := 10;
//  Label_Memo.AutoSize := False;
//  Label_Memo.Width := Bottom_Panel.Width - Label_Memo.Left - 2;
//  Label_Memo.ShowHint := False;
end;

procedure TDetailView_CancelForm.ShowData(AData: TRnRData);
var
  BeforeConfirmation : Boolean;
  R: TRect;
  str, str2, s : string;
begin
  inherited;
  str2 := '';
  if AData.isFirst then
    str2 := '(����) ';

  BeforeConfirmation := AData.hsptlreceptndttm <> 0; // ����/���� Ȯ�� �Ͻ�

    str := '���';
  case AData.Status of
    rrs������� : Label9.Caption := str2 + 'ȯ�� ���'; // '���� ���';
    rrs�������� : Label9.Caption := str2 + '���� ���';
    rrs������� :
      begin
        if BeforeConfirmation then
        begin // Ȯ�� ��
          Label9.Caption := str2 + '���� ���';
        end
        else
        begin // Ȯ�� ��
          if AData.DataType = rrReception then
            Label9.Caption := str2 + '���� ���'
          else
            Label9.Caption := str2 + '���� �ź�';
        end;
      end;
    rrs������� :
      begin
        if BeforeConfirmation then
        begin // Ȯ�� ��
          Label9.Caption := str2 + 'ȯ�� öȸ';
        end
        else
        begin // Ȯ�� ��
          Label9.Caption := str2 + 'ȯ�� ���';
        end;
      end;
  else
    // Label9.Caption := '�ڵ� ���';
    Label9.Caption := str2 + '����';
    str := '����'
  end;


  //���� �߰� 0918
  if AData.Inflow = rriftablet then
   Label17.Caption := '�º���';

  if AData.Inflow = rrifApp then
   Label17.Caption := '�����';

//��Ҹ޽��� ����0918
//  s := AData.CanceledMessage;
//  UniqueString(S);
//  R := Label_Memo.ClientRect;
//  Label_Memo.Canvas.Font := Label_Memo.Font;
//  DrawText(Label_Memo.Canvas.Handle,  PChar(S), Length(S), R, DT_END_ELLIPSIS or DT_MODIFYSTRING or DT_NOPREFIX);
//
//  Label_Memo.Caption := s;
//  if AData.CanceledMessage <> s then
//  begin
//    Label_Memo.ShowHint := True;
//    Label_Memo.Hint := AData.CanceledMessage;
//  end;

  Label_Time.Caption := str + '�ð�: ' + FormatDateTime('yyyy-mm-dd hh:nn:ss', AData.CancelDT);

  roominfo.Enabled := False;
  SakpungImageButton1.Enabled := False;
  SakpungImageButton2.Enabled := False;
  SakpungImageButton3.Enabled := False;
  SakpungImageButton4.Enabled := False;
  SakpungImageButton3.Visible := False;
  SakpungImageButton4.Visible := False;
  Memo_Data.ReadOnly := True;
  Memo_Data.Color := cl3DLight;


//  reservationDate.Enabled := False;
//  reservationTime.Enabled := False;
//  SakpungImageButton5.Enabled := False;
//  SakpungImageButton10.Enabled := False;
end;

{ TDetailView_FinishForm }

constructor TDetailView_FinishForm.Create(AOwner: TComponent);
begin
  inherited;

end;

destructor TDetailView_FinishForm.Destroy;
begin

  inherited;
end;

procedure TDetailView_FinishForm.doMemoSave(AMemo: string);
begin
  inherited;

end;

procedure TDetailView_FinishForm.doRoomInfoChange(ARoomInfo : TRoomInfo);
begin
  inherited;

end;

procedure TDetailView_FinishForm.ShowData(AData: TRnRData);
var
  str : string;
begin
  inherited;

  str := '';
//  if AData.isFirst then
//    str := '(����) ';

  Label9.Caption := str + '���� �Ϸ�';

  roominfo.Enabled := False;
  SakpungImageButton1.Enabled := False;
  SakpungImageButton2.Enabled := False;
  SakpungImageButton3.Enabled := False;
  SakpungImageButton4.Enabled := False;
  SakpungImageButton3.Visible := False;
  SakpungImageButton4.Visible := False;
  Memo_Data.ReadOnly := True;
  Memo_Data.Color := cl3DLight;


  //�����߰� 0918
  if AData.Inflow = rriftablet then
   Label17.Caption := '�º���';

  if AData.Inflow = rrifApp then
   Label17.Caption := '�����';

//  reservationDate.Enabled := False;
//  reservationTime.Enabled := False;
//  SakpungImageButton5.Enabled := False;
//  SakpungImageButton10.Enabled := False;
end;


{ TDetailView_Reservation_WorkForm }

procedure TDetailView_Reservation_WorkForm.click_����Ȯ��(ASender: TObject);
begin
  ShowGDMsgDlg( '���� Ȯ�� ó���� ���� �ؾ� �Ѵ�.', GetTransFormHandle, mtInformation, [mbOK] )
end;


procedure TDetailView_Reservation_WorkForm.click_�������(ASender: TObject);
var
  form : TSelectCancelMSGForm;
begin
  form := TSelectCancelMSGForm.Create( self );
  try
    if form.ShowModal = mrYes then
    begin
      Memo_Data.Lines.Text := form.GetSelectMsg; // test �ڵ�
{ TODO : ������ ���� ������ ��� �۾� ���� }
    end;
  finally
    FreeAndNil( form );
  end;
end;

constructor TDetailView_Reservation_WorkForm.Create(AOwner: TComponent);
begin
  inherited;

  btn_����Ȯ�� := TSakpungImageButton2.Create( nil );
  btn_������� := TSakpungImageButton2.Create( nil );
  initButton;
end;

destructor TDetailView_Reservation_WorkForm.Destroy;
begin
  FreeAndNil( btn_����Ȯ�� );
  FreeAndNil( btn_������� );

  inherited;
end;

procedure TDetailView_Reservation_WorkForm.doMemoSave(AMemo: string);
begin
  inherited;
end;

procedure TDetailView_Reservation_WorkForm.doRoomInfoChange(ARoomInfo : TRoomInfo);
begin
  inherited;
end;

procedure TDetailView_Reservation_WorkForm.initButton;
var
  leftposition : Integer;
begin
  button_panel.Width := ImageResourceDM.ButtonImageList80x26.Width * 2 + 5;
  leftposition := 0;

  btn_����Ȯ��.Parent := button_panel;
  btn_����Ȯ��.Top := 0;
  btn_����Ȯ��.Left := leftposition;
  btn_����Ȯ��.PngImageList := ImageResourceDM.ButtonImageList80x26;
  btn_����Ȯ��.OnClick := click_����Ȯ��;
  ImageResourceDM.SetButtonImage(btn_����Ȯ��, aibtButton1, BTN_Img_Detail_����Ȯ��);
  btn_����Ȯ��.Visible := True;
  Inc(leftposition, btn_����Ȯ��.Width + 5);

  btn_�������.Parent := button_panel;
  btn_�������.Top := 0;
  btn_�������.Left := leftposition;
  btn_�������.PngImageList := ImageResourceDM.ButtonImageList80x26;
  btn_�������.OnClick := click_�������;
  ImageResourceDM.SetButtonImage(btn_�������, aibtButton1, BTN_Img_Detail_�������);
  btn_�������.Visible := True;
end;

procedure TDetailView_Reservation_WorkForm.ShowData(AData: TRnRData);
var
  str : string;
begin
  inherited;

  str := '';
  if AData.isFirst then
    str := '(����) ';

  if AData.Status = rrs����Ȯ�� then
    Label9.Caption := str + '���� Ȯ��'
  else
  begin
    Label9.Caption := str + '���� Ȯ��';
  end;

  //�����߰� 0918
  if AData.Inflow = rriftablet then
   Label17.Caption := '�º���';

  if AData.Inflow = rrifApp then
   Label17.Caption := '�����';
end;

{ TDetailView_VisiteDecide_WorkForm }

procedure TDetailView_VisiteDecide_WorkForm.click_����Ϸ�(
  ASender: TObject);
var
  status : TRnRDataStatus;
begin
  status := rrs����Ϸ�;

  if doStatusChange( status ) then
    Close;
end;

procedure TDetailView_VisiteDecide_WorkForm.click_���(ASender: TObject);
var
  status : TRnRDataStatus;
begin
  status := rrs�������;

  if doStatusChange( status ) then
    Close;
end;

constructor TDetailView_VisiteDecide_WorkForm.Create(AOwner: TComponent);
begin
  inherited;
  btn_����Ϸ� := TSakpungImageButton2.Create( nil );
  btn_��� := TSakpungImageButton2.Create( nil );
end;

destructor TDetailView_VisiteDecide_WorkForm.Destroy;
begin
  FreeAndNil( btn_����Ϸ� );
  FreeAndNil( btn_��� );
  inherited;
end;

procedure TDetailView_VisiteDecide_WorkForm.doMemoSave(AMemo: string);
begin
  inherited;
end;

procedure TDetailView_VisiteDecide_WorkForm.doRoomInfoChange(ARoomInfo : TRoomInfo);
begin
  inherited;
end;

procedure TDetailView_VisiteDecide_WorkForm.initButton( AType : TRnRType );
var
  leftposition : Integer;
  btype : string;
begin
  button_panel.Width := ImageResourceDM.ButtonImageList80x26.Width * 2 + 5;
  leftposition := 0;

  btn_����Ϸ�.Parent := button_panel;
  btn_����Ϸ�.Top := 0;
  btn_����Ϸ�.Left := leftposition;
  btn_����Ϸ�.PngImageList := ImageResourceDM.ButtonImageList80x26;
  btn_����Ϸ�.OnClick := click_����Ϸ�;
  ImageResourceDM.SetButtonImage(btn_����Ϸ�, aibtButton1, BTN_Img_Detail_����Ϸ�);
  btn_����Ϸ�.Visible := True;
  Inc(leftposition, btn_����Ϸ�.Width + 5);

  btn_���.Parent := button_panel;
  btn_���.Top := 0;
  btn_���.Left := leftposition;
  btn_���.PngImageList := ImageResourceDM.ButtonImageList80x26;
  btn_���.OnClick := click_���;

  if AType = rrReservation then
    btype := BTN_Img_Detail_�������
  else
    btype := BTN_Img_Detail_�������;

  ImageResourceDM.SetButtonImage(btn_���, aibtButton1, btype);
  btn_���.Visible := True;
end;

//�����Ϸ� form
procedure TDetailView_VisiteDecide_WorkForm.ShowData(AData: TRnRData);
var
  str : string;
begin
  inherited;
  initButton( AData.DataType );

  str := '';
  if AData.isFirst then
    str := '(����) ';

  Label9.Caption := str + '���� �Ϸ�';

  //�����߰� 0918
  if AData.Inflow = rriftablet then
   Label17.Caption := '�º���';

  if AData.Inflow = rrifApp then
   Label17.Caption := '�����';
end;

{ TClipboardMemo }

procedure TClipboardMemo.DefaultHandler(var Message);
var
  str : string;
begin
(*
  case TMessage(Message).Msg of
    WM_COPY, WM_CUT:
    begin
      //�޸𿡼� ���õ� ������ŭ�� ���� �Ǿ� �Ѵ�. todo
      str := '';
      for i := 0 to Lines.Count -1 do
      begin
        if str <> '' then
          str := str + ' ';
        str := str + Lines.Strings[ i ];
      end;
      Clipboard.AsText := str;
    end;
    else inherited DefaultHandler(Message);
  end;  *)

  (*
    readonly�� true�� ��� ctrl+x(wm_cut�� �߻� ���� �ʴ´�.
  *)
  inherited DefaultHandler(Message);
  case TMessage(Message).Msg of
    WM_COPY, WM_CUT:
    begin
      str := Clipboard.AsText;
      str := StringReplace(str, #13#10, ' ', [rfReplaceAll]);
      Clipboard.AsText := str;
    end;
  end;
end;


procedure TCustomRRDetailViewForm.Panel1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
const
  SC_DragMove = $F012;  { a magic number }
begin
  ReleaseCapture;
  self.perform(WM_SysCommand, SC_DragMove, 0);
end;


procedure TCustomRRDetailViewForm.CopyTimerTimer(Sender: TObject);
begin
 CopyTimer.Interval := 1000;
 CopyCom.Visible := false;
 CopyCom2.Visible := false;
 CopyCom3.Visible := false;
 CopyCom4.Visible := false;
end;


end.


//TDetailView_RequestForm ������û
//TDetailView_WorkForm �����Ϸ�
//TDetailView_CancelForm �������
//TDetailView_FinishForm ����Ϸ�