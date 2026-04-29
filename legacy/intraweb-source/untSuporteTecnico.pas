unit untSuporteTecnico;

interface

uses
  Classes, SysUtils, IWAppForm, IWApplication, IWColor, IWTypes, Vcl.Controls,
  IWVCLBaseControl, IWBaseControl, IWBaseHTMLControl, IWControl, IWCompButton,
  IWVCLComponent, IWBaseLayoutComponent, IWBaseContainerLayout,
  IWContainerLayout, IWTemplateProcessorHTML, IWCompEdit, IWBaseComponent,
  IWBaseHTMLComponent, IWBaseHTML40Component, IWCompExtCtrls;

type
  TIWformSuporteTecnico = class(TIWAppForm)
    IWTemplateProcessorHTML1: TIWTemplateProcessorHTML;
    btnVoltar: TIWButton;
    edtPesquisar: TIWEdit;
    btnPesquisar: TIWButton;
    edtOrientacao: TIWEdit;
    btnCarregar: TIWButton;
    timerCarregar: TIWTimer;
    timerShow: TIWTimer;
    procedure btnVoltarAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure edtPesquisarAsyncKeyPress(Sender: TObject;
      EventParams: TStringList);
    procedure btnPesquisarAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure btnCarregarAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure timerCarregarAsyncTimer(Sender: TObject;
      EventParams: TStringList);
    procedure IWAppFormShow(Sender: TObject);
    procedure timerShowAsyncTimer(Sender: TObject; EventParams: TStringList);
  public
  end;

implementation
uses ServerController;

{$R *.dfm}


procedure TIWformSuporteTecnico.btnCarregarAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  timerCarregar.Enabled := true;
end;

procedure TIWformSuporteTecnico.btnPesquisarAsyncClick(Sender: TObject;
  EventParams: TStringList);
var SQL  : String;
    HTML : String;
begin
  if (TRIM(edtPesquisar.Text) = '') then
  begin
    WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(' btnFechaModalMensagem.click(); ');
    WebApplication.ShowNotification('Preencha alguma informação antes de pesquisar!',TIWNotifyType.ntLog);
    Exit;
  end;

  SQL := ' exec SmartBox.USP_HTMLTecnicoOnlineOrientacoesPesquisa '''+TRIM(edtPesquisar.Text)+''' ';
  HTML := UserSession.RetornaSQL(SQL);

  Sleep(1000);

  WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(HTML);
end;

procedure TIWformSuporteTecnico.btnVoltarAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  UserSession.AbreForm('TIWformMain');

  release;
end;

procedure TIWformSuporteTecnico.edtPesquisarAsyncKeyPress(Sender: TObject;
  EventParams: TStringList);
begin
  if EventParams.Values['which'] = '13' then
    WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA('pesquisar();');
end;

procedure TIWformSuporteTecnico.IWAppFormShow(Sender: TObject);
begin
  timerShow.Enabled := true;
end;

procedure TIWformSuporteTecnico.timerCarregarAsyncTimer(Sender: TObject;
  EventParams: TStringList);
var SQL : String;
    Ret : String;
begin
  timerCarregar.Enabled := false;

  try
    SQL := ' exec SmartBox.USP_HTMLTecnicoOnlineOrientacoesCarregar 0'+TRIM(edtOrientacao.Text);
    Ret := UserSession.RetornaSQL(SQL);

    WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(Ret);

  except
  end;
end;

procedure TIWformSuporteTecnico.timerShowAsyncTimer(Sender: TObject;
  EventParams: TStringList);
var SQL  : String;
    HTML : String;
begin
  timerShow.Enabled := false;

  SQL := ' exec SmartBox.USP_HTMLTecnicoOnlineOrientacoesPesquisa '''' ';
  HTML := UserSession.RetornaSQL(SQL);

  Sleep(300);

  WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(HTML);
end;

end.
