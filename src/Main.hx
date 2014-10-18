
import luxe.Vector;
import luxe.Input;
import luxe.Text;
import luxe.Color;
import luxe.Rectangle;
import luxe.Sprite;
import phoenix.Texture.FilterType;


class Player
{
	public var sprite:Sprite;

	public function new(x:Float, y:Float)
	{
        var texture = Luxe.loadTexture('assets/player.png');
        texture.filter = FilterType.nearest;

        sprite = new Sprite({
            texture : texture,
            pos : new Vector(x, y),
        });
	}
}


class Main extends luxe.Game
{
	var player:Player;

    override function ready()
    {
    	player = new Player(Luxe.screen.mid.x, Luxe.screen.mid.y);
    }

    override function update(dt:Float)
    {
    	player.sprite.pos.x += 1;
    }
}