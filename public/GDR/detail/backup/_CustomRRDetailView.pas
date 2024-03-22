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
  ���� ���� ��� �⺻ class
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
    procedure initButton; // window button�� image�� �ʱ�ȭ �Ѵ�.
  protected
    { protected declarations }
    procedure CreateParams(var Params: TCreateParams); override;
    procedure DoShow; override;

    procedure doRoomInfoChange( ARoomID, ARoomName : string ); virtual; // ���� ��ư Ŭ���� �߻� �Ѵ�.
    procedure doMemoSave( AMemo : string ); virtual; // ���� ��ư Ŭ���� �߻� �Ѵ�.
    procedure ShowData( AData : TRnRData ); virtual; // data�� ��� �Ѵ�.
  public
    { Public declarations }
    constructor Create( AOwner : TComponent ); override;

    function ShowDetailData( AData : TRnRData ) : Integer; virtual;
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

    procedure initButton;
  protected
    { protected declarations }
    procedure doRoomInfoChange( ARoomID, ARoomName : string ); override; // ���� ��ư Ŭ���� �߻� �Ѵ�.
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
    btn_�����ź� : TSakpungImageButton2;
    procedure click_������û( ASender : TObject );
    procedure click_����Ȯ��( ASender : TObject );
    procedure click_�����ź�( ASender : TObject );

    procedure initButton;
  protected
    { protected declarations }
    procedure doRoomInfoChange( ARoomID, ARoomName : string ); override; // ���� ��ư Ŭ���� �߻� �Ѵ�.
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
    procedure doRoomInfoChange( ARoomID, ARoomName : string ); override; // ���� ��ư Ŭ���� �߻� �Ѵ�.
    procedure doMemoSave( AMemo : string ); override; // ���� ��ư Ŭ���� �߻� �Ѵ�.
    procedure ShowData( AData : TRnRData ); override; // data�� ��� �Ѵ�.
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
  begin // ���� data
    if AData.Canceled = rrctUnknown  then
    begin // ��ҵ��� �ʴ� data�̴�.
      case AData.State of
        rrsRequest        : makeclass := TDetailView_RequestForm; // ���� ��û ����
        rrsDecide,
        rrsRequestVisite,
        rrsVisiteDecide   : makeclass := TDetailView_WorkForm; // ���� Ȯ���� �Ϸ�� ����, ���� ��� ����
        rrsFinish         : ; // ���� �Ϸ� ����
      end;

    end
    else
      makeclass := TDetailView_CancelForm;
  end
  else
  begin  // ���� data

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

  Label14.Caption := '����� ������ �����3�� 13,' +  #13#10 + '4��(���ﵿ �ɾ��Ÿ��)';
end;

procedure TCustomRRDetailViewForm.CreateParams(var Params: TCreateParams);
begin
  inherited;
  // borderstyle := bsNone; ���� ���� �� ����ؾ� �Ѵ�.

  //Params.Style := Params.Style or WS_THICKFRAME;   // captiond����, resize �ǰ�
  Params.Style := Params.Style or WS_BORDER; // caption����, border �ְ�, resize�ʵǰ�
  // Params.Style := Params.Style or WS_BORDER or WS_DLGFRAME; // caption�ְ�, system button����, resize �ʵǰ� , WS_CAPTION��� �ѰͰ� ����
  //Params.Style := Params.Style or WS_BORDER or WS_THICKFRAME; // captiond����, resize �ǰ�

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
(* main form ������ ��ܿ� ��ġ�Ѵ�.
position property�� ���� poDesigned�� ���� �ؾ� �Ѵ�.
  r := Application.MainForm.BoundsRect;

  r2 := BoundsRect;

  r2.Offset(r.Right- r2.Right, r.Top - r2.Top);
  BoundsRect := r2; *)

{ main form�� center�� ��µǱ� ���� position property�� ������.
  Position := poMainFormCenter; }

  ImportRoomInfo; // room ��� ���
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
{ TODO : roomid�� roomname�� combobox�� ���� �ϰ�, Ȱ�� �� �� �־�� �Ѵ�.}
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
{ TODO : roomid�� roomname�� ���� �� doRoomInfoChange�� ���� �� �� �־�� �Ѵ�. }
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

procedure TDetailView_RequestForm.click_�����ź�(ASender: TObject);
var
  form : TSelectCancelMSGForm;
begin
  form := TSelectCancelMSGForm.Create( self );
  try
    if form.ShowModal = mrYes then
    begin
      Memo1.Lines.Text := form.GetSelectMsg; // test �ڵ�
{ TODO : ������ ���� ������ ��� �۾� ���� }
    end;
  finally
    FreeAndNil( form );
  end;
end;

procedure TDetailView_RequestForm.click_����Ȯ��(ASender: TObject);
begin
  GDMessageDlg('���� Ȯ�� ó���� ���� �ؾ� �Ѵ�.', mtInformation, [mbOK], 0);
end;

constructor TDetailView_RequestForm.Create(AOwner: TComponent);
begin
  inherited;

  btn_����Ȯ�� := TSakpungImageButton2.Create( nil );
  btn_�����ź� := TSakpungImageButton2.Create( nil );
  initButton;
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
  GDMessageDlg('Memo ���� : ' + AMemo, mtInformation, [mbOK], 0);
end;

procedure TDetailView_RequestForm.doRoomInfoChange(ARoomID,
  ARoomName: string);
begin
  inherited;
  GDMessageDlg('Room Info ���� : ' + Format('%s, %s',[ARoomID, ARoomName]), mtInformation, [mbOK], 0);
end;

procedure TDetailView_RequestForm.initButton;
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

  btn_�����ź�.Parent := button_panel;
  btn_�����ź�.Top := 0;
  btn_�����ź�.Left := leftposition;
  btn_�����ź�.PngImageList := ImageResourceDM.ButtonImageList80x26;
  btn_�����ź�.OnClick := click_�����ź�;
  ImageResourceDM.SetButtonImage(btn_�����ź�, aibtButton1, BTN_Img_Detail_�����ź�);
  btn_�����ź�.Visible := True;
end;

procedure TDetailView_RequestForm.ShowData(AData: TRnRData);
begin
  inherited;
  Label9.Caption := '���� ��û';
end;

{ TDetailView_WorkForm }

procedure TDetailView_WorkForm.click_������û(ASender: TObject);
begin
  GDMessageDlg('���� ��û ó���� ���� �ؾ� �Ѵ�.', mtInformation, [mbOK], 0);
end;

procedure TDetailView_WorkForm.click_����Ȯ��(ASender: TObject);
begin
  GDMessageDlg('���� Ȯ�� ó���� ���� �ؾ� �Ѵ�.', mtInformation, [mbOK], 0);
end;

procedure TDetailView_WorkForm.click_�����ź�(ASender: TObject);
var
  form : TSelectCancelMSGForm;
begin
  form := TSelectCancelMSGForm.Create( self );
  try
    if form.ShowModal = mrYes then
    begin
      Memo1.Lines.Text := form.GetSelectMsg; // test �ڵ�
{ TODO : ������ ���� ������ ��� �۾� ���� }
    end;
  finally
    FreeAndNil( form );
  end;
end;

constructor TDetailView_WorkForm.Create(AOwner: TComponent);
begin
  inherited;

  btn_������û := TSakpungImageButton2.Create( nil );
  btn_����Ȯ�� := TSakpungImageButton2.Create( nil );
  btn_�����ź� := TSakpungImageButton2.Create( nil );
  initButton;
end;

destructor TDetailView_WorkForm.Destroy;
begin
  FreeAndNil( btn_������û );
  FreeAndNil( btn_����Ȯ�� );
  FreeAndNil( btn_�����ź� );

  inherited;
end;

procedure TDetailView_WorkForm.doMemoSave(AMemo: string);
begin
  inherited;
  GDMessageDlg('Memo ���� : ' + AMemo, mtInformation, [mbOK], 0);
end;

procedure TDetailView_WorkForm.doRoomInfoChange(ARoomID,
  ARoomName: string);
begin
  inherited;
  GDMessageDlg('Room Info ���� : ' + Format('%s, %s',[ARoomID, ARoomName]), mtInformation, [mbOK], 0);
end;

procedure TDetailView_WorkForm.initButton;
var
  leftposition : Integer;
begin
  button_panel.Width := ImageResourceDM.ButtonImageList80x26.Width * 3 + 5*2;
  leftposition := 0;

  btn_������û.Parent := button_panel;
  btn_������û.Top := 0;
  btn_������û.Left := leftposition;
  btn_������û.PngImageList := ImageResourceDM.ButtonImageList80x26;
  btn_������û.OnClick := click_������û;
  ImageResourceDM.SetButtonImage(btn_������û, aibtButton1, BTN_Img_Detail_������û);
  btn_������û.Visible := True;
  Inc(leftposition, btn_������û.Width + 5);

  btn_����Ȯ��.Parent := button_panel;
  btn_����Ȯ��.Top := 0;
  btn_����Ȯ��.Left := leftposition;
  btn_����Ȯ��.PngImageList := ImageResourceDM.ButtonImageList80x26;
  btn_����Ȯ��.OnClick := click_����Ȯ��;
  ImageResourceDM.SetButtonImage(btn_����Ȯ��, aibtButton1, BTN_Img_Detail_����Ȯ��);
  btn_����Ȯ��.Visible := True;
  Inc(leftposition, btn_����Ȯ��.Width + 5);

  btn_�����ź�.Parent := button_panel;
  btn_�����ź�.Top := 0;
  btn_�����ź�.Left := leftposition;
  btn_�����ź�.PngImageList := ImageResourceDM.ButtonImageList80x26;
  btn_�����ź�.OnClick := click_�����ź�;
  ImageResourceDM.SetButtonImage(btn_�����ź�, aibtButton1, BTN_Img_Detail_�����ź�);
  btn_�����ź�.Visible := True;
end;

procedure TDetailView_WorkForm.ShowData(AData: TRnRData);
begin
  inherited;

  if AData.DataType = rrReception then
    Label9.Caption := '���� Ȯ��'
  else
    Label9.Caption := '���� Ȯ��';
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
        Label9.Caption := '����Ϸ�'
    end;
    Label_Memo.Caption := '���� �Ϸ�';
  end
  else if AData.Canceled = rrctHospital then
  begin
    Label9.Caption := '���� ���';
    Label_Memo.Caption := AData.CanceledMessage;
  end
  else
  begin
    Label9.Caption := 'ȯ�� ���';
    Label_Memo.Caption := AData.CanceledMessage;
  end;
{ TODO : db�� �ԷµǾ� �ִ� �Ϸ�ð�/��� �ð��� ����� �� �ְ� �ؾ� �Ѵ� }
  Label_Time.Caption := FormatDateTime('yyyy-mm-dd hh:nn:ss', now);
end;

end.
