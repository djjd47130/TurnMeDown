program TurnMeDown;

uses
  Vcl.Forms,
  Winapi.Windows,
  uMain in 'uMain.pas' {frmTurnMeDownMain},
  Vcl.Themes,
  Vcl.Styles,
  uAbout in 'uAbout.pas' {frmAbout},
  JD.Ctrls.Gauges.Objects in '..\JDLib-master\Source\JD.Ctrls.Gauges.Objects.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Turn Me Down';
  Application.CreateForm(TfrmTurnMeDownMain, frmTurnMeDownMain);
  Application.Run;
end.
