package sge.entity;


import openfl.display.Graphics;
import sge.geom.Coord;
import sge.geom.Vector;
import sge.collision.Collider;
import sge.collision.COLLISION_GROUP;
import sge.lib.StringArrayPool;

// 
// EntityGrid; EntityManager
// 
// - stores the entities location info in a grid 
//   for fast positional querying
// - supports negative positions with string keys
// 
// NOTE: cell size should be such that no entitiy 
//       can inhabit more than a maximum of 4
//       
class EntityGrid extends EntityManager {


  public var CELL_WIDTH   :Int = 124;
  public var CELL_HEIGHT  :Int = 124;


  public function new ()
  {
    super();
    _entitiesById = new Map();    // the entity indexed by it's id
    _idsByCoord   = new Map();    // the entity_ids for a given coord
    _coordById    = new Map();    // the coord for a given entity_id
    _coordMap     = new Map();
    _coordsById   = new Map();
    _idsToUpdate  = [];  // the entity_ids that may have changed coord
  }


  override public function add ( entity : Entity, collisionGroup : Int = COLLISION_GROUP.NONE ) : Void
  {
    id = entity.id;
    _entitiesById.set(id, entity );
    _coordById.set(id, "");
    
    if (entity.hasCollider)
      _coordsById.set(id, StringArrayPool.instance.get());

    // updateEntityCoords( entity );
    touch( entity );

    _count++;
  }


  override public function remove ( entity : Entity ) : Void
  {
    id = entity.id;
    
    if ( _entitiesById.remove( id ) ) 
    {
      _count--;
      if (entity.hasCollider)
      {
        coordKeys = _coordsById.get( id );
        for (key in coordKeys)
        {
          ids = _idsByCoord.get(key);
          ids.remove(id);
        }
        StringArrayPool.instance.push( coordKeys );
        _coordsById.remove( id );
      }

      _coordById.remove( id );
      _idsToUpdate.remove( id );
    }
  }

  // Tell the manager to update the entity
  override public function touch ( entity :Entity ) : Void
  {
    if (_idsToUpdate.indexOf( entity.id ) < 0)
      _idsToUpdate.push( entity.id );
  }


  // 
  // func: ( entity :Entity ) : Void
  // called on each entity update
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

        updateEntityCoords(entity);
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

      updateEntityCoords(entity);
    }
  }
  // var id :Int
  // var entity :Entity


  override public function debug_render ( graphics :Graphics ) : Void
  {
    if (coordsRendered == null) coordsRendered = [];

    while (coordsRendered.length > 0) coordsRendered.pop();

    for ( e in _entitiesById )
    {
      e.debug_render( graphics );

      id = e.id;
      // Render the cell the entity is in...
      // if it hasn't already been rendered
      if (e.hasCollider)
      {
        coordKeys = _coordsById.get( id );
        if (coordKeys == null) continue;
        for ( key in coordKeys )
        {
          coord = _coordMap.get( key );
          debug_render_cell( coord, graphics );
        }
      }
      else
      {
        hash = _coordById.get( id );
        coord = _coordMap.get( hash );
        debug_render_cell( coord, graphics );
      }
    } // end for ( e in _entitiesById )

  }
  // var coordsRendered :Array<Coord>
  // var coord :Coord

  inline function debug_render_cell( coord :Coord, graphics :Graphics ) : Void
  {
    if (coord == null) return;
    if (coordsRendered.indexOf(coord) < 0)
    {
      coordsRendered.push(coord);
      graphics.drawRect(coord.x * CELL_WIDTH, coord.y * CELL_HEIGHT, CELL_WIDTH, CELL_HEIGHT);
    }
  }


  private function updateEntityCoords ( entity :Entity ) :Void
  {
    if (! _entitiesById.exists( entity.id )) return null;
    
    if (entity.hasCollider) 
    {
      // updateEntityCoords_point( entity );
      updateEntityCoords_collider( entity );
    }
    else
    {
      updateEntityCoords_point( entity );
    }

  }
  // var oldCoord :String
  // var newCoord :String
  // var ids :Array<Int>
  

  inline function updateEntityCoords_point ( entity :Entity ) :Void
  {
    id = entity.id;

    oldCoord = _coordById.get(id);
    newCoord = getCoordHash( entity.x, entity.y );
    if (! _coordMap.exists(newCoord)) getCoord( entity.x, entity.y );

    // adjust which coord the entity is stored in
    if (oldCoord != newCoord)
    {
      // adjust the ids for the given coord
      if (oldCoord != "")
      {
        if (! _idsByCoord.exists( oldCoord )) _idsByCoord.set( oldCoord, [] );
        ids = _idsByCoord.get( oldCoord );
        ids.remove(id);
      }

      if (! _idsByCoord.exists( newCoord )) _idsByCoord.set( newCoord, [] );
      ids = _idsByCoord.get( newCoord );
      if (ids.indexOf(id) < 0) ids.push(id);

      // adjust the coord for the given id
      _coordById.set( id, newCoord ); 
    }
  }


  inline function updateEntityCoords_collider ( entity :Entity ) :Void
  {
    id = entity.id;

    // Remove old
    coordKeys = _coordsById.get( id );

    for (oldCoord in coordKeys)
    {
      if (! _idsByCoord.exists( oldCoord )) _idsByCoord.set( oldCoord, [] );
      ids = _idsByCoord.get( oldCoord );
      ids.remove(id);
    }

    // Add new
    coordKeys = getColliderCoords( entity.collider, coordKeys );
    for (newCoord in coordKeys)
    {
      if (! _idsByCoord.exists( newCoord )) _idsByCoord.set( newCoord, [] );
      ids = _idsByCoord.get( newCoord );
      if (ids.indexOf(id) < 0) ids.push(id);
    }

    _coordsById.set( id, coordKeys );
  }


  override public function near ( entity : Entity, entities :Array<Entity> = null ) : Array<Entity> 
  { 
    if (_entitiesById.exists(entity.id)) return near_local(entity, entities);
      
    if (entity.hasCollider) return nearCollider(entity.collider, entities);

    return nearPosition(entity, entities);
  }


  override public function nearPosition ( position : Dynamic, entities :Array<Entity> = null ) : Array<Entity> 
  { 
    cx = get_cell_x( position.x );
    cy = get_cell_y( position.y );

    if (entities == null) entities = [];

    getEntities( cx, cy, entities );

    return entities;
  }


  inline function near_local ( entity :Entity, entities :Array<Entity> ) : Array<Entity>
  {
    id = entity.id;

    nearText = "";
    if (entity.hasCollider)
    {
      coordKeys = _coordsById.get(id);
      for (hash in coordKeys)
      {
        ids = _idsByCoord.get(hash);
        addEntitiesById(ids, entities);
        nearText += '[$hash|${ids.length}]';
      }
    }
    else
    {
      hash = _coordById.get(id);
      ids = _idsByCoord.get(hash);
      addEntitiesById(ids, entities);
      nearText += '[$hash|${ids.length}]';
    }

    nearText += '(${entities.length})';
    Game.debug.setLabel('near', nearText);

    entities.remove(entity);

    return entities;
  }
  var nearText :String;


  public inline function nearCollider ( collider :Collider, entities :Array<Entity> ) : Array<Entity>
  {
    coordKeys = getColliderCoords( collider, coordKeys );

    for (hash in coordKeys)
    {
      ids = _idsByCoord.get(hash);
      addEntitiesById(ids, entities);
    }

    return entities;
  }


  public inline function addEntitiesById ( ids :Array<Int>, entities :Array<Entity>, allowDuplicates :Bool = false ) : Void
  {
    if (ids == null) return;
    if (entities == null) entities = [];

    for (id in ids)
    {
      entity = _entitiesById.get(id);
      if (entities.indexOf(entity) < 0 || allowDuplicates) entities.push( entity );
    }
  }
  

  override public function collision ( collider : Collider, hits : Array<Entity> ) : Bool 
  { 
    return false;
  }


  // 
  // Private Helpers
  // 

  inline function getColliderCoords( collider : Collider, coords :Array<String> ) : Array<String>
  {
    if (coords == null) 
      coords = StringArrayPool.instance.get();
    else 
      StringArrayPool.clean(coords);

    tl = getCoord(collider.left, collider.top);
    tr = getCoord(collider.right, collider.top);
    bl = getCoord(collider.left, collider.bottom);
    br = getCoord(collider.right, collider.bottom);

    tlh = tl.hashString();
    trh = tr.hashString();
    blh = bl.hashString();
    brh = br.hashString();

    // we check if its already there to prevent adding multiple of the same
    if (coords.indexOf(tlh) < 0) coords.push(tlh);
    if (coords.indexOf(trh) < 0) coords.push(trh);
    if (coords.indexOf(blh) < 0) coords.push(blh);
    if (coords.indexOf(brh) < 0) coords.push(brh);

    return coords;
  }
  var tl :Coord;
  var tr :Coord;
  var bl :Coord;
  var br :Coord;
  var tlh :String;
  var trh :String;
  var blh :String;
  var brh :String;


  inline function getCoordHash( x :Float, y :Float ) :String
  {
    cx = get_cell_x( x );
    cy = get_cell_y( y );
    return Coord.getHashString( cx, cy );
  }


  inline function getCoord( x :Float, y :Float ) :Coord
  {
    var coord;

    cx = get_cell_x( x );
    cy = get_cell_y( y );
    hash = Coord.getHashString( cx, cy );

    if (! _coordMap.exists( hash ) )
    {
      coord = new Coord( cx, cy );
      _coordMap.set( hash, coord );
    }
    else
    {
      coord = _coordMap.get( hash );
    }

    return coord;
  }
  // var cx :Int
  // var cy :Int
  // var hash :String
  // var coord :Coord


  inline function get_cell_x( x :Float ) :Int  return Math.floor( x / CELL_WIDTH );
  

  inline function get_cell_y( y :Float ) :Int  return Math.floor( y / CELL_HEIGHT );


  inline function getEntities( cx :Int, cy :Int, entities :Array<Entity> ) :Void
  {
    hash = Coord.getHashString(cx, cy);
    if (!_idsByCoord.exists( hash )) return;

    ids = _idsByCoord.get( hash );
    for (id in ids)
    {
      entities.push(_entitiesById.get(id));
    }
  }
  // var hash :String
  // var ids :Array<Int>

  var _entitiesById : Map<Int, Entity>;
  var _idsByCoord   : Map<String, Array<Int>>;
  var _coordById    : Map<Int, String>;
  var _coordsById   : Map<Int, Array<String>>;
  var _coordMap     : Map<String, Coord>;
  var _idsToUpdate  : Array<Int>;
  var _count :Int = 0;

  var id :Int;
  var entity :Entity;
  var oldCoord :String;
  var newCoord :String;
  var ids :Array<Int>;
  var coord :Coord;
  var coordKeys :Array<String>;
  var coordsRendered :Array<Coord>;
  var hash :String;
  var cx :Int;
  var cy :Int;

  override function get_count() :Int return _count;

}
