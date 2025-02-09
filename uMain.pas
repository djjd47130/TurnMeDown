unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  System.Types, System.UITypes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  Vcl.WinXPickers, Vcl.StdCtrls, Vcl.WinXCtrls,
  Vcl.Menus, Vcl.Themes, Vcl.Styles, Vcl.ComCtrls, Vcl.AppEvnts,
  Registry,
  JD.Common, JD.VolumeControls, JD.FontGlyphs, JD.Ctrls,
  JD.Ctrls.Gauges,
  RzTrkBar, RzTray, RzPanel,
  uAbout, uChart, uChart2,
  System.ImageList, Vcl.ImgList, Vcl.Mask, RzEdit;

const
  SETTINGS_KEY = 'Software\JD Software\TurnMeDown';

type
  TfrmTurnMeDownMain = class(TForm)
    Vol: TJDVolumeControls;
    Tmr: TTimer;
    Tray: TRzTrayIcon;
    TrayPop: TPopupMenu;
    mShowHide: TMenuItem;
    mEnabled: TMenuItem;
    N1: TMenuItem;
    mExit: TMenuItem;
    AppEvents: TApplicationEvents;
    pHint: TRzPanel;
    mAbout: TMenuItem;
    pTopControl: TRzPanel;
    pQuietTimes: TRzPanel;
    swActive: TToggleSwitch;
    swAutoStart: TToggleSwitch;
    pQuietStart: TRzPanel;
    pQuietStop: TRzPanel;
    tpStart: TTimePicker;
    StaticText1: TStaticText;
    tpStop: TTimePicker;
    StaticText2: TStaticText;
    pStatus: TRzPanel;
    lblStatus: TLabel;
    TrayImg: TImageList;
    TrayGlyphs: TJDFontGlyphs;
    gVol: TJDGauge;
    gMax: TJDGauge;
    mChart: TMenuItem;
    procedure VolVolumeChanged(Sender: TObject; const Volume: Integer);
    procedure TmrTimer(Sender: TObject);
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
    procedure swAutoStartClick(Sender: TObject);
    procedure mAboutClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure pQuietTimesResize(Sender: TObject);
    procedure TrayQueryEndSession(Sender: TObject;
      var AllowSessionToEnd: Boolean);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure FormShow(Sender: TObject);
    procedure gVolMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure gVolMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure gVolMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure gMaxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure gMaxMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure gMaxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure mChartClick(Sender: TObject);
  private
    FMutex: THandle;
    FLoading: Boolean;
    FChangingMax: Boolean;
    FChangingVol: Boolean;
    procedure AssertVolume;
    procedure BringExistingInstanceToFront;
    procedure ShowAbout;
  public
    function LoadOptions: Boolean;
    function SaveOptions: Boolean;
    function IsActive: Boolean;
    function IsInQuietHours: Boolean;
  end;

var
  frmTurnMeDownMain: TfrmTurnMeDownMain;

implementation

{$R *.dfm}

uses
  StrUtils,
  Math;

procedure AddAppToStartup(const AppName, AppPath: string);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', True) then
    begin
      Reg.WriteString(AppName, AppPath);
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

procedure RemoveAppFromStartup(const AppName: string);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', False) then
    begin
      if Reg.ValueExists(AppName) then
        Reg.DeleteValue(AppName);
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

function IsAppInStartup(const AppName: string): Boolean;
var
  Reg: TRegistry;
begin
  Result := False; // Default to false
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKeyReadOnly('Software\Microsoft\Windows\CurrentVersion\Run') then
    begin
      Result := Reg.ValueExists(AppName);
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

const
  ASFW_ANY = DWORD(-1);

procedure SetForegroundWindowInternal(hWnd: HWND);
var
  hCurrWnd: THandle;
  dwThisTID, dwCurrTID: DWORD;
  lockTimeOut: DWORD;
begin
  if not IsWindow(hWnd) then
    Exit;

  hCurrWnd := GetForegroundWindow;
  dwThisTID := GetCurrentThreadId;
  dwCurrTID := GetWindowThreadProcessId(hCurrWnd, nil);

  if dwThisTID <> dwCurrTID then
  begin
    AttachThreadInput(dwThisTID, dwCurrTID, True);
    SystemParametersInfo(SPI_GETFOREGROUNDLOCKTIMEOUT, 0, @lockTimeOut, 0);
    SystemParametersInfo(SPI_SETFOREGROUNDLOCKTIMEOUT, 0, nil, SPIF_SENDWININICHANGE or SPIF_UPDATEINIFILE);
    AllowSetForegroundWindow(ASFW_ANY);
  end;

  SetForegroundWindow(hWnd);

  if dwThisTID <> dwCurrTID then
  begin
    SystemParametersInfo(SPI_SETFOREGROUNDLOCKTIMEOUT, 0, @lockTimeOut, SPIF_SENDWININICHANGE or SPIF_UPDATEINIFILE);
    AttachThreadInput(dwThisTID, dwCurrTID, False);
  end;
end;

procedure TfrmTurnMeDownMain.AppEventsHint(Sender: TObject);
begin
  pHint.Caption:= Application.Hint;
end;

procedure TfrmTurnMeDownMain.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  //
end;

procedure TfrmTurnMeDownMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  case MessageDlg('Are you sure you wish to exit Turn Me Down?',
    mtConfirmation, [mbYes,mbNo], 0) of
    mrYes: begin
      CanClose:= True;
    end;
    else begin
      CanClose:= False;
    end;
  end;
  //CanClose:= False;
  //Tray.MinimizeApp;
end;

procedure TfrmTurnMeDownMain.FormCreate(Sender: TObject);
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

  //TStyleManager.TrySetStyle('Blue Texture');
  TStyleManager.TrySetStyle('Marble');

  Height:= 290;

  if not LoadOptions then begin

  end;
end;

procedure TfrmTurnMeDownMain.FormDestroy(Sender: TObject);
begin
  if FMutex <> 0 then
    CloseHandle(FMutex);
end;

procedure TfrmTurnMeDownMain.ShowAbout;
var
  F: TfrmAbout;
begin
  F:= TfrmAbout.Create(nil);
  try
    F.ShowModal;
  finally
    F.Free;
  end;
end;

procedure TfrmTurnMeDownMain.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    ShowAbout;
end;

procedure TfrmTurnMeDownMain.BringExistingInstanceToFront;
var
  ExistingWnd: HWND;
begin
  ExistingWnd := FindWindow(nil, 'Turn Me Down');
  if ExistingWnd <> 0 then begin
    // Restore the window if it is minimized
    if IsIconic(ExistingWnd) then
      ShowWindow(ExistingWnd, SW_RESTORE)
    else
      ShowWindow(ExistingWnd, SW_SHOW);
    // Bring the window to the front
    //SetForegroundWindow(ExistingWnd);
    SetForegroundWindowInternal(ExistingWnd);
  end;
end;

function TfrmTurnMeDownMain.IsActive: Boolean;
begin
  Result:= swActive.State = TToggleSwitchState.tssOn;
end;

function TfrmTurnMeDownMain.IsInQuietHours: Boolean;
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

procedure TfrmTurnMeDownMain.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then begin
    ReleaseCapture;
    Perform(WM_SYSCOMMAND, $F012, 0);
  end;
end;

function TfrmTurnMeDownMain.LoadOptions: Boolean;
var
  R: TRegistry;
begin
  Result:= False;
  if FLoading then Exit;
  FLoading:= True;
  try

    if IsAppInStartup('TurnMeDown') then
      swAutoStart.State:= TToggleSwitchState.tssOn
    else
      swAutoStart.State:= TToggleSwitchState.tssOff;

    R:= TRegistry.Create(KEY_READ or KEY_WRITE);
    try
      R.RootKey:= HKEY_CURRENT_USER;
      Result:= R.KeyExists(SETTINGS_KEY);
      if not Result then begin
        Result:= R.CreateKey(SETTINGS_KEY);
        if Result then begin
          //Initialize defaults...
          if not IsAppInStartup('TurnMeDown') then
            AddAppToStartup('TurnMeDown', Application.ExeName);
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
              gMax.MainValue.Value:= R.ReadInteger('MaxVol');
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

function TfrmTurnMeDownMain.SaveOptions: Boolean;
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
        R.WriteInteger('MaxVol', Round(gMax.MainValue.Value));
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

procedure TfrmTurnMeDownMain.mExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmTurnMeDownMain.mShowHideClick(Sender: TObject);
begin
  Tray.RestoreApp;
end;

procedure TfrmTurnMeDownMain.pQuietTimesResize(Sender: TObject);
begin
  pQuietStart.Width:= Trunc(pQuietTimes.ClientWidth / 2);
end;

procedure TfrmTurnMeDownMain.mAboutClick(Sender: TObject);
begin
  ShowAbout;
end;

procedure TfrmTurnMeDownMain.mChartClick(Sender: TObject);
var
  F: TfrmChart2;
begin
  F:= TfrmChart2.Create(nil);
  try
    F.ShowModal;
  finally
    F.Free;
  end;
end;

procedure TfrmTurnMeDownMain.mEnabledClick(Sender: TObject);
begin
  if IsActive then
    swActive.State:= TToggleSwitchState.tssOff
  else
    swActive.State:= TToggleSwitchState.tssOn;
  SaveOptions;
end;

procedure TfrmTurnMeDownMain.swActiveClick(Sender: TObject);
begin
  SaveOptions;
end;

procedure TfrmTurnMeDownMain.swAutoStartClick(Sender: TObject);
begin
  case swAutoStart.State of
    tssOff: RemoveAppFromStartup('TurnMeDown');
    tssOn:  AddAppToStartup('TurnMeDown', Application.ExeName);
  end;
end;

procedure TfrmTurnMeDownMain.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var
  Pt: TPoint;
  C: TWinControl;
begin
  Pt:= MousePos;
  C:= FindVCLWindow(Pt);
  if C <> nil then begin
    if C = gVol then begin
      //Set current system volume...
      if WheelDelta > 0 then
        Vol.Volume:= Vol.Volume + 2
      else
        Vol.Volume:= Vol.Volume - 2;
      Handled:= True;
    end else
    if C = gMax then begin
      //Set max volume...
      if WheelDelta > 0 then
        gMax.MainValue.Value:= gMax.MainValue.Value + 2
      else
        gMax.MainValue.Value:= gMax.MainValue.Value - 2;
      SaveOptions;
      Handled:= True;
    end;
  end;
end;

procedure TfrmTurnMeDownMain.FormShow(Sender: TObject);
begin

  gVol.MainValue.Value:= Vol.Volume;
end;

procedure TfrmTurnMeDownMain.gMaxMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = TMouseButton.mbLeft then begin
    FChangingMax:= True;
    var P: TPoint:= Point(X, Y);
    var D: Integer:= Round((P.X / gMax.ClientWidth) * 100);
    gMax.MainValue.Value:= D;
    SaveOptions;
    AssertVolume;
  end;
end;

procedure TfrmTurnMeDownMain.gMaxMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if FChangingMax then begin
    var P: TPoint:= Point(X, Y);
    var D: Integer:= Round((P.X / gMax.ClientWidth) * 100);
    gMax.MainValue.Value:= D;
    SaveOptions;
    AssertVolume;
  end;
end;

procedure TfrmTurnMeDownMain.gMaxMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = TMouseButton.mbLeft then begin
    FChangingMax:= False;
    AssertVolume;
  end;
end;

procedure TfrmTurnMeDownMain.gVolMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = TMouseButton.mbLeft then begin
    FChangingVol:= True;
    var P: TPoint:= Point(X, Y);
    var D: Integer:= Round((P.X / gVol.ClientWidth) * 100);
    Vol.Volume:= D;
    AssertVolume;
  end;
end;

procedure TfrmTurnMeDownMain.gVolMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if FChangingVol then begin
    var P: TPoint:= Point(X, Y);
    var D: Integer:= Round((P.X / gVol.ClientWidth) * 100);
    Vol.Volume:= D;
    AssertVolume;
  end;
end;

procedure TfrmTurnMeDownMain.gVolMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = TMouseButton.mbLeft then begin
    FChangingVol:= False;
    AssertVolume;
  end;
end;

procedure TfrmTurnMeDownMain.AssertVolume;
begin
  if IsActive and IsInQuietHours then begin
    lblStatus.Visible:= True;
    Tray.Icons:= TrayImg;
    Tray.Animate:= True;
    Tray.Hint:= 'Turn Me Down (Enforcing Quiet Time)';
    if Vol.Volume > Round(gMax.MainValue.Value) then
      Vol.Volume:= Round(gMax.MainValue.Value);
  end else begin
    lblStatus.Visible:= False;
    Tray.Icons:= nil;
    Tray.Animate:= False;
    Tray.Hint:= 'Turn Me Down';
  end;
end;

procedure TfrmTurnMeDownMain.tpStartChange(Sender: TObject);
begin
  SaveOptions;
end;

procedure TfrmTurnMeDownMain.tpStopChange(Sender: TObject);
begin
  SaveOptions;
end;

procedure TfrmTurnMeDownMain.TrayPopPopup(Sender: TObject);
begin
  //mShowHide.Caption:= IfThen(WindowState = wsNormal, 'Hide', 'Show');
  mEnabled.Checked:= IsActive;
end;

procedure TfrmTurnMeDownMain.TrayQueryEndSession(Sender: TObject;
  var AllowSessionToEnd: Boolean);
begin
  AllowSessionToEnd:= True;
end;

procedure TfrmTurnMeDownMain.TmrTimer(Sender: TObject);
begin
  AssertVolume;
end;

procedure TfrmTurnMeDownMain.VolVolumeChanged(Sender: TObject; const Volume: Integer);
begin
  gVol.MainValue.Value:= Vol.Volume;
  AssertVolume;
end;

end.
