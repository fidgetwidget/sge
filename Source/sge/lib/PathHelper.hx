package sge.lib;

import openfl.display.BitmapData;
import openfl.display.PNGEncoderOptions;
import openfl.geom.Rectangle;
import openfl.utils.ByteArray;
import haxe.io.Path;
import sge.lib.SystemDirectory;

#if (sys)
import sys.io.FileOutput;
import sys.io.File;
import sys.FileSystem;
#end

#if (!lime_legacy && sys)
import lime.system.System as SystemPath;
#end

@:publicFields
class PathHelper
{
  
  
  static function buildPath( file :String, directory :Int = SystemDirectory.APPLICATION_STORAGE ) :Path
  {
    var path :Path;
    var baseDir :String = "";

    // Build Path
#if (sys)
    switch (directory)
    {
      case SystemDirectory.DESKTOP:
        baseDir = SystemPath.desktopDirectory;

      case SystemDirectory.USER:
        baseDir = SystemPath.userDirectory;

      case SystemDirectory.APPLICATION_STORAGE:
        baseDir = SystemPath.applicationStorageDirectory;
    }
#end

    path = new Path(baseDir+file);

#if (sys)
    // If we need to, create the directory
    if (!FileSystem.exists(path.dir)) FileSystem.createDirectory(path.dir);
#end

    return path;

  }

  static function saveImage( image :BitmapData, file :String, directory :Int = SystemDirectory.APPLICATION_STORAGE ) :Void
  { 

#if (sys)
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
#end

  }


}