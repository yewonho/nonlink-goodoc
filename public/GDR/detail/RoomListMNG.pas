unit RoomListMNG;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  SakpungImageButton, Vcl.Grids, SakpungStyleButton, RnRData, {GDGrid,} RRGridDrawUnit,
  ImageResourceDMUnit, RRObserverUnit;

type
  TRoomListMNGForm = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Panel3: TPanel;
    listgrid: TStringGrid;
    close_btn: TSakpungImageButton2;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Label3: TLabel;
    Button1: TButton;
    Button2: TButton;
    procedure Panel3Resize(Sender: TObject);
    procedure close_btnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    FGridDrawCell : TNormalGridListDrawCell;

    procedure SetGridUI;  // grid�� �ʱ� UI�� ���� �Ѵ�.
    procedure ClearGrid;

    procedure initButton; // window button�� image�� �ʱ�ȭ �Ѵ�.
    procedure ReloadRoomList; // ����� ����� �ٽ� �о� ����.

  private
    { Private declarations }
    FObserver : TRRObserver;
    procedure BeforeEventNotify( AEventID : Cardinal; AData : TObserverData );
    procedure AfterEventNotify( AEventID : Cardinal; AData : TObserverData );
  protected
    { protected declarations }
    procedure CreateParams(var Params: TCreateParams); override;
    procedure DoShow; override;
  public
    { Public declarations }
    constructor Create( AOwner : TComponent ); override;
    destructor Destroy; override;

    function ShowModal: Integer; override;
  end;

var
  RoomListMNGForm: TRoomListMNGForm;

implementation
uses
  TranslucentFormUnit, RRConst, EventIDConst, RREnvUnit, RnRDMUnit,
  BridgeWrapperUnit, BridgeCommUnit;

{$R *.dfm}

{ TRoomListMNGForm }

procedure TRoomListMNGForm.AfterEventNotify(AEventID: Cardinal;
  AData: TObserverData);
begin

end;

procedure TRoomListMNGForm.BeforeEventNotify(AEventID: Cardinal;
  AData: TObserverData);
begin

end;

procedure TRoomListMNGForm.Button1Click(Sender: TObject);
begin
  ReloadRoomList;
  SetGridUI;
end;

procedure TRoomListMNGForm.Button2Click(Sender: TObject);
begin
  Close;
end;

procedure TRoomListMNGForm.ClearGrid;
var
  i, j : Integer;
  o : TObject;
begin
  with listgrid do
  begin
    for i := 0 to RowCount-1 do
    begin
      for j := 0 to ColCount do
      begin
        o := Objects[j, i];
        if Assigned( o ) then
        begin
          Objects[j, i] := nil;
          FreeAndNil( o );
        end;
      end;
    end;
  end;
end;

procedure TRoomListMNGForm.close_btnClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

constructor TRoomListMNGForm.Create(AOwner: TComponent);
begin
  inherited;
  FGridDrawCell := TNormalGridListDrawCell.Create;
  FGridDrawCell.ListGrid := listgrid;

  FObserver := TRRObserver.Create( nil );
  FObserver.OnBeforeAction := BeforeEventNotify;
  FObserver.OnAfterAction := AfterEventNotify;
end;

procedure TRoomListMNGForm.CreateParams(var Params: TCreateParams);
begin
  inherited;
  // borderstyle := bsNone; ���� ���� �� ����ؾ� �Ѵ�.

  //Params.Style := Params.Style or WS_THICKFRAME;   // captiond����, resize �ǰ�
  Params.Style := Params.Style or WS_BORDER; // caption����, border �ְ�, resize�ʵǰ�
  // Params.Style := Params.Style or WS_BORDER or WS_DLGFRAME; // caption�ְ�, system button����, resize �ʵǰ� , WS_CAPTION��� �ѰͰ� ����
  //Params.Style := Params.Style or WS_BORDER or WS_THICKFRAME; // captiond����, resize �ǰ�
end;

destructor TRoomListMNGForm.Destroy;
begin
  ClearGrid;  // grid�� ��ϵǾ� �ִ� object ����

  FreeAndNil( FGridDrawCell );

  FreeAndNil( FObserver );

  inherited;
end;

procedure TRoomListMNGForm.DoShow;
begin
  inherited;

  SetGridUI;
end;


procedure TRoomListMNGForm.FormShow(Sender: TObject);
begin
  initButton;
  FormStyle := Application.MainForm.FormStyle;
end;

procedure TRoomListMNGForm.initButton;
begin
  close_btn.PngImageList := ImageResourceDM.WindowButtonImageList;
  ImageResourceDM.SetButtonImage(close_btn, aibtButton1, BTN_Img_Win_Close);
end;

procedure TRoomListMNGForm.Panel3Resize(Sender: TObject);
begin
//  SakpungImageButton1.Left := (Panel3.Width - SakpungImageButton1.Width) div 2;
end;

procedure TRoomListMNGForm.ReloadRoomList;
// ��⿭ ��� ��û �� ó���ؼ� db�� ���� �Ѵ�.
var
  event403 : string;
  event_402 : TBridgeRequest_402;
  baseresponse : TBridgeResponse;
  event_403 : TBridgeResponse_403;
begin
  event_402 := TBridgeRequest_402( GetBridgeFactory.MakeRequestObj( EventID_��⿭��Ͽ�û ) );
  try
    event_402.HospitalNo := GetRREnv.HospitalID;

    event403 := BridgeWrapperDM.RequestResponse( event_402.ToJsonString );
    baseresponse := GetBridgeFactory.MakeResponseObj( event403 );
    try
      if baseresponse.EventID <> EventID_��⿭��Ͽ�û��� then
      begin // error ó��
        exit;
      end;
      event_403 := TBridgeResponse_403( baseresponse );

      FObserver.BeforeAction(OB_Event_RoomInfo_Change);
      try
        // ���ŵ� room ������ table�� ���� �Ѵ�.
        RnRDM.PackRoomTable( event_403 );
      finally
        FObserver.AfterAction(OB_Event_RoomInfo_Change);
      end;
    finally
      FreeAndNil( baseresponse );
    end;
  finally
    FreeAndNil( event_402);
  end;
end;

procedure TRoomListMNGForm.SetGridUI;
var
  i, rowcnt : Integer;
  str : string;
begin
  listgrid.Perform(WM_SETREDRAW, 0, 0);   // begineupdate
  try
    ClearGrid;
    with listgrid do
    begin
      RowCount := 2;

      str := '"�����(�ڵ�)","����(�ڵ�)","�ǻ�(�ڵ�)"';
      Rows[ 0 ].CommaText := str;

      str := '';
      for i := 0 to ColCount do
      begin
        if str <> '' then
          str := str + ',';
        str := str + '""';
      end;
      Rows[ 1 ].CommaText := str;

      rowcnt := 1;
      with RnRDM do
      begin
        Room_DB.First;
        while not Room_DB.Eof do
        begin
          Cells[0, rowcnt] := Format('%s(%s)',[ Room_DB.FieldByName('roomname').AsString, Room_DB.FieldByName('roomcode').AsString ]);
          Cells[1, rowcnt] := Format('%s(%s)',[ Room_DB.FieldByName('deptname').AsString, Room_DB.FieldByName('deptcode').AsString ]);
          Cells[2, rowcnt] := Format('%s(%s)',[ Room_DB.FieldByName('doctorname').AsString, Room_DB.FieldByName('doctorcode').AsString ]);

          Inc( rowcnt );
          RowCount := rowcnt;

          Room_DB.Next;
        end;
      end;
    end;
  finally
    listgrid.Perform(WM_SETREDRAW, 1, 0);   // endupdate
    listgrid.Invalidate;
  end;
end;

function TRoomListMNGForm.ShowModal: Integer;
begin
  SetWindowLong(Handle, GWL_HWNDPARENT, Application.ActiveFormHandle );
  Result := inherited ShowModal;
end;

end.
