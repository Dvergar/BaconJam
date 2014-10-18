
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
    }

    public function moveUp(dt:Float)
        sprite.pos.y -= SPEED * dt;

    public function moveDown(dt:Float)
        sprite.pos.y += SPEED * dt;

    public function moveLeft(dt:Float)
    {
        sprite.pos.x -= SPEED * dt;
        sprite.flipx = true;
    }

    public function moveRight(dt:Float)
    {
        sprite.pos.x += SPEED * dt;
        sprite.flipx = false;
    }
}


class Main extends luxe.Game
{
    var player:Player;
    var line:LineGeometry;

    override function ready()
    {
        player = new Player(Luxe.screen.mid.x, Luxe.screen.mid.y);
        line = Luxe.draw.line({
            p0: new Vector(0, Luxe.screen.h/2),
            p1: new Vector(Luxe.screen.w, Luxe.screen.h/2),
            color: new Color().rgb(0x737178),
        });
    }

    override function onmousemove(e:MouseEvent)
    {
        line.p0 = new Vector(player.sprite.pos.x, player.sprite.pos.y);
        line.p1 = new Vector(e.pos.x, e.pos.y);
    }

    var upPressed = false;
    var downPressed = false;
    var leftPressed = false;
    var rightPressed = false;

    override function onkeyup(e:KeyEvent)
    {
        if(e.keycode == Key.key_w)
            upPressed = false;

        if(e.keycode == Key.key_s)
            downPressed = false;

        if(e.keycode == Key.key_a)
            leftPressed = false;

        if(e.keycode == Key.key_d)
            rightPressed = false;

    }

    override function onkeydown(e:KeyEvent)
    {
        if(e.keycode == Key.key_w)
            upPressed = true;

        if(e.keycode == Key.key_s)
            downPressed = true;

        if(e.keycode == Key.key_a)
            leftPressed = true;

        if(e.keycode == Key.key_d)
            rightPressed = true;
    }

    override function update(dt:Float)
    {
        if(upPressed) player.moveUp(dt);
        if(downPressed) player.moveDown(dt);
        if(leftPressed) player.moveLeft(dt);
        if(rightPressed) player.moveRight(dt);
    }
}