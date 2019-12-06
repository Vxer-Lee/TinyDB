object PwdDataForm: TPwdDataForm
  Left = 241
  Top = 212
  BorderStyle = bsDialog
  Caption = 'Password Info'
  ClientHeight = 165
  ClientWidth = 299
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 7
    Top = 59
    Width = 201
    Height = 98
    Caption = 'Note'
    TabOrder = 1
    object NoteMemo: TMemo
      Left = 11
      Top = 18
      Width = 178
      Height = 68
      ScrollBars = ssVertical
      TabOrder = 0
    end
  end
  object GroupBox2: TGroupBox
    Left = 7
    Top = 4
    Width = 201
    Height = 50
    Caption = 'Password'
    TabOrder = 0
    object PasswordEdit: TEdit
      Left = 11
      Top = 18
      Width = 178
      Height = 21
      TabOrder = 0
    end
  end
  object OkButton: TButton
    Left = 217
    Top = 9
    Width = 75
    Height = 25
    Caption = '&OK'
    Default = True
    TabOrder = 2
    OnClick = OkButtonClick
  end
  object CancelButton: TButton
    Left = 217
    Top = 43
    Width = 75
    Height = 25
    Cancel = True
    Caption = '&Cancel'
    TabOrder = 3
    OnClick = CancelButtonClick
  end
end
