package games.tileworld.world;


import openfl.geom.Rectangle;
import sge.Game;
import sge.Lib;
import sge.collision.AABB;
import sge.collision.Collision;


class WorldCollisionHandler {

  var TILE_HALF_WIDTH :Float;
  var TILE_HALF_HEIGHT :Float;


  var world :World;
  // var collisionBitmaps :Map<String, Bitmap>;


  public function new( world :World ) 
  {
    this.world = world;
    // collisionBitmaps = new Map();
    TILE_HALF_WIDTH = CONST.TILE_WIDTH * 0.5;
    TILE_HALF_HEIGHT = CONST.TILE_HEIGHT * 0.5;
  }


  public function testCollision_rectagle( rect :Rectangle ) :Bool 
  {
    xx = rect.x;
    yy = rect.y;
    tile = null;

    while (xx <= rect.x + rect.width)
    {
      while (yy <= rect.y + rect.height)
      {
        tile = world.getTile(xx, yy);
        if (testCollision_rect_tile(rect, tile)) return true;

        yy += Math.min( CONST.TILE_HEIGHT, rect.height * 0.5 );
      }
      yy = rect.y;
      xx += Math.min( CONST.TILE_WIDTH, rect.width * 0.5 );
    }

    return false;
  }


  public function testCollision_point( x :Float, y :Float ) :Bool 
  {
    tile = world.getTile(x, y);
    return testCollision_point_tile(x, y, tile);
  }


  // 
  // CollisionCheck
  public function getCollisions( aabb :AABB, collisions :Array<Collision> ) :Array<Collision>
  {
    if (collisions == null) collisions = new Array();

    xx = aabb.left;
    yy = aabb.top;
    tile = null;

    while (xx <= aabb.right)
    {
      while (yy <= aabb.bottom)
      {
        tile = world.getTile(xx, yy);
        collision = collide_aabb_tile(aabb, tile);
        if (collision != null)
        {
          collisions.push(collision);
        }

        yy += Math.min( CONST.TILE_HEIGHT, aabb.halfHeight );
      }
      yy = aabb.top;
      xx += Math.min( CONST.TILE_WIDTH, aabb.halfWidth );
    }
    return collisions;
  }


  inline function testCollision_point_tile( x :Float, y :Float, tile :Tile ) :Bool
  {
    Game.debug.setLabel('collision', '$x|$y ${tile.type}');

    if (tile.type == TYPES.NONE) return false;

    return (x >= tile.worldX && x <= (tile.worldX + CONST.TILE_WIDTH) &&
            y >= tile.worldY && y <= (tile.worldY + CONST.TILE_HEIGHT));
  }


  public function testCollision_rect_tile( rect :Rectangle, tile :Tile ) :Bool
  {
    if (tile.type == TYPES.NONE) return false;

    tcx = tile.worldX + TILE_HALF_WIDTH;
    rhw = rect.width * 0.5;
    dx = tcx - (rect.x + rhw);
    px = (rhw + TILE_HALF_WIDTH) - Math.abs(dx);

    if (px <= 0) return false;

    tcy = tile.worldY + TILE_HALF_HEIGHT;
    rhh = rect.height * 0.5;
    dy = tcy - (rect.y + rhh);
    py = (rhh + TILE_HALF_HEIGHT) - Math.abs(dy);

    if (py <= 0) return false;

    return true;
  }

  // 
  // Collision for aabb
  // 
  // TODO: when a collidier allows for two opposite directions, return the direction difference that is shorter
  // 
  public function collide_aabb_tile( aabb :AABB, tile :Tile ) :Collision
  {
    if (tile.type == TYPES.NONE) return null; // need to figure out why this happens...
    
    dir = getTileCollisionValue(tile.worldX, tile.worldY);

    if (dir == NEIGHBORS.NONE) return null;

    tcx = tile.worldX + TILE_HALF_WIDTH;    
    dx = tcx - aabb.centerX;
    px = (aabb.halfWidth + TILE_HALF_WIDTH) - Math.abs(dx);

    if (px <= 0) return null;

    tcy = tile.worldY + TILE_HALF_HEIGHT;
    dy = tcy - aabb.centerY;
    py = (aabb.halfHeight + TILE_HALF_HEIGHT) - Math.abs(dy);

    if (py <= 0) return null;

    px *= dx > 0 ? 1 : -1;
    py *= dy > 0 ? 1 : -1;

    if (dir & NEIGHBORS.SIDES == NEIGHBORS.SIDES)
    {
      // Do nothing because we have all 4 directions
    }
    else
    {
      if (dir & NEIGHBORS.VERTICAL != 0)
      {
        // up & down are fine as is, lets check for left or right
        if (dir & NEIGHBORS.WEST != 0)
        {
          while (px < 0) px += CONST.TILE_WIDTH;
        } 
        else if (dir & NEIGHBORS.EAST != 0) 
        {
          while (px > 0) px -= CONST.TILE_WIDTH;
        }
        else
        {
          px = 0;
        }

        if (Math.abs(py) > CONST.TILE_HEIGHT * 0.5)
        {
          // trace('collision improvement condiction met.');
          // TODO: flip the collision direction
        }

      }
      else if (dir & NEIGHBORS.HORIZONTAL != 0)
      {
        // left & right are fine as is, lets check for up or down
        if (dir & NEIGHBORS.NORTH != 0)
        {
          while (py < 0) py += CONST.TILE_HEIGHT;
        }
        else if (dir & NEIGHBORS.SOUTH != 0)
        {
          while (py > 0) py -= CONST.TILE_HEIGHT;
        }
        else
        {
           py = 0;
        }

        if (Math.abs(px) > CONST.TILE_WIDTH * 0.5)
        {
          // trace('collision improvement condiction met.');
          // TODO: flip the collision direction
        }

      }
      else
      {
        // no sides are safe, test them all
        
        if (dir & NEIGHBORS.WEST != 0)
        {
          while (px < 0) px += CONST.TILE_WIDTH;
        } 
        else if (dir & NEIGHBORS.EAST != 0) 
        {
          while (px > 0) px -= CONST.TILE_WIDTH;
        }
        else
        {
          px = 0;
        }

        if (dir & NEIGHBORS.NORTH != 0)
        {
          while (py < 0) py += CONST.TILE_HEIGHT;
        }
        else if (dir & NEIGHBORS.SOUTH != 0)
        {
          while (py > 0) py -= CONST.TILE_HEIGHT;
        }
        else
        {
           py = 0;
        }
      }
      
    }

    if (px == 0 && py == 0) return null;

    return new Collision(px, py);
  }


  public inline function getTileCollisionValue( x :Float, y :Float ) :Int
  {
    return world.getRegion(x, y).getChunk(x, y).getCollision(x, y);
  }

  public inline function snapToTileX( x :Float ) :Int return Math.floor(x - Lib.remainder_int(Math.floor(x), CONST.TILE_WIDTH));

  public inline function snapToTileY( y :Float ) :Int return Math.floor(y - Lib.remainder_int(Math.floor(y), CONST.TILE_HEIGHT));


  var xx :Float;
  var yy :Float;
  var dx :Float;
  var px :Float;
  var dy :Float;
  var py :Float;
  var dir :Int;
  var tile :Tile;
  var tcx :Float;
  var tcy :Float;
  var rhw :Float;
  var rhh :Float;
  var collision :Collision;

}