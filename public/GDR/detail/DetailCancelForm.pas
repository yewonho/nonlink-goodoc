unit DetailCancelForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  SakpungImageButton, Vcl.Grids, SakpungStyleButton, RnRData, Vcl.AppEvnts,
  TranslucentFormUnit, SakpungMemo, Vcl.ComCtrls, RRObserverUnit;

type
  TTDetailCancelForm = class(TForm)
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
//    procedure Button2Click(Sender: TObject);
//    procedure Button1Click(Sender: TObject);
  private
  { Private declarations }
  public
  { Public declarations }
  end;


  var
  TDetailCancelForm : TTDetailCancelForm;

implementation

{$R *.dfm}

//
//procedure TDetailCancelForm.Button1Click(Sender: TObject);
//begin
//
//   ModalResult := mrOk; // ��ȭ ���ڸ� �����մϴ�.
//
//end;
//
//procedure TDetailCancelForm.Button2Click(Sender: TObject);
//begin
//  ModalResult := mrCancel; // ��ȭ ���ڸ� �����մϴ�.
//
//end;

end.
