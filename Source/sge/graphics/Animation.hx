package sge.graphics;

import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.display.BitmapData;


// A frame animation
class Animation {


  // basically Tile Data
  public var name :String;

  public var bitmapData (get, never) :BitmapData;

  public var rect (get, never) :Rectangle;

  public var origin (get, never) :Point;

  public var frames :Array<FrameData>;

  public var looping :Bool = true;

  public var reverse :Bool = false;

  public var frameRate :Float = 0.0;

  public var currentIndex (get, set) :Int;

  public var hasCompleted (get, never) :Bool;

  // Callback functions
  public var onComplete :Dynamic;

  public var onLoop :Dynamic;

  public var onFrameChanged :Dynamic;

  

  public function new()
  {
    frames = new Array();
  }


  public function init( data :AnimatioNData ) : Void
  {
    name = data.name;

    looping = data.looping;
    frameRate = data.frameRate;

    for (frame in data.frames)
    {
      addFrame( frame );
    }
  }


  public function addFrame( frameData :FrameData ) : Void
  {
    frames.push(frameData);
  }


  public function dispose() : Void
  {
    name = "";
    looping = true;
    reverse = false;
    frameRate = 0.0;
    currentFrame = null;
    onLoop = null;
    onComplete = null;
    onFrameChanged = null;
    while (frames.length > 0) frames.pop();
    _delta = 0.0;
    _index = 0;
    _hasCompleted = false;
  }


  public function update() : Void
  {
    _delta += Game.delta;
    while (_delta > frameRate)
    {
      reverse ? prevFrame() : nextFrame();
      _delta -= frameRate;
    }
  }


  public inline function nextFrame() currentIndex++;

  public inline function prevFrame() currentIndex--;


  inline function loop() : Void
  {
    if (onLoop != null) onLoop();
  }

  inline function complete() : Void
  {
    _hasCompleted = true;
    if (onComplete != null) onComplete();
  }

  inline function frameChanged() : Void
  {
    if (onFrameChanged != null) onFrameChanged();
  }


  var currentFrame :FrameData;

  var _delta :Float = 0.0;

  var _index :Int = 0;

  var _hasCompleted :Bool = false;

  inline function get_currentIndex() :Int return _index;

  inline function set_currentIndex( value :Int ) :Int 
  {
    if (value == _index) return value;

    if (value > frames.length || value < 0)
    {
      if (looping) 
      {
        value = reverse ? frames.length : 0;
        loop();
      }
      else
      {
        complete();
        return value;
      }
    }
    currentFrame = frames[value];
    frameChanged();
    return _index = value;
  }

  inline function get_hasCompleted() :Bool return _hasCompleted;

  inline function get_bitmapData() :BitmapData return currentFrame.bitmapData;
  
  inline function get_rect() :Rectangle return currentFrame.rect;
  
  inline function get_origin() :Point return currentFrame.origin;

}
