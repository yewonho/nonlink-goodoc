unit SelectCancelMSG;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  SakpungImageButton, Vcl.Grids, SakpungStyleButton, SakpungEdit, RnRData, {GDGrid,} RRGridDrawUnit,
  ImageResourceDMUnit;

type
  TRadioButton = class( Vcl.StdCtrls.TRadioButton )
  public
  published
    { published declarations }
    property ClicksDisabled;
  end;

  TDispData = class( TCancelMsgData )
  private
    { Private declarations }
  public
    { Public declarations }
    RadioButton : TRadioButton;
    EditBox : TSakpungEdit;
  public
    { Public declarations }
    constructor Create; override;
    destructor Destroy; override;
  end;


  TSelectCancelMSGForm = class(TForm)
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
    SakpungImageButton1: TSakpungImageButton;
    procedure Panel3Resize(Sender: TObject);
    procedure listgridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure listgridTopLeftChanged(Sender: TObject);
    procedure close_btnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure listgridSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure SakpungImageButton1Click(Sender: TObject);
  private
    { Private declarations }
    FCancelMsgGridDrawCell : TCancelMsgGridDrawCell;

    procedure SetGridUI;  // grid�� �ʱ� UI�� ���� �Ѵ�.
    procedure ClearGrid;

    procedure RadioButtonClickEvent( ASender : TObject );
    procedure initButton; // window button�� image�� �ʱ�ȭ �Ѵ�.
    // ���õ� ��� data�� ��ȯ �Ѵ�.
    function GetSelectData : TDispData;
  protected
    { protected declarations }
    procedure CreateParams(var Params: TCreateParams); override;
    procedure DoShow; override;
  public
    { Public declarations }
    constructor Create( AOwner : TComponent ); override;
    destructor Destroy; override;

    function ShowModal: Integer; override;
    function GetSelectMsg : string;
  end;

var
  SelectCancelMSGForm: TSelectCancelMSGForm;

implementation
uses
  UtilsUnit, TranslucentFormUnit, RRConst, RnRDMUnit, gd.GDMsgDlg_none;

{$R *.dfm}

{ TSelectCancelMSGForm }

procedure TSelectCancelMSGForm.ClearGrid;
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

procedure TSelectCancelMSGForm.close_btnClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

constructor TSelectCancelMSGForm.Create(AOwner: TComponent);
begin
  inherited;
  FCancelMsgGridDrawCell := TCancelMsgGridDrawCell.Create;
  FCancelMsgGridDrawCell.ListGrid := listgrid;
end;

procedure TSelectCancelMSGForm.CreateParams(var Params: TCreateParams);
begin
  inherited;
  // borderstyle := bsNone; ���� ���� �� ����ؾ� �Ѵ�.

  //Params.Style := Params.Style or WS_THICKFRAME;   // captiond����, resize �ǰ�
  Params.Style := Params.Style or WS_BORDER; // caption����, border �ְ�, resize�ʵǰ�
  // Params.Style := Params.Style or WS_BORDER or WS_DLGFRAME; // caption�ְ�, system button����, resize �ʵǰ� , WS_CAPTION��� �ѰͰ� ����
  //Params.Style := Params.Style or WS_BORDER or WS_THICKFRAME; // captiond����, resize �ǰ�
end;

destructor TSelectCancelMSGForm.Destroy;
begin
  ClearGrid;  // grid�� ��ϵǾ� �ִ� object ����

  FreeAndNil( FCancelMsgGridDrawCell );

  inherited;
end;

procedure TSelectCancelMSGForm.DoShow;
begin
  inherited;

  SetGridUI;
end;


procedure TSelectCancelMSGForm.FormShow(Sender: TObject);
begin
  initButton;

  FormStyle := Application.MainForm.FormStyle;
end;

function TSelectCancelMSGForm.GetSelectData: TDispData;
var
  i : Integer;
  dd : TDispData;
begin
  Result := nil;
  // grid���� ��µǾ� �ִ� control���� �Ⱥ��̰� ó�� �Ѵ�.
  for i := 0 to listgrid.RowCount -1 do
  begin
    dd := TDispData( listgrid.Objects[Col_Index_Data, i] );
    if Assigned( dd ) then
    begin
      if dd.RadioButton.Checked then
      begin
        Result := dd;
        exit;
      end;
    end;
  end;
end;

function TSelectCancelMSGForm.GetSelectMsg: string;
var
  i : Integer;
  dd : TDispData;
begin
  // grid���� ��µǾ� �ִ� control���� �Ⱥ��̰� ó�� �Ѵ�.
  for i := 0 to listgrid.RowCount -1 do
  begin
    dd := TDispData( listgrid.Objects[Col_Index_Data, i] );
    if Assigned( dd ) then
    begin
      if dd.RadioButton.Checked then
      begin
        if dd.Caption = '' then
          Result := dd.EditBox.Text
        else
          Result := dd.Caption;
      end;
    end;
  end;
end;

procedure TSelectCancelMSGForm.initButton;
begin
  close_btn.PngImageList := ImageResourceDM.WindowButtonImageList;
  ImageResourceDM.SetButtonImage(close_btn, aibtButton1, BTN_Img_Win_Close);
end;

procedure TSelectCancelMSGForm.listgridDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  s : TStringGrid;
  rowdata : TDispData;
  workrect : TRect;
begin
  s := TStringGrid( Sender );
  workrect := Rect;

  rowdata := TDispData( s.Objects[Col_Index_Data, ARow] );
  if not Assigned( rowdata ) then
    exit; // ��� data�� ����.

  case ACol of
    Col_Index_RadioBox  : // radio button ���
      begin
        if Assigned( rowdata.RadioButton ) then
        begin
          workrect.Left := workrect.Left + 4;
          rowdata.RadioButton.BoundsRect := workrect;
          rowdata.RadioButton.Visible := True;
        end;
      end;
    Col_Index_Message   :
      begin
        if Assigned( rowdata.EditBox ) then
        begin
          workrect.Inflate(-4, -1);
          rowdata.EditBox.Visible := True;
          rowdata.EditBox.BoundsRect := workrect;
        end;
      end;
  end;
end;

procedure TSelectCancelMSGForm.listgridSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
var
  dd : TDispData;
begin
  dd := TDispData( listgrid.Objects[Col_Index_Data, ARow] );
  dd.RadioButton.Checked := True;
end;

procedure TSelectCancelMSGForm.listgridTopLeftChanged(Sender: TObject);
var
  i : Integer;
  dd : TDispData;
begin
  // grid���� ��µǾ� �ִ� control���� �Ⱥ��̰� ó�� �Ѵ�.
  for i := 0 to listgrid.RowCount -1 do
  begin
    dd := TDispData( listgrid.Objects[Col_Index_Data, i] );
    if Assigned( dd ) then
    begin
      if Assigned( dd.RadioButton ) then
        dd.RadioButton.Visible := False;

      if Assigned( dd.EditBox ) then
        dd.EditBox.Visible := False;
    end;
  end;
end;

procedure TSelectCancelMSGForm.Panel3Resize(Sender: TObject);
begin
  SakpungImageButton1.Left := (Panel3.Width - SakpungImageButton1.Width) div 2;
end;

procedure TSelectCancelMSGForm.RadioButtonClickEvent(ASender: TObject);
begin
  TRadioButton( ASender ).ClicksDisabled := true;
  try
    TRadioButton( ASender ).Checked := not TRadioButton( ASender ).Checked;
    listgrid.Row := TRadioButton( ASender ).Tag;
  finally
    TRadioButton( ASender ).ClicksDisabled := False;
  end;
end;

procedure TSelectCancelMSGForm.SakpungImageButton1Click(Sender: TObject);
var
  ret : Integer;
  m, msg : string;
  data : TDispData;
begin
  data := GetSelectData;
  if not Assigned(data) then
  begin
    msg := '��� ������ �Է��ϼ���!';
    ShowGDMsgDlg( msg, GetTransFormHandle, mtWarning, [mbOK] );
    exit;
  end;
  if data.RadioButton.Tag = 0 then
  begin // ���� �Է��̴�.
    if Trim( data.EditBox.Text ) = '' then
    begin
      msg := '��� ������ �Է��� �ּ���!';
      ShowGDMsgDlg( msg, GetTransFormHandle, mtWarning, [mbOK] );
      data.EditBox.SetFocus;
      exit;
    end;
  end;

  msg := '�ش� ȯ���� ����/������ ����Ͻðڽ��ϱ�?';
  m := GetSelectMsg;
  if m <> '' then
  begin
    m := SliceString(m, 30);
    msg := msg + #13#10 + format('(%s)',[m]); // ���
  end;

  ret := ShowGDMsgDlg( msg, GetTransFormHandle, mtConfirmation, [mbYes, mbNo] );
  if ret = mrYes then
    ModalResult := mrYes;
end;

procedure TSelectCancelMSGForm.SetGridUI;
var
  i, rowcnt : Integer;
  str : string;
  rowdata : TDispData;
begin
  listgrid.Perform(WM_SETREDRAW, 0, 0);   // begineupdate
  try
    ClearGrid;
    with listgrid do
    begin
      RowCount := 1;

      str := '';
      for i := 0 to ColCount do
      begin
        if str <> '' then
          str := str + ',';
        str := str + '""';
      end;
      Rows[ 0 ].CommaText := str;

      ColWidths[Col_Index_RadioBox] := Col_Width_RadioBox; // radio box
      ColWidths[Col_Index_Message]  := Width - Col_Width_RadioBox - 25; // �޽���

      // ���� �Է�
      rowcnt := 0;
      rowdata := TDispData.Create;
      rowdata.RadioButton := TRadioButton.Create(listgrid);
      rowdata.RadioButton.ClicksDisabled := False;
      rowdata.RadioButton.Visible := False;
      rowdata.RadioButton.Parent := listgrid;
      rowdata.RadioButton.Tag := rowcnt;
      rowdata.RadioButton.Checked := False;
      rowdata.RadioButton.ControlStyle := [csClickEvents];  // click event�� �߻� ��Ų��.
      rowdata.RadioButton.OnClick := RadioButtonClickEvent;
      rowdata.RadioButton.ClicksDisabled := True;

      rowdata.EditBox := TSakpungEdit.Create(listgrid);
      rowdata.EditBox.Visible := False;
      rowdata.EditBox.Parent := listgrid;
      rowdata.EditBox.MaxLength := 255;
      rowdata.EditBox.Tag := rowcnt;
      rowdata.EditBox.OnClick := RadioButtonClickEvent;
      rowdata.EditBox.Text := '';
      rowdata.EditBox.TextHint := '�����Է�';

      listgrid.Objects[Col_Index_Data, rowcnt] := rowdata;

      with RnRDM do
      begin
        CancelMsg_DB.First;
        while not CancelMsg_DB.Eof do
        begin
          Inc( rowcnt );

          rowdata := TDispData.Create;
          rowdata.Caption := CancelMsg_DB.FieldByName('cancelmsg').AsString;
          rowdata.RadioButton := TRadioButton.Create(listgrid);
          rowdata.RadioButton.ClicksDisabled := False;
          rowdata.RadioButton.Visible := False;
          rowdata.RadioButton.Parent := listgrid;
          rowdata.RadioButton.Tag := rowcnt;
          rowdata.RadioButton.Checked := rowcnt = 2;
          rowdata.RadioButton.OnClick := RadioButtonClickEvent;
          rowdata.RadioButton.ControlStyle := [csClickEvents];  // click event�� �߻� ��Ų��.
          rowdata.RadioButton.ClicksDisabled := True;
          rowdata.EditBox := nil;
          RowCount := rowcnt + 1;
          Objects[Col_Index_Data, rowcnt] := rowdata;

          CancelMsg_DB.Next;
        end;
      end;
    end;

  finally
    listgrid.Perform(WM_SETREDRAW, 1, 0);   // endupdate
    listgrid.Invalidate;
  end;
end;

function TSelectCancelMSGForm.ShowModal: Integer;
begin
  SetWindowLong(Handle, GWL_HWNDPARENT, Application.ActiveFormHandle );
  Result := inherited ShowModal;
end;

{ TDispData }

constructor TDispData.Create;
begin
  inherited;
  RadioButton := nil;
  EditBox := nil;
end;

destructor TDispData.Destroy;
begin
  if Assigned(RadioButton) then
  begin
    RadioButton.Parent := nil;
    FreeAndNil( RadioButton );
  end;

  if Assigned(EditBox) then
  begin
    EditBox.Parent := nil;
    FreeAndNil( EditBox );
  end;

  inherited;
end;

end.
