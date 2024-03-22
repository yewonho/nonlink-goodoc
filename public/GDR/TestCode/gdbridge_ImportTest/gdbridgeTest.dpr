program gdbridgeTest;

uses
  {$IFDEF EurekaLog}
  EMemLeaks,
  EResLeaks,
  EDialogWinAPIMSClassic,
  EDialogWinAPIEurekaLogDetailed,
  EDialogWinAPIStepsToReproduce,
  EDebugExports,
  EDebugJCL,
  EFixSafeCallException,
  EMapWin32,
  EAppVCL,
  ExceptionLog7,
  {$ENDIF EurekaLog}
  Vcl.Forms,
  gdbridgeTestMain in 'gdbridgeTestMain.pas' {gdbridgeTestMainForm},
  BridgeDLL in '..\..\Common\Bridge\BridgeDLL.pas',
  GDLog in '..\..\..\Common\Log\GDLog.pas',
  GDThread in '..\..\..\Common\GDThread.pas',
  UtilsUnit in '..\..\..\Common\UtilsUnit.pas',
  BridgeCommUnit in '..\..\Common\Comm\BridgeCommUnit.pas',
  GDJson in '..\..\..\Common\GDJson.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TgdbridgeTestMainForm, gdbridgeTestMainForm);
  Application.Run;
end.

