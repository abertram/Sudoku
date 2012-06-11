object frmMain: TfrmMain
  Left = 666
  Top = 293
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Sudoku'
  ClientHeight = 439
  ClientWidth = 430
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = mmMenu
  OldCreateOrder = False
  Position = poDesktopCenter
  ShowHint = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object dgField: TDrawGrid
    Left = 8
    Top = 8
    Width = 465
    Height = 425
    BorderStyle = bsNone
    ColCount = 9
    Ctl3D = True
    DefaultColWidth = 45
    DefaultRowHeight = 45
    FixedCols = 0
    RowCount = 9
    FixedRows = 0
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -27
    Font.Name = 'Verdana'
    Font.Style = []
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing]
    ParentCtl3D = False
    ParentFont = False
    ScrollBars = ssNone
    TabOrder = 0
    OnDrawCell = dgFieldDrawCell
    OnGetEditText = dgFieldGetEditText
    OnKeyPress = dgFieldKeyPress
    OnSelectCell = dgFieldSelectCell
    OnSetEditText = dgFieldSetEditText
  end
  object mmMenu: TMainMenu
    AutoHotkeys = maManual
    Left = 8
    Top = 8
    object miFile: TMenuItem
      Caption = 'Datei'
      object miNew: TMenuItem
        Caption = 'Neu'
        Hint = 'Neues Sudoku erstellen'
        OnClick = miNewClick
      end
      object miSave: TMenuItem
        Caption = 'Speichern'
        Hint = 'Sudoku speichern'
        OnClick = miSaveClick
      end
      object miOpen: TMenuItem
        Caption = #214'ffnen'
        Hint = 'Sudoku '#246'ffnen'
        OnClick = miOpenClick
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object miExit: TMenuItem
        Caption = 'Beenden'
        Hint = 'Spiel beenden'
        OnClick = miExitClick
      end
    end
    object miSudoku: TMenuItem
      Caption = 'Sudoku'
      object miSetFixedDigits: TMenuItem
        AutoCheck = True
        Caption = 'Eingeben'
        Hint = 'Vorgegebene Ziffern eingeben'
        OnClick = miSetFixedDigitsClick
      end
      object miVerify: TMenuItem
        Caption = #220'berpr'#252'fen'
        Hint = 'Sudoku auf Korrektheit '#252'berpr'#252'fen'
        OnClick = miVerifyClick
      end
    end
    object miHelp: TMenuItem
      Caption = 'Hilfe'
      object miSolveCol: TMenuItem
        Caption = 'Spalte l'#246'sen'
        Hint = 'Eine Spalte l'#246'sen'
        OnClick = miSolveColClick
      end
      object miSolveRow: TMenuItem
        Caption = 'Zeile l'#246'sen'
        Hint = 'Eine Zeile l'#246'sen'
      end
      object miAccounting: TMenuItem
        AutoCheck = True
        Caption = 'Buchf'#252'hrung'
        Hint = 'M'#246'gliche Werte in jeder Zelle anzeigen'
        OnClick = miAccountingClick
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object miSolve: TMenuItem
        Caption = 'L'#246'sen'
        Hint = 'Sudoku l'#246'sen'
        OnClick = miSolveClick
      end
    end
  end
  object odOpenFile: TOpenDialog
    Left = 72
    Top = 8
  end
  object sdSaveFile: TSaveDialog
    Left = 40
    Top = 8
  end
end
