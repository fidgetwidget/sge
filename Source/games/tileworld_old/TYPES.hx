package games.tileworld_old;

import openfl.display.BitmapData;


class TYPES {


  public static var tileTypeIds (get, never) :Iterator< UInt >;

  public static var tileTypeNames (get, never) :Iterator< String >;


  static inline function get_tileTypeIds() :Iterator<UInt> return TileHelper.ids;

  static inline function get_tileTypeNames() :Iterator<String> return TileHelper.names;


  // public static inline function getTileRGBKey( type :UInt ) :UInt return TileHelper.getTileRGBKey(type);
  // public static inline function getIdFromeName( name :String ) :UInt return TileHelper.getIdFromeName(name);
  // public static inline function getTypeFromRGB( rgb :UInt ) :UInt return TileHelper.getTypeFromRGB(rgb);


  // Because we don't have a None tileType, we need to rgb value some other way
  public static var NONE_RGB :UInt = 0x87ceeb; // sky blue

  // 
  // Static Const Types
  // 

  public static var NONE :UInt = 0;

  // Basic
  public static var DIRT    :UInt = 10;
  public static var CLAY    :UInt = 16;
  public static var STONE   :UInt = 20;
  public static var PUTTY   :UInt = 24;
  // Ore
  public static var COAL    :UInt = 50;
  public static var COPPER  :UInt = 54;
  public static var TIN     :UInt = 56;
  public static var ZINC    :UInt = 58;
  public static var IRON    :UInt = 60;
  
  public static var ALUMINIUM :UInt = 64;


  // Progression of base material
  // 
  // Stone
  // 
  // Copper 
  // 
  // Bronze : Copper + Coal
  //  - Brass : Copper + Zink
  // 
  // Iron
  // 
  // Steel : Iron + ?some process 
  //  - Stainless : Iron + Nickle
  //  

  public static var GOLD :UInt = 100;  
  public static var PLATINUM :UInt = 102;

  public static var NICKLE :UInt = 112;
  public static var COBALT :UInt = 114;

}