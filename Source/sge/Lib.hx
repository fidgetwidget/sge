package sge;

import openfl.display.BitmapData;
import openfl.display.PNGEncoderOptions;
import openfl.geom.Rectangle;
import openfl.utils.ByteArray;
import openfl.utils.SystemPath;
import haxe.io.Path;
import sys.io.FileOutput;
import sys.io.File;
import sys.FileSystem;
import sge.lib.SystemDirectory;

#if !lime_legacy
import lime.system.System as SystemPath;
#else
import openfl.utils.SystemPath;
#end

// 
// Math Extension:
// 
class Lib
{

  // Get the Divisor result because % gives the Dividend
  
  public static inline function remainder_int( a :Int, n :Int ) :Int
  {
    return a - (n * Math.floor(a/n));
  }

  public static inline function remainder_float( a :Float, n :Float ) :Float
  {
    return a - (n * Math.floor(a/n));
  }


  public static inline function random_int( min :Int, max :Int ) :Int
  {
    return min + Math.floor((max - min + 1) * Math.random());
  }

  public static inline function random_fromArray<T>( array :Array<T> ) :Null<T>
  {
    return (array != null && array.length > 0) ? array[ random_int(0, array.length - 1) ] : null;
  }

  public static inline function shuffleArray<T>( array :Array<T> ) :Array<T>
  {

    if (array!=null) {

      for (i in 0...array.length) {

        var j = random_int(0, array.length - 1);
        var a = array[i];
        var b = array[j];

        array[i] = b;
        array[j] = a;

      }

    }

    return array;

  }

  public static function saveImage( image :BitmapData, file :String, directory :Int = 1 ) :Void
  { 

    var path :Path = Lib.buildPath(file, directory);
    var options :PNGEncoderOptions = new PNGEncoderOptions();
    var png :ByteArray = image.encode(image.rect, options);
    var fo :FileOutput = File.write(""+path, true);

    try 
    {
      fo.writeBytes(png, 0, png.length );
      trace('save path done: $path');
    } 
    catch (e:Dynamic) 
    {
      trace('Error writing file $path: $e');
    }

    fo.close();

  }


  static function buildPath( file :String, directory :Int = 1 ) :Path
  {
    var baseDir;
    var path;

    // Build Path
    switch (directory)
    {
      case SystemDirectory.DESKTOP:
        baseDir = SystemPath.desktopDirectory;

      case SystemDirectory.USER:
        baseDir = SystemPath.userDirectory;

      default:
        baseDir = SystemPath.applicationStorageDirectory;
    }
    path = new Path(baseDir+file);

    // If we need to, create the directory
    if (!FileSystem.exists(path.dir)) FileSystem.createDirectory(path.dir);

    return path;

  }

}