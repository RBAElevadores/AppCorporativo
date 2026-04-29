unit untNotificacoes;

interface

uses
  Classes, SysUtils, IWAppForm, IWApplication, IWColor, IWTypes,
  IWBaseComponent, IWBaseHTMLComponent, IWBaseHTML40Component, IWCompExtCtrls,
  Vcl.Controls, IWVCLBaseControl, IWBaseControl, IWBaseHTMLControl, IWControl,
  IWCompButton, IWVCLComponent, IWBaseLayoutComponent, IWBaseContainerLayout,
  IWContainerLayout, IWTemplateProcessorHTML, IWHTMLTag, IWCompEdit;

type
  TIWFormNotificacoes = class(TIWAppForm)
    IWTemplateProcessorHTML1: TIWTemplateProcessorHTML;
    btnVoltar: TIWButton;
    timerShow: TIWTimer;
    edtTitulo: TIWEdit;
    edtMensagem: TIWEdit;
    edtUsuario: TIWEdit;
    btnSalvarNotificacao: TIWButton;
    edtPesquisar: TIWEdit;
    btnPesquisar: TIWButton;
    procedure btnVoltarAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure IWAppFormShow(Sender: TObject);
    procedure timerShowAsyncTimer(Sender: TObject; EventParams: TStringList);
    procedure edtTituloHTMLTag(ASender: TObject; ATag: TIWHTMLTag);
    procedure edtMensagemHTMLTag(ASender: TObject; ATag: TIWHTMLTag);
    procedure btnSalvarNotificacaoAsyncClick(Sender: TObject;
      EventParams: TStringList);
    procedure btnPesquisarAsyncClick(Sender: TObject; EventParams: TStringList);
  public
  end;

implementation
uses ServerController;

{$R *.dfm}


procedure TIWFormNotificacoes.btnPesquisarAsyncClick(Sender: TObject;
  EventParams: TStringList);
var SQL  : String;
    HTML : String;
begin
  if (TRIM(edtPesquisar.Text) = '') then
  begin
    WebApplication.ShowNotification('Preencha alguma informação antes de pesquisar!',TIWNotifyType.ntLog);
    Exit;
  end;

  SQL := ' exec SmartBox.[USP_HTMLTecnicoOnlineNotificacoesPesquisa] '''+TRIM(edtPesquisar.Text)+''' ';
  HTML := UserSession.RetornaSQL(SQL);

  Sleep(1000);

  WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(HTML);
end;

procedure TIWFormNotificacoes.btnSalvarNotificacaoAsyncClick(Sender: TObject;
  EventParams: TStringList);
var SQL : String;
    Retorno : String;
begin
  if Trim(edtTitulo.Text) = '' then
  begin
    WebApplication.ShowNotification('Preencha o Título antes de salvar!',TIWNotifyType.ntLog);
    Exit;
  end;

  if Trim(edtMensagem.Text) = '' then
  begin
    WebApplication.ShowNotification('Preencha a Mensagem antes de salvar!',TIWNotifyType.ntLog);
    Exit;
  end;

  if Trim(edtUsuario.Text) = '' then
  begin
    WebApplication.ShowNotification('Escolha o Usuário antes de salvar!',TIWNotifyType.ntLog);
    Exit;
  end;

  try
    Retorno := '';
    SQL     := ' exec SmartBox.USP_CorporativoLancarNotificacao '''+TRIM(edtTitulo.Text)+
                  ''', '''+Trim(edtMensagem.Text)+''', 0'+Trim(edtUsuario.Text)+', 0'+IntTOStr(UserSession.CodUsuario);
    Retorno := UserSession.RetornaSQL(SQL);

    if TRIM(Retorno) <> '' then
    begin
      WebApplication.ShowNotification(Retorno,TIWNotifyType.ntSuccess);
      WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA('btnFechaModalNotificacao.click();');
    end
    else
      WebApplication.ShowNotification('Houve algum problema ao salvar a notificaçao!',TIWNotifyType.ntError);
  except
    WebApplication.ShowNotification('Houve algum erro ao salvar a notificaçao!',TIWNotifyType.ntError);
  end;
end;

procedure TIWFormNotificacoes.btnVoltarAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  UserSession.AbreForm('TIWformMain');

  release;
end;

procedure TIWFormNotificacoes.edtMensagemHTMLTag(ASender: TObject;
  ATag: TIWHTMLTag);
begin
  ATag.AddStringParam('maxlength','400');
end;

procedure TIWFormNotificacoes.edtTituloHTMLTag(ASender: TObject;
  ATag: TIWHTMLTag);
begin
  ATag.AddStringParam('maxlength','20');
end;

procedure TIWFormNotificacoes.IWAppFormShow(Sender: TObject);
begin
  timerShow.Enabled := true;
end;

procedure TIWFormNotificacoes.timerShowAsyncTimer(Sender: TObject;
  EventParams: TStringList);
var SQL : String;
    Ret : String;
    Ret2 : String;
begin
  timerShow.Enabled := false;

  try
    SQL := ' exec SmartBox.USP_HTMLTecnicoOnlineNotificacoes 0'+IntToStr(UserSession.CodUsuario);

    Ret := UserSession.RetornaSQL( SQL );

    //Sleep(100);

    //Verifica permissão se o usuário pode enviar notificação
    if UserSession.VerPermissao('App Corporativo: Lancar Notificacoes Push','V',false) then
      Ret := Ret + ' document.getElementById("enviarNotificacao").style.display = "block"; '
    else
      Ret := Ret + ' document.getElementById("enviarNotificacao").style.display = "none"; ';


    SQL := ' select ''visualizar("''+isnull(Titulo,'''')+''","''+REPLACE(REPLACE(REPLACE(REPLACE(isnull(Mensagem,''''''''),'''''''',''''),''"'',''''),CHAR(10),''<br>''),CHAR(13),'''')+''");'' Txt '+
           ' from SmartBox.Corporativo_Notificacoes '+
           ' where Seq = 0'+IntToStr(UserSession.IDNotificacao);
    Ret2 := UserSession.RetornaSQL(SQL);

    UserSession.TipoNotificacao := '';
    UserSession.IDNotificacao := 0;

    if Ret2 <> '' then
      Ret := Ret + Ret2;

    WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(Ret);

  except
  end;
end;

end.
