package sge.graphics;

import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.graphics.BitmapData;


typedef FrameData {

  var name :String;

  var bitmapData :BitmapData;

  var rect :Rectangle;

  // for sprites (where is the center of the frame)
  var origin :Point;

}

