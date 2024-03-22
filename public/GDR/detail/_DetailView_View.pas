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
