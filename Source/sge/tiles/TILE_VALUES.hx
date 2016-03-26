package sge.tiles;

@:publicFields
class TILE_VALUES {

  static inline var TILE_WIDTH  :Int = 16;
  static inline var TILE_HEIGHT :Int = 16;

  static var HALF_TILE_WIDTH    :Float = TILE_WIDTH * 0.5;
  static var HALF_TILE_HEIGHT   :Float = TILE_HEIGHT * 0.5;

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
