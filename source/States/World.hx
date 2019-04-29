package;

import flixel.input.gamepad.lists.FlxGamepadMotionValueList;
import Inventory.ItemData;
import MapReader.ActorData;
import flixel.FlxBasic;
import flixel.text.FlxBitmapText;
import flixel.FlxObject;
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
    public var mapData : MapData;
    public var roomData : RoomData;
    var cursorX : Int;
    var cursorY : Int;

    var transitionData : TransitionData;

    public var screencam : FlxCamera;
    public var hudcam : FlxCamera;

    public var hudGroup : FlxGroup;
    public var hud : Hud;

    public var platforms : FlxGroup;
    public var solids : FlxGroup;
    public var oneways : FlxGroup;
    public var ladders : FlxGroup;

    var triggers : FlxGroup;
    public var items : FlxGroup;

    var tilemapBG : FlxTilemap;
    var tilemapFG : FlxTilemap;

    public var player : Player;

    var mouseTile : FlxSprite;

    var label : flixel.text.FlxBitmapText;

    public var left     (get, null) : Float;
    public var right    (get, null) : Float;
    public var top      (get, null) : Float;
    public var bottom   (get, null) : Float;

    public function new(?TransitionData : TransitionData = null)
    {
        super();

        transitionData = TransitionData;
    }

    override public function create() : Void
    {
        mapReader = new MapReader();
        mapReader.read(GameStatus.map);
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

        items = new FlxGroup();
        add(items);

        platforms = new FlxGroup();
        platforms.add(solids);
        platforms.add(oneways);

        mapReader.buildSolids(roomData, this, solids, oneways, ladders);

        mapReader.buildEntities(roomData, this);

        restoreRoomStatus();

        spawnPlayer();       

        setupCameras();
        setupHUD();

        var grid : Grid = new Grid(this);
        grid.cameras = [screencam];
        add(grid);

        screencam.follow(player, flixel.FlxCamera.FlxCameraFollowStyle.PLATFORMER);
        bg.cameras = [screencam];

        super.create();

        // DEBUG
        label = text.PixelText.New(0, 0, "HELLO");
        addHudElement(label);
    }

    function spawnPlayer() 
    {
        // If there's no transitionData, it's the level entry
        if (transitionData == null)
        {
            // Locate spawn point
            var spawn : ActorData = mapReader.findActor(roomData, "spawn");
            // TODO: Temporary patch until all maps have spawns
            if (spawn == null)
            {
                spawn = {
                    id: "", x: 32, y: 32, type: "spawn", w: 1, h: 1, properties: null
                };
            }

            transitionData = {
                dx: 0,
                dy: 0,
                screenOffsetX: 0,
                screenOffsetY: 0,
                playerData: Player.getInitialPlayerData(spawn.x * 7, spawn.y * 14)
            };
        }

         // Reposition player after transition
        var playerData : PlayerData = transitionData.playerData;
        
        // 1. Adjust screen offsets
        playerData.x += transitionData.screenOffsetX*15*7;
        playerData.y += transitionData.screenOffsetY*11*14;
        
        // 2. Reposition considering the borders of the new screen
        if (transitionData.dx < 0)
            playerData.x = roomData.columns*7-3;
        else if (transitionData.dx > 0)
            playerData.x = 0;
        if (transitionData.dy < 0)
            playerData.y = roomData.rows*14-3;
        else if (transitionData.dy > 0)
            playerData.y = 0;

        player = new Player(playerData, this);
        add(player);

        if (playerData.carrying != null) 
        {
            useItem(playerData.carrying, false);
        }

        // Force an input event given previous state
        Gamepad.handleBufferedState(playerData.leftPressed, playerData.rightPressed, 
                                    playerData.upPressed, playerData.downPressed,
                                    playerData.jumpPressed, playerData.actionPressed);

        /*if (mapReader.color(roomData.colors[1]) == 0xFF000000)
            player.color = mapReader.color(roomData.colors[1]);*/
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

        hud = new Hud(this);
        addHudElement(hud);
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

        /* Handle overlaps */
        // Player vs triggers
        triggers.forEachExists(function(t:FlxBasic) {
            cast(t, Solid).color = 0xFFFFFFFF;
        });        
        FlxG.overlap(player, triggers, function(p : Player, trigger : Solid) {
            trigger.color = 0xFF00FF00;
        });

        // Inventory management
        if (Gamepad.justPressed(Gamepad.Select))
        {
            Inventory.MoveCursor();
        }

        if (Gamepad.justPressed(Gamepad.B))
        {
            var item : ItemData = Inventory.GetCurrent();
            useItem(item);
        }
        
        super.update(elapsed);

        // Check if the player is OOB and we need to switch rooms
        handleRoomSwitching();

        // Handle debug routines
        handleDebugRoutines();
    }

    function useItem(item : ItemData, ?current : Bool = true)
    {
        if (item != null)
        {
            // TODO: Check item type and act accordingly
            // if (item.type == "BANANAS")
            var itemActor : Item = spawnItemAt(player.x, player.y, item);
            if (player.onUseItem(itemActor)) 
            {
                items.add(itemActor);
                // Remove the item from the inventory only if it's the current one
                if (current)
                    Inventory.RemoveCurrent();
            }
            else
            {
                itemActor.destroy();
            }
        }
    }

    function spawnItemAt(x : Float, y : Float, item : ItemData) : Item
    {
        switch (item.type)
        {
            case "DONUT":
                return new ItemDonut(x, y, this, item);
            default:
                return new Item(x, y, this, item);
        }
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
            var canMove : Bool = false;
            // Allow moving in 1 direction only
            // and check that the new screen is in the map bounds
            if ((tx == cursorX || ty == cursorY) && 
                tx >= 0 && tx < mapData.size.x && ty >= 0 && ty < mapData.size.y)
            {
                var newRoomId : Null<Int> = mapData.grid[tx+ty*mapData.size.x];
                if (newRoomId != null && newRoomId != GameStatus.room) 
                {
                    canMove = true;
                    trace("Moving to " + newRoomId);

                    // Store room status in LRAM, WRAM
                    storeRoomStatus();
                
                    var newRoom : RoomData = mapReader.getRoom(newRoomId);
                    GameStatus.room = newRoomId;

                    var dx : Int = tx-cursorX;
                    var dy : Int = ty-cursorY;

                    var transitionData : TransitionData = {
                        dx: dx,
                        dy: dy,
                        screenOffsetX: (dx != 0 ? 0 : roomData.gridX - newRoom.gridX),
                        screenOffsetY: (dy != 0 ? 0 : roomData.gridY - newRoom.gridY),
                        playerData: player.getPlayerData(dy < 0)
                    };

                    FlxG.switchState(new World(transitionData));
                }
            }
            
            if (!canMove)
            {
                player.x -= (tx-cursorX) * 7;
                player.y -= (ty-cursorY) * 14;
            }
        }
    }

    function storeRoomStatus()
    {
        var itemsData : Array<LRAM.StoredItemData> = [];
        var itemActor : Item;
        trace("Storing items of room " + roomData.id);
        for (item in items)
        {
            if (item != null && item.alive && player.carrying != item)
            {
                itemActor = cast(item, Item);
                trace("Storing " + itemActor);
                itemsData.push({
                    x: itemActor.x,
                    y: itemActor.y,
                    data: itemActor.data
                });
            }
        }

        LRAM.StoreRoom("" + roomData.id, itemsData);

        // TODO: Store important items in WRAM, or...?
        // TODO: Actors?
    }

    function restoreRoomStatus()
    {
        var itemsList : Array<LRAM.StoredItemData> = LRAM.GetRoom("" + roomData.id);
        if (itemsList != null)
        {
            var actor : Item = null;
            for (item in itemsList)
            {
                actor = spawnItemAt(item.x, item.y, item.data);
                items.add(actor);
            }
        }
    }

    inline function get_left() : Float
    {
        return 0;
    }

    inline function get_right() : Float
    {
        return roomData.columns*7;
    }

    inline function get_top() : Float
    {
        return 0;
    }

    inline function get_bottom() : Float
    {
        return roomData.rows*14;
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

        if (FlxG.mouse.justPressed)
        {
            if (FlxG.keys.pressed.ALT)
                oneways.add(new Solid(Std.int(x / 7)*7, Std.int(y / 14)*14, 7, 4, this));
            else if (FlxG.keys.pressed.SHIFT)
            {
                // Create trigger
                // triggers.add(new Solid(Std.int(x / 7)*7, Std.int(y / 14)*14, 7, 14, this));
                
                // Create item
                var data : ItemData = {id: "0", type: "KEY", label: "One key"};

                var item : Item = new Item(Std.int(x / 7)*7, Std.int(y / 14)*14, this, data);
                items.add(item);
            }
            else
            {
                // var s = new Solid(Std.int(x / 7)*7, Std.int(y / 14)*14, 7, 14, this);
                var s = new LockSolid(Std.int(x / 7)*7, Std.int(y / 14)*14, 7, 14*4, this);
                s.init("whatever");
                solids.add(s);
            }
        }

        label.text = "p: " + player.x + ", " + player.y + "\n" +
                     "(" + player.state + ")" + "\n" +
                    // "c: " + cursorX + ", " + cursorY + "\n" +
                    // "s: " + screencam.x + ", " + screencam.y + "\n" +
                    "s: " + screencam.scroll + "\n" +
                    "g: " + gamepadString() + "\n" +
                    /*"h: " + (""+player.hspeed).substr(0, 4) + "\n" +
                    "   " + (""+player.haccel).substr(0, 4) + "\n" +
                    "   " + (""+player.xRemainder).substr(0, 4) + "\n" + */
                    "";

        if (FlxG.keys.justPressed.D)
        {
            Inventory.Add({
                type: "DONUT", label: "Cool Donut", id: "xxx"
            });
        }
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
        str += (Gamepad.up() ? "^" : ".");
        str += (Gamepad.down() ? "v" : ".");
        str += (Gamepad.pressed(Gamepad.A) ? "A" : ".");
        str += (Gamepad.pressed(Gamepad.B) ? "B" : ".");

        return str;
    }
}

typedef TransitionData = {
    var dx : Int;
    var dy : Int;
    var screenOffsetX : Int;
    var screenOffsetY : Int;
    var playerData : PlayerData;
}

typedef PlayerData = {
    var x : Float;
    var y : Float;
    var facing : Int;
    var state : Player.State;
    var hspeed : Float;
    var vspeed : Float;
    var leftPressed : Bool;
    var rightPressed : Bool;
    var upPressed : Bool;
    var downPressed : Bool;
    var jumpPressed : Bool;
    var actionPressed : Bool;
    var debug : Bool;
    var carrying : ItemData;
}