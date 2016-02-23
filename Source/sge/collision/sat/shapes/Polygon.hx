package sge.collision.sat.shapes;

import openfl.display.Graphics;
import sge.collision.AABB;
import sge.collision.sat.ray.Ray;
import sge.collision.sat.ray.RayCollision;
import sge.geom.Matrix;
import sge.geom.Vector;

class Polygon extends Shape
{

  // parent properties
  // public var transform :Transform;
  // public var offset :Vector;

  public var vertices (get, never) :Array<Vector>;

  public var transformedVertices (get, never) :Array<Vector>;


  public function new( x :Float, y :Float, vertices :Array<Vector> ) 
  { 
    super(x, y);
    _transformedVertices = new Array<Vector>();
    _vertices = vertices;
    _setSize();
  }

  private function _setSize() :Void
  {

    var minX :Float = Math.NEGATIVE_INFINITY;
    var minY :Float = Math.NEGATIVE_INFINITY;
    var maxX :Float = Math.POSITIVE_INFINITY;
    var maxY :Float = Math.POSITIVE_INFINITY;

    for (v in _vertices)
    {
      minX = Math.min(v.x, minX);
      minY = Math.min(v.y, minY);
      maxX = Math.max(v.x, maxX);
      maxY = Math.max(v.y, maxY);
    }

    _bounds.width = maxX - minX;
    _bounds.height = maxY - minY;

  }

  override public function test( shape :Shape, ?collision :ShapeCollision ) : ShapeCollision
  {
    return shape.testPolygon(this, collision, true);
  }

  override public function testCircle( circle :Circle, ?collision :ShapeCollision, flip :Bool = false ) : ShapeCollision 
  {
    return SAT2D.testCircleVsPolygon( circle, this, collision, flip );
  }

  override public function testPolygon( polygon :Polygon, ?collision :ShapeCollision, flip :Bool = false ) : ShapeCollision 
  {
    return SAT2D.testPolygonVsPolygon( this, polygon, collision, flip );
  }

  override public function testRay( ray :Ray ) : RayCollision 
  {
    return SAT2D.testRayVsPolygon(ray, this);
  }

  // Render the shape
  // NOTE: does not set a linestyle
  override public function debug_render( graphics :Graphics ) : Void
  {
    var verts = get_transformedVertices();
    var end = verts[verts.length - 1];
    graphics.moveTo(end.x, end.y);

    for (vert in verts)
    {
      graphics.lineTo(vert.x, vert.y);
    }
  }
 
  override public function destroy() : Void 
  {
    var _count : Int = _vertices.length;

    for(i in 0 ... _count) {
        _vertices[i] = null;
    }

    _transformedVertices = null;
    _vertices = null;
    _transformMatrix = null;
    _bounds = null;
  }


  override private function get_width() :Float return 0;
  override private function get_height() :Float return 0;


  inline private function get_vertices() :Array<Vector> return _vertices;
  inline private function get_transformedVertices() :Array<Vector>
  {
    
    var _temp = transform.matrix.clone();
    _temp.translate(offsetX, offsetY);

    if( !_transformMatrix.equal(_temp) ) {

      _transformedVertices = new Array<Vector>();
      _transformMatrix = _temp;

      var len : Int = _vertices.length;

      for (i in 0...len) {

        var vert = _vertices[i].clone().transform( _transformMatrix );
        _transformedVertices.push( vert );

      }
    }

    return _transformedVertices;
  }

  private var _vertices :Array<Vector>;
  private var _transformedVertices :Array<Vector>;
  private var _transformMatrix :Matrix;


  // Static Methods
  
  static public function create( x :Float, y :Float, sides :Int, radius :Float ) :Polygon
  {
    var rotation:Float = (Math.PI * 2) / sides;
    var angle:Float;
    var vector:Vector;
    var vertices:Array<Vector> = new Array();

    for(i in 0 ... sides) {

      angle = (i * rotation) + ((Math.PI - rotation) * 0.5);
      vector = new Vector();
      vector.x = Math.cos(angle) * radius;
      vector.y = Math.sin(angle) * radius;
      vertices.push(vector);

    }

    return new Polygon( x, y, vertices );
  }

  static public function rectangle( x :Float, y :Float, width :Float, height :Float, centered :Bool = false ) :Polygon
  {
    var vertices:Array<Vector> = new Array<Vector>();

    if (centered) {

      vertices.push( new Vector(-width / 2, -height / 2) );
      vertices.push( new Vector( width / 2, -height / 2) );
      vertices.push( new Vector( width / 2,  height / 2) );
      vertices.push( new Vector(-width / 2,  height / 2) );

    } else {

      vertices.push( new Vector(0, 0) );
      vertices.push( new Vector(width, 0) );
      vertices.push( new Vector(width, height) );
      vertices.push( new Vector(0, height) );

    }

    return new Polygon( x, y, vertices );
  }

  static public function square( x :Float, y :Float, width :Float, centered :Bool = true ) :Polygon
  {
    return rectangle( x, y, width, width, centered );
  }

  static public function triangle( x :Float, y :Float, radius :Float ) :Polygon 
  {
    return create(x, y, 3, radius);
  }


}