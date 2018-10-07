package sge.collision;

import sge.geom.Vector;


// 
// Simple collision information (aabb and point, aabb and aabb, aabb and circle, etc)
// 
@:publicFields
class Collision
{

  // penetration depth vector
  var px :Float;
  var py :Float;

  var hit (get, never) :Bool;

  var xval (get, never) :Float;
  var xdir (get, never) :Int;

  var yval (get, never) :Float;
  var ydir (get, never) :Int;


  function new ( px :Float = 0, py :Float = 0 )
  {
    this.px = px;
    this.py = py;
  }

  // remove the larger vector
  function smallest() :Collision
  {
    if (px == 0 || py == 0)
      return this;

    if (Math.abs(px) > Math.abs(py))
      px = 0;
    else
      py = 0;

    return this;
  }


  inline function reset() :Collision
  {
    px = py = 0.0;
    return this;
  }


  inline function clone() :Collision
  {
    var c = new Collision();
    return c.copy_from(this);
  }


  inline function copy_from( collision :Collision ) :Collision
  {
    px = collision.px;
    py = collision.py;
    return this;
  }


  inline function get_hit() :Bool return !(px == 0 && py == 0);

  inline function get_xval() :Float return Math.abs(px);
  inline function get_xdir() :Int return px > 0 ? 1 : -1;

  inline function get_yval() :Float return Math.abs(py);
  inline function get_ydir() :Int return py > 0 ? 1 : -1;


  public function toString() :String 
  {
    return 'collision{ px: $px, py: $py }';
  }


  // --------------------------------------------------
  // Static Methods & Properties
  // --------------------------------------------------

  public static var empty :Collision = new Collision();

  public static function getSmallest( all :Array<Collision>, result :Collision = null ) :Collision
  {
    if (all.length == 0) return empty;
    var col :Collision;

    if (result == null) result = new Collision();
    
    _xdir = 0;
    _xval = 0.0;
    _ydir = 0;
    _yval = 0.0;
    col = all.pop();

    result.px = col.px;
    result.py = col.py;

    while(all.length > 0)
    {
      col = all.pop().smallest();
      
      if (col.px != 0) 
      {
        _xval = Math.min(result.xval, col.xval);
        _xdir = (_xval == result.xval ? result.xdir : col.xdir);
        result.px = _xval * _xdir;
      }
      if (col.py != 0) 
      {
        _yval = Math.min(result.yval, col.yval);
        _ydir = (_yval == result.yval ? result.ydir : col.ydir);
        result.py = _yval * _ydir;
      }
    }

    return result;
  }
  static var _xval :Float;
  static var _xdir :Int;
  static var _yval :Float;
  static var _ydir :Int;

}