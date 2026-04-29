{.$DEFINE SA}
{$DEFINE ISAPI}
{.$DEFINE IWLIB}

{$IFDEF SA}
program TecnicoOnline;
{$ELSE}
library TecnicoOnline;
{$ENDIF}

uses
  IWRtlFix,
  Forms,
  {$IFDEF SA}
  IWStart,
  {$ENDIF }
  {$IFDEF ISAPI}
  IWInitISAPI,
  {$ENDIF }
  {$IFDEF IWLIB}
  IW.Export,
  {$ENDIF }
  ServerController in 'ServerController.pas' {IWServerController: TIWServerControllerBase},
  UserSessionUnit in 'UserSessionUnit.pas' {IWUserSession: TIWUserSessionBase},
  untLogin in 'untLogin.pas' {IWformLogin: TIWAppForm},
  untPrincipal in 'untPrincipal.pas' {IWformPrincipal: TIWAppForm},
  untChat in 'untChat.pas' {IWformChat: TIWAppForm},
  untSuporteTecnico in 'untSuporteTecnico.pas' {IWformSuporteTecnico: TIWAppForm},
  untMain in 'untMain.pas' {IWformMain: TIWAppForm},
  untClientes in 'untClientes.pas' {IWformClientes: TIWAppForm},
  untMainRestrito in 'untMainRestrito.pas' {IWformMainRestrito: TIWAppForm},
  untIAMOnline in 'untIAMOnline.pas' {IWformIAMOnline: TIWAppForm},
  untPlantonistasSOS in 'untPlantonistasSOS.pas' {IWFormPlantonistasSOS: TIWAppForm},
  untFichaTecnica in 'untFichaTecnica.pas' {IWFormFichaTecnica: TIWAppForm},
  untNotificacoes in 'untNotificacoes.pas' {IWFormNotificacoes: TIWAppForm},
  untOS in 'untOS.pas' {IWformOS: TIWAppForm},
  untEntregaTecnica in 'untEntregaTecnica.pas' {IWformEntregaTecnica: TIWAppForm},
  untVistorias in 'untVistorias.pas' {IWformVistorias: TIWAppForm},
  untHolerites in 'untHolerites.pas' {IWformHolerites: TIWAppForm},
  untQuery in 'untQuery.pas' {IWformQuery: TIWAppForm},
  untAcoesEspeciais in 'untAcoesEspeciais.pas' {IWformAcoesEspeciais: TIWAppForm},
  untRamais in 'untRamais.pas' {IWformRamais: TIWAppForm},
  untIndices in 'untIndices.pas' {IWformIndices: TIWAppForm},
  untAbrirSac in 'untAbrirSac.pas' {IWFormAbrirSac: TIWAppForm};

{$R *.res}
{$IFDEF ISAPI}
exports
  GetExtensionVersion,
  HttpExtensionProc,
  TerminateExtension;
{$ENDIF}

begin
  {$IFDEF ISAPI}
   IWRun;
  {$ELSE}
  {$IFDEF SA}
   TIWStart.Execute(True);
   {$ENDIF}
  {$ENDIF}
end.
