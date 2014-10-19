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
	var sprite:Sprite;
	var centered:Bool;
	var colliderList:Array<Array<Rectangle>>;
	public var render:Bool = false;
	public var collides:Bool;
	public var collisionBox:Rectangle;
	
	public var x(get, null):Float;
	public var y(get, null):Float;
	@:isVar public var width(default, set):Float;
	@:isVar public var height(default, set):Float;

	public function new(width:Float, height:Float, colliderList:Array<Array<Rectangle>>, centered:Bool=false) 
	{
		super( { name:"BoxCollider" } );
		this.centered = centered;
		this.height = height;
		this.width = width;
		this.colliderList = colliderList;
		collisionBox = new Rectangle(0, 0, width, height);
	}
	
	override public function init() 
	{
		super.init();
		sprite = cast entity;

		collisionBox.x = sprite.pos.x + (centered ? -width/2 : 0);
		collisionBox.y = sprite.pos.y + (centered ? -width/2 : 0);
	}
	
	override public function update(dt:Float) 
	{
		super.update(dt);

		// CACHE OLD COLLIDER POSITION
		collides = false;
		var oldCollisionBox = collisionBox.clone();

		// MOVE Y AND CORRECT IF COLLISION
		collisionBox.y = sprite.pos.y + (centered ? -width / 2 : 0);
		for(colliders in colliderList)
			for(collider in colliders)
				if(collider.overlaps(collisionBox))
				{
					collides = true;
					collisionBox.y = oldCollisionBox.y;
				}

		// MOVE X AND CORREF IF COLLISION
		collisionBox.x = sprite.pos.x + (centered ? -width / 2 : 0);
		for(colliders in colliderList)
			for(collider in colliders)
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
	
	public function set_width(newWidth:Float):Float
	{
		if(collisionBox!=null)
			collisionBox.w = newWidth;
		return width = newWidth;
	}
	
	public function set_height(newHeight:Float):Float
	{
		if(collisionBox!=null)
			collisionBox.h = newHeight;
		return height = newHeight;
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