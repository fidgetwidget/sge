package samples;

import openfl.display.Shape;
import sge.Game;
import sge.scene.Scene;


class TestScene extends Scene
{

  private var shape :Shape;
  private var sx :Int;
  private var sy :Int;
  private var sradius :Int;
  
  public function new() 
  { 
    super();

  }

  override private function onReady() 
  {

    shape = new Shape();
    sx = 100;
    sy = 150;
    sradius = 20;
    _sprite.addChild(shape);

  }

  override public function update()
  {

    var input = Game.inputManager;

    if ( input.mouse.isDown() )
    {
      sx = Math.floor( input.mouse.mouseX );
      sy = Math.floor( input.mouse.mouseY );
    }

  }


  override public function render()
  {

    shape.graphics.clear();
    shape.graphics.beginFill(0x0088DD, 1);
    shape.graphics.drawCircle(sx, sy, sradius);

  }


}