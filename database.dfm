object Database: TDatabase
  Height = 480
  Width = 640
  object nxseAllEngines1: TnxseAllEngines
    Left = 32
    Top = 8
  end
  object nxListenTrans: TnxWinsockTransport
    DisplayCategory = 'Transports'
    CommandHandler = nxlocalCommandH
    Mode = nxtmListen
    ServerNameRuntime = '127.0.0.1'
    ServerNameDesigntime = '127.0.0.1'
    Left = 32
    Top = 64
  end
  object nxLocSrvEng: TnxServerEngine
    SqlEngine = nxSqlEng
    ServerName = ''
    Options = []
    TableExtension = 'nx1'
    Left = 208
    Top = 64
  end
  object nxSqlEng: TnxSqlEngine
    ActiveDesigntime = True
    StmtLogging = False
    StmtLogTableName = 'QueryLog'
    UseFieldCache = False
    Left = 296
    Top = 224
  end
  object nxTrans: TnxWinsockTransport
    DisplayCategory = 'Transports'
    ActiveDesigntime = True
    ServerNameDesigntime = '127.0.0.1'
    Left = 32
    Top = 136
  end
  object nxSe1: TnxSession
    ActiveDesigntime = True
    ServerEngine = nxRmtSrvEng
    Left = 32
    Top = 224
  end
  object nxDb1: TnxDatabase
    ActiveDesigntime = True
    Session = nxSe1
    AliasPath = 'D:\databases\Docuware'
    Left = 120
    Top = 224
  end
  object nxtbAnforderung: TnxTable
    Database = nxDb1
    AfterInsert = nxtbAnforderungAfterInsert
    BeforeDelete = nxtbAnforderungBeforeDelete
    TableName = 'ANFORDERUNG'
    IndexName = 'ANFORDERUNG_INDSTAT'
    Left = 32
    Top = 320
    object nxtbAnforderungGUID: TnxStringField
      FieldName = 'GUID'
      Size = 38
    end
    object nxtbAnforderungSTATUS: TnxStringField
      FieldName = 'STATUS'
      Size = 15
    end
    object nxtbAnforderungCOMMAND: TnxStringField
      FieldName = 'COMMAND'
      Size = 15
    end
    object nxtbAnforderungDELFLG: TnxStringField
      FieldName = 'DELFLG'
      Size = 1
    end
    object nxtbAnforderungARCHIVE: TnxStringField
      FieldName = 'ARCHIVE'
      Size = 255
    end
    object nxtbAnforderungSELECTION: TnxStringField
      FieldName = 'SELECTION'
      Size = 255
    end
    object nxtbAnforderungRESULTHEADER: TnxStringField
      FieldName = 'RESULTHEADER'
      Size = 1024
    end
    object nxtbAnforderungERSTELLTVON: TnxStringField
      FieldName = 'ERSTELLTVON'
      Size = 30
    end
    object nxtbAnforderungERSTELLTAM: TDateTimeField
      FieldName = 'ERSTELLTAM'
    end
  end
  object nxtbResult: TnxTable
    Database = nxDb1
    AfterInsert = nxtbResultAfterInsert
    BeforeDelete = nxtbResultBeforeDelete
    TableName = 'RESULT'
    IndexFieldNames = 'ANFGUID'
    MasterFields = 'GUID'
    MasterSource = dtsAnforderungPK
    Left = 32
    Top = 384
    object nxtbResultANFGUID: TnxStringField
      FieldName = 'ANFGUID'
      Size = 38
    end
    object nxtbResultGUID: TnxStringField
      FieldName = 'GUID'
      Size = 38
    end
    object nxtbResultPOS: TIntegerField
      FieldName = 'POS'
    end
    object nxtbResultDOCID: TIntegerField
      FieldName = 'DOCID'
    end
    object nxtbResultRESULTLINE: TnxStringField
      FieldName = 'RESULTLINE'
      Size = 2024
    end
    object nxtbResultINDEXDATA: TnxStringField
      FieldName = 'INDEXDATA'
      Size = 2024
    end
    object nxtbResultOBJECTLOADED: TIntegerField
      FieldName = 'OBJECTLOADED'
    end
  end
  object nxtbAnforderungPK: TnxTable
    Database = nxDb1
    AfterInsert = nxtbAnforderungPKAfterInsert
    BeforeDelete = ne
    TableName = 'ANFORDERUNG'
    IndexName = 'ANFORDERUNG_PK'
    Left = 208
    Top = 320
    object nxtbAnforderungPKGUID: TnxStringField
      FieldName = 'GUID'
      Size = 38
    end
    object nxtbAnforderungPKSTATUS: TnxStringField
      FieldName = 'STATUS'
      Size = 15
    end
    object nxtbAnforderungPKCOMMAND: TnxStringField
      FieldName = 'COMMAND'
      Size = 15
    end
    object nxtbAnforderungPKDELFLG: TnxStringField
      FieldName = 'DELFLG'
      Size = 1
    end
    object nxtbAnforderungPKARCHIVE: TnxStringField
      FieldName = 'ARCHIVE'
      Size = 255
    end
    object nxtbAnforderungPKSELECTION: TnxStringField
      FieldName = 'SELECTION'
      Size = 255
    end
    object nxtbAnforderungPKRESULTHEADER: TnxStringField
      FieldName = 'RESULTHEADER'
      Size = 1024
    end
    object nxtbAnforderungPKERSTELLTVON: TnxStringField
      FieldName = 'ERSTELLTVON'
      Size = 30
    end
    object nxtbAnforderungPKERSTELLTAM: TDateTimeField
      FieldName = 'ERSTELLTAM'
    end
  end
  object nxtbResObj: TnxTable
    Database = nxDb1
    AfterInsert = nxtbResObjAfterInsert
    TableName = 'RESULTOBJEKT'
    IndexName = 'RESULTOBJEKT_PK'
    MasterFields = 'ANFGUID;GUID'
    MasterSource = dtsResult
    Left = 208
    Top = 384
    object nxtbResObjANFGUID: TnxStringField
      FieldName = 'ANFGUID'
      Size = 38
    end
    object nxtbResObjRESULTGUID: TnxStringField
      FieldName = 'RESULTGUID'
      Size = 38
    end
    object nxtbResObjGUID: TnxStringField
      FieldName = 'GUID'
      Size = 38
    end
    object nxtbResObjOBJEKTNAME: TnxStringField
      FieldName = 'OBJEKTNAME'
      Size = 255
    end
    object nxtbResObjOBJEKT: TBlobField
      FieldName = 'OBJEKT'
    end
  end
  object dtsAnforderung: TDataSource
    DataSet = nxtbAnforderung
    Left = 120
    Top = 320
  end
  object dtsResult: TDataSource
    DataSet = nxtbResult
    Left = 120
    Top = 384
  end
  object dtsAnforderungPK: TDataSource
    DataSet = nxtbAnforderungPK
    Left = 296
    Top = 320
  end
  object dtsResObj: TDataSource
    DataSet = nxtbResObj
    Left = 296
    Top = 384
  end
  object nxQuery1: TnxQuery
    Database = nxDb1
    Left = 208
    Top = 224
  end
  object nxlocalCommandH: TnxServerCommandHandler
    ServerEngine = nxLocSrvEng
    Left = 120
    Top = 64
  end
  object nxRmtSrvEng: TnxRemoteServerEngine
    ActiveDesigntime = True
    Transport = nxTrans
    Left = 120
    Top = 136
  end
  object nxtbArchivePK: TnxTable
    Database = nxDb1
    TableName = 'ARCHIVE'
    IndexName = 'ARCHIVE_PK'
    Left = 488
    Top = 32
    object nxtbArchivePKAR_GUID: TnxStringField
      FieldName = 'AR_GUID'
      Size = 38
    end
    object nxtbArchivePKAR_ID: TnxStringField
      FieldName = 'AR_ID'
      Size = 35
    end
    object nxtbArchivePKAR_BEZ: TnxStringField
      FieldName = 'AR_BEZ'
      Size = 255
    end
    object nxtbArchivePKAR_DOKPATH: TnxStringField
      FieldName = 'AR_DOKPATH'
      Size = 255
    end
    object nxtbArchivePKAR_LTZLFDNR: TIntegerField
      FieldName = 'AR_LTZLFDNR'
    end
  end
  object dtsArchivePK: TDataSource
    DataSet = nxtbArchivePK
    Left = 560
    Top = 32
  end
  object nxtbArchive: TnxTable
    Database = nxDb1
    TableName = 'ARCHIVE'
    IndexName = 'Sequential Access Index'
    Left = 488
    Top = 96
    object nxtbArchiveAR_GUID: TnxStringField
      FieldName = 'AR_GUID'
      Size = 38
    end
    object nxtbArchiveAR_ID: TnxStringField
      FieldName = 'AR_ID'
      Size = 35
    end
    object nxtbArchiveAR_BEZ: TnxStringField
      FieldName = 'AR_BEZ'
      Size = 255
    end
    object nxtbArchiveAR_DOKPATH: TnxStringField
      FieldName = 'AR_DOKPATH'
      Size = 255
    end
    object nxtbArchiveAR_LTZLFDNR: TIntegerField
      FieldName = 'AR_LTZLFDNR'
    end
  end
  object dtsArchive: TDataSource
    DataSet = nxtbArchive
    Left = 560
    Top = 96
  end
  object nxtbArchiveID: TnxTable
    Database = nxDb1
    TableName = 'ARCHIVE'
    IndexName = 'ARCHIVE_INDID'
    Left = 488
    Top = 152
    object nxtbArchiveIDAR_GUID: TnxStringField
      FieldName = 'AR_GUID'
      Size = 38
    end
    object nxtbArchiveIDAR_ID: TnxStringField
      FieldName = 'AR_ID'
      Size = 35
    end
    object nxtbArchiveIDAR_BEZ: TnxStringField
      FieldName = 'AR_BEZ'
      Size = 255
    end
    object nxtbArchiveIDAR_DOKPATH: TnxStringField
      FieldName = 'AR_DOKPATH'
      Size = 255
    end
    object nxtbArchiveIDAR_LTZLFDNR: TIntegerField
      FieldName = 'AR_LTZLFDNR'
    end
  end
  object dtaArchiveID: TDataSource
    DataSet = nxtbArchiveID
    Left = 560
    Top = 152
  end
  object nxtbFields: TnxTable
    Database = nxDb1
    TableName = 'FIELDS'
    IndexName = 'Sequential Access Index'
    Left = 488
    Top = 224
    object nxtbFieldsCABINETID: TnxStringField
      FieldName = 'CABINETID'
      Size = 36
    end
    object nxtbFieldsINDEXNR: TIntegerField
      FieldName = 'INDEXNR'
    end
    object nxtbFieldsFIELDNAME: TnxStringField
      FieldName = 'FIELDNAME'
      Size = 255
    end
    object nxtbFieldsFIELDALIAS: TnxStringField
      FieldName = 'FIELDALIAS'
      Size = 255
    end
    object nxtbFieldsFIELDTYPE: TnxStringField
      FieldName = 'FIELDTYPE'
      Size = 64
    end
    object nxtbFieldsSystemField: TBooleanField
      FieldName = 'SystemField'
    end
  end
  object dtsFields: TDataSource
    DataSet = nxtbFields
    Left = 560
    Top = 224
  end
  object nxtbFieldsPK: TnxTable
    Database = nxDb1
    TableName = 'FIELDS'
    IndexName = 'FIELDS_PK'
    Left = 488
    Top = 280
    object nxtbFieldsPKCABINETID: TnxStringField
      FieldName = 'CABINETID'
      Size = 36
    end
    object nxtbFieldsPKINDEXNR: TIntegerField
      FieldName = 'INDEXNR'
    end
    object nxtbFieldsPKFIELDNAME: TnxStringField
      FieldName = 'FIELDNAME'
      Size = 255
    end
    object nxtbFieldsPKFIELDALIAS: TnxStringField
      FieldName = 'FIELDALIAS'
      Size = 255
    end
    object nxtbFieldsPKFIELDTYPE: TnxStringField
      FieldName = 'FIELDTYPE'
      Size = 64
    end
    object nxtbFieldsPKSystemField: TBooleanField
      FieldName = 'SystemField'
    end
  end
  object dtsFieldPK: TDataSource
    DataSet = nxtbFieldsPK
    Left = 560
    Top = 280
  end
  object dtsFieldsName: TDataSource
    DataSet = nxtbFieldsName
    Left = 560
    Top = 344
  end
  object nxtbFieldsName: TnxTable
    Database = nxDb1
    TableName = 'FIELDS'
    IndexName = 'FIELDS_NAME'
    Left = 488
    Top = 344
    object nxtbFieldsNameCABINETID: TnxStringField
      FieldName = 'CABINETID'
      Size = 36
    end
    object nxtbFieldsNameINDEXNR: TIntegerField
      FieldName = 'INDEXNR'
    end
    object nxtbFieldsNameFIELDNAME: TnxStringField
      FieldName = 'FIELDNAME'
      Size = 255
    end
    object nxtbFieldsNameFIELDALIAS: TnxStringField
      FieldName = 'FIELDALIAS'
      Size = 255
    end
    object nxtbFieldsNameFIELDTYPE: TnxStringField
      FieldName = 'FIELDTYPE'
      Size = 64
    end
    object nxtbFieldsNameSystemField: TBooleanField
      FieldName = 'SystemField'
    end
  end
end
