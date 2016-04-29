package sge;

import openfl.display.BitmapData;
import haxe.io.Path;
import sge.lib.ArrayHelper;
import sge.lib.MathHelper;
import sge.lib.PathHelper;
import sge.lib.Remainder;
import sge.lib.SystemDirectory;


// 
// Helper functions
// 
// TODO: utilize the lib classes to provide the functions used here
// 

@:publicFields
class Lib
{

  // --------------------------------------------------
  //    Math
  // --------------------------------------------------

  static inline function distanceBetween( x1 :Float, y1 :Float, x2 :Float, y2 :Float ) :Float
  {
    return MathHelper.distanceBetween(x1, y1, x2, y2);
  }


  // --------------------------------------------------
  //    Remainder
  // --------------------------------------------------

  // Get the Divisor result because % gives the Dividend
  static inline function remainder_int( a :Int, n :Int ) :Int
  {
    return Remainder.int(a, n);
  }

  static inline function remainder_float( a :Float, n :Float ) :Float
  {
    return Remainder.float(a, n);
  }


  // --------------------------------------------------
  //    Random
  // --------------------------------------------------

  static inline function random_int ( min :Int, max :Int ) : Int
  {
    return min + Math.floor((max - min + 1) * Math.random());
  }

  static inline function random_fromArray<T> ( array :Array<T> ) : Null<T>
  {
    return (array != null && array.length > 0) ? array[ random_int(0, array.length - 1) ] : null;
  }


  // --------------------------------------------------
  //    Array
  // --------------------------------------------------

  static inline function shuffleArray<T> ( array :Array<T> ) : Array<T>
  {
    return ArrayHelper.shuffleArray(array);
  }

  static inline function emptyArray<T> ( array :Array<T>) : Array<T>
  {
    return ArrayHelper.emptyArray(array);
  }


  // --------------------------------------------------
  //    Path
  // --------------------------------------------------

  static function saveImage( image :BitmapData, file :String, directory :Int = SystemDirectory.APPLICATION_STORAGE ) :Void
  { 
    return PathHelper.saveImage( image, file, directory );
  }

  static function buildPath( file :String, directory :Int = SystemDirectory.APPLICATION_STORAGE ) :Path
  {
    return PathHelper.buildPath( file, directory );
  }

}