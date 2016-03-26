
# TileWorld

This is very much still a work in progress - and not really a game.

- A fast tile drawing system that allows the player to alter the state of the world.
- Testing a tile collision solution that doesn't require creating a large number of, or complex colliders.
- Move the player sprite (who begins just off screen {top left}) with the ARROW keys.
- Draw tiles with left click.
- Move the camera by holding the SPACE key, and left click dragging the world.
- Change the zoom with the scroll wheel.
- Cycle through the available tile types with the / key
- toggle drawing the region/chunk bounds with the B key
- toggle drawing the collision helpers with the C key
- hold down the ` key to show some debug data about what is at the cursors position.

NOTE:
- when both the bounds and collision drawing helpers are active, the frame rate will drop significantly
- the player doesn't have any gravity so you can move it in any direction with the ARROW keys.
- the collision system isn't working correctly yet.
