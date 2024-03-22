unit DetailView_Work;

interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  SakpungImageButton, SakpungStyleButton, CustomRRDetailView, RnRData;

type
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


implementation
uses
  RRDialogs,
  ImageResourceDMUnit, RnRDMUnit, SelectCancelMSG;

{ TDetailView_RequestForm }

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

end.
