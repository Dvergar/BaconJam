package entities;
import components.BoxCollider;
import luxe.Quaternion;
import luxe.Sprite;
import luxe.Vector;
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
        this.direction = direction.normalized;
		var texture = Luxe.loadTexture('assets/bullet.png');
        texture.filter = FilterType.nearest;
		
        super({
            texture: texture,
            pos: new Vector(x, y),
            depth: 1,
        });
		
		this.rotation.setFromAxisAngle(new Vector(0, 0, 1), Math.atan2(direction.y, direction.x) -0.1 + Math.random() * 0.2);
		collider = new BoxCollider(10, 10, false);
		add(collider);
	}
	
	override public function init() 
	{
		super.init();
		trace(collider.shape);
		LuxeApp._game.bulletShapes.push(collider.shape);
	}
		
	override public function update(dt:Float) 
	{
		super.update(dt);
		var direction = new Vector(1, 0, 0).applyQuaternion(rotation);
		pos.x += direction.x * speed * dt;
		pos.y += direction.y * speed * dt;
		
		if (collider.collides)
		{
			destroy();
		}
	}
	
}