package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;

import MapReader.RoomData;
import MapReader.MapData;

class World extends FlxState
{
    var mapReader : MapReader;
    var mapData : MapData;
    var roomData : RoomData;
    var cursorX : Int;
    var cursorY : Int;

    var playerData : PlayerData;

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

    public function new(PlayerData : PlayerData)
    {
        super();

        playerData = PlayerData;
        if (playerData == null)
            playerData = {
                x: 32,
                y: 32,
                hspeed: 0,
                vspeed: 0,
                screenOffsetX: 0,
                screenOffsetY: 0
            };
    }

    override public function create() : Void
    {
        FlxG.mouse.useSystemCursor = true;
        FlxG.scaleMode = new flixel.system.scaleModes.PixelPerfectScaleMode();

        mapReader = new MapReader();
        mapReader.read("whatever");
        mapData = mapReader.mapData;
        roomData = mapReader.getRoom("" + GameStatus.room);

        // var bg = new flixel.addons.display.FlxBackdrop("assets/images/bg.png");//,1, 1, false, false);
        // bg.cameras = [screencam];
        var bg = new FlxSprite(0, 0);
        bg.makeGraphic(210, 156*2, mapReader.color(roomData.colors[0]));
        // bg.scrollFactor.set(0, 0);
        add(bg);

        solids = new FlxGroup();
        add(solids);

        tilemapBG = new FlxTilemap();
        tilemapBG.loadMapFromArray(roomData.tiles.bg, roomData.columns, roomData.rows, "assets/images/tileset.png", 7, 14);
        tilemapBG.color = mapReader.color(roomData.colors[1]);
        add(tilemapBG);

        tilemapFG = new FlxTilemap();
        tilemapFG.loadMapFromArray(roomData.tiles.fg, roomData.columns, roomData.rows, "assets/images/tileset.png", 7, 14);
        tilemapFG.color = mapReader.color(roomData.colors[2]);
        add(tilemapFG);

        oneways = new FlxGroup();
        add(oneways);

        platforms = new FlxGroup();
        platforms.add(solids);
        platforms.add(oneways);

        mapReader.buildSolids(roomData, this, solids, oneways);

        // Reposition player after transition
        var b : Int = 3;
        if (playerData.x < b)
            playerData.x = roomData.columns*7-3;
        else if (playerData.x > 15*7-b)
            playerData.x = 0;
        else if (playerData.y < b)
            playerData.y = roomData.rows*14-3;
        else if (playerData.y > 11*14-b)
            playerData.y = 0;

        playerData.x += playerData.screenOffsetX*15*7;
        playerData.y += playerData.screenOffsetY*11*14;

        // TODO: Increase vspeed if coming from below
        
        player = new Player(playerData, this);
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

        screencam = new FlxCamera(96, 12, 210, 156, 1);
        screencam.bgColor = 0xFFFFFF00;
        screencam.setScale(2, 1);
        trace(roomData.columns*7);
        // screencam.setScrollBoundsRect(-96/2-6, -1, 210*2+(96/2)-96-3*7+6/2, 156);
        // 366
        screencam.setScrollBoundsRect(0-210/2/2, 0, Math.max(roomData.columns*7*2+210/2/2-54-54-54+6-2, 210), Math.max(roomData.rows*14-2, 156));
        trace(screencam.minScrollX, screencam.maxScrollX, screencam.minScrollY, screencam.maxScrollY);

        hudcam = new flixel.FlxCamera(0, 0, 320, 200, 1);
        hudcam.bgColor = 0x00000000;
        hudcam.scroll.set(-1000, -1000);

        FlxG.cameras.add(screencam);
        FlxG.cameras.add(hudcam);
    }

    function setupHUD()
    {
        var hud : FlxSprite = new FlxSprite(0, 0, "assets/images/temp-hud.png");
        // hud.alpha = 0.2;
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

        updateCursor();

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

        label.text = "p: " + player.x + ", " + player.y + "\n" +
                     "c: " + cursorX + ", " + cursorY + "\n" +
                     "s: " + screencam.x + ", " + screencam.y + "\n" +
                     "s: " + screencam.scroll + "\n" +
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

        super.update(elapsed);

        var tx : Int = cursorX;
        var ty : Int = cursorY;
        
        if (player.x < -3)
            tx -= 1;
        else if (player.x > roomData.columns*7-3)
            tx += 1;
        else if (player.y < -3)
            ty -= 1;
        else if (player.y > roomData.rows*14-3)
            ty += 1;
        
        if (tx != cursorX || ty != cursorY)
        {
            var newRoomId : Null<Int> = mapData.grid[tx+ty*mapData.size.x];
            trace("Moving to " + newRoomId);
            if (newRoomId != null && newRoomId != GameStatus.room) 
            {
                var newRoom : RoomData = mapReader.getRoom(""+newRoomId);
                GameStatus.room = newRoomId;

                var nextPlayerData : PlayerData = {
                    x: player.x,
                    y: player.y,
                    hspeed : player.hspeed,
                    vspeed : player.vspeed,
                    screenOffsetX: (tx-cursorX != 0 ? 0 : newRoom.gridX - roomData.gridX),
                    screenOffsetY: (ty-cursorY != 0 ? 0 : newRoom.gridY - roomData.gridY)
                };

                FlxG.switchState(new World(nextPlayerData));
            }
        }
    }

    function updateCursor()
    {
        cursorX = roomData.gridX + Std.int((player.x / (7*15)) % (7*15));
        cursorY = roomData.gridY + Std.int((player.y / (14*11)) % (14*11));
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

typedef PlayerData = {
    var x : Float;
    var y : Float;
    var hspeed : Float;
    var vspeed : Float;
    var screenOffsetX : Int;
    var screenOffsetY : Int;
}