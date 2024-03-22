unit AccountRequestUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  EPBridgeCommUnit, BridgeCommUnit;

type
  TAccountRequestForm = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    ComboBox1: TComboBox;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    totalAmt_edit: TEdit;
    nhisAmt_edit: TEdit;
    userAmt_edit: TEdit;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure totalAmt_editChange(Sender: TObject);
    procedure totalAmt_editKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
    chartReceptnResultId : TChartReceptnResultId;
    resultCd , resultMsg : string;
    payAuthNo : string;
    planMonth : string;
    transDttm : string;
    userAmt, totalAmt, nhisAmt : LongWord;
  end;

var
  AccountRequestForm: TAccountRequestForm;

implementation
uses
  System.UITypes, AccountDMUnit;

var
  PlanMonthCode : array [0..11] of string = ('M0', 'M2', 'M3', 'M4', 'M5', 'M6', 'M7', 'M8', 'M9', 'M10', 'M11', 'M12');


{$R *.dfm}

procedure TAccountRequestForm.Button1Click(Sender: TObject);

  function GetPlanMonth : string;
  var
    item : TMonthListItem;
  begin
    //Result := PlanMonthCode[ ComboBox1.ItemIndex ];
    Result := 'M0';
    item := TMonthListItem( ComboBox1.Items.Objects[ComboBox1.ItemIndex] );
    if not Assigned( item ) then
      exit;
    Result := item.cd;
  end;

var
  cur : TCursor;
  ret : TBridgeResponse_143;
begin
  payAuthNo := '';
  resultCd := '';
  resultMsg := '';
  transDttm := '';

  totalAmt := StrToUIntDef(totalAmt_edit.Text, 0);
  nhisAmt := StrToUIntDef(nhisAmt_edit.Text, 0);
  userAmt := totalAmt - nhisAmt;

  if userAmt > AccountDM.PriceAmt then
  begin
    MessageDlg( '환자 부담금이 결제 가능 금액을 초과 하였습니다!' + #13#10 + format('결제 가능 금액 : %s',[  FormatFloat('#,0',AccountDM.PriceAmt) ]), mtWarning, [mbOK], 0);
    exit;
  end;


  planMonth := GetPlanMonth;

  cur := Screen.Cursor;
  try
    Screen.Cursor := crAppStart;
    ret := AccountDM.Send142( chartReceptnResultId, totalAmt, nhisAmt, userAmt, planMonth );
    if not Assigned( ret ) then
    begin
      MessageDlg( '결제를 실패 하였습니다.' + #13#10 + '알수 없는 상태 입니다. 관리자에게 문의 하세요!', mtError, [mbOK], 0);
      exit;
    end;
  finally
    Screen.Cursor := cur;
  end;
  try
    if ret.Code <> Result_SuccessCode then
    begin
      MessageDlg( ret.MessageStr, mtError, [mbOK], 0);
      exit;
    end;

    if ret.resultCd <> '00' then
    begin // error가 있다.
      MessageDlg( ret.resultMsg, mtError, [mbOK], 0);
      exit;
    end;

    resultCd := ret.resultCd;
    resultMsg := ret.resultMsg;
    payAuthNo := ret.payAuthNo;
    transDttm := ret.transDttm;
  finally
    FreeAndNil( ret );
  end;

  MessageDlg( '결제가 완료되었습니다.', mtInformation, [mbOK], 0);
  ModalResult := mrOk;
end;

procedure TAccountRequestForm.Button2Click(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TAccountRequestForm.FormShow(Sender: TObject);
var
  i : Integer;
  item : TMonthListItem;
begin
  Label4.Caption := '환자 부담금' + #13#10 + '(결제 금액)';

  ComboBox1.Items.Clear;
  for i := 0 to AccountDM.MonthListCount -1 do
  begin
    item := AccountDM.MonthList[ i ];
    ComboBox1.Items.AddObject(item.nm, item);
  end;
  ComboBox1.ItemIndex := 0;
end;

procedure TAccountRequestForm.totalAmt_editChange(Sender: TObject);
var
  c1, c2, c3 : LongWord;
begin
  c2 := StrToUIntDef(totalAmt_edit.Text, 0);
  c3 := StrToUIntDef(nhisAmt_edit.Text, 0);
  c1 := c2 - c3;
  userAmt_edit.Text := FormatFloat('#,0', c1);

  if c1 <= AccountDM.PriceAmt then
    userAmt_edit.Color := clWindow
  else
    userAmt_edit.Color := clRed;
end;

procedure TAccountRequestForm.totalAmt_editKeyPress(Sender: TObject;
  var Key: Char);
var
  v : Int64;
begin
  v := StrToInt64Def( TEdit(Sender).Text, 0);
  if v >= 999999999 then
  begin
    if key >= #32 then
      Key := #0;
  end;
end;

end.
