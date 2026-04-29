unit untFichaTecnica;

interface

uses
  Classes, SysUtils, IWAppForm, IWApplication, IWColor, IWTypes,
  IWBaseComponent, IWBaseHTMLComponent, IWBaseHTML40Component, IWCompExtCtrls,
  Vcl.Controls, IWVCLBaseControl, IWBaseControl, IWBaseHTMLControl, IWControl,
  IWCompButton, IWVCLComponent, IWBaseLayoutComponent, IWBaseContainerLayout,
  IWContainerLayout, IWTemplateProcessorHTML, IWCompEdit, IWCompCheckbox,
  IWHTMLTag, Vcl.ExtCtrls;

type
  TIWFormFichaTecnica = class(TIWAppForm)
    IWTemplateProcessorHTML1: TIWTemplateProcessorHTML;
    btnVoltar: TIWButton;
    timerCarregar: TIWTimer;
    edtPesquisar: TIWEdit;
    btnPesquisar: TIWButton;
    edt90Dias: TIWEdit;
    edtFicha: TIWEdit;
    btnCarregar: TIWButton;
    edtPesquisarFicha: TIWEdit;
    edtCamposCalculados: TIWEdit;
    edtAcrescimoCompensador: TIWEdit;
    btnAcrescimoCompensador: TIWButton;
    btnAcrescimoCompensadorRemover: TIWButton;
    timerOnline: TIWTimer;
    btnLigarOnline: TIWButton;
    btnDesligarOnline: TIWButton;
    btnAutorizar: TIWButton;
    timerShow: TIWTimer;
    procedure btnVoltarAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure timerCarregarAsyncTimer(Sender: TObject;
      EventParams: TStringList);
    procedure btnPesquisarAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure btnCarregarAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure btnAcrescimoCompensadorAsyncClick(Sender: TObject;
      EventParams: TStringList);
    procedure edtAcrescimoCompensadorHTMLTag(ASender: TObject;
      ATag: TIWHTMLTag);
    procedure btnAcrescimoCompensadorRemoverAsyncClick(Sender: TObject;
      EventParams: TStringList);
    procedure timerOnlineAsyncTimer(Sender: TObject; EventParams: TStringList);
    procedure btnLigarOnlineAsyncClick(Sender: TObject;
      EventParams: TStringList);
    procedure btnDesligarOnlineAsyncClick(Sender: TObject;
      EventParams: TStringList);
    procedure btnAutorizarAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure IWAppFormShow(Sender: TObject);
    procedure timerShowAsyncTimer(Sender: TObject; EventParams: TStringList);
  public
  end;

implementation
uses ServerController;

{$R *.dfm}


procedure TIWFormFichaTecnica.btnAcrescimoCompensadorAsyncClick(Sender: TObject;
  EventParams: TStringList);
var SQL  : String;
    HTML : String;
    Ret  : String;

    Acrescimo : Single;
begin
  if Trim(edtAcrescimoCompensador.Text) = '' then
    Exit;

  try
    Acrescimo := StrToFloat( StringReplace( edtAcrescimoCompensador.Text,'.',',', [rfReplaceAll]) );
  except
  end;

  if Acrescimo < 0 then
  begin
    if not UserSession.VerPermissao('Ficha Técnica: Acréscimo Compensador Negativo','V',True) then
      exit;
  end;

  try
    SQL := ' update FichaTecnica.FichasTecnicas set AcrescimoCompensador =  '+ StringReplace( edtAcrescimoCompensador.Text,',','.', [rfReplaceAll]) +
           ' where seq = '+ Trim(edtFicha.Text)+
           ' exec [FichaTecnica].[USP_Calcular] '+ Trim(edtFicha.Text);

    Ret := UserSession.RetornaSQL(SQL);

    if TRIM(ret) <> '' then
      HTML := ' mensagem(''Erro ao calcular a Ficha'','''+Trim(Ret)+''',0,1,0); '
    else
      HTML := ' btnFechaModalMensagem.click(); filtrarFicha(); ';
  except
    HTML := ' mensagem("Erro!"," <div class=''row''> <div class=''col'' align=''center''> Houve algum problema ao salvar o Acréscimo Compensador! Tente novamente, se o erro persistir procure o T.I. ",5,1,0); ';
  end;

  WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(HTML);
end;

procedure TIWFormFichaTecnica.btnAcrescimoCompensadorRemoverAsyncClick(
  Sender: TObject; EventParams: TStringList);
var SQL : String;
    Ret : String;

    HTML : String;
begin
  try
    SQL := ' update FichaTecnica.FichasTecnicas set AcrescimoCompensador = null '+
           ' where seq = '+ Trim(edtFicha.Text)+
           ' exec [FichaTecnica].[USP_Calcular] '+ Trim(edtFicha.Text);

    Ret := UserSession.RetornaSQL(SQL);

    if TRIM(ret) <> '' then
      HTML := ' mensagem(''Erro ao calcular a Ficha'','''+Trim(Ret)+''',0,1,0); '
    else
      HTML := ' btnFechaModalMensagem.click(); filtrarFicha(); ';
  except
    HTML := ' mensagem("Erro!"," <div class=''row''> <div class=''col'' align=''center''> Houve algum problema ao remover o Acréscimo Compensador! Tente novamente, se o erro persistir procure o T.I. ",5,1,0); ';
  end;

  WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(HTML);
end;

procedure TIWFormFichaTecnica.btnAutorizarAsyncClick(Sender: TObject;
  EventParams: TStringList);
var HTML : String;
    SQL  : String;
    Ret  : String;
begin

  try
    SQL := ' exec [FichaTecnica].[USP_Calcular] '+ Trim(edtFicha.Text);

    Ret := UserSession.RetornaSQL(SQL);

    if TRIM(ret) <> '' then
    begin
      HTML := ' mensagem(''Erro ao calcular a Ficha para Autorização'','''+Trim(Ret)+''',0,1,0); ';

      WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(HTML);
    end
    else
    begin

      UserSession.qryAux.Close;
      UserSession.qryAux.SQL.Clear;
      UserSession.qryAux.SQL.Add(' exec FichaTecnica.USP_Autorizar :Seq, :CodUsuario');
      UserSession.qryAux.ParamByName('Seq').AsString         := edtFicha.Text;
      UserSession.qryAux.ParamByName('CodUsuario').AsInteger := UserSession.CodUsuario;
      UserSession.qryAux.Open;

      if UserSession.qryAux.IsEmpty then
        WebApplication.ShowNotification('Houve algum problema ao autorizar a Ficha! Tente novamente, se o erro persistir informe ao T.I.',TIWNotifyType.ntError)
      else
      begin

        if UserSession.qryAux.Fields[0].AsString <> '' then
        begin
          WebApplication.ShowNotification(UserSession.qryAux.Fields[0].AsString,TIWNotifyType.ntError);
          Exit;
        end
        else
        begin
          WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(UserSession.qryAux.Fields[1].AsString);
          WebApplication.ShowNotification('Ficha autorizada!',TIWNotifyType.ntSuccess);
        end;
      end;

    end;
  except
    WebApplication.ShowNotification('Houve algum erro ao autorizar a Ficha! Tente novamente, se o erro persistir informe ao T.I.',TIWNotifyType.ntError);
  end;

end;

procedure TIWFormFichaTecnica.btnCarregarAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  if Trim(edtFicha.Text) = '' then
    Exit;

  timerCarregar.Tag     := 0;
  timerCarregar.Enabled := true;
end;

procedure TIWFormFichaTecnica.btnDesligarOnlineAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
    timerOnline.Enabled := false;
end;

procedure TIWFormFichaTecnica.btnLigarOnlineAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  timerOnline.Enabled := true;
end;

procedure TIWFormFichaTecnica.btnPesquisarAsyncClick(Sender: TObject;
  EventParams: TStringList);
var SQL  : String;
    HTML : String;
begin
  if (TRIM(edtPesquisar.Text) = '') then
  begin
    WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(
            'mensagem("PESQUISA...", "Preencha alguma informação antes de pesquisar!",10000,1,0);');
    Exit;
  end;

  SQL := ' exec SmartBox.[USP_HTMLTecnicoOnlineFichaTecnicaPesquisa] '''+TRIM(edtPesquisar.Text)+''', 0'+IntToStr(UserSession.CodUsuario)+', '+edt90Dias.Text+', 0';
  HTML := UserSession.RetornaSQL(SQL);

  Sleep(1000);

  WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(HTML);
end;

procedure TIWFormFichaTecnica.btnVoltarAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  UserSession.AbreForm('TIWformMain');

  release;
end;

procedure TIWFormFichaTecnica.edtAcrescimoCompensadorHTMLTag(ASender: TObject;
  ATag: TIWHTMLTag);
begin
  ATag.AddStringParam('type','number');
end;

procedure TIWFormFichaTecnica.IWAppFormShow(Sender: TObject);
begin
  WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(' mensagem("Carregando Fichas", "Aguarde...",10000,0,1); ');

  timerShow.Enabled := true;
end;

procedure TIWFormFichaTecnica.timerCarregarAsyncTimer(Sender: TObject;
  EventParams: TStringList);
var SQL : String;
    Ret : String;
begin
  timerCarregar.Enabled := false;

  try
    SQL := ' exec [SmartBox].[USP_HTMLTecnicoOnlineFichaTecnicaCarregar] '''+TRIM(edtFicha.Text)+''', 0'+IntToStr(UserSession.CodUsuario)+
          ', '''+Trim(edtPesquisarFicha.Text)+''', 0'+Trim(edtCamposCalculados.Text);
    Ret := UserSession.RetornaSQL(SQL);

    WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(Ret);
  except
  end;
end;

procedure TIWFormFichaTecnica.timerOnlineAsyncTimer(Sender: TObject;
  EventParams: TStringList);
var SQL : String;
begin
  timerOnline.Enabled := false;

  try
    SQL := ' update FichaTecnica.FichasTecnicas set QuemOnline = 0'+
          IntToStr(UserSession.CodUsuario)+', DtOnline = GETDATE() where Seq = 0'+
          TRIM(edtFicha.Text);
    UserSession.ExecutaSQL(SQL);
  except
  end;

  timerOnline.Enabled := true;
end;

procedure TIWFormFichaTecnica.timerShowAsyncTimer(Sender: TObject;
  EventParams: TStringList);
var SQL : String;
    HTML : String;
    Ficha : String;
begin
  timerShow.Enabled := false;

  try
    Ficha := '';

    if (UserSession.TipoNotificacao = 'Autorizar Ficha') and (UserSession.IDNotificacao > 0) then
    begin
      SQL   := ' select CodigoVinculoTipo from SmartBox.Corporativo_Notificacoes where Seq = 0'+IntToStr(UserSession.IDNotificacao);
      Ficha := UserSession.RetornaSQL(SQL);

      UserSession.TipoNotificacao := '';
      UserSession.IDNotificacao := 0;
    end;

    if Ficha <> '' then
      HTML := ' selecionar('+Ficha+'); '
    else
    begin
      SQL := ' exec SmartBox.[USP_HTMLTecnicoOnlineFichaTecnicaPesquisa] '''+TRIM(edtPesquisar.Text)+''', 0'+IntToStr(UserSession.CodUsuario)+', 0, 1';
      HTML := UserSession.RetornaSQL(SQL);
    end;

    //Sleep(500);

    WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(HTML);
  except
  end;
end;

end.
