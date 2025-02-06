object frmAbout: TfrmAbout
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'About Turn Me Down'
  ClientHeight = 190
  ClientWidth = 198
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'Tahoma'
  Font.Style = [fsBold]
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 18
  object lblMaxVol: TStaticText
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 192
    Height = 24
    Align = alTop
    Alignment = taCenter
    AutoSize = False
    Caption = 'Turn Me Down'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    ExplicitWidth = 311
  end
  object StaticText1: TStaticText
    AlignWithMargins = True
    Left = 3
    Top = 63
    Width = 192
    Height = 20
    Cursor = crHandPoint
    Hint = 'https://jerrydodge.com'
    Align = alTop
    Alignment = taCenter
    AutoSize = False
    Caption = 'by Jerry Dodge'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Tahoma'
    Font.Style = [fsBold, fsUnderline]
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    OnClick = StaticText1Click
    ExplicitLeft = 8
    ExplicitTop = 53
    ExplicitWidth = 311
  end
  object StaticText2: TStaticText
    AlignWithMargins = True
    Left = 3
    Top = 89
    Width = 192
    Height = 48
    Align = alTop
    Alignment = taCenter
    AutoSize = False
    Caption = 'Restrict system volume during quiet hours'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    ExplicitLeft = -2
    ExplicitTop = 59
  end
  object StaticText3: TStaticText
    AlignWithMargins = True
    Left = 3
    Top = 143
    Width = 192
    Height = 20
    Cursor = crHandPoint
    Hint = 'https://github.com/djjd47130/TurnMeDown'
    Align = alTop
    Alignment = taCenter
    AutoSize = False
    Caption = 'View on GitHub'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -15
    Font.Name = 'Tahoma'
    Font.Style = [fsBold, fsUnderline]
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
    OnClick = StaticText3Click
    ExplicitLeft = 8
    ExplicitTop = 137
  end
  object lblVersion: TStaticText
    AlignWithMargins = True
    Left = 3
    Top = 33
    Width = 192
    Height = 24
    Align = alTop
    Alignment = taCenter
    AutoSize = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
  end
end
