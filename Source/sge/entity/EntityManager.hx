package sge.entity;

import openfl.display.Graphics;
import sge.geom.Vector;
import sge.collision.sat.Collider;
import sge.scene.Scene;

// NOTE: maybe this should be an interface instead?

// Abstract Class
class EntityManager {

  //
  // Properties
  //

  public var x : Float;

  public var y : Float;

  public var width : Float;

  public var height : Float;

  public var scene : Scene;


  // 
  // Constructor
  // 
  public function new () {}


  // 
  // Methods
  // 

  public function add ( entity : Entity ) : Void {}

  public function remove ( entity : Entity ) : Void {}

  public function touch ( entity : Entity ) : Void {}

  public function update () : Void {}

  public function near ( vector : Vector ) : Array<Entity> { return null; }

  public function collision ( collider : Collider, hits : Array<Entity> ) : Bool { return false; }
  


  public function debug_render ( graphics :Graphics ) { return false; }

}
