unit ReceptionDialogUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Vcl.DBGrids, Vcl.StdCtrls, Vcl.ExtCtrls,
  DBDMUnit, Data.DB, BridgeCommUnit,
  MemDS, DBAccess, LiteAccess;

type
  TReceptionDialogForm = class(TForm)
    roomlist: TLiteTable;
    DataSource1: TDataSource;
    Panel1: TPanel;
    Label1: TLabel;
    DBGrid1: TDBGrid;
    DataSource2: TDataSource;
    LiteQuery1: TLiteQuery;
    Panel2: TPanel;
    Panel4: TPanel;
    LabeledEdit1: TLabeledEdit;
    LabeledEdit2: TLabeledEdit;
    DBGrid2: TDBGrid;
    Panel3: TPanel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button3Click(Sender: TObject);
    procedure LabeledEdit2KeyPress(Sender: TObject; var Key: Char);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    procedure search( ACellPhone, ARegNum : string );
  public
    { Public declarations }
    ResultObj : TBridgeRequest_100;
  end;

var
  ReceptionDialogForm: TReceptionDialogForm;

implementation
uses
  GlobalUnit;


{$R *.dfm}

procedure TReceptionDialogForm.Button1Click(Sender: TObject);
begin
  ResultObj := TBridgeRequest_100( GBridgeFactory.MakeRequestObj( EventID_접수요청 ) );
  ResultObj.PatntChartId := LiteQuery1.FieldByName( 'chartid' ).AsString;
  ResultObj.hospitalNo := GHospitalNo;
  ResultObj.PatntName := LiteQuery1.FieldByName( 'name' ).AsString;
  ResultObj.RegNum := LiteQuery1.FieldByName( 'regnum' ).AsString;
  ResultObj.CellPhone := LiteQuery1.FieldByName( 'cellphone' ).AsString;
  ResultObj.Sexdstn := LiteQuery1.FieldByName( 'sex' ).AsString;
  ResultObj.Birthday := LiteQuery1.FieldByName( 'birthday' ).AsString;
  ResultObj.addr := LiteQuery1.FieldByName( 'addr' ).AsString;
  ResultObj.addrDetail := LiteQuery1.FieldByName( 'addrdetail' ).AsString;
  ResultObj.zip := LiteQuery1.FieldByName( 'zip' ).AsString;

  ResultObj.RoomCode := roomlist.FieldByName( 'roomcode' ).AsString;
  ResultObj.RoomName := roomlist.FieldByName( 'roomname' ).AsString;
  ResultObj.DeptCode := roomlist.FieldByName( 'deptcode' ).AsString;
  ResultObj.DeptName := roomlist.FieldByName( 'deptname' ).AsString;
  ResultObj.DoctorCode := roomlist.FieldByName( 'doctorcode' ).AsString;
  ResultObj.DoctorName := roomlist.FieldByName( 'doctorname' ).AsString;

  ResultObj.ReceptionDttm := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss.zzz"Z"', now);

  ResultObj.ChartReceptionResultID1 := FormatDateTime('yyyymmddhhnnsszzz', now);
  ResultObj.ChartReceptionResultID2 := '';
  ResultObj.ChartReceptionResultID3 := '';
  ResultObj.ChartReceptionResultID4 := '';
  ResultObj.ChartReceptionResultID5 := '';
  ResultObj.ChartReceptionResultID6 := '';

  ModalResult := mrOk;
end;

procedure TReceptionDialogForm.Button2Click(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TReceptionDialogForm.Button3Click(Sender: TObject);
begin
  search(LabeledEdit1.Text, LabeledEdit2.Text);
end;

procedure TReceptionDialogForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caHide;
  roomlist.Active := False;
  LiteQuery1.Active := False;
end;

procedure TReceptionDialogForm.FormCreate(Sender: TObject);
begin
  ResultObj := nil;
end;

procedure TReceptionDialogForm.FormDestroy(Sender: TObject);
begin
  if Assigned( ResultObj ) then
    FreeAndNil( ResultObj );
end;

procedure TReceptionDialogForm.FormShow(Sender: TObject);
begin
  if Assigned( ResultObj ) then
    FreeAndNil( ResultObj );

  roomlist.Active := True;
  search('', '');
end;

procedure TReceptionDialogForm.LabeledEdit2KeyPress(Sender: TObject; var Key: Char);
begin
  if key = #13 then
  begin
    key := #0;
    Button3.Click; // 사용자 검색
  end;
end;

procedure TReceptionDialogForm.search(ACellPhone, ARegNum: string);
  function makewhere : string;
  var
    cp, rn : string;
  begin
    Result := '';
    if (ACellPhone = '') and (ARegNum = '') then
      exit;
    if ACellPhone <> '' then
      cp := Format('( cellphone like ''%%%s%%'' )',[ACellPhone]);
    if ACellPhone <> '' then
      rn := Format('( regnum like ''%%%s%%'' )',[ARegNum]);

    Result := cp;
    if rn <> '' then
      if Result = '' then
        Result := rn else Result := Result + ' and ' + rn;
  end;

begin
  LiteQuery1.Active := False;
  LiteQuery1.SQL.Clear;
  LiteQuery1.SQL.Add( 'select * from patient' );
  LiteQuery1.SQL.Add( makewhere );
  LiteQuery1.Active := True;
end;

end.
