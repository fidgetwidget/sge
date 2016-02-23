package samples.brickBreaker;

import openfl.display.Graphics;
import openfl.display.Shape;
import openfl.ui.Keyboard;
import sge.Lib;
import sge.Game;
import sge.scene.Scene;
import sge.geom.Motion;
import sge.geom.base.Circle;
import sge.geom.base.Rectangle;


class Playground extends Scene
{

  
  public function new() 
  { 

    super();

    entities = new EntityGrid();
    entities.scene = this;

  }

  override private function onReady() :Void
  {

    init();

    // 

    reset();

  }


  override public function update() :Void
  {

    handleInput();

    if (isPaused) return;

    // 

  }


  override public function render() :Void
  {

    var g = draw.graphics;

    g.clear();

    // 

  }


  private function init() :Void
  {

    // 

  }


  private function reset() :Void
  {

    // 

  }


  // 
  // Update Helpers
  // 

  override private function handleInput() :Void
  {

    var input = Game.inputManager;

    // 

  }


  // 
  // Collision Helpers
  // 
  
  private var collision :Collision;


  // 
  // Collision Handlers
  // 


  private function on__() :Void
  {

  }


}