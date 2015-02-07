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
	var k:Float = 0;
	
	public function new(?_options:ComponentOptions) 
	{
		super(_options);

		// SPRITE
		var texture = Luxe.loadTexture('assets/weapon.png');
        texture.filter = FilterType.nearest;
        sprite = new Sprite({
            texture : texture,
            pos : new Vector( Luxe.screen.w/2, Luxe.screen.h/2 ),
            depth : 2,
        });

		texture.onload = function(f)
		{
	        sprite.origin = new Vector(0, texture.height/2);
		}

		// AUDIO
		Luxe.audio.create('assets/161862__antistatikk__balloon-bass-12.wav', 'boom');
	}
	
	override public function init() 
	{
		super.init();
		e = cast entity;
	}
	
	override public function update(dt:Float) 
	{
		k+= 0.7;
		super.update(dt);
		sinceLastShoot += dt;
		if (sinceLastShoot > (1 / fireRate) && shooting)
		{	
			fire();
			sinceLastShoot = 0;
		}

		sprite.pos.x = e.pos.x + 0;
		sprite.pos.y = e.pos.y + 10;

		// WEAPON WOBBLE
		if(LuxeApp._game.input.length != 0)
			sprite.pos.y = e.pos.y + 10 + Math.cos(k) * 3;

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
		
		// KNOCKBACK
		e.pos.subtract(direction.clone().normalize().multiplyScalar(1.5));

		// SHAKE
		// Luxe.camera.shake(3, true);

		// AUDIO
		Luxe.audio.play('boom');
	}
	
}