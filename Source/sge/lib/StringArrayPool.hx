package sge.lib;


import sge.lib.Pool;


class StringArrayPool extends Pool<Array<String>> {

  public static var instance (get, null) :StringArrayPool;
  
  static function get_instance() :StringArrayPool return (instance == null ? instance = new StringArrayPool() : instance);

  override function createNew() :Array<String>
  {
    count++;
    return [];
  }

  override public function push( item :Array<String> ) :Void
  {
    available.push( StringArrayPool.clean(item) );
  }

  public static function clean( array :Array<String> ) :Array<String>
  {
    while (array.length > 0) array.pop();

    return array;
  }

}
