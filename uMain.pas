unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, System.UITypes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  Vcl.WinXPickers, Vcl.StdCtrls, Vcl.WinXCtrls,
  Vcl.Menus, Vcl.Themes, Vcl.Styles, Vcl.ComCtrls, Vcl.AppEvnts,
  Registry,
  JD.Common, JD.VolumeControls,
  RzTrkBar, RzTray, RzPanel;

type
  TfrmMain = class(TForm)
    Vol: TJDVolumeControls;
    tkMaxVol: TRzTrackBar;
    Tmr: TTimer;
    tpStart: TTimePicker;
    tpStop: TTimePicker;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    swActive: TToggleSwitch;
    Tray: TRzTrayIcon;
    lblMaxVol: TStaticText;
    TrayPop: TPopupMenu;
    mShowHide: TMenuItem;
    mEnabled: TMenuItem;
    N1: TMenuItem;
    mExit: TMenuItem;
    AppEvents: TApplicationEvents;
    pHint: TRzPanel;
    procedure VolVolumeChanged(Sender: TObject; const Volume: Integer);
    procedure TmrTimer(Sender: TObject);
    procedure tkMaxVolChange(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure tpStartChange(Sender: TObject);
    procedure tpStopChange(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure swActiveClick(Sender: TObject);
    procedure mExitClick(Sender: TObject);
    procedure mShowHideClick(Sender: TObject);
    procedure mEnabledClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure AppEventsHint(Sender: TObject);
    procedure TrayPopPopup(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FMutex: THandle;
    FLoading: Boolean;
    procedure AssertVolume;
    procedure BringExistingInstanceToFront;
  public
    function LoadOptions: Boolean;
    function SaveOptions: Boolean;
    function IsActive: Boolean;
    function IsInQuietHours: Boolean;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses
  StrUtils,
  Math;

const
  SETTINGS_KEY = 'Software\JD Software\TurnMeDown';

procedure TfrmMain.AppEventsHint(Sender: TObject);
begin
  pHint.Caption:= Application.Hint;
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose:= False;
  Tray.MinimizeApp;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  FMutex := CreateMutex(nil, False, 'TurnMeDown');
  if GetLastError = ERROR_ALREADY_EXISTS then begin
    //MessageDlg('Another instance of this application is already running.', mtWarning, [mbOK], 0);
    BringExistingInstanceToFront;
    Application.Terminate;
  end;

  {$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown:= True;
  {$ENDIF}

  TStyleManager.TrySetStyle('Blue Texture');

  Height:= 250;

  if not LoadOptions then begin

  end;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  if FMutex <> 0 then
    CloseHandle(FMutex);
end;

procedure TfrmMain.BringExistingInstanceToFront;
var
  ExistingWnd: HWND;
begin
  ExistingWnd := FindWindow(nil, 'Turn Me Down');
  if ExistingWnd <> 0 then begin
    ShowWindow(ExistingWnd, SW_SHOWNORMAL);
    SetForegroundWindow(ExistingWnd);
  end;
end;

function TfrmMain.IsActive: Boolean;
begin
  Result:= swActive.State = TToggleSwitchState.tssOn;
end;

function TfrmMain.IsInQuietHours: Boolean;
var
  T, T1, T2: TTime;
begin
  T := Time;
  T1 := tpStart.Time;
  T2 := tpStop.Time;
  if T1 < T2 then begin
    // Time range is within the same day
    Result := (T >= T1) and (T <= T2);
  end else begin
    // Time range spans over midnight
    Result := (T >= T1) or (T <= T2);
  end;
end;

procedure TfrmMain.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then begin
    ReleaseCapture;
    Perform(WM_SYSCOMMAND, $F012, 0);
  end;
end;

function TfrmMain.LoadOptions: Boolean;
var
  R: TRegistry;
begin
  Result:= False;
  if FLoading then Exit;
  FLoading:= True;
  try
    R:= TRegistry.Create(KEY_READ or KEY_WRITE);
    try
      R.RootKey:= HKEY_CURRENT_USER;
      Result:= R.KeyExists(SETTINGS_KEY);
      if not Result then begin
        Result:= R.CreateKey(SETTINGS_KEY);
        if Result then begin
          //Initialize defaults...
          Result:= R.OpenKey(SETTINGS_KEY, True);
          if Result then begin
            R.WriteInteger('Active', 1);
            R.WriteString('QuietStart', '9:00 PM');
            R.WriteString('QuietStop', '9:00 AM');
            R.WriteInteger('MaxVol', 15);
          end;
        end;
      end;
      if Result then begin
        Result:= R.KeyExists(SETTINGS_KEY);
        if Result then begin
          Result:= R.OpenKey(SETTINGS_KEY, True);
          try
            if Result then begin
              //Load actual options
              if R.ReadInteger('Active') = 1 then
                swActive.State:= TToggleSwitchState.tssOn
              else
                swActive.State:= TToggleSwitchState.tssOff;
              tpStart.Time:= StrToTimeDef(R.ReadString('QuietStart'), 0);
              tpStop.Time:= StrToTimeDef(R.ReadString('QuietStop'), 0);
              tkMaxVol.Position:= R.ReadInteger('MaxVol');
              Result:= True;
            end;
          finally
            R.CloseKey;
          end;
        end;
      end;
    finally
      R.Free;
    end;
  finally
    FLoading:= False;
  end;
end;

function TfrmMain.SaveOptions: Boolean;
var
  R: TRegistry;
begin
  Result:= False;
  if FLoading then Exit;
  R:= TRegistry.Create(KEY_READ or KEY_WRITE);
  try
    R.RootKey:= HKEY_CURRENT_USER;
    Result:= R.OpenKey(SETTINGS_KEY, True);
    try
      if Result then begin
        R.WriteInteger('Active', IfThen(IsActive, 1, 0));
        R.WriteString('QuietStart', FormatDateTime('hh:nn AMPM', tpStart.Time));
        R.WriteString('QuietStop', FormatDateTime('hh:nn AMPM', tpStop.Time));
        R.WriteInteger('MaxVol', tkMaxVol.Position);
        Result:= True;
      end else begin
        MessageDlg('Sorry, unable to save options.', mtError, [mbOK], 0);
      end;
    finally
      R.CloseKey;
    end;
  finally
    R.Free;
  end;
end;

procedure TfrmMain.mExitClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TfrmMain.mShowHideClick(Sender: TObject);
begin
  Tray.RestoreApp;
end;

procedure TfrmMain.mEnabledClick(Sender: TObject);
begin
  if IsActive then
    swActive.State:= TToggleSwitchState.tssOff
  else
    swActive.State:= TToggleSwitchState.tssOn;
  SaveOptions;
end;

procedure TfrmMain.swActiveClick(Sender: TObject);
begin
  SaveOptions;
end;

procedure TfrmMain.tkMaxVolChange(Sender: TObject);
begin
  lblMaxVol.Caption:= 'Max Volume: '+
    IntToStr(tkMaxVol.Position) +
    '% During Quiet Hours';
  SaveOptions;
end;

procedure TfrmMain.AssertVolume;
begin
  if IsActive and IsInQuietHours then begin
    if Vol.Volume > tkMaxVol.Position then
      Vol.Volume:= tkMaxVol.Position;
  end;
end;

procedure TfrmMain.tpStartChange(Sender: TObject);
begin
  SaveOptions;
end;

procedure TfrmMain.tpStopChange(Sender: TObject);
begin
  SaveOptions;
end;

procedure TfrmMain.TrayPopPopup(Sender: TObject);
begin
  mEnabled.Checked:= IsActive;
end;

procedure TfrmMain.TmrTimer(Sender: TObject);
begin
  AssertVolume;
end;

procedure TfrmMain.VolVolumeChanged(Sender: TObject; const Volume: Integer);
begin
  AssertVolume;
end;

end.
