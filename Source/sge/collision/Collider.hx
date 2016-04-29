package sge.collision;

import openfl.display.Graphics;
import sge.collision.shapes.Shape;
import sge.collision.shapes.ShapeCollision;
import sge.collision.shapes.ShapeCollisionPool;
import sge.collision.AABB;
import sge.geom.Transform;
import sge.geom.Matrix;


class Collider
{

  public var isActive : Bool;

  public var transform (get, never) : Transform;
  
  public var shape (get, never) : Shape;

  public var left (get, never) :Float;
  public var right (get, never) :Float;
  public var top (get, never) :Float;
  public var bottom (get, never) :Float;

  public var width (get, never) : Float;
  public var height (get, never) : Float;

  public var collision (get, never) : ShapeCollision;


  public function new( transform :Transform, shape :Shape ) 
  {
    _transform = transform;
    _shape = shape;
    _shape.transform = _transform;
  }

  public function setShape( shape :Shape ) :Void
  {
    _shape = shape;
    _shape.transform = _transform; 
  }

  public function setTransform( transform :Transform ) :Void
  {
    _transform = transform;
    _shape.transform = _transform;
  }

  public function test( collider : Collider ) :Bool
  {
    _collision = _collision == null ? _collision = ShapeCollisionPool.instance.get() : _collision.reset();

    return ( collider.shape.test(shape, _collision) != null );
  }

  // Render the shape
  public function debug_render( graphics : Graphics ) :Void  
  {
    _shape.debug_render( graphics );
  }

  inline function get_transform() :Transform return _transform;

  inline function get_shape() :Shape  return _shape;

  inline function get_left() :Float   return _transform.x - (_shape.width * 0.5);
  inline function get_right() :Float  return _transform.x + (_shape.width * 0.5);
  inline function get_top() :Float    return _transform.y - (_shape.height * 0.5);
  inline function get_bottom() :Float return _transform.y + (_shape.height * 0.5);

  inline function get_width() :Float  return _shape.width;
  inline function get_height() :Float return _shape.height;

  inline function get_collision() :ShapeCollision return _collision;

  
  var _transform :Transform;
  var _transformMatrix :Matrix;
  var _shape :Shape;
  var _collision :ShapeCollision;

}
