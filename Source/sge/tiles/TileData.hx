package sge.tiles;

import sge.graphics.TileFrame;

// 
// The Data that represents a Tile
// 
// Relative Position (x, y)
// Depth (z)
// Type (type) - display, collision, etc
// Display Variables (type, neighbors, corners, neighborTypes)
// 
typedef TileData = {

  var x :Int;

  var y :Int;

  var z :Int;

  var type :UInt;

  var neighbors :UInt; // 4 direction neighbor state

  var corners :UInt; // 8 direction neighbor state


  // neighborTypes 0, 1, 2, 3
  var neighborType_north :UInt;

  var neighborType_east :UInt;

  var neighborType_south :UInt;

  var neighborType_west :UInt;

}
