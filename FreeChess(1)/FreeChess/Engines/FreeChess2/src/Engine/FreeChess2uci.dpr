program FreeChess2uci;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Eval in 'Eval.pas',
  Hash in 'Hash.pas',
  Main in 'Main.pas',
  Moves in 'Moves.pas',
  Think in 'Think.pas',
  Vars in 'Vars.pas',
  Util in 'Util.pas',
  Iface in 'Iface.pas',
  History in 'History.pas',
  windows;

var cmd:string;
    res:byte;

begin
  randomize;
  ponder:=true;
  HashSizeMB:=1;
  init;  GetSTD;
  OpnTest:=LoadBook;
  readfen(startfen);
  //������� ����
  repeat
    //��������� �������
    Cmd:=Inp;
    //���� ���� �����
    if Cmd='' then continue;
    //������������ �������
    Res:=Protokol(Cmd);
    //���������, ����� �������� ���� ���������
    case Res of
    //���� ���� ������� �����
    0: break;
    end;
  until false;
end.
