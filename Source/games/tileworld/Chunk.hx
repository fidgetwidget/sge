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
  // OPTIONS: Possible optimization - turn the tile object into arrays of values in the chunk
  var tiles :Array<Tile>;
  var tiles_bg :Array<Tile>;
  var tiles_locked :Array<Int>;

  var changedTiles :Array<TileData>;
  public var tileCollision :Array<Int>;
  


  public function new() 
  { 
    tiles = new Array();
    tiles_bg = new Array();
    tiles_locked = new Array();
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
    init_data();
  }


  public inline function setTile( x :Float, y :Float, tile :Tile ) :Void
  {
    var index = worldPosition_tileIndex(x, y);

    if (tile.layer == LAYERS.BASE)
      tiles[index] = tile;
    if (tile.layer == LAYERS.BACKGROUND)
      tiles_bg[index] = tile;

    tileChanged(tile);
  }
  

  public inline function lockTile( x :Float, y :Float, layer :Int = LAYERS.BASE, unlock :Bool = false ) :Void
  {
    var index = worldPosition_tileIndex(x, y);

    // locked[index] == 0 for all layers unlocked, 1 for collision locked, 2 for background, 4 for foerground 
    // 1 << 0 (1) 
    // 1 << 1 (2)
    // 1 << 2 (4)

    if (unlock)
      tiles_locked[index] = 0;
    else
      tiles_locked[index] |= 1 << layer;
  }


  inline function isLocked( index :Int, layer :Int = LAYERS.BASE ) :Bool
  {
    return (tiles_locked[index] & (1 << layer) != 0);
  }


  public inline function removeTile( x :Float, y :Float, layer :Int = LAYERS.BASE ) :Void
  {
    setTileType(x, y, TYPES.NONE, layer);
  }


  public function setTileType( x :Float, y :Float, tileType :Int, layer :Int = LAYERS.BASE, force :Bool = false ) :Void
  {
    var index = worldPosition_tileIndex(x, y);
    if (tiles.length < index) throw new Error("Chunk tile ["+index+"] unavailable.");

    if (isLocked(index, layer) && !force) return;

    if (tiles_locked[index] == 1 + layer ) return;
    var tile = layer == LAYERS.BASE ? tiles[index] : tiles_bg[index];

    if (tile.type == tileType) return;

    tile.change(tileType);
    updateNeighbors(tile);
    tileChanged(tile);
  }


  public inline function getTile( x :Float, y :Float, layer :UInt = LAYERS.BASE ) :Tile
  {
    var index = worldPosition_tileIndex(x, y);
    return layer == LAYERS.BACKGROUND ?  tiles_bg[index] : tiles[index];
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

    for (tyi in 0...CONST.CHUNK_TILES_HIGH)
    {
      for (txi in 0...CONST.CHUNK_TILES_WIDE)
      {
        tx = txi * CONST.TILE_WIDTH;
        ty = tyi * CONST.TILE_HEIGHT;

        init_tile(tx, ty);
        init_tile_bg(tx, ty);
        tiles_locked.push(0); // defailt all blocked to false
      }
    }
  }

  inline function init_tile( tx :Int, ty :Int ) :Void
  {
    var tile :Tile = getNewTile();
    tile.set(this, tx, ty, TYPES.NONE);
    tiles.push(tile);
    changedTiles.push(tile.data);
  }

  inline function init_tile_bg( tx :Int, ty :Int ) :Void
  {
    var tile = getNewTile();
    tile.set(this, tx, ty, TYPES.NONE, LAYERS.BACKGROUND);
    tiles_bg.push(tile);
    changedTiles.push(tile.data);
  }


  inline function init_data() :Void
  {
    var w = CONST.CHUNK_WIDTH;
    var h = CONST.CHUNK_HEIGHT;
    _backgroundLayerBitmap = new BitmapData( w, h, true, 0 );
    _collisionLayerBitmap = new BitmapData( w, h, true, 0 );
    _cache = new BitmapData( w, h, true, 0 );
    _mapData = new BitmapData( CONST.CHUNK_TILES_WIDE, CONST.CHUNK_TILES_HIGH, false, TYPES.NONE_RGB);
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
  // static var NEIGHBOR_TYPES :Array<Int> = [1, 2, 4, 8];
  // static var NEIGHBOR_OFFSETS :Array<Int> = [
  //    0,  1, // SOUTH (: NORTH [1])
  //   -1,  0, // WEST  (: EAST  [2])
  //    0, -1, // NORTH (: SOUTH [4])
  //    1,  0, // EAST  (: WEST  [8])
  //  ];

  // static var CORNER_TYPES :Array<Int> = [16, 32, 64, 128];
  // static var CORNER_OFFSETS :Array<Int> = [
  //    1,  1, // NORT_WEST -> SOUTH_EAST
  //   -1,  1, // NORT_EAST -> SOUTH_WEST
  //   -1, -1, // SOUTH_EAST -> NORTH_WEST
  //    1, -1, // SOUTH_WEST -> NORTH_EAST
  // ];

  inline function updateNeighbors( tile :Tile ) :Void
  {
    // TODO: make these var's class scope namesafe and move them out of here
    var nt  :Tile; // neighbor tile
    var tw  :Int = CONST.TILE_WIDTH; // tile width
    var th  :Int = CONST.TILE_HEIGHT; // tile height
    var htw :Float = tw * 0.5; // half tile width
    var hth :Float = th * 0.5; // half tile height
    var n   :UInt = 0;
    var ni  :UInt = 0;
    
    var tnx :Int; // tile neighbor x index
    var tny :Int; // tile neighbor y index
    var tx  :Float; // tile neighbor x world position
    var ty  :Float; // tile neighbor y world position
    
    var ntype :UInt; // the neighbor's neighbor value
    var ttype :UInt; // the tile's neighbor value
    var nval  :UInt = 0;
    var layer :UInt = tile.layer;

    // Sides
    // 
    // NORTH -> EAST -> SOUTH -> WEST
    // (SOUTH, WEST, NORTH, EAST)
    while (ni < CONST.NEIGHBOR_TYPES.length)
    {
      // get the offset neighbor
      tnx = CONST.NEIGHBOR_OFFSETS[n]; n++;
      tny = CONST.NEIGHBOR_OFFSETS[n]; n++;
      tx = tile.worldX + (tw * tnx);
      ty = tile.worldY + (th * tny);

      // get the neighbor tile (nt) and tell the world that it needs to be updated
      nt = region.world.getTile(tx, ty, layer);

      ntype = CONST.NEIGHBOR_TYPES[ni]; ni++;
      ttype = NEIGHBORS.flip(ntype);
      if (tile.type != nt.type) // TODO: change this to allow for tiles that don't connect
      {
        nt.setSide(ntype, tile.type);
        tile.setSide(ttype, nt.type);
      }
      else
      {
        nt.setSide(ntype, NEIGHBORS.NONE);
        tile.setSide(ttype, NEIGHBORS.NONE);
      }
      if (nt.type != TYPES.NONE)
        nval |= ttype;
      
      // for some reason doing the += or -= isn't triggering the changeNeighbors
      var val = nt.neighbors;
      if (tile.type == TYPES.NONE)
        val &= ~ntype;
      else 
        val |= ntype;
        
      nt.neighbors = val;
      if (layer == LAYERS.COLLISION) 
        updateCollision_neighborsChanged(nt);

      region.world.touchTile(tx, ty);
    }
    tile.neighbors = nval;
    if (layer == LAYERS.COLLISION) 
      updateCollision_neighborsChanged(tile);

    // Corners
    // ni = n = 0;
    // while (ni < CONST.CORNER_TYPES.length)
    // {
    //   tnx = CONST.CORNER_OFFSETS[n]; n++;
    //   tny = CONST.CORNER_OFFSETS[n]; n++;
    //   tx = worldX + tile.x + (tw * tnx) + htw;
    //   ty = worldY + tile.y + (th * tny) + hth;

    //   nt = region.world.getTile(tx, ty, layer);
    //   region.world.touchTile(tx, ty);

    //   ntype = CONST.CORNER_TYPES[ni]; ni++;
    //   if (nt.type != TYPES.NONE)
    //     nval += ntype == 16 ? 64 : ntype == 32 ? 128 : ntype == 64 ? 16 : ntype == 128 ? 32 : 0;
      
    //   var val = nt.corners;
    //   if (tile.type != TYPES.NONE)
    //     val = val | ntype;
    //   else
    //     val = val & ~ntype;
    //   nt.corners = val;
    // }
    // // corners includes the sides value
    // tile.corners = nval;

  }

  inline function updateCollision_neighborsChanged( tile :Tile ) :Void
  {
    if (tile.chunk != this) 
    { 
      tile.chunk.updateCollision_neighborsChanged(tile);
    }
    else
    if (tile.layer == LAYERS.COLLISION) 
    {
      var index = getIndex_tile(tile);
      var val = tile.type == TYPES.NONE ? NEIGHBORS.NONE : NEIGHBORS.inverse( tile.neighbors );
      tileCollision[index] = val;
    }
  }


  var _backgroundLayerBitmap :BitmapData;
  var _collisionLayerBitmap  :BitmapData;

  var _tileRect   :Rectangle;
  var _chunkRect  :Rectangle;
  var _tileTarget :Point;
  var _zero       :Point;
  var _mapData    :BitmapData;


  // 
  // Properties
  // 
  
  var _cache :BitmapData;

  inline function get_dirty() :Bool return changedTiles.length > 0;

  inline function get_cache() :BitmapData
  {
    if (dirty) updateCache();
    return _cache;
  }

  inline function get_worldX() :Int return region.x + this.x;
  inline function get_worldY() :Int return region.y + this.y;

}
