package sge.graphics;

import haxe.Json;
import openfl.Assets;
import openfl.geom.Point;
import openfl.geom.Rectangle;


class AnimationImporter extends SpriteSheetImporter {

  static var rect :Rectangle;
  static var zero :Point;

  static var json :String;

  // 
  // TODO: change the import path so that the set's paths are relative
  // 
  public static function importAnimationSet( importPath :String, animationSet :AnimationSet ) :AnimationSet
  {
    if (animationSet == null) animationSet = new AnimationSet();

    json = Assets.getText('${importPath}.json');
    var importData = Json.parse(json);

    return animationSet;
  }
  

  // 
  // Create a TileSet SpriteSheet 
  // 
  public static function importFrames( json :String, spritesheet :SpriteSheet = null ) :SpriteSheet
  {
    if (spritesheet == null) spritesheet = new SpriteSheet();

    return spritesheet;
  }

}

