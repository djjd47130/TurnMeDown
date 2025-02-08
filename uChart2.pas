unit uChart2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, JD.Ctrls.PlotChart;

type
  TfrmChart2 = class(TForm)
    JDPlotChart1: TJDPlotChart;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmChart2: TfrmChart2;

implementation

{$R *.dfm}

procedure TfrmChart2.FormCreate(Sender: TObject);
begin
  JDPlotChart1.Align:= alClient;
end;

end.
