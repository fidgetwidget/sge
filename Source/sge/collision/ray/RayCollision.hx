package sge.collision.ray;

import sge.collision.shapes.Shape;


// 
// Collision between Ray and Shape
// 
@:publicFields
class RayCollision
{
  
  var shape  :Shape;
  var ray    :Ray;
  var start  :Float = 0.0;  // Distance along ray that the intersection start at
  var end    :Float = 0.0;  // Distance along ray that the intersection ended at
  

  @:noCompletion
  inline function new() {}

  inline function reset() 
  {
    ray = null;
    shape = null;
    start = 0.0;
    end = 0.0;

    return this;
  } //reset

  inline function copy_from( other :RayCollision ) 
  {

    ray = other.ray;
    shape = other.shape;
    start = other.start;
    end = other.end;

  } //copy_from

  inline function clone() 
  {
    var _clone = new RayCollision();

    _clone.copy_from(this);

    return _clone;
  } //copy_from

}
