unit untClientes;

interface

uses
  Classes, SysUtils, IWAppForm, IWApplication, IWColor, IWTypes, Vcl.Controls,
  IWVCLBaseControl, IWBaseControl, IWBaseHTMLControl, IWControl, IWCompButton,
  IWVCLComponent, IWBaseLayoutComponent, IWBaseContainerLayout,
  IWContainerLayout, IWTemplateProcessorHTML, IWBaseComponent,
  IWBaseHTMLComponent, IWBaseHTML40Component, IWCompExtCtrls, IWCompEdit,
  IWHTMLTag;

type
  TIWformClientes = class(TIWAppForm)
    IWTemplateProcessorHTML1: TIWTemplateProcessorHTML;
    btnVoltar: TIWButton;
    timerCarregaHtml: TIWTimer;
    edtObra: TIWEdit;
    edtNome: TIWEdit;
    edtApelidoObra: TIWEdit;
    btnPesquisar: TIWButton;
    edtCidade: TIWEdit;
    edtVisualizar: TIWEdit;
    btnVisualizar: TIWButton;
    edtMinhaTela: TIWEdit;
    btnMinhaTela: TIWButton;
    edtPesquisarFicha: TIWEdit;
    edtCamposCalculados: TIWEdit;
    procedure IWAppFormRender(Sender: TObject);
    procedure IWAppFormShow(Sender: TObject);
    procedure btnVoltarAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure timerCarregaHtmlAsyncTimer(Sender: TObject;
      EventParams: TStringList);
    procedure btnPesquisarAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure edtNomeHTMLTag(ASender: TObject; ATag: TIWHTMLTag);
    procedure edtObraHTMLTag(ASender: TObject; ATag: TIWHTMLTag);
    procedure edtApelidoObraHTMLTag(ASender: TObject; ATag: TIWHTMLTag);
    procedure edtCidadeHTMLTag(ASender: TObject; ATag: TIWHTMLTag);
    procedure btnVisualizarAsyncClick(Sender: TObject;
      EventParams: TStringList);
    procedure edtNomeAsyncKeyPress(Sender: TObject; EventParams: TStringList);
    procedure btnMinhaTelaAsyncClick(Sender: TObject; EventParams: TStringList);
  public
    Nome_CarregaHtml : String;
    HTML_CarregaHtml : String;

    procedure Abrindo;
  end;

implementation
Uses ServerController;

{$R *.dfm}


procedure TIWformClientes.Abrindo;
begin
  //123
end;

procedure TIWformClientes.btnMinhaTelaAsyncClick(Sender: TObject;
  EventParams: TStringList);
var SQL  : String;
    HTML : String;
begin
  if Trim(edtMinhaTela.Text) = '' then
    Exit;

  try
    SQL := ' exec SmartBox.USP_HTMLTecnicoOnlineClientesMinhaTela 0'+TRIM(edtMinhaTela.Text)+', 0'+
        IntToStR(UserSession.CodUsuario)+', '''+
        Trim(edtPesquisarFicha.Text)+''', 0'+Trim(edtCamposCalculados.Text);

    HTML := UserSession.RetornaSQL(SQL);

    WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(HTML);
  except
  end;
end;

procedure TIWformClientes.btnPesquisarAsyncClick(Sender: TObject;
  EventParams: TStringList);
var SQL  : String;
    HTML : String;
begin
  if (TRIM(edtNome.Text) = '') and (Trim(edtObra.Text) = '') and (Trim(edtApelidoObra.Text) = '')
      and (TRIM(edtCidade.Text) = '') then
  begin
    WebApplication.ShowNotification('Preencha alguma informação antes de pesquisar!',TIWNotifyType.ntLog);
    Exit;
  end;

  SQL := ' exec SmartBox.[USP_HTMLTecnicoOnlineClientes] '''+TRIM(edtNome.Text)+''', 0'+TRIM(edtObra.Text)+', '''+
              Trim(edtApelidoObra.Text)+''', '''+TRIM(edtCidade.Text)+''', 0'+IntToStr(UserSession.CodUsuario);
  HTML := UserSession.RetornaSQL(SQL);

  Sleep(1000);

  WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(HTML);
end;

procedure TIWformClientes.btnVisualizarAsyncClick(Sender: TObject;
  EventParams: TStringList);
var HTML : String;
begin
  if Trim(edtVisualizar.Text) = '' then
    Exit;

  try
    HTML := UserSession.RetornaSQL(' exec [SmartBox].[USP_HTMLTecnicoOnlineClientesInformacoes] 0'+Trim(edtVisualizar.Text));

    WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(HTML);
  except
    WebApplication.ShowNotification('Houve algum problema ao carregar as informações! Tente novamente.',TIWNotifyType.ntError);
  end;
end;

procedure TIWformClientes.btnVoltarAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  UserSession.AbreForm('TIWformMain');

  release;
end;

procedure TIWformClientes.edtApelidoObraHTMLTag(ASender: TObject;
  ATag: TIWHTMLTag);
begin
  ATag.AddStringParam('placeholder','Apelido da Obra');
end;

procedure TIWformClientes.edtCidadeHTMLTag(ASender: TObject; ATag: TIWHTMLTag);
begin
  ATag.AddStringParam('placeholder','Cidade');
end;

procedure TIWformClientes.edtNomeAsyncKeyPress(Sender: TObject;
  EventParams: TStringList);
begin
  if EventParams.Values['which'] = '13' then
    WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA('pesquisar();');
end;

procedure TIWformClientes.edtNomeHTMLTag(ASender: TObject; ATag: TIWHTMLTag);
begin
  ATag.AddStringParam('placeholder','Nome');
end;

procedure TIWformClientes.edtObraHTMLTag(ASender: TObject; ATag: TIWHTMLTag);
begin
  ATag.AddStringParam('placeholder','Obra');
end;

procedure TIWformClientes.IWAppFormRender(Sender: TObject);
begin
  Abrindo;
end;

procedure TIWformClientes.IWAppFormShow(Sender: TObject);
begin
  Abrindo;
end;

procedure TIWformClientes.timerCarregaHtmlAsyncTimer(Sender: TObject;
  EventParams: TStringList);
begin
  timerCarregaHtml.Enabled := false;

  WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA('carregaHtmls("'+Nome_CarregaHtml+'",'''+HTML_CarregaHtml+''');');
end;

end.
