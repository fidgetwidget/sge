package sge.geom;

import openfl.geom.Point;
import sge.lib.Pool;


class VectorPool extends Pool<Vector> {

  public static var instance (get, null) :VectorPool;

  static function get_instance() :VectorPool return (instance == null ? instance = new VectorPool() : instance);

  override function createNew() :Vector
  {
    count++;
    return new Vector();
  }

  override public function push( item :Vector ) :Void
  {
    available.push( VectorPool.clean(item) );
  }

  public static function clean( vector :Vector ) :Vector
  {
    vector.x = vector.y = 0.0;
    return vector;
  }

}

