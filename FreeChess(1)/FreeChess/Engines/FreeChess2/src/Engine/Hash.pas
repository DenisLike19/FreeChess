unit Hash;

//*********************************************
//* Copyright (C) 2005-2006 by Maklyakov Ivan *
//*********************************************

//Модуль для работы с хэш-таблицами

interface

uses SysUtils,Vars;

type
  TTrans = record
    Key:int64;
    Depth:byte;
    Score:TEval;
    MoveFrom,MoveTo:byte;
  end;

  TZobrist=array[0..12,1..64] of int64;

var
  Zobrist:TZobrist;
  BlackKey:int64;
  TransTable : array of TTrans;
  HashSize:integer;
  hFrom,hTo:byte;

procedure FillZobristTables;
function GetRandom:int64;
function GetPositionHash:int64;
function WhatPiese(Num:byte):byte;
procedure SaveToHash(blck:byte; depth:byte; score:TEval; MovFrom,MovTo:byte; ply:byte);
procedure ClearHash;

implementation

procedure FillZobristTables;
//Генерация зорбист-ключей
var i,k:byte;
begin
  BlackKey:=GetRandom;
  for i:=0 to 12 do
      for k:=1 to 64 do
        Zobrist[i,k]:=GetRandom;
end;

function GetRandom:int64;
//Генерация 64-х разрядного целого числа
var res:int64;
    i:byte;
    tmp:integer;
begin
  res:=0;
  for i:=1 to 4 do
  begin
    tmp:=random(65536);
    res:=res shl 16;
    res:=res or tmp;
  end;
  result:=res;
end;

function GetPositionHash:int64;
//Получаем хэш-ключ позиции
var res:int64;
    i:byte;
begin
  res:=0;
  for i:=1 to 64 do
    res:=res xor (Zobrist[WhatPiese(i),i]);
  Result:=res;
end;

function WhatPiese(Num:byte):byte;
//Какая фигура в данной клетке
var z,b:byte;
begin
  z:=Board[Num]; b:=0;
  if z>black then
  begin
    dec(z,black);
    b:=1;
  end;
  if z>ProhodR then dec(z,ProhodR);
  if z>ProhodL then dec(z,ProhodL);
  if z>IfMove then dec(z,IfMove);
  WhatPiese:=6*b+z;
end;

procedure SaveToHash(blck:byte; depth:byte; score:TEval; MovFrom,MovTo:byte; ply:byte);
//Сохраняем результаты в хэш
var ind:integer;
begin
  ind:=1+Abs(boardkey mod HashSize);
  if (TransTable[ind].depth<=depth) then
  begin
    TransTable[ind].key:=boardkey;
    TransTable[ind].depth:=depth;
    TransTable[ind].score:=score;
    TransTable[ind].MoveFrom:=MovFrom;
    TransTable[ind].MoveTo:=MovTo;
  end;
end;

procedure ClearHash;
//Очищаем хэш
var i:integer;
begin
  for i:=0 to HashSize+2 do
  begin
    TransTable[i].Key:=0;
    TransTable[i].Depth:=0;
    TransTable[i].Score:=0;
    TransTable[i].MoveFrom:=0;
    TransTable[i].MoveTo:=0;
  end;
end;

end.
