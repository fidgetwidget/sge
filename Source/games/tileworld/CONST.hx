package games.tileworld;

@:publicFields
class CONST {

  static var REGION_CHUNKS_WIDE :Int = 4;
  static var REGION_CHUNKS_HIGH :Int = 4;

  static var CHUNK_TILES_WIDE :Int = 16;
  static var CHUNK_TILES_HIGH :Int = 16;

  static var REGION_TILES_WIDE :Int = REGION_CHUNKS_WIDE * CHUNK_TILES_WIDE;
  static var REGION_TILES_HIGH :Int = REGION_CHUNKS_HIGH * CHUNK_TILES_HIGH;

  static var TILE_WIDTH :Int = 16;
  static var TILE_HEIGHT :Int = 16;

  static var CLUMP_TILES_WIDE :Int = 3;
  static var CLUMP_TILES_HIGH :Int = 3;

  static var CHUNK_WIDTH :Int = CHUNK_TILES_WIDE * TILE_WIDTH;
  static var CHUNK_HEIGHT :Int = CHUNK_TILES_HIGH * TILE_HEIGHT;

  static var REGION_WIDTH :Int = REGION_CHUNKS_WIDE * CHUNK_WIDTH;
  static var REGION_HEIGHT :Int = REGION_CHUNKS_HIGH * CHUNK_HEIGHT;

}
