package sge.geom;

import openfl.geom.Point;
import sge.lib.Pool;


class PointPool extends Pool<Point> {

  public static var instance (get, null) :PointPool;

  static function get_instance() :PointPool return (instance == null ? instance = new PointPool() : instance);

  override function createNew() :Point
  {
    count++;
    return new Point();
  }

}

