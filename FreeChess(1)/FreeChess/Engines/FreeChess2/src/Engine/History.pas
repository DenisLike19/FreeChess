unit History;

interface

uses Vars;

var wHist,bHist:array[1..64,1..64] of integer;
    Killer:array[1..MaxDepth,1..2,1..2] of byte;

procedure ClearHistory;
procedure IncHistory(Move:TMo;blck,ply,depth:byte);

implementation

procedure ClearHistory;
var i,j:integer;
begin
  for i:=1 to 64 do
    for j:=1 to 64 do
    begin
      wHist[i,j]:=0;
      bHist[i,j]:=0;
    end;
  for i:=1 to MaxDepth do
    for j:=1 to 2 do
    begin
      Killer[i,j,1]:=0;
      Killer[i,j,2]:=0;
    end;
end;

procedure IncHistory(Move:TMo;blck,ply,depth:byte);
begin
  if not(Move.isKill) then
  begin
    if blck=0 then wHist[Move.fromb,Move.tob]:=wHist[Move.fromb,Move.tob]+depth*depth
    else bHist[Move.fromb,Move.tob]:=bHist[Move.fromb,Move.tob]+depth*depth;
    if (Killer[ply,1,1]<>Move.fromb) and (Killer[ply,1,2]<>Move.tob) then
    begin
      Killer[ply,2,1]:=Killer[ply,1,1];
      Killer[ply,2,2]:=Killer[ply,1,2];
      Killer[ply,1,1]:=Move.fromb;
      Killer[ply,1,2]:=Move.tob;
    end;
  end;
end;

end.
