package;
import components.ShootComponent;
import luxe.Input.MouseButton;
import luxe.Sprite;
import luxe.Text;
import luxe.Vector;
import phoenix.Texture.FilterType;

/**
 * ...
 * @author 
 */
class Player extends Sprite
{
    static inline var SPEED:Int = 350;
	var fireComponent:ShootComponent;

    public function new(x:Float, y:Float)
    {
        var texture = Luxe.loadTexture('assets/player.png');
        texture.filter = FilterType.nearest;

        super({
            texture: texture,
            pos: new Vector(x, y),
            depth: 1,
        });

        Luxe.events.listen('update', update);
		
		fireComponent = new ShootComponent();
		fireComponent.fireRate = 30;
		add(fireComponent);
    }
	
    override function update(dt:Float)
    {
		move(dt);
		fireComponent.shooting = Luxe.input.mousedown(1);

		fireComponent.direction = Vector.Subtract(LuxeApp._game.mousePos,pos).normalized;
    }

	public function move(dt:Float) 
	{
		var input = LuxeApp._game.input;
		pos.add(input.multiplyScalar( SPEED * dt));
		if (input.x < 0)
			flipx = true;
		if (input.x > 0)
			flipx = false;
	}
	
}
