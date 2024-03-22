unit AboutUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Imaging.pngimage,
  Vcl.ExtCtrls;

type
  TAboutForm = class(TForm)
    Image1: TImage;
    Memo1: TMemo;
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
    procedure AboutInfo;
    function GetPackageVersion : string;
  public
    { Public declarations }
  end;

var
  AboutForm: TAboutForm;

implementation
uses
  inifiles, UtilsUnit, SakpungAppVersionInfo;
const
  PackageVersionFile = '..\bin\gdconfig.ini';

{$R *.dfm}

procedure TAboutForm.AboutInfo;
var
  kver : string;
  v : TSakpungAppVersionInfo;
begin
  kver := GetPackageVersion;
  v := TSakpungAppVersionInfo.Create( nil );
  try
    Memo1.Clear;
    Memo1.Lines.Add( '¿Ã∏ß : ' + Application.Title );
    Memo1.Lines.Add( format('CompanyName : %s',[v.CompanyName]) );
    Memo1.Lines.Add( format('PackageVersion : %s',[kver]) );
    Memo1.Lines.Add( format('FileDescription : %s',[v.FileDescription]) );
    Memo1.Lines.Add( format('FileVersion : %s',[v.FileVersion]) );
    Memo1.Lines.Add( format('Internalname : %s',[v.Internalname]) );
    Memo1.Lines.Add( format('OriginalFilename : %s',[v.OriginalFilename]) );
    Memo1.Lines.Add( format('ProgramID : %s',[v.ProgramID]) );
    Memo1.Lines.Add( format('ProductVersion : %s',[v.ProductVersion]) );
    Memo1.Lines.Add( format('Comments : %s',[v.Comments]) );
  finally
    FreeAndNil( v );
  end;
end;

procedure TAboutForm.FormResize(Sender: TObject);
begin
  Image1.Left := (Width - Image1.Width) div 2;
end;

procedure TAboutForm.FormShow(Sender: TObject);
begin
  AboutInfo;
  FormStyle := Application.MainForm.FormStyle;
end;

function TAboutForm.GetPackageVersion: string;
var
  fn : string;
  ini : TIniFile;
begin
  result := '';
  fn := RelToAbs(PackageVersionFile, ExtractFilePath( ParamStr( 0 ) ) );
  if not FileExists( fn ) then
    exit;
  ini := TIniFile.Create( fn );
  try
    Result := ini.ReadString('config','version','');
  finally
    FreeAndNil( ini );
  end;
end;

end.
