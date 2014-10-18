
import luxe.collision.ShapeDrawerLuxe;
import luxe.collision.shapes.Polygon;
import luxe.collision.shapes.Shape;
import luxe.Vector;
import luxe.Input;
import luxe.Text;
import luxe.Color;
import luxe.Rectangle;
import luxe.Sprite;
import luxe.Quaternion;
import phoenix.Texture.FilterType;
import phoenix.geometry.QuadGeometry;


class Main extends luxe.Game
{
	public var shapes:Array<Shape> = new Array();
    var player:Player;
    var box:QuadGeometry;
	public var input:Vector;
	public var mousePos:Vector = new Vector(0,0);

    override function ready()
    {
		input = new Vector();
		player = new Player(Luxe.screen.mid.x, Luxe.screen.mid.y);
		
		shapes.push(Polygon.rectangle(0, 0, Luxe.screen.w, 20, false));
		shapes.push(Polygon.rectangle(0, Luxe.screen.h-20, Luxe.screen.w, 20, false));
		shapes.push(Polygon.rectangle(0, 0, 20, Luxe.screen.h, false));
		shapes.push(Polygon.rectangle(Luxe.screen.w-20, 0, 20, Luxe.screen.h, false));
    }

    override function onmousemove(e:MouseEvent)
		mousePos = e.pos.clone();

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
        // INPUT UPDATE
        input.set_xy(0, 0);
        if(upPressed) input.y-=1;
        if(downPressed) input.y+=1;
        if(leftPressed) input.x-=1;
        if (rightPressed) input.x += 1;
        input.normalize();

        // LINE OF SIGHT
        var width = 16;
        var angle = mousePos.rotationTo(player.pos);
        var distance = Math.sqrt(Math.pow((mousePos.x - player.pos.x), 2)
                               + Math.pow((mousePos.y - player.pos.y), 2));

        box = Luxe.draw.box({
            x: player.pos.x, y: player.pos.y,
            w: width,
            h: distance,
            immediate: true,
            origin: new Vector(width / 2, 0),
            rotation: new Quaternion().setFromEuler(
                            new Vector(0,0,angle).radians()),
            color: new Color(1, 1, 1, 0.2).rgb(0x737178),
        });
		
		//display FPS
		Luxe.draw.text( {
			immediate : true,
			pos: new Vector(0,Luxe.screen.h-30),
			text: Math.round( 1/Luxe.debug.dt_average) +" | "+ (Luxe.debug.dt_average+"").substr(0,6),
		});
		
		
		#if debug
		for (shape in shapes)
		{
			new ShapeDrawerLuxe().drawShape(shape);
		}
		#end
		
    }
}