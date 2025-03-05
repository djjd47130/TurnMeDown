program TurnMeDownFMX;

uses
  System.StartUpCopy,
  FMX.Forms,
  uTurnMeDownFMX in 'uTurnMeDownFMX.pas' {frmTurnMeDownFMX};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmTurnMeDownFMX, frmTurnMeDownFMX);
  Application.Run;
end.
