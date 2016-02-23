package samples.brickBreaker;


import openfl.display.Shape;
import openfl.display.Graphics;
import sge.Game;
import sge.geom.Motion;
import sge.collision.AABB;
import sge.geom.base.Rectangle;


class Ball 
{

  public var shape :Shape;
  public var motion :Motion;

  public var x :Float;
  public var y :Float;
  public var radius: Float;

  public var ballControleTimer :Int;

  public var board_bounds :AABB;


  public function new() 
  { 

    shape = new Shape();
    motion = new Motion();
    x = y = 0;
    ballControleTimer = 0;
    radius = 10;

  }


  public function reset() :Void
  {
    
    x = board_bounds.x + (board_bounds.width * 0.5) - radius;
    y = board_bounds.y + board_bounds.height - 120 - radius;

    motion.velocityX = 3;
    motion.velocityY = 3;
    motion.accelerationX = 1;
    motion.accelerationY = 1;

  }

  public function update() :Void
  {
    
    motion.update( Game.delta );

    x += motion.velocityX;
    y += motion.velocityY;

  }


  public function render() :Void
  {

    var g = shape.graphics;

    g.clear();
    g.beginFill(0x335599, 1);

    g.drawCircle(x, y, radius);

    g.endFill();

  }


}