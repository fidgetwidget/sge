package sge.lib;

// 
// A few helper functions to get values from an array with a weighted value array 
// eg. Loot Tables
// 
class WeightedArrayLookup
{
  
  static inline public function getRandomValue( array :Array<T>, weights :Array<Int> ) :T
  {
    if (array.length != weights.length) throw new openfl.errors.Error("Values Array and Weights Array don't have matching lengths.");

    max = index = 0;
    for (w in weights)
    {
      max += w;
    }
    rnd = sge.Lib.remainder_int(0, max);
    while (max > 0)
    {
      max -= weights[index];
      if (max <= 0)
        return array[index];
      index++;
    }
    return null;
  }


  static var max :Int;
  static var rnd :Int;
  static var index :Int;


}