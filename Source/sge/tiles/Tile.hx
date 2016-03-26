package sge.tiles;

import haxe.ds.Vector;
import openfl.display.BitmapData;
import openfl.errors.Error;
import sge.graphics.RenderTarget;
import sge.graphics.TileFrame;
import sge.graphics.TileRenderer;


// A Simple render object that is neighbor aware
class Tile extends RenderTarget {

  public static var renderer :TileRenderer;


  // x :Int
  
  // y :Int
  
  // z :Int

  // bitmapData :BitmapData

  // dirty :Bool

  public var type (get, set) :UInt;

  public var neighborTypes (get, never) :Vector<UInt>; // the 4 direction neighbor types

  public var neighbors (get, set) :UInt; // 4 direction neighbor state

  public var corners (get, set) :UInt; // 8 direction neighbor state

  public var frame (get, never) :TileFrame; // the static tile details
  

  public function new() 
  { 
    super();
    _neighborTypes = new Vector(4);
    initBitmapData(TILE_VALUES.TILE_WIDTH, TILE_VALUES.TILE_HEIGHT);
  }


  override public function dispose() :Void
  {
    super.dispose();
    _type = 0;
    _neighbors = 0;
    _dirty = true;
    
    TilePool.instance.push(this);
  }


  public function init( x :Int, y :Int, type :UInt = TILE_TYPES.NONE, neighbors :UInt = NEIGHBORS.NONE, z :Int = TILE_LAYERS.DEFAULT ) :Void
  {
    _frame.x = x;
    _frame.y = y;
    _frame.z = z;
    _type = type;
    _neighbors = neighbors;
    init_neighborTypes();
    _dirty = true;
  }


  public function setNeighborType( side :Int, type :UInt ) :Void
  {
    si = TILE_VALUES.NEIGHBOR_TYPES.indexOf(side);
    _neighborTypes.set(si, type);

    if (_type != TILE_TYPES.NONE) _dirty = true;
  }


  override function updateBitmapData() :Void
  {
    if (Tile.renderer == null) 
      throw new Error("Tile.updateBitmapData() Tile Renderer not found.");

    if (_type == TILE_TYPES.NONE)
    {
      Tile.renderer.clearBitmapData(_frame.bitmapData);
    }
    else
    {
      Tile.renderer.updateTileFrame(_frame, _type, _neighbors);
      Tile.renderer.updateTileFrame_sides(_frame, _type, _neighborTypes, z);
    }
    _dirty = false;
  }



  inline function init_neighborTypes() :Void
  {
    _neighborTypes.set(0, TILE_TYPES.NONE);
    _neighborTypes.set(1, TILE_TYPES.NONE);
    _neighborTypes.set(2, TILE_TYPES.NONE);
    _neighborTypes.set(3, TILE_TYPES.NONE);
  }

  var si :Int;

  // 
  // Properties
  // 

  var _type       :UInt;
  var _neighbors  :UInt;
  var _neighborTypes :Vector<UInt>;
  var _corners    :UInt;

  override function set_z( value :Int ) :Int
  {
    if (_frame.z != value)
    {
      _frame.z = value;
      _dirty = true;
    }
    return _frame.z;
  }

  inline function get_type() :UInt return _type;
  inline function set_type( value :UInt ) :UInt
  {
    if (_type != value)
    {
      _type = value;
      _dirty = true;  
    }
    return _type;
  }

  inline function get_neighborTypes() :Vector<UInt> return _neighborTypes;

  inline function get_neighbors() :Int return _neighbors;
  inline function set_neighbors( value :UInt ) :UInt
  {
    if (_neighbors != value)
    {
      _neighbors = value;
      if (_type != TILE_TYPES.NONE) _dirty = true;
    }
    return _neighbors;
  }


  inline function get_corners() :UInt return _corners;
  inline function set_corners( value :UInt ) :UInt
  {
    if (_corners != value)
    {
      _corners = value;
      if (_type != TILE_TYPES.NONE) _dirty = true;
    }
    return _corners;
  }  


  inline function get_frame() :TileFrame
  {
    if (_dirty) updateBitmapData();
    return _frame;
  }

  inline function toString() :String return 'Tile{ x:$x y:$y z:$z type:$_type neighbors:$_neighbors }';

}
