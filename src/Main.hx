
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

        tiles = parseMap({data:map, skip: ["char", "shadows"]});
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

            demTiles.add_layer({name: layer.name, layer: Std.int(layer.number * -1), opacity: 1, visible: true});
            demTiles.add_tiles_fill_by_id(layer.name, 0);  // Gnn

            var tiles:Array<Dynamic> = layer.tiles;
            for(tile in tiles)
                demTiles.tile_at(layer.name, tile.x, tile.y).id = tile.tile + 1;
        }

        demTiles.display({scale:1});
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
	public var shapes:Array<Shape> = new Array();
	public var enemyShapes:Array<Shape> = new Array();
    public var bulletShapes:Array<Shape> = new Array();
	public var worldShapes:Array<Shape> = new Array();
    public var player:Player;
	public var input:Vector;
	public var mousePos:Vector = new Vector(0,0);
    var map:BaconMap;
	var shit:Array<Dynamic> = new Array();

    override function ready()
    {
		input = new Vector();
		player = new Player(Luxe.screen.mid.x, Luxe.screen.mid.y);
        map = new BaconMap();
		shapes.push(Polygon.rectangle(0, 0, Luxe.screen.w, 20, false));
		shapes.push(Polygon.rectangle(0, Luxe.screen.h-20, Luxe.screen.w, 20, false));
		shapes.push(Polygon.rectangle(0, 0, 20, Luxe.screen.h, false));
		shapes.push(Polygon.rectangle(Luxe.screen.w - 20, 0, 20, Luxe.screen.h, false));
		
		new Enemy(100, 100);

        for(posx in 0...map.TILES_WIDE)
            for(posy in 0...map.TILES_HIGH)
                if(map.collisionMap[posx][posy])
                    shapes.push(Polygon.rectangle(posx * BaconMap.TILESIZE, posy * BaconMap.TILESIZE, BaconMap.TILESIZE, BaconMap.TILESIZE, false));
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
	
	public function rockFall(x:Float,y:Float)
	{
		shit.push(new FallingRock(x, y));
	}
}