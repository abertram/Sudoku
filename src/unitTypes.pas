//------------------------------------------------------------------------------
// Name der Unit: unitTypes
//
// Projekt: Sudoku
//
// Beschreibung:
// -------------
//   Eigene Datentypen
//
// Autor: Alex
// erstellt am: 10.04.2006
//------------------------------------------------------------------------------
unit unitTypes;

interface

uses
  Graphics;

const
  // minimale/maximale/Standard-Spielfeldgroesse
  cFieldSizeMin = 2;
  cFieldSizeMax = 4;
  cFieldSizeDefault = 3;

  // miminmale/maximale Ziffer
  cDigitMin = 1;
  cDigitMax = sqr(cFieldSizeMax);

  // gueltige Eingabezeichen
  cValidKeys = ['0'..'9', #8, #13];

  // Dateierweiterung
  cFileExt = 'sdk';

  // Groessen, um den Buchfuehrungsmodus verfuegbar zu machen
  cAccountingSizes = [3];

  // minimale/maximale Spaltenanzahl
  cColCountMin = 0;
  cColcountMax = sqr(cFieldSizeMax)-1;

  // minimale/maximale Zeilenanzahl
  cRowCountMin = 0;
  cRowCountMax = sqr(cFieldSizeMax)-1;

  // minimale/maximale Blockanzahl
  cBlockCountMin = 0;
  cBlockCountMax = cFieldSizeMax-1;

  // minimale/maximale Spaltenanzahl pro Block
  cBlockColCountMin = 0;
  cBlockColCountMax = ((cColCountMax+1) div (cBlockCountMax+1))-1;

  // minimale/maximale Zeilenanzahl pro Block
  cBlockRowCountMin = 0;
  cBlockRowCountMax = ((cRowCountMax+1) div (cBlockCountMax+1))-1;

  // minimale/maximale Anzahl ungueltiger Zellen (zum Hervorheben)
  cInvalidCellsCountMin = 0;
  cInvalidCellsCountMax = 1;

  // Ziffernfarben fuer den Buchfuehrungsmodus
  cDigitColorCountMin = 0;
  cDigitColorCountMax = 2;

  // Zellfarben
  cInvalidCellColor = Byte($ff) or (Word($ea) shl 8) or (Longword($ea) shl 16);
  cFocusedCellColor = Byte($ea) or (Word($ea) shl 8) or (Longword($ea) shl 16);
  cFixedCellColor = Byte($dd) or (Word($dd) shl 8) or (Longword($dd) shl 16);

type
  // Spielfeldgroesse
  TFieldSize = cFieldSizeMin..cFieldSizeMax;

  // Ziffern und Ziffernmenge
  TDigit = cDigitMin..cDigitMax;
  TDigitSet = set of TDigit;
  // Ueberlaufschutz in Schleifen
  TDigit1 = cDigitMin..cDigitMax+1;

  // Datentypen fuer Spalten
  // Spaltenanzahl
  TColCount = cColCountMin..cColcountMax;
  // Ueberlaufschutz in Schleifen
  TColCount1 = cColCountMin..cColcountMax+1;
  // Ziffernmoeglichkeiten pro Spalte
  TColPossibilities = array [TColCount] of TDigitSet;

  // Datentypen fuer Zeilen
  // Zeilenanzahl
  TRowCount = cRowCountMin..cRowCountMax;
  // Ueberlaufschutz in Schleifen
  TRowCount1 = cRowCountMin..cRowCountMax+1;
  // Ziffernmoeglichkeiten pro Zeile
  TRowPossibilities = array [TRowCount] of TDigitSet;

  // Datentypen fuer Bloecke
  // Blockanzahl
  TBlockCount = cBlockCountMin..cBlockCountMax;
  // Ueberlaufschutz in Schleifen
  TBlockCount1 = cBlockCountMin..cBlockCountMax+1;
  // Ziffernmoeglichkeiten pro Block
  TBlockPossibilities = array [TBlockCount, TBlockCount] of TDigitSet;
  // Spaltenanzahl pro Block
  TBlockColCount = cBlockColCountMin..cBlockColCountMax;
  // Ueberlaufschutz in Schleifen
  TBlockColCount1= cBlockColCountMin..cBlockColCountMax+1;
  // Ziffernmoeglichkeiten pro Blockspalte
  TBlockColPossibilities = array [TBlockColCount] of TDigitSet;
  // Zeilenanzahl pro Block
  TBlockRowCount = cBlockRowCountMin..cBlockRowCountMax;
  // Ueberlaufschutz in Schleifen
  TBlockRowCount1 = cBlockRowCountMin..cBlockRowCountMax+1;
  // Ziffernmoeglichkeiten pro Blockzeile
  TBlockRowPossibilities = array [TBlockRowCount] of TDigitSet;
  // Ziffernmoeglichkeiten pro Blockzelle
  TBlockCellPossibilities = array [TBlockColCount, TBlockRowCount] of TDigitSet;

  // Spielfeldzelle
  TCell = record
    ValueExisting,  // Flag, ob Wert eingetragen
    Fixed: boolean;  // Flag, ob Wert vorgegeben
    Value: TDigit;  // Ziffer
  end;

  // Spielfeld
  TField = record
    Size: TFieldSize;  // Groesse
    Cells: array [TColCount, TRowCount] of TCell;  // Zellen
  end;

  // Zellen einer Spalte/Zeile
  // damit die Zellen einzelner Spalten/Zeilen/Bloecke
  // ausgelesen und gesetzt werden koennen und nicht das ganze Spielfeld
  TColCells = array [TRowCount] of TCell;
  TRowCells = array [TColCount] of TCell;

  // Fehlercodes
  TErrorCode = (ERR_EMPTY_CELL=1,
                ERR_DOUBLE_DIGITS_IN_COL=2,
                ERR_DOUBLE_DIGITS_IN_ROW=3,
                ERR_DOUBLE_DIGITS_IN_BLOCK=4,
                ERR_NO_POSSIBILITIES=5);

  // Anzahl ungueltiger Zellen
  TInvalidCellsCount = cInvalidCellsCountMin..cInvalidCellsCountMax;
  // Ueberlaufschutz in Schleifen
  TInvalidCellsCount1 = cInvalidCellsCountMin..cInvalidCellsCountMax+1;
  // ungueltige Zelle
  TInvalidCell = record
    Invalid: boolean;
    x: TColCount;
    y: TRowCount;
  end;
  // ungueltige Zellen
  TInvalidCells = array [TInvalidCellsCount] of TInvalidCell;

  // Anzahl Farben im Buchfuehrungsmodus
  TDigitColorCount = cDigitColorCountMin..cDigitColorCountMax;

var
  // Strings fuer die Fehlercodes
  ErrorMessages: array [TErrorCode] of string = ('Leere Zelle entdeckt',
                                                 'Doppelte Ziffern in einer Spalte',
                                                 'Doppelte Ziffern in einer Zeile',
                                                 'Doppelte Ziffern in einem Block',
                                                 'Kandidatenliste leer');
  // Farben fue die Ziffern im Buchfuehrungsmodus
  DigitColors: array [TDigitColorCount] of TColor = (clBlack, // alles ausser 1 und 2
                                                     clRed, // 1 Moeglichkeit
                                                     clBlue); // 2 Moeglichkeiten

implementation

end.
