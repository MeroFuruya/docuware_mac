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
  Settings;

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
    constructor Create;
    destructor Destroy; override;
    function select(): TArray<TDocument>;
  end;

implementation

uses
  main;

{ TDocuware }

constructor TDocuware.Create(Settings: TSettings);
begin
  inherited;
  self.FHttp := THttpClient.Create;
  self.FSettings := Settings;
end;

destructor TDocuware.Destroy;
begin
  self.FHttp.Free;
  inherited;
end;

function TDocuware.select: TArray<TDocument>;
var
  AReq: IHTTPRequest;
  ARes: IHTTPResponse;
  AJson: TJSONObject;
  AJsonArr: TJSONArray;
  AJsonObj: TJSONObject;
  ADoc: TDocument;
  I: Integer;
begin
  AReq := self.FHttp.GetRequest(sHTTPMethodGet, self.buildUrl('/Documents')); // @todo @MeroFuruya: this function must take some args and stuff idk yet
end;

function TDocuware.makeRequest(AReq: IHTTPRequest): IHttpResponse;
begin
  Result := FHttp.Execute(AReq);
  if Result.StatusCode = 401 then
  begin
    self.doLogin();
    Result := FHttp.Execute(AReq);
  end
  else if Result.StatusCode <> 200 then
  begin
    Form_main.log(Format('Request failed with status code %d.', [Result.StatusCode]]));
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
  AReq.AddHeader('Content-Type', 'application/xxx-www-form-urlencoded');
  AReq.AddHeader('Accept', 'application/json');
  APayload := TStringStream.Create('username=' + self.FSettings.DocuwareUser + '&password=' + self.FSettings.DocuwarePassword);
  AReq.ContentStream := APayload;
  ARes := self.FHttp.Execute(AReq);

  if ARes.StatusCode <> 200 then
  begin
    Form_main.log(Format('Login failed with status code %d.', [ARes.StatusCode]]));
    raise Exception.CreateFmt('Login failed with code %d.', [ARes.StatusCode]);
    Exit;
  end;
end;

function TDocuware.buildUrl(APath: string): string;
begin
  if not APath.StartsWith('/') then APath := '/' + APath;
  Result := 'http://' + self.FSettings.DocuwareUrl + '/docuware/platform' + APath;
end;

end.