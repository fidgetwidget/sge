package samples.blockDrop;


import openfl.display.Shape;
import openfl.display.Graphics;
import openfl.ui.Keyboard;
import sge.Game;
import sge.scene.Scene;
import sge.geom.base.Rectangle;
import sge.Lib;


class BlockDrop extends Scene
{

  public static var TILE_SIZE :Int = 32;
  public static var BOARD_COLS :Int = 10;
  public static var BOARD_ROWS :Int = 21;

  private var DEFAULT_DELAY_TIME :Int = 50;
  private var DEFAULT_DROP_COUNT_DECREMENTER :Int = 10;
  private var MIN_DROP_COUNT_DECREMENTER :Int = 1;
  private var MIN_DELAY_TIME :Int = 30;

  private var _debugShape :Shape;
  private var board :GameBoard;

  private var activePiece :Block;
  private var nextPiece :NextBlock;
  
  private var rowsToClear :Array<Int>;

  private var nextPieceType :String;
  private var nextPieceTypes :Array<String>;
  private var nextPiecePool :Array<String>;

  private var delta :Float;
  private var delayTime :Int;
  private var clearRowsDelay :Int;
  private var dropCount :Int;
  private var dropCountDecrementer :Int;


  public function new() 
  { 

    super();

    _debugShape = new Shape();
    
    rowsToClear = new Array();
    
    board = new GameBoard();
    activePiece = new Block();
    nextPiece = new NextBlock();

  }
  

  override private function onReady() : Void
  {

    var stageWidth   = Game.root.stage.stageWidth;
    var stageHeight  = Game.root.stage.stageHeight;

    board.width   = TILE_SIZE * BOARD_COLS;
    board.height  = TILE_SIZE * BOARD_ROWS;
    board.x = Math.floor((stageWidth * 0.5) - (board.width * 0.5));
    board.y = Math.floor((stageHeight * 0.5) - (board.height * 0.5));

    nextPiece.offsetX = board.x + board.width + 20;
    nextPiece.offsetY = board.y + 20;
    activePiece.offsetX = board.x;
    activePiece.offsetY = board.y;


    _sprite.addChild(_debugShape);

    _sprite.addChild(board.shape);
    _sprite.addChild(activePiece.shape);
    _sprite.addChild(nextPiece.shape);

    resetGame();

  }


  override public function update() : Void
  {

    handleInput();

    if (isPaused) return;

    if (rowsToClear.length == 0)
    {

      dropPiece();

      checkForClearRows();

    }
    
    if (rowsToClear.length > 0)
    {

      if (clearRowsDelay > 0)
      {
        clearRowsDelay -= Math.floor(Game.delta * 100);
      }
      else
      {
        clearRows();
      }

    }

  }


  override public function render() : Void
  {

    board.render();

    activePiece.render();

    nextPiece.render();

    if (clearRowsDelay > 0)
    {
      render_clearRows();
    }

    drawBounds();

  }


  // ----------------------------------------
  // 
  // Helpers
  // 
  // ----------------------------------------

  // Reset everything
  private function resetGame() :Void
  {

    delayTime = DEFAULT_DELAY_TIME;
    dropCountDecrementer = DEFAULT_DROP_COUNT_DECREMENTER;
    delta = 0;
    dropCount = 0;
    clearRowsDelay = 0;

    board.clearBoard();

    activePiece.init();
    nextPiece.reset();

    nextPiece.ready(activePiece);

  }


  override private function handleInput() :Void
  {

    var input = Game.inputManager;

    if (input.keyboard.isPressed(Keyboard.LEFT))
    {
      activePiece.move(-1, 0, board.collision);
    }
    else if (input.keyboard.isPressed(Keyboard.RIGHT))
    {
      activePiece.move(1, 0, board.collision);
    }

    if (input.keyboard.isPressed(Keyboard.SHIFT))
    {
      activePiece.rotate(1, board.collision);
    }
    else if (input.keyboard.isPressed(Keyboard.UP))
    {
      activePiece.rotate(-1, board.collision);
    }

    if (input.keyboard.isDown(Keyboard.DOWN))
    {
      if (! activePiece.drop( board.collision ) )
      {
        setCurrentBlock();
      }
    }

  }

  // 
  private function dropPiece() :Void
  {
    delta += (Game.delta * 100);

    if (delta > delayTime)
    {      
      if (! activePiece.drop( board.collision ) )
      {
        setCurrentBlock();
      }

      delta -= delayTime;

      // The speeding up of the game happens here
      dropCount++;
      if (dropCount > dropCountDecrementer)
      {
        if (delayTime > MIN_DELAY_TIME) delayTime--;

        if (dropCountDecrementer > MIN_DROP_COUNT_DECREMENTER) dropCountDecrementer--;

        dropCount -= dropCountDecrementer;
      }
      
    }
  }

  // check for and get a list of full rows
  private function checkForClearRows() :Void
  {
    rowsToClear = board.clearRows();
    if (rowsToClear.length > 0)
    {
      clearRowsDelay = 30;
    }
  }

  // Clear all of the full rows
  private function clearRows() :Void
  {
    
    while (rowsToClear.length > 0)
    {
      board.dropRow( rowsToClear.shift() );
    }

  }

  private function setCurrentBlock() :Void
  {
    activePiece.eachBlock(setCurrentBlocks);
    
    nextPiece.ready(activePiece);
  }

  
  private function setCurrentBlocks(col :Int, row :Int) :Void board.setBlock(col, row, activePiece.type);
  
  

  private function render_clearRows() :Void
  {
    var g = board.shape.graphics;
    var xx :Int;
    var yy :Int;

    g.beginFill(0x339955, 1);

    xx = board.x;

    for (i in 0...rowsToClear.length)
    {
      yy = board.y + (rowsToClear[i] * BlockDrop.TILE_SIZE);

      g.drawRect(xx, yy, BlockDrop.TILE_SIZE * BOARD_COLS, BlockDrop.TILE_SIZE);
    }

    g.endFill();

  }
  
  private function drawBounds() : Void
  {
    
    var g = _debugShape.graphics;

    g.clear();

    // Draw Bounds
    
    g.lineStyle(1, 0x555555, 1);

    g.drawRect(board.x, board.y, board.width, board.height);

    g.lineStyle(0, 0 ,0);

  }


}