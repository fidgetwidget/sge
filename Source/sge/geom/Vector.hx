package sge.geom;

import sge.geom.Matrix;


// 
// 2D Vector
// x, y 
// has math for:
// - transformation
// - normalization
// - dot and cross products
// - adding and subtracting vectors together
// - inverting 
// - truncating
// 
class Vector {


    public var x : Float = 0;

    public var y : Float = 0;

    public var length ( get, set ) : Float;

    public var lengthsq ( get, never ) : Float;



    public function new( x :Float = 0, y :Float = 0 ) 
    {
      this.x = x;
      this.y = y;
    }

        
    public inline function clone() : Vector 
    {
      v = VectorPool.instance.get();
      
      v.x = this.x;
      v.y = this.y;

      return v;
    } 

    public function transform( matrix :Matrix, clone :Bool = false ) : Vector 
    {
      if (clone)
        v = this.clone();
      else
        v = this;

      v.x = (v.x * matrix.a) + (v.y * matrix.c) + matrix.tx;
      v.y = (v.x * matrix.b) + (v.y * matrix.d) + matrix.ty;

      return v;
    } 

    public function normalize() : Vector 
    {
      l = length;

      if (l == 0) 
      {
        x = 1;
        return this;
      }

      x /= l;
      y /= l;

      return this;
    } 

    public function truncate( max:Float ) : Vector 
    {
      length = Math.min(max, length);

      return this;
    }

    public function invert() : Vector 
    {
      x = -x;
      y = -y;

      return this;
    }

    public function dot( other:Vector ) : Float 
    {
      return x * other.x + y * other.y;
    } 

    public function cross( other:Vector ) : Float 
    {
      return x * other.y - y * other.x;
    }

    public function add( other :Vector ) :Vector 
    {
      x += other.x;
      y += other.y;

      return this;
    }

    public function add_values( x :Float, y :Float ) :Vector
    {
      this.x += x;
      this.y += y;

      return this;
    }

    public function subtract( other :Vector ) : Vector 
    {
      x -= other.x;
      y -= other.y;

      return this;
    } 

    public function subtract_values( x :Float, y :Float ) :Vector
    {
      this.x -= x;
      this.y -= y;

      return this;
    }

    public function toString() : String  return 'Vector[x: $x, y: $y]';

    var v :Vector;
    var l :Float;


    // We only store the x and y values of the vector, 
    // so changing the length (the magnatude) is more 
    // costly than changing the indivudual axies values.
    inline private function set_length( value :Float ) : Float 
    {
      var ep:Float = 0.00000001;
      var _angle:Float = Math.atan2(y, x);

      x = Math.cos(_angle) * value;
      y = Math.sin(_angle) * value;

      if (Math.abs(x) < ep) x = 0;
      if (Math.abs(y) < ep) y = 0;

      return value;
    }

    inline private function get_length() : Float  return Math.sqrt(lengthsq);

    inline private function get_lengthsq() : Float  return x * x + y * y;


} //Vector
