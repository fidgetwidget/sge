package sge.entity;

import sge.geom.Coord;


class EntityGrid extends EntityManager {


  public var CELL_WIDTH   :Int = 32;
  public var CELL_HEIGHT  :Int = 32;


  public function new ()
  {
    super();
    _entitiesById = new Map();    // the entity indexed by it's id
    _idsByCoord   = new Map();    // the entity_ids for a given coord
    _coordById    = new Map();    // the coord for a given entity_id
    _idsToUpdate  = new Array();  // the entity_ids that may have changed coord
  }


  override public function add ( entity : Entity ) : Void
  {
    _entitiesById.set(entity.id, entity );
    getCoordForEntity( entity );
  }


  override public function remove ( entity : Entity ) : Void
  {
    _entitiesById.remove( entity.id );
    _coordById.remove( entity.id );
  }

  // Tell the manager to update the entity
  override public function touch ( entity : Entity ) : Void
  {
    _idsToUpdate.push( entity.id );
  }


  override public function update () : Void
  {
    var id : Int;
    var entity : Entity;
    var oldCoord : Coord;
    var newCoord : Coord;
    var idsArray : Array<Int>;

    while (_idsToUpdate.length > 0)
    {
      id = _idsToUpdate.pop();
      entity = _entitiesById.get(id);

      entity.update();
      
      // test if the entity moved
      oldCoord = _coordById.get(id);
      getCoordForEntity(entity, newCoord);

      // adjust which coord the entity is stored in
      if (oldCoord != newCoord)
      {
        
        // adjust the ids for the given coord
        if (oldCoord != null)
        {
          idsArray = _idsByCoord.get(oldCoord.hashString());
          idsArray.remove(id);
        }
        idsArray = _idsByCoord.get(newCoord.hashString());
        idsArray.push(id);

        // adjust the coord for the given id
        _coordById.set(id, newCoord); 

      }
    }
  }

  private function getCoordForEntity ( entity : Entity, coord :Coord = null ) : Coord
  {
    var _coord :Coord;

    if ( coord != null ) 
      _coord = coord;
    else
    {
      if (_coordById.exists( entity.id ))
        _coord = _coordById.get( entity.id );
      else
      {
        _coord = new Coord();
        _coordById.set( entity.id, _coord );  
      }
    }

    _coord.x = Math.floor( entity.x / CELL_WIDTH );
    _coord.y = Math.floor( entity.y / CELL_HEIGHT );

    return _coord;

  }

  public function near ( vector : Vector, entities :Array<Entity> = null, neighbors :Bool = false ) : Array<Entity> 
  { 
    var cx = get_cell_x(vector.x);
    var cy = get_cell_y(vector.y);

    if (entities == null) entities = new Array();
    getEntities(cx, cy, entities);

    if (neighbors)
    {
      getEntities(cx+1, cy,   entities);
      getEntities(cx  , cy+1, entities);
      getEntities(cx-1, cy,   entities);
      getEntities(cx  , cy-1, entities);
      // diagnals
      getEntities(cx+1, cy+1, entities);
      getEntities(cx-1, cy-1, entities);
      getEntities(cx+1, cy-1, entities);
      getEntities(cx-1, cy+1, entities);
    }

    return entities;
  }

  public function collision ( collider : Collider, hits : Array<Entity> ) : Bool 
  { 
    return false; 
  }

  // 
  // Private Helpers
  // 

  inline private function get_cell_x( x :Float ) :Int  return Math.floor( x / CELL_WIDTH );
  
  inline private function get_cell_y( y :Float ) :Int  return Math.floor( y / CELL_HEIGHT );

  inline private function getEntities( cx :Int, cy :Int, entities :Array<Entity> ) :Void
  {

    var _coordHash = Coord.getHashString(cx, cy);
    if (!_idsByCoord.exists(_coordHash )) return;

    var ids :Array<Int> = _idsByCoord.get(  );
    for (id in ids)
    {
      entities.push(_entitiesById.get(id));
    }

  }

  private var _entitiesById : Map<Int, Entity>;
  private var _idsByCoord   : Map<String, Array<Int>>;
  private var _coordById    : Map<Int, Coord>;
  private var _idsToUpdate  : Array<Int>;

}
