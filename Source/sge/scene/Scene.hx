package sge.scene;

import openfl.display.DisplayObject;
import openfl.display.Sprite;
import sge.entity.EntityManager;
import sge.entity.Entity;


class Scene
{

  // 
  // Static Unique Id
  // 
  private static var uid :Int = 0;
  private static function getNextId() :Int 
  {
    return Scene.uid++;
  }


  // 
  // Properties
  // 
  
  public var id : Int;

  public var name : String;

  public var entities : EntityManager;

  public var camera : Camera;

  public var manager : SceneManager;

  public var x (get, set) : Float;

  public var y (get, set) : Float;

  // does this scene pause any scene below it
  public var isOpaque : Bool = true;

  public var isPaused : Bool = false;

  public var isVisible (get, never) : Bool;


  // 
  // Constructor
  // 
  public function new () 
  { 
    // super();
    id = Scene.getNextId();
    name = Type.getClassName(Type.getClass(this));

    _sprite = new Sprite();
  }


  // 
  // Methods
  // 

  public function ready () : Void 
  {
    if (Game.debugMode) trace('Scene[$name]:ready');

    Game.addChild_scene(_sprite);

    onReady();
  }

  private function onReady () : Void {}

  public function unload () : Void 
  {
    if (Game.debugMode) trace('Scene[$name]:unload');

    Game.removeChild_scene(_sprite);
  }

  // Update

  public function update() : Void 
  {
    handleInput();

    if (isPaused) return;

    if (entities != null)  
      entities.update();
  }

  private function handleInput() : Void {}


  public function render() : Void 
  {
    if (entities != null)  
      entities.debug_render( _sprite.graphics );
  }


  // Entity Manager
  
  public function addEntity ( entity :Entity ) : Void 
  {
    if (entities == null) 
    { 
      trace('Scene[$name]:addEntity > Scene.entities is null'); 
      return;
    }

    entities.add( entity );
    entity.manager = entities;
    addSprite( entity.sprite );
  }

  public function removeEntity ( entity :Entity ) : Void 
  {
    if (entities == null) 
    {
      trace('Scene[$name]:addEntity > Scene.entities is null'); 
      return;
    }

    entities.remove( entity );
    entity.manager = null;
    removeSprite( entity.sprite );
  }

  
  // Sprite Managment
  
  public function addSprite ( sprite :DisplayObject ) :Void 
  {
    _sprite.addChild(sprite);
  }

  public function removeSprite ( sprite :DisplayObject ) :Void
  {
    _sprite.removeChild(sprite);
  }

  // 
  // Property Getters & Setters
  // 

  private function get_isVisible () : Bool 
  { 
    if ( manager.activeScene == this ) return true;
    return manager.occludedScenes.indexOf(this) != -1;
  }


  inline private function get_x() : Float return _sprite.x;
  inline private function set_x( x :Float ) : Float return _sprite.x = x;

  inline private function get_y() : Float return _sprite.y;
  inline private function set_y( y :Float ) : Float return _sprite.y = y;

  private var _sprite : Sprite;

}
