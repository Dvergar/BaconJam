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
	
	var speed = 500;
	var time = 5;
	var targetY:Float;
	
	public function new(x:Float, y:Float) 
	{
		targetY = y;
		var texture = Luxe.loadTexture('assets/rock.png');
        texture.filter = FilterType.nearest;
		
        super({
            texture : texture,
            pos : new Vector(x, y-time*speed),
			depth: 1
        });
	}
	
	override public function update(dt:Float) 
	{
		super.update(dt);
		
		pos.add(new Vector(0, speed).multiplyScalar(dt));
		
		if (pos.y > targetY)
		{
			//do shit with collisions
			pos.y = targetY;
			
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