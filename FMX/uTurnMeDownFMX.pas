unit uTurnMeDownFMX;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.TabControl,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.Gestures,
  System.Actions,
  FMX.ActnList;

type
  TfrmTurnMeDownFMX = class(TForm)
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    TabControl2: TTabControl;
    TabItem5: TTabItem;
    ToolBar1: TToolBar;
    lblTitle1: TLabel;
    btnNext: TSpeedButton;
    TabItem6: TTabItem;
    ToolBar2: TToolBar;
    lblTitle2: TLabel;
    btnBack: TSpeedButton;
    TabItem2: TTabItem;
    ToolBar3: TToolBar;
    lblTitle3: TLabel;
    TabItem3: TTabItem;
    ToolBar4: TToolBar;
    lblTitle4: TLabel;
    TabItem4: TTabItem;
    ToolBar5: TToolBar;
    lblTitle5: TLabel;
    GestureManager1: TGestureManager;
    ActionList1: TActionList;
    NextTabAction1: TNextTabAction;
    PreviousTabAction1: TPreviousTabAction;
    StyleBook1: TStyleBook;
    procedure GestureDone(Sender: TObject; const EventInfo: TGestureEventInfo; var Handled: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmTurnMeDownFMX: TfrmTurnMeDownFMX;

implementation

{$R *.fmx}

uses
  System.StrUtils, System.Math,
{$IFDEF MSWINDOWS}
  Winapi.MMSystem, System.Win.ComObj, Winapi.ActiveX, Winapi.PropSys, Winapi.ShlObj
{$ENDIF}
{$IFDEF MACOS}
  Macapi.CoreAudio, Macapi.CoreFoundation
{$ENDIF}
{$IFDEF ANDROID}
  Androidapi.JNI.JavaTypes, Androidapi.JNI.GraphicsContentViewText, Androidapi.Helpers, FMX.Helpers.Android
{$ENDIF}
{$IFDEF IOS}
  iOSapi.MediaPlayer, iOSapi.AVFoundation, iOSapi.Foundation, iOSapi.CocoaTypes, Macapi.ObjCRuntime, Macapi.ObjectiveC
{$ENDIF}
;




procedure SetVolume(Volume: Single);
begin
  {$IFDEF MSWINDOWS}
  // Windows-specific code
  var VolumeValue: DWORD := Round(Volume * $FFFF);
  waveOutSetVolume(0, VolumeValue or (VolumeValue shl 16));
  {$ENDIF}

  {$IFDEF MACOS}
  // macOS-specific code
  var DefaultOutputDeviceID: AudioDeviceID;
  var Size: UInt32 := SizeOf(DefaultOutputDeviceID);
  AudioObjectGetPropertyData(kAudioObjectSystemObject, kAudioHardwarePropertyDefaultOutputDevice, 0, nil, Size, @DefaultOutputDeviceID);
  AudioObjectSetPropertyData(DefaultOutputDeviceID, kAudioDevicePropertyVolumeScalar, 0, nil, SizeOf(Volume), @Volume);
  {$ENDIF}

  {$IFDEF ANDROID}
  // Android-specific code
  var AudioManager: JAudioManager := TJAudioManager.Wrap((TAndroidHelper.Context.getSystemService(TJContext.JavaClass.AUDIO_SERVICE) as ILocalObject).GetObjectID);
  AudioManager.setStreamVolume(TJAudioManager.JavaClass.STREAM_MUSIC, Round(Volume * AudioManager.getStreamMaxVolume(TJAudioManager.JavaClass.STREAM_MUSIC)), 0);
  {$ENDIF}

  {$IFDEF IOS}
  // iOS-specific code
  var AudioSession: AVAudioSession := TAVAudioSession.Wrap(TAVAudioSession.OCClass.sharedInstance);
  AudioSession.setPreferredOutputNumberOfChannels(1, nil);
  AudioSession.setPreferredInputNumberOfChannels(1, nil);
  AudioSession.setPreferredSampleRate(44100, nil);
  AudioSession.setPreferredIOBufferDuration(0.005, nil);
  AudioSession.setActive(true, nil);
  AudioSession.setOutputVolume(Volume, nil);
  {$ENDIF}
end;

function GetVolume: Single;
begin
  {$IFDEF MSWINDOWS}
  // Windows-specific code
  var VolumeValue: DWORD;
  waveOutGetVolume(0, @VolumeValue);
  Result := (VolumeValue and $FFFF) / $FFFF;
  {$ENDIF}

  {$IFDEF MACOS}
  // macOS-specific code
  var DefaultOutputDeviceID: AudioDeviceID;
  var Size: UInt32 := SizeOf(DefaultOutputDeviceID);
  AudioObjectGetPropertyData(kAudioObjectSystemObject, kAudioHardwarePropertyDefaultOutputDevice, 0, nil, Size, @DefaultOutputDeviceID);
  AudioObjectGetPropertyData(DefaultOutputDeviceID, kAudioDevicePropertyVolumeScalar, 0, nil, SizeOf(Result), @Result);
  {$ENDIF}

  {$IFDEF ANDROID}
  // Android-specific code
  var AudioManager: JAudioManager := TJAudioManager.Wrap((TAndroidHelper.Context.getSystemService(TJContext.JavaClass.AUDIO_SERVICE) as ILocalObject).GetObjectID);
  Result := AudioManager.getStreamVolume(TJAudioManager.JavaClass.STREAM_MUSIC) / AudioManager.getStreamMaxVolume(TJAudioManager.JavaClass.STREAM_MUSIC);
  {$ENDIF}

  {$IFDEF IOS}
  // iOS-specific code
  var AudioSession: AVAudioSession := TAVAudioSession.Wrap(TAVAudioSession.OCClass.sharedInstance);
  Result := AudioSession.outputVolume;
  {$ENDIF}
end;





procedure TfrmTurnMeDownFMX.FormCreate(Sender: TObject);
begin
  { This defines the default active tab at runtime }
  TabControl1.ActiveTab := TabItem1;
end;

procedure TfrmTurnMeDownFMX.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkHardwareBack then
  begin
    if (TabControl1.ActiveTab = TabItem1) and (TabControl2.ActiveTab = TabItem6) then
    begin
      TabControl2.Previous;
      Key := 0;
    end;
  end;
end;

procedure TfrmTurnMeDownFMX.GestureDone(Sender: TObject; const EventInfo: TGestureEventInfo; var Handled: Boolean);
begin
  case EventInfo.GestureID of
    sgiLeft:
      begin
        if TabControl1.ActiveTab <> TabControl1.Tabs[TabControl1.TabCount - 1] then
          TabControl1.ActiveTab := TabControl1.Tabs[TabControl1.TabIndex + 1];
        Handled := True;
      end;

    sgiRight:
      begin
        if TabControl1.ActiveTab <> TabControl1.Tabs[0] then
          TabControl1.ActiveTab := TabControl1.Tabs[TabControl1.TabIndex - 1];
        Handled := True;
      end;
  end;
end;

procedure SetMute(Mute: Boolean);
begin
  {$IFDEF MSWINDOWS}
  // Windows-specific code
  var VolumeValue: DWORD := IfThen(Mute, 0, $FFFF);
  waveOutSetVolume(0, VolumeValue or (VolumeValue shl 16));
  {$ENDIF}

  {$IFDEF MACOS}
  // macOS-specific code
  var DefaultOutputDeviceID: AudioDeviceID;
  var Size: UInt32 := SizeOf(DefaultOutputDeviceID);
  var IsMuted: UInt32 := IfThen(Mute, 1, 0);
  AudioObjectGetPropertyData(kAudioObjectSystemObject, kAudioHardwarePropertyDefaultOutputDevice, 0, nil, Size, @DefaultOutputDeviceID);
  AudioObjectSetPropertyData(DefaultOutputDeviceID, kAudioDevicePropertyMute, 0, nil, SizeOf(IsMuted), @IsMuted);
  {$ENDIF}

  {$IFDEF ANDROID}
  // Android-specific code
  var AudioManager: JAudioManager := TJAudioManager.Wrap((TAndroidHelper.Context.getSystemService(TJContext.JavaClass.AUDIO_SERVICE) as ILocalObject).GetObjectID);
  AudioManager.setStreamMute(TJAudioManager.JavaClass.STREAM_MUSIC, Mute);
  {$ENDIF}

  {$IFDEF IOS}
  // iOS-specific code
  var AudioSession: AVAudioSession := TAVAudioSession.Wrap(TAVAudioSession.OCClass.sharedInstance);
  AudioSession.setActive(True, nil);
  var AudioOutput: AVAudioOutputNode := TAVAudioEngine.Wrap(TAVAudioEngine.OCClass.mainMixerNode).outputNode;
  AudioOutput.setVolume(IfThen(Mute, 0.0, 1.0));
  {$ENDIF}
end;

function IsMuted: Boolean;
begin
  {$IFDEF MSWINDOWS}
  // Windows-specific code
  var VolumeValue: DWORD;
  waveOutGetVolume(0, @VolumeValue);
  Result := (VolumeValue and $FFFF) = 0;
  {$ENDIF}

  {$IFDEF MACOS}
  // macOS-specific code
  var DefaultOutputDeviceID: AudioDeviceID;
  var Size: UInt32 := SizeOf(DefaultOutputDeviceID);
  var IsMuted: UInt32;
  AudioObjectGetPropertyData(kAudioObjectSystemObject, kAudioHardwarePropertyDefaultOutputDevice, 0, nil, Size, @DefaultOutputDeviceID);
  AudioObjectGetPropertyData(DefaultOutputDeviceID, kAudioDevicePropertyMute, 0, nil, SizeOf(IsMuted), @IsMuted);
  Result := IsMuted = 1;
  {$ENDIF}

  {$IFDEF ANDROID}
  // Android-specific code
  var AudioManager: JAudioManager := TJAudioManager.Wrap((TAndroidHelper.Context.getSystemService(TJContext.JavaClass.AUDIO_SERVICE) as ILocalObject).GetObjectID);
  Result := AudioManager.isStreamMute(TJAudioManager.JavaClass.STREAM_MUSIC);
  {$ENDIF}

  {$IFDEF IOS}
  // iOS-specific code
  var AudioSession: AVAudioSession := TAVAudioSession.Wrap(TAVAudioSession.OCClass.sharedInstance);
  AudioSession.setActive(True, nil);
  Result := AudioSession.outputVolume = 0.0;
  {$ENDIF}
end;


{$IFDEF MACOS}
procedure InitializeCoreAudio;
begin
  // Placeholder for CoreAudio initialization if needed
end;

procedure FinalizeCoreAudio;
begin
  // Placeholder for CoreAudio finalization if needed
end;
{$ENDIF}


{$IFDEF IOS}
procedure InitializeAVAudioSession;
var
  AudioSession: AVAudioSession;
begin
  AudioSession := TAVAudioSession.Wrap(TAVAudioSession.OCClass.sharedInstance);
  AudioSession.setActive(true, nil);
end;

procedure FinalizeAVAudioSession;
var
  AudioSession: AVAudioSession;
begin
  AudioSession := TAVAudioSession.Wrap(TAVAudioSession.OCClass.sharedInstance);
  AudioSession.setActive(false, nil);
end;
{$ENDIF}



initialization
  {$IFDEF MACOS}
  InitializeCoreAudio;
  {$ENDIF}
  {$IFDEF IOS}
  InitializeAVAudioSession;
  {$ENDIF}

finalization
  {$IFDEF MACOS}
  FinalizeCoreAudio;
  {$ENDIF}
  {$IFDEF IOS}
  FinalizeAVAudioSession;
  {$ENDIF}

end.

