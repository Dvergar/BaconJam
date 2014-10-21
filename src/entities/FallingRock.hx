package entities;
import luxe.tween.Actuate;
import luxe.Vector;
import luxe.Sprite;
import phoenix.Texture.FilterType;

/**
 * ...
 * @author 
 */
class FallingRock extends Sprite
{
	
	var speed = 800;
	var time = 1;
	var targetY:Float;
	var shadow:Sprite;
	var targetX:Float;
	
	public function new(x:Float, y:Float) 
	{
		shadow = new Sprite( { 
			pos: new Vector(x, y),
			texture: Luxe.loadTexture('assets/rock-shadow.png'),
			depth:1
		});
		
		shadow.color.a = 0;
		
		targetY = y;
		targetX = x;
		var texture = Luxe.loadTexture('assets/rock.png');
        texture.filter = FilterType.nearest;
		
        super({
            texture : texture,
            pos : new Vector(x-time*speed, y-time*speed),
			depth: 2
        });
	}
	
	override public function update(dt:Float) 
	{
		super.update(dt);
		
		if (shadow !=null && shadow.color.a < 1)
			shadow.color.a += dt;
		
		pos.add(new Vector(speed, speed).multiplyScalar(dt));
		
		if (pos.y > targetY)
		{
			pos.y = targetY;
			pos.x = targetX;
			if (shadow != null)
			{
				var distance = Vector.Subtract(pos, LuxeApp._game.player.pos).length;
				if (distance < 50)
				{
					LuxeApp._game.player.hurt(15);
				}
				shadow.destroy();
				shadow = null;

				// SPAWN ENEMIES
				function spawnMob(posx:Int, posy:Int)
					if(!LuxeApp._game.map.collisionMap[posx][posy])
						new Enemy(posx * 64, posy * 64);

				var posx:Int = Std.int(targetX / 64);
				var posy:Int = Std.int(targetY / 64);

				spawnMob(posx + 1, posy);
				spawnMob(posx - 1, posy);
				spawnMob(posx, posy + 1);
				spawnMob(posx, posy - 1);

				// METEOR SHAKE
				if(distance <500)
					Luxe.camera.shake(8000 / distance, true);
			}
			
			//Actuate.tween(color, 0.5, { a:0 } ).onComplete(function() { destroy(); } ); //it doesn't work on web		 target	
		}
		if (pos.y == targetY)
		{
			color.a -= dt;
			if (color.a < 0)
				destroy();
		}
	}
	
}