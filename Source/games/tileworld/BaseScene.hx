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

  var MAX_DRAW_SIZE :Int = 3;
  var MIN_DRAW_SIZE :Int = 1;
  var MAX_COLLISIONS :Int = 32;

  var tries :Int = 0;
  var placeableTileTypes :Array<Int>;

  var tileData : BitmapData;
  var world : World;
  var player :Player;
  var currentTile :Bitmap;
  var outline :Shape;

  // movement input helpers
  var mouseDragStart :Point;
  var cameraDragStart :Point;
  var draggingRect :Rectangle;
  var displayScaleCounter :Int;
  // Flags
  var mouseDragging :Bool = false;
  var cameraDragging :Bool = false;
  var rectDragging :Bool = false;
  var renderBounds :Bool = false;
  var renderCollisions :Bool = false;
  var resolveCollisions (get, never) :Bool;
  // current mouse position in the world
  var currentWorldX(get, never) :Float;
  var currentWorldY(get, never) :Float;
  // tile placement
  var currentTileType(get, set) :Int;
  var currentTileTypeIndex(get, set) :Int;
  var drawSize (get, set) :Int;


  public function new() 
  { 
    super();

    tileData = Assets.getBitmapData("images/tiles.png");
    TYPES.init();

    camera = new Camera();
    placeableTileTypes = [TYPES.NONE, TYPES.DIRT, TYPES.STONE, TYPES.CLAY, TYPES.PUTTY];
    mouseDragStart = new Point();
    cameraDragStart = new Point();
    draggingRect = new Rectangle();
    _drawRect = new Rectangle();
    drawSize = 1;
  }


  override private function onReady() 
  {
    init_camera();

    world = new World(this);
    player = new Player(this);
    init_currentTile();

    _sprite.addChild(world.image);
    _sprite.addChild(player.image);
    _sprite.addChild(currentTile);
    _sprite.addChild(outline);

    reset_camera();
  }


  override public function update()
  {
    Game.ruler.startMarker('update', 0xff0000);

    handleInput();

    world.update();
    player.update();

    if (resolveCollisions)
      update_collisions();
    
    Game.ruler.endMarker('update');
  }


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

    input_adjustDrawSize();

    input_player();      
  }


  // +----------------------------------------+
  // |                                        |
  // |                HELPERS                 |
  // |                                        |
  // +----------------------------------------+

  // 
  // Camera
  // 

  inline function reset_camera() :Void
  {
    setScale(2);
    camera.centerX = CONST.REGION_WIDTH * 0.5;
    camera.centerY = CONST.REGION_HEIGHT * 0.5;
    player.setPosition(CONST.REGION_WIDTH * 0.5, CONST.REGION_HEIGHT * 0.5);

    draggingRect.x = player.x - 120;
    draggingRect.y = player.y + 120;
    draggingRect.width = 240;
    draggingRect.height = 20;
    placeTile_rect(draggingRect, TYPES.DIRT);

    draggingRect.x = player.x - 120;
    draggingRect.y = player.y - 120;
    draggingRect.width = 240;
    draggingRect.height = 120;
    placeTile_rect(draggingRect, TYPES.NONE);
  }

  inline function setScale( value :Float ) :Void
  {
    camera.scale = value;
    world.image.scaleX = player.image.scaleX = currentTile.scaleX = camera.scaleX;
    world.image.scaleY = player.image.scaleY = currentTile.scaleY = camera.scaleY;
  }

  // 
  // Player Actions
  // 
  inline function placeTile( x:Float, y:Float, type :Int, layer :UInt = LAYERS.BASE )
  {
    world.setTileType(x, y, type, layer);
  }

  inline function placeTile_rect( rect :Rectangle, type :Int, layer :UInt = LAYERS.BASE )
  {
    var l = rect.left;
    var t = rect.top;
    while( l <= rect.right )
    {
      while ( t <= rect.bottom )
      {
        placeTile( l, t, type, layer );
        t += CONST.TILE_HEIGHT;
      }
      t = rect.top;
      l += CONST.TILE_WIDTH;
    }
  }

  // This only works on native platforms right now
  inline function saveRegionToImage( region :Region ) :Void
  {
#if (sys)
    var rx = Math.floor(region.x / CONST.REGION_WIDTH);
    var ry = Math.floor(region.y / CONST.REGION_HEIGHT);
    var imageData = region.cache;
    var fileName = 'region_x${rx}_y${ry}.png';
    var path = '/${fileName}';

    Lib.saveImage( imageData, path, sge.lib.SystemDirectory.DESKTOP );
#end
  }

  // 
  // Init Heleprs
  // 

  inline function init_camera() :Void
  {
    camera.bounds.width = Game.root.stage.stageWidth;
    camera.bounds.height = Game.root.stage.stageHeight;
    camera.MIN_SCALE = 0.2;
    camera.MAX_SCALE = 6;
  }


  inline function init_currentTile() :Void
  {
    var bitmapData = new BitmapData(CONST.TILE_WIDTH, CONST.TILE_HEIGHT, true, 0xffffff);
    currentTile = new Bitmap(bitmapData, PixelSnapping.ALWAYS, false);
    outline = new Shape();
    currentTileType = TYPES.DIRT;
  }

  // 
  // Update Heleprs
  // 

  inline function update_collisions() :Void
  {
    tries = 0;
    collisions = world.collisionCheck(player.bounds, collisions);
    while (collisions.length > 0 && tries < MAX_COLLISIONS)
    {
      smallest = Collision.getSmallest(collisions).smallest();
      player.resolveCollision(smallest.px, smallest.py);
      collisions = world.collisionCheck(player.bounds, collisions);
      tries++;
    }
    if (tries == MAX_COLLISIONS) throw new openfl.errors.Error('Can\'t resolve the player collisions');

    if (player.velocityY == 0) player.canJump = true;
  }

  // 
  // Render Helpers
  // 

  inline function render_currentTile() :Void
  {
    var g = outline.graphics;

    g.clear();
    g.lineStyle(3, 0xff69b4);


    if (rectDragging)
    {
      var tlTile :Tile;
      var brTile :Tile;
      var left :Float;
      var top :Float;
      var right :Float;
      var bottom :Float;

      tlTile = world.getTile(draggingRect.x, draggingRect.y);
      brTile = world.getTile(draggingRect.x + draggingRect.width, draggingRect.y + draggingRect.height);

      top = (tlTile.worldY - camera.y) * camera.scaleY;
      left = (tlTile.worldX - camera.x) * camera.scaleX;
      bottom = (brTile.worldY + CONST.TILE_HEIGHT - camera.y) * camera.scaleY;
      right = (brTile.worldX + CONST.TILE_WIDTH - camera.x) * camera.scaleX;

      g.drawRect(Math.min(left, right), Math.min(top, bottom), Math.abs(right - left), Math.abs(bottom - top));
    }
    else
    {
      var xx :Float;
      var yy :Float;
      _drawRect.x = currentWorldX + (_drawRect.width * -0.5);
      _drawRect.y = currentWorldY + (_drawRect.height * -0.5);

      _drawRectTiles = world.getTiles_rect(_drawRect.x, _drawRect.y, _drawRect.width, _drawRect.height, _drawRectTiles);
      while( _drawRectTiles.length > 0 )
      {
        var tile = _drawRectTiles.pop();
        xx = (tile.worldX - camera.x) * camera.scaleX;
        yy = (tile.worldY - camera.y) * camera.scaleY;
        g.drawRect(xx, yy, CONST.TILE_WIDTH * camera.scaleX, CONST.TILE_HEIGHT * camera.scaleY);
      }
    }
  }
  var _drawRectTiles :Array<Tile>;


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
      var col = world.getTileCollisionValue(tx, ty);

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
      smallest = Collision.getSmallest(collisions).smallest();
      if (smallest.px != 0 || smallest.py != 0)
      {
        xx = xx - (smallest.px * camera.scaleX);
        yy = yy - (smallest.py * camera.scaleY);
        g.lineTo(xx, yy);  
      }
      Game.debug.setLabel('c', '${smallest.px}|${smallest.py}');
    }
    
  }

  // 
  // Input Helpers
  // 


  inline function input_showDebugText() :Void
  {
    if (Game.debug.visible)
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

      Game.debug.setLabel('o', text);
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
      // debugText.text = 'scale: ${camera.scaleX}';
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
    var layer = 0;

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
      if (input.keyboard.isDown(Keyboard.ALTERNATE)) layer = LAYERS.BACKGROUND;

      placeTile_rect(draggingRect, currentTileType, layer);
      mouseDragging = false;
      rectDragging = false;
    }
  }


  inline function input_placeTile() :Void
  {
    var input = Game.inputManager;
    var layer = 0;

    if (input.mouse.isDown() && !mouseDragging)
    {
      if (input.keyboard.isDown(Keyboard.ALTERNATE)) layer = LAYERS.BACKGROUND;

      _drawRect.x = currentWorldX + (_drawRect.width * -0.5);
      _drawRect.y = currentWorldY + (_drawRect.height * -0.5);

      placeTile_rect(_drawRect, currentTileType, layer);
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

    if (input.keyboard.isPressed( Keyboard.P )) 
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

  inline function input_adjustDrawSize() :Void
  {
    var input = Game.inputManager;

    if (input.keyboard.isPressed(Keyboard.LEFTBRACKET))
    {
      drawSize--;
    }
    if (input.keyboard.isPressed(Keyboard.RIGHTBRACKET))
    {
      drawSize++;
    }
  }

  inline function input_player() :Void
  {

    var input = Game.inputManager;

    if (input.keyboard.isDown(Keyboard.LEFT) || input.keyboard.isDown(Keyboard.A) ||
       input.keyboard.isDown(Keyboard.RIGHT) || input.keyboard.isDown(Keyboard.D))
    {
      if (input.keyboard.isDown(Keyboard.LEFT) || input.keyboard.isDown(Keyboard.A))
      {
        player.velocityX = -4;
      } 
      if (input.keyboard.isDown(Keyboard.RIGHT) || input.keyboard.isDown(Keyboard.D))
      {
        player.velocityX = 4;
      } 
    }
    else
    {
      player.velocityX = 0;
    }

    if (!renderCollisions)
    {
      if (input.keyboard.isPressed(Keyboard.Z) ||
          input.keyboard.isPressed(Keyboard.UP) ||
          input.keyboard.isPressed(Keyboard.W))
      {
        if (player.canJump) player.velocityY -= CONST.JUMP_POWER; player.canJump = false;
      }
      // gravity
      player.velocityY += CONST.GRAVITY_ACCELERATION;
    }
    else
    {
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
  }

  // 
  // Properties
  // 
  
  var _currentTileTypeIndex :Int;
  var _currentTileType :Int;
  var _tiles :Array<Tile>;
  var _drawSize :Int;
  var _drawRect :Rectangle;
  var smallest :Collision;
  var collisions :Array<Collision>;

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

  inline function get_drawSize() :Int return _drawSize;
  inline function set_drawSize( value :Int ) :Int
  {
    if (value > MAX_DRAW_SIZE) value = MIN_DRAW_SIZE;
    if (value < MIN_DRAW_SIZE) value = MAX_DRAW_SIZE;
    _drawSize = value;
    _drawRect.width = CONST.TILE_WIDTH * (value - 1) + 1;
    _drawRect.height = CONST.TILE_HEIGHT * (value - 1) + 1;
    return _drawSize;
  }

  inline function get_currentWorldX() :Float return (Game.inputManager.mouse.mouseX / camera.scaleX) + camera.x;
  inline function get_currentWorldY() :Float return (Game.inputManager.mouse.mouseY / camera.scaleY) + camera.y;

  inline function get_resolveCollisions() :Bool return !renderCollisions;

}