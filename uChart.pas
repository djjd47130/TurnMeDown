unit uChart;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.Win.Registry, System.Types, System.UITypes,
  System.SysUtils, System.Variants, System.Classes,
  System.Generics.Collections, System.Generics.Defaults,
  Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VclTee.TeeGDIPlus, VCLTee.TeEngine,
  VCLTee.Series, Vcl.ExtCtrls, VCLTee.TeeProcs, VCLTee.Chart, Vcl.ComCtrls;

const
  AccentColor: TColor = $00282828;
  GridLineColor: TColor = $00373737;

type

  TPlotPoint = record
    Hour: Single; //0-24 where decimals represent minutes
    Perc: Single; //0-100 percent
  end;

  TfrmChart = class(TForm)
    C: TPaintBox;
    Stat: TStatusBar;
    procedure CPaint(Sender: TObject);
    procedure CDblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    FPoints: TArray<TPlotPoint>;
    HoveringIndex: Integer;
    DraggingIndex: Integer;
    Dragging: Boolean;
    DraggingVertical: Boolean;
    Buffer: TBitmap;
    GhostPointVisible: Boolean;
    GhostPlotPoint: TPlotPoint;
    function ChartRect: TRect;
    function PlotPointToPoint(P: TPlotPoint): TPoint;
    function PointToPlotPoint(P: TPoint): TPlotPoint;
    function LoadPlotPointsFromRegistry: Boolean;
    procedure SavePlotPointsToRegistry;
  public
    procedure LoadPlotPoints(Points: TArray<TPlotPoint>);
    procedure CreatePlotPoints(TimeStart, TimeStop: TTime; Perc: Single);
    function GetTimePerc(ATime: TTime): Single;
  end;

var
  frmChart: TfrmChart;

implementation

{$R *.dfm}

uses
  Math, StrUtils, DateUtils,
  uMain;

function PointLineDistance(P, A, B: TPoint): Single;
var
  AB, AP, BP: TPoint;
  AB_Dot_AB, AP_Dot_AB, BP_Dot_AB: Single;
begin
  AB := Point(B.X - A.X, B.Y - A.Y);
  AP := Point(P.X - A.X, P.Y - A.Y);
  BP := Point(P.X - B.X, P.Y - B.Y);

  AB_Dot_AB := AB.X * AB.X + AB.Y * AB.Y;
  AP_Dot_AB := AP.X * AB.X + AP.Y * AB.Y;
  BP_Dot_AB := BP.X * AB.X + BP.Y * AB.Y;

  if AP_Dot_AB <= 0 then
    Result := Sqrt(AP.X * AP.X + AP.Y * AP.Y)
  else if BP_Dot_AB >= 0 then
    Result := Sqrt(BP.X * BP.X + BP.Y * BP.Y)
  else
    Result := Abs(AB.X * AP.Y - AB.Y * AP.X) / Sqrt(AB_Dot_AB);
end;

procedure TfrmChart.FormCreate(Sender: TObject);
begin
  Buffer:= TBitmap.Create;
  Buffer.SetSize(C.Width, C.Height);

  HoveringIndex := -1;
  DraggingIndex := -1;
  Dragging := False;
  DraggingVertical:= False;

  if not LoadPlotPointsFromRegistry then begin
    CreatePlotPoints(frmTurnMeDownMain.tpStart.Time, frmTurnMeDownMain.tpStop.Time,
      frmTurnMeDownMain.gMax.MainValue.Value);
    Self.SavePlotPointsToRegistry;
  end;
end;

procedure TfrmChart.FormDestroy(Sender: TObject);
begin
  Buffer.Free;
end;

procedure TfrmChart.FormResize(Sender: TObject);
begin
  Buffer.SetSize(C.Width, C.Height);
  C.Invalidate;
end;

procedure TfrmChart.LoadPlotPoints(Points: TArray<TPlotPoint>);
begin
  FPoints := Points;
  C.Invalidate;
end;

procedure TfrmChart.CreatePlotPoints(TimeStart, TimeStop: TTime; Perc: Single);
var
  StartHour, StopHour: Single;
  Midnight: Boolean;
begin
  StartHour := HourOf(TimeStart) + (MinuteOf(TimeStart) / 60);
  StopHour := HourOf(TimeStop) + (MinuteOf(TimeStop) / 60);

  Midnight := StopHour < StartHour; // Detect if times lapse over midnight

  if Midnight then
  begin
    SetLength(FPoints, 6);
    FPoints[0].Hour := 0;
    FPoints[0].Perc := Perc; // 0 : 20
    FPoints[1].Hour := StopHour;
    FPoints[1].Perc := Perc; // 9 : 20
    FPoints[2].Hour := StopHour;
    FPoints[2].Perc := 100; // 9 : 100
    FPoints[3].Hour := StartHour;
    FPoints[3].Perc := 100; // 21 : 100
    FPoints[4].Hour := StartHour;
    FPoints[4].Perc := Perc; // 21 : 20
    FPoints[5].Hour := 23.9999;
    FPoints[5].Perc := Perc; // 24 : 20
  end
  else
  begin
    SetLength(FPoints, 6);
    FPoints[0].Hour := 0;
    FPoints[0].Perc := 100; // 0 : 100
    FPoints[1].Hour := StartHour;
    FPoints[1].Perc := 100; // StartHour : 100
    FPoints[2].Hour := StartHour;
    FPoints[2].Perc := Perc; // StartHour : Perc
    FPoints[3].Hour := StopHour;
    FPoints[3].Perc := Perc; // StopHour : Perc
    FPoints[4].Hour := StopHour;
    FPoints[4].Perc := 100; // StopHour : 100
    FPoints[5].Hour := 23.9999;
    FPoints[5].Perc := 100; // 24 : 100
  end;

  C.Invalidate;
end;
procedure TfrmChart.CDblClick(Sender: TObject);
var
  MousePos: TPoint;
  ClickPoint: TPlotPoint;
  MinDist, Dist: Single;
  DeleteIndex, InsertIndex: Integer;
  NearestP1, NearestP2: TPlotPoint;
  T: Single;
begin
  MousePos := C.ScreenToClient(Mouse.CursorPos);
  ClickPoint := PointToPlotPoint(MousePos);
  MinDist := 10; // Threshold distance to detect proximity to a point or line
  DeleteIndex := -1;

  // Check if the double-click is near an existing point
  for var I := 0 to Length(FPoints) - 1 do
  begin
    var P := PlotPointToPoint(FPoints[I]);
    Dist := Sqrt(Sqr(P.X - MousePos.X) + Sqr(P.Y - MousePos.Y));
    if Dist < MinDist then
    begin
      DeleteIndex := I;
      Break;
    end;
  end;

  // If an existing point is found near the double-click, delete it
  if DeleteIndex <> -1 then
  begin
    for var I := DeleteIndex to Length(FPoints) - 2 do
      FPoints[I] := FPoints[I + 1];
    SetLength(FPoints, Length(FPoints) - 1);
    C.Invalidate;
    Exit;
  end;

  // Detect if double-click is near a line
  for var I := 0 to Length(FPoints) - 2 do
  begin
    var P1 := PlotPointToPoint(FPoints[I]);
    var P2 := PlotPointToPoint(FPoints[I + 1]);

    // Check the proximity to the line segment P1-P2
    Dist := PointLineDistance(MousePos, P1, P2);
    if Dist < MinDist then
    begin
      NearestP1 := FPoints[I];
      NearestP2 := FPoints[I + 1];

      // Calculate the closest point on the line segment to the mouse position
      var DX := P2.X - P1.X;
      var DY := P2.Y - P1.Y;
      var LineLenSquared := DX * DX + DY * DY;
      T := ((MousePos.X - P1.X) * DX + (MousePos.Y - P1.Y) * DY) / LineLenSquared;
      if T < 0 then T := 0;
      if T > 1 then T := 1;

      // Create the new point exactly on the line
      var NewPoint: TPlotPoint;
      NewPoint.Hour := NearestP1.Hour + T * (NearestP2.Hour - NearestP1.Hour);
      NewPoint.Perc := NearestP1.Perc + T * (NearestP2.Perc - NearestP1.Perc);

      InsertIndex := I + 1;
      SetLength(FPoints, Length(FPoints) + 1);
      for var J := Length(FPoints) - 1 downto InsertIndex + 1 do
        FPoints[J] := FPoints[J - 1];
      FPoints[InsertIndex] := NewPoint;
      C.Invalidate;
      Exit;
    end;
  end;
end;

function TfrmChart.ChartRect: TRect;
begin
  Result:= C.ClientRect;
  Result.Left:= 30;
  Result.Right:= Result.Right - 12;
  Result.Top:= 12;
  Result.Bottom:= Result.Bottom - 30;
end;

procedure TfrmChart.CMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if HoveringIndex <> -1 then
  begin
    DraggingIndex := HoveringIndex;
    Dragging := True;
    if (DraggingIndex = 0) or (DraggingIndex = Length(FPoints) - 1) then
    begin
      // Allow vertical movement only for the first and last points
      DraggingVertical := True;
    end
    else
    begin
      DraggingVertical := False;
    end;
  end;
end;

procedure TfrmChart.CMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Dragging then
  begin
    Dragging := False;
    DraggingIndex := -1;
    Self.SavePlotPointsToRegistry;
  end;
end;

function TfrmChart.PlotPointToPoint(P: TPlotPoint): TPoint;
var
  R: TRect;
  XRatio, YRatio: Single;
begin
  R := ChartRect;

  // Calculate the ratios
  XRatio := (R.Right - R.Left) / 24;  // 24 hours in a day
  YRatio := (R.Bottom - R.Top) / 100; // Percentage from 0 to 100

  // Translate coordinates
  Result.X := Round(R.Left + P.Hour * XRatio);
  Result.Y := Round(R.Bottom - P.Perc * YRatio); // Y-axis is typically inverted
end;

function TfrmChart.PointToPlotPoint(P: TPoint): TPlotPoint;
var
  R: TRect;
  XRatio, YRatio: Single;
begin
  R := ChartRect;

  // Calculate the ratios
  XRatio := (R.Right - R.Left) / 24; // 24 hours in a day
  YRatio := (R.Bottom - R.Top) / 100; // Percentage from 0 to 100

  // Translate coordinates
  Result.Hour := (P.X - R.Left) / XRatio;
  Result.Perc := (R.Bottom - P.Y) / YRatio; // Y-axis is typically inverted
end;

procedure TfrmChart.CMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  R: TRect;
  HoverPoint: TPoint;
  Dist, MinDist: Single;
  NearestP1, NearestP2: TPlotPoint;
  GhostFound, NearPoint: Boolean;
begin
  R := ChartRect;
  GhostFound := False;
  NearPoint := False;
  MinDist := 10; // Threshold distance to detect proximity to a line

  HoveringIndex := -1;
  for var I := 0 to Length(FPoints) - 1 do
  begin
    var P := PlotPointToPoint(FPoints[I]);
    if (Abs(P.X - X) <= 4) and (Abs(P.Y - Y) <= 4) then
    begin
      HoveringIndex := I;
      NearPoint := True;
      Break;
    end;
  end;

  // Update StatusBar with hovered time and percentage or clear if outside
  if PtInRect(R, Point(X, Y)) or Dragging then
  begin
    if Dragging and (DraggingIndex <> -1) then
    begin
      var NewPoint := PointToPlotPoint(Point(X, Y));

      // Clamp to chart area
      if NewPoint.Perc < 0 then
        NewPoint.Perc := 0;
      if NewPoint.Perc > 100 then
        NewPoint.Perc := 100;

      if not DraggingVertical then
      begin
        if NewPoint.Hour < 0 then
          NewPoint.Hour := 0;
        if NewPoint.Hour > 24 then
          NewPoint.Hour := 24;

        // Prevent dragging past neighboring points
        if (DraggingIndex > 0) and (NewPoint.Hour <= FPoints[DraggingIndex - 1].Hour) then
          NewPoint.Hour := FPoints[DraggingIndex - 1].Hour + 0.01; // Small increment to prevent overlap
        if (DraggingIndex < Length(FPoints) - 1) and (NewPoint.Hour >= FPoints[DraggingIndex + 1].Hour) then
          NewPoint.Hour := FPoints[DraggingIndex + 1].Hour - 0.01; // Small decrement to prevent overlap

        FPoints[DraggingIndex] := NewPoint;
      end
      else
      begin
        // Adjust only the percentage (vertical position)
        FPoints[DraggingIndex].Perc := NewPoint.Perc;

        // Move the other fixed point if dragging the first or last point
        if DraggingIndex = 0 then
          FPoints[Length(FPoints) - 1].Perc := NewPoint.Perc
        else if DraggingIndex = Length(FPoints) - 1 then
          FPoints[0].Perc := NewPoint.Perc;
      end;

      // Use the new point for status bar update
      HoverPoint := PlotPointToPoint(FPoints[DraggingIndex]);
    end
    else
    begin
      HoverPoint := Point(X, Y);
    end;

    // Ensure valid time before setting to status bar
    var StoppedPoint := PointToPlotPoint(HoverPoint);
    var Hour := Trunc(StoppedPoint.Hour);
    var Minute := Round(Frac(StoppedPoint.Hour) * 60);
    if Hour < 0 then Hour := 0;
    if Hour > 23 then Hour := 23;
    if Minute < 0 then Minute := 0;
    if Minute > 59 then Minute := 59;
    var HoverTime := EncodeTime(Hour, Minute, 0, 0);
    var HoverPerc := GetTimePerc(HoverTime);

    Stat.Panels[0].Text := Format('Time: %s', [TimeToStr(HoverTime)]);
    Stat.Panels[1].Text := Format('Percentage: %.2f%%', [HoverPerc]);

    // Detect if hovering near a line
    for var I := 0 to Length(FPoints) - 2 do
    begin
      var P1 := PlotPointToPoint(FPoints[I]);
      var P2 := PlotPointToPoint(FPoints[I + 1]);

      // Check the proximity to the line segment P1-P2
      var LineDist := PointLineDistance(Point(X, Y), P1, P2);
      if LineDist < MinDist then
      begin
        GhostFound := True;
        NearestP1 := FPoints[I];
        NearestP2 := FPoints[I + 1];

        // Calculate the closest point on the line segment to the mouse position
        var DX := P2.X - P1.X;
        var DY := P2.Y - P1.Y;
        var LineLenSquared := DX * DX + DY * DY;
        var T := ((X - P1.X) * DX + (Y - P1.Y) * DY) / LineLenSquared;
        if T < 0 then T := 0;
        if T > 1 then T := 1;

        GhostPlotPoint.Hour := NearestP1.Hour + T * (NearestP2.Hour - NearestP1.Hour);
        GhostPlotPoint.Perc := NearestP1.Perc + T * (NearestP2.Perc - NearestP1.Perc);
        Break;
      end;
    end;

    if not NearPoint then
    begin
      if not GhostFound then
      begin
        // If not snapping to a line, place ghost point directly under the mouse cursor
        GhostPlotPoint := PointToPlotPoint(Point(X, Y));
        GhostFound := True;
      end;
    end
    else
    begin
      GhostFound := False;
    end;

    GhostPointVisible := GhostFound;
  end
  else
  begin
    Stat.Panels[0].Text := '';
    Stat.Panels[1].Text := '';
    GhostPointVisible := False;
  end;

  C.Invalidate;
end;

procedure TfrmChart.CPaint(Sender: TObject);
var
  W, H: Single;

  procedure Line(P1, P2: TPoint; AColor: TColor; AWidth: Integer = 1);
  begin
    Buffer.Canvas.Brush.Style := bsClear;
    Buffer.Canvas.Pen.Style := psSolid;
    Buffer.Canvas.Pen.Color := AColor;
    Buffer.Canvas.Pen.Width := AWidth;
    Buffer.Canvas.MoveTo(P1.X, P1.Y);
    Buffer.Canvas.LineTo(P2.X, P2.Y);
  end;

  procedure DrawVerticalGridLines;
  var
    LabelFreq: Integer;
  begin
    W := (ChartRect.Right - ChartRect.Left) / 24; // Divide by 24 hours
    LabelFreq := 1; // Default frequency for labels
    if W < 20 then
      LabelFreq := 4 // If too small, label every 4 hours
    else if W < 40 then
      LabelFreq := 2; // If small, label every 2 hours

    Buffer.Canvas.Pen.Color:= GridLineColor;
    for var X: Integer := 0 to 24 do begin
      var P1 := Point(ChartRect.Left + Round(X * W), ChartRect.Top);
      var P2 := Point(P1.X, ChartRect.Bottom);
      Buffer.Canvas.Brush.Style := bsClear;
      Line(P1, P2, GridLineColor);
      if (X mod LabelFreq = 0) and (X <> 0) and (X <> 24) then begin
        Buffer.Canvas.Font.Color := clWhite;
        Buffer.Canvas.TextOut(P1.X + 2, ChartRect.Bottom - 15, Format('%d %s', [IfThen(X > 12, X - 12, X), IfThen(X < 12, 'AM', 'PM')])); // AM/PM format without minutes
      end;
    end;
  end;

  procedure DrawHorizontalGridLines;
  var
    LabelFreq: Integer;
  begin
    H := (ChartRect.Bottom - ChartRect.Top) / 10; // Divide by 10 (10% intervals)
    LabelFreq := 1; // Default frequency for labels
    if H < 10 then
      LabelFreq := 10; // If too small, label every 10%

    Buffer.Canvas.Pen.Color:= GridLineColor;
    for var Y: Integer := 0 to 10 do begin
      var P1 := Point(ChartRect.Left, ChartRect.Bottom - Round(Y * H));
      var P2 := Point(ChartRect.Right, P1.Y);
      Line(P1, P2, GridLineColor);
      if (Y mod LabelFreq = 0) and (Y <> 0) and (Y <> 10) then begin
        Buffer.Canvas.Font.Color := clWhite;
        Buffer.Canvas.TextOut(ChartRect.Left + 5, P1.Y - 10, Format('%d%%', [Y * 10]));
      end;
    end;
  end;

  procedure DrawLines(AColor: TColor; AWidth: Integer);
  begin
    Buffer.Canvas.Brush.Style := bsClear;
    for var X: Integer := 0 to Length(FPoints) - 2 do begin
      var P1 := PlotPointToPoint(FPoints[X]);
      var P2 := PlotPointToPoint(FPoints[X + 1]);
      Line(P1, P2, AColor, AWidth);
    end;
  end;

  procedure DrawPoints;
  begin
    for var X: Integer := 0 to Length(FPoints) - 1 do begin
      var P := PlotPointToPoint(FPoints[X]);
      if (HoveringIndex = X) then
        Buffer.Canvas.Brush.Color := clRed // Entire point red when hovering
      else
        Buffer.Canvas.Brush.Color := clLime;
      Buffer.Canvas.Brush.Style := bsSolid;
      Buffer.Canvas.Pen.Color := Buffer.Canvas.Brush.Color; // Ensure the outline matches the fill color
      Buffer.Canvas.Ellipse(P.X - 4, P.Y - 4, P.X + 4, P.Y + 4);
    end;
  end;

  function GetPolyUnderLine(P1, P2: TPoint): TArray<TPoint>;
  begin
    SetLength(Result, 4);
    Result[0] := Point(P1.X, P1.Y);
    Result[1] := Point(P2.X, P2.Y);
    Result[2] := Point(P2.X, ChartRect.Bottom);
    Result[3] := Point(P1.X, ChartRect.Bottom);
  end;

  procedure DrawAccentColor(AColor: TColor);
  begin
    // Draw Plot Lines Only
    DrawLines(clGray, 2);

    // Flood Fill Beneath the Plotted Lines
    Buffer.Canvas.Brush.Color := AColor;
    Buffer.Canvas.Pen.Color:= AColor;
    Buffer.Canvas.Brush.Style := bsSolid;
    for var I: Integer := 0 to Length(FPoints) - 2 do begin
      var P1 := PlotPointToPoint(FPoints[I]);
      var P2 := PlotPointToPoint(FPoints[I + 1]);
      // Draw a polygonal shape for each segment
      {
      var Points: TArray<TPoint>;
      SetLength(Points, 4);
      Points[0] := Point(P1.X, P1.Y);
      Points[1] := Point(P2.X, P2.Y);
      Points[2] := Point(P2.X, ChartRect.Bottom);
      Points[3] := Point(P1.X, ChartRect.Bottom);
      }
      Buffer.Canvas.Polygon(GetPolyUnderLine(P1, P2));
    end;
  end;
begin

  // Draw Background
  Buffer.Canvas.Brush.Style := bsSolid;
  Buffer.Canvas.Brush.Color := clBlack;
  Buffer.Canvas.Pen.Style := psClear;
  Buffer.Canvas.FillRect(C.ClientRect);

  // Draw color beneath plotted line
  DrawAccentColor(AccentColor);

  // Draw Grid Lines
  DrawVerticalGridLines;
  DrawHorizontalGridLines;

  // Draw Left Axis
  var P1 := Point(ChartRect.Left, ChartRect.Top);
  var P2 := Point(ChartRect.Left, ChartRect.Bottom);
  Line(P1, P2, clGray, 3); // Medium gray axis

  // Draw Bottom Axis
  P1 := Point(ChartRect.Left, ChartRect.Bottom);
  P2 := Point(ChartRect.Right, ChartRect.Bottom);
  Line(P1, P2, clGray, 3); // Medium gray axis

  // Draw Line(s) and Points
  DrawLines(clLime, 3);
  DrawPoints;

  // Draw Ghost Point if visible
  if GhostPointVisible then
  begin
    var GP := PlotPointToPoint(GhostPlotPoint);
    Buffer.Canvas.Brush.Color := clAqua; // Ghost point color
    Buffer.Canvas.Brush.Style := bsSolid;
    Buffer.Canvas.Pen.Color := Buffer.Canvas.Brush.Color;
    Buffer.Canvas.Ellipse(GP.X - 4, GP.Y - 4, GP.X + 4, GP.Y + 4);
  end;

  // Copy the buffer to the PaintBox canvas
  C.Canvas.Draw(0, 0, Buffer);
end;

function TfrmChart.GetTimePerc(ATime: TTime): Single;
var
  TargetHour: Single;
  I: Integer;
  P1, P2: TPlotPoint;
  HourDiff, PercDiff: Single;
begin
  // Convert the time to an hour value (0-24 range)
  TargetHour := HourOf(ATime) + (MinuteOf(ATime) / 60) + (SecondOf(ATime) / 3600);

  // Find the interval that contains TargetHour
  for I := 0 to Length(FPoints) - 2 do
  begin
    if (FPoints[I].Hour <= TargetHour) and (TargetHour <= FPoints[I + 1].Hour) then
    begin
      P1 := FPoints[I];
      P2 := FPoints[I + 1];

      // Calculate the percentage value using linear interpolation
      HourDiff := P2.Hour - P1.Hour;
      if HourDiff = 0 then
        Exit(P1.Perc); // Avoid division by zero

      PercDiff := P2.Perc - P1.Perc;
      Result := P1.Perc + ((TargetHour - P1.Hour) / HourDiff) * PercDiff;
      Exit;
    end;
  end;

  // If TargetHour is not within the range of FPoints, return 0 or a default value
  Result := 0;
end;

procedure TfrmChart.SavePlotPointsToRegistry;
var
  Reg: TRegistry;
  Buffer: TMemoryStream;
  DataSize: Integer;
begin
  Reg := TRegistry.Create(KEY_WRITE);
  Buffer := TMemoryStream.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;

    if Reg.OpenKey(SETTINGS_KEY, True) then begin
      // Serialize the array of TPlotPoint to a memory stream
      Buffer.WriteData(FPoints, Length(FPoints) * SizeOf(TPlotPoint));
      Buffer.Position := 0;

      // Write the memory stream to the registry as binary data
      DataSize := Buffer.Size;
      Reg.WriteBinaryData('PlotPoints', Buffer.Memory^, DataSize);
      Reg.CloseKey;
    end;
  finally
    Buffer.Free;
    Reg.Free;
  end;
end;

function TfrmChart.LoadPlotPointsFromRegistry: Boolean;
var
  Reg: TRegistry;
  Buffer: TMemoryStream;
  DataSize: Integer;
begin
  Result:= False;
  Reg := TRegistry.Create(KEY_READ);
  Buffer := TMemoryStream.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;

    if Reg.OpenKey(SETTINGS_KEY, False) then begin
      // Get the size of the binary data
      DataSize := Reg.GetDataSize('PlotPoints');
      if DataSize > 0 then begin
        // Read the binary data from the registry
        Buffer.SetSize(DataSize);
        Reg.ReadBinaryData('PlotPoints', Buffer.Memory^, DataSize);
        Buffer.Position := 0;

        // Deserialize the data back into the array of TPlotPoint
        SetLength(FPoints, DataSize div SizeOf(TPlotPoint));
        Buffer.ReadData(FPoints, DataSize);
        Result:= True;
      end;
      Reg.CloseKey;
    end;
  finally
    Buffer.Free;
    Reg.Free;
  end;
  C.Invalidate;
end;

end.
