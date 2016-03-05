package sge.graphics;

import openfl.display.BitmapData;


typedef TileSetData = {

  var name :String;
  
  var source :BitmapData;

  var tileData :Array<BitmapData>;

  var tileMap :Map< String, Int >;

}
