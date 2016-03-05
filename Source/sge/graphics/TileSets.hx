package sge.graphics;

import openfl.display.BitmapData;


class TileSets {


  public var tileSets :Map<String, TileSetData>;


  public function new() 
  {
    tileSets = new Map();
  }

  // 
  // Add a TileSet to the collection
  // 
  public function addTileSet( tileSetData :TileSetData, ?name :String ) :Void
  {
    tileSets.set( name == null ? tileSetData.name : name, tileSetData );
  }

  // 
  // Get a TileSet from the collection
  // 
  public function getTileSet( name :String ) :TileSetData
  {
    if (! tileSets.exists(name)) return null;

    return tileSets.get(name);
  }

  // 
  // Get a specific frame from a TileSet
  // 
  public function getTileFrame( setName :String, frame :String ) :BitmapData
  {
    tileSet = getTileSet( setName );

    if ( tileSet == null || !tileSet.tileMap.exists(frame) ) return null;

    index = tileSet.tileMap.get(frame);
    return tileSet.tileData[index];
  }

  // to prevent garbage when using getTileFrame frequently
  private var tileSet :TileSetData;
  private var index :Int;

}
