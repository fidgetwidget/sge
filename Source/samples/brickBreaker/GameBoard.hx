package samples.brickBreaker;


import openfl.display.Shape;
import openfl.display.Graphics;
import sge.Game;
import sge.Lib;
import sge.collision.AABB;
import sge.collision.Collision;


class GameBoard 
{

  private var BRICK_WIDTH   :Int = 40;
  private var BRICK_HEIGHT  :Int = 20;
  private var BRICK_SPACING :Int = 10;


  public var shape :Shape;
  public var bounds :AABB;
  public var brickBounds :AABB;
  public var bricks :Array<Array<Int>>;
  public var bricksCount :Int;
  public var rows :Int;
  public var cols :Int;
  public var spacing :Int;
  


  public function new() 
  { 

    bricks = new Array();
    shape  = new Shape();
    _aabb = new AABB();

  }


  public function init() :Void
  {
    
    var sw = Game.root.stage.stageWidth;
    var sh = Game.root.stage.stageHeight;

    var cx = sw * 0.5;    // scene center
    var cy = sh * 0.5;    
    var halfWidth = 250;  // 500 wide
    var halfHeight = 400; // 800 high

    bounds = AABB.make( cx, cy, halfWidth, halfHeight );
    brickBounds = AABB.make_rect( bounds.left + 30, bounds.top + 30, bounds.width - 60, 110 );

    cols = Math.floor((brickBounds.width + BRICK_SPACING) / (BRICK_WIDTH + BRICK_SPACING));
    rows = Math.floor((brickBounds.height + BRICK_SPACING) / (BRICK_HEIGHT + BRICK_SPACING));

    _aabb.width = BRICK_WIDTH;
    _aabb.height = BRICK_HEIGHT;

  }



  public function resetBricks() :Void
  {

    bricksCount = cols * rows;

    eachBrick(resetBricks_eachBrick);

  }


  public function collision_ball( x :Float, y :Float, r :Float, ?collision :Collision ) :Collision
  {

    collision = collision == null ? new Collision() : collision.reset();

    if (x - r < bounds.left || x + r > bounds.right || 
        y - r < bounds.top || y + r > bounds.bottom)
    {
      
      if (x - r < bounds.left) 
        collision.px = bounds.left - (x - r);

      if (x + r > bounds.right)
        collision.px = bounds.right - (x + r);

      if (y - r < bounds.top) 
        collision.py = bounds.top - (y - r);

      if (y + r > bounds.bottom)
        collision.py = bounds.bottom - (y + r);
      
      return collision;

    }

    if (brickBounds.collision_circle(x, y, r))
    {
      var collide :Bool = false;
      
      _aabb.reset();

      var t :Int = getRow(y - r);
      var r :Int = getCol(x + r);
      var b :Int = getRow(y + r);
      var l :Int = getCol(x - r);

      for (col in l...r)
      {

        for (row in t...b)
        {

          if ( collision_ball_brick( col, row, x, y, r, collision) )
          {

            // if (px == 0) 
            //   px = collision.px;
            // else 
            //   px = Math.min(px, collision.px);

            // if (py == 0) 
            //   py = collision.py;
            // else 
            //   py = Math.min(py, collision.py);

            collide = true;
          }

        } // for row

      } // for col

      if (collide)
      {
        // collision.px = px;
        // collision.py = py;
        collision.smallest();

        return collision;
      }

    }

    return null;

  }

  public function collision_paddle( paddle :AABB, ?collision :Collision ) :Collision
  {

    if (paddle.left < bounds.left || paddle.right > bounds.right)
    {

      if (paddle.left < bounds.left) {
        collision.px = bounds.left - paddle.left;
      }

      if (paddle.right > bounds.right) {
        collision.px = bounds.right - paddle.right;
      }

      return collision;

    }

    return null;

  }

  private var _aabb :AABB;



  // 
  // Get the block type at a given position
  // 
  public function getBrick( col :Int, row :Int ) :Int
  {
    
    if (coord_outOfBoundsCheck(col, row)) return 0;

    return bricks[col][row];

  }

  // 
  // Set the block type at a given position
  // 
  public function setBrick( col :Int, row :Int, value :Int ) :Void
  {

    if (coord_outOfBoundsCheck(col, row)) return;

    if (bricks.length - 1 < col) return;
    if (bricks[col].length - 1 < row) return;

    bricks[col][row] = value;
    changed = true;
    
  }

  // 
  // Draw the board (only have to re-darw it when it changes)
  // 
  public function render() :Void
  {
    changed = true;

    if (changed)
    {
      render_drawBricks();
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


  private function eachBrick( func : Int -> Int -> Void ) :Void
  {

    for (col in 0...cols)
    {
      
      for (row in 0...rows)
      {
        
        func( col, row );

      }

    }

  }


  private function resetBricks_eachBrick( col :Int, row :Int ) :Void
  {

    if (bricks.length - 1 < col) bricks[col] = new Array();
    bricks[col][row] = 1;

  }


  private function render_drawBricks() :Void
  {

    g = shape.graphics;

    g.clear();
    g.beginFill(0x000000, 0);
    g.lineStyle(1, 0x555555, 1);

    eachBrick(render_eachBrick);

    g.endFill();
    g.lineStyle(0, 0 ,0);

    changed = false;

  }


  private function render_eachBrick( col :Int, row :Int ) :Void
  {
    
    var b = getBrick(col, row);

    if (b == 0) return;

    var bx = bounds.x + (col * BRICK_WIDTH);
    bx += col > 0 ? col * BRICK_SPACING : 0;
    var by = bounds.y + (row * BRICK_HEIGHT);
    by += row > 0 ? row * BRICK_SPACING : 0;

    g.drawRect(bx, by, BRICK_WIDTH, BRICK_HEIGHT);

  }


  private function collision_ball_brick( col :Int, row :Int, x :Float, y :Float, r :Float, collision :Collision ) :Bool
  {
    var b = getBrick(col, row);
    if (b == 0) return false;
    
    var bx = bounds.x + (col * BRICK_WIDTH);
    bx += col > 0 ? col * BRICK_SPACING : 0;
    var by = bounds.y + (row * BRICK_HEIGHT);
    by += row > 0 ? row * BRICK_SPACING : 0;

    _aabb.x = bx;
    _aabb.y = by;

    return _aabb.collision_circle(x, y, r, collision);
  }


  private function coord_outOfBoundsCheck( col :Int, row :Int ) :Bool
  {
    return (col < 0 || col > cols - 1 || row < 0 || row > rows - 1);
  }


  inline private function getCol( x :Float ) :Int return Math.floor( Lib.remainder_float(x, cols) );
  inline private function getRow( y :Float ) :Int return Math.floor( Lib.remainder_float(y, cols) );


}
