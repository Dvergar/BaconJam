package entities;
import components.BoxCollider;
import luxe.Quaternion;
import luxe.Sprite;
import luxe.Vector;
import luxe.Color;
import luxe.tween.Actuate;
import phoenix.Texture.FilterType;

/**
 * ...
 * @author 
 */
class Bullet extends Sprite
{
	var direction:Vector;
	public var speed:Float = 400;
	public var collider:BoxCollider;
	
    public function new(x:Float, y:Float,direction:Vector)
    {
		collider = new BoxCollider(BULLET, 2, 2, [LuxeApp._game.colliders, LuxeApp._game.enemyColliders], true);
		
        this.direction = direction.normalized;

		var texture = Luxe.loadTexture('assets/bullet.png');
        texture.filter = FilterType.nearest;
        super({
            texture: texture,
            pos: new Vector(x, y),
            depth: 1,
        });
		
        texture.onload = function(f)
        {
        	origin = new Vector(texture.width/2, texture.height/2);
			
			collider.width = texture.width;
			collider.height = texture.height;
        }
		
		this.rotation.setFromAxisAngle(new Vector(0, 0, 1),
									   Math.atan2(direction.y, direction.x));
		add(collider);
	}
	
	override public function init() 
	{
		super.init();
		LuxeApp._game.bulletColliders.push(collider.rectangle);
	}
		
	override public function update(dt:Float) 
	{
		super.update(dt);
		var direction = new Vector(1, 0, 0).applyQuaternion(rotation);
		pos.x += direction.x * speed * dt;
		pos.y += direction.y * speed * dt;
		
		if(collider.collides)
		{
			// CLEAN UP
			destroy();
			LuxeApp._game.bulletColliders.remove(collider.rectangle);

			if(Lambda.has(collider.rectangle.collisionTypes, ENEMY))
			{
				// BLOOD PARTICLES
				var texture = Luxe.loadTexture('assets/blood.png');
		        texture.filter = FilterType.nearest;

		        var c = new Color(1, 1, 1, 1);
		        var sprite = new Sprite({
		            texture : texture,
		            pos : pos,
		            depth : 1,
		            color: c,
		        });

		        Actuate.tween(c, 1, {a: 0}).ease( luxe.tween.easing.Expo.easeOut );
		        Actuate.tween(sprite.pos, 0.5, { x: pos.x + direction.x * 100,
		        							     y: pos.y + direction.y * 100,
		        							     })
		        	.ease( luxe.tween.easing.Expo.easeOut )
		        	.onComplete(function()
		        	{
		        		sprite.destroy();
				   	});
	        }
		}

		collider.rectangle.collisionTypes = new Array();
	}
}