unit clientu;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TForm1 = class(TForm)
    m1: TMemo;
    Label1: TLabel;
    ip: TEdit;
    Label2: TLabel;
    port: TEdit;
    conn: TButton;
    Label3: TLabel;
    name: TEdit;
    ident: TButton;
    e1: TMemo;
    procedure identClick(Sender: TObject);
    procedure connClick(Sender: TObject);
    procedure e1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure e1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure m1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

uses sox;

var

  sc: cardinal;
  thh, thid, e: cardinal;
  s, k: string;
  fi: FLASHWINFO;

procedure flash;
begin
  fi.cbSize := sizeof( fi );
  fi.hwnd := application.handle;
  fi.uCount := 10;
  fi.dwFlags := FLASHW_ALL or FLASHW_TIMERNOFG;
  fi.dwTimeout := 0;
  flashwindowex( fi );
  application.title := '*** ! Új üzenet';
end;

procedure recvproc;
  begin
    repeat
      receivestr( sc, s );
      form1.m1.lines.add( '(' + timetostr( now ) + ') ' + s );
      if form1.handle <> getforegroundwindow then
        flash;
    until false;
  end;

procedure TForm1.identClick(Sender: TObject);
var

  pass: string;
begin
  pass := inputbox( 'Jelszó megadása', 'Kérem a jelszavát', '' );

end;

procedure TForm1.connClick(Sender: TObject);
begin
  initwsa;
  sc := createsocket;

  conn.enabled := false;
  try
    if connect( sc, ip.text, strtoint( port.text ) ) = 0 then begin
      thh := createthread( nil, 0, @recvproc, nil, 0, thid );
      sendstr( sc, 'NAME ' + name.text );
    end else begin
      messagedlg( 'Nem sikerült csatlakozni', mtError, [mbOk], 0 );
      conn.enabled := true;
    end;
  except
    messagedlg( 'Nem lehet csatlakozni!', mtError, [mbOk], 0 );
  end;

end;

procedure TForm1.e1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if key = VK_RETURN then begin
    k := e1.lines.strings[ e1.CaretPos.y ];
    if k = '' then exit;
    sendstr( sc, 'MESG ' + k );
    for e := 0 to e1.lines.count - 1 do begin
      if (e1.lines.strings[e] = '') and (e1.text <> '') then e1.lines.delete( e );
    end;
  end;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  disconnect( sc );
end;

procedure TForm1.e1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if key = VK_RETURN then begin
    for e := 0 to e1.lines.count - 1 do begin
      if e1.lines.strings[e] = '' then e1.lines.delete( e );
    end;
  end;
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
  application.title := 'Chat';
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  application.onactivate := FormActivate;
end;

procedure TForm1.m1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin

  if chr(key) in ['A'..'Z', 'a'..'z', '0'..'9'] then e1.text := e1.text + chr(key);
  e1.selstart := length( e1.text );
  e1.SetFocus;

end;

end.
