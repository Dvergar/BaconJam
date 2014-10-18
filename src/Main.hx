
import luxe.Vector;
import luxe.Input;
import luxe.Text;
import luxe.Color;
import luxe.Rectangle;
import luxe.Sprite;
import phoenix.Texture.FilterType;


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

    override function ready()
    {
        player = new Player(Luxe.screen.mid.x, Luxe.screen.mid.y);
    }

    var upPressed = false;
    var downPressed = false;
    var leftPressed = false;
    var rightPressed = false;

    override function onkeyup(e:KeyEvent)
    {
        if(e.keycode == Key.key_z)
            upPressed = false;

        if(e.keycode == Key.key_s)
            downPressed = false;

        if(e.keycode == Key.key_q)
            leftPressed = false;

        if(e.keycode == Key.key_d)
            rightPressed = false;

    }

    override function onkeydown(e:KeyEvent)
    {
        if(e.keycode == Key.key_z)
            upPressed = true;

        if(e.keycode == Key.key_s)
            downPressed = true;

        if(e.keycode == Key.key_q)
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