package samples.blockDrop;


import openfl.display.Shape;
import openfl.display.Graphics;
import sge.geom.base.Coord;
import sge.Lib;


class NextBlock extends Block
{

  public var nextType :String;
  public var pool :Array<String>;
  public var allTypes :Array<String>;


  public function new() 
  { 

    super();
    nextType = "";
    pool = new Array();
    allTypes = BlockTypes.ALL_TYPES.split("");

  }

  public function reset() :Void
  {
    init();

    restePool();
    nextType = pool.pop();
  }


  public function ready( next :Block ) :Block
  {

    var center = Math.floor(BlockDrop.BOARD_COLS * 0.5) - Math.floor(BlockTypes.BLOCKS_WIDE * 0.5);

    next.set(center, 0, nextType);
    
    nextType = pool.pop();
    set(0, 0, nextType);

    if (pool.length == 0)
      restePool();

    return next;

  }



  // Reset the pool of next piece nextTypes
  private function restePool() :Void
  {

    if (pool.length > 0)
      emptyPool();

    // add 4 of each nextType of piece to the pool
    for (i in 0...4)
    {
      for (piece in allTypes)
      {
        pool.push(piece);
      }
    }
    // shuffle the list 
    Lib.shuffleArray(pool);

  }

  // Empty the next piece nextTypes pool
  private function emptyPool() :Void while (pool.length > 0) pool.pop();

}
