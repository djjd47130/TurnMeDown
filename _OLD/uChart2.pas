unit uChart2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, JD.Ctrls.PlotChart, JD.Common, JD.Ctrls,
  Vcl.ComCtrls, Vcl.ExtCtrls, RzPanel, Vcl.StdCtrls, JD.Ctrls.FontButton;

type
  TfrmChart2 = class(TForm)
    Stat: TStatusBar;
    JDPlotChart1: TJDPlotChart;
    JDFontButton1: TJDFontButton;
    procedure FormCreate(Sender: TObject);
    procedure JDPlotChart1PointAdded(Sender: TObject; P: TJDPlotPoint);
    procedure JDPlotChart1PointDeleted(Sender: TObject; P: TJDPlotPoint);
    procedure JDPlotChart1PointMoved(Sender: TObject; P: TJDPlotPoint);
  private
    { Private declarations }
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    procedure PostLog(const S: String);
  end;

var
  frmChart2: TfrmChart2;

implementation

{$R *.dfm}

procedure TfrmChart2.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.ExStyle:= Params.ExStyle or WS_EX_APPWINDOW;
  Params.WndParent:= GetDesktopWindow;
end;

procedure TfrmChart2.FormCreate(Sender: TObject);
begin
  JDPlotChart1.Align:= alClient;
end;

procedure TfrmChart2.JDPlotChart1PointAdded(Sender: TObject; P: TJDPlotPoint);
begin
  PostLog('Point Added: '+P.DisplayName);
end;

procedure TfrmChart2.JDPlotChart1PointDeleted(Sender: TObject; P: TJDPlotPoint);
begin
  PostLog('Point Deleted: '+P.DisplayName);
end;

procedure TfrmChart2.JDPlotChart1PointMoved(Sender: TObject; P: TJDPlotPoint);
begin
  PostLog('Point Moved: '+P.DisplayName);
end;

procedure TfrmChart2.PostLog(const S: String);
begin
  //
end;

end.
