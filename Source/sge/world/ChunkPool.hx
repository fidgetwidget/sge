package sge.world;


import sge.lib.pool.Pool;


class ChunkPool extends Pool<Chunk> {

  public static var instance (get, null) :ChunkPool;

  static function get_instance() :ChunkPool return (instance == null ? instance = new ChunkPool() : instance);

  override function createNew() :Chunk
  {
    count++;
    return new Chunk();
  }

}
