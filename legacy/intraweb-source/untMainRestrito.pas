unit untMainRestrito;

interface

uses
  Classes, SysUtils, IWAppForm, IWApplication, IWColor, IWTypes,
  IWBaseComponent, IWBaseHTMLComponent, IWBaseHTML40Component, IWCompExtCtrls,
  Vcl.Controls, IWVCLBaseControl, IWBaseControl, IWBaseHTMLControl, IWControl,
  IWCompButton, IWVCLComponent, IWBaseLayoutComponent, IWBaseContainerLayout,
  IWContainerLayout, IWTemplateProcessorHTML;

type
  TIWformMainRestrito = class(TIWAppForm)
    IWTemplateProcessorHTML1: TIWTemplateProcessorHTML;
    btnSair: TIWButton;
    timerCarregaHtml: TIWTimer;
    procedure btnSairAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure timerCarregaHtmlAsyncTimer(Sender: TObject;
      EventParams: TStringList);
    procedure IWAppFormRender(Sender: TObject);
    procedure IWAppFormShow(Sender: TObject);
  public
    Nome_CarregaHtml : String;
    HTML_CarregaHtml : String;

    procedure Abrindo;
  end;

implementation
Uses ServerController;

{$R *.dfm}


procedure TIWformMainRestrito.Abrindo;
begin
  //123
end;

procedure TIWformMainRestrito.btnSairAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  UserSession.AbreForm('TIWformLogin');

  Release;
end;

procedure TIWformMainRestrito.IWAppFormRender(Sender: TObject);
begin
  Abrindo;
end;

procedure TIWformMainRestrito.IWAppFormShow(Sender: TObject);
begin
  Abrindo;
end;

procedure TIWformMainRestrito.timerCarregaHtmlAsyncTimer(Sender: TObject;
  EventParams: TStringList);
begin
  timerCarregaHtml.Enabled := false;

  WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA('carregaHtmls("'+Nome_CarregaHtml+'",'''+HTML_CarregaHtml+''');');
end;

end.
