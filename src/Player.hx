package;
import luxe.components.sprite.SpriteAnimation;
import components.BoxCollider;
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
	var anim:SpriteAnimation;

    public function new(x:Float, y:Float)
    {
        var texture = Luxe.loadTexture('assets/player.png');
        texture.filter = FilterType.nearest;

        super({
            texture: texture,
            pos: new Vector(x, y),
            depth: 1,
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
		
		add(new BoxCollider(50, 50, true));
		get("BoxCollider").render = true;
    }
	
    override function update(dt:Float)
    {
		move(dt);  // Why a function there? :(((
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

		// ANIMATION EVENTS
		if(anim == null) return;  // Meh
		if(input.length == 0)
			anim.animation = 'idle';
		else
			if(anim.animation == 'idle')
				anim.animation = 'walk';
	}
	
}
