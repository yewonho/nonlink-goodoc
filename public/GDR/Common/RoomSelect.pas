unit RoomSelect;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.ExtCtrls, Vcl.Grids, SakpungImageButton,
  Vcl.StdCtrls, TranslucentFormUnit,
  RnRData, Vcl.AppEvnts;

type
  TRoomInfoData = class
  public
    { Public declarations }
    RoomCode : string;
    RoomName : string;
    DeptCode, DeptName, DoctorCode, DoctorName : string;
  end;

  TRoomSelectForm = class(TTranslucentSubForm)
    Bevel2: TBevel;
    Panel2: TPanel;
    Label1: TLabel;
    close_btn: TSakpungImageButton2;
    Bevel1: TBevel;
    Panel3: TPanel;
    Bevel3: TBevel;
    Panel4: TPanel;
    SakpungImageButton1: TSakpungImageButton;
    Panel5: TPanel;
    Panel1: TPanel;
    RoomGrid: TStringGrid;
    procedure RoomGridMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure RoomGridMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure RoomGridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure RoomGridClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClick(Sender: TObject);
    procedure close_btnClick(Sender: TObject);
    procedure Panel3Resize(Sender: TObject);
    procedure SakpungImageButton1Click(Sender: TObject);
    procedure Panel5Resize(Sender: TObject);
  private
    { Private declarations }
    iskeydown : Boolean;
    FSelectRoomInfo : TRoomInfo;

    procedure SetUI;
    procedure ClearUI;
    procedure initButton; // window button의 image를 초기화 한다.
  protected
    { protected declarations }
    procedure CreateParams( var AParams : TCreateParams ); override;
  public
    { Public declarations }
    function ShowRoomSelect( var ARoomInfo : TRoomInfo ) : Integer;

    constructor Create( AOwner : TComponent ); override;
    destructor Destroy; override;
  end;

const  // 진료실 목록 출력
  GDC_RoomSelect_Title      = $006DB10D;
  GDC_RoomSelect_TitleFont  = clWhite;
  //GDC_RoomSelect_SelectItem =  $00C8F6B8;
  GDC_RoomSelect_SelectItem = $00FFEFD5;

var
  RoomSelectForm: TRoomSelectForm;

function ShowRoomSelect( var ARoomInfo : TRoomInfo ) : TModalResult;

function GetRoomSelectForm : TRoomSelectForm;

implementation
uses
  System.Types, ImageResourceDMUnit,
  RnRDMUnit;

{$R *.dfm}

function ShowRoomSelect( var ARoomInfo : TRoomInfo ) : TModalResult;
var
  form : TRoomSelectForm;
begin
  ARoomInfo.RoomCode := ''; ARoomInfo.RoomName := '';
  ARoomInfo.DeptCode := ''; ARoomInfo.DeptName := '';
  ARoomInfo.DoctorCode := ''; ARoomInfo.DoctorName := '';
  form := GetRoomSelectForm;
  try
    Result := TModalResult( form.ShowRoomSelect( ARoomInfo ) );
  finally
    FreeAndNil( form );
  end;
end;

function GetRoomSelectForm : TRoomSelectForm;
begin
  Result := TRoomSelectForm.Create( nil );
end;

procedure TRoomSelectForm.ClearUI;
var
  i : Integer;
  data : TObject;
begin
  for i := 0 to RoomGrid.RowCount -1 do
  begin
    data := RoomGrid.Objects[0, i];
    if Assigned(data) then
    begin
      RoomGrid.Objects[0, i] := nil;
      FreeAndNil( data );
    end;
  end;
end;

procedure TRoomSelectForm.close_btnClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

constructor TRoomSelectForm.Create(AOwner: TComponent);
begin
  inherited;
  iskeydown := False;
end;

procedure TRoomSelectForm.CreateParams(var AParams: TCreateParams);
begin
  inherited;
end;

destructor TRoomSelectForm.Destroy;
begin
  ClearUI;

  inherited;
end;

procedure TRoomSelectForm.FormClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TRoomSelectForm.FormShow(Sender: TObject);
begin
  initButton; // form의 button에 image 연결

  FormStyle := Application.MainForm.FormStyle;

  RoomGrid.SetFocus;
end;

procedure TRoomSelectForm.initButton;
begin
  close_btn.PngImageList := ImageResourceDM.WindowButtonImageList;
  ImageResourceDM.SetButtonImage(close_btn, aibtButton1, BTN_Img_Win_Close);
end;

procedure TRoomSelectForm.Panel3Resize(Sender: TObject);
begin
  Panel4.Left := ( Panel3.Width - Panel4.Width ) div 2;
end;

procedure TRoomSelectForm.Panel5Resize(Sender: TObject);
begin
  Panel1.Left := (Panel5.Width - Panel1.Width) div 2;
  Panel1.Top := (Panel5.Height - Panel1.Height) div 2;
end;

procedure TRoomSelectForm.SakpungImageButton1Click(Sender: TObject);
var
  data : TRoomInfoData;
begin
  data := TRoomInfoData( RoomGrid.Objects[ 0, RoomGrid.Row ] );
  if Assigned( data ) then
  begin
    FSelectRoomInfo.RoomCode := data.RoomCode;
    FSelectRoomInfo.RoomName := data.RoomName;
    FSelectRoomInfo.DeptCode := data.DeptCode;
    FSelectRoomInfo.DeptName := data.DeptName;
    FSelectRoomInfo.DoctorCode := data.DoctorCode;
    FSelectRoomInfo.DoctorName := data.DoctorName;
  end;

  ModalResult := mrOk;
end;

procedure TRoomSelectForm.SetUI;
var
  index : Integer;
  data : TRoomInfoData;
begin
  RoomGrid.Perform(WM_SETREDRAW, 0, 0);   // begineupdate
  try
    ClearUI;

    index := 0;
    RnRDM.Room_DB.First;
    while not RnRDM.Room_DB.Eof do
    begin
      data := TRoomInfoData.Create;
      data.RoomCode := RnRDM.Room_DB.FieldByName( 'roomcode' ).AsString;
      data.RoomName := RnRDM.Room_DB.FieldByName( 'roomname' ).AsString;
      data.DeptCode := RnRDM.Room_DB.FieldByName( 'deptcode' ).AsString;
      data.DeptName := RnRDM.Room_DB.FieldByName( 'deptname' ).AsString;
      data.DoctorCode := RnRDM.Room_DB.FieldByName( 'doctorcode' ).AsString;
      data.DoctorName := RnRDM.Room_DB.FieldByName( 'doctorname' ).AsString;

      RoomGrid.Cells[0, index] := data.RoomName;
      RoomGrid.Objects[0, index] := data;

      RnRDM.Room_DB.Next;
      Inc( index );
    end;
    RoomGrid.RowCount := index;
  finally
    RoomGrid.Perform(WM_SETREDRAW, 1, 0);   // endupdate
    RoomGrid.Invalidate;
  end;
end;

function TRoomSelectForm.ShowRoomSelect(var ARoomInfo : TRoomInfo ): Integer;
begin
  SetUI;

  Result := ShowModal;
  if Result = mrOk then
  begin
    ARoomInfo.RoomCode := FSelectRoomInfo.RoomCode;
    ARoomInfo.RoomName := FSelectRoomInfo.RoomName;
    ARoomInfo.DeptCode := FSelectRoomInfo.DeptCode;
    ARoomInfo.Deptname := FSelectRoomInfo.DeptName;
    ARoomInfo.DoctorCode := FSelectRoomInfo.DoctorCode;
    ARoomInfo.DoctorName := FSelectRoomInfo.DoctorName;
  end;
end;

procedure TRoomSelectForm.RoomGridClick(Sender: TObject);
(* var
  data : TRoomInfoData; *)
begin
(*  if iskeydown then
    exit;

  data := TRoomInfoData( RoomGrid.Objects[ 0, RoomGrid.Row ] );
  if Assigned( data ) then
  begin
    FSelectRoomName := data.RoomName;
    FSelectRoomID := data.RoomID;

    if FSelectRoomName <> '' then
    begin
      ModalResult := mrOk;
    end;
  end; *)
end;

procedure TRoomSelectForm.RoomGridDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  data : string;
  sg : TStringGrid;
begin
  sg := TStringGrid( Sender );

  if gdSelected in State then
    sg.Canvas.Brush.Color := GDC_RoomSelect_SelectItem
  else
    sg.Canvas.Brush.Color := clWhite;

  sg.Canvas.Brush.Style := bsSolid;
  sg.Canvas.Pen.Style := psClear;
  sg.Canvas.FillRect(Rect);
  sg.Canvas.FrameRect( Rect );

  data := sg.Cells[ACol, ARow];

  sg.Canvas.Font.Assign( sg.Font );
  sg.Canvas.TextRect(Rect, data, [tfCenter, tfVerticalCenter, tfSingleLine, tfEndEllipsis]);
end;

procedure TRoomSelectForm.RoomGridMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  // mouse wheel로 인해 click event가 발생되지 않게 코드 추가함.
  Handled := True;
end;

procedure TRoomSelectForm.RoomGridMouseWheelUp(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  // mouse wheel로 인해 click event가 발생되지 않게 코드 추가함.
  Handled := True;
end;

initialization

finalization

end.
