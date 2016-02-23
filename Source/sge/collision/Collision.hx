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
    var _clone = new Collision();
    return _clone.copy_from(this);
  }


  inline function copy_from( collision :Collision ) :Collision
  {
    px = collision.px;
    py = collision.py;
    return this;
  }

  inline function get_xval() :Float return Math.abs(px);
  inline function get_xdir() :Int return px > 0 ? 1 : -1;

  inline function get_yval() :Float return Math.abs(py);
  inline function get_ydir() :Int return py > 0 ? 1 : -1;

  public function toString() :String 
  {
    return 'collision{ px: $px, py: $py }';
  }


  public static function getSmallest( array :Array<Collision> ) :Collision
  {
    var smallest = new Collision();
    if (array.length == 0) return smallest;
    
    var xdir = 0;
    var xval = 0.0;
    var ydir = 0;
    var yval = 0.0;
    var collision = array.pop();

    smallest.px = collision.px;
    smallest.py = collision.py;

    while(array.length > 0)
    {
      collision = array.pop().smallest();
      
      if (collision.px != 0) 
      {
        xval = Math.min(smallest.xval, collision.xval);
        xdir = (xval == smallest.xval ? smallest.xdir : collision.xdir);
        smallest.px = xval * xdir;
      }
      if (collision.py != 0) 
      {
        yval = Math.min(smallest.yval, collision.yval);
        ydir = (yval == smallest.yval ? smallest.ydir : collision.ydir);
        smallest.py = yval * ydir;
      }
    }

    return smallest;
  }

}