package games.tileworld;

import openfl.display.BitmapData;


class Tile {

  
  public var x (get, never) :Int;
  public var y (get, never) :Int;
  public var worldX (get, never) :Int;
  public var worldY (get, never) :Int;

  public var layer (get, never) :Int;
  public var type (get, never) :UInt;
  public var modifier (get, never) :UInt;

  public var neighbors (get, set) :Int;
  public var corners (get, set) :Int;

  public var chunk (default, null) :Chunk;
  public var data (default, null) :TileData;
  public var sides :Array<Int>;

  public function new() 
  { 
    data = {
      x: 0,
      y: 0,
      layer: 0,
      bitmapData: new BitmapData( CONST.TILE_WIDTH, CONST.TILE_HEIGHT, true, 0 )
    }
    sides = [0,0,0,0];
  }


  public function set( chunk: Chunk, x :Int, y :Int, type :UInt, layer :Int = 0, modifier :Int = 0 ) :Void
  {
    this.chunk = chunk;

    data.x = x;
    data.y = y;
    data.layer = layer;

    _type = type;
    _modifier = modifier;

    setTileImage();

  }

  public function change( type :UInt, modifier :Int = -1) :Void
  {
    if (type >= 0) _type = type;
    if (modifier >= 0) _modifier = modifier;

    setTileImage();
  }

  public function setSide( neighborVal :Int, type :Int ) :Void
  {
    var sideIndex = NEIGHBORS.getSideIndex(neighborVal);

    if (sides[sideIndex] != type)
    {
      sides[sideIndex] = type;
      setTileImage();
    }
  }



  // 
  // Internal
  // 

  inline function init_frame() :Void
  {
    
  }

  inline function setTileImage() :Void
  {
    TYPES.setBitmapToTileType(data.bitmapData, _type, _modifier, _neighbors);
    if (type != TYPES.NONE)
      TYPES.setTileBitmapSides(data.bitmapData, type, sides);
  }

  // 
  // Properties
  // 

  var _type     :UInt;
  var _modifier :UInt;
  var _neighbors :UInt;
  var _corners :UInt;

  inline function get_x() :Int return data.x;
  inline function set_x( value :Int ) :Int return data.x = value;

  inline function get_y() :Int return data.y;
  inline function set_y( value :Int ) :Int return data.y = value;

  inline function get_layer() :Int return data.layer;

  inline function get_type() :UInt return _type;

  inline function get_modifier() :UInt return _modifier;

  inline function get_neighbors() :Int return _neighbors;

  inline function set_neighbors( value :Int ) :Int 
  {
    if (_neighbors != value) changeTileNeighbors(value);
    return _neighbors;
  }

  inline function changeTileNeighbors( neighbors :UInt ) :Void
  {
    _neighbors = neighbors;
    setTileImage();
  }


  inline function get_corners() :Int return _corners;

  inline function set_corners( value :Int ) :Int
  {
    if (_corners != value) changeTileCorners(value);
    return _corners;
  }

  inline function changeTileCorners( corners :UInt ) :Void
  {
    _corners = corners;
    // setTileImage();
  }

  inline function get_worldX() :Int return chunk.worldX + this.x;
  inline function get_worldY() :Int return chunk.worldY + this.y;
  

}
