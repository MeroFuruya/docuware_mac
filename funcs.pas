unit funcs;

interface

uses
  System.StrUtils,
  System.SysUtils,
  database,
  Settings,
  StatConst,
  utils;

type
  Tfuncs = class
  private
    FSettings: TSettings;
  public
    procedure init();
    procedure deinit();
    procedure execute();
  end;

implementation

{Tfuncs}

procedure Tfuncs.init();
begin
  //init
  self.FSettings := TSettings.Create();
  if StrToBool(self.FSettings.DatabaseIsRemote) then
  begin
    Fdatabase.OpenRemoteDB(self.FSettings);
  end
  else
  begin
    Fdatabase.OpenLocalDB(self.FSettings);
  end;
end;

procedure Tfuncs.deinit();
begin
  //deinit
  if StrToBool(self.FSettings.DatabaseIsRemote) then
  begin
    Fdatabase.CloseRemoteDB(self.FSettings);
  end
  else
  begin
    Fdatabase.CloseLocalDB(self.FSettings);
  end;
  Self.FSettings.Free();
end;

procedure Tfuncs.execute();
begin
  //execute
  // find all open tasks in the database

  Fdatabase.nxQuery1.SQL.Text := 'SELECT * FROM "Anforderung" WHERE status = "ANF"';
  Fdatabase.nxQuery1.ExecSQL();



  // iterate through all open tasks

  // categorize task
end;

end.