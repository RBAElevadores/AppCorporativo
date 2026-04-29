unit untIAMOnline;

interface

uses
  Classes, SysUtils, IWAppForm, IWApplication, IWColor, IWTypes, IWHTMLTag,
  IWBaseComponent, IWBaseHTMLComponent, IWBaseHTML40Component, IWCompExtCtrls,
  Vcl.Controls, IWVCLBaseControl, IWBaseControl, IWBaseHTMLControl, IWControl,
  IWCompButton, IWVCLComponent, IWBaseLayoutComponent, IWBaseContainerLayout,
  IWContainerLayout, IWTemplateProcessorHTML, IWCompEdit, IWCompCheckbox,
  IWCompLabel;

type
  TIWformIAMOnline = class(TIWAppForm)
    IWTemplateProcessorHTML1: TIWTemplateProcessorHTML;
    btnVoltar: TIWButton;
    timerCarregaHtml: TIWTimer;
    edtPesquisar: TIWEdit;
    btnEquipamento: TIWButton;
    btnPesquisar: TIWButton;
    edtObra: TIWEdit;
    btnCarregar: TIWButton;
    timerCarregar: TIWTimer;
    edtAcao: TIWEdit;
    btnAcao: TIWButton;
    chkEPROM: TIWCheckBox;
    btnValores: TIWButton;
    btnAtualizarValores: TIWButton;
    edtValores: TIWEdit;
    timerValores: TIWTimer;
    edtAcionarBotao: TIWEdit;
    btnAcionarBotao: TIWButton;
    edtListaComando: TIWEdit;
    btnListaComando: TIWButton;
    edtListaComandoSemEscolha: TIWEdit;
    edtValoresFiltro: TIWEdit;
    btnWhiteList: TIWButton;
    btnManualCabineiroAtivar: TIWButton;
    btnManualCabineiroDesativar: TIWButton;
    btnManualCabineiroSubir: TIWButton;
    btnManualCabineiroDescer: TIWButton;
    btnPinOut: TIWButton;
    timerManualCabineiroSobeDesce: TIWTimer;
    timerManualCabineiro: TIWTimer;
    lblPinout: TIWLabel;
    edtListarComandosFiltrar: TIWEdit;
    btnAtualizarListaComandos: TIWButton;
    edtHistoricos: TIWEdit;
    btnHistoricos: TIWButton;
    timerConversaSOS: TIWTimer;
    btnSOS: TIWButton;
    edtMensagemSOS: TIWEdit;
    btnMensagemSOS: TIWButton;
    btnEmInstalacaoAutorizar: TIWButton;
    btnEmInstalacaoSenha: TIWButton;
    edtLiberarEquip: TIWEdit;
    procedure btnVoltarAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure timerCarregaHtmlAsyncTimer(Sender: TObject;
      EventParams: TStringList);
    procedure IWAppFormRender(Sender: TObject);
    procedure edtPesquisarAsyncKeyPress(Sender: TObject;
      EventParams: TStringList);
    procedure btnPesquisarAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure edtPesquisarHTMLTag(ASender: TObject; ATag: TIWHTMLTag);
    procedure timerCarregarAsyncTimer(Sender: TObject;
      EventParams: TStringList);
    procedure btnCarregarAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure edtAcaoHTMLTag(ASender: TObject; ATag: TIWHTMLTag);
    procedure btnAcaoAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure chkEPROMHTMLTag(ASender: TObject; ATag: TIWHTMLTag);
    procedure btnValoresAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure btnAtualizarValoresAsyncClick(Sender: TObject;
      EventParams: TStringList);
    procedure timerValoresAsyncTimer(Sender: TObject; EventParams: TStringList);
    procedure btnAcionarBotaoAsyncClick(Sender: TObject;
      EventParams: TStringList);
    procedure btnListaComandoAsyncClick(Sender: TObject;
      EventParams: TStringList);
    procedure btnWhiteListAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure timerManualCabineiroAsyncTimer(Sender: TObject;
      EventParams: TStringList);
    procedure IWAppFormCreate(Sender: TObject);
    procedure timerManualCabineiroSobeDesceAsyncTimer(Sender: TObject;
      EventParams: TStringList);
    procedure btnManualCabineiroDesativarAsyncClick(Sender: TObject;
      EventParams: TStringList);
    procedure btnManualCabineiroAtivarAsyncClick(Sender: TObject;
      EventParams: TStringList);
    procedure btnManualCabineiroSubirAsyncClick(Sender: TObject;
      EventParams: TStringList);
    procedure btnManualCabineiroDescerAsyncClick(Sender: TObject;
      EventParams: TStringList);
    procedure btnPinOutAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure btnAtualizarListaComandosAsyncClick(Sender: TObject;
      EventParams: TStringList);
    procedure btnHistoricosAsyncClick(Sender: TObject;
      EventParams: TStringList);
    procedure timerConversaSOSAsyncTimer(Sender: TObject;
      EventParams: TStringList);
    procedure btnSOSAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure btnMensagemSOSAsyncClick(Sender: TObject;
      EventParams: TStringList);
    procedure btnEmInstalacaoAutorizarAsyncClick(Sender: TObject;
      EventParams: TStringList);
    procedure btnEmInstalacaoSenhaAsyncClick(Sender: TObject;
      EventParams: TStringList);
  public
    Nome_CarregaHtml : String;
    HTML_CarregaHtml : String;

    UltimoHTML       : String;
    UltimoHTMLPrinc  : String;

    CodigoSOS        : Integer;

    procedure Abrindo;
    procedure SolicitaPinOut;
  end;

implementation
Uses ServerController;

{$R *.dfm}


procedure TIWformIAMOnline.Abrindo;
begin
  if UserSession.IAMSOS = 1 then
  begin
    edtObra.Text := IntToStr(UserSession.Obra);

    timerCarregar.Tag     := 0;
    timerCarregar.Enabled := true;
  end;
end;

procedure TIWformIAMOnline.btnAcaoAsyncClick(Sender: TObject;
  EventParams: TStringList);
var SQL : String;
begin
  if not UserSession.VerPermissao('IAM Online: Enviar comando para placa','V',True) then
    exit;

  if edtAcao.Text = '' then
    exit;

  try

    if chkEPROM.Checked then
    begin
      SQL := ' insert into SmartBox.Acoes(SeqDados,Acao,DataAtualizacao,Tipo) '+
             ' select Seq, ''$066'', getdate(), ''ACAO'' from SmartBox.Dados '+
             ' where Obra = 0'+TRIM(edtObra.Text);

      //manda 2x para garantir a abertura da EPROM
      UserSession.ExecutaSQL(SQL);
      sleep(200);
      UserSession.ExecutaSQL(SQL);
    end;


    SQL := ' insert into SmartBox.Acoes(SeqDados,Acao,DataAtualizacao,Tipo) '+
           ' select Seq, '''+trim(edtAcao.Text)+''', getdate(), ''ACAO'' from SmartBox.Dados '+
           ' where Obra = 0'+TRIM(edtObra.Text);

    //manda 2x para garantir o fechamento da EPROM
    UserSession.ExecutaSQL(SQL);
    sleep(200);


    if chkEPROM.Checked then
    begin
      SQL := ' insert into SmartBox.Acoes(SeqDados,Acao,DataAtualizacao,Tipo) '+
             ' select Seq, ''$105'', getdate(), ''ACAO'' from SmartBox.Dados '+
             ' where Obra = 0'+TRIM(edtObra.Text);

      //manda 2x para garantir o fechamento da EPROM
      UserSession.ExecutaSQL(SQL);
      sleep(200);
      UserSession.ExecutaSQL(SQL);
    end;

    edtAcao.Text := '';
    WebApplication.ShowNotification('Comando enviado!',TIWNotifyType.ntSuccess);
  except
    WebApplication.ShowNotification('Digite alguma ação antes de enviar!',TIWNotifyType.ntError);
  end;
end;

procedure TIWformIAMOnline.btnAcionarBotaoAsyncClick(Sender: TObject;
  EventParams: TStringList);
var SQL  : String;
    HTML : String;
begin
  if not UserSession.VerPermissao('IAM Online: Enviar chamado de botão para placa','V',True) then
    exit;

  if (TRIM(edtAcionarBotao.Text) = '') then
    Exit;

  try
    SQL := ' exec [SmartBox].[USP_LancaAcao] 0'+Trim(edtObra.Text)+', ''r'+TRIM(edtAcionarBotao.Text)+''', ''ACAO'' ';
    UserSession.ExecutaSQL(SQL);

    WebApplication.ShowNotification('Comando enviado!',TIWNotifyType.ntSuccess);
  except
  end;
end;

procedure TIWformIAMOnline.btnAtualizarListaComandosAsyncClick(Sender: TObject;
  EventParams: TStringList);
var SQL  : String;
    HTML : String;

    Aux  : String;
begin
  if Trim(edtListaComando.Text) = '' then
    Exit;

  try
    Aux := '0';
    if Trim(edtListaComandoSemEscolha.Text) <> '' then
      Aux := Trim(edtListaComandoSemEscolha.Text);

    SQL := ' exec SmartBox.USP_HTMLTecnicoOnlineIAMOnlineComandos 0'+Trim(edtListaComando.Text)+', 0'+Trim(edtListaComandoSemEscolha.Text)+', '''+
          TRIM(edtListarComandosFiltrar.Text)+''', 1 ';
    HTML := UserSession.RetornaSQL(SQL);

    Sleep(200);

    WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(HTML);
  except
  end;
end;

procedure TIWformIAMOnline.btnAtualizarValoresAsyncClick(Sender: TObject;
  EventParams: TStringList);
var SQL  : String;
    HTML : String;
begin
  if (TRIM(edtValores.Text) = '') then
    Exit;

  SQL := ' exec SmartBox.USP_HTMLTecnicoOnlineIAMOnlineValores 0'+Trim(edtObra.Text)+', 0'+TRIM(edtValores.Text)+', 2';
  HTML := UserSession.RetornaSQL(SQL);

  if HTML <> UltimoHTML then
  begin
    UltimoHTML := HTML;

    Sleep(200);

    WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(HTML);
  end;
end;

procedure TIWformIAMOnline.btnCarregarAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  timerCarregar.Tag     := 0;
  timerCarregar.Enabled := true;
end;

procedure TIWformIAMOnline.btnEmInstalacaoAutorizarAsyncClick(Sender: TObject;
  EventParams: TStringList);
var SQL : String;
begin
  if not UserSession.VerPermissao('IAM Online: Autorizar Equipamento Em Instalacao','V',True) then
    exit;

  try
    //Marca que liberou
    UserSession.ExecutaSQL(' update Obras set Dt_IAM_EquipLiberadoInstalacao = getdate() where Seq = 0'+Trim(edtObra.Text));

    SQL := ' insert into SmartBox.Acoes(SeqDados,Acao,DataAtualizacao,Tipo) '+
           ' select Seq, ''$066'', getdate(), ''ACAO'' from SmartBox.Dados '+
           ' where Obra = 0'+TRIM(edtObra.Text);

    //manda 2x para garantir a abertura da EPROM
    UserSession.ExecutaSQL(SQL);
    sleep(200);
    UserSession.ExecutaSQL(SQL);


    SQL := ' insert into SmartBox.Acoes(SeqDados,Acao,DataAtualizacao,Tipo) '+
           ' select Seq, ''$1091'', getdate(), ''ACAO'' from SmartBox.Dados '+
           ' where Obra = 0'+TRIM(edtObra.Text);

    UserSession.ExecutaSQL(SQL);
    sleep(200);

    SQL := ' insert into SmartBox.Acoes(SeqDados,Acao,DataAtualizacao,Tipo) '+
           ' select Seq, ''$105'', getdate(), ''ACAO'' from SmartBox.Dados '+
           ' where Obra = 0'+TRIM(edtObra.Text);

    //manda 2x para garantir o fechamento da EPROM
    UserSession.ExecutaSQL(SQL);
    sleep(200);
    UserSession.ExecutaSQL(SQL);

    WebApplication.ShowNotification('Comando enviado!',TIWNotifyType.ntSuccess);
  except
    WebApplication.ShowNotification('Houve algum problema ao enviar a Autorização!',TIWNotifyType.ntError);
  end;
end;

procedure TIWformIAMOnline.btnEmInstalacaoSenhaAsyncClick(Sender: TObject;
  EventParams: TStringList);
var I     : Integer;
    Senha : String;
begin
  if not UserSession.VerPermissao('IAM Online: Autorizar Equipamento Em Instalacao','V',True) then
    exit;

  if TRIM(edtLiberarEquip.Text) = '1' then
  begin
    try
      UserSession.ExecutaSQL(' update Obras set Dt_IAM_EquipLiberadoInstalacao = getdate() where Seq = 0'+Trim(edtObra.Text));
    except
      begin
        WebApplication.ShowNotification('Houve algum problema ao registrar a liberação! Tente novamente!',TIWNotifyType.ntError);
        Exit;
      end;
    end;
  end;

  I     := ( Trunc(StrToInt(edtObra.Text) * 123 + 123) mod 1000000007 ) mod 10000;
  Senha :=  IntToStr( I );

  WebApplication.ShowMessage('Senha para Autorização:'+#13+#10+Senha);
end;

procedure TIWformIAMOnline.btnHistoricosAsyncClick(Sender: TObject;
  EventParams: TStringList);
var SQL, HTML : String;
begin
  if Trim(edtHistoricos.Text) = '' then
    Exit;

  try
    SQL := ' exec SmartBox.USP_HTMLTecnicoOnlineIAMOnlineHistoricos 0'+Trim(edtObra.Text)+', 0'+Trim(edtHistoricos.Text);
    HTML := UserSession.RetornaSQL(SQL);

    Sleep(200);

    WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(HTML);
  except
  end;
end;

procedure TIWformIAMOnline.btnListaComandoAsyncClick(Sender: TObject;
  EventParams: TStringList);
var SQL  : String;
    HTML : String;

    Aux  : String;
begin
  if Trim(edtListaComando.Text) = '' then
    Exit;

  if not UserSession.VerPermissao('IAM Online: Ver Comandos','V',True) then
    exit;


  try
    Aux := '0';
    if Trim(edtListaComandoSemEscolha.Text) <> '' then
      Aux := Trim(edtListaComandoSemEscolha.Text);

    SQL := ' exec SmartBox.USP_HTMLTecnicoOnlineIAMOnlineComandos 0'+Trim(edtListaComando.Text)+', 0'+Trim(edtListaComandoSemEscolha.Text)+', '''', 0 ';
    HTML := UserSession.RetornaSQL(SQL);

    Sleep(200);

    WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(HTML);
  except
  end;
end;

procedure TIWformIAMOnline.btnManualCabineiroAtivarAsyncClick(Sender: TObject;
  EventParams: TStringList);
var SQL : String;
begin
  try
    if not UserSession.VerPermissao('IAM Online: Ação Manual Cabineiro','V',True) then
      exit;

    SQL := ' exec [SmartBox].[USP_LancaAcao] 0'+Trim(edtObra.Text)+', ''M1'', ''ACAO'' ';
    UserSession.ExecutaSQL(SQL);

    WebApplication.ShowNotification('Comando enviado!',TIWNotifyType.ntSuccess);

    timerManualCabineiro.Tag     := 0;
    timerManualCabineiro.Enabled := false;
    timerManualCabineiro.Enabled := true;
  except
   begin
     WebApplication.ShowNotification('Erro ao enviar comando para ativar o Manual Cabineiro! Tente novamente.',TIWNotifyType.ntError);
     timerManualCabineiro.Enabled := false;
   end;
  end;
end;

procedure TIWformIAMOnline.btnManualCabineiroDesativarAsyncClick(
  Sender: TObject; EventParams: TStringList);
var SQL : String;
begin
  try
    if not UserSession.VerPermissao('IAM Online: Ação Manual Cabineiro','V',True) then
      exit;

    SQL := ' exec [SmartBox].[USP_LancaAcao] 0'+TRIM(edtObra.Text)+', ''M0'', ''ACAO'' ';
    UserSession.ExecutaSQL(SQL);

    WebApplication.ShowNotification('Comando enviado!',TIWNotifyType.ntSuccess);

    timerManualCabineiro.Enabled := false;
    timerManualCabineiro.Enabled := true;
  except
   begin
     WebApplication.ShowNotification('Erro ao enviar comando para desativar o Manual Cabineiro! Tente novamente.',TIWNotifyType.ntError);
     timerManualCabineiro.Enabled := false;
   end;
  end;
end;

procedure TIWformIAMOnline.btnManualCabineiroDescerAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  if not UserSession.VerPermissao('IAM Online: Ação Manual Cabineiro','V',True) then
    exit;

  if btnManualCabineiroDescer.Tag = 0 then
  begin
    timerManualCabineiroSobeDesce.Tag     := 2;
    timerManualCabineiroSobeDesce.Enabled := true;

    btnManualCabineiroDescer.Css := 'btn btn-danger w-100';
    btnManualCabineiroDescer.Tag := 1;
  end
  else
  begin
    timerManualCabineiroSobeDesce.Enabled := false;

    btnManualCabineiroDescer.Css := 'btn btn-success w-100';
    btnManualCabineiroDescer.Tag := 0;
  end;
end;

procedure TIWformIAMOnline.btnManualCabineiroSubirAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  if not UserSession.VerPermissao('IAM Online: Ação Manual Cabineiro','V',True) then
    exit;

  if btnManualCabineiroSubir.Tag = 0 then
  begin
    timerManualCabineiroSobeDesce.Tag     := 1;
    timerManualCabineiroSobeDesce.Enabled := true;

    btnManualCabineiroSubir.Css := 'btn btn-danger w-100';
    btnManualCabineiroSubir.Tag := 1;
  end
  else
  begin
    timerManualCabineiroSobeDesce.Enabled := false;

    btnManualCabineiroSubir.Css := 'btn btn-success w-100';
    btnManualCabineiroSubir.Tag := 0;
  end;
end;

procedure TIWformIAMOnline.btnMensagemSOSAsyncClick(Sender: TObject;
  EventParams: TStringList);
var SQL : String;
begin
  if TRIM(edtMensagemSOS.Text) = '' then
    Exit;

  // Troca os enters por <br>
  edtMensagemSOS.Text := StringReplace(edtMensagemSOS.Text,'#$D#$A#$D#$A','<br>',[rfReplaceAll]);

  //Lança a mensagem
  try
    SQL := 'insert into SmartBox.SOSChat(Obra,Texto,QuemEnviou,DTInsert) ';
    SQL := SQL + 'select 0'+IntToStr(UserSession.Obra)+','''+TRIM(edtMensagemSOS.Text)+''', ''RBA'', getdate()';

    UserSession.ExecutaSQL(SQL);

    edtMensagemSOS.Text := '';

    WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA('btnFechaModalMensagemSOS.click();');
  except
    WebApplication.ShowMessage('Houve um problema ao enviar sua mensagem! Tente novamente, se o problema persistir procure o suporte!');
  end;
end;

procedure TIWformIAMOnline.btnPesquisarAsyncClick(Sender: TObject;
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

  SQL := ' exec SmartBox.[USP_HTMLTecnicoOnlineIAMOnlinePesquisa] '''+TRIM(edtPesquisar.Text)+''', 0'+IntToStr(UserSession.CodUsuario);
  HTML := UserSession.RetornaSQL(SQL);

  Sleep(1000);

  WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(HTML);
end;

procedure TIWformIAMOnline.btnPinOutAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  btnPinOut.Tag := 0;
  SolicitaPinOut;
end;

procedure TIWformIAMOnline.btnSOSAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  UserSession.AbreForm('TIWformChat');

  release;
end;

procedure TIWformIAMOnline.btnValoresAsyncClick(Sender: TObject;
  EventParams: TStringList);
var SQL  : String;
    HTML : String;
begin
  if (TRIM(edtValores.Text) = '') then
    Exit;

  SQL  := ' exec SmartBox.USP_HTMLTecnicoOnlineIAMOnlineValores 0'+Trim(edtObra.Text)+', 0'+TRIM(edtValores.Text)+', 0';
  HTML := UserSession.RetornaSQL(SQL);

  if HTML <> UltimoHTML then
  begin
    UltimoHTML := HTML;

    Sleep(200);

    timerValores.Interval := 4000;
    timerValores.Enabled  := true;

    edtValoresFiltro.Text := '';

    WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(HTML);
  end;
end;

procedure TIWformIAMOnline.btnVoltarAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  timerCarregar.Enabled := false;

  UserSession.AbreForm('TIWformMain');

  release;
end;

procedure TIWformIAMOnline.btnWhiteListAsyncClick(Sender: TObject;
  EventParams: TStringList);
var SQL : String;
begin
  if not UserSession.VerPermissao('IAM Online: WhiteList Manual','V',True) then
    exit;

  try
    SQL := ' update SmartBox.Dados set DiasWhiteList = 1 where Obra = 0'+Trim(edtObra.Text)+
           ' if Not exists(select 1 from SmartBox.WhiteListManual where Obra = 0'+Trim(edtObra.Text)+') '+
           ' begin insert into SmartBox.WhiteListManual(Obra,Data) select 0'+Trim(edtObra.Text)+', getdate() end ';

    UserSession.ExecutaSQL(SQL);

    WebApplication.ShowNotification('Inserido na WhiteList! Precisa aguardar o ESP do cliente começar a enviar as informações se estiver conectado a internet!',TIWNotifyType.ntSuccess);
  except
    WebApplication.ShowNotification('Houve algum problema ao inserir na WhiteList!',TIWNotifyType.ntError);
  end;
end;

procedure TIWformIAMOnline.chkEPROMHTMLTag(ASender: TObject; ATag: TIWHTMLTag);
begin
  ATag.AddStringParam('type','checkbox');
end;

procedure TIWformIAMOnline.edtAcaoHTMLTag(ASender: TObject; ATag: TIWHTMLTag);
begin
  ATag.AddStringParam('placeholder','Ação');
  ATag.AddStringParam('type','text');
end;

procedure TIWformIAMOnline.edtPesquisarAsyncKeyPress(Sender: TObject;
  EventParams: TStringList);
begin
  if EventParams.Values['which'] = '13' then
    WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA('pesquisar();');
end;

procedure TIWformIAMOnline.edtPesquisarHTMLTag(ASender: TObject;
  ATag: TIWHTMLTag);
begin
  ATag.AddStringParam('placeholder','Obra, Apelido ou Cliente');
end;

procedure TIWformIAMOnline.IWAppFormCreate(Sender: TObject);
begin
  lblPinout.Caption := '';
  CodigoSOS         := 0;
end;

procedure TIWformIAMOnline.IWAppFormRender(Sender: TObject);
begin
  Abrindo;
end;

procedure TIWformIAMOnline.SolicitaPinOut;
var SQL : String;
begin
  try
    SQL := ' exec [SmartBox].[USP_LancaAcao] 0'+trim(edtObra.Text)+', ''Z'', ''PINOUT'' ';
    UserSession.ExecutaSQL(SQL);

    if btnPinOut.Tag = 0 then
      WebApplication.ShowNotification('Comando enviado!',TIWNotifyType.ntSuccess);
  except
   begin
     if btnPinOut.Tag = 0 then
       WebApplication.ShowNotification('Erro ao enviar comando para solicitar PinOuts! Tente novamente.',TIWNotifyType.ntError);
   end;
  end;
end;

procedure TIWformIAMOnline.timerCarregaHtmlAsyncTimer(Sender: TObject;
  EventParams: TStringList);
begin
  timerCarregaHtml.Enabled := false;

  WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA('carregaHtmls("'+Nome_CarregaHtml+'",'''+HTML_CarregaHtml+''');');
end;

procedure TIWformIAMOnline.timerCarregarAsyncTimer(Sender: TObject;
  EventParams: TStringList);
var SQL : String;
    Ret : String;
begin
  timerCarregar.Enabled := false;

  try
    //Primeiro giro para carregar cabeçalho
    if timerCarregar.Tag = 0 then
    begin
      SQL := ' exec SmartBox.USP_HTMLTecnicoOnlineIAMOnlineCabecalho 0'+TRIM(edtObra.Text)+', 0'+IntToStr(UserSession.CodUsuario);

      timerCarregar.Tag := 1;

      Ret := UserSession.RetornaSQL(SQL);

      if UserSession.IAMSOS = 1 then
      begin
        Ret := Ret + ' mostrarSOS();';

        timerConversaSOS.Enabled := true;
      end;

      WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(Ret);
    end
    else
    begin
      SQL := ' exec SmartBox.USP_HTMLTecnicoOnlineIAMOnlineBotoeriaAcoes 0'+TRIM(edtObra.Text)+', 0'+IntToStr(UserSession.CodUsuario);
      Ret := UserSession.RetornaSQL(SQL);

      if UltimoHTMLPrinc <> Ret then
      begin
        UltimoHTMLPrinc := Ret;

        WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(Ret);
      end;

    end;

  except
  end;

  timerCarregar.Enabled := true;
end;

procedure TIWformIAMOnline.timerConversaSOSAsyncTimer(Sender: TObject;
  EventParams: TStringList);
var Quem       : String;
    SQL        : String;
    HTML       : String;
    Ret        : String;
begin
  timerConversaSOS.Enabled := false;

  try
    UserSession.ConectarBD;

    //faz a pesquisa
    UserSession.qryAux.Close;
    UserSession.qryAux.SQL.Clear;
    UserSession.qryAux.SQL.Add(' select Codigo, REPLACE(Texto,CHAR(13)+Char(10),''<br>'') Texto, Obra, QuemEnviou, convert(varchar(5),DTInsert,108) Hora, IIF( (DTLido_RBA is null) and (QuemEnviou = ''TABLET'') ,''1'',''0'') MarcarLido from SmartBox.SOSChat ');
    UserSession.qryAux.SQL.Add(' where Obra = :Obra ');
    UserSession.qryAux.SQL.Add(' and Codigo > :Codigo ');
    UserSession.qryAux.SQL.Add(' order by Codigo ');
    UserSession.qryAux.ParamByName('Codigo').AsInteger := CodigoSOS;
    UserSession.qryAux.ParamByName('Obra').AsInteger  := UserSession.Obra;

    UserSession.qryAux.Open;

    if not UserSession.qryAux.IsEmpty then
    begin
      CodigoSOS := UserSession.qryAux.Fields[0].AsInteger;

      while not UserSession.qryAux.Eof do
      begin

        //Seta o valor de quem que é o audio
        Quem := UserSession.qryAux.Fields[3].AsString;
        if Quem = 'TABLET' then
          Quem := 'Obra '+UserSession.qryAux.Fields[2].AsString
        else
          Quem := 'RBA ELEVADORES';

        WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA('addChat("'+Quem+'","'+UserSession.qryAux.Fields[1].AsString+'","'+UserSession.qryAux.Fields[4].AsString+'");');

        UserSession.qryAux.Next;
      end;

    end;

    //Verifica se o cliente ainda esta online ou se encerrou o atendimento
    try
      SQL := ' select ''<strong> <font color="red">''+case when not (DTConcluido is null) then ''ATENDIMENTO ENCERRADO'' ELSE ''OFF-LINE'' END+''</font> </strong>'' StatusTablet '+
             ' from SmartBox.Atendimentos '+
             ' where Codigo = 0'+IntToStr(UserSession.Atendimento)+
               ' and ( (not DTConcluido is null) or (DATEDIFF(second,isnull(DTTabletOnline,''01/01/1990''),getdate())>40) ) ';

      Ret := UserSession.RetornaSQL(SQL);
      if TRIM(Ret) <> '' then
        WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA('addChat("Cliente","'+Ret+'","'+TimeToStr(now)+'");');
    except
    end;
  except
  end;

  timerConversaSOS.Enabled := true;
end;

procedure TIWformIAMOnline.timerManualCabineiroAsyncTimer(Sender: TObject;
  EventParams: TStringList);
var SQL : String;
begin
  timerManualCabineiro.Enabled := false;

  //Tenta conectar
  if not UserSession.ConectarBD then
  begin
    timerManualCabineiro.Enabled := true;
    Exit;
  end;

  //faz a pesquisa
  UserSession.qryAux2.Close;
  UserSession.qryAux2.SQL.Clear;
  try
    UserSession.qryAux2.SQL.Add(' select ManualCabineiro, FDCPrimPino, FDCUltPino from ( ');
    UserSession.qryAux2.SQL.Add('    select ManualCabineiro from ( ');
    UserSession.qryAux2.SQL.Add('          select a.Valor from SmartBox.SuporteOnline a ');
    UserSession.qryAux2.SQL.Add('          inner join SmartBox.Dados b on b.Seq = a.Seq_Dados ');
    UserSession.qryAux2.SQL.Add('          where b.Obra = :Obra and a.Tipo = ''Botoeira''  ');
    UserSession.qryAux2.SQL.Add('          ) a ');
    UserSession.qryAux2.SQL.Add('    outer apply [SmartBox].[F_LerBotoeira](a.Valor) b ');
    UserSession.qryAux2.SQL.Add('    ) a ');
    UserSession.qryAux2.SQL.Add(' inner join ( ');
    UserSession.qryAux2.SQL.Add('    select SUM(IIF(b.Nome=''FDCPrimPino'',b.ValorPino,0)) FDCPrimPino, SUM(IIF(b.Nome=''FDCUltPino'',b.ValorPino,0)) FDCUltPino from ( ');
    UserSession.qryAux2.SQL.Add('          select b.Obra, a.Valor from SmartBox.SuporteOnline a ');
    UserSession.qryAux2.SQL.Add('          inner join SmartBox.Dados b on b.Seq = a.Seq_Dados ');
    UserSession.qryAux2.SQL.Add('          where b.Obra = :Obra and a.Tipo = ''Pinout''  ');
    UserSession.qryAux2.SQL.Add('          ) a ');
    UserSession.qryAux2.SQL.Add('    outer apply [SmartBox].[F_LerPinOut](a.Valor) b ');
    UserSession.qryAux2.SQL.Add('    where b.Nome in (''FDCPrimPino'',''FDCUltPino'') ');
    UserSession.qryAux2.SQL.Add('    group by a.Obra ');
    UserSession.qryAux2.SQL.Add('    ) b on 1=1 ');
    UserSession.qryAux2.ParamByName('Obra').AsString := TRIM(edtObra.Text);

    UserSession.qryAux2.Open;

    if not UserSession.qryAux2.IsEmpty then
    begin
      lblPinout.Caption := 'FDCPrimPino: '+UserSession.qryAux2.Fields[1].AsString+' - FDCUltPino:'+UserSession.qryAux2.Fields[2].AsString;

      if UserSession.qryAux2.Fields[0].AsString = '1' then
      begin
        timerManualCabineiro.Tag            := 1;

        btnManualCabineiroAtivar.Enabled    := false;
        btnManualCabineiroDesativar.Enabled := true;
        btnManualCabineiroSubir.Enabled     := true;
        btnManualCabineiroDescer.Enabled    := true;

        timerManualCabineiro.Enabled        := true;
      end
      else if timerManualCabineiro.Tag = 1 then // Se já ficou ativo e não está mais, então bloqueia
      begin
        timerManualCabineiro.Tag            := 0;

        btnManualCabineiroAtivar.Enabled    := true;
        btnManualCabineiroDesativar.Enabled := false;
        btnManualCabineiroSubir.Enabled     := false;
        btnManualCabineiroDescer.Enabled    := false;
      end
      else
        timerManualCabineiro.Enabled        := true;

    end
    else
      timerManualCabineiro.Enabled        := true;
  except
    timerManualCabineiro.Enabled := true;
  end;
end;

procedure TIWformIAMOnline.timerManualCabineiroSobeDesceAsyncTimer(
  Sender: TObject; EventParams: TStringList);
var SQL  : String;
begin
  timerManualCabineiroSobeDesce.Enabled := false;

  try
    SQL := ' exec [SmartBox].[USP_LancaAcao] 0'+Trim(edtObra.Text)+', ''m'+IntToStr(timerManualCabineiroSobeDesce.Tag)+''', ''ACAO'' ';
    UserSession.ExecutaSQL(SQL);
  except
  end;

  //a cada 1 segundo +- pede pinout junto
  btnPinOut.Tag := btnPinOut.Tag + 1;
  if btnPinOut.Tag >= 10 then
    btnPinOut.Tag := 1;

  timerManualCabineiroSobeDesce.Enabled := true;
end;

procedure TIWformIAMOnline.timerValoresAsyncTimer(Sender: TObject;
  EventParams: TStringList);
var SQL  : String;
    HTML : String;
begin
  timerValores.Enabled := false;

  if timerValores.Interval <> 2000 then
    timerValores.Interval := 2000;

  try

    SQL  := ' exec SmartBox.USP_HTMLTecnicoOnlineIAMOnlineValores 0'+Trim(edtObra.Text)+', 0'+TRIM(edtValores.Text)+', 1';

    if TRIM(edtValoresFiltro.Text) <> '' then
      SQL := SQL + ', '''+TRIM(edtValoresFiltro.Text)+''' ';

    HTML := UserSession.RetornaSQL(SQL);

    if HTML <> UltimoHTML then
    begin
      UltimoHTML := HTML;

      Sleep(200);

      WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(HTML);
    end;

  except
  end;

  timerValores.Enabled := true;
end;

end.
