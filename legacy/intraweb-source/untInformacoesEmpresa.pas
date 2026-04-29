unit untInformacoesEmpresa;

interface

uses
  Classes, SysUtils, IWAppForm, IWApplication, IWColor, IWTypes, IWVCLComponent,
  IWBaseLayoutComponent, IWBaseContainerLayout, IWContainerLayout,
  IWTemplateProcessorHTML, Vcl.Controls, IWVCLBaseControl, IWBaseControl,
  IWBaseHTMLControl, IWControl, IWCompButton, IWCompFileUploader,
  IWBaseComponent, IWBaseHTMLComponent, IWBaseHTML40Component, IWCompExtCtrls,
  Data.DB;

type
  TIWformInformacoesEmpresa = class(TIWAppForm)
    btnVoltar: TIWButton;
    IWTemplateProcessorHTML1: TIWTemplateProcessorHTML;
    timerShow: TIWTimer;
    procedure btnVoltarAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure IWAppFormShow(Sender: TObject);
    procedure timerShowAsyncTimer(Sender: TObject; EventParams: TStringList);
  public
  end;

implementation
uses ServerController;

{$R *.dfm}


procedure TIWformInformacoesEmpresa.btnVoltarAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  UserSession.AbreForm('TIWformMain');

  release;
end;

procedure TIWformInformacoesEmpresa.IWAppFormShow(Sender: TObject);
begin
  timerShow.Enabled := false;
  timerShow.Enabled := true;
end;

procedure TIWformInformacoesEmpresa.timerShowAsyncTimer(Sender: TObject;
  EventParams: TStringList);
var CaminhoArq      : String;
    HTML            : String;

    NomeFundoEscuro : String;
    NomeFundoClaro  : String;
begin
  timerShow.Enabled := false;

  HTML := ' EmpresaSistema = '+IntToStr(UserSession.EmpresaSistema)+'; ';
  NomeFundoEscuro := 'LogoParceiro_FundoEscuro_'+IntToStr(UserSession.EmpresaSistema)+'.png';
  NomeFundoClaro  := 'LogoParceiro_FundoClaro_'+IntToStr(UserSession.EmpresaSistema)+'.png';

  try
    //Baixa logo de FUNDO ESCURO
    UserSession.qryAux.Close;
    UserSession.qryAux.SQL.Clear;
    UserSession.qryAux.SQL.Add(' select Imagem from Arquivos.dbo.ImagensGeral where Nome = :Nome ');
    UserSession.qryAux.ParamByName('Nome').AsString := NomeFundoEscuro;
    UserSession.qryAux.Open;

    if not UserSession.qryAux.IsEmpty then
    begin

      //Logo Fundo Escuro
      if not UserSession.qryAux.Fields[0].IsNull then
      begin
        CaminhoArq := WebApplication.ApplicationPath+'\wwwroot\'+NomeFundoEscuro;
        if FileExists(CaminhoArq) then
          DeleteFile(CaminhoArq);

        (UserSession.qryAux.Fields[0] as TBlobField).SaveToFile(CaminhoArq);

        HTML := HTML + ' LogoEscura = 1; ';
      end;

    end;

    //Baixa logo de FUNDO CLARO
    UserSession.qryAux.Close;
    UserSession.qryAux.ParamByName('Nome').AsString := NomeFundoClaro;
    UserSession.qryAux.Open;

    if not UserSession.qryAux.IsEmpty then
    begin

      //Logo Fundo Escuro
      if not UserSession.qryAux.Fields[0].IsNull then
      begin
        CaminhoArq := WebApplication.ApplicationPath+'\wwwroot\'+NomeFundoClaro;
        if FileExists(CaminhoArq) then
          DeleteFile(CaminhoArq);

        (UserSession.qryAux.Fields[0] as TBlobField).SaveToFile(CaminhoArq);

        HTML := HTML + ' LogoClara = 1; ';
      end;

    end;


    HTML := HTML + ' refreshImage(); ';

    //Atualiza as imagens na página
    WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(HTML);

  except
  end;
end;

end.
