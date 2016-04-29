package sge.lib;


@:publicFields
class MathHelper
{
  
  static inline function distanceBetween ( x1 :Float, y1 :Float, x2 :Float, y2 :Float ) : Float
  {
    var dx :Float = x1 - x2;
    var dy :Float = y1 - y2;

    return Math.sqrt(dx * dx + dy * dy);
  }

}