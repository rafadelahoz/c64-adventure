package;

import flixel.FlxBasic;
import flixel.text.FlxBitmapText;
import flixel.FlxObject;
import openfl.events.KeyboardEvent;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
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

    public var hudGroup : FlxGroup;

    public var platforms : FlxGroup;
    public var solids : FlxGroup;
    public var oneways : FlxGroup;
    public var ladders : FlxGroup;
    var triggers : FlxGroup;

    var tilemapBG : FlxTilemap;
    var tilemapFG : FlxTilemap;

    public var player : Player;

    var mouseTile : FlxSprite;

    var label : flixel.text.FlxBitmapText;

    public function new(?PlayerData : PlayerData = null)
    {
        super();

        playerData = PlayerData;
        if (playerData == null)
            playerData = {
                x: 32,
                y: 32,
                state : Player.State.Idle,
                facing : FlxObject.RIGHT,
                hspeed: 0,
                vspeed: 0,
                screenOffsetX: 0,
                screenOffsetY: 0,
                leftPressed: false,
                rightPressed: false,
                debug: false
            };
    }

    override public function create() : Void
    {
        mapReader = new MapReader();
        mapReader.read(GameStatus.map + ".json");
        mapData = mapReader.mapData;
        roomData = mapReader.getRoom(GameStatus.room);

        // Checked bg for testing
        // var bg = new flixel.addons.display.FlxBackdrop("assets/images/bg.png");//,1, 1, false, false);
        // bg.cameras = [screencam];
        var bg = new FlxSprite(0, 0);
        bg.makeGraphic(210, 156, mapReader.color(roomData.colors[0]));
        bg.scrollFactor.set(0, 0);
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

        ladders = new FlxGroup();
        add(ladders);

        triggers = new FlxGroup();
        add(triggers);

        platforms = new FlxGroup();
        platforms.add(solids);
        platforms.add(oneways);

        mapReader.buildSolids(roomData, this, solids, oneways, ladders);

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

        // Force an input event given previous state
        // TODO: Generalize this (gamepad, etc)
        if (playerData.leftPressed)
            FlxG.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, 0, 37));
        if (playerData.rightPressed)
            FlxG.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, 0, 39));

        // TODO: Increase vspeed if coming from below
        
        player = new Player(playerData, this);
        add(player);

        /*if (mapReader.color(roomData.colors[1]) == 0xFF000000)
            player.color = mapReader.color(roomData.colors[1]);*/

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
        mouseTile.setSize(14, 14);
        mouseTile.makeGraphic(14, 14, 0x00000000);
        flixel.util.FlxSpriteUtil.drawCircle(mouseTile, 7, 7, 2, 0xFFFFFFFF);
        addHudElement(mouseTile);

        label = text.PixelText.New(0, 0, "HELLO");
        addHudElement(label);
    }

    function setupCameras()
    {
        screencam = new FlxCamera(96, 12, 210, 156, 1);
        screencam.bgColor = 0xFFFFFF00;
        screencam.setScale(2, 1);
        screencam.setScrollBoundsRect(0-210/2/2, 0, Math.max(roomData.columns*7*2+210/2/2-54-54-54+6-2, 210), Math.max(roomData.rows*14-2, 156), true);
        screencam.pixelPerfectRender = true;
        // trace(screencam.minScrollX, screencam.maxScrollX, screencam.minScrollY, screencam.maxScrollY);

        hudcam = new flixel.FlxCamera(0, 0, 320, 200, 1);
        hudcam.bgColor = 0x00000000;
        hudcam.scroll.set(-1000, -1000);
        hudcam.pixelPerfectRender = true;

        FlxG.cameras.add(screencam);
        FlxG.cameras.add(hudcam);
    }

    function setupHUD()
    {
        hudGroup = new FlxGroup();
        add(hudGroup);
        hudGroup.cameras = [hudcam];

        var hud : FlxSprite = new FlxSprite(0, 0, "assets/images/temp-hud.png");
        // hud.alpha = 0.2;
        addHudElement(hud);

        
        var label : flixel.text.FlxBitmapText = text.PixelText.New(12, 36, "Bananas\nWhatever\nDandelion\nBig lion\nRock monster\nSkeleton\nSkele throw");
        addHudElement(label);

        var roomNameLabel : FlxBitmapText = text.PixelText.New(0, 0, roomData.name);
        roomNameLabel.x = 194 - roomNameLabel.width/2;
        roomNameLabel.y = 174;
        addHudElement(roomNameLabel);
    }

    function addHudElement(element : FlxObject)
    {
        element.scrollFactor.set(0, 0);
        element.cameras = [hudcam];
        hudGroup.add(element);
    }

    override public function update(elapsed : Float) : Void
    {
        player.preupdate();

        // Handle overlaps

        triggers.forEachExists(function(t:FlxBasic) {
            cast(t, Solid).color = 0xFFFFFFFF;
        });
        FlxG.overlap(player, triggers, function(p : Player, trigger : Solid) {
            trigger.color = 0xFF00FF00;
        });
        
        super.update(elapsed);

        // Check if the player is OOB and we need to switch rooms
        handleRoomSwitching();

        // Handle debug routines
        handleDebugRoutines();
    }

    function handleRoomSwitching()
    {
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
            if (newRoomId != null && newRoomId != GameStatus.room) 
            {
                trace("Moving to " + newRoomId);
            
                var newRoom : RoomData = mapReader.getRoom(newRoomId);
                GameStatus.room = newRoomId;

                var nextPlayerData : PlayerData = {
                    x: player.x,
                    y: player.y,
                    facing : player.facing,
                    state : player.state,
                    hspeed : player.hspeed,
                    vspeed : player.vspeed,
                    screenOffsetX: (tx-cursorX != 0 ? 0 : newRoom.gridX - roomData.gridX),
                    screenOffsetY: (ty-cursorY != 0 ? 0 : newRoom.gridY - roomData.gridY),
                    leftPressed: Gamepad.left(),
                    rightPressed: Gamepad.right(),
                    debug: player.debug
                };

                FlxG.switchState(new World(nextPlayerData));
            }
            else
            {
                player.x -= (tx-cursorX) * 7;
                player.y -= (ty-cursorY) * 14;
            }
        }
    }

    /* FUNNY DEBUG AREA */
    function handleDebugRoutines()
    {
        updateCursor();

        var cx : Float = FlxG.mouse.screenX + 2;
        var cy : Float = FlxG.mouse.screenY - 7;

        var wx : Float = Std.int(cx/screencam.scaleX + screencam.scroll.x);
        var wy : Float = Std.int(cy + screencam.scroll.y);

        var x = wx;
        var y = wy;

        mouseTile.x = cx; Std.int(cx/14)*14;
        mouseTile.y = cy; Std.int(cy/14)*14;

        if (FlxG.mouse.justPressed)
        {
            if (FlxG.keys.pressed.ALT)
                oneways.add(new Solid(Std.int(x / 7)*7, Std.int(y / 14)*14, 7, 4, this));
            else if (FlxG.keys.pressed.SHIFT)
                triggers.add(new Solid(Std.int(x / 7)*7, Std.int(y / 14)*14, 7, 14, this));
            else
            {
                var s = new Solid(Std.int(x / 7)*7, Std.int(y / 14)*14, 7, 14, this);
                solids.add(s);
            }
        }

        label.text = "p: " + player.x + ", " + player.y + "\n" +
                     "(" + player.state + ")" + "\n" +
                    // "c: " + cursorX + ", " + cursorY + "\n" +
                    // "s: " + screencam.x + ", " + screencam.y + "\n" +
                    "s: " + screencam.scroll + "\n" +
                    // "m: " + mouseTile.x + ", " + mouseTile.y + "\n" +
                    "g: " + gamepadString() + "\n" +
                    /*"h: " + (""+player.hspeed).substr(0, 4) + "\n" +
                    "   " + (""+player.haccel).substr(0, 4) + "\n" +
                    "   " + (""+player.xRemainder).substr(0, 4) + "\n" + */
                    "";
    }

    function updateCursor()
    {
        cursorX = roomData.gridX + Std.int((player.x / (7*15)) % (7*15));
        cursorY = roomData.gridY + Std.int((player.y / (14*11)) % (14*11));
    }

    function gamepadString() : String
    {
        var str = "";
        
        str += (Gamepad.left() ? "<" : ".");
        str += (Gamepad.right() ? ">" : ".");
        str += (Gamepad.pressed(Gamepad.A) ? "A" : ".");

        return str;
    }
}

typedef PlayerData = {
    var x : Float;
    var y : Float;
    var facing : Int;
    var state : Player.State;
    var hspeed : Float;
    var vspeed : Float;
    var screenOffsetX : Int;
    var screenOffsetY : Int;
    var leftPressed : Bool;
    var rightPressed : Bool;
    var debug : Bool;
}