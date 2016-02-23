package sge.collision.sat.ray;


// 
// Collision between Ray and Ray
// 
class RayIntersection
{
 
  public var ray1 :Ray;
  public var ray2 :Ray;
  public var u1   :Float; // u value for ray1
  public var u2   :Float; // u value for ray2


  public function new( ray1 :Ray, u1 :Float, ray2 :Ray, u2 :Float ) 
  {
    this.ray1 = ray1;
    this.ray2 = ray2;
    this.u1   = u1;
    this.u2   = u2;
  }

}
