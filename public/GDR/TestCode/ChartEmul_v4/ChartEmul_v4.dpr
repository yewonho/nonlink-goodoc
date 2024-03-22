program ChartEmul_v4;

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
  System.SysUtils,
  Vcl.Forms,
  ChartEmul_v4Unit in 'ChartEmul_v4Unit.pas' {ChartEmulV4Form},
  BridgeDLL in '..\..\Common\Bridge\BridgeDLL.pas',
  GDLog in '..\..\..\Common\Log\GDLog.pas',
  GDThread in '..\..\..\Common\GDThread.pas',
  UtilsUnit in '..\..\..\Common\UtilsUnit.pas',
  BridgeCommUnit in '..\..\Common\Comm\BridgeCommUnit.pas',
  GDJson in '..\..\..\Common\GDJson.pas',
  GlobalUnit in 'GlobalUnit.pas',
  DBDMUnit in 'DBDMUnit.pas' {DBDM: TDataModule},
  QueryTestUnit in 'QueryTestUnit.pas' {QueryTestForm},
  GDBridge in '..\..\Common\Bridge\GDBridge.pas',
  PatientMngUnit in 'PatientMngUnit.pas' {PatientMngForm},
  ReceptionMngUnit in 'ReceptionMngUnit.pas' {ReceptionMngForm},
  RoomListDialogUnit in 'RoomListDialogUnit.pas' {RoomListDialogForm},
  ReservationMngUnit in 'ReservationMngUnit.pas' {ReservationMngForm},
  RoomMngUnit in 'RoomMngUnit.pas' {RoomMngForm},
  GDDateTime in '..\..\..\Common\GDDateTime.pas',
  EPBridgeCommUnit in '..\..\Common\Comm\EPBridgeCommUnit.pas',
  ElectronicPrescriptionsDefaultUnit in 'ElectronicPrescriptionsDefaultUnit.pas' {ElectronicPrescriptionsDefaultForm},
  AccountDMUnit in 'AccountDMUnit.pas' {AccountDM: TDataModule},
  AccountRequestUnit in 'AccountRequestUnit.pas' {AccountRequestForm},
  ReceptionIDChangeUnit in 'ReceptionIDChangeUnit.pas' {ReceptionIDChangeForm},
  ReservationScheduleSendUnit in 'ReservationScheduleSendUnit.pas' {ReservationScheduleSend},
  IdWebSocketSimpleClient in 'Indy\Lib\Core\IdWebSocketSimpleClient.pas',
  PatientStateAutomationUnit in 'PatientStateAutomationUnit.pas' {PatientStateAutomationForm};

{$R *.res}

begin
//  SetLogRootFolder( RelToAbs('..\Log\ChartEmul', ExtractFilePath(ParamStr(0)) ) );

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TChartEmulV4Form, ChartEmulV4Form);
  Application.CreateForm(TDBDM, DBDM);
  Application.CreateForm(TPatientMngForm, PatientMngForm);
  Application.CreateForm(TReceptionMngForm, ReceptionMngForm);
  Application.CreateForm(TRoomListDialogForm, RoomListDialogForm);
  Application.CreateForm(TReservationMngForm, ReservationMngForm);
  Application.CreateForm(TRoomMngForm, RoomMngForm);
  Application.CreateForm(TElectronicPrescriptionsDefaultForm, ElectronicPrescriptionsDefaultForm);
  Application.CreateForm(TAccountDM, AccountDM);
  Application.CreateForm(TReservationScheduleSendForm, ReservationScheduleSendForm);
  Application.CreateForm(TPatientStateAutomationForm, PatientStateAutomationForm);
  Application.Run;
end.

