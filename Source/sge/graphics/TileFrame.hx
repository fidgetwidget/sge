package sge.graphics;

import openfl.display.BitmapData;

// Only the information needed to render the tile
typedef TileFrame = {

  // Position
  var x :Int;
  var y :Int;
  var z :Int; // layer, paralx, more
  // Graphics
  var bitmapData :BitmapData;

}
