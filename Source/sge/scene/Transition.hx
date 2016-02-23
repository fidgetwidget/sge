package sge.scene;


class Transition
{

  public var time :Float;

  public var position (get, never) :Float;

  public var onComplete :Dynamic;


  public function new ( time :Float = 0 ) {

    this.time = time;
    _current  = 0;
    _complete = false;

  }


  public function update ( delta :Float ) {

    if (_complete)  return;

    _current += delta;
    if (_current >= time) 
    {  
      _current  = time;
      _complete = true;

      if (onComplete != null)  onComplete();

    }

  }

  public function reset() :Void
  {
    _complete = false;
    _current  = 0;
  }


  private inline function get_position() :Float  return _current / time; 


  private var _complete :Bool = false;
  private var _current :Float = 0;

}
