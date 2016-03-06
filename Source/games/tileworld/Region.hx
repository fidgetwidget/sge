package games.tileworld;


import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.errors.Error;
import openfl.errors.RangeError;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import sge.geom.CoordMap;

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
  public var chunks (default, null) :CoordMap<Chunk>;

  var changedChunks :Array<Chunk>;
  var tileObjects :Array<TileObject>;

  var mapData :BitmapData;
  var mapDirty :Bool;
  

  public function new() 
  { 
    chunks = new CoordMap();
    changedChunks = new Array();
    tileObjects = new Array();

    _chunkRect = new Rectangle(0, 0, CONST.CHUNK_WIDTH, CONST.CHUNK_HEIGHT);
    _chunkTarget = new Point();
    _tObjRect = new Rectangle();
    _tObjTarget = new Point();
  }


  public inline function set( world :World, x :Int, y :Int ) :Void
  {
    this.world = world;
    this.x = x;
    this.y = y;
    init_chunks();
    init_data();
  }



  public function addTileObject( tileObject :TileObject ) :Void
  {
    tileObjects.push(tileObject);
  }

  // Not In Use
  // 
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
    // index = worldPosition_chunkIndex(x, y);
    // chunk = chunks[index];
    
    ix = Math.floor( (x - this.x) / CONST.CHUNK_WIDTH );
    iy = Math.floor( (y - this.y) / CONST.CHUNK_HEIGHT );

    chunk = chunks.getAt(ix, iy);

    return chunk.getTile(x, y, layer);
  }

  public inline function getTileType( x :Float, y :Float ) :Int
  {
    return getTile(x, y).type;
  }


  public inline function getChunk( x:Float, y :Float ) :Chunk
  {
    // index = worldPosition_chunkIndex(x, y);

    ix = Math.floor( (x - this.x) / CONST.CHUNK_WIDTH );
    iy = Math.floor( (y - this.y) / CONST.CHUNK_HEIGHT );

    return chunks.getAt(ix, iy);
    // return chunks[index];
  }

  // This isn't really a thing, they are indexed in a 1D array 
  // because we don't need to support negative indexes
  public inline function getChunkKey( x:Float, y :Float ) :String
  {
    ix = Math.floor((x - this.x) / CONST.CHUNK_WIDTH);
    iy = Math.floor((y - this.y) / CONST.CHUNK_HEIGHT);
    return '$ix|$iy';
  }

  public inline function chunkChanged( chunk :Chunk ) :Void
  {
    if (changedChunks.indexOf(chunk) >= 0) return;
    changedChunks.push(chunk);
  }


  // public inline function getMap() :BitmapData
  // {
  //   if (mapDirty) updateMap();
  //   return mapData;
  // }


  // 
  // Internal Functions
  // 

  inline function init_chunks() : Void
  {
    for (cyi in 0...CONST.REGION_CHUNKS_HIGH)
    {
      for (cxi in 0...CONST.REGION_CHUNKS_WIDE)
      {
        chunk = ChunkPool.instance.get();
        xx = cxi * CONST.CHUNK_WIDTH;
        yy = cyi * CONST.CHUNK_HEIGHT;

        chunk.set(this, xx, yy);
        chunks.setAt(cxi, cyi, chunk);
        // chunks.push(chunk);
        chunkChanged(chunk);
      }
    }
  }


  inline function init_data() :Void 
  { 
    _cache = new BitmapData( CONST.REGION_WIDTH, CONST.REGION_HEIGHT, true, 0 );
    _bg = new BitmapData( CONST.REGION_WIDTH, CONST.REGION_HEIGHT, true, 0 );
    _fg = new BitmapData( CONST.REGION_WIDTH, CONST.REGION_HEIGHT, true, 0 );

    mapData = new BitmapData( CONST.REGION_TILES_WIDE, CONST.REGION_TILES_HIGH, false );
    mapDirty = true;
  }


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

    for (tObj in tileObjects)
    {
      _tObjRect.width = tObj.width;
      _tObjRect.height = tObj.height;
      _tObjRect.x = this.x - tObj.x;
      _tObjRect.x = this.y - tObj.y;
      _cache.copyPixels(tObj.image, _tObjRect, _tObjTarget);
    }
  }


  var ix :Int;
  var iy :Int;
  var xx :Int;
  var yy :Int;
  var cxi :Int;
  var cyi :Int;
  var index :Int;
  var chunkX :Int;
  var chunkY :Int;
  var chunk :Chunk;
  var changeCount :Int;

  var _tObjRect :Rectangle;
  var _tObjTarget :Point;
  var _chunkRect :Rectangle;
  var _chunkTarget :Point;

  var MAX_CHANGE_COUNT = 4;

  // 
  // Properties
  // 

  var _cache :BitmapData;
  var _bg :BitmapData;
  var _fg :BitmapData;

  inline function get_dirty() :Bool return changedChunks.length > 0;

  inline function get_cache() :BitmapData
  {
    if (dirty) updateCache();
    return _cache;
  }

}
