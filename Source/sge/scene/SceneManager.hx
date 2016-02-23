package sge.scene;

import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import sge.Game;
import sge.scene.Scene;


class SceneManager
{

  // 
  // Properties
  // 

  public var allScenes (default, null) : Map<String, Scene>;

  public var activeScene (get, null) : Scene;

  public var occludedScenes (default, null) : Array<Scene>;

  public var isTransitioning (get, null) : Bool;

  public var camera : Camera;


  // 
  // Constructor
  // 
  public function new()
  {

    allScenes = new Map();
    occludedScenes = new Array<Scene>();

  }


  // 
  // Methods
  // 

  // Update
  public function update () : Void 
  {

    if (_nextScene != null) {

      if (_nextSceneTransition != null)  _nextSceneTransition.update( Game.delta );
      else  nextSceneTransitionComplete();

    }

    if (_activeScene == null)  return;

    _activeScene.update();

    // If the active scene isn't opaque, then update the scene(s) below it
    if (!_activeScene.isOpaque && occludedScenes.length > 0) {

      var oSceneIndex = occludedScenes.length - 1;
      var oScene :Scene;

      while (oSceneIndex > 0)
      {

        oScene = occludedScenes[oSceneIndex];
        
        if (oScene != _activeScene)  oScene.update();

        if (oScene.isOpaque)  oSceneIndex = 1; // don't update any more below this
        
        oSceneIndex--;

      }

    }

  }


  private function nextSceneTransitionComplete()
  {
    if (Game.debugMode) trace("SceneManager:nextSceneTransitionComplete");

    if (_nextSceneTransition != null)
    {
        // Clean up the pointer to this method
      _nextSceneTransition.onComplete = null;
      // Recycle it
      _nextSceneTransition.reset();
      _nextSceneTransition = null;
    }

    if (_activeScene != null)  _activeScene.unload();
    
    _activeScene = _nextScene;
    _nextScene = null;

  }


  // Render
  public function render () : Void {

    // trace("SceneManager:render.");

    if (occludedScenes != null && occludedScenes.length > 0) {
      
      for (oScene in occludedScenes) {
        if (oScene != _activeScene)  oScene.render();
      }

    }

    if (_activeScene == null)  return;

    _activeScene.render();

  }

  // Add Scene
  public function addScene ( scene :Scene, ?name :String ) : Void {
    
    if (name != null) { 
      allScenes.set(name, scene);
      return;
    }

    allScenes.set(scene.name, scene);

    scene.manager = this;

  }

  // Push Scene
  public function pushScene ( scene :Dynamic, ?transition :Transition ) :Void {

    if (Game.debugMode) trace("SceneManager:pushScene");

    if (Std.is(scene, String))  scene = getScene(scene);
    else  scene.manager = this;

    // transition to the given scene
    _nextScene = scene;

    if (transition != null) {
      _nextSceneTransition = transition;
      _nextSceneTransition.onComplete = this.nextSceneTransitionComplete;
    } 

    if (_activeScene != null)  occludedScenes.push(_activeScene);

    _nextScene.ready();

  }

  // Get Scene
  public function getScene ( name :String ) : Scene {

    if (! allScenes.exists(name) )  return null;

    return allScenes.get(name);

  }

  // Remove Scene
  public function removeScene ( name :String ) : Void {

    allScenes.remove(name);

  }

  // Pop Scene
  public function popScene ( ?transition :Transition ) : Scene 
  {

    if (occludedScenes.length > 0)  _nextScene = occludedScenes.pop();

    if (transition != null)  _nextSceneTransition = transition;

    return _nextScene;

  }


  // 
  // Property Getters & Setters
  // 

  private function get_activeScene () : Scene return _activeScene;

  private function get_isTransitioning () : Bool return _isTransitioning;



  private var _activeScene : Scene = null;

  private var _nextScene : Scene = null;

  private var _nextSceneTransition : Transition = null;
  
  private var _isTransitioning : Bool = false;

}
