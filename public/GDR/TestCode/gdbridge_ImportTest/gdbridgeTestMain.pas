unit gdbridgeTestMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TgdbridgeTestMainForm = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Button2: TButton;
    Button3: TButton;
    Edit2: TEdit;
    Button4: TButton;
    Edit3: TEdit;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Memo1: TMemo;
    Edit4: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
  private
    { Private declarations }
    procedure DllLoadState;
    procedure AddLog( ALog : string );
  public
    { Public declarations }
    constructor Create( AOwner : TComponent ); override;
    destructor Destroy; override;
  end;

var
  gdbridgeTestMainForm: TgdbridgeTestMainForm;

implementation
uses
  strutils,
  BridgeDLL;

{$R *.dfm}

{ TgdbridgeTestMainForm }

procedure TgdbridgeTestMainForm.AddLog(ALog: string);
begin
  Memo1.Lines.Add( ALog );
end;

procedure TgdbridgeTestMainForm.Button1Click(Sender: TObject);
begin
  GBridgeDLL.Load;
  DllLoadState;
end;

procedure TgdbridgeTestMainForm.Button2Click(Sender: TObject);
begin
  GBridgeDLL.Unload;
  DllLoadState;
end;

procedure TgdbridgeTestMainForm.Button3Click(Sender: TObject);
begin
  Edit2.Text := GBridgeDLL.GetJobID;
end;

procedure TgdbridgeTestMainForm.Button4Click(Sender: TObject);
begin
  Edit3.Text := GBridgeDLL.GetErrorString( 3 );
end;

procedure TgdbridgeTestMainForm.Button5Click(Sender: TObject);
begin
  Edit2.Text := GBridgeDLL.GetJobIDW;
end;

procedure TgdbridgeTestMainForm.Button6Click(Sender: TObject);
begin
  Edit3.Text := GBridgeDLL.GetErrorStringW( 3 );
end;

procedure TgdbridgeTestMainForm.Button7Click(Sender: TObject);
var
  ret : Integer;
begin
  //ret := GBridgeDLL.init(1020, '100000000006', _Bridge_InitType_Polling, nil);
  ret := GBridgeDLL.init(1020, Edit4.Text, _Bridge_InitType_Polling, nil);
  AddLog( Format('init : Result=%d',[ret]) );
end;

procedure TgdbridgeTestMainForm.Button8Click(Sender: TObject);
begin
  GBridgeDLL.Deinit;
  AddLog( 'Deinit : ' );
end;

constructor TgdbridgeTestMainForm.Create(AOwner: TComponent);
begin
  inherited;
  GBridgeDLL := T__BridgeDLL.Create( _Bridge_DLL_FileName );
end;

destructor TgdbridgeTestMainForm.Destroy;
begin
  FreeAndNil( GBridgeDLL );
  inherited;
end;

procedure TgdbridgeTestMainForm.DllLoadState;
begin

  Edit1.Text := ifthen(GBridgeDLL.DLLLoaded,'Load','Unload')
end;

end.
