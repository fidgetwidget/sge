package sge.collision.sat.shapes;

import openfl.display.Graphics;
import sge.collision.AABB;
import sge.collision.sat.ray.Ray;
import sge.collision.sat.ray.RayCollision;
import sge.geom.Vector;


class Circle extends Shape
{

  // parent properties
  // public var transform :Transform;
  
  public var radius (get, never) :Float;

  public var transformedRadius (get, never) :Float;



  public function new( x :Float, y :Float, radius :Float ) 
  { 
    super(x, y);
    _radius = radius;
    _bounds.halfWidth = _bounds.halfHeight = _radius;
  }

  override public function test( shape :Shape, ?collision :ShapeCollision ) : ShapeCollision 
  {
    return shape.testCircle(this, collision, true);
  }

  override public function testCircle( circle :Circle, ?collision :ShapeCollision, flip :Bool = false ) : ShapeCollision 
  {
    var c1 = flip ? circle : this;
    var c2 = flip ? this : circle;

    return SAT2D.testCircleVsCircle( c1, c2, collision );
  }

  override public function testPolygon( polygon :Polygon, ?collision :ShapeCollision, flip :Bool = false ) : ShapeCollision 
  {
    return SAT2D.testCircleVsPolygon( this, polygon, collision, flip );
  }

  override public function testRay( ray :Ray ) : RayCollision 
  {
    return SAT2D.testRayVsCircle(ray, this);
  }


  override public function debug_render( graphics :Graphics ) : Void
  {
    graphics.drawCircle(x, y, radius);
  }


  inline private function get_radius() :Float return _radius;

  inline private function get_transformedRadius() :Float return _radius * transform.scale.x;


  private var _radius :Float = 0;

}