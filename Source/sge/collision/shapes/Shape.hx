package sge.collision.shapes;

import openfl.display.Graphics;
import sge.collision.AABB;
import sge.collision.ray.Ray;
import sge.collision.ray.RayCollision;
import sge.geom.Transform;
import sge.geom.Vector;

class Shape
{

  public var transform :Transform;

  public var offset (get, set) :Vector;
  public var offsetX (get, set) :Float;
  public var offsetY (get, set) :Float;

  // accessors only
  public var x (get, never) :Float;
  public var y (get, never) :Float;

  public var position (get, never) :Vector;

  public var width (get, never) :Float;
  public var height (get, never) :Float;


  public function new( offsetX :Float = 0, offsetY :Float = 0 ) 
  { 
    _offset = new Vector(offsetX, offsetY);
    _bounds = new AABB();
  }

  public function setBounds( aabb :AABB ) :Void  _bounds = aabb;

  public function test( shape :Shape, ?collision :ShapeCollision ) : ShapeCollision return null;

  public function testCircle( circle :Circle, ?collision :ShapeCollision, flip :Bool = false ) : ShapeCollision return null;

  public function testPolygon( polygon :Polygon, ?collision :ShapeCollision, flip :Bool = false ) : ShapeCollision return null;

  public function testRay( ray :Ray ) : RayCollision return null;

  public function debug_render( graphics :Graphics ) :Void return;

  public function destroy() :Void offset = null;


  inline private function get_offset() :Vector return _offset;
  inline private function set_offset( offset :Vector ) :Vector return _offset = offset;

  inline private function get_offsetX() :Float return offset.x;
  inline private function set_offsetX( offsetX :Float ) :Float return offset.x = offsetX;
  inline private function get_offsetY() :Float return offset.y;
  inline private function set_offsetY( offsetY :Float ) :Float return offset.y = offsetY;

  inline private function get_x() :Float return ( (transform != null) ? transform.x + offsetX : offsetX );
  inline private function get_y() :Float return ( (transform != null) ? transform.y + offsetY : offsetY );

  inline private function get_position() :Vector return ( (transform != null) ? transform.position.clone().add_values(offsetX, offsetY) : offset.clone() );


  private function get_width()  :Float return _bounds.width;
  private function get_height() :Float return _bounds.height;
  

  private var _offset :Vector;
  private var _bounds :AABB;

}