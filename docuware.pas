unit Docuware;

interface

uses
  System.SysUtils,
  System.DateUtils,
  System.Classes,
  System.Net.HttpClient,
  System.Net.URLClient,
  System.StrUtils,
  System.Generics.Collections,
  System.JSON,
  Settings,
  task;

type

  TField = record
    Name: string;
    Value: string;
  end;

  TDocument = record
    Id: string;
    Name: string;
    Fields: TArray<TField>;
  end;

  TDocuware = class
  private
    FHttp: THttpClient;
    FSettings: TSettings;
    FISERROR: boolean;
    function makeRequest(AReq: IHTTPRequest): IHttpResponse;
    function buildUrl(APath: string): string;
    function doLogin(): boolean;
  public
    constructor Create(Settings: TSettings);
    destructor Destroy; override;
    function select(task: TTask): TArray<TDocument>;
    function Update(task: TTask): TDocument;
    function getAllCabinetIds(): TArray<string>;
    function getAllFieldNames(cabinetId: string): TArray<string>;
    property IsError: boolean read FISERROR;
    function translateSelect(cabinetID: string; select: string): TArray<TField>; overload;
    function translateSelect(cabinetID: string; fields: TArray<TField>; FieldIDsOut: boolean = true): TArray<TField>; overload;
    function translateStoredatetime(fields: TArray<TField>): TArray<TField>;
  end;

implementation

uses
  main;

{ TDocuware }

constructor TDocuware.Create(Settings: TSettings);
begin
  inherited Create();
  self.FHttp := THttpClient.Create;
  self.FSettings := Settings;
end;

destructor TDocuware.Destroy;
begin
  try
    self.FHttp.Free;
  finally end;
  inherited;
end;

function TDocuware.select(task: TTask): TArray<TDocument>;
var
  // url building
  AFields: TArray<TField>;
  AField: TField;
  AUrl: string;

  DirectId: string;

  // request
  AReq: IHTTPRequest;
  ARes: IHTTPResponse;
  // response parsing
  AJson: TJSONValue;
  AJsonDocuments: TJSONArray;
  AJsonDocument: TJSONValue;
  AJsonDocumentFields: TJSONArray;
  AJsonDocumentField: TJSONValue;
  // result
  ADoc: TDocument;
  AIncludeField: boolean;
begin
  // build url
  AUrl := Format('/FileCabinets/%s/Documents?q=dialog;;;And;', [task.archiveId]);
  AFields := self.translateSelect(task.archiveId, task.selection);
  for AField in AFields do
    if (AField.Name.ToLower = 'dwdocid') then
      DirectId := AField.Value
    else
      AUrl := AUrl + Format(';%s:%s', [AField.Name, AField.Value]);
  if DirectId <> '' then
  begin
    // why does docuware have to be this BAD?
    // i hate my damn life right now
    // i dont want to write this shitty code.
    // i want to write good code.
    // öasldkfjölaskdfjslg
    // i hate my life
    // AAAAAAAAAAAAAAAAAAAHHHHHHHHHHHHHHHH
    // HEEEELLLPPPPP
    // i want to die
    // okay anyways  // @MeroFuruya 20230404_154422
    AReq := self.FHttp.GetRequest(sHTTPMethodGet, self.buildUrl(Format('/FileCabinets/%s/Documents/%s', [Task.archiveId, DirectId])));
    ARes := self.makeRequest(AReq);
    if ARes.StatusCode = 200 then
    begin
      AJsonDocument := TJSONValue.ParseJSONValue(ARes.ContentAsString);
      if AJsonDocument <> nil then
      begin
        // parse document
        ADoc.Id := AJsonDocument.GetValue<string>('Id', '');
        ADoc.Name := AJsonDocument.GetValue<string>('Title', '');
        ADoc.Fields := [];
        // Document fields
        if AJsonDocument.TryGetValue<TJSONArray>('Fields', AJsonDocumentFields) then
        begin
          for AJsonDocumentField in AJsonDocumentFields do
          begin
            // parse field
            AField.Name := AJsonDocumentField.GetValue<string>('FieldName', '');
            AField.Value := AJsonDocumentField.GetValue<string>('Item', '');

            // check if field should be included
            AIncludeField := AJsonDocument.GetValue<boolean>('SystemField', false);

            if not AIncludeField then
              AIncludeField := IndexText(AField.Name, ['DWSTOREDATETIME', 'DWDOCID', 'DWDISKNO', 'DWPAGECOUNT', 'DWFLAGS', 'DWOFFSET']) <> -1;

            if AIncludeField then
            begin
              // add field to document
              ADoc.Fields := ADoc.Fields + [AField];
            end;
          end;
        end;
        // add document to result
        Result := Result + [ADoc];
      end;
    end;
    exit;
  end;
  // make request
  AReq := self.FHttp.GetRequest(sHTTPMethodGet, self.buildUrl(AUrl));
  ARes := self.makeRequest(AReq);
  if ARes.StatusCode = 200 then
  begin
    AJson := TJSONValue.ParseJSONValue(ARes.ContentAsString);
    if AJson <> nil then
    begin
      // documents
      if AJson.TryGetValue<TJSONArray>('Items', AJsonDocuments) then
      begin
        for AJsonDocument in AJsonDocuments do
        begin
          // parse document
          ADoc.Id := AJsonDocument.GetValue<string>('Id', '');
          ADoc.Name := AJsonDocument.GetValue<string>('Title', '');
          ADoc.Fields := [];
          // Document fields
          if AJsonDocument.TryGetValue<TJSONArray>('Fields', AJsonDocumentFields) then
          begin
            for AJsonDocumentField in AJsonDocumentFields do
            begin
              // parse field
              AField.Name := AJsonDocumentField.GetValue<string>('FieldName', '');
              AField.Value := AJsonDocumentField.GetValue<string>('Item', '');

              // check if field should be included
              AIncludeField := AJsonDocument.GetValue<boolean>('SystemField', false);

              if not AIncludeField then
                AIncludeField := IndexText(AField.Name, ['DWSTOREDATETIME', 'DWDOCID', 'DWDISKNO', 'DWPAGECOUNT', 'DWFLAGS', 'DWOFFSET']) <> -1;

              if AIncludeField then
              begin
                // add field to document
                ADoc.Fields := ADoc.Fields + [AField];
              end;
            end;
          end;
          // add document to result
          Result := Result + [ADoc];
        end;
      end;
      AJson.Free;
    end;
  end;
end;

function TDocuware.getAllCabinetIds: TArray<string>;
var
  AReq: IHTTPRequest;
  ARes: IHTTPResponse;
  AJson: TJSONValue;
  AJsonCabinets: TJSONArray;
  AJsonCabinet: TJSONValue;
begin
  // make request
  AReq := self.FHttp.GetRequest(sHTTPMethodGet, self.buildUrl(Format('/FileCabinets?orgid=%s', [self.FSettings.DocuwareOrgId])));
  ARes := self.makeRequest(AReq);
  if ARes.StatusCode = 200 then
  begin
    // parse json
    AJson := TJSONValue.ParseJSONValue(ARes.ContentAsString);
    if AJson <> nil then
    begin
      if AJson.TryGetValue<TJSONArray>('FileCabinet', AJsonCabinets) then
      begin
        for AJsonCabinet in AJSonCabinets do
        begin
          Result := Result + [AJsonCabinet.GetValue<string>('Id', '')];
        end;
      end;
    end;
    AJson.Free;
  end;
end;

function TDocuware.Update(task: TTask): TDocument;
var
  AJsonCabinetInfo: TJsonValue;
  AExistingFields: TJSONArray;
  AJsonField: TJSONValue;
  // fields
  AFields: TArray<TField>;
  AField: TField;
  DirectId: string;
  AJsonFields: TJSONArray;
  ANewJsonField: TJSONObject;
  // request
  APayload: TJSONObject;
  APayloadStream: TStringStream;
  AReq: IHTTPRequest;
  ARes: IHTTPResponse;
  // result parsing
  AJson: TJSONValue;
  AJsonFields: TJSONArray;
  AJsonField: TJSONValue;
begin
  
  // get existing fields
  AReq := self.FHttp.GetRequest(sHTTPMethodGet, self.buildUrl(Format('/FileCabinets/%s', [task.archiveId])));
  ARes := self.makeRequest(AReq);
  if ARes.StatusCode = 200 then
  begin
    AJsonCabinetInfo := TJSONValue.ParseJSONValue(ARes.ContentAsString);
    if AJsonCabinetInfo <> nil then
    begin
      AExistingFields := AJsonCabinetInfo.GetValue<TJSONArray>('Fields', nil);
    end;
  end;

  if AExistingFields = nil then // catch error
  begin
    task.status := 'ERROR1';
    exit;
  end;

  // create payload
  APayload := TJSONObject.Create;
  AJsonFields := TJSONArray.Create;
  APayload.AddPair('Fields', AJsonFields);
  // get fields
  AFields := self.translateSelect(task.archiveId, task.selection);
  // get cabinet id
  DirectId := '';
  for AField in AFields do
    if (AField.Name.ToLower = 'dwdocid') then
      DirectId := AField.Value;
  if DirectId.IsEmpty then
  begin
    task.status := 'ERROR2';
    exit;
  end;
  // add fields
  for AField in AFields do
  begin
    // find field in existing fields
    for AJsonField in AExistingFields do
    begin
      if AField.Name = AJsonField.GetValue<string>('Name', '') then
      begin
        // check if field is NOT a system field
        if AJsonField.GetValue<string>('Scope', '') = 'User' then
        begin
          // add field to payload
          ANewJsonField := TJSONObject.Create;
          ANewJsonField.AddPair('FieldName', AField.Name);
          ANewJsonField.AddPair('Item', AField.Value);
          ANewJsonField.AddPair('ItemElementName', AJsonField.GetValue<string>('ItemElementName', ''));
          AJsonFields.AddElement(ANewJsonField);
        end;
      end;
    end;
  end;

  if AJsonFields.Count = 0 then
  begin
    self.FISERROR := true;
    exit;
  end;  // @todo yeah idfk :) but i stopped here

  // Create payload stream
  APayloadStream := TStringStream.Create(APayload.ToString);
  // Create Request
  AReq := self.FHttp.GetRequest(sHTTPMethodPut, self.buildUrl(Format('/FileCabinets/%s/Documents/%s/Fields', [task.archiveId, task.documentId])));
  AReq.AddHeader('Content-Type', 'application/json');
  AReq.AddHeader('Accept', 'application/json');
  AReq.SourceStream := APayloadStream;
  ARes := self.makeRequest(AReq);
  if ARes.StatusCode = 200 then
  begin
    AJson := TJSONValue.ParseJSONValue(ARes.ContentAsString);
    if AJson <> nil then
    begin
      // parse document
      Result.Id := AJson.GetValue<string>('Id', '');
      Result.Name := AJson.GetValue<string>('Title', '');
      Result.Fields := [];
      // Document fields
      if AJson.TryGetValue<TJSONArray>('Fields', AJsonFields) then
      begin
        for AJsonDocumentField in AJsonFields do
        begin
          // parse field
          AField.Name := AJsonDocumentField.GetValue<string>('FieldName', '');
          AField.Value := AJsonDocumentField.GetValue<string>('Item', '');

          // check if field should be included
          AIncludeField := AJsonDocument.GetValue<boolean>('SystemField', false);

          if not AIncludeField then
            AIncludeField := IndexText(AField.Name, ['DWSTOREDATETIME', 'DWDOCID', 'DWDISKNO', 'DWPAGECOUNT', 'DWFLAGS', 'DWOFFSET']) <> -1;

          if AIncludeField then
          begin
            // add field to document
            ADoc.Fields := ADoc.Fields + [AField];
          end;
        end;
      end;
    end;
    AJson.Free;
  end;
  APayloadStream.Free;
  APayload.Free;
  

end;

function TDocuware.getAllFieldNames(cabinetId: string): TArray<string>;
var
  AReq: IHTTPRequest;
  ARes: IHTTPResponse;
  AJson: TJSONValue;
  AJsonFields: TJSONArray;
  AJsonField: TJSONValue;
begin
  // make request
  AReq := self.FHttp.GetRequest(sHTTPMethodGet, self.buildUrl(Format('/FileCabinets/%s', [cabinetId])));
  ARes := self.makeRequest(AReq);
  if ARes.StatusCode = 200 then
  begin
    // parse json
    AJson := TJSONValue.ParseJSONValue(ARes.ContentAsString);
    if AJson <> nil then
    begin
      if AJson.TryGetValue<TJSONArray>('Fields', AJsonFields) then
      begin
        for AJsonField in AJSonFields do
        begin
          if AJsonField.GetValue<string>('Scope', '') <> 'System' then  // filter out system fields
            Result := Result + [AJsonField.GetValue<string>('DBFieldName', '')];
        end;
      end;
      AJson.Free;
    end;
  end;
end;

function TDocuware.makeRequest(AReq: IHTTPRequest): IHttpResponse;
const
  MAXTRIES = 10;
var
  ACount: integer;
begin
  ACount := 0;
  AReq.AddHeader('Accept', 'application/json');
  Result := FHttp.Execute(AReq);
  if Result.StatusCode = 401 then
  begin
    // sleep(50);
    if self.doLogin() then
    begin
      Result := FHttp.Execute(AReq);
      // THIS IS A HACK, DOCUWARE IS NOT WORKING PROPERLY :)
      // sometimes it returns 401 even after login, so we wait 10 ms, witch normally is enougth but just in case -> weird behaviour is weird lmao
      // yea then we try again
      // please just dont make the same mistake to use docuware   // @MeroFuruya 20230405_100339
      ACount := 0;
      while (Result.StatusCode = 401) and (ACount < MAXTRIES) do
      begin
        sleep(50);
        Result := FHttp.Execute(AReq);
        inc(ACount);
      end;
      if acount > 0 then
        Form_main.log(Format('Request failed with status code %d.%sURL: %s %s%sPayload: %s%sRetried %d of %d times', [Result.StatusCode, sLineBreak, AReq.MethodString, AReq.URL.ToString, sLineBreak, Result.ContentAsString, sLineBreak, ACount, MAXTRIES]));
    end;
  end;
  if (Result.StatusCode <> 200) and (ACount = 0) then
  begin
    Form_main.log(Format('Request failed with status code %d.%sURL: %s %s%sPayload: %s', [Result.StatusCode, sLineBreak, AReq.MethodString, AReq.URL.ToString, sLineBreak, Result.ContentAsString]));
    FISERROR := true;
    // raise Exception.CreateFmt('Request failed with code %d.', [Result.StatusCode]);
    Exit;
  end
  else
  begin
    FISERROR := false;
  end;
end;

function TDocuware.doLogin: boolean;
var
  AOrgJson: TJSONValue;
  AOrgName: string;
  AReq: IHTTPRequest;
  ARes: IHTTPResponse;
  APayload: TStringStream;
begin
  AOrgName := '';
  if self.FSettings.DocuwareOrgId <> '' then
  begin
    // get organization name
    AReq := self.FHttp.GetRequest(sHTTPMethodGet, self.buildUrl(Format('/Organizations/%s', [self.FSettings.DocuwareOrgId])));
    ARes := self.FHttp.Execute(AReq);
    if ARes.StatusCode = 200 then
    begin
      AOrgJson := TJSONValue.ParseJSONValue(ARes.ContentAsString);
      if AOrgJson <> nil then
      begin
        AOrgName := AOrgJson.GetValue<string>('Name', '');
        AOrgJson.Free;
      end;
    end;
  end;

  AReq := self.FHttp.GetRequest(sHTTPMethodPost, self.buildUrl('/Account/Logon'));
  AReq.AddHeader('Content-Type', 'application/x-www-form-urlencoded');
  AReq.AddHeader('Accept', 'application/json');
  APayload := TStringStream.Create(Format(
    'UserName=%s&Password=%s&Organization=%s&LicenseType=&RememberMe=false&RedirectToMyselfInCaseOfError=false&HostID=%s',
    [self.FSettings.DocuwareUser, self.FSettings.DocuwarePassword, AOrgName, self.FSettings.DocuwareHostId]
    ));
  AReq.SourceStream := APayload;
  ARes := self.FHttp.Execute(AReq);
  
  APayload.Free;

  if ARes.StatusCode <> 200 then
  begin
    Form_main.log(Format('Login failed with status code %d.%sURL: %s %s%sPayload: %s', [ARes.StatusCode, sLineBreak, AReq.MethodString, AReq.URL.ToString, sLineBreak, ARes.ContentAsString]));
    Result := false;
    // raise Exception.CreateFmt('Login failed with code %d.', [ARes.StatusCode]);
    Exit;
  end
  else
  begin
    Form_main.log('Login successful.');
    Result := true;
  end;
end;

function TDocuware.buildUrl(APath: string): string;
begin
  if not APath.StartsWith('/') then APath := '/' + APath;
  Result := 'http://' + self.FSettings.DocuwareIp + '/docuware/platform' + APath;
end;

function TDocuware.translateSelect(cabinetID: string; select: string): TArray<TField>;
var
  AElem: TArray<string>;
  AI: integer;
  ANewField: TField;
  ANewFieldName: string;
begin
  AElem := select.Split([',']);
  for AI := 0 to (Length(AElem) div 2) - 1 do
  begin
    // parse field name
    if AElem[AI * 2] = '243' then
      ANewFieldName := 'DWSTOREDATETIME'
    else if AElem[AI * 2] = '248' then
      ANewFieldName := 'DWDOCID'
    else if AElem[AI * 2] = '249' then
      ANewFieldName := 'DWDISKNO'
    else if AElem[AI * 2] = '69632' then
      ANewFieldName := 'DocuWareFulltext'
    else
      ANewFieldName := self.FSettings.getFieldName(cabinetID, AElem[AI * 2]);
    ANewField.Name := ANewFieldName;
    ANewField.Value := AElem[AI * 2 + 1];
    Result := Result + [ANewField];
  end;
end;

function TDocuware.translateSelect(cabinetID: string; fields: TArray<TField>; FieldIDsOut: boolean = true): TArray<TField>;
var
  AField: TField;
  ANewField: TField;
  AConvertedFieldIdentifier: string;
  ANewValue: string;

  function ConvertIfDate(AValue: string): string;
  var
    AChar: Char;
    ANewValue: string;
  begin
    if AValue.StartsWith('/Date(') and AValue.EndsWith(')/') then
    begin
      for AChar in AValue do
        if Achar in ['0' .. '9'] then
          ANewValue := ANewValue + AChar;
      Result := UnixToDateTime(StrToInt64(ANewValue)).ToISO8601(False);
    end
    else
      Result := AValue;
  end;

begin
  Result := [];
  self.FISERROR := false;
  for AField in fields do
  begin
    if FieldIDsOut then
    begin
      ANewValue := '';
      if AField.Name = 'DWSTOREDATETIME' then
      begin
        AConvertedFieldIdentifier := '243';
        ANewValue := ConvertIfDate(AField.Value);
      end
      else if AField.Name = 'DWDOCID' then
        AConvertedFieldIdentifier := '248'
      else if AField.Name = 'DWDISKNO' then
        AConvertedFieldIdentifier := '249'
      else if AField.Name = 'DocuWareFulltext' then
        AConvertedFieldIdentifier := '69632'
      else if IndexText(AField.Name, ['DWPAGECOUNT', 'DWFLAGS', 'DWOFFSET']) <> -1 then Continue // ignore these fields
      else
        AConvertedFieldIdentifier := self.FSettings.getFieldID(cabinetID, AField.Name);
    end
    else
    begin
      if AField.Name = '243' then
      begin
        AConvertedFieldIdentifier := 'DWSTOREDATETIME';
        ANewValue := Format('/Date(%s)/', [DateTimeToUnix(ISO8601ToDate(AField.Value)).ToString]);
      end
      else if AField.Name = '248' then
        AConvertedFieldIdentifier := 'DWDOCID'
      else if AField.Name = '249' then
        AConvertedFieldIdentifier := 'DWDISKNO'
      else if AField.Name = '69632' then
        AConvertedFieldIdentifier := 'DocuWareFulltext'
      else
        AConvertedFieldIdentifier := self.FSettings.getFieldName(cabinetID, AField.Name);
    end;
    if AConvertedFieldIdentifier <> '' then
    begin
      ANewField.Name := AConvertedFieldIdentifier;
      if ANewValue <> '' then
        ANewField.Value := ANewValue
      else
        ANewField.Value := AField.Value;
      Result := Result + [ANewField];
      self.FISERROR := self.FISERROR or false;
    end
    else
      self.FISERROR := true;
  end;
end;

function TDocuware.translateStoredatetime(fields: TArray<TField>): TArray<TField>;
var
  AField: TField;
  ANewField: TField;

  function dwToDatetime(s: string): TDateTime;
  var
    NewStr: string;
    AChar: char;
  begin
    if s.StartsWith('/Date(', true) and s.EndsWith(')/') then
    begin
      for AChar in s do
        if AChar in ['0'..'9'] then
          NewStr := NewStr + AChar;
      Result := UnixToDateTime(StrToInt64(NewStr));
    end
    else
      Result := 0;
  end;

begin
  Result := [];
  for AField in fields do
  begin
    if AField.Name = 'DWSTOREDATETIME' then
    begin
      ANewField.Name := 'SDATE';
      ANewField.Value := dwToDatetime(AField.Value).Format('dd.mm.yyyy');
      Result := Result + [ANewField];
      ANewField.Name := 'STIME';
      ANewField.Value := dwToDatetime(AField.Value).Format('hh:nn');
      Result := Result + [ANewField];
    end
    else if AField.Name = 'DWDOCID' then
    begin
      ANewField.Name := 'DOCID';
      ANewField.Value := AField.Value;
      Result := Result + [ANewField];
    end
    else if AField.Name = 'DWDISKNO' then
    begin
      ANewField.Name := 'DISK';
      ANewField.Value := AField.Value;
      Result := Result + [ANewField];
    end
    else if AField.Name = 'DWPAGECOUNT' then
    begin
      ANewField.Name := 'PAGES';
      ANewField.Value := AField.Value;
      Result := Result + [ANewField];
    end
    else if AField.Name = 'DWFLAGS' then
    begin
      ANewField.Name := 'FLAGS';
      ANewField.Value := AField.Value;
      Result := Result + [ANewField];
    end
    else if AField.Name = 'DWOFFSET' then
    begin
      ANewField.Name := 'OFFSET';
      ANewField.Value := AField.Value;
      Result := Result + [ANewField];
    end
    else
    begin
      ANewField.Name := AField.Name;
      ANewField.Value := AField.Value;
      Result := Result + [ANewField];
    end;
  end;
end;

end.
