unit QueryTestUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.Grids, Vcl.DBGrids,
  Vcl.ExtCtrls, Vcl.StdCtrls, DBDMUnit, MemDS, DBAccess, LiteAccess;

type
  TQueryTestForm = class(TForm)
    Panel2: TPanel;
    Panel3: TPanel;
    Button2: TButton;
    Button3: TButton;
    Memo1: TMemo;
    Splitter1: TSplitter;
    DBGrid1: TDBGrid;
    LiteQuery1: TLiteQuery;
    LiteQuery2: TLiteQuery;
    DataSource1: TDataSource;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  QueryTestForm: TQueryTestForm;

implementation

{$R *.dfm}

procedure TQueryTestForm.Button2Click(Sender: TObject);
begin
  LiteQuery1.DisableControls;
  try
    try
      LiteQuery1.Active := False;
      LiteQuery1.SQL.Clear;
      LiteQuery1.SQL.Assign( Memo1.Lines );
      LiteQuery1.Active := True;
    except
      on e : exception do
      begin
        ShowMessage( format('%s(%s)',[e.Message, e.ClassName]) );
      end;
    end;
  finally
    LiteQuery1.EnableControls;
  end;
end;

procedure TQueryTestForm.Button3Click(Sender: TObject);
begin
  try
    LiteQuery2.SQL.Clear;
    LiteQuery2.SQL.Assign( Memo1.Lines );
    LiteQuery2.ExecSQL;
  except
    on e : exception do
    begin
      ShowMessage( format('%s(%s)',[e.Message, e.ClassName]) );
    end;
  end;
end;

procedure TQueryTestForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

end.
