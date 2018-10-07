package sge.lib.pool;


import sge.lib.pool.Pool;


class IntArrayPool extends Pool<Array<Int>> {

  public static var instance (get, null) :IntArrayPool;
  
  static function get_instance() :IntArrayPool return (instance == null ? instance = new IntArrayPool() : instance);

  override function createNew() :Array<Int>
  {
    count++;
    return [];
  }

  override public function push( item :Array<Int> ) :Void
  {
    available.push( IntArrayPool.clean(item) );
  }

  public static function clean( array :Array<Int> ) :Array<Int>
  {
    while (array.length > 0) array.pop();

    return array;
  }

}
