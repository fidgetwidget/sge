package games.tileworld;

import openfl.display.BitmapData;


class TileObject {

  
  public var x :Int;
  public var y :Int;
  public var width (get, never) :Int;
  public var height (get, never) :Int;

  public var tiles_wide (get, never) :Int;
  public var tiles_high (get, never) :Int;
  public var center_tile_x (get, never) :Int;
  public var center_tile_y (get, never) :Int;
  
  public var image (get, never) :BitmapData;
  public var tileFrames :Array<TileFrameData>;

  public var placed :Bool = false;

  var data :TileObjectData;


  public function new( data :TileObjectData ) 
  { 
    this.data = data;
    _image = new BitmapData( width, height, true, 0xffffff );
  }


  public function canPlace( world :World, x :Float, y :Float ) :Bool
  {
    if (data.emptyReq == null) return true;
    
    var coord = world.getTileCoord(x, y);

    // 1) Test if the required placement space is free...
    var emptyReq = Rectangle(
      coord.x + data.emptyReq.x, coord.y + data.emptyReq.y, 
      data.emptyReq.width, data.emptyReq.height);

    if (world.tileCollision(emptyReq)) return false;
    
    if (data.collisionReq == null) return true;

    // 2) Test if the required structure is in place
    var collisionReq = Rectangle(
      coord.x + data.collisionReq.x, coord.y + data.collisionReq.y, 
      data.collisionReq.width, data.collisionReq.height);

    return world.tileCollision(collisionReq);
  }


  public function place( world :World, x :Float, y :Float ) :Void
  {
    if (!canPlace(x, y)) return;

    var coord = world.getTileCoord(x, y);
    this.x = coord.x;
    this.y = coord.y;
    this.placed = true;

    setTileImage();
  }


  // 
  // Internal
  // 
  
  inline function setTileImage() :Void
  {
    var l = tiles_wide - center_tile_x + (CONST.TILE_WIDTH * 0.5);
    var t = tiles_high - center_tile_y + (CONST.TILE_HEIGHT * 0.5);
    var i = 0;
    for (r in 0...tiles_high)
    {
      for (c in 0...tiles_wide)
      {
        
      }
    }
    
  }


  // 
  // Properties
  // 

  var _image    :BitmapData;

  inline function get_image() :BitmapData return _image;

  inline function get_width() :Int return data.tiles_wide * CONST.TILE_WIDTH;

  inline function get_height() :Int return data.tiles_high * CONST.TILE_HEIGHT;
  
  inline function get_tiles_wide() :Int return data.tiles_wide;

  inline function get_tiles_high() :Int return data.tiles_high;

  inline function get_center_tile_x() :Int return data.center_tile_x;

  inline function get_center_tile_y() :Int return data.center_tile_y;
  
}
