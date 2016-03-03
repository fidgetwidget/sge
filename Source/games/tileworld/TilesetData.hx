package games.tileworld;

import openfl.Assets;
import openfl.display.BitmapData;


@:publicFields
class TilesetData {

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

  var backgroundFrames :Array<TileFrameData>;
  var backgroundVariants :Map< String, Array<TileFrameData> >;
  var backgroundSides :Array<TileFrameData>;

  function new( name :String, id :UInt, filename :String, rgb :String ) 
  {
    this.name = name;
    this.id = id;
    this.filename = filename;

    this.rgb = Std.parseInt(rgb);
    this.source = Assets.getBitmapData('tiles/$filename');
  }

}
