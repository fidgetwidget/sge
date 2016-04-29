package sge.graphics;

import openfl.display.BitmapData;
import sge.tiles.TILE_LAYERS;


class AnimationSet {


  public var animations (get, never) :Array<AnimationData>;

  public var animationNames (get, never) :Iterator<String>;

  public var animationIds (get, never) :Iterator<Int>;


  public function new()
  {
    sets = new Array();
    nameMap = new Map();
    idMap = new Map();
    idNameMap = new Map();
  }

  // 
  // Add a TileSet to the collection
  // 
  public function addAnimation( animation :AnimationData, ?name :String ) :Void
  {
    name = name == null ? animation.name : name;
    sets.push(animation);

    var index = sets.length - 1;
    
    nameMap.set( animation.name, index );
    idMap.set( animation.id, index );
    idNameMap.set( animation.id, name );
  }

  // 
  // Get a TileSet from the collection
  // 
  public inline function getAnimation( name :String ) :AnimationData
  {
    if (! nameMap.exists(name)) return null;

    return sets[nameMap.get(name)];
  }

  public inline function getAnimationById( id :Int ) :AnimationData
  {
    if (! idMap.exists(id)) return null;

    return sets[idMap.get(id)];
  }


  public inline function getNameById( id :UInt ) :String return idNameMap.exists(id) ? idNameMap.get(id) : "";



  var sets :Array<AnimationData>;
  var idMap :Map<Int, Int>;
  var nameMap :Map<String, Int>;
  var idNameMap :Map<Int, String>;


  inline function get_tileSets() :Array<AnimationData> return sets; // maybe I should only expose the iterator?

  inline function get_tileSetNames() :Iterator<String> return nameMap.keys();

  inline function get_tileSetIds() :Iterator<Int> return idMap.keys();

  // to prevent garbage when using getTileFrame frequently
  private var animData :AnimationData;
  private var index :Int;

}
