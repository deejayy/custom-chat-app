object Form1: TForm1
  Left = 242
  Top = 108
  Width = 709
  Height = 501
  Caption = 'Chat'
  Color = clBtnFace
  Constraints.MinHeight = 200
  Constraints.MinWidth = 520
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 33
    Height = 13
    Caption = 'IP cím:'
  end
  object Label2: TLabel
    Left = 188
    Top = 8
    Width = 55
    Height = 13
    Caption = 'Port száma:'
  end
  object Label3: TLabel
    Left = 300
    Top = 8
    Width = 23
    Height = 13
    Caption = 'Név:'
  end
  object m1: TMemo
    Left = 4
    Top = 32
    Width = 694
    Height = 409
    Anchors = [akLeft, akTop, akRight, akBottom]
    Color = 5197647
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -16
    Font.Name = 'Courier New'
    Font.Style = [fsBold]
    ParentFont = False
    ReadOnly = True
    TabOrder = 6
    OnKeyDown = m1KeyDown
  end
  object ip: TEdit
    Left = 48
    Top = 4
    Width = 129
    Height = 22
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    Text = '192.168.1.39'
  end
  object port: TEdit
    Left = 248
    Top = 4
    Width = 41
    Height = 22
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    Text = '5556'
  end
  object conn: TButton
    Left = 587
    Top = 4
    Width = 109
    Height = 21
    Anchors = [akTop, akRight]
    Caption = 'Csatlakozás >>'
    TabOrder = 3
    OnClick = connClick
  end
  object name: TEdit
    Left = 328
    Top = 4
    Width = 252
    Height = 22
    Anchors = [akLeft, akTop, akRight]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    Text = 'DeeJayy'
  end
  object ident: TButton
    Left = 617
    Top = 444
    Width = 79
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Azonosítás'
    Enabled = False
    TabOrder = 5
    OnClick = identClick
  end
  object e1: TMemo
    Left = 3
    Top = 444
    Width = 607
    Height = 25
    Anchors = [akLeft, akRight, akBottom]
    Color = 5197647
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -16
    Font.Name = 'Courier New'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 4
    OnKeyDown = e1KeyDown
    OnKeyUp = e1KeyUp
  end
end
