unit task;

interface

uses
  System.SysUtils;

type
  TTask = record
    guid: string;
    command: string;
    archive: string;
    archiveId: string;
    selection: string;
    error: string;
    class function Create(guid, command, archive, selection: string): TTask; static;
  end;

implementation

{ TTask }

class function TTask.Create(guid, command, archive, selection: string): TTask;
begin
  Result.guid := guid.ToLower;
  Result.command := command.ToLower;
  Result.archive := ExtractFileName(archive).ToLower;
  Result.selection := selection.ToLower;
end;

end.