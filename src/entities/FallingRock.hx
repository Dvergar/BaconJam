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
	
	public function new(x:Float, y:Float) 
	{
		shadow = new Sprite( { 
			pos: new Vector(x, y),
			texture: Luxe.loadTexture('assets/rock-shadow.png'),
			depth:1
		});
		
		shadow.color.a = 0;
		
		targetY = y;
		var texture = Luxe.loadTexture('assets/rock.png');
        texture.filter = FilterType.nearest;
		
        super({
            texture : texture,
            pos : new Vector(x, y-time*speed),
			depth: 2
        });
	}
	
	override public function update(dt:Float) 
	{
		super.update(dt);
		
		if (shadow !=null && shadow.color.a < 1)
			shadow.color.a += dt;
		
		pos.add(new Vector(0, speed).multiplyScalar(dt));
		
		if (pos.y > targetY)
		{
			pos.y = targetY;
			if (shadow != null)
			{
				if (Vector.Subtract(pos, LuxeApp._game.player.pos).length < 50)
				{
					LuxeApp._game.player.hurt(15);
				}
				shadow.destroy();
				shadow = null;
				Luxe.camera.shake(6, true);
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