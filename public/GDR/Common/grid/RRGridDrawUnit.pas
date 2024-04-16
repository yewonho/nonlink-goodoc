unit RRGridDrawUnit;

interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Grids, RnRData;

type
  TGridDataType = (gdtRequest, gdtReception, gdtReservation);              // ���� type, ����/����

  TCustomGridListDrawCell = class
  private
    { Private declarations }
    FListGrid: TStringGrid;
    FOldDrawCellEvent : TDrawCellEvent;
    FSelectColor: TColor;
    FLineColor: TColor;
    FGridDataType: TGridDataType;
    procedure SetListGrid(const Value: TStringGrid);
  protected
    { protected declarations }
    //grid component�� ��ϵǾ� �ִ� event�� ���� ��Ų��.
    procedure doUserDrawCellEvent(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);

    procedure ListDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState); virtual;
  public
    { Public declarations }
    // data�� ���¿� ���� ���°��� string���� �����.
    function GetState( AData : TRnRData ) : string;
    function GetState_DeviceType( AData : TRnRData ) : string; // device type���� �����Ͽ� ���°� ���
    function GetState_FontColor( AData: TRnRData ) : TColor; // ���¿� ���� font color�� ��ȯ �Ѵ�.

    // fixed������ text�� ��� �Ѵ�.
    procedure FixedCell( AGrid : TStringGrid; ACol, ARow: Integer; ARect: TRect );
    // ������ ������ text�� ��� �Ѵ�.
    procedure DrawCenterText(AGrid : TStringGrid; ARect: TRect; AText : string);
    // ������ ������ text�� ��� �Ѵ�.
    procedure DrawLeftText(AGrid : TStringGrid; ARect: TRect; AText : string);
    // ������ ������ text�� ��� �Ѵ�.
    procedure DrawRightText(AGrid : TStringGrid; ARect: TRect; AText : string);

    // ������ ������ �������� text�� ��� �Ѵ�.
    procedure DrawTopCenterText(AGrid : TStringGrid; ARect: TRect; AText : string);

    // ������ ������ text�� ��� �Ѵ�. �̸� ��� style
    procedure DrawCenterTextNameStyle(AGrid : TStringGrid; ARect: TRect; AText : string);

    // grid�� �޸�ǥ�ø� ���� �ﰢ�� �׸���
    procedure triangleDraw( AGrid : TStringGrid; ARect : TRect );

    function Col_Index_State : integer;
    function Col_Index_PatientName : integer;
    function Col_Index_Room : integer;
    function Col_Index_BirthDayRegNum : integer;
    function Col_Index_Time : integer;
    //function Col_Index_Time2 : integer;
    function Col_Index_Button1 : integer;
    function Col_Index_Button2 : integer;
    function Col_Index_Symptom : integer;
    function Col_Index_isFirst : integer;
  public
    { Public declarations }
    constructor Create; virtual;
    destructor Destroy; override;

    // ����� hint�� ���� �Ѵ�.
    function makeHint( AData : TRnRData ) : string; virtual;

    property ListGrid : TStringGrid read FListGrid write SetListGrid;
    property SelectColor : TColor read FSelectColor write FSelectColor;
    property LineColor : TColor read FLineColor write FLineColor;
    property GridDataType : TGridDataType read FGridDataType write FGridDataType;  // ���� �⺻��
  end;

  TNormalGridListDrawCell = class(TCustomGridListDrawCell)
  private
    { Private declarations }
  protected
    { protected declarations }
    procedure ListDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState); override;
  public
    { Public declarations }
  public
    { Public declarations }
    constructor Create; override;
    destructor Destroy; override;
  end;

  TGridListDrawCell = class(TCustomGridListDrawCell)
  private
    { Private declarations }
  protected
    { protected declarations }
    procedure ListDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState); override;
  public
    { Public declarations }
    // ����� hint�� ���� �Ѵ�.
    function makeHint( AData : TRnRData ) : string; override;
  public
    { Public declarations }
    constructor Create; override;
    destructor Destroy; override;
  end;

  // ����/���� ��� ��½� ����
  TRRGridListDrawCell = class(TCustomGridListDrawCell)
  private
    { Private declarations }
  protected
    { protected declarations }
    procedure ListDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState); override;
  public
    { Public declarations }
  public
    { Public declarations }
    constructor Create; override;
    destructor Destroy; override;
  end;

  // ���� ��� ��½� ����
  TReservationGridListDrawCell = class(TCustomGridListDrawCell)
  private
    { Private declarations }
  protected
    { protected declarations }
    procedure ListDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState); override;
  public
    { Public declarations }
    // ����� hint�� ���� �Ѵ�.
    function makeHint( AData : TRnRData ) : string;  override;
  public
    { Public declarations }
    constructor Create; override;
    destructor Destroy; override;
  end;

  TCancelMsgGridDrawCell = class(TCustomGridListDrawCell)
  private
    { Private declarations }
  protected
    { protected declarations }
    procedure ListDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState); override;
  public
    { Public declarations }
    // ����� hint�� ���� �Ѵ�.
  public
    { Public declarations }
    constructor Create; override;
    destructor Destroy; override;
  end;


  TMonthGridDrawCell = class(TCustomGridListDrawCell)
  private
    { Private declarations }
    FDay: TDate;
    // ��µǴ� cell�� ���� ���� data���� Ȯ�� �Ѵ�.
    function checkToDay( ACol, ARow : Integer ) : Boolean;
  protected
    { protected declarations }
    procedure ListDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState); override;
  public
    { Public declarations }
    property Day : TDate read FDay write FDay;
  public
    { Public declarations }
    constructor Create; override;
    destructor Destroy; override;

    // ���ڷ� col, row�� ��� �Ѵ�.
    procedure CalcDate2ColRow( ADate : TDate; var ACol, ARow : Integer );
  end;

const  // ��� cell�� index��
//  Col7_Index_State             = 0; //����
//  Col7_Index_PatientName       = 1; //�̸�
//  Col7_Index_Room              = 2; // �����
//  Col7_Index_BirthDayRegNum    = 3; //�������/�ֹι�ȣ
//  Col7_Index_Symptom           = 4; //�����ͤ�����
//  Col7_Index_Time              = 5; // ����/�����ð�, ���� �ð�, ���� �ð�
//  Col7_Index_Button1           = 6; // 1�� ��ư
//  Col7_Index_Button2           = 7; // 2�� ��ư

  Col7_Index_Button1           = 0; // 1�� ��ư(����)
  Col7_Index_State             = 1; //����(����)
  Col7_Index_isFirst           = 2; // ȯ������
  Col7_Index_PatientName       = 3; //�̸�
  Col7_Index_Room              = 4; // �����
  Col7_Index_BirthDayRegNum    = 5; //�������/�ֹι�ȣ
  Col7_Index_Symptom           = 6; //��������
  Col7_Index_Time              = 7; // ����/�����ð�, ���� �ð�, ���� �ð�
  Col7_Index_Button2           = 8; // 2�� ��ư

const  // ����� ��� cell�� index��
//  Col8_Index_State             = 0; //����
//  Col8_Index_PatientName       = 1; //�̸�
//  Col8_Index_Room              = 2; // �����
//  Col8_Index_BirthDayRegNum    = 3; //�������/�ֹι�ȣ
//  Col8_Index_Symptom           = 4; //��������
//  Col8_Index_Time              = 5; // �����û�ð�
//  Col8_Index_Time2             = 6; // ����ð�
//  Col8_Index_Button1           = 7; // 1�� ��ư
//  Col8_Index_Button2           = 8; // 2�� ��ư

  Col8_Index_Button1           = 0; // 1�� ��ư(����)
  Col8_Index_State             = 1; //����(����)
  Col8_Index_isFirst           = 2; // ȯ������
  Col8_Index_PatientName       = 3; //�̸�
  Col8_Index_Room              = 4; //�����
  Col8_Index_BirthDayRegNum    = 5; // �������/�ֹι�ȣ
  Col8_Index_Symptom           = 6;  //��������
  Col8_Index_Time              = 7; // ������û�ð�
  Col8_Index_Button2           = 8; // 2�� ��ư
   //Col8_Index_Time2             = 7; // ����ð�

const  // �޷� ��� cell�� width
  Col_Width_Month_Holiday = 40;
  Col_Index_��            = 0;
  Col_Index_��            = 1;
  Col_Index_ȭ            = 2;
  Col_Index_��            = 3;
  Col_Index_��            = 4;
  Col_Index_��            = 5;
  Col_Index_��            = 6;

const  // �ź�/��� �޽��� grid����
  Col_Width_RadioBox      = 25;
  Col_Index_RadioBox      = 0;
  Col_Index_Message       = 1;

const // ��Ͽ� ����� header��
  Grid_Head_����            = '"����"';
{$ifdef _BirthDayShow_}
  Grid_Head_����_�ֹ�       = '"�������"';
{$else}
  Grid_Head_����_�ֹ�       = '"�ֹι�ȣ"';
{$endif}
  Grid_Head_����            = '"����"';

  Grid_Head_��������        = '"��������"';

  Grid_Head_ȯ������        = '"ȯ������"';


implementation
uses
  System.UITypes,
  dateutils, strutils, UtilsUnit,
  RRConst, gdlog;

var
  GridDataTypeMessage : array [TGridDataType] of string = ('��û�� ȯ�ڰ� �����ϴ�.', '���� Ȯ���� ȯ�ڰ� �����ϴ�.','���� Ȯ���� ȯ�ڰ� �����ϴ�.');

{ TCustomGridListDrawCell }

constructor TCustomGridListDrawCell.Create;
begin
  FSelectColor := clYellow;
  FLineColor := clSilver;
  FGridDataType := gdtRequest;
  FOldDrawCellEvent := nil;
  FListGrid := nil;
end;

destructor TCustomGridListDrawCell.Destroy;
begin
  ListGrid := nil;

  inherited;
end;

procedure TCustomGridListDrawCell.doUserDrawCellEvent(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
  if Assigned(FOldDrawCellEvent) then
  begin
    FOldDrawCellEvent(Sender, ACol, ARow, Rect, State);
  end;
end;

procedure TCustomGridListDrawCell.DrawCenterText(AGrid: TStringGrid;
  ARect: TRect; AText: string);
begin
  AGrid.Canvas.TextRect(ARect, AText, [tfCenter, tfVerticalCenter, tfSingleLine, tfEndEllipsis]);
end;

procedure TCustomGridListDrawCell.DrawTopCenterText(AGrid: TStringGrid;
  ARect: TRect; AText: string);
begin
  AGrid.Canvas.TextRect(ARect, AText, [tfCenter]);
end;

procedure TCustomGridListDrawCell.DrawCenterTextNameStyle(AGrid: TStringGrid;
  ARect: TRect; AText: string);
begin
  AGrid.Canvas.Font.Style := [fsBold, fsUnderline];
  DrawCenterText( AGrid, ARect, AText );
  AGrid.Canvas.Font.Style := [];
end;

procedure TCustomGridListDrawCell.DrawLeftText(AGrid: TStringGrid; ARect: TRect;
  AText: string);
begin
  ARect.Left := ARect.Left + 4;
  AGrid.Canvas.TextRect(ARect, AText, [tfLeft, tfVerticalCenter, tfSingleLine, tfEndEllipsis]);
end;

procedure TCustomGridListDrawCell.DrawRightText(AGrid: TStringGrid;
  ARect: TRect; AText: string);
begin
  ARect.Right := ARect.Right + -2;
  AGrid.Canvas.TextRect(ARect, AText, [tfRight, tfVerticalCenter, tfSingleLine, tfEndEllipsis]);
end;

procedure TCustomGridListDrawCell.FixedCell(AGrid: TStringGrid; ACol,
  ARow: Integer; ARect: TRect);
var
  fs : TFontStyles;
  str : string;
begin
  // ������ ĥ�ϱ�
  AGrid.Canvas.Brush.Color := AGrid.FixedColor;
  AGrid.Canvas.FillRect( ARect );

  // �׵θ� �׸���
  AGrid.Canvas.Rectangle( ARect );

  // text ���
  fs := AGrid.Canvas.Font.Style;
  str := AGrid.Cells[ ACol, ARow ];
  // Include(AGrid.Canvas.Font.Style, fsBold);
  AGrid.Canvas.Font.Style := [ fsBold ];
  DrawCenterText(AGrid, ARect, str);
  AGrid.Canvas.Font.Style := fs;
end;

function TCustomGridListDrawCell.GetState(AData: TRnRData): string;
// data�� ���¿� ���� ���°��� string���� �����.
begin
  Result := TRRDataTypeConvert.RnRDataStatus2DispStr2( AData.DataType, AData.����Ȯ��, AData.Status, AData.Inflow );
end;

function TCustomGridListDrawCell.GetState_DeviceType(AData: TRnRData): string;
begin
  Result := TRRDataTypeConvert.RnRDataStatus2DispStr( AData.DataType, AData.����Ȯ��, AData.Status, AData.Inflow);
end;

function TCustomGridListDrawCell.GetState_FontColor( AData: TRnRData ): TColor; //���� ��Ʈ ��
const
  SC_���� = $FFFFFFF;//$000000FF;
  SC_���� = $FFFFFFF;//$0090CF37;
  SC_���� = $00FF7B00;
  SC_�Ϸ� = $00BB6317;

begin
  Result := clBlack;

  case AData.Status of
    rrs�����û,
    rrs������û : // Status_������û = 'C01';
      begin
        if AData.DataType = rrReception then
        begin
          Result := SC_����;
          if AData.Inflow = rriftablet then
            Result := SC_����;
        end
        else
          Result := SC_����;
      end;
    rrs����Ϸ� :
      begin
        Result := SC_�Ϸ�;
      end;
  end;
end;

procedure TCustomGridListDrawCell.ListDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
//  TStringGrid(Sender).Canvas.Font.Assign( TStringGrid(Sender).Font );
end;

function TCustomGridListDrawCell.makeHint(AData: TRnRData): string;
var
  lHint : string;

  procedure appendhint( AStr : string );
  begin
    if lHint <> '' then
      lHint := lHint + #13#10;
    lHint := lHint + AStr;
  end;

var
  BeforeConfirmation : Boolean;
  canceltitle : string;
begin
  lHint := '';
  try
    if not Assigned( AData ) then
      exit;
    if not (AData is TRnRData) then
      exit; // AData�� TRnRData�� ����ȯ�� �ʵǸ� ó������ �ʴ´�.

    BeforeConfirmation := AData.hsptlreceptndttm <> 0; // ����/���� Ȯ�� �Ͻ�

    with AData do
    begin
      if Canceled  then
      begin  // ��� ����
        case AData.Status of
          rrs������� : canceltitle := '���� ���';
          rrs�������� : canceltitle := '���� ���';
          rrs������� :
            begin
              if BeforeConfirmation then
                canceltitle := '���� ���' // Ȯ�� ��
              else
              begin // Ȯ�� ��
                if AData.DataType = rrReception then
                  canceltitle := '���� ���'
                else
                  canceltitle := '���� �ź�';
              end;
            end;
          rrs������� :
            begin
              if BeforeConfirmation then
                canceltitle := 'ȯ�� öȸ' // Ȯ�� ��
              else
                canceltitle := 'ȯ�� ���'; // Ȯ�� ��
            end;
        else // rrs�ڵ����
          // canceltitle := '�ڵ� ���';
          canceltitle := '����';
        end;

        appendhint( canceltitle );
        appendhint( FormatDateTime('yyyy-mm-dd hh:nn:ss', CancelDT) );
        if AData.CanceledMessage <> '' then
          appendhint( AData.CanceledMessage );

      end
      else
      begin
        if Registration_number <> '' then
          appendhint( Format('�ֹι�ȣ : %s',[ DisplayRegistrationNumber( Registration_number ) ]))
        else
          appendhint( Format('������� : %s',[ DisplayBirthDay( BirthDay ) ]));
        appendhint( Format('�������� : %s',[Symptom]));
      end;
    end;
  finally
    Result := lHint;
  end;
end;

procedure TCustomGridListDrawCell.SetListGrid(const Value: TStringGrid);
begin
  if (not Assigned(Value) ) and Assigned( FListGrid ) then
  begin
    FListGrid.DefaultDrawing := True;
    FListGrid.OnDrawCell := FOldDrawCellEvent;
  end;

  FListGrid := Value;
  if Assigned( FListGrid ) then
  begin
    FOldDrawCellEvent := FListGrid.OnDrawCell;
    FListGrid.DefaultDrawing := False;
    FListGrid.OnDrawCell := ListDrawCell;
  end;
end;


procedure TCustomGridListDrawCell.triangleDraw(AGrid : TStringGrid; ARect: TRect);
var
  c : TColor;
  triangle : array [0..2] of TPoint;
begin
  c := AGrid.Canvas.Brush.Color;
  try
    AGrid.Canvas.Brush.Color := clRed;
    triangle[0].X := ARect.Left;
    triangle[0].y := ARect.Top;

    triangle[1].X := ARect.Left;
    triangle[1].y := ARect.Top + 7;

    triangle[2].X := ARect.Left + 7;
    triangle[2].y := ARect.Top;

    AGrid.Canvas.Polygon( triangle );
  finally
    AGrid.Canvas.Brush.Color := c;
  end;
end;

function TCustomGridListDrawCell.Col_Index_State;
begin
  if GridDataType = gdtRequest then // column count : 8
  begin
    Result := Col8_Index_State;
  end
  else
  begin
    Result := Col7_Index_State;
  end;
end;

function TCustomGridListDrawCell.Col_Index_PatientName;
begin
  if GridDataType = gdtRequest then // column count : 8
  begin
    Result := Col8_Index_PatientName;
  end
  else
  begin
    Result := Col7_Index_PatientName;
  end;
end;

function TCustomGridListDrawCell.Col_Index_Room;
begin
  if GridDataType = gdtRequest then // column count : 8
  begin
    Result := Col8_Index_Room;
  end
  else
  begin
    Result := Col7_Index_Room;
  end;
end;

function TCustomGridListDrawCell.Col_Index_BirthDayRegNum;
begin
  if GridDataType = gdtRequest then // column count : 8
  begin
    Result := Col8_Index_BirthDayRegNum;
  end
  else
  begin
    Result := Col7_Index_BirthDayRegNum;
  end;
end;

function TCustomGridListDrawCell.Col_Index_Time;
begin
  if GridDataType = gdtRequest then // column count : 8
  begin
    Result := Col8_Index_Time;
  end
  else
  begin
    Result := Col7_Index_Time;
  end;
end;

//function TCustomGridListDrawCell.Col_Index_Time2;
//begin
//  if GridDataType = gdtRequest then // column count : 8
//  begin
//    Result := Col8_Index_Time2;
//  end
//  else
//  begin
//    Result := -1;
//  end;
//end;

function TCustomGridListDrawCell.Col_Index_Button1;
begin
  if GridDataType = gdtRequest then // column count : 8
  begin
    Result := Col8_Index_Button1;
  end
  else
  begin
    Result := Col7_Index_Button1;
  end;
end;

function TCustomGridListDrawCell.Col_Index_Button2;
begin
  if GridDataType = gdtRequest then // column count : 8
  begin
    Result := Col8_Index_Button2;
  end
  else
  begin
    Result := Col7_Index_Button2;
  end;
end;

function TCustomGridListDrawCell.Col_Index_Symptom;
begin
  if GridDataType = gdtRequest then // column count : 8
  begin
    Result := Col8_Index_Symptom;
  end
  else
  begin
    Result := Col7_Index_Symptom;
  end;
end;

function TCustomGridListDrawCell.Col_Index_isFirst;
begin
  if GridDataType = gdtRequest then // column count : 8
  begin
    Result := Col8_Index_isFirst;
  end
  else
  begin
    Result := Col7_Index_isFirst;
  end;
end;

{ TGridListDrawCell }

constructor TGridListDrawCell.Create;
begin
  inherited;
end;

destructor TGridListDrawCell.Destroy;
begin

  inherited;
end;

procedure TGridListDrawCell.ListDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  i : integer;
  s : TStringGrid;
  c : Integer;
  backcolor : TColor;
  rowdata : TRnRData;

  workrect, r1 : TRect;
  str : string;

  oldfontcolor : TColor;

begin
  inherited ListDrawCell(Sender, ACol, ARow, Rect, State);

  try
    s := TStringGrid( Sender );
    s.Canvas.Font.Assign( s.Font ); // font
    s.Canvas.Pen.Width := 1;
    s.Canvas.Pen.Color := FLineColor; // line
    c := ACol;
    workrect := Rect;
    backcolor := s.Color;

    if ACol in [Col_Index_Button1] then     //, Col_Index_Button2
    begin
      c := Col_Index_Button1;
      workrect := s.CellRect(Col_Index_Button1, ARow);
    //  r1 := s.CellRect(Col_Index_Button2, ARow);
    // workrect := TRect.Union(workrect, r1);
    // workrect.Right := workrect.Right -1;
      workrect.Left := workrect.Left -1;
    end;

    workrect.Right := workrect.Right +1;
    if s.RowCount <> ARow + 1 then  // ������ row�� data�̴�.
      workrect.Bottom := workrect.Bottom +1;

    if ARow = 0 then
    begin // fixed �����̴�.
      FixedCell( s, c, ARow, workrect );
      exit;
    end;

//    if ACol = 0 then
//    begin // fixed �����̴�.
//      FixedCell( s, c, ARow, workrect );
//      exit;
//    end;

    if gdSelected  in State then
      backcolor := FSelectColor;

    s.Canvas.Brush.Color := backcolor;
   // s.Canvas.FillRect( workrect );
    s.Canvas.Rectangle( workrect );

    rowdata := TRnRData( s.Objects[Col_Index_Data, ARow] );
    if not Assigned( rowdata ) then
    begin  // ��� data�� ����.
      if (s.RowCount = 2) and (ARow = 1) then
      begin
        for i := 0 to s.ColCount -1 do
        begin
          r1 := s.CellRect(i, ARow);
          workrect := TRect.Union(workrect, r1);
        end;
        s.Canvas.Rectangle( workrect );
        str := GridDataTypeMessage[ GridDataType ];
        DrawCenterText(s, workrect, str);
      end;
      exit;
    end;

    oldfontcolor := s.Canvas.Font.Color;
    if rowdata.Canceled then
      s.Canvas.Font.Color := clSilver
    else if rowdata.Status = rrs����Ϸ� then
      s.Canvas.Font.Color := GetState_FontColor( rowdata )
    else
    begin
      if ACol = Col_Index_State then
        s.Canvas.Font.Color := GetState_FontColor( rowdata );
    end;

    if ACol = Col_Index_State then // ����
    begin
      str := GetState( rowdata );
      if rowdata.isFirst then
        str := str;
      DrawCenterText(s, workrect, str);
    end
    else if ACol = Col_Index_PatientName then //�̸�
    begin
      str := rowdata.PatientName;
      case rowdata.Gender of
        rrgtMale    : str := str + '(��)';
        rrgtFemale  : str := str + '(��)';
      end;
      DrawCenterTextNameStyle(s, workrect, str);

      // �޸� ������ �̸� ���ʿ� ������ �ﰢ���� ǥ�� �Ѵ�.
      if rowdata.Memo <> '' then
        triangleDraw( s, Rect );
    end
    else if ACol = Col_Index_Room then // ����� �̸�
    begin
      str := rowdata.RoomInfo.RoomName;
      DrawCenterText(s, workrect, str);
    end
    else if ACol = Col_Index_BirthDayRegNum then //�������
    begin
{$ifdef _BirthDayShow_}
      str := rowdata.DispBirthDay; // yy-mm-dd
{$else}
      str := rowdata.DispRegistration_number; // xxxxxx-xxxxxxx
{$endif}
      DrawCenterText(s, workrect, str);
    end
    else if ACol = Col_Index_Time then  // ����/�����ð�, ���� �ð�, ���� �ð�
    begin
      if GridDataType = gdtRequest then
        str := FormatDateTime('mm/dd hh:nn', rowdata.RegisterDT)
      else
        str := FormatDateTime('mm/dd hh:nn', rowdata.VisitDT);
      DrawCenterText(s, workrect, str);
    end
//    else if ACol = Col_Index_Time2 then // ����ð�
//    begin
//      str := FormatDateTime('mm/dd hh:nn',rowdata.VisitDT);
//      DrawCenterText(s, workrect, str);
//    end
    else if ACol = Col_Index_Symptom then // ��������
    begin
     str := rowdata.Symptom;
     DrawCenterText(s, workrect, str);
    end
     else if ACol = Col_Index_isFirst then // ��������
    begin
       if rowdata.Canceled then
         begin
           str := '���';
         end
       else if rowdata.Status = rrs����Ϸ� then
         begin
           str := '�Ϸ�';
         end
       else if rowdata.isFirst then
         begin
           str := '�ű�';
         end
       else
         str := '����';

      DrawCenterText(s, workrect, str);
    end;

  except
    on e : exception do
    begin
      AddExceptionLog('TGridListDrawCell.ListDrawCell', e);
      raise e;
    end;
  end;

  doUserDrawCellEvent(Sender, ACol, ARow, Rect, State);

  s.Canvas.Font.Color := oldfontcolor;
end;


function TGridListDrawCell.makeHint(AData: TRnRData): string;
begin
  Result := inherited makeHint( AData );
end;

{ TMonthGridDrawCell }

procedure TMonthGridDrawCell.CalcDate2ColRow(ADate: TDate; var ACol,
  ARow: Integer);
var
  y, m, d : Word;

  d1 : TDate;
  d2 : Integer;
begin
  decodedate(ADate, y, m, d);
  d1 := EncodeDate(y, m, 1);
  d2 := DayOfWeek( d1 ) + d;
  ARow := (d2 div 7) + 1;

  ACol := DayOfWeek( ADate ) -1;
  if ACol >= 5 then
    dec( ARow );
end;

function TMonthGridDrawCell.checkToDay(ACol, ARow: Integer): Boolean;
var
  y, m, d2 : Word;
  c, r : Integer;
  d, sd, ed : TDateTime;

  d1 : TDate;
  d3 : Integer;
begin
  Result := False;
  CalcRangeMonth( FDay, sd, ed );  // ������ ���� ����/������ ����
  d := Now;

  if not CheckRangeDateTime(d, sd, ed) then
    exit; // ������ ���Ե��� ���� ���� ��� �ϰ� �ִ�.

(*  c := DayOfWeek( d ) -1;
  decodedate(d, y, m, d2);

  r := ((d2 + (6-c) ) div 7);
  r := r + 1; // ���� title����ϴ� row�� �ڵ����� ���� ���Ѿ� �Ѵ� *)

  decodedate(d, y, m, d2);
  d1 := EncodeDate(y, m, 1);
  d3 := DayOfWeek( d1 ) + d2;
  r := (d3 div 7) + 1;

  c := DayOfWeek( d ) -1;
  if c >= 5 then
    dec( r );

  if (r = ARow) and (c = ACol) then
    Result := True;
end;

constructor TMonthGridDrawCell.Create;
begin
  inherited;
  FDay := today;
end;

destructor TMonthGridDrawCell.Destroy;
begin

  inherited;
end;

procedure TMonthGridDrawCell.ListDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  s : TStringGrid;
  data : TMonthData;
  backcolor, oldfontcolor : TColor;
  fs : TFontStyles;
  workrect, rect1 : TRect;
  str : string;
  isHoliday : Boolean;
begin
  inherited ListDrawCell(Sender, ACol, ARow, Rect, State);

  s := TStringGrid( Sender );
  s.Canvas.Font.Assign( s.Font ); // font
  s.Canvas.Pen.Width := 1;
  s.Canvas.Pen.Color := FLineColor; // line
  workrect := Rect;
  backcolor := s.Color;

  workrect.Right := workrect.Right +1;
  if s.RowCount <> ARow + 1 then  // ������ row�� data�̴�.
    workrect.Bottom := workrect.Bottom +1;

  if ACol = s.ColCount-1 { 6 } then
  begin
    workrect.Right := workrect.Right -1;
  end;

  if ARow = 0 then
  begin // fixed �����̴�.
    FixedCell( s, ACol, ARow, workrect );
    exit;
  end;

  if gdSelected  in State then
    backcolor := FSelectColor;

  s.Canvas.Brush.Color := backcolor;
  if checkToDay(ACol, ARow) then
  begin // ���� ǥ��
    rect1 := workrect;
    s.Canvas.Pen.Width := 3;
    s.Canvas.Pen.Color := clGreen;

    rect1.Left := rect1.Left + 1;
    rect1.Top := rect1.Top + 1;
    rect1.Bottom := rect1.Bottom - s.Canvas.Pen.Width +1;
    rect1.Right := rect1.Right - s.Canvas.Pen.Width +1;

    s.Canvas.Rectangle(rect1);
    s.Canvas.Pen.Width := 1;
  end
  else
    s.Canvas.Rectangle( workrect );

  workrect.Top := workrect.Top + 5;
  data := TMonthData( s.Objects[ACol, ARow] );
  if not Assigned( data ) then
  begin  // data�� ����.
    str := s.Cells[ACol, ARow];
    isHoliday := ACol in [0, 6];

    oldfontcolor := s.Canvas.Font.Color;
    if isHoliday then
    begin
      if ACol = 0 then
        s.Canvas.Font.Color := clRed  // �Ͽ���
      else
        s.Canvas.Font.Color := clBlue; // �����
    end
    else
      s.Canvas.Font.Color := clSilver;

    DrawTopCenterText(s, workrect, str);

    s.Canvas.Font.Color := oldfontcolor;
    exit;
  end;

  isHoliday := data.Holiday;

  oldfontcolor := s.Canvas.Font.Color;
  if isHoliday then
  begin
    if ACol = 0 then
      s.Canvas.Font.Color := clRed  // �Ͽ���
    else
      s.Canvas.Font.Color := clBlue; // �����
  end
  else if (data.CancelFinishCount = 0) and (data.DecideCount = 0) and (data.RequestCount = 0) then
    s.Canvas.Font.Color := clSilver; // data�� ����.

  str := data.Caption;
  rect1 := workrect;
  rect1.Bottom := rect1.Top + 20;
  DrawTopCenterText(s, workrect, str); // ���� ���

  if (data.DecideCount > 0) or (data.RequestCount > 0) then
  begin // ���� data�� �ִ�.
    str := format('%d/%d��',[data.DecideCount, data.RequestCount]);
    rect1 := workrect;
    rect1.Top := rect1.Top + 20;
    fs := s.Canvas.Font.Style;
    try
      s.Canvas.Font.Style := [ fsBold ];
      DrawTopCenterText(s, rect1, str); // ���� data�� count���� ��� �Ѵ�.
    finally
      s.Canvas.Font.Style := fs;
    end;
  end;

  doUserDrawCellEvent(Sender, ACol, ARow, Rect, State);

  s.Canvas.Font.Color := oldfontcolor;
end;

{ TCancelMsgGridDrawCell }

constructor TCancelMsgGridDrawCell.Create;
begin
  inherited;

end;

destructor TCancelMsgGridDrawCell.Destroy;
begin

  inherited;
end;

procedure TCancelMsgGridDrawCell.ListDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  s : TStringGrid;
//  c : Integer;
  backcolor : TColor;
  rowdata : TCancelMsgData;

  workrect : TRect;
  str : string;

  oldfontcolor : TColor;
begin
  inherited ListDrawCell(Sender, ACol, ARow, Rect, State);

  s := TStringGrid( Sender );
  s.Canvas.Font.Assign( s.Font ); // font
  s.Canvas.Pen.Width := 1;
  s.Canvas.Pen.Color := FLineColor; // line
//  c := ACol;
  workrect := Rect;
  backcolor := s.Color;

  if s.ColCount <> ACol + 1 then  // ������ col�� data�̴�.
  workrect.Right := workrect.Right +1;

  if s.RowCount <> ARow + 1 then  // ������ row�� data�̴�.
    workrect.Bottom := workrect.Bottom +1;

(* fixed������ ������
  if ARow = 0 then
  begin // fixed �����̴�.
    FixedCell( s, c, ARow, workrect );
    exit;
  end; *)

  if gdSelected  in State then
    backcolor := FSelectColor;

  s.Canvas.Brush.Color := backcolor;
  //s.Canvas.Rectangle( workrect ); // line����
  s.Canvas.FillRect( workrect );  // line����

  rowdata := TCancelMsgData( s.Objects[Col_Index_Data, ARow] );
  if not Assigned( rowdata ) then
    exit; // ��� data�� ����.

  oldfontcolor := s.Canvas.Font.Color;

  case ACol of
    Col_Index_Message : // �޽��� ���
      begin
        str := rowdata.Caption;
        DrawLeftText(s, workrect, str);
      end;
  end;

  doUserDrawCellEvent(Sender, ACol, ARow, Rect, State);

  s.Canvas.Font.Color := oldfontcolor;
end;


{ TNormalGridListDrawCell }

constructor TNormalGridListDrawCell.Create;
begin
  inherited;

end;

destructor TNormalGridListDrawCell.Destroy;
begin

  inherited;
end;

procedure TNormalGridListDrawCell.ListDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  s : TStringGrid;
  c : Integer;
  backcolor : TColor;

  workrect, r1 : TRect;
  str : string;

  oldfontcolor : TColor;
begin
  inherited ListDrawCell(Sender, ACol, ARow, Rect, State);

  s := TStringGrid( Sender );
  s.Canvas.Font.Assign( s.Font ); // font
  s.Canvas.Pen.Width := 1;
  s.Canvas.Pen.Color := FLineColor; // line
  c := ACol;
  workrect := Rect;
  backcolor := s.Color;

  if ACol in [Col_Index_Button1] then     //Col_Index_Button2
  begin
    c := Col_Index_Button1;
    workrect := s.CellRect(Col_Index_Button1, ARow);
   // r1 := s.CellRect(Col_Index_Button2, ARow);
   // workrect := TRect.Union(workrect, r1);
   // workrect.Right := workrect.Right -1;
    workrect.Left := workrect.Left -1;
  end;

  workrect.Right := workrect.Right +1;
  if s.RowCount <> ARow + 1 then  // ������ row�� data�̴�.
    workrect.Bottom := workrect.Bottom +1;

  if ARow = 0 then
  begin // fixed �����̴�.
    FixedCell( s, c, ARow, workrect );
    exit;
  end;

  if gdSelected  in State then
    backcolor := FSelectColor;

  s.Canvas.Brush.Color := backcolor;
  //s.Canvas.FillRect( workrect );
  s.Canvas.Rectangle( workrect );

  str := trim( s.Cells[ACol, ARow] );
  if str = '' then
    exit;

  oldfontcolor := s.Canvas.Font.Color;
  DrawLeftText(s, workrect, str);

  doUserDrawCellEvent(Sender, ACol, ARow, Rect, State);

  s.Canvas.Font.Color := oldfontcolor;
end;

{ TReservationGridListDrawCell }

constructor TReservationGridListDrawCell.Create;
begin
  inherited;

end;

destructor TReservationGridListDrawCell.Destroy;
begin

  inherited;
end;

procedure TReservationGridListDrawCell.ListDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  i : Integer;
  s : TStringGrid;
  c : Integer;
  backcolor : TColor;
  rowdata : TRnRData;

  workrect, r1 : TRect;
  str : string;

  oldfontcolor : TColor;
begin
  inherited ListDrawCell(Sender, ACol, ARow, Rect, State);

  s := TStringGrid( Sender );
  s.Canvas.Font.Assign( s.Font ); // font
  s.Canvas.Pen.Width := 1;
  s.Canvas.Pen.Color := FLineColor; // line
  c := ACol;
  workrect := Rect;
  backcolor := s.Color;

  if ACol in [Col_Index_Button1, Col_Index_Button2] then
  begin
    c := Col_Index_Button1;
    workrect := s.CellRect(Col_Index_Button1, ARow);
    r1 := s.CellRect(Col_Index_Button2, ARow);
    workrect := TRect.Union(workrect, r1);
    workrect.Right := workrect.Right -1;
  end;

  workrect.Right := workrect.Right +1;
  if s.RowCount <> ARow + 1 then  // ������ row�� data�̴�.
    workrect.Bottom := workrect.Bottom +1;

  if ARow = 0 then
  begin // fixed �����̴�.
    FixedCell( s, c, ARow, workrect );
    exit;
  end;

  if gdSelected  in State then
    backcolor := FSelectColor;

  s.Canvas.Brush.Color := backcolor;
  //s.Canvas.FillRect( workrect );
  s.Canvas.Rectangle( workrect );

  rowdata := TRnRData( s.Objects[Col_Index_Data, ARow] );
  if not Assigned( rowdata ) then
  begin // ��� data�� ����.
    if (s.RowCount = 2) and (ARow = 1) then
    begin
      for i := 0 to s.ColCount -1 do
      begin
        r1 := s.CellRect(i, ARow);
        workrect := TRect.Union(workrect, r1);
      end;
      s.Canvas.Rectangle( workrect );
      str := GridDataTypeMessage[ GridDataType ];
      DrawCenterText(s, workrect, str);
    end;
    exit;
  end;

  oldfontcolor := s.Canvas.Font.Color;
  if rowdata.Canceled then
    s.Canvas.Font.Color := clSilver
  else if rowdata.Status = rrs����Ϸ� then
          s.Canvas.Font.Color := GetState_FontColor( rowdata )
  else
  begin
    if ACol = Col_Index_State then
      s.Canvas.Font.Color := GetState_FontColor( rowdata );
  end;

  if ACol = Col_Index_State then //����
  begin
    str := GetState( rowdata );
    if rowdata.isFirst then
      str := str;
    DrawCenterText(s, workrect, str);
  end
  else if ACol = Col_Index_PatientName then //�̸�
  begin
    str := rowdata.PatientName;
    case rowdata.Gender of
      rrgtMale    : str := str + '(��)';
      rrgtFemale  : str := str + '(��)';
    end;
    DrawCenterTextNameStyle(s, workrect, str);

    // �޸� ������ �̸� ���ʿ� ������ �ﰢ���� ǥ�� �Ѵ�.
    if rowdata.Memo <> '' then
      triangleDraw( s, Rect );
  end
  else if ACol = Col_Index_Room then  // ����� �̸�
  begin
    str := rowdata.RoomInfo.RoomName;
    DrawCenterText(s, workrect, str);
  end
  else if ACol = Col_Index_BirthDayRegNum then //�������
  begin
{$ifdef _BirthDayShow_}
    str := rowdata.DispBirthDay; // yy-mm-dd
{$else}
    str := rowdata.DispRegistration_number; // xxxxxx-xxxxxxx
{$endif}
    DrawCenterText(s, workrect, str);
  end
  else if ACol = Col_Index_Time then  // ����/�����ð�, ���� �ð�, ���� �ð�
  begin
    if GridDataType = gdtRequest then
      str := FormatDateTime('mm/dd hh:nn', rowdata.RegisterDT)
    else
      str := FormatDateTime('mm/dd hh:nn', rowdata.VisitDT);
    DrawCenterText(s, workrect, str);
  end;
//  else if ACol = Col_Index_Time2 then // ����ð�
//  begin
//    str := FormatDateTime('mm/dd hh:nn', rowdata.VisitDT);
//    DrawCenterText(s, workrect, str);
//  end;                                ����ð� ����

  doUserDrawCellEvent(Sender, ACol, ARow, Rect, State);

  s.Canvas.Font.Color := oldfontcolor;
end;

function TReservationGridListDrawCell.makeHint(AData: TRnRData): string;
begin
  Result := inherited makeHint( AData );
end;

{ TRRGridListDrawCell }

constructor TRRGridListDrawCell.Create;
begin
  inherited;

end;

destructor TRRGridListDrawCell.Destroy;
begin

  inherited;
end;

procedure TRRGridListDrawCell.ListDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  i : integer;
  s : TStringGrid;
  c : Integer;
  backcolor : TColor;
  rowdata : TRnRData;

  workrect, r1 : TRect;
  str : string;

  oldfontcolor : TColor;
begin
  inherited ListDrawCell(Sender, ACol, ARow, Rect, State);

  s := TStringGrid( Sender );
  s.Canvas.Font.Assign( s.Font ); // font
  s.Canvas.Pen.Width := 1;
  s.Canvas.Pen.Color := FLineColor; // line
  c := ACol;
  workrect := Rect;
  backcolor := s.Color;

  if ACol in [Col_Index_Button1, Col_Index_Button2] then
  begin
    c := Col_Index_Button1;
    workrect := s.CellRect(Col_Index_Button1, ARow);
   // r1 := s.CellRect(Col_Index_Button2, ARow);
   // workrect := TRect.Union(workrect, r1);
    workrect.Left := workrect.Left -1;
  end;

  workrect.Right := workrect.Right +1;
  if s.RowCount <> ARow + 1 then  // ������ row�� data�̴�.
    workrect.Bottom := workrect.Bottom +1;

  if ARow = 0 then
  begin // fixed �����̴�.
    FixedCell( s, c, ARow, workrect );
    exit;
  end;

  if gdSelected  in State then
    backcolor := FSelectColor;

  s.Canvas.Brush.Color := backcolor;
  //s.Canvas.FillRect( workrect );
  s.Canvas.Rectangle( workrect );

  rowdata := TRnRData( s.Objects[Col_Index_Data, ARow] );
  if not Assigned( rowdata ) then
  begin  // ��� data�� ����.
    if (s.RowCount = 2) and (ARow = 1) then
    begin
      for i := 0 to s.ColCount -1 do
      begin
        r1 := s.CellRect(i, ARow);
        workrect := TRect.Union(workrect, r1);
      end;
      s.Canvas.Rectangle( workrect );
      str := GridDataTypeMessage[ GridDataType ];
      DrawCenterText(s, workrect, str);
    end;
    exit;
  end;

  oldfontcolor := s.Canvas.Font.Color;
  if rowdata.Canceled then
    s.Canvas.Font.Color := clSilver
  else if rowdata.Status = rrs����Ϸ� then
          s.Canvas.Font.Color := GetState_FontColor( rowdata )
  else
  begin
    if ACol = Col_Index_State then
      s.Canvas.Font.Color := GetState_FontColor( rowdata );
  end;

  if ACol = Col_Index_State then //����
  begin
    //str := GetState( rowdata );
    str := GetState_DeviceType( rowdata ); // device type���� ���� �ϰ� �Ѵ�.
    if rowdata.isFirst then
     str := str;
    DrawCenterText(s, workrect, str);
  end
  else if ACol = Col_Index_PatientName then //�̸�
  begin
    str := rowdata.PatientName;
    case rowdata.Gender of
      rrgtMale    : str := str + '(��)';
      rrgtFemale  : str := str + '(��)';
    end;
    DrawCenterTextNameStyle(s, workrect, str);

    // �޸� ������ �̸� ���ʿ� ������ �ﰢ���� ǥ�� �Ѵ�.
    if rowdata.Memo <> '' then
      triangleDraw( s, Rect );
  end
  else if ACol = Col_Index_Room then  // ����� �̸�
  begin
    str := rowdata.RoomInfo.RoomName;
    DrawCenterText(s, workrect, str);
  end
  else if ACol = Col_Index_BirthDayRegNum then // ����/�ֹι�ȣ
  begin
{$ifdef _BirthDayShow_}
    str := rowdata.DispBirthDay; // yy-mm-dd
{$else}
    str := rowdata.DispRegistration_number; // xxxxxx-xxxxxxx
{$endif}
    DrawCenterText(s, workrect, str);
  end
  else if ACol = Col_Index_Time then  // ����/�����ð�, ���� �ð�, ���� �ð�
  begin
    if rowdata.DataType = rrReception then
      str := FormatDateTime('mm/dd hh:nn', rowdata.VisitDT) // ����
    else
      str := FormatDateTime('mm/dd hh:nn', rowdata.RegisterDT); // ����

    DrawCenterText(s, workrect, str);
  end
//  else if ACol = Col_Index_Time2 then // ����ð�
//  begin
//    if rowdata.DataType = rrReception then
//      str := '-' //FormatDateTime('mm/dd hh:nn', rowdata.VisitDT) // ����
//    else
//      str := FormatDateTime('mm/dd hh:nn', rowdata.VisitDT); // ����
//      DrawCenterText(s, workrect, str);
//    end
  else if ACol = Col_Index_Symptom then // ��������
    begin
     str := rowdata.Symptom;
     DrawCenterText(s, workrect, str);
  end
  else if ACol = Col_Index_isFirst then // ��������
    begin
      if rowdata.Canceled then
         begin
           str := '���';
         end
       else if rowdata.Status = rrs����Ϸ� then
         begin
           str := '�Ϸ�';
         end
       else if rowdata.isFirst then
         begin
           str := '�ű�';
         end
       else
         str := '����';

      DrawCenterText(s, workrect, str);
    end;

  doUserDrawCellEvent(Sender, ACol, ARow, Rect, State);

  s.Canvas.Font.Color := oldfontcolor;
end;


end.