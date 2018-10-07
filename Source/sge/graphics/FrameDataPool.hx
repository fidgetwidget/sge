package sge.graphics;

import openfl.geom.Point;
import openfl.geom.Rectangle;
import sge.lib.pool.Pool;


class FrameDataPool extends Pool<FrameData> {

  public static var instance (get, null) :FrameDataPool;

  static function get_instance() :FrameDataPool return (instance == null ? instance = new FrameDataPool() : instance);


  override function createNew() :FrameData
  {
    count++;
    return { name: "", source: null, rect: new Rectangle(), origin: new Point(), bitmapData: null };
  }

  override public function push( item :FrameData ) :Void
  {
    available.push( FrameDataPool.clean(item) );
  }

  public static function clean( data :FrameData ) :FrameData
  {
    data.name = "";
    data.source = null;
    data.rect.x = data.rect.y = data.rect.width = data.rect.height = 0;
    data.origin.x = data.origin.y = 0;
    data.bitmapData = null;

    return data;
  }

}

