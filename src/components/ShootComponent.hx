package components;

import entities.Bullet;
import luxe.Component;
import luxe.options.ComponentOptions;
import luxe.Sprite;
import luxe.Vector;
import luxe.Quaternion;
import phoenix.Texture.FilterType;

/**
 * ...
 * @author 
 */
class ShootComponent extends Component
{
	public var direction:Vector;
	public var fireRate:Float = 1;
	public var shooting:Bool = false;
	public var crit:Float = 1;
	var sprite:Sprite;
	var e:Sprite;
	var sinceLastShoot:Float = 0;
	
	public function new(?_options:ComponentOptions) 
	{
		super(_options);

		// Yeah yeah, can probably be in its own component
		var texture = Luxe.loadTexture('assets/weapon.png');
        texture.filter = FilterType.nearest;
        sprite = new Sprite({
            texture : texture,
            pos : new Vector( Luxe.screen.w/2, Luxe.screen.h/2 ),
            depth : 1,
        });

		texture.onload = function(f)
		{
	        sprite.origin = new Vector(0, texture.height/2);
		}
	}
	
	override public function init() 
	{
		super.init();
		e = cast entity;
	}
	
	override public function update(dt:Float) 
	{
		super.update(dt);
		sinceLastShoot += dt;
		if (sinceLastShoot > (1 / fireRate) && shooting)
		{	
			fire();
			sinceLastShoot = 0;
		}

		sprite.pos.x = e.pos.x ;
		sprite.pos.y = e.pos.y;

		var angle = Luxe.screen.mid.rotationTo(LuxeApp._game.mousePos);
		sprite.rotation = new Quaternion().setFromEuler(new Vector(0,0, angle - 90).radians());
	}
	
	private function fire()
	{
		if (Std.random(100) < crit)
		{
			trace("CRIT!!");
			new Bullet(e.pos.x, e.pos.y, direction.clone()
				.applyQuaternion(new Quaternion().setFromAxisAngle(new Vector(0, 0, 1),0.017*Std.random(10))));
			new Bullet(e.pos.x, e.pos.y, direction.clone());
			new Bullet(e.pos.x, e.pos.y, direction.clone()
				.applyQuaternion(new Quaternion().setFromAxisAngle(new Vector(0, 0, 1),-0.017*Std.random(10))));
		}else
		{
			new Bullet(e.pos.x, e.pos.y, direction.clone()
				.applyQuaternion(new Quaternion().setFromAxisAngle(new Vector(0, 0, 1),-0.017*(Std.random(10)-5))));
		}
		
		Luxe.camera.shake(3, true);
	}
	
}