unit untRamais;

interface

uses
  Classes, SysUtils, IWAppForm, IWApplication, IWColor, IWTypes,
  IWBaseComponent, IWBaseHTMLComponent, IWBaseHTML40Component, IWCompExtCtrls,
  Vcl.Controls, IWVCLBaseControl, IWBaseControl, IWBaseHTMLControl, IWControl,
  IWCompButton, IWVCLComponent, IWBaseLayoutComponent, IWBaseContainerLayout,
  IWContainerLayout, IWTemplateProcessorHTML;

type
  TIWformRamais = class(TIWAppForm)
    IWTemplateProcessorHTML1: TIWTemplateProcessorHTML;
    btnVoltar: TIWButton;
    timerShow: TIWTimer;
    procedure btnVoltarAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure IWAppFormShow(Sender: TObject);
    procedure timerShowAsyncTimer(Sender: TObject; EventParams: TStringList);
  public
  end;

implementation
uses ServerController;

{$R *.dfm}


procedure TIWformRamais.btnVoltarAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  UserSession.AbreForm('TIWformMain');

  release;
end;

procedure TIWformRamais.IWAppFormShow(Sender: TObject);
begin
  timerShow.Enabled := false;
  timerShow.Enabled := true;
end;

procedure TIWformRamais.timerShowAsyncTimer(Sender: TObject;
  EventParams: TStringList);
var SQL, Ret : String;
begin
  timerShow.Enabled := false;

  try
    SQL := ' exec SmartBox.USP_HTMLTecnicoOnlineRamais ';

    Ret := UserSession.RetornaSQL(SQL);

    WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(Ret);
  except
  end;
end;

end.
