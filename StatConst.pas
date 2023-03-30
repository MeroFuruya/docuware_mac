unit StatConst;

interface
 Type
  TRequest= (reqUndef,
             reqSelect,           //F�hrt ein Select aus und ermittelt IndexDaten
             reqSelectFast,       //F�hrt ein Select aus ohne IndexDaten-Ermittlung
             reqSelectIndex,      //F�hrt ein Select aus und git die IndexDaten als FldNr=Value zur�ck
             reqGetObj,
             reqInsert,
             reqDelete,
             reqGetArchives,
             reqGetFieldList,     //Holt gesamte Feldliste Tennzeichen #13#10
             reqGetIndexField,    //Holt Feldliste in der Form Feldname=Index
             reqGetFieldIndex,
             reqGetFieldTypes,    //Holt Feldliste in der Form Feldname=Type
             reqGetFieldAlias,
             reqChgDokIndex       //�ndert den Index eines Dokumentes wobei 248,DokId der erste Indexeintrag sein mu�
            );

  TDWKSelectArt  = (dsaSelect, dsaSelectFAST, dsaSelectIndex);

  TreqIndAction  = (dreqIndAdd, dreqIndSel);

  TListEntrType  = (dletCrtName, dletExitName, dletValueList);

 Const
  C_STATANF        = 'ANF';
  C_STATOK         = 'OK';
  C_STATWAIT       = 'WAIT';
  C_STATREQWORK    = 'WORK';
  C_STATRMVREQ     = 'RMVREQ';
  C_STATERR        = 'ERROR';
  C_STATERR2       = 'NOARCHIVE';
  C_STATERR3       = 'ERROR2';
  C_REQERR1        = 'REQUESTNOTFOUND';
  C_REQERR2        = 'NOOBJEKTFOUND';
  C_NOERROR        = '';
  C_REQERR3        = 'NOTEMPPATH';
  C_REQERR4        = 'RESULTPOSNOTFOUND';
  C_REQERR5        = 'TIMELIMITOVERFLOW';
  C_LFDARTANF      = 'ANFORDERUNG';


 var
  reqSet_ArchiveMustExists: set of TRequest = [reqSelect, reqSelectFast, reqSelectIndex,
                                               reqGetObj, reqInsert, reqDelete,
                                               reqGetFieldList, reqGetIndexField,
                                               reqGetFieldIndex, reqGetFieldAlias,
                                               reqGetFieldTypes,reqChgDokIndex];

  function GetRequestString(pRequest:TRequest):string;
  function GetRequestFromString(pRequestString:string):TRequest;

implementation
  uses
    sysutils;

  function GetRequestString(pRequest:TRequest):string;
  begin
   case pRequest  of
    reqSelect       :  result:= 'SELECT';
    reqSelectFast   :  result:= 'SELECTFAST';
    reqSelectIndex  :  result:= 'SELECTINDEX';
    reqChgDokIndex  :  result:= 'CHHDOKINDEX';
    reqGetObj       :  result:= 'GETOBJ';
    reqInsert       :  result:= 'INSERT';
    reqDelete       :  result:= 'DELETE';
    reqGetArchives  :  result:= 'GETARCHIVES';
    reqGetFieldList :  result:= 'GETFIELDLIST';
    reqGetFieldTypes:  result:= 'GETFIELDTYPES';
    reqGetIndexField:  result:= 'GETINDEXFIELD';
    reqGetFieldIndex:  result:= 'GETFIELDINDEX';
    reqGetFieldAlias:  result:= 'GETFIELDALIAS';
   end;//case
  end;

  function GetRequestFromString(pRequestString:string):TRequest;
  begin
   pRequestString:=UpperCase(pRequestString);
   if      pRequestString='SELECT'        then result:= reqSelect
   else if pRequestString='SELECTFAST'    then result:= reqSelectFast
   else if pRequestString='SELECTINDEX'   then result:= reqSelectIndex
   else if pRequestString='GETOBJ'        then result:= reqGetObj
   else if pRequestString='INSERT'        then result:= reqInsert
   else if pRequestString='DELETE'        then result:= reqDelete
   else if pRequestString='GETARCHIVES'   then result:= reqGetArchives
   else if pRequestString='GETFIELDLIST'  then result:= reqGetFieldList
   else if pRequestString='GETFIELDTYPES' then result:= reqGetFieldTypes
   else if pRequestString='GETINDEXFIELD' then result:= reqGetIndexField
   else if pRequestString='GETFIELDINDEX' then result:= reqGetFieldIndex
   else if pRequestString='GETFIELDALIAS' then result:= reqGetFieldAlias
   else if pRequestString='CHHDOKINDEX'   then result:= reqChgDokIndex
   else result:= reqUNDEF;
  end;

end.

