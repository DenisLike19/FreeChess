unit Moves;

//*********************************************
//* Copyright (C) 2005-2006 by Maklyakov Ivan *
//*********************************************

//Модуль, связанный с ходами

interface

uses Vars, Eval, Hash, History;

function GenMoves(blck:byte;all:boolean):TGen;
function Check(blck,where:byte):boolean;
procedure MakeMove(Move:TMo);
function SortMove(Moves:TGen;blck,ply:byte):TSortMove;
procedure QuickSortM(var a:TSortMove; Lo,Hi:integer);
function OpenLib:TMo;
procedure SavePV(blck:byte; depth:byte; score:TEval; PV:TLine);

implementation

function GenMoves(blck:byte;all:boolean):TGen;
//Генерация всех ходов или только взятий
var i,j,l,m,ll,rr,mm:integer;
    wh,q,qq,z,zz:integer;
    x,y,xx,yy:integer;
    a,b:boolean;
    tmp:TGen;
label m1;
begin
  tmp.NMove:=0;
  //В проверке учавствуют все фигуры =)
  for i:=1 to 16 do
  begin
    //Если фигура есть
    if Figs[blck,i].fig<>0 then
    begin
    //проверяем что за фигура и где она находится
    ll:=0; rr:=0; mm:=0;
    wh:=Figs[blck,i].where;
    x:=((wh-1) div 8)+1;
    y:=((wh-1) mod 8)+1;
    z:=Board[wh]-blck*black;
    if z>ProhodR then
    begin
      rr:=1;
      dec(z,ProhodR);
    end;
    if z>ProhodL then
    begin
      ll:=1;
      dec(z,ProhodL);
    end;
    if z>IfMove then
    begin
      mm:=1;
      dec(z,IfMove);
    end;
    //Если король, проверяем рокеровки
    if (z=1) and all then
      if mm=1 then
        begin
          a:=true; b:=true;
          if (Board[wh-4]-blck*black)>8 then
          begin
            for j:=1 to 3 do
              if Board[wh-j]<>0 then a:=false;
            if a then
              for j:=0 to 2 do
                if Check(blck,wh-j) then
                begin
                  b:=false;
                  break;
                end;
            if a and b then
            begin
              inc(tmp.NMove);
              tmp.Move[tmp.NMove].fromb:=wh;
              tmp.Move[tmp.NMove].tob:=wh-2;
              tmp.Move[tmp.NMove].flag1:=1;
              tmp.Move[tmp.NMove].flag2:=0;
              tmp.Move[tmp.NMove].flag3:=0;
              tmp.Move[tmp.NMove].isKill:=false;
            end;
          end;
          a:=true; b:=true;
          if (Board[wh+3]-blck*black)>8 then
          begin
            for j:=1 to 2 do
              if Board[wh+j]<>0 then a:=false;
            if a then
              for j:=0 to 2 do
                if Check(blck,wh+j) then
                begin
                  b:=false;
                  break;
                end;
            if a and b then
            begin
              inc(tmp.NMove);
              tmp.Move[tmp.NMove].fromb:=wh;
              tmp.Move[tmp.NMove].tob:=wh+2;
              tmp.Move[tmp.NMove].flag1:=2;
              tmp.Move[tmp.NMove].flag2:=0;
              tmp.Move[tmp.NMove].flag3:=0;
              tmp.Move[tmp.NMove].isKill:=false;
            end;
          end;
        end;
    //Для фигур    
    if (z>=1) and (z<=5) then
    begin
      //Проверяем, куда можно сходить
      for j:=1 to Movs.Number[z,0] do
          for m:=1 to Movs.Number[z,j] do
          begin
            //Новые координаты, и т.д....
            xx:=x+Movs.Moves[z,j,m].x;
            yy:=y+Movs.Moves[z,j,m].y;
            if (xx<1) or (xx>8) or (yy<1) or (yy>8) then break;
            zz:=(xx-1)*8+yy;
            //Че мы имеем там, куда надо бы идти =)
            q:=Board[zz];  qq:=0;
            if q>black then
            begin
              dec(q,black);
              qq:=1;
            end;
            q:=q and 7;
            //Если ниче нету, то ход
            if (q=0) and all then
            begin
              inc(tmp.NMove);
              tmp.Move[tmp.NMove].fromb:=wh;
              tmp.Move[tmp.NMove].tob:=zz;
              tmp.Move[tmp.NMove].flag1:=0;
              tmp.Move[tmp.NMove].flag2:=Board[wh];
              tmp.Move[tmp.NMove].flag3:=0;
              tmp.Move[tmp.NMove].isKill:=false;
            end;
            //Если свои, то прекращаем строить линию
            //(если конь или король то ниче не делаем)
            if (qq=blck) and (q<>0) then break;
            //Если вражина, то бьем нах!
            if (qq<>blck) and (q<>0) then
            begin
              inc(tmp.NMove);
              tmp.Move[tmp.NMove].fromb:=wh;
              tmp.Move[tmp.NMove].tob:=zz;
              tmp.Move[tmp.NMove].flag1:=3;
              tmp.Move[tmp.NMove].flag2:=Board[zz];
              tmp.Move[tmp.NMove].flag3:=0;
              tmp.Move[tmp.NMove].isKill:=true;
              break;
            end;
          end;
    end;
    //Ходы пешки
    if z=6 then
    begin
      //Сморим обычные ходы пешки
      //(на 2 клетки если пешка еще не дергалась)
      for j:=1 to 1+mm do
      begin
        yy:=y;
        if blck=1 then xx:=x-j else xx:=x+j;
        //Новая координата
        zz:=(xx-1)*8+yy;
        //Если че-то есть, сваливаем
        if Board[zz]<>0 then break;
        if (xx=1) or (xx=8) then
        begin
        //Если превращение, пишем чтоб проверял все фигуры, а не тока ферзя
          for l:=2 to 5 do
          begin
            inc(tmp.NMove);
            tmp.Move[tmp.NMove].fromb:=wh;
            tmp.Move[tmp.NMove].tob:=zz;
            tmp.Move[tmp.NMove].flag1:=6;
            tmp.Move[tmp.NMove].flag2:=l;
            tmp.Move[tmp.NMove].flag3:=0;
            tmp.Move[tmp.NMove].isKill:=true;
          end;
        end
        else if all then
        begin
        //Если не превращение, то просто ход
          inc(tmp.NMove);
          tmp.Move[tmp.NMove].fromb:=wh;
          tmp.Move[tmp.NMove].tob:=zz;
          tmp.Move[tmp.NMove].flag1:=0;
          tmp.Move[tmp.NMove].flag2:=Board[wh];
          tmp.Move[tmp.NMove].flag3:=0;
          tmp.Move[tmp.NMove].isKill:=false;
          if ((xx=2) and (blck=1)) or ((xx=7) and (blck=0)) then tmp.Move[tmp.NMove].flag3:=yy;
          if j=2 then tmp.Move[tmp.NMove].flag1:=4;
        end;
      end;
      //Тут смотрим взятия
      for l:=1 to 2 do
      begin
        if blck=1 then xx:=x-1 else xx:=x+1;
        yy:=y;
        if l=1 then dec(yy);
        if l=2 then inc(yy);
        if (yy<1) or (yy>8) then goto m1;
        //Новая координата
        zz:=(xx-1)*8+yy;
        //Че мы имеем в ней
        q:=Board[zz];  qq:=0;
        if q>black then
        begin
          dec(q,black);
          qq:=1;
        end;
        //Если че-то имеем
        if (qq<>blck) and (q<>0) then
        begin
          if (xx=1) or (xx=8) then
          begin
          //Смотрим, может не только долбанем фигуру,
          //Но и превратимся (но не только в ферзя :))
            for m:=2 to 5 do
            begin
              inc(tmp.NMove);
              tmp.Move[tmp.NMove].fromb:=wh;
              tmp.Move[tmp.NMove].tob:=zz;
              tmp.Move[tmp.NMove].flag1:=7;
              tmp.Move[tmp.NMove].flag2:=m;
              tmp.Move[tmp.NMove].flag3:=Board[zz];
              tmp.Move[tmp.NMove].isKill:=true;
            end;
          end
          else
          begin
          //Если не превратимся
            inc(tmp.NMove);
            tmp.Move[tmp.NMove].fromb:=wh;
            tmp.Move[tmp.NMove].tob:=zz;
            tmp.Move[tmp.NMove].flag1:=3;
            tmp.Move[tmp.NMove].flag2:=Board[zz];
            tmp.Move[tmp.NMove].flag3:=0;
            tmp.Move[tmp.NMove].isKill:=true;
            if ((xx=2) and (blck=1)) or ((xx=7) and (blck=0)) then tmp.Move[tmp.NMove].flag3:=yy;
          end;
        end;
        //Сморим взятия на проходе
        if (l=1) and (ll=1) then
        begin
          inc(tmp.NMove);
          tmp.Move[tmp.NMove].fromb:=wh;
          tmp.Move[tmp.NMove].tob:=zz;
          xx:=x;
          zz:=(xx-1)*8+yy;
          tmp.Move[tmp.NMove].flag1:=5;
          tmp.Move[tmp.NMove].flag2:=Board[zz];
          tmp.Move[tmp.NMove].flag3:=Board[wh];
          tmp.Move[tmp.NMove].isKill:=true;
        end;
        if (l=2) and (rr=1) then
        begin
          inc(tmp.NMove);
          tmp.Move[tmp.NMove].fromb:=wh;
          tmp.Move[tmp.NMove].tob:=zz;
          xx:=x;
          zz:=(xx-1)*8+yy;
          tmp.Move[tmp.NMove].flag1:=5;
          tmp.Move[tmp.NMove].flag2:=Board[zz];
          tmp.Move[tmp.NMove].flag3:=Board[wh];
          tmp.Move[tmp.NMove].isKill:=true;
        end;
m1:
      end;
    end;
    end;
  end;
  //Все
  GenMoves:=tmp;
end;

function Check(blck,where:byte):boolean;
//Детектор шахов (очень корявый, но какой есть, такой есть...)
var i,j,m:integer;
    wh,a,z,zz:integer;
    x,y,xx,yy:integer;
label m1;
begin
  //Идея такова:
  //Из клетки короля (или из другой клетки)
  //строим линии и смотрим, есть ли там соответствующая фигура
  Check:=false; wh:=where;
  if wh=0 then wh:=Figs[blck,1].where;
  x:=((wh-1) div 8)+1;
  y:=((wh-1) mod 8)+1;
  for i:=3 to 5 do
    for j:=1 to Movs.Number[i,0] do
    begin
        for m:=1 to Movs.Number[i,j] do
        begin
          xx:=x+Movs.Moves[i,j,m].x;
          yy:=y+Movs.Moves[i,j,m].y;
          if (xx<1) or (xx>8) or (yy<1) or (yy>8) then goto m1;
          zz:=(xx-1)*8+yy;
          z:=Board[zz];
          if z>Black then
          begin
            a:=1;
            dec(z,Black);
          end
          else a:=0;
          z:=z and 7;
          if (z<>0) and (a=blck) then goto m1;
          if (a<>blck) and (z=6) and (i=4) and (m=1) and (a=0) and (xx<x) then
          begin
            Check:=true;
            exit;
          end;
          if (a<>blck) and (z=6) and (i=4) and (m=1) and (a=1) and (xx>x) then
          begin
            Check:=true;
            exit;
          end;
          if (a<>blck) and (z=5) and (i=5) then
          begin
            Check:=true;
            exit;
          end;
          if (a<>blck) and (z=4) and (i=4) then
          begin
            Check:=true;
            exit;
          end;
          if (a<>blck) and (z=3) and (i=3) then
          begin
            Check:=true;
            exit;
          end;
          if (a<>blck) and (z=2) and (i=3) then
          begin
            Check:=true;
            exit;
          end;
          if (a<>blck) and (z=2) and (i=4) then
          begin
            Check:=true;
            exit;
          end;
          if (a<>blck) and (z=1) and (i=3) and (m=1) then
          begin
            Check:=true;
            exit;
          end;
          if (a<>blck) and (z=1) and (i=4) and (m=1) then
          begin
            Check:=true;
            exit;
          end;
          if z<>0 then goto m1;
        end;
m1:
    end;
end;

procedure MakeMove(Move:TMo);
//Выполнение хода на доске
var bl,z,i,k:integer;
    x,y:integer;
begin
  bl:=0;
  //Кем ходим
  z:=Board[Move.fromb];
  if z>black then
  begin
    dec(z,black);
    bl:=1;
  end;
  z:=z and 7;
  //Корректируем хэш-ключ
  BoardKey:=BoardKey xor Zobrist[z+6*bl,Move.tob];
  BoardKey:=BoardKey xor Zobrist[z+6*bl,Move.fromb];
  BoardKey:=BoardKey xor BlackKey;
  //Если было взятие на проходе.
  //(Точнее пешка выежнулась)
  if Proh[0]=1 then
  begin
    i:=1;
    while i<=64 do
    begin
      k:=Board[i]; y:=0;
      if k>black then
      begin
        y:=1;
        dec(k,black);
      end;
      k:=k and 15;
      if y=1 then Board[i]:=k+black;
      inc(i);
    end;
  end;
  if Proh[1]=1 then
  begin
    i:=1;
    while i<=64 do
    begin
      k:=Board[i]; y:=0;
      if k>black then
      begin
        y:=1;
        dec(k,black);
      end;
      k:=k and 15;
      if y=0 then Board[i]:=k;
      inc(i);
    end;
  end;
  if Proh[0]>0 then dec(Proh[0]);
  if Proh[1]>0 then dec(Proh[1]);
  //Проверяем че за ход
  case Move.flag1 of
  0:begin
      //Простой ход
      Board[Move.tob]:=z+black*bl;
      Board[Move.fromb]:=0;
      for i:=1 to 16 do
        if (Figs[bl,i].where=Move.fromb) and (Figs[bl,i].fig<>0) then
        begin
          Figs[bl,i].where:=Move.tob;
          break;
        end;
    end;
  1:begin
      //Рокеровка длинная
      Board[Move.fromb]:=0;
      Board[Move.tob-2]:=0;
      Board[Move.fromb-2]:=King+black*bl;
      Board[Move.fromb-1]:=Rook+black*bl;
      Figs[bl,1].where:=Move.fromb-2;
      for i:=3 to 4 do
        if (Figs[bl,i].where=(Move.tob-2)) and (Figs[bl,i].fig<>0) then Figs[bl,i].where:=Move.fromb-1;
    end;
  2:begin
      //Рокеровка короткая
      Board[Move.fromb]:=0;
      Board[Move.tob+1]:=0;
      Board[Move.fromb+2]:=King+black*bl;
      Board[Move.fromb+1]:=Rook+black*bl;
      Figs[bl,1].where:=Move.fromb+2;
      for i:=3 to 4 do
        if (Figs[bl,i].where=(Move.tob+1)) and (Figs[bl,i].fig<>0) then Figs[bl,i].where:=Move.fromb+1;
    end;
  3:begin
      //Простое взятие
      Board[Move.tob]:=z+black*bl;
      Board[Move.fromb]:=0;
      for i:=1 to 16 do
        if (Figs[bl,i].where=Move.fromb) and (Figs[bl,i].fig=z) then
        begin
          Figs[bl,i].where:=Move.tob;
          break;
        end;
      for i:=1 to 16 do
        if (Figs[1-bl,i].where=Move.tob) and (Figs[1-bl,i].fig<>0) then
        begin
          Figs[1-bl,i].fig:=0;
          break;
        end;
    end;
  4:begin
      //Пешка на 2 клетки вперед
      Board[Move.tob]:=z+black*bl;
      Board[Move.fromb]:=0;
      for i:=1 to 16 do
        if (Figs[bl,i].where=Move.fromb) and (Figs[bl,i].fig<>0) then
        begin
          Figs[bl,i].where:=Move.tob;
          break;
        end;
      x:=((Move.tob-1) div 8)+1;
      y:=((Move.tob-1) mod 8)+1;
      if y>1 then
      if Board[Move.tob-1]<>0 then
      begin
        z:=Board[Move.tob-1];
        i:=0;
        if z>black then
        begin
          i:=1;
          dec(z,black);
        end;
        if z>ProhodR then dec(z,ProhodR);
        if z>ProhodL then dec(z,ProhodL);
        if (z=6) and (i<>bl) then
        begin
          Proh[bl]:=2;
          inc(Board[Move.tob-1],ProhodR);
        end;
      end;
      if y<8 then
      if Board[Move.tob+1]<>0 then
      begin
        z:=Board[Move.tob+1];
        i:=0;
        if z>black then
        begin
          i:=1;
          dec(z,black);
        end;
        if z>ProhodR then dec(z,ProhodR);
        if z>ProhodL then dec(z,ProhodL);
        if (z=6) and (i<>bl) then
        begin
           Proh[bl]:=2;
           inc(Board[Move.tob+1],ProhodL);
        end;
      end;
    end;
  5:begin
      //Взятие на проходе
      x:=((Move.tob-1) div 8)+1;
      y:=((Move.tob-1) mod 8)+1;
      if bl=0 then x:=x-1 else x:=x+1;
      Board[Move.tob]:=z+black*bl;
      Board[Move.fromb]:=0;
      z:=(x-1)*8+y;
      Board[z]:=0;
      for i:=9 to 16 do
        if (Figs[bl,i].where=Move.fromb) and (Figs[bl,i].fig<>0) then
        begin
          Figs[bl,i].where:=Move.tob;
          break;
        end;
      for i:=9 to 16 do
        if (Figs[1-bl,i].where=z) and (Figs[1-bl,i].fig<>0) then
        begin
          Figs[1-bl,i].fig:=0;
          break;
        end;
    end;
  6:begin
      //Превращение
      Board[Move.tob]:=Move.flag2+black*bl;
      Board[Move.fromb]:=0;
      for i:=9 to 16 do
        if (Figs[bl,i].where=Move.fromb) and (Figs[bl,i].fig<>0) then
        begin
          Figs[bl,i].where:=Move.tob;
          Figs[bl,i].fig:=Move.flag2;
          break;
        end;
    end;
  7:begin
      //Превращение со взятием
      Board[Move.tob]:=Move.flag2+black*bl;
      Board[Move.fromb]:=0;
      for i:=9 to 16 do
        if (Figs[bl,i].where=Move.fromb) and (Figs[bl,i].fig<>0) then
        begin
          Figs[bl,i].where:=Move.tob;
          Figs[bl,i].fig:=Move.flag2;
          break;
        end;
      for i:=1 to 16 do
        if (Figs[1-bl,i].where=Move.tob) and (Figs[1-bl,i].fig<>0) then
        begin
          Figs[1-bl,i].fig:=0;
          break;
        end;
    end;
  end;
end;

function SortMove(Moves:TGen;blck,ply:byte):TSortMove;
//Сортировка обычных ходов
var i,x,z,zz:integer;
    e1,e2:integer;
    e:TEval;
    SK:TSortMove;
    q,qq:boolean;
begin
  if Moves.NMove=0 then exit;
  for i:=1 to Moves.NMove do
  begin
    SK[1,i]:=i; e:=0; qq:=true;
    if (Moves.Move[i].fromb=hFrom) and (Moves.Move[i].tob=hTo) then SK[2,i]:=-13*CQueen+Moves.Move[i].flag2
    else if Moves.Move[i].isKill then
    begin
      x:=Board[Moves.Move[i].fromb] and 7;
      e:=Price[x];
      if (Moves.Move[i].flag1=7) or (Moves.Move[i].flag1=6) then
      begin
        if (Moves.Move[i].flag1=7) then
        begin
          x:=Moves.Move[i].flag3 and 7;
          e:=e-Price[x];
        end;
        x:=Moves.Move[i].flag2;
      end;
      if (Moves.Move[i].flag1=5) then
      begin
        x:=6;
      end;
      if (Moves.Move[i].flag1=3) then
      begin
        x:=Moves.Move[i].flag2 and 7;
      end;
      dec(e,Price[x]);
      dec(e,(6-x)*cQueen);
      if Moves.Move[i].tob=lm.tob then dec(e,cQueen);
      SK[2,i]:=e-CQueen;
    end else
    begin
      z:=Moves.Move[i].fromb;
      zz:=Moves.Move[i].tob;
      if ((Killer[ply,1,1]=z) and (Killer[ply,1,2]=zz)) or ((Killer[ply,2,1]=z) and (Killer[ply,2,2]=zz)) then qq:=false;
{      else
      begin
        if (blck=0) then
          if (wHist[z,zz]<>0) then
          begin
            e:=-wHist[z,zz]+cQueen;
            qq:=false;
          end;
        if (blck=1) then
          if (bHist[z,zz]<>0) then
          begin
            e:=-bHist[z,zz]+cQueen;
            qq:=false;
          end;
      end;
}      if qq then
      begin
        x:=Board[z] and 7;
        if blck=0 then
        begin
          q:=Figs[1,2].Fig<>0;
          case x of
          1: if q then e1:=EKingBW[z] else e1:=EKingEW[z];
          2: e1:=EQueenW[z];
          3: e1:=ERookW[z];
          4: e1:=EBishopW[z];
          5: e1:=EKnightW[z];
          6: e1:=EPawnW[z];
          end;
          case x of
          1: if q then e2:=EKingBW[zz] else e2:=EKingEW[zz];
          2: e2:=EQueenW[zz];
          3: e2:=ERookW[zz];
          4: e2:=EBishopW[zz];
          5: e2:=EKnightW[zz];
          6: e2:=EPawnW[zz];
          end;
        end else
        begin
          q:=Figs[0,2].Fig<>0;
          case x of
          1: if q then e1:=EKingBB[z] else e1:=EKingEB[z];
          2: e1:=EQueenB[z];
          3: e1:=ERookB[z];
          4: e1:=EBishopB[z];
          5: e1:=EKnightB[z];
          6: e1:=EPawnB[z];
          end;
          case x of
          1: if q then e2:=EKingBB[zz] else e2:=EKingEB[zz];
          2: e2:=EQueenB[zz];
          3: e2:=ERookB[zz];
          4: e2:=EBishopB[zz];
          5: e2:=EKnightB[zz];
          6: e2:=EPawnB[zz];
          end;
        end;
        e:=e1-e2+CQueen*2;
      end;
      SK[2,i]:=e;
    end;
  end;
  QuickSortM(SK,1,Moves.NMove);
  SortMove:=SK;
end;

procedure QuickSortM(var a:TSortMove; Lo,Hi:integer);
//Куик сорт
procedure sort(l,r:integer);
var
  i,j,x,y:integer;
begin
  i:=l; j:=r; x:=a[2,(l+r) DIV 2];
  repeat
    while a[2,i]<x do i:=i+1;
    while x<a[2,j] do j:=j-1;
    if i<=j then
    begin
      y:=a[1,i]; a[1,i]:=a[1,j]; a[1,j]:=y;
      y:=a[2,i]; a[2,i]:=a[2,j]; a[2,j]:=y;
      i:=i+1; j:=j-1;
    end;
  until i>j;
  if l<j then sort(l,j);
  if i<r then sort(i,r);
end;
begin
  sort(Lo,Hi);
end;

function OpenLib:TMo;
//Берем ход из библиотеки (если есть конечно)
var i,i1,i2:integer;
    j,k:integer;
    hh:TMo;
begin
  i1:=0; i2:=0;
  if NHod=0 then
  begin
    i1:=1;
    i2:=Kopn;
  end else
    for i:=1 to Kopn do
    begin
      k:=0;
      for j:=1 to Open[i].Number do
        if (j<=Nhod) and (Open[i].Items[j].fromb=Game[j].mmm.fromb) and (Open[i].Items[j].tob=Game[j].mmm.tob) then inc(k) else break;
      if (k=Nhod) and (k<>Open[i].Number) and (i1=0) then i1:=i;
      if (i1<>0) and (k<>Nhod) then
      begin
        i2:=i-1;
        break;
      end;
    end;
  if i2=0 then i2:=Kopn;
  if i1=0 then Opn:=false
  else
  begin
    repeat
      i:=i1+random(i2-i1+1);
    until (Nhod<Open[i].Number);
    hh.fromb:=Open[i].Items[NHod+1].fromb;
    hh.tob:=Open[i].Items[NHod+1].tob;
    OpenLib:=hh;
  end;
end;

procedure SavePV(blck:byte; depth:byte; score:TEval; PV:TLine);
var ply:byte;
    ind:integer;
begin
  ply:=0;
  repeat
    inc(ply);
    ind:=1+Abs(boardkey mod HashSize);
    TransTable[ind].key:=boardkey;
    TransTable[ind].depth:=depth;
    TransTable[ind].score:=score;
    TransTable[ind].MoveFrom:=PV.line[ply].fromb;
    TransTable[ind].MoveTo:=PV.line[ply].tob;
    dec(depth);
    score:=-score;
    MakeMove(PV.line[ply]);
  until (depth=0) or (ply=PV.count);
end;

end.
