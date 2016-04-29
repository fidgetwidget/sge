package samples.animationTest;

import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Graphics;
import openfl.display.Shape;
import openfl.display.PixelSnapping;
import openfl.geom.Point;
import openfl.geom.Rectangle;

import sge.Game;
import sge.Lib;
import sge.graphics.AnimatedBitmapData;
import sge.scene.Camera;
import sge.scene.Scene;


class AnimationTest extends Scene
{

  var sprite :Bitmap;
  var spriteOrigin :Point;
  var abd :AnimatedBitmapData;

  public function new() 
  { 
    super();

    sprite = new Bitmap();
    spriteOrigin = new Point();

    abd = new AnimatedBitmapData();
    // abd.addAnimation();

  }

  override public function unload() :Void 
  {    
    removeSprite(sprite);
  }


  override private function onReady() 
  {
    addSprite(sprite);
    abd.setAnimation("base", 0);
  }


  override public function update()
  {
    handleInput();
  }


  override public function render()
  {

    abd.updateBitmap(sprite, spriteOrigin);

  }

  function handleInput()
  {

  }


}
