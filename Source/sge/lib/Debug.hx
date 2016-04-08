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

// DEBUG
// 
// Simple debug data display area
// 
// - Default fps and mem usage tracking
// - Easy to add and update labels 
// 
class Debug extends Sprite 
{
  var TEXT_COLOR  :UInt = 0xffffff;
  var BG_COLOR    :UInt = 0x55333333;
  var LAYOUT_PADDING :UInt = 20;
  var LINE_HEIGHT :UInt = 40;

  var fps_width   :UInt = 100;
  var mem_width   :UInt = 300;

  var background :Bitmap;
  var fps :FPS;
  var mem :MemUsage;
  var textFormat :TextFormat;
  var fields :Map<String, TextField>;
  var fieldCount :Int = 0;
  var layout_x :Float;
  var layout_y :Float;
  var layout_width :Float;
  var layout_height :Float;

  public function new()
  {
    super();

    var sw = Game.root.stage.stageWidth;
    var sh = Game.root.stage.stageHeight;

    fps = new FPS();
    mem = new MemUsage();
    fields = new Map();

    textFormat = new TextFormat('Arial', 32, TEXT_COLOR);

    fps.defaultTextFormat = textFormat;
    fps.autoSize = TextFieldAutoSize.RIGHT;
    fps.width = fps_width;
    mem.defaultTextFormat = textFormat;
    mem.autoSize = TextFieldAutoSize.RIGHT;
    mem.width = mem_width;
    
    layout_width = sw - (LAYOUT_PADDING * 2);
    layout_height = (sh * 0.33) - LAYOUT_PADDING;
    layout_x = LAYOUT_PADDING;
    layout_y = sh - layout_height - LAYOUT_PADDING;

    this.x = layout_x;
    this.y = layout_y;
    
    var bitmapData = new BitmapData(Math.floor(layout_width), Math.floor(layout_height), true, BG_COLOR);
    background = new Bitmap(bitmapData);

    fps.x = layout_width - LAYOUT_PADDING - fps_width;
    fps.y = LAYOUT_PADDING;
    mem.x = layout_width - LAYOUT_PADDING - mem_width;
    mem.y = LAYOUT_PADDING + LINE_HEIGHT;

    addChild(background);
    addChild(fps);
    addChild(mem);
    
    addEventListener (Event.ENTER_FRAME, this_onEnterFrame);

    visible = false;
  }


  public function setLabel(label :String, value :String) :Void
  {
    tempText = !fields.exists(label) ? createLabel(label) :fields.get(label);
    if (tempText.text == '$label: $value') return;
    tempText.text = '$label: $value';
  }
  var tempText :TextField;


  inline function createLabel(name :String) :TextField
  {
    var labelYPosition = (fieldCount * LINE_HEIGHT + (fieldCount + 1) * LAYOUT_PADDING);
    if (labelYPosition > layout_height - (fieldCount * LINE_HEIGHT + LAYOUT_PADDING))
      throw new openfl.errors.Error('Maximum Labels Reached - can\'t create label $name : currentLabelCount: $fieldCount');

    textField = new TextField();
    textField.defaultTextFormat = textFormat;
    textField.autoSize = TextFieldAutoSize.LEFT;
    textField.selectable = false;
    textField.mouseEnabled = false;
    textField.x = LAYOUT_PADDING;
    textField.y = labelYPosition;
    textField.width = layout_width - LAYOUT_PADDING * 2;

    fieldCount++;
    fields.set(name, textField);
    addChild(textField);

    return textField;
  }
  var textField :TextField;

  // 
  // Maybe this should be updated by the Game Class instead?
  // 
  @:noCompletion private function this_onEnterFrame (event:Event) :Void 
  {
    if (Game.inputManager.keyboard.isPressed(Keyboard.BACKQUOTE)) { visible = !visible; }
  }

}