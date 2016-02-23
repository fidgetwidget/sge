package sge.collision.sat.shapes;

import sge.geom.Vector;


// 
// Collision between Shape and Shape
// 
@:publicFields
class ShapeCollision
{


  var shape1     :Shape;
  var shape2     :Shape;

  var overlap    :Float = 0; // the overlap amount

  var separation :Vector;    // a vector that when subtracted to shape 1 will separate it from shape 2
  var unitVector :Vector;    // unit vector on the axis of the collision (the normal of the face that was collided with)

  var other      :ShapeCollision;


  inline function new() 
  {
    separation = new Vector();
    unitVector = new Vector();
    other = null;
    shape1 = null;
    shape2 = null;
  }


  inline function reset() :ShapeCollision
  {

    shape1 = shape2 = null;
    overlap = separation.x = separation.y = unitVector.x = unitVector.y = 0.0;
    other = null;

    return this;

  } //reset


  inline function clone() :ShapeCollision
  {

    var _clone = new ShapeCollision();
    return _clone.copy_from(this);

  } //clone


  inline function copy_from( other :ShapeCollision ) :ShapeCollision 
  {

    shape1 = other.shape1;
    shape2 = other.shape2;

    overlap = other.overlap;
    separation.x = other.separation.x;
    separation.y = other.separation.y;
    unitVector.x = other.unitVector.x;
    unitVector.y = other.unitVector.y;

    return this;

  } //copy_from

}
