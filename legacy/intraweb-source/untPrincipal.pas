unit untPrincipal;

interface

uses
  Classes, SysUtils, IWAppForm, IWApplication, IWColor, IWTypes, IWVCLComponent,
  IWBaseLayoutComponent, IWBaseContainerLayout, IWContainerLayout,
  IWTemplateProcessorHTML, Vcl.Controls, IWVCLBaseControl, IWBaseControl,
  IWBaseHTMLControl, IWControl, IWCompExtCtrls, Data.DB, MemDS, DBAccess, Uni,
  IWCompLabel, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, IWCompGrids, IWDBGrids,
  IWHTMLControls, MSHTML, IWCompButton, IWCompEdit, IWCompSilverlight,
  IWBaseComponent, IWBaseHTMLComponent, IWBaseHTML40Component;

type
  TIWformPrincipal = class(TIWAppForm)
    IWTemplateProcessorHTML1: TIWTemplateProcessorHTML;
    timerOnline: TIWTimer;
    btnAlterarSenha: TIWButton;
    lblBemVindo: TIWLabel;
    timerCarregaHtml: TIWTimer;
    edtAtendimento: TIWEdit;
    btnAtender: TIWButton;
    timerConversasAbertas: TIWTimer;
    timerAtendimentos: TIWTimer;
    timerMobile: TIWTimer;
    btnVoltar: TIWButton;
    procedure timerOnlineAsyncTimer(Sender: TObject; EventParams: TStringList);
    procedure IWAppFormShow(Sender: TObject);
    procedure btnAlterarSenhaClick(Sender: TObject);
    procedure timerCarregaHtmlAsyncTimer(Sender: TObject;
      EventParams: TStringList);
    procedure btnAtenderAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure timerConversasAbertasAsyncTimer(Sender: TObject;
      EventParams: TStringList);
    procedure timerAtendimentosAsyncTimer(Sender: TObject; EventParams: TStringList);
    procedure IWAppFormRender(Sender: TObject);
    procedure timerMobileAsyncTimer(Sender: TObject; EventParams: TStringList);
    procedure btnVoltarAsyncClick(Sender: TObject; EventParams: TStringList);
  public
    Nome_CarregaHtml : String;
    HTML_CarregaHtml : String;
    {procedures/functions}
    procedure Abrindo;
  end;

implementation
Uses ServerController;
{$R *.dfm}

procedure TIWformPrincipal.timerCarregaHtmlAsyncTimer(Sender: TObject;
  EventParams: TStringList);
begin
  timerCarregaHtml.Enabled := false;

  WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA('carregaHtmls("'+Nome_CarregaHtml+'",'''+HTML_CarregaHtml+''');');
end;

procedure TIWformPrincipal.timerConversasAbertasAsyncTimer(Sender: TObject;
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

procedure TIWformPrincipal.timerMobileAsyncTimer(Sender: TObject;
  EventParams: TStringList);
begin
  timerMobile.Enabled := false;

  WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA('EscondeSideBar();');
end;

procedure TIWformPrincipal.timerAtendimentosAsyncTimer(Sender: TObject;
  EventParams: TStringList);
var HTML : String;
begin
  timerAtendimentos.Enabled := false;

  if timerAtendimentos.Interval = 1000 then
    timerAtendimentos.Interval := 15000;

  if not UserSession.ConectarBD then
  begin
    WebApplication.ShowMessage('Não foi possível conectar ao servidor! Por favor tente novamente, caso o problema continue entre em contato conosco pelo e-mail no rodapé!');
    timerAtendimentos.Enabled := true;

    Exit;
  end;

  UserSession.qryAux.Close;
  UserSession.qryAux.SQL.Clear;
  UserSession.qryAux.SQL.Add(' exec SmartBox.USP_HTMLAtendimentos ');
  try
    UserSession.qryAux.Open;

    if UserSession.qryAux.IsEmpty then
    begin
      WebApplication.ShowMessage('Nenhuma informação encontrada dos atendimentos! Tente novamente!');
      Exit;
    end;

    HTML := '';
    HTML := UserSession.qryAux.Fields[0].AsString;

    Nome_CarregaHtml         := 'atendimentos';
    HTML_CarregaHtml         := HTML;
    timerCarregaHtml.Enabled := true;
  except
    WebApplication.ShowMessage('Houve um erro ao carregar os atendimentos! Tente novamente.');
  end;

  timerAtendimentos.Enabled := true;
end;

procedure TIWformPrincipal.timerOnlineAsyncTimer(Sender: TObject;
  EventParams: TStringList);
begin
  //Marca a dataOnline do usuário, se estiver logado
  UserSession.UsuarioDataOnline;
end;

procedure TIWformPrincipal.Abrindo;
begin
  if UserSession.MobilePC <> 'mobile' then
    timerMobile.Enabled := true;

  //Marca a dataOnline do usuário, se estiver logado
  UserSession.UsuarioDataOnline;

  //Mensagem bem vindo
  lblBemVindo.Caption := UserSession.RetornaSQL('select UPPER(Nome) from Usuarios where Codigo = '+IntToStr(UserSession.CodUsuario))+'!';

  timerAtendimentos.Interval := 1000;
  timerAtendimentos.Enabled  := true;

  timerConversasAbertas.Enabled := true;

  if UserSession.PCodAtendimento > 0 then
  begin
    edtAtendimento.Text         := IntToStr(UserSession.PCodAtendimento);
    UserSession.PCodAtendimento := 0;

    btnAtenderAsyncClick(nil,nil);
  end;
end;

procedure TIWformPrincipal.btnAlterarSenhaClick(Sender: TObject);
begin
  UserSession.AbreForm('TIWformAlterarSenha');
end;

procedure TIWformPrincipal.btnAtenderAsyncClick(Sender: TObject;
  EventParams: TStringList);
var SQL : String;
begin
  if TRIM(edtAtendimento.Text) = '' then
    Exit;

  try
    //Registra que começou o atendimento
    SQL := ' if exists( select 1 aux from SmartBox.Atendimentos where Codigo = 0'+edtAtendimento.Text+' and DTInicioAtendimento is null ) '+
	         '   update SmartBox.Atendimentos set DTInicioAtendimento = getdate(), QuemInicioAtendimento = 0'+IntToStr(UserSession.CodUsuario)+' where Codigo = 0'+edtAtendimento.Text;
    UserSession.ExecutaSQL(SQL);

    UserSession.Atendimento := 0;

    UserSession.Obra        := StrToInt( '0'+UserSession.RetornaSQL(' select Obra from SmartBox.Atendimentos where Codigo = 0'+edtAtendimento.Text) );
    UserSession.Atendimento := StrToInt(edtAtendimento.Text);
  except
    Exit;
  end;

  UserSession.AbreForm('TIWformChat');
end;

procedure TIWformPrincipal.IWAppFormRender(Sender: TObject);
begin
  Abrindo;
end;

procedure TIWformPrincipal.IWAppFormShow(Sender: TObject);
begin
  Abrindo;
end;

procedure TIWformPrincipal.btnVoltarAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  UserSession.AbreForm('TIWformMain');

  Release;
end;

end.
