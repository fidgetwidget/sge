package sge.world;

import sge.tiles.TILE_VALUES;

@:publicFields
class WORLD_VALUES {

  static inline var CHUNK_TILES_WIDE :Int = 8;
  static inline var CHUNK_TILES_HIGH :Int = 8;

  static inline var REGION_CHUNKS_WIDE :Int = 4;
  static inline var REGION_CHUNKS_HIGH :Int = 4;
  

  // 
  // Calculated Values
  // 
  static var CHUNK_WIDTH  :Int = CHUNK_TILES_WIDE * TILE_VALUES.TILE_WIDTH;
  static var CHUNK_HEIGHT :Int = CHUNK_TILES_HIGH * TILE_VALUES.TILE_HEIGHT;

  static var REGION_TILES_WIDE :Int = REGION_CHUNKS_WIDE * CHUNK_TILES_WIDE;
  static var REGION_TILES_HIGH :Int = REGION_CHUNKS_HIGH * CHUNK_TILES_HIGH;

  static var REGION_WIDTH  :Int = REGION_TILES_WIDE * TILE_VALUES.TILE_WIDTH;
  static var REGION_HEIGHT :Int = REGION_TILES_HIGH * TILE_VALUES.TILE_HEIGHT;

}
