unit ReservationScheduleSendUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.WinXCalendars,
  Vcl.WinXPickers, Vcl.ExtCtrls, Data.DB, MemDS, DBAccess, LiteAccess, DBDMUnit, BridgeCommUnit, GlobalUnit,
  Vcl.Grids;

type
  TReservationScheduleSendForm = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ListBox1: TListBox;
    ListBox2: TListBox;
    Button1: TButton;
    LiteQuery1: TLiteQuery;
    StringGrid1: TStringGrid;
    Button2: TButton;
    Button3: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);

  private
    { Private declarations }

  public
    { Public declarations }
    procedure ChangeUI( AParentCtrl : TWinControl );
    procedure Refresh;

    procedure Send;
  end;

var
  ReservationScheduleSendForm: TReservationScheduleSendForm;


implementation
uses
  System.UITypes, math, strutils,
  GDLog, GDBridge, dateutils,
  RoomListDialogUnit, ChartEmul_v4Unit,
  PatientMngUnit, ElectronicPrescriptionsDefaultUnit, ReservationMngUnit, RoomMngUnit,
  AccountDMUnit, AccountRequestUnit, ReceptionIDChangeUnit, ReceptionMngUnit;

{$R *.dfm}

procedure TReservationScheduleSendForm.Button1Click(Sender: TObject);
  function InspectInputValue() : boolean;
  var
    i : integer;
    rowData : TStrings;
    datetime : TDateTime;
    fs : TFormatSettings;
    fixRow : integer;
    fixCol : integer;

  begin
    Result := true;

    fs := TFormatSettings.Create;
    fs.DateSeparator := '-';
    fs.TimeSeparator := ':';
    fs.LongDateFormat := 'yyyy-mm-dd';
    fs.ShortDateFormat := 'yyyy-mm-dd';
    fs.LongTimeFormat := 'hh:nn';
    fs.ShortTimeFormat := 'hh:nn';

    // skip a header cell
    for i := 1 to StringGrid1.RowCount-1 do
    begin
      rowData := StringGrid1.Rows[i];
      if rowData[0] = string.Empty then
      begin
        Application.MessageBox('�������� ���� �Է����ּ���.', '�˸�', MB_OK);
        Result := false;
        fixRow := i;
        fixCol := 0;
        break;
      end
      else if rowData[1] = string.Empty then
      begin
        Application.MessageBox('������������ ���� �Է����ּ���.', '�˸�', MB_OK);
        Result := false;
        fixRow := i;
        fixCol := 1;
        break;
      end;

      // ��¥/�ð� üũ
      try
        datetime := StrToDateTime(rowData[0], fs);
        //Application.MessageBox(PWideChar(DateTimeToStr(datetime)), '�˸�', MB_OK);
        StringGrid1.Cells[0, i] := FormatDateTime('yyyy-mm-dd hh:nn', datetime);

        if datetime <= Now then
        begin
          Application.MessageBox('�������ڴ� ���ݺ��� �����̾�� �մϴ�.', '�˸�', MB_OK);
          Result := false;
          fixRow := i;
          fixCol := 0;
          break;
        end;
      except on e: Exception do
        begin
          Application.MessageBox('����ð� �Է� ������ �����ּ���', '�˸�', MB_OK);
          Result := false;
          fixRow := i;
          fixCol := 0;
          break;
        end;
      end;

      // ������������ üũ
      if not string.Equals(rowData[1], '0') and not string.Equals(rowData[1], '1') then
      begin
        Application.MessageBox('������������ �Է� ������ �����ּ���', '�˸�', MB_OK);
        Result := false;
        fixRow := i;
        fixCol := 1;
        break;
      end;

    end;

    if not Result then
    begin
      StringGrid1.Row := fixRow;
      StringGrid1.Col := fixCol;
      StringGrid1.Selection := TGridRect(Rect(fixCol, fixRow, fixCol, fixRow));
      StringGrid1.SetFocus;
    end;

  end;


begin
  if ListBox1.ItemIndex = -1 then
  begin
    Application.MessageBox('������� �ڵ带 �������ּ���.', '�˸�', MB_OK);
    exit;
  end;

  if ListBox2.ItemIndex = -1 then
  begin
    Application.MessageBox('����� �ڵ带 �������ּ���.', '�˸�', MB_OK);
    exit;
  end;
  {
  if CalendarPicker1.Date < Today then
  begin
    Application.MessageBox('�������ڴ� ���ݺ��� �����̾�� �մϴ�.', '�˸�', MB_OK);
    exit;
  end
  else if IsToday(CalendarPicker1.Date) and (TimePicker1.Time <= TimeOf(Now)) then
  begin
    Application.MessageBox('����ð��� ���ݺ��� �����̾�� �մϴ�.', '�˸�', MB_OK);
    exit;
  end;
  }
  if not InspectInputValue then
    exit;

  // ����
  Send;
end;

procedure TReservationScheduleSendForm.Button2Click(Sender: TObject);
begin
  StringGrid1.RowCount := StringGrid1.RowCount + 1;

  StringGrid1.Cells[0, StringGrid1.RowCount-1] := FormatDateTime('yyyy-mm-dd hh:nn', Now);
  StringGrid1.Cells[1, StringGrid1.RowCount-1] := '0';
end;

procedure TReservationScheduleSendForm.Button3Click(Sender: TObject);
begin
  if StringGrid1.RowCount <= 2 then
    exit;

  StringGrid1.RowCount := StringGrid1.RowCount - 1;
end;

procedure TReservationScheduleSendForm.ChangeUI(AParentCtrl : TWinControl);
begin
  if Assigned( AParentCtrl ) then
  begin
    Panel1.Parent := AParentCtrl;
    Panel1.Align := alClient;
  end
  else
    Panel1.Parent := Self;
end;

procedure TReservationScheduleSendForm.Refresh;
  procedure PrintDepartmentList();
  begin
    ListBox1.Items.Clear;

    LiteQuery1.Active := false;
    with LiteQuery1 do
    begin
      SQL.Clear;
      SQL.Add( 'select * from room ' );
      Active := True;
      First;
      while not eof do
      begin
        ListBox1.Items.Add(FieldByName( 'roomname' ).AsString + ':' + FieldByName( 'roomcode' ).AsString);
        Next;
      end;

    end;

  end;

  procedure PrintRoomList();
  begin
    ListBox2.Items.Clear;

    LiteQuery1.Active := false;
    with LiteQuery1 do
    begin
      SQL.Clear;
      SQL.Add( 'select * from room ' );
      Active := True;
      First;
      while not eof do
      begin
        ListBox2.Items.Add(FieldByName( 'deptname' ).AsString + ':' + FieldByName( 'deptcode' ).AsString);
        Next;
      end;
    end;
  end;

  procedure ResetScheduleSheet();
  var
    i : integer;
  begin
    StringGrid1.Cells[0, 0] := '����ð�(yyyy-MM-dd hh:mm)';
    StringGrid1.Cells[1, 0] := '������������(0: ����, 1: ����)';

    for i := 1 to StringGrid1.RowCount - 1 do
    begin
      if StringGrid1.Cells[0, i] = string.Empty then
        StringGrid1.Cells[0, i] := FormatDateTime('yyyy-mm-dd hh:nn', Now);
      if StringGrid1.Cells[1, i] = string.Empty then
        StringGrid1.Cells[1, i] := '0';
    end;

  end;

begin
  // ������� �ڵ��� ���
  PrintDepartmentList;

  // ����� �ڵ��� ���
  PrintRoomList;

  // �ʱ�ȭ
  ResetScheduleSheet;

end;


procedure TReservationScheduleSendForm.Send;
  function ParseRoomCode() : string;
  var
    str : string;
    delimArray : array[0..0] of char;
    strArray : TArray<string>;
  begin
    str := ListBox1.Items[ListBox1.ItemIndex];
    delimArray := ':';
    strArray := str.Split(delimArray);


    Result := strArray[Length(strArray)-1];
  end;

  function ParseDeptCode() : string;
  var
    str : string;
    delimArray : array[0..0] of char;
    strArray : TArray<string>;
  begin
    str := ListBox2.Items[ListBox2.ItemIndex];
    delimArray := ':';
    strArray := str.Split(delimArray);

    Result := strArray[Length(strArray)-1];
  end;

  function ParseDateTime(ACol, ARow : integer) : string;
  var
    date : string;
    time : string;
  begin
    //date := FormatDateTime('yyyy-mm-dd', CalendarPicker1.Date);
    //time := FormatDateTime('hh:nn', TimePicker1.Time);
    //date := '2021-06-09';
    //time := '00:00';
    Result := StringGrid1.Cells[ACol, ARow];
  end;

  function IsCheckReserved(ACol, ARow : integer) : boolean;
  begin
    //Result := CheckBox1.Checked;
    Result := (StringGrid1.Cells[ACol, ARow] = '1');
  end;

var
  str : string;
  event_2006 : TBridgeRequest_2006;
  responsebase : TBridgeResponse;
  i : integer;
begin
  event_2006 := TBridgeRequest_2006( GBridgeFactory.MakeRequestObj( EventID_���ེ���������û ) );
  try
    event_2006.RoomCode := ParseRoomCode;
    event_2006.DeptCode := ParseDeptCode;

    for i := 1 to StringGrid1.RowCount - 1 do
    begin
      event_2006.AddItem(ParseDateTime(0, i), IsCheckReserved(1, i));
    end;

    //Application.MessageBox(PWideChar(event_2006.ToJsonString), '�˸�', MB_OK);

    addlog( doRunLog, '���� : ' + event_2006.ToJsonString);
    ChartEmulV4Form.AddMemo( event_2006.EventID, event_2006.JobID);

    str := GetBridge.RequestResponse( event_2006.ToJsonString );
    addlog( doRunLog, '��� : ' + str);
    responsebase := GBridgeFactory.MakeResponseObj( str );
    try
      ChartEmulV4Form.AddMemo( responsebase.EventID, responsebase.JobID, responsebase.Code, responsebase.MessageStr, 0 );
      if event_2006.JobID <> responsebase.JobID then
      begin
        ChartEmulV4Form.AddMemo( format('EventID:%d�� ���� JobID���� ���ų� Ʋ����.(JobID=%s)', [responsebase.EventID, responsebase.JobID]) );
        AddLog(doWarningLog, format('EventID:%d�� ���� JobID���� ���ų� Ʋ����.(JobID=%s)', [responsebase.EventID, responsebase.JobID]) );
      end;
    finally
      freeandnil( responsebase );
    end;

  finally
    freeandnil( event_2006 );
  end;
end;


end.
