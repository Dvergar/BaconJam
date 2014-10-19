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
import luxe.components.sprite.SpriteAnimation;

/**
 * ...
 * @author 
 */
class Enemy extends Sprite
{
	var collider:Rectangle;
	var box:BoxCollider;
	var health:Int = 45;
	public var attackEvery:Float = 1.5;
	var sinceLastAttack:Float = 1;

	public function new(x:Float, y:Float)
	{
        var texture = Luxe.loadTexture('assets/enemy.png');
        texture.filter = FilterType.nearest;

        super({
            texture: texture,
            pos: new Vector(x, y),
            depth: 1,
            origin: new Vector(0, 0),
			size : new Vector(64, 64),
        });

        texture.onload = function(t)
        {
	        var anim = new SpriteAnimation({ name:'anim' });
	        add(anim);

	        var animation_json = '
	            {
	                "walk" : {
	                    "frame_size":{ "x":"64", "y":"64" },
	                    "frameset": ["1-3"],
	                    "pingpong":"false",
	                    "loop": "true",
	                    "speed": "18"
	                },
	            }
	        ';

	        anim.add_from_json( animation_json );
	        anim.animation = 'walk';
	        anim.play();
    	}

		box = new BoxCollider(50, 60, [LuxeApp._game.colliders], false);
		add(box);
		collider = box.collisionBox;
		LuxeApp._game.enemyColliders.push(collider);
	}
	
	override public function update(dt:Float) 
	{
		super.update(dt);
		sinceLastAttack += dt;
		
		var direction = LuxeApp._game.player.pos.clone().subtract(pos).normalize();
		pos.add(direction.multiplyScalar(100 * dt));
		
		var bulletCollision = collideWith(LuxeApp._game.bulletColliders);

		if (bulletCollision)
			health -= 15;
		
		if (health <= 0)
			die();
		
		if (sinceLastAttack > attackEvery && Vector.Subtract(pos, LuxeApp._game.player.pos).length < 25)
		{
			LuxeApp._game.player.hurt(5);
			sinceLastAttack = 0;
		}
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