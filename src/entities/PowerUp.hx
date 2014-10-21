package entities;

import luxe.Text;
import luxe.Color;
import luxe.Sprite;
import luxe.Vector;
import luxe.tween.Actuate;
import luxe.options.SpriteOptions;

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
	
	function textBonus(msg:String, pos:Vector)
	{
		var y = pos.y + 20;
        var text = new Text({
            pos: new Vector(pos.x + 10, y),
            font : LuxeApp._game.font,
            text : msg,
            depth: 3,
        });

        Actuate.tween(text.pos, 3, {y: y - 50});
        Actuate.tween(text.color, 3, {a: 0});
	}

	override public function update(dt:Float) 
	{
		if (Vector.Subtract(pos, LuxeApp._game.player.pos).length < 30)
		{
			switch (kind)
			{
				case Crit:
					LuxeApp._game.player.fireComponent.crit++;
					textBonus("Critical increase", LuxeApp._game.player.pos);
				case FireRate:
					LuxeApp._game.player.fireComponent.fireRate++;
					textBonus("Fire rate increase", LuxeApp._game.player.pos);
			}
			destroy();
		}
		super.update(dt);
	}
	
}