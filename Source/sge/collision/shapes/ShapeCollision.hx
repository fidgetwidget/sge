package sge.collision.shapes;

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
  var separationX (get, set) :Float;
  var separationY (get, set) :Float;

  var unitVector :Vector;    // unit vector on the axis of the collision (the normal of the face that was collided with)
  var unitVectorX (get, set) :Float;
  var unitVectorY (get, set) :Float;

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

  inline function get_separationX() :Float return separation.x;
  inline function set_separationX( value :Float ) :Float return separation.x = value;

  inline function get_separationY() :Float return separation.y;
  inline function set_separationY( value :Float ) :Float return separation.y = value;

  inline function get_unitVectorX() :Float return unitVector.x;
  inline function set_unitVectorX( value :Float ) :Float return unitVector.x = value;

  inline function get_unitVectorY() :Float return unitVector.y;
  inline function set_unitVectorY( value :Float ) :Float return unitVector.y = value;

  public inline function toString() return 'ShapeCollision[overlap: $overlap separation: ${separation.x}|${separation.y} unitVector: ${unitVector.x}|${unitVector.y}]';

}
