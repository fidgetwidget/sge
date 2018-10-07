package sge.lib.pool;

class Pool<T>
{
  /**

  can't impliment generics and the singleton pattern
  so for singleton in a non abstract scenario do the following:

  public static var instance (get, null) :Pool<T>;
  static function get_instance() :Pool<T> return (instance == null ? new Pool() : instance);

  */

  
  var available :Array<T>;
  public var count :Int = 0;
  public var activeCount (get, never) :Int;
  
  public function new()
  {
    available = new Array();
  }

  // TODO: impliment this for each unique pool
  function createNew() :T  
  {
    count++;
    return null;
  }

  inline public function preFill( count :Int ) :Void
  {
    var item :T;

    for (i in 0...count)
    {
      
      item = createNew();
      available.push(item);

    }
  }

  public function push( item :T ) :Void available.push(item);

  public function get() :T return (available.length > 0) ? available.pop() : createNew();


  inline function get_activeCount() :Int return count - available.length;


}