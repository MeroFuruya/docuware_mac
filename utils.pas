unit utils;

interface

uses
  Winapi.Windows;

function ExpandEnvStr(const szInput: string): string;

implementation

function ExpandEnvStr(const szInput: string): string;
  const
    MAXSIZE = 32768;
  begin
    SetLength(Result,MAXSIZE);
    SetLength(Result,ExpandEnvironmentStrings(pchar(szInput),
      @Result[1],length(Result)) - 1);
  end;

end.