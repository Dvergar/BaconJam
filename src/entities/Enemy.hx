package entities;
import components.BoxCollider;
import luxe.collision.Collision;
import luxe.collision.CollisionData;
import luxe.collision.ShapeDrawerLuxe;
import luxe.collision.shapes.Polygon;
import luxe.collision.shapes.Shape;
import luxe.Sprite;
import luxe.Vector;
import luxe.Rectangle;
import phoenix.Texture.FilterType;

/**
 * ...
 * @author 
 */
class Enemy extends Sprite
{
	var collider:Rectangle;
	var health:Int = 100;

	public function new(x:Float, y:Float)
	{
		var texture = Luxe.loadTexture('assets/enemy.png');
        texture.filter = FilterType.nearest;
		
        super({
            texture : texture,
            pos : new Vector(x, y),
			depth: 1
        });
		var box = new BoxCollider(50, 60, [LuxeApp._game.colliders], true);
		add(box);
		collider = box.collisionBox;
		LuxeApp._game.enemyColliders.push(collider);
	}
	
	override public function update(dt:Float) 
	{
		super.update(dt);
		
		var direction = LuxeApp._game.player.pos.clone().subtract(pos).normalize();
		pos.add(direction.multiplyScalar(100 * dt));
		
		var bulletCollision = collideWith(LuxeApp._game.bulletColliders);
		if (bulletCollision)
			health -= 15;
		
		if (health <= 0)
			die();
	}
	
	override function ondestroy() 
	{
		LuxeApp._game.enemyColliders.remove(collider);
		super.ondestroy();
	}
	
	function die() 
	{
		destroy();
		trace("die");
	}
	
	public function collideWith(colliders:Array<Rectangle>):Bool
	{
		for (_collider in colliders)
		{
			if (_collider.overlaps(collider))
				return true;
		}
		return false;
	}


	
}