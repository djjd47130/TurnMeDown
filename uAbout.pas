unit uAbout;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  ShellAPI;

type
  TfrmAbout = class(TForm)
    lblMaxVol: TStaticText;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    lblVersion: TStaticText;
    procedure StaticText3Click(Sender: TObject);
    procedure StaticText1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmAbout: TfrmAbout;

implementation

{$R *.dfm}

function GetAppVersion: string;
var
  Size, Handle: DWORD;
  Buffer: TBytes;
  FileInfo: PVSFixedFileInfo;
  FileInfoSize: UINT;
begin
  Size := GetFileVersionInfoSize(PChar(ParamStr(0)), Handle);
  if Size = 0 then
    RaiseLastOSError;
  SetLength(Buffer, Size);
  if not GetFileVersionInfo(PChar(ParamStr(0)), Handle, Size, Buffer) then
    RaiseLastOSError;
  if not VerQueryValue(Buffer, '\', Pointer(FileInfo), FileInfoSize) then
    RaiseLastOSError;
  Result := Format('%d.%d.%d.%d', [
    HiWord(FileInfo.dwFileVersionMS), // Major version
    LoWord(FileInfo.dwFileVersionMS), // Minor version
    HiWord(FileInfo.dwFileVersionLS), // Release
    LoWord(FileInfo.dwFileVersionLS)  // Build
  ]);
end;

procedure OpenURL(const URL: string);
begin
  ShellExecute(0, 'open', PChar(URL), nil, nil, SW_SHOWNORMAL);
end;

procedure TfrmAbout.FormCreate(Sender: TObject);
begin
  lblVersion.Caption:= GetAppVersion;
end;

procedure TfrmAbout.StaticText1Click(Sender: TObject);
begin
  OpenURL('https://jerrydodge.com');
end;

procedure TfrmAbout.StaticText3Click(Sender: TObject);
begin
  OpenURL('https://github.com/djjd47130/TurnMeDown');
end;

end.
