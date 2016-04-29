package sge.collision.shapes;


import sge.lib.Pool;


class ShapeCollisionPool extends Pool<ShapeCollision> {

  public static var instance (get, null) :ShapeCollisionPool;
  
  static function get_instance() :ShapeCollisionPool return (instance == null ? instance = new ShapeCollisionPool() : instance);

  override function createNew() :ShapeCollision
  {
    count++;
    return new ShapeCollision();
  }

  override public function push( item :ShapeCollision ) :Void
  {
    available.push( item.reset() );
  }

}
