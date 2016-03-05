package sge.graphics;

import openfl.geom.Point;
import openfl.geom.Rectangle;
import sge.lib.Pool;


class FrameDataPool extends Pool<FrameData> {

  public static var instance (get, null) :FrameDataPool;
  static function get_instance() :FrameDataPool return (instance == null ? new FrameDataPool() : instance);


  override function createNew() :FrameData
  {
    return { name: "", source: null, rect: new Rectangle(), origin: new Point(), bitmapData: null };
  }

}

