package sge.entity;


import openfl.display.Graphics;
import sge.collision.Collider;


class EntityList extends EntityManager {


  public function new ()
  {
    super();
    _entitiesById = new Map();
    _entityIdGroupMap = new Map();
    _idsToUpdate = new Array();
  }


  override public function add ( entity :Entity, group :String = "" ) : Void
  {
    _entitiesById.set( entity.id, entity );
    
    if (group != "") _entityIdGroupMap.set( entity.id, group );

    _count++;
  }


  override public function remove ( entity : Entity ) : Void
  {
    _entityIdGroupMap.remove( entity.id );

    if ( _entitiesById.remove( entity.id ) ) _count--; 
  }

  override public function touch ( entity : Entity ) : Void
  {
    _idsToUpdate.push( entity.id );
  }


  override public function update ( updateAll :Bool = false, onUpdate : Entity -> Void = null, beforeUpdate :Bool = false ) : Void
  {
    if (updateAll)
    {
      for (entity in _entitiesById)
      {
        if (onUpdate != null && beforeUpdate)
          onUpdate(entity);

        entity.update();

        if (onUpdate != null && !beforeUpdate)
          onUpdate(entity);
      }

      while (_idsToUpdate.length > 0) _idsToUpdate.pop();

      return;
    }

    while (_idsToUpdate.length > 0)
    {
      id = _idsToUpdate.pop();
      entity = _entitiesById.get(id);

      if (onUpdate != null && beforeUpdate)
        onUpdate(entity);

      entity.update();

      if (onUpdate != null && !beforeUpdate)
        onUpdate(entity);
    }

  }
  var id :Int;
  var entity :Entity;


  override public function debug_render ( graphics :Graphics ) :Void
  {
    for (e in _entitiesById)
    {
      e.debug_render( graphics );
    }
  }

  private var _entitiesById : Map<Int, Entity>;
  private var _entityIdGroupMap :Map<Int, String>;
  private var _idsToUpdate : Array<Int>;
  private var _count :Int = 0;

  override function get_count() :Int return _count;
  
}
