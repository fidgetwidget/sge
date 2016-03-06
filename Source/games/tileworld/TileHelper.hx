package games.tileworld;

import haxe.Json;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.errors.Error;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import sge.Lib;
import sge.graphics.TileSetCollection;
import sge.graphics.TileSetImporter;


class TileHelper {


  static var instance :TileHelper;

  public static var ids (get, never) :Iterator<UInt>;

  public static var names (get, never) :Iterator<String>;

  // 
  // Load the assets from the json file
  //  
  //  TODO: make this more portable, taking an importer type, and json filename to pull with Assets
  // 
  public static function init() :Void
  {
    instance = new TileHelper();
  }

  // 
  // CopyPixel Helpers
  // 

  public static inline function setBitmapToTileType( bitmapData :BitmapData, tileType :UInt, neighbors :Int = 0, layer :UInt = LAYERS.BASE ) :Void
  {
    var key = instance._collection.getFrameKey(tileType, neighbors, layer == LAYERS.BACKGROUND);
    var data = instance._collection.getTileFrameById(tileType, key);

    bitmapData.copyPixels( data, instance.rect, instance.zero );
  }


  public static inline function setTileBitmapSides( bitmapData :BitmapData, type :UInt, sides :Array<Int>, layer :UInt = LAYERS.BASE, ignoreTypePriority :Bool = false )
  {
    for (sideIndex in 0...sides.length)
    {
      var tileType = sides[sideIndex];
      if (tileType == 0 || (type > tileType && !ignoreTypePriority)) continue;

      var neighborVal = NEIGHBORS.getNeighborVal(sideIndex);
      var key = instance._collection.getSideFrameKey(tileType, neighborVal, layer == LAYERS.BACKGROUND);
      var data = instance._collection.getTileFrameById(tileType, key);

      bitmapData.copyPixels( data, instance.rect, instance.zero, null, null, true);
    }
  }

  static inline function get_ids() :Iterator<UInt> return instance._collection.tileSetIds;

  static inline function get_names() :Iterator<String> return instance._collection.tileSetNames;


  var _collection :TileSetCollection;
  var rect :Rectangle;
  var zero :Point;

  function new() 
  {
    rect = new Rectangle(0, 0, CONST.TILE_WIDTH, CONST.TILE_HEIGHT);
    zero = new Point();
    _collection = new TileSetCollection();
    TileSetImporter.DEFAULT_TILE_WIDTH = CONST.TILE_WIDTH;
    TileSetImporter.DEFAULT_TILE_HEIGHT = CONST.TILE_HEIGHT;
    TileSetImporter.importTileSets('data/import', _collection);
  }

}
