package sge.graphics;

import openfl.Assets;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.display.BitmapData;

class SpriteSheet {


  private static var uid : Int = 0;
  private static function getNextId() : Int
  {
    return SpriteSheet.uid++;
  }


  public var name :String;

  public var id :Int;

  public var frames :Array<FrameData>;

  public var sourceImage (default, null) : BitmapData;

  public var frameNames (get, never) : Iterator<String>;

  var zero : Point;

  var framesMap :Map<String, Int>;


  public function new( source :Dynamic, ?name :String ) 
  { 
    id = SpriteSheet.getNextId();
    frames = new Array();
    zero = new Point();
    framesMap = new Map();
    sourceImage = Assets.getBitmapData(source);

    this.name = name == null ? Std.string(source) : name;
  }

  // 
  // 
  // 
  public inline function setFrameName( frameIndex :Int, name :String ) :Void
  {
    frames[frameIndex].name = name;
    framesMap.set(name, frameIndex);
  }

  // 
  // Get the FrameData from the Frame Name (null if no match)
  // 
  public inline function getFrame( name :String ) :FrameData
  {
    if (! framesMap.exists(name) ) return null;
    
    var frameIndex = framesMap.get(name);

    if (frames[frameIndex].bitmapData == null) copyBitmapDataToFrame(frameIndex);

    return frames[frameIndex];
  }


  // 
  // Add a frame to the SpriteSheet
  // @params x, y, width, height: the frameData rectangle
  // @params cx, cy: the frameData origin
  // 
  public inline function addFrame( x :Int, y :Int, width :Int, height :Int, cx :Float = 0, cy :Float = 0 ) :Int
  {
    var rect :Rectangle = new Rectangle(x, y, width, height);
    var origin :Point = new Point(cx, cy);

    return addFrameRect( rect, origin );
  }

  // 
  // Add a frame to the SpriteSheet
  // @param rect: the frameData rectangle
  // @param origin: the frameData origin
  // 
  public inline function addFrameRect( rect :Rectangle, origin :Point ) :Int
  {
    var frameData :FrameData = FrameDataPool.instance.get();

    frameData.rect = rect;
    frameData.origin = origin;

    return addFrameData( frameData );
  }

  // 
  // Add a frame to the SpriteSheet
  // @param frameData: the frameData to add
  // @option initBitmapData: whether or not to initialize the bitmapData to the frameData
  // 
  public inline function addFrameData( frameData :FrameData, initBitmapData :Bool = false ) :Int
  {
    frames.push(frameData);
    frameData.source = sourceImage;

    if (initBitmapData) copyBitmapDataToFrame(frames.length - 1);

    return frames.length - 1;
  }

  // 
  // Draw the given frame (via index) to the target bitmapData 
  // @option target: where on the targetBitmap to draw the frame
  // 
  public inline function drawFrameTo( frameIndex :Int, bitmapData :BitmapData, target :Point = null ) :Void
  {
    if (target == null) target = zero;

    bitmapData.copyPixels(sourceImage, frames[frameIndex].rect, target);
  }


  // 
  // Get an Array of BitmapData from the frames
  // 
  public inline function toArray() :Array<BitmapData>
  {
    var data :Array<BitmapData> = new Array();

    for (i in 0...frames.length)
    {
      var frame = frames[i];
      var bitmapData = new BitmapData(Math.floor(frame.rect.width), Math.floor(frame.rect.height), true, 0);

      bitmapData.copyPixels(this.sourceImage, frame.rect, zero);
      data.push(bitmapData);
    }

    return data;
  }

  // 
  // Get TileSetData of the SpriteSheet
  // 
  public inline function toTileSetData() :TileSetData
  {
    var data :TileSetData = {
      name:     this.name, 
      id:       this.id,
      source:   this.sourceImage,
      tileData: null,
      tileMap:  null,
      variantCount: null
    };

    data.tileData = toArray();  
    
    data.tileMap = new Map();
    for (name in framesMap.keys())
    {
      data.tileMap.set(name, framesMap.get(name));
    }

    return data;
  }


  // 
  // Setup the FrameData with it's BitmapData
  // 
  inline function copyBitmapDataToFrame( frameIndex :Int ) :Void
  {
    var frameData = frames[frameIndex];
    var bitmapData = new BitmapData(Math.floor(frameData.rect.width), Math.floor(frameData.rect.height), true, 0);

    drawFrameTo(frameIndex, bitmapData);
    frameData.bitmapData = bitmapData;
  }


  inline function get_frameNames() :Iterator<String> return framesMap.keys();


}

