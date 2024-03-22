unit RoomListDialogUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Vcl.DBGrids, Vcl.StdCtrls, Vcl.ExtCtrls,
  DBDMUnit, Data.DB, BridgeCommUnit, GlobalUnit,
  MemDS, DBAccess, LiteAccess;

type
  TRoomListDialogForm = class(TForm)
    roomlist: TLiteTable;
    DataSource1: TDataSource;
    Panel1: TPanel;
    Label1: TLabel;
    DBGrid1: TDBGrid;
    Panel3: TPanel;
    Button1: TButton;
    Button2: TButton;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    LastSelectRoomInfo : TRoomInfoRecord;
  end;

var
  RoomListDialogForm: TRoomListDialogForm;

implementation

{$R *.dfm}

procedure TRoomListDialogForm.Button1Click(Sender: TObject);
begin
  LastSelectRoomInfo.RoomCode := roomlist.FieldByName( 'roomcode' ).AsString;
  LastSelectRoomInfo.RoomName := roomlist.FieldByName( 'roomname' ).AsString;
  LastSelectRoomInfo.DeptCode := roomlist.FieldByName( 'deptcode' ).AsString;
  LastSelectRoomInfo.DeptName := roomlist.FieldByName( 'deptname' ).AsString;
  LastSelectRoomInfo.DoctorCode := roomlist.FieldByName( 'doctorcode' ).AsString;
  LastSelectRoomInfo.DoctorName := roomlist.FieldByName( 'doctorname' ).AsString;

  ModalResult := mrOk;
end;

procedure TRoomListDialogForm.Button2Click(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TRoomListDialogForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caHide;
  roomlist.Active := False;
end;

procedure TRoomListDialogForm.FormShow(Sender: TObject);
begin
  roomlist.Active := True;
end;


end.
