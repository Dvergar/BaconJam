package entities;
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
		
		this.rotation.setFromAxisAngle(new Vector(0, 0, 1), Math.atan2(direction.y, direction.x) -0.1 + Math.random()*0.2);
	}
	
	override public function update(dt:Float) 
	{
		super.update(dt);
		var direction = new Vector(1, 0, 0).applyQuaternion(rotation);
		pos.x += direction.x * speed * dt;
		pos.y += direction.y * speed * dt;
	}
	
}