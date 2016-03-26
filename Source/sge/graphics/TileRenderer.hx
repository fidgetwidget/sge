package sge.graphics;

import haxe.ds.Vector;
import openfl.display.BitmapData;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import sge.tiles.TILE_LAYERS;
import sge.tiles.TILE_TYPES;
import sge.tiles.TILE_VALUES;
import sge.tiles.NEIGHBORS;


// A Simple render object that is neighbor aware
class TileRenderer {

  public static var TILE_WIDTH  :Int = 16;
  public static var TILE_HEIGHT :Int = 16;

  var rect  :Rectangle;
  var zero  :Point;
  var blank :BitmapData;

  public var collection :TileSetCollection;


  public function new() 
  { 
    rect = new Rectangle(0, 0, TILE_WIDTH, TILE_HEIGHT);
    zero = new Point();
    blank = new BitmapData(TILE_WIDTH, TILE_HEIGHT, true, 0);
    collection = new TileSetCollection();
  }

  // Import the tileset collection
  public function importTilesSets( path :String ) :Void
  {
    TileSetImporter.TILE_WIDTH  = TILE_WIDTH;
    TileSetImporter.TILE_HEIGHT = TILE_HEIGHT;

    TileSetImporter.importTileSets( path, collection);
  }


  public inline function getBitmapData( tileType :UInt, neighbors :UInt = NEIGHBORS.NONE, layer :Int = TILE_LAYERS.DEFAULT ) :BitmapData
  {
    key  = collection.getFrameKey(tileType, neighbors, layer);
    data = collection.getTileFrameById(tileType, key);

    return data;
  }
  // var key   :String;
  // var data  :BitmapData;
  // 

  public inline function copyBitmapData( bitmapData :BitmapData, tileType :UInt, neighbors :UInt = NEIGHBORS.NONE, layer :Int = TILE_LAYERS.DEFAULT ) :Void
  {
    bitmapData.copyPixels( getBitmapData(tileType, neighbors, layer), rect, zero);
  }


  public inline function updateTileFrame( frame :TileFrame, tileType :UInt, neighbors :UInt ) :Void
  {
    frame.bitmapData.copyPixels( getBitmapData(tileType, neighbors, frame.z), rect, zero);
  }


  public inline function updateTileFrame_sides( frame :TileFrame, tileType :UInt, neighborTypes :Vector<UInt>, layer :Int = TILE_LAYERS.DEFAULT, ignoreTypePriority = false ) :Void
  {
    for (index in 0...neighborTypes.length)
    {
      neighborTileType = neighborTypes.get(index);
      if (tileType == TILE_TYPES.NONE ||
        neighborTileType == TILE_TYPES.NONE || 
        neighborTileType == tileType || 
        (tileType > neighborTileType && !ignoreTypePriority)) continue;

      neighborSideVal = TILE_VALUES.NEIGHBOR_TYPES[index];
      key = collection.getSideFrameKey(neighborTileType, neighborSideVal, layer);
      data = collection.getTileFrameById(neighborTileType, key);

      frame.bitmapData.copyPixels( data, rect, zero, null, null, true);
    }
  }


  public inline function clearTileFrame( frame :TileFrame ) :Void
  {
    frame.bitmapData.copyPixels( blank, rect, zero );
  }

  var neighborTileType :UInt;
  var neighborSideVal  :UInt;

  var key   :String;
  var data  :BitmapData;

}
