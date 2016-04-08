package sge.graphics;

import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.display.Bitmap;
import openfl.display.BitmapData;


class AnimatedBitmapData {


  public var bitmapData (get, never) :BitmapData;

  public var frameRect (get, never) :Rectangle;

  public var frameOrigin (get, never) :Point;

  public var animations :Map<String, Animation>;

  

  public function new()
  {
    animations = new Map();
  }


  public function update() : Void
  {
    if (_current == null) return;

    _current.update();
  }


  public function addAnimation( data :AnimationData ) : Void
  {
    var animation = AnimationPool.instance.getAnimation();
    animation.init(data);

    animations.set(data.name, animation);
  }


  public function setAnimation( name :String, frame :Int = 0 ) : Void
  {
    if (!animations.exists(name)) return;

    if (_current != null) cleanupCurrent();

    _current = animations.get(name);
    _current.currentIndex = frame;
  }

  public function setIdleAnimation( name :String ) : Void
  {
    _idleFrameName = name;
  }

  public function updateBitmap( bitmap :Bitmap, origin :Point = null ) : Void
  {
    if (!_dirty) return;

    // if (_target == null) _target = new Point();

    // _target.x = frameOrigin.x + (origin == null ? 0 : origin.x);
    // _target.y = frameOrigin.y + (origin == null ? 0 : origin.y);

    bitmap.bitmapData = _current.bitmapData;

    // bitmap.bitmapData.copyPixels( bitmapData, frameRect, _target);
    
    _dirty = false;
  }

  inline function cleanupCurrent() : Void
  {
    _current.onComplete     = null;
    _current.onLoop         = null;
    _current.onFrameChange  = null;
  }

  inline function hookupCurrent() : Void
  {
    _current.onComplete     = this.onComplete;
    _current.onLoop         = this.onLoop;
    _current.onFrameChange  = this.onFrameChange;
  }


  function onComplete() : Void
  {
    setAnimation(_idleFrameName);
  }

  function onLoop() : Void return;

  function onFrameChange() : Void
  {
    _dirty = true;
  }


  var _idleFrameName :String = "";

  var _dirty :Bool = false;

  var _current :Animation;

  var _target :Point;


  inline function get_bitmapData() :BitmapData return _current.bitmapData;
  
  inline function get_frameRect() :Rectangle return _current.rect;
  
  inline function get_frameOrigin() :Point return _current.origin;

}
