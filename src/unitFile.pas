//------------------------------------------------------------------------------
// Projekt: Sudoku
//
// Beschreibung:
// -------------
//   Enthaelt IO-Routinen
//
// Autor: Alex
// erstellt am: 02.03.2006
//------------------------------------------------------------------------------
unit unitFile;

interface

uses
  unitTypes;

// ueberprueft, ob Datei gueltig
function FileIsValid(FileName: string; RecordSize: word): boolean;
// ueberprueft, ob Datei schreibgeschuetzt
function FileIsReadOnly(FileName: string): boolean;
// schriebt die Datensaetze in eine Datei
function SaveField(FileName: string; Field: TField): boolean;
// liest die Datensaetze aus einer Datei
function OpenField(FileName: string; var Field: TField): boolean;
// erzeugt eine Datei
function FileCreate(FileName: string): boolean;
// entfernt Schreibschutz
function ClearReadOnlyFlag(FileName: string): boolean;

implementation

uses SysUtils;

type
  TFieldFile = file of TField;

function FileIsValid(FileName: string; RecordSize: word): boolean;
{-------------------------------------------------------------------------------
Beschreibung:
  Ueberprueft anhand der Datensatzgroesse, ob die Datei gueltig ist.
--------------------------------------------------------------------------------
Parameter(in):
  FileName: string: Dateiname
  RecordSize: word: Datensatzgroesse
--------------------------------------------------------------------------------
Rückgabewert (out):
  boolean: Datei gueltig
-------------------------------------------------------------------------------}
var
  f: file of byte;
  TmpFileMode: byte;
begin
  FileIsValid := true;
  TmpFileMode := FileMode;
  try
    // FileMode auf ReadOnly
    FileMode := fmOpenRead;
    AssignFile(f, FileName);
    // Datei öffnen
    Reset(f);
    // überprüfen, ob Dateigröße Vielfaches von der Recordgröße ist
    FileIsValid := (FileSize(f) mod RecordSize) = 0;
    CloseFile(f);
  except
    FileIsValid := false;
  end;
  // FileMode zurücksetzen
  FileMode := TmpFileMode;
end;

function FileIsReadOnly(FileName: string): boolean;
{-------------------------------------------------------------------------------
Beschreibung:
  Ueberprueft, ob Datei schreibgeschuetzt ist.
--------------------------------------------------------------------------------
Parameter(in):
  FileName: string: Dateiname
--------------------------------------------------------------------------------
Rückgabewert (out):
  boolean: Datei schreibgeschuetzt
-------------------------------------------------------------------------------}
begin
  FileIsReadOnly :=     (SysUtils.FileGetAttr(FileName)
                    and SysUtils.faReadOnly)
                    = SysUtils.faReadOnly;
end;

function ClearReadOnlyFlag(FileName: string): boolean;
{-------------------------------------------------------------------------------
Beschreibung:
  Entfernt den Schreibschut einer Datei.
--------------------------------------------------------------------------------
Parameter(in):
  FileName: string: Dateiname
--------------------------------------------------------------------------------
Rückgabewert (out):
  boolean: Schreibschutz entfernt
-------------------------------------------------------------------------------}
begin
  ClearReadOnlyFlag := (SysUtils.FileSetAttr(FileName,
                            SysUtils.FileGetAttr(FileName)
                        and not SysUtils.faReadOnly) = 0);
end;

function SaveField(FileName: string; Field: TField): boolean;
{-------------------------------------------------------------------------------
Beschreibung:
  Speichert das Spielfeld in einer Datei.
--------------------------------------------------------------------------------
Parameter(in):
  FileName: string: Dateiname
  Field: TField: Spielfeld
--------------------------------------------------------------------------------
Rückgabewert (out):
  boolean: Feld gespeichert
-------------------------------------------------------------------------------}
var
  FieldFile: TFieldFile;
begin
  SaveField := true;
  // Verbindung zur Datei
  AssignFile(FieldFile, FileName);
  try
    // datei oeffnen
    Reset(FieldFile);
    // Datensatz schreiben
    Write(FieldFile, Field);
  except
    // Fehler
    SaveField := false;
  end;
  // Datei schliessen
  CloseFile(FieldFile);
end;

function OpenField(FileName: string; var Field: TField): boolean;
{-------------------------------------------------------------------------------
Beschreibung:
  Liest das Spielfeld aus einer Datei.
--------------------------------------------------------------------------------
Parameter(in):
  FileName: string: Dateiname
--------------------------------------------------------------------------------
Rückgabewert (out):
  Field: TField: Spielfeld
  boolean: Spielfeld ausgelesen
-------------------------------------------------------------------------------}
var
  FieldFile: TFieldFile;
  TmpFileMode: byte;
begin
  OpenField := true;
  // Verbindung zur Datei
  AssignFile(FieldFile, FileName);
  // Filemode merken
  TmpFileMode := FileMode;
  // Filemode setzen
  FileMode := fmOpenRead;
  try
    // Datei oeffnen
    Reset(FieldFile);
    // Datensatz lesen
    Read(FieldFile, Field);
  except
    // Fehler
    OpenField := false;
  end;
  // Datei schliessen
  CloseFile(FieldFile);
  // Filemode zuruecksetzen
  FileMode := TmpFileMode;
end;

function FileCreate(FileName: string): boolean;
{-------------------------------------------------------------------------------
Beschreibung:
  Erstellt eine Datei.
--------------------------------------------------------------------------------
Parameter(in):
  FileName: string: Dateiname
--------------------------------------------------------------------------------
Rückgabewert (out):
  boolean: Datei erstellt
-------------------------------------------------------------------------------}
var
  f: file;
begin
  FileCreate := true;
  AssignFile(f, FileName);
  try
    try
      // Datei anlegen und oeffnen
      Rewrite(f);
    except
      FileCreate := false;
    end;
  finally
    // Datei schliessen
    CloseFile(f);
  end;
end;

end.
