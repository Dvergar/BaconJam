
import luxe.Vector;
import luxe.Input;
import luxe.Text;
import luxe.Color;
import luxe.Rectangle;
import luxe.Sprite;
import phoenix.Texture.FilterType;
import phoenix.geometry.LineGeometry;
import phoenix.geometry.RectangleGeometry;



class Main extends luxe.Game
{
    var player:Player;
    var line:LineGeometry;
	public var input:Vector;
	public var mousePos:Vector = new Vector(0,0);

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
		mousePos = e.pos.clone();
        line.p1 = mousePos;
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

        // LINE OF SIGHT MOVE - TARGET
        line.p0 = new Vector(player.pos.x, player.pos.y);

        // UPDATE EVENT DISPATCH
        //Luxe.events.fire('update', dt);
		Luxe.draw.text( {
			immediate : true,
			pos: new Vector(0,Luxe.screen.h-30),
			text: Math.round( 1/Luxe.debug.dt_average) +" | "+ (Luxe.debug.dt_average+"").substr(0,6),
		});
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