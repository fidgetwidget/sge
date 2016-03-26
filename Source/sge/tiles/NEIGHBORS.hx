package sge.tiles;

@:publicFields
class NEIGHBORS {

  static inline var NONE  :UInt = 0;

  static inline var NORTH :UInt = 1;
  static inline var EAST  :UInt = 2;
  static inline var SOUTH :UInt = 4;
  static inline var WEST  :UInt = 8;

  static var SIDES        :UInt = NORTH | EAST | SOUTH | WEST;
  static var HORIZONTAL   :UInt = EAST | WEST;
  static var VERTICAL     :UInt = NORTH | SOUTH;

  static inline var NORTH_WEST  :UInt = 16;
  static inline var NORTH_EAST  :UInt = 32;
  static inline var SOUTH_EAST  :UInt = 64;
  static inline var SOUTH_WEST  :UInt = 128;

  static var CORNERS      :UInt = NORTH_WEST | NORTH_EAST | SOUTH_EAST | SOUTH_WEST;

  static var ALL          :UInt = SIDES | CORNERS;



  static inline function inverse_sides( value :UInt ) :UInt
  {
    return inverse(value, 4);
  }

  static inline function inverse_corners( value :UInt ) :UInt
  {
    return inverse(value, 8);
  }

  // max 4 for sides, and 8 for corners
  static inline function inverse( value :UInt, max :Int = 4 ) :UInt 
  {
    var mask :UInt = (1 << max) - 1;
    return ~value & mask;
  }


  // 
  // TODO: find a better way of getting the value we need for this
  // 
  // 0000 : 0 ... 0 
  // 0001 : 1 ... 4 {0100}
  // 0010 : 2 ... 8 {1000}
  // 0100 : 4 ... 1 {0001}
  // 1000 : 8 ... 2 {0010}
  // 
  static inline function opposite_side( value :UInt ) :UInt
  {
    return value == 0 ? 0 : value >= 4 ? value >> 2 : value << 2;
  }

}
