unit main;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.DateUtils,
  System.StrUtils,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  funcs;

type
  TForm_main = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    running: boolean;
    funcs: Tfuncs;
  public
    procedure log(msg: string);
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
    self.funcs.init;
    while running do
    begin
      Application.ProcessMessages;
      self.funcs.execute;
    end;
    self.funcs.deinit;
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

procedure TForm_main.FormCreate(Sender: TObject);
begin
  self.funcs := Tfuncs.Create;
end;

procedure TForm_main.FormDestroy(Sender: TObject);
begin
  self.funcs.Free;
end;

procedure TForm_main.log(msg: string);
begin
  self.Memo1.Lines.Add('[' + Now.ToISO8601() + '] - ' + msg + sLineBreak);
end;

end.