unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls;

type
  TForm_main = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    running: boolean;
  public
    { Public-Deklarationen }
  end;

var
  Form_main: TForm_main;

implementation

{$R *.dfm}

procedure TForm_main.Button1Click(Sender: TObject);
begin
  if not running then
  begin
    running := true;
    self.Button1.Caption := 'stop';
    while running do
    begin
      Application.ProcessMessages;
    end;
  end
  else
  begin
    running := false;
    self.Button1.Caption := 'start';
  end;
end;

procedure TForm_main.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  running := false;
end;

end.
