package sge.graphics;

import openfl.display.BitmapData;


class TileSetCollection {


  public var tileSets (get, never) :Array<TileSetData>;

  public var tileSetNames (get, never) :Iterator<String>;

  public var tileSetIds (get, never) :Iterator<Int>;


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
  public function addTileSet( tileSetData :TileSetData, ?name :String ) :Void
  {
    name = name == null ? tileSetData.name : name;
    sets.push(tileSetData);

    var index = sets.length - 1;
    nameMap.set( tileSetData.name, index );
    idMap.set( tileSetData.id, index );
    idNameMap.set( tileSetData.id, name );

    initVariantCounts( tileSetData );
  }

  // 
  // Get a TileSet from the collection
  // 
  public inline function getTileSet( name :String ) :TileSetData
  {
    if (! nameMap.exists(name)) return null;

    return sets[nameMap.get(name)];
  }

  public inline function getTileSetById( id :Int ) :TileSetData
  {
    if (! idMap.exists(id)) return null;

    return sets[idMap.get(id)];
  }

  // 
  // get the FrameKey for the given tile state
  // 
  public inline function getFrameKey( frameType :UInt, neighborVal :UInt, background :Bool = false ) :String
  {
    return '${frameType}:${neighborVal}' + (background ? '_bg' : '');
  }

  // 
  // get the FrameKey for the side overlap
  // 
  public inline function getSideFrameKey( frameType :UInt, sideVal :UInt, background :Bool = false ) :String
  {
    return '${frameType}:s_${sideVal}' + (background ? '_bg' : '');
  }


  public inline function getNameById( frameType :UInt ) :String return idNameMap.exists(frameType) ? idNameMap.get(frameType) : "";

  // 
  // Get a specific frame from a TileSet
  // 
  public function getTileFrame( setName :String, frameKey :String, allowVariation :Bool = true ) :BitmapData
  {
    tileSet = getTileSet( setName );
    return _getTileFrame( tileSet, frameKey, allowVariation );
  }

  public function getTileFrameById( id :Int, frameKey :String, allowVariation :Bool = true ) :BitmapData
  {
    tileSet = getTileSetById( id );
    return _getTileFrame( tileSet, frameKey, allowVariation );
  }


  inline function _getTileFrame( tileSet :TileSetData, frameKey :String, allowVariation :Bool = true ) :BitmapData
  {
    if ( tileSet == null || !tileSet.tileMap.exists(frameKey) ) return null;

    if (allowVariation)
    {
      var count = tileSet.variantCount.get(frameKey);
      var r = Lib.random_int(0, count);
      if (r > 0)
        frameKey += '_v${r - 1}';
    }

    index = tileSet.tileMap.get(frameKey);

    return tileSet.tileData[index];
  }



  inline function initVariantCounts( tileSetData :TileSetData ) :Void
  {
    var variantKey :String = "_v";
    var frameKey :String = "";
    var keyIndex :Int;

    tileSetData.variantCount = new Map();

    for (name in tileSetData.tileMap.keys())
    {
      keyIndex = name.indexOf(variantKey);
      if (keyIndex >= 0)
      {
        if (name.substr(0, keyIndex) != frameKey)
        {
          frameKey = name.substr(0, keyIndex);
          tileSetData.variantCount.set(frameKey, 1);
        }
        else
        {
          var count = tileSetData.variantCount.get(frameKey);
          tileSetData.variantCount.set(frameKey, count++);
        }
      }
    }
  }

  var sets :Array<TileSetData>;
  var idMap :Map<Int, Int>;
  var nameMap :Map<String, Int>;
  var idNameMap :Map<Int, String>;


  inline function get_tileSets() :Array<TileSetData> return sets; // maybe I should only expose the iterator?

  inline function get_tileSetNames() :Iterator<String> return nameMap.keys();

  inline function get_tileSetIds() :Iterator<Int> return idMap.keys();

  // to prevent garbage when using getTileFrame frequently
  private var tileSet :TileSetData;
  private var index :Int;

}
