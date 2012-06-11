//------------------------------------------------------------------------------
// Projekt: Sudoku
//
// Beschreibung:
// -------------
//   Enthaelt die Logik des Programms.
//
// Autor: Alexander Bertram
// erstellt am: 02.03.2006
//------------------------------------------------------------------------------
unit unitLogic;

interface

uses
  unitTypes, Graphics;

// initialisiert das Feld
procedure InitField(FieldSize: TFieldSize = cFieldSizeDefault);
// setzt/loescht eine Ziffer in einer Zelle
procedure SetCellValue(x: TColCount; y: TRowCount; Value: TDigit;
  Fix: boolean = false; DeleteValue: boolean = false);
// liest ein Zelle aus
function GetCellValue(x: TColCount; y: TRowCount; var Value: TDigit): boolean;
// ueberprueft, ob Zelle vorgegeben
function CellValueIsFixed(x: TColCount; y: TRowCount): boolean;
// setzt Spielfeldgroesse
procedure SetFieldSize(FieldSize: TFieldSize);
// liest Spielfeldgroesse aus
function GetFieldSize: TFieldSize;
// setzt das Spielfeld
procedure SetField(AField: TField);
// liest das Spielfeld aus
function GetField: TField;
// loest eine Zeile
function SolveRow(y: TRowCount): boolean;
// berechnet die Kandidaten einer Zelle
function GetCellPossibilities(x: TColCount; y: TRowCount;
  ExcludeInvalid: boolean = false): TDigitSet;
// ueberprueft, ob Sudoku geloest
function SudokuIsSolved(var ErrorCode: TErrorCode; var x: TColCount;
  var y: TRowCount): boolean;
// liefert die Fehlermeldung in Textform zurueck
function GetErrorMessage(ErrorCode: TErrorCode): string;
// liest die Zellen einer Zeile aus
function GetRowCells(y: TRowCount): TRowCells;
// setzt die Zellen einer Zeile
procedure SetRowCells(y: TRowCount; RowCells: TRowCells);
// loest eine Spalte
function SolveCol(x: TColCount): boolean;
// setzt ungueltige Zellen
procedure SetInvalidCells(ErrorCode: TErrorCode; x: TColCount; y: TRowCount);
// uebeprueft, ob Zelle ungueltig
function CellIsInvalid(x: TColCount; y: TrowCount): boolean;
// initialisiert/loescht ungueltige Zellen
procedure InitInvalidCells;
// ueberprueft, ob Sudoku loesbar ist
function SudokuIsSolvable(var x: TColCount; var y: TRowCount;
  var ErrorCode: TErrorCode): boolean;
// ueberprueft, ob einer Zeille ausgefuellt ist
function RowIsFilled(y: TRowCount): boolean;
// loest das Sudoku
function SolveSudoku: boolean;
// liefert die Farbe fuer eine Ziffer zurueck
function GetDigitColor(x: TColCount; y: TRowCount; Digit: TDigit): TColor;
// ueberprueft, ob eine Spalte ausgefuellt ist
function ColIsFilled(x: TColCount): boolean;
// liest die Zellen einer Spalte aus
function GetColCells(x: TColCount): TColCells;
// setzt die Zellen einer Spalte
procedure SetColCells(x: TColCount; ColCells: TColCells);

implementation

uses
  Forms
{$ifdef debug}
  , Dialogs, Windows, SysUtils
{$endif}
;

var
  // Spielfeld
  Field: TField;
  // ungueltige Zellen
  InvalidCells: TInvalidCells;

procedure SetCellValue(x: TColCount; y: TRowCount; Value: TDigit;
                       Fix: boolean = false;
                       DeleteValue: boolean = false);
{-------------------------------------------------------------------------------
Beschreibung:
  Setzt eine Zelle im Spielfeld
--------------------------------------------------------------------------------
Parameter(in):
  x: TColCount: Spalte
  y: TRowCount: Zeile
  Value: TDigit: Ziffer
  Fix: boolean: vorgegeben
  DeleteValue: Flag, ob Zelle geloescht werden soll
--------------------------------------------------------------------------------
globale Zugriffe:
  Field (schreibend): Spielfeld
-------------------------------------------------------------------------------}
begin
  Field.Cells[x, y].ValueExisting := not DeleteValue;
  Field.Cells[x, y].Fixed := not DeleteValue and Fix;
  Field.Cells[x, y].Value := Value;
end;

function GetCellValue(x: TColCount; y: TRowCount; var Value: TDigit): boolean;
{-------------------------------------------------------------------------------
Beschreibung:
  Liest eine Zelle aus
--------------------------------------------------------------------------------
Parameter(in):
  x: TColCount: Spalte
  y: TRowCount: Zeile
--------------------------------------------------------------------------------
Rückgabewert (out):
  Value: TDigit: Ziffer
  boolean: Zelle ausgelesen
--------------------------------------------------------------------------------
globale Zugriffe:
  Field (lesend): Spielfeld
-------------------------------------------------------------------------------}
begin
  GetCellValue := Field.Cells[x, y].ValueExisting;
  if Field.Cells[x, y].ValueExisting then
    Value := Field.Cells[x, y].Value;
end;

function CellValueIsFixed(x: TColCount; y: TRowCount): boolean;
{-------------------------------------------------------------------------------
Beschreibung:
  Ueberprueft, ob Zelle vorgegeben ist
--------------------------------------------------------------------------------
Parameter(in):
  x: TColCount: Spalte
  y: TRowCount: Zeile
--------------------------------------------------------------------------------
Rückgabewert (out):
  boolean: Zelle vorgegeben
-------------------------------------------------------------------------------}
begin
  CellValueIsFixed := Field.Cells[x, y].Fixed;
end;

procedure InitInvalidCells;
{-------------------------------------------------------------------------------
Beschreibung:
  Initialisiert/loescht ungueltige Zellen
--------------------------------------------------------------------------------
globale Zugriffe:
  InvalidCells (schreibend): Ungueltige Zellen
-------------------------------------------------------------------------------}
var
  i: TInvalidCellsCount;
begin
  for i := low(TInvalidCellsCount) to high(TInvalidCellsCount) do
    InvalidCells[i].Invalid := false;
end;

procedure SetFieldSize(FieldSize: TFieldSize);
{-------------------------------------------------------------------------------
Beschreibung:
  Setzt die Spielfeldgroesse
--------------------------------------------------------------------------------
Parameter(in):
  FieldSize: TFieldSize: Spielfeldgroesse
--------------------------------------------------------------------------------
globale Zugriffe:
  Field (schreibend): Spielfeld
-------------------------------------------------------------------------------}
begin
  Field.Size := FieldSize;
end;

function GetFieldSize: TFieldSize;
{-------------------------------------------------------------------------------
Beschreibung:
  Liest die Spielfeldgroesse aus
--------------------------------------------------------------------------------
Rückgabewert (out):
  TFieldSize: Spielfeldgroesse
--------------------------------------------------------------------------------
globale Zugriffe:
  Field (lesend): Spielfeld
-------------------------------------------------------------------------------}
begin
  GetFieldSize := Field.Size;
end;

procedure InitField(FieldSize: TFieldSize = cFieldSizeDefault);
{-------------------------------------------------------------------------------
Beschreibung:
  Iitialisiert das Spielfeld
--------------------------------------------------------------------------------
Parameter(in):
  FieldSize: TFieldSize: Spielfeldgroesse
-------------------------------------------------------------------------------}
var
  x: TColCount;
  y: TRowCount;
begin
  SetFieldSize(FieldSize);
  for x := low(TColCount) to high(TColCount) do
  begin
    for y := low(TRowCount) to high(TRowCount) do
      SetCellValue(x, y, TDigit(0), false, true);
  end;
  InitInvalidCells;
end;

procedure SetField(AField: TField);
{-------------------------------------------------------------------------------
Beschreibung:
  Setzt das Spielfeld
--------------------------------------------------------------------------------
Parameter(in):
  AField: TField: Spielfeld
--------------------------------------------------------------------------------
globale Zugriffe:
  Field (schreibend): Spielfeld
-------------------------------------------------------------------------------}
begin
  Field := AField;
end;

function GetField: TField;
{-------------------------------------------------------------------------------
Beschreibung:
  Liest das Spielfeld aus
--------------------------------------------------------------------------------
Rückgabewert (out):
  TField: Spielfeld
--------------------------------------------------------------------------------
globale Zugriffe:
  Field (lesend): Spielfeld
-------------------------------------------------------------------------------}
begin
  GetField := Field;
end;

procedure InitDigitSet(var DigitSet: TDigitSet);
{-------------------------------------------------------------------------------
Beschreibung:
  Initialisiert ein DigitSet mit [1..FieldSize²]
--------------------------------------------------------------------------------
Parameter(in):
  DigitSet: TDigitSet: DigitSet zum Initialisieren
--------------------------------------------------------------------------------
Rückgabewert (out):
  DigitSet: TDigitSet: initialisierte DigitSet
-------------------------------------------------------------------------------}
var
  i: TDigit;
begin
  DigitSet := [];
  for i := cDigitMin to sqr(GetFieldSize) do
    Include(DigitSet, i);
end;

procedure InitColPossibilities(var Col: TColPossibilities);
{-------------------------------------------------------------------------------
Beschreibung:
  Initialisiert Spaltenmoeglichkeiten
--------------------------------------------------------------------------------
Parameter(in):
  Col: TColPossibilities: Spaltenmoeglichkeiten zum Initialisieren
--------------------------------------------------------------------------------
Rückgabewert (out):
  Col: TColPossibilities: intialisierte Spaltenmoeglichkeiten
-------------------------------------------------------------------------------}
var
  i: TColCount;
  FieldSize: TFieldSize;
begin
  FieldSize := GetFieldSize;
  // Spielfeld horizontal durchlaufen
  for i := low(TRowCount) to sqr(FieldSize)-1 do
    InitDigitSet(Col[i]);
end;

procedure InitRowPossibilities(var Row: TRowPossibilities);
{-------------------------------------------------------------------------------
Beschreibung:
  Initialisiert Zeilenmoeglichkeiten
--------------------------------------------------------------------------------
Parameter(in):
  Row: TRowPossibilities: Zeilenmoeglichkeiten zum Initialisieren
--------------------------------------------------------------------------------
Rückgabewert (out):
  Row: TRowPossibilities: initialisierte Zeilenmoeglichkeiten
-------------------------------------------------------------------------------}
var
  y: TRowCount;
  FieldSize: TFieldSize;
begin
  FieldSize := GetFieldSize;
  // Spielfeld vertikal durchlaufen
  for y := low(TColCount) to sqr(FieldSize)-1 do
    InitDigitSet(Row[y]);
end;

procedure InitBlockPossibilities(var Block: TBlockPossibilities);
{-------------------------------------------------------------------------------
Beschreibung:
  Initialisiert Blockmoeglichkeiten mit [1..FieldSieze²]
--------------------------------------------------------------------------------
Parameter(in):
  Block: TBlockPossibilities: Blockmoeglichkeiten zum Initialisieren
--------------------------------------------------------------------------------
Rückgabewert (out):
  Block: TBlockPossibilities: initialisierte Blockmoeglichkeiten
-------------------------------------------------------------------------------}
var
  x, y: TBlockCount;
  FieldSize: TFieldSize;
begin
  FieldSize := GetFieldSize;
  for x := low(TBlockCount) to FieldSize-1 do
  begin
    for y := low(TBlockCount) to FieldSize-1 do
      InitDigitSet(Block[x, y]);
  end;
end;

function GetSingletonDigit(DigitSet: TDigitSet): TDigit;
{-------------------------------------------------------------------------------
Beschreibung:
  Liest eine Ziffer aus einem DigitSet mit nur einer Ziffer 
--------------------------------------------------------------------------------
Parameter(in):
  DigitSet: TDigitSet: DigitSet, aus dem die Ziffer ausglesen werden soll
--------------------------------------------------------------------------------
Rückgabewert (out):
  TDigit: ausgelesene Ziffer
-------------------------------------------------------------------------------}
var
  i: TDigit;
begin
  i := cDigitMin;
  while not (i in DigitSet) do
    inc(i);
  GetSingletonDigit := i;
end;

function GetDigitSetElementsCount(DigitSet: TDigitSet): byte;
{-------------------------------------------------------------------------------
Beschreibung:
  Berechnet die Anzahl der Ziffern in der Menge
--------------------------------------------------------------------------------
Parameter(in):
  DigitSet: TDigitSet: Ziffernmenge
--------------------------------------------------------------------------------
Rückgabewert (out):
  byte: Anzahl der Ziffern
-------------------------------------------------------------------------------}
var
  i: TDigit;
  j: byte;
begin
  j := 0;
  // alle moeglichen Ziffern durchgehen
  for i := low(TDigit) to sqr(GetFieldSize) do
  begin
    // Ziffer im DigitSet?
    if i in DigitSet then
      // zaehlen
      inc(j);
  end;

  GetDigitSetElementsCount := j;
end;

function GetColPossibilities(x: TColCount): TDigitSet;
{-------------------------------------------------------------------------------
Beschreibung:
  Berechnet die Ziffernmoeglichkeiten fuer eine Spalte
--------------------------------------------------------------------------------
Parameter(in):
  x: TColCount. Spalte
--------------------------------------------------------------------------------
Rückgabewert (out):
  TDigitSet: Ziffernmoeglichkeiten
-------------------------------------------------------------------------------}
var
  y: TRowCount;
  DigitSet: TDigitSet;
  Digit: TDigit;
begin
  InitDigitSet(DigitSet);

  // Spielfeld vertikal durchlaufen
  for y := low(TRowCount) to sqr(GetFieldSize)-1 do
  begin
    // Zelle gesetzt und Ziffer im DigitSet?
    if GetCellValue(x, y, Digit) and (Digit in DigitSet) then
      Exclude(DigitSet, Digit);
  end;

  GetColPossibilities := DigitSet;
end;

function GetRowPossibilities(y: TRowCount): TDigitSet;
{-------------------------------------------------------------------------------
Beschreibung:
  Berechnet die Ziffernmoeglichkeiten fuer eine Zeile
--------------------------------------------------------------------------------
Parameter(in):
  y: TRowCount: Zeile
--------------------------------------------------------------------------------
Rückgabewert (out):
  TDigitSet: Ziffernmoeglichkeiten
-------------------------------------------------------------------------------}
var
  x: TColCount;
  DigitSet: TDigitSet;
  Digit: TDigit;
begin
  InitDigitSet(DigitSet);
  // Spielfeld horizontal durchlaufen
  for x := low(TcolCount) to sqr(GetFieldSize)-1 do
  begin
    // Zelle gesetzt und Ziffer im DigitSet?
    if GetCellValue(x, y, Digit) and (Digit in DigitSet) then
      Exclude(DigitSet, Digit);
  end;
  GetRowPossibilities := DigitSet;
end;

function GetBlockPossibilities(x, y: TBlockCount): TDigitSet;
{-------------------------------------------------------------------------------
Beschreibung:
  Berechnet die Ziffernmoeglichkeiten fuer einen Block
--------------------------------------------------------------------------------
Parameter(in):
  x, y: TBlockCount: Blockkoordinaten
--------------------------------------------------------------------------------
Rückgabewert (out):
  TDigitSet: Ziffernmoeglichkeiten
-------------------------------------------------------------------------------}
var
  x1, y1: TBlockCount;
  Digit: TDigit;
  DigitSet: TDigitSet;
  BlockOffsetX, BlockOffsetY: byte;
  FieldSize: TFieldSize;
begin
  InitDigitSet(DigitSet);
  FieldSize := GetFieldSize;
  // Blockoffsets berechnen
  BlockOffsetX := x * FieldSize;
  BlockOffsetY := y * FieldSize;

  // eingetragene Zahlen des aktuellen Blocks aus dem Set rausnehmen
  for x1 := low(TBlockCount) to FieldSize-1 do
  begin
    for y1 := low(TBlockCount) to FieldSize-1 do
    begin
      if     GetCellValue(x1+BlockOffsetX, y1+BlockOffsetY, Digit)
         and (Digit in DigitSet) then
        Exclude(DigitSet, Digit);
    end;
  end;

  GetBlockPossibilities := DigitSet;
end;

function GetFirstDigitOfDigitSet(var DigitSet: TDigitSet;
  var Digit: TDigit1): boolean;
{-------------------------------------------------------------------------------
Beschreibung:
  Liest und Loescht die erste Ziffer aus dem FigitSet
--------------------------------------------------------------------------------
Parameter(in):
  DigitSet: TDigitSet: DigitSet
--------------------------------------------------------------------------------
Rückgabewert (out):
  DigitSet: TDigitSet: veraenderter DigitSet
  Digit: TDigit1: Ziffer
  boolean: Ziffer ausgelesen
-------------------------------------------------------------------------------}
var
  FieldSize: TFieldSize;
begin
  FieldSize := GetFieldSize;

  // erste Ziffer im DigitSet suchen
  Digit := low(TDigit);
  while (Digit <= sqr(FieldSize)) and not (Digit in DigitSet) do
    inc(Digit);
  // Ziffer "zurueckgeben" und aus dem DigitSet rausnehmen
  if Digit in DigitSet then
  begin
    Exclude(DigitSet, Digit);
    GetFirstDigitOfDigitSet := true;
  end
  else
    GetFirstDigitOfDigitSet := false;
end;

function ExcludeLockedCandidates(x: TColCount; y: TRowCount;
  CellPossibilities: TDigitSet): TDigitSet;
{-------------------------------------------------------------------------------
Beschreibung:
  Optimiert die uebergebenen Moeglichkeiten einer Zelle, in dem Kandidaten
  ausgeschlossen werden, die auf keinen Fall in der Zelle stehen koennen, weil
  sie in anderen Zellen stehen muessen.

  Algorithmus:
    Es wird eine Blockspalte/-zeile betrachtet. Befindet sich eine Ziffer unter
    den Moeglichkeiten dieser Blockspalte/-zeile, nicht aber unter den
    Moeglichkeiten der anderen Blockspalte/-zeilen in dem gleichen Block, kann
    sie in den Blockspalten/-zeilen dadrueber/-drunter/links/rechts davon
    ausgeschlossen werden.
--------------------------------------------------------------------------------
Parameter(in):
  x: TColCount: Spalte
  y: TRowCount: Zeile
  CellPossibilities: TDigitSet: zellmoeglichkeiten
--------------------------------------------------------------------------------
Rückgabewert (out):
  TDigitSet: optimierte Moeglichkeiten
-------------------------------------------------------------------------------}
var
  // Schleifenzaehler
  iBlock: TBlockCount;
  xBlock: TBlockColCount;
  yBlock: TBlockRowCount;
  // Offsets
  BlockColOffsetX,
  BlockRowOffsetX: TColCount;
  BlockColOffsetY,
  BlockRowOffsetY: TRowCount;
  // Spielfeldgroesse
  FieldSize: TFieldSize;
  // Moeglichkeiten pro Blockspalte pro Block
  BlockColPossibilities: array [TBlockCount] of TBlockColPossibilities;
  // Moeglichkeiten pro Blockszeile pro Block
  BlockRowPossibilities: array [TBlockCount] of TBlockRowPossibilities;
  // temporaere DigitSets
  DigitSet1,
  DigitSet2,
  TmpCellPossibilities: TDigitSet;
  // Ziffer
  Digit: TDigit;
begin
  FieldSize := GetFieldSize;

  // Blockspalten/-zeilen initialisieren
  for iBlock := low(TBlockCount) to FieldSize-1 do
  begin
    for xBlock := low(TBlockColCount) to FieldSize-1 do
      BlockColPossibilities[iBlock, xBlock] := [];
    for yBlock := low(TBlockRowCount) to FieldSize-1 do
      BlockRowPossibilities[iBlock, yBlock] := [];
  end;

  // horizontalen Blockspaltenoffset berechnen
  BlockColOffsetX := (x div FieldSize) * FieldSize;
  // vertikalen Blockzeilenoffset berechnen
  BlockRowOffsetY := (y div FieldSize) * FieldSize;
  // Bloecke durchlaufen
  for iBlock := low(TBlockCount) to FieldSize-1 do
  begin
    // vertikalen Blockspaltenoffset berechnen
    BlockColOffsetY := iBlock * FieldSize;
    // horizontalen Blockzeilenoffset berechnen
    BlockRowOffsetX := iBlock * FieldSize;
    // Blockspalten durchlaufen
    for xBlock := low(TBlockColCount) to FieldSize-1 do
    begin
      // Blockzeilen durchlaufen
      for yBlock := low(TBlockRowCount) to FieldSize-1 do
      begin
        // Blockspaltenmoeglichkeiten berechnen
        BlockColPossibilities[iBlock, xBlock] :=
          BlockColPossibilities[iBlock, xBlock]
          +GetCellPossibilities(xBlock+BlockColOffsetX, yBlock+BlockColOffsetY);
        // Blockzeilenmoeglichkeiten berechnen
        BlockRowPossibilities[iBlock, yBlock] :=
          BlockRowPossibilities[iBlock, yBlock]
          +GetCellPossibilities(xBlock+BlockRowOffsetX, yBlock+BlockRowOffsetY);
      end;
    end;

    // nur Bloecke mit einbeziehen, die unter/ueber dem Block mit der
    // uebergebener Zelle liegen
    if (y div FieldSize) <> iBlock then
    begin
      DigitSet1 := [];
      DigitSet2 := [];
      // temporaeren DigitSet bilden
      TmpCellPossibilities := CellPossibilities;
      // Bloecke horizontal durchlaufen
      for xBlock := low(TBlockColCount) to FieldSize-1 do
      begin
        // akt. Blockspalte = uebergebene Spalte
        if (xBlock + BlockColOffsetX) = x then
          DigitSet1 := BlockColPossibilities[iBlock, xBlock]
        // Blockspalten dadrueber/-drunters
        else
          DigitSet2 := DigitSet2 + BlockColPossibilities[iBlock, xBlock]
      end;
      // alle Ziffern aus dem DigitSet durchlaufen
      while GetFirstDigitOfDigitSet(TmpCellPossibilities, TDigit1(Digit)) do
      begin
        // ueberpruefen, ob
        // DigitSet nicht leer
        // Ziffer in der uebergebenen Spalte
        // Ziffer nicht in den anderen Spalte
        if     (DigitSet1 <> [])
           and (Digit in DigitSet1)
           and not (Digit in DigitSet2) then
          Exclude(CellPossibilities, Digit);
      end;
    end;
    // nur Bloecke mit einbeziehen, die links/rechts neben dem Block mit der
    // uebergebener Zelle liegen
    if (x div FieldSize) <> iBlock then
    begin
      DigitSet1 := [];
      DigitSet2 := [];
      TmpCellPossibilities := CellPossibilities;
      for yBlock := low(TBlockRowCount) to FieldSize-1 do
      begin
        // akt. Blockzeile = uebergebene Zeile
        if (yBlock + BlockRowOffsetY) = y then
          DigitSet1 := BlockRowPossibilities[iBlock, yBlock]
        // andere Blockzeilen
        else
          DigitSet2 := DigitSet2 + BlockRowPossibilities[iBlock, yBlock]
      end;
      // alle Ziffern aus dem DigitSet durchlaufen
      while GetFirstDigitOfDigitSet(TmpCellPossibilities, TDigit1(Digit)) do
      begin
        // ueberpruefen, ob
        // DigitSet nicht leer
        // Ziffer in der uebergebenen Spalte
        // Ziffer nicht in den anderen Spalte
        if     (DigitSet1 <> [])
           and (Digit in DigitSet1)
           and not (Digit in DigitSet2) then
          Exclude(CellPossibilities, Digit);
      end;
    end;
  end;

  ExcludeLockedCandidates := CellPossibilities;
end;

function GetCellPossibilities(x: TColCount; y: TRowCount;
  ExcludeInvalid: boolean = false): TDigitSet;
{-------------------------------------------------------------------------------
Beschreibung:
  Berechnet die Ziffernmoeglichkeiten fuer eine Zelle
--------------------------------------------------------------------------------
Parameter(in):
  x: TColCount: Spalte
  y: TRowCount: Zeile
  ExcludeInvalid: boolean: Moeglichkeiten optimieren
--------------------------------------------------------------------------------
Rückgabewert (out):
  TDigitSet: Ziffernmoeglichkeiten
-------------------------------------------------------------------------------}
var
  Digit: TDigit;
  ResultCellPossibilities: TDigitSet;
  FieldSize: TFieldSize;
begin
  // Zelle gesetzt?
  if GetCellValue(x, y, Digit) then
    ResultCellPossibilities := []
  else
  begin
    FieldSize := GetFieldSize;
    // Schnittmenge der Spalte, Zeile und des Blockes an den Koordinaten bilden
    ResultCellPossibilities :=   GetColPossibilities(x)
                               * GetRowPossibilities(y)
                               * GetBlockPossibilities(x div FieldSize,
                                                       y div FieldSize);
  end;

  // Moeglichkeiten optimieren?
  if (ResultCellPossibilities <> []) and ExcludeInvalid then
    ResultCellPossibilities := ExcludeLockedCandidates(x, y,
      ResultCellPossibilities);

  GetCellPossibilities := ResultCellPossibilities;
end;

function SetColSingles(x: TColCount;
  var RowPossibilities: TRowPossibilities): boolean;
{-------------------------------------------------------------------------------
Beschreibung: sucht Zellen in einer Spalte entweder mit einelementiger Menge
              oder mit nur einer regelkonformen Möglichkeit und setzt diese
--------------------------------------------------------------------------------
Parameter(in):
  x: TColCount: Spalte
  RowPossibilities: Moeglichkeiten in den einzelnen Zellen dieser Spalte
--------------------------------------------------------------------------------
Rückgabewert (out):
  RowPossibilities: evtl. veraenderte Moglichkeiten
  boolean: Zellen gefunden/gesetzt
-------------------------------------------------------------------------------}
var
  y, y1, y2: TRowCount;
  Digit: TDigit;
  DigitSet: TDigitSet;
  Counter: byte;
  SingletonsAvailable: boolean;
  Res: boolean;
  FieldSize: TFieldSize;
begin
  y2 := low(TRowCount);
  SingletonsAvailable := true;
  Res := false;
  FieldSize := GetFieldSize;

  // solange Songletons gefunden werden
  while SingletonsAvailable do
  begin
    SingletonsAvailable := false;
    DigitSet := [];
    // Schnittmenge aller Zellen der Spalte bilden
    for y := low(TRowCount) to sqr(FieldSize)-1 do
      DigitSet := DigitSet + RowPossibilities[y];
    // alle Ziffern durchgehen
    for Digit := cDigitMin to sqr(FieldSize) do
    begin
      // Ziffer im Set?
      if Digit in DigitSet then
      begin
        Counter := 0;
        // Spielfeld vertikal durchgehen
        for y := low(TRowCount) to sqr(FieldSize)-1 do
        begin
          // Ziffer in der aktuellen Zelle?
          if Digit in RowPossibilities[y] then
          begin
            // Anzahl der Ziffernmoeglichkeiten pro Zelle zaehlen
            inc(Counter);
            // Zeile merken
            y2 := y;
          end;
          // Singleton?
          if GetDigitSetElementsCount(RowPossibilities[y]) = 1 then
          begin
            SingletonsAvailable := true;
            Res := true;
            // Zelle setzen
            SetCellValue(x, y, GetSingletonDigit(RowPossibilities[y]));
          end;
        end;
        // mehrere Ziffern moeglich, aber nur eine davon regelkonform
        if Counter = 1 then
        begin
          SingletonsAvailable := true;
          Res := true;
          // Zelle setzen
          SetCellValue(x, y2, Digit);
        end;
      end;
    end;
    // Singletons gefunden?
    if SingletonsAvailable then
    begin
      // Zeilenmoeglichkeiten aktualisieren
      for y1 := low(TRowCount) to sqr(FieldSize)-1 do
        RowPossibilities[y1] := GetCellPossibilities(x, y1);
    end;
  end;

  SetColSingles := Res;
end;

function GetDoubleDigitsInCol(x: TColCount; var y1, y2: TRowCount1): boolean;
{-------------------------------------------------------------------------------
Beschreibung:
  Sucht doppelte Ziffern in einer Spalte
--------------------------------------------------------------------------------
Parameter(in):
  x: TColCount;: Spalte
--------------------------------------------------------------------------------
Rückgabewert (out):
  y1, y2: TRowCount1: Zeilen, in denen evtl. doppelte Ziffern stehen
  boolean: doppelte Werte gefunden
-------------------------------------------------------------------------------}
var
  Digit1, Digit2: TDigit;
  DigitsFound: boolean;
  FieldSize: TFieldSize;
begin
  FieldSize := GetFieldSize;
  DigitsFound := false;

  // Spalte durchlaufen
  y1 := low(TRowCount);
  while (y1 < sqr(FieldSize)-1) and not DigitsFound do
  begin
    // Zelle gesetzt?
    if GetCellValue(x, y1, Digit1) then
    begin
      // den Rest der Splate durchlaufen
      y2 := y1 + 1;
      while (y2 <= sqr(FieldSize)-1) and not DigitsFound do
      begin
        // ueberpruefen, ob Ziffern gleich sind
        DigitsFound := GetCellValue(x, y2, Digit2) and (Digit1 = Digit2);
        if not DigitsFound then
          inc(y2);
      end;
    end;
    if not DigitsFound then
      inc(y1);
  end;

  GetDoubleDigitsInCol := DigitsFound;
end;

function ColIsSolvable(x: TColCount; RowPossibilities: TRowPossibilities;
  var y: TRowCount; var ErrorCode: TErrorCode): boolean;
{-------------------------------------------------------------------------------
Beschreibung:
  Ueberprueft, ob Spalte loesbar ist
--------------------------------------------------------------------------------
Parameter(in):
  x: TColCount: Spalte
  RowPossibilities: TRowPossibilities: Zeilenmoeglichkeiten
--------------------------------------------------------------------------------
Rückgabewert (out):
  y: TRowCount: Zeile, falls die Spalte nicht loesbar ist, in der, der Fehler
                auftritt
  ErrorCode: TErrorCode: Fehlercode
  boolean: Spalte loesbar
-------------------------------------------------------------------------------}
var
  y1, y2: TRowCount1;
  Solvable: boolean;
begin
  // ueberpurefen, ob keine Zahlen doppelt vorkommen
  Solvable := not GetDoubleDigitsInCol(x, y1, y2);
  if not Solvable then
    ErrorCode := ERR_DOUBLE_DIGITS_IN_COL;

  ColIsSolvable := Solvable;
end;

function GetColCells(x: TColCount): TColCells;
{-------------------------------------------------------------------------------
Beschreibung:
  Liest die Zellen einer Spalte aus
--------------------------------------------------------------------------------
Parameter(in):
  x: TColCount: Spalte
--------------------------------------------------------------------------------
Rückgabewert (out):
  TColCells: Spaltenzellen
--------------------------------------------------------------------------------
globale Zugriffe:
  Field (lesend): Spielfeld
-------------------------------------------------------------------------------}
var
  y: TRowCount;
  ColCells: TColCells;
begin
  // Spielfeld vertikal durchlaufen
  for y := low(TRowCount) to sqr(GetFieldSize)-1 do
    // Zellen merken
    ColCells[y] := Field.Cells[x, y];

  GetColCells := ColCells;
end;

procedure SetColCells(x: TColCount; ColCells: TColCells);
{-------------------------------------------------------------------------------
Beschreibung:
  Setzt die Zellen einer Spalte
--------------------------------------------------------------------------------
Parameter(in):
  x: TColCount: Spalte
  ColCells: TColCells: Zellen
--------------------------------------------------------------------------------
globale Zugriffe:
  Field (schreibend): Spielfeld
-------------------------------------------------------------------------------}
var
  y: TRowCount;
begin
  // Spielfeld vertikal durchlaufen
  for y := low(TRowCount) to sqr(GetFieldSize)-1 do
    // Zellen setzen
    Field.Cells[x, y] := ColCells[y];
end;

function SetRowSingles(y: TRowCount;
  var ColPossibilities: TColPossibilities): boolean;
{-------------------------------------------------------------------------------
Beschreibung:
  sucht Zellen in einer Zeile entweder mit einelementiger Menge oder mit nur
  einer regelkonformen Moeglichkeit
--------------------------------------------------------------------------------
Parameter(in):
  y: TRowCount: Zeile
  ColPossibilities: TColPossibilities: Moeglichkeiten pro Spalte
--------------------------------------------------------------------------------
Rückgabewert (out):
  boolean: Singletons gefunden/gesetzt
-------------------------------------------------------------------------------}
var
  x, x1, x2: TColCount;
  Digit: TDigit;
  DigitSet: TDigitSet;
  Counter: byte;
  SingletonsAvailable: boolean;
  Res: boolean;
  FieldSize: TFieldSize;
begin
  x2 := low(TColCount);
  SingletonsAvailable := true;
  Res := false;
  FieldSize := GetFieldSize;

  // solange Singletons gefunden werden
  while SingletonsAvailable do
  begin
    SingletonsAvailable := false;
    DigitSet := [];
    // Schnittmege der Spaltenmoeglichkeiten
    for x := low(TColCount) to sqr(FieldSize)-1 do
      DigitSet := DigitSet + ColPossibilities[x];
    // alle Ziffern durchlaufen
    for Digit := cDigitMin to sqr(FieldSize) do
    begin
      // Ziffer im DigitSet?
      if Digit in DigitSet then
      begin
        Counter := 0;
        // Spielfeld horizontal durchlaufen
        for x := low(TColCount) to sqr(FieldSize)-1 do
        begin
          // Ziffer in der Zelle?
          if Digit in ColPossibilities[x] then
          begin
            // Moeglichkeiten der Ziffer pro Zelle zaehlen
            inc(Counter);
            // Spalte merken
            x2 := x;
          end;
          // einelementige Menge?
          if GetDigitSetElementsCount(ColPossibilities[x]) = 1 then
          begin
            SingletonsAvailable := true;
            Res := true;
            // Zelle setzen
            SetCellValue(x, y, GetSingletonDigit(ColPossibilities[x]));
          end;
        end;
        // mehrere Zahlen möglich, aber nur eine davon regelkonform
        if Counter = 1 then
        begin
          SingletonsAvailable := true;
          Res := true;
          // Zelle setzen
          SetCellValue(x2, y, Digit);
        end;
        // Singletons gefunden?
        if SingletonsAvailable then
        begin
          // Spaltenmoeglichkeiten aktualisieren
          for x1 := low(TColCount) to sqr(FieldSize)-1 do
            ColPossibilities[x1] := GetCellPossibilities(x1, y);
        end;
      end;
    end;
  end;

  SetRowSingles := Res;
end;

function SolveSudokuByLogic: boolean;
{-------------------------------------------------------------------------------
Beschreibung:
  Loest das Sudoku soweit wie moeglich durch Logik
--------------------------------------------------------------------------------
Rückgabewert (out):
  boolean: Sudoku geloest
-------------------------------------------------------------------------------}
var
  x: TColCount;
  y: TRowCount;
  ColPossibilities: array [TRowCount] of TColPossibilities;
  RowPossibilities: array [TColCount] of TRowPossibilities;
  CellSolved: boolean;
  ErrorCode: TErrorCode;
  FieldSize: TFieldSize;
begin
  FieldSize := GetFieldSize;

  // Zeilenmoeglichkeiten berechnen
  for x := low(TColCount) to sqr(FieldSize)-1 do
  begin
    for y := low(TRowCount) to sqr(FieldSize)-1 do
      RowPossibilities[x, y] := GetCellPossibilities(x, y, true);
  end;

  // Singles in den Spalten loesen, bis keine Singles mehr gefunden werden
  repeat
    CellSolved := false;
    for x := low(TColCount) to sqr(FieldSize)-1 do
      CellSolved := SetColSingles(x, RowPossibilities[x]) or CellSolved;
  until not CellSolved;

  // Spaltenmoeglichkeiten berechnen
  for y := low(TRowCount) to sqr(FieldSize)-1 do
  begin
    for x := low(TColCount) to sqr(FieldSize)-1 do
      ColPossibilities[y, x] := GetCellPossibilities(x, y, true);
  end;

  // Singles in den Zeilen loesen, bis keine Singles mehr gefunden werden
  repeat
    CellSolved := false;
    for y := low(TRowCount) to sqr(FieldSize)-1 do
      CellSolved := SetRowSingles(y, ColPossibilities[y]) or CellSolved;
    // wenn eine Zelle geloest wurde, das Ganze nochmal starten
    if CellSolved then
      if SolveSudokuByLogic then;
  until not CellSolved;

  SolveSudokuByLogic := SudokuIsSolved(ErrorCode, x, y);
end;

function SolveSudokuByBacktracking(AField: TField; x: TColCount;
  y: TRowCount): boolean;
{-------------------------------------------------------------------------------
Beschreibung:
  Loest ein Sudoku durch Backtracking
--------------------------------------------------------------------------------
Parameter(in):
  AField: TField: zu loesendes Feld
  x: TColCount: Spalte, in der das Loesen beginnen soll
  y: TRowCount: Zeile, in der das Loesen beginnen soll
--------------------------------------------------------------------------------
Rückgabewert (out):
  boolean: Sudoku geloest
-------------------------------------------------------------------------------}
var
  x1: TColCount1;
  y1: TRowCount1;
  x2: TColCount;
  y2: TRowCount;
  ErrorCode: TErrorCode;
  EmptyFound,
  PossibilitiesSelected: boolean;
  Digit: TDigit;
  CellPossibilities: TDigitSet;
  FieldSize: TFieldSize;
  Res: boolean;
begin
  Application.ProcessMessages;
  // Sudoku loesbar?
  if not SudokuIsSolvable(x2, y2, ErrorCode) then
    Res := false
  else
  begin
    // Zellenmoeglichkieten leeren
    CellPossibilities := [];
    // Zellmoeglichkeiten wurden noch nicht berechnet
    PossibilitiesSelected := false;
    // Spielfeldgroesse auslesen
    FieldSize := GetFieldSize;
    repeat
      // zu loesendes Feld setzen
      SetField(AField);
      // Versuch durch Logik zu loesen
      if SolveSudokuByLogic then;
      // noch keine leere Zelle gefunden
      EmptyFound := false;
      x1 := x;
      y1 := y;
      // y ausserhalb des Spielfeldes?
      if y > sqr(FieldSize)-1 then
        // Spalte inkrementieren
        inc(x1);
      // die erste leere Zelle suchen
      while (x1 <= sqr(FieldSize)-1) and not EmptyFound do
      begin
        // y1 aussehalb des Spielfeldes?
        if y1 > sqr(FieldSize)-1 then
          // y1 zuruecksetzen
          y1 := low(TrowCount);
        while (y1 <= sqr(FieldSize)-1) and not EmptyFound do
        begin
          EmptyFound := not GetCellValue(x1, y1, Digit);
          if not EmptyFound then
            inc(y1);
        end;
        if not EmptyFound then
          inc(x1);
      end;
      // Zellmoeglichkeiten berechnet?
      // x1 und y1 innerhalb des Spielfeldes?
      if     not PossibilitiesSelected
         and (x1 <= sqr(FieldSize)-1)
         and (y1 <= sqr(FieldSize)-1) then
      begin
        // Zellmoeglichkeiten berechnen
        CellPossibilities := GetCellPossibilities(x1, y1);
        // Flag setzen, damit die Moeglichkeiten pro Zelle nur ein Mal berechnet
        // werden
        PossibilitiesSelected := true;
      end;
      // erste Ziffer aus dem DigitSet auslesen
      if GetFirstDigitOfDigitSet(CellPossibilities, TDigit1(Digit)) then
      begin
        // Zelle setzen
        SetCellValue(x1, y1, Digit);
        // y1 modulo Spielfeldgroesse inkrementieren
        y1 := (y1 + 1) mod (sqr(FieldSize));
        // Rekursion starten
        if not SolveSudokuByBacktracking(GetField, x1, y1) then
          SetField(AField);
      end;
      // ueberpruefen, ob Sudoku erfolgreich geloest
      Res := SudokuIsSolved(ErrorCode, x2, y2);
    // Austrittsbedingungen:
    // Zellmoeglichkeiten leer
    // Sudoku geloest
    // x1 oder y1 ausserhalb des Spielfeldes
    until    (CellPossibilities = [])
          or Res
          or (x1 > sqr(FieldSize)-1)
          or (y1 > sqr(FieldSize)-1);
  end;

  SolveSudokuByBacktracking := Res;
end;

function SolveSudoku: boolean;
{-------------------------------------------------------------------------------
Beschreibung:
  Ruft Prozeduren auf, um ein Sudoku zu loesen
--------------------------------------------------------------------------------
Rückgabewert (out):
  boolean: Sudoku geloest
-------------------------------------------------------------------------------}
{$ifdef debug}
var
  StartTime: longword;
{$endif}
begin
{$ifdef debug}
  StartTime := GetTickCount;
{$endif}
  // Sudoku durch Logik oder durch Backtracking loesen
  SolveSudoku :=    SolveSudokuByLogic
                 or SolveSudokuByBacktracking(GetField, low(TColCount),
                      low(TRowCount));
{$ifdef debug}
  ShowMessage(IntToStr((GetTickCount-StartTime) div 1000)+' s');
{$endif}
end;

function SolveCol(x: TColCount): boolean;
{-------------------------------------------------------------------------------
Beschreibung:
  Loest eine Spalte
--------------------------------------------------------------------------------
Parameter(in):
  x: TColCount: Spalte
--------------------------------------------------------------------------------
Rückgabewert (out):
  boolean: Spalte geloest
-------------------------------------------------------------------------------}
var
  x1: TColCount;
  Solved: boolean;
  FieldSize: TFieldSize;
  Cols: array [TColCount] of TColCells;
begin
  FieldSize := GetFieldSize;

  // alle Spalten ausser der zu loesenden merken
  for x1 := low(TColCount) to sqr(FieldSize)-1 do
  begin
    if x1 <> x then
      Cols[x1] := GetColCells(x1);
  end;

  // Sudoku loesen
  Solved := SolveSudoku;

  // gemerkte Spalten zuruecksetzen
  for x1 := low(TColCount) to sqr(FieldSize)-1 do
  begin
    if x1 <> x then
      SetColCells(x1, Cols[x1]);
  end;

  SolveCol := Solved;
end;

function GetDoubleDigitsInRow(y: TRowCount; var x1, x2: TColCount1): boolean;
{-------------------------------------------------------------------------------
Beschreibung:
  Sucht doppelte Ziffern in einer Zeile
--------------------------------------------------------------------------------
Parameter(in):
  y: TRowCount: Zeile
--------------------------------------------------------------------------------
Rückgabewert (out):
  x1, x2: TColCount1: Spalten, in denen evtl. doppelte Ziffern stehen
  boolean: doppelte Werte gefunden
-------------------------------------------------------------------------------}
var
  Digit1, Digit2: TDigit;
  DigitsFound: boolean;
  FieldSize: TFieldSize;
begin
  FieldSize := GetFieldSize;
  DigitsFound := false;

  // Zeile durchlaufen
  x1 := low(TRowCount);
  while (x1 < sqr(FieldSize)-1) and not DigitsFound do
  begin
    // Zelle gesetzt?
    if GetCellValue(x1, y, Digit1) then
    begin
      // den Rest der Zeile durchlaufen
      x2 := x1 + 1;
      while (x2 <= sqr(FieldSize)-1) and not DigitsFound do
      begin
        // Ziffern vergleichen
        DigitsFound := GetCellValue(x2, y, Digit2) and (Digit1 = Digit2);
        if not DigitsFound then
          inc(x2);
      end;
    end;
    if not DigitsFound then
      inc(x1);
  end;

  GetDoubleDigitsInRow := DigitsFound;
end;

function RowIsSolvable(y: TRowCount; ColPossibilities: TColPossibilities;
  var x: TColCount; var ErrorCode: TErrorCode): boolean;
{-------------------------------------------------------------------------------
Beschreibung:
  Ueberprueft, ob eine Zeile loesbar ist
--------------------------------------------------------------------------------
Parameter(in):
  y: TRowCount: Zeile
  ColPossibilities: TColPossibilities: Ziffernmoeglichkeiten pro Zelle der Zeile
--------------------------------------------------------------------------------
Rückgabewert (out):
  x: TColCount: Spalte, in der der Fehler auftritt, falls nicht loesbar
  ErrorCode: TErrorCode: Fehlercode
  boolean: Zeile loesbar
-------------------------------------------------------------------------------}
var
  x1, x2: TColCount1;
  Solvable: boolean;
begin
  // ... und ob keine Zahlen doppelt vorkommen
  Solvable := not GetDoubleDigitsInRow(y, x1, x2);
  if not Solvable then
    ErrorCode := ERR_DOUBLE_DIGITS_IN_ROW;

  RowIsSolvable := Solvable;
end;

function GetRowCells(y: TRowCount): TRowCells;
{-------------------------------------------------------------------------------
Beschreibung:
  Liest die Zellen einer Zeile aus
--------------------------------------------------------------------------------
Parameter(in):
  y: TRowCount: Zeile
--------------------------------------------------------------------------------
Rückgabewert (out):
  TRowCells: Zellen der Zeile
--------------------------------------------------------------------------------
globale Zugriffe:
   Field (lesend): Spielfeld
-------------------------------------------------------------------------------}
var
  x: TColCount;
  RowCells: TRowCells;
begin
  for x := low(TColCount) to sqr(GetFieldSize)-1 do
  begin
    RowCells[x] := Field.Cells[x, y];
  end;

  GetRowCells := RowCells;
end;

procedure SetRowCells(y: TRowCount; RowCells: TRowCells);
{-------------------------------------------------------------------------------
Beschreibung:
  Setzt die Zellen einer Zeile
--------------------------------------------------------------------------------
Parameter(in):
  y: TRowCount: Zeile
  RowCells: TRowCells: Zellen
--------------------------------------------------------------------------------
globale Zugriffe:
  Field (schreibend): Spielfeld
-------------------------------------------------------------------------------}
var
  x: TColCount;
begin
  // Zeile durchlaufen
  for x := low(TColCount) to sqr(GetFieldSize)-1 do
    Field.Cells[x, y] := RowCells[x];
end;

function SolveRow(y: TRowCount): boolean;
{-------------------------------------------------------------------------------
Beschreibung:
  Loest ein Zeile
--------------------------------------------------------------------------------
Parameter(in):
  y: TRowCount: Zeile
--------------------------------------------------------------------------------
Rückgabewert (out):
  boolean
--------------------------------------------------------------------------------
globale Zugriffe: -
-------------------------------------------------------------------------------}
var
  y1: TRowCount;
  Solved: boolean;
  FieldSize: TFieldSize;
  Rows: array [TRowCount] of TRowCells;
begin
  FieldSize := GetFieldSize;

  // alle Zeilen, ausser der zu loesenden merken
  for y1 := low(TRowCount) to sqr(FieldSize)-1 do
  begin
    if y1 <> y then
      Rows[y1] := GetRowCells(y1);
  end;

  // Sudoku loesen
  Solved := SolveSudoku;

  // alle gemerkten Zeilen zuruecksetzen
  for y1 := low(TRowCount) to sqr(FieldSize)-1 do
  begin
    if y1 <> y then
      SetRowCells(y1, Rows[y1]);
  end;

  SolveRow := Solved;
end;

function GetDoubleDigitsInBlock(var x1, x2: TColCount;
  var y1, y2: TRowCount): boolean;
{-------------------------------------------------------------------------------
Beschreibung:
  Sucht doppelte Ziffern in einem Block
--------------------------------------------------------------------------------
Parameter(in):
  x1: TColCount; y1: TRowCount: Zellkoordinaten
--------------------------------------------------------------------------------
Rückgabewert (out):
  x1, x2: TColCount; y1, y2: TRowCount: Koordinaten, in denen evtl. dopplete
                             Werte stehen
  boolean: doppelte Werte gefunden
-------------------------------------------------------------------------------}
var
  Digit1, Digit2: TDigit;
  DigitsFound: boolean;
  OffsetX, OffsetY: byte;
  FieldSize: TFieldSize;
begin
  FieldSize := GetFieldSize;
  DigitsFound := false;
  // Offsets berechnen
  OffsetX := (x1 div FieldSize) * FieldSize;
  OffSetY := (y1 div FieldSize) * FieldSize;

  // Block vertikal durchlaufen
  x1 := low(TBlockColCount);
  while (x1 <= FieldSize-1) and not DigitsFound do
  begin
    // Block horizontal durchlaufen
    y1 := low(TBlockRowCount);
    while (y1 <= FieldSize-1) and not DigitsFound do
    begin
      // Zelle gesetzt?
      if GetCellValue(x1+OffsetX, y1+OffsetY, Digit1) then
      begin
        // restlichen Block horizontal durchlaufen
        x2 := x1;
        y2 := y1 + 1;
        if y2 > FieldSize-1 then
          inc(x2);
        while (x2 <= FieldSize-1) and not DigitsFound do
        begin
          // restlichen Block vertikal durchlaufen
          if y2 > FieldSize-1 then
            y2 := low(TBlockRowCount);
          while (y2 <= FieldSize-1) and not DigitsFound do
          begin
            // Ziffern vergleichen
            DigitsFound :=     GetCellValue(x2+OffsetX, y2+OffsetY, Digit2)
                           and (Digit1 = Digit2);
            if not DigitsFound then
              inc(y2);
          end;
          if not DigitsFound then
            inc(x2);
        end;
      end;
      if not DigitsFound then
        inc(y1);
    end;
    if not DigitsFound then
      inc(x1);
  end;

  GetDoubleDigitsInBlock := DigitsFound;
end;

procedure SetInvalidCell(Index: TInvalidCellsCount; Invalid: boolean;
  x: TColCount; y: TRowCount);
{-------------------------------------------------------------------------------
Beschreibung:
  Markiert ungueltige Zelle
--------------------------------------------------------------------------------
Parameter(in):
  Index: TInvalidCellsCount: Index im Array
  Invalid: boolean: ungueltig
  x: TColCount: Spalte
  y: TRowCount: Zeile
--------------------------------------------------------------------------------
globale Zugriffe:
  InvalidCells (schreibend): ungueltige Zellen
-------------------------------------------------------------------------------}
begin
  InvalidCells[Index].Invalid := Invalid;
  InvalidCells[Index].x := x;
  InvalidCells[Index].y := y;
end;

procedure SetInvalidCells(ErrorCode: TErrorCode; x: TColCount; y: TRowCount);
{-------------------------------------------------------------------------------
Beschreibung:
  Markiert ungueltige Zellen
--------------------------------------------------------------------------------
Parameter(in):
  ErrorCode: TErrorCode:Fehlercode
  x: TColCount: Spalte
  y: TRowCount: Zeile
-------------------------------------------------------------------------------}
var
  x1, x2: TColCount;
  y1, y2: TRowCount;
begin
  x1 := x;
  x2 := x;
  y1 := y;
  y2 := y;
  // je nach Fehlercode die Koordinaten berechnen
  case ErrorCode of
    ERR_DOUBLE_DIGITS_IN_COL:
      if GetDoubleDigitsInCol(x, TRowCount1(y1), TRowCount1(y2)) then;
    ERR_DOUBLE_DIGITS_IN_ROW:
      if GetDoubleDigitsInRow(y, TColCount1(x1), TColCount1(x2)) then;
    ERR_DOUBLE_DIGITS_IN_BLOCK:
      if GetDoubleDigitsInBlock(x1, x2, y1, y2) then;
  end;
  // Zellen setzen
  SetInvalidCell(0, true, x1, y1);
  SetInvalidCell(1, true, x2, y2);
end;

function CellIsInvalid(x: TColCount; y: TrowCount): boolean;
{-------------------------------------------------------------------------------
Beschreibung:
  Ueberprueft, ob eine Zelle als ungueltig markiert ist
--------------------------------------------------------------------------------
Parameter(in):
  x: TColCount: Spalte
  y: TrowCount: Zeile
--------------------------------------------------------------------------------
Rückgabewert (out):
  boolean: Zelle ungueltig
--------------------------------------------------------------------------------
globale Zugriffe:
  InvalidCells (lesend): ungueltige Zellen
-------------------------------------------------------------------------------}
var
  i: TInvalidCellsCount1;
  Res: boolean;
begin
  Res := false;

  // alle ungueltigen Zellen durchlaufen
  i := low(TInvalidCellsCount);
  while (i <= high(TInvalidCellsCount)) and not Res do
  begin
    // uebergebene Koordinaten mit den aktuellen vergleichen
    Res :=     InvalidCells[i].Invalid
           and (InvalidCells[i].x = x)
           and (InvalidCells[i].y = y);
    inc(i);
  end;

  CellIsInvalid := Res;
end;

function SudokuIsSolved(var ErrorCode: TErrorCode; var x: TColCount;
  var y: TRowCount): boolean;
{-------------------------------------------------------------------------------
Beschreibung:
  Ueberprueft, ob das Sudoku geloest ist
--------------------------------------------------------------------------------
Rückgabewert (out):
  ErrorCode: TErrorCode: Fehlercode, falls nicht geloest
  x: TColCount: Spalte, in der der Fehler auftritt
  y: TRowCount: Zeile, in der der Fehler auftritt
  boolean: Sudoku ist geloest
-------------------------------------------------------------------------------}
var
  x1, x2: TColCount1;
  y1, y2: TRowCount1;
  Digit1, Digit2: TDigit;
  Solved: boolean;
  BlockPossibilities: TBlockPossibilities;
  FieldSize: TFieldSize;
begin
  x1 := low(TColCount);
  Solved := true;
  InitBlockPossibilities(BlockPossibilities);
  FieldSize := GetFieldSize;

  while (x1 <= sqr(FieldSize)-1) and Solved do
  begin
    y1 := low(TRowCount);
    while (y1 <= sqr(FieldSize)-1) and Solved do
    begin
      // Auf leere Zellen überprüfen
      Solved := GetCellValue(x1, y1, Digit1);

      if Solved then
        Exclude(BlockPossibilities[x1 div FieldSize, y1 div FieldSize], Digit1)
      else
      begin
        ErrorCode := ERR_EMPTY_CELL;
        x := x1;
        y := y1;
      end;

      // Spalte auf doppelte Ziffern überprüfen
      y2 := y1+1;
      while (y2 <= sqr(FieldSize)-1) and Solved do
      begin
        Solved := GetCellValue(x1, y2, Digit2);
        if not Solved then
        begin
          ErrorCode := ERR_EMPTY_CELL;
          x := x1;
          y := y2;
        end
        else
        begin
          Solved := Digit1 <> Digit2;
          if not Solved then
          begin
            ErrorCode := ERR_DOUBLE_DIGITS_IN_COL;
            x := x1;
          end;
        end;
        inc(y2);
      end;

      // Zeile auf doppelte Zahlen überprüfen
      x2 := x1+1;
      while (x2 <= sqr(FieldSize)-1) and Solved do
      begin
        Solved := GetCellValue(x2, y1, Digit2);
        if not Solved then
        begin
          ErrorCode := ERR_EMPTY_CELL;
          x := x2;
          y := y1;
        end
        else
        begin
          Solved := Digit1 <> Digit2;
          if not Solved then
          begin
            ErrorCode := ERR_DOUBLE_DIGITS_IN_ROW;;
            y := y1;
          end;
        end;
        inc(x2);
      end;

      inc(y1);
    end;
    inc(x1);
  end;

  // Bloecke auf doppelte Werte ueberpruefen
  if Solved then
  begin
    x1 := low(TBlockCount);
    while (x1 < FieldSize) and Solved do
    begin
      y1 := low(TBlockCount);
      while (y1 < FieldSize) and Solved do
      begin
        Solved := BlockPossibilities[x1, y1] = [];
        if not Solved then
        begin
          ErrorCode := ERR_DOUBLE_DIGITS_IN_BLOCK;
          x := x1;
          y := y1;
        end;
        inc(y1);
      end;
      inc(x1);
    end;
  end;

  SudokuIsSolved := Solved;
end;

function GetErrorMessage(ErrorCode: TErrorCode): string;
{-------------------------------------------------------------------------------
Beschreibung:
  Liefert einen Fehlermeldung zum Fehlercode
--------------------------------------------------------------------------------
Parameter(in):
  ErrorCode: TErrorCode: Fehlercode
--------------------------------------------------------------------------------
Rückgabewert (out):
  string: Fehlermeldung
--------------------------------------------------------------------------------
globale Zugriffe:
  ErrorMessages (lesend): Fehlermeldungen in Textform
-------------------------------------------------------------------------------}
begin
  GetErrorMessage := ErrorMessages[Errorcode];
end;

function BlockIsSolvable(x, y: TBlockCount;
  BlockCellPossibilities: TBlockCellPossibilities;
  var ErrorCode: TErrorCode): boolean;
{-------------------------------------------------------------------------------
Beschreibung:
  Ueberprueft, ob ein Block loesbar ist
--------------------------------------------------------------------------------
Parameter(in):
  x, y: TBlockCount: Blockkoordinaten
  BlockCellPossibilities: TBlockCellPossibilities: Blockzellmoeglichkeiten
--------------------------------------------------------------------------------
Rückgabewert (out):
  ErrorCode: TErrorCode: Fehlercode, falls ein Fehler auftritt
  boolean: Block loesbar
-------------------------------------------------------------------------------}
var
  x1: TBlockColCount1;
  y1: TBlockRowCount1;
  x2: TColCount;
  y2: TRowCount;
  Solvable: boolean;
  Digit: TDigit;
  FieldSize: TFieldSize;
  OffsetX, OffsetY: byte;
begin
  Solvable := true;
  FieldSize := GetFieldSize;
  // Blockoffsets berechnen
  OffsetX := x * FieldSize;
  OffsetY := y * FieldSize;

  // Blockspalten durchlaufen
  x1 := low(TBlockColCount);
  while (x1 <= FieldSize-1) and Solvable do
  begin
    // Blockzeilen durchlaufen
    y1 := low(TBlockRowCount);
    while (y1 <= FieldSize-1) and Solvable do
    begin
      // Zelle ausgefuellt oder Kandidatenliste nicht leer?
      Solvable :=    GetCellValue(x1+OffsetX, y1+OffsetY, Digit)
                  or (BlockCellPossibilities[x1, y1] <> []);
      if not Solvable then
        ErrorCode := ERR_EMPTY_CELL;
      inc(y1);
    end;
    inc(x1);
  end;

  // auf doppelte Ziffern ueberpruefen
  Solvable := not GetDoubleDigitsInBlock(TColCount(OffsetX), x2,
    TRowCount(OffsetY), y2);
  if not Solvable then
    ErrorCode := ERR_DOUBLE_DIGITS_IN_BLOCK;

  BlockIsSolvable := Solvable;
end;

function SudokuIsSolvable(var x: TColCount; var y: TRowCount;
  var ErrorCode: TErrorCode): boolean;
{-------------------------------------------------------------------------------
Beschreibung:
  Ueberprueft, ob ein Sudoku loesbar ist
--------------------------------------------------------------------------------
Rückgabewert (out):
  x: TColCount: Spalte des Fehlers, falls nicht loesbar
  y: TRowCount: Zeile des Fehlers, falls nicht loesbar
  ErrorCode: TErrorCode: Fehlercode, falls nicht loesbar
  boolean: Sudoku ist loesbar
-------------------------------------------------------------------------------}
var
  x1: TColCount1;
  y1: TRowCount1;
  x2, y2: TBlockCount1;
  Solvable: boolean;
  ColPossibilities: TColPossibilities;
  RowPossibilities: TRowPossibilities;
  BlockCellPossibilities: TBlockCellPossibilities;
  FieldSize: TFieldSize;
  Digit: TDigit;
begin
  Solvable := true;
  FieldSize := GetFieldSize;

  // alle Zellen durchlaufen
  x1 := low(TColCount);
  while (x1 <= sqr(FieldSize)-1) and Solvable do
  begin
    y1 := low(TRowCount);
    while (y1 <= sqr(FieldSize)-1) and Solvable do
    begin
      // auf leere Kanditatenlisten uebepruefen
      Solvable :=    GetCellValue(x1, y1, Digit)
                  or (GetCellPossibilities(x1, y1) <> []);
      if not Solvable then
      begin
        ErrorCode := ERR_NO_POSSIBILITIES;
        x := x1;
        y := y1;
      end;
      inc(y1);
    end;
    inc(x1);
  end;

  // alle Spalten durchlaufen
  x1 := low(TColCount);
  while (x1 <= sqr(FieldSize)-1) and Solvable do
  begin
    // ueberpruefen, ob Spalte loesbar
    Solvable := ColIsSolvable(x1, RowPossibilities, y, ErrorCode);
    if not Solvable then
      x := x1;
    inc(x1);
  end;

  // alle Zeilen durchlaufen
  y1 := low(TRowCount);
  while (y1 <= sqr(FieldSize)-1) and Solvable do
  begin
    // ueberpruefen, ob Zeile loesbar
    Solvable := RowIsSolvable(y1, ColPossibilities, x, ErrorCode);
    if not Solvable then
      y := y1;
    inc(y1);
  end;

  // alle Bloecke horizontal durchlaufen
  x2 := low(TBlockCount);
  while (x2 <= FieldSize-1) and Solvable do
  begin
    // alle Bloecke vertikal durchlaufen
    y2 := low(TBlockCount);
    while (y2 <= FieldSize-1) and Solvable do
    begin
      // Blockspalten durchlaufen
      for x1 := low(TBlockColCount) to FieldSize-1 do
      begin
        // Blockzeilen durchlaufen
        for y1 := low(TBlockRowCount) to FieldSize-1 do
          // Zellenmoeglichkeiten berechnen
          BlockCellPossibilities[x1, y1] :=
            GetCellPossibilities(x2*FieldSize+x1, y2*FieldSize+y1);
      end;
      // ueberpruefen, ob Block loesbar
      Solvable := BlockIsSolvable(x2, y2, BlockCellPossibilities, ErrorCode);
      if not Solvable then
      begin
        x := x2 * FieldSize;
        y := y2 * FieldSize;
      end;
      inc(y2);
    end;
    inc(x2);
  end;

  SudokuIsSolvable := Solvable;
end;

function GetDigitPossibilitiesCountInCol(x: TColCount;
  Digit: TDigit): TColCount1;
{-------------------------------------------------------------------------------
Beschreibung:
  Zaehlt die Moeglichkeit fuer eine Ziffer in einer Spalte
--------------------------------------------------------------------------------
Parameter(in):
  x: TColCount: Spalte
  Digit: TDigit: Ziffer
--------------------------------------------------------------------------------
Rückgabewert (out):
  TColCount1: Anzahl Moeglichkeiten
-------------------------------------------------------------------------------}
var
  y: TRowCount1;
  DigitCount: byte;
  FieldSize: TFieldSize;
begin
  DigitCount := 0;
  FieldSize := GetFieldSize;

  // Spielfeld vertikal durchlaufen
  y := low(TRowCount);
  while y <= sqr(FieldSize)-1 do
  begin
    // Moeglichkeiten zaehlen
    if Digit in GetCellPossibilities(x, y) then
      inc(DigitCount);
    inc(y);
  end;

  GetDigitPossibilitiesCountInCol := DigitCount;
end;

function GetDigitPossibilitiesCountInRow(y: TRowCount;
  Digit: TDigit): TRowCount1;
{-------------------------------------------------------------------------------
Beschreibung:
  Zaehlt die Moeglichkeiten einer Ziffer in einer Zeile
--------------------------------------------------------------------------------
Parameter(in):
  y: TRowCount: Zeile
  Digit: TDigit: Ziffer
--------------------------------------------------------------------------------
Rückgabewert (out):
  TRowCount1: Anzahl Moeglichkeiten
-------------------------------------------------------------------------------}
var
  x: TColCount1;
  ColPossibilities: TColPossibilities;
  DigitCount: byte;
  FieldSize: TFieldSize;
begin
  DigitCount := 0;
  FieldSize := GetFieldSize;

  // Zeilenmoeglichkeiten berechnen
  for x := low(TColCount) to sqr(FieldSize)-1 do
    ColPossibilities[x] := GetCellPossibilities(x, y);

  // Spielfeld horizontal durchlaufen
  x := low(TColCount);
  while (x <= sqr(FieldSize)-1) and (DigitCount <= 1) do
  begin
    // Moeglichkeiten zaehlen
    if Digit in ColPossibilities[x] then
      inc(DigitCount);
    inc(x);
  end;

  GetDigitPossibilitiesCountInRow := DigitCount;
end;

function GetDigitPossibilitiesCountInBlock(x, y: TBlockCount;
  Digit: TDigit): byte;
{-------------------------------------------------------------------------------
Beschreibung:
  Zaehlt die Moeglichkeiten einer Ziffer in einem Bloch
--------------------------------------------------------------------------------
Parameter(in):
  x, y: TBlockCount: Blockkoordianten
  Digit: TDigit: Ziffer
--------------------------------------------------------------------------------
Rückgabewert (out):
  byte: Anzahl Moeglichkeiten
-------------------------------------------------------------------------------}
var
  x1, y1: TBlockCount1;
  DigitCount,
  OffsetX, OffsetY: byte;
  FieldSize: TFieldSize;
begin
  FieldSize := GetFieldSize;
  DigitCount := 0;

  // Blockoffsets berechnen
  OffsetX := x * FieldSize;
  OffsetY := y * FieldSize;

  // Block horizontal durchlaufen
  for x1 := low(TBlockCount) to FieldSize-1 do
  begin
    // Block vertikal durchlaufen
    for y1 := low(TBlockCount) to FieldSize-1 do
    begin
      // Moeglichkeiten zaehlen
      if Digit in GetCellPossibilities(x1+OffsetX, y1+OffsetY) then
        inc(DigitCount);
    end;
  end;

  GetDigitPossibilitiesCountInBlock := DigitCount;
end;

function DigitIsSingle(x: TColCount; y: TRowCount; Digit: TDigit): boolean;
{-------------------------------------------------------------------------------
Beschreibung:
  Ueberprueft ob eine Ziffer ein Singleton in einer Zelle ist
--------------------------------------------------------------------------------
Parameter(in):
  x: TColCount: Spalte
  y: TRowCount: Zeile
  Digit: TDigit: Ziffer
--------------------------------------------------------------------------------
Rückgabewert (out):
  boolean: Ziffer ist ein Singleton
-------------------------------------------------------------------------------}
var
  CellPossibilities: TDigitSet;
  FieldSize: TFieldSize;
begin
  FieldSize := GetFieldSize;
  // Zellmoeglichketien berechnen
  CellPossibilities := GetCellPossibilities(x, y, true);
  // Ueberpruefen ob:
  // Anzahl Moeglichkeiten in der Zelle = 1 und die Moeglichkeit = Digit ist
  // Anzahl Moeglichkeiten in der Spalte, Zeile oder im Block = 1 ist
  DigitIsSingle := (      (GetDigitSetElementsCount(CellPossibilities) = 1)
                      and (GetSingletonDigit(CellPossibilities) = Digit))
                   or (GetDigitPossibilitiesCountInCol(x, Digit) = 1)
                   or (GetDigitPossibilitiesCountInRow(y, Digit) = 1)
                   or (GetDigitPossibilitiesCountInBlock(x div FieldSize,
                                                         y div FieldSize,
                                                         Digit) = 1);
end;

function RowIsFilled(y: TRowCount): boolean;
{-------------------------------------------------------------------------------
Beschreibung:
  Ueberprueft, ob alle Zellen einer Zeile gefuellt/gesetzt sind
--------------------------------------------------------------------------------
Parameter(in):
  y: TRowCount: Zeile
--------------------------------------------------------------------------------
Rückgabewert (out):
  boolean: Zeile ausgefuellt
-------------------------------------------------------------------------------}
var
  x: TColCount1;
  Filled: boolean;
  Digit: TDigit;
begin
  Filled := true;

  // Spielfeld horizonatal durchlaufen
  x := low(TColCount);
  while (x <= sqr(GetFieldSize)-1) and Filled do
  begin
    Filled := GetCellValue(x, y, Digit);
    inc(x);
  end;

  RowIsFilled := Filled;
end;

function ColIsFilled(x: TColCount): boolean;
{-------------------------------------------------------------------------------
Beschreibung:
  Ueberprueft, ob alle Zellen einer Spalte gefuellt/gesetzt sind
--------------------------------------------------------------------------------
Parameter(in):
  x: TColCount: Spalte
--------------------------------------------------------------------------------
Rückgabewert (out):
  boolean: Spalte ausgefuellt
-------------------------------------------------------------------------------}
var
  y: TRowCount1;
  Filled: boolean;
  Digit: TDigit;
begin
  Filled := true;

  // Spielfeld vertikal durchlaufen
  y := low(TRowCount);
  while (y <= sqr(GetFieldSize)-1) and Filled do
  begin
    Filled := GetCellValue(x, y, Digit);
    inc(y);
  end;

  ColIsFilled := Filled;
end;

function GetDigitColor(x: TColCount; y: TRowCount; Digit: TDigit): TColor;
{-------------------------------------------------------------------------------
Beschreibung:
  Bestimmt die Farbe einer Ziffer im Buchfuehrungsmodus
--------------------------------------------------------------------------------
Parameter(in):
  x: TColCount: Spalte
  y: TRowCount: Zeile
  Digit: TDigit: Ziffer
--------------------------------------------------------------------------------
Rückgabewert (out):
  TColor: Farbe
--------------------------------------------------------------------------------
globale Zugriffe:
  DigitColors (lesend): Farben je nach Anzahl
-------------------------------------------------------------------------------}
var
  PossibilitiesCount: byte;
begin
  // eine einzige Moeglichkeit
  if DigitIsSingle(x, y, Digit) then
    GetDigitColor := DigitColors[1]
  else
  begin
    // Anzahl der Moeglichkeiten in einem Block berechnen
    PossibilitiesCount := GetDigitPossibilitiesCountInBlock(x div GetFieldSize,
                                                            y div GetFieldSize,
                                                            Digit);
    // Anzahl ausserhalb des Farbenarrays => Standardfarbe
    if PossibilitiesCount > high(TDigitColorCount) then
      GetDigitColor := DigitColors[0]
    // berechnete Anzahl im Array => Farbe aus dem Array
    else
      GetDigitColor := DigitColors[PossibilitiesCount];
  end;
end;

// Initialisierungen
initialization
  InitField;

end.
