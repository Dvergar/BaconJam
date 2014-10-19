package;
import luxe.components.sprite.SpriteAnimation;
import components.BoxCollider;
import components.ShootComponent;
import luxe.Input.MouseButton;
import luxe.Sprite;
import luxe.Text;
import luxe.tween.Actuate;
import luxe.Vector;
import phoenix.Texture.FilterType;

/**
 * ...
 * @author 
 */
class Player extends Sprite
{
	public static var MAX_HEALTH:Int = 100;
	public var health:Float=100;
    static inline var SPEED:Int = 350;
	var fireComponent:ShootComponent;
	var anim:SpriteAnimation;

    public function new(x:Float, y:Float)
    {
        var texture = Luxe.loadTexture('assets/player.png');
        texture.filter = FilterType.nearest;

        // SPRITE
        super({
            texture: texture,
            pos: new Vector(x, y),
            depth: 2,
			name: "player",
			size : new Vector(64, 64),
        });

        texture.onload = function(t)
        {
	        anim = new SpriteAnimation({ name:'anim' });
	        add(anim);

	        var animation_json = '
	            {
	                "walk" : {
	                    "frame_size":{ "x":"64", "y":"64" },
	                    "frameset": ["1-3"],
	                    "pingpong":"false",
	                    "loop": "true",
	                    "speed": "18"
	                },
	                "idle" : {
	                    "frame_size":{ "x":"64", "y":"64" },
	                    "frameset": ["1"],
	                    "pingpong":"false",
	                    "loop": "true",
	                    "speed": "18"
	                }
	            }
	        ';

	        anim.add_from_json( animation_json );
	        anim.animation = 'walk';
	        anim.play();
    	}

        Luxe.events.listen('update', update);
		
		fireComponent = new ShootComponent();
		fireComponent.fireRate = 30;
		add(fireComponent);
		
		add(new BoxCollider(PLAYER, 50, 50, [LuxeApp._game.colliders], true));
		// get("BoxCollider").render = true;
    }
	
    override function update(dt:Float)
    {
		move(dt);  // Why a function there? :(((
		fireComponent.shooting = Luxe.input.mousedown(1);
		fireComponent.direction = Vector.Subtract(LuxeApp._game.mousePos, Luxe.screen.mid).normalized;
		health += dt;
		if (health > MAX_HEALTH)
			health = MAX_HEALTH;
    }

	public function move(dt:Float) 
	{
		// APPLY MOVEMENT
		var input = LuxeApp._game.input;
		pos.add(input.multiplyScalar( SPEED * dt));

		// FLIP SPRITE
		var worldMousePos = Luxe.camera.screen_point_to_world(LuxeApp._game.mousePos);
		if(worldMousePos.x < pos.x)
			flipx = true;
		else
			flipx = false;

		// ANIMATION EVENTS
		if(anim == null) return;  // Meh
		if(input.length == 0)
			anim.animation = 'idle';
		else
			if(anim.animation == 'idle')
				anim.animation = 'walk';

		var camx = pos.x - Luxe.screen.w / 2;
		var camy = pos.y - Luxe.screen.h / 2;

		var dx = camx - Luxe.camera.pos.x;
		var dy = camy - Luxe.camera.pos.y;

		Luxe.camera.pos.x += Std.int(dx * 0.3);
		Luxe.camera.pos.y += Std.int(dy * 0.3);
	}
	
	public function hurt(damage:Int)
	{
		health -= damage;
		Actuate.tween(color, 1, { r:1, g:0, b:0 } ).onComplete(function() { Actuate.tween(color, 1, { r:1, g:1, b:1 } ); } );
		if (health <= 0)
		{
			health = 0;
			die();
		}
	}
	
	function die() 
	{
		trace("YOU DIED");
		destroy();
	}
	
}
