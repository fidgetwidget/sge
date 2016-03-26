package sge.graphics;

import openfl.display.BitmapData;


// A Simple render object that is neighbor aware
class RenderTarget {


  // basically Tile Data
  public var x (get, set) :Int;

  public var y (get, set) :Int;

  public var z (get, set) :Int;

  public var bitmapData (get, never) :BitmapData;

  public var dirty (get, never) :Bool;
  

  public function new()
  {
    _frame = {
      x: 0,
      y: 0,
      z: 0,
      bitmapData: null
    };
    _dirty = true;
  }

  public function dispose() :Void
  {
    _frame.x = 0;
    _frame.y = 0;
    _frame.z = 0;
    _frame.bitmapData = null;
    _dirty = true;
  }

  // Q: should I setup a bitmapData pool?
  function initBitmapData( width :Int, height :Int ) :Void
    _frame.bitmapData = new BitmapData(width, height, true, 0);
  
  function updateBitmapData() :Void 
    _dirty = false;

  
  var _dirty :Bool;
  var _frame :TileFrame;

  inline function get_x() :Int return _frame.x;
  function set_x(value :Int) :Int return _frame.x = value;

  inline function get_y() :Int return _frame.y;
  function set_y(value :Int) :Int return _frame.y = value;

  inline function get_z() :Int return _frame.z;
  function set_z(value :Int) :Int return _frame.z = value;

  inline function get_bitmapData() :BitmapData
  {
    if (_dirty) updateBitmapData();
    return _frame.bitmapData;
  }

  function get_dirty() :Bool return _dirty;

}
