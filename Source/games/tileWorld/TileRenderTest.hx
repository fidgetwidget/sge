package games.tileworld;

import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.display.PixelSnapping;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFieldAutoSize;
import openfl.ui.Keyboard;
import sge.Game;
import sge.Lib;
import sge.lib.MemUsage;
import sge.collision.Collision;
import sge.scene.Camera;
import sge.scene.Scene;
import sge.graphics.TileSetCollection;
import sge.graphics.TileSetImporter;
import sge.graphics.TileRenderer;
import sge.tiles.TILE_VALUES;
import sge.tiles.TILE_TYPES;
import sge.tiles.TILE_LAYERS;
import sge.tiles.NEIGHBORS;


class TileRenderTest extends Scene
{

  var image : Sprite;

  // movement input helpers
  var mouseDragStart :Point;
  var cameraDragStart :Point;
  var draggingRect :Rectangle;
  var displayScaleCounter :Int;
  // Flags
  var mouseDragging :Bool = false;
  var cameraDragging :Bool = false;
  // current mouse position in the world
  var currentWorldX(get, never) :Float;
  var currentWorldY(get, never) :Float;

  var collection :TileSetCollection;
  var renderer :TileRenderer;

  public function new() 
  { 
    super();

    renderer = new TileRenderer();
    renderer.importTilesSets('data/tilesets');

    // collection = new TileSetCollection();
    // TileSetImporter.importTileSets('data/import', collection);

    // TileHelper.init();
    camera = new Camera();
    mouseDragStart = new Point();
    cameraDragStart = new Point();
  }

  inline function init_camera() :Void
  {
    camera.bounds.width = Game.root.stage.stageWidth;
    camera.bounds.height = Game.root.stage.stageHeight;
    camera.MIN_SCALE = 0.5;
    camera.MAX_SCALE = 6;
  }


  override private function onReady() 
  {
    init_camera();
    image = new Sprite();
    _sprite.addChild(image);

    var x = 10;
    var y = 10;

    trace('start render');
    for( id in renderer.collection.tileSetIds )
    {
      
      trace('tileSetId: $id');

      if (id == TILE_TYPES.NONE) continue;

      for ( n in 0...NEIGHBORS.SIDES )
      {
        var data = renderer.getBitmapData(id, n);
        if (data == null) continue;
        var bitmap = new Bitmap(data, PixelSnapping.ALWAYS, false);

        bitmap.x = x;
        bitmap.y = y;
        image.addChild(bitmap);

        x += TILE_VALUES.TILE_WIDTH + 10; 
      }

      x += TILE_VALUES.TILE_WIDTH;

      for ( n in 0...NEIGHBORS.SIDES )
      {
        var data = renderer.getBitmapData(id, n, TILE_LAYERS.BACKGROUND);
        if (data == null) continue;
        var bitmap = new Bitmap(data, PixelSnapping.ALWAYS, false);

        bitmap.x = x;
        bitmap.y = y;
        image.addChild(bitmap);

        x += TILE_VALUES.TILE_WIDTH + 10; 
      }

      x = 10;
      y += TILE_VALUES.TILE_HEIGHT + 10;

    }
    trace('render complete');

    reset_camera();
  }

  override public function update()
  {
    Game.ruler.startMarker('update', 0xff0000);

    handleInput();
    
    Game.ruler.endMarker('update');
  }


  override public function render()
  {
    Game.ruler.startMarker('render', 0x00ff00);

    image.x = -(camera.x * 2);
    image.y = -(camera.y * 2);

    Game.ruler.endMarker('render');
  }
  

  override function handleInput() :Void
  {
    input_dragMove();

    input_cameraReset();  

    input_zoom();  
  }



  inline function reset_camera() :Void
  {
    setScale(2);
    camera.x = 0;
    camera.y = 0;
  }

  inline function setScale( value :Float ) :Void
  {
    camera.scale = value;
    image.scaleX = camera.scaleX;
    image.scaleY = camera.scaleY;
  }

  // 
  // Input
  // 

  inline function input_dragMove() :Void
  {
    var input = Game.inputManager;

    // Test if we are starting a drag action
    if (input.keyboard.isDown( Keyboard.SPACE ) && input.mouse.isDown() &&
      ( input.keyboard.isPressed( Keyboard.SPACE ) || input.mouse.isPressed() ))
    {
      mouseDragStart.x = input.mouse.mouseX;
      mouseDragStart.y = input.mouse.mouseY;
      cameraDragStart.x = camera.x;
      cameraDragStart.y = camera.y;
      mouseDragging = true;
      cameraDragging = true;
    }

    if ( cameraDragging && (input.keyboard.isReleased( Keyboard.SPACE ) || input.mouse.isReleased() ) )
    {
      mouseDragging = false;
      cameraDragging = false;
    }

    // if we are dragging
    if ( cameraDragging )
    {
      var dx = (mouseDragStart.x - input.mouse.mouseX) / camera.scaleX;
      var dy = (mouseDragStart.y - input.mouse.mouseY) / camera.scaleY;

      camera.x = Math.floor(cameraDragStart.x + dx);
      camera.y = Math.floor(cameraDragStart.y + dy);
    }

  }


  inline function input_cameraReset() :Void
  {
    var input = Game.inputManager;

    if (input.keyboard.isPressed( Keyboard.R )) reset_camera();
  }


  // zoom
  inline function input_zoom() :Void
  {
    var input = Game.inputManager;
    var mouseDelta = input.mouse.mouseWheel.last;

    if (mouseDelta != 0)
    {
      var targetScale = camera.scaleX;
      mouseDelta = (mouseDelta > 0 ? 1 : -1);
      if (input.keyboard.isDown( Keyboard.SHIFT ))
        targetScale += mouseDelta * 0.1;
      else
        targetScale += mouseDelta * 0.2;
      targetScale = Math.round(targetScale * 100) * 0.01;
      
      setScale(targetScale);
    }
  }


  inline function get_currentWorldX() :Float return (Game.inputManager.mouse.mouseX / camera.scaleX) + camera.x;
  inline function get_currentWorldY() :Float return (Game.inputManager.mouse.mouseY / camera.scaleY) + camera.y;

}
