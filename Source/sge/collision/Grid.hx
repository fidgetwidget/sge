package sge.collision;

import sge.Lib;


class Grid
{

  public var x :Float;
  public var y :Float;
  public var width (get, never) :Float;
  public var height (get, never) :Float;

  public var cellWidth (get, set) :Float;
  public var cellHeight (get, set) :Float;

  public var cols :Int;
  public var rows :Int;


  public function new()
  { 
    gridCells = new Array<Int>();
  }

  public function init() : Void
  {

    for (row in 0...rows)
    {
      for (col in 0...cols)
      {
        // row, then col so the index will be 0...length
        set(col, row, DIRECTION.NONE);
      } // for col(x)
    } // for row(y)

  }

  // 
  // Get & Set Grid Values
  // 

  inline public function set( col :Int, row :Int, value :Int ) :Void  
  {
    gridCells[getIndex(col, row)] = value;
  }

  inline public function get( col :Int, row :Int ) :Int  
  {
    return gridCells[getIndex(col, row)];  
  }

  public function set_at( x:Float, y:Float, value :Int ) :Void
  {

    if (!inBounds(x, y)) return;

    return set( getCol(x), getRow(y), value );

  }

  public function get_at( x:Float, y:Float ) :Int
  {

    if (!inBounds(x, y)) return -1;

    return get( getCol(x), getRow(y) );

  }



  // 
  // Collision Functions
  // 
  
  // Test if the position (x,y) is in the bounds of the grid
  inline public function inBounds( x:Float, y:Float ) :Bool
  {
    return (x >= this.x &&
            x <= this.x + this.width &&
            y >= this.y && 
            y <= this.y + this.height)
  }

  public function collision_point( x :Float, y :Float, collision :Collision ) :Bool
  {
    if (! inBounds(x, y)) return false;

    var col = getCol(x);
    var row = getRow(y);
    var dir = get( col, row );

    if (dir == DIRECTION.NONE) return false; // no direction, no collision

    var cx = this.x + (col * cellWidth) + halfWidth;
    var cy = this.y + (row * cellHeight) + halfHeight;

    var cellAABB = AABB.make(cx, cy, halfWidth, halfHeight);

    if ( cellAABB.collision_point(x, y, collision) )
    {

      if (collision != null) adjustCollision( dir, collision );
      
      return true;

    }

    return false;

  }

  public function collision_aabb( aabb :AABB, collision :Collision ) :Bool
  {

    var t :Int = getRow(aabb.top);
    var r :Int = getCol(aabb.right);
    var b :Int = getRow(aabb.bottom);
    var l :Int = getCol(aabb.left);

    var px :Float = 0;
    var py :Float = 0;

    var collide = false;

    for (col in l..r)
    {

      for (row in t..b)
      {

        if ( collision_aabb_tile( col, row, aabb, collision) )
        {
          if (collision)
          {
            px += collision.px;
            py += collision.py;  
          }
          collide = true;
        }

      } // for row

    } // for col

    if (collide && collision != null)
    {
      collision.smallest();
    }

    return collide;

  }

  public function collision_circle( x :Float, y :Float, radius :Float, ?collision :Collision ) :Bool
  {

    var l :Int = getCol(x - radius);
    var t :Int = getRow(y - radius);
    var r :Int = getCol(x + radius);
    var b :Int = getRow(y + radius);

    var px :Float = 0;
    var py :Float = 0;

    var collide = false;

    for (col in l..r)
    {

      for (row in t..b)
      {

        if ( collision_circle_tile( col, row, x, y, radius, collision) )
        {
          if (collision != null )
          {
            if (px == 0) px = collision.px
            else px = Math.min(px, collision.px)

            if (py == 0) py = collision.py
            else py = Math.min(py, collision.py)  
          }
          collide = true;
        }

      } // for row

    } // for col

    if (collide && collision != null)
    {
      collision.px = px;
      collision.py = py;
      collision.smallest();
    }

    return collide;

  }



  private function collision_aabb_tile( col :Int, row :Int, aabb :AABB, collision :Collision ) :Bool
  {
    if (col < 0 || col > cols || row < 0 || row > rows) return false;

    var dir = get( col, row );

    if (dir == DIRECTION.NONE) return false; // no direction, no collision

    var cx = this.x + (col * cellWidth) + halfWidth;
    var cy = this.y + (row * cellHeight) + halfHeight;

    var tileAABB = AABB.make(cx, cy, halfWidth, halfHeight);

    if ( tileAABB.collision_aabb(aabb, collision) )
    {

      if (collision != null) adjustCollision( dir, collision );
      
      return true;

    }

    return false;
  }

  private function collision_circle_tile( 
    col :Int, row :Int, 
    x :Float, y:Float, radius :Float, 
    collision :Collision ) :Bool
  {
    if (col < 0 || col > cols || row < 0 || row > rows) return false;

    var dir = get( col, row );

    if (dir == DIRECTION.NONE) return false; // no direction, no collision

    var cx = this.x + (col * cellWidth) + halfWidth;
    var cy = this.y + (row * cellHeight) + halfHeight;

    var tileAABB = AABB.make(cx, cy, halfWidth, halfHeight);

    if ( tileAABB.collision_circle(x, y, radius, collision) )
    {

      if (collision != null) adjustCollision( dir, collision );
      
      return true;

    }

    return false;
  }

  // 
  // Render
  // 

  public function debug_render( g :Graphics ) :Void
  {

    var dir :Int;
    var xx :Float;
    var yy :Float;

    for (col in 0...cols)
    {
      for (row in 0...rows)
      {

        dir = get(col, row);
        xx = x + (col * cellWidth);
        yy = y + (row * cellHeight);

        // if its solid, render rectangle
        if (dir == DIRECTION.ALL) {
          g.drawRect(xx, yy, cellWidth, cellHeight);
          continue;
        }
        
        // for each side, render a line
        if (dir & DIRECTION.UP > 0) {
          g.moveTo(xx,              yy);
          g.lineTo(xx + cellWidth, yy);
        }

        if (dir & DIRECTION.RIGHT > 0) {
          g.moveTo(xx + cellWidth, yy);
          g.lineTo(xx + cellWidth, yy + cellHeight);
        }

        if (dir & DIRECTION.DOWN > 0) {
          g.moveTo(xx + cellWidth, yy + cellHeight);
          g.lineTo(xx,              yy + cellHeight);
        }

        if (dir & DIRECTION.LEFT > 0) {
          g.moveTo(xx,              yy + cellHeight);
          g.lineTo(xx,              yy);
        }

      } // for x
    } // for y

  }



  // 
  // Helpers
  // 

  private function adjustCollision( dir :Int, collision :Collision ) :Void
  {

    if (dir != DIRECTION.ALL)
    {
      // is LEFT or RIGHT present
      if (dir & DIRECTION.HORIZONTAL > 0) 
      {
        // check if its only Left, or only Right
        if ((dir & DIRECTION.LEFT == 0 && collision.px < 0) ||
            (dir & DIRECTION.RIGHT == 0 && collision.px > 0) )
          collision.px *= -1;
      }
      else collision.px = 0;

      // is UP or DOWN present
      if (dir & DIRECTION.VERTICAL > 0) 
      {
        // check if we need to reverse the direction
        if ((dir & DIRECTION.UP == 0 && collision.py < 0) ||
            (dir & DIRECTION.DOWN == 0 && collision.py > 0) )
          collision.py *= -1; 
      }
      else collision.py = 0;

    }

  }

  inline private function getIndex( col :Int, row :Int ) :Int  return col + (row * cols);

  inline private function getCol( x :Float ) :Int return Lib.remainder_int(x, cols);

  inline private function getRow( y :Float ) :Int return Lib.remainder_int(y, cols);



  // 
  // Properties
  // 

  inline private function get_width() :Float  return cols * cellWidth;

  inline private function get_height() :Float  return rows * cellHeight;

  inline private function get_cellWidth() :Int return _cellWidth;

  inline private function set_cellWidth( value :Int ) 
  {
    halfWidth = value * 0.5; 
    return _cellWidth = value;
  }

  inline private function get_cellHeight() :Int return _cellHeight;

  inline private function get_cellHeight( value :Int ) 
  {
    halfHeight = value * 0.5; 
    return _cellHeight = value;  
  }
  

  private var _cellWidth :Int;
  private var _cellHeight :Int;
  private var halfWidth :Float;
  private var halfHeight :Float;
  private var gridCells :Array<Int>;
  

}