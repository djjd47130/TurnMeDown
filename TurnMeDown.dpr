program TurnMeDown;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {frmMain},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Turn Me Down';
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
