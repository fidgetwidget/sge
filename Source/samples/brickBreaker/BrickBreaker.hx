package samples.brickBreaker;

import openfl.display.Graphics;
import openfl.display.Shape;
import openfl.ui.Keyboard;
import sge.Lib;
import sge.Game;
import sge.scene.Scene;
import sge.geom.Motion;
import sge.geom.base.Circle;
import sge.geom.base.Rectangle;
import sge.collision.Collision;


class BrickBreaker extends Scene
{

  var ball :Ball;
  var paddle :Paddle;
  var board :GameBoard;

  
  public function new() 
  { 

    super();

    ball = new Ball();
    paddle = new Paddle();
    board = new GameBoard();
    collision = new Collision();

  }

  override private function onReady() :Void
  {

    init();

    _sprite.addChild(ball.shape);

    _sprite.addChild(paddle.shape);

    _sprite.addChild(board.shape);

    reset();

  }


  override public function update() :Void
  {

    handleInput();

    if (isPaused) return;

    ball.update();
    paddle.update();
    
    // check_collisions();

    // board.update();

  }


  override public function render() :Void
  {

    // var g = draw.graphics;

    // g.clear();

    // render_bounds(g);

    // render_bricks(g);

    // render_ball(g);

    // render_paddle(g);

  }


  private function init() :Void
  {

    board.init();

    ball.board_bounds = board.bounds;
    paddle.board_bounds = board.bounds;

  }


  private function reset() :Void
  {

    ball.reset();
    paddle.reset();

    board.resetBricks();

  }


  // 
  // Update Helpers
  // 

  override private function handleInput() :Void
  {

    var input = Game.inputManager;

    if ( input.keyboard.isDown(Keyboard.LEFT) ) {
      
      paddle.motion.velocityX -= 1;

    } else if ( input.keyboard.isDown(Keyboard.RIGHT) ) {
      
      paddle.motion.velocityX += 1;

    }

    if  ( input.keyboard.isDown(Keyboard.R) ) {
      
      reset();

    }

  }


  private inline function update_collision() :Void
  {

    collision.reset();
    var paddleBounds = paddle.getBounds();

    // paddle with board
    if ( board.collision_paddle( paddleBounds, collision ) != null )
    {

      paddle.x += collision.px;
      paddle.motion.velocityX *= -0.8;

    }

    // ball with board
    if ( board.collision_ball(ball.x, ball.y, ball.radius, collision) != null )
    {
      
      if (collision.px != 0)
      {
        ball.motion.velocityX *= -0.8;
        ball.motion.accelerationX *= -1;
      }

      if (collision.py != 0)
      {
        ball.motion.velocityY *= -0.8;
        ball.motion.accelerationY *= -1;
      }    
      
    }

    // ball with paddle
    if ( paddleBounds.collision_circle(ball.x, ball.y, ball.radius, collision) )
    {

      ball.y = paddle.y - ball.radius;
      ball.motion.velocityY *= -1;
      ball.motion.accelerationY *= -1;
      ball.ballControleTimer = 5;

    }

  }


  // 
  // Collision Helpers
  // 
  
  private var collision :Collision;


  // 
  // Collision Handlers
  // 


  private function onCollision_ballWithPaddle() :Void
  {

    // ball.y = paddle.y - ball.radius;
    // ball.motion.velocityY *= -1;
    // ball.motion.accelerationY *= -1;

    // used for a little bit of ball control
    // ball.ballControleTimer = 5;

    // TODO: play sound effect

  }

  private function onCollision_ballWithBrick( brickId :Int, side :Int ) :Void
  {

    // bricks[brickId] = 0;
    // bricksCount--;

    // if (side == 1 || side == 3)
    // {
    //   ball.motion.velocityY *= -1;
    //   ball.motion.accelerationY *= -1;
    // } 
    // else
    // {
    //   ball.motion.velocityX *= -1;
    //   ball.motion.accelerationX *= -1;
    // }

    // TODO: play sound effect

  }


}