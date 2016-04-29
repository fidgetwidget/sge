package sge.geom;


class Motion
{

  var MIN_VELOCITY = 0.1;
  
  public var velocity :Vector;
  public var acceleration :Vector;
  public var drag :Vector;

  public var velocityX (get, set) :Float;
  public var velocityY (get, set) :Float;
  public var accelerationX (get, set) :Float;
  public var accelerationY (get, set) :Float;
  public var dragX (get, set) :Float;
  public var dragY (get, set) :Float;

  public var linearDrag :Float;

  public var angularVelocity :Float;
  public var angularAcceleration :Float;
  public var angularDrag :Float;

  public var velocityLimit :Float;
  public var angularVelocityLimit :Float;

  public var inMotion (get, never) :Bool;


  public function new()
  {
    velocity = new Vector();
    acceleration = new Vector();
    drag = new Vector();
    linearDrag = 0;
    
    angularVelocity = 0;
    angularAcceleration = 0;
    angularDrag = 0;

    velocityLimit = 0;
    angularVelocityLimit = 0;
  }


  // This half stepping concept is taken from flixel...
  public function update( elapsed :Float = 1, transform :Transform = null ) :Void
  {
    var velocityDelta :Float, delta :Float;

    velocityDelta = computeVelocity( angularVelocity, angularAcceleration, angularDrag, angularVelocityLimit, elapsed) - angularVelocity;

    angularVelocity += velocityDelta * 0.5;
    if (transform != null) transform.rotation += angularVelocity * elapsed;
    angularVelocity += velocityDelta * 0.5;

    velocityDelta = computeVelocity( velocityX, accelerationX, dragX, velocityLimit, elapsed) - velocityX;

    velocityX += velocityDelta * 0.5;
    delta = velocityX * elapsed;
    velocityX += velocityDelta * 0.5;
    if (transform != null) transform.x += delta;

    velocityDelta = computeVelocity( velocityY, accelerationY, dragY, velocityLimit, elapsed) - velocityY;

    velocityY += velocityDelta * 0.5;
    delta = velocityY * elapsed;
    velocityY += velocityDelta * 0.5;
    if (transform != null) transform.y += delta;
  }


  private function computeVelocity( vel :Float, accel :Float, drag :Float, limit :Float, elapsed :Float = 1 ) :Float
  {
    if (accel != 0)
    {
      vel += accel * elapsed;
    }
    else if (drag != 0 || linearDrag != 0)
    {
      if (linearDrag != 0)
        drag = Math.abs(vel) * linearDrag * elapsed;
      else
        drag = drag * elapsed;

      if (vel - drag > 0)       { vel -= drag; }
      else if (vel + drag < 0)  { vel += drag; }
      else                      { vel = 0; }

      if (Math.abs(vel) < MIN_VELOCITY) vel = 0;

    }

    if (vel != 0 && limit != 0)
    {
      vel = ( vel > limit ? limit : (vel < -limit ? -limit : vel) );
    }

    return vel;
  }


  inline private function get_velocityX() :Float return velocity.x;
  inline private function set_velocityX( x :Float ) :Float return velocity.x = x;
  inline private function get_velocityY() :Float return velocity.y;
  inline private function set_velocityY( y :Float ) :Float return velocity.y = y;

  inline private function get_accelerationX() :Float return acceleration.x;
  inline private function set_accelerationX( x :Float ) :Float return acceleration.x = x;
  inline private function get_accelerationY() :Float return acceleration.y;
  inline private function set_accelerationY( y :Float ) :Float return acceleration.y = y;

  inline private function get_dragX() :Float return drag.x;
  inline private function set_dragX( x :Float ) :Float return drag.x = x;
  inline private function get_dragY() :Float return drag.y;
  inline private function set_dragY( y :Float ) :Float return drag.y = y;

  inline private function get_inMotion() :Bool
  {
    return 
      acceleration.x != 0 || acceleration.y != 0 ||
      velocity.x != 0 || velocity.y != 0 || 
      angularAcceleration != 0 || angularVelocity != 0;
  }

}