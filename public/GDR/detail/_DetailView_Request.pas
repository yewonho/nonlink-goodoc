unit DetailView_Request;

interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  SakpungImageButton, SakpungStyleButton, CustomRRDetailView, RnRData;

type
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


implementation
uses
  RRDialogs,
  ImageResourceDMUnit, RnRDMUnit, SelectCancelMSG;

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

end.
