unit untAbrirSac;

interface

uses
  Classes, SysUtils, IWAppForm, IWApplication, IWColor, IWTypes, IWCompButton,
  IWCompMemo, Vcl.Controls, IWVCLBaseControl, IWBaseControl, IWBaseHTMLControl,
  IWControl, IWVCLComponent, IWBaseLayoutComponent, IWBaseContainerLayout,
  IWContainerLayout, IWTemplateProcessorHTML, IWBaseComponent, IWBaseHTMLComponent,
  IWBaseHTML40Component, IWCompExtCtrls, IWCompEdit, IWHTMLTag;

type
  TIWFormAbrirSac = class(TIWAppForm)
    EdtTitulo: TIWEdit;
    MemDescricao: TIWMemo;
    MemInfo: TIWMemo;
    IWBtnCancel: TIWButton;
    IWBtnConfirma: TIWButton;
    IWTemplateProcessorHTML1: TIWTemplateProcessorHTML;
    timerCarregaHtml: TIWTimer;
    procedure IWBtnCancelAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure timerCarregaHtmlAsyncTimer(Sender: TObject;
      EventParams: TStringList);
    procedure IWAppFormShow(Sender: TObject);
    procedure IWAppFormRender(Sender: TObject);
    procedure IWBtnConfirmaAsyncClick(Sender: TObject;
      EventParams: TStringList);
  public
    Nome_CarregaHtml : String;
    HTML_CarregaHtml : String;

    procedure Abrindo;
  end;

implementation
  Uses ServerController;
{$R *.dfm}


procedure TIWformAbrirSac.Abrindo;
begin
  //123
end;

procedure TIWFormAbrirSac.IWAppFormRender(Sender: TObject);
begin
  Abrindo;
end;

procedure TIWFormAbrirSac.IWAppFormShow(Sender: TObject);
begin
  Abrindo;
end;

procedure TIWFormAbrirSac.IWBtnCancelAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  UserSession.AbreForm('TIWformMain');

  release;
end;

procedure TIWFormAbrirSac.IWBtnConfirmaAsyncClick(Sender: TObject;
  EventParams: TStringList);
  var SQL : string;
begin

  if trim(EdtTitulo.Text) = '' then
  begin
     WebApplication.ShowNotification('Por favor preencha o Título.');
     exit;
  end
  else if trim(MemDescricao.Text) = '' then
  begin
     WebApplication.ShowNotification('Por favor preencha a Descrição.');
     exit;
  end
  else if trim(MemInfo.Text) = '' then
  begin
     WebApplication.ShowNotification('Por favor preencha as Informações.');
     exit;
  end
  else if Trim(EdtTitulo.Text).Length > 200 then
  begin
     WebApplication.ShowNotification('Por favor insira um título menor. Maximo(200), Atual('+IntToStr(Trim(EdtTitulo.Text).Length)+').');
     exit;
  end
  else if trim(MemDescricao.Text).Length = 500 then
  begin
     WebApplication.ShowNotification('Por favor insira uma descrição menor. Maximo(500), Atual('+IntToStr(Trim(MemDescricao.Text).Length)+').');
     exit;
  end;

  SQL := 'insert into PendenciasGeral (DtInsert, Titulo, Descricao, Informacoes, Prazo, Tipo, TipoOrigem, UsuInsert) ' +
         'values (CAST(GETDATE() as date), ' + QuotedStr(Trim(EdtTitulo.Text)) + ', ' + QuotedStr(Trim(MemDescricao.Text)) + ', ' + QuotedStr(Trim(MemInfo.Text)) + ', CAST((GETDATE() + 7) as date), ''SAC'', ''Manual'', ' + IntToStr(UserSession.CodUsuario) + ')';

  UserSession.RetornaSQL(SQL);

  UserSession.AbreForm('TIWformMain');

  release;

  WebApplication.ShowNotification('SAC Aberto!', ntSuccess);
end;

procedure TIWFormAbrirSac.timerCarregaHtmlAsyncTimer(Sender: TObject;
  EventParams: TStringList);
begin
  timerCarregaHtml.Enabled := false;

  WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA('carregaHtmls("'+Nome_CarregaHtml+'",'''+HTML_CarregaHtml+''');');
end;

end.
