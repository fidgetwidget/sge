package sge.world;

import openfl.display.BitmapData;
import openfl.errors.Error;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import sge.collision.DIRECTION;
import sge.graphics.RenderTarget;
import sge.graphics.TileFrame;
import sge.geom.CoordMap;
import sge.tiles.Tile;
import sge.tiles.TileCollection;
import sge.tiles.NEIGHBORS;
import sge.tiles.TILE_VALUES;
import sge.tiles.TILE_TYPES;
import sge.tiles.TILE_LAYERS;


// A Simple render object that is neighbor aware
class Region extends RenderTarget implements TileCollection {


  // x :Int
  
  // y :Int
  
  // z :Int

  // bitmapData :BitmapData

  // dirty :Bool

  public var world :World;

  public var chunks :Map<Int, CoordMap<Chunk>>;
  var background_chunks :CoordMap<Chunk>;
  var foreground_chunks :CoordMap<Chunk>;
  var collision_chunks :CoordMap<Chunk>;

  var bg_bitmap :BitmapData;
  var fg_bitmap :BitmapData;
  var col_bitmap :BitmapData;

  public var tileCollision :CoordMap<UInt>;

  public var dirtyBgFrames :Array<TileFrame>;
  public var dirtyFgFrames :Array<TileFrame>;
  public var dirtyColFrames :Array<TileFrame>;

  public function new() 
  { 
    super();
    var w :Int, h :Int;
    w = WORLD_VALUES.REGION_WIDTH;
    h = WORLD_VALUES.REGION_HEIGHT;

    _target = new Point();
    _chunkRect = new Rectangle(0, 0, WORLD_VALUES.CHUNK_WIDTH, WORLD_VALUES.CHUNK_HEIGHT);
    _regionRect = new Rectangle(0, 0, w, h);

    // initBitmapData(WORLD_VALUES.REGION_WIDTH, WORLD_VALUES.REGION_HEIGHT);
    _frame.bitmapData = new BitmapData(w, h, true, 0xff0000);

    bg_bitmap = new BitmapData(w, h, true, 0);
    fg_bitmap = new BitmapData(w, h, true, 0);
    col_bitmap = new BitmapData(w, h, true, 0);

    chunks = new Map();

    background_chunks = new CoordMap();
    foreground_chunks = new CoordMap();
    collision_chunks  = new CoordMap();

    tileCollision = new CoordMap();
    dirtyBgFrames = [];
    dirtyFgFrames = [];
    dirtyColFrames = [];

    chunks.set(TILE_LAYERS.BACKGROUND, background_chunks);
    chunks.set(TILE_LAYERS.FOREGROUND, foreground_chunks);
    chunks.set(TILE_LAYERS.COLLISION,  collision_chunks);
  }


  override public function dispose() :Void
  {
    super.dispose();

    RegionPool.instance.push(this);
  }


  public function init( x :Int, y :Int, world :World ) :Void
  {
    this.world = world;

    _frame.x = x;
    _frame.y = y;
    _frame.z = 0;
    _dirty = true;

    init_chunks();
    init_collision();
  }

  public inline function getChunk( x :Float, y :Float, z :Int ) :Chunk
  {
    ix = Math.floor( (x - this.x) / WORLD_VALUES.CHUNK_WIDTH );
    iy = Math.floor( (y - this.y) / WORLD_VALUES.CHUNK_HEIGHT );

    return chunks.get(z).getAt(ix, iy);
  }
  // var ci :Int


  public inline function getTile( x :Float, y :Float, z :Int ) :Tile
  {
    chunk = getChunk(x, y, z);

    return chunk.getTile( x, y, this );
  }
  // var ci :Int
  // var chunk :Chunk

  public function setTile( x :Float, y :Float, z :Int, type :UInt ) :Bool
  {
    chunk = getChunk(x, y, z);

    if ( !chunk.setTile(x, y, type, this) )
      return false;

    if (z == TILE_LAYERS.COLLISION) setCollision( x, y );

    switch (z)
    {
      case TILE_LAYERS.BACKGROUND:
        dirtyBgFrames.push(chunk.frame);
      case TILE_LAYERS.FOREGROUND:
        dirtyFgFrames.push(chunk.frame);
      case TILE_LAYERS.COLLISION:
        dirtyColFrames.push(chunk.frame);
    }

    _dirty = true;

    updateNeighbors( getTile(x, y, z), x, y );

    return true;
  }
  // var ci :Int
  // var chunk :Chunk

  public function touchTile( x :Float, y :Float, z :Int ) :Void
  {
    chunk = getChunk(x, y, z);

    chunk.touchTile(x, y, this);

    switch (z)
    {
      case TILE_LAYERS.BACKGROUND:
        dirtyBgFrames.push(chunk.frame);
      case TILE_LAYERS.FOREGROUND:
        dirtyFgFrames.push(chunk.frame);
      case TILE_LAYERS.COLLISION:
        dirtyColFrames.push(chunk.frame);
    }

    _dirty = true;

    // updateNeighbors( getTile(x, y, z), x, y );
  }
  // var ci :Int
  // var chunk :Chunk


  public function getCollision( x :Float, y :Float ) :UInt
  {
    ix = Math.floor( (x - this.x) / TILE_VALUES.TILE_WIDTH );
    iy = Math.floor( (y - this.y) / TILE_VALUES.TILE_HEIGHT );

    return tileCollision.getAt(ix, iy);
  }
  // var tci :Int

  public function setCollision( x :Float, y :Float, tile :Tile = null ) :Void
  {
    if (tile == null) 
    {
      tile = getTile(x, y, TILE_LAYERS.COLLISION);
    }
    else if (tile.z != TILE_LAYERS.COLLISION) 
    {
      return;
    }

    ix = Math.floor( (x - this.x) / TILE_VALUES.TILE_WIDTH );
    iy = Math.floor( (y - this.y) / TILE_VALUES.TILE_HEIGHT );

    if ( tile.type != TILE_TYPES.NONE )
    {
      tileCollision.setAt(ix, iy, NEIGHBORS.inverse( tile.neighbors ) );
    }
    else
    {
      tileCollision.setAt(ix, iy, DIRECTION.NONE );
    }
  }
  // var tile :Tile
  // var tci :Int


  inline function init_chunks() :Void
  {
    ix = iy = 0;

    while (ix < WORLD_VALUES.REGION_CHUNKS_WIDE)
    {
      while (iy < WORLD_VALUES.REGION_CHUNKS_HIGH)
      {
        chunk = createChunk(ix, iy, TILE_LAYERS.BACKGROUND);
        background_chunks.setAt(ix, iy, chunk);
        dirtyBgFrames.push(chunk.frame);

        chunk = createChunk(ix, iy, TILE_LAYERS.FOREGROUND);
        foreground_chunks.setAt(ix, iy, chunk);
        dirtyFgFrames.push(chunk.frame);

        chunk = createChunk(ix, iy, TILE_LAYERS.COLLISION);
        collision_chunks.setAt(ix, iy, chunk);
        dirtyColFrames.push(chunk.frame);

        iy++;
      }
      iy = 0;
      ix++;
    }
  }
  // var ix :Int
  // var iy :Int
  // var ci :Int

  inline function init_collision() :Void
  {
    ix = iy = 0;

    while (ix < WORLD_VALUES.REGION_TILES_WIDE)
    {
      while (iy < WORLD_VALUES.REGION_TILES_HIGH)
      {
        tileCollision.setAt(ix, iy, DIRECTION.NONE);
        iy++;
      }
      iy = 0;
      ix++;
    }
  }


  inline function createChunk( x :Int, y :Int, z :Int ) :Chunk
  {
    // trace('Region:createChunk( $x, $y, $z )');

    var xx :Int, yy :Int;
    var chunk :Chunk;

    chunk = ChunkPool.instance.get();
    xx = x * WORLD_VALUES.CHUNK_WIDTH;
    yy = y * WORLD_VALUES.CHUNK_HEIGHT;

    chunk.init(xx, yy, z);
    return chunk;
  }

  override function updateBitmapData() :Void
  {
    while( dirtyBgFrames.length > 0) 
    {
      df = dirtyBgFrames.pop();
      _target.x = df.x;
      _target.y = df.y;
      bg_bitmap.copyPixels(df.bitmapData, _chunkRect, _target);
    }

    while ( dirtyFgFrames.length > 0)
    {
      df = dirtyFgFrames.pop();
      _target.x = df.x;
      _target.y = df.y;
      fg_bitmap.copyPixels(df.bitmapData, _chunkRect, _target); 
    }

    while ( dirtyColFrames.length > 0)
    {
      df = dirtyColFrames.pop();
      _target.x = df.x;
      _target.y = df.y;
      col_bitmap.copyPixels(df.bitmapData, _chunkRect, _target); 
    }

    _target.x = _target.y = 0;
    _frame.bitmapData.copyPixels(bg_bitmap,  _regionRect, _target);
    _frame.bitmapData.copyPixels(col_bitmap, _regionRect, _target, null, null, true);
    _frame.bitmapData.copyPixels(fg_bitmap,  _regionRect, _target, null, null, true);

    _dirty = false;
  }
  // var df :TileFrame
  

  inline function updateNeighbors( tile :Tile, x :Float, y :Float ) :Void
  {
    // TODO: make these var's class scope namesafe and move them out of here
    var tw  :Int = TILE_VALUES.TILE_WIDTH; // tile width
    var th  :Int = TILE_VALUES.TILE_HEIGHT; // tile height
    var htw :Float = TILE_VALUES.HALF_TILE_WIDTH;
    var hth :Float = TILE_VALUES.HALF_TILE_HEIGHT;
    var n   :UInt = 0;
    var ni  :UInt = 0;

    var neighborTile :Tile; // neighbor tile
    var ntxi :Int; // tile neighbor x index
    var ntyi :Int; // tile neighbor y index
    var ntx  :Float; // tile neighbor x world position
    var nty  :Float; // tile neighbor y world position
    
    var ntype :UInt; // the neighbor's neighbor value
    var ttype :UInt; // the tile's neighbor value

    var tileNeighborsValue :UInt = 0;
    var neighborTileNValue :UInt;

    // Sides
    // 
    // NORTH -> EAST -> SOUTH -> WEST
    // (SOUTH, WEST, NORTH, EAST)
    while (ni < TILE_VALUES.NEIGHBOR_TYPES.length)
    {
      // get the offset neighbor
      ntxi = TILE_VALUES.NEIGHBOR_OFFSETS[n]; n++;
      ntyi = TILE_VALUES.NEIGHBOR_OFFSETS[n]; n++;
      ntx = x + (tw * ntxi);
      nty = y + (th * ntyi);

      // get the neighborTile and tell the world that it needs to be updated
      neighborTile = world.getTile(ntx, nty, tile.z);

      ntype = TILE_VALUES.NEIGHBOR_TYPES[ni]; ni++; // the NEIGHBOR value for the side
      ttype = NEIGHBORS.opposite_side(ntype);       // the opposite side

      neighborTile.setNeighborType(ntype, tile.type);
      tile.setNeighborType(ttype, neighborTile.type);

      // if (tile.type != neighborTile.type) {
      //   neighborTile.setNeighborType(ntype, tile.type);
      //   tile.setNeighborType(ttype, neighborTile.type);  
      // } else {
      //   neighborTile.setNeighborType(ntype, TILE_TYPES.NONE);
      //   tile.setNeighborType(ttype, TILE_TYPES.NONE);  
      // }

      if (neighborTile.type != TILE_TYPES.NONE)
        tileNeighborsValue |= ttype;
      
      // for some reason doing the += or -= isn't triggering the changeNeighbors
      neighborTileNValue = neighborTile.neighbors;
      if (tile.type == TILE_TYPES.NONE)
        neighborTileNValue &= ~ntype;
      else 
        neighborTileNValue |= ntype;  
      neighborTile.neighbors = neighborTileNValue;

      if (tile.z == TILE_LAYERS.COLLISION) 
      {
        world.setCollision( ntx, nty, neighborTile );
      }

      world.touchTile(ntx, nty, tile.z);
    }

    tile.neighbors = tileNeighborsValue;
    if (tile.z == TILE_LAYERS.COLLISION) 
    {
      world.setCollision( x, y, tile );
    }
  }


  var df :TileFrame; // dirty frame
  var ix :Int;
  var iy :Int;
  var ci :Int;
  var tci :Int;
  var tcd :Int;
  var tile :Tile;
  var chunk :Chunk;
  var _target :Point;
  var _chunkRect :Rectangle;
  var _regionRect :Rectangle;

  inline function toString() :String return 'Region{ x:$x y:$y }';

}
