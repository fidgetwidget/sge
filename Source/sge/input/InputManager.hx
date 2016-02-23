package sge.input;

import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;


class InputManager
{

  public var keyboard :KeyboardInput;
  public var mouse :MouseInput;

  public function new()
  {

    keyboard = new KeyboardInput();
    mouse = new MouseInput();

  }

  public function update() :Void
  {

    keyboard.update();
    mouse.update();

  }

}
