package sge.geom;

import haxe.ds.HashMap;
import openfl.errors.Error;

// 
// Helper for storing and retrieving objects with Coordinate values.
// 
class CoordMap<T>
{

  // TODO: create a CoordPool and use that instead of the local cache
  
  public function new()
  {
    _hashMap = new HashMap();
    _coord = new Coord();
  }

  public function set( coord :Coord, value :T ) :Void
  {
    _hashMap.set(coord, value);
  }

  public function setAt( x :Int, y :Int, value :T ) :Void
  {
    getCoord(x, y);

    _hashMap.set(_coord, value);
  }

  public function get( coord :Coord ) :T
  {
    if (Game.debugMode && !_hashMap.exists(coord)) throw new Error('CoordMap index out of range Exception');

    return _hashMap.get(coord);
  }

  public function getAt( x :Int, y :Int ) :T
  {
    getCoord(x, y);

    return get(_coord);
  }


  public function iterator() : Iterator<T> return _hashMap.iterator();


  inline function getCoord( x :Int, y :Int ) :Coord
  {    
    _coord.x = x;
    _coord.y = y;

    return _coord;
  }


  var _hashMap :HashMap<Coord, T>;
  var _coord :Coord;


}