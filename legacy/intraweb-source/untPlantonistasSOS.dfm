object IWFormPlantonistasSOS: TIWFormPlantonistasSOS
  Left = 0
  Top = 0
  Width = 555
  Height = 400
  RenderInvisibleControls = True
  OnRender = IWAppFormShow
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
  object btnVoltar: TIWButton
    Left = 224
    Top = 24
    Width = 75
    Height = 25
    Caption = 'Voltar'
    Color = clBtnFace
    Font.Color = clNone
    Font.Size = 10
    Font.Style = []
    FriendlyName = 'btnVoltar'
    TabOrder = 0
    OnAsyncClick = btnVoltarAsyncClick
  end
  object IWTemplateProcessorHTML1: TIWTemplateProcessorHTML
    TagType = ttIntraWeb
    Left = 80
    Top = 16
  end
  object timerCarregar: TIWTimer
    Enabled = False
    Interval = 1000
    ShowAsyncLock = False
    OnAsyncTimer = timerCarregarAsyncTimer
    Left = 360
    Top = 8
  end
end
