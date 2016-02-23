package games.tileworld;

@:publicFields
class NEIGHBORS {

  static var NONE        :Int = 0;
  
  static var NORTH       :Int = 1;
  static var EAST        :Int = 2;
  static var SOUTH       :Int = 4;
  static var WEST        :Int = 8;

  static var SIDES       :Int = NORTH | EAST | SOUTH | WEST;

  static var HORIZONTAL  :Int = EAST | WEST;
  static var VERTICAL    :Int = NORTH | SOUTH;

  static var NORTH_WEST  :Int = 16;
  static var NORTH_EAST  :Int = 32;
  static var SOUTH_EAST  :Int = 64;
  static var SOUTH_WEST  :Int = 128;

  static var CORNERS     :Int = NORTH_WEST | NORTH_EAST | SOUTH_EAST | SOUTH_WEST;

  static var ALL         :Int = SIDES | CORNERS;


  // max 4 for sides, and 8 for corners
  static function inverse( value :Int, max :Int = 4 ) :Int 
  {
    var mask :Int = (1 << max) - 1;
    return ~value & mask;
  }

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
    if (index == 0) return 1;
    if (index == 1) return 2;
    if (index == 2) return 4;
    if (index == 3) return 8;
    return 0;
  }
  
  static function getSideIndex( neighbor :Int ) :Int
  {
    if (neighbor == 1) return 0;
    if (neighbor == 2) return 1;
    if (neighbor == 4) return 2;
    if (neighbor == 8) return 3;
    return 0;
  }

}
