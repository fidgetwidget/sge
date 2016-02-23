package samples.blockDrop;


import openfl.display.Shape;
import openfl.display.Graphics;
import sge.geom.base.Coord;

class Block {

  public var x :Int; // the top left corner position col,row
  public var y :Int;
  public var blocks :Array<Int>; // block state for all four directions
  public var direction :Int; // the current direction
  public var color :Int; // the color of the block type
  public var shape :Shape;

  public var type :String;

  // render offset
  public var offset (get, set) :Coord;
  public var offsetX (get, set) :Int;
  public var offsetY (get, set) :Int;


  public function new() 
  { 

    offset = { x: 0, y: 0 }
    shape = new Shape();
    init();

  }


  public inline function init() :Void
  {

    x = 0;
    y = 0;
    direction = 0;
    changed = true;

  }


  public function set( x :Int, y :Int, type :String, direction :Int = 0 )
  {
    this.x      = x;
    this.y      = y;
    this.blocks = BlockTypes.getBlocks(type);
    this.color  = BlockTypes.getColor(type);
    this.direction = direction;
    this.type = type;
    changed = true;
  }



  // dir: +1 or -1
  public function rotate( dir :Int, collide : Block -> Bool ) :Void
  {

    this.changed = true;
    this.direction += dir;
    correctRotation();

    if (collide(this)) 
    {
      this.direction -= dir;
      correctRotation();
    }

  }

  // move in any direction
  public function move( x :Int, y :Int, collide :Block -> Bool ) :Void
  {

    this.changed = true;
    this.x += x;
    this.y += y;

    if (collide(this)) 
    {
      this.x -= x;
      this.y -= y;
    }

  }


  public function drop( collide :Block -> Bool ) :Bool
  {
    
    this.changed = true;
    this.y++;

    if (collide(this)) 
    {
      this.y--;
      return false;
    }

    return true;

  }


  public function eachBlock( func : Int -> Int -> Void ) :Void
  {
    var _bit = 0x8000;
    var _xx = 0;
    var _yy = 0;
    var _blocks = this.blocks[this.direction];
    
    while (_bit > 0)
    {
      if (_blocks & _bit > 0) 
        func(x + _xx, y + _yy);
      
      _xx++;
      if (_xx == 4) {
        _xx = 0;
        _yy++;
      }

      _bit = _bit >> 1;
    }
  }


  public function render() :Void
  {

    if (!changed || shape == null) return;

    g = shape.graphics;
    g.clear();

    g.beginFill(color, 1);
    g.lineStyle(1, 0x555555, 1);

    this.eachBlock(render_drawBlock);

    g.lineStyle(0, 0x000000, 0);
    g.endFill();

    changed = false;

  }


  // ----------------------------------------
  // 
  // Helpers
  // 
  // ----------------------------------------

  private var changed :Bool = false;
  private var g :Graphics;
  private var _offset :Coord;

  private function correctRotation() :Void
  {
    if (this.direction < 0) this.direction = 3;
    if (this.direction > 3) this.direction = 0;
  }

  private function render_drawBlock( col :Int, row :Int ) :Void
  {

    var x = offsetX + (col * BlockDrop.TILE_SIZE);
    var y = offsetY + (row * BlockDrop.TILE_SIZE);

    g.drawRect(x, y, BlockDrop.TILE_SIZE, BlockDrop.TILE_SIZE);

  }

  private function get_offset() :Coord return _offset;
  private function set_offset( coord :Coord ) :Coord return _offset = coord;

  private function get_offsetX() :Int return _offset.x;
  private function set_offsetX( x :Int ) return _offset.x = x;

  private function get_offsetY() :Int return _offset.y;
  private function set_offsetY( y :Int ) return _offset.y = y;


}
