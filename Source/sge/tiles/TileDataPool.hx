package sge.tiles;


import sge.lib.pool.Pool;


class TileDataPool extends Pool<TileData> {

  public static var instance (get, null) :TileDataPool;
  
  static function get_instance() :TileDataPool return (instance == null ? instance = new TileDataPool() : instance);

  override function createNew() :TileData
  {
    count++;
    
    return { 
      x: 0, y: 0, z: 0, 
      type: 0, 
      neighbors: 0, corners: 0, 
      neighborType_north: 0, neighborType_east: 0, neighborType_south: 0, neighborType_west: 0 
    };
  }

  override public function push( item :TileData ) :Void
  {
    available.push( TileDataPool.clean(item) );
  }

  public static function clean( data :TileData ) :TileData
  {
    data.x = data.y = data.z = 0;
    data.type = 0;
    data.neighbors = data.corners = 0;
    data.neighborType_north = data.neighborType_east = data.neighborType_south = data.neighborType_west = 0;

    return data;
  }

}
