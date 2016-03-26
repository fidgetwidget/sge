package sge.tiles;


// The TileCollection Interface
interface TileCollection {


  public function getTile( x :Float, y :Float, z :Int ) :Tile;

  public function setTile( x :Float, y :Float, z :Int, type :UInt ) :Bool;

  public function touchTile( x :Float, y :Float, z :Int ) :Void;


  public function getCollision( x :Float, y :Float ) :UInt;

  public function setCollision( x :Float, y :Float, tile :Tile = null ) :Void;


}