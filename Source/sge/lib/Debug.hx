package sge.lib;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import openfl.ui.Keyboard;


class Debug extends Sprite 
{

  var background :Bitmap;
  var text :TextField;
  var fps :FPS;
  var mem :MemUsage;
  var textFormat :TextFormat;
  var padding :Int = 20;

  var layout_x :Float;
  var layout_y :Float;
  var layout_width :Float;
  var layout_height :Float;

  var fps_width   :UInt = 100;
  var mem_width   :UInt = 300;
  var line_height :UInt = 40;
  var text_color  :UInt = 0xffffffff;


  public function new()
  {
    super();

    var sw = Game.root.stage.stageWidth;
    var sh = Game.root.stage.stageHeight;

    fps = new FPS();
    mem = new MemUsage();
    text = new TextField();

    textFormat = new TextFormat('Arial', 32, text_color);

    fps.defaultTextFormat = textFormat;
    fps.autoSize = TextFieldAutoSize.RIGHT;
    fps.width = fps_width;
    mem.defaultTextFormat = textFormat;
    mem.autoSize = TextFieldAutoSize.RIGHT;
    mem.width = mem_width;
    text.defaultTextFormat = textFormat;
    text.selectable = false;
    text.mouseEnabled = false;
    
    layout_width = sw - (padding * 2);
    layout_height = (sh * 0.5) - padding;
    layout_x = padding;
    layout_y = sh - layout_height - padding;

    this.x = layout_x;
    this.y = layout_y;
    
    var bitmapData = new BitmapData(Math.floor(layout_width), Math.floor(layout_height), true, 0x33999999);
    background = new Bitmap(bitmapData);

    fps.x = layout_width - padding - fps_width;
    fps.y = padding;
    mem.x = layout_width - padding - mem_width;
    mem.y = padding + line_height;
    text.x = padding;
    text.y = padding + line_height * 2;

    addChild(background);
    addChild(text);
    addChild(fps);
    addChild(mem);
    
    addEventListener (Event.ENTER_FRAME, this_onEnterFrame);

    visible = false;
  }



  @:noCompletion private function this_onEnterFrame (event:Event) :Void 
  {
    if (Game.inputManager.keyboard.isPressed(Keyboard.BACKQUOTE)) { visible = !visible; }
  }

}