package games.tileworld;

import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.FPS;
import openfl.display.Graphics;
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
import sge.collision.Collision;
import sge.collision.TileCollisionHandler;
import sge.input.InputManager;
import sge.lib.MemUsage;
import sge.scene.Camera;
import sge.tiles.Tile;
import sge.tiles.TileScene;
import sge.world.Chunk;
import sge.world.Region;
import sge.world.World;
import sge.tiles.TILE_VALUES;
import sge.tiles.TILE_TYPES;
import sge.tiles.TILE_LAYERS;
import sge.world.WORLD_VALUES;
import sge.world.RegionPool;
import sge.world.ChunkPool;
import sge.tiles.TilePool;


class BaseScene extends TileScene
{

  var MAX_DRAW_SIZE :Int = 3;
  var MIN_DRAW_SIZE :Int = 1;
  var MAX_COLLISIONS :Int = 32;

  var STATE_CREATE :Int = 0;
  var STATE_PLAY :Int = 1;

  var currentState :Int;
  var attempts :Int = 0;
  var placeableTileTypes :Array<Int>;

  var background :Bitmap;
  
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

    placeableTileTypes = [0, 10, 16, 20];
    mouseDragStart = new Point();
    cameraDragStart = new Point();
    draggingRect = new Rectangle();
    _drawRect = new Rectangle();
    drawSize = 1;
    currentState = STATE_PLAY;

    tileRenderer.importTilesSets('data/tilesets');
  }


  override public function ready() :Void 
  {
    // trace('tileworld.BaseScene.ready');

    Game.addChild_scene(_sprite);

    var backgroundData = Assets.getBitmapData('images/tempBg.png');
    background = new Bitmap(backgroundData, PixelSnapping.ALWAYS, false);

    addSprite(background);
    addSprite(world.regionSprite);

    onReady();
  }


  override public function unload() :Void 
  {    
    removeSprite(background);
    removeSprite(world.regionSprite);

    Game.removeChild_scene(_sprite);
  }


  override private function onReady() 
  {
    // trace('tileworld.BaseScene.onReady');

    init_camera();
    // trace('init_camera done');

    init_worldBg();
    // trace('init_worldBg done');

    init_currentTile();
    // trace('init_currentTile done');

    player = new Player(this, collisionHandler);
    
    addSprite(player.image);
    addSprite(currentTile);
    addSprite(outline);

    reset_camera();
    trace('reset_camera done');
  }


  override public function update()
  {
    Game.ruler.startMarker('update', 0xff0000);

    handleInput();

    world.update();
    player.update();

    if (resolveCollisions || currentState == STATE_PLAY)
      update_collisions();

    if (currentState == STATE_PLAY)
      update_camera_follow_player();
    
    Game.ruler.endMarker('update');
  }


  override public function render()
  {
    Game.ruler.startMarker('render', 0x00ff00);
    
    world.render();
    player.render();

    render_currentTile();

    if (renderBounds)
      render_bounds();

    if (renderCollisions)
      render_collision();

    Game.ruler.endMarker('render');
  }
  

  override function handleInput() :Void
  {
    if (currentState == STATE_CREATE)
    {
      input_dragMoveWithSpacebar();
      
      input_shiftDragFillRect();
    }

    if (currentState == STATE_PLAY)
    {
      // play only input
    }

    input_changeCurrentTile();

    input_placeTile();

    input_currentTile();

    input_adjustCursor();

    input_adjustDrawSize();


    input_toggleState();

    input_scrollWithMousewheel();

    input_resetCamera();

    input_toggleBoundsRender();

    input_toggleCollisionRender();

    input_showDebugText();
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
    if (currentState == STATE_CREATE)
    {
      setScale(2);
      camera.centerX = WORLD_VALUES.REGION_WIDTH * 0.5;
      camera.centerY = WORLD_VALUES.REGION_HEIGHT * 0.5;
    }

    player.setPosition(WORLD_VALUES.REGION_WIDTH * 0.5, WORLD_VALUES.REGION_HEIGHT * 0.5);

    draggingRect.x = player.x - 120;
    draggingRect.y = player.y + 120;
    draggingRect.width = 240;
    draggingRect.height = 20;
    placeTile_rect(draggingRect, TILE_LAYERS.DEFAULT, TILE_TYPES.BASIC);

    draggingRect.x = player.x - 120;
    draggingRect.y = player.y - 120;
    draggingRect.width = 240;
    draggingRect.height = 120;
    placeTile_rect(draggingRect, TILE_LAYERS.DEFAULT, TILE_TYPES.NONE);
  }

  inline function setScale( value :Float ) :Void
  {
    camera.scale = value;
    world.regionSprite.scaleX = player.image.scaleX = currentTile.scaleX = camera.scaleX;
    world.regionSprite.scaleY = player.image.scaleY = currentTile.scaleY = camera.scaleY;
  }

  // 
  // Player Actions
  // 
  inline function placeTile( x:Float, y:Float, z :Int = TILE_LAYERS.DEFAULT, type :UInt = TILE_TYPES.NONE )
  {
    // trace('placeTile');

    world.setTile(x, y, z, type);
  }

  inline function placeTile_rect( rect :Rectangle, z :Int = TILE_LAYERS.DEFAULT, type :UInt = TILE_TYPES.NONE )
  {
    // trace('placeTile_rect');

    l = rect.left;
    t = rect.top;
    d = 0;
    while( l <= rect.right )
    {
      while ( t <= rect.bottom )
      {
        placeTile( l, t, z, type );
        d = Math.min( TILE_VALUES.TILE_HEIGHT, rect.bottom - t );
        t += d == 0 ? 1 : d;
      }
      t = rect.top;
      d = Math.min( TILE_VALUES.TILE_WIDTH, rect.right - l );
      l += d == 0 ? 1 : d;
    }
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
    bitmapData = new BitmapData(TILE_VALUES.TILE_WIDTH, TILE_VALUES.TILE_HEIGHT, true, 0xffffff);

    currentTile = new Bitmap(bitmapData, PixelSnapping.ALWAYS, false);
    outline = new Shape();
    currentTileType = TILE_TYPES.BASIC;
  }


  inline function init_worldBg() :Void
  {
    sw = Game.root.stage.stageWidth;
    sh = Game.root.stage.stageHeight;
    dx = sw - background.width;
    dy = sh - background.height;
    scale = 1;
    if (Math.abs(dx) > Math.abs(dy))
    {
      scale += dy / background.height;
    }
    else
    {
      scale += dx / background.width;
    }
    background.scaleX = scale;
    background.scaleY = scale;
  }

  // 
  // Update Heleprs
  // 

  inline function update_collisions() :Void
  {
    attempts = 0;
    collisions = collisionHandler.collide(player.bounds, collisions);
    while (collisions.length > 0 && attempts < MAX_COLLISIONS)
    {
      smallest = Collision.getSmallest(collisions);
      if (player.isJumping && smallest.py < 0) smallest.py = 0;
      smallest = smallest.smallest();

      player.resolveCollision(smallest.px, smallest.py);
      collisions = collisionHandler.collide(player.bounds, collisions);
      attempts++;
    }
    // if (attempts == MAX_COLLISIONS) throw new openfl.errors.Error('Can\'t resolve the player collisions');
  }

  inline function update_camera_follow_player() :Void
  {
    camera.centerX = player.x;
    camera.centerY = player.y;
  }

  // 
  // Render Helpers
  // 

  inline function render_currentTile() :Void
  {
    g = outline.graphics;

    g.clear();
    g.lineStyle(3, 0xff69b4);

    if (rectDragging)
    {
      tlTile = world.getTilePosition(draggingRect.x, draggingRect.y, tlTile);
      brTile = world.getTilePosition(draggingRect.x + draggingRect.width, draggingRect.y + draggingRect.height, brTile);

      top = (tlTile.y - camera.y) * camera.scaleY;
      left = (tlTile.x - camera.x) * camera.scaleX;
      bottom = (brTile.y + TILE_VALUES.TILE_HEIGHT - camera.y) * camera.scaleY;
      right = (brTile.x + TILE_VALUES.TILE_WIDTH - camera.x) * camera.scaleX;

      g.drawRect(Math.min(left, right), Math.min(top, bottom), Math.abs(right - left), Math.abs(bottom - top));
    }
    else
    {      
      _drawRect.x = currentWorldX + (_drawRect.width * -0.5);
      _drawRect.y = currentWorldY + (_drawRect.height * -0.5);

      drawRectTiles = world.getTilePositions(_drawRect.x, _drawRect.y, _drawRect.width, _drawRect.height, drawRectTiles);
      while( drawRectTiles.length > 0 )
      {
        p = drawRectTiles.pop();
        xx = (p.x - camera.x) * camera.scaleX;
        yy = (p.y - camera.y) * camera.scaleY;
        g.drawRect(xx, yy, TILE_VALUES.TILE_WIDTH * camera.scaleX, TILE_VALUES.TILE_HEIGHT * camera.scaleY);
      }
    }
  }
  


  inline function render_bounds() :Void
  {
    g = outline.graphics;

    if (!renderCollisions)
    {
      xx = (player.x - player.bounds.halfWidth - camera.x) * camera.scaleX;
      yy = (player.y - player.bounds.height - camera.y) * camera.scaleY;
      ww = player.bounds.width * camera.scaleX;
      hh = player.bounds.height * camera.scaleX;

      g.drawRect(xx, yy, ww, hh);  
    }

    for (r in world.regions)
    {
      xx = (r.x - camera.x) * camera.scaleX;
      yy = (r.y - camera.y) * camera.scaleY;
      ww = WORLD_VALUES.REGION_WIDTH * camera.scaleX;
      hh = WORLD_VALUES.REGION_HEIGHT * camera.scaleY;

      g.drawRect(xx, yy, ww, hh);
    }
  }
  

  inline function render_collision() :Void
  {
    g = outline.graphics;

    xx = (player.x - player.bounds.halfWidth - camera.x) * camera.scaleX;
    yy = (player.y - player.bounds.height - camera.y) * camera.scaleY;
    ww = player.bounds.width * camera.scaleX;
    hh = player.bounds.height * camera.scaleX;

    g.drawRect(xx, yy, ww, hh); 


    world.debug_render_tile_bounds(player.bounds.left, player.bounds.top, player.bounds.width, player.bounds.height, g);


    if (player.freeMove)
    {
      ww = player.bounds.width * camera.scaleX;
      hh = player.bounds.height * camera.scaleY;

      g.drawRect(10, 10, ww, hh);
      xx = (ww * 0.5) + 10;
      yy = (hh * 0.5) + 10;
      g.drawCircle(xx, yy, 3);

      g.lineStyle(1, 0x000099);
      g.moveTo(xx, yy);


      attempts = 0;
      collisions = collisionHandler.collide(player.bounds, collisions);
      while (collisions.length > 0 && attempts < MAX_COLLISIONS)
      {
        
        smallest = collisions.pop();
        xx = (ww * 0.5) + 10;
        yy = (hh * 0.5) + 10;
        xx = xx - (smallest.px * camera.scaleX);
        yy = yy - (smallest.py * camera.scaleY);
        g.lineTo(xx, yy);  

      }

    }
  }
  

  // 
  // Input Helpers
  // 

  inline function input_toggleState() :Void
  {
    input = Game.inputManager;

    if (input.keyboard.isPressed( Keyboard.O ))
    {
      currentState = currentState == STATE_CREATE ? STATE_PLAY : STATE_CREATE;

      if (currentState == STATE_CREATE)
      {
        
      }

      if (currentState == STATE_PLAY)
      {
        
      }
    }
  }
  


  inline function input_dragMoveWithSpacebar() :Void
  {
    input = Game.inputManager;

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
      dx = (mouseDragStart.x - input.mouse.mouseX) / camera.scaleX;
      dy = (mouseDragStart.y - input.mouse.mouseY) / camera.scaleY;

      camera.x = Math.floor(cameraDragStart.x + dx);
      camera.y = Math.floor(cameraDragStart.y + dy);
    }

  }


  inline function input_scrollWithMousewheel() :Void
  {
    input = Game.inputManager;
    mouseDelta = input.mouse.mouseWheel.last;

    if (mouseDelta != 0)
    {
      targetScale = camera.scaleX;
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
    input = Game.inputManager;

    if (input.keyboard.isPressed(Keyboard.SLASH))
    {
      currentTileTypeIndex++;
    }
  }

  inline function input_shiftDragFillRect() :Void
  {
    input = Game.inputManager;
    xx = currentWorldX;
    yy = currentWorldY;
    layer = 0;

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
      if (input.keyboard.isDown(Keyboard.ALTERNATE)) layer = TILE_LAYERS.BACKGROUND;

      placeTile_rect(draggingRect, layer, currentTileType);
      mouseDragging = false;
      rectDragging = false;
    }
  }
  


  inline function input_placeTile() :Void
  {
    input = Game.inputManager;
    layer = 0;

    if (input.mouse.isDown() && !mouseDragging)
    {
      if (input.keyboard.isDown(Keyboard.ALTERNATE)) layer = TILE_LAYERS.BACKGROUND;

      _drawRect.x = currentWorldX + (_drawRect.width * -0.5);
      _drawRect.y = currentWorldY + (_drawRect.height * -0.5);

      placeTile_rect(_drawRect, layer, currentTileType);
    }
  }

  inline function input_resetCamera() :Void
  {
    input = Game.inputManager;

    if (input.keyboard.isPressed( Keyboard.R )) reset_camera();
  }

  inline function input_toggleBoundsRender() :Void
  {
    input = Game.inputManager;

    if (input.keyboard.isPressed( Keyboard.B )) 
    {
      renderBounds = !renderBounds;
    }
  }

  inline function input_toggleCollisionRender() :Void
  {
    input = Game.inputManager;

    if (input.keyboard.isPressed( Keyboard.C )) 
    {
      renderCollisions = !renderCollisions;
      player.freeMove = renderCollisions;
    }
  }


  inline function input_adjustCursor() :Void
  {
    input = Game.inputManager;

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
    tilePosition = world.getTilePosition(currentWorldX, currentWorldY, tilePosition);
    currentTile.x = (tilePosition.x - camera.x) * camera.scaleX;
    currentTile.y = (tilePosition.y - camera.y) * camera.scaleY;
  }


  inline function input_adjustDrawSize() :Void
  {
    input = Game.inputManager;

    if (input.keyboard.isPressed(Keyboard.LEFTBRACKET))
    {
      drawSize--;
    }
    if (input.keyboard.isPressed(Keyboard.RIGHTBRACKET))
    {
      drawSize++;
    }
  }

  inline function input_showDebugText() :Void
  {
    if (Game.debug.visible)
    {
      xx = Math.floor(currentWorldX);
      yy = Math.floor(currentWorldY);
      
      region = world.getRegion(xx, yy, false);
      text = '$xx|$yy';

      if (region != null)
      {
        text += ':region_${region.x}_${region.y}';

        chunk = world.getChunk(xx, yy);
        text += ':chunk_${region.x + chunk.x}_${region.y + chunk.y}';
      
        tile = world.getTile(xx, yy, TILE_LAYERS.DEFAULT);
        text += ':tile_${region.x + chunk.x + tile.x}_${region.y + chunk.y + tile.y}_t${tile.type}_n${tile.neighbors}_c${tile.corners}_s${tile.neighborTypes}';

        tileCollision = world.getCollision(xx, yy);
        text += '_col$tileCollision';

      }
      else
      {
        text += ':region_NONE';
      }

      Game.debug.setLabel('o', text);

      text = '';

      count = RegionPool.instance.count;
      active = RegionPool.instance.activeCount;

      text += '(regions:$count|$active)';

      count = ChunkPool.instance.count;
      active = ChunkPool.instance.activeCount;

      text += '(chunks:$count|$active)';

      count = TilePool.instance.count;
      active = TilePool.instance.activeCount;

      text += '(tiles:$count|$active)';

      Game.debug.setLabel('pools', text);
    }
  }
  var region :Region;
  var chunk :Chunk;
  var tile :Tile;
  var p :Point;
  var text :String;
  var tileCollision :Int;
  var count :Int;
  var active :Int;

  var layer :Int;
  var input :InputManager;
  var mouseDelta :Float;
  var targetScale :Float;

  var g :Graphics;
  var left :Float;
  var right :Float;
  var top :Float;
  var bottom :Float;
  var xx :Float;
  var yy :Float;
  
  var l :Float;
  var t :Float;
  var d :Float;

  var sw :Float;
  var sh :Float;
  var dx :Float;
  var dy :Float;
  var ww :Float;
  var hh :Float;
  var scale :Float;

  var bitmapData :BitmapData;

  var drawRectTiles :Array<Point>;
  var smallest :Collision;
  var collisions :Array<Collision>;
  var tilePosition :Point;
  var tlTile :Point;
  var brTile :Point;
  var _tiles :Array<Point>;

  // 
  // Properties
  // 
  
  var _currentTileTypeIndex :Int;
  var _currentTileType :Int;
  var _drawSize :Int;
  var _drawRect :Rectangle;


  inline function get_currentTileType() :Int return _currentTileType;
  inline function set_currentTileType( value :Int ) :Int 
  {
    _currentTileTypeIndex = placeableTileTypes.indexOf(value);
    _currentTileType = value;

    tileRenderer.copyBitmapData(currentTile.bitmapData, _currentTileType);

    return value;
  }

  inline function get_currentTileTypeIndex() :Int return _currentTileTypeIndex;
  inline function set_currentTileTypeIndex( value :Int ) :Int
  {
    if (value < 0) value = placeableTileTypes.length - 1;
    if (value > placeableTileTypes.length - 1) value = 0;
    _currentTileTypeIndex = value;
    _currentTileType = placeableTileTypes[_currentTileTypeIndex];

    if (_currentTileType == TILE_TYPES.NONE)
      tileRenderer.clearBitmapData(currentTile.bitmapData);
    else
      tileRenderer.copyBitmapData(currentTile.bitmapData, _currentTileType);

    return _currentTileTypeIndex;
  }

  inline function get_drawSize() :Int return _drawSize;
  inline function set_drawSize( value :Int ) :Int
  {
    if (value > MAX_DRAW_SIZE) value = MIN_DRAW_SIZE;
    if (value < MIN_DRAW_SIZE) value = MAX_DRAW_SIZE;
    _drawSize = value;
    _drawRect.width = TILE_VALUES.TILE_WIDTH * (value - 1) + 1;
    _drawRect.height = TILE_VALUES.TILE_HEIGHT * (value - 1) + 1;
    return _drawSize;
  }

  inline function get_currentWorldX() :Float return (Game.inputManager.mouse.mouseX / camera.scaleX) + camera.x;
  inline function get_currentWorldY() :Float return (Game.inputManager.mouse.mouseY / camera.scaleY) + camera.y;

  inline function get_resolveCollisions() :Bool return !player.freeMove;


}