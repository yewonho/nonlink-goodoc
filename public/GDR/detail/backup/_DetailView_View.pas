unit DetailView_View;

interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  SakpungImageButton, SakpungStyleButton, CustomRRDetailView, RnRData;

type
  TDetailView_ViewForm = class(TCustomRRDetailViewForm)
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


implementation
uses
  RRDialogs,
  ImageResourceDMUnit, RnRDMUnit, SelectCancelMSG;

{ TDetailView_RequestForm }

constructor TDetailView_ViewForm.Create(AOwner: TComponent);
begin
  inherited;

  Label_Time := TLabel.Create( nil );
  Label_Memo := TLabel.Create( nil );

  initUI;
end;

destructor TDetailView_ViewForm.Destroy;
begin
  FreeAndNil( Label_Time );
  FreeAndNil( Label_Memo );

  inherited;
end;

procedure TDetailView_ViewForm.doMemoSave(AMemo: string);
begin
  inherited;
end;

procedure TDetailView_ViewForm.doRoomInfoChange(ARoomID,
  ARoomName: string);
begin
  inherited;
end;

procedure TDetailView_ViewForm.initUI;
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

procedure TDetailView_ViewForm.ShowData(AData: TRnRData);
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
