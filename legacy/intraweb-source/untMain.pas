unit untMain;

interface

uses
  Classes, SysUtils, IWAppForm, IWApplication, IWColor, IWTypes,
  IWBaseComponent, IWBaseHTMLComponent, IWBaseHTML40Component, IWCompExtCtrls,
  IWVCLComponent, IWBaseLayoutComponent, IWBaseContainerLayout,
  IWContainerLayout, IWTemplateProcessorHTML, Vcl.Controls, IWVCLBaseControl,
  IWBaseControl, IWBaseHTMLControl, IWControl, IWCompButton, IWCompLabel,
  DateUtils, IWCompEdit;

type
  TIWformMain = class(TIWAppForm)
    IWTemplateProcessorHTML1: TIWTemplateProcessorHTML;
    timerCarregaHtml: TIWTimer;
    btnClientes: TIWButton;
    btnIAMOnline: TIWButton;
    btnSOS: TIWButton;
    lblBemVindo: TIWLabel;
    btnSair: TIWButton;
    timerInicio: TIWTimer;
    btnSuporteTecnico: TIWButton;
    btnSenhaMaster: TIWButton;
    btnPlantonistasSOS: TIWButton;
    btnFichaTecnica: TIWButton;
    btnNotificacoes: TIWButton;
    btnOS: TIWButton;
    btnEntregaTecnica: TIWButton;
    btnVistorias: TIWButton;
    btnHolerites: TIWButton;
    btnQuery: TIWButton;
    btnAcoesEspeciais: TIWButton;
    btnRamais: TIWButton;
    edtToken: TIWEdit;
    btnToken: TIWButton;
    btnIndices: TIWButton;
    BtnAbrirSAC: TIWButton;
    procedure timerCarregaHtmlAsyncTimer(Sender: TObject;
      EventParams: TStringList);
    procedure btnSOSAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure IWAppFormRender(Sender: TObject);
    procedure btnClientesAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure btnSairAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure btnIAMOnlineAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure timerInicioAsyncTimer(Sender: TObject; EventParams: TStringList);
    procedure btnSuporteTecnicoAsyncClick(Sender: TObject;
      EventParams: TStringList);
    procedure btnSenhaMasterAsyncClick(Sender: TObject;
      EventParams: TStringList);
    procedure btnPlantonistasSOSAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure btnFichaTecnicaAsyncClick(Sender: TObject;
      EventParams: TStringList);
    procedure btnNotificacoesAsyncClick(Sender: TObject;
      EventParams: TStringList);
    procedure btnOSAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure btnEntregaTecnicaAsyncClick(Sender: TObject;
      EventParams: TStringList);
    procedure btnVistoriasAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure btnHoleritesAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure btnQueryAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure btnAcoesEspeciaisAsyncClick(Sender: TObject;
      EventParams: TStringList);
    procedure btnRamaisAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure btnTokenAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure btnIndicesAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure BtnAbrirSACAsyncClick(Sender: TObject; EventParams: TStringList);
  public
    Nome_CarregaHtml : String;
    HTML_CarregaHtml : String;

    procedure Abrindo;
  end;

implementation
Uses ServerController;

{$R *.dfm}


procedure TIWformMain.Abrindo;
var TipoNotificacao : String;
begin
  if UserSession.IDNotificacao > 0 then
  begin
    TipoNotificacao := UserSession.RetornaSQL(' select Tipo from SmartBox.Corporativo_Notificacoes '+
                    ' where Seq = 0'+IntToStr(UserSession.IDNotificacao));

    UserSession.TipoNotificacao := TipoNotificacao;
    if TipoNotificacao = 'Autorizar Ficha' then
    begin
      UserSession.AbreForm('TIWformFichaTecnica');
      Release;
    end
    else if TipoNotificacao = 'Autorizar OS' then
    begin
      UserSession.AbreForm('TIWformOS');
      Release;
    end
    else
    begin
      UserSession.AbreForm('TIWformNotificacoes');
      Release;
    end;
  end;

  //Mensagem bem vindo
  lblBemVindo.Caption := UserSession.RetornaSQL('select UPPER(Nome) from Usuarios where Codigo = '+IntToStr(UserSession.CodUsuario))+'!';

  //Mostra mensagem de aguarde
  WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA('mensagem("Carregando o Menu","<strong> <font color=''#172e63''> Aguarde... </font> </strong>",0,0,1);');

  timerInicio.Enabled := true;
end;

procedure TIWformMain.BtnAbrirSACAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  if not UserSession.VerPermissao('App Corporativo: Abrir Sac','V',true) then
    Exit;

  UserSession.AbreForm('TIWformAbrirSac');

  Release;
end;

procedure TIWformMain.btnAcoesEspeciaisAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  if not UserSession.VerPermissao('App Corporativo: TI: Acoes Especiais','V',true) then
    Exit;

  UserSession.AbreForm('TIWformAcoesEspeciais');

  Release;
end;

procedure TIWformMain.btnClientesAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  if not UserSession.VerPermissao('App Corporativo: Clientes','V',true) then
    Exit;

  UserSession.AbreForm('TIWformClientes');

  Release;
end;

procedure TIWformMain.btnEntregaTecnicaAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  if UserSession.EmpresaSistema = 1 then
  begin
    if not UserSession.VerPermissao('App Corporativo: Gerencial: Entrega Técnica','V',true) then
      Exit;
  end;

  UserSession.AbreForm('TIWformEntregaTecnica');

  Release;
end;

procedure TIWformMain.btnFichaTecnicaAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  if not UserSession.VerPermissao('Cadastro: Fichas Técnicas','V',true) then
    Exit;

  WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(' console.log("download https://arquivos.rbaelevadores.com.br/Arquivos/HTMLExe/Orcamentos.html"); ');

  //UserSession.AbreForm('TIWformFichaTecnica');

  //Release;
end;

procedure TIWformMain.btnHoleritesAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  UserSession.AbreForm('TIWformHolerites');

  Release;
end;

procedure TIWformMain.btnIAMOnlineAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  if not (
            (UserSession.VerPermissao('IAM: IAM Online','V',true))
            or (UserSession.Departamento in [15,18])
          ) then
    Exit;

  UserSession.IAMSOS := 0;

  UserSession.AbreForm('TIWformIAMOnline');

  Release;
end;

procedure TIWformMain.btnIndicesAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  UserSession.AbreForm('TIWformIndices');

  Release;
end;

procedure TIWformMain.btnNotificacoesAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  UserSession.AbreForm('TIWformNotificacoes');

  Release;
end;

procedure TIWformMain.btnOSAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  if not UserSession.VerPermissao('App Corporativo: Aprovação de O.S. de Manutenção','V',true) then
    Exit;

  UserSession.AbreForm('TIWformOS');

  Release;
end;

procedure TIWformMain.btnSairAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  UserSession.AbreForm('TIWformLogin');

  Release;
end;

procedure TIWformMain.btnSenhaMasterAsyncClick(Sender: TObject;
  EventParams: TStringList);
var Alfabeto  : String;
    Resultado : Integer;
    R         : String;
    Senha     : String;
    Letra     : String;

    I         : Integer;
begin
  if not (
            (UserSession.VerPermissao('IAM: Senha Acesso','V',true))
            or (UserSession.Departamento = 15)
          ) then
    Exit;

  //Monta a senha
  Alfabeto  := 'ZYXWVUTSRQPONMLKJIHGFEDCBA';
  Resultado := (DayOf(date)+MonthOf(date)+YearOf(date))*DayOf(date);
  R         := Copy(IntToStr(Resultado),LENGTH(IntToStr(Resultado))-3,4);

  for I := 1 to Length(R) do
  begin
    if ((I mod 2) = 0) then
      Senha := Senha + COPY(R,I,1)
    else
    begin
      if StrToInt(COPY(R,I,1)) = 0 then
        Letra := '0'
      else
        Letra := COPY(Alfabeto, StrToInt(COPY(R,I,1)), 1);

      Senha := Senha + Letra;
    end;
  end;

  WebApplication.ShowMessage('Senha do Dia:'+#13+#10+Senha);
end;

procedure TIWformMain.btnSOSAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  if not UserSession.VerPermissao('App Corporativo: Suporte: SOS / TICKETS','V',true) then
    Exit;

  UserSession.AbreForm('TIWformPrincipal');

  Release;
end;

procedure TIWformMain.btnSuporteTecnicoAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  if not (
            (UserSession.VerPermissao('App Corporativo: Suporte: Orientações','V',true))
            or (UserSession.Departamento in [15,18])
          ) then
    Exit;

  UserSession.AbreForm('TIWformSuporteTecnico');

  Release;
end;

procedure TIWformMain.btnTokenAsyncClick(Sender: TObject;
  EventParams: TStringList);
var SQL : String;
    Token : String;
begin
  if Trim(edtToken.Text) = '' then
    Exit;

  try
    SQL := ' select TokenAppCorporativo from Usuarios where Codigo = 0'+IntToStr(UserSession.CodUsuario);
    Token := UserSession.RetornaSQL(SQL);

    if Token = '' then
    begin
      WebApplication.ShowNotification('Houve algum problema na geração do token!',TIWNotifyType.ntError);
      Exit;
    end;

    if Token <> edtToken.Text then
    begin
      WebApplication.ShowNotification('Token inválido!',TIWNotifyType.ntLog);
      Exit;
    end;


    SQL := ' update Usuarios set TokenAppCorporativo = null, DtTokenAppCorporativo = getdate() where Codigo = 0'+IntToStr(UserSession.CodUsuario);
    UserSession.ExecutaSQL(SQL);

    WebApplication.ShowNotification('Token autenticado com sucesso!',TIWNotifyType.ntSuccess);

    Abrindo;
  except
  end;
end;

procedure TIWformMain.IWAppFormRender(Sender: TObject);
begin
  Abrindo;
end;

procedure TIWformMain.btnVistoriasAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  if not UserSession.VerPermissao('App Corporativo: Gerencial: Vistorias','V',true) then
    Exit;

  UserSession.AbreForm('TIWformVistorias');

  Release;
end;

procedure TIWformMain.btnPlantonistasSOSAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  if not UserSession.VerPermissao('IAM: I AM - Telefones de Plantão','V',true) then
    Exit;

  UserSession.AbreForm('TIWformPlantonistasSOS');

  Release;
end;

procedure TIWformMain.btnQueryAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  if not UserSession.VerPermissao('App Corporativo: TI: Query','V',true) then
    Exit;

  UserSession.AbreForm('TIWformQuery');

  Release;
end;

procedure TIWformMain.btnRamaisAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  UserSession.AbreForm('TIWformRamais');

  Release;
end;

procedure TIWformMain.timerCarregaHtmlAsyncTimer(Sender: TObject;
  EventParams: TStringList);
begin
  timerCarregaHtml.Enabled := false;

  WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA('carregaHtmls("'+Nome_CarregaHtml+'",'''+HTML_CarregaHtml+''');');
end;

procedure TIWformMain.timerInicioAsyncTimer(Sender: TObject;
  EventParams: TStringList);
var SQL, Ret : String;
begin
  timerInicio.Enabled := false;

  try
    SQL := ' exec [SmartBox].[USP_HTMLTecnicoOnlineMainMenu] 0'+IntToStr(UserSession.CodUsuario);
    Ret := UserSession.RetornaSQL(SQL);

    WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(Ret);
  except
    WebApplication.ShowNotification('Houve algum problema ao carregar os Menus!',TIWNotifyType.ntError);
  end;
end;

end.
