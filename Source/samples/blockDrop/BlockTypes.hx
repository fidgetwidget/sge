package samples.blockDrop;


class BlockTypes { 

  public static var ALL_TYPES = "ijlostz";

  public static var BLOCKS_WIDE :Int = 4;

  public static var NONE = "";

  public static var I = "i";
  public static var J = "j";
  public static var L = "l";
  public static var O = "o";
  public static var S = "s";
  public static var T = "t";
  public static var Z = "z";

  public static function getBlocks( type :String ) :Array<Int>
  {
    return switch (type)
    {

      case "i": [0x0F00, 0x2222, 0x00F0, 0x4444];

      case "j": [0x44C0, 0x8E00, 0x6440, 0x0E20];

      case "l": [0x4460, 0x0E80, 0xC440, 0x2E00];

      case "o": [0xCC00, 0xCC00, 0xCC00, 0xCC00];

      case "s": [0x06C0, 0x8C40, 0x6C00, 0x4620];

      case "t": [0x0E40, 0x4C40, 0x4E00, 0x4640];

      case "z": [0x0C60, 0x4C80, 0xC600, 0x2640];

      default:  [0x0000, 0x0000, 0x0000, 0x0000];

    }
  }

  public static function getColor( type :String ) :Int
  {

    return switch (type)
    {

      case "i": 0x00ffff;

      case "j": 0x0000ff;

      case "l": 0xffa500;

      case "o": 0xffff00;

      case "s": 0x00ff00;

      case "t": 0x551a8b;

      case "z": 0xff0000;

      default:  0x000000;

    }

  }

}
