package sge.lib;

import sge.lib.pool.Pool;

@:publicFields
class ArrayHelper
{
  
  static inline function shuffleArray<T> ( array :Array<T> ) : Array<T>
  {

    if (array!=null) {

      for (i in 0...array.length) {

        var j = Lib.random_int(0, array.length - 1);
        var a = array[i];
        var b = array[j];

        array[i] = b;
        array[j] = a;

      }

    }

    return array;

  }

  static inline function emptyArray<T> ( array : Array<T> ) : Array<T>
  {
    while (array.length > 0) array.pop();
    return array;
  }

  static inline function emptyArrayAndRecycleItems<T> ( array : Array<T>, pool : Pool<T> ) : Array<T>
  {
    while (array.length > 0) pool.push( array.pop() ); 
    return array;
  }

}