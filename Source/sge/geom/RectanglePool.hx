package sge.geom;

import openfl.geom.Rectangle;
import sge.lib.pool.Pool;


class RectanglePool extends Pool<Rectangle> {

  public static var instance (get, null) :RectanglePool;

  static function get_instance() :RectanglePool return (instance == null ? instance = new RectanglePool() : instance);

  override function createNew() :Rectangle
  {
    count++;
    return new Rectangle();
  }

}

