program ircserv;

uses
  Forms,
  ircu in 'ircu.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Relay';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
