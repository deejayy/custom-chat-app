program ircclient;

uses
  Forms,
  clientu in 'clientu.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Chat client';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
