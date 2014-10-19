
import entities.Enemy;
import entities.FallingRock;
import luxe.collision.ShapeDrawerLuxe;
import luxe.collision.shapes.Polygon;
import luxe.collision.shapes.Shape;
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


class BaconMap  // Damn it, can't call it Map or Tilemap
{
    public static inline var TILESIZE = 64;
    public var collisionMap:Array<Array<Bool>>;
    public var TILES_HIGH:Int;
    public var TILES_WIDE:Int;
    var tiles:Tilemap;

    public function new()
    {
        // IMPORT PYXELEDIT MAP
        var map = haxe.Json.parse(haxe.Resource.getString("map"));
        TILES_HIGH = map.tileshigh;
        TILES_WIDE = map.tileswide;

        tiles = parseMap({data:map, skip: ["char"]});
        tiles.layers.get("shadows").opacity = 0.1;
        tiles.display({});
        collisionMap = getCollisionMapFrom(map, "collisionmap");
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

    function getCollisionMapFrom(map:Dynamic, layerName:String)
    {
        // DEFAULT THE COLLISIONMAP
        var collisionMap = new Array();
        for(posx in 0...TILES_WIDE)
        {
            var col = new Array();
            for(posy in 0...TILES_HIGH)
                col.push(false);

            collisionMap.push(col);
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
                        collisionMap[tile.x][tile.y] = true;
                break;
            }
        }

        return collisionMap;
    }
}


class Main extends luxe.Game
{
    public var player:Player;
	public var input:Vector;
    public var colliders:Array<Rectangle> = new Array();
    public var enemyColliders:Array<Rectangle> = new Array();
    public var bulletColliders:Array<Rectangle> = new Array();
	public var mousePos:Vector = new Vector(0,0);
    var map:BaconMap;
	var shit:Array<Dynamic> = new Array();

    override function ready()
    {
		input = new Vector();
		player = new Player(Luxe.screen.mid.x, Luxe.screen.mid.y);
        map = new BaconMap();
		new Enemy(100, 100);

        // PUSH COLLIDERS FROM COLLISION MAP
        for(posx in 0...map.TILES_WIDE)
            for(posy in 0...map.TILES_HIGH)
                if(map.collisionMap[posx][posy])
                    colliders.push(new Rectangle(posx * BaconMap.TILESIZE, posy * BaconMap.TILESIZE, BaconMap.TILESIZE, BaconMap.TILESIZE));
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
			rockFall(player.pos.x, player.pos.y);

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
			pos: new Vector(0,Luxe.screen.h-30),
			text: Math.round( 1/Luxe.debug.dt_average) +" | "+ (Luxe.debug.dt_average+"").substr(0,6),
		});
		
        // DISPLAY COLLIDERS
		#if debug
		for (collider in colliders)
		{
            Luxe.draw.rectangle({
                x: collider.x, y : collider.y,
                w: collider.w,
                h: collider.h,
                color: new Color(1, 1 ,1),
                immediate: true,
                depth: 3,
            });
		}
		#end
		
    }
	
	public function rockFall(x:Float,y:Float)
	{
		shit.push(new FallingRock(x, y));
	}
}