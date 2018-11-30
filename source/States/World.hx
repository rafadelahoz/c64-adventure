package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;

class World extends FlxState
{
    var screencam : FlxCamera;
    var hudcam : FlxCamera;

    public var platforms : FlxGroup;
    public var solids : FlxGroup;
    public var oneways : FlxGroup;

    var tilemap : FlxTilemap;

    public var player : Player;

    var mouseTile : FlxSprite;

    var label : flixel.text.FlxBitmapText;

    override public function create() : Void
    {
        FlxG.mouse.useSystemCursor = true;
        FlxG.scaleMode = new flixel.system.scaleModes.PixelPerfectScaleMode();

        var bg = new flixel.addons.display.FlxBackdrop("assets/images/bg.png",1, 1, false, false);
        // bg.cameras = [screencam];
        add(bg);

        solids = new FlxGroup();
        add(solids);

        tilemap = new FlxTilemap();
        var arr = [];
        for (i in 0...200*200)
            arr.push(0);
        tilemap.loadMapFromArray(arr, 200, 200, "assets/images/tileset.png", 7, 14);
        add(tilemap);

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

        screencam.follow(player, flixel.FlxCamera.FlxCameraFollowStyle.PLATFORMER);

        super.create();

        // DEBUG
        mouseTile = new FlxSprite(0, 0);
        // mouseTile.offset.set(7, 0);
        mouseTile.setSize(14, 14);
        mouseTile.makeGraphic(14, 14, 0x00000000);
        // flixel.util.FlxSpriteUtil.drawRect(mouseTile, 1, 1, 12, 12, 0x00FFFFFF, {thickness: 1, color: 0xFFFFFFFF});
        flixel.util.FlxSpriteUtil.drawCircle(mouseTile, 7, 7, 2, 0xFFFFFFFF);
        add(mouseTile);
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
        //screencam.setScrollBounds(0, 2000, 0, 2000);

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

        var cx : Float = FlxG.mouse.screenX + 3;
        var cy : Float = FlxG.mouse.screenY - 7;

        var wx : Float = cx/screencam.scaleX + screencam.scroll.x;
        var wy : Float = cy + screencam.scroll.y;

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

        if (x >= tilemap.x && x < tilemap.x+tilemap.width && y >= tilemap.y && y < tilemap.y+tilemap.width)
        {
            if (FlxG.keys.justPressed.ZERO)
                tilemap.setTile(Std.int(x / 7), Std.int(y / 14), 0);
            else if (FlxG.keys.justPressed.ONE)
                tilemap.setTile(Std.int(x / 7), Std.int(y / 14), 1);
            else if (FlxG.keys.justPressed.TWO)
                tilemap.setTile(Std.int(x / 7), Std.int(y / 14), 2);
            else if (FlxG.keys.justPressed.THREE)
                tilemap.setTile(Std.int(x / 7), Std.int(y / 14), 3);
            else if (FlxG.keys.justPressed.FOUR)
                tilemap.setTile(Std.int(x / 7), Std.int(y / 14), 4);
            else if (FlxG.keys.justPressed.FIVE)
                tilemap.setTile(Std.int(x / 7), Std.int(y / 14), 5);
            else if (FlxG.keys.justPressed.SIX)
                tilemap.setTile(Std.int(x / 7), Std.int(y / 14), 6);
            else if (FlxG.keys.justPressed.SEVEN)
                tilemap.setTile(Std.int(x / 7), Std.int(y / 14), 7);
            else if (FlxG.keys.justPressed.EIGHT)
                tilemap.setTile(Std.int(x / 7), Std.int(y / 14), 8);
            else if (FlxG.keys.justPressed.NINE)
                tilemap.setTile(Std.int(x / 7), Std.int(y / 14), 9);
        }

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
