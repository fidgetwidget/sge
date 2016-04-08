package sge.entity;

import openfl.display.DisplayObject;
import openfl.display.Graphics;
import sge.collision.sat.Collider;
import sge.collision.sat.shapes.Shape;
import sge.entity.EntityManager;
import sge.geom.Motion;
import sge.geom.Transform;
import sge.geom.Vector;

class Entity
{

  // 
  // Static Unique Id
  // 
  private static var uid : Int = 1;
  private static function getNextId() : Int
  {
    return Entity.uid++;
  }


  // 
  // Properties
  // 
  
  public var id (get, null) :Int;
  
  public var name :String;

  public var manager :EntityManager;


  public var transform (get, never) :Transform;

  public var x (get, set) :Float;

  public var y (get, set) :Float;

  public var angle (get, set) :Float;

  public var scaleX (get, set) :Float;

  public var scaleY (get, set) :Float;


  public var motion (get, never) :Motion;

  public var velocityX (get, set) :Float;

  public var velocityY (get, set) :Float;

  public var accelerationX (get, set) :Float;

  public var accelerationY (get, set) :Float;

  public var dragX (get, set) :Float;

  public var dragY (get, set) :Float;

  public var angularVelocity (get, set) :Float;

  public var angularAcceleration (get, set) :Float;

  public var angularDrag (get, set) :Float;

  public var velocityLimit (get, set) :Float;

  public var angularVelocityLimit (get, set) :Float;

  public var isStatic (get, set) : Bool;


  public var collider :Collider;


  public var width (get, never) :Float;

  public var height (get, never) :Float;

  public var sprite :DisplayObject;

  public var anchor :Vector;

  public var hasSprite (get, never) :Bool;

  public var hasCollider (get, never) :Bool;

  // 
  // Constructor
  // 
  public function new () 
  {
    _id   = Entity.getNextId();
    name  = Type.getClassName(Type.getClass(this));
    _transform    = new Transform();
    _motion       = new Motion();
    anchor        = new Vector();
  }


  // 
  // Methods
  // 
  
  public function createCollider ( shape :Shape ) :Void collider = new Collider( transform, shape );

  
  public function update() : Void 
  {
    _preUpdate();

    if (!isStatic) _updateMotion();

    if (hasSprite) _updateSprite();

    _postUpdate(); 
  }

  private function _preUpdate () : Void return;

  private inline function _updateMotion () : Void motion.update( Game.delta, _transform );
  

  private inline function _updateSprite () : Void 
  {
    sprite.x = x - anchor.x;
    sprite.y = y - anchor.y;
    sprite.rotation = angle; 
  }

  private function _postUpdate () : Void return;


  public function debug_render( graphics :Graphics ) :Void 
  {
    if (hasCollider)
      collider.debug_render(graphics);
    else
    {
      graphics.drawCircle(x, y, 3);
    }
  }

  // 
  // Property Getters & Setters
  // 

  inline private function get_id() :Int return _id;

  // transform
  inline private function get_transform() :Transform return _transform;
  // x & y
  inline private function get_x() :Float return _transform.x;
  inline private function set_x( x :Float ) :Float return _transform.x = x;
  inline private function get_y() :Float return _transform.y;
  inline private function set_y( y :Float ) :Float return _transform.y = y;
  // angle
  inline private function get_angle() :Float return _transform.rotation;
  inline private function set_angle( angle : Float ) :Float return _transform.rotation = angle;
  // scale
  inline private function get_scaleX() :Float return _transform.scaleX;
  inline private function set_scaleX( x :Float ) :Float return _transform.scaleX = x;
  inline private function get_scaleY() :Float return _transform.scaleY;
  inline private function set_scaleY( y :Float ) :Float return _transform.scaleY = y;

  // motion
  inline private function get_motion() :Motion return _motion;
  // velocity
  inline private function get_velocityX() :Float  return _motion.velocityX;
  inline private function set_velocityX( x :Float ) :Float  return _motion.velocityX = x;
  inline private function get_velocityY() :Float  return _motion.velocityY;
  inline private function set_velocityY( y :Float ) :Float  return _motion.velocityY = y;
  // acceleration
  inline private function get_accelerationX() :Float  return _motion.accelerationX;
  inline private function set_accelerationX( x :Float ) :Float  return _motion.accelerationX = x;
  inline private function get_accelerationY() :Float  return _motion.accelerationY;
  inline private function set_accelerationY( y :Float ) :Float  return _motion.accelerationY = y;
  // drag
  inline private function get_dragX() :Float  return _motion.dragX;
  inline private function set_dragX( x :Float ) :Float  return _motion.dragX = x;
  inline private function get_dragY() :Float  return _motion.dragY;
  inline private function set_dragY( y :Float ) :Float  return _motion.dragY = y;
  // angularVelocity
  inline private function get_angularVelocity() :Float  return _motion.angularVelocity;
  inline private function set_angularVelocity( value :Float ) :Float  return _motion.angularVelocity = value;
  // angularAcceleration
  inline private function get_angularAcceleration() :Float  return _motion.angularAcceleration;
  inline private function set_angularAcceleration( value :Float ) :Float  return _motion.angularAcceleration = value;
  // angularDrag
  inline private function get_angularDrag() :Float  return _motion.angularDrag;
  inline private function set_angularDrag( value :Float ) :Float  return _motion.angularDrag = value;
  // velocityLimit
  inline private function get_velocityLimit() :Float  return _motion.velocityLimit;
  inline private function set_velocityLimit( value :Float ) :Float  return _motion.velocityLimit = value;
  // angularVelocityLimit
  inline private function get_angularVelocityLimit() :Float  return _motion.angularVelocityLimit;
  inline private function set_angularVelocityLimit( value :Float ) :Float  return _motion.angularVelocityLimit = value;
  // 
  inline private function get_isStatic() :Bool return _static;
  inline private function set_isStatic( isStatic :Bool ) :Bool return _static = isStatic;

  // width & height
  inline private function get_width() :Float  return collider == null ? 0 : collider.width;
  inline private function get_height() :Float  return collider == null ? 0 : collider.height;

  // has sprite
  inline private function get_hasSprite() :Bool  return sprite != null;
  inline private function get_hasCollider() :Bool  return collider != null;
  
  
  private var _id :Int;
  private var _transform :Transform;
  private var _motion :Motion;
  private var _static :Bool;

}
