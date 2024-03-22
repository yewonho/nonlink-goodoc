unit SplashUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Imaging.pngimage;

type
  TSplashForm = class(TForm)
    Edit1: TEdit;
    CloseTimer: TTimer;
    Image1: TImage;
    procedure FormShow(Sender: TObject);
    procedure CloseTimerTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure dispDesc( ADesc : string ); // 화면에 출력할 내용
    procedure CloseSplash;
  end;

var
  SplashForm: TSplashForm;

implementation

{$R *.dfm}

{ TSplashForm }

procedure TSplashForm.CloseSplash;
begin
  CloseTimer.Enabled := True;
end;

procedure TSplashForm.CloseTimerTimer(Sender: TObject);
begin
  CloseTimer.Enabled := False;
  Close;
end;

procedure TSplashForm.dispDesc(ADesc: string);
begin
  Edit1.Text := ADesc;
end;

procedure TSplashForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TSplashForm.FormShow(Sender: TObject);
begin
  Edit1.Text := '';
end;

end.
