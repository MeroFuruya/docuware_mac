program docuware_mac;

uses
  Vcl.Forms,
  database in 'database.pas' {Database: TDataModule},
  docuware in 'docuware.pas',
  funcs in 'funcs.pas',
  main in 'main.pas' {Form_main},
  Settings in 'Settings.pas',
  StatConst in 'StatConst.pas',
  task in 'task.pas',
  utils in 'utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm_main, Form_main);
  Application.CreateForm(TDatabase, FDatabase);
  Application.Run;
end.
