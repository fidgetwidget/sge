package games.tileworld;


import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.errors.Error;
import openfl.errors.RangeError;
import openfl.geom.Point;
import openfl.geom.Rectangle;


// 
// TODO: Move the draw region bounds
//  out of here, and make it possible
//  to render the lines outside of the
//  world image (so that it's not
//  scaled to the world scale)
// 

class Region {

  public var x :Int;
  public var y :Int;
  public var cache (get, never) :BitmapData;
  public var dirty (get, never) :Bool;

  public var world (default, null) :World;
  public var chunks (default, null) :Array<Chunk>;
  var changedChunks :Array<Chunk>;
  var mapData :BitmapData;
  var mapDirty :Bool;
  

  public function new() 
  { 
    chunks = new Array();
    changedChunks = new Array();
    _chunkRect = new Rectangle(0, 0, CONST.CHUNK_WIDTH, CONST.CHUNK_HEIGHT);
    _chunkTarget = new Point();
  }


  public inline function set( world :World, x :Int, y :Int ) :Void
  {
    this.world = world;
    this.x = x;
    this.y = y;
    init_chunks();
    init_data();
  }


  // public inline function setTile( x :Float, y :Float, tile :Tile ) :Void
  // {
  //   var chunk = getChunk(x, y);
  //   chunk.setTile(x, y, tile);
  //   chunkChanged(chunk);
  // }


  public function setTileType( x :Float, y :Float, tileType :Int, layer :UInt = LAYERS.BASE ) :Void
  {
    chunk = getChunk(x, y);
    chunk.setTileType( x, y, tileType, layer );
    chunkChanged(chunk);
  }


  public inline function getTile( x :Float, y :Float, layer :UInt = LAYERS.BASE ) :Tile
  {
    index = worldPosition_chunkIndex(x, y);
    chunk = chunks[index];
    return chunk.getTile(x, y, layer);
  }


  public inline function getChunk( x:Float, y :Float ) :Chunk
  {
    index = worldPosition_chunkIndex(x, y);
    return chunks[index];
  }

  // This isn't really a thing, they are indexed in a 1D array 
  // because we don't need to support negative indexes
  public inline function getChunkKey( x:Float, y :Float ) :String
  {
    chunkX = Math.floor((x - this.x) / CONST.CHUNK_WIDTH);
    chunkY = Math.floor((y - this.y) / CONST.CHUNK_HEIGHT);
    return '$chunkX|$chunkY';
  }


  public inline function getTileType( x :Float, y :Float ) :Int
  {
    return getTile(x, y).type;
  }


  public inline function chunkChanged( chunk :Chunk ) :Void
  {
    if (changedChunks.indexOf(chunk) >= 0) return;
    changedChunks.push(chunk);
  }


  public inline function getMap() :BitmapData
  {
    if (mapDirty) updateMap();
    return mapData;
  }


  // 
  // Internal Functions
  // 

  inline function init_chunks() : Void
  {
    for (cyi in 0...CONST.REGION_CHUNKS_HIGH)
    {
      for (cxi in 0...CONST.REGION_CHUNKS_WIDE)
      {
        chunk = getNewChunk();
        xx = cxi * CONST.CHUNK_WIDTH;
        yy = cyi * CONST.CHUNK_HEIGHT;

        chunk.set(this, xx, yy);
        chunks.push(chunk);
        chunkChanged(chunk);
      }
    }
  }


  inline function init_data() :Void 
  { 
    _cache = new BitmapData( CONST.REGION_WIDTH, CONST.REGION_HEIGHT, false );
    mapData = new BitmapData( CONST.REGION_TILES_WIDE, CONST.REGION_TILES_HIGH, false );
    mapDirty = true;
  }


  inline function getNewChunk() : Chunk  return new Chunk(); // ChunkPool.getChunk();


  inline function getIndex( x :Int , y :Int ) :Int return (y * CONST.REGION_CHUNKS_WIDE) + x;


  inline function worldPosition_chunkIndex( x :Float, y :Float ) :Int
  {
    if (x < this.x || x > this.x + CONST.REGION_WIDTH ||
        y < this.y || y > this.y + CONST.REGION_HEIGHT)
    {
      trace('getting Chunk index for position: $x|$y in region position ${this.x}|${this.y}');
      throw new RangeError("world position outside of the region.");
    }

    ix = Math.floor( (x - this.x) / CONST.CHUNK_WIDTH );
    iy = Math.floor( (y - this.y) / CONST.CHUNK_HEIGHT );

    return getIndex(ix, iy);
  }


  inline function updateCache() :Void
  {
    changeCount = 0;
    while (changedChunks.length > 0 && changeCount < MAX_CHANGE_COUNT)
    {
      chunk = changedChunks.shift();
      // trace('region cache update for chunk @ ${chunk.x}|${chunk.y}');
      _chunkTarget.x = chunk.x;
      _chunkTarget.y = chunk.y;
      _cache.copyPixels(chunk.cache, _chunkRect, _chunkTarget);
      changeCount++;
    }
  }

  inline function updateMap() :Void
  {
    if (_chunkMapRect == null) _chunkMapRect = new Rectangle(0, 0, CONST.CHUNK_TILES_WIDE, CONST.CHUNK_TILES_HIGH);
    if (_chunkMapTarget == null) _chunkMapTarget = new Point();

    for (cyi in 0...CONST.REGION_CHUNKS_HIGH)
    {
      for (cxi in 0...CONST.REGION_CHUNKS_WIDE)
      {
        xx = cxi * CONST.CHUNK_WIDTH;
        yy = cyi * CONST.CHUNK_HEIGHT;
        chunk = getChunk(xx, yy);
        _chunkMapTarget.x = cxi;
        _chunkMapTarget.x = cyi;
        _chunkMap = chunk.getMap();
        mapData.copyPixels(_chunkMap, _chunkMapRect, _chunkMapTarget);
      }
    }
  }

  var MAX_CHANGE_COUNT = 4;
  var _chunkRect :Rectangle;
  var _chunkMapRect :Rectangle;
  var _chunkTarget :Point;
  var _chunkMapTarget :Point;
  var _chunkMap :BitmapData;
  var changeCount :Int;
  var chunk :Chunk;
  var index :Int;
  var chunkX :Int;
  var chunkY :Int;
  var cxi :Int;
  var cyi :Int;
  var xx :Int;
  var yy :Int;
  var ix :Int;
  var iy :Int;

  // 
  // Properties
  // 

  var _cache :BitmapData;

  inline function get_dirty() :Bool return changedChunks.length > 0;

  inline function get_cache() :BitmapData
  {
    if (dirty) updateCache();
    return _cache;
  }

}
