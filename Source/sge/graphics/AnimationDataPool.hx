package sge.graphics;


import sge.lib.Pool;

class AnimationDataPool extends Pool<AnimationData> {

  public static var instance (get, null) :AnimationDataPool;

  static function get_instance() :AnimationDataPool return (instance == null ? instance = new AnimationDataPool() : instance);


  override function createNew() :AnimationData
  {
    count++;
    return { name: "", looping: true, frameRate: 30.0, frames: [] };
  }

  override public function push( item :AnimationData ) :Void
  {
    available.push( AnimationDataPool.clean(item) );
  }

  public static function clean( data :AnimationData ) :AnimationData
  {
    data.name = "";
    data.looping = true;
    data.frameRate = 30.0;
    while (data.frames.length > 0) data.frames.pop();

    return data;
  }

}

