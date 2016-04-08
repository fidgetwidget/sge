package sge.graphics;

import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.display.BitmapData;


typedef AnimationData = {

  var name :String;

  var looping :Bool;

  var frameRate :Float;
  
  var frames :Array<FrameData>;

}

