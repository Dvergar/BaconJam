package entities;

import luxe.Color;
import luxe.options.SpriteOptions;
import luxe.Sprite;
import luxe.Vector;

/**
 * ...
 * @author 
 */
enum PowerUpKind
{
	FireRate;
	Crit;
}
 
class PowerUp extends Sprite
{
	public var kind:PowerUpKind;

	
	public function new(x:Float,y:Float) 
	{
		kind = [FireRate, Crit][Std.random(2)];
		
		super({
			pos: new Vector(x, y),
			// Not removing in case you want to add more;
			// color: switch (kind)
			// 		{
			// 			case Crit:
			// 				new Color().rgb(0xffff00);
			// 			case FireRate:
			// 				new Color().rgb(0x00FF00);
			// 		},
			texture: switch (kind)
					{
						case Crit:
							Luxe.loadTexture('assets/powerup_crit.png');
						case FireRate:
							Luxe.loadTexture('assets/powerup_firerate.png');
					},
			depth:5,
			size: new Vector(25, 25)
		});
		
	}
	
	override public function update(dt:Float) 
	{
		if (Vector.Subtract(pos, LuxeApp._game.player.pos).length < 30)
		{
			switch (kind)
			{
				case Crit:
					LuxeApp._game.player.fireComponent.crit++;
				case FireRate:
					LuxeApp._game.player.fireComponent.fireRate++;
			}
			destroy();
		}
		super.update(dt);
	}
	
}