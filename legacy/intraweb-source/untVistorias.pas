unit untVistorias;

interface

uses
  Classes, SysUtils, IWAppForm, IWApplication, IWColor, IWTypes, Vcl.Controls,
  IWVCLBaseControl, IWBaseControl, IWBaseHTMLControl, IWControl, IWCompButton,
  IWVCLComponent, IWBaseLayoutComponent, IWBaseContainerLayout,
  IWContainerLayout, IWTemplateProcessorHTML, IWBaseComponent,
  IWBaseHTMLComponent, IWBaseHTML40Component, IWCompExtCtrls, IWCompEdit,
  IWHTMLTag, Data.DB, IWCompMemo, IWCompListbox;

type
  TIWformVistorias = class(TIWAppForm)
    IWTemplateProcessorHTML1: TIWTemplateProcessorHTML;
    btnVoltar: TIWButton;
    timerShow: TIWTimer;
    edtPesquisar: TIWEdit;
    btnPesquisar: TIWButton;
    edtObra: TIWEdit;
    btnCarregar: TIWButton;
    timerCarregar: TIWTimer;
    edtVistoria: TIWEdit;
    btnCarregarVistoria: TIWButton;
    timerVistoria: TIWTimer;
    edtPesquisarFicha: TIWEdit;
    btnCarregarFicha: TIWButton;
    timerCarregarFicha: TIWTimer;
    btnArquivosFotos: TIWButton;
    timerArquivosFotos: TIWTimer;
    edtEnvio: TIWEdit;
    btnEnvio: TIWButton;
    edtEnvioTipo: TIWEdit;
    edtEnvioCopia: TIWEdit;
    memoDescAditivo: TIWMemo;
    btnSolicitaAditivo: TIWButton;
    cbxConseguiuContato: TIWComboBox;
    memoDetalheContato: TIWMemo;
    edtNomeContato: TIWEdit;
    btnLancaFollowUp: TIWButton;
    procedure btnVoltarAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure timerShowAsyncTimer(Sender: TObject; EventParams: TStringList);
    procedure IWAppFormShow(Sender: TObject);
    procedure IWAppFormRender(Sender: TObject);
    procedure edtPesquisarAsyncKeyPress(Sender: TObject;
      EventParams: TStringList);
    procedure edtPesquisarHTMLTag(ASender: TObject; ATag: TIWHTMLTag);
    procedure btnPesquisarAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure btnCarregarAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure timerCarregarAsyncTimer(Sender: TObject;
      EventParams: TStringList);
    procedure timerVistoriaAsyncTimer(Sender: TObject;
      EventParams: TStringList);
    procedure btnCarregarVistoriaAsyncClick(Sender: TObject;
      EventParams: TStringList);
    procedure btnCarregarFichaAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure timerCarregarFichaAsyncTimer(Sender: TObject;
      EventParams: TStringList);
    procedure timerArquivosFotosAsyncTimer(Sender: TObject;
      EventParams: TStringList);
    procedure btnArquivosFotosAsyncClick(Sender: TObject;
      EventParams: TStringList);
    procedure btnEnvioAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure btnSolicitaAditivoAsyncClick(Sender: TObject;
      EventParams: TStringList);
    procedure btnLancaFollowUpAsyncClick(Sender: TObject;
      EventParams: TStringList);
  public
  end;

implementation
uses ServerController;

{$R *.dfm}


procedure TIWformVistorias.btnArquivosFotosAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  timerArquivosFotos.Enabled := false;
  timerArquivosFotos.Enabled := true;
end;

procedure TIWformVistorias.btnCarregarAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  timerCarregar.Enabled := false;
  timerCarregar.Enabled := true;
end;

procedure TIWformVistorias.btnCarregarVistoriaAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  timerVistoria.Enabled := false;
  timerVistoria.Enabled := true;
end;

procedure TIWformVistorias.btnEnvioAsyncClick(Sender: TObject;
  EventParams: TStringList);
var Aux : String;
begin
  if (Trim(edtEnvio.Text) = '') and (TRIM(edtEnvioTipo.Text) = '') then
    Exit;

  if Trim(edtEnvioTipo.Text) = '1' then
  begin
    if not UserSession.VerPermissao('Vistorias: Enviar E-Mail','V',True) then
      exit;
  end
  else if Trim(edtEnvioTipo.Text) = '2' then
  begin
    if not UserSession.VerPermissao('Vistorias: Enviar WhatsApp','V',True) then
      exit;
  end;


  if (Trim(edtEnvio.Text) = '') then
  begin
    if Trim(edtEnvioTipo.Text) = '1' then
      WebApplication.ShowNotification('Preencha algum Email antes de clicar para enviar!',TIWNotifyType.ntLog)
    else
      WebApplication.ShowNotification('Preencha algum Whatsapp antes de clicar para enviar!',TIWNotifyType.ntLog);

    Exit;
  end;

  Aux := Trim(edtEnvio.Text);

  if trim(edtEnvioCopia.Text) <> '' then
    Aux := Aux + ';' + trim(edtEnvioCopia.Text);

  // Email
  if Trim(edtEnvioTipo.Text) = '1' then
  begin
    try
      UserSession.ExecutaSQL(' exec dbo.USP_EnviaEmailVistoria 0'+TRIM(edtVistoria.Text)+', '''+Aux+''' ');

      WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(' mensagem("Emails","Email enviado!",2000,1,0); ');
    except
      WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(' mensagem("Emails","<font color=red> <strong> Houve algum problema ao enviar o email! </strong> </font>",0,1,0); ');
    end;
  end
  else if Trim(edtEnvioTipo.Text) = '2' then //Whatsapp
  begin
    try
      UserSession.ExecutaSQL(' exec dbo.USP_EnviaWhatsAppVistoria 0'+TRIM(edtVistoria.Text)+', '''+Aux+''' ');

      WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(' mensagem("Whatsapp","Whatsapp enviado!",2000,1,0); ');
    except
      WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(' mensagem("Whatsapp","<font color=red> <strong> Houve algum problema ao enviar o whatsapp! </strong> </font>",0,1,0); ');
    end;
  end;

end;

procedure TIWformVistorias.btnLancaFollowUpAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  if cbxConseguiuContato.Text = 'Sim' then
  begin
    if edtNomeContato.Text = '' then
    begin
      WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(' mensagem("Follow UP","<font color=red> <strong> Digite o nome do contato! </strong> </font>",0,1,0); ');
      exit;
    end;
  end
  else if TRIM(cbxConseguiuContato.Text) = '' then
  begin
    WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(' mensagem("Follow UP","<font color=red> <strong> Preencha os campos de contato! </strong> </font>",0,1,0); ');
    exit;
  end;

  if (cbxConseguiuContato.Text = 'Não') and (Trim(edtNomeContato.Text) <> '') then
  begin
    WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(' mensagem("Follow UP","<font color=red> <strong> Conseguiu contato como NÃO e Existe um nome, excluir nome do contato! </strong> </font>",0,1,0); ');
    exit;
  end;

  if memoDetalheContato.Text = '' then
  begin
    WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(' mensagem("Follow UP","<font color=red> <strong> Digite alguma informação para registrar o contato! </strong> </font>",0,1,0); ');
    Exit;
  end;

  if(UserSession.RetornaSQL('exec Telas.USP_LancaFollowUP @Obra = 0'+ edtObra.Text +' , @Usuario = ' + IntToStr(UserSession.CodUsuario) + ', @ConseguiuContato = '+ QuotedStr(cbxConseguiuContato.Text) +', @Observacao = '+ QuotedStr(memoDetalheContato.Text) +', @Tipo = ''Civil'', @NomeContato = ' + QuotedStr(edtNomeContato.Text)) <> '0') then
  begin
    WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(' mensagem("Follow UP","<font color=red> <strong> Ocorreu um erro! </strong> </font>",0,1,0); ');
  end
  else
  begin
    WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(' mensagem("Follow UP","Follow UP registrado!",2000,1,0); ');
  end;
end;

procedure TIWformVistorias.btnPesquisarAsyncClick(Sender: TObject;
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

  SQL := ' exec SmartBox.[USP_HTMLTecnicoOnlineVistoriasPesquisa] '''+TRIM(edtPesquisar.Text)+''', 0'+IntToStr(UserSession.CodUsuario);
  HTML := UserSession.RetornaSQL(SQL);

  Sleep(1000);

  WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(HTML);
end;

procedure TIWformVistorias.btnSolicitaAditivoAsyncClick(Sender: TObject;
  EventParams: TStringList);
var Ret, SQL : String;
begin
  if Trim(memoDescAditivo.Text) = '' then
    Exit;

  try
    Ret := UserSession.RetornaSQL(' select Obra from ObraVistorias where Seq = 0'+Trim(edtVistoria.Text));
    if Ret = '' then
    begin
      WebApplication.ShowNotification('Houve algum problema ao encontrar a Obra da vistoria!',TIWNotifyType.ntLog);
      WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA('btnFechaModalMensagem.click();');
      Exit;
    end;

    SQL := 'select 1 aux from Producao.OPPlanejamento_Itens a '+
           ' inner join Producao.Pedidos b on b.Seq = a.OP '+
           ' where b.Obra = 0'+Ret;
    if UserSession.RetornaSQL(SQL) = '1' then
    begin
      WebApplication.ShowNotification('Este equipamento já está em um Planejamento de Fabricação. Falar com o PCP.',TIWNotifyType.ntLog);
      WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA('btnFechaModalMensagem.click();');
      Exit;
    end;
  except
    begin
      WebApplication.ShowNotification('Houve algum problema ao encontrar a Obra da vistoria!',TIWNotifyType.ntLog);
      WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA('btnFechaModalMensagem.click();');
      Exit;
    end;
  end;

  UserSession.qryAux.Close;
  UserSession.qryAux.SQL.Clear;
  UserSession.qryAux.SQL.Add('insert into SolicitacaoAditivo(Obra,Status,UsuInsert,Descricao) select :Obra, :Status, :UsuInsert, :Descricao');
  UserSession.qryAux.ParamByName('Obra').AsString        := Ret;
  UserSession.qryAux.ParamByName('Status').AsString      := 'Aditivo Solicitado';
  UserSession.qryAux.ParamByName('UsuInsert').AsInteger  := UserSession.CodUsuario;
  UserSession.qryAux.ParamByName('Descricao').AsString   := trim(memoDescAditivo.Text);
  UserSession.qryAux.ExecSql;

  WebApplication.ShowNotification('Aditivo gerado com sucesso!',TIWNotifyType.ntSuccess);
  WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA('btnFechaModalMensagem.click(); btnFechaModalVistoria.click();');

  timerVistoria.Enabled := true;
end;

procedure TIWformVistorias.btnVoltarAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  UserSession.AbreForm('TIWformMain');

  release;
end;

procedure TIWformVistorias.edtPesquisarAsyncKeyPress(Sender: TObject;
  EventParams: TStringList);
begin
  if EventParams.Values['which'] = '13' then
    WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA('pesquisar();');
end;

procedure TIWformVistorias.edtPesquisarHTMLTag(ASender: TObject;
  ATag: TIWHTMLTag);
begin
  ATag.AddStringParam('placeholder','Obra, Apelido ou Cliente');
end;

procedure TIWformVistorias.IWAppFormRender(Sender: TObject);
begin
  timerShow.Enabled := false;
  timerShow.Enabled := true;
end;

procedure TIWformVistorias.IWAppFormShow(Sender: TObject);
begin
  timerShow.Enabled := false;
  timerShow.Enabled := true;
end;

procedure TIWformVistorias.btnCarregarFichaAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  timerCarregarFicha.Enabled := false;
  timerCarregarFicha.Enabled := true;
end;

procedure TIWformVistorias.timerArquivosFotosAsyncTimer(Sender: TObject;
  EventParams: TStringList);
var CaminhoArq : String;
    SQL        : String;
    Ret        : String;
begin
  timerArquivosFotos.Enabled := false;

  if not DirectoryExists(WebApplication.ApplicationPath+'\wwwroot\ArquivosVistoria') then
    CreateDir(WebApplication.ApplicationPath+'\wwwroot\ArquivosVistoria');

  try
    UserSession.qryAux.Close;
    UserSession.qryAux.SQL.Clear;
    UserSession.qryAux.SQL.Add(' select Foto, cast(Seq as varchar(10))+IIF( Tipo = ''Projeto'', ''.pdf'', ''.jpeg'') Nome ');
    UserSession.qryAux.SQL.Add(' from ObraVistoriaFotos ');
    UserSession.qryAux.SQL.Add(' where Vistoria = :Seq  ');
    UserSession.qryAux.ParamByName('Seq').AsString := edtVistoria.Text;
    UserSession.qryAux.Open;

    if not UserSession.qryAux.IsEmpty then
    begin
      UserSession.qryAux.First;

      while not UserSession.qryAux.Eof do
      begin
        CaminhoArq := WebApplication.ApplicationPath+'\wwwroot\ArquivosVistoria\'+UserSession.qryAux.Fields[1].AsString;
        if FileExists(CaminhoArq) then
          DeleteFile(CaminhoArq);

        (UserSession.qryAux.Fields[0] as TBlobField).SaveToFile(CaminhoArq);

        UserSession.qryAux.Next;
      end;
    end;
  except
    begin
      WebApplication.ShowNotification('Houve algum problema ao carregar as imagens!',TIWNotifyType.ntError);
      WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA('btnFechaModalMensagem.click();');
    end;
  end;

  //Carrega a página
  try
    SQL := ' exec SmartBox.USP_HTMLTecnicoOnlineVistoriaCarregarImagens 0'+TRIM(edtVistoria.Text);
    Ret := UserSession.RetornaSQL(SQL);

    WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(Ret);
  except
  end;
end;

procedure TIWformVistorias.timerCarregarAsyncTimer(Sender: TObject;
  EventParams: TStringList);
var SQL : String;
    Ret : String;
begin
  timerCarregar.Enabled := false;

  try
    SQL := ' exec SmartBox.USP_HTMLTecnicoOnlineVistorias 0'+TRIM(edtObra.Text);

    Ret := UserSession.RetornaSQL(SQL);

    WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(Ret);
  except
  end;
end;

procedure TIWformVistorias.timerCarregarFichaAsyncTimer(Sender: TObject;
  EventParams: TStringList);
var SQL : String;
    Ret : String;
begin
  timerCarregarFicha.Enabled := false;

  try
    SQL := ' exec SmartBox.USP_HTMLTecnicoOnlineVistoriaCarregarFicha '''+TRIM(edtVistoria.Text)+''', '''+Trim(edtPesquisarFicha.Text)+'''';
    Ret := UserSession.RetornaSQL(SQL);

    WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(Ret);
  except
  end;
end;

procedure TIWformVistorias.timerShowAsyncTimer(Sender: TObject;
  EventParams: TStringList);
begin
  timerShow.Enabled := false;
end;

procedure TIWformVistorias.timerVistoriaAsyncTimer(Sender: TObject;
  EventParams: TStringList);
var SQL : String;
    Ret : String;
begin
  timerVistoria.Enabled := false;

  try
    SQL := ' exec SmartBox.USP_HTMLTecnicoOnlineVistoriasCarregar 0'+TRIM(edtVistoria.Text);

    Ret := UserSession.RetornaSQL(SQL);

    WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(Ret);
  except
  end;
end;

end.
