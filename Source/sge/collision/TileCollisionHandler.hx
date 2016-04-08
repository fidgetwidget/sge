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

  var debug :Bool = false;

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
    if (collisions == null) collisions = new Array();
    else while (collisions.length > 0) collisions.pop();

    collisions = collision_bounds(rect.x, rect.y, rect.width, rect.height, collisions);

    return collisions != null && collisions.length > 0;
  }
  // var xx :Float;
  // var yy :Float;
  // var hw :Float;
  // var hh :Float;
  // var collisions :Array<Collision>;


  public function collide( aabb :AABB, collisions :Array<Collision> ) :Array<Collision>
  {
    collisions = collision_bounds(aabb.left, aabb.top, aabb.width, aabb.height, collisions);

    return collisions;
  }


  inline function collision_bounds( x :Float, y :Float, width :Float, height :Float, collisions :Array<Collision> = null ) :Array<Collision>
  {
    var text = '';
    if (collisions == null) collisions = new Array();

    xx = x;
    yy = y;
    hw = width * 0.5;
    hh = height * 0.5;
    cx = x + hw;
    cy = y + hh;

    while (xx <= x + width)
    {
      while (yy <= y + height)
      {
        dir = tiles.getCollision(xx, yy);
        tx = Math.floor(xx / TILE_WIDTH) * TILE_WIDTH;
        ty = Math.floor(yy / TILE_HEIGHT) * TILE_HEIGHT;

        if (dir != 0)
        {
          if (debug) text += '($dir|$tx|$ty|$x|$y|$width|$height)';

          collision = collision_tile_bounds( dir, tx, ty, cx, cy, hw, hh, collision );
          if (collision != null)
          {
            collisions.push(collision.clone());
          }
        }
        yy += Math.min( TILE_HEIGHT, hh );
      }
      yy = y;
      xx += Math.min( TILE_WIDTH, hw );
    }

    if (debug) Game.debug.setLabel('collisionBounds', text);

    return collisions;
  }
  // var collision :Collision;
  // var xx :Float;
  // var yy :Float;
  // var cx :Float;
  // var cy :Float;
  // var hw :Float;
  // var hh :Float;


  inline function collision_tile_point( dir :UInt, tx :Int, ty :Int, x :Float, y :Float, collision :Collision = null ) :Collision
  {
    return collision_tile_bounds(dir, tx, ty, x, y, 0, 0, collision);
  }

  inline function collision_tile_aabb( dir :UInt, tx :Int, ty :Int, aabb :AABB, collision :Collision = null ) :Collision
  {
    return collision_tile_bounds(dir, tx, ty, aabb.centerX, aabb.centerY, aabb.halfWidth, aabb.halfHeight, collision);
  }

  inline function collision_tile_rect( dir :UInt, tx :Int, ty :Int, rect :Rectangle, collision :Collision = null ) :Collision
  {
    if (dir == 0) return null;

    hw = rect.width * 0.5;
    hh = rect.height * 0.5;

    return collision_tile_bounds(dir, tx, ty, rect.x + hw, rect.y + hh, hw, hh, collision);
  }
  // var hw :Float
  // var hh :Float


  inline function collision_tile_bounds( dir :UInt, tx :Int, ty :Int, cx :Float, cy :Float, hw :Float, hh :Float, collision :Collision = null ) :Collision
  {
    if (dir == 0) return null;

    dx = (tx + HALF_TILE_WIDTH) - (cx);
    px = (HALF_TILE_WIDTH + hw) - Math.abs(dx);

    if (px <= 0) return null;

    dy = (ty + HALF_TILE_HEIGHT) - (cy);
    py = (HALF_TILE_HEIGHT + hh) - Math.abs(dy);

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
    var text = '';
    if (debug) text = '{$px|$py}';
    // Ensure tile direction allows for collision
    if (dir & DIRECTION.ALL == DIRECTION.ALL)
    {
      if (debug) text += 'ALL[$dir]';

      // if (Math.abs(px) > HALF_TILE_WIDTH)
      // {
      //   px = px > 0 ? px - TILE_WIDTH : px + TILE_WIDTH;
      // }

      // if (Math.abs(py) > HALF_TILE_HEIGHT)
      // {
      //   py = py > 0 ? py - TILE_HEIGHT : py + TILE_HEIGHT;
      // }
    }
    else
    {
      if (dir & DIRECTION.VERTICAL == DIRECTION.VERTICAL)
      {
        if (debug) text += 'VERTICAL[$dir]';

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

        // if (Math.abs(py) > HALF_TILE_HEIGHT)
        // {
        //   py = py > 0 ? py - TILE_HEIGHT : py + TILE_HEIGHT;
        // }

      }
      else if (dir & DIRECTION.HORIZONTAL == DIRECTION.HORIZONTAL)
      {
        if (debug) text += 'HORIZONTAL[$dir]';

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

        // if (Math.abs(px) > HALF_TILE_WIDTH)
        // {
        //   px = px > 0 ? px - TILE_WIDTH : px + TILE_WIDTH;
        // }

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

    if (px == 0 && py == 0) 
    {

      if (debug)
      {
        text += '(NONE)';
        Game.debug.setLabel('cleanCollision', text);  
      }

      return null;
    }

    if (collision == null) collision = new Collision();

    collision.px = px;
    collision.py = py;

    if (debug)
    {
      text += '($px|$py)';
      Game.debug.setLabel('cleanCollision', text);  
    }

    return collision;

  }

  var dx :Float;
  var dy :Float;
  var px :Float;
  var py :Float;
  var xx :Float;
  var yy :Float;
  var cx :Float;
  var cy :Float;
  var hw :Float;
  var hh :Float;
  var tx :Int;
  var ty :Int;
  var collision :Collision;
  var collisions :Array<Collision>;

}
