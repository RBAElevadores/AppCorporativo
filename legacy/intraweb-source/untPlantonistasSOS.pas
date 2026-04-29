unit untPlantonistasSOS;

interface

uses
  Classes, SysUtils, IWAppForm, IWApplication, IWColor, IWTypes,
  IWBaseComponent, IWBaseHTMLComponent, IWBaseHTML40Component, IWCompExtCtrls,
  Vcl.Controls, IWVCLBaseControl, IWBaseControl, IWBaseHTMLControl, IWControl,
  IWCompButton, IWVCLComponent, IWBaseLayoutComponent, IWBaseContainerLayout,
  IWContainerLayout, IWTemplateProcessorHTML;

type
  TIWFormPlantonistasSOS = class(TIWAppForm)
    IWTemplateProcessorHTML1: TIWTemplateProcessorHTML;
    btnVoltar: TIWButton;
    timerCarregar: TIWTimer;
    procedure btnVoltarAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure IWAppFormShow(Sender: TObject);
    procedure timerCarregarAsyncTimer(Sender: TObject;
      EventParams: TStringList);
  public
    procedure Start;
  end;

implementation
uses ServerController;

{$R *.dfm}


procedure TIWFormPlantonistasSOS.btnVoltarAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  UserSession.AbreForm('TIWformMain');

  release;
end;

procedure TIWFormPlantonistasSOS.IWAppFormShow(Sender: TObject);
begin
  Start;
end;

procedure TIWFormPlantonistasSOS.Start;
begin
  timerCarregar.Enabled := false;
  timerCarregar.Enabled := true;
end;

procedure TIWFormPlantonistasSOS.timerCarregarAsyncTimer(Sender: TObject;
  EventParams: TStringList);
var SQL : String;
    Ret : String;
begin
  timerCarregar.Enabled := false;

  try

    SQL := ' exec SmartBox.USP_HTMLTecnicoOnlinePlantonistasSOS ';

    Ret := UserSession.RetornaSQL( SQL );

    Sleep(1000);

    WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(Ret);

  except
  end;
end;

end.
