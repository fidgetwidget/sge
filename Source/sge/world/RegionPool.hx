package sge.world;


import sge.lib.pool.Pool;


class RegionPool extends Pool<Region> {

  public static var instance (get, null) :RegionPool;

  static function get_instance() :RegionPool return (instance == null ? instance = new RegionPool() : instance);

  override function createNew() :Region
  {
    count++;
    return new Region();
  }

}
