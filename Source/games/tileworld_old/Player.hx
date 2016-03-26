package games.tileworld_old;

import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.PNGEncoderOptions;
import openfl.display.PixelSnapping;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.ui.Keyboard;
import sge.Game;
import sge.Lib;
import sge.scene.Camera;
import sge.scene.Scene;
import sge.collision.AABB;
import sge.collision.Collision;

import games.tileworld_old.world.WorldCollisionHandler;

class Player {

  var DEFAULT_JUMP_POWER = 10;
  var DEFAULT_JUMP_TIMER = 30;
  var BASE_JUMP_VELOCITY_CONST = 0.25;


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

  public var canJump (get, never) :Bool;

  public var isJumping (get, never) :Bool;

  public var freeMove :Bool = false;


  var scene :Scene;
  var wch :WorldCollisionHandler;
  var camera :Camera;
  var imageOffsetX :Float; // the offset for player position to image position
  var imageOffsetY :Float; // the offset for player position to image position

  var camera_x (get, never) :Float;

  var camera_y (get, never) :Float;

  // 
  // Constructor
  // 
  public function new( scene :Scene, wch :WorldCollisionHandler ) 
  {
    this.scene = scene;
    this.wch = wch;
    this.camera = scene.camera;
    x = 0;
    y = 0;
    _width = 32;
    _height = 64;
    velocityX = 0;
    velocityY = 0;
    imageOffsetX = 16;
    imageOffsetY = 64;

    bounds = AABB.make_rect(0, 0, width, height);
    bounds.width = 24;

    var bitmapData = new BitmapData( width, height, true, 0 );
    var rect :Rectangle = new Rectangle(0, 0, width, height);
    var zero :Point = new Point();

    sourceImage = Assets.getBitmapData('images/player.png');
    image = new Bitmap(bitmapData, PixelSnapping.ALWAYS, false);
    image.bitmapData.copyPixels(sourceImage, rect, zero);
  }

  
  public function update() : Void 
  {
    handleInput();

    if (jumpTimer > 0)
    {
      velocityY -= (jumpTimer * 0.01 + BASE_JUMP_VELOCITY_CONST);
      jumpTimer--;
    }

    var collision = wch.testCollision_point(x, y + 1);
    
    // Game.debug.setLabel('player', '$x|$y v$velocityX|$velocityY');
    // Game.debug.setLabel('jump', '$jumpTimer $collision');

    setPosition( x + velocityX, y + velocityY );
  }


  public function render() : Void
  {
    setImageAndBounds();
  }


  public inline function resolveCollision( px :Float, py :Float ) :Void
  {
    if (Math.abs(px) > 0) velocityX = 0;
    if (Math.abs(py) > 0) velocityY = 0;
    if (Math.abs(py) > 0) doLanding();

    setPosition( x - px, y - py );
  }


  public inline function setPosition( x :Float, y :Float ) :Void
  {
    _x = Math.floor(x);
    _y = Math.floor(y);
    setImageAndBounds();
  }


  public inline function doJump() :Void
  {
    velocityY -= DEFAULT_JUMP_POWER;
    jumpTimer = DEFAULT_JUMP_TIMER;
    _canJump = false;
  }


  public inline function doLanding() :Void
  {
    jumpTimer = 0;
    _canJump = true;
  }


  inline function handleInput() :Void
  {
    var input = Game.inputManager;

    if (input.keyboard.isDown(Keyboard.LEFT) || input.keyboard.isDown(Keyboard.A) ||
       input.keyboard.isDown(Keyboard.RIGHT) || input.keyboard.isDown(Keyboard.D))
    {
      if (input.keyboard.isDown(Keyboard.LEFT) || input.keyboard.isDown(Keyboard.A))
      {
        velocityX = -4;
      } 
      if (input.keyboard.isDown(Keyboard.RIGHT) || input.keyboard.isDown(Keyboard.D))
      {
        velocityX = 4;
      } 
    }
    else
    {
      velocityX = 0;
    }

    if (!freeMove)
    {
      if (input.keyboard.isDown(Keyboard.Z) ||
          input.keyboard.isDown(Keyboard.UP) ||
          input.keyboard.isDown(Keyboard.W))
      {
        if (canJump) doJump();
        _readyToJump = false;
      }
      else
      {
        jumpTimer = 0;
        _readyToJump = true;
      }
      // gravity
      velocityY += CONST.GRAVITY_ACCELERATION;
    }
    else
    {
      if (input.keyboard.isDown(Keyboard.UP) ||
          input.keyboard.isDown(Keyboard.DOWN))
      {
        if (input.keyboard.isDown(Keyboard.UP))
        {
          velocityY = -4;
        } 
        if (input.keyboard.isDown(Keyboard.DOWN))
        {
          velocityY = 4;
        } 
      }
      else
      {
        velocityY = 0;
      }
    }
  }


  inline function setImageAndBounds() :Void
  {
    bounds.centerX = x;
    bounds.y = y;

    image.x = (x - imageOffsetX - camera.x) * camera.scaleX;
    image.y = (y - imageOffsetY - camera.y) * camera.scaleY;

    if (direction != 0)
    {
      image.scaleX = camera.scaleX * direction;
    }
    
    if (image.scaleX < 0)
    {
      image.x = (x - imageOffsetX + width - camera.x) * camera.scaleX;
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

  var jumpTimer :Int = 0;
  var _canJump :Bool;
  var _readyToJump :Bool;

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

  inline function get_canJump() :Bool return jumpTimer == 0 && _canJump && _readyToJump && wch.testCollision_point(x, y + 8);
  inline function get_isJumping() :Bool return jumpTimer > 0;

}
