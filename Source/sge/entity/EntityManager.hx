package sge.entity;


import openfl.display.Graphics;
import sge.geom.Vector;
import sge.collision.Collider;
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

  public var count (get, never) :Int;


  // 
  // Constructor
  // 
  public function new () {}


  // 
  // Methods
  // 

  public function add ( entity : Entity, group :String = "" ) : Void {}

  public function remove ( entity : Entity ) : Void {}

  public function touch ( entity : Entity ) : Void {}

  public function update ( updateAll :Bool = false, onUpdate : Entity -> Void = null, beforeUpdate :Bool = false ) : Void {}

  public function near ( entity : Entity, entities :Array<Entity> = null ) : Array<Entity> { return entities; }

  public function nearPosition ( position : Dynamic, entities :Array<Entity> = null ) : Array<Entity> { return entities; }

  public function collision ( collider : Collider, hits : Array<Entity> ) : Bool { return false; }
  

  public function debug_render ( graphics :Graphics ) :Void { return; }


  public function get_count() :Int return 0;

}
