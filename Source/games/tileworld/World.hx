package games.tileworld;

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
import sge.geom.base.Coord as BaseCoord;
import sge.geom.base.Rectangle as BaseRectangle;
import sge.input.InputManager;
import sge.scene.Camera;
import sge.scene.Scene;


class World {

  public var image :Sprite;
  // public var bitmap :Bitmap;

  var scene :Scene;
  var camera :Camera;

  var regions :Map<String, Region>;
  var regionBitmaps :Map<String, Bitmap>;
  var collisionBitmaps :Map<String, Bitmap>;

  var camera_x (get, never) :Float;
  var camera_y (get, never) :Float;
  

  public function new( scene :Scene )
  {
    this.scene = scene;
    this.camera = scene.camera;

    image = new Sprite();
    // bitmap = new Bitmap(camera.bounds.width, camera.bounds.height, false, 0);
    regions = new Map();
    regionBitmaps = new Map();
    collisionBitmaps = new Map();

    init_regions();
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
      if (region.dirty) regionBitmap.bitmapData = region.cache;

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


  public function collisionCheck( aabb :AABB, collisions :Array<Collision> ) :Array<Collision>
  {
    if (collisions == null) collisions = new Array();

    var xx :Float = aabb.left;
    var yy :Float = aabb.top;
    var tile :Tile = null;
    var collision :Collision;

    while (xx <= aabb.right)
    {
      while (yy <= aabb.bottom)
      {
        tile = getTile(xx, yy);
        collision = collision_tile(aabb, tile);
        if (collision != null)
        {
          collisions.push(collision);
        }

        yy += CONST.TILE_HEIGHT;
      }
      yy = aabb.top;
      xx += CONST.TILE_WIDTH;
    }
    return collisions;
  }

  // 
  // Collision_tile

  public function collision_tile( aabb :AABB, tile :Tile ) :Collision
  {
    
    var dir = getTileCollisionValue(tile.worldX, tile.worldY);
    if (dir == NEIGHBORS.NONE) return null;

    var tileHalfWidth = (CONST.TILE_WIDTH * 0.5);
    var tileCenterX = tile.worldX + tileHalfWidth;    
    var dx = tileCenterX - aabb.centerX;
    var px = (aabb.halfWidth + tileHalfWidth) - Math.abs(dx);

    if (px <= 0) return null;

    var tileHalfHeight = (CONST.TILE_HEIGHT * 0.5);
    var tileCenterY = tile.worldY + tileHalfHeight;
    var dy = tileCenterY - aabb.centerY;
    var py = (aabb.halfHeight + tileHalfHeight) - Math.abs(dy);

    if (py <= 0) return null;

    px *= dx > 0 ? 1 : -1;
    py *= dy > 0 ? 1 : -1;

    if (dir & NEIGHBORS.SIDES == NEIGHBORS.SIDES)
    {
      // Do nothing because we have all 4 directions
    }
    else
    {
      if (dir & NEIGHBORS.VERTICAL != 0)
      {
        // up & down are fine as is, lets check for left or right
        if (dir & NEIGHBORS.WEST != 0)
        {
          while (px < 0) px += CONST.TILE_WIDTH;
        } 
        else if (dir & NEIGHBORS.EAST != 0) 
        {
          while (px > 0) px -= CONST.TILE_WIDTH;
        }
        else
        {
          px = 0;
        }
      }
      else if (dir & NEIGHBORS.HORIZONTAL != 0)
      {
        // left & right are fine as is, lets check for up or down
        if (dir & NEIGHBORS.NORTH != 0)
        {
          while (py < 0) py += CONST.TILE_HEIGHT;
        }
        else if (dir & NEIGHBORS.SOUTH != 0)
        {
          while (py > 0) py -= CONST.TILE_HEIGHT;
        }
        else
        {
           py = 0;
        }
      }
      else
      {
        // no sides are safe, test them all
        
        if (dir & NEIGHBORS.WEST != 0)
        {
          while (px < 0) px += CONST.TILE_WIDTH;
        } 
        else if (dir & NEIGHBORS.EAST != 0) 
        {
          while (px > 0) px -= CONST.TILE_WIDTH;
        }
        else
        {
          px = 0;
        }

        if (dir & NEIGHBORS.NORTH != 0)
        {
          while (py < 0) py += CONST.TILE_HEIGHT;
        }
        else if (dir & NEIGHBORS.SOUTH != 0)
        {
          while (py > 0) py -= CONST.TILE_HEIGHT;
        }
        else
        {
           py = 0;
        }
      }
      
    }

    if (px == 0 && py == 0) return null;

    return new Collision(px, py);
  }


  public function getTiles_bounds( aabb :AABB, tileArray :Array<Tile> ) :Array<Tile>
  {
    if (tileArray == null) tileArray = new Array();

    var xx = aabb.left;
    var yy = aabb.top;

    while (xx <= aabb.right)
    {
      while (yy <= aabb.bottom)
      {
        var tile = getTile(xx, yy);
        if (!(tileArray.indexOf(tile) >= 0))
        {
          tileArray.push(tile);
        }

        yy += CONST.TILE_HEIGHT;
      }
      yy = aabb.top;
      xx += CONST.TILE_WIDTH;
    }

    return tileArray;
  }

  // 
  // Accessors
  // 

  
  // Tiles

  public function getTile( x :Float, y :Float ) :Tile
  {
    var region = getRegion(x, y);
    return region.getTile(x, y);
  }


  public function setTileType( x :Float, y :Float, tileType :Int ) :Void
  {
    var region = getRegion(x, y);
    region.setTileType(x, y, tileType);
  }


  public function tileChanged( x :Float, y :Float ) :Tile
  {
    var region = getRegion(x, y);
    var chunk = region.getChunk(x, y);
    var tile = chunk.getTile(x, y);
    chunk.tileChanged(tile);
    return tile;
  }


  public function getTileCoord( x :Float, y :Float ) :BaseCoord
  {
    var tx = Math.floor(x - Lib.remainder_int(Math.floor(x), CONST.TILE_WIDTH));
    var ty = Math.floor(y - Lib.remainder_int(Math.floor(y), CONST.TILE_WIDTH));
    return { x: tx, y: ty };
  }

  // Chunk

  public function getChunk( x :Float, y :Float ) :Chunk
  {
    return getRegion(x, y).getChunk(x, y);
  }

  public function getTileCollisionValue( x :Float, y :Float ) :Int
  {
    return getRegion(x, y).getChunk(x, y).getCollision(x, y);
  }

  // Regions
  
  public function getRegions() :Map<String, Region> return regions;

  public inline function getRegion( x :Float, y :Float, createIfNull :Bool = true ) :Region
  {
    var rx = Math.floor( x / CONST.REGION_WIDTH );
    var ry = Math.floor( y / CONST.REGION_HEIGHT );

    return getRegion_local(rx, ry, createIfNull);
  }

  public inline function getRegionKey( x :Float, y :Float ) :String
  {
    var rx = Math.floor( x / CONST.REGION_WIDTH );
    var ry = Math.floor( y / CONST.REGION_HEIGHT );

    return regionString(rx, ry);
  } 


  

  


  // 
  // Internal Helpers
  // 

  // 
  // TODO: move these to a new WorldGen class
  //  init_regions, getNewRegion, createRegion

  inline function init_regions() :Void
  {
    createRegion(0, 0);
  }

  inline function getNewRegion() : Region  return new Region();

  inline function createRegion( rx :Int, ry :Int ) :Region
  {
    var region = getNewRegion();

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

  inline function regionString( regionXIndex :Int, regionYIndex :Int ) :String return '$regionXIndex|$regionYIndex';


  // 
  // Region Map (save & load via image)
  // 
  // TODO: move this to another class...
  // 

  inline function loadRegionFromMap( regionXIndex :Int, regionYIndex :Int ) :Void
  {
    var region = getRegion(regionXIndex, regionYIndex);

    var regionReadyHandler = function( imageData :BitmapData ) :Void
    {
      for (imageTileX in 0...CONST.REGION_TILES_WIDE)
      {
        for (imageTileY in 0...CONST.REGION_TILES_HIGH)
        {
          // using the pixel, determine the tile type
          var pixel :UInt = imageData.getPixel(imageTileX, imageTileY);
          var tileTypeValue :UInt = TYPES.getTypeFromRGB( pixel );

          // convert to world position x/y
          var tileXPos = 
            (regionXIndex * CONST.REGION_TILES_WIDE) + 
            (imageTileX * CONST.TILE_WIDTH) + 
            (CONST.TILE_WIDTH * 0.5);
          var tileYPos = 
            (regionYIndex * CONST.REGION_TILES_HIGH) + 
            (imageTileY * CONST.TILE_HEIGHT) + 
            (CONST.TILE_HEIGHT * 0.5);

          // set the tile at that position to the correct tile type
          region.setTileType(tileXPos, tileYPos, tileTypeValue);
        }
      }

    }
    var fileName = 'region_x${regionXIndex}_y${regionYIndex}.png';
    var path = 'assets/regions/${fileName}';

    if (Assets.exists(path, AssetType.IMAGE))
    {
      Assets.loadBitmapData( path, true, regionReadyHandler );
    }
    else
    {
      createRegion( regionXIndex, regionYIndex );
    }
  }


  inline function saveRegionMap( regionXIndex :Int, regionYIndex :Int ) :Void
  {
    var region = getRegion(regionXIndex, regionYIndex);
    var imageData = new BitmapData(CONST.REGION_TILES_WIDE, CONST.REGION_TILES_HIGH, true, 0xffffff);

    imageData.lock();
    for (imageTileX in 0...CONST.REGION_TILES_WIDE)
    {
      for (imageTileY in 0...CONST.REGION_TILES_HIGH)
      {
        var tileXPos = 
          (regionXIndex * CONST.REGION_TILES_WIDE) + 
          (imageTileX * CONST.TILE_WIDTH) + 
          (CONST.TILE_WIDTH * 0.5);
        var tileYPos = 
          (regionYIndex * CONST.REGION_TILES_HIGH) + 
          (imageTileY * CONST.TILE_HEIGHT) + 
          (CONST.TILE_HEIGHT * 0.5);

        // set the tile at that position to the correct tile type
        var tileType = region.getTileType(tileXPos, tileYPos);
        var tileTypeColor = 0x000000;
        imageData.setPixel(imageTileX, imageTileY, tileTypeColor);
      }
    }
    var rect = new Rectangle(0, 0, CONST.REGION_TILES_WIDE, CONST.REGION_TILES_HIGH);
    imageData.unlock(rect);

    var fileName = 'region_x${regionXIndex}_y${regionYIndex}.png';
    var path = 'regions/${fileName}';

#if (sys)
    Lib.saveImage( imageData, path );
#end
  }


  // 
  // Properties
  // 

  inline function get_camera_x() :Float return camera == null ? 0 : camera.x;
  inline function get_camera_y() :Float return camera == null ? 0 : camera.y;

}
