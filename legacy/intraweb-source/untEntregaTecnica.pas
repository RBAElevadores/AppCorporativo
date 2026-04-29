unit untEntregaTecnica;

interface

uses
  Classes, SysUtils, IWAppForm, IWApplication, IWColor, IWTypes, Vcl.Controls,
  IWVCLBaseControl, IWBaseControl, IWBaseHTMLControl, IWControl, IWCompButton,
  IWVCLComponent, IWBaseLayoutComponent, IWBaseContainerLayout,
  IWContainerLayout, IWTemplateProcessorHTML, IWCompEdit, IWHTMLTag,
  IWBaseComponent, IWBaseHTMLComponent, IWBaseHTML40Component, IWCompExtCtrls;

type
  TIWformEntregaTecnica = class(TIWAppForm)
    IWTemplateProcessorHTML1: TIWTemplateProcessorHTML;
    btnVoltar: TIWButton;
    edtPesquisar: TIWEdit;
    btnEquipamento: TIWButton;
    btnPesquisar: TIWButton;
    edtObra: TIWEdit;
    btnCarregar: TIWButton;
    timerCarregar: TIWTimer;
    btnAcessarEntregaTecnica: TIWButton;
    btnEstruturaEntregaTecnica: TIWButton;
    edtAcessarEntregaTecnica: TIWEdit;
    timerShow: TIWTimer;
    procedure btnVoltarAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure edtPesquisarAsyncKeyPress(Sender: TObject;
      EventParams: TStringList);
    procedure edtPesquisarHTMLTag(ASender: TObject; ATag: TIWHTMLTag);
    procedure btnPesquisarAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure btnCarregarAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure timerCarregarAsyncTimer(Sender: TObject;
      EventParams: TStringList);
    procedure btnAcessarEntregaTecnicaAsyncClick(Sender: TObject;
      EventParams: TStringList);
    procedure btnEstruturaEntregaTecnicaAsyncClick(Sender: TObject;
      EventParams: TStringList);
    procedure IWAppFormShow(Sender: TObject);
    procedure timerShowAsyncTimer(Sender: TObject; EventParams: TStringList);
  public
  end;

implementation
uses ServerController;

{$R *.dfm}


procedure TIWformEntregaTecnica.btnAcessarEntregaTecnicaAsyncClick(
  Sender: TObject; EventParams: TStringList);
var SQL, Ret : String;
begin
  if trim(edtObra.Text) = '' then
    Exit;

  try
    //Primeiro giro para carregar cabeçalho
    SQL := ' exec SmartBox.USP_AcessarEntregaTecnica 0'+TRIM(edtObra.Text)+', 0'+IntToStr(UserSession.CodUsuario)+', 0'+TRIM(edtAcessarEntregaTecnica.Text);

    Ret := UserSession.RetornaSQL(SQL);

    WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(Ret);
  except
  end;
end;

procedure TIWformEntregaTecnica.btnCarregarAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  timerCarregar.Enabled := false;
  timerCarregar.Enabled := true;
end;

procedure TIWformEntregaTecnica.btnEstruturaEntregaTecnicaAsyncClick(
  Sender: TObject; EventParams: TStringList);
var SQL : String;
begin
  if trim(edtObra.Text) = '' then
    Exit;

  try
    //Primeiro giro para carregar cabeçalho
    SQL := ' exec WhatsApp.USP_EntregaTecnicaEstrutura 0'+TRIM(edtObra.Text)+', 0'+IntToStr(UserSession.CodUsuario);

    UserSession.ExecutaSQL(SQL);

    WebApplication.ShowNotification('Verifique se recebeu em seu Whatsapp!',TIWNotifyType.ntSuccess);
  except
  end;
end;

procedure TIWformEntregaTecnica.btnPesquisarAsyncClick(Sender: TObject;
  EventParams: TStringList);
var SQL  : String;
    HTML : String;
begin
  if not UserSession.VerPermissao('App Corporativo: Gerencial: Entrega Técnica','V',true) then
    Exit;

  if (TRIM(edtPesquisar.Text) = '') then
  begin
    WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA('btnFechaModalMensagem.click();');
    WebApplication.ShowNotification('Preencha alguma informação antes de pesquisar!',TIWNotifyType.ntLog);
    Exit;
  end;

  SQL := ' exec SmartBox.[USP_HTMLTecnicoOnlineEntregaTecnicaPesquisa] '''+TRIM(edtPesquisar.Text)+''', 0'+IntToStr(UserSession.CodUsuario);
  HTML := UserSession.RetornaSQL(SQL);

  Sleep(1000);

  WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(HTML);
end;

procedure TIWformEntregaTecnica.btnVoltarAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  UserSession.AbreForm('TIWformMain');

  release;
end;

procedure TIWformEntregaTecnica.edtPesquisarAsyncKeyPress(Sender: TObject;
  EventParams: TStringList);
begin
  if EventParams.Values['which'] = '13' then
    WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA('pesquisar();');
end;

procedure TIWformEntregaTecnica.edtPesquisarHTMLTag(ASender: TObject;
  ATag: TIWHTMLTag);
begin
  ATag.AddStringParam('placeholder','Obra, Apelido ou Cliente');
end;

procedure TIWformEntregaTecnica.IWAppFormShow(Sender: TObject);
begin
  timerShow.Enabled := false;
  timerShow.Enabled := True;
end;

procedure TIWformEntregaTecnica.timerCarregarAsyncTimer(Sender: TObject;
  EventParams: TStringList);
var SQL : String;
    Ret : String;
begin
  timerCarregar.Enabled := false;

  try
    //Primeiro giro para carregar cabeçalho
    SQL := ' exec SmartBox.USP_HTMLTecnicoOnlineEntregaTecnicaCarregar 0'+TRIM(edtObra.Text)+', 0'+IntToStr(UserSession.CodUsuario);

    Ret := UserSession.RetornaSQL(SQL);

    WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(Ret);
  except
  end;
end;

procedure TIWformEntregaTecnica.timerShowAsyncTimer(Sender: TObject;
  EventParams: TStringList);
var SQL  : String;
    HTML : String;
begin
  timerShow.Enabled := false;

  //Checa se o usuário é
  SQL := ' select 1 aux from Usuarios '+
         ' where Codigo = 0'+IntToStr(UserSession.CodUsuario)+' and CodCli is null ';

  if UserSession.RetornaSQL(SQL) <> '' then
    HTML := 'erroCadUsuario'
  else
    HTML := 'corpo';

  WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(' document.getElementById("'+HTML+'").style.display = "block"; ')
end;

end.
