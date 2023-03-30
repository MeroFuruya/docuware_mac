unit database;

interface

uses
  System.SysUtils, System.Classes, Data.DB, nxdb, nxsrSqlEngineBase,
  nxsqlEngine, nxsdServerEngine, nxsrServerEngine, nxllTransport,
  nxchCommandHandler, nxllComponent, nxptBasePooledTransport,
  nxtwWinsockTransport, nxseAutoComponent,
  nxreRemoteServerEngine, settings, StatConst;

type
  TDatabase = class(TDataModule)
    nxseAllEngines1: TnxseAllEngines;
    nxListenTrans: TnxWinsockTransport;
    nxLocSrvEng: TnxServerEngine;
    nxSqlEng: TnxSqlEngine;
    nxTrans: TnxWinsockTransport;
    nxSe1: TnxSession;
    nxDb1: TnxDatabase;
    nxtbAnforderung: TnxTable;
    nxtbResult: TnxTable;
    nxtbAnforderungPK: TnxTable;
    nxtbResObj: TnxTable;
    dtsAnforderung: TDataSource;
    dtsResult: TDataSource;
    dtsAnforderungPK: TDataSource;
    dtsResObj: TDataSource;
    nxtbAnforderungGUID: TnxStringField;
    nxtbAnforderungSTATUS: TnxStringField;
    nxtbAnforderungCOMMAND: TnxStringField;
    nxtbAnforderungDELFLG: TnxStringField;
    nxtbAnforderungARCHIVE: TnxStringField;
    nxtbAnforderungSELECTION: TnxStringField;
    nxtbAnforderungRESULTHEADER: TnxStringField;
    nxtbAnforderungERSTELLTVON: TnxStringField;
    nxtbAnforderungERSTELLTAM: TDateTimeField;
    nxtbResultANFGUID: TnxStringField;
    nxtbResultGUID: TnxStringField;
    nxtbResultPOS: TIntegerField;
    nxtbResultDOCID: TIntegerField;
    nxtbResultRESULTLINE: TnxStringField;
    nxtbResultINDEXDATA: TnxStringField;
    nxtbResultOBJECTLOADED: TIntegerField;
    nxtbAnforderungPKGUID: TnxStringField;
    nxtbAnforderungPKSTATUS: TnxStringField;
    nxtbAnforderungPKCOMMAND: TnxStringField;
    nxtbAnforderungPKDELFLG: TnxStringField;
    nxtbAnforderungPKARCHIVE: TnxStringField;
    nxtbAnforderungPKSELECTION: TnxStringField;
    nxtbAnforderungPKRESULTHEADER: TnxStringField;
    nxtbAnforderungPKERSTELLTVON: TnxStringField;
    nxtbAnforderungPKERSTELLTAM: TDateTimeField;
    nxQuery1: TnxQuery;
    nxlocalCommandH: TnxServerCommandHandler;
    nxRmtSrvEng: TnxRemoteServerEngine;
    nxtbArchivePK: TnxTable;
    dtsArchivePK: TDataSource;
    nxtbArchivePKAR_GUID: TnxStringField;
    nxtbArchivePKAR_ID: TnxStringField;
    nxtbArchivePKAR_BEZ: TnxStringField;
    nxtbArchivePKAR_DOKPATH: TnxStringField;
    nxtbArchivePKAR_LTZLFDNR: TIntegerField;
    nxtbArchive: TnxTable;
    dtsArchive: TDataSource;
    nxtbArchiveID: TnxTable;
    dtaArchiveID: TDataSource;
    nxtbArchiveIDAR_GUID: TnxStringField;
    nxtbArchiveIDAR_ID: TnxStringField;
    nxtbArchiveIDAR_BEZ: TnxStringField;
    nxtbArchiveIDAR_DOKPATH: TnxStringField;
    nxtbArchiveIDAR_LTZLFDNR: TIntegerField;
    nxtbArchiveAR_GUID: TnxStringField;
    nxtbArchiveAR_ID: TnxStringField;
    nxtbArchiveAR_BEZ: TnxStringField;
    nxtbArchiveAR_DOKPATH: TnxStringField;
    nxtbArchiveAR_LTZLFDNR: TIntegerField;
    nxtbFields: TnxTable;
    dtsFields: TDataSource;
    nxtbFieldsPK: TnxTable;
    dtsFieldPK: TDataSource;
    nxtbResObjANFGUID: TnxStringField;
    nxtbResObjRESULTGUID: TnxStringField;
    nxtbResObjGUID: TnxStringField;
    nxtbResObjOBJEKTNAME: TnxStringField;
    nxtbResObjOBJEKT: TBlobField;
    dtsFieldsName: TDataSource;
    nxtbFieldsName: TnxTable;
    nxtbFieldsCABINETID: TnxStringField;
    nxtbFieldsINDEXNR: TIntegerField;
    nxtbFieldsFIELDNAME: TnxStringField;
    nxtbFieldsFIELDALIAS: TnxStringField;
    nxtbFieldsFIELDTYPE: TnxStringField;
    nxtbFieldsSystemField: TBooleanField;
    nxtbFieldsPKCABINETID: TnxStringField;
    nxtbFieldsPKINDEXNR: TIntegerField;
    nxtbFieldsPKFIELDNAME: TnxStringField;
    nxtbFieldsPKFIELDALIAS: TnxStringField;
    nxtbFieldsPKFIELDTYPE: TnxStringField;
    nxtbFieldsPKSystemField: TBooleanField;
    nxtbFieldsNameCABINETID: TnxStringField;
    nxtbFieldsNameINDEXNR: TIntegerField;
    nxtbFieldsNameFIELDNAME: TnxStringField;
    nxtbFieldsNameFIELDALIAS: TnxStringField;
    nxtbFieldsNameFIELDTYPE: TnxStringField;
    nxtbFieldsNameSystemField: TBooleanField;
    procedure nxtbAnforderungAfterInsert(DataSet: TDataSet);
    procedure nxtbAnforderungBeforeDelete(DataSet: TDataSet);
    procedure nxtbResultAfterInsert(DataSet: TDataSet);
    procedure nxtbResultBeforeDelete(DataSet: TDataSet);
    procedure nxtbResObjAfterInsert(DataSet: TDataSet);
    procedure nxtbAnforderungPKAfterInsert(DataSet: TDataSet);
    procedure ne(DataSet: TDataSet);
  private
    function GetNewGuid(): string;
    property NewGuid: string read GetNewGuid;
    procedure openTables();
  public
    AllDatasources: TArray<TDataSource>;
    Constructor Create(pOwner: TComponent); override;
    Destructor Destroy(); override;
    procedure OpenRemoteDB(Settings: TSettings);
    procedure CloseRemoteDB();
    procedure OpenLocalDB(Settings: TSettings);
    procedure CloseLocalDB();
  end;

var
  Fdatabase: TDatabase;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

Constructor Tdatabase.Create(pOwner: TComponent);
begin
  inherited Create(pOwner);
  self.AllDatasources := [dtsAnforderung, dtsResult, dtsAnforderungPK, dtsResObj, dtsArchivePK, dtsArchive, dtsFields, dtsFieldPK, dtsFieldsName];
end;


Destructor  Tdatabase.Destroy();
begin
  nxTrans.Close();
  nxtbResObj.Close();
  nxtbResult.Close();
  nxtbAnforderung.Close();
  nxtbAnforderungPK.Close();
  inherited Destroy();
end;

procedure Tdatabase.OpenRemoteDB(Settings: TSettings);
begin
  // setup Session
  nxSe1.ServerEngine := nxRmtSrvEng;

  // setup Transport
  nxTrans.ServerName := Settings.RemoteDatabaseIp;
  nxTrans.Port := StrToInt(Settings.RemoteDatabasePort);
  // open Transport
  nxTrans.Open();
  // setup Session
  nxSe1.ServerEngine := nxRmtSrvEng;
  nxSe1.UserName := Settings.RemoteDatabaseUser;
  nxSe1.Password := Settings.RemoteDatabasePassword;
  nxSe1.Timeout := StrToInt(Settings.RemoteDatabaseTimeout);
  // open Session
  nxSe1.Open();

  // check if Session can see Database
  if not nxSe1.IsAlias(Settings.RemoteDatabaseAlias) then
    nxSe1.AddAlias(Settings.RemoteDatabaseAlias, ChangeFileExt(ParamStr(0), '/'), true);

  // setup Database
  nxDb1.Session := nxSe1;
  nxDb1.AliasName := Settings.RemoteDatabaseAlias;
  // open Database
  nxdb1.Open();

  openTables();

end;

procedure Tdatabase.openTables;
begin
  // open Tables
  if not nxtbAnforderung.Exists then
  begin
  //  nxtbAnforderung.CreateTable();
    nxQuery1.SQL.Text := ''
    + 'create table "ANFORDERUNG"'
    + '("GUID" VARCHAR(38),'
    + '"STATUS" VARCHAR(15),"COMMAND" VARCHAR(15),'
    + '"DELFLG" VARCHAR(1),"ARCHIVE" VARCHAR(255),'
    + '"SELECTION" VARCHAR(255),"RESULTHEADER" VARCHAR(1024),'
    + '"ERSTELLTVON" VARCHAR(30),"ERSTELLTAM" DATETIME);'
//    + 'Alter table "ANFORDERUNG" SET DESCRIPTION "Anforderungen"; '
    + 'ALTER TABLE "ANFORDERUNG" ALTER COLUMN "GUID" SET DESCRIPTION ''k'';'
    + 'ALTER TABLE "ANFORDERUNG" ALTER COLUMN "STATUS" SET DESCRIPTION ''h'';'
    + 'ALTER TABLE "ANFORDERUNG" ALTER COLUMN "COMMAND" SET DESCRIPTION ''h'';'
    + 'ALTER TABLE "ANFORDERUNG" ALTER COLUMN "DELFLG" SET DESCRIPTION ''h'';'
    + 'ALTER TABLE "ANFORDERUNG" ALTER COLUMN "ARCHIVE" SET DESCRIPTION ''h'';'
    + 'ALTER TABLE "ANFORDERUNG" ALTER COLUMN "SELECTION" SET DESCRIPTION ''h'';'
    + 'ALTER TABLE "ANFORDERUNG" ALTER COLUMN "RESULTHEADER" SET DESCRIPTION ''h'';'
    + 'ALTER TABLE "ANFORDERUNG" ALTER COLUMN "ERSTELLTVON" SET DESCRIPTION ''h'';'
    + 'ALTER TABLE "ANFORDERUNG" ALTER COLUMN "ERSTELLTAM" SET DESCRIPTION ''h'';'
    + 'create unique index "ANFORDERUNG_INDSTAT" on  "ANFORDERUNG" ("STATUS" NULLS FIRST ,"GUID" NULLS FIRST);'
    + 'create unique index "ANFORDERUNG_PK" on "ANFORDERUNG" ("GUID" NULLS FIRST);';
    nxQuery1.ExecSQL();
  end;
  nxtbAnforderung.Open();
  nxtbAnforderungPK.Open();

  if not nxtbResult.Exists then
  begin
//    nxtbResult.CreateTable();
    nxQuery1.SQL.Text := ''
    + 'create table "RESULT"('
    + '"ANFGUID"  VARCHAR(38),"GUID" VARCHAR(38),'
    + '"POS"  INTEGER,"DOCID" INTEGER,'
    + '"RESULTLINE" VARCHAR(2024),"INDEXDATA" VARCHAR(2024),'
    + '"OBJECTLOADED" INTEGER);'
//    + 'Alter table "RESULT" SET DESCRIPTION ''Results'';'
    + 'ALTER TABLE "RESULT" ALTER COLUMN "ANFGUID" SET DESCRIPTION ''o ==>ANFORDERUNG.GUID'';'
    + 'ALTER TABLE "RESULT" ALTER COLUMN "GUID" SET DESCRIPTION ''k'';'
    + 'ALTER TABLE "RESULT" ALTER COLUMN "POS" SET DESCRIPTION ''h'';'
    + 'ALTER TABLE "RESULT" ALTER COLUMN "DOCID" SET DESCRIPTION ''h'';'
    + 'ALTER TABLE "RESULT" ALTER COLUMN "RESULTLINE" SET DESCRIPTION ''h'';'
    + 'ALTER TABLE "RESULT" ALTER COLUMN "INDEXDATA" SET DESCRIPTION ''h'';'
    + 'ALTER TABLE "RESULT" ALTER COLUMN "OBJECTLOADED" SET DESCRIPTION ''h'';'
    + 'create unique index "RESULT_PK" on "RESULT" ("ANFGUID" NULLS FIRST,"GUID" NULLS FIRST);';
    nxQuery1.ExecSQL;
  end;
  nxtbResult.Open();

  if not nxtbResObj.Exists then
  begin
//    nxtbResObj.CreateTable();
    nxQuery1.SQL.Text := ''
    + 'create table "RESULTOBJEKT"('
    + '"ANFGUID" VARCHAR(38),"RESULTGUID" VARCHAR(38),'
    + '"GUID" VARCHAR(38),"OBJEKTNAME" VARCHAR(255),'
    + '"OBJEKT" BLOB);'
//    + 'Alter table "RESULTOBJEKT" SET DESCRIPTION "Resultobjekte"; '
    + 'ALTER TABLE "RESULTOBJEKT" ALTER COLUMN "ANFGUID" SET DESCRIPTION ''o ==>RESULT.ANFGUID'';'
    + 'ALTER TABLE "RESULTOBJEKT" ALTER COLUMN "RESULTGUID" SET DESCRIPTION ''o ==>RESULT.GUID'';'
    + 'ALTER TABLE "RESULTOBJEKT" ALTER COLUMN "GUID" SET DESCRIPTION ''k'';'
    + 'ALTER TABLE "RESULTOBJEKT" ALTER COLUMN "OBJEKTNAME" SET DESCRIPTION ''h'';'
    + 'ALTER TABLE "RESULTOBJEKT" ALTER COLUMN "OBJEKT" SET DESCRIPTION ''h'';'
    + 'create unique index "RESULTOBJEKT_PK" on "RESULTOBJEKT" ("ANFGUID" NULLS FIRST,"RESULTGUID" NULLS FIRST,"GUID" NULLS FIRST);';
    nxQuery1.ExecSQL;
  end;
  nxtbResObj.Open();

  if not nxtbArchivePK.Exists then
  begin
    nxQuery1.SQL.Text := ''
    + 'create table "ARCHIVE"('
    + '"AR_GUID" VARCHAR(38),"AR_ID" VARCHAR(35),'
    + '"AR_BEZ" VARCHAR(255),"AR_DOKPATH" VARCHAR(255), '
    + '"AR_LTZLFDNR" INTEGER);'
//    + 'Alter table "ARCHIVE" SET DESCRIPTION '';'
    + 'ALTER TABLE "ARCHIVE" ALTER COLUMN "AR_GUID" SET DESCRIPTION ''k'';'
    + 'ALTER TABLE "ARCHIVE" ALTER COLUMN "AR_ID" SET DESCRIPTION ''h'';'
    + 'ALTER TABLE "ARCHIVE" ALTER COLUMN "AR_BEZ" SET DESCRIPTION ''h'';'
    + 'ALTER TABLE "ARCHIVE" ALTER COLUMN "AR_DOKPATH" SET DESCRIPTION ''h'';'
    + 'ALTER TABLE "ARCHIVE" ALTER COLUMN "AR_LTZLFDNR" SET DESCRIPTION ''h'';'
    + 'create unique index "ARCHIVE_INDID" on "ARCHIVE"("AR_ID" NULLS FIRST);'
    + 'create unique index "ARCHIVE_PK" on "ARCHIVE"("AR_GUID" NULLS FIRST);';
    nxQuery1.ExecSQL;
  end;
  nxtbArchivePK.Open();
  nxtbArchive.Open();
  nxtbArchiveID.Open();

  if not nxtbFields.Exists then
  begin
    nxQuery1.SQL.Text := ''
    + 'create table "FIELDS"('
    + '"CABINETID" VARCHAR(36),"INDEXNR" INTEGER,"FIELDNAME" VARCHAR(255),'
    + '"FIELDALIAS" VARCHAR(255), "FIELDTYPE" VARCHAR(64),'
    + '"SystemField" BOOLEAN);'
//    + 'Alter table "FIELDS" SET DESCRIPTION '';'
    + 'ALTER TABLE "FIELDS" ALTER COLUMN "CABINETID" SET DESCRIPTION ''k'';'
    + 'ALTER TABLE "FIELDS" ALTER COLUMN "INDEXNR" SET DESCRIPTION ''h'';'
    + 'ALTER TABLE "FIELDS" ALTER COLUMN "FIELDNAME" SET DESCRIPTION ''h'';'
    + 'ALTER TABLE "FIELDS" ALTER COLUMN "FIELDALIAS" SET DESCRIPTION ''h'';'
    + 'ALTER TABLE "FIELDS" ALTER COLUMN "FIELDTYPE" SET DESCRIPTION ''h'';'
    + 'ALTER TABLE "FIELDS" ALTER COLUMN "FIELDTYPE" SET DESCRIPTION ''h'';'
    + 'create unique index "FIELDS_PK" on "FIELDS"("CABINETID" NULLS FIRST,"INDEXNR" NULLS FIRST);'
    + 'create unique index "FIELDS_NAME" on "FIELDS"("CABINETID" NULLS FIRST,"FIELDNAME" NULLS FIRST);';
    nxQuery1.ExecSQL;
  end;
  nxtbFields.Open();
  nxtbFieldsPK.Open();
  nxtbFieldsName.Open();
end;

procedure Tdatabase.CloseRemoteDB();
begin
  // close Transport
  nxTrans.Close();
  // close Engine
  nxRmtSrvEng.Close();
end;

procedure Tdatabase.OpenLocalDB(Settings: TSettings);
//var
  //add: TStrings;
  //indexNames: TStrings;
begin
  // setup Engine
  nxLocSrvEng.TempStorePath := Settings.LocalDatabaseTempPath;
  // setup Session
  nxSe1.ServerEngine := nxLocSrvEng;
  // setup Transport
  nxListenTrans.ListenAddresses.Add(Settings.LocalDatabaseListenIp);
  nxListenTrans.Port := StrToInt(Settings.LocalDatabaseListenPort);
  nxListenTrans.ServerName := Settings.LocalDatabaseListenIp;
  // open sql Engine
  nxSQLEng.Open();
  // open Engine
  nxLocSrvEng.Open();
  // open Transport
  nxListenTrans.Open();
  // open Session
  nxSe1.UserName := Settings.LocalDatabaseUser;
  nxSe1.Password := Settings.LocalDatabasePassword;
  nxSe1.Open();
  // check if Session can see Database
  if not nxSe1.IsAlias(Settings.RemoteDatabaseAlias) then
    nxSe1.AddAlias(Settings.LocalDatabaseAlias, Settings.LocalDatabasePath, true);
  // setup Database
  nxDb1.AliasName := Settings.LocalDatabaseAlias;
  nxDb1.AliasPath := Settings.LocalDatabasePath;
  // open Database
  nxDb1.Open();

  // init indexNames
  //indexNames := TStrings.Create;

    openTables();
end;

procedure Tdatabase.CloseLocalDB();
begin
  // close Engine
  nxLocSrvEng.Close();
  // close Transport
  nxListenTrans.Close();
  // close command handler
  nxlocalCommandH.Close();
  // close sql Engine
  nxSQLEng.Close();
end;

// Guid Generator
function  Tdatabase.GetNewGuid() : string;
 var
  yGuid  : TGUID;
  yResult: HRESULT;

begin
 yResult := CreateGUID(yGuid);
 if yResult=S_OK
 then begin
  result := GuidToString(yGuid);
 end
 else begin
  result := GuidToString(yGuid);
 end; //if
end; //GetNewGuid

// Table specific procedures

procedure Tdatabase.nxtbAnforderungAfterInsert(DataSet: TDataSet);
begin
  nxtbAnforderungGUID.AsString := NewGuid; // NewGuid
  nxtbAnforderungERSTELLTVON.AsString := '';
  nxtbAnforderungERSTELLTAM.AsDateTime := Date() + Time();
  nxtbAnforderungSTATUS.AsString := C_STATANF; // C_STATANF
end;

procedure Tdatabase.nxtbAnforderungBeforeDelete(DataSet: TDataSet);
begin
  raise Exception.Create('Deleting not allowed here. DataSet: ' + DataSet.GetNamePath	);
end;

procedure Tdatabase.nxtbAnforderungPKAfterInsert(DataSet: TDataSet);
begin
  nxtbAnforderungPKGUID.AsString := NewGuid; // NewGuid
  nxtbAnforderungPKERSTELLTVON.AsString := '';
  nxtbAnforderungPKERSTELLTAM.AsDateTime := Date() + Time();
  nxtbAnforderungPKSTATUS.AsString := C_STATANF; // C_StatAnf
end;

procedure Tdatabase.ne(DataSet: TDataSet);
begin
  nxtbResult.First();
  while not nxtbResult.Eof do
    nxtbResult.Delete();
end;

procedure Tdatabase.nxtbResObjAfterInsert(DataSet: TDataSet);
begin
  nxtbResObjANFGUID.AsString := nxtbResultANFGUID.AsString;
  nxtbResObjRESULTGUID.AsString := nxtbResultGUID.AsString;
  nxtbResObjGUID.AsString := NewGuid; // NewGuid
end;

procedure Tdatabase.nxtbResultAfterInsert(DataSet: TDataSet);
begin
  nxtbResultANFGUID.AsString := nxtbAnforderungPKGUID.AsString;
  nxtbResultGUID.AsString := NewGuid; // NewGuid
  nxtbResultPOS.AsInteger := 0;
  nxtbResultDOCID.AsInteger := -1;
end;

procedure Tdatabase.nxtbResultBeforeDelete(DataSet: TDataSet);
begin
  nxtbResObj.First();
  while not nxtbResObj.Eof do
    nxtbResObj.Delete();
end;

end.
