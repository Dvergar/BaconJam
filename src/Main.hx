
import luxe.Vector;
import luxe.Input;
import luxe.Text;
import luxe.Color;
import luxe.Rectangle;
import luxe.Sprite;
import phoenix.Texture.FilterType;
import phoenix.geometry.LineGeometry;
import phoenix.geometry.RectangleGeometry;


class Player
{
    static inline var SPEED:Int = 350;
    public var sprite:Sprite;

    public function new(x:Float, y:Float)
    {
        var texture = Luxe.loadTexture('assets/player.png');
        texture.filter = FilterType.nearest;

        sprite = new Sprite({
            texture : texture,
            pos : new Vector(x, y),
        });

        Luxe.events.listen('update', update);
    }
	
    function update(dt:Float)
    {

    }

	public function move(input:Vector,dt:Float) 
	{
		sprite.pos.add(input.multiplyScalar( SPEED * dt));
		if (input.x < 0)
			sprite.flipx = true;
		if (input.x > 0)
			sprite.flipx = false;
	}
}


class Main extends luxe.Game
{
    var player:Player;
    var line:LineGeometry;
	var input:Vector;

    override function ready()
    {
		input = new Vector();
        player = new Player(Luxe.screen.mid.x, Luxe.screen.mid.y);
        line = Luxe.draw.line({
            p0: new Vector(0, Luxe.screen.h/2),
            p1: new Vector(Luxe.screen.w, Luxe.screen.h/2),
            color: new Color().rgb(0x737178),
        });
    }

    override function onmousemove(e:MouseEvent)
    {
        // LINE OF SIGHT MOVE - TARGET
        line.p1 = new Vector(e.pos.x, e.pos.y);
    }

    var upPressed = false;
    var downPressed = false;
    var leftPressed = false;
    var rightPressed = false;

    override function onkeyup(e:KeyEvent)
    {
        if(e.keycode == Key.key_w || e.keycode == Key.up)
            upPressed = false;

        if(e.keycode == Key.key_s || e.keycode == Key.down)
            downPressed = false;

        if(e.keycode == Key.key_a || e.keycode == Key.left)
            leftPressed = false;

        if(e.keycode == Key.key_d || e.keycode == Key.right)
            rightPressed = false;

    }

    override function onkeydown(e:KeyEvent)
    {
        if(e.keycode == Key.key_w || e.keycode == Key.up)
            upPressed = true;

        if(e.keycode == Key.key_s || e.keycode == Key.down)
            downPressed = true;

        if(e.keycode == Key.key_a || e.keycode == Key.left)
            leftPressed = true;

        if(e.keycode == Key.key_d || e.keycode == Key.right)
            rightPressed = true;
    }

    override function update(dt:Float)
    {

		updateInput();
		player.move(input,dt);

        // LINE OF SIGHT MOVE - TARGET
        line.p0 = new Vector(player.sprite.pos.x, player.sprite.pos.y);

        // UPDATE EVENT DISPATCH
        Luxe.events.fire('update', dt);
    }
	
	
	function updateInput() 
	{
		input.set_xy(0, 0);
		if(upPressed) input.y-=1;
        if(downPressed) input.y+=1;
        if(leftPressed) input.x-=1;
        if (rightPressed) input.x += 1;
		input.normalize();
	}
}