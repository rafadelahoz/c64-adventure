package;

import flixel.util.FlxTimer;
import flixel.util.FlxSpriteUtil;
import flixel.FlxBasic;
import flixel.text.FlxBitmapText;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxCamera;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;

import Teleport.TeleportData;
import Inventory.ItemData;
import MapReader.ActorData;

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

    var background : FlxSprite;

    public var platforms : FlxGroup;
    public var solids : FlxGroup;
    public var oneways : FlxGroup;
    public var ladders : FlxGroup;
    public var hazards : FlxGroup;
    public var teleports : FlxGroup;
    public var exits : FlxGroup;
    public var enemies : FlxGroup;

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

    public var paused : Bool;
    var pauseTimer : FlxTimer;

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

        background = new FlxSprite(0, 0);
        background.makeGraphic(210, 156, mapReader.color(roomData.colors[0]));
        background.scrollFactor.set(0, 0);
        add(background);

        tilemapBG = new FlxTilemap();
        tilemapBG.loadMapFromArray(roomData.tiles.bg, roomData.columns, roomData.rows, "assets/images/tileset.png", 7, 14);
        tilemapBG.color = mapReader.color(roomData.colors[1]);
        add(tilemapBG);

        tilemapFG = new FlxTilemap();
        tilemapFG.loadMapFromArray(roomData.tiles.fg, roomData.columns, roomData.rows, "assets/images/tileset.png", 7, 14);
        tilemapFG.color = mapReader.color(roomData.colors[2]);
        add(tilemapFG);

        solids = new FlxGroup();
        add(solids);

        oneways = new FlxGroup();
        add(oneways);

        ladders = new FlxGroup();
        add(ladders);

        hazards = new FlxGroup();
        add(hazards);

        teleports = new FlxGroup();
        add(teleports);

        exits = new FlxGroup();
        add(exits);

        enemies = new FlxGroup();
        add(enemies);

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
        background.cameras = [screencam];

        pauseTimer = new FlxTimer();
        paused = false;

        if (transitionData.teleporting)
        {
            player.findGround();
            
            var fader : Fader = new Fader(this);
            // pause();
            fader.fade(true, function() {
                remove(fader);
                fader.destroy();
            });
        }

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
                teleporting: true,
                dx: 0,
                dy: 0,
                screenOffsetX: 0,
                screenOffsetY: 0,
                playerData: Player.getInitialPlayerData(spawn.x * Constants.TileWidth, spawn.y * Constants.TileHeight)
            };
        }

         // Reposition player after transition
        var playerData : PlayerData = transitionData.playerData;
        
        // 1. Adjust screen offsets
        playerData.x += transitionData.screenOffsetX*15*Constants.TileWidth;
        playerData.y += transitionData.screenOffsetY*11*Constants.TileHeight;
        
        // 2. Reposition considering the borders of the new screen
        if (transitionData.dx < 0)
            playerData.x = roomData.columns*Constants.TileWidth-3;
        else if (transitionData.dx > 0)
            playerData.x = 0;
        if (transitionData.dy < 0)
            playerData.y = roomData.rows*Constants.TileHeight-3;
        else if (transitionData.dy > 0)
            playerData.y = 0;

        player = new Player(playerData, this);
        add(player);

        if (playerData.carrying != null) 
        {
            useItem(playerData.carrying, false);
        }

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

    function transitionTo()
    {
        roomData = mapReader.getRoom(GameStatus.room);

        background.makeGraphic(210, 156, mapReader.color(roomData.colors[0]));

        tilemapBG.loadMapFromArray(roomData.tiles.bg, roomData.columns, roomData.rows, "assets/images/tileset.png", 7, 14);
        tilemapBG.color = mapReader.color(roomData.colors[1]);

        tilemapFG.loadMapFromArray(roomData.tiles.fg, roomData.columns, roomData.rows, "assets/images/tileset.png", 7, 14);
        tilemapFG.color = mapReader.color(roomData.colors[2]);

        // TODO: Destroy/kill all members
        solids.clear();

        // TODO: Destroy/kill all members
        oneways.clear();

        // TODO: Destroy/kill all members
        ladders.clear();

        // TODO: Destroy/kill all members
        hazards.clear();

        // TODO: Destroy/kill all members
        teleports.clear();

        // TODO: Destroy/kill all members
        exits.clear();

        // TODO: Destroy/kill all members
        enemies.clear();

        // TODO: Destroy/kill all members
        triggers.clear();

        // TODO: Destroy/kill all members
        items.clear();

        platforms.clear();
        platforms.add(solids);
        platforms.add(oneways);

        mapReader.buildSolids(roomData, this, solids, oneways, ladders);

        mapReader.buildEntities(roomData, this);

        restoreRoomStatus();

        // TODO: Better player management
        //   - don't destroy instance
        //   - reposition and set the appropriate variables
        player.destroy();
        spawnPlayer();       

        screencam.setScrollBoundsRect(0-210/2/2, 0, Math.max(roomData.columns*7*2+210/2/2-54-54-54+6-2, 210), Math.max(roomData.rows*14-2, 156), true);

        hud.onRoomChange();

        screencam.follow(player, flixel.FlxCamera.FlxCameraFollowStyle.PLATFORMER);

        paused = false;

        if (transitionData.teleporting)
        {
            player.findGround();
            
            var fader : Fader = new Fader(this);
            // pause();
            fader.fade(true, function() {
                remove(fader);
                fader.destroy();
            });
        }
    }

    override public function update(elapsed : Float) : Void
    {
        if (!paused)
        {
            player.preupdate();

            /* Handle overlaps */

            // Player vs Enemies
            FlxG.overlap(player, enemies, function(p : Player, e : Enemy) {
                e.onCollisionWithPlayer(p);
                p.onCollisionWithDanger(e);
            });

            // Player vs hazards
            FlxG.overlap(player, hazards, function(p : Player, hazard : Hazard) {
                p.onCollisionWithDanger(hazard);
            });

            // Items vs hazards
            FlxG.overlap(items, hazards, function(i : Item, hazard : Hazard) {
                i.onCollisionWithHazard(hazard);
            });

            // Player vs triggers
            triggers.forEachExists(function(t:FlxBasic) {
                cast(t, Solid).color = 0xFFFFFFFF;
            });
            FlxG.overlap(player, triggers, function(p : Player, trigger : Solid) {
                trigger.color = 0xFF00FF00;
            });

            // Player vs Exits
            FlxG.overlap(player, exits, function(p : Player, e : MapExit) {
                pause();
                wait(1, function() {
                    var fader = new Fader(this);
                    fader.fade(false, function() {
                        wait(1, function() {
                            GameController.ClearMap(e.name);
                            var clearThing : CourseClearThing = new CourseClearThing(this);
                            addHudElement(clearThing);
                        });
                    });
                });
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
        }
        
        super.update(elapsed);

        // Late update?
        for (solid in solids)
            cast(solid, Solid).lateUpdate();

        // Check if the player is OOB and we need to switch rooms
        handleRoomSwitching();

        // Handle debug routines
        handleDebugRoutines();
    }

    function useItem(item : ItemData, ?willingly : Bool = true)
    {
        if (item != null)
        {
            // TODO: Check item type and act accordingly
            // if (item.type == "BANANAS")
            var itemActor : Item = spawnItemAt(player.x, player.y, item);
            if (player.onUseItem(itemActor, willingly)) 
            {
                items.add(itemActor);
                // Remove the item from the inventory only if it's the current one
                if (willingly)
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

                    // Store room status in LRAM, WRAM
                    storeRoomStatus();
                
                    var newRoom : RoomData = mapReader.getRoom(newRoomId);
                    GameStatus.room = newRoomId;

                    var dx : Int = tx-cursorX;
                    var dy : Int = ty-cursorY;

                    var transitionData : TransitionData = {
                        teleporting: false,
                        dx: dx,
                        dy: dy,
                        screenOffsetX: (dx != 0 ? 0 : roomData.gridX - newRoom.gridX),
                        screenOffsetY: (dy != 0 ? 0 : roomData.gridY - newRoom.gridY),
                        playerData: player.getPlayerData()
                    };

                    this.transitionData = transitionData;
                    transitionTo();
                }
            }
            
            if (!canMove)
            {
                player.moveX(-7*(tx-cursorX));
                player.moveY(-14*(ty-cursorY));
            }
        }
    }

    public function teleportTo(data : TeleportData)
    {
        var newRoomId : Int = data.target;
        GameStatus.room = newRoomId;

        storeRoomStatus();
        
        var transitionData : TransitionData = {
            teleporting: true,
            dx: 0, dy: 0, screenOffsetX: 0, screenOffsetY: 0,
            playerData: player.getPlayerTeleportData()
        };

        transitionData.playerData.x = data.tileX * Constants.TileWidth;
        transitionData.playerData.y = data.tileY * Constants.TileHeight;

        this.transitionData = transitionData;
        transitionTo();
    }

    function storeRoomStatus()
    {
        var itemsData : Array<LRAM.StoredItemData> = [];
        var itemActor : Item;
        
        for (item in items)
        {
            if (item != null && item.alive && player.carrying != item)
            {
                itemActor = cast(item, Item);
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

    public function onPlayerDead(?dissappeared : Bool = false) 
    {
        hud.playerDead = true;

        if (!dissappeared)
        {
            FlxSpriteUtil.fill(background, 0xFF5d0800);
            
            tilemapBG.visible = false;
            tilemapFG.visible = false;
            
            solids.visible = false;
            solids.visible = false;
            platforms.visible = false;
            oneways.visible = false;
            ladders.visible = false;
            hazards.visible = false;
            teleports.visible = false;
            exits.visible = false;
            enemies.visible = false;
            triggers.visible = false;
            items.visible = false;
        }
        else
        {
            var gameoverthing : GameOverThing = new GameOverThing(this);
            addHudElement(gameoverthing);
        }
    }

    public function pause(?duration : Float = -1, ?callback : Void -> Void = null)
    {
        if (paused)
            return;
        
        paused = true;
        if (duration > 0)
            pauseTimer.start(duration, function(t:FlxTimer) {
                if (callback != null)
                    callback();
                unpause();
            });
    }

    public function unpause()
    {
        paused = false;
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

    function wait(seconds : Float, callback : Void -> Void)
    {
        new FlxTimer().start(seconds, function(t:FlxTimer) {
            t.destroy();
            callback();
        });
    }

    /* FUNNY DEBUG AREA */
    function handleDebugRoutines()
    {
        #if (desktop || web)
        if (FlxG.keys.justPressed.F9)
            openSubState(new DebugSubstate(this));

        updateCursor();

        var cx : Float = FlxG.mouse.screenX + 2;
        var cy : Float = FlxG.mouse.screenY - 7;

        var wx : Float = Std.int(cx/screencam.scaleX + screencam.scroll.x);
        var wy : Float = Std.int(cy + screencam.scroll.y);

        var x = wx;
        var y = wy;

        if (FlxG.mouse.justPressed)
        {
            var sx : Int = Std.int(x / 7)*7;
            var sy : Int = Std.int(y / 14)*14;

            if (FlxG.keys.pressed.SHIFT)
            {
                var s = new FallingSolid(sx, sy, 7, 14, this);
                solids.add(s);
            }
            else if (FlxG.keys.pressed.ALT)
            {
                var s = new Solid(sx, sy, 14, 28, this);
                s.visible = true;
                solids.add(s);
            }
            else
            {
                var properties : haxe.DynamicAccess<Dynamic> = {};
                if (FlxG.random.bool())
                    properties.set("type", "RED");
                var e : Enemy = new EnemySkeleton(sx, sy, this, properties);
                enemies.add(e);
            }
        }

        label.text = "";
                    /*"p: " + player.x + ", " + player.y + "\n" +
                     "(" + player.state + ")" + "\n" +
                    // "c: " + cursorX + ", " + cursorY + "\n" +
                    // "s: " + screencam.x + ", " + screencam.y + "\n" +
                    "s: " + screencam.scroll + "\n" +
                    "g: " + gamepadString() + "\n" +
                        / *"h: " + (""+player.hspeed).substr(0, 4) + "\n" +
                        "   " + (""+player.haccel).substr(0, 4) + "\n" +
                        "   " + (""+player.xRemainder).substr(0, 4) + "\n" + * /
                    "";¿*/

        if (FlxG.keys.justPressed.ESCAPE)
        {
            player.triggerDeath();
        }
        #end
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
    var teleporting : Bool;
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
    var actingTimerRemaining : Float;
    var invulnerableTimerRemaining : Float;
    var hspeed : Float;
    var vspeed : Float;
    var debug : Bool;
    var carrying : ItemData;
}