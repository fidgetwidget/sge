package sge.collision;


// 
// A 4 directional type
// 
class DIRECTION
{

  public static var NONE        :Int = 0;

  public static var UP          :Int = 1;
  public static var RIGHT       :Int = 2;
  public static var DOWN        :Int = 4;
  public static var LEFT        :Int = 8;

  public static var ALL         :Int = UP | RIGHT | DOWN | LEFT;
  public static var HORIZONTAL  :Int = RIGHT | LEFT;
  public static var VERTICAL    :Int = UP | DOWN; 
  

}

// --------+--------+---------+-----
//         |        |         |
// Diagram | Name   | Binary  | Hex
// --------+--------+---------+-----
//         |        |         |
//   +  +  |        |         |
//         | EMPTY  |  0000   | 0x0
//   +  +  |        |         |
//         |        |         |
// --------+--------+---------+-----
//         |        |         |
//   +--+  |        |         |
//         | UP     |  0001   | 0x1
//   +  +  |        |         |
//         |        |         |
// --------+--------+---------+-----
//         |        |         |
//   +  +  |        |         | 
//      |  | RIGHT  |  1000   | 0x2
//   +  +  |        |         |
//         |        |         |
// --------+--------+---------+-----
//         |        |         |
//   +  +  |        |         |
//         | DOWN   |  0100   | 0x4
//   +--+  |        |         |
//         |        |         |
// --------+--------+---------+-----
//         |        |         |
//   +  +  |        |         |
//   |     | LEFT   |  0010   | 0x8
//   +  +  |        |         |
//         |        |         |
// --------+--------+---------+-----
//         |        |         |
//   +--+  |        |         | 
//   |  |  | ALL    |  1111   | 0xf
//   +--+  |        |         |
//         |        |         |
// --------+--------+---------+----- 
