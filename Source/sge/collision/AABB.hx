package sge.collision;

import sge.geom.Vector;


class AABB
{

  // 
  // Static Properties
  // 
  public static function make( centerX :Float, centerY :Float, halfWidth :Float, halfHeight :Float ) :AABB
  {
    var aabb :AABB = new AABB();

    aabb.centerX = centerX;
    aabb.centerY = centerY;
    aabb.halfWidth = halfWidth;
    aabb.halfHeight = halfHeight;

    return aabb;
  }

  public static function make_rect( x :Float, y :Float, width :Float, height: Float ) :AABB
  {
    var aabb :AABB = new AABB();

    aabb.halfWidth = width * 0.5;
    aabb.halfHeight = height * 0.5;
    aabb.x = x;
    aabb.y = y;

    return aabb;
  }
  
  // 
  // Instance Object
  // 
  public var x (get, set) :Float;
  public var y (get, set) :Float;
  public var width (get, set) :Float;
  public var height (get, set) :Float;

  public var top (get, never) :Float;
  public var right (get, never) :Float;
  public var bottom (get, never) :Float;
  public var left (get, never) :Float;

  // NOTE: requesting the min/max creates a new vector
  public var min (get, never) :Vector;
  public var max (get, never) :Vector;

  public var centerX (get, set) :Float;
  public var centerY (get, set) :Float;

  public var center (get, set) :Vector;
  
  public var halfWidth (get, set) :Float;
  public var halfHeight (get, set) :Float;
  
  public var halves (get, set) :Vector;


  public function new() 
  { 
    this._center = new Vector();
    this._halves = new Vector();
  }

  public function reset() :AABB
  {
    _center.x = _center.y = 0.0;
    _halves.x = _halves.y = 0.0;
    return this;
  }


  inline public function contains_point( x :Float, y :Float ) :Bool
    return (x > left && x < right) && (y > top && y < bottom);


  public function collision_point( x :Float, y :Float, ?collision :Collision ) :Bool
  {
    return SimpleCollisions.aabb_point_collision( this, x, y, collision );
  }

  public function collision_aabb( aabb :AABB, ?collision :Collision ) :Bool
  {
    return SimpleCollisions.aabb_aabb_collision( this, aabb, collision );
  }

  public function collision_circle( x :Float, y :Float, radius :Float, ?collision :Collision ) :Bool
  {
    return SimpleCollisions.aabb_circle_collision( this, x, y, radius, collision );
  }

  
  inline private function get_x() :Float return _center.x - _halves.x;
  inline private function set_x( value :Float ) :Float {
    _center.x = value - _halves.x; 
    return get_x();
  }
  inline private function get_y() :Float return _center.y - _halves.y;
  inline private function set_y( value :Float ) :Float {
    _center.y = value - _halves.y; 
    return get_y();
  }

  inline private function get_width() :Float return _halves.x * 2;
  inline private function set_width( value :Float ) :Float {
    _halves.x = value * 0.5; 
    return get_width();
  }
  inline private function get_height() :Float return _halves.y * 2;
  inline private function set_height( value :Float ) :Float {
    _halves.y = value * 0.5; 
    return get_height();
  }

  inline private function get_top() :Float return get_y();
  inline private function get_right() :Float return get_x() + get_width();
  inline private function get_bottom() :Float return get_y() + get_height();
  inline private function get_left() :Float return get_x();

  inline private function get_min() :Vector return new Vector(x, y);
  inline private function get_max() :Vector return new Vector(x + width, y + height);

  inline private function get_centerX() :Float return _center.x;
  inline private function set_centerX( value :Float ) :Float return _center.x = value;
  inline private function get_centerY() :Float return _center.y;
  inline private function set_centerY( value :Float ) :Float return _center.y = value;

  inline private function get_center() :Vector return _center;
  inline private function set_center( value :Vector ) :Vector return _center = value;

  inline private function get_halfWidth() :Float return _halves.x;
  inline private function set_halfWidth( value :Float ) :Float return _halves.x = value;
  inline private function get_halfHeight() :Float return _halves.y;
  inline private function set_halfHeight( value :Float ) :Float return _halves.y = value;

  inline private function get_halves() :Vector return _halves;
  inline private function set_halves( value :Vector ) :Vector return _halves = value;


  private var _center :Vector;
  private var _halves :Vector;

  public function toString() :String 
  {
    return 'AABB{ cx: ${_center.x}, cy: ${_center.y}, hw: ${_halves.x}, hh: ${_halves.y} }';
  }

}