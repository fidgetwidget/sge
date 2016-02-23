package games.tileworld;

import openfl.display.BitmapData;

typedef TilesetData = {

  var name :String;
  var id :UInt;
  var rgb :UInt; // for use in the tile -> chunk/region/world map 
  
  // the image file
  var filename :String;
  var source :BitmapData;

  // how that image breaks down into tileFrames
  var tileFrame :TileFrameData;
  var bitwiseFrames :Array<TileFrameData>;
  var variants :Map< String, Array<TileFrameData> >;
  var sideFrames :Array<TileFrameData>;

}
