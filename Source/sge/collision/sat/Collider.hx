package sge.collision.sat;

import openfl.display.Graphics;
import sge.collision.sat.Collider;
import sge.collision.sat.shapes.Shape;
import sge.collision.sat.shapes.ShapeCollision;
import sge.collision.AABB;
import sge.geom.Transform;
import sge.geom.Matrix;


class Collider
{

  public var isActive : Bool;

  public var transform (get, never) : Transform;
  
  public var shape (get, never) : Shape;

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
    _collision = _collision == null ? _collision = new ShapeCollision() : _collision.reset();
    if ( collider.shape.test(shape, _collision) != null ) return true;
    return false;

  }

  // Render the shape
  public function debug_render( graphics : Graphics ) :Void  _shape.debug_render( graphics );

  inline private function get_transform() :Transform return _transform;

  inline private function get_shape() :Shape return _shape;

  inline private function get_width() :Float return _shape.width;

  inline private function get_height() :Float return _shape.height;

  inline private function get_collision() :ShapeCollision return _collision;

  
  private var _transform :Transform;
  private var _transformMatrix :Matrix;
  private var _shape :Shape;
  private var _collision :ShapeCollision;

}
