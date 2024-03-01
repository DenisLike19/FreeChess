unit Vars;

//*********************************************
//* Copyright (C) 2005-2006 by Maklyakov Ivan *
//*********************************************

//������ � ����������� � ������

interface

uses IniFiles;

//--------------------------------------------------------------------------------

const
  ver='FreeChess v 2.16c';  //������
  
  startfen='rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';
  
  MaxDepth=50;              //������������ �������

  Kopn=27032;               //���������� �������

  Pawn=6;                   //�����
  Knight=5;                 //����
  Bishop=4;                 //����
  Rook=3;                   //�����
  Queen=2;                  //�����
  King=1;                   //������

  IfMove=8;                 //����: ���� ������ �� ��������� ���

  ProhodL=32;               //����: ��� ������ �� ������� (�����)
  ProhodR=64;               //����: ��� ������ �� ������� (������)

  Black=128;                //����: ������ ������

  //����������
  Koord:array[1..64] of string[2]=
        ('a1','b1','c1','d1','e1','f1','g1','h1',
         'a2','b2','c2','d2','e2','f2','g2','h2',
         'a3','b3','c3','d3','e3','f3','g3','h3',
         'a4','b4','c4','d4','e4','f4','g4','h4',
         'a5','b5','c5','d5','e5','f5','g5','h5',
         'a6','b6','c6','d6','e6','f6','g6','h6',
         'a7','b7','c7','d7','e7','f7','g7','h7',
         'a8','b8','c8','d8','e8','f8','g8','h8');

  CPawn=100;        //��� �����
  Inf=200*CPawn;    //��� �������������
  CKnight=CPawn*3;  //��� ����
  CBishop=CPawn*3;  //��� �����
  CRook=CPawn*5;    //�����
  CQueen=CPawn*9;   //�����
  CKing=inf;        //������

  //�� ��, �� � �������
  Price:array[1..6] of 0..Inf=(CKing,CQueen,CRook,CBishop,CKnight,CPawn);

  //������ ���, ��� ��� ���� � ������
  Figi:array[1..16] of byte=(1,2,3,3,4,4,5,5,6,6,6,6,6,6,6,6);

//--------------------------------------------------------------------------------

type
  //��� �����
  TBoard=array[1..64] of byte;

  //�������� ��������� ��� ��������� �����
  TKoord=record
    x,y:-7..7;
  end;

  //���
  TMo=record
    fromb,tob,flag1,flag2,flag3:byte;
    isKill:boolean;
  end;

  //��� � ����������
  TMopen=record
    fromb,tob:byte;
  end;

  //����� PV
  TLine=record
    line:array[1..MaxDepth] of TMo;
    count:byte;
  end;

  //������ ��������� ��������� ��� ��������� �����
  TMove=record
    Moves:array[1..5,1..8,1..7] of TKoord;
    Number:array[1..5,0..8] of 0..8;
  end;

  //������
  TEval=longint;

  //������ �� ����������
  TOpn=record
    Number:byte;
    Items:array[1..50] of TMopen;
  end;

  //����������
  TOpen=array[1..Kopn] of TOpn;

  //������
  TFig=record
    Fig:byte;
    Where:byte;
  end;

  //������ �����
  TFigu=array[0..1,1..16] of TFig;

  //��� ���� � ������
  TGen=record
    Move:array[1..300] of TMo;
    NMove:byte;
  end;

  //��� ����������
  TSortMove=array[1..2,1..300] of TEval;

  //��� ������ �� �������
  TProh=array[0..1] of byte;

  //���������� ���� ����
  TGame=record
    mmm:TMo;
  end;

  //�������
  TRule=record
    //�������
    depth:byte;
    //����� �� ���
    movetime:longint;
    //��������� �����
    wtime,btime,winc,binc:longint;
    //��� � N �����
    mate:byte;
    //����������
    infinite:boolean;
    //... �� N �����
    movestogo:byte;
    //������� �������
    nodes:longint;
    //Ponder
    ponder:boolean;
  end;


//--------------------------------------------------------------------------------

var
  Board:TBoard;                   //�����
  BoardKey:int64;                 //���� �������
  Proh:TProh;                     //������ �� �������
  Open:TOpen;                     //����������
  Opn,OpnTest:boolean;            //��� ����������
  Nhod:word;                      //� �������� ���a
  Figs:TFigu;                     //������ �����
  Movs:TMove;                     //������ ��������� ��������� ��� ��������� �����
  Lin:TLine;                      //PV
  nodes,NPS:longint;              //������ � ���-�
  Game:array[1..1024] of TGame;   //���� ����������� ����
  RealDepth:byte;                 //������� ��������
  Otmena,Otm:boolean;             //��� ������
  HashSizeMB:word;                //������ ���� � ����������
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
