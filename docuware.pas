unit Docuware;

interface

uses
  System.SysUtils,
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
    function makeRequest(AReq: IHTTPRequest): IHttpResponse;
    function buildUrl(APath: string): string;
    procedure doLogin();
    function translateSelect(cabinetID: string; select: string): TArray<TField>; overload;
    function translateSelect(fields: TArray<TField>; WithValues: boolean = False; Sep: string = ','): string; overload;
  public
    constructor Create(Settings: TSettings);
    destructor Destroy; override;
    function select(task: TTask): TArray<TDocument>;
    function getAllCabinetIds(): TArray<string>;
    function getAllFieldNames(cabinetId: string): TArray<string>;
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
begin
  //@MeroFuruya @todo create field mapper, then continue here :)
  // build url
  AUrl := '/Documents?q=dialog;;;And;';
  AFields := self.translateSelect(task.CabinetId, task.Select);
  for AField in AFields do
    AUrl := AUrl + Format(';%s:%s', [AField.Name, AField.Value]);
  // make request
  AReq := self.FHttp.GetRequest(sHTTPMethodGet, self.buildUrl(AUrl));
  ARes := self.makeRequest(AReq);
  if ARes.StatusCode = 200 then
  begin
    AJson := TJSONValue.ParseJSONValue(ARes.ContentAsString);
    if AJson <> nil then
    begin
      if AJson.TryGetValue<TJSONArray>('Items', AJsonDocuments) then
      begin
        for AJsonDocument in AJsonDocuments do
        begin
          ADoc.Id := AJsonDocument.GetValue<string>('Id', '');  // @iwashere @MeroFuruya
          ADoc.Name := AJsonDocument.GetValue<string>('Title', '');
          ADoc.Size := AJsonDocument.GetValue<string>('FileSize', '');
          ADoc.Date := AJsonDocument.GetValue<string>('CreatedAt', '');
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
var
  ACount: integer;
begin
  AReq.AddHeader('Accept', 'application/json');
  Result := FHttp.Execute(AReq);
  if Result.StatusCode = 401 then
  begin
    self.doLogin();
    Result := FHttp.Execute(AReq);
    // THIS IS A HACK, DOCUWARE IS NOT WORKING PROPERLY :)
    // sometimes it returns 401 even after login, so we wait 10 ms, witch normally is enougth but just in case -> weird behaviour is weird lmao
    // yea then we try again
    // please just mayke the same mistake and dont use docuware
    ACount := 0;
    while (Result.StatusCode = 401) and (ACount <= 10) do
    begin
      sleep(10);
      Result := FHttp.Execute(AReq);
      inc(ACount);
    end;
  end;
  if Result.StatusCode <> 200 then
  begin
    Form_main.log(Format('Request failed with status code %d.%sURL: %s', [Result.StatusCode, sLineBreak, AReq.URL.ToString]));
    Form_main.log(Result.ContentAsString);
    raise Exception.CreateFmt('Request failed with code %d.', [Result.StatusCode]);
    Exit;
  end;
end;

procedure TDocuware.doLogin;
var
  AReq: IHTTPRequest;
  ARes: IHTTPResponse;
  APayload: TStringStream;
begin
  AReq := self.FHttp.GetRequest(sHTTPMethodPost, self.buildUrl('/Account/Logon'));
  AReq.AddHeader('Content-Type', 'application/x-www-form-urlencoded');
  AReq.AddHeader('Accept', 'application/json');
  APayload := TStringStream.Create(Format(
    'UserName=%s&Password=%s&Organization=&LicenseType=&RememberMe=false&RedirectToMyselfInCaseOfError=True',
    [self.FSettings.DocuwareUser, self.FSettings.DocuwarePassword]
    ));
  AReq.SourceStream := APayload;
  ARes := self.FHttp.Execute(AReq);
  
  APayload.Free;

  if ARes.StatusCode <> 200 then
  begin
    Form_main.log(Format('Login failed with status code %d.', [ARes.StatusCode]));
    Form_main.log(ARes.ContentAsString);
    raise Exception.CreateFmt('Login failed with code %d.', [ARes.StatusCode]);
    Exit;
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

function TDocuware.translateSelect(fields: TArray<TField>; WithValues: boolean = False; Sep: string = ','): string;
var
  AElem: TArray<string>;
  AField: TField;
begin
  // @MeroFuruya @todo implement this
  for AField in fields do
  begin
    if WithValues then
      AElem := AElem + [self.FSettings.getFieldId(cabinetId, AField.Name), AField.Value]
    else
      AElem := AElem + [self.FSettings.getFieldId(cabinetId, AField.Name)];
  end;
  Result := string.Join(Sep, Result);
end;

end.
