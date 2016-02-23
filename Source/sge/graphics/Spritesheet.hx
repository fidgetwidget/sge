package sge.graphics;


import haxe.Json;


typedef ImportFrames = {

  var frames :Array<ImportFrame>;

}

typedef ImportFrame = {

  var name :String;
  var x :Int;
  var y :Int;
  var width :Int;
  var height :Int;
  var cx :Int;
  var cy :Int;

}



class Spritesheet {


  public var name :String;

  var sourceImage : BitmapData;
  var frames : Array<FrameData>;
  var zero : Point;


  public function new( source :Dynamic, ?name :String ) 
  { 
    
    this.frames = new Array();

    this.zero = new Point();

    this.name = name == null ? Std.string(source) : name;

    this.sourceImage = Assets.getBitmapData(source);

  }

  // 
  // 
  // 
  public function loadFrames( jsonString :String ) :Void
  {

    var index :Int;

    var importFrames :ImportFrames = Json.parse(jsonString);

    for ( frame in importFrames.frames ) {

      index = addFrame( frame.x, frame.y, frame.width, frame.height, frame.cx, frame.cy );

      if (frame.name) {

        this.frames[index].name = frame.name;

      }

    }

  }

  // 
  // 
  // 
  public inline function addFrame( x :Int, y :Int, width :Int, height :Int, cx :Float, cy :Float ) :Int
  {
    
    var rect :Rectagle = new Rectagle(x, y, width, height);

    var origin :Point = new Point(cx, cy);

    return addFrameRect( rect, origin );

  }

  // 
  // 
  // 
  public inline function addFrameRect( rect :Rectagle, origin :Point ) :Int
  {

    var frameData :FrameData = 
    {
      rect: rect,
      origin: origin
    };

    return addFrameData( frameData );

  }

  // 
  // 
  // 
  public inline function addFrameData( frameData :FrameData ) :Int
  {

    frames.push(frameData);

    return frames.count - 1;

  }

  // 
  // 
  // 
  public inline function drawFrameTo( bitmapData :BitmapData, target :Point = zero, frameIndex :Int ) :Void
  {
    
    bitmapData.copyPixels(this.sourceImage, this.frames[index].rect, target);

  }


}

