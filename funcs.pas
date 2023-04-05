unit funcs;

interface

uses
  VCL.Dialogs, // @debug
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
    procedure handleSelectTask(var Task: TTask);
    procedure handleUpdateTask(var Task: TTask);
    function getResultHeader(documents: TArray<TDocument>): string;
    function getResultLines(documents: TArray<TDocument>): TArray<string>;
    function getIndexData(task: TTask; documents: TArray<TDocument>): TArray<string>;
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
  self.FOpenTasks := TList<TTask>.Create();
  inherited;
end;

destructor Tfuncs.Destroy();
begin
  //destroy
  self.FOpenTasks.Free();
  inherited;
end;

procedure Tfuncs.init();
begin
  //init
  self.FSettings := TSettings.Create();
  self.FDocuware := TDocuware.Create(self.FSettings);
  if not self.checkFieldMapping() then
    Form_main.log('Field/Cabinet mapping is not complete. Please check the ''settings.ini'' file.');
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
  // free
  if self.FDocuware <> nil then
  begin
    self.FDocuware.Free;
    self.FDocuware := nil;
  end;
  if self.FSettings <> nil then
  begin
    self.FSettings.Free;
    self.FSettings := nil;
  end;
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
      self.handleSelectTask(task);
    end
    else if task.command = 'chhdokindex' then
    begin
      self.handleUpdateTask(task);
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
    Fdatabase.nxQuery1.SQL.Text := 'UPDATE "Anforderung" SET "status"='''+task.error.ToUpper+''' WHERE "guid" LIKE ''' + task.guid + ''' IGNORE CASE';
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
    fieldExisted := self.FSettings.makeCabExist(ACabinet);
    if not fieldExisted then
        Result := False;
    for AField in self.FDocuware.getAllFieldNames(ACabinet) do
    begin
      fieldExisted := self.FSettings.makeFieldExist(ACabinet, AField);
      if not fieldExisted then
        Result := False;
    end;
  end;
end;

procedure Tfuncs.handleSelectTask(var Task: TTask);
var
  ADocuments: TArray<TDocument>;
  // stuff we need to write to the database:
  AResultLine: TArray<string>;
  AIndexData: TArray<string>;
  // sql
  AI: integer;
  ASQLValues: TArray<string>;
begin
  // stuff we need to write to the database:
  // - Anforderung
  //   - Resultheaders (field names, '|' separated)
  // - Result
  //   - Pos (document position in result)
  //   - docid (document id)
  //   - Resultline (field values, '|' separated)
  //   - indexdata (fieldname and -value, ',' separated)
  //   - objectloaded (just a zero)

  // get the result
  ADocuments := self.FDocuware.select(task);
  // handle docuware errors
  if self.FDocuware.IsError then
  begin
    task.error := 'ERROR2';
    exit;
  end;
  // build result headers
  // write the result to the database
  Fdatabase.nxQuery1.SQL.Text := 'UPDATE "Anforderung" SET "Resultheader"=''' + self.getResultHeader(ADocuments) + ''' WHERE "guid" LIKE ''' + task.guid + ''' IGNORE CASE;';
  Fdatabase.nxQuery1.ExecSQL();

  // build result lines
  AResultLine := self.getResultLines(ADocuments);
  // build index data
  AIndexData := self.getIndexData(task, ADocuments);

  for AI := 0 to Length(ADocuments) - 1 do
  begin
    // add to sql values
    ASQLValues := ASQLValues + [Format('(''%s'', ''%s'', %d, %s, ''%s'', ''%s'', 0)', [Task.guid, GUIDToString(TGUID.NewGuid), AI, ADocuments[AI].Id, AResultLine[AI], AIndexData[AI]])];
  end;
  // write to database
  if Length(ASQLValues) > 0 then
  begin
    Fdatabase.nxQuery1.SQL.Text := 'INSERT INTO "Result" ("ANFGUID", "GUID", "POS", "DOCID", "RESULTLINE", "INDEXDATA", "OBJECTLOADED") VALUES ' + string.Join(',', ASQLValues) + ';';
    Fdatabase.nxQuery1.ExecSQL();
  end;
end;

function Tfuncs.getResultHeader(documents: TArray<TDocument>): string;
var
  AResultHeadersList: TArray<string>;
  ADocument: TDocument;
  AField: TField;
begin
  Result := '';
  for ADocument in Documents do
    for AField in self.FDocuware.translateStoredatetime(ADocument.Fields) do
      if IndexText(AField.Name, AResultHeadersList) = -1 then
        AResultHeadersList := AResultHeadersList + [AField.Name];
  Result := string.Join('|', AResultHeadersList);
end;

function Tfuncs.getResultLines(documents: TArray<TDocument>): TArray<string>;
var
  AResultHeadersList: TArray<string>;
  ADocument: TDocument;
  AField: TField;
  AResultLine: TArray<string>;
  AResultHeaderString: string;
begin
  Result := [];
  for ADocument in Documents do
    for AField in self.FDocuware.translateStoredatetime(ADocument.Fields) do
      if IndexText(AField.Name, AResultHeadersList) = -1 then
        AResultHeadersList := AResultHeadersList + [AField.Name];

  for ADocument in Documents do
  begin
    AResultLine := [];
    for AResultHeaderString in AResultHeadersList do
      for AField in self.FDocuware.translateStoredatetime(ADocument.Fields) do
        if AField.Name = AResultHeaderString then
          AResultLine := AResultLine + [AField.Value];
    Result := Result + [string.Join('|', AResultLine)];
  end;
end;

function Tfuncs.getIndexData(task: TTask; documents: TArray<TDocument>): TArray<string>;
var
  AIndexData: TArray<string>;
  ADocument: TDocument;
  AConvertedFieldList: TArray<TField>;
  AField: TField;
begin
  Result := [];
  for ADocument in Documents do
  begin
    // build index data
    AConvertedFieldList := self.FDocuware.translateSelect(task.archiveId, ADocument.Fields, true);
    if self.FDocuware.IsError then  // docuware error handling
    begin
      Result := [];
      exit;
    end;
    AIndexData := [];
    for AField in AConvertedFieldList do
      AIndexData := AIndexData + [AField.Name, AField.Value];
    Result := Result + [string.Join(',', AIndexData)];
  end;
end;

procedure Tfuncs.handleUpdateTask(var Task: TTask);
begin
  
end;

end.
