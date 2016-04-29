package sge.geom;


class Transform
{
  // Math.PI / 180
  private static inline var DEGREES_TO_RADIANS_CONST = 3.141592653589793 / 180;


  public var position :Vector;
  public var rotation (get, set) :Float;
  public var scale :Vector;

  public var x (get, set) :Float;
  public var y (get, set) :Float;
  public var scaleX (get, set) :Float;
  public var scaleY (get, set) :Float;

  public var matrix (get, never) :Matrix;


  public function new()
  {
    _position = new Vector(0, 0);
    _rotationRadians = 0;
    _scale = new Vector(1, 1);
  }


  inline private function get_rotation() :Float return _rotationDegrees;
  private function set_rotation( angle :Float ) :Float
  {
    _rotationDegrees = angle;
    _rotationRadians = angle * DEGREES_TO_RADIANS_CONST;
    return angle;
  }

  inline private function get_x() :Float return _position.x;
  inline private function set_x( x :Float ) :Float return _position.x = x;
  inline private function get_y() :Float return _position.y;
  inline private function set_y( y :Float ) :Float return _position.y = y;
  inline private function get_scaleX() :Float return _scale.x;
  inline private function set_scaleX( x :Float ) :Float return _scale.x = x;
  inline private function get_scaleY() :Float return _scale.y;
  inline private function set_scaleY( y :Float ) :Float return _scale.y = y;

  private function get_matrix() :Matrix
  {
    if (_matrix == null) _matrix = new Matrix();
    _matrix.compose(_position, _rotationRadians, _scale);
    return _matrix;
  }

  private var _position :Vector;
  private var _rotationDegrees :Float;
  private var _rotationRadians :Float;
  private var _scale :Vector;
  private var _matrix :Matrix;


  // Static Methods

  public static function decomposeMatrix( matrix : Matrix, transform :Transform = null ) :Transform
  {
    var px :Vector, py :Vector, rot :Float;

    px = deltaTransformPoint(0, 1, matrix.a, matrix.b, matrix.c, matrix.d);
    py = deltaTransformPoint(1, 0, matrix.a, matrix.b, matrix.c, matrix.d);

    rot = ((180 / Math.PI) * Math.atan2(py.y, py.x));

    if (transform == null) transform = new Transform();

    transform.scaleX = Math.sqrt(matrix.a * matrix.a + matrix.b * matrix.b);
    transform.scaleY = Math.sqrt(matrix.c * matrix.c + matrix.d * matrix.d);

    transform.rotation = rot;

    transform.x = matrix.tx;
    transform.y = matrix.ty;

    return transform;
  }

  private static function deltaTransformPoint(x :Float, y :Float, a :Float, b :Float, c :Float, d :Float) :Vector
  {
    return new Vector(x * a + y * c, x * b + y * d);
  }

}