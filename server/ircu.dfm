object Form1: TForm1
  Left = 492
  Top = 118
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Relay'
  ClientHeight = 194
  ClientWidth = 237
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  OnPaint = FormPaint
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 64
    Width = 23
    Height = 13
    Caption = 'Név:'
  end
  object start: TButton
    Left = 32
    Top = 4
    Width = 75
    Height = 25
    Caption = 'Start'
    TabOrder = 0
    OnClick = startClick
  end
  object stop: TButton
    Left = 132
    Top = 4
    Width = 75
    Height = 25
    Caption = 'Stop'
    Enabled = False
    TabOrder = 1
    OnClick = stopClick
  end
  object m: TMemo
    Left = 4
    Top = 92
    Width = 229
    Height = 97
    TabOrder = 2
  end
  object stup: TCheckBox
    Left = 8
    Top = 36
    Width = 129
    Height = 17
    Caption = 'Indulás a windows-zal'
    TabOrder = 3
    OnClick = stupClick
  end
  object ued: TEdit
    Left = 44
    Top = 60
    Width = 89
    Height = 21
    TabOrder = 4
  end
  object Button1: TButton
    Left = 144
    Top = 60
    Width = 75
    Height = 21
    Caption = 'Jelszava'
    TabOrder = 5
    OnClick = Button1Click
  end
  object ss: TServerSocket
    Active = False
    Port = 5556
    ServerType = stNonBlocking
    OnAccept = ssAccept
    OnClientConnect = ssClientConnect
    OnClientDisconnect = ssClientDisconnect
    OnClientRead = recv
    OnClientError = ssClientError
  end
end
