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


implementation
uses
  RRDialogs,
  ImageResourceDMUnit, RnRDMUnit, SelectCancelMSG;

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

end.
