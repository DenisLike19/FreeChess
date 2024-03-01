unit Iface;

//****************************************
//* Copyright (C) 2006 by Maklyakov Ivan *
//****************************************

//������ ���������� �� UCI

interface

uses vars,Moves,Util,Main,Sysutils,windows,Think,history,hash;

function Protokol(str:string):byte;

implementation

procedure Think;
//������� �����
var e:TEval;
    s:string;
    mo:TMo;
    bbb:TBoard;
    fff:TFigu;
    ppp:TProh;
    kkk:int64;
    j:byte;
    lastline:Tline;
begin
  Otmena:=false; Otm:=false;
  lastres1:=0; lastres2:=0;
  nodes:=0; j:=0;  ResetLine(Lin);
  //���� ��� �� ����������
  if Opn then Mo:=OpenLib;
  StartTime:=now;
  EndTim:=0; Tim:=0;
  if (Rules.wtime<>0) or (Rules.btime<>0) then
  begin
    if ToMove=0 then EndTim:=Rules.wtime
    else EndTim:=Rules.btime;
    if (Rules.winc<>0) or (Rules.binc<>0) then
    begin
      if ToMove=0 then
      begin
        if Rules.movestogo<>0 then inc(EndTim,(Rules.movestogo-1)*Rules.winc)
      end else
      begin
        if Rules.movestogo<>0 then inc(EndTim,(Rules.movestogo-1)*Rules.binc)
      end;
    end;
    if Rules.movestogo>1 then EndTim:=trunc(1.2*(EndTim/Rules.movestogo));
    if Rules.movestogo=1 then EndTim:=EndTim-500;
    if Rules.movestogo=0 then
    begin
      if NHod<=80 then EndTim:=trunc(1.2*(EndTim/30))
      else if NHod<120 then EndTim:=trunc(1.2*(EndTim/25))
      else EndTim:=trunc(1.2*(EndTim/20));
    end;
    if ((Rules.winc<>0) or (Rules.binc<>0)) and (Rules.movestogo<>1) then
    begin
      if ToMove=0 then inc(EndTim,Rules.winc)
      else inc(EndTim,Rules.binc);
    end;
    if ToMove=0 then
    begin
      if EndTim>=Rules.wtime then EndTim:=trunc(0.8*Rules.wtime);
    end else
    begin
      if EndTim>=Rules.btime then EndTim:=trunc(0.8*Rules.btime);
    end;
    if EndTim<=100 then EndTim:=100;
  end;
  if Rules.ponder then EndTim:=trunc(EndTim*1.1);
  if ToMove=0 then
  begin
    if EndTim>=Rules.wtime then EndTim:=trunc(0.9*Rules.wtime);
  end else
  begin
    if EndTim>=Rules.btime then EndTim:=trunc(0.9*Rules.btime);
  end;
  if Rules.movetime<>0 then EndTim:=Rules.movetime;
  //���� ��� ���� �� ����������
  ClearHistory;
  if not(Opn) then
  begin
    //��������� ������������ ����������, ���� �� ��������� ������� ������
    while true do
    begin
      inc(j); maxply:=0;
      RealDepth:=j;
      e:=Search(-inf,inf,j,0,ToMove,Lin,false,Check(ToMove,0),true);
      if Otmena and not(Otm) then
      begin
        Lin:=LastLine;
        Break;
      end;
      bbb:=Board; fff:=Figs; ppp:=Proh; kkk:=BoardKey;
      SavePV(ToMove,j,e,lin);
      Board:=bbb; Figs:=fff; Proh:=ppp; BoardKey:=kkk;
      if not(rules.ponder) then
      begin
        if not(Rules.infinite) and ((e>inf-500) or (e<500-inf)) then break;
        if j=MaxDepth then break;
        if j=Rules.depth then break;
        if (EndTim<>0) and (Rules.movestogo<>1) and (Rules.movetime=0) then
        begin
          CurrTime:=now; Tim:=trunc((CurrTime-StartTime)*86400000);
          if Tim>trunc(Endtim/2) then break;
        end;
      end;
      if Otmena then Break;
      lastline:=Lin;
    end;
    s:=Koord[Lin.line[1].fromb]+Koord[Lin.line[1].tob];
    if ((Lin.line[1].flag1=6) or (Lin.line[1].flag1=7)) then
      case Lin.line[1].flag2 of
      2: s:=s+'q';
      3: s:=s+'r';
      4: s:=s+'b';
      5: s:=s+'n';
      end;
    s:='bestmove '+s;
    if ponder then
    begin
      s:=s+' ponder '+Koord[Lin.line[2].fromb]+Koord[Lin.line[2].tob];
      if ((Lin.line[2].flag1=6) or (Lin.line[2].flag1=7)) then
        case Lin.line[2].flag2 of
        2: s:=s+'q';
        3: s:=s+'r';
        4: s:=s+'b';
        5: s:=s+'n';
        end;
    end;
    LPrint(s);
  end else
  begin
    s:=Koord[mo.fromb]+Koord[mo.tob];
    LPrint('bestmove '+s);
  end;
end;

//������������ �������
function Protokol(str:string):byte;
var res,mfrom,mto,b,p:byte;
    i:integer;
    cmd,sc,fen:string;
    Moves:TGen;
    mo:TMo;
    handle,id,excode:cardinal;
begin
  while (id<>0) do
  begin
    GetExitCodeThread(handle, excode);
    if excode = STILL_ACTIVE then Sleep(16)
    else id := 0
  end;
  //�� ��������� ��������� - ���� �� ������
  res:=255;
  //�������� �������
  cmd:=SubStr(str,' ');
  //���� �����
  if (uppercase(cmd)='QUIT') then
  begin
    res:=0;
  end;
  //���� ������� UCI
  if (uppercase(cmd)='UCI') then
  begin
    //������� UCI � �������� ���� � ������
    UCI:=true;
    LPrint('id name '+Ver);
    LPrint('id author Ivan Maklyakov');
    LPrint('option name Hash type spin default 1 min 1 max 512');
    LPrint('option name OwnBook type check default true');
    LPrint('option name Ponder type check default true');
    LPrint('option name Clear Hash type button');
    LPrint('uciok');
  end;
  //���� ���������� ISREADY
  if (uppercase(cmd)='ISREADY') and UCI then
  begin
    //�����, ��� �� :)
    LPrint('readyok');
  end;
  //���� �������, ��� ���� ����� ����
  if (uppercase(cmd)='UCINEWGAME') and UCI then
  begin
    readfen(startfen);
  end;
  //���� ����� �������� �������
  if (uppercase(cmd)='POSITION') and UCI then
  begin
    //��������� �������
    sc:=SubStr(str,' ');
    //���� ������� �� FEN
    if uppercase(sc)='FEN' then
    begin
      //��������� FEN
      fen:=SubStr(str,' ');
      fen:=fen+' '+SubStr(str,' ');
      fen:=fen+' '+SubStr(str,' ');
      fen:=fen+' '+SubStr(str,' ');
      fen:=fen+' '+SubStr(str,' ');
      fen:=fen+' '+SubStr(str,' ');
      ReadFen(fen);
    end;
    //���� ������� ���������
    if uppercase(sc)='STARTPOS' then readfen(startfen);
    //������ ����� ��������� ������������������ �����
    if str<>'' then sc:=SubStr(str,' ');
    while str<>'' do
    begin
      //��������� ���
      sc:=uppercase(SubStr(str,' '));
      //����� ���������� ����
      mfrom:=1+(ord(sc[2])-ord('1'))*8 + (ord(sc[1])-ord('A'));
      mto:=1+(ord(sc[4])-ord('1'))*8 + (ord(sc[3])-ord('A'));
      //���������� ����
      Moves:=GenMoves(ToMove,true);
      //���� ��� � ������ �����
      b:=0; p:=0;
      if length(sc)=5 then
      begin
        if sc[5]='Q' then p:=2;
        if sc[5]='R' then p:=3;
        if sc[5]='B' then p:=4;
        if sc[5]='N' then p:=5;
      end;
      for i:=1 to Moves.NMove do
        if (Moves.Move[i].fromb=mfrom) and (Moves.Move[i].tob=mto) then
          if p=0 then
          begin
            b:=i;
            break;
          end
          else if ((Moves.Move[i].flag1=7) or (Moves.Move[i].flag1=6)) and (Moves.Move[i].flag2=p) then
          begin
            b:=i;
            break;
          end;
      if b<>0 then mo:=Moves.Move[b];
      if b=0 then  halt;
      //������ ���
      MakeMove(mo);
      //�������� ����
      ToMove:=1-ToMove;

      if ((Board[mo.tob] and 7)=6) or (mo.isKill) then Rule50:=1
      else inc(Rule50);

      ProvHash[Rule50]:=BoardKey;

      inc(Nhod);
      Game[Nhod].mmm:=mo;
    end;
  end;
  //���� ������� GO
  if (uppercase(cmd)='GO') and UCI then
  begin
    //�������� �������
    NewRule;
    woforce:=false;
    while str<>'' do
    begin
      //��������� �������������� ��������, ����� ������ ��� ����
      sc:=SubStr(str,' ');
      //�������:
      //��������
      if lowercase(sc)='depth' then     Rules.depth:=strtoint(SubStr(str,' '));
      //����� �� ���
      if lowercase(sc)='movetime' then  Rules.movetime:=strtoint(SubStr(str,' '));
      //����, ������ � �.�.
      if lowercase(sc)='wtime' then     Rules.wtime:=strtoint(SubStr(str,' '));
      if lowercase(sc)='btime' then     Rules.btime:=strtoint(SubStr(str,' '));
      if lowercase(sc)='winc' then      Rules.winc:=strtoint(SubStr(str,' '));
      if lowercase(sc)='binc' then      Rules.binc:=strtoint(SubStr(str,' '));
      if lowercase(sc)='movestogo' then Rules.movestogo:=strtoint(SubStr(str,' '));
      //����� ��� (�� ��������)
      if lowercase(sc)='mate' then      Rules.mate:=strtoint(SubStr(str,' '));
      if lowercase(sc)='woforce' then   woforce:=true;
      //����������
      if lowercase(sc)='infinite' then  Rules.infinite:=true;
      //������ �������
      if lowercase(sc)='nodes' then     Rules.nodes:=strtoint(SubStr(str,' '));
      //������
      if lowercase(sc)='ponder' then    Rules.ponder:=true;
    end;
    handle := BeginThread(nil, 0, @Think, nil, 0, id);
  end;
  //���� ponderhit
  if (uppercase(cmd)='PONDERHIT') and UCI then
  begin
    Rules.ponder:=false;
  end;
  //���� ������� setoption
  if (uppercase(cmd)='SETOPTION') and UCI then
  begin
    sc:=SubStr(str,' ');
    sc:=SubStr(str,' ');
    if uppercase(sc)='HASH' then
    begin
      fen:=SubStr(str,' ');
      fen:=SubStr(str,' ');
      HashSizeMB:=strtoint(fen);
      init;
    end;
    if uppercase(sc)='OWNBOOK' then
    begin
      fen:=SubStr(str,' ');
      fen:=SubStr(str,' ');
      if uppercase(fen)='TRUE' then OpnTest:=LoadBook;
      if uppercase(fen)='FALSE' then OpnTest:=false;
    end;
    if uppercase(sc)='PONDER' then
    begin
      fen:=SubStr(str,' ');
      fen:=SubStr(str,' ');
      if uppercase(fen)='TRUE' then ponder:=true;
      if uppercase(fen)='FALSE' then ponder:=false;
    end;
    if (uppercase(sc)='CLEAR') and (uppercase(str)='HASH') then ClearHash;
  end;
  if (uppercase(cmd)='STOP') and UCI then Otmena:=true;
  Protokol:=res;
end;

end.
