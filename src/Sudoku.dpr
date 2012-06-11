program Sudoku;

{%ToDo 'Sudoku.todo'}

uses
  Forms,
  unitMain in 'unitMain.pas' {frmMain},
  unitTypes in 'unitTypes.pas',
  unitLogic in 'unitLogic.pas',
  unitFile in 'unitFile.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
