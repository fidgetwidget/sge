package sge.input;

import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;


class KeyboardInput
{

  public var keys :Array<InputState>;

  public function new()
  {

    initKeys();

    var stage = Game.root.stage;

    stage.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
    stage.addEventListener( KeyboardEvent.KEY_UP,   onKeyUp );

  }

  public function update() :Void
  {

    updateKeys();

  }


  // 
  // Keyboard Input State Checks
  // 
  public function isDown( key:Int ) :Bool
  {
    return keys[key].current > 0;
  }

  public function isPressed( key:Int ) :Bool
  {
    return keys[key].current == 2;
  }

  public function isReleased( key:Int ) :Bool
  {
    return keys[key].current == -1;
  }



  private function initKeys() :Void
  {

    keys = new Array<InputState>();

    // Arrow Keys
    addKey(Keyboard.LEFT);                // 37
    addKey(Keyboard.UP);                  // 38
    addKey(Keyboard.RIGHT);               // 39
    addKey(Keyboard.DOWN);                // 40

    // Alphabet Keys
    addKey(Keyboard.A);                   // 65
    addKey(Keyboard.B);                   // 66
    addKey(Keyboard.C);                   // 67
    addKey(Keyboard.D);                   // 68
    addKey(Keyboard.E);                   // 69
    addKey(Keyboard.F);                   // 70
    addKey(Keyboard.G);                   // 71
    addKey(Keyboard.H);                   // 72
    addKey(Keyboard.I);                   // 73
    addKey(Keyboard.J);                   // 74
    addKey(Keyboard.K);                   // 75
    addKey(Keyboard.L);                   // 76
    addKey(Keyboard.M);                   // 77
    addKey(Keyboard.N);                   // 78
    addKey(Keyboard.O);                   // 79
    addKey(Keyboard.P);                   // 80
    addKey(Keyboard.Q);                   // 81
    addKey(Keyboard.R);                   // 82
    addKey(Keyboard.S);                   // 83
    addKey(Keyboard.T);                   // 84
    addKey(Keyboard.U);                   // 85
    addKey(Keyboard.V);                   // 86
    addKey(Keyboard.W);                   // 87
    addKey(Keyboard.X);                   // 88
    addKey(Keyboard.Y);                   // 89
    addKey(Keyboard.Z);                   // 90
    
    // Common Keys
    addKey(Keyboard.ENTER);               // 13
    addKey(Keyboard.COMMAND);             // 15
    addKey(Keyboard.CONTROL);             // 17
    addKey(Keyboard.ALTERNATE);           // 18
    addKey(Keyboard.SPACE);               // 32
    addKey(Keyboard.SHIFT);               // 16 
    addKey(Keyboard.BACKSPACE);           // 8
    addKey(Keyboard.CAPS_LOCK);           // 20  
    addKey(Keyboard.DELETE);              // 46
    addKey(Keyboard.END);                 // 35
    addKey(Keyboard.ESCAPE);              // 27 
    addKey(Keyboard.HOME);                // 36
    addKey(Keyboard.INSERT);              // 45
    addKey(Keyboard.TAB);                 // 9
    addKey(Keyboard.PAGE_DOWN);           // 34
    addKey(Keyboard.PAGE_UP);             // 33  
    addKey(Keyboard.LEFTBRACKET);         // 219
    addKey(Keyboard.RIGHTBRACKET);        // 221
    addKey(Keyboard.BACKQUOTE);           // 192
    addKey(Keyboard.EQUAL);               // 187
    addKey(Keyboard.MINUS);               // 189
    addKey(Keyboard.BACKSLASH);           // 220
    addKey(Keyboard.COMMA);               // 188
    addKey(Keyboard.SEMICOLON);           // 186
    addKey(Keyboard.PERIOD);              // 190
    addKey(Keyboard.QUOTE);               // 222
    addKey(Keyboard.SLASH);               // 191  

  }

  private function addKey( key :UInt ) :Void
  {
    keys[key] = { current:0, last:0 };
  }

  private function updateKeys() :Void
  {
    var keyState :InputState;

    for (i in 0...keys.length) {
      keyState = keys[i];
      if (keyState == null) continue;
      
      if ( keyState.last == -1 && keyState.current == -1 ) 
      {
        keyState.current = 0;
      }
      else if ( keyState.last == 2 && keyState.current == 2 ) 
      {
        keyState.current = 1;
      }
      
      keyState.last = keyState.current;
    }
  }


  private function onKeyDown( e :KeyboardEvent ) :Void
  {
    var keyCode = e.keyCode;

    if (Game.debugMode) openfl.Lib.trace("KeyboardInput:onKeyDown["+keyCode+"]");

    var _o = keys[keyCode];
    if ( _o == null ) return;
    
    if ( _o.current > 0 ) {
      _o.current = 1; // is down
    }
    else {
      _o.current = 2; // just pressed
    }
  }

  private function onKeyUp( e :KeyboardEvent ) :Void
  {
    var keyCode = e.keyCode;

    if (Game.debugMode) openfl.Lib.trace("KeyboardInput:onKeyUp["+keyCode+"]");

    var _o = keys[keyCode];
    if ( _o == null ) return;
    
    if ( _o.current > 0 ) {
      _o.current = -1; // just released
    }
    else {
      _o.current = 0; // is up
    }
  }

}
