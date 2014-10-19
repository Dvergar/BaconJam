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
	public var fireRate:Float = 5;
	public var shooting:Bool = false;
	var sprite:Sprite;
	var e:Sprite;
	var sinceLastShoot:Float = 0;
	
	public function new(?_options:ComponentOptions) 
	{
		super(_options);

		// Yeah yeah, can probably be in its own component
		var texture = Luxe.loadTexture('assets/weapon.png');
		texture.onload = function(f)
		{
	        texture.filter = FilterType.nearest;

	        sprite = new Sprite({
	            texture : texture,
	            pos : new Vector( Luxe.screen.w/2, Luxe.screen.h/2 ),
	            origin: new Vector(0, texture.height/2),
	            depth : 1,
	        });
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

		if(sprite == null) return;  // Super meh
		sprite.pos.x = e.pos.x ;
		sprite.pos.y = e.pos.y;

		var angle = sprite.pos.rotationTo(LuxeApp._game.mousePos);
		sprite.rotation = new Quaternion().setFromEuler(new Vector(0,0, angle - 90).radians());
	}
	
	private function fire()
	{
		new Bullet(e.pos.x, e.pos.y, direction);
		Luxe.camera.shake(3,true);
	}
	
}