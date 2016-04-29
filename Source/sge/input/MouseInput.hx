package sge.input;

import openfl.events.MouseEvent;


class MouseInput
{

  public static var LEFT_MOUSE_BUTTON : Int = 0;
  public static var MIDDLE_MOUSE_BUTTON : Int = 2;
  public static var RIGHT_MOUSE_BUTTON : Int = 1;

  public var buttons :Array<InputState>;

  public var mouseX :Float;
  public var mouseY :Float;
  public var mouseWheel :InputState;
  public var mouseWheelDelta (get, never) :Float;

  public function new()
  {

    initButtons();
    mouseWheel = { current:0, last:0 };

    var stage = Game.root.stage;

    stage.addEventListener( MouseEvent.MOUSE_DOWN,  onMouseDown );
    stage.addEventListener( MouseEvent.MOUSE_UP,    onMouseUp );
    stage.addEventListener( MouseEvent.MOUSE_WHEEL, onMouseWheelChange );
    stage.addEventListener( MouseEvent.MOUSE_MOVE,   onMouseMove );

#if (!js)
    stage.addEventListener( MouseEvent.MIDDLE_MOUSE_DOWN, onMiddleMouseDown );
    stage.addEventListener( MouseEvent.MIDDLE_MOUSE_UP,   onMiddleMouseUp );
    stage.addEventListener( MouseEvent.RIGHT_MOUSE_DOWN,  onRightMouseDown );
    stage.addEventListener( MouseEvent.RIGHT_MOUSE_UP,    onRightMouseUp );
#end
  }

  public function update() :Void
  {

    updateButtons();

    mouseWheel.last = mouseWheel.current;
    mouseWheel.current = 0;

  }

  private function updateButtons() :Void
  {
    var _o;

    for (i in 0...buttons.length) {
      _o = buttons[i];
      if (_o == null) continue;
      
      if ( _o.last == -1 && _o.current == -1 ) 
      {
        _o.current = 0;
      }
      else if ( _o.last == 2 && _o.current == 2 ) 
      {
        _o.current = 1;
      }
      
      _o.last = _o.current;
    }

  }


  // 
  // Keyboard Input State Checks
  // 
  public function isDown( mouseButton :Int = 0 ) :Bool
  {
    return buttons[mouseButton].current > 0;
  }

  public function isPressed( mouseButton :Int = 0 ) :Bool
  {
    return buttons[mouseButton].current == 2;
  }

  public function isReleased( mouseButton :Int = 0 ) :Bool
  {
    return buttons[mouseButton].current == -1;
  }



  private function initButtons() :Void
  {

    buttons = new Array<InputState>();
    buttons[LEFT_MOUSE_BUTTON]    = { current:0, last:0 };

#if !js
    buttons[MIDDLE_MOUSE_BUTTON]  = { current:0, last:0 };
    buttons[RIGHT_MOUSE_BUTTON]   = { current:0, last:0 };
#end
  }


  private function onMouseDown( e :MouseEvent ) :Void
  {
    if (Game.debugMode) openfl.Lib.trace("MouseInput:onMouseDown");

    var _o = buttons[LEFT_MOUSE_BUTTON];
    if ( _o.current > 0 ) {
      _o.current = 1; // is down
    }
    else {
      _o.current = 2; // just pressed
    }
  }

  private function onMouseUp( e :MouseEvent ) :Void
  {
    if (Game.debugMode) openfl.Lib.trace("MouseInput:onMouseUp");

    var _o = buttons[LEFT_MOUSE_BUTTON];
    if ( _o.current > 0 ) {
      _o.current = -1; // just released
    }
    else {
      _o.current = 0; // is up
    }
  }


  private function onMouseWheelChange( e :MouseEvent ) :Void
  {
    var delta = e.delta;
    if (Game.debugMode) openfl.Lib.trace("MouseInput:onMouseWheelChange ["+delta+"]");

    mouseWheel.last = mouseWheel.current;
    mouseWheel.current = delta;
  }

  private function onMouseMove( e :MouseEvent ) :Void
  {
    mouseX = e.stageX;
    mouseY = e.stageY;
  }


  private function onMiddleMouseDown( e :MouseEvent ) :Void
  {
    if (Game.debugMode) openfl.Lib.trace("MouseInput:onMiddleMouseDown");

    var _o = buttons[MIDDLE_MOUSE_BUTTON];
    if ( _o.current > 0 ) {
      _o.current = 1; // is down
    }
    else {
      _o.current = 2; // just pressed
    }
  }

  private function onMiddleMouseUp( e :MouseEvent ) :Void
  {
    if (Game.debugMode) openfl.Lib.trace("MouseInput:onMiddleMouseUp");

    var _o = buttons[MIDDLE_MOUSE_BUTTON];
    if ( _o.current > 0 ) {
      _o.current = -1; // just released
    }
    else {
      _o.current = 0; // is up
    }
  }

  private function onRightMouseDown( e :MouseEvent ) :Void
  {
    if (Game.debugMode) openfl.Lib.trace("MouseInput:onRightMouseDown");

    var _o = buttons[RIGHT_MOUSE_BUTTON];
    if ( _o.current > 0 ) {
      _o.current = 1; // is down
    }
    else {
      _o.current = 2; // just pressed
    }
  }

  private function onRightMouseUp( e :MouseEvent ) :Void
  {
    if (Game.debugMode) openfl.Lib.trace("MouseInput:onRightMouseUp");

    var _o = buttons[RIGHT_MOUSE_BUTTON];
    if ( _o.current > 0 ) {
      _o.current = -1; // just released
    }
    else {
      _o.current = 0; // is up
    }
  }


  private function get_mouseWheelDelta() :Float return mouseWheel.current;

}
