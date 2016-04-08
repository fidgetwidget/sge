package sge.lib;

import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.system.System;

class MemUsage extends TextField 
{

  public var peak (default, null) :Float;
  public var currentUsage (default, null) :Float;

  public function new (x:Float = 10, y:Float = 10, color:Int = 0x000000)
  {
    super ();
    
    this.x = x;
    this.y = y;
    
    currentUsage = peak = 0;
    selectable = false;
    mouseEnabled = false;
    defaultTextFormat = new TextFormat ("_sans", 12, color);
    text = '';
    
    addEventListener (Event.ENTER_FRAME, this_onEnterFrame);
  }


  @:noCompletion private function this_onEnterFrame (event:Event) :Void 
  {
    
    currentUsage = Math.round(System.totalMemory / 1024 / 1024 * 100) /100;

    if (currentUsage > peak) 
      peak = currentUsage;
    
    text = 'MEM: ${currentUsage}MB (${peak})MB';

  }

}