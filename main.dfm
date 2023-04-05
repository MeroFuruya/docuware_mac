object Form_main: TForm_main
  Left = 0
  Top = 0
  Caption = 'docuware mac'
  ClientHeight = 470
  ClientWidth = 683
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    683
    470)
  TextHeight = 15
  object Button1: TButton
    Left = 0
    Top = 441
    Width = 681
    Height = 25
    Anchors = [akLeft, akRight, akBottom]
    Caption = 'start'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 0
    Top = 0
    Width = 681
    Height = 440
    Anchors = [akLeft, akTop, akRight, akBottom]
    ScrollBars = ssBoth
    TabOrder = 1
  end
end
