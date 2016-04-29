package samples.basic;


import openfl.display.Graphics;
import openfl.display.Shape;
import sge.Game;
import sge.Lib;
import sge.entity.Entity;
import sge.collision.Collider;
import sge.collision.shapes.Circle;
import sge.collision.shapes.Polygon;


class Box extends Entity {

  
  var poly :Polygon;


  public function new() 
  {
    super();

    var w = Lib.random_int(10, 60);
    var h = Lib.random_int(10, 60);

    poly = Polygon.rectangle(0, 0, w, h, true);
    collider = new Collider(_transform, poly);
    linearDrag = 0.1;
    velocityLimit = 30 * 60 * 100;
  }

}
