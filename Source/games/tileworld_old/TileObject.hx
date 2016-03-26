package games.tileworld_old;

import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import sge.geom.base.Rectangle as BaseRectangle;

import games.tileworld_old.world.Region;
import games.tileworld_old.world.World;
import games.tileworld_old.world.WorldCollisionHandler;


class TileObject {

  
  public var x :Int;
  public var y :Int;
  public var width (get, never) :Int;
  public var height (get, never) :Int;
  public var tiles_wide (get, never) :Int;
  public var tiles_high (get, never) :Int;
  public var center_tile_x (get, never) :Int;
  public var center_tile_y (get, never) :Int;
  public var showForeground (get, set) :Bool;
  public var image (get, never) :BitmapData;

  // public var tileFrames :Array<TileFrameData>;
  public var placed :Bool = false;
  

  public function new() { }

  public function set( data :TileObjectData )
  {
    this.data = data;
    sourceImage = Assets.getBitmapData('objects/${data.filename}');
    initImages();
  }


  public function clone() :TileObject
  {
    var clone :TileObject = new TileObject();
    if (this.data == null) return clone;

    clone.data = this.data;
    clone.sourceImage = this.sourceImage;
    // for (tileFrame in tileFrames)
    // {
    //   clone.tileFrames.push(tileFrame);
    // }
    clone._image = this._image;
    return clone;
  }


  inline function initImages() :Void
  {
    // TODO: create tileFrameData from the sourceImage
    zero = new Point();
    _imageRect = new Rectangle();
    _image = new BitmapData( width, height, true, 0xffffff );

    // Check for a background layer
    if (data.image_rect_bg != null)
      drawLayer(data.image_rect_bg);

    // NOTE: This should NEVER be null
    if (data.image_rect != null)
      drawLayer(data.image_rect);

    // Check for a foreground layer
    if (data.image_rect_fg != null)
      drawLayer(data.image_rect_fg);
  }


  public function canPlace( collisionHandler :WorldCollisionHandler, x :Float, y :Float ) :Bool
  {
    if (data.emptyReq == null && data.emptyReqTiles == null &&
        data.collisionReq == null && data.collisionReqTiles == null) return true;

    var success :Bool = false;
    var worldTileX :Int = collisionHandler.snapToTileX(x);
    var worldTileY :Int = collisionHandler.snapToTileY(y);
    var tx :Int;
    var ty :Int;
    var i :Int;

    // 1) Test if the required placement space is free...

    if (data.emptyReq != null)
    {
      if (emptyReqRect == null) { emptyReqRect = new Rectangle(0, 0, data.emptyReq.width, data.emptyReq.height); }
      emptyReqRect.x = worldTileX + data.emptyReq.x; 
      emptyReqRect.y = worldTileY + data.emptyReq.y;
      success = !collisionHandler.testCollision_rectagle(emptyReqRect);
      if (!success) return false;
    }

    if (data.emptyReqTiles != null)
    {
      i = 0;
      while(i < data.emptyReqTiles.length)
      {
        tx = data.emptyReqTiles[i]; i++;
        ty = data.emptyReqTiles[i]; i++;

        success = !collisionHandler.testCollision_point( worldTileX + (tx * CONST.TILE_WIDTH), worldTileY + (ty * CONST.TILE_HEIGHT));
        if (!success) return false;
      }
    }
    
    // 2) Test if the required structure is in place
    
    if (data.collisionReq != null)
    {
      if (collisionReqRect == null) { collisionReqRect = new Rectangle(0, 0, data.collisionReq.width, data.collisionReq.height); }
      collisionReqRect.x = x + data.collisionReq.x; 
      collisionReqRect.y = y + data.collisionReq.y;

      success = collisionHandler.testCollision_rectagle( collisionReqRect );
      if (!success) return false;
    }

    if (data.collisionReqTiles != null)
    {
      i = 0;
      while(i < data.collisionReqTiles.length)
      {
        tx = data.collisionReqTiles[i]; i++;
        ty = data.collisionReqTiles[i]; i++;

        success = collisionHandler.testCollision_point( worldTileX + (tx * CONST.TILE_WIDTH), worldTileY + (ty * CONST.TILE_HEIGHT));
        if (!success) return false;
      }
    }

    return success;
  }


  public function place( world :World, collisionHandler :WorldCollisionHandler, x :Float, y :Float ) :Bool
  {
    if (!canPlace(collisionHandler, x, y)) return false;

    this.x = world.snapToTileX(x);
    this.y = world.snapToTileY(y);
    this.placed = true;

    placeInWorld( world );

    return true;
  }


  // 
  // Internal
  // 
  
  inline function placeInWorld( world :World ) :Void
  {
    placedInRegions = new Array();

    for (yi in 0...tiles_high)
    {
      for (xi in 0...tiles_wide) 
      {
        var region :Region = world.getRegion( this.x + (xi * CONST.TILE_WIDTH), this.y + (yi * CONST.TILE_HEIGHT) );

        if (placedInRegions.indexOf(region) < 0)
        {
          placedInRegions.push(region);
          region.addTileObject(this);
        }
      }
    }
  }


  inline function updateImage() :Void
  {
    if (data.image_rect_bg != null)
      drawLayer(data.image_rect_bg);

    if (data.image_rect != null)
      drawLayer(data.image_rect);

    if (data.image_rect_fg != null && showForeground)
      drawLayer(data.image_rect_fg);

    for (region in placedInRegions)
      copyPixels(region);
  }


  inline function copyPixels( region :Region ) :Void
  {
    if (target == null) target = new Point();
    target.x = region.x - this.x;
    target.y = region.y - this.y;

    // TODO: make sure the rectangle is only the part of the image that is in the region
    _imageRect.width = width;
    _imageRect.height = height;
    _imageRect.x = 0;
    _imageRect.y = 0;

    region.cache.copyPixels(image, _imageRect, target);
  }


  inline function drawLayer( rect :BaseRectangle ) :Void
  {
    _imageRect.x = rect.x;
    _imageRect.y = rect.y;
    _imageRect.width = rect.width;
    _imageRect.height = rect.height;

    _image.copyPixels(sourceImage, _imageRect, zero);
  }


  var _imageRect :Rectangle;
  var target :Point;
  var zero :Point;
  var placedInRegions :Array<Region>;
  var sourceImage :BitmapData;
  var data :TileObjectData;
  var emptyReqRect :Rectangle;
  var collisionReqRect :Rectangle;

  // 
  // Properties
  // 

  var _image :BitmapData;
  var _showForeground :Bool = true;

  inline function get_image() :BitmapData return _image;

  inline function get_width() :Int return data.tiles_wide * CONST.TILE_WIDTH;

  inline function get_height() :Int return data.tiles_high * CONST.TILE_HEIGHT;
  
  inline function get_tiles_wide() :Int return data.tiles_wide;

  inline function get_tiles_high() :Int return data.tiles_high;

  inline function get_center_tile_x() :Int return data.center_tile_x;

  inline function get_center_tile_y() :Int return data.center_tile_y;

  inline function get_showForeground() :Bool return _showForeground;

  inline function set_showForeground( value :Bool ) :Bool
  {
    if (_showForeground != value) 
    {
      _showForeground = value;
      updateImage();
    }
    return value;
  }
  
}
