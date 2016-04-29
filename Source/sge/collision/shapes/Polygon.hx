package sge.collision.shapes;

import openfl.display.Graphics;
import sge.collision.AABB;
import sge.collision.ray.Ray;
import sge.collision.ray.RayCollision;
import sge.geom.Matrix;
import sge.geom.Vector;
import sge.geom.VectorPool;

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

  function _setSize() :Void
  {

    var minX :Float = Math.POSITIVE_INFINITY;
    var minY :Float = Math.POSITIVE_INFINITY;
    var maxX :Float = Math.NEGATIVE_INFINITY;
    var maxY :Float = Math.NEGATIVE_INFINITY;

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
    // graphics.drawRect(x, y, _bounds.width, _bounds.height);

    verts = get_transformedVertices();

    // move to the last vertice
    vert = verts[verts.length - 1];
    graphics.moveTo(vert.x, vert.y);

    // draw the lines between each verticie
    for (v in verts)
    {
      graphics.lineTo(v.x, v.y);
    }
  }
 
  override public function destroy() : Void 
  {
    _count = _vertices.length;

    for(i in 0 ... _count) {
        _vertices[i] = null;
    }

    _transformedVertices = null;
    _vertices = null;
    _transformMatrix = null;
    _bounds = null;
  }
  // var _count :Int

  var _count :Int;
  var _testMatrix :Matrix;
  var len :Int;
  var vert :Vector;
  var verts :Array<Vector>;

  var _vertices :Array<Vector>;
  var _transformedVertices :Array<Vector>;
  var _transformMatrix :Matrix;

  inline function get_vertices() :Array<Vector> return _vertices;
  inline function get_transformedVertices() :Array<Vector>
  {
    _testMatrix = transform.matrix.clone();
    _testMatrix.translate(offsetX, offsetY);

    if( _transformMatrix == null || ! _transformMatrix.equal(_testMatrix) ) {

      _transformedVertices = Lib.emptyArray(_transformedVertices);
      _transformMatrix = _testMatrix;

      len = _vertices.length;
      for (i in 0...len) {
        vert = _vertices[i].transform( _transformMatrix, true );
        _transformedVertices.push( vert );
      }
    }

    return _transformedVertices;
  }


  // 
  // Static Factory Methods
  // 
  static public function create( x :Float, y :Float, sides :Int, radius :Float ) :Polygon
  {
    var rotation :Float = (Math.PI * 2) / sides;
    var angle :Float;
    var vector :Vector;
    var vertices :Array<Vector> = [];

    for(i in 0 ... sides) {

      angle = (i * rotation) + ((Math.PI - rotation) * 0.5);
      vector = VectorPool.instance.get();
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

      vertices.push( Polygon.getVector(-width * 0.5, -height * 0.5) );
      vertices.push( Polygon.getVector( width * 0.5, -height * 0.5) );
      vertices.push( Polygon.getVector( width * 0.5,  height * 0.5) );
      vertices.push( Polygon.getVector(-width * 0.5,  height * 0.5) );

    } else {

      vertices.push( Polygon.getVector(0, 0) );
      vertices.push( Polygon.getVector(width, 0) );
      vertices.push( Polygon.getVector(width, height) );
      vertices.push( Polygon.getVector(0, height) );

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

  // 
  // Stitc Helper
  // 
  static inline function getVector( x :Float = 0.0, y :Float = 0.0 ) :Vector 
  {
    var v = VectorPool.instance.get();
    v.x = x;
    v.y = y;
    return v;
  }


}