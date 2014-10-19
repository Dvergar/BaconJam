
import entities.Enemy;
import entities.FallingRock;
import luxe.collision.ShapeDrawerLuxe;
import luxe.collision.shapes.Polygon;
import luxe.collision.shapes.Shape;
import luxe.Parcel;
import luxe.ParcelProgress;
import luxe.Vector;
import luxe.Input;
import luxe.Text;
import luxe.Color;
import luxe.Rectangle;
import luxe.Sprite;
import luxe.tilemaps.Tilemap;
import luxe.importers.tiled.TiledMap;
import luxe.Quaternion;
import phoenix.Texture.FilterType;
import phoenix.geometry.QuadGeometry;
import entities.Bullet;


typedef Tile = {x:Int, y:Int};
class BaconMap  // Damn it, can't call it Map or Tilemap
{
    public static inline var TILESIZE = 64;
    public var collisionMap:Array<Array<Bool>>;
    public var nestMap:Array<Tile>;
    public var TILES_HIGH:Int;
    public var TILES_WIDE:Int;
    var tiles:Tilemap;

    public function new()
    {
        // IMPORT PYXELEDIT MAP
        var map = haxe.Json.parse(haxe.Resource.getString("map"));
        TILES_HIGH = map.tileshigh;
        TILES_WIDE = map.tileswide;

        tiles = parseMap({data:map, skip: ["char", "nests"]});
        tiles.layers.get("shadows").opacity = 0.1;
        tiles.display({});
        collisionMap = getMapFrom(map, "collisionmap");
        nestMap = getArrayFrom(map, "nests");
    }

    function parseMap(args:{data:Dynamic, skip:Array<String>})
    {
        // LUXE TILEMAP
        var demTiles = new Tilemap({
            x           : 0,
            y           : 0,
            w           : TILES_WIDE,
            h           : TILES_HIGH,
            tile_width  : TILESIZE,
            tile_height : TILESIZE,
            orientation : TilemapOrientation.ortho,
        });

        demTiles.add_tileset({
            name: "yay",
            texture: Luxe.loadTexture('assets/tileset.png'),
            tile_width: TILESIZE, tile_height: TILESIZE,
        });

        // PYXEL EDIT MAP PARSING
        var layers:Array<Dynamic> = args.data.layers;
        for(layer in layers)
        {
            if(Lambda.has(args.skip, layer.name)) continue;

            demTiles.add_layer({name: layer.name, layer: Std.int(layer.number * -1)});
            demTiles.add_tiles_fill_by_id(layer.name, 0);  // Gnn

            var tiles:Array<Dynamic> = layer.tiles;
            for(tile in tiles)
                demTiles.tile_at(layer.name, tile.x, tile.y).id = tile.tile + 1;
        }
        return demTiles;
    }

    function getMapFrom(map:Dynamic, layerName:String)
    {
        // DEFAULT THE COLLISIONMAP
        var daMap = new Array();
        for(posx in 0...TILES_WIDE)
        {
            var col = new Array();
            for(posy in 0...TILES_HIGH)
                col.push(false);

            daMap.push(col);
        }

        // APPLY REAL DATA
        var layers:Array<Dynamic> = map.layers;
        for(layer in layers)
        {
            if(layer.name == layerName)
            {
                var tiles:Array<Dynamic> = layer.tiles;
                for(tile in tiles)
                    if(tile.tile != -1) 
                        daMap[tile.x][tile.y] = true;
                break;
            }
        }

        return daMap;
    }

    function getArrayFrom(map:Dynamic, layerName:String)
    {
        // DEFAULT THE COLLISIONMAP
        var array = new Array();

        // APPLY REAL DATA
        var layers:Array<Dynamic> = map.layers;
        for(layer in layers)
        {
            if(layer.name == layerName)
            {
                var tiles:Array<Dynamic> = layer.tiles;
                for(tile in tiles)
                    if(tile.tile != -1)
                    {
                        var daTile:Tile = {x:tile.x, y:tile.y};
                        array.push(daTile);
                    }
                break;
            }
        }

        return array;
    }
}


// Rename ColliderType
enum CollisionType
{
    WORLD;
    ENEMY;
    BULLET;
    PLAYER;
}


// TOREFACTOR - Back to Array<CollisionRekt>;
class Colliders
{
    public var array:Array<CollisionRekt> = new Array();
    public var type:CollisionType;

    public function new(type:CollisionType)
    {
        this.type = type;
    }

    public function push(rekt:CollisionRekt)
        array.push(rekt);

    public function remove(rekt:CollisionRekt)
        array.remove(rekt);

    // NOTIME FOR NOW
    // public function hasNext()
    // {
    //     return array.hasNext();
    // }

    // public function next()
    // {
    //     return array.next();
    // }
}


class CollisionRekt extends Rectangle
{
    public var collisionTypes:Array<CollisionType> = new Array();
    public var type:CollisionType;

    public function new(type:CollisionType, _x:Float=0, _y:Float=0, _w:Float=0, _h:Float=0)
    {
        super(_x, _y, _w, _h);
        this.type = type;
    }
}



class Main extends luxe.Game
{
    public var player:Player;
	public var input:Vector = new Vector();
    public var colliders = new Colliders(WORLD);
    public var enemyColliders = new Colliders(ENEMY);
    public var bulletColliders = new Colliders(BULLET);
	public var mousePos:Vector = new Vector(0, 0);
    public var map:BaconMap;
	public var enemiesKilled:Int = 0;
    var loaded:Bool = false;
	
	var healthBar:QuadGeometry;
	
    override function ready()
	{
           //fetch a list of assets to load from the json file
        var json_asset = Luxe.loadJSON('assets/parcel.json');

            //then create a parcel to load it for us
        var preload = new Parcel();
            preload.from_json(json_asset.json);

            //but, we also want a progress bar for the parcel,
            //this is a default one, you can do your own
        new ParcelProgress({
            parcel      : preload,
            background  : new Color(1,1,1,0.85),
            oncomplete  : assets_loaded
        });

            //go!
        preload.load();

    } //ready
	
    function assets_loaded(_)
    {
		loaded = true;
		player = new Player(Luxe.screen.mid.x, Luxe.screen.mid.y);
        map = new BaconMap();

        function spawnMob()
        {
            var index = Std.random(map.nestMap.length);
            var enemyPos = map.nestMap[index];

            new Enemy(enemyPos.x * BaconMap.TILESIZE,
                      enemyPos.y * BaconMap.TILESIZE);

            Luxe.timer.schedule(2, spawnMob);
        }

        //spawnMob();

        // PUSH COLLIDERS FROM COLLISION MAP
        for(posx in 0...map.TILES_WIDE)
            for(posy in 0...map.TILES_HIGH)
                if(map.collisionMap[posx][posy])
                    colliders.push(new CollisionRekt(WORLD, posx * BaconMap.TILESIZE,
                                                            posy * BaconMap.TILESIZE,
                                                            BaconMap.TILESIZE,
                                                            BaconMap.TILESIZE));
		
		
		Luxe.timer.schedule(1, rockFall);
		Luxe.timer.schedule(1, rockFall);
		Luxe.timer.schedule(1, rockFall);
		Luxe.timer.schedule(1, rockFall);	
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
			
		if (e.keycode == Key.space)
			rockFall();

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
		if (!loaded)
		{
			return; //ugly fix
		}
		
		
		var healthColor:Color = new Color();
		healthColor.r = 1 - (player.health / Player.MAX_HEALTH);
		healthColor.g = (player.health / Player.MAX_HEALTH);
		healthColor.b = 0;
		
		
		//healthbar background
		healthBar = Luxe.draw.box({ 
			x:Luxe.camera.pos.x + 30,
			y:Luxe.camera.pos.y + 30,
			w: 3*Player.MAX_HEALTH,
			h:30,
			color: new Color().rgb(0x999999),
			depth:9,
			immediate:true
		});
		
		//healthbar
		healthBar = Luxe.draw.box({ 
			x:Luxe.camera.pos.x + 30,
			y:Luxe.camera.pos.y + 30,
			w: 3*player.health,
			h:30,
			color: healthColor,
			depth:10,
			immediate:true
		});
		
		//healthbar outline
		Luxe.draw.rectangle({ 
			x:Luxe.camera.pos.x + 30,
			y:Luxe.camera.pos.y + 30,
			w: 300,
			h:30,
			color: new Color().rgb(0xFFFFFF),
			depth:11,
			immediate:true
		});
		
        // INPUT UPDATE
        input.set_xy(0, 0);
        if(upPressed) input.y-=1;
        if(downPressed) input.y+=1;
        if(leftPressed) input.x-=1;
        if (rightPressed) input.x += 1;
        input.normalize();

        // LINE OF SIGHT
        var width = 16;
        var worldMousePos = Luxe.camera.screen_point_to_world(mousePos);
        var angle = mousePos.rotationTo(Luxe.screen.mid);
        var distance = Math.sqrt(Math.pow((Luxe.screen.mid.x - mousePos.x), 2)
                               + Math.pow((Luxe.screen.mid.y - mousePos.y), 2));

        Luxe.draw.box({
            x: player.pos.x, y: player.pos.y,
            w: width,
            h: distance,
            immediate: true,
            origin: new Vector(width / 2, 0),
            rotation: new Quaternion().setFromEuler(
                            new Vector(0,0,angle).radians()),
            color: new Color(1, 1, 1, 0.2).rgb(0x737178),
            depth: 1,
        });
		
		// DISPLAY FPS
		Luxe.draw.text( {
			immediate: true,
			pos: new Vector(Luxe.camera.pos.x,Luxe.camera.pos.y+Luxe.screen.h-30),
			text: Math.round( 1/Luxe.debug.dt_average) +" | "+ (Luxe.debug.dt_average+"").substr(0,6),
		});
		
        // DISPLAY COLLIDERS
		#if debug
		for (rekt in colliders.array)
		{
            Luxe.draw.rectangle({
                x: rekt.x, y : rekt.y,
                w: rekt.w,
                h: rekt.h,
                color: new Color(1, 1 ,1),
                immediate: true,
                depth: 3,
            });
		}

        for (rekt in bulletColliders.array)
        {
            Luxe.draw.rectangle({
                x: rekt.x, y : rekt.y,
                w: rekt.w,
                h: rekt.h,
                color: new Color(1, 1 ,1),
                immediate: true,
                depth: 3,
            });
        }

        for (rekt in enemyColliders.array)
        {
            Luxe.draw.rectangle({
                x: rekt.x, y : rekt.y,
                w: rekt.w,
                h: rekt.h,
                color: new Color(1, 1 ,1),
                immediate: true,
                depth: 3,
            });
        }
		#end
		
		Luxe.draw.text( {
			immediate: true,
            pos: new Vector(Luxe.camera.pos.x + Luxe.screen.mid.x,
                            Luxe.camera.pos.y + 30),
			text: "Remaining enemies: " + (1000000-enemiesKilled),
		});
    }
	
    // Most useless function i've ever seen in my entire life!
	// I was thinking of adding the shadown here, but in the end i added it inside the FallingRock class
	public function rockFall()
	{
		var x:Int;
		var y:Int;
		do {
			x = Std.random(map.TILES_WIDE);
			y = Std.random(map.TILES_HIGH);
		}while (map.collisionMap[x][y]);
		new FallingRock((x+0.5)*BaconMap.TILESIZE, (y+0.5)*BaconMap.TILESIZE);
		//player.hurt(10);
		Luxe.timer.schedule(3+Math.random() * 3, rockFall);
	}
}