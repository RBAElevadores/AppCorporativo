unit untQuery;

interface

uses
  Classes, SysUtils, IWAppForm, IWApplication, IWColor, IWTypes,
  IWBaseComponent, IWBaseHTMLComponent, IWBaseHTML40Component, IWCompExtCtrls,
  Vcl.Controls, IWVCLBaseControl, IWBaseControl, IWBaseHTMLControl, IWControl,
  IWCompButton, IWVCLComponent, IWBaseLayoutComponent, IWBaseContainerLayout,
  IWContainerLayout, IWTemplateProcessorHTML, IWHTMLTag, IWCompMemo;

type
  TIWformQuery = class(TIWAppForm)
    IWTemplateProcessorHTML1: TIWTemplateProcessorHTML;
    btnVoltar: TIWButton;
    timerShow: TIWTimer;
    memoScript: TIWMemo;
    btnExecutar: TIWButton;
    procedure IWAppFormShow(Sender: TObject);
    procedure timerShowAsyncTimer(Sender: TObject; EventParams: TStringList);
    procedure btnVoltarAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure memoScriptHTMLTag(ASender: TObject; ATag: TIWHTMLTag);
    procedure btnExecutarAsyncClick(Sender: TObject; EventParams: TStringList);
  public
  end;

implementation
uses ServerController;

{$R *.dfm}


procedure TIWformQuery.btnExecutarAsyncClick(Sender: TObject;
  EventParams: TStringList);
var Ret, Linha, Campo : String;
    i, j : Integer;
begin
  if TRIM(memoScript.Text) = '' then
  begin
    WebApplication.ShowNotification('Preencha algum script',ntLog);
    Exit;
  end;

  UserSession.qryAux.Close;
  UserSession.qryAux.SQL.Clear;
  UserSession.qryAux.SQL.Add(memoScript.Text);

  try
    UserSession.qryAux.ExecSQL;

    if UserSession.qryAux.IsEmpty then
      ret := 'mensagem("Sucesso","Script executado com sucesso",5000,1,0); document.getElementById(tabela).style.display = "none";'
    else
    begin

      // Começa a construir o arrayGrafico com os nomes das colunas
      Linha := '[';
      for i := 0 to UserSession.qryAux.FieldCount - 1 do
      begin
        Linha := Linha + '"' + UserSession.qryAux.Fields[i].DisplayLabel + '"';
        if i < UserSession.qryAux.FieldCount - 1 then
          Linha := Linha + ',';
      end;
      Linha := Linha + ']';

      // Agora adiciona os dados linha por linha
      Ret := 'arrayGrafico = [' + Linha;

      UserSession.qryAux.First;
      while not UserSession.qryAux.Eof do
      begin
        Linha := '[';
        for j := 0 to UserSession.qryAux.FieldCount - 1 do
        begin
          Campo := UserSession.qryAux.Fields[j].AsString;
          Campo := StringReplace(Campo, '"', '\"', [rfReplaceAll]); // escapa aspas
          Linha := Linha + '"' + Campo + '"';
          if j < UserSession.qryAux.FieldCount - 1 then
            Linha := Linha + ',';
        end;
        Linha := Linha + ']';
        Ret := Ret + ',' + Linha;

        UserSession.qryAux.Next;
      end;

      Ret := Ret + '];';
      Ret := Ret + ' drawTable(); window.location.href="#"+tabela;';

    end;

  except on e:exception do
    begin
      ret := 'mensagem("Erro","'+E.Message+'",10000,1,0);';
    end;
  end;

  WebApplication.CallBackResponse.AddJavaScriptToExecuteAsCDATA(ret);
end;

procedure TIWformQuery.btnVoltarAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  UserSession.AbreForm('TIWformMain');

  release;
end;

procedure TIWformQuery.IWAppFormShow(Sender: TObject);
begin
  timerShow.Enabled := false;
  timerShow.Enabled := true;
end;

procedure TIWformQuery.memoScriptHTMLTag(ASender: TObject; ATag: TIWHTMLTag);
begin
  ATag.AddStringParam('rows','12');
end;

procedure TIWformQuery.timerShowAsyncTimer(Sender: TObject;
  EventParams: TStringList);
begin
  timerShow.Enabled := false;
end;

end.
