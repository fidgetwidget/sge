package;


import haxe.Log;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.Lib;
import sge.Game;
import samples.TestScene;
import samples.basic.BasicScene;
import samples.brickBreaker.BrickBreaker;
import samples.blockDrop.BlockDrop;
import samples.snake.Snake;
import games.tileworld.BaseScene;
import games.tileworld.TileRenderTest;


class Main extends Sprite {


  var game  :sge.Game;

  var ready :Bool = false;


  public function new() 
  {
    super();  
    addEventListener(Event.ADDED_TO_STAGE, added);
  }

  
  function resize(e) 
  {
    if (!ready) init();
    // else (resize or orientation change)
  }
  
  function init() 
  {
    if (ready) return;
    
    game = new Game();
    game.init(Lib.current);

    ready = true;

    // 
    // Push your first scene (loading scene?)
    // 
    Game.sceneManager.pushScene( new BaseScene() );
  }

  
  function added(e) 
  {
    removeEventListener(Event.ADDED_TO_STAGE, added);

    // setup a resize handler in case we want/need it...
    stage.addEventListener(Event.RESIZE, resize);

    #if ios
    haxe.Timer.delay(init, 100); // iOS 6
    #else
    init();
    #end
  }
  


  public static function main() 
  {
    
    Lib.current.stage.align = openfl.display.StageAlign.TOP_LEFT;
    Lib.current.stage.scaleMode = openfl.display.StageScaleMode.NO_SCALE;
    Lib.current.addChild(new Main());
    
  }
  
  
}