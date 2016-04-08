package sge.graphics;


import sge.lib.Pool;


class AnimationPool extends Pool<Animation> {

  public static var instance (get, null) :AnimationPool;

  static function get_instance() :AnimationPool return (instance == null ? instance = new AnimationPool() : instance);

  override function createNew() :Animation
  {
    count++;
    return new Animation();
  }

}
