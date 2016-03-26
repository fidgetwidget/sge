package sge;

import haxe.Timer;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.display.Stage;
import openfl.events.Event;
import sge.lib.Debug;
import sge.lib.TimeRuler;
import sge.scene.SceneManager;
import sge.input.InputManager;
import sge.tiles.*;
import sge.world.*;


class Game {

  // 
  // Static Access
  // 

  public static var root (get, never) : DisplayObjectContainer;

  public static var delta (get, never) : Float;

  public static var sceneManager (get, never) : SceneManager;

  public static var inputManager (get, never) : InputManager;

  public static var isPaused (get, never) : Bool;

  public static var ruler (get, never) : TimeRuler;

  public static var debug (get, never) : Debug;

  public static var debugMode :Bool = false;

  public static var drawTimeRuler :Bool = true;

  private static var self :Game;



  public static function addChild_scene( disObj :DisplayObject ) :Void
  {
    if (Game.debugMode) trace('Game:addChild__scene');
    if (Game.self == null) return;
    Game.self.sceneSprite.addChild(disObj);
  }

  public static function removeChild_scene( disObj :DisplayObject ) :Void
  {
   if (Game.self == null) return;
    Game.self.sceneSprite.removeChild(disObj); 
  }

  public static function addChild_debug( disObj :DisplayObject ) :Void
  {
    if (Game.debugMode) trace('Game:addChild__debug');

    if (Game.self == null) return;
    Game.self.debugSprite.addChild(disObj);
  }

  public static function removeChild_debug( disObj :DisplayObject ) :Void
  {
   if (Game.self == null) return;
    Game.self.debugSprite.removeChild(disObj); 
  }

  // 
  // Constructor
  // 
  
  public function new () {
    
    Game.self = this;
    var tile = new Tile();
    var chunk = new Chunk();
    var region = new Region();
    var tileScene = new TileScene();

  }

  public function init ( root :DisplayObjectContainer ) : Void {

    if (Game.debugMode) openfl.Lib.trace("Game:init");

    _root = root;
    _start = _current = Timer.stamp();
    _isPaused = false;
    _delta = 0;

    _sceneManager = new SceneManager();
    _inputManager = new InputManager();

    root.stage.addEventListener( Event.ACTIVATE,     function(_) resume() );
    root.stage.addEventListener( Event.DEACTIVATE,   function(_) pause() );
    root.stage.addEventListener( Event.ENTER_FRAME,  function(_) update() );

    sceneSprite = new Sprite();
    debugSprite = new Sprite();

    root.stage.addChild(sceneSprite);
    root.stage.addChild(debugSprite);

    _debug = new Debug();
    _ruler = new TimeRuler();
    
    debugSprite.addChild(_debug);
    debugSprite.addChild(_ruler);

  }


  public function pause () : Void 
  {
    if (Game.debugMode) trace("Game:pause");
    _isPaused = true;
  }

  public function resume () : Void 
  {
    if (Game.debugMode) trace("Game:resume");
    _isPaused = false;
  }

  public function update () : Void {
    
    if (_isPaused) return;

    _updateDelta();
    _preUpdate();
    _update();
    _render();
    _postUpdate();

  }


  private function _updateDelta () : Void {

    _last = _current;
    _current = Timer.stamp();
    _delta = _current - _last;

  }

  private function _preUpdate() : Void {
    
    _inputManager.update();

  }

  private function _update () : Void {
    
    _sceneManager.update();

  }

  private function _render () : Void {

    _sceneManager.render();

  }

  private function _postUpdate () : Void {

  }



  private var _root :DisplayObjectContainer;

  private var _delta :Float;

  private var _start :Float;

  private var _last :Float;

  private var _current: Float;

  private var _sceneManager :SceneManager;

  private var _inputManager :InputManager;

  private var _isPaused :Bool;

  private var _ruler :TimeRuler;

  private var _debug :Debug;

  private var sceneSprite :Sprite;

  private var debugSprite :Sprite;



  // 
  // Static Getters
  // 
  
  static inline private function get_root() :DisplayObjectContainer return Game.self != null ? Game.self._root : null;
  
  static inline private function get_delta() :Float return Game.self != null ? Game.self._delta : 0;
  
  static inline private function get_sceneManager() :SceneManager return Game.self != null ? Game.self._sceneManager : null;
  
  static inline private function get_inputManager() :InputManager return Game.self != null ? Game.self._inputManager : null;
  
  static inline private function get_isPaused() :Bool return Game.self != null ? Game.self._isPaused : true;

  static inline private function get_ruler() :TimeRuler return Game.self != null ? Game.self._ruler : null;

  static inline private function get_debug() :Debug return Game.self != null ? Game.self._debug : null;
 

}