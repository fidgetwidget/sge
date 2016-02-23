package sge.geom;

// 
// Transformation Matrix
// 
// See openfl.geom.matrix for a more full implimentation
// Taken from differ (//github.com/underscorediscovery/differ)
// 
class Matrix  {

  public var a  : Float;
  public var b  : Float;
  public var c  : Float;
  public var d  : Float;
  public var tx : Float;
  public var ty : Float;


  public function new( a :Float = 1, b :Float = 0, c :Float = 0, d :Float = 1, tx :Float = 0, ty :Float = 0 ) 
  {
    this.a = a;
    this.b = b;
    this.c = c;
    this.d = d;
    this.tx = tx;
    this.ty = ty;
  }

  public function identity() :Void
  {
    a = 1;
    b = 0;
    c = 0;
    d = 1;
    tx = 0;
    ty = 0;
  }

  public function translate( x :Float, y :Float ) :Void 
  {
      tx += x;
      ty += y;
  }

  public function compose( position :Dynamic, rotation :Float, scale :Dynamic ) 
  {
    // identity();
    // scale( scale.x, scale.y );
    // rotate( rotation );
    // makeTranslation( position.x, position.y );
    
    if (rotation != 0) {
      
      var cos = Math.cos (rotation);
      var sin = Math.sin (rotation);
      
      a = cos * scale.x;
      b = sin * scale.y;
      c = -sin * scale.x;
      d = cos * scale.y;
      
    } else {
      
      a = scale.x;
      b = 0;
      c = 0;
      d = scale.y;
      
    }
    
    tx = position.x;
    ty = position.y;
  }


  public function makeTranslation( x:Float, y:Float ) :Matrix 
  {
    tx = x;
    ty = y;
    return this;
  }

  public function rotate( angle :Float ) :Void 
  {
    var cos, sin, a1, c1, tx1;
    
    cos = Math.cos (angle);
    sin = Math.sin (angle);
    
    a1 = a * cos - b * sin;
    b = a * sin + b * cos;
    a = a1;

    c1 = c * cos - d * sin;
    d = c * sin + d * cos;
    c = c1;

    tx1 = tx * cos - ty * sin;
    ty = tx * sin + ty * cos;
    tx = tx1;
  }

  public function scale( x :Float, y :Float) :Void 
  {
    a *= x;
    b *= y;

    c *= x;
    d *= y;

    tx *= x;
    ty *= y;
  }

  public function equal( other :Matrix ) :Bool
  {
    return (other.a  == a  &&
            other.b  == b  &&
            other.c  == c  &&
            other.d  == d  &&
            other.tx == tx &&
            other.ty == ty);
  }

  public function clone() :Matrix
  {
    return new Matrix(
        this.a, 
        this.b, 
        this.c, 
        this.d, 
        this.tx, 
        this.ty 
      );
  }

  public function toString() :String  return 'Matrix[a:$a, b:$b, c:$c, d:$d, tx:$tx, ty:$ty]';


  var _last_rotation : Float = 0;

}
