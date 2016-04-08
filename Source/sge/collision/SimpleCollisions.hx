package sge.collision;

// 
// Static helpers for collision scenarios
// 
@:publicFields
class SimpleCollisions
{

  // 
  // AABB -> Point (x,y) Collision
  // 
  static function aabb_point_collision( aabb :AABB, x :Float, y :Float, ?collision :Collision ) :Bool
  {

    if (!aabb.contains_point(x, y)) return false;
    
    var dx = x - aabb.centerX;
    if (Math.abs(dx) < aabb.halfWidth)
    {
      var dy = y - aabb.centerY;
      if (Math.abs(dy) < aabb.halfHeight)
      {

        if (collision == null) return true;

        collision.px = dx;
        collision.py = dy;

        return true;

      } 
    }
    return false;

  }

  // 
  // AABB -> AABB Collision
  // 
  static function aabb_aabb_collision( aabb1 :AABB, aabb2 :AABB, ?collision :Collision ) :Bool
  {

    var dx = aabb2.centerX - aabb1.centerX;
    var px = (aabb2.halfWidth + aabb1.halfWidth) - Math.abs(dx);
    if (px > 0)
    {
      var dy = aabb2.centerY - aabb1.centerY;
      var py = (aabb2.halfHeight + aabb1.halfHeight) - Math.abs(dy);
      if (py > 0)
      {

        if (collision == null) return true;

        if (dx < 0) px *= -1; 
        if (dy < 0) py *= -1;

        collision.px = px;
        collision.py = py;

        return true;

      } 
    }
    return false;

  }

  // 
  // AABB -> Circle (x, y, radius) Collision
  // 
  static function aabb_circle_collision( aabb :AABB, x :Float, y :Float, radius :Float, ?collision :Collision ) :Bool
  {

    var dx = x - aabb.centerX;
    var px = (radius + aabb.halfWidth) - Math.abs(dx);
    if (px > 0)
    {
      var dy = y - aabb.centerY;
      var py = (radius + aabb.halfHeight) - Math.abs(dy);
      if (py > 0)
      {

        if (collision == null) return true;

        if (dx < 0) px *= -1; 
        if (dy < 0) py *= -1;

        collision.px = px;
        collision.py = py;

        return true;

      } 
    }
    return false;

  }


}
