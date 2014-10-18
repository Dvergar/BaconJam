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

/**
 * ...
 * @author 
 */
class BoxCollider extends Component
{
	var width:Float;
	var height:Float;
	var sprite:Sprite;
	var shape:Shape;
	var centered:Bool;
	public var render:Bool = false;
	public var collides:Bool;
	
	public var x(get, null):Float;
	public var y(get, null):Float;
	
	public function new(width:Float=100,height:Float=100,centered:Bool=false) 
	{
		super( { name:"BoxCollider" } );
		this.centered = centered;
		this.height = height;
		this.width = width;
	}
	
	override public function init() 
	{
		super.init();
		sprite = cast entity;
		shape = Polygon.rectangle(sprite.pos.x,sprite.pos.y,width, height,false);
	}
	
	override public function update(dt:Float) 
	{
		collides = collideWith(LuxeApp._game.shapes);

		super.update(dt);
		shape.x = sprite.pos.x + (centered ? -width/2 : 0);
		shape.y = sprite.pos.y + (centered ? -width / 2 : 0);
		if (render)
		{
			Luxe.draw.box( {
				x:x,
				y:y,
				w:width,
				h:height,
				immediate:true,
				color:new Color().rgb(collides ? 0xFF0000 : 0x737178),
			} );
		}
	}
	
	public function get_x():Float
	{
		return shape.x;
	}
	
	public function get_y():Float
	{
		return shape.y;
	}
	
	public function collideWith(shapes:Array<Shape>):Bool
	{
		for (collision in Collision.testShapes(shape, shapes))
		{
			if (collision != null)
				return true;
		}
		return false;
	}
	
}