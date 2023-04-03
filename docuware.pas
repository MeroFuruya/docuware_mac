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

  TDocument = record
    Id: string;
    Name: string;
    Size: string;
    Date: string;
  end;

  TDocuware = class
  private
    FHttp: THttpClient;
    FSettings: TSettings;
    function makeRequest(AReq: IHTTPRequest): IHttpResponse;
    function buildUrl(APath: string): string;
    procedure doLogin();
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
  AReq: IHTTPRequest;
  ARes: IHTTPResponse;
  AJson: TJSONObject;
  AJsonArr: TJSONArray;
  AJsonObj: TJSONObject;
  ADoc: TDocument;
  I: Integer;
begin
  //@MeroFuruya @todo create field mapper, then continue here :)

  AReq := self.FHttp.GetRequest(sHTTPMethodGet, self.buildUrl('/Documents'));

end;

function TDocuware.getAllCabinetIds: TArray<string>;
var
  AReq: IHTTPRequest;
  ARes: IHTTPResponse;
  AJson: TJSONValue;
  AJsonArr: TJSONArray;
  AJsonObj: TJSONObject;
  s: string;
  I: Integer;
begin
  AReq := self.FHttp.GetRequest(sHTTPMethodGet, self.buildUrl(Format('/FileCabinets?orgid=%s', [self.FSettings.DocuwareOrgId])));
  ARes := self.makeRequest(AReq);
  AJson := TJSONValue.ParseJSONValue(ARes.ContentAsString);
  s := ARes.ContentAsString;
  AJsonArr := AJson.GetValue<TJSONArray>('FileCabinet');
  SetLength(Result, AJsonArr.Count);
  for I := 0 to AJsonArr.Count - 1 do
  begin
    AJsonObj := AJsonArr.Items[I] as TJSONObject;
    Result[I] := AJsonObj.GetValue('Id').Value;
  end;
end;

function TDocuware.getAllFieldNames(cabinetId: string): TArray<string>;
var
  AReq: IHTTPRequest;
  ARes: IHTTPResponse;
  AJson: TJSONObject;
  AJsonArr: TJSONArray;
  AJsonObj: TJSONObject;
  I: Integer;
begin
  AReq := self.FHttp.GetRequest(sHTTPMethodGet, self.buildUrl(Format('/FileCabinets/%s', [cabinetId])));
  ARes := self.makeRequest(AReq);
  AJson := TJSONObject.ParseJSONValue(ARes.ContentAsString) as TJSONObject;
  AJsonArr := AJson.GetValue('Fields') as TJSONArray;
  SetLength(Result, AJsonArr.Count);
  for I := 0 to AJsonArr.Count - 1 do
  begin
    AJsonObj := AJsonArr.Items[I] as TJSONObject;
    Result[I] := AJsonObj.GetValue('DBFieldName').Value;
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
    while (Result.StatusCode = 401) or (ACount >= 10) do
    begin
      sleep(10);
      Result := FHttp.Execute(AReq);
      inc(ACount);
    end;
  end
  else if Result.StatusCode <> 200 then
  begin
    Form_main.log(Format('Request failed with status code %d.', [Result.StatusCode]));
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

end.
