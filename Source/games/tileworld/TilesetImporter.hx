package games.tileworld;

import haxe.Json;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.geom.Point;
import openfl.geom.Rectangle;

// 
// Import Types
// 

// neighborBitwiseMap
//
// ┌───────┐ ┌─┐  ─┘ └─ 
// 
// │       │ │ │  ─┐ ┌─ 
// 
// └───────┘ └─┘  ── │ 
// ┌───────┐ ┌─┐
// └───────┘ └─┘   │ ── 
//
// 00 01 02  03 | 04 05
// 06 07 08  09 | 10 11
// 12 13 14  15 | 16 17
// 18 19 20  21 | 22 23
// -- -- --  -- + -- --
// 24 25 26  27 | 28 29
//
// 06, 14, 12, 04, 
// 07, 15, 13, 05,
// 03, 11, 09, 01,
// 02, 10, 08, 00,
// 
// 21, 15, 18, 12, 3, 9, 0, 6, 20, 14, 19, 13, 2, 8, 1, 7
// 

typedef ImportTileTypes = {

  var types :Array<ImportTilesetData>;
  var neighborBitwiseMap :Array<Int>;
  var sideMap :Array<Int>;

}

typedef ImportTilesetData = {

  var name :String;
  var id :UInt;
  var filename :String;
  var x :UInt;
  var y :UInt;
  var width :UInt;
  var height :UInt;
  var key :String; // 0x000000 -> 0xffffff
  var variants :Array<ImportTileTypeVariantData>;
  var noSides :Bool;

}


typedef ImportTileTypeVariantData = {

  var key :String; // the part after the : in ${type}:${neighbors} or ${type}:s${side} or ${type}:c${corner}
  var set :Bool;
  var x :UInt;
  var y :UInt;

}


// 
// Tile Type Importer
// 
class TilesetImporter {

  var DEFAULT_BITWISE_MAP :Array<Int> = [21, 15, 18, 12, 3, 9, 0, 6, 20, 14, 19, 13, 2, 8, 1, 7];
  var DEFAULT_SIDES_MAP :Array<Int> = [23, 22, 16, 17];

  var jsonString :String;
  var jsonData :ImportTileTypes;
  var bitwiseMap :Array<Int>;
  var sideMap :Array<Int>;
  var rect :Rectangle;
  var zero :Point;
  var sourceImage :BitmapData;
  var tileBitmap :BitmapData;
  var tileset :String;

  var x :UInt;
  var y :UInt;
  var width :UInt;
  var height :UInt;
  var rgb :UInt;

  var columns :UInt;


  public function new() 
  {
    rect = new Rectangle();
    zero = new Point();
  }

  public function importTileTypes( path :String ) :Map<Int, TilesetData>
  {
    trace('importing $path');
    var results :Map< Int, TilesetData > = new Map();

    jsonString = Assets.getText(path);
    jsonData = Json.parse(jsonString);

    bitwiseMap = jsonData.neighborBitwiseMap;
    bitwiseMap = bitwiseMap == null ? DEFAULT_BITWISE_MAP : bitwiseMap;
    sideMap = jsonData.sideMap;
    sideMap = sideMap == null ? DEFAULT_SIDES_MAP : sideMap;

    // type :ImportTilesetData
    for( type in jsonData.types )
    {
      rgb = Std.parseInt(type.key);
      sourceImage = Assets.getBitmapData('tiles/${type.filename}');

      var tilesetData :TilesetData = {
        name:           type.name,
        id:             type.id,
        filename:       type.filename,
        rgb:            rgb,
        source:         sourceImage,
        tileFrame:      null,
        bitwiseFrames:  null,
        variants:       null,
        sideFrames:     null
      };

      if (type.id == 0) {
        tilesetData.tileFrame = getNoneTileFrame();
        results.set(type.id, tilesetData);
        continue;
      }

      x = type.x;
      y = type.y;
      width = type.width;
      height = type.height;
      if (width == 0) width = CONST.TILE_WIDTH;
      if (height == 0) height = CONST.TILE_HEIGHT;
      columns = Math.floor(sourceImage.width / width);

      tilesetData.bitwiseFrames = getTileFrames( x, y, width, height, bitwiseMap );
      
      if (type.variants != null)
        tilesetData.variants = getTileFrameVariants( type.id, x, y, width, height, type.variants );

      if (type.noSides != true)
        tilesetData.sideFrames = getSideFrames( x, y, width, height );

      results.set(type.id, tilesetData);
    }

    return results;
  }

  inline function getNoneTileFrame() :TileFrameData
  {
    return getTileFrame( 0, 0, 0, 0, CONST.TILE_WIDTH, CONST.TILE_HEIGHT);
  }


  inline function getTileFrames( tile_x :Int, tile_y :Int, tile_width :Int, tile_height :Int, bitwiseMap :Array<Int> ) :Array<TileFrameData>
  {
    var frames :Array<TileFrameData> = new Array();
    var x :Int;
    var y :Int;
    var index :Int;

    for( bitwiseVal in 0...bitwiseMap.length )
    {
      index = bitwiseMap[bitwiseVal];
      x = index - (Math.floor(index / columns) * columns);
      y = Math.floor(index / columns);

      var tileFrame :TileFrameData = getTileFrame( x, y, tile_x, tile_y, tile_width, tile_height );
      frames.push(tileFrame);
    }

    return frames;
  }


  inline function getTileFrameVariants( tile_id :Int, tile_x :Int, tile_y :Int, tile_width :Int, tile_height :Int, variants :Array<ImportTileTypeVariantData> ) :Map< String, Array<TileFrameData> >
  {
    var variantFramesMap :Map< String, Array<TileFrameData> > = new Map();

    for( index in 0...variants.length )
    {
      var variant = variants[index];

      if (variant.set)
      {
        getTileFrameVariantSet( tile_id, tile_x + variant.x, tile_y + variant.y, tile_width, tile_height, variantFramesMap );
        continue;
      }

      getTileFrameVariant( variant.x, variant.y, variant.key, tile_id, tile_x, tile_y, tile_width, tile_height, variantFramesMap );

    }
    return variantFramesMap;
  }


  inline function getTileFrameVariantSet( 
    tile_id :Int, tile_x :Int, tile_y :Int, tile_width :Int, tile_height :Int, 
    variantFramesMap :Map<String, Array<TileFrameData>> ) :Void
  {
    var x :Int;
    var y :Int;
    var index :Int;
    var nval :Int;
    var tileFrame :TileFrameData;
    var variantFrames :Array<TileFrameData>;

    // Neighbor Aware
    for( bitwiseVal in 0...bitwiseMap.length )
    {
      index = bitwiseMap[bitwiseVal];

      if (!variantFramesMap.exists( '$bitwiseVal' ))
        variantFramesMap.set('$bitwiseVal', new Array());
      variantFrames = variantFramesMap.get('$bitwiseVal');

      x = index - (Math.floor(index / columns) * columns);
      y = Math.floor(index / columns);
      
      tileFrame = getTileFrame( x, y, tile_x, tile_y, tile_width, tile_height );
      variantFrames.push(tileFrame);
    }

    // Sides
    for( sideVal in 0...sideMap.length )
    {
      index = sideMap[sideVal];
      nval = NEIGHBORS.getNeighborVal(sideVal);

      if (!variantFramesMap.exists( 's_$nval' ))
        variantFramesMap.set('s_$nval', new Array());
      variantFrames = variantFramesMap.get('s_$nval');
      
      x = index - (Math.floor(index / columns) * columns);
      y = Math.floor(index / columns);

      tileFrame = getTileFrame( x, y, tile_x, tile_y, tile_width, tile_height );
      variantFrames.push(tileFrame);
    }
  }


  inline function getTileFrameVariant( x :Int, y :Int, variant_key :String,
    tile_id :Int, tile_x :Int, tile_y :Int, tile_width :Int, tile_height :Int, 
    variantFramesMap :Map<String, Array<TileFrameData>> ) :Void
  {

    var variantFrames :Array<TileFrameData>;

    if (!variantFramesMap.exists(variant_key))
      variantFramesMap.set(variant_key, new Array());
    variantFrames = variantFramesMap.get(variant_key);

    rect.x = x = tile_x + (x * tile_width);
    rect.y = y = tile_y + (y * tile_height);
    rect.width = tile_width;
    rect.height = tile_height;

    tileBitmap = new BitmapData(tile_width, tile_height, true, 0);
    tileBitmap.copyPixels( sourceImage, rect, zero );

    var tileFrame :TileFrameData = {
      x: x,
      y: y,
      width: tile_width,
      height: tile_height,
      bitmapData: tileBitmap
    };

    variantFrames.push(tileFrame);
  }


  inline function getSideFrames( tile_x :Int, tile_y :Int, tile_width :Int, tile_height :Int ) :Array<TileFrameData>
  {
    var sideFrames :Array<TileFrameData> = new Array();
    var x :Int;
    var y :Int;
    var index :Int;
    var tileFrame :TileFrameData;

    for( sideVal in 0...sideMap.length )
    {
      index = sideMap[sideVal];

      x = index - (Math.floor(index / columns) * columns);
      y = Math.floor(index / columns);

      tileFrame = getTileFrame( x, y, tile_x, tile_y, tile_width, tile_height );
      sideFrames.push(tileFrame);
    }

    return sideFrames;
  }


  inline function getTileFrame( x :Int, y :Int, tile_x :Int, tile_y :Int, tile_width :Int, tile_height :Int ) :TileFrameData
  {
    rect.x = x = tile_x + (x * tile_width);
    rect.y = y = tile_y + (y * tile_height);
    rect.width = tile_width;
    rect.height = tile_height;

    tileBitmap = new BitmapData(tile_width, tile_height, true, 0);
    tileBitmap.copyPixels( sourceImage, rect, zero );

    return {
      x: x,
      y: y,
      width: tile_width,
      height: tile_height,
      bitmapData: tileBitmap
    };
  }

}