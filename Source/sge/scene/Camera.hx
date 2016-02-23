package sge.scene;


import sge.collision.AABB;


class Camera {

  public var MIN_SCALE :Float = 0.005;

  public var MAX_SCALE :Float = 5;

  
  public var x (get, set) :Int;

  public var y (get, set) :Int;

  public var centerX (get, set) :Float;

  public var centerY (get, set) :Float;

  public var scale (never, set) :Float;

  public var scaleX (get, set) :Float;

  public var scaleY (get, set) :Float;

  public var bounds :AABB;

  public var left (get, never) :Float;
  public var top (get, never) :Float;
  public var right (get, never) :Float;
  public var bottom (get, never) :Float;

  public var positionChanged (get, set) :Bool;

  public var scaleChanged (get, set) :Bool;


  public function new() 
  {
    bounds = new AABB();
  }


  // 
  // Properties
  // 

  var _x :Int = 0;
  var _y :Int = 0;
  var _positionChanged :Bool = false;
  var _scaleX :Float = 1.0;
  var _scaleY :Float = 1.0;
  var _scaleChanged :Bool = false;

  inline function get_x() :Int  return _x;
  inline function set_x( value :Int ) 
  {
    _positionChanged = true;
    return _x = value;
  }

  inline function get_y() :Int  return _y;
  inline function set_y( value :Int ) 
  {
    _positionChanged = true;
    return _y = value;
  }


  inline function get_centerX() :Float return _x + (bounds.halfWidth * scaleX);
  inline function set_centerX( value :Float ) :Float return _x = Math.floor(value - (bounds.halfWidth / scaleX));

  inline function get_centerY() :Float  return _y + (bounds.halfHeight * scaleY); 
  inline function set_centerY( value :Float ) :Float return _y = Math.floor(value - (bounds.halfHeight / scaleY));

  inline function set_scale( value :Float ) :Float
  {
    if (value < MIN_SCALE) { value = MIN_SCALE; }
    if (value > MAX_SCALE) { value = MAX_SCALE; }
    _scaleChanged = true;
    _scaleX = value;
    _scaleY = value;
    return value;
  }

  inline function get_scaleX() :Float  return _scaleX;
  inline function set_scaleX( value :Float ) :Float
  {
    if (value < MIN_SCALE) { value = MIN_SCALE; }
    if (value > MAX_SCALE) { value = MAX_SCALE; }
    _scaleChanged = true;
    return _scaleX = value;
  }

  inline function get_scaleY() :Float  return _scaleY;
  inline function set_scaleY( value :Float ) :Float
  {
    if (value < MIN_SCALE) { value = MIN_SCALE; }
    if (value > MAX_SCALE) { value = MAX_SCALE; }
    _scaleChanged = true;
    return _scaleY = value;
  }


  inline function get_left() :Float return _x;

  inline function get_top() :Float return _y;

  inline function get_right() :Float return _x + bounds.width;

  inline function get_bottom() :Float return _y + bounds.height;


  inline function get_positionChanged() :Bool 
  {
    if (_positionChanged)
    {
      _positionChanged = false;
      return true;
    }
    return false;
  }
  inline function set_positionChanged( value :Bool ) :Bool return _positionChanged = value;

  inline function get_scaleChanged() :Bool 
  {
    if (_scaleChanged)
    {
      _scaleChanged = false;
      return true;
    }
    return false;
  }
  inline function set_scaleChanged( value :Bool ) :Bool return _scaleChanged = value;

}