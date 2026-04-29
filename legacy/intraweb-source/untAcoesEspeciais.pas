unit untAcoesEspeciais;

interface

uses
  Classes, SysUtils, IWAppForm, IWApplication, IWColor, IWTypes,
  IWBaseComponent, IWBaseHTMLComponent, IWBaseHTML40Component, IWCompExtCtrls,
  Vcl.Controls, IWVCLBaseControl, IWBaseControl, IWBaseHTMLControl, IWControl,
  IWCompButton, IWVCLComponent, IWBaseLayoutComponent, IWBaseContainerLayout,
  IWContainerLayout, IWTemplateProcessorHTML, IWCompEdit;

type
  TIWformAcoesEspeciais = class(TIWAppForm)
    IWTemplateProcessorHTML1: TIWTemplateProcessorHTML;
    btnVoltar: TIWButton;
    timerShow: TIWTimer;
    edtGrupo: TIWEdit;
    btnGrupo: TIWButton;
    edtExecutar: TIWEdit;
    btnExecutar: TIWButton;
    procedure btnVoltarAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure timerShowAsyncTimer(Sender: TObject; EventParams: TStringList);
    procedure IWAppFormShow(Sender: TObject);
    procedure btnGrupoAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure btnExecutarAsyncClick(Sender: TObject; EventParams: TStringList);
  public
  end;

implementation
uses ServerController;

{$R *.dfm}


procedure TIWformAcoesEspeciais.btnExecutarAsyncClick(Sender: TObject;
  EventParams: TStringList);
var SQL, Ret : String;
begin
  if Trim(edtExecutar.Text) = '' then
    Exit;

  try
    SQL := ' exec SmartBox.USP_HTMLTecnicoOnlineAcoesEspeciaisExecutar 0'+edtExecutar.Text;

    Ret := UserSession.RetornaSQL(SQL);

    WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(Ret);
  except
  end;
end;

procedure TIWformAcoesEspeciais.btnGrupoAsyncClick(Sender: TObject;
  EventParams: TStringList);
var SQL, Ret : String;
begin
  if Trim(edtGrupo.Text) = '' then
    Exit;

  try
    SQL := ' exec SmartBox.USP_HTMLTecnicoOnlineAcoesEspeciaisBotoes '''+Trim(edtGrupo.Text)+''' ';

    Ret := UserSession.RetornaSQL(SQL);

    WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(Ret);
  except
  end;
end;

procedure TIWformAcoesEspeciais.btnVoltarAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  UserSession.AbreForm('TIWformMain');

  release;
end;

procedure TIWformAcoesEspeciais.IWAppFormShow(Sender: TObject);
begin
  timerShow.Enabled := false;
  timerShow.Enabled := true;
end;

procedure TIWformAcoesEspeciais.timerShowAsyncTimer(Sender: TObject;
  EventParams: TStringList);
var SQL, Ret : String;
begin
  timerShow.Enabled := false;

  try
    SQL := ' exec SmartBox.USP_HTMLTecnicoOnlineAcoesEspeciais ';

    Ret := UserSession.RetornaSQL(SQL);

    WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(Ret);
  except
  end;
end;

end.
