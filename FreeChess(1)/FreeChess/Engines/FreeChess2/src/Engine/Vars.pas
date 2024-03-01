unit Vars;

//*********************************************
//* Copyright (C) 2005-2006 by Maklyakov Ivan *
//*********************************************

//Модуль с переменными и типами

interface

uses IniFiles;

//--------------------------------------------------------------------------------

const
  ver='FreeChess v 2.16c';  //Версия
  
  startfen='rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';
  
  MaxDepth=50;              //Максимальная глубина

  Kopn=27032;               //Количество дебютов

  Pawn=6;                   //Пешка
  Knight=5;                 //Конь
  Bishop=4;                 //Слон
  Rook=3;                   //Ладья
  Queen=2;                  //Ферзь
  King=1;                   //Король

  IfMove=8;                 //Флаг: если фигура не дергалась еще

  ProhodL=32;               //Флаг: для взятия на проходе (слева)
  ProhodR=64;               //Флаг: для взятия на проходе (справа)

  Black=128;                //Флаг: черная фигура

  //Координаты
  Koord:array[1..64] of string[2]=
        ('a1','b1','c1','d1','e1','f1','g1','h1',
         'a2','b2','c2','d2','e2','f2','g2','h2',
         'a3','b3','c3','d3','e3','f3','g3','h3',
         'a4','b4','c4','d4','e4','f4','g4','h4',
         'a5','b5','c5','d5','e5','f5','g5','h5',
         'a6','b6','c6','d6','e6','f6','g6','h6',
         'a7','b7','c7','d7','e7','f7','g7','h7',
         'a8','b8','c8','d8','e8','f8','g8','h8');

  CPawn=100;        //Вес пешки
  Inf=200*CPawn;    //Вес бесконечности
  CKnight=CPawn*3;  //Вес коня
  CBishop=CPawn*3;  //Вес слона
  CRook=CPawn*5;    //ладьи
  CQueen=CPawn*9;   //ферзя
  CKing=inf;        //короля

  //То же, но в массиве
  Price:array[1..6] of 0..Inf=(CKing,CQueen,CRook,CBishop,CKnight,CPawn);

  //Фигуры так, как они идут в списке
  Figi:array[1..16] of byte=(1,2,3,3,4,4,5,5,6,6,6,6,6,6,6,6);

//--------------------------------------------------------------------------------

type
  //Тип доски
  TBoard=array[1..64] of byte;

  //Разность координат для генерации ходов
  TKoord=record
    x,y:-7..7;
  end;

  //Ход
  TMo=record
    fromb,tob,flag1,flag2,flag3:byte;
    isKill:boolean;
  end;

  //Ход в библиотеке
  TMopen=record
    fromb,tob:byte;
  end;

  //Линия PV
  TLine=record
    line:array[1..MaxDepth] of TMo;
    count:byte;
  end;

  //Список разностей координат для генерации ходов
  TMove=record
    Moves:array[1..5,1..8,1..7] of TKoord;
    Number:array[1..5,0..8] of 0..8;
  end;

  //Оценка
  TEval=longint;

  //Строка из библиотеки
  TOpn=record
    Number:byte;
    Items:array[1..50] of TMopen;
  end;

  //Библиотека
  TOpen=array[1..Kopn] of TOpn;

  //Фигура
  TFig=record
    Fig:byte;
    Where:byte;
  end;

  //Список фигур
  TFigu=array[0..1,1..16] of TFig;

  //Все ходы и взятия
  TGen=record
    Move:array[1..300] of TMo;
    NMove:byte;
  end;

  //Для сортировки
  TSortMove=array[1..2,1..300] of TEval;

  //При взятии на проходе
  TProh=array[0..1] of byte;

  //Сохранение всей игры
  TGame=record
    mmm:TMo;
  end;

  //Правила
  TRule=record
    //Глубина
    depth:byte;
    //Время на ход
    movetime:longint;
    //Параметры блица
    wtime,btime,winc,binc:longint;
    //Мат в N ходов
    mate:byte;
    //Бесконечно
    infinite:boolean;
    //... на N ходов
    movestogo:byte;
    //Столько позиций
    nodes:longint;
    //Ponder
    ponder:boolean;
  end;


//--------------------------------------------------------------------------------

var
  Board:TBoard;                   //Доска
  BoardKey:int64;                 //Ключ позиции
  Proh:TProh;                     //Взятия на проходе
  Open:TOpen;                     //Библиотека
  Opn,OpnTest:boolean;            //Для библиотеки
  Nhod:word;                      //№ текущего ходa
  Figs:TFigu;                     //Список вигур
  Movs:TMove;                     //Список разностей координат для генерации ходов
  Lin:TLine;                      //PV
  nodes,NPS:longint;              //Нодесы и НПС-ы
  Game:array[1..1024] of TGame;   //Сюда сохраняется игра
  RealDepth:byte;                 //Глубина перебора
  Otmena,Otm:boolean;             //Для отмены
  HashSizeMB:word;                //Размер хэша в мегабайтах
  ProvLine:array[0..MaxDepth] of int64;
  ProvHash:array[0..500] of int64;
  Rule50:byte;
  uci:boolean;
  ToMove:byte;
  Rules:TRule;
  StartTime,CurrTime:TDateTime;
  Tim,EndTim:longint;
  lm:TMo;
  lastres1,lastres2:integer;
  maxply:byte;
  ponder:boolean;
  woforce:boolean;

//--------------------------------------------------------------------------------

implementation

end.
