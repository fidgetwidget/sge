package samples.basic;


import openfl.display.Graphics;
import openfl.display.Shape;
import sge.Game;
import sge.Lib;
import sge.entity.Entity;
import sge.collision.Collider;
import sge.collision.shapes.Circle;


class Ball extends Entity {

  
  var circ :Circle;


  public function new() 
  {
    super();

    var r = Lib.random_int(5, 30);

    circ = new Circle(0, 0, r);
    collider = new Collider(_transform, circ);
    linearDrag = 0.1;
    velocityLimit = 30 * 60 * 100;
  }

}
