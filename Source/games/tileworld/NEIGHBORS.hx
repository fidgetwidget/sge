package games.tileworld;

@:publicFields
class NEIGHBORS {

  static inline var NONE  :Int = 0;
  static inline var NORTH :Int = 1;
  static inline var EAST  :Int = 2;
  static inline var SOUTH :Int = 4;
  static inline var WEST  :Int = 8;
  static inline var NORTH_WEST  :Int = 16;
  static inline var NORTH_EAST  :Int = 32;
  static inline var SOUTH_EAST  :Int = 64;
  static inline var SOUTH_WEST  :Int = 128;

  static var SIDES        :Int = NORTH | EAST | SOUTH | WEST;
  static var HORIZONTAL   :Int = EAST | WEST;
  static var VERTICAL     :Int = NORTH | SOUTH;
  static var CORNERS      :Int = NORTH_WEST | NORTH_EAST | SOUTH_EAST | SOUTH_WEST;
  static var ALL          :Int = SIDES | CORNERS;


  // max 4 for sides, and 8 for corners
  static inline function inverse( value :Int, max :Int = 4 ) :Int 
  {
    var mask :Int = (1 << max) - 1;
    return ~value & mask;
  }

  // TODO: find a bitwise way of doing this...
  
  static function flip(value :Int) :Int
  {
    if (value == 1) return 4;
    if (value == 2) return 8;
    if (value == 4) return 1;
    if (value == 8) return 2;
    return 0;
  }

  static function getNeighborVal( index :Int ) :Int
  {
    if (index >= CONST.NEIGHBOR_TYPES.length) return 0;
    return CONST.NEIGHBOR_TYPES[index];
  }
  
  static function getSideIndex( neighbor :Int ) :Int
  {
    return CONST.NEIGHBOR_TYPES.indexOf(neighbor);
  }

}
