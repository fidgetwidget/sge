package games.tileworld;


import sge.lib.Pool;


class RegionPool extends Pool<Region> {

  public static var instance (get, null) :RegionPool;
  static function get_instance() :RegionPool return (instance == null ? new RegionPool() : instance);

  override function createNew() :Region  return new Region();

}

