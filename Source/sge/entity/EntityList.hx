package sge.entity;


class EntityList extends EntityManager {


  public function new ()
  {
    super();
    _entitiesById = new Map();
    _idsToUpdate = new Array();
  }


  override public function add ( entity : Entity ) : Void
  {
    _entitiesById.add( entity.id, entity );
  }


  override public function remove ( entity : Entity ) : Void
  {
    _entitiesById.remove( entity.id );
  }

  override public function touch ( entity : Entity ) : Void
  {
    _idsToUpdate.push( entity );
  }


  override public function update () : Void
  {
    var id : Int;
    var entity : Entity;

    while (_idsToUpdate.length > 0)
    {
      id = _idsToUpdate.pop();
      entity = _entitiesById.get(id);
      entity.update();
    }

  }


  private var _entitiesById : Map<Int, Entity>;
  private var _idsToUpdate : Array<Int>;
  
}
