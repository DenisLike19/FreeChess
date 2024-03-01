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
  //Главный цикл
  repeat
    //Считывыем команду
    Cmd:=Inp;
    //Если было пусто
    if Cmd='' then continue;
    //Обрабатываем команду
    Res:=Protokol(Cmd);
    //Проверяем, какое действие надо выполнить
    case Res of
    //Если была команда Выход
    0: break;
    end;
  until false;
end.
