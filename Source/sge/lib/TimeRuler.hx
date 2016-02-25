package sge.lib;

import openfl.events.Event;
import openfl.display.Graphics;
import openfl.display.Shape;
import openfl.geom.Point;
import sge.Game;

// 
// Draw the length of time a given "marker" is taking across the whole frame length
// 
class TimeRuler extends Shape
{

  var ALMOST_ZERO :Float = 0.000001;
  var MAX_SAMPLES :Int = 256;
  var BAR_HEIGHT :Int = 16;
  
  var position :Point;
  var max_width :Float;
  var frameSpan :Float;
  var frameStartTime :Float = 0;
  var prevStarTime :Float = 0;
  var delta :Float = 0;
  var samples :Int = 0;
  var markers :Array<Marker>;
  var markerNameMap :Map<String, Int>;
  var mid :Int;
  var now (get, never) :Float;

  public function new()
  {
    super();

    var sw = Game.root.stage.stageWidth;
    var sh = Game.root.stage.stageHeight;

    markers = new Array();
    markerNameMap = new Map();

    frameSpan = (1 / 60) * 1000;
    max_width = sw - 40;
    position = new Point();
    position.x = 20;
    position.y = sh - 20 - BAR_HEIGHT;

    g = graphics;

    addEventListener (Event.ENTER_FRAME, this_onEnterFrame);
  }


  @:noCompletion private function this_onEnterFrame (event:Event) :Void 
  {
    g.clear();
    g.lineStyle(1, 0x333333);
    g.beginFill(0xffffff);
    g.drawRect(position.x, position.y, max_width, BAR_HEIGHT);
    g.endFill();

    prevStarTime = frameStartTime;
    frameStartTime = now;
    delta += frameStartTime - prevStarTime;
    
    sampleMarkers();
    samples++;
    if (samples > 3)
    {
      delta *= (1/3);
      drawMarkers();
      samples = 0;
      delta = 0;
    }

  }

  inline function get_now() :Float
  {
#if (sys)
    return Sys.cpuTime();
#elseif (flash || nme || openfl)
    return flash.Lib.getTimer() / 1000;
#elseif lime
    return lime.system.System.getTimer() / 1000;
#else
    return haxe.Timer.stamp();
#end
  }


  public function startMarker(name :String, color :UInt = 0x2257ad) :Void
  {
    if (!markerNameMap.exists(name)) makeMarker(name, color);

    mid = markerNameMap.get(name);
    markers[mid].startTime = now;
  }


  public function endMarker(name :String) :Void
  {
    if (!markerNameMap.exists(name)) throw new openfl.errors.Error('Maker named:$name does\'t exist');

    mid = markerNameMap.get(name);
    markers[mid].endTime = now;
  }


  function makeMarker(name :String, color :UInt ) :Void
  {
    mid = markers.length;

    var marker :Marker = {
      id: mid,
      startTime: 0.0,
      endTime: 0.0,
      elapsedTime: 0.0,
      color: color,
      min: 0,
      max: 0,
      avg: 0,
      offset: 0,
      samples: 0,
    };

    markers.push(marker);
    markerNameMap.set(name, mid);
  }


  function sampleMarkers() :Void
  {
    for(m in markers)
    {
      dl = m.startTime - frameStartTime;
      m.elapsedTime = d = m.endTime - m.startTime;

      if (m.samples == 0)
      {
        m.min = d;
        m.min = d;
        m.avg = d;
        m.offset = dl;
        m.samples++;
      }
      else
      {

        m.min = Math.min(m.min, d);
        m.min = Math.max(m.max, d);
        m.avg += d;
        m.avg *= 0.5;
        m.offset += dl;
        m.offset *= 0.5;
        m.samples++;
      }

      if (m.samples > MAX_SAMPLES)
      {
        m.samples = 1;
        m.avg = (m.min + m.max) * 0.5;
      }
    }
  }
  var d :Float;
  var dl :Float;


  function drawMarkers() :Void
  {
    l = 0;
    w = 0;
    n = max_width / frameSpan;
    
    for(m in markers)
    {
      g.beginFill(m.color);

      l = (m.offset > ALMOST_ZERO ? m.offset : ALMOST_ZERO) * n;
      w = Math.max( (m.avg > ALMOST_ZERO ? m.avg : m.max > ALMOST_ZERO ? m.max : ALMOST_ZERO) * n, 1);

      g.drawRect(position.x + l, position.y, w, BAR_HEIGHT);

      g.endFill();
    }
  }

  var g :Graphics;
  var l :Float;
  var w :Float;
  var n :Float;
  var temp :Float;

}

typedef Marker = {

  var id :UInt;
  var color :UInt;

  var startTime :Float;
  var endTime :Float;
  var elapsedTime :Float;

  var min :Float;
  var max :Float;
  var avg :Float;

  var offset :Float;

  var samples :Int;

}
