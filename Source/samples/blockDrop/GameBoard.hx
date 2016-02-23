package samples.blockDrop;


import openfl.display.Shape;
import openfl.display.Graphics;
import sge.geom.base.Rectangle;


class GameBoard {


  public var shape :Shape;
  public var bounds :Rectangle;
  public var blocks :Array<Array<String>>;
  public var x (get, set) :Int;
  public var y (get, set) :Int;
  public var width (get, set) :Int;
  public var height (get, set) :Int;


  public function new() 
  { 

    bounds = { x: 0, y: 0, width: 0, height: 0 };
    blocks = new Array();
    shape = new Shape();

    clearBoard();

  }

  // 
  // Clear the Board
  // 
  public function clearBoard() :Void
  {

    eachBlock(clearBoard_eachBlock);
    changed = true;

  }



  // 
  // Clear any completed rows, and returns the number of rows cleard
  // 
  public function clearRows() :Array<Int>
  {

    var filled :Bool;
    var clearedRows :Array<Int> = new Array();

    for (row in 0...BlockDrop.BOARD_ROWS)
    {

      filled = true;

      for (col in 0...BlockDrop.BOARD_COLS)
      {
        
        if ( getBlock(col, row) == BlockTypes.NONE ) 
          filled = false;

      }

      if (filled)
        clearedRows.push(row);

    }

    return clearedRows;

  }


  public function dropRow( row :Int ) :Void
  {
    var type :String;
    var rowAbove :Int = row - 1;

    while (rowAbove > 0)
    {
      for(col in 0...BlockDrop.BOARD_COLS)
      {
        type = getBlock(col, rowAbove);
        setBlock(col, row, type);
      }

      rowAbove--;
      row--;
    }
  }

  // 
  // Get the block type at a given position
  // 
  public function getBlock( col :Int, row :Int ) :String
  {
    
    if (collision_outOfBoundsCheck(col, row)) return BlockTypes.NONE;

    return blocks[col][row];

  }

  // 
  // Set the block type at a given position
  // 
  public function setBlock( col :Int, row :Int, type :String ) :Void
  {

    if (collision_outOfBoundsCheck(col, row)) return;

    if (blocks.length - 1 < col) return;
    if (blocks[col].length - 1 < row) return;

    blocks[col][row] = type;
    changed = true;
    
  }

  // 
  // Check to see if a tetromino collides with something on the baord
  // 
  public function collision( piece :Block ) :Bool
  {
    collides = false;

    piece.eachBlock( collision_eachBlock );

    return collides;
  }

  // 
  // Draw the board (only have to re-darw it when it changes)
  // 
  public function render() :Void
  {
    changed = true;

    if (changed)
    {
      render_drawBlocks();
      changed = false;
    }
  }


  // ----------------------------------------
  // 
  // Helpers
  // 
  // ----------------------------------------

  private var collides :Bool = false;
  private var changed :Bool = false;
  private var g :Graphics;
  private var t :String = "";


  private function eachBlock( func : Int -> Int -> Void ) :Void
  {

    for (col in 0...BlockDrop.BOARD_COLS)
    {
      
      for (row in 0...BlockDrop.BOARD_ROWS)
      {
        
        func( col, row );

      }

    }

  }

  private function clearBoard_eachBlock( col :Int, row :Int ) :Void
  {

    if (blocks.length - 1 < col) blocks.insert(col, new Array());
    blocks[col].insert(row, BlockTypes.NONE);
    
  }


  private function collision_eachBlock( col :Int, row :Int ) :Void
  {
    if (collision_testPosition(col, row))
    {
      collides = true;
    }
  }

  private function collision_testPosition( col :Int, row :Int ) :Bool
  {
    if (! collision_outOfBoundsCheck(col, row))
    {
      return (getBlock(col, row) != BlockTypes.NONE);
    }
    return true;
  }

  private function collision_outOfBoundsCheck( col :Int, row :Int ) :Bool
  {
    return (col < 0 || col > BlockDrop.BOARD_COLS - 1 || row > BlockDrop.BOARD_ROWS - 1);
  }

  private function collision_aboveBoardCheck( col :Int, row :Int ) :Bool
  {
    return row < 0;
  }

  private function render_drawBlocks() :Void
  {

    // redraw the board
    var t :String = "";
    var c :UInt = 0;

    g = shape.graphics;

    g.clear();
    g.beginFill(0x000000, 0);
    g.lineStyle(1, 0x555555, 1);

    eachBlock(render_eachBlock);

    g.endFill();
    g.lineStyle(0, 0 ,0);

    changed = false;

  }

  private function render_eachBlock( col :Int, row :Int ) :Void
  {
    
    var c :Int; 

    if (t != getBlock(col, row))
    {
      
      t = getBlock(col, row);

      if (t != BlockTypes.NONE)
      {
        c = BlockTypes.getColor(t);
        g.endFill();
        g.beginFill(c, 1);
      }

    }

    if (t != BlockTypes.NONE) 
      render_drawBlock(col, row);

  }
  


  private function render_drawBlock( col :Int, row :Int ) :Void
  {

    var x = bounds.x + (col * BlockDrop.TILE_SIZE);
    var y = bounds.y + (row * BlockDrop.TILE_SIZE);

    g.drawRect(x, y, BlockDrop.TILE_SIZE, BlockDrop.TILE_SIZE);

  }


  // ----------------------------------------
  // 
  // Properties
  // 
  // ----------------------------------------

  private function get_x() :Int return Math.floor(bounds.x);
  private function set_x( value :Int ) :Int return Math.floor(bounds.x = value);
  private function get_y() :Int return Math.floor(bounds.y);
  private function set_y( value :Int ) :Int return Math.floor(bounds.y = value);
  private function get_width() :Int return Math.floor(bounds.width);
  private function set_width( value :Int ) :Int return Math.floor(bounds.width = value);
  private function get_height() :Int return Math.floor(bounds.height);
  private function set_height( value :Int ) :Int return Math.floor(bounds.height = value);


}
