; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "Turn Me Down"
#define MyAppVersion "0.7"
#define MyAppPublisher "Jerry Dodge"
#define MyAppURL "https://github.com/djjd47130/TurnMeDown"
#define MyAppExeName "TurnMeDown.exe"

[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{C7176E3A-E16F-4814-9DFF-E6D9236E4C40}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppPublisher}\{#MyAppName}
DisableProgramGroupPage=yes
; Uncomment the following line to run in non administrative install mode (install for current user only.)
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
OutputDir=D:\Development\GitHub\TurnMeDown\Output
OutputBaseFilename=InstallTurnMeDown
SetupIconFile=D:\Development\GitHub\TurnMeDown\8669809.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern
UninstallDisplayIcon={app}\TurnMeDown.exe

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "D:\Development\GitHub\TurnMeDown\Bin\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{autoprograms}\{#MyAppPublisher}\Turn Me Down\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall

[Registry]
Root: HKCU; Subkey: "Software\JD Software"; Flags: uninsdeletekeyifempty
Root: HKCU; Subkey: "Software\JD Software\TurnMeDown"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\JD Software\TurnMeDown"; ValueType: dword; ValueName: "Active"; ValueData: "1"; Flags: createvalueifdoesntexist
Root: HKCU; Subkey: "Software\JD Software\TurnMeDown"; ValueType: dword; ValueName: "MaxVol"; ValueData: "20"; Flags: createvalueifdoesntexist
Root: HKCU; Subkey: "Software\JD Software\TurnMeDown"; ValueType: dword; ValueName: "UseChart"; ValueData: "0"; Flags: createvalueifdoesntexist
Root: HKCU; Subkey: "Software\JD Software\TurnMeDown"; ValueType: string; ValueName: "QuietStart"; ValueData: "09:00 PM"; Flags: createvalueifdoesntexist
Root: HKCU; Subkey: "Software\JD Software\TurnMeDown"; ValueType: string; ValueName: "QuietStop"; ValueData: "09:00 AM"; Flags: createvalueifdoesntexist       
Root: HKCU; Subkey: "Software\JD Software\TurnMeDown"; ValueType: string; ValueName: "ChartData"; ValueData: ""; Flags: createvalueifdoesntexist

[Code]




