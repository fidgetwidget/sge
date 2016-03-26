package games.tileworld;

@:publicFields
class CONST {

  static inline var GRAVITY_ACCELERATION :Float = 1;

  static inline var REGION_CHUNKS_WIDE :Int = 4;
  static inline var REGION_CHUNKS_HIGH :Int = 4;

  static inline var CHUNK_TILES_WIDE :Int = 16;
  static inline var CHUNK_TILES_HIGH :Int = 16;

  static var REGION_TILES_WIDE :Int = REGION_CHUNKS_WIDE * CHUNK_TILES_WIDE;
  static var REGION_TILES_HIGH :Int = REGION_CHUNKS_HIGH * CHUNK_TILES_HIGH;

  static inline var TILE_WIDTH :Int = 16;
  static inline var TILE_HEIGHT :Int = 16;

  static inline var CLUMP_TILES_WIDE :Int = 3;
  static inline var CLUMP_TILES_HIGH :Int = 3;

  static var CHUNK_WIDTH :Int = CHUNK_TILES_WIDE * TILE_WIDTH;
  static var CHUNK_HEIGHT :Int = CHUNK_TILES_HIGH * TILE_HEIGHT;

  static var REGION_WIDTH :Int = REGION_CHUNKS_WIDE * CHUNK_WIDTH;
  static var REGION_HEIGHT :Int = REGION_CHUNKS_HIGH * CHUNK_HEIGHT;

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

}
