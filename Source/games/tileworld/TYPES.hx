package games.tileworld;

import haxe.Json;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.errors.Error;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import sge.Lib;


class TYPES {

  static var zero :Point;
  static var rect :Rectangle;

  public static var tilesets :Map< String, TilesetData >;
  public static var tileFrames :Map< String, BitmapData >;
  static var variantCounts :Map< String, Int >;
  static var rgbIdMap :Map< Int, UInt >;
  static var nameIdMap :Map< String, UInt >;


  public static function init() :Void
  {
    TYPES.zero = new Point();
    TYPES.rect = new Rectangle(0, 0, CONST.TILE_WIDTH, CONST.TILE_HEIGHT);
    TYPES.tilesets = new Map();
    TYPES.tileFrames = new Map();
    TYPES.variantCounts = new Map();
    TYPES.rgbIdMap = new Map();
    TYPES.nameIdMap = new Map();

    // trace('TYPES.init() begin.');

    var importer :TilesetImporter = new TilesetImporter();
    var results :Map< Int, TilesetData > = importer.importTileTypes('data/tiles.json');

    // trace('adding results');

    for (key in results.keys())
    {
      var value :TilesetData = results.get(key);
      TYPES.tilesets.set(value.name, value);

      var tileKey :String;
      var varTileKey :String;
      var tileFrame :TileFrameData;
      var bitmapData :BitmapData;
      var neighborVal :Int;

      if (value.tileFrame != null)
      {
        tileKey = '$key';
        tileFrame = value.tileFrame;
        bitmapData = tileFrame.bitmapData;
        TYPES.tileFrames.set(tileKey, bitmapData);
      }

      if (value.bitwiseFrames != null)
      {
        for (bitwiseKey in 0...value.bitwiseFrames.length)
        {
          tileKey = '$key:$bitwiseKey';
          tileFrame = value.bitwiseFrames[bitwiseKey];
          bitmapData = tileFrame.bitmapData;
          TYPES.tileFrames.set(tileKey, bitmapData);
        }
      }       

      if (value.sideFrames != null)
      {  
        for (sideIndex in 0...value.sideFrames.length)
        {
          neighborVal = NEIGHBORS.getNeighborVal(sideIndex);
          tileKey = '$key:s_$neighborVal';
          tileFrame = value.sideFrames[sideIndex];
          bitmapData = tileFrame.bitmapData;
          TYPES.tileFrames.set(tileKey, bitmapData);
        }
      }

      if (value.variants != null)
      {
        for (variantKey in value.variants.keys())
        {
          var frames = value.variants.get(variantKey);
          tileKey = '$key:$variantKey'; 
          variantCounts.set(tileKey, frames.length);

          for (vi in 0...frames.length)
          {
            varTileKey = '${tileKey}_${vi}';
            tileFrame = frames[vi];
            bitmapData = tileFrame.bitmapData;
            TYPES.tileFrames.set(varTileKey, bitmapData);
          }
        }
      }
      
      TYPES.nameIdMap.set(value.name, key);
      TYPES.rgbIdMap.set(value.rgb, key);
    }

    // trace('TYPES.init() complete.');

  }


  public static inline function getTileRGBKey( type :UInt ) :UInt
  {
    if (!TYPES.rgbIdMap.exists(type)) throw new openfl.errors.Error('Undefined type');
    return rgbIdMap.get(type);
  }


  public static inline function setBitmapToTileType( bitmapData :BitmapData, tileType :UInt, modifier :UInt = 0, neighbors :Int = 0, layer :UInt = LAYERS.BASE ) :Void
  {
    if (TYPES.tileFrames == null) throw new Error("tileFrames is null");

    tileKey = TYPES.getTileKey(tileType, modifier, neighbors);
    tileBitmapData = TYPES.tileFrames.get(tileKey);
    bitmapData.copyPixels( tileBitmapData, TYPES.rect, TYPES.zero );
  }


  public static inline function setTileBitmapSides( bitmapData :BitmapData, type :Int, sides :Array<Int>, layer :UInt = LAYERS.BASE, ignoreTypePriority :Bool = false )
  {
    for (sideIndex in 0...sides.length)
    {
      tileType = sides[sideIndex];
      if (tileType == 0 || (type > tileType && !ignoreTypePriority)) continue;

      neighborVal = NEIGHBORS.getNeighborVal(sideIndex);
      sideKey = getTileSideKey(tileType, neighborVal);

      sideBitmapData = TYPES.tileFrames.get(sideKey);

      bitmapData.copyPixels( sideBitmapData, TYPES.rect, TYPES.zero, null, null, true);
    }
  }


  public static inline function getIdFromeName( name :String ) :UInt return nameIdMap.get(name);

  public static inline function getTypeFromRGB( rgb :UInt ) :UInt return rgbIdMap.get(rgb);


  public static inline function getTileKey( tileType :UInt, modifier :Int, neighbors :UInt, layer :UInt = LAYERS.BASE, noVariants :Bool = false ) :String
  {
    tileKey = '$tileType:$neighbors';
    // if (layer == LAYERS.BACKGROUND) tileKey += '_bg';

    if (!TYPES.tileFrames.exists(tileKey)) 
    {
      tileKey = '$tileType';
      // if (layer == LAYERS.BACKGROUND) tileKey += '_bg';
    }
    if (!TYPES.tileFrames.exists(tileKey)) throw new Error('tileFrames $tileKey not found.');

    if (variantCounts.exists(tileKey) && !noVariants)
    {
      count = variantCounts.get(tileKey);
      rnd = Lib.random_int(0, count);
      if (rnd < count) tileKey += '_$rnd';
    }

    return tileKey;
  }

  public static inline function getTileSideKey( tileType :UInt, neighborVal :UInt, layer :UInt = LAYERS.BASE ) :String
  {
    tileKey = '$tileType:s_$neighborVal';
    // if (layer == LAYERS.BACKGROUND) tileKey += '_bg';

    if (!TYPES.tileFrames.exists(tileKey)) throw new Error('tileFrames $tileKey not found.');

    if (variantCounts.exists(tileKey))
    {
      count = variantCounts.get(tileKey);
      rnd = Lib.random_int(0, count);
      if (rnd < count) tileKey += '_$rnd';
    }

    return tileKey;
  }

  static var tileKey :String;
  static var tileBitmapData :BitmapData;
  static var neighborVal :Int;
  static var tileType :Int;
  static var sideKey :String;
  static var sideBitmapData :BitmapData;
  static var count :Int;
  static var rnd :Int;





  // 
  // Static Const Types
  // 

  public static var NONE :UInt = 0;
  public static var NONE_RGB :UInt = 0x87ceeb; // sky blue
  
  // Liquids?

  // Basic
  public static var DIRT    :UInt = 10;
  public static var CLAY    :UInt = 16;
  public static var STONE   :UInt = 20;
  public static var PUTTY   :UInt = 24;
  // Ore
  public static var COAL    :UInt = 50;
  public static var COPPER  :UInt = 54;
  public static var TIN     :UInt = 56;
  public static var ZINC    :UInt = 58;
  public static var IRON    :UInt = 60;
  
  public static var ALUMINIUM :UInt = 64;


  // Progression of base material
  // 
  // Stone
  // 
  // Copper 
  // 
  // Bronze : Copper + Coal
  //  - Brass : Copper + Zink
  // 
  // Iron
  // 
  // Steel : Iron + ?some process 
  //  - Stainless : Iron + Nickle
  //  

  public static var GOLD :UInt = 100;  
  public static var PLATINUM :UInt = 102;

  public static var NICKLE :UInt = 112;
  public static var COBALT :UInt = 114;



}