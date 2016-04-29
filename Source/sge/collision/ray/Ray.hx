package sge.collision.ray;

import sge.geom.Vector;

class Ray
{
  
  public var start :Vector;

  public var end :Vector;

  public var infinite :Bool;

  public var direction (get, never) :Vector;


  public function new( start :Vector, end :Vector, infinite :Bool = false ) 
  { 
    this.start = start;
    this.end = end;
    this.infinite = infinite;

    _direction = new Vector(end.x - start.x, end.y - start.y);
  }


  inline private function get_direction() :Vector
  {
    _direction.x = end.x - start.x;
    _direction.y = end.y - start.y;

    return _direction;
  }

  private var _direction :Vector;

}