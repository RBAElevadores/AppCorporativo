unit untIndices;

interface

uses
  Classes, SysUtils, IWAppForm, IWApplication, IWColor, IWTypes, IWVCLComponent,
  IWBaseLayoutComponent, IWBaseContainerLayout, IWContainerLayout,
  IWTemplateProcessorHTML, Vcl.Controls, IWVCLBaseControl, IWBaseControl,
  IWBaseHTMLControl, IWControl, IWCompButton, IWBaseComponent,
  IWBaseHTMLComponent, IWBaseHTML40Component, IWCompExtCtrls, IWCompEdit;

type
  TIWformIndices = class(TIWAppForm)
    timerShow: TIWTimer;
    btnVoltar: TIWButton;
    IWTemplateProcessorHTML1: TIWTemplateProcessorHTML;
    edtScript: TIWEdit;
    btnScript: TIWButton;
    procedure btnVoltarAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure timerShowAsyncTimer(Sender: TObject; EventParams: TStringList);
    procedure IWAppFormShow(Sender: TObject);
    procedure btnScriptAsyncClick(Sender: TObject; EventParams: TStringList);
  public
  end;

implementation
uses ServerController;

{$R *.dfm}


procedure TIWformIndices.btnScriptAsyncClick(Sender: TObject;
  EventParams: TStringList);
var Ret : String;
begin
  if Trim(edtScript.Text) = '' then
    Exit;

  try
    Ret := UserSession.RetornaSQL(edtScript.Text);

    WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(Ret);
  except
  end;
end;

procedure TIWformIndices.btnVoltarAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  UserSession.AbreForm('TIWformMain');

  release;
end;

procedure TIWformIndices.IWAppFormShow(Sender: TObject);
begin
  timerShow.Enabled := false;
  timerShow.Enabled := true;
end;

procedure TIWformIndices.timerShowAsyncTimer(Sender: TObject;
  EventParams: TStringList);
var SQL : String;
    Ret : String;
begin
  timerShow.Enabled := false;

  try
    SQL := ' exec SmartBox.USP_HTMLTecnicoOnlineIndices 0'+IntToStr(UserSession.CodUsuario);

    Ret := UserSession.RetornaSQL(SQL);

    WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(Ret);
  except
  end;
end;

end.
