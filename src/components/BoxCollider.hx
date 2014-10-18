package components;

import luxe.collision.Collision;
import luxe.collision.CollisionData;
import luxe.collision.ShapeDrawer;
import luxe.collision.shapes.Polygon;
import luxe.collision.shapes.Shape;
import luxe.Color;
import luxe.Component;
import luxe.Draw;
import luxe.Entity;
import luxe.options.ComponentOptions;
import luxe.Sprite;
import luxe.Vector;
import luxe.Rectangle;

/**
 * ...
 * @author 
 */
class BoxCollider extends Component
{
	var width:Float;
	var height:Float;
	var sprite:Sprite;
	var centered:Bool;
	public var render:Bool = false;
	public var collides:Bool;
	public var collisionBox:Rectangle;
	
	public var x(get, null):Float;
	public var y(get, null):Float;

	public function new(width:Float=100, height:Float=100, centered:Bool=false) 
	{
		super( { name:"BoxCollider" } );
		this.centered = centered;
		this.height = height;
		this.width = width;
		collisionBox = new Rectangle(0, 0, 64, 64);
	}
	
	override public function init() 
	{
		super.init();
		sprite = cast entity;

		collisionBox.x = sprite.pos.x + (centered ? -width/2 : 0);
		collisionBox.y = sprite.pos.y + (centered ? -width / 2 : 0);
	}
	
	override public function update(dt:Float) 
	{
		super.update(dt);

		// CACHE OLD COLLIDER POSITION
		collides = false;
		var oldCollisionBox = collisionBox.clone();

		// MOVE Y AND CORRECT IF COLLISION
		collisionBox.y = sprite.pos.y + (centered ? -width / 2 : 0);
		for(collider in LuxeApp._game.colliders)
			if(collider.overlaps(collisionBox))
			{
				collides = true;
				collisionBox.y = oldCollisionBox.y;
			}

		// MOVE X AND CORREF IF COLLISION
		collisionBox.x = sprite.pos.x + (centered ? -width / 2 : 0);
		for(collider in LuxeApp._game.colliders)
			if(collider.overlaps(collisionBox))
			{
				collides = true;
				collisionBox.x = oldCollisionBox.x;
			}

		// REFLECT TO SPRITE
		sprite.pos.x = collisionBox.x - (centered ? -width / 2 : 0);
		sprite.pos.y = collisionBox.y - (centered ? -width / 2 : 0);

		if (render)
		{
            Luxe.draw.rectangle({
                x: x, y : y,
                w: width,
                h: height,
                color: new Color().rgb(collides ? 0xFF0000 : 0x737178),
                immediate: true,
                depth: 1,
            });
		}
	}
	
	public function get_x():Float
	{
		return collisionBox.x;
	}
	
	public function get_y():Float
	{
		return collisionBox.y;
	}
}