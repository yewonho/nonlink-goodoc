unit CancelMsgListMNG;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  SakpungImageButton, Vcl.Grids, SakpungStyleButton, RnRData, {GDGrid,} RRGridDrawUnit,
  ImageResourceDMUnit, RRObserverUnit;

type
  TCancelMsgListMNGForm = class(TForm)
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
    procedure ReloadCancelMsgList; // ����� ����� �ٽ� �о� ����.

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
  CancelMsgListMNGForm: TCancelMsgListMNGForm;

implementation
uses
  TranslucentFormUnit, RRConst, EventIDConst, RREnvUnit, RnRDMUnit,
  BridgeWrapperUnit, BridgeCommUnit;

{$R *.dfm}

{ TCancelMsgListMNGForm }

procedure TCancelMsgListMNGForm.AfterEventNotify(AEventID: Cardinal;
  AData: TObserverData);
begin

end;

procedure TCancelMsgListMNGForm.BeforeEventNotify(AEventID: Cardinal;
  AData: TObserverData);
begin

end;

procedure TCancelMsgListMNGForm.Button1Click(Sender: TObject);
begin
  ReloadCancelMsgList;
  SetGridUI;
end;

procedure TCancelMsgListMNGForm.Button2Click(Sender: TObject);
begin
  Close;
end;

procedure TCancelMsgListMNGForm.ClearGrid;
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

procedure TCancelMsgListMNGForm.close_btnClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

constructor TCancelMsgListMNGForm.Create(AOwner: TComponent);
begin
  inherited;
  FGridDrawCell := TNormalGridListDrawCell.Create;
  FGridDrawCell.ListGrid := listgrid;

  FObserver := TRRObserver.Create( nil );
  FObserver.OnBeforeAction := BeforeEventNotify;
  FObserver.OnAfterAction := AfterEventNotify;
end;

procedure TCancelMsgListMNGForm.CreateParams(var Params: TCreateParams);
begin
  inherited;
  // borderstyle := bsNone; ���� ���� �� ����ؾ� �Ѵ�.

  //Params.Style := Params.Style or WS_THICKFRAME;   // captiond����, resize �ǰ�
  Params.Style := Params.Style or WS_BORDER; // caption����, border �ְ�, resize�ʵǰ�
  // Params.Style := Params.Style or WS_BORDER or WS_DLGFRAME; // caption�ְ�, system button����, resize �ʵǰ� , WS_CAPTION��� �ѰͰ� ����
  //Params.Style := Params.Style or WS_BORDER or WS_THICKFRAME; // captiond����, resize �ǰ�
end;

destructor TCancelMsgListMNGForm.Destroy;
begin
  ClearGrid;  // grid�� ��ϵǾ� �ִ� object ����

  FreeAndNil( FGridDrawCell );

  FreeAndNil( FObserver );

  inherited;
end;

procedure TCancelMsgListMNGForm.DoShow;
begin
  inherited;

  SetGridUI;
end;


procedure TCancelMsgListMNGForm.FormShow(Sender: TObject);
begin
  initButton;

  FormStyle := Application.MainForm.FormStyle;
end;

procedure TCancelMsgListMNGForm.initButton;
begin
  close_btn.PngImageList := ImageResourceDM.WindowButtonImageList;
  ImageResourceDM.SetButtonImage(close_btn, aibtButton1, BTN_Img_Win_Close);
end;

procedure TCancelMsgListMNGForm.ReloadCancelMsgList;
// ��� �޽��� ��� ��û �� ó���ؼ� db�� ���� �Ѵ�.
var
  event303 : string;
  event_302 : TBridgeRequest_302;
  baseresponse : TBridgeResponse;
  event_303 : TBridgeResponse_303;
begin
  event_302 := TBridgeRequest_302( GetBridgeFactory.MakeRequestObj( EventID_��Ҹ޽�����Ͽ�û ) );
  try
    event_302.HospitalNo := GetRREnv.HospitalID;
    event303 := BridgeWrapperDM.RequestResponse( event_302.ToJsonString );

    baseresponse := GetBridgeFactory.MakeResponseObj( event303 );
    try
      if baseresponse.EventID <> EventID_��Ҹ޽�����Ͽ�û��� then
      begin // error ó��
        exit;
      end;
      event_303 := TBridgeResponse_303( baseresponse );

      // ���ŵ� room ������ table�� ���� �Ѵ�.
      RnRDM.PackCancelMsgTable( event_303 );
    finally
      FreeAndNil( baseresponse );
    end;
  finally
    FreeAndNil( event_302);
  end;
end;

procedure TCancelMsgListMNGForm.SetGridUI;
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

      str := '"��� �޽���","�⺻��"';
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
        CancelMsg_DB.First;
        while not CancelMsg_DB.Eof do
        begin
          Cells[0, rowcnt] := CancelMsg_DB.FieldByName('cancelmsg').AsString;
          if CancelMsg_DB.FieldByName('default').AsBoolean then
            Cells[1, rowcnt] := '�⺻����'
          else
            Cells[1, rowcnt] := '';

          Inc( rowcnt );
          RowCount := rowcnt;

          CancelMsg_DB.Next;
        end;
      end;
    end;
  finally
    listgrid.Perform(WM_SETREDRAW, 1, 0);   // endupdate
    listgrid.Invalidate;
  end;
end;

function TCancelMsgListMNGForm.ShowModal: Integer;
begin
  SetWindowLong(Handle, GWL_HWNDPARENT, Application.ActiveFormHandle );
  Result := inherited ShowModal;
end;

end.
