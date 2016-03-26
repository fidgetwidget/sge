package sge.tiles;

import openfl.display.Bitmap;
import openfl.display.PixelSnapping;
import openfl.display.Sprite;
import sge.collision.TileCollisionHandler;
import sge.graphics.TileRenderer;
import sge.scene.Scene;
import sge.scene.Camera;
import sge.world.World;

// A Simple render object that is neighbor aware
class TileScene extends Scene {

  public var world :World;
  public var tileRenderer :TileRenderer;
  public var collisionHandler :TileCollisionHandler;


  public function new() 
  {
    super();

    world = new World();
    camera = new Camera();
    world.camera = camera;

    collisionHandler = new TileCollisionHandler(world);
    tileRenderer = new TileRenderer();
    Tile.renderer = tileRenderer;
  }


  override public function render() :Void
  {
    world.render();
  }  


  override public function ready() :Void 
  {
    if (Game.debugMode) trace('TileScene[$name]:ready');
    Game.addChild_scene(_sprite);
    addSprite(world.regionSprite);
    onReady();
  }


  override public function unload() :Void 
  {
    if (Game.debugMode) trace('TileScene[$name]:unload');
    removeSprite(world.regionSprite);
    Game.removeChild_scene(_sprite);
  }
  

}
