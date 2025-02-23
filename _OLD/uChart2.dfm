object frmChart2: TfrmChart2
  Left = 0
  Top = 0
  Margins.Right = 8
  AlphaBlend = True
  AlphaBlendValue = 220
  Caption = 'Volume Chart'
  ClientHeight = 504
  ClientWidth = 1027
  Color = clBlack
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWhite
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Stat: TStatusBar
    Left = 0
    Top = 485
    Width = 1027
    Height = 19
    Panels = <
      item
        Text = 'X Position'
        Width = 120
      end
      item
        Text = 'Y Position'
        Width = 120
      end
      item
        Width = 120
      end>
    ExplicitTop = 491
  end
  object JDPlotChart1: TJDPlotChart
    Left = 0
    Top = 0
    Width = 809
    Height = 485
    Align = alLeft
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -9
    Font.Name = 'Tahoma'
    Font.Style = []
    Font.Quality = fqAntialiased
    Points = <
      item
        Y = 20.000000000000000000
      end
      item
        X = 8.000000000000000000
        Y = 20.000000000000000000
      end
      item
        X = 9.000000000000000000
        Y = 100.000000000000000000
      end
      item
        X = 20.000000000000000000
        Y = 100.000000000000000000
      end
      item
        X = 20.010000228881840000
        Y = 40.000000000000000000
      end
      item
        X = 23.999000549316410000
        Y = 20.000000000000000000
      end>
    UI.Background.Color.Color = clBlack
    UI.Background.Color.UseStandardColor = False
    UI.Background.Alpha = 255
    UI.Background.Transparent = False
    UI.ChartArea.AxisLeft.Labels = lpOutside
    UI.ChartArea.AxisLeft.BaseLine.Color.StandardColor = fcNeutral
    UI.ChartArea.AxisLeft.BaseLine.Color.UseStandardColor = True
    UI.ChartArea.AxisLeft.BaseLine.Alpha = 150
    UI.ChartArea.AxisLeft.BaseLine.Width = 2.000000000000000000
    UI.ChartArea.AxisLeft.BaseLine.Visible = True
    UI.ChartArea.AxisLeft.GridLines.Color.StandardColor = fcNeutral
    UI.ChartArea.AxisLeft.GridLines.Color.UseStandardColor = True
    UI.ChartArea.AxisLeft.GridLines.Alpha = 64
    UI.ChartArea.AxisLeft.GridLines.Width = 1.000000000000000000
    UI.ChartArea.AxisLeft.GridLines.Visible = True
    UI.ChartArea.AxisBottom.Labels = lpOutside
    UI.ChartArea.AxisBottom.BaseLine.Color.StandardColor = fcNeutral
    UI.ChartArea.AxisBottom.BaseLine.Color.UseStandardColor = True
    UI.ChartArea.AxisBottom.BaseLine.Alpha = 150
    UI.ChartArea.AxisBottom.BaseLine.Width = 2.000000000000000000
    UI.ChartArea.AxisBottom.BaseLine.Visible = True
    UI.ChartArea.AxisBottom.GridLines.Color.StandardColor = fcNeutral
    UI.ChartArea.AxisBottom.GridLines.Color.UseStandardColor = True
    UI.ChartArea.AxisBottom.GridLines.Alpha = 64
    UI.ChartArea.AxisBottom.GridLines.Width = 1.000000000000000000
    UI.ChartArea.AxisBottom.GridLines.Visible = True
    UI.ChartArea.Border.Color.Color = 5460819
    UI.ChartArea.Border.Color.UseStandardColor = False
    UI.ChartArea.Border.Alpha = 255
    UI.ChartArea.Border.Width = 1.000000000000000000
    UI.ChartArea.Border.Visible = True
    UI.ChartArea.Color.Color = clBlack
    UI.ChartArea.Color.UseStandardColor = False
    UI.ChartArea.Fill.Color.Color = clMaroon
    UI.ChartArea.Fill.Color.UseStandardColor = False
    UI.ChartArea.Fill.Alpha = 40
    UI.ChartArea.Line.Color.Color = clRed
    UI.ChartArea.Line.Color.UseStandardColor = False
    UI.ChartArea.Line.Alpha = 255
    UI.ChartArea.Line.Width = 2.000000000000000000
    UI.ChartArea.Line.Visible = True
    UI.ChartArea.Points.Alpha = 255
    UI.ChartArea.Points.PointType = ptEllipse
    UI.ChartArea.Points.Width = 10.000000000000000000
    UI.ChartArea.Points.Color.Color = clMaroon
    UI.ChartArea.Points.Color.UseStandardColor = False
    UI.ChartArea.Points.Visible = True
    UI.ChartArea.PointMouse.Alpha = 255
    UI.ChartArea.PointMouse.PointType = ptEllipse
    UI.ChartArea.PointMouse.Width = 12.000000000000000000
    UI.ChartArea.PointMouse.Color.StandardColor = fcRed
    UI.ChartArea.PointMouse.Color.UseStandardColor = True
    UI.ChartArea.PointMouse.Visible = True
    UI.ChartArea.PointHover.Alpha = 255
    UI.ChartArea.PointHover.PointType = ptEllipse
    UI.ChartArea.PointHover.Width = 12.000000000000000000
    UI.ChartArea.PointHover.Color.StandardColor = fcRed
    UI.ChartArea.PointHover.Color.UseStandardColor = True
    UI.ChartArea.PointHover.Visible = True
    UI.ChartArea.Padding = 15.000000000000000000
    UX.ChartArea.AxisBottom.AxisType = atCustom
    UX.ChartArea.AxisBottom.Max = 24.000000000000000000
    UX.ChartArea.AxisBottom.Frequency = 2.000000000000000000
    UX.ChartArea.AxisLeft.AxisType = atPercent
    UX.ChartArea.AxisLeft.Max = 100.000000000000000000
    UX.ChartArea.AxisLeft.Frequency = 10.000000000000000000
    UX.ChartArea.AxisLeft.Format = '0%'
    UX.ChartArea.Overlap = drPushAll
    UX.ChartArea.LinkLeftAndRight = True
    UX.ChartArea.SnapTolerance = 8.000000000000000000
    UX.ChartArea.AddPointAnywhere = False
    ExplicitTop = -6
  end
  object JDFontButton1: TJDFontButton
    Left = 848
    Top = 144
    Width = 100
    Height = 30
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Image.AutoSize = False
    Image.Text = #57715
    Image.Font.Charset = DEFAULT_CHARSET
    Image.Font.Color = clWindowText
    Image.Font.Height = -21
    Image.Font.Name = 'FontAwesome'
    Image.Font.Style = []
    Image.Font.Quality = fqAntialiased
    Overlay.Text = #57715
    Overlay.Font.Charset = DEFAULT_CHARSET
    Overlay.Font.Color = clWindowText
    Overlay.Font.Height = -7
    Overlay.Font.Name = 'FontAwesome'
    Overlay.Font.Style = []
    Overlay.Font.Quality = fqAntialiased
    Overlay.Position = foNone
    Overlay.Margin = 3
    SubTextFont.Charset = DEFAULT_CHARSET
    SubTextFont.Color = clGray
    SubTextFont.Height = -11
    SubTextFont.Name = 'Tahoma'
    SubTextFont.Style = []
    TabOrder = 2
    Text = 'JDFontButton1'
    Visible = False
  end
end
