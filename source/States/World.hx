package;

import flixel.addons.display.FlxBackdrop;
import MapReader.RoomData;
import MapReader.MapData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;

class World extends FlxState
{
    public var screencam : FlxCamera;
    public var hudcam : FlxCamera;

    public var platforms : FlxGroup;
    public var solids : FlxGroup;
    public var oneways : FlxGroup;

    var tilemapBG : FlxTilemap;
    var tilemapFG : FlxTilemap;

    public var player : Player;

    var mouseTile : FlxSprite;

    var label : flixel.text.FlxBitmapText;

    override public function create() : Void
    {
        FlxG.mouse.useSystemCursor = true;
        FlxG.scaleMode = new flixel.system.scaleModes.PixelPerfectScaleMode();

        var mapReader : MapReader = new MapReader();
        mapReader.read("whatever");
        var mapData : MapData = mapReader.mapData;
        var room : RoomData = mapData.rooms[0];

        var bg = new flixel.addons.display.FlxBackdrop("assets/images/bg.png");//,1, 1, false, false);
        // bg.cameras = [screencam];
        add(bg);

        solids = new FlxGroup();
        add(solids);

        tilemapBG = new FlxTilemap();
        tilemapBG.loadMapFromArray(room.tiles.bg, room.columns, room.rows, "assets/images/tileset.png", 7, 14);
        tilemapBG.color = mapReader.color(room.colors[1]);
        add(tilemapBG);

        tilemapFG = new FlxTilemap();
        tilemapFG.loadMapFromArray(room.tiles.fg, room.columns, room.rows, "assets/images/tileset.png", 7, 14);
        tilemapFG.color = mapReader.color(room.colors[2]);
        add(tilemapFG);

        oneways = new FlxGroup();
        add(oneways);

        platforms = new FlxGroup();
        platforms.add(solids);
        platforms.add(oneways);

        solids.add(new Solid(0, 14*10, 1400, 14, this));

        oneways.add(new Solid(112, 14*6, 14*5, 4, this));

        player = new Player(0, 0, this);
        add(player);

        setupCameras();
        setupHUD();

        var grid : Grid = new Grid(this);
        grid.cameras = [screencam];
        add(grid);

        screencam.follow(player, flixel.FlxCamera.FlxCameraFollowStyle.PLATFORMER);
        bg.cameras = [screencam];

        super.create();

        // DEBUG
        mouseTile = new FlxSprite(0, 0);
        // mouseTile.offset.set(7, 0);
        mouseTile.setSize(14, 14);
        mouseTile.makeGraphic(14, 14, 0x00000000);
        // flixel.util.FlxSpriteUtil.drawRect(mouseTile, 1, 1, 12, 12, 0x00FFFFFF, {thickness: 1, color: 0xFFFFFFFF});
        flixel.util.FlxSpriteUtil.drawCircle(mouseTile, 7, 7, 2, 0xFFFFFFFF);
        // add(mouseTile);
        mouseTile.scrollFactor.set(0, 0);
        mouseTile.cameras = [hudcam];

        label = text.PixelText.New(0, 0, "HELLO");
        label.cameras = [hudcam];
        label.scrollFactor.set(0, 0);
        add(label);
    }

    function setupCameras()
    {
        // FlxG.camera.bgColor = 0xFFFF00FF;
        // FlxG.cameras.list[0].bgColor = 0xFFFF00FF;

        screencam = new FlxCamera(96, 12, 216, 156);
        // screencam.bgColor = 0xFFFFFF00;
        screencam.setScale(2, 1);
        // screencam.setScrollBounds(0, 0, tilemap.width*2, tilemap.height*2);

        hudcam = new flixel.FlxCamera(0, 0, 320, 200, 1);
        hudcam.bgColor = 0x00000000;
        hudcam.scroll.set(-1000, -1000);

        FlxG.cameras.add(screencam);
        FlxG.cameras.add(hudcam);
    }

    function setupHUD()
    {
        var hud : FlxSprite = new FlxSprite(0, 0, "assets/images/temp-hud.png");
        hud.scrollFactor.set(0, 0);
        // hud.alpha = 0.2;
        hud.cameras = [hudcam];
        add(hud);

        text.PixelText.Init();
        var text : flixel.text.FlxBitmapText = text.PixelText.New(12, 36, "Bananas\nWhatever\nDandelion\nBig lion\nRock monster\nSkeleton\nSkele throw");
        text.scrollFactor.set(0, 0);
        text.cameras = [hudcam];
        add(text);
    }

    override public function update(elapsed : Float) : Void
    {
        if (FlxG.keys.pressed.SPACE)
        {
            beginSlowdown();
        }
        else
        {
            endSlowdown();
        }

        var cx : Float = FlxG.mouse.screenX + 2;
        var cy : Float = FlxG.mouse.screenY - 7;

        var wx : Float = Std.int(cx/screencam.scaleX + screencam.scroll.x);
        var wy : Float = Std.int(cy + screencam.scroll.y);

        /*var x : Float = screencam.x + Std.int((mx - screencam.scroll.x) / 7)*7;
        var y : Float = screencam.y + Std.int((my - screencam.scroll.y) / 14)*14;*/
        var x = wx;
        var y = wy;

        mouseTile.x = cx; Std.int(cx/14)*14;
        mouseTile.y = cy; Std.int(cy/14)*14;

        label.text = "c: " + cx + ", " + cy + "\n" +
                     "s: " + screencam.scroll + "\n" +
                     "w: " + wx + ", " + wy + "\n" +
                     "m: " + mouseTile.x + ", " + mouseTile.y;

        if (FlxG.mouse.justPressed)
        {
            if (FlxG.keys.pressed.ALT)
                oneways.add(new Solid(Std.int(x / 7)*7, Std.int(y / 14)*14, 7, 4, this));
            else
            {
                var s = new Solid(Std.int(x / 7)*7, Std.int(y / 14)*14, 7, 14, this);
                solids.add(s);
                trace(s.x, s.y);
            }
        }

        /*if (x >= tilemap.x && x < tilemap.x+tilemap.width && y >= tilemap.y && y < tilemap.y+tilemap.width)
        {
            if (FlxG.keys.pressed.ZERO)
                tilemap.setTile(Std.int(x / 7), Std.int(y / 14), 0);
            else if (FlxG.keys.pressed.ONE)
                tilemap.setTile(Std.int(x / 7), Std.int(y / 14), 1);
            else if (FlxG.keys.pressed.TWO)
                tilemap.setTile(Std.int(x / 7), Std.int(y / 14), 2);
            else if (FlxG.keys.pressed.THREE)
                tilemap.setTile(Std.int(x / 7), Std.int(y / 14), 3);
            else if (FlxG.keys.pressed.FOUR)
                tilemap.setTile(Std.int(x / 7), Std.int(y / 14), 4);
            else if (FlxG.keys.pressed.FIVE)
                tilemap.setTile(Std.int(x / 7), Std.int(y / 14), 5);
            else if (FlxG.keys.pressed.SIX)
                tilemap.setTile(Std.int(x / 7), Std.int(y / 14), 6);
            else if (FlxG.keys.pressed.SEVEN)
                tilemap.setTile(Std.int(x / 7), Std.int(y / 14), 7);
            else if (FlxG.keys.pressed.EIGHT)
                tilemap.setTile(Std.int(x / 7), Std.int(y / 14), 8);
            else if (FlxG.keys.pressed.NINE)
                tilemap.setTile(Std.int(x / 7), Std.int(y / 14), 9);
        }*/

        super.update(elapsed);
    }

    public function beginSlowdown() : Void
    {
        forEachAlive(function(entity : FlxBasic) {
            if (Std.is(entity, Entity))
            {
                cast(entity, Entity).beginSlowdown();
            }
        }, true);
    }

    public function endSlowdown() : Void
    {
        forEachAlive(function(entity : FlxBasic) {
            if (Std.is(entity, Entity))
            {
                cast(entity, Entity).endSlowdown();
            }
        }, true);
    }
}
