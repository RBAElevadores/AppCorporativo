object IWServerController: TIWServerController
  OldCreateOrder = False
  AppName = 'TecnicoOnline'
  ComInitialization = ciMultiThreaded
  Description = 'RBA - T'#233'cnico Online'
  DisplayName = 'RBA - T'#233'cnico Online'
  EnableImageToolbar = True
  Port = 8888
  ServerResizeTimeout = 0
  ShowLoadingAnimation = True
  SessionTimeout = 9999
  LockSessionTimeout = 999999999
  SSLOptions.NonSSLRequest = nsAccept
  SSLOptions.Port = 0
  SSLOptions.SSLVersions = []
  Version = '15.0.18'
  AllowMultipleSessionsPerUser = False
  JavaScriptOptions.AjaxErrorMode = emNone
  JavaScriptOptions.jQueryVersion = '1.12.4'
  RestartExpiredSession = True
  BackButtonOptions.WarningMessage = 'Utilize o Voltar do pr'#243'prio site.'
  OnNewSession = IWServerControllerBaseNewSession
  Height = 310
  Width = 342
end
