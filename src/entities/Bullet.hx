package entities;
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

	public var speed:Float = 100;
    public function new(x:Float, y:Float,direction:Vector)
    {
        this.direction = direction.normalized;
		var texture = Luxe.loadTexture('assets/bullet.png');
        texture.filter = FilterType.nearest;
		
        super({
            texture : texture,
            pos : new Vector(x, y),
        });
		
		this.rotation.setFromAxisAngle(new Vector(0, 0, 1), Math.atan2(direction.y,direction.x));
	}
	
	override public function update(dt:Float) 
	{
		super.update(dt);
		//pos.add(direction.multiplyScalar(speed*dt)); //this doesn't work for some reasons
		pos.x += direction.x * speed * dt;
		pos.y += direction.y * speed * dt;
	}
	
}