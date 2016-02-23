package games.tileworld;


import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.errors.Error;
import openfl.errors.RangeError;
import openfl.geom.Point;
import openfl.geom.Rectangle;


class Chunk {

  public var x :Int;
  public var y :Int;
  public var cache (get, never) :BitmapData;
  public var dirty (get, never) :Bool;
  public var worldX (get, never) :Int;
  public var worldY (get, never) :Int;

  var region :Region;
  var tiles :Array<Tile>;
  public var tileCollision :Array<Int>;
  var changedTiles :Array<TileData>;


  public function new() 
  { 
    tiles = new Array();
    tileCollision = new Array();
    changedTiles = new Array();

    _tileRect = new Rectangle(0, 0, CONST.TILE_WIDTH, CONST.TILE_HEIGHT);
    _chunkRect = new Rectangle(0, 0, CONST.CHUNK_WIDTH, CONST.CHUNK_HEIGHT);
    _tileTarget = new Point();
    _zero = new Point();
  }


  public inline function set( region :Region, x :Int, y :Int ) :Void
  {
    this.region = region;
    this.x = x;
    this.y = y;

    init_tiles();
    init_cache();
  }


  public inline function setTile( x :Float, y :Float, tile :Tile ) :Void
  {
    var index = worldPosition_tileIndex(x, y);

    tiles[index] = tile;
    tileChanged(tile);
  }
  

  public function setTileType( x :Float, y :Float, tileType :Int ) :Void
  {
    var index = worldPosition_tileIndex(x, y);
    if (tiles.length < index) throw new Error("Chunk tile ["+index+"] unavailable.");
    var tile = tiles[index];
    if (tile.type == tileType) return;
    tile.change(tileType);
    updateNeighbors(tile);
    tileChanged(tile);
  }


  public inline function getTile( x :Float, y :Float ) :Tile
  {
    var index = worldPosition_tileIndex(x, y);
    return tiles[index];
  }


  public inline function getCollision( x :Float, y :Float ) :Int
  {
    var index = worldPosition_tileIndex(x, y);
    return tileCollision[index]; 
  }


  public inline function tileChanged( tile :Tile ) :Void
  {
    if (changedTiles.indexOf(tile.data) >= 0) return;
    changedTiles.push(tile.data);
    region.chunkChanged(this);
  }


  // 
  // Internal Functions
  // 

  inline function init_tiles() : Void
  {
    var txi :Int;
    var tyi :Int;
    var tx :Int;
    var ty :Int;
    var tile :Tile;

    for (tyi in 0...CONST.CHUNK_TILES_HIGH)
    {
      for (txi in 0...CONST.CHUNK_TILES_WIDE)
      {
        tile = getNewTile();
        tx = txi * CONST.TILE_WIDTH;
        ty = tyi * CONST.TILE_HEIGHT;
        
        tile.set(this, tx, ty, TYPES.NONE);
        tiles.push(tile);
        changedTiles.push(tile.data);
      }
    }
  }


  inline function init_cache() :Void
  {
    var w = CONST.CHUNK_WIDTH;
    var h = CONST.CHUNK_HEIGHT;
    _backgroundLayerBitmap = new BitmapData( w, h, true, 0 );
    _collisionLayerBitmap = new BitmapData( w, h, true, 0 );
    _cache = new BitmapData( w, h, true, 0x00ffffff );
  }


  inline function getTile_local( x :Int, y :Int ) :Tile
  {
    var index = getIndex(x, y);
    return tiles[index];
  }

  inline function getCollision_local( x :Int, y :Int ) :Int
  {
    var index = getIndex(x, y);
    return tileCollision[index]; 
  }


  inline function getNewTile() : Tile  return TilePool.instance.get();


  inline function getIndex( x :Int, y :Int ) :Int return (y * CONST.CHUNK_TILES_WIDE) + x;


  inline function getIndex_tile( tile :Tile ) :Int return Math.floor(((tile.y / CONST.TILE_HEIGHT) * CONST.CHUNK_TILES_WIDE) + tile.x / CONST.TILE_WIDTH);


  inline function worldPosition_tileIndex( x :Float, y :Float ) :Int
  {
    if (x < worldX || x > worldX + CONST.CHUNK_WIDTH ||
        y < worldY || y > worldY + CONST.CHUNK_HEIGHT)
    {
      throw new RangeError("world position outside of the chunk.");
    }
    var ix :Int = Math.floor( (x - worldX) / CONST.TILE_WIDTH );
    var iy :Int = Math.floor( (y - worldY) / CONST.TILE_HEIGHT );

    return getIndex(ix, iy);
  }
  

  inline function updateCache() :Void
  {
    while (changedTiles.length > 0)
    {
      var tile = changedTiles.shift();
      _tileTarget.x = tile.x;
      _tileTarget.y = tile.y;

      if (tile.layer == LAYERS.BACKGROUND)
        _backgroundLayerBitmap.copyPixels(tile.bitmapData, _tileRect, _tileTarget);
      if (tile.layer == LAYERS.BASE) 
        _collisionLayerBitmap.copyPixels(tile.bitmapData, _tileRect, _tileTarget);
    }

    _cache.copyPixels(_backgroundLayerBitmap, _chunkRect, _zero);
    _cache.copyPixels(_collisionLayerBitmap,  _chunkRect, _zero, null, null, true);
  }


  // 
  // NEIGHBOR_TYPES: the bitwise neighbor values
  // neithborOffsets: the x,y position index of the tile who's neighbor would be the associated neighborType
  // eg. 1 (NORTH) would have an offset of 0, 1 (the tile south of the given tile)
  // 
  static var NEIGHBOR_TYPES :Array<Int> = [1, 2, 4, 8];
  static var NEIGHBOR_OFFSETS :Array<Int> = [
     0,  1, // NORTH -> SOUTH 
    -1,  0, // EAST -> WEST
     0, -1, // SOUTH -> NORTH
     1,  0, // WEST -> EAST
   ];

  static var CORNER_TYPES :Array<Int> = [16, 32, 64, 128];
  static var CORNER_OFFSETS :Array<Int> = [
     1,  1, // NORT_WEST -> SOUTH_EAST
    -1,  1, // NORT_EAST -> SOUTH_WEST
    -1, -1, // SOUTH_EAST -> NORTH_WEST
     1, -1, // SOUTH_WEST -> NORTH_EAST
  ];

  inline function updateNeighbors( tile :Tile ) :Void
  {
    var nt  :Tile; // neighbor tile
    var tw  :Int = CONST.TILE_WIDTH;
    var th  :Int = CONST.TILE_HEIGHT;
    var htw :Float = tw * 0.5;
    var hth :Float = th * 0.5;
    var n   :UInt = 0;
    var ni  :UInt = 0;
    
    var tnx :Int; // tile neighbor x index
    var tny :Int; // tile neighbor y index
    var tx  :Float; // tile neighbor x world position
    var ty  :Float; // tile neighbor y world position
    
    var ntype :UInt;
    var ttype :UInt;
    var nval  :UInt = 0;

    // Sides
    while (ni < Chunk.NEIGHBOR_TYPES.length)
    {
      tnx = Chunk.NEIGHBOR_OFFSETS[n]; n++;
      tny = Chunk.NEIGHBOR_OFFSETS[n]; n++;
      tx = worldX + tile.x + (tw * tnx) + htw;
      ty = worldY + tile.y + (th * tny) + hth;

      // we go up to the world to make sure when we cross chunk 
      // and region we can still get the right tile
      nt = region.world.getTile(tx, ty);
      region.world.tileChanged(tx, ty);

      ntype = Chunk.NEIGHBOR_TYPES[ni]; ni++;
      ttype = ntype == 0 ? 0 : NEIGHBORS.flip(ntype);
      if (tile.type != nt.type)
      {
        nt.setSide(ntype, tile.type);
        tile.setSide(ttype, nt.type);
      }
      else 
      {
        nt.setSide(ntype, 0);
        tile.setSide(ttype, 0);
      }
      if (nt.type == TYPES.NONE) continue; // we don't care about the neighbor value of none tiles
      nval += ttype;
      // for some reason doing the += or -= isn't triggering the changeNeighbors
      var val = nt.neighbors;
      if (tile.type == TYPES.NONE)
        val = val & ~ntype;
      else 
        val = val | ntype;
        
      nt.neighbors = val;
      updateCollision_neighborsChanged(nt);
    }
    tile.neighbors = nval;
    updateCollision_neighborsChanged(tile);

    // Corners
    ni = n = 0;
    while (ni < Chunk.CORNER_TYPES.length)
    {
      tnx = Chunk.CORNER_OFFSETS[n]; n++;
      tny = Chunk.CORNER_OFFSETS[n]; n++;
      tx = worldX + tile.x + (tw * tnx) + htw;
      ty = worldY + tile.y + (th * tny) + hth;

      nt = region.world.getTile(tx, ty);
      region.world.tileChanged(tx, ty);

      ntype = Chunk.CORNER_TYPES[ni]; ni++;
      if (nt.type == TYPES.NONE) continue;
      nval += ntype == 16 ? 64 : ntype == 32 ? 128 : ntype == 64 ? 16 : ntype == 128 ? 32 : 0;
      
      var val = nt.corners;
      if (tile.type != TYPES.NONE)
        val = val | ntype;
      else
        val = val & ~ntype;
      nt.corners = val;
    }
    // corners includes the sides value
    tile.corners = nval;

    
  }

  inline function updateCollision_neighborsChanged( tile :Tile ) :Void
  {
    var index = getIndex_tile(tile);
    var val = tile.type == TYPES.NONE ? NEIGHBORS.NONE : NEIGHBORS.inverse( tile.neighbors );
    tileCollision[index] = val;
  }

  // 
  // Properties
  // 
  
  var _cache :BitmapData;
  var _backgroundLayerBitmap :BitmapData;
  var _collisionLayerBitmap  :BitmapData;
  var _tileRect :Rectangle;
  var _chunkRect :Rectangle;
  var _tileTarget :Point;
  var _zero :Point;
  var _isDirty :Bool = false;

  inline function get_dirty() :Bool return changedTiles.length > 0;

  inline function get_cache() :BitmapData
  {
    if (dirty) updateCache();
    return _cache;
  }

  inline function get_worldX() :Int return region.x + this.x;
  inline function get_worldY() :Int return region.y + this.y;

}
