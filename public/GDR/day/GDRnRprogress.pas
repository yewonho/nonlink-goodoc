unit GDRnRprogress;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ComCtrls;

type
  TRnRDMUnitProgress = class(TForm)
    ProgressBar1: TProgressBar;
    Label1: TLabel;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    FThread: TThread;
  public
    { Public declarations }
  end;

var
  RnRDMUnitProgress: TRnRDMUnitProgress;

implementation

{$R *.dfm}

procedure TRnRDMUnitProgress.FormCreate(Sender: TObject);
var
  MainFormCenterX, MainFormCenterY: Integer;
  ModalFormLeft, ModalFormTop: Integer;
  rect: TRect;
begin
  GetWindowRect(Application.MainFormHandle, rect);

  MainFormCenterX := (rect.Left + rect.Right) div 2;
  MainFormCenterY := (rect.Top + rect.Bottom) div 2;

  ModalFormLeft := MainFormCenterX - Width div 2;
  ModalFormTop := MainFormCenterY - Height div 2;

  Left := ModalFormLeft;
  Top := ModalFormTop;

  Timer1.Enabled := True;
end;

procedure TRnRDMUnitProgress.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False; // 타이머 중복 실행 방지

  FThread := TThread.CreateAnonymousThread(
    procedure
    var
      iRow: Integer;
    begin
      ProgressBar1.Position := 0;
      ProgressBar1.Max := 2;

      for iRow := 0 to 2 do
      begin
        ProgressBar1.Position := ProgressBar1.Position + 1;
        Sleep(500);
      end;

      TThread.Queue(nil,
        procedure
        begin
          Timer1.Enabled := False;
          Close;
        end
      );
    end
  );
  FThread.Start;
end;

end.

