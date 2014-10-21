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
import Main;
import Bresenham;

/**
 * ...
 * @author 
 */
class Enemy extends Sprite
{
	public var collider:BoxCollider;
	public var attackEvery:Float = 1.5;
	var box:BoxCollider;
	var health:Int = 45;
	var sinceLastAttack:Float = 1;

	public function new(x:Float, y:Float)
	{
        // SPRITE ANIMATION
        var texture = Luxe.loadTexture('assets/enemy.png');
        texture.filter = FilterType.nearest;

        super({
            texture: texture,
            pos: new Vector(x+25, y+30),
            depth: 3,
			size : new Vector(64, 64),
			batcher: LuxeApp._game.mobsBatcher,
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

    	// COLLIDER
		collider = new BoxCollider(ENEMY, 45, 55, [LuxeApp._game.colliders], true);
		add(collider);
		LuxeApp._game.enemyColliders.push(collider.rectangle);

		// AUDIO
		Luxe.audio.create('assets/bite-small.wav', 'bite');
		Luxe.audio.create('assets/bite-small2.wav', 'bite2');
		Luxe.audio.create('assets/bite-small3.wav', 'bite3');
	}
	
	override public function update(dt:Float) 
	{
		super.update(dt);
		sinceLastAttack += dt;
		
		var direction = LuxeApp._game.player.pos.clone().subtract(pos).normalize();
		pos.add(direction.multiplyScalar(100 * dt));
		flipx = direction.x < 0;
		
		var bulletCollision = Lambda.has(collider.rectangle.collisionTypes, BULLET);

		if (bulletCollision)
			health -= 15;
		
		if (health <= 0)
			die();
		
		// ATTACK
		if (sinceLastAttack > attackEvery && Vector.Subtract(pos, LuxeApp._game.player.pos).length < 25)
		{
			Luxe.audio.play(['bite', 'bite1', "bite2"][Std.random(3)]);
			LuxeApp._game.player.hurt(5);
			sinceLastAttack = 0;
		}

		collider.rectangle.collisionTypes = new Array();
	}
	
	override function ondestroy() 
	{
		LuxeApp._game.enemyColliders.remove(collider.rectangle);
		super.ondestroy();
	}
	
	function die() 
	{
		destroy();
		LuxeApp._game.enemiesKilled++;
		new PowerUp(pos.x,pos.y);
	}
}