unit ircu;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Registry, ScktComp, StdCtrls;

type
  TForm1 = class(TForm)
    ss: TServerSocket;
    start: TButton;
    stop: TButton;
    m: TMemo;
    stup: TCheckBox;
    ued: TEdit;
    Label1: TLabel;
    Button1: TButton;
    procedure ssClientConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure startClick(Sender: TObject);
    procedure stopClick(Sender: TObject);
    procedure ssClientDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure ssClientError(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure ssAccept(Sender: TObject; Socket: TCustomWinSocket);
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure recv(Sender: TObject; Socket: TCustomWinSocket);
    procedure stupClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure refreshservice;
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

uses md5, sox;

const

  deflog        = './log.txt';
  chlog         = './channel.txt';
  pwfile        = './info.dat';
  prefix        = '* ';

  run           : array[false..true] of string = ( 'stopped', 'running...' );

type

  crec  = record
    name        : string;
    ip          : string;
    pass        : string;
    sup         : boolean;
    port        : integer;
    socket      : integer;
  end;

var

  clients: array of crec;

procedure log( s: string );
var

  f: textfile;
begin
  assignfile( f, deflog );
  if not fileexists( deflog ) then rewrite( f ) else append( f );
  writeln( f, '[' + datetimetostr( now ) + '] ' + s );
  closefile( f );
end;

procedure clog( s: string );
var

  f: textfile;
begin
  assignfile( f, chlog );
  if not fileexists( chlog ) then rewrite( f ) else append( f );
  writeln( f, '[' + datetimetostr( now ) + '] ' + s );
  closefile( f );
end;

function crapspaces( s: string ): string;
begin
  result := s;
  while s[1] = ' ' do delete( s, 1, 1 );
  while s[length(s)] = ' ' do delete( s, length(s), 1 );
  result := s;
end;

function chomp( s: string ): string;
var

  e: integer;
begin
  result := s;
  for e := 1 to length( s ) do begin
    if (s[e] = #$0A) or (s[e] = #$0D) then s[e] := #$20;
  end;
  result := s;
end;

function checkpass( user, pass: string ): boolean;
var

  f: textfile;
  s, password: string;
begin
  result := false;
  if user = '' then exit;
  assignfile( f, pwfile );
  if not fileexists( pwfile ) then exit;
  password := MD5DigestToStr( MD5String( pass ) );
  reset( f );
  while not eof( f ) do begin
    readln( f, s );
    if (copy( s, 1, pos( ':', s ) - 1 ) = user) and (copy( s, pos( ':', s ) + 1, 255 ) = password) then result := true;
  end;
  closefile( f );
  if not result then
    log( '|W| Login failed: ' + user )
  else
    log( '|I| Logged in: ' + user )
end;

function changepass( user, pass, newpass: string ): boolean;
var

  f, g: textfile;
  s, op, np: string;
  i, e: integer;
begin
  log( '|I| Changing password for user "' + user + '"' );
  result := false;
  if user = '' then exit;
  assignfile( f, pwfile );
  assignfile( g, pwfile + '.new' );
  e := 0; op := MD5DigestToStr( MD5String( pass ) ); np := MD5DigestToStr( MD5String( newpass ) );
  if fileexists( pwfile ) then begin
    reset( f );
    rewrite( g );
    while eof( f ) do begin
      readln( f, s );
      if (copy( s, 1, pos( ':', s ) - 1 ) = user) and (copy( s, pos( ':', s ) + 1, 255 ) = op) then result := true;
      if not result then writeln( g, s ) else
        writeln( g, user + ':' + np );
    end;
    closefile( f );
    if not result then
      writeln( g, user + ':' + np );
    result := true;
    closefile( g );

    rename( f, pwfile + '.old' );
    rename( g, pwfile );
  end else begin
    rewrite( f );
    writeln( f, user + ':' + np );
    closefile( f );
  end;
  if result then
    log( '|I| Changed password for user "' + user + '"' )
  else
    log( '|W| Password change failed! (' + user + ')' )
end;














function clientbysocket( sid: integer ): crec;
var

  e: integer;
begin
  result.port := 0;
  for e := 0 to high( clients ) do
    if clients[e].socket = sid then result := clients[e]; 
end;

function clientbyname( name: string ): crec;
var

  e: integer;
begin
  result.port := 0;
  for e := 0 to high( clients ) do
    if clients[e].name = name then result := clients[e];
end;

function clientnumber( client: crec ): integer;
var

  e: integer;
begin
  result := -1;
  for e := 0 to high( clients ) do
    if clients[e].socket = client.socket then result := e;
end;

function getsup: crec;
var

  e: integer;
begin
  result.port := 0;
  for e := 0 to high( clients ) do
    if clients[e].sup then result := clients[e];
end;

procedure addclient( client: crec );
begin
  setlength( clients, high( clients ) + 2 );
  clients[ high( clients ) ] := client;
end;

procedure delclient( client: crec );
var

  e: integer;
begin
  for e := clientnumber( client ) + 1 to high( clients ) do
    clients[e-1] := clients[e];
  setlength( clients, high( clients ) );
end;

procedure broadcastm( s: string );
var

  e: integer;
begin
  for e := 0 to high( clients ) do
    sendstr( clients[e].socket, s + #10 );
  form1.m.lines.add( s );
end;








procedure TForm1.refreshservice;
begin
  start.enabled := not ss.active;
  stop.enabled := ss.active;
  form1.caption := 'Relay is ' + run[ss.active];
  application.title := form1.caption;
end;

procedure TForm1.startClick(Sender: TObject);
begin
  log( '|I| -> Server STARTING...' );
  ss.Active := true;
  if ss.Active then log( '|I|    Server STARTED' );

  refreshservice;
end;

procedure TForm1.stopClick(Sender: TObject);
begin
  log( '|I| <- Server STOPPING...' );
  ss.Active := false;
  log( '|I|    Server STOPPED' );

  refreshservice;
end;

procedure TForm1.ssClientConnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  log( '|I| Client connect: ' + socket.RemoteAddress + ':' + inttostr( socket.RemotePort ) );
  socket.Accept( socket.SocketHandle );
end;

procedure TForm1.ssClientDisconnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  log( '|I| Client disconnect: ' + socket.RemoteAddress + ':' + inttostr( socket.RemotePort ) );
  delclient( clients[ clientnumber( clientbysocket( socket.sockethandle ) ) ] );
end;

procedure TForm1.ssClientError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  log( '|E| Client ERROR: ' + socket.RemoteAddress + ':' + inttostr( socket.RemotePort ) );
  case errorevent of
    eeGeneral   : log( '   ^->   GENERAL (' + inttostr( errorcode ) + ')' );
    eeSend      : log( '   ^->   SEND (' + inttostr( errorcode ) + ')' );
    eeReceive   : log( '   ^->   RECIVE (' + inttostr( errorcode ) + ')' );
    eeConnect   : log( '   ^->   CONNECT (' + inttostr( errorcode ) + ')' );
    eeDisconnect: log( '   ^->   DISCONNECT (' + inttostr( errorcode ) + ')' );
    eeAccept    : log( '   ^->   ACCEPT (' + inttostr( errorcode ) + ')' );
  end;
  broadcastm( prefix + clientbysocket( socket.sockethandle ).name + ' kilépett' );
  errorcode := 0;
end;

procedure TForm1.ssAccept(Sender: TObject; Socket: TCustomWinSocket);
var

  cl: crec;
begin
  log( '|I| Connection accepted: ' + socket.RemoteAddress + ':' + inttostr( socket.RemotePort ) );

  cl.ip := socket.remoteaddress;
  cl.port := socket.remoteport;
  cl.socket := socket.SocketHandle;
  cl.sup := false;

  addclient( cl );
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
  refreshservice;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  refreshservice;
end;

procedure TForm1.FormPaint(Sender: TObject);
begin
  refreshservice;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if stop.enabled then stopClick( sender );
  log( '|I| Program exit' );
end;

procedure TForm1.FormCreate(Sender: TObject);
var

  reg : tregistry;
begin
  log( '|I| Program started' );

  reg := tregistry.create;
  reg.closekey;
  reg.openkey( 'Software\Microsoft\Windows\CurrentVersion\Run', true );
  stup.checked := reg.valueexists( 'irc' );
  reg.free;
end;

procedure TForm1.recv(Sender: TObject; Socket: TCustomWinSocket);
var

  msg, outstr: string;
begin
  msg := socket.ReceiveText;
  clog( clientbysocket( socket.sockethandle ).name + '@' + clientbysocket( socket.sockethandle ).ip + ' #root :' + msg );
  outstr := crapspaces( chomp( copy( msg, 6, 255 ) ) );

  if (pos( 'NAME', msg ) = 1) and (outstr <> '') then begin
    if clientbysocket( socket.sockethandle ).name <> '' then
      broadcastm( prefix + clientbysocket( socket.sockethandle ).name + ' neve ezentúl már ' + outstr )
    else
      broadcastm( prefix + outstr + ' bekapcsolódott a beszélgetésbe' );
    clients[ clientnumber( clientbysocket( socket.sockethandle ) ) ].name := outstr;
  end;
  if (pos( 'PASS', msg ) = 1) and (outstr <> '') then begin
    if checkpass( clientbysocket( socket.sockethandle ).name, outstr ) then begin
       clients[ clientnumber( clientbysocket( socket.sockethandle ) ) ].sup := true;
       broadcastm( prefix + clientbysocket( socket.sockethandle ).name + ' egy adminisztrátor' );
    end;
  end;
  if (pos( 'MESG', msg ) = 1) and (clientbysocket( socket.sockethandle ).name <> '') then begin
    if clientbysocket( socket.sockethandle ).sup then
      outstr := '[@' + clientbysocket( socket.sockethandle ).name + '] ' + outstr
    else
      outstr := '[' + clientbysocket( socket.sockethandle ).name + '] ' + outstr;
    broadcastm( outstr );
  end;
  if (pos( 'PWCH', msg ) = 1) and (clientbysocket( socket.sockethandle ).name <> '') then begin
    changepass( clientbysocket( socket.sockethandle ).name, copy( outstr, 1, pos( ' ', outstr ) - 1 ), copy( outstr, pos( ' ', outstr ) + 1, 255 ) );
  end;
  if (pos( 'LIST', msg ) = 1) then begin
  end;
  
end;

procedure TForm1.stupClick(Sender: TObject);
var

  reg : tregistry;
begin
  reg := tregistry.create;
  reg.closekey;
  reg.openkey( 'Software\Microsoft\Windows\CurrentVersion\Run', true );
  if stup.checked then
    reg.writestring( 'irc', paramstr( 0 ) )
  else
    reg.deletevalue( 'irc' );
  reg.free;
end;

procedure TForm1.Button1Click(Sender: TObject);
var

  op, np: string;
begin
  op := inputbox( 'Jelszó megadása', 'Kérem ' + ued.text + ' RÉGI jelszavát (ha nincs, akkor üres)', '' );
  np := inputbox( 'Jelszó megadása', 'Kérem ' + ued.text + ' ÚJ jelszavát', '' );
  if np <> '' then changepass( ued.text, op, np );
end;

end.
