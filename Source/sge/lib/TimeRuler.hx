package sge.lib;

import openfl.Lib;
import openfl.display.Shape;
import openfl.geom.Point;
import sge.Game;

// 
// Draw the length of time a given "marker" is taking across the whole frame length
// 
class TimeRuler
{

  // var MAX_BARS :Int = 8;
  // var MAX_SAMPLES :Int = 256;
  // var MAX_NEST_CALL :Int = 32;
  // var MAX_SAMPLE_FRAMES :Int = 4;

  var BAR_HEIGHT :Int = 16;
  // var BAR_PADDING :Int = 2;
  // var AUTO_ADJUST_DELAY :Int = 30;


  var position :Point;
  var width :Float;
  var interval :Int;
  var startTime :Float;

  var markers :Array<Marker>;
  var markerNameMap :Map<String, Int>;
  var mid :Int;
  var shape :Shape;

  public function new()
  {
    markers = new Array();
    markerNameMap = new Map();
    shape = new Shape();
    interval = Math.floor(1000/60); // 30 fps?
  }


  public function init() :Void
  {
    trace('TimeRuler init');

    var stageWidth = Game.root.stage.stageWidth;
    var stageHeight = Game.root.stage.stageHeight;

    width = stageWidth - 40;
    position = new Point();
    position.x = 20;
    position.y = stageHeight - 20 - BAR_HEIGHT;

    Game.addChild_debug(shape);
  }


  public function start() :Void  startTime = Lib.getTimer();


  public function end() :Void  drawMarkers();


  public function startMarker(name :String, color :UInt = 0x2257ad) :Void
  {
    if (!markerNameMap.exists(name)) makeMarker(name, color);

    mid = markerNameMap.get(name);
    markers[mid].startTime = Lib.getTimer();
  }


  public function endMarker(name :String) :Void
  {
    if (!markerNameMap.exists(name)) throw new openfl.errors.Error('Maker named:$name does\'t exist');

    mid = markerNameMap.get(name);
    markers[mid].endTime = Lib.getTimer();
  }


  function makeMarker(name :String, color :UInt ) :Void
  {
    mid = markers.length;

    var marker :Marker = {
      id: mid,
      startTime: 0.0,
      endTime: 0.0,
      color: color
    };

    markers.push(marker);
    markerNameMap.set(name, mid);
  }

  function drawMarkers() :Void
  {
    var g = shape.graphics;
    var n = interval;
    var dl :Float = 0;
    var d :Float = Lib.getTimer() - startTime;
    var l :Float = 0;
    var w :Float = (d / n) * width;

    g.clear();
    g.lineStyle(1, 0x333333);
    g.drawRect(position.x, position.y, width, BAR_HEIGHT);
    g.lineStyle(0, 0);
    
    for(m in markers)
    {
      g.beginFill(m.color);
      
      dl = m.startTime - startTime;
      d = m.endTime - m.startTime;
      l = (dl / n) * width;
      w = (d / n) * width;

      g.drawRect(position.x + l, position.y, w, BAR_HEIGHT);
      g.endFill();
    }
  }

}

typedef Marker = {

  var id :UInt;
  var startTime :Float;
  var endTime :Float;
  var color :UInt;

}
