object frmChart: TfrmChart
  Left = 0
  Top = 0
  Caption = 'Chart'
  ClientHeight = 312
  ClientWidth = 606
  Color = clBlack
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  StyleElements = [seFont, seBorder]
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object C: TPaintBox
    Left = 0
    Top = 0
    Width = 606
    Height = 293
    Align = alClient
    Color = 3618615
    ParentColor = False
    OnDblClick = CDblClick
    OnMouseDown = CMouseDown
    OnMouseMove = CMouseMove
    OnMouseUp = CMouseUp
    OnPaint = CPaint
    ExplicitLeft = 96
    ExplicitTop = 128
    ExplicitWidth = 105
    ExplicitHeight = 105
  end
  object Stat: TStatusBar
    Left = 0
    Top = 293
    Width = 606
    Height = 19
    Panels = <
      item
        Width = 120
      end
      item
        Width = 120
      end
      item
        Width = 120
      end>
  end
end
