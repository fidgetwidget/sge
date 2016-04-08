package games.tileworld_old;


import sge.lib.Pool;


class TilePool extends Pool<Tile> {

  public static var instance (get, null) :TilePool;
  
  static function get_instance() :TilePool return (instance == null ? instance = new TilePool() : instance);

}

