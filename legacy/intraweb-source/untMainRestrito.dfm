object IWformMainRestrito: TIWformMainRestrito
  Left = 0
  Top = 0
  Width = 555
  Height = 400
  RenderInvisibleControls = True
  OnRender = IWAppFormRender
  AllowPageAccess = True
  ConnectionMode = cmAny
  OnShow = IWAppFormShow
  Background.Fixed = False
  LayoutMgr = IWTemplateProcessorHTML1
  HandleTabs = False
  LeftToRight = True
  LockUntilLoaded = True
  LockOnSubmit = True
  ShowHint = True
  XPTheme = True
  DesignLeft = 8
  DesignTop = 8
  object btnSair: TIWButton
    Left = 40
    Top = 320
    Width = 129
    Height = 33
    Caption = 'SAIR'
    Color = clBtnFace
    Font.Color = clNone
    Font.Size = 10
    Font.Style = []
    FriendlyName = 'btnSair'
    TabOrder = 0
    OnAsyncClick = btnSairAsyncClick
  end
  object IWTemplateProcessorHTML1: TIWTemplateProcessorHTML
    TagType = ttIntraWeb
    Left = 80
    Top = 16
  end
  object timerCarregaHtml: TIWTimer
    Enabled = False
    Interval = 100
    ShowAsyncLock = False
    OnAsyncTimer = timerCarregaHtmlAsyncTimer
    Left = 224
    Top = 16
  end
end
