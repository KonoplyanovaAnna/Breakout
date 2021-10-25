uses GraphABC, ABCObjects, System.Timers;

const brickCount = 10; 
const brickWidth = 50; 
const brickHeight = 20; 
const gapBetweenBricks = 2; 
const sliderGap = 100; 
const sliderWidth = 100; 
const sliderHeight = 20; 
const topGap = 100; 
const ballSize = 15; 
var countB := 10 * 10;

var wallColors := Arr( 
  Color.Red, Color.Orange, Color.Yellow, Color.GreenYellow, Color.Cyan);

var Slider: RectangleABC := nil;
var Ball: CircleABC := nil;
var gameTimer := new Timer(10);
var speedTimer := new Timer(20000);

procedure DrawWall(xWall, yWall: integer);
begin
  for var i := 0 to 9 do
  begin
    xWall := gapBetweenBricks;
    for var j := 1 to brickCount do
    begin
      new RectangleABC(xWall, yWall, brickWidth, brickHeight, wallColors[i div 2]);
      xWall += brickWidth + gapBetweenBricks;
    end;
    yWall += brickHeight + gapBetweenBricks;
  end;
end;

procedure MoveSlider(x, y, mousebutton: integer);
begin
  x := x - sliderWidth div 2;
  if x < 0 then
    x := 0;
  if x > Window.Width - SliderWidth then
    x := Window.Width - SliderWidth;
  Slider.Left := x;
end;

procedure CreateSlider(xSlider, ySlider: integer);
begin
  Slider := new RectangleABC(xSlider, ySlider, sliderWidth, sliderHeight, Color.Black);
  OnMouseMove += MoveSlider;
end;

function getCollidingObject(): ObjectABC;
begin
  if ObjectUnderPoint(Ball.Center.X - ballSize - 1, Ball.Center.Y - ballSize - 1) <> nil then
    Result := ObjectUnderPoint(Ball.Center.X - ballSize - 1, Ball.Center.Y - ballSize - 1);
  
  if ObjectUnderPoint(Ball.Center.X + ballSize + 1, Ball.Center.Y - ballSize - 1) <> nil then
    Result := ObjectUnderPoint(Ball.Center.X + ballSize + 1, Ball.Center.Y - ballSize - 1);
  
  if ObjectUnderPoint(Ball.Center.X + ballSize + 1, Ball.Center.Y + ballSize + 1) <> nil then
    Result := ObjectUnderPoint(Ball.Center.X + ballSize + 1, Ball.Center.Y + ballSize + 1);
  
  if ObjectUnderPoint(Ball.Center.X - ballSize - 1, Ball.Center.Y + ballSize + 1) <> nil then
    Result := ObjectUnderPoint(Ball.Center.X - ballSize - 1, Ball.Center.Y + ballSize + 1);
end;

procedure Tick(source: Object; e: ElapsedEventArgs);
begin
  if (Ball.Center.Y + ballSize) >= Window.Height then
  begin
    gameTimer.Stop;
    new TextABC(170, 20, 35, 'you lose', Color.Red);
  end;
  if (Ball.Center.Y - ballSize) <= 0 then
    Ball.dy *= -1;
  if (Ball.Center.X + ballSize) >= Window.Width then
    Ball.dx *= -1;
  if (Ball.Center.X - ballSize) <= 0 then
    Ball.dx *= -1;
  var collidingObjec := getCollidingObject();
  if collidingObjec <> nil then
  begin
    if collidingObjec = Slider then
      Ball.dy *= -1
    else
    begin
      collidingObjec.Destroy;
      Ball.dy *= -1;
      countB -= 1;
      if countB = 0 then
      begin
        gameTimer.Stop;
        new TextABC(170, 20, 35, 'you win', Color.GreenYellow);
      end;
    end;
  end;
  Ball.Move;
end;

procedure CreateBall(xBall, yBall: integer);
begin
  Ball := new CircleABC(xBall, yBall, ballSize, Color.Black);
  Ball.dx := Random(-4,4);
  Ball.dy := 3;
end;

procedure SpeedBooster(source: Object; e: ElapsedEventArgs);
begin
  Ball.dy += 1 * Sign(Ball.dy);
end;

procedure Init();
begin
  DrawWall(gapBetweenBricks, topGap);
  CreateSlider(Window.Width div 2 - sliderWidth div 2, Window.Height - topGap);
  CreateBall(Window.Width div 2, Window.Height div 2);
end;

begin
  Window.Title := 'Breakout';
  Window.Width := gapBetweenBricks * (brickCount+1) +  brickWidth * brickCount;
  Window.Height := 700;
  Window.IsFixedSize := True;
  //Window.CenterOnScreen;
  Window.Top := 0;
  
  Init();
  gameTimer.Elapsed += Tick;
  gameTimer.Start;
  speedTimer.Elapsed += SpeedBooster; // увеличивает скорость на 1 каждые 20 секунд
  speedTimer.Start;
end.