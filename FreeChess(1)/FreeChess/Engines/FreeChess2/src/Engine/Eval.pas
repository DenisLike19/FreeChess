unit Eval;

//*********************************************
//* Copyright (C) 2005-2006 by Maklyakov Ivan *
//*********************************************

//Модуль оценки позиции

interface

uses Vars;

type Ev=array[1..64] of shortint;
     Pss=array[1..8] of byte;

const
//Статические таблицы
  EKingBW:Ev=  ( 30, 30, 20,-30,-20,-30, 30, 35,
                -10,-10,-20,-40,-40,-25, 0,  10,
                -40,-40,-40,-40,-40,-40,-40,-40,
                -40,-40,-40,-40,-40,-40,-40,-40,
                -40,-40,-40,-40,-40,-40,-40,-40,
                -40,-40,-40,-40,-40,-40,-40,-40,
                -40,-40,-40,-40,-40,-40,-40,-40,
                -40,-40,-40,-40,-40,-40,-40,-40);
  EKingEW:Ev=  (  0,  3,  6,  9,  9,  6,  3,  0,
                  3,  6,  9, 12, 12,  9,  6,  3,
                  6,  9, 12, 15, 15, 12,  9,  8,
                  9, 12, 15, 18, 18, 15, 12,  9,
                  9, 12, 15, 18, 18, 15, 12,  9,
                  6,  9, 12, 15, 15, 12,  9,  8,
                  3,  6,  9, 12, 12,  9,  6,  3,
                  0,  3,  6,  9,  9,  6,  3,  0);
  EQueenW:Ev=  (  0,  5,  8,  8,  8,  8,  5,  0,
                  0,  5, 10, 10, 10, 10,  5,  0,
                  0,  5, 10, 10, 10, 10,  5,  0,
                 -2, -5,  5, 15, 15,  5, -5, -2,
                 -5, -5,  5, 15, 15,  5, -5, -5,
                 -5, -5,  5, 15, 15,  5, -5, -5,
                -10, -5,  5,  5,  5,  5, -5,-10,
                -15, -5,  5,  5,  5,  5, -5,-15);
  ERookW:Ev=   (  2,  2,  5,  6,  6,  5,  2,  2,
                  1,  1,  2,  3,  3,  2,  1,  1,
                  1,  1,  1,  2,  2,  1,  1,  1,
                  1,  1,  1,  1,  1,  1,  1,  1,
                  1,  1,  1,  1,  1,  1,  1,  1,
                 10, 10, 10, 10, 10, 10, 10, 10,
                 30, 30, 30, 30, 30, 30, 30, 30,
                 15, 15, 15, 15, 15, 15, 15, 15);
  EBishopW:Ev= (  0,-13,-13, -5, -5,-13,-13,  0,
                -10,  6,  0,  0,  0,  0,  6,-10,
                 -5,  0,  5,  0,  0,  5,  0, -5,
                 -5,  0,  5, 10, 10,  5,  0, -5,
                 -5,  0,  5, 10, 10,  5,  0, -5,
                  0,  0,  7,  0,  0,  7,  0,  0,
                -10,  5,  0,  0,  0,  0,  5,-10,
                  0,-10, -5, -5, -5, -5, -5,  0);
  EKnightW:Ev= (-45,-14, -8, -8, -8, -8,-14,-45,
                -15,  0,  0,  0,  0,  0,  0,-15,
                -15,  0,  2,  1,  1,  2,  0,-15,
                -15,  0,  7,  7,  7,  7,  0,-15,
                -15,  2, 15, 16, 16, 15,  2,-15,
                  0,  5, 19, 24, 24, 19,  5,  0,
                -30,  5,  8,  8,  8,  8,  5,-30,
                -45,  0,  0,  0,  0,  0,  0,-45);
  EPawnW:Ev=   (  0,  0,  0,  0,  0,  0,  0,  0,
                  0,  3,  6,-15,-15,  6,  3,  0,
                  1,  4,  8,  0,  0,  8,  4,  1,
                  2,  5, 10, 13, 13, 10,  5,  2,
                  3,  6, 12, 15, 15, 12,  6,  3,
                 10, 12, 15, 20, 20, 15, 12, 10,
                 15, 18, 26, 30, 30, 26, 18, 15,
                 99, 99, 99, 99, 99, 99, 99, 99);


  EKingBB:Ev=  (-40,-40,-40,-40,-40,-40,-40,-40,
                -40,-40,-40,-40,-40,-40,-40,-40,
                -40,-40,-40,-40,-40,-40,-40,-40,
                -40,-40,-40,-40,-40,-40,-40,-40,
                -40,-40,-40,-40,-40,-40,-40,-40,
                -40,-40,-40,-40,-40,-40,-40,-40,
                -10,-10,-20,-40,-40,-25, 0,  10,
                 30, 30, 20,-30,-20,-30, 30, 35);
  EKingEB:Ev=  (  0,  3,  6,  9,  9,  6,  3,  0,
                  3,  6,  9, 12, 12,  9,  6,  3,
                  6,  9, 12, 15, 15, 12,  9,  8,
                  9, 12, 15, 18, 18, 15, 12,  9,
                  9, 12, 15, 18, 18, 15, 12,  9,
                  6,  9, 12, 15, 15, 12,  9,  8,
                  3,  6,  9, 12, 12,  9,  6,  3,
                  0,  3,  6,  9,  9,  6,  3,  0);
  EQueenB:Ev=  (-15, -5,  5,  5,  5,  5, -5,-15,
                -10, -5,  5,  5,  5,  5, -5,-10,
                 -5, -5,  5, 15, 15,  5, -5, -5,
                 -5, -5,  5, 15, 15,  5, -5, -5,
                 -2, -5,  5, 15, 15,  5, -5, -2,
                  0,  5, 10, 10, 10, 10,  5,  0,
                  0,  5, 10, 10, 10, 10,  5,  0,
                  0,  5,  8,  8,  8,  8,  5,  0);
  ERookB:Ev=   ( 15, 15, 15, 15, 15, 15, 15, 15,
                 30, 30, 30, 30, 30, 30, 30, 30,
                 10, 10, 10, 10, 10, 10, 10, 10,
                  1,  1,  1,  1,  1,  1,  1,  1,
                  1,  1,  1,  1,  1,  1,  1,  1,
                  1,  1,  1,  2,  2,  1,  1,  1,
                  1,  1,  2,  3,  3,  2,  1,  1,
                  2,  2,  5,  6,  6,  5,  2,  2);
  EBishopB:Ev= (  0,-10, -5, -5, -5, -5, -5,  0,
                -10,  5,  0,  0,  0,  0,  5,-10,
                  0,  0,  7,  0,  0,  7,  0,  0,
                 -5,  0,  5, 10, 10,  5,  0, -5,
                 -5,  0,  5, 10, 10,  5,  0, -5,
                 -5,  0,  5,  0,  0,  5,  0, -5,
                -10,  6,  0,  0,  0,  0,  6,-10,
                  0,-13,-13, -5, -5,-13,-13,  0);
  EKnightB:Ev= (-45,  0,  0,  0,  0,  0,  0,-45,
                -30,  5,  8,  8,  8,  8,  5,-30,
                  0,  5, 19, 24, 24, 19,  5,  0,
                -15,  2, 15, 16, 16, 15,  2,-15,
                -15,  0,  7,  7,  7,  7,  0,-15,
                -15,  0,  2,  1,  1,  2,  0,-15,
                -15,  0,  0,  0,  0,  0,  0,-15,
                -45,-14, -8, -8, -8, -8,-14,-45);
  EPawnB:Ev=   ( 99, 99, 99, 99, 99, 99, 99, 99,
                 15, 18, 26, 30, 30, 26, 18, 15,
                 10, 12, 15, 20, 20, 15, 12, 10,
                  3,  6, 12, 15, 15, 12,  6,  3,
                  2,  5, 10, 13, 13, 10,  5,  2,
                  1,  4,  8,  0,  0,  8,  4,  1,
                  0,  3,  6,-15,-15,  6,  3,  0,
                  0,  0,  0,  0,  0,  0,  0,  0);

  BadKnight=10;   //(-) Неразвитые кони
  BadBishop=13;   //(-) Неразвитые слоны
  TwoBishops=20;  //(+) Два слона
  TwoPawns=8;     //(-) Две пешки на одной вертикали
  AlonePawn=12;   //(-) Одинокая пешка
  QueenKo=5;      //(-) Коэффициент расстояния от короля до ферзя
  KingKo=10;      //(+) Коэффициент расстояния между королями (чтобы ставить мат)
  Pass:Pss=(0,10,20,30,
     40,50,80,0); //(+) За проходную пешку

function Evalution(blck:byte):TEval;
function MatEval(blck:byte):TEval;

implementation

function Evalution(blck:byte):TEval;
//Функция оценки
var Eva:longint;
    Q:boolean;
    i,w,f:byte;
    fi:byte;
    x,y,xx,yy:shortint;
    BlPVert,BlPV:array[0..9]of byte;
    WhPVert,WhPV:array[0..9]of byte;
begin
  Eva:=0;
  //Обнуляем пешечные массивы:
  //сколько пешек на каждой вертикали
  //и наивысшая пешка на вертикали
  for i:=0 to 9 do
  begin
    BlPVert[i]:=0;
    WhPVert[i]:=0;
    BlPV[i]:=9;
    WhPV[i]:=0;
  end;
  //Для белых:
  //Есть ли ферзь врага
  q:=Figs[1,2].Fig<>0; fi:=0;
  //Если есть, то считаем расстояние от короля до него
  //и вычитаем из оценки
  if q then
  begin
    x:=((Figs[1,2].where-1) div 8)+1;
    y:=((Figs[1,2].where-1) mod 8)+1;
    xx:=((Figs[0,1].where-1) div 8)+1;
    yy:=((Figs[0,1].where-1) mod 8)+1;
    x:=x-xx;
    y:=y-yy;
    dec(Eva,(14-abs(x)-abs(y))*QueenKo);
  end;
  //Обрабатываем все фигуры
  for i:=1 to 16 do
  begin
    w:=Figs[0,i].where; f:=Figs[0,i].fig;
    //Штраф за неразвитого слона
    if ((i=5) or (i=6)) and ((w=3) or (w=6)) then dec(Eva,BadBishop);
    //Штраф за неразвитого коня
    if ((i=7) or (i=8)) and ((w=2) or (w=7)) then dec(Eva,BadKnight);
    //Если фигура существует
    if f<>0 then
    begin
      //Добавляем материал
      inc(Eva,Price[f]);
      inc(fi);
      //Если пешка, пополняем пешечный массив
      if f=6 then
      begin
        inc(WhPVert[((w-1) mod 8)+1]);
        if ((w-1) div 8)+1>WhPV[((w-1) mod 8)+1] then WhPV[((w-1) mod 8)+1]:=((w-1) div 8)+1;
      end;
    end;
    case f of
    //Добавляем к оценке значение из статической таблицы
    1: if q then inc(Eva,EKingBW[w]) else inc(Eva,EKingEW[w]);
    2: inc(Eva,EQueenW[w]);
    3: inc(Eva,ERookW[w]);
    4: inc(Eva,EBishopW[w]);
    5: inc(Eva,EKnightW[w]);
    6: inc(Eva,EPawnW[w]);
    end;
  end;
  //Анализируем пешечную структуру
  //Тупо, но хотя бы что-то...
  for i:=1 to 8 do
  begin
    if WhPVert[i]>1 then dec(Eva,TwoPawns*WhPVert[i]);
    if (WhPVert[i]<>0) and (WhPVert[i-1]=0) and (WhPVert[i+1]=0) then dec(Eva,AlonePawn*WhPVert[i]);
  end;
  //Бонус за разнопольных слонов
  if (Figs[0,5].fig<>0) and (Figs[0,6].fig<>0) then inc(Eva,TwoBishops);
  //Если одинокий король, то считаем расстояние между королями
  //и вычитаем из оценки
  if fi=1 then
  begin
    x:=((Figs[1,1].where-1) div 8)+1;
    y:=((Figs[1,1].where-1) mod 8)+1;
    xx:=((Figs[0,1].where-1) div 8)+1;
    yy:=((Figs[0,1].where-1) mod 8)+1;
    x:=x-xx;
    y:=y-yy;
    dec(Eva,(14-abs(x)-abs(y))*KingKo);
  end;
  //Аналогичные действия, но для черной стороны
  q:=Figs[0,2].Fig<>0; fi:=0;
  if q then
  begin
    x:=((Figs[0,2].where-1) div 8)+1;
    y:=((Figs[0,2].where-1) mod 8)+1;
    xx:=((Figs[1,1].where-1) div 8)+1;
    yy:=((Figs[1,1].where-1) mod 8)+1;
    x:=x-xx;
    y:=y-yy;
    inc(Eva,(14-abs(x)-abs(y))*QueenKo);
  end;
  for i:=1 to 16 do
  begin
    w:=Figs[1,i].where; f:=Figs[1,i].fig;
    if ((i=5) or (i=6)) and ((w=62) or (w=59)) then inc(Eva,BadBishop);
    if ((i=7) or (i=8)) and ((w=63) or (w=58)) then inc(Eva,BadKnight);
    if f<>0 then
    begin
      dec(Eva,Price[f]);
      inc(fi);
      if f=6 then
      begin
        inc(BlPVert[((w-1) mod 8)+1]);
        if ((w-1) div 8)+1<BlPV[((w-1) mod 8)+1] then BlPV[((w-1) mod 8)+1]:=((w-1) div 8)+1;
      end;
    end;
    case f of
    1: if q then dec(Eva,EKingBB[w]) else dec(Eva,EKingEB[w]);
    2: dec(Eva,EQueenB[w]);
    3: dec(Eva,ERookB[w]);
    4: dec(Eva,EBishopB[w]);
    5: dec(Eva,EKnightB[w]);
    6: dec(Eva,EPawnB[w]);
    end;
  end;
  for i:=1 to 8 do
  begin
    if BlPVert[i]>1 then inc(Eva,TwoPawns*BlPVert[i]);
    if (BlPVert[i]<>0) and (BlPVert[i-1]=0) and (BlPVert[i+1]=0) then inc(Eva,AlonePawn*BlPVert[i]);
    //Оценка проходных пешек
    if (BlPVert[i]<>0) and ((WhPVert[i-1]=0) or (WhPV[i-1]>=BlPV[i])) and ((WhPVert[i+1]=0) or (WhPV[i+1]>=BlPV[i])) then dec(Eva,Pass[9-BlPV[i]]);
    if (WhPVert[i]<>0) and ((BlPVert[i-1]=0) or (BlPV[i-1]<=WhPV[i])) and ((BlPVert[i+1]=0) or (BlPV[i+1]<=WhPV[i])) then inc(Eva,Pass[WhPV[i]]);
  end;
  if (Figs[1,5].fig<>0) and (Figs[1,6].fig<>0) then dec(Eva,TwoBishops);
  if fi=1 then
  begin
    x:=((Figs[1,1].where-1) div 8)+1;
    y:=((Figs[1,1].where-1) mod 8)+1;
    xx:=((Figs[0,1].where-1) div 8)+1;
    yy:=((Figs[0,1].where-1) mod 8)+1;
    x:=x-xx;
    y:=y-yy;
    inc(Eva,(14-abs(x)-abs(y))*KingKo);
  end;
  //Поправляем оценку, если значение вышло за пределы
  //Х.З. бывает ли такое, но на всякий случай :)
  if Eva>inf then eva:=inf;
  if Eva<-inf then eva:=-inf;
  //Оценка
  if blck=0 then Evalution:=Eva else Evalution:=-Eva;
end;

function MatEval(blck:byte):TEval;
//Функция считает материал
var Eva:TEval;
    i:integer;
begin
  Eva:=0;
  for i:=1 to 16 do
  begin
    if Figs[0,i].Fig<>0 then inc(Eva,Price[Figs[0,i].Fig]);
    if Figs[1,i].Fig<>0 then dec(Eva,Price[Figs[1,i].Fig]);
  end;
  if blck=0 then MatEval:=Eva else MatEval:=-Eva;
end;

end.
