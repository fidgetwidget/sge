package sge.world;


import sge.lib.Pool;


class ChunkPool extends Pool<Chunk> {

  public static var instance (get, null) :ChunkPool;
  static function get_instance() :ChunkPool return (instance == null ? new ChunkPool() : instance);

  override function createNew() :Chunk  return new Chunk();

}
