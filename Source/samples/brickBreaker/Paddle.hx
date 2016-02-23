package samples.brickBreaker;


import openfl.display.Shape;
import openfl.display.Graphics;
import sge.Game;
import sge.geom.Motion;
import sge.collision.AABB;


class Paddle 
{

  public var shape :Shape;
  public var motion :Motion;

  public var x :Float;
  public var y :Float;
  public var width: Float;
  public var height :Float;

  public var bounds :AABB;
  public var board_bounds :AABB;


  public function new() 
  { 

    shape = new Shape();
    motion = new Motion();
    x = y = 0;
    width = 100;
    height = 20;

    bounds = new AABB();
    bounds.width = width;
    bounds.height = height;

  }


  public function reset() :Void
  {

    x = board_bounds.x + (board_bounds.width * 0.5) - (this.width * 0.5);
    y = board_bounds.y + board_bounds.height - 20 - (this.height * 0.5);

    motion.dragX = 10;
    motion.velocityX = 0;
    motion.velocityY = 0;

  }


  public function update() :Void
  {
    
    motion.update( Game.delta );

    x += motion.velocityX;

  }


  public function render() :Void
  {

    var g = shape.graphics;

    g.clear();
    g.beginFill(0x3377FF, 1);

    g.drawRect(x, y, width, height);

    g.endFill();

  }


  public function getBounds() :AABB
  {
    bounds.x = x;
    bounds.y = y;
    return bounds;
  }


}