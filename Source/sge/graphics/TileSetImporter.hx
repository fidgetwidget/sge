package sge.graphics;

import haxe.Json;
import openfl.Assets;
import openfl.geom.Point;
import openfl.geom.Rectangle;


class TileSetImporter extends SpriteSheetImporter {

  public static var DEFAULT_TILE_WIDTH :Int = 16;
  public static var DEFAULT_TILE_HEIGHT :Int = 16;

  static var neighborBitwiseMap :Array<Int>;

  static var sideMap :Array<Int>;
  static var sideNeighborMap :Array<Int>;

  static var cornerMap :Array<Int>;
  static var cornerNeighborMap :Array<Int>;

  static var rect :Rectangle;
  static var zero :Point;

  static var json :String;
  static var importData :ImportTileSetsData;
  static var spritesheet :SpriteSheet;

  // 
  // Using the 
  // 
  public static function importTileSets( importPath :String, tileSets :TileSets ) :TileSets
  {
    if (tileSets == null) tileSets = new TileSets();

    trace('Importing TileSets "data/${importPath}.json"');

    json = Assets.getText('data/${importPath}.json');
    importData = Json.parse(json);

    if (Reflect.hasField(importData, "neighborBitwiseMap")) 
      neighborBitwiseMap = importData.neighborBitwiseMap;

    if (Reflect.hasField(importData, "sideMap")) 
      sideMap = importData.sideMap;
    if (Reflect.hasField(importData, "sideNeighborMap")) 
      sideNeighborMap = importData.sideNeighborMap;

    if (Reflect.hasField(importData, "cornerMap")) 
      cornerMap = importData.cornerMap;
    if (Reflect.hasField(importData, "cornerNeighborMap")) 
      cornerNeighborMap = importData.cornerNeighborMap;

    for (filename in importData.set)
    {
      trace('Importing TileSet "data/${filename}.json"');

      json = Assets.getText('data/${filename}.json');
      spritesheet = importFrames(json, spritesheet);

      tileSets.addTileSet( spritesheet.toTileSetData() );
    }

    return tileSets;
  }
  

  // 
  // Create a TileSet SpriteSheet 
  // 
  public static function importFrames( json :String, spritesheet :SpriteSheet ) :SpriteSheet
  {
    var hasSides:Bool, hasCorners:Bool, hasBackground:Bool, hasVariants:Bool;
    var x:Int, y:Int, width:Int, height:Int, cols:Int;
    var type :ImportTilesetData = Json.parse(json);
    var source = 'tiles/${type.filename}';
    var name = type.name;

    var suffix = Reflect.hasField(type, 'suffix') ? type.suffix : null;

    if (Reflect.hasField(type, "neighborBitwiseMap")) 
      neighborBitwiseMap = type.neighborBitwiseMap;
    // Sides
    if (Reflect.hasField(type, "sideMap")) 
      sideMap = type.sideMap;
    if (Reflect.hasField(type, "sideNeighborMap")) 
      sideNeighborMap = type.sideNeighborMap;
    // Corners
    if (Reflect.hasField(type, "cornerMap")) 
      cornerMap = type.cornerMap;
    if (Reflect.hasField(type, "cornerNeighborMap")) 
      cornerNeighborMap = type.cornerNeighborMap;

    _initDefaultData();

    if (spritesheet == null)
      spritesheet = new SpriteSheet(source, name);
    spritesheet.id = type.id;

    // Setup the Values
    x       = Reflect.hasField(type, "x")      ? Std.parseInt(type.x)      : 0;
    y       = Reflect.hasField(type, "y")      ? Std.parseInt(type.y)      : 0;
    width   = Reflect.hasField(type, "width")  ? Std.parseInt(type.width)  : DEFAULT_TILE_WIDTH;
    height  = Reflect.hasField(type, "height") ? Std.parseInt(type.height) : DEFAULT_TILE_HEIGHT;
    cols    = Reflect.hasField(type, "cols")   ? Std.parseInt(type.cols)   : Math.floor( spritesheet.sourceImage.width / width );

    setBitwiseFrames( spritesheet, x, y, width, height, cols, suffix );

    // Check if it has extended graphics
    hasSides      = Reflect.hasField(type, "hasSides")   ? type.hasSides : false;
    hasCorners    = Reflect.hasField(type, "hasCorners") ? type.hasCorners : false;
    hasVariants   = Reflect.hasField(type, "variants")   ? (type.variants != null ? true : false) : false;
    hasBackground = Reflect.hasField(type, "background") ? (type.background != null ? true : false) : false;

    if (hasSides) 
      setSideFrames( spritesheet, x, y, width, height, cols, suffix );
    if (hasCorners) 
      setCornerFrames( spritesheet, x, y, width, height, cols, suffix );
    if (hasVariants) 
      setVariantFrames( spritesheet, x, y, width, height, cols, suffix, type.variants );

    if (hasBackground) 
    {
      var bgx = x + (Reflect.hasField(type.background, "x") ? Std.parseInt(type.background.x) : 0);
      var bgy = y + (Reflect.hasField(type.background, "y") ? Std.parseInt(type.background.y) : 0);
      var bgsuffix = (suffix == null ? 'bg' : 'bg_${suffix}');
      
      setBitwiseFrames( spritesheet, bgx, bgy, width, height, cols, bgsuffix );

      if (Reflect.hasField(type.background, "variants") && type.background.variants != null)
        setVariantFrames( spritesheet, bgx, bgy, width, height, cols, bgsuffix, type.background.variants );
    }

    return spritesheet;
  }

  // 
  // Add an entire bitwise set of frames to the SpriteSheet
  // 
  static inline function setBitwiseFrames( sheet :SpriteSheet, 
    x :Int, y :Int, width :Int, height :Int, cols :Int, 
    ?suffix :String = null ) :Void
  {
    var xx:Int, yy:Int, i:Int, frameIndex:Int;
    for (bitVal in 0...neighborBitwiseMap.length)
    {
      i = neighborBitwiseMap[bitVal];
      xx = i - (Math.floor(i / cols) * cols);
      yy = Math.floor(i / cols);

      frameIndex = sheet.addFrame(xx, yy, width, height);
      var frameName = '${sheet.id}:${bitVal}';
      if (suffix != null) frameName += '_${suffix}';

      sheet.setFrameName(frameIndex, frameName);
    }
  }

  // 
  // Add the side frames to the SpriteSheet
  // 
  static inline function setSideFrames( sheet :SpriteSheet, 
    x :Int, y :Int, width :Int, height :Int, cols :Int, 
    ?suffix :String = null ) :Void
  {
    var xx:Int, yy:Int, i:Int, side:Int, frameIndex:Int, frameName:String;

    for(sideVal in 0...sideMap.length)
    {
      i = sideMap[sideVal];
      xx = i - (Math.floor(i / cols) * cols);
      yy = Math.floor(i / cols);

      frameIndex = sheet.addFrame(xx, yy, width, height);
      side = sideNeighborMap[sideVal];
      frameName = '${sheet.id}:s_${side}';
      if (suffix != null) frameName += '_${suffix}';

      sheet.setFrameName(frameIndex, frameName);
    }
  }

  // 
  // Add the corner frames to the SpriteSheet
  // 
  static inline function setCornerFrames( sheet :SpriteSheet, 
    x :Int, y :Int, width :Int, height :Int, cols :Int, 
    ?suffix :String = null ) :Void
  {
    var xx:Int, yy:Int, i:Int, corner:Int, frameIndex:Int, frameName:String;
    for(cornerVal in 0...cornerMap.length)
    {
      i = cornerMap[cornerVal];
      xx = i - (Math.floor(i / cols) * cols);
      yy = Math.floor(i / cols);

      frameIndex = sheet.addFrame(xx, yy, width, height);
      corner = cornerNeighborMap[cornerVal];
      frameName = '${sheet.id}:s_${corner}';
      if (suffix != null) frameName += '_${suffix}';

      sheet.setFrameName(frameIndex, frameName);
    }
  }

  // 
  // Add variants (set or individual) to the SpriteSheet
  // 
  static inline function setVariantFrames( sheet :SpriteSheet, 
    x :Int, y :Int, width :Int, height :Int, cols :Int, 
    ?suffix :String, variants :Array<ImportTileTypeVariantData> ) :Void
  {
    var hasSides:Bool, hasCorners:Bool;
    var vx:Int, vy:Int, vcols:Int, vsuffix:String;
    var variant :ImportTileTypeVariantData;

    for (vi in 0...variants.length)
    {
      variant = variants[vi];

      if (variant.isSet)
      {
        hasSides   = Reflect.hasField(variant, "hasSides")   ? variant.hasSides : false;
        hasCorners = Reflect.hasField(variant, "hasCorners") ? variant.hasCorners : false;

        vx = x + (Reflect.hasField(variant, "x") ? Std.parseInt(variant.x) : 0);
        vy = y + (Reflect.hasField(variant, "y") ? Std.parseInt(variant.y) : 0);
        vcols = (Reflect.hasField(variant, "cols") ? Std.parseInt(variant.cols) : cols);
        vsuffix = suffix == null ? 'v${vi}' : '${suffix}_v${vi}';

        setBitwiseFrames( sheet, vx, vy, width, height, vcols, vsuffix );
        if (hasSides)     
          setSideFrames( sheet, vx, vy, width, height, vcols, vsuffix );
        if (hasCorners)
          setCornerFrames( sheet, vx, vy, width, height, vcols, vsuffix );
      }
      else
      {
        var frameIndex:Int, count:Int, frameName:String;
        vx = x + (Reflect.hasField(variant, "x") ? Std.parseInt(variant.x) : 0) * width;
        vy = y + (Reflect.hasField(variant, "y") ? Std.parseInt(variant.y) : 0) * height;
        frameIndex = sheet.addFrame(vx, vy, width, height);
        count = 0;
        frameName = suffix == null ? '${variant.key}_v' : '${variant.key}_${suffix}_v';

        for (name in sheet.frameNames)
        {
          if (name.indexOf(frameName) >= 0) count++;
        }
        frameName += '$count';
        sheet.setFrameName(frameIndex, frameName);
      }
    }
  }

    
  static inline function _initDefaultData() :Void
  {
    if (neighborBitwiseMap == null) 
      neighborBitwiseMap = [21, 15, 18, 12, 3, 9, 0, 6, 20, 14, 19, 13, 2, 8, 1, 7];

    if (sideMap == null)
      sideMap = [23, 22, 16, 17];

    if (sideNeighborMap == null)
      sideNeighborMap = [1, 2, 4, 8];

    if (cornerMap == null)
      cornerMap = [4, 5, 11, 10];

    if (cornerNeighborMap == null)
      cornerNeighborMap = [16, 32, 64, 128];
  }

}


// +------------------------------------------------------------+
// |                                                            |
// |              Default Import Data Structure                 |
// |                                                            |
// +------------------------------------------------------------+

//  neighborBitwiseMap
//  
//   ┌───────┐ ┌─┐  ─┘ └─ 
//   
//   │       │ │ │  ─┐ ┌─ 
//   
//   └───────┘ └─┘  ── │ 
//   ┌───────┐ ┌─┐
//   └───────┘ └─┘   │ ── 
//  
//   00 01 02  03 | 04 05
//   06 07 08  09 | 10 11
//   12 13 14  15 | 16 17
//   18 19 20  21 | 22 23
//   -- -- --  -- + -- --
//   24 25 26  27 | 28 29
//  
//   06 14 12  04   NW NE
//   07 15 13  05   SW SE
//   03 11 09  01    N  E
//   02 10 08  00    W  S
//   
//  neighborBitwise: 21, 15, 18, 12, 3, 9, 0, 6, 20, 14, 19, 13, 2, 8, 1, 7
//  sides:           23, 22, 16, 17 {1, 2, 4, 8}
//  corners:         4, 5, 11, 10   {!16, !32, !64, !128}

// The whole file
typedef ImportTileSetsData = 
{
  var set :Array<String>; // list of file names

  var neighborBitwiseMap :Array<Int>;
  var sideMap :Array<Int>;
  var sideNeighborMap :Array<Int>;
  var cornerMap :Array<Int>;
  var cornerNeighborMap :Array<Int>;
}

// The tileset
typedef ImportTilesetData = 
{
  var name :String;
  var filename :String;
  var id :Int;

  var suffix :String; // optional suffix (to allow support of variants through wholely seperate tile sets)
  
  var x :String;
  var y :String;
  var width :String;
  var height :String;
  var cols :String;

  // optional background and variant types
  var hasSides :Bool;
  var hasCorners :Bool;
  var background :ImportBackgroundData;
  var variants :Array<ImportTileTypeVariantData>;

  // Optional
  var neighborBitwiseMap :Array<Int>;
  var sideMap :Array<Int>;
  var sideNeighborMap :Array<Int>;
  var cornerMap :Array<Int>;
  var cornerNeighborMap :Array<Int>;
}

// Variants
typedef ImportTileTypeVariantData = 
{
  var x :String;
  var y :String;
  var cols :String;
  
  var key :String;  // the part after the : in ${type}:${neighbors} or ${type}:s${side} or ${type}:c${corner}

  var isSet :Bool;  // [true] if it's a whole set [null or false] if it's a single tile
  var hasSides :Bool;
  var hasCorners :Bool;
}

// Background 
typedef ImportBackgroundData = 
{
  var x :String;
  var y :String;
  // optional variants for the background
  var variants :Array<ImportTileTypeVariantData>;
}
