unit Main;

//*********************************************
//* Copyright (C) 2005-2006 by Maklyakov Ivan *
//*********************************************

//Модуль со всякой нужной фигней :)

interface

uses Sysutils,Vars,Hash,Util;

procedure init;
function LoadBook:boolean;
procedure FillMoves;
procedure readfen(fen:string);

implementation

procedure readfen(fen:string);
var pos,sp:string;
    k1,k2:boolean;
    i,j,x,y:integer;
begin
  if fen=startfen then Opn:=OpnTest;
  Proh[0]:=0; k1:=false;
  Proh[1]:=0; k2:=false;
  for i:=1 to 64 do
    Board[i]:=0;
  for x:=0 to 1 do
    for y:=1 to 16 do
      Figs[x,y].Fig:=0;
  pos:=substr(fen,' ');
  for x:=7 downto 0 do
  begin
    y:=0;
    sp:=substr(pos,'/');
    for i:=1 to length(sp) do
    begin
      case sp[i] of
      '1'..'9': inc(y,ord(sp[i])-ord('1'));
      'k': begin
             Board[1+((x shl 3) or y)]:=King+Black;
             Figs[1,1].Fig:=King;
             Figs[1,1].Where:=1+((x shl 3) or y);
           end;
      'K': begin
             Board[1+((x shl 3) or y)]:=King;
             Figs[0,1].Fig:=King;
             Figs[0,1].Where:=1+((x shl 3) or y);
           end;
      'q': begin
             Board[1+((x shl 3) or y)]:=Queen+Black;
             if Figs[1,2].Fig=0 then
             begin
               Figs[1,2].Fig:=Queen;
               Figs[1,2].Where:=1+((x shl 3) or y);
             end else
             begin
               for j:=9 to 16 do
                 if Figs[1,j].Fig=0 then
                 begin
                   Figs[1,j].Fig:=Queen;
                   Figs[1,j].Where:=1+((x shl 3) or y);
                   break;
                 end;
             end;
           end;
      'Q': begin
             Board[1+((x shl 3) or y)]:=Queen;
             if Figs[0,2].Fig=0 then
             begin
               Figs[0,2].Fig:=Queen;
               Figs[0,2].Where:=1+((x shl 3) or y);
             end else
             begin
               for j:=9 to 16 do
                 if Figs[0,j].Fig=0 then
                 begin
                   Figs[0,j].Fig:=Queen;
                   Figs[0,j].Where:=1+((x shl 3) or y);
                   break;
                 end;
             end;
           end;
      'r': begin
             Board[1+((x shl 3) or y)]:=Rook+Black;
             if Figs[1,3].Fig=0 then
             begin
               Figs[1,3].Fig:=Rook;
               Figs[1,3].Where:=1+((x shl 3) or y);
             end else
             begin
               if Figs[1,4].Fig=0 then
               begin
                 Figs[1,4].Fig:=Rook;
                 Figs[1,4].Where:=1+((x shl 3) or y);
               end else
               begin
                 for j:=9 to 16 do
                   if Figs[1,j].Fig=0 then
                   begin
                     Figs[1,j].Fig:=Rook;
                     Figs[1,j].Where:=1+((x shl 3) or y);
                     break;
                   end;
               end;
             end;
           end;
      'R': begin
             Board[1+((x shl 3) or y)]:=Rook;
             if Figs[0,3].Fig=0 then
             begin
               Figs[0,3].Fig:=Rook;
               Figs[0,3].Where:=1+((x shl 3) or y);
             end else
             begin
               if Figs[0,4].Fig=0 then
               begin
                 Figs[0,4].Fig:=Rook;
                 Figs[0,4].Where:=1+((x shl 3) or y);
               end else
               begin
                 for j:=9 to 16 do
                   if Figs[0,j].Fig=0 then
                   begin
                     Figs[0,j].Fig:=Rook;
                     Figs[0,j].Where:=1+((x shl 3) or y);
                     break;
                   end;
               end;
             end;
           end;
      'b': begin
             Board[1+((x shl 3) or y)]:=Bishop+Black;
             if Figs[1,5].Fig=0 then
             begin
               Figs[1,5].Fig:=Bishop;
               Figs[1,5].Where:=1+((x shl 3) or y);
             end else
             begin
               if Figs[1,6].Fig=0 then
               begin
                 Figs[1,6].Fig:=Bishop;
                 Figs[1,6].Where:=1+((x shl 3) or y);
               end else
               begin
                 for j:=9 to 16 do
                   if Figs[1,j].Fig=0 then
                   begin
                     Figs[1,j].Fig:=Bishop;
                     Figs[1,j].Where:=1+((x shl 3) or y);
                     break;
                   end;
               end;
             end;
           end;
      'B': begin
             Board[1+((x shl 3) or y)]:=Bishop;
             if Figs[0,5].Fig=0 then
             begin
               Figs[0,5].Fig:=Bishop;
               Figs[0,5].Where:=1+((x shl 3) or y);
             end else
             begin
               if Figs[0,6].Fig=0 then
               begin
                 Figs[0,6].Fig:=Bishop;
                 Figs[0,6].Where:=1+((x shl 3) or y);
               end else
               begin
                 for j:=9 to 16 do
                   if Figs[0,j].Fig=0 then
                   begin
                     Figs[0,j].Fig:=Bishop;
                     Figs[0,j].Where:=1+((x shl 3) or y);
                     break;
                   end;
               end;
             end;
           end;
      'n': begin
             Board[1+((x shl 3) or y)]:=Knight+Black;
             if Figs[1,7].Fig=0 then
             begin
               Figs[1,7].Fig:=Knight;
               Figs[1,7].Where:=1+((x shl 3) or y);
             end else
             begin
               if Figs[1,8].Fig=0 then
               begin
                 Figs[1,8].Fig:=Knight;
                 Figs[1,8].Where:=1+((x shl 3) or y);
               end else
               begin
                 for j:=9 to 16 do
                   if Figs[1,j].Fig=0 then
                   begin
                     Figs[1,j].Fig:=Knight;
                     Figs[1,j].Where:=1+((x shl 3) or y);
                     break;
                   end;
               end;
             end;
           end;
      'N': begin
             Board[1+((x shl 3) or y)]:=Knight;
             if Figs[0,7].Fig=0 then
             begin
               Figs[0,7].Fig:=Knight;
               Figs[0,7].Where:=1+((x shl 3) or y);
             end else
             begin
               if Figs[0,8].Fig=0 then
               begin
                 Figs[0,8].Fig:=Knight;
                 Figs[0,8].Where:=1+((x shl 3) or y);
               end else
               begin
                 for j:=9 to 16 do
                   if Figs[0,j].Fig=0 then
                   begin
                     Figs[0,j].Fig:=Knight;
                     Figs[0,j].Where:=1+((x shl 3) or y);
                     break;
                   end;
               end;
             end;
           end;
      'p': begin
             Board[1+((x shl 3) or y)]:=Pawn+Black;
             if x=6 then inc(Board[1+((x shl 3) or y)],IfMove);
             for j:=9 to 16 do
               if Figs[1,j].Fig=0 then
               begin
                 Figs[1,j].Fig:=Pawn;
                 Figs[1,j].Where:=1+((x shl 3) or y);
                 break;
               end;
           end;
      'P': begin
             Board[1+((x shl 3) or y)]:=Pawn;
             if x=1 then inc(Board[1+((x shl 3) or y)],IfMove);
             for j:=9 to 16 do
               if Figs[0,j].Fig=0 then
               begin
                 Figs[0,j].Fig:=Pawn;
                 Figs[0,j].Where:=1+((x shl 3) or y);
                 break;
               end;
           end;
      end;
      inc(y);
    end;
  end;
  pos:=substr(fen,' ');
  if lowercase(pos)='w' then ToMove:=0;
  if lowercase(pos)='b' then ToMove:=1;
  pos:=substr(fen,' ');
  for i:=1 to length(pos) do
    case pos[i] of
    'k': begin
           inc(Board[61],IfMove);
           inc(Board[64],IfMove);
           k1:=true;
         end;
    'K': begin
           inc(Board[5],IfMove);
           inc(Board[8],IfMove);
           k2:=true;
         end;
    'q': begin
           if not(k1) then inc(Board[61],IfMove);
           inc(Board[57],IfMove);
         end;
    'Q': begin
           if not(k2) then inc(Board[5],IfMove);
           inc(Board[1],IfMove);
         end;
    end;
  pos:=uppercase(substr(fen,' '));
  BoardKey:=GetPositionHash;
  NHod:=0;
  Rule50:=0;
end;

procedure init;
begin
  HashSize:=trunc(HashSizeMB*1024*1024/sizeof(TTrans));
  SetLength(TransTable,HashSize+2);
  FillZobristTables; ClearHash;
  FillMoves;
end;

function LoadBook:boolean;
//Загрузка дебютов
var f:file of TOpen;
begin
  LoadBook:=false;
  if not(FileExists('FreeChess.bok')) then exit;
  assignfile(f,'FreeChess.bok');
  reset(f);
  read(f,Open);
  closefile(f);
  LoadBook:=true;
end;

procedure FillMoves;
var i,j,x,y,dx,dy:integer;
//Генерация хдов для всех фигур 
begin
//King
  i:=0;
  for x:=-1 to 1 do
    for y:=-1 to 1 do
      if not((x=0) and (y=0)) then
      begin
        inc(i);
        Movs.Number[1,i]:=1;
        Movs.Moves[1,i,1].x:=x;
        Movs.Moves[1,i,1].y:=y;
      end;
  Movs.Number[1,0]:=i;
//Queen
  i:=0;
  for x:=-1 to 1 do
    for y:=-1 to 1 do
      if not((x=0) and (y=0)) then
      begin
        inc(i); dx:=0; dy:=0;
        Movs.Number[2,i]:=7;
        for j:=1 to 7 do
        begin
          dx:=dx+x; dy:=dy+y;
          Movs.Moves[2,i,j].x:=dx;
          Movs.Moves[2,i,j].y:=dy;
        end;
      end;
  Movs.Number[2,0]:=i;
//Rook
  i:=0;
  for x:=-1 to 1 do
    for y:=-1 to 1 do
      if not((x=0) and (y=0)) and (abs(x)<>abs(y)) then
      begin
        inc(i); dx:=0; dy:=0;
        Movs.Number[3,i]:=7;
        for j:=1 to 7 do
        begin
          dx:=dx+x; dy:=dy+y;
          Movs.Moves[3,i,j].x:=dx;
          Movs.Moves[3,i,j].y:=dy;
        end;
      end;
  Movs.Number[3,0]:=i;
//Bishop
  i:=0;
  for x:=-1 to 1 do
    for y:=-1 to 1 do
      if not((x=0) and (y=0)) and (abs(x)=abs(y)) then
      begin
        inc(i); dx:=0; dy:=0;
        Movs.Number[4,i]:=7;
        for j:=1 to 7 do
        begin
          dx:=dx+x; dy:=dy+y;
          Movs.Moves[4,i,j].x:=dx;
          Movs.Moves[4,i,j].y:=dy;
        end;
      end;
  Movs.Number[4,0]:=i;
//Knight
  i:=0;
  for x:=-2 to 2 do
    for y:=-2 to 2 do
      if (abs(x)+abs(y))=3 then
      begin
        inc(i);
        Movs.Number[5,i]:=1;
        Movs.Moves[5,i,1].x:=x;
        Movs.Moves[5,i,1].y:=y;
      end;
  Movs.Number[5,0]:=i;
end;

end.
