package sge.world;

import openfl.display.Bitmap;
import openfl.display.PixelSnapping;
import openfl.display.Sprite;
import openfl.display.Graphics;
import openfl.errors.Error;
import openfl.geom.Point;
import sge.scene.Scene;
import sge.scene.Camera;
import sge.tiles.Tile;
import sge.tiles.TileCollection;
import sge.tiles.TILE_VALUES;
import sge.tiles.TILE_LAYERS;
import sge.tiles.TILE_TYPES;


// A Simple render object that is neighbor aware
class World implements TileCollection {


  public var camera :Camera;
  public var regionSprite :Sprite;
  
  public var regions (default, null) :Map<String, Region>;
  var regionBitmaps :Map<String, Bitmap>;
  var regionsOnScreen :Array<String>;
  

  public function new() 
  {
    regions = new Map();
    regionBitmaps = new Map();
    regionsOnScreen = [];
    regionSprite = new Sprite();
  }


  public function update() :Void
  {
    // trace("World.update");
  }


  public function render() :Void
  {
    renderRegions();
  }


  public inline function debug_render_tile_bounds( x :Float, y :Float, width :Float, height :Float, g :Graphics ) :Void
  {
    ix = Math.floor(x);
    iy = Math.floor(y);

    while (ix <= x + width)
    {
      while (iy <= y + height)
      {

        if (getTile(ix, iy, TILE_LAYERS.COLLISION).type != TILE_TYPES.NONE)
        {
          xx = ix - Lib.remainder_int(ix, TILE_VALUES.TILE_WIDTH);
          yy = iy - Lib.remainder_int(iy, TILE_VALUES.TILE_HEIGHT);

          tx = (xx - camera.x) * camera.scaleX;
          ty = (yy - camera.y) * camera.scaleY;
          tw = TILE_VALUES.TILE_WIDTH * camera.scaleX;
          th = TILE_VALUES.TILE_HEIGHT * camera.scaleY;

          g.drawRect(tx, ty, tw, th);
        }

        iy += TILE_VALUES.TILE_HEIGHT;
      }
      iy = Math.floor(y);
      ix += TILE_VALUES.TILE_WIDTH;
    }
  }
  var tx :Float;
  var ty :Float;
  var tw :Float;
  var th :Float;


  public inline function getRegions() :Iterator<Region> return regions.iterator();


  public inline function getRegion( x :Float, y :Float, createIfNull :Bool = false ) :Region
  {
    // trace('World.getRegion $x $y $createIfNull');

    rx = Math.floor( x / WORLD_VALUES.REGION_WIDTH );
    ry = Math.floor( y / WORLD_VALUES.REGION_HEIGHT );
    key = '$rx|$ry';
    region = null;

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
  // var region
  // var key
  // var rx
  // var ry

  public inline function getChunk( x :Float, y :Float, z :Int = TILE_LAYERS.COLLISION ) :Chunk 
  {
    return getRegion(x, y, true).getChunk(x, y, z);
  }


  public inline function getTilePosition( x :Float, y :Float, point :Point = null ) :Point
  {
    if (point == null) point = new Point();

    ix = Math.floor(x / TILE_VALUES.TILE_WIDTH);
    iy = Math.floor(y / TILE_VALUES.TILE_HEIGHT);

    point.x = (ix * TILE_VALUES.TILE_WIDTH);
    point.y = (iy * TILE_VALUES.TILE_HEIGHT);

    return point;
  }
  // var ix
  // var iy
  
  public inline function getTilePositions( x :Float, y :Float, width :Float, height :Float, points :Array<Point> ) :Array<Point>
  {
    if (points == null) points = [];

    ix = Math.floor(x);
    iy = Math.floor(y);

    while (ix <= x + width)
    {
      while (iy <= y + height)
      {
        xx = ix - Lib.remainder_int(ix, TILE_VALUES.TILE_WIDTH);
        yy = iy - Lib.remainder_int(iy, TILE_VALUES.TILE_HEIGHT);
        
        point = new Point(xx, yy);
        points.push(point);

        iy += TILE_VALUES.TILE_HEIGHT;
      }
      iy = Math.floor(y);
      ix += TILE_VALUES.TILE_WIDTH;
    }

    return points;
  }
  // var point


  public function getTile( x :Float, y :Float, z :Int ) :Tile
  {
    // trace('World.getTile');
    return getRegion(x, y, true).getTile(x, y, z);
  }


  public function setTile( x :Float, y :Float, z :Int, type :UInt ) :Bool
  {
    // trace('World.setTile');
    return getRegion(x, y, true).setTile(x, y, z, type);
  }
  // var region :Region

  public function touchTile( x :Float, y :Float, z :Int ) :Void
  {
    getRegion(x, y, true).touchTile(x, y, z);
  }
  // var region :Region


  public function getCollision( x :Float, y :Float ) :UInt
  {
    return getRegion(x, y, true).getCollision(x, y);
  }
  // var region :Region

  public function setCollision( x :Float, y :Float, tile :Tile = null ) :Void
  {
    getRegion(x, y, true).setCollision( x, y, tile );
  }
  // var region :Region

  

  inline function renderRegions() :Void
  {
    // trace('World.renderRegions');

    for( key in regions.keys() )
    {
      region = regions.get(key);
      bitmap = regionBitmaps.get(key);

      // Update the region's image
      if (region.dirty) 
        bitmap.bitmapData = region.bitmapData;

      bitmap.x = region.x - camera.x;
      bitmap.y = region.y - camera.y;
      
      if (testRegionOutOfBounds( bitmap.x, bitmap.y ))
      {
        if (regionsOnScreen.indexOf(key) >= 0)
        {
          regionSprite.removeChild(bitmap);
          regionsOnScreen.remove(key);  
        }
      }
      else
      {
        if (regionsOnScreen.indexOf(key) < 0)
        {
          regionSprite.addChild(bitmap);
          regionsOnScreen.push(key);
        }
      }
    }
  }
  // var region :Region
  // var bitmap :Bitmap


  inline function createRegion( x :Int, y :Int ) :Region
  {
    // trace('World.createRegion');

    key = '$x|$y';
    region = RegionPool.instance.get();
    rx = x * WORLD_VALUES.REGION_WIDTH;
    ry = y * WORLD_VALUES.REGION_HEIGHT;

    region.init(rx, ry, this);
    bitmap = new Bitmap(region.bitmapData, PixelSnapping.ALWAYS, true);

    regions.set(key, region);
    regionBitmaps.set(key, bitmap);

    return region;
  }
  // var key :String
  // var region :Region
  // var bitmap :Bitmap
  // var rx :Int
  // var ry :Int


  inline function testRegionOutOfBounds( x :Float, y :Float ) :Bool
  {
    if (camera == null) throw new Error("Can't test Region Bounds without [camera].");

    return (x + WORLD_VALUES.REGION_WIDTH  < 0 ||
            y + WORLD_VALUES.REGION_HEIGHT < 0 ||
            x > camera.bounds.width / camera.scaleX ||
            y > camera.bounds.height / camera.scaleY);
  }


  var region :Region;
  var bitmap :Bitmap;
  var key :String;
  var point :Point;
  var rx :Int;
  var ry :Int;
  var ix :Int;
  var iy :Int;
  var xx :Int;
  var yy :Int;

}
