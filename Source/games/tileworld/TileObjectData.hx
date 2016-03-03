package games.tileworld;

import openfl.display.BitmapData;
import sge.geom.base.Rectangle; // we just care about the x, y, width and height


typedef TileObjectData = {

  var name :String;
  var id :UInt;
  var tileObjectType :String;
  var layer :UInt; // which tile layer the object will be placed on

  // placement info
  // what tile x,y offset its placed at
  var center_tile_x :Int;
  var center_tile_y :Int;
  // collision rectangles
  // the x and y are offset from the center_tile_x/y position
  var emptyReq :Rectangle; // don't collide with this
  var emptyReqTiles :Array<Int>;
  var collisionReq :Rectangle; // do collide with this
  var collisionReqTiles :Array<Int>;

  // [x, y, dir, x, y, dir...] offset values & collision direction values to set when placed
  // the x & y are offset from the center_tile_x/y position
  var collisionTiles :Array<Int>;
  
  // image info
  var filename :String;
  var image_rect :Rectangle;
  var image_rect_bg :Rectangle;
  var image_rect_fg :Rectangle;

  var tiles_wide :Int;
  var tiles_high :Int;
  // how the image breaks down to individual tiles
  var tileFrames :Array<TileFrameData>;

}
