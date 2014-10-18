package components;

import entities.Bullet;
import luxe.Component;
import luxe.options.ComponentOptions;
import luxe.Sprite;
import luxe.Vector;

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
	var sinceLastShoot:Float = 0;
	
	public function new(?_options:ComponentOptions) 
	{
		super(_options);
	}
	
	override public function init() 
	{
		super.init();
		sprite = cast entity;
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
	}
	
	private function fire()
	{
		new Bullet(sprite.pos.x, sprite.pos.y, direction);
	}
	
}