unit Think;

//*********************************************
//* Copyright (C) 2005-2006 by Maklyakov Ivan *
//*********************************************

//������ ��������

interface

uses SysUtils,Vars,Moves,Eval,Hash,Util,History;

procedure SaveLine(var sl,dl:TLine;var bm:TMo);
procedure ResetLine(var l:TLine);
function Search(a,b:TEval;Depth,ply,blck:byte;var Line:TLine; nul,c2,movePV:boolean):TEval;
function Quies(a,b:TEval;ply,blck:byte):TEval;

implementation

procedure SaveLine(var sl,dl:TLine;var bm:TMo);
//��������� ��� � PV
var i:byte;
begin
  for i:=1 to sl.count do
    dl.line[i+1]:=sl.line[i];
  dl.line[1]:=bm;
  dl.count:=sl.count+1;
end;

procedure ResetLine(var l:TLine);
//�������� PV
begin
  l.count:=0;
end;

function Search(a,b:TEval;Depth,ply,blck:byte;var Line:TLine; nul,c2,movePV:boolean):TEval;
//������� �������
var tmpline:TLine;
    tmp,res,score,Margin,OptVal:TEval;
    Gen:TGen;
    i,l,j:integer;
    mo:TMo;
    ind,Ext:integer;
    bbb:TBoard;
    fff:TFigu;
    ppp:TProh;
    kkk:int64;
    ko:boolean;
    SortM:TSortMove;
    c3,c4:boolean;
    Fuck:boolean;
    last:TMo;
    s:string;
 begin
  //���� ��������� �������, ��������� ������������� �������
  if (Depth<=0) or (ply>MaxDepth) then
  begin
    if woforce then Search:=Evalution(blck)
    else Search:=Quies(a,b,ply,blck);
    exit;
  end;
  //����������� ������
  inc(nodes);
  //������������ ��������� �����
  if ((nodes mod 50000)=0) and not(rules.ponder) then
  begin
    CurrTime:=now; Tim:=trunc((CurrTime-StartTime)*86400000);
    if (nodes mod 200000)=0 then
    begin
      if Tim>100 then NPS:=trunc(1000*(nodes/Tim));
      lprint('info nps '+inttostr(NPS)+' nodes '+inttostr(nodes))
    end;
    if EndTim<>0 then
    begin
      Tim:=Tim+100;
      if Tim>EndTim then
        if (lastres2<(lastres1+cPawn div 2)) or (rules.movestogo=1) or (rules.movetime<>0) then Otmena:=true;
      if Tim>EndTim*2 then Otmena:=true;  
      if (Tim>rules.wtime) and (ToMove=0) and (rules.wtime<>0) then Otmena:=true;
      if (Tim>rules.btime) and (ToMove=1) and (rules.btime<>0) then Otmena:=true;
    end;
  end;
  //���� ������, �������
  if Otmena then
  begin
    Search:=b;
    Exit;
  end;
  //�������, ���� ����
  if nodes=Rules.nodes then Otmena:=true;
  if maxply<ply then maxply:=ply;
  hFrom:=0; hTo:=0;
  //��� ���������, ���� �� ��� � ����
  ind:=1+Abs(BoardKey mod HashSize);
  if (TransTable[ind].Depth<>0) and (TransTable[ind].Key=BoardKey) then
  begin
    //������� ����� ����� �������� � �� �������
    //���� �� ����������, �� ����-�� ������� �����
    if not(movePV) and (ply>0) and (TransTable[ind].depth>=Depth) then
    begin
      score:=TransTable[ind].Score;
      if score>a then a:=score;
      if a>=b then
      begin
        Search:=b;
        exit;
      end;
    end;
    //���������� ��� �� ����
    hFrom:=TransTable[ind].MoveFrom;
    hTo:=TransTable[ind].MoveTo;
  end;
  res:=-inf; tmp:=res;
  ko:=true;
  //���������� � ��������� ����
  Gen:=GenMoves(blck,true);
  SortM:=SortMove(Gen,blck,ply);
  //���������� ���������
  bbb:=Board; fff:=Figs; ppp:=Proh; kkk:=BoardKey;
  last:=lm; j:=0; OptVal:=inf; 
  for i:=1 to Gen.NMove do
  begin
    mo:=Gen.Move[SortM[1,i]];
    if mo.fromb<>Figs[blck,1].where then ko:=false;
    ResetLine(tmpline);
    if not(movePV) and (depth<=5) and not(c2) and not(mo.isKill) then
    begin
      if OptVal=inf then OptVal:=Evalution(blck);
    end;
    //������ ���
    MakeMove(mo);
    //����
    c3:=Check(blck,0);
    if not(c3) then inc(j);
    c4:=Check(1-blck,0);
    ProvLine[ply]:=BoardKey;
    lm:=mo;
    if (RealDepth>6) and (ply=0) then
    begin
      s:='info depth '+inttostr(realdepth)+' currmove '+Koord[lm.fromb]+Koord[lm.tob]+' currmovenumber '+inttostr(j);
      LPRint(s);
    end;
    Ext:=0; Fuck:=false;
    //���� ���, ����������
    if c4 then inc(Ext);
    //���� ������, ���������� (�� ������ �����)
    if (movePV) and ((lm.flag1=3) and (last.flag1=3) and (Price[lm.flag2 and 7]=Price[last.flag2 and 7]) and (Price[lm.flag2 and 7]<>CPawn)) then inc(Ext);
    //���� ����� �� ������������� �����������, ���� ����������
    if (movePV) and (((Mo.flag1=0) or (Mo.flag1=3)) and (Mo.flag3<>0)) then inc(Ext);
    if (movePV) and (((last.flag1=0) or (last.flag1=3)) and (last.flag3<>0)) then inc(Ext);
    //Null move
    if {not(movePV) and} (depth>=4) and not(nul) and not(c2) and not(c3) and not(c4) then
      if Search(a,a+1,depth-4,ply+2,blck,tmpline,true,false,false)<=a then
      begin
        Fuck:=true;
        tmp:=a;
      end;
    //Futility pruning
    if not(movePV) and (ext=0) and (depth<=3) and (depth>=2) and not(c2) and not(c3) and not(c4) and not(mo.isKill) and not(Fuck) then
    begin
      tmp:=OptVal+(CPawn div 2);
      if (tmp)<=a then Fuck:=true;
    end;
    //Razoring
    if not(movePV) and (ext=0) and (depth<=5) and (depth>=4) and not(c2) and not(c3) and not(c4) and not(mo.isKill) and not(Fuck) then
      if ({MatEval(blck)}OptVal+CQueen)<=a then dec(Ext);
    //���� ��� ���, �� ������� ��
    if c3 then
    begin
      Fuck:=true;
      tmp:=ply-inf+1;
    end;
    //��������� �� ������ �������
    if not(nul) then
      if CheckReps(ply) then
      begin
        Fuck:=true;
        tmp:=0;
      end;
    //���� ����������������� � Razoring
    if Depth+Ext<=0 then Ext:=0;
    //���� ������� ����� ���������, ���������
//    if Ext>1 then Ext:=1;
    //�������
    if not(Fuck) then
    begin
      tmp:=-Search(-a-1,-a,depth-1+Ext,ply+1,1-blck,tmpline,false,c4,false);
      if (tmp>a) and (tmp<b) then tmp:=-Search(-b,-a,depth-1+Ext,ply+1,1-blck,tmpline,false,c4,true);
    end;
    //���������� ��������� ������� (������ UnMakeMove)
    Board:=bbb; Figs:=fff; Proh:=ppp; BoardKey:=kkk;
    lm:=last;
    //���� ������
    if Otmena and (ply=0) and (j<>1) then Otm:=true;    
    if Otmena then
    begin
      Search:=res;
      exit;
    end;
    //�����-����...
    if tmp>res then res:=tmp;
    if res>a then
    begin
      //���� �� ���, ��������� ��������� � ���
      if not((res>inf-500) or (res<500-inf)) then SaveToHash(blck,depth,res,mo.fromb,mo.tob,ply);
      a:=res;
      if a<b then
      begin
        SaveLine(tmpline,line,mo);
        if (ply=0) and not(c3) then
        begin
          s:='info currmove '+Koord[Mo.fromb]+Koord[Mo.tob]+' currmovenumber '+inttostr(j);
          s:=s+' depth '+inttostr(RealDepth)+' seldepth '+inttostr(maxply)+' nodes '+inttostr(nodes)+' score ';
          maxply:=0;
          if (Res>inf-500)  then s:=s+'mate '+inttostr((inf-abs(Res)) div 2)
          else if (Res<500-inf) then s:=s+'mate -'+inttostr((inf-abs(Res)) div 2)
          else s:=s+'cp '+inttostr(Res);
          s:=s+' pv ';
          for l:=1 to Lin.count do
          begin
            s:=s+Koord[Lin.line[l].fromb]+Koord[Lin.line[l].tob];
            if ((Lin.line[l].flag1=6) or (Lin.line[l].flag1=7)) then
              case Lin.line[l].flag2 of
              2: s:=s+'q';
              3: s:=s+'r';
              4: s:=s+'b';
              5: s:=s+'n';
              end;
            s:=s+' ';
          end;
          if (lastres2<lastres1+(cPawn div 2)) or (realdepth<=6) then
          begin
            lastres2:=lastres1;
            lastres1:=res;
          end;
          LPrint(s);
        end;
      end;
    end;
    if a>=b then
    begin
      Search:=a;
      IncHistory(mo,blck,ply,depth);
      exit;
    end;
  end;
  //���������� ���
  if ko and not(c2) and ((res=(ply+2-inf)) or (res=(ply+1-inf))) then res:=0;
  //��� :)))
  Search:=res;
end;

function Quies(a,b:TEval;ply,blck:byte):TEval;
//������������� �������
var score:TEval;
    Gen:TGen;
    i:byte;
    last:TMo;
    bbb:TBoard;
    fff:TFigu;
    ppp:TProh;
    SortM:TSortMove;
    ept:boolean;
begin
  hFrom:=0; hTo:=0;
  //����������� ������
  inc(nodes);
  //������������ ��������� �����
  if ((nodes mod 50000)=0) and not(rules.ponder) then
  begin
    CurrTime:=now; Tim:=trunc((CurrTime-StartTime)*86400000);
    if (nodes mod 200000)=0 then
    begin
      if Tim>100 then NPS:=trunc(1000*(nodes/Tim));
      lprint('info nps '+inttostr(NPS)+' nodes '+inttostr(nodes))
    end;
    if EndTim<>0 then
    begin
      Tim:=Tim+100;
      if Tim>EndTim then
        if (lastres2<(lastres1+cPawn div 2)) or (rules.movestogo=1) or (rules.movetime<>0) then Otmena:=true;
      if Tim>EndTim*2 then Otmena:=true;  
      if (Tim>rules.wtime) and (ToMove=0) and (rules.wtime<>0) then Otmena:=true;
      if (Tim>rules.btime) and (ToMove=1) and (rules.btime<>0) then Otmena:=true;
    end;
  end;
  //�������, ���� ���� (���-�� ����� ��� ���������...)
  if nodes=Rules.nodes then Otmena:=true;
  if maxply<ply then maxply:=ply;
  //�������� ����� �������
  score:=Evalution(blck);
  if score>a then a:=score;
  if a>=b then
  begin
    Quies:=a;
    exit;
  end;
  //���������� ������ � ���������
  Gen:=GenMoves(blck,false);
  SortM:=SortMove(Gen,blck,ply);
  //��������� �������
  bbb:=Board; fff:=Figs; ppp:=Proh; last:=lm;
  //����������
  for i:=1 to Gen.NMove do
  begin
    //������� �����-����..
    ept:=true;
    MakeMove(Gen.Move[SortM[1,i]]);
    lm:=Gen.Move[SortM[1,i]];
    //���� ��� ���, �� �� ���������� ������ (��)
    if Check(blck,0) then
    begin
      ept:=false;
      score:=ply-inf+1;
    end;
    if ept then score:=-Quies(-b,-a,ply+1,1-blck);
    Board:=bbb; Figs:=fff; Proh:=ppp;
    lm:=last;
    if score>a then a:=score;
    if a>=b then
    begin
      Quies:=a;
      exit;
    end;
  end;
  //��� =))
  Quies:=a;
end;

end.
