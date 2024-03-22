unit RRDetailView_Request;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  SakpungImageButton, Vcl.Grids, SakpungStyleButton;

type
  TComboBox = class(Vcl.StdCtrls.TComboBox)
  protected
    { protected declarations }
    procedure WndProc(var Message: TMessage); override;
    procedure DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState); override;
  end;

  TRRDetailView_RequestForm = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Label1: TLabel;
    Panel4: TPanel;
    SakpungImageButton1: TSakpungImageButton;
    SakpungImageButton2: TSakpungImageButton;
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
    procedure Panel3Resize(Sender: TObject);
    procedure SakpungImageButton2Click(Sender: TObject);
    procedure close_btnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure ImportRoomInfo;
    procedure initButton; // window button의 image를 초기화 한다.
  protected
    { protected declarations }
    procedure CreateParams(var Params: TCreateParams); override;
    procedure DoShow; override;
  public
    { Public declarations }
    constructor Create( AOwner : TComponent ); override;
  end;

var
  RRDetailView_RequestForm: TRRDetailView_RequestForm;

implementation
uses
  TranslucentFormUnit, RnRDMUnit, SelectCancelMSG, ImageResourceDMUnit;

{$R *.dfm}

{ TRRDetailView_RequestForm }

procedure TRRDetailView_RequestForm.close_btnClick(Sender: TObject);
begin
  Close;
end;

constructor TRRDetailView_RequestForm.Create(AOwner: TComponent);
begin
  inherited;

  Label14.Caption := '서울시 강남구 역삼로3길 13,' +  #13#10 + '4층(역삼동 케어랩스타워)';
end;

procedure TRRDetailView_RequestForm.CreateParams(var Params: TCreateParams);
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

procedure TRRDetailView_RequestForm.DoShow;
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

procedure TRRDetailView_RequestForm.FormShow(Sender: TObject);
begin
  initButton;
end;

procedure TRRDetailView_RequestForm.ImportRoomInfo;
begin
  ComboBox1.Items.Clear;
  with RnRDM do
  begin
    Room_DB.First;
    ComboBox1.Items.Add( '-' );
    while not Room_DB.Eof do
    begin
      ComboBox1.Items.Add( Room_DB.FieldByName( 'roomname' ).AsString );
      //ComboBox1.Items.AddObject(Room_DB.FieldByName( 'roomname' ).AsString, Room_DB.FieldByName( 'roomid' ).AsString);
      Room_DB.Next;
    end;
  end;
  ComboBox1.ItemIndex := 0;
end;

procedure TRRDetailView_RequestForm.initButton;
begin
  close_btn.PngImageList := ImageResourceDM.WindowButtonImageList;
  ImageResourceDM.SetButtonImage(close_btn, aibtButton1, BTN_Img_Win_Close);
end;

procedure TRRDetailView_RequestForm.Panel3Resize(Sender: TObject);
begin
  Panel4.Left := ( Panel3.Width - Panel4.Width ) div 2;
end;

procedure TRRDetailView_RequestForm.SakpungImageButton2Click(Sender: TObject);
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

end.
