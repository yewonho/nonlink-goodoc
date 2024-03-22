unit CustomRRDetailView;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  SakpungImageButton, Vcl.Grids, SakpungStyleButton, RnRData;

type
  TComboBox = class(Vcl.StdCtrls.TComboBox)
  protected
    { protected declarations }
    procedure WndProc(var Message: TMessage); override;
    procedure DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState); override;
  end;

  TRRDetailViewClass = class of TCustomRRDetailViewForm;
{
  접수 정보 출력 기본 class
}
  TCustomRRDetailViewForm = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Bottom_Panel: TPanel;
    Label1: TLabel;
    button_panel: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    ComboBox1: TComboBox;
    Label20: TLabel;
    Memo1: TMemo;
    Bevel1: TBevel;
    close_btn: TSakpungImageButton2;
    SakpungImageButton3: TSakpungImageButton;
    SakpungImageButton4: TSakpungImageButton;
    Bevel2: TBevel;
    procedure Bottom_PanelResize(Sender: TObject);
    procedure close_btnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SakpungImageButton3Click(Sender: TObject);
    procedure SakpungImageButton4Click(Sender: TObject);
  private
    { Private declarations }
    procedure ImportRoomInfo;
    procedure initButton; // window button의 image를 초기화 한다.
  protected
    { protected declarations }
    procedure CreateParams(var Params: TCreateParams); override;
    procedure DoShow; override;

    procedure doRoomInfoChange( ARoomID, ARoomName : string ); virtual; // 변경 버튼 클릭시 발생 한다.
    procedure doMemoSave( AMemo : string ); virtual; // 저장 버튼 클릭시 발생 한다.
    procedure ShowData( AData : TRnRData ); virtual; // data를 출력 한다.
  public
    { Public declarations }
    constructor Create( AOwner : TComponent ); override;

    function ShowDetailData( AData : TRnRData ) : Integer; virtual;
  end;

{
  접수 요청 상태에서 처리 하는 class
}
  TDetailView_RequestForm = class(TCustomRRDetailViewForm)
  private
    { Private declarations }
    btn_접수확정 : TSakpungImageButton2;
    btn_접수거부 : TSakpungImageButton2;
    procedure click_접수확정( ASender : TObject );
    procedure click_접수거부( ASender : TObject );

    procedure initButton;
  protected
    { protected declarations }
    procedure doRoomInfoChange( ARoomID, ARoomName : string ); override; // 변경 버튼 클릭시 발생 한다.
    procedure doMemoSave( AMemo : string ); override; // 저장 버튼 클릭시 발생 한다.
    procedure ShowData( AData : TRnRData ); override; // data를 출력 한다.
  public
    { Public declarations }
    constructor Create( AOwner : TComponent ); override;
    destructor Destroy; override;
  end;

{
  접수 확정 상태에서 내원요청/내원확인 처리 하는 class
}
  TDetailView_WorkForm = class(TCustomRRDetailViewForm)
  private
    { Private declarations }
    btn_내원요청 : TSakpungImageButton2;
    btn_내원확인 : TSakpungImageButton2;
    btn_접수거부 : TSakpungImageButton2;
    procedure click_내원요청( ASender : TObject );
    procedure click_내원확인( ASender : TObject );
    procedure click_접수거부( ASender : TObject );

    procedure initButton;
  protected
    { protected declarations }
    procedure doRoomInfoChange( ARoomID, ARoomName : string ); override; // 변경 버튼 클릭시 발생 한다.
    procedure doMemoSave( AMemo : string ); override; // 저장 버튼 클릭시 발생 한다.
    procedure ShowData( AData : TRnRData ); override; // data를 출력 한다.
  public
    { Public declarations }
    constructor Create( AOwner : TComponent ); override;
    destructor Destroy; override;
  end;

{
  취소 상태에서 내용 조회하는 class
}
  TDetailView_CancelForm = class(TCustomRRDetailViewForm)
  private
    { Private declarations }
    Label_Time : TLabel;
    Label_Memo : TLabel;
    procedure initUI;
  protected
    { protected declarations }
    procedure doRoomInfoChange( ARoomID, ARoomName : string ); override; // 변경 버튼 클릭시 발생 한다.
    procedure doMemoSave( AMemo : string ); override; // 저장 버튼 클릭시 발생 한다.
    procedure ShowData( AData : TRnRData ); override; // data를 출력 한다.
  public
    { Public declarations }
    constructor Create( AOwner : TComponent ); override;
    destructor Destroy; override;
  end;


function MakeDetailClass( AData : TRnRData ) : TCustomRRDetailViewForm;

implementation
uses
  RRDialogs,
  TranslucentFormUnit, RnRDMUnit, ImageResourceDMUnit, SelectCancelMSG;

{$R *.dfm}

function MakeDetailClass( AData : TRnRData ) : TCustomRRDetailViewForm;
var
  makeclass : TRRDetailViewClass;
begin
  makeclass := nil;

  if AData.DataType = rrReception then
  begin // 접수 data
    if AData.Canceled = rrctUnknown  then
    begin // 취소되지 않는 data이다.
      case AData.State of
        rrsRequest        : makeclass := TDetailView_RequestForm; // 접수 요청 상태
        rrsDecide,
        rrsRequestVisite,
        rrsVisiteDecide   : makeclass := TDetailView_WorkForm; // 내원 확인이 완료된 상태, 진료 대기 상태
        rrsFinish         : ; // 진료 완료 상태
      end;

    end
    else
      makeclass := TDetailView_CancelForm;
  end
  else
  begin  // 에약 data

  end;
end;

{ TCustomRRDetailViewForm }

procedure TCustomRRDetailViewForm.close_btnClick(Sender: TObject);
begin
  Close;
end;

constructor TCustomRRDetailViewForm.Create(AOwner: TComponent);
begin
  inherited;

  button_panel.BorderStyle := bsNone;

  Label14.Caption := '서울시 강남구 역삼로3길 13,' +  #13#10 + '4층(역삼동 케어랩스타워)';
end;

procedure TCustomRRDetailViewForm.CreateParams(var Params: TCreateParams);
begin
  inherited;
  // borderstyle := bsNone; 으로 설정 후 사용해야 한다.

  //Params.Style := Params.Style or WS_THICKFRAME;   // captiond없고, resize 되고
  Params.Style := Params.Style or WS_BORDER; // caption없고, border 있고, resize않되고
  // Params.Style := Params.Style or WS_BORDER or WS_DLGFRAME; // caption있고, system button없고, resize 않되고 , WS_CAPTION사용 한것과 같다
  //Params.Style := Params.Style or WS_BORDER or WS_THICKFRAME; // captiond없고, resize 되고

  // trans
  Params.WndParent := GetTransFormHandle;
end;

procedure TCustomRRDetailViewForm.doMemoSave(AMemo: string);
begin

end;

procedure TCustomRRDetailViewForm.doRoomInfoChange(ARoomID, ARoomName: string);
begin

end;

procedure TCustomRRDetailViewForm.DoShow;
(*var
  r, r2 : TRect;*)
begin
  inherited;
(* main form 오른쪽 상단에 위치한다.
position property의 값을 poDesigned로 설정 해야 한다.
  r := Application.MainForm.BoundsRect;

  r2 := BoundsRect;

  r2.Offset(r.Right- r2.Right, r.Top - r2.Top);
  BoundsRect := r2; *)

{ main form의 center에 출력되기 위에 position property를 수정함.
  Position := poMainFormCenter; }

  ImportRoomInfo; // room 목록 출력
end;

procedure TCustomRRDetailViewForm.FormShow(Sender: TObject);
begin
  initButton;
end;

procedure TCustomRRDetailViewForm.ImportRoomInfo;
begin
  ComboBox1.Items.Clear;
  with RnRDM do
  begin
    Room_DB.First;
    ComboBox1.Items.Add( '-' );
    while not Room_DB.Eof do
    begin
{ TODO : roomid와 roomname을 combobox에 저장 하고, 활용 할 수 있어야 한다.}
      ComboBox1.Items.Add( Room_DB.FieldByName( 'roomname' ).AsString );
      //ComboBox1.Items.AddObject(Room_DB.FieldByName( 'roomname' ).AsString, Room_DB.FieldByName( 'roomid' ).AsString);
      Room_DB.Next;
    end;
  end;
  ComboBox1.ItemIndex := 0;
end;

procedure TCustomRRDetailViewForm.initButton;
begin
  close_btn.PngImageList := ImageResourceDM.WindowButtonImageList;
  ImageResourceDM.SetButtonImage(close_btn, aibtButton1, BTN_Img_Win_Close);
end;

procedure TCustomRRDetailViewForm.Bottom_PanelResize(Sender: TObject);
begin
  button_panel.Left := ( Bottom_Panel.Width - button_panel.Width ) div 2;
end;

procedure TCustomRRDetailViewForm.SakpungImageButton3Click(Sender: TObject);
begin
{ TODO : roomid와 roomname을 인지 후 doRoomInfoChange를 실행 할 수 있어야 한다. }
  doRoomInfoChange( '', ComboBox1.Text );
end;

procedure TCustomRRDetailViewForm.SakpungImageButton4Click(Sender: TObject);
begin
  doMemoSave( Memo1.Lines.Text );
end;

procedure TCustomRRDetailViewForm.ShowData(AData: TRnRData);
begin

end;

function TCustomRRDetailViewForm.ShowDetailData(AData: TRnRData): Integer;
begin
  ShowData(AData);
  Result := ShowModal;
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

procedure TDetailView_RequestForm.click_접수거부(ASender: TObject);
var
  form : TSelectCancelMSGForm;
begin
  form := TSelectCancelMSGForm.Create( self );
  try
    if form.ShowModal = mrYes then
    begin
      Memo1.Lines.Text := form.GetSelectMsg; // test 코드
{ TODO : 선택한 접수 정보의 취소 작업 진행 }
    end;
  finally
    FreeAndNil( form );
  end;
end;

procedure TDetailView_RequestForm.click_접수확정(ASender: TObject);
begin
  GDMessageDlg('접수 확정 처리를 진행 해야 한다.', mtInformation, [mbOK], 0);
end;

constructor TDetailView_RequestForm.Create(AOwner: TComponent);
begin
  inherited;

  btn_접수확정 := TSakpungImageButton2.Create( nil );
  btn_접수거부 := TSakpungImageButton2.Create( nil );
  initButton;
end;

destructor TDetailView_RequestForm.Destroy;
begin
  FreeAndNil( btn_접수확정 );
  FreeAndNil( btn_접수거부 );

  inherited;
end;

procedure TDetailView_RequestForm.doMemoSave(AMemo: string);
begin
  inherited;
  GDMessageDlg('Memo 저장 : ' + AMemo, mtInformation, [mbOK], 0);
end;

procedure TDetailView_RequestForm.doRoomInfoChange(ARoomID,
  ARoomName: string);
begin
  inherited;
  GDMessageDlg('Room Info 변경 : ' + Format('%s, %s',[ARoomID, ARoomName]), mtInformation, [mbOK], 0);
end;

procedure TDetailView_RequestForm.initButton;
var
  leftposition : Integer;
begin
  button_panel.Width := ImageResourceDM.ButtonImageList80x26.Width * 2 + 5;
  leftposition := 0;

  btn_접수확정.Parent := button_panel;
  btn_접수확정.Top := 0;
  btn_접수확정.Left := leftposition;
  btn_접수확정.PngImageList := ImageResourceDM.ButtonImageList80x26;
  btn_접수확정.OnClick := click_접수확정;
  ImageResourceDM.SetButtonImage(btn_접수확정, aibtButton1, BTN_Img_Detail_접수확정);
  btn_접수확정.Visible := True;

  Inc(leftposition, btn_접수확정.Width + 5);

  btn_접수거부.Parent := button_panel;
  btn_접수거부.Top := 0;
  btn_접수거부.Left := leftposition;
  btn_접수거부.PngImageList := ImageResourceDM.ButtonImageList80x26;
  btn_접수거부.OnClick := click_접수거부;
  ImageResourceDM.SetButtonImage(btn_접수거부, aibtButton1, BTN_Img_Detail_접수거부);
  btn_접수거부.Visible := True;
end;

procedure TDetailView_RequestForm.ShowData(AData: TRnRData);
begin
  inherited;
  Label9.Caption := '접수 요청';
end;

{ TDetailView_WorkForm }

procedure TDetailView_WorkForm.click_내원요청(ASender: TObject);
begin
  GDMessageDlg('내원 요청 처리를 진행 해야 한다.', mtInformation, [mbOK], 0);
end;

procedure TDetailView_WorkForm.click_내원확인(ASender: TObject);
begin
  GDMessageDlg('내원 확인 처리를 진행 해야 한다.', mtInformation, [mbOK], 0);
end;

procedure TDetailView_WorkForm.click_접수거부(ASender: TObject);
var
  form : TSelectCancelMSGForm;
begin
  form := TSelectCancelMSGForm.Create( self );
  try
    if form.ShowModal = mrYes then
    begin
      Memo1.Lines.Text := form.GetSelectMsg; // test 코드
{ TODO : 선택한 접수 정보의 취소 작업 진행 }
    end;
  finally
    FreeAndNil( form );
  end;
end;

constructor TDetailView_WorkForm.Create(AOwner: TComponent);
begin
  inherited;

  btn_내원요청 := TSakpungImageButton2.Create( nil );
  btn_내원확인 := TSakpungImageButton2.Create( nil );
  btn_접수거부 := TSakpungImageButton2.Create( nil );
  initButton;
end;

destructor TDetailView_WorkForm.Destroy;
begin
  FreeAndNil( btn_내원요청 );
  FreeAndNil( btn_내원확인 );
  FreeAndNil( btn_접수거부 );

  inherited;
end;

procedure TDetailView_WorkForm.doMemoSave(AMemo: string);
begin
  inherited;
  GDMessageDlg('Memo 저장 : ' + AMemo, mtInformation, [mbOK], 0);
end;

procedure TDetailView_WorkForm.doRoomInfoChange(ARoomID,
  ARoomName: string);
begin
  inherited;
  GDMessageDlg('Room Info 변경 : ' + Format('%s, %s',[ARoomID, ARoomName]), mtInformation, [mbOK], 0);
end;

procedure TDetailView_WorkForm.initButton;
var
  leftposition : Integer;
begin
  button_panel.Width := ImageResourceDM.ButtonImageList80x26.Width * 3 + 5*2;
  leftposition := 0;

  btn_내원요청.Parent := button_panel;
  btn_내원요청.Top := 0;
  btn_내원요청.Left := leftposition;
  btn_내원요청.PngImageList := ImageResourceDM.ButtonImageList80x26;
  btn_내원요청.OnClick := click_내원요청;
  ImageResourceDM.SetButtonImage(btn_내원요청, aibtButton1, BTN_Img_Detail_내원요청);
  btn_내원요청.Visible := True;
  Inc(leftposition, btn_내원요청.Width + 5);

  btn_내원확인.Parent := button_panel;
  btn_내원확인.Top := 0;
  btn_내원확인.Left := leftposition;
  btn_내원확인.PngImageList := ImageResourceDM.ButtonImageList80x26;
  btn_내원확인.OnClick := click_내원확인;
  ImageResourceDM.SetButtonImage(btn_내원확인, aibtButton1, BTN_Img_Detail_내원확인);
  btn_내원확인.Visible := True;
  Inc(leftposition, btn_내원확인.Width + 5);

  btn_접수거부.Parent := button_panel;
  btn_접수거부.Top := 0;
  btn_접수거부.Left := leftposition;
  btn_접수거부.PngImageList := ImageResourceDM.ButtonImageList80x26;
  btn_접수거부.OnClick := click_접수거부;
  ImageResourceDM.SetButtonImage(btn_접수거부, aibtButton1, BTN_Img_Detail_접수거부);
  btn_접수거부.Visible := True;
end;

procedure TDetailView_WorkForm.ShowData(AData: TRnRData);
begin
  inherited;

  if AData.DataType = rrReception then
    Label9.Caption := '접수 확정'
  else
    Label9.Caption := '예약 확정';
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

procedure TDetailView_CancelForm.doRoomInfoChange(ARoomID,
  ARoomName: string);
begin
  inherited;
end;

procedure TDetailView_CancelForm.initUI;
var
  topposition : Integer;
begin
  button_panel.Visible := False;
  topposition := 5;

  Label_Time.Parent := Bottom_Panel;
  Label_Time.Top := topposition;
  Label_Time.Left := 10;
  Inc(topposition, Label_Time.Height + 5);

  Label_Memo.Parent := Bottom_Panel;
  Label_Memo.Top := topposition;
  Label_Memo.Left := 10;
end;

procedure TDetailView_CancelForm.ShowData(AData: TRnRData);
begin
  inherited;

  if AData.Canceled = rrctUnknown then
  begin
    case AData.State of
  //    rrsRequest,
  //    rrsDecide,
  //    rrsRequestVisite,
  //    rrsVisiteDecide,
      rrsFinish :
        Label9.Caption := '진료완료'
    end;
    Label_Memo.Caption := '진료 완료';
  end
  else if AData.Canceled = rrctHospital then
  begin
    Label9.Caption := '병원 취소';
    Label_Memo.Caption := AData.CanceledMessage;
  end
  else
  begin
    Label9.Caption := '환자 취소';
    Label_Memo.Caption := AData.CanceledMessage;
  end;
{ TODO : db에 입력되어 있는 완료시간/취소 시간을 사용할 수 있게 해야 한다 }
  Label_Time.Caption := FormatDateTime('yyyy-mm-dd hh:nn:ss', now);
end;

end.
