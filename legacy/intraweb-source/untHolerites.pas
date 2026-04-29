unit untHolerites;

interface

uses
  Classes, SysUtils, IWAppForm, IWApplication, IWColor, IWTypes,
  IWBaseComponent, IWBaseHTMLComponent, IWBaseHTML40Component, IWCompExtCtrls,
  Vcl.Controls, IWVCLBaseControl, IWBaseControl, IWBaseHTMLControl, IWControl,
  IWCompButton, IWVCLComponent, IWBaseLayoutComponent, IWBaseContainerLayout,
  IWContainerLayout, IWTemplateProcessorHTML, IWCompEdit, Data.DB, ShellAPI,
  Windows;

type
  TIWformHolerites = class(TIWAppForm)
    IWTemplateProcessorHTML1: TIWTemplateProcessorHTML;
    btnVoltar: TIWButton;
    timerShow: TIWTimer;
    edtSeqArquivo: TIWEdit;
    btnBaixar: TIWButton;
    timerArquivo: TIWTimer;
    procedure btnVoltarAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure timerShowAsyncTimer(Sender: TObject; EventParams: TStringList);
    procedure IWAppFormShow(Sender: TObject);
    procedure btnBaixarAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure timerArquivoAsyncTimer(Sender: TObject; EventParams: TStringList);
  public
  end;

implementation
uses ServerController;

{$R *.dfm}


procedure TIWformHolerites.btnBaixarAsyncClick(Sender: TObject;
  EventParams: TStringList);
var URL  : String;
    SQL  : String;
    Nome : String;
begin
  if Trim(edtSeqArquivo.Text) = '' then
    Exit;

  Nome := 'Holerite_'+Trim(edtSeqArquivo.Text)+'.pdf';

  SQL := ' delete from Arquivos.dbo.ArquivosTempURL where not DtCriouServidor is null and Arquivo is null '+
         ' insert into Arquivos.dbo.ArquivosTempURL(Arquivo,Nome) '+
         ' select Arquivo, '''+Nome+''' from Arquivos.FolhaSalarial.Holerites '+
         ' where Seq = 0'+Trim(edtSeqArquivo.Text);
  UserSession.ExecutaSQL(SQL);

  timerArquivo.Enabled := false;
  timerArquivo.Tag     := 0;
  timerArquivo.Enabled := true;
end;

procedure TIWformHolerites.btnVoltarAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  UserSession.AbreForm('TIWformMain');

  release;
end;

procedure TIWformHolerites.IWAppFormShow(Sender: TObject);
begin
  timerShow.Enabled := false;
  timerShow.Enabled := true;
end;

procedure TIWformHolerites.timerArquivoAsyncTimer(Sender: TObject;
  EventParams: TStringList);
var SQL : String;
    URL : String;
    Nome : String;
begin
  timerArquivo.Enabled := false;

  Nome := 'Holerite_'+Trim(edtSeqArquivo.Text)+'.pdf';

  SQL := ' select 1 Aux from Arquivos.dbo.ArquivosTempURL '+
         ' where Nome = '''+Nome+''' and not DtCriouServidor is null ';
  if UserSession.RetornaSQL(SQL) = '1' then
  begin
    URL := 'https://rbaelevadores.ddns.net/Arquivos/Temp/'+Nome;
    WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA('downloadArquivo("'+URL+'"); btnFechaModalMensagem.click();');
  end
  else
  begin
    timerArquivo.Tag     := timerArquivo.Tag+1;

    if timerArquivo.Tag > 10 then
    begin
      WebApplication.ShowNotification('Houve algum problema! Tente novamente!',ntError);
      WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA('btnFechaModalMensagem.click();');
    end
    else
      timerArquivo.Enabled := true;
  end;
end;

procedure TIWformHolerites.timerShowAsyncTimer(Sender: TObject;
  EventParams: TStringList);
var SQL, Ret : String;
begin
  timerShow.Enabled := false;

  try
    SQL := ' exec SmartBox.USP_HTMLTecnicoOnlineHolerites 0'+IntToStr(UserSession.CodUsuario);

    Ret := UserSession.RetornaSQL( SQL );

    WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(Ret);
  except
  end;
end;

end.
