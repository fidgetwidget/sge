package games.tileworld;

import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.PNGEncoderOptions;
import openfl.display.PixelSnapping;
import openfl.geom.Point;
import openfl.geom.Rectangle;

import sge.Game;
import sge.Lib;
import sge.scene.Camera;
import sge.scene.Scene;
import sge.collision.AABB;
import sge.collision.Collision;


class Player {

  // 
  // Properties
  // 

  public var x (get, set) :Int;

  public var y (get, set) :Int;

  public var width (get, never) :Int;

  public var height (get, never) :Int;

  public var scaleX (get, set) :Float;

  public var scaleY (get, set) :Float;

  public var velocityX (get, set) :Float;

  public var velocityY (get, set) :Float;

  public var bounds :AABB;

  public var sourceImage :BitmapData;

  public var image :Bitmap;

  public var direction (get, never) :Int;


  var scene :Scene;
  var camera :Camera;

  var camera_x (get, never) :Float;
  var camera_y (get, never) :Float;

  // 
  // Constructor
  // 
  public function new( scene :Scene ) 
  {
    this.scene = scene;
    this.camera = scene.camera;
    x = 0;
    y = 0;
    _width = 32;
    _height = 64;
    velocityX = 0;
    velocityY = 0;

    bounds = AABB.make_rect(0, 0, width, height);

    var bitmapData = new BitmapData( width, height, true, 0 );
    var rect :Rectangle = new Rectangle(0, 0, width, height);
    var zero :Point = new Point();

    sourceImage = Assets.getBitmapData('images/player.png');
    image = new Bitmap(bitmapData, PixelSnapping.ALWAYS, false);
    image.bitmapData.copyPixels(sourceImage, rect, zero);
  }

  
  public function update() : Void 
  {
    setPosition( x + velocityX, y + velocityY ); 
  }


  public inline function resolveCollision( px :Float, py :Float ) :Void
  {
    if (Math.abs(px) > 0) velocityX = 0;
    if (Math.abs(py) > 0) velocityY = 0;

    setPosition( x - px, y - py );
  }


  public inline function setPosition( x :Float, y :Float ) :Void
  {
    _x = Math.floor(x);
    _y = Math.floor(y);
    setImageAndBounds();
  }


  inline function setImageAndBounds() :Void
  {
    bounds.centerX = x;
    bounds.y = y;

    image.x = (bounds.x - camera.x) * camera.scaleX;
    image.y = (bounds.y - camera.y) * camera.scaleY;

    if (direction != 0)
    {
      image.scaleX = camera.scaleX * direction;
    }
    
    if (image.scaleX < 0)
    {
      image.x = (bounds.x + width - camera.x) * camera.scaleX;
    }
  }

  // 
  // Property Getters & Setters
  // 

  var _x :Int;
  var _y :Int;
  var _width :Int;
  var _height :Int;

  var _velocityX :Float;
  var _velocityY :Float;

  // x & y
  inline function get_x() :Int return _x;
  inline function set_x( value :Int ) :Int return _x = value;
  inline function get_y() :Int return _y;
  inline function set_y( value :Int ) :Int return _y = value;
  
  // width & height
  inline function get_width() :Int  return _width;
  inline function get_height() :Int  return _height;

  // scale
  inline function get_scaleX() :Float return image.scaleX;
  inline function set_scaleX( value :Float ) :Float return image.scaleX = value;
  inline function get_scaleY() :Float return image.scaleY;
  inline function set_scaleY( value :Float ) :Float return image.scaleY = value;

  // velocity
  inline function get_velocityX() :Float  return _velocityX;
  inline function set_velocityX( value :Float ) :Float  return _velocityX = value;
  inline function get_velocityY() :Float  return _velocityY;
  inline function set_velocityY( value :Float ) :Float  return _velocityY = value;

  inline function get_direction() :Int return _velocityX > 0 ? 1 : _velocityX < 0 ? -1 : 0;

  inline function get_camera_x() :Float return camera == null ? 0 : camera.x;
  inline function get_camera_y() :Float return camera == null ? 0 : camera.y;

}
