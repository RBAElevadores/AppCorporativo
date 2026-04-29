unit untChat;

interface

uses
  Classes, SysUtils, IWAppForm, IWApplication, IWColor, IWTypes,
  IWBaseComponent, IWBaseHTMLComponent, IWBaseHTML40Component, IWCompExtCtrls,
  IWVCLComponent, IWBaseLayoutComponent, IWBaseContainerLayout,
  IWContainerLayout, IWTemplateProcessorHTML, Vcl.Controls, IWVCLBaseControl,
  IWBaseControl, IWBaseHTMLControl, IWControl, IWCompButton, IWCompEdit,
  IWHTMLTag, SHELLAPI, IdCoderMIME, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  IWCompLabel, IWCompMemo, Vcl.ExtCtrls;

type
  TIWformChat = class(TIWAppForm)
    IWTemplateProcessorHTML1: TIWTemplateProcessorHTML;
    timerOnline: TIWTimer;
    timerCarregaHtml: TIWTimer;
    btnVoltar: TIWButton;
    timerConversa: TIWTimer;
    lblOnline: TIWLabel;
    timerConversasAbertas: TIWTimer;
    edtObra: TIWEdit;
    btnAtender: TIWButton;
    lblObraApelido: TIWLabel;
    lblEndereco: TIWLabel;
    lblTelefone: TIWLabel;
    lblTelefonesEmergenciais: TIWLabel;
    memMsgs: TFDMemTable;
    memMsgsCodigo: TIntegerField;
    memoMsg: TIWMemo;
    btnEnviar: TIWButton;
    btnEncerrar: TIWButton;
    timerMobile: TIWTimer;
    timerShow: TIWTimer;
    btnManualCabineiroAtivar: TIWButton;
    btnManualCabineiroDesativar: TIWButton;
    btnManualCabineiroSubir: TIWButton;
    btnManualCabineiroDescer: TIWButton;
    timerManualCabineiroSobeDesce: TIWTimer;
    timerManualCabineiro: TIWTimer;
    btnPinOut: TIWButton;
    lblPinout: TIWLabel;
    btnSalvarObservacao: TIWButton;
    edtObservacao: TIWMemo;
    edtComando: TIWEdit;
    btnEnviarComando: TIWButton;
    btnIAMOnline: TIWButton;
    procedure timerOnlineAsyncTimer(Sender: TObject; EventParams: TStringList);
    procedure btnVoltarClick(Sender: TObject);
    procedure timerCarregaHtmlAsyncTimer(Sender: TObject;
      EventParams: TStringList);
    procedure timerConversaAsyncTimer(Sender: TObject;
      EventParams: TStringList);
    procedure IWAppFormCreate(Sender: TObject);
    procedure IWAppFormShow(Sender: TObject);
    procedure timerConversasAbertasAsyncTimer(Sender: TObject;
      EventParams: TStringList);
    procedure btnAtenderAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure btnEnviarAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure memoMsgHTMLTag(ASender: TObject; ATag: TIWHTMLTag);
    procedure btnEncerrarAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure timerMobileAsyncTimer(Sender: TObject; EventParams: TStringList);
    procedure timerShowAsyncTimer(Sender: TObject; EventParams: TStringList);
    procedure timerManualCabineiroSobeDesceAsyncTimer(Sender: TObject;
      EventParams: TStringList);
    procedure btnManualCabineiroAtivarAsyncClick(Sender: TObject;
      EventParams: TStringList);
    procedure btnManualCabineiroDesativarAsyncClick(Sender: TObject;
      EventParams: TStringList);
    procedure timerManualCabineiroAsyncTimer(Sender: TObject;
      EventParams: TStringList);
    procedure btnPinOutAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure btnManualCabineiroSubirAsyncClick(Sender: TObject;
      EventParams: TStringList);
    procedure btnManualCabineiroDescerAsyncClick(Sender: TObject;
      EventParams: TStringList);
    procedure btnSalvarObservacaoAsyncClick(Sender: TObject;
      EventParams: TStringList);
    procedure edtObservacaoHTMLTag(ASender: TObject; ATag: TIWHTMLTag);
    procedure edtObservacaoAsyncChange(Sender: TObject;
      EventParams: TStringList);
    procedure btnEnviarComandoAsyncClick(Sender: TObject;
      EventParams: TStringList);
    procedure btnIAMOnlineAsyncClick(Sender: TObject; EventParams: TStringList);
  public
    Nome_CarregaHtml : String;
    HTML_CarregaHtml : String;

    Obra             : Integer;
    {procedures/functions}
    procedure SolicitaPinOut;
  end;

implementation
Uses ServerController;
{$R *.dfm}


procedure TIWformChat.btnAtenderAsyncClick(Sender: TObject;
  EventParams: TStringList);
var SQL : String;
begin
  if (TRIM(edtObra.Text) = '') then
    Exit;

  if StrToInt(edtObra.Text) = UserSession.Obra then
    Exit;

  try
    UserSession.Obra := StrToInt(edtObra.Text);
  except
    Exit;
  end;

  UserSession.AbreForm('TIWformChat');
end;

procedure TIWformChat.btnEncerrarAsyncClick(Sender: TObject;
  EventParams: TStringList);
var SQL : String;
begin
  if UserSession.Atendimento <= 0 then
    Exit;

  try
    //Registra que começou o atendimento
    SQL := ' update SmartBox.Atendimentos set DTConcluido = GETDATE(), QuemConcluiu = ''RBA'', QuemInicioAtendimento = 0'+IntToStr(UserSession.CodUsuario)+
           ' where Codigo = 0'+IntToStr(UserSession.Atendimento);

    UserSession.ExecutaSQL(SQL);

    Release;
  except
    Exit;
  end;
end;

procedure TIWformChat.btnEnviarAsyncClick(Sender: TObject;
  EventParams: TStringList);
var SQL : String;
begin
  if TRIM(memoMsg.Text) = '' then
    Exit;

  // Troca os enters por <br>
  memoMsg.Text := StringReplace(memoMsg.Text,'#$D#$A#$D#$A','<br>',[rfReplaceAll]);

  //Lança a mensagem
  try
    SQL := 'insert into SmartBox.SOSChat(Obra,Texto,QuemEnviou,DTInsert) ';
    SQL := SQL + 'select 0'+IntToStr(UserSession.Obra)+','''+TRIM(memoMsg.Text)+''', ''RBA'', getdate()';

    UserSession.ExecutaSQL(SQL);

    memoMsg.Text := '';
  except
    WebApplication.ShowMessage('Houve um problema ao enviar sua mensagem! Tente novamente, se o problema persistir procure o suporte!');
  end;

end;

procedure TIWformChat.btnEnviarComandoAsyncClick(Sender: TObject;
  EventParams: TStringList);
var SQL : String;
begin
  if TRIM(edtComando.Text) <> '' then
  begin
    try
      SQL := ' exec [SmartBox].[USP_LancaAcao] 0'+IntToStr(UserSession.Obra)+
             '                     , '''+TRIM(edtComando.Text)+''', ''ACAO''';
      UserSession.ExecutaSQL(SQL);

      edtComando.Text := '';
      WebApplication.ShowNotification('Comando enviado com sucesso!',ntSuccess);
    except
      WebApplication.ShowNotification('Houve algum problema ao enviar o comando!',ntError);
    end;
  end;
end;

procedure TIWformChat.btnIAMOnlineAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  if not UserSession.VerPermissao('IAM: IAM Online','V',True) then
    exit;

  UserSession.IAMSOS := 1;

  UserSession.AbreForm('TIWformIAMOnline');

  Release;
end;

procedure TIWformChat.btnManualCabineiroAtivarAsyncClick(Sender: TObject;
  EventParams: TStringList);
var SQL : String;
begin
  try
    SQL := ' exec [SmartBox].[USP_LancaAcao] 0'+IntToStr(UserSession.Obra)+', ''M1'', ''ACAO'' ';
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

procedure TIWformChat.btnManualCabineiroDesativarAsyncClick(Sender: TObject;
  EventParams: TStringList);
var SQL : String;
begin
  try
    SQL := ' exec [SmartBox].[USP_LancaAcao] 0'+IntToStr(UserSession.Obra)+', ''M0'', ''ACAO'' ';
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

procedure TIWformChat.btnManualCabineiroDescerAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  if btnManualCabineiroDescer.Tag = 0 then
  begin
    timerManualCabineiroSobeDesce.Tag     := 2;
    timerManualCabineiroSobeDesce.Enabled := true;

    btnManualCabineiroDescer.Css := 'btn btn-danger';
    btnManualCabineiroDescer.Tag := 1;
  end
  else
  begin
    timerManualCabineiroSobeDesce.Enabled := false;

    btnManualCabineiroDescer.Css := 'btn btn-success';
    btnManualCabineiroDescer.Tag := 0;
  end;
end;

procedure TIWformChat.btnManualCabineiroSubirAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  if btnManualCabineiroSubir.Tag = 0 then
  begin
    timerManualCabineiroSobeDesce.Tag     := 1;
    timerManualCabineiroSobeDesce.Enabled := true;

    btnManualCabineiroSubir.Css := 'btn btn-danger';
    btnManualCabineiroSubir.Tag := 1;
  end
  else
  begin
    timerManualCabineiroSobeDesce.Enabled := false;

    btnManualCabineiroSubir.Css := 'btn btn-success';
    btnManualCabineiroSubir.Tag := 0;
  end;
end;

procedure TIWformChat.btnPinOutAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  btnPinOut.Tag := 0;
  SolicitaPinOut;
end;

procedure TIWformChat.btnSalvarObservacaoAsyncClick(Sender: TObject;
  EventParams: TStringList);
var SQL : String;
begin
  if trim(edtObservacao.Text) = '' then
    Exit;

  try
    SQL := ' update SmartBox.Atendimentos set Observacao = '''+trim(edtObservacao.Text)+''' where Codigo = 0'+IntToStr(UserSession.Atendimento);
    UserSession.ExecutaSQL(SQL);
  except
  end;
end;

procedure TIWformChat.btnVoltarClick(Sender: TObject);
begin
  UserSession.IAMSOS := 0;

  Release;
end;

procedure TIWformChat.edtObservacaoAsyncChange(Sender: TObject;
  EventParams: TStringList);
var SQL : String;
begin
  if trim(edtObservacao.Text) = '' then
    Exit;


  try
    SQL := ' update SmartBox.Atendimentos set Observacao = '''+trim(edtObservacao.Text)+''' where Codigo = 0'+IntToStr(UserSession.Atendimento);
    UserSession.ExecutaSQL(SQL);
  except
  end;
end;

procedure TIWformChat.edtObservacaoHTMLTag(ASender: TObject; ATag: TIWHTMLTag);
begin
  ATag.AddStringParam('style','height: 200;');
  ATag.AddStringParam('maxlength','500');
end;

procedure TIWformChat.IWAppFormCreate(Sender: TObject);
begin
  timerConversa.Tag := 1;
end;

procedure TIWformChat.IWAppFormShow(Sender: TObject);
begin
  if UserSession.MobilePC <> 'mobile' then
    timerMobile.Enabled := true;

  //Carrega informações da obra
  try
    UserSession.qryAux.Close;
    UserSession.qryAux.SQL.Clear;
    UserSession.qryAux.SQL.Add(' select LTRIM(RTRIM(isnull(b.Apelido,'''')))+'' (''+cast(a.Obra as varchar(10))+'')'' Apelido, LTRIM(RTRIM(isnull(c.Logradouro,'''')))+'',''+LTRIM(RTRIM(isnull(c.Numero,'''')))+'',''+LTRIM(RTRIM(isnull(c.Bairro,'''')))+'', ''+ ');
    UserSession.qryAux.SQL.Add(' 		    LTRIM(RTRIM(isnull(d.Nome,'''')))+'' - ''+d.UF Endereco, ');
    UserSession.qryAux.SQL.Add(' 	      case when LTRIM(RTRIM(isnull(e.Telefone,''''))) <> '''' then LTRIM(RTRIM(e.Telefone)) ');
    UserSession.qryAux.SQL.Add(' 		          when LTRIM(RTRIM(isnull(e.Telefone2,''''))) <> '''' then LTRIM(RTRIM(e.Telefone2)) ');
    UserSession.qryAux.SQL.Add(' 		          when LTRIM(RTRIM(isnull(e.Telefone3,''''))) <> '''' then LTRIM(RTRIM(e.Telefone3)) end Telefone, ');
    UserSession.qryAux.SQL.Add(' 		    ''Tel 1: '' + isnull(c.IAM_TelefoneEmergencia1,'''') + '' ('' + isnull(c.IAM_NomeTelefoneEmergencia1,'' '') + '') - '' + ');
    UserSession.qryAux.SQL.Add(' 		    ''Tel 2: '' + isnull(c.IAM_TelefoneEmergencia2,'''') + '' ('' + isnull(c.IAM_NomeTelefoneEmergencia2,'' '') + '') - '' + ');
    UserSession.qryAux.SQL.Add(' 		    ''Tel 3: '' + isnull(c.IAM_TelefoneEmergencia3,'''') + '' ('' + isnull(c.IAM_NomeTelefoneEmergencia3,'' '') + '')'' TelEmergencial ');
    UserSession.qryAux.SQL.Add(' from ( select Max(Codigo) Codigo from SmartBox.Atendimentos where Obra = :Obra ) z ');
    UserSession.qryAux.SQL.Add(' inner join SmartBox.Atendimentos a on a.Codigo = z.Codigo ');
    UserSession.qryAux.SQL.Add(' left outer join FichaTecnica.VShareVendas b on b.Obra = a.Obra ');
    UserSession.qryAux.SQL.Add(' left outer join Obras c on c.Seq = a.Obra ');
    UserSession.qryAux.SQL.Add(' left outer join Cidades d on d.Codigo = c.Cidade ');
    UserSession.qryAux.SQL.Add(' left outer join Clientes e on e.Codigo = c.Cliente ');
    UserSession.qryAux.ParamByName('Obra').AsInteger := UserSession.Obra;
    UserSession.qryAux.Open;

    if not UserSession.qryAux.IsEmpty then
    begin
      lblObraApelido.Caption           := UserSession.qryAux.Fields[0].AsString;
      lblEndereco.Caption              := UserSession.qryAux.Fields[1].AsString;
      lblTelefone.Caption              := UserSession.qryAux.Fields[2].AsString;
      lblTelefonesEmergenciais.Caption := UserSession.qryAux.Fields[3].AsString;
    end;
  except
  end;

  memMsgs.Close;
  memMsgs.Open;

  timerConversasAbertas.Enabled := true;
  timerShow.Enabled := true;
end;

procedure TIWformChat.memoMsgHTMLTag(ASender: TObject; ATag: TIWHTMLTag);
begin
  ATag.AddStringParam('style','height: 100px;');
end;

procedure TIWformChat.SolicitaPinOut;
var SQL : String;
begin
  try
    SQL := ' exec [SmartBox].[USP_LancaAcao] 0'+IntToStr(UserSession.Obra)+', ''Z'', ''PINOUT'' ';
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

procedure TIWformChat.timerCarregaHtmlAsyncTimer(Sender: TObject;
  EventParams: TStringList);
begin
  timerCarregaHtml.Enabled := false;

  WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA('carregaHtmls("'+Nome_CarregaHtml+'",'''+HTML_CarregaHtml+''');');
end;

procedure TIWformChat.timerConversaAsyncTimer(Sender: TObject;
  EventParams: TStringList);
var Quem       : String;
    SQL        : String;
    HTML       : String;
begin

  //Tenta conectar
  try
    if not UserSession.ConectarBD then
      WebApplication.ShowMessage('Não foi possível conectar no servidor! Tente mais tarde ou entre em contato com o suporte através do email no rodapé!');
  except
    WebApplication.ShowMessage('Não foi possível conectar no servidor! Tente mais tarde ou entre em contato com o suporte através do email no rodapé!');
  end;

  //faz a pesquisa
  UserSession.qryAux.Close;
  UserSession.qryAux.SQL.Clear;
  UserSession.qryAux.SQL.Add(' select Codigo, REPLACE(Texto,CHAR(13)+Char(10),''<br>'') Texto, Obra, QuemEnviou, convert(varchar(5),DTInsert,108) Hora, IIF( (DTLido_RBA is null) and (QuemEnviou = ''TABLET'') ,''1'',''0'') MarcarLido from SmartBox.SOSChat ');
  UserSession.qryAux.SQL.Add(' where Obra = 0'+IntToStr(UserSession.Obra));
  if timerConversa.Tag <= 1 then
    UserSession.qryAux.SQL.Add(' and DTInsert between DATEADD(HOUR,-12,GETDATE()) and Getdate() ')
  else
    UserSession.qryAux.SQL.Add(' and DTInsert between DATEADD(mi,-5,GETDATE()) and Getdate() ');

  UserSession.qryAux.SQL.Add(' order by Codigo ');

  try
    UserSession.qryAux.Open;

    if not UserSession.qryAux.IsEmpty then
    begin
      while not UserSession.qryAux.Eof do
      begin

        //Verifica se já carregou o audio
        if not memMsgs.Locate('Codigo',UserSession.qryAux.Fields[0].AsInteger,[]) then
        begin

          //Seta o valor de quem que é o audio
          Quem := UserSession.qryAux.Fields[3].AsString;
          if Quem = 'TABLET' then
            Quem := 'Obra '+UserSession.qryAux.Fields[2].AsString
          else
            Quem := 'RBA ELEVADORES';

          WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA('addChat("'+Quem+'","'+UserSession.qryAux.Fields[4].AsString+'","arquivo","'+UserSession.qryAux.Fields[1].AsString+'");');

          //Salva que foi lido e registra na tela o audio
          if UserSession.qryAux.Fields[5].AsString = '1' then
            UserSession.ExecutaSQL('update SmartBox.SOSChat set DTLido_RBA = getdate() where Codigo = 0'+UserSession.qryAux.Fields[0].AsString);

          memMsgs.Insert;
          memMsgsCodigo.AsInteger := UserSession.qryAux.Fields[0].AsInteger;
          memMsgs.Post;

        end;

        UserSession.qryAux.Next;
      end;

    end;
  except
  end;

  //A primeira vez passa girando todos só pra criar os arquivos, depois passa segunda vez em todos pra lançar na tela
  if timerConversa.Tag = 1 then
  begin
    timerConversa.Tag := 2;
    timerConversa.Interval := 3000;
  end;

  //Verifica se o cliente ainda esta online ou se encerrou o atendimento
  try
    SQL := ' select case when not (DTConcluido is null) then ''ATENDIMENTO ENCERRADO'' ELSE IIF(DATEDIFF(second,isnull(DTTabletOnline,''01/01/1990''),getdate())<=40,''ON-LINE'',''OFF-LINE'') END StatusTablet '+
           ' from SmartBox.Atendimentos where Codigo = 0'+IntToStr(UserSession.Atendimento);

    lblOnline.Caption := UserSession.RetornaSQL(SQL);
    if lblOnline.Caption = 'ON-LINE' then
      lblOnline.Css := 'text-success'
    else
      lblOnline.Css := 'text-danger';
  except
    lblOnline.Caption := 'OFF-LINE';
  end;

  //Atualiza a botoeira
  try
    HTML := UserSession.RetornaSQL(' exec SmartBox.USP_HTMLSOSBotoeira 0'+IntToStr(UserSession.Obra));
    if HTML <> '' then
      WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA('carregaHtmls("Botoeira",'''+HTML+''');');
  except
  end;

  //Atualiza as acoes pendentes
  try
    HTML := UserSession.RetornaSQL(' exec SmartBox.USP_HTMLSOSAcoesPendentes 0'+IntToStr(UserSession.Obra));
    WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA('carregaHtmls("AcoesPendentes",'''+HTML+''');');
  except
  end;
end;

procedure TIWformChat.timerConversasAbertasAsyncTimer(Sender: TObject;
  EventParams: TStringList);
var HTML : String;
begin
  timerConversasAbertas.Enabled := false;

  try
    UserSession.qryAux.Close;
    UserSession.qryAux.SQL.Clear;
    UserSession.qryAux.SQL.Add(' exec SmartBox.USP_HTMLAtendimentosUsuario :CodUsuario');
    UserSession.qryAux.ParamByName('CodUsuario').AsInteger := UserSession.CodUsuario;
    UserSession.qryAux.Open;

    if not UserSession.qryAux.IsEmpty then
    begin
      HTML := '';
      HTML := UserSession.qryAux.Fields[0].AsString;

      Nome_CarregaHtml         := 'conversasabertas';
      HTML_CarregaHtml         := HTML;
      timerCarregaHtml.Enabled := true;
    end;
  except
  end;

  timerConversasAbertas.Enabled := true;
end;

procedure TIWformChat.timerManualCabineiroAsyncTimer(Sender: TObject;
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
    UserSession.qryAux2.ParamByName('Obra').AsInteger := UserSession.Obra;

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

procedure TIWformChat.timerManualCabineiroSobeDesceAsyncTimer(Sender: TObject;
  EventParams: TStringList);
var SQL  : String;
begin
  timerManualCabineiroSobeDesce.Enabled := false;

  try
    SQL := ' exec [SmartBox].[USP_LancaAcao] 0'+IntToStr(UserSession.Obra)+', ''m'+IntToStr(timerManualCabineiroSobeDesce.Tag)+''', ''ACAO'' ';
    UserSession.ExecutaSQL(SQL);
  except
  end;

  //a cada 1 segundo +- pede pinout junto
  btnPinOut.Tag := btnPinOut.Tag + 1;
  if btnPinOut.Tag >= 10 then
  begin
    //SolicitaPinOut;

    btnPinOut.Tag := 1;
  end;

  timerManualCabineiroSobeDesce.Enabled := true;
end;

procedure TIWformChat.timerMobileAsyncTimer(Sender: TObject;
  EventParams: TStringList);
begin
  timerMobile.Enabled := false;

  WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA('EscondeSideBar();');
end;

procedure TIWformChat.timerOnlineAsyncTimer(Sender: TObject;
  EventParams: TStringList);
begin
  //Marca a dataOnline do usuário, se estiver logado
  UserSession.UsuarioDataOnline;
end;

procedure TIWformChat.timerShowAsyncTimer(Sender: TObject;
  EventParams: TStringList);
var Comando : String;
    Tipo    : String;
    Texto   : String;
begin
  timerShow.Enabled := false;

  Tipo  := UserSession.RetornaSQL(' select Tipo from SmartBox.Atendimentos where Codigo = 0'+IntToStr(UserSession.Atendimento));
  Texto := UserSession.RetornaSQL(' select Observacao from SmartBox.Atendimentos where Codigo = 0'+IntToStr(UserSession.Atendimento));

  edtObservacao.Text := texto;

  Comando := ' mostrarDivs(';
  if Tipo = 'TICKET' then
    Comando := Comando + '1 '
  else
    Comando := Comando + '0';
  Comando := Comando + ');';

  //Thiago, Marcus
  if UserSession.CodUsuario in [6,136] then
    Comando := Comando + ' document.getElementById(''ADM'').style.display = "block"; ';

  WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(Comando);
end;

end.
