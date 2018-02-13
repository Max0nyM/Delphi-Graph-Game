uses ABCObjects,GraphABC,ABCButtons;


const

  wth = 800;
  hth = 600;
  w  = 20;
  w1 = 1;
  m  = 13;
  n  = 20;
  x0 = 20;
  y0 = 100;
  delay = 10;
  

Type
  Reds = array[1..n*m] of CircleABC;
  Rects = array[1..100] of RectangleABC;
  Circles = array[0..n,0..m] of CircleABC;
  Point = Record
  x:integer;
  y:integer;
  end;
  
  Player = Record
  name:string[80];
  lvl:integer;
  losed:boolean;
  points:array[1..260] of Point;
  end;
  
  Setting = Record  
  startLevel,lifes:integer;
  player1,player2:Player;
  end;  
          

   var
   
   obj:Circles;
   RedCircles:Reds;
   Edit:Rects;
   RedCount:integer;
   NewGame, CloseGame,SettingsGame,SaveSettings,SaveGameButton,ChangePlayer: ButtonABC;
   StatusRect,Box: RectangleABC;
   CurrentCircle,PrevCircle,CurrentRect,PrevRect:ObjectABC;
   SetNum,SetSetting:boolean;
   CurrentPlayer:Player;
   sets:Setting;
   f: File of Setting;
   
 
procedure initWindow();
begin
  Window.Title := 'Հիշողության վարժանք';
  Window.IsFixedSize := True;
  Window.SetSize(wth,hth);
  CenterWindow;
end;

procedure LoadSettings();
begin
  AssignFile(f, 'Settings.set');
  Reset(f);
  read(f,sets);
  Close(f);
end;
procedure SaveAndResetSetting();
begin
AssignFile(f, 'Settings.set');
Rewrite(f);
sets.player1.lvl:=sets.startLevel;
sets.player2.lvl:=sets.startLevel;
sets.player1.losed:=false;
sets.player2.losed:=false;
sets.player1.points[1].x:=0;
sets.player1.points[1].y:=0;
sets.player2.points[1].x:=0;
sets.player2.points[1].y:=0;
try
sets.lifes:=Edit[2].Number;
sets.startLevel:=Edit[1].Number;
sets.player1.lvl:=sets.startLevel;
sets.player2.lvl:=sets.startLevel;
sets.player1.name:=Edit[3].Text;
sets.player2.name:=Edit[4].Text;
Write(f,sets);
close(f);
except
Write(f,sets);
close(f);
LoadSettings;
end;

end;
procedure LoadGame();
begin
if (sets.player1.losed) then
CurrentPlayer:=sets.player2
else
if (sets.player2.losed) then
CurrentPlayer:=sets.player1
else
begin
SaveAndResetSetting;
CurrentPlayer:=sets.player1;
end;
end;

procedure SaveGame(_player:Player);
var i:integer;
begin
i:=1;
while(RedCircles[i]<>nil) do
begin
_player.points[i].x:=RedCircles[i].Position.X;
_player.points[i].y:=RedCircles[i].Position.Y;
inc(i);
end;
AssignFile(f, 'Settings.set');
Rewrite(f);
if(sets.player1.name = _player.name) then
sets.player1:=_player
else
sets.player2:=_player;
Write(f, sets);
close(f);
end;




procedure Clear();
var
cl:Reds;
begin
ClearWindow(clRoyalBlue);
RedCircles:=cl;;

if NewGame<>nil then
NewGame.Destroy;
if CloseGame<>nil then
CloseGame.Destroy;
if SettingsGame<>nil then
SettingsGame.Destroy;
if SaveSettings<>nil then
SaveSettings.Destroy;

if SaveGameButton<>nil then
SaveGameButton.Destroy;
if ChangePlayer<>nil then
ChangePlayer.Destroy;
if (StatusRect<>nil) then
StatusRect.Destroy;


if(obj[1,1]<>nil)then
begin
for var i:=0 to n-1 do
for var j:=0 to m-1 do
begin
obj[i,j].Destroy;
end;
end;

if (Box <> nil) then
Box.Destroy;
if(Edit[1] <> nil) then
Edit[1].Destroy;
if(Edit[3] <> nil) then
Edit[3].Destroy;
if(Edit[4] <> nil) then
Edit[4].Destroy;




end;


procedure Save_Game();
begin
SaveGame(CurrentPlayer);
end;

procedure Status();
var s:string;
begin
StatusRect := RectangleABC.Create(0,0,Window.Width,80,clSteelBlue);
StatusRect.TextScale:=0.9;
StatusRect.BorderWidth:=2;
StatusRect.Text := sets.player1.name+'`s score: ' + IntToStr(sets.player1.lvl) + #10#13+sets.player2.name+'`s score: ' + IntToStr(sets.player2.lvl) + #10#13+'Now Playing: ' + CurrentPlayer.name;
s:='Level: '+CurrentPlayer.lvl;
SetBrushStyle(bsClear);
SetFontSize(15);
TextOut(StatusRect.Width-TextWidth(s)-25,StatusRect.Height-TextHeight(s),s);
end;

procedure SetCircles();
var LocalRedCircles:Reds;
begin
 
  for var u:=1 to CurrentPlayer.lvl do 
  begin
  if(CurrentPlayer.points[1].x=0) then
  begin
  var x := Random(n-1)+1;
  var y := Random(m-1)+1;
  obj[x,y].Color:=clSalmon;
  LocalRedCircles[u]:=obj[x,y];
  end
  else
  begin
  var ojz:=ObjectUnderPoint(CurrentPlayer.points[u].x,CurrentPlayer.points[u].y);
  ojz.Color:=clRed;
  end;
  Sleep(200);
  end;
  RedCircles:=LocalRedCircles;
end;



procedure Board();
begin
for var i:=0 to n-1 do
for var j:=0 to m-1 do
begin
var ob := CircleABC.Create(x0+2*i*w,y0+2*j*w,20,clLightSkyBlue);
obj[i,j]:= ob;
end;
Status;
SetCircles;
end;

procedure ChangePlayerProc();
begin
if ((CurrentPlayer.name = sets.player1.name) and (sets.player2.losed = false)) then
CurrentPlayer:=sets.player2
else
if ((CurrentPlayer.name = sets.player2.name) and (sets.player1.losed = false)) then
CurrentPlayer:=sets.player1
else
if ((sets.player2.losed) and (sets.player1.losed)) then
begin
SaveAndResetSetting;
CurrentPlayer:=sets.player1;
end;

Board;
end;

procedure SetButtons();
begin
SaveGameButton := new ButtonABC(15, 15+25+5, 150, 25, 'Save Game', clCadetBlue);
ChangePlayer := new ButtonABC(15, 15, 150, 25, 'Change Player', clCadetBlue);
SaveGameButton.OnClick+=Save_Game;
ChangePlayer.OnClick+=ChangePlayerProc;
end;

procedure NewGameProc();
begin
Clear;
LoadGame;
SetButtons;
Board;
end;


    
procedure Settings();
var wit,het,st:integer;
begin
Clear;
Box:=RectangleABC.Create(Window.Width div 4,Window.Height div 4,Window.Width div 2,250,clSteelBlue);
SetBrushStyle(bsClear);
TextOut(Window.Width div 4,(Window.Height div 4)-TextHeight('Settings')+4,'Settings');
SetFontSize(20);
wit:=(Window.Width div 4);
het:=(Window.Height div 4);
st:=TextWidth('Start Level');
TextOut(wit+10,het+50,'Start Level');
TextOut(wit+10,het+100,'Player 1');
TextOut(wit+10,het+150,'Player 2');
Edit[1]:= RectangleABC.Create(wit+50+st,het+55,200,25,Color.White);
Edit[3]:= RectangleABC.Create(wit+50+st,het+105,200,25,Color.White);
Edit[4]:= RectangleABC.Create(wit+50+st,het+155,200,25,Color.White);
Edit[1].Number:=sets.startLevel;
Edit[3].Text:=sets.player1.name;
Edit[4].Text:=sets.player2.name;
SaveSettings := new ButtonABC((wit+Box.Height div 2), Box.Width-30, 150, 25, 'Save And Reset Settings', clCadetBlue);
SaveSettings.OnClick:=SaveAndResetSetting;
end;




procedure CreateMenu();
var x,y1,y2,y3:integer;
begin
      ClearWindow(clRoyalBlue);
      x:= (wth-250) div 2;
      y1:=(hth-300) div 2;
      y2:=y1+110;
      y3:= y2+110;
      NewGame := new ButtonABC(x, y1, 250, 80, 'New Game', clCadetBlue);
      SettingsGame:= new ButtonABC(x, y2, 250, 80, 'Settings', clCadetBlue);
      CloseGame:= new ButtonABC(x, y3, 250, 80, 'Exit', clCadetBlue);
      NewGame.OnClick+=NewGameProc;
      SettingsGame.OnClick+=Settings;
      CloseGame.OnClick+=CloseWindow;
end;

procedure GetWinner();
begin
SetBrushStyle(bsClear);
if sets.player1.lvl > sets.player2.lvl then
TextOut(0,0,'The Winner Is`'+sets.player1.name+#10#13+'Press ESC - MENU')
else
if sets.player1.lvl < sets.player2.lvl then
TextOut(0,0,'The Winner Is`'+sets.player2.name+#10#13+'Press ESC - MENU')
else
TextOut(0,0,'DRAW'+#10#13+'Press ESC - MENU');

end;

procedure Lose();
begin
CurrentPlayer.losed:=true;
Save_Game;
Clear;
if ((sets.player1.losed = true) and (sets.player2.losed = true)) then 
begin
GetWinner;
SaveAndResetSetting;
end
else
begin
ChangePlayerProc;
SetButtons;
end;
end;

procedure Check();
var
i:integer;
begin
i:=StrToInt(CurrentCircle.Text);
if(RedCircles[i]<>nil)then
begin
if RedCircles[i] <> CurrentCircle then
Lose
else
if RedCircles[i] = CurrentCircle then
Inc(RedCount);
if ((RedCircles[i+1] = nil) and (CurrentPlayer.losed = false) and (RedCircles[i]<>nil) and (CurrentCircle<>nil) and (RedCount=CurrentPlayer.lvl)) then
begin
CurrentPlayer.lvl+=1;
RedCount:=0;
Save_Game;
Clear;
SetButtons;
Board;
end;
end;

end;
procedure KeyPress(c:char);
begin
if SetNum then 
begin
if c in ['1'..'9'] then
CurrentCircle.Text += c;
if c = #13 then
begin
CurrentCircle.Color:=clSalmon;
PrevCircle:=nil;
SetNum:=false;
Check;
end;

if c = #8 then
begin
CurrentCircle.Text:='';
end;

end;

if SetSetting then 
begin
CurrentRect.Text+=c;
if c = #13 then
begin
CurrentRect.Color:=Color.Snow;
PrevRect:=nil;
SetSetting:=false;
end;
if c = #8 then
begin
CurrentRect.Text:='';
end;

end;
end;

procedure Control(Key: integer);
begin
case Key of
VK_Escape:
begin
Clear;
SetBrushStyle(bsSolid);
CreateMenu;
end;
end;
end;

procedure MyMouseDown(x,y,mb: integer);
var ob:ObjectABC;
begin
ob:=ObjectUnderPoint(x,y);

  if((PrevCircle=nil) and (ob is CircleABC)) then
  CurrentCircle := ob
  else
  CurrentCircle:=PrevCircle;
  
  if (CurrentCircle<>nil) and (CurrentCircle is CircleABC) and (CurrentCircle.Color = clSalmon)  then
  begin
  CurrentCircle.Color:=clLightGreen;
  PrevCircle:=CurrentCircle;
  SetNum:=true;
  end;
 
 if((PrevRect=nil) and (ob is RectangleABC)) then
  CurrentRect := ob
  else
  CurrentRect:=PrevRect;
  
 if ((ob <> nil) and (ob is RectangleABC) and (ob.Width=200))then
 begin
 CurrentRect.Color:=Color.LightGreen;
 PrevRect:=CurrentRect;
 SetSetting:=true;
 end;
  
  
  
       
  
end;
begin
  initWindow;
  CreateMenu;
  LoadSettings;  
  OnKeyDown:=Control;
  OnKeyPress:=KeyPress;
  OnMouseDown := MyMouseDown;
end.