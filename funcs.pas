unit funcs;

interface

uses
  System.StrUtils,
  System.SysUtils,
  System.Generics.Collections,
  database,
  Settings,
  StatConst,
  utils,
  task,
  docuware;

type
  Tfuncs = class
  private
    FSettings: TSettings;
    FOpenTasks: TList<TTask>;
    FDocuware: TDocuware;
    function checkFieldMapping(): boolean;
  public
    Constructor Create();
    Destructor Destroy(); override;
    procedure init();
    procedure deinit();
    procedure execute();
    procedure executeTask(Task: TTask);
  end;

implementation

uses
  main;

{Tfuncs}

constructor Tfuncs.Create();
begin
  //create
  inherited;
  self.FOpenTasks := TList<TTask>.Create();
end;

destructor Tfuncs.Destroy();
begin
  //destroy
  self.FOpenTasks.Free();
  self.FDocuware.Free();
  inherited;
end;

procedure Tfuncs.init();
begin
  //init
  self.FSettings := TSettings.Create();
  self.FDocuware := TDocuware.Create(self.FSettings);
  if not self.checkFieldMapping() then
    Form_main.log('Field mapping is not complete. Please check the ''settings.ini'' file.');
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
    Fdatabase.CloseRemoteDB();
  end
  else
  begin
    Fdatabase.CloseLocalDB();
  end;
  self.FDocuware.Free;
  self.FSettings.Free;
end;

procedure Tfuncs.execute();
var
  ATask: TTask;
begin
  // clear open tasks list
  self.FOpenTasks.Clear();
  // find all open tasks in the database
  Fdatabase.nxQuery1.SQL.Text := 'SELECT * FROM "Anforderung" WHERE "status" LIKE ''ANF'' IGNORE CASE';
  Fdatabase.nxQuery1.ExecSQL();
  Fdatabase.nxQuery1.Open();
  // iterate through all open tasks
  while not Fdatabase.nxQuery1.Eof do
  begin
    // update tasks list
    self.FOpenTasks.Add(
      TTask.Create(
        Fdatabase.nxQuery1.FieldByName('guid').AsString,
        Fdatabase.nxQuery1.FieldByName('command').AsString,
        Fdatabase.nxQuery1.FieldByName('archive').AsString,
        Fdatabase.nxQuery1.FieldByName('selection').AsString
        )
      );
    Fdatabase.nxQuery1.Next();
  end;
  Fdatabase.nxQuery1.Close();
  // iterate through all open tasks
  for ATask in self.FOpenTasks do
  begin
    // execute current task
    self.executeTask(ATask);
  end;

end;

procedure Tfuncs.executeTask(task: TTask);
begin
  // get archive id
  Fdatabase.nxQuery1.SQL.Text := 'SELECT "ar_guid" FROM "Archive" WHERE "ar_id" LIKE ''' + task.archive + ''' IGNORE CASE';
  Fdatabase.nxQuery1.ExecSQL();
  Fdatabase.nxQuery1.Open();
  if FDatabase.nxQuery1.RecordCount = 0 then
    task.error := 'noarchive'
  else
    task.archiveId := Fdatabase.nxQuery1.FieldByName('ar_guid').AsString;
  Fdatabase.nxQuery1.Close();
  
  if task.error = '' then
  begin
    // Categorize Task
    if IndexText(task.command, ['select', 'selectfast', 'selectindex']) <> -1 then
    begin

    end
    else if task.command = 'chhdokindex' then
    begin

    end
    else if task.command = 'getobj' then
    begin

    end
    else if task.command = 'insert' then
    begin

    end
    else if task.command = 'delete' then
    begin

    end
    else if task.command = 'getarchives' then
    begin

    end
    else if task.command = 'getfieldlist' then
    begin

    end
    else if task.command = 'getfieldtypes' then
    begin

    end
    else if task.command = 'getindexfield' then
    begin

    end
    else if task.command = 'getfieldindex' then
    begin

    end
    else if task.command = 'getfieldalias' then
    begin

    end
    else
    begin
      task.error := 'error';
    end;
  end;

  // done.
  if task.error = '' then
  begin
    Form_main.log('Task ' + task.guid + ' completed successfully.');
    Fdatabase.nxQuery1.SQL.Text := 'UPDATE "Anforderung" SET "status"=''OK'' WHERE "guid" LIKE ''' + task.guid + ''' IGNORE CASE';
    Fdatabase.nxQuery1.ExecSQL();
  end
  else
  begin
    Form_main.log('Task ' + task.guid + ' failed with error: ' + task.error);
    Fdatabase.nxQuery1.SQL.Text := 'UPDATE "Anforderung" SET "status"='''+task.error.ToUpper+''' WHERE "guid" LIKE ''' + task.guid + '''';
    Fdatabase.nxQuery1.ExecSQL();
  end;
end;

function Tfuncs.checkFieldMapping(): boolean;
var
  ACabinet: string;
  AField: string;
  fieldExisted: boolean;
begin
  Result := True;
  for ACabinet in self.FDocuware.getAllCabinetIds do
  begin
    for AField in self.FDocuware.getAllFieldNames(ACabinet) do
    begin
      fieldExisted := self.FSettings.makeFieldExist(ACabinet, AField);
      if not fieldExisted then
        Result := False;
    end;
  end;
end;

end.
