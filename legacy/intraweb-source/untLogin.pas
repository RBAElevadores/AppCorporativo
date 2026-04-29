unit untLogin;

interface

uses
  Classes, SysUtils, IWAppForm, IWApplication, IWColor, IWTypes, Vcl.Controls,
  IWVCLBaseControl, IWBaseControl, IWBaseHTMLControl, IWControl, IWCompLabel,
  IWCompEdit, IWCompButton, IWVCLComponent, IWBaseLayoutComponent,
  IWBaseContainerLayout, IWContainerLayout, IWTemplateProcessorHTML, IWHTMLTag,
  IWBaseComponent, IWBaseHTMLComponent, IWBaseHTML40Component, IWCompExtCtrls;

type
  TIWformLogin = class(TIWAppForm)
    IWLabel1: TIWLabel;
    edtNick: TIWEdit;
    IWLabel2: TIWLabel;
    edtSenha: TIWEdit;
    btnEntrar: TIWButton;
    IWTemplateProcessorHTML1: TIWTemplateProcessorHTML;
    timerMobilePC: TIWTimer;
    edtMobilePC: TIWEdit;
    edtVaiProMain: TIWEdit;
    btnAcessoThiago: TIWButton;
    procedure btnEntrarAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure edtSenhaHTMLTag(ASender: TObject; ATag: TIWHTMLTag);
    procedure btnEntrarHTMLTag(ASender: TObject; ATag: TIWHTMLTag);
    procedure edtNickHTMLTag(ASender: TObject; ATag: TIWHTMLTag);
    procedure timerMobilePCAsyncTimer(Sender: TObject;
      EventParams: TStringList);
    procedure edtNickAsyncKeyPress(Sender: TObject; EventParams: TStringList);
    procedure IWAppFormShow(Sender: TObject);
    procedure btnAcessoThiagoAsyncClick(Sender: TObject;
      EventParams: TStringList);
  public
  end;

implementation
  Uses ServerController, untPrincipal;
{$R *.dfm}

procedure TIWformLogin.btnAcessoThiagoAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  edtNick.Text  := 'thiago';
  edtSenha.Text := 'mcse123';

  btnEntrarAsyncClick(nil,nil);
end;

procedure TIWformLogin.btnEntrarAsyncClick(Sender: TObject;
  EventParams: TStringList);
Var CodUsuario : String;
    SQL        : String;
begin
  //Verifica se preencheu os campos
  if TRIM(edtNick.Text) = '' then
  begin
    WebApplication.ShowMessage('Preencha seu Nick antes de entrar!');
    Exit;
  end;

  if TRIM(edtSenha.Text) = '' then
  begin
    WebApplication.ShowMessage('Preencha sua Senha antes de entrar!');
    Exit;
  end;

  //Verifica se existe um usuario com esse Nick e senha
  CodUsuario := '';
  SQL        := ' select a.Codigo from Usuarios a '+
                ' left outer join Clientes b on b.Codigo = a.CodCli '+
                ' where ((a.Nick = '''+TRIM(edtNick.Text)+''') or (b.CPFCNPJ = '''+TRIM(edtNick.Text)+''')) ' +
                ' and Senha = '''+TRIM(edtSenha.Text)+''' ';
  CodUsuario := UserSession.RetornaSQL(SQL);
  if CodUsuario = '' then
  begin
    WebApplication.ShowMessage('Usuário não encontrado!');
    Exit;
  end;

  //Salva o código do usuário e empresa na sessão
  UserSession.CodUsuario := StrToInt(CodUsuario);
  //UserSession.CodEmpresa := StrToInt('0'+UserSession.RetornaSQL('select Empresa from Usuarios where Codigo = '+CodUsuario));

  SQL := ' select EmpresaSistema from Usuarios '+
         ' where Codigo = 0'+CodUsuario;
  try
    UserSession.EmpresaSistema := StrToInt(UserSession.RetornaSQL(SQL));
  except
  end;

  SQL := ' select Departamento from Usuarios where Codigo = 0'+CodUsuario;
  try
    UserSession.Departamento := StrToInt(UserSession.RetornaSQL(SQL));
  except
  end;

  //Abre o Main
  UserSession.AbreForm('TIWformMain');

  if UserSession.PCodAtendimento > 0 then
  begin
    //Vai para a tela Principal
    UserSession.AbreForm('TIWformPrincipal');
  end;

  //Fecha a tela de Login
  Release;
end;

procedure TIWformLogin.btnEntrarHTMLTag(ASender: TObject; ATag: TIWHTMLTag);
begin
  ATag.AddStringParam('type','submit');
end;

procedure TIWformLogin.edtNickAsyncKeyPress(Sender: TObject;
  EventParams: TStringList);
begin
  if EventParams.Values['which'] = '13' then
    edtNick.SetFocus;
end;

procedure TIWformLogin.edtNickHTMLTag(ASender: TObject; ATag: TIWHTMLTag);
begin
  ATag.AddStringParam('placeholder','Nick');
end;

procedure TIWformLogin.edtSenhaHTMLTag(ASender: TObject; ATag: TIWHTMLTag);
begin
  ATag.AddStringParam('placeholder','Senha');
  ATag.AddStringParam('type','password');
end;

procedure TIWformLogin.IWAppFormShow(Sender: TObject);
var Parametro  : String;
    Aux        : String;
    CodUsuario : Integer;
    Versao     : String;

    Token      : String;
begin
  UserSession.PCodAtendimento := 0;
  UserSession.IDNotificacao   := -1;
  CodUsuario                  := 0;
  Versao                      := '';

  edtVaiProMain.Text := '';

  // Tenta pegar informação para ATENDIMENTOD DE SOS
  try
    Parametro := WebApplication.Request.QueryFields.Values['idobra'];
    if TRIM(Parametro) <> '' then
      UserSession.PCodAtendimento := StrToInt(Parametro);
  except
    UserSession.PCodAtendimento := 0;
  end;

  // Verifica se é LOGIN direto de usuário ou de terceiros
  try
    Aux        := WebApplication.Request.QueryFields.Values['codusuario'];
    if Aux <> '' then
      CodUsuario := StrToInt(Aux);
  except
    CodUsuario := 0;
  end;

  // Verifica se está abrindo pelo APP através de NOTIFICAÇÃO
  aux := '';
  try
    Aux        := WebApplication.Request.QueryFields.Values['idnotificacao'];
    if Aux <> '' then
      UserSession.IDNotificacao := StrToInt(Aux);
  except on E:Exception do
   begin
     WebApplication.ShowMessage(e.Message);
     UserSession.IDNotificacao := -1;
   end;
  end;

  //Tenta pegar a Versao do app
  try
    Versao := WebApplication.Request.QueryFields.Values['versao'];
    if (Versao <> '') and (CodUsuario > 0) then
      UserSession.ExecutaSQL(' update Usuarios set VersaoAppCorporativo = 0'+Versao+' where Codigo = 0'+IntToStr(CodUsuario));
  except
    Versao := '';
  end;

  if CodUsuario = -1 then
  begin
    Token := '';
    Token := WebApplication.Request.QueryFields.Values['token'];

    if Token <> '' then
    begin
      //Salva o código do token do dispositivo do terceiro
      UserSession.TokenTerceiro := Token;

      //Abre o Main do pessoal terceiro
      UserSession.AbreForm('TIWformMainRestrito');

      //Fecha a tela de Login
      Release;
    end;
  end
  else if CodUsuario > 0 then
  begin
    //Salva o código do usuário e empresa na sessão
    UserSession.CodUsuario := CodUsuario;

    //Abre o Main
    UserSession.AbreForm('TIWformMain');

    //Fecha a tela de Login
    Release;
  end
  else
    edtVaiProMain.Text := '1';
end;

procedure TIWformLogin.timerMobilePCAsyncTimer(Sender: TObject;
  EventParams: TStringList);
begin
  timerMobilePC.Enabled := false;

  UserSession.MobilePC  := edtMobilePC.Text;
end;

initialization
  TIWformLogin.SetAsMainForm;

end.
