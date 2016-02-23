package games.tileworld;

import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.FPS;
import openfl.display.Shape;
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


class BaseScene extends Scene
{
  
  var tileData : BitmapData;
  var world : World;
  var player :Player;
  var fps : FPS;
  var mem : MemUsage;
  var debugText :TextField;
  var collisionText :TextField;
  var currentWorldX(get, never) :Float;
  var currentWorldY(get, never) :Float;
  var currentTile :Bitmap;
  var outline :Shape;

  // 
  // Input Flags & States
  // 
  var mouseDragStart :Point;
  var cameraDragStart :Point;
  var mouseDragging :Bool = false;
  var cameraDragging :Bool = false;
  var rectDragging :Bool = false;
  var draggingRect :Rectangle;
  var displayScaleCounter :Int;
  var placeableTileTypes :Array<Int>;
  var currentTileType(get, set) :Int;
  var currentTileTypeIndex(get, set) :Int;

  var renderBounds :Bool = false;
  var renderCollisions :Bool = false;
  var resolveCollisions (get, never) :Bool;
  



  public function new() 
  { 
    super();

    tileData = Assets.getBitmapData("images/tiles.png");
    TYPES.init();

    mouseDragStart = new Point();
    cameraDragStart = new Point();
    camera = new Camera();
    draggingRect = new Rectangle();

    placeableTileTypes = [TYPES.NONE, TYPES.DIRT, TYPES.STONE, TYPES.CLAY];
  }


  override private function onReady() 
  {
    camera.bounds.width = Game.root.stage.stageWidth;
    camera.bounds.height = Game.root.stage.stageHeight;

    camera.MIN_SCALE = 0.2;
    camera.MAX_SCALE = 6;

    world = new World(this);
    player = new Player(this);
    _sprite.addChild(world.image);
    _sprite.addChild(player.image);
    
    init_textFields();
    init_currentTile();

    reset_camera();
  }


  inline function init_textFields() :Void
  {
    fps = new FPS( Game.root.stage.stageWidth - 150, 0, 0x333333 );
    fps.autoSize = TextFieldAutoSize.RIGHT;
    fps.defaultTextFormat = new TextFormat('Arial', 32);
    _sprite.addChild(fps);

    mem = new MemUsage( Game.root.stage.stageWidth - 300, 0, 0x333333 );
    mem.autoSize = TextFieldAutoSize.RIGHT;
    mem.defaultTextFormat = new TextFormat('Arial', 32);
    _sprite.addChild(mem);

    debugText = new TextField();    
    debugText.autoSize = TextFieldAutoSize.LEFT;
    debugText.selectable = false;
    debugText.defaultTextFormat = new TextFormat('Arial', 32);
    _sprite.addChild(debugText);

    collisionText = new TextField();
    collisionText.y = Game.root.stage.stageHeight - 160;
    collisionText.autoSize = TextFieldAutoSize.LEFT;
    collisionText.selectable = false;
    collisionText.defaultTextFormat = new TextFormat('Arial', 32);
    _sprite.addChild(collisionText);
  }


  inline function init_currentTile() :Void
  {
    var bitmapData = new BitmapData(CONST.TILE_WIDTH, CONST.TILE_HEIGHT, true, 0xffffff);
    
    currentTile = new Bitmap(bitmapData);
    outline = new Shape();

    currentTileType = TYPES.DIRT;

    _sprite.addChild(currentTile);
    _sprite.addChild(outline);
  }


  override public function update()
  {
    Game.ruler.startMarker('update', 0xff0000);

    debugText.text = '';
    collisionText.text = '';

    handleInput();
    world.update();

    player.update();
    if (resolveCollisions)
    {
      collisions = world.collisionCheck(player.bounds, collisions);
      while (collisions.length > 0)
      {
        smallest = Collision.getSmallest(collisions).smallest();
        player.resolveCollision(smallest.px, smallest.py);
        collisions = world.collisionCheck(player.bounds, collisions);
      }
    }
    
    Game.ruler.endMarker('update');
  }
  var smallest :Collision;
  var collisions :Array<Collision>;


  override public function render()
  {
    Game.ruler.startMarker('render', 0x00ff00);
    world.render();

    render_currentTile();

    if (renderBounds)
    {
      render_bounds();
    }
    if (renderCollisions)
    {
      render_collision();
    }

    Game.ruler.endMarker('render');
  }


  inline function render_currentTile() :Void
  {
    var g = outline.graphics;

    g.clear();
    g.lineStyle(3, 0xff69b4);

    if (rectDragging)
    {
      var rx = (draggingRect.x - camera.x) * camera.scaleX;
      var ry = (draggingRect.y - camera.y) * camera.scaleY;

      g.drawRect(rx, ry, draggingRect.width * camera.scaleX, draggingRect.height * camera.scaleY);
    }
    else
      g.drawRect(currentTile.x, currentTile.y, currentTile.width, currentTile.height);
  }


  inline function render_bounds() :Void
  {
    var g = outline.graphics;

    var world_regions = world.getRegions();
    var xx :Float;
    var yy :Float;
    var ww :Float;
    var hh :Float;

    g.lineStyle(3, 0xff0000);
    for( region in world_regions )
    {
      xx = (region.x - camera.x) * camera.scaleX;
      yy = (region.y - camera.y) * camera.scaleY;
      ww = CONST.REGION_WIDTH * camera.scaleX;
      hh = CONST.REGION_HEIGHT * camera.scaleY;

      g.drawRect(xx, yy, ww, hh);

      if (camera.scaleX < 1) continue;
      var region_chunks = region.chunks;

      for ( chunk in region_chunks )
      {
        xx = (region.x + chunk.x - camera.x) * camera.scaleX;
        yy = (region.y + chunk.y - camera.y) * camera.scaleY;
        ww = CONST.CHUNK_WIDTH * camera.scaleX;
        hh = CONST.CHUNK_HEIGHT * camera.scaleY;

        if (camera.x > xx + ww ||
            camera.y > yy + hh ||
            xx > camera.x + camera.bounds.width ||
            yy > camera.y + camera.bounds.height )
        continue;

        g.drawRect(xx, yy, ww, hh);
      }
    }

    xx = (player.x - player.bounds.halfWidth - camera.x) * camera.scaleX;
    yy = (player.y - player.bounds.height - camera.y) * camera.scaleY;
    ww = player.bounds.width * camera.scaleX;
    hh = player.bounds.height * camera.scaleX;

    g.drawRect(xx, yy, ww, hh);

  }

  var _tiles :Array<Tile>;

  inline function render_collision() :Void
  {
    if (_tiles == null) _tiles = new Array();
    _tiles = world.getTiles_bounds(player.bounds, _tiles);

    var g = outline.graphics;
    var xx;
    var yy;
    var ww;
    var hh;

    xx = (player.x - player.bounds.halfWidth - camera.x) * camera.scaleX;
    yy = (player.y - player.bounds.height - camera.y) * camera.scaleY;
    ww = player.bounds.width * camera.scaleX;
    hh = player.bounds.height * camera.scaleX;

    g.drawRect(xx, yy, ww, hh);

    var tileWidth = CONST.TILE_WIDTH * camera.scaleX;
    var tileHeight = CONST.TILE_HEIGHT * camera.scaleY;
    var px = (player.x - camera.x) * camera.scaleX;
    var py = (player.y - camera.y) * camera.scaleY;

    while (_tiles.length > 0)
    {
      var tile = _tiles.pop();
      if (tile.type == TYPES.NONE) continue;
      var tx = tile.worldX;
      var ty = tile.worldY;

      xx = (tx - camera.x) * camera.scaleX;
      yy = (ty - camera.y) * camera.scaleY;

      g.drawRect(xx, yy, tileWidth, tileHeight);
    }

    g.lineStyle(3, 0x0000ff);
    var pw = player.width * camera.scaleX;
    var ph = player.height * camera.scaleY;

    g.drawRect(10, 10, pw, ph);

    xx = (pw * 0.5 + 10);
    yy = (ph * 0.5 + 10);
    g.moveTo(xx, yy);
    g.drawCircle(xx, yy, 2);


    collisions = world.collisionCheck(player.bounds, collisions);
    if (collisions.length > 0)
    {
      collisionText.text = '${collisions.length}';

      smallest = Collision.getSmallest(collisions).smallest();
      if (smallest.px != 0 || smallest.py != 0)
      {
        xx = xx - (smallest.px * camera.scaleX);
        yy = yy - (smallest.py * camera.scaleY);
        g.lineTo(xx, yy);  
      }

      collisionText.text += ' ${smallest.px}|${smallest.py}';
    }
    
  }

  // 
  // Camera
  // 

  inline function reset_camera() :Void
  {
    setScale(2);
    // camera.centerX = CONST.REGION_WIDTH * 0.5;
    // camera.centerY = CONST.REGION_HEIGHT * 0.5;
    // player.setPosition(CONST.REGION_WIDTH * 0.5, CONST.REGION_HEIGHT * 0.5);
  }

  inline function setScale( value :Float ) :Void
  {
    camera.scale = value;
    world.image.scaleX = player.image.scaleX = currentTile.scaleX = camera.scaleX;
    world.image.scaleY = player.image.scaleY = currentTile.scaleY = camera.scaleY;
  }


  // 
  // Input
  // 

  override function handleInput() :Void
  {
    input_dragMoveWithSpacebar();

    input_scrollWithMousewheel();

    input_changeCurrentTile();

    input_shiftDragFillRect();

    input_placeTile();

    input_resetCamera();

    input_toggleBoundsRender();

    input_toggleCollisionRender();

    input_saveRegionImage();

    input_showDebugText();

    input_adjustCursor();

    input_currentTile();

    input_player();      
  }


  inline function input_showDebugText() :Void
  {
    var input = Game.inputManager;

    if (input.keyboard.isDown(Keyboard.BACKQUOTE))
    {
      var xx = Math.floor(currentWorldX);
      var yy = Math.floor(currentWorldY);
      
      var regionKey = world.getRegionKey(xx, yy);
      var region = world.getRegion(xx, yy, false);

      var text = '$xx|$yy:region_$regionKey';
      if (region != null)
      {
        var chunkKey = region.getChunkKey(xx, yy);
        text += ':chunk_$chunkKey';
      }
      var tile = world.getTile(xx, yy);
      text += ':tile_${tile.type}_n${tile.neighbors}_c${tile.corners}_s${tile.sides}';

      var tileCollision = world.getTileCollisionValue(xx, yy);
      text += '_col$tileCollision';

      debugText.text = text;
    }
  }


  inline function input_dragMoveWithSpacebar() :Void
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

  inline function input_scrollWithMousewheel() :Void
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
      displayScaleCounter = 30;
    }

    if (displayScaleCounter > 0)
    {
      debugText.text = 'scale: ${camera.scaleX}';
      displayScaleCounter--;
    }
  }


  inline function input_changeCurrentTile() :Void
  {
    var input = Game.inputManager;

    if (input.keyboard.isPressed(Keyboard.SLASH))
    {
      currentTileTypeIndex++;
    }
  }

  inline function input_shiftDragFillRect() :Void
  {
    var input = Game.inputManager;
    var xx = currentWorldX;
    var yy = currentWorldY;

    // When one is down and the other is pressed
    if (input.keyboard.isDown( Keyboard.SHIFT ) && input.mouse.isDown() &&
      ( input.keyboard.isPressed( Keyboard.SHIFT ) || input.mouse.isPressed() ))
    {
      mouseDragStart.x = draggingRect.x = xx;
      mouseDragStart.y = draggingRect.y = yy;
      mouseDragging = true;
      rectDragging = true;
    }

    if ( rectDragging )
    {
      draggingRect.x = Math.min(xx, mouseDragStart.x);
      draggingRect.y = Math.min(yy, mouseDragStart.y);
      draggingRect.width = Math.abs(mouseDragStart.x - xx);
      draggingRect.height = Math.abs(mouseDragStart.y - yy);
    }

    if ( rectDragging && (input.keyboard.isReleased( Keyboard.SHIFT ) || input.mouse.isReleased() ) )
    {
      placeTile_rect(draggingRect, currentTileType);
      mouseDragging = false;
      rectDragging = false;
    }
  }


  inline function input_placeTile() :Void
  {
    var input = Game.inputManager;

    if (input.mouse.isDown() && !mouseDragging)
    {
      placeTile(currentWorldX, currentWorldY, currentTileType);
    }
  }

  inline function input_resetCamera() :Void
  {
    var input = Game.inputManager;

    if (input.keyboard.isPressed( Keyboard.R )) reset_camera();
  }

  inline function input_toggleBoundsRender() :Void
  {
    var input = Game.inputManager;

    if (input.keyboard.isPressed( Keyboard.B )) 
    {
      renderBounds = !renderBounds;
    }
  }

  inline function input_toggleCollisionRender() :Void
  {
    var input = Game.inputManager;

    if (input.keyboard.isPressed( Keyboard.C )) 
    {
      renderCollisions = !renderCollisions;
    }
  }

  inline function input_saveRegionImage() :Void
  {
    var input = Game.inputManager;

    if (input.keyboard.isPressed( Keyboard.S )) 
    {
      var region = world.getRegion(currentWorldX, currentWorldY, false);

      if (region != null) 
        saveRegionToImage(region);
    }
  }

  inline function input_adjustCursor() :Void
  {
    var input = Game.inputManager;

    if (input.keyboard.isDown(Keyboard.SPACE) || mouseDragging)
    {
      openfl.ui.Mouse.show();
      currentTile.visible = false;
    }
    else
    {
      openfl.ui.Mouse.hide();
      currentTile.visible = true;
    }
  }

  inline function input_currentTile() :Void
  {
    var coord = world.getTileCoord(currentWorldX, currentWorldY);

    currentTile.x = (coord.x - camera.x) * camera.scaleX;
    currentTile.y = (coord.y - camera.y) * camera.scaleY;
  }


  inline function input_player() :Void
  {

    var input = Game.inputManager;

    if (input.keyboard.isDown(Keyboard.LEFT) ||
      input.keyboard.isDown(Keyboard.RIGHT))
    {
      if (input.keyboard.isDown(Keyboard.LEFT))
      {
        player.velocityX = -4;
      } 
      if (input.keyboard.isDown(Keyboard.RIGHT))
      {
        player.velocityX = 4;
      } 
    }
    else
    {
      player.velocityX = 0;
    }

    if (input.keyboard.isDown(Keyboard.UP) ||
      input.keyboard.isDown(Keyboard.DOWN))
    {
      if (input.keyboard.isDown(Keyboard.UP))
      {
        player.velocityY = -4;
      } 
      if (input.keyboard.isDown(Keyboard.DOWN))
      {
        player.velocityY = 4;
      } 
    }
    else
    {
      player.velocityY = 0;
    }

  }

  // 
  // Helpers
  // 

  inline function placeTile( x:Float, y:Float, type :Int )
  {
    world.setTileType(x, y, type);
  }

  // TOOD: figure out some way to make this faster...
  inline function placeTile_rect( rect :Rectangle, type :Int )
  {
    var l = rect.left;
    var t = rect.top;
    while( l < rect.right )
    {
      while ( t < rect.bottom )
      {
        placeTile( l, t, currentTileType );
        t += CONST.TILE_HEIGHT;
      }
      t = rect.top;
      l += CONST.TILE_WIDTH;
    }
  }

  inline function saveRegionToImage( region :Region ) :Void
  {
    var rx = Math.floor(region.x / CONST.REGION_WIDTH);
    var ry = Math.floor(region.y / CONST.REGION_HEIGHT);
    var imageData = region.cache;
    var fileName = 'region_x${rx}_y${ry}.png';
    var path = '/${fileName}';
#if (sys)
    Lib.saveImage( imageData, path, sge.lib.SystemDirectory.DESKTOP );
#end
  }

  inline function get_currentWorldX() :Float return (Game.inputManager.mouse.mouseX / camera.scaleX) + camera.x;
  inline function get_currentWorldY() :Float return (Game.inputManager.mouse.mouseY / camera.scaleY) + camera.y;

  inline function get_resolveCollisions() :Bool return !renderCollisions;

  // 
  // Properties
  // 
  
  var _currentTileTypeIndex :Int;
  var _currentTileType :Int;

  inline function get_currentTileType() :Int return _currentTileType;
  inline function set_currentTileType( value :Int ) :Int 
  {
    _currentTileTypeIndex = placeableTileTypes.indexOf(value);
    _currentTileType = value;
    TYPES.setBitmapToTileType(currentTile.bitmapData, _currentTileType);
    return value;
  }

  inline function get_currentTileTypeIndex() :Int return _currentTileTypeIndex;
  inline function set_currentTileTypeIndex( value :Int ) :Int
  {
    if (value < 0) value = placeableTileTypes.length - 1;
    if (value > placeableTileTypes.length - 1) value = 0;
    _currentTileTypeIndex = value;
    _currentTileType = placeableTileTypes[_currentTileTypeIndex];
    TYPES.setBitmapToTileType(currentTile.bitmapData, _currentTileType);
    return _currentTileTypeIndex;
  }

}