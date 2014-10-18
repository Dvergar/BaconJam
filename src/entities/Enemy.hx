package entities;
import luxe.collision.Collision;
import luxe.collision.CollisionData;
import luxe.collision.ShapeDrawerLuxe;
import luxe.collision.shapes.Polygon;
import luxe.collision.shapes.Shape;
import luxe.Sprite;
import luxe.Vector;
import phoenix.Texture.FilterType;

/**
 * ...
 * @author 
 */
class Enemy extends Sprite
{

	var shape:Shape;
	var health:Int = 10;
	public function new(x:Float, y:Float)
	{
		var texture = Luxe.loadTexture('assets/enemy.png');
        texture.filter = FilterType.nearest;
		
        super({
            texture : texture,
            pos : new Vector(x, y),
			name:"enemy"
        });
		shape = Polygon.rectangle(x, y, 50, 60, true);
		LuxeApp._game.enemyShapes.push(shape);		
	}
	
	override public function update(dt:Float) 
	{
		super.update(dt);
		new ShapeDrawerLuxe().drawShape(shape);
		
		var direction = LuxeApp._game.player.pos.clone().subtract(pos).normalize();
		pos.add(direction.multiplyScalar(100 * dt));
		
		shape.x = pos.x;
		shape.y = pos.y;
		
		var bulletCollision = collideWith(LuxeApp._game.bulletShapes);
		if (bulletCollision !=null)
		{
			//bulletCollision.shape2.destroy();
			health -= 5;
		}
		
		if (health <= 0)
		{
			die();
		}
		
		
	}
	
	override function ondestroy() 
	{
		LuxeApp._game.enemyShapes.remove(shape);
		shape.destroy();
		super.ondestroy();
	}
	
	function die() 
	{
		destroy();
		trace("die");
	}
	
	public function collideWith(shapes:Array<Shape>):CollisionData
	{
		for (collision in Collision.testShapes(shape, shapes))
		{
			if (collision != null)
				return collision;
		}
		return null;
	}


	
}