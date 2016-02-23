package sge.geom;

// 
// Helper for storing and retrieving objects with Coordinate values.
// 
class CoordMap<T>
{

  
  public function new()
  {
    _hashMap = new HashMap();
    _coordCache = new Array();
  }

  public function set( coord :Coord, value :T ) :Void
  {
    _hashMap.set(coord, value);
  }

  public function setAt( x :Int, y :Int, value :T ) :Void
  {
    var coord = getCoord(x, y);
    _hashMap.set(coord, value);
    _coordCache.push(coord);
  }

  public function get( coord :Coord ) :T
  {
    return _hashMap.get(coord);
  }

  public function getAt( x :Int, y :Int ) :T
  {
    var coord = getCoord(x, y);
    var value = _hashMap.get(coord);
    _coordCache.push(coord);
    return value;
  }



  private function getCoord( x :Int, y :Int ) :Coord
  {
    var coord;
    if (_coordCache.length > 0)
    {
      coord = _coordCache.pop();
      coord.x = x;
      coord.y = y;
    }
    else
    {
      coord = new Coord(x, y);
    }
    return coord;
  }


  private var _hashMap :HashMap<Coord, T>;
  private var _coordCache :Array<Coord>;


}