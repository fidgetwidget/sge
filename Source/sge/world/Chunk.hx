package sge.world;

import openfl.display.BitmapData;
import openfl.errors.Error;
import openfl.errors.RangeError;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import sge.graphics.RenderTarget;
import sge.graphics.TileFrame;
import sge.tiles.Tile;
import sge.tiles.TilePool;
import sge.tiles.TILE_LAYERS;
import sge.tiles.TILE_VALUES;

// A Simple render object that is neighbor aware
class Chunk extends RenderTarget {


  // x :Int
  
  // y :Int
  
  // z :Int

  // bitmapData :BitmapData

  // dirty :Bool

  public var frame (get, never) :TileFrame;

  public var tiles :Array<Tile>;
  
  public var dirtyFrames :Array<TileFrame>;
  

  public function new() 
  { 
    super();
    _target = new Point();
    _tileRect = new Rectangle(0, 0, TILE_VALUES.TILE_WIDTH, TILE_VALUES.TILE_HEIGHT);

    initBitmapData(WORLD_VALUES.CHUNK_WIDTH, WORLD_VALUES.CHUNK_HEIGHT);

    tiles = [];
    dirtyFrames = [];
  }


  override public function dispose() :Void
  {
    super.dispose();
    for (i in 0...tiles.length)
    {
      tiles[i].dispose();
      tiles[i] = null;
    }

    ChunkPool.instance.push(this);
  }


  public function init( x :Int, y :Int, z :Int ) :Void
  {
    _frame.x = x;
    _frame.y = y;
    _frame.z = z;
    _dirty = true;

    init_tiles();
  }


  public inline function getTile( x :Float, y :Float, parent :RenderTarget ) :Tile
  {
    // trace('Chunk:getTile( $x, $y, $parent )');

    ti = getTileIndex(x, y, parent);

    if (tiles.length <= ti) throw new RangeError('Chunk:getTile $x $y $parent [$ti] out of bounds.');

    return tiles[ti];
  }


  public function setTile( x :Float, y :Float, type :UInt, parent :RenderTarget ) :Bool
  {
    // trace('Chunk:setTile( $x, $y, $type, $parent )');

    ti = getTileIndex(x, y, parent);
    
    if (tiles.length <= ti) throw new RangeError('Chunk:setTile $x $y $parent [$ti] out of bounds.');

    tile = tiles[ti];
    if (tile.type == type)
      return false;

    tile.type = type;
    dirtyFrames.push(tile.frame);

    _dirty = true;
    return true;
  }
  // var ti :Int
  // var tile :Tile


  public function touchTile( x :Float, y :Float, parent :RenderTarget ) :Void
  {
    // trace('Chunk:touchTile( $x, $y, $parent )');

    ti = getTileIndex(x, y, parent);

    if (tiles.length <= ti) throw new RangeError('Chunk:touchTile $x $y $parent [$ti] out of bounds.');

    tile = tiles[ ti ];
    dirtyFrames.push(tile.frame);

    _dirty = true;
  }
  // var ti :Int
  // var tile :Tile



  inline function init_tiles() :Void
  {
    ix = iy = 0;

    while (ix < WORLD_VALUES.CHUNK_TILES_WIDE)
    {
      while (iy < WORLD_VALUES.CHUNK_TILES_HIGH)
      {
        ti = (iy * WORLD_VALUES.CHUNK_TILES_WIDE) + ix;
        tiles[ti] = createTile(ix, iy);
        dirtyFrames.push(tiles[ti].frame);
        iy++;
      }
      iy = 0;
      ix++;
    }
  }


  inline function createTile(x :Int, y :Int) :Tile
  {
    // trace('Chunk:createTile( $x, $y )');

    var xx :Int, yy :Int;
    var tile :Tile;
    
    tile = TilePool.instance.get();
    xx = x * TILE_VALUES.TILE_WIDTH;
    yy = y * TILE_VALUES.TILE_HEIGHT;

    tile.init(xx, yy);
    tile.z = z;
    return tile;
  }


  inline function getTileIndex( x :Float, y :Float, parent :RenderTarget ) :Int
  {
    return tile_index( x - this.x - parent.x, y - this.y - parent.y );
  }



  inline function tile_index( x :Float, y :Float ) :Int 
  {
    if (x < 0 || x > WORLD_VALUES.CHUNK_WIDTH || y < 0 || y > WORLD_VALUES.CHUNK_HEIGHT) 
    {
      throw new Error('Chunk:tile_index $x $y Out of Bounds. $this');
    }

    ix = Math.floor(x / TILE_VALUES.TILE_WIDTH);
    iy = Math.floor(y / TILE_VALUES.TILE_HEIGHT);

    return (iy * WORLD_VALUES.CHUNK_TILES_WIDE) + ix;
  }
  // var ix :Int
  // var iy :Int


  override function updateBitmapData() :Void
  {
    while( dirtyFrames.length > 0) 
    {
      df = dirtyFrames.pop();
      _target.x = df.x;
      _target.y = df.y;
      _frame.bitmapData.copyPixels(df.bitmapData, _tileRect, _target);
    }
    _dirty = false;
  }
  // var df :TileFrame


  var tile :Tile;
  var df :TileFrame;
  var ti :Int;
  var ix :Int;
  var iy :Int;
  var _target :Point;
  var _tileRect :Rectangle;


  inline function get_frame() :TileFrame 
  {
    if (_dirty) 
      updateBitmapData(); 

    return _frame;  
  }

  inline function toString() :String return 'Chunk{ x:$x y:$y z:$z }';

}
