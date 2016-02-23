package sge.lib;

// 
// A simple helper to get the divisor remainder 
// because haxe's implimentation of the modulos opporator 
// returns the dividend
// 
class Remainder
{
  
  // Use in place of
  // a % n -> Remainder.int/float(a, n)
  // when you want the remainder instead of the dividend 
  static inline public function int( a :Int, n :Int ) :Int
  {
    return a - (n * Math.floor(a/n));
  }

  static inline public function float( a :Float, n :Float ) :Float
  {
    return a - (n * Math.floor(a/n));
  }

}