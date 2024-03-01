unit Util;

//****************************************
//* Copyright (C) 2006 by Maklyakov Ivan *
//****************************************

//Модуль с различными вещами :)

interface

uses Vars,Sysutils,Windows;

var GHandleOut:Cardinal;
//    f:textfile;

procedure GetSTD;
procedure LPrint(msgs:string);
function Inp:string;
function Inpt:string;
function SubStr(var Cmd:string; ch:char):string;
procedure NewRule;
function CheckReps(ply:byte):boolean;

implementation

//Процедура однократного подхвата потока для вывода в стандартный OutPut
procedure GetSTD;
begin
  gHandleout:=getstdhandle(std_output_handle);
{  assignfile(f,'iolog.txt');
  rewrite(f);
  writeln(f,ver);
  writeln(f,'Input/Output log');
  closefile(f);}
end;

//Печать на стандартный output
procedure LPrint(msgs:string);
var x1:Pchar;
    len:Cardinal;
begin
{  assignfile(f,'iolog.txt');
  Append(f);
  writeln(f,'--> ',msgs);
  closefile(f);}
  len:=length(msgs);
  x1:=pchar(msgs + #10);
  _lwrite(gHandleout,x1,len+1);
end;

//Считываем команду из output
function Inp:string;
var res:string;
begin
  Inp:='';
  readln(res);
  if res='' then exit;
{  assignfile(f,'iolog.txt');
  Append(f);
  writeln(f,'<-- ',res);
  closefile(f);}
  Inp:=res;
end;

function Inpt:string;
var res:string;
    c:char;
begin
  Inpt:='';
  read(Input,c);
  if c='' then exit;
  res:=c;
{  assignfile(f,'iolog.txt');
  Append(f);
  writeln(f,'<-- ',res);
  closefile(f);}
  Inpt:=res;
end;

//Функция выделяет первую команду, отделенную символом
function SubStr(var Cmd:string; ch:char):string;
var sc:string;
    i:integer;
begin
  //Результат сначала пустой
  sc:='';
  //Обнуляем счетчик
  i:=0;
  //Цикл
  repeat
    //Увеличиваем счетчик
    inc(i);
    //Добавляем символ
    if Cmd[i]<>ch then sc:=sc+Cmd[i];
  //Выходим из цикла если конец или данный символ
  until (i=length(Cmd)) or (Cmd[i]=ch);
  //Обрезаем данную строку
  Cmd:=copy(Cmd,i+1,length(Cmd)-i);
  //Результат
  SubStr:=sc;
end;

procedure NewRule;
begin
  Rules.depth:=0;
  Rules.movetime:=0;
  Rules.wtime:=0;
  Rules.btime:=0;
  Rules.winc:=0;
  Rules.binc:=0;
  Rules.mate:=0;
  Rules.infinite:=false;
  Rules.movestogo:=0;
  Rules.nodes:=0;
  Rules.ponder:=false;
end;

function CheckReps(ply:byte):boolean;
var i,pos:integer;
begin
  pos:=0;
  if ply>3 then
  begin
    i:=ply-2;
    while i>0 do
    begin
      if ProvLine[i]=BoardKey then inc(pos);
      if pos=2 then
      begin
        Result:=true;
        exit;
      end;
      dec(i);
    end;
  end;
  i:=Rule50;
  while i>0 do
  begin
    if ProvHash[i]=BoardKey then inc(pos);
    if pos=2 then
    begin
      Result:=true;
      exit;
    end;
    dec(i);
  end;
  Result:=false;
end;

end.
