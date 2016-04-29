package samples.basic;


import openfl.display.Graphics;
import openfl.display.Shape;
import openfl.ui.Keyboard;
import sge.Game;
import sge.Lib;
import sge.entity.Entity;
import sge.collision.Collider;
import sge.collision.shapes.Circle;


class Player extends Entity {

  static var MOVE_SPEED = 360;
  var circle :Circle;
  var radius :Int = 30;

  public function new() 
  {
    super();
    circle = new Circle(0, 0, radius);
    collider = new Collider(_transform, circle);
    linearDrag = 0.25;
    velocityLimit = 30 * 60 * 100;
  }

  public function handleInput() :Void
  {

    var input = Game.inputManager;

    if (input.keyboard.isDown(Keyboard.LEFT))
    {
      accelerationX = MOVE_SPEED * -1;
    }
    else if (input.keyboard.isDown(Keyboard.RIGHT))
    {
      accelerationX = MOVE_SPEED;
    }
    else
    {
      accelerationX = 0;
    }

    if (input.keyboard.isDown(Keyboard.UP))
    {
      accelerationY = MOVE_SPEED * -1;
    }
    else if (input.keyboard.isDown(Keyboard.DOWN))
    {
      accelerationY = MOVE_SPEED;
    }
    else
    {
      accelerationY = 0;
    }

  }

}
