package sge.lib;

// 
// A simple helper to get the divisor remainder 
// because haxe's implimentation of the modulos opporator 
// returns the dividend
// 
class Pool<T>
{
  /**

  can't impliment generics and the singleton pattern
  so for singleton in a non abstract scenario do the following:

  public static var instance (get, null) :Pool<T>;
  static function get_instance() :Pool<T> return (instance == null ? new Pool() : instance);

  */

  
  var available :Array<T>;
  
  public function new()
  {

    available = new Array();

  }

  // TODO: impliment this for each unique pool
  function createNew() :T  return null;

  inline public function preFill( count :Int ) :Void
  {

    var item :T;
    for (i in 0...count)
    {
      
      item = createNew();
      available.push(item);

    }

  }

  inline public function push( item :T ) :Void
  {
    available.push(item);
  }

  inline public function get() :T
  {

    return (available.length > 0) ? available.pop() : createNew();

  }


}