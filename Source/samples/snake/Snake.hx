package samples.snake;


import openfl.display.Shape;
import openfl.ui.Keyboard;
import sge.Game;
import sge.scene.Scene;
import sge.geom.base.Rectangle;
import sge.geom.base.Coord;
import sge.Lib;


class Snake extends Scene
{

  private var TILE_SIZE: Int = 32;
  private var ROWS :Int = 16;
  private var COLS :Int = 16;
  private var DEFAULT_SNAKE_LENGTH :Int = 3;
  private var DEFAULT_SNAKE_MOVE_DELAY :Int = 60;
  private var MIN_SNAKE_MOVE_DELAY :Int = 10;
  private var DEFAULT_APPLE_DELAY :Int = 300;
  private var MAX_APPLES_COUNT :Int = 5;

  private var bounds :Rectangle;
  private var boundsShape :Shape;
  
  private var snakeShape: Shape;
  private var snakeLength :Int;
  private var snakeMoveDelay :Float;
  private var nextSnakeMoveDelay :Int;
  private var snakePositions: Array<Coord>;
  private var snakeFacing: Coord;

  private var applesShape :Shape;
  private var newAppleDelay :Float;
  private var nextNewAppleDelay :Int;
  private var applePositions: Array<Coord>;

  private var delta :Float;
  private var gameover :Bool = false;
  
  
  public function new() 
  { 
    super();
    
    bounds = { x: 0, y: 0, height: 0, width: 0 }
    bounds.width = TILE_SIZE * COLS;
    bounds.height = TILE_SIZE * ROWS;

    boundsShape = new Shape();
    snakeShape = new Shape();
    applesShape = new Shape();
    snakePositions = new Array<Coord>();
    applePositions = new Array<Coord>();

  }

  override private function onReady() : Void
  {

    var stageWidth   = Game.root.stage.stageWidth;
    var stageHeight  = Game.root.stage.stageHeight;

    bounds.x = (stageWidth * 0.5) - (bounds.width * 0.5);
    bounds.y = (stageHeight * 0.5) - (bounds.height * 0.5);

    _sprite.addChild(boundsShape);
    _sprite.addChild(snakeShape);
    _sprite.addChild(applesShape);

    reset();

  }

  override public function update() : Void
  {

    handleInput();

    if (isPaused) return;

    update_snake();

    update_apple();

    update_collisionCheck();

  }


  override public function render() : Void
  {

    if (!gameover)
    {
      render_bounds();

      render_snake();

      render_apples();
    }
    else
    {
      gameover = false;

      boundsShape.graphics.clear();

      boundsShape.graphics.beginFill(0x000000, 1);

      boundsShape.graphics.drawRect(bounds.x, bounds.y, bounds.width, bounds.height);

      boundsShape.graphics.endFill();

    }

  }


  private function reset() : Void
  {

    nextSnakeMoveDelay = DEFAULT_SNAKE_MOVE_DELAY;
    snakeMoveDelay = nextSnakeMoveDelay;
    snakeLength = DEFAULT_SNAKE_LENGTH;
    snakeFacing = { x: 0, y: 1 }
    clearSnakePositions();

    nextNewAppleDelay = DEFAULT_APPLE_DELAY;
    newAppleDelay = nextNewAppleDelay;
    clearApplePositions();

    var col :Int = Math.floor(COLS * 0.5);
    var row :Int = Math.floor(ROWS * 0.5);
    var coord :Coord = { x: col, y: row }
    snakePositions.push(coord);

  }


  private function clearSnakePositions() : Void
  {
    while (snakePositions.length > 0)
    {
      snakePositions.pop();
    }
  }

  private function clearApplePositions() : Void
  {
    while (applePositions.length > 0)
    {
      applePositions.pop();
    }
  }


  override private function handleInput() : Void
  {
    
    var input = Game.inputManager;

    if ( input.keyboard.isDown(Keyboard.LEFT) ) {
      
      snakeFacing.x = -1;
      snakeFacing.y = 0;

    } else if ( input.keyboard.isDown(Keyboard.RIGHT) ) {
      
      snakeFacing.x = 1;
      snakeFacing.y = 0;

    } else if (input.keyboard.isDown(Keyboard.UP)) {

      snakeFacing.x = 0;
      snakeFacing.y = -1;

    } else if (input.keyboard.isDown(Keyboard.DOWN)) {

      snakeFacing.x = 0;
      snakeFacing.y = 1;

    }

  }


  private function update_snake() : Void
  {

    if (snakeMoveDelay > 0)
    {
      snakeMoveDelay -= Game.delta * 100;
    }
    else
    {
      snakeMoveDelay = nextSnakeMoveDelay;
      
      snake_move();
    }

  }

  
  private function update_apple() : Void
  {

    if (newAppleDelay > 0)
    {
      newAppleDelay -= Game.delta * 100;
    }
    else
    {
      newAppleDelay = nextNewAppleDelay;

      apple_spawn();
    }

  }


  private function update_collisionCheck() : Void
  {

    var currentPosition = snakePositions[snakePositions.length - 1];
    var col = Math.floor(currentPosition.x);
    var row = Math.floor(currentPosition.y);

    if (collision_boundsCheck(col, row) ) reset();

    if (collision_selfCheck(col, row)) 
    {
      gameover = true;

      // TODO: play sound effect
      
      reset();
    }

    if (collision_appleCheck(col, row))
    {
      snake_grow();
    }

  }

  private inline function collision_boundsCheck( col :Int, row :Int ) : Bool
  {
    return (col < 0 || col > COLS - 1 || row < 0 || row > ROWS - 1);
  }

  private function collision_selfCheck( col :Int, row :Int, ignoreHead :Bool = true ) :Bool
  {
    if (snakePositions.length == 1) return false;

    var end :Int = (ignoreHead ? snakePositions.length - 1 : snakePositions.length);

    for (i in 0...end)
    {
      var cc :Coord = snakePositions[i];
      if (Math.floor(cc.x) == col && Math.floor(cc.y) == row) return true;
    }

    return false;
  }

  private function collision_appleCheck( col :Int, row :Int, remove :Bool = true ) :Bool
  {
    if (applePositions.length < 1) return false;

    for (i in 0...applePositions.length)
    {
      var cc :Coord = applePositions[i];
      if (Math.floor(cc.x) == col && Math.floor(cc.y) == row)
      {
        if (remove) apple_remove(i);
        return true;
      }
    }

    return false;
  }

  private inline function snake_move() :Void
  {
    var currentPosition = snakePositions[snakePositions.length - 1];
    var nextPosition = { x: currentPosition.x + snakeFacing.x, y: currentPosition.y + snakeFacing.y }

    snakePositions.push(nextPosition);

    if (snakePositions.length > snakeLength)
    {
      snakePositions.shift();
    }

    // TODO: play a sound effect  
  }

  private inline function snake_grow() : Void
  {
    snakeLength++;
    // NOTE: grow will rely on the speedUp sound
    snake_speedUp();
  }

  private inline function snake_speedUp() : Void
  {
    if (nextSnakeMoveDelay > MIN_SNAKE_MOVE_DELAY) 
    {
      nextSnakeMoveDelay--;
      // TODO: play a sound effect  
    }
  }


  // Apple Functions

  private inline function apple_spawn() : Void
  {

    if (applePositions.length > MAX_APPLES_COUNT) 
    {
      snake_speedUp();
      return;
    }

    var col :Int;
    var row :Int;
    var coord :Coord;
    
    // ensure it's not on top of the snake
    do 
    {
      col = Lib.random_int(0, COLS - 1);
      row = Lib.random_int(0, ROWS - 1);
    }
    while (collision_selfCheck(col, row) || collision_appleCheck(col, row, false));
    
    coord = { x: col, y: row }

    applePositions.push(coord);

    // TODO: play a sound effect

  }

  private inline function apple_remove( index :Int ) : Void
  {

    applePositions.splice(index, 1);

    // TODO: play a sound effect  
    
  }


  // 
  // Render Functions
  // 

  private inline function render_bounds() : Void
  {

    var g = boundsShape.graphics;
    g.clear();

    g.lineStyle(1, 0x555555, 0.8);
    g.drawRect(bounds.x, bounds.y, bounds.height, bounds.width);
    g.lineStyle(0, 0x000000, 0);

  }

  private inline function render_snake() : Void
  {
    
    var g = snakeShape.graphics;
    g.clear();
    
    g.beginFill(0x555555, 1);

    var xx :Float;
    var yy :Float;
    for( c in snakePositions )
    {
      xx = (c.x * TILE_SIZE) + bounds.x;
      yy = (c.y * TILE_SIZE) + bounds.y;
      g.drawRect(xx + 2, yy + 2, TILE_SIZE - 4, TILE_SIZE - 4);
    }
    g.endFill();

  }

  private inline function render_apples() : Void
  {

    var g = applesShape.graphics;
    g.clear();
    
    g.beginFill(0xAA2255, 1);

    var xx :Float;
    var yy :Float;
    for( c in applePositions )
    {
      xx = (c.x * TILE_SIZE) + bounds.x;
      yy = (c.y * TILE_SIZE) + bounds.y;
      g.drawRect(xx + 4, yy + 4, TILE_SIZE - 8, TILE_SIZE - 8);
    }
    g.endFill();

  }


}