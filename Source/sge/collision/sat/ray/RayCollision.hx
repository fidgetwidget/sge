package sge.collision.sat.ray;

import sge.collision.sat.shapes.Shape;


// 
// Collision between Ray and Shape
// 
class RayCollision
{
  
  public var shape  :Shape;
  public var ray    :Ray;
  public var start  :Float;  // Distance along ray that the intersection start at
  public var end    :Float;  // Distance along ray that the intersection ended at
  

  public function new( shape:Shape, ray:Ray, start:Float, end:Float ) 
  {
    this.ray    = ray;
    this.shape  = shape;
    this.start  = start;
    this.end    = end;
  }

}
