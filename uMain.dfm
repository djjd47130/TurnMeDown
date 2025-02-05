object frmMain: TfrmMain
  Left = 0
  Top = 0
  AlphaBlend = True
  AlphaBlendValue = 220
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Turn Me Down'
  ClientHeight = 264
  ClientWidth = 335
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'Tahoma'
  Font.Style = [fsBold]
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnMouseDown = FormMouseDown
  DesignSize = (
    335
    264)
  PixelsPerInch = 96
  TextHeight = 18
  object tkMaxVol: TRzTrackBar
    AlignWithMargins = True
    Left = 3
    Top = 198
    Width = 329
    Height = 40
    Cursor = crHandPoint
    Hint = 'The maximum volume during quiet hours'
    Max = 100
    Position = 5
    TickStep = 10
    TrackWidth = 16
    Transparent = True
    OnChange = tkMaxVolChange
    Align = alBottom
    ParentShowHint = False
    ShowHint = False
    TabOrder = 3
  end
  object tpStart: TTimePicker
    Left = 8
    Top = 83
    Cursor = crHandPoint
    Hint = 'The time to start enforcing volume rules'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = []
    MinuteIncrement = 15
    TabOrder = 1
    Time = 0.875000000000000000
    TimeFormat = 'h:mm AMPM'
    OnChange = tpStartChange
  end
  object tpStop: TTimePicker
    Left = 177
    Top = 83
    Cursor = crHandPoint
    Hint = 'The time to stop enforcing volume rules'
    Anchors = [akTop, akRight]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = []
    MinuteIncrement = 15
    TabOrder = 2
    Time = 0.333333333333333300
    TimeFormat = 'h:mm AMPM'
    OnChange = tpStopChange
  end
  object StaticText1: TStaticText
    Left = 8
    Top = 55
    Width = 150
    Height = 22
    Alignment = taCenter
    AutoSize = False
    Caption = 'Quiet Time Start'
    TabOrder = 4
    OnMouseDown = FormMouseDown
  end
  object StaticText2: TStaticText
    Left = 177
    Top = 55
    Width = 150
    Height = 22
    Alignment = taCenter
    Anchors = [akTop, akRight]
    AutoSize = False
    Caption = 'Quiet Time Stop'
    TabOrder = 5
    OnMouseDown = FormMouseDown
  end
  object swActive: TToggleSwitch
    Left = 8
    Top = 17
    Height = 20
    Cursor = crHandPoint
    Hint = 'Whether volume rules are enabled'
    ParentShowHint = False
    ShowHint = False
    State = tssOn
    TabOrder = 0
    OnClick = swActiveClick
  end
  object lblMaxVol: TStaticText
    Left = 0
    Top = 175
    Width = 335
    Height = 20
    Align = alBottom
    Alignment = taCenter
    AutoSize = False
    Caption = '5% During Quiet Hours'
    TabOrder = 6
    OnMouseDown = FormMouseDown
  end
  object pHint: TRzPanel
    Left = 0
    Top = 241
    Width = 335
    Height = 23
    Align = alBottom
    BorderOuter = fsNone
    BorderSides = [sdTop]
    Color = 15987699
    TabOrder = 7
    Transparent = True
    OnMouseDown = FormMouseDown
  end
  object swAutoStart: TToggleSwitch
    Left = 243
    Top = 17
    Width = 84
    Height = 20
    Cursor = crHandPoint
    Hint = 'Whether to start with Windows'
    Alignment = taLeftJustify
    Anchors = [akTop, akRight]
    ParentShowHint = False
    ShowHint = False
    State = tssOn
    StateCaptions.CaptionOn = 'Yes'
    StateCaptions.CaptionOff = 'No'
    TabOrder = 8
    OnClick = swAutoStartClick
  end
  object StaticText3: TStaticText
    Left = 149
    Top = 17
    Width = 85
    Height = 22
    Alignment = taRightJustify
    Anchors = [akTop, akRight]
    Caption = 'Auto Start:'
    TabOrder = 9
    OnMouseDown = FormMouseDown
  end
  object Vol: TJDVolumeControls
    Volume = 4
    Muted = False
    OnVolumeChanged = VolVolumeChanged
    Left = 56
    Top = 128
  end
  object Tmr: TTimer
    Interval = 250
    OnTimer = TmrTimer
    Left = 96
    Top = 128
  end
  object Tray: TRzTrayIcon
    Hint = 'Turn Me Down'
    PopupMenu = TrayPop
    Left = 136
    Top = 128
  end
  object TrayPop: TPopupMenu
    OnPopup = TrayPopPopup
    Left = 176
    Top = 128
    object mShowHide: TMenuItem
      Caption = 'Show'
      OnClick = mShowHideClick
    end
    object mEnabled: TMenuItem
      Caption = 'Enabled'
      Checked = True
      OnClick = mEnabledClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object mExit: TMenuItem
      Caption = 'Exit'
      OnClick = mExitClick
    end
  end
  object AppEvents: TApplicationEvents
    OnHint = AppEventsHint
    Left = 224
    Top = 128
  end
end
