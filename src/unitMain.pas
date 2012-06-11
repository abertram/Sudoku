//------------------------------------------------------------------------------
// Name der Unit: unitMain
//
// Projekt: Sudoku
//
// Beschreibung:
// -------------
//   Hauptformular des Programms
//
// Autor: Alexander Bertram
// erstellt am: 02.03.2006
//------------------------------------------------------------------------------
unit unitMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, Menus, ComCtrls, StdCtrls, unitTypes;

type
  TfrmMain = class(TForm)
    dgField: TDrawGrid;
    mmMenu: TMainMenu;
    miFile: TMenuItem;
    miSudoku: TMenuItem;
    miAccounting: TMenuItem;
    miNew: TMenuItem;
    miSave: TMenuItem;
    miOpen: TMenuItem;
    N1: TMenuItem;
    miExit: TMenuItem;
    miSetFixedDigits: TMenuItem;
    miSolve: TMenuItem;
    miVerify: TMenuItem;
    miHelp: TMenuItem;
    N4: TMenuItem;
    odOpenFile: TOpenDialog;
    sdSaveFile: TSaveDialog;
    miSolveRow: TMenuItem;
    miSolveCol: TMenuItem;
    procedure dgFieldDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure dgFieldSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: String);
    procedure dgFieldGetEditText(Sender: TObject; ACol, ARow: Integer;
      var Value: String);
    procedure dgFieldKeyPress(Sender: TObject; var Key: Char);
    procedure miAccountingClick(Sender: TObject);
    procedure dgFieldSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure miSaveClick(Sender: TObject);
    procedure miOpenClick(Sender: TObject);
    procedure miExitClick(Sender: TObject);
    procedure miNewClick(Sender: TObject);
    procedure miVerifyClick(Sender: TObject);
    procedure miSolveClick(Sender: TObject);
    procedure miSetFixedDigitsClick(Sender: TObject);
    procedure miSolveColClick(Sender: TObject);
    procedure miSolveRowClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private-Deklarationen }
    // Bitmap fuer leere Zelle
    Cell: TBitmap;
    // Menubuttons fuer neue Spielfeldgroessen
    MenuItemsNew: array [TFieldSize] of TMenuItem;
    // Menubuttons zum Spalten loesen
    MenuItemsSolveCol: array [TColCount] of TMenuItem;
    // Menubuttons zum Zeilen loesen
    MenuItemsSolveRow: array [TColCount] of TMenuItem;
    procedure SetFieldSize;
    procedure SaveFile;
    procedure OpenFile;
    procedure SetMenuButtonsState;
    procedure DrawCellLeftLine(Color: TColor = clBlack; Width: integer = 1);
    procedure DrawCellTopLine(Color: TColor = clBlack; Width: integer = 1);
    procedure DrawCellRightLine(Color: TColor = clBlack; Width: integer = 1);
    procedure DrawCellBottomLine(Color: TColor = clBlack; Width: integer = 1);
    procedure DrawCellFrame(Color: TColor = clBlack; Width: integer = 1);
  public
    { Public-Deklarationen }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses
  unitLogic, unitFile;

procedure TfrmMain.dgFieldDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
{-------------------------------------------------------------------------------
Beschreibung:
  Darstellen des Spielfeldes und seines Inhaltes
--------------------------------------------------------------------------------
globale Zugriffe:
  Cell (schreibend): einzelne Spielfeldzelle, die am Ende ins Spielfeld
                     uebertragen wird 
-------------------------------------------------------------------------------}
var
  Digit: TDigit;
  DigitStr: string;
  FieldSize: TFieldSize;
  DigitSet: TDigitSet;
  x, y: integer;
begin
  // Hintergrundfarbe der Bitmap setzen
  // fehlerhafte Zelle
  if CellIsInvalid(ACol, ARow) then
    Cell.Canvas.Brush.Color := cInvalidCellColor
  // fokussierte Zelle
  else if gdFocused in State then
    Cell.Canvas.Brush.Color := cFocusedCellColor
  // vorgegebene zelle
  else if CellValueIsFixed(ACol, ARow) then
    Cell.Canvas.Brush.Color := cFixedCellColor
  // andere
  else
    Cell.Canvas.Brush.Color := dgField.Color;
  Cell.Canvas.FillRect(Cell.Canvas.ClipRect);

  FieldSize := GetFieldSize;
  // Spielfeld- und Blockraender hervorheben
  // links
  if (ACol mod FieldSize) = 0 then
    DrawCellLeftLine;
  // rechts
  if ((ACol+1) mod FieldSize) = 0 then
    DrawCellRightLine;
  // oben
  if (ARow mod FieldSize) = 0 then
    DrawCellTopLine;
  // unten
  if ((ARow+1) mod FieldSize) = 0 then
    DrawCellBottomLine;

  // vorgegebene Zellen hervorheben
  if CellValueIsFixed(ACol, ARow) then
    DrawCellFrame;

  // fokussierte Zelle hervorheben
  if gdFocused in State then
    DrawCellFrame;

  // fehlerhafte Zellen hervorheben
  if CellIsInvalid(ACol, ARow) then
    DrawCellFrame(clRed);

  // ueberpruefen, ob Ziffer eingegeben
  if GetCellValue(ACol, ARow, Digit) then
  begin
    DigitStr := IntToStr(Digit);
    Cell.Canvas.Font:= dgField.Font;
    Cell.Canvas.Font.Color:= clBlack;

    // Koordinaten für zentrierte Ausgabe berechnen
    x := (Cell.Width div 2)-(Cell.Canvas.TextWidth(DigitStr) div 2);
    y := (Cell.Height div 2)-(Cell.Canvas.TextHeight(DigitStr) div 2);

    Cell.Canvas.TextOut(x, y, DigitStr);
  end
  // Buchfuehrung aktiviert?
  else if miAccounting.Checked then
  begin
    // Zellenmoeglichkeiten holen
    DigitSet := GetCellPossibilities(ACol, ARow);
    for Digit := cDigitMin to sqr(GetFieldSize) do
    begin
      // ueberpruefen, ob sich die Ziffer unter den Moeglichkeiten befindet
      if Digit in DigitSet then
      begin
        DigitStr := IntToStr(Digit);
        Cell.Canvas.Font.Size:= 8;
        // Farbe fuer die Ziffer holen
        Cell.Canvas.Font.Color := GetDigitColor(ACol, ARow, Digit);

        // Koordinaten für die Ausgabe berechnen
        x := (Digit-1) mod FieldSize * (Cell.Width div FieldSize)+
             ((Cell.Width div FieldSize) div 2)-
             (Cell.Canvas.TextWidth(DigitStr) div 2);
        y := (Digit-1) div FieldSize*(Cell.Width div FieldSize)+
             ((Cell.Height div FieldSize) div 2)-
             (Cell.Canvas.TextHeight(DigitStr) div 2);
        Cell.Canvas.TextOut(x, y, DigitStr);
      end;
    end;
  end;

  // Bitmap ins Grid übertragen
  if BitBlt(dgField.Canvas.Handle, Rect.Left, Rect.Top, Rect.Right-Rect.Left,
            Rect.Bottom-Rect.Top, Cell.Canvas.Handle, 0, 0, SRCCOPY) then;

  // Fokusrechteck verstecken
  if gdFocused in State then
    dgField.Canvas.DrawFocusRect(Rect);
end;

procedure TfrmMain.FormCreate(Sender: TObject);
{-------------------------------------------------------------------------------
Beschreibung:
  Initialisierungen beim Erstellen des Formulars
--------------------------------------------------------------------------------
globale Zugriffe:
  Cell (schreibend): Spielfeldzelle
  sdSaveFile (schreibend): SaveDialog
  odOpenFile (schreibend): OpenDialog
  MenuItemsNew (schreibend): Menuebuttons fuer ein neues Spiel
  MenuItemsSolveCol (schreibend): Menuebuttons zum Spalten loesen
  MenuItemssolveRow (schreibend): Menuebuttons zum Zeilen loesen
-------------------------------------------------------------------------------}
var
  i: TFieldSize;
  x: TColCount;
  y: TRowCount;
begin
  // Bitmap für leere Zelle erzeugen
  Cell := TBitmap.Create;
  Cell.Canvas.Font := dgField.Font;
  with Cell do begin
    Width := dgField.DefaultColWidth;
    Height := dgField.DefaultRowHeight;
  end;

  // Spielfeldgroesse setzen
  SetFieldSize;

  // Dialoge initialisieren
  sdSaveFile.InitialDir := ExtractFileDir(Application.ExeName);
  sdSaveFile.DefaultExt := cFileExt;
  sdSaveFile.Filter := 'Sudoku files|*.'+cFileExt+'|All files|*.*';
  odOpenFile.InitialDir := ExtractFileDir(Application.ExeName);
  odOpenFile.DefaultExt := cFileExt;
  odOpenFile.Filter := 'Sudoku files|*.'+cFileExt+'|All files|*.*';

  // Menuebuttons fuer Spielfeldgroessen erstellen
  for i := low(TFieldSize) to high(TFieldSize) do
  begin
    MenuItemsNew[i] := TMenuItem.Create(self);
    MenuItemsNew[i].Name := Format('miNew%d', [i]);
    MenuItemsNew[i].Caption := Format('%d×%0:d', [i]);
    MenuItemsNew[i].OnClick := miNewClick;
    miNew.Insert(miNew.Count, MenuItemsNew[i]);
  end;

  // Menuebuttons zum Spalten loesen erstellen
  for x := low(TColCount) to high(TColCount) do
  begin
    MenuItemsSolveCol[x] := TMenuItem.Create(self);
    MenuItemsSolveCol[x].Name := Format('miSolveCol%d', [x]);
    MenuItemsSolveCol[x].Caption := Format('%d', [x+1]);
    MenuItemsSolveCol[x].OnClick := miSolveColClick;
    miSolveCol.Insert(miSolveCol.Count, MenuItemsSolveCol[x]);
  end;

  // Menuebuttons zum Zeilen loesen erstellen
  for y := low(TRowCount) to high(TRowCount) do
  begin
    MenuItemsSolveRow[y] := TMenuItem.Create(self);
    MenuItemsSolveRow[y].Name := Format('miSolveRow%d', [y]);
    MenuItemsSolveRow[y].Caption := Format('%d', [y+1]);
    MenuItemsSolveRow[y].OnClick := miSolveRowClick;
    miSolveRow.Insert(miSolveRow.Count, MenuItemsSolveRow[y]);
  end;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
{-------------------------------------------------------------------------------
Beschreibung:
  Freigabe von selbst erstellten Objekten
--------------------------------------------------------------------------------
globale Zugriffe:
  Cell (schreibend): Spielfeldzelle
  MenuItemsNew (schreibend): Menuebuttons fuer ein neues Spiel
-------------------------------------------------------------------------------}
var
  i: TFieldSize;
  x: TColCount;
  y: TRowCount;
begin
  Cell.Free;
  for i := low(TFieldSize) to high(TFieldSize) do
    MenuItemsNew[i].Free;
  for x := low(TColCount) to high(TColCount) do
    MenuItemsSolveCol[x].Free;
  for y := low(TRowCount) to high(TRowCount) do
    MenuItemsSolveRow[y].Free;
end;

procedure TfrmMain.dgFieldSetEditText(Sender: TObject; ACol,
  ARow: Integer; const Value: String);
{-------------------------------------------------------------------------------
Beschreibung:
  nimmt Zifferneingaben entgegen, ueberprueft diese auf Gueltigkeit und setzt
  sie in der internen Darstellung
-------------------------------------------------------------------------------}
var
  Digit: TDigit;
begin
  // ueberpruefen, ob in der Zelle eine Ziffer steht
  if Value <> '' then
  begin
    try
      // String aus der Zelle in eine Ziffer umwandeln
      Digit := StrToInt(Value);
      // ueberpruefen, ob Ziffer gueltig
      if Digit > sqr(GetFieldSize) then
        // Exception auslösen
        raise ERangeError.Create('Ungültige Eingabe!');
      // Ziffer in der internen Darstellung setzen
      SetCellValue(ACol, ARow, Digit, miSetFixedDigits.Checked);
    except
      // Fehlermeldung
      ShowMessage( 'Ungültige Eingabe!');
    end;
  end
  else
    // Ziffer aus der internen Darstellung loeschen
    SetCellValue(ACol, ARow, 1, false, true);
  // Spielfeld neu malen
  dgField.Refresh;
end;

procedure TfrmMain.dgFieldGetEditText(Sender: TObject; ACol,
  ARow: Integer; var Value: String);
{-------------------------------------------------------------------------------
Beschreibung:
  Laesst den User die Zahl der aktuellen Zelle editieren.
-------------------------------------------------------------------------------}
var
  Digit: TDigit;
begin
  // Zelle gesetzt?
  if GetCellValue(ACol, ARow, Digit) then
    // Ziffer darstellen
    Value := IntToStr(Digit);
  // ungueltige Zellen zuruecksetzen
  InitInvalidCells;
  dgField.Refresh;
end;

procedure TfrmMain.dgFieldKeyPress(Sender: TObject; var Key: Char);
{-------------------------------------------------------------------------------
Beschreibung:
  Laesst unerlaubte Zeichen nicht zu.
--------------------------------------------------------------------------------
globale Zugriffe:
  cValidKeys (lesend): gueltige Zeichen
-------------------------------------------------------------------------------}
begin
  if not (Key in cValidKeys) then
    Key := #0;
end;

procedure TfrmMain.miAccountingClick(Sender: TObject);
{-------------------------------------------------------------------------------
Beschreibung:
  Laesst das Spielfeld neu malen, nach Ein-/Ausschalten des Buchfuehrungsmoduses
--------------------------------------------------------------------------------
globale Zugriffe:
  dgField (lesend): Spielfeld (externe Darstellung)
-------------------------------------------------------------------------------}
begin
  // ungueltige Zellen zuruecksetzen
  InitInvalidCells;
  dgField.Refresh;
end;

procedure TfrmMain.dgFieldSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
{-------------------------------------------------------------------------------
Beschreibung:
  Laesst das Editieren einer Zelle je nach Art der Ziffer in der Zelle nicht zu
-------------------------------------------------------------------------------}
begin
  // ueberpruefen, ob im Eingabemodus
  if not miSetFixedDigits.Checked then
  begin
    // ueberpruefen, ob Ziffer vorgegeben
    if CellValueIsFixed(ACol, ARow) then
      // Editieren der Zelle verbieten
      dgField.Options := dgField.Options - [goEditing]
    else
      // Editieren der Zelle zulassen
      dgField.Options := dgField.Options + [goEditing];
  end
  else
  // Editieren in anderen Faellen zulassen
  if not (goEditing in dgField.Options) then
    dgField.Options := dgField.Options + [goEditing];
end;

procedure TfrmMain.SetFieldSize;
{-------------------------------------------------------------------------------
Beschreibung:
  Berechnet die Groesse des Formulars
-------------------------------------------------------------------------------}
var
  TmpRect: TRect;
begin
  dgField.ColCount := sqr(GetFieldSize);
  dgField.RowCount := sqr(GetFieldSize);
  // Breite des Spielfeldes berechnen
  dgField.Width :=   dgField.ColCount
                   * dgField.DefaultColWidth
                   + dgField.ColCount
                   + 0;
  // Hoehe des Spielfeldes berechnen
  dgField.Height :=   dgField.RowCount
                    * dgField.DefaultRowHeight
                    + dgField.RowCount
                    + 0;
  // Groesse des Mainmenus beruecksichtigen
  TmpRect.Left := 0;
  TmpRect.Right := 0;
  TmpRect.Top := 0;
  TmpRect.Bottom := 0;
  if GetWindowRect(mmMenu.WindowHandle, tmpRect) then;
  // Breite des Formulars berechnen
  frmMain.Width :=   2
                   * dgField.Left
                   + dgField.Width
                   + dgField.Left
                   - 2;
  // Hoehe des Formulars berechnen
  frmMain.Height :=   abs(ScreenToClient(tmpRect.TopLeft).y)
                    + 2
                    * dgField.Top
                    + dgField.Height
                    + dgField.Top
                    - 2;
  // Formular zentrieren
  frmMain.Left := (Screen.Width - frmMain.Width) div 2;
  frmMain.Top := (Screen.Height - frmMain.Height) div 2;
end;

procedure TfrmMain.OpenFile;
{-------------------------------------------------------------------------------
Beschreibung:
  Oeffnet eine Datei
-------------------------------------------------------------------------------}
var
  FileName: string;
  Field: TField;
begin
  if odOpenFile.Execute then
  begin
    FileName := odOpenFile.FileName;
    // ueberpruefen, ob Datei gültig
    if not FileIsValid(FileName, sizeof(TField)) then
      ShowMessage('Die Datei ist entweder ungültig oder mit einem anderen '+
      'Programm geöffnet!')
    else
    begin
      // versuchen, das Spielfeld zu laden
      if OpenField(FileName, Field) then
      begin
        // Spielfeld setzen
        SetField(Field);
        // Spielfeldgroesse setzen
        SetFieldSize;
      end
      else
        ShowMessage('Die Datei konnte nicht geöffnet werden!');
    end;
  end;
end;

procedure TfrmMain.SaveFile;
{-------------------------------------------------------------------------------
Beschreibung:
  Speichert eine Datei
-------------------------------------------------------------------------------}
var
  // Flag für Dateioperationen
  OKFlag: boolean;
  FileName: string;
  Field: TField;
begin
  OKFlag := true;
  if sdSaveFile.Execute then
  begin
    FileName := sdSaveFile.FileName;
    // ueberpruefen, ob Datei existiert
    if FileExists(FileName) then
      OKFlag := (MessageDlg('Datei existiert, soll sie überschrieben werden?',
        mtWarning, [mbYes, mbNo], 0) = mrYes)
    else
    // versuchen, Datei anzulegen
    if not unitFile.FileCreate(FileName) then
    begin
      // Fehlermeldung
      ShowMessage('Datei konnte nicht angelegt werden!');
      // Flag setzen
      OKFlag := false;
    end;
    if OKFlag then
      // ueberprufen, ob Datei schreibgeschützt
      // Versuch, Schreibschutz zu entfernen
      if     FileIsReadOnly(FileName) then
      begin
        if (MessageDlg('Datei ist schreibgeschützt. Soll der Schreibschutz '+
             'entfernt werden?', mtConfirmation, [mbYes, mbNo], 0) = mrYes)
           and not ClearReadOnlyFlag(FileName) then
        begin
          ShowMessage('Schreibschutz konnte nicht entfernt werden!');
          OKFlag := false;
        end
        else
          OKFlag := false;
      end;
    // alles in Ordnung?
    if OKFlag then
    begin
      Field := GetField;
      // Versuch, Spielfeld zu speichern
      if not SaveField(FileName, Field) then
        ShowMessage('Datei konnte nicht gespeichert werden!');
    end;
  end;
end;

procedure TfrmMain.miSaveClick(Sender: TObject);
{-------------------------------------------------------------------------------
Beschreibung:
  Ruft die Funktion zum Speichern der Datei auf
-------------------------------------------------------------------------------}
begin
  SaveFile;
end;

procedure TfrmMain.miOpenClick(Sender: TObject);
{-------------------------------------------------------------------------------
Beschreibung:
  Ruft die Funktion zum Oeffnen einer Datei auf, initialisiert ungueltige
  Zellen, laesst das Spielfeld neu malen und schaltet Menuebuttons ein/aus
-------------------------------------------------------------------------------}
begin
  // Datei oeffnen
  OpenFile;
  // ungueltige Zellen initaialisieren
  InitInvalidCells;
  // Spielfeld neu malen lassen
  dgField.Refresh;
  // Menuebuttons ein-/ausschalten
  SetMenuButtonsState;
end;

procedure TfrmMain.miExitClick(Sender: TObject);
{-------------------------------------------------------------------------------
Beschreibung:
  Schliesst das Programm
-------------------------------------------------------------------------------}
begin
  Close;
end;

procedure TfrmMain.miNewClick(Sender: TObject);
{-------------------------------------------------------------------------------
Beschreibung:
  Erstellt ein neues Spiel
-------------------------------------------------------------------------------}
var
  TmpStr: string;
begin
  // Name des geklickten Buttons auslesen
  TmpStr := (Sender as TMenuItem).Name;
  // letzten Buchstaben des Namens (=Spielfeldgroesse) extrahieren
  TmpStr := Copy(TmpStr, Length(TmpStr), 1);
  try
    // Spielfeldgroesse in der internen Darstellung setzen
    unitLogic.SetFieldSize(StrToInt(TmpStr));
    // Spielfeld initialisieren
    InitField(StrToInt(TmpStr));
    // ungueltige Zellen initialisieren
    InitInvalidCells;
    // Spielfeldgroesse (externe Darstellung) setzen
    SetFieldSize;
    // Buchfuehrungsmodus ausschalten
    miAccounting.Checked := false;
    // Spielfeld neu malen lassen
    dgField.Refresh;
    // Menuebuttons ein/ausschalten
    SetMenuButtonsState;
  except

  end;
end;

procedure TfrmMain.SetMenuButtonsState;
{-------------------------------------------------------------------------------
Beschreibung:
  Schaltet Menubuttons ein/aus
-------------------------------------------------------------------------------}
var
  i: byte;
begin
  // Eingabemodus aus
  miSetFixedDigits.Checked := false;
  // Buchfuehrungsbutton ein/aus
  miAccounting.Enabled := GetFieldSize in cAccountingSizes;
  // Spalten loesen-Buttons sichtbar/unsichtbar
  if miSolveCol.Count > 0 then
  begin
    for i := 0 to sqr(cFieldSizeMax)-1 do
      MenuItemsSolveCol[i].Visible := i < sqr(GetFieldSize);
  end;
  // Zeilen loesen-Buttons sichtbar/unsichtbar
  if miSolveRow.Count > 0 then
  begin
    for i := 0 to sqr(cFieldSizeMax)-1 do
      MenuItemsSolveRow[i].Visible := i < sqr(GetFieldSize);
  end;
end;

procedure TfrmMain.miVerifyClick(Sender: TObject);
{-------------------------------------------------------------------------------
Beschreibung:
  Ueberprueft, ob Sudoku geloest ist
-------------------------------------------------------------------------------}
var
  ErrorCode: TErrorCode;
  x: TColCount;
  y: TRowCount;
begin
  // ueberpruefen, ob Sudoku geloest
  if SudokuIsSolved(ErrorCode, x, y) then
    ShowMessage('Klasse! Das Sudoku ist gelöst! :-)')
  else
  begin
    // ungueltige Zellen berechnen
    SetInvalidCells(ErrorCode, x, y);
    dgField.Refresh;
    // Fehlermeldung
    ShowMessage('Sorry, du musst es wohl weiter versuchen! :-p ('+
                GetErrorMessage(ErrorCode)+')');
  end;
end;

procedure TfrmMain.miSolveClick(Sender: TObject);
{-------------------------------------------------------------------------------
Beschreibung:
  Loest das Sudoku
-------------------------------------------------------------------------------}
var
  ErrorCode: TErrorCode;
  x: TColCount;
  y: TRowCount;
  Field: TField;                          
begin
  // Cursor zur Eieruhr
  Screen.Cursor := crHourGlass;
  // Spielfeld schuetzen
  dgField.Enabled := false;
  // ueberpruefen, ob Sudoku loesbar
  if not SudokuIsSolvable(x, y, ErrorCode) then
  begin
    Screen.Cursor := crDefault;
    // ungueltige Zellen initialisieren
    InitInvalidCells;
    // ungueltige Zellen berechnen
    SetInvalidCells(ErrorCode, x, y);
    // Fehlermeldung
    ShowMessage(Format('Sudoku nicht lösbar! (%s)', [GetErrorMessage(ErrorCode)]))
  end
  else
  begin
    // Spielfeld sichern
    Field := GetField;
    // Versuch, Sudoku zu loesen
    if not SolveSudoku then
    begin
      // Spielfeld zuruecksetzen
      SetField(Field);
      // Fehlermeldung
      ShowMessage('Sudoku nicht lösbar!');
    end;
  end;
  // Spielfeld neu malen
  dgField.Refresh;
  // Spielfeldschutz aus
  dgField.Enabled := true;
  // Cursor zuruecksetzen
  Screen.Cursor := crDefault;
end;

procedure TfrmMain.miSetFixedDigitsClick(Sender: TObject);
{-------------------------------------------------------------------------------
Beschreibung:
  Laesst das Editieren des Spielfeldes zu
-------------------------------------------------------------------------------}
var
  TmpBoolean: boolean;
begin
  // ungueltige Zellen
  InitInvalidCells;
  // Ereignis ausloesen, um die selektierte Zelle un/-editierbar zu machen
  dgFieldSelectCell(nil, dgField.Selection.Left, dgField.Selection.Top,
    TmpBoolean);
end;

procedure TfrmMain.DrawCellBottomLine(Color: TColor; Width: integer);
{-------------------------------------------------------------------------------
Beschreibung:
  Malt den unteren Rand einer Spielfeldzelle
--------------------------------------------------------------------------------
Parameter(in):
  Color: Farbe des Randes
  Width: Dicke des Randes
-------------------------------------------------------------------------------}
begin
  with Cell.Canvas do
  begin
    Pen.Color := Color;
    Pen.Width := Width;
    MoveTo(0, Cell.Height-1);
    LineTo(Cell.Width, Cell.Height-1);
  end;
end;

procedure TfrmMain.DrawCellFrame(Color: TColor; Width: integer);
{-------------------------------------------------------------------------------
Beschreibung:
  Malt die Raender einer Zelle
--------------------------------------------------------------------------------
Parameter(in):
  Color: Farbe des Randes
  Width: Dicke des Randes
-------------------------------------------------------------------------------}
begin
  DrawCellLeftLine(Color, Width);
  DrawCellRightLine(Color, Width);
  DrawCellTopLine(Color, Width);
  DrawCellBottomLine(Color, Width);
end;

procedure TfrmMain.DrawCellLeftLine(Color: TColor; Width: integer);
{-------------------------------------------------------------------------------
Beschreibung:
  Malt den linken Rand einer Spielfeldzelle
--------------------------------------------------------------------------------
Parameter(in):
  Color: Farbe des Randes
  Width: Dicke des Randes
-------------------------------------------------------------------------------}
begin
  with Cell.Canvas do
  begin
    Pen.Color := Color;
    Pen.Width := Width;
    MoveTo(0, 0);
    LineTo(0, Cell.Height);
  end;
end;

procedure TfrmMain.DrawCellRightLine(Color: TColor; Width: integer);
{-------------------------------------------------------------------------------
Beschreibung:
  Malt den rechten Rand einer Spielfeldzelle
--------------------------------------------------------------------------------
Parameter(in):
  Color: Farbe des Randes
  Width: Dicke des Randes
-------------------------------------------------------------------------------}
begin
  with Cell.Canvas do
  begin
    Pen.Color := Color;
    Pen.Width := Width;
    MoveTo(Cell.Width-1, 0);
    LineTo(Cell.Width-1, Cell.Height);
  end;
end;

procedure TfrmMain.DrawCellTopLine(Color: TColor; Width: integer);
{-------------------------------------------------------------------------------
Beschreibung:
  Malt den oberen Rand einer Spielfeldzelle
--------------------------------------------------------------------------------
Parameter(in):
  Color: Farbe des Randes
  Width: Dicke des Randes
-------------------------------------------------------------------------------}
begin
  with Cell.Canvas do
  begin
    Pen.Color := Color;
    Pen.Width := Width;
    MoveTo(0, 0);
    LineTo(Cell.Width, 0);
  end;
end;

procedure TfrmMain.miSolveColClick(Sender: TObject);
{-------------------------------------------------------------------------------
Beschreibung:
  Loest ein Spalte
--------------------------------------------------------------------------------
Parameter(in):
  Sender: TObject: Menuebutton, der die Ereignisbehandlung ausloest
-------------------------------------------------------------------------------}
var
  x: TColCount;
  TmpStr: string;
  ColCells: TColCells;
begin
  // ungueltige Zellen
  InitInvalidCells;
  TmpStr := (Sender as TMenuItem).Name;
  try
    try
      // zweistellige Ziffer
      x := StrToInt(Copy(TmpStr, Length(TmpStr)-1, 2));
    except
      // einstellige Ziffer
      x := StrToInt(Copy(TmpStr, Length(TmpStr), 1));
    end;
    // Cursor aendern
    Screen.Cursor := crHourGlass;
    // Spalte ausgefuellt?
    if not ColIsFilled(x) then
    begin
      // Zellen sichern
      ColCells := GetColCells(x);
      // Versuch, Spalte zu loesen
      if not SolveCol(x) then
      begin
        // Zellen zuruecksetzen
        SetColCells(x, ColCells);
        // Fehlermeldung
        ShowMessage('Spalte nicht lösbar!');
      end;
    end;
    dgField.Refresh;
  except

  end;
  // Cursor zurueck
  Screen.Cursor := crDefault;
end;

procedure TfrmMain.miSolveRowClick(Sender: TObject);
{-------------------------------------------------------------------------------
Beschreibung:
  Loest eine Zeile
--------------------------------------------------------------------------------
Parameter(in):
  Sender: TObject: Buttton, der die Ereignisbehandlung ausloest
-------------------------------------------------------------------------------}
var
  y: TRowCount;
  TmpStr: string;
  RowCells: TRowCells;
begin
  // ungueltige Zellens
  InitInvalidCells;
  TmpStr := (Sender as TMenuItem).Name;
  try
    try
      // zweistellige Ziffer
      y := StrToInt(Copy(TmpStr, Length(TmpStr)-1, 2));
    except
      // einstellige Ziffer
      y := StrToInt(Copy(TmpStr, Length(TmpStr), 1));
    end;
    // Cursor setzen
    Screen.Cursor := crHourGlass;
    // ueberpruefen, ob Zeile bereits geloest
    if not RowIsFilled(y) then
    begin
      // Zellen sichern
      RowCells := GetRowCells(y);
      // Versuch, Zeile zu loesen
      if not SolveRow(y) then
      begin
        // Zellen zuruecksetzen
        SetRowCells(y, RowCells);
        ShowMessage('Zeile nicht lösbar!');
      end;
      // Spielfeld neu malen lassen
      dgField.Refresh;
    end;
  except

  end;
  // cursor zurueck
  Screen.Cursor := crDefault;
end;

procedure TfrmMain.FormShow(Sender: TObject);
{-------------------------------------------------------------------------------
Beschreibung:
  Weitere Initialisierungen
-------------------------------------------------------------------------------}
begin
  SetMenuButtonsState;
end;

end.
