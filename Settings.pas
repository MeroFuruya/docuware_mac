unit Settings;

interface

uses 
  System.Classes, System.IniFiles, System.SysUtils,
  utils;

type
  TSettings = class
  private
    Ini: TIniFile;

    // --- Docuware ---
    xDocuwareIp: String;
    xDocuwareUser: String;
    xDocuwarePassword: String;
    xDocuwareHostId: String;
    xDocuwareOrgId: String;
    xDocuwareMaxReconnects: String;
    xDocuwareReconnectWait: String;
    xDocuwareTestConnectionEvery: String;

    // --- Database ---
    xDatabaseIsRemote: String;

    // --- Remote Database ---
    xRemoteDatabaseAlias: String;
    xRemoteDatabasePort: String;
    xRemoteDatabaseIp: String;
    xRemoteDatabaseUser: String;
    xRemoteDatabasePassword: String;
    xRemoteDatabaseTimeout: String;
    xRemoteDatabaseMaxReconnects: String;
    xRemoteDatabaseReconnectWait: String;


    // --- Local Database ---
    xLocalDatabaseAlias: String;
    xLocalDatabasePath: String;
    xLocalDatabaseTempPath: String;
    xLocalDatabaseListenIp: String;
    xLocalDatabaseListenPort: String;
    xLocalDatabaseUser: String;
    xLocalDatabasePassword: String;

    // --- Timings ---
    xTimingsWait: string;

    function IniGetAndCreateIfValueNotExists(Section: String; Ident: String; Value: String): String;
  public
    constructor Create();
    destructor Destroy; override;

    // --- Docuware ---
    property DocuwareIp: String read xDocuwareIp;
    property DocuwareUser: String read xDocuwareUser;
    property DocuwarePassword: String read xDocuwarePassword;
    property DocuwareHostId: String read xDocuwareHostId;
    property DocuwareOrgId: String read xDocuwareOrgId;
    property DocuwareTestConnectionEvery: String read xDocuwareTestConnectionEvery;
    property DocuwareMaxReconnects: String read xDocuwareMaxReconnects;
    property DocuwareReconnectWait: String read xDocuwareReconnectWait;

    // --- Database ---
    
    property DatabaseIsRemote: String read xDatabaseIsRemote;

    // --- Remote Database ---
    property RemoteDatabaseAlias: String read xRemoteDatabaseAlias;
    property RemoteDatabasePort: String read xRemoteDatabasePort;
    property RemoteDatabaseIp: String read xRemoteDatabaseIp;
    property RemoteDatabaseUser: String read xRemoteDatabaseUser;
    property RemoteDatabasePassword: String read xRemoteDatabasePassword;
    property RemoteDatabaseTimeout: String read xRemoteDatabaseTimeout;
    property RemoteDatabaseMaxReconnects: String read xRemoteDatabaseMaxReconnects;
    property RemoteDatabaseReconnectWait: String read xRemoteDatabaseReconnectWait;

    // --- Local Database ---
    property LocalDatabaseAlias: String read xLocalDatabaseAlias;
    property LocalDatabasePath: String read xLocalDatabasePath;
    property LocalDatabaseTempPath: String read xLocalDatabaseTempPath;
    property LocalDatabaseListenIp: String read xLocalDatabaseListenIp;
    property LocalDatabaseListenPort: String read xLocalDatabaseListenPort;
    property LocalDatabaseUser: String read xLocalDatabaseUser;
    property LocalDatabasePassword: String read xLocalDatabasePassword;

    // --- Timings ---
    property TimingsWait: String read xTimingsWait;
  end;

implementation

constructor TSettings.Create();
begin
  inherited Create;
  Ini := TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini'));

  // --- Docuware ---
  xDocuwareIp := IniGetAndCreateIfValueNotExists('DOCUWARE', 'Ip', '127.0.0.1');
  xDocuwareUser := IniGetAndCreateIfValueNotExists('DOCUWARE', 'Username', '');
  xDocuwarePassword := IniGetAndCreateIfValueNotExists('DOCUWARE', 'Password', '');
  xDocuwareHostId := IniGetAndCreateIfValueNotExists('DOCUWARE', 'HostId', 'RestfulDocuwareLmpsWorker');
  xDocuwareOrgId := IniGetAndCreateIfValueNotExists('DOCUWARE', 'OrgId', '');
  xDocuwareTestConnectionEvery := IniGetAndCreateIfValueNotExists('DOCUWARE', 'TestConnectionEvery', '1000');
  xDocuwareMaxReconnects := IniGetAndCreateIfValueNotExists('DOCUWARE', 'MaxReconnects', '0');
  xDocuwareReconnectWait := IniGetAndCreateIfValueNotExists('DOCUWARE', 'ReconnectWait', '10000');


  // --- Database ---
  xDatabaseIsRemote := IniGetAndCreateIfValueNotExists('DATABASE', 'IsRemote', 'true');

  // --- Remote Database ---
  xRemoteDatabaseAlias := IniGetAndCreateIfValueNotExists('REMOTEDATABASE', 'Alias', 'Docuware');
  xRemoteDatabasePort := IniGetAndCreateIfValueNotExists('REMOTEDATABASE', 'Port', '16000');
  xRemoteDatabaseIp := IniGetAndCreateIfValueNotExists('REMOTEDATABASE', 'Ip', '127.0.0.1');
  xRemoteDatabaseUser := IniGetAndCreateIfValueNotExists('REMOTEDATABASE', 'Username', '');
  xRemoteDatabasePassword := IniGetAndCreateIfValueNotExists('REMOTEDATABASE', 'Password', '');
  xRemoteDatabaseTimeout := IniGetAndCreateIfValueNotExists('REMOTEDATABASE', 'Timeout', '60000');
  xRemoteDatabaseMaxReconnects := IniGetAndCreateIfValueNotExists('REMOTEDATABASE', 'maxReconnects', '0');
  xRemoteDatabaseReconnectWait := IniGetAndCreateIfValueNotExists('REMOTEDATABASE', 'ReconnectWait', '60');

  // --- Local Database ---
  xLocalDatabaseAlias := IniGetAndCreateIfValueNotExists('LOCALDATABASE', 'Alias', 'Docuware');
  xLocalDatabasePath := ExpandEnvStr(IniGetAndCreateIfValueNotExists('LOCALDATABASE', 'Path', '%LOCALAPPDATA%\RestfulDocuwareLMPSWorker\')); // ExpandEnvStr is needed for %APPDATA%
  xLocalDatabaseTempPath := ExpandEnvStr(IniGetAndCreateIfValueNotExists('LOCALDATABASE', 'TempPath', '%LOCALAPPDATA%\Temp\RestfulDocuwareLMPSWorker')); // ExpandEnvStr is needed for %APPDATA%
  xLocalDatabaseListenIp := IniGetAndCreateIfValueNotExists('LOCALDATABASE', 'ListenIp', '0.0.0.0');
  xLocalDatabaseListenPort := IniGetAndCreateIfValueNotExists('LOCALDATABASE', 'ListenPort', '16000');
  xLocalDatabaseUser := IniGetAndCreateIfValueNotExists('LOCALDATABASE', 'Username', '');
  xLocalDatabasePassword := IniGetAndCreateIfValueNotExists('LOCALDATABASE', 'Password', '');

  // --- Timings ---
  xTimingsWait := IniGetAndCreateIfValueNotExists('TIMINGS', 'ProcessWaitTime', '300');

  // i know it would be better if i would do a check if the file has changed
  // and only then reload it but i dont really care
  Ini.UpdateFile;

end;

function TSettings.IniGetAndCreateIfValueNotExists(Section: String; Ident: String; Value: String): String;
begin
  if Ini.ReadString(Section, Ident, '') = '' then
    Ini.WriteString(Section, Ident, Value);
  Result := Ini.ReadString(Section, Ident, Value);
end;

destructor TSettings.Destroy;
begin
  Ini.Free;
  inherited Destroy;
end;

end.