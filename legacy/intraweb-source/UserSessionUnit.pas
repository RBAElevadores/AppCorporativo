unit UserSessionUnit;

{
  This is a DataModule where you can add components or declare fields that are specific to
  ONE user. Instead of creating global variables, it is better to use this datamodule. You can then
  access the it using UserSession.
}
interface

uses
  IWUserSessionBase, SysUtils, Classes, UniProvider, SQLServerUniProvider,
  Data.DB, DBAccess, Uni, MemDS, IWBaseComponent, IWBaseHTMLComponent,
  IWBaseHTML40Component, IWCompExtCtrls, Vcl.ExtCtrls, DateUtils,
  MySQLUniProvider,

  IWAppForm, IWApplication, IWColor, IWTypes, IWHTMLTag,
  Vcl.Controls, IWVCLBaseControl, IWBaseControl, IWBaseHTMLControl, IWControl,
  IWCompButton, IWVCLComponent, IWBaseLayoutComponent, IWBaseContainerLayout,
  IWContainerLayout, IWTemplateProcessorHTML, IWCompEdit, IWCompCheckbox,
  IWCompLabel;

type
  TIWUserSession = class(TIWUserSessionBase)
    uniconn: TUniConnection;
    qryAux: TUniQuery;
    qryRetornaSQL: TUniQuery;
    qryExecuta: TUniQuery;
    qryAux2: TUniQuery;
    SQLServerUniProvider1: TSQLServerUniProvider;
    qryLogos: TUniQuery;
    qryLogosEmpresa: TIntegerField;
    qryLogosLogoIAM_FundoEscuro: TBlobField;
    qryLogosLogoIAM_FundoClaro: TBlobField;

  private
    { Private declarations }
  public
    MobilePC             : String;
    CodUsuario           : Integer;
    CodEmpresa           : Integer;
    Departamento         : Integer;
    EmpresaSistema       : Integer;

    Obra                 : Integer;
    Atendimento          : Integer;
    IAMSOS               : Integer;
    IDNotificacao        : Integer;

    PCodAtendimento      : Integer;

    TipoNotificacao      : String;
    TokenTerceiro        : String;

    { Public declarations }
    function RetornaSQL(SQL:String):String;
    procedure ExecutaSQL(SQL:String);
    procedure UsuarioDataOnline;
    function ConectarBD : Boolean;
    procedure DesconectarBD;
    procedure AbreForm(Classe: String);
    function VerPermissao(DescricaoPermissao,TipoPermissao: string;ExibeMensagem:Boolean=False) : boolean;
  end;

implementation
Uses untPrincipal, untChat, untSuporteTecnico, untMain, untClientes,
  untLogin, untMainRestrito, untIAMOnline, untPlantonistasSOS, untFichaTecnica,
  untNotificacoes, untOS, untEntregaTecnica, untVistorias, untHolerites, untQuery,
  untAcoesEspeciais, untRamais, untIndices, untAbrirSac;

{%CLASSGROUP 'System.Classes.TPersistent'}

function TIWUserSession.VerPermissao(DescricaoPermissao,TipoPermissao: string;ExibeMensagem:Boolean=False) : boolean;
begin
  if TipoPermissao = 'V' then
    TipoPermissao := 'Visualizar'
  else if TipoPermissao = 'A' then
    TipoPermissao := 'Alterar'
  else if TipoPermissao = 'E' then
    TipoPermissao := 'Excluir'
  else if TipoPermissao = 'I' then
    TipoPermissao := 'Incluir';

  if CodUsuario in [6,136] then //Thiago / Marcus
  begin
   Result := true;
   ExecutaSQL('if not exists(select 1 from Permissoes.Permissao where ltrim(rtrim(Descricao)) = '+QuotedStr(DescricaoPermissao)+')'+
               '    insert into Permissoes.Permissao(Descricao)values('+QuotedStr(DescricaoPermissao)+')');
  end
  else
   Result := RetornaSQL('if exists(select 1 from Permissoes.UsuarioPermissao where CodPermissao = (select CodPermissao from Permissoes.Permissao where Descricao = '+QuotedStr(DescricaoPermissao)+')'
   +' and CodUsuario = '+IntToStr(CodUsuario)+' and '+TipoPermissao+' = 1) select 1 else select 0') = '1';

  if (not Result)  then
  begin
    if ExibeMensagem then
      WebApplication.ShowNotification('Você não possui permissão para: '+DescricaoPermissao,TIWNotifyType.ntError);

    ExecutaSQL('if not exists(select 1 from Permissoes.Permissao where ltrim(rtrim(Descricao)) = '+QuotedStr(DescricaoPermissao)+')'+
               '    insert into Permissoes.Permissao(Descricao)values('+QuotedStr(DescricaoPermissao)+')');
  end;
end;

function TIWUserSession.RetornaSQL(SQL:String):String;
begin
  Result := '';

  //Tenta conectar
  try
    if not ConectarBD then
    begin
      if not ConectarBD then
      begin
        WebApplication.ShowMessage('Não foi possível conectar no servidor! Tente mais tarde ou entre em contato com o suporte através do email no rodapé!');
        Exit;
      end;
    end;
  except
   begin
     WebApplication.ShowMessage('Não foi possível conectar no servidor! Tente mais tarde ou entre em contato com o suporte através do email no rodapé!');
     Exit;
   end;
  end;

  qryRetornaSQL.Close;
  qryRetornaSQL.SQL.Clear;
  qryRetornaSQL.SQL.Add(SQL);
  try
    qryRetornaSQL.Open;
    Result := qryRetornaSQL.Fields[0].AsString;
  Except
    Result := '';
  end;

  //Fecha qry e desconecta bando
  qryRetornaSQL.Close;
  //DesconectarBD;
end;

procedure TIWUserSession.ExecutaSQL(SQL:String);
begin
  //Tenta conectar
  try
    if not ConectarBD then
    begin
      if not ConectarBD then
        WebApplication.ShowMessage('Não foi possível conectar no servidor! Tente mais tarde ou entre em contato com o suporte através do email no rodapé!');
    end;
  except
    WebApplication.ShowMessage('Não foi possível conectar no servidor! Tente mais tarde ou entre em contato com o suporte através do email no rodapé!');
  end;

  qryExecuta.Close;
  qryExecuta.SQL.Clear;
  qryExecuta.SQL.Add(SQL);
  try
    qryExecuta.ExecSQL;
  Except
  end;

  //Fecha qry e desconecta bando
  qryExecuta.Close;
  //DesconectarBD;
end;

procedure TIWUserSession.UsuarioDataOnline;
begin
  if CodUsuario > 0 then
  begin
    try
      ExecutaSQL('update Usuarios set TecnicoOnline_DTOnline = GETDATE() where Codigo = '+IntToStr(CodUsuario));
    finally
    end;
  end;
end;

procedure TIWUserSession.AbreForm(Classe: String);
var Form : TComponent;
begin
  Form := WebApplication.FindFormByClassName(Classe);
  if Form <> nil then
  begin
    if UpperCase(Classe) = UpperCase('TIWformPrincipal') then
      (Form as TIWformPrincipal).Show
    else if UpperCase(Classe) = UpperCase('TIWformChat') then
      (Form as TIWformChat).Show
    else if UpperCase(Classe) = UpperCase('TIWformSuporteTecnico') then
      (Form as TIWformSuporteTecnico).Show
    else if UpperCase(Classe) = UpperCase('TIWformMain') then
      (Form as TIWformMain).Show
    else if UpperCase(Classe) = UpperCase('TIWformClientes') then
      (Form as TIWformClientes).Show
    else if UpperCase(Classe) = UpperCase('TIWformLogin') then
      (Form as TIWformLogin).Show
    else if UpperCase(Classe) = UpperCase('TIWformMainRestrito') then
      (Form as TIWformMainRestrito).Show
    else if UpperCase(Classe) = UpperCase('TIWformIAMOnline') then
      (Form as TIWformIAMOnline).Show
    else if UpperCase(Classe) = UpperCase('TIWformPlantonistasSOS') then
      (Form as TIWFormPlantonistasSOS).Show
    else if UpperCase(Classe) = UpperCase('TIWformFichaTecnica') then
      (Form as TIWFormFichaTecnica).Show
    else if UpperCase(Classe) = UpperCase('TIWformNotificacoes') then
      (Form as TIWformNotificacoes).Show
    else if UpperCase(Classe) = UpperCase('TIWformOS') then
      (Form as TIWformOS).Show
    else if UpperCase(Classe) = UpperCase('TIWformEntregaTecnica') then
      (Form as TIWformEntregaTecnica).Show
    else if UpperCase(Classe) = UpperCase('TIWformVistorias') then
      (Form as TIWformVistorias).Show
    else if UpperCase(Classe) = UpperCase('TIWformHolerites') then
      (Form as TIWformHolerites).Show
     else if UpperCase(Classe) = UpperCase('TIWformQuery') then
      (Form as TIWformQuery).Show
     else if UpperCase(Classe) = UpperCase('TIWformAcoesEspeciais') then
      (Form as TIWformAcoesEspeciais).Show
     else if UpperCase(Classe) = UpperCase('TIWformRamais') then
      (Form as TIWformRamais).Show
     else if UpperCase(Classe) = UpperCase('TIWformIndices') then
      (Form as TIWformIndices).Show
      else if UpperCase(Classe) = UpperCase('TIWformAbrirSac') then
      (Form as TIWformAbrirSac).Show;
  end
  else
  begin
    if UpperCase(Classe) = UpperCase('TIWformPrincipal') then
      TIWformPrincipal.Create(WebApplication).Show
    else if UpperCase(Classe) = UpperCase('TIWformChat') then
      TIWformChat.Create(WebApplication).Show
    else if UpperCase(Classe) = UpperCase('TIWformSuporteTecnico') then
      TIWformSuporteTecnico.Create(WebApplication).Show
    else if UpperCase(Classe) = UpperCase('TIWformMain') then
      TIWformMain.Create(WebApplication).Show
    else if UpperCase(Classe) = UpperCase('TIWformClientes') then
      TIWformClientes.Create(WebApplication).Show
    else if UpperCase(Classe) = UpperCase('TIWformLogin') then
      TIWformLogin.Create(WebApplication).Show
    else if UpperCase(Classe) = UpperCase('TIWformMainRestrito') then
      TIWformMainRestrito.Create(WebApplication).Show
    else if UpperCase(Classe) = UpperCase('TIWformIAMOnline') then
      TIWformIAMOnline.Create(WebApplication).Show
    else if UpperCase(Classe) = UpperCase('TIWformPlantonistasSOS') then
      TIWFormPlantonistasSOS.Create(WebApplication).Show
    else if UpperCase(Classe) = UpperCase('TIWformFichaTecnica') then
      TIWFormFichaTecnica.Create(WebApplication).Show
    else if UpperCase(Classe) = UpperCase('TIWformNotificacoes') then
      TIWformNotificacoes.Create(WebApplication).Show
    else if UpperCase(Classe) = UpperCase('TIWformOS') then
      TIWformOS.Create(WebApplication).Show
    else if UpperCase(Classe) = UpperCase('TIWformEntregaTecnica') then
      TIWformEntregaTecnica.Create(WebApplication).Show
    else if UpperCase(Classe) = UpperCase('TIWformVistorias') then
      TIWformVistorias.Create(WebApplication).Show
    else if UpperCase(Classe) = UpperCase('TIWformHolerites') then
      TIWformHolerites.Create(WebApplication).Show
    else if UpperCase(Classe) = UpperCase('TIWformQuery') then
      TIWformQuery.Create(WebApplication).Show
    else if UpperCase(Classe) = UpperCase('TIWformAcoesEspeciais') then
      TIWformAcoesEspeciais.Create(WebApplication).Show
    else if UpperCase(Classe) = UpperCase('TIWformRamais') then
      TIWformRamais.Create(WebApplication).Show
    else if UpperCase(Classe) = UpperCase('TIWformIndices') then
      TIWformIndices.Create(WebApplication).Show
    else if UpperCase(Classe) = UpperCase('TIWformAbrirSac') then
      TIWformAbrirSac.Create(WebApplication).Show;
  end;
end;

function TIWUserSession.ConectarBD : Boolean;
begin
  try
    if not uniconn.Connected then
    begin
      uniconn.Connected := false;
      uniconn.Connected := True;

      Result := uniconn.Connected;
    end
    else
      Result := true;
  except
    Result := False;
  end;
end;

procedure TIWUserSession.DesconectarBD;
begin
  try
    uniconn.Connected := False;
  finally
  end;
end;

{$R *.dfm}

end.