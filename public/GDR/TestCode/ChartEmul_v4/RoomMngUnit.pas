unit RoomMngUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Data.DB, Vcl.Grids,
  Vcl.DBGrids, DBDMUnit, MemDS, DBAccess, LiteAccess, Vcl.StdCtrls, Vcl.DBCtrls,
  BridgeCommUnit, GlobalUnit;

type
  TRoomMngForm = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    DBGrid1: TDBGrid;
    LiteQuery1: TLiteQuery;
    DataSource1: TDataSource;
    DBNavigator1: TDBNavigator;
    Button1: TButton;
    LiteQuery2: TLiteQuery;
    Edit1: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure LiteQuery1AfterPost(DataSet: TDataSet);
    procedure LiteQuery1BeforeInsert(DataSet: TDataSet);
  private
    { Private declarations }
    procedure DeleteRoomInfo;
  public
    { Public declarations }
    procedure ChangeUI( AParentCtrl : TWinControl );
    procedure UpdateRoomInfo( AEvent403 : TBridgeResponse_403 );

    function GetRoomInfo( ARoomCode : string ) : TRoomInfoRecord;

    procedure DBRefresh;
  end;

var
  RoomMngForm: TRoomMngForm;

implementation
uses
  GDBridge,
  RoomListDialogUnit, ReceptionMngUnit;

{$R *.dfm}

{ TPatientMngForm }

procedure TRoomMngForm.Button1Click(Sender: TObject);
begin
  LiteQuery1.Active := False;
  LiteQuery1.SQL.Text := 'select * from room';
  LiteQuery1.Active := True;
  initDBGridWidth( DBGrid1 );
end;

procedure TRoomMngForm.ChangeUI(AParentCtrl: TWinControl);
begin
  if Assigned( AParentCtrl ) then
  begin
    Panel1.Parent := AParentCtrl;
    Panel1.Align := alClient;
  end
  else
    Panel1.Parent := Self;
end;

procedure TRoomMngForm.DBRefresh;
begin
  Button1.Click;
end;

procedure TRoomMngForm.DeleteRoomInfo;
begin
  LiteQuery1.Active := False;
  LiteQuery2.Active := False;
  with LiteQuery2 do
  begin
    SQL.Text := 'delete from room ';
    ExecSQL;
  end;
end;

function TRoomMngForm.GetRoomInfo(ARoomCode: string): TRoomInfoRecord;
begin
  with Result do
  begin
    RoomCode := '';
    RoomName := '';
    DeptCode := '';
    DeptName := '';
    DoctorCode := '';
    DoctorName := '';
  end;

  if ARoomCode = '' then
    exit;

  LiteQuery2.Active := False;
  with LiteQuery2 do
  begin
    SQL.Clear;
    SQL.Add( 'select * from room ' );
    SQL.Add( 'where ' );
    SQL.Add( 'roomcode = :roomcode ' );
    ParamByName( 'roomcode' ).Value := ARoomCode;
    Active := True;
    First;
    if not eof then
    begin
      with Result do
      begin
        RoomCode := FieldByName( 'roomcode' ).AsString;
        RoomName := FieldByName( 'roomname' ).AsString;
        DeptCode := FieldByName( 'deptcode' ).AsString;
        DeptName := FieldByName( 'deptname' ).AsString;
        DoctorCode := FieldByName( 'doctorcode' ).AsString;
        DoctorName := FieldByName( 'doctorname' ).AsString;
      end;
    end;
  end;
  LiteQuery2.Active := False;
end;

procedure TRoomMngForm.LiteQuery1AfterPost(DataSet: TDataSet);
begin
  DBGrid1.Options := [dgTitles,dgIndicator,dgColumnResize,dgColLines,dgRowLines,dgTabs,dgRowSelect,dgAlwaysShowSelection,dgConfirmDelete,dgCancelOnExit,dgTitleClick,dgTitleHotTrack];
end;

procedure TRoomMngForm.LiteQuery1BeforeInsert(DataSet: TDataSet);
begin
  DBGrid1.Options := [dgEditing,dgTitles,dgIndicator,dgColumnResize,dgColLines,dgRowLines,dgTabs,dgConfirmDelete,dgCancelOnExit,dgTitleClick,dgTitleHotTrack];
end;

procedure TRoomMngForm.UpdateRoomInfo(AEvent403 : TBridgeResponse_403);
var
  i : Integer;
  item : TRoomListItem;
begin
  DeleteRoomInfo;
  Button1.Click;

  for i := 0 to AEvent403.RoomListCount -1 do
  begin
    item := AEvent403.RoomLists[ i ];
    LiteQuery1.Append;
      LiteQuery1.FieldByName( 'roomcode' ).AsString := item.RoomCode;
      LiteQuery1.FieldByName( 'roomname' ).AsString := item.RoomName;
      LiteQuery1.FieldByName( 'deptcode' ).AsString := item.DeptCode;
      LiteQuery1.FieldByName( 'deptname' ).AsString := item.DeptName;
      LiteQuery1.FieldByName( 'doctorcode' ).AsString := item.DoctorCode;
      LiteQuery1.FieldByName( 'doctorname' ).AsString := item.DoctorName;
    LiteQuery1.Post;
  end;
end;

end.
