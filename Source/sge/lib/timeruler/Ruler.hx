package sge.lib.timeruler;

import openfl.events.Event;
import openfl.display.Graphics;
import openfl.display.Shape;
import openfl.geom.Point;
import sge.Game;

// 
// Draw the length of time a given "marker" is taking across the whole frame length
// 
class Ruler extends Shape
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
  var sampleStartTime :Float;
  var prevSampleStartTime :Float;
  var sampleSetCount :Int = 30;
  var sampleSetDelta :Float = 0.0;
  var delatOverSampleSet :Float = 0.0;
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

    frameSpan = (1 / 30) * 1000;
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
    if (samples >= sampleSetCount)
    {
      prevSampleStartTime = sampleStartTime;
      sampleStartTime = now;
      sampleSetDelta = sampleStartTime - prevSampleStartTime;

      delatOverSampleSet = delta / sampleSetCount;

      samples = 0;
      delta = 0;
      writeLog();
    }

    drawMarkers();
  }

  inline function get_now() :Float
  {
    return haxe.Timer.stamp() * 1000;
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


  function makeMarker(name :String, color :UInt) :Void
  {
    mid = markers.length;

    var marker:Marker = {
      id: mid,
      startTime: 0.0,
      endTime: 0.0,
      elapsedTime: 0.0,
      color: color,
      min: 0,
      max: 0,
      avg: 0,
      minOffset: 0,
      maxOffset: 0,
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
        m.max = d;
        m.avg = d;
        m.minOffset = dl;
        m.maxOffset = dl;
        m.offset = dl;
        m.samples++;
      }
      else
      {

        m.min = Math.min(m.min, d);
        m.max = Math.max(m.max, d);
        m.avg += d;
        m.avg *= 0.5;

        m.minOffset = Math.min(m.minOffset, dl);
        m.maxOffset = Math.max(m.maxOffset, dl);
        m.offset += dl;
        m.offset *= 0.5;
        m.samples++;
      }

      if (m.samples > MAX_SAMPLES)
      {
        m.samples = 1;
        m.avg = (m.min + m.max) * 0.5;
        m.offset = (m.minOffset + m.maxOffset) * 0.5;
      }
    }
  }
  var d :Float;
  var dl :Float;

  function writeLog() :Void
  {
    n = max_width / frameSpan; // the width of the container over the length of a frame
    l = 0;
    w = sampleSetDelta * n;

    for (m in markers)
    {
      trace('[${m.id}] start: ${m.startTime} frame: ${frameStartTime} offset: ${m.startTime - frameStartTime}ms avg: ${m.avg}ms');
    }
  }
  var t :Float;


  function drawMarkers() :Void
  {
    n = max_width / frameSpan;
    l = 0;
    w = Math.max(delatOverSampleSet * n, 1);

    g.beginFill(0x00ff00);
    g.drawRect(position.x, position.y, w, 3);
    g.endFill();
    

    n = max_width / delatOverSampleSet;

    for(m in markers)
    {
      g.beginFill(m.color);

      l = m.offset * n;
      w = Math.max( m.avg * n, 1);

      g.drawRect(position.x - l, position.y, w, BAR_HEIGHT);

      g.endFill();
    }
  }

  var g :Graphics;
  var l :Float;
  var w :Float;
  var n :Float;
  var temp :Float;

}

