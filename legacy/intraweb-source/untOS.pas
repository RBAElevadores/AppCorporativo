unit untOS;

interface

uses
  Classes, SysUtils, IWAppForm, IWApplication, IWColor, IWTypes,
  IWBaseComponent, IWBaseHTMLComponent, IWBaseHTML40Component, IWCompExtCtrls,
  Vcl.Controls, IWVCLBaseControl, IWBaseControl, IWBaseHTMLControl, IWControl,
  IWCompButton, IWVCLComponent, IWBaseLayoutComponent, IWBaseContainerLayout,
  IWContainerLayout, IWTemplateProcessorHTML, IWCompEdit;

type
  TIWformOS = class(TIWAppForm)
    IWTemplateProcessorHTML1: TIWTemplateProcessorHTML;
    btnVoltar: TIWButton;
    timerShow: TIWTimer;
    edtPesquisar: TIWEdit;
    btnPesquisar: TIWButton;
    edtOS: TIWEdit;
    btnOS: TIWButton;
    btnAutorizar: TIWButton;
    procedure btnVoltarAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure btnPesquisarAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure btnOSAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure btnAutorizarAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure IWAppFormShow(Sender: TObject);
    procedure timerShowAsyncTimer(Sender: TObject; EventParams: TStringList);
  public
  end;

implementation
uses ServerController;

{$R *.dfm}


procedure TIWformOS.btnAutorizarAsyncClick(Sender: TObject;
  EventParams: TStringList);
var SQL  : String;
    HTML : String;
begin
  if Trim(edtOS.Text) = '' then
  begin
    WebApplication.ShowNotification('Não foi possível identificar a O.S. para autorizar!',TIWNotifyType.ntLog);
    WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA('btnFechaModalMensagem.click();');
    Exit;
  end;

  try
    SQL := ' exec SmartBox.[USP_HTMLTecnicoOnlineOSAutorizar] '''+TRIM(edtOS.Text)+''' ';
    HTML := UserSession.RetornaSQL(SQL);

    WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(HTML);
  except
  end;
end;

procedure TIWformOS.btnOSAsyncClick(Sender: TObject; EventParams: TStringList);
var SQL  : String;
    HTML : String;
begin
  if Trim(edtOS.Text) = '' then
    Exit;

  try
    SQL := ' exec SmartBox.[USP_HTMLTecnicoOnlineOS] '''+TRIM(edtOS.Text)+''' ';
    HTML := UserSession.RetornaSQL(SQL);

    WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(HTML);
  except
  end;
end;

procedure TIWformOS.btnPesquisarAsyncClick(Sender: TObject;
  EventParams: TStringList);
var SQL  : String;
    HTML : String;
begin
  if (TRIM(edtPesquisar.Text) = '') then
  begin
    WebApplication.ShowNotification('Preencha alguma informação antes de pesquisar!',TIWNotifyType.ntLog);
    WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA('btnFechaModalMensagem.click();');
    Exit;
  end;

  SQL := ' exec SmartBox.[USP_HTMLTecnicoOnlineOSPesquisa] '''+TRIM(edtPesquisar.Text)+''' ';
  HTML := UserSession.RetornaSQL(SQL);

  Sleep(1000);

  WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(HTML);
end;

procedure TIWformOS.btnVoltarAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  UserSession.AbreForm('TIWformMain');

  release;
end;

procedure TIWformOS.IWAppFormShow(Sender: TObject);
begin
  timerShow.Enabled  := false;
  timerShow.Tag      := 0;
  timerShow.Interval := 200;
  timerShow.Enabled  := true;
end;

procedure TIWformOS.timerShowAsyncTimer(Sender: TObject;
  EventParams: TStringList);
var OS  : String;
    SQL : String;
begin
  timerShow.Enabled := false;

  try
    if timerShow.Tag = 0 then
    begin

      OS := '';

      if (UserSession.TipoNotificacao = 'Autorizar OS') and (UserSession.IDNotificacao > 0) then
      begin
        SQL := ' select CodigoVinculoTipo from SmartBox.Corporativo_Notificacoes where Seq = 0'+IntToStr(UserSession.IDNotificacao);
        OS  := UserSession.RetornaSQL(SQL);

        UserSession.TipoNotificacao := '';
        UserSession.IDNotificacao := 0;
      end;

      if OS <> '' then
      begin
        edtOS.Text := OS;
        btnOSAsyncClick(nil,nil);
      end
      else
        WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(' mensagem(''PESQUISANDO...'',''Aguarde, procurando...'',0,0,1); ');

      timerShow.Tag      := 1;
      timerShow.Interval := 1000;
      timerShow.Enabled  := true;
    end
    else
    begin
      //carrega tudo que está pendente
      edtPesquisar.Text := '-1';
      btnPesquisarAsyncClick(nil,nil);
      edtPesquisar.Text := '';
    end;
  except
  end;
end;

end.
