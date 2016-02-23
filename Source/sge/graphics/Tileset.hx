package sge.graphics;

// 
// imports
// eg. import haxe.Log;
// 


class Tileset extends Spritesheet {

  // public var name :String;
  // var data : BitmapData;
  // var frames : Array<FrameData>;
  // var _zero : Point;

  var tileWidth :Int;
  var tileHeight :Int;
  var columns :Int;
  var rows :Int;

  public function new( source :Dynamic, ?name :String ) 
  { 
    
    super( source, name );

  }

  public function init(  ) :Void
  {
    this.tileWidth = tileWidth;
    this.tileHeight = tileHeight;
    this.columns = columns;
    this.rows = rows;
    initFrames();
  }

  inline function initFrames() :Void
  {

    var _frameData :FrameData;
    var _rect :Rectangle;
    var _center :Point;

    _rect  = new Rectangle(0, 0, tileWidth, tileHeight);
    _center = new Point(tileWidth * 0.5, tileHeight * 0.5);

    for (r in 0...rows)
    {
      for (c in 0...columns)
      {
        _rect = _rect.clone();
        _center = _center.clone();

        _rect.x = tileWidth * c;
        _rect.y = tileHeight * r;

        _frameData = {
          rect: _rect,
          center: _center,
        };

        addFrameData(_frameData);
      }
    }

  }

}

