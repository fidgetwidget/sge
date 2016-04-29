package samples.basic;


import openfl.display.Shape;
import sge.Game;
import sge.Lib;
import sge.input.InputManager;
import sge.scene.Scene;
import sge.entity.Entity;
import sge.entity.EntityGrid;
import sge.geom.Motion;
import sge.collision.SAT2D;


class BasicScene extends Scene
{

  var player :Player;
  var sceneWidth :Int;
  var sceneHeight :Int;
  var input :InputManager;

  var _shapes :Array<Entity>;
  var _near   :Array<Entity>;
  var _entitiesToRemove :Array<Entity>;
  var _ent :Entity;
  
  
  public function new() 
  { 
    super();

    entities = new EntityGrid();
    player = new Player();

    _shapes = [];
    _near = [];
    _entitiesToRemove = [];

  }


  override private function onReady() 
  {
    trace( 'BasicScene onReady' );

    input = Game.inputManager;

    sceneWidth  = Game.root.stage.stageWidth;
    sceneHeight = Game.root.stage.stageHeight;

    for (i in 0...10)
    {
      addShape( Lib.random_int(0, sceneWidth), Lib.random_int(0, sceneHeight) );
    }

    player.x = 50;
    player.y = 50;
    addEntity(player);

    trace('entity count: ${entities.count}');

  }


  override public function update() :Void
  {

    removeEntities();
    
    player.handleInput();

    if ( input.mouse.isDown() )
    {
      addShape(input.mouse.mouseX, input.mouse.mouseY);
    }

    if (player.motion.inMotion)
      entities.touch(player);

    entities.update( true, function (e :Entity) {

      var dx :Float;
      var dy :Float;

      Lib.emptyArray(_near);
      _near = entities.near( e, _near );

      // trace('entity update callback');

      for (ent in _near)
      {
        // trace('near loop');

        if (ent == e || ent == player || e == player)
        {
          continue;
        }

        // trace('collision test');
        if (ent.hasCollider && e.hasCollider && ent.collider.test(e.collider))
        {
          dx = ent.collider.collision.separation.x;
          dy = ent.collider.collision.separation.y;

          ent.x -= dx * 0.5;
          ent.y -= dy * 0.5;
          ent.motion.velocityX = dx * -0.1;
          ent.motion.velocityY = dy * -0.1;

          e.x += dx * 0.5;
          e.y += dy * 0.5; 
          e.motion.velocityX = dx * 0.1;
          e.motion.velocityY = dy * 0.1;
        }

      }

      if (e.collider.left < 0 || e.collider.right > sceneWidth ||
          e.collider.top < 0  || e.collider.bottom > sceneHeight)
      {
        _entitiesToRemove.push(e);
      }

    });

    // test for and resolve player and other collisions
    Lib.emptyArray(_near);
    _near = entities.near( player, _near );

    for (e in _near)
    {
      if ( e.hasCollider && player.collider.test(e.collider) )
      {
        
        vx = player.collider.collision.separation.x;
        vy = player.collider.collision.separation.y;
        vl = SAT2D.vec_length(vx, vy);
        e.x += vx;
        e.y += vy;
        e.motion.velocityX += SAT2D.vec_normalize(vl, vx) * Math.abs(player.velocityX * 0.25);
        e.motion.velocityY += SAT2D.vec_normalize(vl, vy) * Math.abs(player.velocityY * 0.25);

        // entities.touch(e);
      }
    }

    // Player collide with the edge of the world
    if (player.collider.left < 0 || player.collider.right > sceneWidth)
    {
      if (player.collider.left < 0) player.x += 0 - player.collider.left;
      if (player.collider.right > sceneWidth) player.x += sceneWidth - player.collider.right;

      player.velocityX *= -1;
    }

    if (player.collider.top < 0 || player.collider.bottom > sceneHeight)
    {
      if (player.collider.top < 0) player.y += 0 - player.collider.top;
      if (player.collider.bottom > sceneHeight) player.y += sceneHeight - player.collider.bottom;

      player.velocityY *= -1;
    }

  }
  var vl :Float;
  var vx :Float; 
  var vy :Float;


  override public function render() :Void
  {

    _sprite.graphics.clear();
    _sprite.graphics.lineStyle( 1, 0x0000ff );

    entities.debug_render( _sprite.graphics );

    // _near should still be populated from the update()
    _sprite.graphics.beginFill( 0x33ff0000 );
    for (e in _near)
    {
      e.debug_render(_sprite.graphics);
    }
    _sprite.graphics.endFill();
    
  }


  inline function removeEntities()
  {
    while (_entitiesToRemove.length > 0)
    {
      _ent = _entitiesToRemove.pop();
      if (_ent == player) continue;
      entities.remove(_ent);
    }
  }

  inline function addShape( x :Float, y :Float )
  {
    var shape :Entity;
    shapeType = Lib.random_fromArray(shapeTypes);

    switch (shapeType)
    {
      case 'box': 
        shape = new Box();
      default:
        shape = new Ball();
    }
    

    shape.x = x;
    shape.y = y;

    _shapes.push(shape);
    addEntity(shape);
    entities.touch(shape);
  }

  var shapeTypes = [ 'box', 'ball' ];
  var shapeType :String;

}