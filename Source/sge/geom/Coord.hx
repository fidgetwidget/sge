package sge.geom;


// 
// Coordinate Pair
// 
// hashCode for use with hashMap
// - this will only support positive values
// hasString for Map<String, V>
// - this accepts negative values but is a slower store and reterval
// 
// This was very helpful in creating this: (http://stackoverflow.com/questions/919612/mapping-two-integers-to-one-in-a-unique-and-deterministic-way)
class Coord 
{

  public var x :Int;
  public var y :Int;

  public function new( x :Int = 0, y :Int = 0 )
  {
    this.x = x;
    this.y = y;
  }

  inline public function hashCode() :Int 
  {
    // trace('$x|$y:${Coord.getHashInt(x, y)}'); 
    return Coord.getHashInt(x, y);
  }

  inline public function hashString() :String return Coord.getHashString(x, y);

  inline public function toString() :String return '($x, $y)';
  

  inline public static function getHashInt( x:Int, y:Int ) :Int  return (x >= y ? x * x + x + y : x + y * y);

  inline public static function getHashString( x:Int, y:Int ) :String  return '$x:$y';

}