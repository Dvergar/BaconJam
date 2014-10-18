package;
import luxe.Sprite;
import luxe.Vector;
import phoenix.Texture.FilterType;

/**
 * ...
 * @author 
 */
class Player extends Sprite
{
    static inline var SPEED:Int = 350;

    public function new(x:Float, y:Float)
    {
        var texture = Luxe.loadTexture('assets/player.png');
        texture.filter = FilterType.nearest;

        super({
            texture : texture,
            pos : new Vector(x, y),
        });

        Luxe.events.listen('update', update);

    }
	
    override function update(dt:Float)
    {
		move(dt);
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
