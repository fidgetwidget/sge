package sge.collision;

import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import sge.tiles.TileCollection;
import sge.tiles.TILE_VALUES;


// A Simple render object that is neighbor aware
class TileCollisionHandler {


  public var tiles :TileCollection;

  var TILE_WIDTH :Int;
  var TILE_HEIGHT :Int;
  var HALF_TILE_WIDTH :Float;
  var HALF_TILE_HEIGHT :Float;

  var dir :UInt;


  public function new( collection :TileCollection )
  {
    tiles = collection;
    
    TILE_WIDTH = TILE_VALUES.TILE_WIDTH;
    TILE_HEIGHT = TILE_VALUES.TILE_HEIGHT;

    HALF_TILE_WIDTH = TILE_WIDTH * 0.5;
    HALF_TILE_HEIGHT = TILE_HEIGHT * 0.5;

    collision = new Collision();
  }


  public function testCollision( x :Float, y :Float ) :Bool
  {
    dir = tiles.getCollision(x, y);
    if (dir == 0) return false;

    tx = Math.floor(x - Lib.remainder_float(x, TILE_WIDTH));
    ty = Math.floor(y - Lib.remainder_float(y, TILE_HEIGHT));
    
    return (collision_tile_point( dir, tx, ty, x, y, collision ) != null);
  }
  // var tx :Float;
  // var ty :Float;


  public function testCollision_rectagle( rect :Rectangle ) :Bool
  {
    xx = rect.x;
    yy = rect.y;
    hw = rect.width * 0.5;
    hh = rect.height * 0.5;

    while (xx <= rect.x + rect.width)
    {
      while (yy <= rect.y + rect.height)
      {
        
        dir = tiles.getCollision(xx, yy);
        if (dir == 0) 
        {
          yy += Math.min( TILE_HEIGHT, hh );
          continue;
        }

        tx = Math.floor(xx - Lib.remainder_float(xx, TILE_WIDTH));
        ty = Math.floor(yy - Lib.remainder_float(yy, TILE_HEIGHT));

        if ( collision_tile_rect( dir, tx, ty, rect, collision ) != null) return true;

        yy += Math.min( TILE_HEIGHT, hh );
      }
      yy = rect.y;
      xx += Math.min( TILE_WIDTH, hw );
    }

    return false;
  }
  // var xx :Float;
  // var yy :Float;
  // var hw :Float;
  // var hh :Float;


  public function collide( aabb :AABB, collisions :Array<Collision> ) :Array<Collision>
  {
    var _text = '';
    if (collisions == null) collisions = new Array();

    xx = aabb.left;
    yy = aabb.top;

    while (xx <= aabb.right)
    {
      while (yy <= aabb.bottom)
      {
        dir = tiles.getCollision(xx, yy);
        tx = Math.floor(xx / TILE_WIDTH) * TILE_WIDTH;
        ty = Math.floor(yy / TILE_HEIGHT) * TILE_HEIGHT;

        if (dir != 0)
        {
          collision = collision_tile_aabb( dir, tx, ty, aabb, collision );
          if (collision != null)
          {
            collisions.push(collision.clone());
          }
        }
        yy += Math.min( TILE_HEIGHT, aabb.halfHeight );
      }
      yy = aabb.top;
      xx += Math.min( TILE_WIDTH, aabb.halfWidth );
    }

    Game.debug.setLabel('collision', _text);

    return collisions;
  }
  // var collision :Collision;
  // var xx :Float;
  // var yy :Float;



  inline function collision_tile_aabb( dir :UInt, tx :Int, ty :Int, aabb :AABB, collision :Collision = null ) :Collision
  {
    if (dir == 0) return null;

    dx = (tx + HALF_TILE_WIDTH) - (aabb.centerX);
    px = (HALF_TILE_WIDTH + aabb.halfWidth) - Math.abs(dx);

    if (px <= 0) return null;

    dy = (ty + HALF_TILE_HEIGHT) - (aabb.centerY);
    py = (HALF_TILE_HEIGHT + aabb.halfHeight) - Math.abs(dy);

    if (py <= 0) return null;

    px *= dx > 0 ? 1 : -1;
    py *= dy > 0 ? 1 : -1;

    return cleanCollision( dir, px, py, collision );
  }
  // var dx :Float;
  // var dy :Float;
  // var px :Float;
  // var py :Float;


  inline function collision_tile_rect( dir :UInt, tx :Int, ty :Int, rect :Rectangle, collision :Collision = null ) :Collision
  {
    hw = rect.width * 0.5;
    hh = rect.height * 0.5;

    dx = tx + HALF_TILE_WIDTH - (rect.x + hw);
    px = (HALF_TILE_WIDTH + hw) - Math.abs(dx);

    if (px <= 0) return null;

    dy = ty + HALF_TILE_HEIGHT - (rect.y + hh);
    py = (HALF_TILE_HEIGHT + hh) - Math.abs(dy);

    if (py <= 0) return null;

    px *= dx > 0 ? 1 : -1;
    py *= dy > 0 ? 1 : -1;

    return cleanCollision( dir, px, py, collision );
  }
  // var hw :Float;
  // var hh :Float;
  // var dx :Float;
  // var dy :Float;
  // var px :Float;
  // var py :Float;


  inline function collision_tile_point( dir :UInt, tx :Int, ty :Int, x :Float, y :Float, collision :Collision = null ) :Collision
  {
    dx = tx + HALF_TILE_WIDTH - x;
    px = HALF_TILE_WIDTH - Math.abs(dx);

    if (px <= 0) return null;

    dy = ty + HALF_TILE_HEIGHT - y;
    py = HALF_TILE_HEIGHT - Math.abs(dy);

    if (py <= 0) return null;

    px *= dx > 0 ? 1 : -1;
    py *= dy > 0 ? 1 : -1;

    return cleanCollision( dir, px, py, collision );
  }
  // var dx :Float;
  // var dy :Float;
  // var px :Float;
  // var py :Float;


  inline function cleanCollision( dir :UInt, px :Float, py :Float, collision :Collision = null ) :Collision 
  {
    // Ensure tile direction allows for collision
    if (dir & DIRECTION.ALL == DIRECTION.ALL)
    {

    }
    else
    {
      if (dir & DIRECTION.VERTICAL != 0)
      {
        // up & down are fine as is, lets check for left or right
        if (dir & DIRECTION.LEFT != 0)
        {
          while (px < 0) px += TILE_WIDTH;
        } 
        else if (dir & DIRECTION.RIGHT != 0) 
        {
          while (px > 0) px -= TILE_WIDTH;
        }
        else
        {
          px = 0;
        }

        if (Math.abs(py) > HALF_TILE_HEIGHT)
        {
          // trace('collision improvement condiction met.');
          // TODO: flip the collision direction
        }

      }
      else if (dir & DIRECTION.HORIZONTAL != 0)
      {
        // left & right are fine as is, lets check for up or down
        if (dir & DIRECTION.UP != 0)
        {
          while (py < 0) py += TILE_HEIGHT;
        }
        else if (dir & DIRECTION.DOWN != 0)
        {
          while (py > 0) py -= TILE_HEIGHT;
        }
        else
        {
           py = 0;
        }

        if (Math.abs(px) > HALF_TILE_WIDTH)
        {
          // trace('collision improvement condiction met.');
          // TODO: flip the collision direction
        }

      }
      else
      {
        // no sides are safe, test them all
        
        if (dir & DIRECTION.LEFT != 0)
        {
          while (px < 0) px += TILE_WIDTH;
        } 
        else if (dir & DIRECTION.RIGHT != 0) 
        {
          while (px > 0) px -= TILE_WIDTH;
        }
        else
        {
          px = 0;
        }

        if (dir & DIRECTION.UP != 0)
        {
          while (py < 0) py += TILE_HEIGHT;
        }
        else if (dir & DIRECTION.DOWN != 0)
        {
          while (py > 0) py -= TILE_HEIGHT;
        }
        else
        {
           py = 0;
        }
      }
      
    }

    if (px == 0 && py == 0) return null;

    if (collision == null) collision = new Collision();

    collision.px = px;
    collision.py = py;

    return collision;

  }

  var dx :Float;
  var dy :Float;
  var px :Float;
  var py :Float;
  var xx :Float;
  var yy :Float;
  var hw :Float;
  var hh :Float;
  var tx :Int;
  var ty :Int;
  var collision :Collision;

}
