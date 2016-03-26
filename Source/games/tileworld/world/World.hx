package games.tileworld.world;

import games.tileworld.CONST;
import games.tileworld.LAYERS;
import games.tileworld.TYPES;
import games.tileworld.Tile;

import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.PNGEncoderOptions;
import openfl.display.Sprite;
import openfl.display.PixelSnapping;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import sge.Game;
import sge.Lib;
import sge.collision.AABB;
import sge.collision.Collision;
import sge.input.InputManager;
import sge.scene.Camera;
import sge.scene.Scene;


class World {

  public var background :Bitmap;
  public var image :Sprite;

  var scene :Scene;
  var camera :Camera;

  var regions :Map<String, Region>;
  var regionBitmaps :Map<String, Bitmap>;
  var collisionBitmaps :Map<String, Bitmap>;

  var camera_x (get, never) :Float;
  var camera_y (get, never) :Float;

  var rect :Rectangle;
  var zero :Point;
  

  public function new( scene :Scene )
  {
    this.scene = scene;
    this.camera = scene.camera;

    var backgroundData = Assets.getBitmapData('images/tempBg.png');
    background = new Bitmap(backgroundData, PixelSnapping.ALWAYS, false);
    image = new Sprite();
    // bitmap = new Bitmap(camera.bounds.width, camera.bounds.height, false, 0);
    regions = new Map();
    regionBitmaps = new Map();
    collisionBitmaps = new Map();

    rect = new Rectangle(0, 0, CONST.REGION_WIDTH, CONST.REGION_HEIGHT);
    zero = new Point();

    generateWorld();
  }


  public function update() :Void
  {
    return;
  }


  public function render() :Void
  {
    for( regionKey in regions.keys() )
    {
      var region = regions.get(regionKey);
      var regionBitmap = regionBitmaps.get(regionKey);

      // Update the region's image
      if (region.dirty) 
      {
        trace('region is dirty. ${region.x}|${region.y}');
        regionBitmap.bitmapData = region.cache;
      }

      regionBitmap.x = region.x - camera_x;
      regionBitmap.y = region.y - camera_y;
      
      if (0 > regionBitmap.x + CONST.REGION_WIDTH ||
          0 > regionBitmap.y + CONST.REGION_HEIGHT ||
          regionBitmap.x > camera.bounds.width / camera.scaleX ||
          regionBitmap.y > camera.bounds.height / camera.scaleY)
      {
        image.removeChild(regionBitmap);
      }
      else
      {
        image.addChild(regionBitmap);
      }
    }
  }


  // 
  // Tile Getters
  // 
  
  // Tiles
  public function getTile( x :Float, y :Float, layer :UInt = 0 ) :Tile
  {
    var region = getRegion(x, y);
    return region.getTile(x, y, layer);
  }

  public function getTiles( x :Float, y :Float, width :Float, height :Float, results :Array<Tile> ) :Array<Tile>
  {
    if (results == null) results = new Array();

    var xx = x;
    var yy = y;

    while (xx <= x + width)
    {
      while (yy <= y + height)
      {
        var tile = getTile(xx, yy);
        if (!(results.indexOf(tile) >= 0))
        {
          results.push(tile);
        }

        yy += CONST.TILE_HEIGHT;
      }
      yy = y;
      xx += CONST.TILE_WIDTH;
    }

    return results;
  }

  public function getTiles_bounds( aabb :AABB, results :Array<Tile> ) :Array<Tile>
  {
    return getTiles(aabb.left, aabb.top, aabb.width, aabb.height, results);
  }

  // Chunk
  public function getChunk( x :Float, y :Float ) :Chunk
  {
    return getRegion(x, y).getChunk(x, y);
  }

  // Regions
  public inline function getRegion( x :Float, y :Float, createIfNull :Bool = true ) :Region
  {
    var rx = Math.floor( x / CONST.REGION_WIDTH );
    var ry = Math.floor( y / CONST.REGION_HEIGHT );

    return getRegion_local(rx, ry, createIfNull);
  }

  public function getRegions() :Map<String, Region> return regions;

  public inline function getRegionKey( x :Float, y :Float ) :String
  {
    var rx = Math.floor( x / CONST.REGION_WIDTH );
    var ry = Math.floor( y / CONST.REGION_HEIGHT );

    return regionString(rx, ry);
  } 

  // 
  // SETTERS
  // 

  // 
  // Set tile by type
  // 
  public function setTileType( x :Float, y :Float, tileType :Int, layer :UInt = 0 ) :Void
  {
    var region = getRegion(x, y);
    region.setTileType(x, y, tileType, layer);
  }

  // 
  // Set tile as dirty (to be updated)
  // 
  public function touchTile( x :Float, y :Float ) :Void
  {
    var chunk = getRegion(x, y).getChunk(x, y);
    var tile = chunk.getTile(x, y, LAYERS.BASE);
    chunk.tileChanged(tile);
    tile = chunk.getTile(x, y, LAYERS.BACKGROUND);
    chunk.tileChanged(tile);
  }

  
  // 
  // Helpers
  // 
  
  public inline function snapToTileX( x :Float ) :Int return Math.floor(x - Lib.remainder_int(Math.floor(x), CONST.TILE_WIDTH));

  public inline function snapToTileY( y :Float ) :Int return Math.floor(y - Lib.remainder_int(Math.floor(y), CONST.TILE_HEIGHT));


  // 
  // Internal Helpers
  // 

  
  // 
  // TODO: Move these to a WorldGenerator class
  inline function generateWorld() :Void
  {
    createRegion(0, 0);
  }

  inline function createRegion( rx :Int, ry :Int ) :Region
  {
    var region = RegionPool.instance.get();

    var regionKey = regionString(rx, ry);
    var xx = rx * CONST.REGION_WIDTH;
    var yy = ry * CONST.REGION_HEIGHT;
    // trace('new region made at position: [$xx|$yy]');
    region.set(this, xx, yy);

    var regionBitmap = new Bitmap(region.cache, PixelSnapping.ALWAYS, false);
    // image.addChild(regionBitmap);

    regions.set(regionKey, region);
    regionBitmaps.set( regionKey, regionBitmap );

    return region;
  }


  inline function getRegion_local( rx :Int, ry :Int, createIfNull :Bool = true ) :Region
  {
    var region :Region = null;
    var key = regionString(rx, ry);
    
    if (!regions.exists(key))
    {
      if (createIfNull) region = createRegion(rx, ry);
    }
    else
    {
      region = regions.get(key);
    }

    return region;
  }


  inline function regionString( rx :Int, ry :Int ) :String return '$rx|$ry';


  // 
  // Region Map (save & load via image)
  // 
  // TODO: move this to another class...
  // 

//   inline function loadRegionFromMap( regionXIndex :Int, regionYIndex :Int ) :Void
//   {
//     var region = getRegion(regionXIndex, regionYIndex);

//     var regionReadyHandler = function( imageData :BitmapData ) :Void
//     {
//       for (imageTileX in 0...CONST.REGION_TILES_WIDE)
//       {
//         for (imageTileY in 0...CONST.REGION_TILES_HIGH)
//         {
//           // using the pixel, determine the tile type
//           var pixel :UInt = imageData.getPixel(imageTileX, imageTileY);
//           var tileTypeValue :UInt = TYPES.getTypeFromRGB( pixel );

//           // convert to world position x/y
//           var tileXPos = 
//             (regionXIndex * CONST.REGION_TILES_WIDE) + 
//             (imageTileX * CONST.TILE_WIDTH) + 
//             (CONST.TILE_WIDTH * 0.5);
//           var tileYPos = 
//             (regionYIndex * CONST.REGION_TILES_HIGH) + 
//             (imageTileY * CONST.TILE_HEIGHT) + 
//             (CONST.TILE_HEIGHT * 0.5);

//           // set the tile at that position to the correct tile type
//           region.setTileType(tileXPos, tileYPos, tileTypeValue);
//         }
//       }

//     }
//     var fileName = 'region_x${regionXIndex}_y${regionYIndex}.png';
//     var path = 'assets/regions/${fileName}';

//     if (Assets.exists(path, AssetType.IMAGE))
//     {
//       Assets.loadBitmapData( path, true, regionReadyHandler );
//     }
//     else
//     {
//       createRegion( regionXIndex, regionYIndex );
//     }
//   }


//   inline function saveRegionMap( regionXIndex :Int, regionYIndex :Int ) :Void
//   {
//     var region = getRegion(regionXIndex, regionYIndex);
//     var imageData = new BitmapData(CONST.REGION_TILES_WIDE, CONST.REGION_TILES_HIGH, true, 0xffffff);

//     imageData.lock();
//     for (imageTileX in 0...CONST.REGION_TILES_WIDE)
//     {
//       for (imageTileY in 0...CONST.REGION_TILES_HIGH)
//       {
//         var tileXPos = 
//           (regionXIndex * CONST.REGION_TILES_WIDE) + 
//           (imageTileX * CONST.TILE_WIDTH) + 
//           (CONST.TILE_WIDTH * 0.5);
//         var tileYPos = 
//           (regionYIndex * CONST.REGION_TILES_HIGH) + 
//           (imageTileY * CONST.TILE_HEIGHT) + 
//           (CONST.TILE_HEIGHT * 0.5);

//         // set the tile at that position to the correct tile type
//         var tileType = region.getTileType(tileXPos, tileYPos);
//         var tileTypeColor = 0x000000;
//         imageData.setPixel(imageTileX, imageTileY, tileTypeColor);
//       }
//     }
//     var rect = new Rectangle(0, 0, CONST.REGION_TILES_WIDE, CONST.REGION_TILES_HIGH);
//     imageData.unlock(rect);

//     var fileName = 'region_x${regionXIndex}_y${regionYIndex}.png';
//     var path = 'regions/${fileName}';

// #if (sys)
//     Lib.saveImage( imageData, path );
// #end
//   }


  // 
  // Properties
  // 

  inline function get_camera_x() :Float return camera == null ? 0 : camera.x;
  inline function get_camera_y() :Float return camera == null ? 0 : camera.y;

}
