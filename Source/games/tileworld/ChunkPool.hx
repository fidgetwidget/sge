package games.tileworld;


import sge.lib.Pool;


class ChunkPool extends Pool<Chunk> {

  public static var instance (get, null) :ChunkPool;
  static function get_instance() :ChunkPool return (instance == null ? new TilChunkPoolePool() : instance);

  override function createNew() :Chunk  return new Chunk();

}
