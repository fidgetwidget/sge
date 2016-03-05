package games.tileworld;

import haxe.Json;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.errors.Error;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import sge.Lib;


class TileHelper {


  static var instance :TileHelper;


  public static var tilesets (get, never) :Map< String, TilesetData >;

  public static var tileFrames (get, never) :Map< String, BitmapData >;

  public static var tileTypeIds (get, never) :Iterator< UInt >;

  public static var tileTypeNames (get, never) :Iterator< String >;


  static inline function get_tilesets() :Map< String, TilesetData > return instance._tilesets;

  static inline function get_tileFrames() :Map< String, BitmapData > return instance._tileFrames;

  static inline function get_tileTypeIds() :Iterator<UInt> return instance.nameIdMap.iterator();

  static inline function get_tileTypeNames() :Iterator<String> return instance.nameIdMap.keys();


  // 
  // Load the assets from the json file
  //  
  //  TODO: make this more portable, taking an importer type, and json filename to pull with Assets
  // 
  public static function init() :Void
  {
    instance = new TileHelper();
    instance.readyAssets();
  }


  public static inline function getTileRGBKey( type :UInt ) :UInt
  {
    if (!instance.rgbIdMap.exists(type)) throw new openfl.errors.Error('Undefined type');
    return instance.rgbIdMap.get(type);
  }

  public static inline function getIdFromeName( name :String ) :UInt return instance.nameIdMap.get(name);

  public static inline function getTypeFromRGB( rgb :UInt ) :UInt return instance.rgbIdMap.get(rgb);

  public static inline function getBitmapData( key :String ) :BitmapData return instance._tileFrames.exists(key) ? instance._tileFrames.get(key) : null;


  // 
  // tileFrame key getters
  // 

  public static inline function getTileKey( tileType :UInt, modifier :Int, neighbors :UInt, layer :UInt = LAYERS.BASE, noVariants :Bool = false ) :String
  {
    // None gets the None Tile
    if (tileType == TYPES.NONE) return '${tileType}';

    var tileKey :String = layer == LAYERS.BACKGROUND ? '${tileType}:${neighbors}_bg' : '$tileType:$neighbors';
    // check if its just the bg that's missing
    if (!instance._tileFrames.exists(tileKey) && layer == LAYERS.BACKGROUND) 
    {
      trace('background asset not found for ${tileType}:${neighbors}');
      tileKey = '$tileType:$neighbors';
    }
    // check to see if it's a no neighbor tile
    if (!instance._tileFrames.exists(tileKey)) 
    {
      tileKey = '$tileType';
      if (layer == LAYERS.BACKGROUND && instance._tileFrames.exists(tileKey + '_bg')) tileKey += '_bg';
    }
    // otherwise we just don't have the tile asset
    if (!instance._tileFrames.exists(tileKey)) throw new Error('_tileFrames $tileKey not found.');

    if (instance.variantCounts.exists(tileKey) && !noVariants)
    {
      var count = instance.variantCounts.get(tileKey);
      var rnd = Lib.random_int(0, count);
      if (rnd < count) tileKey += '_$rnd';
    }
    
    return tileKey;
  }


  public static inline function getTileSideKey( tileType :UInt, neighborVal :UInt, layer :UInt = LAYERS.BASE ) :String
  {
    var tileKey = '$tileType:s_$neighborVal';
    // if (layer == LAYERS.BACKGROUND) tileKey += '_bg';

    if (!instance._tileFrames.exists(tileKey)) throw new Error('_tileFrames $tileKey not found.');

    if (instance.variantCounts.exists(tileKey))
    {
      var count = instance.variantCounts.get(tileKey);
      var rnd = Lib.random_int(0, count);
      if (rnd < count) tileKey += '_$rnd';
    }

    return tileKey;
  }


  // 
  // CopyPixel Helpers
  // 

  public static inline function setBitmapToTileType( bitmapData :BitmapData, tileType :UInt, modifier :UInt = 0, neighbors :Int = 0, layer :UInt = LAYERS.BASE ) :Void
  {
    if (instance._tileFrames == null) throw new Error("_tileFrames is null");

    var tileKey = getTileKey(tileType, modifier, neighbors, layer);
    var tileBitmapData = getBitmapData(tileKey);

    bitmapData.copyPixels( tileBitmapData, instance.rect, instance.zero );
  }


  public static inline function setTileBitmapSides( bitmapData :BitmapData, type :Int, sides :Array<Int>, layer :UInt = LAYERS.BASE, ignoreTypePriority :Bool = false )
  {
    for (sideIndex in 0...sides.length)
    {
      var tileType = sides[sideIndex];
      if (tileType == 0 || (type > tileType && !ignoreTypePriority)) continue;

      var neighborVal = NEIGHBORS.getNeighborVal(sideIndex);
      var sideKey = getTileSideKey(tileType, neighborVal);
      var sideBitmapData = getBitmapData(sideKey);

      bitmapData.copyPixels( sideBitmapData, instance.rect, instance.zero, null, null, true);
    }
  }


  // We have static accessors for these
  var _tilesets :Map< String, TilesetData >;
  var _tileFrames :Map< String, BitmapData >;

  var rect :Rectangle;
  var zero :Point;

  var importer :TilesetImporter;
  var variantCounts :Map< String, Int >;
  var nameIdMap :Map< String, Int >;
  var rgbIdMap :Map< UInt, Int >;

  var data :TilesetData;
  var bitmapData :BitmapData;
  var tileFrame :TileFrameData;
  var tileKey :String;
  var varTileKey :String;
  var neighborVal :Int;


  function new() 
  {
    rect = new Rectangle(0, 0, CONST.TILE_WIDTH, CONST.TILE_HEIGHT);
    zero = new Point();

    importer = new TilesetImporter();
    variantCounts = new Map();
    _tilesets = new Map();
    _tileFrames = new Map();
    nameIdMap = new Map();
    rgbIdMap = new Map();
  }


  inline function readyAssets() :Void
  {    
    var results :Map< Int, TilesetData > = importer.importTileTypes('data/tiles.json');

    for (key in results.keys())
    {
      data = results.get(key);

      _tilesets.set(data.name, data);

      nameIdMap.set(data.name, key);

      rgbIdMap.set(data.rgb, key);

      setSingleFrame(data, key);

      setBitwiseFrames(data, key);

      setSideFrames(data, key);

      setVariantFrames(data, key);

      setBackgroundFrames(data, key);

      setBackgroundVariantFrames(data, key);
    }

  }



  inline function setSingleFrame( data :TilesetData, key :Int ) :Void
  {
    if (data.tileFrame == null) return;
    
    tileKey = '$key';
    tileFrame = data.tileFrame;
    bitmapData = tileFrame.bitmapData;

    _tileFrames.set(tileKey, bitmapData);
  }


  inline function setBitwiseFrames( data :TilesetData, key :Int ) :Void
  {
    if (data.bitwiseFrames == null) return;
      
    for (bitwiseKey in 0...data.bitwiseFrames.length)
    {
      tileKey = '$key:$bitwiseKey';
      tileFrame = data.bitwiseFrames[bitwiseKey];
      bitmapData = tileFrame.bitmapData;

      _tileFrames.set(tileKey, bitmapData);
    }
  }


  inline function setSideFrames( data :TilesetData, key :Int ) :Void
  {
    if (data.sideFrames == null) return;
    
    for (sideIndex in 0...data.sideFrames.length)
    {
      neighborVal = NEIGHBORS.getNeighborVal(sideIndex);
      tileKey = '$key:s_$neighborVal';
      tileFrame = data.sideFrames[sideIndex];
      bitmapData = tileFrame.bitmapData;

      _tileFrames.set(tileKey, bitmapData);
    }
  }


  inline function setVariantFrames( data :TilesetData, key :Int ) :Void
  {
    if (data.variants == null) return;

    for (variantKey in data.variants.keys())
    {
      var frames = data.variants.get(variantKey);
      tileKey = '$key:$variantKey'; 
      variantCounts.set(tileKey, frames.length);

      for (vi in 0...frames.length)
      {
        varTileKey = '${tileKey}_${vi}';
        tileFrame = frames[vi];
        bitmapData = tileFrame.bitmapData;

        _tileFrames.set(varTileKey, bitmapData);
      }
    }
  }


  inline function setBackgroundFrames( data :TilesetData, key :Int ) :Void
  {
    if (data.backgroundFrames == null) return;

    for (bitwiseKey in 0...data.backgroundFrames.length)
    {
      tileKey = '${key}:${bitwiseKey}_bg';
      tileFrame = data.backgroundFrames[bitwiseKey];
      bitmapData = tileFrame.bitmapData;

      _tileFrames.set(tileKey, bitmapData);
    }
  }


  inline function setBackgroundVariantFrames( data :TilesetData, key :Int ) :Void
  {
    if (data.backgroundVariants == null) return;

    for (variantKey in data.backgroundVariants.keys())
    {
      var frames = data.backgroundVariants.get(variantKey);
      tileKey = '${key}:${variantKey}_bg'; 
      variantCounts.set(tileKey, frames.length);

      for (vi in 0...frames.length)
      {
        varTileKey = '${tileKey}_${vi}_bg';
        tileFrame = frames[vi];
        bitmapData = tileFrame.bitmapData;

        _tileFrames.set(varTileKey, bitmapData);
      }
    }
  }

}
